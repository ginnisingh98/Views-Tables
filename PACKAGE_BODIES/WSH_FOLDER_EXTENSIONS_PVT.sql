--------------------------------------------------------
--  DDL for Package Body WSH_FOLDER_EXTENSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FOLDER_EXTENSIONS_PVT" as
/* $Header: WSHFDEXB.pls 115.7 2004/02/17 01:11:53 ttrichy noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_FOLDER_EXTENSIONS_PVT';

Procedure Insert_Update_Folder_Ext(
          p_folder_ext_rec IN folder_ext_rec_type,
          x_return_status  OUT NOCOPY VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;

 CURSOR c_ext_rec_cur(p_folder_id NUMBER) IS
 SELECT folder_extension_id
 FROM wsh_folder_extensions
 WHERE folder_id = p_folder_id
 FOR UPDATE NOWAIT;

  l_folder_extension_id NUMBER;
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_UPDATE_FOLDER_EXT';
--
  BEGIN

    -- initialize parameters
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
        WSH_DEBUG_SV.log(l_module_name, 'folder id', p_folder_ext_rec.folder_id);
        WSH_DEBUG_SV.log(l_module_name, 'folder extension id', p_folder_ext_rec.folder_extension_id);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_DLVY_OTHERS', p_folder_ext_rec.DISPLAY_DLVY_OTHERS);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_LINE_OTHERS',p_folder_ext_rec.display_line_others);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_TRIP_OTHERS',p_folder_ext_rec.display_trip_others);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_STOP_OTHERS',p_folder_ext_rec.display_stop_others);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_QM_LINE_OTHERS',p_folder_ext_rec.display_qm_line_others);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_SHIP_CONF_DIALOGUE',p_folder_ext_rec.display_ship_conf_dialogue);
        WSH_DEBUG_SV.log(l_module_name, 'DISPLAY_TRIP_INFO',p_folder_ext_rec.display_trip_info);
        WSH_DEBUG_SV.log(l_module_name, 'Userid', p_folder_ext_rec.user_id);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN c_ext_rec_cur(p_folder_ext_rec.folder_id);
   FETCH c_ext_rec_cur INTO l_folder_extension_id;

   IF c_ext_rec_cur%FOUND THEN

    UPDATE WSH_FOLDER_EXTENSIONS
    SET
        user_id = nvl(p_folder_ext_rec.user_id, FND_GLOBAL.USER_ID),
        application_id = nvl(p_folder_ext_rec.application_id, 665),
        display_dlvy_main = nvl(p_folder_ext_rec.display_dlvy_main,'Y'), -- always display
        display_dlvy_others = nvl(p_folder_ext_rec.display_dlvy_others,'N'),
        display_line_main = nvl(p_folder_ext_rec.display_line_main,'Y'), -- always display
        display_line_others = nvl(p_folder_ext_rec.display_line_others,'N'), -- By default is not visible
        display_trip_main = nvl(p_folder_ext_rec.display_trip_main,'Y'), -- always display
        display_trip_others = nvl(p_folder_ext_rec.display_trip_others,'N'),
        display_stop_main = nvl(p_folder_ext_rec.display_stop_main,'Y'), -- always display
        display_stop_others = nvl(p_folder_ext_rec.display_stop_others,'N'),
        display_qm_line_main = nvl(p_folder_ext_rec.display_qm_line_main,'Y'), -- always display
        display_qm_line_others = nvl(p_folder_ext_rec.display_qm_line_others,'N'), -- By default is not visible
        display_ship_conf_dialogue = nvl(p_folder_ext_rec.display_ship_conf_dialogue,'Y'), -- By default is visible
        display_trip_conf_dialogue = nvl(p_folder_ext_rec.display_trip_conf_dialogue,'Y'), -- By default is visible
        display_trip_info = nvl(p_folder_ext_rec.display_trip_info,'Y'), -- By default is visible
        last_update_date = nvl(p_folder_ext_rec.last_update_date, SYSDATE),
        last_updated_by = nvl(p_folder_ext_rec.last_updated_by, FND_GLOBAL.USER_ID),
        last_update_login = nvl(p_folder_ext_rec.last_update_login, FND_GLOBAL.LOGIN_ID)
   WHERE
          folder_id = p_folder_ext_rec.folder_id;
  ELSE

     INSERT INTO WSH_FOLDER_EXTENSIONS
           (FOLDER_EXTENSION_ID,
        OBJECT,
        USER_ID,
        FOLDER_ID,
        APPLICATION_ID,
        DISPLAY_DLVY_MAIN,
        DISPLAY_DLVY_OTHERS,
        DISPLAY_LINE_MAIN,
        DISPLAY_LINE_OTHERS,
        DISPLAY_TRIP_MAIN,
        DISPLAY_TRIP_OTHERS,
        DISPLAY_STOP_MAIN,
        DISPLAY_STOP_OTHERS,
        DISPLAY_QM_LINE_MAIN,
        DISPLAY_QM_LINE_OTHERS,
        DISPLAY_SHIP_CONF_DIALOGUE,
        DISPLAY_TRIP_CONF_DIALOGUE,
        DISPLAY_TRIP_INFO,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
        )
    VALUES
       (
        wsh_folder_extension_s.nextval,
        p_folder_ext_rec.object,
        nvl(p_folder_ext_rec.user_id,FND_GLOBAL.USER_ID),
        p_folder_ext_rec.folder_id,
        nvl(p_folder_ext_rec.application_id,665),
        nvl(p_folder_ext_rec.display_dlvy_main,'Y'), -- always display
        nvl(p_folder_ext_rec.display_dlvy_others,'N'),
        nvl(p_folder_ext_rec.display_line_main,'Y'), -- always display
        nvl(p_folder_ext_rec.display_line_others,'N'), -- By default is not visible
        nvl(p_folder_ext_rec.display_trip_main,'Y'), -- always display
        nvl(p_folder_ext_rec.display_trip_others,'N'),
        nvl(p_folder_ext_rec.display_stop_main,'Y'), -- always display
        nvl(p_folder_ext_rec.display_stop_others,'N'),
        nvl(p_folder_ext_rec.display_qm_line_main,'Y'), -- always display
        nvl(p_folder_ext_rec.display_qm_line_others,'N'), -- By default is not visible
        nvl(p_folder_ext_rec.display_ship_conf_dialogue,'Y'), -- By default is visible
        nvl(p_folder_ext_rec.display_trip_conf_dialogue,'Y'), -- By default is visible
        nvl(p_folder_ext_rec.display_trip_info,'Y'), -- By default is visible
        nvl(p_folder_ext_rec.creation_date,SYSDATE),
        nvl(p_folder_ext_rec.created_by, FND_GLOBAL.USER_ID),
        nvl(p_folder_ext_rec.last_update_date, SYSDATE),
        nvl(p_folder_ext_rec.last_updated_by, FND_GLOBAL.USER_ID),
        nvl(p_folder_ext_rec.last_update_login, FND_GLOBAL.LOGIN_ID)
        );
  END IF;

   COMMIT;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

     WHEN others THEN
	   wsh_util_core.default_handler('WSH_FOLDER_EXTENSIONS_PVT.INSERT_UPDATE_FOLDER_EXT',l_module_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
           --

END Insert_Update_Folder_Ext;


Procedure Delete_Folder_Ext(
          p_folder_id           IN NUMBER,
          x_return_status       OUT NOCOPY VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;
  --
  l_flag VARCHAR2(1) := 'N';
  l_debug_on BOOLEAN;
  l_count NUMBER := 0;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FOLDER_EXT';
--
  BEGIN

     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         WSH_DEBUG_SV.log(l_module_name,'p_folder_id',p_folder_id);
         --
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

-- Only if record has been deleted from fnd_folders, delete it
-- from WSH custom table

     SELECT count(*)
       INTO l_count
       FROM fnd_folders
      WHERE folder_id = p_folder_id;

     IF l_count = 0 THEN
       l_flag := 'N';
     ELSE
       l_flag := 'Y';
     END IF;
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Flag',l_flag);
     END IF;

     IF l_flag = 'N' THEN

       DELETE FROM wsh_folder_extensions
        WHERE folder_id = p_folder_id;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Folders Deleted-',sql%rowcount);
       END IF;

       COMMIT;
     ELSE
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'No Folders Deleted');
       END IF;

     END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION

     WHEN others THEN
	   wsh_util_core.default_handler('WSH_FOLDER_EXTENSIONS_PVT.DELETE_FOLDER_EXT',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

END Delete_Folder_Ext;

/*-------------------------------------------
-- Folder Custom Actions Table Handler
--========= INSERT/UPDATE FOLDER CUSTOM ACTIONS==
-- There can be multiple records for a folder_id in table
-- wsh_folder_custom_actions, so Input needs to be table of records
-------------------------------------------*/

Procedure Insert_Update_Folder_Custom(
          p_folder_cust_tab IN folder_cust_tab_type,
          x_return_status  OUT NOCOPY VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;

 CURSOR c_cust_rec_cur(v_folder_id IN NUMBER) IS
 SELECT folder_id
 FROM wsh_folder_custom_actions
 WHERE folder_id = v_folder_id
   AND rownum = 1;
-- FOR UPDATE NOWAIT;

  l_folder_id NUMBER;
  l_flag VARCHAR2(1);
  --
  l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_UPDATE_FOLDER_CUSTOM';
--
  l_return_status VARCHAR2(30);
  BEGIN

    -- initialize parameters
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
      WSH_DEBUG_SV.log(l_module_name,'COUNT of records', p_folder_cust_tab.count);
    END IF;
    --
-- Initialize the Local variables for return status
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    OPEN c_cust_rec_cur(p_folder_cust_tab(p_folder_cust_tab.FIRST).folder_id);
    FETCH c_cust_rec_cur
     INTO l_folder_id;
    CLOSE c_cust_rec_cur;

    IF l_folder_id IS NULL THEN
      -- If record does not exist ,then insert new records
      l_flag := 'I';
    ELSE
      -- If record exists ,then update records
      l_flag := 'U';
    END IF;


--  Records May exist in wsh_folder_custom_actions for user selected
-- buttons,but user can chose to display a totally different set
-- of buttons when doing Save-As,so delete existing records and then
-- create new for same folder id
    IF l_flag = 'U' THEN
      -- Delete all records and then Insert New Records
      -- No need to check for records in fnd_folders
      DELETE FROM wsh_folder_custom_actions
       WHERE folder_id = l_folder_id;
    END IF;

    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
      FOR i in 1..p_folder_cust_tab.count
      LOOP
        INSERT INTO wsh_folder_custom_actions
          (ACTION_ID,
           ACTION_NAME,
           OBJECT,
           USER_ENTERED_PROMPT,
           USER_ID,
           FOLDER_ID,
           WIDTH,
           ACCESS_KEY,
           DISPLAY_AS_BUTTON_FLAG,
           DEFAULT_PROMPT,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
          )
         VALUES
          (p_folder_cust_tab(i).action_id,
           p_folder_cust_tab(i).action_name,
           p_folder_cust_tab(i).object,
           p_folder_cust_tab(i).user_entered_prompt,
           nvl(p_folder_cust_tab(i).user_id,FND_GLOBAL.USER_ID),
           p_folder_cust_tab(i).folder_id,
           p_folder_cust_tab(i).width,
           p_folder_cust_tab(i).access_key,
           p_folder_cust_tab(i).display_as_button_flag,
           p_folder_cust_tab(i).default_prompt,
           nvl(p_folder_cust_tab(i).creation_date,SYSDATE),
           nvl(p_folder_cust_tab(i).created_by, FND_GLOBAL.USER_ID),
           nvl(p_folder_cust_tab(i).last_update_date, SYSDATE),
           nvl(p_folder_cust_tab(i).last_updated_by, FND_GLOBAL.USER_ID),
           nvl(p_folder_cust_tab(i).last_update_login, FND_GLOBAL.LOGIN_ID)
          );
      END LOOP;

    ELSE
      x_return_status := l_return_status;
    END IF;

   COMMIT;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION

     WHEN others THEN
	   wsh_util_core.default_handler('WSH_FOLDER_EXTENSIONS_PVT.INSERT_UPDATE_FOLDER_CUSTOM',l_module_name);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           --
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
               WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
           END IF;
           --

END Insert_Update_Folder_Custom;

--========= DELETE FOLDER CUSTOM ACTIONS=================
-- There can be multiple records in wsh_folder_custom_actions
-- But they will be deleted by single delete and no need to loop
Procedure Delete_Folder_Custom(
          p_folder_id           IN NUMBER,
          x_return_status       OUT NOCOPY VARCHAR2)
IS PRAGMA AUTONOMOUS_TRANSACTION;
  --
  l_flag VARCHAR2(1) := 'N';
  l_debug_on BOOLEAN;
  l_count NUMBER := 0;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_FOLDER_CUSTOM';
--
  BEGIN

     l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
     --
     IF l_debug_on IS NULL
     THEN
         l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
     END IF;
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.push(l_module_name);
         WSH_DEBUG_SV.log(l_module_name,'p_folder_id',p_folder_id);
         --
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

       DELETE FROM wsh_folder_custom_actions
       WHERE folder_id = p_folder_id;

       IF sql%NOTFOUND THEN
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'No custom action for Folder Deleted');
         END IF;
       END IF;

       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Folders Deleted-',sql%rowcount);
       END IF;

       COMMIT;

  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION

     WHEN others THEN
	   wsh_util_core.default_handler('WSH_FOLDER_EXTENSIONS_PVT.DELETE_FOLDER_CUSTOM',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
            WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

END Delete_Folder_Custom;



END WSH_FOLDER_EXTENSIONS_PVT;

/
