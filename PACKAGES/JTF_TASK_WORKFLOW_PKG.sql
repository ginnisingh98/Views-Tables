--------------------------------------------------------
--  DDL for Package JTF_TASK_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_WORKFLOW_PKG" AUTHID CURRENT_USER as
/* $Header: jtftkwfs.pls 115.22 2002/12/04 23:38:35 cjang ship $ */

   jtf_task_item_type         CONSTANT VARCHAR2(8)      := 'JTFTASK';
   jtf_task_default_process   CONSTANT VARCHAR2(30)     := 'TASK_WORKFLOW';

   TYPE task_details_rec IS RECORD (
      task_attribute                VARCHAR2(80),
      old_value                     VARCHAR2(80),
      new_value                     VARCHAR2(80)
   );

   TYPE task_details_tbl IS TABLE OF task_details_rec
      INDEX BY BINARY_INTEGER;

   g_miss_task_details_tbl             task_details_tbl;



-- -----------------------------------------------------------------------
-- Is_Task_Item_Active
--   Determine whether the workflow process identified by the given process
--   ID for the given task is still active.
-- IN
--   p_task_id - task ID
--   p_wf_process_id - workflow process ID for this task ID
-- RETURN
--   'Y' if process is active, 'N' otherwise
-- -----------------------------------------------------------------------

   FUNCTION Is_Task_Item_Active
  			( p_task_id		IN	NUMBER,
    			  p_wf_process_id	IN	NUMBER )
  			 RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES (Is_Task_Item_Active, WNDS);

-- -------------------------------------------------------------------
-- Get_Workflow_Disp_Name
--   Get the display name of the given Workflow process.
--
--   Notes:  The p_raise_error flag determines what to do if the
--	     Workflow process does not exist.  If it's TRUE, then
--	     NO_DATA_FOUND exception will be raised; otherwise, no
--	     exception is raised and NULL is returned
--
--	     This is a stored function that can be invoked from a
-- 	     view script.
--
-- -------------------------------------------------------------------

  FUNCTION Get_Workflow_Disp_Name (
		p_item_type		IN VARCHAR2,
		p_process_name		IN VARCHAR2,
		p_raise_error		IN BOOLEAN    DEFAULT FALSE )
    RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (Get_Workflow_Disp_Name, WNDS, WNPS);


   PROCEDURE check_event (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   );

   FUNCTION default_task_details_tbl return task_details_tbl;

   PROCEDURE start_task_workflow (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id             IN       NUMBER,
      p_old_assignee_code   IN       VARCHAR2 DEFAULT NULL,
      p_old_assignee_id     IN       NUMBER DEFAULT NULL,
      p_new_assignee_code   IN       VARCHAR2 DEFAULT NULL,
      p_new_assignee_id     IN       NUMBER DEFAULT NULL,
      p_old_owner_code      IN       VARCHAR2 DEFAULT NULL,
      p_old_owner_id        IN       NUMBER DEFAULT NULL,
      p_new_owner_code      IN       VARCHAR2 DEFAULT NULL,
      p_new_owner_id        IN       NUMBER DEFAULT NULL,
      p_task_details_tbl    IN       task_details_tbl
            DEFAULT g_miss_task_details_tbl,
      p_event               IN       VARCHAR2,
/*
'ADD_ASSIGNEE',
'CHANGE_ASSIGNEE',
'DELETE_ASSIGNEE',
'CHANGE_OWNER',
'CHANGE_TASK_DETAILS'
*/
      p_wf_display_name     IN       VARCHAR2 DEFAULT NULL,
      p_wf_process          IN       VARCHAR2 DEFAULT 'TASK_WORKFLOW',
      p_wf_item_type        IN       VARCHAR2 DEFAULT 'JTFTASK',
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   );

   PROCEDURE abort_task_workflow (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id         IN   NUMBER,
      p_wf_process_id   IN   NUMBER,
      p_user_code       IN   VARCHAR2,
      p_user_id         IN   NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   );


END JTF_TASK_WORKFLOW_PKG;

 

/
