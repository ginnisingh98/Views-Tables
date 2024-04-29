--------------------------------------------------------
--  DDL for Package GMO_DVC_INTG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DVC_INTG_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGDVCS.pls 120.2 2005/09/05 23:20 rahugupt noship $ */

--This procedure reads the device.

-- Start of comments
-- API name             : read_device
-- Type                 : Private Utility.
-- Function             : reads the device
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			              p_init_msg_list in varchar2 default fnd_api.g_false,
--			              p_commit in  varchar2 default fnd_api.g_false,
--			              p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_device_id in number
--                        p_organization_id in number
--                        p_event_id in number
--                        p_lock_unlock in varchar2 default gmo_constants_grp.yes,
--				   		  p_requester in number,
--				   		  p_parameter_id 	in fnd_table_of_varchar2_255
--				   		  p_parameter_uom_defn in fnd_table_of_varchar2_255
-- OUT                  : x_parameter_value out fnd_table_of_varchar2_255
--                        x_parameter_uom out fnd_table_of_varchar2_255
--                        x_device_status out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure READ_DEVICE  (P_API_VERSION IN NUMBER,
				   		P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
				   		P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				   		P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
				   		X_RETURN_STATUS OUT NOCOPY VARCHAR2,
				   		X_MSG_COUNT OUT NOCOPY NUMBER,
				   		X_MSG_DATA OUT NOCOPY VARCHAR2,
				   		P_RESOURCE_ID IN NUMBER,
						P_DEVICE_ID IN NUMBER,
				   		P_ORGANIZATION_ID IN NUMBER,
				   		P_EVENT_ID IN NUMBER,
				   		P_LOCK_UNLOCK IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
				   		P_REQUESTER IN NUMBER,
				   		P_PARAMETER_ID 	IN FND_TABLE_OF_VARCHAR2_255,
				   		P_PARAMETER_UOM_DEFN IN FND_TABLE_OF_VARCHAR2_255,
				   		X_PARAMETER_VALUE OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
						X_PARAMETER_UOM	OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
						X_DEVICE_STATUS OUT NOCOPY VARCHAR2);


--This procedure reads the device.

-- Start of comments
-- API name             : read_device
-- Type                 : Private Utility.
-- Function             : reads the device
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			              p_init_msg_list in varchar2 default fnd_api.g_false,
--			              p_commit in  varchar2 default fnd_api.g_false,
--			              p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_device_id in number
--                        p_organization_id in number
--                        p_event_id in number
--                        p_lock_unlock in varchar2 default gmo_constants_grp.yes,
--				   		  p_requester in number,
--				   		  p_parameter_id 	in gmo_datatypes_grp.gmo_table_of_varchar2_255
--				   		  p_parameter_uom_defn in gmo_datatypes_grp.gmo_table_of_varchar2_255
-- OUT                  : x_parameter_value out gmo_datatypes_grp.gmo_table_of_varchar2_255
--                        x_parameter_uom out gmo_datatypes_grp.gmo_table_of_varchar2_255
--                        x_device_status out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure READ_DEVICE  (P_API_VERSION IN NUMBER,
				   		P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
				   		P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				   		P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
				   		X_RETURN_STATUS OUT NOCOPY VARCHAR2,
				   		X_MSG_COUNT OUT NOCOPY NUMBER,
				   		X_MSG_DATA OUT NOCOPY VARCHAR2,
				   		P_RESOURCE_ID IN NUMBER,
						P_DEVICE_ID IN NUMBER,
				   		P_ORGANIZATION_ID IN NUMBER,
				   		P_EVENT_ID IN NUMBER,
				   		P_LOCK_UNLOCK IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
				   		P_REQUESTER IN NUMBER,
				   		P_PARAMETER_ID 	IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
				   		P_PARAMETER_UOM_DEFN IN GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
				   		X_PARAMETER_VALUE OUT NOCOPY GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
						X_PARAMETER_UOM	OUT NOCOPY GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
						X_DEVICE_STATUS OUT NOCOPY VARCHAR2);


--This procedure reads the device.

-- Start of comments
-- API name             : read_device
-- Type                 : Private Utility.
-- Function             : reads the device
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			              p_init_msg_list in varchar2 default fnd_api.g_false,
--			              p_commit in  varchar2 default fnd_api.g_false,
--			              p_validation_level in number	default	fnd_api.g_valid_level_full,
--                        p_device_id in number
--                        p_organization_id in number
--                        p_event_id in number
--                        p_lock_unlock in varchar2 default gmo_constants_grp.yes,
--			  p_requester in number,
--			  p_msg_component_param in varchar2,
--			  p_msg_component_uom in varchar2,
-- OUT                  : x_param_value out varchar2
--                        x_uom_value out varchar2
--                        x_device_status out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure READ_DEVICE  (P_API_VERSION IN NUMBER,
				   		P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
				   		P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				   		P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
				   		X_RETURN_STATUS OUT NOCOPY VARCHAR2,
				   		X_MSG_COUNT OUT NOCOPY NUMBER,
				   		X_MSG_DATA OUT NOCOPY VARCHAR2,
				   		P_DEVICE_ID IN NUMBER,
				   		P_ORGANIZATION_ID IN NUMBER,
						P_EVENT_ID IN NUMBER,
				   		P_LOCK_UNLOCK IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
				   		P_REQUESTER IN NUMBER,
						P_MSG_COMPONENT_PARAM IN VARCHAR2,
						P_MSG_COMPONENT_UOM IN VARCHAR2,
						X_PARAM_VALUE OUT NOCOPY VARCHAR2,
						X_UOM_VALUE OUT NOCOPY VARCHAR2,
						X_DEVICE_STATUS OUT NOCOPY VARCHAR2);


END GMO_DVC_INTG_GRP;

 

/
