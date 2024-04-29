--------------------------------------------------------
--  DDL for Package Body GMO_VBATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_VBATCH_GRP" AS
/* $Header: GMOGVBTB.pls 120.2 2005/10/26 05:49 rahugupt noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMO_VBATCH_GRP';

--This procdeure would instantiate the process instructions for the batch.
procedure INSTANTIATE_ADVANCED_PI (P_API_VERSION IN NUMBER,
				   P_INIT_MSG_LIST IN VARCHAR2 DEFAULT FND_API.G_FALSE,
				   P_COMMIT IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
				   P_VALIDATION_LEVEL IN NUMBER	DEFAULT	FND_API.G_VALID_LEVEL_FULL,
                                   X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                   X_MSG_COUNT OUT NOCOPY NUMBER,
                                   X_MSG_DATA OUT NOCOPY VARCHAR2,
				   P_ENTITY_NAME IN VARCHAR2,
                                   P_ENTITY_KEY IN VARCHAR2)
IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'INSTANTIATE_ADVANCED_PI';
l_api_version   CONSTANT NUMBER 	:= 1.0;

BEGIN

	-- Standard Start of API savepoint
    	SAVEPOINT	INSTANTIATE_ADVANCED_PI_GRP;

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


	GMO_VBATCH_PVT.INSTANTIATE_ADVANCED_PI
	(
		P_ENTITY_NAME => P_ENTITY_NAME,
		P_ENTITY_KEY => P_ENTITY_KEY,
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
		ROLLBACK TO INSTANTIATE_ADVANCED_PI_GRP;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_grp.instantiate_advanced_pi', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO INSTANTIATE_ADVANCED_PI_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.instantiate_advanced_pi', FALSE);
		end if;
	WHEN OTHERS THEN
		ROLLBACK TO INSTANTIATE_ADVANCED_PI_GRP;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.instantiate_advanced_pi', FALSE);
		end if;
END INSTANTIATE_ADVANCED_PI;


--This procdeure would get the context information for the task.

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
                        X_CONTEXT_PARAMS_TBL OUT NOCOPY GMO_DATATYPES_GRP.CONTEXT_PARAMS_TBL_TYPE)
IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'ON_TASK_LOAD';
l_api_version   CONSTANT NUMBER 	:= 1.0;


BEGIN
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

	GMO_VBATCH_PVT.ON_TASK_LOAD
	(
		P_FROM_MODULE => P_FROM_MODULE,
		P_ENTITY_NAME => P_ENTITY_NAME,
		P_ENTITY_KEY => P_ENTITY_KEY,
		P_TASK => P_TASK,
		P_TASK_ATTRIBUTE => P_TASK_ATTRIBUTE,
		P_INSTRUCTION_ID => P_INSTRUCTION_ID,
		P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
		P_REQUESTER => P_REQUESTER,
		P_VBATCH_MODE => P_VBATCH_MODE,
		X_TASK_ENTITY_NAME => X_TASK_ENTITY_NAME,
		X_TASK_ENTITY_KEY => X_TASK_ENTITY_KEY,
		X_TASK_NAME => X_TASK_NAME,
		X_TASK_KEY => X_TASK_KEY,
		X_READ_ONLY => X_READ_ONLY,
		X_CONTEXT_PARAMS_TBL => X_CONTEXT_PARAMS_TBL,
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
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_grp.on_task_load', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.on_task_load', FALSE);
		end if;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.on_task_load', FALSE);
		end if;

END ON_TASK_LOAD;




--This procdeure would process the action performed by the task.

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
                          P_REQUESTER IN NUMBER)
IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'ON_TASK_ACTION';
l_api_version   CONSTANT NUMBER 	:= 1.0;

BEGIN
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

	GMO_VBATCH_PVT.ON_TASK_ACTION
	(
		P_ENTITY_NAME => P_ENTITY_NAME,
		P_ENTITY_KEY => P_ENTITY_KEY,
		P_TASK => P_TASK,
		P_TASK_ATTRIBUTE => P_TASK_ATTRIBUTE,
		P_REQUESTER => P_REQUESTER,
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
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_grp.on_task_action', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.on_task_action', FALSE);
		end if;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.on_task_action', FALSE);
		end if;

END ON_TASK_ACTION;


--This procdeure would process the save event of the task.

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
                        P_REQUESTER IN NUMBER)
IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'ON_TASK_SAVE';
l_api_version   CONSTANT NUMBER 	:= 1.0;
l_task_identifier fnd_table_of_varchar2_255;
l_task_value fnd_table_of_varchar2_255;
l_task_erecord fnd_table_of_varchar2_255;

BEGIN
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

	l_task_identifier := FND_TABLE_OF_VARCHAR2_255();
	l_task_value := FND_TABLE_OF_VARCHAR2_255();
	l_task_erecord := FND_TABLE_OF_VARCHAR2_255();

	for j in 1..P_TASK_IDENTIFIER.count loop
		l_task_identifier.extend;
		l_task_identifier(j) := P_TASK_IDENTIFIER(j);
	end loop;

	for k in 1..P_TASK_VALUE.count loop
                l_task_value.extend;
                l_task_value(k) := P_TASK_VALUE(k);
        end loop;

	for l in 1..P_TASK_ERECORD.count loop
                l_task_erecord.extend;
                l_task_erecord(l) := P_TASK_ERECORD(l);
        end loop;

	GMO_VBATCH_PVT.ON_TASK_SAVE
	(
		P_FROM_MODULE => P_FROM_MODULE ,
		P_ENTITY_NAME => P_ENTITY_NAME,
		P_ENTITY_KEY => P_ENTITY_KEY,
		P_TASK => P_TASK,
		P_TASK_ATTRIBUTE => P_TASK_ATTRIBUTE,
		P_INSTRUCTION_ID => P_INSTRUCTION_ID,
		P_INSTRUCTION_PROCESS_ID => P_INSTRUCTION_PROCESS_ID,
		P_TASK_IDENTIFIER => l_task_identifier,
		P_TASK_VALUE => l_task_value,
		P_TASK_ERECORD => l_task_erecord,
		P_REQUESTER => P_REQUESTER,
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
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_grp.on_task_save', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.on_task_save', FALSE);
		end if;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.on_task_save', FALSE);
		end if;

END ON_TASK_SAVE;


--This procdeure would check if the step is locked or not

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
				  X_LOCK_ALLOWED OUT NOCOPY VARCHAR2)

IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'GET_ENTITY_LOCK_STATUS';
l_api_version   CONSTANT NUMBER 	:= 1.0;

BEGIN
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

	GMO_VBATCH_PVT.GET_ENTITY_LOCK_STATUS
	(
		P_ENTITY_NAME => P_ENTITY_NAME,
		P_ENTITY_KEY => P_ENTITY_KEY,
		P_REQUESTER => P_REQUESTER,
		X_LOCK_STATUS => X_LOCK_STATUS,
		X_LOCKED_BY_STATUS => X_LOCKED_BY_STATUS,
		X_LOCK_ALLOWED => X_LOCK_ALLOWED,
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
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_vbatch_grp.get_entity_lock_status', FALSE);
		end if;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.get_entity_lock_status', FALSE);
		end if;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_vbatch_grp.get_entity_lock_status', FALSE);
		end if;

END GET_ENTITY_LOCK_STATUS;



--This procdeure loads the operator workbench for the entity. It has been defined in the GMOGOWB.pll
/*
procedure LOAD_VBATCH
*/

END GMO_VBATCH_GRP;

/
