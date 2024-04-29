--------------------------------------------------------
--  DDL for Package GMO_DVC_INTG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DVC_INTG_PVT" AUTHID CURRENT_USER AS
/* $Header: GMOVDVCS.pls 120.1 2005/09/05 23:21 rahugupt noship $ */

--This procedure would lock the device.

-- Start of comments
-- API name             : lock_device
-- Type                 : Private Utility.
-- Function             : lock the device for the user
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_device_id in number
--                        p_requester in number
--			  p_organization_id in number
-- OUT                  : x_device_type out varchar2
--                        x_device_desc out varchar2
--                        x_subinventory out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments


procedure LOCK_DEVICE	 (P_DEVICE_ID IN NUMBER,
                          P_REQUESTER IN NUMBER,
                          P_ORGANIZATION_ID IN NUMBER,
			  X_DEVICE_TYPE     OUT NOCOPY VARCHAR2,
			  X_DEVICE_DESC     OUT NOCOPY VARCHAR2,
  			  X_SUBINVENTORY    OUT NOCOPY VARCHAR2,
			  X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
			  X_MSG_COUNT       OUT NOCOPY NUMBER,
			  X_MSG_DATA        OUT NOCOPY VARCHAR2);


--This procdeure would unlock the device.

-- Start of comments
-- API name             : unlock_device
-- Type                 : Private Utility.
-- Function             : unlock the device for the user
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_device_id in number
--                        p_requester in number
--			  p_organization_id in number
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure UNLOCK_DEVICE	 (P_DEVICE_ID IN NUMBER,
                          P_REQUESTER IN NUMBER,
                          P_ORGANIZATION_ID IN NUMBER,
			  X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
			  X_MSG_COUNT       OUT NOCOPY NUMBER,
			  X_MSG_DATA        OUT NOCOPY VARCHAR2);


--This procdeure would clean the data from the temporary tables.

-- Start of comments
-- API name             : temp_data_cleanup
-- Type                 : Private Utility.
-- Function             : cleans up the temporary tables
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_cleanup_to_date in date default null
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure TEMP_DATA_CLEANUP	 (P_CLEANUP_TO_DATE IN DATE DEFAULT NULL,
                          	  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          	  X_MSG_COUNT OUT NOCOPY NUMBER,
                          	  X_MSG_DATA OUT NOCOPY VARCHAR2);


--This procedure reads the device.

-- Start of comments
-- API name             : read_device
-- Type                 : Private Utility.
-- Function             : reads the device
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_device_id in number
--                        p_organization_id in number
--                        p_event_id in number
--                        p_lock_unlock in varchar2 default gmo_constants_grp.yes,
--			  p_requester in number,
--			  p_parameter_id in fnd_table_of_varchar2_255
--			  p_parameter_uom_defn in fnd_table_of_varchar2_255
-- OUT                  : x_parameter_value out fnd_table_of_varchar2_255
--                        x_parameter_uom out fnd_table_of_varchar2_255
--                        x_device_status out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure READ_DEVICE  (P_RESOURCE_ID IN NUMBER,
			P_DEVICE_ID IN NUMBER,
			P_ORGANIZATION_ID IN NUMBER,
			P_EVENT_ID IN NUMBER,
			P_LOCK_UNLOCK IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
			P_REQUESTER IN NUMBER,
			P_PARAMETER_ID 	IN FND_TABLE_OF_VARCHAR2_255,
			P_PARAMETER_UOM_DEFN IN FND_TABLE_OF_VARCHAR2_255,
			X_PARAMETER_VALUE OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
			X_PARAMETER_UOM	OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
			X_DEVICE_STATUS OUT NOCOPY VARCHAR2,
			X_RETURN_STATUS OUT NOCOPY VARCHAR2,
			X_MSG_COUNT OUT NOCOPY NUMBER,
			X_MSG_DATA OUT NOCOPY VARCHAR2);


--This procedure reads the device.

-- Start of comments
-- API name             : read_device
-- Type                 : Private Utility.
-- Function             : reads the device
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_device_id in number
--                        p_organization_id in number
--			  p_event_id in number
--                        p_lock_unlock in varchar2 default gmo_constants_grp.yes,
--			  p_requester in number,
--			  p_msg_component in varchar2,
-- OUT                  : x_value out varchar2
--                        x_device_status out varchar2
--                        x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

procedure READ_DEVICE  (P_DEVICE_ID IN NUMBER,
			P_ORGANIZATION_ID IN NUMBER,
			P_EVENT_ID IN NUMBER,
			P_LOCK_UNLOCK IN VARCHAR2 DEFAULT GMO_CONSTANTS_GRP.YES,
			P_REQUESTER IN NUMBER,
			P_MSG_COMPONENT IN FND_TABLE_OF_VARCHAR2_255,
			X_VALUE OUT NOCOPY FND_TABLE_OF_VARCHAR2_255,
			X_DEVICE_STATUS OUT NOCOPY VARCHAR2,
			X_RETURN_STATUS OUT NOCOPY VARCHAR2,
			X_MSG_COUNT OUT NOCOPY NUMBER,
			X_MSG_DATA OUT NOCOPY VARCHAR2);

--This procedure would process the device response

-- Start of comments
-- API name             : PROCESS_DEVICE_RESPONSE
-- Type                 : Public Utility.
-- Function             : Process device response
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_param_values_record in wms_wcs_device_grp.msg_component_lookup_type
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

PROCEDURE PROCESS_DEVICE_RESPONSE ( P_REQUEST_ID IN NUMBER,
				    P_DEVICE_ID IN NUMBER,
				    P_PARAM_VALUES_RECORD IN  WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE,
				    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
				    X_MSG_COUNT OUT NOCOPY NUMBER,
				    X_MSG_DATA OUT NOCOPY VARCHAR2);

END GMO_DVC_INTG_PVT;

 

/
