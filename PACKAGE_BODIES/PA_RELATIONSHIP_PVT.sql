--------------------------------------------------------
--  DDL for Package Body PA_RELATIONSHIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RELATIONSHIP_PVT" as
/*$Header: PAXRELVB.pls 120.12.12010000.7 2010/05/20 07:22:00 vgovvala ship $*/

-- API name                      : Create_Relationship
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
--   p_project_id_from                   IN  NUMBER
--   p_structure_id_from                 IN  NUMBER
--   p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id_to                     IN  NUMBER
--   p_structure_id_to                   IN  NUMBER
--   p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_type                    IN  VARCHAR2
--   p_initiating_element                IN  VARCHAR2
--   p_link_to_latest_structure_ver      IN  VARCHAR2    := 'N'
--   p_relationship_type                 IN  VARCHAR2
--   p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_object_relationship_id            OUT  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Create_Relationship
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_from                   IN  NUMBER
   ,p_structure_id_from                 IN  NUMBER
   ,p_structure_version_id_from         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_to                     IN  NUMBER
   ,p_structure_id_to                   IN  NUMBER
   ,p_structure_version_id_to           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_type                    IN  VARCHAR2
   ,p_initiating_element                IN  VARCHAR2
   ,p_link_to_latest_structure_ver      IN  VARCHAR2    := 'N'
   ,p_relationship_type                 IN  VARCHAR2
   ,p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_weighting_percentage              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_object_relationship_id            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_id_from     pa_object_relationships.object_id_from1%TYPE;
    l_id_to       pa_object_relationships.object_id_to1%TYPE;
    l_type_from   pa_object_relationships.object_type_from%TYPE;
    l_type_to     pa_object_relationships.object_type_to%TYPE;
    l_weighting_percentage pa_object_relationships.weighting_percentage%TYPE;

    l_dummy               varchar2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(250);
    l_return_status       varchar2(1);
    l_error_message_code  varchar2(250);
    l_data                VARCHAR2(2000);
    l_msg_index_out       NUMBER;

    CURSOR Is_Struc_Type_Valid(c_struc_type VARCHAR2, c_struc_id NUMBER) IS
      select '1'
        from pa_proj_structure_types s,
             pa_structure_types t
       where s.proj_element_id = c_struc_id
         and s.structure_type_id = t.structure_type_id
         and t.structure_type_class_code = c_struc_type;

    CURSOR Get_Element_Id(c_elem_ver_id NUMBER) IS
      select proj_element_id, object_type
        from pa_proj_element_versions
       where element_version_id = c_elem_ver_id;

    CURSOR Get_Parent_Struc_Ver_Id(c_elem_ver_id NUMBER) IS
      select parent_structure_Version_id
        from pa_proj_element_versions
       where element_version_id = c_elem_ver_id;

    CURSOR Get_Top_Task_ID(c_project_id NUMBER, c_structure_id NUMBER) IS
      select pev.proj_element_id
        from pa_proj_element_versions pev,
             pa_proj_element_versions pev2,
             pa_object_relationships rel
       where pev2.project_id = c_project_id
         and pev2.object_type = 'PA_STRUCTURES'
         and pev2.proj_element_id = c_structure_id
         and pev2.element_version_id = rel.object_id_from1
         and rel.relationship_type = 'S'
         and rel.object_id_to1 = pev.element_version_id;

    CURSOR Get_Latest_Pub_Ver(c_struc_type VARCHAR2, c_project_id NUMBER) IS
      select pevs.element_version_id
        from pa_proj_structure_types s,
             pa_structure_types t,
             pa_proj_elements pe,
             pa_proj_elem_ver_structure pevs
       where pe.object_type = 'PA_STRUCTURES'
         and pe.project_id = c_project_id
         and pe.proj_element_id = s.proj_element_id
         and s.structure_type_id = t.structure_type_id
         and t.structure_type_class_code = c_struc_type
         and c_project_id = pevs.project_id
         and pe.proj_element_id = pevs.proj_element_id
         and pevs.latest_eff_published_flag = 'Y';

    CURSOR Get_Scheduled_Dates(c_element_version_id NUMBER) IS
      select a.scheduled_start_date, a.scheduled_finish_date
        from pa_proj_elem_ver_schedule a, pa_proj_element_versions b
       where b.element_version_id = c_element_version_id
         and a.project_id = b.project_id
         and a.element_version_id = b.element_version_id;

    l_scheduled_start_date    DATE;
    l_scheduled_finish_date   DATE;

    l_lastest_pub_ver_id      NUMBER;
    l_structure_id            NUMBER;
    l_parent_struc_ver_id     NUMBER;
    l_task_id                 NUMBER;
    l_task_version_id         NUMBER;
    l_pev_schedule_id         NUMBER;
    l_task_name_number        VARCHAR2(240);
    l_peer_or_sub             VARCHAR2(30);

    l_object_type             VARCHAR2(30);
    l_element_id              NUMBER;

    -- Bug 2955589. Local variables introduced to handle miss char and miss num.
    l_lag_day                 pa_object_relationships.lag_day%TYPE;
    l_priority                pa_object_relationships.priority%TYPE;

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.CREATE_RELATIONSHIP begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_relationship_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    --Bug 2955589. Handle miss char for priority.
    IF p_priority = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
          l_priority := NULL;
    ELSE
          l_priority := p_priority;
    END IF;

    --Bug 2955589. Handle miss num for lag_day.
    IF p_lag_day = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          l_lag_day := NULL;
    ELSE
          l_lag_day := p_lag_day;
    END IF;

    --Determine the relationship type
    IF p_relationship_type = 'L' THEN
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('creating link relationship');
      END IF;

      --Check if this is a parent link or child link
      IF (p_initiating_element = 'FROM') THEN
        --It is a child link

        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('child link');
        END IF;

        --Determine parent element id
        IF (p_task_version_id_from IS NULL) THEN
          l_id_from := p_structure_version_id_from;
          l_type_from := 'PA_STRUCTURES';
        ELSE
          l_id_from := p_task_version_id_from;
          l_type_from := 'PA_TASKS';
        END IF;
        --set structure id for creating task.
--dbms_output.put_line('p_structure_id_from = '||p_structure_id_from);
        l_structure_id := p_structure_id_from;


        --Determine child element id
        IF (p_link_to_latest_structure_ver = 'Y') THEN
          --Find latest published version for the structure.
          --  Error if none exist.
--dbms_output.put_line('getting latest pub version'||p_structure_type||', '||p_project_id_to);
          OPEN Get_latest_Pub_Ver(p_structure_type, p_project_id_to);
          FETCH Get_latest_Pub_Ver into l_lastest_pub_ver_id 	;
--dbms_output.put_line('struc ver id='||l_lastest_pub_ver_id||', struc id = '||l_structure_id);
          IF Get_latest_Pub_Ver%NOTFOUND THEN
            CLOSE Get_latest_Pub_Ver;
--dbms_output.put_line('no latest pub version, error');
            PA_UTILS.ADD_MESSAGE('PA','PA_PS_NO_PUB_VER_EXIST');
            x_msg_data := 'PA_PS_NO_PUB_VER_EXIST';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          l_id_to := l_lastest_pub_ver_id;
          l_type_to := 'PA_STRUCTURES';
          CLOSE Get_latest_Pub_Ver;

        ELSE
          --Check if user entered Structure Name and Structure Version Name
          If (p_structure_id_to = NULL) THEN
            PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_NAME_REQ');
            x_msg_data := 'PA_PS_STRUC_NAME_REQ';
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          --Check if selected structure type matches the structure
          OPEN Is_Struc_Type_Valid(p_structure_type, p_structure_id_to);
          FETCH Is_Struc_Type_Valid into l_dummy;
          IF Is_Struc_Type_Valid%NOTFOUND THEN
            CLOSE Is_Struc_Type_Valid;
            PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_TYPE_ID_ERR');
            x_msg_data := 'PA_PS_STRUC_TYPE_ID_ERR';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE Is_Struc_Type_Valid;

          IF (p_structure_version_id_to = NULL) THEN
            PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_VER_NAME_REQ');
            x_msg_data := 'PA_PS_STRUC_VER_NAME_REQ';
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (p_task_version_id_to IS NULL) THEN
            l_id_to := p_structure_version_id_to;
            l_type_to := 'PA_STRUCTURES';
          ELSE
            l_id_to := p_task_version_id_to;
            l_type_to := 'PA_TASKS';
          END IF;

        END IF;

      ELSE
        --It is a parent link
        If (p_debug_mode = 'Y') THEN
          pa_debug.debug('parent link');
        END IF;

        --Determine child element id
        IF (p_task_version_id_to IS NULL) THEN
          l_id_to := p_structure_version_id_to;
          l_type_to := 'PA_STRUCTURES';
        ELSE
          l_id_to := p_task_version_id_to;
          l_type_to := 'PA_TASKS';
        END IF;
        --set structure id for creating task.
        l_structure_id := p_structure_id_from;

        --Determine child element id
        --Check if selected structure type matches the structure
        OPEN Is_Struc_Type_Valid(p_structure_type, p_structure_id_from);
        FETCH Is_Struc_Type_Valid into l_dummy;
        IF Is_Struc_Type_Valid%NOTFOUND THEN
          CLOSE Is_Struc_Type_Valid;
          PA_UTILS.ADD_MESSAGE('PA','PA_PS_STRUC_TYPE_ID_ERR');
          x_msg_data := 'PA_PS_STRUC_TYPE_ID_ERR';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Is_Struc_Type_Valid;

        --Set the from id
        IF (p_task_version_id_from IS NULL) THEN
          l_id_from := p_structure_version_id_from;
          l_type_from := 'PA_STRUCTURES';
        ELSE
          l_id_from := p_task_version_id_from;
          l_type_from := 'PA_TASKS';
        END IF;

      END IF;

--dbms_output.put_line('create_relationship pvt'||l_id_from);

      --Check create link ok
      PA_RELATIONSHIP_UTILS.Check_Create_Link_Ok(l_id_from
                                                 ,l_id_to
                                                 ,l_return_status
                                                 ,l_error_message_code);

--dbms_output.put_line('check create linke done, return '||l_return_status);
      --Modified. When creating links, always create a subtask
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('need to create new sub task');
        END IF;
        l_task_name_number := substr(fnd_date.date_to_canonical(sysdate),0,25);


        --get scheduled dates from the linked task/structure
        OPEN get_scheduled_dates(l_id_to);
        FETCH get_scheduled_dates into l_scheduled_start_date, l_scheduled_finish_date;
        IF get_scheduled_dates%NOTFOUND THEN
          l_scheduled_start_date := sysdate;
          l_scheduled_finish_date := sysdate;
        END IF;
        CLOSE get_scheduled_dates;

        --get parent task info
        l_peer_or_sub := 'SUB';
--dbms_output.put_line('id from = '||l_id_from);
        OPEN Get_Element_Id(l_id_from);
        FETCH Get_Element_Id INTO l_element_id, l_object_type;
        IF Get_Element_Id%NOTFOUND THEN
          l_element_id := NULL;
        ELSE
--dbms_output.put_line('ref is a structure; project_id = '||p_project_id_from||', struc id = '||l_structure_id);
          IF l_object_type = 'PA_STRUCTURES' THEN
            l_peer_or_sub := 'PEER';
            --If Structure has task, need to use peer and select a task;
            OPEN Get_Top_Task_Id(p_project_id_from, l_structure_id);
            FETCH Get_Top_Task_Id into l_element_id;
            IF Get_Top_Task_Id%NOTFOUND THEN
--dbms_output.put_line('top task not found');
              --Empty structure
              l_element_id := NULL;
            END IF;
            CLOSE Get_Top_Task_Id;
          END IF;
        END IF;
        CLOSE Get_Element_Id;
        OPEN Get_Parent_Struc_Ver_Id(l_id_from);
        FETCH Get_Parent_Struc_Ver_Id into l_parent_struc_ver_id;
        CLOSE Get_Parent_Struc_Ver_Id;

        --need to create a task under the from side.
--dbms_output.put_line('Pid = '||p_project_id_from||', l_struc_id = '||l_structure_id||', l_element_id = '||l_element_id||'number(name) = '||substr(l_task_name_number,0,25)||'('||substr(l_task_name_number,0,240)||')');
        PA_TASK_PUB1.CREATE_TASK
        ( p_validate_only          => FND_API.G_FALSE
         ,p_object_type            => 'PA_TASKS'
         ,p_project_id             => p_project_id_from
         ,p_structure_id           => l_structure_id
         ,p_ref_task_id            => l_element_id
         ,p_peer_or_sub            => l_peer_or_sub
         ,p_structure_version_id   => l_parent_struc_ver_id
         ,p_task_number            => substr(l_task_name_number,0,25)
         ,p_task_name              => substr(l_task_name_number,0,240)
         ,p_task_manager_id        => NULL
         ,p_task_manager_name      => NULL
         ,p_scheduled_start_date   => l_scheduled_start_date
         ,p_scheduled_finish_date  => l_scheduled_finish_date
         ,p_link_task_flag => 'Y'
         ,x_task_id                => l_task_id
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data);

        If (p_debug_mode = 'Y') THEN
          pa_debug.debug('new task id => '||l_task_id);
        END IF;

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

        --CREATE_TASK_VERSION
        l_peer_or_sub := 'SUB';

        If (p_debug_mode = 'Y') THEN
          pa_debug.debug('Create peer or sub => '||l_peer_or_sub);
        END IF;

        PA_TASK_PUB1.CREATE_TASK_VERSION
        ( p_validate_only        => FND_API.G_FALSE
         ,p_ref_task_version_id  => l_id_from
         ,p_peer_or_sub          => l_peer_or_sub
         ,p_task_id              => l_task_id
         ,x_task_version_id      => l_task_version_id
         ,x_return_status        => l_return_status
         ,x_msg_count            => l_msg_count
         ,x_msg_data             => l_msg_data);

        If (p_debug_mode = 'Y') THEN
          pa_debug.debug('new task version id  => '||l_task_version_id);
        END IF;


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

        if PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(p_structure_version_id_from, 'WORKPLAN') = 'Y' then
          PA_TASK_PUB1.CREATE_SCHEDULE_VERSION
          ( p_validate_only           => FND_API.G_FALSE
           ,p_element_version_id      => l_task_version_id
           ,p_scheduled_start_date    => l_scheduled_start_date
           ,p_scheduled_end_date      => l_scheduled_finish_date
           ,x_pev_schedule_id         => l_pev_schedule_id
           ,x_return_status           => l_return_status
           ,x_msg_count	              => l_msg_count
           ,x_msg_data                => l_msg_data );

          If (p_debug_mode = 'Y') THEN
            pa_debug.debug('new workplan attr for task => '||l_pev_schedule_id);
          END IF;

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

        --Assign new task as the linking object
        l_id_from := l_task_version_id;
        l_type_from := 'PA_TASKS';

        PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => l_type_from
        ,p_object_id_from1 => l_id_from
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
        ,p_relationship_subtype => p_relationship_subtype
        ,p_lag_day => l_lag_day                   --Bug 2955589. Use miss num handled local var instead of p_lag_day.
        ,p_imported_lag => NULL
        ,p_priority => l_priority                 --Bug 2955589. Use miss char handled local var instead of p_priority.
        ,p_pm_product_code => NULL
        ,x_object_relationship_id => x_object_relationship_id
        ,x_return_status => x_return_status
  --FPM changes bug 3301192
        ,p_comments           => null
        ,p_status_code        => null
  --end FPM changes bug 3301192
        );

      -- 4537865
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	 RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      -- End : 4537865

      ELSE
        PA_UTILS.ADD_MESSAGE('PA',l_error_message_code);
        x_msg_data := l_error_message_code;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF p_relationship_type = 'S' THEN
      --create relationship for task

      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('creating task link');
      END IF;

      IF (p_task_version_id_from IS NULL) THEN
        l_id_from := p_structure_version_id_from;
        l_type_from := 'PA_STRUCTURES';
      ELSE
        l_id_from := p_task_version_id_from;
        l_type_from := 'PA_TASKS';
      END IF;

      IF (p_task_version_id_to IS NULL) THEN
        l_id_to := p_structure_version_id_to;
        l_type_to := 'PA_STRUCTURES';
      ELSE
        l_id_to := p_task_version_id_to;
        l_type_to := 'PA_TASKS';
      END IF;

      IF (p_weighting_percentage = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM or p_weighting_percentage IS NULL) THEN
        l_weighting_percentage := NULL;
      ELSE
        l_weighting_percentage := p_weighting_percentage;
      END IF;

      PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => l_type_from
        ,p_object_id_from1 => l_id_from
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
        ,p_relationship_subtype => p_relationship_subtype
        ,p_lag_day => l_lag_day                    --Bug 2955589. Use miss num handled local var instead of p_lag_day
        ,p_imported_lag => NULL
        ,p_priority => l_priority                  --Bug 2955589. Use miss char handled local var instead of p_priority
        ,p_pm_product_code => NULL
        ,p_weighting_percentage => l_weighting_percentage
        ,x_object_relationship_id => x_object_relationship_id
        ,x_return_status => x_return_status
  --FPM changes bug 3301192
        ,p_comments           => null
        ,p_status_code        => null
  --end FPM changes bug 3301192
      );

      -- 4537865
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      -- End : 4537865

-- Begin add rtarway FP.M development
    ELSIF p_relationship_type = 'M'THEN
        --create mapping for task
        --l_type_from := 'PA_TASKS';
        --l_type_to := 'PA_TASKS';
      IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('creating task link');
      END IF;

      IF (p_task_version_id_from IS NOT NULL) THEN
        l_id_from := p_task_version_id_from;
        l_type_from := 'PA_TASKS';
      END IF;

      IF (p_task_version_id_to IS NOT NULL) THEN
        l_id_to := p_task_version_id_to;
        l_type_to := 'PA_TASKS';
      END IF;
      PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
          p_user_id => FND_GLOBAL.USER_ID
        , p_object_type_from => l_type_from
        , p_object_id_from1  => l_id_from
        , p_object_id_from2  => NULL
        , p_object_id_from3  => NULL
        , p_object_id_from4  => NULL
        , p_object_id_from5  => NULL
        , p_object_type_to   => l_type_to
        , p_object_id_to1    => l_id_to
        , p_object_id_to2    => NULL
        , p_object_id_to3    => NULL
        , p_object_id_to4    => NULL
        , p_object_id_to5    => NULL
        , p_relationship_type=> p_relationship_type
        , p_relationship_subtype =>NULL
        , p_lag_day              => l_lag_day                   --Bug 2955589. Use miss num handled local var instead of p_lag_day
        , p_imported_lag         => NULL
        , p_priority             => l_priority                  --Bug 2955589. Use miss char handled local var instead of p_priority
        , p_pm_product_code      => NULL
        , p_weighting_percentage => NULL
        , x_object_relationship_id => x_object_relationship_id
        , x_return_status          => x_return_status
        , p_comments           => null
        , p_status_code        => null
      );

            -- 4537865
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
      -- End 4537865

    -- End add rtarway FP.M development
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.CREATE_RELATIONSHIP end');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to create_relationship_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to create_relationship_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'Create_Relationship',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END;

-- API name                      : Update_Relationship
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
--   p_object_relationship_id            IN  NUMBER
--   p_project_id_from                   IN  NUMBER
--   p_structure_id_from                 IN  NUMBER
--   p_structure_version_id_from         IN  NUMBER
--   p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_project_id_to                     IN  NUMBER
--   p_structure_id_to                   IN  NUMBER
--   p_structure_version_id_to           IN  NUMBER
--   p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_relationship_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Update_Relationship
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
   ,p_project_id_from                   IN  NUMBER
   ,p_structure_id_from                 IN  NUMBER
   ,p_structure_version_id_from         IN  NUMBER
   ,p_task_version_id_from              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id_to                     IN  NUMBER
   ,p_structure_id_to                   IN  NUMBER
   ,p_structure_version_id_to           IN  NUMBER
   ,p_task_version_id_to                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_relationship_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_relationship_subtype              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_lag_day                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_priority                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
   ,p_weighting_percentage              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_id_from     pa_object_relationships.object_id_from1%TYPE;
    l_id_to       pa_object_relationships.object_id_to1%TYPE;
    l_type_from   pa_object_relationships.object_type_from%TYPE;
    l_type_to     pa_object_relationships.object_type_to%TYPE;
    l_or_id       pa_object_relationships.object_relationship_id%TYPE;
    l_weighting_percentage pa_object_relationships.weighting_percentage%TYPE;
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.UPDATE_RELATIONSHIP begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_relationship_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;


    IF (p_task_version_id_from IS NULL) THEN
      l_id_from := p_structure_version_id_from;
      l_type_from := 'PA_STRUCTURES';
    ELSE
      l_id_from := p_task_version_id_from;
      l_type_from := 'PA_TASKS';
    END IF;

    IF (p_task_version_id_to IS NULL) THEN
      l_id_to := p_structure_version_id_to;
      l_type_to := 'PA_STRUCTURES';
    ELSE
      l_id_to := p_task_version_id_to;
      l_type_to := 'PA_TASKS';
    END IF;

      IF (p_weighting_percentage = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM or p_weighting_percentage IS NULL) THEN
        l_weighting_percentage := NULL;
      ELSE
        l_weighting_percentage := p_weighting_percentage;
      END IF;

    PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW(
       p_object_relationship_id => p_object_relationship_id
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
      ,p_record_version_number => p_record_version_number
      ,p_pm_product_code => NULL
      ,x_return_status => x_return_status
    );

          -- 4537865
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
      END IF;
      -- End 4537865

    PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
       p_user_id => FND_GLOBAL.USER_ID
      ,p_object_type_from => l_type_from
      ,p_object_id_from1 => l_id_from
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
      ,p_relationship_subtype => p_relationship_subtype
      ,p_lag_day => p_lag_day
      ,p_imported_lag => NULL
      ,p_priority => p_priority
      ,p_pm_product_code => NULL
      ,p_weighting_percentage => l_weighting_percentage
      ,x_object_relationship_id => l_or_id
      ,x_return_status => x_return_status
  --FPM changes bug 3301192
        ,p_comments           => null
        ,p_status_code        => null
  --end FPM changes bug 3301192
    );

          -- 4537865
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
      END IF;
      -- End 4537865

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_relationship_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to update_relationship_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                              p_procedure_name => 'Update_relationship',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END UPDATE_RELATIONSHIP;



-- API name                      : Delete_Relationship
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
--   p_object_relationship_id            IN  NUMBER
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT  VARCHAR2
--   x_msg_count                         OUT  NUMBER
--   x_msg_data                          OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Delete_Relationship
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
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    CURSOR get_link_task_ver_id IS
      select object_id_from1, relationship_type
        from pa_object_relationships
       where object_relationship_id = p_object_relationship_id;
    l_link_task_ver get_link_task_ver_id%ROWTYPE;
    l_task_version_rvn NUMBER;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.DELETE_RELATIONSHIP begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_relationship_pvt;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    OPEN get_link_task_ver_id;
    FETCH get_link_task_ver_id into l_link_task_ver;
    CLOSE get_link_task_ver_id;

    PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW(
       p_object_relationship_id => p_object_relationship_id
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
      ,p_record_version_number => p_record_version_number
      ,p_pm_product_code => NULL
      ,x_return_status => x_return_status
    );

          -- 4537865
      IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
      END IF;
      -- End 4537865

    If (l_link_task_ver.relationship_type = 'L') THEN
      --need to delete link task if removing links.
      select record_version_number
        into l_task_version_rvn
        from pa_proj_element_versions
       where element_version_id = l_link_task_ver.object_id_from1;

      PA_TASK_PUB1.DELETE_TASK_VERSION(p_commit => 'N',
                                       p_debug_mode => p_debug_mode,
                                       p_task_version_id => l_link_task_ver.object_id_from1,
                                       p_record_version_number => l_task_version_rvn,
                                       x_return_status => l_return_status,
                                       x_msg_count => l_msg_count,
                                       x_msg_data => l_msg_data);
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

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.DELETE_RELATIONSHIP end');
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to delete_relationship_pvt;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to delete_relationship_pvt;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                              p_procedure_name => 'Delete_relationship',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END DELETE_RELATIONSHIP;

-- API name                      : Create_Dependency
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
--   p_src_proj_id                       IN  NUMBER      := NULL
--   p_src_task_ver_id                   IN  NUMBER      := NULL
--   p_dest_proj_id                      IN  NUMBER      := NULL
--   P_dest_task_id                      IN  NUMBER      := NULL
--   P_type                              IN  VARCHAR2    := 'FS'
--   P_lag_days                          IN  NUMBER      := 0
--   p_comments                          IN  VARCHAR2    := NULL
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Create_dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_src_proj_id                       IN  NUMBER      := NULL
   ,p_src_task_ver_id                   IN  NUMBER      := NULL
   ,p_dest_proj_id                      IN  NUMBER      := NULL
   ,p_dest_task_ver_id                  IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := 'FS'
   ,p_lag_days                          IN  NUMBER      := 0
   ,p_comments                          IN  VARCHAR2    := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'CREATE_DEPENDENCY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

    l_dest_proj_id                  NUMBER;
    l_dest_task_ver_id              NUMBER;
    l_structure_ver_id              NUMBER;

    l_work_structure_ver_id         NUMBER;       /* working structure version */
    l_lp_structure_ver_id           NUMBER;       /* latest published structrue version */
    l_src_proj_ve                   VARCHAR2(1);  /* source project versioning enabled flag */
    l_dest_proj_ve                  VARCHAR2(1);  /* destination project versioning enabled flag */
    l_work_dest_task_ver_id         NUMBER;       /* destination working task version */
    l_object_relationship_id        NUMBER;
    l_src_str_status_code           VARCHAR2(30);
    l_status_code                   VARCHAR2(30);

    l_lag_days                      NUMBER;

    l_cnt                           NUMBER; /* created to check given task is summary task or not */

    CURSOR get_src_str_status
    IS
      SELECT status_code
        FROM  pa_proj_element_versions ppev,
              pa_proj_elem_ver_structure ppevs
       WHERE ppev.project_id = p_src_proj_id
         AND ppev.element_version_id = p_src_task_ver_id
         AND ppev.parent_structure_version_id = ppevs.element_version_id
         AND ppevs.project_id = ppev.project_id
         ;

    CURSOR get_dest_task_ver_id
    IS
      SELECT pev2.element_version_id, 'STRUCTURE_WORKING' status_code
        FROM pa_proj_element_versions pev,
             pa_proj_elem_ver_structure str,
             pa_proj_element_versions pev2
       WHERE pev.proj_element_id = pev2.proj_element_id
         AND pev.project_id = pev2.project_id
         AND pev2.parent_structure_version_id = str.element_version_id
         AND pev2.project_id = str.project_id
         AND str.current_working_flag = 'Y'
         AND str.status_code <> 'STRUCTURE_PUBLISHED'
         AND pev.element_version_id =  p_dest_task_ver_id
      UNION ALL
      SELECT pev2.element_version_id, 'STRUCTURE_PUBLISHED' status_code
        FROM pa_proj_element_versions pev,
             pa_proj_elem_ver_structure str,
             pa_proj_element_versions pev2
       WHERE pev.proj_element_id = pev2.proj_element_id
         AND pev.project_id = pev2.project_id
         AND pev2.parent_structure_version_id = str.element_version_id
         AND pev2.project_id = str.project_id
         AND str.status_code = 'STRUCTURE_PUBLISHED'
         AND str.latest_eff_published_flag = 'Y'
         AND pev.element_version_id = p_dest_task_ver_id
         ;

   cursor is_summary_task(c_task_ver_id number) IS
        SELECT count(1)
        FROM  dual
        WHERE EXISTS ( SELECT 'x'
                       FROM pa_object_relationships por
                       WHERE por.object_id_from1   = c_task_ver_id
                       AND   por.object_type_from  = 'PA_TASKS'
                       AND   por.relationship_type = 'S');

    l_debug_mode               varchar2(1)   := 'N'; --BUG 4218977, rtarway
    g_module_name              varchar2(200) := 'PA_RELATIONSHIP_PVT.CREATE_DEPENDENCY';--BUG 4218977, rtarway

  BEGIN

    l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.CREATE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint create_dependency_pvt;
    END IF;

    --Bug8427713 : WHEN CONVERTING DATA FROM MSP, THE INCORRECT PRED_STRING VALUE IS LOADED
    IF p_calling_module = 'SELF_SERVICE' OR p_calling_module = 'AMG' THEN
      IF (p_lag_days = NULL) THEN
        l_lag_days := 0;
      END IF;
      l_lag_days := p_lag_days; -- bug 8583608 * 10 * 60 * 8;
    ELSE
      IF (p_lag_days = NULL) THEN
        l_lag_days := 0;
      ELSE
        l_lag_days := p_lag_days;
      END IF;
    END IF;

   /* Checking source task is summary task or not */
   IF (UPPER(PA_PROJECT_STRUCTURE_UTILS.check_dep_on_summary_tk_ok(p_src_proj_id))  <> 'Y') THEN
     l_cnt := 0;
     BEGIN
        OPEN is_summary_task(p_src_task_ver_id);
        FETCH is_summary_task into l_cnt;
        CLOSE is_summary_task;
        /* If single row is returned */
        IF NVL(l_cnt,0) <> 0 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_count     := 1;
           x_msg_data      := 'PA_PS_NO_DEP_ON_SUMM';
           PA_UTILS.add_message('PA', 'PA_PS_NO_DEP_ON_SUMM');
           raise FND_API.G_EXC_ERROR;
        END IF;
     END;
   END IF;


   /* Checking destination task is summary task or not */
   IF (UPPER(PA_PROJECT_STRUCTURE_UTILS.check_dep_on_summary_tk_ok(p_dest_proj_id))  <> 'Y') THEN
     l_cnt := 0;
     BEGIN
        OPEN is_summary_task(p_dest_task_ver_id);
        FETCH IS_SUMMARY_TASK into l_cnt;
        close is_summary_task;
        /* If single row is returned */
        IF NVL(l_cnt,0) <> 0 THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_count     := 1;
           x_msg_data      := 'PA_PS_NO_DEP_ON_SUMM';
           PA_UTILS.add_message('PA', 'PA_PS_NO_DEP_ON_SUMM');
           raise FND_API.G_EXC_ERROR;
        END IF;
     END;
   END IF;

   --create record in object relationships table
   --Added by rtarway, 4218977
   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage := 'Value of G_OP_VALIDATE_flag'||PA_PROJECT_PUB.G_OP_VALIDATE_FLAG ;
        pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
   END IF;

   IF p_src_proj_id = p_dest_proj_id
   THEN
       --If Added by rtarway, 4218977
       --Added null check for BUG 4226832, rtarway
       IF ( PA_PROJECT_PUB.G_OP_VALIDATE_FLAG is null OR PA_PROJECT_PUB.G_OP_VALIDATE_FLAG = 'Y' ) THEN
           /* Checking intra dependency  */
           BEGIN

              PA_RELATIONSHIP_UTILS.check_create_intra_dep_ok(
                                      p_pre_project_id             => p_dest_proj_id
                                     ,p_pre_task_ver_id            => p_dest_task_ver_id
                                     ,p_project_id                 => p_src_proj_id
                                     ,p_task_ver_id                => p_src_task_ver_id
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
           END;
      END IF;

       --Create record in relationships table.
       PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id                   => FND_GLOBAL.USER_ID
        ,p_object_type_from          => 'PA_TASKS'
        ,p_object_id_from1           => p_src_task_ver_id
        ,p_object_id_from2           => p_src_proj_id
        ,p_object_id_from3           => NULL
        ,p_object_id_from4           => NULL
        ,p_object_id_from5           => NULL
        ,p_object_type_to            => 'PA_TASKS'
        ,p_object_id_to1             => p_dest_task_ver_id
        ,p_object_id_to2             => p_dest_proj_id
        ,p_object_id_to3             => NULL
        ,p_object_id_to4             => NULL
        ,p_object_id_to5             => NULL
        ,p_relationship_type         => 'D'
        ,p_relationship_subtype      => p_type
        ,p_lag_day                   => l_lag_days
        ,p_imported_lag              => NULL
        ,p_priority                  => null
        ,p_pm_product_code           => NULL
        ,x_object_relationship_id    => l_object_relationship_id
        ,x_return_status             => l_return_status
        ,p_comments                  => p_comments
        ,p_status_code               => null   /* not applicable for intra dependency */
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

   ELSE

      /* Checking inter dependency */
      BEGIN
         PA_RELATIONSHIP_UTILS.check_create_inter_dep_ok(
                                 p_pre_project_id             => p_dest_proj_id
                                ,p_pre_task_ver_id            => p_dest_task_ver_id
                                ,p_project_id                 => p_src_proj_id
                                ,p_task_ver_id                => p_src_task_ver_id
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
      END;

       l_src_proj_ve := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(p_src_proj_id);
       l_dest_proj_ve := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(p_dest_proj_id);

       OPEN get_src_str_status;
       FETCH get_src_str_status INTO l_src_str_status_code;
       CLOSE get_src_str_status;

       FOR get_dest_task_ver_id_rec IN get_dest_task_ver_id LOOP
            IF l_src_str_status_code = rtrim(get_dest_task_ver_id_rec.status_code) AND l_src_str_status_code = 'STRUCTURE_WORKING'
            THEN
               l_status_code := 'UNPUBLISHED';
            ELSIF l_src_str_status_code = rtrim(get_dest_task_ver_id_rec.status_code) AND l_src_str_status_code = 'STRUCTURE_PUBLISHED'
            THEN
               l_status_code := 'PUBLISHED';
            ELSE
                IF (l_src_str_status_code = 'STRUCTURE_WORKING' AND rtrim(get_dest_task_ver_id_rec.status_code) = 'STRUCTURE_PUBLISHED')
                THEN
                   IF l_dest_proj_ve = 'Y'
                   THEN
                      l_status_code := 'PUBLISHED'; /* creating dependency from a working version to published version and dest is versioned.*/
                   ELSE
                      l_status_code := 'UNPUBLISHED'; /* creating dependency from a working version to published version and dest is not versioned.*/
                   END IF;
                ELSIF (l_src_str_status_code = 'STRUCTURE_PUBLISHED' AND rtrim(get_dest_task_ver_id_rec.status_code) = 'STRUCTURE_WORKING')  --Bug No 3763315
		THEN
                      l_status_code := 'UNPUBLISHED'; /* creating dependency from a working version to published version and dest is versioned.*/
                ELSIF (l_src_proj_ve = 'N'  AND l_dest_proj_ve = 'N') AND
                      (l_src_str_status_code = 'STRUCTURE_PUBLISHED' AND rtrim(get_dest_task_ver_id_rec.status_code) = 'STRUCTURE_PUBLISHED')
                THEN
                    l_status_code := 'PUBLISHED';   /* creating dependency from a published version to published version */
                END IF;
            END IF;

            --Create record in relationships table.
            PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
                         p_user_id                   => FND_GLOBAL.USER_ID
                	,p_object_type_from          => 'PA_TASKS'
	                ,p_object_id_from1           => p_src_task_ver_id
		        ,p_object_id_from2           => p_src_proj_id
		        ,p_object_id_from3           => NULL
		        ,p_object_id_from4           => NULL
		        ,p_object_id_from5           => NULL
		        ,p_object_type_to            => 'PA_TASKS'
		        ,p_object_id_to1             => get_dest_task_ver_id_rec.element_version_id
		        ,p_object_id_to2             => p_dest_proj_id
		        ,p_object_id_to3             => NULL
		        ,p_object_id_to4             => NULL
		        ,p_object_id_to5             => NULL
		        ,p_relationship_type         => 'D'
		        ,p_relationship_subtype      => p_type
		        ,p_lag_day                   => l_lag_days
		        ,p_imported_lag              => NULL
		        ,p_priority                  => null
		        ,p_pm_product_code           => NULL
		        ,x_object_relationship_id    => l_object_relationship_id
		        ,x_return_status             => l_return_status
		        ,p_comments                  => p_comments
		        ,p_status_code               => l_status_code
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.CREATE_DEPENDENCY END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to create_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'CREATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to create_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'CREATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Create_Dependency;

-- API name                      : Update_Dependency
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
--   p_task_version_id                   IN  NUMBER      := NULL
--   p_type                              IN  VARCHAR2    := NULL
--   p_lag_days                          IN  NUMBER      := NULL
--   p_comments                          IN  VARCHAR2    := NULL
--   p_record_version_number             IN  NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Update_dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_task_version_id                   IN  NUMBER      := NULL
   ,p_src_task_version_id               IN  NUMBER      := NULL
   ,p_type                              IN  VARCHAR2    := NULL
   ,p_lag_days                          IN  NUMBER      := NULL
   ,p_comments                          IN  VARCHAR2    := NULL
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_DEPENDENCY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

    l_lag_days                       NUMBER;
    l_comments                      VARCHAR2(240);
    l_rel_subtype                   VARCHAR2(30);

    CURSOR cur_obj_rel
    IS
      SELECT *
        FROM pa_object_relationships
       WHERE object_id_to1 = p_task_version_id
         AND object_id_from1 = p_src_task_version_id
         AND relationship_type = 'D';
  BEGIN

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.UPDATE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint update_dependency_pvt;
    END IF;

    FOR  l_obj_rel_rec IN cur_obj_rel LOOP

         IF (l_obj_rel_rec.lag_day IS NULL) OR (p_lag_days <> l_obj_rel_rec.lag_day)
         THEN
          --Bug8427713 : WHEN CONVERTING DATA FROM MSP, THE INCORRECT PRED_STRING VALUE IS LOADED
          IF p_calling_module = 'SELF_SERVICE' OR p_calling_module = 'AMG' THEN
             l_lag_days := p_lag_days; -- bug#	8583608 * 10 * 60 * 8;
           ELSE
             l_lag_days := p_lag_days;
           END IF;
         ELSE
             l_lag_days := l_obj_rel_rec.lag_day;
         END IF;

         IF (l_obj_rel_rec.relationship_subtype IS NULL) OR (p_type <> l_obj_rel_rec.relationship_subtype)
         THEN
            l_rel_subtype := p_type;
         ELSE
            l_rel_subtype := l_obj_rel_rec.relationship_subtype;
         END IF;

         l_comments := p_comments;

         --update record in object relationships table

         PA_OBJECT_RELATIONSHIPS_PKG.UPDATE_ROW
          (        p_user_id                => FND_GLOBAL.USER_ID
                  ,p_object_relationship_id => l_obj_rel_rec.object_relationship_id
                  ,p_relationship_type      => l_obj_rel_rec.relationship_type
                  ,p_relationship_subtype   => l_rel_subtype
                  ,p_lag_day                => l_lag_days
                  ,p_priority               => l_obj_rel_rec.priority
                  ,p_pm_product_code        => l_obj_rel_rec.pm_product_code
               	  ,p_weighting_percentage   => l_obj_rel_rec.weighting_percentage
                  ,p_comments               => l_comments
                  ,p_status_code            => l_obj_rel_rec.status_code
                  ,p_record_version_number  => p_record_version_number
                  ,x_return_status          => l_return_status
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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.UPDATE_DEPENDENCY END');
    END IF;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to update_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'UPDATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to update_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'UPDATE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Update_Dependency;

-- API name                      : Delete_Dependency
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
--   p_object_relationship_id            IN  NUMBER      := NULL
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  10-dec-03   Maansari             -Created
--
--  FPM bug 3301192
--

  procedure Delete_Dependency
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_object_relationship_id            IN  NUMBER      := NULL
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'DELETE_DEPENDENCY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);


    /* Since the one source can be dependent on multiple destination projects, we need to deltete dependencies only from
       one specific destination project. */
    /* get the relationship ids of the dependencies between the source and the destination.*/

    CURSOR cur_obj_rel
    IS
      SELECT por2.object_relationship_id, por2.record_version_number
        FROM pa_object_relationships por1,
             pa_object_relationships por2
       WHERE por1.object_relationship_id = p_object_relationship_id
         AND por1.relationship_type = 'D'
         AND por1.object_id_from1 = por2.object_id_from1
         AND por2.object_id_to1 IN (
             select ppev1.element_version_id
               from pa_proj_element_versions ppev1,
                    pa_proj_element_versions ppev2
              where ppev2.element_version_id = por1.object_id_to1
                and ppev2.project_id = ppev1.project_id
                and ppev2.proj_element_Id = ppev1.proj_element_id);
--
    --Bug No 3494587 Added this cursor to get source structure version id and project id
    --for the given relationship id
    CURSOR cur_get_struc_det(cp_object_relationship_id NUMBER)
    IS
      SELECT parent_structure_version_id,project_id
        FROM pa_object_relationships por,
             pa_proj_element_versions ppev
       WHERE por.object_relationship_id = cp_object_relationship_id
         AND ppev.element_version_id = por.object_id_from1;
    l_project_id  NUMBER;
    l_struc_ver_id NUMBER;
  BEGIN

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.DELETE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_dependency_pvt;
    END IF;

    --delete record from object relationships table.

    FOR cur_obj_rel_rec IN cur_obj_rel LOOP
--
        --Bug No 3494587
        OPEN cur_get_struc_det(cur_obj_rel_rec.object_relationship_id);
        FETCH cur_get_struc_det INTO l_struc_ver_id,l_project_id;
        CLOSE cur_get_struc_det;
--
        -- Bug No 3494587, added this to code check if the the structure ver is published
        -- if the sturcture ver is published then the process should not allow to delete dependency
        IF PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_project_id) = 'Y' THEN
          IF PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(l_project_id,l_struc_ver_id) = 'Y' THEN
             PA_UTILS.ADD_MESSAGE('PA','PA_DEL_DEP_FOR_PUB_STR');
             RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
--
        PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW (
         p_object_relationship_id => cur_obj_rel_rec.object_relationship_id
        ,p_object_type_from       =>  null
        ,p_object_id_from1        =>  null
        ,p_object_id_from2        =>  null
        ,p_object_id_from3        =>  null
        ,p_object_id_from4        =>  null
        ,p_object_id_from5        =>  null
        ,p_object_type_to         =>  null
        ,p_object_id_to1          =>  null
        ,p_object_id_to2          =>  null
        ,p_object_id_to3          =>  null
        ,p_object_id_to4          =>  null
        ,p_object_id_to5          =>  null
	,p_record_version_number  =>  cur_obj_rel_rec.record_version_number
        ,p_pm_product_code        =>  null
	,x_return_status          => l_return_status );

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

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.DELETE_DEPENDENCY END');
    END IF;
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'DELETE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to delete_dependency_pvt;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'DELETE_DEPENDENCY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END Delete_Dependency;

  -- Added for FP_M changes 3305199
  Procedure Copy_Intra_Dependency (
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /*	P_Source_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
  /*    P_Destin_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
	P_Source_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	P_Destin_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
        P_source_struc_ver_id     IN      NUMBER := NULL,
        p_dest_struc_ver_id       IN      NUMBER := NULL,
	X_Return_Status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Msg_Count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
	X_Msg_Data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

  l_Found_Flag		NUMBER;
  l_Object_Task_ID	NUMBER;

  l_src_proj_id         NUMBER;
  l_src_task_ver_id     NUMBER;
  l_dest_proj_id        NUMBER;
  l_dest_task_ver_id    NUMBER;
  l_Type                VARCHAR2(100);
  l_lag_days    	NUMBER;
  l_comments		VARCHAR2(240);

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

  --bug 4019845
  CURSOR get_struc_dependency IS
  select --a.element_version_id src_task_ver_id,
         b.element_version_id dest_task_ver_id,
         --c.element_version_id src_pred_ver_id,
         d.element_version_id dest_pred_ver_id,
         a.project_id,
         r.relationship_subtype,
         r.lag_day,
         r.comments
    from pa_proj_element_versions a,
         pa_proj_element_versions b,
         pa_proj_element_versions c,
         pa_proj_element_versions d,
         pa_object_relationships r
   where a.project_id = b.project_id
     and a.proj_element_id = b.proj_element_id
     and a.parent_structure_version_id = P_source_struc_ver_id
     and b.parent_structure_version_id = p_dest_struc_ver_id
     and r.relationship_type = 'D'
     and r.object_id_from1 = a.element_version_id
     and r.object_id_to1 = c.element_version_id
     and r.object_id_from2 = r.object_id_to2
     and c.project_id = a.project_id
     and c.parent_structure_version_id = p_source_struc_ver_id
     and d.project_id = b.project_id
     and d.proj_element_id = c.proj_element_id
     and d.parent_structure_version_id = p_dest_struc_ver_id;
   l_dep_struc_rec  get_struc_dependency%ROWTYPE;
  --end bug 4019845

  CURSOR get_dependency(c_suc_ver_id NUMBER, c_pred_ver_id NUMBER) IS
    select * from pa_object_relationships
     where relationship_type = 'D'
       and object_id_from1 = c_suc_ver_id
       and object_id_to1 = c_pred_ver_id
       and object_id_from2 = object_id_to2
       and object_type_from = 'PA_TASKS'
       and object_type_to = 'PA_TASKS';
  l_dependency_rec get_dependency%ROWTYPE;

  CURSOR get_parent_struc_ver_id(c_elem_ver_id NUMBER) IS
    select parent_structure_version_id, project_id
      from pa_proj_element_versions
     where element_version_id = c_elem_ver_id;
  l_parent_ver_id1    NUMBER;
  l_parent_ver_id2    NUMBER;
  l_project_id1       NUMBER;
  l_project_id2       NUMBER;

  CURSOR check_intra_dep_exists(c_elem_ver_id NUMBER) IS
    select 1
      from pa_object_relationships
     where relationship_type = 'D'
       and object_id_from1 = c_elem_ver_id
       and object_id_from2 = object_id_to2
       and rownum = 1;
  l_dummy NUMBER;

  --bug 4153377
  l_pred_ver_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_pred_proj_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_suc_ver_id_tbl   SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_suc_proj_id_tbl  SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
  l_comment_tbl      SYSTEM.PA_VARCHAR2_240_TBL_TYPE := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
  l_subtype_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  l_lag_days_tbl     SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

  CURSOR get_dependency2 IS
    select /*+ leading(dt1) use_nl(dt1 rel) */       -- hint added per performance team recommendation for bug 5576900
           rel.object_id_from1, dt1.dest_task_ver_id DEST_FROM_ID,
           rel.object_id_to1, dt2.dest_task_ver_id DEST_TO_ID,
           rel.comments, rel.LAG_DAY, rel.RELATIONSHIP_SUBTYPE
      from pa_object_relationships rel,
           pa_copy_dep_temp dt1,
           pa_copy_dep_temp dt2
     where rel.relationship_type = 'D'
       and rel.object_id_from1 = dt1.src_task_ver_id
       and rel.object_id_to1 = dt2.src_task_ver_id
       and rel.object_id_from2 = object_id_to2
       and object_type_from = 'PA_TASKS'
       and object_type_to = 'PA_TASKS';
  l_dep_rec2 get_dependency2%ROWTYPE;
  --end bug 4153377

-- Begin fix for Bug # 4354217.

-- Begin Bug # 4354217 : 15-AUG-2005.

-- Bug # 5077599.

-- Bug 9247114
-- Reverted to the old definition of get_dependency3 since the new definition added as part
-- of bug 4947328 did not resolve the original issue, and also resulted in P1 bug 9247114
-- Note that pa_copy_dep_temp will not have all the tasks in the copy tasks context

  cursor get_dependency3 is
  -- select all predecessor dependencies from the source task to other tasks in the project.
  select pcdt.dest_task_ver_id suc_ver_id, rel.object_id_to1 pred_ver_id
	, rel.object_id_from2 suc_proj_id, rel.object_id_to2 pred_proj_id
	, rel.relationship_subtype sub_type, rel.lag_day lag_day, rel.comments comments
  from pa_object_relationships rel, pa_copy_dep_temp pcdt
  where rel.object_id_from1 = pcdt.src_task_ver_id
  and rel.relationship_type = 'D'
  and rel.object_id_from2 = rel.object_id_to2
  and object_type_from = 'PA_TASKS'
  and object_type_to = 'PA_TASKS'
  -- This condition prevents the creation of intra-project dependencies between a task and any of
  -- its sub-tasks.
  and rel.object_id_to1 not in (select por.object_id_from1
				from pa_object_relationships por
				where por.relationship_type = 'S'
				and por.object_type_from = 'PA_TASKS'
				start with por.object_id_to1 = pcdt.dest_task_ver_id
				connect by prior por.object_id_from1 = por.object_id_to1
				and prior por.relationship_type = por.relationship_type
				union
				select por.object_id_to1
                                from pa_object_relationships por
				where por.relationship_type = 'S'
				and por.object_type_to = 'PA_TASKS'
                                start with por.object_id_from1 = pcdt.dest_task_ver_id
                                connect by prior por.object_id_to1 = por.object_id_from1
				and prior por.relationship_type = por.relationship_type)
  union all
  -- select all successor dependencies from other tasks in the project to the source task.
  select rel.object_id_from1 suc_ver_id, pcdt.dest_task_ver_id pred_ver_id
        , rel.object_id_from2 suc_proj_id, rel.object_id_to2 pred_proj_id
        , rel.relationship_subtype sub_type, rel.lag_day lag_day, rel.comments comments
  from pa_object_relationships rel, pa_copy_dep_temp pcdt
  where rel.object_id_to1 = pcdt.src_task_ver_id
  and rel.relationship_type = 'D'
  and rel.object_id_from2 = rel.object_id_to2
  and object_type_from = 'PA_TASKS'
  and object_type_to = 'PA_TASKS'
  -- This condition prevents the creation of intra-project dependencies between a task and any of \
  -- its sub-tasks.
  and rel.object_id_from1 not in (select por.object_id_from1
                                from pa_object_relationships por
                                where por.relationship_type = 'S'
                                and por.object_type_from = 'PA_TASKS'
                                start with por.object_id_to1 = pcdt.dest_task_ver_id
                                connect by prior por.object_id_from1 = por.object_id_to1
                                and prior por.relationship_type = por.relationship_type
                                union
                                select por.object_id_to1
                                from pa_object_relationships por
                                where por.relationship_type = 'S'
                                and por.object_type_to = 'PA_TASKS'
                                start with por.object_id_from1 = pcdt.dest_task_ver_id
                                connect by prior por.object_id_to1 = por.object_id_from1
                                and prior por.relationship_type = por.relationship_type);




/*
  cursor get_dependency3 is
  -- select all predecessor dependencies from the source task to other tasks in the project.
  select pcdt.dest_task_ver_id suc_ver_id, pcdt2.dest_task_ver_id pred_ver_id
        , rel.object_id_from2 suc_proj_id, rel.object_id_to2 pred_proj_id
        , rel.relationship_subtype sub_type, rel.lag_day lag_day, rel.comments comments
  from pa_object_relationships rel, pa_copy_dep_temp pcdt, pa_copy_dep_temp pcdt2
  where rel.object_id_from1 = pcdt.src_task_ver_id
  and rel.relationship_type = 'D'
  and rel.object_id_to1 = pcdt2.src_task_ver_id
  and rel.object_id_from2 = rel.object_id_to2
  and object_type_from = 'PA_TASKS'
  and object_type_to = 'PA_TASKS'
  -- This condition prevents the creation of intra-project dependencies between a task and any of
  -- its sub-tasks.
  and pcdt2.dest_task_ver_id not in (select por.object_id_from1
                                     from pa_object_relationships por
                                     where por.relationship_type = 'S'
                                     and por.object_type_from = 'PA_TASKS'
                                     start with por.object_id_to1 = pcdt.dest_task_ver_id
                                     connect by prior por.object_id_from1 = por.object_id_to1
                                     and prior por.relationship_type = por.relationship_type
                                     union
                                     select por.object_id_to1
                                     from pa_object_relationships por
                                     where por.relationship_type = 'S'
                                     and por.object_type_to = 'PA_TASKS'
                                     start with por.object_id_from1 = pcdt.dest_task_ver_id
                                     connect by prior por.object_id_to1 = por.object_id_from1
                                     and prior por.relationship_type = por.relationship_type)
  union
  -- select all successor dependencies from other tasks in the project to the source task.
  select pcdt2.dest_task_ver_id suc_ver_id, pcdt.dest_task_ver_id pred_ver_id
        , rel.object_id_from2 suc_proj_id, rel.object_id_to2 pred_proj_id
        , rel.relationship_subtype sub_type, rel.lag_day lag_day, rel.comments comments
  from pa_object_relationships rel, pa_copy_dep_temp pcdt, pa_copy_dep_temp pcdt2
  where rel.object_id_to1 = pcdt.src_task_ver_id
  and rel.relationship_type = 'D'
  and rel.object_id_from1 = pcdt2.src_task_ver_id
  and rel.object_id_from2 = rel.object_id_to2
  and object_type_from = 'PA_TASKS'
  and object_type_to = 'PA_TASKS'
  -- This condition prevents the creation of intra-project dependencies between a task and any of
  -- its sub-tasks.
  and pcdt2.dest_task_ver_id not in (select por.object_id_from1
                                     from pa_object_relationships por
                                     where por.relationship_type = 'S'
                                     and por.object_type_from = 'PA_TASKS'
                                     start with por.object_id_to1 = pcdt.dest_task_ver_id
                                     connect by prior por.object_id_from1 = por.object_id_to1
                                     and prior por.relationship_type = por.relationship_type
                                     union
                                     select por.object_id_to1
                                     from pa_object_relationships por
                                     where por.relationship_type = 'S'
                                     and por.object_type_to = 'PA_TASKS'
                                     start with por.object_id_from1 = pcdt.dest_task_ver_id
                                     connect by prior por.object_id_to1 = por.object_id_from1
                                     and prior por.relationship_type = por.relationship_type);

-- End of Bug # 5077599.
*/

cursor l_cur_all_tasks(c_task_ver_id NUMBER) is
select count(ppev.element_version_id)
from pa_proj_element_versions ppev
where ppev.parent_structure_version_id = (select ppev2.parent_structure_version_id
					  from pa_proj_element_versions ppev2
					  where ppev2.element_version_id = c_task_ver_id)
and ppev.object_type = 'PA_TASKS'
and ppev.element_version_id not in (select pcdt.src_task_ver_id
				    from pa_copy_dep_temp pcdt);

l_count_all_tasks NUMBER := null;

-- End Bug # 4354217 : 15-AUG-2005.

-- End fix for Bug # 4354217.

l_debug_mode                    VARCHAR2(1);     --debug messages added while fixing bug 5067296
BEGIN
Delete from PA_COPY_DEP_TEMP; --Bug#8842950

   --debug messages added while fixing bug 5067296
    l_debug_mode := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.login_id,275,null,null), 'N');

    IF (l_debug_mode = 'Y') THEN
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY Start : Passed Parameters :', x_Log_Level=> 3);
/* These two lines are causing bug 5076461 in publish flow.
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'P_Source_Ver_Tbl.Count='||P_Source_Ver_Tbl.Count, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'P_Destin_Ver_Tbl.Count='||P_Destin_Ver_Tbl.Count, x_Log_Level=> 3);
*/
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'P_source_struc_ver_id='||P_source_struc_ver_id, x_Log_Level=> 3);
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'p_dest_struc_ver_id='||p_dest_struc_ver_id, x_Log_Level=> 3);
    END IF;
   --debug messages added while fixing bug 5067296


    IF (P_source_struc_ver_id IS NULL) THEN

--bug 4153377
      --insert mapping ids
       --debug messages added while fixing bug 5067296
       IF (l_debug_mode = 'Y') THEN
          pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'Before BULK insert into PA_COPY_DEP_TEMP table', x_Log_Level=> 3);
       END IF;
      --debug messages added while fixing bug 5067296
      Forall i IN 1..P_Source_Ver_Tbl.Count
      INSERT INTO PA_COPY_DEP_TEMP(SRC_TASK_VER_ID, DEST_TASK_VER_ID)
      VALUES(p_source_ver_tbl(i), p_destin_ver_tbl(i));

      -- Begin fix for Bug # 4354217.

      -- Begin Bug # 4354217 : 15-AUG-2005.

      -- The cursor get_dependency2 expects all the source tasks from a structure version to be
      -- passed into this API along with their destination task versions. The cursor get_dependency2
      -- is used to create the same dependencies among the dest_task_ver_ids as exists among
      -- the src_task_ver_ids.
      -- If only some src_task_ver_id and their corresponding dest_task_ver_id are passed into this API
      -- as is the case from the PA_TASK_PUB1.COPY_TASK() API, then we use the cursor get_dependency3 to
      -- get all the dependencies for each src_task_ver_id and create the same for the corresponding
      -- dest_task_ver_id.

    --debug messages added while fixing bug 5067296
    IF (l_debug_mode = 'Y') THEN
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY',         x_Msg => 'Before cursor l_cur_all_tasks', x_Log_Level=> 3);
    END IF;
    --debug messages added while fixing bug 5067296

    IF P_Source_Ver_Tbl.Count > 0   --bug 5067296
    THEN

      open l_cur_all_tasks(p_source_ver_tbl(1));
      fetch l_cur_all_tasks into l_count_all_tasks;
      close l_cur_all_tasks;
    END IF;

    --debug messages added while fixing bug 5067296
    IF (l_debug_mode = 'Y') THEN
       pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'After cursor l_cur_all_tasks l_count_all_tasks='||l_count_all_tasks, x_Log_Level=> 3);
    END IF;
    --debug messages added while fixing bug 5067296

      if (NVL(l_count_all_tasks,0) > 0) then

        open get_dependency3;

      -- End Bug # 4354217 : 15-AUG-2005.

        loop

                fetch get_dependency3 bulk collect INTO l_suc_ver_id_tbl, l_pred_ver_id_tbl
                                                        , l_suc_proj_id_tbl, l_pred_proj_id_tbl
                                                        , l_subtype_tbl, l_lag_days_tbl
                                                        , l_comment_tbl LIMIT 1000;
                exit WHEN get_dependency3%NOTFOUND;

        end loop;

        close get_dependency3;

      else

      -- End fix for Bug # 4354217.

      --check if tasks has dependency
      OPEN get_dependency2;
      LOOP
        FETCH get_dependency2 INTO l_dep_rec2;
        EXIT when get_dependency2%NOTFOUND;

        --check if copying to same structure version; bug 3625037
        OPEN get_parent_struc_ver_id(l_dep_rec2.DEST_FROM_ID);
        FETCH get_parent_struc_ver_id INTO l_parent_ver_id1, l_project_id1;
        CLOSE get_parent_struc_ver_id;

        OPEN get_parent_struc_ver_id(l_dep_rec2.DEST_TO_ID);
        FETCH get_parent_struc_ver_id INTO l_parent_ver_id2, l_project_id2;
        CLOSE get_parent_struc_ver_id;

        --debug messages added while fixing bug 5067296
        IF (l_debug_mode = 'Y') THEN
            pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'l_parent_ver_id1='||l_parent_ver_id1, x_Log_Level=> 3);
            pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'l_parent_ver_id2='||l_parent_ver_id2, x_Log_Level=> 3);
        END IF;
        --debug messages added while fixing bug 5067296

        IF (l_parent_ver_id1 = l_parent_ver_id2) THEN
          --insert into plsql tbl
          l_suc_ver_id_tbl.extend(1);
          l_suc_ver_id_tbl(l_suc_ver_id_tbl.count) := l_dep_rec2.DEST_FROM_ID;
          l_suc_proj_id_tbl.extend(1);
          l_suc_proj_id_tbl(l_suc_proj_id_tbl.count) := l_project_id1;
          l_pred_ver_id_tbl.extend(1);
          l_pred_ver_id_tbl(l_pred_ver_id_tbl.count) := l_dep_rec2.DEST_TO_ID;
          l_pred_proj_id_tbl.extend(1);
          l_pred_proj_id_tbl(l_pred_proj_id_tbl.count) := l_project_id2;
          l_comment_tbl.extend(1);
          l_comment_tbl(l_comment_tbl.count) := l_dep_rec2.comments;
          l_subtype_tbl.extend(1);
          l_subtype_tbl(l_subtype_tbl.count) := l_dep_rec2.relationship_subtype;
          l_lag_days_tbl.extend(1);
          l_lag_days_tbl(l_lag_days_tbl.count) := l_dep_rec2.lag_day;
        END IF;

      END LOOP;
      Close get_dependency2;

      end if; -- Fix for Bug # 4354217.

    ELSE
      --use get_struc_dependency to populate table

      --debug messages added while fixing bug 5067296
       IF (l_debug_mode = 'Y') THEN
          pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'Before opening cursor get_struc_dependency', x_Log_Level=> 3);
       END IF;
       --debug messages added while fixing bug 5067296

      OPEN get_struc_dependency;
      LOOP
        FETCH get_struc_dependency bulk collect INTO l_suc_ver_id_tbl, l_pred_ver_id_tbl, l_pred_proj_id_tbl, l_subtype_tbl,
                                                     l_lag_days_tbl, l_comment_tbl LIMIT 1000;
        EXIT WHEN get_struc_dependency%NOTFOUND;
      END LOOP;
      CLOSE get_struc_dependency;

      FOR i IN 1..l_pred_proj_id_tbl.count
      LOOP
         l_suc_proj_id_tbl.extend(1);
         l_suc_proj_id_tbl(i) := l_pred_proj_id_tbl(i);
      END LOOP;

    END IF;

    --bulk insert into pa_object_relationships table
      --debug messages added while fixing bug 5067296
       IF (l_debug_mode = 'Y') THEN
          pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.COPY_INTRA_DEPENDENCY', x_Msg => 'Before BULK insert into PA_OBJECT_RELATIONSHIPS table', x_Log_Level=> 3);
       END IF;
      --debug messages added while fixing bug 5067296

    FORALL i IN 1..l_suc_ver_id_tbl.COUNT
      INSERT INTO PA_OBJECT_RELATIONSHIPS(
        OBJECT_RELATIONSHIP_ID
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE
       ,LAST_UPDATE_LOGIN
       ,RELATIONSHIP_TYPE
       ,OBJECT_TYPE_FROM
       ,OBJECT_TYPE_TO
       ,OBJECT_ID_FROM1
       ,OBJECT_ID_TO1
       ,OBJECT_ID_FROM2
       ,OBJECT_ID_TO2
       ,LAG_DAY
       ,RELATIONSHIP_SUBTYPE
       ,COMMENTS
       ,RECORD_VERSION_NUMBER
      )
      VALUES (
        pa_object_relationships_s.nextval
       ,FND_GLOBAL.USER_ID
       ,sysdate
       ,FND_GLOBAL.USER_ID
       ,sysdate
       ,FND_GLOBAL.USER_ID
       ,'D'
       ,'PA_TASKS'
       ,'PA_TASKS'
       ,l_suc_ver_id_tbl(i)
       ,l_pred_ver_id_tbl(i)
       ,l_suc_proj_id_tbl(i)
       ,l_pred_proj_id_tbl(i)
       ,l_lag_days_tbl(i)
       ,l_subtype_tbl(i)
       ,l_comment_tbl(i)
       ,1
      );

--end bug 4153377


/*
    For i IN 1..P_Source_Ver_Tbl.Count Loop

      --bug 3975527
      --if dependency exists, then enter second loop
      OPEN check_intra_dep_exists(p_source_ver_tbl(i));
      FETCH check_intra_dep_exists INTO l_dummy;
      IF check_intra_dep_exists%FOUND THEN
      --end bug 3975527

      For j IN 1..P_Source_Ver_Tbl.Count Loop
        -- Fetch the dependency Object Task ID
        -- Scan thru all the Source Version Object IDs
        OPEN get_dependency(p_source_ver_tbl(i), p_source_ver_tbl(j));
        FETCH get_dependency INTO l_dependency_rec;
        l_found_flag := 0;
        IF (get_dependency%FOUND) THEN
          --check if copying to same structure version; bug 3625037
          OPEN get_parent_struc_ver_id(p_destin_ver_tbl(i));
          FETCH get_parent_struc_ver_id INTO l_parent_ver_id1, l_project_id1;
          CLOSE get_parent_struc_ver_id;

          OPEN get_parent_struc_ver_id(p_destin_ver_tbl(j));
          FETCH get_parent_struc_ver_id INTO l_parent_ver_id2, l_project_id2;
          CLOSE get_parent_struc_ver_id;

          IF (l_parent_ver_id1 = l_parent_ver_id2) THEN
            l_found_flag := 1;
          END IF;

        END IF;
        CLOSE get_dependency;

        IF l_found_flag = 1 THEN

          PA_Relationship_Pvt.Create_dependency (
              p_src_proj_id         => l_project_id1
             ,p_src_task_ver_id     => p_destin_ver_tbl(i)
             ,p_dest_proj_id        => l_project_id2
             ,p_dest_task_ver_id    => p_destin_ver_tbl(j)
             ,p_type                => l_dependency_rec.relationship_subtype
             ,p_lag_days            => l_dependency_rec.lag_day/(10*60*8)
             ,p_comments            => l_dependency_rec.comments
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
            );

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
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
          END IF;
        END IF; --if found
      End Loop;

      END IF;
      CLOSE check_intra_dep_exists;
      --end bug 3975527
      -- End of Looping thru predecessor IDs
    End Loop;
    -- End of Looping thru successor IDs

    ELSE
      --bug 4019845: publishing changes; copy entire structure version
      open get_struc_dependency;
      LOOP
        FETCH get_struc_dependency INTO l_dep_struc_rec;
        EXIT WHEN get_struc_dependency%NOTFOUND;

        PA_Relationship_Pvt.Create_dependency (
              p_src_proj_id         => l_dep_struc_rec.project_id
             ,p_src_task_ver_id     => l_dep_struc_rec.dest_task_ver_id
             ,p_dest_proj_id        => l_dep_struc_rec.project_id
             ,p_dest_task_ver_id    => l_dep_struc_rec.dest_pred_ver_id
             ,p_type                => l_dep_struc_rec.relationship_subtype
             ,p_lag_days            => l_dep_struc_rec.lag_day/(10*60*8)
             ,p_comments            => l_dep_struc_rec.comments
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
          );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
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
          close get_struc_dependency;
          raise FND_API.G_EXC_ERROR;
        END IF;
      END Loop;
      close get_struc_dependency;
    END IF;
    --end bug 4019845
*/

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION -- 4537865
  WHEN  FND_API.G_EXC_ERROR THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                              p_procedure_name => 'Copy_Intra_Dependency',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

  End Copy_Intra_Dependency;

/* Bug #: 3305199 SMukka Start of Fix                                              */
/* Commented the following procedure code and rewritten the logic for procedure    */
/* Copy_Inter_Project_Dependency                                                   */
  /*Procedure Copy_Inter_Project_Dependency ( */
  /* Bug #: 3305199 SMukka                                                         */
  /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
  /*	P_Source_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
  /*    P_Destin_Ver_Tbl          IN      PA_PLSQL_DATATYPES.IdTabTyp,             */
/*	P_Source_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	P_Destin_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	X_Return_Status           OUT     VARCHAR2,
	X_Msg_Count               OUT     NUMBER,
	X_Msg_Data                OUT     VARCHAR2
  ) IS

  l_Found_Flag		NUMBER;
  l_Object_Task_ID	NUMBER;

  l_src_proj_id         NUMBER;
  l_src_task_ver_id     NUMBER;
  l_dest_proj_id        NUMBER;
  l_dest_task_ver_id    NUMBER;
  l_Type                VARCHAR2(100);
  l_lag_days    	NUMBER;
  l_comments		VARCHAR2(240);

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

  Begin
    For i IN 1..P_Source_Ver_Tbl.Count Loop
      -- Fetch the dependency Object Task ID
      l_Found_Flag := 0;
      Begin
        Select 1, Object_ID_TO1,
	       Object_ID_From2, Object_ID_From1, Object_ID_To2, Object_ID_To1,
	       Relationship_SubType, Lag_Day, Comments
	INTO   l_Found_Flag, l_Object_Task_ID,
	       l_src_proj_id, l_src_task_ver_id, l_dest_proj_id, l_dest_task_ver_id,
	       l_Type, l_lag_days, l_comments
        From   PA_Object_Relationships
        Where  RELATIONSHIP_TYPE = 'D'
        And    OBJECT_ID_TO2 <> OBJECT_ID_FROM2
        And    OBJECT_ID_FROM1 = P_Source_Ver_Tbl(i);
        Exception When No_Data_Found then NULL;
      End;

      If l_Found_Flag = 1 Then
        -- Scan thru all the Source Version Object IDs
        For j IN 1..P_Destin_Ver_Tbl.Count Loop
	  If l_Object_Task_ID = P_Destin_Ver_Tbl(j) Then
            PA_Relationship_Pvt.Create_dependency (
              p_src_proj_id         => l_src_proj_id
             ,p_src_task_ver_id     => l_src_task_ver_id
             ,p_dest_proj_id        => l_dest_proj_id
             ,p_dest_task_ver_id    => l_dest_task_ver_id
             ,p_type                => l_Type
             ,p_lag_days            => l_Lag_Days
             ,p_comments            => l_Comments
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
            );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
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
            END IF;
 	  End If;
        End Loop;
        -- End of Looping thru destination IDs
      End If;

    End Loop;
    -- End of Looping thru Source IDs

  End Copy_Inter_Project_Dependency;*/


Procedure Copy_Inter_Project_Dependency (
	P_Source_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	P_Destin_Ver_Tbl          IN      SYSTEM.pa_num_tbl_type,
	X_Return_Status           OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_Msg_Count               OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
	X_Msg_Data                OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS
--
  l_Found_Flag		NUMBER;
  l_Object_Task_ID	NUMBER;
--
  l_src_proj_id         NUMBER;
  l_src_task_ver_id     NUMBER;
  l_dest_proj_id        NUMBER;
  l_dest_task_ver_id    NUMBER;
  l_Type                VARCHAR2(100);
  l_lag_days    	NUMBER;
  l_comments		VARCHAR2(240);
--
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);
--
  CURSOR get_dependency(c_suc_ver_id NUMBER) IS
    select *
   From PA_Object_Relationships
  Where RELATIONSHIP_TYPE = 'D'
    and object_type_from = 'PA_TASKS'
    and object_type_to = 'PA_TASKS'
    And OBJECT_ID_TO2 <> OBJECT_ID_FROM2
    and object_id_from1 = c_suc_ver_id;
  l_dependency_rec get_dependency%ROWTYPE;
--
  Begin
    For i IN 1..P_Source_Ver_Tbl.Count Loop
        -- Scan thru all the Source Version Object IDs
        OPEN get_dependency(p_source_ver_tbl(i));
        FETCH get_dependency INTO l_dependency_rec;
        l_found_flag := 0;
        IF (get_dependency%FOUND) THEN
          l_found_flag := 1;
        END IF;
        CLOSE get_dependency;
--
        IF l_found_flag = 1 THEN
           SELECT project_id
	     INTO l_src_proj_id
             FROM pa_proj_element_versions ppev
            WHERE ppev.element_version_id = p_destin_ver_tbl(i);
--
	  PA_Relationship_Pvt.Create_dependency (
              p_src_proj_id         => l_src_proj_id
             ,p_src_task_ver_id     => p_destin_ver_tbl(i)
             ,p_dest_proj_id        => l_dependency_rec.object_id_to2
             ,p_dest_task_ver_id    => l_dependency_rec.object_id_to1
             ,p_type                => l_dependency_rec.relationship_subtype
             ,p_lag_days            => l_dependency_rec.lag_day/*(10*60*8)*/  --bug 8583608
             ,p_comments            => l_dependency_rec.comments
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
            );
          -- 4537865 : This is wrong.Check shud be made against x_return_status  :
	  --  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
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
          END IF;
        END IF; --if found
    End Loop;
    -- End of Looping thru successor IDs
--
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
 EXCEPTION -- 4537865
  WHEN  FND_API.G_EXC_ERROR THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                              p_procedure_name => 'Copy_Inter_Project_Dependency',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

End Copy_Inter_Project_Dependency;
/*Bug :3305199 End Of Fix                                                   */


  Procedure Publish_Inter_Proj_Dep (
    P_Publishing_Struc_Ver_ID   IN     NUMBER,
    P_Previous_Pub_Struc_Ver_ID IN     NUMBER,
    P_Published_Struc_Ver_ID    IN     NUMBER,
    X_Return_Status             OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    X_Msg_Count                 OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
    X_Msg_Data                  OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )IS

    CURSOR Check_Prev_Ver_Exists IS
      Select rel.object_relationship_id, rel.Record_Version_Number
      From pa_object_relationships rel,
           pa_proj_element_versions ppev1
      Where rel.relationship_type = 'D'
      and  rel.object_id_from1 = ppev1.element_version_id
      and  rel.object_id_to2 <> rel.object_id_from2
      and  ppev1.parent_structure_version_id = P_Previous_Pub_Struc_Ver_ID;
/*  --bug 3970398
      Select rel.object_relationship_id, rel.Record_Version_Number
      From pa_object_relationships rel,
           pa_proj_element_versions ppev1,
	   pa_proj_element_versions ppev2
      Where rel.relationship_type = 'D'
      and  rel.object_id_from1 = ppev1.element_version_id
      and  rel.object_id_to1 = ppev2.element_version_id
      and  rel.object_id_to2 <> rel.object_id_from2
      and  ppev1.parent_structure_version_id = P_Previous_Pub_Struc_Ver_ID
						-- <PREVIOUS PUBLISHED VERSION ID>
      and Not Exists (
	Select 1
	From pa_object_relationships rel2,
	     pa_proj_element_versions ppev3,
	     pa_proj_element_versions ppev4
	where rel2.relationship_type = 'D'
        and   rel2.object_id_to2 <> rel2.object_id_from2
	and   rel.object_id_from1 = ppev3.element_version_id
	and   rel.object_id_to1 = ppev4.element_version_id
	and   rel.object_id_from1 = ppev1.element_version_id
	and   rel.object_id_to1 = ppev2.element_version_id
	and   ppev3.parent_structure_version_id = P_Publishing_Struc_Ver_ID);
					-- <PUBLISHING STRUCTURE VERSION ID> );
*/

    -- If previous published version is NULL OR NOT NULL
    -- for creating inter project dependency on new published structure
    CURSOR Create_Proj_Depend (c_Version_ID  NUMBER)IS
      select ppev2.element_version_id, ppev2.project_id,
	   rel1.object_id_to1, rel1.object_id_to2, rel1.lag_day, rel1.comments,
	   rel1.relationship_subtype
      from pa_object_relationships rel1,
     	   pa_proj_element_versions ppev,
	   pa_proj_element_versions ppev2
      where rel1.relationship_type = 'D'
      and rel1.object_id_to2 <> rel1.object_id_from2
      and rel1.object_id_from1 = ppev.element_version_id
      and ppev.project_id = ppev2.project_id
      and ppev.proj_element_id = ppev2.proj_element_id
      and ppev.parent_structure_version_id = c_Version_ID
						-- <PUBLISHING STRUCTURE VERSION ID>
      and ppev2.parent_structure_version_id = P_Published_Struc_Ver_ID;
						-- <PUBLISHED STRUCTURE VERSION ID>

    -- If published version is NULL or NOT NULL
    -- To Update successors dependencies:
    CURSOR Update_Publ_Ver IS
      select distinct rel1.object_id_from1, rel1.object_id_from2 -- Fix for Bug # 4349093.
	     , ppev2.element_version_id, ppev2.project_id
             ,rel1.lag_day, rel1.comments, rel1.relationship_subtype
	     -- , rel1.object_relationship_id -- Fix for Bug # 4349093.
             , rel1.record_version_number
      from pa_object_relationships rel1,
     	   pa_proj_element_versions ppev,
	   pa_proj_element_versions ppev2
      where rel1.relationship_type = 'D'
      and rel1.object_id_to2 <> rel1.object_id_from2
      and rel1.object_id_to1 = ppev.element_version_id
      and ppev.project_id = ppev2.project_id
      and ppev.proj_element_id = ppev2.proj_element_id
      and ppev.parent_structure_version_id IN (P_Publishing_Struc_Ver_ID, P_Previous_Pub_Struc_Ver_ID)
      and ppev2.parent_structure_version_id = P_Published_Struc_Ver_ID;
      l_del_obj_rel_id NUMBER;

/*  --bug 3970398
      Select rel1.object_id_from1, rel1.object_id_from2,
             rel1.object_id_to1, rel1.object_id_to2,
	     ppev2.element_version_id,
	     ppev2.project_id, rel1.lag_day, rel1.comments, rel1.relationship_subtype
      from pa_object_relationships rel1,
           pa_proj_element_versions ppev,
	   pa_proj_element_versions ppev2
      where rel1.relationship_type = 'D'
      and rel1.object_id_to2 <> rel1.object_id_from2
      and rel1.object_id_to1 = ppev.element_version_id
      and ppev.project_id = ppev2.project_id
      and ppev.proj_element_id = ppev2.proj_element_id
      and ppev.parent_structure_version_id = c_version_ID
					-- <PUBLISHING STRUCTURE VERSION ID>
      and ppev2.parent_structure_version_id = P_Published_Struc_Ver_ID;
					-- <PUBLISHED STRUCTURE VERSION ID>
*/
    -- For Update successors dependencies:
    -- If published version is NULL, use this SQL
    CURSOR Delete_Publ_Ver IS
      select rel.object_relationship_id, rel.Record_Version_Number
      from pa_object_relationships rel,
      pa_proj_element_versions ppev
      where rel.relationship_type = 'D'
      and   rel.object_id_from1 = ppev.element_version_id
      and   ppev.parent_structure_version_id = P_Previous_Pub_Struc_Ver_ID
				-- <PREVIOUS PUBLISHED VERSION ID, if available>
      and   rel.object_id_from2 <> rel.object_id_to2
      UNION
      select rel.object_relationship_id, rel.Record_Version_Number
      from pa_object_relationships rel,
	  pa_proj_element_versions ppev
	  where rel.relationship_type = 'D'
	  and   rel.object_id_to1 = ppev.element_version_id
	  and   ppev.parent_structure_version_id = P_Previous_Pub_Struc_Ver_ID
					-- <PREVIOUS PUBLISHED VERSION ID, if available>
	  and   rel.object_id_from2 <> rel.object_id_to2 ;

  l_src_proj_id         NUMBER;
  l_src_task_ver_id     NUMBER;
  l_dest_proj_id        NUMBER;
  l_dest_task_ver_id    NUMBER;

    l_Relationship_ID	NUMBER;
    l_Record_Ver_Number NUMBER;

    l_Version_ID	NUMBER;

    l_Element_Ver_ID	NUMBER;
    l_Project_ID	NUMBER;
    l_Sub_Type              VARCHAR2(100);
    l_Lag_Days    	NUMBER;
    l_Comments		VARCHAR2(240);
    l_Obj_ID_To1	NUMBER;
    l_Obj_ID_To2 	NUMBER;
    l_Obj_ID_From1	NUMBER;
    l_Obj_ID_From2	NUMBER;

    -- l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

    l_Object_Relationship_ID	NUMBER;

  Begin

    --------------------------------- Begin of Step 1
    If P_Previous_Pub_Struc_Ver_ID IS NOT NULL  Then
      Open  Check_Prev_Ver_Exists;

      LOOP

        Fetch Check_Prev_Ver_Exists
        INTO  l_Relationship_ID, l_Record_Ver_Number;
        EXIT when Check_Prev_Ver_Exists%NOTFOUND;
        --Close Check_Prev_Ver_Exists;
        -- Step 1: Delete Inter project dependencies from prev published version
        --         which does not exist in publishing structure
        PA_RELATIONSHIP_PVT.Delete_Relationship (
           p_object_relationship_id   => l_Relationship_ID
          ,p_record_version_number    => l_Record_Ver_Number
          ,x_return_status            => x_return_status
          ,x_msg_count                => x_msg_count
          ,x_msg_data                 => x_msg_data
        );
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
          Close Check_Prev_Ver_Exists;
          Raise FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      Close Check_Prev_Ver_Exists;
    End If;
    --------------------------------- End of Step 1

    --------------------------------- Begin of Step 2
    l_Version_ID := P_Publishing_Struc_Ver_ID;
/*  --bug 3970398
    IF P_Previous_Pub_Struc_Ver_ID IS NULL Then
       l_Version_ID := P_Publishing_Struc_Ver_ID;
    Else
       l_Version_ID := P_Previous_Pub_Struc_Ver_ID;
    End IF;
*/

    Open  Create_Proj_Depend(l_Version_ID);
    LOOP
      Fetch Create_Proj_Depend
      INTO  l_src_task_ver_id, l_src_proj_id, l_dest_task_ver_id, l_dest_proj_id,
            l_Lag_Days, l_Comments, l_Sub_Type;
      EXIT when Create_Proj_Depend%NOTFOUND;

      l_object_relationship_id := NULL;
      PA_Object_Relationships_PKG.Insert_Row(
	 p_user_id                   => FND_GLOBAL.USER_ID
	,p_object_type_from          => 'PA_TASKS'
	,p_object_id_from1           => l_src_task_ver_id
	,p_object_id_from2           => l_src_proj_id
	,p_object_id_from3           => NULL
	,p_object_id_from4           => NULL
	,p_object_id_from5           => NULL
	,p_object_type_to            => 'PA_TASKS'
	,p_object_id_to1             => l_dest_task_ver_id
	,p_object_id_to2             => l_dest_proj_id
	,p_object_id_to3             => NULL
	,p_object_id_to4             => NULL
	,p_object_id_to5             => NULL
	,p_relationship_type         => 'D'
	,p_relationship_subtype      => l_Sub_Type
	,p_lag_day                   => l_Lag_Days
	,p_imported_lag              => NULL
	,p_priority                  => Null
	,p_pm_product_code           => NULL
	,x_object_relationship_id    => l_object_relationship_id
	,p_comments                  => l_comments
	,p_status_code               => 'PUBLISHED'
        ,x_return_status       	     => x_return_status
        -- ,x_msg_count                 => x_msg_count
        -- ,x_msg_data                  => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := FND_MSG_PUB.count_msg;
         /* IF x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_TRUE,
                 p_msg_index      => 1,
                 p_msg_count      => x_msg_count,
                 p_msg_data       => x_msg_data,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
         END IF; */
         Close Create_Proj_Depend;
         Raise FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    Close Create_Proj_Depend;
    --------------------------------- End of Step 2

    --------------------------------- Begin of Step 3
/*
    IF P_Previous_Pub_Struc_Ver_ID IS NULL Then
      l_Version_ID := P_Publishing_Struc_Ver_ID;
    Else
      l_Version_ID := P_Previous_Pub_Struc_Ver_ID;
    End IF;
*/

    Open  Update_Publ_Ver;
    LOOP
      Fetch Update_Publ_Ver
      Into  l_Obj_ID_From1, l_Obj_ID_From2, l_Obj_ID_To1, l_Obj_ID_To2,
	  l_Lag_Days, l_Comments, l_Sub_Type
	  -- , l_del_obj_rel_id -- Fix for Bug # 4349093.
	  , l_Record_Ver_Number;
/* --bug 3970398
      Into  l_Obj_ID_From1, l_Obj_ID_From2, l_Obj_ID_To1, l_Obj_ID_To2,
	  l_src_task_ver_id, l_src_proj_id, -- l_Element_Ver_ID, l_Project_ID,
	  l_Lag_Days, l_Comments, l_Sub_Type ;
*/
      EXIT WHEN Update_Publ_Ver%NOTFOUND;
/* --bug 3970398
      IF P_Previous_Pub_Struc_Ver_ID IS NULL Then
         l_dest_task_ver_id := l_Obj_ID_From1;
         l_dest_proj_id     := l_Obj_ID_From2;
      Else
         l_dest_task_ver_id := l_Obj_ID_To1;
         l_dest_proj_id     := l_Obj_ID_To2;
      End IF;
*/
      l_object_relationship_id := NULL;
      PA_Object_Relationships_PKG.Insert_Row(
	 p_user_id                   => FND_GLOBAL.USER_ID
	,p_object_type_from          => 'PA_TASKS'
	,p_object_id_from1           => l_obj_id_from1
	,p_object_id_from2           => l_obj_id_from2
	,p_object_id_from3           => NULL
	,p_object_id_from4           => NULL
	,p_object_id_from5           => NULL
	,p_object_type_to            => 'PA_TASKS'
	,p_object_id_to1             => l_obj_id_to1
	,p_object_id_to2             => l_obj_id_to2
	,p_object_id_to3             => NULL
	,p_object_id_to4             => NULL
	,p_object_id_to5             => NULL
	,p_relationship_type         => 'D'
	,p_relationship_subtype      => l_Sub_Type
	,p_lag_day                   => l_Lag_Days
	,p_imported_lag              => NULL
	,p_priority                  => Null
	,p_pm_product_code           => NULL
	,x_object_relationship_id    => l_object_relationship_id
	,p_comments                  => l_comments
	,p_status_code               => 'PUBLISHED'
        ,x_return_status       	     => x_return_status
        -- ,x_msg_count                 => x_msg_count
        -- ,x_msg_data                  => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := FND_MSG_PUB.count_msg;
         /* IF x_msg_count = 1 then
            pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_TRUE,
                 p_msg_index      => 1,
                 p_msg_count      => x_msg_count,
                 p_msg_data       => x_msg_data,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
         END IF; */
         Close Update_Publ_Ver;
         Raise FND_API.G_EXC_ERROR;
      END IF;

/*
      PA_RELATIONSHIP_PVT.Delete_Relationship (
           p_object_relationship_id   => l_del_obj_rel_id
          ,p_record_version_number    => l_Record_Ver_Number
          ,x_return_status            => x_return_status
          ,x_msg_count                => x_msg_count
          ,x_msg_data                 => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := FND_MSG_PUB.count_msg;
         Close Update_Publ_Ver;
         Raise FND_API.G_EXC_ERROR;
      END IF;
*/

    END LOOP;
    Close Update_Publ_Ver;
    --------------------------------- End of Step 3
/*--bug 3970398
    Open  Delete_Publ_Ver;
    Loop
      l_Relationship_ID   := NULL;
      l_Record_Ver_Number := NULL;
      Fetch Delete_Publ_Ver
        INTO  l_Relationship_ID, l_Record_Ver_Number;
      Exit When Delete_Publ_Ver%NOTFOUND;
      PA_RELATIONSHIP_PVT.Delete_Relationship (
           p_object_relationship_id   => l_Relationship_ID
          ,p_record_version_number    => l_Record_Ver_Number
          ,x_return_status            => x_return_status
          ,x_msg_count                => x_msg_count
          ,x_msg_data                 => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_msg_count := FND_MSG_PUB.count_msg;
         IF x_msg_count = 1 Then
            pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_TRUE,
                 p_msg_index      => 1,
                 p_msg_count      => x_msg_count,
                 p_msg_data       => x_msg_data,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
         END IF;
         Raise FND_API.G_EXC_ERROR;
      END IF;
    End Loop;
    Close Delete_Publ_Ver;
*/
  EXCEPTION -- 4537865
  WHEN  FND_API.G_EXC_ERROR THEN
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                              p_procedure_name => 'Copy_Intra_Dependency',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

  End Publish_Inter_Proj_Dep;
--
PROCEDURE Insert_Subproject_Association( p_init_msg_list           IN  VARCHAR2    := FND_API.G_TRUE
                                        ,p_commit                  IN  VARCHAR2    := FND_API.G_FALSE
                                        ,p_validate_only           IN  VARCHAR2    := FND_API.G_TRUE
                                        ,p_validation_level        IN  VARCHAR2    := 100
                                        ,p_calling_module          IN  VARCHAR2    := 'SELF_SERVICE'
                                        ,p_debug_mode              IN  VARCHAR2    := 'N'
                                        ,p_max_msg_count           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                                        ,p_src_proj_id             IN  NUMBER
                                        ,p_src_struc_wp_or_fin     IN  VARCHAR2
                                        ,p_src_struc_elem_id       IN  NUMBER
                                        ,p_src_struc_elem_ver_id   IN  NUMBER
                                        ,p_dest_proj_id            IN  NUMBER
                                        ,p_dest_struc_elem_id      IN  NUMBER
                                        ,p_dest_struc_elem_ver_id  IN  NUMBER
                                        ,p_src_task_elem_id        IN  NUMBER
                                        ,p_src_task_elem_ver_id    IN  NUMBER
                                        ,p_lnk_task_name_number    IN  VARCHAR2  --SMukka
                                        ,p_relationship_type       IN  VARCHAR2
					,p_comment                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR  --Bug No 3668113
                                        ,x_lnk_task_elem_id        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_lnk_task_elem_ver_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_object_relationship_id  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_pev_schedule_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                        ,x_msg_data                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        )
IS
    l_msg_index_out       NUMBER;
--    l_msg_count           NUMBER;
--    l_msg_data            VARCHAR2(250);
    l_data                VARCHAR2(2000);
    l_scheduled_start_date DATE:= sysdate;
    l_scheduled_finish_date DATE:= sysdate;
    l_upd_prog_grp_status  NUMBER:=0;
    l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();
    l_sharing_code VARCHAR2(30);

--bug 4296915
  CURSOR check_child_pub
  IS
    SELECT 'x'
      FROM pa_proj_elem_ver_structure
     WHERE project_id=p_dest_proj_id
       AND element_version_id = p_dest_struc_elem_ver_id
       AND status_code = 'STRUCTURE_PUBLISHED'
       ;
     l_dummy    VARCHAR2(1);
--end bug 4296915

-- Bug # 4329284.

cursor cur_proj_name (c_project_id NUMBER) is
select ppa.name
from pa_projects_all ppa
where ppa.project_id = c_project_id;

l_proj_name VARCHAR2(30);
l_prog_name VARCHAR2(30);

-- Bug # 4329284.

BEGIN
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Insert_Subproject_Association begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Insert_Subproject_Association;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Performing validations');
       pa_debug.debug('PA_TASK_PUB1.CREATE_TASK Src Proj Id => '||p_src_proj_id);
       pa_debug.debug('PA_TASK_PUB1.CREATE_TASK Src Structure Elem Id=> '||p_src_struc_elem_id);
       pa_debug.debug('PA_TASK_PUB1.CREATE_TASK Src Structure Elem Ver Id => '||p_src_struc_elem_ver_id);
       pa_debug.debug('Before PA_TASK_PUB1.CREATE_TASK Linking Task Name Number => '||p_lnk_task_name_number);
    END IF;
--
    /* Creating linking task in the pa_proj_elements table*/
    PA_TASK_PUB1.CREATE_TASK
        ( p_validate_only          => FND_API.G_FALSE
         ,p_object_type            => 'PA_TASKS'
         ,p_project_id             => p_src_proj_id
         ,p_structure_id           => p_src_struc_elem_id     --Proj_element_id of the parent structure
         ,p_ref_task_id            => p_src_task_elem_id      --proj_element_id of the ref task
         ,p_peer_or_sub            => 'SUB'
         ,p_structure_version_id   => p_src_struc_elem_ver_id
         ,p_task_number            => substr(p_lnk_task_name_number,0,25)
         ,p_task_name              => substr(p_lnk_task_name_number,0,240)
         ,p_task_manager_id        => NULL
         ,p_task_manager_name      => NULL
         ,p_link_task_flag         => 'Y'
         ,x_task_id                => x_lnk_task_elem_id
         ,x_return_status          => x_return_status
         ,x_msg_count              => x_msg_count
         ,x_msg_data               => x_msg_data);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
--
    --Added the following code
    -- Modified from substr(x_lnk_task_elem_id,-1,1) to x_lnk_task_elem_id for bug #4480013
    UPDATE PA_PROJ_ELEMENTS
       SET ELEMENT_NUMBER = substr(p_lnk_task_name_number,0,25)||x_lnk_task_elem_id
     WHERE PROJ_ELEMENT_ID = x_lnk_task_elem_id;
     IF SQL%NOTFOUND THEN
         x_return_status:=FND_API.G_RET_STS_ERROR;
     END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('After Call To PA_TASK_PUB1.CREATE_TASK Return Status => '||x_return_status);
       pa_debug.debug('After Call To PA_TASK_PUB1.CREATE_TASK => '||x_lnk_task_elem_id);
       pa_debug.debug('PA_TASK_PUB1.CREATE_TASK_VERSION Src Structure Elem Id=> '||p_src_task_elem_ver_id);
       pa_debug.debug('PA_TASK_PUB1.CREATE_TASK_VERSION Linking Task Elem Id => '||x_lnk_task_elem_id);
    END IF;
--
    /* Creating linking task in the pa_proj_element_versions and pa_object_relationships table  */
    /* This API call create task in pa_proj_element_versions and creates relationship between   */
    /* linking task and its parent task in the pa_object_relationships table                    */
    PA_TASK_PUB1.CREATE_TASK_VERSION
        ( p_validate_only        => FND_API.G_FALSE
         ,p_validation_level     => 0
         ,p_ref_task_version_id  => p_src_task_elem_ver_id
         ,p_peer_or_sub          => 'SUB'
         ,p_task_id              => x_lnk_task_elem_id
         ,x_task_version_id      => x_lnk_task_elem_ver_id
         ,x_return_status        => x_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('After Call To PA_TASK_PUB1.CREATE_TASK_VERSION Return Status => '||x_return_status);
       pa_debug.debug('After Call To PA_TASK_PUB1.CREATE_TASK_VERSION Linking Task Elem Id => '||x_lnk_task_elem_id);
       pa_debug.debug('After Call To PA_TASK_PUB1.CREATE_TASK_VERSION Linking Task Elem Ver Id=> '||x_lnk_task_elem_ver_id);
       pa_debug.debug('PA_TASK_PUB1.Create_Schedule_Version Linking Task Elem Ver Id=> '||x_lnk_task_elem_ver_id);
    END IF;
--
    --bug 4279634
    --set chargeable to N
    l_sharing_code := PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_src_proj_id);

-- Begin fix for Bug # 4490532.
-- Modifications to allow the collection of progress on those tasks in the parent project
-- that have sub-projects linked to them.

/*  Begin commenting out the code to set the chargeable_flag to 'N'.

    IF (l_sharing_code = 'SHARE_FULL')
       OR (l_sharing_code = 'SHARE_PARTIAL') THEN
      IF PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_src_proj_id) = 'Y' THEN
        --IF no publishing version, set flag to N
        IF 'N' = PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(p_src_proj_id, p_src_struc_elem_id) THEN
          UPDATE PA_TASKS
          SET
          CHARGEABLE_FLAG = 'N',
          RECORD_VERSION_NUMBER = nvl(RECORD_VERSION_NUMBER,0)+1,
          last_updated_by = FND_GLOBAL.USER_ID,
          last_update_login = FND_GLOBAL.USER_ID,
          last_update_date = sysdate
          WHERE TASK_ID = p_src_task_elem_id;
        END IF;
      ELSE
        --set flag to N
        UPDATE PA_TASKS
        SET
        CHARGEABLE_FLAG = 'N',
        RECORD_VERSION_NUMBER = nvl(RECORD_VERSION_NUMBER,0)+1,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_login = FND_GLOBAL.USER_ID,
        last_update_date = sysdate
        WHERE TASK_ID = p_src_task_elem_id;
      END IF;
    ELSE --not share, check if financial only
      IF p_src_struc_wp_or_fin = 'FINANCIAL' THEN
        --set flag to N
        UPDATE PA_TASKS
        SET
        CHARGEABLE_FLAG = 'N',
        RECORD_VERSION_NUMBER = nvl(RECORD_VERSION_NUMBER,0)+1,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_login = FND_GLOBAL.USER_ID,
        last_update_date = sysdate
        WHERE TASK_ID = p_src_task_elem_id;
      END IF;
    END IF;

End commenting out the code to set the chargeable_flag to 'N'. */

-- End fix for Bug # 4490532.

    --end bug 4279634

    /* Create recrod into work pa_proj_elem_ver_schedule table for workplan structure only*/
    IF p_src_struc_wp_or_fin = 'WORKPLAN' THEN
       PA_TASK_PUB1.Create_Schedule_Version
           ( p_validate_only           =>FND_API.G_FALSE
            ,p_element_version_id      =>x_lnk_task_elem_ver_id  --task version of linking task
            ,p_scheduled_start_date    =>l_scheduled_start_date
            ,p_scheduled_end_date      =>l_scheduled_finish_date
            ,x_pev_schedule_id	       =>x_pev_schedule_id
            ,x_return_status	       =>x_return_status
            ,x_msg_count	       =>x_msg_count
            ,x_msg_data	               =>x_msg_data
           );
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('new workplan attr for task after call to PA_TASK_PUB1.Create_Schedule_Version=> '||x_pev_schedule_id);
       END IF;
--
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_msg_count := FND_MSG_PUB.count_msg;
          IF x_msg_count = 1 THEN
             pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => x_msg_count,
                p_msg_data       => x_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('After Call To PA_TASK_PUB1.Create_Schedule_Version Return Status => '||x_return_status);
       pa_debug.debug('PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW Linking Task Elem Ver Id => '||x_lnk_task_elem_ver_id);
       pa_debug.debug('PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW Src Proj Id=> '||p_src_proj_id);
       pa_debug.debug('PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW Dest Struc Elem Ver Id=> '||p_dest_struc_elem_ver_id);
       pa_debug.debug('PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW Dest Proj Id=> '||p_dest_proj_id);
    END IF;
--
    /* This API call create relationship between linking task and destination structure vesion */
    /* in the pa_object_relationships table                                                    */
    PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
         p_user_id => FND_GLOBAL.USER_ID
        ,p_object_type_from => 'PA_TASKS'
        ,p_object_id_from1 => x_lnk_task_elem_ver_id
        ,p_object_id_from2 => p_src_proj_id
        ,p_object_id_from3 => NULL
        ,p_object_id_from4 => NULL
        ,p_object_id_from5 => NULL
        ,p_object_type_to => 'PA_STRUCTURES'
        ,p_object_id_to1 => p_dest_struc_elem_ver_id
        ,p_object_id_to2 => p_dest_proj_id
        ,p_object_id_to3 => NULL
        ,p_object_id_to4 => NULL
        ,p_object_id_to5 => NULL
        ,p_relationship_type => p_relationship_type
        ,p_relationship_subtype => NULL
        ,p_lag_day => NULL
        ,p_imported_lag => NULL
        ,p_priority => NULL
        ,p_pm_product_code => NULL
        ,x_object_relationship_id => x_object_relationship_id
        ,x_return_status      => x_return_status
--        ,p_comments           => null
        ,p_comments           => p_comment               --Bug No 3668113
        ,p_status_code        => null
        );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_msg_count := FND_MSG_PUB.count_msg;
       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
--
/* 4541039
    --bug 4238036
    IF p_src_struc_wp_or_fin = 'WORKPLAN' THEN
      l_tasks_ver_ids.extend(1);
      l_tasks_ver_ids(1) := p_src_task_elem_ver_id;

      --bug 4296915  do not rollup from working to working structure version.
      IF p_dest_struc_elem_ver_id IS NOT NULL
      THEN
        OPEN check_child_pub;
        FETCH check_child_pub INTO l_dummy;
        IF check_child_pub%FOUND
        THEN
        --end bug 4296915
          PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject(
            p_debug_mode => p_debug_mode,
            p_element_versions => l_tasks_ver_ids,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_msg_count := FND_MSG_PUB.count_msg;
           IF x_msg_count = 1 THEN
              pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => x_msg_count,
                p_msg_data       => x_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
                x_msg_data := l_data;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
--bug 4296915
        END IF;
        CLOSE check_child_pub;
       END IF;
--bug 4296915

    END IF;
    --end bug 4238036
end bug 4541039 */

    --Bug No 3450684
    BEGIN
        IF p_validation_level > 0 THEN
           l_upd_prog_grp_status:=PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS(x_object_relationship_id,
                                                                           'ADD');
           IF  l_upd_prog_grp_status < 0 THEN

               -- Bug # 4329284.

               open cur_proj_name(p_src_proj_id);
               fetch cur_proj_name into l_prog_name;
               close cur_proj_name;

               open cur_proj_name(p_dest_proj_id);
               fetch cur_proj_name into l_proj_name;
               close cur_proj_name;

               -- Bug # 4329284.

	       PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
               RAISE FND_API.G_EXC_ERROR;
           END IF;
           IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Return Status PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS=> '||l_upd_prog_grp_status);
           END IF;
        END IF;
    EXCEPTION

	-- Begin fix for Bug # 4485908.

	WHEN FND_API.G_EXC_ERROR THEN

		RAISE FND_API.G_EXC_ERROR;

	-- End fix for Bug # 4485908.

        WHEN OTHERS THEN
             fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                                     p_procedure_name => 'Insert_Subproject_Association',
                                     p_error_text     => SUBSTRB('PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS:'||SQLERRM,1,240));
         RAISE FND_API.G_EXC_ERROR;
    END;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('After Call To PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW Return Status => '||x_return_status);
    END IF;
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_RELATIONSHIP_PVT.Insert_Subproject_Association END');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Insert_Subproject_Association;
      END IF;
            -- RESET OUT PARAMS 4537865
      x_lnk_task_elem_id       := NULL ;
      x_lnk_task_elem_ver_id   := NULL ;
      x_object_relationship_id := NULL ;
      x_pev_schedule_id        := NULL;

      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Insert_Subproject_Association;
      END IF;
            -- RESET OUT PARAMS 4537865
      x_lnk_task_elem_id       := NULL ;
      x_lnk_task_elem_ver_id   := NULL ;
      x_object_relationship_id := NULL ;
      x_pev_schedule_id        := NULL;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'Insert_Subproject_Association',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
END Insert_Subproject_Association;
--
--
--
-- API name                      : Create_Subproject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_api_version                 IN   NUMBER      :=1.0
-- p_init_msg_list	         IN   VARCHAR2	:=FND_API.G_TRUE
-- p_validate_only	         IN   VARCHAR2	:=FND_API.G_TRUE
-- p_validation_level            IN   NUMBER      :=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module              IN   VARCHAR2	:='SELF_SERVICE'
-- p_commit	                 IN   VARCHAR2	:=FND_API.G_FALSE
-- p_debug_mode	                 IN   VARCHAR2	:='N'
-- p_max_msg_count               IN   NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_src_proj_id                 IN   pa_projects_all.project_id%type
-- p_task_ver_id                 IN   pa_proj_element_versions.element_version_id%type
-- p_dest_proj_id                IN   pa_projects_all.project_id%type
-- p_dest_proj_name              IN   pa_projects_all.name%type
-- p_comment                     IN   pa_object_relationships.comments%type
-- x_return_status               OUT  VARCHAR2
-- x_msg_count                   OUT  NUMBER
-- x_msg_data                    OUT  VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
-- 03-DEC-2008   rkartha   Bug#7427161: Modified the declaration of l_task_name with PA_PROJ_ELEMENTS.NAME%TYPE
--                                      so as to avoid the numeric or value error.
--
Procedure Create_Subproject_Association(p_api_version	   IN	NUMBER	        :=1.0,
                                        p_init_msg_list	   IN	VARCHAR2	:=FND_API.G_TRUE,
                                        p_validate_only	   IN	VARCHAR2	:=FND_API.G_TRUE,
--                                        p_validation_level IN	NUMBER	        :=FND_API.G_VALID_LEVEL_FULL,
                                        p_validation_level IN   VARCHAR2        := 100,
                                        p_calling_module   IN	VARCHAR2	:='SELF_SERVICE',
                                        p_commit	   IN	VARCHAR2	:=FND_API.G_FALSE,
                                        p_debug_mode	   IN	VARCHAR2	:='N',
                                        p_max_msg_count	   IN	NUMBER	        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_src_proj_id      IN   pa_projects_all.project_id%type,
                                        p_task_ver_id      IN   pa_proj_element_versions.element_version_id%type,
                                        p_dest_proj_id     IN   pa_projects_all.project_id%type,
                                        p_dest_proj_name   IN   pa_projects_all.name%type,
                                        p_comment          IN   pa_object_relationships.comments%type,
                                        x_return_status    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count        OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data         OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   l_src_proj_sharing_code            pa_projects_all.structure_sharing_code%type;
   l_dest_proj_sharing_code           pa_projects_all.structure_sharing_code%type;
--
   l_src_struc_elem_id                pa_proj_elements.proj_element_id%type;
   l_src_struc_elem_ver_id            pa_proj_element_versions.element_version_id%type;
   l_src_task_elem_id                 pa_proj_elements.proj_element_id%type;
   l_src_task_financial_flag          pa_proj_element_versions.financial_task_flag%type;
--
   l_dest_fin_str_ver_id              pa_proj_element_versions.element_version_id%type:=0;
   l_dest_wp_str_ver_id               pa_proj_element_versions.element_version_id%type:=0;
   l_dest_wp_struct_element_id        pa_proj_elements.proj_element_id%type:=0;
   l_dest_fin_struct_element_id       pa_proj_elements.proj_element_id%type:=0;
--
   l_parent_strucutre_version_id      pa_proj_element_versions.element_version_id%type;
--
   l_src_str_fin_enable_fl            CHAR(1):='N';
   l_src_str_wp_enable_fl             CHAR(1):='N';
   l_row_id                           VARCHAR2(100);
--
   l_lnk_task_elem_id                 number;
   l_lnk_task_elem_ver_id             pa_proj_element_versions.element_version_id%type;
   l_pev_schedule_id                  number;
   l_task_name_number                 varchar2(240);
   l_msg_count                        NUMBER;
   l_msg_data                         varchar2(250);
   l_data                             VARCHAR2(2000);
   l_msg_index_out                    NUMBER;
   x_object_relationship_id           pa_object_relationships.object_relationship_id%type;

   l_time_phase1                      VARCHAR2(1);
   l_time_phase2                      VARCHAR2(1);

   --bug 4297370
    CURSOR cur_period_duration(cp_project_id NUMBER)
    IS
    SELECT imp.period_set_name pa_period_set_name
          ,imp.pa_period_type
          , sob.period_set_name gl_period_set_name
          , sob.accounted_period_type
    FROM
    pa_implementations_all imp
    , pa_projects_all prj
    , gl_sets_of_books sob
    WHERE 1=1
    AND prj.org_id = imp.org_id --MOAC Changes: Bug 4363092: removed nvl usage with org_id
    AND prj.project_id = cp_project_id
    AND sob.set_of_books_id = imp.set_of_books_id
    ;

    l_src_period_duration  cur_period_duration%ROWTYPE;
    l_dest_period_duration  cur_period_duration%ROWTYPE;
    --end 4297370

--bug 4370533 --Issue #3
l_dest_published_wp_str_id   NUMBER;
--bug 4370533 --Issue #3
l_create_relationship_ok VARCHAR2(1):='Y';--4473103

-- Bug # 4329284.

cursor cur_proj_name (c_project_id NUMBER) is
select ppa.name
from pa_projects_all ppa
where ppa.project_id = c_project_id;

cursor cur_task_name (c_task_ver_id NUMBER) is
select ppe.name
from pa_proj_elements ppe, pa_proj_element_versions ppev
where ppe.project_id = ppev.project_id
and ppe.proj_element_id = ppev.proj_element_id
and ppev.element_version_id = c_task_ver_id;

l_proj_name VARCHAR2(30);
l_prog_name VARCHAR2(30);
-- l_task_name VARCHAR2(30);   /* Bug#7427161 */

l_task_name     PA_PROJ_ELEMENTS.NAME%TYPE    := NULL;  /* Bug#7427161 */

-- Bug # 4329284.

BEGIN
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_RELATIONSHIP_PVT.Create_Subproject_Association begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint Create_Subproject_Ass_pvt;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Performing validations');
       pa_debug.debug('The value of the passed src proj id=> '||p_src_proj_id);
       pa_debug.debug('The value of the passed src task ver id=> '||p_task_ver_id);
       pa_debug.debug('The value of the passed dest proj id=>'||p_dest_proj_id);
       pa_debug.debug('The value of the passed dest proj name id=> '||p_dest_proj_name);
       pa_debug.debug('The value of the passed comments=> '||p_comment);
    END IF;
--
--  Check for source structure type
    l_src_proj_sharing_code:=PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_src_proj_id);
--
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('The src project id value => '||p_src_proj_id);
       pa_debug.debug('The src project sharing code value => '||l_src_proj_sharing_code);
       pa_debug.debug('The value of src task ver id => '||p_task_ver_id);
    END IF;
--
--  l_proj_element_id = structure element id
--  l_parent_strucutre_version_id=parent structure version id
--

-- Bug # 4329284.

open cur_proj_name(p_src_proj_id);
fetch cur_proj_name into l_prog_name;
close cur_proj_name;

open cur_proj_name(p_dest_proj_id);
fetch cur_proj_name into l_proj_name;
close cur_proj_name;

open cur_task_name(p_task_ver_id);
fetch cur_task_name into l_task_name;
close cur_task_name;

-- Bug # 4329284.

    BEGIN
        SELECT ppev2.proj_element_id,
               ppev1.parent_structure_version_id,
               ppev1.FINANCIAL_TASK_FLAG,
               ppev1.proj_element_id
          INTO l_src_struc_elem_id,
               l_src_struc_elem_ver_id,
               l_src_task_financial_flag,
               l_src_task_elem_id
          FROM pa_proj_element_versions ppev1,
               pa_proj_element_versions ppev2
         WHERE ppev1.element_version_id = p_task_ver_id
           AND ppev1.object_type = 'PA_TASKS'
           AND ppev1.project_id = p_src_proj_id
           AND ppev2.element_version_id = ppev1.parent_structure_version_id
           AND ppev2.project_id = ppev2.project_id
           AND ppev2.object_type = 'PA_STRUCTURES';
    EXCEPTION
        WHEN OTHERS THEN
             RAISE;
    END;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('The src structure elem id => '||l_src_struc_elem_id);
       pa_debug.debug('The src strcuture elem version id => '||l_src_struc_elem_ver_id);
       pa_debug.debug('The value of src task financial flag => '||l_src_task_financial_flag);
       pa_debug.debug('The value of src task elem id => '||l_src_task_elem_id);
    END IF;
--
/*    IF PA_PROJECT_STRUCTURE_UTILS.get_element_struc_type(p_src_proj_id,p_task_ver_id,'PA_TASKS') = 'WORKPLAN' THEN
       l_src_str_wp_enable_fl:='Y';
    END IF;*/
--
/*    IF PA_PROJECT_STRUCTURE_UTILS.get_element_struc_type(p_src_proj_id,p_task_ver_id,'PA_TASKS') = 'FINANCIAL' THEN
       l_src_str_fin_enable_fl:='Y';
    END IF;*/
--
    IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(l_src_struc_elem_id, 'WORKPLAN')) THEN
      l_src_str_wp_enable_fl:='Y';
    END IF;

    IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Structure(l_src_struc_elem_id, 'FINANCIAL')) THEN
       l_src_str_fin_enable_fl:='Y';
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('The src str wp enable flag => '||l_src_str_wp_enable_fl);
       pa_debug.debug('The src str fin enable flag => '||l_src_str_fin_enable_fl);
    END IF;

    --Bug 3912783:
    IF (PA_RELATIONSHIP_UTILS.Check_proj_currency_identical(p_src_proj_id,p_dest_proj_id) = 'N') THEN
      -- PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_DIFF_PRJ_CURR','PROJ',l_proj_name,'TASK',l_task_name,'PROG',l_prog_name); -- Bug # 4329284.
      PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_DIFF_PRJ_CURR','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4871876.
RAISE FND_API.G_EXC_ERROR;
    END IF;
    --end bug 3912783

--
--  Check for target structure type
--  Get the latest published structure, if there is one for the given project_id(p_dest_proj_id)
--
    l_dest_proj_sharing_code:=PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(p_dest_proj_id);
--
    l_dest_fin_str_ver_id:=PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(p_dest_proj_id);
    l_dest_wp_str_ver_id:=PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(p_dest_proj_id);

--bug 4370533 --Issue #3
    l_dest_published_wp_str_id := l_dest_wp_str_ver_id;
--bug 4370533 --Issue #3

--
/*    IF l_dest_fin_str_ver_id IS NULL AND l_dest_wp_str_ver_id IS NULL THEN
       --get current working wp ver
       l_dest_wp_str_ver_id :=PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(p_dest_proj_id);
       --get only version for fin
       PA_PROJECT_STRUCTURE_UTILS.Get_Financial_Version(p_dest_proj_id,l_dest_fin_str_ver_id);
    END IF;*/

    IF l_dest_fin_str_ver_id IS NULL  THEN   --SMukka added if block
       --get only version for fin
       PA_PROJECT_STRUCTURE_UTILS.Get_Financial_Version(p_dest_proj_id,l_dest_fin_str_ver_id);

	-- Begin fix for Bug # 4426392.

       	if (l_dest_fin_str_ver_id = -1) then

		l_dest_fin_str_ver_id := null;

	end if;

	-- End fix for Bug # 4426392.

    END IF;
--
    IF l_dest_wp_str_ver_id IS NULL THEN      --SMukka added if block
       --get current working wp ver
       l_dest_wp_str_ver_id :=PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(p_dest_proj_id);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Dest WP Str Ver Id => '||l_dest_wp_str_ver_id);
    END IF;
--
--    IF l_dest_wp_str_ver_id IS NOT NULL  THEN   --Commented
    IF (l_dest_wp_str_ver_id >=0) THEN   --SMukka
       BEGIN
           SELECT proj_element_id
             INTO l_dest_wp_struct_element_id
             FROM pa_proj_element_versions
            WHERE element_version_id = l_dest_wp_str_ver_id;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               RAISE;
           WHEN OTHERS THEN
               RAISE;
       END;
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('Dest WP Str element Id => '||l_dest_wp_struct_element_id);
       END IF;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Dest FIN Str Ver Id => '||l_dest_fin_str_ver_id);
    END IF;
--
--    IF l_dest_fin_str_ver_id IS NOT NULL THEN   --SMukka
    IF (l_dest_fin_str_ver_id >= 0) THEN   --SMukka
       BEGIN
           SELECT proj_element_id
             INTO l_dest_fin_struct_element_id
             FROM pa_proj_element_versions
            WHERE element_version_id = l_dest_fin_str_ver_id;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
               RAISE;
           WHEN OTHERS THEN
               RAISE;
       END;
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('Dest FIN Str element Id => '||l_dest_fin_struct_element_id);
       END IF;
    END IF;
--
--  Create linking task
--
    --bug 4272730
    IF l_src_str_wp_enable_fl = 'Y' THEN
      l_time_phase1 := PA_FIN_PLAN_UTILS.Get_wp_bv_time_phase(l_src_struc_elem_ver_id);
      IF l_dest_wp_str_ver_id IS NOT NULL THEN
        l_time_phase2 := PA_FIN_PLAN_UTILS.Get_wp_bv_time_phase(l_dest_wp_str_ver_id);
        IF (l_time_phase1 <> l_time_phase2) THEN
	  -- PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_DIFF_TIME_PHASE','PROJ',l_proj_name,'TASK',l_task_name,'PROG',l_prog_name); -- Bug # 4329284.
	  PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_DIFF_TIME_PHASE','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4871876.
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;
    --end bug 4272730

--bug 4297370
 IF l_src_str_wp_enable_fl = 'Y'
 THEN
   OPEN cur_period_duration(p_src_proj_id);
   FETCH cur_period_duration INTO l_src_period_duration;
   CLOSE cur_period_duration;

   OPEN cur_period_duration(p_dest_proj_id);
   FETCH cur_period_duration INTO l_dest_period_duration;
   CLOSE cur_period_duration;

   IF l_time_phase1 = 'P' AND l_time_phase2 = 'P'
   THEN
      IF l_src_period_duration.pa_period_set_name <> l_dest_period_duration.pa_period_set_name OR
         l_src_period_duration.pa_period_type  <> l_dest_period_duration.pa_period_type
      THEN
	  PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_DIFF_PA_CAL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   ELSIF l_time_phase1 = 'G' AND l_time_phase2 = 'G'
   THEN
      IF l_src_period_duration.gl_period_set_name <> l_dest_period_duration.gl_period_set_name OR
         l_src_period_duration.accounted_period_type  <> l_dest_period_duration.accounted_period_type
      THEN
	  PA_UTILS.ADD_MESSAGE('PA','PA_PS_LINK_DIFF_GL_CAL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
 END IF;
--end bug 4297370

    l_task_name_number := substr(fnd_date.date_to_canonical(sysdate),0,25);
--
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Before call to Insert_Subproject_Association');
       pa_debug.debug('Before call to ISPA Src Project Id => '||p_src_proj_id);
       pa_debug.debug('Before call to ISPA Src Strcuture elem id => '||l_src_struc_elem_id);
       pa_debug.debug('Before call to ISPA Src Structure elem version id => '||l_src_struc_elem_ver_id);
       pa_debug.debug('Before call to ISPA Src Task elem id => '||l_src_task_elem_id);
       pa_debug.debug('Before call to ISPA Src Task elem version id => '||p_task_ver_id);
       pa_debug.debug('Before call to ISPA Src Task Financial Flag => '||l_src_task_financial_flag);
       pa_debug.debug('Before call to ISPA Dest Project id => '||p_dest_proj_id);
       pa_debug.debug('Before call to ISPA Linking Task element id => '||l_lnk_task_elem_id);
       pa_debug.debug('Before call to ISPA Linking Task Element Version Id => '||l_lnk_task_elem_ver_id);
       pa_debug.debug('Before call to ISPA Linking Task Name Number => '||l_task_name_number);
       pa_debug.debug('Before call to ISPA Dest wp Structure Element id => '||l_dest_wp_struct_element_id);
       pa_debug.debug('Before call to ISPA Dest wp Strcuture ver id => '||l_dest_wp_str_ver_id);
       pa_debug.debug('Before call to ISPA Dest wp Structure Element id => '||l_dest_fin_struct_element_id);
       pa_debug.debug('Before call to ISPA Dest wp Strcuture ver id => '||l_dest_fin_str_ver_id);
       pa_debug.debug('Before call to ISPA Src Structure WP Enable Flag => '||l_src_str_wp_enable_fl);
       pa_debug.debug('Before call to ISPA Dest Structure FIN Enable Flag => '||l_src_str_fin_enable_fl);
    END IF;
/* Bug 4473103 : Undone the fix for 3983361 and redo
--
--
--bug 3983361
    IF p_validation_level > 0 THEN
      IF  PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id) = 'N' THEN  --SMukka

	if (FND_MSG_PUB.count_msg = 0) then -- Fix for Bug # 4256435.

		PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.

	end if; -- Fix for Bug # 4256435.

        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
--end bug 3983361
*/

	-- 4473103 : Begin
	IF l_src_str_wp_enable_fl = 'Y' AND l_dest_wp_str_ver_id IS NOT NULL THEN
		l_create_relationship_ok := PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id,'WORKPLAN');
		IF l_create_relationship_ok = 'N' THEN
			PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;

	IF l_src_str_fin_enable_fl = 'Y' AND l_dest_fin_str_ver_id IS NOT NULL AND l_src_task_financial_flag='Y' THEN
		l_create_relationship_ok := PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id,'FINANCIAL');
		IF l_create_relationship_ok = 'N' THEN
			PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	END IF;
	-- 4473103 : End

    IF l_src_proj_sharing_code = 'SHARE_FULL' AND l_dest_proj_sharing_code = 'SHARE_FULL' THEN
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('Into block where both src and dest proj are SHARE_FULL');
       END IF;
       /* For workplan */
           --Validation for create sub project association
       --bug 3716615
       IF (p_debug_mode = 'Y') THEN
         pa_debug.debug('Before call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
       END IF;
/* --bug 3983361
       IF p_validation_level > 0 THEN
         IF  PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id) = 'N' THEN  --SMukka
	     PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
*/
       IF (p_debug_mode = 'Y') THEN
         pa_debug.debug('After call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
       END IF;
       --end bug 3716615
       PA_RELATIONSHIP_PVT.Insert_Subproject_Association
                                (  p_init_msg_list           =>  p_init_msg_list
                                  ,p_commit                  =>  p_commit
                                  ,p_validate_only           =>  p_validate_only
                                  ,p_validation_level        =>  p_validation_level
                                  ,p_calling_module          =>  p_calling_module
                                  ,p_debug_mode              =>  p_debug_mode
                                  ,p_max_msg_count           =>  p_max_msg_count
                                  ,p_src_proj_id             =>  p_src_proj_id
                                  ,p_src_struc_wp_or_fin     =>  'WORKPLAN'
                                  ,p_src_struc_elem_id       =>  l_src_struc_elem_id
                                  ,p_src_struc_elem_ver_id   =>  l_src_struc_elem_ver_id
                                  ,p_src_task_elem_id        =>  l_src_task_elem_id
                                  ,p_src_task_elem_ver_id    =>  p_task_ver_id
                                  ,p_dest_proj_id            =>  p_dest_proj_id
                                  ,p_dest_struc_elem_id      =>  l_dest_wp_struct_element_id
                                  ,p_dest_struc_elem_ver_id  =>  l_dest_wp_str_ver_id
                                  ,x_lnk_task_elem_id        =>  l_lnk_task_elem_id
                                  ,x_lnk_task_elem_ver_id    =>  l_lnk_task_elem_ver_id
                                  ,p_lnk_task_name_number    =>  l_task_name_number
                                  ,p_relationship_type       =>  'LW'
                                  ,p_comment                 =>  p_comment               --Bug No 3668113
                                  ,x_object_relationship_id  =>  x_object_relationship_id
                                  ,x_pev_schedule_id         =>  l_pev_schedule_id
                                  ,x_return_status           =>  x_return_status
                                  ,x_msg_count               =>  x_msg_count
                                  ,x_msg_data                =>  x_msg_data
                                  );
--
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
       END IF;
--
       /* For Financial */
--       IF l_src_task_financial_flag='Y' THEN  --No need to check for fully shared project
          IF (p_debug_mode = 'Y') THEN
             pa_debug.debug('Into block where both src and dest proj are SHARE_FULL');
             pa_debug.debug('Into fin block where both src and dest proj are SHARE_FULL');
          END IF;

          --bug 3716615
          IF (p_debug_mode = 'Y') THEN
            pa_debug.debug('Before call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
          END IF;
/* --bug 3983361
          IF p_validation_level > 0 THEN
            IF  PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id, 'FINANCIAL') = 'N' THEN  --SMukka
		PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;
*/
          IF (p_debug_mode = 'Y') THEN
            pa_debug.debug('After call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
          END IF;
          --end bug 3716615

          PA_RELATIONSHIP_PVT.Insert_Subproject_Association
                                (  p_init_msg_list           =>  p_init_msg_list
                                  ,p_commit                  =>  p_commit
                                  ,p_validate_only           =>  p_validate_only
                                  ,p_validation_level        =>  p_validation_level
                                  ,p_calling_module          =>  p_calling_module
                                  ,p_debug_mode              =>  p_debug_mode
                                  ,p_max_msg_count           =>  p_max_msg_count
                                  ,p_src_proj_id             =>  p_src_proj_id
                                  ,p_src_struc_wp_or_fin     =>  'FINANCIAL'
                                  ,p_src_struc_elem_id       =>  l_src_struc_elem_id
                                  ,p_src_struc_elem_ver_id   =>  l_src_struc_elem_ver_id
                                  ,p_src_task_elem_id        =>  l_src_task_elem_id
                                  ,p_src_task_elem_ver_id    =>  p_task_ver_id
                                  ,p_dest_proj_id            =>  p_dest_proj_id
                                  ,p_dest_struc_elem_id      =>  l_dest_fin_struct_element_id
                                  ,p_dest_struc_elem_ver_id  =>  l_dest_fin_str_ver_id
                                  ,x_lnk_task_elem_id        =>  l_lnk_task_elem_id
                                  ,x_lnk_task_elem_ver_id    =>  l_lnk_task_elem_ver_id
                                  ,p_lnk_task_name_number    =>  l_task_name_number
                                  ,p_relationship_type       =>  'LF'
                                  ,p_comment                 =>  p_comment               --Bug No 3668113
                                  ,x_object_relationship_id  =>  x_object_relationship_id
                                  ,x_pev_schedule_id         =>  l_pev_schedule_id
                                  ,x_return_status           =>  x_return_status
                                  ,x_msg_count               =>  x_msg_count
                                  ,x_msg_data                =>  x_msg_data
                                  );
--
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
           END IF;
--
       --END IF;  --financial task flag is Y
    ELSE
        IF l_dest_wp_str_ver_id IS NOT NULL AND l_src_str_wp_enable_fl = 'Y' THEN
           IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Into Else block Where src and dest are WP');
           END IF;
           --bug 3716615
           IF (p_debug_mode = 'Y') THEN
             pa_debug.debug('Before call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
           END IF;
/* --bug 3983361
           IF p_validation_level > 0 THEN
             IF  PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id) = 'N' THEN  --SMukka
		 PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
               RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
*/
           IF (p_debug_mode = 'Y') THEN
             pa_debug.debug('After call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
           END IF;
           --end bug 3716615

           PA_RELATIONSHIP_PVT.Insert_Subproject_Association
                                (  p_init_msg_list           =>  p_init_msg_list
                                  ,p_commit                  =>  p_commit
                                  ,p_validate_only           =>  p_validate_only
                                  ,p_validation_level        =>  p_validation_level
                                  ,p_calling_module          =>  p_calling_module
                                  ,p_debug_mode              =>  p_debug_mode
                                  ,p_max_msg_count           =>  p_max_msg_count
                                  ,p_src_proj_id             =>  p_src_proj_id
                                  ,p_src_struc_wp_or_fin     =>  'WORKPLAN'
                                  ,p_src_struc_elem_id       =>  l_src_struc_elem_id
                                  ,p_src_struc_elem_ver_id   =>  l_src_struc_elem_ver_id
                                  ,p_src_task_elem_id        =>  l_src_task_elem_id
                                  ,p_src_task_elem_ver_id    =>  p_task_ver_id
                                  ,p_dest_proj_id            =>  p_dest_proj_id
                                  ,p_dest_struc_elem_id      =>  l_dest_wp_struct_element_id
                                  ,p_dest_struc_elem_ver_id  =>  l_dest_wp_str_ver_id
                                  ,x_lnk_task_elem_id        =>  l_lnk_task_elem_id
                                  ,x_lnk_task_elem_ver_id    =>  l_lnk_task_elem_ver_id
                                  ,p_lnk_task_name_number    =>  l_task_name_number
                                  ,p_relationship_type       =>  'LW'
                                  ,p_comment                 =>  p_comment               --Bug No 3668113
                                  ,x_object_relationship_id  =>  x_object_relationship_id
                                  ,x_pev_schedule_id         =>  l_pev_schedule_id
                                  ,x_return_status           =>  x_return_status
                                  ,x_msg_count               =>  x_msg_count
                                  ,x_msg_data                =>  x_msg_data
                                  );
--
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
           END IF;
--
        END IF;  --l_dest_wp_str_ver_id is not null and l_src_str_wp_enable_fl is Y
        IF l_dest_fin_str_ver_id IS NOT NULL AND
           l_src_task_financial_flag='Y' AND
           l_src_str_fin_enable_fl = 'Y' THEN
           IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Into Else block Where src and dest are FIN');
           END IF;

           --bug 3716615
           IF (p_debug_mode = 'Y') THEN
             pa_debug.debug('Before call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
           END IF;
/* --bug 3983361
           IF p_validation_level > 0 THEN
              IF  PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK(p_task_ver_id,p_dest_proj_id, 'FINANCIAL') = 'N' THEN  --SMukka
                 PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
               RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
*/
           IF (p_debug_mode = 'Y') THEN
             pa_debug.debug('After call to PA_RELATIONSHIP_UTILS.CREATE_SUB_PROJ_ASSO_OK api');
           END IF;
           --end bug 3716615

           PA_RELATIONSHIP_PVT.Insert_Subproject_Association
                                (  p_init_msg_list           =>  p_init_msg_list
                                  ,p_commit                  =>  p_commit
                                  ,p_validate_only           =>  p_validate_only
                                  ,p_validation_level        =>  p_validation_level
                                  ,p_calling_module          =>  p_calling_module
                                  ,p_debug_mode              =>  p_debug_mode
                                  ,p_max_msg_count           =>  p_max_msg_count
                                  ,p_src_proj_id             =>  p_src_proj_id
                                  ,p_src_struc_wp_or_fin     =>  'FINANCIAL'
                                  ,p_src_struc_elem_id       =>  l_src_struc_elem_id
                                  ,p_src_struc_elem_ver_id   =>  l_src_struc_elem_ver_id
                                  ,p_src_task_elem_id        =>  l_src_task_elem_id
                                  ,p_src_task_elem_ver_id    =>  p_task_ver_id
                                  ,p_dest_proj_id            =>  p_dest_proj_id
                                  ,p_dest_struc_elem_id      =>  l_dest_fin_struct_element_id
                                  ,p_dest_struc_elem_ver_id  =>  l_dest_fin_str_ver_id
                                  ,x_lnk_task_elem_id        =>  l_lnk_task_elem_id
                                  ,x_lnk_task_elem_ver_id    =>  l_lnk_task_elem_ver_id
                                  ,p_lnk_task_name_number    =>  l_task_name_number
                                  ,p_relationship_type       =>  'LF'
                                  ,p_comment                 =>  p_comment               --Bug No 3668113
                                  ,x_object_relationship_id  =>  x_object_relationship_id
                                  ,x_pev_schedule_id         =>  l_pev_schedule_id
                                  ,x_return_status           =>  x_return_status
                                  ,x_msg_count               =>  x_msg_count
                                  ,x_msg_data                =>  x_msg_data
                                  );
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
           END IF;
        END IF; --l_dest_fin_str_ver_id is not null and l_src_task_fin_flag is Y and l_src_str_fin_enable_fl is y
    END IF; --src and dest project sharing code are SHARE_FULL
--
    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('After call to ISPA Linking Task Elem Id => '||l_lnk_task_elem_id);
        pa_debug.debug('After call to ISPA Linking Task Elem Ver Id => '||l_lnk_task_elem_ver_id);
        pa_debug.debug('After call to ISPA Object_Relationship_Id => '||x_object_relationship_id);
        pa_debug.debug('After call to ISPA WP Attr schedule Id => '||l_pev_schedule_id);
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--

--bug 4370533 --Issue #3
-- set WBS flag dirty for the project
--update only if a workplan is created.

-- Begin fix for Bug # 4409337.

 if (
     (
      (
       l_src_proj_sharing_code = 'SHARE_FULL'
       or
       l_src_proj_sharing_code = 'SHARE_PARTIAL'
      )
      and
      -- Begin Bug # 4573015.
      (
       l_dest_fin_str_ver_id is not null
       or
       pa_project_structure_utils.check_struc_ver_published(p_dest_proj_id, l_dest_wp_str_ver_id) = 'Y'
      )
      -- End Bug # 4573015.
     )
     or
     (
      (
       l_src_proj_sharing_code = 'SPLIT_MAPPING'
       or
       l_src_proj_sharing_code = 'SPLIT_NO_MAPPING'
      )
      and
      (
       (
        l_dest_wp_str_ver_id IS NOT NULL
        and
        l_src_str_wp_enable_fl = 'Y'
        and
        pa_project_structure_utils.check_struc_ver_published(p_dest_proj_id, l_dest_wp_str_ver_id) = 'Y'
       )
       or
       (
        l_dest_fin_str_ver_id IS NOT NULL
        and
        l_src_task_financial_flag='Y'
        and
        l_src_str_fin_enable_fl = 'Y'
        and
        pa_project_structure_utils.check_struc_ver_published(p_dest_proj_id, l_dest_fin_str_ver_id) = 'Y'
       )
      )
     )
      -- Begin Bug # 4573015.
     or
     (
      l_src_str_wp_enable_fl = 'Y'
      and
      l_src_str_fin_enable_fl = 'N'
      and
      pa_project_structure_utils.check_struc_ver_published(p_dest_proj_id, l_dest_wp_str_ver_id) = 'Y'
     )
     or
     (
      l_src_str_fin_enable_fl = 'Y'
      and
      l_src_str_wp_enable_fl = 'N'
     )
      -- End Bug # 4573015.
    ) then

/*

 IF l_src_str_wp_enable_fl = 'Y' AND l_dest_published_wp_str_id IS NOT NULL
 THEN

*/

-- End fix for Bug # 4409337.

-- Added If condition for Bug 8889029
--  If user wants to defer the rollup of programs, we need not set the version to dirty as another message will be displayed to run UPPD.

  IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN

   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => 'SELF_SERVICE'
     ,p_project_id            => p_src_proj_id
     ,p_structure_version_id  => l_src_struc_elem_ver_id
     ,p_update_wbs_flag       => 'Y'
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data);

   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
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
   end if;
 END IF; --Bug#8889029
 END IF;
--bug 4370533 --Issue #3

    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_RELATIONSHIP_PVT.Create_Subproject_Association end');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Create_Subproject_Ass_pvt;
       END IF;
       x_msg_count := FND_MSG_PUB.count_msg;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Create_Subproject_Ass_pvt;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := FND_MSG_PUB.count_msg;
       --put message
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                               p_procedure_name => 'Create_Subproject_Association',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END Create_Subproject_Association;
--
--
--
-- API name                      : Update_Subproject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_commit                      IN  VARCHAR2 := FND_API.G_FALSE
-- p_debug_mode                  IN  VARCHAR2 := 'N'
-- p_object_relationship_id      IN  NUMBER
-- p_record_version_number       IN  NUMBER
-- p_comment                     IN  VARCHAR2
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
Procedure Update_Subproject_Association(p_api_version            IN  NUMBER      := 1.0,
                                        p_init_msg_list          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validate_only          IN  VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level       IN  VARCHAR2    := 100,
                                        p_calling_module         IN  VARCHAR2    := 'SELF_SERVICE',
                                        p_max_msg_count          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_commit                 IN  VARCHAR2    := FND_API.G_FALSE,
                                        p_debug_mode             IN  VARCHAR2    := 'N',
                                        p_object_relationship_id IN  NUMBER,
                                        p_record_version_number  IN  NUMBER,
                                        p_comment                IN  VARCHAR2,
                                        x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

-- Bug # 5072032.

cursor l_cur_obj_rel_id(c_object_relationship_id NUMBER) is
select por2.object_relationship_id, por2.record_version_number
from pa_object_relationships por1, pa_object_relationships por2
, pa_object_relationships por3, pa_object_relationships por4
where por1.object_id_to1 = por2.object_id_from1
and por1.relationship_type = 'S'
and por3.object_id_to1 = por4.object_id_from1
and por3.relationship_type = 'S'
and por1.object_id_from1  = por3.object_id_from1
and por2.object_id_from2 = por4.object_id_from2
and por2.object_id_to1 = por4.object_id_to1
and por2.object_id_to2 = por4.object_id_to2
and por2.relationship_type IN ('LW','LF')
and por4.object_relationship_id = c_object_relationship_id;

l_cur_obj_rel_rec l_cur_obj_rel_id%ROWTYPE;

-- Bug # 5072032.


BEGIN
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIPS_PVT1.UPDATE_SUBPROJECT_ASSOCIATION Begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       savepoint update_subproject_ass_pvt;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('The value of the passed object_relationship_id=> '||p_object_relationship_id);
       pa_debug.debug('The value of the passed comments=> '||p_comment);
    END IF;
--

-- Bug # 5072032.

for l_cur_obj_rel_rec in l_cur_obj_rel_id(p_object_relationship_id)
loop
    UPDATE pa_object_relationships
       SET comments               = p_comment
           ,record_version_number  = (l_cur_obj_rel_rec.record_version_number+1) -- p_record_version_number + 1
    WHERE object_relationship_id = l_cur_obj_rel_rec.object_relationship_id -- p_object_relationship_id
    and record_version_number = l_cur_obj_rel_rec.record_version_number;
    IF SQL%NOTFOUND THEN
        fnd_message.set_name('PA','PA_RECORD_CHANGED');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

end loop;

-- Bug # 5072032.
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Return status before the end of Update_Subproject_Association=> '||x_return_status);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_RELATIONSHIPS_PVT1.UPDATE_SUBPROJECT_ASSOCIATION END');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (p_commit = FND_API.G_TRUE) THEN
           ROLLBACK to update_subproject_ass_pvt;
        END IF;
        x_msg_count := FND_MSG_PUB.count_msg;
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        IF (p_commit = FND_API.G_TRUE) THEN
	    ROLLBACK TO update_subproject_ass_pvt;
	END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.add_exc_msg(
		p_pkg_name       => 'PA_RELATIONSHIPS_PVT1',
                p_procedure_name => 'update_subproject_association',
                p_error_text     => SUBSTRB(SQLERRM,1,240));
        ROLLBACK TO update_subproject_association;
	RAISE;
END Update_Subproject_Association;
--
--
--
-- API name                      : Delete_SubProject_Association
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_object_relationships_id     IN  NUMBER
-- p_record_version_number       IN  NUMBER
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
PROCEDURE Delete_SubProject_Association(p_commit                  IN   VARCHAR2    := FND_API.G_FALSE,
                                        p_validate_only           IN   VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level        IN   VARCHAR2    := 100,
                                        p_calling_module          IN   VARCHAR2    := 'SELF_SERVICE',
                                        p_debug_mode              IN   VARCHAR2    := 'N',
                                        p_max_msg_count           IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_object_relationships_id IN   NUMBER,
                                        p_record_version_number   IN   NUMBER,
                                        x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
--  Deleting sub-project association
--  Input parameters for this API are
--  object_relationship_id=  p_object_relationships_id
    l_src_lnk_task_ver_id    pa_proj_element_versions.element_version_id%type;
    l_dest_str_ver_id        pa_proj_element_versions.element_version_id%type;
    l_src_proj_id            pa_projects_all.project_id%type;
    l_dest_proj_id           pa_projects_all.project_id%type;
    l_src_task_ver_id        pa_proj_element_versions.element_version_id%type;
    l_task_version_rvn       NUMBER;
    l_upd_prog_grp_status    NUMBER:=0;
--
    l_data                   VARCHAR2(250);
    l_msg_index_out          NUMBER;
--
    CURSOR get_lnk_obj_rel_attr(cp_object_relationships_id NUMBER) IS
    SELECT object_id_from1,        --src_lnk_task_ver_id
           object_id_to1,          --dest_str_ver_id
           object_id_from2,        --src proj_id
           object_id_to2           --dest_proj_id
      FROM pa_object_relationships
     WHERE object_relationship_id = cp_object_relationships_id
       AND relationship_type IN ('LW','LF');
    get_lnk_obj_rel_attr_rec get_lnk_obj_rel_attr%ROWTYPE;
--
    CURSOR get_rec_ver_num(cp_lnk_task_ver_id NUMBER) IS
    SELECT record_version_number    --task_Version_rvn
      FROM pa_proj_element_versions
     WHERE element_version_id = cp_lnk_task_ver_id;
    get_rec_ver_num_rec  get_rec_ver_num%ROWTYPE;

    CURSOR get_src_task_ver_id(cp_src_lnk_task_ver_id NUMBER) IS
    SELECT object_id_from1         --src_task_ver_id
      FROM pa_object_relationships
     WHERE object_id_to1 = cp_src_lnk_task_ver_id
       AND relationship_type = 'S';
    get_src_task_ver_id_rec get_src_task_ver_id%ROWTYPE;
--
    CURSOR get_lnk_info(cp_src_project_id NUMBER,
                        cp_src_Task_ver_id NUMBER,
                        cp_dest_proj_id NUMBER) IS
    SELECT pora.object_relationship_id obj_rel_id,
           pora.object_id_to1 lnk_task_ver_id,
           porb.object_relationship_id lnk_obj_rel_id,
           porb.object_id_to1 lnk_dest_str_ver_id
	   , porb.record_version_number lnk_record_ver_number -- Bug # 5072032.
      FROM pa_proj_element_versions ppev,
           pa_object_relationships pora,
           pa_object_relationships porb,
           pa_proj_elements ppe
     WHERE pora.relationship_type = 'S'
       AND ppev.project_id = cp_src_project_id
       AND pora.OBJECT_ID_FROM1 = cp_src_Task_ver_id
       AND pora.object_type_from = 'PA_TASKS'
       AND pora.OBJECT_ID_to1 = ppev.ELEMENT_VERSION_ID
       AND ppe.proj_element_id = ppev.proj_element_id
       AND pora.object_id_to1=porb.object_id_from1
       AND porb.object_id_to2 = cp_dest_proj_id
       AND porb.object_id_from2 = cp_src_project_id
       AND porb.object_type_to = 'PA_STRUCTURES'
       AND porb.relationship_type IN ('LW','LF')
       AND ppe.link_task_flag = 'Y';
    get_lnk_info_rec get_lnk_info%ROWTYPE;
--

--bug 4370533 --Issue #3 delete link
  CURSOR cur_src_structure_ver_id(c_src_task_ver_id NUMBER)
  IS
    SELECT project_id, parent_structure_version_id
      FROM pa_proj_element_versions
    WHERE element_version_id = c_src_task_ver_id
    ;
  l_src_structure_ver_id   NUMBER;
  l_src_project_id         NUMBER;
--bug 4370533 --Issue #3

-- Begin fix for Bug # 4385027.

l_tasks_ver_ids PA_NUM_1000_NUM := PA_NUM_1000_NUM();

cursor check_child_pub (c_dest_proj_id NUMBER, c_dest_struc_elem_ver_id NUMBER) is
select 'x'
from pa_proj_elem_ver_structure
where project_id = c_dest_proj_id
and element_version_id = c_dest_struc_elem_ver_id
and status_code = 'STRUCTURE_PUBLISHED';

l_dummy    VARCHAR2(1);

-- End fix for Bug # 4385027.

BEGIN
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Delete_SubProject_Association begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint delete_subproject_ass_pvt;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Deleting the object_relationships_id => '||p_object_relationships_id);
    END IF;
--
--  Get the details for passed object relationship id from pa_object_relationships
    OPEN get_lnk_obj_rel_attr(p_object_relationships_id);
    FETCH get_lnk_obj_rel_attr INTO get_lnk_obj_rel_attr_rec;
    IF get_lnk_obj_rel_attr%NOTFOUND THEN
       CLOSE get_lnk_obj_rel_attr;
       PA_UTILS.ADD_MESSAGE('PA','PA_NO_RECORD_VERSION_NUMBER');
       x_msg_data := 'PA_NO_RECORD_VERSION_NUMBER';
       RAISE FND_API.G_EXC_ERROR;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('src lnk task ver id value for pass obj rel id=> '||get_lnk_obj_rel_attr_rec.object_id_from1);
       pa_debug.debug('dest str ver id value for pass obj rel id=> '||get_lnk_obj_rel_attr_rec.object_id_to1);
       pa_debug.debug('src proj id value for pass obj rel id => '||get_lnk_obj_rel_attr_rec.object_id_from2);
       pa_debug.debug('dest proj id value for pass obj rel id => '||get_lnk_obj_rel_attr_rec.object_id_to2);
    END IF;
--
    CLOSE get_lnk_obj_rel_attr;
--
    --Getting the src task version details
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Values pass to get_lnk_obj_rel_attr cursor => '||get_lnk_obj_rel_attr_rec.object_id_from1);
    END IF;
--
    OPEN get_src_task_ver_id(get_lnk_obj_rel_attr_rec.object_id_from1);
    FETCH get_src_task_ver_id INTO get_src_task_ver_id_rec;
    IF get_src_task_ver_id%NOTFOUND THEN
       CLOSE get_src_task_ver_id;
       PA_UTILS.ADD_MESSAGE('PA','PA_NO_RECORD_VERSION_NUMBER');
       x_msg_data := 'PA_NO_RECORD_VERSION_NUMBER';
       RAISE FND_API.G_EXC_ERROR;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('the value of src task ver id for passed lnk task ver id=> '||get_src_task_ver_id_rec.object_id_from1);
    END IF;
--
    CLOSE get_src_task_ver_id;

--bug 4370533 --Issue #3 delete link

    OPEN  cur_src_structure_ver_id(get_src_task_ver_id_rec.object_id_from1);
    FETCH cur_src_structure_ver_id INTO l_src_project_id, l_src_structure_ver_id;
    CLOSE cur_src_structure_ver_id;

    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('l_src_structure_ver_id='||l_src_structure_ver_id);
    END IF;
--bug 4370533 --Issue #3

--
    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Values pass to get_lnk_info cursor => '||get_lnk_obj_rel_attr_rec.object_id_from2);
        pa_debug.debug('Values pass to get_lnk_info cursor => '||get_src_task_ver_id_rec.object_id_from1);
        pa_debug.debug('Values pass to get_lnk_info cursor => '||get_lnk_obj_rel_attr_rec.object_id_to2);
    END IF;
--
    OPEN get_lnk_info(get_lnk_obj_rel_attr_rec.object_id_from2,
                      get_src_task_ver_id_rec.object_id_from1,
                      get_lnk_obj_rel_attr_rec.object_id_to2);
    LOOP
       FETCH get_lnk_info INTO get_lnk_info_rec;
       IF get_lnk_info%NOTFOUND THEN
          CLOSE get_lnk_info;
          exit;
       END IF;
       --Loop thru the above cursor to get the second part of the link
       --Bug No 3450684
       BEGIN
           l_upd_prog_grp_status:=PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS(get_lnk_info_rec.lnk_obj_rel_id,
                                                                           'DROP');
           IF  l_upd_prog_grp_status < 0 THEN
               PA_UTILS.ADD_MESSAGE('PA','PA_DEL_SUBPROJ_VAL_FAIL');
               RAISE FND_API.G_EXC_ERROR;
           END IF;
           IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Return Status PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS=> '||l_upd_prog_grp_status);
           END IF;
       EXCEPTION

        -- Begin fix for Bug # 4485908.

        WHEN FND_API.G_EXC_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

        -- End fix for Bug # 4485908.

           WHEN OTHERS THEN
                fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                                        p_procedure_name => 'Delete_SubProject_Association',
                                        p_error_text     => SUBSTRB('PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END;
--

       --PA_RELATIONSHIP_PUB.Delete_Relationship(porb.object_relationship_id);--table handler
       PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW(
                     p_object_relationship_id => get_lnk_info_rec.lnk_obj_rel_id
                    ,p_object_type_from       => NULL
                    ,p_object_id_from1        => NULL
                    ,p_object_id_from2        => NULL
                    ,p_object_id_from3        => NULL
                    ,p_object_id_from4        => NULL
                    ,p_object_id_from5 => NULL
                    ,p_object_type_to => NULL
                    ,p_object_id_to1 => NULL
                    ,p_object_id_to2 => NULL
                    ,p_object_id_to3 => NULL
                    ,p_object_id_to4 => NULL
                    ,p_object_id_to5 => NULL
		    ,p_record_version_number => get_lnk_info_rec.lnk_record_ver_number -- p_record_version_number -- Bug # 5072032.
                    ,p_pm_product_code => NULL
                    ,x_return_status => x_return_status
                   );
--
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
       END IF;
--
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('Return status after call to PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW=> '||x_return_status);
       END IF;
--
--       PA_TASK_PVT1.Delete_Task_Version(pora.object_id_to1);
       OPEN get_rec_ver_num(get_lnk_info_rec.lnk_task_ver_id);
       FETCH get_rec_ver_num INTO get_rec_ver_num_rec;
       IF get_rec_ver_num%NOTFOUND THEN
          CLOSE get_rec_ver_num;
          PA_UTILS.ADD_MESSAGE('PA','PA_NO_RECORD_VERSION_NUMBER');
          x_msg_data := 'PA_NO_RECORD_VERSION_NUMBER';
          RAISE FND_API.G_EXC_ERROR;
       END IF;
--
       PA_TASK_PUB1.DELETE_TASK_VERSION(p_commit => 'N',
                                        p_debug_mode => p_debug_mode,
                                        p_task_version_id => get_lnk_info_rec.lnk_task_ver_id,
                                        p_record_version_number => get_rec_ver_num_rec.record_version_number,
                                        x_return_status => x_return_status,
                                        x_msg_count => x_msg_count,
                                        x_msg_data => x_msg_data);
--
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
       END IF;
--
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('Return status after call to PA_TASK_PUB1.DELETE_TASK_VERSION=> '||x_return_status);
       END IF;
--
       CLOSE get_rec_ver_num;
    END LOOP;
--

/* bug 4541039
-- Begin fix for Bug # 4385027.

if pa_project_structure_utils.get_struc_type_for_version(l_src_structure_ver_id, 'WORKPLAN') = 'Y' then

	l_tasks_ver_ids.extend(1);
	l_tasks_ver_ids(1) := get_src_task_ver_id_rec.object_id_from1;

	-- do not rollup from working to working structure version.

	if get_lnk_obj_rel_attr_rec.object_id_to1 IS NOT NULL then

                open check_child_pub(get_lnk_obj_rel_attr_rec.object_id_to2
                                     , get_lnk_obj_rel_attr_rec.object_id_to1);
                fetch check_child_pub INTO l_dummy;

                        if check_child_pub%FOUND then

                                PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject
                                (p_debug_mode => p_debug_mode
                                , p_element_versions => l_tasks_ver_ids
                                , x_return_status => x_return_status
                                , x_msg_count => x_msg_count
                                , x_msg_data => x_msg_data);

          			if x_return_status <> FND_API.G_RET_STS_SUCCESS then

             				x_msg_count := FND_MSG_PUB.count_msg;

           					if x_msg_count = 1 then

              						pa_interface_utils_pub.get_messages
               						(p_encoded        => FND_API.G_TRUE
                					, p_msg_index      => 1
                					, p_msg_count      => x_msg_count
                					, p_msg_data       => x_msg_data
                					, p_data           => l_data
                					, p_msg_index_out  => l_msg_index_out);

                					x_msg_data := l_data;

           					end if;

           				raise FND_API.G_EXC_ERROR;

				end if;

        		end if;

        	close check_child_pub;

       	end if;

end if;

-- End fix for Bug # 4385027.

--bug 4370533 --Issue #3 delete link
end bug 4541039 */

-- set WBS flag dirty for the project

--Update dirty only if workplan gets deleted.
-- Added If condition for Bug 8889029
--  If user wants to defer the rollup of programs, we need not set the version to dirty as another message will be displayed to run UPPD.
IF NVL(FND_PROFILE.value('PA_ROLLUP_PROGRAM_AMOUNTS'),'AUTOMATIC') = 'AUTOMATIC' THEN
IF PA_PROJECT_STRUCTURE_UTILS.GET_STRUC_TYPE_FOR_VERSION(l_src_structure_ver_id, 'WORKPLAN') = 'Y'
THEN
   PA_PROJ_TASK_STRUC_PUB.SET_UPDATE_WBS_FLAG
   (
      p_calling_context       => 'SELF_SERVICE'
     ,p_project_id            => l_src_project_id
     ,p_structure_version_id  => l_src_structure_ver_id
     ,p_update_wbs_flag       => 'Y'
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data);

   if x_return_status <> FND_API.G_RET_STS_SUCCESS then
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
   end if;
END IF;
--bug 4370533 --Issue #3
END IF; -- Bug 8889029


    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Return status before the end of Delete_SubProject_Association=> '||x_return_status);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Delete_SubProject_Association end');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to delete_subproject_ass_pvt;
       END IF;
       x_msg_count := FND_MSG_PUB.count_msg;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to delete_subproject_ass_pvt;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := FND_MSG_PUB.count_msg;
       --put message
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                               p_procedure_name => 'Delete_SubProject_Association',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END Delete_SubProject_Association;
--
--
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
Procedure Copy_OG_Lnk_For_Subproj_Ass(p_validate_only           IN   VARCHAR2    := FND_API.G_TRUE,
                                      p_validation_level        IN   VARCHAR2    := 100,
                                      p_calling_module          IN   VARCHAR2    := 'SELF_SERVICE',
                                      p_debug_mode              IN   VARCHAR2    := 'N',
                                      p_max_msg_count           IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                      p_commit                  IN   VARCHAR2    := FND_API.G_FALSE,
                                      p_src_str_version_id      IN   NUMBER,
                                      p_dest_str_version_id     IN   NUMBER,
                                      x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
/*PROCEDURE  Copy_OG_Lnk_For_Subproj_Ass(p_src_str_version_id      IN   NUMBER,
                                      p_dest_str_version_id     IN   NUMBER,
                                      x_return_status           OUT  VARCHAR2,
                                      x_msg_count               OUT  NUMBER,
                                      x_msg_data                OUT  VARCHAR2)*/
IS
    l_object_relationship_id  NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    API_ERROR                 EXCEPTION;
--
--
   l_pub_str_ver_enable  CHAR(1):=NULL;
   /* Cursor to get the linking task information present on that src structure version id*/
   CURSOR get_linking_task_info(cp_src_str_ver_id NUMBER) IS
   SELECT ppev.element_version_id lnk_task_ver_id,
          ppe.proj_element_id lnk_task_id
     FROM pa_proj_elements ppe,
          pa_proj_element_versions ppev
    WHERE ppe.proj_element_id = ppev.proj_element_id
      AND ppe.link_task_flag = 'Y'
      AND ppev.parent_structure_version_id = cp_src_str_ver_id
      AND ppe.project_id = ppev.project_id;
   get_linking_task_info_rec get_linking_task_info%ROWTYPE;
--
    /*This cursor is used to get the relationships that are going out of task version*/
    CURSOR get_going_out_lnk_info(cp_src_Task_ver_id NUMBER) IS
    SELECT por.object_relationship_id,
           por.object_id_to1,
           por.object_id_from1,
           por.object_id_to2,
           por.object_id_from2,
           por.relationship_type,
           por.record_version_number,
           por.object_type_to,
           por.object_type_from
      FROM pa_object_relationships por
     WHERE por.relationship_type in ('LW','LF')
       AND por.OBJECT_ID_FROM1 = cp_src_Task_ver_id
       AND por.object_type_from = 'PA_TASKS'
       AND por.object_type_to = 'PA_STRUCTURES'
       AND por.object_id_to2 <> por.object_id_from2;
     get_going_out_lnk_info_rec   get_going_out_lnk_info%ROWTYPE;
     p_src_Task_ver_id  NUMBER;
     l_new_pub_lnk_task_ver_id NUMBER;
--
     l_upd_prog_grp_status    NUMBER:=0;
--

  CURSOR get_new_pub_lnk_task_ver_id(c_dest_str_version_id NUMBER, c_link_task_id NUMBER) IS
              SELECT element_version_id
                FROM pa_proj_element_versions
               WHERE parent_structure_Version_id = c_dest_str_version_id
                 AND proj_element_id = c_link_task_id;
BEGIN
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Copy_OG_Lnk_For_Subproj_Ass begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Copy_OG_Lnk_For_Subproj_Ass;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Value of p_src_str_version_id => '||p_src_str_version_id);
        pa_debug.debug('Value of p_dest_str_version_id => '||p_dest_str_version_id);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Value of p_src_str_version_id before get_linking_task_info => '||p_src_str_version_id);
    END IF;
    OPEN get_linking_task_info(p_src_str_version_id);
    LOOP
       FETCH get_linking_task_info INTO get_linking_task_info_rec;
       IF get_linking_task_info%NOTFOUND THEN
          EXIT;
       END IF;
       IF (p_debug_mode = 'Y') THEN
          pa_debug.debug('Value of get_linking_task_info_rec lnk_task_ver_id before get_going_out_lnk_info cur => '||get_linking_task_info_rec.lnk_task_ver_id);
       END IF;
       OPEN get_going_out_lnk_info(get_linking_task_info_rec.lnk_task_ver_id);
       LOOP
          FETCH get_going_out_lnk_info into get_going_out_lnk_info_rec;
          IF get_going_out_lnk_info%NOTFOUND THEN
             EXIT;
          END IF;
          --For Task
/*
          BEGIN
              SELECT element_version_id
                INTO l_new_pub_lnk_task_ver_id
                FROM pa_proj_element_versions
               WHERE parent_structure_Version_id = p_dest_str_version_id
                 AND proj_element_id = get_linking_task_info_rec.lnk_task_id;
              IF (p_debug_mode = 'Y') THEN
                 pa_debug.debug('Value of l_new_pub_lnk_task_ver_id after select=> '||l_new_pub_lnk_task_ver_id);
                 pa_debug.debug('Value of p_dest_str_version_id after select => '||p_dest_str_version_id);
              END IF;
          EXCEPTION
               WHEN OTHERS THEN
                    RAISE;
          END;
*/
          l_new_pub_lnk_task_ver_id := NULL;
          OPEN get_new_pub_lnk_task_ver_id(p_dest_str_version_id, get_linking_task_info_rec.lnk_task_id);
          FETCH get_new_pub_lnk_task_ver_id INTO l_new_pub_lnk_task_ver_id;
          CLOSE get_new_pub_lnk_task_ver_id;

          IF (l_new_pub_lnk_task_ver_id IS NOT NULL) THEN
            PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
                p_user_id => FND_GLOBAL.USER_ID
               ,p_object_type_from => 'PA_TASKS'
               ,p_object_id_from1 => l_new_pub_lnk_task_ver_id
               ,p_object_id_from2 => get_going_out_lnk_info_rec.object_id_from2
               ,p_object_id_from3 => NULL
               ,p_object_id_from4 => NULL
               ,p_object_id_from5 => NULL
               ,p_object_type_to => get_going_out_lnk_info_rec.object_type_to
               ,p_object_id_to1 => get_going_out_lnk_info_rec.object_id_to1
               ,p_object_id_to2 => get_going_out_lnk_info_rec.object_id_to2
               ,p_object_id_to3 => NULL
               ,p_object_id_to4 => NULL
               ,p_object_id_to5 => NULL
               ,p_relationship_type => get_going_out_lnk_info_rec.relationship_type
               ,p_relationship_subtype => NULL
               ,p_lag_day => NULL
               ,p_imported_lag => NULL
               ,p_priority => NULL
               ,p_pm_product_code => NULL
               ,x_object_relationship_id => l_object_relationship_id
               ,x_return_status      => x_return_status
               ,p_comments           => null
               ,p_status_code        => null
            );

	      -- 4537865
    	  IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
       	       RAISE FND_API.G_EXC_ERROR;
      	  ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
      	  END IF;
      	      -- End 4537865

            IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Value of x_object_relationship_id=> '||l_object_relationship_id);
              pa_debug.debug('Value of l_new_pub_lnk_task_ver_id=> '||l_new_pub_lnk_task_ver_id);
              pa_debug.debug('Value of x_return_status after call to PA_OBJECT_RELATIONSHIPS_PKG INSERT_ROW=> '||x_return_status);
            END IF;
--
            --Bug No 3450684
            BEGIN
              l_upd_prog_grp_status:=PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS(l_object_relationship_id,
                                                                              'ADD');
              IF l_upd_prog_grp_status < 0 THEN
                 PA_UTILS.ADD_MESSAGE('PA','PA_CP_SUBPROJ_VAL_FAIL');
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF (p_debug_mode = 'Y') THEN
                 pa_debug.debug('Return Status PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS=> '||l_upd_prog_grp_status);
              END IF;
            EXCEPTION

        -- Begin fix for Bug # 4485908.

        WHEN FND_API.G_EXC_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

        -- End fix for Bug # 4485908.

              WHEN OTHERS THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                                           p_procedure_name => 'Copy_OG_Lnk_For_Subproj_Ass',
                                           p_error_text     => SUBSTRB('PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS:'||SQLERRM,1,240));
              RAISE FND_API.G_EXC_ERROR;
            END;
          END IF;
--
       END LOOP; --end loop for get_going_out_lnk_info cursor
       CLOSE get_going_out_lnk_info;
    END LOOP; --end loop for get_linking_task_info cursor
    CLOSE get_linking_task_info;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Return status before the end of Copy_OG_Lnk_For_Subproj_Ass=> '||x_return_status);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Copy_OG_Lnk_For_Subproj_Ass end');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Copy_OG_Lnk_For_Subproj_Ass;
       END IF;
       x_msg_count := FND_MSG_PUB.count_msg;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Copy_OG_Lnk_For_Subproj_Ass;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := FND_MSG_PUB.count_msg;
       --put message
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                               p_procedure_name => 'Copy_OG_Lnk_For_Subproj_Ass',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END Copy_OG_Lnk_For_Subproj_Ass;
--
--
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
PROCEDURE Move_CI_Lnk_For_subproj_step2(p_commit                  IN   VARCHAR2    := FND_API.G_FALSE,
                                        p_validate_only           IN   VARCHAR2    := FND_API.G_TRUE,
                                        p_validation_level        IN   VARCHAR2    := 100,
                                        p_calling_module          IN   VARCHAR2    := 'SELF_SERVICE',
                                        p_debug_mode              IN   VARCHAR2    := 'N',
                                        p_max_msg_count           IN   NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_src_str_version_id      IN   NUMBER,
                                        p_dest_str_version_id     IN   NUMBER,  /*publishing str*/
                                        p_publish_fl              IN   CHAR,
                                        x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
--
      x_object_relationship_id  NUMBER;
--    p_commit                  VARCHAR2;
--    p_validate_only           VARCHAR2;
--    p_validation_level        VARCHAR2;
--    p_calling_module          VARCHAR2;
--    p_debug                   VARCHAR2;
--    p_max_msg_count           NUMBER;
--
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
--    API_ERROR             EXCEPTION;
--
--
    /*This cursor is used to get the relationships that are coming in to the structure version id  */
    /*from working versions                                                                        */
    CURSOR get_coming_in_lnk_info(cp_src_str_ver_id NUMBER) IS
    SELECT porb.object_relationship_id,
           porb.object_id_to1,
           porb.object_id_from1,
           porb.object_id_to2,
           porb.object_id_from2,
           porb.relationship_type,
           porb.record_version_number
      FROM pa_object_relationships pora,
           pa_object_relationships porb
     WHERE pora.relationship_type = 'S'
       AND pora.object_type_from = 'PA_TASKS'
       AND pora.object_id_to1 = porb.object_id_from1
       AND pora.object_type_to = porb.object_type_from
       AND porb.OBJECT_ID_TO1 = cp_src_str_ver_id
       AND porb.object_type_to = 'PA_STRUCTURES'
       AND porb.relationship_type IN ('LW','LF');

--commented out: bug 3665487
/*
       AND pora.OBJECT_ID_TO1 = cp_src_str_ver_id
       AND pora.object_type_from = 'PA_TASKS'
       AND pora.OBJECT_ID_from1 = ppev.ELEMENT_VERSION_ID
       AND ppe.proj_element_id = ppev.proj_element_id
       AND pora.object_id_to1=porb.object_id_from1
       AND porb.object_id_to2 <> porb.object_id_from2
       AND porb.object_type_to = 'PA_STRUCTURES'
       AND porb.relationship_type IN ('LW','LF')
       AND ppe.link_task_flag = 'Y';
*/

     get_coming_in_lnk_info_rec   get_coming_in_lnk_info%ROWTYPE;
--
     l_move_link_fl           VARCHAR2(1):='Y';
     l_proj_id                NUMBER;
     l_pub_str_ver_enable     VARCHAR2(1);
     l_upd_prog_grp_status    NUMBER:=0;
--
    CURSOR get_working_ver(c_ver_id NUMBER) IS
    Select 1 from pa_proj_element_versions a, pa_proj_elem_ver_structure b
     where a.element_version_id = c_ver_id
       and a.project_id = b.project_id
       and a.parent_structure_version_id = b.element_version_id
       and b.status_code <> 'STRUCTURE_PUBLISHED';
    l_dummy NUMBER;

-- Bug # 4329284.

cursor cur_proj_name (c_project_id NUMBER) is
select ppa.name
from pa_projects_all ppa
where ppa.project_id = c_project_id;

l_proj_name VARCHAR2(30);
l_prog_name VARCHAR2(30);

-- Bug # 4329284.

BEGIN
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Move_CI_Lnk_For_subproj_step2 begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Move_CI_Lnk_For_subproj_step2;
    END IF;

    	x_return_status := FND_API.G_RET_STS_SUCCESS; -- 4537865
--
/*    IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Deleting the object_relationships_id => ');
    END IF;*/
--
    OPEN get_coming_in_lnk_info(p_src_str_version_id);
    LOOP
       fetch get_coming_in_lnk_info into get_coming_in_lnk_info_rec;
       IF get_coming_in_lnk_info%NOTFOUND THEN
          EXIT;
       END IF;
       l_move_link_fl:='Y';
       IF p_publish_fl = 'Y' THEN
          /* Will tell if versioning is enabled or not on the pub str*/
          SELECT project_id
            INTO l_proj_id
            FROM pa_proj_element_versions
           WHERE element_Version_id = get_coming_in_lnk_info_rec.object_id_from1;
          l_pub_str_ver_enable:=PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_proj_id);
          IF l_pub_str_ver_enable = 'N' THEN
             l_move_link_fl:='Y';
          ELSE
             --move if linking from working version
            OPEN get_working_ver(get_coming_in_lnk_info_rec.object_id_from1);
            FETCH get_working_ver INTO l_dummy;
            if Get_working_ver%FOUND THEN
              l_move_link_fl := 'Y';
            else
              l_move_link_fl := 'N';
            end if;
            CLOSE get_working_ver;
          END IF;
       END IF;
       --For Task
       IF l_move_link_fl='Y' THEN
          x_object_relationship_id := NULL;
          PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
              p_user_id => FND_GLOBAL.USER_ID
             ,p_object_type_from => 'PA_TASKS'
             ,p_object_id_from1 => get_coming_in_lnk_info_rec.object_id_from1
             ,p_object_id_from2 => get_coming_in_lnk_info_rec.object_id_from2
             ,p_object_id_from3 => NULL
             ,p_object_id_from4 => NULL
             ,p_object_id_from5 => NULL
             ,p_object_type_to => 'PA_STRUCTURES'
             ,p_object_id_to1 => p_dest_str_version_id
             ,p_object_id_to2 => get_coming_in_lnk_info_rec.object_id_to2
             ,p_object_id_to3 => NULL
             ,p_object_id_to4 => NULL
             ,p_object_id_to5 => NULL
             ,p_relationship_type => get_coming_in_lnk_info_rec.relationship_type
             ,p_relationship_subtype => NULL
             ,p_lag_day => NULL
             ,p_imported_lag => NULL
             ,p_priority => NULL
             ,p_pm_product_code => NULL
             ,x_object_relationship_id => x_object_relationship_id
             ,x_return_status      => x_return_status
             ,p_comments           => null
             ,p_status_code        => null
             );
              -- 4537865
          IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
          END IF;
              -- End 4537865
--
          --Bug No 3450684
          BEGIN
              l_upd_prog_grp_status:=0;
              l_upd_prog_grp_status:=PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS(x_object_relationship_id,
                                                                           'ADD');
              IF  l_upd_prog_grp_status < 0 THEN

                -- Bug # 4329284.

                open cur_proj_name(get_coming_in_lnk_info_rec.object_id_from2);
                fetch cur_proj_name into l_prog_name;
                close cur_proj_name;

                open cur_proj_name(get_coming_in_lnk_info_rec.object_id_to2);
                fetch cur_proj_name into l_proj_name;
                close cur_proj_name;

                -- Bug # 4329284.

                PA_UTILS.ADD_MESSAGE('PA','PA_CRT_SUBPROJ_VAL_FAIL','PROJ',l_proj_name,'PROG',l_prog_name); -- Bug # 4329284.
                RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF (p_debug_mode = 'Y') THEN
                pa_debug.debug('Return Status PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS=> '||l_upd_prog_grp_status);
              END IF;
          EXCEPTION

        -- Begin fix for Bug # 4485908.

        WHEN FND_API.G_EXC_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

        -- End fix for Bug # 4485908.

            WHEN OTHERS THEN
              fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                                     p_procedure_name => 'Insert_Subproject_Association',
                                     p_error_text     => SUBSTRB('PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS:'||SQLERRM,1,240));
              RAISE FND_API.G_EXC_ERROR;
          END;

          BEGIN
              l_upd_prog_grp_status:=0;
              l_upd_prog_grp_status:=PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS(get_coming_in_lnk_info_rec.object_relationship_id,
                                                                              'DROP');
              IF l_upd_prog_grp_status < 0 THEN
                 PA_UTILS.ADD_MESSAGE('PA','PA_MV_DEL_SUBPROJ_VAL_FAIL');
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF (p_debug_mode = 'Y') THEN
                 pa_debug.debug('Return Status PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS=> '||l_upd_prog_grp_status);
              END IF;
          EXCEPTION

        -- Begin fix for Bug # 4485908.

        WHEN FND_API.G_EXC_ERROR THEN

                RAISE FND_API.G_EXC_ERROR;

        -- End fix for Bug # 4485908.

              WHEN OTHERS THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                                           p_procedure_name => 'Move_CI_Lnk_For_subproj_step2',
                                           p_error_text     => SUBSTRB('PA_RELATIONSHIP_PUB.UPDATE_PROGRAM_GROUPS:'||SQLERRM,1,240));
              RAISE FND_API.G_EXC_ERROR;
          END;
--
          PA_OBJECT_RELATIONSHIPS_PKG.DELETE_ROW(
                     p_object_relationship_id => get_coming_in_lnk_info_rec.object_relationship_id
                    ,p_object_type_from       => NULL
                    ,p_object_id_from1        => NULL
                    ,p_object_id_from2        => NULL
                    ,p_object_id_from3        => NULL
                    ,p_object_id_from4        => NULL
                    ,p_object_id_from5 => NULL
                    ,p_object_type_to => NULL
                    ,p_object_id_to1 => NULL
                    ,p_object_id_to2 => NULL
                    ,p_object_id_to3 => NULL
                    ,p_object_id_to4 => NULL
                    ,p_object_id_to5 => NULL
                    ,p_record_version_number => get_coming_in_lnk_info_rec.record_version_number
                    ,p_pm_product_code => NULL
                    ,x_return_status => x_return_status
                   );
                 -- 4537865
          IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
          END IF;
              -- End 4537865
--
       END IF; --End of move_link is Y
    END LOOP;  --end loop get_coming_in_lnk_info cursor
    CLOSE get_coming_in_lnk_info;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Return status before the end of Delete_SubProject_Association=> '||x_return_status);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Move_CI_Lnk_For_subproj_step2 end');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Move_CI_Lnk_For_subproj_step2;
       END IF;
       x_msg_count := FND_MSG_PUB.count_msg;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Move_CI_Lnk_For_subproj_step2;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := FND_MSG_PUB.count_msg;
       --put message
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                               p_procedure_name => 'Move_CI_Lnk_For_subproj_step2',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END Move_CI_Lnk_For_subproj_step2;
--
--
--
--  History
--
--  20-Feb-04   Smukka           -Created
--                               -Created this procedure for subproject association
--
--  FPM bug 3450684
--
--
PROCEDURE Move_CI_Lnk_For_subproj_step1(p_api_version	   IN	NUMBER	        :=1.0,
                                        p_init_msg_list	   IN	VARCHAR2	:=FND_API.G_TRUE,
                                        p_validate_only	   IN	VARCHAR2	:=FND_API.G_TRUE,
--                                        p_validation_level IN	NUMBER	        :=FND_API.G_VALID_LEVEL_FULL,
                                        p_validation_level IN  VARCHAR2         := 100,
                                        p_calling_module   IN	VARCHAR2	:='SELF_SERVICE',
                                        p_commit	   IN	VARCHAR2	:=FND_API.G_FALSE,
                                        p_debug_mode	   IN	VARCHAR2	:='N',
                                        p_max_msg_count	   IN	NUMBER	        :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                        p_src_str_version_id      IN   NUMBER,
                                        p_pub_str_version_id      IN   NUMBER,     --published str, which is destination
                                        p_last_pub_str_version_id IN   NUMBER,
                                        x_return_status           OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count               OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data                OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Move_CI_Lnk_For_subproj_step1 begin');
    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint Move_CI_Lnk_For_subproj_step1;
    END IF;
--
  /*  IF (p_debug_mode = 'Y') THEN
        pa_debug.debug('Deleting the object_relationships_id => ');
    END IF;*/
--
    /*Move all the link coming into the working structure version*/
    Move_CI_Lnk_For_subproj_step2(p_src_str_version_id=>p_src_str_version_id,
                              p_dest_str_version_id=>p_pub_str_version_id,
                              p_publish_fl=>'N',
                                x_return_status =>  x_return_status,
                                 x_msg_count  =>  x_msg_count,
                                 x_msg_data   =>  x_msg_data);
    /*Move all the links coming into the last published structure version if there any */
    /*The links coming into the last published structure version should be coming*/
    /*from structure with versioning disabled                                    */
    IF p_last_pub_str_version_id IS NOT NULL THEN
       Move_CI_Lnk_For_subproj_step2(p_src_str_version_id=>p_last_pub_str_version_id,
                                 p_dest_str_version_id => p_pub_str_version_id,
                                 p_publish_fl => 'Y',
                                 x_return_status =>  x_return_status,
                                 x_msg_count  =>  x_msg_count,
                                 x_msg_data   =>  x_msg_data
                                 );
         -- 4537865
       IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR; -- To go to WHEN OTHERS Block
       END IF;
              -- End 4537865

    END IF;
--
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('Return status before the end of Move_CI_Lnk_For_subproj_step1=> '||x_return_status);
    END IF;
--
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.Move_CI_Lnk_For_subproj_step1 end');
    END IF;
--
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Move_CI_Lnk_For_subproj_step1;
       END IF;
       x_msg_count := FND_MSG_PUB.count_msg;
       x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       IF (p_commit = FND_API.G_TRUE) THEN
          ROLLBACK to Move_CI_Lnk_For_subproj_step1;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := FND_MSG_PUB.count_msg;
       --put message
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIPS_PVT',
                               p_procedure_name => 'Move_CI_Lnk_For_subproj_step1',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
END Move_CI_Lnk_For_subproj_step1;
--
--

-- API name                      : update_parent_WBS_flag_dirty
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
--   p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_structure_version_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  13-may-05   Maansari             -Created
--
--  Post FPM bug 4370533
--
-- Description
--
-- This API is used to update parent links working version flag to dirty. This is called from process_wbs_updates api in publish mode.

  procedure UPDATE_PARENT_WBS_FLAG_DIRTY
  (
   p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                      CONSTANT VARCHAR(30) := 'UPDATE_PARENT_WBS_FLAG_DIRTY';
    l_api_version                   CONSTANT NUMBER      := 1.0;

    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(250);
    l_data                          VARCHAR2(250);
    l_msg_index_out                 NUMBER;
    l_error_msg_code                VARCHAR2(250);

    l_lag_days                       NUMBER;
    l_comments                      VARCHAR2(240);
    l_rel_subtype                   VARCHAR2(30);
    l_debug_mode                    VARCHAR2(1);

    CURSOR cur_obj_rel
    IS
      SELECT *
        FROM pa_object_relationships
       WHERE object_id_to2 = p_project_id
         AND object_id_to1 = p_structure_version_id
         AND relationship_type = 'LW';    --Financial links should not be specified here bcoz Process WBS updates can be run only for workplan structures.
  BEGIN

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.UPDATE_DEPENDENCY begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_PARENT_WBS_FLAG_DIRTY;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
        pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.UPDATE_PARENT_WBS_FLAG_DIRTY', x_Msg => 'p_project_id: '||p_project_id, x_Log_Level=> 3);
        pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.UPDATE_PARENT_WBS_FLAG_DIRTY', x_Msg => 'p_structure_version_id: '||p_structure_version_id, x_Log_Level=> 3);
     END IF;

    FOR cur_obj_rel_rec in cur_obj_rel LOOP
        UPDATE pa_proj_elem_ver_structure
           SET PROCESS_UPDATE_WBS_FLAG = 'Y',
               process_code            = 'CPI'
          WHERE project_id = cur_obj_rel_rec.object_id_from2
            AND element_version_id=(select parent_structure_version_id
                                       FROM pa_proj_element_versions
                                      WHERE project_id=cur_obj_rel_rec.object_id_from2
                                        AND element_version_id= cur_obj_rel_rec.object_id_from1
                                   );
    END LOOP;

     IF l_debug_mode = 'Y' THEN
        pa_debug.write(x_Module=>'PA_RELATIONSHIP_PVT.UPDATE_PARENT_WBS_FLAG_DIRTY', x_Msg => 'Completed', x_Log_Level=> 3);
     END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_RELATIONSHIP_PVT.UPDATE_PARENT_WBS_FLAG_DIRTY END');
    END IF;


  EXCEPTION
    when FND_API.G_EXC_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_PARENT_WBS_FLAG_DIRTY;
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
    when FND_API.G_EXC_UNEXPECTED_ERROR then
      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_PARENT_WBS_FLAG_DIRTY;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'UPDATE_PARENT_WBS_FLAG_DIRTY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    when OTHERS then
      if p_commit = FND_API.G_TRUE then
         rollback to UPDATE_PARENT_WBS_FLAG_DIRTY;
      end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_PVT',
                              p_procedure_name => 'UPDATE_PARENT_WBS_FLAG_DIRTY',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      raise;
  END UPDATE_PARENT_WBS_FLAG_DIRTY;

end PA_RELATIONSHIP_PVT;

/
