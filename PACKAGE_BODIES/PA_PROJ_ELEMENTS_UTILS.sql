--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ELEMENTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ELEMENTS_UTILS" AS
/* $Header: PATSK1UB.pls 120.15.12010000.7 2009/10/07 06:49:15 anuragar ship $ */

Invalid_Arg_Exc_WP     Exception ;
g_module_name VARCHAR2(100) := 'pa.plsql.pa_proj_elements_utils';

-- Added for Bug 6156686
TYPE l_lookup_cache_tbl_typ IS TABLE OF VARCHAR2(80)
INDEX BY VARCHAR2(70);

l_lookup_cache_tbl l_lookup_cache_tbl_typ;

TYPE l_fndlkp_cache_tbl_typ IS TABLE OF VARCHAR2(80)
INDEX BY VARCHAR2(70);

l_fndlkp_cache_tbl l_lookup_cache_tbl_typ;

PROCEDURE SetGlobalStrucVerId ( p_structure_version_id IN NUMBER )
IS
BEGIN
  PA_PROJ_ELEMENTS_UTILS.g_Struc_Ver_Id := p_structure_version_id;
END SetGlobalStrucVerId;

FUNCTION GetGlobalStrucVerId RETURN NUMBER
IS
BEGIN
  RETURN ( PA_PROJ_ELEMENTS_UTILS.g_Struc_Ver_Id  );
END GetGlobalStrucVerId;

--This function checks if a WORKPLAN (split or shared) task
--may be updtaed by the logged in user.
--Do not use this function for split FINANCIAL tasks
-- 5/13/05: DHI ER: Allowing multiple user to update task assignment
--          Added p_require_lock_flag parameter defauled to 'Y'.
-- 8/29/05: R12 Bug fix 4533152: Added p_add_error_flag paramter
--          defaulted to 'N'.
FUNCTION Check_Edit_Task_Ok(p_project_id IN NUMBER,
                            p_structure_version_id IN NUMBER,
                            p_curr_struct_version_id IN NUMBER,
                            p_element_id IN NUMBER := NULL,
                            p_require_lock_flag IN VARCHAR := 'Y',
                            p_add_error_flag IN VARCHAR := 'N')
RETURN VARCHAR2
IS
  l_ret_code  varchar2(1);
  l_ret_stat  varchar2(1);
  l_msg_count NUMBER;
  l_msg_data  varchar2(250);

  cursor c1 IS
    select '1' from pa_projects_all
     where project_id = p_project_id
       and template_flag = 'Y';
  l_dummy VARCHAR2(1);
  -- bug 4239490
  l_lock  VARCHAR2(1);
  l_is_task_manager_flag   VARCHAR2(1);
  l_version_enable_flag    VARCHAR2(1);
   --bug 4239490
BEGIN

  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%FOUND THEN
    CLOSE c1;
    return 'Y';
  END IF;
  CLOSE c1;

  --check if this is published
--  IF (PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(p_project_id, p_structure_version_id) = 'Y') THEN
--    return 'N';
--  END IF;
  IF ('N' = PA_PROJECT_STRUCTURE_UTILS.check_edit_wp_ok(p_project_id, p_structure_version_id)) THEN
    -- Bug 4533152
    IF p_add_error_flag = 'Y' THEN
      PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_CHANGE_PUB_VER_ERR');
    END IF;
    -- End of Bug 4533152
    return 'N';
  END IF;
/* commented out--bug 3071008
   since linking is not shipped
  --check if this is linked element version
  If (p_structure_version_id = p_curr_struct_version_id) THEN
    --Same structure
    return 'Y';
  END IF;
*/

  l_version_enable_flag := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id);
  --check if this is locked
  --bug 3071008: added condition for versioned projects only
  IF (l_version_enable_flag = 'Y') THEN
    -- The following API returns 'Y' if locked by current user , '0' if Locked by some other user and 'N' if no one is locking
    -- If no one is locking we can still allow editing.
    --bug 4239490
    l_lock := PA_PROJECT_STRUCTURE_UTILS.IS_STRUC_VER_LOCKED_BY_USER(FND_GLOBAL.USER_ID, p_structure_version_id);

    -- Bug Fix: 4725901
    -- DHI ER:
    -- Need to consider the p_require_lock_flag.
    -- Currently the flow is returning N which is preventing other users
    -- to update/create/delete the task assignments using the PA_TASK_ASSIGNMENT_PUB
    --
    -- In order to allow the users to update/delete/create the Task Assignments
    -- even though the structure is locked we need to consider the p_required_lock flag.
    -- The flow will be
    -- If the structure is locked AND p_required_lock_flag is Y then only return N
    -- In case of DHI ER the call to this procedure from
    -- PA_TASK_ASSIGNMENT_UTILS.check_edit_task_ok will pass N. So the error is
    -- bypassed.
    --
    -- IF (l_lock = 'O') THEN    --bug 4239490

    IF ((l_lock = 'O') AND (p_require_lock_flag = 'Y')) THEN    --bug 4725901

      -- Bug 4533152
      IF p_add_error_flag = 'Y' THEN
        PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_STR_LOCKED_BY_OTHER');
      END IF;
      -- End of Bug 4533152
      return 'N';

    END IF;

  END IF;

  -- This API can be called from so many other places also,where this p_element_id may not be available
  -- Hence PA_PROGRESS_UTILS.IS_TASK_MANAGER API will return 'N'
  -- which may produce undesirable results
  -- Here ,Introduced the condition to call this API if and only if p_element_id is passed

  IF p_element_id is NOT NULL -- 4267419 <avaithia> tracking
  THEN
  --bug 4239490 No access if there is no lock and the user is not task manager.
  l_is_task_manager_flag := PA_PROGRESS_UTILS.IS_TASK_MANAGER(p_element_id, p_project_id, FND_GLOBAL.USER_ID);

  IF l_version_enable_flag = 'Y' AND
     l_is_task_manager_flag = 'N' and l_lock = 'N' AND
     p_require_lock_flag = 'Y'      -- 5/13/05: DHI ER: Allowing multiple user to update task assignment
                                    --          If structure version is NOT locked by another user,
                                    --          also return 'Y';
  THEN
      -- Bug 4533152
      IF p_add_error_flag = 'Y' THEN
        PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');
      END IF;
      -- End of Bug 4533152
     return 'N';
  END IF;
   --end bug 4239490
  END IF ; -- 4267419 <avaithia> tracking

  --check if user can edit
  IF (PA_SECURITY_PVT.check_user_privilege('PA_PAXPREPR_OPT_WORKPLAN_STR', 'PA_PROJECTS', p_project_id
      , 'N') -- Fix for Bug # 4319137.
      <> FND_API.G_TRUE) THEN
     IF p_element_id is NOT NULL THEN
        IF (l_is_task_manager_flag = 'Y') THEN   --bug 4239490  replaced the is_task_manager api call with the variable.
           IF (PA_SECURITY_PVT.check_user_privilege('PA_TASKS_UPDATE_DETAILS', 'PA_PROJECTS', p_project_id
	       , 'N') -- Fix for Bug # 4319137.
             <> FND_API.G_TRUE) THEN
               -- Bug 4533152
               IF p_add_error_flag = 'Y' THEN
                 PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');
               END IF;
               -- End of Bug 4533152
               return 'N';
           END IF;
        ELSE
          -- Bug 4533152
          IF p_add_error_flag = 'Y' THEN
            PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');
          END IF;
          -- End of Bug 4533152
          return 'N';
        END IF;
     ELSE
        -- Bug 4533152
        IF p_add_error_flag = 'Y' THEN
          PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');
        END IF;
        -- End of Bug 4533152
        return 'N';
     END IF;
  END IF;
  return 'Y';
END Check_Edit_Task_Ok;


PROCEDURE Get_Structure_Attributes(
    p_element_version_id       NUMBER,
    p_structure_type_code       VARCHAR2 := 'WORKPLAN',
    x_task_name                 OUT NOCOPY VARCHAR2, -- 4537865
    x_task_number               OUT NOCOPY VARCHAR2, -- 4537865
    x_task_version_id           OUT NOCOPY NUMBER, -- 4537865
    x_structure_version_name    OUT NOCOPY VARCHAR2, -- 4537865
    x_structure_version_number  OUT NOCOPY NUMBER, -- 4537865
    x_structure_name            OUT NOCOPY VARCHAR2, -- 4537865
    x_structure_number          OUT NOCOPY VARCHAR2, -- 4537865
    x_structure_id              OUT NOCOPY NUMBER, -- 4537865
    x_structure_type_code_name  OUT NOCOPY VARCHAR2, -- 4537865
    x_structure_version_id      OUT NOCOPY NUMBER, -- 4537865
    x_project_id                OUT NOCOPY NUMBER -- 4537865

) AS

    CURSOR cur_elem_ver
    IS
      SELECT ppe.name, ppe.element_number, ppev.parent_structure_version_id, ppe.project_id
        FROM pa_proj_element_versions ppev,
             pa_proj_elements ppe
       WHERE ppe.proj_element_id = ppev.proj_element_id
         AND ppev.element_version_id = p_element_version_id
         AND ppev.object_type = 'PA_TASKS';

/* Bug 2680486 -- Performance changes -- Added one more condition to compare project_id in the following cursor.
                  The project_id is got from pa_proj_element_versions*/

    CURSOR cur_elem_ver_stru( p_version_id NUMBER )
    IS
      SELECT ppevs.version_number, ppevs.name, ppe.element_number, ppe.name, ppe.proj_element_id, ppe.project_id
        FROM pa_proj_elem_ver_structure ppevs,
             pa_proj_elements ppe
       WHERE ppevs.element_version_id = p_version_id
         AND ppe.proj_element_id = ppevs.proj_element_id
         AND ppevs.project_id = (select project_id
                                 from pa_proj_element_versions
                                 where element_version_id = p_version_id) ;

    CURSOR cur_lookups
    IS
      SELECT meaning
        FROM pa_lookups
       WHERE lookup_type = 'PA_STRUCTURE_TYPE_CLASS'
         AND lookup_code = p_structure_type_code;


   x_version_id    NUMBER;
BEGIN
     OPEN cur_elem_ver;
     FETCH cur_elem_ver INTO  x_task_name, x_task_number, x_structure_version_id,x_project_id;
     IF cur_elem_ver%FOUND THEN
        --If element is TASK Get the structure details. This structure is parent of the task p_elemnt_version_id.
        x_version_id := x_structure_version_id;
        --here we get the task.
        x_task_version_id := p_element_version_id;
     ELSE
        --If element is STRUCTURE. Pass back only STRUCTURE details.
        x_version_id := p_element_version_id;
        x_structure_version_id := p_element_version_id;
     END IF;
     CLOSE cur_elem_ver;

     OPEN cur_elem_ver_stru( x_version_id );
     FETCH cur_elem_ver_stru INTO x_structure_version_number, x_structure_version_name,
                                  x_structure_number, x_structure_name, x_structure_id, x_project_id;
     CLOSE cur_elem_ver_stru;

     OPEN cur_lookups;
     FETCH cur_lookups INTO x_structure_type_code_name;
     CLOSE cur_lookups;

-- 4537865 I havent changed WHEN OTHERS block because existing code wanted to ignore it.
-- Discussed with Rajnish  reg. this

EXCEPTION WHEN OTHERS THEN
     null;
END Get_Structure_Attributes;


FUNCTION latest_published_ver_id(
    p_project_id             NUMBER,
    p_structure_type_code    VARCHAR2 := 'WORKPLAN'
) RETURN NUMBER IS
    CURSOR cur_elem_ver_stru
    IS
      SELECT element_version_id
        FROM pa_proj_elem_ver_structure ppevs,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       WHERE ppevs.project_id = p_project_id
         AND latest_eff_published_flag = 'Y'
         AND ppst.proj_element_id = ppevs.proj_element_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code = p_structure_type_code;
    v_element_version_id  NUMBER;
BEGIN
     OPEN cur_elem_ver_stru;
     FETCH cur_elem_ver_stru INTO v_element_version_id;
     CLOSE cur_elem_ver_stru;
     RETURN NVL( v_element_version_id, -1);
END latest_published_ver_id;

-- POST K:Added for Shortcut to get the last updated Workplan version

Procedure Get_Last_Upd_Working_Wp_Ver(
       p_project_id            IN   pa_proj_elem_ver_structure.project_id%TYPE
      ,x_pev_structure_id      OUT NOCOPY  pa_proj_elem_ver_structure.pev_structure_id%TYPE -- 4537865
      ,x_element_version_id    OUT NOCOPY  pa_proj_elem_ver_structure.element_version_id%TYPE -- 4537865
      ,x_element_version_name  OUT NOCOPY pa_proj_elem_ver_structure.name%TYPE -- 4537865
      ,x_record_version_number OUT NOCOPY pa_proj_elem_ver_structure.record_version_number%TYPE -- 4537865
      ,x_return_status         OUT NOCOPY VARCHAR2 -- 4537865
      ,x_msg_count             OUT NOCOPY  NUMBER -- 4537865
      ,x_msg_data              OUT NOCOPY VARCHAR2) -- 4537865
AS

l_msg_index_out                 NUMBER;
l_debug_mode                           VARCHAR2(1);

l_data                          VARCHAR2(2000); -- 4537865

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;
l_module_name                    VARCHAR2(100) := 'pa.plsql.PA_PROJ_ELEMENTS_UTILS';

l_date1                   DATE ;
l_pev_structure_id1       pa_proj_elem_ver_structure.pev_structure_id%TYPE      ;
l_element_version_id1     pa_proj_elem_ver_structure.element_version_id%TYPE    ;
l_element_version_name1   pa_proj_elem_ver_structure.name%TYPE                  ;
l_record_version_number1  pa_proj_elem_ver_structure.record_version_number%TYPE ;

l_date2                   DATE ;
l_pev_structure_id2       pa_proj_elem_ver_structure.pev_structure_id%TYPE      ;
l_element_version_id2     pa_proj_elem_ver_structure.element_version_id%TYPE    ;
l_element_version_name2   pa_proj_elem_ver_structure.name%TYPE                  ;
l_record_version_number2  pa_proj_elem_ver_structure.record_version_number%TYPE ;

    CURSOR cur_elem_ver_stru1
    IS
      SELECT ppevs.last_update_date,
             ppevs.pev_structure_id,
             ppevs.element_version_id,
             ppevs.name,
             ppevs.record_version_number
        FROM pa_proj_elem_ver_structure ppevs,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       WHERE ppevs.project_id = p_project_id
         AND ppevs.status_code = 'STRUCTURE_WORKING'
         AND ppst.proj_element_id = ppevs.proj_element_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code = 'WORKPLAN'
         ORDER BY ppevs.last_update_date desc ;

   --bug#2956325 :
   --Added the below mentioned cursor to take care of
   --scenerios such as delete,indent,outdent,move,add
   --etc.The above cursor doesn't take care of these
   --scenerios as the last_updated_date is not updated
   --for the structure version in pa_proj_elem_ver_structure
   --table.The above cursor is though needed when the structure
   --version infirmation such as description is updated.

   --Now after the fix ,both the maximum dates from
   --pa_proj_elem_ver_structure and pa_proj_elem_ver_schedule
   --are compared.The structure version info corresponding
   --to greater last_updated_date is returned.

    CURSOR cur_elem_ver_stru2
    IS
      SELECT MAX(a.last_update_date),
             c.pev_structure_id,
             c.element_version_id,
                   c.name,
                   c.record_version_number
        FROM pa_proj_element_versions b,
             pa_proj_elem_ver_schedule a,
             pa_proj_elem_ver_structure c,
             pa_structure_types d ,
             pa_proj_structure_types e
       WHERE a.element_version_id= b.element_version_id
         AND a.project_id = b.project_id
         AND a.proj_element_id = b.proj_element_id
         AND b.parent_structure_version_id = c.element_version_id
         AND b.project_id = c.project_id
         AND b.project_id = p_project_id
            AND c.status_code = 'STRUCTURE_WORKING'
         AND e.proj_element_id = c.proj_element_id
         AND d.structure_type_id = e.structure_type_id
         AND d.structure_type_class_code = 'WORKPLAN'
    GROUP BY c.pev_structure_id
                  ,c.element_version_id
                  ,c.name
                  ,c.record_version_number
   ORDER BY MAX(a.last_update_date) desc  ;

   --cursor to select the structure version id for a workplan structure
    CURSOR cur_elem_ver_stru3
    IS
      SELECT ppe.proj_element_id
        FROM pa_proj_elements ppe,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       WHERE ppe.project_id = p_project_id
         AND ppe.object_type = 'PA_STRUCTURES'
--         AND ppe.status_code <> 'STRUCTURE_PUBLISHED'
         AND ppst.proj_element_id = ppe.proj_element_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code = 'WORKPLAN';
    l_structure_id NUMBER;

    /* Bug No 3692971, For performance reasons the following tables are removed from the cursor query as */
    /* pa_proj_structure_types, pa_structure_types tables are not used in select list and where clause.  */
    /* In case these two tables are required please add the following two join conditions to avoid full  */
    /* table scan on the structure_type tables                                                           */
    /* AND ppst.proj_element_id = ppevs.proj_element_id   */
    /* AND ppst.structure_type_id = pst.structure_type_id */
    CURSOR cur_elem_ver_stru4(c_struc_id NUMBER, c_struc_ver_id NUMBER)
    IS
      SELECT ppevs.last_update_date,
             ppevs.pev_structure_id,
             ppevs.element_version_id,
             ppevs.name,
             ppevs.record_version_number
        FROM pa_proj_elem_ver_structure ppevs
       WHERE ppevs.project_id = p_project_id
         AND ppevs.proj_element_id = c_struc_id
         AND ppevs.element_version_id = c_struc_ver_id;
/*      SELECT ppevs.last_update_date,
             ppevs.pev_structure_id,
             ppevs.element_version_id,
             ppevs.name,
             ppevs.record_version_number
        FROM pa_proj_elem_ver_structure ppevs,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       WHERE ppevs.project_id = p_project_id
         AND ppevs.proj_element_id = c_struc_id
         AND ppevs.element_version_id = c_struc_ver_id;*/
BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


     IF l_debug_mode = 'Y' THEN
          --Moved here for bug 4252182
          pa_debug.set_curr_function( p_function   => 'Get_Last_Upd_Working_Wp_Ver',
                                 p_debug_mode => l_debug_mode );

          pa_debug.g_err_stage:= 'Validating input parameters';
          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     END IF;

     IF (p_project_id IS NULL) THEN
          IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Value of input parameter = '|| p_project_id;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level5);
          END IF;
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_FP_INV_PARAM_PASSED');
          RAISE Invalid_Arg_Exc_WP;

     END IF;

--added for bug 3476162
     OPEN cur_elem_ver_stru3;
     FETCH cur_elem_ver_stru3 into l_structure_id;
     CLOSE cur_elem_ver_stru3;

     x_element_version_id := PA_PROJECT_STRUCTURE_UTILS.get_last_updated_working_ver(l_structure_id);

     OPEN cur_elem_ver_stru4(l_structure_id, x_element_version_id);
     FETCH cur_elem_ver_stru4 INTO
          l_date1
         ,l_pev_structure_id1
         ,l_element_version_id1
         ,l_element_version_name1
         ,l_record_version_number1;
     IF cur_elem_ver_stru4%NOTFOUND THEN
        x_pev_structure_id      := -1  ;
        x_element_version_id    := -1  ;
        x_element_version_name  := '-1';
        x_record_version_number := -1;
     ELSE
        x_pev_structure_id      := l_pev_structure_id1      ;
        x_element_version_id    := l_element_version_id1    ;
        x_element_version_name  := l_element_version_name1  ;
        x_record_version_number := l_record_version_number1 ;
     END IF;
     CLOSE cur_elem_ver_stru4;
--end added for bug 3476162

--commented out for bug 3476162
/*
     OPEN cur_elem_ver_stru1;
     FETCH cur_elem_ver_stru1 INTO
          l_date1
         ,l_pev_structure_id1
         ,l_element_version_id1
         ,l_element_version_name1
         ,l_record_version_number1;
     IF cur_elem_ver_stru1%NOTFOUND THEN
           x_pev_structure_id      := -1  ;
           x_element_version_id    := -1  ;
        x_element_version_name  := '-1';
        x_record_version_number := -1  ;
     CLOSE cur_elem_ver_stru1 ;
     ELSE
     OPEN cur_elem_ver_stru2;
     FETCH cur_elem_ver_stru2 INTO
          l_date2
         ,l_pev_structure_id2
         ,l_element_version_id2
         ,l_element_version_name2
         ,l_record_version_number2;

          IF l_date1>l_date2 THEN
                x_pev_structure_id      := l_pev_structure_id1      ;
                x_element_version_id    := l_element_version_id1    ;
                x_element_version_name  := l_element_version_name1  ;
                x_record_version_number := l_record_version_number1 ;
          ELSE
                x_pev_structure_id      := l_pev_structure_id2      ;
                x_element_version_id    := l_element_version_id2    ;
                x_element_version_name  := l_element_version_name2  ;
                x_record_version_number := l_record_version_number2 ;
          END IF ;
     CLOSE cur_elem_ver_stru2 ;
     END IF;
*/

     IF l_debug_mode = 'Y' THEN  --For bug 4252182

        pa_debug.reset_curr_function;

     END IF;

EXCEPTION

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := FND_MSG_PUB.count_msg;

      -- 4537865 RESET OUT PARAMS
      x_pev_structure_id      := NULL ;
      x_element_version_id    := NULL ;
      x_element_version_name  := NULL ;
      x_record_version_number := NULL ;

     IF x_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => x_msg_count
              ,p_msg_data       => x_msg_data
              ,p_data           => l_data, -- 4537865
              p_msg_index_out  => l_msg_index_out);

		x_msg_data := l_data ; -- 4537865

      END IF;

     IF l_debug_mode = 'Y' THEN --For bug 4252182
         pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

      -- 4537865 RESET OUT PARAMS
      x_pev_structure_id      := NULL ;
      x_element_version_id    := NULL ;
      x_element_version_name  := NULL ;
      x_record_version_number := NULL ;

     IF cur_elem_ver_stru1%ISOPEN THEN
          CLOSE cur_elem_ver_stru1;
     END IF;
     IF cur_elem_ver_stru2%ISOPEN THEN
          CLOSE cur_elem_ver_stru2;
     END IF;

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_ELEMENTS_UTILS'
                    ,p_procedure_name  => 'Get_Last_Upd_Working_Wp_Ver'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(l_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function; --For bug 4252182
     END IF;
     RAISE;
END Get_Last_Upd_Working_Wp_Ver;

FUNCTION element_has_child(
    p_structure_version_id NUMBER
) RETURN VARCHAR2 IS
   CURSOR cur_obj_rel
   IS
     SELECT 'x'
       FROM pa_object_relationships por, pa_proj_elements ppe, pa_proj_element_versions ppev
      WHERE object_id_from1 = p_structure_version_id
        AND relationship_type = 'S'
        AND por.object_id_to1 = ppev.element_version_id
        AND ppe.proj_element_id = ppev.proj_element_id
        AND ppe.link_task_flag = 'N';
      /*START WITH object_id_from1 = p_structure_version_id
      CONNECT BY object_id_from1 = PRIOR object_id_to1;*/
   v_dummy_char  VARCHAR2(1);
BEGIN
    OPEN cur_obj_rel;
    FETCH cur_obj_rel INTO v_dummy_char;
    IF cur_obj_rel%FOUND
    THEN
       CLOSE cur_obj_rel;
       RETURN 'Y';
    ELSE
       CLOSE cur_obj_rel;
       RETURN 'N';
    END IF;
END element_has_child;

-- API name                      : IS_LOWEST_Task
-- Type                          : Task Utils API
-- Pre-reqs                      : None
-- Return Value                  : 1 if it is lowest task; 0 if not.
-- Parameters
--  p_task_version_id                   IN      NUMBER
--
--  History
--
--  31-OCT-01   HSIU             -Created
--


function IS_LOWEST_TASK(p_task_version_id NUMBER) RETURN VARCHAR2
IS
  l_dummy number;

  cursor child_exist IS
  select 1
   from pa_object_relationships
  where object_type_from = 'PA_TASKS'
    and object_id_from1 = p_task_version_id
    and relationship_type = 'S';

BEGIN

  OPEN child_exist;
  FETCH child_exist into l_dummy;
  IF child_exist%NOTFOUND then
    --Cannot find child. It is lowest task
    CLOSE child_exist;
    return 'Y';
  ELSE
    --Child found. Not lowest task
    CLOSE child_exist;
    return 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    return (SQLCODE);
END IS_LOWEST_TASK;

-- API name                      : Check_element_Name_Unique
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--   p_element_name               IN      VARCHAR2
--   p_element_id                 IN      NUMBER
--   p_project_id                   IN      NUMBER
--   p_object_type                     IN  VARCHAR2 := 'PA_TASKS'
--
--  History
--
--  01-NOV-01   MAANSARI             -Created
--
--

  function Check_element_NUmber_Unique
  (
    p_element_number                    IN  VARCHAR2
   ,p_element_id                      IN  NUMBER
   ,p_project_id                      IN  NUMBER
   ,p_structure_id                    IN  NUMBER
   ,p_object_type                     IN  VARCHAR2 := 'PA_TASKS'
  ) return VARCHAR2
  IS
    cursor c1 is
           select 1 from pa_proj_elements
           where project_id = p_project_id
           and object_type = p_object_type
           and element_number = p_element_number
           and PARENT_STRUCTURE_ID = p_structure_id
           and (p_element_id is NULL or proj_element_id <> p_element_id);

    l_dummy NUMBER;

  BEGIN
    if (p_project_id IS NULL or p_element_number is NULL) then
      return (null);
    end if;

    open c1;
    fetch c1 into l_dummy;
    if c1%notfound THEN
      close c1;
      return('Y');
    else
      close c1;
      return('N');
    end if;
  EXCEPTION
    when others then
      return (SQLCODE);
  END Check_element_number_Unique;

-- API name                      : Check_Struc_Published
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N if not published; Y if published.
-- Parameters
--    p_structure_id              IN  NUMBER
--    p_project_id              IN  NUMBER
--
--  History
--
--  01-NOV-01   MAANSARI             -Created
--
--


  function Check_Struc_Published
  (
    p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
  ) return VARCHAR2
  IS
    cursor c1 is
      select '1'
      from pa_proj_elem_ver_structure
      where project_id = p_project_id
      and proj_element_id = p_structure_id
      and published_date IS NULL;
    c1_rec c1%rowtype;

  BEGIN
    if (p_project_id IS NULL or p_structure_id IS NULL) then
      return (null);
    end if;

    open c1;
    fetch c1 into c1_rec;
    if c1%notfound THEN
      close c1;
      return('N');
    else
      close c1;
      return('Y');
    end if;
  EXCEPTION
    when others then
      return (SQLCODE);
  END Check_Struc_Published;


-- API name                      : Check_Delete_task_Ver_Ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_structure_version_id         IN      NUMBER
--   x_return_status                OUT     VARCHAR2
--   x_error_msg_code           OUT     VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Delete_task_Ver_Ok
  (
    p_project_id                        IN  NUMBER
   ,p_task_version_id                   IN  NUMBER
   ,p_parent_structure_ver_id           IN  NUMBER
   ,p_validation_mode                      IN  VARCHAR2   DEFAULT 'U' --bug 2947492
   ,x_return_status                     OUT NOCOPY VARCHAR2  -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2  -- 4537865
  )
  IS
    l_user_id  NUMBER;
    l_person_id NUMBER;
    l_dummy     VARCHAR2(1);
    l_proj_element_id   NUMBER;

    l_err_code          VARCHAR2(2000);
    l_err_stage         VARCHAR2(2000);
    l_err_stack         VARCHAR2(2000);

    cursor get_person_id(p_user_id NUMBER) IS
    select p.person_id
      from per_all_people_f p, fnd_user f
     where f.employee_id = p.person_id
       and sysdate between p.effective_start_date and p.effective_end_date
       and f.user_id = p_user_id;

    cursor get_lock_user(p_person_id NUMBER) IS
    select '1'
      from pa_proj_element_versions v, pa_proj_elem_ver_structure s
     where v.element_version_id = p_parent_structure_ver_id
       and v.project_id = s.project_id
       and v.element_version_id = s.element_version_id
       and (locked_by_person_id IS NULL
        or locked_by_person_id = p_person_id);

    cursor get_link IS
    select '1'
      from pa_object_relationships
     where ( object_id_from1 = p_task_version_id
             or object_id_to1 = p_task_version_id )
       and relationship_type = 'L';

    CURSOR cur_chk_last_ver
    IS
      SELECT 'x'
        FROM pa_proj_element_versions
       WHERE proj_element_id = ( SELECT proj_element_id
                                   FROM pa_proj_element_versions
                                  WHERE element_version_id = p_task_version_id )
         AND element_version_id <>  p_task_version_id;

    CURSOR cur_proj_elem_ver
    IS
      SELECT ppev.proj_element_id
        FROM pa_proj_element_versions ppev, pa_tasks pt
       WHERE ppev.element_version_id = p_task_version_id
         and ppev.proj_element_id = pt.task_id;

    -- Bug 3933576 : Added cursor cur_wp_proj_elem_ver and variable l_wp_proj_elem_id
    CURSOR cur_wp_proj_elem_ver
    IS
      SELECT ppev.proj_element_id
        FROM pa_proj_element_versions ppev
       WHERE ppev.element_version_id = p_task_version_id
    ;


--hsiu: added for bug 2682805
    l_dummy2    NUMBER;

-- anlee Added for ENG
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_delete_ok VARCHAR2(250);

  BEGIN
    l_user_id := FND_GLOBAL.USER_ID;
--dbms_output.put_line('user id = '||l_user_id);
    --get the current user's person_id
    open get_person_id(l_user_id);
    fetch get_person_id into l_person_id;
    if get_person_id%NOTFOUND then
      l_person_id := -1;
    end if;
    close get_person_id;

--dbms_output.put_line( 'Person Id = '||l_person_id);

--comment out because linking is not available
--    open get_lock_user(l_person_id);
--    fetch get_lock_user into l_dummy;
--    if get_lock_user%NOTFOUND then
--      --the structure version is locked by another user.
--      close get_lock_user;
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      x_error_message_code := 'PA_PS_STRUC_VER_LOCKED';
--      --return;
--      raise FND_API.G_EXC_ERROR;
--
--    end if;
--    close get_lock_user;

--dbms_output.put_line( 'Check if this is a published version ');

    --Check if this is a published version
--hsiu
--versioning changes
--
--    If (PA_PROJECT_STRUCTURE_UTILS.Check_Struc_Ver_Published(p_project_id, p_parent_structure_ver_id) = 'Y') THEN
      --version is published. Error.
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      x_error_message_code := 'PA_PS_STRUC_VER_LOCKED';
--      return;
--    END IF;

    --check if the structure is worplan
--dbms_output.put_line( 'Before if 1 ');

--hsiu: added for bug 2682805
    -- Bug 3933576 : proj_element_id shd come from  cur_wp_proj_elem_ver rather than cur_proj_elem_ver
    -- because CI, EGO Items and progress check will happen, even if entry is not there in pa_tasks.

    -- OPEN cur_proj_elem_ver;
    -- FETCH cur_proj_elem_ver INTO l_proj_element_id;
    -- CLOSE cur_proj_elem_ver;

     OPEN cur_wp_proj_elem_ver;
     FETCH cur_wp_proj_elem_ver INTO l_proj_element_id;
     CLOSE cur_wp_proj_elem_ver;


     IF (1 = PA_CONTROL_ITEMS_UTILS.CHECK_CONTROL_ITEM_EXISTS(p_project_id, l_proj_element_id) ) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
--use this error message according to mthai: PA_CI_ITEMS_EXIST
--changed to PA_CI_PROJ_TASK_IN_USE, according to Margaret
       x_error_message_code := 'PA_CI_PROJ_TASK_IN_USE';
       return;
     END IF;
--end bug 2682805

--anlee
--Added for ENG integration

        PA_EGO_WRAPPER_PUB.check_delete_task_ok_eng(
                p_api_version           => 1.0                  ,
                p_task_id               => l_proj_element_id    ,
                p_init_msg_list         => NULL                 ,
                x_delete_ok             => l_delete_ok          ,
                x_return_status         => l_return_status      ,
                x_errorcode             => l_err_code           ,
                x_msg_count             => l_msg_count          ,
                x_msg_data              => l_msg_data );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       return;
     END IF;
-- anlee end of changes

     IF   PA_PROJ_ELEMENTS_UTILS.structure_type(
                 p_structure_version_id     => p_parent_structure_ver_id
                 ,p_task_version_id          => null
                 ,p_structure_type           => 'WORKPLAN'
                 ) = 'Y'
     THEN
         --call selvas API
     -- Bug 3933576 : NO need to open cursor cur_proj_elem_ver here, l_proj_element_id is already fetched
         --OPEN cur_proj_elem_ver;
         --FETCH cur_proj_elem_ver INTO l_proj_element_id;
         --CLOSE cur_proj_elem_ver;

         -- 4201927 commented below code as check_task_progress_exist is deriving project id and then
         -- calling check_object_has_prog api
         /*
         IF pa_project_structure_utils.check_task_progress_exist(l_proj_element_id) = 'Y' THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message_code := 'PA_PS_TASK_HAS_PROG';
             raise FND_API.G_EXC_ERROR;
         END IF;
         */

         -- using the direct api check_object_has_prog

         IF pa_progress_utils.check_object_has_prog(p_project_id => p_project_id, p_object_id => l_proj_element_id) = 'Y' THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message_code := 'PA_PS_TASK_HAS_PROG';
             raise FND_API.G_EXC_ERROR;
         END IF;
        -- 4201927 end

        -- 4201927 , delete dlvr to task association api should get called for
        -- all the tasks

        PA_DELIVERABLE_PUB.delete_dlv_task_asscn_in_bulk
         (
             p_task_element_id      => l_proj_element_id
            ,p_project_id           => p_project_id
            ,p_task_version_id      => p_task_version_id
            ,p_delete_or_validate   => 'V'
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data
         );

	 --  4537865 Changed from x_return_status to l_return_status
         IF l_return_status = FND_API.G_RET_STS_ERROR then
             RAISE FND_API.G_EXC_ERROR;
         End If;

         -- 4201927 end

/*
         IF pa_progress_utils.PROJ_TASK_PROG_EXISTS(p_project_id, l_proj_element_id) = 'Y' THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message_code := 'PA_PS_TASK_HAS_PROG';
             raise FND_API.G_EXC_ERROR;
         END IF;

         IF pa_progress_utils.progress_record_exists( p_task_version_id, 'PA_TASKS'
                            ,p_project_id) = 'Y' -- Fixed bug # 3688901.
         THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             x_error_message_code := 'PA_PS_CANT_DELETE_TASK_VER';
             PA_UTILS.ADD_MESSAGE('PA', 'PA_PS_CANT_DELETE_TASK_VER');
             raise FND_API.G_EXC_ERROR;
         END IF;
*/
     END IF;

     IF PA_PROJ_ELEMENTS_UTILS.structure_type(
                 p_structure_version_id     => p_parent_structure_ver_id
                 ,p_task_version_id          => null
                 ,p_structure_type           => 'FINANCIAL'
                 ) = 'Y' THEN
        --Check if this is a billing/costing structure version
         --if it is, check to see if it is the last version

         --dbms_output.put_line( 'Before cur_chk_last_ver');

--         OPEN cur_chk_last_ver;
--         FETCH cur_chk_last_ver INTO l_dummy;
--         IF cur_chk_last_ver%NOTFOUND -- p_task_version is the last version
--         THEN
             OPEN cur_proj_elem_ver;
             FETCH cur_proj_elem_ver INTO l_proj_element_id;
             CLOSE cur_proj_elem_ver;
             --Check if it is okay to delete task

             IF (l_proj_element_id IS NOT NULL) THEN --it can be partial share
               PA_TASK_UTILS.CHECK_DELETE_TASK_OK( x_task_id     => l_proj_element_id,
                                                 x_validation_mode => p_validation_mode,   --bug 2947492
                                                 x_err_code    => l_err_code,
                                                 x_err_stage   => l_err_stage,
                                                 x_err_stack   => l_err_stack);

               IF (l_err_code <> 0) THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  x_error_message_code := l_err_stage;
                  raise FND_API.G_EXC_ERROR;
               END IF;
             END IF;

--         END IF;
--         CLOSE cur_chk_last_ver;
     END IF;

--linking is not available yet. Comment out
    --Check if this task version has any links
--    open get_link;
--    fetch get_link into l_dummy;
--    if get_link%FOUND then
--      --a link exists
--      close get_link;
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      x_error_message_code := 'PA_PS_LINK_EXISTS';
--      return;
--    end if;
--    close get_link;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- 4537865
      -- Not Resetting x_error_message_code unconditionally as after its population only
      -- it will reach here. In case if its not populated then,populate the generic msg

      IF x_error_message_code is NULL THEN
	 x_error_message_code :=  'PA_CHECK_DELETE_TASK_FAILED';
      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- 4537865
      x_error_message_code := SQLCODE;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                              p_procedure_name => 'Check_Delete_task_Ver_Ok',
			      p_error_text => SUBSTRB(SQLERRM,1,240)); -- 4537865
      RAISE;
  END Check_Delete_task_Ver_Ok;

  function structure_type(
    p_structure_version_id NUMBER,
    p_task_version_id      NUMBER,
    p_structure_type       VARCHAR2 ) RETURN VARCHAR2 IS

    CURSOR cur_proj_elem
    IS
      SELECT parent_structure_version_id
        FROM pa_proj_element_versions
       WHERE element_version_id = p_task_version_id
         AND object_type = 'PA_TASKS';

    CURSOR cur_struc_type( x_structure_version_id NUMBER )
    IS
      SELECT 'Y'
        FROM pa_proj_element_versions ppev
            ,pa_proj_structure_types ppst
            ,pa_structure_types pst
       WHERE ppev.element_version_id = x_structure_version_id
         AND ppev.proj_element_id = ppst.proj_element_id
         AND ppst.structure_type_id = pst.structure_type_id
         AND pst.structure_type_class_code = p_structure_type;


   l_structure_version_id  NUMBER;
   l_dummy_char            VARCHAR2(1);
  begin
      OPEN cur_proj_elem;
      FETCH cur_proj_elem INTO l_structure_version_id;
      CLOSE cur_proj_elem;

      IF l_structure_version_id IS NULL
      THEN
         l_structure_version_id := p_structure_version_id;
      END IF;

      OPEN cur_struc_type( l_structure_version_id );
      FETCH cur_struc_type INTO l_dummy_char;
      IF cur_struc_type%FOUND
      THEN
         CLOSE cur_struc_type;
         RETURN 'Y';
      ELSE
         CLOSE cur_struc_type;
         RETURN 'N';
      END IF;

  end structure_type;

FUNCTION is_summary_task_or_structure( p_element_version_id NUMBER ) RETURN VARCHAR2 IS
 /*  CURSOR cur_obj_rel
   IS
    SELECT 'x'
      FROM  pa_object_relationships
     WHERE object_id_from1 = p_element_version_id
     --hsiu: bug 2800553: performance
       and rownum < 2
      --start with object_id_from1 = p_element_version_id
        AND object_type_from = 'PA_TASKS'
        AND relationship_type = 'S'
        And object_id_to1 NOT IN (
          select b.object_id_from1
            from pa_object_relationships a,
                 pa_object_relationships b
           where a.object_id_from1 = p_element_version_id
             and a.object_id_to1 = b.object_id_from1
             and a.relationship_type = 'S'
             and b.relationship_type IN ('LW', 'LF'))
       ;*/

-- Bug 6156686
       CURSOR cur_obj_rel
       IS
       SELECT NULL
       FROM   DUAL
       WHERE  EXISTS
       (SELECT NULL
        FROM   pa_object_relationships por,
               pa_proj_element_versions pev,
               pa_proj_elements pe
        WHERE  por.object_id_from1 = p_element_version_id
        AND    por.object_type_from ='PA_TASKS'
        AND    por.relationship_type = 'S'
        AND    por.object_id_to1=pev.element_version_id
        AND    pe.proj_element_id=pev.proj_element_id
        AND    (((NVL(pe.link_task_flag,'N') <> 'Y'
        AND    pev.financial_task_flag = 'Y'))
                OR    (pe.task_status is not null)));  -- Added AND Condition for Bug 7210236
				--Added the OR condition for bug 8992059

     --connect by object_id_from1 = prior object_id_to1 ;
v_dummy_char VARCHAR2(1);
BEGIN
   OPEN cur_obj_rel;
   FETCH cur_obj_rel INTO v_dummy_char;
   IF cur_obj_rel%FOUND
   THEN
      CLOSE cur_obj_rel;
      RETURN 'Y';
   ELSE
      CLOSE cur_obj_rel;
      RETURN 'N';
   END IF;

END is_summary_task_or_structure;


  procedure Check_Date_range
  (
    p_scheduled_start_date      IN      DATE            :=null
   ,p_scheduled_end_date        IN      DATE            :=null
   ,p_obligation_start_date   IN        DATE          :=null
   ,p_obligation_end_date       IN      DATE          :=null
   ,p_actual_start_date       IN        DATE          :=null
   ,p_actual_finish_date        IN      DATE          :=null
   ,p_estimate_start_date       IN      DATE          :=null
   ,p_estimate_finish_date      IN      DATE          :=null
   ,p_early_start_date        IN        DATE            :=null
   ,p_early_end_date          IN        DATE          :=null
   ,p_late_start_date         IN        DATE          :=null
   ,p_late_end_date           IN        DATE          :=null
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  ) IS

begin
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_scheduled_start_date IS NOT NULL AND p_scheduled_end_date IS NOT NULL
    THEN
       IF p_scheduled_start_date > p_scheduled_end_date
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_SCH_ST_DT_GT_EN_DT';
          return;
       END IF;
    END IF;

    IF p_obligation_start_date IS NOT NULL AND p_obligation_end_date IS NOT NULL
    THEN
       IF p_obligation_start_date > p_obligation_end_date
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_OBL_ST_DT_GT_EN_DT';
          return;
       END IF;
    END IF;

    IF p_actual_start_date IS NOT NULL AND p_actual_finish_date IS NOT NULL
    THEN
       IF p_actual_start_date > p_actual_finish_date
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_ACT_ST_DT_GT_EN_DT';
          return;
       END IF;
    END IF;

    IF p_estimate_start_date IS NOT NULL AND p_estimate_finish_date IS NOT NULL
    THEN
       IF p_estimate_start_date > p_estimate_finish_date
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_EST_ST_DT_GT_EN_DT';
          return;
       END IF;
    END IF;

    IF p_early_start_date IS NOT NULL AND p_early_end_date IS NOT NULL
    THEN
       IF p_early_start_date > p_early_end_date
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_ERL_ST_DT_GT_EN_DT';
          return;
       END IF;
    END IF;

    IF p_late_start_date IS NOT NULL AND p_late_end_date IS NOT NULL
    THEN
       IF p_late_start_date > p_late_end_date
       THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_PS_LAT_ST_DT_GT_EN_DT';
          return;
       END IF;
    END IF;
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
		x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
		x_error_message_code := SQLCODE ;
		fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_ELEMENTS_UTILS',
                              p_procedure_name => 'Check_Date_range',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
		RAISE;
end Check_Date_range;

PROCEDURE Project_Name_Or_Id
  (
    p_project_name                      IN  VARCHAR2
   ,p_project_id                        IN  NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 := 'Y'
   ,x_project_id                        OUT NOCOPY  NUMBER -- 4537865
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_msg_code                OUT  NOCOPY VARCHAR2 -- 4537865
  )
  IS
  BEGIN
    IF (p_project_id IS NOT NULL) THEN
      IF (p_check_id_flag = 'Y') THEN
        select project_id
          into x_project_id
          from pa_projects_all
         where project_id = p_project_id;
      ELSE
        x_project_id := p_project_id;
      END IF;
    ELSE
      select project_id
        into x_project_id
        from pa_projects_all
       where segment1 = p_project_name;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PS_INVALID_PRJ_NAME';
	 x_project_id := NULL ; -- 4537865

       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PS_PRJ_NAME_NOT_UNIQUE';
	 x_project_id := NULL ; -- 4537865
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	  x_project_id := NULL ; -- 4537865
         RAISE;
  END Project_Name_Or_Id;

PROCEDURE task_Ver_Name_Or_Id
  (
    p_task_name                         IN  VARCHAR2
   ,p_task_version_id                   IN  NUMBER
   ,p_structure_version_id              IN NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 := 'Y'
   ,x_task_version_id                   OUT NOCOPY  NUMBER  -- 4537865
   ,x_return_status                     OUT NOCOPY VARCHAR2  -- 4537865
   ,x_error_msg_code                    OUT NOCOPY VARCHAR2  -- 4537865
  )
  IS
  BEGIN
    IF (p_task_version_id IS NOT NULL) THEN
      IF (p_check_id_flag = 'Y') THEN
        select element_version_id
          into x_task_version_id
          from pa_proj_element_versions
         where element_version_id = p_task_version_id;
      ELSE
        x_task_version_id := p_task_version_id;
      END IF;
    ELSE
      select element_version_id
        into x_task_version_id
        from pa_proj_elements ppe, pa_proj_element_versions ppev
       where ppe.proj_element_id = ppev.proj_element_id
         AND ppe.name = p_task_name
         AND ppev.parent_structure_version_id = p_structure_version_id;
       null;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PS_INVALID_TSK_NAME';
	 -- 4537865
	 x_task_version_id := NULL ;

       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_PS_TSK_NAME_NOT_UNIQUE';
         -- 4537865
         x_task_version_id := NULL ;

       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         -- 4537865
         x_task_version_id := NULL ;
	 x_error_msg_code:= SQLCODE ;

         RAISE;
END task_Ver_Name_Or_Id;

/* ----------------------------------------------------------------------
||
||  Procedure Name:  UPDATE_WBS_NUMBERS
||
||  Author        : Andrew Lee
||  Description:
||     This procedure is called update the wbs numbers in the task
||     hierarchy whenever any of the following actions occur:
||     INSERT
||     INDENT
||     OUTDENT
||     COPY
||     DELETE
|| ---------------------------------------------------------------------
*/
PROCEDURE UPDATE_WBS_NUMBERS ( p_commit                  IN        VARCHAR2
                              ,p_debug_mode              IN        VARCHAR2
                              ,p_parent_structure_ver_id IN        NUMBER
                              ,p_task_id                 IN        NUMBER
                              ,p_display_seq             IN        NUMBER
                              ,p_action                  IN        VARCHAR2
                              ,p_parent_task_id          IN        NUMBER
                              ,x_return_status          OUT NOCOPY       VARCHAR2) -- 4537865
IS
  CURSOR TASK_INFO_CSR(c_task_id NUMBER)
  IS
  SELECT rel.object_id_from1 parent_task_id, pev.wbs_number
  FROM   PA_PROJ_ELEMENT_VERSIONS pev, PA_OBJECT_RELATIONSHIPS rel
  WHERE  pev.element_version_id = c_task_id
  AND    pev.object_type = 'PA_TASKS'
  AND    rel.object_id_to1 = pev.element_version_id
  AND    rel.relationship_type = 'S'
  AND    rel.object_type_from in ('PA_TASKS', 'PA_STRUCTURES');

  CURSOR UPDATE_MASKED_TASKS_CSR (c_parent_structure_ver_id NUMBER, c_display_seq NUMBER, c_mask VARCHAR2)
  IS
  SELECT element_version_id task_id, wbs_number, display_sequence
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  parent_structure_version_id = c_parent_structure_ver_id
  AND    object_type = 'PA_TASKS'
  AND    abs(display_sequence) >= abs(c_display_seq)
  AND    display_sequence <> c_display_seq
  --  AND    substr(wbs_number, 1, length(c_mask)) = c_mask   Commented for bug 3581030
  AND    substr(wbs_number, 1, length(c_mask)+1) = c_mask||'.'  -- Added for bug 3581030
  ORDER BY abs(display_sequence);

  CURSOR UPDATE_TASKS_CSR (c_parent_structure_ver_id NUMBER, c_display_seq NUMBER)
  IS
  SELECT element_version_id task_id, wbs_number, display_sequence
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  parent_structure_version_id = c_parent_structure_ver_id
  AND    object_type = 'PA_TASKS'
  AND    abs(display_sequence) >= abs(c_display_seq)
  AND    display_sequence <> c_display_seq
  ORDER BY abs(display_sequence);

  CURSOR GET_TASK_CSR (c_parent_structure_ver_id NUMBER, c_display_seq NUMBER)
  IS
  SELECT element_version_id task_id
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  parent_structure_version_id = c_parent_structure_ver_id
  AND    object_type = 'PA_TASKS'
  AND  display_sequence = c_display_seq;

  CURSOR GET_PREV_PEER_TASK_CSR(c_parent_structure_ver_id NUMBER, c_parent_task_id NUMBER, c_display_seq NUMBER)
  IS
  SELECT element_version_id task_id
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  parent_structure_version_id = c_parent_structure_ver_id
  AND    object_type = 'PA_TASKS'
  AND    display_sequence =
    (SELECT max(pev.display_sequence)
     FROM   PA_PROJ_ELEMENT_VERSIONS pev, PA_OBJECT_RELATIONSHIPS rel
     WHERE  rel.object_type_from = 'PA_TASKS'
     AND    rel.object_id_from1 = c_parent_task_id
     AND    rel.relationship_type = 'S'
     AND    rel.object_type_to =  'PA_TASKS'
     AND    rel.object_id_to1 = pev.element_version_id
     AND    pev.parent_structure_version_id = c_parent_structure_ver_id
     AND    pev.display_sequence < c_display_seq);

  CURSOR GET_PREV_TOP_PEER_TASK_CSR(c_parent_structure_ver_id NUMBER, c_display_seq NUMBER)
  IS
  SELECT element_version_id task_id
  FROM   PA_PROJ_ELEMENT_VERSIONS
  WHERE  parent_structure_version_id = c_parent_structure_ver_id
  AND    object_type = 'PA_TASKS'
  AND    display_sequence =
    (SELECT max(pev.display_sequence)
     FROM   PA_PROJ_ELEMENT_VERSIONS pev, PA_OBJECT_RELATIONSHIPS rel
     WHERE  rel.object_type_from = 'PA_STRUCTURES'
     AND    rel.object_id_from1 = c_parent_structure_ver_id
     AND    rel.relationship_type = 'S'
     AND    rel.object_type_to =  'PA_TASKS'
     AND    rel.object_id_to1 = pev.element_version_id
     AND    pev.parent_structure_version_id = c_parent_structure_ver_id
     AND    display_sequence < c_display_seq);

  l_task_rec        TASK_INFO_CSR%ROWTYPE;
  l_prev_task_rec   TASK_INFO_CSR%ROWTYPE;
  l_parent_task_rec TASK_INFO_CSR%ROWTYPE;
  l_temp            TASK_INFO_CSR%ROWTYPE;
  l_update_task_rec UPDATE_TASKS_CSR%ROWTYPE;
  l_task_id         NUMBER;

  l_count           NUMBER;
  l_wbs_number      VARCHAR2(1000);
  l_mask            VARCHAR2(1000);
  l_branch_mask     VARCHAR2(1000);
  l_mask2           VARCHAR2(1000);
  l_prev_disp_seq   NUMBER;
  l_prev_task_id    NUMBER;
  l_increment       VARCHAR2(255);
  l_str1            VARCHAR2(1000);
  l_str2            VARCHAR2(1000);
  l_loop_wbs_number VARCHAR2(1000);
  l_flag            BOOLEAN;

  API_ERROR         EXCEPTION;
  l_number          NUMBER; -- Bug 2786662
BEGIN
  if p_commit = 'Y' then
    savepoint update_wbs_numbers;
  end if;

  if(p_action <> 'DELETE') then
    OPEN TASK_INFO_CSR(p_task_id);
    FETCH TASK_INFO_CSR INTO l_task_rec;
    if(TASK_INFO_CSR%NOTFOUND) then
      CLOSE TASK_INFO_CSR;
      x_return_status := 'E';
      raise API_ERROR;
    end if;
    CLOSE TASK_INFO_CSR;
  end if;

  -- INSERT or COPY
  if((p_action = 'INSERT') OR (p_action = 'COPY')) then
    if(l_task_rec.parent_task_id = p_parent_structure_ver_id) then
      -- Inserted task is a top task
      -- Added the leading hint below for bug 3416314
      -- Smukka Merging branch 40 as of now with main branch
      SELECT /*+ LEADING (rel) */ count(pev.element_version_id)
      INTO   l_count
      FROM   PA_PROJ_ELEMENT_VERSIONS pev, PA_OBJECT_RELATIONSHIPS rel
      WHERE  pev.parent_structure_version_id = p_parent_structure_ver_id
      AND    pev.object_type = 'PA_TASKS'
      AND    abs(pev.display_sequence) <= abs(p_display_seq)
      AND    rel.object_id_to1 = pev.element_version_id
      AND    rel.relationship_type = 'S'
      AND    rel.object_type_from = 'PA_STRUCTURES'
      AND    rel.object_id_from1 = p_parent_structure_ver_id
      AND    rel.object_type_to = 'PA_TASKS'; --Added for Bug 6430953

      l_wbs_number := l_count;
      l_mask := 'NONE';
    else
      -- Inserted task is a child task
      l_prev_disp_seq := abs(p_display_seq) - 1;
      OPEN GET_TASK_CSR(p_parent_structure_ver_id, l_prev_disp_seq);
      FETCH GET_TASK_CSR INTO l_prev_task_id;
      if(GET_TASK_CSR%NOTFOUND) then
        CLOSE GET_TASK_CSR;
        OPEN GET_TASK_CSR(p_parent_structure_ver_id, l_prev_disp_seq * -1);
        FETCH GET_TASK_CSR INTO l_prev_task_id;
        if(GET_TASK_CSR%NOTFOUND) then
          CLOSE GET_TASK_CSR;
          x_return_status := 'E';
          raise API_ERROR;
        end if;
      end if;

      CLOSE GET_TASK_CSR;


      if(l_prev_task_id = l_task_rec.parent_task_id) then
        -- Previous task is a parent
        OPEN TASK_INFO_CSR(l_prev_task_id);
        FETCH TASK_INFO_CSR INTO l_prev_task_rec;
        CLOSE TASK_INFO_CSR;

        l_wbs_number := l_prev_task_rec.wbs_number || '.1';
        l_mask := l_prev_task_rec.wbs_number;
      else
        -- Previous task is a peer task
        OPEN TASK_INFO_CSR(l_task_rec.parent_task_id);
        FETCH TASK_INFO_CSR INTO l_parent_task_rec;
        CLOSE TASK_INFO_CSR;

        OPEN GET_PREV_PEER_TASK_CSR(p_parent_structure_ver_id, l_task_rec.parent_task_id, p_display_seq);
        FETCH GET_PREV_PEER_TASK_CSR INTO l_prev_task_id;
        CLOSE GET_PREV_PEER_TASK_CSR;

        OPEN TASK_INFO_CSR(l_prev_task_id);
        FETCH TASK_INFO_CSR INTO l_prev_task_rec;
        CLOSE TASK_INFO_CSR;

        l_increment := to_char(to_number(substr(l_prev_task_rec.wbs_number, length(l_parent_task_rec.wbs_number) + 2)) + 1);
        l_wbs_number := substr(l_prev_task_rec.wbs_number, 1, length(l_parent_task_rec.wbs_number)) || '.' || l_increment;
        l_mask := l_parent_task_rec.wbs_number;
      end if;
    end if; -- ig(l_task_rec.parent_task_id = p_parent_structure_ver_id) then

    -- Update the WBS number for the inserted task
    UPDATE PA_PROJ_ELEMENT_VERSIONS
    SET    wbs_number = l_wbs_number
    WHERE  element_version_id = p_task_id;

    -- Loop through tasks that have a greater display seq than the current
    -- and begins with the same mask (in the same branch)
    if(l_mask = 'NONE') then
      OPEN UPDATE_TASKS_CSR(p_parent_structure_ver_id, p_display_seq);
    else
      OPEN UPDATE_MASKED_TASKS_CSR(p_parent_structure_ver_id, p_display_seq, l_mask);
    end if;

    LOOP
      if(l_mask = 'NONE') then
        FETCH UPDATE_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_TASKS_CSR%NOTFOUND;

        if(instr(l_update_task_rec.wbs_number, '.') <> 0) then
          l_str1 := substr(l_update_task_rec.wbs_number, 1, instr(l_update_task_rec.wbs_number, '.') - 1);
          l_str2 := substr(l_update_task_rec.wbs_number, instr(l_update_task_rec.wbs_number, '.'));
          l_str1 := to_char(to_number(l_str1 + 1));

          l_wbs_number := l_str1 || l_str2;
        else
          l_wbs_number := to_char(to_number(l_update_task_rec.wbs_number) + 1);
        end if;
      else
        FETCH UPDATE_MASKED_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_MASKED_TASKS_CSR%NOTFOUND;

        l_str1 := substr(l_update_task_rec.wbs_number, length(l_mask) + 2);
        if(instr(l_str1, '.') <> 0) then
          l_str2 := substr(l_str1, instr(l_str1, '.'));
          l_str1 := substr(l_str1, 1, instr(l_str1, '.') - 1);
          l_str1 := to_char(to_number(l_str1) + 1);

          l_wbs_number := l_mask || '.' || l_str1 || l_str2;
        else
          l_str1 := to_char(to_number(l_str1) + 1);
          l_wbs_number := l_mask || '.' || l_str1;
        end if;

      end if;

      -- Update the WBS number
      UPDATE PA_PROJ_ELEMENT_VERSIONS
      SET    wbs_number = l_wbs_number
      WHERE  element_version_id = l_update_task_rec.task_id;
    END LOOP;

    if(l_mask = 'NONE') then
      CLOSE UPDATE_TASKS_CSR;
    else
      CLOSE UPDATE_MASKED_TASKS_CSR;
    end if;

  elsif(p_action = 'INDENT') then
    -- Get the last previous peer task
    OPEN GET_PREV_PEER_TASK_CSR(p_parent_structure_ver_id, l_task_rec.parent_task_id, p_display_seq);
    FETCH GET_PREV_PEER_TASK_CSR INTO l_prev_task_id;

    -- Increment the last digit of the peer task wbs number to
    -- get the indented task's wbs number
    OPEN TASK_INFO_CSR(l_task_rec.parent_task_id);
    FETCH TASK_INFO_CSR INTO l_parent_task_rec;
    CLOSE TASK_INFO_CSR;

    if(GET_PREV_PEER_TASK_CSR%NOTFOUND) then
      -- No previous peer tasks; first peer task under the parent
      OPEN TASK_INFO_CSR(l_task_rec.parent_task_id);
      FETCH TASK_INFO_CSR INTO l_prev_task_rec;
      CLOSE TASK_INFO_CSR;

      l_wbs_number := l_prev_task_rec.wbs_number || '.1';
    else
      OPEN TASK_INFO_CSR(l_prev_task_id);
      FETCH TASK_INFO_CSR INTO l_prev_task_rec;
      CLOSE TASK_INFO_CSR;

      l_str1 := substr(l_prev_task_rec.wbs_number, 1, length(l_parent_task_rec.wbs_number));
      l_str2 := substr(l_prev_task_rec.wbs_number, length(l_parent_task_rec.wbs_number) + 2);
      l_str2 := to_char(to_number(l_str2 + 1));

      l_wbs_number := l_str1 || '.' || l_str2;
    end if;

    CLOSE GET_PREV_PEER_TASK_CSR;

    l_branch_mask := l_task_rec.wbs_number;
    --dbms_output.put_line('L_BRANCH_MASK: ' || l_branch_mask);

    --dbms_output.put_line('L_WBS_NUMBER: ' || l_wbs_number);

    -- Update the WBS number for the indented task
    UPDATE PA_PROJ_ELEMENT_VERSIONS
    SET    wbs_number = l_wbs_number
    WHERE  element_version_id = p_task_id;

    -- Find l_mask
    OPEN TASK_INFO_CSR(l_task_rec.parent_task_id);
    FETCH TASK_INFO_CSR INTO l_temp;
    CLOSE TASK_INFO_CSR;

    if(l_temp.parent_task_id = p_parent_structure_ver_id) then
      -- This indented task used to be a top task
      l_mask := 'NONE';
    else
      OPEN TASK_INFO_CSR(l_parent_task_rec.parent_task_id);
      FETCH TASK_INFO_CSR INTO l_parent_task_rec;
      CLOSE TASK_INFO_CSR;

      l_mask := l_parent_task_rec.wbs_number;
    end if;

    --dbms_output.put_line('L_MASK: ' || l_mask);

    if(l_mask = 'NONE') then
      OPEN UPDATE_TASKS_CSR(p_parent_structure_ver_id, p_display_seq);
    else
      OPEN UPDATE_MASKED_TASKS_CSR(p_parent_structure_ver_id, p_display_seq, l_mask);
    end if;

    LOOP
      if(l_mask = 'NONE') then
        FETCH UPDATE_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_TASKS_CSR%NOTFOUND;

        if(substr(l_update_task_rec.wbs_number, 1, length(l_branch_mask)) = l_branch_mask) then
          -- Task is under the indented branch
          -- Bug 2786662  Commented the replace and used substr to get the l_loop_wbs_number
          --l_loop_wbs_number := replace(l_update_task_rec.wbs_number, l_branch_mask, l_wbs_number);
          l_number := instr(l_update_task_rec.wbs_number, l_branch_mask, 1, 1);
          l_str1 := substr(l_update_task_rec.wbs_number, 1, l_number -1);
          l_str2 := substr(l_update_task_rec.wbs_number, length(l_branch_mask)+l_number);
          l_loop_wbs_number := l_str1 || l_wbs_number || l_str2;

        else

          if(instr(l_update_task_rec.wbs_number, '.') <> 0) then
            l_str1 := substr(l_update_task_rec.wbs_number, 1, instr(l_update_task_rec.wbs_number, '.') - 1);
            l_str2 := substr(l_update_task_rec.wbs_number, instr(l_update_task_rec.wbs_number, '.'));
            l_str1 := to_char(to_number(l_str1) - 1);

            l_loop_wbs_number := l_str1 || l_str2;
          else
            l_loop_wbs_number := to_char(to_number(l_update_task_rec.wbs_number) - 1);
          end if;
        end if;

      else
        FETCH UPDATE_MASKED_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_MASKED_TASKS_CSR%NOTFOUND;

        if(substr(l_update_task_rec.wbs_number, 1, length(l_branch_mask)) = l_branch_mask) then
          -- Task is under the indented branch
          -- Bug 2786662  Commented the replace and used substr to get the l_loop_wbs_number
          --l_loop_wbs_number := replace(l_update_task_rec.wbs_number, l_branch_mask, l_wbs_number);
          l_number := instr(l_update_task_rec.wbs_number, l_branch_mask, 1, 1);
          l_str1 := substr(l_update_task_rec.wbs_number, 1, l_number -1);
          l_str2 := substr(l_update_task_rec.wbs_number, length(l_branch_mask)+l_number);
          l_loop_wbs_number := l_str1 || l_wbs_number || l_str2;

        else

          l_str1 := substr(l_update_task_rec.wbs_number, length(l_mask) + 2);
          if(instr(l_str1, '.') <> 0) then
            l_str2 := substr(l_str1, instr(l_str1, '.'));
            l_str1 := substr(l_str1, 1, instr(l_str1, '.') - 1);
            l_str1 := to_char(to_number(l_str1) - 1);

            l_loop_wbs_number := l_mask || '.' || l_str1 || l_str2;
          else
            l_str1:= to_char(to_number(l_str1) - 1);
            l_loop_wbs_number := l_mask || '.' || l_str1;
          end if;
        end if;

      end if;

      -- Update the WBS number
      UPDATE PA_PROJ_ELEMENT_VERSIONS
      SET    wbs_number = l_loop_wbs_number
      WHERE  element_version_id = l_update_task_rec.task_id;
    END LOOP;

    if(l_mask = 'NONE') then
      CLOSE UPDATE_TASKS_CSR;
    else
      CLOSE UPDATE_MASKED_TASKS_CSR;
    end if;

  elsif(p_action = 'OUTDENT') then
    if(l_task_rec.parent_task_id = p_parent_structure_ver_id) then
      -- At top level; no parent task
      OPEN GET_PREV_TOP_PEER_TASK_CSR(p_parent_structure_ver_id, p_display_seq);
      FETCH GET_PREV_TOP_PEER_TASK_CSR INTO l_prev_task_id;

      if(GET_PREV_TOP_PEER_TASK_CSR%NOTFOUND) then
        x_return_status := 'E';
        raise API_ERROR;
      end if;
      CLOSE GET_PREV_TOP_PEER_TASK_CSR;
    else
      -- Get the last previous peer task
      OPEN GET_PREV_PEER_TASK_CSR(p_parent_structure_ver_id, l_task_rec.parent_task_id, p_display_seq);
      FETCH GET_PREV_PEER_TASK_CSR INTO l_prev_task_id;

      if(GET_PREV_PEER_TASK_CSR%NOTFOUND) then
        x_return_status := 'E';
        raise API_ERROR;
      end if;
      CLOSE GET_PREV_PEER_TASK_CSR;
    end if;

    OPEN TASK_INFO_CSR(l_prev_task_id);
    FETCH TASK_INFO_CSR INTO l_prev_task_rec;
    CLOSE TASK_INFO_CSR;

    --dbms_output.put_line('Previous peer task: ' || l_prev_task_rec.wbs_number);

    -- Increment the last digit of the peer task wbs number to
    -- get the outdented task's wbs number
    OPEN TASK_INFO_CSR(l_task_rec.parent_task_id);
    FETCH TASK_INFO_CSR INTO l_parent_task_rec;
    if(TASK_INFO_CSR%NOTFOUND) then
      -- Outdented task is now a top task
      l_wbs_number := l_prev_task_rec.wbs_number + 1;
    else
      l_str1 := substr(l_prev_task_rec.wbs_number, 1, length(l_parent_task_rec.wbs_number));
      l_str2 := substr(l_prev_task_rec.wbs_number, length(l_parent_task_rec.wbs_number) + 2);
      l_str2 := to_char(to_number(l_str2 + 1));

      l_wbs_number := l_str1 || '.' || l_str2;
    end if;

    CLOSE TASK_INFO_CSR;


    -- l_branch_mask contains the old wbs_number (before the task was outdented)
    l_branch_mask := l_task_rec.wbs_number;
    --dbms_output.put_line('L_BRANCH_MASK: ' || l_branch_mask);

    -- l_mask2 contains the wbs number of the previous peer task
    -- This mask is used to find subsequent peer/child tasks of the outdented task (before it was
    -- outdented)
    l_mask2 := l_prev_task_rec.wbs_number;
    --dbms_output.put_line('L_MASK2: ' || l_mask2);

    -- Update the WBS number for the outdented task
    UPDATE PA_PROJ_ELEMENT_VERSIONS
    SET    wbs_number = l_wbs_number
    WHERE  element_version_id = p_task_id;

    --dbms_output.put_line('L_WBS_NUMBER: ' || l_wbs_number);

    -- Find l_mask
    if(l_task_rec.parent_task_id = p_parent_structure_ver_id) then
      -- This outdented task has become a top task
      l_mask := 'NONE';
    else
      l_mask := l_parent_task_rec.wbs_number;
    end if;

    --dbms_output.put_line('L_MASK: ' || l_mask);

    if(l_mask = 'NONE') then
      OPEN UPDATE_TASKS_CSR(p_parent_structure_ver_id, p_display_seq);
    else
      OPEN UPDATE_MASKED_TASKS_CSR(p_parent_structure_ver_id, p_display_seq, l_mask);
    end if;

    LOOP
      if(l_mask = 'NONE') then
        FETCH UPDATE_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_TASKS_CSR%NOTFOUND;

        if(substr(l_update_task_rec.wbs_number, 1, length(l_branch_mask)) = l_branch_mask) then
          -- Task is under the outdented branch
          -- Bug 2786662  Commented the replace and used substr to get the l_loop_wbs_number
          --l_loop_wbs_number := replace(l_update_task_rec.wbs_number, l_branch_mask, l_wbs_number);
          l_number := instr(l_update_task_rec.wbs_number, l_branch_mask, 1, 1);
          l_str1 := substr(l_update_task_rec.wbs_number, 1, l_number -1);
          l_str2 := substr(l_update_task_rec.wbs_number, length(l_branch_mask)+l_number);
          l_loop_wbs_number := l_str1 || l_wbs_number || l_str2;

        elsif(substr(l_update_task_rec.wbs_number, 1, length(l_mask2)) = l_mask2) then
          -- Task used to be a peer of the outdented task
          OPEN GET_PREV_PEER_TASK_CSR(p_parent_structure_ver_id, p_task_id, l_update_task_rec.display_sequence);
          FETCH GET_PREV_PEER_TASK_CSR INTO l_prev_task_id;
          if(GET_PREV_PEER_TASK_CSR%NOTFOUND) then
            l_loop_wbs_number := l_wbs_number || '.1';
          else
            OPEN TASK_INFO_CSR(l_prev_task_id);
            FETCH TASK_INFO_CSR INTO l_prev_task_rec;
            CLOSE TASK_INFO_CSR;
            l_str1 := substr(l_prev_task_rec.wbs_number, length(l_wbs_number) + 2);
            l_str1 := to_char(to_number(l_str1 + 1));
            l_loop_wbs_number := l_wbs_number || '.' || l_str1;
          end if;
          CLOSE GET_PREV_PEER_TASK_CSR;

        else
          if(instr(l_update_task_rec.wbs_number, '.') <> 0) then
            l_str1 := substr(l_update_task_rec.wbs_number, 1, instr(l_update_task_rec.wbs_number, '.') - 1);
            l_str2 := substr(l_update_task_rec.wbs_number, instr(l_update_task_rec.wbs_number, '.'));
            l_str1 := to_char(to_number(l_str1) + 1);

            l_loop_wbs_number := l_str1 || l_str2;
          else
            l_loop_wbs_number := to_char(to_number(l_update_task_rec.wbs_number) + 1);
          end if;
        end if;

      else
        FETCH UPDATE_MASKED_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_MASKED_TASKS_CSR%NOTFOUND;

        if(substr(l_update_task_rec.wbs_number, 1, length(l_branch_mask)) = l_branch_mask) then
          -- Task is under the indented branch
          -- Bug 2786662  Commented the replace and used substr to get the l_loop_wbs_number
          --l_loop_wbs_number := replace(l_update_task_rec.wbs_number, l_branch_mask, l_wbs_number);
          l_number := instr(l_update_task_rec.wbs_number, l_branch_mask, 1, 1);
          l_str1 := substr(l_update_task_rec.wbs_number, 1, l_number -1);
          l_str2 := substr(l_update_task_rec.wbs_number, length(l_branch_mask)+l_number);
          l_loop_wbs_number := l_str1 || l_wbs_number || l_str2;

        elsif(substr(l_update_task_rec.wbs_number, 1, length(l_mask2)) = l_mask2) then
          -- Task used to be a peer of the outdented task
          OPEN GET_PREV_PEER_TASK_CSR(p_parent_structure_ver_id, p_task_id, l_update_task_rec.display_sequence);
          FETCH GET_PREV_PEER_TASK_CSR INTO l_prev_task_id;
          if(GET_PREV_PEER_TASK_CSR%NOTFOUND) then
            --dbms_output.put_line('HELLO2');
            l_loop_wbs_number := l_wbs_number || '.1';
          else
            OPEN TASK_INFO_CSR(l_prev_task_id);
            FETCH TASK_INFO_CSR INTO l_prev_task_rec;
            CLOSE TASK_INFO_CSR;
            --dbms_output.put_line('HELLO: ' || l_prev_task_rec.wbs_number);
            l_str1 := substr(l_prev_task_rec.wbs_number, length(l_wbs_number) + 2);
            l_str1 := to_char(to_number(l_str1 + 1));
            l_loop_wbs_number := l_wbs_number || '.' || l_str1;
          end if;
          CLOSE GET_PREV_PEER_TASK_CSR;

        else

          l_str1 := substr(l_update_task_rec.wbs_number, length(l_mask) + 2);
          if(instr(l_str1, '.') <> 0) then
            l_str2 := substr(l_str1, instr(l_str1, '.'));
            l_str1 := substr(l_str1, 1, instr(l_str1, '.') - 1);
            l_str1 := to_char(to_number(l_str1) + 1);

            l_loop_wbs_number := l_mask || '.' || l_str1 || l_str2;
          else
            l_str1 := to_char(to_number(l_str1) + 1);
            l_loop_wbs_number := l_mask || '.' || l_str1;
          end if;
        end if;

      end if;

      -- Update the WBS number
      UPDATE PA_PROJ_ELEMENT_VERSIONS
      SET    wbs_number = l_loop_wbs_number
      WHERE  element_version_id = l_update_task_rec.task_id;
    END LOOP;

    if(l_mask = 'NONE') then
      CLOSE UPDATE_TASKS_CSR;
    else
      CLOSE UPDATE_MASKED_TASKS_CSR;
    end if;

  elsif(p_action = 'DELETE') then
    if(p_parent_task_id = p_parent_structure_ver_id ) then
      -- Deleted task is a top task
      --dbms_output.put_line('Is parent task');
      l_mask := 'NONE';
    else
      -- Deleted task is not a top task
      OPEN TASK_INFO_CSR(p_parent_task_id);
      FETCH TASK_INFO_CSR INTO l_parent_task_rec;
      CLOSE TASK_INFO_CSR;

      l_mask := l_parent_task_rec.wbs_number;
    end if;

    -- Loop through tasks that have a greater display seq than the current
    -- and begins with the same mask (in the same branch)
    if(l_mask = 'NONE') then
      OPEN UPDATE_TASKS_CSR(p_parent_structure_ver_id, p_display_seq);
    else
      OPEN UPDATE_MASKED_TASKS_CSR(p_parent_structure_ver_id, p_display_seq, l_mask);
    end if;

    --dbms_output.put_line('L_MASK: '||l_mask);
    LOOP
      if(l_mask = 'NONE') then
        --dbms_output.put_line('IN LOOP');
        FETCH UPDATE_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_TASKS_CSR%NOTFOUND;

        ----dbms_output.put_line('L_UPDATE_TASK_REC.WBS_NUMBER: '|| l_update_task_rec.wbs_number);

        if(instr(l_update_task_rec.wbs_number, '.') <> 0) then
          l_str1 := substr(l_update_task_rec.wbs_number, 1, instr(l_update_task_rec.wbs_number, '.') - 1);
          l_str2 := substr(l_update_task_rec.wbs_number, instr(l_update_task_rec.wbs_number, '.'));
          l_str1 := to_char(to_number(l_str1) - 1);

          l_wbs_number := l_str1 || l_str2;
        else
          l_wbs_number := to_char(to_number(l_update_task_rec.wbs_number) - 1);
        end if;
      else
        FETCH UPDATE_MASKED_TASKS_CSR INTO l_update_task_rec;
        EXIT WHEN UPDATE_MASKED_TASKS_CSR%NOTFOUND;

        l_str1 := substr(l_update_task_rec.wbs_number, length(l_mask) + 2);
        if(instr(l_str1, '.') <> 0) then
          l_str2 := substr(l_str1, instr(l_str1, '.'));
          l_str1 := substr(l_str1, 1, instr(l_str1, '.') - 1);
          l_str1 := to_char(to_number(l_str1) - 1);

          l_wbs_number := l_mask || '.' || l_str1 || l_str2;
        else
          l_str1 := to_char(to_number(l_str1) - 1);
          l_wbs_number := l_mask || '.' || l_str1;
        end if;
      end if;

      -- Update the WBS number
      UPDATE PA_PROJ_ELEMENT_VERSIONS
      SET    wbs_number = l_wbs_number
      WHERE  element_version_id = l_update_task_rec.task_id;
    END LOOP;

    if(l_mask = 'NONE') then
      CLOSE UPDATE_TASKS_CSR;
    else
      CLOSE UPDATE_MASKED_TASKS_CSR;
    end if;
  end if;

  x_return_status := 'S';

  if(p_commit = 'Y') then
    commit;
  end if;
EXCEPTION
  when API_ERROR then
    if p_commit = 'Y' then
      rollback to update_wbs_numbers;
    end if;

     x_return_status := 'E'; -- 4537865
 WHEN OTHERS THEN
    if p_commit = 'Y' then
      rollback to update_wbs_numbers;
    end if;

    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASK_PUB1',
                            p_procedure_name => 'UPDATE_WBS_NUMBERS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    x_return_status := 'E';
END UPDATE_WBS_NUMBERS;


FUNCTION task_exists_in_struc_ver(
  p_structure_version_id NUMBER,
  p_task_version_id      NUMBER ) RETURN VARCHAR2 IS

  CURSOR cur_ppev
  IS
    SELECT 'x'
      FROM pa_proj_element_versions
     WHERE element_version_id = p_task_version_id
       AND parent_structure_version_id = p_structure_version_id;
  l_dummy_char VARCHAR2(1);
BEGIN
    OPEN cur_ppev;
    FETCH cur_ppev INTO l_dummy_char;
    IF cur_ppev%FOUND
    THEN
       CLOSE cur_ppev;
       RETURN 'Y';
    ELSE
       CLOSE cur_ppev;
       RETURN 'N';
    END IF;

END task_exists_in_struc_ver;

FUNCTION GET_LINKED_TASK_VERSION_ID(
    p_cur_element_id                     NUMBER ,
    p_cur_element_version_id             NUMBER
) RETURN NUMBER IS

  CURSOR cur_obj_rel
  IS
    SELECT object_id_to1
      FROM pa_object_relationships
     WHERE object_id_from1 = p_cur_element_version_id
       AND relationship_type = 'L';
  l_linked_task_ver_id NUMBER;
BEGIN
    --A linking task can only link one task.

   IF LINK_FLAG( p_cur_element_id ) = 'Y'
   THEN
       OPEN cur_obj_rel;
       FETCH cur_obj_rel INTO l_linked_task_ver_id;
       CLOSE cur_obj_rel;
       RETURN l_linked_task_ver_id;
   ELSE
       RETURN p_cur_element_version_id;
   END IF;

END GET_LINKED_TASK_VERSION_ID;

FUNCTION LINK_FLAG( p_element_id NUMBER ) RETURN VARCHAR2 IS
    CURSOR cur_proj_elements
    IS
      SELECT link_task_flag
        FROM pa_proj_elements
       WHERE proj_element_id = p_element_id;

    l_link_task_flag VARCHAR2(1) :='N';    --bug 4180390
BEGIN

/* comenting the code for bug 4180390
    OPEN cur_proj_elements;
    FETCH cur_proj_elements INTO l_link_task_flag;
    CLOSE cur_proj_elements;
*/

    RETURN l_link_task_flag;

END LINK_FLAG;


-- API name                      : CHECK_TASK_IN_STRUCTURE
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if task is in structure; N for task in
--                                 different struture.
--
-- Parameters
--    p_structure_version_id    IN  NUMBER
--    p_task_version_id         IN  NUMBER
--
--  History
--
--  09-JAN-02   HSIU             -Created
--
FUNCTION CHECK_TASK_IN_STRUCTURE(p_structure_version_id NUMBER,
                                 p_task_version_id NUMBER)
RETURN VARCHAR2 IS
  CURSOR c1 IS
    select '1'
      from pa_proj_element_versions
     where p_task_version_id = element_version_id
       and p_structure_version_id = parent_structure_version_id;

  l_dummy VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    return 'N';
  END IF;
  CLOSE c1;
  return 'Y';
END CHECK_TASK_IN_STRUCTURE;


FUNCTION GET_DISPLAY_PARENT_VERSION_ID(p_element_version_id NUMBER,
                                       p_parent_element_version_id NUMBER,
                                       p_relationship_type VARCHAR2,
                                       p_link_task_flag VARCHAR2)
RETURN NUMBER IS
  cursor get_display_parent_id IS
    select object_id_from1
      from pa_object_relationships
     where relationship_type = 'S'
       and object_id_to1 = p_parent_element_version_id;
  l_display_parent_version_id NUMBER;
BEGIN
  IF (p_relationship_type = 'L') THEN
    --return parent of the parent element version
    OPEN get_display_parent_id;
    FETCH get_display_parent_id into l_display_parent_version_id;
    CLOSE get_display_parent_id;
    return l_display_parent_version_id;
  ELSIF (p_link_task_flag = 'Y') THEN
    return to_number(NULL);
  END IF;
  --a normal task. Return its current parent
  return p_parent_element_version_id;

END GET_DISPLAY_PARENT_VERSION_ID;


FUNCTION IS_ACTIVE_TASK(p_element_version_id NUMBER,
                        p_object_type VARCHAR2)
RETURN VARCHAR2
IS

--  CURSOR c1 IS
--    select 1
--    from pa_percent_completes ppc,
--      pa_proj_element_versions pev
--    where pev.element_version_id = p_element_version_id
--    and pev.project_id = ppc.project_id
--    and pev.proj_element_id = ppc.task_id
--    and ppc.submitted_flag = 'Y'
--    and ppc.current_flag = 'Y'
--    and ppc.actual_start_date IS NOT NULL
--    and ppc.actual_finish_date IS NULL;
--  l_dummy NUMBER;
BEGIN
--  OPEN c1;
--  FETCH c1 into l_dummy;
--  IF c1%FOUND THEN
--    CLOSE c1;
--    return 'Y';
--  END IF;
--  CLOSE c1;
--  return 'N';
  return 'Y';
END IS_ACTIVE_TASK;

FUNCTION Get_DAYS_TO_START(p_element_version_id NUMBER,
                           p_object_type VARCHAR2)
RETURN NUMBER
IS
  CURSOR c1 IS
    select scheduled_start_date
      from pa_proj_elem_ver_schedule sch,
           pa_proj_element_versions ev
     where p_element_version_id = ev.element_version_id
       and ev.element_version_id = sch.element_version_id
       and ev.project_id = sch.project_id;
  l_date DATE;
BEGIN
  IF (p_object_type = 'PA_STRUCTURES') THEN
    RETURN to_number(NULL);
  END IF;
  OPEN c1;
  FETCH c1 into l_date;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    return to_number(NULL);
  END IF;
  CLOSE c1;
  return TRUNC(l_date) - TRUNC(SYSDATE);
END Get_DAYS_TO_START;

FUNCTION Get_DAYS_TO_FINISH(p_element_version_id NUMBER,
                            p_object_type VARCHAR2)
RETURN NUMBER
IS
  CURSOR c1 IS
    select scheduled_finish_date
      from pa_proj_elem_ver_schedule sch,
           pa_proj_element_versions ev
     where p_element_version_id = ev.element_version_id
       and ev.element_version_id = sch.element_version_id
       and ev.project_id = sch.project_id;
  l_date DATE;
BEGIN
  IF (p_object_type = 'PA_STRUCTURES') THEN
    RETURN to_number(NULL);
  END IF;
  OPEN c1;
  FETCH c1 into l_date;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    return to_number(NULL);
  END IF;
  CLOSE c1;
  return TRUNC(l_date) - TRUNC(sysdate);
END Get_DAYS_TO_FINISH;

FUNCTION GET_PREV_SCH_START_DATE(p_element_version_id NUMBER,
                                 p_parent_structure_version_id NUMBER)
RETURN DATE
IS
  CURSOR c1(c_project_id NUMBER, c_structure_version_id NUMBER) IS
    select sch.scheduled_start_date
      from pa_proj_elem_ver_schedule sch,
           pa_proj_element_versions pev,
           pa_proj_element_versions pev2
     where pev.project_id = c_project_id
       and pev.parent_structure_version_id = c_structure_version_id
       and pev.element_version_id = sch.element_version_id
       and pev.project_id = sch.project_id
       and pev.proj_element_id = pev2.proj_element_id
       and pev.project_id = pev2.project_id
       and pev2.element_version_id = p_element_version_id;

  CURSOR c2 IS
    select str.project_id, str.element_version_id
      from pa_proj_elem_ver_structure str,
           pa_proj_element_versions pev
     where pev.element_version_id = p_parent_structure_version_id
       and pev.project_id = str.project_id
       and pev.proj_element_id = str.proj_element_id
       and str.LATEST_EFF_PUBLISHED_FLAG = 'Y';
  l_project_id NUMBER;
  l_structure_version_id NUMBER;
  l_date DATE;
BEGIN
  OPEN c2;
  FETCH c2 into l_project_id, l_structure_version_id;
  IF c2%NOTFOUND THEN
--no published version
    CLOSE c2;
    return to_date(NULL);
  END IF;
  CLOSE c2;

  OPEN c1(l_project_id, l_structure_version_id);
  FETCH c1 into l_date;
  CLOSE c1;

  return l_date;

END GET_PREV_SCH_START_DATE;

FUNCTION GET_PREV_SCH_FINISH_DATE(p_element_version_id NUMBER,
                                  p_parent_structure_version_id NUMBER)
RETURN DATE
IS
  CURSOR c1(c_project_id NUMBER, c_structure_version_id NUMBER) IS
    select sch.scheduled_finish_date
      from pa_proj_elem_ver_schedule sch,
           pa_proj_element_versions pev,
           pa_proj_element_versions pev2
     where pev.project_id = c_project_id
       and pev.parent_structure_version_id = c_structure_version_id
       and pev.element_version_id = sch.element_version_id
       and pev.project_id = sch.project_id
       and pev.proj_element_id = pev2.proj_element_id
       and pev.project_id = pev2.project_id
       and pev2.element_version_id = p_element_version_id;

  CURSOR c2 IS
    select str.project_id, str.element_version_id
      from pa_proj_elem_ver_structure str,
           pa_proj_element_versions pev
     where pev.element_version_id = p_parent_structure_version_id
       and pev.project_id = str.project_id
       and pev.proj_element_id = str.proj_element_id
       and str.LATEST_EFF_PUBLISHED_FLAG = 'Y';
  l_project_id NUMBER;
  l_structure_version_id NUMBER;
  l_date DATE;
BEGIN
  OPEN c2;
  FETCH c2 into l_project_id, l_structure_version_id;
  IF c2%NOTFOUND THEN
--no published version
    CLOSE c2;
    return to_date(NULL);
  END IF;
  CLOSE c2;

  OPEN c1(l_project_id, l_structure_version_id);
  FETCH c1 into l_date;
  CLOSE c1;

  return l_date;

END GET_PREV_SCH_FINISH_DATE;

FUNCTION CHECK_IS_FINANCIAL_TASK(p_proj_element_id NUMBER)
RETURN VARCHAR2
IS
  cursor c1 IS
    SELECT 1
      FROM PA_TASKS
     WHERE task_id = p_proj_element_id;
  l_dummy  NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 into l_dummy;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    return 'N';
  ELSE
    CLOSE c1;
    return 'Y';
  END IF;
END CHECK_IS_FINANCIAL_TASK;

FUNCTION CONVERT_HR_TO_DAYS(p_hour NUMBER)
RETURN NUMBER
IS

    l_fte_day NUMBER := 0;

    cursor get_fte_days_csr
    IS
    SELECT fte_day
    FROM   pa_implementations;

BEGIN

--commented out for bug 3612309
--    OPEN get_fte_days_csr;
--    FETCH get_fte_days_csr INTO l_fte_day;
--    IF  get_fte_days_csr%NOTFOUND then
--        return 0;
--    end if;
--   CLOSE get_fte_days_csr;

--    if l_fte_day is null or l_fte_day = 0 then
--        l_fte_day := 8;
--    end if;

--dbms_output.put_line('fte_days  = '||l_fte_day);

--    return round(p_hour/l_fte_day,2);
  return p_hour;

END CONVERT_HR_TO_DAYS;


FUNCTION GET_FND_LOOKUP_MEANING(p_lookup_type VARCHAR2,
                                p_lookup_code VARCHAR2)
RETURN VARCHAR2
IS
/*
  cursor c1 is
    select meaning
      from fnd_lookups
     where lookup_type = p_lookup_type
       and lookup_code = p_lookup_code;
  l_dummy varchar2(80);
BEGIN
-- Bug Fix 5611871
IF p_lookup_code IS NULL THEN
  l_dummy := NULL;
  RETURN l_dummy;
END IF;
-- End of Bug Fix 5611871

  open c1;
  FETCH c1 into l_dummy;
  If c1%NOTFOUND THEN
    l_dummy := NULL;
  END IF;
  close c1;
  return l_dummy;
  */

-- Bug 6156686
    cursor c1 is
    select meaning
      from fnd_lookups
     where lookup_type = p_lookup_type
       and lookup_code = p_lookup_code;
  l_dummy varchar2(80);
  l_index varchar2(100);
BEGIN
  l_index := p_lookup_type || '*'||p_lookup_code;
  IF l_fndlkp_cache_tbl.EXISTS(l_index) THEN
        l_dummy :=   l_fndlkp_cache_tbl(l_index);
  ELSE
      open c1;
      FETCH c1 into l_dummy;
      If c1%NOTFOUND THEN
        l_dummy := NULL;
      END IF;
      close c1;
      l_fndlkp_cache_tbl(l_index) := l_dummy;

  END IF;
  return l_dummy;

END GET_FND_LOOKUP_MEANING;


FUNCTION GET_PA_LOOKUP_MEANING(p_lookup_type VARCHAR2,
                               p_lookup_code VARCHAR2)
RETURN VARCHAR2
IS
  cursor c1 is
    select meaning
      from pa_lookups
     where lookup_type = p_lookup_type
       and lookup_code = p_lookup_code;
  l_dummy varchar2(80);
  l_index varchar2(100);		-- Bug 6156686
BEGIN
-- Bug 6156686
  l_index := p_lookup_type || '*'||p_lookup_code;
  IF l_lookup_cache_tbl.EXISTS(l_index) THEN
        l_dummy :=   l_lookup_cache_tbl(l_index);
  ELSE
  open c1;
  FETCH c1 into l_dummy;
  If c1%NOTFOUND THEN
    l_dummy := NULL;
  END IF;
  close c1;
        l_lookup_cache_tbl(l_index) := l_dummy;

  END IF;

  return l_dummy;
END GET_PA_LOOKUP_MEANING;

-- API name                      : GET_DEFAULT_TASK_TYPE_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Default task type_id
--
-- Parameters
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_DEFAULT_TASK_TYPE_ID
    return NUMBER
  IS
  BEGIN
    return 1;
  END GET_DEFAULT_TASK_TYPE_ID;

  FUNCTION IS_TASK_TYPE_USED(p_task_type_id IN NUMBER)
    return VARCHAR2
  IS

/* Bug2680486 -- Performance changes -- Commented the following cursor query and restructured it. */
/*    cursor c1 IS
    select 'Y'
      from PA_PROJ_ELEMENTS
     where type_id = p_task_type_id;
*/

    cursor c1 IS
    select 'Y'
    from dual
    where exists (
      select 'xyz'
      from PA_PROJ_ELEMENTS
      where type_id = p_task_type_id
      AND project_id > -1
      AND object_type = 'PA_TASKS'
      );

    l_ret_val VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_ret_val;
    IF c1%NOTFOUND THEN
      l_ret_val := 'N';
    END IF;
    CLOSE c1;
    return l_ret_val;
  END IS_TASK_TYPE_USED;

-- API name                      : GET_LATEST_FIN_PUB_TASK_VER_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Task version id of the latest financial
--                                 published task
--
-- Parameters
--   p_project_id                IN NUMBER
--   p_task_id                   IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_LATEST_FIN_PUB_TASK_VER_ID(
    p_project_id    IN NUMBER
   ,p_task_id       IN NUMBER
  ) return NUMBER
  IS
    CURSOR c1(c_structure_version_id NUMBER) IS
      select ppev.element_version_id
        from pa_proj_element_versions ppev
       where parent_structure_version_id = c_structure_version_id
         and project_id = p_project_id
         and proj_element_id = p_task_id;
    l_structure_version_id NUMBER;
    l_task_version_id   NUMBER;
  BEGIN
    l_structure_version_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID(p_project_id);

    OPEN c1(l_structure_version_id);
    FETCH c1 into l_task_version_id;
    CLOSE c1;
    return l_task_version_id;
  END GET_LATEST_FIN_PUB_TASK_VER_ID;


-- API name                      : CHECK_MODIFY_OK_FOR_STATUS
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if this task can be modified with its
--                                 current status. Y can be modified, N cannot.
--
-- Parameters
--   p_project_id                IN NUMBER
--   p_task_id                   IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION CHECK_MODIFY_OK_FOR_STATUS(
    p_project_id    IN NUMBER
   ,p_task_id       IN NUMBER
  ) return VARCHAR2
  IS
--bug 2863836: modified cursor to refer to system status
    cursor c1 is
    select b.project_system_status_code
      from pa_proj_elements a, pa_project_statuses b
     where a.proj_element_id = p_task_id
       and a.status_code = b.project_status_code
       and b.status_type = 'TASK';
    l_dummy  pa_proj_elements.status_code%TYPE;
    l_retval VARCHAR2(1);
  BEGIN
    open c1;
    FETCH c1 into l_dummy;
    CLOSE c1;
    IF (l_dummy = 'ON_HOLD' OR l_dummy = 'CANCELLED') THEN
      return 'N';
    END IF;
    return 'Y';
  END CHECK_MODIFY_OK_FOR_STATUS;


-- API name                      : GET_DISPLAY_SEQUENCE
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : The display sequence for a given task.
--
-- Parameters
--   p_task_id                   IN NUMBER
--
--  History
--
--  16-OCT-02   XXLU             -Created
--
FUNCTION GET_DISPLAY_SEQUENCE (
   p_task_id       IN  NUMBER
) RETURN NUMBER
IS

  l_element_version_id  pa_proj_element_versions.element_version_id%TYPE;

  CURSOR c1(p_task_id IN NUMBER) IS
    SELECT project_id
    FROM pa_tasks
    WHERE task_id = p_task_id;

  v_c1 c1%ROWTYPE;

  CURSOR c2 (p_proj_element_id IN NUMBER) IS
    SELECT element_version_id
    FROM pa_proj_element_versions
    WHERE proj_element_id = p_proj_element_id;

  v_c2 c2%ROWTYPE;

  CURSOR c3 (p_element_version_id IN NUMBER) IS
    SELECT display_sequence
    FROM pa_proj_element_versions
    WHERE element_version_id = p_element_version_id;

  v_c3 c3%ROWTYPE;


BEGIN

  OPEN c1 (p_task_id);
  FETCH c1 INTO v_c1;
  CLOSE c1;

  l_element_version_id := PA_PROJ_ELEMENTS_UTILS.GET_LATEST_FIN_PUB_TASK_VER_ID
                          (p_project_id => v_c1.project_id,
                           p_task_id => p_task_id);

  IF l_element_version_id IS NULL THEN
    OPEN c2 (p_task_id);
    FETCH c2 INTO v_c2;
    CLOSE c2;

    l_element_version_id := v_c2.element_version_id;

  END IF;

  OPEN c3(l_element_version_id);
  FETCH c3 INTO v_c3;
  CLOSE c3;

  RETURN(v_c3.display_sequence);

END GET_DISPLAY_SEQUENCE;

  procedure Check_Del_all_task_Ver_Ok
  (
    p_project_id                        IN  NUMBER
   ,p_task_version_id                   IN  NUMBER
   ,p_parent_structure_ver_id           IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select object_Id_to1
        from pa_object_relationships
       where object_type_to = 'PA_TASKS'
         and relationship_type = 'S'
  start with object_id_from1 = p_task_version_id
         and object_type_from = 'PA_TASKS'
         and relationship_type = 'S'
  connect by prior object_id_to1 = object_id_from1
         and prior object_type_to = object_type_from
         and relationship_type = prior relationship_type;    --Bug 3792616
    l_task_ver_id    NUMBER;

    l_task_ver_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE() ; -- 4201927 for performance issue
  BEGIN

    PA_PROJ_ELEMENTS_UTILS.CHECK_DELETE_TASK_VER_OK(
                               p_project_id => p_project_id
                              ,p_task_version_id => p_task_version_id
                              ,p_parent_structure_ver_id => p_parent_structure_ver_id
                              ,x_return_status => x_return_status
                              ,x_error_message_code => x_error_message_code
                             );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
    END IF;


    -- 4201927 commented below code for performance issue
    /*
    OPEN c1;
    LOOP
      FETCH c1 into l_task_ver_id;
      EXIT WHEN c1%NOTFOUND;
      PA_PROJ_ELEMENTS_UTILS.Check_delete_task_ver_ok(
                               p_project_id => p_project_id
                              ,p_task_version_id => l_task_ver_id
                              ,p_parent_structure_ver_id => p_parent_structure_ver_id
                              ,x_return_status => x_return_status
                              ,x_error_message_code => x_error_message_code
                             );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        raise FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    CLOSE c1;
    */

    -- using bulk collect approach and then iterating through table

    OPEN  c1 ;
    FETCH c1 BULK COLLECT INTO l_task_ver_id_tbl;
    CLOSE  c1 ;

    IF  nvl(l_task_ver_id_tbl.LAST,0) > 0 THEN
        FOR i in reverse l_task_ver_id_tbl.FIRST..l_task_ver_id_tbl.LAST LOOP

          PA_PROJ_ELEMENTS_UTILS.Check_delete_task_ver_ok(
                                   p_project_id => p_project_id
                                  ,p_task_version_id => l_task_ver_id_tbl(i)
                                  ,p_parent_structure_ver_id => p_parent_structure_ver_id
                                  ,x_return_status => x_return_status
                                  ,x_error_message_code => x_error_message_code
                                 );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            raise FND_API.G_EXC_ERROR;
          END IF;

        END LOOP;
    END IF;

    -- 4201927 end

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- 4537865 NOT RESETTING x_error_message_code AS IT WILL reach this point only after x_error_message_code is set
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865
      x_error_message_code := SQLCODE ;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                              p_procedure_name => 'Check_Del_all_task_Ver_Ok
');
      RAISE;
  END Check_Del_all_task_Ver_Ok;

  procedure Check_create_subtask_ok
  ( p_parent_task_ver_id                IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 -- 4537865
   ,x_error_message_code                OUT NOCOPY VARCHAR2 -- 4537865
  )
  IS
    CURSOR get_status IS
      select ppe.project_id, ppe.proj_element_id
        from pa_project_statuses pps,
             pa_proj_elements ppe,
             pa_proj_element_versions ppev
       where ppev.element_version_id = p_parent_task_ver_id
         and ppe.project_id = ppev.project_id
         and ppe.proj_element_id = ppev.proj_element_id
         and ppe.status_code = pps.project_status_code
         and pps.project_system_status_code IN ('ON_HOLD', 'CANCELLED')
         and pps.status_type = 'TASK';
    l_project_id       NUMBER;
    l_proj_element_id  NUMBER;

    CURSOR get_task_info IS
      select ppev.project_id, ppev.proj_element_id
        from pa_proj_element_versions ppev
       where ppev.element_version_id = p_parent_task_ver_id;

    CURSOR get_schedule_info IS
      select 1
        from pa_proj_elem_ver_schedule ppvsch,
             pa_proj_element_versions ppev
       where ppev.element_version_id = p_parent_task_ver_id
         and ppev.project_id = ppvsch.project_id
         and ppev.proj_element_id = ppvsch.proj_element_id
         and ppev.element_version_id = ppvsch.element_version_id
         and ( ppvsch.wq_planned_quantity IS NOT NULL AND ppvsch.wq_planned_quantity <> 0 );
    l_dummy            NUMBER;

    l_err_code         NUMBER:= 0;
    l_err_stack        VARCHAR2(630);
    l_err_stage        VARCHAR2(80);

    l_return_status    VARCHAR2(1);
    l_msg_data         VARCHAR2(2000);
    l_msg_count        NUMBER;
  BEGIN
    OPEN get_status;
    FETCH get_status into l_project_id, l_proj_element_id;
    IF get_status%NOTFOUND THEN
      x_return_status := 'Y';
    ELSE
      x_return_status := 'N';
      x_error_message_code := 'PA_PS_ONHOLD_CANCEL_TK_ERR';
      CLOSE get_status;
      return;
    END IF;
    CLOSE get_status;

    OPEN get_task_info;
    FETCH get_task_info into l_project_id, l_proj_element_id;
    CLOSE get_task_info;

    --hsiu: bug 2674107
    --if workplan, check if ok to create subtask.
    OPEN get_schedule_info;
    FETCH get_schedule_info into l_dummy;
    IF (get_schedule_info%FOUND) THEN
        x_return_status := 'N';
        x_error_message_code := 'PA_PS_PARENT_TK_PWQ_ERR';
        return;
    END IF;
    CLOSE get_schedule_info;

    -- Begin fix for Bug # 4266540.

    l_return_status := pa_relationship_utils.check_task_has_sub_proj(l_project_id
							          , l_proj_element_id
								  , p_parent_task_ver_id);

    if (l_return_status = 'Y') then

    	x_return_status := 'N';
       	x_error_message_code := 'PA_PS_TASK_HAS_SUB_PROJ';
       	return;

    end if;

    l_return_status := null;

    -- End fix for Bug # 4266540.

    --if financial, check if ok to create subtask.
    --Bug 5988335 Adding condition for partial share project to skip financial validation
    --when a new subtask is  getting created in workplan.
    If (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_proj_element_id) = 'Y') AND
       (PA_PROJ_TASK_STRUC_PUB.GET_SHARE_TYPE(l_project_id) <> 'SHARE_PARTIAL') --Bug 5988335
    THEN
      PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(x_task_id => l_proj_element_id,
          x_err_code => l_err_code,
          x_err_stack => l_err_stack,
          x_err_stage => l_err_stage
          );
      IF (l_err_code <> 0) THEN
        x_return_status := 'N';
        x_error_message_code := substrb(l_err_stage,1,30); -- 4537865 changed substr to substrb
        return;
      ELSE
        x_return_status := 'Y';
        return;
      END IF;
    ELSE
        --bug 3055708 (for financial or shared str it will be taken
        --care in PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK)
        PA_TASK_PUB1.Check_Task_Has_Association(
                   p_task_id                => l_proj_element_id
                  ,x_return_status          => l_return_status
                  ,x_msg_count              => l_msg_count
                  ,x_msg_data               => l_msg_data

               );

         IF (l_return_status <> 'S') Then
             x_return_status := 'N';
             x_error_message_code := l_msg_data;
             return;
         END IF;
        --end bug 3055708

        --bug 3305199: cannot create subtask if dep exists in parent when
        --option for no dep in summary task is Y
        IF (PA_PROJECT_STRUCTURE_UTILS.check_dep_on_summary_tk_ok(l_project_id) = 'N') THEN
          IF ('Y' = PA_RELATIONSHIP_UTILS.CHECK_DEP_EXISTS(p_parent_task_ver_id)) THEN
           x_return_status := 'N';
           x_error_message_code := 'PA_DEP_ON_SUMM_TSK';
            return;
          END IF;
        END IF;
    END IF;
    --bug 3947726
    --do not allow sub-tasks creation if the lowest level task has progress.
    --This is also applicable for shared case if the task has only ETC but not actual. If actual is there then it means it will be stopped in expenditure items validation.
    IF pa_proj_task_struc_pub.wp_str_exists(l_project_id) = 'Y'
       AND pa_task_assignment_utils.get_task_level_record( l_project_id, p_parent_task_ver_id ) IS NOT NULL
       AND PA_PROGRESS_UTILS.check_object_has_prog(
                p_project_id                           => l_project_id
               ,p_proj_element_id                      => l_proj_element_id
               ,p_object_id                            => l_proj_element_id
               ,p_object_type                          => 'PA_TASKS'
               ,p_structure_type                       => 'WORKPLAN'
              )       = 'Y'
	AND PA_PROGRESS_UTILS.check_ta_has_prog(
		p_project_id                           => l_project_id
	       ,p_proj_element_id                      => l_proj_element_id
	       ,p_element_ver_id                       => p_parent_task_ver_id
	      )       = 'Y'  --Added for 7015986
    THEN
           x_return_status := 'N';
           x_error_message_code := 'PA_PS_TASK_HAS_PROG_ADD';
            return;
    END IF;
    --end bug 3947726
  -- 4537865
  EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'N';
		x_error_message_code := SQLCODE ;
		fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                              p_procedure_name => 'Check_create_subtask_ok',
                              p_error_text => SUBSTRB(SQLERRM,1,240));
		RAISE ;
  END Check_create_subtask_ok;


  FUNCTION Check_task_stus_action_allowed
                          (p_task_status_code IN VARCHAR2,
                           p_action_code      IN VARCHAR2 ) return
  VARCHAR2
  IS
    CURSOR l_taskstus_csr IS
    SELECT enabled_flag, project_system_status_code
    FROM pa_project_status_controls
    WHERE project_status_code = p_task_status_code
    AND   action_code         = p_action_code;

    l_action_allowed  VARCHAR2(1) := 'N';

    l_proj_sys_status_code  VARCHAR2(30);
  BEGIN
    OPEN l_taskstus_csr;
    FETCH l_taskstus_csr INTO l_action_allowed, l_proj_sys_status_code;
    IF l_taskstus_csr%NOTFOUND THEN
      CLOSE l_taskstus_csr;
      RETURN 'N';
    END IF;
    CLOSE l_taskstus_csr;

    RETURN (NVL(l_action_allowed,'N'));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END Check_task_stus_action_allowed;

-- hyau new apis for lifecycle changes

-- API name                      : CHECK_ELEMENT_HAS_PHASE
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : 'Y' if the element has a phase associated with it, else returns 'N'.
--
-- Parameters
--   p_proj_element_id            IN NUMBER
--
--  History
--
--  30-OCT-02   hyau             -Created
--
FUNCTION CHECK_ELEMENT_HAS_PHASE (
   p_proj_element_id       IN  NUMBER) RETURN

  VARCHAR2
  IS
    CURSOR l_element_has_phase_csr IS
    SELECT 'Y'
    FROM   pa_proj_elements
    WHERE  proj_element_id = p_proj_element_id
    AND    phase_version_id is not null;

    l_has_phase  VARCHAR2(1) := 'N';

  BEGIN
    OPEN l_element_has_phase_csr;
    FETCH l_element_has_phase_csr INTO l_has_phase;
    IF l_element_has_phase_csr%NOTFOUND THEN
      CLOSE l_element_has_phase_csr;
      RETURN 'N';
    END IF;
    CLOSE l_element_has_phase_csr;

    RETURN (NVL(l_has_phase,'N'));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END CHECK_ELEMENT_HAS_PHASE;


-- API name                      : IS_TOP_TASK_ACROSS_ALL_VER
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : 'Y' if the task is a top task across all versions, else returns 'N'.
--
-- Parameters
--   p_proj_element_id            IN NUMBER
--
--  History
--
--  30-OCT-02   hyau             -Created
--
FUNCTION IS_TOP_TASK_ACROSS_ALL_VER(
   p_proj_element_id       IN  NUMBER) RETURN

  VARCHAR2
  IS
    CURSOR l_exist_non_top_task_csr IS
    select 'N'
    from   pa_proj_elements ppe,
           pa_proj_element_versions ppev
    where  ppe.proj_element_id = p_proj_element_id
    and    ppe.proj_element_id = ppev.proj_element_id
    and    nvl(ppev.wbs_level, 0) <> 1;

    l_is_top_task  VARCHAR2(1) := 'N';

  BEGIN
    OPEN l_exist_non_top_task_csr;
    FETCH l_exist_non_top_task_csr INTO l_is_top_task;
    IF l_exist_non_top_task_csr%NOTFOUND THEN
      CLOSE l_exist_non_top_task_csr;
      RETURN 'Y';
    END IF;
    CLOSE l_exist_non_top_task_csr;

    RETURN (NVL(l_is_top_task,'N'));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END IS_TOP_TASK_ACROSS_ALL_VER;

-- API name                      : CHECK_PHASE_IN_USE
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : 'Y' if the phase is already used by another task in the structure, else returns 'N'.
--
-- Parameters
--   p_task_id           NUMBER
--   phase_version_id    NUMBER
--
--  History
--
--  30-OCT-02   hyau             -Created
--
FUNCTION CHECK_PHASE_IN_USE(
   p_task_id       IN  NUMBER
  ,p_phase_version_id  IN NUMBER) RETURN

  VARCHAR2
  IS

  /* Bug 2680486 -- Performance changes -- Added join of project_id in the following cursor*/
    CURSOR l_phase_in_use_csr IS
    select 'Y'
    from   pa_proj_elements ppe,
           pa_proj_elements ppe2
    where  ppe.proj_element_id = p_task_id
    and    ppe.parent_structure_id = ppe2.parent_structure_id
    and    ppe2.phase_version_id = p_phase_version_id
    and    ppe2.proj_element_id <> p_task_id
    and    ppe2.project_id = ppe.project_id;

    l_phase_in_use  VARCHAR2(1) := 'Y';

  BEGIN
    OPEN l_phase_in_use_csr;
    FETCH l_phase_in_use_csr INTO l_phase_in_use;
    IF l_phase_in_use_csr%NOTFOUND THEN
      CLOSE l_phase_in_use_csr;
      RETURN 'N';
    END IF;
    CLOSE l_phase_in_use_csr;

    RETURN (NVL(l_phase_in_use,'Y'));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
  END CHECK_PHASE_IN_USE;


-- end hyau new apis for lifecycle changes

  PROCEDURE Check_Fin_Task_Published(p_project_id IN NUMBER,
                                     p_task_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2, -- 4537865
                                     x_error_message_code OUT NOCOPY VARCHAR2) -- 4537865
  IS
    CURSOR c1 is
    select 1 from
      pa_proj_elements a,
      pa_proj_element_versions b,
      pa_proj_elem_ver_structure c
    where a.proj_element_id = p_task_id
      and a.project_id = p_project_id
      and a.project_id = b.project_id
      and a.proj_element_id = b.proj_element_id
      and b.project_Id = c.project_id
      and b.parent_structure_version_id = c.element_version_id
      and c.status_code = 'STRUCTURE_PUBLISHED';

    CURSOR c2 IS
    select 1 from
      pa_tasks a
    where a.task_id = p_task_id;

    l_dummy NUMBER;

  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      --check if task has financial component
      OPEN c2;
      FETCH c2 into l_dummy;
      IF c2%NOTFOUND THEN
        x_return_status := 'N';
        x_error_message_code := 'PA_PS_TSK_NOT_PUB_ERR';
      ELSE
        x_return_status := 'Y';
      END IF;
      CLOSE c2;
    ELSE
      x_return_status := 'Y';
    END IF;
    CLOSE c1;

  -- 4537865
  EXCEPTION
	WHEN OTHERS THEN
		x_return_status := 'N' ;
		x_error_message_code := SQLCODE ;

		-- not included add_exc_msg call because caller of this API doesnt expect it.
		RAISE ;
  END Check_Fin_Task_Published;

  PROCEDURE check_move_task_ok
  (
    p_task_ver_id         IN  NUMBER
   ,x_return_status       OUT NOCOPY VARCHAR2   -- 4537865
   ,x_error_message_code  OUT NOCOPY VARCHAR2   -- 4537865
  )
  IS
    CURSOR get_status IS
      select '1'
        from pa_project_statuses pps,
             pa_proj_elements ppe,
             pa_proj_element_versions ppev
       where ppev.element_version_id = p_task_ver_id
         and ppe.project_id = ppev.project_id
         and ppe.proj_element_id = ppev.proj_element_id
         and ppe.status_code = pps.project_status_code
         and pps.project_system_status_code IN ('ON_HOLD', 'CANCELLED', 'COMPLETED')
         and pps.status_type = 'TASK';
    l_dummy varchar2(1);
  BEGIN
    OPEN get_status;
    FETCH get_status into l_dummy;
    IF get_status%NOTFOUND THEN
      x_return_status := 'Y';
    ELSE
      x_return_status := 'N';
      x_error_message_code := 'PA_PS_MOVE_TK_STAT_ERR';
    END IF;
    CLOSE get_status;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_return_status := 'N' ;
                x_error_message_code := SQLCODE ;
		fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_ELEMENTS_UTILS',
                              p_procedure_name => 'check_move_task_ok',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
                RAISE ;
  END check_move_task_ok;


-- API name                      :
-- Type                          : PROCEDURE
-- Pre-reqs                      : N/A
-- Return Value                  : Sucess, Error, or Unexpected error
--
-- Parameters
--   p_task_id            IN   NUMBER
--   p_task_version_id    IN   NUMBER
--   p_new_task_status    IN   VARCHAR2
--   x_return_status      OUT  VARCHAR2
--   x_error_message_code OUT  VARCHAR2
--
--  History
--
--  30-OCT-02   hyau             -Created
--
  PROCEDURE Check_chg_stat_cancel_ok
  (
    p_task_id             IN  NUMBER
   ,p_task_version_id     IN  NUMBER
   ,p_new_task_status     IN  VARCHAR2
   ,x_return_status       OUT NOCOPY VARCHAR2   -- 4537865
   ,x_error_message_code  OUT NOCOPY VARCHAR2   -- 4537865
  )
  IS
    CURSOR c1 IS
      select b.project_id, b.proj_element_id
      from pa_proj_element_versions a,
           pa_proj_elem_ver_structure b
      where a.element_version_id = p_task_version_id
        and a.parent_structure_version_id = b.element_version_id
        and a.project_id = b.project_id;
    l_project_id          NUMBER;
    l_structure_id        NUMBER;
    l_xtra_task_id        NUMBER;
    l_versioned           VARCHAR2(1);

    CURSOR c2(c_project_id NUMBER, c_structure_id NUMBER) IS
      select distinct ppe.proj_element_id
        from pa_proj_element_versions ppe
       where ppe.element_version_id IN (
               select object_id_to1
                 from pa_object_relationships
                where relationship_type = 'S'
           start with object_id_from1 IN (
                         select a.element_version_id
                           from pa_proj_element_versions a,
                                pa_proj_elem_ver_structure b
                          where b.project_id = c_project_id
                            and b.proj_element_id = c_structure_id
                            and b.status_code <> 'STRUCTURE_PUBLISHED'
                            and b.element_version_id = a.parent_structure_version_id
                            and a.proj_element_id = p_task_id)
                  and relationship_type = 'S'
           connect by object_id_from1 = prior object_id_to1
                  and object_type_from = prior object_type_to
                  and relationship_type = prior relationship_type)
      minus
      select ppe.proj_element_id
        from pa_proj_element_versions ppe
       where ppe.element_version_id IN (
               select object_id_to1
                 from pa_object_relationships
                where relationship_type = 'S'
           start with object_id_from1 = p_task_version_id
                  and object_type_from = 'PA_TASKS'
                  and relationship_type = 'S'
           connect by object_id_from1 = prior object_id_to1
                  and object_type_from = prior object_type_to
                  and relationship_type = prior relationship_type);

    CURSOR c3(c_project_id NUMBER, c_structure_id NUMBER, c_xtra_task_id NUMBER) IS
      select ppev.element_version_id, ppev.TASK_UNPUB_VER_STATUS_CODE
        from pa_proj_element_Versions ppev,
             pa_proj_elem_ver_structure ppevs
       where ppev.proj_element_id = c_xtra_task_id
         and ppev.project_id = c_project_id
         and ppev.parent_structure_version_id = ppevs.element_version_id
         and ppevs.project_id = c_project_id
         and ppevs.proj_element_id = c_structure_id
         and ppevs.status_code <> 'STRUCTURE_PUBLISHED';
    l_xtra_task_ver_id    NUMBER;
    l_task_ver_status     VARCHAR2(30);

  BEGIN
    OPEN c1;
    FETCH c1 into l_project_id, l_structure_id;
    CLOSE c1;

    --Check if versioning is enabled
    l_versioned := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                                                  l_project_id);

    IF (l_versioned = 'Y') THEN
      OPEN c2(l_project_id, l_structure_id);
      LOOP
        --get the task id of all tasks that are in the working version but not in
        -- the latest published version.
        FETCH c2 into l_xtra_task_id;
        EXIT WHEN c2%NOTFOUND;
        OPEN c3(l_project_id, l_structure_id, l_xtra_task_id);
        LOOP
          --get all the task version status of unpublished tasks
          FETCH c3 INTO l_xtra_task_ver_id, l_task_ver_status;
          EXIT WHEN c3%NOTFOUND;
          IF (l_task_ver_status = 'PUBLISHED') THEN
            x_error_message_code:= 'PA_PS_TK_STAT_CNL_ERR';
            raise FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
        CLOSE c3;
      END LOOP;
      CLOSE c2;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- 4537865
      -- Not resetting x_error_message_code as at this point it would have been already populated.
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                              p_procedure_name => 'Check_chg_stat_cancel_ok');

      -- 4537865
      x_error_message_code := SQLCODE ;
      RAISE ;
  END Check_chg_stat_cancel_ok;

FUNCTION get_element_name(p_proj_element_id IN NUMBER) RETURN VARCHAR2
IS
  l_ret VARCHAR2(240);
BEGIN
  IF p_proj_element_id IS NULL OR p_proj_element_id<0 THEN
    RETURN NULL;
  END IF;

  SELECT name
  INTO l_ret
  FROM pa_proj_elements
  WHERE proj_element_id = p_proj_element_id;

  RETURN l_ret;
EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                            p_procedure_name => 'get_element_name');
    RAISE;
END get_element_name;

FUNCTION get_element_number(p_proj_element_id IN NUMBER) RETURN VARCHAR2
IS
  l_ret VARCHAR2(100);
BEGIN
  IF p_proj_element_id IS NULL OR p_proj_element_id<0 THEN
    RETURN NULL;
  END IF;

  SELECT element_number
  INTO l_ret
  FROM pa_proj_elements
  WHERE proj_element_id = p_proj_element_id;

  RETURN l_ret;
EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                            p_procedure_name => 'get_element_number');
    RAISE;
END get_element_number;

FUNCTION get_element_name_number(p_proj_element_id IN NUMBER) RETURN VARCHAR2
IS
  l_ret VARCHAR2(1000);
BEGIN
  IF p_proj_element_id IS NULL OR p_proj_element_id<0 THEN
    RETURN NULL;
  END IF;

  SELECT name||'('||element_number||')'
  INTO l_ret
  FROM pa_proj_elements
  WHERE proj_element_id = p_proj_element_id;

  RETURN l_ret;
EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name => 'PA_PROJ_ELEMENTS_UTILS',
                            p_procedure_name => 'get_element_name_number');
    RAISE;
END get_element_name_number;

function check_child_element_exist(p_element_version_id NUMBER) RETURN VARCHAR2
IS
  l_dummy number;

-- Bug 6156686
  cursor child_exist IS
  select null
  from dual where exists
  (select null from pa_object_relationships
  where object_id_from1 = p_element_version_id
    and relationship_type = 'S');
BEGIN

  OPEN child_exist;
  FETCH child_exist into l_dummy;
  IF child_exist%NOTFOUND then
    --Cannot find child. It is lowest task
    CLOSE child_exist;
    return 'N';
  ELSE
    --Child found. Not lowest task
    CLOSE child_exist;
    return 'Y';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    return (SQLCODE);
END check_child_element_exist;


FUNCTION get_task_status_sys_code(p_task_status_code VARCHAR2) RETURN VARCHAR2
IS
  l_task_stat_sys_code VARCHAR2(30);
BEGIN
  select project_system_status_code into l_task_stat_sys_code
  from pa_project_statuses
  where p_task_status_code = project_status_code
  and status_type = 'TASK';

  return l_task_stat_sys_code;
EXCEPTION
  WHEN OTHERS THEN
    return NULL;
END get_task_status_sys_code;

-- Returns the element_version_id of the next/previous task, given the project id, parent structure
-- version id, and the display sequence of the current task. Pass value "NEXT" and "PREVIOUS" for
-- p_previous_or_next parameter to indicate whether to get the next or the previous task. Returns
-- -1 if there are no next/previous task.
FUNCTION get_next_prev_task_id(
    p_project_id                IN  NUMBER
   ,p_structure_version_id      IN  NUMBER
   ,p_display_seq_id            IN  NUMBER
   ,p_previous_or_next          IN VARCHAR2) RETURN NUMBER
IS
  l_element_version_Id NUMBER;

  cursor c_previous_task_id( c_project_id NUMBER, c_struct_version_id NUMBER, c_display_seq NUMBER) IS
    select element_version_id
    from pa_proj_element_versions
    where project_id = c_project_id
    and parent_structure_version_id = c_struct_version_id
    and display_sequence = (
      select max(display_sequence)
      from pa_proj_element_versions
      where project_id = c_project_id
      and parent_structure_version_id = c_struct_version_id
      and display_sequence < c_display_seq
    );

  cursor c_next_task_id( c_project_id NUMBER, c_struct_version_id NUMBER, c_display_seq NUMBER) IS
    select element_version_id
    from pa_proj_element_versions
    where project_id = c_project_id
    and parent_structure_version_id = c_struct_version_id
    and display_sequence = (
      select min(display_sequence)
      from pa_proj_element_versions
      where project_id = c_project_id
      and parent_structure_version_id = c_struct_version_id
      and display_sequence > c_display_seq
    );

BEGIN

  IF p_previous_or_next IS NOT NULL and p_previous_or_next = 'PREVIOUS' then
    OPEN c_previous_task_id(p_project_id, p_structure_version_id, p_display_seq_id);
    FETCH c_previous_task_id into l_element_version_Id;
    IF c_previous_task_id%NOTFOUND then
      CLOSE c_previous_task_id;
      return -1;
    ELSE
      CLOSE c_previous_task_id;
      return l_element_version_Id;
    END IF;
  ELSIF  p_previous_or_next IS NOT NULL and p_previous_or_next = 'NEXT' then
    OPEN c_next_task_id(p_project_id, p_structure_version_id, p_display_seq_id);
    FETCH c_next_task_id into l_element_version_Id;
    IF c_next_task_id%NOTFOUND then
      CLOSE c_next_task_id;
      return -1;
    ELSE
      CLOSE c_next_task_id;
      return l_element_version_Id;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    return -1;
END get_next_prev_task_id;

/*==================================================================
   This api obtains the structure version id to which task versions
   should be created and added to. This API is to be called only from
   the AMG context. Included the api for Post FP K one off. Bug 2931183.
   This api also returns the task unpublished version status code.
   This value is used when we create a task version.
 ==================================================================*/

PROCEDURE GET_STRUCTURE_INFO
   (  p_project_id                IN   pa_projects_all.project_id%TYPE
     ,p_structure_type            IN   pa_structure_types.structure_type_class_code%TYPE
     ,p_structure_id              IN   pa_proj_elements.proj_element_id%TYPE
     ,p_is_wp_separate_from_fn    IN   VARCHAR2
     ,p_is_wp_versioning_enabled  IN   VARCHAR2
     ,x_structure_version_id      OUT NOCOPY pa_proj_element_versions.element_version_id%TYPE -- 4537865
     ,x_task_unpub_ver_status_code OUT NOCOPY  pa_proj_element_versions.task_unpub_ver_status_code%TYPE -- 4537865
     ,x_return_status             OUT  NOCOPY VARCHAR2 -- 4537865
     ,x_msg_count                 OUT  NOCOPY NUMBER -- 4537865
     ,x_msg_data                  OUT  NOCOPY VARCHAR2) -- 4537865
AS


-- Cursors used in this API.
   CURSOR cur_struc_ver_wp(c_project_id number,c_structure_type varchar2,c_status_code varchar2)
   IS
     SELECT c.element_version_id
       FROM pa_proj_element_versions c,
                    pa_structure_types a,
                    pa_proj_structure_types b
                   ,pa_proj_elem_ver_structure d
      WHERE c.project_id = c_project_id
        AND a.structure_type_id = b.structure_type_id
        AND b.proj_element_id = c.proj_element_id
        AND a.structure_type = c_structure_type
           AND d.project_id = c.project_id
        AND d.element_version_id = c.element_version_id
        AND d.status_code = c_status_code;

   CURSOR cur_struc_ver_fin(c_project_id number,c_structure_type varchar2)
   IS
     SELECT c.element_version_id
       FROM pa_proj_element_versions c,
                    pa_structure_types a,
                    pa_proj_structure_types b,
                    pa_proj_elem_ver_structure d
      WHERE c.project_id = c_project_id
        AND a.structure_type_id = b.structure_type_id
        AND b.proj_element_id = c.proj_element_id
        AND a.structure_type = c_structure_type
           AND d.project_id = c.project_id
        AND d.element_version_id = c.element_version_id
        AND d.status_code = 'STRUCTURE_PUBLISHED'
        AND d.latest_eff_published_flag = 'Y';
-- End cursors used in this API.

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                           VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

BEGIN
     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Entering GET_STRUCTURE_INFO';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level2);
     END IF;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN --For bug 4252182

           pa_debug.set_curr_function( p_function   => 'GET_STRUCTURE_INFO',
                                 p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN

          pa_debug.g_err_stage:= 'Input parameter List :';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

          pa_debug.g_err_stage:= 'p_project_id : ' || p_project_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);


          pa_debug.g_err_stage:= 'p_structure_type : ' || p_structure_type;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

          pa_debug.g_err_stage:= 'p_structure_id : ' || p_structure_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

          pa_debug.g_err_stage:= 'p_is_wp_separate_from_fn :' || p_is_wp_separate_from_fn;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);

          pa_debug.g_err_stage:= 'p_is_wp_versioning_enabled :' || p_is_wp_versioning_enabled;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level3);
     END IF;


     IF  (p_project_id IS NULL) OR
         (p_structure_type IS NULL) OR
         (p_structure_id IS NULL) OR
         (p_is_wp_separate_from_fn IS NULL) OR
         (p_is_wp_versioning_enabled IS NULL)
     THEN
          PA_UTILS.ADD_MESSAGE
                (p_app_short_name => 'PA',
                  p_msg_name     => 'PA_INV_PARAM_PASSED');     -- Bug 2955589. Changed the message name to
          RAISE Invalid_Arg_Exc_WP;                             -- have a generic message.

     END IF;

     /*
          If workplan context, if versioning is enabled get the working version. else
          get the published version. In financial context get working version. If
          working version could not be found, get the published version.
     */
     IF p_structure_type = 'WORKPLAN' THEN
          IF p_is_wp_separate_from_fn = 'Y' AND p_is_wp_versioning_enabled = 'Y' THEN
               x_structure_version_id :=
                    PA_PROJECT_STRUCTURE_UTILS.get_last_updated_working_ver(p_structure_id);
               x_task_unpub_ver_status_code := 'WORKING';
          END IF;

          IF x_structure_version_id is null THEN
               open  cur_struc_ver_wp(p_project_id,'WORKPLAN','STRUCTURE_PUBLISHED');
               fetch cur_struc_ver_wp into x_structure_version_id;
               close cur_struc_ver_wp;
               x_task_unpub_ver_status_code := 'PUBLISHED';
          END IF;
     ELSE -- structure type is financial
          open  cur_struc_ver_wp(p_project_id,'FINANCIAL','STRUCTURE_WORKING');
          fetch cur_struc_ver_wp into x_structure_version_id;
          close cur_struc_ver_wp;
          x_task_unpub_ver_status_code := 'WORKING';

          IF x_structure_version_id is null THEN
               open  cur_struc_ver_fin(p_project_id,'FINANCIAL');
               fetch cur_struc_ver_fin into x_structure_version_id;
               close cur_struc_ver_fin;
               x_task_unpub_ver_status_code := 'PUBLISHED';
          END IF;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Obtained structure version id : '||x_structure_version_id;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.g_err_stage:= 'Task Unpublished version status code : '||x_task_unpub_ver_status_code;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level3);
          pa_debug.g_err_stage:= 'Exiting GET_STRUCTURE_INFO';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   l_debug_level2);
     END IF;

     IF l_debug_mode = 'Y' THEN --For bug 4252182
          pa_debug.reset_curr_function;
     End IF;
EXCEPTION

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF cur_struc_ver_wp%ISOPEN THEN
          CLOSE cur_struc_ver_wp;
     END IF;

-- 4537865 : Start
     x_task_unpub_ver_status_code := NULL ;
     x_structure_version_id := NULL ;
-- 4537865 : End

     IF cur_struc_ver_fin%ISOPEN THEN
          CLOSE cur_struc_ver_fin;
     END IF;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
          PA_INTERFACE_UTILS_PUB.get_messages
              (p_encoded        => FND_API.G_TRUE
              ,p_msg_index      => 1
              ,p_msg_count      => l_msg_count
              ,p_msg_data       => l_msg_data
              ,p_data           => l_data
              ,p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN --For bug 4252182
          pa_debug.reset_curr_function;
     End IF;
     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF cur_struc_ver_wp%ISOPEN THEN
          CLOSE cur_struc_ver_wp;
     END IF;

     IF cur_struc_ver_fin%ISOPEN THEN
          CLOSE cur_struc_ver_fin;
     END IF;

-- 4537865 : Start
     x_task_unpub_ver_status_code := NULL ;
     x_structure_version_id := NULL;
-- 4537865 : End

     FND_MSG_PUB.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_ELEMENTS_UTILS'
                    ,p_procedure_name  => 'GET_STRUCTURE_INFO'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                              l_debug_level5);
          pa_debug.reset_curr_function;
     END IF;
     RAISE;
END GET_STRUCTURE_INFO;

--Begin add rtarway FP.M Develepment
-- Procedure            : CHECK_TASK_HAS_TRANSACTION
-- Type                 : Public Procedure
-- Purpose              : This procedure will check whether the task has transaction or not.This API will be
--                      : called from Set_Financial_task_API.
-- Note                 : Check whether it is a financial task or workplan task.
--                      : Fetch the parent_structure_version_id for the passed proj_element_Id from
--                      : PA_PROJ_ELEMENT_VERSIONS and pass to API PA_PROJ_ELEMENTS_UTILS.structure_type

-- Assumptions          : Only called for Financial task

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_task_id                    NUMBER   Yes             This indicates the task ID for which the transaction needs to be checked.


PROCEDURE CHECK_TASK_HAS_TRANSACTION
   (
       p_api_version           IN   NUMBER    := 1.0
     , p_calling_module        IN   VARCHAR2  := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2  := 'N'
     , p_task_id               IN   NUMBER
     , p_project_id            IN   NUMBER  -- Added for Performance fix 4903460
     , x_return_status         OUT NOCOPY  VARCHAR2 -- 4537865
     , x_msg_count             OUT NOCOPY NUMBER -- 4537865
     , x_msg_data              OUT NOCOPY VARCHAR2 -- 4537865
     , x_error_msg_code        OUT NOCOPY VARCHAR2 -- 4537865
     , x_error_code            OUT NOCOPY NUMBER -- 4537865
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_prnt_str_ver_id               NUMBER;
l_return_val                    VARCHAR2(1);
l_used_in_OTL                   BOOLEAN;
l_status_code                   NUMBER;
l_return_status                 VARCHAR2(1);
Is_IEX_Installed                BOOLEAN;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

 --This cursor will select the parent structure version id for the passed proj_elem_id, here it is used for task
 --CURSOR c_get_parent_str_ver_id (task_id NUMBER)
 --IS
 --SELECT PARENT_STRUCTURE_VERSION_ID
 --FROM PA_PROJ_ELEMENT_VERSIONS
 --WHERE PROJ_ELEMENT_ID = task_id;

--Bug 3735089
l_user_id               NUMBER;
l_login_id              NUMBER;

BEGIN
        x_msg_count     := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        --Bug 3735089 - instead of fnd_profile.value use fnd_profile.value_specific
        --l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
        l_user_id := fnd_global.user_id;
        l_login_id := fnd_global.login_id;
        l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

        IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   =>'CHECK_TASK_HAS_TRANSACTION' , p_debug_mode => l_debug_mode );
        END IF;

        IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name , Pa_Debug.g_err_stage , l_debug_level3);
          Pa_Debug.WRITE(g_module_name , 'p_task_id'||':'||p_task_id , l_debug_level3);
        END IF;


        IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : Validating Input Paramater';
          Pa_Debug.WRITE(g_module_name , Pa_Debug.g_err_stage , l_debug_level3);
        END IF;

        -- Validating for Input parameter
        IF ( p_task_id IS NOT NULL ) THEN

             --Commented to be reviewed once more with set financial task
             --IF l_debug_mode = 'Y' THEN
             --   Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : Checking for financial type';
             --   Pa_Debug.WRITE ( g_module_name , Pa_Debug.g_err_stage , l_debug_level3 );
             --END IF;

             --Select the parent structure version id for the passed task id
             --OPEN  c_get_parent_str_ver_id ( p_task_id );
             --FETCH c_get_parent_str_ver_id INTO l_prnt_str_ver_id;
             --CLOSE c_get_parent_str_ver_id;

             --check if the structure type is financial
             --IF (
             --     PA_PROJ_ELEMENTS_UTILS.structure_type
             --     (     p_structure_version_id => l_prnt_str_ver_id
             --         , p_task_version_id => null
             --         , p_structure_type  => 'FINANCIAL'
             --     )  = 'Y'
             --   )THEN
             --put the tests of check_delete_task_ok here.

             -- Commenting code for 4903460 and replacing this wth new code
             --Check if task has expenditure item
             /* IF l_debug_mode = 'Y' THEN
                   Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check expenditure item for '|| p_task_id;
                   Pa_Debug.WRITE(g_module_name , Pa_Debug.g_err_stage , l_debug_level3);
             END IF;
             l_status_code :=
             pa_proj_tsk_utils.check_exp_item_exists(null, p_task_id);
             IF ( l_status_code = 1 ) THEN
               x_error_code := 50;
               x_error_msg_code := 'PA_TSK_EXP_ITEM_EXIST';
               return;
             ELSIF ( l_status_code < 0 ) THEN
               x_error_code  := l_status_code;
               return;
             END IF;

             --Check if task has purchase order distribution
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check purchase order for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                            l_debug_level3);
             END IF;
             l_status_code :=
                     pa_proj_tsk_utils.check_po_dist_exists(NULL, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 60;
                 x_error_msg_code := 'PA_TSK_PO_DIST_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF;

             -- Check if task has purchase order requisition
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check purchase order requisition for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                            l_debug_level3);
             END IF;

             l_status_code :=
                  pa_proj_tsk_utils.check_po_req_dist_exists(NULL, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 70;
                 x_error_msg_code := 'PA_TSK_PO_REQ_DIST_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF;

             -- Check if task has supplier invoices
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check supplier invoice for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;

             l_status_code :=
                  pa_proj_tsk_utils.check_ap_invoice_exists(NULL, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 80;
                 x_error_msg_code := 'PA_TSK_AP_INV_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF;

             -- Check if task has supplier invoice distribution
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check supplier inv distribution for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;

             l_status_code :=
                  pa_proj_tsk_utils.check_ap_inv_dist_exists(NULL, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 90;
                 x_error_msg_code := 'PA_TSK_AP_INV_DIST_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF;

             -- Check if task has commitment transaction
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check commitment transaction for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;
             l_status_code :=
                  pa_proj_tsk_utils.check_commitment_txn_exists(null, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 110;
                 x_error_msg_code := 'PA_TSK_CMT_TXN_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF;

             -- Check if task has compensation rule set
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check compensation rule set for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;

             l_status_code :=
                  pa_proj_tsk_utils.check_comp_rule_set_exists(NULL, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 120;
                 x_error_msg_code := 'PA_TSK_COMP_RULE_SET_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF; */
             -- End of Commenting for 4903460
             -- Check if task is in use in an external system
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check for task used in external system for'|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;

             l_status_code :=
                  pjm_projtask_deletion.CheckUse_ProjectTask(null, p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 130;
         /* Commented the existing error message and modified it to 'PA_PROJ_TASK_IN_USE_MFG' as below for bug 3600806
                 x_error_msg_code := 'PA_TASK_IN_USE_EXTERNAL';*/
                 x_error_msg_code := 'PA_PROJ_TASK_IN_USE_MFG';
                 return;
             ELSIF ( l_status_code = 2 ) THEN         -- Added elseif condition for bug 3600806.
                 x_error_code := 130;
             x_error_msg_code := 'PA_PROJ_TASK_IN_USE_AUTO';
             return;
         ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             ELSIF ( l_status_code <> 0) then     -- Added else condition for bug 3600806 to display a generic error message.
                 x_error_code := 130;
                 x_error_msg_code := 'PA_PROJ_TASK_IN_USE_EXTERNAL';
                 return;
         END IF;

             -- Check if task is used in allocations
             IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check if project allocations uses task '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;

             l_return_val :=
                  pa_alloc_utils.Is_Task_In_Allocations(p_task_id);
             IF ( l_return_val = 'Y' ) THEN
                 x_error_code := 140;
                 x_error_msg_code := 'PA_TASK_IN_ALLOC';
                 return;
             END IF;

             -- Commenting for Performance fix 4903460
             /*
             -- Check if task has draft invoices
              IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check draft invoice for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;

             l_status_code :=
                  pa_proj_tsk_utils.check_draft_inv_details_exists(p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 160;
                 x_error_msg_code := 'PA_TSK_CC_DINV_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF;

             -- Check if task has Project_customers
              IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check Project Customers for '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
             END IF;


             l_status_code :=
                  pa_proj_tsk_utils.check_project_customer_exists(p_task_id);
             IF ( l_status_code = 1 ) THEN
                 x_error_code := 170;
                 x_error_msg_code := 'PA_TSK_CC_CUST_EXIST';
                 return;
             ELSIF ( l_status_code < 0 ) THEN
                 x_error_code := l_status_code;
                 return;
             END IF; */
	     --End of Commenting for Performance fix 4903460

             -- Start of new code for Performance fix 4903460
             PA_PROJ_ELEMENTS_UTILS.perform_task_validations
	     (
	      p_project_id => p_project_id
	     ,p_task_id    => p_task_id
	     ,x_error_code => x_error_code
	     ,x_error_msg_code => x_error_msg_code
	     );

	     IF x_error_code <> 0 THEN
	         return;
             END IF;
	     -- End of new code for Performance fix 4903460

             -- Check if project contract is installed
             IF (pa_install.is_product_installed('OKE')) THEN
                IF l_debug_mode = 'Y' THEN
                             Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : Check contract association for task '|| p_task_id;
                             Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                          l_debug_level3);
                END IF;

                IF (PA_PROJ_STRUCTURE_PUB.CHECK_TASK_CONTRACT_ASSO(p_task_id) <>
                   FND_API.G_RET_STS_SUCCESS) THEN
                 x_error_code := 190;
                 x_error_msg_code := 'PA_STRUCT_TK_HAS_CONTRACT';
                 return;
               END IF;
             END IF;
             -- Finished checking if project contract is installed.

             --Check to see if the task has been used in OTL
               PA_OTC_API.ProjectTaskUsed( p_search_attribute => 'TASK',
                                           p_search_value     => p_task_id,
                                           x_used             => l_used_in_OTL );
               --If exists in OTL
               IF l_used_in_OTL
               THEN
                 x_error_code := 200;
                 x_error_msg_code := 'PA_TSK_EXP_ITEM_EXIST';
                 return;
               END IF;

             --end of OTL check.
               Is_IEX_Installed := pa_install.is_product_installed('IEX');
               If Is_IEX_Installed then
                     IF l_debug_mode = 'Y' THEN
                                  Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : check if task '|| p_task_id || ' is charged in iexpense';
                                  Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                               l_debug_level3);
                     END IF;

                    l_status_code := pa_proj_tsk_utils.check_iex_task_charged(p_task_id);
                    IF ( l_status_code = 1 ) THEN
                        x_error_code := 210;
                        x_error_msg_code := 'PA_TSK_EXP_ITEM_EXIST';
                        return;
                    ELSIF ( l_status_code < 0 ) THEN
                        x_error_code := l_status_code;
                        return;
                    END IF;
               END IF;
               --BEGIN
               IF l_debug_mode = 'Y' THEN
                   Pa_Debug.g_err_stage:= 'PA_PROJ_ELEMENTS_UTILS : CHECK_TASK_HAS_TRANSACTION : PA_FIN_PLAN_UTILS.CHECK_DELETE_TASK_OK'|| p_task_id;
                    Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                               l_debug_level3);
                END IF;

                PA_FIN_PLAN_UTILS.CHECK_DELETE_TASK_OK(
                  p_task_id                => p_task_id
                 ,p_validation_mode        => 'U'
                 ,x_return_status          => l_return_status
                 ,x_msg_count              => l_msg_count
                 ,x_msg_data               => l_msg_data
                );
                   IF (l_return_status <> 'S') Then
                      x_error_code := 220;
                      x_error_msg_code   := pa_project_core1.get_message_from_stack( l_msg_data );
                      return;
                   END IF;
                       --EXCEPTION  WHEN OTHERS THEN
                  --    IF l_debug_mode = 'Y' THEN
                  --                Pa_Debug.g_err_stage:= 'API PA_FIN_PLAN_UTILS.CHECK_DELETE_TASK_OK FAILED';
                  --                Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                  --                             l_debug_level3);
                  --    END IF;
                  --END;

       --To be reviewed with set financial task
       --END IF;--If Financial task condition
      END IF;-- If task ID is not null condition

     -- Bug 3735089 : using reset_curr_function too, just using set_curr_function may overflow it after several recursive calls
     -- and it gives ORA 06512 numeric or value error
      IF l_debug_mode = 'Y' THEN
    Pa_Debug.reset_curr_function;
      END IF;


EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := substrb(SQLERRM,1,120);-- Bug 3735089 Added substr --  4537865 Changed substr to substrb

     --  4537865
     x_error_code := SQLCODE;
     x_error_msg_code := SQLCODE ;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_PROJ_ELEMENT_UTILS'
                    ,p_procedure_name  => 'CHECK_TASK_HAS_TRANSACTION'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);

          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END CHECK_TASK_HAS_TRANSACTION;
--Begin add rtarway FP.M Develepment

function GET_TOP_TASK_VER_ID(p_element_version_id IN number) return number
is
   --bug 4043647 , start
   /*cursor C1 is
   select object_id_from1
   from pa_object_relationships
   where relationship_type='S'
   and object_type_from='PA_TASKS'
   connect by prior object_id_from1 = object_id_to1
          and prior relationship_type = relationship_type
   start with object_id_to1 = p_element_version_id
          and relationship_type = 'S'
   union
    select p_element_version_id from dual ;  --bug 3429648*/

   cursor C1 is
   select object_id_to1
   from pa_object_relationships
   where relationship_type='S'
   and object_type_from='PA_STRUCTURES'
   and object_type_to='PA_TASKS'
   connect by prior object_id_from1 = object_id_to1
   start with object_id_to1 = p_element_version_id
          and relationship_type = 'S';

   --bug 4043647 , end

/*
      intersect
   select a.object_id_to1
   from pa_object_relationships a, pa_proj_element_versions b
   where b.element_version_id = p_element_version_id
   and b.parent_structure_version_id = a.object_id_from1
   and a.relationship_type = 'S';
*/

   l_top_task_ver_id NUMBER := p_element_version_id;

begin
   OPEN c1;
   FETCH c1 INTO l_top_task_ver_id;
   CLOSE c1;
   return l_top_task_ver_id;
exception
   when others then
     return(SQLCODE);
end GET_TOP_TASK_VER_ID;

function GET_TOP_TASK_ID(p_element_version_id IN number) return number
is
   cursor C1 (evid number) is
   select proj_element_id from pa_proj_element_versions
   where element_version_id IN (
   /*select object_id_from1   --bug 4043647
   from pa_object_relationships
   where relationship_type='S'
   and object_type_from='PA_TASKS'
   connect by prior object_id_from1 = object_id_to1
          and prior relationship_type = relationship_type
   start with object_id_to1 = p_element_version_id
          and relationship_type = 'S'
   union
    select p_element_version_id from dual );  --bug 3429648*/
   select object_id_to1
   from pa_object_relationships
   where relationship_type='S'
   and object_type_from='PA_STRUCTURES'
   and object_type_to='PA_TASKS'
   connect by prior object_id_from1 = object_id_to1
   start with object_id_to1 = p_element_version_id
          and relationship_type = 'S');


/*
      intersect
   select a.object_id_to1
   from pa_object_relationships a, pa_proj_element_versions b
   where b.element_version_id = p_element_version_id
   and b.parent_structure_version_id = a.object_id_from1
   and a.relationship_type = 'S');
*/

   l_top_task_ver_id NUMBER := p_element_version_id;
   l_top_task_id NUMBER;

begin
   OPEN c1(p_element_version_id);
   FETCH c1 INTO l_top_task_id;
   CLOSE c1;

   return l_top_task_id;
exception
   when others then
     return(SQLCODE);
end GET_TOP_TASK_ID;

/* 4156732 : This API returns Task Level for Workplan Tasks
 */
function GET_TASK_LEVEL(p_element_version_id IN number) return varchar2
is
   cursor C1 (evid number) is
   select 1
   from pa_object_relationships
   where object_id_to1 = evid
   and relationship_type='S'
   and object_type_from='PA_STRUCTURES';

   cursor C2 (evid number) is
   select 1
   from pa_object_relationships
   where object_id_from1 = evid
   and relationship_type='S';

   c1rec C1%ROWTYPE;
   c2rec C2%ROWTYPE;

   l_tasks_above NUMBER :=0;
   l_tasks_below NUMBER :=0;

   l_task_level VARCHAR2(1) :='L';

   l_dummy NUMBER;

   CURSOR c3(evid NUMBER) IS
   select 1 from pa_proj_element_versions
   where element_version_id = evid
   and object_type = 'PA_STRUCTURES';

begin
   OPEN c3(p_element_version_id);
   FETCH c3 into l_dummy;
   IF C3%FOUND THEN --it is a structure, return T or L
     OPEN c2(p_element_version_id);
     FETCH c2 into l_dummy;
     IF C2%FOUND THEN
       --it has child
       l_task_level := 'T';
     END IF;
     CLOSE c2;
     CLOSE c3;
     return l_task_level;
   END IF;
   CLOSE c3;

   OPEN C1(p_element_version_id);
   FETCH c1 into l_dummy;
   IF c1%found THEN
      l_task_level := 'T';
      CLOSE c1;
      OPEN c2(p_element_version_id);
      FETCH c2 into l_dummy;
      IF c2%NOTFOUND THEN
        l_task_level := 'L';
      END IF;
      CLOSE c2;
      return l_task_level;
   END IF;
   CLOSE c1;

   OPEN C2(p_element_version_id);
   FETCH c2 into l_dummy;
   IF c2%found THEN
      l_task_level := 'M';
      CLOSE c2;
      return l_task_level;
   END IF;
   CLOSE c2;

   return l_task_level;
exception
   when others then
     return(SQLERRM);
end GET_TASK_LEVEL;

/* Created by avaithia for Bug 4156732
   This API (over-ridden GET_TASK_LEVEL API) which takes the following two parameters
   gives the Task Level of Financial Tasks.

   API Name      : GET_TASK_LEVEL

   Parameters             Description       Type Of Parameter
   ==========             ===============   ===================
   p_project_id           The Project ID    PA_PROJECTS_ALL.PROJECT_ID%TYPE
   p_proj_element_id      The ProjElementID PA_PROJ_ELEMENT_VERSIONS.PROJ_ELEMENT_ID%TYPE

   Return Value of this function :
   ===============================
   'T' -> Top Task , 'M' -> Middle Task , 'L' -> Lowest Task , 'X' -> Not Financial Task

    Note that it is very much possible that (say) the case of Partially Shared Structures,
    Some of the tasks may be both workplan and financial tasks,whereas some tasks are only workplan tasks.

    In this case,There will not be any entry for those 'pure' workplan tasks in PA_TASKS table.
    Hence,for such passed Proj_element_id's this API will return 'X'
*/
FUNCTION GET_TASK_LEVEL(p_project_id   PA_PROJECTS_ALL.PROJECT_ID%TYPE,
                        p_proj_element_id PA_PROJ_ELEMENT_VERSIONS.PROJ_ELEMENT_ID%TYPE) RETURN VARCHAR2
IS
   l_task_level VARCHAR2(1) :='L';

   l_dummy NUMBER;
   l_parent_task NUMBER;
   l_mid_task NUMBER;

   CURSOR c_task_exists
   IS
   select 1
   from pa_tasks
   where task_id = p_proj_element_id
     and project_id = p_project_id
   ;

   CURSOR c_is_parent_task
   IS
   select 1
   from dual
   where exists
   (select 1
      from pa_tasks
     where nvl(parent_task_id,-9999) = p_proj_element_id
       and project_id = p_project_id
    ) ;

   CURSOR c_is_mid_task
   IS
   select 1 from pa_tasks
    where parent_task_id is not null
      and task_id = p_proj_element_id ;

BEGIN

OPEN c_task_exists;
FETCH c_task_exists INTO l_dummy ;
CLOSE c_task_exists;

IF nvl(l_dummy,0) = 0
THEN
return 'X' ; -- as the task doesnt exist in PA_TASKS table
END IF;

--At this point the task exists

OPEN c_is_parent_task ;
FETCH c_is_parent_task INTO l_parent_task;
CLOSE c_is_parent_task;

IF nvl(l_parent_task,0) = 0
THEN
return 'L' ; -- as the task is not parent of any other task,(i.e) No Children ,Hence it is the lowest task
END IF;

-- At this point ,The Task exists and it has children ,So it can be a top task or a mid task

OPEN c_is_mid_task ;
FETCH c_is_mid_task INTO l_mid_task;
CLOSE c_is_mid_task ;

IF nvl(l_mid_task,0) = 0
THEN
return 'T' ; -- as the task exists and its parent_task_id is null => It has no parent,hence the top most task
END IF;

-- At this point ,The Task exists and it has children as well as a parent task ,So this is a mid-task
return 'M';

exception
   when others then
   return (SQLERRM);

END GET_TASK_LEVEL ;

--Begin Add sabansal
--Function to check whether the given task is a workplan task or not
FUNCTION CHECK_IS_WORKPLAN_TASK(p_project_id NUMBER,
                                p_proj_element_id NUMBER) RETURN VARCHAR2
IS
str_sharing_code VARCHAR2(30):= null;
return_flag      VARCHAR2(1) := null;

BEGIN

SELECT structure_sharing_code INTO str_sharing_code
FROM pa_projects_all
WHERE project_id = p_project_id;

--If sharing is enabled, then financial and workplan tasks would be common
IF str_sharing_code = 'SHARE_FULL' OR
   str_sharing_code = 'SHARE_PARTIAL' THEN
   return_flag := 'Y';
ELSIF PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(p_proj_element_id) = 'N' THEN
   return_flag := 'Y';
 ELSE
   return_flag := 'N';
END IF;

return return_flag;
EXCEPTION
  WHEN OTHERS THEN
    return null;
END CHECK_IS_WORKPLAN_TASK;
--End Add sabansal

function GET_PARENT_TASK_ID(p_element_version_id IN number) return number
is
   CURSOR c1 IS
   SELECT proj_element_id
   FROM pa_object_relationships, pa_proj_element_versions
   WHERE object_id_to1  = p_element_version_id
   AND object_type_from='PA_TASKS'
   AND object_id_from1 = element_version_id;

   l_parent_task_id NUMBER := NULL;
begin
   OPEN c1;
   FETCH c1 into l_parent_task_id;
   CLOSE c1;

   return l_parent_task_id;
exception
   when others then
     return(SQLCODE);
end GET_PARENT_TASK_ID;

function GET_PARENT_TASK_VERSION_ID(p_element_version_id IN number) return number
is
   l_parent_task_id NUMBER := NULL;
   l_parent_task_version_id NUMBER := NULL;


   CURSOR c1 IS
   SELECT object_id_from1
   FROM pa_object_relationships
   WHERE object_id_to1  = p_element_version_id
   AND object_type_from='PA_TASKS'
   AND relationship_type = 'S';

begin
   OPEN c1;
   FETCH c1 into l_parent_task_version_id;
   CLOSE c1;
   return l_parent_task_version_id;
exception
   when others then
     return(SQLCODE);
end GET_PARENT_TASK_VERSION_ID;

function GET_TASK_VERSION_ID(
    p_structure_version_id  IN NUMBER
    ,p_task_id          IN NUMBER) return NUMBER
is
   l_task_version_id NUMBER;
begin
  select b.element_version_id into l_task_version_id from pa_proj_elements a, pa_proj_element_versions b
  where  a.proj_element_id = b.proj_element_id
  and    a.proj_element_id = p_task_id
  and    b.parent_structure_version_id = p_structure_version_id;

  return l_task_version_id;
exception
   when others then
--     return(SQLCODE);
     return to_number(NULL);   --Bug 3646375
end GET_TASK_VERSION_ID;

function GET_RELATIONSHIP_ID(
    p_object_id_from1  IN NUMBER
    ,p_object_id_to1   IN NUMBER) return NUMBER
is
   l_relationship_id NUMBER;
begin
   select object_relationship_id into l_relationship_id from pa_object_relationships
   where object_id_from1 = p_object_id_from1
   and   object_id_to1 = p_object_id_to1
   and   relationship_type = 'D';

   return l_relationship_id;
exception
   when others then
--     return(SQLCODE);
     return to_number(NULL);   --Bug 3646375
end GET_RELATIONSHIP_ID;

FUNCTION check_task_parents_deliv(p_element_version_id IN number)
RETURN VARCHAR2
IS
--
   CURSOR cur_check_deliv (cp_task_version_id number) IS
   SELECT ppe.proj_element_id,ppe.base_percent_comp_deriv_code
     FROM pa_proj_element_versions ppev,
          pa_proj_elements ppe
    WHERE ppe.project_id = ppev.project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppe.object_type = 'PA_TASKS'
      AND ppev.element_version_id IN (
                     SELECT object_id_to1
                       FROM pa_object_relationships
                      WHERE relationship_type = 'S'
                 START WITH object_id_to1 = cp_task_version_id --24628
                        AND object_type_to = 'PA_TASKS'
                        and relationship_type = 'S'
           CONNECT BY PRIOR object_id_from1 = object_id_to1
                  AND PRIOR object_type_from = object_type_to
                  AND PRIOR relationship_type = relationship_type);
--
   cur_check_deliv_rec cur_check_deliv%ROWTYPE;
--
--   l_err_msg VARCHAR2(80) :=NULL;
   l_err_msg VARCHAR2(1) :='N';  --Bug 3475920
--
BEGIN
    OPEN cur_check_deliv(p_element_version_id);
    LOOP
       FETCH cur_check_deliv INTO cur_check_deliv_rec;
       EXIT WHEN cur_check_deliv%NOTFOUND;
       IF cur_check_deliv_rec.base_percent_comp_deriv_code LIKE 'DELIVERABLE' THEN
          l_err_msg := 'Y';
      EXIT;
       END IF;
    END LOOP;
    RETURN l_err_msg;
EXCEPTION
    WHEN OTHERS THEN
       RETURN(SQLERRM);
END check_task_parents_deliv;

--Can be used for update, indent, Move task
FUNCTION check_deliv_in_hierarchy(p_element_version_id IN number,
                                p_target_element_version_id IN number)
RETURN VARCHAR2
IS
   CURSOR cur_check_deliv_bt (cp_target_task_version_id number) IS
   SELECT ppe.proj_element_id,ppe.base_percent_comp_deriv_code, ppev.element_version_id
     FROM pa_proj_element_versions ppev,
          pa_proj_elements ppe
    WHERE ppe.project_id = ppev.project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppe.object_type = 'PA_TASKS'
      AND ppev.element_version_id IN (
                     SELECT object_id_to1
                       FROM pa_object_relationships
                      WHERE relationship_type = 'S'
                 START WITH object_id_to1 = cp_target_task_version_id
                        AND object_type_to = 'PA_TASKS'
                        and relationship_type = 'S'
           CONNECT BY PRIOR object_id_from1 = object_id_to1
                  AND PRIOR object_type_from = object_type_to
                  AND PRIOR RELATIONSHIP_TYPE = RELATIONSHIP_TYPE);

   CURSOR cur_check_deliv_tb (cp_task_version_id number) IS
   SELECT ppe.proj_element_id,ppe.base_percent_comp_deriv_code, ppev.element_version_id
     FROM pa_proj_element_versions ppev,
          pa_proj_elements ppe
    WHERE ppe.project_id = ppev.project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppe.object_type = 'PA_TASKS'
      AND ppev.element_version_id IN (
                     SELECT object_id_to1
                       FROM pa_object_relationships
                      WHERE relationship_type = 'S'
                 START WITH object_id_to1 = cp_task_version_id
                        AND object_type_to = 'PA_TASKS'
                        and relationship_type = 'S'
                 CONNECT BY object_id_from1 = prior object_id_to1
                        AND object_type_from = prior object_type_to
                        AND PRIOR RELATIONSHIP_TYPE = RELATIONSHIP_TYPE);

   cur_check_deliv_bt_rec cur_check_deliv_bt%ROWTYPE;
   cur_check_deliv_tb_rec cur_check_deliv_tb%ROWTYPE;
--   l_err_msg VARCHAR2(80) :=NULL;
   l_err_msg VARCHAR2(1) :='N';  --Bug 3475920
   l_cnt_no_del_in_branch NUMBER:=0;
BEGIN
    FOR cur_check_deliv_bt_rec in cur_check_deliv_bt(p_target_element_version_id)
    LOOP
       IF cur_check_deliv_bt_rec.base_percent_comp_deriv_code LIKE 'DELIVERABLE' THEN
          l_cnt_no_del_in_branch := l_cnt_no_del_in_branch + 1;
          EXIT;
       END IF;
    END LOOP;
--
    FOR cur_check_deliv_tb_rec in cur_check_deliv_tb(p_element_version_id)
    LOOP
        IF cur_check_deliv_tb_rec.base_percent_comp_deriv_code LIKE 'DELIVERABLE' THEN
           l_cnt_no_del_in_branch := l_cnt_no_del_in_branch + 1;
       EXIT;
        END IF;
    END LOOP;
--
--    IF l_cnt_no_del_in_branch > 2 AND (p_element_version_id = p_target_element_version_id) THEN
    IF l_cnt_no_del_in_branch >= 2 AND (p_element_version_id = p_target_element_version_id) THEN
          l_err_msg:= 'Y';
    ELSIF l_cnt_no_del_in_branch > 1 AND (p_element_version_id <> p_target_element_version_id) THEN
       l_err_msg:= 'Y';
    END IF;
    RETURN l_err_msg;
EXCEPTION
   WHEN OTHERS THEN
     RETURN(SQLERRM);
END check_deliv_in_hierarchy;
--
FUNCTION check_sharedstruct_deliv(p_element_version_id IN number)
RETURN VARCHAR2
IS
    /* This cursor get all the leaf nodes for a given structure*/
    CURSOR get_leaf_node_cur(cp_structure_elem_id NUMBER) IS
    SELECT object_id_to1
      FROM pa_proj_element_versions ppev,
           pa_object_relationships rel1
     WHERE ppev.parent_structure_version_id = cp_structure_elem_id --19671
       AND rel1.relationship_type = 'S'
       AND ppev.element_version_id = rel1.object_id_to1
       AND NOT EXISTS (SELECT 'XYZ'
                         FROM pa_object_relationships rel2
                        WHERE rel2.object_id_from1 = rel1.object_id_to1);
    get_leaf_node_rec get_leaf_node_cur%ROWTYPE;

    /* This cursor goes from leaf node to top of the branch*/
    CURSOR check_for_deliv_cur (cp_task_version_id number) IS
    SELECT ppe.proj_element_id,ppe.base_percent_comp_deriv_code
      FROM pa_proj_element_versions ppev,
           pa_proj_elements ppe
     WHERE ppe.project_id = ppev.project_id
       AND ppe.proj_element_id = ppev.proj_element_id
       AND ppev.object_type = 'PA_TASKS'
       AND ppe.object_type = 'PA_TASKS'
       AND ppev.element_version_id IN (
                      SELECT object_id_to1
                        FROM pa_object_relationships
                       WHERE relationship_type = 'S'
                  START WITH object_id_to1 = cp_task_version_id --24628
                         AND object_type_to = 'PA_TASKS'
                         and relationship_type = 'S'
            CONNECT BY PRIOR object_id_from1 = object_id_to1
                   AND PRIOR object_type_from = object_type_to
                   AND PRIOR RELATIONSHIP_TYPE = RELATIONSHIP_TYPE);
    check_for_deliv_rec check_for_deliv_cur%ROWTYPE;
    branch_deliv_count NUMBER:=0;
    l_err_msg VARCHAR2(1) :='N';
BEGIN
--    OPEN get_leaf_node_cur(p_structure_elem_id);
    OPEN get_leaf_node_cur(p_element_version_id);
    LOOP
        FETCH get_leaf_node_cur INTO get_leaf_node_rec;
        EXIT WHEN get_leaf_node_cur%NOTFOUND;
--
        IF branch_deliv_count = 2 THEN
           EXIT;
        END IF;
--
        OPEN check_for_deliv_cur(get_leaf_node_rec.object_id_to1);
        LOOP
            FETCH check_for_deliv_cur INTO check_for_deliv_rec;
        IF check_for_deliv_cur%NOTFOUND THEN
               IF branch_deliv_count < 2 THEN
                  branch_deliv_count:=0;
               END IF;
               EXIT;
            END IF;
--
            IF check_for_deliv_rec.base_percent_comp_deriv_code LIKE 'DELIVERABLE' THEN
               branch_deliv_count := branch_deliv_count + 1;
            END IF;
            IF branch_deliv_count = 2 THEN
               l_err_msg := 'Y';
               EXIT;
            END IF;
--
        END LOOP; --End loop for check_for_deliv_cur cursor
        CLOSE check_for_deliv_cur;
--
    END LOOP; --End loop for get_leaf_node_cur cursor
    CLOSE get_leaf_node_cur;
--
    RETURN l_err_msg;
--
EXCEPTION
   WHEN OTHERS THEN
     RETURN(SQLERRM);
END check_sharedstruct_deliv;

FUNCTION IS_WF_PROCESS_RUNNING(p_proj_element_id IN number)
RETURN VARCHAR2
IS
CURSOR C
IS
     SELECT 'Y'
       FROM pa_wf_processes pwp, pa_proj_elements ppe       -- Bug #3967939
      WHERE pwp.ENTITY_KEY2 = to_char(p_proj_element_id)    -- Bug#3619754 : Added to_char
      AND ppe.PROJ_ELEMENT_ID = p_proj_element_id       -- Bug #3967939
      AND pwp.ITEM_TYPE = ppe.WF_ITEM_TYPE;         -- Bug #3967939

l_dummy VARCHAR2(1) := 'N' ;
BEGIN
     OPEN C;
     FETCH C INTO l_dummy ;
     IF C%NOTFOUND THEN
      l_dummy := 'N' ;
     END IF;
     CLOSE C;
     return l_dummy ;
EXCEPTION
WHEN OTHERS THEN
   return 'N' ;
END IS_WF_PROCESS_RUNNING ;

FUNCTION GET_ELEMENT_WF_ITEMKEY(p_proj_element_id IN number,
 p_project_id IN number, p_wf_type_code IN VARCHAR2 := 'TASK_EXECUTION')
RETURN VARCHAR2

IS
CURSOR C
IS
      select max(item_key)
        from   pa_wf_processes wp
        ,      pa_proj_elements pe
        where  wp.item_type = pe.wf_item_type
        and  wp.wf_type_code = p_wf_type_code
        and  to_char(pe.proj_element_id) = wp.entity_key2 --Bug 3619754 Added By avaithia
        and  to_char(pe.project_id) = wp.entity_key1 --Bug 3619754 Added By avaithia
        and  pe.project_id = p_project_id and pe.proj_element_id =p_proj_element_id;

l_item_key VARCHAR2(240) := '' ;
BEGIN
     OPEN C;
     FETCH C INTO l_item_key ;
     CLOSE C;
     return l_item_key ;
EXCEPTION
WHEN OTHERS THEN
   return '' ;
END GET_ELEMENT_WF_ITEMKEY;

FUNCTION GET_ELEMENT_WF_STATUS(p_proj_element_id IN number,
 p_project_id IN number, p_wf_type_code IN VARCHAR2 := 'TASK_EXECUTION')
RETURN VARCHAR2

IS
CURSOR c_item_type
IS
      select wf_item_type
        from pa_proj_elements pe
        where
        pe.project_id = p_project_id and pe.proj_element_id =p_proj_element_id;

l_status VARCHAR2(240)     := '';
l_item_key VARCHAR2(240)   := '';
l_wf_status VARCHAR2(240)  := '';
l_item_type VARCHAR2(240)  := '';
l_result VARCHAR2(240)     := '';

BEGIN

  open c_item_type;
  FETCH c_item_type INTO l_item_type;
  CLOSE c_item_type;

  if ( l_item_type is not null) then -- Commented this for Bug 4249993 and l_item_type <> '') then
      l_item_key :=  GET_ELEMENT_WF_ITEMKEY(p_proj_element_id,
            p_project_id, p_wf_type_code);

      if (l_item_key is not null) then -- Commented this for Bug 4249993 and l_item_key <> '') then
            WF_ENGINE.ItemStatus
                  (l_item_type,
                   l_item_key,
                   l_status ,
                   l_result );
      end if;
  end if;
  return l_status;

EXCEPTION
WHEN OTHERS THEN
   return '' ;
END GET_ELEMENT_WF_STATUS;

-- Function             : check_fin_or_wp_structure
-- Purpose              : Checks whether the passed proj_element_id record is a WP or FIN structure record
-- Parameters                    Type      Required  Description and Purpose
-- ---------------------------  ------     --------  --------------------------------------------------------
-- p_proj_element_id             NUMBER        Y      The proj_element_id to be checked
FUNCTION check_fin_or_wp_structure( p_proj_element_id IN NUMBER ) RETURN VARCHAR2 IS
    CURSOR cur_chk_fin_or_wp_structure IS
    SELECT 'Y'
    FROM   pa_proj_elements ppe
          ,pa_proj_structure_types ppst
          ,pa_structure_types pst
    WHERE  ppe.proj_element_id = p_proj_element_id
    AND    ppe.object_type = 'PA_STRUCTURES'
    AND    ppe.proj_element_id = ppst.proj_element_id
    AND    ppst.structure_type_id = pst.structure_type_id
    AND    pst.structure_type IN ('WORKPLAN','FINANCIAL') ;

    l_return_flag   VARCHAR2(1);
BEGIN
    OPEN  cur_chk_fin_or_wp_structure;
    FETCH cur_chk_fin_or_wp_structure INTO l_return_flag;
    CLOSE cur_chk_fin_or_wp_structure;

    RETURN nvl(l_return_flag,'N');
EXCEPTION
    WHEN OTHERS THEN
        RETURN '';
END;

FUNCTION CHECK_USER_VIEW_TASK_PRIVILEGE
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2
IS
l_ret_code VARCHAR2(1) ;
BEGIN
l_ret_code := PA_SECURITY_PVT.check_user_privilege
                 ( p_privilege    => 'PA_PAXPREPR_OPT_WORKPLAN_STR_V'
                  ,p_object_name  => 'PA_PROJECTS'
                  ,p_object_key   => p_project_id
                  ) ;
RETURN l_ret_code ;
END CHECK_USER_VIEW_TASK_PRIVILEGE;
--
--
function GET_SUB_TASK_VERSION_ID(p_task_version_id IN number) return number
is
   l_sub_task_id NUMBER := NULL;
   l_sub_task_version_id NUMBER := NULL;
--
--
   CURSOR c1 IS
   SELECT object_id_to1
   FROM pa_object_relationships
   WHERE object_id_from1  = p_task_version_id
   AND object_type_to='PA_TASKS'
   AND relationship_type = 'S';
--
begin
   OPEN c1;
   FETCH c1 into l_sub_task_version_id;
   CLOSE c1;
   return l_sub_task_version_id;
exception
   when others then
     return(SQLCODE);
end GET_SUB_TASK_VERSION_ID;
--
--
FUNCTION check_deliv_in_hie_upd(p_task_version_id IN number)
RETURN NUMBER
IS
   CURSOR cur_check_deliv_bt (cp_target_task_version_id number) IS
   SELECT ppe.proj_element_id,ppe.base_percent_comp_deriv_code, ppev.element_version_id
     FROM pa_proj_element_versions ppev,
          pa_proj_elements ppe
    WHERE ppe.project_id = ppev.project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppe.object_type = 'PA_TASKS'
      AND ppev.element_version_id IN (
                     SELECT object_id_to1
                       FROM pa_object_relationships
                      WHERE relationship_type = 'S'
                 START WITH object_id_to1 = cp_target_task_version_id
                        AND object_type_to = 'PA_TASKS'
                        and relationship_type = 'S'
           CONNECT BY PRIOR object_id_from1 = object_id_to1
                  AND PRIOR object_type_from = object_type_to
                  AND PRIOR relationship_type = RELATIONSHIP_TYPE);

   CURSOR cur_check_deliv_tb (cp_task_version_id number) IS
   SELECT ppe.proj_element_id,ppe.base_percent_comp_deriv_code, ppev.element_version_id
     FROM pa_proj_element_versions ppev,
          pa_proj_elements ppe
    WHERE ppe.project_id = ppev.project_id
      AND ppe.proj_element_id = ppev.proj_element_id
      AND ppev.object_type = 'PA_TASKS'
      AND ppe.object_type = 'PA_TASKS'
      AND ppev.element_version_id IN (
                     SELECT object_id_to1
                       FROM pa_object_relationships
                      WHERE relationship_type = 'S'
                 START WITH object_id_to1 = cp_task_version_id
                        AND object_type_to = 'PA_TASKS'
                        and relationship_type = 'S'
                 CONNECT BY object_id_from1 = prior object_id_to1
                        AND object_type_from = prior object_type_to
                        AND PRIOR relationship_type = RELATIONSHIP_TYPE);

   cur_check_deliv_bt_rec cur_check_deliv_bt%ROWTYPE;
   cur_check_deliv_tb_rec cur_check_deliv_tb%ROWTYPE;
--   l_err_msg VARCHAR2(80) :=NULL;
   l_err_msg VARCHAR2(1) :='N';  --Bug 3475920
   l_cnt_no_del_in_branch NUMBER:=0;
   l_parent_task_ver_id  NUMBER:=NULL;
   l_sub_task_ver_id  NUMBER:=NULL;
BEGIN
--
    l_parent_task_ver_id:=GET_PARENT_TASK_VERSION_ID(p_task_version_id);
    l_sub_task_ver_id:=GET_SUB_TASK_VERSION_ID(p_task_version_id);
--
    IF l_parent_task_ver_id IS NOT NULL THEN
       FOR cur_check_deliv_bt_rec in cur_check_deliv_bt(l_parent_task_ver_id)
       LOOP
           IF cur_check_deliv_bt_rec.base_percent_comp_deriv_code LIKE 'DELIVERABLE' THEN
              l_cnt_no_del_in_branch := l_cnt_no_del_in_branch + 1;
              EXIT;
           END IF;
       END LOOP;
    END IF;
--
    IF l_sub_task_ver_id IS NOT NULL THEN
       FOR cur_check_deliv_tb_rec in cur_check_deliv_tb(l_sub_task_ver_id)
       LOOP
           IF cur_check_deliv_tb_rec.base_percent_comp_deriv_code LIKE 'DELIVERABLE' THEN
              l_cnt_no_del_in_branch := l_cnt_no_del_in_branch + 1;
              EXIT;
           END IF;
       END LOOP;
    END IF;
--
    RETURN l_cnt_no_del_in_branch;
EXCEPTION
   WHEN OTHERS THEN
     RETURN(SQLERRM);
END check_deliv_in_hie_upd;
--
--
--  FUNCTION           check_pa_lookup_exists
--  PURPOSE            Checks whether the passed lookup_code and value are valid
--  RETURN VALUE       VARCHAR2 - 'Y' if the valid
--                                'N' otherwise.
--
Function check_pa_lookup_exists(p_lookup_type VARCHAR2,
                                p_lookup_code VARCHAR2)
RETURN VARCHAR2
IS
   CURSOR chk_lkp(cp_lookup_type VARCHAR2, cp_lookup_code VARCHAR2)
   IS
   SELECT 'Y'
     FROM pa_lookups
    WHERE lookup_type = cp_lookup_type
      AND lookup_code = cp_lookup_code;
   l_dummy varchar2(1):='Y';
BEGIN
--
    OPEN chk_lkp(p_lookup_type,p_lookup_code);
    FETCH chk_lkp INTO l_dummy;
--
    IF chk_lkp%NOTFOUND THEN
       l_dummy:= 'N';
    END IF;
--
    CLOSE chk_lkp;
--
    RETURN l_dummy;
--
END check_pa_lookup_exists;
--
--

function GET_TASK_ID(
    p_project_id  IN NUMBER
    ,p_structure_version_id  IN NUMBER
    ,p_task_version_id          IN NUMBER) return NUMBER
IS
   l_task_id NUMBER;
begin
  select b.proj_element_id into l_task_id
    from pa_proj_element_versions b
  where  b.element_version_id = p_task_version_id
  and    b.project_id = p_project_id
  and    b.parent_structure_version_id = p_structure_version_id;

  return l_task_id;
exception
   when others then
     return to_number(NULL);
end GET_TASK_ID;

-- Begin fix for Bug # 4237838.

function is_lowest_level_fin_task(p_project_id NUMBER
				  , p_task_version_id NUMBER
				  , p_include_sub_proj_flag VARCHAR2 := 'Y') -- Fix for Bug # 4290042.
return VARCHAR2
is

	cursor cur_fin_task(c_project_id NUMBER
			    , c_task_version_id NUMBER)
	is
	select ppev.financial_task_flag
	from pa_proj_element_versions ppev
	where ppev.project_id = c_project_id
	and ppev.element_version_id = c_task_version_id;

	l_financial_task_flag	VARCHAR2(1) := null;

	cursor cur_lowest_level_fin_task (c_project_id NUMBER
					  , c_task_version_id NUMBER
					  , c_include_sub_proj_flag VARCHAR2) -- Fix for Bug # 4290042.
	is
	-- This query checks if the task version has a financial sub-task.
        select 'N'
        from pa_object_relationships por1, pa_proj_element_versions ppev1
        where por1.object_id_to1 = ppev1.element_version_id
        and por1.relationship_type = 'S'
	and ppev1.project_id = c_project_id
        and por1.object_id_from1 = c_task_version_id
	and ppev1.financial_task_flag = 'Y'
	union all
	-- This query checks if the task version has a linking sub-task that has a financial link to
	-- a sub-project if the input p_include_sub_proj_flag = 'Y'.
        select 'N'
        from pa_object_relationships por2, pa_proj_element_versions ppev2
        where por2.object_id_to1 = ppev2.element_version_id
        and por2.relationship_type = 'S'
        and ppev2.project_id = c_project_id
        and por2.object_id_from1 = c_task_version_id
        and exists (select 'Y'
		    from pa_object_relationships por3
		    where por3.object_id_from1 = ppev2.element_version_id
		    and por3.object_id_from2 = ppev2.project_id
		    and por3.relationship_type = 'LF')
	and c_include_sub_proj_flag = 'Y'; -- Fix for Bug # 4290042.


	l_lowest_level_fin_task VARCHAR2(1) := null;

	l_return		VARCHAR2(1) := null;

begin

	l_return := 'Y';

	-- Check if the Task is a Financial Task.

	open cur_fin_task(p_project_id, p_task_version_id);

	fetch cur_fin_task into l_financial_task_flag;

	close cur_fin_task;

	if l_financial_task_flag = 'N' then

		l_return := 'N';

	else


		-- Check if the Financial Task is a Lowest Level Financial Task.


		open cur_lowest_level_fin_task (p_project_id, p_task_version_id, p_include_sub_proj_flag);
										-- Fix for Bug # 4290042.

		fetch cur_lowest_level_fin_task into l_lowest_level_fin_task;

		if cur_lowest_level_fin_task%FOUND then

			l_return := 'N';

		end if;

		close cur_lowest_level_fin_task;

	end if;

	return(l_return);

end is_lowest_level_fin_task;

-- End fix for Bug # 4237838.

-- Bug 4667361: Added this Function
FUNCTION WP_STR_EXISTS_FOR_UPG
(
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2 IS
   l_return_value  VARCHAR2(1) := 'N';
   l_dummy_char  VARCHAR2(1) := 'N';

  CURSOR cur_pa_proj
  IS

    SELECT 'x'
      FROM pa_proj_elements ppe, pa_proj_structure_types ppst
     WHERE ppe.project_id = p_project_id
       AND ppe.object_type = 'PA_STRUCTURES'
       AND ppe.proj_element_id = ppst.proj_element_id
       AND ppst.structure_type_id = 1;  --'WORKPLAN'

BEGIN

    open cur_pa_proj;
    fetch cur_pa_proj INTO l_dummy_char;
    IF cur_pa_proj%FOUND
    THEN
        l_return_value  := 'Y';
    ELSE
        l_return_value  := 'N';
    END IF;
    CLOSE cur_pa_proj;

    RETURN ( NVL( l_return_value, 'N' ) );

END WP_STR_EXISTS_FOR_UPG;

-- Bug 4667361: Added this Function
FUNCTION CHECK_SHARING_ENABLED_FOR_UPG
  (  p_project_id IN NUMBER
  ) return VARCHAR2
  IS
    CURSOR c1 IS
    SELECT 'Y'
    FROM pa_proj_elements a,
         pa_proj_structure_types b,
         pa_structure_types c,
         pa_proj_structure_types d,
         pa_structure_types e
    WHERE c.structure_type_class_code = 'WORKPLAN'
    AND   e.structure_type_class_code = 'FINANCIAL'
    AND   c.structure_type_id = b.structure_type_id
    AND   e.structure_type_id = d.structure_type_id
    AND   b.proj_element_id = a.proj_element_id
    AND   d.proj_element_id = a.proj_element_id
    AND   a.project_id = p_project_id;

    l_dummy VARCHAR2(1);
  BEGIN
    OPEN c1;
    FETCH c1 into l_dummy;
    IF c1%NOTFOUND THEN
      l_dummy := 'N';
    END IF;
    CLOSE c1;
    return l_dummy;

END CHECK_SHARING_ENABLED_FOR_UPG;


-- Procedure included for perf fix  4903460
---------------------------------------------
-- Does the following validations :
---------------------------------------------
-- Check if task has expenditure item
-- Check if task has purchase order distribution
-- Check if task has purchase order requisition
-- Check if task has supplier invoices
-- check if task has supplier invoice distribution
-- Check if task has commitment transaction
-- Check if task has compensation rule set
-- Check if task has draft invoices
-- Check if task has Project_customers

PROCEDURE perform_task_validations
(
 p_project_id     IN  NUMBER,
 p_task_id        IN  NUMBER,
 x_error_code     OUT NOCOPY NUMBER,
 x_error_msg_code OUT NOCOPY VARCHAR2
 )
IS
l_user_id               NUMBER;
l_login_id              NUMBER;
l_debug_mode            VARCHAR2(1);

l_debug_level3          CONSTANT NUMBER := 3;
l_debug_level5          CONSTANT NUMBER := 5;


/*CURSOR c_tasks_in_hierarchy IS	--Commented the following cursor as this is not needed after perf bug fix Bug#4964992
SELECT TASK_ID
FROM   PA_TASKS
CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
           AND PROJECT_ID = p_project_id
START WITH TASK_ID = p_TASK_ID
           AND PROJECT_ID = p_project_id; */

/*l_task_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(); */	-- Commented this as this is no more needed after Bug#4964992  fix.
l_dummy number:=0;
l_task_tbl sub_task; --Added this for Bug#4964992.

 BEGIN
         x_error_code := 0;
	 x_error_msg_code := NULL ;

        l_user_id := fnd_global.user_id;
        l_login_id := fnd_global.login_id;
        l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

        IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   =>'PERFORM_TASK_VALIDATIONS' , p_debug_mode => l_debug_mode );
        END IF;

        IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'TASK_VALIDATIONS : Printing Input parameters';
          Pa_Debug.WRITE('pa_proj_tsk_utils', Pa_Debug.g_err_stage ,l_debug_level3 );
          Pa_Debug.WRITE('pa_proj_tsk_utils', 'p_task_id'||':'||p_task_id , l_debug_level3);
        END IF;

	     /*OPEN  c_tasks_in_hierarchy;					-- Commented this for Bug#4964992
	     FETCH c_tasks_in_hierarchy BULK COLLECT INTO   l_task_id_tbl;
	     CLOSE c_tasks_in_hierarchy;*/

	     l_task_tbl := get_task_hierarchy(p_project_id,p_task_id);   -- Added this call for Bug#4964992
	     IF nvl(l_task_tbl.COUNT,0)>0 THEN
		  /*FOR i IN  l_task_id_tbl.FIRST..l_task_id_tbl.LAST	--Commented by Sunkalya for perf fix Bug#4964992
		  LOOP */

			--Check if task has expenditure item
			BEGIN

				l_dummy := 0;
				SELECT
				  1 into l_dummy
				FROM
				  sys.dual
				WHERE
				  exists (SELECT NULL
				            FROM   PA_EXPENDITURE_ITEMS_all  pei,table(cast(l_task_tbl as sub_task)) st   --Changed the query for Bug#4964992
						   WHERE  pei.TASK_ID = st.task_id)
			       or exists (SELECT NULL
                                  FROM    PA_EI_DENORM ped, table(cast(l_task_tbl as sub_task)) st
                                  WHERE   ped.TASK_ID = st.task_id);
				IF l_dummy = 1 THEN
					x_error_code :=50;
					x_error_msg_code := 'PA_TSK_EXP_ITEM_EXIST';
					return;
				END IF;

				EXCEPTION
				  WHEN NO_DATA_FOUND THEN
				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS : No Expenditure Items exist in the entire task hierarchy';
					IF l_debug_mode = 'Y' THEN
						Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
					END IF;
				  WHEN OTHERS THEN
				  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
  				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking Expenditure Items';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
				  return;
                        END;

			-- Check if task has purchase order distribution
			BEGIN
				l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM   po_distributions_all poa, table(cast(l_task_tbl as sub_task)) st  	  --Changed the query for Bug#4964992
					    where  poa.project_id = p_project_id
                                              AND  poa.TASK_ID = st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=60;
                                        x_error_msg_code := 'PA_TSK_PO_DIST_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
                                        Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No purchase order distribution exist in the entire task hierarchy';
					IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
    				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking purchase order distribution';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;

				  return;
                        END;

			-- Check if task has purchase order requisition
			BEGIN
				l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM   po_req_distributions_all prd, table(cast(l_task_tbl as sub_task)) st		--Changed the query for Bug#4964992
                                            where  prd.project_id = p_project_id
                                              AND  prd.TASK_ID = st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=70;
                                        x_error_msg_code :='PA_TSK_PO_REQ_DIST_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
				  Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No purchase order requisition exist in the entire task hierarchy';
					IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
    				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking purchase order requisition';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;

				  return;
                        END;

			-- Check if task has supplier invoices
			BEGIN
                                l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM   ap_invoices_all aia, table(cast(l_task_tbl as sub_task)) st			--Changed the query for Bug#4964992
                                            where  aia.project_id = p_project_id
                                              AND  aia.TASK_ID = st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=80;
                                        x_error_msg_code :='PA_TSK_AP_INV_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
				  Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No supplier invoices exist in the entire task hierarchy' ;
					IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
    				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking supplier invoices';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
                                  return;
                        END;

			-- check if task has supplier invoice distribution
                        BEGIN
                                l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM   ap_invoice_distributions_all aid, table(cast(l_task_tbl as sub_task)) st	--Changed the query for Bug#4964992
                                            where  aid.project_id = p_project_id
                                              AND  aid.TASK_ID = st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=90;
                                        x_error_msg_code :='PA_TSK_AP_INV_DIST_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
					Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No supplier invoice distribution exist';
					IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
    				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking supplier invoice distribution' ;

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
                                  return;
                        END;

			-- Check if task has commitment transaction
                        BEGIN
                                l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM   pa_commitment_txns pct, table(cast(l_task_tbl as sub_task)) st		--Changed the query for Bug#4964992
                                            where  pct.project_id = p_project_id
                                              AND  pct.TASK_ID = st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=110;
                                        x_error_msg_code :='PA_TSK_CMT_TXN_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
				  Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No commitment transaction exist';
					IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
    				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking commitment transaction';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
                                  return;
                        END;

			-- Check if task has compensation rule set
                        BEGIN
                                l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM   pa_comp_rule_ot_defaults_all pcr, table(cast(l_task_tbl as sub_task)) st	--Changed the query for Bug#4964992
                                            where  pcr.project_id = p_project_id
                                              AND  pcr.TASK_ID = st.task_id)
				 or exists (SELECT NULL
                                            FROM   pa_org_labor_sch_rule pol, table(cast(l_task_tbl as sub_task)) st
                                            where  overtime_project_id = p_project_id
                                              AND  pol.overtime_TASK_ID = st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=120;
                                        x_error_msg_code :='PA_TSK_COMP_RULE_SET_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
				  Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No compensation rule set exist';
                                        IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
    				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking compensation rule set';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
                                  return;
                        END;

			-- Check if task has draft invoices
                        BEGIN
                                l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM  pa_draft_invoice_details_all pdi, table(cast(l_task_tbl as sub_task)) st	--Changed the query for Bug#4964992
                                            where pdi.CC_TAX_TASK_ID =st.task_id
                                            and   pdi.project_id = p_project_id); -- Added for bug 8530541

                                IF l_dummy = 1 THEN
                                        x_error_code :=160;
					x_error_msg_code := 'PA_TSK_CC_DINV_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
					Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No draft invoice exist';
					IF l_debug_mode = 'Y' THEN
                                              Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking draft invoices';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
                                  return;
                        END;

			-- Check if task has Project_customers
                        BEGIN
                                l_dummy := 0;
                                SELECT
                                  1 into l_dummy
                                FROM
                                  sys.dual
                                WHERE
                                  exists (SELECT NULL
                                            FROM pa_project_customers pc, table(cast(l_task_tbl as sub_task)) st 		--Changed the query for Bug#4964992
                                            where /*pc.project_id = p_project_id and */ -- commented for bug 8485835 */
					      pc.receiver_task_id =st.task_id);

                                IF l_dummy = 1 THEN
                                        x_error_code :=170;
                                        x_error_msg_code := 'PA_TSK_CC_CUST_EXIST';
                                        return;
                                END IF;

                                EXCEPTION
                                  WHEN NO_DATA_FOUND THEN
					Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No Project_customers exist';
					IF l_debug_mode = 'Y' THEN
                                                Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
                                        END IF;
                                  WHEN OTHERS THEN
                                  x_error_code := SQLCODE;
				  x_error_msg_code := substrb(SQLERRM,1,120);
				  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking project customers';

				  IF l_debug_mode = 'Y' THEN
					Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				  END IF;
                                  return;
                        END;

                         /*  added these checks as a part of bug fix 6079887 */
			                        -- Check if task has iExpense records
							BEGIN
								l_dummy := 0;
					                        SELECT
					                          1 into l_dummy
					                        FROM
					                          sys.dual
					                        WHERE
					                          exists (SELECT NULL
					                                    FROM   ap_exp_report_dists_all er, table(cast(l_task_tbl as sub_task)) st  	  --Changed the query for Bug#4964992
									    where  er.project_id = p_project_id
					                                      AND  er.TASK_ID = st.task_id);

					                        IF l_dummy = 1 THEN
					                                x_error_code :=180;
					                                x_error_msg_code := 'PA_TSK_IEXP_EXIST';
					                                return;
					                        END IF;

					                        EXCEPTION
					                          WHEN NO_DATA_FOUND THEN
					                                Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No IExpenses exist in the entire task hierarchy';
									IF l_debug_mode = 'Y' THEN
					                                        Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
					                                END IF;
					                          WHEN OTHERS THEN
					                          x_error_code := SQLCODE;
								  x_error_msg_code := substrb(SQLERRM,1,120);
								  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking IExpense Records';

								  IF l_debug_mode = 'Y' THEN
									Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
								  END IF;

								  return;
			                              END;

			                        -- Check if task has Inventory Transaction records
						BEGIN
							l_dummy := 0;
						        SELECT
						          1 into l_dummy
						        FROM
						          sys.dual
						        WHERE
						          exists (SELECT NULL
						                    FROM   mtl_material_transactions mtl, table(cast(l_task_tbl as sub_task)) st  	  --Changed the query for Bug#4964992
								    where  mtl.project_id = p_project_id
						                      AND  mtl.TASK_ID = st.task_id);

						        IF l_dummy = 1 THEN
						                x_error_code :=190;
						                x_error_msg_code := 'PA_TSK_INV_TRANS_EXIST';
						                return;
						        END IF;

						        EXCEPTION
						          WHEN NO_DATA_FOUND THEN
						                Pa_Debug.g_err_stage:= 'API : TASK_VALIDATIONS : No Inventory transactions exist in the entire task hierarchy';
								IF l_debug_mode = 'Y' THEN
						                        Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
						                END IF;
						          WHEN OTHERS THEN
						          x_error_code := SQLCODE;
							  x_error_msg_code := substrb(SQLERRM,1,120);
							  Pa_Debug.g_err_stage:= ' TASK_VALIDATIONS :Unexpected Error occured while checking Inventory Records';

							  IF l_debug_mode = 'Y' THEN
								Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
							  END IF;

							  return;
			                        END;
			/*  added these checks as a part of bug fix 6079887 */

                 /* END LOOP; */   --Commented By  sunkalya for perf fix Bug#4964992
	     END IF;
IF l_debug_mode = 'Y' THEN
    Pa_Debug.reset_curr_function;
END IF;

EXCEPTION
WHEN OTHERS THEN
x_error_code := SQLCODE;
x_error_msg_code := substrb(SQLERRM,1,120);

Pa_Debug.g_err_stage:= 'Unexpected Error'||x_error_msg_code;

Fnd_Msg_Pub.add_exc_msg
( p_pkg_name        => 'pa_proj_tsk_utils'
,p_procedure_name  => 'TASK_VALIDATIONS'
,p_error_text      => x_error_msg_code);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,
                              l_debug_level5);

          Pa_Debug.reset_curr_function;
     END IF;
-- Important : Dont Raise : It will be taken care by Caller API

end PERFORM_TASK_VALIDATIONS;




-- API name                      : get_task_hierarchy
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : Type sub_task (Table)

-- Prameters			 :
-- p_project_id		IN		NUMBER
-- p_task_id		IN		NUMBER

-- Created By			 : Sunkalya
-- Created Date			 : 28-Feb-2006

-- Purpose:
-- This Function has been included for perf fix  4964992
----------------------------------------------------------------------------------------------------------
-- This function returns the entire hierarchy for the
-- passed task_id.

-- Note that START WITH - CONNECT BY CLAUSE cant be avoided as we want the task passed and all its children
-- in the hierarchy
-- This is known to cause FTS on pa_tasks . But,this cant be avoided.

-- (ie) if the hierarchy is :
--  1
--    11
--      111
--         1111

-- then ,if 1's task id is passed ,then we need the entire branch as above in
-- hierarchy.
-------------------------------------------------------------------------------------------------------------

-- History

-- 28-Feb-2006		Sunkalya	Created. Bug#4964992

FUNCTION get_task_hierarchy(
				p_project_id		IN		NUMBER,
				p_task_id		IN		NUMBER
			   )
RETURN sub_task
IS

l_task_tbl			sub_task;
l_debug_level3			CONSTANT NUMBER := 3;
l_user_id			NUMBER;
l_login_id			NUMBER;
l_debug_mode			VARCHAR2(1);

CURSOR task_hierarchy IS
SELECT
		task_rec(task_name,task_id)
	FROM
		pa_tasks
	CONNECT BY PRIOR
		task_id		=	parent_task_id	AND
		project_id	=	p_project_id
	START WITH
		task_id		=	p_task_id	AND
		project_id	=	p_project_id;

BEGIN
	l_user_id	:=	fnd_global.user_id;
	l_login_id	:=	fnd_global.login_id;

	l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

        IF l_debug_mode = 'Y' THEN
		PA_DEBUG.set_curr_function( p_function   =>'get_task_hierarchy' , p_debug_mode => l_debug_mode );
        END IF;

	OPEN  task_hierarchy;
	FETCH task_hierarchy BULK COLLECT INTO l_task_tbl;
	CLOSE task_hierarchy;

    IF l_debug_mode = 'Y' THEN       --Bug 8525293 Start
       pa_debug.reset_curr_function;
    END IF ;                         --Bug 8525293 End

	RETURN l_task_tbl;

EXCEPTION
	WHEN OTHERS THEN
		Pa_Debug.g_err_stage:= ' API:get_task_hierarchy :Unexpected Error occured while retrieving task strucutre for '|| p_task_id;
			IF l_debug_mode = 'Y' THEN
				Pa_Debug.WRITE('pa_proj_tsk_utils',Pa_Debug.g_err_stage,l_debug_level3);
				pa_debug.reset_curr_function; --Bug 8525293
			END IF;
                RAISE;
END get_task_hierarchy;

function IS_LOWEST_PROJ_TASK(
				p_task_version_id NUMBER,
				p_project_id  NUMBER) RETURN VARCHAR2
is
 l_dummy number;
 cursor child_exist IS
 select 1 from dual where exists(
  select 1
   from pa_object_relationships por, pa_proj_element_versions ppev, pa_proj_elements ppe
    where por.object_type_from = 'PA_TASKS'
    and por.object_id_from1 = p_task_version_id
    and por.relationship_type = 'S'
    and por.object_id_to1 = ppev.element_version_id
    and ppe.PROJ_ELEMENT_ID = ppev.PROJ_ELEMENT_ID
    and nvl(ppe.LINK_TASK_FLAG,'N') <> 'Y');

BEGIN

  OPEN child_exist;
  FETCH child_exist into l_dummy;
  IF child_exist%NOTFOUND then
    --Cannot find child. It is lowest task
    CLOSE child_exist;
    return 'Y';
  ELSE
    --Child found. Not lowest task
    CLOSE child_exist;
    return 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    raise;
END IS_LOWEST_PROJ_TASK;


END PA_PROJ_ELEMENTS_UTILS;

/
