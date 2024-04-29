--------------------------------------------------------
--  DDL for Package Body PA_TASK_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_APPROVAL_PKG" AS
/* $Header: PATSKPKB.pls 120.3.12010000.2 2009/08/19 12:46:13 anuragar noship $ */

  p_debug_mode    VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  PROCEDURE log_message (p_log_msg IN VARCHAR2, debug_level IN NUMBER) IS
  BEGIN
    IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write('log_message: ' || 'PA PWP Notification: ', 'log: ' || p_log_msg, debug_level);
    END IF;
  END log_message;

  -- To verify the task is a child task or not
  FUNCTION Is_Child_Task (p_project_id       IN NUMBER
                         ,p_proj_element     IN NUMBER
                         ,p_parent_struc_ver IN NUMBER
                         ,p_msg_count        OUT NOCOPY NUMBER
                         ,p_msg_data         OUT NOCOPY VARCHAR2
                         ,p_return_status    OUT NOCOPY VARCHAR2
						 ) RETURN BOOLEAN IS

  -- Cursor to identify if the given task has a parent task or not.
  CURSOR C1 IS
    SELECT  'Y'
      FROM  PA_PROJ_ELEMENT_VERSIONS
      WHERE proj_element_id = p_proj_element
      AND   parent_structure_version_id = p_parent_struc_ver
      AND   financial_task_flag = 'Y'
      AND   EXISTS (SELECT 1
                    FROM   PA_OBJECT_RELATIONSHIPS
                    WHERE  object_type_from = 'PA_TASKS'
                    AND    object_id_to1 = element_version_id
                    AND    object_type_to = 'PA_TASKS'
                    AND    relationship_type = 'S');

    l_is_child_task VARCHAR2(1) :='N';
  BEGIN
     log_message('Inside PA_TASK_APPROVAL_PKG.Is_Child_Task',3);
     p_return_status := 'S';
     OPEN C1;
     FETCH C1 INTO l_is_child_task;
     CLOSE C1;
     --b6694902_debug.debug('is_child_task '||l_is_child_task);
     log_message('Result of Is_Child_Task '||l_is_child_task,3);

     IF  l_is_child_task = 'Y' THEN
         log_message('Task '||p_proj_element||' has a parent task',3);
         RETURN TRUE;
     ELSE
         log_message('Task '||p_proj_element||' is a top/root task',3);
         RETURN FALSE;
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
        p_return_status := 'E';
  END Is_Child_Task;

  -- This procedure is to return true/false based on the parent_task's approval status
  -- of a given task. If Parent task is not approved, we cannot raise notification for
  -- the given task.

  FUNCTION Is_Parent_Task_Approved
                         (p_project_id       IN NUMBER
                         ,p_parent_task_id  IN NUMBER
                         ,p_task_id         IN NUMBER
                         ,p_parent_struc_ver IN NUMBER
                         ,p_msg_count       OUT NOCOPY NUMBER
                         ,p_msg_data        OUT NOCOPY VARCHAR2
                         ,p_return_status   OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

    -- Cursor is to identify if the p_parent_task_id exists in PA_TASKs or not.
    CURSOR C1 IS
      SELECT 'Y'
        FROM  PA_TASKS
        WHERE project_id = p_project_id
        AND   task_id = p_parent_task_id
        AND   EXISTS (
                       SELECT 1
                       FROM   PA_PROJ_ELEMENTS
                       WHERE  proj_element_id = p_parent_task_id
                       AND    link_task_flag = 'N');

    -- Cursor to find out if p_parent_task_id is root/top task
    CURSOR C2 IS
      SELECT  'Y'
      FROM  PA_PROJ_ELEMENT_VERSIONS
      WHERE proj_element_id = p_parent_task_id
      AND   parent_structure_version_id = p_parent_struc_ver
      AND   financial_task_flag = 'Y'
      AND   EXISTS (SELECT 1
                    FROM   PA_OBJECT_RELATIONSHIPS
                    WHERE  object_type_from = 'PA_STRUCTURES'
                    AND    object_id_to1 = element_version_id
                    AND    object_type_to = 'PA_TASKS'
                    AND    relationship_type = 'S');

    l_is_parent_tsk_aprvd VARCHAR2(1) := 'N';
  BEGIN
    log_message('Inside PA_TASK_APPROVAL_PKG.Is_Parent_Task_Approved',3);
    p_return_status := 'S';
    OPEN C1;
    FETCH C1 INTO l_is_parent_tsk_aprvd;
    CLOSE C1;

    IF l_is_parent_tsk_aprvd = 'N' THEN
      -- If the task and parent task are one and the same, which means-> task is a root/top task.
      -- In this case we need to check cursor C2. If cursor c2 returns a record, we return
      -- that parent task is approved.
      IF p_task_id  = p_parent_task_id THEN
         OPEN C2;
         FETCH C2 INTO l_is_parent_tsk_aprvd;
         CLOSE C2;
      END IF;
    END IF;

    --b6694902_debug.debug('is_parent_task_aprv '||l_is_parent_tsk_aprvd);
    log_message('Result of Is_Parent_Task_Approved '||l_is_parent_tsk_aprvd,3);

    IF l_is_parent_tsk_aprvd = 'Y' THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       p_return_status := 'E';
  END Is_Parent_Task_Approved;

  PROCEDURE Submit_Task
                        (p_project_id           IN NUMBER
                        ,p_task_id              IN NUMBER
                        ,p_ref_task_id          IN NUMBER
                        ,p_parent_struc_ver     IN NUMBER
                        ,p_approver_user_id     IN NUMBER
                        ,p_ci_id                IN NUMBER
                        ,p_msg_count            OUT NOCOPY NUMBER
                        ,p_msg_data             OUT NOCOPY VARCHAR2
                        ,p_return_status        OUT NOCOPY VARCHAR2) IS

      x_err_stack VARCHAR2(2000);
      x_err_stage VARCHAR2(100);
      x_err_code  NUMBER;
  BEGIN
       log_message('Inside PA_TASK_APPROVAL_PKG.Submit_Task',3);
       p_return_status := 'S';

       --b6694902_debug.debug('Before calling Start_Task_Aprv_Wf ');
       --b6694902_debug.debug('Before calling Start_Task_Aprv_Wf for task '||p_task_id);
       --b6694902_debug.debug('Before calling Start_Task_Aprv_Wf for task '||p_parent_struc_ver);

       log_message('Before calling Start_Task_Aprv_Wf for task',3);
       log_message('Task Id ['||p_task_id||'], '||
                   'Parent Task Structure version id ['||p_parent_struc_ver||'], '||
                   'Approver User Id ['||p_approver_user_id||']'
                 ,3);

update pa_proj_elements
set task_approver_id = p_approver_user_id
where proj_element_id = p_task_id;

       PA_TASK_WORKFLOW_PKG.Start_Task_Aprv_Wf (
                                'PATASKWF'
                               ,'PA_TASK_APPROVAL_WF'
                               ,p_project_id
                               ,p_task_id
                               ,p_parent_struc_ver
                               ,p_approver_user_id
                               ,p_ci_id
                               ,x_err_stack
                               ,x_err_stage
                               ,x_err_code
                              );
       --b6694902_debug.debug('x_err_code '||x_err_code);
       IF x_err_code > 0 THEN
          p_return_status :='E';
       END IF;
       commit;
  END Submit_Task;

  -- This procedure is being called from Change Order workflow
  -- to see if all the used tasks are approved or not.
  PROCEDURE Check_UsedTask_Status
                          (p_ci_id         IN NUMBER
                          ,p_msg_count     OUT NOCOPY NUMBER
                          ,p_msg_data      OUT NOCOPY VARCHAR2
                          ,p_return_status OUT NOCOPY VARCHAR2) IS

   CURSOR C1 IS
   Select count(distinct task_id) from
        pa_resource_assignments pra where
          budget_version_id in (
           select budget_version_id from pa_budget_versions where ci_id = p_ci_id )
        and exists (select 1
                  from pa_proj_elements ppe,
                       pa_proj_element_versions ppev,
                       pa_object_relationships por
                  where ppe.proj_element_id = pra.task_id
                  and ppe.project_id = pra.project_id
                  and ppe.link_task_flag = 'Y'
                  and ppe.type_id = 1
                  and ppev.proj_element_id = ppe.proj_element_id
                  and por.object_id_to1 = ppev.element_version_id
                  and por.object_type_to = 'PA_TASKS'
                  and por.relationship_type = 'S'
                  and ppev.financial_task_flag = 'Y')
        and not exists (select 1 from pa_tasks where task_id = pra.task_id and project_id = pra.project_id);

    l_unapproved_task_cnt NUMBER;
  BEGIN
      log_message('Inside PA_TASK_APPROVAL_PKG.Check_UsedTask_Status',3);
      p_return_status := 'S';
      OPEN C1;
      FETCH C1 INTO l_unapproved_task_cnt;
      CLOSE C1;

      IF l_unapproved_task_cnt > 0 THEN
         log_message('There are unapproved tasks for this change document.',3);
         p_return_status := 'E';
      END IF;
  END;

  -- This procedure is to put the Change Order status to 'CI_SUBMITTED'.
  -- These are eligible to be picked up by the Task Workflow process.
  PROCEDURE Mark_CO_Status(p_ci_id         IN NUMBER
                          ,p_msg_count     OUT NOCOPY NUMBER
                          ,p_msg_data      OUT NOCOPY VARCHAR2
                          ,p_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
       log_message('Inside PA_TASK_APPROVAL_PKG.Mark_CO_Status',3);
       p_return_status := 'S';
       UPDATE pa_control_items SET status_code = 'CI_SUBMITTED' WHERE ci_id = p_ci_id;
  EXCEPTION
       WHEN OTHERS THEN
        log_message('Inside WHEBN OTHERS exception of PA_TASK_APPROVAL_PKG.Mark_CO_Status',3);
         p_return_status := 'E';
         p_msg_data := SQLERRM;
  END;

END PA_TASK_APPROVAL_PKG;

/
