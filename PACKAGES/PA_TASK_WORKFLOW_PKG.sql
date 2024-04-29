--------------------------------------------------------
--  DDL for Package PA_TASK_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_WORKFLOW_PKG" AUTHID CURRENT_USER as
/* $Header: PATSKWFS.pls 120.2.12010000.1 2009/07/21 14:20:53 anuragar noship $ */


  TYPE g_deltask_rec IS RECORD (
          project_id             NUMBER(15),
          task_id                NUMBER(15),
          elem_ver_id            NUMBER(15),
          rec_ver_num            NUMBER(15),
          parent_struc_ver       NUMBER(15)
         );

  TYPE g_taskrec_tbl IS TABLE OF g_deltask_rec INDEX BY BINARY_INTEGER;

  g_del_taskrec g_taskrec_tbl;

    -- Cursor to fetch the project information.
    CURSOR c_proj_info(p_project_id NUMBER) IS
      SELECT  project_id                      project_id
             ,segment1                        project_number
             ,name                            project_name
             ,start_date                      start_date
             ,completion_date                 end_date
             ,project_type                    project_type
             ,carrying_out_organization_id    organization_id
             ,project_status_code             project_status
        FROM  PA_PROJECTS_ALL
        WHERE project_id = p_project_id;

    -- Cursor to fetch the task information.
    CURSOR c_task_info(p_project_id NUMBER, p_task_id NUMBER) IS
      SELECT ppa.project_id project_id,
             ppa.segment1 project_number,
             ppa.name project_name,
             ppe.proj_element_id task_id,
             ppe.element_number task_number,
             ppe.name task_name,
             ppe.task_approver_id task_app_chg_id,
             ppe.task_status,
             ppe.created_by,
	         ppe.manager_person_id,
             ppe.carrying_out_organization_id organization,
	         ppev.wbs_level task_wbs_level,
             ppev.parent_structure_version_id,
             ppevs.scheduled_start_date,
             ppevs.scheduled_finish_date scheduled_end_date,
	         ppe1.element_number parent_task_number,
	         ppe1.proj_element_id parent_task_id,
	         ppe1.name parent_task_name,
	         ppev1.wbs_level parent_task_wbs_level
	   FROM  PA_PROJ_ELEMENTS PPE,
	         PA_PROJ_ELEMENT_VERSIONS ppev,
             PA_PROJ_ELEM_VER_SCHEDULE ppevs,
	         PA_PROJ_ELEMENTS PPE1,
	         PA_PROJ_ELEMENT_VERSIONS ppev1,
			 PA_OBJECT_RELATIONSHIPS por,
             PA_PROJECTS_ALL ppa
	   WHERE ppa.project_id = p_project_id
       AND ppe.project_id = p_project_id
       AND ppe.link_task_flag = 'Y'
       AND ppe.type_id = 1
       AND ppev.proj_element_id = ppe.proj_element_id
       AND por.object_id_to1 = ppev.element_version_id
       AND ppevs.element_version_id(+) = ppev.element_version_id
       AND ppev1.project_id = p_project_id
       AND ((ppev1.element_version_id = por.object_id_from1)
	        OR (ppev1.parent_structure_version_id =por.object_id_from1
    			and por.RELATIONSHIP_SUBTYPE='STRUCTURE_TO_TASK'
				and ppe1.proj_element_id = ppe.proj_element_id))
       AND ppev1.parent_structure_version_id = ppev.parent_structure_version_id
       AND ppe1.proj_element_id= ppev1.proj_element_id
       AND por.object_type_to = 'PA_TASKS'
       AND por.relationship_type = 'S'
       AND ppev.financial_task_flag = 'Y'
       AND ppev1.financial_task_flag = 'Y'
       AND ppev.source_object_id = ppev1.source_object_id
       AND ppe.proj_element_id = p_task_id;

     CURSOR c_user_info(p_user_id NUMBER) IS
      SELECT  f.user_id user_id
             ,f.user_name user_name
             ,e.first_name||' '||e.last_name full_name
      FROM   FND_USER f
            ,PA_EMPLOYEES e
      WHERE  f.user_id = p_user_id
      AND    f.employee_id = e.person_id;

  /*---------------------------------------------------------------------------------------------------------
    -- This is the main procedure that invokes the Task workflow. This is being called from Task Approval
    -- Workflow package.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --  p_item_type              VARCHAR2        YES       Workflow Item Type.
    --  p_process                VARCHAR2        YES       Name of the process in workflow
    --                                                     to run.
    --  p_project_id             NUMBER          YES       Identification of the project
    --  p_task_id                NUMBER          YES       Task Identifier
    --  p_parent_struc_ver       NUMBER          YES       Parent task structure version id
    --  p_approver_user_id       NUMBER          YES       Approver user Id
    --  p_ci_id                  NUMBER          YES       Change document Id
    -- Out parameters
    -- Parameters                Type           Required  Description
    --  x_error_stage            VARCHAR2       YES       To identify which flow of the code
    --                                                    caused the error.
    --  x_err_code               NUMBER         YES       To identify which part of the code
    --                                                    has been errored out.
    --  x_error_stack            VARCHAR2       YES       Holds the error message code
  ----------------------------------------------------------------------------------------------------------*/
    PROCEDURE Start_Task_Aprv_Wf (p_item_type            IN VARCHAR2
                                 ,p_process              IN VARCHAR2
                                 ,p_project_id           IN NUMBER
                                 ,p_task_id              IN NUMBER
                                 ,p_parent_struc_ver     IN NUMBER
                                 ,p_approver_user_id     IN NUMBER
                                 ,p_ci_id                IN NUMBER
                                 ,x_err_stack IN OUT NOCOPY VARCHAR2
                                 ,x_err_stage IN OUT NOCOPY VARCHAR2
                                 ,x_err_code OUT NOCOPY NUMBER);


  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is being invoked from Task workflow. This is to identify whether the task submitted for
    -- approval is a child task of another task or is a main task itself. Based on this, workflow decides on
    -- which method to invoke.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/

    PROCEDURE Is_Child_Task(itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This procedure is being invoked from Task workflow. This is to identify whether parent task of
    -- the task submitted for approval is already approved or not. Based on this, workflow decides
    -- whether to Raise notification for task approval or to update task status as 'Pending' for its parent
    -- task approval.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/

    PROCEDURE Is_Parent_Task_Approved
                          (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

    PROCEDURE Append_Varchar_To_Clob(p_varchar IN VARCHAR2
                                    ,p_clob IN OUT NOCOPY CLOB);

    PROCEDURE Show_Task_Notify_Preview (document_id IN VARCHAR2
                                      ,display_type IN VARCHAR2
                                      ,document IN OUT NOCOPY CLOB
                                      ,document_type IN OUT NOCOPY VARCHAR2);

    -- This procedure is to generate the workflow notification dynamically
    PROCEDURE Generate_Task_Aprv_Notify
                              (p_item_type IN VARCHAR2
                              ,p_item_key  IN VARCHAR2
                              ,p_project_id IN NUMBER
                              ,p_org_id    IN NUMBER
                              ,p_task_id   IN NUMBER
                              ,p_parent_struc_ver IN NUMBER
                              ,p_ci_id     IN NUMBER
                              ,p_cd_yn     IN VARCHAR2 := 'Y'
                              ,x_content_id OUT NOCOPY NUMBER);

  /*---------------------------------------------------------------------------------------------------------
    -- This method is invoked from Task workflow based on the action choosen from the task approval notification.
    -- This procedure in turn calls PA_TASKS_MAINT_PUB.CREATE_TASK to create entries into the pa_tasks table
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/
    PROCEDURE Post_Task (itemtype IN VARCHAR2
                        ,itemkey IN VARCHAR2
                        ,actid IN NUMBER
                        ,funcmode IN VARCHAR2
                        ,resultout OUT NOCOPY VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This method is invoked from Task workflow if the parent task of the submitted task is not yet approved.
    -- This procedure marks task as 'Pending' for its parent task approval in pa_proj_elements.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/
    PROCEDURE Update_Task_Status(itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This method is invoked from Task workflow based on the action choosen from the task approval notification.
    -- We call PA_TASK_PUB1.Delete_Task_Version to delete the submitted task and its child tasks (if exists).
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/

    PROCEDURE Delete_Task(itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

    FUNCTION show_error(p_error_stack   IN VARCHAR2,
                        p_error_stage   IN VARCHAR2,
                        p_error_message IN VARCHAR2,
                        p_arg1          IN VARCHAR2 DEFAULT null,
                        p_arg2          IN VARCHAR2 DEFAULT null) RETURN VARCHAR2;


  /*---------------------------------------------------------------------------------------------------------
    -- This method is invoked from Change order workflow to verify the task used is already approved or not.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/
    PROCEDURE Verify_Task_Status
                          (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This method is invoked from Change order workflow to mark change order status to PENDING, in case
    -- if the task used in this Change Order is not yet approved.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/
    PROCEDURE Mark_CO_Status
                          (itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

  /*---------------------------------------------------------------------------------------------------------
    -- This method is being invoked from Tasks workflow to verify the if the submitted task is last task in
    -- the hierarchy of the task for approval, and if so, raise notification for any change document which uses
    -- this task.
    -- Input parameters
    -- Parameters                Type           Required  Description
    --   itemtype                  VARCHAR2       YES     Workflow Item type
    --   itemkey                   VARCHAR2       YES     Item Key -> Unique identifier of the run
    --   actid                     NUMBER         YES     Action Id
    --   funcmode                  VARCHAR2       YES     Function Mode
    -- Out parameters
    -- Parameters                Type           Required  Description
    --   resultout                 VARCHAR2       YES     Result of the particular function
   ----------------------------------------------------------------------------------------------------------*/
    PROCEDURE Is_Last_Task(itemtype IN VARCHAR2
                          ,itemkey IN VARCHAR2
                          ,actid IN NUMBER
                          ,funcmode IN VARCHAR2
                          ,resultout OUT NOCOPY VARCHAR2);

END PA_TASK_WORKFLOW_PKG;

/
