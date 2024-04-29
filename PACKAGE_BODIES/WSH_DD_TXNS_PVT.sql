--------------------------------------------------------
--  DDL for Package Body WSH_DD_TXNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DD_TXNS_PVT" as
/* $Header: WSHDXTHB.pls 120.2 2006/06/07 08:19:06 alksharm noship $ */
--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_DD_TXN_PVT';
--
    --
    --  Procedure:   Insert_DD_Txn
    --  Parameters:  All Attributes of a Delivery Detail Transaction Record,
    --			 Row_id out
    --			 DD_Txn_id out
    --			 Return_Status out
    --  Description: This procedure will create a delivery detail transaction.
    --               It will return to the user the dd_txn_id as a
    --               parameter.

PROCEDURE Insert_DD_Txn(
	p_dd_txn_info	IN DD_Txn_Rec_Type,
	x_rowid		OUT NOCOPY  VARCHAR2,
	x_dd_txn_id     OUT NOCOPY  NUMBER,
	x_return_status	OUT NOCOPY  VARCHAR2
	) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_DD_TXN';
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
        WSH_DEBUG_SV.push(l_module_name);  -- bug 4992250
     END IF;
     --

     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

     INSERT INTO wsh_dd_txns
        (DD_TXN_ID,
         DD_TXN_DATE,
         DELIVERY_DETAIL_ID,
         RELEASED_STATUS,
         REQUESTED_QUANTITY,
         REQUESTED_QUANTITY_UOM,
         REQUESTED_QUANTITY2,
         REQUESTED_QUANTITY_UOM2,
         PICKED_QUANTITY,
         PICKED_QUANTITY2,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN)
     VALUES
        (wsh_dd_txns_s.nextval,  -- bug 5257141
         SYSDATE,
         p_dd_txn_info.DELIVERY_DETAIL_ID,
         p_dd_txn_info.RELEASED_STATUS,
         p_dd_txn_info.REQUESTED_QUANTITY,
         p_dd_txn_info.REQUESTED_QUANTITY_UOM,
         p_dd_txn_info.REQUESTED_QUANTITY2,
         p_dd_txn_info.REQUESTED_QUANTITY_UOM2,
         p_dd_txn_info.PICKED_QUANTITY,
         p_dd_txn_info.PICKED_QUANTITY2,
         p_dd_txn_info.ATTRIBUTE_CATEGORY,
         p_dd_txn_info.ATTRIBUTE1,
         p_dd_txn_info.ATTRIBUTE2,
         p_dd_txn_info.ATTRIBUTE3,
         p_dd_txn_info.ATTRIBUTE4,
         p_dd_txn_info.ATTRIBUTE5,
         p_dd_txn_info.ATTRIBUTE6,
         p_dd_txn_info.ATTRIBUTE7,
         p_dd_txn_info.ATTRIBUTE8,
         p_dd_txn_info.ATTRIBUTE9,
         p_dd_txn_info.ATTRIBUTE10,
         p_dd_txn_info.ATTRIBUTE11,
         p_dd_txn_info.ATTRIBUTE12,
         p_dd_txn_info.ATTRIBUTE13,
         p_dd_txn_info.ATTRIBUTE14,
         p_dd_txn_info.ATTRIBUTE15,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID);

      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'x_dd_txn_id',x_dd_txn_id);
        WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --

EXCEPTION

      WHEN others THEN
        wsh_util_core.default_handler('WSH_DD_TXNS_PVT.INSERT_DD_TXN',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END Insert_DD_Txn;


--  Procedure:   Get_DD_Snapshot
--  Parameters:  x_dd_txn_info: A record of all attributes of a DD Txn Record
--               p_delivery_detail_id : Delivery detail id for which the record to be populated.
--  Description: This procedure will copy the attributes of a delivery detail in wsh_delivery_details
--               and copy it to a dd transaction record.

PROCEDURE Get_DD_Snapshot (p_delivery_detail_id IN NUMBER,
                           x_dd_txn_info OUT NOCOPY DD_Txn_Rec_Type,
                           x_return_status OUT NOCOPY VARCHAR2) IS

  CURSOR c_dd_rec (p_delivery_detail_id NUMBER) IS
  SELECT DELIVERY_DETAIL_ID,
         RELEASED_STATUS,
         REQUESTED_QUANTITY,
         REQUESTED_QUANTITY_UOM,
         REQUESTED_QUANTITY2,
         REQUESTED_QUANTITY_UOM2,
         PICKED_QUANTITY,
         PICKED_QUANTITY2
  FROM
  wsh_delivery_details
  WHERE delivery_detail_id = p_delivery_detail_id;



  ln_rec_info c_dd_rec%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DD_SNAPSHOT';
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
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id',p_delivery_detail_id);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  OPEN c_dd_rec(p_delivery_detail_id);
  FETCH c_dd_rec INTO ln_rec_info;
  x_dd_txn_info.DELIVERY_DETAIL_ID        := ln_rec_info.DELIVERY_DETAIL_ID;
  x_dd_txn_info.RELEASED_STATUS           := ln_rec_info.RELEASED_STATUS;
 x_dd_txn_info.REQUESTED_QUANTITY        := ln_rec_info.REQUESTED_QUANTITY;
  x_dd_txn_info.REQUESTED_QUANTITY_UOM    := ln_rec_info.REQUESTED_QUANTITY_UOM;
  x_dd_txn_info.REQUESTED_QUANTITY2       := ln_rec_info.REQUESTED_QUANTITY2;
  x_dd_txn_info.REQUESTED_QUANTITY_UOM2   := ln_rec_info.REQUESTED_QUANTITY_UOM2;
  x_dd_txn_info.PICKED_QUANTITY           := ln_rec_info.PICKED_QUANTITY;
  x_dd_txn_info.PICKED_QUANTITY2          := ln_rec_info.PICKED_QUANTITY2;
  CLOSE c_dd_rec;

  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);  -- bug 4992250
  END IF;


EXCEPTION
      WHEN others THEN
        wsh_util_core.default_handler('WSH_DD_TXNS_PVT.Get_DD_Snapshot',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --
END Get_DD_Snapshot;


PROCEDURE create_dd_txn_from_dd  (p_delivery_detail_id IN NUMBER,
                                  x_dd_txn_id OUT NOCOPY NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2) IS

  l_delivery_detail_id NUMBER;
  l_dd_txn_id NUMBER := NULL;
  l_dd_txn_info DD_Txn_Rec_Type;
  l_return_status VARCHAR2(1);
  l_rowid VARCHAR2(50);
  others EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_DD_TXN_FROM_DD';
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
        WSH_DEBUG_SV.log(l_module_name,'p_delivery_detail_id',p_delivery_detail_id);
     END IF;
     --
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     --
     -- Check if DBI is installed, possible values are Y or N only
     -- If not installed, then do not proceed , return Success
     IF (WSH_INTEGRATION.DBI_Installed = 'N')
     THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'DBI Installed flag-',WSH_INTEGRATION.DBI_Installed);
         WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       RETURN;
     END IF;
     --

  l_delivery_detail_id := p_delivery_detail_id;

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Get_DD_Snapshot');
     END IF;
     --
  Get_DD_Snapshot (p_delivery_detail_id => l_delivery_detail_id,
                           x_dd_txn_info => l_dd_txn_info,
                           x_return_status => l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' Error in Get_DD_Snapshot');
        WSH_DEBUG_SV.pop(l_module_name);  -- bug 4992250
     END IF;
     RETURN;
   END IF;

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'Calling Insert_DD_Txn');
     END IF;
     --

  Insert_DD_Txn(p_dd_txn_info => l_dd_txn_info,
	x_rowid => l_rowid,
	x_dd_txn_id =>l_dd_txn_id,
	x_return_status => l_return_status);

   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
     x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,' Error in Insert_DD_Txn');
       WSH_DEBUG_SV.pop(l_module_name);  -- bug 4992250
     END IF;
     RETURN;
   END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);  -- bug 4992250
  END IF;

EXCEPTION

      WHEN others THEN
        wsh_util_core.default_handler('WSH_DD_TXNS_PVT.create_dd_txn_from_dd',l_module_name);
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        --
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
        --

END create_dd_txn_from_dd;

END WSH_DD_TXNS_PVT;

/
