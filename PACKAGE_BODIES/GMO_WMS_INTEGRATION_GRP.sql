--------------------------------------------------------
--  DDL for Package Body GMO_WMS_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_WMS_INTEGRATION_GRP" AS
/* $Header: GMOGWMSB.pls 120.1 2005/08/05 04:13 rahugupt noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMO_WMS_INTEGRATION_GRP';

--This procedure would process the device response

-- Start of comments
-- API name             : PROCESS_DEVICE_RESPONSE
-- Type                 : Group Utility.
-- Function             : Process device response
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version in number,
--                        p_init_msg_list in varchar2 default fnd_api.g_false,
--                        p_commit in  varchar2 default fnd_api.g_false,
--                        p_validation_level in number  default fnd_api.g_valid_level_full,
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
        P_VALIDATION_LEVEL IN NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
        X_MSG_COUNT           OUT NOCOPY NUMBER,
        X_MSG_DATA            OUT NOCOPY VARCHAR2,
        P_REQUEST_ID          IN NUMBER,
        P_DEVICE_ID           IN NUMBER,
        P_PARAM_VALUES_RECORD IN  WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE
)
IS
l_api_name	CONSTANT VARCHAR2(30)	:= 'PROCESS_DEVICE_RESPONSE';
l_api_version   CONSTANT NUMBER 	:= 1.0;

BEGIN

	-- Standard Start of API savepoint
    SAVEPOINT	PROCESS_DEVICE_RESPONSE_GRP;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,l_api_name,G_PKG_NAME)	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	GMO_DVC_INTG_PVT.PROCESS_DEVICE_RESPONSE (
									P_REQUEST_ID => P_REQUEST_ID ,
									P_DEVICE_ID => P_DEVICE_ID ,
									P_PARAM_VALUES_RECORD => P_PARAM_VALUES_RECORD ,
				   					X_RETURN_STATUS => X_RETURN_STATUS,
									X_MSG_COUNT => X_MSG_COUNT,
									X_MSG_DATA => X_MSG_DATA);

	IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		IF FND_API.To_Boolean( p_commit ) THEN
			COMMIT	;
		END IF;
	ELSE
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO PROCESS_DEVICE_RESPONSE_GRP;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_wms_integration_grp.process_device_response', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO PROCESS_DEVICE_RESPONSE_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_wms_integration_grp.process_device_response', FALSE);
		end if;
	WHEN OTHERS THEN
		ROLLBACK TO PROCESS_DEVICE_RESPONSE_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_wms_integration_grp.process_device_response', FALSE);
		end if;
END PROCESS_DEVICE_RESPONSE;

END GMO_WMS_INTEGRATION_GRP;


/
