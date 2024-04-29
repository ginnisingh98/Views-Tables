--------------------------------------------------------
--  DDL for Package Body WSH_OTM_SYNC_REF_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OTM_SYNC_REF_DATA_PKG" AS
/* $Header: WSHTMTHB.pls 120.0.12000000.1 2007/01/25 16:15:16 amohamme noship $ */

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_OTM_SYNC_REF_DATA_PKG';

PROCEDURE is_ref_data_send_reqd(p_entity_id IN NUMBER,
				p_parent_entity_id IN VARCHAR2,
				p_entity_type IN VARCHAR2,
				p_entity_updated_date IN DATE,
				x_substitute_entity OUT NOCOPY VARCHAR2,
				p_transmission_id IN NUMBER,
				x_send_allowed OUT NOCOPY BOOLEAN,
				x_return_status OUT NOCOPY VARCHAR2
				) IS

--Cursor to check whether the entity exists in WOSRD
CURSOR c_entity_exists(p_id NUMBER, p_type VARCHAR2, p_parent_id NUMBER) IS
SELECT	sync_ref_id,
	substitute_entity,
	last_sent_date
FROM	wsh_otm_sync_ref_data
WHERE	entity_id = p_id
AND	entity_type = p_type
AND	parent_entity_id = nvl(p_parent_id,0);

/*
--Cursor to find whether the item was updated in MSI after it was sent to GLOG
CURSOR c_check_item_date(p_item_id NUMBER, p_entity_type VARCHAR2) IS
SELECT	msi.last_update_date,
	wosrd.sync_ref_id,
	wosrd.substitute_entity
FROM	mtl_system_items msi,
	wsh_otm_sync_ref_data wosrd
WHERE	msi.inventory_item_id = p_item_id
AND	wosrd.entity_type = p_entity_type
AND	wosrd.entity_id = msi.inventory_item_id
AND	msi.last_update_date > wosrd.last_sent_date;

----Cursor to find whether the location was updated in MSI after it was sent to GLOG
CURSOR c_check_location_date(p_location_id NUMBER, p_entity_type VARCHAR2) IS
SELECT	wl.last_update_date,
	wosrd.sync_ref_id,
	wosrd.substitute_entity
FROM	wsh_locations wl,
	wsh_otm_sync_ref_data wosrd
WHERE	wl.wsh_location_id = p_location_id
AND	wosrd.entity_type = p_entity_type
AND	wosrd.entity_id = wl.wsh_location_id
AND	wl.last_update_date > wosrd.last_sent_date;
*/
l_check_entity_exists NUMBER := 0;
l_last_update_date DATE;
l_last_sent_date DATE;
l_substitute_entity VARCHAR2(50);
l_sync_ref_id NUMBER;

l_num_errors      NUMBER := 0;
l_num_warnings    NUMBER := 0;
l_return_status VARCHAR2(1);
e_entity_type_error EXCEPTION;

l_debug_on BOOLEAN ;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IS_REF_DATA_SEND_REQD';

BEGIN

-- Debug Statements
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
x_send_allowed := FALSE;

IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID ',p_entity_id);
	WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ENTITY_ID ',p_parent_entity_id);
	WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE ',p_entity_type);
	WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_UPDATED_DATE ',p_entity_updated_date);
	WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID ',p_transmission_id);
END IF;

--Check whether the entity exists in wosrd
OPEN c_entity_exists(p_entity_id, p_entity_type, p_parent_entity_id);
LOOP
	FETCH c_entity_exists INTO l_sync_ref_id, l_substitute_entity, l_last_sent_date;
	EXIT WHEN c_entity_exists%NOTFOUND;
END LOOP;
CLOSE c_entity_exists;

--Check for l_sync_ref_id.
--If its null that means the entity has never been sent to GLOG
--and we have to make and entry both in WOSRD and WOSRDL.
IF l_sync_ref_id is null THEN
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'l_sync_ref_id IS NULL');
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.INSERT_ROW_SYNC_REF_DATA',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	insert_row_sync_ref_data(p_entity_id => p_entity_id ,
				p_parent_entity_id => p_parent_entity_id,
				p_entity_type => p_entity_type,
				p_transmission_id => p_transmission_id,
                                x_sync_ref_id     => l_sync_ref_id,
				x_substitute_entity => l_substitute_entity,
				x_return_status => l_return_status
				);
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_util_core.api_post_call(
	p_return_status    => l_return_status,
	x_num_warnings     => l_num_warnings,
	x_num_errors       => l_num_errors);

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.INSERT_ROW_SYNC_REF_DATA_LOG',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	insert_row_sync_ref_data_log	(p_sync_ref_id => l_sync_ref_id,
					p_transmission_id => p_transmission_id,
                                        p_entity_type => p_entity_type,
					x_return_status => l_return_status
					);
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	wsh_util_core.api_post_call(
	p_return_status    => l_return_status,
	x_num_warnings     => l_num_warnings,
	x_num_errors       => l_num_errors);

	x_send_allowed := true;
ELSE --means that entry in WOSRD is already there and just have to check the dates.
	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'l_sync_ref_id ', l_sync_ref_id);
	END IF;

	IF p_entity_updated_date >= l_last_sent_date OR
	   to_number(sysdate - l_last_sent_date) <= 1 THEN

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_OTM_SYNC_REF_DATA_PKG.INSERT_ROW_SYNC_REF_DATA_LOG',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		insert_row_sync_ref_data_log	(p_sync_ref_id => l_sync_ref_id,
						p_transmission_id => p_transmission_id,
                                                p_entity_type => p_entity_type,
						x_return_status => l_return_status
						);
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.API_POST_CALL',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		wsh_util_core.api_post_call(
		p_return_status    => l_return_status,
		x_num_warnings     => l_num_warnings,
		x_num_errors       => l_num_errors);

		x_send_allowed := TRUE;
	END IF;
END IF;

x_substitute_entity := l_substitute_entity;

IF (l_num_warnings > 0 AND x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN e_entity_type_error THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR ;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'wrong entity type passed',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WRONG_ENTITY_TYPE');
		raise;
	END IF;
WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		raise;
	END IF;

END is_ref_data_send_reqd;

PROCEDURE update_ref_data(	p_transmission_id IN NUMBER,
				p_transmission_status IN VARCHAR2,
				x_return_status OUT NOCOPY VARCHAR2
				) IS

--Cursor to get sync_ref_id's for given transmission_id
CURSOR c_get_sync_ref_id(p_trans_id NUMBER) IS
SELECT	distinct entity_type, sync_ref_id
FROM	wsh_otm_sync_ref_data_log
WHERE	transmission_id = p_trans_id
ORDER BY entity_type, sync_ref_id;


--Cursor to lock the record in wsh_otm_sync_ref_data
CURSOR c_lock_parent_table(p_sync_ref_id NUMBER) IS
SELECT	1
FROM	wsh_otm_sync_ref_data
WHERE	sync_ref_id = p_sync_ref_id
FOR UPDATE NOWAIT;

--Cursor to obtain the first sent_date
CURSOR c_get_sent_date(p_sync_id NUMBER) IS
SELECT	sent_date
FROM	wsh_otm_sync_ref_data_log
WHERE	sync_ref_id = p_sync_id
AND	rownum = 1;


l_recinfo c_lock_parent_table%ROWTYPE;
l_sync_ref_id NUMBER;
l_entity_type VARCHAR2(100);
l_sent_date DATE;

l_dummy_fetch VARCHAR2(10);

l_debug_on BOOLEAN ;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_REF_DATA';

BEGIN

-- Debug Statements
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID ',p_transmission_id);
	WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_STATUS ',p_transmission_status);
END IF;

IF p_transmission_status = 'S' THEN
	--Get the sync ref ids for the transmission id
	OPEN c_get_sync_ref_id(p_transmission_id);
	LOOP
		FETCH c_get_sync_ref_id INTO l_entity_type, l_sync_ref_id;
		EXIT WHEN c_get_sync_ref_id%NOTFOUND;

		DECLARE
		l_notfound BOOLEAN;
		BEGIN
			OPEN c_lock_parent_table(l_sync_ref_id);
			FETCH c_lock_parent_table INTO l_dummy_fetch;

			IF c_lock_parent_table%NOTFOUND THEN
				-- probably taken care of by another request go to next record
				GOTO next_sync_ref_id;
			END IF;

			CLOSE c_lock_parent_table;

                        IF l_debug_on THEN
	                  WSH_DEBUG_SV.log(l_module_name,'Obtained the lock for l_sync_ref_id ', l_sync_ref_id);
                        END IF;

			--Obtain the first sent_date for the l_sync_ref_id
			OPEN c_get_sent_date(l_sync_ref_id);
			FETCH c_get_sent_date into l_sent_date;
			CLOSE c_get_sent_date;

                        IF l_debug_on THEN
	                  WSH_DEBUG_SV.log(l_module_name,'sent_date', l_sent_date);
                        END IF;

			--Update last_sent_date of WOSRD with sent_date of WOSRDL.sent_date
			UPDATE	wsh_otm_sync_ref_data
			SET	last_sent_date = l_sent_date
			WHERE	sync_ref_id = l_sync_ref_id;

                        IF l_debug_on THEN
	                  WSH_DEBUG_SV.log(l_module_name,'Updated ', SQL%ROWCOUNT);
                        END IF;

			--Delete data from WOSRDL for l_sync_ref_id
			DELETE
			FROM	wsh_otm_sync_ref_data_log
			WHERE	sync_ref_id = l_sync_ref_id;

		EXCEPTION
		WHEN OTHERS THEN
		NULL;
		END;

		<<next_sync_ref_id>>
		NULL;

	END LOOP;
	CLOSE c_get_sync_ref_id;
ELSE
	--Since this is an error case delete all the data from WOSRDL for given transmission_id
	IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name,'Error case. So deleting all the data from WOSRDL for transmission_id ', p_transmission_id);
	END IF;

	DELETE
	FROM	wsh_otm_sync_ref_data_log
	WHERE	transmission_id = p_transmission_id;
END IF;

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		raise;
	END IF;

END update_ref_data;

PROCEDURE insert_row_sync_ref_data(	p_entity_id IN NUMBER,
					p_parent_entity_id IN NUMBER,
					p_entity_type IN VARCHAR2,
					p_transmission_id IN NUMBER,
                                        x_sync_ref_id     OUT NOCOPY NUMBER,
					x_substitute_entity OUT NOCOPY VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2
				  ) IS

PRAGMA AUTONOMOUS_TRANSACTION; --since its an autonomous transaction

CURSOR c_entity_exists(p_id NUMBER, p_type VARCHAR2) IS
SELECT	entity_id, parent_entity_id
FROM	wsh_otm_sync_ref_data
WHERE	entity_id = p_id
AND	entity_type = p_type
AND	substitute_entity IS NULL;

l_sync_ref_id NUMBER;
l_substitute_entity VARCHAR2(50);
l_entity_id NUMBER;
l_parent_entity_id NUMBER;
l_check_entity_exists NUMBER := 0;
l_entity_type VARCHAR2(50);

l_debug_on BOOLEAN ;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW_SYNC_REF_DATA';

BEGIN

-- Debug Statements
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID ',p_entity_id);
	WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ENTITY_ID ',p_parent_entity_id);
	WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE ',p_entity_type);
	WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID ',p_transmission_id);
END IF;

--Check whether the input entity id and type exists or not
OPEN c_entity_exists(p_entity_id, p_entity_type);
LOOP
	FETCH c_entity_exists INTO l_entity_id, l_parent_entity_id;
	EXIT WHEN c_entity_exists%NOTFOUND;
END LOOP;
CLOSE c_entity_exists;

IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'After opening cursor c_entity_exists');
	WSH_DEBUG_SV.log(l_module_name,'l_entity_id ', l_entity_id);
	WSH_DEBUG_SV.log(l_module_name,'l_parent_entity_id ', l_parent_entity_id);
END IF;

--get the value for substitute_entity. Also check the value of p_parent_entity_id here.
IF l_entity_id is not null THEN
	--Get the value into l_entity_type
	IF p_entity_type = 'CUST_LOC' THEN
		l_entity_type := 'CUS';
	ELSIF p_entity_type = 'ORG_LOC' THEN
		l_entity_type := 'ORG';
	ELSIF p_entity_type = 'CAR_LOC' THEN
		l_entity_type := 'CAR';
	END IF;

	IF l_parent_entity_id IS NULL OR l_parent_entity_id = 0 THEN
		l_substitute_entity := l_entity_type || '-' || '000' || '-' || p_entity_id ;
	ELSE
		l_substitute_entity := l_entity_type || '-' || l_parent_entity_id || '-' || p_entity_id ;
	END IF;
END IF;

--Insert data into the table
BEGIN
	INSERT INTO wsh_otm_sync_ref_data	(sync_ref_id,
						entity_id,
						parent_entity_id,
						entity_type,
						substitute_entity,
						last_sent_date,
						called_by_module,
						additional_num,
						additional_char,
						additional_date,
						creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login
						)
					VALUES	(wsh_otm_sync_ref_data_s.NEXTVAL,
						p_entity_id,
						nvl(p_parent_entity_id,0),
						p_entity_type,
						l_substitute_entity,
						to_date('1900/01/01 00:00:01', 'YYYY/MM/DD HH24:MI:SS'),
						'WSH-TXN',
						NULL,
						NULL,
						NULL,
						SYSDATE, --creation_date
						FND_GLOBAL.USER_ID,
						SYSDATE, --last_update_date
						FND_GLOBAL.USER_ID,
						FND_GLOBAL.USER_ID
						) returning sync_ref_id into x_sync_ref_id;
EXCEPTION
WHEN OTHERS THEN

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Exception while inserting data into WOSRD ' || SQLERRM);
	END IF;

	SELECT	substitute_entity
	INTO	l_substitute_entity
	FROM	wsh_otm_sync_ref_data
	WHERE	entity_id = p_entity_id
	AND	parent_entity_id = nvl(p_parent_entity_id,0)
	AND	entity_type = p_entity_type;
END;

x_substitute_entity := l_substitute_entity;
x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;
COMMIT;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		raise;
	END IF;
	ROLLBACK;
END insert_row_sync_ref_data;

PROCEDURE insert_row_sync_ref_data_log(	p_sync_ref_id NUMBER,
					p_transmission_id NUMBER,
                                        p_entity_type VARCHAR2,
					x_return_status OUT NOCOPY VARCHAR2
					) IS

l_debug_on BOOLEAN ;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW_SYNC_REF_DATA_LOG';

BEGIN

-- Debug Statements
--
l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
--
IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
END IF;

IF l_debug_on THEN
	WSH_DEBUG_SV.push(l_module_name);
	WSH_DEBUG_SV.log(l_module_name,'P_SYNC_REF_ID ',p_sync_ref_id);
	WSH_DEBUG_SV.log(l_module_name,'P_TRANSMISSION_ID ',p_transmission_id);
	WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE ',P_ENTITY_TYPE);
END IF;

--Inset data into the table
INSERT INTO wsh_otm_sync_ref_data_log	(transmission_id,
					sync_ref_id,
                                        entity_type,
					sent_date,
					creation_date,
					created_by,
					last_update_date,
					last_updated_by,
					last_update_login
					)
VALUES					(p_transmission_id,
					 p_sync_ref_id,
                                         p_entity_type,
					 SYSDATE, --sent_date
					 SYSDATE, --creation_date
					 FND_GLOBAL.USER_ID,
					 SYSDATE, --last_update_date
					 FND_GLOBAL.USER_ID,
					 FND_GLOBAL.USER_ID
					);

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

IF l_debug_on THEN
	WSH_DEBUG_SV.pop(l_module_name);
END IF;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		raise;
	END IF;

END insert_row_sync_ref_data_log;

END WSH_OTM_SYNC_REF_DATA_PKG;

/
