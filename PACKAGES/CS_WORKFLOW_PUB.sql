--------------------------------------------------------
--  DDL for Package CS_WORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_WORKFLOW_PUB" AUTHID CURRENT_USER AS
/* $Header: cspwfs.pls 120.0 2005/10/26 18:02:07 aneemuch noship $ */

-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name    : Launch_Servereq_Workflow
--  Type        : Public
--  Description : Launch a Workflow process for the given service request.
--  Pre-reqs    : Profile option Service:Workflow Administrator must be set before
--                  calling this procedure.
--                p_wf_process_name must be a valid Workflow process based on the
--                  Service Request item type.
--  Parameters  :
--     p_api_version              IN NUMBER     Required
--     p_init_msg_list            IN VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                   IN VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_return_status           OUT VARCHAR2   Required  Length  = 1
--     p_msg_count               OUT NUMBER     Required
--     p_msg_data                OUT VARCHAR2   Required  Length  = 2000
--     p_request_number           IN VARCHAR2   Required
--     p_initiator_user_id        IN NUMBER     Optional  Default NULL
--     p_initiator_resp_id        IN NUMBER     Optional  Default NULL
--     p_initiator_resp_appl_id   IN NUMBER     Optional  Default NULL
--     p_itemkey                 OUT VARCHAR2   Required  Length  = 240
--     p_nowait                   IN VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--  Version     : Initial Version     1.0
--
--  Notes       : This procedure will try to lock the service request record because
--                  it needs to update the workflow_process_id column.  The NOWAIT
--                  option can be specified by setting the p_nowait parameter.
--
--                If there is an active Workflow process for this service request,
--                  this procedure will return an error.  Currently, only one active
--                  workflow process is allowed for each service request.
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Launch_Servereq_Workflow (
                p_api_version             IN NUMBER,
                p_init_msg_list           IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_commit                  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_return_status          OUT NOCOPY VARCHAR2,
                p_msg_count              OUT NOCOPY NUMBER,
                p_msg_data               OUT NOCOPY VARCHAR2,
                p_request_number          IN VARCHAR2,
                p_initiator_user_id       IN NUMBER    DEFAULT NULL,
                p_initiator_resp_id       IN NUMBER    DEFAULT NULL,
                p_initiator_resp_appl_id  IN NUMBER    DEFAULT NULL,
                p_itemkey                OUT NOCOPY VARCHAR2,
                p_nowait                  IN VARCHAR2  DEFAULT FND_API.G_FALSE );


-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name    : Cancel_Servereq_Workflow
--  Type        : Public
--  Description : Abort an active Workflow process for the given service
--                request and send a notification to the current owner of the
--                request.
--  Pre-reqs    :
--  Parameters  :
--     p_api_version              IN NUMBER     Required
--     p_init_msg_list            IN VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                   IN VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_return_status           OUT VARCHAR2   Required  Length  = 1
--     p_msg_count               OUT NUMBER     Required
--     p_msg_data                OUT VARCHAR2   Required  Length  = 2000
--     p_request_number           IN VARCHAR2   Required
--     p_wf_process_id            IN NUMBER     Required
--     p_user_id                  IN NUMBER     Required
--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Cancel_Servereq_Workflow (
                p_api_version             IN NUMBER,
                p_init_msg_list           IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_commit                  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_return_status          OUT NOCOPY VARCHAR2,
                p_msg_count              OUT NOCOPY NUMBER,
                p_msg_data               OUT NOCOPY VARCHAR2,
                p_request_number          IN VARCHAR2,
                p_wf_process_id           IN NUMBER,
                p_user_id                 IN NUMBER );


-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Decode_Servereq_Itemkey
--  Type	: Public
--  Description	: Given an encoded Service Request itemkey, this procedure
--  		  will return the components of the key - service request
--	 	  number, and workflow process ID.
--  Pre-reqs	: None
--  Parameters	:
--     p_api_version		  IN NUMBER	Required
--     p_init_msg_list		  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_return_status		 OUT VARCHAR2   Required  Length  = 1
--     p_msg_count		 OUT NUMBER     Required
--     p_msg_data		 OUT VARCHAR2   Required  Length  = 2000
--     p_itemkey		  IN VARCHAR2   Requried
--     p_request_number		 OUT VARCHAR2   Required  Length  = 64
--     p_wf_process_id		 OUT NUMBER	Required
--
--  Version	: Initial Version	1.0
--
--  Notes:	:
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Decode_Servereq_Itemkey(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_itemkey		  IN VARCHAR2,
		p_request_number	 OUT NOCOPY VARCHAR2,
		p_wf_process_id		 OUT NOCOPY NUMBER );


-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Encode_Servereq_Itemkey
--  Type	: Public
--  Description	: Given a service request number and a Workflow process
--		  ID, this procedure will construct the corresponding
--		  itemkey for the Service Request item type.
--  Pre-reqs	: None
--  Parameters	:
--     p_api_version		  IN NUMBER	Required
--     p_init_msg_list		  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_return_status		 OUT VARCHAR2   Required  Length  = 1
--     p_msg_count		 OUT NUMBER     Required
--     p_msg_data		 OUT VARCHAR2   Required  Length  = 2000
--     p_request_number		  IN VARCHAR2   Required
--     p_wf_process_id		  IN NUMBER	Required
--     p_itemkey		 OUT VARCHAR2   Requried  Length  = 240
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either p_request_number or p_wf_process_id must be non-NULL.
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Encode_Servereq_Itemkey(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_request_number	  IN VARCHAR2,
		p_wf_process_id		  IN NUMBER,
		p_itemkey		 OUT NOCOPY VARCHAR2 );



-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Get_Employee_Role
--  Type	: Public
--  Description	: Get the Workflow role name of the given employee
--  Pre-reqs	: None
--  Parameters	:
--     p_api_version		  IN NUMBER	Required
--     p_init_msg_list		  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_return_status		 OUT VARCHAR2   Required  Length  = 1
--     p_msg_count		 OUT NUMBER     Required
--     p_msg_data		 OUT VARCHAR2   Required  Length  = 2000
--     p_employee_id		  IN NUMBER	Optional  Default = NULL
--     p_emp_last_name		  IN VARCHAR2   Optional  Default = NULL
--     p_emp_first_name		  IN VARCHAR2   Optional  Default = NULL
--     p_role_name		 OUT VARCHAR2	Required  Length  = 100
--     p_role_display_name	 OUT VARCHAR2	Required  Length  = 240
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either employee ID or first/last name must be non-null.
--
--		  If both ID and name are passed in, the ID will be used.  If the
--                name is used and it does NOT uniquely identify an employee, an
--                error will be returned.
--
--		  If the employee is not defined in the Workflow directory
--		  views, the return values p_role_name and p_role_display_name
--		  will be NULL; however, the return status will still be
--                SUCCESS.
--
--		  If the employee is mapped to more than one Workflow role,
--		  then the first one fetched will be returned
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Get_Employee_Role (
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_employee_id  		  IN NUMBER    DEFAULT NULL,
		p_emp_last_name		  IN VARCHAR2  DEFAULT NULL,
		p_emp_first_name	  IN VARCHAR2  DEFAULT NULL,
		p_role_name		 OUT NOCOPY VARCHAR2,
		p_role_display_name	 OUT NOCOPY VARCHAR2 );


-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Get_Emp_Supervisor
--  Type	: Public
--  Description	: Get the supervisor information of the given employee.
--		  Returns the employee ID, Workflow role name, and
--		  Workflow display name of the supervisor.
--  Pre-reqs	: None
--  Parameters	:
--     p_api_version		  IN NUMBER	Required
--     p_init_msg_list		  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_return_status		 OUT VARCHAR2   Required  Length  = 1
--     p_msg_count		 OUT NUMBER     Required
--     p_msg_data		 OUT VARCHAR2   Required  Length  = 2000
--     p_employee_id		  IN NUMBER	Optional  Default = NULL
--     p_emp_last_name		  IN VARCHAR2	Optional  Default = NULL
--     p_emp_first_name		  IN VARCHAR2   Optional  Default = NULL
--     p_supervisor_emp_id	 OUT NUMBER	Required
--     p_supervisor_role	 OUT VARCHAR2	Required  Length  = 100
--     p_supervisor_name	 OUT VARCHAR2   Required  Length  = 240
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either employee ID or first/last name must be non-null.
--
--		  If both ID and name are passed in, the ID will be used.  If the
--                name is used and it does NOT uniquely identify an employee, an
--                error will be returned.
--
--		  If the employee does not have a supervisor, the output
--		  variables for the supervisor information will be set to NULL;
--                however, the return status of the procedure will still be set
--                to SUCCESS.
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Get_Emp_Supervisor(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_employee_id		  IN NUMBER    DEFAULT NULL,
		p_emp_last_name		  IN VARCHAR2  DEFAULT NULL,
		p_emp_first_name	  IN VARCHAR2  DEFAULT NULL,
		p_supervisor_emp_id 	 OUT NOCOPY NUMBER,
		p_supervisor_role	 OUT NOCOPY VARCHAR2,
		p_supervisor_name 	 OUT NOCOPY VARCHAR2 );


-- --------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Get_Emp_Fnd_User_ID
--  Type	: Public
--  Description	: Get the FND user ID of the given employee
--  Pre-reqs	: None
--  Parameters	:
--     p_api_version		  IN NUMBER	Required
--     p_init_msg_list		  IN VARCHAR2	Optional  Default = FND_API.G_FALSE
--     p_return_status		 OUT VARCHAR2   Required  Length  = 1
--     p_msg_count		 OUT NUMBER     Required
--     p_msg_data		 OUT VARCHAR2   Required  Length  = 2000
--     p_employee_id		  IN NUMBER	Optional  Default = NULL
--     p_emp_last_name		  IN VARCHAR2	Optional  Default = NULL
--     p_emp_first_name		  IN VARCHAR2   Optional  Default = NULL
--     p_fnd_user_id		 OUT NUMBER	Required
--
--  Version	: Initial Version	1.0
--
--  Notes:	: Either employee ID or first/last name must be non-null.
--
--		  If both ID and name are passed in, the ID will be used.  If the
--                name is used and it does NOT uniquely identify an employee, an
--                error will be returned.
--
--		  If the employee maps to more than one FND user, then the
--		  first one fetched will be returned.
--
--		  If the given employee is not a FND user, then NULL will be
--		  returned; however, the return status will still be set to
--                SUCCESS.
--
-- End of comments
-- --------------------------------------------------------------------------------

  PROCEDURE Get_Emp_Fnd_User_ID(
		p_api_version		  IN NUMBER,
		p_init_msg_list		  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
		p_employee_id	 	  IN NUMBER    DEFAULT NULL,
		p_emp_last_name		  IN VARCHAR2  DEFAULT NULL,
		p_emp_first_name	  IN VARCHAR2  DEFAULT NULL,
		p_fnd_user_id 		 OUT NOCOPY NUMBER );


-------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Launch_Action_Workflow
--  Type	: Public
--  Function	: Launch a Workflow process for the given service request
--		  action.
--  Pre-reqs    : Profile option Service:Workflow Administrator must be set
--		  before calling this procedure.
--                The type of the given service request action must be
--		  associated with a valid Workflow process based on the
--		  Service Request Action item type.
--  Parameters	:
--  IN		:	p_api_version		IN NUMBER	Required
--			p_init_msg_list		IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			p_commit		IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			p_request_id		IN NUMBER	Required
--			p_action_number		IN NUMBER	Required
--			p_initiator_user_id	IN NUMBER	Optional
--				Default = NULL
--			p_initiator_resp_id	IN NUMBER	Optional
--				Default = NULL
--			p_initiator_resp_appl_id IN NUMBER	Optional
--				Default = NULL
--			p_launched_by_dispatch	IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			p_nowait		IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--
--  OUT		:	p_return_status		OUT	VARCHAR2(1)
--			p_msg_count		OUT	NUMBER
--			p_msg_data		OUT	VARCHAR2(2000)
--			p_itemkey		OUT	VARCHAR2(240)
--
--  Version	: Initial Version	1.0
--
--  Notes	: This procedure will try to lock the service request action
--		  record because it needs to update the workflow_process_id
--		  column. The NOWAIT option can be specified by setting the
--		  p_nowait parameter.
--
--		  If there is an active Workflow process for this service
--		  request action, this procedure will return an error.
--		  Currently, only one active workflow process is allowed for
--		  each service request action.
--
-- End of comments
-------------------------------------------------------------------------------

/*PROCEDURE Launch_Action_Workflow
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
  p_return_status		OUT	VARCHAR2,
  p_msg_count			OUT	NUMBER,
  p_msg_data			OUT	VARCHAR2,
  p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_initiator_user_id		IN	NUMBER   := NULL,
  p_initiator_resp_id		IN	NUMBER   := NULL,
  p_initiator_resp_appl_id	IN	NUMBER   := NULL,
  p_launched_by_dispatch	IN	VARCHAR2 := FND_API.G_FALSE,
  p_nowait			IN	VARCHAR2 := FND_API.G_FALSE,
  p_itemkey			OUT	VARCHAR2
);*/


-------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Cancel_Action_Workflow
--  Type	: Public
--  Function	: Abort an active Workflow process for the given service
--		  request action and send a notification to the current
--		  assignee of the request action. If a dispatch notification
--		  was sent to the dispatcher, also send an abort notification.
--  Pre-reqs	: None.
--  Parameters	:
--  IN		:	p_api_version		IN NUMBER	Required
--			p_init_msg_list		IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			p_commit		IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			p_request_id		IN NUMBER	Required
--			p_action_number		IN NUMBER	Required
--			p_wf_process_id		IN NUMBER	Required
--			p_abort_user_id		IN NUMBER	Required
--
--  OUT		:	p_return_status		OUT	VARCHAR2(1)
--			p_msg_count		OUT	NUMBER
--			p_msg_data		OUT	VARCHAR2(2000)
--			p_launched_by_dispatch	OUT	VARCHAR2(1)
--
--  Version	: Initial Version	1.0
--
--  Notes	:
--
-- End of comments
-------------------------------------------------------------------------------

PROCEDURE Cancel_Action_Workflow
( p_api_version			IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit			IN	VARCHAR2 := FND_API.G_FALSE,
  p_return_status		OUT	NOCOPY VARCHAR2,
  p_msg_count			OUT	NOCOPY NUMBER,
  p_msg_data			OUT	NOCOPY VARCHAR2,
  p_request_id			IN	NUMBER,
  p_action_number		IN	NUMBER,
  p_wf_process_id		IN	NUMBER,
  p_abort_user_id		IN	NUMBER,
  p_launched_by_dispatch	OUT	NOCOPY VARCHAR2
);


-------------------------------------------------------------------------------
-- Start of comments
--  API Name	: Decode_Action_Itemkey
--  Type	: Public
--  Description	: Given an encoded Service Request Action itemkey, this
--		  procedure will return the components of the key - service
--		  request id, action number, and workflow process ID.
--  Pre-reqs	: None
--  Parameters	:
--  IN		:	p_api_version		IN NUMBER	Required
--			p_init_msg_list		IN VARCHAR2	Optional
--				Default = FND_API.G_FALSE
--			p_itemkey		IN VARCHAR2	Requried
--
--  OUT		:	p_return_status		OUT	VARCHAR2(1)
--			p_msg_count		OUT	NUMBER
--			p_msg_data		OUT	VARCHAR2(2000)
--			p_request_id		OUT	NUMBER
--			p_action_number		OUT	NUMBER
--			p_wf_process_id		OUT	NUMBER
--
--  Version	: Initial Version	1.0
--
--  Notes	:
--
-- End of comments
-------------------------------------------------------------------------------

PROCEDURE Decode_Action_Itemkey
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_return_status	OUT	NOCOPY VARCHAR2,
  p_msg_count		OUT	NOCOPY NUMBER,
  p_msg_data		OUT	NOCOPY VARCHAR2,
  p_itemkey		IN	VARCHAR2,
  p_request_id		OUT	NOCOPY NUMBER,
  p_action_number	OUT	NOCOPY NUMBER,
  p_wf_process_id	OUT	NOCOPY NUMBER
);

END CS_Workflow_PUB;

 

/
