--------------------------------------------------------
--  DDL for Package GMO_VBATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_VBATCH_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGVBTS.pls 120.2 2005/10/26 05:49 rahugupt noship $ */

--This procdeure would instantiate the process instructions for the batch.

-- Start of comments
-- API name             : instantiate_advanced_pi
-- Type                 : Group Utility.
-- Function             : Instantiates the process instructions
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			  p_init_msg_list in varchar2 default fnd_api.g_false,
--			  p_commit in  varchar2 default fnd_api.g_false,
--			  p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_entity_name in varchar2
--                        p_entity_key in varchar2
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure INSTANTIATE_ADVANCED_PI (P_API_VERSION IN NUMBER,
				   P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
				   P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				   P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
                                   X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                   X_MSG_COUNT OUT NOCOPY NUMBER,
                                   X_MSG_DATA OUT NOCOPY VARCHAR2,
				   P_ENTITY_NAME IN VARCHAR2,
                                   P_ENTITY_KEY IN VARCHAR2
);


--This procdeure would get the context information for the task.

-- Start of comments
-- API name             : on_task_load
-- Type                 : Group Utility.
-- Function             : gets the context information for the task
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			  p_init_msg_list in varchar2 default fnd_api.g_false,
--			  p_commit in  varchar2 default fnd_api.g_false,
--			  p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_from_module in varchar2
--                        p_entity_name in varchar2
--                        p_entity_key in varchar2
--                        p_task in varchar2
--                        p_task_attribute in varchar2
--                        p_instruction_id in number
-- OUT                  : x_entity_name out varchar2
--                        x_entity_key out varchar2
--                        x_task out varchar2
--                        x_task_key out varchar2
--                        x_read_only out char
--                        x_context_params_tbl out CONTEXT_PARAMS_TBL_TYPE
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure ON_TASK_LOAD (P_API_VERSION IN NUMBER,
			P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
			P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
                        X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                        X_MSG_COUNT OUT NOCOPY NUMBER,
                        X_MSG_DATA OUT NOCOPY VARCHAR2,
			P_FROM_MODULE IN VARCHAR2,
                        P_ENTITY_NAME IN VARCHAR2,
                        P_ENTITY_KEY IN VARCHAR2,
                        P_TASK IN VARCHAR2,
                        P_TASK_ATTRIBUTE IN VARCHAR2,
                        P_INSTRUCTION_ID IN NUMBER,
                        P_INSTRUCTION_PROCESS_ID IN NUMBER,
                        P_REQUESTER IN NUMBER,
                        P_VBATCH_MODE IN VARCHAR2,
                        X_TASK_ENTITY_NAME OUT NOCOPY VARCHAR2,
                        X_TASK_ENTITY_KEY OUT NOCOPY VARCHAR2,
                        X_TASK_NAME OUT NOCOPY VARCHAR2,
                        X_TASK_KEY OUT NOCOPY VARCHAR2,
                        X_READ_ONLY OUT NOCOPY VARCHAR2,
                        X_CONTEXT_PARAMS_TBL OUT NOCOPY GMO_DATATYPES_GRP.CONTEXT_PARAMS_TBL_TYPE
);


--This procdeure would process the action performed by the task.

-- Start of comments
-- API name             : on_task_action
-- Type                 : Group Utility.
-- Function             : process the action performed by the task
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			  p_init_msg_list in varchar2 default fnd_api.g_false,
--			  p_commit in  varchar2 default fnd_api.g_false,
--			  p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_entity_name in varchar2
--                        p_entity_key in varchar2
--                        p_task in varchar2
--                        p_task_attribute in varchar2
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure ON_TASK_ACTION (P_API_VERSION IN NUMBER,
			  P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
			  P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			  P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
                          X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT OUT NOCOPY NUMBER,
                          X_MSG_DATA OUT NOCOPY VARCHAR2,
                          P_ENTITY_NAME IN VARCHAR2,
                          P_ENTITY_KEY IN VARCHAR2,
                          P_TASK IN VARCHAR2,
                          P_TASK_ATTRIBUTE IN VARCHAR2,
                          P_REQUESTER IN NUMBER
);


--This procdeure would process the save event of the task.

-- Start of comments
-- API name             : on_task_save
-- Type                 : Group Utility.
-- Function             : process the save event of the task.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			  p_init_msg_list in varchar2 default fnd_api.g_false,
--			  p_commit in  varchar2 default fnd_api.g_false,
--			  p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_from_module in varchar2
--                        p_entity_name in varchar2
--                        p_entity_key in varchar2
--                        p_task in varchar2
--                        p_task_attribute in varchar2
--                        p_instruction_id in number
--                        p_task_identifier in gmo_table_of_varchar2_255
--                        p_task_value in gmo_table_of_varchar2_255
--                        p_task_erecord in gmo_table_of_varchar2_255
--                        p_requester in number
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments


procedure ON_TASK_SAVE (P_API_VERSION IN NUMBER,
			P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
			P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
                        X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                        X_MSG_COUNT OUT NOCOPY NUMBER,
                        X_MSG_DATA OUT NOCOPY VARCHAR2,
                        P_FROM_MODULE IN VARCHAR2,
                        P_ENTITY_NAME IN VARCHAR2,
                        P_ENTITY_KEY IN VARCHAR2,
                        P_TASK IN VARCHAR2,
                        P_TASK_ATTRIBUTE IN VARCHAR2 DEFAULT NULL,
                        P_INSTRUCTION_ID IN NUMBER DEFAULT NULL,
                        P_INSTRUCTION_PROCESS_ID IN NUMBER DEFAULT NULL,
                        P_TASK_IDENTIFIER IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                        P_TASK_VALUE IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                        P_TASK_ERECORD IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                        P_REQUESTER IN NUMBER
);


--This procdeure would check if the entity is locked or not

-- Start of comments
-- API name             : get_entity_lock_status
-- Type                 : Group Utility.
-- Function             : checks if the entity is locked or not
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			  p_init_msg_list in varchar2 default fnd_api.g_false,
--			  p_commit in  varchar2 default fnd_api.g_false,
--			  p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_entity_name in varchar2
--                        p_entity_key in varchar2
--                        p_requester in varchar2
-- OUT                  : x_lock_status out varchar2
--			  x_locked_by_status out varchar2
--			  x_lock_allowed out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure GET_ENTITY_LOCK_STATUS (P_API_VERSION IN NUMBER,
				  P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
				  P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				  P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
                        	  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                        	  X_MSG_COUNT OUT NOCOPY NUMBER,
                        	  X_MSG_DATA OUT NOCOPY VARCHAR2,
                        	  P_ENTITY_NAME IN VARCHAR2,
				  P_ENTITY_KEY IN VARCHAR2,
				  P_REQUESTER IN NUMBER,
				  X_LOCK_STATUS OUT NOCOPY VARCHAR2,
				  X_LOCKED_BY_STATUS OUT NOCOPY VARCHAR2,
				  X_LOCK_ALLOWED OUT NOCOPY VARCHAR2
);




END GMO_VBATCH_GRP;

 

/
