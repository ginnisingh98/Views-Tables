--------------------------------------------------------
--  DDL for Package Body GMO_DVC_INTG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DVC_INTG_GRP" AS
/* $Header: GMOGDVCB.pls 120.3 2005/09/21 02:05 rahugupt noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMO_DVC_INTG_GRP';

--This procedure reads the device.
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
						X_DEVICE_STATUS OUT NOCOPY VARCHAR2)

IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'READ_DEVICE';
l_api_version   CONSTANT NUMBER 	:= 1.0;

BEGIN

	-- Standard Start of API savepoint
    SAVEPOINT	READ_DEVICE_GRP;

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

	GMO_DVC_INTG_PVT.READ_DEVICE  (
							P_RESOURCE_ID => P_RESOURCE_ID,
							P_DEVICE_ID => P_DEVICE_ID,
					   		P_ORGANIZATION_ID => P_ORGANIZATION_ID,
					   		P_EVENT_ID => P_EVENT_ID,
					   		P_LOCK_UNLOCK => P_LOCK_UNLOCK,
					   		P_REQUESTER => P_REQUESTER,
					   		P_PARAMETER_ID 	=> P_PARAMETER_ID ,
					   		P_PARAMETER_UOM_DEFN => P_PARAMETER_UOM_DEFN,
					   		X_PARAMETER_VALUE => X_PARAMETER_VALUE,
							X_PARAMETER_UOM	=> X_PARAMETER_UOM,
							X_DEVICE_STATUS => X_DEVICE_STATUS,
					   		X_RETURN_STATUS => X_RETURN_STATUS,
					   		X_MSG_COUNT => X_MSG_COUNT,
				   			X_MSG_DATA => X_MSG_DATA
				   		);

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
		ROLLBACK TO READ_DEVICE_GRP;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO READ_DEVICE_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
	WHEN OTHERS THEN
		ROLLBACK TO READ_DEVICE_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
END READ_DEVICE;



--This procedure reads the device.
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
						X_DEVICE_STATUS OUT NOCOPY VARCHAR2)

IS

l_parameter_id fnd_table_of_varchar2_255;
l_parameter_uom_defn fnd_table_of_varchar2_255;
l_parameter_value fnd_table_of_varchar2_255;
l_parameter_uom fnd_table_of_varchar2_255;

BEGIN

	l_parameter_id := fnd_table_of_varchar2_255();
	l_parameter_uom_defn := fnd_table_of_varchar2_255();
	l_parameter_value := fnd_table_of_varchar2_255();
	l_parameter_uom := fnd_table_of_varchar2_255();

	FOR J IN 1..P_PARAMETER_ID.count LOOP
		l_parameter_id.EXTEND;
		l_parameter_id(J) := P_PARAMETER_ID(J);
	END LOOP;

	FOR I IN 1..P_PARAMETER_UOM_DEFN.count LOOP
		l_parameter_uom_defn.EXTEND;
		l_parameter_uom_defn(I) := P_PARAMETER_UOM_DEFN(I);
	END LOOP;



	READ_DEVICE  (		P_API_VERSION => P_API_VERSION ,
				   		P_INIT_MSG_LIST => P_INIT_MSG_LIST,
				   		P_COMMIT => P_COMMIT ,
				   		P_VALIDATION_LEVEL => P_VALIDATION_LEVEL,
				   		X_RETURN_STATUS => X_RETURN_STATUS,
				   		X_MSG_COUNT => X_MSG_COUNT,
				   		X_MSG_DATA => X_MSG_DATA,
				   		P_RESOURCE_ID => P_RESOURCE_ID,
						P_DEVICE_ID => P_DEVICE_ID,
				   		P_ORGANIZATION_ID => P_ORGANIZATION_ID,
				   		P_EVENT_ID => P_EVENT_ID,
				   		P_LOCK_UNLOCK => P_LOCK_UNLOCK,
				   		P_REQUESTER => P_REQUESTER,
				   		P_PARAMETER_ID 	=> L_PARAMETER_ID ,
				   		P_PARAMETER_UOM_DEFN => L_PARAMETER_UOM_DEFN,
				   		X_PARAMETER_VALUE => L_PARAMETER_VALUE,
						X_PARAMETER_UOM	=> L_PARAMETER_UOM,
						X_DEVICE_STATUS => X_DEVICE_STATUS );


	if (L_PARAMETER_VALUE is not null ) then
		FOR K IN 1..l_parameter_value.count LOOP
			X_PARAMETER_VALUE(K) := l_parameter_value(K);
		END LOOP;
	end if;

	if (L_PARAMETER_UOM is not null) then
		FOR M IN 1..l_parameter_uom.count LOOP
			X_PARAMETER_UOM(M) := l_parameter_uom(M);
		END LOOP;
	end if;


END;


--This procedure reads the device.
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
						X_DEVICE_STATUS OUT NOCOPY VARCHAR2)

IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'READ_DEVICE';
l_api_version   CONSTANT NUMBER 	:= 1.0;
l_response_code fnd_table_of_varchar2_255;
l_response_value fnd_table_of_varchar2_255;

BEGIN

	-- Standard Start of API savepoint
    SAVEPOINT	READ_DEVICE;
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
	l_response_code := fnd_table_of_varchar2_255();
	l_response_code.extend;
	l_response_code(1) := P_MSG_COMPONENT_PARAM;
	l_response_code.extend;
	l_response_code(2) := P_MSG_COMPONENT_UOM;

	GMO_DVC_INTG_PVT.READ_DEVICE  (
							P_DEVICE_ID => P_DEVICE_ID,
					   		P_ORGANIZATION_ID => P_ORGANIZATION_ID,
							P_EVENT_ID => P_EVENT_ID,
					   		P_LOCK_UNLOCK => P_LOCK_UNLOCK,
					   		P_REQUESTER => P_REQUESTER,
					   		P_MSG_COMPONENT => l_response_code ,
					   		X_VALUE => l_response_value,
							X_DEVICE_STATUS => X_DEVICE_STATUS,
					   		X_RETURN_STATUS => X_RETURN_STATUS,
					   		X_MSG_COUNT => X_MSG_COUNT,
				   			X_MSG_DATA => X_MSG_DATA
				   		);
	IF (l_response_value is not null and l_response_value.count > 0) then
		x_param_value := l_response_value(1);
		if (l_response_value.count > 1) then
			x_uom_value := l_response_value(2);
		end if;
	end if;

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
		ROLLBACK TO READ_DEVICE;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO READ_DEVICE;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
	WHEN OTHERS THEN
		ROLLBACK TO READ_DEVICE;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
END READ_DEVICE;

END GMO_DVC_INTG_GRP;

/
