--------------------------------------------------------
--  DDL for Package Body WSH_RU_GRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_RU_GRANTS_PVT" AS
/* $Header: WSHGRTHB.pls 115.3 2002/11/12 01:35:27 nparikh ship $ */

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_RU_GRANTS_PVT';
  --
  PROCEDURE Insert_Row(
	p_grant_record	IN  Grant_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_grant_id	OUT NOCOPY  NUMBER,
	x_return_status OUT NOCOPY  VARCHAR2) IS

    WSH_GRANT_OVERLAP EXCEPTION;

    CURSOR c_grant_overlap IS
       SELECT grant_id
       FROM wsh_grants
       WHERE user_id = p_grant_record.user_id
       AND   NVL(organization_id, NVL(p_grant_record.organization_id, -1))
              = NVL(p_grant_record.organization_id, NVL(organization_id, -1))
       AND   (
                 (    p_grant_record.end_date IS NULL
                  AND p_grant_record.start_date < start_date)
              OR (    end_date IS NULL
                  AND p_grant_record.end_date > start_date)
              OR (    p_grant_record.end_date IS NULL
                  AND end_date IS NULL)
              OR (p_grant_record.start_date BETWEEN start_date AND end_date)
              OR (p_grant_record.end_date   BETWEEN start_date AND end_date)
              OR (start_date BETWEEN p_grant_record.start_date AND p_grant_record.end_date)
              OR (end_date BETWEEN p_grant_record.start_date AND p_grant_record.end_date)
             )
       AND rownum = 1;

    CURSOR c_new_grant_id IS
       SELECT wsh_grants_s.nextval FROM DUAL;

    CURSOR c_grant_rowid(x_grant_id IN NUMBER) IS
       SELECT rowid FROM WSH_GRANTS WHERE grant_id = x_grant_id;

    l_grant_id   NUMBER(15)   := NULL;
    l_overlap_id NUMBER(15)   := NULL;
    l_rowid      VARCHAR2(18) := '';

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

-- FGS does not care whether grants overlap. Simply take the
-- union of their organizations
--    OPEN  c_grant_overlap;
--    FETCH c_grant_overlap INTO l_overlap_id;
--    IF c_grant_overlap%NOTFOUND THEN
--      l_overlap_id := NULL;
--    END IF;
--    CLOSE c_grant_overlap;
--
--    IF l_overlap_id IS NOT NULL THEN
--      raise WSH_GRANT_OVERLAP;
--    END IF;

    l_grant_id := p_grant_record.grant_id;

    IF l_grant_id IS NULL THEN
      OPEN  c_new_grant_id;
      FETCH c_new_grant_id INTO l_grant_id;
      CLOSE c_new_grant_id;
    END IF;

    INSERT INTO WSH_GRANTS (
	GRANT_ID,
	USER_ID,
	ROLE_ID,
	ORGANIZATION_ID,
	START_DATE,
	END_DATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	) VALUES (
	l_grant_id,
	p_grant_record.USER_ID,
	p_grant_record.ROLE_ID,
	p_grant_record.ORGANIZATION_ID,
	p_grant_record.START_DATE,
	p_grant_record.END_DATE,
	p_grant_record.CREATED_BY,
	p_grant_record.CREATION_DATE,
	p_grant_record.LAST_UPDATED_BY,
	p_grant_record.LAST_UPDATE_DATE,
	p_grant_record.LAST_UPDATE_LOGIN
	);

    OPEN  c_grant_rowid(l_grant_id);
    FETCH c_grant_rowid INTO l_rowid;
    IF c_grant_rowid%NOTFOUND THEN
      CLOSE c_grant_rowid;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_grant_rowid;

    x_rowid    := l_rowid;
    x_grant_id := l_grant_id;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
    EXCEPTION
      WHEN wsh_grant_overlap THEN
        FND_MESSAGE.Set_Name('WSH', 'WSH_RU_GRANTS_OVERLAP');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_GRANT_OVERLAP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_GRANT_OVERLAP');
END IF;
--
      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_GRANTS_PVT.INSERT_ROW');

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
	p_grant_record	IN Grant_Type) IS

    CURSOR c_lock_grant IS
	SELECT * FROM WSH_GRANTS
	WHERE rowid = p_rowid
	FOR UPDATE OF GRANT_ID NOWAIT;

    l_db_rec c_lock_grant%ROWTYPE;

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
    OPEN  c_lock_grant;
    FETCH c_lock_grant INTO l_db_rec;
    IF c_lock_grant%NOTFOUND THEN
      CLOSE c_lock_grant;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;
    CLOSE c_lock_grant;

    IF     (l_db_rec.USER_ID = p_grant_record.USER_ID)
       AND (l_db_rec.ROLE_ID = p_grant_record.ROLE_ID)
       AND ((l_db_rec.ORGANIZATION_ID = p_grant_record.ORGANIZATION_ID)
            OR (    l_db_rec.ORGANIZATION_ID IS NULL
                AND p_grant_record.ORGANIZATION_ID IS NULL))
       AND (l_db_rec.START_DATE = p_grant_record.START_DATE)
       AND ((l_db_rec.END_DATE = p_grant_record.END_DATE)
            OR (    l_db_rec.END_DATE IS NULL
                AND p_grant_record.END_DATE IS NULL))
       AND (l_db_rec.CREATED_BY = p_grant_record.CREATED_BY)
       AND (l_db_rec.CREATION_DATE = p_grant_record.CREATION_DATE)
       AND (l_db_rec.LAST_UPDATED_BY = p_grant_record.LAST_UPDATED_BY)
       AND (l_db_rec.LAST_UPDATE_DATE = p_grant_record.LAST_UPDATE_DATE)
       AND ((l_db_rec.LAST_UPDATE_LOGIN = p_grant_record.LAST_UPDATE_LOGIN)
            OR (    l_db_rec.LAST_UPDATE_LOGIN IS NULL
                AND p_grant_record.LAST_UPDATE_LOGIN IS NULL))
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

	      if (c_lock_grant%ISOPEN) then
		  close c_lock_grant;
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

	      if (c_lock_grant%ISOPEN) then
		  close c_lock_grant;
	      end if;

	      FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
	      FND_MESSAGE.Set_Token('PACKAGE', 'WSH_RU_GRANTS_PVT.LOCK_ROW');
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
	p_grant_record	IN  Grant_Type,
	x_return_status OUT NOCOPY  VARCHAR2) IS

    WSH_GRANT_OVERLAP EXCEPTION;

    CURSOR c_grant_overlap IS
       SELECT grant_id
       FROM wsh_grants
       WHERE user_id = p_grant_record.user_id
       AND   NVL(organization_id, NVL(p_grant_record.organization_id, -1))
              = NVL(p_grant_record.organization_id, NVL(organization_id, -1))
       AND   (
                 (    p_grant_record.end_date IS NULL
                  AND p_grant_record.start_date < start_date)
              OR (    end_date IS NULL
                  AND p_grant_record.end_date > start_date)
              OR (    p_grant_record.end_date IS NULL
                  AND end_date IS NULL)
              OR (p_grant_record.start_date BETWEEN start_date AND end_date)
              OR (p_grant_record.end_date   BETWEEN start_date AND end_date)
              OR (start_date BETWEEN p_grant_record.start_date AND p_grant_record.end_date)
              OR (end_date BETWEEN p_grant_record.start_date AND p_grant_record.end_date)
             )
       AND grant_id <> p_grant_record.grant_id
       AND rownum = 1;

    l_overlap_id NUMBER(15);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
--
  BEGIN

-- FGS does not care whether grants overlap. Simply take the
-- union of their organizations
--    OPEN  c_grant_overlap;
--    FETCH c_grant_overlap INTO l_overlap_id;
--    IF c_grant_overlap%NOTFOUND THEN
--      l_overlap_id := NULL;
--    END IF;
--    CLOSE c_grant_overlap;
--
--    IF l_overlap_id IS NOT NULL THEN
--      raise WSH_GRANT_OVERLAP;
--    END IF;

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
    UPDATE WSH_GRANTS
    SET
	USER_ID		  =  p_grant_record.USER_ID,
	ROLE_ID		  =  p_grant_record.ROLE_ID,
	ORGANIZATION_ID	  =  p_grant_record.ORGANIZATION_ID,
	START_DATE	  =  p_grant_record.START_DATE,
	END_DATE	  =  p_grant_record.END_DATE,
	CREATED_BY	  =  p_grant_record.CREATED_BY,
	CREATION_DATE	  =  p_grant_record.CREATION_DATE,
	LAST_UPDATED_BY	  =  p_grant_record.LAST_UPDATED_BY,
	LAST_UPDATE_DATE  =  p_grant_record.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN =  p_grant_record.LAST_UPDATE_LOGIN
    WHERE GRANT_ID = p_grant_record.GRANT_ID;

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
      WHEN wsh_grant_overlap THEN
        FND_MESSAGE.Set_Name('WSH', 'WSH_RU_GRANTS_OVERLAP_UPDATE');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_GRANT_OVERLAP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_GRANT_OVERLAP');
END IF;
--
      WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_GRANTS_PVT.UPDATE_ROW');

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
    DELETE FROM WSH_GRANTS
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
	wsh_util_core.default_handler('WSH_RU_GRANTS_PVT.DELETE_ROW');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Delete_Row;


END WSH_RU_GRANTS_PVT;

/
