--------------------------------------------------------
--  DDL for Package AS_SALES_METH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_METH_WF" AUTHID CURRENT_USER AS
/* $Header: asxsmtws.pls 115.15 2003/12/23 10:10:49 sumahali ship $ */
	TYPE 	tasktbl IS TABLE OF jtf_tasks_b.task_id%TYPE
      	INDEX BY BINARY_INTEGER;
   	g_task_tab   tasktbl;
        empty_tbl    tasktbl;
  -- n BINARY_INTEGER := 0;
-- PROCEDURE start methodology
-- DESCRIPTION	This procedure is called to start standard  sales methodology workflow*/
PROCEDURE start_methodology (p_source_object_type_code 		IN 	VARCHAR2,
			     p_source_object_id  		IN 	NUMBER,
			     p_source_object_name 		IN 	VARCHAR2,
			     p_owner_id  			IN 	NUMBER,
			     p_owner_type_code 			IN 	VARCHAR2,
			     p_object_type_code 		IN 	VARCHAR2,
			     p_current_stage_id 		IN 	NUMBER,
			     p_next_stage_id 			IN 	NUMBER,
			     p_template_group_id 		IN 	VARCHAR2,
			     item_type 				IN 	VARCHAR2,
			     workflow_process 			IN 	VARCHAR2,
			     x_return_status 			OUT NOCOPY 	VARCHAR2,
                             x_msg_count		        OUT NOCOPY	NUMBER,
			     x_msg_data			        OUT NOCOPY 	VARCHAR2,
                             x_warning_message                  OUT NOCOPY     VARCHAR2
              ) ;
/* PROCEDURE check_task_for_current
--
-- Description	 checks for any mandatory tasks for current stage
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.         */
PROCEDURE Check_task_for_current (		itemtype		IN 	VARCHAR2,
		  			    	itemkey 		IN 	VARCHAR2,
					    	actid 			IN 	NUMBER,
					    	funcmode		IN 	VARCHAR2,
					    	result 	        	OUT NOCOPY 	VARCHAR2 ) ;
/* PROCEDURE check_task_for_next
--
-- Description	 checks for any  tasks created for next stage
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.*/
PROCEDURE Check_task_exist_for_next  (		itemtype		IN 	VARCHAR2,
						itemkey 		IN 	VARCHAR2,
						actid 			IN 	NUMBER,
						funcmode 		IN 	VARCHAR2,
						result 	        	OUT NOCOPY 	VARCHAR2 ) ;
/* PROCEDURE create_tasks
--
-- Description	 create tasks from templates and create references for 				those tasks
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.*/
PROCEDURE Create_tasks  (		itemtype	IN 	VARCHAR2,
					itemkey 	IN 	VARCHAR2,
					actid 		IN 	NUMBER,
					funcmode 	IN 	VARCHAR2,
					result 	        OUT NOCOPY 	VARCHAR2 ) ;
PROCEDURE Check_duration  (		itemtype	IN 	VARCHAR2,
					itemkey 	IN 	VARCHAR2,
					actid 		IN 	NUMBER,
					funcmode 	IN 	VARCHAR2,
					result 	        OUT NOCOPY 	VARCHAR2 ) ;
/* PROCEDURE create note for duration
--
-- Description	 create note based on previous node in the workflow.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.*/
PROCEDURE Create_note_for_duration  (	itemtype	IN 	VARCHAR2,
					itemkey 	IN 	VARCHAR2,
					actid 		IN 	NUMBER,
					funcmode 	IN 	VARCHAR2,
					result 	        OUT NOCOPY 	VARCHAR2 ) ;
/* PROCEDURE create note
--
-- Description	 create note based on previous node in the workflow.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.*/
PROCEDURE Create_note  (		itemtype	IN 	VARCHAR2,
					itemkey 	IN 	VARCHAR2,
					actid 		IN 	NUMBER,
					funcmode 	IN 	VARCHAR2,
					result 	        OUT NOCOPY 	VARCHAR2 ) ;
---------------
/* PROCEDURE create note for failure
--
-- Description	 create note if create task node fails.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.*/
PROCEDURE Create_note_for_tasks_failure  (		itemtype	IN 	VARCHAR2,
					itemkey 	IN 	VARCHAR2,
					actid 		IN 	NUMBER,
					funcmode 	IN 	VARCHAR2,
					result 	        OUT NOCOPY 	VARCHAR2 ) ;
---------------
END as_sales_meth_wf;


 

/
