--------------------------------------------------------
--  DDL for Package CS_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WORKFLOW_PKG" AUTHID CURRENT_USER as
/* $Header: cswkflws.pls 115.7 2002/11/25 19:46:15 rmanabat ship $ */

-- -------------------------------------------------------------------
-- Is_Servereq_Item_Active
--   Given a service request number and a workflow process ID, this
--   function returns whether or not the workflow process for this
--   service request is active.
--
--   Note:  This is a stored function that can be invoked from a
-- 	    view script.
--
-- Returns:  'Y' - Process is active
--	     'N' - Otherwise
-- -------------------------------------------------------------------

  FUNCTION Is_Servereq_Item_Active (
		p_request_number	  IN VARCHAR2,
		p_wf_process_id 	  IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (Is_Servereq_Item_Active, WNDS);


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


-- -------------------------------------------------------------------
-- Start_Servereq_Workflow
--   This procedure will launch a workflow process for the given
--   service request.
--
-- -------------------------------------------------------------------

  PROCEDURE Start_Servereq_Workflow (
		p_request_number	  IN VARCHAR2,
		p_wf_process_name	  IN VARCHAR2,
		p_initiator_user_id	  IN NUMBER,
		p_initiator_resp_id	  IN NUMBER   := NULL,
		p_initiator_resp_appl_id  IN NUMBER   := NULL,
		p_workflow_process_id	 OUT NOCOPY NUMBER );


-- -------------------------------------------------------------------
-- Abort_Servereq_Workflow
--   This procedure will abort an active service request workflow
--   process and send a notification to the current owner of the
--   request.
-- -------------------------------------------------------------------

  PROCEDURE Abort_Servereq_Workflow (
		p_request_number	  IN VARCHAR2,
		p_wf_process_id		  IN NUMBER,
		p_user_id	  	  IN NUMBER );


----------------------------------------------------------------------
-- Is_Action_Item_Active
--   Given a service request id, an action number and a workflow
--   process ID, this function returns whether or not the workflow
--   process for this service request action is active.
--
--   Note:  This is a stored function that can be invoked from a
--          view script.
--
-- Returns:  'Y' - Process is active
--	     'N' - Otherwise
----------------------------------------------------------------------

FUNCTION Is_Action_Item_Active
( p_request_id		IN NUMBER,
  p_action_number	IN NUMBER,
  p_wf_process_id	IN NUMBER
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Is_Action_Item_Active, WNDS);


----------------------------------------------------------------------
-- Start_Action_Workflow
--   This procedure will launch a workflow process for the given
--   service request action.
--
----------------------------------------------------------------------

PROCEDURE Start_Action_Workflow
( p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_initiator_user_id		IN	NUMBER,
  p_initiator_resp_id		IN	NUMBER   := NULL,
  p_initiator_resp_appl_id	IN	NUMBER   := NULL,
  p_launched_by_dispatch	IN	VARCHAR2 := 'N',
  p_workflow_process_id		OUT	NOCOPY NUMBER
);


----------------------------------------------------------------------
-- Abort_Action_Workflow
--   This procedure will abort an active service request action
--   workflow process and send a notification to the current assignee
--   of the request action.
----------------------------------------------------------------------

PROCEDURE Abort_Action_Workflow
( p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_wf_process_id		IN	NUMBER,
  p_abort_user_id		IN	NUMBER,
  p_launched_by_dispatch	OUT	NOCOPY VARCHAR2
);


PROCEDURE Start_Servereq_Workflow (
                p_request_number          IN VARCHAR2,
                p_wf_process_name         IN VARCHAR2,
                p_initiator_user_id       IN NUMBER,
                p_initiator_resp_id       IN NUMBER   := NULL,
                p_initiator_resp_appl_id  IN NUMBER   := NULL,
                p_workflow_process_id    OUT NOCOPY NUMBER,
                x_msg_count              OUT NOCOPY NUMBER,
                x_msg_data               OUT NOCOPY VARCHAR2 );


PROCEDURE Abort_Servereq_Workflow (
                p_request_number          IN VARCHAR2,
                p_wf_process_id           IN NUMBER,
                p_user_id                 IN NUMBER,
                x_msg_count               OUT NOCOPY NUMBER,
                x_msg_data                OUT NOCOPY VARCHAR2 );


END CS_Workflow_PKG;

 

/
