--------------------------------------------------------
--  DDL for Package Body WSH_RU_ROLE_PRIVILEGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_RU_ROLE_PRIVILEGES_PVT" AS
/* $Header: WSHRPTHB.pls 120.0 2005/05/29 14:11:46 appldev noship $ */

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_RU_ROLE_PRIVILEGES_PVT';
  --
  PROCEDURE Insert_Row(
	p_role_privilege_record	IN  Role_Privilege_Type,
	x_rowid		        OUT NOCOPY  VARCHAR2,
	x_role_privilege_id	OUT NOCOPY  NUMBER,
	x_return_status         OUT NOCOPY  VARCHAR2) IS

    CURSOR c_new_role_privilege_id IS
       SELECT wsh_role_privileges_s.nextval FROM DUAL;

    CURSOR c_role_privilege_rowid(x_role_privilege_id IN NUMBER) IS
       SELECT rowid FROM WSH_ROLE_PRIVILEGES WHERE role_privilege_id = x_role_privilege_id;

    l_role_privilege_id NUMBER(15)   := NULL;
    l_rowid    VARCHAR2(18) := '';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
--
  BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        WSH_DEBUG_SV.log(l_module_name,'role_privilege_id',
                                    p_role_privilege_record.role_privilege_id);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    l_role_privilege_id := p_role_privilege_record.role_privilege_id;

    IF l_role_privilege_id IS NULL THEN
      OPEN  c_new_role_privilege_id;
      FETCH c_new_role_privilege_id INTO l_role_privilege_id;
      CLOSE c_new_role_privilege_id;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'l_role_privilege_id',l_role_privilege_id)
  ;
      END IF;
    END IF;

    INSERT INTO WSH_ROLE_PRIVILEGES (
	ROLE_PRIVILEGE_ID,
	ROLE_ID,
	PRIVILEGE_CODE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	) VALUES (
	l_role_privilege_id,
	p_role_privilege_record.ROLE_ID,
	p_role_privilege_record.PRIVILEGE_CODE,
	p_role_privilege_record.CREATED_BY,
	p_role_privilege_record.CREATION_DATE,
	p_role_privilege_record.LAST_UPDATED_BY,
	p_role_privilege_record.LAST_UPDATE_DATE,
	p_role_privilege_record.LAST_UPDATE_LOGIN
	);

    OPEN  c_role_privilege_rowid(l_role_privilege_id);
    FETCH c_role_privilege_rowid INTO l_rowid;
    IF c_role_privilege_rowid%NOTFOUND THEN
      CLOSE c_role_privilege_rowid;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_role_privilege_rowid;

    x_rowid    := l_rowid;
    x_role_privilege_id := l_role_privilege_id;
    --
    IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ROLE_PRIVILEGES_PVT.INSERT_ROW',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
  END Insert_Row;


  PROCEDURE Lock_Row(
	p_rowid		IN VARCHAR2,
	p_role_privilege_record	IN Role_Privilege_Type) IS

    CURSOR c_lock_role_privilege IS
	SELECT * FROM WSH_ROLE_PRIVILEGES
	WHERE rowid = p_rowid
	FOR UPDATE OF ROLE_PRIVILEGE_ID NOWAIT;

    l_db_rec c_lock_role_privilege%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
--
  BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
    END IF;
    --
    OPEN  c_lock_role_privilege;
    FETCH c_lock_role_privilege INTO l_db_rec;
    IF c_lock_role_privilege%NOTFOUND THEN
      CLOSE c_lock_role_privilege;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');
      END IF;
      app_exception.raise_exception;
    END IF;
    CLOSE c_lock_role_privilege;

    IF     (l_db_rec.ROLE_ID = p_role_privilege_record.ROLE_ID)
       AND (l_db_rec.PRIVILEGE_CODE = p_role_privilege_record.PRIVILEGE_CODE)
       AND (l_db_rec.CREATED_BY = p_role_privilege_record.CREATED_BY)
       AND (l_db_rec.CREATION_DATE = p_role_privilege_record.CREATION_DATE)
       AND (l_db_rec.LAST_UPDATED_BY = p_role_privilege_record.LAST_UPDATED_BY)
       AND (l_db_rec.LAST_UPDATE_DATE = p_role_privilege_record.LAST_UPDATE_DATE)
       AND ((l_db_rec.LAST_UPDATE_LOGIN = p_role_privilege_record.LAST_UPDATE_LOGIN)
            OR (    l_db_rec.LAST_UPDATE_LOGIN IS NULL
                AND p_role_privilege_record.LAST_UPDATE_LOGIN IS NULL))
    THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'Noting Changed');
      END IF;
      --
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_CHANGED');
      END IF;
      app_exception.raise_exception;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
	WHEN app_exception.application_exception
             or app_exception.record_lock_exception THEN

	      if (c_lock_role_privilege%ISOPEN) then
		  close c_lock_role_privilege;
	      end if;
	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

	WHEN others THEN

	      if (c_lock_role_privilege%ISOPEN) then
		  close c_lock_role_privilege;
	      end if;

	      FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('PACKAGE', 'WSH_RU_ROLE_PRIVILEGES_PVT.LOCK_ROW');
	      FND_MESSAGE.Set_Token('ORA_ERROR',sqlcode);
	      FND_MESSAGE.Set_Token('ORA_TEXT',sqlerrm);
	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	      END IF;
	      --
	      RAISE;
  END Lock_Row;


  PROCEDURE Update_Row(
	p_rowid		IN  VARCHAR2,
	p_role_privilege_record	IN  Role_Privilege_Type,
	x_return_status OUT NOCOPY  VARCHAR2) IS
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
	--
  BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
    END IF;
    --
    UPDATE WSH_ROLE_PRIVILEGES
    SET
	ROLE_ID		  =  p_role_privilege_record.ROLE_ID,
	PRIVILEGE_CODE	  =  p_role_privilege_record.PRIVILEGE_CODE,
	CREATED_BY	  =  p_role_privilege_record.CREATED_BY,
	CREATION_DATE	  =  p_role_privilege_record.CREATION_DATE,
	LAST_UPDATED_BY	  =  p_role_privilege_record.LAST_UPDATED_BY,
	LAST_UPDATE_DATE  =  p_role_privilege_record.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN =  p_role_privilege_record.LAST_UPDATE_LOGIN
    WHERE rowid = p_rowid;

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Rows Updated',SQL%ROWCOUNT);
    END IF;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
      WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ROLE_PRIVILEGES_PVT.UPDATE_ROW',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
  END Update_Row;


  PROCEDURE Delete_Row(
	p_rowid		IN  VARCHAR2,
	x_return_status OUT NOCOPY  VARCHAR2) IS
	--
l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
	--
  BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
    END IF;
    --
    DELETE FROM WSH_ROLE_PRIVILEGES
    WHERE rowid = p_rowid;
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows Deleted',SQL%ROWCOUNT);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
      WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ROLE_PRIVILEGES_PVT.DELETE_ROW',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
  END Delete_Row;


  -- This will delete all the data access privileges attached
  -- to that role from wsh_role_privileges.
  -- Following are the data access privileges.
  -- TRIP_VIEW, TRIP_EDIT, STOP_VIEW, STOP_EDIT, DLVY_VIEW,
  -- DLVY_EDIT, DLVB_VIEW, DLVB_EDIT', GENR_VIEW, GENR_EDIT

  PROCEDURE Delete_Role_Privileges(p_role_id in NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2)


  IS

  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROLE';


  BEGIN
    --
    --
    l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
    --
    IF l_debug_on IS NULL
    THEN
        l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
    END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_ID',P_ROLE_ID);
    END IF;
    --
    DELETE FROM WSH_ROLE_PRIVILEGES
    WHERE role_id = p_role_id
    AND    privilege_code
	         IN('TRIP_VIEW','TRIP_EDIT',
	            'STOP_VIEW','STOP_EDIT',
	            'DLVY_VIEW','DLVY_EDIT',
	            'DLVB_VIEW','DLVB_EDIT',
	            'GENR_VIEW','GENR_EDIT'); -- Added AND condition for R12
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Rows Deleted',SQL%ROWCOUNT);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    EXCEPTION
      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_RU_ROLE_PRIVILEGES_PVT.DELETE_ROLR',l_module_name);
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM, WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
  END Delete_Role_Privileges;



END WSH_RU_ROLE_PRIVILEGES_PVT;

/
