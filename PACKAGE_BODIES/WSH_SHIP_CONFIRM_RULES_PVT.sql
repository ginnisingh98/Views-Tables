--------------------------------------------------------
--  DDL for Package Body WSH_SHIP_CONFIRM_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIP_CONFIRM_RULES_PVT" AS
/* $Header: WSHSCTHB.pls 120.1 2005/07/29 19:22:47 wrudge noship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIP_CONFIRM_RULES_PVT';

PROCEDURE Insert_Row (
  p_ship_confirm_rule_info    IN  ship_confirm_rule_rectype,
  x_rule_id                   OUT NOCOPY NUMBER,
  x_row_id                    OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2) IS

    wsh_duplicate_name		EXCEPTION;
    l_dup_id                    NUMBER;

    CURSOR c_dup_name IS
        SELECT ship_confirm_rule_id
        FROM WSH_SHIP_CONFIRM_RULES
        WHERE name = p_ship_confirm_rule_info.name;

Begin

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

OPEN c_dup_name;
FETCH c_dup_name INTO l_dup_id;
IF c_dup_name%NOTFOUND THEN
   l_dup_id := NULL;
END IF;
CLOSE c_dup_name;

IF l_dup_id IS NOT NULL THEN
  RAISE WSH_DUPLICATE_NAME;
END IF;


INSERT INTO WSH_SHIP_CONFIRM_RULES
(
 ship_confirm_rule_id,
 effective_start_date,
 name,
 effective_end_date,
 action_flag,
 stage_del_flag,
 ship_method_default_flag,
 ship_method_code,
 ac_actual_dep_date_default,
 ac_intransit_flag,
 ac_close_trip_flag,
 ac_bol_flag,
 ac_defer_interface_flag,
 mc_intransit_flag,
 mc_close_trip_flag,
 mc_defer_interface_flag,
 mc_bol_flag,
 report_set_id,
 send_945_flag,
 creation_date,
 created_by,
 last_updated_by,
 last_update_date
)
VALUES
(
 wsh_ship_confirm_rules_s.nextval,
 p_ship_confirm_rule_info.effective_start_date,
 p_ship_confirm_rule_info.name,
 p_ship_confirm_rule_info.effective_end_date,
 p_ship_confirm_rule_info.action_flag,
 p_ship_confirm_rule_info.stage_del_flag,
 p_ship_confirm_rule_info.ship_method_default_flag,
 p_ship_confirm_rule_info.ship_method_code,
 p_ship_confirm_rule_info.ac_actual_dep_date_default,
 p_ship_confirm_rule_info.ac_intransit_flag,
 p_ship_confirm_rule_info.ac_close_trip_flag,
 p_ship_confirm_rule_info.ac_bol_flag,
 p_ship_confirm_rule_info.ac_defer_interface_flag,
 p_ship_confirm_rule_info.mc_intransit_flag,
 p_ship_confirm_rule_info.mc_close_trip_flag,
 p_ship_confirm_rule_info.mc_defer_interface_flag,
 p_ship_confirm_rule_info.mc_bol_flag,
 p_ship_confirm_rule_info.report_set_id,
 p_ship_confirm_rule_info.send_945_flag,
 sysdate,
 p_ship_confirm_rule_info.created_by,
 p_ship_confirm_rule_info.last_updated_by,
 sysdate
) returning ship_confirm_rule_id, rowid into x_rule_id, x_row_id;

  EXCEPTION
     WHEN wsh_duplicate_name THEN
           IF c_dup_name%ISOPEN THEN
             CLOSE c_dup_name;
           END IF;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
           WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);


     WHEN others THEN
           IF c_dup_name%ISOPEN THEN
             CLOSE c_dup_name;
           END IF;
           wsh_util_core.default_handler('WSH_SHIP_CONFIRM_RULES_PVT.Insert_Row');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

End Insert_Row;

PROCEDURE Update_Row (
  p_ship_confirm_rule_info    IN  ship_confirm_rule_rectype,
  x_return_status             OUT NOCOPY VARCHAR2) IS


    wsh_duplicate_name          EXCEPTION;
    l_dup_id                    NUMBER;

    CURSOR c_dup_name IS
        SELECT ship_confirm_rule_id
        FROM WSH_SHIP_CONFIRM_RULES
        WHERE name = p_ship_confirm_rule_info.name
        and ship_confirm_rule_id <> p_ship_confirm_rule_info.ship_confirm_rule_id ;

Begin

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

OPEN c_dup_name;
FETCH c_dup_name INTO l_dup_id;
IF c_dup_name%NOTFOUND THEN
   l_dup_id := NULL;
END IF;
CLOSE c_dup_name;

IF l_dup_id IS NOT NULL THEN
  RAISE WSH_DUPLICATE_NAME;
END IF;



Update WSH_SHIP_CONFIRM_RULES

SET

 EFFECTIVE_START_DATE	 	= p_ship_confirm_rule_info.effective_start_date,
 NAME                		= p_ship_confirm_rule_info.name,
 EFFECTIVE_END_DATE		= p_ship_confirm_rule_info.effective_end_date,
 ACTION_FLAG			= p_ship_confirm_rule_info.action_flag,
 STAGE_DEL_FLAG			= p_ship_confirm_rule_info.stage_del_flag,
 SHIP_METHOD_DEFAULT_FLAG	= p_ship_confirm_rule_info.ship_method_default_flag,
 SHIP_METHOD_CODE		= p_ship_confirm_rule_info.ship_method_code,
 AC_ACTUAL_DEP_DATE_DEFAULT	= p_ship_confirm_rule_info.ac_actual_dep_date_default,
 AC_INTRANSIT_FLAG		= p_ship_confirm_rule_info.ac_intransit_flag,
 AC_CLOSE_TRIP_FLAG		= p_ship_confirm_rule_info.ac_close_trip_flag,
 AC_BOL_FLAG			= p_ship_confirm_rule_info.ac_bol_flag,
 AC_DEFER_INTERFACE_FLAG	= p_ship_confirm_rule_info.ac_defer_interface_flag,
 MC_INTRANSIT_FLAG		= p_ship_confirm_rule_info.mc_intransit_flag,
 MC_CLOSE_TRIP_FLAG		= p_ship_confirm_rule_info.mc_close_trip_flag,
 MC_DEFER_INTERFACE_FLAG	= p_ship_confirm_rule_info.mc_defer_interface_flag,
 MC_BOL_FLAG			= p_ship_confirm_rule_info.mc_bol_flag,
 REPORT_SET_ID			= p_ship_confirm_rule_info.report_set_id,
 SEND_945_FLAG			= p_ship_confirm_rule_info.send_945_flag,
 LAST_UPDATED_BY		= p_ship_confirm_rule_info.last_updated_by,
 LAST_UPDATE_DATE		= SYSDATE
 WHERE SHIP_CONFIRM_RULE_ID 	= p_ship_confirm_rule_info.ship_confirm_rule_id;

  EXCEPTION
     WHEN wsh_duplicate_name THEN
           IF c_dup_name%ISOPEN THEN
             CLOSE c_dup_name;
           END IF;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
           WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);


     WHEN others THEN
           IF c_dup_name%ISOPEN THEN
             CLOSE c_dup_name;
           END IF;
           wsh_util_core.default_handler('WSH_SHIP_CONFIRM_RULES_PVT.Update_Row');
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
End Update_Row;


PROCEDURE Lock_Row(
    p_rowid                  IN   VARCHAR2,
    p_ship_confirm_rule_info IN   ship_confirm_rule_rectype)  IS

    CURSOR C_Lock_Row IS
    SELECT
           SHIP_CONFIRM_RULE_ID,
           EFFECTIVE_START_DATE,
           NAME,
           EFFECTIVE_END_DATE,
           ACTION_FLAG,
           STAGE_DEL_FLAG,
           SHIP_METHOD_DEFAULT_FLAG,
           SHIP_METHOD_CODE,
           AC_ACTUAL_DEP_DATE_DEFAULT,
           AC_INTRANSIT_FLAG,
           AC_CLOSE_TRIP_FLAG,
           AC_BOL_FLAG,
           AC_DEFER_INTERFACE_FLAG,
           MC_INTRANSIT_FLAG,
           MC_CLOSE_TRIP_FLAG,
           MC_DEFER_INTERFACE_FLAG,
           MC_BOL_FLAG,
           REPORT_SET_ID,
           SEND_945_FLAG,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE
    FROM WSH_SHIP_CONFIRM_RULES
    WHERE rowid = p_rowid
    FOR UPDATE OF SHIP_CONFIRM_RULE_ID NOWAIT;

    recinfo C_Lock_Row%ROWTYPE;
--
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
--


BEGIN

  --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
        END IF;
        --

        OPEN C_Lock_Row;
        FETCH C_Lock_Row INTO recinfo;
        IF C_Lock_Row%NOTFOUND THEN
           CLOSE C_Lock_Row;
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
           IF l_debug_on THEN

                   WSH_DEBUG_SV.log(l_module_name,'FORM_RECORD_DELETED');

           END IF;
                app_exception.raise_exception;
         END IF;
         CLOSE C_Lock_Row;

         IF
            (( p_ship_confirm_rule_info.EFFECTIVE_START_DATE = recinfo.EFFECTIVE_START_DATE) or
             (( p_ship_confirm_rule_info.EFFECTIVE_START_DATE IS NULL) and
             ( recinfo.EFFECTIVE_START_DATE IS NULL))) and
            (( p_ship_confirm_rule_info.NAME = recinfo.NAME)				or
             ((p_ship_confirm_rule_info.NAME IS NULL) and
             ( recinfo.NAME IS NULL))) 	and
            (( p_ship_confirm_rule_info.EFFECTIVE_END_DATE = recinfo.EFFECTIVE_END_DATE)		or
             (( p_ship_confirm_rule_info.EFFECTIVE_END_DATE IS NULL) and
             ( recinfo.EFFECTIVE_END_DATE IS NULL))) and
            (( p_ship_confirm_rule_info.ACTION_FLAG = recinfo.ACTION_FLAG)    		or
             (( p_ship_confirm_rule_info.ACTION_FLAG IS NULL) and
             ( recinfo.ACTION_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.STAGE_DEL_FLAG = recinfo.STAGE_DEL_FLAG)			or
             (( p_ship_confirm_rule_info.STAGE_DEL_FLAG IS NULL) and
             ( recinfo.STAGE_DEL_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.SHIP_METHOD_DEFAULT_FLAG = recinfo.SHIP_METHOD_DEFAULT_FLAG)	or
             (( p_ship_confirm_rule_info.SHIP_METHOD_DEFAULT_FLAG IS NULL) and
             ( recinfo.SHIP_METHOD_DEFAULT_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.SHIP_METHOD_CODE = recinfo.SHIP_METHOD_CODE)	or
             (( p_ship_confirm_rule_info.SHIP_METHOD_CODE IS NULL) and
             ( recinfo.SHIP_METHOD_CODE IS NULL))) and
            (( p_ship_confirm_rule_info.AC_ACTUAL_DEP_DATE_DEFAULT = recinfo.AC_ACTUAL_DEP_DATE_DEFAULT) or
             (( p_ship_confirm_rule_info.AC_ACTUAL_DEP_DATE_DEFAULT IS NULL)and
             ( recinfo.AC_ACTUAL_DEP_DATE_DEFAULT IS NULL))) and
            (( p_ship_confirm_rule_info.AC_INTRANSIT_FLAG = recinfo.AC_INTRANSIT_FLAG)   or
             (( p_ship_confirm_rule_info.AC_INTRANSIT_FLAG IS NULL) and
             ( recinfo.AC_INTRANSIT_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.AC_CLOSE_TRIP_FLAG = recinfo.AC_CLOSE_TRIP_FLAG)           or
             (( p_ship_confirm_rule_info.AC_CLOSE_TRIP_FLAG IS NULL) and
             ( recinfo.AC_CLOSE_TRIP_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.AC_BOL_FLAG = recinfo.AC_BOL_FLAG)                         or
             (( p_ship_confirm_rule_info.AC_BOL_FLAG IS NULL) and
             ( recinfo.AC_BOL_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.AC_DEFER_INTERFACE_FLAG = recinfo.AC_DEFER_INTERFACE_FLAG) or
             (( p_ship_confirm_rule_info.AC_DEFER_INTERFACE_FLAG IS NULL) and
             ( recinfo.AC_DEFER_INTERFACE_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.MC_DEFER_INTERFACE_FLAG = recinfo.MC_DEFER_INTERFACE_FLAG) or
             (( p_ship_confirm_rule_info.MC_DEFER_INTERFACE_FLAG IS NULL) and
             ( recinfo.MC_DEFER_INTERFACE_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.MC_INTRANSIT_FLAG = recinfo.MC_INTRANSIT_FLAG)             or
             (( p_ship_confirm_rule_info.MC_INTRANSIT_FLAG IS NULL) and
             ( recinfo.MC_INTRANSIT_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.MC_CLOSE_TRIP_FLAG = recinfo.MC_CLOSE_TRIP_FLAG)           or
             (( p_ship_confirm_rule_info.MC_CLOSE_TRIP_FLAG IS NULL) and
             ( recinfo.MC_CLOSE_TRIP_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.MC_BOL_FLAG = recinfo.MC_BOL_FLAG)                         or
             (( p_ship_confirm_rule_info.MC_BOL_FLAG IS NULL) and
             ( recinfo.MC_BOL_FLAG IS NULL))) and
            (( p_ship_confirm_rule_info.REPORT_SET_ID = recinfo.REPORT_SET_ID)                     or
             (( p_ship_confirm_rule_info.REPORT_SET_ID IS NULL) and
             ( recinfo.REPORT_SET_ID IS NULL))) and
            (( p_ship_confirm_rule_info.SEND_945_FLAG = recinfo.SEND_945_FLAG)                    or
             (( p_ship_confirm_rule_info.SEND_945_FLAG IS NULL) and
             ( recinfo.SEND_945_FLAG IS NULL))) /*and
            (( p_ship_confirm_rule_info.CREATION_DATE = recinfo.CREATION_DATE)                     or
             (( p_ship_confirm_rule_info.CREATION_DATE IS NULL) and
             ( recinfo.CREATION_DATE IS NULL))) and
            (( p_ship_confirm_rule_info.CREATED_BY = recinfo.CREATED_BY)                           or
             (( p_ship_confirm_rule_info.CREATED_BY IS NULL) and
             ( recinfo.CREATED_BY IS NULL))) and
            (( p_ship_confirm_rule_info.LAST_UPDATED_BY = recinfo.LAST_UPDATED_BY)                 or
             (( p_ship_confirm_rule_info.LAST_UPDATED_BY IS NULL) and
             ( recinfo.LAST_UPDATED_BY IS NULL))) and
            (( p_ship_confirm_rule_info.LAST_UPDATE_DATE = recinfo.LAST_UPDATE_DATE)               or
             (( p_ship_confirm_rule_info.LAST_UPDATE_DATE IS NULL) and
             ( recinfo.LAST_UPDATE_DATE IS NULL)))*/ THEN
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Nothing has changed');
                    WSH_DEBUG_SV.pop(l_module_name);
                END IF;
                --
                RETURN;
        ELSE
                FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                app_exception.raise_exception;
        END IF;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
        WHEN app_exception.application_exception or app_exception.record_lock_exception THEN

             if (c_lock_row%ISOPEN) then
                  close c_lock_row;
              end if;


              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.APPLICATION_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.APPLICATION_EXCEPTION');
              END IF;
              --
              RAISE;


        WHEN others THEN


             if (c_lock_row%ISOPEN) then
                  close c_lock_row;
              end if;

              FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
              FND_MESSAGE.Set_Token('PACKAGE', 'WSH_SHIP_CONFRIM_RULES_PVT.LOCK_ROW');
              FND_MESSAGE.Set_Token('ORA_ERROR',sqlcode);
              FND_MESSAGE.Set_Token('ORA_TEXT',sqlerrm);

              --
              IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                  WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
              END IF;
              --
              RAISE;

--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
END Lock_Row;





PROCEDURE Delete_Row(
        p_rowid         IN  VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2) IS
        --
        l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
        --
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '. ' || 'DELETE_ROW';
        --
  BEGIN

    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_ROWID',P_ROWID);
    END IF;
    --
    DELETE FROM WSH_SHIP_CONFIRM_RULES
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
--
    EXCEPTION
      WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        wsh_util_core.default_handler('WSH_SHIP_CONFIRM_RULES_PVT.DELETE_ROW');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
  END Delete_Row;






END WSH_SHIP_CONFIRM_RULES_PVT;

/
