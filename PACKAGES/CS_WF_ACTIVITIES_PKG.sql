--------------------------------------------------------
--  DDL for Package CS_WF_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WF_ACTIVITIES_PKG" AUTHID CURRENT_USER as
/* $Header: cswfacts.pls 115.4 2002/11/26 05:29:11 rmanabat ship $ */

Audit_Comments	VARCHAR2(2000);

-- ***************************************************************************
-- *                                                                         *
-- *                         Service Request Item Type                       *
-- *                                                                         *
-- ***************************************************************************

------------------------------------------------------------------------------
-- Servereq_Selector
--   Item Type Callback Function. It sets the database session context before
--   the engine begins to execute process activities.
------------------------------------------------------------------------------

PROCEDURE Servereq_Selector
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	NOCOPY VARCHAR2
);


-- ---------------------------------------------------------------------------
-- Initialize_Request
--   This procedure corresponds to the INITIALIZE_REQUEST function activity.
--   It initializes the item attributes that will remain constant over the
--   duration of the workflow.
-- ---------------------------------------------------------------------------

  PROCEDURE Initialize_Request( itemtype     VARCHAR2,
                                itemkey      VARCHAR2,
                                actid        NUMBER,
                                funmode      VARCHAR2,
                                result   OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Update_Request_Info
--   This procedure corresponds to the UPDATE_REQUEST_INFORMATION function
--   activity.  It updates the service request item attributes with the
--   most current values in the database.  This procedure is used to keep
--   the item attributes in sync with the state of the database.
-- ---------------------------------------------------------------------------

  PROCEDURE Update_Request_Info( itemtype     VARCHAR2,
                                 itemkey      VARCHAR2,
                                 actid        NUMBER,
                                 funmode      VARCHAR2,
                                 result   OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Select_Supervisor
--   This procedure corresponds to the SELECT_SUPERVISOR function activity.
--   It gets the name, employee_id, and Workflow role name of the supervisor
--   of the current owner and updates the following corresponding item
--   attributes:  SUPERVISOR_NAME, SUPERVISOR_ID, and SUPERVISOR_ROLE.
-- ---------------------------------------------------------------------------

  PROCEDURE Select_Supervisor(  itemtype       VARCHAR2,
                                itemkey        VARCHAR2,
                                actid          NUMBER,
                                funmode        VARCHAR2,
                                result     OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Update_Owner
--   This procedure corresponds to the UPDATE_OWNER function activity.
--   It reassigns the service request to the employee specified by the given
--   employee ID.  It also updates the OWNER_ID, OWNER_NAME, and OWNER_ROLE
--   item attributes.
-- ---------------------------------------------------------------------------

  PROCEDURE Update_Owner( itemtype       VARCHAR2,
                          itemkey        VARCHAR2,
                          actid          NUMBER,
                          funmode        VARCHAR2,
                          result     OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Update_Status
--   This procedure corresponds to the UPDATE_STATUS function activity.  It
--   updates the status of the service request to the value given by the
--   STATUS activity attribute.
-- ---------------------------------------------------------------------------

  PROCEDURE Update_Status( itemtype      VARCHAR2,
                           itemkey       VARCHAR2,
                           actid         NUMBER,
                           funmode       VARCHAR2,
                           result    OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Validate_Response_Deadline
--   This procedure corresponds to the VALIDATE_RESPONSE_DEADLINE function
--   activity.  It verifies that the RESPONSE_DEADLINE item attribute is
--   valid.
-- ---------------------------------------------------------------------------

  PROCEDURE Validate_Response_Deadline( itemtype      VARCHAR2,
                                        itemkey	      VARCHAR2,
                                        actid         NUMBER,
                                        funmode	      VARCHAR2,
                                        result    OUT NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- Reset_Response_Deadline
--   This procedure corresponds to the RESET_RESPONSE_DEADLINE function
--   activity.  It resets the RESPONSE_DEADLINE item attribute back to NULL.
-- ---------------------------------------------------------------------------

  PROCEDURE Reset_Response_Deadline( itemtype     VARCHAR2,
                                     itemkey      VARCHAR2,
                                     actid        NUMBER,
                                     funmode      VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2 );


-- ***************************************************************************
-- *                                                                         *
-- *                           System: Error Item Type                       *
-- *                                                                         *
-- *  Following activities are used in the Service Request Error Process     *
-- *                                                                         *
-- ***************************************************************************


-- ---------------------------------------------------------------------------
-- Initialize_Errors
--   This procedure corresponds to the SERVEREQ_INIT_ERROR function activity.
--   It retrieves the error messages from the service request process that
--   errored out and store them in the item attributes of the error process.
-- ---------------------------------------------------------------------------

  PROCEDURE Initialize_Errors( itemtype      VARCHAR2,
                               itemkey       VARCHAR2,
                               actid         NUMBER,
                               funmode	     VARCHAR2,
                               result    OUT NOCOPY VARCHAR2 );


-- ***************************************************************************
-- *                                                                         *
-- *			Service Request Action Item Type		     *
-- *                                                                         *
-- ***************************************************************************

------------------------------------------------------------------------------
-- Action_Selector
--   Item Type Callback Function. It sets the database session context before
--   the engine begins to execute process activities.
------------------------------------------------------------------------------

PROCEDURE Action_Selector
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	NOCOPY VARCHAR2
);


------------------------------------------------------------------------------
-- Initialize_Action
--   This procedure corresponds to the INITIALIZE_ACTION function activity.
--   It initializes the item attributes that will remain constant over the
--   duration of the workflow.
------------------------------------------------------------------------------

/*PROCEDURE Initialize_Action
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	VARCHAR2
);*/


------------------------------------------------------------------------------
-- Is_Launched_From_Dispatch
--   This procedure corresponds to the IS_LAUNCHED_FROM_DISPATCH function
--   activity. It determines if the workflow process is launched from the
--   Field Service Dispatch window.
------------------------------------------------------------------------------

PROCEDURE Is_Launched_From_Dispatch
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	NOCOPY VARCHAR2
);


------------------------------------------------------------------------------
-- Get_Dispatcher_Info
--   This procedure corresponds to the GET_DISPATCHER_INFO function
--   activity. It updates the service request action item attributes with the
--   dispatcher information stored in the database.
------------------------------------------------------------------------------

/*PROCEDURE Get_Dispatcher_Info
( itemtype	IN	VARCHAR2,
  itemkey	IN	VARCHAR2,
  actid		IN	NUMBER,
  funcmode	IN	VARCHAR2,
  result	OUT	VARCHAR2
);*/


--- **** Following three procedures are added to support field service workflow
--  **** Tinoway integration

------------------------------------------------------------------------------
-- FS_INTERFACE
--   This procedure corresponds to the FIELD SERVICE INTERFACE function
--   activity. It creates/updates an interface record into the field service interface
--   table.
------------------------------------------------------------------------------


PROCEDURE IS_MOBILE_INSTALLED (
	itemtype	IN	VARCHAR2,
  	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	NOCOPY VARCHAR2
);

/*PROCEDURE IS_ACTION_CLOSED (
	itemtype	IN	VARCHAR2,
  	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	VARCHAR2
);*/

PROCEDURE IS_FS_INSERT (
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	NOCOPY VARCHAR2
);

/*PROCEDURE INSERT_FS_INTERFACE (
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	VARCHAR2
);

PROCEDURE UPDATE_FS_INTERFACE (
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
  	actid		IN	NUMBER,
  	funcmode	IN	VARCHAR2,
  	result		OUT	NOCOPY VARCHAR2
);

PROCEDURE SET_FS_WF_RESPONSE(
	p_incident_number  	IN NUMBER,
	p_action_number		IN NUMBER,
	p_response 		IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2
);*/



END CS_WF_ACTIVITIES_PKG;

 

/
