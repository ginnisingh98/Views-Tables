--------------------------------------------------------
--  DDL for Package Body WSH_USA_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_USA_CATEGORIES_PVT" as
/* $Header: WSHUSACB.pls 120.16.12010000.5 2010/02/09 14:00:48 skanduku ship $ */

  -- 2071048
  CURSOR c_cache_attributes_1(p_source_line_id     IN NUMBER,
                            p_delivery_detail_id IN NUMBER,
                            p_source_code        IN WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE) IS
  SELECT         source_line_id,
                 source_code,
                 organization_id,
                 inventory_item_id,  --bug#6407943
                 original_subinventory subinventory,
                 date_scheduled,
                 ship_set_id,
                 ship_to_site_use_id,
                 intmed_ship_to_location_id,
                 customer_id,
		 src_requested_quantity, --Bug#6077222
                 src_requested_quantity_uom, --Bug#6077222
                 freight_terms_code,
                 fob_code,
                 ship_method_code,
                 carrier_id,
                 requested_quantity,
                 requested_quantity_uom,
                 source_line_set_id, -- Bug 2181132
                 ship_tolerance_above,-- Bug 2181132
                 ship_tolerance_below,-- Bug 2181132
                 request_date_type_code,
                 container_flag,
                 earliest_pickup_date,
                 latest_pickup_date,
                 earliest_dropoff_date,
                 latest_dropoff_date,
                 mode_of_transport,
                 service_level,
                 decode(p_delivery_detail_id,
                        FND_API.G_MISS_NUM, FND_API.G_MISS_NUM,
                        delivery_detail_id) delivery_detail_id,
                 'Y' cache_flag,
                 project_id,
                 task_id
  FROM  wsh_delivery_details
  WHERE source_line_id = p_source_line_id
  AND   source_code = p_source_code
  AND   delivery_detail_id = DECODE(p_delivery_detail_id, FND_API.G_MISS_NUM,
                                    delivery_detail_id, p_delivery_detail_id)
  AND   released_status in ('R', 'N', 'X')
  AND rownum = 1
  ORDER BY decode (released_status,
                   'R', 1,
                   'N', 2,
                   'X', 3,
                    4);
  CURSOR c_cache_attributes_2(p_source_line_id     IN NUMBER,
                            p_delivery_detail_id IN NUMBER,
                            p_source_code        IN WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE) IS
  SELECT         source_line_id,
                 source_code,
                 organization_id,
                 inventory_item_id,  --bug#6407943
                 original_subinventory  subinventory,
                 date_scheduled,
                 ship_set_id,
                 ship_to_site_use_id,
                 intmed_ship_to_location_id,
                 customer_id,
		 src_requested_quantity, --Bug#6077222
                 src_requested_quantity_uom, --Bug#6077222
                 freight_terms_code,
                 fob_code,
                 ship_method_code,
                 carrier_id,
                 requested_quantity,
                 requested_quantity_uom,
                 source_line_set_id, -- Bug 2181132
                 ship_tolerance_above,-- Bug 2181132
                 ship_tolerance_below,-- Bug 2181132
                 request_date_type_code,
                 container_flag,
                 earliest_pickup_date,
                 latest_pickup_date,
                 earliest_dropoff_date,
                 latest_dropoff_date,
                 mode_of_transport,
                 service_level,
                 decode(p_delivery_detail_id,
                        FND_API.G_MISS_NUM, FND_API.G_MISS_NUM,
                        delivery_detail_id) delivery_detail_id,
                 'Y' cache_flag,
                 project_id,
                 task_id
  FROM  wsh_delivery_details
  WHERE source_line_id = p_source_line_id
  AND   source_code = p_source_code
  AND   delivery_detail_id = DECODE(p_delivery_detail_id, FND_API.G_MISS_NUM,
                                    delivery_detail_id, p_delivery_detail_id)
  AND   released_status in ('B', 'Y', 'S')
  AND rownum = 1
  ORDER BY decode (released_status,
                   'B', 1,
                   'Y', 2,
                   'S', 3,
                    4);
  -- 2071048


-- Global Variables

  g_param_info WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
  g_cache_detail_rec  c_cache_attributes_1%ROWTYPE;

  g_cache_wms_org_id      NUMBER;
  g_cache_wms_flag        VARCHAR2(1);

-- Private Procedures


--
--  Procedure:         Log_Exception
--  Parameters:
--               p_delivery_detail_id  delivery detail against which exception is logged.
--               p_location_id         ship from location where the exception is logged.
--               p_exception_name      name of exception
--               x_return_status       return status
--
--  Description:
--              This is a wrapper around wsh_xc_util.log_exception
--              to be called by the Change Attribute procedures that
--              require exceptions to be logged.

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_USA_CATEGORIES_PVT';
--
PROCEDURE Log_Exception(
            p_delivery_detail_id IN  NUMBER,
            p_location_id        IN  NUMBER,
            p_exception_name     IN  VARCHAR2,
            p_entity_name        IN  VARCHAR2 DEFAULT NULL,
            p_entity_id          IN  NUMBER   DEFAULT NULL,
            x_return_status    OUT NOCOPY  VARCHAR2) IS


l_exception_error_message               VARCHAR2(2000) := NULL;
l_exception_msg_count                   NUMBER;
l_dummy_exception_id                    NUMBER;
l_delivery_assignment_id                NUMBER;
l_exception_msg_data                    VARCHAR2(4000) := NULL;
l_msg                                   VARCHAR2(2000);
l_entity                                VARCHAR2(30);

--variables added for bug 2834274
l_name_of_delivery  VARCHAR2(100);
l_name_of_container VARCHAR2(100);
--

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
    IF l_debug_on THEN
        WSH_DEBUG_SV.push(l_module_name);
        --
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_ID',P_LOCATION_ID);
        WSH_DEBUG_SV.log(l_module_name,'P_EXCEPTION_NAME',P_EXCEPTION_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_NAME',P_ENTITY_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
    END IF;
    --
    IF p_entity_name IS NOT NULL THEN
       FND_MESSAGE.SET_NAME('WSH',p_entity_name);
       l_entity := FND_MESSAGE.GET;
    END IF;

    FND_MESSAGE.SET_NAME('WSH',p_exception_name);
    FND_MESSAGE.SET_TOKEN('DETAIL',p_delivery_detail_id);

    --Bug 2834274
    --{
    IF p_entity_name IS NOT NULL THEN
       FND_MESSAGE.SET_TOKEN('ENTITY_NAME',l_entity);
       IF p_entity_id IS NOT NULL THEN --{

          IF p_entity_name = 'WSH_DELIVERY'  THEN
	     l_name_of_delivery := WSH_NEW_DELIVERIES_PVT.Get_Name(p_entity_id);
	     IF l_name_of_delivery IS NOT NULL THEN
                FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_name_of_delivery);
             ELSE
                FND_MESSAGE.SET_TOKEN('ENTITY_ID',p_entity_id);
             END IF;
          ELSIF p_entity_name = 'WSH_CONTAINER'  THEN
             l_name_of_container := WSH_CONTAINER_UTILITIES.Get_Cont_Name(p_entity_id);
	     IF l_name_of_container IS NOT NULL THEN
                FND_MESSAGE.SET_TOKEN('ENTITY_ID',l_name_of_container);
             ELSE
                FND_MESSAGE.SET_TOKEN('ENTITY_ID',p_entity_id);
             END IF;
	  ELSE
             FND_MESSAGE.SET_TOKEN('ENTITY_ID',p_entity_id);
          END IF;

       END IF; --}
    END IF;
    --}

    l_msg := FND_MESSAGE.GET;
    wsh_xc_util.log_exception(
                     p_api_version             => 1.0,
                     x_return_status           => x_return_status,
                     x_msg_count               => l_exception_msg_count,
                     x_msg_data                => l_exception_msg_data,
                     x_exception_id            => l_dummy_exception_id ,
                     p_logged_at_location_id   => p_location_id,
                     p_exception_location_id   => p_location_id,
                     p_logging_entity          => 'SHIPPER',
                     p_logging_entity_id       => FND_GLOBAL.USER_ID,
                     p_exception_name          => p_exception_name,
                     p_message                 => l_msg,
                     p_delivery_detail_id      => p_delivery_detail_id,
                     p_error_message           => l_exception_error_message
                     );

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
   EXCEPTION

     WHEN OTHERS THEN
      -- close open cursors as needed
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Log_Exception',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Log_Exception;

PROCEDURE Cache_Changed_Attributes(p_source_line_id     IN NUMBER,
                                   p_source_code        IN VARCHAR2,
                                   p_delivery_detail_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                   x_return_status      OUT NOCOPY   VARCHAR2) IS


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CACHE_CHANGED_ATTRIBUTES';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
  END IF;
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF      g_cache_detail_rec.cache_flag         = 'Y'
     AND  g_cache_detail_rec.source_line_id     = p_source_line_id
     AND  g_cache_detail_rec.source_code        = p_source_code
     AND  g_cache_detail_rec.delivery_detail_id = p_delivery_detail_id
  THEN
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Nothing changed');
    END IF;
    --
    RETURN;
  END IF;

  OPEN c_cache_attributes_1(p_source_line_id, p_delivery_detail_id,  p_source_code);

  FETCH c_cache_attributes_1 INTO g_cache_detail_rec;

  IF c_cache_attributes_1%NOTFOUND THEN
    CLOSE c_cache_attributes_1;
    OPEN c_cache_attributes_2(p_source_line_id, p_delivery_detail_id,  p_source_code);
    FETCH c_cache_attributes_2 INTO g_cache_detail_rec;
    IF c_cache_attributes_2%NOTFOUND THEN
      CLOSE c_cache_attributes_2;
      FND_MESSAGE.SET_NAME('WSH', 'WSH_NO_DATA_FOUND');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'WSH_NO_DATA_FOUND');
      END IF;
      --
      RETURN;
    END IF;
    CLOSE c_cache_attributes_2;
  END IF;

  IF c_cache_attributes_1%ISOPEN THEN
    CLOSE c_cache_attributes_1;
  END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'CACHED ATTRIBUTES FOR '|| G_CACHE_DETAIL_REC.SOURCE_CODE || ' LINE: '|| G_CACHE_DETAIL_REC.SOURCE_LINE_ID || ' DD: '||G_CACHE_DETAIL_REC.DELIVERY_DETAIL_ID  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'ORG : '|| G_CACHE_DETAIL_REC.ORGANIZATION_ID ||' ORIG_SUB: '|| G_CACHE_DETAIL_REC.SUBINVENTORY|| ' DATE_SCHED: '|| G_CACHE_DETAIL_REC.DATE_SCHEDULED  );
          WSH_DEBUG_SV.logmsg(l_module_name, ' SHIP_SET: '|| G_CACHE_DETAIL_REC.SHIP_SET_ID || ' DEL GRP ATTR: ...'  );
          WSH_DEBUG_SV.logmsg(l_module_name,
    G_CACHE_DETAIL_REC.SHIP_TO_SITE_USE_ID
    ||' - '
    || G_CACHE_DETAIL_REC.INTMED_SHIP_TO_LOCATION_ID
    || ' - '
    || G_CACHE_DETAIL_REC.CUSTOMER_ID
    || ' - '
    || G_CACHE_DETAIL_REC.FREIGHT_TERMS_CODE
    || ' - '
    || G_CACHE_DETAIL_REC.FOB_CODE
    || ' - '
    || G_CACHE_DETAIL_REC.SHIP_METHOD_CODE
    || ' - '
    || G_CACHE_DETAIL_REC.CARRIER_ID  );
          WSH_DEBUG_SV.logmsg(l_module_name, 'REQUESTED_QUANTITY : '|| G_CACHE_DETAIL_REC.REQUESTED_QUANTITY|| ' '|| G_CACHE_DETAIL_REC.REQUESTED_QUANTITY_UOM  );
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

    WHEN OTHERS THEN
      IF c_cache_attributes_1%ISOPEN THEN
        CLOSE c_cache_attributes_1;
      END IF;
      IF c_cache_attributes_2%ISOPEN THEN
        CLOSE c_cache_attributes_2;
      END IF;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      wsh_util_core.default_handler('WSH_USA_CATEGORIES_PVT.Cache_Changed_Attributes',l_module_name);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Cache_Changed_Attributes;


--  Procedure:          Check_WMS
--  Parameters:
--               p_source_code         source code of record to check
--               p_oraganization_id    organization id to check
--                                     for WMS
--               x_wms_flag            flag to indicate if the delivery
--                                     lines are under WMS
--                                        'Y' - org is under WMS,
--                                        'N' - org is not under WMS
--               x_return_status       return status
--
--  Description:
--               Calls category APIs to check the attributes being updated.


PROCEDURE Check_WMS(
      p_organization_id IN       NUMBER,
      x_wms_flag       OUT NOCOPY        VARCHAR2,
      x_return_status  OUT NOCOPY        VARCHAR2) IS

  l_wms_installed  BOOLEAN;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(4000);
  others           EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_WMS';
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
      WSH_DEBUG_SV.log(l_module_name,'P_ORGANIZATION_ID',P_ORGANIZATION_ID);
      WSH_DEBUG_SV.log(l_module_name,'g_cache_wms_org_id',g_cache_wms_org_id);
  END IF;
  --
  l_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  x_wms_flag := 'N';

  IF g_cache_wms_org_id = p_organization_id THEN
    x_wms_flag := g_cache_wms_flag;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
    RETURN;
  END IF;


  g_cache_wms_org_id := p_organization_id;
  g_cache_wms_flag   := 'N';

    l_wms_installed := WMS_INSTALL.CHECK_INSTALL(
                            x_return_status   => l_return_status,
                            x_msg_count       => l_msg_count,
                            x_msg_data        => l_msg_data,
                            p_organization_id => p_organization_id);

    IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'UNEXPECTED ERROR IN CHECK_WMS'  );
      END IF;
      --
      raise others;
    END IF;

    IF l_wms_installed THEN
      x_wms_flag := 'Y';
      g_cache_wms_flag := 'Y';
    END IF;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_wms_installed',l_wms_installed);
        WSH_DEBUG_SV.log(l_module_name,'x_wms_flag',x_wms_flag);
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_USA_CATEGORIES_PVT.Check_WMS',l_module_name);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Check_WMS;

-- Public Procedures

PROCEDURE Check_Attributes(
  p_source_code       IN   VARCHAR2,
  p_attributes_rec    IN   WSH_INTERFACE.ChangedAttributeRecType,
  x_changed_detail    OUT NOCOPY WSH_USA_CATEGORIES_PVT.ChangedDetailRec,
  x_update_allowed    OUT NOCOPY   VARCHAR2,
  x_return_status     OUT NOCOPY   VARCHAR2)
IS
  update_not_allowed  EXCEPTION;
  others           EXCEPTION;

  l_rs              VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_update_allowed  VARCHAR2(1) := 'Y';
  l_wms_flag        VARCHAR2(1);
  -- HW OPM for OM changes
-- HW OPMCONV. Removed OPM variables

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_ATTRIBUTES';
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
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      END IF;
  -- calls to categories should be sequenced correctly to avoid conflicts:
  -- Each category validates the conditions and performs actions that can change conditions.

  -- always look up attributes because they may have changed in previous records for
  -- same source_line_id.
  Cache_Changed_Attributes(p_source_line_id     => p_attributes_rec.source_line_id,
                           p_source_code        => p_source_code,
                           p_delivery_detail_id => p_attributes_rec.delivery_detail_id,
                           x_return_status      => l_rs);
  IF (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Cache_Changed_Attributes returns Error');
    END IF;
    RAISE update_not_allowed;
  END IF;

-- HW OPM for OM changes
-- HW OPMCONV. Removed branching

-- HW end of OM changes
  Check_WMS(
      p_organization_id =>  g_cache_detail_rec.organization_id,
      x_wms_flag        => l_wms_flag,
      x_return_status   => l_rs);
  IF (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE others;
  END IF;

  WSH_USA_CATEGORIES_PVT.Change_Schedule(
           p_attributes_rec => p_attributes_rec,
           p_source_code    => p_source_code,
           p_wms_flag       => l_wms_flag,
           x_update_allowed => l_update_allowed,
           x_return_status  => l_rs);
  IF     (l_update_allowed = 'N')
     OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE update_not_allowed;
  END IF;
  WSH_USA_CATEGORIES_PVT.Change_Scheduled_Date(
           p_attributes_rec => p_attributes_rec,
           p_source_code    => p_source_code,
           p_wms_flag       => l_wms_flag,
           x_update_allowed => l_update_allowed,
           x_return_status  => l_rs);
  IF     (l_update_allowed = 'N')
     OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Change_Scheduled_Date returned Error');
    END IF;
    RAISE update_not_allowed;
  END IF;

-- HW OPM BUG#:2296620 09/27 Need to remove the branch since OPM is supporting shipsets

  WSH_USA_CATEGORIES_PVT.Change_Sets(
           p_attributes_rec => p_attributes_rec,
           p_source_code    => p_source_code,
           p_wms_flag       => l_wms_flag,
           x_update_allowed => l_update_allowed,
           x_return_status  => l_rs);
    IF     (l_update_allowed = 'N')
      OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
     RAISE update_not_allowed;
    END IF;

  WSH_USA_CATEGORIES_PVT.Change_Delivery_Group(
           p_attributes_rec => p_attributes_rec,
           p_source_code    => p_source_code,
           p_wms_flag       => l_wms_flag,
           x_update_allowed => l_update_allowed,
           x_return_status  => l_rs);
  IF     (l_update_allowed = 'N')
     OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE update_not_allowed;
  END IF;

-- Bug 2181132 for overship tolerance
  WSH_USA_CATEGORIES_PVT.Change_Ship_Tolerance(
           p_attributes_rec => p_attributes_rec,
           p_source_code    => p_source_code,
           p_wms_flag       => l_wms_flag,
           x_update_allowed => l_update_allowed,
           x_return_status  => l_rs);
  IF     (l_update_allowed = 'N')
     OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE update_not_allowed;
  END IF;

  IF (p_attributes_rec.action_flag <> 'S') THEN
    -- we check quantity change only if this record is not an action to split.
    WSH_USA_CATEGORIES_PVT.Change_Quantity( -- Change in Quantity
      p_attributes_rec => p_attributes_rec,
      p_source_code    => p_source_code,
      p_wms_flag       => l_wms_flag,
      x_update_allowed => l_update_allowed,
      x_return_status  => l_rs);
  END IF; -- action_flag <> 'S'
  IF     (l_update_allowed = 'N')
     OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
    RAISE update_not_allowed;
  END IF;
  -- Standalone Project - Do no call Change_TP_Dates API if instance is running in Standalone mode
  IF NVL(WMS_DEPLOY.Wms_Deployment_Mode,'I') <> 'D' THEN --{
    WSH_USA_CATEGORIES_PVT.Change_TP_DATES(
               p_attributes_rec => p_attributes_rec,
               p_source_code    => p_source_code,
               x_changed_detail => x_changed_detail,
               x_update_allowed => l_update_allowed,
               x_return_status  => l_rs);
      IF(l_update_allowed = 'N')
         OR (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        RAISE update_not_allowed;
      END IF;
  END IF;

  x_return_status  := l_rs;
  x_update_allowed := l_update_allowed;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
      WSH_DEBUG_SV.log(l_module_name,'x_update_allowed',x_update_allowed);
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
    WHEN update_not_allowed THEN
      x_update_allowed := l_update_allowed;
      x_return_status  := l_rs;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --
      RETURN;
    WHEN OTHERS THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      wsh_util_core.default_handler('WSH_USA_CATEGORIES_PVT.Check_Categories',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Check_Attributes;




PROCEDURE Change_TP_Dates(
        p_attributes_rec    IN            WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN            VARCHAR2,
        x_changed_detail    OUT    NOCOPY WSH_USA_CATEGORIES_PVT.ChangedDetailRec,
        x_update_allowed    IN OUT NOCOPY VARCHAR2,
        x_return_status     OUT    NOCOPY VARCHAR2) IS

update_not_allowed        EXCEPTION;

l_datetype VARCHAR2(20);

l_in_id wsh_util_core.id_tab_type;

l_earliest_pickup_date DATE;
l_latest_pickup_date DATE;
l_earliest_dropoff_date DATE;
l_latest_dropoff_date DATE;



l_schedule_ship_date DATE;
l_latest_acceptable_date DATE;
l_promise_date DATE;
l_schedule_arrival_date DATE;
l_earliest_acceptable_date DATE;
l_earliest_ship_date DATE;

l_return_status VARCHAR2(250);

l_delivery_detail_id NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Change_TP_DATES';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
  END IF;

  IF (g_cache_detail_rec.container_flag = 'N') THEN

    WSH_TP_RELEASE.calculate_tp_dates(
           p_request_date_type        => g_cache_detail_rec.request_date_type_code,
           p_latest_acceptable_date   => p_attributes_rec.latest_acceptable_date,
           p_promise_date             => p_attributes_rec.promise_date,
           p_schedule_arrival_date    => p_attributes_rec.schedule_arrival_date,
           p_schedule_ship_date       => p_attributes_rec.date_scheduled,
           p_earliest_acceptable_date => p_attributes_rec.earliest_acceptable_date,
           p_demand_satisfaction_date => p_attributes_rec.earliest_ship_date,
           p_source_line_id           => p_attributes_rec.source_line_id,
           p_source_code              => p_source_code,
           p_inventory_item_id        => p_attributes_rec.inventory_item_id,
           p_organization_id          => p_attributes_rec.organization_id,
           x_return_status            => l_return_status,
           x_earliest_pickup_date     => l_earliest_pickup_date,
           x_latest_pickup_date       => l_latest_pickup_date,
           x_earliest_dropoff_date    => l_earliest_dropoff_date,
           x_latest_dropoff_date      => l_latest_dropoff_date
          );
        IF (l_return_status NOT IN (WSH_UTIL_CORE.G_RET_STS_SUCCESS, WSH_UTIL_CORE.G_RET_STS_WARNING)) THEN
                    WSH_INTERFACE.PrintMsg(name=>'WSH_CALC_TP_DATES',
                                 txt=>'Error in calculating TP dates: Date Type : '||l_datetype
                                           ||'Latest Acceptable Date : '||p_attributes_rec.latest_acceptable_date
                                           ||'Promise Date : '||p_attributes_rec.promise_date
                                           ||'Schedule Arr Date : '||p_attributes_rec.schedule_arrival_date
                                           ||'Earliest Acceptable Date : '||p_attributes_rec.earliest_acceptable_date
                                           ||'Earliest Ship Date : '||p_attributes_rec.earliest_ship_date
                                           ||'Schedulde Ship Date : '||p_attributes_rec.date_scheduled
                                           );
          IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Error in calculating TP dates: Date Type : '||l_datetype
                                           ||'Latest Acceptable Date : '||p_attributes_rec.latest_acceptable_date
                                           ||'Promise Date : '||p_attributes_rec.promise_date
                                           ||'Schedule Arr Date : '||p_attributes_rec.schedule_arrival_date
                                           ||'Earliest Acceptable Date : '||p_attributes_rec.earliest_acceptable_date
                                           ||'Earliest Ship Date : '||p_attributes_rec.earliest_ship_date
                                           ||'Schedulde Ship Date : '||p_attributes_rec.date_scheduled
                                           );
          END IF;
        ELSE

          IF  nvl(l_earliest_pickup_date,to_date('01/01/1970','mm/dd/yyyy'))
            <> nvl(g_cache_detail_rec.earliest_pickup_date,to_date('01/01/1970','mm/dd/yyyy'))
          OR nvl(l_latest_pickup_date,to_date('01/01/1970','mm/dd/yyyy'))
            <> nvl(g_cache_detail_rec.latest_pickup_date,to_date('01/01/1970','mm/dd/yyyy'))
          OR nvl(l_earliest_dropoff_date,to_date('01/01/1970','mm/dd/yyyy'))
            <> nvl(g_cache_detail_rec.earliest_dropoff_date,to_date('01/01/1970','mm/dd/yyyy'))
          OR nvl(l_latest_dropoff_date,to_date('01/01/1970','mm/dd/yyyy'))
            <> nvl(g_cache_detail_rec.latest_dropoff_date,to_date('01/01/1970','mm/dd/yyyy'))
           THEN

            x_changed_detail.earliest_pickup_date := l_earliest_pickup_date;
            x_changed_detail.latest_pickup_date   := l_latest_pickup_date;
            x_changed_detail.earliest_dropoff_date:= l_earliest_dropoff_date;
            x_changed_detail.latest_dropoff_date  := l_latest_dropoff_date;
           END IF;
        END IF;
      END IF; -- g_cache_detail_rec.container_flag

   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_update_allowed',x_update_allowed);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  EXCEPTION

     WHEN OTHERS THEN
      -- close open cursors as needed
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_update_allowed := 'N';
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_TP_DATES',l_module_name);
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END Change_TP_Dates;


PROCEDURE Change_Quantity(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN        VARCHAR2,
        p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2) IS

update_not_allowed        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_QUANTITY';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
      WSH_DEBUG_SV.log(l_module_name,'p_attributes_rec.ship_from_org_id',p_attributes_rec.ship_from_org_id);
      WSH_DEBUG_SV.log(l_module_name,'g_cache_detail_rec.organization_id',g_cache_detail_rec.organization_id);
      WSH_DEBUG_SV.log(l_module_name,'p_attributes_rec.inventory_item_id ',p_attributes_rec.inventory_item_id );
  END IF;
  --bug#6407943
  -- There is a possibility of having quantity change on delivery lines when there is a change in org
  -- value on sales order line and item's primary uom is different in old and new orgs.
  IF  ( (p_attributes_rec.ordered_quantity <> FND_API.G_MISS_NUM)
   AND  (p_attributes_rec.order_quantity_uom <> FND_API.G_MISS_CHAR))
   OR
   (      (p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM)
          AND (p_attributes_rec.ship_from_org_id <> g_cache_detail_rec.organization_id)
          AND (p_attributes_rec.inventory_item_id = FND_API.G_MISS_NUM ) ) THEN

      g_cache_detail_rec.cache_flag := 'N';
      WSH_USA_QUANTITY_PVT.Update_Ordered_Quantity(
                         p_changed_attribute => p_attributes_rec,
                         p_source_code       => p_source_code,
                         p_action_flag       => 'U',
                         p_wms_flag          => p_wms_flag,
                         x_return_status     => x_return_status);


  END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'x_update_allowed',x_update_allowed);
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
  EXCEPTION

     WHEN update_not_allowed THEN
      x_update_allowed := 'N';
      --
      IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --
      RETURN;
     WHEN OTHERS THEN
      -- close open cursors as needed
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_update_allowed := 'N';
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_Quantity',l_module_name);
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
           WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
       END IF;
       --
END Change_Quantity;


PROCEDURE Change_Schedule(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN        VARCHAR2,
        p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
        x_return_status     OUT NOCOPY        VARCHAR2)
IS
-- HW OPMCONV - Added Qty2
--bug# 6689448 (replenishment project): added wdd.replenishment_status
cursor c_delivery_detail is
select wdd.delivery_detail_id, wdd.released_status,
       wdd.move_order_line_id, wdd.ship_from_location_id,
       wdd.subinventory, wda.parent_delivery_detail_id,
       wda.delivery_id, wdd.inventory_item_id,
       wdd.serial_number, wdd.transaction_temp_id,
       wdd.requested_quantity, wdd.picked_quantity,
       wdd.requested_quantity2, wdd.picked_quantity2,
       wdd.net_weight, wdd.gross_weight, wdd.volume,
       wdd.weight_uom_code, wdd.volume_uom_code,
       wdd.original_subinventory, wdd.pickable_flag ,
      NVL(wnd.status_code, 'OP'), NVL(wnd.planned_flag, 'N'), NVL(wnd.tms_interface_flag, 'NS'),
      wdd.replenishment_status,
      wdd.client_id -- LSP PROJECT
from wsh_delivery_details wdd, wsh_delivery_assignments wda, wsh_new_deliveries wnd
where wdd.source_line_id = p_attributes_rec.source_line_id
and wdd.source_code = p_source_code
and wdd.delivery_detail_id = wda.delivery_detail_id
and wda.delivery_id = wnd.delivery_id(+)
order by decode(wdd.released_status, 'Y', 1, 2);

CURSOR c_del_status IS
SELECT wnd.status_code,wsp.export_screening_flag
FROM   wsh_delivery_details wdd, wsh_delivery_assignments wda, wsh_new_deliveries wnd,
       wsh_shipping_parameters wsp
WHERE  wdd.source_code = p_source_code
AND    wdd.source_line_id = p_attributes_rec.source_line_id
AND    wdd.delivery_detail_id = wda.delivery_detail_id
AND    wda.delivery_id = wnd.delivery_id
AND    wnd.organization_id = wsp.organization_id
AND   ( NVL(wnd.status_code, 'OP') IN ('SR','SA')  OR
        wsp.export_screening_flag IN ('C','A') );
CURSOR C_specific_item_info(c_p_inventory_item_id number, c_p_organization_id number) IS
SELECT description, hazard_class_id, primary_uom_code, weight_uom_code,
       unit_weight, volume_uom_code, unit_volume , decode(mtl_transactions_enabled_flag,'Y','Y','N') pickable_flag
FROM   mtl_system_items
WHERE  inventory_item_id = c_p_inventory_item_id
AND    organization_id = c_p_organization_id;

--Bug#8518110 : item sub. is enabled for backorder dds also
CURSOR c_det_status IS
SELECT 'N'
FROM   wsh_delivery_details
WHERE  source_line_id = p_attributes_rec.source_line_id
AND    source_code = p_source_code
AND    released_status IN ('S','Y','C');

CURSOR c_packed_det IS
SELECT 'N'
FROM   wsh_delivery_details wdd, wsh_delivery_assignments wda
WHERE  wdd.source_line_id = p_attributes_rec.source_line_id
AND    wdd.source_code = p_source_code
AND    wdd.released_status <> 'D'
AND    wdd.delivery_detail_id = wda.delivery_detail_id
AND    wda.parent_delivery_detail_id IS NOT NULL;

--bug#6407943: Begin
CURSOR  C_item_details(c_organization_id NUMBER,c_item_id NUMBER)  IS
SELECT  primary_uom_code
from    mtl_system_items
where   inventory_item_id = c_item_id
and     organization_id = c_organization_id ;
l_create_reservation  VARCHAR2(1):='Y';
l_primary_uom         VARCHAR2(3);
--bug#6407943: end

l_resv_tbl          inv_reservation_global.mtl_reservation_tbl_type;
l_del_det           NUMBER;
l_status            VARCHAR2(1);
l_unsched_flag      VARCHAR2(1);
l_mo_line           NUMBER;
l_subinventory      VARCHAR2(30);
l_orig_sub      VARCHAR2(30);
l_location_id       NUMBER;
l_parent_det        NUMBER;
l_delivery          NUMBER;
l_item_id           NUMBER;
l_pickable_flag     VARCHAR2(1);
l_reservable_flag   VARCHAR2(1);
l_serial_number     VARCHAR2(30);
l_trx_temp_id       NUMBER;
l_inv_controls      WSH_DELIVERY_DETAILS_INV.inv_control_flag_rec;
l_count             NUMBER;
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(2000);
l_reservation_id    NUMBER;
l_qty_reserved      NUMBER;
-- HW OPMCONV. Added l_qty2_reserved
l_qty2_reserved      NUMBER;
l_change_sub_only   VARCHAR2(1) := NULL;
l_change_resv_flag  VARCHAR2(1);
l_client_id         NUMBER; -- LSP PROJECT
update_not_allowed        EXCEPTION;
-- HW OPM for OM changes
-- HW OPMCONV. Removed OPM variables

-- bug fix 2095105
l_det_req_qty   NUMBER;
l_det_pic_qty   NUMBER;
-- HW OPMCONV - Added Qty2
l_det_req_qty2   NUMBER;
l_det_pic_qty2   NUMBER;
l_return_status VARCHAR2(30);
-- bug fix 2095105

--wrudge
l_delete_dds      WSH_UTIL_CORE.Id_Tab_Type ; -- to delete overpicked delivery lines

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs                VARCHAR2(1);     -- DBI Project

/* H projects: pricing integration csun */
i           NUMBER := 0;
l_del_tab   WSH_UTIL_CORE.Id_Tab_Type ; -- to mark reprice required flag
mark_reprice_error     EXCEPTION;
-- deliveryMerge
Adjust_Planned_Flag_Err  EXCEPTION;
l_num_warning          NUMBER  := 0;
--
-- begin item substitution project :bug#6077222
l_change_item                  VARCHAR2(1) := 'N';
l_export_screening_flag        VARCHAR2(1);
l_del_status                   VARCHAR2(2);
l_del_planned_flag             VARCHAR2(1);
l_tms_interface_flag           VARCHAR2(3);
l_msg                          VARCHAR2(2000);
l_exception_msg_count          NUMBER;
l_exception_msg_data           VARCHAR2(2000);
l_exception_return_status      VARCHAR2(30);
l_exception_location_id        VARCHAR2(30);
l_dummy_exception_id           VARCHAR2(30);
l_exception_error_message      VARCHAR2(2000);
l_shipping_param_info          WSH_SHIPPING_PARAMS_PVT.Parameter_Rec_Typ;
l_new_tot_requested_quantity   NUMBER;
l_old_tot_requested_quantity   NUMBER;
l_net_weight                   NUMBER;
l_gross_weight                 NUMBER;
l_volume                       NUMBER;
l_new_weight                   NUMBER;
l_new_volume                   NUMBER;
l_weight_uom_code              VARCHAR2(3);
l_volume_uom_code              VARCHAR2(3);
l_del_planned_tab              WSH_UTIL_CORE.ID_TAB_TYPE;
l_otm_del_tab                  WSH_UTIL_CORE.ID_TAB_TYPE;
l_delivery_id_tab              WSH_UTIL_CORE.ID_TAB_TYPE;
l_tms_interface_flag_tab       WSH_UTIL_CORE.COLUMN_TAB_TYPE;
l_item_rec                     c_specific_item_info%ROWTYPE;
l_final_org_id                 NUMBER;
l_ordered_quantity             NUMBER;
l_ordered_quantity_uom         VARCHAR2(5);
j                              NUMBER;
item_update_not_allowed        EXCEPTION;
-- end item substitution project :bug#6077222
--bug# 6689448 (replenishment project): begin
l_change_replenish_status  VARCHAR2(1) := 'N';
l_sub_change  VARCHAR2(1) := 'N';
l_replenish_status   VARCHAR2(1);
--bug# 6689448 (replenishment project): end

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_SCHEDULE';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
      WSH_DEBUG_SV.logmsg(l_module_name, 'IN CHANGE_SCHEDULE : ' || P_ATTRIBUTES_REC.SHIP_FROM_ORG_ID || 'SUB ' || P_ATTRIBUTES_REC.SUBINVENTORY || ' SCHED DATE ' || P_ATTRIBUTES_REC.DATE_SCHEDULED  );
  END IF;
  --
  SAVEPOINT before_changes;
-- Bug 2114166 Do not perform actions if the line is getting cancelled.

   IF p_attributes_rec.ordered_quantity = 0 THEN
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.pop(l_module_name,'line is being cancelled');
     END IF;
     --
     RETURN;
   END IF;
-- HW OPM for OM changes
      --
-- HW OPMCONV. Removed branching

-- HW end of OM changes

   -- 2071048. ADDED the check condition g_cache_detail_rec.subinventory <> FND_API.G_MISS_CHAR to
   -- avoid looping through the delivery_details if the released_status of the lines is either
   -- 'B' or 'Y' or 'S'.

   --bug# 6689448 (replenishment project): begin
   IF ( ( p_attributes_rec.subinventory <> FND_API.G_MISS_CHAR) OR (p_attributes_rec.subinventory IS NULL) )
       AND
       ( NVL(p_attributes_rec.subinventory, FND_API.G_MISS_CHAR) <> NVL(g_cache_detail_rec.subinventory, FND_API.G_MISS_CHAR ))  THEN
       l_sub_change := 'Y';
   END IF;
   --bug# 6689448 (replenishment project): end

   IF ((p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM) AND
       (p_attributes_rec.ship_from_org_id <> g_cache_detail_rec.organization_id))
    OR (p_attributes_rec.date_scheduled IS NULL AND g_cache_detail_rec.date_scheduled IS NOT NULL)
   THEN

     l_change_sub_only := 'N';

   ELSIF ( (l_sub_change = 'Y')
          OR
          ((p_attributes_rec.project_id <> FND_API.G_MISS_NUM) OR (p_attributes_rec.project_id IS NULL)) AND
          (NVL(p_attributes_rec.project_id, FND_API.G_MISS_NUM) <> NVL(g_cache_detail_rec.project_id, FND_API.G_MISS_NUM))
          OR
          ((p_attributes_rec.task_id <> FND_API.G_MISS_NUM) OR (p_attributes_rec.task_id IS NULL)) AND
          (NVL(p_attributes_rec.task_id, FND_API.G_MISS_NUM) <> NVL(g_cache_detail_rec.task_id, FND_API.G_MISS_NUM))
          )
          THEN
           l_change_sub_only := 'Y';
   END IF;

-- Item substitution project :bug#6077222
   --Begin.
   --1. Check whether item has been changed.
   IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Old inventory_item_id '||g_cache_detail_rec.inventory_item_id ||
                                           ' New inventory_item_id '||p_attributes_rec.inventory_item_id);
   END IF;
   IF  ( (p_attributes_rec.inventory_item_id <> FND_API.G_MISS_NUM)
   AND   (p_attributes_rec.inventory_item_id <> g_cache_detail_rec.inventory_item_id) )  THEN
   --{

     l_change_item := 'Y';

     --2.Check if detail is associated to OPM org - if so, do not allow update of item.
     --check for old org.
     IF INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => g_cache_detail_rec.organization_id) THEN
     --{
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Item Update is not allowed as it is associated to OPM organization.');
             END IF;
             RAISE item_update_not_allowed;
     --}
     END IF;
     --check for new org.
     IF  ( (p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM)
          AND (p_attributes_rec.ship_from_org_id <> g_cache_detail_rec.organization_id) ) THEN
     --{
          l_final_org_id:= p_attributes_rec.ship_from_org_id;
          IF INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_final_org_id) THEN
          --{
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Item Update is not allowed as it is associated to OPM organization.');
             END IF;
             RAISE item_update_not_allowed;
          --}
          END IF;
     ELSE
       l_final_org_id:= g_cache_detail_rec.organization_id;
     --}
     END IF;
     --2. end.

     --3.Check if detail exists with status other than 'R'/'N' - if so, do not allow update of item
     OPEN c_det_status;
     FETCH c_det_status INTO x_update_allowed;
     IF c_det_status%FOUND THEN
        CLOSE c_det_status;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Item Update is not allowed as there are Detail(s) that are already Pick Released ');
        END IF;
        RAISE item_update_not_allowed;
     END IF;
     CLOSE c_det_status;

     --4. Check if detail is packed into a container - if so, do not allow update of item
     OPEN c_packed_det;
     FETCH c_packed_det INTO x_update_allowed;
     IF c_packed_det%FOUND THEN
        CLOSE c_packed_det;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Item Update is not allowed as there are Detail(s) that are packed into Containers ');
        END IF;
        RAISE item_update_not_allowed;
     END IF;
     CLOSE c_packed_det;

     --5. TPW / Carrier Manifesting Orgs, do not allow update if the delivery is not in 'Open' status {
     OPEN c_del_status;
     FETCH c_del_status INTO l_del_status,l_export_screening_flag;
     IF c_del_status%FOUND THEN
        CLOSE c_del_status;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
           IF ( l_del_status in ('SA','SR') ) THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Update is not allowed as there is a Delivery that belongs to tpw/carrier manifesting Organization with status '||l_del_status);
           END IF;
           IF ( l_export_screening_flag in ('C','A') ) THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Update is not allowed as export compliance screening is enabled at delivery creation/delivery creation and ship confirm '||l_export_screening_flag);
           END IF;
        END IF;
        RAISE item_update_not_allowed;
     END IF;
     CLOSE c_del_status; --}

     --6. Get Item specific info for new item.
     OPEN  C_specific_item_info(p_attributes_rec.inventory_item_id, l_final_org_id);
     FETCH C_specific_item_info INTO l_item_rec;
     CLOSE C_specific_item_info;

     --7. Check if the primary UOM of the new Item is different than the primary UOM of old Item - if so
     --   do not allow update of item.
     IF (g_cache_detail_rec.requested_quantity_uom <> l_item_rec.primary_uom_code ) THEN
     --{
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Update is not allowed as there is a difference in primary UOM for old and new item');
        END IF;
        RAISE item_update_not_allowed;
     --}
     END IF;

     --8. Check if UOM conversion (from order UOM to primary uom) is different. if so - do not allow update of item.
     IF  ( (p_attributes_rec.src_requested_quantity <> FND_API.G_MISS_NUM)
          AND (p_attributes_rec.src_requested_quantity <> g_cache_detail_rec.src_requested_quantity) ) THEN
          l_ordered_quantity := p_attributes_rec.src_requested_quantity;
     ELSE
         l_ordered_quantity := g_cache_detail_rec.src_requested_quantity;
     END IF;
     IF  ( (p_attributes_rec.src_requested_quantity_uom <> FND_API.G_MISS_CHAR)
          AND (p_attributes_rec.src_requested_quantity_uom <> g_cache_detail_rec.src_requested_quantity_uom) ) THEN
          l_ordered_quantity_uom := p_attributes_rec.src_requested_quantity_uom;
     ELSE
         l_ordered_quantity_uom := g_cache_detail_rec.src_requested_quantity_uom;
     END IF;

     l_new_tot_requested_quantity := wsh_wv_utils.convert_uom(l_ordered_quantity_uom,
                                                              l_item_rec.primary_uom_code,
                                                              l_ordered_quantity,
                                                              p_attributes_rec.inventory_item_id);

     l_old_tot_requested_quantity := wsh_wv_utils.convert_uom(l_ordered_quantity_uom,
                                                              l_item_rec.primary_uom_code,
                                                              l_ordered_quantity,
                                                              g_cache_detail_rec.inventory_item_id);

     IF NVL(l_new_tot_requested_quantity, 0) <> nvl(l_old_tot_requested_quantity,0) THEN
     --{
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'Update is not allowed as there is a difference in UOM conversions for old and new item');
        END IF;
        RAISE item_update_not_allowed;
     --}
     END IF;
   --} Item substitute validations
   END IF;

   IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'l_change_sub_only:'||l_change_sub_only||', l_change_item:'||l_change_item);
   END IF;

   IF l_change_sub_only IS NOT NULL OR l_change_item = 'Y' THEN
   --{

     g_cache_detail_rec.cache_flag := 'N';

     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS NOT NULL'  );
     END IF;
     /* moved to inside the loop
     --
     IF l_change_item = 'Y' THEN
     --{
        WSH_SHIPPING_PARAMS_PVT.Get(
                      p_organization_id => l_final_org_id,
                      x_param_info      => l_shipping_param_info,
                      x_return_status   => x_return_status
                      );

        IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        --{
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Update is not allowed as there are no shipping parameters defined for the org: '||l_final_org_id);
           END IF;
           RAISE item_update_not_allowed;
         --}
         END IF;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'l_shipping_param_info.otm_enabled: '||l_shipping_param_info.otm_enabled);
         END IF;
     --}
     END IF;
     --
     */
     open c_delivery_detail; -- cursor to get del det/status code from source line.

     LOOP

      FETCH c_delivery_detail  into l_del_det, l_status,
                                   l_mo_line, l_location_id, l_subinventory,
                                   l_parent_det, l_delivery, l_item_id,
                                   l_serial_number, l_trx_temp_id,
-- HW OPMCONV - Added Qty2
                                   l_det_req_qty, l_det_pic_qty,
				   l_det_req_qty2, l_det_pic_qty2,
	                           l_net_weight, l_gross_weight, l_volume,
                                   l_weight_uom_code, l_volume_uom_code,
                          	   l_orig_sub, l_pickable_flag ,
				   l_del_status, l_del_planned_flag, l_tms_interface_flag,l_replenish_status,l_client_id ; -- LSP PROJECT

       EXIT WHEN c_delivery_detail%NOTFOUND;
       /* H Projects: Pricing integration csun */
       -- LSP PROJECT : Begin.
        --
     IF l_change_item = 'Y' THEN
     --{
        WSH_SHIPPING_PARAMS_PVT.Get(
                      p_organization_id => l_final_org_id,
                      p_client_id       => l_client_id, -- LSP PROJECT.
                      x_param_info      => l_shipping_param_info,
                      x_return_status   => x_return_status
                      );

        IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        --{
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name, 'Update is not allowed as there are no shipping parameters defined for the org: '||l_final_org_id);
           END IF;
           RAISE item_update_not_allowed;
         --}
         END IF;
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'l_shipping_param_info.otm_enabled: '||l_shipping_param_info.otm_enabled);
         END IF;
     --}
     END IF;
     --
       IF l_delivery is NOT NULL THEN
         i := i + 1;
         l_del_tab(i) := l_delivery;
         --
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING DELIVERY '|| L_DELIVERY || 'TO MARK LIST'||',l_del_planned_flag: '||l_del_planned_flag||',l_tms_interface_flag: '||l_tms_interface_flag);
         END IF;
         --

     IF l_change_item = 'Y' THEN
         --{
            -- Check for firmed deliveries
            IF l_del_planned_flag IN ('Y','F') AND (NOT l_del_planned_tab.exists(l_delivery)) THEN
               l_del_planned_tab(l_delivery) := l_delivery;
            END IF;
            -- Check for tms_interface_flag for OTM deliveries that need to be updated to 'UR'
            IF l_shipping_param_info.otm_enabled = 'Y' AND (NOT l_otm_del_tab.exists(l_delivery))
            AND l_tms_interface_flag in ('CP','UP','AW','AR') THEN
                  l_otm_del_tab(l_delivery) := l_delivery;
            END IF;
         --}
       END IF;
       --} delivery check
    END IF;

        ---subinventory specific validations
       IF ( l_change_sub_only IS NOT NULL ) THEN
       --{
          IF l_status = 'Y' AND p_wms_flag = 'Y' THEN
             IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'l_status is set to Y');
             END IF;
             FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_UPDATE_NOT_ALLOWED');
             x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
             WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
             RAISE update_not_allowed;
             exit; -- exit loop if action breaks WMS.
             -- how does it come to exit,when we raise update_not_allowed?
        END IF;
	--

       IF l_change_sub_only = 'Y' THEN
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS: '||L_CHANGE_SUB_ONLY  );
        END IF;
        --
         IF l_status NOT IN ('S','Y') THEN

           l_change_sub_only := 'X';

         ELSE
           l_reservable_flag := WSH_DELIVERY_DETAILS_INV.get_reservable_flag(
                                                         x_item_id => l_item_id,
                                                         x_organization_id =>  g_cache_detail_rec.organization_id,
                                                         x_pickable_flag =>  l_pickable_flag);

           IF l_reservable_flag = 'N'
             AND
              (NVL(l_orig_sub, FND_API.G_MISS_CHAR) <> NVL(p_attributes_rec.subinventory, FND_API.G_MISS_CHAR))
             AND
              (l_status = 'Y' OR (l_status = 'S' AND l_pickable_flag = 'N'))
           THEN

             l_change_sub_only := 'X';

           END IF;

         END IF;

      END IF;

      END IF ;

       -- Here, we set l_change_sub_only to 'X' only if we do need to change the subinventory.
       -- if l_change_sub_only remains at 'Y' we do not go ahead with the changes.
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS: '||L_CHANGE_SUB_ONLY  );
       END IF;
     --
     IF l_change_sub_only IN  ('N', 'X') OR l_change_item = 'Y' THEN

       --
       IF l_change_sub_only IN  ('N', 'X') THEN
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'IN CHANGE_SCHEDULE DOING ACTIONS'  );
         END IF;
         l_change_resv_flag := 'Y';

       END IF ; --Bug 6732141
       --
--wrudge
         IF (l_det_req_qty = 0) THEN

            -- get this overpicked detail deleted
            -- because we can't have req qty = 0 with status 'R'
            l_delete_dds( l_delete_dds.count+1 ) := l_del_det;

         ELSE

   -- subinventory specific validations.
        IF ( l_change_sub_only IN  ('N', 'X') ) THEN
         --{

           IF (l_status = 'S') THEN
-- HW OPM code for OM changes. Need to branch
-- HW OPMCONV. Removed branching
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'l_del_det',l_del_det);
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.CANCEL_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;
              --
              INV_MO_Cancel_PVT.Cancel_Move_Order_Line(
                                p_line_id              =>  l_mo_line,
                                p_delete_reservations  =>  'N',
                                p_txn_source_line_id   =>  p_attributes_rec.source_line_id,
                                p_delivery_detail_id   =>  l_del_det, -- X-dock
                                x_return_status        =>  x_return_status,
                                x_msg_count            =>  l_msg_count,
                                x_msg_data             =>  l_msg_data
                                );

              IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                        IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Cancel_Move_Order_Line returned error');
                        END IF;
                        RAISE update_not_allowed;
              END IF;

           END IF; --subinventory specific validation
-- HW OPMCONV. Removed branching
-- OPM org
   --wrudge
           -- lines released to warehouse or staged need to be unassigned.
           -- unreleased lines can stay in their deliveries.
           IF l_status IN ('S', 'Y') THEN

             IF l_delivery IS NOT NULL THEN
               WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Delivery(
                               p_detail_id => l_del_det,
                               p_validate_flag => 'N',
                               x_return_status => x_return_status);

               IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                 RAISE update_not_allowed;

               END IF;

               Log_Exception(
                  p_delivery_detail_id  => l_del_det,
                  p_location_id         => l_location_id,
                  p_exception_name      => 'WSH_CHANGE_SCHEDULE',
                  p_entity_name         => 'WSH_DELIVERY',
                  p_entity_id           => l_delivery,
                  x_return_status       => x_return_status);

               IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                 RAISE update_not_allowed;

               END IF;

             END IF;

             IF l_parent_det IS NOT NULL THEN
               WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont(
                                 p_detail_id => l_del_det,
                                 p_validate_flag => 'N',
                                 x_return_status => x_return_status);

               IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                 RAISE update_not_allowed;

               END IF;

               Log_Exception(
                  p_delivery_detail_id  => l_del_det,
                  p_location_id         => l_location_id,
                  p_exception_name      => 'WSH_CHANGE_SCHEDULE',
                  p_entity_name         => 'WSH_CONTAINER',
                  p_entity_id           => l_parent_det,
                  x_return_status       => x_return_status);

               IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                 RAISE update_not_allowed;

               END IF;

             END IF;

           END IF; --l_status IN ('S',  'Y')

           IF (l_serial_number IS NOT NULL) OR (l_trx_temp_id IS NOT NULL) THEN

             WSH_DELIVERY_DETAILS_INV.Fetch_Inv_Controls(
                                 p_delivery_detail_id => l_del_det,
                                 p_inventory_item_id => l_item_id,
                                 p_organization_id => g_cache_detail_rec.organization_id,
                                 p_subinventory => l_subinventory,
                                 x_inv_controls_rec => l_inv_controls,
                                 x_return_status => x_return_status);

             IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

               RAISE update_not_allowed;

             END IF;
             WSH_DELIVERY_DETAILS_INV.Unmark_Serial_Number (
                            p_delivery_detail_id => l_del_det,
                            p_serial_number_code => l_inv_controls.serial_code,
                            p_serial_number => l_serial_number,
                            p_transaction_temp_id => l_trx_temp_id,
                            x_return_status => x_return_status);

             IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

               RAISE update_not_allowed;

             END IF;

           END IF; -- IF l_serial_number IS NOT NULL

       -- bug fix 2095105
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'DET PICKED QTY = ' || L_DET_PIC_QTY  );
         WSH_DEBUG_SV.logmsg(l_module_name, 'DET REQ QTY = ' || L_DET_REQ_QTY  );
-- HW OPMCONV -Print Qty2
         WSH_DEBUG_SV.logmsg(l_module_name, 'DET PICKED QTY2 = ' || L_DET_PIC_QTY2  );
         WSH_DEBUG_SV.logmsg(l_module_name, 'DET REQ QTY2 = ' || L_DET_REQ_QTY2  );
     END IF;
     ----

     IF ( l_det_pic_qty > l_det_req_qty) THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name, 'DET PICKED QTY AGAIN = ' || L_DET_PIC_QTY  );
       END IF;

-- HW OPMCONV - Pass Qty2
       WSH_DELIVERY_DETAILS_ACTIONS.Unreserve_delivery_detail
       (
          p_delivery_detail_id    => l_del_det,
          p_quantity_to_unreserve => (l_det_pic_qty - l_det_req_qty),
          p_quantity2_to_unreserve => (l_det_pic_qty2 - l_det_req_qty2),
          p_unreserve_mode        => 'UNRESERVE',
          x_return_status         => l_return_status
       );

                 IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                       RAISE update_not_allowed;
                   END IF;
         END IF;
         --} Subinventory specific code.
      END IF;

      --bug# 6719369 (replenishment project) : Need to change the status of replenishment requested/replenishment completed
      -- delivery details back to original status when there is change in warehouse/subinventory/item/scheduled to NULL on the sales order line.
      IF ( (l_sub_change = 'Y' OR l_change_item = 'Y' OR  l_change_sub_only = 'N' ) AND ( l_replenish_status IS NOT NULL)
               AND (l_status in ('R','B'))  )  THEN
      --{
           l_change_replenish_status := 'Y';
           IF ( l_replenish_status = 'R' ) THEN
           --{
               IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL' ,WSH_DEBUG_SV.C_PROC_LEVEL);
               END IF;
               WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL(
                    p_delivery_detail_id => l_del_det,
                    p_primary_quantity   => 0, --- WMS will delete the records from WMS table.
	            x_return_status      => x_return_status);
               IF x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               --{
                   IF l_debug_on THEN
       	               WSH_DEBUG_SV.logmsg(l_module_name,  'UNEXPECTED ERROR FROM WMS_REPLENISHMENT_PUB.UPDATE_DELIVERY_DETAIL');
                       WSH_DEBUG_SV.pop(l_module_name);
                   END IF;
                   RETURN;
	       --}
               END IF;
           --}
           END IF;
      ELSE
           l_change_replenish_status := 'N';
      --}
      END IF;
      --bug# 6689448 (replenishment project):  end

        -- Calculate new weight and new volume for each detail
            IF l_change_item = 'Y' THEN
            --{ item specific code
               -- revert old weight and volume information from delivery.
               IF l_delivery IS NOT NULL THEN
               --{
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;
                  WSH_WV_UTILS.DD_WV_Post_Process(
                   p_delivery_detail_id => l_del_det,
                   p_diff_gross_wt      => -1 * l_gross_weight,
                   p_diff_net_wt        => -1 * l_net_weight,
                   p_diff_volume        => -1 * l_volume,
                   p_diff_fill_volume   => -1 * l_volume,
                   x_return_status      => l_return_status);
                  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                      x_return_status := l_return_status;
                      IF l_debug_on THEN
                            WSH_DEBUG_SV.log(l_module_name,'Return Status after DD_WV_Post_Process',x_return_status);
                      END IF;
                      RAISE item_update_not_allowed;
                  END IF;
               --} delivery is not null.
               END IF;
               -- calculate new item wieght and volume based on the substite item.
               l_new_weight := l_item_rec.unit_weight * l_det_req_qty;
               l_new_volume := l_item_rec.unit_volume * l_det_req_qty;

            --} item specific code
          END IF;

     -- bug fix 2095105
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name, 'IN CHANGE_SCHEDULE UPDATING WDD'  );
         END IF;
         --
-- HW OPM for OM changes. Added preferred_grade
--HW OPMCONV -Added Qty2s
           UPDATE wsh_delivery_details
           SET subinventory =  NULL,
             lot_number = NULL,
             locator_id = NULL,
             revision = NULL,
             move_order_line_id = NULL,
-- HW OPMCONV. No need for sublot anymore
--           sublot_number = NULL,
             preferred_grade = NULL,
             shipped_quantity = NULL,
             cycle_count_quantity = NULL,
             shipped_quantity2 = NULL,
             cycle_count_quantity2 = NULL,
             picked_quantity = NULL,
             picked_quantity2 = NULL,
             serial_number = NULL,
             transaction_temp_id = NULL,
             batch_id  = NULL,
             transaction_id = NULL,  ---  2803570
	     inventory_item_id      = DECODE(l_change_item, 'Y', p_attributes_rec.inventory_item_id, inventory_item_id),
             item_description       = DECODE(l_change_item, 'Y', l_item_rec.description, item_description),
             unit_weight            = DECODE(l_change_item, 'Y', l_item_rec.unit_weight, unit_weight),
             weight_uom_code        = DECODE(l_change_item, 'Y', l_item_rec.weight_uom_code, weight_uom_code),
             net_weight             = DECODE(l_change_item, 'Y', l_new_weight, net_weight),
             gross_weight           = DECODE(l_change_item, 'Y', l_new_weight, gross_weight),
             unit_volume            = DECODE(l_change_item, 'Y', l_item_rec.unit_volume, unit_volume),
             volume_uom_code        = DECODE(l_change_item, 'Y', l_item_rec.volume_uom_code, volume_uom_code),
             volume                 = DECODE(l_change_item, 'Y', l_new_volume, volume),
             wv_frozen_flag         = DECODE(l_change_item, 'Y', 'N', wv_frozen_flag),
             pickable_flag          = DECODE(l_change_item, 'Y', l_item_rec.pickable_flag, pickable_flag),
             hazard_class_id        = DECODE(l_change_item, 'Y', l_item_rec.hazard_class_id, hazard_class_id),
	     released_status        = DECODE(released_status,'X', DECODE(l_change_item, 'Y', DECODE(l_item_rec.pickable_flag, 'N', 'X', 'R'), 'X'),
                                                  'B', 'B', DECODE(l_change_item, 'Y', DECODE(l_item_rec.pickable_flag, 'N', 'X', 'R'), 'R')),
             inv_interfaced_flag    = DECODE(l_change_item, 'Y', DECODE(l_item_rec.pickable_flag, 'N','X','N'), inv_interfaced_flag),
              requested_quantity2 = p_attributes_rec.ordered_quantity2,
             requested_quantity_uom2= p_attributes_rec.ordered_quantity_uom2,
             replenishment_status = decode(l_change_replenish_status,'Y',NULL,replenishment_status)  ----bug# 6689448 (replenishment project)
            WHERE delivery_detail_id = l_del_det;

           l_detail_tab(l_detail_tab.count+1) := l_del_det ; -- added for DBI Project

           IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Rows updated:',SQL%ROWCOUNT);
           END IF;

	   IF l_change_item = 'Y' and l_delivery IS NOT NULL THEN --{
               -- Propagate new weight and volume for UOMs change
                IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WV_UTILS.DD_WV_Post_Process',WSH_DEBUG_SV.C_PROC_LEVEL);
                END IF;
                WSH_WV_UTILS.DD_WV_Post_Process(
                p_delivery_detail_id => l_del_det,
                p_diff_gross_wt      => l_new_weight,
                p_diff_net_wt        => l_new_weight,
                p_diff_volume        => l_new_volume,
                p_diff_fill_volume   => l_new_volume,
                x_return_status      => l_return_status);
               IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                  x_return_status := l_return_status;
                  IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name,'Return Status after DD_WV_Post_Process',x_return_status);
                  END IF;
                  RAISE item_update_not_allowed;
               END IF;
            --} Weight / Volume Propagation for Item change
            END IF;

         END IF; -- (l_det_req_qty = 0)

       END IF; -- l_change_sub_only in ('N','X') OR item_change = 'Y'

     END LOOP;

     CLOSE c_delivery_detail;
     --
     -- DBI Project
     -- Update of wsh_delivery_details where released_status
     -- are changed, call DBI API after the update.
     -- This API will also check for DBI Installed or not
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Calling DBI API. delivery details l_detail_tab count',l_detail_tab.count);
     END IF;
     WSH_INTEGRATION.DBI_Update_Detail_Log
       (p_delivery_detail_id_tab => l_detail_tab,
        p_dml_type               => 'UPDATE',
        x_return_status          => l_dbi_rs);

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
     END IF;
     IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := l_dbi_rs;
          Rollback to before_changes;
	  -- just pass this return status to caller API
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
            WSH_DEBUG_SV.pop(l_module_name);
          END IF;
          return;
     END IF;
     -- End of Code for DBI Project
     --
      --wrudge

--wrudge

     -- purge overpicked delivery details
     IF l_delete_dds.count > 0 THEN
       WSH_INTERFACE.Delete_Details(
       p_details_id      =>    l_delete_dds,
       x_return_status   =>    x_return_status
       );

       IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         RAISE update_not_allowed;
       END IF;
     END IF;
    --brana
     IF l_change_item = 'Y' THEN
     --{
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_del_planned_tab count',l_del_planned_tab.count);
        END IF;
        --Intialize the message and location id
        IF ( l_del_planned_tab.count > 0) THEN
        --{
           FND_MESSAGE.SET_NAME('WSH','WSH_ITEM_SUBSTITUTED');
           FND_MESSAGE.SET_TOKEN('ITEM1',WSH_UTIL_CORE.Get_Item_Name(p_attributes_rec.inventory_item_id,
                                                                    l_final_org_id));
           FND_MESSAGE.SET_TOKEN('ITEM2',WSH_UTIL_CORE.Get_Item_Name(g_cache_detail_rec.inventory_item_id,
                                                                    l_final_org_id));
           l_msg := FND_MESSAGE.GET;
           l_exception_location_id := l_location_id;
        --}
        END IF;
        i := l_del_planned_tab.FIRST;
        WHILE i is not null LOOP
        --{
          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION for planned delivery '||l_del_planned_tab(i),WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          WSH_XC_UTIL.Log_Exception(
          p_api_version           => 1.0,
          x_return_status         => l_exception_return_status,
          x_msg_count             => l_exception_msg_count,
          x_msg_data              => l_exception_msg_data,
          x_exception_id          => l_dummy_exception_id ,
          p_logged_at_location_id => l_exception_location_id,
          p_exception_location_id => l_exception_location_id,
          p_logging_entity        => 'SHIPPER',
          p_logging_entity_id     => FND_GLOBAL.USER_ID,
          p_exception_name        => 'WSH_ITEM_SUBSTITUTED',
          p_message               => l_msg,
          p_delivery_id           => l_del_planned_tab(i),
          p_error_message         => l_exception_error_message);
          i := l_del_planned_tab.NEXT(i);
          IF l_debug_on THEN
             WSH_DEBUG_SV.log(l_module_name,'log_exception l_exception_return_status',l_exception_return_status);
          END IF;
        --}
        END LOOP;

        -- OTM Deliveries Mark for Update
        IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,'l_otm_del_tab count',l_otm_del_tab.count);
        END IF;
        i := l_otm_del_tab.FIRST;
        j := 0;
        WHILE i is not null LOOP --{
          j := j + 1;
          l_delivery_id_tab(j) := l_otm_del_tab(i);
          l_tms_interface_flag_tab(j) := 'UR';
          i := l_otm_del_tab.NEXT(i);
        END LOOP;
        IF l_delivery_id_tab.FIRST IS NOT NULL THEN
           IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.UPDATE_TMS_INTERFACE_FLAG',WSH_DEBUG_SV.C_PROC_LEVEL);
           END IF;
           WSH_NEW_DELIVERIES_PVT.Update_TMS_Interface_Flag
            (p_delivery_id_tab        => l_delivery_id_tab,
             p_tms_interface_flag_tab => l_tms_interface_flag_tab,
             x_return_status          => l_return_status);
           IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
              x_return_status := l_return_status;
              IF l_debug_on THEN
                 WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_NEW_DELIVERIES_PVT.Update_Tms_interface_flag',l_return_status);
              END IF;
              RAISE item_update_not_allowed;
           END IF;
        END IF; --}
     END IF; --}

     IF l_change_resv_flag = 'Y' THEN

     -- Looks like we have to query resv. all the time since delete resv. needs the table of recs.

     -- R12 X-dock, added parameter p_delivery_detail_id
     -- this code is called only when l_change_resv_flag = Y
     -- when this flag is Y either l_delete_dds is populated or cancel_MOL api is called
     -- As stated above, this call is made primarily to delete_reservations
     -- Above, we have call to INV_MO_Cancel_PVT.Cancel_Move_Order_Line for released_status of 'S'
     -- this takes care of the reservations, hence pass null for delivery_detail_id
       WSH_USA_INV_PVT.query_reservations(
                     p_source_code               => p_source_code,
                     p_source_header_id          => p_attributes_rec.source_header_id,
                     p_source_line_id            => p_attributes_rec.source_line_id,
                     p_organization_id           => g_cache_detail_rec.organization_id,
                     p_delivery_detail_id        => null, -- X-dock
                     x_mtl_reservation_tbl       => l_resv_tbl,
                     x_mtl_reservation_tbl_count => l_count,
                     x_return_status             => x_return_status);

       IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
         RAISE update_not_allowed;
       END IF;

       --END IF;
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS: '||L_CHANGE_SUB_ONLY  );
       END IF;
       --
       --bug#6407943: begin.
       --Creation of reservations should be stopped when
       --item's primary uom value is different in new organization.
       IF (l_count > 0) THEN
       --{
         IF  ( (p_attributes_rec.ship_from_org_id <> FND_API.G_MISS_NUM)
            AND (p_attributes_rec.ship_from_org_id <> g_cache_detail_rec.organization_id) )
           and (p_attributes_rec.inventory_item_id = FND_API.G_MISS_NUM ) THEN
         --{
            OPEN  C_item_details(p_attributes_rec.ship_from_org_id,g_cache_detail_rec.inventory_item_id);
            FETCH C_item_details INTO l_primary_uom;
            CLOSE C_item_details;
            IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'new primary uom',l_primary_uom);
                WSH_DEBUG_SV.log(l_module_name,'old primary uom',g_cache_detail_rec.requested_quantity_uom);
            END IF;
            IF (l_primary_uom <> g_cache_detail_rec.requested_quantity_uom) THEN
                 l_create_reservation  := 'N';
            END IF;
         --}
         end if;
       --}
       END IF;
       --bug#6407943. end
       --
       FOR i IN 1.. l_count LOOP

         WSH_USA_INV_PVT.delete_reservation (
           p_query_input     => l_resv_tbl(i),
           x_return_status    => x_return_status);

         IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

           RAISE update_not_allowed;

         END IF;


         IF p_attributes_rec.date_scheduled IS NOT NULL AND l_create_reservation = 'Y' THEN  --bug#6407943

         --oe_debug_pub.add('In change_schedule : unsched_flag '||l_unsched_flag, 2 );
           IF l_change_sub_only = 'N'  THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS: '||L_CHANGE_SUB_ONLY  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'NEW ORG: '||P_ATTRIBUTES_REC.SHIP_FROM_ORG_ID  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'NEW SUB: '||P_ATTRIBUTES_REC.SUBINVENTORY  );
            END IF;
            --
-- HW OPMCONV - Print values
            IF l_debug_on THEN

                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity: '||p_attributes_rec.ordered_quantity  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity2: '||p_attributes_rec.ordered_quantity2  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity_uom: '||p_attributes_rec.order_quantity_uom   );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity_uom2: '||p_attributes_rec.ordered_quantity_uom2  );
            END IF;
            -- Resetting the Reservations Record Structure
             l_resv_tbl(i).organization_id               := p_attributes_rec.ship_from_org_id;
             l_resv_tbl(i).subinventory_code             := p_attributes_rec.subinventory;
             l_resv_tbl(i).revision                      := NULL;
             l_resv_tbl(i).locator_id                    := NULL;
             l_resv_tbl(i).lot_number                    := NULL;
             l_resv_tbl(i).lpn_id                        := NULL;
             l_resv_tbl(i).demand_source_line_detail     := NULL; -- X-dock
             l_resv_tbl(i).ship_ready_flag               := 2;
	           l_resv_tbl(i).staged_flag                   := 'N';
-- HW OPMCONV - Update the Qtys and UOM in case the item are single in one
-- org and dual in a different org
             l_resv_tbl(i).primary_reservation_quantity   := p_attributes_rec.ordered_quantity;
             l_resv_tbl(i).secondary_reservation_quantity := p_attributes_rec.ordered_quantity2;
             l_resv_tbl(i).primary_uom_code               := p_attributes_rec.order_quantity_uom ;
             l_resv_tbl(i).secondary_uom_code             := p_attributes_rec.ordered_quantity_uom2;
             l_resv_tbl(i).project_id                     := p_attributes_rec.project_id;
             l_resv_tbl(i).task_id                        := p_attributes_rec.task_id;

             -- bug 5225044: reservation's need by date has to be updated
             --              in the context of changing both organization
             --              and scheduled ship date on the order line.
             --  If scheduled ship date is not changed, the need by date
             --  will be left alone.
             IF     (g_cache_detail_rec.date_scheduled IS NULL)
                 OR (p_attributes_rec.date_scheduled
                      <> g_cache_detail_rec.date_scheduled)
             THEN
               l_resv_tbl(i).requirement_date :=
                               p_attributes_rec.date_scheduled;
             END IF;

           ELSIF l_change_sub_only = 'X'  THEN

-- HW OPMCONV - Print values
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS: '||L_CHANGE_SUB_ONLY  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'NEW SUB: '||P_ATTRIBUTES_REC.SUBINVENTORY  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'IN L_CHANGE_SUB_ONLY IS: '||L_CHANGE_SUB_ONLY  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity: '||p_attributes_rec.ordered_quantity  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity2: '||p_attributes_rec.ordered_quantity2  );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity_uom: '||p_attributes_rec.order_quantity_uom   );
                WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.ordered_quantity_uom2: '||p_attributes_rec.ordered_quantity_uom2  );
            END IF;
            --
             l_resv_tbl(i).subinventory_code :=  p_attributes_rec.subinventory;
             l_resv_tbl(i).revision := NULL;
             l_resv_tbl(i).locator_id := NULL;
             l_resv_tbl(i).lot_number := NULL;
             l_resv_tbl(i).lpn_id       := NULL;
             l_resv_tbl(i).ship_ready_flag       := 2;
	     l_resv_tbl(i).staged_flag := 'N';
-- HW OPMCONV - Update the Qtys and UOM in case the item are single in one
-- org and dual in a different org

             l_resv_tbl(i).primary_reservation_quantity := p_attributes_rec.ordered_quantity;
             l_resv_tbl(i).secondary_reservation_quantity := p_attributes_rec.ordered_quantity2;
             l_resv_tbl(i).primary_uom_code := p_attributes_rec.order_quantity_uom ;
             l_resv_tbl(i).secondary_uom_code := p_attributes_rec.ordered_quantity_uom2;
             l_resv_tbl(i).project_id         := p_attributes_rec.project_id;
             l_resv_tbl(i).task_id            := p_attributes_rec.task_id;

             -- bug 5333667: clear attributes for WIP/supply source
             -- pass "g_miss_xxx" because we don't care.
             l_resv_tbl(i).supply_source_type_id     := FND_API.G_MISS_NUM;
             l_resv_tbl(i).supply_source_header_id   := FND_API.G_MISS_NUM;
             l_resv_tbl(i).supply_source_line_id     := FND_API.G_MISS_NUM;
             l_resv_tbl(i).supply_source_name        := FND_API.G_MISS_CHAR;
             l_resv_tbl(i).supply_source_line_detail := FND_API.G_MISS_NUM;

           END IF;
           --
           IF l_debug_on THEN
             wsh_debug_sv.logmsg(l_module_name, 'Actual reservation record
                       being passed to INV');
             wsh_debug_Sv.log(l_module_name, 'RSV record.staged_flag',
                        l_resv_tbl(i).staged_flag);
             wsh_debug_sv.log(l_module_name, 'RSV record org Id',
                        l_resv_tbl(i).organization_id);
             wsh_debug_sv.log(l_module_name, 'RSV subinventory Code',
                        l_resv_tbl(i).subinventory_code);
           END IF;
           --
-- HW OPMCONV. Pass a new parameter p_qty2
           WSH_USA_INV_PVT.create_reservation (
             p_query_input     => l_resv_tbl(i),
             p_qty2            => p_attributes_rec.ordered_quantity2,
             x_reservation_id  => l_reservation_id,
             x_qty_reserved    => l_qty_reserved,
             x_return_status   => x_return_status);

           -- Continue even if create reservation fails.
         END IF; -- if not unsched
       END LOOP;

     END IF; -- l_change_resv_flag = 'Y'


     /*  H integration: Pricing integration csun     */
     IF l_del_tab.count > 0 THEN
        WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
        p_entity_type => 'DELIVERY',
         p_entity_ids   => l_del_tab,
        x_return_status => l_return_status);
        IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
          raise mark_reprice_error;
        END IF;

        -- deliveryMerge
        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;
        WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
              p_delivery_ids          => l_del_tab,
              p_caller                => 'WSH_DLMG',
              p_force_appending_limit => 'N',
              p_call_lcss             => 'Y',
              p_event                 => NULL,
              x_return_status         => l_return_status);
        IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Adjust_Planned_Flag l_return_status',l_return_status);
        END IF;

        IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR  THEN
           raise Adjust_Planned_Flag_Err;
        ELSIF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
           l_num_warning := l_num_warning + 1;
        END IF;

     END IF;

   END IF;
   IF l_num_warning > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
   ELSE
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   END IF;
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   EXCEPTION

 WHEN item_update_not_allowed THEN
      x_update_allowed := 'N';
      --
      -- For item change case, enter both item names.
      FND_MESSAGE.SET_NAME('WSH','WSH_ITEM_SUB_NOT_ALLOWED');
      FND_MESSAGE.SET_TOKEN('ITEM1',WSH_UTIL_CORE.Get_Item_Name(g_cache_detail_rec.inventory_item_id,l_final_org_id));
      FND_MESSAGE.SET_TOKEN('ITEM2',WSH_UTIL_CORE.Get_Item_Name(p_attributes_rec.inventory_item_id,l_final_org_id));
      WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --

    WHEN update_not_allowed THEN
      x_update_allowed := 'N';
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --
    WHEN  mark_reprice_error THEN
   FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
   x_return_status := l_return_status;
   WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
         IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
         END IF;
         --
    WHEN Adjust_Planned_Flag_Err THEN
          FND_MESSAGE.SET_NAME('WSH', 'WSH_ADJUST_PLANNED_FLAG_ERR');
          WSH_UTIL_CORE.add_message(l_return_status,l_module_name);
          x_return_status := l_return_status;

          IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,'Adjust_Planned_Flag_Err exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
             WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:Adjust_Planned_Flag_Err');
          END IF;

    WHEN OTHERS THEN
      IF c_delivery_detail%ISOPEN THEN
         CLOSE c_delivery_detail;
      END IF;

      -- close open cursors as needed
      --ROLLBACK TO before_changes;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_update_allowed := 'N';
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_Schedule',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Change_Schedule;

PROCEDURE Change_Scheduled_Date(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN        VARCHAR2,
        p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2)
IS

cursor c_delivery_detail is
select delivery_detail_id, ship_from_location_id,released_status,move_order_line_id
from wsh_delivery_details
where source_line_id = p_attributes_rec.source_line_id
and source_code = p_source_code;

l_orig_date   DATE;
l_del_det     NUMBER;
l_location_id NUMBER;

--Bug  9226187 : Added local variables
l_status          VARCHAR2(1);
l_mo_line_id      NUMBER;
l_mo_line_rec          INV_Move_Order_PUB.Trolin_Rec_Type;
l_trolin_tbl      INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_old_tbl  INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_out_tbl  INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(3000);


update_not_allowed        EXCEPTION;

/*  H integration: Pricing integration csun  */
i                    NUMBER := 0;
l_det_tab            WSH_UTIL_CORE.Id_Tab_Type ; -- to mark reprice required flag
l_return_status      VARCHAR2(1);
mark_reprice_error   EXCEPTION;


--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_SCHEDULED_DATE';
--
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
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
  END IF;
  --
  --Bug  9226187: Introduced call to the API INV_MOVE_ORDER_PUB.Process_Move_Order_Line
  --              in order to change the Date_Required on MO Line,whenever there is a
  --              change in the Dat_Scheduled on SO Line.
  --              The call should be made only if the delivery detail is 'Released to Warehouse'
  --              and a Move Order line exists.
  IF (p_attributes_rec.date_scheduled <> FND_API.G_MISS_DATE) AND
    (g_cache_detail_rec.date_scheduled <> p_attributes_rec.date_scheduled) THEN


      OPEN c_delivery_detail;

      LOOP

        FETCH c_delivery_detail into l_del_det, l_location_id,l_status,l_mo_line_id;

        EXIT WHEN c_delivery_detail%NOTFOUND;

        IF l_status = 'S' AND l_mo_line_id IS NOT NULL THEN
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'PERFORMING Change Dates '  );
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_TROLIN_UTIL.QUERY_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            l_mo_line_rec := INV_Trolin_Util.Query_Row(p_line_id => l_mo_line_id);
            l_trolin_tbl(1) := l_mo_line_rec;
            l_trolin_old_tbl(1) := l_mo_line_rec;
            l_trolin_tbl(1).OPERATION := INV_GLOBALS.G_OPR_UPDATE;
            l_trolin_tbl(1).date_required :=  p_attributes_rec.date_scheduled;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MOVE_ORDER_PUB.PROCESS_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            INV_MOVE_ORDER_PUB.Process_Move_Order_Line(
            p_api_version_number => 1.0,
            p_commit             => FND_API.G_FALSE,
            x_return_status      => x_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_trolin_tbl         => l_trolin_tbl,
            p_trolin_old_tbl     => l_trolin_old_tbl,
            x_trolin_tbl         => l_trolin_out_tbl);

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'Process_Move_Order_Line returns ERROR');
                END IF;
                RAISE update_not_allowed;
            END IF;

        END IF;   -- of l_status = 'S' and mol is not null

        IF (g_cache_detail_rec.date_scheduled < p_attributes_rec.date_scheduled) THEN
            g_cache_detail_rec.cache_flag := 'N';
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'CHANGE_SCHEDULED_DATE PERFORMING ACTIONS '  );
            END IF;
            --
            i := i+1;
            l_det_tab(i) := l_del_det;
            --
            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'ADDING DELIVERY DETAIL '|| L_DEL_DET || 'TO MARK LIST'  );
            END IF;
            --
            Log_Exception(
                p_delivery_detail_id  => l_del_det,
                p_location_id         => l_location_id,
                p_exception_name      => 'WSH_CHANGE_SCHED_DATE',
                x_return_status       => x_return_status);

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
                RAISE update_not_allowed;
            END IF;
        END IF;
      --End of Changes for bug 9226187
      END LOOP;

      CLOSE c_delivery_detail;

      /*  H integration: Pricing integration csun  */
      IF  l_det_tab.count > 0 THEN
          WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
              p_entity_type => 'DELIVERY_DETAIL',
              p_entity_ids   => l_det_tab,
              x_return_status => l_return_status);
          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              raise mark_reprice_error;
          END IF;
      END IF;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
  EXCEPTION

    WHEN update_not_allowed THEN
      x_update_allowed := 'N';
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --
      RETURN;
    WHEN  mark_reprice_error THEN
   FND_MESSAGE.Set_Name('WSH', 'WSH_REPRICE_REQUIRED_ERR');
   x_return_status := l_return_status;
   WSH_UTIL_CORE.add_message (x_return_status,l_module_name);
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'MARK_REPRICE_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:MARK_REPRICE_ERROR');
   END IF;
   --
    WHEN OTHERS THEN
      -- close open cursors as needed
      IF c_delivery_detail%ISOPEN THEN
         close c_delivery_detail;
      END IF;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_update_allowed := 'N';
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_Scheduled_Date',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Change_Scheduled_Date;


PROCEDURE Change_Sets(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN        VARCHAR2,
        p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2)
IS
-- Bug 2846006
-- Cursor to check if delivery details exist for a source line
-- but different released status
-- Bug 2995052 : Ship Set can be assigned to a order line even if it contains
--               back order and ready to release delivery details.
cursor c_get_released_status is
select count(distinct(decode(released_status,'B','R',released_status)))
from wsh_delivery_details
where source_line_id = p_attributes_rec.source_line_id
and source_code = p_source_code
and released_status NOT IN ('X','D');

-- bug 2153719: ignore released_status 'X' and 'D'
cursor c_get_details is
select delivery_detail_id, released_status, move_order_line_id
from wsh_delivery_details
where source_line_id = p_attributes_rec.source_line_id
and source_code = p_source_code
and released_status NOT IN ('X', 'D')
order by decode(released_status, 'Y', 1, 2);

l_organization_id NUMBER;
l_del_det         NUMBER;
l_status          VARCHAR2(1);
l_status_count    NUMBER;
l_mo_line_id      NUMBER;
l_ship_set        NUMBER;
--l_param_info      WSH_SHIPPING_PARAMETERS.Parameter_Rec_Type;
l_mo_line_rec          INV_Move_Order_PUB.Trolin_Rec_Type;
-- HW OPMCONV. Removed OPM variables

l_trolin_tbl      INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_old_tbl  INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_out_tbl  INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(3000);
update_not_allowed        EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_SETS';

-- HW BUG#:2296620 OPM variables

l_api_version_number CONSTANT NUMBER        := 1.0;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
    WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
    WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
  END IF;

  IF ((p_attributes_rec.ship_set_id <> FND_API.G_MISS_NUM) OR (p_attributes_rec.ship_set_id IS NULL))AND
      (NVL(p_attributes_rec.ship_set_id, FND_API.G_MISS_NUM) <> NVL(g_cache_detail_rec.ship_set_id, FND_API.G_MISS_NUM))
     THEN

    g_cache_detail_rec.cache_flag := 'N';

    IF p_attributes_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
      l_organization_id := g_cache_detail_rec.organization_id;
    ELSE
      l_organization_id := p_attributes_rec.ship_from_org_id;
    END IF;

-- HW BUG#:2296620 Need to check if org is process or discrete
-- HW OPMCONV. Removed branching

    IF NVL(g_param_info.organization_id, -999) <> l_organization_id THEN
      WSH_SHIPPING_PARAMS_PVT.Get(
                      p_organization_id => l_organization_id,
                      x_param_info      => g_param_info,
                      x_return_status   => x_return_status
                      );

      IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
        RAISE update_not_allowed;
      END IF;

    END IF;

    IF g_param_info.enforce_ship_set_and_smc = 'Y' THEN -- Bug 2243033, if not enforced, allow changes regardless...

      OPEN  c_get_details;
      LOOP
      FETCH c_get_details into l_del_det, l_status, l_mo_line_id;
      EXIT WHEN c_get_details%NOTFOUND;

      IF p_attributes_rec.ship_set_id IS NOT NULL
         AND p_attributes_rec.ship_set_id <> NVL(g_cache_detail_rec.ship_set_id, FND_API.G_MISS_NUM) THEN

        -- Planned for Crossdocking scenario, ECO 4497224
        IF l_status = 'S' AND l_mo_line_id IS NULL THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_CHANGE_SET_XDOCK_ERROR');
          FND_MESSAGE.SET_TOKEN('DETAIL', l_del_det);
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'CANNOT CHANGE_SETS : LINE IX CROSSDOCKED'  );
          END IF;
          RAISE update_not_allowed;
        END IF; -- status = 'S' and MOL is null
        -- End of ECO 4497224

        IF l_status = 'S' AND l_mo_line_id IS NOT NULL THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_TROLIN_UTIL.QUERY_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

-- HW BUG#:2296620 Need to branch.
-- HW OPMCONV. Removed branching

          l_mo_line_rec := INV_Trolin_Util.Query_Row(p_line_id => l_mo_line_id);
          IF l_mo_line_rec.quantity_detailed > 0 THEN
            FND_MESSAGE.SET_NAME('WSH','WSH_CHANGE_SET_ERROR');
            FND_MESSAGE.SET_TOKEN('DETAIL', l_del_det);
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'CANNOT CHANGE_SETS : ALLOCATIONS CREATED'  );
            END IF;
            Raise update_not_allowed;
          END IF; -- of discrete quantity_detailed

        END IF;  -- of l_status = 'S' and MOL is not null
-- HW end of BUG#:2296620 changes
      END IF;  --  p_attributes_rec.ship_set_id is NULL

      -- For ensuring the call is for Released to Warehouse only
      -- and not Planned for Crossdocking, Bug 5210926
      IF l_status = 'S' AND l_mo_line_id IS NOT NULL THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'PERFORMING CHANGE_SETS '  );
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_TROLIN_UTIL.QUERY_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
        END IF;

-- HW BUG#:2296620 Need to branch
-- HW OPMCONV. Removed branching
          l_mo_line_rec := INV_Trolin_Util.Query_Row(p_line_id => l_mo_line_id);
          l_trolin_tbl(1) := l_mo_line_rec;
          l_trolin_old_tbl(1) := l_mo_line_rec;
          l_trolin_tbl(1).OPERATION := INV_GLOBALS.G_OPR_UPDATE;
          l_trolin_tbl(1).ship_set_id :=  p_attributes_rec.ship_set_id;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MOVE_ORDER_PUB.PROCESS_MOVE_ORDER_LINE',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          INV_MOVE_ORDER_PUB.Process_Move_Order_Line(
                  p_api_version_number => 1.0,
                  p_commit             => FND_API.G_FALSE,
                  x_return_status      => x_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data,
                  p_trolin_tbl         => l_trolin_tbl,
                  p_trolin_old_tbl     => l_trolin_old_tbl,
                  x_trolin_tbl         => l_trolin_out_tbl);

          IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Process_Move_Order_Line returns ERROR');
            END IF;
            RAISE update_not_allowed;
          END IF; -- of x_return_status for Discrete

      END IF;   -- of l_status = 'S' and mol is not null

      END LOOP;  -- End Loop for all the lines in source line id,c_get_details

-- HW OPM BUG#:2296620 end of changes
      CLOSE c_get_details;

/* shipset is not enforced, allow shipset change regardlessly */
--ELSE
    END IF; -- Bug 2243033

  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION

    WHEN update_not_allowed THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
      x_update_allowed := 'N';
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --
    WHEN OTHERS THEN
      -- close open cursors as needed
      IF c_get_released_status%isopen THEN
         close c_get_released_status;
      END IF;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_update_allowed := 'N';
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_Sets',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Change_Sets;

PROCEDURE Change_Delivery_Group(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN        VARCHAR2,
        p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2)
IS

l_mandatory_flag             VARCHAR2(1) := NULL;
l_shipment_changed_flag      VARCHAR2(1) := NULL;
l_status                     VARCHAR2(1);
l_del_det                    NUMBER;
l_delivery                   NUMBER;
l_parent_det                 NUMBER;
l_location_id                NUMBER;
l_organization_id            NUMBER;
l_intmed_ship_to_org_flag    VARCHAR2(1);
l_sold_to_org_flag           VARCHAR2(1);
l_ship_method_flag           VARCHAR2(1);
l_freight_terms_flag         VARCHAR2(1);
l_fob_flag                   VARCHAR2(1);
l_carrier_flag               VARCHAR2(1);
l_intmed_ship_to_location_id NUMBER;
l_return_status              VARCHAR2(1);
l_num_warning                NUMBER;
l_num_errors                 NUMBER;
l_attr_tab  Wsh_delivery_autocreate.grp_attr_tab_type;
l_group_tab  wsh_delivery_autocreate.grp_attr_tab_type;
l_action_rec wsh_delivery_autocreate.action_rec_type;
l_target_rec wsh_delivery_autocreate.grp_attr_rec_type;
l_matched_entities wsh_util_core.id_tab_type;
l_out_rec wsh_delivery_autocreate.out_rec_type;
l_generic_flag varchar2(1);
l_sm_changed_flag varchar2(1) := 'N';


update_not_allowed        EXCEPTION;

cursor c_del_det (p_source_line_id in number, p_source_code in varchar2)is
select wdd.delivery_detail_id, wdd.ship_from_location_id,
       wda.delivery_id, wda.parent_delivery_detail_id,
       wdd.released_status, wnd.service_level service_level, wnd.mode_of_transport mode_of_transport,
       wnd.carrier_id carrier_id, wnd.ship_method_code ship_method_code
from wsh_delivery_details  wdd, wsh_delivery_assignments_v wda, wsh_new_deliveries wnd
where wdd.source_line_id = p_source_line_id
and wdd.source_code = p_source_code
and wdd.delivery_detail_id = wda.delivery_detail_id
and wda.delivery_id = wnd.delivery_id
UNION
select wdd.delivery_detail_id, wdd.ship_from_location_id,
       wda.delivery_id, wda.parent_delivery_detail_id,
       wdd.released_status, wddp.service_level service_level, wddp.mode_of_transport mode_of_transport,
       wddp.carrier_id carrier_id, wdd.ship_method_code ship_method_code
from wsh_delivery_details  wdd, wsh_delivery_assignments_v wda, wsh_delivery_details wddp
where wdd.source_line_id = p_source_line_id
and wdd.source_code = p_source_code
and wdd.delivery_detail_id = wda.delivery_detail_id
and wda.parent_delivery_detail_id = wddp.delivery_detail_id
and wda.delivery_id is null;

cursor c_get_parent_container(p_child_id in number) is
select parent_delivery_detail_id
from wsh_delivery_assignments_v
where delivery_detail_id = p_child_id;



l_carrier_rec                  WSH_CARRIERS_GRP.Carrier_Service_InOut_Rec_Type;
l_group_index  NUMBER;
l_locked_container NUMBER;
l_parent_container NUMBER;

l_msg_count      NUMBER;
l_msg_data       VARCHAR2(4000);
l_delivery_ids    wsh_util_core.id_tab_type;


l_delivery_info_tab           WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
l_del_out_rec_tab             WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;
l_del_in_rec                  WSH_DELIVERIES_GRP.Del_In_Rec_Type;

l_detail_info_tab            WSH_GLBL_VAR_STRCT_GRP.Delivery_Details_Attr_Tbl_Type;
l_detail_in_rec              WSH_GLBL_VAR_STRCT_GRP.detailInRecType;
l_detail_out_rec             WSH_GLBL_VAR_STRCT_GRP.detailOutRecType;


l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_DELIVERY_GROUP';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
    END IF;
    --
    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    IF  p_attributes_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
        l_attr_tab(1).organization_id := g_cache_detail_rec.organization_id;
        l_attr_tab(1).ship_from_location_id := g_cache_detail_rec.organization_id;
    ELSE
        l_attr_tab(1).organization_id := p_attributes_rec.ship_from_org_id;
        l_attr_tab(1).ship_from_location_id := p_attributes_rec.ship_from_org_id;
    END IF;
    l_attr_tab(2).organization_id := g_cache_detail_rec.organization_id;
    l_attr_tab(2).ship_from_location_id := g_cache_detail_rec.organization_id;

    IF p_attributes_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN

       l_attr_tab(1).ship_to_location_id := g_cache_detail_rec.ship_to_site_use_id;
    ELSE
       l_attr_tab(1).ship_to_location_id := p_attributes_rec.ship_to_org_id;
    END IF;
    l_attr_tab(2).ship_to_location_id := g_cache_detail_rec.ship_to_site_use_id;


    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'p_attributes_rec.intmed_ship_to_org_id',p_attributes_rec.intmed_ship_to_org_id);
    END IF;

    IF p_attributes_rec.intmed_ship_to_org_id = FND_API.G_MISS_NUM THEN

       l_intmed_ship_to_location_id :=  g_cache_detail_rec.intmed_ship_to_location_id;

    ELSIF (p_attributes_rec.intmed_ship_to_org_id IS NOT NULL) THEN
       WSH_UTIL_CORE.GET_LOCATION_ID('CUSTOMER SITE',
                                    p_attributes_rec.intmed_ship_to_org_id,
                                    l_intmed_ship_to_location_id,
                                    x_return_status);
     /* Bug Fix 2852545 passed x_return_status instead of l_return_status to api_post_call */
        wsh_util_core.api_post_call(p_return_status =>x_return_status,
                               x_num_warnings     =>l_num_warning,
                               x_num_errors       =>l_num_errors);

    END IF;

    l_attr_tab(1).intmed_ship_to_location_id := l_intmed_ship_to_location_id;
    l_attr_tab(2).intmed_ship_to_location_id := g_cache_detail_rec.intmed_ship_to_location_id;

    IF p_attributes_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
       l_attr_tab(1).customer_id :=  g_cache_detail_rec.customer_id;
    ELSE
       l_attr_tab(1).customer_id := p_attributes_rec.sold_to_org_id;

       IF (NVL(p_attributes_rec.sold_to_org_id, FND_API.G_MISS_NUM) <> NVL(g_cache_detail_rec.customer_id, FND_API.G_MISS_NUM)) THEN

          l_shipment_changed_flag := 'Y';

       END IF;

    END IF;
    l_attr_tab(2).customer_id := g_cache_detail_rec.customer_id;


    IF  p_attributes_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
         l_attr_tab(1).freight_terms_code := g_cache_detail_rec.freight_terms_code;
    ELSE
         l_attr_tab(1).freight_terms_code := p_attributes_rec.freight_terms_code;

         IF (NVL(p_attributes_rec.freight_terms_code, FND_API.G_MISS_CHAR) <> NVL(g_cache_detail_rec.freight_terms_code, FND_API.G_MISS_CHAR)) THEN

            l_shipment_changed_flag := 'Y';

         END IF;

    END IF;
    l_attr_tab(2).freight_terms_code := g_cache_detail_rec.freight_terms_code;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'freight_terms_code 1:  '||p_attributes_rec.freight_terms_code  );
        WSH_DEBUG_SV.logmsg(l_module_name, 'freight_terms_code 2:  '||g_cache_detail_rec.freight_terms_code  );
    END IF;

    IF p_attributes_rec.fob_code = FND_API.G_MISS_CHAR THEN
       l_attr_tab(1).fob_code := g_cache_detail_rec.fob_code;
    ELSE
       l_attr_tab(1).fob_code := p_attributes_rec.fob_code;

       IF (NVL(p_attributes_rec.fob_code, FND_API.G_MISS_CHAR) <> NVL(g_cache_detail_rec.fob_code, FND_API.G_MISS_CHAR)) THEN

          l_shipment_changed_flag := 'Y';

       END IF;

    END IF;
    l_attr_tab(2).fob_code := g_cache_detail_rec.fob_code;

    IF ((p_attributes_rec.shipping_method_code <> FND_API.G_MISS_CHAR) OR (p_attributes_rec.shipping_method_code IS NULL)) AND
       (NVL(p_attributes_rec.shipping_method_code, FND_API.G_MISS_CHAR) <> NVL(g_cache_detail_rec.ship_method_code,FND_API.G_MISS_CHAR)) THEN

        l_shipment_changed_flag := 'Y';
        l_sm_changed_flag := 'Y';

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'l_shipment_changed_flag:  '||l_shipment_changed_flag  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'p_attributes_rec.shipping_method_code: '||p_attributes_rec.shipping_method_code);
           WSH_DEBUG_SV.logmsg(l_module_name, 'g_cache_detail_rec.ship_method_code: '||g_cache_detail_rec.ship_method_code);
        END IF;
        l_carrier_rec.ship_method_code := p_attributes_rec.shipping_method_code;

       -- 4673778
       l_carrier_rec.generic_flag := NULL;  -- initializing
       IF (p_attributes_rec.shipping_method_code is NOT NULL) THEN
        WSH_CARRIERS_GRP.get_carrier_service_mode(
                         p_carrier_service_inout_rec => l_carrier_rec,
                         x_return_status => x_return_status);
       -- 4673778
        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'After get_carrier_service_mode'|| x_return_status);
           WSH_DEBUG_SV.logmsg(l_module_name, 'l_carrier_rec.genflag#car-id#sm-code#mode-of-tpt#svc-lvl: '||
                 l_carrier_rec.generic_flag||'#'|| l_carrier_rec.carrier_id||'#'||
                 l_carrier_rec.ship_method_code||'#'|| l_carrier_rec.mode_of_transport||'#'||
                 l_carrier_rec.service_level);
        END IF;
       END IF;

       -- 4673778
        IF nvl(l_carrier_rec.generic_flag, 'N') = 'Y' THEN
           l_attr_tab(1).carrier_id := NULL;
           l_attr_tab(1).ship_method_code := NULL;
        ELSE
           l_attr_tab(1).carrier_id := l_carrier_rec.carrier_id;
           l_attr_tab(1).ship_method_code := l_carrier_rec.ship_method_code;
        END IF;
        l_attr_tab(1).mode_of_transport := l_carrier_rec.mode_of_transport;
        l_attr_tab(1).service_level := l_carrier_rec.service_level;

    ELSE

        -- If the ship method has not changed, we can simply compare the current grouping attributes
        -- of the line with the new attributes of the line to see whether they need to be unassigned
        -- or not.

        l_action_rec.action := 'MATCH_GROUPS';
        l_action_rec.check_single_grp := 'Y';


        WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab => l_group_tab,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => x_return_status);


        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

           l_mandatory_flag := 'N';

        ELSIF  l_out_rec.single_group = 'N' THEN

           l_mandatory_flag := 'Y';

        ELSE

           RAISE update_not_allowed;

        END IF;

    END IF;



    FOR dd IN c_del_det(p_source_line_id => p_attributes_rec.source_line_id, p_source_code  => p_source_code)  LOOP

      IF l_sm_changed_flag = 'Y' THEN

        -- Bug 3292364.
        -- If the ship method has changed, we need to compare the new ship method components against
        -- the ship method components of the delivery/container that each line is assigned to, to check
        -- if the line needs to be unassigned or not.

        l_attr_tab(2).carrier_id := dd.carrier_id;
        l_attr_tab(2).mode_of_transport := dd.mode_of_transport;
        l_attr_tab(2).service_level := dd.service_level;
        l_attr_tab(2).ship_method_code := dd.ship_method_code;

        --
        l_action_rec.action := 'MATCH_GROUPS';
        l_action_rec.check_single_grp := 'Y';


        WSH_DELIVERY_AUTOCREATE.Find_Matching_Groups(p_attr_tab => l_attr_tab,
                        p_action_rec => l_action_rec,
                        p_target_rec => l_target_rec,
                        p_group_tab => l_group_tab,
                        x_matched_entities => l_matched_entities,
                        x_out_rec => l_out_rec,
                        x_return_status => x_return_status);

        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'return status after Find_Matching_Groups:  '||x_return_status  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'l_group_tab.count:  '||l_group_tab.count  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'single group flag:  '|| l_out_rec.single_group  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'service_level:  '||l_group_tab(l_group_tab.first).service_level  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'mode_of_transport:  '||l_group_tab(l_group_tab.first).mode_of_transport  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'carrier_id:  '||l_group_tab(l_group_tab.first).carrier_id  );
           WSH_DEBUG_SV.logmsg(l_module_name, 'ship_method_code:   '||l_group_tab(l_group_tab.first).carrier_id  );
        END IF;

        IF x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN

           l_mandatory_flag := 'N';

        ELSIF  l_out_rec.single_group = 'N' THEN

           l_mandatory_flag := 'Y';

        ELSE

           RAISE update_not_allowed;

        END IF;

        l_group_index :=  l_group_tab.FIRST;

      END IF;

      IF l_mandatory_flag = 'Y' THEN

        IF p_wms_flag = 'Y' THEN

          IF dd.released_status = 'Y' THEN

            FND_MESSAGE.SET_NAME('WSH', 'WSH_WMS_UPDATE_NOT_ALLOWED');
            WSH_UTIL_CORE.Add_Message(x_return_status,l_module_name);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            RAISE update_not_allowed;

          END IF;

        END IF;



        IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE CHANGE_DELIVERY_GROUP : DO ACTIONS '  );
        END IF;
          --

        IF dd.delivery_id  IS NOT NULL THEN

            WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Delivery(
                              p_detail_id => dd.delivery_detail_id,
                              p_validate_flag => 'N',
                              x_return_status => x_return_status);

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

              RAISE update_not_allowed;

            END IF;

            Log_Exception(
             p_delivery_detail_id  => dd.delivery_detail_id,
             p_location_id         => dd.ship_from_location_id,
             p_exception_name      => 'WSH_CHANGE_DEL_GROUP',
             p_entity_name         => 'WSH_DELIVERY',
             p_entity_id           => dd.delivery_id,
             x_return_status       => x_return_status);

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

              RAISE update_not_allowed;

            END IF;
            -- csun Pack J deliveryMerge
            l_delivery_ids.delete;
            l_delivery_ids(1) := dd.delivery_id;
            WSH_NEW_DELIVERY_ACTIONS.Adjust_Planned_Flag(
               p_delivery_ids          => l_delivery_ids,
               p_caller                => 'WSH_DLMG',
               p_force_appending_limit => 'N',
               p_call_lcss             => 'Y',
               p_event                 => NULL,
               x_return_status         => l_return_status);

            IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
               RAISE update_not_allowed;
            ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
            ELSE
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            END IF;


          END IF;

          IF dd.parent_delivery_detail_id IS NOT NULL THEN

            WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont(
                              p_detail_id => dd.delivery_detail_id,
                              p_validate_flag => 'N',
                              x_return_status => x_return_status);

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

              RAISE update_not_allowed;

            END IF;

            Log_Exception(
             p_delivery_detail_id  => dd.delivery_detail_id,
             p_location_id         => dd.ship_from_location_id,
             p_exception_name      => 'WSH_CHANGE_DEL_GROUP',
             p_entity_name         => 'WSH_CONTAINER',
             p_entity_id           => dd.parent_delivery_detail_id,
             x_return_status       => x_return_status);

            IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

              RAISE update_not_allowed;

            END IF;

          END IF;

      ELSE --  IF l_mandatory_flag = 'N'


         IF dd.delivery_id is not null and l_sm_changed_flag = 'Y' THEN
         -- Bug 3292364
         -- Even if the line stays on the delivery, but the shipmethod has changed, make sure the
         -- delivery is in sync with the line's shipmethod components.

             IF l_group_tab(l_group_index).service_level IS NOT NULL
             OR l_group_tab(l_group_index).mode_of_transport IS NOT NULL
             OR l_group_tab(l_group_index).carrier_id IS NOT NULL THEN


                WSH_NEW_DELIVERIES_PVT.Table_to_Record(
                                            p_delivery_id => dd.delivery_id,
                                            x_delivery_rec => l_delivery_info_tab(1),
                                            x_return_status => x_return_status);

                IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                   RAISE update_not_allowed;
                END IF;


                IF l_group_tab(l_group_index).service_level IS NOT NULL THEN
                   l_delivery_info_tab(1).service_level := l_group_tab(l_group_index).service_level;
                END IF;
                IF l_group_tab(l_group_index).carrier_id IS NOT NULL THEN
                   l_delivery_info_tab(1).carrier_id := l_group_tab(l_group_index).carrier_id;
                END IF;
                IF l_group_tab(l_group_index).mode_of_transport IS NOT NULL THEN
                   l_delivery_info_tab(1).mode_of_transport := l_group_tab(l_group_index).mode_of_transport;
                END IF;
                IF l_group_tab(l_group_index).ship_method_code IS NOT NULL THEN
                   l_delivery_info_tab(1).ship_method_code := l_group_tab(l_group_index).ship_method_code;
                END IF;

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'updating delivery:  '||dd.delivery_id  );
                END IF;

                l_del_in_rec.caller      := 'WSH';
                l_del_in_rec.action_code := 'UPDATE';

                WSH_INTERFACE_GRP.Create_Update_Delivery(p_api_version_number => 1.0,
                                                         p_init_msg_list      => FND_API.G_FALSE,
                                                         p_commit             => FND_API.G_FALSE,
                                                         p_in_rec             => l_del_in_rec,
                                                         p_rec_attr_tab       => l_delivery_info_tab,
                                                         x_del_out_rec_tab    => l_del_out_rec_tab,
                                                         x_return_status      => x_return_status,
                                                         x_msg_count          => l_msg_count,
                                                         x_msg_data           => l_msg_data);



                IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                   RAISE update_not_allowed;
                END IF;

             END IF;

         END IF;


         IF  dd.parent_delivery_detail_id IS NOT NULL THEN

             IF l_shipment_changed_flag = 'Y' THEN
                Log_Exception(
                   p_delivery_detail_id  => dd.delivery_detail_id,
                   p_location_id         => dd.ship_from_location_id,
                   p_exception_name      => 'WSH_INVALID_PACKING',
                   p_entity_name         => 'WSH_CONTAINER',
                   p_entity_id           => dd.parent_delivery_detail_id,
                   x_return_status       => x_return_status);

                IF (x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)) THEN

                  RAISE update_not_allowed;

                END IF;


            END IF;
            IF l_sm_changed_flag = 'Y' THEN
            -- Bug 3292364
            -- Even if the line stays on the container, but the shipmethod has changed, make sure the
            -- container is in sync with the line's shipmethod components.

                IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name, 'locking container:  '||dd.parent_delivery_detail_id  );
                END IF;



                IF l_group_tab(l_group_index).service_level IS NOT NULL
                OR l_group_tab(l_group_index).mode_of_transport IS NOT NULL
                OR l_group_tab(l_group_index).carrier_id IS NOT NULL THEN


                   WSH_DELIVERY_DETAILS_PKG.Table_to_Record(
                                            p_delivery_detail_id => dd.parent_delivery_detail_id,
                                            x_delivery_detail_rec => l_detail_info_tab(1),
                                            x_return_status => x_return_status);

                   IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                      RAISE update_not_allowed;
                   END IF;

                   IF l_group_tab(l_group_index).service_level IS NOT NULL THEN
                      l_detail_info_tab(1).service_level := l_group_tab(l_group_index).service_level;
                   END IF;
                   IF l_group_tab(l_group_index).carrier_id IS NOT NULL THEN
                      l_detail_info_tab(1).carrier_id := l_group_tab(l_group_index).carrier_id;
                   END IF;
                   IF l_group_tab(l_group_index).mode_of_transport IS NOT NULL THEN
                      l_detail_info_tab(1).mode_of_transport := l_group_tab(l_group_index).mode_of_transport;
                   END IF;
                   IF l_group_tab(l_group_index).ship_method_code IS NOT NULL THEN
                      l_detail_info_tab(1).ship_method_code := l_group_tab(l_group_index).ship_method_code;
                   END IF;

                   IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name, 'updating container:  '||dd.parent_delivery_detail_id  );
                   END IF;

                   l_detail_in_rec.caller := 'WSH_USA';
                   l_detail_in_rec.action_code := 'UPDATE';

                   WSH_INTERFACE_GRP.Create_Update_Delivery_Detail(
                      p_api_version_number      => 1.0,
                      p_init_msg_list          => FND_API.G_FALSE,
                      p_commit                => FND_API.G_FALSE,
                      x_return_status         => x_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data,
                      p_detail_info_tab       => l_detail_info_tab,
                      p_IN_rec                => l_detail_in_rec,
                      x_OUT_rec               => l_detail_out_rec);

                   IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                      RAISE update_not_allowed;
                   END IF;

                   -- The GRP API does not cascade the changes upwards.
                   -- So we have to make sure to update the hierarchy.

                   OPEN c_get_parent_container(dd.parent_delivery_detail_id);
                   FETCH c_get_parent_container INTO l_parent_container;
                   CLOSE c_get_parent_container;


                   IF l_parent_container IS NOT NULL THEN


                      WSH_CONTAINER_ACTIONS.Update_Cont_Hierarchy(
                                         p_del_detail_id => dd.parent_delivery_detail_id,
                                         p_delivery_id => NULL,
                                         p_container_instance_id => l_parent_container,
                                         x_return_status => x_return_status);

                      IF x_return_status IN (WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR, WSH_UTIL_CORE.G_RET_STS_ERROR) THEN
                         RAISE update_not_allowed;
                      END IF;

                   END IF;

                END IF;

            END IF;

         END IF;

      END IF; --  IF l_mandatory_flag = 'Y'


    END LOOP;

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
  EXCEPTION

    WHEN update_not_allowed THEN
      x_update_allowed := 'N';
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'UPDATE_NOT_ALLOWED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UPDATE_NOT_ALLOWED');
      END IF;
      --
      RETURN;
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
       IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name,'G_EXC_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
       IF l_debug_on THEN
           wsh_debug_sv.logmsg(l_module_name,'G_EXC_UNEXPECTED_ERROR');
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
    WHEN OTHERS THEN
      -- close open cursors as needed
      IF c_del_det%ISOPEN THEN
        CLOSE c_del_det;
      END IF;
      IF c_get_parent_container%ISOPEN THEN
        CLOSE c_get_parent_container;
      END IF;
      x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      x_update_allowed := 'N';
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_Delivery_Group',l_module_name);
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END Change_Delivery_Group;


-- Bug 2181132

PROCEDURE Change_Ship_Tolerance(
  p_attributes_rec    IN        WSH_INTERFACE.ChangedAttributeRecType,
        p_source_code       IN        VARCHAR2,
        p_wms_flag          IN        VARCHAR2,
  x_update_allowed    IN OUT NOCOPY     VARCHAR2,
  x_return_status     OUT NOCOPY        VARCHAR2)
IS

-- this is because source_line_set_id may or may not be populated
-- in that case match using source line id
-- query is driven by released status and souce header id.
-- line_set_id can be NULL or MISS_NUM also , when we need to match
-- using source_line_id
CURSOR c_get_released_status is
SELECT delivery_detail_id
  FROM wsh_delivery_details
 WHERE (source_line_id = p_attributes_rec.source_line_id
OR source_line_set_id = p_attributes_rec.source_line_set_id)
   AND source_code = p_source_code
   AND source_header_id = p_attributes_rec.source_header_id
   AND released_status IN ('Y', 'C')
   AND container_flag = 'N'
   AND rownum = 1;

l_delivery_detail_id NUMBER;
update_not_allowed  EXCEPTION;

-- assuming that OM does not allow changes for tolerance in Line Set
-- do i need source header id also in the cursor??
-- Cases        Tol Value    Cached Value
--                Null          Null
--                Null          Not Null
--                Not Null      Null
--                Not Null      Not Null (same)
--                Not Null      Not Null (different)

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHANGE_SHIP_TOLERANCE';
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
        WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_WMS_FLAG',P_WMS_FLAG);
        WSH_DEBUG_SV.log(l_module_name,'X_UPDATE_ALLOWED',X_UPDATE_ALLOWED);
    END IF;

-- need to write for both tolerance above and below
-- 2181132
-- the code exists in WSHUSAAB.Update_Attributes to update the tolerance values
-- ******************
-- Consult with PM if the tolerance check is Required or not.
-- ******************

    IF (
        (((p_attributes_rec.ship_tolerance_above <> FND_API.G_MISS_NUM)
         OR (p_attributes_rec.ship_tolerance_above IS NULL))
         AND
        NVL(p_attributes_rec.ship_tolerance_above, FND_API.G_MISS_NUM) <>
          NVL(g_cache_detail_rec.ship_tolerance_above, FND_API.G_MISS_NUM))
       OR
        (((p_attributes_rec.ship_tolerance_below <> FND_API.G_MISS_NUM)
         OR (p_attributes_rec.ship_tolerance_below IS NULL))
         AND
        NVL(p_attributes_rec.ship_tolerance_below, FND_API.G_MISS_NUM) <>
          NVL(g_cache_detail_rec.ship_tolerance_below, FND_API.G_MISS_NUM))
       ) THEN

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Tolerance Values are different');
      END IF;

      -- use cursor to determine if the values can be changed
      OPEN c_get_released_status;
      FETCH c_get_released_status
       INTO l_delivery_detail_id;
      IF c_get_released_status%NOTFOUND THEN
        l_delivery_detail_id := NULL;
      END IF;

      CLOSE c_get_released_status;

      IF l_delivery_detail_id IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_TOL_NOT_ALLOWED');
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.Add_Message(x_return_status);
        RAISE update_not_allowed;
      END IF;

    END IF;

    x_update_allowed := 'Y';
    x_return_status  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Update Allowed'||x_update_allowed);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

EXCEPTION
  WHEN update_not_allowed THEN
    x_return_status  := WSH_UTIL_CORE.G_RET_STS_ERROR;
    x_update_allowed := 'N';

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

    RETURN;

  WHEN OTHERS THEN
    -- close open cursors as needed
    x_return_status  := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    x_update_allowed := 'N';
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_USA_CATEGORIES_PVT.Change_Ship_Tolerance',l_module_name);
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --

END Change_Ship_Tolerance;

END WSH_USA_CATEGORIES_PVT;

/
