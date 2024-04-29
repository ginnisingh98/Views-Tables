--------------------------------------------------------
--  DDL for Package Body WSH_PO_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PO_INTEGRATION_GRP" AS
/* $Header: WSHPOGPB.pls 120.6 2005/08/22 11:43:13 rlanka noship $ */
--
 G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_PO_INTEGRATION_GRP';
--


-- Start of comments
-- API name : check_purge
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API on receiving a set of header IDs,determines
--	      whether they are eligible for purging or not by checking
--	      for pending transactions against them and appropriately
--	      sets a flag.
-- Parameters :
-- IN:
--	p_api_version_number   IN NUMBER
--	p_init_msg_list	       IN VARCHAR2
--	p_commit	       IN VARCHAR2
--	p_in_rec	       IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype
--         A table of records which conatins Header Ids of lines as one of its field.
-- IN OUT:
--
-- OUT:
--	x_msg_count	OUT NOCOPY NUMBER
--	x_msg_data	OUT NOCOPY VARCHAR2
--	x_out_rec	OUT NOCOPY WSH_PO_INTG_TYPES_GRP.purge_out_rectype
--         A table of records which contains the flag field. For each record of the i/p
--         p_in_rec there is a corresponding entry in this table of records.
--         This field is set to 'Y' if there are no pending transactions against the
--         header ID and set to 'N' if there are pending transactions against this
--         header ID .
--	x_return_status OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE check_purge(
	---- Standard parameters
	p_api_version_number   IN NUMBER,
	p_init_msg_list	       IN VARCHAR2,
	p_commit	       IN VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2,
        -- procedure specific parameters
	p_in_rec	       IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype,
	x_out_rec	OUT NOCOPY WSH_PO_INTG_TYPES_GRP.purge_out_rectype
	) AS

l_purge NUMBER := 0;
l_api_version_number NUMBER := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'check_purge';
l_return_status	       VARCHAR2(1);
l_extend_count	NUMBER;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CHECK_PURGE';
--
BEGIN


x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
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
    WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
    WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.header_ids.COUNT',p_in_rec.header_ids.COUNT);
END IF;
--
IF NOT FND_API.compatible_api_call(
  l_api_version_number,
  p_api_version_number,
  l_api_name,
  G_PKG_NAME) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.to_boolean(p_init_msg_list)  THEN
  FND_MSG_PUB.initialize;
END IF;


-- Loop goes through all the header IDs present in p_in_rec.
FOR i IN 1..p_in_rec.header_ids.COUNT LOOP
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PO_CMG_PVT.CHECK_PENDING_TXNS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --

  -- A function call to determine for checking pending transactions.
  -- If the function returns
  --    0 -> implies no pending transactions.
  --    1 -> implies pending transactions.
  l_purge := WSH_PO_CMG_PVT.check_pending_txns(p_in_rec.header_ids(i),NULL,NULL,NULL);
  IF l_purge = 0 THEN
    x_out_rec.purge_allowed(i) := 'Y';
  ELSIF  l_purge = 1 THEN
    x_out_rec.purge_allowed(i) := 'N';
  END IF;
END LOOP;


FND_MSG_PUB.Count_And_Get(
  p_count  => x_msg_count,
  p_data  =>  x_msg_data,
  p_encoded => FND_API.G_FALSE);

IF FND_API.TO_BOOLEAN(p_commit) THEN
  COMMIT WORK;
END IF;



--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.Default_Handler('WSH_PO_INTEGRATION_GRP.check_purge',l_module_name);
    --
    -- Debug Statements
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END check_purge;



-- Start of comments
-- API name : purge
-- Type     : Public
-- Pre-reqs : None.
-- Function : This API receives a set of header IDs, the API changes
--    	      the status of the corresponding delivery detail IDs to
--	      'Purge(P)' status after unassigning them from their
--	      respective deliveries.
-- Parameters :
-- IN:
--	p_api_version_number   IN NUMBER
--	p_init_msg_list	       IN VARCHAR2
--	p_commit	       IN VARCHAR2
--      p_in_rec               IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype
--        A table of records which contains the header ID to be purged.
-- IN OUT:
--
-- OUT:
--	x_return_status OUT NOCOPY VARCHAR2
--	x_msg_count	OUT NOCOPY NUMBER
--	x_msg_data	OUT NOCOPY VARCHAR2
-- Version : 1.0
-- Previous version 1.0
-- Initial version 1.0
-- End of comments


PROCEDURE purge(
	---- Standard parameters
	p_api_version_number   IN NUMBER,
	p_init_msg_list	       IN VARCHAR2,
	p_commit	       IN VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count	OUT NOCOPY NUMBER,
	x_msg_data	OUT NOCOPY VARCHAR2,
        -- procedure specific parameters
        p_in_rec               IN  WSH_PO_INTG_TYPES_GRP.purge_in_rectype
        ) IS

l_api_version_number NUMBER := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'purge';
l_return_status  VARCHAR2(1);

l_detail_tab WSH_UTIL_CORE.id_tab_type;  -- DBI Project
l_dbi_rs            VARCHAR2(1);         -- DBI Project

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE';
--
BEGIN

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
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
    WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
    WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.header_ids.count',p_in_rec.header_ids.count);
END IF;
--
SAVEPOINT PURGE_PVT;

IF NOT FND_API.compatible_api_call(
  l_api_version_number,
  p_api_version_number,
  l_api_name,
  G_PKG_NAME) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF FND_API.to_boolean(p_init_msg_list)  THEN
  FND_MSG_PUB.initialize;
END IF;


--updates the status of all i/p lines to 'P' (purge).
FORALL i IN p_in_rec.header_ids.FIRST..p_in_rec.header_ids.LAST
  UPDATE wsh_delivery_details
  SET released_status = 'P'
  where source_header_id = p_in_rec.header_ids(i)
        AND source_code = 'PO'
  RETURNING delivery_detail_id BULK COLLECT INTO l_detail_tab;

  --
  -- DBI Project
  -- Update of wsh_delivery_details where released_status
  -- are changed, call DBI API after the update.
  -- This API will also check for DBI Installed or not
  IF l_debug_on THEN
   WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Delivery Details l_detail_tab count : ',l_detail_tab.COUNT);
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
  Rollback to PURGE_PVT;
  -- just pass this return status to caller API
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'DBI API Returned Unexpected error '||x_return_status);
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    return;
  END IF;
  -- End of Code for DBI Project
  --

FND_MSG_PUB.Count_And_Get(
  p_count  => x_msg_count,
  p_data  =>  x_msg_data,
  p_encoded => FND_API.G_FALSE);

 IF FND_API.TO_BOOLEAN(p_commit) THEN
   COMMIT WORK;
 END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK TO PURGE_PVT;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.ADD_MESSAGE(l_return_status,l_module_name);
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_INTEGRATION_GRP.Purge',l_module_name);

	     --
	     -- Debug Statements
	     --
	     IF l_debug_on THEN
	         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	     END IF;
	     --
END purge;


--======================================================================
-- PROCEDURE : vendor_merge
--
-- COMMENT   :
-- HISTORY   : Created the API.
--======================================================================

PROCEDURE vendor_merge(
  P_api_version_number   IN NUMBER,
  P_init_msg_list IN VARCHAR2,
  P_commit IN VARCHAR2,
  X_return_status OUT NOCOPY VARCHAR2,
  X_msg_count OUT NOCOPY NUMBER,
  X_msg_data OUT NOCOPY VARCHAR2,
  P_in_rec IN WSH_PO_INTG_TYPES_GRP.merge_in_rectype,
  X_out_rec OUT NOCOPY WSH_PO_INTG_TYPES_GRP.merge_out_rectype) IS

l_api_version_number NUMBER := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'vendor_merge';
l_return_status  VARCHAR2(1);
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VENDOR_MERGE';
--
BEGIN
  --
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
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
      WSH_DEBUG_SV.log(l_module_name,'P_API_VERSION_NUMBER',P_API_VERSION_NUMBER);
      WSH_DEBUG_SV.log(l_module_name,'P_INIT_MSG_LIST',P_INIT_MSG_LIST);
      WSH_DEBUG_SV.log(l_module_name,'P_COMMIT',P_COMMIT);
  END IF;
  --
  IF NOT FND_API.compatible_api_call(
    l_api_version_number,
    p_api_version_number,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --
  IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get(
   p_count  => x_msg_count,
   p_data  =>  x_msg_data,
   p_encoded => FND_API.G_FALSE);
  --
  IF FND_API.TO_BOOLEAN(p_commit) THEN
   COMMIT WORK;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    WSH_UTIL_CORE.ADD_MESSAGE(l_return_status,l_module_name);
    WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_INTEGRATION_GRP.VENDOR_MERGE',l_module_name);
    --
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    --
END vendor_merge;


--
-- Pre-reqs	: None
--
-- Parameters
--	p_api_version_number    known api version error number
--      p_init_msg_list         FND_API.G_TRUE to reset list
--	p_commit		indicates whether to commit or not.
--      x_return_status         return status
--      x_msg_count             number of messages in the list
--      x_msg_data              text of messages
--	p_in_rec 		Input record structure that holds the
--			        routing response number
--	x_out_rec 		Output record structure that holds info.
--			        whether delivery info. has changed or not.
--
-- Purpose	: This procedure is used to determine whether delivery characteristics have
--		  changed since the time the routing response was generated.
--		  This API checks the last_update_date on all the tables related to the
--		  routing response and if any of the dates is greater than the
--		  last_update_date from WSH_INBOUND_TXN_HISTORY, this API
--		  returns TRUE, else it returns FALSE
--
-- Version : 1.0
--
PROCEDURE HasDeliveryInfoChanged(
  P_api_version_number   IN NUMBER,
  P_init_msg_list 	 IN VARCHAR2,
  P_commit 		 IN VARCHAR2,
  x_return_status 	 OUT NOCOPY VARCHAR2,
  x_msg_count 		 OUT NOCOPY NUMBER,
  x_msg_data 		 OUT NOCOPY VARCHAR2,
  P_in_rec 		 IN WSH_PO_INTG_TYPES_GRP.delInfo_in_rectype,
  x_out_rec 		 OUT NOCOPY WSH_PO_INTG_TYPES_GRP.delInfo_out_rectype)
IS
  --
  CURSOR c_GetDelId(p_respNum VARCHAR2) IS
  SELECT wth.shipment_header_id, wth.last_update_date, wnd.last_update_date
  FROM   wsh_inbound_txn_history wth, wsh_new_deliveries wnd
  WHERE  receipt_number like p_respNum
  AND    shipment_header_id = wnd.delivery_id
  AND    transaction_type = 'ROUTING_RESPONSE'
  ORDER BY NVL(revision_number, -99) DESC;
  --
  CURSOR c_GetLastUpdateDates(p_delId NUMBER) IS
  SELECT MAX(wda.last_update_date), MAX(wdd.last_update_date)
  FROM wsh_delivery_assignments_v wda,wsh_delivery_details wdd
  WHERE wdd.delivery_detail_id = wda.delivery_detail_id
  AND   wda.delivery_id = p_delId;
  --
  -- This cursor gets the dates for the initial pickup location
  --
  CURSOR c_GetPTripLastUpdateDate(p_delId NUMBER) IS
  SELECT wts.last_update_date, wdl.last_update_date, wt.last_update_date
  FROM   wsh_new_deliveries wnd,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts,
         wsh_trips wt
  WHERE  wnd.delivery_id = p_delId
  AND    wnd.delivery_id = wdl.delivery_id
  AND    wdl.pick_up_stop_id = wts.stop_id
  AND    wnd.initial_pickup_location_id = wts.stop_location_id
  AND    wts.trip_id = wt.trip_id
  AND    wnd.shipping_control='BUYER';
  --
  -- This cursor gets the dates for the ultimate dropoff location
  --
  CURSOR c_GetDTripLastUpdateDate(p_delId NUMBER) IS
  SELECT wts.last_update_date, wdl.last_update_date, wt.last_update_date
  FROM   wsh_new_deliveries wnd,
         wsh_delivery_legs wdl,
         wsh_trip_stops wts,
         wsh_trips wt
  WHERE  wnd.delivery_id = p_delId
  AND    wnd.delivery_id = wdl.delivery_id
  AND    wdl.pick_up_stop_id = wts.stop_id
  AND    wnd.ultimate_dropoff_location_id = wts.stop_location_id
  AND    wts.trip_id = wt.trip_id
  AND    wnd.shipping_control='BUYER';
  --
  CURSOR c_GetCarrierLastUpdateDate(p_delId NUMBER) IS
  SELECT MAX(wcs.last_update_date), MAX(wocs.last_update_date)
  FROM   wsh_new_deliveries wnd, wsh_carrier_sites wcs,
         wsh_org_carrier_sites wocs
  WHERE wnd.organization_id = wocs.organization_id
  AND   wcs.carrier_id = wnd.carrier_id
  AND   wnd.delivery_id = p_delId;
  --
  l_deliveryId		WSH_INBOUND_TXN_HISTORY.shipment_header_id%TYPE;
  l_wndUpdateDate	DATE;
  l_wdaUpdateDate	DATE;
  l_wddUpdateDate	DATE;
  l_wdlUpdateDate	DATE;
  l_wtsUpdateDate	DATE;
  l_wtUpdateDate	DATE;
  l_wdlUpdateDate1	DATE;
  l_wtsUpdateDate1	DATE;
  l_wtUpdateDate1	DATE;
  l_ibUpdateDate	DATE;
  l_wcsUpdateDate	DATE;
  l_wocsUpdateDate	DATE;
  l_changed		BOOLEAN := FALSE;
  --
  l_api_version_number	CONSTANT NUMBER := 1.0;
  l_api_name      	CONSTANT VARCHAR2(30) := 'HasDeliveryInfoChanged';
  l_return_status	VARCHAR2(1);
  --
  l_debug_on 	BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'HasDeliveryInfoChanged';
  --
BEGIN
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF l_debug_on IS NULL THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_api_version_number',P_API_VERSION_NUMBER);
    WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',P_INIT_MSG_LIST);
    WSH_DEBUG_SV.log(l_module_name,'p_commit',P_COMMIT);
    WSH_DEBUG_SV.log(l_module_name,'Routing Response Number', p_in_rec.routingRespNum);
  END IF;
  --
  IF NOT FND_API.compatible_api_call(
    l_api_version_number,
    p_api_version_number,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --
  IF FND_API.to_boolean(p_init_msg_list)  THEN
    FND_MSG_PUB.initialize;
  END IF;
  --
  -- Get last_update_date from WND and WTH
  --
  OPEN c_GetDelId(p_in_rec.routingRespNum);
  FETCH c_GetDelId INTO l_deliveryId, l_ibUpdateDate, l_wndUpdateDate;
  CLOSE c_GetDelId;
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'Delivery Id', l_deliveryId);
    wsh_debug_sv.log(l_module_name, 'last update date in IB TXN history', l_ibUpdateDate);
    wsh_debug_sv.log(l_module_name, 'WND Last Update Date', l_wndUpdateDate);
  END IF;
  --
  -- Get last_update_dates of various entities tied to delivery
  --
  OPEN c_GetLastUpdateDates(l_deliveryId);
  FETCH c_GetLastUpdateDates INTO l_wdaUpdateDate, l_wddUpdateDate;
  CLOSE c_GetLastUpdateDates;
  --
  OPEN c_GetPTripLastUpdateDate(l_deliveryId);
  FETCH c_GetPTripLastUpdateDate INTO l_wtsUpdateDate, l_wdlUpdateDate, l_wtUpdateDate;
  CLOSE c_GetPTripLastUpdateDate;
  --
  OPEN c_GetDTripLastUpdateDate(l_deliveryId);
  FETCH c_GetDTripLastUpdateDate INTO l_wtsUpdateDate1, l_wdlUpdateDate1, l_wtUpdateDate1;
  CLOSE c_GetDTripLastUpdateDate;
  --
  OPEN c_GetCarrierLastUpdateDate(l_deliveryId);
  FETCH c_GetCarrierLastUpdateDate INTO l_wcsUpdateDate, l_wocsUpdateDate;
  CLOSE c_GetCarrierLastUpdateDate;
  --
  IF l_debug_on THEN
   wsh_debug_sv.log(l_module_name, 'WND Update Date', l_wndUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WDA Update Date', l_wdaUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WDD Update Date', l_wddUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WTS Update Date using Pickup Stop', l_wtsUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WDL Update Date using Pickup Stop', l_wdlUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WT  Update Date using Pickup Stop',  l_wtUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WTS Update Date using Dropoff Stop', l_wtsUpdateDate1);
   wsh_debug_sv.log(l_module_name, 'WDL Update Date using Dropoff Stop', l_wdlUpdateDate1);
   wsh_debug_sv.log(l_module_name, 'WT  Update Date using Dropoff Stop',  l_wtUpdateDate1);
   wsh_debug_sv.log(l_module_name, 'WCS  Update Date',  l_wcsUpdateDate);
   wsh_debug_sv.log(l_module_name, 'WOCS Update Date',  l_wocsUpdateDate);
  END IF;
  --
  -- Compare the last_update_dates
  --
  IF l_ibUpdateDate < l_wndUpdateDate  OR
     l_ibUpdateDate < l_wdaUpdateDate  OR
     l_ibUpdateDate < l_wddUpdateDate  OR
     l_ibUpdateDate < l_wtsUpdateDate  OR
     l_ibUpdateDate < l_wdlUpdateDate  OR
     l_ibUpdateDate < l_wtUpdateDate   OR
     l_ibUpdateDate < l_wtsUpdateDate1 OR
     l_ibUpdateDate < l_wdlUpdateDate1 OR
     l_ibUpdateDate < l_wtUpdateDate1  OR
     l_ibUpdateDate < l_wcsUpdateDate  OR
     l_ibUpdateDate < l_wocsUpdateDate THEN
    l_changed := TRUE;
  END IF;
  --
  x_out_rec.hasChanged := l_changed;
  --
  FND_MSG_PUB.Count_And_Get(
    p_count  => x_msg_count,
    p_data  =>  x_msg_data,
    p_encoded => FND_API.G_FALSE);
  --
  IF l_debug_on THEN
    wsh_debug_sv.log(l_module_name, 'l_changed', l_changed);
    wsh_debug_sv.pop(l_module_name);
  END IF;
  --
  EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_UNEXP_ERROR',
				WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      --
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      WSH_UTIL_CORE.ADD_MESSAGE(l_return_status,l_module_name);
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_INTEGRATION_GRP.HasDeliveryInfoChanged',l_module_name);
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '
			|| ' Oracle error message is '
			|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END HasDeliveryInfoChanged;

-- { IB-Phase-2
--=============================================================================
--      API name        : validateASNReceiptShipFrom
--      Type            : public.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--			 p_api_version_number   IN NUMBER
--			 p_init_msg_list IN VARCHAR2
--                       p_in_rec  IN WSH_PO_INTEGRATION_GRP.validateSF_in_rec_type
--			 p_commit IN VARCHAR2
--			 x_return_status OUT NOCOPY VARCHAR2
--                       x_out_rec OUT WSH_PO_INTEGRATION_GRP.validateSF_out_rec_type
--			 x_msg_count OUT NOCOPY NUMBER
--			 x_msg_data OUT NOCOPY VARCHAR2
--      Comment         :This API will be called whenever a ASN is created with a
--                       ShipFromLocation on the IssupplierPortal Page. This API
--                       determines whether the ASN can be created for the given
--                       ShipFromLocation based on the following points. It returns
--                       TRUE or FALSE to indicate this
--                               TRUE - ASN can be created.
--                               FALSE - ASN cannot be created.
--                        a) IS the ShipFromLocationId passed through input parameter
--                            p_in_rec a valid WSH Location.
--                                    AND
--                        b) There is a open Delivery Line (for the input PO line and PO
--                           Shipment Line) with the ShipFromLocation
--                           as the one specified as the input parameter or has a
--                           value of -1 as its ShipFromLocation. Return TRUE.
--                        c) IF (b) above is false (no Delivery lines satisfy (b) ), then
--                           check if there are open Delivery Lines for the input PO line
--                           and PO Shipment Line). If so return FALSE, other wise return
--                           TRUE.
--=============================================================================
PROCEDURE validateASNReceiptShipFrom
         (
                        p_api_version_number   IN NUMBER,
                        p_init_msg_list        IN VARCHAR2,
                        p_in_rec  IN WSH_PO_INTEGRATION_GRP.validateSF_in_rec_type,
			p_commit               IN VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_out_rec  OUT NOCOPY WSH_PO_INTEGRATION_GRP.validateSF_out_rec_type,
			x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2
           )
IS

Cursor valid_wsh_sf_loc_csr(p_location_id NUMBER)
IS
Select wsh_location_id
from wsh_locations
where
      source_location_id   = p_location_id
  and location_source_code = 'HZ';


Cursor open_line_with_sf_csr (p_shipment_line_id NUMBER,
                                     p_po_line_id NUMBER,
				     p_location_id NUMBER)
				     IS
Select 1
from wsh_delivery_details
where
po_shipment_line_id = p_shipment_line_id
and (ship_from_location_id = p_location_id  or  ship_from_location_id = -1 )
and released_status = 'X'
and source_code = 'PO'
and source_line_id = p_po_line_id
and rownum=1;

Cursor open_line_without_sf_csr (p_shipment_line_id NUMBER,
                                        p_po_line_id NUMBER)
IS
Select 1
from wsh_delivery_details
where
po_shipment_line_id = p_shipment_line_id
and released_status = 'X'
and source_code = 'PO'
and source_line_id = p_po_line_id
and rownum =1;


l_api_version_number NUMBER := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'validateASNReceiptShipFrom';
l_return_status  VARCHAR2(1);

l_index             NUMBER;
l_temp              NUMBER;
l_wsh_location_id   NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATEASNRECEIPTSHIPFROM';
--

BEGIN

x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS ;
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
    WSH_DEBUG_SV.log(l_module_name,'p_api_version_number',p_api_version_number);
    WSH_DEBUG_SV.log(l_module_name,'p_init_msg_list',p_init_msg_list);
    WSH_DEBUG_SV.log(l_module_name,'p_commit',p_commit);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.po_line_id_tbl.count',p_in_rec.po_line_id_tbl.count);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.po_shipment_line_id_tbl.count',p_in_rec.po_shipment_line_id_tbl.count);
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.ship_from_location_id',p_in_rec.ship_from_location_id);
END IF;
--
IF NOT FND_API.compatible_api_call(
  l_api_version_number,
  p_api_version_number,
  l_api_name,
  G_PKG_NAME) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--
IF FND_API.to_boolean(p_init_msg_list)  THEN
  FND_MSG_PUB.initialize;
END IF;
--
x_out_rec.is_valid := TRUE;
--
IF  p_in_rec.po_line_id_tbl.count = 0 or p_in_rec.po_shipment_line_id_tbl.count = 0
THEN
  IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,' Table count of Shipment Line IDs or PO Line IDs are not equal is/are Zero');
  END IF;
  raise FND_API.G_EXC_ERROR;
END IF;
--
IF p_in_rec.po_line_id_tbl.count <> p_in_rec.po_shipment_line_id_tbl.count THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,' Table count of Shipment Line IDs and PO Line IDs are not equal');
   END IF;
   raise FND_API.G_EXC_ERROR;
END IF;
--
--
OPEN  valid_wsh_sf_loc_csr(p_in_rec.ship_from_location_id);
FETCH valid_wsh_sf_loc_csr INTO l_wsh_location_id;
CLOSE valid_wsh_sf_loc_csr;
--
IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.ship_from_location_id',p_in_rec.ship_from_location_id);
    WSH_DEBUG_SV.log(l_module_name,'l_wsh_location_id',l_wsh_location_id);
END IF;
--
IF l_wsh_location_id is NULL THEN
   IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,' Invalid ShipFromLocation ID from PO');
   END IF;
   --
   FND_MESSAGE.SET_NAME('WSH', 'WSH_IB_INVALID_WSH_LOC');
   WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
   --
   RAISE FND_API.G_EXC_ERROR;
END IF;
--
l_index := p_in_rec.po_line_id_tbl.FIRST;
WHILE l_index is not null LOOP
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.po_shipment_line_id_tbl(l_index)',p_in_rec.po_shipment_line_id_tbl(l_index));
    WSH_DEBUG_SV.log(l_module_name,'p_in_rec.po_line_id_tbl(l_index)',p_in_rec.po_line_id_tbl(l_index));
  END IF;
  --
  OPEN open_line_with_sf_csr (p_in_rec.po_shipment_line_id_tbl(l_index),
                              p_in_rec.po_line_id_tbl(l_index),
			      l_wsh_location_id);
  FETCH open_line_with_sf_csr INTO l_temp;
  --
  IF open_line_with_sf_csr%NOTFOUND THEN
     OPEN open_line_without_sf_csr(p_in_rec.po_shipment_line_id_tbl(l_index),
                                          p_in_rec.po_line_id_tbl(l_index));
     FETCH open_line_without_sf_csr INTO l_temp;
     --
     IF open_line_without_sf_csr%FOUND THEN
        -- raise an error , no suitable open lines found
	CLOSE open_line_without_sf_csr;
        CLOSE open_line_with_sf_csr;
        --
	FND_MESSAGE.SET_NAME('WSH', 'WSH_IB_NO_OPEN_LINES');
        WSH_UTIL_CORE.add_message (wsh_util_core.g_ret_sts_error,l_module_name);
        --
	RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE open_line_without_sf_csr;
  END IF;
  CLOSE open_line_with_sf_csr;
  l_index := p_in_rec.po_line_id_tbl.NEXT(l_index);
END LOOP;


FND_MSG_PUB.Count_And_Get(
  p_count  => x_msg_count,
  p_data  =>  x_msg_data,
  p_encoded => FND_API.G_FALSE);

IF FND_API.TO_BOOLEAN(p_commit) THEN
   COMMIT WORK;
END IF;
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --
      x_out_rec.is_valid := FALSE;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      --
      FND_MSG_PUB.Count_And_Get
        (
         p_count  => x_msg_count,
         p_data  =>  x_msg_data,
         p_encoded => FND_API.G_FALSE
        );
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      --
      x_out_rec.is_valid := FALSE;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
      --
      WSH_UTIL_CORE.DEFAULT_HANDLER('WSH_PO_INTEGRATION_GRP.validateASNReceiptShipFrom',l_module_name);
      --
      IF l_debug_on THEN
	WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. '
			|| ' Oracle error message is '
			|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
END validateASNReceiptShipFrom;
--IB-Phase-2

END WSH_PO_INTEGRATION_GRP;

/
