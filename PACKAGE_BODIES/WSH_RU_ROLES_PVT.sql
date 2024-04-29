--------------------------------------------------------
--  DDL for Package Body WSH_RU_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_RU_ROLES_PVT" AS
/* $Header: WSHROTHB.pls 115.5 2003/11/18 21:03:15 sperera ship $ */

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_RU_ROLES_PVT';
  --
  PROCEDURE Insert_Row(
	p_role_record	IN  Role_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_role_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2) IS

    wsh_duplicate_name		EXCEPTION;

    CURSOR c_dup_role_name IS
        SELECT role_id  FROM WSH_ROLES WHERE name = p_role_record.name;

    CURSOR c_new_role_id IS
       SELECT wsh_roles_s.nextval FROM DUAL;

    CURSOR c_role_rowid(x_role_id IN NUMBER) IS
       SELECT rowid FROM WSH_ROLES WHERE role_id = x_role_id;

    l_role_id NUMBER(15)    := NULL;
    l_dup_id NUMBER(15)     := NULL;
    l_rowid    VARCHAR2(18) := '';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
--
  BEGIN

    --
    -- Debug Statements
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
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    OPEN  c_dup_role_name;
    FETCH c_dup_role_name INTO l_dup_id;
    IF c_dup_role_name%NOTFOUND THEN
      l_dup_id := NULL;
    END IF;
    CLOSE c_dup_role_name;

    IF l_dup_id IS NOT NULL THEN
      raise WSH_DUPLICATE_NAME;
    END IF;

    l_role_id := p_role_record.role_id;

    IF l_role_id IS NULL THEN
      OPEN  c_new_role_id;
      FETCH c_new_role_id INTO l_role_id;
      CLOSE c_new_role_id;
    END IF;

    INSERT INTO WSH_ROLES (
	ROLE_ID,
	NAME,
	DESCRIPTION,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	) VALUES (
	l_role_id,
	p_role_record.NAME,
	p_role_record.DESCRIPTION,
	p_role_record.CREATED_BY,
	p_role_record.CREATION_DATE,
	p_role_record.LAST_UPDATED_BY,
	p_role_record.LAST_UPDATE_DATE,
	p_role_record.LAST_UPDATE_LOGIN
	);

    OPEN  c_role_rowid(l_role_id);
    FETCH c_role_rowid INTO l_rowid;
    IF c_role_rowid%NOTFOUND THEN
      CLOSE c_role_rowid;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_role_rowid;

    x_rowid    := l_rowid;
    x_role_id := l_role_id;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION
      WHEN wsh_duplicate_name THEN
        FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DUPLICATE_NAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DUPLICATE_NAME');
END IF;
--
      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ROLES_PVT.INSERT_ROW');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Insert_Row;


  PROCEDURE Lock_Row(
	p_rowid		IN VARCHAR2,
	p_role_record	IN Role_Type) IS

    CURSOR c_lock_role IS
	SELECT * FROM WSH_ROLES
	WHERE rowid = p_rowid
	FOR UPDATE OF ROLE_ID NOWAIT;

    l_db_rec c_lock_role%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
--
  BEGIN

    --
    -- Debug Statements
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
    OPEN  c_lock_role;
    FETCH c_lock_role INTO l_db_rec;
    IF c_lock_role%NOTFOUND THEN
      CLOSE c_lock_role;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE c_lock_role;

    IF     (l_db_rec.NAME = p_role_record.NAME)
       AND ((l_db_rec.DESCRIPTION = p_role_record.DESCRIPTION)
            OR (    l_db_rec.DESCRIPTION IS NULL
                AND p_role_record.DESCRIPTION IS NULL))
       AND (l_db_rec.CREATED_BY = p_role_record.CREATED_BY)
       AND (l_db_rec.CREATION_DATE = p_role_record.CREATION_DATE)
       AND (l_db_rec.LAST_UPDATED_BY = p_role_record.LAST_UPDATED_BY)
       AND (l_db_rec.LAST_UPDATE_DATE = p_role_record.LAST_UPDATE_DATE)
       AND ((l_db_rec.LAST_UPDATE_LOGIN = p_role_record.LAST_UPDATE_LOGIN)
            OR (    l_db_rec.LAST_UPDATE_LOGIN IS NULL
                AND p_role_record.LAST_UPDATE_LOGIN IS NULL))
    THEN
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION
	WHEN app_exception.application_exception
             or app_exception.record_lock_exception THEN

	      if (c_lock_role%ISOPEN) then
		  close c_lock_role;
	      end if;

	      --
	      -- Debug Statements
	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
	      END IF;
	      --
	      RAISE;

	WHEN others THEN

	      if (c_lock_role%ISOPEN) then
		  close c_lock_role;
	      end if;

	      FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('PACKAGE', 'WSH_RU_ROLES_PVT.LOCK_ROW');
	      FND_MESSAGE.Set_Token('ORA_ERROR',sqlcode);
	      FND_MESSAGE.Set_Token('ORA_TEXT',sqlerrm);

	      --
	      -- Debug Statements
	      --
	      IF l_debug_on THEN
	          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	      END IF;
	      --
	      RAISE;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Lock_Row;


  PROCEDURE Update_Row(
	p_rowid		IN  VARCHAR2,
	p_role_record	IN  Role_Type,
	x_return_status OUT NOCOPY  VARCHAR2) IS
	--

        CURSOR c_dup_role_name IS
        SELECT role_id  FROM WSH_ROLES
        WHERE name = p_role_record.name
        AND ROLE_ID <> p_role_record.ROLE_ID;

        l_dup_id NUMBER;

        wsh_duplicate_name          EXCEPTION;

        l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
	--
  BEGIN

    --
    -- Debug Statements
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
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_ID',p_role_record.ROLE_ID);
    END IF;
    --
    OPEN  c_dup_role_name;
    FETCH c_dup_role_name INTO l_dup_id;
    IF c_dup_role_name%FOUND THEN
       CLOSE c_dup_role_name;
       raise WSH_DUPLICATE_NAME;
    ELSE
       CLOSE c_dup_role_name;
    END IF;

    UPDATE WSH_ROLES
    SET
	ROLE_ID		  =  p_role_record.ROLE_ID,
	NAME		  =  p_role_record.NAME,
	DESCRIPTION	  =  p_role_record.DESCRIPTION,
	CREATED_BY	  =  p_role_record.CREATED_BY,
	CREATION_DATE	  =  p_role_record.CREATION_DATE,
	LAST_UPDATED_BY	  =  p_role_record.LAST_UPDATED_BY,
	LAST_UPDATE_DATE  =  p_role_record.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN =  p_role_record.LAST_UPDATE_LOGIN
    WHERE ROLE_ID = p_role_record.ROLE_ID;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION
      WHEN wsh_duplicate_name THEN
        FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DUPLICATE_NAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DUPLICATE_NAME');
      END IF;
      --
      WHEN others THEN
        IF c_dup_role_name%isopen THEN
           CLOSE c_dup_role_name;
        END IF;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ROLES_PVT.UPDATE_ROW');

      --
      -- Debug Statements
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
    -- Debug Statements
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
    DELETE FROM WSH_ROLES
    WHERE rowid = p_rowid;
    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION
      WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ROLES_PVT.DELETE_ROW');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Delete_Row;


END WSH_RU_ROLES_PVT;

/
