--------------------------------------------------------
--  DDL for Package Body WSH_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_UTILITIES" AS
/* $Header: WSHUTILB.pls 115.5 2004/04/27 21:46:15 anviswan ship $ */
/* This Function return the output log directory to create any kind of output file */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_UTILITIES';
C_MAX_MESSAGE_SIZE	 CONSTANT  NUMBER := 1000; --3509004:public api change
--
Function Get_Output_file_dir return varchar2
IS

   v_db_name VARCHAR2(100);
   v_log_name VARCHAR2(100);
   v_db_name VARCHAR2(100);
   v_st_position number(3);
   v_end_position number(3);
   v_w_position number(3);
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_OUTPUT_FILE_DIR';
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
   select INSTR(value,',',1,2),INSTR(value,',',1,3)
   into v_st_position,v_end_position from  v$parameter
   where upper(name) = 'UTL_FILE_DIR';
   v_w_position := v_end_position - v_st_position - 1;
   select substr(value,v_st_position+1,v_w_position)
   into v_log_name from v$parameter
   where upper(name) = 'UTL_FILE_DIR';
   v_log_name := ltrim(v_log_name);
   FND_FILE.PUT_NAMES(v_log_name,v_log_name,v_log_name);
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   return v_log_name;
EXCEPTION
   WHEN OTHERS then
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Output_file_dir;

--3509004:public api change
PROCEDURE process_message(
			p_entity           IN             VARCHAR2,
			p_entity_name      IN             VARCHAR2,
			p_attributes       IN             VARCHAR2,
			x_return_status    OUT NOCOPY     VARCHAR2
			) IS

l_attributes  VARCHAR2(32767) DEFAULT '';
l_sub_string VARCHAR2(32767);
l_end_index NUMBER;
l_temp     VARCHAR2(2000);
l_token_string VARCHAR2(32767);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'process_message';
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
            WSH_DEBUG_SV.log(l_module_name,'p_entity',p_entity);
            WSH_DEBUG_SV.log(l_module_name,'p_attributes',p_attributes);
        END IF;
        --
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        l_token_string := p_attributes;

        --for testing
        /*
        FOR K in 1..400 LOOP
                l_token_string := l_token_string || 'Test, ';
        END LOOP;
        */
        -- end for testing

        l_sub_string := substrb(l_token_string,1,C_MAX_MESSAGE_SIZE);
        l_end_index := INSTRB(l_sub_string,', ', -1) - 2;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_token_string',l_token_string);
            WSH_DEBUG_SV.log(l_module_name,'length(l_token_string)',length(l_token_string));
            WSH_DEBUG_SV.log(l_module_name,'l_end_index',l_end_index);
        END IF;

        while l_end_index > 0
        LOOP
                --set the message
                 FND_MESSAGE.SET_NAME('WSH','WSH_DISABLED_COLUMNS_' || p_entity);
                 FND_MESSAGE.SET_TOKEN('ENTITY_NAME',p_entity_name);
                 FND_MESSAGE.SET_TOKEN('LIST_ATTRIBUTES',substrb(l_token_string,1,l_end_index+1));
                 WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                 l_token_string := substrb(l_token_string , l_end_index + 4);

                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_token_string',l_token_string);
                    WSH_DEBUG_SV.log(l_module_name,'length(l_token_string)',length(l_token_string));
                    WSH_DEBUG_SV.log(l_module_name,'l_end_index',l_end_index);
                END IF;

                 IF length(l_token_string) <= C_MAX_MESSAGE_SIZE THEN
                      l_token_string := substr(l_token_string,1, length(l_token_string) -2);
                      IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name,'last msg l_token_string',l_token_string);
                      END IF;
                      IF l_token_string is NOT NULL THEN
                         FND_MESSAGE.SET_NAME('WSH','WSH_DISABLED_COLUMNS_' || p_entity);
                         FND_MESSAGE.SET_TOKEN('ENTITY_NAME',p_entity_name);
                         FND_MESSAGE.SET_TOKEN('LIST_ATTRIBUTES',l_token_string);
                         WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_WARNING,l_module_name);
                      END IF;
                      l_end_index := 0;
                 ELSE
                        l_sub_string := substrb(l_token_string,1,C_MAX_MESSAGE_SIZE);
                        l_end_index := INSTRB(l_sub_string,', ', -1) - 2;
                 END IF;
        END LOOP;

          IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          --
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
        --
        IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

END process_message;

END Wsh_Utilities;

/
