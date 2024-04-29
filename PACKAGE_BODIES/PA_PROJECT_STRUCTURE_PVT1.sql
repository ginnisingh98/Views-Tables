--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_STRUCTURE_PVT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_STRUCTURE_PVT1" as
/*$Header: PAXSTCVB.pls 120.23.12010000.8 2009/12/29 08:55:56 bifernan ship $*/

-- API name                      : Create_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id    IN  NUMBER
--   p_structure_number  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_name    IN  VARCHAR2
--   p_calling_flag  IN  VARCHAR2 := 'WORKPLAN'
--   p_structure_description     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
--   x_structure_id  OUT     NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_number                  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_name                    IN  VARCHAR2
   ,p_calling_flag                      IN  VARCHAR2 := 'WORKPLAN'
   ,p_structure_description             IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_approval_reqd_flag            IN VARCHAR2 := 'N'
   ,p_auto_publish_flag             IN VARCHAR2 := 'N'
   ,p_approver_source_id            IN NUMBER   := FND_API.G_MISS_NUM
   ,p_approver_source_type          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_default_display_lvl           IN NUMBER   := 0
   ,p_enable_wp_version_flag        IN VARCHAR2 := 'N'
   ,p_auto_pub_upon_creation_flag   IN VARCHAR2 := 'N'
   ,p_auto_sync_txn_date_flag       IN VARCHAR2 := 'N'
   ,p_txn_date_sync_buf_days        IN NUMBER   := FND_API.G_MISS_NUM
   ,p_lifecycle_version_id          IN NUMBER   := FND_API.G_MISS_NUM
   ,p_current_phase_version_id      IN NUMBER   := FND_API.G_MISS_NUM
   ,p_progress_cycle_id             IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_wq_enable_flag                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_remain_effort_enable_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_percent_comp_enable_flag      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_next_progress_update_date     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_action_set_id                 IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_weight_basis_code        IN VARCHAR2 := 'DURATION'
   ,x_structure_id                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(250);
    l_return_status        VARCHAR2(2);
    l_error_message_code   VARCHAR2(250);

    l_rowid                VARCHAR2(255);
    l_proj_element_id      PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
    l_structure_type_id    PA_STRUCTURE_TYPES.STRUCTURE_TYPE_ID%TYPE;
    l_proj_structure_type_id PA_PROJ_STRUCTURE_TYPES.PROJ_STRUCTURE_TYPE_ID%TYPE;
    l_structure_type       PA_STRUCTURE_TYPES.STRUCTURE_TYPE_CLASS_CODE%TYPE;

    l_workplan_license     VARCHAR2(1);
    l_financial_license      VARCHAR2(1);
    l_multi_struc_license  VARCHAR2(1);

    l_split_flag          VARCHAR2(1);
    l_split_flag2         VARCHAR2(1);

    l_attribute_category VARCHAR2(30) := NULL;
    l_attribute1         VARCHAR2(150) := NULL;
    l_attribute2         VARCHAR2(150) := NULL;
    l_attribute3         VARCHAR2(150) := NULL;
    l_attribute4         VARCHAR2(150) := NULL;
    l_attribute5         VARCHAR2(150) := NULL;
    l_attribute6         VARCHAR2(150) := NULL;
    l_attribute7         VARCHAR2(150) := NULL;
    l_attribute8         VARCHAR2(150) := NULL;
    l_attribute9         VARCHAR2(150) := NULL;
    l_attribute10        VARCHAR2(150) := NULL;
    l_attribute11        VARCHAR2(150) := NULL;
    l_attribute12        VARCHAR2(150) := NULL;
    l_attribute13        VARCHAR2(150) := NULL;
    l_attribute14        VARCHAR2(150) := NULL;
    l_attribute15        VARCHAR2(150) := NULL;

    l_proj_prog_attr_id  NUMBER;
    l_structure_description VARCHAR2(2000);

    cursor get_split_flag IS
    select split_cost_from_workplan_flag, SPLIT_COST_FROM_BILL_FLAG
      from pa_projects_all
     where project_id = p_project_id;

    cursor get_licensed(p_workplan VARCHAR2,
                      p_financial  VARCHAR2,
                      p_deliverable VARCHAR2)  IS
    select structure_type_id, structure_type_class_code
      from pa_structure_types
     where (structure_type_class_code = 'WORKPLAN' and 'Y' = p_workplan)
        or (structure_type_class_code = 'FINANCIAL' and 'Y' = p_financial)
        or (structure_type_class_code = 'DELIVERABLE' and 'Y' = p_deliverable);
    l_deliverable_license VARCHAR2(1) := 'N';

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_STRUC_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    --Check if the structure name is unique within the project
    If (pa_project_structure_utils.check_structure_name_unique(p_structure_name,
                                                               NULL,
                                                               p_project_id) <> 'Y') THEN
      --Name is not unique
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_STRUC_NAME_UNIQUE');
      x_msg_data := 'PA_PS_STRUC_NAME_UNIQUE';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Check what is licensed.
    l_workplan_license := nvl(pa_install.is_pjt_licensed, 'N');
    l_financial_license  := nvl(pa_install.is_costing_licensed, 'N');

    IF (p_calling_flag IS NOT NULL) THEN
      IF (p_calling_flag = 'WORKPLAN') THEN
        l_financial_license := 'N';
        IF (l_workplan_license = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_PROJ_MANAG_NOT_LIC');
          x_msg_data := 'PA_PS_PROD_MANAG_NOT_LIC';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF (p_calling_flag = 'FINANCIAL') THEN
        l_workplan_license := 'N';
        IF (l_financial_license <> 'Y') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_COSTING_NOT_LIC');
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF (p_calling_flag = 'DELIVERABLE') THEN
        l_workplan_license := 'N';
        l_financial_license := 'N';
        l_deliverable_license := 'Y';
      END IF;
    END IF;

/*
    --Check if we should split structure types into different structure
    open get_split_flag;
    fetch get_split_flag into l_split_flag, l_split_flag2;
    IF get_split_flag%NOTFOUND THEN
      PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_PROJECT_ID');
      x_msg_data := 'PA_INVALID_PROJECT_ID';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    close get_split_flag;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --If splitting structure types, check if one structure type is selected
    If (l_split_flag <> 'N') THEN
      IF (p_calling_flag = 'WORKPLAN') THEN
        l_costing_license := 'N';
        l_billing_license := 'N';
        If (l_workplan_license <> 'Y') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_PROJ_MANAG_NOT_LIC');
          x_msg_data := 'PA_PS_PROD_MANAG_NOT_LIC';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIf (p_calling_flag = 'COSTING') THEN
        IF (l_costing_license <> 'Y') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_COSTING_NOT_LIC');
          x_msg_data := 'PA_PS_COSTING_NOT_LIC';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_workplan_license := 'N';
        If (l_split_flag2 <> 'N') THEN
          l_billing_license := 'N';
        END IF;
      ELSIf (p_calling_flag = 'BILLING') THEN
        IF (l_billing_license <> 'Y') THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_BILLING_NOT_LIC');
          x_msg_data := 'PA_PS_BILLING_NOT_LIC';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        l_workplan_license := 'N';
        If (l_split_flag2 <> 'N') THEN
          l_costing_license := 'N';
        END IF;
      ELSIf (p_calling_flag IS NULL) THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_NO_CALLING_PAGE_SEL');
        x_msg_data := 'PA_PS_NO_CALLING_PAGE_SEL';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
*/

    --Check if multistructure is licensed.
    l_multi_struc_license := 'Y'; --pa_install.is_product_licensed('PA_MULTISTRUCTURE_LICENSED');


    --Replace dff values with null if not entered.
    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute_category IS NULL) THEN
      l_attribute_category := p_attribute_category;
    END IF;
    IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute1 IS NULL) THEN
      l_attribute1 := p_attribute1;
    END IF;
    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute2 IS NULL) THEN
      l_attribute2 := p_attribute2;
    END IF;
    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute3 IS NULL) THEN
      l_attribute3 := p_attribute3;
    END IF;
    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute4 IS NULL) THEN
      l_attribute4 := p_attribute4;
    END IF;
    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute5 IS NULL) THEN
      l_attribute5 := p_attribute5;
    END IF;
    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute6 IS NULL) THEN
      l_attribute6 := p_attribute6;
    END IF;
    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute7 IS NULL) THEN
      l_attribute7 := p_attribute7;
    END IF;
    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute8 IS NULL) THEN
      l_attribute8 := p_attribute8;
    END IF;
    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute9 IS NULL) THEN
      l_attribute9 := p_attribute9;
    END IF;
    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute10 IS NULL) THEN
      l_attribute10 := p_attribute10;
    END IF;
    IF (p_attribute11 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute11 IS NULL) THEN
      l_attribute11 := p_attribute11;
    END IF;
    IF (p_attribute12 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute12 IS NULL) THEN
      l_attribute12 := p_attribute12;
    END IF;
    IF (p_attribute13 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute13 IS NULL) THEN
      l_attribute13 := p_attribute13;
    END IF;
    IF (p_attribute14 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute14 IS NULL) THEN
      l_attribute14 := p_attribute14;
    END IF;
    IF (p_attribute15 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute15 IS NULL) THEN
      l_attribute15 := p_attribute15;
    END IF;
    --rtarway,3655698
    IF (p_structure_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
          l_structure_description := null;
    else
          l_structure_description :=  p_structure_description;
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Insert into pa_proj_elements
    select PA_TASKS_S.NEXTVAL into l_proj_element_id from sys.dual;

    PA_PROJ_ELEMENTS_PKG.insert_row(
     X_ROW_ID              => l_rowid
    ,X_PROJ_ELEMENT_ID     => l_proj_element_id
    ,X_PROJECT_ID          => p_project_id
    ,X_OBJECT_TYPE     => 'PA_STRUCTURES'
    ,X_ELEMENT_NUMBER      => to_char(l_proj_element_id)
    ,X_NAME                => p_structure_name
    ,X_DESCRIPTION     => l_structure_description--rtarway,3655698
    ,X_STATUS_CODE     => NULL
    ,X_WF_STATUS_CODE      => NULL
    ,X_PM_PRODUCT_CODE     => NULL
    ,X_PM_TASK_REFERENCE   => NULL
    ,X_CLOSED_DATE     => NULL
    ,X_LOCATION_ID     => NULL
    ,X_MANAGER_PERSON_ID   => NULL
    ,X_CARRYING_OUT_ORGANIZATION_ID => NULL
    ,X_TYPE_ID               => NULL
    ,X_PRIORITY_CODE       => NULL
    ,X_INC_PROJ_PROGRESS_FLAG   => 'N'
    ,X_REQUEST_ID            => NULL
    ,X_PROGRAM_APPLICATION_ID => NULL
    ,X_PROGRAM_ID            => NULL
    ,X_PROGRAM_UPDATE_DATE => NULL
    ,X_LINK_TASK_FLAG      => 'N'
    ,X_ATTRIBUTE_CATEGORY  => l_attribute_category
    ,X_ATTRIBUTE1            => l_attribute1
    ,X_ATTRIBUTE2            => l_attribute2
    ,X_ATTRIBUTE3            => l_attribute3
    ,X_ATTRIBUTE4            => l_attribute4
    ,X_ATTRIBUTE5            => l_attribute5
    ,X_ATTRIBUTE6            => l_attribute6
    ,X_ATTRIBUTE7            => l_attribute7
    ,X_ATTRIBUTE8            => l_attribute8
    ,X_ATTRIBUTE9            => l_attribute9
    ,X_ATTRIBUTE10         => l_attribute10
    ,X_ATTRIBUTE11         => l_attribute11
    ,X_ATTRIBUTE12         => l_attribute12
    ,X_ATTRIBUTE13         => l_attribute13
    ,X_ATTRIBUTE14         => l_attribute14
    ,X_ATTRIBUTE15         => l_attribute15
    ,X_TASK_WEIGHTING_DERIV_CODE => NULL
    ,X_WORK_ITEM_CODE            => NULL
    ,X_UOM_CODE                  => NULL
    ,X_WQ_ACTUAL_ENTRY_CODE      => NULL
    ,X_TASK_PROGRESS_ENTRY_PAGE_ID => NULL
    ,X_PARENT_STRUCTURE_ID => NULL
    ,X_PHASE_CODE          => NULL
    ,X_PHASE_VERSION_ID    => NULL
        ,X_SOURCE_OBJECT_ID    => p_project_id
    ,X_SOURCE_OBJECT_TYPE  => 'PA_PROJECTS'
    );

    x_structure_id := l_proj_element_id;

--dbms_output.put_line('done inserting to pa_proj_element');

    Open get_licensed(l_workplan_license, l_financial_license, l_deliverable_license);
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('workplan license = '||l_workplan_license);
      pa_debug.debug('financial license = '||l_financial_license);
    END IF;

    LOOP
      FETCH get_licensed into l_structure_type_id, l_structure_type;
      EXIT WHEN get_licensed%NOTFOUND;
--dbms_output.put_line('begin inserting to struture type tbl');
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('structure_type = '||l_structure_type);
      END IF;
      --check if structure type exists

      pa_project_structure_utils.Check_structure_Type_Exists(p_project_id,
                                  l_structure_type,
                                  l_return_status,
                                  l_error_message_code);
--dbms_output.put_line(l_return_status||', '||l_error_message_code);
      If (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA',l_error_message_code);
        x_msg_data := l_error_message_code;
        CLOSE get_licensed;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_structure_type IN ('WORKPLAN','DELIVERABLE')) THEN
        --Add pa_proj_workplan_attr row
        PA_WORKPLAN_ATTR_PVT.CREATE_PROJ_WORKPLAN_ATTRS(
           p_validate_only               => FND_API.G_FALSE
          ,p_project_id                  => p_project_id
          ,p_proj_element_id             => l_proj_element_id
          ,p_approval_reqd_flag          => p_approval_reqd_flag
          ,p_auto_publish_flag           => p_auto_publish_flag
          ,p_approver_source_id          => p_approver_source_id
          ,p_approver_source_type        => p_approver_source_type
          ,p_default_display_lvl         => p_default_display_lvl
          ,p_enable_wp_version_flag      => p_enable_wp_version_flag
          ,p_auto_pub_upon_creation_flag => p_auto_pub_upon_creation_flag
          ,p_auto_sync_txn_date_flag     => p_auto_sync_txn_date_flag
          ,p_txn_date_sync_buf_days      => p_txn_date_sync_buf_days
          ,p_lifecycle_version_id        => p_lifecycle_version_id
          ,p_current_phase_version_id    => p_current_phase_version_id
          ,x_return_status               => l_return_status
          ,x_msg_count                   => x_msg_count
          ,x_msg_data                    => x_msg_data
        );

        IF (l_return_status <> 'S') THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    /* Amit : Moving this code below as it will create project progress attribute records for Delievrables too
        PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
           p_validate_only       => FND_API.G_FALSE
          ,p_project_id          => p_project_id
          ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
          ,P_OBJECT_ID           => l_proj_element_id
          ,p_wq_enable_flag      => p_wq_enable_flag
          ,p_progress_cycle_id   => p_progress_cycle_id
          ,p_remain_effort_enable_flag => p_remain_effort_enable_flag
          ,p_percent_comp_enable_flag => p_percent_comp_enable_flag
          ,p_next_progress_update_date => p_next_progress_update_date
          ,p_action_set_id       => p_action_set_id
          ,p_task_weight_basis_code => p_task_weight_basis_code
      ,p_structure_type        => l_structure_type  -- Amit
          ,x_proj_progress_attr_id => l_proj_prog_attr_id
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
        );

        IF (l_return_status <> 'S') THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    */

      END IF;

      IF (l_structure_type = 'WORKPLAN') THEN -- NOt Adding financial here as progress attr created thru enable_financial_structure
        PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
           p_validate_only       => FND_API.G_FALSE
          ,p_project_id          => p_project_id
          ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
          ,P_OBJECT_ID           => l_proj_element_id
          ,p_wq_enable_flag      => p_wq_enable_flag
          ,p_progress_cycle_id   => p_progress_cycle_id
          ,p_remain_effort_enable_flag => p_remain_effort_enable_flag
          ,p_percent_comp_enable_flag => p_percent_comp_enable_flag
          ,p_next_progress_update_date => p_next_progress_update_date
          ,p_action_set_id       => p_action_set_id
          ,p_task_weight_basis_code => p_task_weight_basis_code
      ,p_structure_type        => l_structure_type  -- Amit
          ,x_proj_progress_attr_id => l_proj_prog_attr_id
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
        );

        IF (l_return_status <> 'S') THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      --Insert into pa_proj_structure_types
      BEGIN
      l_proj_structure_type_id := NULL;
      PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
       X_ROWID                   => l_rowid
      , X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
      , X_PROJ_ELEMENT_ID        => l_proj_element_id
      , X_STRUCTURE_TYPE_ID      => l_structure_type_id
      , X_RECORD_VERSION_NUMBER  => 1
      , X_ATTRIBUTE_CATEGORY     => NULL
      , X_ATTRIBUTE1             => NULL
      , X_ATTRIBUTE2             => NULL
      , X_ATTRIBUTE3             => NULL
      , X_ATTRIBUTE4             => NULL
      , X_ATTRIBUTE5             => NULL
      , X_ATTRIBUTE6             => NULL
      , X_ATTRIBUTE7             => NULL
      , X_ATTRIBUTE8             => NULL
      , X_ATTRIBUTE9             => NULL
      , X_ATTRIBUTE10            => NULL
      , X_ATTRIBUTE11            => NULL
      , X_ATTRIBUTE12            => NULL
      , X_ATTRIBUTE13            => NULL
      , X_ATTRIBUTE14            => NULL
      , X_ATTRIBUTE15            => NULL
      );
      EXCEPTION
        WHEN OTHERS THEN
          CLOSE get_licensed;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    END LOOP;
--dbms_output.put_line('done inserting to struture type tbl');

    CLOSE get_licensed;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_STRUC_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_STRUC_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Create_Structure',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END CREATE_STRUCTURE;


-- API name                      : Create_Structure_Version
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id                      IN  NUMBER
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
--   x_structure_version_id  OUT  NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_structure_version_id              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
     l_rowid VARCHAR2(255);
     l_project_id PA_PROJECTS_ALL.PROJECT_ID%TYPE;

     l_msg_count NUMBER;
     l_msg_data VARCHAR2(250);
     -- added ofr Bug Fix: 4537865
     l_new_structure_version_id     NUMBER;
     -- added for Bug fix: 4537865

    l_attribute_category VARCHAR2(30) := NULL;
    l_attribute1         VARCHAR2(150) := NULL;
    l_attribute2         VARCHAR2(150) := NULL;
    l_attribute3         VARCHAR2(150) := NULL;
    l_attribute4         VARCHAR2(150) := NULL;
    l_attribute5         VARCHAR2(150) := NULL;
    l_attribute6         VARCHAR2(150) := NULL;
    l_attribute7         VARCHAR2(150) := NULL;
    l_attribute8         VARCHAR2(150) := NULL;
    l_attribute9         VARCHAR2(150) := NULL;
    l_attribute10        VARCHAR2(150) := NULL;
    l_attribute11        VARCHAR2(150) := NULL;
    l_attribute12        VARCHAR2(150) := NULL;
    l_attribute13        VARCHAR2(150) := NULL;
    l_attribute14        VARCHAR2(150) := NULL;
    l_attribute15        VARCHAR2(150) := NULL;

    l_dummy              number;

    CURSOR getid is select project_id from pa_proj_elements
                     where proj_element_id = p_structure_id;

    CURSOR cur_elem_ver_seq IS
    SELECT pa_proj_element_versions_s.nextval
      FROM sys.dual;

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE_VERSION begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_STRUC_VER_PVT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    --Get project id
    OPEN getid;
    FETCH getid into l_project_id;
    IF (getid%NOTFOUND) THEN
      CLOSE getid;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE getid;


    --Replace dff values
    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute_category IS NULL) THEN
      l_attribute_category := p_attribute_category;
    END IF;
    IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute1 IS NULL) THEN
      l_attribute1 := p_attribute1;
    END IF;
    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute2 IS NULL) THEN
      l_attribute2 := p_attribute2;
    END IF;
    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute3 IS NULL) THEN
      l_attribute3 := p_attribute3;
    END IF;
    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute4 IS NULL) THEN
      l_attribute4 := p_attribute4;
    END IF;
    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute5 IS NULL) THEN
      l_attribute5 := p_attribute5;
    END IF;
    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute6 IS NULL) THEN
      l_attribute6 := p_attribute6;
    END IF;
    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute7 IS NULL) THEN
      l_attribute7 := p_attribute7;
    END IF;
    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute8 IS NULL) THEN
      l_attribute8 := p_attribute8;
    END IF;
    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute9 IS NULL) THEN
      l_attribute9 := p_attribute9;
    END IF;
    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute10 IS NULL) THEN
      l_attribute10 := p_attribute10;
    END IF;
    IF (p_attribute11 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute11 IS NULL) THEN
      l_attribute11 := p_attribute11;
    END IF;
    IF (p_attribute12 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute12 IS NULL) THEN
      l_attribute12 := p_attribute12;
    END IF;
    IF (p_attribute13 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute13 IS NULL) THEN
      l_attribute13 := p_attribute13;
    END IF;
    IF (p_attribute14 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute14 IS NULL) THEN
      l_attribute14 := p_attribute14;
    END IF;
    IF (p_attribute15 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute15 IS NULL) THEN
      l_attribute15 := p_attribute15;
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    --If no error,
    --Get structure version id
    OPEN cur_elem_ver_seq;
    FETCH cur_elem_ver_seq INTO x_structure_version_id;
    CLOSE cur_elem_ver_seq;

    -- Fix for 4657794 :- This is fix for regression introduced by 4537865
    -- As X_ELEMENT_VERSION_ID is an IN OUT parameter ,we need to initialize, its value l_new_structure_version_id
    -- to  x_structure_version_id

    l_new_structure_version_id := x_structure_version_id ;

    -- End 4657794

--    error_msg(x_structure_version_id||' new structure version id, '||p_structure_id||', '||l_project_id);
    --Insert
    PA_PROJ_ELEMENT_VERSIONS_PKG.INSERT_ROW(
       X_ROW_ID                       => l_rowid
    --,X_ELEMENT_VERSION_ID           => x_structure_version_id         * Commenmted for Bug Fix: 4537865
      ,X_ELEMENT_VERSION_ID       => l_new_structure_version_id     -- added for bug bug Fix: 4537865
      ,X_PROJ_ELEMENT_ID              => p_structure_id
      ,X_OBJECT_TYPE                  => 'PA_STRUCTURES'
      ,X_PROJECT_ID                   => l_project_id
      ,X_PARENT_STRUCTURE_VERSION_ID  => x_structure_version_id
      ,X_DISPLAY_SEQUENCE             => NULL
      ,X_WBS_LEVEL                    => NULL
      ,X_WBS_NUMBER                   => '0'
      ,X_ATTRIBUTE_CATEGORY           => l_attribute_category
      ,X_ATTRIBUTE1                   => l_attribute1
      ,X_ATTRIBUTE2                   => l_attribute2
      ,X_ATTRIBUTE3                   => l_attribute3
      ,X_ATTRIBUTE4                   => l_attribute4
      ,X_ATTRIBUTE5                   => l_attribute5
      ,X_ATTRIBUTE6                   => l_attribute6
      ,X_ATTRIBUTE7                   => l_attribute7
      ,X_ATTRIBUTE8                   => l_attribute8
      ,X_ATTRIBUTE9                   => l_attribute9
      ,X_ATTRIBUTE10                  => l_attribute10
      ,X_ATTRIBUTE11                  => l_attribute11
      ,X_ATTRIBUTE12                  => l_attribute12
      ,X_ATTRIBUTE13                  => l_attribute13
      ,X_ATTRIBUTE14                  => l_attribute14
      ,X_ATTRIBUTE15                  => l_attribute15
      ,X_TASK_UNPUB_VER_STATUS_CODE   => NULL
            ,X_SOURCE_OBJECT_ID             => l_project_id
      ,X_SOURCE_OBJECT_TYPE           => 'PA_PROJECTS'
    );
    -- added for bug bug Fix: 4537865
    x_structure_version_id := l_new_structure_version_id;
    -- added for bug bug Fix: 4537865

    select element_version_id into l_dummy from pa_proj_element_versions where element_version_id = x_structure_version_id;
--    error_msg('element_version_id = '||l_dummy);
--    error_msg('rowid = '||l_rowid);
   -- Added by skannoji
   -- added for doosan customer to add the planning transaction
     IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(x_structure_version_id, 'WORKPLAN') = 'Y') THEN
        /*Smukka Bug No. 3474141 Date 03/01/2004                                                 */
        /*moved PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions into plsql block        */
        BEGIN
            PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions
              (
                p_context                => 'WORKPLAN'
               ,p_project_id             => l_project_id
               ,p_struct_elem_version_id => x_structure_version_id
               ,x_return_status          => x_return_status
               ,x_msg_count              => x_msg_count
               ,x_Msg_data               => x_msg_data
              );
         EXCEPTION
            WHEN OTHERS THEN
                 fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PVT1',
                                         p_procedure_name => 'CREATE_STRUCTURE_VERSION',
                                         p_error_text => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions:'||SQLERRM,1,240));
            RAISE FND_API.G_EXC_ERROR;
         END;
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
     -- till here by skannoji

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE_VERSION end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to CREATE_STRUC_VER_PVT;
      end if;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN NO_DATA_FOUND THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to CREATE_STRUC_VER_PVT;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to CREATE_STRUC_VER_PVT;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'CREATE_STRUCTURE_VERSION',
                              p_error_text => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END CREATE_STRUCTURE_VERSION;


-- API name                      : Create_Structure_Version_Attr
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id IN  NUMBER
--   p_structure_version_name   IN  VARCHAR2
--   p_structure_version_desc   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date   IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_latest_eff_published_flag    IN  VARCHAR2 := 'N'
--   p_published_flag   IN  VARCHAR2 := 'N'
--   p_locked_status_code   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_struct_version_status_code   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_current_flag    IN  VARCHAR2 := 'N'
--   p_baseline_original_flag   IN  VARCHAR2 := 'N'
--   x_pev_structure_id OUT NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--  21-JUN-02   HSIU             Added change_reason_code
--


  procedure Create_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_structure_version_name            IN  VARCHAR2
   ,p_structure_version_desc            IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_latest_eff_published_flag         IN  VARCHAR2 := 'N'
   ,p_published_flag                    IN  VARCHAR2 := 'N'
   ,p_locked_status_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_struct_version_status_code        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_current_flag             IN  VARCHAR2 := 'N'
   ,p_baseline_original_flag              IN  VARCHAR2 := 'N'
   ,p_change_reason_code                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,x_pev_structure_id                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS

    l_rowid              VARCHAR2(255);
    l_project_id         PA_PROJECTS_ALL.PROJECT_ID%TYPE;
    l_proj_element_id    PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(250);


    l_status_code                VARCHAR2(30) := 'STRUCTURE_WORKING';

    l_latest_eff_published_flag  VARCHAR2(1)  := 'N';
    l_published_date             DATE         := NULL;
    l_published_person_id        NUMBER;
    l_effective_date             DATE         := NULL;
    l_current_baseline_date      DATE         := NULL;
    l_cur_baseline_person_id     NUMBER;
    l_current_flag               VARCHAR2(1)  := 'N';
    l_original_baseline_date     DATE         := NULL;
    l_orig_baseline_person_id    NUMBER;
    l_original_flag              VARCHAR2(1)  := 'N';
    l_struc_ver_number           NUMBER;
    l_change_reason_code         PA_PROJ_ELEM_VER_STRUCTURE.CHANGE_REASON_CODE%TYPE;
    l_dummy                      VARCHAR2(1);
    --rtarway, 3655698
    l_structure_version_desc     VARCHAR2(2000);

    cursor get_person_id(p_user_id NUMBER) IS
    select p.person_id
      from per_all_people_f p, fnd_user f
     where f.employee_id = p.person_id
       and sysdate between p.effective_start_date and p.effective_end_date
       and f.user_id = p_user_id;

    cursor getids is select project_id, proj_element_id from pa_proj_element_versions
                     where element_version_id = p_structure_version_id;

    cursor get_published_ver_num(c_project_id NUMBER, c_proj_element_id NUMBER) IS
    select nvl(max(version_number),0)+1
      from pa_proj_elem_ver_structure
     where project_id = c_project_id
       and proj_element_id = c_proj_element_id
       and status_code = 'STRUCTURE_PUBLISHED';

    cursor get_working_ver_num(c_project_id NUMBER, c_proj_element_id NUMBER) IS
    select nvl(max(version_number),0)+1
      from pa_proj_elem_ver_structure
     where project_id = c_project_id
       and proj_element_id = c_proj_element_id
       and status_code <> 'STRUCTURE_PUBLISHED';

     CURSOR check_financial_type(c_structure_id NUMBER) IS
     select '1'
       from pa_proj_structure_types p, pa_structure_types s
      where s.structure_type_class_code IN ('FINANCIAL')
        and s.structure_type_id = p.structure_type_id
        and p.proj_element_id = c_structure_id;

     CURSOR check_working_ver_exists(c_project_id NUMBER, c_structure_id NUMBER) IS
     select '1'
       from pa_proj_elem_ver_structure
      where project_id = c_project_id
        and proj_element_id = c_structure_id
        and status_code <> 'STRUCTURE_PUBLISHED';

    l_current_working_ver_flag   VARCHAR2(1);  --FPM bug 3301192

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE_VERSION_ATTR begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_STRUC_VER_ATTR_PVT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    OPEN getids;
    FETCH getids into l_project_id, l_proj_element_id;
    IF (getids%NOTFOUND) THEN
      CLOSE getids;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE getids;


    --Check if name unique
    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Name_Unique(p_structure_version_name,
                                                                      null,
                                                                      l_project_id,
                                                                      l_proj_element_id)) THEN
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_VER_NAM_UNIQUE');
      x_msg_data := 'PA_PS_STRUC_VER_NAM_UNIQUE';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  IF (p_published_flag = 'Y' or p_struct_version_status_code =
      'STRUCTURE_PUBLISHED') THEN
      --Creating a publish structure

      --Get structure version number
      OPEN get_published_ver_num(l_project_id, l_proj_element_id);
      FETCH get_published_ver_num INTO l_struc_ver_number;
      CLOSE get_published_ver_num;

--      IF (p_published_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_published_date := sysdate;

      --get published person id
      open get_person_id(FND_GLOBAL.USER_ID);
      fetch get_person_id into l_published_person_id;
      IF get_person_id%NOTFOUND then
        l_published_person_id := -1;
      END IF;
      close get_person_id;

      l_effective_date := l_published_date;
      l_latest_eff_published_flag := 'Y';

      --set others with lastest_eff_published_flag to 'N'
      update pa_proj_elem_ver_structure
      set latest_eff_published_flag = 'N',
          record_version_number = record_version_number + 1
      where project_id = l_project_id
        and proj_element_id = l_proj_element_id
        and latest_eff_published_flag = 'Y';

      IF (p_baseline_current_flag = 'Y') THEN
        --set date, person_id, flag
        l_current_baseline_date := l_published_date;
        l_current_flag := 'Y';
        l_cur_baseline_person_id := l_published_person_id;

        --clear flags in other versions.
        update pa_proj_elem_ver_structure
        set current_flag = 'N',
            current_baseline_date = NULL,
            current_baseline_person_id = NULL,
            record_version_number = record_version_number + 1
        where project_id = l_project_id
          and proj_element_id = l_proj_element_id
          and current_flag = 'Y';


        --Call baseline_structure_version API if workplan
        IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
          PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                       p_commit => FND_API.G_FALSE,
                       p_structure_version_id => p_structure_version_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

          If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
              x_msg_data := l_msg_data;
            end if;
            raise FND_API.G_EXC_ERROR;
          end if;

        END IF;




      END IF;
      IF (p_baseline_original_flag = 'Y') THEN
        --set date, person_id, flag
        l_original_baseline_date := l_published_date;
        l_original_flag := 'Y';
        l_orig_baseline_person_id := l_published_person_id;

        --clear flags in other versions.
        update pa_proj_elem_ver_structure
        set original_flag = 'N',
            original_baseline_date = NULL,
            original_baseline_person_id = NULL,
            record_version_number = record_version_number + 1
        where project_id = l_project_id
          and proj_element_id = l_proj_element_id
          and original_flag = 'Y';

      END IF;

/*
      ELSE
        l_status_code := p_struct_version_status_code;
        l_current_flag := p_baseline_current_flag;
        l_original_flag := p_baseline_original_flag;
        l_latest_eff_published_flag := p_latest_eff_published_flag;
        l_published_date := sysdate;
        l_published_person_id := NULL;
        l_effective_date := sysdate;

        IF (l_status_code = 'STRUCTURE_PUBLISHED') THEN
          open get_person_id(FND_GLOBAL.USER_ID);
          fetch get_person_id into l_published_person_id;
          IF get_person_id%NOTFOUND then
            l_published_person_id := NULL;
          END IF;
          close get_person_id;

          --set others with lastest_eff_published_flag to 'N'
          update pa_proj_elem_ver_structure
          set latest_eff_published_flag = 'N',
              record_version_number = record_version_number + 1
          where project_id = l_project_id
            and proj_element_id = l_proj_element_id
            and latest_eff_published_flag = 'Y';

          IF (p_baseline_current_flag = 'Y') THEN
            --set date, person_id, flag
            l_current_baseline_date := l_published_date;
            l_current_flag := 'Y';
            l_cur_baseline_person_id := l_published_person_id;

            --clear flags in other versions.
            update pa_proj_elem_ver_structure
            set current_flag = 'N',
                current_baseline_date = NULL,
                current_baseline_person_id = NULL,
                record_version_number = record_version_number + 1
            where project_id = l_project_id
              and proj_element_id = l_proj_element_id
              and current_flag = 'Y';


            --Call baseline_structure_version API if workplan
            IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
              PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                       p_commit => FND_API.G_FALSE,
                       p_structure_version_id => p_structure_version_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

              If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                x_msg_count := FND_MSG_PUB.count_msg;
                if x_msg_count = 1 then
                  x_msg_data := l_msg_data;
                end if;
                raise FND_API.G_EXC_ERROR;
              end if;

            END IF;
          END IF;


        END IF;
      END IF;
*/
    ELSE
      --Creating a non-published structure

      --Check if this structure contains financial structure type
      OPEN check_financial_type(l_proj_element_id);
      FETCH check_financial_type INTO l_dummy;
      --If not found, then this is not a financial structure. Continue.
      IF check_financial_type%FOUND THEN

        --this is a financial structure. Check if there is a non published version
        OPEN check_working_ver_exists(l_project_id, l_proj_element_id);
        FETCH check_working_ver_exists into l_dummy;
        If check_working_ver_exists%FOUND THEN

          --another non-published version exists for structure with type = costing/billing.
          --Error.
          PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_ONE_WORK_VER_ALLOWED');
          x_msg_data := 'PA_PS_ONE_WORK_VER_ALLOWED';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE check_working_ver_exists;
      END IF;

    CLOSE check_financial_type;


      --Get structure version number
      OPEN get_working_ver_num(l_project_id, l_proj_element_id);
      FETCH get_working_ver_num INTO l_struc_ver_number;
      CLOSE get_working_ver_num;
      l_status_code := 'STRUCTURE_WORKING';
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_change_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_change_reason_code := NULL;
    ELSE
      l_change_reason_code := p_change_reason_code;
    END IF;


    --FPM bug 3301192
    --Find out if there is already a working version( a structure with status other PUBLISHED is a working version)?
    OPEN check_working_ver_exists(l_project_id, l_proj_element_id);
    FETCH check_working_ver_exists INTO l_current_working_ver_flag;
    IF check_working_ver_exists%FOUND
    THEN
       l_current_working_ver_flag := 'N';
    ELSE
       l_current_working_ver_flag := 'Y';
    END IF;
    CLOSE check_working_ver_exists;
    --End FPM bug 3301192

    --rtarway,3655698
    IF ( p_structure_version_desc = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
          l_structure_version_desc := null;
    ELSE
          l_structure_version_desc  :=  p_structure_version_desc;
    end if;

    PA_PROJ_ELEM_VER_STRUCTURE_PKG.insert_row(
     X_ROWID                       => l_rowid
   , X_PEV_STRUCTURE_ID            => x_pev_structure_id
   , X_ELEMENT_VERSION_ID          => p_structure_version_id
   , X_VERSION_NUMBER              => l_struc_ver_number
   , X_NAME                        => p_structure_version_name
   , X_PROJECT_ID                  => l_project_id
   , X_PROJ_ELEMENT_ID             => l_proj_element_id
   , X_DESCRIPTION                 => l_structure_version_desc  -- rtarway, 3655698
   , X_EFFECTIVE_DATE              => l_effective_date
   , X_PUBLISHED_DATE              => l_published_date
   , X_PUBLISHED_BY                => l_published_person_id
   , X_CURRENT_BASELINE_DATE       => l_current_baseline_date
   , X_CURRENT_BASELINE_FLAG       => l_current_flag
   , X_CURRENT_BASELINE_BY         => l_cur_baseline_person_id
   , X_ORIGINAL_BASELINE_DATE      => l_original_baseline_date
   , X_ORIGINAL_BASELINE_FLAG      => l_original_flag
   , X_ORIGINAL_BASELINE_BY        => l_orig_baseline_person_id
   , X_LOCK_STATUS_CODE            => NULL
   , X_LOCKED_BY                   => NULL
   , X_LOCKED_DATE                 => NULL
   , X_STATUS_CODE                 => l_status_code
   , X_WF_STATUS_CODE              => NULL
   , X_LATEST_EFF_PUBLISHED_FLAG   => l_latest_eff_published_flag
   , X_CHANGE_REASON_CODE          => l_change_reason_code
   , X_RECORD_VERSION_NUMBER       => 1
   , X_CURRENT_WORKING_FLAG        => l_current_working_ver_flag   --FPM bug 3301192
     , X_SOURCE_OBJECT_ID            => l_project_id
   , X_SOURCE_OBJECT_TYPE          => 'PA_PROJECTS'
    );

    --bug 3010538
    --set update flag to Y if weighting basis is DURATION or EFFORT
/*  --not necessary when empty
    IF (PA_PROGRESS_UTILS.GET_TASK_WEIGHTING_BASIS(l_project_id) <> 'MANUAL') THEN
      --need to set update flag to Y
      PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG(
                               p_project_id => l_project_id,
                               p_structure_version_id => p_structure_version_id,
                               p_update_wbs_flag => 'Y',
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data
                             );
      If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        x_msg_count := FND_MSG_PUB.count_msg;
        if x_msg_count = 1 then
          x_msg_data := l_msg_data;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    END IF;
*/
    --end bug 3010538

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE_VERSION_ATTR end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to CREATE_STRUC_VER_ATTR_PVT;
      end if;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN NO_DATA_FOUND THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to CREATE_STRUC_VER_ATTR_PVT;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to CREATE_STRUC_VER_ATTR_PVT;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'CREATE_STRUCTURE_VERSION_ATTR',
                              p_error_text => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END CREATE_STRUCTURE_VERSION_ATTR;


-- API name                      : Update_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id  IN  NUMBER
--   p_structure_number  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_structure_name    IN  VARCHAR2
--   p_description   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
--   p_record_version_number  IN  NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_structure_number                  IN  VARCHAR2 :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_name                    IN  VARCHAR2
   ,p_description                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute_category                IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute1                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute2                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute3                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute4                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute5                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute6                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute7                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute8                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute9                        IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute10                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute11                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute12                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute13                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute14                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_attribute15                       IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS

    l_rowid              VARCHAR2(255);
    l_project_id         PA_PROJECTS_ALL.PROJECT_ID%TYPE;
    l_proj_element_id    PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(250);


    l_element_number     PA_PROJ_ELEMENTS.element_number%TYPE;
    l_name               PA_PROJ_ELEMENTS.name%TYPE;
    l_description        PA_PROJ_ELEMENTS.description%TYPE;
    l_attribute_category VARCHAR2(30);
    l_attribute1         VARCHAR2(150);
    l_attribute2         VARCHAR2(150);
    l_attribute3         VARCHAR2(150);
    l_attribute4         VARCHAR2(150);
    l_attribute5         VARCHAR2(150);
    l_attribute6         VARCHAR2(150);
    l_attribute7         VARCHAR2(150);
    l_attribute8         VARCHAR2(150);
    l_attribute9         VARCHAR2(150);
    l_attribute10        VARCHAR2(150);
    l_attribute11        VARCHAR2(150);
    l_attribute12        VARCHAR2(150);
    l_attribute13        VARCHAR2(150);
    l_attribute14        VARCHAR2(150);
    l_attribute15        VARCHAR2(150);


    CURSOR get_struc IS
      select rowid,
             project_id,
             element_number,
             name,
             description,
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
             attribute15
        from pa_proj_elements
       where proj_element_id = p_structure_id;
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) then
      savepoint update_structure_pvt;
    END IF;

    --Get existing values.
    OPEN get_struc;
    FETCH get_struc into l_rowid,
                         l_project_id,
                         l_element_number,
                         l_name,
                         l_description,
                         l_attribute_category,
                         l_attribute1,
                         l_attribute2,
                         l_attribute3,
                         l_attribute4,
                         l_attribute5,
                         l_attribute6,
                         l_attribute7,
                         l_attribute8,
                         l_attribute9,
                         l_attribute10,
                         l_attribute11,
                         l_attribute12,
                         l_attribute13,
                         l_attribute14,
                         l_attribute15;
    IF (get_struc%NOTFOUND) THEN
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_NOT_EXIST');
      x_msg_data := 'PA_PS_STRUC_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_struc;


    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('l_name = '||l_name);
      pa_debug.debug('p_structure_name = '||p_structure_name);
    END IF;

    --Check if structure name is unique, if changed.
    IF (l_name <> p_structure_name) then
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('different!!');
      END IF;
      IF ('Y' <> pa_project_structure_utils.Check_Structure_Name_Unique(p_structure_name,
                                               p_structure_id,
                                               l_project_id)) THEN
        --name not unique.
        PA_UTILS.ADD_MESSAGE('PA', 'PS_STRUC_NAME_UNIQUE');
        x_msg_data := 'PA_PS_STRUC_NAME_UNIQUE';
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        l_name := p_structure_name;
      END IF;
    END IF;

    --Replace values, if entered.
    IF (p_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_description IS NULL) THEN
      l_description := p_description;
    END IF;
    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute_category IS NULL) THEN
      l_attribute_category := p_attribute_category;
    END IF;
    IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute1 IS NULL) THEN
      l_attribute1 := p_attribute1;
    END IF;
    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute2 IS NULL) THEN
      l_attribute2 := p_attribute2;
    END IF;
    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute3 IS NULL) THEN
      l_attribute3 := p_attribute3;
    END IF;
    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute4 IS NULL) THEN
      l_attribute4 := p_attribute4;
    END IF;
    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute5 IS NULL) THEN
      l_attribute5 := p_attribute5;
    END IF;
    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute6 IS NULL) THEN
      l_attribute6 := p_attribute6;
    END IF;
    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute7 IS NULL) THEN
      l_attribute7 := p_attribute7;
    END IF;
    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute8 IS NULL) THEN
      l_attribute8 := p_attribute8;
    END IF;
    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute9 IS NULL) THEN
      l_attribute9 := p_attribute9;
    END IF;
    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute10 IS NULL) THEN
      l_attribute10 := p_attribute10;
    END IF;
    IF (p_attribute11 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute11 IS NULL) THEN
      l_attribute11 := p_attribute11;
    END IF;
    IF (p_attribute12 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute12 IS NULL) THEN
      l_attribute12 := p_attribute12;
    END IF;
    IF (p_attribute13 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute13 IS NULL) THEN
      l_attribute13 := p_attribute13;
    END IF;
    IF (p_attribute14 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute14 IS NULL) THEN
      l_attribute14 := p_attribute14;
    END IF;
    IF (p_attribute15 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute15 IS NULL) THEN
      l_attribute15 := p_attribute15;
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJ_ELEMENTS_PKG.UPDATE_ROW(
       X_ROW_ID                  => l_rowid
      ,X_PROJ_ELEMENT_ID         => p_structure_id
      ,X_PROJECT_ID              => l_project_id
      ,X_OBJECT_TYPE             => 'PA_STRUCTURES'
      ,X_ELEMENT_NUMBER          => to_char(p_structure_id)
      ,X_NAME                    => l_name
      ,X_DESCRIPTION             => l_description
      ,X_STATUS_CODE             => NULL
      ,X_WF_STATUS_CODE          => NULL
      ,X_PM_PRODUCT_CODE         => NULL
      ,X_PM_TASK_REFERENCE       => NULL
      ,X_CLOSED_DATE             => NULL
      ,X_LOCATION_ID             => NULL
      ,X_MANAGER_PERSON_ID       => NULL
      ,X_CARRYING_OUT_ORGANIZATION_ID => NULL
      ,X_TYPE_ID                 => NULL
      ,X_PRIORITY_CODE           => NULL
      ,X_INC_PROJ_PROGRESS_FLAG  => NULL
      ,X_RECORD_VERSION_NUMBER   => p_record_version_number
      ,X_REQUEST_ID              => NULL
      ,X_PROGRAM_APPLICATION_ID  => NULL
      ,X_PROGRAM_ID              => NULL
      ,X_PROGRAM_UPDATE_DATE     => NULL
      ,X_ATTRIBUTE_CATEGORY      => l_attribute_category
      ,X_ATTRIBUTE1              => l_attribute1
      ,X_ATTRIBUTE2              => l_attribute2
      ,X_ATTRIBUTE3              => l_attribute3
      ,X_ATTRIBUTE4              => l_attribute4
      ,X_ATTRIBUTE5              => l_attribute5
      ,X_ATTRIBUTE6              => l_attribute6
      ,X_ATTRIBUTE7              => l_attribute7
      ,X_ATTRIBUTE8              => l_attribute8
      ,X_ATTRIBUTE9              => l_attribute9
      ,X_ATTRIBUTE10             => l_attribute10
      ,X_ATTRIBUTE11             => l_attribute11
      ,X_ATTRIBUTE12             => l_attribute12
      ,X_ATTRIBUTE13             => l_attribute13
      ,X_ATTRIBUTE14             => l_attribute14
      ,X_ATTRIBUTE15             => l_attribute15
      ,X_TASK_WEIGHTING_DERIV_CODE => NULL
      ,X_WORK_ITEM_CODE            => NULL
      ,X_UOM_CODE                  => NULL
      ,X_WQ_ACTUAL_ENTRY_CODE      => NULL
      ,X_TASK_PROGRESS_ENTRY_PAGE_ID => NULL
      ,X_PARENT_STRUCTURE_ID         => NULL
      ,X_PHASE_CODE                  => NULL
      ,X_PHASE_VERSION_ID            => NULL
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_STRUCTURE end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when others then
      if p_commit = FND_API.G_TRUE then
         rollback to update_structure_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'UPDATE_STRUCTURE',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END update_structure;



-- API name                      : Update_Structure_Version_Attr
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pev_structure_id       IN    NUMBER
--   p_structure_version_name   IN  VARCHAR2
--   p_structure_version_desc   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date   IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_latest_eff_published_flag    IN  VARCHAR2 := 'N'
--   p_locked_status_code   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_struct_version_status_code   IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_baseline_current_flag    IN  VARCHAR2 := 'N'
--   p_baseline_original_flag   IN  VARCHAR2 := 'N'
--   p_record_version_number  IN    NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--  21-JUN-02   HSIU             Added change_reason_code
--


  procedure Update_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_pev_structure_id        IN    NUMBER
   ,p_structure_version_name    IN  VARCHAR2
   ,p_structure_version_desc    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date    IN  DATE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_latest_eff_published_flag IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_locked_status_code    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_struct_version_status_code    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_current_flag IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_baseline_original_flag    IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_change_reason_code        IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_record_version_number  IN    NUMBER
    --FP M changes bug 3301192
   ,p_current_working_ver_flag          IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --end FP M changes bug 3301192
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS

    l_rowid                        VARCHAR2(255);
    l_structure_version_id         PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE;
    l_project_id                   PA_PROJ_ELEM_VER_STRUCTURE.PROJECT_ID%TYPE;
    l_proj_element_id              PA_PROJ_ELEM_VER_STRUCTURE.PROJ_ELEMENT_ID%TYPE;
    l_version_number               PA_PROJ_ELEM_VER_STRUCTURE.VERSION_NUMBER%TYPE;
    l_name                         PA_PROJ_ELEM_VER_STRUCTURE.NAME%TYPE;
    l_description                  PA_PROJ_ELEM_VER_STRUCTURE.DESCRIPTION%TYPE;
    l_effective_date               PA_PROJ_ELEM_VER_STRUCTURE.effective_date%TYPE;
    l_published_date               PA_PROJ_ELEM_VER_STRUCTURE.published_date%TYPE;
    l_published_by_person_id       PA_PROJ_ELEM_VER_STRUCTURE.published_by_person_id%TYPE;
    l_current_baseline_date        PA_PROJ_ELEM_VER_STRUCTURE.current_baseline_date%TYPE;
    l_current_flag                 PA_PROJ_ELEM_VER_STRUCTURE.current_flag%TYPE;
    l_current_baseline_person_id   PA_PROJ_ELEM_VER_STRUCTURE.current_baseline_person_id%TYPE;
    l_original_baseline_date       PA_PROJ_ELEM_VER_STRUCTURE.original_baseline_date%TYPE;
    l_original_flag                PA_PROJ_ELEM_VER_STRUCTURE.original_flag%TYPE;
    l_original_baseline_person_id  PA_PROJ_ELEM_VER_STRUCTURE.original_baseline_person_id%TYPE;
    l_lock_status_code             PA_PROJ_ELEM_VER_STRUCTURE.lock_status_code%TYPE;
    l_locked_by_person_id          PA_PROJ_ELEM_VER_STRUCTURE.locked_by_person_id%TYPE;
    l_locked_date                  PA_PROJ_ELEM_VER_STRUCTURE.locked_date%TYPE;
    l_status_code                  PA_PROJ_ELEM_VER_STRUCTURE.status_code%TYPE;
    l_wf_status_code               PA_PROJ_ELEM_VER_STRUCTURE.wf_status_code%TYPE;
    l_latest_eff_published_flag    PA_PROJ_ELEM_VER_STRUCTURE.latest_eff_published_flag%TYPE;
    l_pm_source_code               PA_PROJ_ELEM_VER_STRUCTURE.pm_source_code%TYPE;
    l_pm_source_reference          PA_PROJ_ELEM_VER_STRUCTURE.pm_source_reference%TYPE;
    l_change_reason_code           VARCHAR2(30);


    l_return_status                VARCHAR2(1);
    l_msg_count                    NUMBER;
    l_msg_count_int                NUMBER; /*bug# 6414944*/
    l_msg_data                     VARCHAR2(250);
    l_get_lock                     VARCHAR2(1);
    l_person_id                    NUMBER;

    cursor get_person_id(p_user_id NUMBER) IS
    select p.person_id
      from per_all_people_f p, fnd_user f
     where f.employee_id = p.person_id
       and sysdate between p.effective_start_date and p.effective_end_date
       and f.user_id = p_user_id;


    cursor getids is select rowid,
                            element_version_id,
                            version_number,
                            name,
                            project_id,
                            proj_element_id,
                            description,
                            effective_date,
                            published_date,
                            published_by_person_id,
                            CURRENT_BASELINE_DATE,
                            CURRENT_FLAG,
                            CURRENT_BASELINE_PERSON_ID,
                            ORIGINAL_BASELINE_DATE,
                            ORIGINAL_FLAG,
                            ORIGINAL_BASELINE_PERSON_ID,
                            LOCK_STATUS_CODE,
                            LOCKED_BY_PERSON_ID,
                            LOCKED_DATE,
                            STATUS_CODE,
                            WF_STATUS_CODE,
                            LATEST_EFF_PUBLISHED_FLAG,
                            PM_SOURCE_CODE,
                            PM_SOURCE_REFERENCE,
                            CHANGE_REASON_CODE,
                            CURRENT_WORKING_FLAG
                       from pa_proj_elem_ver_structure
                     where pev_structure_id = p_pev_structure_id;

  l_current_working_ver_flag  VARCHAR2(1);    --FPM bug 3301192

    -- Begin Fix For Bug # 4297556.

        cursor cur_relationship_ids(c_structure_version_id NUMBER, c_project_id NUMBER)
    is select por.object_relationship_id, por.record_version_number
    , por2.object_id_from1, por.object_id_from2, por.comments, ppa.name -- Bug # 4556844.
    from pa_object_relationships por, pa_proj_element_versions ppev, pa_proj_elem_ver_structure ppevs
    , pa_projects_all ppa, pa_object_relationships por2 -- Bug # 4556844.
    where ppevs.element_version_id = ppev.parent_structure_version_id
    and ppevs.project_id = ppev.project_id
    and ppev.element_version_id = por.object_id_to1
    and ppev.project_id = por.object_id_to2
    and ppa.project_id = ppev.project_id -- Bug # 4556844.
    and por.relationship_type = 'LW'
    and ppevs.element_version_id <> c_structure_version_id
    and ppevs.project_id = c_project_id
    and ppevs.status_code = 'STRUCTURE_WORKING'
    and por2.object_id_to1 = por.object_id_from1 -- Bug # 4556844.
    and por2.object_type_from in ('PA_STRUCTURES','PA_TASKS') --Bug 6429275
    and por2.object_type_to = 'PA_TASKS' -- Bug 6429275
    and por2.relationship_type = 'S'; -- Bug # 4556844.


    cur_rel_ids_rec cur_relationship_ids%rowtype;

    -- End Fix For Bug # 4297556.

  BEGIN
    l_msg_count_int := FND_MSG_PUB.count_msg; /*Bug#6414944*/
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_STRUCTURE_VERSION_ATTR begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_STRUC_VER_ATTR_PVT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    OPEN getids;
    FETCH getids into l_rowid,
                      l_structure_version_id,
                      l_version_number,
                      l_name,
                      l_project_id,
                      l_proj_element_id,
                      l_description,
                      l_effective_date,
                      l_published_date,
                      l_published_by_person_id,
                      l_current_baseline_date,
                      l_current_flag,
                      l_current_baseline_person_id,
                      l_original_baseline_date,
                      l_original_flag,
                      l_original_baseline_person_id,
                      l_lock_status_code,
                      l_locked_by_person_id,
                      l_locked_date,
                      l_status_code,
                      l_wf_status_code,
                      l_latest_eff_published_flag,
                      l_pm_source_code,
                      l_pm_source_reference,
                      l_change_reason_code,
                      l_current_working_ver_flag;

    IF (getids%NOTFOUND) THEN
      CLOSE getids;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE getids;

    --get person id
    open get_person_id(FND_GLOBAL.USER_ID);
    fetch get_person_id into l_person_id;
    IF get_person_id%NOTFOUND then
      l_person_id := -1;
    END IF;
    close get_person_id;

   IF p_calling_module <> 'PA_UPD_WBS_ATTR' AND p_calling_module <> 'PA_UPD_WBS_ATTR_UN'/*bug# 4582750 ,Bug#6414944*/
   THEN
    --bug 3940853
        DECLARE
          l_rowid  VARCHAR2(255);
        BEGIN
        select rowid into l_rowid
          from pa_proj_elem_ver_structure
         where pev_structure_id = p_pev_structure_id
           and record_version_number = p_record_version_number
           for update NOWAIT;
        EXCEPTION
          when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            if SQLCODE = -54 then
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
              raise;
            end if;
        END;

        x_msg_count := FND_MSG_PUB.count_msg;
        if x_msg_count > 0 then
          x_msg_data := l_msg_data;
          raise FND_API.G_EXC_ERROR;
        end if;
    --end bug 3940853
   END IF;  --p_calling_module <> 'PA_UPD_WBS_ATTR'

    --Check if published
--hsiu
--changed for versioning
--    IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(l_project_id,
--                                                         l_structure_version_id)) THEN
    IF ('N' = PA_PROJECT_STRUCTURE_UTILS.check_edit_wp_ok(l_project_id,
                                                          l_structure_version_id)) THEN
      --If published
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Published');
      END IF;

      --if set current baseline flag
      IF (p_baseline_current_flag = 'Y') THEN
        l_current_flag := 'Y';
        l_current_baseline_date := sysdate;
        l_current_baseline_person_id := l_person_id;

        --clear other flags
        update pa_proj_elem_ver_structure
        set current_flag = 'N',
            current_baseline_date = NULL,
            current_baseline_person_id = NULL,
            record_version_number = record_version_number + 1
        where project_id = l_project_id
          and proj_element_id = l_proj_element_id
          and pev_structure_id <> p_pev_structure_id
          and current_flag = 'Y';

        --Call baseline_structure_version API if workplan
        IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_structure_version_id, 'WORKPLAN') = 'Y') THEN
          PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                       p_commit => FND_API.G_FALSE,
                       p_structure_version_id => l_structure_version_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

          If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
              x_msg_data := l_msg_data;
            end if;
            raise FND_API.G_EXC_ERROR;
          end if;

        END IF;

      END IF;

      --if set original baseline flag
      IF (p_baseline_original_flag = 'Y') THEN
        l_original_flag := 'Y';
        l_original_baseline_date := sysdate;
        l_original_baseline_person_id := l_person_id;

        --clear other flags.
        update pa_proj_elem_ver_structure
        set original_flag = 'N',
            original_baseline_date = NULL,
            original_baseline_person_id = NULL,
            record_version_number = record_version_number + 1
        where project_id = l_project_id
          and proj_element_id = l_proj_element_id
          and pev_structure_id <> p_pev_structure_id
          and original_flag = 'Y';

      END IF;
    END IF;
--hsiu
--changed for versioning
--    ELSE
    IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.check_edit_wp_ok(l_project_id,
                                                          l_structure_version_id)) THEN
      --If not published
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Not Published');
      END IF;

      --Check lock
      l_get_lock := PA_PROJECT_STRUCTURE_UTILS.IS_STRUC_VER_LOCKED_BY_USER(FND_GLOBAL.USER_ID,
                                                             l_structure_version_id);

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('l_get_lock value = '||l_get_lock);
      END IF;

      --bug 3071008
      IF (l_get_lock <> 'Y') THEN
        IF (PA_SECURITY_PVT.check_user_privilege('PA_UNLOCK_ANY_STRUCTURE'
                                             ,NULL
                                             ,to_number(NULL))
           = FND_API.G_TRUE) THEN
          l_get_lock := 'Y';
        END IF;
      END IF;
      --end bug 3071008

      IF (l_get_lock = 'O') THEN
        --lock by other user. Error.
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_STRUC_VER_LOCKED');
        x_msg_data := 'PA_PS_STRUC_VER_LOCKED';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_locked_status_code = 'LOCKED') THEN
        l_lock_status_code := 'LOCKED';
        l_locked_by_person_id := l_person_id;
        l_locked_date := sysdate;
      ELSIF (p_locked_status_code = 'UNLOCKED') THEN
        l_lock_status_code := 'UNLOCKED';
        l_locked_by_person_id := null;
        l_locked_date := null;
      END IF;

      --Check if structure version name is unique if modified
      IF (p_structure_version_name <> l_name) THEN
        IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Name_Unique(p_structure_version_name,
                                               p_pev_structure_id,
                                               l_project_id,
                                               l_proj_element_id)) THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_VER_NAM_UNIQUE');
          x_msg_data := 'PA_PS_STRUC_VER_NAM_UNIQUE';
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_name := p_structure_version_name;
        END IF;
      END IF;

    END IF;

    --other attributes
    If (p_struct_version_status_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   OR
        p_struct_version_status_code IS NULL) THEN
      l_status_code := p_struct_version_status_code;
    END IF;
    IF (p_structure_version_desc <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_structure_version_desc IS NULL) THEN
      l_description := p_structure_version_desc;
    END IF;

    IF (p_change_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_change_reason_code IS NULL) THEN
      l_change_reason_code := p_change_reason_code;
    END IF;

    --FPM bug 3301192
    IF (p_current_working_ver_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_current_working_ver_flag IS NULL) THEN
      NULL;
    ELSE
      l_current_working_ver_flag := p_current_working_ver_flag;
    END IF;
    --end FPM bug 3301192

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
--    IF p_calling_module = 'PA_UPD_WBS_ATTR_UN' THEN   Commented for Bug 6372780
      IF l_msg_count > l_msg_count_int THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;/*Bug# 6414944*/
/* Commented for Bug 6372780
    ELSIF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

    PA_PROJ_ELEM_VER_STRUCTURE_PKG.update_row(
     X_ROWID                      => l_rowid
   , X_PEV_STRUCTURE_ID           => p_pev_structure_id
   , X_ELEMENT_VERSION_ID         => l_structure_version_id
   , X_VERSION_NUMBER             => l_version_number
   , X_NAME                       => l_name
   , X_PROJECT_ID                 => l_project_id
   , X_PROJ_ELEMENT_ID            => l_proj_element_id
   , X_DESCRIPTION                => l_description
   , X_EFFECTIVE_DATE             => l_effective_date
   , X_PUBLISHED_DATE             => l_published_date
   , X_PUBLISHED_BY               => l_published_by_person_id
   , X_CURRENT_BASELINE_DATE      => l_current_baseline_date
   , X_CURRENT_BASELINE_FLAG      => l_current_flag
   , X_CURRENT_BASELINE_BY        => l_current_baseline_person_id
   , X_ORIGINAL_BASELINE_DATE     => l_original_baseline_date
   , X_ORIGINAL_BASELINE_FLAG     => l_original_flag
   , X_ORIGINAL_BASELINE_BY       => l_original_baseline_person_id
   , X_LOCK_STATUS_CODE           => l_lock_status_code
   , X_LOCKED_BY                  => l_locked_by_person_id
   , X_LOCKED_DATE                => l_locked_date
   , X_STATUS_CODE                => l_status_code
   , X_WF_STATUS_CODE             => l_wf_status_code
   , X_LATEST_EFF_PUBLISHED_FLAG  => l_latest_eff_published_flag
   , X_CHANGE_REASON_CODE         => l_change_reason_code
   , X_RECORD_VERSION_NUMBER      => p_record_version_number
   , X_CURRENT_WORKING_FLAG       => l_current_working_ver_flag    --FPM bug 3301192
    );


    --FPM bug 3301192
    --now set the current working flag for the other working versions to 'N'
    IF l_current_working_ver_flag = 'Y'
    THEN
        UPDATE pa_proj_elem_ver_structure
           SET current_working_flag = 'N'
        where project_id = l_project_id
          and proj_element_id = l_proj_element_id
          and pev_structure_id <> p_pev_structure_id
          and current_working_flag = 'Y';

        -- Begin Fix For Bug # 4297556.

        -- For a split structure, we delete all subproject relationships where any of the other working
    -- workplan versions is the child entity.

        for l_cur_rel_ids_rec in cur_relationship_ids(l_structure_version_id, l_project_id)

        loop

                        PA_RELATIONSHIP_PVT.Delete_SubProject_Association(
                                 p_commit                  =>  p_commit
                                ,p_validate_only           =>  p_validate_only
                                ,p_debug_mode              =>  p_debug_mode
                                ,p_object_relationships_id =>  l_cur_rel_ids_rec.object_relationship_id
                                ,p_record_version_number   =>  l_cur_rel_ids_rec.record_version_number
                                ,x_return_status           =>  x_return_status
                                ,x_msg_count               =>  x_msg_count
                                ,x_msg_data                =>  x_msg_data);

            if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then

                    raise FND_API.G_EXC_ERROR;

                end if;

            -- Begin Bug # 4556844.

                        PA_RELATIONSHIP_PVT.Create_SubProject_Association(
                                 p_commit                  =>  p_commit
                                ,p_validate_only           =>  p_validate_only
                                ,p_debug_mode              =>  p_debug_mode
                                ,p_src_proj_id         =>  l_cur_rel_ids_rec.object_id_from2
                                ,p_task_ver_id         =>  l_cur_rel_ids_rec.object_id_from1
                                ,p_dest_proj_id        =>  l_project_id
                                ,p_dest_proj_name      =>  l_cur_rel_ids_rec.name
                                ,p_comment             =>  l_cur_rel_ids_rec.comments
                                ,x_return_status           =>  x_return_status
                                ,x_msg_count               =>  x_msg_count
                                ,x_msg_data                =>  x_msg_data);

                        if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then

                                raise FND_API.G_EXC_ERROR;

                        end if;

            -- End Bug # 4556844.

        end loop;

        -- End Fix For Bug # 4297556.

    END IF;
    --end FPM bug 3301192

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_STRUCTURE_VERSION_ATTR end');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      if p_commit = FND_API.G_TRUE THEN
        rollback to UPDATE_STRUC_VER_ATTR_PVT;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_STRUC_VER_ATTR_PVT;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_STRUC_VER_ATTR_PVT;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Update_Structure_Version_Attr',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END Update_Structure_Version_Attr;



-- API name                      : Delete_Structure
-- Type                           : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_id                      IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_id                      IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_rowid  VARCHAR2(255);

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);

    cursor sel_struct_type IS
      select rowid
        from pa_proj_structure_types
       where proj_element_id = p_structure_id;

    -- Begin fix for Bug # 4506308.

    cursor l_cur_projects_all(c_structure_id NUMBER) is
    select ppa.project_id, ppa.record_version_number
    from pa_projects_all ppa, pa_proj_elements ppe
    where ppa.project_id = ppe.project_id
    and ppe.proj_element_id = c_structure_id;

    l_project_id     NUMBER;
    l_rec_ver_number NUMBER;
    l_is_wp_str      VARCHAR2(1);

    -- End fix for Bug # 4506308.

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE begin');
    END IF;

    if p_commit = FND_API.G_TRUE then
       savepoint delete_structure_pvt;
    end if;

    -- Begin fix for Bug # 4506308.

    l_is_wp_str := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(p_structure_id, 'WORKPLAN');

    if (l_is_wp_str = 'Y') then

        open l_cur_projects_all(p_structure_id);
        fetch l_cur_projects_all into l_project_id, l_rec_ver_number;
        close l_cur_projects_all;

        PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
        p_validate_only          => FND_API.G_FALSE
        ,p_project_id             => l_project_id
        ,p_date_type              => 'SCHEDULED'
        ,p_start_date             => null
        ,p_finish_date            => null
        ,p_record_version_number  => l_rec_ver_number
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    end if;

    -- End fix for Bug # 4506308.

    --Delete detail rows (structure types)
    OPEN sel_struct_type;
    LOOP
      FETCH sel_struct_type into l_rowid;
      EXIT WHEN sel_struct_type%NOTFOUND;
      PA_PROJ_STRUCTURE_TYPES_PKG.delete_row(l_rowid);
    END LOOP;
    CLOSE sel_struct_type;

    --Lock record
    IF (p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        --lock
        select rowid into l_rowid
          from pa_proj_elements
         where proj_element_id = p_structure_id
           and record_version_number = p_record_version_number
           for update of record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            if SQLCODE = -54 then
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
              raise;
            end if;
      END;
    ELSE
      BEGIN
        select rowid into l_rowid
          from pa_proj_elements
         where proj_element_id = p_structure_id
           and record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            raise;
      END;
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;


    PA_PROJ_ELEMENTS_PKG.DELETE_ROW(
      X_ROW_ID => l_rowid
    );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE end');
    END IF;

  EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Delete_Structure',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Delete_Structure;


-- API name                      : Delete_Structure_Version
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Structure_Version
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_rowid  VARCHAR2(255);

    l_Project_ID    NUMBER;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);

-- Begin fix for Bug # 4483222.

cursor l_cur_rel_id(p_str_ver_id NUMBER) is
select por.object_relationship_id, por.record_version_number
from pa_object_relationships por
where por.object_id_to1 = p_str_ver_id
and por.relationship_type in ('LW', 'LF');

l_rec_rel_id l_cur_rel_id%ROWTYPE;

-- End fix for Bug # 4483222.

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE_VERSION begin');
    END IF;

    if p_commit = FND_API.G_TRUE then
       savepoint delete_structure_version_pvt;
    end if;

    --Lock record
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('locking record '||p_structure_version_id||', '||p_record_Version_number);
    END IF;
    IF (p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        --lock
        select rowid into l_rowid
          from pa_proj_element_versions
         where element_version_id = p_structure_version_id
           and record_version_number = p_record_version_number
           for update of record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            if SQLCODE = -54 then
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
              raise;
            end if;
      END;
    ELSE
      BEGIN
        select rowid into l_rowid
          from pa_proj_element_versions
         where element_version_id = p_structure_version_id
           and record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            raise;
      END;
    END IF;


    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('deleting structure versionn');
    END IF;


    -- Added by skannoji
    -- Added for doosan customer to delete structure version id for workplan
    DECLARE
      /* Bug #: 3305199 SMukka                                                         */
      /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
      /* l_struct_version_id_tbl     PA_PLSQL_DATATYPES.IdTabTyp;                      */
      l_struct_version_id_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
    BEGIN
     IF ( PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
       l_struct_version_id_tbl.extend(1); /* Venky */
       l_struct_version_id_tbl(1) := p_structure_version_id;
       /*Smukka Bug No. 3474141 Date 03/01/2004                                  */
       /*moved PA_FIN_PLAN_PVT.delete_wp_budget_versions into plsql block        */
       BEGIN
           PA_FIN_PLAN_PVT.delete_wp_budget_versions
                  (
                     p_struct_elem_version_id_tbl    => l_struct_version_id_tbl
                    ,x_return_status                 => x_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_Msg_data                      => x_msg_data
                    );
       EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                        p_procedure_name => 'Delete_Structure_Version',
                                        p_error_text     => SUBSTRB('PA_FIN_PLAN_PVT.delete_wp_budget_versions:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END;
       -- Added for FP_M Changes -- Bhumesh
       BEGIN
           SELECT project_id INTO l_Project_ID
       FROM   pa_proj_element_versions
           WHERE  element_version_id = p_structure_version_id and rownum < 2;

           PA_PROGRESS_PUB.delete_working_wp_progress (
             P_Project_ID       => l_Project_ID
                    ,P_Structure_Version_ID     => P_Structure_Version_ID
                    ,x_return_status        => x_return_status
                    ,x_msg_count            => x_msg_count
                    ,x_Msg_data             => x_msg_data
                    );
       EXCEPTION
           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(
            p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                    p_procedure_name => 'Delete_Structure_Version',
                    p_error_text     => SUBSTRB('PA_PROGRESS_PUB.delete_working_wp_progress:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END;
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
    END;
    -- till here by skannoji

-- Begin fix for Bug # 4483222.

-- delete all sub-project relationships where this structure is the child of another structure.

  for l_rec_rel_id in l_cur_rel_id(p_structure_version_id)
  loop

    /*

        pa_relationship_pub.delete_relationship
        (p_api_version                        => p_api_version
         ,p_init_msg_list                     => p_init_msg_list
         ,p_commit                            => p_commit
         ,p_validate_only                     => p_validate_only
         ,p_validation_level                  => p_validation_level
         ,p_calling_module                    => p_calling_module
         ,p_debug_mode                        => p_debug_mode
         ,p_max_msg_count                     => p_max_msg_count
         ,p_object_relationship_id            => l_rec_rel_id.object_relationship_id
         ,p_record_version_number             => l_rec_rel_id.record_version_number
         ,x_return_status                     => x_return_status
         ,x_msg_count                         => x_msg_count
         ,x_msg_data                          => x_msg_data);

    */

    pa_relationship_pvt.delete_subproject_association
        (p_commit                   =>  p_commit
         ,p_validate_only           =>  p_validate_only
         ,p_debug_mode              =>  p_debug_mode
         ,p_object_relationships_id =>  l_rec_rel_id.object_relationship_id
         ,p_record_version_number   =>  l_rec_rel_id.record_version_number
         ,x_return_status           =>  x_return_status
         ,x_msg_count               =>  x_msg_count
         ,x_msg_data                =>  x_msg_data);

         if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then

            raise FND_API.G_EXC_ERROR;

         end if;

  end loop;

-- End fix for Bug # 4483222.

    PA_PROJ_ELEMENT_VERSIONS_PKG.DELETE_ROW(
      X_ROW_ID => l_rowid
    );

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE_VERSION end');
    END IF;

  EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_version_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_version_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Delete_Structure_Version',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END DELETE_STRUCTURE_VERSION;


-- API name                      : Delete_Structure_Version_Attr
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pev_structure_id                  IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Structure_Version_Attr
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_pev_structure_id                  IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_rowid                         VARCHAR2(255);

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);

    --FP M bug 3301192
    CURSOR cur_proj_str
    IS
      SELECT proj_element_id, project_id
        FROM pa_proj_elem_ver_structure
       WHERE pev_structure_id = p_pev_structure_id;

    l_structure_id               NUMBER;
    l_project_id                 NUMBER;
    l_current_working_ver_id     NUMBER;

    --end FPM bug 3301192

    -- 3804437 Added below cursor to retrieve last updated working version
    CURSOR cur_last_working_ver( p_structure_id NUMBER )
    IS
      select str.element_version_id
        from pa_proj_elem_ver_structure str,
              pa_proj_elements ppe
        where ppe.proj_element_id = p_structure_id
          and ppe.project_id = str.project_id
          and ppe.proj_element_id = str.proj_element_id
          and str.status_code = 'STRUCTURE_WORKING'
          and str.current_working_flag = 'N'
          order by str.last_update_date desc;
    -- 3804437

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE_VERSION_ATTR begin');
    END IF;

    if p_commit = FND_API.G_TRUE then
       savepoint delete_structure_ver_attr_pvt;
    end if;

    --Lock record
    IF (p_validate_only <> FND_API.G_TRUE) THEN
      BEGIN
        --lock
        select rowid into l_rowid
          from pa_proj_elem_ver_structure
         where pev_structure_id = p_pev_structure_id
           and record_version_number = p_record_version_number
           for update of record_version_number NOWAIT;
      EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            if SQLCODE = -54 then
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
              raise;
            end if;
      END;
    ELSE
      BEGIN
        select rowid into l_rowid
          from pa_proj_elem_ver_structure
         where pev_structure_id = p_pev_structure_id
           and record_version_number = p_record_version_number;
      EXCEPTION
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            raise;
      END;
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    --FPM bug 3301192
    OPEN cur_proj_str;
    FETCH cur_proj_str INTO l_structure_id, l_project_id;
    CLOSE cur_proj_str;

    -- 3804437 Commented below code to retrieve last updated working version
    -- because below code is retrieving the current working version only

    --l_current_working_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(l_structure_id);

    -- Added code to retrieve last updated working version

    OPEN cur_last_working_ver(l_structure_id);
    FETCH cur_last_working_ver INTO l_current_working_ver_id;
    CLOSE cur_last_working_ver;

    -- 3804437 end

    --update the latest updated working version as current working version.
      UPDATE pa_proj_elem_ver_structure
         SET current_working_flag = 'Y'
       WHERE element_version_id = l_current_working_ver_id
         AND project_id = l_project_id;

    --end FPM bug 3301192

    /* Added for bug 8708651 */
    if PJI_PA_DEL_MAIN.g_from_conc is null then
    PA_PROJ_ELEM_VER_STRUCTURE_PKG.delete_row(
      X_ROWID => l_rowid
    );
    else
        update PA_PROJ_ELEM_VER_STRUCTURE
        set PURGED_FLAG = 'Y',
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.USER_ID,
            conc_request_id = FND_GLOBAL.CONC_REQUEST_ID /* Added for bug 9049425 */
        WHERE ROWID = l_rowid;
    end if;
    /* Added for bug 8708651 */

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUCTURE_VERSION_ATTR end');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
   when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_ver_attr_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_structure_ver_attr_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Delete_Structure',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Delete_Structure_Version_Attr;


-- API name                      : Publish_Structure
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_responsibility_id                 IN  NUMBER      := 0
--   p_structure_version_id              IN  NUMBER
--   p_publish_structure_ver_name        IN  VARCHAR2
--   p_structure_ver_desc                IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_original_baseline_flag            IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_current_baseline_flag             IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_published_struct_ver_id           OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--



  procedure Publish_Structure
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_responsibility_id                 IN  NUMBER      := 0
   ,p_user_id                           IN  NUMBER      := NULL
   ,p_structure_version_id              IN  NUMBER
   ,p_publish_structure_ver_name        IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_structure_ver_desc                IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_effective_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   ,p_original_baseline_flag            IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_current_baseline_flag             IN  VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_pub_prog_flag             IN  VARCHAR2    DEFAULT 'Y'  -- FP_M changes
   ,x_published_struct_ver_id           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'Publish_Structure';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_apps_name                     VARCHAR2(2000) := 'PA';

    l_dummy                         VARCHAR2(1);
    l_dummy_name                    PA_PROJ_ELEM_VER_STRUCTURE.NAME%TYPE;

    l_project_id                    PA_PROJ_ELEM_VER_STRUCTURE.PROJECT_ID%TYPE;
    l_proj_element_id               PA_PROJ_ELEM_VER_STRUCTURE.PROJ_ELEMENT_ID%TYPE;
    l_element_version_id            PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE;
    l_pev_structure_id              PA_PROJ_ELEM_VER_STRUCTURE.PEV_STRUCTURE_ID%TYPE;


    l_new_struct_ver_id             NUMBER;
    -- added for Bug Fix: 4537865
    l_tmp_struct_ver_id         NUMBER;
    -- added for Bug fix: 4537865
    l_new_pev_structure_id          PA_PROJ_ELEM_VER_STRUCTURE.PEV_STRUCTURE_ID%TYPE;
    l_new_pev_schedule_id           PA_PROJ_ELEM_VER_SCHEDULE.PEV_SCHEDULE_ID%TYPE;
    l_new_obj_rel_id                PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;

    l_original_baseline_flag        VARCHAR2(1);
    l_current_baseline_flag         VARCHAR2(1);

    l_new_struct_ver_name           PA_PROJ_ELEM_VER_STRUCTURE.name%TYPE;
    l_new_struct_ver_desc           PA_PROJ_ELEM_VER_STRUCTURE.description%TYPE;

    -- anlee
    -- Dates changes
    l_scheduled_start_date          DATE;
    l_scheduled_finish_date         DATE;
    l_proj_record_ver_number        NUMBER;

    l_user_id                       NUMBER;

  ----------------------------------- FP_M changes : Begin
  -- Refer to tracking bug 3305199
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /*  l_Old_Task_Versions_Tab        PA_PLSQL_DATATYPES.IdTabTyp;                  */
  /*  l_New_Task_Versions_Tab        PA_PLSQL_DATATYPES.IdTabTyp;                  */
    l_Old_Task_Versions_Tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
    l_New_Task_Versions_Tab        SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
  ----------------------------------- FP_M changes : End

    CURSOR get_scheduled_dates(c_project_id NUMBER, c_structure_version_id NUMBER)
    IS
    SELECT scheduled_start_date, scheduled_finish_date
    FROM pa_proj_elem_ver_schedule
    WHERE project_id = c_project_id
    AND   element_version_id = c_structure_version_id;

    CURSOR get_proj_rec_ver_number(c_project_id NUMBER)
    IS
    SELECT record_version_number
    FROM pa_projects_all
    WHERE project_id = c_project_id;
    -- End of changes


--Bug 2189657
--Added for linking tasks with no display sequence.
    Type T_EquivElemVerTable IS TABLE OF NUMBER
      Index by BINARY_INTEGER;
    t_equiv_elem_ver_id T_EquivElemVerTable;
--Bug 2189657 end;

    cursor get_from_id(c_element_version_id NUMBER) IS
      select object_relationship_id, object_id_from1 object_id_from,
             object_type_from, record_version_number
        from pa_object_relationships
       where relationship_type = 'L'
         and object_id_to1 = c_element_version_id
         and object_type_to IN ('PA_TASKS','PA_STRUCTURES');
    l_from_object_info        get_from_id%ROWTYPE;

    cursor get_to_id(c_element_version_id NUMBER) IS
      select object_relationship_id, object_id_to1 object_id_to, object_id_to2,
             object_type_to, record_version_number
        from pa_object_relationships
       where relationship_type IN ('LW', 'LF')
         and object_id_from1 = c_element_version_id
         and object_type_from IN ('PA_TASKS','PA_STRUCTURES');
    l_to_object_info          get_to_id%ROWTYPE;
    l_working_ver_fg          VARCHAR2(1);

    cursor get_task_version_info(c_task_version_id NUMBER) IS
      select v1.project_id project_id, v2.proj_element_id structure_id,
             v1.parent_structure_version_id structure_version_id,
             v1.element_version_id task_version_id
        from pa_proj_element_versions v1,
             pa_proj_element_versions v2
       where v1.element_version_id = c_task_version_id
         and v1.parent_structure_version_id = v2.element_version_id;
    l_info_task_ver_rec       get_task_version_info%ROWTYPE;

    cursor get_structure_version_info(c_structure_version_id NUMBER) IS
      select v1.project_id project_id, v1.proj_element_id structure_id,
             v1.element_version_id structure_version_id
        from pa_proj_element_versions v1
       where v1.element_version_id = c_structure_version_id;
    l_info_struc_ver_rec      get_structure_version_info%ROWTYPE;


    cursor get_struc_ver_name IS
      select pevs.name, pevs.project_id, pevs.proj_element_id,
             pevs.element_version_id, pevs.pev_structure_id
        from pa_proj_elem_ver_structure pevs,
             pa_proj_element_versions pev
       where pev.element_version_id = p_structure_version_id
         and pevs.project_id = pev.project_id
         and pevs.element_version_id = pev.element_version_id;

    CURSOR get_structure_ver_csr(c_structure_version_id NUMBER) IS
      SELECT *
      FROM PA_PROJ_ELEMENT_VERSIONS
      WHERE element_version_id = c_structure_version_id;
    l_struc_ver_rec          get_structure_ver_csr%ROWTYPE;

    CURSOR get_structure_ver_attr_csr(c_structure_version_id NUMBER, c_project_id NUMBER) IS
      SELECT *
      FROM PA_PROJ_ELEM_VER_STRUCTURE
      WHERE ELEMENT_VERSION_ID = c_structure_version_id
        AND project_id = c_project_id;
    l_struc_ver_attr_rec     get_structure_ver_attr_csr%ROWTYPE;

    CURSOR get_ver_schedule_attr_csr(c_element_version_id NUMBER, c_project_id NUMBER) IS
      SELECT *
      FROM PA_PROJ_ELEM_VER_SCHEDULE
      WHERE element_version_id = c_element_version_id
        AND project_id = c_project_id;
    l_ver_sch_attr_rec       get_ver_schedule_attr_csr%ROWTYPE;

--hsiu: task version status change. Added task version status.
    CURSOR get_task_versions_csr(c_structure_version_id NUMBER) IS
      SELECT a.element_version_id, a.proj_element_id, a.display_sequence, a.wbs_level,
             a.project_id, b.object_id_from1 parent_element_version_id,
             a.TASK_UNPUB_VER_STATUS_CODE, a.parent_structure_version_id
        FROM PA_PROJ_ELEMENT_VERSIONS a,
             PA_OBJECT_RELATIONSHIPS b
       WHERE a.object_type = 'PA_TASKS'
         AND a.parent_structure_version_id = c_structure_version_id
         AND a.element_version_id = b.object_id_to1
         AND b.relationship_type = 'S'
       ORDER BY a.display_sequence;

    l_task_versions_rec      get_task_versions_csr%ROWTYPE;

    Cursor get_linking_tasks IS
      select a.element_version_id
        from pa_proj_element_versions a,
             pa_proj_elements b
       where a.proj_element_id = b.proj_element_id
         and a.parent_structure_version_id = p_structure_version_id
         and b.link_task_flag = 'Y';
    l_linking_task_rec       get_linking_tasks%ROWTYPE;

    l_ref_task_ver_id        NUMBER;
    l_peer_or_sub            VARCHAR2(10);
    l_last_wbs_level         NUMBER;
    l_task_version_id        NUMBER;
    l_pev_schedule_id        NUMBER;

    l_i_msg_count            NUMBER;
    l_i_msg_data             PA_VC_1000_2000:= PA_VC_1000_2000(1);
    l_i_return_status        VARCHAR2(1);

    TYPE reference_tasks IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;
    l_outline_task_ref reference_tasks;

    l_proj_start_date        DATE;
    l_proj_completion_date   DATE;
    l_prefix                 VARCHAR2(80);

--Hsiu added for date rollup
    l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();

--hsiu added for advanced structure changes
    cursor sel_other_structure_ver(c_keep_struc_ver_id NUMBER) IS
      select b.element_version_id, b.record_version_number
        from pa_proj_element_versions a,
             pa_proj_element_versions b,
             pa_proj_elem_ver_structure c
       where a.element_version_id = c_keep_struc_ver_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.element_version_id <> c_keep_struc_ver_id
         and b.object_type = 'PA_STRUCTURES'
         and b.project_id = c.project_id
         and b.element_version_id = c.element_version_id
         and c.status_code <> 'STRUCTURE_PUBLISHED';
    l_del_struc_ver_id       NUMBER;
    l_del_struc_ver_rvn      NUMBER;

  CURSOR get_task_ver_weighting(p_task_ver_id NUMBER)
  IS
  select weighting_percentage
    from pa_object_relationships
   where object_id_to1 = p_task_ver_id
     and object_type_to = 'PA_TASKS'
     and object_type_from in ('PA_STRUCTURES','PA_TASKS')
     and object_type_to = 'PA_TASKS' -- Bug 6429275
     and relationship_type = 'S';
  l_weighting_percentage     NUMBER;

--hsiu added for task status
  l_error_message_code  VARCHAR2(250);
  l_create_task_ver_flag varchar2(1);

  -- Bug # 4691749.
  -- Replacing this varray PA_NUM_1000_NUM with t_TBDtasksTable index table.
  TYPE t_TBD_tasksTable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  --l_tbd_task_ver_id     PA_NUM_1000_NUM := PA_NUM_1000_NUM(); --replacing this varray with t_TBDtasksTable index table.
  l_tbd_task_ver_id       t_TBD_tasksTable;
  l_tbd_index             NUMBER := 0;
  -- Bug # 4691749.

  -- Added for  4096218
  -- This VARRAY will hold the list of to_be_deleted tasks' proj_element_ids
  l_tbd_task_id         PA_NUM_1000_NUM := PA_NUM_1000_NUM();

  l_del_task_cnt        NUMBER;

  CURSOR get_tbd_tasks_info(c_task_ver_id NUMBER) IS
    select parent_structure_version_id, element_version_id,
           record_version_number
      from pa_proj_element_versions
     where element_version_id = c_task_ver_id;
  l_tbd_tasks_info_rec   get_tbd_tasks_info%ROWTYPE;

  CURSOR get_parent_id(c_task_ver_id NUMBER) IS
    select object_id_from1
      from pa_object_relationships
     where object_id_to1 = c_task_ver_id
       and object_type_to = 'PA_TASKS'
       and relationship_type = 'S';
  l_parent_id NUMBER;
  l_parent_ver_id NUMBER;
  TYPE t_parentTable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_parent_tbl t_parentTable;

--bug 2662139
  CURSOR is_summary_elem(c_elem_ver_id NUMBER) IS
    SELECT '1'
      from pa_object_relationships
     where object_type_from IN ('PA_TASKS', 'PA_STRUCTURES')
       and object_id_from1 = c_elem_ver_id
       and relationship_type = 'S';

--bug
    l_err_code         NUMBER:= 0;
    l_err_stack        VARCHAR2(630);
    l_err_stage        VARCHAR2(80);

    l_messages         PA_PROJECT_STRUCTURE_PVT1.PA_PUBLISH_ERR_TBL_TYPE;
    l_page_content_id  NUMBER;
    l_item_key         VARCHAR2(240);

--added for performace improvement
    X_Row_id  VARCHAR2(255);

--added for performance improvement
    l_workplan_type    VARCHAR2(1);
    l_financial_type   VARCHAR2(1);

    --maansari
    i NUMBER := 1;
--    l_user_id    NUMBER := FND_GLOBAL.USER_ID;
    l_login_id   NUMBER := FND_GLOBAL.LOGIN_ID;
    --maansari

--bug 3047602
  l_task_ver_ids_tbl PA_STRUCT_TASK_ROLLUP_PUB.pa_element_version_id_tbl_typ;
  cursor get_all_new_childs(c_new_struc_ver_id NUMBER) IS
    select element_version_id
    from pa_proj_element_versions
    where parent_structure_version_id = c_new_struc_ver_id
    and object_type = 'PA_TASKS';
--end bug 3047602

  l_rowid VARCHAR2(255);
  CURSOR cur_elem_ver_seq IS
    SELECT pa_proj_element_versions_s.nextval
      FROM sys.dual;

  l_last_pub_str_ver_id   NUMBER;            --Bug No. 3450684  Smukka 01/03/2004
  l_chk_deliverable       VARCHAR2(80);      --Summuka For checking deliverables

  --bug 3822112
  l_share_flag            VARCHAR2(1)  := 'N';
  l_copy_actuals_flag     VARCHAR2(1)  := 'Y';
  -- Bug 3839288 Begin
  l_task_weight_basis_code pa_proj_progress_attr.task_weight_basis_code%TYPE;
  l_as_of_date             DATE;
  -- Bug 3839288 End
  l_upd_new_elem_ver_id_flag VARCHAR2(1) := 'Y'; --rtarway, 3951024

  l_debug_mode             VARCHAR2(1);

  -- 9072357
  l_structure_id           pa_proj_elem_ver_structure.proj_element_id%TYPE;

  CURSOR get_structure_id(c_structure_version_id pa_proj_elem_ver_structure.element_version_id%TYPE)
  IS
    SELECT proj_element_id
    FROM pa_proj_elem_ver_structure
    WHERE element_version_id = c_structure_version_id;

  BEGIN

    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.PUBLISH_STRUCTURE begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint publish_structure_pvt;
    END IF;

    PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';

    ----------
    -- code --
    IF p_user_id IS NULL THEN
      l_user_id := FND_GLOBAL.USER_ID;
    ELSE
      l_user_id := p_user_id;
    END IF;

    l_workplan_type    := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');
    l_financial_type   := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'FINANCIAL');

    select project_id
    into l_project_id
    from pa_proj_element_versions
    where element_version_id = p_structure_version_id;

    --bug 3840509
    IF 'Y' = nvl(PA_PROJECT_STRUCTURE_UTILS.Get_Sch_Dirty_fl(l_project_id,
                                                             p_structure_version_id), 'N') THEN
      --need to reschedule
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_NEED_THIRD_PT_SCH');
      x_msg_data := 'PA_PS_NEED_THIRD_PT_SCH';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --end bug 3840509

    l_share_flag       := PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(l_project_id);   --bug 3822112

    --Set the baseline flags
    l_original_baseline_flag := p_original_baseline_flag;
    l_current_baseline_flag  := p_current_baseline_flag;

    /* Smukka 01/03/2004 Bug No. 3450684                                                   */
    /* Added the following if block for getting the lastest published structure version id */
    IF l_workplan_type = 'Y' THEN
       l_last_pub_str_ver_id:=PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(l_project_id);
    ELSIF l_financial_type = 'Y' THEN
          l_last_pub_str_ver_id:=PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(l_project_id);
    END IF;

    --hsiu: changes for checking transaction currency difference
    --for bug 3786612
    PA_PROGRESS_UTILS.check_txn_currency_diff
    (
      p_structure_version_id => p_structure_version_id,
      p_context => 'PUBLISH_STRUCTURE',
      x_return_status => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --end changes for bug 3786612

    --hsiu: bug 2684465
    --Check if this structure missing tasks with transactions
--    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.check_miss_transaction_tasks(p_structure_version_id)) THEN
--      PA_UTILS.ADD_MESSAGE('PA','PA_PS_MISS_TRANSAC_TASK');
--      x_msg_data := 'PA_PS_MISS_TRANSAC_TASK';
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;
    PA_PROJECT_STRUCTURE_UTILS.CHECK_MISS_TRANSACTION_TASKS(p_structure_version_id,
                                                            l_return_status,
                                                            l_msg_count,
                                                            l_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Check if task statuses are consistent
    PA_PROJECT_STRUCTURE_UTILS.check_tasks_statuses_valid(
      p_structure_version_id
     ,l_return_status
     ,l_msg_count
     ,l_msg_data
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Check if any new summary task has transactions
    PA_PROJECT_STRUCTURE_UTILS.Check_txn_on_summary_tasks(
      p_structure_version_id
     ,l_return_status
     ,l_msg_count
     ,l_msg_data
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      PA_UTILS.ADD_MESSAGE('PA',l_error_message_code);
      x_msg_data := l_error_message_code;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --end bug 2684465

    -- 9072357
    OPEN get_structure_id(p_structure_version_id);
    FETCH get_structure_id INTO l_structure_id;
    CLOSE get_structure_id;

    IF ((PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_structure_id) = 'Y') AND
        (PA_PROJECT_STRUCTURE_UTILS.CHECK_SHARING_ENABLED(l_project_id) = 'Y')) THEN

      PA_PROJECT_STRUCTURE_UTILS.check_exp_item_dates(
        p_project_id           => l_project_id,
        p_structure_version_id => p_structure_version_id,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    --Check if this structure can be published (ie, if linked structures are published)
--    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.Check_Publish_Struc_Ver_Ok(p_structure_version_id)) THEN
--      PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_STRUC_NOT_PUB');
--      x_msg_data := 'PA_PS_LINK_STRUC_NOT_PUB';
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

    --Check if this structure missing tasks with transactions
--    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.check_miss_transaction_tasks(p_structure_version_id)) THEN
--      PA_UTILS.ADD_MESSAGE('PA','PA_PS_MISS_TRANSAC_TASK');
--      x_msg_data := 'PA_PS_MISS_TRANSAC_TASK';
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

    --For rollups
--    IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
--      OPEN get_linking_tasks;
--      LOOP
--        FETCH get_linking_tasks INTO l_linking_task_rec;
--        EXIT WHEN get_linking_tasks%NOTFOUND;
--        l_tasks_ver_ids.extend;
--        l_tasks_ver_ids(l_tasks_ver_ids.count) := l_linking_task_rec.element_version_id;
--      END LOOP;
--      CLOSE get_linking_tasks;
--
--      IF (l_tasks_ver_ids.count > 0) THEN
--        PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup(
--                       p_commit => FND_API.G_FALSE,
--                       p_element_versions => l_tasks_ver_ids,
--                       x_return_status => l_return_status,
--                       x_msg_count => l_msg_count,
--                       x_msg_data => l_msg_data);
--
--        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
--          x_msg_count := FND_MSG_PUB.count_msg;
--          if x_msg_count = 1 then
--            x_msg_data := l_msg_data;
--          end if;
--          raise FND_API.G_EXC_ERROR;
--        end if;
--
--      END IF;
--    END IF;

    --Check if any linked structure is workplan type and if publishing structure is
    --  financial only

    --dbms_output.put_line('1');
    OPEN get_struc_ver_name;
--dbms_output.put_line('open  get_struc_ver_name');
    FETCH get_struc_ver_name into l_dummy_name, l_project_id,
                                  l_proj_element_id, l_element_version_id,
                                  l_pev_structure_id;
    IF get_struc_ver_name%NOTFOUND THEN
--dbms_output.put_line('close get_struc_ver_name');
      CLOSE get_struc_ver_name;
      RAISE NO_DATA_FOUND;
    END IF;
--dbms_output.put_line('close get_struc_ver_name');
    CLOSE get_struc_ver_name;
    --dbms_output.put_line('1b');

    --Set baseline flags if this is the first published version
    IF ('N' = PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(l_project_id, l_proj_element_id)) THEN
      l_current_baseline_flag := 'Y';
      l_original_baseline_flag := 'Y';
    END IF;

    --Get Structure Version Attribute Info
--dbms_output.put_line('open get_structure_ver_attr_csr');
    OPEN get_structure_ver_attr_csr(p_structure_version_id, l_project_id);
    FETCH get_structure_ver_attr_csr INTO l_struc_ver_attr_rec;
--dbms_output.put_line('close get_structure_ver_attr_csr');
    CLOSE get_structure_ver_attr_csr;

    --Copy structure version name and description
    IF (p_publish_structure_ver_name IS NULL) OR (p_publish_structure_ver_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_new_struct_ver_name := l_struc_ver_attr_rec.name;
    ELSE
      l_new_struct_ver_name := p_publish_structure_ver_name;
    END IF;

    IF (p_structure_ver_desc IS NULL) or (p_structure_ver_desc = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      l_new_struct_ver_desc := l_struc_ver_attr_rec.description;
    ELSE
      l_new_struct_ver_desc := p_structure_ver_desc;
    END IF;

    --l_dummy_name for current structure
    --p_publish_structure_ver_name for new publishing structure
    --Check if names are the same
    IF (l_dummy_name = l_new_struct_ver_name) THEN
      -- If same, add Time-Stamp to working version.
--      error_msg('dummyname before '||l_dummy_name);
--      l_dummy_name := substr(fnd_date.date_to_canonical(sysdate)||' - '||
--                             l_dummy_name,0,240);
      --select prefix from pa_lookups
      select meaning
        into l_prefix
        from pa_lookups
       where lookup_type = 'PA_STRUCTURES_PREFIX'
         and lookup_code = 'PA_PREFIX_COPY';

      l_dummy_name := substrb(l_prefix||' '||l_dummy_name,0,240);

      -- Bug Fix 4727737
      -- We need to make sure that the name of the newly created working version is unique
      -- and not getting collided with the published versions name.
      -- Users can create data in such a way that the version name when prefixed with Copy To:
      -- will result into an existing published version name.

      -- So adding the following call to avoid the U2 violation due to the following update statement.

           IF (pa_project_structure_utils.check_struc_ver_name_unique(l_dummy_name,
                                                                      null,
                                                                      l_project_id,
                                                                      l_proj_element_id) <> 'Y') THEN

             --Not unique; error.
             pa_utils.add_message('PA','PA_PS_NEW_STRUC_VER_NAM_UNIQUE');
             x_msg_data := 'PA_PS_NEW_STRUC_VER_NAM_UNIQUE';
             RAISE FND_API.G_EXC_ERROR;
           END IF;

      -- End of Bug Fix 4727737

--      error_msg('dummy_name after'||l_dummy_name);
      -- update_name
      update PA_PROJ_ELEM_VER_STRUCTURE
      set name = l_dummy_name,
          current_working_flag = 'Y'
      where pev_structure_id = l_pev_structure_id;

    END IF;

    --Check if structure version name is unique
    If (PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Name_Unique(l_new_struct_ver_name,
                                                               null,
                                                               l_project_id,
                                                               l_proj_element_id) <> 'Y') THEN
      --Not unique; error.
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_VER_NAM_UNIQUE');
      x_msg_data := 'PA_PS_STRUC_VER_NAM_UNIQUE';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Bug No 3450684 Smukka Checking for deliverable type
    IF  PA_PROJ_ELEMENTS_UTILS.check_sharedstruct_deliv(p_structure_version_id) = 'Y' THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name => 'PA_PS_CHK_DEL_FAIL_PUB_STR');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Get Structure Version Info
    --dbms_output.put_line('2');
--dbms_output.put_line('open get_structure_ver_csr');
    OPEN get_structure_ver_csr(p_structure_version_id);
    FETCH get_structure_ver_csr INTO l_struc_ver_rec;
--dbms_output.put_line('close get_structure_ver_csr');
    CLOSE get_structure_ver_csr;
    --dbms_output.put_line('2b');

    OPEN cur_elem_ver_seq;
    FETCH cur_elem_ver_seq into l_new_struct_ver_id;
    CLOSE cur_elem_ver_seq;

    -- Fix for 4657794 :- This is fix for regression introduced by 4537865
    -- As X_ELEMENT_VERSION_ID is an IN OUT parameter ,we need to initialize, its value l_tmp_struct_ver_id
    -- to l_new_struct_ver_id

    l_tmp_struct_ver_id := l_new_struct_ver_id ;

    -- End 4657794

    PA_PROJ_ELEMENT_VERSIONS_PKG.INSERT_ROW(
       X_ROW_ID                       => l_rowid
    --,X_ELEMENT_VERSION_ID           => l_new_struct_ver_id        * commented for Bug Fix: 4537865
      ,X_ELEMENT_VERSION_ID       => l_tmp_struct_ver_id        -- added for Bug fix: 4537865
      ,X_PROJ_ELEMENT_ID              => l_struc_ver_rec.proj_element_id
      ,X_OBJECT_TYPE                  => 'PA_STRUCTURES'
      ,X_PROJECT_ID                   => l_struc_ver_rec.project_id
      ,X_PARENT_STRUCTURE_VERSION_ID  => l_new_struct_ver_id
      ,X_DISPLAY_SEQUENCE             => NULL
      ,X_WBS_LEVEL                    => NULL
      ,X_WBS_NUMBER                   => '0'
      ,X_ATTRIBUTE_CATEGORY           => l_struc_ver_rec.attribute_category
      ,X_ATTRIBUTE1                   => l_struc_ver_rec.attribute1
      ,X_ATTRIBUTE2                   => l_struc_ver_rec.attribute2
      ,X_ATTRIBUTE3                   => l_struc_ver_rec.attribute3
      ,X_ATTRIBUTE4                   => l_struc_ver_rec.attribute4
      ,X_ATTRIBUTE5                   => l_struc_ver_rec.attribute5
      ,X_ATTRIBUTE6                   => l_struc_ver_rec.attribute6
      ,X_ATTRIBUTE7                   => l_struc_ver_rec.attribute7
      ,X_ATTRIBUTE8                   => l_struc_ver_rec.attribute8
      ,X_ATTRIBUTE9                   => l_struc_ver_rec.attribute9
      ,X_ATTRIBUTE10                  => l_struc_ver_rec.attribute10
      ,X_ATTRIBUTE11                  => l_struc_ver_rec.attribute11
      ,X_ATTRIBUTE12                  => l_struc_ver_rec.attribute12
      ,X_ATTRIBUTE13                  => l_struc_ver_rec.attribute13
      ,X_ATTRIBUTE14                  => l_struc_ver_rec.attribute14
      ,X_ATTRIBUTE15                  => l_struc_ver_rec.element_version_id
      ,X_TASK_UNPUB_VER_STATUS_CODE   => NULL
            ,X_SOURCE_OBJECT_ID             => l_struc_ver_rec.project_id
            ,X_SOURCE_OBJECT_TYPE           => 'PA_PROJECTS'
    );
    -- added for Bug fix: 4537865
        l_new_struct_ver_id := l_tmp_struct_ver_id;
    -- added for Bug fix: 4537865

/* This API insert into planning txn table if wp. Call table hander instead
    --Call Create Structure Version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
     ( p_validate_only         => p_validate_only
      ,p_structure_id          => l_struc_ver_rec.proj_element_id
      ,p_attribute_category    => l_struc_ver_rec.attribute_category
      ,p_attribute1            => l_struc_ver_rec.attribute1
      ,p_attribute2            => l_struc_ver_rec.attribute2
      ,p_attribute3            => l_struc_ver_rec.attribute3
      ,p_attribute4            => l_struc_ver_rec.attribute4
      ,p_attribute5            => l_struc_ver_rec.attribute5
      ,p_attribute6            => l_struc_ver_rec.attribute6
      ,p_attribute7            => l_struc_ver_rec.attribute7
      ,p_attribute8            => l_struc_ver_rec.attribute8
      ,p_attribute9            => l_struc_ver_rec.attribute9
      ,p_attribute10           => l_struc_ver_rec.attribute10
      ,p_attribute11           => l_struc_ver_rec.attribute11
      ,p_attribute12           => l_struc_ver_rec.attribute12
      ,p_attribute13           => l_struc_ver_rec.attribute13
      ,p_attribute14           => l_struc_ver_rec.attribute14
      ,p_attribute15           => l_struc_ver_rec.element_version_id    --for performacnce to be used later by new structure version
      ,x_structure_version_id  => l_new_struct_ver_id
      ,x_return_status         => l_return_status
      ,x_msg_count             => l_msg_count
      ,x_msg_data              => l_msg_data );
--dbms_output.put_line('new struct version id = '||l_new_struct_ver_id);
*/

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('create structure version =>'||l_new_struct_ver_id);
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    --update links linking from working version to current published version
--    PA_PROJECT_STRUCTURE_PVT1.UPDATE_LATEST_PUB_LINKS
--    (
--      p_init_msg_list       => FND_API.G_FALSE
--     ,p_commit              => FND_API.G_FALSE
--     ,p_debug_mode          => p_debug_mode
--     ,p_orig_project_id     => l_project_id
--     ,p_orig_structure_id   => l_proj_element_id
--     ,p_orig_struc_ver_id   => p_structure_version_id
--     ,p_orig_task_ver_id    => NULL
--     ,p_new_project_id      => l_project_id
--     ,p_new_structure_id    => l_struc_ver_rec.proj_element_id
--     ,p_new_struc_ver_id    => l_new_struct_ver_id
--     ,p_new_task_ver_id     => NULL
--     ,x_return_status       => l_return_status
--     ,x_msg_count           => l_msg_count
--     ,x_msg_data            => l_msg_data
--    );
--
--    l_msg_count := FND_MSG_PUB.count_msg;
--    if l_msg_count > 0 then
--      x_msg_count := l_msg_count;
--      if x_msg_count = 1 then
--        x_msg_data := l_msg_data;
--      end if;
--      raise FND_API.G_EXC_ERROR;
--    end if;

    --Search for incoming links; update existing links
    --dbms_output.put_line('3');
--dbms_output.put_line('open p_structure_version_id');
--    OPEN get_from_id(p_structure_version_id);
--    LOOP
--      IF (p_debug_mode = 'Y') THEN
--        pa_debug.debug('check incoming links for struct');
--      END IF;
--      FETCH get_from_id INTO l_from_object_info;
--      EXIT WHEN get_from_id%NOTFOUND;
--
--      If (l_from_object_info.object_type_from = 'PA_STRUCTURES') THEN
--        --get element information, then update
--        --dbms_output.put_line('4');
--dbms_output.put_line('open get_structure_version_info');
--        OPEN get_structure_version_info(l_from_object_info.object_id_from);
--        FETCH get_structure_version_info INTO l_info_struc_ver_rec;
--        PA_RELATIONSHIP_PVT.Update_Relationship(
--          p_init_msg_list => FND_API.G_FALSE
--         ,p_commit => FND_API.G_FALSE
--         ,p_debug_mode => p_debug_mode
--         ,p_object_relationship_id    => l_from_object_info.object_relationship_id
--         ,p_project_id_from           => l_info_struc_ver_rec.project_id
--         ,p_structure_id_from         => l_info_struc_ver_rec.structure_id
--         ,p_structure_version_id_from => l_info_struc_ver_rec.structure_version_id
--         ,p_task_version_id_from      => NULL
--         ,p_project_id_to             => l_project_id
--         ,p_structure_id_to           => l_struc_ver_rec.proj_element_id
--         ,p_structure_version_id_to   => l_new_struct_ver_id
--         ,p_task_version_id_to        => NULL
--         ,p_relationship_type         => 'L'
--         ,p_relationship_subtype      => 'READ_WRITE'
--         ,p_record_version_number     => l_from_object_info.record_version_number
--         ,x_return_status             => l_return_status
--         ,x_msg_count                 => l_msg_count
--         ,x_msg_data                  => l_msg_data
--        );
--dbms_output.put_line('close get_structure_version_info');
--        CLOSE get_structure_version_info;
--        --dbms_output.put_line('4b');
--
--
--      ELSIF (l_from_object_info.object_type_from = 'PA_TASKS') THEN
--        --get element information, then update
--        --dbms_output.put_line('5');
--dbms_output.put_line('open get_task_version_info');
--        OPEN get_task_version_info(l_from_object_info.object_id_from);
--        FETCH get_task_version_info INTO l_info_task_ver_rec;
--        PA_RELATIONSHIP_PVT.Update_Relationship(
--          p_init_msg_list => FND_API.G_FALSE
--         ,p_commit => FND_API.G_FALSE
--         ,p_debug_mode => p_debug_mode
--         ,p_object_relationship_id    => l_from_object_info.object_relationship_id
--         ,p_project_id_from           => l_info_task_ver_rec.project_id
--         ,p_structure_id_from         => l_info_task_ver_rec.structure_id
--         ,p_structure_version_id_from => l_info_task_ver_rec.structure_version_id
--         ,p_task_version_id_from      => l_info_task_ver_rec.task_version_id
--         ,p_project_id_to             => l_project_id
--         ,p_structure_id_to           => l_struc_ver_rec.proj_element_id
--         ,p_structure_version_id_to   => l_new_struct_ver_id
--         ,p_task_version_id_to        => NULL
--         ,p_relationship_type         => 'L'
--         ,p_relationship_subtype      => 'READ_WRITE'
--         ,p_record_version_number     => l_from_object_info.record_version_number
--         ,x_return_status             => l_return_status
--         ,x_msg_count                 => l_msg_count
--         ,x_msg_data                  => l_msg_data
--        );
--dbms_output.put_line('close get_task_version_info');
--        CLOSE get_task_version_info;
--        --dbms_output.put_line('5b');
--
--      END IF;
--      If (p_debug_mode = 'Y') THEN
--        pa_debug.debug('update incoming links for struct =>'||l_return_status);
--      END IF;
--
--      --Check error
--      l_msg_count := FND_MSG_PUB.count_msg;
--      if (l_msg_count > 0) then
--        x_msg_count := l_msg_count;
--        if x_msg_count = 1 then
--          x_msg_data := l_msg_data;
--        end if;
--dbms_output.put_line('close get_from_id');
--        CLOSE get_from_id;
--        raise FND_API.G_EXC_ERROR;
--      end if;
--
--
--    END LOOP;
--dbms_output.put_line('close get_from_id');
--    CLOSE get_from_id;
    --dbms_output.put_line('5b');

    -----------------------------------------------
    --Search for outgoing links; create new Links--
    --dbms_output.put_line('6');
--dbms_output.put_line('open get_to_id');
--    OPEN get_to_id(p_structure_version_id);
--    LOOP
--      IF (p_debug_mode = 'Y') THEN
--        pa_debug.debug('check outgoing links for struct');
--      END IF;
--      FETCH get_to_id INTO l_to_object_info;
--      EXIT WHEN get_to_id%NOTFOUND;
--      If (l_to_object_info.object_type_to = 'PA_STRUCTURES') THEN
--        --dbms_output.put_line('7');
--dbms_output.put_line('open get_structure_version_info');
--        OPEN get_structure_version_info(l_to_object_info.object_id_to);
--        FETCH get_structure_version_info INTO l_info_struc_ver_rec;
/*****************************/
--dbms_output.put_line('creating rel: structure out going links for structures');
--        PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
--         p_user_id => FND_GLOBAL.USER_ID
--        ,p_object_type_from => 'PA_STRUCTURES'
--        ,p_object_id_from1 => l_new_struct_ver_id
--        ,p_object_id_from2 => NULL
--        ,p_object_id_from3 => NULL
--        ,p_object_id_from4 => NULL
--        ,p_object_id_from5 => NULL
--        ,p_object_type_to => 'PA_STRUCTURES'
--        ,p_object_id_to1 => l_info_struc_ver_rec.structure_version_id
--        ,p_object_id_to2 => NULL
--        ,p_object_id_to3 => NULL
--        ,p_object_id_to4 => NULL
--        ,p_object_id_to5 => NULL
--        ,p_relationship_type => 'L'
--        ,p_relationship_subtype => 'READ_WRITE'
--        ,p_lag_day => NULL
--        ,p_imported_lag => NULL
--        ,p_priority => NULL
--        ,p_pm_product_code => NULL
--        ,x_object_relationship_id => l_new_obj_rel_id
--        ,x_return_status => l_return_status
--        );
--
/*****************************/
--dbms_output.put_line('close get_structure_version_info');
--        CLOSE get_structure_version_info;
--        --dbms_output.put_line('7b');
--
--      ELSIF(l_to_object_info.object_type_to = 'PA_TASKS') THEN
--        --dbms_output.put_line('8');
--dbms_output.put_line('open get_task_version_info');
--        OPEN get_task_version_info(l_to_object_info.object_id_to);
--        FETCH get_task_version_info INTO l_info_task_ver_rec;
/*****************************/
--dbms_output.put_line('creating rel: structure out going links for tasks');
--        PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
--         p_user_id => FND_GLOBAL.USER_ID
--        ,p_object_type_from => 'PA_STRUCTURES'
--        ,p_object_id_from1 => l_new_struct_ver_id
--        ,p_object_id_from2 => NULL
--        ,p_object_id_from3 => NULL
--        ,p_object_id_from4 => NULL
--        ,p_object_id_from5 => NULL
--        ,p_object_type_to => 'PA_TASKS'
--        ,p_object_id_to1 => l_info_task_ver_rec.task_version_id
--        ,p_object_id_to2 => NULL
--        ,p_object_id_to3 => NULL
--        ,p_object_id_to4 => NULL
--        ,p_object_id_to5 => NULL
--        ,p_relationship_type => 'L'
--        ,p_relationship_subtype => 'READ_WRITE'
--        ,p_lag_day => NULL
--        ,p_imported_lag => NULL
--        ,p_priority => NULL
--        ,p_pm_product_code => NULL
--        ,x_object_relationship_id => l_new_obj_rel_id
--        ,x_return_status => l_return_status
--        );
--
/*****************************/
--dbms_output.put_line('close get_task_version_info');
--        CLOSE get_task_version_info;
--        --dbms_output.put_line('8b');
--
--        If (p_debug_mode = 'Y') THEN
--          pa_debug.debug('update outgoing links for struct =>'||l_return_status);
--        END IF;
--      END IF;
--      --Check error
--      l_msg_count := FND_MSG_PUB.count_msg;
--      if (l_msg_count > 0) then
--        x_msg_count := l_msg_count;
--        if x_msg_count = 1 then
--          x_msg_data := l_msg_data;
--        end if;
--dbms_output.put_line('close get_to_id');
--        CLOSE get_to_id;
--        raise FND_API.G_EXC_ERROR;
--      end if;

--    END LOOP;
--dbms_output.put_line('close get_to_id');
--    CLOSE get_to_id;
    --dbms_output.put_line('6b');


--maansari
--initialized the pl/sql table
l_src_tasks_versions_tbl.delete;
--maansari

    --Create the task versions
    --Fetch all task versions
--    error_msg('create tasks');
--dbms_output.put_line('open get_Task_versions_csr');
    OPEN get_task_versions_csr(p_structure_version_id);
    l_last_wbs_level := NULL;
    LOOP
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('create task version for published structure');
      END IF;

      FETCH get_task_versions_csr INTO l_task_versions_rec;
      EXIT WHEN get_task_versions_csr%NOTFOUND;

--hsiu added for task version status
--Check if this task can be deleted.
--Call PA_PROJ_ELEMENTS_UTILS.Check_Del_all_task_Ver_Ok
--If ok to be deleted, move on to the next task and don't add this task
--  (goto l_endofloop);
--otherwise add this task and set status to 'CANCELLED'
      l_create_task_ver_flag := 'Y';

      --Removing due to changes in publishing
      select a.proj_element_id, b.object_id_from1
      into   l_parent_id, l_parent_ver_id
      from pa_proj_element_versions a,
           pa_object_relationships b
      where a.element_version_id = b.object_id_from1
      and a.object_type = b.object_type_from
      and relationship_type = 'S'
      and object_id_to1 = l_task_versions_rec.element_version_id
      and object_type_to = 'PA_TASKS';

      --If it is financial task, check if this task should be created

--      PA_PROJ_ELEMENTS_UTILS.Check_create_subtask_ok(
--        p_parent_task_ver_id => l_parent_ver_id
--       ,x_return_status => l_return_status
--       ,x_error_message_code => l_error_message_code);

--bug: 2805602
--hsiu: commented because this has been done in check_txn_on_summary_tasks
--      If (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_parent_id) = 'Y') THEN
--        PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(x_task_id => l_parent_id,
--          x_err_code => l_err_code,
--          x_err_stack => l_err_stack,
--          x_err_stage => l_err_stage
--          );
--        IF (l_err_code <> 0) THEN
--          l_create_task_ver_flag := 'N';
--        END IF;
--      END IF;

--      IF (l_return_status <> 'Y') THEN
--        l_create_task_ver_flag := 'N';
--      END IF;

      IF (l_task_versions_rec.TASK_UNPUB_VER_STATUS_CODE = 'TO_BE_DELETED') THEN

        PA_PROJ_ELEMENTS_UTILS.Check_Del_all_task_Ver_Ok(
                     p_project_id             => l_task_versions_rec.project_id
                    ,p_task_version_id        => l_task_versions_rec.element_version_id
                    ,p_parent_structure_ver_id=> l_task_versions_rec.parent_structure_version_id
                    ,x_return_status          => l_return_status
                    ,x_error_message_code     => l_error_message_code );
        IF l_return_status <> 'S' THEN
--Cannot delete this version. Create and set as cancelled
          l_create_task_ver_flag := 'Y';
        ELSE
--This task version should not be created
          l_create_task_ver_flag := 'N';
--delete from working if found

          -- Bug # 4691749.
          -- l_tbd_task_ver_id.extend;
          -- l_tbd_task_ver_id(l_tbd_task_ver_id.count) := l_task_versions_rec.element_version_id;
          l_tbd_index := l_tbd_index + 1;
          l_tbd_task_ver_id(l_tbd_index) := l_task_versions_rec.element_version_id;
          -- Bug # 4691749.

          -- Start : 4096218
          if (l_tbd_task_id.count < 1000) then -- Bug # 4691749.
      	 	l_tbd_task_id.extend;
         	l_tbd_task_id(l_tbd_task_id.count) := l_task_versions_rec.proj_element_id;
          end if; -- Bug # 4691749.
          -- End : 4096218

--prorate this branch; find parent
          IF (l_last_wbs_level is NULL) THEN
            l_parent_tbl(l_new_struct_ver_id) := l_new_struct_ver_id;
            --l_parent_ver_id := l_new_struct_ver_id;
          ELSE
            IF (l_task_versions_rec.wbs_level > l_last_wbs_level) THEN
              l_parent_tbl(l_outline_task_ref(l_last_wbs_level)) := l_outline_task_ref(l_last_wbs_level);
              --l_parent_ver_id := l_outline_task_ref(l_last_wbs_level);
            ELSE
              OPEN get_parent_id(l_outline_task_ref(l_task_versions_rec.wbs_level));
              FETCH get_parent_id into l_parent_ver_id;
              CLOSE get_parent_id;
              l_parent_tbl(l_parent_ver_id) := l_parent_ver_id;
            END IF;
          END IF;
        END IF;
        --set task status to cancelled.
        UPDATE pa_proj_elements
           set status_code = '128',
               RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,1)+1,
               LAST_UPDATE_DATE = SYSDATE,
               LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
               LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
         where proj_element_id = l_task_versions_rec.proj_element_id;

        update pa_proj_element_versions
           set TASK_UNPUB_VER_STATUS_CODE = 'PUBLISHED'
         where element_version_id = l_task_versions_rec.element_version_id;

        -- 3955848 Added code to delete task to dlvr association in publishing flow , version enabled case
        -- p_delete_or_validate is passed as 'D' because only deletion should be done

        PA_DELIVERABLE_PUB.delete_dlv_task_asscn_in_bulk
         (
             p_task_element_id      => l_task_versions_rec.proj_element_id
            ,p_project_id           => l_task_versions_rec.project_id
            ,p_task_version_id      => l_task_versions_rec.element_version_id
            ,p_delete_or_validate   => 'D'
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR then
             RAISE FND_API.G_EXC_ERROR;
         End If;

        -- 3955848 end

      ELSE
        --if this task is linking to a working structure version
        --then do not copy

        --Added by rtarway for bug 4193990
        l_working_ver_fg := 'N';

        OPEN get_to_id(l_task_versions_rec.element_version_id);
        FETCH get_to_id INTO l_to_object_info;
        IF get_to_id%FOUND THEN
          --check if this is working version
          IF (pa_project_structure_utils.check_struc_ver_published(l_to_object_info.object_id_to2 ,l_to_object_info.object_id_to)
              = 'N') THEN
            l_working_ver_fg := 'Y';
          ELSE
            l_working_ver_fg := 'N';
          END IF;
        --Added by rtarway for bug 4193990
        ELSE
           l_working_ver_fg := 'N';
        --End Added by rtarway for bug 4193990
        END IF;
        CLOSE get_to_id;

        IF (l_working_ver_fg = 'Y') THEN
          l_create_task_ver_flag := 'N';
          IF (l_last_wbs_level is NULL) THEN
            l_parent_tbl(l_new_struct_ver_id) := l_new_struct_ver_id;
            --l_parent_ver_id := l_new_struct_ver_id;
          ELSE
            IF (l_task_versions_rec.wbs_level > l_last_wbs_level) THEN
              l_parent_tbl(l_outline_task_ref(l_last_wbs_level)) := l_outline_task_ref(l_last_wbs_level);
              --l_parent_ver_id := l_outline_task_ref(l_last_wbs_level);
            ELSE
              OPEN get_parent_id(l_outline_task_ref(l_task_versions_rec.wbs_level));
              FETCH get_parent_id into l_parent_ver_id;
              CLOSE get_parent_id;
              l_parent_tbl(l_parent_ver_id) := l_parent_ver_id;
            END IF;
          END IF;
        ELSE --copy
          update pa_proj_element_versions
             set TASK_UNPUB_VER_STATUS_CODE = 'PUBLISHED'
          where element_version_id = l_task_versions_rec.element_version_id;
        END IF;
      END IF;

--maansari
      l_src_tasks_versions_tbl(i).src_task_version_id         := l_task_versions_rec.element_version_id;
      l_src_tasks_versions_tbl(i).src_version_status          := l_task_versions_rec.TASK_UNPUB_VER_STATUS_CODE;
      l_src_tasks_versions_tbl(i).src_parent_task_version_id  := l_parent_ver_id;
      l_src_tasks_versions_tbl(i).copy_flag                   := l_create_task_ver_flag;
      i := i + 1;
--maansari

/*--maansari  --commenting out the following code and replacing it with bulk insert
    IF (l_create_task_ver_flag = 'Y') THEN
--dbms_output.put_line('creating task '||l_task_versions_rec.proj_element_id||', '||l_task_versions_rec.element_version_id);
      if l_last_wbs_level is null then
        -- first task version being created
        -- This task should have wbs level = 1
        l_ref_task_ver_id := l_new_struct_ver_id;
        l_peer_or_sub := 'SUB';
      else
        if l_task_versions_rec.wbs_level > l_last_wbs_level then
          l_ref_task_ver_id := l_outline_task_ref(l_last_wbs_level);
          l_peer_or_sub := 'SUB';
        else
          l_ref_task_ver_id := l_outline_task_ref(l_task_versions_rec.wbs_level);
          l_peer_or_sub := 'PEER';
        end if;
      end if;
--dbms_output.put_line('l_ref_task_ver_id = '||l_ref_task_ver_id);
--dbms_output.put_line('l_peer_or_sub =  '||l_peer_or_sub);
--dbms_output.put_line('parent_element_version_id = '||l_task_versions_rec.parent_element_version_id);
--Bug 2189657
--Added for linking tasks with no display sequence.
--Set correct reference and parent element version id
      If (l_task_versions_rec.display_sequence IS NULL) THEN
        IF (l_ref_task_ver_id <> l_new_struct_ver_id) THEN
          --A task has already been created. Reference task must be a task
          IF (l_task_versions_rec.parent_element_version_id = p_structure_version_id) THEN
            --this is a link to the structure version. A task has already been created.
            --need to use a top level task as peer reference task
            l_peer_or_sub := 'PEER';
            l_ref_task_ver_id := l_outline_task_ref(1);
          ELSE
            --this is a link to a task.
            l_peer_or_sub := 'SUB';
            l_ref_task_ver_id := t_equiv_elem_ver_id(l_task_versions_rec.parent_element_version_id);
          END IF;
        ELSE
          --No task has been created. Reference task is structure
          l_peer_or_sub := 'SUB';
          l_ref_task_ver_id := l_new_struct_ver_id;
--          l_ref_task_ver_id := t_equiv_elem_ver_id(l_task_versions_rec.parent_element_version_id);
        END IF;
      END IF;
--dbms_output.put_line('l_ref_task_ver_id = '||l_ref_task_ver_id);
--dbms_output.put_line('l_peer_or_sub =  '||l_peer_or_sub);

      OPEN get_task_ver_weighting(l_task_versions_rec.element_version_id);
      FETCH get_task_ver_weighting into l_weighting_percentage;
      CLOSE get_task_ver_weighting;

--Bug 2189657 end;
      PA_TASK_PVT1.CREATE_TASK_VERSION
      ( p_validate_only        => FND_API.G_FALSE
       ,p_validation_level     => 0
       ,p_ref_task_version_id  => l_ref_task_ver_id
       ,p_peer_or_sub          => l_peer_or_sub
       ,p_task_id              => l_task_versions_rec.proj_element_id
       ,p_WEIGHTING_PERCENTAGE => l_weighting_percentage
       ,p_TASK_UNPUB_VER_STATUS_CODE => 'PUBLISHED'
       ,x_task_version_id      => l_task_version_id
       ,x_return_status        => l_return_status
       ,x_msg_count            => l_msg_count
       ,x_msg_data             => l_msg_data);

      t_equiv_elem_ver_id(l_task_versions_rec.element_version_id) := l_task_version_id;
--dbms_output.put_line('elem_ver_id = '||l_task_versions_rec.element_version_id||', new elem_ver_id = '||l_task_version_id);

--dbms_output.put_line('ref/peer = '||l_ref_task_ver_id||'/'||l_peer_or_sub||'elm Id = '||l_task_versions_rec.proj_element_id||', elm ver Id = '||l_task_version_id);

--dbms_output.put_line('new task version id = '||l_task_version_id);

--      error_msg('done create_task_version '||l_msg_count||', '||l_msg_data);
      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
--dbms_output.put_line('close get_task_versions_csr');
        CLOSE get_task_versions_csr;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
*/ --maansari


--      error_msg('before update published links');
      --update links linking from working version to current published version
--      IF (p_debug_mode = 'Y') THEN
--        pa_debug.debug('updating links');
--      END IF;
--      PA_PROJECT_STRUCTURE_PVT1.UPDATE_LATEST_PUB_LINKS
--      (
--        p_init_msg_list       => FND_API.G_FALSE
--       ,p_commit              => FND_API.G_FALSE
--       ,p_debug_mode          => p_debug_mode
--       ,p_orig_project_id     => l_project_id
--       ,p_orig_structure_id   => l_proj_element_id
--       ,p_orig_struc_ver_id   => p_structure_version_id
--       ,p_orig_task_ver_id    => l_task_versions_rec.element_version_id
--       ,p_new_project_id      => l_project_id
--       ,p_new_structure_id    => l_struc_ver_rec.proj_element_id
--       ,p_new_struc_ver_id    => l_new_struct_ver_id
--       ,p_new_task_ver_id     => l_task_version_id
--       ,x_return_status       => l_return_status
--       ,x_msg_count           => l_msg_count
--       ,x_msg_data            => l_msg_data
--      );
--      error_msg('update latest published links');

      --Check if there is any error.
--      l_msg_count := FND_MSG_PUB.count_msg;
--      IF l_msg_count > 0 THEN
--        x_msg_count := l_msg_count;
--        IF x_msg_count = 1 THEN
--          x_msg_data := l_msg_data;
--        END IF;
--dbms_output.put_line('close get_task_versions_csr');
--        CLOSE get_task_versions_csr;
--        RAISE FND_API.G_EXC_ERROR;
--      END IF;


      --Search for incoming links; update existing links
--dbms_output.put_line('open get_from_id');
--      OPEN get_from_id(l_task_versions_rec.element_version_id);
--      LOOP
--        FETCH get_from_id INTO l_from_object_info;
--        EXIT WHEN get_from_id%NOTFOUND;
--        IF (l_from_object_info.object_type_from = 'PA_STRUCTURES') THEN
--dbms_output.put_line('open get_structure_version_info');
--          OPEN get_structure_version_info(l_from_object_info.object_id_from);
--          FETCH get_structure_version_info INTO l_info_struc_ver_rec;
--          PA_RELATIONSHIP_PVT.Update_Relationship(
--            p_init_msg_list => FND_API.G_FALSE
--           ,p_commit => FND_API.G_FALSE
--           ,p_debug_mode => p_debug_mode
--           ,p_object_relationship_id    => l_from_object_info.object_relationship_id
--           ,p_project_id_from           => l_info_struc_ver_rec.project_id
--           ,p_structure_id_from         => l_info_struc_ver_rec.structure_id
--           ,p_structure_version_id_from => l_info_struc_ver_rec.structure_version_id
--           ,p_task_version_id_from      => NULL
--           ,p_project_id_to             => l_project_id
--           ,p_structure_id_to           => l_struc_ver_rec.proj_element_id
--           ,p_structure_version_id_to   => l_new_struct_ver_id
--           ,p_task_version_id_to        => l_task_version_id
--           ,p_relationship_type         => 'L'
--           ,p_relationship_subtype      => 'READ_WRITE'
--           ,p_record_version_number     => l_from_object_info.record_version_number
--           ,x_return_status             => l_return_status
--           ,x_msg_count                 => l_msg_count
--           ,x_msg_data                  => l_msg_data
--          );
--dbms_output.put_line('Incoming: From '||l_info_struc_ver_rec.structure_version_id||' To '||l_task_version_id);
--dbms_output.put_line('close get_structure_version_info');
--          CLOSE get_structure_version_info;
--
--        ELSIF (l_from_object_info.object_type_from = 'PA_TASKS') THEN
--dbms_output.put_line('get_task_version_info');
--          OPEN get_task_version_info(l_from_object_info.object_id_from);
--          FETCH get_task_version_info INTO l_info_task_ver_rec;
--          PA_RELATIONSHIP_PVT.Update_Relationship(
--            p_init_msg_list => FND_API.G_FALSE
--           ,p_commit => FND_API.G_FALSE
--           ,p_debug_mode => p_debug_mode
--           ,p_object_relationship_id    => l_from_object_info.object_relationship_id
--           ,p_project_id_from           => l_info_task_ver_rec.project_id
--           ,p_structure_id_from         => l_info_task_ver_rec.structure_id
--           ,p_structure_version_id_from => l_info_task_ver_rec.structure_version_id
--           ,p_task_version_id_from      => l_info_task_ver_rec.task_version_id
--           ,p_project_id_to             => l_project_id
--           ,p_structure_id_to           => l_struc_ver_rec.proj_element_id
--           ,p_structure_version_id_to   => l_new_struct_ver_id
--           ,p_task_version_id_to        => l_task_version_id
--           ,p_relationship_type         => 'L'
--           ,p_relationship_subtype      => 'READ_WRITE'
--           ,p_record_version_number     => l_from_object_info.record_version_number
--           ,x_return_status             => l_return_status
--           ,x_msg_count                 => l_msg_count
--           ,x_msg_data                  => l_msg_data
--          );
--dbms_output.put_line('Incoming: From '||l_info_task_ver_rec.task_version_id||' To '||l_task_version_id);
--dbms_output.put_line('close get_task_version_info');
--          CLOSE get_task_version_info;
--        END IF;
--
--        --Check error
--        l_msg_count := FND_MSG_PUB.count_msg;
--        if (l_msg_count > 0) then
--          x_msg_count := l_msg_count;
--          if x_msg_count = 1 then
--            x_msg_data := l_msg_data;
--          end if;
--dbms_output.put_line('close get_task_versions_csr');
--          CLOSE get_task_versions_csr;
--dbms_output.put_line('close get_from_id');
--          CLOSE get_from_id;
--          raise FND_API.G_EXC_ERROR;
--        end if;

--      END LOOP;
--dbms_output.put_line('close get_from_id');
--      CLOSE get_from_id;

      --Search for outgoing links; create new Links
--dbms_output.put_line('get_to_id');
--      OPEN get_to_id(l_task_versions_rec.element_version_id);
--      LOOP
--        FETCH get_to_id INTO l_to_object_info;
--        EXIT WHEN get_to_id%NOTFOUND;
--        If (l_to_object_info.object_type_to = 'PA_STRUCTURES') THEN
--dbms_output.put_line('get_structure_version_info');
--          OPEN get_structure_version_info(l_to_object_info.object_id_to);
--          FETCH get_structure_version_info INTO l_info_struc_ver_rec;
/*****************************/
--dbms_output.put_line('creating rel: task out going links for structures');
--dbms_output.put_line(l_project_id||','||l_struc_ver_rec.proj_element_id||','||l_new_struct_ver_id||','||','||l_task_version_id||', TO: '
--||l_info_struc_ver_rec.project_id||','||l_info_struc_ver_rec.structure_id||','||l_info_struc_ver_rec.structure_version_id);
--          PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
--           p_user_id => FND_GLOBAL.USER_ID
--          ,p_object_type_from => 'PA_TASKS'
--          ,p_object_id_from1 => l_task_version_id
--          ,p_object_id_from2 => NULL
--          ,p_object_id_from3 => NULL
--          ,p_object_id_from4 => NULL
--          ,p_object_id_from5 => NULL
--          ,p_object_type_to => 'PA_STRUCTURES'
--          ,p_object_id_to1 => l_info_struc_ver_rec.structure_version_id
--          ,p_object_id_to2 => NULL
--          ,p_object_id_to3 => NULL
--          ,p_object_id_to4 => NULL
--          ,p_object_id_to5 => NULL
--          ,p_relationship_type => 'L'
--          ,p_relationship_subtype => 'READ_WRITE'
--          ,p_lag_day => NULL
--          ,p_imported_lag => NULL
--          ,p_priority => NULL
--          ,p_pm_product_code => NULL
--          ,x_object_relationship_id => l_new_obj_rel_id
--          ,x_return_status => l_return_status
--          );
--dbms_output.put_line('Outgoing: From '||l_task_version_id||' To '||l_info_struc_ver_rec.structure_version_id);

/*****************************/
--dbms_output.put_line('close get_structure_version_info');
--          CLOSE get_structure_version_info;

--        ELSIF (l_to_object_info.object_type_to = 'PA_TASKS') THEN
--dbms_output.put_line('open get_task_version_info');
--          OPEN get_task_version_info(l_to_object_info.object_id_to);
--          FETCH get_task_version_info INTO l_info_task_ver_rec;
/*****************************/
--dbms_output.put_line('creating rel: task out going links for tasks');
--          PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
--           p_user_id => FND_GLOBAL.USER_ID
--          ,p_object_type_from => 'PA_TASKS'
--          ,p_object_id_from1 => l_task_version_id
--          ,p_object_id_from2 => NULL
--          ,p_object_id_from3 => NULL
--          ,p_object_id_from4 => NULL
--          ,p_object_id_from5 => NULL
--          ,p_object_type_to => 'PA_TASKS'
--          ,p_object_id_to1 => l_info_task_ver_rec.task_version_id
--          ,p_object_id_to2 => NULL
--          ,p_object_id_to3 => NULL
--          ,p_object_id_to4 => NULL
--          ,p_object_id_to5 => NULL
--          ,p_relationship_type => 'L'
--          ,p_relationship_subtype => 'READ_WRITE'
--          ,p_lag_day => NULL
--          ,p_imported_lag => NULL
--          ,p_priority => NULL
--          ,p_pm_product_code => NULL
--          ,x_object_relationship_id => l_new_obj_rel_id
--          ,x_return_status => l_return_status
--          );
--dbms_output.put_line('Outgoing: From '||l_task_version_id||' To '||l_info_task_ver_rec.task_version_id);

/*****************************/
--dbms_output.put_line('close get_task_version_info');
--          CLOSE get_task_version_info;
--
--        END IF;
--
        --Check error
--        l_msg_count := FND_MSG_PUB.count_msg;
--        if (l_msg_count > 0) then
--          x_msg_count := l_msg_count;
--          if x_msg_count = 1 then
--            x_msg_data := l_msg_data;
--          end if;
--dbms_output.put_line('close get_task_versions_csr');
--          CLOSE get_task_versions_csr;
--dbms_output.put_line('close get_to_id');
--          CLOSE get_to_id;
--          raise FND_API.G_EXC_ERROR;
--        end if;
--
--      END LOOP;
--dbms_output.put_line('close get_to_id');
--      CLOSE get_to_id;


--      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
/* maansari
      IF (l_workplan_type = 'Y') THEN
--dbms_output.put_line('open get_ver_schedule_attr_csr');
        OPEN get_ver_schedule_attr_csr(l_task_versions_rec.element_version_id,
                                       l_task_versions_rec.project_id);
        FETCH get_ver_schedule_attr_csr INTO l_ver_sch_attr_rec;
--dbms_output.put_line('close get_ver_schedule_attr_csr');
        CLOSE get_ver_schedule_attr_csr;
*/ --maansari


/* hsiu: bug 2800553: commented for performance improvement
        -- xxlu added DFF attributes
        PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
        (p_validate_only           => FND_API.G_FALSE
        ,p_element_version_id      => l_task_version_id
        ,p_calendar_id             => l_ver_sch_attr_rec.calendar_id
        ,p_scheduled_start_date    => l_ver_sch_attr_rec.scheduled_start_date
        ,p_scheduled_end_date      => l_ver_sch_attr_rec.scheduled_finish_date
        ,p_obligation_start_date   => l_ver_sch_attr_rec.obligation_start_date
        ,p_obligation_end_date     => l_ver_sch_attr_rec.obligation_finish_date
        ,p_actual_start_date       => l_ver_sch_attr_rec.actual_start_date
        ,p_actual_finish_date      => l_ver_sch_attr_rec.actual_finish_date
        ,p_estimate_start_date     => l_ver_sch_attr_rec.estimated_start_date
        ,p_estimate_finish_date    => l_ver_sch_attr_rec.estimated_finish_date
        ,p_duration                => l_ver_sch_attr_rec.duration
        ,p_early_start_date        => l_ver_sch_attr_rec.early_start_date
        ,p_early_end_date          => l_ver_sch_attr_rec.early_finish_date
        ,p_late_start_date         => l_ver_sch_attr_rec.late_start_date
        ,p_late_end_date           => l_ver_sch_attr_rec.late_finish_date
        ,p_milestone_flag          => l_ver_sch_attr_rec.milestone_flag
        ,p_critical_flag           => l_ver_sch_attr_rec.critical_flag
        ,p_WQ_PLANNED_QUANTITY     => l_ver_sch_attr_rec.WQ_PLANNED_QUANTITY
        ,p_PLANNED_EFFORT          => l_ver_sch_attr_rec.PLANNED_EFFORT
        ,p_attribute_category        => l_ver_sch_attr_rec.attribute_category
        ,p_attribute1                => l_ver_sch_attr_rec.attribute1
        ,p_attribute2                => l_ver_sch_attr_rec.attribute2
        ,p_attribute3                => l_ver_sch_attr_rec.attribute3
        ,p_attribute4                => l_ver_sch_attr_rec.attribute4
        ,p_attribute5                => l_ver_sch_attr_rec.attribute5
        ,p_attribute6                => l_ver_sch_attr_rec.attribute6
        ,p_attribute7                => l_ver_sch_attr_rec.attribute7
        ,p_attribute8                => l_ver_sch_attr_rec.attribute8
        ,p_attribute9                => l_ver_sch_attr_rec.attribute9
        ,p_attribute10             => l_ver_sch_attr_rec.attribute10
        ,p_attribute11             => l_ver_sch_attr_rec.attribute11
        ,p_attribute12             => l_ver_sch_attr_rec.attribute12
        ,p_attribute13             => l_ver_sch_attr_rec.attribute13
        ,p_attribute14             => l_ver_sch_attr_rec.attribute14
        ,p_attribute15             => l_ver_sch_attr_rec.attribute15
        ,x_pev_schedule_id         => l_pev_schedule_id
        ,x_return_status           => l_return_status
        ,x_msg_count               => l_msg_count
        ,x_msg_data                  => l_msg_data );
       -- end xxlu changes
*/
--hsiu: bug 2800553: added for performance improvement
/* maansari commenting the following code and replacing it with bulk insert
       l_new_pev_schedule_id := NULL;
       PA_PROJ_ELEMENT_SCH_PKG.Insert_Row(
         X_ROW_ID                => X_Row_Id
        ,X_PEV_SCHEDULE_ID     => l_new_pev_schedule_id
        ,X_ELEMENT_VERSION_ID      => l_task_version_id
        ,X_PROJECT_ID            => l_ver_sch_attr_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID     => l_ver_sch_attr_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE  => l_ver_sch_attr_rec.SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE => l_ver_sch_attr_rec.SCHEDULED_FINISH_DATE
        ,X_OBLIGATION_START_DATE => l_ver_sch_attr_rec.OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE => l_ver_sch_attr_rec.OBLIGATION_FINISH_DATE
        ,X_ACTUAL_START_DATE        => l_ver_sch_attr_rec.ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE       => l_ver_sch_attr_rec.ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE   => l_ver_sch_attr_rec.ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE  => l_ver_sch_attr_rec.ESTIMATED_FINISH_DATE
        ,X_DURATION           => l_ver_sch_attr_rec.DURATION
        ,X_EARLY_START_DATE     => l_ver_sch_attr_rec.EARLY_START_DATE
        ,X_EARLY_FINISH_DATE        => l_ver_sch_attr_rec.EARLY_FINISH_DATE
        ,X_LATE_START_DATE      => l_ver_sch_attr_rec.LATE_START_DATE
        ,X_LATE_FINISH_DATE     => l_ver_sch_attr_rec.LATE_FINISH_DATE
        ,X_CALENDAR_ID            => l_ver_sch_attr_rec.CALENDAR_ID
        ,X_MILESTONE_FLAG       => l_ver_sch_attr_rec.MILESTONE_FLAG
        ,X_CRITICAL_FLAG        => l_ver_sch_attr_rec.CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY      => l_ver_sch_attr_rec.wq_planned_quantity
        ,X_PLANNED_EFFORT           => l_ver_sch_attr_rec.planned_effort
        ,X_ACTUAL_DURATION          => l_ver_sch_attr_rec.actual_duration
        ,X_ESTIMATED_DURATION       => l_ver_sch_attr_rec.estimated_duration
        ,X_ATTRIBUTE_CATEGORY               => l_ver_sch_attr_rec.ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1                       => l_ver_sch_attr_rec.ATTRIBUTE1
        ,X_ATTRIBUTE2                       => l_ver_sch_attr_rec.ATTRIBUTE2
        ,X_ATTRIBUTE3                       => l_ver_sch_attr_rec.ATTRIBUTE3
        ,X_ATTRIBUTE4                       => l_ver_sch_attr_rec.ATTRIBUTE4
        ,X_ATTRIBUTE5                       => l_ver_sch_attr_rec.ATTRIBUTE5
        ,X_ATTRIBUTE6                       => l_ver_sch_attr_rec.ATTRIBUTE6
        ,X_ATTRIBUTE7                       => l_ver_sch_attr_rec.ATTRIBUTE7
        ,X_ATTRIBUTE8                       => l_ver_sch_attr_rec.ATTRIBUTE8
        ,X_ATTRIBUTE9                       => l_ver_sch_attr_rec.ATTRIBUTE9
        ,X_ATTRIBUTE10                    => l_ver_sch_attr_rec.ATTRIBUTE10
        ,X_ATTRIBUTE11                    => l_ver_sch_attr_rec.ATTRIBUTE11
        ,X_ATTRIBUTE12                    => l_ver_sch_attr_rec.ATTRIBUTE12
        ,X_ATTRIBUTE13                    => l_ver_sch_attr_rec.ATTRIBUTE13
        ,X_ATTRIBUTE14                    => l_ver_sch_attr_rec.ATTRIBUTE14
        ,X_ATTRIBUTE15                    => l_ver_sch_attr_rec.ATTRIBUTE15
        ,X_SOURCE_OBJECT_ID               => l_ver_sch_attr_rec.PROJECT_ID
        ,X_SOURCE_OBJECT_TYPE             => 'PA_PROJECTS'
       );

       --Check if there is any error.
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         IF x_msg_count = 1 THEN
           x_msg_data := l_msg_data;
         END IF;
--dbms_output.put_line('close get_task_versions_csr');
         CLOSE get_task_versions_csr;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     l_last_wbs_level := l_task_versions_rec.wbs_level;
     l_outline_task_ref(l_task_versions_rec.wbs_level) := l_task_version_id;

--hsiu added for task version status
--label for not adding the task version in the published structure version.
    END IF; --for l_create_task_ver_flag
*/ --maansari

    END LOOP;
--dbms_output.put_line('close get_task_versions_csr');
    CLOSE get_task_versions_csr;

    --hsiu
    --changes for task status
    --tasks might be deleted because childs are also deleted when deleting
    -- a task
    l_del_task_cnt := 0;
    LOOP

      -- Bug # 4691749.
      -- EXIT when l_del_task_cnt = l_tbd_task_ver_id.count;
      EXIT when l_del_task_cnt = l_tbd_index;
      -- Bug # 4691749.

      l_del_task_cnt := l_del_task_cnt + 1;

      OPEN get_tbd_tasks_info(l_tbd_task_ver_id(l_del_task_cnt));
      FETCH get_tbd_tasks_info into l_tbd_tasks_info_rec;
      IF get_tbd_tasks_info%FOUND THEN
        PA_TASK_PVT1.Delete_Task_Ver_wo_val(
             p_structure_version_id  => l_tbd_tasks_info_rec.parent_structure_version_id
            ,p_task_version_id       => l_tbd_tasks_info_rec.element_version_id
            ,p_record_version_number => l_tbd_tasks_info_rec.record_version_number
            ,x_return_status         => l_return_status
            ,x_msg_count         => l_msg_count
            ,x_msg_data              => l_msg_data
        );

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := l_msg_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

      END IF;
      CLOSE get_tbd_tasks_info;
    END LOOP;
    --end changes for task status


    --hsiu: create schedule row for structure version after delete so that dates are rolledup properly.
--    IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN') = 'Y') THEN
    IF (l_workplan_type = 'Y') THEN
      --Get Schedule Version Info, if workplan type
      --dbms_output.put_line('9');
--dbms_output.put_line('open get_ver_schedule_attr_csr');
      OPEN get_ver_schedule_attr_csr(p_structure_version_id, l_project_id);
      FETCH get_ver_schedule_attr_csr INTO l_ver_sch_attr_rec;
--dbms_output.put_line('close get_ver_schedule_attr_csr');
      CLOSE get_ver_schedule_attr_csr;
      --dbms_output.put_line('10b');

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('create schedule version for struct');
      END IF;
      --Call Create_Schedule_Version if workplan type
/* hsiu: bug 2800553: commented for performance improvement
      PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
      ( p_validate_only           => FND_API.G_FALSE
       ,p_element_version_id      => l_new_struct_ver_id
       ,p_calendar_id             => l_ver_sch_attr_rec.calendar_id
       ,p_scheduled_start_date    => l_ver_sch_attr_rec.scheduled_start_date
       ,p_scheduled_end_date      => l_ver_sch_attr_rec.scheduled_finish_date
       ,p_obligation_start_date   => l_ver_sch_attr_rec.obligation_start_date
       ,p_obligation_end_date     => l_ver_sch_attr_rec.obligation_finish_date
       ,p_actual_start_date       => l_ver_sch_attr_rec.actual_start_date
       ,p_actual_finish_date      => l_ver_sch_attr_rec.actual_finish_date
       ,p_estimate_start_date     => l_ver_sch_attr_rec.estimated_start_date
       ,p_estimate_finish_date    => l_ver_sch_attr_rec.estimated_finish_date
       ,p_duration                => l_ver_sch_attr_rec.duration
       ,p_early_start_date        => l_ver_sch_attr_rec.early_start_date
       ,p_early_end_date          => l_ver_sch_attr_rec.early_finish_date
       ,p_late_start_date         => l_ver_sch_attr_rec.late_start_date
       ,p_late_end_date           => l_ver_sch_attr_rec.late_finish_date
       ,p_milestone_flag          => l_ver_sch_attr_rec.milestone_flag
       ,p_critical_flag           => l_ver_sch_attr_rec.critical_flag
       ,p_WQ_PLANNED_QUANTITY     => l_ver_sch_attr_rec.WQ_PLANNED_QUANTITY
       ,p_PLANNED_EFFORT          => l_ver_sch_attr_rec.PLANNED_EFFORT
       ,x_pev_schedule_id         => l_new_pev_schedule_id
       ,x_return_status           => l_return_status
       ,x_msg_count               => l_msg_count
       ,x_msg_data                  => l_msg_data );
*/
--hsiu: bug 2800553: added for performance improvement
      l_new_pev_schedule_id := NULL;
      PA_PROJ_ELEMENT_SCH_PKG.Insert_Row(
         X_ROW_ID                => X_Row_Id
        ,X_PEV_SCHEDULE_ID     => l_new_pev_schedule_id
        ,X_ELEMENT_VERSION_ID      => l_new_struct_ver_id
        ,X_PROJECT_ID            => l_ver_sch_attr_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID     => l_ver_sch_attr_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE  => l_ver_sch_attr_rec.SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE => l_ver_sch_attr_rec.SCHEDULED_FINISH_DATE
        ,X_OBLIGATION_START_DATE => l_ver_sch_attr_rec.OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE => l_ver_sch_attr_rec.OBLIGATION_FINISH_DATE
        ,X_ACTUAL_START_DATE        => l_ver_sch_attr_rec.ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE       => l_ver_sch_attr_rec.ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE   => l_ver_sch_attr_rec.ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE  => l_ver_sch_attr_rec.ESTIMATED_FINISH_DATE
        ,X_DURATION           => l_ver_sch_attr_rec.DURATION
        ,X_EARLY_START_DATE     => l_ver_sch_attr_rec.EARLY_START_DATE
        ,X_EARLY_FINISH_DATE        => l_ver_sch_attr_rec.EARLY_FINISH_DATE
        ,X_LATE_START_DATE      => l_ver_sch_attr_rec.LATE_START_DATE
        ,X_LATE_FINISH_DATE     => l_ver_sch_attr_rec.LATE_FINISH_DATE
        ,X_CALENDAR_ID            => l_ver_sch_attr_rec.CALENDAR_ID
        ,X_MILESTONE_FLAG       => l_ver_sch_attr_rec.MILESTONE_FLAG
        ,X_CRITICAL_FLAG        => l_ver_sch_attr_rec.CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY      => l_ver_sch_attr_rec.wq_planned_quantity
        ,X_PLANNED_EFFORT           => l_ver_sch_attr_rec.planned_effort
        ,X_ACTUAL_DURATION          => l_ver_sch_attr_rec.actual_duration
        ,X_ESTIMATED_DURATION       => l_ver_sch_attr_rec.estimated_duration
        ,X_ATTRIBUTE_CATEGORY               => l_ver_sch_attr_rec.ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1                       => l_ver_sch_attr_rec.ATTRIBUTE1
        ,X_ATTRIBUTE2                       => l_ver_sch_attr_rec.ATTRIBUTE2
        ,X_ATTRIBUTE3                       => l_ver_sch_attr_rec.ATTRIBUTE3
        ,X_ATTRIBUTE4                       => l_ver_sch_attr_rec.ATTRIBUTE4
        ,X_ATTRIBUTE5                       => l_ver_sch_attr_rec.ATTRIBUTE5
        ,X_ATTRIBUTE6                       => l_ver_sch_attr_rec.ATTRIBUTE6
        ,X_ATTRIBUTE7                       => l_ver_sch_attr_rec.ATTRIBUTE7
        ,X_ATTRIBUTE8                       => l_ver_sch_attr_rec.ATTRIBUTE8
        ,X_ATTRIBUTE9                       => l_ver_sch_attr_rec.ATTRIBUTE9
        ,X_ATTRIBUTE10                    => l_ver_sch_attr_rec.ATTRIBUTE10
        ,X_ATTRIBUTE11                    => l_ver_sch_attr_rec.ATTRIBUTE11
        ,X_ATTRIBUTE12                    => l_ver_sch_attr_rec.ATTRIBUTE12
        ,X_ATTRIBUTE13                    => l_ver_sch_attr_rec.ATTRIBUTE13
        ,X_ATTRIBUTE14                    => l_ver_sch_attr_rec.ATTRIBUTE14
        ,X_ATTRIBUTE15                    => l_ver_sch_attr_rec.ATTRIBUTE15
        ,X_SOURCE_OBJECT_ID               => l_ver_sch_attr_rec.PROJECT_ID
        ,X_SOURCE_OBJECT_TYPE             => 'PA_PROJECTS'
      );


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


--maansari
    --clear up global array
    PA_STRUCT_UPGR_PUB.clear_globals;

    INSERT INTO pa_proj_element_versions(
                     ELEMENT_VERSION_ID
                    ,PROJ_ELEMENT_ID
                    ,OBJECT_TYPE
                    ,PROJECT_ID
                    ,PARENT_STRUCTURE_VERSION_ID
                    ,DISPLAY_SEQUENCE
                    ,WBS_LEVEL
                    ,WBS_NUMBER
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,LAST_UPDATE_LOGIN
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
                     ,TASK_UNPUB_VER_STATUS_CODE
                    ,attribute15          --this column is used to store structure ver id of the source str to be used to created relationships.
            ,source_object_id
            ,source_object_type
                    ,financial_task_flag
                    )
                  SELECT
                     pa_proj_element_versions_s.nextval
                    ,ppev.proj_element_id
                    ,ppev.object_type
                    ,l_project_id
                    ,l_new_struct_ver_id
                    ,PA_STRUCT_UPGR_PUB.get_disp_sequence(ppev.display_sequence)
                    ,ppev.WBS_LEVEL
                    ,PA_STRUCT_UPGR_PUB.get_wbs_number(ppev.WBS_LEVEL, NULL)        -- Bug No. 4049574
                    ,SYSDATE
                    ,l_user_id
                    ,SYSDATE
                    ,l_user_id
                    ,l_login_id
                     ,ppev.RECORD_VERSION_NUMBER
                     ,ppev.ATTRIBUTE_CATEGORY
                     ,ppev.ATTRIBUTE1
                     ,ppev.ATTRIBUTE2
                     ,ppev.ATTRIBUTE3
                     ,ppev.ATTRIBUTE4
                     ,ppev.ATTRIBUTE5
                     ,ppev.ATTRIBUTE6
                     ,ppev.ATTRIBUTE7
                     ,ppev.ATTRIBUTE8
                     ,ppev.ATTRIBUTE9
                     ,ppev.ATTRIBUTE10
                     ,ppev.ATTRIBUTE11
                     ,ppev.ATTRIBUTE12
                     ,ppev.ATTRIBUTE13
                     ,ppev.ATTRIBUTE14
                     ,ppev.TASK_UNPUB_VER_STATUS_CODE
                     ,ppev.element_version_id
             ,l_project_id
             ,'PA_PROJECTS'
                     ,ppev.financial_task_flag
                  FROM ( SELECT * from pa_proj_element_versions ppev2
                  --,pa_proj_elements ppe  --bug 4573340        commenting out this for bug 4578813
                          WHERE --bug#3094283 ppev2.project_id = l_project_id
                            ppev2.parent_structure_version_id = p_structure_version_id
                            and ppev2.object_type = 'PA_TASKS'
                        /*
                         --bug 4573340
                            and ppe.project_id = ppev2.project_id
                            and ppe.proj_element_id = ppev2.proj_element_id
                            and ppe.link_task_flag = 'N'
                         --bug 4573340
                           */
                            and PA_PROJECT_STRUCTURE_PVT1.copy_task_version( p_structure_version_id,
                                                       ppev2.element_version_id ) = 'Y'
                           order by ppev2.display_sequence ) ppev
                    ;

                  /*   --cant write order by directly.
                  FROM pa_proj_element_versions ppev
                  WHERE ppev.project_id = l_project_id
                    and ppev.parent_structure_version_id = p_structure_version_id
                    and ppev.object_type = 'PA_TASKS'
                    and PA_PROJECT_STRUCTURE_PVT1.copy_task_version( p_structure_version_id,
                                                       ppev.element_version_id ) = 'Y'
                  order by ppev.display_sequence
                    ;
                   */

        -- Bug 4205167 : Added hint to use Hash Join
              INSERT INTO PA_OBJECT_RELATIONSHIPS (
                                  object_relationship_id,
                                  object_type_from,
                                  object_id_from1,
                                  object_type_to,
                                  object_id_to1,
                                  relationship_type,
                                  relationship_subtype,
                                  Record_Version_Number,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN,
                                  weighting_percentage
                                  )
                 SELECT /*+ USE_HASH(ppev2 ppev1)*/
                               pa_object_relationships_s.nextval,
                               pobj.object_type_from,
                               ppev1.element_version_id,
                               pobj.object_type_to,
                               ppev2.element_version_id,
                               pobj.relationship_type,
                               pobj.relationship_subtype,
                               pobj.Record_Version_Number,
                               l_user_id,
                               SYSDATE,
                               l_user_id,
                               SYSDATE,
                               l_login_id,
                               pobj.weighting_percentage
                    FROM ( SELECT  object_type_from, object_id_from1,
                                   object_type_to,   object_id_to1,
                                   relationship_type, relationship_subtype,
                                   Record_Version_Number, weighting_percentage
                             FROM pa_object_relationships
                   --bug#3094283         WHERE RELATIONSHIP_TYPE = 'S'
                             start with object_id_from1 = p_structure_version_id
                                and RELATIONSHIP_TYPE = 'S'  /* Bug 2881667 - Added this condition */
                             connect by  object_id_from1 =  prior object_id_to1
                                and RELATIONSHIP_TYPE = 'S' ) pobj,   /* Bug 2881667 - Added this condition */
                         pa_proj_element_versions ppev1,
                         pa_proj_element_versions ppev2
                 WHERE
                   --bug#3094283    ppev1.project_id = l_project_id
                   ppev1.attribute15 = pobj.object_id_from1
                   --bug#3094283 AND ppev2.project_id = l_project_id
                   AND ppev2.attribute15 = pobj.object_id_to1
                   and ppev1.parent_structure_version_id = l_new_struct_ver_id
                   and ppev2.parent_structure_version_id = l_new_struct_ver_id
                   ;


              INSERT INTO pa_proj_elem_ver_schedule(
                            PEV_SCHEDULE_ID
                           ,ELEMENT_VERSION_ID
                           ,PROJECT_ID
                           ,PROJ_ELEMENT_ID
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,SCHEDULED_START_DATE
                           ,SCHEDULED_FINISH_DATE
                           ,OBLIGATION_START_DATE
                           ,OBLIGATION_FINISH_DATE
                           ,ACTUAL_START_DATE
                           ,ACTUAL_FINISH_DATE
                           ,ESTIMATED_START_DATE
                           ,ESTIMATED_FINISH_DATE
                           ,DURATION
                           ,EARLY_START_DATE
                           ,EARLY_FINISH_DATE
                           ,LATE_START_DATE
                           ,LATE_FINISH_DATE
                           ,CALENDAR_ID
                           ,MILESTONE_FLAG
                           ,CRITICAL_FLAG
                           ,RECORD_VERSION_NUMBER
                           ,LAST_UPDATE_LOGIN
                           ,WQ_PLANNED_QUANTITY
                           ,PLANNED_EFFORT
                           ,ACTUAL_DURATION
                           ,ESTIMATED_DURATION
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
                           ,source_object_id
                           ,source_object_type
                           ,CONSTRAINT_TYPE_CODE
                           ,CONSTRAINT_DATE
                           ,FREE_SLACK
                           ,TOTAL_SLACK
                           ,EFFORT_DRIVEN_FLAG
                           ,LEVEL_ASSIGNMENTS_FLAG
                           ,EXT_ACT_DURATION
                           ,EXT_REMAIN_DURATION
                           ,EXT_SCH_DURATION
                           ,DEF_SCH_TOOL_TSK_TYPE_CODE -- 4295770 Added
                              )
                        SELECT
                            pa_proj_elem_ver_schedule_s.nextval
                           ,ppev1.ELEMENT_VERSION_ID
                           ,l_PROJECT_ID
                           ,ppev1.PROJ_ELEMENT_ID
                           ,SYSDATE
                           ,l_user_id
                           ,SYSDATE
                           ,l_user_id
                           ,ppevs.SCHEDULED_START_DATE
                           ,ppevs.SCHEDULED_FINISH_DATE
                           ,ppevs.OBLIGATION_START_DATE
                           ,ppevs.OBLIGATION_FINISH_DATE
                           ,ppevs.ACTUAL_START_DATE
                           ,ppevs.ACTUAL_FINISH_DATE
                           ,ppevs.ESTIMATED_START_DATE
                           ,ppevs.ESTIMATED_FINISH_DATE
                           ,ppevs.DURATION
                           ,ppevs.EARLY_START_DATE
                           ,ppevs.EARLY_FINISH_DATE
                           ,ppevs.LATE_START_DATE
                           ,ppevs.LATE_FINISH_DATE
                           ,ppevs.CALENDAR_ID
                           ,ppevs.MILESTONE_FLAG
                           ,ppevs.CRITICAL_FLAG
                           ,ppevs.RECORD_VERSION_NUMBER
                           ,l_login_id
                           ,ppevs.WQ_PLANNED_QUANTITY
                           ,ppevs.PLANNED_EFFORT
                           ,ppevs.ACTUAL_DURATION
                           ,ppevs.ESTIMATED_DURATION
                           ,ppevs.ATTRIBUTE_CATEGORY
                           ,ppevs.ATTRIBUTE1
                           ,ppevs.ATTRIBUTE2
                           ,ppevs.ATTRIBUTE3
                           ,ppevs.ATTRIBUTE4
                           ,ppevs.ATTRIBUTE5
                           ,ppevs.ATTRIBUTE6
                           ,ppevs.ATTRIBUTE7
                           ,ppevs.ATTRIBUTE8
                           ,ppevs.ATTRIBUTE9
                           ,ppevs.ATTRIBUTE10
                           ,ppevs.ATTRIBUTE11
                           ,ppevs.ATTRIBUTE12
                           ,ppevs.ATTRIBUTE13
                           ,ppevs.ATTRIBUTE14
                           ,ppevs.ATTRIBUTE15
                           ,l_PROJECT_ID
                           ,'PA_PROJECTS'
                           ,ppevs.CONSTRAINT_TYPE_CODE
                           ,ppevs.CONSTRAINT_DATE
                           ,ppevs.FREE_SLACK
                           ,ppevs.TOTAL_SLACK
                           ,ppevs.EFFORT_DRIVEN_FLAG
                           ,ppevs.LEVEL_ASSIGNMENTS_FLAG
                           ,ppevs.EXT_ACT_DURATION
                           ,ppevs.EXT_REMAIN_DURATION
                           ,ppevs.EXT_SCH_DURATION
                           ,ppevs.DEF_SCH_TOOL_TSK_TYPE_CODE -- 4295770 Added
                         FROM pa_proj_elem_ver_schedule ppevs,
                              pa_proj_element_versions ppev1
                           where ppev1.attribute15 = ppevs.element_version_id
                            and  ppevs.project_id = l_project_id
                            and  ppev1.project_id = l_project_id
                            and  ppev1.parent_structure_version_id = l_new_struct_ver_id
                            and  ppev1.object_type = 'PA_TASKS';

    ---------------------------------------------- FP_M changes: Begin
    -- Refer to tracking bug 3305199
    -- Populate the old and new task version ID in PL/SQL tables

    Select Element_Version_ID, ATTRIBUTE15  Bulk Collect
    INTO   l_New_Task_Versions_Tab, l_Old_Task_Versions_Tab
    From   pa_proj_element_versions
    Where  parent_structure_version_id = l_new_struct_ver_id
    and    object_type = 'PA_TASKS'
    and    PA_PROJECT_STRUCTURE_PVT1.copy_task_version( l_new_struct_ver_id, element_version_id ) = 'Y'
        order by display_sequence;

--bug 4019845
--comment starts here
/*
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

        PA_RELATIONSHIP_PVT.Publish_Inter_Proj_Dep (  -- This API needs to be called
        p_publishing_struc_ver_id => p_structure_version_id,
        p_previous_pub_struc_ver_id => l_last_pub_str_ver_id,
        p_published_struc_ver_id => l_new_struct_ver_id,
        X_Return_Status      => X_Return_Status,
        X_Msg_Count          => X_Msg_Count,
        X_Msg_Data           => X_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/

        /* Smukka 01/03/2004 Bug No.3450684                                            */
        /* Added call to PA_RELATIONSHIP_PVT.Copy_OG_Lnk_For_Subproj_Ass        */
        /* And PA_RELATIONSHIP_PVT.Move_CI_Lnk_For_subproj_step1 API calls to   */
        /* copy all the out going and coming in sub project assoications               */
/*
        PA_RELATIONSHIP_PVT.Copy_OG_Lnk_For_Subproj_Ass(
                                      p_validate_only           =>  p_validate_only,
                                      p_validation_level        =>  p_validation_level,
                                      p_calling_module          =>  p_calling_module,
                                      p_debug_mode              =>  p_debug_mode,
                                      p_max_msg_count           =>  p_max_msg_count,
                                      p_commit                  =>  p_commit,
                                      p_src_str_version_id      =>  p_structure_version_id,
                                      p_dest_str_version_id     =>  l_new_struct_ver_id,  -- Destination Str version id can be of published str also
                                      x_return_status           =>  X_Return_Status,
                                      x_msg_count               =>  X_Msg_Count,
                                      x_msg_data                =>  X_Msg_Data);
        IF (X_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
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
        PA_RELATIONSHIP_PVT.Move_CI_Lnk_For_subproj_step1(
                                      p_api_version    =>   p_api_version,
                                      p_init_msg_list      =>   p_init_msg_list,
                                      p_validate_only      =>   p_validate_only,
                                      p_validation_level   =>   p_validation_level,
                                      p_calling_module     =>   p_calling_module,
                                      p_commit             =>   p_commit,
                                      p_debug_mode     =>   p_debug_mode,
                                      p_max_msg_count      =>   p_max_msg_count,
                                      p_src_str_version_id      =>   p_structure_version_id,
                                      p_pub_str_version_id      =>   l_new_struct_ver_id,
                                      p_last_pub_str_version_id =>   l_last_pub_str_ver_id,
                                      x_return_status           =>  x_return_status,
                                      x_msg_count               =>  x_msg_count,
                                      x_msg_data                =>  x_msg_data);

    --------------------------------------------- FP_M changes: End
*/
--end bug 4019845

  update pa_proj_element_versions ppevs1
     set attribute15 = ( select attribute15 from pa_proj_element_versions ppevs2
                          where ppevs2.project_id = l_project_id
                            and parent_structure_version_id = p_structure_version_id
                            and ppevs2.element_version_id = ppevs1.attribute15
                             )
   where project_id = l_project_id
    and parent_structure_version_id = l_new_struct_ver_id;

--maansari

    --This has to be done at the end because creating latest version before
    --  updating links will break the logic for updating to latest published
    --  version.

    --Call Create Structure Version Attr
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
     ( p_validate_only               => FND_API.G_FALSE
      ,p_structure_version_id        => l_new_struct_ver_id
      ,p_structure_version_name      => l_new_struct_ver_name
      ,p_structure_version_desc      => l_new_struct_ver_desc
      ,p_effective_date              => l_struc_ver_attr_rec.effective_date
      ,p_latest_eff_published_flag   => 'Y'
      ,p_published_flag              => 'Y'
      ,p_locked_status_code          => 'UNLOCK'
      ,p_struct_version_status_code  => 'STRUCTURE_PUBLISHED'
      ,p_baseline_current_flag       => l_current_baseline_flag
      ,p_baseline_original_flag      => l_original_baseline_flag
      ,p_change_reason_code          => l_struc_ver_attr_rec.change_reason_code
      ,x_pev_structure_id            => l_new_pev_structure_id
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data );


    l_msg_count := FND_MSG_PUB.count_msg;
    if (l_msg_count > 0) then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

--bug 4019845
/*
    --bug 3047602: rollup dates
    OPEN get_all_new_childs(l_new_struct_ver_id);
    FETCH get_all_new_childs bulk collect into l_task_ver_ids_tbl;
    CLOSE get_all_new_childs;

update pa_proj_elem_ver_structure
   set status_code = 'STRUCTURE_WORKING',
       LOCKED_BY_PERSON_ID = (select locked_by_person_id
                                from pa_proj_elem_ver_structure
                               where project_id = l_project_id
                                 and element_version_id = p_structure_version_id),
       LOCK_STATUS_CODE = 'LOCKED'
 where project_id = l_project_id and element_version_id = l_new_struct_ver_id;

       --3755117 for copying mapping
       BEGIN
         PA_PROJ_STRUC_MAPPING_PUB.copy_mapping(
           p_context             => 'PUBLISH_VERSION'
          ,p_src_project_id      => l_project_id
          ,p_dest_project_id     => l_project_id
          ,p_src_str_version_id  => p_structure_version_id
          ,p_dest_str_version_id => l_new_struct_ver_id
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
         );

         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                           p_procedure_name => 'PUBLISH_STRUCTURE',
                                           p_error_text     => SUBSTRB('PA_PROJ_STRUC_MAPPING_PUB.COPY_MAPPING:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END;
*/
--end bug 4019845

       -- Changes added by skannoji
       -- Added code for doosan customer
         /* Bug #: 3305199 SMukka                                                         */
         /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
         /* src_versions_tab   PA_PLSQL_DATATYPES.IdTabTyp;                               */
         /* dest_versions_tab  PA_PLSQL_DATATYPES.IdTabTyp;                               */
--bug 4019845
/*
       Declare
         src_versions_tab   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
         dest_versions_tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
         prev_pub_tab       SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); --bug 3847386
       Begin
         src_versions_tab.extend(1);
         dest_versions_tab.extend(1);
         src_versions_tab(1)  := p_structure_version_id;
         dest_versions_tab(1) :=  l_new_struct_ver_id;
         prev_pub_tab.extend(1);   --bug 3847386
         prev_pub_tab(1) := l_last_pub_str_ver_id;   --bug 3847386
         -- Copies budget versions, resource assignments and budget lines as required for the workplan version.
         --Smukka Bug No. 3474141 Date 03/01/2004
         --moved PA_FP_COPY_FROM_PKG.copy_wp_budget_versions into plsql block
         BEGIN
             PA_FP_COPY_FROM_PKG.copy_wp_budget_versions
              (
                p_source_project_id            => l_project_id
               ,p_target_project_id            => l_project_id
               ,p_src_sv_ids_tbl               => src_Versions_Tab
               ,p_target_sv_ids_tbl            => dest_Versions_Tab
               ,p_copy_act_from_str_ids_tbl    => prev_pub_tab --bug 3847386
               ,x_return_status                => x_return_status
               ,x_msg_count                    => x_msg_count
               ,x_Msg_data                     => x_msg_data
              );
          EXCEPTION
              WHEN OTHERS THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                           p_procedure_name => 'PUBLISH_STRUCTURE',
                                           p_error_text     => SUBSTRB('PA_FP_COPY_FROM_PKG.copy_wp_budget_versions:'||SQLERRM,1,240));
              RAISE FND_API.G_EXC_ERROR;
          END;
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
       End;
       -- till here by skannoji
*/
--end bug 4019845


/* Removed for bug 3850488.
       BEGIN
         PA_TASK_ASSIGNMENTS_PVT.Copy_Missing_Unplanned_Asgmts(
            p_project_id => l_project_id
           ,p_old_structure_version_id => l_last_pub_str_ver_id
           ,p_new_structure_version_id => l_new_struct_ver_id
           ,x_msg_count => x_msg_count
           ,x_msg_data => x_msg_data
           ,x_return_status => x_return_status
         );
       EXCEPTION
         WHEN OTHERS THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                           p_procedure_name => 'PUBLISH_STRUCTURE',
                                           p_error_text     => SUBSTRB('PA_FP_COPY_FROM_PKG.copy_missing_unplanned_asgmts:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END;
       If (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
*/

/* --hsiu: no need to rollup since the copied structure version is already rolled-up
    IF l_task_ver_ids_tbl.count > 0 THEN
      --rollup dates for new published version

      PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
                       p_commit => FND_API.G_FALSE,
                       p_element_versions => l_task_ver_ids_tbl,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

      l_msg_count := FND_MSG_PUB.count_msg;
      if (l_msg_count > 0) then
        x_msg_count := l_msg_count;
        if x_msg_count = 1 then
          x_msg_data := l_msg_data;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    END IF;
    --end bug 3047602
*/
--    error_msg('before progress report');


--      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_new_struct_ver_id, 'FINANCIAL') = 'Y') THEN

--bug 4019845
/*
      IF (l_financial_type = 'Y') THEN

    select start_date, completion_date
    into l_proj_start_date, l_proj_completion_date
    from pa_projects_all
    where project_id = l_project_id;

    --dbms_output.put_line('sycn up api');
    --Call sync-up API
--    error_msg('import task');

    PA_XC_PROJECT_PUB.import_task
      ( p_project_id               => l_project_id
      ,p_task_reference            => NULL
      ,p_task_name                 => NULL
      ,p_task_start_date           => NULL
      ,p_task_end_date             => NULL
      ,p_parent_task_reference     => NULL
      ,p_task_number               => NULL
      ,p_wbs_level                 => NULL
      ,p_milestone                 => NULL
      ,p_duration                  => NULL
      ,p_duration_unit             => NULL
      ,p_early_start_date          => NULL
      ,p_early_finish_date         => NULL
      ,p_late_start_date           => NULL
      ,p_late_finish_date          => NULL
      ,p_display_seq               => NULL
      ,p_login_user_name           => NULL
      ,p_critical_path             => NULL
      ,p_sub_project_id            => NULL
      ,p_attribute7                => NULL
      ,p_attribute8                => NULL
      ,p_attribute9                => NULL
      ,p_attribute10               => NULL
      ,p_progress_report           => NULL
      ,p_progress_status           => NULL
      ,p_progress_comments         => NULL
      ,p_progress_asof_date        => NULL
      ,p_predecessors              => NULL
      ,p_structure_version_id      => l_new_struct_ver_id
      ,p_calling_mode              => 'PUBLISH' );

    l_i_msg_count := 0;
--    error_msg('import project');
    PA_XC_PROJECT_PUB.import_project
      (p_user_id                   => l_user_id
      ,p_commit                    => 'N'
      ,p_debug_mode                => p_debug_mode
      ,p_project_id                => l_project_id
      ,p_project_mpx_start_date    => fnd_date.date_to_canonical(l_proj_start_date)
      ,p_project_mpx_end_date      => fnd_date.date_to_canonical(l_proj_completion_date)
      ,p_task_mgr_override         => NULL
      ,p_task_pgs_override         => NULL
      ,p_process_id                => NULL
      ,p_language                  => NULL
      ,p_delimiter                 => NULL
      ,p_responsibility_id         => p_responsibility_id
      ,p_structure_id              => NULL
      ,p_structure_version_id      => l_new_struct_ver_id
      ,p_calling_mode              => 'PUBLISH'
      ,x_msg_count                 => l_i_msg_count
      ,x_msg_data                  => l_i_msg_data
      ,x_return_status             => l_i_return_status);


--dbms_output.put_line('import proj: '||l_i_return_status);
    --Check for error
--    IF (x_msg_count > 0) THEN
--      FOR i IN 1..x_msg_count LOOP
--        PA_UTILS.ADD_MESSAGE('PA',l_i_msg_data(i));
--      END LOOP;
--    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
--        x_msg_data := l_msg_data;
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

    END IF; --for checking structure type
*/
--bug 4019845


/*  removed
    IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_new_struct_ver_id, 'WORKPLAN') = 'Y') THEN
      --API for progress report.
*/
/*  removed
      PA_PROGRESS_PUB.CREATE_PROGRESS_FOR_WBS(
        p_commit               => FND_API.G_FALSE
       ,p_project_id           => l_project_id
       ,p_structure_version_id => l_new_struct_ver_id
       ,x_return_status        => l_return_status
       ,x_msg_count            => l_msg_count
       ,x_msg_data             => l_msg_data
      );
*/
/*  removed
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('progress report api');
      END IF;


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
*/

--bug 4019845
/*
--bug 3830932
--moving before copy project dates so that latest structure version will be selected in the API
update pa_proj_elem_ver_structure
   set status_code = 'STRUCTURE_PUBLISHED',
       LOCKED_BY_PERSON_ID = NULL,
       LOCK_STATUS_CODE = 'UNLOCKED'
 where project_id = l_project_id and element_version_id = l_new_struct_ver_id;
--end bug 3830932

-- anlee
-- Dates changes
--    IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(l_new_struct_ver_id, 'WORKPLAN') = 'Y') THEN
    IF (l_workplan_type = 'Y') THEN
      OPEN get_scheduled_dates(l_project_id, l_new_struct_ver_id);
      FETCH get_scheduled_dates INTO l_scheduled_start_date, l_scheduled_finish_date;
      CLOSE get_scheduled_dates;

      OPEN get_proj_rec_ver_number(l_project_id);
      FETCH get_proj_rec_ver_number INTO l_proj_record_ver_number;
      CLOSE get_proj_rec_ver_number;

      PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
        p_validate_only          => FND_API.G_FALSE
       ,p_project_id             => l_project_id
       ,p_date_type              => 'SCHEDULED'
       ,p_start_date             => l_scheduled_start_date
       ,p_finish_date            => l_scheduled_finish_date
       ,p_record_version_number  => l_proj_record_ver_number
       ,x_return_status          => l_return_status
       ,x_msg_count              => l_msg_count
       ,x_msg_data               => l_msg_data );

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
-- End of changes

-- hsiu
-- project dates changes
-- copy dates to transaction dates if 1, share structure
--                                    2, auto task update is enabled
--   IF ((PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(l_proj_element_id, 'WORKPLAN') = 'Y') AND
--      (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(l_proj_element_id, 'FINANCIAL') = 'Y')) THEN
   IF ((l_workplan_type = 'Y') AND
      (l_financial_type = 'Y')) THEN
     --select workplan attr
     IF (PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_proj_element_id) = 'Y') THEN
       --Copy to transaction date
       PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES(
         p_project_id => l_project_id,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data
       );

       if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
         x_msg_count := FND_MSG_PUB.count_msg;
         if x_msg_count = 1 then
           x_msg_data := l_msg_data;
         end if;
         raise FND_API.G_EXC_ERROR;
       end if;

     END IF;
   END IF;
-- end of changes
*/
--end bug 4019845

--bug 4019845
/*
   --hsiu: task status
   --push down and rollup
   PA_STRUCT_TASK_ROLLUP_PUB.Task_Stat_Pushdown_Rollup(
          p_structure_version_id => l_new_struct_ver_id
         ,x_return_status => x_return_status
         ,x_msg_count => x_msg_count
         ,x_msg_data => x_msg_data
        );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   --end task status changes
*/
--end bug 4019845

/* remove
   --hsiu: prorate tasks for tasks that have to be deleted peer tasks
   l_parent_ver_id := l_parent_tbl.FIRST;
   FOR i IN 1..l_parent_tbl.COUNT LOOP
     --if it has child then prorate
--     IF (PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(l_parent_ver_id) = 'N') THEN
       OPEN is_summary_elem(l_parent_ver_id);
       FETCH is_summary_elem INTO l_dummy;
       IF is_summary_elem%FOUND THEN
         PA_TASK_PVT1.RECALC_TASKS_WEIGHTING(
              p_task_version_id => l_parent_ver_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data);
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           CLOSE is_summary_elem;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
       CLOSE is_summary_elem;
--     END IF;
     l_parent_ver_id := l_parent_tbl.NEXT(l_parent_ver_id);
   END LOOP;
*/

/* --moved before copying tasks
    --hsiu
    --changes for task status
    --tasks might be deleted because childs are also deleted when deleting
    -- a task
    l_del_task_cnt := 0;
    LOOP
      EXIT when l_del_task_cnt = l_tbd_task_ver_id.count;
      l_del_task_cnt := l_del_task_cnt + 1;

      OPEN get_tbd_tasks_info(l_tbd_task_ver_id(l_del_task_cnt));
      FETCH get_tbd_tasks_info into l_tbd_tasks_info_rec;
      IF get_tbd_tasks_info%FOUND THEN
        PA_TASK_PVT1.Delete_Task_Ver_wo_val(
             p_structure_version_id  => l_tbd_tasks_info_rec.parent_structure_version_id
            ,p_task_version_id       => l_tbd_tasks_info_rec.element_version_id
            ,p_record_version_number => l_tbd_tasks_info_rec.record_version_number
            ,x_return_status         => l_return_status
            ,x_msg_count         => l_msg_count
            ,x_msg_data              => l_msg_data
        );

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := l_msg_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

      END IF;
      CLOSE get_tbd_tasks_info;
    END LOOP;
    --end changes for task status
*/

    --Change the status of the working version to 'STRUCTURE_WORKING'
    update PA_PROJ_ELEM_VER_STRUCTURE
    set status_code = 'STRUCTURE_WORKING',
        record_version_number = nvl(record_version_number,0)+1
    where pev_structure_id = l_pev_structure_id;


--bug 4479392
--Update the wbs_flag for the working version as well.
      PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG(
                               p_project_id => l_project_id,
                               p_structure_version_id => p_structure_version_id,
                               p_update_wbs_flag => 'Y',
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data
                             );
      If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        x_msg_count := FND_MSG_PUB.count_msg;
        if x_msg_count = 1 then
          x_msg_data := l_msg_data;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

--end bug 4479392

    --bug 3035902
    --Change the process flag of the published structure version to Y if
    --the working version is set to Y
    --Bug No 3450684 SMukka Commented if condition
    --IF (PA_PROJECT_STRUCTURE_UTILS.GET_UPDATE_WBS_FLAG(l_project_id,
      --  p_structure_version_id) = 'Y') THEN
      --set the flag for the published version
      PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG(
                               p_project_id => l_project_id,
                               p_structure_version_id => l_new_struct_ver_id,
                               p_update_wbs_flag => 'Y',
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data
                             );
      If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        x_msg_count := FND_MSG_PUB.count_msg;
        if x_msg_count = 1 then
          x_msg_data := l_msg_data;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    --END IF;
    --end bug 3035902

--bug 4019845
/*
 -- Added this for FP_M changes -- Bhumesh
  PA_PROGRESS_PUB.Pull_Summarized_Actuals (
     P_Project_ID       =>  l_Project_ID
    ,p_Calling_Mode     =>  'PUBLISH'
    ,x_return_status    =>  x_return_status
    ,x_msg_count        =>  x_msg_count
    ,x_msg_data         =>  x_msg_data
  );

  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
  end if;

IF p_pub_prog_flag = 'Y' THEN
  PA_PROGRESS_PUB.Publish_Progress(
     p_project_id               => l_Project_ID
    --,p_structure_version_id     => p_structure_version_id -- Bug 3839288
    ,p_pub_structure_version_id   => l_new_struct_ver_id  -- Bug 3839288
    ,x_upd_new_elem_ver_id_flag   => l_upd_new_elem_ver_id_flag -- added by rtarway for BUG 3951024
    ,x_as_of_date         => l_as_of_date -- Bug 3839288
    ,x_task_weight_basis_code     => l_task_weight_basis_code -- Bug 3839288
    ,x_return_status        => x_return_status
    ,x_msg_count            => x_msg_count
    ,x_msg_data             => x_msg_data
  );

  if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
  end if;

END IF;
*/
--end bug 4019845

 -- End

    IF l_debug_mode = 'Y' THEN
        pa_debug.write('PA_PROJECT_STRUCTURE_PVT1.PUBLISH_STRUCTURE', 'Before opening sel_other_structure_ver p_structure_version_id='||p_structure_version_id, 3);
    END IF;

    --hsiu
    --changes for advanced structure
    --Delete other working structures after publishing
    OPEN sel_other_structure_ver(p_structure_version_id);
    LOOP
      FETCH sel_other_structure_ver into l_del_struc_ver_id, l_del_struc_ver_rvn;
      EXIT WHEN sel_other_structure_ver%NOTFOUND;

    IF l_debug_mode = 'Y' THEN
        pa_debug.write('PA_PROJECT_STRUCTURE_PVT1.PUBLISH_STRUCTURE', 'Before calling PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_wo_val', 3);
        pa_debug.write('PA_PROJECT_STRUCTURE_PVT1.PUBLISH_STRUCTURE', 'l_del_struc_ver_id='||l_del_struc_ver_id||' l_del_struc_ver_rvn='||l_del_struc_ver_rvn, 3);
    END IF;

      PA_PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_wo_val(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_del_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
            );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;

    IF l_debug_mode = 'Y' THEN
        pa_debug.write('PA_PROJECT_STRUCTURE_PVT1.PUBLISH_STRUCTURE', 'After calling PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_wo_val l_return_status='||l_return_status||' l_msg_count='||l_msg_count, 3);
    END IF;

      IF l_msg_count > 0  OR l_return_status ='E' THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        CLOSE sel_other_structure_ver;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE sel_other_structure_ver;
    --end changes


    x_published_struct_ver_id := l_new_struct_ver_id;

    --bug 3010538
    IF (p_calling_module = 'SELF_SERVICE') THEN
      --called separately if calling from AMG
      PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP(
        p_calling_context => 'PUBLISH',
        p_project_id => l_project_id,
--        p_structure_version_id => l_last_pub_str_ver_id,   --SMukka Commented
        p_structure_version_id => p_structure_version_id,   --Smukka Added line
        p_pub_struc_ver_id => l_new_struct_ver_id,
        p_pub_prog_flag => p_pub_prog_flag,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
      );

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
    --end bug 3010538

--bug 4019845
/*
    -- BUg 3627315 Issue 8 : Added following call
    --The follwoing api is called to push progress data to PJI for the new
    --structure version.
    BEGIN
         --bug 3822112
         if l_share_flag = 'Y'
         then
            l_copy_actuals_flag := 'N';
         end if;
    PA_PROGRESS_PUB.COPY_PROGRESS_ACT_ETC(
           p_project_id               => l_Project_ID
          ,p_src_str_ver_id           => p_structure_version_id
          ,p_dst_str_ver_id           => l_new_struct_ver_id
          ,p_pub_wp_with_prog_flag    => p_pub_prog_flag
          ,p_calling_context          => 'PUBLISH'
          ,p_copy_actuals_flag        => l_copy_actuals_flag    --bug 3822112
          ,p_last_pub_str_version_id  => l_last_pub_str_ver_id -- Modified rakragha 28-JUL-2004
          ,x_return_status            => x_return_status
          ,x_msg_count                => x_msg_count
          ,x_msg_data                 => x_msg_data
          );
    EXCEPTION
      WHEN OTHERS THEN
          fnd_msg_pub.add_exc_msg(p_pkg_name       =>
            'PA_PROJECT_STRUCTURE_PVT1',
                    p_procedure_name => 'publish_structure',
                    p_error_text     => SUBSTRB('Call PA_PROGRESS_PUB.COPY_PROGRESS_ACT_ETC:'||SQLERRM,1,120));
                   RAISE FND_API.G_EXC_ERROR;
    END;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;
*/
--bug 4019845


--bug 4019845
/*
    -- Bug 3839288 Begin
    IF p_pub_prog_flag = 'Y' AND l_as_of_date IS NOT NULL
    THEN
    BEGIN

        pa_progress_pub.populate_pji_tab_for_plan(
             p_init_msg_list    => FND_API.G_FALSE
            ,p_commit       => FND_API.G_FALSE
            --,p_calling_module => p_calling_module
            ,p_project_id       => l_Project_ID
            ,p_structure_version_id => l_new_struct_ver_id
            ,p_baselined_str_ver_id => PA_PROJECT_STRUCTURE_UTILS.Get_Baseline_Struct_Ver(l_Project_ID)
            ,p_structure_type       => 'WORKPLAN'
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            );
    EXCEPTION
        WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       =>
                'PA_PROJECT_STRUCTURE_PVT1',
                    p_procedure_name => 'publish_structure',
                    p_error_text     => SUBSTRB('Call pa_progress_pub.populate_pji_tab_for_plan:'||SQLERRM,1,120));
            RAISE FND_API.G_EXC_ERROR;
    END;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;

    BEGIN
           PA_PROGRESS_PUB.ROLLUP_PROGRESS_PVT(
                 p_init_msg_list             => FND_API.G_FALSE
            --,p_calling_module      => p_calling_module
                ,p_commit                    => FND_API.G_FALSE
                --,p_validate_only             => p_validate_only
                ,p_project_id                => l_Project_ID
                ,p_structure_version_id      => l_new_struct_ver_id
                ,p_as_of_date                => l_as_of_date
                ,p_wp_rollup_method          => l_task_weight_basis_code
                ,p_rollup_entire_wbs         => 'Y'
                ,p_working_wp_prog_flag      => 'N'
                ,p_upd_new_elem_ver_id_flag  => l_upd_new_elem_ver_id_flag --rtarway, 3951024
                ,x_return_status             => x_return_status
                ,x_msg_count                 => x_msg_count
                ,x_msg_data                  => x_msg_data);
    EXCEPTION
        WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       =>
                'PA_PROJECT_STRUCTURE_PVT1',
                    p_procedure_name => 'publish_structure',
                    p_error_text     => SUBSTRB('Call PA_PROGRESS_PUB.ROLLUP_PROGRESS_PVT:'||SQLERRM,1,120));
            RAISE FND_API.G_EXC_ERROR;
    END;


    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;

       END IF;
    -- Bug 3839288 End
*/
--end bug 4019845

--bug 4019845
/*
    IF p_pub_prog_flag = 'Y'
    THEN
  --bug 3851528
        BEGIN
           PA_PROGRESS_UTILS.clear_prog_outdated_flag(
                 p_project_id                => l_Project_ID
                ,p_structure_version_id      => l_new_struct_ver_id
                ,p_object_id                 => null
                ,p_object_type               => null
                ,x_return_status             => x_return_status
                ,x_msg_count                 => x_msg_count
                ,x_msg_data                  => x_msg_data);
        EXCEPTION
                WHEN OTHERS THEN
                        fnd_msg_pub.add_exc_msg(p_pkg_name       =>
                                'PA_PROJECT_STRUCTURE_PVT1',
                                        p_procedure_name => 'publish_structure',
                                        p_error_text     => SUBSTRB('Call PA_PROGRESS_UTILS.clear_prog_outdated_flag:'||SQLERRM,1,120));
                        RAISE FND_API.G_EXC_ERROR;
        END;


        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_msg_count := FND_MSG_PUB.count_msg;
                IF x_msg_count = 1 THEN
                        x_msg_data := l_msg_data;
                END IF;
                raise FND_API.G_EXC_ERROR;
        END IF;
  --bug 3851528

    END IF; -- p_pub_prog_flag = 'Y' THEN
*/
--end bug 4019845

    -- Start Bug : 4096218
    IF p_calling_module = 'AMG' THEN
            /* 4096218 Commenting , as we have changed the global varray name to G_DELETED_TASK_IDS_FROM_OP
                       and now we are expected to pass the varray of 'to be deleted' task projelementids ,
               not version ids.
            PA_PROJECT_PUB.G_DELETED_TASK_VER_IDS_FROM_OP := l_tbd_task_ver_id;
        */
        PA_PROJECT_PUB.G_DELETED_TASK_IDS_FROM_OP := l_tbd_task_id;
    END IF;
    -- End Bug : 4096218

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.PUBLISH_STRUCTURE end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to publish_structure_pvt;
      else
         --need to rollback because generate error page performs a commit
         rollback;
      end if;
      --get errors
      FOR i IN 1..FND_MSG_PUB.COUNT_MSG LOOP
        FND_MSG_PUB.GET(p_encoded=>'F',
                        p_data=>l_messages(i),
                        p_msg_index_out => l_msg_index_out);
      END LOOP;

      --create error clob
      PA_PROJECT_STRUCTURE_PVT1.Generate_Error_Page(
        p_structure_version_id => p_structure_version_id,
        p_error_tbl            => l_messages,
        x_page_content_id      => l_page_content_id,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data
      );

      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to publish_structure_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'PUBLISH_STRUCTURE',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to publish_structure_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'PUBLISH_STRUCTURE',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Publish_Structure;


-- API name                      : UPDATE_LATEST_PUB_LINKS
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_orig_project_id                   IN  NUMBER
--   p_orig_structure_id                 IN  NUMBER
--   p_orig_struc_ver_id                 IN  NUMBER
--   p_orig_task_ver_id                  IN  NUMBER
--   p_new_project_id                    IN  NUMBER
--   p_new_structure_id                  IN  NUMBER
--   p_new_struc_ver_id                  IN  NUMBER
--   p_new_task_ver_id                   IN  NUMBER
--   x_return_status     OUT     VARCHAR2
--   x_msg_count     OUT     NUMBER
--   x_msg_data  OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU              -Created
--
--


  procedure UPDATE_LATEST_PUB_LINKS
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_orig_project_id                   IN  NUMBER
   ,p_orig_structure_id                 IN  NUMBER
   ,p_orig_struc_ver_id                 IN  NUMBER
   ,p_orig_task_ver_id                  IN  NUMBER
   ,p_new_project_id                    IN  NUMBER
   ,p_new_structure_id                  IN  NUMBER
   ,p_new_struc_ver_id                  IN  NUMBER
   ,p_new_task_ver_id                   IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    cursor get_from_id(c_element_version_id NUMBER) IS
      select object_relationship_id, object_id_from1 object_id_from,
             object_type_from, record_version_number
        from pa_object_relationships
       where relationship_type = 'L'
         and object_id_to1 = c_element_version_id
         and object_type_to IN ('PA_TASKS','PA_STRUCTURES');
    l_from_object_info        get_from_id%ROWTYPE;

    cursor get_task_version_info(c_task_version_id NUMBER) IS
      select v1.project_id project_id, v2.proj_element_id structure_id,
             v1.parent_structure_version_id structure_version_id,
             v1.element_version_id task_version_id
        from pa_proj_element_versions v1,
             pa_proj_element_versions v2
       where v1.element_version_id = c_task_version_id
         and v1.parent_structure_version_id = v2.element_version_id;
    l_info_task_ver_rec       get_task_version_info%ROWTYPE;

    cursor get_structure_version_info(c_structure_version_id NUMBER) IS
      select v1.project_id project_id, v1.proj_element_id structure_id,
             v1.element_version_id structure_version_id
        from pa_proj_element_versions v1
       where v1.element_version_id = c_structure_version_id;
    l_info_struc_ver_rec      get_structure_version_info%ROWTYPE;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_orig_element_version_id       NUMBER;

    l_object_type                   VARCHAR2(30);

    cursor get_latest_struc_ver(c_struc_ver_id NUMBER) IS
      select pevs.element_version_id
        from pa_proj_element_versions pev,
             pa_proj_elem_ver_structure pevs
       where pev.element_version_id = c_struc_ver_id
         and pev.project_id = pevs.project_id
         and pev.proj_element_id = pevs.proj_element_id
         and pevs.latest_eff_published_flag = 'Y';

    cursor get_latest_task_ver(c_task_ver_id NUMBER) IS
      select pev2.element_version_id task_version_id,
             pev2.parent_structure_version_id parent_structure_version_id
        from pa_proj_element_versions pev,
             pa_proj_element_versions pev1,
             pa_proj_elem_ver_structure pevs,
             pa_proj_element_versions pev2
       where pev.element_version_id = c_task_ver_id
         and pev.parent_structure_version_id = pev1.element_version_id
         and pev1.project_id = pevs.project_id
         and pev1.proj_element_id = pevs.proj_element_id
         and pevs.latest_eff_published_flag = 'Y'
         and pev.proj_element_id = pev2.proj_element_id
         and pev.project_id = pev2.project_id
         and pev2.parent_structure_version_id = pevs.element_version_id;

    cursor can_update(c_element_version_id NUMBER) IS
      select '1'
        from pa_proj_elem_ver_structure pevs,
             pa_proj_element_versions pev
       where pev.element_version_id = c_element_version_id
         and pev.parent_structure_version_id = pevs.element_version_id
         and pev.project_id = pevs.project_id
         and pevs.status_code IN ('STRUCTURE_WORKING', 'STRUCTURE_REJECTED');
    l_dummy  VARCHAR2(1);

    l_latest_elem_ver               NUMBER;
    l_latest_parent_struc_ver       NUMBER;

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_LATEST_PUB_LINKS begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_latest_pub_links_pvt;
    END IF;

    IF p_orig_task_ver_id IS NULL THEN
      l_object_type := 'PA_STRUCTURES';
      l_orig_element_version_id := p_orig_struc_ver_id;
    ELSE
      l_object_type := 'PA_TASKS';
      l_orig_element_version_id := p_orig_task_ver_id;
    END IF;

--    error_msg('in update latest pub links');
    --Search for the element version in the latest published version
    --  that has a link point to it, and corresponds to the original
    --  element.
    IF (l_object_type = 'PA_STRUCTURES') THEN
      --Get the published element
--dbms_output.put_line('b, Open get_latest_struc_ver');
      OPEN get_latest_struc_ver(l_orig_element_version_id);
      FETCH get_latest_struc_ver INTO l_latest_elem_ver;
      IF get_latest_struc_ver%NOTFOUND THEN
        --no publish version. exit;
        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('No latest published version found');
        END IF;
--dbms_output.put_line('b, Close get_latest_struc_ver');
        CLOSE get_latest_struc_ver;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
      END IF;
      l_latest_parent_struc_ver := l_latest_elem_ver;
--dbms_output.put_line('b, Close get_latest_struc_ver');
      CLOSE get_latest_struc_ver;
    ELSIF (l_object_type = 'PA_TASKS') THEN
--dbms_output.put_line('b, Open get_latest_task_ver');
      OPEN get_latest_task_ver(l_orig_element_version_id);
      FETCH get_latest_task_ver INTO l_latest_elem_ver,
                                     l_latest_parent_struc_ver;
      IF get_latest_task_ver%NOTFOUND THEN
        --no publish version. exit;
        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('No latest published version found');
        END IF;
--dbms_output.put_line('b, Close get_latest_task_ver');
        CLOSE get_latest_task_ver;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
      END IF;
--dbms_output.put_line('b, Close get_latest_task_ver');
      CLOSE get_latest_task_ver;
    END IF;

    --For the element, find all the element versions that links to
    --  the publish version which belongs to a working version.

    --Search for incoming links for the latest pub element
--dbms_output.put_line('b, Open get_from_id');
    OPEN get_from_id(l_latest_elem_ver);
    LOOP
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('getting incoming links');
      END IF;
      FETCH get_from_id INTO l_from_object_info;
      EXIT WHEN get_from_id%NOTFOUND;

--dbms_output.put_line('b, Open can_update');
      OPEN can_update(l_from_object_info.object_id_from);
      FETCH can_update INTO l_dummy;
      IF (can_update%FOUND) THEN
--dbms_output.put_line('can update found');
        --the from object is a working/rejected version. Need to update
        IF (l_from_object_info.object_type_from = 'PA_STRUCTURES') THEN

--dbms_output.put_line('b, Open get_structure_version_info');
          OPEN get_structure_version_info(l_from_object_info.object_id_from);
          FETCH get_structure_version_info INTO l_info_struc_ver_rec;
          PA_RELATIONSHIP_PVT.Update_Relationship(
            p_init_msg_list => FND_API.G_FALSE
           ,p_commit => FND_API.G_FALSE
           ,p_debug_mode => p_debug_mode
           ,p_object_relationship_id    => l_from_object_info.object_relationship_id
           ,p_project_id_from           => l_info_struc_ver_rec.project_id
           ,p_structure_id_from         => l_info_struc_ver_rec.structure_id
           ,p_structure_version_id_from => l_info_struc_ver_rec.structure_version_id
           ,p_task_version_id_from      => NULL
           ,p_project_id_to             => p_new_project_id
           ,p_structure_id_to           => p_new_structure_id
           ,p_structure_version_id_to   => p_new_struc_ver_id
           ,p_task_version_id_to        => p_new_task_ver_id
           ,p_relationship_type         => 'L'
           ,p_relationship_subtype      => 'READ_WRITE'
           ,p_record_version_number     => l_from_object_info.record_version_number
           ,x_return_status             => l_return_status
           ,x_msg_count                 => l_msg_count
           ,x_msg_data                  => l_msg_data
          );
--dbms_output.put_line('b, Close get_structure_version_info');
          CLOSE get_structure_version_info;

        ELSIF (l_from_object_info.object_type_from = 'PA_TASKS') THEN
--dbms_output.put_line('b, Open get_task_version_info');
          OPEN get_task_version_info(l_from_object_info.object_id_from);
          FETCH get_task_version_info INTO l_info_task_ver_rec;
          PA_RELATIONSHIP_PVT.Update_Relationship(
            p_init_msg_list => FND_API.G_FALSE
           ,p_commit => FND_API.G_FALSE
           ,p_debug_mode => p_debug_mode
           ,p_object_relationship_id    => l_from_object_info.object_relationship_id
           ,p_project_id_from           => l_info_task_ver_rec.project_id
           ,p_structure_id_from         => l_info_task_ver_rec.structure_id
           ,p_structure_version_id_from => l_info_task_ver_rec.structure_version_id
           ,p_task_version_id_from      => l_info_task_ver_rec.task_version_id
           ,p_project_id_to             => p_new_project_id
           ,p_structure_id_to           => p_new_structure_id
           ,p_structure_version_id_to   => p_new_struc_ver_id
           ,p_task_version_id_to        => p_new_task_ver_id
           ,p_relationship_type         => 'L'
           ,p_relationship_subtype      => 'READ_WRITE'
           ,p_record_version_number     => l_from_object_info.record_version_number
           ,x_return_status             => l_return_status
           ,x_msg_count                 => l_msg_count
           ,x_msg_data                  => l_msg_data
          );
--dbms_output.put_line('b, Close get_task_version_info');
          CLOSE get_task_version_info;

        END IF;
      END IF;
--dbms_output.put_line('b, Close can_update');
      CLOSE can_update;
    END LOOP;
--dbms_output.put_line('b, Close get_from_id');
    CLOSE get_from_id;


    l_msg_count := FND_MSG_PUB.count_msg;
    if (l_msg_count > 0) then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_latest_pub_links_pvt;
      end if;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_latest_pub_links_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'UPDATE_LATEST_PUB_LINKS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_latest_pub_links_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'UPDATE_LATEST_PUB_LINKS',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END UPDATE_LATEST_PUB_LINKS;


PROCEDURE COPY_STRUCTURE_VERSION
( p_commit                        IN VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2   := 'N'
 ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
 ,p_structure_version_id          IN NUMBER
 ,p_new_struct_ver_name           IN VARCHAR2
 ,p_new_struct_ver_desc           IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,x_new_struct_ver_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_new_struct_ver_id             PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_pev_structure_id              NUMBER;

  CURSOR l_get_structure_ver_csr(c_structure_version_id NUMBER)
  IS
  SELECT *
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = c_structure_version_id;

  l_structure_ver_rec       l_get_structure_ver_csr%ROWTYPE;
  l_structure_ver_to_rec    l_get_structure_ver_csr%ROWTYPE;

  CURSOR l_get_structure_ver_attr_csr(c_structure_version_id NUMBER)
  IS
  SELECT a.*
  FROM PA_PROJ_ELEM_VER_STRUCTURE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.element_version_id = c_structure_version_id
  AND   b.project_id = a.project_id
  AND   b.element_version_id = a.project_id;

  l_structure_ver_attr_rec       l_get_structure_ver_attr_csr%ROWTYPE;

  CURSOR l_get_task_versions_csr(c_structure_version_id NUMBER)
  IS
  SELECT a.element_version_id, a.proj_element_id, a.display_sequence, a.wbs_level,
         b.object_id_from1 parent_element_version_id,
         a.TASK_UNPUB_VER_STATUS_CODE
  FROM PA_PROJ_ELEMENT_VERSIONS a,
       PA_OBJECT_RELATIONSHIPS b
  WHERE a.object_type = 'PA_TASKS'
  AND   a.parent_structure_version_id = c_structure_version_id
  AND   a.element_version_id = b.object_id_to1
  AND   b.relationship_type = 'S'
  AND   b.object_type_from in ('PA_STRUCTURES','PA_TASKS') -- Bug 6429275
  AND   b.object_type_to = 'PA_TASKS'
  ORDER BY a.display_sequence;

  l_task_versions_rec        l_get_task_versions_csr%ROWTYPE;
  l_ref_task_ver_id          NUMBER;
  l_peer_or_sub              VARCHAR2(10);

  CURSOR l_get_ver_schedule_attr_csr(c_element_version_id NUMBER)
  IS
  SELECT a.*
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.element_version_id = c_element_version_id
  AND b.project_id = a.project_id
  AND b.element_version_id = a.element_version_id;

  l_ver_schedule_attr_rec       l_get_ver_schedule_attr_csr%ROWTYPE;

  TYPE reference_tasks IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

--Bug 2189657
--Added for linking tasks with no display sequence.
  Type T_EquivElemVerTable IS TABLE OF NUMBER
      Index by BINARY_INTEGER;
  t_equiv_elem_ver_id T_EquivElemVerTable;
--Bug 2189657 end;


  -- This table stores reference task version IDs for a particular wbs
  -- level. This provides a lookup to find the last task version
  -- at that level.
  l_outline_task_ref reference_tasks;

  l_last_wbs_level          NUMBER;
  l_task_version_id         NUMBER;
  l_pev_schedule_id         NUMBER;

  CURSOR l_get_structure_type_csr(c_structure_version_id NUMBER)
  IS
  SELECT pst.structure_type_class_code
  FROM   PA_STRUCTURE_TYPES pst,
         PA_PROJ_ELEMENT_VERSIONS ppev,
         PA_PROJ_STRUCTURE_TYPES ppst
  WHERE  ppev.element_version_id = c_structure_version_id
  AND    ppev.proj_element_id = ppst.proj_element_id
  AND    ppst.structure_type_id = pst.structure_type_id;

  l_structure_type          PA_STRUCTURE_TYPES.structure_type%TYPE;

  CURSOR l_check_working_versions_csr(c_structure_version_id NUMBER)
  IS
  SELECT 'Y'
  FROM  PA_PROJ_ELEMENT_VERSIONS ppev
  WHERE ppev.element_version_id = c_structure_version_id
  AND   EXISTS
        (SELECT 'Y'
         FROM   PA_PROJ_ELEMENT_VERSIONS ppev2,
                PA_PROJ_ELEM_VER_STRUCTURE ppevs
         WHERE  ppev2.proj_element_id = ppev.proj_element_id
         AND    ppev2.project_id = ppev.project_id
         AND    ppevs.project_id = ppev2.project_id
         AND    ppevs.element_version_id = ppev2.element_version_id
         AND    ppevs.status_code <> 'STRUCTURE_PUBLISHED');

  l_dummy                   VARCHAR2(1);

  cursor get_to_id(c_element_version_id NUMBER) IS
      select object_relationship_id, object_id_to1 object_id_to,
             object_type_to, record_version_number
        from pa_object_relationships
       where relationship_type = 'L'
         and object_id_from1 = c_element_version_id
         and object_type_from IN ('PA_TASKS','PA_STRUCTURES');
    l_to_object_info          get_to_id%ROWTYPE;

    cursor get_task_version_info(c_task_version_id NUMBER) IS
      select v1.project_id project_id, v2.proj_element_id structure_id,
             v1.parent_structure_version_id structure_version_id,
             v1.element_version_id task_version_id
        from pa_proj_element_versions v1,
             pa_proj_element_versions v2
       where v1.element_version_id = c_task_version_id
         and v1.parent_structure_version_id = v2.element_version_id;
    l_info_task_ver_rec       get_task_version_info%ROWTYPE;

    l_new_obj_rel_id          PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;
    l_structure_type1         PA_STRUCTURE_TYPES.structure_type_class_code%TYPE;

--hsiu
--added for task weighting
    CURSOR get_cur_task_ver_weighting(c_ver_id NUMBER) IS
     select WEIGHTING_PERCENTAGE
       from pa_object_relationships
      where object_id_to1 = c_ver_id
        and object_type_to = 'PA_TASKS'
        and relationship_type = 'S';
    l_weighting               NUMBER(17,2);

--end task weighting changes

   X_Row_id  VARCHAR2(255);
BEGIN

  pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE_VERSION');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE_VERSION begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint copy_structure_version_pvt;
  END IF;

  -- Get structure version info
  OPEN l_get_structure_ver_csr(p_structure_version_id);
  FETCH l_get_structure_ver_csr INTO l_structure_ver_rec;
  CLOSE l_get_structure_ver_csr;

  PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
  ( p_validate_only         => p_validate_only
   ,p_structure_id          => l_structure_ver_rec.proj_element_id
   ,p_attribute_category    => l_structure_ver_rec.attribute_category
   ,p_attribute1            => l_structure_ver_rec.attribute1
   ,p_attribute2            => l_structure_ver_rec.attribute2
   ,p_attribute3            => l_structure_ver_rec.attribute3
   ,p_attribute4            => l_structure_ver_rec.attribute4
   ,p_attribute5            => l_structure_ver_rec.attribute5
   ,p_attribute6            => l_structure_ver_rec.attribute6
   ,p_attribute7            => l_structure_ver_rec.attribute7
   ,p_attribute8            => l_structure_ver_rec.attribute8
   ,p_attribute9            => l_structure_ver_rec.attribute9
   ,p_attribute10           => l_structure_ver_rec.attribute10
   ,p_attribute11           => l_structure_ver_rec.attribute11
   ,p_attribute12           => l_structure_ver_rec.attribute12
   ,p_attribute13           => l_structure_ver_rec.attribute13
   ,p_attribute14           => l_structure_ver_rec.attribute14
   ,p_attribute15           => l_structure_ver_rec.attribute15
   ,x_structure_version_id  => l_new_struct_ver_id
   ,x_return_status         => l_return_status
   ,x_msg_count             => l_msg_count
   ,x_msg_data              => l_msg_data );

  If (p_debug_mode = 'Y') THEN
    pa_debug.debug('Create Structure Version return status: ' || l_return_status);
    pa_debug.debug('l_new_struct_ver_id: ' || l_new_struct_ver_id);
  END IF;


  --Check if there is any error.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    IF x_msg_count = 1 THEN
      x_msg_data := l_msg_data;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   -- Get structure version attributes
  OPEN l_get_structure_ver_attr_csr(p_structure_version_id);
  FETCH l_get_structure_ver_attr_csr INTO l_structure_ver_attr_rec;
  CLOSE l_get_structure_ver_attr_csr;

  If (p_change_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
    l_structure_ver_attr_rec.change_reason_code := p_change_reason_code;
  END IF;

  PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
  ( p_validate_only               => FND_API.G_FALSE
   ,p_structure_version_id        => l_new_struct_ver_id
   ,p_structure_version_name      => p_new_struct_ver_name
   ,p_structure_version_desc      => p_new_struct_ver_desc
   ,p_effective_date              => l_structure_ver_attr_rec.effective_date
   ,p_latest_eff_published_flag   => l_structure_ver_attr_rec.latest_eff_published_flag
   ,p_locked_status_code          => l_structure_ver_attr_rec.lock_status_code
   ,p_struct_version_status_code  => l_structure_ver_attr_rec.status_code
   ,p_baseline_current_flag       => l_structure_ver_attr_rec.current_flag
   ,p_baseline_original_flag      => l_structure_ver_attr_rec.original_flag
   ,p_change_reason_code          => l_structure_ver_attr_rec.change_reason_code
   ,x_pev_structure_id            => l_pev_structure_id
   ,x_return_status               => l_return_status
   ,x_msg_count                   => l_msg_count
   ,x_msg_data                    => l_msg_data );

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('Create Structure Version Attr return status: ' || l_return_status);
    pa_debug.debug('l_pev_structure_id: ' || l_pev_structure_id);
  END IF;

  --Check if there is any error.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    IF x_msg_count = 1 THEN
      x_msg_data := l_msg_data;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Search for outgoing links for the structure version; create new Links
/*
  OPEN get_to_id(p_structure_version_id);
  LOOP
    FETCH get_to_id INTO l_to_object_info;
    EXIT WHEN get_to_id%NOTFOUND;
    If (l_to_object_info.object_type_to = 'PA_STRUCTURES') THEN
      OPEN l_get_structure_ver_csr(l_to_object_info.object_id_to);
      FETCH l_get_structure_ver_csr INTO l_structure_ver_to_rec;

      SELECT pst.structure_type_class_code
      INTO l_structure_type1
      FROM PA_STRUCTURE_TYPES pst,
           PA_PROJ_STRUCTURE_TYPES ppst
      WHERE ppst.proj_element_id = l_structure_ver_to_rec.proj_element_id
      AND   pst.structure_type_id = ppst.structure_type_id;

      PA_RELATIONSHIP_PVT.Create_Relationship(
         p_init_msg_list                => FND_API.G_FALSE
        ,p_commit                       => FND_API.G_FALSE
        ,p_debug_mode                   => p_debug_mode
        ,p_project_id_from              => l_structure_ver_rec.project_id
        ,p_structure_id_from            => l_structure_ver_rec.proj_element_id
        ,p_structure_version_id_from    => l_new_struct_ver_id
        ,p_task_version_id_from         => NULL
        ,p_project_id_to                => l_structure_ver_to_rec.project_id
        ,p_structure_id_to              => l_structure_ver_to_rec.proj_element_id
        ,p_structure_version_id_to      => l_structure_ver_to_rec.element_version_id
        ,p_task_version_id_to           => NULL
        ,p_structure_type               => l_structure_type1
        ,p_initiating_element           => NULL
        ,p_link_to_latest_structure_ver => NULL
        ,p_relationship_type            => 'L'
        ,p_relationship_subtype         => 'READ_WRITE'
        ,x_object_relationship_id       => l_new_obj_rel_id
        ,x_return_status                => l_return_status
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                     => l_msg_data
      );
      CLOSE l_get_structure_ver_csr;

      IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Create Relationship return status: ' || l_return_status);
       pa_debug.debug('l_new_obj_rel_id: ' || l_new_obj_rel_id);
      END IF;
    ELSIF(l_to_object_info.object_type_to = 'PA_TASKS') THEN
      OPEN get_task_version_info(l_to_object_info.object_id_to);
      FETCH get_task_version_info INTO l_info_task_ver_rec;

      SELECT pst.structure_type_class_code
      INTO l_structure_type1
      FROM PA_STRUCTURE_TYPES pst,
           PA_PROJ_STRUCTURE_TYPES ppst
      WHERE ppst.proj_element_id = l_info_task_ver_rec.structure_id
      AND   pst.structure_type_id = ppst.structure_type_id;

      PA_RELATIONSHIP_PVT.Create_Relationship(
         p_init_msg_list                => FND_API.G_FALSE
        ,p_commit                       => FND_API.G_FALSE
        ,p_debug_mode                   => p_debug_mode
        ,p_project_id_from              => l_structure_ver_rec.project_id
        ,p_structure_id_from            => l_structure_ver_rec.proj_element_id
        ,p_structure_version_id_from    => l_new_struct_ver_id
        ,p_task_version_id_from         => NULL
        ,p_project_id_to                => l_info_task_ver_rec.project_id
        ,p_structure_id_to              => l_info_task_ver_rec.structure_id
        ,p_structure_version_id_to      => l_info_task_ver_rec.structure_version_id
        ,p_task_version_id_to           => l_info_task_ver_rec.task_version_id
        ,p_structure_type               => l_structure_type1
        ,p_initiating_element           => NULL
        ,p_link_to_latest_structure_ver => NULL
        ,p_relationship_type            => 'L'
        ,p_relationship_subtype         => 'READ_WRITE'
        ,x_object_relationship_id       => l_new_obj_rel_id
        ,x_return_status                => l_return_status
        ,x_msg_count                    => l_msg_count
        ,x_msg_data                     => l_msg_data
      );
      CLOSE get_task_version_info;
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Create Relationship return status: ' || l_return_status);
        pa_debug.debug('l_new_obj_rel_id: ' || l_new_obj_rel_id);
      END IF;
    END IF;
    --Check error
    l_msg_count := FND_MSG_PUB.count_msg;
    if (l_msg_count > 0) then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      CLOSE get_to_id;
      raise FND_API.G_EXC_ERROR;
    end if;

  END LOOP;
  CLOSE get_to_id;
*/


  OPEN l_get_structure_type_csr(p_structure_version_id);
  FETCH l_get_structure_type_csr INTO l_structure_type;
  CLOSE l_get_structure_type_csr;

  -- If structure is workplan type create schedule version record
  if l_structure_type = 'WORKPLAN' then

    OPEN l_get_ver_schedule_attr_csr(p_structure_version_id);
    FETCH l_get_ver_schedule_attr_csr INTO l_ver_schedule_attr_rec;
    CLOSE l_get_ver_schedule_attr_csr;

/*
    PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
    ( p_validate_only           => FND_API.G_FALSE
     ,p_element_version_id      => l_new_struct_ver_id
     ,p_calendar_id             => l_ver_schedule_attr_rec.calendar_id
     ,p_scheduled_start_date    => l_ver_schedule_attr_rec.scheduled_start_date
     ,p_scheduled_end_date      => l_ver_schedule_attr_rec.scheduled_finish_date
     ,p_obligation_start_date   => l_ver_schedule_attr_rec.obligation_start_date
     ,p_obligation_end_date     => l_ver_schedule_attr_rec.obligation_finish_date
     ,p_actual_start_date       => l_ver_schedule_attr_rec.actual_start_date
     ,p_actual_finish_date      => l_ver_schedule_attr_rec.actual_finish_date
     ,p_estimate_start_date     => l_ver_schedule_attr_rec.estimated_start_date
     ,p_estimate_finish_date    => l_ver_schedule_attr_rec.estimated_finish_date
     ,p_duration                => l_ver_schedule_attr_rec.duration
     ,p_early_start_date        => l_ver_schedule_attr_rec.early_start_date
     ,p_early_end_date          => l_ver_schedule_attr_rec.early_finish_date
     ,p_late_start_date         => l_ver_schedule_attr_rec.late_start_date
     ,p_late_end_date           => l_ver_schedule_attr_rec.late_finish_date
     ,p_milestone_flag          => l_ver_schedule_attr_rec.milestone_flag
     ,p_critical_flag           => l_ver_schedule_attr_rec.critical_flag
     ,p_WQ_PLANNED_QUANTITY     => l_ver_schedule_attr_rec.WQ_PLANNED_QUANTITY
     ,p_PLANNED_EFFORT          => l_ver_schedule_attr_rec.PLANNED_EFFORT
     ,x_pev_schedule_id         => l_pev_schedule_id
     ,x_return_status           => l_return_status
     ,x_msg_count           => l_msg_count
     ,x_msg_data            => l_msg_data );
*/
    l_pev_schedule_id := NULL;
    PA_PROJ_ELEMENT_SCH_PKG.Insert_Row(
         X_ROW_ID                => X_Row_Id
        ,X_PEV_SCHEDULE_ID     => l_pev_schedule_id
        ,X_ELEMENT_VERSION_ID      => l_new_struct_ver_id
        ,X_PROJECT_ID            => l_ver_schedule_attr_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID     => l_ver_schedule_attr_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE  => l_ver_schedule_attr_rec.SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE => l_ver_schedule_attr_rec.SCHEDULED_FINISH_DATE
        ,X_OBLIGATION_START_DATE => l_ver_schedule_attr_rec.OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE => l_ver_schedule_attr_rec.OBLIGATION_FINISH_DATE
        ,X_ACTUAL_START_DATE        => l_ver_schedule_attr_rec.ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE       => l_ver_schedule_attr_rec.ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE   => l_ver_schedule_attr_rec.ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE  => l_ver_schedule_attr_rec.ESTIMATED_FINISH_DATE
        ,X_DURATION           => l_ver_schedule_attr_rec.DURATION
        ,X_EARLY_START_DATE     => l_ver_schedule_attr_rec.EARLY_START_DATE
        ,X_EARLY_FINISH_DATE        => l_ver_schedule_attr_rec.EARLY_FINISH_DATE
        ,X_LATE_START_DATE      => l_ver_schedule_attr_rec.LATE_START_DATE
        ,X_LATE_FINISH_DATE     => l_ver_schedule_attr_rec.LATE_FINISH_DATE
        ,X_CALENDAR_ID            => l_ver_schedule_attr_rec.CALENDAR_ID
        ,X_MILESTONE_FLAG       => l_ver_schedule_attr_rec.MILESTONE_FLAG
        ,X_CRITICAL_FLAG        => l_ver_schedule_attr_rec.CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY      => l_ver_schedule_attr_rec.wq_planned_quantity
        ,X_PLANNED_EFFORT           => l_ver_schedule_attr_rec.planned_effort
        ,X_ACTUAL_DURATION          => l_ver_schedule_attr_rec.actual_duration
        ,X_ESTIMATED_DURATION       => l_ver_schedule_attr_rec.estimated_duration
        ,X_ATTRIBUTE_CATEGORY               => l_ver_schedule_attr_rec.ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1                       => l_ver_schedule_attr_rec.ATTRIBUTE1
        ,X_ATTRIBUTE2                       => l_ver_schedule_attr_rec.ATTRIBUTE2
        ,X_ATTRIBUTE3                       => l_ver_schedule_attr_rec.ATTRIBUTE3
        ,X_ATTRIBUTE4                       => l_ver_schedule_attr_rec.ATTRIBUTE4
        ,X_ATTRIBUTE5                       => l_ver_schedule_attr_rec.ATTRIBUTE5
        ,X_ATTRIBUTE6                       => l_ver_schedule_attr_rec.ATTRIBUTE6
        ,X_ATTRIBUTE7                       => l_ver_schedule_attr_rec.ATTRIBUTE7
        ,X_ATTRIBUTE8                       => l_ver_schedule_attr_rec.ATTRIBUTE8
        ,X_ATTRIBUTE9                       => l_ver_schedule_attr_rec.ATTRIBUTE9
        ,X_ATTRIBUTE10                    => l_ver_schedule_attr_rec.ATTRIBUTE10
        ,X_ATTRIBUTE11                    => l_ver_schedule_attr_rec.ATTRIBUTE11
        ,X_ATTRIBUTE12                    => l_ver_schedule_attr_rec.ATTRIBUTE12
        ,X_ATTRIBUTE13                    => l_ver_schedule_attr_rec.ATTRIBUTE13
        ,X_ATTRIBUTE14                    => l_ver_schedule_attr_rec.ATTRIBUTE14
        ,X_ATTRIBUTE15                    => l_ver_schedule_attr_rec.ATTRIBUTE15
        ,X_SOURCE_OBJECT_ID               => l_ver_schedule_attr_rec.PROJECT_ID
        ,X_SOURCE_OBJECT_TYPE             => 'PA_PROJECTS'
    );


    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Create Schedule Version return status: ' || l_return_status);
      pa_debug.debug('l_pev_schedule_id: ' || l_pev_schedule_id);
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF l_structure_type in ('FINANCIAL') then
    -- There can only be one working version any any time for a financial structure
    OPEN l_check_working_versions_csr(p_structure_version_id);
    FETCH l_check_working_versions_csr INTO l_dummy;
    if l_check_working_versions_csr%FOUND then
      CLOSE l_check_working_versions_csr;
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_WORKING_VER_EXISTS');
      x_msg_data := 'PA_PS_WORKING_VER_EXISTS';
      RAISE FND_API.G_EXC_ERROR;
    end if;
    CLOSE l_check_working_versions_csr;
  end if;

  -- Fetch all task versions for this structure version
  OPEN l_get_task_versions_csr(p_structure_version_id);

  l_last_wbs_level := null;

  LOOP
    FETCH l_get_task_versions_csr INTO l_task_versions_rec;
    EXIT WHEN l_get_task_versions_csr%NOTFOUND;

    if l_last_wbs_level is null then
      -- first task version being created
      -- This task should have wbs level = 1
      l_ref_task_ver_id := l_new_struct_ver_id; --p_structure_version_id;
      l_peer_or_sub := 'SUB';
    else
      if l_task_versions_rec.wbs_level > l_last_wbs_level then
        l_ref_task_ver_id := l_outline_task_ref(l_last_wbs_level);
        l_peer_or_sub := 'SUB';
      else
        l_ref_task_ver_id := l_outline_task_ref(l_task_versions_rec.wbs_level);
        l_peer_or_sub := 'PEER';
      end if;
    end if;

--Bug 2189657
--Added for linking tasks with no display sequence.
--Set correct reference and parent element version id
      If (l_task_versions_rec.display_sequence IS NULL) THEN
        IF (l_ref_task_ver_id <> l_new_struct_ver_id) THEN
          --A task has already been created. Reference task must be a task
          IF (l_task_versions_rec.parent_element_version_id = p_structure_version_id) THEN
            --this is a link to the structure version. A task has already been created.
            --need to use a top level task as peer reference task
            l_peer_or_sub := 'PEER';
            l_ref_task_ver_id := l_outline_task_ref(1);
          ELSE
            --this is a link to a task.
            l_peer_or_sub := 'SUB';
            l_ref_task_ver_id := t_equiv_elem_ver_id(l_task_versions_rec.parent_element_version_id);
          END IF;
        ELSE
          --No task has been created. Reference task is structure
          l_peer_or_sub := 'SUB';
          l_ref_task_ver_id := l_new_struct_ver_id;
--          l_ref_task_ver_id := t_equiv_elem_ver_id(l_task_versions_rec.parent_element_version_id);
        END IF;
      END IF;
--Bug 2189657 end;
    OPEN get_cur_task_ver_weighting(l_task_versions_rec.element_version_id);
    FETCH get_cur_task_ver_weighting INTO l_weighting;
    CLOSE get_cur_task_ver_weighting;

    PA_TASK_PVT1.CREATE_TASK_VERSION
    ( p_validate_only        => FND_API.G_FALSE
     ,p_validation_level     => 0
     ,p_ref_task_version_id  => l_ref_task_ver_id
     ,p_peer_or_sub          => l_peer_or_sub
     ,p_task_id              => l_task_versions_rec.proj_element_id
     ,p_WEIGHTING_PERCENTAGE => l_weighting
     ,p_TASK_UNPUB_VER_STATUS_CODE => l_task_versions_rec.TASK_UNPUB_VER_STATUS_CODE
     ,x_task_version_id      => l_task_version_id
     ,x_return_status        => l_return_status
     ,x_msg_count            => l_msg_count
     ,x_msg_data             => l_msg_data);

    t_equiv_elem_ver_id(l_task_versions_rec.element_version_id) := l_task_version_id;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Create Task Version return status: ' || l_return_status);
      pa_debug.debug('l_task_version_id: ' || l_task_version_id);
      pa_debug.debug('l_msg_count: ' || l_msg_count);
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    if l_structure_type = 'WORKPLAN' then
      -- Get task version schedule attributes
      OPEN l_get_ver_schedule_attr_csr(l_task_versions_rec.element_version_id);
      FETCH l_get_ver_schedule_attr_csr INTO l_ver_schedule_attr_rec;
      CLOSE l_get_ver_schedule_attr_csr;

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Before Create Schedule Version');
      END IF;
      -- xxlu added DFF attributes
/*      PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
      ( p_validate_only           => FND_API.G_FALSE
       ,p_element_version_id      => l_task_version_id
       ,p_calendar_id             => l_ver_schedule_attr_rec.calendar_id
       ,p_scheduled_start_date    => l_ver_schedule_attr_rec.scheduled_start_date
       ,p_scheduled_end_date      => l_ver_schedule_attr_rec.scheduled_finish_date
       ,p_obligation_start_date   => l_ver_schedule_attr_rec.obligation_start_date
       ,p_obligation_end_date     => l_ver_schedule_attr_rec.obligation_finish_date
       ,p_actual_start_date       => l_ver_schedule_attr_rec.actual_start_date
       ,p_actual_finish_date      => l_ver_schedule_attr_rec.actual_finish_date
       ,p_estimate_start_date     => l_ver_schedule_attr_rec.estimated_start_date
       ,p_estimate_finish_date    => l_ver_schedule_attr_rec.estimated_finish_date
       ,p_duration                => l_ver_schedule_attr_rec.duration
       ,p_early_start_date        => l_ver_schedule_attr_rec.early_start_date
       ,p_early_end_date          => l_ver_schedule_attr_rec.early_finish_date
       ,p_late_start_date         => l_ver_schedule_attr_rec.late_start_date
       ,p_late_end_date           => l_ver_schedule_attr_rec.late_finish_date
       ,p_milestone_flag          => l_ver_schedule_attr_rec.milestone_flag
       ,p_critical_flag           => l_ver_schedule_attr_rec.critical_flag
       ,p_WQ_PLANNED_QUANTITY     => l_ver_schedule_attr_rec.WQ_PLANNED_QUANTITY
       ,p_PLANNED_EFFORT          => l_ver_schedule_attr_rec.PLANNED_EFFORT
        ,p_attribute_category        => l_ver_schedule_attr_rec.attribute_category
        ,p_attribute1                => l_ver_schedule_attr_rec.attribute1
        ,p_attribute2                => l_ver_schedule_attr_rec.attribute2
        ,p_attribute3                => l_ver_schedule_attr_rec.attribute3
        ,p_attribute4                => l_ver_schedule_attr_rec.attribute4
        ,p_attribute5                => l_ver_schedule_attr_rec.attribute5
        ,p_attribute6                => l_ver_schedule_attr_rec.attribute6
        ,p_attribute7                => l_ver_schedule_attr_rec.attribute7
        ,p_attribute8                => l_ver_schedule_attr_rec.attribute8
        ,p_attribute9                => l_ver_schedule_attr_rec.attribute9
        ,p_attribute10             => l_ver_schedule_attr_rec.attribute10
        ,p_attribute11             => l_ver_schedule_attr_rec.attribute11
        ,p_attribute12             => l_ver_schedule_attr_rec.attribute12
        ,p_attribute13             => l_ver_schedule_attr_rec.attribute13
        ,p_attribute14             => l_ver_schedule_attr_rec.attribute14
        ,p_attribute15             => l_ver_schedule_attr_rec.attribute15
       ,x_pev_schedule_id         => l_pev_schedule_id
       ,x_return_status           => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data );
      -- end xxlu changes
*/
      l_pev_schedule_id := NULL;
      PA_PROJ_ELEMENT_SCH_PKG.Insert_Row(
         X_ROW_ID                => X_Row_Id
        ,X_PEV_SCHEDULE_ID     => l_pev_schedule_id
        ,X_ELEMENT_VERSION_ID      => l_task_version_id
        ,X_PROJECT_ID            => l_ver_schedule_attr_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID     => l_ver_schedule_attr_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE  => l_ver_schedule_attr_rec.SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE => l_ver_schedule_attr_rec.SCHEDULED_FINISH_DATE
        ,X_OBLIGATION_START_DATE => l_ver_schedule_attr_rec.OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE => l_ver_schedule_attr_rec.OBLIGATION_FINISH_DATE
        ,X_ACTUAL_START_DATE        => l_ver_schedule_attr_rec.ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE       => l_ver_schedule_attr_rec.ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE   => l_ver_schedule_attr_rec.ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE  => l_ver_schedule_attr_rec.ESTIMATED_FINISH_DATE
        ,X_DURATION           => l_ver_schedule_attr_rec.DURATION
        ,X_EARLY_START_DATE     => l_ver_schedule_attr_rec.EARLY_START_DATE
        ,X_EARLY_FINISH_DATE        => l_ver_schedule_attr_rec.EARLY_FINISH_DATE
        ,X_LATE_START_DATE      => l_ver_schedule_attr_rec.LATE_START_DATE
        ,X_LATE_FINISH_DATE     => l_ver_schedule_attr_rec.LATE_FINISH_DATE
        ,X_CALENDAR_ID            => l_ver_schedule_attr_rec.CALENDAR_ID
        ,X_MILESTONE_FLAG       => l_ver_schedule_attr_rec.MILESTONE_FLAG
        ,X_CRITICAL_FLAG        => l_ver_schedule_attr_rec.CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY      => l_ver_schedule_attr_rec.wq_planned_quantity
        ,X_PLANNED_EFFORT           => l_ver_schedule_attr_rec.planned_effort
        ,X_ACTUAL_DURATION          => l_ver_schedule_attr_rec.actual_duration
        ,X_ESTIMATED_DURATION       => l_ver_schedule_attr_rec.estimated_duration
        ,X_ATTRIBUTE_CATEGORY               => l_ver_schedule_attr_rec.ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1                       => l_ver_schedule_attr_rec.ATTRIBUTE1
        ,X_ATTRIBUTE2                       => l_ver_schedule_attr_rec.ATTRIBUTE2
        ,X_ATTRIBUTE3                       => l_ver_schedule_attr_rec.ATTRIBUTE3
        ,X_ATTRIBUTE4                       => l_ver_schedule_attr_rec.ATTRIBUTE4
        ,X_ATTRIBUTE5                       => l_ver_schedule_attr_rec.ATTRIBUTE5
        ,X_ATTRIBUTE6                       => l_ver_schedule_attr_rec.ATTRIBUTE6
        ,X_ATTRIBUTE7                       => l_ver_schedule_attr_rec.ATTRIBUTE7
        ,X_ATTRIBUTE8                       => l_ver_schedule_attr_rec.ATTRIBUTE8
        ,X_ATTRIBUTE9                       => l_ver_schedule_attr_rec.ATTRIBUTE9
        ,X_ATTRIBUTE10                    => l_ver_schedule_attr_rec.ATTRIBUTE10
        ,X_ATTRIBUTE11                    => l_ver_schedule_attr_rec.ATTRIBUTE11
        ,X_ATTRIBUTE12                    => l_ver_schedule_attr_rec.ATTRIBUTE12
        ,X_ATTRIBUTE13                    => l_ver_schedule_attr_rec.ATTRIBUTE13
        ,X_ATTRIBUTE14                    => l_ver_schedule_attr_rec.ATTRIBUTE14
        ,X_ATTRIBUTE15                    => l_ver_schedule_attr_rec.ATTRIBUTE15
    ,X_SOURCE_OBJECT_ID               => l_ver_schedule_attr_rec.PROJECT_ID
        ,X_SOURCE_OBJECT_TYPE             => 'PA_PROJECTS'
      );

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Create Schedule Version return status: ' || l_return_status);
        pa_debug.debug('l_pev_schedule_id: ' || l_pev_schedule_id);
      END IF;

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    end if;

/* hsiu: bug 2800553: commented for performance improvement
    --Search for outgoing links; create new Links
    OPEN get_to_id(l_task_versions_rec.element_version_id);
    LOOP
      FETCH get_to_id INTO l_to_object_info;
      EXIT WHEN get_to_id%NOTFOUND;
      If (l_to_object_info.object_type_to = 'PA_STRUCTURES') THEN
        OPEN l_get_structure_ver_csr(l_to_object_info.object_id_to);
        FETCH l_get_structure_ver_csr INTO l_structure_ver_to_rec;

          PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
           p_user_id => FND_GLOBAL.USER_ID
          ,p_object_type_from => 'PA_TASKS'
          ,p_object_id_from1 => l_task_version_id
          ,p_object_id_from2 => NULL
          ,p_object_id_from3 => NULL
          ,p_object_id_from4 => NULL
          ,p_object_id_from5 => NULL
          ,p_object_type_to => 'PA_STRUCTURES'
          ,p_object_id_to1 => l_structure_ver_to_rec.element_version_id
          ,p_object_id_to2 => NULL
          ,p_object_id_to3 => NULL
          ,p_object_id_to4 => NULL
          ,p_object_id_to5 => NULL
          ,p_relationship_type => 'L'
          ,p_relationship_subtype => 'READ_WRITE'
          ,p_lag_day => NULL
          ,p_imported_lag => NULL
          ,p_priority => NULL
          ,p_pm_product_code => NULL
          ,x_object_relationship_id => l_new_obj_rel_id
          ,x_return_status => l_return_status
          );
*/
/*
        OPEN l_get_structure_type_csr(l_structure_ver_to_rec.element_version_id);
        FETCH l_get_structure_type_csr INTO l_structure_type1;
        CLOSE l_get_structure_type_csr;

        PA_RELATIONSHIP_PVT.Create_Relationship(
           p_init_msg_list                => FND_API.G_FALSE
          ,p_commit                       => FND_API.G_FALSE
          ,p_debug_mode                   => p_debug_mode
          ,p_project_id_from              => l_structure_ver_rec.project_id
          ,p_structure_id_from            => l_structure_ver_rec.proj_element_id
          ,p_structure_version_id_from    => l_new_struct_ver_id
          ,p_task_version_id_from         => l_task_version_id
          ,p_project_id_to                => l_structure_ver_to_rec.project_id
          ,p_structure_id_to              => l_structure_ver_to_rec.proj_element_id
          ,p_structure_version_id_to      => l_structure_ver_to_rec.element_version_id
          ,p_task_version_id_to           => NULL
          ,p_structure_type               => l_structure_type1
          ,p_initiating_element           => NULL
          ,p_link_to_latest_structure_ver => NULL
          ,p_relationship_type            => 'L'
          ,p_relationship_subtype         => 'READ_WRITE'
          ,x_object_relationship_id       => l_new_obj_rel_id
          ,x_return_status                => l_return_status
          ,x_msg_count                    => l_msg_count
          ,x_msg_data                     => l_msg_data
        );
*/
/* hsiu: bug 2800553:  commented for performance improvement
        CLOSE l_get_structure_ver_csr;

      ELSIF (l_to_object_info.object_type_to = 'PA_TASKS') THEN
        OPEN get_task_version_info(l_to_object_info.object_id_to);
        FETCH get_task_version_info INTO l_info_task_ver_rec;

          PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
           p_user_id => FND_GLOBAL.USER_ID
          ,p_object_type_from => 'PA_TASKS'
          ,p_object_id_from1 => l_task_version_id
          ,p_object_id_from2 => NULL
          ,p_object_id_from3 => NULL
          ,p_object_id_from4 => NULL
          ,p_object_id_from5 => NULL
          ,p_object_type_to => 'PA_TASKS'
          ,p_object_id_to1 => l_info_task_ver_rec.task_version_id
          ,p_object_id_to2 => NULL
          ,p_object_id_to3 => NULL
          ,p_object_id_to4 => NULL
          ,p_object_id_to5 => NULL
          ,p_relationship_type => 'L'
          ,p_relationship_subtype => 'READ_WRITE'
          ,p_lag_day => NULL
          ,p_imported_lag => NULL
          ,p_priority => NULL
          ,p_pm_product_code => NULL
          ,x_object_relationship_id => l_new_obj_rel_id
          ,x_return_status => l_return_status
          );
*/
/*
        OPEN l_get_structure_type_csr(l_info_task_ver_rec.structure_version_id);
        FETCH l_get_structure_type_csr INTO l_structure_type1;
        CLOSE l_get_structure_type_csr;

        PA_RELATIONSHIP_PVT.Create_Relationship(
           p_init_msg_list                => FND_API.G_FALSE
          ,p_commit                       => FND_API.G_FALSE
          ,p_debug_mode                   => p_debug_mode
          ,p_project_id_from              => l_structure_ver_rec.project_id
          ,p_structure_id_from            => l_structure_ver_rec.proj_element_id
          ,p_structure_version_id_from    => l_new_struct_ver_id
          ,p_task_version_id_from         => l_task_version_id
          ,p_project_id_to                => l_info_task_ver_rec.project_id
          ,p_structure_id_to              => l_info_task_ver_rec.structure_id
          ,p_structure_version_id_to      => l_info_task_ver_rec.structure_version_id
          ,p_task_version_id_to           => l_info_task_ver_rec.task_version_id
          ,p_structure_type               => l_structure_type1
          ,p_initiating_element           => NULL
          ,p_link_to_latest_structure_ver => NULL
          ,p_relationship_type            => 'L'
          ,p_relationship_subtype         => 'READ_WRITE'
          ,x_object_relationship_id       => l_new_obj_rel_id
          ,x_return_status                => l_return_status
          ,x_msg_count                    => l_msg_count
          ,x_msg_data                     => l_msg_data
        );
*/
/* hsiu: bug 2800553: commented for performance improvement
        CLOSE get_task_version_info;

      END IF;

      --Check error
      l_msg_count := FND_MSG_PUB.count_msg;
      if (l_msg_count > 0) then
        x_msg_count := l_msg_count;
        if x_msg_count = 1 then
          x_msg_data := l_msg_data;
        end if;
        CLOSE get_to_id;
        raise FND_API.G_EXC_ERROR;
     end if;
    END LOOP;
    CLOSE get_to_id;
*/
    l_last_wbs_level := l_task_versions_rec.wbs_level;
    l_outline_task_ref(l_task_versions_rec.wbs_level) := l_task_version_id;

  END LOOP;

  CLOSE l_get_task_versions_csr;

  x_new_struct_ver_id := l_new_struct_ver_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE_VERSION END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'COPY_STRUCTURE_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'COPY_STRUCTURE_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END COPY_STRUCTURE_VERSION;


PROCEDURE COPY_STRUCTURE
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_src_project_id                IN NUMBER
 ,p_dest_project_id               IN NUMBER
-- anlee
-- Dates changes
 ,p_delta                         IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- End of changes
 ,p_copy_task_flag                IN VARCHAR2    := 'Y'
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_split_cost_workplan_flag      VARCHAR2(1);
  l_structure_id                  NUMBER;
  l_structure_type                PA_STRUCTURE_TYPES.structure_type_class_code%TYPE;

--Bug 2189657
--Added for linking tasks with no display sequence.
    Type T_EquivElemVerTable IS TABLE OF NUMBER
      Index by BINARY_INTEGER;
    t_equiv_elem_ver_id T_EquivElemVerTable;
--Bug 2189657 end;

  CURSOR l_get_structure_type_csr(c_proj_element_id NUMBER)
  IS
  SELECT structure_type_class_code
  FROM   PA_STRUCTURE_TYPES pst,
         PA_PROJ_STRUCTURE_TYPES ppst
  WHERE  ppst.proj_element_id = c_proj_element_id
  AND    pst.structure_type_id = ppst.structure_type_id;

  CURSOR l_get_structure_csr(c_project_id NUMBER)
  IS
  SELECT *
  FROM PA_PROJ_ELEMENTS
  WHERE project_id = c_project_id
  AND   object_type = 'PA_STRUCTURES';

  l_structure_rec                 l_get_structure_csr%ROWTYPE;

  --This cursor will either get all the working versions or the latest published version
--  CURSOR l_get_structure_versions_csr(c_project_id NUMBER, c_structure_id NUMBER, c_pub_status VARCHAR2)
--  IS
--  SELECT b.element_version_id
--  FROM   PA_PROJ_ELEM_VER_STRUCTURE b
--  WHERE  b.proj_element_id = c_structure_id
--  AND    b.project_id = c_project_id
--  AND    (b.STATUS_CODE = 'STRUCTURE_PUBLISHED' AND b.LATEST_EFF_PUBLISHED_FLAG = 'Y' AND c_pub_status = 'Y')
--    UNION
--  SELECT b.element_version_id
--  FROM   PA_PROJ_ELEM_VER_STRUCTURE b
--  WHERE  b.proj_element_id = c_structure_id
--  AND    b.project_id = c_project_id
--  AND    (b.STATUS_CODE <> 'STRUCTURE_PUBLISHED' AND c_pub_status = 'N');


  l_structure_version_id         NUMBER;
  l_new_structure_version_id     NUMBER;

  CURSOR l_get_structure_ver_csr(c_structure_version_id NUMBER)
  IS
  SELECT *
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = c_structure_version_id;

  l_structure_ver_rec       l_get_structure_ver_csr%ROWTYPE;

--commented by hsiu for advanced structure changes
--  CURSOR l_get_structure_ver_attr_csr(c_structure_version_id NUMBER, c_pub_status VARCHAR2)
--  IS
--  SELECT a.*
--  FROM PA_PROJ_ELEM_VER_STRUCTURE a,
--       PA_PROJ_ELEMENT_VERSIONS b
--  WHERE b.element_version_id = c_structure_version_id
--    AND b.element_version_id = a.element_version_id
--    AND b.project_id = a.project_id
--    AND (a.STATUS_CODE <> 'STRUCTURE_PUBLISHED' AND c_pub_status = 'N')
--  UNION
--  SELECT a.*
--  FROM PA_PROJ_ELEM_VER_STRUCTURE a,
--       PA_PROJ_ELEMENT_VERSIONS b
--  WHERE b.element_version_id = c_structure_version_id
--    AND b.element_version_id = a.element_version_id
--    AND b.project_id = a.project_id
--    AND (a.STATUS_CODE = 'STRUCTURE_PUBLISHED' AND c_pub_status = 'Y' and a.LATEST_EFF_PUBLISHED_FLAG='Y');

  CURSOR l_get_structure_ver_attr_csr(c_structure_version_id NUMBER)
  IS
  SELECT a.*
  FROM PA_PROJ_ELEM_VER_STRUCTURE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.element_version_id = c_structure_version_id
    AND b.element_version_id = a.element_version_id
    AND b.proj_element_id = a.proj_element_id
    AND b.project_id = a.project_id;
  l_structure_ver_attr_rec       l_get_structure_ver_attr_csr%ROWTYPE;

  CURSOR l_get_task_versions_csr(c_structure_version_id NUMBER)
  IS
  SELECT a.element_version_id, a.proj_element_id, a.display_sequence, a.wbs_level,
         b.object_id_from1 parent_element_version_id
  FROM PA_PROJ_ELEMENT_VERSIONS a,
       PA_OBJECT_RELATIONSHIPS b,
       pa_proj_elements c
  WHERE a.object_type = 'PA_TASKS'
  AND   a.parent_structure_version_id = c_structure_version_id
  AND   a.element_version_id = b.object_id_to1
  AND   b.relationship_type = 'S'
  and   c.link_task_flag <> 'Y'
  and   c.proj_element_id = a.proj_element_id
  ORDER BY a.display_sequence;

  l_task_versions_rec        l_get_task_versions_csr%ROWTYPE;

  CURSOR get_task_ver_weighting(p_task_ver_id NUMBER)
  IS
  select weighting_percentage
    from pa_object_relationships
   where object_id_to1 = p_task_ver_id
     and object_type_to = 'PA_TASKS'
     and relationship_type = 'S';
  l_weighting_percentage     NUMBER;

  l_ref_task_ver_id          NUMBER;
  l_peer_or_sub              VARCHAR2(10);

  CURSOR l_get_ver_schedule_attr_csr(c_element_version_id NUMBER)
  IS
  SELECT a.*
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.element_version_id = c_element_version_id
  AND   b.element_version_id = a.element_version_id
  AND   b.project_id = a.project_id;

  l_ver_schedule_attr_rec       l_get_ver_schedule_attr_csr%ROWTYPE;

  TYPE reference_tasks IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

  -- This table stores reference task version IDs for a particular wbs
  -- level. This provides a lookup to find the last task version
  -- at that level.
  l_outline_task_ref reference_tasks;

  l_last_wbs_level          NUMBER;
  l_task_version_id         NUMBER;
  l_pev_schedule_id         NUMBER;

  CURSOR l_get_tasks_csr(c_project_id NUMBER, c_proj_element_id NUMBER)
  IS
  SELECT a.*, b.task_number PA_TASK_NUMBER
  FROM PA_PROJ_ELEMENTS a,
       PA_TASKS b
  WHERE a.object_type = 'PA_TASKS'
  AND   a.project_id = c_project_id
  AND   a.proj_element_id = c_proj_element_id
  AND   a.LINK_TASK_FLAG <> 'Y'
  AND   a.proj_element_id = b.task_id(+);

  CURSOR l_get_pa_tasks_csr(c_project_id NUMBER, c_task_number VARCHAR2)
  IS
  SELECT task_id
  FROM PA_TASKS
  WHERE project_id = c_project_id
  AND   task_number = c_task_number;

  l_tasks_rec              l_get_tasks_csr%ROWTYPE;
  l_task_id                NUMBER;
  l_task_id_ref            reference_tasks;
  l_pev_structure_id       NUMBER;

  --Bug No 3634334  Commented for performance reasons and rewritten the query.
  /*CURSOR l_linking_tasks_csr(c_src_project_id NUMBER, c_dest_project_id NUMBER)
  IS
  select a.task_id
  from pa_tasks a, pa_tasks b, pa_proj_elements c
  where a.project_id = c_dest_project_id
    and b.project_id = c_src_project_id
    and a.task_number = b.task_number
    and b.task_id = c.proj_element_id
    and c.link_task_flag = 'Y';*/

  CURSOR l_linking_tasks_csr(c_src_project_id NUMBER, c_dest_project_id NUMBER)
  IS
  select /*+ INDEX(a PA_TASKS_U2) */ a.task_id    --Bug No 3634334
  from pa_tasks a, pa_tasks b, pa_proj_elements c
  where a.project_id = c_dest_project_id
    and b.project_id = c_src_project_id
    and a.task_number = b.task_number
    and c.project_id = c_src_project_id    --Bug No 3634334
    and b.task_id = c.proj_element_id
    and c.object_type = 'PA_TASKS'  -- Bug No. 3968095
    and c.link_task_flag = 'Y';

  l_task_delete NUMBER;
  l_task_delete_rvn NUMBER;
  l_task_delete_wbs_rvn NUMBER;

  Type task_match_tbl is Table of NUMBER
    INDEX BY BINARY_INTEGER;
  l_task_match_tbl task_match_tbl;

  CURSOR l_is_template (c_project_id NUMBER)
  IS
  SELECT 1 FROM PA_PROJECTS_ALL
  WHERE TEMPLATE_FLAG = 'Y'
  AND project_id = c_project_id;
  l_dummy NUMBER;

--  l_is_workplan VARCHAR2(1);
--  l_is_billing  VARCHAR2(1);
--  l_is_costing  VARCHAR2(1);
  l_structure_pub_status VARCHAR2(1);
  l_rowid VARCHAR2(255);
  l_name         VARCHAR2(240);
  l_project_name VARCHAR2(30);
  l_append       VARCHAR2(10) := ': ';
  l_suffix       VARCHAR2(80);
-- anlee
-- Dates changes
  l_delta        NUMBER;
-- End of changes

--HSIU
--Added for calculating delta using target date
  CURSOR get_target_dates
  IS
  SELECT target_start_date, target_finish_date
  FROM   PA_PROJECTS_ALL
  WHERE  PROJECT_ID = p_dest_project_id;
  l_target_start_date    DATE;
  l_target_finish_date   DATE;
  l_scheduled_start_date  DATE;
  l_scheduled_finish_date DATE;
-- hsiu
-- Added for advanced structure
  l_src_template_flag  VARCHAR2(1);
  l_dest_template_flag VARCHAR2(1);
  l_select             NUMBER; -- For selecting structure versions:
                               -- 1 for last updated working
                               -- 2 for all working, baselined and latest published
                               -- 3 for latest published only
  l_copy               NUMBER; -- For status of copied structure version
                               -- 1 for Working
                               -- 2 for Published and Baselined
                               -- 3 for same as original
                               -- 4 for Published only
  l_status_code        VARCHAR2(30);
  l_baseline_flag      VARCHAR2(1);
  l_latest_flag        VARCHAR2(1);

  CURSOR l_get_structure_versions_csr(c_project_id NUMBER, c_structure_id NUMBER,
                                      c_option NUMBER)
  IS
  SELECT distinct(b.element_version_id)
  FROM   pa_proj_elements a, pa_proj_elem_ver_structure b
  WHERE  a.project_id = c_project_id
  AND    a.proj_element_id = c_structure_id
  AND    a.project_id = b.project_id
  AND    a.proj_element_id = b.proj_element_id
  AND    b.status_code <> 'STRUCTURE_PUBLISHED'
--Bug 2643432
--This is a temporary fix. The API returns the first row, but since date
--comparison only compares up to the day, not the second, we can only
--return the first selected row in this API.
  AND    b.element_version_id = PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(c_structure_id)
--  AND    b.last_update_date = (
--         SELECT MAX(c.last_update_date)
--         FROM pa_proj_elem_ver_structure c
--         WHERE c.project_id = a.project_id
--         AND c.proj_element_id = a.proj_element_id
--         AND c.status_code <> 'STRUCTURE_PUBLISHED')
  AND    1 = (c_option)
  UNION
  SELECT distinct(b.element_version_id)
  FROM   pa_proj_elements a, pa_proj_elem_ver_structure b
  WHERE  a.project_id = c_project_id
  AND    a.proj_element_id = c_structure_id
  AND    a.project_id = b.project_id
  AND    a.proj_element_id = b.proj_element_id
  AND    ((b.status_code = 'STRUCTURE_PUBLISHED' AND
           b.latest_eff_published_flag = 'Y')
          OR
          (b.status_code = 'STRUCTURE_PUBLISHED' AND
           b.current_flag = 'Y')
          OR
          (b.status_code <> 'STRUCTURE_PUBLISHED'))
  AND    2 = (c_option)
  UNION
  SELECT distinct(b.element_version_id)
  FROM   pa_proj_elements a, pa_proj_elem_ver_structure b
  WHERE  a.project_id = c_project_id
  AND    a.proj_element_id = c_structure_id
  AND    a.project_id = b.project_id
  AND    a.proj_element_id = b.proj_element_id
  AND    b.status_code = 'STRUCTURE_PUBLISHED'
  AND    b.latest_eff_published_flag = 'Y'
  AND    3 = (c_option);


  CURSOR get_wp_attr(c_proj_element_id NUMBER) IS
    select *
    from   pa_proj_workplan_attr
    where  proj_element_id = c_proj_element_id;
  l_wp_attr_rec get_wp_attr%ROWTYPE;

  CURSOR get_progress_attr(c_proj_element_id NUMBER, c_project_id NUMBER) IS            -- For Bug 3968095
    select *
    from   pa_proj_progress_attr
    where  object_type = 'PA_STRUCTURES'
    and    object_id = c_proj_element_id
    and project_id = c_project_id;                                      -- For Bug 3968095
  l_progress_attr_rec  get_progress_attr%ROWTYPE;

  CURSOR get_proj_rec_ver_number(c_project_id NUMBER) IS
    select record_version_number
    from pa_projects_all
    where project_id = c_project_id;
  l_proj_record_ver_number   NUMBER;
  l_struc_scheduled_start_date  DATE;
  l_struc_scheduled_finish_date DATE;
--hsiu added for task version status
  l_task_unpub_ver_status_code    pa_proj_element_versions.TASK_UNPUB_VER_STATUS_CODE%TYPE;
--end task version status changes

--hsiu: bug 2667527
  CURSOR get_init_task_stat(c_task_type_id NUMBER) IS
    select INITIAL_STATUS_CODE
      from pa_task_types
     where task_type_id = c_task_type_id;
  l_init_status_code PA_TASK_TYPES.INITIAL_STATUS_CODE%TYPE;
--end bug 2667527
BEGIN
  pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint copy_structure_pvt;
  END IF;

  -- Check if source and destination project are the same
  if p_src_project_id = p_dest_project_id then
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    return;
  end if;

  --Check if the destination project is a template
  OPEN l_is_template(p_dest_project_id);
  FETCH l_is_template INTO l_dummy;
  IF l_is_template%NOTFOUND THEN
    l_dest_template_flag := 'N';
  ELSE
    l_dest_template_flag := 'Y';
  END IF;
  CLOSE l_is_template;

  --Check if the source project is a template
  OPEN l_is_template(p_src_project_id);
  FETCH l_is_template INTO l_dummy;
  IF l_is_template%NOTFOUND THEN
    l_src_template_flag := 'N';
  ELSE
    l_src_template_flag := 'Y';
  END IF;
  CLOSE l_is_template;

/* commented by Hsiu
  -- delta is now calculated for each version

  -- anlee
  -- Dates changes
  if (p_delta = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) OR (p_delta is NULL) then
    l_delta := 0;
  else
    l_delta := p_delta;
  end if;
  -- End of changes
*/

/* commented by Hsiu

  -- Check split_cost_from_workplan_flag for source project
  SELECT split_cost_from_workplan_flag
  INTO l_split_cost_workplan_flag
  FROM PA_PROJECTS_ALL
  WHERE project_id = p_src_project_id;

  if l_split_cost_workplan_flag = 'N' then
    OPEN l_get_structure_csr(p_src_project_id);
    FETCH l_get_structure_csr INTO l_structure_rec;
    if l_get_structure_csr%NOTFOUND then
      CLOSE l_get_structure_csr;
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_NOT_EXIST');
      l_msg_data := 'PA_PS_STRUC_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR;
    end if;

    CLOSE l_get_structure_csr;
*/

  select name into l_project_name
    from pa_projects_all
   where project_id = p_dest_project_id;

  select meaning
    into l_suffix
    from pa_lookups
   where lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
     and lookup_code = 'WORKPLAN';

  --Hsiu start modification
  --Get target dates
  l_delta := 0;
  OPEN get_target_dates;
  FETCH get_target_dates into l_target_start_date, l_target_finish_date;
  CLOSE get_target_dates;
  --end modification

  OPEN l_get_structure_csr(p_src_project_id);
  LOOP
    FETCH l_get_structure_csr INTO l_structure_rec;
    EXIT WHEN l_get_structure_csr%NOTFOUND;

    --check if this is a split project
--    SELECT split_cost_from_workplan_flag
--    INTO l_split_cost_workplan_flag
--    FROM PA_PROJECTS_ALL
--    WHERE project_id = p_src_project_id;

--    OPEN l_get_structure_type_csr(l_structure_rec.proj_element_id);
--    FETCH l_get_structure_type_csr INTO l_structure_type;
--    CLOSE l_get_structure_type_csr;

--    IF l_split_cost_workplan_flag = 'N' THEN
--      --there should not be a second structure
--      l_structure_type := NULL;
--    END IF;

-- Hsiu added
-- For advanced structure

    l_name := substrb(l_project_name, 1, 240);
    IF (PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_src_project_id)
        = 'N') THEN
      --Workplan and financial are separate structures
      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(
                                     l_structure_rec.proj_element_id, 'WORKPLAN')
         = 'Y') THEN

        --Workplan structure
        l_structure_type := 'WORKPLAN';

        --Get workplan attributes
        OPEN get_wp_attr(l_structure_rec.proj_element_id);
        FETCH get_wp_attr into l_wp_attr_rec;
        CLOSE get_wp_attr;

        OPEN get_progress_attr(l_structure_rec.proj_element_id, l_structure_rec.project_id);        -- For Bug 3968095
        FETCH get_progress_attr into l_progress_attr_rec;
        CLOSE get_progress_attr;

        --Modify name; add suffix
        l_name := substrb(l_project_name||l_append||l_suffix, 1, 240);

        IF (l_src_template_flag = 'Y') AND
           (l_dest_template_flag = 'Y') THEN
          l_select := 1;
          l_copy := 1;
        ELSIF (l_src_template_flag = 'Y') AND
              (l_dest_template_flag = 'N') THEN
          l_select := 1;
          IF (l_wp_attr_rec.WP_ENABLE_VERSION_FLAG = 'Y' AND
              l_wp_attr_rec.AUTO_PUB_UPON_CREATION_FLAG = 'N') THEN
            l_copy := 1;
          ELSE
            l_copy := 2;
          END IF;
        ELSIF (l_src_template_flag = 'N') AND
              (l_dest_template_flag = 'N') THEN
          l_select := 2;
          l_copy := 3;
        ELSIF (l_src_template_flag = 'N') AND
              (l_dest_template_flag = 'Y') THEN
          IF (PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(p_src_project_id,
                          l_structure_rec.proj_element_id) = 'Y') THEN
            l_select := 3;
          ELSE
            l_select := 1;
          END IF;
          l_copy := 1;
        END IF;
      END IF;
      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(
                                     l_structure_rec.proj_element_id, 'FINANCIAL')
         = 'Y') THEN

        --Financial structure
        l_structure_type := 'FINANCIAL';

        IF (PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(p_src_project_id,
                        l_structure_rec.proj_element_id) = 'Y') THEN
          l_select := 3;
        ELSE
          l_select := 1;
        END IF;
        IF (l_dest_template_flag = 'Y') THEN
          l_copy := 1;
        ELSE
          l_copy := 4;
        END IF;

      END IF;
    ELSE--share flag is 'Y' for source project

      --Workplan and financial as 1 structure
      l_structure_type := NULL; --for share structure

      --Get workplan attributes
      OPEN get_wp_attr(l_structure_rec.proj_element_id);
      FETCH get_wp_attr into l_wp_attr_rec;
      CLOSE get_wp_attr;

      OPEN get_progress_attr(l_structure_rec.proj_element_id, l_structure_rec.project_id);      -- For Bug 3968095
      FETCH get_progress_attr into l_progress_attr_rec;
      CLOSE get_progress_attr;

      IF (l_src_template_flag = 'Y') AND
         (l_dest_template_flag = 'Y') THEN
        l_select := 1;
        l_copy := 1;
      ELSIF (l_src_template_flag = 'Y') AND
            (l_dest_template_flag = 'N') THEN
        l_select := 1;
        IF (l_wp_attr_rec.WP_ENABLE_VERSION_FLAG = 'Y' AND
            l_wp_attr_rec.AUTO_PUB_UPON_CREATION_FLAG = 'N') THEN
          l_copy := 1;
        ELSE
          l_copy := 2;
        END IF;
      ELSIF (l_src_template_flag = 'N') AND
            (l_dest_template_flag = 'N') THEN
        l_select := 2;
        l_copy := 3;
      ELSIF (l_src_template_flag = 'N') AND
            (l_dest_template_flag = 'Y') THEN
        IF (PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(p_src_project_id,
                        l_structure_rec.proj_element_id) = 'Y') THEN
          l_select := 3;
        ELSE
          l_select := 1;
        END IF;
        l_copy := 1;
      END IF;
    END IF;
-- end advanced structure changes

/*
    IF (l_structure_type = 'WORKPLAN') THEN
      l_name := substr(l_project_name||l_append||l_suffix, 1, 240);
    ELSE
      l_name := substr(l_project_name, 1, 240);
    END IF;
*/
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('create structure');
    END IF;

--Commented by hsiu
--  IF (l_dest_template_flag = 'Y' AND l_structure_type = 'WORKPLAN') THEN
--Create new structure
--    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
--    ( p_validate_only           => FND_API.G_FALSE
--     ,p_project_id              => p_dest_project_id
--     ,p_structure_number        => l_name
--     ,p_structure_name          => l_name
--     ,p_calling_flag            => l_structure_type
--     ,x_structure_id            => l_structure_id
--     ,x_return_status           => l_return_status
--     ,x_msg_count               => l_msg_count
--     ,x_msg_data                => l_msg_data );

--    --Check if there is any error.
--    l_msg_count := FND_MSG_PUB.count_msg;
--    IF l_msg_count > 0 THEN
--      x_msg_count := l_msg_count;
--      IF x_msg_count = 1 THEN
--        x_msg_data := l_msg_data;
--      END IF;
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

--    IF (p_debug_mode = 'Y') THEN
--      pa_debug.debug('create structure version');
--    END IF;
--    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
--    ( p_validate_only         => FND_API.G_FALSE
--     ,p_structure_id          => l_structure_id
--     ,x_structure_version_id  => l_new_structure_version_id
--     ,x_return_status         => l_return_status
--     ,x_msg_count             => l_msg_count
--     ,x_msg_data              => l_msg_data );

--    --Check if there is any error.
--    l_msg_count := FND_MSG_PUB.count_msg;
--    IF l_msg_count > 0 THEN
--      x_msg_count := l_msg_count;
--      IF x_msg_count = 1 THEN
--        x_msg_data := l_msg_data;
--      END IF;
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

--    IF (p_debug_mode = 'Y') THEN
--      pa_debug.debug('create structure version attr');
--    END IF;
--    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
--    ( p_validate_only               => FND_API.G_FALSE
--     ,p_structure_version_id        => l_new_structure_version_id
--     ,p_structure_version_name      => l_name
--     ,p_structure_version_desc      => NULL
--     ,p_effective_date              => NULL
--     ,p_latest_eff_published_flag   => 'N'
--     ,p_locked_status_code          => 'UNLOCKED'
--     ,p_struct_version_status_code  => 'STRUCTURE_WORKING'
--     ,p_baseline_current_flag       => 'N'
--     ,p_baseline_original_flag      => 'N'
--     ,x_pev_structure_id            => l_pev_structure_id
--     ,x_return_status               => l_return_status
--     ,x_msg_count                   => l_msg_count
--     ,x_msg_data                    => l_msg_data );

--    --Check if there is any error.
--    l_msg_count := FND_MSG_PUB.count_msg;
--    IF l_msg_count > 0 THEN
--      x_msg_count := l_msg_count;
--      IF x_msg_count = 1 THEN
--        x_msg_data := l_msg_data;
--      END IF;
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

--    IF (p_debug_mode = 'Y') THEN
--      pa_debug.debug('create schedule version');
--    END IF;
--    PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
--    ( p_validate_only           => FND_API.G_FALSE
--     ,p_element_version_id      => l_new_structure_version_id
--     ,p_scheduled_start_date    => SYSDATE
--     ,p_scheduled_end_date      => SYSDATE
--     ,x_pev_schedule_id         => l_pev_schedule_id
--     ,x_return_status           => l_return_status
--     ,x_msg_count             => l_msg_count
--     ,x_msg_data              => l_msg_data );

--    --Check if there is any error.
--    l_msg_count := FND_MSG_PUB.count_msg;
--    IF l_msg_count > 0 THEN
--      x_msg_count := l_msg_count;
--      IF x_msg_count = 1 THEN
--        x_msg_data := l_msg_data;
--      END IF;
--      RAISE FND_API.G_EXC_ERROR;
--    END IF;

--  ELSE
--copy from
--end commented code by hsiu

    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    ( p_validate_only           => FND_API.G_FALSE
     ,p_project_id              => p_dest_project_id
     ,p_structure_number        => l_name
     ,p_structure_name          => l_name
     ,p_calling_flag            => l_structure_type
     ,p_structure_description   => l_structure_rec.description
     ,p_attribute_category      => l_structure_rec.attribute_category
     ,p_attribute1              => l_structure_rec.attribute1
     ,p_attribute2              => l_structure_rec.attribute2
     ,p_attribute3              => l_structure_rec.attribute3
     ,p_attribute4              => l_structure_rec.attribute4
     ,p_attribute5              => l_structure_rec.attribute5
     ,p_attribute6              => l_structure_rec.attribute6
     ,p_attribute7              => l_structure_rec.attribute7
     ,p_attribute8              => l_structure_rec.attribute8
     ,p_attribute9              => l_structure_rec.attribute9
     ,p_attribute10             => l_structure_rec.attribute10
     ,p_attribute11             => l_structure_rec.attribute11
     ,p_attribute12             => l_structure_rec.attribute12
     ,p_attribute13             => l_structure_rec.attribute13
     ,p_attribute14             => l_structure_rec.attribute14
     ,p_attribute15             => l_structure_rec.attribute15
   ,p_approval_reqd_flag          =>l_wp_attr_rec.WP_APPROVAL_REQD_FLAG
   ,p_auto_publish_flag           =>l_wp_attr_rec.WP_AUTO_PUBLISH_FLAG
   ,p_approver_source_id          =>l_wp_attr_rec.WP_APPROVER_SOURCE_ID
   ,p_approver_source_type        =>l_wp_attr_rec.WP_APPROVER_SOURCE_TYPE
   ,p_default_display_lvl         =>l_wp_attr_rec.WP_DEFAULT_DISPLAY_LVL
   ,p_enable_wp_version_flag      =>l_wp_attr_rec.WP_ENABLE_VERSION_FLAG
   ,p_auto_pub_upon_creation_flag =>l_wp_attr_rec.AUTO_PUB_UPON_CREATION_FLAG
   ,p_auto_sync_txn_date_flag     =>l_wp_attr_rec.AUTO_SYNC_TXN_DATE_FLAG
   ,p_txn_date_sync_buf_days      =>l_wp_attr_rec.TXN_DATE_SYNC_BUF_DAYS
--LDENG
   ,p_lifecycle_version_id         => l_wp_attr_rec.LIFECYCLE_VERSION_ID
   ,p_current_phase_version_id     => l_wp_attr_rec.CURRENT_PHASE_VERSION_ID
--END LDENG
   ,p_PROGRESS_CYCLE_ID           =>l_progress_attr_rec.PROGRESS_CYCLE_ID
   ,p_wq_enable_flag              =>l_progress_attr_rec.WQ_ENABLE_FLAG
   ,p_remain_effort_enable_flag   =>l_progress_attr_rec.REMAIN_EFFORT_ENABLE_FLAG
   ,p_percent_comp_enable_flag    =>l_progress_attr_rec.PERCENT_COMP_ENABLE_FLAG
   ,p_next_progress_update_date   =>l_progress_attr_rec.NEXT_PROGRESS_UPDATE_DATE
     ,x_structure_id            => l_structure_id
     ,x_return_status           => l_return_status
     ,x_msg_count               => l_msg_count
     ,x_msg_data                => l_msg_data );

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('done: '||l_return_status);
    END IF;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


/*
    -- Get all of the tasks for the source project
    OPEN l_get_tasks_csr(p_src_project_id);
    LOOP
      FETCH l_get_tasks_csr INTO l_tasks_rec;
      EXIT WHEN l_get_tasks_csr%NOTFOUND;

      -- CREATE_TASK
      PA_TASK_PUB1.CREATE_TASK
      ( p_validate_only          => FND_API.G_FALSE
       ,p_object_type            => 'PA_TASKS'
       ,p_project_id             => p_dest_project_id
       ,p_structure_id           => l_structure_id
       ,p_task_number            => l_tasks_rec.element_number
       ,p_task_name              => l_tasks_rec.name
       ,p_task_manager_id        => l_tasks_rec.manager_person_id
       ,p_scheduled_start_date   => sysdate
       ,p_scheduled_finish_date  => sysdate
       ,x_task_id                => l_task_id
       ,x_return_status          => l_return_status
       ,x_msg_count              => l_msg_count
       ,x_msg_data               => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Store the newly created task ID
      l_task_id_ref(l_tasks_rec.proj_element_id) := l_task_id;
    END LOOP;
    CLOSE l_get_tasks_csr;
*/

--commented by hsiu
    --Get structure type
--  l_is_workplan := pa_project_structure_utils.Get_Struc_Type_For_Structure(l_structure_id,'WORKPLAN');
--  l_is_billing  := pa_project_structure_utils.Get_Struc_Type_For_Structure(l_structure_id,'BILLING');
--  l_is_costing  := pa_project_structure_utils.Get_Struc_Type_For_Structure(l_structure_id,'COSTING');

--  IF (l_is_billing = 'Y') OR (l_is_costing = 'Y') THEN
--    --Check if it has any published version.
--    If (pa_project_structure_utils.CHECK_PUBLISHED_VER_EXISTS(
--            p_src_project_id, l_structure_rec.proj_element_id) = 'Y') THEN
--      l_structure_pub_status := 'Y';
--    ELSE
--      l_structure_pub_status := 'N';
--    END IF;
--  ELSE
--    l_structure_pub_status := 'N';
--  END IF;
--end commented code by hsiu

    -- Copy all of the structure versions, either published or unpublished from the source structure
    -- depending on the flag
    OPEN l_get_structure_versions_csr(p_src_project_id,
                                      l_structure_rec.proj_element_id,
                                      l_select);
    LOOP
      FETCH l_get_structure_versions_csr INTO l_structure_version_id;
      EXIT WHEN l_get_structure_versions_csr%NOTFOUND;

      -- Get structure version info
      OPEN l_get_structure_ver_csr(l_structure_version_id);
      FETCH l_get_structure_ver_csr INTO l_structure_ver_rec;
      CLOSE l_get_structure_ver_csr;


      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('create structure version');
      END IF;
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
      ( p_validate_only         => p_validate_only
       ,p_structure_id          => l_structure_id
       ,p_attribute_category    => l_structure_ver_rec.attribute_category
       ,p_attribute1            => l_structure_ver_rec.attribute1
       ,p_attribute2            => l_structure_ver_rec.attribute2
       ,p_attribute3            => l_structure_ver_rec.attribute3
       ,p_attribute4            => l_structure_ver_rec.attribute4
       ,p_attribute5            => l_structure_ver_rec.attribute5
       ,p_attribute6            => l_structure_ver_rec.attribute6
       ,p_attribute7            => l_structure_ver_rec.attribute7
       ,p_attribute8            => l_structure_ver_rec.attribute8
       ,p_attribute9            => l_structure_ver_rec.attribute9
       ,p_attribute10           => l_structure_ver_rec.attribute10
       ,p_attribute11           => l_structure_ver_rec.attribute11
       ,p_attribute12           => l_structure_ver_rec.attribute12
       ,p_attribute13           => l_structure_ver_rec.attribute13
       ,p_attribute14           => l_structure_ver_rec.attribute14
       ,p_attribute15           => l_structure_ver_rec.attribute15
       ,x_structure_version_id  => l_new_structure_version_id
       ,x_return_status         => l_return_status
       ,x_msg_count             => l_msg_count
       ,x_msg_data              => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Structure version attributes creates after tasks are created

      -- If structure is workplan type create schedule version record
      if (l_structure_type = 'WORKPLAN') OR (l_structure_type IS NULL) THEN

        OPEN l_get_ver_schedule_attr_csr(l_structure_version_id);
        FETCH l_get_ver_schedule_attr_csr INTO l_ver_schedule_attr_rec;
        CLOSE l_get_ver_schedule_attr_csr;

        --Hsiu added
        --Project Dates changes: Calculate delta
        IF (l_target_start_date IS NULL) THEN
          l_delta := 0;
        ELSE
          l_delta := l_target_start_date - l_ver_schedule_attr_rec.scheduled_start_date;
        END IF;

        --calcuate scheduled start and finish dates
        IF (l_target_finish_date < l_ver_schedule_attr_rec.scheduled_start_date + l_delta) THEN
          l_scheduled_start_date := l_target_finish_date;
        ELSE
          l_scheduled_start_date := l_ver_schedule_attr_rec.scheduled_start_date + l_delta;
        END IF;

        IF (l_target_finish_date < l_ver_schedule_attr_rec.scheduled_finish_date + l_delta) THEN
          l_scheduled_finish_date := l_target_finish_date;
        ELSE
          l_scheduled_finish_date := l_ver_schedule_attr_rec.scheduled_finish_date + l_delta;
        END IF;
        -- end calculate scheduled start and finish dates


        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('create schedule version for structure');
        END IF;

        l_struc_scheduled_start_date  := l_scheduled_start_date;
        l_struc_scheduled_finish_date := l_scheduled_finish_date;

        PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
        ( p_validate_only           => FND_API.G_FALSE
         ,p_element_version_id      => l_new_structure_version_id
         ,p_calendar_id             => l_ver_schedule_attr_rec.calendar_id
         ,p_scheduled_start_date    => l_scheduled_start_date
         ,p_scheduled_end_date      => l_scheduled_finish_date
         ,p_obligation_start_date   => l_ver_schedule_attr_rec.obligation_start_date
         ,p_obligation_end_date     => l_ver_schedule_attr_rec.obligation_finish_date
         ,p_actual_start_date       => l_ver_schedule_attr_rec.actual_start_date
         ,p_actual_finish_date      => l_ver_schedule_attr_rec.actual_finish_date
         ,p_estimate_start_date     => l_ver_schedule_attr_rec.estimated_start_date
         ,p_estimate_finish_date    => l_ver_schedule_attr_rec.estimated_finish_date
         ,p_duration                => l_ver_schedule_attr_rec.duration
         ,p_early_start_date        => l_ver_schedule_attr_rec.early_start_date
         ,p_early_end_date          => l_ver_schedule_attr_rec.early_finish_date
         ,p_late_start_date         => l_ver_schedule_attr_rec.late_start_date
         ,p_late_end_date           => l_ver_schedule_attr_rec.late_finish_date
         ,p_milestone_flag          => l_ver_schedule_attr_rec.milestone_flag
         ,p_critical_flag           => l_ver_schedule_attr_rec.critical_flag
         ,p_WQ_PLANNED_QUANTITY     => l_ver_schedule_attr_rec.WQ_PLANNED_QUANTITY
         ,p_PLANNED_EFFORT          => l_ver_schedule_attr_rec.PLANNED_EFFORT
         ,x_pev_schedule_id         => l_pev_schedule_id
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      end if;


      -- Fetch all task versions for this structure version
      OPEN l_get_task_versions_csr(l_structure_version_id);

      l_last_wbs_level := null;

      LOOP
        FETCH l_get_task_versions_csr INTO l_task_versions_rec;
        EXIT WHEN l_get_task_versions_csr%NOTFOUND or p_copy_task_flag = 'N';

        if l_last_wbs_level is null then
          -- first task version being created
          -- This task should have wbs level = 1
          l_ref_task_ver_id := l_new_structure_version_id;
          l_peer_or_sub := 'SUB';
        else
          if l_task_versions_rec.wbs_level > l_last_wbs_level then
            l_ref_task_ver_id := l_outline_task_ref(l_last_wbs_level);
            l_peer_or_sub := 'SUB';
          else
            l_ref_task_ver_id := l_outline_task_ref(l_task_versions_rec.wbs_level);
            l_peer_or_sub := 'PEER';
          end if;
        end if;


        --check if task already exist; if it does, then skip
        -- CREATE_TASK
        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('l_task_versions_rec.proj_elemnet_id = '||l_task_versions_rec.proj_element_id);
        END IF;

        If (NOT (l_task_match_tbl.exists(l_task_versions_rec.proj_element_id))) THEN

          OPEN l_get_tasks_csr(p_src_project_id, l_task_versions_rec.proj_element_id);
          FETCH l_get_tasks_csr INTO l_tasks_rec;
          CLOSE l_get_tasks_csr;

--commented by hsiu
--          If (l_is_workplan = 'Y') AND (l_is_billing = 'N') AND (l_is_costing = 'N') THEN
          l_task_id := NULL;
          IF (l_structure_type = 'WORKPLAN') THEN
            --get new id
            select PA_TASKS_S.NEXTVAL into l_task_id from sys.dual;
          ELSE
            --id exists in pa_tasks. Need to find matching id by using task_number
            OPEN l_get_pa_tasks_csr(p_dest_project_id, l_tasks_rec.PA_TASK_NUMBER);
            FETCH l_get_pa_tasks_csr into l_task_id;
            CLOSE l_get_pa_tasks_csr;
          END IF;

          IF (p_debug_mode = 'Y') THEN
            pa_debug.debug('inserting into task with id'||l_task_id);
          END IF;

          OPEN get_init_task_stat(l_tasks_rec.TYPE_ID);
          FETCH get_init_task_stat into l_init_status_code;
          CLOSE get_init_task_stat;

          PA_PROJ_ELEMENTS_PKG.Insert_Row(
                 X_ROW_ID                               => l_rowid
                ,X_PROJ_ELEMENT_ID                      => l_task_id
                ,X_PROJECT_ID                           => p_dest_project_id
                ,X_OBJECT_TYPE                          => 'PA_TASKS'
                ,X_ELEMENT_NUMBER                       => l_tasks_rec.ELEMENT_NUMBER
                ,X_NAME                                 => l_tasks_rec.NAME
                ,X_DESCRIPTION                          => l_tasks_rec.DESCRIPTION
                ,X_STATUS_CODE                          => l_init_status_code
                ,X_WF_STATUS_CODE                       => l_tasks_rec.WF_STATUS_CODE
                ,X_PM_PRODUCT_CODE                      => l_tasks_rec.PM_SOURCE_CODE
                ,X_PM_TASK_REFERENCE                    => l_tasks_rec.PM_SOURCE_REFERENCE
                ,X_CLOSED_DATE                          => l_tasks_rec.CLOSED_DATE
                ,X_LOCATION_ID                          => l_tasks_rec.LOCATION_ID
                ,X_MANAGER_PERSON_ID                    => l_tasks_rec.MANAGER_PERSON_ID
                ,X_CARRYING_OUT_ORGANIZATION_ID         => l_tasks_rec.CARRYING_OUT_ORGANIZATION_ID
                ,X_TYPE_ID                              => l_tasks_rec.TYPE_ID
                ,X_PRIORITY_CODE                    => l_tasks_rec.PRIORITY_CODE
                ,X_INC_PROJ_PROGRESS_FLAG               => l_tasks_rec.INC_PROJ_PROGRESS_FLAG
                ,X_REQUEST_ID                           => l_tasks_rec.REQUEST_ID
                ,X_PROGRAM_APPLICATION_ID               => l_tasks_rec.PROGRAM_APPLICATION_ID
                ,X_PROGRAM_ID                           => l_tasks_rec.PROGRAM_ID
                ,X_PROGRAM_UPDATE_DATE                  => l_tasks_rec.PROGRAM_UPDATE_DATE
                ,X_LINK_TASK_FLAG                       => l_tasks_rec.LINK_TASK_FLAG
                ,X_ATTRIBUTE_CATEGORY                   => l_tasks_rec.ATTRIBUTE_CATEGORY
                ,X_ATTRIBUTE1                           => l_tasks_rec.ATTRIBUTE1
                ,X_ATTRIBUTE2                           => l_tasks_rec.ATTRIBUTE2
                ,X_ATTRIBUTE3                           => l_tasks_rec.ATTRIBUTE3
                ,X_ATTRIBUTE4                           => l_tasks_rec.ATTRIBUTE4
                ,X_ATTRIBUTE5                           => l_tasks_rec.ATTRIBUTE5
                ,X_ATTRIBUTE6                           => l_tasks_rec.ATTRIBUTE6
                ,X_ATTRIBUTE7                           => l_tasks_rec.ATTRIBUTE7
                ,X_ATTRIBUTE8                           => l_tasks_rec.ATTRIBUTE8
                ,X_ATTRIBUTE9                           => l_tasks_rec.ATTRIBUTE9
                ,X_ATTRIBUTE10                          => l_tasks_rec.ATTRIBUTE10
                ,X_ATTRIBUTE11                          => l_tasks_rec.ATTRIBUTE11
                ,X_ATTRIBUTE12                          => l_tasks_rec.ATTRIBUTE12
                ,X_ATTRIBUTE13                          => l_tasks_rec.ATTRIBUTE13
                ,X_ATTRIBUTE14                          => l_tasks_rec.ATTRIBUTE14
                ,X_ATTRIBUTE15                          => l_tasks_rec.ATTRIBUTE15
                ,X_TASK_WEIGHTING_DERIV_CODE       => NULL
                ,X_WORK_ITEM_CODE                  => l_tasks_rec.WQ_ITEM_CODE
                ,X_UOM_CODE                        => l_tasks_rec.WQ_UOM_CODE
                ,X_WQ_ACTUAL_ENTRY_CODE            => l_tasks_rec.WQ_ACTUAL_ENTRY_CODE
                ,X_TASK_PROGRESS_ENTRY_PAGE_ID     =>l_tasks_rec.TASK_PROGRESS_ENTRY_PAGE_ID
                ,X_PARENT_STRUCTURE_ID             => l_structure_id
                ,X_PHASE_CODE                      => l_tasks_rec.PHASE_CODE
                ,X_PHASE_VERSION_ID                => l_tasks_rec.PHASE_VERSION_ID
        ,X_SOURCE_OBJECT_ID                => p_dest_project_id
                ,X_SOURCE_OBJECT_TYPE              => 'PA_PROJECTS'
          );

          -- insert task id into table so task will not be duplicated.
          l_task_match_tbl(l_tasks_rec.proj_element_id) := l_task_id;

        ELSE
          --copy the id into l_task_id;
          l_task_id := l_task_match_tbl(l_task_versions_rec.proj_element_id);
        END IF;

        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('l_task_id = '||l_task_id);
        END IF;


        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('before creating version:'||l_ref_task_ver_id||','||l_peer_or_sub);
        END IF;

        OPEN get_task_ver_weighting(l_task_versions_rec.element_version_id);
        FETCH get_task_ver_weighting into l_weighting_percentage;
        CLOSE get_task_ver_weighting;

--hsiu: task version status changes
        IF (l_dest_template_flag = 'N') THEN
          --check if structure is shared
          --  if shared, check if versioned
          --    'WORKING' if versioned; 'PUBLISHED' if not
          --  if split, check if 'FINANCIAL'
          --    'PUBLISHED' if financial
          --    check if versioned
          --    'WORKING' if versioend; 'PUBLISHED' if not
          IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_dest_project_id)) THEN
            IF ('Y' = PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_dest_project_id) AND (l_wp_attr_rec.AUTO_PUB_UPON_CREATION_FLAG = 'N')) THEN
              l_task_unpub_ver_status_code := 'WORKING';
            ELSE
              l_task_unpub_ver_status_code := 'PUBLISHED';
            END IF;
          ELSE --split
            IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_structure_id, 'FINANCIAL')  AND
                'N' = PA_PROJECT_STRUCTURE_UTILS.get_struc_type_for_structure(l_structure_id, 'WORKPLAN')) THEN
              l_task_unpub_ver_status_code := 'PUBLISHED';
            ELSE --workplan only
              IF ('Y' = PA_WORKPLAN_ATTR_UTILS.Check_Wp_Versioning_Enabled(p_dest_project_id) AND (l_wp_attr_rec.AUTO_PUB_UPON_CREATION_FLAG = 'N')) THEN
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

        PA_TASK_PUB1.CREATE_TASK_VERSION
        ( p_validate_only        => FND_API.G_FALSE
         ,p_ref_task_version_id  => l_ref_task_ver_id
         ,p_peer_or_sub          => l_peer_or_sub
         ,p_task_id              => l_task_id--l_task_id_ref(l_task_versions_rec.proj_element_id)
         ,p_WEIGHTING_PERCENTAGE => l_weighting_percentage
         ,p_TASK_UNPUB_VER_STATUS_CODE => l_TASK_UNPUB_VER_STATUS_CODE
         ,x_task_version_id      => l_task_version_id
         ,x_return_status        => l_return_status
         ,x_msg_count            => l_msg_count
         ,x_msg_data             => l_msg_data);

      t_equiv_elem_ver_id(l_task_versions_rec.element_version_id) := l_task_version_id;

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        if (l_structure_type = 'WORKPLAN') or (l_structure_type IS NULL) THEN
          -- Get task version schedule attributes
          OPEN l_get_ver_schedule_attr_csr(l_task_versions_rec.element_version_id);
          FETCH l_get_ver_schedule_attr_csr INTO l_ver_schedule_attr_rec;
          CLOSE l_get_ver_schedule_attr_csr;

          --calcuate scheduled start and finish dates
          IF (l_target_finish_date < l_ver_schedule_attr_rec.scheduled_start_date + l_delta) THEN
            l_scheduled_start_date := l_target_finish_date;
          ELSE
            l_scheduled_start_date := l_ver_schedule_attr_rec.scheduled_start_date + l_delta;
          END IF;

          IF (l_target_finish_date < l_ver_schedule_attr_rec.scheduled_finish_date + l_delta) THEN
            l_scheduled_finish_date := l_target_finish_date;
          ELSE
            l_scheduled_finish_date := l_ver_schedule_attr_rec.scheduled_finish_date + l_delta;
          END IF;
          -- end calculate scheduled start and finish dates

          -- xxlu added DFF attributes
          PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
          ( p_validate_only           => FND_API.G_FALSE
           ,p_element_version_id      => l_task_version_id
           ,p_calendar_id             => l_ver_schedule_attr_rec.calendar_id
-- anlee
-- Dates changes
           ,p_scheduled_start_date    => l_scheduled_start_date
           ,p_scheduled_end_date      => l_scheduled_finish_date
-- End of changes
           ,p_obligation_start_date   => l_ver_schedule_attr_rec.obligation_start_date
           ,p_obligation_end_date     => l_ver_schedule_attr_rec.obligation_finish_date
           ,p_actual_start_date       => l_ver_schedule_attr_rec.actual_start_date
           ,p_actual_finish_date      => l_ver_schedule_attr_rec.actual_finish_date
           ,p_estimate_start_date     => l_ver_schedule_attr_rec.estimated_start_date
           ,p_estimate_finish_date    => l_ver_schedule_attr_rec.estimated_finish_date
           ,p_duration                => l_ver_schedule_attr_rec.duration
           ,p_early_start_date        => l_ver_schedule_attr_rec.early_start_date
           ,p_early_end_date          => l_ver_schedule_attr_rec.early_finish_date
           ,p_late_start_date         => l_ver_schedule_attr_rec.late_start_date
           ,p_late_end_date           => l_ver_schedule_attr_rec.late_finish_date
           ,p_milestone_flag          => l_ver_schedule_attr_rec.milestone_flag
           ,p_critical_flag           => l_ver_schedule_attr_rec.critical_flag
           ,p_WQ_PLANNED_QUANTITY     => l_ver_schedule_attr_rec.WQ_PLANNED_QUANTITY
           ,p_PLANNED_EFFORT          => l_ver_schedule_attr_rec.PLANNED_EFFORT
           ,p_attribute_category         => l_ver_schedule_attr_rec.attribute_category
           ,p_attribute1                 => l_ver_schedule_attr_rec.attribute1
           ,p_attribute2                 => l_ver_schedule_attr_rec.attribute2
           ,p_attribute3                 => l_ver_schedule_attr_rec.attribute3
           ,p_attribute4                 => l_ver_schedule_attr_rec.attribute4
           ,p_attribute5                 => l_ver_schedule_attr_rec.attribute5
           ,p_attribute6                 => l_ver_schedule_attr_rec.attribute6
           ,p_attribute7                 => l_ver_schedule_attr_rec.attribute7
           ,p_attribute8                 => l_ver_schedule_attr_rec.attribute8
           ,p_attribute9                 => l_ver_schedule_attr_rec.attribute9
           ,p_attribute10              => l_ver_schedule_attr_rec.attribute10
           ,p_attribute11              => l_ver_schedule_attr_rec.attribute11
           ,p_attribute12              => l_ver_schedule_attr_rec.attribute12
           ,p_attribute13              => l_ver_schedule_attr_rec.attribute13
           ,p_attribute14              => l_ver_schedule_attr_rec.attribute14
           ,p_attribute15              => l_ver_schedule_attr_rec.attribute15
           ,x_pev_schedule_id         => l_pev_schedule_id
           ,x_return_status           => l_return_status
           ,x_msg_count               => l_msg_count
           ,x_msg_data                => l_msg_data );
           -- end xxlu changes

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        end if;

        l_last_wbs_level := l_task_versions_rec.wbs_level;
        l_outline_task_ref(l_task_versions_rec.wbs_level) := l_task_version_id;--l_task_versions_rec.element_version_id;

      END LOOP;
      CLOSE l_get_task_versions_csr;

      --Delete linking tasks in PA_TASKS if this is a financial structure
      IF (l_structure_type = 'FINANCIAL' or l_structure_type IS NULL) THEN
        OPEN l_linking_tasks_csr(p_src_project_id, p_dest_project_id);
        LOOP
          FETCH l_linking_tasks_csr into l_task_delete;
          EXIT WHEN l_linking_tasks_csr%NOTFOUND;

          select a.record_version_number, 0
            INTO l_task_delete_rvn, l_task_delete_wbs_rvn
            from pa_tasks a
           where a.task_id = l_task_delete;

          PA_TASKS_MAINT_PUB.DELETE_TASK(
             p_init_msg_list => FND_API.G_FALSE
            ,p_commit => FND_API.G_FALSE
            ,p_project_id => p_dest_project_id
            ,p_task_id    => l_task_delete
            ,p_record_version_number => l_task_delete_rvn
            ,p_wbs_record_version_number => l_task_delete_wbs_rvn
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data  => l_msg_data
          );
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END LOOP;
        CLOSE l_linking_tasks_csr;
      END IF;

      -- Get structure version attributes
      OPEN l_get_structure_ver_attr_csr(l_structure_version_id);
      FETCH l_get_structure_ver_attr_csr INTO l_structure_ver_attr_rec;
      CLOSE l_get_structure_ver_attr_csr;

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('create structure version attribute');
      END IF;

      IF (l_copy = 1) THEN
        l_status_code := 'STRUCTURE_WORKING';
        l_baseline_flag := 'N';
        l_latest_flag := 'N';
      ELSIF (l_copy = 2) THEN
        l_status_code := 'STRUCTURE_PUBLISHED';
        l_baseline_flag := 'Y';
        l_latest_flag := 'Y';
      ELSIF (l_copy = 3) THEN
        l_status_code := l_structure_ver_attr_rec.status_code;
        l_baseline_flag := l_structure_ver_attr_rec.current_flag;
        l_latest_flag := l_structure_ver_attr_rec.LATEST_EFF_PUBLISHED_FLAG;
      ELSIF (l_copy = 4) THEN
        l_status_code := 'STRUCTURE_PUBLISHED';
        l_baseline_flag := 'N';
        l_latest_flag := 'Y';
      END IF;

      --moved here for baseline purpose
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
      ( p_validate_only               => FND_API.G_FALSE
       ,p_structure_version_id        => l_new_structure_version_id
--       ,p_structure_version_name      => l_name
--hsiu
--fix bug 2640307
--structure version name needs to be unique; copy from source.
       ,p_structure_version_name      => l_structure_ver_attr_rec.name
--end bug 2640307 fix
       ,p_structure_version_desc      => l_structure_ver_attr_rec.description
       ,p_effective_date              => l_structure_ver_attr_rec.effective_date
       ,p_latest_eff_published_flag   => l_latest_flag
       ,p_locked_status_code          => 'UNLOCKED'
       ,p_struct_version_status_code  => l_status_code
       ,p_baseline_current_flag       => l_baseline_flag
       ,p_baseline_original_flag      => 'N'
       ,x_pev_structure_id            => l_pev_structure_id
       ,x_return_status               => l_return_status
       ,x_msg_count                   => l_msg_count
       ,x_msg_data                    => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --If status is published and latest version, or template
      --update project level schedule dates
      IF ((l_status_code = 'STRUCTURE_PUBLISHED') and (l_latest_flag = 'Y')) OR (l_dest_template_flag = 'Y') THEN
        OPEN get_proj_rec_ver_number(p_dest_project_id);
        FETCH get_proj_rec_ver_number into l_proj_record_ver_number;
        CLOSE get_proj_rec_ver_number;

        PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES(
          p_validate_only       => FND_API.G_FALSE
         ,p_project_id          => p_dest_project_id
         ,p_date_type           => 'SCHEDULED'
         ,p_start_date          => l_struc_scheduled_start_date
         ,p_finish_date         => l_struc_scheduled_finish_date
         ,p_record_version_number => l_proj_record_ver_number
         ,x_return_status        => l_return_status
         ,x_msg_count           => l_msg_count
         ,x_msg_data            => l_msg_data
        );

        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

    END LOOP;
    CLOSE l_get_structure_versions_csr;

    --Commented by hsiu
    --END IF;
    --END IF for check if project is template and if type = WORKPLAN
  END LOOP;
  CLOSE l_get_structure_csr;
--  HSiu: commented old code
--  end if;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'COPY_STRUCTURE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'COPY_STRUCTURE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END COPY_STRUCTURE;


PROCEDURE BASELINE_STRUCTURE_VERSION
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_version_id          IN NUMBER
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
    CURSOR c1( c_project_id NUMBER ) IS
      SELECT B.PROJ_ELEMENT_ID, B.SCHEDULED_START_DATE,
             B.SCHEDULED_FINISH_DATE, A.ELEMENT_VERSION_ID   , duration
      FROM PA_PROJ_ELEMENT_VERSIONS A, PA_PROJ_ELEM_VER_SCHEDULE B
      WHERE A.PARENT_STRUCTURE_VERSION_ID = p_structure_version_id
        AND A.ELEMENT_VERSION_ID = B.ELEMENT_VERSION_ID
        AND A.PROJECT_ID = B.PROJECT_ID
        AND A.project_id = c_project_id;

    c1_rec c1%ROWTYPE;
    l_project_id  NUMBER;

-- anlee
-- Dates changes
    CURSOR c2 (c_project_id NUMBER)
    IS
    SELECT record_version_number
    FROM pa_projects_all
    WHERE project_id = c_project_id;

    l_proj_record_ver_number NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
-- End of changes

   l_calendar_id   NUMBER;
   l_duration      NUMBER;
   l_duration_days NUMBER;
   cursor get_cal_id IS
     select a.calendar_id
       from pa_projects_all a, pa_proj_element_versions b
      where a.project_id = b.project_id
        and b.element_version_id = p_structure_version_id;
BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint baseline_structure_pvt;
    END IF;

    SELECT PROJECT_ID
    INTO l_project_id
    FROM PA_PROJ_ELEMENT_VERSIONS
    WHERE ELEMENT_VERSION_ID = p_structure_version_id;

    UPDATE PA_PROJ_ELEMENTS
    SET BASELINE_START_DATE= NULL ,
        BASELINE_FINISH_DATE= NULL ,
        RECORD_VERSION_NUMBER=NVL(RECORD_VERSION_NUMBER,0) + 1
    WHERE PROJECT_ID = l_project_id;

    OPEN c1( l_project_id );
    LOOP
      FETCH c1 into c1_rec;
      EXIT WHEN c1%NOTFOUND;

/*      -- Calc duration
      OPEN get_cal_id;
      FETCH get_cal_id INTO l_calendar_id;
      CLOSE get_cal_id;

      PA_DURATION_UTILS.GET_DURATION(
       p_calendar_id      => l_calendar_id
      ,p_start_date       => c1_rec.scheduled_start_date
      ,p_end_date         => c1_rec.scheduled_finish_date
      ,x_duration_days    => l_duration_days
      ,x_duration_hours   => l_duration
      ,x_return_status    => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data );

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

      UPDATE PA_PROJ_ELEMENTS
      SET BASELINE_START_DATE=c1_rec.scheduled_start_date,
          BASELINE_FINISH_DATE=c1_rec.scheduled_finish_date, -- pa
          BASELINE_DURATION=c1_rec.duration,
          RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,0) + 1
      WHERE PROJ_ELEMENT_ID = c1_rec.proj_element_id;

      -- anlee
      -- Dates changes
      if c1_rec.element_version_id = p_structure_version_id then
        OPEN c2(l_project_id);
        FETCH c2 INTO l_proj_record_ver_number;
        CLOSE c2;

        PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
         p_validate_only          => FND_API.G_FALSE
        ,p_project_id             => l_project_id
        ,p_date_type              => 'BASELINE'
        ,p_start_date             => c1_rec.scheduled_start_date
        ,p_finish_date            => c1_rec.scheduled_finish_date
        ,p_record_version_number  => l_proj_record_ver_number
        ,x_return_status          => l_return_status
        ,x_msg_count              => l_msg_count
        ,x_msg_data               => l_msg_data );

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
-- End of changes

    END LOOP;
    CLOSE c1;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION end');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to baseline_structure_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to baseline_structure_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'BASELINE_STRUCTURE_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to baseline_structure_pvt;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'BASELINE_STRUCTURE_VERSION',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END BASELINE_STRUCTURE_VERSION;


PROCEDURE SPLIT_WORKPLAN
( p_commit                        IN VARCHAR2    := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2    := FND_API.G_TRUE
 ,p_validation_level              IN VARCHAR2    := 100
 ,p_calling_module                IN VARCHAR2    := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2    := 'N'
 ,p_max_msg_count                 IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_project_id                    IN NUMBER
 ,p_structure_name                IN VARCHAR2
 ,p_structure_number              IN VARCHAR2
 ,p_description                   IN VARCHAR2
 ,x_structure_id                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_structure_version_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  cursor c1 IS
    select a.proj_element_id
      from pa_proj_elements a,
           pa_proj_structure_types b,
           pa_structure_types c
     where a.project_id = p_project_id
       and a.object_type = 'PA_STRUCTURES'
       and a.proj_element_id = b.proj_element_id
       and b.structure_type_id = c.structure_type_id
       and c.structure_type_class_code IN ('FINANCIAL');

  cursor sel_struct_type(c_structure_id NUMBER) IS
    select a.rowid
      from pa_proj_structure_types a, pa_structure_types b
     where a.proj_element_id = c_structure_id
       and a.structure_type_id = b.structure_type_id
       and b.structure_type_class_code = 'WORKPLAN';


  l_structure_id NUMBER;
  l_rowid  VARCHAR2(255);

  l_ret_stat VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(250);

  l_struc_id           NUMBER;
  l_struc_ver_attr_id  NUMBER;
  l_struc_ver_id       NUMBER;
  l_pev_schedule_id    NUMBER;

BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.SPLIT_WORKPLAN BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint split_workplan;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Find existing structure');
    END IF;

    --get current costing/billing structure id
    OPEN c1;
    FETCH c1 INTO l_structure_id;
    CLOSE c1;

    --check if there is a published workplan version
    IF PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(p_project_id, l_structure_id) = 'Y' THEN
      --cannot split if publish version exists.
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANNOT_SPLIT_STRUCT');
      x_msg_data := 'PA_PS_CANNOT_SPLIT_STRUCT';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --delete workplan structure type
    OPEN sel_struct_type(l_structure_id);
    FETCH sel_struct_type INTO l_rowid;
    IF sel_struct_type%FOUND THEN
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Deleting type structure type');
      END IF;
      PA_PROJ_STRUCTURE_TYPES_PKG.delete_row(l_rowid);
    END IF;
    CLOSE sel_struct_type;

    --create_structure
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure(
                        p_project_id                        => p_project_id
                       ,p_structure_number                  => p_structure_number
                       ,p_structure_name                    => p_structure_name
                       ,p_structure_description             => p_description
                       ,p_calling_flag                      => 'WORKPLAN'
                       ,x_structure_id                      => l_struc_id
                       ,x_return_status                     => l_ret_stat
                       ,x_msg_count                         => l_msg_count
                       ,x_msg_data                          => l_msg_data
    );

    x_structure_id := l_struc_id;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --delete schedule info for structure versions and tasks
    delete from pa_proj_elem_ver_schedule
    where project_id = p_project_id;

    --create_structure_version
    PA_PROJECT_STRUCTURE_PUB1.create_structure_Version(
           p_structure_id                    => l_struc_id,
           x_structure_version_id            => l_struc_ver_id,
           x_return_status                   => l_ret_stat,
           x_msg_count                       => l_msg_count,
           x_msg_data                        => l_msg_data
    );

    x_structure_version_id := l_struc_ver_id;

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create_structure_version_attr
    PA_PROJECT_STRUCTURE_PUB1.create_structure_version_attr(
      p_structure_version_id                 => l_struc_ver_id,
      p_structure_version_name               => p_structure_name,
      p_structure_version_desc               => p_description,
      x_return_status                        => l_ret_stat,
      x_msg_count                            => l_msg_count,
      x_msg_data                             => l_msg_data,
      x_pev_structure_id                     => l_struc_ver_attr_id
    );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create_schedule_version
    PA_TASK_PUB1.Create_Schedule_Version(
                   p_element_version_id      => l_struc_ver_id
                  ,p_scheduled_start_date    => SYSDATE
                  ,p_scheduled_end_date      => SYSDATE
                  ,x_pev_schedule_id         => l_pev_schedule_id
                  ,x_return_status           => l_ret_stat
                  ,x_msg_count               => l_msg_count
                  ,x_msg_data                => l_msg_data
    );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.SPLIT_WORKPLAN end');
    END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to split_workplan;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to split_workplan;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'SPLIT_WORKPLAN',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to split_workplan;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'SPLIT_WORKPLAN',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END SPLIT_WORKPLAN;


procedure SUBMIT_WORKPLAN
(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_responsibility_id                 IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_structure_version_name   VARCHAR2(240);
  l_structure_version_desc   VARCHAR2(250);
  l_auto_pub                 VARCHAR2(1);
  l_published_struc_ver_id   NUMBER;
  l_dummy                    VARCHAR2(1);
  l_item_key                 VARCHAR2(240);
  l_wf_enable                VARCHAR2(1);
  l_wf_item_type             VARCHAR2(30);
  l_wf_process               VARCHAR2(30);
  l_wf_success_code          VARCHAR2(30);
  l_wf_failure_code          VARCHAR2(30);
  l_err_code                 NUMBER;
  l_err_stage                VARCHAR2(30);
  l_err_stack                VARCHAR2(240);
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_error_msg_code           VARCHAR2(250);

  CURSOR checkAutoPub IS
    select '1' from pa_proj_workplan_attr
      where project_id = p_project_id
        and wp_auto_publish_flag = 'Y';

  CURSOR get_wp_info IS
    select name, description
      from pa_proj_elem_ver_structure
     where project_Id = p_project_id
       and element_version_id = p_structure_version_id;

 /* Bug 2683138 */
 /* CURSOR get_start_wf IS
    select 'Y' from dual
       where exists (
       select 1 from pa_product_installation_v
        where product_short_code = 'PJT' AND INSTALLED_FLAG = 'Y'); */

  CURSOR get_start_wf IS
    select 'Y' from dual;

  CURSOR get_wf_info(c_status_code VARCHAR2) IS
    select enable_wf_flag, workflow_item_type,
           workflow_process, wf_success_status_code,
           wf_failure_status_code
      from pa_project_statuses
     where project_status_code = c_status_code;
--status_code can be STRUCTURE_SUBMITTED, STRUCTURE_REJECTED,
--                   STRUCTURE_APPROVED, or STRUCTURE_PUBLISHED

  --check if delete unpublished ok
    cursor sel_other_structure_ver(c_keep_struc_ver_id NUMBER) IS
      select b.element_version_id
        from pa_proj_element_versions a,
             pa_proj_element_versions b
       where a.element_version_id = c_keep_struc_ver_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.element_version_id <> c_keep_struc_ver_id
         and b.object_type = 'PA_STRUCTURES';
    l_del_struc_ver_id  NUMBER;

BEGIN
  PA_DEBUG.INIT_ERR_STACK('PA_PROJECT_STRUCTURE_PVT1.SUBMIT_WORKPLAN');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint SUBMIT_WP_PRIVATE;
  END IF;

  OPEN get_wp_info;
  FETCH get_wp_info into l_structure_version_name, l_structure_version_desc;
  CLOSE get_wp_info;

  --Check if ok to publish workplan version
  OPEN checkAutoPub;
  FETCH checkAutoPub into l_dummy;
  IF checkAutoPub%NOTFOUND THEN
    l_auto_pub := 'N';
  ELSE
    l_auto_pub := 'Y';
  END IF;
  CLOSE checkAutoPub;


  --hsiu: bug 2684465
  --Check if this structure missing tasks with transactions
--  IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.check_miss_transaction_tasks(p_structure_version_id)) THEN
--    PA_UTILS.ADD_MESSAGE('PA','PA_PS_MISS_TRANSAC_TASK');
--    x_msg_data := 'PA_PS_MISS_TRANSAC_TASK';
--    RAISE FND_API.G_EXC_ERROR;
--  END IF;
  PA_PROJECT_STRUCTURE_UTILS.CHECK_MISS_TRANSACTION_TASKS(p_structure_version_id,
                                                          l_return_status,
                                                          l_msg_count,
                                                          l_msg_data);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;



  --Check if task statuses are consistent
  PA_PROJECT_STRUCTURE_UTILS.check_tasks_statuses_valid(
      p_structure_version_id
     ,l_return_status
     ,l_msg_count
     ,l_msg_data
  );
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --Check if any new summary task has transactions
  PA_PROJECT_STRUCTURE_UTILS.Check_txn_on_summary_tasks(
    p_structure_version_id
   ,l_return_status
   ,l_msg_count
   ,l_msg_data
  );
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --end bug 2684465



  IF (l_auto_pub = 'Y') THEN

/*
    --Check if this structure can be published (ie, if linked structures are published)
    IF ('Y' <> PA_PROJECT_STRUCTURE_UTILS.Check_Publish_Struc_Ver_Ok(p_structure_version_id)) THEN
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_STRUC_NOT_PUB');
      x_msg_data := 'PA_PS_LINK_STRUC_NOT_PUB';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

/*
    PA_PROGRESS_PUB.CREATE_PROGRESS_FOR_WBS(
        p_validate_only        => FND_API.G_TRUE
       ,p_commit               => FND_API.G_FALSE
       ,p_project_id           => p_project_id
       ,p_structure_version_id => p_structure_version_id
       ,x_return_status        => l_return_status
       ,x_msg_count            => l_msg_count
       ,x_msg_data             => l_msg_data
    );
*/

    --bug 3840509
    IF 'Y' = nvl(PA_PROJECT_STRUCTURE_UTILS.Get_Sch_Dirty_fl(p_project_id,
                                                             p_structure_version_id), 'N') THEN
      --need to reschedule
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_NEED_THIRD_PT_SCH');
      x_msg_data := 'PA_PS_NEED_THIRD_PT_SCH';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --end bug 3840509

      --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

/*
    savepoint check_workplan;

    PA_PROJECT_STRUCTURE_PVT1.Publish_Structure(
      p_responsibility_id                => p_responsibility_id
     ,p_structure_version_id             => p_structure_version_id
     ,p_publish_structure_ver_name       => l_structure_version_name
     ,p_structure_ver_desc               => l_structure_version_desc
     ,p_effective_date                   => TRUNC(SYSDATE)
     ,p_current_baseline_flag            => 'N'
     ,x_published_struct_ver_id          => l_published_struc_ver_id
     ,x_return_status                    => x_return_status
     ,x_msg_count                        => x_msg_count
     ,x_msg_data                         => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    rollback to check_workplan;
*/
  END IF;

-- For bug 3045358 : Functionality presently is that we do not require to check for the locking status of other working versions
-- while submitting a particular version for approval.
-- Hence commenting the below code
  /*
  OPEN sel_other_structure_ver(p_structure_version_id);
  LOOP
    FETCH sel_other_structure_ver into l_del_struc_ver_id;
    EXIT WHEN sel_other_structure_ver%NOTFOUND;
    PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
      p_project_id => p_project_id
     ,p_structure_version_id =>l_del_struc_ver_id
     ,x_return_status => l_return_status
     ,x_error_message_code => l_msg_data
    );

    IF (l_return_status <> 'S') THEN
      PA_UTILS.ADD_MESSAGE('PA',l_msg_data);
      x_msg_data := l_msg_data;
      CLOSE sel_other_structure_ver;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;
  CLOSE sel_other_structure_ver;
  */
  --Update to submit status
  UPDATE PA_PROJ_ELEM_VER_STRUCTURE
  set status_code = 'STRUCTURE_SUBMITTED',
      lock_status_code = 'UNLOCKED',
      locked_by_person_id = NULL,
      locked_date = NULL
  where project_id = p_project_id
  and element_version_id = p_structure_version_id;

  --Submit for approval
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

    OPEN get_start_wf;
    FETCH get_start_wf into l_dummy;
    IF get_start_wf%FOUND THEN

      OPEN get_wf_info('STRUCTURE_SUBMITTED');
      FETCH get_wf_info into l_wf_enable, l_wf_item_type, l_wf_process,
                             l_wf_success_code, l_wf_failure_code;
      IF (l_wf_enable = 'Y') THEN
        PA_WORKPLAN_WORKFLOW.Start_workflow
        (
          l_wf_item_type
         ,l_wf_process
         ,p_structure_version_id
         ,p_responsibility_id
         ,FND_GLOBAL.USER_ID
         ,l_item_key
         ,x_msg_count
         ,x_msg_data
         ,x_return_status
        );

        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          --update pa_wf_process_table
          PA_WORKFLOW_UTILS.INSERT_WF_PROCESSES
          (
             p_wf_type_code =>      'WORKPLAN'
            ,p_item_type    =>      l_wf_item_type
            ,p_item_key     =>      l_item_key
            ,p_entity_key1  =>      p_project_id
            ,p_entity_key2  =>      p_structure_version_id
            ,p_description  =>      NULL
            ,p_err_code     =>      l_err_code
            ,p_err_stage    =>      l_err_stage
            ,p_err_stack    =>      l_err_stack
          );
          IF (l_err_code <> 0) THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_PS_CREATE_WF_FAILED');
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_CREATE_WF_FAILED');
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;
      CLOSE get_wf_info;
    END IF;
    CLOSE get_start_wf;

  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to SUBMIT_WP_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to SUBMIT_WP_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Submit_Workplan',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END SUBMIT_WORKPLAN;


procedure CHANGE_WORKPLAN_STATUS
(
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_false,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
   p_project_id                  IN     NUMBER := NULL,
   p_structure_version_id        IN     NUMBER := NULL,
   p_status_code                 IN     VARCHAR2 := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
      l_wf_enable VARCHAR2(1);
      l_wf_item_type VARCHAR2(30);
      l_wf_process VARCHAR2(30);
      l_success_code VARCHAR2(30);
      l_failure_code VARCHAR2(30);
      l_err_code NUMBER;
      l_err_stage VARCHAR2(30);
      l_err_stack VARCHAR2(240);
      l_dummy     VARCHAR2(1);
      l_item_key  NUMBER;
      l_pev_struc_id  NUMBER;
      l_msg_count    NUMBER;
      l_msg_data     VARCHAR2(250);

  /* Bug 2683138 */
  /* CURSOR get_start_wf IS
      select 'Y' from dual
       where exists (
         select 1 from pa_product_installation_v
          where product_short_code = 'PJT' AND INSTALLED_FLAG = 'Y');   */

    CURSOR get_start_wf IS
      select 'Y' from dual;

  CURSOR get_wf_info(c_status_code VARCHAR2) IS
    select enable_wf_flag, workflow_item_type,
           workflow_process, wf_success_status_code,
           wf_failure_status_code
      from pa_project_statuses
     where project_status_code = c_status_code;

  CURSOR get_status_code(c_status_code VARCHAR2) IS
    select '1' from pa_project_statuses
     where project_status_code = c_status_code
       and status_type = 'STRUCTURE';

BEGIN
    PA_DEBUG.init_err_stack('PA_PROJECT_STRUCTURE_PVT1.CHANGE_WORKPLAN_STATUS');

    -- Initialize the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    BEGIN
      select pev_structure_id into l_pev_struc_id
        from pa_proj_elem_ver_structure
       where project_id = p_project_id
         and element_version_id = p_structure_version_id
         and record_version_number = p_record_version_number
         for update of record_version_number NOWAIT;
    EXCEPTION
         when TIMEOUT_ON_RESOURCE then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
            l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
         when NO_DATA_FOUND then
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_XC_RECORD_CHANGED');
            l_msg_data := 'PA_XC_RECORD_CHANGED';
         when OTHERS then
            if SQLCODE = -54 then
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
              l_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
            else
              raise;
            end if;
    END;

    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        x_msg_data := l_msg_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    --check if status if valid
    OPEN get_status_code(p_status_code);
    FETCH get_status_code INTO l_dummy ;
    IF (get_status_code%NOTFOUND) THEN
      CLOSE get_status_code;
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name       => 'PA_PS_STRUC_STAT_INVAL');
              x_msg_data := 'PA_PS_STRUC_STAT_INVAL';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE get_status_code;
    --end validation

    update pa_proj_elem_ver_structure
    set status_code = p_status_code,
        record_version_number = record_version_number + 1
    where pev_structure_id = l_pev_struc_id;

    OPEN get_start_wf;
    FETCH get_start_wf INTO  l_dummy;
    IF (get_start_wf%found) THEN
      OPEN get_wf_info(p_status_code);
      FETCH get_wf_info INTO l_wf_enable, l_wf_item_type, l_wf_process,
                             l_success_code,l_failure_code;
      IF (get_wf_info%found) then
        IF (l_wf_enable = 'Y') THEN
          PA_WORKPLAN_WORKFLOW.Start_workflow
          (
            l_wf_item_type
           ,l_wf_process
           ,p_structure_version_id
           ,FND_GLOBAL.RESP_ID -- NULL Added for bug 5372586
           ,FND_GLOBAL.USER_ID -- NULL Added for bug 5372586
           ,l_item_key
           ,x_msg_count
           ,x_msg_data
           ,x_return_status
          );

          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            --update pa_wf_process_table
            PA_WORKFLOW_UTILS.INSERT_WF_PROCESSES
            (
               p_wf_type_code =>      'WORKPLAN'
              ,p_item_type    =>      l_wf_item_type
              ,p_item_key     =>      l_item_key
              ,p_entity_key1  =>      p_project_id
              ,p_entity_key2  =>      p_structure_version_id
              ,p_description  =>      NULL
              ,p_err_code     =>      l_err_code
              ,p_err_stage    =>      l_err_stage
              ,p_err_stack    =>      l_err_stack
            );
            IF (l_err_code <> 0) THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name => 'PA_PS_CREATE_WF_FAILED');
              x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
          ELSE
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_PS_CREATE_WF_FAILED');
            x_return_status := FND_API.G_RET_STS_ERROR;

          END IF;
        END IF;
      END IF;
      CLOSE get_wf_info;

    END IF;
    CLOSE get_start_wf;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Change_Workplan_Status',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END CHANGE_WORKPLAN_STATUS;


  PROCEDURE rework_workplan
  (
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_item_key      VARCHAR2(240);
    l_approve_req   VARCHAR2(1);
    l_item_type     VARCHAR2(30);
    l_wf_status     VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(300);

    CURSOR check_approve_req IS
      select nvl(wp_approval_reqd_flag,'N') from pa_proj_workplan_attr
       where project_id = p_project_id;

/* Bug 2680486 -- Performance changes -- Added the join of wf_type_code to avoid full table scan on pa_wf_processes*/

    CURSOR get_item_key IS
      select MAX(pwp.item_key), max(pwp.item_type)
        from pa_wf_processes pwp, pa_project_statuses pps
       where pwp.item_type = pps.workflow_item_type
         and pps.status_type = 'STRUCTURE'
         and pps.project_status_code = 'STRUCTURE_SUBMITTED'
         and entity_key2 = p_structure_version_id
     and pwp.wf_type_code = 'WORKPLAN';

    CURSOR get_wf_status IS
      select 'Y'
        from wf_item_activity_statuses wias, pa_project_statuses pps
       where wias.item_type = pps.WORKFLOW_ITEM_TYPE
         and wias.item_key = l_item_key
         and wias.activity_status = 'ACTIVE'
         and pps.status_type = 'STRUCTURE'
         and pps.project_status_code = 'STRUCTURE_SUBMITTED';

  BEGIN
    PA_DEBUG.init_err_stack('PA_PROJECT_STRUCTURE_PVT1.REWORK_WORKPLAN');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint rework_workplan_pvt;
    END IF;

    change_workplan_status(
      p_project_id => p_project_id
     ,p_structure_version_id => p_structure_version_id
     ,p_status_code => 'STRUCTURE_WORKING'
     ,p_record_version_number => p_record_version_number
     ,x_return_status => x_return_status
     ,x_msg_count => l_msg_count
     ,x_msg_data => l_msg_data
    );

      --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      OPEN check_approve_req;
      FETCH check_approve_req into l_approve_req;
      IF check_approve_req%NOTFOUND THEN
        l_approve_req := 'N';
      END IF;
      CLOSE check_approve_req;

      OPEN get_item_key;
      FETCH get_item_key into l_item_key, l_item_type;
      IF (get_item_key%FOUND) THEN

        --process exist
        OPEN get_wf_status;
        FETCH get_wf_status INTO l_wf_status;
        IF (get_wf_status%NOTFOUND or l_wf_status <> 'Y') THEN
--          IF (l_approve_req = 'Y') THEN
--            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
--                                ,p_msg_name => 'PA_PR_CANCEL_WORKFLOW_INV');
--            x_return_status := FND_API.G_RET_STS_ERROR;
--            x_msg_count := FND_MSG_PUB.count_msg;
--            if x_msg_count = 1 then
--              x_msg_data := 'PA_PR_CANCEL_WORKFLOW_INV';
--            end if;
--            raise FND_API.G_EXC_ERROR;
--          END IF;
            NULL;
        ELSE
          --cancel process
          PA_WORKPLAN_WORKFLOW.cancel_workflow(
            l_item_type
           ,l_item_key
           ,x_msg_count
           ,x_msg_data
           ,x_return_status
          );
        END IF;
        CLOSE get_wf_status;

      ELSE
        IF (l_approve_req = 'Y') THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_PR_CANCEL_WORKFLOW_INV');
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := 'PA_PR_CANCEL_WORKFLOW_INV';
          end if;
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      CLOSE get_item_key;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to rework_workplan_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to rework_workplan_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'rework_Workplan',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END rework_workplan;


-- API name                      : update_structures_setup_attr
-- Type                             : Update API
-- Pre-reqs                       : None
-- Return Value                 : Update_structures_setup_attr
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_workplan_enabled_flag IN VARCHAR2
--  p_financial_enabled_flag IN VARCHAR2
--  p_sharing_enabled_flag IN VARCHAR2
--  x_return_status OUT VARCHAR2
--  x_msg_count OUT NUMBER
--  x_msg_data  OUT VARCHAR2
--
--  History
--
--  26-JUL-02   HSIU             -Created
--  15-JAN-04   HSIU             -rewrite API with sharing code changes

  PROCEDURE update_structures_setup_old
  (  p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id IN NUMBER
    ,p_workplan_enabled_flag IN VARCHAR2
    ,p_financial_enabled_flag IN VARCHAR2
    ,p_sharing_enabled_flag IN VARCHAR2
    --FP M changes bug 3301192
    ,p_deliverables_enabled_flag       IN VARCHAR2
    ,p_sharing_option_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --End FP M changes bug 3301192
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_ret_stat           VARCHAR2(1);
    l_err_msg_code       VARCHAR2(30);
    l_suffix             VARCHAR2(80);
    l_name               VARCHAR2(240);
    l_append             VARCHAR2(10) := ': ';
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(250);
    l_structure_id       NUMBER;
    l_structure_version_id NUMBER;
    l_template_flag      VARCHAR2(1);
    l_status_code        VARCHAR2(30);
    l_baseline_flag      VARCHAR2(1);
    l_latest_eff_pub_flag VARCHAR2(1);
    l_effective_date     DATE;
    l_wp_attr_rvn        NUMBER;
    l_rowid              VARCHAR2(255);
    l_keep_structure_ver_id NUMBER;
    l_del_struc_ver_id   NUMBER;
    l_struc_ver_rvn      NUMBER;
    l_pev_structure_id   NUMBER;
    l_pev_schedule_id    NUMBER;
    l_struc_ver_attr_rvn NUMBER;
    l_struc_type_id      NUMBER;
    l_proj_structure_type_id NUMBER;
    l_task_id            NUMBER;
    l_element_version_id NUMBER;
    l_start_date         DATE;
    l_completion_date    DATE;
    l_object_type        VARCHAR2(30);
    l_task_ver_id        NUMBER;
   /* Bug 2790703 Begin */
    -- l_task_ver_ids       PA_NUM_1000_NUM := PA_NUM_1000_NUM();
    l_task_ver_ids_tbl PA_STRUCT_TASK_ROLLUP_PUB.pa_element_version_id_tbl_typ;
    l_index number :=0 ;
/* Bug 2790703 End */

    l_proj_start_Date DATE;
    l_proj_completion_date DATE;
    l_proj_prog_attr_id NUMBER;

    CURSOR get_project_info IS
      select name, target_start_date, target_finish_date
        from pa_projects_all
       where project_id = p_project_id;

--bug 2843569: added record_version_number
    CURSOR get_template_flag IS
      select template_flag, record_version_number
        from pa_projects_all
       where project_id = p_project_id;

    CURSOR get_wp_attr_rvn IS
      select b.proj_element_id, a.record_version_number
        from pa_proj_workplan_attr a,
             pa_proj_elements b,
             pa_proj_structure_types c,
             pa_structure_types d
       where a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.project_id = p_project_id
         and b.proj_element_id = c.proj_element_id
         and c.structure_type_id = d.structure_type_id
         and d.structure_type_class_code = 'WORKPLAN';

    cursor sel_wp_struct_type(c_structure_id NUMBER) IS
      select a.rowid
        from pa_proj_structure_types a,
             pa_structure_types b
       where a.proj_element_id = c_structure_id
         and a.structure_type_id = b.structure_type_id
         and b.structure_type_class_code = 'WORKPLAN';

    cursor sel_latest_pub_ver(c_structure_id NUMBER) IS
      select element_version_id
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         and project_id = p_project_id
         and status_code = 'STRUCTURE_PUBLISHED'
         and LATEST_EFF_PUBLISHED_FLAG = 'Y';

    cursor sel_wp_structure_id IS
      select a.proj_element_id
        from pa_proj_elements a,
             pa_proj_structure_types b,
             pa_structure_types c
       where a.project_id = p_project_id
         and a.object_type = 'PA_STRUCTURES'
         and a.proj_element_id = b.proj_element_id
         and b.structure_type_id = c.structure_type_id
         and c.structure_type_class_code = 'WORKPLAN';

    cursor sel_other_structure_ver(c_keep_struc_ver_id NUMBER) IS
      select b.element_version_id, b.record_version_number
        from pa_proj_element_versions a,
             pa_proj_element_versions b
       where a.element_version_id = c_keep_struc_ver_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.element_version_id <> c_keep_struc_ver_id
         and b.object_type = 'PA_STRUCTURES';

    cursor sel_all_wp_structure_ver(c_struc_id NUMBER) IS
      select a.element_version_id, a.record_version_number
        from pa_proj_element_versions a,
             pa_proj_elements b
       where a.proj_element_id = b.proj_element_id
         and a.project_id = b.project_id
         and b.proj_element_id = c_struc_id;

    cursor sel_struc_ver_attr_rvn(c_struc_ver_id NUMBER) IS
      select PEV_STRUCTURE_ID, record_version_number
        from pa_proj_elem_ver_structure
       where project_id = p_project_id
         and element_version_id = c_struc_ver_id;

    cursor sel_proj_workplan_attr(c_struc_id NUMBER) is
      select *
        from pa_proj_workplan_attr
       where proj_element_id = c_struc_id;
    l_proj_workplan_attr_rec  sel_proj_workplan_attr%ROWTYPE;

    cursor sel_proj_progress_attr(c_struc_id NUMBER) IS
      select *
        from pa_proj_progress_attr
       where project_id = p_project_id
         and object_type = 'PA_STRUCTURES'
         and object_id = c_struc_id;
    l_proj_progress_attr_rec  sel_proj_progress_attr%ROWTYPE;

    cursor sel_fin_structure_id IS
      select a.proj_element_id
        from pa_proj_elements a,
             pa_proj_structure_types b,
             pa_structure_types c
       where a.project_id = p_project_id
         and a.object_type = 'PA_STRUCTURES'
         and a.proj_element_id = b.proj_element_id
         and b.structure_type_id = c.structure_type_id
         and c.structure_type_class_code = 'FINANCIAL';

    CURSOR sel_struc_type_id IS
      select structure_type_id
        from pa_structure_types
       where structure_type_class_code = 'WORKPLAN';

    cursor sel_struc_ver(c_structure_id NUMBER) IS
      select element_version_id
        from pa_proj_element_versions
       where project_id = p_project_id
         and proj_element_id = c_structure_id
         and object_type = 'PA_STRUCTURES';

--hsiu: commented for performance
--    cursor sel_struc_and_task_vers(c_struc_ver_id NUMBER) IS
--      select object_type, proj_element_id, element_version_id
--        from pa_proj_element_versions
--       where parent_structure_version_id = c_struc_ver_id;
    cursor sel_struc_and_task_vers(c_struc_ver_id NUMBER) IS
      select pev.object_type, pev.proj_element_id, pev.element_version_id
        from pa_proj_element_versions pev, pa_object_relationships rel
       where pev.parent_structure_version_id = c_struc_ver_id
         and rel.object_id_to1 = pev.element_version_id
         and rel.relationship_type = 'S'
         and NOT EXISTS (
               select 1
                 from pa_object_Relationships
                where object_id_from1 = pev.element_version_id
                  and relationship_type = 'S'
             );


    cursor sel_task_dates(c_task_id NUMBER) IS
      select start_date, completion_date
        from pa_tasks
       where task_id = c_task_id;

--hsiu added for bug 2634029
    cursor sel_target_dates IS
      select target_start_date, target_finish_date, calendar_id
        from pa_projects_all
       where project_id = p_project_id;

    CURSOR get_top_tasks(c_structure_version_id NUMBER) IS
           select v.element_version_id
             from pa_proj_element_versions v,
                  pa_object_relationships r
            where v.element_version_id = r.object_id_to1
              and r.object_id_from1 = c_structure_version_id
              and r.object_type_from = 'PA_STRUCTURES';

--bug 2843569
    CURSOR get_scheduled_dates(c_project_Id NUMBER,
                                c_element_version_id NUMBER) IS
           select a.scheduled_start_date, a.scheduled_finish_date
             from pa_proj_elem_ver_schedule a
            where a.project_id = c_project_id
              and a.element_version_id = c_element_version_id;
    l_get_sch_dates_cur get_scheduled_dates%ROWTYPE;
    l_proj_rec_ver_num      NUMBER;
--end bug 2843569

    l_target_start_date     DATE;
    l_target_finish_date    DATE;
    l_calendar_id           NUMBER;
--end changes for bug 2634029

--bug 3010538
    l_task_weight_basis_code VARCHAR2(30);
    l_update_proc_wbs_flag VARCHAR2(1);
--end bug 3010538

    l_wp_name               VARCHAR2(240);
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.update_structures_setup_attr');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_struc_setup_attr_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

/*
    --For enabling workplan
    IF (p_workplan_enabled_flag <>
        PA_PROJECT_STRUCTURE_UTILS.CHECK_WORKPLAN_ENABLED(p_project_id)) THEN
      --BEGIN ENABLING WP CODE

      IF (p_workplan_enabled_flag = 'Y') THEN
        --Validation
        PA_PROJECT_STRUCTURE_UTILS.check_enable_wp_ok(p_project_id,
                                                      l_ret_stat,
                                                      l_err_msg_code);
        IF (l_ret_stat = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --enable WP
        --get project name
        OPEN get_project_info;
        FETCH get_project_info into l_name, l_proj_start_date, l_proj_completion_date;
        CLOSE get_project_info;

        IF (l_proj_completion_date IS NULL AND l_proj_start_date IS NOT NULL) THEN
          l_proj_completion_date := l_proj_start_date;
        ELSIF (l_proj_completion_date IS NULL AND l_proj_start_date IS NULL) THEN
          l_proj_completion_date := sysdate;
          l_proj_start_date := sysdate;
        END IF;

        --get suffix
        select meaning
          into l_suffix
          from pa_lookups
         where lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
           and lookup_code = 'WORKPLAN';

        l_name := substrb(l_name||l_append||l_suffix, 1, 240);
        --Create new structure
        PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
         ( p_validate_only           => FND_API.G_FALSE
          ,p_project_id              => p_project_id
          ,p_structure_number        => l_name
          ,p_structure_name          => l_name
          ,p_calling_flag            => 'WORKPLAN'
          ,x_structure_id            => l_structure_id
          ,x_return_status           => l_return_status
          ,x_msg_count               => l_msg_count
          ,x_msg_data                => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
        ( p_validate_only         => FND_API.G_FALSE
         ,p_structure_id          => l_structure_id
         ,x_structure_version_id  => l_structure_version_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => l_msg_count
         ,x_msg_data              => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        PA_TASK_PUB1.Create_Schedule_Version(
          p_element_version_id      => l_structure_version_id
         ,p_scheduled_start_date    => l_proj_start_date
         ,p_scheduled_end_date      => l_proj_completion_date
         ,x_pev_schedule_id         => l_pev_schedule_id
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data
        );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN get_template_flag;
        FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
        CLOSE get_template_flag;

        IF (l_template_flag = 'Y') THEN
          l_status_code := 'STRUCTURE_WORKING';
          l_baseline_flag := 'N';
          l_latest_eff_pub_flag := 'N';
          l_effective_date := NULL;
        ELSE
          l_status_code := 'STRUCTURE_PUBLISHED';
          l_baseline_flag := 'Y';
          l_latest_eff_pub_flag := 'Y';
          l_effective_date := sysdate;
        END IF;

        PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
        ( p_validate_only               => FND_API.G_FALSE
         ,p_structure_version_id        => l_structure_version_id
         ,p_structure_version_name      => l_name
         ,p_structure_version_desc      => NULL
         ,p_effective_date              => l_effective_date
         ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
         ,p_locked_status_code          => 'UNLOCKED'
         ,p_struct_version_status_code  => l_status_code
         ,p_baseline_current_flag       => l_baseline_flag
         ,p_baseline_original_flag      => 'N'
         ,x_pev_structure_id            => l_pev_structure_id
         ,x_return_status               => l_return_status
         ,x_msg_count                   => l_msg_count
         ,x_msg_data                    => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --end enable WP
      ELSE
        --Validation
        PA_PROJECT_STRUCTURE_UTILS.check_disable_wp_ok(p_project_id,
                                                       l_ret_stat,
                                                       l_err_msg_code);
        IF (l_ret_stat = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --disable WP

        --get structure_id
        OPEN sel_wp_structure_id;
        FETCH sel_wp_structure_id INTO l_structure_id;
        CLOSE sel_wp_structure_id;

        IF (PA_PROJECT_STRUCTURE_UTILS.check_sharing_enabled(p_project_id)
            = 'Y') THEN
          --Shared
          --Select version to be kept
          OPEN sel_latest_pub_ver(l_structure_id);
          FETCH sel_latest_pub_ver into l_keep_structure_ver_id;
          IF sel_latest_pub_ver%NOTFOUND THEN
            l_keep_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(l_structure_id);
          END IF;
          CLOSE sel_latest_pub_ver;

          --Delete all other structure versions
          OPEN sel_other_structure_ver(l_keep_structure_ver_id);
          LOOP
            FETCH sel_other_structure_ver into l_del_struc_ver_id,
                                               l_struc_ver_rvn;
            EXIT WHEN sel_other_structure_ver%NOTFOUND;
-----hsiu: bug 2800553: added for sharing/splitting performance
            PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
            IF (l_return_status <> 'S') THEN
              PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
              x_msg_data := l_err_msg_code;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --get top tasks
            OPEN get_top_tasks(l_del_struc_ver_id);
            LOOP
              FETCH get_top_tasks into l_task_ver_id;
              EXIT WHEN get_top_tasks%NOTFOUND;

              PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

              IF (l_return_status <> 'S') THEN
                x_return_status := l_return_status;
                PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
                l_msg_data := l_err_msg_code;
                CLOSE get_top_tasks;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;
            CLOSE get_top_tasks;

--            PA_PROJECT_STRUCTURE_PUB1.Delete_Structure_Version(
            PA_PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_Wo_Val(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
            );
----end changes

            --Check if there is any error.
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
              END IF;
              CLOSE sel_other_structure_ver;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END LOOP;
          CLOSE sel_other_structure_ver;

          --NULL all baseline dates
          UPDATE pa_proj_elements
             SET baseline_start_date = NULL,
                 baseline_finish_date = NULL,
                 record_version_number = record_version_number+1
           WHERE project_id = p_project_id;

          --Delete all schedule rows
          DELETE FROM pa_proj_elem_ver_schedule
          WHERE project_id = p_project_id;

          --Delete wp attr row
          OPEN get_wp_attr_rvn;
          FETCH get_wp_attr_rvn into l_structure_id, l_wp_attr_rvn;
          CLOSE get_wp_attr_rvn;

          PA_WORKPLAN_ATTR_PUB.DELETE_PROJ_WORKPLAN_ATTRS(
            p_validate_only               => FND_API.G_FALSE
           ,p_project_id => p_project_id
           ,p_proj_element_id => l_structure_id
           ,p_record_version_number => l_wp_attr_rvn
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
          );

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          PA_PROGRESS_PUB.DELETE_PROJ_PROG_ATTR(
            p_validate_only        => FND_API.G_FALSE
           ,p_project_id           => p_project_id
           ,P_OBJECT_TYPE          => 'PA_STRUCTURES'
           ,p_object_id            => l_structure_id
           ,x_return_status        => l_return_status
           ,x_msg_count            => l_msg_count
           ,x_msg_data             => l_msg_data
          );

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --Delete structure type
          OPEN sel_wp_struct_type(l_structure_id);
          FETCH sel_wp_struct_type into l_rowid;
          PA_PROJ_STRUCTURE_TYPES_PKG.delete_row(l_rowid);
          CLOSE sel_wp_struct_type;

          --Update structure status to published if project;
          --  working if template
          OPEN get_template_flag;
          FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
          CLOSE get_template_flag;

          OPEN sel_struc_ver_attr_rvn(l_keep_structure_ver_id);
          FETCH sel_struc_ver_attr_rvn into l_pev_structure_id,
                                            l_struc_ver_attr_rvn;
          CLOSE sel_struc_ver_attr_rvn;

          IF (l_template_flag = 'Y') THEN
            l_status_code := 'STRUCTURE_WORKING';
            l_latest_eff_pub_flag := 'N';
            l_effective_date := NULL;
          ELSE
            l_status_code := 'STRUCTURE_PUBLISHED';
            l_latest_eff_pub_flag := 'Y';
            l_effective_date := sysdate;
          END IF;

          --Change status
          UPDATE pa_proj_elem_ver_structure
          set status_code = l_status_code,
              current_flag = 'N',
              current_baseline_date = NULL,
              current_baseline_person_id = NULL,
              latest_eff_published_flag = l_latest_eff_pub_flag,
              effective_date = l_effective_date,
              record_version_number = record_version_number + 1
          where pev_structure_id = l_pev_structure_id;

        ELSE
          --Not Shared
          --Delete all structure versions
          OPEN sel_all_wp_structure_ver(l_structure_id);
          LOOP
            FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                             l_struc_ver_rvn;
            EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
            PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
            IF (l_return_status <> 'S') THEN
              PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
              x_msg_data := l_err_msg_code;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --get top tasks
            OPEN get_top_tasks(l_del_struc_ver_id);
            LOOP
              FETCH get_top_tasks into l_task_ver_id;
              EXIT WHEN get_top_tasks%NOTFOUND;

              PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

              IF (l_return_status <> 'S') THEN
                x_return_status := l_return_status;
                PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
                l_msg_data := l_err_msg_code;
                CLOSE get_top_tasks;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;
            CLOSE get_top_tasks;

--            PA_PROJECT_STRUCTURE_PUB1.Delete_Structure_Version(
            PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
            );
----end changes

            --Check if there is any error.
            l_msg_count := FND_MSG_PUB.count_msg;
            IF l_msg_count > 0 THEN
              x_msg_count := l_msg_count;
              IF x_msg_count = 1 THEN
                x_msg_data := l_msg_data;
              END IF;
              CLOSE sel_all_wp_structure_ver;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END LOOP;
          CLOSE sel_all_wp_structure_ver;

        END IF;
        --end disable WP
      END IF;
      --END ENABLING WP CODE
    END IF;

    --For sharing workplan
    IF (p_sharing_enabled_flag <>
        PA_PROJECT_STRUCTURE_UTILS.CHECK_SHARING_ENABLED(p_project_id)) THEN
      --get structure_id
      OPEN sel_wp_structure_id;
      FETCH sel_wp_structure_id INTO l_structure_id;
      CLOSE sel_wp_structure_id;

      --select current proj wp attributes
      OPEN sel_proj_workplan_attr(l_structure_id);
      FETCH sel_proj_workplan_attr INTO l_proj_workplan_attr_rec;
      CLOSE sel_proj_workplan_attr;

      OPEN sel_proj_progress_attr(l_structure_id);
      FETCH sel_proj_progress_attr INTO l_proj_progress_attr_rec;
      CLOSE sel_proj_progress_attr;

      --BEGIN SHARING CODE
      IF (p_sharing_enabled_flag = 'Y' AND
          PA_PROJECT_STRUCTURE_UTILS.CHECK_WORKPLAN_ENABLED(p_project_id) = 'Y') THEN
        --Validation
        PA_PROJECT_STRUCTURE_UTILS.check_sharing_on_ok(p_project_id,
                                                       l_ret_stat,
                                                       l_err_msg_code);
        IF (l_ret_stat = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --hsiu: bug 2634029; get target dates
        OPEN sel_target_dates;
        FETCH sel_target_dates into l_target_start_date, l_target_finish_date, l_calendar_id;
        CLOSE sel_target_dates;
        IF (l_target_start_date IS NULL or l_target_finish_date IS NULL) THEN
          l_target_start_date := sysdate;
          l_target_finish_date := sysdate;
        END IF;
        --end bug 2634029 changes

        --sharing on
        --loop and delete all workplan versions
        OPEN sel_all_wp_structure_ver(l_structure_id);
        LOOP
          FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                              l_struc_ver_rvn;
          EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
            PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
            IF (l_return_status <> 'S') THEN
              PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
              x_msg_data := l_err_msg_code;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --get top tasks
            OPEN get_top_tasks(l_del_struc_ver_id);
            LOOP
              FETCH get_top_tasks into l_task_ver_id;
              EXIT WHEN get_top_tasks%NOTFOUND;

              PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );


              IF (l_return_status <> 'S') THEN
                x_return_status := l_return_status;
                PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
                l_msg_data := l_err_msg_code;
                CLOSE get_top_tasks;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;
            CLOSE get_top_tasks;

--          PA_PROJECT_STRUCTURE_PUB1.Delete_Structure_Version(
            PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
          );

----end changes

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            CLOSE sel_all_wp_structure_ver;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
        CLOSE sel_all_wp_structure_ver;

        --Add structure type to financial
        OPEN sel_fin_structure_id;
        FETCH sel_fin_structure_id into l_structure_id;
        CLOSE sel_fin_structure_id;

        OPEN sel_struc_type_id;
        FETCH sel_struc_type_id INTO l_struc_type_id;
        CLOSE sel_struc_type_id;

        PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
              X_ROWID                  => l_rowid
             ,X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
             ,X_PROJ_ELEMENT_ID        => l_structure_id
             ,X_STRUCTURE_TYPE_ID      => l_struc_type_id
             ,X_RECORD_VERSION_NUMBER  => 1
             ,X_ATTRIBUTE_CATEGORY     => NULL
             ,X_ATTRIBUTE1             => NULL
             ,X_ATTRIBUTE2             => NULL
             ,X_ATTRIBUTE3             => NULL
             ,X_ATTRIBUTE4             => NULL
             ,X_ATTRIBUTE5             => NULL
             ,X_ATTRIBUTE6             => NULL
             ,X_ATTRIBUTE7             => NULL
             ,X_ATTRIBUTE8             => NULL
             ,X_ATTRIBUTE9             => NULL
             ,X_ATTRIBUTE10            => NULL
             ,X_ATTRIBUTE11            => NULL
             ,X_ATTRIBUTE12            => NULL
             ,X_ATTRIBUTE13            => NULL
             ,X_ATTRIBUTE14            => NULL
             ,X_ATTRIBUTE15            => NULL
        );

        --add proj_wp attr
        PA_WORKPLAN_ATTR_PVT.CREATE_PROJ_WORKPLAN_ATTRS(
          p_validate_only               => FND_API.G_FALSE
         ,p_project_id                   => p_project_id
         ,p_proj_element_id              => l_structure_id
         ,p_approval_reqd_flag           => l_proj_workplan_attr_rec.WP_APPROVAL_REQD_FLAG
         ,p_auto_publish_flag            => l_proj_workplan_attr_rec.WP_AUTO_PUBLISH_FLAG
         ,p_approver_source_id           => l_proj_workplan_attr_rec.WP_APPROVER_SOURCE_ID
         ,p_approver_source_type         => l_proj_workplan_attr_rec.WP_APPROVER_SOURCE_TYPE
         ,p_default_display_lvl          => l_proj_workplan_attr_rec.WP_DEFAULT_DISPLAY_LVL
         ,p_enable_wp_version_flag       => l_proj_workplan_attr_rec.WP_ENABLE_VERSION_FLAG
         ,p_auto_pub_upon_creation_flag  => l_proj_workplan_attr_rec.AUTO_PUB_UPON_CREATION_FLAG
         ,p_auto_sync_txn_date_flag      => l_proj_workplan_attr_rec.AUTO_SYNC_TXN_DATE_FLAG
         ,p_txn_date_sync_buf_days       => l_proj_workplan_attr_rec.TXN_DATE_SYNC_BUF_DAYS
--LDENG
         ,p_lifecycle_version_id         => l_proj_workplan_attr_rec.LIFECYCLE_VERSION_ID
         ,p_current_phase_version_id     => l_proj_workplan_attr_rec.CURRENT_PHASE_VERSION_ID
--END LDENG
         ,x_return_status                => l_return_status
         ,x_msg_count                    => l_msg_count
         ,x_msg_data                     => l_msg_data
        );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --bug 3010538
        --copy task weighting basis
        PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
           p_validate_only       => FND_API.G_FALSE
          ,p_project_id          => p_project_id
          ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
          ,P_OBJECT_ID           => l_structure_id
          ,p_PROGRESS_CYCLE_ID   => l_proj_progress_attr_rec.PROGRESS_CYCLE_ID
          ,p_wq_enable_flag      => l_proj_progress_attr_rec.wq_enable_flag
          ,p_remain_effort_enable_flag => l_proj_progress_attr_rec.remain_effort_enable_flag
          ,p_percent_comp_enable_flag => l_proj_progress_attr_rec.percent_comp_enable_flag
          ,p_next_progress_update_date => l_proj_progress_attr_rec.next_progress_update_date
          ,p_action_set_id       => NULL
          ,p_TASK_WEIGHT_BASIS_CODE => l_proj_progress_attr_rec.TASK_WEIGHT_BASIS_CODE
          ,x_proj_progress_attr_id => l_proj_prog_attr_id
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
        );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Loop schedule version to structure version and task versions
        OPEN sel_struc_ver(l_structure_id);
        FETCH sel_struc_ver into l_structure_version_id;
        CLOSE sel_struc_ver;

        --3035902: process update flag changes
        IF (l_proj_progress_attr_rec.TASK_WEIGHT_BASIS_CODE = 'EFFORT') THEN
          --set process flag to Y
          --get structure version id
          PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG(
                               p_project_id => p_project_id,
                               p_structure_version_id => l_structure_version_id,
                               p_update_wbs_flag => 'Y',
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data
                             );
          If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
              x_msg_data := l_msg_data;
            end if;
            raise FND_API.G_EXC_ERROR;
          end if;

        END IF;
         --3035902: end process update flag changes


        OPEN sel_struc_and_task_vers(l_structure_version_id);
        LOOP
          FETCH sel_struc_and_task_vers into l_object_type, l_task_id, l_element_version_id;
          EXIT WHEN sel_struc_and_task_vers%NOTFOUND;
--hsiu: commented for performance enhancement
--          l_start_date := sysdate;
--          l_completion_date := sysdate;

          --If it is lowest task, get dates
--hsiu: commented for performance
--          IF (l_object_type = 'PA_TASKS' AND
--              PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(l_element_version_id) = 'Y') THEN
--            OPEN sel_task_dates(l_task_id);
--            FETCH sel_task_dates into l_start_date, l_completion_date;
--            CLOSE sel_task_dates;

        --  Bug 2790703 Begin
            --Add to array for rollup
            --l_task_ver_ids.extend;
            --l_task_ver_ids(l_task_ver_ids.count) := l_element_version_id;
        l_index := l_index + 1;
        l_task_ver_ids_tbl(l_index) := l_element_version_id;
        --  Bug 2790703 End

--hsiu: commented for performance
--            IF (l_start_date IS NULL) OR (l_completion_date IS NULL) THEN
--              CLOSE sel_struc_and_task_vers;
--              PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_FIN_TK_DATE_MISS');
--              x_msg_data := 'PA_PS_FIN_TK_DATE_MISS';
--              RAISE FND_API.G_EXC_ERROR;
--hsiu: 2634029
--      Default sysdate or project target dates if transaction dates
--      are missing.
--              l_start_date := l_target_start_date;
--              l_completion_date := l_target_finish_date;
--            END IF;
--          END IF;

          -- anlee
          --   Commented out for performance
          --   Will use bulk insert into schedule table instead
          -- anlee end of comment

        END LOOP;
        CLOSE sel_struc_and_task_vers;

        INSERT INTO PA_PROJ_ELEM_VER_SCHEDULE(
          pev_schedule_id,
          element_version_id,
          project_id,
          proj_element_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          scheduled_start_date,
          scheduled_finish_date,
          milestone_flag,
          critical_flag,
          calendar_id,
          record_version_number,
          last_update_login,
      source_object_id,
      source_object_type
      )
        SELECT
          pa_proj_elem_ver_schedule_s.nextval,
          PPEV.element_version_id,
          PPEV.project_id,
          PPEV.proj_element_id,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', decode(PT.COMPLETION_DATE, NULL, trunc(l_target_start_date), trunc(PT.START_DATE))),
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.COMPLETION_DATE), trunc(l_target_finish_date))),
          'N',
          'N',
          l_calendar_id,
          0,
          FND_GLOBAL.LOGIN_ID,
      PPEV.project_id,
      'PA_PROJECTS'
        FROM PA_TASKS PT,
             PA_PROJ_ELEMENT_VERSIONS PPEV
        WHERE
             PPEV.parent_structure_version_id = l_structure_version_id
        AND  PPEV.proj_element_id = PT.task_id (+);
        -- anlee end of bulk insert

    -- Bug 2790703 Begin
      IF (l_task_ver_ids_tbl.count > 0) THEN
        --rollup
        PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
                       p_commit => FND_API.G_FALSE,
                       p_element_versions => l_task_ver_ids_tbl,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

    -- Bug 2790703 End

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

        --check if project or template; set status
        OPEN get_template_flag;
        FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
        CLOSE get_template_flag;

        --bug 3010538
        --set update flag to 'Y' for all working versions (or published
        --  if versioning is disabled
        IF (l_template_flag = 'Y') THEN
          l_status_code := 'STRUCTURE_WORKING';
          l_baseline_flag := 'N';
          l_latest_eff_pub_flag := 'N';
          l_effective_date := NULL;
        ELSE
          l_status_code := 'STRUCTURE_PUBLISHED';
          l_baseline_flag := 'Y';
          l_latest_eff_pub_flag := 'Y';
          l_effective_date := sysdate;
        END IF;

        --Change status
        OPEN sel_struc_ver_attr_rvn(l_structure_version_id);
        FETCH sel_struc_ver_attr_rvn into l_pev_structure_id,
                                          l_struc_ver_attr_rvn;
        CLOSE sel_struc_ver_attr_rvn;

--bug 3010538
--added process_update_wbs_flag
        UPDATE pa_proj_elem_ver_structure
        set status_code = l_status_code,
            current_flag = l_baseline_flag,
            current_baseline_date = l_effective_date,
            current_baseline_person_id = NULL,
            latest_eff_published_flag = l_latest_eff_pub_flag,
            effective_date = l_effective_date,
--            PROCESS_UPDATE_WBS_FLAG = l_update_proc_wbs_flag,
            record_version_number = record_version_number + 1
        where pev_structure_id = l_pev_structure_id;

--bug 2843569
        IF (l_status_code = 'STRUCTURE_PUBLISHED') OR
           (l_template_flag = 'Y') THEN
          OPEN get_scheduled_dates(p_project_id, l_structure_version_id);
          FETCH get_scheduled_dates into l_get_sch_dates_cur;
          CLOSE get_scheduled_dates;

          PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
            p_validate_only        => FND_API.G_FALSE
           ,p_project_id           => p_project_id
           ,p_date_type            => 'SCHEDULED'
           ,p_start_date           => l_get_sch_dates_cur.scheduled_start_date
           ,p_finish_date          => l_get_sch_dates_cur.scheduled_finish_date
           ,p_record_version_number=> l_proj_rec_ver_num
           ,x_return_status        => x_return_status
           ,x_msg_count            => x_msg_count
           ,x_msg_data             => x_msg_data );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
--bug 2843569

        IF (l_baseline_flag = 'Y') THEN
          --baseline structure
          PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                       p_commit => FND_API.G_FALSE,
                       p_structure_version_id => l_structure_version_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

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
    -- Bug 2758343 -- Added the following call to recalculate the weightings for existing tasks
    RECALC_FIN_TASK_WEIGHTS(  p_structure_version_id    => l_structure_version_id
                , p_project_id          => p_project_id
                , x_msg_count           => l_msg_count
                , x_msg_data            => l_msg_data
                , x_return_status       => l_return_status);

    IF  l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

        --end sharing on
      ELSIF (p_sharing_enabled_flag = 'Y' AND
          PA_PROJECT_STRUCTURE_UTILS.CHECK_WORKPLAN_ENABLED(p_project_id) = 'N') THEN
        PA_UTILS.ADD_MESSAGE('PA','PA_PS_WP_NOT_EN_SHR_ERR');
        x_msg_data := 'PA_PS_WP_NOT_EN_SHR_ERR';
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (p_sharing_enabled_flag = 'N') THEN
        --Validation
        PA_PROJECT_STRUCTURE_UTILS.check_sharing_off_ok(p_project_id,
                                                        l_ret_stat,
                                                        l_err_msg_code);
        IF (l_ret_stat = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        --sharing off
        --Select version to be kept
        OPEN sel_latest_pub_ver(l_structure_id);
        FETCH sel_latest_pub_ver into l_keep_structure_ver_id;
        IF sel_latest_pub_ver%NOTFOUND THEN
          l_keep_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(l_structure_id);
        END IF;
        CLOSE sel_latest_pub_ver;

        --Delete all other structure versions
        OPEN sel_other_structure_ver(l_keep_structure_ver_id);
        LOOP
          FETCH sel_other_structure_ver into l_del_struc_ver_id,
                                             l_struc_ver_rvn;
          EXIT WHEN sel_other_structure_ver%NOTFOUND;
            PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
            IF (l_return_status <> 'S') THEN
              PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
              x_msg_data := l_err_msg_code;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            --get top tasks
            OPEN get_top_tasks(l_del_struc_ver_id);
            LOOP
              FETCH get_top_tasks into l_task_ver_id;
              EXIT WHEN get_top_tasks%NOTFOUND;

              PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

              IF (l_return_status <> 'S') THEN
                x_return_status := l_return_status;
                PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
                l_msg_data := l_err_msg_code;
                CLOSE get_top_tasks;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;
            CLOSE get_top_tasks;

--          PA_PROJECT_STRUCTURE_PUB1.Delete_Structure_Version(
            PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
          );
----end changes

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            CLOSE sel_other_structure_ver;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END LOOP;
        CLOSE sel_other_structure_ver;

        --NULL all baseline dates
        UPDATE pa_proj_elements
           SET baseline_start_date = NULL,
               baseline_finish_date = NULL,
               record_version_number = record_version_number+1
         WHERE project_id = p_project_id;

        --Delete all schedule rows
        DELETE FROM pa_proj_elem_ver_schedule
        WHERE project_id = p_project_id;

        --Delete wp attr row
        OPEN get_wp_attr_rvn;
        FETCH get_wp_attr_rvn into l_structure_id, l_wp_attr_rvn;
        CLOSE get_wp_attr_rvn;

        PA_WORKPLAN_ATTR_PUB.DELETE_PROJ_WORKPLAN_ATTRS(
            p_validate_only               => FND_API.G_FALSE
           ,p_project_id => p_project_id
           ,p_proj_element_id => l_structure_id
           ,p_record_version_number => l_wp_attr_rvn
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
        );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        PA_PROGRESS_PUB.DELETE_PROJ_PROG_ATTR(
           p_validate_only       => FND_API.G_FALSE
          ,p_project_id          => p_project_id
          ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
          ,P_OBJECT_ID           => l_structure_id
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
        );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Delete structure type
        OPEN sel_wp_struct_type(l_structure_id);
        FETCH sel_wp_struct_type into l_rowid;
        PA_PROJ_STRUCTURE_TYPES_PKG.delete_row(l_rowid);
        CLOSE sel_wp_struct_type;

        --Update structure status to published if project;
        --  working if template
        OPEN get_template_flag;
        FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
        CLOSE get_template_flag;

        OPEN sel_struc_ver_attr_rvn(l_keep_structure_ver_id);
        FETCH sel_struc_ver_attr_rvn into l_pev_structure_id,
                                          l_struc_ver_attr_rvn;
        CLOSE sel_struc_ver_attr_rvn;

        IF (l_template_flag = 'Y') THEN
          l_status_code := 'STRUCTURE_WORKING';
          l_latest_eff_pub_flag := 'N';
          l_effective_date := NULL;
        ELSE
          l_status_code := 'STRUCTURE_PUBLISHED';
          l_latest_eff_pub_flag := 'Y';
          l_effective_date := sysdate;
        END IF;

        --Change status
        UPDATE pa_proj_elem_ver_structure
        set status_code = l_status_code,
            current_flag = 'N',
            current_baseline_date = NULL,
            current_baseline_person_id = NULL,
            latest_eff_published_flag = l_latest_eff_pub_flag,
            effective_date = l_effective_date,
            record_version_number = record_version_number + 1
        where pev_structure_id = l_pev_structure_id;

        --Create structure
        --get project name
        OPEN get_project_info;
        FETCH get_project_info into l_name, l_proj_start_date, l_proj_completion_date;
        CLOSE get_project_info;

        IF (l_proj_completion_date IS NULL AND l_proj_start_date IS NOT NULL) THEN
          l_proj_completion_date := l_proj_start_date;
        ELSIF (l_proj_completion_date IS NULL AND l_proj_start_date IS NULL) THEN
          l_proj_completion_date := sysdate;
          l_proj_start_date := sysdate;
        END IF;

        --get suffix
        select meaning
          into l_suffix
          from pa_lookups
         where lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
           and lookup_code = 'WORKPLAN';

        l_name := substrb(l_name||l_append||l_suffix, 1, 240);
        --Create new structure
        PA_PROJECT_STRUCTURE_PVT1.CREATE_STRUCTURE
         ( p_validate_only           => FND_API.G_FALSE
          ,p_project_id              => p_project_id
          ,p_structure_number        => l_name
          ,p_structure_name          => l_name
          ,p_calling_flag            => 'WORKPLAN'
          ,p_approval_reqd_flag      => l_proj_workplan_attr_rec.WP_APPROVAL_REQD_FLAG
          ,p_auto_publish_flag       => l_proj_workplan_attr_rec.WP_AUTO_PUBLISH_FLAG
          ,p_approver_source_id      => l_proj_workplan_attr_rec.WP_APPROVER_SOURCE_ID
          ,p_approver_source_type    => l_proj_workplan_attr_rec.WP_APPROVER_SOURCE_TYPE
          ,p_default_display_lvl     => l_proj_workplan_attr_rec.WP_DEFAULT_DISPLAY_LVL
          ,p_enable_wp_version_flag  => l_proj_workplan_attr_rec.WP_ENABLE_VERSION_FLAG
          ,p_auto_pub_upon_creation_flag => l_proj_workplan_attr_rec.AUTO_PUB_UPON_CREATION_FLAG
          ,p_auto_sync_txn_date_flag => l_proj_workplan_attr_rec.AUTO_SYNC_TXN_DATE_FLAG
          ,p_txn_date_sync_buf_days  => l_proj_workplan_attr_rec.TXN_DATE_SYNC_BUF_DAYS
--LDENG
      ,p_lifecycle_version_id         => l_proj_workplan_attr_rec.LIFECYCLE_VERSION_ID
      ,p_current_phase_version_id     => l_proj_workplan_attr_rec.CURRENT_PHASE_VERSION_ID
--END LDENG
          ,p_progress_cycle_id => l_proj_progress_attr_rec.PROGRESS_CYCLE_ID
          ,p_wq_enable_flag => l_proj_progress_attr_rec.wq_enable_flag
          ,p_remain_effort_enable_flag => l_proj_progress_attr_rec.remain_effort_enable_flag
          ,p_percent_comp_enable_flag => l_proj_progress_attr_rec.percent_comp_enable_flag
          ,p_next_progress_update_date => l_proj_progress_attr_rec.next_progress_update_date
          ,p_action_set_id       => NULL
          ,p_task_weight_basis_code => l_proj_progress_attr_rec.TASK_WEIGHT_BASIS_CODE
          ,x_structure_id            => l_structure_id
          ,x_return_status           => l_return_status
          ,x_msg_count               => l_msg_count
          ,x_msg_data                => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
        ( p_validate_only         => FND_API.G_FALSE
         ,p_structure_id          => l_structure_id
         ,x_structure_version_id  => l_structure_version_id
         ,x_return_status         => l_return_status
         ,x_msg_count             => l_msg_count
         ,x_msg_data              => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        PA_TASK_PUB1.Create_Schedule_Version(
          p_element_version_id      => l_structure_version_id
         ,p_scheduled_start_date    => l_proj_start_date
         ,p_scheduled_end_date      => l_proj_completion_date
         ,x_pev_schedule_id         => l_pev_schedule_id
         ,x_return_status           => l_return_status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data
        );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Check versioning flag, project or template
        OPEN get_template_flag;
        FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
        CLOSE get_template_flag;

        IF (l_template_flag = 'Y') OR
           (l_template_flag = 'N' AND l_proj_workplan_attr_rec.WP_ENABLE_VERSION_FLAG = 'Y') THEN
          l_status_code := 'STRUCTURE_WORKING';
          l_baseline_flag := 'N';
          l_latest_eff_pub_flag := 'N';
          l_effective_date := NULL;
        ELSE
          l_status_code := 'STRUCTURE_PUBLISHED';
          l_baseline_flag := 'Y';
          l_latest_eff_pub_flag := 'Y';
          l_effective_date := sysdate;
        END IF;

        IF (l_template_flag = 'Y') THEN
          --update project dates
          OPEN get_scheduled_dates(p_project_id, l_structure_version_id);
          FETCH get_scheduled_dates into l_get_sch_dates_cur;
          CLOSE get_scheduled_dates;

          PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
            p_validate_only        => FND_API.G_FALSE
           ,p_project_id           => p_project_id
           ,p_date_type            => 'SCHEDULED'
           ,p_start_date           => l_get_sch_dates_cur.scheduled_start_date
           ,p_finish_date          => l_get_sch_dates_cur.scheduled_finish_date
           ,p_record_version_number=> l_proj_rec_ver_num
           ,x_return_status        => x_return_status
           ,x_msg_count            => x_msg_count
           ,x_msg_data             => x_msg_data );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          IF (l_status_code = 'STRUCTURE_WORKING') THEN
            --clear previously set dates
            UPDATE PA_PROJECTS_ALL
            SET baseline_start_date          = NULL,
                baseline_finish_date         = NULL,
                baseline_duration            = NULL,
                baseline_as_of_date          = NULL,
                scheduled_start_date         = NULL,
                scheduled_finish_date        = NULL,
                scheduled_duration           = NULL,
                scheduled_as_of_date         = NULL
            WHERE Project_id = p_project_id;
          END IF;
        END IF;

        PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
        ( p_validate_only               => FND_API.G_FALSE
         ,p_structure_version_id        => l_structure_version_id
         ,p_structure_version_name      => l_name
         ,p_structure_version_desc      => NULL
         ,p_effective_date              => l_effective_date
         ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
         ,p_locked_status_code          => 'UNLOCKED'
         ,p_struct_version_status_code  => l_status_code
         ,p_baseline_current_flag       => l_baseline_flag
         ,p_baseline_original_flag      => 'N'
         ,x_pev_structure_id            => l_pev_structure_id
         ,x_return_status               => l_return_status
         ,x_msg_count                   => l_msg_count
         ,x_msg_data                    => l_msg_data );

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --end sharing off
      END IF;
      --END SHARING CODE
    END IF;
*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.update_structures_setup_attr end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_struc_setup_attr_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_struc_setup_attr_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'update_structures_setup_attr',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END update_structures_setup_old;

  PROCEDURE update_workplan_versioning
  ( p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_proj_element_id  IN  NUMBER
    ,p_enable_wp_version_flag IN VARCHAR2
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(250);
    l_ret_stat           VARCHAR2(1);
    l_err_msg_code       VARCHAR2(30);
    l_keep_structure_ver_id NUMBER;
    l_template_flag      VARCHAR2(1);
    l_pev_structure_id   NUMBER;
    l_struc_ver_attr_rvn NUMBER;
    l_del_struc_ver_id   NUMBER;
    l_struc_ver_rvn      NUMBER;

    --bug 3125813
    l_project_id         NUMBER;
    l_struc_ver_id       NUMBER;
    --end bug 3125813

    cursor sel_latest_pub_ver(c_structure_id NUMBER) IS
      select a.element_version_id
        from pa_proj_elem_ver_structure a,
             pa_proj_elements b
       where b.proj_element_id = c_structure_id
         and b.project_id = a.project_id
         and b.proj_element_id = a.proj_element_id
         and a.status_code = 'STRUCTURE_PUBLISHED'
         and a.LATEST_EFF_PUBLISHED_FLAG = 'Y';

    CURSOR get_template_flag IS
      select a.template_flag
        from pa_projects_all a,
             pa_proj_elements b
       where a.project_id = b.project_id
         and b.proj_element_id = p_proj_element_id;

    cursor sel_struc_ver_attr_rvn(c_struc_ver_id NUMBER) IS
      select a.PEV_STRUCTURE_ID, a.record_version_number
        from pa_proj_elem_ver_structure a,
             pa_proj_element_versions b
       where b.project_id = a.project_id
         and b.element_version_id = c_struc_ver_id
         and a.element_version_id = b.element_version_id;

    cursor sel_other_structure_ver(c_keep_struc_ver_id NUMBER) IS
      select b.element_version_id, b.record_version_number
        from pa_proj_element_versions a,
             pa_proj_element_versions b
       where a.element_version_id = c_keep_struc_ver_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.element_version_id <> c_keep_struc_ver_id
         and b.object_type = 'PA_STRUCTURES';

    --bug 3125813
    cursor sel_one_struc_ver(c_structure_id NUMBER) IS
      select b.project_id, b.element_version_id
        from pa_proj_elements a,
             pa_proj_element_versions b
       where a.proj_element_id = c_structure_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id;
    --end bug 3125813

   --bug 4263266
   CURSOR cur_chk_tasks(c_project_id NUMBER, c_structure_version_id NUMBER)
   IS
     SELECT 'x' from pa_proj_element_versions
     WHERE project_id = c_project_id
       AND parent_structure_version_id = c_structure_version_id
       AND object_type = 'PA_TASKS'
     ;
   l_dummy     VARCHAR2(1);
   --end bug 4263266

   --BUG 4330926
   l_curr_wp_ver_flag PA_PROJ_WORKPLAN_ATTR.WP_ENABLE_VERSION_FLAG%TYPE;

   CURSOR get_curr_wp_flag (l_proj_element_id NUMBER, l_project_id NUMBER )IS
   SELECT WP_ENABLE_VERSION_FLAG
   FROM   PA_PROJ_WORKPLAN_ATTR
   WHERE  PROJ_ELEMENT_ID = l_proj_element_id
   AND    PROJECT_ID = l_project_id;

   --BUG 4330926

   --bug 4546607
   CURSOR sub_projects ( c_project_id NUMBER, c_relationship_type VARCHAR2)
   IS
        SELECT *
          from pa_structures_links_v
        where parent_project_id= c_project_id
          and relationship_type = c_relationship_type
          ;
   --end bug 4546607

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.update_workplan_versioning');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_wp_versioning_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    IF (p_enable_wp_version_flag = 'Y') THEN
      --enable versioning
      PA_PROJECT_STRUCTURE_UTILS.check_versioning_on_ok(
        p_proj_element_id
       ,l_ret_stat
       ,l_err_msg_code);
       IF (l_ret_stat = 'N') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
       --enable versioning
       --do not need to do anything

       --bug 3125813
       --need to update weightings (if necessary) when enable versiong because
       --structure will become published.
       OPEN sel_one_struc_ver(p_proj_element_id);
       FETCH sel_one_struc_ver into l_project_id, l_struc_ver_id;
       CLOSE sel_one_struc_ver;

--bug 4546607
       --Delete all LW links without checking bcoz versioning is always allowed
       --for workplan.
       FOR sub_projects_rec in sub_projects(l_project_id, 'LW') LOOP
           IF PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(sub_projects_rec.sub_project_id, sub_projects_rec.sub_structure_ver_id) = 'N'
           THEN
               PA_RELATIONSHIP_PUB.Delete_SubProject_Association(
                                        p_object_relationships_id => sub_projects_rec.object_relationship_id,
                                        p_record_version_number   => sub_projects_rec.record_version_number,
                                        x_return_status => l_return_status,
                                        x_msg_count => l_msg_count,
                                        x_msg_data => l_msg_data
                                        );
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
       END LOOP;
--end bug 4546607

       --bug 4263266
       --call process wbs updates only if there is atleast one task.
      OPEN cur_chk_tasks(l_project_id,l_struc_ver_id);
      FETCH cur_chk_tasks INTO l_dummy;
      IF cur_chk_tasks%FOUND
      THEN
       --end bug 4263266
       PA_PROJ_TASK_STRUC_PUB.PROCESS_WBS_UPDATES_WRP(
         p_project_id => l_project_id,
         p_structure_version_id => l_struc_ver_id,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data
       );

       --Check if there is any error.
       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         IF x_msg_count = 1 THEN
           x_msg_data := l_msg_data;
         END IF;
--         CLOSE sel_other_structure_ver;      --Bug 3793128
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       --end bug 3125813
      --bug 4263266
      END IF; --if cur_chk_tasks%FOUND
      CLOSE cur_chk_tasks;
      --end bug 4263266

      --Added by rtarway for BUG 4330926
      OPEN  get_template_flag;
      FETCH get_template_flag into l_template_flag;
      CLOSE get_template_flag;

      OPEN  get_curr_wp_flag(p_proj_element_id ,l_project_id);
      FETCH get_curr_wp_flag into l_curr_wp_ver_flag;
      CLOSE get_curr_wp_flag;

      IF ( l_curr_wp_ver_flag ='N' AND l_template_flag = 'N'   ) THEN
        UPDATE pa_proj_elem_ver_structure
        SET    current_working_flag = 'N'
        WHERE  element_version_id = l_struc_ver_id
        and    project_id = l_project_id;
      END IF;
      --End Added by rtarway for BUG 4330926

       --end enable versioning
    ELSIF (p_enable_wp_version_flag = 'N') THEN
      --disable versioning
      PA_PROJECT_STRUCTURE_UTILS.check_versioning_off_ok(
        p_proj_element_id
       ,l_ret_stat
       ,l_err_msg_code);
      IF (l_ret_stat = 'N') THEN
         PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
         x_msg_data := l_err_msg_code;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --disable versioning
      --Applies to project only
      OPEN get_template_flag;
      FETCH get_template_flag into l_template_flag;
      CLOSE get_template_flag;

      IF (l_template_flag = 'N') THEN
        --Select version to be kept
        OPEN sel_latest_pub_ver(p_proj_element_id);
        FETCH sel_latest_pub_ver into l_keep_structure_ver_id;
        IF sel_latest_pub_ver%NOTFOUND THEN
          l_keep_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(p_proj_element_id);
        END IF;
        CLOSE sel_latest_pub_ver;

        --Delete all versions except the keep version
        OPEN sel_other_structure_ver(l_keep_structure_ver_id);
        LOOP
          FETCH sel_other_structure_ver into l_del_struc_ver_id,
                                             l_struc_ver_rvn;
          EXIT WHEN sel_other_structure_ver%NOTFOUND;
          PA_PROJECT_STRUCTURE_PUB1.Delete_Structure_Version(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
	     ,p_calling_from => 'DEL_WP_STRUC_DISABLE_VERSION' ---Added for bug 6023347
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
          );

          --Check if there is any error.
          l_msg_count := FND_MSG_PUB.count_msg;
          IF l_msg_count > 0 THEN
            x_msg_count := l_msg_count;
            IF x_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            END IF;
            CLOSE sel_other_structure_ver;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END LOOP;
        CLOSE sel_other_structure_ver;

        --Change status
        OPEN sel_struc_ver_attr_rvn(l_keep_structure_ver_id);
        FETCH sel_struc_ver_attr_rvn into l_pev_structure_id,
                                          l_struc_ver_attr_rvn;
        CLOSE sel_struc_ver_attr_rvn;

        --set status to latest published and baselined

        UPDATE pa_proj_elem_ver_structure
        set status_code = 'STRUCTURE_PUBLISHED',
            published_date = sysdate,
            current_flag = 'Y',
            current_baseline_date = sysdate,
            current_baseline_person_id = NULL,
            latest_eff_published_flag = 'Y',
            effective_date = sysdate,
            LOCK_STATUS_CODE = 'UNLOCKED',
            LOCKED_BY_PERSON_ID = NULL,
            LOCKED_DATE = NULL,
            record_version_number = record_version_number + 1
        where pev_structure_id = l_pev_structure_id;

        --baseline structure
        PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                       p_commit => FND_API.G_FALSE,
                       p_structure_version_id => l_keep_structure_ver_id,
                       x_return_status => l_return_status,
                       x_msg_count => l_msg_count,
                       x_msg_data => l_msg_data);

        --Check if there is any error.
        l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count > 0 THEN
          x_msg_count := l_msg_count;
          IF x_msg_count = 1 THEN
            x_msg_data := l_msg_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

       END IF; --for project

       --end disable versioning
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.update_workplan_versioning end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_wp_versioning_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_wp_versioning_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'update_workplan_versioning',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END update_workplan_versioning;


  PROCEDURE update_wp_calendar
  (
     p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id       IN  NUMBER
    ,p_calendar_id      IN  NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_opt                     VARCHAR2(1);

    cursor get_wp_versions IS
      select ppevs.element_version_id
        from pa_proj_elem_ver_structure ppevs,
             pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where ppevs.status_code <> 'STRUCTURE_PUBLISHED'
         and ppevs.project_id = ppe.project_id
         and ppevs.proj_element_id = ppe.proj_element_id
         and ppe.object_type = 'PA_STRUCTURES'
         and ppe.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'WORKPLAN'
         and ppe.project_id = p_project_id
         and '1' = l_opt
      union all
      select ppevs.element_version_id
        from pa_proj_elem_ver_structure ppevs,
             pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where ppevs.status_code = 'STRUCTURE_PUBLISHED'
         and ppevs.project_id = ppe.project_id
         and ppevs.proj_element_id = ppe.proj_element_id
         and ppe.object_type = 'PA_STRUCTURES'
         and ppe.proj_element_id = ppst.proj_element_id
         and ppst.structure_type_id = pst.structure_type_id
         and pst.structure_type_class_code = 'WORKPLAN'
         and ppe.project_id = p_project_id
         and '2' = l_opt;

    l_structure_version_id    NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(250);
    l_sch_hours                   NUMBER;
    l_bsl_hours                   NUMBER;
    l_act_hours                   NUMBER;
    l_days                    NUMBER;
    l_start_date              DATE;
    l_finish_date             DATE;
    l_template_flag           VARCHAR2(1);

    --Bug 3010538.
    l_weight_basis            pa_proj_progress_attr.task_weight_basis_code%TYPE;

    CURSOR c1 IS
      select template_flag
        from pa_projects_all where project_id = p_project_id;

    CURSOR c2 IS
      select SCHEDULED_START_DATE, SCHEDULED_FINISH_DATE
        from pa_projects_all where project_id = p_project_id;

    CURSOR c3 IS
      select ACTUAL_START_DATE, ACTUAL_FINISH_DATE
        from pa_projects_all where project_id = p_project_id;

    CURSOR c4 IS
      select BASELINE_START_DATE, BASELINE_FINISH_DATE
        from pa_projects_all where project_id = p_project_id;
--
    l_sch_dur   NUMBER;          -- Bug 3657808
    l_act_dur   NUMBER;          -- Bug 3657808
    l_bsl_dur   NUMBER;          -- Bug 3657808
--
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_WP_CALENDAR BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_wp_calendar;
    END IF;

    OPEN c1;
    FETCH c1 into l_template_flag;
    CLOSE c1;

    IF (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id) = 'N') THEN
      -- Bug 3010538. Task Weighting enhancement.
      -- For a template even if the versioning flag is enabled, we will have only a
      -- working version and not a published version. Hence setting the option to 1 always
      -- in case of a template so that the working version is queried.
      IF nvl(l_template_flag,'N') = 'Y' THEN
        l_opt := '1';
      ELSE
        l_opt := '2';
      END IF;
      --need to modify
      --SCHEDULED_DURATION (template and project)
      --BASELINE_DURATION (project only)
      --ACTUAL_DURATION   (project only)
      OPEN c2;
      FETCH c2 into l_start_date, l_finish_date;
      CLOSE c2;

      IF (l_start_date IS NOT NULL AND
          l_finish_date IS NOT NULL) THEN
         -- Bug 3657808 Remove duration calculation using calendar
     --Storing in days
          l_sch_dur:=trunc(l_finish_date) - trunc(l_start_date) + 1;
        /*PA_DURATION_UTILS.get_duration(
          p_calendar_id => p_calendar_id
         ,p_start_date => l_start_date
         ,p_end_date => l_finish_date
         ,x_duration_days => l_days
         ,x_duration_hours => l_sch_hours
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := l_msg_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        END IF;*/

      END IF;

      IF (l_template_flag = 'N') THEN
        OPEN c3;
        FETCH c3 into l_start_date, l_finish_date;
        CLOSE c3;

        IF (l_start_date IS NOT NULL AND
            l_finish_date IS NOT NULL) THEN
         -- Bug 3657808 Remove duration calculation using calendar
     --Storing in days
          l_act_dur:=trunc(l_finish_date) - trunc(l_start_date) + 1;
          /*PA_DURATION_UTILS.get_duration(
            p_calendar_id => p_calendar_id
           ,p_start_date => l_start_date
           ,p_end_date => l_finish_date
           ,x_duration_days => l_days
           ,x_duration_hours => l_act_hours
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
          );

         If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
              x_msg_data := l_msg_data;
            end if;
            raise FND_API.G_EXC_ERROR;
          END IF;*/
        END IF;


        OPEN c4;
        FETCH c4 into l_start_date, l_finish_date;
        CLOSE c4;

        IF (l_start_date IS NOT NULL AND
            l_finish_date IS NOT NULL) THEN
         -- Bug 3657808 Remove duration calculation using calendar
     --Storing in days
          l_bsl_dur:=trunc(l_finish_date) - trunc(l_start_date) + 1;
          /*PA_DURATION_UTILS.get_duration(
            p_calendar_id => p_calendar_id
           ,p_start_date => l_start_date
           ,p_end_date => l_finish_date
           ,x_duration_days => l_days
           ,x_duration_hours => l_bsl_hours
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
          );

         If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
              x_msg_data := l_msg_data;
            end if;
            raise FND_API.G_EXC_ERROR;
          END IF;*/
        END IF;

--hsiu: removed record version number for Forms changes
        update pa_projects_all
           /*set SCHEDULED_DURATION = l_sch_hours,
               BASELINE_DURATION = l_bsl_hours,
               ACTUAL_DURATION = l_act_hours*/
           set SCHEDULED_DURATION = l_sch_dur,
               BASELINE_DURATION = l_bsl_dur,
               ACTUAL_DURATION = l_act_dur
         where project_id = p_project_id;

      END IF;
    ELSE
      l_opt := '1';

      IF (l_template_flag =  'Y') THEN
        OPEN c2;
        FETCH c2 into l_start_date, l_finish_date;
        CLOSE c2;

        IF (l_start_date IS NOT NULL AND
            l_finish_date IS NOT NULL) THEN
         -- Bug 3657808 Remove duration calculation using calendar
     --Storing in days
          l_sch_dur:=trunc(l_finish_date) - trunc(l_start_date) + 1;
          /*PA_DURATION_UTILS.get_duration(
            p_calendar_id => p_calendar_id
           ,p_start_date => l_start_date
           ,p_end_date => l_finish_date
           ,x_duration_days => l_days
           ,x_duration_hours => l_sch_hours
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
          );

         If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            x_msg_count := FND_MSG_PUB.count_msg;
            if x_msg_count = 1 then
              x_msg_data := l_msg_data;
            end if;
            raise FND_API.G_EXC_ERROR;
          END IF;*/
        END IF;

--hsiu: removed record version number for Forms changes
        update pa_projects_all
          -- set SCHEDULED_DURATION = l_sch_hours
           set SCHEDULED_DURATION = l_sch_dur
         where project_id = p_project_id;

      END IF;
    END IF;

    -- Bug 3010538. Task Weighting enhancement.
    -- Obtain the task weighting basis for the project.
    l_weight_basis  := pa_progress_utils.get_task_weighting_basis(p_project_id => p_project_id);

--get all working versions
    OPEN get_wp_versions;
    LOOP
      FETCH get_wp_versions into l_structure_version_id;
      EXIT WHEN get_wp_versions%NOTFOUND;

      -- Bug 3010538. Task Weighting enhancement.
      -- The weightage needs to be recalculated for the structure version(s), if the task
      -- weighting basis is DURATION. Recalculation has to be done for the only version(that
      -- is published) if versioning is disabled and for all the non published versions when
      -- versioning is enabled in case of a project and for the working version in case of a
      -- template.
      IF l_weight_basis = 'DURATION' THEN
          -- Always call this API as the cursor would have taken care to select the appropriate
          -- structure version for processing.
               pa_proj_task_struc_pub.set_update_wbs_flag(
                     p_project_id            => p_project_id
                    ,p_structure_version_id  => l_structure_version_id
                    ,x_return_status         => l_return_status
                    ,x_msg_count             => l_msg_count
                    ,x_msg_data              => l_msg_data
               );

                If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  x_msg_count := FND_MSG_PUB.count_msg;
                  if x_msg_count = 1 then
                    x_msg_data := l_msg_data;
                  end if;
                  raise FND_API.G_EXC_ERROR;
                END IF;
      END IF;

      PA_PROJECT_STRUCTURE_PVT1.RECALC_STRUC_VER_DURATION(
         p_structure_version_id => l_structure_version_id
        ,p_calendar_id          => p_calendar_id
        ,x_return_status        => l_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
      );

      If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        x_msg_count := FND_MSG_PUB.count_msg;
        if x_msg_count = 1 then
          x_msg_data := l_msg_data;
        end if;
        raise FND_API.G_EXC_ERROR;
      END IF;

--update duration for all working structure versions
    END LOOP;
    CLOSE get_wp_versions;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_WP_CALENDAR end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_wp_calendar;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_wp_calendar;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Update_wp_calendar',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END update_wp_calendar;

  PROCEDURE update_all_wp_calendar
  (
     p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_calendar_id      IN  NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  is
    Cursor c_calendar_projects
    IS
    Select project_id
    from pa_projects_all
    where calendar_id = p_calendar_id;
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_ALL_WP_CALENDAR BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_all_wp_calendar;
    END IF;

    FOR c_rec IN c_calendar_projects
    LOOP
        PA_PROJECT_STRUCTURE_PVT1.update_wp_calendar
               (
                p_api_version       => p_api_version
                ,p_init_msg_list    => p_init_msg_list
                ,p_commit           => p_commit
                ,p_validate_only    => p_validate_only
                ,p_validation_level => p_validation_level
                ,p_calling_module   => p_calling_module
                ,p_debug_mode       => p_debug_mode
                ,p_max_msg_count    => p_max_msg_count
                ,p_project_id       => c_rec.project_id
                ,p_calendar_id      => p_calendar_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                );
   END LOOP;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.UPDATE_ALL_WP_CALENDAR END');
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to update_all_wp_calendar;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        --put message
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Update_all_wp_calendar',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END UPDATE_ALL_WP_CALENDAR;


  PROCEDURE RECALC_STRUC_VER_DURATION(
     p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_structure_version_id IN NUMBER
    ,p_calendar_id      IN  NUMBER
    ,x_return_status    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    CURSOR get_dates IS
      select ppvsch.pev_schedule_id,
             ppvsch.scheduled_start_date, ppvsch.scheduled_finish_date,
             ppvsch.estimated_start_date, ppvsch.estimated_finish_date,
             ppvsch.actual_start_date, ppvsch.actual_finish_date
        from pa_proj_elem_ver_schedule ppvsch,
             pa_proj_element_versions ppv
       where ppv.parent_structure_version_id = p_structure_version_id
         and ppv.project_id = ppvsch.project_id
         and ppv.proj_element_id = ppvsch.proj_element_id
         and ppv.element_version_id = ppvsch.element_version_id;

    l_pev_schedule_id       NUMBER;
    l_days                  NUMBER;
    l_hours                 NUMBER;
    l_scheduled_start_date  DATE;
    l_scheduled_finish_date DATE;
    l_estimated_start_date  DATE;
    l_estimated_finish_date DATE;
    l_actual_start_date     DATE;
    l_actual_finish_date    DATE;

    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(250);
    l_act_days              NUMBER;                -- Bug 3657808
    l_sch_days              NUMBER;                -- Bug 3657808
    l_est_days              NUMBER;                -- Bug 3657808
  BEGIN

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.RECALC_STRUC_VER_DURATION BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint RECALC_STRUC_VER_DURATION;
    END IF;

    OPEN get_dates;
    LOOP
      FETCH get_dates INTO l_pev_schedule_id,
                           l_scheduled_start_date,
                           l_scheduled_finish_date,
                           l_estimated_start_date,
                           l_estimated_finish_date,
                           l_actual_start_date,
                           l_actual_finish_date;
      EXIT WHEN get_dates%NOTFOUND;

--Update calendar id
      UPDATE PA_PROJ_ELEM_VER_SCHEDULE
         SET calendar_id = p_calendar_id
       WHERE pev_schedule_id = l_pev_schedule_id;

--Update schedule dates
      IF (l_scheduled_start_date IS NOT NULL AND
          l_scheduled_finish_date IS NOT NULL) THEN
        -- Bug 3657808 Remove duration calculation using calendar
        --Storing in days
        l_sch_days:=trunc(l_scheduled_finish_date) - trunc(l_scheduled_start_date) + 1;
        /*PA_DURATION_UTILS.get_duration(
          p_calendar_id => p_calendar_id
         ,p_start_date => l_scheduled_start_date
         ,p_end_date => l_scheduled_finish_date
         ,x_duration_days => l_days
         ,x_duration_hours => l_hours
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := l_msg_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        END IF;*/

        UPDATE PA_PROJ_ELEM_VER_SCHEDULE
           --SET DURATION = l_hours
           SET DURATION = l_sch_days
         WHERE pev_schedule_id = l_pev_schedule_id;
      END IF;

--Update estimated dates
      IF (l_estimated_start_date IS NOT NULL AND
          l_estimated_finish_date IS NOT NULL) THEN
        -- Bug 3657808 Remove duration calculation using calendar
        --Storing in days
    /* Commented call to API for 4210634 - It was missed during code fix for bug 3657808 */
        l_est_days:=trunc(l_estimated_finish_date) - trunc(l_estimated_start_date) + 1;
        /* PA_DURATION_UTILS.get_duration(
          p_calendar_id => p_calendar_id
         ,p_start_date => l_estimated_start_date
         ,p_end_date => l_estimated_finish_date
         ,x_duration_days => l_days
         ,x_duration_hours => l_hours
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := l_msg_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        END IF; */

        UPDATE PA_PROJ_ELEM_VER_SCHEDULE
           --SET ESTIMATED_DURATION = l_hours
           SET ESTIMATED_DURATION = l_est_days
         WHERE pev_schedule_id = l_pev_schedule_id;
      END IF;

--Update actual dates
      IF (l_actual_start_date IS NOT NULL AND
          l_actual_finish_date IS NOT NULL) THEN
        -- Bug 3657808 Remove duration calculation using calendar
        --Storing in days
        l_act_days:=trunc(l_actual_finish_date) - trunc(l_actual_start_date) + 1;
        /*PA_DURATION_UTILS.get_duration(
          p_calendar_id => p_calendar_id
         ,p_start_date => l_actual_start_date
         ,p_end_date => l_actual_finish_date
         ,x_duration_days => l_days
         ,x_duration_hours => l_hours
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        If (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          x_msg_count := FND_MSG_PUB.count_msg;
          if x_msg_count = 1 then
            x_msg_data := l_msg_data;
          end if;
          raise FND_API.G_EXC_ERROR;
        END IF;*/

        UPDATE PA_PROJ_ELEM_VER_SCHEDULE
--           SET ACTUAL_DURATION = l_hours
           SET ACTUAL_DURATION = l_act_days
         WHERE pev_schedule_id = l_pev_schedule_id;
      END IF;

    END LOOP;
    CLOSE get_dates;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.RECALC_STRUC_VER_DURATION end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to RECALC_STRUC_VER_DURATION;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to RECALC_STRUC_VER_DURATION;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'RECALC_STRUC_VER_DURATION',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END RECALC_STRUC_VER_DURATION;


  procedure Delete_Struc_Ver_Wo_Val
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'Delete_Struc_Ver_Wo_Val';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;

    l_dummy                VARCHAR2(1);
    l_error_message_code   VARCHAR2(250);

    CURSOR get_struc_ver IS
           select pev.project_id, pe.proj_element_id, pe.record_version_number,
                  pev.element_version_id, pev.record_version_number,
                  pevs.pev_structure_id, pevs.record_version_number,
                  pevsh.pev_schedule_id, pevsh.record_version_number,
                  pevsh.rowid
             from pa_proj_elements pe,
                  pa_proj_element_versions pev,
                  pa_proj_elem_ver_structure pevs,
                  pa_proj_elem_ver_schedule pevsh
            where pev.element_version_id = p_structure_version_id and
                  pev.proj_element_id = pe.proj_element_id and
                  pev.project_id = pevs.project_id and
                  pev.element_version_id = pevs.element_version_id and
                  pev.project_id = pevsh.project_id (+) and
                  pev.element_version_id = pevsh.element_version_id (+);

    CURSOR is_last_version(p_structure_id NUMBER) IS
           select 'N'
             from pa_proj_element_versions
            where proj_element_id = p_structure_id;

    CURSOR get_top_tasks IS
           select v.element_version_id
             from pa_proj_element_versions v,
                  pa_object_relationships r
            where v.element_version_id = r.object_id_to1
              and r.object_id_from1 = p_structure_version_id
              and r.object_type_from = 'PA_STRUCTURES';

    cursor sel_wp_attr(c_proj_element_id NUMBER) IS
      select record_version_number
        from pa_proj_workplan_attr
       where proj_element_id = c_proj_element_id;

    l_project_id          PA_PROJ_ELEMENT_VERSIONS.PROJECT_ID%TYPE;
    l_proj_element_id     PA_PROJ_ELEMENTS.PROJ_ELEMENT_ID%TYPE;
    l_pe_rvn              PA_PROJ_ELEMENTS.RECORD_VERSION_NUMBER%TYPE;
    l_element_version_id  PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
    l_pev_rvn             PA_PROJ_ELEMENT_VERSIONS.RECORD_VERSION_NUMBER%TYPE;
    l_pev_structure_id    PA_PROJ_ELEM_VER_STRUCTURE.PEV_STRUCTURE_ID%TYPE;
    l_pevs_rvn            PA_PROJ_ELEM_VER_STRUCTURE.RECORD_VERSION_NUMBER%TYPE;
    l_pev_schedule_id     PA_PROJ_ELEM_VER_SCHEDULE.PEV_SCHEDULE_ID%TYPE;
    l_pevsh_rvn           PA_PROJ_ELEM_VER_SCHEDULE.RECORD_VERSION_NUMBER%TYPE;
    l_pevsh_rowid         VARCHAR2(255);

    l_task_version_id     PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
    l_task_rvn            PA_PROJ_ELEMENT_VERSIONS.RECORD_VERSION_NUMBER%TYPE;
    l_wp_attr_rvn         PA_PROJ_WORKPLAN_ATTR.RECORD_VERSION_NUMBER%TYPE;

    l_parent_struc_ver_id PA_PROJ_ELEMENT_VERSIONS.PARENT_STRUCTURE_VERSION_ID%TYPE;

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_struc_ver_wo_val;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('get structure version_info');
    END IF;

    --Delete logic
    --Get structure version information
    OPEN get_struc_ver;
    FETCH get_struc_ver INTO l_project_id,
                             l_proj_element_id,
                             l_pe_rvn,
                             l_element_version_id,
                             l_pev_rvn,
                             l_pev_structure_id,
                             l_pevs_rvn,
                             l_pev_schedule_id,
                             l_pevsh_rvn,
                             l_pevsh_rowid;
    IF (get_struc_ver%NOTFOUND) THEN
      CLOSE get_struc_ver;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE get_struc_ver;

    --NO ERROR, call delete_task_ver_wo_val
    --select all top level tasks
    OPEN get_top_tasks;
    LOOP
      FETCH get_top_tasks into l_task_version_id;
      EXIT WHEN get_top_tasks%NOTFOUND;
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('deleting task version '||to_char(l_task_version_id));
      END IF;

      --Get record version number for task, as it will change everytime
      --a task is deleted.
      select record_version_number, parent_structure_version_id
      into l_task_rvn, l_parent_struc_ver_id
      from pa_proj_element_versions
      where element_version_id = l_task_version_id;


      PA_TASK_PVT1.DELETE_TASK_VER_WO_VAL(p_commit => 'N',
                                       p_debug_mode => p_debug_mode,
                                       p_calling_module => 'DEL_STRUCT',
                                       p_structure_version_id => l_parent_struc_ver_id,
                                       p_task_version_id => l_task_version_id,
                                       p_record_version_number => l_task_rvn,
                                       x_return_status => l_return_status,
                                       x_msg_count => l_msg_count,
                                       x_msg_data => l_msg_data);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_count := FND_MSG_PUB.count_msg;
        IF x_msg_count = 1 then
           pa_interface_utils_pub.get_messages
           (p_encoded        => FND_API.G_TRUE,
            p_msg_index      => 1,
            p_data           => l_data,
            p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
        END IF;
        CLOSE get_top_tasks;
        raise FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE get_top_tasks;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('done deleting tasks');
    END IF;
    --If all tasks are deleted, delete schedule if workplan
    --Check if this is workplan
    If ('Y' = PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN')) THEN
       --Structure type exists. Delete from schedule table
       IF (p_debug_mode = 'Y') THEN
         pa_debug.debug('WORKPLAN type');
       END IF;
       PA_PROJ_ELEMENT_SCH_PKG.Delete_Row(l_pevsh_rowid);

       --bug 4172646
       --remove the code to call PA_FIN_PLAN_PVT.delete_wp_budget_versions as its also called from
       --PA_PROJECT_STRUCTURE_PVT1.delete_structure_versions API.
       --

    END IF;

    --check for errors.
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('del structure version attr');
    END IF;
    --Delete structure version attribute
    PA_PROJECT_STRUCTURE_PVT1.Delete_Structure_Version_Attr(
                        p_commit => p_commit,
                        p_debug_mode => p_debug_mode,
                        p_pev_structure_id => l_pev_structure_id,
                        p_record_version_number => l_pevs_rvn,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('del structure version');
    END IF;

    --Delete structure version
    PA_PROJECT_STRUCTURE_PVT1.Delete_Structure_Version(
                        p_commit => p_commit,
                        p_debug_mode => p_debug_mode,
                        p_structure_version_id => l_element_version_id,
                        p_record_version_number => l_pev_rvn,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
--          p_msg_count      => l_msg_count,
--          p_msg_data       => l_msg_data,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;


    --Delete structure if this is the last version
    OPEN is_last_version(l_proj_element_id);
    FETCH is_last_version into l_dummy;
    IF is_last_version%NOTFOUND THEN
      --We are deleting the last version. Delete structure
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('delete non-versioned structure');
      END IF;


      IF (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(l_proj_element_id, 'WORKPLAN') = 'Y') THEN
        --delete workplan attribute
        OPEN sel_wp_attr(l_proj_element_id);
        FETCH sel_wp_attr into l_wp_attr_rvn;
        CLOSE sel_wp_attr;

        PA_WORKPLAN_ATTR_PUB.DELETE_PROJ_WORKPLAN_ATTRS(
          p_validate_only => FND_API.G_FALSE
         ,p_project_id => l_project_id
         ,p_proj_element_id => l_proj_element_id
         ,p_record_version_number => l_wp_attr_rvn
         ,x_return_status => l_return_status
         ,x_msg_count => l_msg_count
         ,x_msg_data => l_msg_data
        );

        --Check error
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count = 1 then
             pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

        PA_PROGRESS_PUB.DELETE_PROJ_PROG_ATTR(
          p_validate_only        => FND_API.G_FALSE
         ,p_project_id           => l_project_id
         ,P_OBJECT_TYPE          => 'PA_STRUCTURES'
         ,p_object_id            => l_proj_element_id
     ,p_structure_type       => 'WORKPLAN' --Amit
         ,x_return_status        => l_return_status
         ,x_msg_count            => l_msg_count
         ,x_msg_data             => l_msg_data
        );

        --Check error
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count = 1 then
             pa_interface_utils_pub.get_messages
             (p_encoded        => FND_API.G_TRUE,
              p_msg_index      => 1,
              p_data           => l_data,
              p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
          END IF;
          raise FND_API.G_EXC_ERROR;
        END IF;

      END IF;

      select record_version_number into l_pe_rvn
      from pa_proj_elements where proj_element_id = l_proj_element_id;
      PA_PROJECT_STRUCTURE_PVT1.Delete_Structure(
                        p_commit => p_commit,
                        p_debug_mode => p_debug_mode,
                        p_structure_id => l_proj_element_id,
                        p_record_version_number => l_pe_rvn,
                        x_return_status => l_return_status,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);

    END IF;
    CLOSE is_last_version;

    --Check error
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      END IF;
      raise FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL end');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
        rollback to delete_struc_ver_wo_val;
      end if;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
        rollback to delete_struc_ver_wo_val;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Delete_Struc_Ver_Wo_Val',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_struc_ver_wo_val;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Delete_Struc_Ver_Wo_Val',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END DELETE_STRUC_VER_WO_VAL;

  procedure Generate_Error_Page
  (
    p_api_version                      IN  NUMBER     := 1.0
   ,p_commit                           IN  VARCHAR2   := 'N'
   ,p_calling_module                   IN  VARCHAR2   := 'SELF_SERVICE'
   ,p_debug_mode                       IN  VARCHAR2   := 'N'
   ,p_max_msg_count                    IN  NUMBER     := NULL
   ,p_structure_version_id             IN  NUMBER
   ,p_error_tbl                        IN  PA_PUBLISH_ERR_TBL_TYPE
   ,x_page_content_id                  OUT NOCOPY NUMBER
   ,x_return_status                    OUT NOCOPY VARCHAR2
   ,x_msg_count                        OUT NOCOPY NUMBER
   ,x_msg_data                         OUT NOCOPY VARCHAR2
  )
  IS PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR get_struct_ver_info IS
      select a.name, a.version_number, c.scheduled_start_date,
             c.scheduled_finish_date, b.project_id
        from pa_proj_elem_ver_structure a,
             pa_proj_element_versions b,
             pa_proj_elem_ver_schedule c
       where b.element_version_id = p_structure_version_id
         and b.project_id = a.project_id
         and b.proj_element_id = a.proj_element_id
         and b.element_version_id = a.element_version_id
         and b.project_id = c.project_id
         and b.proj_element_id = c.proj_element_id
         and b.element_version_id = c.element_version_id;
    l_struc_ver_info_rec get_struct_ver_info%ROWTYPE;

    CURSOR get_project_info(c_project_id NUMBER) IS
      select ppa.name name, ppa.segment1,
             hou.name carrying_out_org_name, ppl.full_name
        from pa_projects_all ppa,
             hr_all_organization_units hou,
             per_all_people_f ppl,
             pa_project_parties ppp
       where ppa.carrying_out_organization_id = hou.organization_id
         and ppa.project_id = ppp.project_id (+)
         and ppa.project_id = c_project_id
         and 1 = ppp.project_role_id (+)
         and sysdate between ppp.start_date_active(+)
             and nvl(ppp.end_date_active(+), sysdate)
         and ppp.resource_source_id = ppl.person_id (+)
         and sysdate between ppl.effective_start_date(+)
             and nvl(ppl.effective_end_date (+), sysdate);
    l_proj_info_rec get_project_info%ROWTYPE;

    CURSOR get_lookup_meaning(c_lookup_code VARCHAR2) IS
      select meaning
        from pa_lookups
       where lookup_type = 'PA_WORKPLAN_ERROR_NOTIF'
         and lookup_code = c_lookup_code;
    l_workplan_version_err      varchar2(80);
    l_err_instruction           varchar2(80);
    l_project_info              varchar2(80);
    l_project_name              varchar2(80);
    l_project_num               varchar2(80);
    l_project_mgr               varchar2(80);
    l_project_org               varchar2(80);
    l_workplan_ver_info         varchar2(80);
    l_workplan_ver_name         varchar2(80);
    l_workplan_ver_num          varchar2(80);
    l_wp_sch_start_date         varchar2(80);
    l_wp_sch_finish_date        varchar2(80);
    l_error_header              varchar2(80);
    l_error                     varchar2(80);

    l_page_content_id           NUMBER;
    l_clob                      clob;
    l_text                      VARCHAR2(32767);
    l_index                     NUMBER;
    l_item_key                  VARCHAR2(240);
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(250);
    l_err_code                  NUMBER:= 0;
    l_err_stack                 VARCHAR2(630);
    l_err_stage                 VARCHAR2(80);

  BEGIN

    OPEN get_struct_ver_info;
    FETCH get_struct_ver_info INTO l_struc_ver_info_rec;
    CLOSE get_struct_ver_info;

    OPEN get_project_info(l_struc_ver_info_rec.project_id);
    FETCH get_project_info INTO l_proj_info_rec;
    CLOSE get_project_info;

    --get headers and prompts
    OPEN get_lookup_meaning('PA_WORKPLAN_VERSION_ERR');
    FETCH get_lookup_meaning into l_workplan_version_err;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_ERR_INSTRUCTION');
    FETCH get_lookup_meaning into l_err_instruction;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_PROJECT_INFO');
    FETCH get_lookup_meaning into l_project_info;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_PROJECT_NAME');
    FETCH get_lookup_meaning into l_project_name;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_PROJECT_NUM');
    FETCH get_lookup_meaning into l_project_num;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_PROJECT_MGR');
    FETCH get_lookup_meaning into l_project_mgr;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_PROJECT_ORG');
    FETCH get_lookup_meaning into l_project_org;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_WORKPLAN_VER_INFO');
    FETCH get_lookup_meaning into l_workplan_ver_info;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_WORKPLAN_VER_NAME');
    FETCH get_lookup_meaning into l_workplan_ver_name;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_WORKPLAN_VER_NUM');
    FETCH get_lookup_meaning into l_workplan_ver_num;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_WP_SCH_START_DATE');
    FETCH get_lookup_meaning into l_wp_sch_start_date;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_WP_SCH_FINISH_DATE');
    FETCH get_lookup_meaning into l_wp_sch_finish_date;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_ERROR_HEADER');
    FETCH get_lookup_meaning into l_error_header;
    CLOSE get_lookup_meaning;

    OPEN get_lookup_meaning('PA_ERROR');
    FETCH get_lookup_meaning into l_error;
    CLOSE get_lookup_meaning;
    --done getting header and prompt

    --create record in pa_page_layouts
    PA_PAGE_CONTENTS_PUB.CREATE_PAGE_CONTENTS(
      p_init_msg_list   => fnd_api.g_false
     ,p_validate_only   => fnd_api.g_false
     ,p_object_type     => 'PA_STRUCTURES'
     ,p_pk1_value       => p_structure_version_id
     ,p_pk2_value       => 1
     ,x_page_content_id => x_page_content_id
     ,x_return_status   => x_return_status
     ,x_msg_count       => x_msg_count
     ,x_msg_data        => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create notification page
    select page_content
    into l_clob
    from pa_page_contents
    where page_content_id = x_page_content_id for update;

    --print title
    l_text := '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td><table cellspacing=0 cellpadding=0 width="100%" border=0 summary="">';
    l_text := l_text||'<tbody><tr><td width="100%"><font class="OraHeader" face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3c3c3c" size="5">';
    l_text := l_text||l_workplan_version_err||': ';
    l_text := l_text||l_struc_ver_info_rec.name;
    l_text := l_text||' ('||l_struc_ver_info_rec.version_number||')';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print instruction text
    l_text := '</font></td></tr><tr><td class=OraBGAccentDark bgcolor=#cfe0f1></td></tr></tbody></table><table cellspacing=0 cellpadding=0 width="100%" border=0 summary="">';
    l_text := l_text||'<tbody><tr><td><table cellspacing=0 cellpadding=0 border=0 summary=""><tbody><tr><td></td><td><span>';
    l_text := l_text||'<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
    l_text := l_text||l_err_instruction||'</font></span></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print project info
    l_text := '</tr></tbody></table><table cellspacing=10 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td valign=top width="100%">';
    l_text := l_text||'<table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td height=17></td></tr><tr><td width=20 rowspan=3>';
    l_text := l_text||'</td><td><table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td width="100%">';
    l_text := l_text||'<font class=OraHeaderSub face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#3c3c3c><b>';
    l_text := l_text||l_project_info||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print project name
    l_text := '</tr><tr><td class=OraBGAccentDark bgcolor=#cfe0f1></td></tr></tbody></table></td></tr><tr><td height=2></td></tr><tr><td>';
    l_text := l_text||'<table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td><table cellspacing=0 cellpadding=0 border=0 summary="">';
    l_text := l_text||'<tbody><tr><td width="5%"></td><td valign=top><table cellspacing=0 cellpadding=0 border=0 summary="">';
    l_text := l_text||'<tbody><tr><td noWrap align=right><span align="right"><font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2>';
    l_text := l_text||'<label>';
    l_text := l_text||l_project_name||'</label></font></span></td><td width=12></td><td><font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_proj_info_rec.name||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print project number
    l_text := '</tr><tr><td height=3></td><td></td><td></td></tr><tr><td noWrap align=right><span align="right">';
    l_text := l_text||'<font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_project_num||'</label></font></span></td><td width=12></td><td><font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_proj_info_rec.segment1||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print project manager
    l_text := '</tr><tr><td height=3></td><td></td><td></td></tr></tbody></table></td><td width="5%"></td><td valign=top>';
    l_text := l_text||'<table cellspacing=0 cellpadding=0 border=0 summary=""><tbody><tr><td noWrap align=right><span align="right">';
    l_text := l_text||'<font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_project_mgr||'</label></font></span></td>';
    l_text := l_text||'<td width=12></td><td><font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_proj_info_rec.full_name||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print organization
    l_text := '</tr><tr><td height=3></td><td></td><td></td></tr><tr><td noWrap align=right><span align="right">';
    l_text := l_text||'<font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_project_org||'</label></font></span></td><td width=12></td><td><font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_proj_info_rec.carrying_out_org_name;
    l_text := l_text||'</b></font></td></tr><tr><td height=3></td><td></td><td></td></tr></tbody></table></td></tr></tbody></table>';
    l_text := l_text||'</td></tr></tbody></table></td></tr></tbody></table>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print workplan version information
    l_text := '<div><table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td height=17></td></tr><tr><td width=20 rowspan=3>';
    l_text := l_text||'</td><td><table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td width="100%">';
    l_text := l_text||'<font class=OraHeaderSub face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#3c3c3c><b>';
    l_text := l_text||l_workplan_ver_info||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print version name
    l_text := '</tr><tr><td class=OraBGAccentDark bgcolor=#cfe0f1></td></tr></tbody></table></td></tr><tr><td height=2></td></tr><tr><td>';
    l_text := l_text||'<table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td><table cellspacing=0 cellpadding=0 border=0 summary="" width="319">';
    l_text := l_text||'<tbody><tr><td width="5%"></td><td valign=top><table cellspacing=0 cellpadding=0 border=0 summary="" width="419">';
    l_text := l_text||'<tbody><tr><td noWrap align=right width="177"><span align="right">';
    l_text := l_text||'<font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_workplan_ver_name||'</label></font></span></td><td width=12></td><td width="198">';
    l_text := l_text||'<font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_struc_ver_info_rec.name||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print version number
    l_text := '</tr><tr><td height=3 width="177"></td><td width="12"></td><td width="198"></td></tr><tr><td noWrap align=right width="177">';
    l_text := l_text||'<span align="right"><font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_workplan_ver_num||'</label></font></span></td>';
    l_text := l_text||'<td width=12></td><td width="198"><font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_struc_ver_info_rec.version_number||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    l_text := '</tr><tr><td height=3 width="177"></td><td width="12"></td><td width="198"></td></tr><tr><td noWrap align=right width="177">';
    l_text := l_text||'<span align="right"><font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_wp_sch_start_date||'</label></font></span></td><td width=12></td><td width="198">';
    l_text := l_text||'<font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_struc_ver_info_rec.scheduled_start_date||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print scheduled finish date
    l_text := '</tr><tr><td height=3 width="177"></td><td width="12"></td><td width="198"></td></tr><tr><td noWrap align=right width="177">';
    l_text := l_text||'<span align="right"><font class=OraPromptText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><label>';
    l_text := l_text||l_wp_sch_finish_date||'</label></font></span></td><td width=12></td><td width="198">';
    l_text := l_text||'<font class=OraDataText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><b>';
    l_text := l_text||l_struc_ver_info_rec.scheduled_finish_date||'</b></font></td></tr></tbody></table></td></tr></tbody></table><div></div></td>';
    l_text := l_text||'</tr></tbody></table></td></tr></tbody></table></div><div></div>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print error header
    l_text := '<div><table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td height=17></td></tr><tr><td width=20 rowspan=3>';
    l_text := l_text||'</td><td><table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td width="100%">';
    l_text := l_text||'<font class=OraHeaderSub face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#3c3c3c><b>';
    l_text := l_text||l_error_header||'</b></font></td>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print error table

    l_text := '</tr><tr><td class=OraBGAccentDark bgcolor=#cfe0f1></td></tr></tbody></table></td></tr><tr><td height=2></td></tr><tr><td>';
    l_text := l_text||'<table cellspacing=0 cellpadding=0 width="100%" border=0 summary=""><tbody><tr><td><table cellspacing=0 cellpadding=0 width=0 border=0 summary="">';
    l_text := l_text||' <tbody><tr><td class=OraTable bgcolor=#999966><table style="BORDER-COLLAPSE: collapse" cellspacing=0 cellpadding=1 width="100%" border=0 summary="">';
    l_text := l_text||'<tbody><tr><th style="BORDER-LEFT: #f2f2f5 1px solid" valign=bottom align=left bgcolor=#cfe0f1 scope="col">';
    l_text := l_text||'<font class=OraTableColumnHeader face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#3c3c3c size=2>';
    l_text := l_text||'<b><span class=OraTableHeaderLink bgcolor="#cfe0f1">';
    l_text := l_text||l_error||'</span></b></font></th></tr>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --print errors
    --loop
    l_index := p_error_tbl.FIRST;
    LOOP
      l_text := '<tr><td style="BORDER-RIGHT: #cfe0f1 1px solid; BORDER-TOP: #cfe0f1 1px solid; BORDER-LEFT: #cfe0f1 1px solid; BORDER-BOTTOM: #cfe0f1 1px solid" valign=baseline noWrap bgcolor=#f2f2f5>';
      l_text := l_text||'<font class=OraTableCellText face=Tahoma,Arial,Helvetica,Geneva,sans-serif color=#000000 size=2><span>';
      l_text := l_text||p_error_tbl(l_index)||'</span></font></td></tr>';

      PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
        l_text
       ,l_clob);

      EXIT WHEN l_index = p_error_tbl.LAST;
      l_index := p_error_tbl.next(l_index);

    END LOOP;
    --end loop
    --print end

    l_text := '</tbody></table></td></tr></tbody></table><div></div><table cellspacing=0 cellpadding=0 border=0 summary=""><tbody><tr>';
    l_text := l_text||'<td width="5%"></td><td valign=top><table cellspacing=0 cellpadding=0 border=0 summary=""><tbody></tbody></table></td>';
    l_text := l_text||'</tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></div></td></tr></tbody></table></td>';
    l_text := l_text||'</tr></tbody></table><p></p><p></p></td></tr></table>';

    PA_PROJECT_STRUCTURE_PVT1.APPEND_VARCHAR_TO_CLOB(
      l_text
     ,l_clob);

    --send notification
    PA_WORKPLAN_WORKFLOW.START_WORKFLOW(
          'PAWFPPWP'
         ,'PA_WORKPLAN_ERRORS'
         ,p_structure_version_id
         ,NULL
         ,NULL
         ,l_item_key
         ,l_msg_count
         ,l_msg_data
         ,l_return_status
        );
    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      PA_WORKFLOW_UTILS.INSERT_WF_PROCESSES(
             p_wf_type_code =>      'WORKPLAN'
            ,p_item_type    =>      'PAWFPPWP'
            ,p_item_key     =>      l_item_key
            ,p_entity_key1  =>      l_struc_ver_info_rec.project_id
            ,p_entity_key2  =>      p_structure_version_id
            ,p_description  =>      NULL
            ,p_err_code     =>      l_err_code
            ,p_err_stage    =>      l_err_stage
            ,p_err_stack    =>      l_err_stack
          );
      IF (l_err_code <> 0) THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_PS_CREATE_WF_FAILED');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_CREATE_WF_FAILED');
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    COMMIT;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      ROLLBACK;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when OTHERS then
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'Generate_Error_Page',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Generate_Error_Page;


  PROCEDURE APPEND_VARCHAR_TO_CLOB(p_varchar IN varchar2,
                                   p_clob    IN OUT NOCOPY CLOB)
  IS
    l_chunkSize   INTEGER;
    v_offset      INTEGER := 0;
    l_clob        clob;
    l_length      INTEGER;

    v_size        NUMBER;
    v_text        VARCHAR2(3000);  -- Bug 3634909. Increased to 3000 from 1000
  BEGIN
    l_chunksize := length(p_varchar);
    l_length := dbms_lob.getlength(p_clob);

    dbms_lob.write(p_clob,
                   l_chunksize,
                   l_length+1,
                   p_varchar);
    v_size := 1000;
    dbms_lob.read(p_clob, v_size, 1, v_text);
  END APPEND_VARCHAR_TO_CLOB;

-- Following procedure is added for Bug 2758343
-- It will recalculate the task weightings based on
-- duration for a given project and structure version id

PROCEDURE RECALC_FIN_TASK_WEIGHTS
( p_structure_version_id IN NUMBER
 ,p_project_id           IN NUMBER
 ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status        OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS

CURSOR c_get_task_ver IS
    SELECT element_version_id
         , wbs_level
    FROM   pa_proj_element_versions
    WHERE  project_id = p_project_id
    AND    parent_structure_version_id = p_structure_version_id
    AND    object_type = 'PA_TASKS';

CURSOR check_progress_allowed(c_element_version_id NUMBER) IS
    SELECT ptt.prog_entry_enable_flag
    FROM   pa_task_types ptt
         , pa_proj_element_versions ppev
         , pa_proj_elements ppe
    WHERE  ppev.element_version_id = c_element_version_id
    AND    ppev.proj_element_id = ppe.proj_element_id
    AND    ptt.object_type ='PA_TASKS'              /* bug 3279978 FP M Enhancement */
    AND    ppe.TYPE_ID   = ptt.task_type_id;

CURSOR get_parent(c_element_version_id NUMBER) IS
    SELECT object_id_from1
    FROM   pa_object_relationships
    WHERE  object_id_to1 = c_element_version_id
    AND    object_type_to = 'PA_TASKS'
    AND    relationship_type = 'S'
    AND    object_type_from IN ('PA_STRUCTURES', 'PA_TASKS');

 CURSOR get_summed_duration(c_parent_element_version_id NUMBER) IS
    SELECT sum(ppevs.duration)
    FROM   pa_proj_elem_ver_schedule ppevs
         , pa_object_relationships por
         , pa_proj_element_versions ppev
         , pa_proj_elements ppe
         , pa_task_types ptt
    WHERE  por.object_id_from1 = c_parent_element_version_id
    AND    por.object_type_to = 'PA_TASKS'
    AND    por.relationship_type = 'S'
    AND    por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
    AND    por.object_id_to1 = ppevs.element_version_id
    AND    por.object_id_to1 = ppev.element_version_id
    AND    ppev.proj_element_id = ppe.proj_element_id
    AND    ppevs.project_id     = ppe.project_id
    AND    ppe.TYPE_ID   = ptt.task_type_id
    AND    ptt.object_type ='PA_TASKS'              /* bug 3279978 FP M Enhancement */
    AND    ptt.prog_entry_enable_flag = 'Y';

 CURSOR get_task_duration(c_element_version_id NUMBER, c_project_id NUMBER) IS
    SELECT duration
    FROM   pa_proj_elem_ver_schedule
    WHERE  element_version_id = c_element_version_id
    AND    project_id = c_project_id;

 CURSOR get_existing_weights(c_parent_element_version_id NUMBER) IS
    SELECT sum(weighting_percentage)
    FROM   PA_OBJECT_RELATIONSHIPS
    WHERE  object_id_from1 = c_parent_element_version_id
    AND    object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
    AND    object_type_to = 'PA_TASKS'
    AND    relationship_type = 'S';


l_element_version_id NUMBER;
l_parent_element_version_id NUMBER;
l_outline_level NUMBER;
l_progress_allowed VARCHAR2(1);

TYPE durations IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

l_durations durations;
l_total_duration NUMBER;
l_task_weight PA_OBJECT_RELATIONSHIPS.weighting_percentage%TYPE;
l_task_duration  NUMBER;
l_existing_weight NUMBER;
l_remaining_weight NUMBER;

BEGIN

For l_get_task_ver IN c_get_task_ver LOOP

    l_element_version_id := l_get_task_ver.element_version_id;
    l_outline_level  := l_get_task_ver.wbs_level;

    OPEN check_progress_allowed(l_element_version_id);
    FETCH check_progress_allowed INTO l_progress_allowed;
    CLOSE check_progress_allowed;

    OPEN get_parent(l_element_version_id);
    FETCH get_parent INTO l_parent_element_version_id;
    CLOSE get_parent;


    IF l_progress_allowed = 'N' THEN
          -- Populate task weight as zero
          UPDATE PA_OBJECT_RELATIONSHIPS
          SET weighting_percentage = 0
          WHERE object_id_from1 = l_parent_element_version_id
          AND   object_id_to1 = l_element_version_id
          AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          AND   object_type_to = 'PA_TASKS'
          AND   relationship_type = 'S';
    ELSE

          IF l_durations.exists(l_parent_element_version_id) then
              NULL;
          ELSE
          OPEN get_summed_duration(l_parent_element_version_id);
              FETCH get_summed_duration INTO l_total_duration;
              CLOSE get_summed_duration;

          l_durations(l_parent_element_version_id) := l_total_duration;
          END IF;

      OPEN get_task_duration(l_element_version_id, p_project_id);
          FETCH get_task_duration INTO l_task_duration;
          CLOSE get_task_duration;

          IF (l_durations(l_parent_element_version_id) IS NULL) OR (l_durations(l_parent_element_version_id) = 0) THEN
          l_task_weight := 0;
          ELSE
              OPEN get_existing_weights(l_parent_element_version_id);
          FETCH get_existing_weights INTO l_existing_weight;
              CLOSE get_existing_weights;

          l_remaining_weight := 100 - l_existing_weight;
              l_task_weight := (l_task_duration / l_durations(l_parent_element_version_id)) * 100;

          IF(abs(l_remaining_weight - l_task_weight) <= .05) THEN
            l_task_weight := l_remaining_weight;
          END IF;
          IF(abs(l_remaining_weight) <= .01) THEN
            l_task_weight := l_task_weight+l_remaining_weight;
          END IF;
      END IF;

          UPDATE PA_OBJECT_RELATIONSHIPS
          SET weighting_percentage = l_task_weight
          WHERE object_id_from1 = l_parent_element_version_id
          AND   object_id_to1 = l_element_version_id
          AND   object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
          AND   object_type_to = 'PA_TASKS'
          AND   relationship_type = 'S';
    END IF;
END LOOP;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                          p_procedure_name => 'RECALC_FIN_TASK_WEIGHTS',
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
END RECALC_FIN_TASK_WEIGHTS;

--maansari
FUNCTION copy_task_version( p_structure_version_id NUMBER, p_task_version_id NUMBER ) RETURN VARCHAR2 IS
   l_copy_task_flag VARCHAR2(1) := 'Y';
   l_parent_task_version_id NUMBER;
BEGIN

   FOR i in 1..l_src_tasks_versions_tbl.count LOOP
       IF p_task_version_id = l_src_tasks_versions_tbl(i).src_task_version_id
       THEN
          l_copy_task_flag := l_src_tasks_versions_tbl(i).copy_flag;
          l_parent_task_version_id := l_src_tasks_versions_tbl(i).src_parent_task_version_id;
          --loop thru untill top of the hierarchy.
          WHILE l_parent_task_version_id <> p_structure_version_id LOOP
            FOR i in 1..l_src_tasks_versions_tbl.count LOOP
             IF l_parent_task_version_id = l_src_tasks_versions_tbl(i).src_task_version_id
             THEN
--bug 2863836
                IF l_src_tasks_versions_tbl(i).copy_flag = 'N' THEN
                  l_copy_task_flag := l_src_tasks_versions_tbl(i).copy_flag;
                END IF;
--end bug 2863836
                l_parent_task_version_id := l_src_tasks_versions_tbl(i).src_parent_task_version_id;
                exit;
             END IF;
            END LOOP;
          END LOOP;
          exit;
       END IF;
   END LOOP;

   return l_copy_task_flag;
END copy_task_version;
--maansari

-- Performance changes : added this API. It is bulk version of COPY_STRUCTURE_VERSION

PROCEDURE COPY_STRUCTURE_VERSION_BULK
( p_commit                        IN VARCHAR2   := FND_API.G_FALSE
 ,p_validate_only                 IN VARCHAR2   := FND_API.G_TRUE
 ,p_validation_level              IN NUMBER     := FND_API.G_VALID_LEVEL_FULL
 ,p_calling_module                IN VARCHAR2   := 'SELF_SERVICE'
 ,p_debug_mode                    IN VARCHAR2   := 'N'
 ,p_max_msg_count                 IN NUMBER     := FND_API.G_MISS_NUM
 ,p_structure_version_id          IN NUMBER
 ,p_new_struct_ver_name           IN VARCHAR2
 ,p_new_struct_ver_desc           IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,x_new_struct_ver_id            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_new_struct_ver_id             PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
  -- added for Bug Fix: 4537865
  l_tmp_struct_ver_id         PA_PROJ_ELEMENT_VERSIONS.ELEMENT_VERSION_ID%TYPE;
  -- added for Bug Fix: 4537865
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(250);
  l_data                          VARCHAR2(2000);
  l_msg_index_out                 NUMBER;
  l_pev_structure_id              NUMBER;

  CURSOR l_get_structure_ver_csr(c_structure_version_id NUMBER)
  IS
  SELECT *
  FROM PA_PROJ_ELEMENT_VERSIONS
  WHERE element_version_id = c_structure_version_id;

  l_structure_ver_rec       l_get_structure_ver_csr%ROWTYPE;
  l_structure_ver_to_rec    l_get_structure_ver_csr%ROWTYPE;

  CURSOR l_get_structure_ver_attr_csr(c_structure_version_id NUMBER)
  IS
  SELECT a.*
  FROM PA_PROJ_ELEM_VER_STRUCTURE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.element_version_id = c_structure_version_id
  AND   b.project_id = a.project_id
  AND   b.element_version_id = a.project_id;

  l_structure_ver_attr_rec       l_get_structure_ver_attr_csr%ROWTYPE;

  l_ref_task_ver_id          NUMBER;
  l_peer_or_sub              VARCHAR2(10);

  CURSOR l_get_ver_schedule_attr_csr(c_element_version_id NUMBER)
  IS
  SELECT a.*
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.element_version_id = c_element_version_id
  AND b.project_id = a.project_id
  AND b.element_version_id = a.element_version_id;

  l_ver_schedule_attr_rec       l_get_ver_schedule_attr_csr%ROWTYPE;

  l_last_wbs_level          NUMBER;
  l_task_version_id         NUMBER;
  l_pev_schedule_id         NUMBER;

  CURSOR l_get_structure_type_csr(c_structure_version_id NUMBER)
  IS
  SELECT pst.structure_type_class_code
  FROM   PA_STRUCTURE_TYPES pst,
         PA_PROJ_ELEMENT_VERSIONS ppev,
         PA_PROJ_STRUCTURE_TYPES ppst
  WHERE  ppev.element_version_id = c_structure_version_id
  AND    ppev.proj_element_id = ppst.proj_element_id
  AND    ppst.structure_type_id = pst.structure_type_id;

  l_structure_type          PA_STRUCTURE_TYPES.structure_type%TYPE;

  CURSOR l_check_working_versions_csr(c_structure_version_id NUMBER)
  IS
  SELECT 'Y'
  FROM  PA_PROJ_ELEMENT_VERSIONS ppev
  WHERE ppev.element_version_id = c_structure_version_id
  AND   EXISTS
        (SELECT 'Y'
         FROM   PA_PROJ_ELEMENT_VERSIONS ppev2,
                PA_PROJ_ELEM_VER_STRUCTURE ppevs
         WHERE  ppev2.proj_element_id = ppev.proj_element_id
         AND    ppev2.project_id = ppev.project_id
         AND    ppevs.project_id = ppev2.project_id
         AND    ppevs.element_version_id = ppev2.element_version_id
         AND    ppevs.status_code <> 'STRUCTURE_PUBLISHED');

  l_dummy                   VARCHAR2(1);


    l_new_obj_rel_id          PA_OBJECT_RELATIONSHIPS.OBJECT_RELATIONSHIP_ID%TYPE;
    l_structure_type1         PA_STRUCTURE_TYPES.structure_type_class_code%TYPE;

--Added by rtarway
l_rowid VARCHAR2(255);

   X_Row_id  VARCHAR2(255);
   l_project_id number;
   l_user_id number;
   l_login_id number;

    CURSOR cur_elem_ver_seq IS
    SELECT pa_proj_element_versions_s.nextval
      FROM sys.dual;

  l_wp_struc VARCHAR2(1);
  l_fin_struc VARCHAR2(1);

BEGIN

  pa_debug.init_err_stack ('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE_VERSION_BULK');

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE_VERSION_BULK begin');
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    savepoint copy_structure_version_pvt_blk;
  END IF;

  -- Get structure version info
  OPEN l_get_structure_ver_csr(p_structure_version_id);
  FETCH l_get_structure_ver_csr INTO l_structure_ver_rec;
  CLOSE l_get_structure_ver_csr;

  l_project_id := l_structure_ver_rec.project_id;

  OPEN cur_elem_ver_seq;
  FETCH cur_elem_ver_seq INTO l_new_struct_ver_id;
  CLOSE cur_elem_ver_seq;

    -- Fix for 4657794 :- This is fix for regression introduced by 4537865
    -- As X_ELEMENT_VERSION_ID is an IN OUT parameter ,we need to initialize, its value l_tmp_struct_ver_id
    -- to l_new_struct_ver_id

    l_tmp_struct_ver_id := l_new_struct_ver_id ;

    -- End 4657794

    PA_PROJ_ELEMENT_VERSIONS_PKG.INSERT_ROW(
       X_ROW_ID                       => l_rowid
    --,X_ELEMENT_VERSION_ID           => l_new_struct_ver_id        * commented for Bug Fix: 453786
      ,X_ELEMENT_VERSION_ID       => l_tmp_struct_ver_id        --  added for bug Fix: 4537865
      ,X_PROJ_ELEMENT_ID              => l_structure_ver_rec.proj_element_id
      ,X_OBJECT_TYPE                  => 'PA_STRUCTURES'
      ,X_PROJECT_ID                   => l_project_id
      ,X_PARENT_STRUCTURE_VERSION_ID  => l_new_struct_ver_id
      ,X_DISPLAY_SEQUENCE             => NULL
      ,X_WBS_LEVEL                    => NULL
      ,X_WBS_NUMBER                   => '0'
      ,X_ATTRIBUTE_CATEGORY           => l_structure_ver_rec.attribute_category
      ,X_ATTRIBUTE1                   => l_structure_ver_rec.attribute1
      ,X_ATTRIBUTE2                   => l_structure_ver_rec.attribute2
      ,X_ATTRIBUTE3                   => l_structure_ver_rec.attribute3
      ,X_ATTRIBUTE4                   => l_structure_ver_rec.attribute4
      ,X_ATTRIBUTE5                   => l_structure_ver_rec.attribute5
      ,X_ATTRIBUTE6                   => l_structure_ver_rec.attribute6
      ,X_ATTRIBUTE7                   => l_structure_ver_rec.attribute7
      ,X_ATTRIBUTE8                   => l_structure_ver_rec.attribute8
      ,X_ATTRIBUTE9                   => l_structure_ver_rec.attribute9
      ,X_ATTRIBUTE10                  => l_structure_ver_rec.attribute10
      ,X_ATTRIBUTE11                  => l_structure_ver_rec.attribute11
      ,X_ATTRIBUTE12                  => l_structure_ver_rec.attribute12
      ,X_ATTRIBUTE13                  => l_structure_ver_rec.attribute13
      ,X_ATTRIBUTE14                  => l_structure_ver_rec.attribute14
      ,X_ATTRIBUTE15                  => l_structure_ver_rec.element_version_id
      ,X_TASK_UNPUB_VER_STATUS_CODE   => NULL
            ,X_SOURCE_OBJECT_ID             => l_project_id
      ,X_SOURCE_OBJECT_TYPE           => 'PA_PROJECTS'
    );
      -- added for bug Fix: 4537865
     l_new_struct_ver_id := l_tmp_struct_ver_id;
      -- added for bug Fix: 4537865

/*
  PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
  ( p_validate_only         => p_validate_only
   ,p_structure_id          => l_structure_ver_rec.proj_element_id
   ,p_attribute_category    => l_structure_ver_rec.attribute_category
   ,p_attribute1            => l_structure_ver_rec.attribute1
   ,p_attribute2            => l_structure_ver_rec.attribute2
   ,p_attribute3            => l_structure_ver_rec.attribute3
   ,p_attribute4            => l_structure_ver_rec.attribute4
   ,p_attribute5            => l_structure_ver_rec.attribute5
   ,p_attribute6            => l_structure_ver_rec.attribute6
   ,p_attribute7            => l_structure_ver_rec.attribute7
   ,p_attribute8            => l_structure_ver_rec.attribute8
   ,p_attribute9            => l_structure_ver_rec.attribute9
   ,p_attribute10           => l_structure_ver_rec.attribute10
   ,p_attribute11           => l_structure_ver_rec.attribute11
   ,p_attribute12           => l_structure_ver_rec.attribute12
   ,p_attribute13           => l_structure_ver_rec.attribute13
   ,p_attribute14           => l_structure_ver_rec.attribute14
   ,p_attribute15           => l_structure_ver_rec.element_version_id  --fix bug 2833989: replaced l_structure_ver_rec.attribute15
   ,x_structure_version_id  => l_new_struct_ver_id
   ,x_return_status         => l_return_status
   ,x_msg_count             => l_msg_count
   ,x_msg_data              => l_msg_data );
*/

  If (p_debug_mode = 'Y') THEN
    pa_debug.debug('Create Structure Version Bulk return status: ' || l_return_status);
    pa_debug.debug('l_new_struct_ver_id: ' || l_new_struct_ver_id);
  END IF;


  --Check if there is any error.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    IF x_msg_count = 1 THEN
      x_msg_data := l_msg_data;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

   -- Get structure version attributes
  OPEN l_get_structure_ver_attr_csr(p_structure_version_id);
  FETCH l_get_structure_ver_attr_csr INTO l_structure_ver_attr_rec;
  CLOSE l_get_structure_ver_attr_csr;

  If (p_change_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) THEN
    l_structure_ver_attr_rec.change_reason_code := p_change_reason_code;
  END IF;

  PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
  ( p_validate_only               => FND_API.G_FALSE
   ,p_structure_version_id        => l_new_struct_ver_id
   ,p_structure_version_name      => p_new_struct_ver_name
   ,p_structure_version_desc      => p_new_struct_ver_desc
   ,p_effective_date              => l_structure_ver_attr_rec.effective_date
   ,p_latest_eff_published_flag   => l_structure_ver_attr_rec.latest_eff_published_flag
   ,p_locked_status_code          => l_structure_ver_attr_rec.lock_status_code
   ,p_struct_version_status_code  => l_structure_ver_attr_rec.status_code
   ,p_baseline_current_flag       => l_structure_ver_attr_rec.current_flag
   ,p_baseline_original_flag      => l_structure_ver_attr_rec.original_flag
   ,p_change_reason_code          => l_structure_ver_attr_rec.change_reason_code
   ,x_pev_structure_id            => l_pev_structure_id
   ,x_return_status               => l_return_status
   ,x_msg_count                   => l_msg_count
   ,x_msg_data                    => l_msg_data );

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('Create Structure Version Bulk Attr return status: ' || l_return_status);
    pa_debug.debug('l_pev_structure_id: ' || l_pev_structure_id);
  END IF;

  --Check if there is any error.
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    x_msg_count := l_msg_count;
    IF x_msg_count = 1 THEN
      x_msg_data := l_msg_data;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Search for outgoing links for the structure version; create new Links
  -- Amit: Code(get_to_id) which was commented earlier is removed. If needed it can be found from COPY_STRUCTURE_VERSION

  --hsiu: added to check for structure type
  l_wp_struc := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'WORKPLAN');
  l_fin_struc:= PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(p_structure_version_id, 'FINANCIAL');

  OPEN l_get_structure_type_csr(p_structure_version_id);
  FETCH l_get_structure_type_csr INTO l_structure_type;
  CLOSE l_get_structure_type_csr;

  -- If structure is workplan type create schedule version record
--  if l_structure_type = 'WORKPLAN' then
  IF (l_wp_struc = 'Y') THEN

    OPEN l_get_ver_schedule_attr_csr(p_structure_version_id);
    FETCH l_get_ver_schedule_attr_csr INTO l_ver_schedule_attr_rec;
    CLOSE l_get_ver_schedule_attr_csr;

  -- Amit: Code(PA_TASK_PUB1.CREATE_SCHEDULE_VERSION) which was commented earlier is removed.
  -- If needed it can be found from COPY_STRUCTURE_VERSION

    l_pev_schedule_id := NULL;
    PA_PROJ_ELEMENT_SCH_PKG.Insert_Row(
         X_ROW_ID               => X_Row_Id
        ,X_PEV_SCHEDULE_ID          => l_pev_schedule_id
        ,X_ELEMENT_VERSION_ID           => l_new_struct_ver_id
        ,X_PROJECT_ID               => l_ver_schedule_attr_rec.PROJECT_ID
        ,X_PROJ_ELEMENT_ID          => l_ver_schedule_attr_rec.PROJ_ELEMENT_ID
        ,X_SCHEDULED_START_DATE         => l_ver_schedule_attr_rec.SCHEDULED_START_DATE
        ,X_SCHEDULED_FINISH_DATE        => l_ver_schedule_attr_rec.SCHEDULED_FINISH_DATE
        ,X_OBLIGATION_START_DATE        => l_ver_schedule_attr_rec.OBLIGATION_START_DATE
        ,X_OBLIGATION_FINISH_DATE       => l_ver_schedule_attr_rec.OBLIGATION_FINISH_DATE
        ,X_ACTUAL_START_DATE            => l_ver_schedule_attr_rec.ACTUAL_START_DATE
        ,X_ACTUAL_FINISH_DATE           => l_ver_schedule_attr_rec.ACTUAL_FINISH_DATE
        ,X_ESTIMATED_START_DATE         => l_ver_schedule_attr_rec.ESTIMATED_START_DATE
        ,X_ESTIMATED_FINISH_DATE        => l_ver_schedule_attr_rec.ESTIMATED_FINISH_DATE
        ,X_DURATION             => l_ver_schedule_attr_rec.DURATION
        ,X_EARLY_START_DATE         => l_ver_schedule_attr_rec.EARLY_START_DATE
        ,X_EARLY_FINISH_DATE            => l_ver_schedule_attr_rec.EARLY_FINISH_DATE
        ,X_LATE_START_DATE          => l_ver_schedule_attr_rec.LATE_START_DATE
        ,X_LATE_FINISH_DATE         => l_ver_schedule_attr_rec.LATE_FINISH_DATE
        ,X_CALENDAR_ID              => l_ver_schedule_attr_rec.CALENDAR_ID
        ,X_MILESTONE_FLAG           => l_ver_schedule_attr_rec.MILESTONE_FLAG
        ,X_CRITICAL_FLAG            => l_ver_schedule_attr_rec.CRITICAL_FLAG
        ,X_WQ_PLANNED_QUANTITY          => l_ver_schedule_attr_rec.wq_planned_quantity
        ,X_PLANNED_EFFORT           => l_ver_schedule_attr_rec.planned_effort
        ,X_ACTUAL_DURATION          => l_ver_schedule_attr_rec.actual_duration
        ,X_ESTIMATED_DURATION           => l_ver_schedule_attr_rec.estimated_duration
        ,X_ATTRIBUTE_CATEGORY           => l_ver_schedule_attr_rec.ATTRIBUTE_CATEGORY
        ,X_ATTRIBUTE1               => l_ver_schedule_attr_rec.ATTRIBUTE1
        ,X_ATTRIBUTE2               => l_ver_schedule_attr_rec.ATTRIBUTE2
        ,X_ATTRIBUTE3               => l_ver_schedule_attr_rec.ATTRIBUTE3
        ,X_ATTRIBUTE4               => l_ver_schedule_attr_rec.ATTRIBUTE4
        ,X_ATTRIBUTE5               => l_ver_schedule_attr_rec.ATTRIBUTE5
        ,X_ATTRIBUTE6               => l_ver_schedule_attr_rec.ATTRIBUTE6
        ,X_ATTRIBUTE7               => l_ver_schedule_attr_rec.ATTRIBUTE7
        ,X_ATTRIBUTE8               => l_ver_schedule_attr_rec.ATTRIBUTE8
        ,X_ATTRIBUTE9               => l_ver_schedule_attr_rec.ATTRIBUTE9
        ,X_ATTRIBUTE10              => l_ver_schedule_attr_rec.ATTRIBUTE10
        ,X_ATTRIBUTE11              => l_ver_schedule_attr_rec.ATTRIBUTE11
        ,X_ATTRIBUTE12              => l_ver_schedule_attr_rec.ATTRIBUTE12
        ,X_ATTRIBUTE13              => l_ver_schedule_attr_rec.ATTRIBUTE13
        ,X_ATTRIBUTE14              => l_ver_schedule_attr_rec.ATTRIBUTE14
        ,X_ATTRIBUTE15              => l_ver_schedule_attr_rec.ATTRIBUTE15
    ,X_SOURCE_OBJECT_ID   => l_ver_schedule_attr_rec.PROJECT_ID
        ,X_SOURCE_OBJECT_TYPE => 'PA_PROJECTS'
    );


    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Create Schedule Version Bulk return status: ' || l_return_status);
      pa_debug.debug('l_pev_schedule_id: ' || l_pev_schedule_id);
    END IF;

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

--  ELSIF l_structure_type in ('FINANCIAL') then
  IF l_wp_struc = 'N' and l_fin_struc = 'Y' THEN
    -- There can only be one working version any any time for a financial structure
    OPEN l_check_working_versions_csr(p_structure_version_id);
    FETCH l_check_working_versions_csr INTO l_dummy;
    if l_check_working_versions_csr%FOUND then
      CLOSE l_check_working_versions_csr;
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_WORKING_VER_EXISTS');
      x_msg_data := 'PA_PS_WORKING_VER_EXISTS';
      RAISE FND_API.G_EXC_ERROR;
    end if;
    CLOSE l_check_working_versions_csr;
  end if;

  -- Amit The code to get all the task versions and then create task versions one by one is commented
  -- Now we are using bulk insert for this purpose.

    l_user_id := FND_GLOBAl.user_id;
    l_login_id := FND_GLOBAl.login_id;

    INSERT INTO pa_proj_element_versions(
                     ELEMENT_VERSION_ID
                    ,PROJ_ELEMENT_ID
                    ,OBJECT_TYPE
                    ,PROJECT_ID
                    ,PARENT_STRUCTURE_VERSION_ID
                    ,DISPLAY_SEQUENCE
                    ,WBS_LEVEL
                    ,WBS_NUMBER
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,LAST_UPDATE_LOGIN
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
                     ,TASK_UNPUB_VER_STATUS_CODE
                     ,FINANCIAL_TASK_FLAG
                    ,attribute15          --this column is used to store structure ver id of the source str to be used to created relationships.
            ,source_object_id
                    ,source_object_type
                    )
                  SELECT
                     pa_proj_element_versions_s.nextval
                    ,ppev.proj_element_id
                    ,ppev.object_type
                    ,l_project_id
                    ,l_new_struct_ver_id
                    ,ppev.display_sequence
                    ,ppev.WBS_LEVEL
                    ,ppev.WBS_NUMBER
                    ,SYSDATE
                    ,l_user_id
                    ,SYSDATE
                    ,l_user_id
                    ,l_login_id
                     ,ppev.RECORD_VERSION_NUMBER
                     ,ppev.ATTRIBUTE_CATEGORY
                     ,ppev.ATTRIBUTE1
                     ,ppev.ATTRIBUTE2
                     ,ppev.ATTRIBUTE3
                     ,ppev.ATTRIBUTE4
                     ,ppev.ATTRIBUTE5
                     ,ppev.ATTRIBUTE6
                     ,ppev.ATTRIBUTE7
                     ,ppev.ATTRIBUTE8
                     ,ppev.ATTRIBUTE9
                     ,ppev.ATTRIBUTE10
                     ,ppev.ATTRIBUTE11
                     ,ppev.ATTRIBUTE12
                     ,ppev.ATTRIBUTE13
                     ,ppev.ATTRIBUTE14
                     ,ppev.TASK_UNPUB_VER_STATUS_CODE
                     ,ppev.FINANCIAL_TASK_FLAG
                     ,ppev.element_version_id
             ,l_project_id
             ,'PA_PROJECTS'
                  FROM ( SELECT ppev2.* from pa_proj_element_versions ppev2
                  ,pa_proj_elements ppe  --bug 4573340
                          WHERE -- bug#3094283 ppev2.project_id = l_project_id
                            ppev2.parent_structure_version_id = p_structure_version_id
                         --bug 4573340
                            and ppe.project_id = ppev2.project_id
                            and ppe.proj_element_id = ppev2.proj_element_id
                            and ppe.link_task_flag = 'N'
                         --bug 4573340
                            and ppev2.object_type = 'PA_TASKS'
                           order by ppev2.display_sequence ) ppev
                    ;
           -- Bug 4205167 : Added hint to use Hash Join
              INSERT INTO PA_OBJECT_RELATIONSHIPS (
                                  object_relationship_id,
                                  object_type_from,
                                  object_id_from1,
                                  object_type_to,
                                  object_id_to1,
                                  relationship_type,
                                  relationship_subtype,
                                  Record_Version_Number,
                                  CREATED_BY,
                                  CREATION_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATE_LOGIN,
                                  weighting_percentage
                                  )
                 SELECT /*+ USE_HASH(ppev2 ppev1)*/
                               pa_object_relationships_s.nextval,
                               pobj.object_type_from,
                           ppev1.element_version_id,
                   pobj.object_type_to,
                   ppev2.element_version_id,
                   pobj.relationship_type,
                   pobj.relationship_subtype,
                               pobj.Record_Version_Number,
                               l_user_id,
                               SYSDATE,
                               l_user_id,
                               SYSDATE,
                               l_login_id,
                               pobj.weighting_percentage
                    FROM ( SELECT  object_type_from, object_id_from1,
                                   object_type_to,   object_id_to1,
                                   relationship_type, relationship_subtype,
                                   Record_Version_Number, weighting_percentage
                             FROM pa_object_relationships
                     --bug#3094283       WHERE RELATIONSHIP_TYPE = 'S'
                             start with object_id_from1 = p_structure_version_id
                  and RELATIONSHIP_TYPE = 'S'  /* Bug 2881667 - Added this condition */
                             connect by  object_id_from1 =  prior object_id_to1
                              and RELATIONSHIP_TYPE = 'S' ) pobj,   /* Bug 2881667 - Added this condition */
                         pa_proj_element_versions ppev1,
                         pa_proj_element_versions ppev2
                 WHERE
                   --bug#3094283    ppev1.project_id = l_project_id
                   ppev1.attribute15 = pobj.object_id_from1
                   --bug#3094283 AND ppev2.project_id = l_project_id
                   AND ppev2.attribute15 = pobj.object_id_to1
                   and ppev1.parent_structure_version_id = l_new_struct_ver_id
                   and ppev2.parent_structure_version_id = l_new_struct_ver_id
                   ;


              INSERT INTO pa_proj_elem_ver_schedule(
                            PEV_SCHEDULE_ID
                           ,ELEMENT_VERSION_ID
                           ,PROJECT_ID
                           ,PROJ_ELEMENT_ID
                           ,CREATION_DATE
                           ,CREATED_BY
                           ,LAST_UPDATE_DATE
                           ,LAST_UPDATED_BY
                           ,SCHEDULED_START_DATE
                           ,SCHEDULED_FINISH_DATE
                           ,OBLIGATION_START_DATE
                           ,OBLIGATION_FINISH_DATE
                           ,ACTUAL_START_DATE
                           ,ACTUAL_FINISH_DATE
                           ,ESTIMATED_START_DATE
                           ,ESTIMATED_FINISH_DATE
                           ,DURATION
                           ,EARLY_START_DATE
                           ,EARLY_FINISH_DATE
                           ,LATE_START_DATE
                           ,LATE_FINISH_DATE
                           ,CALENDAR_ID
                           ,MILESTONE_FLAG
                           ,CRITICAL_FLAG
                           ,RECORD_VERSION_NUMBER
                           ,LAST_UPDATE_LOGIN
                           ,WQ_PLANNED_QUANTITY
                           ,PLANNED_EFFORT
                           ,ACTUAL_DURATION
                           ,ESTIMATED_DURATION
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
               ,source_object_id
               ,source_object_type
               ,CONSTRAINT_TYPE_CODE
               ,CONSTRAINT_DATE
               ,FREE_SLACK
               ,TOTAL_SLACK
               ,EFFORT_DRIVEN_FLAG
               ,LEVEL_ASSIGNMENTS_FLAG
               ,EXT_ACT_DURATION
               ,EXT_REMAIN_DURATION
               ,EXT_SCH_DURATION
           ,DEF_SCH_TOOL_TSK_TYPE_CODE -- Fix For Bug # 4321287.
                              )
                        SELECT
                            pa_proj_elem_ver_schedule_s.nextval
                           ,ppev1.ELEMENT_VERSION_ID
                           ,l_PROJECT_ID
                           ,ppev1.PROJ_ELEMENT_ID
                           ,SYSDATE
                           ,l_user_id
                           ,SYSDATE
                           ,l_user_id
                           ,ppevs.SCHEDULED_START_DATE
                           ,ppevs.SCHEDULED_FINISH_DATE
                           ,ppevs.OBLIGATION_START_DATE
                           ,ppevs.OBLIGATION_FINISH_DATE
                           ,ppevs.ACTUAL_START_DATE
                           ,ppevs.ACTUAL_FINISH_DATE
                           ,ppevs.ESTIMATED_START_DATE
                           ,ppevs.ESTIMATED_FINISH_DATE
                           ,ppevs.DURATION
                           ,ppevs.EARLY_START_DATE
                           ,ppevs.EARLY_FINISH_DATE
                           ,ppevs.LATE_START_DATE
                           ,ppevs.LATE_FINISH_DATE
                           ,ppevs.CALENDAR_ID
                           ,ppevs.MILESTONE_FLAG
                           ,ppevs.CRITICAL_FLAG
                           ,ppevs.RECORD_VERSION_NUMBER
                           ,l_login_id
                           ,ppevs.WQ_PLANNED_QUANTITY
                           ,ppevs.PLANNED_EFFORT
                           ,ppevs.ACTUAL_DURATION
                           ,ppevs.ESTIMATED_DURATION
                           ,ppevs.ATTRIBUTE_CATEGORY
                           ,ppevs.ATTRIBUTE1
                           ,ppevs.ATTRIBUTE2
                           ,ppevs.ATTRIBUTE3
                           ,ppevs.ATTRIBUTE4
                           ,ppevs.ATTRIBUTE5
                           ,ppevs.ATTRIBUTE6
                           ,ppevs.ATTRIBUTE7
                           ,ppevs.ATTRIBUTE8
                           ,ppevs.ATTRIBUTE9
                           ,ppevs.ATTRIBUTE10
                           ,ppevs.ATTRIBUTE11
                           ,ppevs.ATTRIBUTE12
                           ,ppevs.ATTRIBUTE13
                           ,ppevs.ATTRIBUTE14
                           ,ppevs.ATTRIBUTE15
               ,l_PROJECT_ID
               ,'PA_PROJECTS'
               ,ppevs.CONSTRAINT_TYPE_CODE
               ,ppevs.CONSTRAINT_DATE
               ,ppevs.FREE_SLACK
               ,ppevs.TOTAL_SLACK
               ,ppevs.EFFORT_DRIVEN_FLAG
               ,ppevs.LEVEL_ASSIGNMENTS_FLAG
               ,ppevs.EXT_ACT_DURATION
               ,ppevs.EXT_REMAIN_DURATION
               ,ppevs.EXT_SCH_DURATION
           ,ppevs.DEF_SCH_TOOL_TSK_TYPE_CODE -- Fix For Bug # 4321287.
                         FROM pa_proj_elem_ver_schedule ppevs,
                              pa_proj_element_versions ppev1
                           where ppev1.attribute15 = ppevs.element_version_id
                            and  ppevs.project_id = l_project_id
                            and  ppev1.project_id = l_project_id
                            and  ppev1.parent_structure_version_id = l_new_struct_ver_id
                            and  ppev1.object_type = 'PA_TASKS';

    -----------------------------------------FP_M Changes : Begin
    -- Refer to tracking bug 3305199
    --
    Declare
          /* Bug #: 3305199 SMukka                                                         */
          /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
      /* Old_Versions_Tab  PA_PLSQL_DATATYPES.IdTabTyp;                                */
      /* New_Versions_Tab  PA_PLSQL_DATATYPES.IdTabTyp;                                */
      Old_Versions_Tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
      New_Versions_Tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
    Begin
      Select Element_Version_ID, attribute15 BULK COLLECT
      INTO   New_Versions_Tab, Old_Versions_Tab
      From   PA_Proj_Element_Versions
      Where  Project_ID = l_project_id
      AND    parent_structure_version_id = l_new_struct_ver_id;

      PA_Relationship_Pvt.Copy_Intra_Dependency (
        P_Source_Ver_Tbl  => Old_Versions_Tab,
        P_Destin_Ver_Tbl  => New_Versions_Tab,
        X_Return_Status   => X_Return_Status,
        X_Msg_Count     => X_Msg_Count,
        X_Msg_Data      => X_Msg_Data
      );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          PA_RELATIONSHIP_PVT.Copy_Inter_Project_Dependency (
        P_Source_Ver_Tbl     => Old_Versions_Tab,
        P_Destin_Ver_Tbl     => New_Versions_Tab,
        X_Return_Status      => X_Return_Status,
        X_Msg_Count          => X_Msg_Count,
        X_Msg_Data           => X_Msg_Data
          );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
    End;
        /* SMukka 01-Mar-04 Bug No. 3450684                                            */
        /* Added call to PA_RELATIONSHIP_PVT.Copy_OG_Lnk_For_Subproj_Ass               */
        /* API to copy all the out going sub project assoication                       */

    -- Begin fix for Bug # 4530436.

    -- The out going sub-project association links will not copied into the new structure version
    -- if the new structure version created is a working structure version.

    if
      (pa_project_structure_utils.Check_Struc_Ver_Published(l_project_id, l_new_struct_ver_id) = 'Y')
    then

    -- End fix for Bug # 4530436.

        PA_RELATIONSHIP_PVT.Copy_OG_Lnk_For_Subproj_Ass(
                                      p_validate_only           =>  p_validate_only,
                                      p_validation_level        =>  p_validation_level,
                                      p_calling_module          =>  p_calling_module,
                                      p_debug_mode              =>  p_debug_mode,
                                      p_max_msg_count           =>  p_max_msg_count,
                                      p_commit                  =>  p_commit,
                                      p_src_str_version_id      =>  p_structure_version_id,
                                      p_dest_str_version_id     =>  l_new_struct_ver_id,  -- Destination Str version id can be of published str also
                                      x_return_status           =>  X_Return_Status,
                                      x_msg_count               =>  X_Msg_Count,
                                      x_msg_data                =>  X_Msg_Data);
        IF (X_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
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

    end if; -- Fix for Bug # 4530436.

      --3755117 for copying mapping
      BEGIN
        PA_PROJ_STRUC_MAPPING_PUB.copy_mapping(
           p_context             => 'CREATE_WORKING_VERSION'
          ,p_src_project_id      => l_project_id
          ,p_dest_project_id     => l_project_id
          ,p_src_str_version_id  => p_structure_version_id
          ,p_dest_str_version_id => l_new_struct_ver_id
          ,x_return_status       => x_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
        );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                  p_procedure_name => 'COPY_STRUCTURE_VERSION_BULK',
                                  p_error_text     => SUBSTRB('PA_PROJ_STRUC_MAPPING_PUB.copy_mapping:'||SQLERRM,1,240));
        RAISE FND_API.G_EXC_ERROR;
      END;

        -- Changes added by skannoji
        -- Added code for doosan customer
      IF (l_wp_struc = 'Y') THEN
        Declare
      /* Bug #: 3305199 SMukka                                                         */
          /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
          /* src_versions_tab   PA_PLSQL_DATATYPES.IdTabTyp;                               */
          /* dest_versions_tab  PA_PLSQL_DATATYPES.IdTabTyp;                               */
          src_versions_tab   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
          dest_versions_tab  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type(); /* Venky */
        Begin
           src_versions_tab.extend(1); /* Venky */
           dest_versions_tab.extend(1); /* Venky */
           src_versions_tab(1)  :=  p_structure_version_id;
           dest_versions_tab(1) :=  l_new_struct_ver_id;

          -- Copies budget versions, resource assignments and budget lines as required for the workplan version.
           /*Smukka Bug No. 3474141 Date 03/01/2004                                    */
           /*moved PA_FP_COPY_FROM_PKG.copy_wp_budget_versions into plsql block        */
           BEGIN
               PA_FP_COPY_FROM_PKG.copy_wp_budget_versions
               (
                 p_source_project_id            => l_project_id
                ,p_target_project_id            => l_project_id
                ,p_src_sv_ids_tbl               => src_Versions_Tab /* Workplan version id tbl */
                ,p_target_sv_ids_tbl            => dest_Versions_Tab /* Workplan version id tbl */
                ,p_copy_mode                    => 'V'     --bug  5118313
                ,x_return_status                => x_return_status
                ,x_msg_count                    => x_msg_count
                ,x_Msg_data                     => x_msg_data
               );
           EXCEPTION
               WHEN OTHERS THEN
                    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                            p_procedure_name => 'COPY_STRUCTURE_VERSION_BULK',
                                            p_error_text     => SUBSTRB('PA_FP_COPY_FROM_PKG.copy_wp_budget_versions:'||SQLERRM,1,240));
               RAISE FND_API.G_EXC_ERROR;
           END;
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        End;
      END IF;
        -- till here by skannoji

    -----------------------------------------FP_M Changes : End

      UPDATE pa_proj_element_versions ppevs1
         SET attribute15 = ( select attribute15 from pa_proj_element_versions ppevs2
                          where ppevs2.project_id = l_project_id
                            and parent_structure_version_id = p_structure_version_id
                            and ppevs2.element_version_id = ppevs1.attribute15
                             )
          WHERE project_id = l_project_id
        AND parent_structure_version_id = l_new_struct_ver_id
       ;


  x_new_struct_ver_id := l_new_struct_ver_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

  IF (p_debug_mode = 'Y') THEN
    pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.COPY_STRUCTURE_VERSION_BULK END');
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version_pvt_blk;
    end if;
    x_return_status := FND_API.G_RET_STS_ERROR;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version_pvt_blk;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'COPY_STRUCTURE_VERSION_BULK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
  when OTHERS then
    if p_commit = FND_API.G_TRUE then
      rollback to copy_structure_version_pvt_blk;
    end if;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'COPY_STRUCTURE_VERSION_BULK',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    raise;
END COPY_STRUCTURE_VERSION_BULK;

procedure update_sch_dirty_flag(
     p_project_id           IN NUMBER := NULL
    ,p_structure_version_id IN NUMBER
    ,p_dirty_flag           IN VARCHAR2 := 'N'
    ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_dirty_flag    VARCHAR2(1);
  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

   --Bug No 3634334
   --Commented the following query for performance reason and rewritten the same.
   --Getting the project_id from pa_proj_element_versions table instead of getting
   --it from pa_proj_elem_ver_structure table, in this optimizer will be using the
   --unique index on element_version_id and functionally the process is fetching
   --project_id
/*  CURSOR get_proj_id(cp_structure_version_id NUMBER) IS
  SELECT project_id
    FROM pa_proj_elem_ver_structure
   WHERE element_version_id = cp_structure_version_id;*/

  CURSOR get_proj_id(cp_structure_version_id NUMBER) IS
  SELECT project_id
    FROM pa_proj_element_versions
   WHERE element_version_id = cp_structure_version_id;
   l_proj_id   NUMBER;
BEGIN

/*  IF (p_dirty_flag = 'N') THEN
    l_dirty_flag := 'N';
  ELSE
    l_dirty_flag := 'Y';
  END IF;*/

  IF (p_dirty_flag IS NULL) THEN
    l_dirty_flag := 'N';
  ELSE
    l_dirty_flag := p_dirty_flag;
  END IF;
--
  IF p_project_id IS NULL THEN
     OPEN get_proj_id(p_structure_version_id);
     FETCH get_proj_id INTO l_proj_id;
     CLOSE get_proj_id;
--
     UPDATE pa_proj_elem_ver_structure
        SET SCHEDULE_DIRTY_FLAG = l_dirty_flag
      WHERE element_version_id = p_structure_version_id
         AND project_id = l_proj_id;
  ELSE
     UPDATE pa_proj_elem_ver_structure
        SET SCHEDULE_DIRTY_FLAG = l_dirty_flag
      WHERE element_version_id = p_structure_version_id
        AND project_id = p_project_id;
  END IF;

  x_return_status := l_return_status;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := FND_MSG_PUB.count_msg;
    --put message
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                            p_procedure_name => 'update_sch_dirty_flag',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;
END update_sch_dirty_flag;

--bug 3305199
--Please refer to update_structures_setup_old for old code
  PROCEDURE update_structures_setup_attr
  (  p_api_version      IN  NUMBER     := 1.0
    ,p_init_msg_list    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_commit           IN  VARCHAR2   := FND_API.G_FALSE
    ,p_validate_only    IN  VARCHAR2   := FND_API.G_TRUE
    ,p_validation_level IN  VARCHAR2   := 100
    ,p_calling_module   IN  VARCHAR2   := 'SELF_SERVICE'
    ,p_debug_mode       IN  VARCHAR2   := 'N'
    ,p_max_msg_count    IN  NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id IN NUMBER
    ,p_workplan_enabled_flag IN VARCHAR2
    ,p_financial_enabled_flag IN VARCHAR2
    ,p_sharing_enabled_flag IN VARCHAR2
    --FP M changes bug 3301192
    ,p_deliverables_enabled_flag       IN VARCHAR2
    ,p_sharing_option_code             IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    --End FP M changes bug 3301192
    ,p_sys_program_flag  IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_allow_multi_prog_rollup IN varchar2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_ret_stat           VARCHAR2(1);
    l_err_msg_code       VARCHAR2(250);
    l_suffix             VARCHAR2(80);
    l_name               VARCHAR2(240);
    l_append             VARCHAR2(10) := ': ';
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(250);
    l_structure_id       NUMBER;
    l_structure_version_id NUMBER;
    l_template_flag      VARCHAR2(1);
    l_status_code        VARCHAR2(30);
    l_baseline_flag      VARCHAR2(1);
    l_latest_eff_pub_flag VARCHAR2(1);
    l_effective_date     DATE;
    l_wp_attr_rvn        NUMBER;
    l_rowid              VARCHAR2(255);
    l_keep_structure_ver_id NUMBER;
    l_del_struc_ver_id   NUMBER;
    l_struc_ver_rvn      NUMBER;
    l_pev_structure_id   NUMBER;
    l_pev_schedule_id    NUMBER;
    l_struc_ver_attr_rvn NUMBER;
    l_struc_type_id      NUMBER;
    l_proj_structure_type_id NUMBER;
    l_task_id            NUMBER;
    l_element_version_id NUMBER;
    l_start_date         DATE;
    l_completion_date    DATE;
    l_object_type        VARCHAR2(30);
    l_task_ver_id        NUMBER;
   /* Bug 2790703 Begin */
    -- l_task_ver_ids       PA_NUM_1000_NUM := PA_NUM_1000_NUM();
    l_task_ver_ids_tbl PA_STRUCT_TASK_ROLLUP_PUB.pa_element_version_id_tbl_typ;
    l_index number :=0 ;
/* Bug 2790703 End */

    l_proj_start_Date DATE;
    l_proj_completion_date DATE;
    l_proj_prog_attr_id NUMBER;

    -- FP.M Changes below
    l_sys_program_flag        PA_PROJECTS_ALL.sys_program_flag%TYPE;
    l_allow_multi_program_rollup    PA_PROJECTS_ALL.allow_multi_program_rollup%TYPE;
    l_proj_sys_program_flag        PA_PROJECTS_ALL.sys_program_flag%TYPE;
    l_proj_allow_program_rollup    PA_PROJECTS_ALL.allow_multi_program_rollup%TYPE;
    l_flag                    VARCHAR2(1);

    -- NYU
    l_del_trans_exist VARCHAR2(1);

    CURSOR get_project_info IS
      select name, target_start_date, target_finish_date, sys_program_flag, allow_multi_program_rollup
        from pa_projects_all
       where project_id = p_project_id;

--bug 2843569: added record_version_number
    CURSOR get_template_flag IS
      select template_flag, record_version_number
        from pa_projects_all
       where project_id = p_project_id;

    CURSOR get_wp_attr_rvn IS
      select b.proj_element_id, a.record_version_number
        from pa_proj_workplan_attr a,
             pa_proj_elements b,
             pa_proj_structure_types c,
             pa_structure_types d
       where a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.project_id = p_project_id
         and b.proj_element_id = c.proj_element_id
         and c.structure_type_id = d.structure_type_id
         and d.structure_type_class_code = 'WORKPLAN';

    cursor sel_wp_struct_type(c_structure_id NUMBER) IS
      select a.rowid
        from pa_proj_structure_types a,
             pa_structure_types b
       where a.proj_element_id = c_structure_id
         and a.structure_type_id = b.structure_type_id
         and b.structure_type_class_code = 'WORKPLAN';

    cursor sel_latest_pub_ver(c_structure_id NUMBER) IS
      select element_version_id
        from pa_proj_elem_ver_structure
       where proj_element_id = c_structure_id
         and project_id = p_project_id
         and status_code = 'STRUCTURE_PUBLISHED'
         and LATEST_EFF_PUBLISHED_FLAG = 'Y';

    --bug 4054587, replace literal with bind variable
    l_wp_structure_code VARCHAR2(10) := 'WORKPLAN';
    cursor sel_wp_structure_id IS
      select a.proj_element_id
        from pa_proj_elements a,
             pa_proj_structure_types b,
             pa_structure_types c
       where a.project_id = p_project_id
         and a.object_type = 'PA_STRUCTURES'
         and a.proj_element_id = b.proj_element_id
         and b.structure_type_id = c.structure_type_id
         --and c.structure_type_class_code = 'WORKPLAN';
         and c.structure_type_class_code = l_wp_structure_code;

    cursor sel_other_structure_ver(c_keep_struc_ver_id NUMBER) IS
      select b.element_version_id, b.record_version_number
        from pa_proj_element_versions a,
             pa_proj_element_versions b
       where a.element_version_id = c_keep_struc_ver_id
         and a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.element_version_id <> c_keep_struc_ver_id
         and b.object_type = 'PA_STRUCTURES';

    cursor sel_all_wp_structure_ver(c_struc_id NUMBER) IS
      select a.element_version_id, a.record_version_number
        from pa_proj_element_versions a,
             pa_proj_elements b
       where a.proj_element_id = b.proj_element_id
         and a.project_id = b.project_id
         and b.proj_element_id = c_struc_id;

    cursor sel_struc_ver_attr_rvn(c_struc_ver_id NUMBER) IS
      select PEV_STRUCTURE_ID, record_version_number
        from pa_proj_elem_ver_structure
       where project_id = p_project_id
         and element_version_id = c_struc_ver_id;

    cursor sel_proj_workplan_attr(c_struc_id NUMBER) is
      select *
        from pa_proj_workplan_attr
       where proj_element_id = c_struc_id;
    l_proj_workplan_attr_rec  sel_proj_workplan_attr%ROWTYPE;

    cursor sel_proj_progress_attr(c_struc_id NUMBER) IS
      select *
        from pa_proj_progress_attr
       where project_id = p_project_id
         and object_type = 'PA_STRUCTURES'
         and object_id = c_struc_id;
    l_proj_progress_attr_rec  sel_proj_progress_attr%ROWTYPE;

    --bug 4054587, replace literal with bind variable
    l_fin_structure_code VARCHAR2(10) := 'FINANCIAL';
    cursor sel_fin_structure_id IS
      select a.proj_element_id
        from pa_proj_elements a,
             pa_proj_structure_types b,
             pa_structure_types c
       where a.project_id = p_project_id
         and a.object_type = 'PA_STRUCTURES'
         and a.proj_element_id = b.proj_element_id
         and b.structure_type_id = c.structure_type_id
         --and c.structure_type_class_code = 'FINANCIAL';
         and c.structure_type_class_code = l_fin_structure_code;

    CURSOR sel_struc_type_id IS
      select structure_type_id
        from pa_structure_types
       where structure_type_class_code = 'WORKPLAN';

    cursor sel_struc_ver(c_structure_id NUMBER) IS
      select element_version_id
        from pa_proj_element_versions
       where project_id = p_project_id
         and proj_element_id = c_structure_id
         and object_type = 'PA_STRUCTURES';

--hsiu: commented for performance
--    cursor sel_struc_and_task_vers(c_struc_ver_id NUMBER) IS
--      select object_type, proj_element_id, element_version_id
--        from pa_proj_element_versions
--       where parent_structure_version_id = c_struc_ver_id;
    cursor sel_struc_and_task_vers(c_struc_ver_id NUMBER) IS
      select pev.object_type, pev.proj_element_id, pev.element_version_id
        from pa_proj_element_versions pev, pa_object_relationships rel
       where pev.parent_structure_version_id = c_struc_ver_id
         and rel.object_id_to1 = pev.element_version_id
         and rel.relationship_type = 'S'
         and NOT EXISTS (
               select 1
                 from pa_object_Relationships
                where object_id_from1 = pev.element_version_id
                  and relationship_type = 'S'
             );


    cursor sel_task_dates(c_task_id NUMBER) IS
      select start_date, completion_date
        from pa_tasks
       where task_id = c_task_id;

--hsiu added for bug 2634029
    cursor sel_target_dates IS
      select target_start_date, target_finish_date, calendar_id
        from pa_projects_all
       where project_id = p_project_id;

    CURSOR get_top_tasks(c_structure_version_id NUMBER) IS
           select v.element_version_id
             from pa_proj_element_versions v,
                  pa_object_relationships r
            where v.element_version_id = r.object_id_to1
              and r.object_id_from1 = c_structure_version_id
              and r.object_type_from = 'PA_STRUCTURES';

--bug 2843569
    CURSOR get_scheduled_dates(c_project_Id NUMBER,
                                c_element_version_id NUMBER) IS
           select a.scheduled_start_date, a.scheduled_finish_date
             from pa_proj_elem_ver_schedule a
            where a.project_id = c_project_id
              and a.element_version_id = c_element_version_id;
    l_get_sch_dates_cur get_scheduled_dates%ROWTYPE;
    l_proj_rec_ver_num      NUMBER;
--end bug 2843569

    l_target_start_date     DATE;
    l_target_finish_date    DATE;
    l_calendar_id           NUMBER;
--end changes for bug 2634029

--bug 3010538
    l_task_weight_basis_code VARCHAR2(30);
    l_update_proc_wbs_flag VARCHAR2(1);
--end bug 3010538

    l_wp_name               VARCHAR2(240);

    CURSOR sel_fin_struc_type_id IS
      select structure_type_id
        from pa_structure_types
       where structure_type_class_code = 'FINANCIAL';
    l_fin_struc_type_id NUMBER;
    l_del_name          VARCHAR2(240);
    l_wp_enabled        VARCHAR2(1);
    l_fin_enabled       VARCHAR2(1);
    l_delv_enabled      VARCHAR2(1);
    l_share_code        VARCHAR2(30);
    l_new_share_code    VARCHAR2(30);

    l_struct_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

/*  Bug # 3420093. Progress Management changes. */

    l_proj_progress_attr_id     NUMBER;

/*      Bug # 3420093. Progress Management changes.     */

-- Begin fix for Bug # 4426392.

   cursor cur_program (c_project_id NUMBER) is
   select 'Y'
   from pa_object_relationships por
   where (por.object_id_from2 = c_project_id
          or por.object_id_to2 = c_project_id)
   and por.relationship_type in ('LW', 'LF');

   l_program    VARCHAR2(1) := null;

   cursor cur_links (c_project_id NUMBER) is
   -- Select links from the working structure version of all parent projects
   -- with sharing enabled to the given project.
   select por1.object_relationship_id obj_rel_id
          , por1.object_id_from2 src_proj_id
          , por2.object_id_from1 task_ver_id
          , c_project_id dest_proj_id
          , ppev.parent_structure_version_id src_str_ver_id
          , por1.record_version_number rec_ver_number
   from pa_object_relationships por1
        , pa_object_relationships por2
        , pa_projects_all ppa
        , pa_proj_element_versions ppev
        , pa_proj_elem_ver_structure ppevs
   where por1.object_id_to2 = c_project_id
         and por1.relationship_type in ('LW', 'LF')
         and por1.object_id_from1 = por2.object_id_to1
         and por2.relationship_type = 'S'
         and por1.object_id_from2 = ppa.project_id
         and ppa.structure_sharing_code in ('SHARE_FULL', 'SHARE_PARTIAL')
         and por2.object_id_from1 = ppev.element_version_id
         -- Bug Fix 4868867
         -- Ram Namburi
         -- adding the following additional project id join to avoid the Full Table Scan on
         --  pa_proj_elem_ver_structure table and to use N1.
         and ppev.project_id = ppevs.project_id
         and ppev.parent_structure_version_id = ppevs.element_version_id
         and ppevs.current_working_flag = 'Y'
   union
   -- Select links from the working structure version of the given project to all child projects
   -- with sharing enabled.
    select por1.object_relationship_id obj_rel_id
          , c_project_id src_proj_id
          , por2.object_id_from1 task_ver_id
          , por1.object_id_to2 dest_proj_id
          , ppev.parent_structure_version_id src_str_ver_id
          , por1.record_version_number rec_ver_number
   from pa_object_relationships por1
        , pa_object_relationships por2
        , pa_projects_all ppa
        , pa_proj_element_versions ppev
        , pa_proj_elem_ver_structure ppevs
   where por1.object_id_from2 = c_project_id
         and por1.relationship_type in ('LW', 'LF')
         and por1.object_id_from1 = por2.object_id_to1
         and por2.relationship_type = 'S'
         and por1.object_id_to2 = ppa.project_id
         and ppa.structure_sharing_code in ('SHARE_FULL', 'SHARE_PARTIAL')
         and por2.object_id_from1 = ppev.element_version_id
         -- Bug Fix 4868867
         -- Ram Namburi
         -- adding the following additional project id join to avoid the Full Table Scan on
         --  pa_proj_elem_ver_structure table and to use N1.
         and ppev.project_id = ppevs.project_id
         and ppev.parent_structure_version_id = ppevs.element_version_id
         and ppevs.current_working_flag = 'Y';

   l_cur_links_rec      cur_links%rowtype;

   l_comment            VARCHAR2(30) := null;

   l_dest_proj_name     VARCHAR2(30) := null;

-- End fix for Bug # 4426392.

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.update_structures_setup_attr');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_struc_setup_attr_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

l_wp_enabled := PA_PROJECT_STRUCTURE_UTILS.Check_workplan_enabled(p_project_id);
l_fin_enabled := PA_PROJECT_STRUCTURE_UTILS.Check_financial_enabled(p_project_id);
l_share_code := PA_PROJECT_STRUCTURE_UTILS.Get_Structure_sharing_code(p_project_id);
l_delv_enabled := PA_PROJECT_STRUCTURE_UTILS.Check_deliverable_enabled(p_project_id);


--get template flag
OPEN get_template_flag;
FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
CLOSE get_template_flag;

--get project name
OPEN get_project_info;
FETCH get_project_info into l_name, l_proj_start_date, l_proj_completion_date, l_proj_sys_program_flag, l_proj_allow_program_rollup;
CLOSE get_project_info;

-- Begin fix for Bug # 4426392.

-- If a project is part of a program then the user cannot disable its project structures
-- or change its structure integration option from split tp shared or vice-versa.

-- Please ensure that this code s always the first check in this API.

open cur_program(p_project_id);
fetch cur_program into l_program;
close cur_program;

if (
     (nvl(l_program,'N') = 'Y')
     and (((l_wp_enabled = 'Y') and (p_workplan_enabled_flag = 'N'))
         or ((l_fin_enabled = 'Y') and (p_financial_enabled_flag = 'N'))
         or ((l_share_code in ('SHARE_FULL','SHARE_PARTIAL'))
             and (p_sharing_option_code in ('SPLIT_MAPPING','SPLIT_NO_MAPPING')))
         or ((l_share_code in ('SPLIT_MAPPING','SPLIT_NO_MAPPING'))
             and (p_sharing_option_code IN ('SHARE_FULL','SHARE_PARTIAL'))))
    ) then

        PA_UTILS.ADD_MESSAGE('PA', 'PA_WP_PROG_CANT_CHG_STR');

        RAISE FND_API.G_EXC_ERROR;

end if;

-- End fix for Bug # 4426392.

--check if ok to enable workplan
If (l_wp_enabled <> p_workplan_enabled_flag AND p_workplan_enabled_flag = 'Y') THEN
  -- Bug 6832737 Changed check_disable_wp_ok to check_enable_wp_ok
  --PA_PROJECT_STRUCTURE_UTILS.check_disable_wp_ok(p_project_id,
  PA_PROJECT_STRUCTURE_UTILS.check_enable_wp_ok(p_project_id,
                                                       l_ret_stat,
                                                       l_err_msg_code);
  IF (l_ret_stat = 'N') THEN
    PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
    x_msg_data := l_err_msg_code;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
END IF;

--check if ok to disable workplan
IF (l_wp_enabled <> p_workplan_enabled_flag AND p_workplan_enabled_flag = 'N') THEN
  PA_PROJECT_STRUCTURE_UTILS.check_disable_wp_ok(p_project_id,
                                                       l_ret_stat,
                                                       l_err_msg_code);
  IF (l_ret_stat = 'N') THEN
    PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
    x_msg_data := l_err_msg_code;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
END IF;

--check if ok to share
    IF (l_share_code IN ('SPLIT_MAPPING','SPLIT_NO_MAPPING') and p_sharing_option_code IN ('SHARE_FULL','SHARE_PARTIAL')) THEN
        PA_PROJECT_STRUCTURE_UTILS.check_sharing_on_ok(p_project_id,
                                                       l_ret_stat,
                                                       l_err_msg_code);
        IF (l_ret_stat = 'N') THEN
            PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
            x_msg_data := l_err_msg_code;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

--check if ok to split
  IF (l_share_code IN ('SHARE_FULL','SHARE_PARTIAL') and p_sharing_option_code IN ('SPLIT_MAPPING','SPLIT_NO_MAPPING')) THEN
    PA_PROJECT_STRUCTURE_UTILS.check_sharing_off_ok(p_project_id,
                                                        l_ret_stat,
                                                        l_err_msg_code);
    IF (l_ret_stat = 'N') THEN
      PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
      x_msg_data := l_err_msg_code;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

IF (l_proj_completion_date IS NULL AND l_proj_start_date IS NOT NULL) THEN
  l_proj_completion_date := l_proj_start_date;
ELSIF (l_proj_completion_date IS NULL AND l_proj_start_date IS NULL) THEN
  l_proj_completion_date := sysdate;
  l_proj_start_date := sysdate;
END IF;

--get suffix
select meaning
into l_suffix
from pa_lookups
where lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
and lookup_code = 'WORKPLAN';
--get workplan name
l_wp_name := substrb(l_name||l_append||l_suffix, 1, 240);

--check for
IF (l_wp_enabled = 'N' and l_fin_enabled = 'N') THEN
  --both currently disabled
  IF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'N') THEN
    --disabled both
    NULL;
  ELSIF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'Y') THEN
    --disable workplan (enable financial)
    --create financial structure API
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only => FND_API.G_FALSE
    ,p_project_id    => p_project_id
    ,p_structure_number => l_name
    ,p_structure_name   => l_name
    ,p_calling_flag     => 'FINANCIAL'
    ,x_structure_id     => l_structure_id
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create row in pa_proj_workplan_attr
    PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE
    (p_validate_only => FND_API.G_FALSE
    ,p_project_id => p_project_id
    ,p_proj_element_id => l_structure_id
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disable financial (enable workplan)
    --create workplan structure
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only           => FND_API.G_FALSE
    ,p_project_id              => p_project_id
    ,p_structure_number        => l_wp_name
    ,p_structure_name          => l_wp_name
    ,p_calling_flag            => 'WORKPLAN'
    ,x_structure_id            => l_structure_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_TASK_PUB1.Create_Schedule_Version(
     p_element_version_id      => l_structure_version_id
    ,p_scheduled_start_date    => l_proj_start_date
    ,p_scheduled_end_date      => l_proj_completion_date
    ,x_pev_schedule_id         => l_pev_schedule_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'Y';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SHARE_PARTIAL', 'SHARE_FULL')) THEN
    --partial share/full share
    --enable workplan structure API
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only           => FND_API.G_FALSE
    ,p_project_id              => p_project_id
    ,p_structure_number        => l_name
    ,p_structure_name          => l_name
    ,p_calling_flag            => 'WORKPLAN'
    ,x_structure_id            => l_structure_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_TASK_PUB1.Create_Schedule_Version(
     p_element_version_id      => l_structure_version_id
    ,p_scheduled_start_date    => l_proj_start_date
    ,p_scheduled_end_date      => l_proj_completion_date
    ,x_pev_schedule_id         => l_pev_schedule_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'Y';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create financial type
    OPEN sel_fin_struc_type_id;
    FETCH sel_fin_struc_type_id INTO l_fin_struc_type_id;
    CLOSE sel_fin_struc_type_id;

    l_proj_structure_type_id := NULL;
    PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
     X_ROWID                  => l_rowid
    ,X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
    ,X_PROJ_ELEMENT_ID        => l_structure_id
    ,X_STRUCTURE_TYPE_ID      => l_fin_struc_type_id
    ,X_RECORD_VERSION_NUMBER  => 1
    ,X_ATTRIBUTE_CATEGORY     => NULL
    ,X_ATTRIBUTE1             => NULL
    ,X_ATTRIBUTE2             => NULL
    ,X_ATTRIBUTE3             => NULL
    ,X_ATTRIBUTE4             => NULL
    ,X_ATTRIBUTE5             => NULL
    ,X_ATTRIBUTE6             => NULL
    ,X_ATTRIBUTE7             => NULL
    ,X_ATTRIBUTE8             => NULL
    ,X_ATTRIBUTE9             => NULL
    ,X_ATTRIBUTE10            => NULL
    ,X_ATTRIBUTE11            => NULL
    ,X_ATTRIBUTE12            => NULL
    ,X_ATTRIBUTE13            => NULL
    ,X_ATTRIBUTE14            => NULL
    ,X_ATTRIBUTE15            => NULL
    );

    IF (p_sharing_option_code = 'SHARE_PARTIAL') THEN
      NULL;
    ELSIF (p_sharing_option_code = 'SHARE_FULL') THEN
      NULL;
    END IF;

/*  Bug # 3420093. Progress Management changes. */

  --create row in pa_proj_progress_attr
  PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
  p_project_id                  => p_project_id
 ,P_OBJECT_TYPE                 => 'PA_STRUCTURES'
 ,P_OBJECT_ID                   => l_structure_id
 ,P_PROGRESS_CYCLE_ID           => to_number(null)
 ,P_WQ_ENABLE_FLAG              => 'N'
 ,P_REMAIN_EFFORT_ENABLE_FLAG       => 'N'
 ,P_PERCENT_COMP_ENABLE_FLAG        => 'Y'
 ,P_NEXT_PROGRESS_UPDATE_DATE       => to_date(null)
 ,p_TASK_WEIGHT_BASIS_CODE          => 'COST'
 ,X_PROJ_PROGRESS_ATTR_ID           => l_proj_progress_attr_id
 ,P_ALLOW_COLLAB_PROG_ENTRY         => 'N'
 ,P_ALLW_PHY_PRCNT_CMP_OVERRIDES    => 'Y'
 ,p_structure_type                      => 'FINANCIAL' --Amit
 ,x_return_status                   => l_return_status
 ,x_msg_count                   => l_msg_count
 ,x_msg_data                    => l_msg_data
);

/*      Bug # 3420093. Progress Management changes.     */


  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SPLIT_MAPPING','SPLIT_NO_MAPPING')) THEN
    --split mapping/split no mapping
    --enable financial structure API
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only => FND_API.G_FALSE
    ,p_project_id    => p_project_id
    ,p_structure_number => l_name
    ,p_structure_name   => l_name
    ,p_calling_flag     => 'FINANCIAL'
    ,x_structure_id     => l_structure_id
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create row in pa_proj_workplan_attr
    PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE
    (p_validate_only => FND_API.G_FALSE
    ,p_project_id => p_project_id
    ,p_proj_element_id => l_structure_id
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create workplan structure
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only           => FND_API.G_FALSE
    ,p_project_id              => p_project_id
    ,p_structure_number        => l_wp_name
    ,p_structure_name          => l_wp_name
    ,p_calling_flag            => 'WORKPLAN'
    ,x_structure_id            => l_structure_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_TASK_PUB1.Create_Schedule_Version(
     p_element_version_id      => l_structure_version_id
    ,p_scheduled_start_date    => l_proj_start_date
    ,p_scheduled_end_date      => l_proj_completion_date
    ,x_pev_schedule_id         => l_pev_schedule_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'Y';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_sharing_option_code = 'SPLIT_MAPPING') THEN
      NULL;
    ELSIF (p_sharing_option_code = 'SPLIT_NO_MAPPING') THEN
      NULL;
    END IF;

  END IF;

ELSIF (l_wp_enabled = 'N' and l_fin_enabled = 'Y') THEN
  --workplan currently disabled (financial enabled)
  IF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'N') THEN
    --disabled both
    --disable financial structure API
    PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE(
     p_validate_only     => FND_API.G_FALSE
    ,p_project_id        => p_project_id
    ,x_return_status     => l_return_status
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'Y') THEN
    --disable workplan (enable financial)
    NULL;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disable financial (enable workplan)
    --disable financial structure API
    PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE(
     p_validate_only     => FND_API.G_FALSE
    ,p_project_id        => p_project_id
    ,x_return_status     => l_return_status
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create workplan structure
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only           => FND_API.G_FALSE
    ,p_project_id              => p_project_id
    ,p_structure_number        => l_wp_name
    ,p_structure_name          => l_wp_name
    ,p_calling_flag            => 'WORKPLAN'
    ,x_structure_id            => l_structure_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_TASK_PUB1.Create_Schedule_Version(
     p_element_version_id      => l_structure_version_id
    ,p_scheduled_start_date    => l_proj_start_date
    ,p_scheduled_end_date      => l_proj_completion_date
    ,x_pev_schedule_id         => l_pev_schedule_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'Y';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_wp_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SHARE_PARTIAL', 'SHARE_FULL')) THEN
    --partial share
    --add workplan structure type
    OPEN sel_fin_structure_id;
    FETCH sel_fin_structure_id into l_structure_id;
    CLOSE sel_fin_structure_id;

    OPEN sel_struc_type_id;
    FETCH sel_struc_type_id INTO l_struc_type_id;
    CLOSE sel_struc_type_id;

    l_proj_structure_type_id := NULL;
    PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
     X_ROWID                  => l_rowid
    ,X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
    ,X_PROJ_ELEMENT_ID        => l_structure_id
    ,X_STRUCTURE_TYPE_ID      => l_struc_type_id
    ,X_RECORD_VERSION_NUMBER  => 1
    ,X_ATTRIBUTE_CATEGORY     => NULL
    ,X_ATTRIBUTE1             => NULL
    ,X_ATTRIBUTE2             => NULL
    ,X_ATTRIBUTE3             => NULL
    ,X_ATTRIBUTE4             => NULL
    ,X_ATTRIBUTE5             => NULL
    ,X_ATTRIBUTE6             => NULL
    ,X_ATTRIBUTE7             => NULL
    ,X_ATTRIBUTE8             => NULL
    ,X_ATTRIBUTE9             => NULL
    ,X_ATTRIBUTE10            => NULL
    ,X_ATTRIBUTE11            => NULL
    ,X_ATTRIBUTE12            => NULL
    ,X_ATTRIBUTE13            => NULL
    ,X_ATTRIBUTE14            => NULL
    ,X_ATTRIBUTE15            => NULL);

    --add progress row
    l_proj_prog_attr_id := NULL;
    PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
     p_validate_only       => FND_API.G_FALSE
    ,p_project_id          => p_project_id
    ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
    ,P_OBJECT_ID           => l_structure_id
    ,p_action_set_id       => NULL
    ,p_structure_type      => 'WORKPLAN' -- Amit
    ,x_proj_progress_attr_id => l_proj_prog_attr_id
    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN sel_struc_ver(l_structure_id);
    FETCH sel_struc_ver into l_structure_version_id;
    CLOSE sel_struc_ver;

    --add financial planning
    /*Smukka Bug No. 3474141 Date 03/01/2004                                                 */
    /*moved PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions into plsql block        */
    BEGIN
        PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions(
                      p_context                => 'WORKPLAN'
                     ,p_project_id             => p_project_id
                     ,p_struct_elem_version_id => l_structure_version_id
                     ,x_return_status          => l_return_status
                     ,x_msg_count              => x_msg_count
                     ,x_Msg_data               => x_msg_data);
    EXCEPTION
       WHEN OTHERS THEN
            fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                    p_procedure_name => 'update_structures_setup_attr',
                                    p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions:'||SQLERRM,1,240));
       RAISE FND_API.G_EXC_ERROR;
    END;
    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    --create schedule row for each task
    INSERT INTO PA_PROJ_ELEM_VER_SCHEDULE(
          pev_schedule_id,
          element_version_id,
          project_id,
          proj_element_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          scheduled_start_date,
          scheduled_finish_date,
          milestone_flag,
          critical_flag,
          calendar_id,
          record_version_number,
          last_update_login,
      source_object_id,
      source_object_type)
    SELECT
          pa_proj_elem_ver_schedule_s.nextval,
          PPEV.element_version_id,
          PPEV.project_id,
          PPEV.proj_element_id,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.START_DATE), trunc(l_proj_start_date))),
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.COMPLETION_DATE), trunc(l_proj_completion_date))),
          'N',
          'N',
          NULL,
          0,
          FND_GLOBAL.LOGIN_ID,
      PPEV.project_id,
      'PA_PROJECTS'
    FROM PA_TASKS PT,
         PA_PROJ_ELEMENT_VERSIONS PPEV
    WHERE
         PPEV.parent_structure_version_id = l_structure_version_id
    AND  PPEV.proj_element_id = PT.task_id (+);

    OPEN sel_struc_and_task_vers(l_structure_version_id);
    LOOP
      FETCH sel_struc_and_task_vers into l_object_type, l_task_id, l_element_version_id;
      EXIT WHEN sel_struc_and_task_vers%NOTFOUND;
      /* Bug 2790703 Begin */
      --Add to array for rollup
      l_index := l_index + 1;
      l_task_ver_ids_tbl(l_index) := l_element_version_id;
      /* Bug 2790703 End */
      END LOOP;
    CLOSE sel_struc_and_task_vers;

    IF (l_task_ver_ids_tbl.count > 0) THEN
      --rollup
      PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
       p_commit => FND_API.G_FALSE,
       p_element_versions => l_task_ver_ids_tbl,
       x_return_status => l_return_status,
       x_msg_count => l_msg_count,
       x_msg_data => l_msg_data);

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

    IF (l_status_code = 'STRUCTURE_PUBLISHED') OR
       (l_template_flag = 'Y') THEN
      OPEN get_scheduled_dates(p_project_id, l_structure_version_id);
      FETCH get_scheduled_dates into l_get_sch_dates_cur;
      CLOSE get_scheduled_dates;

      /* the record version number contained in the variabe l_proj_rec_ver_num is
        no more latest bcoz there was an update done by some other api by now.
        selcting latest record version number to avoid concurrency issue. maansari*/
      OPEN get_template_flag;
      FETCH get_template_flag into l_template_flag, l_proj_rec_ver_num;
      CLOSE get_template_flag;

      PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
            p_validate_only        => FND_API.G_FALSE
           ,p_project_id           => p_project_id
           ,p_date_type            => 'SCHEDULED'
           ,p_start_date           => l_get_sch_dates_cur.scheduled_start_date
           ,p_finish_date          => l_get_sch_dates_cur.scheduled_finish_date
           ,p_record_version_number=> l_proj_rec_ver_num
           ,x_return_status        => x_return_status
           ,x_msg_count            => x_msg_count
           ,x_msg_data             => x_msg_data );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    RECALC_FIN_TASK_WEIGHTS(
       p_structure_version_id => l_structure_version_id
     , p_project_id           => p_project_id
     , x_msg_count            => l_msg_count
     , x_msg_data             => l_msg_data
     , x_return_status        => l_return_status);

    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

-- Begin fix for Bug # 4426392.

-- For a FINANCIAL structure only project that is part of a program, if WORKPLAN structure is enabled
-- and the structures are SHARED.

if (nvl(l_program, 'N') = 'Y') then

        for l_cur_links_rec in cur_links (p_project_id)
        loop

                -- Delete the 'LW' or 'LF' links that currently exist from the task version.

                pa_relationship_pub.delete_subproject_association
                (p_api_version                   =>     p_api_version
                ,p_init_msg_list                 =>     p_init_msg_list
                ,p_commit                        =>     p_commit
                ,p_validate_only                 =>     p_validate_only
                ,p_validation_level              =>     p_validation_level
                ,p_calling_module                =>     p_calling_module
                ,p_debug_mode                    =>     p_debug_mode
                ,p_max_msg_count                 =>     p_max_msg_count
                ,p_object_relationships_id       =>     l_cur_links_rec.obj_rel_id
                ,p_record_version_number         =>     l_cur_links_rec.rec_ver_number
                ,x_return_status                 =>     x_return_status
                ,x_msg_count                     =>     x_msg_count
                ,x_msg_data                      =>     x_msg_data);

                -- Create both the 'LW' and 'LF' links anew from the task version.

                pa_relationship_pub.create_subproject_association
                (p_api_version                   =>     p_api_version
                ,p_init_msg_list                 =>     p_init_msg_list
                ,p_commit                        =>     p_commit
                ,p_validate_only                 =>     p_validate_only
                ,p_validation_level              =>     p_validation_level
                ,p_calling_module                =>     p_calling_module
                ,p_debug_mode                    =>     p_debug_mode
                ,p_max_msg_count                 =>     p_max_msg_count
                ,p_src_proj_id                   =>     l_cur_links_rec.src_proj_id
                ,p_task_ver_id                   =>     l_cur_links_rec.task_ver_id
                ,p_dest_proj_id                  =>     l_cur_links_rec.dest_proj_id
                ,p_dest_proj_name                =>     l_dest_proj_name
                ,p_comment                       =>     l_comment
                ,x_return_status                 =>     x_return_status
                ,x_msg_count                     =>     x_msg_count
                ,x_msg_data                      =>     x_msg_data);

                -- Set the process update flag for the source structure version to 'Y'.

                update pa_proj_elem_ver_structure ppevs
                set ppevs.process_update_wbs_flag = 'Y'
                where ppevs.element_version_id = l_cur_links_rec.src_str_ver_id
                and ppevs.project_id = l_cur_links_rec.src_proj_id;

        end loop;

end if;

-- End fix for Bug # 4426392.

    IF (p_sharing_option_code = 'SHARE_PARTIAL') THEN
      --extra code for partial share
      NULL;
    ELSIF (p_sharing_option_code = 'SHARE_FULL') THEN
      --extra code for full share
      NULL;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SPLIT_NO_MAPPING', 'SPLIT_MAPPING')) THEN
    --split mapping
    --Create default workplan structure
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only           => FND_API.G_FALSE
    ,p_project_id              => p_project_id
    ,p_structure_number        => l_wp_name
    ,p_structure_name          => l_wp_name
    ,p_calling_flag            => 'WORKPLAN'
    ,x_structure_id            => l_structure_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_TASK_PUB1.Create_Schedule_Version(
     p_element_version_id      => l_structure_version_id
    ,p_scheduled_start_date    => l_proj_start_date
    ,p_scheduled_end_date      => l_proj_completion_date
    ,x_pev_schedule_id         => l_pev_schedule_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'Y';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_sharing_option_code = 'SPLIT_NO_MAPPING') THEN
      NULL;
    ELSIF (p_sharing_option_code = 'SPLIT_MAPPING') THEN
      NULL;
    END IF;
  END IF;

ELSIF (l_wp_enabled = 'Y' and l_fin_enabled = 'N') THEN
  --financial currently disabled
  IF (p_workplan_enabled_flag = 'N') THEN
    --disabled both
    --delete all dependencies
    --disable workplan

    --get structure_id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    --delete workplan structure
    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                          l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
      PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --get top tasks
      OPEN get_top_tasks(l_del_struc_ver_id);
      LOOP
        FETCH get_top_tasks into l_task_ver_id;
        EXIT WHEN get_top_tasks%NOTFOUND;

        PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

        IF (l_return_status <> 'S') THEN
          x_return_status := l_return_status;
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          l_msg_data := l_err_msg_code;
          CLOSE get_top_tasks;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE get_top_tasks;

      PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
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
        CLOSE sel_all_wp_structure_ver;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE sel_all_wp_structure_ver;

    IF (p_financial_enabled_flag = 'N') THEN
      NULL;
    ELSIF (p_financial_enabled_flag = 'Y') THEN
      --call enable financial structure API
      --enable financial structure API
      PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
      (p_validate_only => FND_API.G_FALSE
      ,p_project_id    => p_project_id
      ,p_structure_number => l_name
      ,p_structure_name   => l_name
      ,p_calling_flag     => 'FINANCIAL'
      ,x_structure_id     => l_structure_id
      ,x_return_status    => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --create row in pa_proj_workplan_attr
      PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE
      (p_validate_only => FND_API.G_FALSE
      ,p_project_id => p_project_id
      ,p_proj_element_id => l_structure_id
      ,x_return_status    => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --create structure version
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
      (p_validate_only         => FND_API.G_FALSE
      ,p_structure_id          => l_structure_id
      ,x_structure_version_id  => l_structure_version_id
      ,x_return_status         => l_return_status
      ,x_msg_count             => l_msg_count
      ,x_msg_data              => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_template_flag = 'Y') THEN
        l_status_code := 'STRUCTURE_WORKING';
        l_baseline_flag := 'N';
        l_latest_eff_pub_flag := 'N';
        l_effective_date := NULL;
      ELSE
        l_status_code := 'STRUCTURE_PUBLISHED';
        l_baseline_flag := 'N';
        l_latest_eff_pub_flag := 'Y';
        l_effective_date := sysdate;
      END IF;

      --create structure version
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
      (p_validate_only               => FND_API.G_FALSE
      ,p_structure_version_id        => l_structure_version_id
      ,p_structure_version_name      => l_name
      ,p_structure_version_desc      => NULL
      ,p_effective_date              => l_effective_date
      ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
      ,p_locked_status_code          => 'UNLOCKED'
      ,p_struct_version_status_code  => l_status_code
      ,p_baseline_current_flag       => l_baseline_flag
      ,p_baseline_original_flag      => 'N'
      ,x_pev_structure_id            => l_pev_structure_id
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data );

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

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disable financial (enable workplan), do nothing
    NULL;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SHARE_PARTIAL','SHARE_FULL')) THEN
    --partial share
    --add financial structure type
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    --create financial type
    OPEN sel_fin_struc_type_id;
    FETCH sel_fin_struc_type_id INTO l_fin_struc_type_id;
    CLOSE sel_fin_struc_type_id;

    l_proj_structure_type_id := NULL;
    PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
     X_ROWID                  => l_rowid
    ,X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
    ,X_PROJ_ELEMENT_ID        => l_structure_id
    ,X_STRUCTURE_TYPE_ID      => l_fin_struc_type_id
    ,X_RECORD_VERSION_NUMBER  => 1
    ,X_ATTRIBUTE_CATEGORY     => NULL
    ,X_ATTRIBUTE1             => NULL
    ,X_ATTRIBUTE2             => NULL
    ,X_ATTRIBUTE3             => NULL
    ,X_ATTRIBUTE4             => NULL
    ,X_ATTRIBUTE5             => NULL
    ,X_ATTRIBUTE6             => NULL
    ,X_ATTRIBUTE7             => NULL
    ,X_ATTRIBUTE8             => NULL
    ,X_ATTRIBUTE9             => NULL
    ,X_ATTRIBUTE10            => NULL
    ,X_ATTRIBUTE11            => NULL
    ,X_ATTRIBUTE12            => NULL
    ,X_ATTRIBUTE13            => NULL
    ,X_ATTRIBUTE14            => NULL
    ,X_ATTRIBUTE15            => NULL
    );

    --get structure version id
    OPEN sel_struc_ver(l_structure_id);
    FETCH sel_struc_ver into l_structure_version_id;
    CLOSE sel_struc_ver;

    -- Bug 3938654 : Additional Fix that will go as a part of this bug
    --               This fix is not related to main issue reported in the bug

    -- The present case is when WP is already enabled (l_wp_enabled = Y) and Fin. is disabled(l_fin_enabled = N)
    --  But Now,We have enabled Fin. (i.e) p_financial_enabled_flag = Y and made in a shared structure(may be full / partial)

    -- In this Case ,The Already Existing Structure Name will be of the format l_name : Workplan
    -- (Because earlier itself WP was enabled and the structure name hence would be of above format)

    -- While we are going to 'SHARE' it now ,We have to reset the Structure Name Format to : l_name
    -- This is needed because : Later If we try to Split the structure ,It will again try to create an empty
    -- WP Structure with the structure name in the format l_name : Workplan

    -- Hence ,the structure split will not be allowed as "name not unique error will be thrown"
    -- To avoid this Problem , We are resetting the structure name before Sharing

    UPDATE pa_proj_elements
       SET name = l_name
          ,element_number = l_name
     WHERE proj_element_id = l_structure_id ;

    -- End of Fix : 3938654

    --bug 4114101
    --insert progress attr row for financial struc
    PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
     p_validate_only            => FND_API.G_FALSE
    ,p_project_id               => p_project_id
    ,P_OBJECT_TYPE              => 'PA_STRUCTURES'
    ,P_OBJECT_ID                => l_structure_id
    ,P_PROGRESS_CYCLE_ID        => to_number(null)
    ,P_WQ_ENABLE_FLAG           => 'N'
    ,P_REMAIN_EFFORT_ENABLE_FLAG    => 'N'
    ,P_PERCENT_COMP_ENABLE_FLAG     => 'Y'
    ,P_NEXT_PROGRESS_UPDATE_DATE    => to_date(null)
    ,p_TASK_WEIGHT_BASIS_CODE       => 'COST'
    ,X_PROJ_PROGRESS_ATTR_ID        => l_proj_progress_attr_id
    ,P_ALLOW_COLLAB_PROG_ENTRY      => 'N'
    ,P_ALLW_PHY_PRCNT_CMP_OVERRIDES     => 'Y'
    ,p_structure_type                   => 'FINANCIAL' --Amit
    ,x_return_status                => l_return_status
    ,x_msg_count                => l_msg_count
    ,x_msg_data                     => l_msg_data
    );

    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --end bug 4114101

    IF (p_sharing_option_code = 'SHARE_PARTIAL') THEN
      NULL;
    ELSIF (p_sharing_option_code = 'SHARE_FULL') THEN
      --set financial task flag to Y for all tasks
      update pa_proj_element_versions
         set financial_task_flag = 'Y'
       where parent_structure_version_id = l_structure_version_id
         and object_type = 'PA_TASKS'
         and proj_element_id NOT IN
             (select proj_element_id
                from pa_proj_elements
               where project_id = p_project_id
                 and object_type = 'PA_TASKS'
                 and link_task_flag = 'Y');
    END IF;

    --need to call sync up API
    PA_TASKS_MAINT_PUB.SYNC_UP_WP_TASKS_WITH_FIN
     (p_patask_record_version_number   => NULL
     ,p_parent_task_version_id         => NULL
     ,p_project_id                     => p_project_id
     ,p_syncup_all_tasks               => 'Y'
     ,p_task_version_id                => NULL
     ,p_structure_version_id           => l_structure_version_id
     ,p_check_for_transactions         => 'N'
     ,p_checked_flag                   => FND_API.G_MISS_CHAR
     ,p_mode                           => 'ALL'
     ,x_return_status                  => l_return_status
     ,x_msg_count                      => l_msg_count
     ,x_msg_data                       => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

-- Begin fix for Bug # 4426392.

-- For a WORKPLAN structure only project that is part of a program, if a FINANCIAL structure is enabled
-- and the structures are SHARED.

if (nvl(l_program, 'N') = 'Y') then

        for l_cur_links_rec in cur_links (p_project_id)
        loop

                -- Delete the 'LW' or 'LF' links that currently exist from the task version.

                pa_relationship_pub.delete_subproject_association
                (p_api_version                   =>     p_api_version
                ,p_init_msg_list                 =>     p_init_msg_list
                ,p_commit                        =>     p_commit
                ,p_validate_only                 =>     p_validate_only
                ,p_validation_level              =>     p_validation_level
                ,p_calling_module                =>     p_calling_module
                ,p_debug_mode                    =>     p_debug_mode
                ,p_max_msg_count                 =>     p_max_msg_count
                ,p_object_relationships_id       =>     l_cur_links_rec.obj_rel_id
                ,p_record_version_number         =>     l_cur_links_rec.rec_ver_number
                ,x_return_status                 =>     x_return_status
                ,x_msg_count                     =>     x_msg_count
                ,x_msg_data                      =>     x_msg_data);

                -- Create both the 'LW' and 'LF' links anew from the task version.

                pa_relationship_pub.create_subproject_association
                (p_api_version                   =>     p_api_version
                ,p_init_msg_list                 =>     p_init_msg_list
                ,p_commit                        =>     p_commit
                ,p_validate_only                 =>     p_validate_only
                ,p_validation_level              =>     p_validation_level
                ,p_calling_module                =>     p_calling_module
                ,p_debug_mode                    =>     p_debug_mode
                ,p_max_msg_count                 =>     p_max_msg_count
                ,p_src_proj_id                   =>     l_cur_links_rec.src_proj_id
                ,p_task_ver_id                   =>     l_cur_links_rec.task_ver_id
                ,p_dest_proj_id                  =>     l_cur_links_rec.dest_proj_id
                ,p_dest_proj_name                =>     l_dest_proj_name
                ,p_comment                       =>     l_comment
                ,x_return_status                 =>     x_return_status
                ,x_msg_count                     =>     x_msg_count
                ,x_msg_data                      =>     x_msg_data);

                -- Set the process update flag for the source structure version to 'Y'.

                update pa_proj_elem_ver_structure ppevs
                set ppevs.process_update_wbs_flag = 'Y'
                where ppevs.element_version_id = l_cur_links_rec.src_str_ver_id
                and ppevs.project_id = l_cur_links_rec.src_proj_id;

        end loop;

end if;

-- End fix for Bug # 4426392.

    -- Amit : Add progress attr fro Financial here
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SPLIT_NO_MAPPING','SPLIT_MAPPING')) THEN
    --split mapping/ no mapping
    --call enable financial structure API
    --create financial structure API
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only => FND_API.G_FALSE
    ,p_project_id    => p_project_id
    ,p_structure_number => l_name
    ,p_structure_name   => l_name
    ,p_calling_flag     => 'FINANCIAL'
    ,x_structure_id     => l_structure_id
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create row in pa_proj_workplan_attr
    PA_PROJECT_STRUCTURE_PUB1.ENABLE_FINANCIAL_STRUCTURE
    (p_validate_only => FND_API.G_FALSE
    ,p_project_id => p_project_id
    ,p_proj_element_id => l_structure_id
    ,x_return_status    => l_return_status
    ,x_msg_count        => l_msg_count
    ,x_msg_data         => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_sharing_option_code = 'SPLIT_MAPPING') THEN
      NULL;
    ELSIF (p_sharing_option_code = 'SPLIT_NO_MAPPING') THEN
      NULL;
    END IF;
  END IF;

ELSIF (l_wp_enabled = 'Y' and l_fin_enabled = 'Y' and l_share_code = 'SHARE_PARTIAL') THEN
  --currently partial share
  IF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'N') THEN
    --disabled both
    --delete all dependencies
    --delete Financial structure API
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver INTO l_structure_version_id, l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;

      PA_PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_Wo_Val(
              p_structure_version_id => l_structure_version_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
      );

      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE sel_all_wp_structure_ver;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SPLIT_NO_MAPPING', 'SPLIT_MAPPING')) OR (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'Y') THEN
    --split mapping/split no mapping/disable workplan
    --delete all tasks not marked as financial
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    --get structure version id
    OPEN sel_latest_pub_ver(l_structure_id);
    FETCH sel_latest_pub_ver into l_structure_version_id;
    IF sel_latest_pub_ver%NOTFOUND THEN
      l_keep_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(l_structure_id);
    ELSE
      l_keep_structure_ver_id := l_structure_version_id;
    END IF;
    CLOSE sel_latest_pub_ver;

/*  Bug 3597178 Commented the call to PA_DELIVERABLE_UTILS.CHECK_PROJ_DLV_TXN_EXISTS
    As we can change from a shared to split,mapped etc even though deliverable transactions exist
    --NYU
    --Check if deliverable transactions exist.  If so, we cannot change the structure sharing to SPLIT
    l_del_trans_exist := PA_DELIVERABLE_UTILS.CHECK_PROJ_DLV_TXN_EXISTS(
        p_project_id => p_project_id,
        x_return_status => l_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);
    IF l_del_trans_exist = 'Y' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    --delete wp budget for the version we keep
    l_struct_version_id_tbl.extend(1); /* Venky */
    l_struct_version_id_tbl(1) := l_keep_structure_ver_id;
    /*Smukka Bug No. 3474141 Date 03/01/2004                                  */
    /*moved PA_FIN_PLAN_PVT.delete_wp_budget_versions into plsql block        */
    BEGIN
         /*Commented call to this API and replaced with pa_fin_plan_pvt.Delete_wp_option
          for Bug 3954050
        PA_FIN_PLAN_PVT.delete_wp_budget_versions(
                     p_struct_elem_version_id_tbl    => l_struct_version_id_tbl
                    ,x_return_status                 => l_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_Msg_data                      => x_msg_data);
       */
        PA_FIN_PLAN_PVT.delete_wp_option
        (
                p_project_id        =>  p_project_id,
                x_return_status     => l_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data
        );
    EXCEPTION
        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                     p_procedure_name => 'update_structures_setup_attr',
                                     p_error_text     => SUBSTRB('PA_FIN_PLAN_PVT.delete_wp_options :'||SQLERRM,1,240));
        RAISE FND_API.G_EXC_ERROR;
    END;
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Delete all other structure versions
    OPEN sel_other_structure_ver(l_keep_structure_ver_id);
    LOOP
      FETCH sel_other_structure_ver into l_del_struc_ver_id,
                                         l_struc_ver_rvn;
      EXIT WHEN sel_other_structure_ver%NOTFOUND;
      PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --get top tasks
      OPEN get_top_tasks(l_del_struc_ver_id);
      LOOP
        FETCH get_top_tasks into l_task_ver_id;
        EXIT WHEN get_top_tasks%NOTFOUND;

        PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

        IF (l_return_status <> 'S') THEN
          x_return_status := l_return_status;
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          l_msg_data := l_err_msg_code;
          CLOSE get_top_tasks;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE get_top_tasks;

      PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
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
        CLOSE sel_other_structure_ver;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE sel_other_structure_ver;

    --delete from pa_proj_progress_attr
    PA_PROGRESS_PUB.DELETE_PROJ_PROG_ATTR(
            p_validate_only        => FND_API.G_FALSE
           ,p_project_id           => p_project_id
           ,P_OBJECT_TYPE          => 'PA_STRUCTURES'
           ,p_object_id            => l_structure_id
       ,p_structure_type       => 'WORKPLAN'
           ,x_return_status        => l_return_status
           ,x_msg_count            => l_msg_count
           ,x_msg_data             => l_msg_data
          );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --delete all tasks not marked as financial in the structure keeping
    --delete schedule versions
    delete from pa_proj_elem_ver_schedule
    where project_id =p_project_id       --Bug No 3634334
      and element_version_id IN (
      select element_version_id
      from pa_proj_element_versions
      where project_id = p_project_id    --Bug No 3634334
      and parent_structure_version_id = l_keep_structure_ver_id
      and object_type IN ('PA_TASKS', 'PA_STRUCTURES'));

    --delete relationships
    --Bug No 3634334 Commented for performance tuning and rewritten the query.
/*    delete from pa_object_relationships rel
    where rel.relationship_type IN ('D','S')
    and EXISTS (
      select 1 from pa_proj_element_versions
      where (rel.object_id_from1 = element_version_id OR
      rel.object_id_to1 = element_version_id ) and
      parent_structure_version_id = l_keep_structure_ver_id and
      financial_task_flag = 'N'); */

    --Bug No 3634334 Created for performance tuning for the above query.

    delete from pa_object_relationships rel
    where OBJECT_RELATIONSHIP_ID IN (
         select OBJECT_RELATIONSHIP_ID
           from pa_object_relationships rel,
                pa_proj_element_versions
          where rel.relationship_type IN ('D','S')
            and object_type_to = 'PA_TASKS'
            and rel.object_id_to1 = element_version_id
            and parent_structure_version_id = l_keep_structure_ver_id
            and financial_task_flag = 'N'
          UNION
         select OBJECT_RELATIONSHIP_ID
           from pa_object_relationships rel,
                pa_proj_element_versions
          where rel.relationship_type IN ('D','S')
            and object_type_from = 'PA_TASKS'
            and rel.object_id_from1 = element_version_id
            and parent_structure_version_id = l_keep_structure_ver_id
            and financial_task_flag = 'N');

/*   Bug 3906015 Just moved the existing code after the delete statements
     to this position
*/
    -- NYU
    -- delete deliverable associations
    PA_DELIVERABLE_PUB.delete_dlv_associations
        (p_project_id=>p_project_id,
        x_return_status=>l_return_status,
        x_msg_count=>l_msg_count,
        x_msg_data=>l_msg_data);

    --delete elements
    delete from pa_proj_elements ppe
    where proj_element_ID in (
      select proj_element_id
      from pa_proj_element_versions
      where parent_structure_version_id = l_keep_structure_ver_id
      and object_type = 'PA_TASKS'
      and financial_task_flag = 'N');

    --delete element versions
    Delete from pa_proj_element_versions
    where parent_structure_version_id = l_keep_structure_ver_id
    and object_type = 'PA_TASKS'
    and financial_task_flag = 'N';

    --delete from pa_proj_structure_types
    DELETe FROM pa_proj_structure_types
    where proj_element_id = l_structure_id
    and structure_type_id = (
      select structure_type_id from pa_structure_types
      where structure_type = 'WORKPLAN');

/*   Bug 3906015
     Moved this code to above (i.e) before deleting the elements (Before deleting task)
     This is necessary because : delete_dlv_associations API has been modified
     in such a way that it retrives the tasks from pa_proj_element_versions table for the passed project_id
     and then for those values ,it performs deliverable related validations for Workplan Task Deletion

     If this call,is after delete statement on pa_proj_element_versions tables,the logic written
     in delete_dlv_associations APi will fail .Hence moved the code up.

    -- NYU
    -- delete deliverable associations
    PA_DELIVERABLE_PUB.delete_dlv_associations
        (p_project_id=>p_project_id,
        x_return_status=>l_return_status,
        x_msg_count=>l_msg_count,
        x_msg_data=>l_msg_data);
*/

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --bug 3894059
    --set versioning disable for financial structure, and structure version as published if it is a project
    update pa_proj_workplan_attr
       set WP_ENABLE_VERSION_FLAG = 'N'
     where proj_element_id = l_structure_id;

    IF (l_template_flag <> 'Y') THEN
      --project
      update pa_proj_elem_ver_structure
         set status_code = 'STRUCTURE_PUBLISHED',
             latest_eff_published_flag = 'Y',
             published_date = sysdate
      where project_id = p_project_id
        and element_version_id = l_keep_structure_ver_id;
    END IF;
    --end bug 3894059

    IF (p_workplan_enabled_flag = 'Y' AND p_sharing_option_code IN ('SPLIT_NO_MAPPING','SPLIT_MAPPING')) THEN
        --Create empty workplan structure
      l_structure_id := NULL;
      PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
      (p_validate_only           => FND_API.G_FALSE
      ,p_project_id              => p_project_id
      ,p_structure_number        => l_wp_name
      ,p_structure_name          => l_wp_name
      ,p_calling_flag            => 'WORKPLAN'
      ,x_structure_id            => l_structure_id
      ,x_return_status           => l_return_status
      ,x_msg_count               => l_msg_count
      ,x_msg_data                => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_structure_version_id := NULL;
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
       (p_validate_only         => FND_API.G_FALSE
       ,p_structure_id          => l_structure_id
       ,x_structure_version_id  => l_structure_version_id
       ,x_return_status         => l_return_status
       ,x_msg_count             => l_msg_count
       ,x_msg_data              => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      PA_TASK_PUB1.Create_Schedule_Version(
       p_element_version_id      => l_structure_version_id
      ,p_scheduled_start_date    => l_proj_start_date
      ,p_scheduled_end_date      => l_proj_completion_date
      ,x_pev_schedule_id         => l_pev_schedule_id
      ,x_return_status           => l_return_status
      ,x_msg_count               => l_msg_count
      ,x_msg_data                => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_template_flag = 'Y') THEN
        l_status_code := 'STRUCTURE_WORKING';
        l_baseline_flag := 'N';
        l_latest_eff_pub_flag := 'N';
        l_effective_date := NULL;
      ELSE
        l_status_code := 'STRUCTURE_PUBLISHED';
        l_baseline_flag := 'Y';
        l_latest_eff_pub_flag := 'Y';
        l_effective_date := sysdate;
      END IF;

      --create structure version
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
      (p_validate_only               => FND_API.G_FALSE
      ,p_structure_version_id        => l_structure_version_id
      ,p_structure_version_name      => l_name
      ,p_structure_version_desc      => NULL
      ,p_effective_date              => l_effective_date
      ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
      ,p_locked_status_code          => 'UNLOCKED'
      ,p_struct_version_status_code  => l_status_code
      ,p_baseline_current_flag       => l_baseline_flag
      ,p_baseline_original_flag      => 'N'
      ,x_pev_structure_id            => l_pev_structure_id
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      NULL;
    ELSIF (p_workplan_enabled_flag = 'N' ) THEN
      NULL;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disable financial (enable workplan)
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    update pa_proj_elements
    set name = l_wp_name,
        element_number = l_wp_name
    where proj_element_id = l_structure_id;

    --Need delete financial tasks API
    PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE(
     p_validate_only     => FND_API.G_FALSE
    ,p_project_id        => p_project_id
    ,x_return_status     => l_return_status
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --clear financial Flag API
    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver INTO l_structure_version_id, l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;

      PA_PROJECT_STRUCTURE_PUB1.CLEAR_FINANCIAL_FLAG(
       p_validate_only => FND_API.G_FALSE
      ,p_project_id    => p_project_id
      ,p_task_version_id => NULL
      ,p_structure_version_id => l_structure_version_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE sel_all_wp_structure_ver;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SHARE_PARTIAL') THEN
    --partial share; no action required
    NULL;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SHARE_FULL') THEN
    --full share
    --Need to call sync up API
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    --get structure version id
    OPEN sel_latest_pub_ver(l_structure_id);
    FETCH sel_latest_pub_ver into l_structure_version_id;
    IF sel_latest_pub_ver%NOTFOUND THEN
      l_structure_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(l_structure_id);
    ELSE
      l_keep_structure_ver_id := l_structure_version_id;
    END IF;
    CLOSE sel_latest_pub_ver;

    update pa_proj_element_versions
       set financial_task_flag = 'Y'
     where parent_structure_version_id = l_structure_version_id
       and object_type = 'PA_TASKS'
       and proj_element_id NOT IN
           (select proj_element_id
              from pa_proj_elements
             where project_id = p_project_id
               and object_type = 'PA_TASKS'
               and link_task_flag = 'Y');

    --need to call sync up API
    PA_TASKS_MAINT_PUB.SYNC_UP_WP_TASKS_WITH_FIN
     (p_patask_record_version_number   => NULL
     ,p_parent_task_version_id         => NULL
     ,p_project_id                     => p_project_id
     ,p_syncup_all_tasks               => 'Y'
     ,p_task_version_id                => NULL
     ,p_structure_version_id           => l_structure_version_id
     ,p_check_for_transactions         => 'N'
     ,p_checked_flag                   => FND_API.G_MISS_CHAR
     ,p_mode                           => 'ALL'
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

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

ELSIF (l_wp_enabled = 'Y' and l_fin_enabled = 'Y' and l_share_code = 'SHARE_FULL') THEN
  --currently full share
  IF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'N') THEN
    --disabled both
    --delete all dependencies
    --delete Financial structure API
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver INTO l_structure_version_id, l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;

      PA_PROJECT_STRUCTURE_PVT1.Delete_Struc_Ver_Wo_Val(
              p_structure_version_id => l_structure_version_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
      );

      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE sel_all_wp_structure_ver;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SPLIT_MAPPING', 'SPLIT_NO_MAPPING')) OR (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'Y') THEN
    --split mapping/split no mapping/disable workplan
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    --get structure version id
    OPEN sel_latest_pub_ver(l_structure_id);
    FETCH sel_latest_pub_ver into l_structure_version_id;
    IF sel_latest_pub_ver%NOTFOUND THEN
      l_keep_structure_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER(l_structure_id);
    ELSE
      l_keep_structure_ver_id := l_structure_version_id;
    END IF;
    CLOSE sel_latest_pub_ver;

    -- Bug 3938654 : Additional Fix that will go as a part of this bug
    --               This fix is not related to main issue reported in the bug

    -- Actually this call should not be present .This fix should have been
    -- done long back as a part of 3597178
    -- For the case l_wp_enabled_flag=Y,l_fin_enabled_flag=Y,l_share_code=SHARE_PARTIAL ,this fix
    -- has already been done .For this case (l_wp_enabled = 'Y' and l_fin_enabled = 'Y' and l_share_code = 'SHARE_FULL')
    -- It had been missed.

   /*  Hence doing the commenting
    --NYU
    --Check if deliverable transactions exist.  If so, we cannot change the structure sharing to SPLIT
    l_del_trans_exist := PA_DELIVERABLE_UTILS.CHECK_PROJ_DLV_TXN_EXISTS(
        p_project_id => p_project_id,
        x_return_status => l_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);
    IF l_del_trans_exist = 'Y' THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
   */

    --delete wp budget for the version we keep
    l_struct_version_id_tbl.extend(1); /* Venky */
    l_struct_version_id_tbl(1) := l_keep_structure_ver_id;
    /*Smukka Bug No. 3474141 Date 03/01/2004                                  */
    /*moved PA_FIN_PLAN_PVT.delete_wp_budget_versions into plsql block        */
    BEGIN
        /*Commented call to this API and replaced with pa_fin_plan_pvt.Delete_wp_option
          for Bug 3954050
        PA_FIN_PLAN_PVT.delete_wp_budget_versions(
                     p_struct_elem_version_id_tbl    => l_struct_version_id_tbl
                    ,x_return_status                 => l_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_Msg_data                      => x_msg_data);
        */
        PA_FIN_PLAN_PVT.delete_wp_option
        (
                p_project_id        =>  p_project_id,
                x_return_status     => l_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data
        );
    EXCEPTION
        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                     p_procedure_name => 'update_structures_setup_attr',
                                     p_error_text     => SUBSTRB('PA_FIN_PLAN_PVT.delete_wp_option:'||SQLERRM,1,240));
        RAISE FND_API.G_EXC_ERROR;
    END;
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Delete all other structure versions
    OPEN sel_other_structure_ver(l_keep_structure_ver_id);
    LOOP
      FETCH sel_other_structure_ver into l_del_struc_ver_id,
                                         l_struc_ver_rvn;
      EXIT WHEN sel_other_structure_ver%NOTFOUND;
      PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --get top tasks
      OPEN get_top_tasks(l_del_struc_ver_id);
      LOOP
        FETCH get_top_tasks into l_task_ver_id;
        EXIT WHEN get_top_tasks%NOTFOUND;

        PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

        IF (l_return_status <> 'S') THEN
          x_return_status := l_return_status;
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          l_msg_data := l_err_msg_code;
          CLOSE get_top_tasks;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE get_top_tasks;

      PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
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
        CLOSE sel_other_structure_ver;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE sel_other_structure_ver;

    --delete from pa_proj_progress_attr
    PA_PROGRESS_PUB.DELETE_PROJ_PROG_ATTR(
            p_validate_only        => FND_API.G_FALSE
           ,p_project_id           => p_project_id
           ,P_OBJECT_TYPE          => 'PA_STRUCTURES'
           ,p_object_id            => l_structure_id
       ,p_structure_type       => 'WORKPLAN' --Amit
           ,x_return_status        => l_return_status
           ,x_msg_count            => l_msg_count
           ,x_msg_data             => l_msg_data
          );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --delete all tasks not marked as financial in the structure keeping
    --delete schedule versions
    delete from pa_proj_elem_ver_schedule
    where project_id =p_project_id                                     --Bug No 3634334
      and element_version_id IN (
      select element_version_id
      from pa_proj_element_versions
      where project_id =p_project_id                                   --Bug No 3634334
      and parent_structure_version_id = l_keep_structure_ver_id
      and object_type IN ('PA_TASKS', 'PA_STRUCTURES'));

    --delete from pa_proj_structure_types
    DELETe FROM pa_proj_structure_types
    where proj_element_id = l_structure_id
    and structure_type_id = (
      select structure_type_id from pa_structure_types
      where structure_type = 'WORKPLAN');

    -- NYU
    -- delete deliverable associations
    PA_DELIVERABLE_PUB.delete_dlv_associations
        (p_project_id=>p_project_id,
        x_return_status=>l_return_status,
        x_msg_count=>l_msg_count,
        x_msg_data=>l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --bug 3894059
    --set versioning disable for financial structure, and structure version as published if it is a project
    update pa_proj_workplan_attr
       set WP_ENABLE_VERSION_FLAG = 'N'
     where proj_element_id = l_structure_id;

    IF (l_template_flag <> 'Y') THEN
      --project
      update pa_proj_elem_ver_structure
         set status_code = 'STRUCTURE_PUBLISHED',
             latest_eff_published_flag = 'Y',
             published_date = sysdate
      where project_id = p_project_id
        and element_version_id = l_keep_structure_ver_id;
    END IF;
    --end bug 3894059

    IF (p_workplan_enabled_flag = 'Y' AND p_sharing_option_code IN ('SPLIT_NO_MAPPING','SPLIT_MAPPING')) THEN
        --Create empty workplan structure
      PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
      (p_validate_only           => FND_API.G_FALSE
      ,p_project_id              => p_project_id
      ,p_structure_number        => l_wp_name
      ,p_structure_name          => l_wp_name
      ,p_calling_flag            => 'WORKPLAN'
      ,x_structure_id            => l_structure_id
      ,x_return_status           => l_return_status
      ,x_msg_count               => l_msg_count
      ,x_msg_data                => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
       (p_validate_only         => FND_API.G_FALSE
       ,p_structure_id          => l_structure_id
       ,x_structure_version_id  => l_structure_version_id
       ,x_return_status         => l_return_status
       ,x_msg_count             => l_msg_count
       ,x_msg_data              => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      PA_TASK_PUB1.Create_Schedule_Version(
       p_element_version_id      => l_structure_version_id
      ,p_scheduled_start_date    => l_proj_start_date
      ,p_scheduled_end_date      => l_proj_completion_date
      ,x_pev_schedule_id         => l_pev_schedule_id
      ,x_return_status           => l_return_status
      ,x_msg_count               => l_msg_count
      ,x_msg_data                => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_template_flag = 'Y') THEN
        l_status_code := 'STRUCTURE_WORKING';
        l_baseline_flag := 'N';
        l_latest_eff_pub_flag := 'N';
        l_effective_date := NULL;
      ELSE
        l_status_code := 'STRUCTURE_PUBLISHED';
        l_baseline_flag := 'Y';
        l_latest_eff_pub_flag := 'Y';
        l_effective_date := sysdate;
      END IF;

      --create structure version
      PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
      (p_validate_only               => FND_API.G_FALSE
      ,p_structure_version_id        => l_structure_version_id
      ,p_structure_version_name      => l_name
      ,p_structure_version_desc      => NULL
      ,p_effective_date              => l_effective_date
      ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
      ,p_locked_status_code          => 'UNLOCKED'
      ,p_struct_version_status_code  => l_status_code
      ,p_baseline_current_flag       => l_baseline_flag
      ,p_baseline_original_flag      => 'N'
      ,x_pev_structure_id            => l_pev_structure_id
      ,x_return_status               => l_return_status
      ,x_msg_count                   => l_msg_count
      ,x_msg_data                    => l_msg_data );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      NULL;
    ELSIF (p_workplan_enabled_flag = 'N' ) THEN
      NULL;
    END IF;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disable financial (enable workplan)
    --call disable financial structure API
    --get structure id
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    update pa_proj_elements
    set name = l_wp_name,
        element_number = l_wp_name
    where proj_element_id = l_structure_id;

    --Need delete financial tasks API
    PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE(
     p_validate_only     => FND_API.G_FALSE
    ,p_project_id        => p_project_id
    ,x_return_status     => l_return_status
    ,x_msg_count         => l_msg_count
    ,x_msg_data          => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --clear financial Flag API
    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver INTO l_structure_version_id, l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;

      PA_PROJECT_STRUCTURE_PUB1.CLEAR_FINANCIAL_FLAG(
       p_validate_only => FND_API.G_FALSE
      ,p_project_id    => p_project_id
      ,p_task_version_id => NULL
      ,p_structure_version_id => l_structure_version_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE sel_all_wp_structure_ver;

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SHARE_PARTIAL') THEN
    --partial share; no action required
    NULL;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SHARE_FULL') THEN
    --full share; no action required
    NULL;
  END IF;

ELSIF (l_wp_enabled = 'Y' and l_fin_enabled = 'Y' and l_share_code = 'SPLIT_MAPPING') THEN
  --currently split with mapping
  IF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'N') OR
     (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'Y') OR
     (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disabled both/workplan/financial
    --remove mapping APIs
    PA_PROJ_STRUC_MAPPING_PUB.DELETE_ALL_MAPPING(
       p_project_id        => p_project_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_workplan_enabled_flag = 'N') THEN
      --disable workplan
      --get structure_id
      OPEN sel_wp_structure_id;
      FETCH sel_wp_structure_id INTO l_structure_id;
      CLOSE sel_wp_structure_id;

      --delete workplan structure
      OPEN sel_all_wp_structure_ver(l_structure_id);
      LOOP
        FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                          l_struc_ver_rvn;
        EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
        PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
        IF (l_return_status <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --get top tasks
        OPEN get_top_tasks(l_del_struc_ver_id);
        LOOP
          FETCH get_top_tasks into l_task_ver_id;
          EXIT WHEN get_top_tasks%NOTFOUND;

          PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

          IF (l_return_status <> 'S') THEN
            x_return_status := l_return_status;
            PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
            l_msg_data := l_err_msg_code;
            CLOSE get_top_tasks;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
        CLOSE get_top_tasks;

        PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
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
          CLOSE sel_all_wp_structure_ver;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE sel_all_wp_structure_ver;
    END IF;

    IF (p_financial_enabled_flag = 'N') THEN
      --disable financial structure API
      PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE(
       p_validate_only     => FND_API.G_FALSE
      ,p_project_id        => p_project_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

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

  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SHARE_FULL','SHARE_PARTIAL')) THEN
    --partial share/full share
    --remove mapping APIs
    PA_PROJ_STRUC_MAPPING_PUB.DELETE_ALL_MAPPING(
       p_project_id        => p_project_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

    --loop and delete all workplan versions
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                          l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
      PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --get top tasks
      OPEN get_top_tasks(l_del_struc_ver_id);
      LOOP
        FETCH get_top_tasks into l_task_ver_id;
        EXIT WHEN get_top_tasks%NOTFOUND;

        PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );


        IF (l_return_status <> 'S') THEN
          x_return_status := l_return_status;
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          l_msg_data := l_err_msg_code;
          CLOSE get_top_tasks;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE get_top_tasks;

      PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
      );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        CLOSE sel_all_wp_structure_ver;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE sel_all_wp_structure_ver;

    --Add structure type to financial
    OPEN sel_fin_structure_id;
    FETCH sel_fin_structure_id into l_structure_id;
    CLOSE sel_fin_structure_id;

    OPEN sel_struc_type_id;
    FETCH sel_struc_type_id INTO l_struc_type_id;
    CLOSE sel_struc_type_id;

    PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
              X_ROWID                  => l_rowid
             ,X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
             ,X_PROJ_ELEMENT_ID        => l_structure_id
             ,X_STRUCTURE_TYPE_ID      => l_struc_type_id
             ,X_RECORD_VERSION_NUMBER  => 1
             ,X_ATTRIBUTE_CATEGORY     => NULL
             ,X_ATTRIBUTE1             => NULL
             ,X_ATTRIBUTE2             => NULL
             ,X_ATTRIBUTE3             => NULL
             ,X_ATTRIBUTE4             => NULL
             ,X_ATTRIBUTE5             => NULL
             ,X_ATTRIBUTE6             => NULL
             ,X_ATTRIBUTE7             => NULL
             ,X_ATTRIBUTE8             => NULL
             ,X_ATTRIBUTE9             => NULL
             ,X_ATTRIBUTE10            => NULL
             ,X_ATTRIBUTE11            => NULL
             ,X_ATTRIBUTE12            => NULL
             ,X_ATTRIBUTE13            => NULL
             ,X_ATTRIBUTE14            => NULL
             ,X_ATTRIBUTE15            => NULL);

    l_proj_prog_attr_id := NULL;
    PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
     p_validate_only       => FND_API.G_FALSE
    ,p_project_id          => p_project_id
    ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
    ,P_OBJECT_ID           => l_structure_id
    ,p_action_set_id       => NULL
    ,p_structure_type      => 'WORKPLAN' --Amit
    ,x_proj_progress_attr_id => l_proj_prog_attr_id
    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data);

    --get structure version id
    OPEN sel_struc_ver(l_structure_id);
    FETCH sel_struc_ver into l_structure_version_id;
    CLOSE sel_struc_ver;

    --add planning transaction to the shared structure version
    --add financial planning
    /*Smukka Bug No. 3474141 Date 03/01/2004                                                 */
    /*moved PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions into plsql block        */
    BEGIN
        PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions(
                      p_context                => 'WORKPLAN'
                     ,p_project_id             => p_project_id
                     ,p_struct_elem_version_id => l_structure_version_id
                     ,x_return_status          => l_return_status
                     ,x_msg_count              => x_msg_count
                     ,x_Msg_data               => x_msg_data);
    EXCEPTION
        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                     p_procedure_name => 'update_structures_setup_attr',
                                     p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions:'||SQLERRM,1,240));
        RAISE FND_API.G_EXC_ERROR;
    END;
    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create schedule row for each task
    INSERT INTO PA_PROJ_ELEM_VER_SCHEDULE(
          pev_schedule_id,
          element_version_id,
          project_id,
          proj_element_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          scheduled_start_date,
          scheduled_finish_date,
          milestone_flag,
          critical_flag,
          calendar_id,
          record_version_number,
          last_update_login,
      source_object_id,
      source_object_type)
    SELECT
          pa_proj_elem_ver_schedule_s.nextval,
          PPEV.element_version_id,
          PPEV.project_id,
          PPEV.proj_element_id,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.START_DATE), trunc(l_proj_start_date))),
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.COMPLETION_DATE), trunc(l_proj_completion_date))),
          'N',
          'N',
          NULL,
          0,
          FND_GLOBAL.LOGIN_ID,
      PPEV.project_id,
      'PA_PROJECTS'
    FROM PA_TASKS PT,
         PA_PROJ_ELEMENT_VERSIONS PPEV
    WHERE
         PPEV.parent_structure_version_id = l_structure_version_id
    AND  PPEV.proj_element_id = PT.task_id (+);

    OPEN sel_struc_and_task_vers(l_structure_version_id);
    LOOP
      FETCH sel_struc_and_task_vers into l_object_type, l_task_id, l_element_version_id;
      EXIT WHEN sel_struc_and_task_vers%NOTFOUND;
      /* Bug 2790703 Begin */
      --Add to array for rollup
      l_index := l_index + 1;
      l_task_ver_ids_tbl(l_index) := l_element_version_id;
      /* Bug 2790703 End */
      END LOOP;
    CLOSE sel_struc_and_task_vers;

    IF (l_task_ver_ids_tbl.count > 0) THEN
      --rollup
      PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
       p_commit => FND_API.G_FALSE,
       p_element_versions => l_task_ver_ids_tbl,
       x_return_status => l_return_status,
       x_msg_count => l_msg_count,
       x_msg_data => l_msg_data);

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

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Bug # 5077599.

    -- If the project is version disabled, then baseline the structure version.

    if (PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(p_project_id) = 'N') then

        update pa_proj_elem_ver_structure ppevs
        set ppevs.current_flag = 'Y'
            , ppevs.original_flag = 'Y'
            , ppevs.record_version_number = (ppevs.record_version_number+1)
        where ppevs.project_id = p_project_id
        and ppevs.element_version_id = l_structure_version_id;

        PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION
        (p_commit                 => p_commit
        ,p_validate_only          => p_validate_only
        ,p_validation_level       => p_validation_level
        ,p_calling_module         => p_calling_module
        ,p_debug_mode             => p_debug_mode
        ,p_max_msg_count          => p_max_msg_count
        ,p_structure_version_id   => l_structure_version_id
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data);

    end if;

    -- Bug # 5077599.


    IF (p_sharing_option_code = 'SHARE_FULL') THEN
      NULL;
    ELSIF (p_sharing_option_code = 'SHARE_PARTIAL') THEN
      NULL;
    END IF;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SPLIT_MAPPING') THEN
    --split mapping; no action required
    NULL;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SPLIT_NO_MAPPING') THEN
    --split no mapping
    --remove mapping APIs
    PA_PROJ_STRUC_MAPPING_PUB.DELETE_ALL_MAPPING(
       p_project_id        => p_project_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

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

ELSIF (l_wp_enabled = 'Y' and l_fin_enabled = 'Y' and l_share_code = 'SPLIT_NO_MAPPING') THEN
  --currently split no mapping
  IF (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'N') OR
     (p_workplan_enabled_flag = 'N' and p_financial_enabled_flag = 'Y') OR
     (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'N') THEN
    --disabled both/delete workplan structure/disable financial structure API

    IF (p_workplan_enabled_flag = 'N') THEN
      --delete workplan structure
      --get structure_id
      OPEN sel_wp_structure_id;
      FETCH sel_wp_structure_id INTO l_structure_id;
      CLOSE sel_wp_structure_id;

      --delete workplan structure
      OPEN sel_all_wp_structure_ver(l_structure_id);
      LOOP
        FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                          l_struc_ver_rvn;
        EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
        PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
        IF (l_return_status <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          x_msg_data := l_err_msg_code;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        --get top tasks
        OPEN get_top_tasks(l_del_struc_ver_id);
        LOOP
          FETCH get_top_tasks into l_task_ver_id;
          EXIT WHEN get_top_tasks%NOTFOUND;

          PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );

          IF (l_return_status <> 'S') THEN
            x_return_status := l_return_status;
            PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
            l_msg_data := l_err_msg_code;
            CLOSE get_top_tasks;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
        CLOSE get_top_tasks;

        PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
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
          CLOSE sel_all_wp_structure_ver;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE sel_all_wp_structure_ver;
    END IF;

    IF (p_financial_enabled_flag = 'N') THEN
      --disable financial structure API
      PA_PROJECT_STRUCTURE_PUB1.DISABLE_FINANCIAL_STRUCTURE(
       p_validate_only     => FND_API.G_FALSE
      ,p_project_id        => p_project_id
      ,x_return_status     => l_return_status
      ,x_msg_count         => l_msg_count
      ,x_msg_data          => l_msg_data);

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
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code IN ('SHARE_FULL','SHARE_PARTIAL')) THEN
    --partial share/full share
    --remove financial structure row in pa_proj_workplan_attr
    --delete all workplan dependencies
    --delete workplan structure
    --add schedule rows for financial structure and tasks
    --add workplan structure type

    --loop and delete all workplan versions
    OPEN sel_wp_structure_id;
    FETCH sel_wp_structure_id INTO l_structure_id;
    CLOSE sel_wp_structure_id;

    OPEN sel_all_wp_structure_ver(l_structure_id);
    LOOP
      FETCH sel_all_wp_structure_ver into l_del_struc_ver_id,
                                          l_struc_ver_rvn;
      EXIT WHEN sel_all_wp_structure_ver%NOTFOUND;
      PA_PROJECT_STRUCTURE_UTILS.Check_Delete_Structure_Ver_Ok(
                       p_project_id,
                       l_del_struc_ver_id,
                       l_return_status,
                       l_err_msg_code);
      IF (l_return_status <> 'S') THEN
        PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
        x_msg_data := l_err_msg_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --get top tasks
      OPEN get_top_tasks(l_del_struc_ver_id);
      LOOP
        FETCH get_top_tasks into l_task_ver_id;
        EXIT WHEN get_top_tasks%NOTFOUND;

        PA_PROJ_ELEMENTS_UTILS.check_del_all_task_ver_ok(
               p_project_id                   => p_project_id
              ,p_task_version_id              => l_task_ver_id
              ,p_parent_structure_ver_id      => l_del_struc_ver_id
              ,x_return_status                => l_return_status
              ,x_error_message_code           => l_err_msg_code );


        IF (l_return_status <> 'S') THEN
          x_return_status := l_return_status;
          PA_UTILS.ADD_MESSAGE('PA', l_err_msg_code);
          l_msg_data := l_err_msg_code;
          CLOSE get_top_tasks;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE get_top_tasks;

      PA_PROJECT_STRUCTURE_PVT1.DELETE_STRUC_VER_WO_VAL(
              p_structure_version_id => l_del_struc_ver_id
             ,p_record_version_number => l_struc_ver_rvn
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
      );

      --Check if there is any error.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF l_msg_count > 0 THEN
        x_msg_count := l_msg_count;
        IF x_msg_count = 1 THEN
          x_msg_data := l_msg_data;
        END IF;
        CLOSE sel_all_wp_structure_ver;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE sel_all_wp_structure_ver;

    --Add structure type to financial
    OPEN sel_fin_structure_id;
    FETCH sel_fin_structure_id into l_structure_id;
    CLOSE sel_fin_structure_id;

    OPEN sel_struc_type_id;
    FETCH sel_struc_type_id INTO l_struc_type_id;
    CLOSE sel_struc_type_id;

    PA_PROJ_STRUCTURE_TYPES_PKG.insert_row(
              X_ROWID                  => l_rowid
             ,X_PROJ_STRUCTURE_TYPE_ID => l_proj_structure_type_id
             ,X_PROJ_ELEMENT_ID        => l_structure_id
             ,X_STRUCTURE_TYPE_ID      => l_struc_type_id
             ,X_RECORD_VERSION_NUMBER  => 1
             ,X_ATTRIBUTE_CATEGORY     => NULL
             ,X_ATTRIBUTE1             => NULL
             ,X_ATTRIBUTE2             => NULL
             ,X_ATTRIBUTE3             => NULL
             ,X_ATTRIBUTE4             => NULL
             ,X_ATTRIBUTE5             => NULL
             ,X_ATTRIBUTE6             => NULL
             ,X_ATTRIBUTE7             => NULL
             ,X_ATTRIBUTE8             => NULL
             ,X_ATTRIBUTE9             => NULL
             ,X_ATTRIBUTE10            => NULL
             ,X_ATTRIBUTE11            => NULL
             ,X_ATTRIBUTE12            => NULL
             ,X_ATTRIBUTE13            => NULL
             ,X_ATTRIBUTE14            => NULL
             ,X_ATTRIBUTE15            => NULL);

    l_proj_prog_attr_id := NULL;
    PA_PROGRESS_PUB.CREATE_PROJ_PROG_ATTR(
     p_validate_only       => FND_API.G_FALSE
    ,p_project_id          => p_project_id
    ,P_OBJECT_TYPE         => 'PA_STRUCTURES'
    ,P_OBJECT_ID           => l_structure_id
    ,p_action_set_id       => NULL
    ,p_structure_type      => 'WORKPLAN' --Amit
    ,x_proj_progress_attr_id => l_proj_prog_attr_id
    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data);

    --get structure version id
    OPEN sel_struc_ver(l_structure_id);
    FETCH sel_struc_ver into l_structure_version_id;
    CLOSE sel_struc_ver;

    --add financial planning
    /*Smukka Bug No. 3474141 Date 03/01/2004                                                 */
    /*moved PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions into plsql block        */
    BEGIN
        PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions(
                      p_context                => 'WORKPLAN'
                     ,p_project_id             => p_project_id
                     ,p_struct_elem_version_id => l_structure_version_id
                     ,x_return_status          => l_return_status
                     ,x_msg_count              => x_msg_count
                     ,x_Msg_data               => x_msg_data);
    EXCEPTION
        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                                     p_procedure_name => 'update_structures_setup_attr',
                                     p_error_text     => SUBSTRB('PA_FP_PLANNING_TRANSACTION_PUB.add_planning_transactions:'||SQLERRM,1,240));
        RAISE FND_API.G_EXC_ERROR;
    END;
    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --create schedule row for each task
    INSERT INTO PA_PROJ_ELEM_VER_SCHEDULE(
          pev_schedule_id,
          element_version_id,
          project_id,
          proj_element_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          scheduled_start_date,
          scheduled_finish_date,
          milestone_flag,
          critical_flag,
          calendar_id,
          record_version_number,
          last_update_login,
      source_object_id,
      source_object_type
)
    SELECT
          pa_proj_elem_ver_schedule_s.nextval,
          PPEV.element_version_id,
          PPEV.project_id,
          PPEV.proj_element_id,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.START_DATE), trunc(l_proj_start_date))),
          DECODE(PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(PPEV.element_version_id), 'N', trunc(SYSDATE), 'Y', NVL(trunc(PT.COMPLETION_DATE), trunc(l_proj_completion_date))),
          'N',
          'N',
          NULL,
          0,
          FND_GLOBAL.LOGIN_ID,
      PPEV.project_id,
      'PA_PROJECTS'
    FROM PA_TASKS PT,
         PA_PROJ_ELEMENT_VERSIONS PPEV
    WHERE
         PPEV.parent_structure_version_id = l_structure_version_id
    AND  PPEV.proj_element_id = PT.task_id (+);

    OPEN sel_struc_and_task_vers(l_structure_version_id);
    LOOP
      FETCH sel_struc_and_task_vers into l_object_type, l_task_id, l_element_version_id;
      EXIT WHEN sel_struc_and_task_vers%NOTFOUND;
      /* Bug 2790703 Begin */
      --Add to array for rollup
      l_index := l_index + 1;
      l_task_ver_ids_tbl(l_index) := l_element_version_id;
      /* Bug 2790703 End */
      END LOOP;
    CLOSE sel_struc_and_task_vers;

    IF (l_task_ver_ids_tbl.count > 0) THEN
      --rollup
      PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited(
       p_commit => FND_API.G_FALSE,
       p_element_versions => l_task_ver_ids_tbl,
       x_return_status => l_return_status,
       x_msg_count => l_msg_count,
       x_msg_data => l_msg_data);

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

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug # 5077599.

    -- If the project is version disabled, then baseline the structure version.

    if (PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(p_project_id) = 'N') then

        update pa_proj_elem_ver_structure ppevs
        set ppevs.current_flag = 'Y'
            , ppevs.original_flag = 'Y'
            , ppevs.record_version_number = (ppevs.record_version_number+1)
        where ppevs.project_id = p_project_id
        and ppevs.element_version_id = l_structure_version_id;

        PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION
        (p_commit                 => p_commit
        ,p_validate_only          => p_validate_only
        ,p_validation_level       => p_validation_level
        ,p_calling_module         => p_calling_module
        ,p_debug_mode             => p_debug_mode
        ,p_max_msg_count          => p_max_msg_count
        ,p_structure_version_id   => l_structure_version_id
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data);

    end if;

    -- Bug # 5077599.


  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SPLIT_MAPPING') THEN
    --split mapping; no action required
    NULL;
  ELSIF (p_workplan_enabled_flag = 'Y' and p_financial_enabled_flag = 'Y' and p_sharing_option_code = 'SPLIT_NO_MAPPING') THEN
    --split no mapping; no action required
    NULL;
  END IF;

END IF;

IF (p_workplan_enabled_flag = 'N' or p_financial_enabled_flag = 'N') THEN
  --clear sharing option
  l_new_share_code := NULL;
ELSE
  l_new_share_code := p_sharing_option_code;
END IF;

update pa_projects_all
set structure_sharing_code = l_new_share_code
where project_id = p_project_id;

IF l_delv_enabled = 'Y' THEN
  --currently enabled
  IF (p_deliverables_enabled_flag = 'N') THEN
    PA_DELIVERABLE_PUB.DELETE_DELIVERABLE_STRUCTURE
    (p_project_id => p_project_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

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
ELSE  --l_delv_enabled = 'N'
  --currently disabled
  IF (p_deliverables_enabled_flag = 'Y') THEN
    --enable deliverable
    --get suffix
    select meaning
    into l_suffix
    from pa_lookups
    where lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
    and lookup_code = 'DELIVERABLE';
    --get deliverable name
    l_del_name := substrb(l_name||l_append||l_suffix, 1, 240);

    --create workplan structure
    PA_PROJECT_STRUCTURE_PUB1.CREATE_STRUCTURE
    (p_validate_only           => FND_API.G_FALSE
    ,p_project_id              => p_project_id
    ,p_structure_number        => l_del_name
    ,p_structure_name          => l_del_name
    ,p_calling_flag            => 'DELIVERABLE'
    ,x_structure_id            => l_structure_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version
    (p_validate_only         => FND_API.G_FALSE
    ,p_structure_id          => l_structure_id
    ,x_structure_version_id  => l_structure_version_id
    ,x_return_status         => l_return_status
    ,x_msg_count             => l_msg_count
    ,x_msg_data              => l_msg_data );

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    PA_TASK_PUB1.Create_Schedule_Version(
     p_element_version_id      => l_structure_version_id
    ,p_scheduled_start_date    => l_proj_start_date
    ,p_scheduled_end_date      => l_proj_completion_date
    ,x_pev_schedule_id         => l_pev_schedule_id
    ,x_return_status           => l_return_status
    ,x_msg_count               => l_msg_count
    ,x_msg_data                => l_msg_data);

    --Check if there is any error.
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
      x_msg_count := l_msg_count;
      IF x_msg_count = 1 THEN
        x_msg_data := l_msg_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_template_flag = 'Y') THEN
      l_status_code := 'STRUCTURE_WORKING';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'N';
      l_effective_date := NULL;
    ELSE
      l_status_code := 'STRUCTURE_PUBLISHED';
      l_baseline_flag := 'N';
      l_latest_eff_pub_flag := 'Y';
      l_effective_date := sysdate;
    END IF;

    --create structure version
    PA_PROJECT_STRUCTURE_PVT1.Create_Structure_Version_Attr
    (p_validate_only               => FND_API.G_FALSE
    ,p_structure_version_id        => l_structure_version_id
    ,p_structure_version_name      => l_del_name
    ,p_structure_version_desc      => NULL
    ,p_effective_date              => l_effective_date
    ,p_latest_eff_published_flag   => l_latest_eff_pub_flag
    ,p_locked_status_code          => 'UNLOCKED'
    ,p_struct_version_status_code  => l_status_code
    ,p_baseline_current_flag       => l_baseline_flag
    ,p_baseline_original_flag      => 'N'
    ,x_pev_structure_id            => l_pev_structure_id
    ,x_return_status               => l_return_status
    ,x_msg_count                   => l_msg_count
    ,x_msg_data                    => l_msg_data );

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
END IF;

 -- FP.M changes below
    If p_sys_program_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
         l_sys_program_flag := null;
    else
         l_sys_program_flag := p_sys_program_flag;
    end if;

    If p_allow_multi_prog_rollup = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
         l_allow_multi_program_rollup :=null;
    else
         l_allow_multi_program_rollup :=p_allow_multi_prog_rollup;
    end if;

--bug 4275096
    IF l_sys_program_flag = 'N' AND l_allow_multi_program_rollup = 'Y'
    THEN
          Pa_Utils.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name     =>'PA_PS_EN_SYS_PROG_ERR');
           RAISE FND_API.G_EXC_ERROR;
    END IF;
--end bug 4275096

    IF (l_proj_sys_program_flag='Y' and nvl(l_sys_program_flag,'N')='N' ) then
        l_flag := PA_RELATIONSHIP_UTILS.DISABLE_SYS_PROG_OK(p_project_id);
         If l_flag='N' Then
          Pa_Utils.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name     =>'PA_PS_DIS_SYS_PROG_ERR');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    IF (l_proj_allow_program_rollup='Y' and nvl(l_allow_multi_program_rollup,'N')='N' ) then
        l_flag := PA_RELATIONSHIP_UTILS.DISABLE_MULTI_PROG_OK(p_project_id);
          IF l_flag ='N' Then
           Pa_Utils.ADD_MESSAGE
                ( p_app_short_name => 'PA',
                  p_msg_name     =>'PA_PS_DIS_MULTI_PROG_ERR');
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

--    IF NOT FND_API.TO_BOOLEAN(p_validate_only) THEN
      UPDATE pa_projects_all
      SET
          sys_program_flag      = nvl(l_sys_program_flag,'N'),
          allow_multi_program_rollup = nvl(l_allow_multi_program_rollup,'N')
      WHERE project_id = p_project_id;
--    END IF;
  -- end of FP.M changes

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_PROJECT_STRUCTURE_PVT1.update_structures_setup_attr end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_struc_setup_attr_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_struc_setup_attr_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_STRUCTURE_PVT1',
                              p_procedure_name => 'update_structures_setup_attr',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END update_structures_setup_attr;

end PA_PROJECT_STRUCTURE_PVT1;

/
