--------------------------------------------------------
--  DDL for Package Body WSH_RU_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_RU_ACTIONS" AS
/* $Header: WSHRUACB.pls 120.1 2005/06/09 17:04:43 appldev  $ */


  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_RU_ACTIONS';
  g_custom_message_tbl custom_message_cache_tbl;
  --
  PROCEDURE Create_Role_Definition(
	p_role_def_record	IN  Role_Definition_Type,
	x_rowid			OUT NOCOPY  VARCHAR2,
	x_role_id		OUT NOCOPY  NUMBER,
	x_return_status 	OUT NOCOPY  VARCHAR2) IS
    l_rs        	VARCHAR2(1);
    l_role      	WSH_RU_ROLES_PVT.Role_Type;
    l_privilege 	WSH_RU_ROLE_PRIVILEGES_PVT.Role_Privilege_Type;
    l_role_id		NUMBER(15);
    i           	NUMBER;
    l_dummy_rowid	VARCHAR2(18);
    l_dummy_id  	NUMBER(15);
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_ROLE_DEFINITION';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.ROLE_ID',p_role_def_record.ROLE_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.NAME',p_role_def_record.NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.DESCRIPTION',p_role_def_record.DESCRIPTION);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.CREATED_BY',p_role_def_record.CREATED_BY);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.CREATION_DATE',p_role_def_record.CREATION_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.LAST_UPDATED_BY',p_role_def_record.LAST_UPDATED_BY);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.LAST_UPDATE_DATE',p_role_def_record.LAST_UPDATE_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.LAST_UPDATE_LOGIN',p_role_def_record.LAST_UPDATE_LOGIN);
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.PRIVILEGES_COUNT',p_role_def_record.PRIVILEGES.COUNT);
    END IF;
    --
    savepoint before_role_definition;

    l_role.ROLE_ID 		:= NULL;
    l_role.NAME    		:= p_role_def_record.NAME;
    l_role.DESCRIPTION		:= p_role_def_record.DESCRIPTION;
    l_role.CREATED_BY		:= p_role_def_record.CREATED_BY;
    l_role.CREATION_DATE	:= p_role_def_record.CREATION_DATE;
    l_role.LAST_UPDATED_BY	:= p_role_def_record.LAST_UPDATED_BY;
    l_role.LAST_UPDATE_DATE	:= p_role_def_record.LAST_UPDATE_DATE;
    l_role.LAST_UPDATE_LOGIN	:= p_role_def_record.LAST_UPDATE_LOGIN;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RU_ROLES_PVT.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_RU_ROLES_PVT.Insert_Row(
	p_role_record	=> l_role,
	x_rowid		=> x_rowid,
	x_role_id	=> l_role_id,
	x_return_status => l_rs);

    IF l_rs <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_rs;
      rollback to before_role_definition;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;

    x_role_id := l_role_id;
    -- Debug Statements
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_ROLE_ID',x_role_id);
    END IF;
    --

    l_privilege.ROLE_PRIVILEGE_ID 	:= NULL;
    l_privilege.ROLE_ID 		:= l_role_id;
    l_privilege.PRIVILEGE_CODE 		:= NULL; -- this will be updated
    l_privilege.CREATED_BY		:= p_role_def_record.CREATED_BY;
    l_privilege.CREATION_DATE		:= p_role_def_record.CREATION_DATE;
    l_privilege.LAST_UPDATED_BY		:= p_role_def_record.LAST_UPDATED_BY;
    l_privilege.LAST_UPDATE_DATE	:= p_role_def_record.LAST_UPDATE_DATE;
    l_privilege.LAST_UPDATE_LOGIN	:= p_role_def_record.LAST_UPDATE_LOGIN;

    FOR i IN 1..p_role_def_record.privileges.count LOOP

      l_privilege.PRIVILEGE_CODE := p_role_def_record.privileges(i);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'PRIVILEGE_CODE',l_privilege.PRIVILEGE_CODE);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RU_ROLE_PRIVILEGES_PVT.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_RU_ROLE_PRIVILEGES_PVT.Insert_Row(
	p_role_privilege_record => l_privilege,
	x_rowid			=> l_dummy_rowid,
	x_role_privilege_id	=> l_dummy_id,
	x_return_status		=> l_rs);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        x_return_status := l_rs;
        rollback to before_role_definition;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
      END IF;

    END LOOP;

    x_return_status := l_rs;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Create_Role_Definition;


  PROCEDURE Lock_Role_Definition(
	p_role_def_record	IN  Role_Definition_Type,
        p_row_id                IN  VARCHAR2) IS
	--
        l_role              WSH_RU_ROLES_PVT.Role_Type;
        l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROLE_DEFINITION';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.ROLE_ID',p_role_def_record.ROLE_ID);
    END IF;

    l_role.ROLE_ID              := p_role_def_record.ROLE_ID;
    l_role.NAME                 := p_role_def_record.NAME;
    l_role.DESCRIPTION          := p_role_def_record.DESCRIPTION;
    l_role.CREATED_BY           := p_role_def_record.CREATED_BY;
    l_role.CREATION_DATE        := p_role_def_record.CREATION_DATE;
    l_role.LAST_UPDATED_BY      := p_role_def_record.LAST_UPDATED_BY;
    l_role.LAST_UPDATE_DATE     := p_role_def_record.LAST_UPDATE_DATE;
    l_role.LAST_UPDATE_LOGIN    := p_role_def_record.LAST_UPDATE_LOGIN;

    --
    wsh_ru_roles_pvt.lock_row(
       p_rowid       => p_row_id,
       p_role_record => l_role
       );

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  END Lock_Role_Definition;


  PROCEDURE Update_Role_Definition(
	p_role_def_record	IN  OUT NOCOPY Role_Definition_Type,
	x_return_status 	OUT NOCOPY  VARCHAR2) IS
  --
  l_rs        	VARCHAR2(1);
  l_role      	WSH_RU_ROLES_PVT.Role_Type;
  l_privilege 	WSH_RU_ROLE_PRIVILEGES_PVT.Role_Privilege_Type;
  l_role_id		NUMBER(15);
  i           	NUMBER;
  l_dummy_rowid	VARCHAR2(18);
  l_dummy_id  	NUMBER(15);
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROLE_DEFINITION';
  --
  BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
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
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.ROLE_ID',p_role_def_record.ROLE_ID);
    END IF;

    savepoint before_role_definition;

    l_role.ROLE_ID 		:= p_role_def_record.ROLE_ID;
    l_role.NAME    		:= p_role_def_record.NAME;
    l_role.DESCRIPTION		:= p_role_def_record.DESCRIPTION;
    l_role.CREATED_BY		:= p_role_def_record.CREATED_BY;
    l_role.CREATION_DATE	:= p_role_def_record.CREATION_DATE;
    l_role.LAST_UPDATED_BY	:= p_role_def_record.LAST_UPDATED_BY;
    l_role.LAST_UPDATE_DATE	:= SYSDATE;
    l_role.LAST_UPDATE_LOGIN	:= p_role_def_record.LAST_UPDATE_LOGIN;

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RU_ROLES_PVT.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    --
    WSH_RU_ROLES_PVT.Update_Row(
	p_role_record	=> l_role,
        p_rowid         => NULL,
	x_return_status => l_rs);

    IF l_rs <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_rs;
      rollback to before_role_definition;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;

    WSH_RU_ROLE_PRIVILEGES_PVT.Delete_Role_Privileges(
              p_role_id       => p_role_def_record.ROLE_ID,
              x_return_status => l_rs);

    IF l_rs <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      x_return_status := l_rs;
      rollback to before_role_definition;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;

    l_privilege.ROLE_PRIVILEGE_ID 	:= NULL;
    l_privilege.ROLE_ID 		:= p_role_def_record.ROLE_ID;
    l_privilege.PRIVILEGE_CODE 		:= NULL; -- this will be updated
    l_privilege.CREATED_BY		:= p_role_def_record.CREATED_BY;
    l_privilege.CREATION_DATE		:= p_role_def_record.CREATION_DATE;
    l_privilege.LAST_UPDATED_BY		:= p_role_def_record.LAST_UPDATED_BY;
    l_privilege.LAST_UPDATE_DATE	:= p_role_def_record.LAST_UPDATE_DATE;
    l_privilege.LAST_UPDATE_LOGIN	:= p_role_def_record.LAST_UPDATE_LOGIN;

    FOR i IN 1..p_role_def_record.privileges.count LOOP

      l_privilege.PRIVILEGE_CODE := p_role_def_record.privileges(i);

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'PRIVILEGE_CODE',l_privilege.PRIVILEGE_CODE);
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_RU_ROLE_PRIVILEGES_PVT.INSERT_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      WSH_RU_ROLE_PRIVILEGES_PVT.Insert_Row(
	p_role_privilege_record => l_privilege,
	x_rowid			=> l_dummy_rowid,
	x_role_privilege_id	=> l_dummy_id,
	x_return_status		=> l_rs);

      IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        x_return_status := l_rs;
        rollback to before_role_definition;
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
        return;
      END IF;

    END LOOP;
    --
    -- Debug Statements
    --
    p_role_def_record.LAST_UPDATE_DATE := l_role.LAST_UPDATE_DATE;

    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  END Update_Role_Definition;


  PROCEDURE Delete_Role_Definition(
	p_role_def_record	IN  Role_Definition_Type,
	x_return_status 	OUT NOCOPY  VARCHAR2) IS
	--
        l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROLE_DEFINITION';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ROLE_DEF_RECORD.ROLE_ID',p_role_def_record.ROLE_ID);
    END IF;
    --
    FND_MESSAGE.SET_NAME('WSH', 'NOT_IMPLEMENTED');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  END Delete_Role_Definition;


  PROCEDURE Get_Organization_Privileges(
        p_organization_id       IN  NUMBER,
        x_privileges            OUT NOCOPY  Privileges_Type,
        x_return_status         OUT NOCOPY  VARCHAR2) IS

    CURSOR c_privileges(x_org_id IN NUMBER, x_user_id IN NUMBER) IS
    SELECT DISTINCT rp.privilege_code
    FROM  wsh_grants          g,
          wsh_role_privileges rp
    WHERE g.user_id = x_user_id
    AND   sysdate BETWEEN g.start_date AND NVL(g.end_date, sysdate)
    AND   NVL(g.organization_id, NVL(x_org_id, -1))
           = NVL(x_org_id, NVL(g.organization_id, -1))
    AND   rp.role_id = g.role_id
    ORDER BY privilege_code;

    i NUMBER := 0;
    --
l_debug_on BOOLEAN;
    --
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_ORGANIZATION_PRIVILEGES';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    END IF;
    --
    FOR p IN c_privileges(p_organization_id, fnd_profile.value('USER_ID')) LOOP
      i:=i+1;  x_privileges(i) := p.privilege_code;
    END LOOP;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_PRIVILEGES.COUNT',X_PRIVILEGES.COUNT);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
    EXCEPTION
      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ACTIONS.GET_ORGANIZATION_PRIVILEGES');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Get_Organization_Privileges;


  PROCEDURE Entity_Access_In_Organization(
        p_entity_type           IN  VARCHAR2,
        p_organization_id       IN  NUMBER,
        x_access_type           OUT NOCOPY  VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2) IS

    CURSOR c_access(x_org_id IN NUMBER, x_priv IN VARCHAR2,
                    x_user_id IN NUMBER) IS
    SELECT 'Y'
    FROM  wsh_grants          g,
          wsh_role_privileges rp
    WHERE g.user_id = x_user_id
    AND   sysdate BETWEEN g.start_date AND NVL(g.end_date, sysdate)
    AND   rp.role_id = g.role_id
    AND   NVL(g.organization_id, NVL(x_org_id, -1))
           = NVL(x_org_id, NVL(g.organization_id, -1))
    AND   rp.privilege_code = x_priv
    ORDER BY privilege_code;

    user_id NUMBER := fnd_profile.value('USER_ID');
    edit_privilege VARCHAR2(30);
    view_privilege VARCHAR2(30);
    flag VARCHAR2(1) := 'N';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ENTITY_ACCESS_IN_ORGANIZATION';
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
        WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',P_ENTITY_TYPE);
        WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF    (p_entity_type = 'TRIP') THEN
      edit_privilege := 'TRIP_EDIT';
      view_privilege := 'TRIP_VIEW';

    ELSIF (p_entity_type IN ('STOP', 'TRIP STOP')) THEN
      edit_privilege := 'STOP_EDIT';
      view_privilege := 'STOP_VIEW';

    ELSIF (p_entity_type IN ('DLVY',
                             'DELIVERY',
                             'BILL OF LADING',
                             'DELIVERY LEG',
                             'PACK SLIP')) THEN
      edit_privilege := 'DLVY_EDIT';
      view_privilege := 'DLVY_VIEW';

    ELSIF (p_entity_type IN ('DLVB', 'DELIVERY DETAIL')) THEN
      edit_privilege := 'DLVB_EDIT';
      view_privilege := 'DLVB_VIEW';

    END IF;

    OPEN  c_access(p_organization_id, edit_privilege, user_id);
    FETCH c_access INTO flag;
    IF c_access%NOTFOUND THEN
      flag := 'N';
    END IF;
    CLOSE c_access;

    IF flag = 'Y' THEN
      x_access_type := 'EDIT';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_ACCESS_TYPE',X_ACCESS_TYPE);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;

    OPEN  c_access(p_organization_id, view_privilege, user_id);
    FETCH c_access INTO flag;
    IF c_access%NOTFOUND THEN
      flag := 'N';
    END IF;
    CLOSE c_access;

    IF flag = 'Y' THEN
      x_access_type := 'VIEW';
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'X_ACCESS_TYPE',X_ACCESS_TYPE);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
      return;
    END IF;

    x_access_type := 'NONE';

--
-- Debug Statements
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'X_ACCESS_TYPE',X_ACCESS_TYPE);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
    EXCEPTION
      WHEN others THEN
        x_access_type := 'NONE';
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_RU_ACTIONS.ENTITY_ACCESS_IN_ORGANIZATION');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Entity_Access_In_Organization;





 /**************************************************************************************
 *   Table Handler to insert records into wsh_customized_activity_msgs table
 *   This API is designed to be called from ROLE_DEFINITIONS form only.
 ****************************************************************************************/
 Procedure insert_customized_msgs (
            p_custom_message_rec IN OUT NOCOPY custom_message_rec
           ,x_error_message      OUT NOCOPY VARCHAR2
           ,x_return_status      OUT NOCOPY VARCHAR2 ) is

  l_user_id     number := fnd_global.user_id;
  l_login_id    number := fnd_global.login_id;
  l_sysdate     date   := sysdate;
  l_id          number;
  l_debug_on    boolean;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_CUSTOMIZED_MSGS';

 Begin

  l_debug_on := wsh_debug_interface.g_debug;
  IF l_debug_on IS NULL THEN
     l_debug_on := wsh_debug_sv.is_debug_enabled;
  END IF;


  IF l_debug_on THEN
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.customized_activity_mesg_id',p_custom_message_rec.customized_activity_mesg_id);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.role_id',p_custom_message_rec.role_id);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.activity_code',p_custom_message_rec.activity_code);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.validation_code',p_custom_message_rec.validation_code);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.return_status',p_custom_message_rec.return_status);
     wsh_debug_sv.log(l_module_name,'l_id',l_id);
     wsh_debug_sv.log(l_module_name,'l_user_id',l_user_id);
     wsh_debug_sv.log(l_module_name,'l_login_id',l_login_id);
     wsh_debug_sv.log(l_module_name,'l_sysdate',l_sysdate);
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;

  insert into wsh_customized_activity_msgs
      (customized_activity_mesg_id
      ,role_id
      ,activity_code
      ,validation_code
      ,return_status
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login)
   values
     (wsh_customized_activity_msgs_s.nextval
     ,p_custom_message_rec.role_id
     ,p_custom_message_rec.activity_code
     ,p_custom_message_rec.validation_code
     ,p_custom_message_rec.return_status
     ,l_sysdate
     ,l_user_id
     ,l_sysdate
     ,l_user_id
     ,l_login_id)
   returning customized_activity_mesg_id into l_id;

  p_custom_message_rec.customized_activity_mesg_id := l_id;
  --p_custom_message_rec.last_update_date := l_sysdate;

  IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name,'x_return_status',x_return_status);
     wsh_debug_sv.pop(l_module_name);
  END IF;

 Exception
   When others then
     x_error_message := SQLERRM;
     x_return_status := wsh_util_core.g_ret_sts_error;
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'x_return_status',x_return_status);
        wsh_debug_sv.pop(l_module_name);
     END IF;

 End insert_customized_msgs ;


 /**************************************************************************************
 *   Table Handler to update records into wsh_customized_activity_msgs table
 *   This API is designed to be called from ROLE_DEFINITIONS form only.
 * ***************************************************************************************/
 Procedure update_customized_msgs (
           p_custom_message_rec IN OUT NOCOPY custom_message_rec
          ,x_error_message      OUT NOCOPY VARCHAR2
          ,x_return_status      OUT NOCOPY VARCHAR2 ) is

  l_user_id     number := fnd_global.user_id;
  l_login_id    number := fnd_global.login_id;
  l_sysdate     date   := sysdate;
  l_debug_on    boolean ;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_CUSTOMIZED_MSGS';

 Begin

  l_debug_on := wsh_debug_interface.g_debug;
  IF l_debug_on IS NULL THEN
     l_debug_on := wsh_debug_sv.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.customized_activity_mesg_id',p_custom_message_rec.customized_activity_mesg_id);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.role_id',p_custom_message_rec.role_id);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.activity_code',p_custom_message_rec.activity_code);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.validation_code',p_custom_message_rec.validation_code);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.return_status',p_custom_message_rec.return_status);
     wsh_debug_sv.log(l_module_name,'l_user_id',l_user_id);
     wsh_debug_sv.log(l_module_name,'l_login_id',l_login_id);
     wsh_debug_sv.log(l_module_name,'l_sysdate',l_sysdate);
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;

  update wsh_customized_activity_msgs msg
     set return_status     = nvl(p_custom_message_rec.return_status,'W')
        ,creation_date     = l_sysdate
        ,created_by        = l_user_id
        ,last_update_date  = l_sysdate
        ,last_updated_by   = l_user_id
        ,last_update_login = l_login_id
   where msg.customized_activity_mesg_id = p_custom_message_rec.customized_activity_mesg_id
     and msg.role_id         = p_custom_message_rec.role_id
     and msg.activity_code   = p_custom_message_rec.activity_code
     and msg.validation_code = p_custom_message_rec.validation_code;

   --p_custom_message_rec.last_update_date := l_sysdate;

   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'x_return_status',x_return_status);
      wsh_debug_sv.pop(l_module_name);
   END IF;

 Exception
   When others then
     x_error_message := SQLERRM;
     x_return_status := wsh_util_core.g_ret_sts_error;
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'x_return_status',x_return_status);
        wsh_debug_sv.pop(l_module_name);
     END IF;

 End update_customized_msgs ;


 /**************************************************************************************
 *   Table Handler to delete records into wsh_customized_activity_msgs table
 *   This API is designed to be called from ROLE_DEFINITIONS form only.
 ****************************************************************************************/
 Procedure delete_customized_msgs (
           p_custom_message_rec IN OUT NOCOPY custom_message_rec
          ,x_error_message      OUT NOCOPY VARCHAR2
          ,x_return_status      OUT NOCOPY VARCHAR2 ) is

  l_debug_on    boolean ;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_CUSTOMIZED_MSGS';

 Begin

  l_debug_on := wsh_debug_interface.g_debug;
  IF l_debug_on IS NULL THEN
     l_debug_on := wsh_debug_sv.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     wsh_debug_sv.push(l_module_name);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.customized_activity_mesg_id',p_custom_message_rec.customized_activity_mesg_id);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.role_id',p_custom_message_rec.role_id);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.activity_code',p_custom_message_rec.activity_code);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.validation_code',p_custom_message_rec.validation_code);
     wsh_debug_sv.log(l_module_name,'p_custom_message_rec.return_status',p_custom_message_rec.return_status);
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;

  delete from wsh_customized_activity_msgs
   where customized_activity_mesg_id = p_custom_message_rec.customized_activity_mesg_id;

  IF l_debug_on THEN
     wsh_debug_sv.log(l_module_name,'l_return_status',x_return_status);
     wsh_debug_sv.pop(l_module_name);
  END IF;


 Exception
   When others then
     x_error_message := SQLERRM;
     x_return_status := wsh_util_core.g_ret_sts_error;
     IF l_debug_on THEN
        wsh_debug_sv.log(l_module_name,'l_return_status',x_return_status);
        wsh_debug_sv.pop(l_module_name);
     END IF;
 End delete_customized_msgs ;

 Function get_message_severity (
          p_activity_code   in varchar2
         ,p_validation_code in varchar2 ) return varchar2 is

   Cursor l_get_message_severity_csr( p_user_id       in number
                                     ,p_activity_code in VARCHAR2
                                     ,p_validation_code in VARCHAR2
                                     ,p_lookup_type     in VARCHAR2) is
   select msgs.activity_code , msgs.validation_code , msgs.return_status
     from wsh_customized_activity_msgs msgs
         ,wsh_grants   grants
         ,wsh_lookups  activity
         ,wsh_lookups  message
    where grants.user_id       = p_user_id
      and sysdate between nvl(grants.start_date,sysdate) and nvl(grants.end_date,sysdate )
      and msgs.activity_code   = p_activity_code
      and msgs.validation_code = p_validation_code
      and grants.role_id       = msgs.role_id
      and msgs.activity_code   = activity.lookup_code
      and sysdate between nvl(activity.start_date_active,sysdate) and nvl(activity.end_date_active,sysdate)
      and activity.lookup_type = p_lookup_type
      and msgs.validation_code = message.lookup_code
      and sysdate between nvl(message.start_date_active,sysdate) and nvl(message.end_date_active,sysdate)
      and message.lookup_type  = activity.lookup_code
      and msgs.return_status   = 'E';

   l_get_message_severity_rec l_get_message_severity_csr%ROWTYPE;

   l_lookup_type CONSTANT varchar2(200) := 'WSH_CUSTOMIZED_ACTIVITY';
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MESSAGE_SEVERITY';
   l_user_id     number := fnd_global.user_id;
   l_index       number ;
   l_debug_on    boolean;


 Begin

   l_debug_on := wsh_debug_interface.g_debug;
   IF l_debug_on IS NULL THEN
      l_debug_on := wsh_debug_sv.is_debug_enabled;
   END IF;

   IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
      wsh_debug_sv.log(l_module_name,'l_user_id',l_user_id);
      wsh_debug_sv.log(l_module_name,'p_activity_code',p_activity_code);
      wsh_debug_sv.log(l_module_name,'p_validation_code',p_validation_code);
      wsh_debug_sv.log(l_module_name,'g_custom_message_tbl.count',g_custom_message_tbl.count);
   End If;

   If g_custom_message_tbl.count > 0 then
      For i in g_custom_message_tbl.first..g_custom_message_tbl.last
      Loop
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'g_custom_message_tbl('||i||').user_id',g_custom_message_tbl(i).user_id);
           wsh_debug_sv.log(l_module_name,'g_custom_message_tbl('||i||').activity_code',g_custom_message_tbl(i).activity_code);
           wsh_debug_sv.log(l_module_name,'g_custom_message_tbl('||i||').validation_code',g_custom_message_tbl(i).validation_code);
        End If;
        If g_custom_message_tbl(i).user_id         = l_user_id And
           g_custom_message_tbl(i).activity_code   = p_activity_code And
           g_custom_message_tbl(i).validation_code = p_validation_code Then
           IF l_debug_on THEN
              wsh_debug_sv.log(l_module_name,'Message Severity from cache ', g_custom_message_tbl(i).return_status);
              wsh_debug_sv.pop(l_module_name);
           End If;
           return(g_custom_message_tbl(i).return_status);
        End If;
      End Loop;
   End If;

   Open l_get_message_severity_csr ( l_user_id
                                   , p_activity_code
                                   , p_validation_code
                                   , l_lookup_type );
   Fetch l_get_message_severity_csr into l_get_message_severity_rec;
   IF l_debug_on THEN
         wsh_debug_sv.log(l_module_name,'l_get_message_severity_rec.return_status:',l_get_message_severity_rec.return_status);
   End If;
   Close l_get_message_severity_csr;

   l_index := g_custom_message_tbl.count + 1 ;
   g_custom_message_tbl(l_index).user_id         := l_user_id;
   g_custom_message_tbl(l_index).activity_code   := p_activity_code;
   g_custom_message_tbl(l_index).validation_code := p_validation_code;
   g_custom_message_tbl(l_index).return_status   := nvl(l_get_message_severity_rec.return_status,'W');

   IF l_debug_on THEN
      wsh_debug_sv.log(l_module_name,'Message Severity ',nvl(l_get_message_severity_rec.return_status, 'W'));
      wsh_debug_sv.pop(l_module_name);
   End If;
   Return(nvl(l_get_message_severity_rec.return_status,'W'));
 Exception
   When others then
        IF l_debug_on THEN
           wsh_debug_sv.log(l_module_name,'IN EXCEPTION ',SQLERRM);
           wsh_debug_sv.pop(l_module_name);
        End If;
        Raise;

 End get_message_severity;



END WSH_RU_ACTIONS;

/
