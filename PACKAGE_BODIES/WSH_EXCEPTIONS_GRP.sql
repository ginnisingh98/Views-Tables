--------------------------------------------------------
--  DDL for Package Body WSH_EXCEPTIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_EXCEPTIONS_GRP" AS
/* $Header: WSHXCPGB.pls 120.4 2006/01/04 10:02:21 parkhj noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_EXCEPTIONS_GRP';
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
        x_return_status         OUT  NOCOPY    VARCHAR2,
        x_msg_count             OUT  NOCOPY    NUMBER,
        x_msg_data              OUT  NOCOPY    VARCHAR2,

        -- program specific parameters
        p_logging_entity_id	IN 	NUMBER,
	p_logging_entity_name	IN	VARCHAR2,

        -- program specific out parameters
        x_exceptions_tab	OUT NOCOPY 	WSH_EXCEPTIONS_PUB.XC_TAB_TYPE
	) IS

  CURSOR Get_Trip_Exceptions (v_trip_id NUMBER) IS
  SELECT exception_id, exception_name, status
  FROM   wsh_exceptions
  WHERE  trip_id = v_trip_id;

  CURSOR Get_Stop_Exceptions (v_stop_id NUMBER) IS
  SELECT exception_id, exception_name, status
  FROM   wsh_exceptions
  WHERE  trip_stop_id = v_stop_id;

  CURSOR Get_Delivery_Exceptions (v_delivery_id NUMBER) IS
  SELECT exception_id, exception_name, status
  FROM   wsh_exceptions
  WHERE  delivery_id = v_delivery_id;

  CURSOR Get_Detail_Exceptions (v_detail_id NUMBER) IS
  SELECT exception_id, exception_name, status
  FROM   wsh_exceptions
  WHERE  delivery_detail_id = v_detail_id;

  CURSOR Get_Container_Exceptions (v_del_detail_id NUMBER) IS
  SELECT exception_id, exception_name, status
  FROM   WSH_EXCEPTIONS
  WHERE  delivery_detail_id = v_del_detail_id;

  -- Standard call to check for call compatibility
  l_api_version          CONSTANT        NUMBER  := 1.0;
  l_api_name             CONSTANT        VARCHAR2(30):= 'Get_Exceptions';

  l_count   NUMBER;

  wsh_invalid_exception_name EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_EXCEPTIONS';
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
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_NAME',P_LOGGING_ENTITY_NAME);
      WSH_DEBUG_SV.log(l_module_name,'P_LOGGING_ENTITY_ID',P_LOGGING_ENTITY_ID);
  END IF;

  IF NOT FND_API.compatible_api_call (
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_count := 0;
  IF (p_logging_entity_name = 'TRIP') THEN
    FOR rec in Get_Trip_Exceptions(p_logging_entity_id) LOOP
        l_count := l_count + 1;
        x_exceptions_tab(l_count) := rec;
    END LOOP;
  ELSIF (p_logging_entity_name = 'STOP') THEN
    FOR rec in Get_Stop_Exceptions(p_logging_entity_id) LOOP
       l_count := l_count + 1;
       x_exceptions_tab(l_count) := rec;
    END LOOP;
  ELSIF (p_logging_entity_name = 'DELIVERY') THEN
    FOR rec in Get_Delivery_Exceptions(p_logging_entity_id) LOOP
       l_count := l_count + 1;
       x_exceptions_tab(l_count) := rec;
    END LOOP;
  ELSIF (p_logging_entity_name = 'DETAIL') THEN
    FOR rec in Get_Detail_Exceptions(p_logging_entity_id) LOOP
       l_count := l_count + 1;
       x_exceptions_tab(l_count) := rec;
    END LOOP;
  ELSIF (p_logging_entity_name = 'CONTAINER') THEN
    FOR rec in Get_Container_Exceptions(p_logging_entity_id) LOOP
       l_count := l_count + 1;
       x_exceptions_tab(l_count) := rec;
    END LOOP;
  ELSE
    raise wsh_invalid_exception_name;
  END IF;

--
-- Debug Statements
--
  IF l_debug_on THEN
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;
--

  EXCEPTION
    WHEN wsh_invalid_exception_name THEN
      FND_MESSAGE.Set_Name('FND', 'WSH_XC_INVALID_LOGGING_ENTITY');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
               p_count => x_msg_count,
               p_data  => x_msg_data,
	       p_encoded => FND_API.G_FALSE
               );

--
-- Debug Statements
--
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_EXCEPTION_NAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_EXCEPTION_NAME');
   END IF;
--

    WHEN others THEN
      IF Get_Trip_Exceptions%ISOPEN THEN
	  CLOSE Get_Trip_Exceptions;
      END IF;
      IF Get_Stop_Exceptions%ISOPEN THEN
	  CLOSE Get_Stop_Exceptions;
      END IF;
      IF Get_Delivery_Exceptions%ISOPEN THEN
	  CLOSE Get_Delivery_Exceptions;
      END IF;
      IF Get_Detail_Exceptions%ISOPEN THEN
	  CLOSE Get_Detail_Exceptions;
      END IF;
      IF Get_Container_Exceptions%ISOPEN THEN
	  CLOSE Get_Container_Exceptions;
      END IF;

      wsh_util_core.default_handler('WSH_EXCEPTIONS_GRP.GET_EXCEPTIONS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--

END Get_Exceptions;


------------------------------------------------------------------------------
-- Procedure:   Change_Status
--
-- Parameters:  1) p_logging_entity_id - entity id for a particular entity name
--              2) p_logging_entity_name - can be 'TRIP', 'STOP', 'DELIVERY',
--                                       'DETAIL', or 'CONTAINER'
--              3) p_exception_name - name of exceptions which will have
--                               status updated
--              4) p_exception_id - specific exception to be changed
--              5) p_new_status - Status which exceptions will be updated to
--              6) x_updated_rows - returns number of rows get updated
-- Description: This procedure will change status of exceptions for a
--              particular entity id, entity name, exception name to a new
--              status specified.
------------------------------------------------------------------------------

PROCEDURE Change_Status (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status         OUT NOCOPY      VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT  NOCOPY    VARCHAR2,

        -- program specific parameters
        p_logging_entity_id     IN      NUMBER,
        p_logging_entity_name   IN      VARCHAR2,
	p_exception_name	IN	VARCHAR2  DEFAULT NULL,
	p_exception_id	        IN	NUMBER    DEFAULT NULL,
	p_new_status		IN	VARCHAR2,
        x_updated_rows		OUT NOCOPY 	NUMBER
	) IS

  -- To get the current status of the Exception
  CURSOR get_status IS
  SELECT status
  FROM   wsh_exceptions
  WHERE  exception_id = p_exception_id ;

  -- Standard call to check for call compatibility
  l_api_version          CONSTANT        NUMBER  := 1.0;
  l_api_name             CONSTANT        VARCHAR2(30):= 'Change_Status';

  l_exceptions_tab WSH_EXCEPTIONS_PUB.xc_tab_type;
  l_temp_tab WSH_EXCEPTIONS_PUB.xc_tab_type;
  l_count NUMBER;
  l_new_status VARCHAR2(30);
  l_old_status VARCHAR2(30);
  l_success_count NUMBER;
  l_error_count NUMBER;

  WSH_INVALID_EXCEPTION_ID EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_STATUS';
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
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'p_api_version',p_api_version);
      WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list);
      WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
      WSH_DEBUG_SV.log(l_module_name,'p_validation_level',p_validation_level);
      WSH_DEBUG_SV.log(l_module_name,'p_logging_entity_id',p_logging_entity_id);
      WSH_DEBUG_SV.log(l_module_name,'p_logging_entity_name',p_logging_entity_name);
      WSH_DEBUG_SV.log(l_module_name,'p_exception_name',p_exception_name);
      WSH_DEBUG_SV.log(l_module_name,'p_exception_id',p_exception_id);
      WSH_DEBUG_SV.log(l_module_name,'p_new_status',p_new_status);
  END IF;

  IF NOT FND_API.compatible_api_call (
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- initialize parameters
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_new_status := p_new_status;

  -- Checking p_logging_entity_id, p_logging_entity_name, and p_exception_name
  -- if any of them is not valid then return
  IF (p_logging_entity_id = FND_API.G_MISS_NUM) OR
     (p_logging_entity_name = FND_API.G_MISS_CHAR) OR
     (p_exception_name = FND_API.G_MISS_CHAR) OR
     (p_new_status = FND_API.G_MISS_CHAR) THEN
    x_updated_rows := 0;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;

  IF p_exception_id IS NULL THEN
     -- Call get_exceptions to get a list of exceptions per logging_entity_id and logging_entity_name
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_EXCEPTIONS_GRP.GET_EXCEPTIONS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_EXCEPTIONS_GRP.Get_Exceptions (p_api_version => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count => x_msg_count,
                                        x_msg_data => x_msg_data,
                                        p_logging_entity_id => p_logging_entity_id,
                                        p_logging_entity_name => p_logging_entity_name,
                                        x_exceptions_tab => l_temp_tab);
     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) OR (l_temp_tab.count = 0) THEN
       x_updated_rows := 0;
       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
       RETURN;
     END IF;

     -- If exception_name is specified, only the particular exception will be updated with
     -- new_status for the passed logging_entity_id; otherwise, all the exceptions will be
     -- updated with new_status for the passed logging_entity_id.
     IF p_exception_name IS NULL THEN
       l_exceptions_tab := l_temp_tab;
     ELSE
       l_count := 0;
       For i in 1..l_temp_tab.count LOOP
         IF l_temp_tab(i).exception_name = p_exception_name THEN
           l_count := l_count + 1;
           l_exceptions_tab(l_count) := l_temp_tab(i);
         END IF;
       END LOOP;
     END IF;

     -- Looping through the exception list and update status accordingly
     IF l_exceptions_tab.count > 0 THEN
       l_error_count := 0;
       l_success_count := 0;
       For i in 1..l_exceptions_tab.count LOOP
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.CHANGE_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         --
         WSH_XC_UTIL.change_status (p_api_version => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    p_commit => FND_API.g_false,
                                    p_validation_level => p_validation_level,
                                    x_return_status => x_return_status,
                                    x_msg_count => x_msg_count,
                                    x_msg_data => x_msg_data,
                                    p_exception_id => l_exceptions_tab(i).exception_id,
                                    p_old_status => l_exceptions_tab(i).status,
                                    p_set_default_status =>  FND_API.G_FALSE,
                                    x_new_status => l_new_status
                                    );

         IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
           l_error_count := l_error_count + 1;
         ELSE
           l_success_count := l_success_count + 1;
         END IF;
       END LOOP;
     END IF;

  ELSE
     -- Specific Exception has to be updated
     l_error_count := 0;
     l_success_count := 0;

     OPEN get_status;
     FETCH get_status INTO l_old_status;
     IF get_status%NOTFOUND THEN
        RAISE WSH_INVALID_EXCEPTION_ID;
     END IF;
     CLOSE get_status;

     --
     -- Debug Statements
     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.CHANGE_STATUS',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_XC_UTIL.change_status (
                                p_api_version        => p_api_version,
                                p_init_msg_list      => p_init_msg_list,
                                p_commit             => FND_API.g_false,
                                p_validation_level   => p_validation_level,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_exception_id       => p_exception_id,
                                p_old_status         => l_old_status,
                                p_set_default_status => FND_API.G_FALSE,
                                x_new_status         => l_new_status
                               );

     IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
        l_error_count := l_error_count + 1;
     ELSE
        l_success_count := l_success_count + 1;
     END IF;

  END IF;

  IF l_error_count > 0 THEN
    IF l_success_count = 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;
  ELSE
    IF l_success_count = 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
    ELSE
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    END IF;
  END IF;

  x_updated_rows := l_success_count;

  IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING))
		AND FND_API.TO_BOOLEAN(p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data,
                    p_encoded => FND_API.G_FALSE
                    );
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

  EXCEPTION
    WHEN WSH_INVALID_EXCEPTION_ID THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      wsh_util_core.add_message(x_return_status);
      FND_MSG_PUB.Count_And_Get(
                        p_count  => x_msg_count,
                        p_data   => x_msg_data,
                        p_encoded => FND_API.G_FALSE
                        );

      --
      -- Debug Statements
      --
      IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_EXCEPTION_ID exception has occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_EXCEPTION_ID');
      END IF;
      --

    WHEN others THEN
      wsh_util_core.default_handler('WSH_EXCEPTIONS_GRP.CHANGE_STATUS');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
           FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
      END IF;
      FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data,
                        p_encoded => FND_API.G_FALSE
                );

--
-- Debug Statements
--
      IF l_debug_on THEN
    		WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    		WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
--

END Change_Status;


------------------------------------------------------------------------------
-- Procedure:   Log_Exception
--
-- Parameters:
--
-- Description: This Procedure is to log a new exception or to restrictly
--              update an existing exception. Update is allowed only for
--              the fields which are NULL.
--
------------------------------------------------------------------------------

PROCEDURE Log_Exception (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_msg_count             OUT     NOCOPY NUMBER,
        x_msg_data              OUT     NOCOPY VARCHAR2,
        x_return_status         OUT     NOCOPY VARCHAR2,

        -- Program specific parameters
        p_exception_rec          IN OUT  NOCOPY   WSH_EXCEPTIONS_PUB.XC_ACTION_REC_TYPE
        ) IS

        -- cursor to validate stop_location
        CURSOR C1(c_trip_id NUMBER) IS
                SELECT  trip_stop_id
                FROM    wsh_xc_trip_stops_v
                WHERE   trip_id = c_trip_id
                AND     location_code = p_exception_rec.stop_location_id;

        -- cursor to validate delivery_detail_id
        CURSOR C2(c_delivery_id NUMBER) IS
                SELECT  wdd.delivery_detail_id, wda.delivery_id, wda.delivery_assignment_id
                FROM    wsh_delivery_details wdd, wsh_delivery_assignments_v wda
                WHERE   wdd.delivery_detail_id = wda.delivery_detail_id
                AND     ((c_delivery_id is null) or (wda.delivery_id =c_delivery_id))
                AND     wdd.delivery_detail_id = p_exception_rec.delivery_detail_id
                AND     wdd.container_flag IN ('N', 'Y'); -- R12 MDC

        -- cursor to get the delivery_detail_id for container_name
        CURSOR C_del_detail (c_container_name VARCHAR2) IS
                SELECT delivery_detail_id
                FROM   wsh_delivery_details
                WHERE  container_flag = 'Y'
                AND    container_name = c_container_name
                AND    delivery_detail_id =
                         nvl(p_exception_rec.delivery_detail_id, delivery_detail_id);

      --R12 MDC
      CURSOR c_check_consol_dlvy(p_delivery_id IN NUMBER) IS
      SELECT delivery_id
      FROM   wsh_new_deliveries
      WHERE  delivery_id = p_delivery_id
      AND    delivery_type = 'STANDARD';

        -- local variables
        l_exception_id                  NUMBER  DEFAULT NULL;
        l_trip_id                       NUMBER  DEFAULT NULL;
        l_trip_stop_id                  NUMBER  DEFAULT NULL;
        l_delivery_id                   NUMBER  DEFAULT NULL;
	l_delivery_id_temp		NUMBER  DEFAULT NULL;
        l_logged_at_location_id         NUMBER;
        l_exception_location_id         NUMBER;
        l_delivery_detail_id            NUMBER;
        l_delivery_assignment_id        NUMBER;
        l_result                        BOOLEAN;
        l_return_status                 VARCHAR2(1) DEFAULT FND_API.G_RET_STS_SUCCESS;
        l_msg_reason                    VARCHAR2(150);
	l_logging_entity		VARCHAR2(30);
	l_severity			VARCHAR2(30);

        -- standard version information
        l_api_version        CONSTANT        NUMBER          := 1.0;
        l_api_name           CONSTANT        VARCHAR2(30)    := 'Log_Exception';

        WSH_XC_INVALID_LOCATION         EXCEPTION;
        WSH_INVALID_DELIVERY_DETAIL     EXCEPTION;
        WSH_INVALID_CONTAINER_NAME      EXCEPTION;
        WSH_INVALID_TRIPNAME            EXCEPTION;
        WSH_INVALID_DELIVERY            EXCEPTION;
	WSH_INVALID_CONSOL_DELIVERY	EXCEPTION;
        WSH_INVALID_EXCEPTION_LOCATION  EXCEPTION;
        WSH_INVALID_LOGGED_AT_LOCATION  EXCEPTION;
        WSH_XC_INVALID_DATE             EXCEPTION;
        WSH_XC_INVALID_OPERATION        EXCEPTION;
        WSH_INVALID_INVENTORY_CONTROL   EXCEPTION;
	WSH_XC_LOOKUP_LOG		EXCEPTION;
	WSH_XC_LOOKUP_SEVERITY		EXCEPTION;
	WSH_MULTIPLE_CONTAINERS         EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOG_EXCEPTION';
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
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            wsh_debug_sv.log(l_module_name,'p_api_version',p_api_version);
            wsh_debug_sv.log(l_module_name,'p_init_msg_list',p_init_msg_list);
            wsh_debug_sv.log(l_module_name,'p_validation_level',p_validation_level);
            wsh_debug_sv.log(l_module_name,'p_commit',p_commit);
            wsh_debug_sv.log (l_module_name,'request_id', p_exception_rec.request_id);
            wsh_debug_sv.log (l_module_name,'exception_name',
                                                            p_exception_rec.exception_name);
            wsh_debug_sv.log (l_module_name,'status', p_exception_rec.status);
            wsh_debug_sv.log (l_module_name,'logging_entity',
                                                            p_exception_rec.logging_entity);
            wsh_debug_sv.log (l_module_name,'logging_entity_id',
                                                            p_exception_rec.logging_entity_id);
            wsh_debug_sv.log (l_module_name,'logged_at_location_code',
                                                    p_exception_rec.logged_at_location_code);
            wsh_debug_sv.log (l_module_name,'exception_location_code',
                                                   p_exception_rec.exception_location_code);
            wsh_debug_sv.log (l_module_name,'severity', p_exception_rec.severity);
            wsh_debug_sv.log (l_module_name,'delivery_name', p_exception_rec.delivery_name);
            wsh_debug_sv.log (l_module_name,'trip_name', p_exception_rec.trip_name);
            wsh_debug_sv.log (l_module_name,'stop_location_id', p_exception_rec.stop_location_id);
            wsh_debug_sv.log (l_module_name,'delivery_detail_id', p_exception_rec.delivery_detail_id);
        END IF;

	IF NOT FND_API.compatible_api_call(
                                     l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check p_init_msg_list
        IF FND_API.to_boolean(p_init_msg_list)  THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Check for Required parameter 'exception_location'
        IF p_exception_rec.exception_id IS NULL THEN
             IF p_exception_rec.exception_location_code IS NULL THEN
               l_msg_reason := 'Required parameter exception_location is missing for logging a new exception';
               RAISE WSH_XC_INVALID_OPERATION;
             END IF;
        END IF;

        -- Validating logging_entity
        IF p_exception_rec.logging_entity IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOOKUP to Validate the logging entity',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Lookup('LOGGING_ENTITY',l_logging_entity,
                                                p_exception_rec.logging_entity,l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_XC_LOOKUP_LOG;
            END IF;
        END IF;
        END IF;

        -- Validate logged_at_location
        IF p_exception_rec.logged_at_location_code IS NOT NULL THEN
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION to Validate the Logged at Location',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_UTIL_VALIDATE.Validate_Location(
                        p_location_id      => l_logged_at_location_id,
                        p_location_code    => p_exception_rec.logged_at_location_code,
                        x_return_status    => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_INVALID_LOGGED_AT_LOCATION;
            END IF;
        END IF;
        END IF;

        -- Validate exception_location
        IF p_exception_rec.exception_location_code IS NOT NULL THEN
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION to Validate the Exception Location',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_UTIL_VALIDATE.Validate_Location (
                        p_location_id      => l_exception_location_id,
                        p_location_code    => p_exception_rec.exception_location_code,
                        x_return_status    => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_INVALID_EXCEPTION_LOCATION;
            END IF;
        END IF;
        END IF;

	-- Validate Trip Name
        IF p_exception_rec.trip_name IS NOT NULL THEN
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_TRIP_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_UTIL_VALIDATE.Validate_Trip_Name(
                                        p_trip_id       => l_trip_id,
                                        p_trip_name     => p_exception_rec.trip_name,
                                        x_return_status => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_INVALID_TRIPNAME;
            END IF;
        END IF;
        END IF;

	-- Validate stop_location
        IF l_trip_id IS NOT NULL AND p_exception_rec.stop_location_id IS NOT NULL THEN
                OPEN C1(l_trip_id);
                FETCH C1 INTO l_trip_stop_id;
                IF C1%NOTFOUND THEN
                        RAISE WSH_XC_INVALID_LOCATION;
                END IF;
                CLOSE C1;
        END IF;

        -- Validate delivery_name
        IF p_exception_rec.delivery_name IS NOT NULL THEN
                 --
                 -- Debug Statements
                 --
                 IF l_debug_on THEN
                     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_DELIVERY_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                 END IF;
                 --
                 WSH_UTIL_VALIDATE.Validate_Delivery_Name(
                                        p_delivery_id   => l_delivery_id,
                                        p_delivery_name => p_exception_rec.delivery_name,
                                        x_return_status => l_return_status);
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
             IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 x_return_status := l_return_status;
             ELSE
                 RAISE WSH_INVALID_DELIVERY;
             END IF;
           END IF;

          --R12 MDC
          --Delivery must be a standard delivery
          OPEN c_check_consol_dlvy(l_delivery_Id);
          FETCH c_check_consol_dlvy INTO l_delivery_Id;
          IF c_check_consol_dlvy%NOTFOUND THEN
             CLOSE c_check_consol_dlvy;
             RAISE WSH_INVALID_CONSOL_DELIVERY;
          END IF;
          CLOSE c_check_consol_dlvy;
        END IF;

	-- Validate delivery_detail_id
        IF p_exception_rec.delivery_detail_id IS NOT NULL THEN
                OPEN C2(l_delivery_id);
                FETCH C2 INTO l_delivery_detail_id,l_delivery_id_temp,l_delivery_assignment_id;
                IF C2%NOTFOUND THEN
                        RAISE WSH_INVALID_DELIVERY_DETAIL;
                END IF;
                CLOSE C2;
        END IF;
        IF l_delivery_id IS NULL THEN
	 	l_delivery_id := l_delivery_id_temp;
	END IF;

        -- Get the delivery_detail_id if only Container_Name is passed
        IF p_exception_rec.container_name IS NOT NULL THEN
                 OPEN C_del_detail(p_exception_rec.container_name);
                 FETCH C_del_detail INTO l_delivery_detail_id;
                 IF C_del_detail%NOTFOUND THEN
                        RAISE WSH_INVALID_CONTAINER_NAME;
                 END IF;
		 FETCH C_del_detail INTO l_delivery_detail_id;
		 IF C_del_detail%FOUND THEN   --LPN Synch Up..samanna.to check if multiple records returned
			RAISE WSH_MULTIPLE_CONTAINERS;
		 END IF;
                 CLOSE C_del_detail;

	END IF;

        -- Validate if departure date is prior to arrival_date
        IF p_exception_rec.departure_date > p_exception_rec.arrival_date THEN
                RAISE WSH_XC_INVALID_DATE;
        END IF;

	-- Validate inventory controls of the item
        IF p_exception_rec.inventory_item_id IS NOT NULL  THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_INV.VALIDATE_SERIAL',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_DELIVERY_DETAILS_INV.Validate_Serial(
                        p_serial_number     => p_exception_rec.serial_number,
                        p_lot_number        => p_exception_rec.lot_number,
                        p_organization_id   => p_exception_rec.org_id,
                        p_inventory_item_id => p_exception_rec.inventory_item_id,
                        p_subinventory  => p_exception_rec.subinventory,
                        p_revision      => p_exception_rec.revision,
                        p_locator_id    => p_exception_rec.locator_id,
                        x_return_status => l_return_status,
                        x_result        => l_result );
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_INVALID_INVENTORY_CONTROL;
            END IF;
        END IF;
        END IF;

        -- Call Private API to Log a new exception or update the existing exception
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        --
        WSH_XC_UTIL.log_exception(
                        p_api_version      => p_api_version,
                        p_init_msg_list    => FND_API.G_FALSE,
                        p_commit           => FND_API.G_FALSE,
                        p_validation_level => p_validation_level,
                        x_return_status    => l_return_status,
                        x_msg_count        => x_msg_count,
                        x_msg_data         => x_msg_data,
                        x_exception_id     => p_exception_rec.exception_id,
                        p_exception_location_id  => l_exception_location_id,
                        p_logged_at_location_id  => l_logged_at_location_id,
                        p_logging_entity         => l_logging_entity,
                        p_logging_entity_id      => p_exception_rec.logging_entity_id,
                        p_exception_name         => p_exception_rec.exception_name,
                        p_message                => p_exception_rec.message,
                        p_manually_logged        => p_exception_rec.manually_logged,
                        p_trip_id                => l_trip_id,
                        p_trip_name              => p_exception_rec.trip_name,
                        p_trip_stop_id           => l_trip_stop_id,
                        p_delivery_id            => l_delivery_id,
                        p_delivery_name          => p_exception_rec.delivery_name,
                        p_delivery_detail_id     => p_exception_rec.delivery_detail_id,
                        p_delivery_assignment_id => l_delivery_assignment_id,
                        p_container_name         => p_exception_rec.container_name,
                        p_inventory_item_id      => p_exception_rec.inventory_item_id,
                        p_lot_number             => p_exception_rec.lot_number,
-- HW OPMCONV. No need for sublot anymore
--                      p_sublot_number          => p_exception_rec.sublot_number,
                        p_revision               => p_exception_rec.revision,
                        p_serial_number          => p_exception_rec.serial_number,
                        p_unit_of_measure        => p_exception_rec.unit_of_measure,
                        p_quantity               => p_exception_rec.quantity,
                        p_unit_of_measure2       => p_exception_rec.unit_of_measure2,
                        p_quantity2              => p_exception_rec.quantity2,
                        p_subinventory           => p_exception_rec.subinventory,
                        p_locator_id             => p_exception_rec.locator_id,
                        p_arrival_date           => p_exception_rec.arrival_date,
                        p_departure_date         => p_exception_rec.departure_date,
                        p_error_message          => p_exception_rec.error_message,
                        p_attribute_category     => p_exception_rec.attribute_category,
                        p_attribute1             => p_exception_rec.attribute1,
                        p_attribute2             => p_exception_rec.attribute2,
                        p_attribute3             => p_exception_rec.attribute3,
                        p_attribute4             => p_exception_rec.attribute4,
                        p_attribute5             => p_exception_rec.attribute5,
                        p_attribute6             => p_exception_rec.attribute6,
                        p_attribute7             => p_exception_rec.attribute7,
                        p_attribute8             => p_exception_rec.attribute8,
                        p_attribute9             => p_exception_rec.attribute9,
                        p_attribute10            => p_exception_rec.attribute10,
                        p_attribute11            => p_exception_rec.attribute11,
                        p_attribute12            => p_exception_rec.attribute12,
                        p_attribute13            => p_exception_rec.attribute13,
                        p_attribute14            => p_exception_rec.attribute14,
                        p_attribute15            => p_exception_rec.attribute15,
                        p_request_id             => p_exception_rec.request_id,
                        p_batch_id               => p_exception_rec.batch_id
                );

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	        x_return_status := l_return_status;
	END IF;

        FND_MSG_PUB.Count_And_Get(
                        p_count  => x_msg_count,
                        p_data   => x_msg_data,
		        p_encoded => FND_API.G_FALSE
                        );
--
-- Debug Statements
--
	IF l_debug_on THEN
    		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
--

EXCEPTION
	-- LPN Synch Up ..samanna
	WHEN WSH_MULTIPLE_CONTAINERS THEN
		IF C_Del_Detail%ISOPEN THEN
			close C_Del_Detail;
		END IF;
		FND_MESSAGE.SET_NAME('WSH','WSH_MULTIPLE_CONTAINERS');
		FND_MESSAGE.SET_TOKEN('CONT_NAME',p_exception_rec.container_name);
		x_return_status := FND_API.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status,l_module_name);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
		        p_encoded => FND_API.G_FALSE
			);
	--debug messages
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_MULTIPLE_CONTAINERS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_MULTIPLE_CONTAINERS');
		END IF;
	--
        WHEN WSH_XC_INVALID_OPERATION THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_OPERATION');
                FND_MESSAGE.SET_TOKEN('REASON', l_msg_reason);
	 	x_return_status := FND_API.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
		        p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
	    		WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_OPERATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_OPERATION');
		END IF;
--

        WHEN WSH_XC_LOOKUP_LOG THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOOKUP_TYPE');
                FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE','LOGGING_ENTITY');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get(
                                p_count  => x_msg_count,
                                p_data   => x_msg_data,
			        p_encoded => FND_API.G_FALSE
                                );
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_LOOKUP_LOG exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_LOOKUP_LOG');
		END IF;
--

       WHEN WSH_XC_LOOKUP_SEVERITY THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOOKUP_TYPE');
                FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE','SEVERITY');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
                FND_MSG_PUB.Count_And_Get(
                                p_count  => x_msg_count,
                                p_data   => x_msg_data,
			        p_encoded => FND_API.G_FALSE
                                );
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_LOOKUP_SEVERITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_LOOKUP_SEVERITY');
		END IF;
--

        WHEN WSH_INVALID_TRIPNAME THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PUB_INVALID_PARAMETER');
                FND_MESSAGE.SET_TOKEN('PARAMETER','Trip_Name');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_TRIPNAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_TRIPNAME');
		END IF;
--

        WHEN WSH_INVALID_DELIVERY THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PUB_INVALID_PARAMETER');
                FND_MESSAGE.SET_TOKEN('PARAMETER','Delivery_Name');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DELIVERY');
		END IF;
--
        WHEN WSH_INVALID_CONSOL_DELIVERY THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PUB_CONSOL_DEL_EXP');
                FND_MESSAGE.SET_TOKEN('PARAMETER',p_exception_rec.delivery_name);
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONSOL_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONSOL_DELIVERY');
		END IF;
--

        WHEN WSH_INVALID_LOGGED_AT_LOCATION THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_LOGGED_AT_LOCATION');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_LOGGED_AT_LOCATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_LOGGED_AT_LOCATION');
		END IF;
--

        WHEN WSH_INVALID_EXCEPTION_LOCATION THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_EXCEPTION_LOCATION');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
    			WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_EXCEPTION_LOCATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    			WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_EXCEPTION_LOCATION');
		END IF;
--

        WHEN WSH_XC_INVALID_LOCATION THEN
		IF C1%ISOPEN THEN
			CLOSE C1;
		END IF;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_LOCATION');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_LOCATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_LOCATION');
		END IF;
--

        WHEN WSH_INVALID_DELIVERY_DETAIL THEN
		IF C2%ISOPEN THEN
			CLOSE C2;
		END IF;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PUB_INVALID_PARAMETER');
                FND_MESSAGE.SET_TOKEN('PARAMETER', 'Delivery_Detail_Id');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_DELIVERY_DETAIL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_DELIVERY_DETAIL');
		END IF;
--

        WHEN WSH_INVALID_CONTAINER_NAME THEN
		IF C_del_detail%ISOPEN THEN
			CLOSE C_del_detail;
		END IF;
                FND_MESSAGE.SET_NAME('WSH', 'WSH_PUB_INVALID_PARAMETER');
                FND_MESSAGE.SET_TOKEN('PARAMETER', 'Container_Name');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_CONTAINER_NAME exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_CONTAINER_NAME');
		END IF;
--

        WHEN WSH_INVALID_INVENTORY_CONTROL THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_INVENTORY_CONTROL exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_INVENTORY_CONTROL');
		END IF;
--

        WHEN WSH_XC_INVALID_DATE THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_XC_INVALID_DATE');
                x_return_status := FND_API.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
			p_count  => x_msg_count,
			p_data   => x_msg_data,
			p_encoded => FND_API.G_FALSE
			);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_DATE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_DATE');
		END IF;
--

        WHEN OTHERS THEN
                wsh_util_core.default_handler('WSH_EXCEPTIONS_GRP.LOG_EXCEPTION');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
    	    		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count   =>      x_msg_count,
        		p_data    =>      x_msg_data,
			p_encoded => FND_API.G_FALSE
		);

--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
--

END Log_Exception;


------------------------------------------------------------------------------
-- Procedure:   Purge_Exception
--
-- Parameters:
--
-- Description: This procedure purges all exceptions which fall into the creiteria
--              entered by the user.
------------------------------------------------------------------------------

PROCEDURE Purge_Exception (
        -- Standard parameters
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_msg_count             OUT     NOCOPY    NUMBER,
        x_msg_data              OUT     NOCOPY    VARCHAR2,
        x_return_status         OUT     NOCOPY    VARCHAR2,

        -- Program specific parameters
        p_exception_rec  	 IN     WSH_EXCEPTIONS_PUB.XC_ACTION_REC_TYPE,
        p_action                 IN     VARCHAR2
        ) IS

        -- cursor to validate the exception name

        /*

        -- Performance bug 4891910 : 15039503 on 12/22/2005 by parkhj
        -- no need to use wsh_exception_definitions_v
        -- since only exception_name is accessed

        CURSOR c_exception_name IS
        SELECT exception_name
        FROM wsh_exception_definitions_v
        WHERE exception_name = p_exception_rec.exception_name;
        */

        CURSOR c_exception_name IS
        SELECT exception_name
          FROM wsh_exception_definitions_tl
         WHERE exception_name = p_exception_rec.exception_name
           AND language = userenv('LANG');

	l_exception_name        VARCHAR2(50);
        l_return_status         VARCHAR2(1);
        l_msg_data              VARCHAR2(200);
        l_msg_count             NUMBER := 0;
        l_no_of_records         NUMBER := 0;
        l_delivery_id           NUMBER        DEFAULT NULL;
        l_lookup_code           VARCHAR2(30)  DEFAULT NULL;
	l_logging_entity	VARCHAR2(30)  DEFAULT NULL;
	l_exception_type	VARCHAR2(30)  DEFAULT NULL;
	l_severity		VARCHAR2(30)  DEFAULT NULL;
        l_logged_at_location_id NUMBER        DEFAULT NULL;
        l_exception_location_id NUMBER        DEFAULT NULL;
        l_trip_id               NUMBER;

        -- Standard call to check for call compatibility
        l_api_version          CONSTANT        NUMBER  := 1.0;
        l_api_name             CONSTANT        VARCHAR2(30):= 'Purge_Exception';

        WSH_XC_INVALID_STATUS           EXCEPTION;
        WSH_XC_NOT_FOUND                EXCEPTION;
        WSH_XC_INVALID_LOCATION         EXCEPTION;
        WSH_XC_INVALID_DATE_RANGE       EXCEPTION;
        WSH_PURGE_NOT_ALLOWED           EXCEPTION;
        WSH_XC_INVALID_OPERATION        EXCEPTION;
        WSH_XC_LOOKUP_LOG               EXCEPTION;
        WSH_XC_LOOKUP_EXCEPTION         EXCEPTION;
        WSH_XC_LOOKUP_SEVERITY          EXCEPTION;
        WSH_INVALID_LOGGED_AT_LOCATION  EXCEPTION;
        WSH_INVALID_EXCEPTION_LOCATION  EXCEPTION;
        WSH_XC_INVALID_DELIVERY         EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_EXCEPTION';
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
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            wsh_debug_sv.push(l_module_name);
            --
            wsh_debug_sv.log(l_module_name,'p_api_version',p_api_version);
            wsh_debug_sv.log(l_module_name,'p_init_msg_list',p_init_msg_list);
            wsh_debug_sv.log(l_module_name,'p_validation_level',p_validation_level);
            wsh_debug_sv.log(l_module_name,'p_commit',p_commit);
            wsh_debug_sv.log(l_module_name,'p_action',p_action);
            wsh_debug_sv.log (l_module_name,'request_id', p_exception_rec.request_id);
	    wsh_debug_sv.log (l_module_name,'exception_id',
                                                            p_exception_rec.exception_id);
            wsh_debug_sv.log (l_module_name,'exception_name',
                                                            p_exception_rec.exception_name);
            wsh_debug_sv.log (l_module_name,'status', p_exception_rec.status);
            wsh_debug_sv.log (l_module_name,'logging_entity',
                                                            p_exception_rec.logging_entity);
            wsh_debug_sv.log (l_module_name,'logged_at_location_code',
                                                    p_exception_rec.logged_at_location_code);
            wsh_debug_sv.log (l_module_name,'exception_location_code',
                                                   p_exception_rec.exception_location_code);
            wsh_debug_sv.log (l_module_name,'severity', p_exception_rec.severity);
            wsh_debug_sv.log (l_module_name,'delivery_name', p_exception_rec.delivery_name);
            wsh_debug_sv.log (l_module_name,'data_older_no_of_days', p_exception_rec.data_older_no_of_days);
        END IF;

	IF NOT FND_API.compatible_api_call (
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check p_init_msg_list
        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        IF ( p_exception_rec.request_id IS NULL AND
                p_exception_rec.exception_name IS NULL AND
                p_exception_rec.logging_entity IS NULL AND
                p_exception_rec.logged_at_location_code IS NULL AND
                p_exception_rec.exception_location_code IS NULL AND
                p_exception_rec.exception_type IS NULL AND
                p_exception_rec.severity IS NULL AND
                p_exception_rec.status IS NULL AND
                p_exception_rec.arrival_date IS NULL AND
                p_exception_rec.arrival_date_to IS NULL AND
                p_exception_rec.departure_date IS NULL AND
                p_exception_rec.departure_date_to IS NULL AND
                p_exception_rec.creation_date IS NULL AND
                p_exception_rec.creation_date_to IS NULL AND
                p_exception_rec.delivery_name IS NULL AND
                NVL(p_exception_rec.data_older_no_of_days,0) = 0 ) THEN
                RAISE WSH_XC_INVALID_OPERATION;
        END IF;

        -- Validating status of the exception
        IF (p_exception_rec.status IS NOT NULL and p_exception_rec.status NOT IN
	('CLOSED','ERROR','IN_PROCESS','LOGGED','MANUAL','NO_ACTION_REQUIRED','NOT_HANDLED','OPEN')) THEN
                RAISE WSH_XC_INVALID_STATUS;
        END IF;

        -- Validating the status of the exception if the action is PURGE
        IF ( p_exception_rec.status IS NOT NULL AND
			p_exception_rec.status <> 'CLOSED')  THEN
                RAISE WSH_PURGE_NOT_ALLOWED;
        END IF;

        -- Validating the name of the exception
        IF ( p_exception_rec.exception_name IS NOT NULL ) THEN
                OPEN c_exception_name;
                FETCH c_exception_name into l_exception_name;
                IF c_exception_name%NOTFOUND THEN
                        RAISE WSH_XC_NOT_FOUND;
                END IF;
                CLOSE c_exception_name;
        END IF;

        -- Validating logging_entity
        IF p_exception_rec.logging_entity IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOOKUP to Validate the loggint entity',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Lookup('LOGGING_ENTITY',l_logging_entity,
                                                p_exception_rec.logging_entity,l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	    IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        	x_return_status := l_return_status;
            ELSE
                RAISE WSH_XC_LOOKUP_LOG;
            END IF;
        END IF;
        END IF;

        -- Validating type of the exception
        IF p_exception_rec.exception_type IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOOKUPto Validate the Exception Type',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Lookup('EXCEPTION_TYPE',l_exception_type,
                                                p_exception_rec.exception_type,l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_XC_LOOKUP_EXCEPTION;
            END IF;
        END IF;
        END IF;

        -- Validating severity of the exception
        IF p_exception_rec.severity IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOOKUPto Validate the Severity',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Lookup('EXCEPTION_BEHAVIOR',l_severity,
                                                        p_exception_rec.severity,l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_XC_LOOKUP_SEVERITY;
            END IF;
        END IF;
        END IF;

        -- Validating logged_at_location of the exception
        IF p_exception_rec.logged_at_location_code IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION to Validate the Logged at Location',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Location(l_logged_at_location_id,
                                        p_exception_rec.logged_at_location_code,l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_INVALID_LOGGED_AT_LOCATION;
            END IF;
        END IF;
        END IF;

        -- Validating the location where exception has happened
        IF p_exception_rec.exception_location_code IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_LOCATION to Validate Exception Location',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Location(l_exception_location_id,
                                        p_exception_rec.exception_location_code,l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_INVALID_EXCEPTION_LOCATION;
            END IF;
        END IF;
        END IF;

        -- Validating the delivery name
        IF p_exception_rec.delivery_name IS NOT NULL THEN
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_VALIDATE.VALIDATE_DELIVERY_NAME',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_UTIL_VALIDATE.Validate_Delivery_Name(l_delivery_id,
					p_exception_rec.delivery_name,l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                x_return_status := l_return_status;
            ELSE
                RAISE WSH_XC_INVALID_DELIVERY;
            END IF;
        END IF;
        END IF;

        -- Validating if to_date is greater than from_date
        IF (p_exception_rec.departure_date > p_exception_rec.departure_date_to OR
                p_exception_rec.arrival_date > p_exception_rec.arrival_date_to OR
                p_exception_rec.creation_date > p_exception_rec.creation_date_to)  THEN
                RAISE WSH_XC_INVALID_DATE_RANGE;
        END IF;

	-- Call the Private API to Purge the Exceptions
                --
                -- Debug Statements
                --
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.PURGE',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                --
                WSH_XC_UTIL.Purge(
                     p_api_version      => p_api_version,
                     p_init_msg_list    => FND_API.G_FALSE,
                     p_commit           => FND_API.G_FALSE,
                     p_validation_level => p_validation_level,
                     x_return_status    => l_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => x_msg_data,
                     p_request_id       => p_exception_rec.request_id,
                     p_exception_name   => p_exception_rec.exception_name,
                     p_logging_entity   => l_logging_entity,
                     p_logged_at_location_id => l_logged_at_location_id,
                     p_exception_location_id => l_exception_location_id,
     --              p_inventory_org_id      => inventory_org_id,
                     p_exception_type        => l_exception_type,
                     p_severity              => l_severity,
                     p_status                => p_exception_rec.status,
                     p_arrival_date_from     => p_exception_rec.arrival_date,
                     p_arrival_date_to       => p_exception_rec.arrival_date_to,
                     p_departure_date_from   => p_exception_rec.departure_date,
                     p_departure_date_to     => p_exception_rec.departure_date_to,
                     p_creation_date_from    => p_exception_rec.creation_date,
                     p_creation_date_to      => p_exception_rec.creation_date_to,
                     p_data_older_no_of_days => p_exception_rec.data_older_no_of_days,
                     x_no_of_recs_purged     => l_no_of_records,
                     p_delivery_id           => l_delivery_id,
                     p_action                => p_action
                     );

               IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS,WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                   FND_MESSAGE.SET_NAME('WSH','WSH_NO_OF_RECS_PURGED');
                   FND_MESSAGE.SET_TOKEN('NO_OF_RECS',l_no_of_records);
                   wsh_util_core.add_message(l_return_status);
               END IF;

	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               	   x_return_status := l_return_status;
	       END IF;

               FND_MSG_PUB.Count_And_Get(
                                p_count  => x_msg_count,
                                p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
                                );
--
-- Debug Statements
--
	       IF l_debug_on THEN
		       WSH_DEBUG_SV.pop(l_module_name);
	       END IF;
--

EXCEPTION
        WHEN WSH_XC_NOT_FOUND THEN
		IF c_exception_name%ISOPEN THEN
			CLOSE c_exception_name;
		END IF;
                FND_MESSAGE.SET_NAME('WSH','WSH_XC_DEF_NOT_FOUND');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_NOT_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_NOT_FOUND');
		END IF;
--

        WHEN WSH_XC_INVALID_STATUS THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_XC_INVALID_STATUS');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_STATUS exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_STATUS');
		END IF;
--

        WHEN WSH_PURGE_NOT_ALLOWED THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_PURGE_NOT_ALLOWED');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_PURGE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_PURGE_NOT_ALLOWED');
		END IF;
--

        WHEN WSH_XC_INVALID_DATE_RANGE THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_XC_INVALID_DATE_RANGE');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_DATE_RANGE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_DATE_RANGE');
		END IF;
--

        WHEN WSH_XC_INVALID_OPERATION THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_XC_INVALID_OPERATION');
                FND_MESSAGE.SET_TOKEN('REASON','Trying to Purge All Records',TRUE);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_OPERATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_OPERATION');
		END IF;
--

        WHEN WSH_XC_LOOKUP_LOG THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOOKUP_TYPE');
                FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE','LOGGING_ENTITY');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_LOOKUP_LOG exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_LOOKUP_LOG');
		END IF;
--

        WHEN WSH_XC_LOOKUP_EXCEPTION THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOOKUP_TYPE');
                FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE','EXCEPTION_TYPE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_LOOKUP_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_LOOKUP_EXCEPTION');
		END IF;
--

        WHEN WSH_XC_LOOKUP_SEVERITY THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOOKUP_TYPE');
                FND_MESSAGE.SET_TOKEN('LOOKUP_TYPE','EXCEPTION_SEVERITY');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_LOOKUP_SEVERITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_LOOKUP_SEVERITY');
		END IF;
--

        WHEN WSH_INVALID_LOGGED_AT_LOCATION THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_LOGGED_AT_LOCATION');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_LOGGED_AT_LOCATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_LOGGED_AT_LOCATION');
		END IF;
--

        WHEN WSH_INVALID_EXCEPTION_LOCATION THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_EXCEPTION_LOCATION');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_EXCEPTION_LOCATION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_EXCEPTION_LOCATION');
		END IF;
--

        WHEN WSH_XC_INVALID_DELIVERY THEN
                FND_MESSAGE.SET_NAME('WSH', 'WSH_OI_INVALID_DEL_NAME');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count  => x_msg_count,
				p_data   => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_XC_INVALID_DELIVERY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_XC_INVALID_DELIVERY');
		END IF;
--

        WHEN OTHERS THEN
                WSH_UTIL_CORE.default_handler('WSH_EXCEPTIONS_GRP.EXCEPTION_ACTION');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data,
			p_encoded => FND_API.G_FALSE
                );
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
--

END Purge_Exception;


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
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        p_validation_level      IN      NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
        p_commit                IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
        x_msg_count             OUT     NOCOPY  NUMBER,
        x_msg_data              OUT     NOCOPY  VARCHAR2,
        x_return_status         OUT     NOCOPY  VARCHAR2,

        -- Program specific parameters
        p_exception_rec         IN OUT  NOCOPY WSH_EXCEPTIONS_PUB.XC_ACTION_REC_TYPE,
        p_action                IN      VARCHAR2
        ) IS

	l_action		VARCHAR2(20);
	l_updated_rows		NUMBER;
        l_return_status         VARCHAR2(1);

        -- Standard call to check for call compatibility
        l_api_version          CONSTANT        NUMBER  := 1.0;
        l_api_name             CONSTANT        VARCHAR2(30):= 'Exception_Action';

	WSH_INVALID_ACTION_CODE         EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'EXCEPTION_ACTION';
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
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
            WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
            WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
            WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
            WSH_DEBUG_SV.log(l_module_name,'P_ACTION',P_ACTION);
        END IF;

	IF NOT FND_API.compatible_api_call(
                          l_api_version,
                          p_api_version,
                          l_api_name,
                          G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Check p_init_msg_list
        IF FND_API.to_boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_action := UPPER(p_action);
        IF (l_action NOT IN ( 'CHANGE_STATUS','PURGE','LOG' )) THEN
                RAISE WSH_INVALID_ACTION_CODE;
        END IF;

        -- Call the private API if the action requested is PURGE
        IF  l_action = 'PURGE' THEN
                Purge_Exception(
                   p_api_version      =>  p_api_version,
                   p_init_msg_list    =>  FND_API.G_FALSE,
                   p_validation_level =>  p_validation_level,
                   p_commit           =>  FND_API.G_FALSE,
                   x_msg_count        =>  x_msg_count,
                   x_msg_data         =>  x_msg_data,
                   x_return_status    =>  l_return_status,

		   -- program specific parameters
                   p_exception_rec    =>  p_exception_rec,
                   p_action           =>  l_action
                   );

        END IF;

	-- Call the private API if the action requested is LOG
        IF l_action = 'LOG' THEN
                Log_Exception(
                   p_api_version      =>  p_api_version,
                   p_init_msg_list    =>  FND_API.G_FALSE,
                   p_validation_level =>  p_validation_level,
                   p_commit           =>  FND_API.G_FALSE,
                   x_msg_count        =>  x_msg_count,
                   x_msg_data         =>  x_msg_data,
                   x_return_status    =>  l_return_status,

		   -- program specific parameters
                   p_exception_rec    =>  p_exception_rec
                   );
        END IF;

        -- Call the private API if the action requested is CHANGE_STATUS
        IF l_action = 'CHANGE_STATUS' THEN
                Change_Status(
                   p_api_version      =>  p_api_version,
                   p_init_msg_list    =>  FND_API.G_FALSE,
                   p_validation_level =>  p_validation_level,
                   p_commit           =>  FND_API.G_FALSE,
                   x_msg_count        =>  x_msg_count,
                   x_msg_data         =>  x_msg_data,
                   x_return_status    =>  l_return_status,

                   -- program specific parameters
                   p_logging_entity_id     =>   p_exception_rec.logging_entity_id,
                   p_logging_entity_name   =>   p_exception_rec.logging_entity,
                   p_exception_name        =>   p_exception_rec.exception_name,
                   p_exception_id          =>   p_exception_rec.exception_id,
                   p_new_status            =>   p_exception_rec.new_status,
                   x_updated_rows          =>   l_updated_rows
                   );
        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_NO_OF_RECS_UPDATED');
                FND_MESSAGE.SET_TOKEN('NO_OF_RECS',l_updated_rows);
        END IF;
	END IF;

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        	x_return_status := l_return_status;
	END IF;

	IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)) AND
			FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

        FND_MSG_PUB.Count_And_Get(
                    p_count  => x_msg_count,
                    p_data   => x_msg_data,
		    p_encoded => FND_API.G_FALSE
		    );
--
-- Debug Statements
--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;
--

EXCEPTION
        WHEN WSH_INVALID_ACTION_CODE THEN
                FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_ACTION_CODE');
                FND_MESSAGE.SET_TOKEN('ACT_CODE',p_action);
                x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
		FND_MSG_PUB.Count_And_Get(
				p_count => x_msg_count,
			        p_data  => x_msg_data,
				p_encoded => FND_API.G_FALSE
				);
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INVALID_ACTION_CODE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_ACTION_CODE');
		END IF;
--

        WHEN OTHERS THEN
                WSH_UTIL_CORE.default_handler('WSH_EXCEPTIONS_GRP.EXCEPTION_ACTION');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                IF      FND_MSG_PUB.Check_Msg_Level
                        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
                END IF;
                FND_MSG_PUB.Count_And_Get
                (       p_count   =>      x_msg_count,
                        p_data    =>      x_msg_data,
			p_encoded => FND_API.G_FALSE
                );
--
-- Debug Statements
--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		END IF;
--

END Exception_Action;


END WSH_EXCEPTIONS_GRP;

/
