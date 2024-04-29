--------------------------------------------------------
--  DDL for Package Body GMO_DVC_INTG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DVC_INTG_PVT" AS
/* $Header: GMOVDVCB.pls 120.4 2005/10/25 01:02 rahugupt noship $ */


-- internal constants used in this package body
ACTION_INSERT_RESPONSE CONSTANT VARCHAR2(30) := 'INSERT_RESPONSE';
ACTION_UPDATE_RESPONSE CONSTANT VARCHAR2(30) := 'UPDATE_RESPONSE';
ACTION_INSERT_REQUEST CONSTANT VARCHAR2(30) := 'INSERT_REQUEST';
ACTION_UPDATE_DEVICE_STATUS CONSTANT VARCHAR2(30) := 'UPDATE_DEVICE_STATUS';
ACTION_UPDATE_DEVICE_RESPONSE CONSTANT VARCHAR2(30) := 'UPDATE_DEVICE_RESPONSE';


--This procedure would lock the device.
procedure LOCK_DEVICE	 (P_DEVICE_ID IN NUMBER,
                          P_REQUESTER IN NUMBER,
                          P_ORGANIZATION_ID IN NUMBER,
			  X_DEVICE_TYPE     OUT NOCOPY VARCHAR2,
			  X_DEVICE_DESC     OUT NOCOPY VARCHAR2,
  			  X_SUBINVENTORY    OUT NOCOPY VARCHAR2,
			  X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
			  X_MSG_COUNT       OUT NOCOPY NUMBER,
			  X_MSG_DATA        OUT NOCOPY VARCHAR2)

IS PRAGMA AUTONOMOUS_TRANSACTION;

l_device_name varchar2(30);
l_signon_wrk_stn varchar2(100);
cursor c_get_device_details is select name from wms_devices_vl where device_id = P_DEVICE_ID;

BEGIN

	open c_get_device_details;
	fetch c_get_device_details into l_device_name;
	close c_get_device_details;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_LOCK_DEVICE_MSG');
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('DEVICE_NAME',l_device_name);
		FND_MESSAGE.SET_TOKEN('REQUESTER',P_REQUESTER);
		FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',P_ORGANIZATION_ID);

		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.lock_device', FALSE);
	end if;

	-- call the wms api to lock the device
	WMS_WCS_DEVICE_GRP.DEVICE_SIGN_ON
	(
		P_DEVICE_ID => P_DEVICE_ID,
		P_DEVICE_NAME => L_DEVICE_NAME,
		P_EMPLOYEE_ID => P_REQUESTER,
		P_ORGANIZATION_ID => P_ORGANIZATION_ID,
		X_DEVICE_TYPE => X_DEVICE_TYPE,
		X_DEVICE_DESC => X_DEVICE_DESC,
		X_SUBINVENTORY => X_SUBINVENTORY,
		X_SIGNON_WRK_STN => l_signon_wrk_stn,
		X_RETURN_STATUS => X_RETURN_STATUS,
		X_MSG_COUNT => X_MSG_COUNT,
		X_MSG_DATA => X_MSG_DATA
	);
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_pvt.lock_device', FALSE);
		end if;
END LOCK_DEVICE;

--This procdeure would unlock the device.
procedure UNLOCK_DEVICE	 (P_DEVICE_ID IN NUMBER,
                          P_REQUESTER IN NUMBER,
                          P_ORGANIZATION_ID IN NUMBER,
			  X_RETURN_STATUS   OUT NOCOPY VARCHAR2,
			  X_MSG_COUNT       OUT NOCOPY NUMBER,
			  X_MSG_DATA        OUT NOCOPY VARCHAR2)


IS PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNLOCK_DEVICE_MSG');
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('REQUESTER',P_REQUESTER);
		FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',P_ORGANIZATION_ID);

		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.unlock_device', FALSE);
	end if;

	-- call the wms api to unlock the device
	WMS_WCS_DEVICE_GRP.SINGLE_DEVICE_SIGN_OFF
	(
		P_EMPLOYEE_ID => P_REQUESTER,
		P_ORG_ID => P_ORGANIZATION_ID,
		P_DEVICE_ID => P_DEVICE_ID,
		X_RETURN_STATUS => X_RETURN_STATUS,
		X_MSG_COUNT => X_MSG_COUNT,
		X_MSG_DATA => X_MSG_DATA
	);
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_pvt.unlock_device', FALSE);
		end if;
END UNLOCK_DEVICE;

-- this is an internal procedure to invoke wms device request api
PROCEDURE DEVICE_REQUEST (P_BUS_EVENT IN NUMBER,
			  P_ORG_ID IN NUMBER,
			  P_SUBINV IN VARCHAR2,
			  P_DEVICE_ID IN NUMBER,
			  X_REQUEST_MSG OUT NOCOPY VARCHAR2,
			  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
			  X_MSG_COUNT OUT NOCOPY NUMBER,
			  X_MSG_DATA OUT NOCOPY VARCHAR2,
			  X_REQUEST_ID OUT NOCOPY VARCHAR2)

IS PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
	WMS_WCS_DEVICE_GRP.DEVICE_REQUEST
	(
                P_INIT_MSG_LIST    => fnd_api.g_false,
                P_BUS_EVENT        => P_BUS_EVENT,
                P_CALL_CTX          => 'U',
                P_TASK_TRX_ID        => NULL,
                P_ORG_ID           => P_ORG_ID,
                P_ITEM_ID          => -1,
                P_SUBINV           => P_SUBINV,
                P_LOCATOR_ID       => -1,
                P_LPN_ID           => -1,
                P_XFR_ORG_ID       => -1,
                P_XFR_SUBINV       => null,
                P_XFR_LOCATOR_ID     => -1,
                P_TRX_QTY            => -1,
                P_TRX_UOM            => '###',
                P_REV                => '###',
                X_REQUEST_MSG        => X_REQUEST_MSG,
                X_RETURN_STATUS    => X_RETURN_STATUS,
                X_MSG_COUNT        => X_MSG_COUNT,
                X_MSG_DATA            => X_MSG_DATA,
                P_REQUEST_ID        => X_REQUEST_ID,
                P_DEVICE_ID        => P_DEVICE_ID
        );
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END DEVICE_REQUEST;

--This procdeure would clean the data from the temporary tables.
procedure TEMP_DATA_CLEANUP	 (P_CLEANUP_TO_DATE IN DATE DEFAULT NULL,
                          	  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          	  X_MSG_COUNT OUT NOCOPY NUMBER,
                          	  X_MSG_DATA OUT NOCOPY VARCHAR2)

IS

l_cleanup_to_date date;

BEGIN

	l_cleanup_to_date := P_CLEANUP_TO_DATE;

	IF (l_cleanup_to_date IS NULL) THEN
		l_cleanup_to_date := sysdate -2;
	END IF;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_CLEANUP_DATA_MSG');
		FND_MESSAGE.SET_TOKEN('CLEANUP_TO_DATE',P_CLEANUP_TO_DATE);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.temp_data_cleanup', FALSE);
	end if;

	DELETE FROM GMO_DEVICE_RESPONSES_T WHERE REQUEST_ID IN
    (SELECT REQUEST_ID FROM GMO_DEVICE_REQUESTS_T
      WHERE CREATION_DATE < l_cleanup_to_date );

	DELETE FROM GMO_DEVICE_REQUESTS_T WHERE CREATION_DATE < l_cleanup_to_date;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_CLEANUP_SUCCESS_MSG');
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.temp_data_cleanup', FALSE);
	end if;

	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
	WHEN OTHERS THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.temp_data_cleanup', FALSE);
		end if;
END TEMP_DATA_CLEANUP;

-- Internal procedure to insert the device response component for a request
-- This procedure is autonoumous as device request and response are in different db sessions
-- and we want the request to be available for response

PROCEDURE POST_RESPONSE (P_ACTION IN VARCHAR2, P_REQUEST_ID IN NUMBER, P_RESP_COMP_CODE IN VARCHAR2, P_RESP_COMP_CODE_VALUE IN VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

	IF (P_ACTION = ACTION_INSERT_RESPONSE) then
		insert into gmo_device_responses_t
			(
				RESPONSE_ID,
				REQUEST_ID,
				RESP_COMP_CODE,
				RESP_COMP_CODE_VALUE,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE
			) values(
				GMO_DEVICE_RESPONSES_T_S.nextval,
				P_REQUEST_ID,
				P_RESP_COMP_CODE,
				P_RESP_COMP_CODE_VALUE,
				FND_GLOBAL.USER_ID,
				sysdate,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.LOGIN_ID,
				sysdate
			);
	ELSIF (P_ACTION = ACTION_UPDATE_RESPONSE) then

		update gmo_device_responses_t set
			RESP_COMP_CODE_VALUE = P_RESP_COMP_CODE_VALUE,
			LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
			LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
			LAST_UPDATE_DATE = sysdate
		where REQUEST_ID = P_REQUEST_ID
		and RESP_COMP_CODE = P_RESP_COMP_CODE;

	END IF;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_REQUEST_COMP_OPRN_MSG');
		FND_MESSAGE.SET_TOKEN('ACTION', P_ACTION);
		FND_MESSAGE.SET_TOKEN('REQUEST_ID',P_REQUEST_ID);
		FND_MESSAGE.SET_TOKEN('COMPONENT',P_RESP_COMP_CODE);
		FND_MESSAGE.SET_TOKEN('COMPONENT_VALUE',P_RESP_COMP_CODE_VALUE);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.post_response', FALSE);
	end if;

	commit;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_MESSAGE.SET_NAME('GMO','GMO_DVC_REQUEST_COMP_OPRN_ERR');
			FND_MESSAGE.SET_TOKEN('ACTION', P_ACTION);
			FND_MESSAGE.SET_TOKEN('REQUEST_ID',P_REQUEST_ID);
			FND_MESSAGE.SET_TOKEN('COMPONENT',P_RESP_COMP_CODE);
			FND_MESSAGE.SET_TOKEN('COMPONENT_VALUE',P_RESP_COMP_CODE_VALUE);
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.post_response', FALSE);
		end if;
		RAISE;
END;

-- Internal procedure to insert the device request
-- This procedure is autonoumous as device request and response are in different db sessions
-- and we want the request to be available for response

PROCEDURE POST_REQUEST (P_ACTION IN VARCHAR2, P_REQUEST_ID IN NUMBER, P_DEVICE_ID IN NUMBER, P_REQUESTER IN NUMBER, P_DEVICE_STATUS IN VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

	IF (P_ACTION = ACTION_INSERT_REQUEST) then

		INSERT INTO GMO_DEVICE_REQUESTS_T (REQUEST_ID, DEVICE_ID, REQUESTER, RESPONSE_STATUS, DEVICE_STATUS, REQUEST_DATE, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN, LAST_UPDATE_DATE)
		VALUES (P_REQUEST_ID, P_DEVICE_ID, P_REQUESTER, '', P_DEVICE_STATUS, SYSDATE, FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, SYSDATE);

	ELSIF (P_ACTION = ACTION_UPDATE_DEVICE_STATUS) then

		UPDATE GMO_DEVICE_REQUESTS_T SET
			DEVICE_STATUS = P_DEVICE_STATUS,
			LAST_UPDATE_DATE = sysdate,
			LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
			LAST_UPDATED_BY = FND_GLOBAL.USER_ID
			WHERE REQUEST_ID = P_REQUEST_ID AND DEVICE_ID = P_DEVICE_ID;

	ELSIF (P_ACTION = ACTION_UPDATE_DEVICE_RESPONSE) then
		-- update process_device_response
		UPDATE GMO_DEVICE_REQUESTS_T SET
			RESPONSE_STATUS = FND_API.G_RET_STS_SUCCESS,
			LAST_UPDATE_DATE = sysdate,
			LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
			LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		WHERE REQUEST_ID = P_REQUEST_ID AND DEVICE_ID = P_DEVICE_ID;
	END IF;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_REQUEST_OPRN_MSG');
		FND_MESSAGE.SET_TOKEN('ACTION', P_ACTION);
		FND_MESSAGE.SET_TOKEN('REQUEST_ID',P_REQUEST_ID);
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('REQUESTER',P_REQUESTER);
		FND_MESSAGE.SET_TOKEN('DEVICE_STATUS',P_DEVICE_STATUS);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.post_request', FALSE);
	end if;

	commit;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_MESSAGE.SET_NAME('GMO','GMO_DVC_REQUEST_OPRN_ERR');
			FND_MESSAGE.SET_TOKEN('ACTION', P_ACTION);
			FND_MESSAGE.SET_TOKEN('REQUEST_ID',P_REQUEST_ID);
			FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
			FND_MESSAGE.SET_TOKEN('REQUESTER',P_REQUESTER);
			FND_MESSAGE.SET_TOKEN('DEVICE_STATUS',P_DEVICE_STATUS);
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.post_request', FALSE);
		end if;
		RAISE;
END;


--This procedure reads the device.
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
			X_MSG_DATA OUT NOCOPY VARCHAR2)

IS
l_msg_component fnd_table_of_varchar2_255;
l_param_id number;
l_response_code varchar2(30);
l_response_uom varchar2(30);
l_counter binary_integer;
l_param_error varchar2(4000);
l_parameter_name varchar2(300);
l_parameter_map_err exception;
l_response_values fnd_table_of_varchar2_255;
l_uom_counter binary_integer;
l_value_counter binary_integer;

l_uom_mismatch_err exception;



cursor c_get_msg_component is select RESP_COMP_CODE_VALUE, RESP_COMP_CODE_UOM from gmp_resource_device_messages where resource_id = P_RESOURCE_ID and device_id = P_DEVICE_ID and process_param_id = L_PARAM_ID AND EVENT_ID = P_EVENT_ID;
cursor c_get_parameter_details is select parameter_name from gmp_process_parameters where parameter_id = l_param_id;
BEGIN

	l_msg_component := fnd_table_of_varchar2_255();
	l_counter := 0;

	FOR J IN 1..P_PARAMETER_ID.count LOOP
		l_param_id := P_PARAMETER_ID(J);

		-- get the message components (code, and uom) for the parameter
		open c_get_msg_component;
		fetch c_get_msg_component into l_response_code, l_response_uom;
		close c_get_msg_component;

		-- check if they exist, add them to the list
		if (l_response_code is not null and l_response_uom is not null) then
			l_msg_component.extend;
			l_counter := l_counter + 1;
			l_msg_component(l_counter) := l_response_code;

			if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

				FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_COMPONENT_MSG');
				FND_MESSAGE.SET_TOKEN('COMPONENT',l_response_code);
				FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
			end if;

			l_msg_component.extend;
			l_counter := l_counter + 1;
			l_msg_component(l_counter) := l_response_uom;

			if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

				FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_COMPONENT_MSG');
				FND_MESSAGE.SET_TOKEN('COMPONENT',l_response_uom);
				FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
			end if;

		else
			-- if the parameter has no message components, create the error parameter list
			if (l_param_error is not null and length(l_param_error) > 0) then
				l_param_error := l_param_error || ',';
			end if;
			open c_get_parameter_details;
			fetch c_get_parameter_details into l_parameter_name;
			close c_get_parameter_details;
			if (l_parameter_name is null) then
				l_parameter_name := l_param_id;
			end if;
			l_param_error := l_param_error || l_parameter_name;
		end if;

	END LOOP;

	-- validate if there were any parameters not mapped
	IF (l_param_error is not null and length(l_param_error) > 0) then
		raise l_parameter_map_err;
	end if;

	READ_DEVICE
	(
		P_DEVICE_ID => P_DEVICE_ID,
		P_ORGANIZATION_ID => P_ORGANIZATION_ID,
		P_EVENT_ID => P_EVENT_ID,
		P_LOCK_UNLOCK => P_LOCK_UNLOCK,
		P_REQUESTER => P_REQUESTER,
		P_MSG_COMPONENT => L_MSG_COMPONENT,
		X_VALUE => l_response_values,
		X_DEVICE_STATUS => X_DEVICE_STATUS ,
		X_RETURN_STATUS => X_RETURN_STATUS,
		X_MSG_COUNT => X_MSG_COUNT ,
		X_MSG_DATA => X_MSG_DATA
	);

	X_PARAMETER_UOM := fnd_table_of_varchar2_255();
	X_PARAMETER_VALUE := fnd_table_of_varchar2_255();

	IF (X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS) THEN

		l_uom_counter := 0;
		l_value_counter := 0;

		FOR K IN 1..l_response_values.count LOOP
			 -- when we added the message components, code was added first
			 -- and then uom, so all odd elements are value for code
			 -- and all even element are value for parameter UOM
			IF (MOD(K,2) = 0) THEN
				l_uom_counter := l_uom_counter + 1;
				X_PARAMETER_UOM.extend;
				X_PARAMETER_UOM(l_uom_counter) := l_response_values(K);
			else
				l_value_counter := l_value_counter + 1;
				X_PARAMETER_VALUE.extend;
				X_PARAMETER_VALUE(l_value_counter) := l_response_values(K);
			END IF;
		END LOOP;

		l_param_error := '';

		-- validate if the parameter definition uom are passed
		-- if yes match them against the device uom

		IF (P_PARAMETER_UOM_DEFN is not null and P_PARAMETER_UOM_DEFN.count > 0) THEN
			FOR I IN 1..P_PARAMETER_UOM_DEFN.count LOOP

				IF (P_PARAMETER_UOM_DEFN(I) <> X_PARAMETER_UOM(I)) THEN

					if (l_param_error is not null and length(l_param_error) > 0) then
						l_param_error := l_param_error || ',';
					end if;

					l_param_id := P_PARAMETER_ID(I);

					open c_get_parameter_details;
					fetch c_get_parameter_details into l_parameter_name;
					close c_get_parameter_details;

					if (l_parameter_name is null) then
						l_parameter_name := l_param_id;
					end if;

					l_param_error := l_param_error || l_parameter_name;

				END IF;

			END LOOP;
		END IF;

		IF (l_param_error is not null and length(l_param_error) > 0) then
			raise l_uom_mismatch_err;
		end if;

	end if;

EXCEPTION
	WHEN L_PARAMETER_MAP_ERR THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_PARAM_MAP_ERR');
		FND_MESSAGE.SET_TOKEN('PARAMS',l_param_error);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_UOM_MISMATCH_ERR THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_PARAM_UOM_MISMATCH_ERR');
		FND_MESSAGE.SET_TOKEN('PARAMS',l_param_error);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN OTHERS THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.batchstep_material_available', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
END READ_DEVICE;

--This procedure reads the device.
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
			X_MSG_DATA OUT NOCOPY VARCHAR2)

IS

l_wcs_enabled varchar2(1);
l_wcs_disabled_err exception;
l_device_op_method_err exception;
l_org_code varchar2(3);
l_output_method varchar2(30);
l_output_method_id varchar2(30);
l_device_name varchar2(100);
l_device_type varchar2(100);
l_device_desc varchar2(100);
l_subinventory varchar2(30);
l_return_status varchar2(10);
l_msg_count number;
l_msg_data varchar2(4000);
l_lock_device_err exception;
l_unlock_device_err exception;
l_request_id number;
l_read_device_err exception;
l_response_code varchar2(300);
l_response_value varchar2(4000);
l_profile_value varchar2(300);
l_request_msg varchar2(4000);
l_request_start_date date;
l_request_current_date date;
l_timeout_profile_value number;
l_request_exec_time number;
l_response_status varchar2(300);
L_DEVICE_RESPONSE_ERR exception;
L_DEVICE_REQUEST_END boolean;
L_TIMEOUT_ERR exception;
l_device_subinv_err exception;

l_is_device_locked boolean;

l_no_msg_components_err exception;
cursor c_get_org_details is select organization_code from mtl_parameters where organization_id = P_ORGANIZATION_ID;
cursor c_get_device_details is select output_method, output_method_id, name, subinventory_code from wms_devices_vl where device_id = P_DEVICE_ID;
cursor c_get_device_response is select RESP_COMP_CODE_VALUE from gmo_device_responses_t where request_id = l_request_id and RESP_COMP_CODE = l_response_code;



BEGIN
	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_DEVICE_MSG');
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',P_ORGANIZATION_ID);
		FND_MESSAGE.SET_TOKEN('REQUESTER',P_REQUESTER);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;

	-- validate if any message components were passed
	IF (P_MSG_COMPONENT is null or P_MSG_COMPONENT.COUNT = 0) THEN
		raise l_no_msg_components_err;
	END IF;

	l_wcs_enabled := WMS_WCS_DEVICE_GRP.IS_WCS_ENABLED (P_ORGANIZATION_ID);

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_WCS_ORG_ENABLED_MSG');
		FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',P_ORGANIZATION_ID);
		FND_MESSAGE.SET_TOKEN('ENABLED_FLAG',l_wcs_enabled);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;

	-- check if the organization is wcs enabled
	-- this is required from wms architecture perspective

	if (nvl (l_wcs_enabled, GMO_CONSTANTS_GRP.NO) = GMO_CONSTANTS_GRP.NO) then

		open c_get_org_details;
		fetch c_get_org_details into l_org_code;
		close c_get_org_details;

		raise l_wcs_disabled_err;
	end if;

	open c_get_device_details;
	fetch c_get_device_details into l_output_method, l_output_method_id, l_device_name, l_subinventory;
	close c_get_device_details;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_OUTPUT_METHOD_MSG');
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('DEVICE',l_device_name);
		FND_MESSAGE.SET_TOKEN('OUTPUT_METHOD',l_output_method);
		FND_MESSAGE.SET_TOKEN('OUTPUT_METHOD_ID',l_output_method_id);
		 FND_MESSAGE.SET_TOKEN('SUBINVENTORY', l_subinventory);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;

	-- for device response, the output method should always be API (outputmethod id 2).
	if (l_output_method_id <> '2') then
		raise l_device_op_method_err;
	end if;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_REQUEST_ID_MSG');
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;



	if (P_LOCK_UNLOCK = GMO_CONSTANTS_GRP.YES) THEN
		l_is_device_locked := true;
		LOCK_DEVICE	 (P_DEVICE_ID => P_DEVICE_ID,
                      P_REQUESTER => P_REQUESTER,
                      P_ORGANIZATION_ID => P_ORGANIZATION_ID,
					  X_DEVICE_TYPE     => l_device_type,
					  X_DEVICE_DESC     => l_device_desc,
  					  X_SUBINVENTORY    => l_subinventory,
					  X_RETURN_STATUS   => l_return_status,
					  X_MSG_COUNT => l_msg_count,
					  X_MSG_DATA  => l_msg_data);
		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE L_LOCK_DEVICE_ERR;
		end if;
	end if;

	-- validate the device is associated to a subinventory.
	if (l_subinventory is null or length(l_subinventory) = 0) then
		raise l_device_subinv_err;
	end if;

	select sysdate into l_request_start_date from dual;


	DEVICE_REQUEST
	(
		P_BUS_EVENT        => p_event_id, -- business event id 18 or 19
		P_ORG_ID           => p_organization_id, -- organization id
		P_SUBINV           => l_subinventory, -- it will have the device sub inventory
		P_DEVICE_ID        => p_device_id, -- device id
		X_REQUEST_MSG        => l_request_msg, -- out parameter
		X_RETURN_STATUS    => l_return_status, -- out parameter
		X_MSG_COUNT        => l_msg_count, -- out parameter
		X_MSG_DATA            => l_msg_data, -- out parameter
		X_REQUEST_ID        => l_request_id -- out parameter
	);

	POST_REQUEST (P_ACTION => ACTION_INSERT_REQUEST, P_REQUEST_ID => l_request_id, P_DEVICE_ID => P_DEVICE_ID , P_REQUESTER => P_REQUESTER , P_DEVICE_STATUS => '');

	FOR I IN 1..P_MSG_COMPONENT.count LOOP
		POST_RESPONSE (P_ACTION => ACTION_INSERT_RESPONSE, P_REQUEST_ID => l_request_id, P_RESP_COMP_CODE => P_MSG_COMPONENT(I), P_RESP_COMP_CODE_VALUE => '');
	END LOOP;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_DEVICE_STATUS_MSG');
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MESSAGE.SET_TOKEN('DEVICE_STATUS',l_return_status);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;

	POST_REQUEST (P_ACTION => ACTION_UPDATE_DEVICE_STATUS, P_REQUEST_ID => l_request_id, P_DEVICE_ID => P_DEVICE_ID , P_REQUESTER => P_REQUESTER , P_DEVICE_STATUS => l_return_status);
	X_DEVICE_STATUS := l_return_status;

 	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		RAISE l_read_device_err;
	end if;

	L_DEVICE_REQUEST_END := FALSE;

	l_timeout_profile_value := -1;
	l_profile_value := fnd_profile.value(NAME => 'GMO_DVC_READ_TIMEOUT');
	if (l_profile_value is not null) then
		l_timeout_profile_value := to_number(l_profile_value);
	end if;

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_TIMEOUT_VALUE_MSG');
		FND_MESSAGE.SET_TOKEN('TIMEOUT',l_profile_value);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;


	-- we will loop till the response is recevied or timeout (based on profile) has reached.

	WHILE NOT L_DEVICE_REQUEST_END LOOP

	   select sysdate into l_request_current_date from dual;
	   l_request_exec_time := (l_request_current_date - l_request_start_date)*24*60*60;

	   select RESPONSE_STATUS into l_response_status from gmo_device_requests_t where request_id = l_request_id;

	   if (l_response_status is not null) then
	   		L_DEVICE_REQUEST_END := TRUE;

			if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_MESSAGE.SET_NAME('GMO','GMO_DVC_RESPONSE_RECD_MSG');
				FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
			end if;

			IF (l_response_status <> FND_API.G_RET_STS_SUCCESS) THEN
				RAISE L_DEVICE_RESPONSE_ERR;
			END IF;
	   elsif (l_timeout_profile_value > -1 and l_request_exec_time > l_timeout_profile_value) then
			if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
				FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_TIMEOUT_MSG');
				FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
			end if;
			L_DEVICE_REQUEST_END := TRUE;

			raise l_timeout_err;
	   end if;

	END LOOP;

	X_VALUE := fnd_table_of_varchar2_255();

	if (P_LOCK_UNLOCK = GMO_CONSTANTS_GRP.YES) THEN
		UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID,
					  P_REQUESTER => P_REQUESTER,
                      P_ORGANIZATION_ID => P_ORGANIZATION_ID,
					  X_RETURN_STATUS   => l_return_status,
					  X_MSG_COUNT => l_msg_count,
					  X_MSG_DATA  => l_msg_data);
		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			RAISE L_UNLOCK_DEVICE_ERR;
		end if;
	end if;

	FOR K IN 1..P_MSG_COMPONENT.count LOOP
		l_response_code := P_MSG_COMPONENT(K);
		open c_get_device_response;
		fetch c_get_device_response into l_response_value;
		close c_get_device_response;

		X_VALUE.extend;
		X_VALUE(K) := l_response_value;

	END LOOP;

	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN L_NO_MSG_COMPONENTS_ERR THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_NO_MSG_COMP_ERR');
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_WCS_DISABLED_ERR THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_WCS_DISABLED_ORG_ERR');
		FND_MESSAGE.SET_TOKEN('ORGN',L_ORG_CODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_DEVICE_OP_METHOD_ERR THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_OUTPUT_METHOD_ERR');
		FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_LOCK_DEVICE_ERR THEN
		if (l_is_device_locked = true) then
			UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
					X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
		end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_LOCK_DEVICE_ERR');
		FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN l_device_subinv_err THEN
		if (l_is_device_locked = true) then
                        UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
                                        X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
                end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('GMO','GMO_DVC_SUBINV_DEVICE_ERR');
                FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
                FND_MSG_PUB.ADD;
                FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
                if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
                end if;
--                APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_READ_DEVICE_ERR THEN
		if (l_is_device_locked = true) then
                        UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
                                        X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
                end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_DEVICE_ERR');
		FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_TIMEOUT_ERR	THEN
		if (l_is_device_locked = true) then
                        UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
                                        X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
                end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_READ_TIMEOUT_ERR');
		FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_DEVICE_RESPONSE_ERR THEN
		if (l_is_device_locked = true) then
                        UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
                                        X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
                end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_RESPONSE_ERR');
		FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN L_UNLOCK_DEVICE_ERR THEN
		if (l_is_device_locked = true) then
                        UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
                                        X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
                end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNLOCK_DEVICE_ERR');
		FND_MESSAGE.SET_TOKEN('DEVICE',L_DEVICE_NAME);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN OTHERS THEN
		if (l_is_device_locked = true) then
                        UNLOCK_DEVICE(P_DEVICE_ID => P_DEVICE_ID, P_REQUESTER => P_REQUESTER, P_ORGANIZATION_ID => P_ORGANIZATION_ID,
                                        X_RETURN_STATUS   => l_return_status, X_MSG_COUNT => l_msg_count, X_MSG_DATA  => l_msg_data);
                end if;
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.read_device', FALSE);
		end if;
--		APP_EXCEPTION.RAISE_EXCEPTION;
END READ_DEVICE;


--This procedure would process the device response
PROCEDURE PROCESS_DEVICE_RESPONSE ( P_REQUEST_ID IN NUMBER,
				    P_DEVICE_ID IN NUMBER,
				    P_PARAM_VALUES_RECORD IN  WMS_WCS_DEVICE_GRP.MSG_COMPONENT_LOOKUP_TYPE,
				    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
				    X_MSG_COUNT OUT NOCOPY NUMBER,
				    X_MSG_DATA OUT NOCOPY VARCHAR2)

IS

l_count number;
l_request_not_found_err exception;

BEGIN

	if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_PROCESS_RESPONSE_MSG');
		FND_MESSAGE.SET_TOKEN('REQUEST_ID',P_REQUEST_ID);
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,'gmo.plsql.gmo_dvc_intg_pvt.read_device', FALSE);
	end if;

	select count(*) into l_count from GMO_DEVICE_REQUESTS_T WHERE REQUEST_ID = P_REQUEST_ID AND DEVICE_ID = P_DEVICE_ID;

	if (l_count = 0) then
		raise l_request_not_found_err;
	end if;

	-- the P_RESP_COMP_CODE is based on the lookup type WMS_DEVICE_MSG_COMPONENTS,
	-- which was used during resource-device mapping

	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'1' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.ORGANIZATION);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'2' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.ORDER_NUMBER);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'3' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.ITEM);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'4' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.BUSINESS_EVENT);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'10' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.LPN);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'11' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.LOT);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'12' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.UOM);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'13' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.CYCLE_COUNT_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'14' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.QUANTITY);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'15' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.REQUESTED_QUANTITY);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'16' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.WEIGHT);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'17' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.WEIGHT_UOM_CODE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'18' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.VOLUME);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'19' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.VOLUME_UOM_CODE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'20' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.LENGTH);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'21' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.WIDTH);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'22' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.HEIGHT);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'23' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DIMENSIONAL_WEIGHT);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'24' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DIMENSIONAL_WEIGHT_FACTOR);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'25' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.NET_WEIGHT);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'26' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.RECEIVED_REQUEST_DATE_AND_TIME);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'27' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.MEASUREMENT_DATE_AND_TIME);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'28' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.RESPONSE_DATE_AND_TIME);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'29' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.TEMPERATURE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'30' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.TEMPERATURE_UOM);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'31' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.REASON_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'32' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.REASON_TYPE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'33' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.SENSOR_MEASUREMENT_TYPE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'34' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.VALUE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'35' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.QUALITY);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'36' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.OPC_VARIANT_CODE);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'37' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.EPC);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'38' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.UNUSED);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'39' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.BATCH);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'40' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_1);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'41' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_2);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'42' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_3);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'43' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_4);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'44' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_5);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'45' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_6);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'46' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_7);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'47' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_8);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'48' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_9);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'49' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_COMPONENT_10);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'50' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.RELATION_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'51' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.TASK_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'52' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.TASK_SUMMARY);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'53' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.ORGANIZATION_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'54' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.INVENTORY_ITEM_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'55' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DEVICE_STATUS);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'56' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.TRANSFER_LPN_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'57' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DESTINATION_SUBINVENTORY);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'58' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.DESTINATION_LOCATOR_ID);
	POST_RESPONSE (P_ACTION => ACTION_UPDATE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_RESP_COMP_CODE =>'59' , P_RESP_COMP_CODE_VALUE => P_PARAM_VALUES_RECORD.SOURCE_LOCATOR_ID);

	-- update process_device_response
	POST_REQUEST (P_ACTION => ACTION_UPDATE_DEVICE_RESPONSE, P_REQUEST_ID => P_REQUEST_ID, P_DEVICE_ID => P_DEVICE_ID , P_REQUESTER => FND_GLOBAL.USER_ID , P_DEVICE_STATUS => '');

	X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN L_REQUEST_NOT_FOUND_ERR THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_REQUEST_FOR_RESP_ERR');
		FND_MESSAGE.SET_TOKEN('REQUEST_ID',P_REQUEST_ID);
		FND_MESSAGE.SET_TOKEN('DEVICE_ID',P_DEVICE_ID);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dvc_intg_grp.process_device_response', FALSE);
		end if;
	WHEN OTHERS THEN
		X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MESSAGE.SET_NAME('GMO','GMO_DVC_UNEXPECTED_DB_ERR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
		FND_MESSAGE.SET_TOKEN('ERROR_CODE',SQLCODE);
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
		if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
			FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,'gmo.plsql.gmo_dvc_intg_grp.process_device_response', FALSE);
		end if;
END PROCESS_DEVICE_RESPONSE;

END GMO_DVC_INTG_PVT;

/
