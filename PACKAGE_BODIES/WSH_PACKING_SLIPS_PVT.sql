--------------------------------------------------------
--  DDL for Package Body WSH_PACKING_SLIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PACKING_SLIPS_PVT" AS
-- $Header: WSHPSTHB.pls 120.0 2005/05/26 17:59:02 appldev noship $

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PACKING_SLIPS_PVT';
--
PROCEDURE update_Row
  ( p_api_version                 IN  NUMBER
    , p_init_msg_list             IN  VARCHAR2
    , p_commit                    IN  VARCHAR2
    , p_validation_level          IN  NUMBER
    , x_return_status             OUT NOCOPY  VARCHAR2
    , x_msg_count                 OUT NOCOPY  NUMBER
    , x_msg_data                  OUT NOCOPY  VARCHAR2
    , p_entity_name               IN  VARCHAR2
    , p_entity_id                 IN  NUMBER
    , p_document_type             IN  VARCHAR2
    , p_reason_of_transport       IN  VARCHAR2
    , p_description               IN  VARCHAR2
    , p_document_number           IN  VARCHAR2
  )
  IS
     l_ledger_id VARCHAR2(30); -- LE Uptake

     wsh_update_document_error EXCEPTION;
/* Bug 2276586 */
l_delivery_id NUMBER;
delivery_id_locked exception  ;
PRAGMA EXCEPTION_INIT(delivery_id_locked, -54);


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
--
BEGIN
   -- l_ledger_id := 1;

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
       WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
       WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
       WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
       WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_REASON_OF_TRANSPORT',P_REASON_OF_TRANSPORT);
       WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION',P_DESCRIPTION);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_NUMBER',P_DOCUMENT_NUMBER);
   END IF;
   -- LE Uptake
   SELECT hoi.org_information1
     INTO l_ledger_id
     FROM hr_organization_information hoi,
          wsh_new_deliveries wnd
    WHERE wnd.delivery_id = p_entity_id
      AND hoi.organization_id = wnd.organization_id
      AND hoi.org_information_context = 'Accounting Information';

-- Bug 2276586
   SELECT delivery_id
     INTO l_delivery_id
     FROM wsh_new_deliveries
    WHERE delivery_id = p_entity_id
      FOR UPDATE NOWAIT;

/* Changes for Shipping Data Model Bug#1918342*/

Update WSH_NEW_DELIVERIES
SET
reason_of_transport = p_reason_of_transport,
description = p_description,
last_updated_by = fnd_global.user_id,
last_update_date = sysdate,
last_update_login = fnd_global.login_id
WHERE delivery_id = p_entity_id;

   -- update document
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PVT.UPDATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_document_pvt.update_document
     ( p_api_version
       , p_init_msg_list
       , p_commit
       , p_validation_level
       , x_return_status
       , x_msg_count
       , x_msg_data
       , p_entity_name
       , p_entity_id
       , p_document_type
/* Commented for changes in the shipping datamodel bug#1918342
       , NULL
       , NULL
       , NULL
       , p_reason_of_transport
       , p_description
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
       , NULL
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL
     , NULL        */
     , l_ledger_id         -- LE Uptake
     , 'BOTH'
     );

   IF x_return_status <> 'S' THEN
      RAISE wsh_update_document_error;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN wsh_update_document_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --FND_MESSAGE.SET_NAME('WSH', 'WSH_BOL_UPDATE_DOCUMENT_ERROR');
      --WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UPDATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UPDATE_DOCUMENT_ERROR');
END IF;
--
   WHEN delivery_id_locked THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_LOCK');
     WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_ID_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIVERY_ID_LOCKED');
END IF;
--
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
      --WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
END Update_Row;


PROCEDURE insert_row
  (x_return_status             IN OUT NOCOPY  VARCHAR2,
   x_msg_count                 IN OUT NOCOPY  VARCHAR2,
   x_msg_data                  IN OUT NOCOPY  VARCHAR2,
   p_entity_name               IN     VARCHAR2,
   p_entity_id                 IN     NUMBER,
   p_application_id            IN     NUMBER,
   p_location_id               IN     NUMBER,
   p_document_type             IN     VARCHAR2,
   p_document_sub_type         IN     VARCHAR2,
   p_reason_of_transport       IN     VARCHAR2,
   p_description               IN     VARCHAR2,
   x_document_number           IN OUT NOCOPY  VARCHAR2
  )
  IS
     x_rowid     varchar2(30);
     l_trip_info wsh_trips_pvt.trip_rec_type;
     l_del_rows  wsh_util_core.id_tab_type;
     l_ledger_id VARCHAR2(30); -- LE Uptake

     wsh_create_document_error EXCEPTION;

/* Bug 2276586 */
l_delivery_id NUMBER;
delivery_id_locked exception  ;
PRAGMA EXCEPTION_INIT(delivery_id_locked, -54);

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
       --
       WSH_DEBUG_SV.log(l_module_name,'X_RETURN_STATUS',X_RETURN_STATUS);
       WSH_DEBUG_SV.log(l_module_name,'X_MSG_COUNT',X_MSG_COUNT);
       WSH_DEBUG_SV.log(l_module_name,'X_MSG_DATA',X_MSG_DATA);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
       WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_APPLICATION_ID',P_APPLICATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_SUB_TYPE',P_DOCUMENT_SUB_TYPE);
       WSH_DEBUG_SV.log(l_module_name,'P_REASON_OF_TRANSPORT',P_REASON_OF_TRANSPORT);
       WSH_DEBUG_SV.log(l_module_name,'P_DESCRIPTION',P_DESCRIPTION);
       WSH_DEBUG_SV.log(l_module_name,'X_DOCUMENT_NUMBER',X_DOCUMENT_NUMBER);
   END IF;
   --
   -- LE Uptake
   --l_ledger_id := 1;

   SELECT hoi.org_information1
     INTO l_ledger_id
     FROM hr_organization_information hoi,
          wsh_new_deliveries wnd
    WHERE wnd.delivery_id = p_entity_id
      AND hoi.organization_id = wnd.organization_id
      AND hoi.org_information_context = 'Accounting Information';

-- Bug 2276586
   SELECT delivery_id
     INTO l_delivery_id
     FROM wsh_new_deliveries
    WHERE delivery_id = p_entity_id
      FOR UPDATE NOWAIT;

/* Changes for Shipping DataModel Bug#1918342 */

Update WSH_NEW_DELIVERIES
SET
reason_of_transport = p_reason_of_transport,
description = p_description,
last_updated_by = fnd_global.user_id,
last_update_date = sysdate,
last_update_login = fnd_global.login_id
WHERE delivery_id = p_entity_id;


  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PVT.CREATE_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  wsh_document_pvt.create_document (
    1.0,
    'T',
    NULL,
    NULL,
    x_return_status,
    x_msg_count,
    x_msg_data,
    p_entity_name,
    p_entity_id,
    p_application_id,
    p_location_id,
    p_document_type,
    p_document_sub_type,
/* Commented for changes in the Shipping Data Model Bug#1918342
    null,
    null,
    null,
    p_reason_of_transport,
    p_description,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    null,*/
    l_ledger_id,    -- LE Uptake
    'BOTH',
    200,
    x_document_number );

   IF x_return_status <> 'S' THEN
      RAISE wsh_create_document_error;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN wsh_create_document_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
--      FND_MESSAGE.SET_NAME('WSH', 'WSH_BOL_CREATE_DOCUMENT_ERROR');
--      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CREATE_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CREATE_DOCUMENT_ERROR');
END IF;
--
   WHEN delivery_id_locked THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_LOCK');
     WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'DELIVERY_ID_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DELIVERY_ID_LOCKED');
   END IF;
   --
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--      FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
--      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
   END IF;
   --
END Insert_Row;


PROCEDURE delete_row
  ( p_api_version                 IN  NUMBER
    , p_init_msg_list             IN  VARCHAR2
    , p_commit                    IN  VARCHAR2
    , p_validation_level          IN  NUMBER
    , x_return_status             OUT NOCOPY  VARCHAR2
    , x_msg_count                 OUT NOCOPY  NUMBER
    , x_msg_data                  OUT NOCOPY  VARCHAR2
    , p_entity_id                 IN  NUMBER
    , p_document_type             IN  VARCHAR2
    , p_document_number           IN  VARCHAR2
    )
  IS
     l_rowid VARCHAR2(30);

     wsh_cancel_document_error EXCEPTION;
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
          WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION',P_API_VERSION);
          WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
          WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
          WSH_DEBUG_SV.log(l_module_name,'P_VALIDATION_LEVEL',P_VALIDATION_LEVEL);
          WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_TYPE',P_DOCUMENT_TYPE);
          WSH_DEBUG_SV.log(l_module_name,'P_DOCUMENT_NUMBER',P_DOCUMENT_NUMBER);
      END IF;
      --
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DOCUMENT_PVT.CANCEL_DOCUMENT',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
      --
      wsh_document_pvt.cancel_document
	(P_API_VERSION
	 , P_INIT_MSG_LIST
	 , P_COMMIT
	 , P_VALIDATION_LEVEL
	 , X_RETURN_STATUS
	 , X_MSG_COUNT
	 , X_MSG_DATA
	 , NULL
	 , p_ENTITY_ID
	 , P_DOCUMENT_TYPE
	 , 'BOTH'
	 );

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
   WHEN wsh_cancel_document_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --FND_MESSAGE.SET_NAME('WSH', 'WSH_BOL_CANCEL_DOCUMENT_ERROR');
      --WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_CANCEL_DOCUMENT_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_CANCEL_DOCUMENT_ERROR');
      END IF;
      --
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --FND_MESSAGE.SET_NAME('WSH','WSH_UNEXP_ERROR');
      --WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END delete_row;
--  Procedure:    Get_Disabled_List
--
--  Parameters:   p_delivery_id -- delivery the detail is assigned to
--                p_list_type --
--							'FORM', will return list of form field names
--                   'TABLE', will return list of table column names
--                x_return_status  -- return status for execution of this API
-- 					x_disabled_list -- list of disabled field names
--                x_msg_count -- number of error message
--                x_msg_data  -- error message if API failed
--
PROCEDURE Get_Disabled_List(
  p_delivery_id               IN    NUMBER
, p_list_type                 IN    VARCHAR2
, x_return_status             OUT NOCOPY    VARCHAR2
, x_disabled_list             OUT NOCOPY    WSH_UTIL_CORE.column_tab_type
, x_msg_count                 OUT NOCOPY    NUMBER
, x_msg_data                  OUT NOCOPY    VARCHAR2
)
IS
CURSOR get_delivery_status
IS
SELECT status_code
FROM wsh_new_deliveries
WHERE delivery_id = p_delivery_id;

i								NUMBER :=0;
wsh_dp_no_entity			EXCEPTION;
wsh_inv_list_type			EXCEPTION;
l_msg_summary           VARCHAR2(2000) := NULL;
l_msg_details           VARCHAR2(4000) := NULL;
l_status_code				VARCHAR2(2);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';
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
	    WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_ID',P_DELIVERY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_LIST_TYPE',P_LIST_TYPE);
	END IF;
	--
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	-- clear the disabled list first
	x_disabled_list.delete;

	IF (p_delivery_id IS NOT NULL) THEN
		OPEN get_delivery_status;
		FETCH get_delivery_status INTO l_status_code;
		IF (get_delivery_status%NOTFOUND) THEN
			CLOSE get_delivery_status;
			RAISE wsh_dp_no_entity;
		END IF;
		CLOSE get_delivery_status;

		IF (l_status_code IN ('CO', 'IT', 'CL', 'SR', 'SC')) THEN  -- sperera 940/945
			i:=i+1; x_disabled_list(i) := 'REASON_OF_TRANSPORT';
			i:=i+1; x_disabled_list(i) := 'DESCRIPTION';
		END IF;

	END IF;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
	EXCEPTION
		WHEN wsh_dp_no_entity THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_ENTITY');
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
			WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
			IF x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			ELSE
				x_msg_data := l_msg_summary;
			END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
END IF;
--
		WHEN wsh_inv_list_type THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('WSH', 'WSH_INV_LIST_TYPE');
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
			WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
			IF x_msg_count > 1 then
				x_msg_data := l_msg_summary || l_msg_details;
			ELSE
				x_msg_data := l_msg_summary;
			END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INV_LIST_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_LIST_TYPE');
END IF;
--
     	WHEN others THEN
			IF (get_delivery_status%ISOPEN) THEN
				CLOSE get_delivery_status;
			END IF;
			wsh_util_core.default_handler('WSH_DELIVERY_VALIDATIONS.get_disabled_list');
	   	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Disabled_List;

END WSH_PACKING_SLIPS_PVT;

/
