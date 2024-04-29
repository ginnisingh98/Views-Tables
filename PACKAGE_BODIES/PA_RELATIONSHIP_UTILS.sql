--------------------------------------------------------
--  DDL for Package Body PA_RELATIONSHIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RELATIONSHIP_UTILS" as
/*$Header: PAXRELUB.pls 120.19.12010000.3 2009/06/22 09:11:32 paljain ship $*/

-- API name                      : Check_Create_Link_Ok
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : S if ok
--                                 E if error.
-- Parameters
--  p_element_version_id_from IN NUMBER
--  p_element_version_id_to   IN NUMBER
--  x_return_status           OUT VARCHAR2
--  x_error_message_code      OUT VARCHAR2
--
--
--  History
--
--  24-JAN-02   HSIU             -Modified
--                                  Added logic for linking within project from
--                                  costing to workplan structure in
--                                  check_create_link_ok api.
--  19-DEC-01   HSIU             -Modified
--                                  Sutask is always created if task can be created.
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Create_Link_Ok
  (
    p_element_version_id_from IN NUMBER
   ,p_element_version_id_to   IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_create_new_task VARCHAR2(1);
    l_dummy           VARCHAR2(1);
    l_err_code        NUMBER        := 0;
    l_err_stack       VARCHAR2(630);
    l_err_stage       VARCHAR2(80);
    l_element_id      NUMBER;
    l_object_type     VARCHAR2(30);

    l_project_id_from NUMBER;
    l_project_id_to   NUMBER;

    cursor Get_Element_Id(c_element_version_id NUMBER) IS
      select proj_element_id, object_type
        from pa_proj_element_versions
       where element_version_id = c_element_version_id;

    cursor Is_linked(c_element_version_id NUMBER) IS
      select '1'
        from pa_object_relationships
       where object_id_from1 = c_element_version_id
         and object_type_from = 'PA_TASKS'
         and relationship_type = 'L';

    cursor Is_structure(c_element_version_id NUMBER) IS
      select '1'
        from pa_object_relationships
       where object_id_from1 = c_element_version_id
         and object_type_from = 'PA_STRUCTURES';

    cursor Get_Struc_Ver_Id(c_element_version_id NUMBER) IS
      select parent_structure_version_id, project_id
        from pa_proj_element_versions
       where element_version_id = c_element_version_id;
    l_from_struc_ver_id           NUMBER;

    cursor Check_PA_TASKS_Exists(c_task_id NUMBER) IS
      select '1'
        from PA_TASKS
       where task_id = c_task_id;

    cursor Is_Same_Struc(c_elem_ver_from NUMBER, c_elem_ver_to NUMBER) IS
      select '1'
        from pa_proj_elements pe1,
             pa_proj_element_versions pev1a,
             pa_proj_element_versions pev1b,
             pa_proj_element_versions pev2a,
             pa_proj_element_versions pev2b
       where pev1b.element_version_id = c_elem_ver_from
         and pev1b.parent_structure_version_id = pev1a.element_version_id
         and pev1a.proj_element_id = pe1.proj_element_id
         and pev2b.element_version_id = c_elem_ver_to
         and pev2b.parent_structure_version_id = pev2a.element_version_id
         and pev2a.proj_element_id = pe1.proj_element_id;

/* Bug 2680486 -- Performance changes -- Commented the following cursor definition. Restructured it to
                                        avoid  Non-mergable view issue and use EXISTS rather than IN */

/*    cursor Is_Diff_Version_Linked(c_elem_ver_from NUMBER, c_elem_ver_to NUMBER) IS
      select '1'
        from pa_proj_elements pe1,
             pa_proj_element_versions pev1a,
             pa_proj_element_versions pev1b,
             pa_object_relationships r
       where pev1a.element_version_id = c_elem_ver_from
         and pev1a.proj_element_id = pe1.proj_element_id
         and pe1.project_id = pev1b.project_id
         and pe1.proj_element_id = pev1b.proj_element_id
         and pev1b.element_version_id = r.object_id_to1
         and r.object_id_from1 IN
       (select pev2b.element_version_id
          from pa_proj_elements pe2,
               pa_proj_element_versions pev2a,
               pa_proj_element_versions pev2b
         where pev2a.element_version_id = c_elem_ver_to
           and pev2a.proj_element_id = pe2.proj_element_id
           and pe2.project_id = pev2b.project_id
           and pe2.proj_element_id = pev2b.proj_element_id);
*/

    cursor Is_Diff_Version_Linked(c_elem_ver_from NUMBER, c_elem_ver_to NUMBER) IS
      select '1'
        from pa_proj_elements pe1,
             pa_proj_element_versions pev1a,
             pa_proj_element_versions pev1b,
             pa_object_relationships r
       where pev1a.element_version_id = c_elem_ver_from
         and pev1a.proj_element_id = pe1.proj_element_id
         and pe1.project_id = pev1b.project_id
         and pe1.proj_element_id = pev1b.proj_element_id
         and pev1b.element_version_id = r.object_id_to1
         and EXISTS
       (select pev2b.element_version_id
          from pa_proj_elements pe2,
               pa_proj_element_versions pev2a,
               pa_proj_element_versions pev2b
         where pev2a.element_version_id = c_elem_ver_to
           and pev2a.proj_element_id = pe2.proj_element_id
           and pe2.project_id = pev2b.project_id
           and pe2.proj_element_id = pev2b.proj_element_id
       and r.object_id_from1 = pev2b.element_version_id);

    cursor Is_Circular_Link(c_from NUMBER, c_to NUMBER) IS
      select '1'
        from pa_proj_element_versions a,
             pa_proj_element_versions b
       where a.element_version_id = c_from
         and a.proj_element_id = b.proj_element_id
         and a.project_id = b.project_id
         and b.element_version_id IN (
             select object_id_to1
               from pa_object_relationships
              start with object_id_from1 IN (
                    select b.element_version_id
                      from pa_proj_element_versions a,
                           pa_proj_element_versions b
                     where a.element_version_id = c_to
                       and a.proj_element_id = b.proj_element_id
                       and a.project_id = b.project_id
                          )
                and object_type_from IN ('PA_TASKS','PA_STRUCTURES')
                and object_type_to IN ('PA_TASKS','PA_STRUCTURES')
                and relationship_type IN ('S','L')
         connect by prior object_id_to1 = object_id_from1
                and object_type_from IN ('PA_TASKS','PA_STRUCTURES')
                and prior object_type_to IN ('PA_TASKS','PA_STRUCTURES')
                and prior relationship_type IN ('S','L')
             );


    cursor Get_Top_Nodes(c_element_version_id NUMBER) IS
      select a.object_id_from1
        from pa_object_relationships a
       where NOT EXISTS (select '1' from pa_object_relationships b
                                   where b.object_id_to1 = a.object_id_from1)
       start with a.object_id_to1 = c_element_version_id
              and a.object_type_to IN ('PA_STRUCTURES','PA_TASKS')
       connect by prior a.object_id_from1 = a.object_id_to1
              and a.relationship_type IN ('S','L')
       union
      select a.object_id_from1
        from pa_object_relationships a
       where a.object_id_from1 = c_element_version_id
         and object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
         and relationship_type = 'S';
    l_top_node_id         NUMBER;

    cursor Is_Version_Exist(c_top_node_id NUMBER, c_linking_node_id NUMBER) IS
      select object_id_to1
        from pa_object_relationships
       where relationship_type IN ('S', 'L')
       start with object_id_from1 = c_top_node_id
              and object_type_from IN ('PA_STRUCTURES','PA_TASKS')
       connect by object_id_from1 = prior object_id_to1
              and relationship_type IN ('L','S')
      intersect
      (
        select pev1b.element_version_id
          from pa_proj_element_versions pev1b,
               pa_proj_elements pe1,
               pa_proj_element_versions pev1a
         where pev1b.project_id = pe1.project_id
           and pev1b.proj_element_id = pe1.proj_element_id
           and pev1a.proj_element_id = pe1.proj_element_id
           and pev1a.element_version_id IN
         ( select object_id_to1
             from pa_object_relationships
            where relationship_type IN ('S','L')
            start with object_id_from1 = c_linking_node_id
                   and object_type_from IN ('PA_STRUCTURES','PA_TASKS')
            connect by object_id_from1 = prior object_id_to1
                   and relationship_type IN('L','S')
--           UNION
--           select object_id_from1
--             from pa_object_relationships
--            where relationship_type IN ('S','L')
--            start with object_id_to1 = c_linking_node_id
--                   and object_type_to IN ('PA_STRUCTURES','PA_TASKS')
--            connect by prior object_id_from1 = object_id_to1
--                   and relationship_type IN ('S','L')
           UNION
           select element_version_id
             from pa_proj_element_versions
            where element_version_id = c_linking_node_id
         )
      );
    l_existing_elem_ver_id         NUMBER;

    l_struc_ver_id_from            NUMBER;
    l_struc_ver_id_to              NUMBER;

    l_workplan_from                VARCHAR2(1);
    l_workplan_to                  VARCHAR2(1);
    l_financial_from                 VARCHAR2(1);
    l_financial_to                   VARCHAR2(1);
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --1 Check if need to create new task.

    --1a. check if link exist for this task
    --    if yes, error.
--    If (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      OPEN Is_linked(p_element_version_id_from);
      FETCH Is_linked into l_dummy;
      IF Is_linked%FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_PS_LINK_EXISTS';
        CLOSE Is_linked;
        return;
      END IF;
      CLOSE Is_linked;
--    END IF;

    --Removed, since subtask is always created now.
    --1b. check if the from element version is a structure
    --    if yes, create new task.
--    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
--      OPEN Is_structure(p_element_version_id_from);
--      FETCH Is_structure into l_dummy;
--      IF Is_structure%FOUND THEN
--        x_return_status := 'T';
--      END IF;
--      CLOSE Is_structure;
--    END IF;

--    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      --1c. check if from object is lowest task.
      --    if no, create new task.

--      IF (PA_PROJ_ELEMENTS_UTILS.IS_LOWEST_TASK(p_element_version_id_from) = 'N') THEN
--        --check if there is transaction to this task.
--        --if transaction exists, return error.
--        x_return_status := 'T';
--      ELSE

        --1d. Lowest task. Check if lowest task has transaction
        --    if yes, error.
        --Get structure version id

        OPEN Get_Struc_Ver_Id(p_element_version_id_from);
        FETCH Get_Struc_Ver_id into l_from_struc_ver_id, l_project_id_from;
        CLOSE Get_Struc_Ver_id;
        OPEN Get_Element_Id(p_element_version_id_from);
        FETCH Get_Element_Id into l_element_id, l_object_type;
        CLOSE Get_Element_Id;
        --Check if it has costing/billing structure type.
        --changed to financial
--dbms_output.put_line('l_element_id = '||l_element_id);

        If (PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                   l_from_struc_ver_id, 'FINANCIAL') = 'Y') THEN
          --Check for transaction for this task


          IF (l_object_type = 'PA_TASKS') THEN
--Bug 2183974
--Check if this task is valid in PA_TASKS first
            OPEN Check_PA_TASKS_Exists(l_element_id);
            FETCH Check_PA_TASKS_Exists into l_dummy;
            IF Check_PA_TASKS_Exists%NOTFOUND THEN
              CLOSE Check_PA_TASKS_Exists;
              x_error_message_code := 'PA_PS_PA_TASKS_NOT_EXISTS';
              x_return_status := FND_API.G_RET_STS_ERROR;
              return;
            ELSE
              --Task exists
              CLOSE Check_PA_TASKS_Exists;
              PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(x_task_id => l_element_id,
                                                  x_err_code => l_err_code,
                                                  x_err_stack => l_err_stack,
                                                  x_err_stage => l_err_stage
                                                  );
              IF (l_err_code <> 0) THEN

                --There is transaction, error.
                x_error_message_code := substrb(l_err_stage,0,30); -- 4537865 : Changed substr usage to substrb
                x_return_status := FND_API.G_RET_STS_ERROR;
                return;
              END IF;
            END IF;
          END IF;
        END IF;
--      END IF;
--    END IF;

    --Check if ok to link elements from two different structures (structure types)
    -- Get From Structure Version Id
    OPEN get_struc_ver_id(p_element_version_id_from);
    FETCH get_struc_ver_id into l_struc_ver_id_from, l_project_id_from;
    CLOSE get_struc_ver_id;
    l_financial_from := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                                          l_struc_ver_id_from,
                                                          'FINANCIAL');
    l_workplan_from := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                                          l_struc_ver_id_from,
                                                          'WORKPLAN');

    -- Get To Structure Version Id
    OPEN get_struc_ver_id(p_element_version_id_to);
    FETCH get_struc_ver_id into l_struc_ver_id_to, l_project_id_to;
    CLOSE get_struc_ver_id;
    l_financial_to := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                                          l_struc_ver_id_to,
                                                          'FINANCIAL');
    l_workplan_to := PA_PROJECT_STRUCTURE_UTILS.Get_Struc_Type_For_Version(
                                                          l_struc_ver_id_to,
                                                          'WORKPLAN');
    --Compare structure types
    If (l_workplan_from = 'Y') and
       (l_financial_from = 'N') and
       (l_workplan_to = 'N') and
       (l_financial_to = 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_LINK_WP_TO_FIN_ERR';
      return;
    END IF;

    If (l_financial_from = 'Y') and
       (l_workplan_to = 'Y') and
       (l_financial_to = 'N') THEN
      If (l_workplan_from = 'N') THEN
        IF (l_project_id_from <> l_project_id_to) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_LINK_FIN_TO_WP_ERR';
          return;
        END IF;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_PS_LINK_FIN_TO_WP_ERR';
        return;
      END IF;
    END IF;

--dbms_output.put_line('checking linking within program:'||p_element_version_id_from||','||p_element_version_id_to);
    --Check if linking within structure
    OPEN Is_Same_Struc(p_element_version_id_from, p_element_version_id_to);
    FETCH Is_Same_Struc into l_dummy;
    If Is_Same_Struc%FOUND THEN
      CLOSE Is_Same_Struc;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_LINK_WITHIN_STRUCTURE';
      return;
    END IF;
    CLOSE Is_Same_Struc;
--dbms_output.put_line('done checking linking within program');

    --Check if a version of object A is linked to object B, not any version of object B
    --  should be linked to any version of object A.
--dbms_output.put_line('checking linking versions');
    OPEN Is_Diff_Version_Linked(p_element_version_id_from, p_element_version_id_to);
    FETCH Is_Diff_Version_Linked into l_dummy;
    IF Is_Diff_Version_Linked%FOUND THEN
      CLOSE Is_Diff_Version_Linked;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_DIFF_VER_LINKED';
      return;
    END IF;
    CLOSE Is_Diff_Version_Linked;

    OPEN Is_Circular_Link(p_element_version_id_from, p_element_version_id_to);
    FETCH Is_Circular_Link into l_dummy;
    IF Is_Circular_Link%FOUND THEN
      CLOSE Is_Circular_Link;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_PS_DIFF_VER_LINKED';
      return;
    END IF;
    CLOSE Is_Circular_Link;
--dbms_output.put_line('done checking linking versions');

    --Check if any linking objects or its versions exist in the hierarchy.
    --  needs to be enhanced in the future.
--dbms_output.put_line('Top node from => '||p_element_version_id_from);
    OPEN Get_Top_Nodes(p_element_version_id_from);
    LOOP
      FETCH Get_Top_Nodes INTO l_top_node_id;
--dbms_output.put_line('top node = '||l_top_node_id);
      EXIT WHEN Get_Top_Nodes%NOTFOUND;

--dbms_output.put_line('checking anything/version exists in hierarchy');
      OPEN Is_Version_Exist(l_top_node_id, p_element_version_id_to);
      FETCH Is_Version_Exist into l_existing_elem_ver_id;
      IF Is_Version_Exist%FOUND THEN
        CLOSE Is_Version_Exist;
        CLOSE Get_Top_Nodes;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_PS_LINK_ELEM_EX_IN_HIER';
        return;
      END IF;
      CLOSE Is_Version_Exist;
--dbms_output.put_line('done checking anything/version exists in hierarchy');
    END LOOP;
    CLOSE Get_Top_Nodes;

  -- 4537865
  EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_error_message_code := SQLCODE ;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIP_UTILS',
                              p_procedure_name => 'CHECK_CREATE_LINK_OK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;
  END CHECK_CREATE_LINK_OK;

-- API name                      : Check_Create_Dependency_Ok
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--  p_element_version_id_from IN NUMBER
--  p_element_version_id_to   IN NUMBER
--  x_return_status           OUT VARCHAR2
--  x_error_message_code      OUT VARCHAR2
--
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Create_Dependency_Ok
  (
    p_element_version_id_from IN NUMBER
   ,p_element_version_id_to   IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END CHECK_CREATE_DEPENDENCY_OK;


-- API name                      : Check_Create_Association_Ok
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--  p_element_version_id_from IN NUMBER
--  p_element_version_id_to   IN NUMBER
--  x_return_status           OUT VARCHAR2
--  x_error_message_code      OUT VARCHAR2
--
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Create_Association_Ok
  (
    p_element_version_id_from IN NUMBER
   ,p_element_version_id_to   IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END CHECK_CREATE_ASSOCIATION_OK;


-- API name                      : parent_LP_link_exists
-- Type                          : Private Function
-- Pre-reqs                      : None
-- Return Value                  : Y or N
-- Parameters
--  p_parent_project_id IN NUMBER
--  p_sub_project_id   IN NUMBER
--
--
--  History
--
--  05-DEC-03   Maansari             -Created
--
--  Description
--
-- This fucntion returns 'Y' if there exists a Link from parent latest published version to the
-- subproject.  This is used in view PA_STRUCTURES_LINKS_V to select working version if there is no
-- link from the parent latest published version to the subproject.
--
--


  Function parent_LP_link_exists
  (
    p_parent_project_id IN NUMBER
   ,p_sub_project_id   IN NUMBER
  ) RETURN VARCHAR2 IS

    CURSOR cur_parent_lp_link
    IS
      SELECT 'Y'
        FROM pa_proj_elements ppe
            ,pa_proj_element_versions ppv1    /* to get link task version id */
            ,pa_proj_element_versions ppv2    /* to get sub project structure version ids */
            ,pa_object_relationships por
       WHERE ppe.project_id = p_parent_project_id
         AND ppe.link_task_flag = 'Y'
         AND ppe.project_id = ppv1.project_id
         AND ppe.proj_element_id = ppv1.proj_element_id
         AND ppv1.parent_structure_version_id IN ( SELECT ppevs.element_version_id
                                                    FROM pa_proj_elem_ver_structure ppevs
                                                   WHERE ppevs.project_id = p_parent_project_id
                                                     AND ppevs.status_code = 'STRUCTURE_PUBLISHED'
                                                     AND ppevs.latest_eff_published_flag = 'Y' )
         AND ppv2.project_id = p_sub_project_id
         AND ppv2.object_type = 'PA_STRUCTURES'
         AND ppv1.element_version_id = por.object_id_from1
         AND por.relationship_type in ( 'LW', 'LF' ) -- ( 'WL', 'FL' ) -- Bug # 4760126.
         AND ppv2.element_version_id = por.object_id_to1
	 AND object_type_from = 'PA_TASKS'                  --Bug 6429264
	 AND object_type_to = 'PA_STRUCTURES'               --Bug 6429264
         ;
     l_return_value    VARCHAR2(1) := 'N';
  BEGIN

       OPEN cur_parent_lp_link;
       FETCH cur_parent_lp_link INTO l_return_value;
       CLOSE cur_parent_lp_link;

       RETURN l_return_value;
  END parent_LP_link_exists;

-- API name                      : check_create_intra_dep_ok
-- Type                          : Private Check procedure
-- Pre-reqs                      : None
-- Return Value                  : Returns error status
-- Parameters
--  p_pre_project_id    IN NUMBER
--  p_pre_task_ver_id   IN NUMBER
--  p_project_id        IN NUMBER
--  p_task_ver_id       IN NUMBER
--
--
--  History
--
--  19-DEC-03   Maansari             -Created
--
--  Description
--
-- This check procedure check s the following business rules and returns status 'E' with proper
-- error message if any of the rules fails.
--a.    No duplicates.
--b.    No circular dependencies between two or more tasks.
--c.    A task cannot depend on itself.
--d.    You cannot create a dependency from an object (predecessor) to you (successor) if that object has
--      subtasks (successor) that depend on you (predecessor).
--e.    You cannot create a dependency between objects that are in the same direct path from lowest
--      node to the top node.
--
-- Notes:  The p_pre_<> paramaters are for predecessor tasks and stored in object_id_to1 colunmn
--         of pa_object_relationships.

  procedure check_create_intra_dep_ok(
   p_pre_project_id    IN NUMBER
  ,p_pre_task_ver_id   IN NUMBER
  ,p_project_id        IN NUMBER
  ,p_task_ver_id       IN NUMBER
  ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

    CURSOR cur_a
    IS
      SELECT 'x'
        FROM pa_object_relationships
       WHERE object_id_from1 = p_task_ver_id
         AND object_id_from2 = p_project_id
         AND object_id_to1 = p_pre_task_ver_id
         AND object_id_to2 = p_pre_project_id
         AND relationship_type = 'D'
       ;

    CURSOR cur_b
    IS
      SELECT 'x'
                      FROM (
                        SELECT object_id_to1
                        FROM pa_object_relationships por2
                        WHERE relationship_type = 'D'
                        AND   por2.object_id_from2 = por2.object_id_to2                --Bug 3629024
                        START WITH por2.object_id_from1 = p_pre_task_ver_id
                        AND        relationship_type    = 'D'                          --bug 3944567
                        CONNECT BY por2.object_id_from1 = PRIOR por2.object_id_to1
                        AND        relationship_type    = PRIOR relationship_type
                        AND        relationship_type    = 'D'
                        AND        por2.object_id_from2 = PRIOR por2.object_id_from2 ) --Bug 3629024
                      where object_id_to1 = p_task_ver_id;

   /* the successor is a prdecessor of the sub-tasks of the predecessor.*/
/*Commented out for bug 3629024
   CURSOR cur_d
   IS
    SELECT 'x'
      FROM pa_object_relationships por1
     WHERE por1.relationship_type = 'D'
       AND por1.object_id_to1 = p_task_ver_id
       AND por1.object_id_from1 IN
        ( SELECT por2.object_id_to1
               FROM pa_object_relationships por2
              START WITH por2.object_id_from1 = p_pre_task_ver_id
            CONNECT BY por2.object_id_from1 = prior por2.object_id_to1
                AND por2.relationship_type = prior por2.relationship_type
                AND por2.relationship_type = 'S')
    ;
*/
   CURSOR cur_e1_get_parent( c_child_task_ver_id NUMBER )
   IS
    SELECT object_id_from1
      FROM pa_object_relationships
     where object_id_to1 = c_child_task_ver_id
     and relationship_type = 'S'
      ;

   l_dummy_char          VARCHAR2(1);
   l_child_task_ver_id   NUMBER;
   l_parent_task_ver_id  NUMBER;
BEGIN

    IF p_pre_project_id IS NULL OR
       p_pre_task_ver_id IS NULL OR
       p_project_id IS NULL OR
       p_task_ver_id   IS NULL
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_PARAMS_NULL');
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF p_pre_project_id <> p_project_id
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_NOT_INTRA_DEPND');
        raise FND_API.G_EXC_ERROR;
    END IF;

    --c) a task cannot depend on it-self
    IF p_pre_task_ver_id = p_task_ver_id
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_NO_SELF_DEPDN');
        raise FND_API.G_EXC_ERROR;
    END IF;

    OPEN cur_a;
    FETCH cur_a INTO l_dummy_char;
    IF cur_a%FOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_DEPND_EXISTS');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_a;

    OPEN cur_b;
    FETCH cur_b INTO l_dummy_char;
    IF cur_b%FOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_CIRCLR_DEPND_EXISTS');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_b;

/*  Following code commented out for bug 3629024
    OPEN cur_d;
    FETCH cur_d INTO l_dummy_char;
    IF cur_d%FOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_SUBTASKS_DEPND_EXISTS');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_d;
*/
    --Bug 3629024 : Check for the existence of a closed path
    --This bug fix is for rule D
    IF get_parents_childs(p_pre_task_ver_id, p_task_ver_id) = TRUE THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count     := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_SUBTASKS_DEPND_EXISTS');
        raise FND_API.G_EXC_ERROR;
    END IF;

/*    --check if predecessor is parent in the same line of hierarchy.
    OPEN cur_e1;
    FETCH cur_e1 INTO l_dummy_char;
    IF cur_e1%FOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_NO_PARENT_PRED');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_e1;

    --check if predecessor is child in the same line of hierarchy.
    OPEN cur_e2;
    FETCH cur_e2 INTO l_dummy_char;
    IF cur_e2%FOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_NO_CHILD_PRED');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_e2;
*/

  /* check for predecessor is parent */
  l_child_task_ver_id := p_task_ver_id;
  WHILE ( l_child_task_ver_id IS NOT NULL ) LOOP
       OPEN cur_e1_get_parent( l_child_task_ver_id);
       FETCH cur_e1_get_parent INTO l_parent_task_ver_id; /* predecessor is parent */
       IF cur_e1_get_parent%NOTFOUND THEN
         close cur_e1_get_parent;
         exit;
       END IF;
       CLOSE cur_e1_get_parent;

       IF l_parent_task_ver_id IS NOT NULL AND
          l_parent_task_ver_id = p_pre_task_ver_id
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := FND_MSG_PUB.count_msg;
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_PS_NO_PARENT_PRED');
          raise FND_API.G_EXC_ERROR;
       ELSE
          l_child_task_ver_id := l_parent_task_ver_id;
       END IF;
  END LOOP;


  /* check for predecessor is child or successor is a parent */
  /* starting from predecessor, find out the parent up the hierarchy and compare the
     successor with the parent found. if successor is same as the parent found then it means
     the predecessor is a child of the succeesor down the line in the hierarchy */
  /* it is not possible to traverse down the hierarchy to find out whether the predecessor is a
     child in the same line of successsor starting from the suceesor therefore traversing up
     the hierarchy starting from predecessor*/

  l_child_task_ver_id := p_pre_task_ver_id;
  WHILE ( l_child_task_ver_id IS NOT NULL ) LOOP
       OPEN cur_e1_get_parent( l_child_task_ver_id);
       FETCH cur_e1_get_parent INTO l_parent_task_ver_id;
       IF cur_e1_get_parent%NOTFOUND THEN
         close cur_e1_get_parent;
         exit;
       END IF;
       CLOSE cur_e1_get_parent;

       IF l_parent_task_ver_id IS NOT NULL AND
          l_parent_task_ver_id = p_task_ver_id  /* is succssor a parent in the same line of hierarcgy*/
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := FND_MSG_PUB.count_msg;
          PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_PS_NO_CHILD_PRED');
          raise FND_API.G_EXC_ERROR;
       ELSE
          l_child_task_ver_id := l_parent_task_ver_id;
       END IF;
  END LOOP;


  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;     -- 4537865 : RESET OUT param
      x_msg_data := SUBSTRB(SQLERRM,1,240);     -- 4537865 : RESET OUT PARAM
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_UTILS',
                              p_procedure_name => 'check_create_intra_dep_ok',
                              p_error_text     => x_msg_data ); -- 4537865
      raise;

END check_create_intra_dep_ok;

-- API name                      : check_create_intra_dep_ok
-- Type                          : Private Check procedure
-- Pre-reqs                      : None
-- Return Value                  : Returns error status
-- Parameters
--  p_pre_project_id    IN NUMBER
--  p_pre_task_ver_id   IN NUMBER
--  p_project_id        IN NUMBER
--  p_task_ver_id       IN NUMBER
--
--
--  History
--
--  19-DEC-03   Maansari             -Created
--
--  Description
--
-- This check procedure check s the following business rules and returns status 'E' with proper
-- error message if any of the rules fails.
--a.    No duplicates.
-- Notes:  The p_pre_<> paramaters are for predecessor tasks and stored in object_id_to1 colunmn
--         of pa_object_relationships.

  procedure check_create_inter_dep_ok(
   p_pre_project_id    IN NUMBER
  ,p_pre_task_ver_id   IN NUMBER
  ,p_project_id        IN NUMBER
  ,p_task_ver_id       IN NUMBER
  ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

    CURSOR cur_a
    IS
      SELECT 'x'
        FROM pa_object_relationships
       WHERE object_id_from1 = p_task_ver_id
         AND  object_id_from2 = p_project_id
         AND object_id_to1 = p_pre_task_ver_id
         AND object_id_to2 = p_pre_project_id
         AND relationship_type = 'D'
       ;

   CURSOR CUR_valid_sucsr_proj_task
   IS
    SELECT 'x'
      FROM pa_proj_element_versions
     WHERE project_id = p_project_id
      AND element_version_id = p_task_ver_id
     ;


   CURSOR CUR_valid_pred_proj_task
   IS
    SELECT 'x'
      FROM pa_proj_element_versions
     WHERE project_id = p_pre_project_id
      AND element_version_id = p_pre_task_ver_id
     ;

   l_dummy_char   VARCHAR2(1);

-- Begin fix for Bug # Bug # 4256435.

cursor cur_sub_proj_hierarchy(c_pre_project_id NUMBER) is
-- This query selects all the parent projects of the predecessor project.
select por.object_id_from1 task_ver_id, por.object_id_from2 project_id
from pa_object_relationships por
where por.relationship_type in ('LW', 'LF')
start with por.object_id_to2 = c_pre_project_id
connect by prior por.object_id_from2 = por.object_id_to2
and prior por.relationship_type = por.relationship_type
and por.relationship_type in ('LW', 'LF')
AND object_type_from = 'PA_TASKS'                  --Bug 6429264
AND object_type_to = 'PA_STRUCTURES'               --Bug 6429264
union all
-- This query selects all the child projects of the predecessor project.
select por.object_id_to1 task_ver_id, por.object_id_to2 project_id
from pa_object_relationships por
where por.relationship_type in ('LW', 'LF')
start with por.object_id_from2 = c_pre_project_id
connect by prior por.object_id_to2 = por.object_id_from2
and prior por.relationship_type = por.relationship_type
and por.relationship_type in ('LW', 'LF')
AND object_type_from = 'PA_TASKS'                  --Bug 6429264
AND object_type_to = 'PA_STRUCTURES'               --Bug 6429264
;

rec_sub_proj_hierarchy cur_sub_proj_hierarchy%ROWTYPE;

cursor cur_linking_task(c_task_ver_id NUMBER, c_linking_task_ver_id NUMBER) is
select 'Y'
from pa_object_relationships por
where por.object_id_from1 = c_task_ver_id
and por.object_id_to1 = c_linking_task_ver_id
and por.relationship_type = 'S';

l_link_exists   VARCHAR2(1) := 'N';

-- End fix for Bug # Bug # 4256435.

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --check valid for null parameters
    IF p_pre_project_id IS NULL OR
       p_pre_task_ver_id IS NULL OR
       p_project_id IS NULL OR
       p_task_ver_id   IS NULL
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_PARAMS_NULL');
        raise FND_API.G_EXC_ERROR;
    END IF;

    --check for inter projects. The successor project and predecssor projects should be different.
    IF p_pre_project_id = p_project_id
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_NOT_INTER_DEPND');
        raise FND_API.G_EXC_ERROR;
    END IF;

-- Begin fix for Bug # Bug # 4256435.

        for rec_sub_proj_hierarchy in cur_sub_proj_hierarchy(p_pre_project_id)
        loop

                if (rec_sub_proj_hierarchy.project_id = p_project_id) then

                        open  cur_linking_task(p_task_ver_id, rec_sub_proj_hierarchy.task_ver_id);
                        fetch cur_linking_task into l_link_exists;
                        close cur_linking_task;

                        if (l_link_exists = 'Y') then

                                x_return_status := FND_API.G_RET_STS_ERROR;
                                x_msg_count := FND_MSG_PUB.count_msg;

                                PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                                                     , p_msg_name       => 'PA_WP_PRGM_EXISTS_NO_DEP');

                                raise FND_API.G_EXC_ERROR;

                        end if;
                end if;

        end loop;

-- End fix for Bug # Bug # 4256435.

/* do we really need this validation here?
    --validate successor project id and task ver id combination.
    OPEN cur_valid_sucsr_proj_task;
    FETCH cur_valid_sucsr_proj_task INTO l_dummy;
    IF cur_valid_sucsr_proj_task%NOTFOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_INV_SUCSR_PRJ_TSK');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_valid_sucsr_proj_task;

    --validate predecessor project id and task ver id combination.
    OPEN cur_valid_pred_proj_task;
    FETCH cur_valid_pred_proj_task INTO l_dummy;
    IF cur_valid_pred_proj_task%NOTFOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_INV_PRED_PRJ_TSK');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_valid_pred_proj_task;
*/

    --check for duplicate dependency.
    OPEN cur_a;
    FETCH cur_a INTO l_dummy_char;
    IF cur_a%FOUND
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.count_msg;
        PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_PS_DEPND_EXISTS');
        raise FND_API.G_EXC_ERROR;
    END IF;
    CLOSE cur_a;

  EXCEPTION
    when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;         -- 4537865 : RESET OUT param
      x_msg_data := SUBSTRB(SQLERRM,1,240);     -- 4537865 : RESET OUT PARAM
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_RELATIONSHIOP_UTILS',
                              p_procedure_name => 'check_create_inter_dep_ok',
                              p_error_text     => x_msg_data); -- 4537865
      raise;

END check_create_inter_dep_ok;


FUNCTION DISPLAY_PREDECESSORS
  ( p_element_version_id IN NUMBER)
  RETURN  VARCHAR2 IS
--
-- To modify this template, edit file FUNC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the function
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
-- SMUKKA      01/28/2004   Initial Version

   l_task_name_list                 VARCHAR2(1220):=NULL; --bug 4141897
   l_task_count                     NUMBER:=0;
CURSOR cur_task_names( c_element_version_id NUMBER )
  IS
    SELECT ppe.name task_name
      FROM pa_proj_element_versions ppev,
           pa_proj_elements ppe
     WHERE ppev.proj_element_id = ppe.proj_element_id
       and ppev.project_id = ppe.project_id
       AND ppev.element_version_id IN (SELECT object_id_to1
                                         FROM pa_object_relationships por
                                        WHERE por.object_id_from1   = c_element_version_id
    --Bug8534395: Commented below predicate to allow tasks from other project to be shown as predecessors.
                                          --AND por.object_id_from2   = por.object_id_to2
                                          AND por.object_type_from  = 'PA_TASKS' --4141109 Replaced LIKE with Equijoin
                                          AND por.object_type_to    = 'PA_TASKS' --4141109 Replaced LIKE with Equijoin
                                          AND por.relationship_type = 'D');  --4141109 Replaced LIKE with Equijoin
    l_cur_task_names_rec  cur_task_names%ROWTYPE;
BEGIN
   OPEN cur_task_names(p_element_version_id);
   LOOP
      FETCH cur_task_names into l_cur_task_names_rec;
      IF cur_task_names%NOTFOUND THEN
         EXIT;
      ELSE
         l_task_count:=l_task_count+1;
         IF l_task_count = 1 THEN
            l_task_name_list:= l_task_name_list||l_cur_task_names_rec.task_name;
         ELSIF l_task_count > 5 THEN
               l_task_name_list:= l_task_name_list||'...';
         ELSE
            l_task_name_list := l_task_name_list||','||l_cur_task_names_rec.task_name;
         END IF;
      END IF;
   END LOOP;
   CLOSE cur_task_names;
   RETURN l_task_name_list ;
EXCEPTION
   WHEN OTHERS THEN
       NULL ;
END DISPLAY_PREDECESSORS;


FUNCTION ChecK_dep_exists(p_element_version_id IN NUMBER)
  RETURN VARCHAR2
IS
  CURSOR get_dependency IS
    SELECT 1 from pa_object_relationships
     where relationship_type = 'D'
       and (object_id_from1 = p_element_version_id OR
            object_id_to1 = p_element_version_id);
  l_dummy NUMBER;
BEGIN
  OPEN get_Dependency;
  FETCH get_Dependency into l_dummy;
  IF get_dependency%FOUND THEN
    CLOSE get_dependency;
    return 'Y';
  END IF;
  CLOSE get_Dependency;
  return 'N';
END CHECK_DEP_EXISTS;


FUNCTION Is_Proj_Top_Program(p_project_id IN NUMBER)
  RETURN VARCHAR2
IS
  --Bug No 3634315 Performance Fix, to avoid full table scan on pa_object_relationships table.
/*  CURSOR c1 IS
    select 1
      from pa_object_relationships
     where relationship_type IN ('LW', 'LF')
       and object_id_to2 = p_project_id;*/
    CURSOR c1 IS
    select 1
      from pa_object_relationships por,
           pa_proj_element_versions ppev
     where por.relationship_type IN ('LW', 'LF')
       and ppev.element_version_id = por.object_id_to1
       and por.object_id_to2 = ppev.project_id
       and por.object_id_to2 = p_project_id
       AND object_type_from = 'PA_TASKS'                   --Bug 6429264
       AND object_type_to = 'PA_STRUCTURES';               --Bug 6429264

  CURSOR c2 IS
    select 1
      from pa_object_relationships
     where relationship_type IN ('LW', 'LF')
       and object_id_from2 = p_project_id
       AND object_type_from = 'PA_TASKS'                   --Bug 6429264
       AND object_type_to = 'PA_STRUCTURES';               --Bug 6429264

  l_dummy number;
BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%FOUND THEN
    CLOSE c1;
    return 'N';
  END IF;
  CLOSE c1;

  OPEN c2;
  FETCH c2 into l_dummy;
  IF c2%NOTFOUND THEN
    CLOSE c2;
    return 'N';
  END IF;
  CLOSE c2;

  return 'Y';
END Is_Proj_Top_Program;

FUNCTION Is_Proj_Sub_Project(p_project_id IN NUMBER)
  RETURN VARCHAR2
IS
  --Bug No 3634315 Performance Fix, to avoid full table scan on pa_object_relationships table.
/*  CURSOR c1 IS
    select 1
      from pa_object_relationships
     where relationship_type IN ('LW', 'LF')
       and object_id_to2 = p_project_id;*/
    CURSOR c1 IS
    select 1
      from pa_object_relationships por,
           pa_proj_element_versions ppev
     where por.relationship_type IN ('LW', 'LF')
       and ppev.element_version_id = por.object_id_to1
       and por.object_id_to2 = ppev.project_id
       and por.object_id_to2 = p_project_id
       AND object_type_from = 'PA_TASKS'                   --Bug 6429264
       AND object_type_to = 'PA_STRUCTURES';               --Bug 6429264

  l_dummy NUMBER;
BEGIN
  open c1;
  FETCH c1 into l_dummy;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    return 'N';
  END IF;
  CLOSE c1;

  return 'Y';
END Is_Proj_Sub_Project;

FUNCTION DISABLE_SYS_PROG_OK(p_project_id NUMBER)
  RETURN varchar2
IS
  CURSOR c1 IS
    select 1
    from pa_object_relationships
    where relationship_type IN ('LW', 'LF')
    and object_id_from2 = p_project_id;
  l_dummy NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%found then
    CLOSE c1;
    return 'N';
  END IF;
  CLOSE c1;
  return 'Y';
END DISABLE_SYS_PROG_OK;

FUNCTION DISABLE_MULTI_PROG_OK(p_project_id NUMBER)
  RETURN varchar2
IS
  --Bug No 3634315 Performance Fix, to avoid full table scan on pa_object_relationships table.
/*  CURSOR c1(c_parent_project_id NUMBER, c_child_project_id NUMBER) IS
    select count(1)
    from pa_object_relationships
    where relationship_type IN ('LW', 'LF')
    and object_id_to2 = c_child_project_id
    and object_id_from1 <> c_parent_project_id;*/
  CURSOR c1(c_parent_project_id NUMBER, c_child_project_id NUMBER) IS
  select count(1)
    from pa_object_relationships por,
         pa_proj_element_versions ppev
    where relationship_type IN ('LW', 'LF')
    and ppev.element_version_id = object_id_to1
    and por.object_id_to2 = ppev.project_id
    and object_id_to2 = c_child_project_id
    and object_id_from2 <> c_parent_project_id;--bug 4244482

  CURSOR c2 IS
    select object_id_from2, object_Id_to2
      from pa_object_relationships
     where relationship_type IN ('LW')   --bug 3962849
  start with object_id_from2 = p_project_id
         and relationship_type = 'LW'
  connect by prior object_id_to2 = object_id_from2
         and prior relationship_type = relationship_type;

  CURSOR c3 IS
    select object_id_from2, object_Id_to2
      from pa_object_relationships
     where relationship_type IN ('LF')   --bug 3962849
  start with object_id_from2 = p_project_id
         and relationship_type = 'LF'
  connect by prior object_id_to2 = object_id_from2
         and prior relationship_type = relationship_type;

  l_parent_proj_id NUMBER;
  l_child_proj_id NUMBER;
  l_count NUMBER;
BEGIN
  OPEN c2;
  LOOP
    FETCH c2 into l_parent_proj_id, l_child_proj_id;
    EXIT WHEN C2%NOTFOUND;
    OPEN c1(l_parent_proj_id, l_child_proj_id);
    FETCH c1 INTO l_count;
    IF l_count > 0 THEN
      CLOSE c1;
      CLOSE c2;
      return 'N';
    END IF;
    CLOSE c1;
  END LOOP;
  CLOSE c2;

  OPEN c3;
  LOOP
    FETCH c3 into l_parent_proj_id, l_child_proj_id;
    EXIT WHEN C3%NOTFOUND;
    OPEN c1(l_parent_proj_id, l_child_proj_id);
    FETCH c1 INTO l_count;
    IF l_count > 0 THEN
      CLOSE c1;
      CLOSE c3;
      return 'N';
    END IF;
    CLOSE c1;
  END LOOP;
  CLOSE c3;

  return 'Y';
END DISABLE_MULTI_PROG_OK;

FUNCTION CREATE_SUB_PROJ_ASSO_OK(p_task_version_id NUMBER, p_project_id NUMBER,
                                 p_structure_type VARCHAR2 := 'WORKPLAN')
  RETURN VARCHAR2
IS
  CURSOR get_project_id(c_element_version_id NUMBER) IS
    select project_id
      from pa_proj_element_versions
     where element_version_id = c_element_version_id;

  CURSOR get_loop1(c_project_id NUMBER) IS
    select object_Id_to2, object_id_from2 -- Fix for Bug # 4297715.
      from pa_object_relationships
     where relationship_type IN ('LW')
     start with object_id_from2 = c_project_id
   connect by prior object_id_to2 = object_id_from2
                and prior relationship_type = relationship_type
                and relationship_type = 'LW';

  CURSOR get_loop2(c_project_id NUMBER) IS
    select object_Id_to2, object_id_from2 -- Fix for Bug # 4297715.
      from pa_object_relationships
     where relationship_type IN ('LF')
     start with object_id_from2 = c_project_id
   connect by prior object_id_to2 = object_id_from2
                and prior relationship_type = relationship_type
                and relationship_type = 'LF';
--
  -- Start of Bug 3621794
  CURSOR get_proj_prog_fl(c_project_id NUMBER) IS
  SELECT sys_program_flag
    FROM pa_projects_all
   WHERE project_id =c_project_id;

   CURSOR get_parent_sub_proj(c_project_id NUMBER) IS
     SELECT ppa.sys_program_flag
     FROM pa_proj_element_versions ppev,
          pa_proj_elements ppe,
          pa_projects_all ppa
    WHERE ppe.project_id = ppev.project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppe.object_type = 'PA_TASKS'
      AND ppe.project_id = ppa.project_id
      AND ppev.element_version_id IN (
                     SELECT object_id_from1
                       FROM pa_object_relationships
                      WHERE relationship_type IN ('LW','LF')
                 START WITH object_id_to2 = c_project_id
                        AND object_type_to = 'PA_STRUCTURES'
                 CONNECT BY object_id_from2 = prior object_id_to2
                        and prior relationship_type = relationship_type
                        AND relationship_type IN ('LW','LF')
                        AND object_type_from = 'PA_TASKS');
  -- End of Bug 3621794
--
  --bug 3893970
  CURSOR get_multi_rollup(c_project_id NUMBER) IS
  select nvl(ALLOW_MULTI_PROGRAM_ROLLUP,'N')
    from pa_projects_all
   where project_id = c_project_id;

  CURSOR get_child_links(c_project_id NUMBER, c_parent_proj_id NUMBER) IS
  select distinct(object_id_from2)
      from pa_object_relationships a
     where a.relationship_type IN ('LW','LF')
       and a.object_id_to2 = c_project_id
       and a.object_id_from2 <> c_parent_proj_id -- Fix for Bug # 4297715.
       and exists (select 1 from PA_PROJ_ELEMENT_VERSIONS elv  /* Added the exists for Bug 6148092 */
              where elv.element_version_id = a.object_id_from1
              and ((elv.PARENT_STRUCTURE_VERSION_ID =
                   PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(elv.project_id))
                or (elv.PARENT_STRUCTURE_VERSION_ID =
                   PA_PROJECT_STRUCTURE_UTILS.get_latest_wp_version(elv.project_id))
                )
              );

  l_linked_parent_proj_id NUMBER;
  l_multi_rollup_flag VARCHAR2(1);
  l_dest_multi_rollup_flag VARCHAR2(1);
  --end bug 3893970

  l_src_project_id NUMBER;
  l_dest_project_id NUMBER;
  l_proj_id NUMBER;
  l_proj_prog_fl  VARCHAR2(1);                 --Bug 3621794

-- Begin Fix for Bug # 4297715.

cursor cur_get_status_code(c_task_version_id NUMBER) is
select ppevs.status_code
from pa_proj_elem_ver_structure ppevs, pa_proj_element_versions ppev
where ppev.element_version_id = c_task_version_id
and ppev.project_id = ppevs.project_id -- Bug # 4868867.
and ppev.parent_structure_version_id = ppevs.element_version_id;

l_status_code   VARCHAR2(150) := NULL;

l_proj_id_from  NUMBER := NULL;

-- End Fix for Bug # 4297715.

-- Begin fix for Bug # Bug # 4256435.

cursor cur_dep_hierarchy(c_src_task_ver_id NUMBER) is
-- This query selects all the successor projects of the source project.
select por.object_id_from2 project_id
from pa_object_relationships por
where por.relationship_type = 'D'
start with por.object_id_to1 = c_src_task_ver_id
-- connect by prior por.object_id_from2 = por.object_id_to2 -- Fix for Bug # 4256435.
connect by prior por.object_id_from1 = por.object_id_to1 -- Fix for Bug # 4256435.
and prior por.relationship_type = por.relationship_type
and por.relationship_type = 'D'
union all
-- This query selects all the predecessor projects of the source project.
select por.object_id_to2 project_id
from pa_object_relationships por
where por.relationship_type = 'D'
start with por.object_id_from1 = c_src_task_ver_id
-- connect by prior por.object_id_to2 = por.object_id_from2 -- Fix for Bug # 4256435.
connect by prior por.object_id_to1 = por.object_id_from1 -- Fix for Bug # 4256435.
and prior por.relationship_type = por.relationship_type
and por.relationship_type = 'D';

rec_dep_hierarchy cur_dep_hierarchy%ROWTYPE;

-- End fix for Bug # Bug # 4256435.

BEGIN
  OPEN get_project_id(p_task_version_id);
  FETCH get_project_id into l_src_project_id;
  CLOSE get_project_id;

-- Begin Fix for Bug # 4297715.

  open cur_get_status_code(p_task_version_id);
  fetch cur_get_status_code into l_status_code;
  close cur_get_status_code;

-- End Fix for Bug # 4297715.


  l_dest_project_id := p_project_id;

  IF (l_src_project_id = l_dest_project_id) THEN
    return 'N';
  END IF;

-- Begin fix for Bug # Bug # 4256435.

        for rec_dep_hierarchy in cur_dep_hierarchy(p_task_version_id)
        loop

                if (rec_dep_hierarchy.project_id = l_dest_project_id) then

                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA'
                                             , p_msg_name       => 'PA_WP_DEP_EXISTS_NO_PRGM');

                        return 'N';

                 end if;

        end loop;

-- End fix for Bug # Bug # 4256435.

  --bug 3893970
  OPEN get_multi_rollup(l_src_project_id);
  FETCH get_multi_rollup INTO l_multi_rollup_flag;
  CLOSE get_multi_rollup;

  If l_multi_rollup_flag = 'N' THEN
    --need to check if new child is already linked
    OPEN get_child_links(l_dest_project_id, l_src_project_id);
    FETCH get_child_links INTO l_linked_parent_proj_id;
    IF get_child_links%FOUND THEN
      CLOSE get_child_links;
      return 'N';
    END IF;
    CLOSE get_child_links;

    --need to check all new child to see if it has multi rollup = 'Y'
    FOR i IN get_loop1(l_dest_project_id) LOOP
      OPEN get_multi_rollup(i.object_id_to2);
      FETCH get_multi_rollup into l_dest_multi_rollup_flag;
      CLOSE get_multi_rollup;

      IF (l_dest_multi_rollup_flag = 'Y') THEN
        return 'N';
      END IF;
    END LOOP;

    FOR i IN get_loop2(l_dest_project_id) LOOP
      OPEN get_multi_rollup(i.object_id_to2);
      FETCH get_multi_rollup into l_dest_multi_rollup_flag;
      CLOSE get_multi_rollup;

      IF (l_dest_multi_rollup_flag = 'Y') THEN
        return 'N';
      END IF;
    END LOOP;
  ELSE
    --If allow, need to check if new child has parent which does not allow
    --need to check all new child to see if its parent has multi rollup = 'N'
    OPEN get_child_links(l_dest_project_id, l_src_project_id);
    LOOP
      FETCH get_child_links INTO l_linked_parent_proj_id;
      EXIT WHEN get_child_links%NOTFOUND;

      OPEN get_multi_rollup(l_linked_parent_proj_id);
      FETCH get_multi_rollup into l_dest_multi_rollup_flag;
      CLOSE get_multi_rollup;

      IF (l_dest_multi_rollup_flag = 'N') THEN
        CLOSE get_child_links;
        return 'N';
      END IF;
    END LOOP;
    CLOSE get_child_links;
  END IF;
  --end bug 3893970

  IF (p_structure_type = 'WORKPLAN') THEN
    OPEN get_loop1(l_src_project_id);
    LOOP
      FETCH get_loop1 INTO l_proj_id, l_proj_id_from; -- Fix for Bug # 4297715.
      EXIT when get_loop1%NOTFOUND;

      IF ((l_proj_id = l_dest_project_id) -- Fix for Bug # 4297715.

          -- Fix for Bug # 4297715. If the published versions of the source project and the destination
          -- project are linked in a parent and immediate child relationship respectively,  we still allow
          -- the working version of the source project to be linked to the published version of the
          -- destination project.

          and  NOT((nvl(l_status_code,'X') = 'STRUCTURE_WORKING') -- Fix for Bug # 4297715.
                and (l_proj_id_from = l_src_project_id))) -- Fix for Bug # 4297715.
     THEN
        CLOSE get_loop1;
        return 'N';
      END If;

    END LOOP;
    CLOSE get_loop1;
  END IF;

  IF (p_structure_type = 'FINANCIAL') THEN
    OPEN get_loop2(l_src_project_id);
    LOOP
      FETCH get_loop2 INTO l_proj_id, l_proj_id_from; -- Fix for Bug # 4297715.
      EXIT when get_loop2%NOTFOUND;

      IF ((l_proj_id = l_dest_project_id) -- Fix for Bug # 4297715.

      -- Fix for Bug # 4297715. If the published versions of the source project and the destination
          -- project are linked in a parent and immediate child relationship respectively,  we still allow
      -- the working version of the source project to be linked to the published version of the
      -- destination project.

          and  NOT((nvl(l_status_code,'X') = 'STRUCTURE_WORKING') -- Fix for Bug # 4297715.
                   and (l_proj_id_from = l_src_project_id))) -- Fix for Bug # 4297715.
    THEN
        CLOSE get_loop2;
        return 'N';
      END If;

    END LOOP;
    CLOSE get_loop2;
  END IF;

  --IMP Note: Please add any new validation above this code
  --Imp Note: Let this be the last validation to be performed by this API.
  -- Start of Bug 3621794
  OPEN get_proj_prog_fl(l_src_project_id);
  FETCH get_proj_prog_fl INTO l_proj_prog_fl;
     IF l_proj_prog_fl = 'Y' THEN
        CLOSE get_proj_prog_fl;
--        return 'N';                 --Bug 3622177
          return 'Y';                 --Bug 3622177
     END IF;
  CLOSE get_proj_prog_fl;

  l_proj_prog_fl:='N';
  OPEN get_parent_sub_proj(l_src_project_id);
  LOOP
     FETCH get_parent_sub_proj INTO l_proj_prog_fl;
     IF get_parent_sub_proj%NOTFOUND THEN
        CLOSE get_parent_sub_proj;
    return 'N';
     END IF;
--     EXIT WHEN get_parent_sub_proj%NOTFOUND;
     IF l_proj_prog_fl = 'Y' THEN
        CLOSE get_parent_sub_proj;
--        return 'N';                 --Bug 3622177
          return 'Y';                 --Bug 3622177
     END IF;
  END LOOP;
  CLOSE get_parent_sub_proj;
  -- End of Bug 3621794

  return 'Y';
END CREATE_SUB_PROJ_ASSO_OK;

FUNCTION IS_AUTO_ROLLUP(p_project_id NUMBER)
  RETURN VARCHAR2
IS
  cursor c1 is
    select ppwa.AUTO_ROLLUP_SUBPROJ_FLAG
      from pa_proj_workplan_attr ppwa,
           pa_proj_elements ppe,
           pa_proj_structure_types ppst,
           pa_structure_types pst
     where ppe.project_id = p_project_id
       and ppe.object_type = 'PA_STRUCTURES'
       and ppe.proj_element_id = ppst.proj_element_id
       and ppst.structure_type_id = pst.structure_type_id
       and pst.structure_type = 'WORKPLAN'
       and ppe.project_id = ppwa.project_id
       and ppe.proj_element_id = ppwa.proj_element_id;
  l_dummy VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  CLOSE c1;

  return l_dummy;

END IS_AUTO_ROLLUP;

FUNCTION Get_Latest_Parent_Ver_obj_Id(p_structure_ver_id NUMBER,
                                      p_task_id NUMBER
                      , p_relationship_type VARCHAR2 := 'LW') -- Fix for Bug # 4471484.
  RETURN NUMBER
IS
  CURSOR c1 IS
    select por2.object_relationship_id, por2.relationship_type, ppev.element_version_id
      from pa_object_relationships  por1,
           pa_object_relationships  por2,
           pa_proj_element_versions ppev,
           pa_proj_elements         ppe
     where ppe.proj_element_id = p_task_id
       and ppe.proj_element_id = ppev.proj_element_id
       and ppe.project_id = ppev.project_id
       and ppev.element_version_id = por1.object_id_from1
       and por1.relationship_type = 'S'
       and por2.object_id_to1 = p_structure_ver_id
       and por2.object_id_from1 = por1.object_id_to1
       and por2.relationship_type = p_relationship_type -- IN ('LF', 'LW') -- Fix for Bug # 4471484.
       -- and rownum < 2 -- Fix for Bug # 4477118.
     order by ppev.element_version_id desc ; -- por2.relationship_type desc, -- Fix for Bug # 4477118.

/*
    select por1.object_id_from1
      from pa_object_relationships  por1,
           pa_object_relationships  por2
     where por2.object_id_to1 = p_structure_ver_id
       and por2.object_id_from1 = por1.object_id_to1
       and por2.relationship_type IN ('LF', 'LW')
       and rownum < 2
  order by por1.object_id_from1 desc;
*/

  l_obj_rel_id    NUMBER;
  l_element_ver_id NUMBER;
  l_obj_type      VARCHAR2(30);
BEGIN
  OPEN c1;
  FETCH c1 into l_obj_rel_id, l_obj_type, l_element_ver_id;
  CLOSE c1;

  return l_obj_rel_id;
END Get_Latest_Parent_Ver_obj_Id;

FUNCTION Get_Latest_Parent_Task_Ver_Id(p_structure_ver_id NUMBER,
                                      p_task_id NUMBER
                      , p_relationship_type VARCHAR2 := 'LW')
  RETURN NUMBER
IS
  CURSOR c1 IS
    select por2.object_relationship_id, por2.relationship_type, ppev.element_version_id
      from pa_object_relationships  por1,
           pa_object_relationships  por2,
           pa_proj_element_versions ppev,
           pa_proj_elements         ppe
     where ppe.proj_element_id = p_task_id
       and ppe.proj_element_id = ppev.proj_element_id
       and ppe.project_id = ppev.project_id
       and ppev.element_version_id = por1.object_id_from1
       and por1.relationship_type = 'S'
       and por2.object_id_to1 = p_structure_ver_id
       and por2.object_id_from1 = por1.object_id_to1
       and por2.relationship_type = p_relationship_type
     order by ppev.element_version_id desc ;

  l_obj_rel_id    NUMBER;
  l_element_ver_id NUMBER;
  l_obj_type      VARCHAR2(30);
BEGIN
  OPEN c1;
  FETCH c1 into l_obj_rel_id, l_obj_type, l_element_ver_id;
  CLOSE c1;

  return l_element_ver_id;
END Get_Latest_Parent_Task_Ver_Id;


FUNCTION Get_Latest_Child_Ver_Id(p_task_ver_id NUMBER)
  RETURN NUMBER
IS
  CURSOR c1 IS
    select por2.object_id_to1
      from pa_object_relationships  por1,
           pa_object_relationships  por2
     where por1.object_id_from1 = p_task_ver_id
       and por1.object_id_to1 = por2.object_id_from1
       and por2.relationship_type IN ('LF', 'LW')
       and rownum < 2
  order by por2.object_id_to1 desc;

  l_child_ver_id NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 into l_child_ver_id;
  CLOSE c1;

  return l_child_ver_id;
END Get_Latest_Child_Ver_Id;


--============================================================================================
/*Bug 3629024 : ## SHORT NOTE ON THE FOLL. TWO MUTUALLY RECURSIVE FUNCTIONS ##
Treat the workplan structure as a directed graph, with nodes being the
structure/tasks and links between the nodes being dependencies and/or
parent/child task relationships.
Dependency links are directed from sucessor to predecessor.
Child Tasks are linked to their parents with a bi-directional link.
Then, there should be no circular path for any node

The following two functions check for the existence of such a closed path.
*/

-- Function             : get_predecessors
-- Type                 : Mutually Recursive functions alongwith get_parents_childs
-- Purpose              : Retrieves tasks which are predecessor of the task passed to
--                        this function (p_src_task_ver_id)
-- Return               : Returns with TRUE if
--                        SUCCESSOR(p_orig_succ_task_ver_id) matches any of the retrieved
--                        predecessors
-- Assumptions          : We have started from the PREDECESSOR to which a dependency is
--                        trying to be created
-- Parameters                    Type      Required  Description and Purpose
-- ---------------------------  ------     --------  --------------------------------------------------------
-- p_src_task_ver_id            NUMBER        Y      Task id for which predecessors are to be retieved and checked
-- p_orig_succ_task_ver_id      NUMBER        Y      Task id to which the retrieved predecessors are compared
--
-- Call the function as get_predecessors(PRE,SUCC) where
-- PRE  = predecessor to which a dependency is trying to be created
-- SUCC = successor from which a dependency is trying to be created
FUNCTION get_predecessors( p_src_task_ver_id       IN NUMBER
                          ,p_orig_succ_task_ver_id IN NUMBER ) RETURN BOOLEAN IS
CURSOR cur_get_predecessors IS
     SELECT por1.object_id_to1 RELATED_TASK
     FROM   pa_object_relationships por1
     WHERE  por1.relationship_type     = 'D'
     AND    LEVEL = 1
     AND    por1.object_id_from2 = por1.object_id_to2
     START WITH       por1.object_id_from1 = p_src_task_ver_id
     CONNECT BY PRIOR por1.object_id_to1   = por1.object_id_from1
     AND        PRIOR por1.relationship_type = por1.relationship_type
     AND        PRIOR por1.object_id_from2 = por1.object_id_from2
     ;
--NOTE : * PRIOR por1.relationship_type = por1.relationship_type
--         is required so as to prevent traversing parent-child dependency relns.
--       * PRIOR por1.object_id_from2 = por1.object_id_from2 in CONNECT clause
--         is required to prevent traversing inter-project dependencies; which can be
--         circular and can give a "ORA-01436: CONNECT BY loop in user data" error
--       * por1.object_id_from2 = por1.object_id_to2 in WHERE clause
--         is required to filter out only those rows which correspond to intra-proj dependencies
BEGIN
     FOR rec_predecessors IN cur_get_predecessors LOOP
          IF rec_predecessors.related_task = p_orig_succ_task_ver_id
          OR get_parents_childs( rec_predecessors.related_task, p_orig_succ_task_ver_id ) = TRUE THEN
               RETURN TRUE;
          END IF;
     END LOOP;

     RETURN FALSE;
END get_predecessors;

-- Function             : get_parents_childs
-- Type                 : Mutually Recursive functions alongwith get_predecessors
-- Purpose              : Retrieves tasks which are parents or childs, of the task passed to
--                        this function (p_src_task_ver_id)
-- Return               : Returns with TRUE if
--                        SUCCESSOR(p_orig_succ_task_ver_id) matches any of the retrieved
--                        parents/childs
-- Assumptions          : We have started from the PREDECESSOR to which a dependency is
--                        trying to be created
-- Parameters                    Type      Required  Description and Purpose
-- ---------------------------  ------     --------  --------------------------------------------------------
-- p_src_task_ver_id            NUMBER        Y      Task id for which parents/childs are to be retieved and checked
-- p_orig_succ_task_ver_id      NUMBER        Y      Task id to which the retrieved parents/childs are compared
FUNCTION get_parents_childs( p_src_task_ver_id       IN NUMBER
                            ,p_orig_succ_task_ver_id IN NUMBER ) RETURN BOOLEAN IS
CURSOR cur_get_parents_childs IS
     SELECT por1.object_id_to1 RELATED_TASK
     FROM   pa_object_relationships por1
     WHERE      por1.relationship_type     = 'S'
     AND        por1.relationship_subtype = 'TASK_TO_TASK'
     START WITH       por1.object_id_from1 = p_src_task_ver_id
                  AND relationship_type = 'S' --bug 3944567
     CONNECT BY PRIOR por1.object_id_to1   = por1.object_id_from1
     AND        PRIOR por1.relationship_type = por1.relationship_type
     UNION
     SELECT por2.object_id_from1 RELATED_TASK
     FROM   pa_object_relationships por2
     WHERE      por2.relationship_type          = 'S'
     AND        por2.relationship_subtype = 'TASK_TO_TASK'
     START WITH       por2.object_id_to1   = p_src_task_ver_id
                  AND relationship_type = 'S' --bug 3944567
     CONNECT BY PRIOR por2.object_id_from1 = por2.object_id_to1
     AND        PRIOR por2.relationship_type = por2.relationship_type
     UNION
     SELECT p_src_task_ver_id RELATED_TASK
     FROM   dual
     ;

   --bug 4145585
   Cursor check_intersect IS
     select object_id_from1 elem_ver_id
       from pa_object_relationships
      start with object_id_to1 = p_orig_succ_task_ver_id
        and relationship_type = 'D'
 connect by  object_id_to1 =  prior object_id_from1
        and relationship_type = prior relationship_type
        and object_id_to2 = object_id_from2
     INTERSECT
     select object_id_to1
       from pa_object_relationships
      start with object_id_to1 = p_src_task_ver_id
        and relationship_type = 'S'
 connect by prior object_id_to1 = object_id_from1
        and relationship_type = prior relationship_type;
   l_dummy NUMBER;
   --end bug 4145585

BEGIN
   --bug 4145585
/*
     FOR rec_parents_childs IN cur_get_parents_childs LOOP
          IF rec_parents_childs.related_task = p_orig_succ_task_ver_id
          OR get_predecessors( rec_parents_childs.related_task, p_orig_succ_task_ver_id ) = TRUE THEN
               RETURN TRUE;
          END IF;
     END LOOP;

     RETURN FALSE;
*/
   OPEN check_intersect;
   FETCH check_intersect into l_dummy;
   IF check_intersect%FOUND THEN
     CLOSE check_intersect;
     RETURN TRUE;
   END IF;
   CLOSE check_intersect;

   RETURN FALSE;
   --end bug 4145585

END get_parents_childs;
--============================================================================================

FUNCTION Check_link_exists(p_project_id number
   ,p_link_type    VARCHAR2 DEFAULT 'SHARED'    --bug 4532826
) return VARCHAR2
IS
  CURSOR get_count IS
    Select count(1) from pa_object_relationships
     where relationship_type IN ('LW', 'LF')
       and (object_id_from2 = p_project_id or object_id_to2 = p_project_id);

-- bug 4532826
  CURSOR get_count_fn IS
    Select count(1) from pa_object_relationships
     where relationship_type = 'LF'
       and (object_id_from2 = p_project_id or object_id_to2 = p_project_id);

  CURSOR get_count_wp IS
    Select count(1) from pa_object_relationships
     where relationship_type = 'LW'
       and (object_id_from2 = p_project_id or object_id_to2 = p_project_id);
--end bug 4532826


  l_cnt NUMBER :=0;
BEGIN
  IF p_link_type = 'SHARED'    --bug 4532826
  THEN
      OPEN get_count;
      FETCH get_count into l_cnt;
      CLOSE get_count;
--bug 4532826
  ELSIF  p_link_type = 'FINANCIAL'
  THEN

      OPEN get_count_fn;
      FETCH get_count_fn into l_cnt;
      CLOSE get_count_fn;

  ELSIF  p_link_type = 'WORKPLAN'
  THEN

      OPEN get_count_wp;
      FETCH get_count_wp into l_cnt;
      CLOSE get_count_wp;

  END IF;
 --bug end 4532826

  IF l_cnt > 0 THEN
     return 'Y';
  END IF;

  return 'N';
END Check_link_exists;

FUNCTION Check_proj_currency_identical(p_src_project_id NUMBER
                                     , p_dest_project_id NUMBER) return VARCHAR2
IS
  CURSOR get_proj_curr_code(c_project_id NUMBER) IS
  select project_currency_code
    from pa_projects_all
   where project_id = C_project_id;
  l_src_proj_currency_code  VARCHAR2(15);
  l_dest_proj_currency_code VARCHAR2(15);
BEGIN
  OPEN get_proj_curr_code(p_src_project_id);
  FETCH get_proj_curr_code INTO l_src_proj_currency_code;
  CLOSE get_proj_curr_code;

  OPEN get_proj_curr_code(p_dest_project_id);
  FETCH get_proj_curr_code INTO l_dest_proj_currency_code;
  CLOSE get_proj_curr_code;

  IF (l_src_proj_currency_code <> l_dest_proj_currency_code) THEN
    return 'N';
  END IF;

  return 'Y';
END check_proj_currency_identical;

FUNCTION check_dependencies_valid(p_new_parent_task_ver_id  IN NUMBER
                                 ,p_task_ver_id IN NUMBER) RETURN VARCHAR2
IS
  CURSOR get_parent_to_child IS
    select count(1)
      from pa_object_relationships
     where relationship_type = 'D'
       and object_id_from1 IN (     --get all tasks in upper branch
               select object_id_to1
               from pa_object_relationships
               start with object_id_to1 = p_new_parent_task_ver_id
                      and relationship_type = 'S'
               connect by prior object_id_from1  = object_id_to1
                   and relationship_type = prior relationship_type
                   and prior object_type_from = object_type_to)
       and object_id_to1 IN (       --get all tasks in lower branch
               select object_id_to1
               from pa_object_relationships
               start with object_id_to1 = p_task_ver_id
                      and relationship_type = 'S'
               connect by prior object_id_to1 = object_id_from1
                   and relationship_type = prior relationship_type
                   and prior object_type_to = object_type_from);

  CURSOR get_child_to_parent IS
    select count(1)
      from pa_object_relationships
     where relationship_type = 'D'
       and object_id_from1 IN (    --get tasks in lower branch
               select object_id_to1
               from pa_object_relationships
               start with object_id_to1 = p_task_ver_id
                      and relationship_type = 'S'
               connect by prior object_id_to1 = object_id_from1
                   and relationship_type = prior relationship_type
                   and prior object_type_to = object_type_from)
       and object_id_to1 IN (     --get tasks in upper branch
               select object_id_to1
               from pa_object_relationships
               start with object_id_to1 = p_new_parent_task_ver_id
                      and relationship_type = 'S'
               connect by prior object_id_from1  = object_id_to1
                   and relationship_type = prior relationship_type
                   and prior object_type_from = object_type_to);
  l_cnt NUMBER;

BEGIN
  OPEN get_parent_to_child;
  FETCH get_parent_to_child INTO l_cnt;
  CLOSE get_parent_to_child;
  IF l_cnt > 0 THEN
    return 'N';
  END IF;

  OPEN get_child_to_parent;
  FETCH get_child_to_parent INTO l_cnt;
  CLOSE get_child_to_parent;
  IF l_cnt > 0 THEN
    return 'N';
  END IF;

  RETURN 'Y';
END check_dependencies_valid;

-- Begin fix for Bug # 4266540.

FUNCTION check_task_has_sub_proj(p_project_id NUMBER
                 , p_task_id NUMBER
                 , p_task_version_id NUMBER := NULL)
return VARCHAR2 is

cursor cur_sub_project (c_project_id NUMBER, c_task_id NUMBER, c_task_version_id NUMBER) is
select count(pslv.sub_project_id)
from pa_structures_links_v pslv
where pslv.parent_project_id = c_project_id
and pslv.parent_task_id = c_task_id
and pslv.parent_task_version_id = c_task_version_id;

cursor cur_task_version_id (c_project_id NUMBER, c_task_id NUMBER, c_structure_version_id NUMBER) is
select ppev.element_version_id
from pa_proj_element_versions ppev
where ppev.project_id = c_project_id
and ppev.proj_element_id = c_task_id
and ppev.parent_structure_version_id = c_structure_version_id;

l_cur_working_str_ver_id        NUMBER := null;

l_task_version_id               NUMBER := null;

l_count                         NUMBER := null;

l_return                        VARCHAR2(1) := null;

BEGIN

    l_return := 'N';

    if (p_task_version_id is null) then

        -- The calling API in this case is: pa_task_utils.check_create_subtask_ok() which is only
        -- called for 'FINANCIAL' tasks.

        l_cur_working_str_ver_id := pa_project_structure_utils.get_fin_struc_ver_id(p_project_id);

            open cur_task_version_id(p_project_id, p_task_id, l_cur_working_str_ver_id);
            fetch cur_task_version_id into l_task_version_id;
            close cur_task_version_id;

    else

            l_task_version_id := p_task_version_id;

    end if;

        open cur_sub_project(p_project_id, p_task_id, l_task_version_id);
        fetch cur_sub_project into l_count;
        close cur_sub_project;

        if nvl(l_count,0) > 0 then

                l_return := 'Y';

        end if;

        return(l_return);

END check_task_has_sub_proj;

-- End fix for Bug # 4266540.

-- Begin fix for Bug # 4411603.

function is_str_linked_to_working_ver
(p_project_id NUMBER
 , p_structure_version_id NUMBER
 , p_relationship_type VARCHAR2 := 'LW') return VARCHAR2
is

l_return_value VARCHAR2(1) := null;

cursor cur_structure_version_ids (c_object_id_from NUMBER
                                  , c_relationship_type VARCHAR2) is
-- Bug # 4757224.

select 1
from   dual
where exists (select 1
              from pa_proj_element_versions pev, pa_object_relationships por, pa_proj_elem_ver_structure ppevs
              where pev.parent_structure_version_id = c_object_id_from
	      and pev.element_version_id = por.object_id_from1
	      and por.object_id_to1 = ppevs.element_version_id
              -- Bug Fix 5077552
              -- Adding the project id to avoid the FTS on ppevs.
              and por.object_id_to2 = ppevs.project_id
	      and por.object_type_to = 'PA_STRUCTURES'
	      and por.relationship_type in (c_relationship_type, 'S')
	      and ppevs.status_code='STRUCTURE_WORKING');

/*
-- Bug # 4737033.

select ppevs.status_code status_code
from (select por.object_id_to1
      from pa_object_relationships por
      where por.object_type_to = 'PA_STRUCTURES'
      and relationship_type in (c_relationship_type, 'S')
      start with por.object_id_from1 = c_object_id_from
      connect by prior por.object_id_to1 = por.object_id_from1
      and prior relationship_type in (c_relationship_type, 'S')) por
      ,pa_proj_elem_ver_structure ppevs
where
    por.object_id_to1 = ppevs.element_version_id (+);

select ppevs.status_code status_code
from pa_object_relationships por, pa_proj_elem_ver_structure ppevs
where por.object_id_to1 = ppevs.element_version_id (+)
and por.object_type_to = 'PA_STRUCTURES'
and relationship_type in (c_relationship_type, 'S')
start with por.object_id_from1 = c_object_id_from
connect by prior por.object_id_to1 = por.object_id_from1
and prior relationship_type in (c_relationship_type, 'S');

-- Bug # 4737033.
*/

-- Bug # 4757224.

l_structure_working VARCHAR2(1) := null;

rec_structure_version_ids cur_structure_version_ids%rowtype;

begin

l_return_value := 'N';

if (pa_project_structure_utils.check_program_flag_enable(p_project_id) = 'Y') then -- Bug # 4742904.

-- Bug # 4757224.

    open cur_structure_version_ids(p_structure_version_id, p_relationship_type);
    fetch cur_structure_version_ids into rec_structure_version_ids;

    if cur_structure_version_ids%NOTFOUND then
        l_return_value:='N';
    else
        l_return_value:='Y';
    end if;

    close cur_structure_version_ids;

/*
for rec_structure_version_ids in cur_structure_version_ids(p_structure_version_id, p_relationship_type)
loop

    if (rec_structure_version_ids.status_code = 'STRUCTURE_WORKING') then

       l_return_value := 'Y';

    end if;

end loop;
*/

-- Bug # 4757224.

end if; -- Bug # 4742904.

return(l_return_value);

end is_str_linked_to_working_ver;

-- End fix for Bug # 4411603.

--bug 4541039

FUNCTION Check_parent_project_Exists
(
     p_project_id NUMBER,
     p_structure_ver_id NUMBER
    ,p_link_type        VARCHAR2     default 'SHARED'    --bug 4541039
)RETURN VARCHAR2
IS
    CURSOR check_parentproj_exists IS
    SELECT '1'
       from     pa_object_relationships por
       WHERE p_structure_ver_id = por.object_id_to1
       and por.object_id_to2 = p_project_id
       and por.relationship_type IN ('LW', 'LF');


    CURSOR check_parentproj_exists_wp IS
    SELECT '1'
       from    pa_object_relationships por
       WHERE p_structure_ver_id = por.object_id_to1
       and por.object_id_to2 = p_project_id
       and por.relationship_type = 'LW';

    CURSOR check_parentproj_exists_fn IS
    SELECT '1'
        from   pa_object_relationships por
       WHERE p_structure_ver_id = por.object_id_to1
       and por.object_id_to2 = p_project_id
       and por.relationship_type = 'LF';

    l_dummy VARCHAR2(1);
BEGIN
    IF p_link_type = 'SHARED'  --bug 4541039
    THEN
        OPEN check_parentproj_exists;
        FETCH check_parentproj_exists INTO l_dummy;
        IF check_parentproj_exists%NOTFOUND THEN
        CLOSE check_parentproj_exists;
          RETURN 'N';
        ELSE
          CLOSE check_parentproj_exists;
          RETURN 'Y';
        END IF;
    ELSIF p_link_type = 'WORKPLAN'
    THEN
        OPEN check_parentproj_exists_wp;
        FETCH check_parentproj_exists_wp INTO l_dummy;
        IF check_parentproj_exists_wp%NOTFOUND THEN
        CLOSE check_parentproj_exists_wp;
          RETURN 'N';
        ELSE
          CLOSE check_parentproj_exists_wp;
          RETURN 'Y';
        END IF;
    ELSIF p_link_type = 'FINANCIAL'
    THEN
        OPEN check_parentproj_exists_fn;
        FETCH check_parentproj_exists_fn INTO l_dummy;
        IF check_parentproj_exists_fn%NOTFOUND THEN
        CLOSE check_parentproj_exists_fn;
          RETURN 'N';
        ELSE
          CLOSE check_parentproj_exists_fn;
          RETURN 'Y';
        END IF;
    END IF;

END Check_parent_project_Exists;

--bug 4619824
FUNCTION Check_subproject_link_exists(p_project_id number
   ,p_link_type    VARCHAR2 DEFAULT 'SHARED'    --bug 4532826
) return VARCHAR2
IS
  CURSOR get_count IS
    Select count(1) from pa_object_relationships
     where relationship_type IN ('LW', 'LF')
       and object_id_from2 = p_project_id;

  CURSOR get_count_fn IS
    Select count(1) from pa_object_relationships
     where relationship_type = 'LF'
       and object_id_from2 = p_project_id;

  CURSOR get_count_wp IS
    Select count(1) from pa_object_relationships
     where relationship_type = 'LW'
       and (object_id_from2 = p_project_id);


  l_cnt NUMBER :=0;
BEGIN
  IF p_link_type = 'SHARED'
  THEN
      OPEN get_count;
      FETCH get_count into l_cnt;
      CLOSE get_count;
  ELSIF  p_link_type = 'FINANCIAL'
  THEN

      OPEN get_count_fn;
      FETCH get_count_fn into l_cnt;
      CLOSE get_count_fn;

  ELSIF  p_link_type = 'WORKPLAN'
  THEN

      OPEN get_count_wp;
      FETCH get_count_wp into l_cnt;
      CLOSE get_count_wp;

  END IF;

  IF l_cnt > 0 THEN
     return 'Y';
  END IF;

  return 'N';
END Check_subproject_link_exists;


end PA_RELATIONSHIP_UTILS;

/
