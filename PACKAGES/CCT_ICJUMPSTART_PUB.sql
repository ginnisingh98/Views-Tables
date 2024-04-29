--------------------------------------------------------
--  DDL for Package CCT_ICJUMPSTART_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_ICJUMPSTART_PUB" AUTHID CURRENT_USER as
/* $Header: cctjumps.pls 120.0 2005/06/02 09:34:10 appldev noship $ */

/* -----------------------------------------------------------------------
   Activity Name : CreateICAgent

   This API creates an IC Agent in HR Employee, FND USER and JTF Resource Manager
   It configures the role and agent parameters for the new IC Agent
   IN
    p_Last_name   	- Last Name of the Agent
    p_First_Name 	- First Name of the Agent(optional)
    p_middle_name 	- Middle Name of the Agent(optional)
    p_Agent_Sex		- M/F
    p_App_Username	- A unique UserName for the agent
    p_IC_ROLE		- Role of the agent in IC (CALL_CENTER_Agent/CALL_CENTER_Manager/CALL_CENTER_Supervisor)
    p_IC_SErver_Group_ID - The Server Group ID to which the agent belongs
    p_middleware_config_id - The middleware Config in the above Server Group ID to which the agent should be set up
    p_acd_agent_ID  - ACD Agent ID for the above middleware config
    p_acd_agent_password - ACD Agent Password for the above middleware config
   OUT
    x_return_status - Success/Failure
    x_message_data	- Error messages if any
    p_Resource_ID	- Resource ID for the newly created Agent
*-----------------------------------------------------------------------*/

Procedure CreateICAgent(
	 p_LAST_NAME IN VARCHAR2
	,p_FIRST_NAME IN VARCHAR2 Default NULL
	,p_MIDDLE_NAME IN VARCHAR2 Default NULL
	,p_Agent_SEX IN VARCHAR2 Default 'M'
	,p_APP_USERNAME IN VARCHAR2
	,p_IC_ROLE IN VARCHAR2 Default 'CALL_CENTER_AGENT'
	,p_IC_SERVER_GROUP_ID IN NUMBER
	,p_middleware_config_id IN NUMBER Default NULL
	,p_ACD_AGENT_ID IN VARCHAR2 Default NULL
	,p_ACD_AGENT_PASSWORD IN VARCHAR2 Default Null
	,p_acd_queue IN VARCHAR2 Default NULL
	,p_Resource_ID	OUT nocopy NUMBER
	,x_return_status OUT nocopy  VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_user_password OUT  nocopy VARCHAR2
);

/* -----------------------------------------------------------------------
   Activity Name : CreateServerGroup

   This API creates a new Server Group.
   IN
	p_server_group_name - a unique name for the server group
   OUT
    x_return_status - Success/Failure
    x_message_data	- Error messages if any
    p_server_group_ID - Server Group ID for the newly created Server Group
*-----------------------------------------------------------------------*/
Procedure CreateServerGroup(
	 p_server_Group_Name In Varchar2
	,x_return_status OUT nocopy  VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_Server_group_id Out nocopy  Number
);

Procedure CreateAllServers(
     p_server_group_id In Number
    ,p_call_center_type IN VARCHAR2 DEFAULT NULL
	,x_return_Status OUT nocopy  VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_SERVERTYPEID_SERVERID OUT nocopy  CCT_KEYVALUE_VARR
);


Procedure CreateMiddlewareConfig(
 	p_server_group_id In Number
 	,p_middleware_type IN Varchar2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
 	,x_middleware_id OUT nocopy  Number
);

Procedure GetMiddlewareConfigInfo(
	p_server_group_name In VARCHAR2 Default Null
	,p_server_group_id In Number Default Null
	,p_middleware_id In OUT nocopy  Number
	,x_return_status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_config_name OUT nocopy  VARCHAR2
	,x_middleware_type OUT nocopy  VARCHAR2
	,x_param_value OUT nocopy  CCT_KEYVALUE_VARR
);

Procedure CreateServerParam(
    p_server_id In Number
    ,p_param_value IN CCT_KEYVALUE_VARR
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
);

Procedure CreateMwareParam(
	p_middleware_id In Number
    ,p_param_value IN CCT_KEYVALUE_VARR
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
);

Procedure CreateTelesets(
	p_middleware_id In Number
	,p_teleset_type In Varchar2
	,p_start_teleset_number In Number
	,p_skip_by In Number Default 1
	,p_number_of_Telesets In Number
	,p_line1 In Number Default Null
	,p_line2 In Number Default Null
	,p_line3 In Number Default 9999
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
);

Procedure CreateRoutePoint(
	p_middleware_id In Number
    ,p_route_point_number IN VARCHAR2
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
	,x_route_point_id OUT nocopy  NUMBER
);

Procedure CreateRoutePointParams(
    p_route_point_id In Number
    ,p_param_value CCT_KEYVALUE_VARR
	,p_commit	IN VARCHAR2 DEFAULT FND_API.G_FALSE
	,p_init_msg_list IN VARCHAR2 Default FND_API.G_FALSE
	,x_return_Status OUT nocopy  VARCHAR2
	,x_msg_count 	OUT nocopy  NUMBER
	,x_message_data OUT nocopy  VARCHAR2
);

End CCT_ICJUMPSTART_PUB;

 

/
