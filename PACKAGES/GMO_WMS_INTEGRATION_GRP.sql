--------------------------------------------------------
--  DDL for Package GMO_WMS_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_WMS_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: GMOGWMSS.pls 120.0 2005/08/05 03:57 rahugupt noship $*/

--This procedure would process the device response

-- Start of comments
-- API name             : PROCESS_DEVICE_RESPONSE
-- Type                 : Group Utility.
-- Function             : Process device response
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--			  p_init_msg_list in varchar2 default fnd_api.g_false,
--			  p_commit in  varchar2 default fnd_api.g_false,
--			  p_validation_level in number	default fnd_api.g_valid_level_full,
--                        p_request_id in number
--                        p_device_id in number
--                        p_param_values_record in wms_wcs_device_grp.msg_component_lookup_type
-- OUT                  : x_return_status out varchar2
--                        x_msg_count out number
--                        x_msg_data out varchar2
-- End of comments

PROCEDURE PROCESS_DEVICE_RESPONSE (

	P_API_VERSION IN NUMBER,
	P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
	X_MSG_COUNT           OUT NOCOPY NUMBER,
	X_MSG_DATA            OUT NOCOPY VARCHAR2,
        P_REQUEST_ID          IN NUMBER,
        P_DEVICE_ID           IN NUMBER,
	P_PARAM_VALUES_RECORD IN  WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE
);


END GMO_WMS_INTEGRATION_GRP;

 

/
