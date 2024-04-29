--------------------------------------------------------
--  DDL for Package Body WSH_EXCEPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_EXCEPTIONS_PUB" AS
/* $Header: WSHXCPBB.pls 115.12 2004/05/24 21:40:37 dramamoo ship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_EXCEPTIONS_PUB';
-- add your constants here if any

--===================
-- PROCEDURES
--===================

------------------------------------------------------------------------------
-- Procedure:	Get_Exceptions
--
-- Parameters:  1) p_logging_entity_id - entity id for a particular entity name
--              2) p_logging_entity_name - can be 'TRIP', 'STOP', 'DELIVERY',
--                                       'DETAIL', or 'CONTAINER'
--              3) x_exceptions_tab - list of exceptions
--
-- Description: This procedure takes in a logging entity id and logging entity
--              name and create an exception table.
------------------------------------------------------------------------------

PROCEDURE Get_Exceptions (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	IN 	NUMBER,
	p_logging_entity_name	IN	VARCHAR2,

        -- program specific out parameters
        x_exceptions_tab	OUT NOCOPY 	WSH_EXCEPTIONS_PUB.XC_TAB_TYPE
	) IS

  -- Standard call to check for call compatibility
  l_api_version          CONSTANT        NUMBER  := 1.0;
  l_api_name             CONSTANT        VARCHAR2(30):= 'Get_Exceptions';
l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.'
                                                        || 'Get_Exceptions';



BEGIN

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
     wsh_debug_sv.push (l_module_name);
     wsh_debug_sv.log (l_module_name,'p_init_msg_list', p_init_msg_list);
     wsh_debug_sv.log (l_module_name,'p_logging_entity_id',
                                                          p_logging_entity_id);
     wsh_debug_sv.log (l_module_name,'p_logging_entity_name',
                                                         p_logging_entity_name);
  END IF;
  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;


  IF NOT FND_API.compatible_api_call (
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  WSH_EXCEPTIONS_GRP.Get_Exceptions (
        p_api_version         => p_api_version,
        p_init_msg_list       => FND_API.G_FALSE,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_logging_entity_id   => p_logging_entity_id,
        p_logging_entity_name => p_logging_entity_name,
        x_exceptions_tab      => x_exceptions_tab);

  FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count
     , p_data  => x_msg_data
     ,p_encoded => FND_API.G_FALSE
     );
  IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  EXCEPTION
    WHEN others THEN
     FND_MSG_PUB.Count_And_Get
          ( p_count => x_msg_count
          , p_data  => x_msg_data
          ,p_encoded => FND_API.G_FALSE
          );
      wsh_util_core.default_handler('WSH_EXCEPTIONS_PUB.GET_EXCEPTIONS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF l_debug_on THEN
         wsh_debug_sv.log (l_module_name,'Error', SUBSTR(SQLERRM,1,200));
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;


END Get_Exceptions;

------------------------------------------------------------------------------
-- Procedure:   Exception_Action
--
-- Parameters:
--
-- Description:  This procedure calls the corresponding procedures to Log,
--               Purge and Change_Status of the exceptions based on the action
--               code it receives through the parameter p_action.
------------------------------------------------------------------------------

PROCEDURE Exception_Action (
	-- Standard parameters
	p_api_version	        IN	NUMBER,
	p_init_msg_list		IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
	p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_msg_count             OUT NOCOPY      NUMBER,
        x_msg_data              OUT NOCOPY      VARCHAR2,
	x_return_status         OUT NOCOPY      VARCHAR2,

	-- Program specific parameters
        p_exception_rec         IN OUT  NOCOPY WSH_EXCEPTIONS_PUB.XC_ACTION_REC_TYPE,
	p_action	   	 IN		VARCHAR2
	) IS


	-- Standard call to check for call compatibility
  	l_api_version          CONSTANT        NUMBER  := 1.0;
  	l_api_name             CONSTANT        VARCHAR2(30):= 'Exception_Action';
l_debug_on BOOLEAN;
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME ||
              '.' || 'Get_Exceptions';
--        l_in_rec                    WSH_EXCEPTIONS_PUB.ExpInRecType;

BEGIN
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --

        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        IF l_debug_on THEN
           wsh_debug_sv.push (l_module_name);
           wsh_debug_sv.log (l_module_name,'p_api_version', p_api_version);
           wsh_debug_sv.log (l_module_name,'p_init_msg_list', p_init_msg_list);
           wsh_debug_sv.log (l_module_name,'p_validation_level',
                                                          p_validation_level);
           wsh_debug_sv.log (l_module_name,'p_commit', p_commit);
           wsh_debug_sv.log (l_module_name,'p_action', p_action);
        END IF;

  	-- Check p_init_msg_list
  	IF FND_API.to_boolean(p_init_msg_list) THEN
    		FND_MSG_PUB.initialize;
  	END IF;

  	IF NOT FND_API.compatible_api_call (
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

        p_exception_rec.caller := 'WSH_PUB';
 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        -- For Public API, Exceptions are always manually logged
        p_exception_rec.manually_logged := FND_API.G_TRUE;

        wsh_exceptions_grp.Exception_Action(
              p_api_version               => p_api_version,
              p_init_msg_list             => FND_API.G_FALSE,
              p_commit              	  => p_commit,
              p_validation_level          => p_validation_level,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data,
              x_return_status             => x_return_status,
	      p_exception_rec		  => p_exception_rec,
	      p_action			  => p_action
        ) ;

        --bms original API is not calling FND_MSG_PUB.Count_And_Get
       IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
       END IF;

EXCEPTION
	WHEN OTHERS THEN
        	WSH_UTIL_CORE.default_handler('WSH_EXCEPTIONS_PUB.EXCEPTION_ACTION');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                IF l_debug_on THEN
                   wsh_debug_sv.log (l_module_name,'Error', SUBSTR(SQLERRM,1,200));
                   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                END IF;

END Exception_Action;

END WSH_EXCEPTIONS_PUB;

/
