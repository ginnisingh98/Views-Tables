--------------------------------------------------------
--  DDL for Package FND_SVC_COMPONENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SVC_COMPONENT" authid current_user as
/* $Header: AFSVCMPS.pls 120.1 2005/07/02 04:18:47 appldev ship $ */

--
-- Package variables
--
pv_Package_Name VARCHAR2(30)           := 'FND_SVC_COMPONENT';
pv_Connection_Name_Prefix VARCHAR2(30) := 'SVC';

pv_Container_Status_Running varchar2(30) := 'RUNNING';
pv_Container_Status_Stopping varchar2(30) := 'STOPPING';
pv_Container_Status_Stopped varchar2(30) := 'STOPPED';

pv_callerContextUser varchar2(30)	:= 'USER';
pv_callerContextAdmin varchar2(30)	:= 'ADMIN';
pv_callerContext varchar2(30)		:= pv_CallerContextUser;

pv_retOtherComponentError number 	:= 7000;
pv_retInvalidComponentState number 	:= 7001;
pv_retContainerNotRunning number 	:= 7002;

--
-- Keep the following constants in sync with those in
-- oracle.apps.oam.common.OAMConstants
--
pv_OAM_Status_Down         NUMBER := 0;
pv_OAM_Status_Warning      NUMBER := 1;
pv_OAM_Status_Up           NUMBER := 2;
pv_OAM_Status_NA           NUMBER := 3;
pv_OAM_Status_Not_Started  NUMBER := 5;
pv_OAM_Status_Cancel       NUMBER := 7;

--
-- Keep the following constants in sync with those in
-- oracle.apps.cp.gsc.SvcComponentContainerInterface
--
pv_Key_Container_Log_Level VARCHAR2(30) := 'SVC_CONTAINER_LOG_LEVEL';

--
-- Keep the following constants in sync with those in
-- oracle.apps.cp.gsc.server.SvcComponentEO
--
pv_Container_Type_GSM VARCHAR2(30)     := 'GSM';
pv_Container_Type_Servlet VARCHAR2(30) := 'SERV';

pv_Status_Not_Configured varchar2(30) 	:= 'NOT_CONFIGURED';
pv_Status_Starting varchar2(30) 	:= 'STARTING';
pv_Status_Running varchar2(30) 		:= 'RUNNING';
pv_Status_Suspending varchar2(30) 	:= 'SUSPENDING';
pv_Status_Suspended varchar2(30) 	:= 'SUSPENDED';
pv_Status_Resuming varchar2(30) 	:= 'RESUMING';
pv_Status_Stopping varchar2(30) 	:= 'STOPPING';
pv_Status_Stopped varchar2(30) 		:= 'STOPPED';
pv_Status_Stopped_Error varchar2(30) 	:= 'STOPPED_ERROR';
pv_Status_Deactivated_User varchar2(30) := 'DEACTIVATED_USER';
pv_Status_Deactivated_System varchar2(30):= 'DEACTIVATED_SYSTEM';

pv_Startup_Mode_Automatic varchar2(30) 	:= 'AUTOMATIC';
pv_Startup_Mode_Manual varchar2(30) 	:= 'MANUAL';
pv_Startup_Mode_On_Demand varchar2(30) 	:= 'ON_DEMAND';

pv_opStart varchar2(30) 		:= 'START';
pv_opStop varchar2(30) 			:= 'STOP';
pv_opSuspend varchar2(30) 		:= 'SUSPEND';
pv_opResume varchar2(30) 		:= 'RESUME';
pv_opRefresh varchar2(30) 		:= 'REFRESH';
pv_opUpdate varchar2(30) 		:= 'UPDATE';
pv_opDelete varchar2(30) 		:= 'DELETE';
pv_opGeneric varchar2(30) 		:= 'GENERIC';

pv_Event_Start varchar2(100) 		:= 'oracle.apps.fnd.cp.gsc.SvcComponent.start';
pv_Event_Stop varchar2(100) 		:= 'oracle.apps.fnd.cp.gsc.SvcComponent.stop';
pv_Event_Suspend varchar2(100) 		:= 'oracle.apps.fnd.cp.gsc.SvcComponent.suspend';
pv_Event_Resume varchar2(100) 		:= 'oracle.apps.fnd.cp.gsc.SvcComponent.resume';
pv_Event_Refresh varchar2(100) 		:= 'oracle.apps.fnd.cp.gsc.SvcComponent.refresh';

pv_adminStatusCompleted varchar2(30) 	:= 'COMPLETED';
pv_adminStatusSkipped varchar2(30) 	:= 'SKIPPED';
pv_adminStatusErrored varchar2(30) 	:= 'ERRORER';

PROCEDURE Delete_Request
          ( p_component_request_id IN NUMBER);

FUNCTION Get_OAM_Rolled_Status_By_Type
         ( p_component_type    IN VARCHAR2 default NULL)
         RETURN NUMBER;

PROCEDURE Execute_Request
          ( p_component_request_id IN NUMBER);

PROCEDURE Insert_Param_Vals
          ( p_component_type    IN VARCHAR2
          , p_component_id      IN NUMBER);

PROCEDURE Validate_Operation
		(p_Component_Id        IN NUMBER,
		p_Control_Operation   IN VARCHAR2,
		p_retcode	OUT NOCOPY NUMBER,
		p_errbuf	OUT NOCOPY VARCHAR2);

PROCEDURE Get_Container_Status
         ( p_container_type     IN VARCHAR2
         , p_container_name     IN VARCHAR2
	 , p_container_status	OUT NOCOPY VARCHAR2
	 , p_process_id		OUT NOCOPY NUMBER);

PROCEDURE Name_Container_Session
          ( p_container_type IN VARCHAR2
          , p_container_name IN VARCHAR2
	  , p_process_id IN NUMBER
	  , p_action_name IN VARCHAR2 default null);

FUNCTION Retrieve_Parameter_Value
          ( p_parameter_name    IN VARCHAR2
          , p_component_id      IN NUMBER)
         RETURN VARCHAR2;

PROCEDURE Reset_Container_Components
         ( p_container_type     IN VARCHAR2
         , p_container_name     IN VARCHAR2);

Function Get_Current_Status (p_Component_Id in NUMBER) return varchar2;


-- Start of comments
--	API name	: Start
--	Type		: Group
--	Purpose		: Performs startup control operation on an component
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_Component_Id	NUMBER 	Required
--				Internally generated and unique id for an
--				component
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments

Procedure Start_Component (p_Component_Id in number,
		p_retcode	OUT NOCOPY NUMBER,
		p_errbuf	OUT NOCOPY VARCHAR2
		);

-- Start of comments
--	API name	: Stop
--	Type		: Group
--	Purpose		: Performs stop control operation on an component
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_Component_Id 	NUMBER 	Required
--				Internally generated and unique id for an
--				component
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
--
-- End of comments

Procedure Stop_Component	(p_Component_Id in NUMBER,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);


-- Start of comments
--	API name	: Suspend
--	Type		: Group
--	Purpose		: Performs suspend control operation on an component.
--			  Stops the component instance from processing any
--			  messages.  The component instance
--			  may maintains its connection to the remote system
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_Component_Id 	NUMBER 	Required
--				Internally generated and unique id for an
--				component
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Suspend_Component (p_Component_Id in NUMBER,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

-- Start of comments
--	API name	: Resume
--	Type		: Group
--	Purpose		: Performs resume control operation on an component.
--			  Allows the component instance to process messages
--	Pre-reqs	: None.
--	Parameters	:
--
--	IN		:
--			  p_Component_Id 	NUMBER 	Required
--				Internally generated and unique id for an
--				component
--	OUT		:
--			  p_retcode   		NUMBER
--				This output argument is to indicate if the API
-- 				call has been made sucessfully.  The value of
--				0 means the call was made sucessfully, while
--				any non-zero value means otherwise.  The
-- 				caller must examine this parameter value after
--				the call is completed.  If the value is 0, the
-- 				caller routine must do commit, otherwise, the
-- 				caller routine must do a rollback
--			  p_errbuf   		VARCHAR2
--				The decription of the error encountered	when
--				the return_code is not 0
--
--	Version		: Current version	11.5
--	Notes		: None
--
-- End of comments
Procedure Resume_Component (p_Component_Id in NUMBER,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);


Procedure Refresh_Component (p_Component_Id in NUMBER,
				p_params	IN VARCHAR2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

Procedure Generic_Operation (p_Component_Id in NUMBER,
				p_Control_Event	IN VARCHAR2,
				p_params	IN VARCHAR2,
				p_retcode	OUT NOCOPY NUMBER,
				p_errbuf	OUT NOCOPY VARCHAR2
				);

PROCEDURE Refresh_Container_Log_Level
         ( p_container_type     IN VARCHAR2,
           p_container_name     IN VARCHAR2,
           p_log_level		IN NUMBER,
           p_retcode		OUT NOCOPY NUMBER,
           p_errbuf		OUT NOCOPY VARCHAR2);

PROCEDURE Verify_Container
         ( p_container_type     IN VARCHAR2
         , p_container_name     IN VARCHAR2);

PROCEDURE Verify_All_Containers ;

--
-- Update_Status
--   Procedure to update the status of the given Service Component
--   If the component staus is either STOPPED_ERROR or DEACTIVATED_SYSTEM
--   then a System Alert is raised with the pre-defined message.
--   For more information, refer Bug 3786007.
--
PROCEDURE Update_Status (p_Component_Id      IN NUMBER,
			 p_Status            IN VARCHAR2,
			 p_Status_Info       IN VARCHAR2 default null,
			 p_Last_Updated_By   IN NUMBER   default 0,
			 p_Last_Update_Login IN NUMBER   default null);

--
-- Get_Component_Status
--   Function that returns the current status of the given Component
--   after verifying its Container status
-- IN
--   p_Component_Name     - Component Name
--
FUNCTION Get_Component_Status
         (p_Component_Name IN VARCHAR2)
         RETURN VARCHAR2;

END FND_SVC_COMPONENT;

 

/

  GRANT EXECUTE ON "APPS"."FND_SVC_COMPONENT" TO "EM_OAM_MONITOR_ROLE";
