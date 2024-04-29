--------------------------------------------------------
--  DDL for Package Body WSH_TRIP_CONSOLIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRIP_CONSOLIDATION" as
/* $Header: WSHTRCOB.pls 120.1.12010000.2 2009/12/03 13:29:01 anvarshn ship $ */

/**
 * This is a private procedure that loops through the input table of
 * delivery records and selects only those whose indexes exist in
 * p_IndexTab table
**/
PROCEDURE BuildDeliveryTable(p_IndexTab IN WSH_UTIL_CORE.ID_TAB_TYPE,
                             p_DeliveryTab IN WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
                             x_deliveryTab   IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type) IS
  --
  l_debugOn     BOOLEAN;
  l_moduleName  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.BuildDeliveryTable';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'p_IndexTab.COUNT', p_IndexTab.COUNT);
    wsh_debug_sv.log(l_moduleName, 'p_DeliveryTab.COUNT', p_DeliveryTab.COUNT);
  END IF;
  --
  FOR j IN p_IndexTab.FIRST..p_IndexTab.LAST LOOP
   --
   IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Index', p_IndexTab(j));
    wsh_Debug_sv.log(l_moduleName, 'Delivery at this Index',
                     p_deliveryTab(p_IndexTab(j)).delivery_id);
   END IF;
   --
   x_DeliveryTab(x_DeliveryTab.COUNT+1) := p_DeliveryTab(p_IndexTab(j));
   --
  END LOOP;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'x_DeliveryTab.COUNT', x_DeliveryTab.COUNT);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.BuildDeliveryTable');
    --
    IF l_debugOn THEN
      wsh_debug_sv.log(l_moduleName, 'Unexpected error',
                       SUBSTRB(SQLERRM, 1, 200));
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END BuildDeliveryTable;


PROCEDURE Create_Consolidated_Trips(
		p_deliv_status		IN VARCHAR2,
		p_pickup_start		IN DATE,
		p_pickup_end		IN DATE,
		p_dropoff_start		IN DATE,
		p_dropoff_end		IN DATE,
                p_client_id             IN NUMBER,  -- Modified R12.1.1 LSP PROJECT
		p_ship_from_org_id	IN NUMBER,
		p_customer_id		IN NUMBER,
		p_ship_to_location	IN VARCHAR2,
		p_ship_method_code	IN VARCHAR2,
		p_grp_ship_method	IN VARCHAR2,
		p_grp_ship_from		IN VARCHAR2,
		p_max_num_deliveries	IN NUMBER,
		x_TotDeliveries		OUT NOCOPY NUMBER,
		x_SuccessDeliv		OUT NOCOPY NUMBER,
		x_Trips			OUT NOCOPY NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2) IS
  --
  v_Query		VARCHAR2(32767);
  v_RetSts		VARCHAR2(1);
  i			NUMBER;
  v_DelivRec		t_DelivRec;
  e_HashError		EXCEPTION;
  c_Deliv		t_Cursor_ref;
  l_DelTab		WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_DeliveryTab         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  v_DelRec		WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
  l_num_warnings	NUMBER;
  l_num_errors		NUMBER;
  v_HashTab		HashTable;
  v_DelivTab		DelivTable;
  l_action_prms 	WSH_DELIVERIES_GRP.action_parameters_rectype;
  l_defaults_rec        wsh_deliveries_grp.default_parameters_rectype;
  l_deliv_out_rec	WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
  l_useDeliv		VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(32767);
  --
  l_debugOn	BOOLEAN;
  l_moduleName	CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.Create_Consolidated_Trips';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'p_grp_ship_from', p_grp_ship_from);
    wsh_debug_sv.log(l_moduleName, 'p_grp_ship_method', p_grp_ship_method);
    wsh_debug_sv.log(l_moduleName, 'p_max_num_deliveries', p_max_num_deliveries);
  END IF;
  --
  BuildQuery(
	p_deliv_status		=> p_deliv_status,
	p_pickup_start		=> p_pickup_start,
	p_pickup_end		=> p_pickup_end,
	p_dropoff_start 	=> p_dropoff_start,
        p_client_id             => p_client_id, -- Modified R12.1.1 LSP PROJECT
	p_dropoff_end   	=> p_dropoff_end,
	p_ship_from_org_id 	=> p_ship_from_org_id,
	p_customer_id		=> p_customer_id,
	p_ship_to_location	=> p_ship_to_location,
	p_ship_method_code	=> p_ship_method_code,
	x_Query			=> v_Query,
	x_return_status		=> v_RetSts);
  --
  IF l_debugOn THEN
    wsh_debug_sv.logmsg(l_moduleName, 'After build query');
  END IF;
  --
  wsh_util_core.api_post_call(
      p_return_status    => v_RetSts,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
  --
  WSH_UTIL_CORE.OpenDynamicCursor(c_Deliv, v_Query, g_BindVarTab);
  --
  i := 1;
  --
  WHILE FetchDelivery(c_Deliv, v_delivRec) LOOP
    --{
    CreateAssignHashValue(
	p_grp_ship_from		=> p_grp_ship_from,
	p_grp_ship_method	=> p_grp_ship_method,
	x_del_rec		=> v_delivRec,
	x_HashTable		=> v_HashTab,
	x_RetSts		=> v_RetSts,
	x_UseDeliv		=> l_useDeliv);
    --
    wsh_util_core.api_post_call(
      p_return_status    => v_RetSts,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
    --
    IF v_RetSts = WSH_UTIL_CORE.g_RET_STS_SUCCESS AND l_useDeliv = 'Y' THEN
      v_DelivTab(i) := v_DelivRec;
      i := i + 1;
    END IF;
    --}
  END LOOP;
  --
  IF l_debugOn THEN
   wsh_debug_sv.log(l_moduleName, 'Total number of deliveries selected', v_DelivTab.COUNT);
   wsh_debug_sv.log(l_moduleName, 'Total number of unique hash values', v_HashTab.COUNT);
  END IF;
  --
  i := v_HashTab.FIRST;
  WHILE i IS NOT NULL LOOP
   --{
   IF l_debugOn THEN
     wsh_debug_sv.logmsg(l_moduleName, '=========================================================');
     wsh_debug_sv.log(l_moduleName, 'v_HashTab(' || i || ').hashString', v_HashTab(i).hashString);
   END IF;
   --
   l_DelTab.DELETE;
   --
   FOR j IN 1..v_DelivTab.COUNT LOOP
    --{
    IF v_DelivTab(j).hash_value = i THEN
     --
     BuildDelivRec(v_DelivTab(j), v_DelRec, v_RetSts);
     --
     wsh_util_core.api_post_call(
      p_return_status    => v_RetSts,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
     --
     l_DelTab(l_DelTab.COUNT + 1) := v_DelRec;
     --
    END IF;
    --}
   END LOOP;
   --
   IF l_debugOn THEN
     wsh_debug_sv.log(l_moduleName, 'number of deliveries in this batch', l_DelTab.COUNT);
   END IF;
   --
   IF l_DelTab.COUNT > 0 THEN
    --{
    BEGIN
     --{
     SAVEPOINT BEFORE_DELGRP_API;
     --
     l_action_prms.caller := 'WSH_TRCON';
     l_action_prms.action_code := 'TRIP-CONSOLIDATION';
     l_action_prms.phase := 1;
     l_action_prms.maxDelivs := p_max_num_deliveries;
     --
     WSH_DELIVERIES_GRP.Delivery_Action(
	p_api_version_number => 1.0,
	p_init_msg_list	     => FND_API.G_FALSE,
	p_commit	     => FND_API.G_FALSE,
	p_action_prms	     => l_action_prms,
	p_rec_attr_tab	     => l_DelTab,
	x_delivery_out_rec   => l_deliv_out_rec,
 	x_defaults_rec	     => l_defaults_rec,
	x_return_status	     => v_RetSts,
        x_msg_count	     => l_msg_count,
        x_msg_data	     => l_msg_data);
     --
     wsh_util_core.api_post_call(
      p_return_status    => v_RetSts,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
     --
     IF v_RetSts = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
      --{
      IF l_debugOn THEN
        wsh_debug_sv.logmsg(l_moduleName, 'Delivery_Action - warning');
        wsh_debug_sv.log(l_moduleName, 'l_deliv_out_rec.valid_ids_tab.COUNT',
                                       l_deliv_out_rec.valid_ids_tab.COUNT);
      END IF;
      --
      IF l_deliv_out_rec.valid_ids_tab.COUNT > 0 AND
         l_action_prms.phase = 1 THEN
       --{
       l_deliveryTab.DELETE;
       BuildDeliveryTable(p_IndexTab => l_deliv_out_rec.valid_ids_tab,
                          p_deliveryTab   => l_DelTab,
                          x_DeliveryTab   => l_DeliveryTab);
       l_action_prms.phase := 2;
       --
       IF l_debugOn THEN
        wsh_debug_sv.log(l_moduleName, 'l_deliveryTab.COUNT',
                         l_deliveryTab.COUNT);
        wsh_debug_sv.logmsg(l_moduleName, 'Second call to Delivery_Action');
        --
       END IF;
       --
       WSH_DELIVERIES_GRP.Delivery_Action
        (
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_FALSE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_action_prms,
          p_rec_attr_tab       => l_DeliveryTab,
          x_delivery_out_rec   => l_deliv_out_rec,
          x_defaults_rec       => l_defaults_rec,
          x_return_status      => v_RetSts,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
        );
       --
       wsh_util_core.api_post_call(
        p_return_status    => v_RetSts,
        x_num_warnings     => l_num_warnings,
        x_num_errors       => l_num_errors);
       --}
      END IF;
      --}
     END IF;
     --
    EXCEPTION
      --
      WHEN FND_API.G_EXC_ERROR THEN
        --
        ROLLBACK TO BEFORE_DELGRP_API;
        --
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --
        ROLLBACK TO BEFORE_DELGRP_API;
        --
     --}
    END;
    --}
   ELSE
    --
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'No deliveries selected for this hashValue');
    END IF;
    --
   END IF;
   --
   i := v_HashTab.NEXT(i);
   --}
  END LOOP;
  --
  x_TotDeliveries := v_DelivTab.COUNT;
  x_SuccessDeliv  := g_SuccDelivs;
  x_Trips         := g_Trips;
  --
  IF NVL(x_SuccessDeliv,0) = NVL(x_TotDeliveries,0) THEN
   x_return_status := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
  ELSIF NVL(x_SuccessDeliv,0) = 0 THEN
   x_return_status := WSH_UTIL_CORE.g_RET_STS_ERROR;
  ELSE
   x_return_status := WSH_UTIL_CORE.g_RET_STS_WARNING;
  END IF;
  --
  IF l_debugOn THEN
    wsh_Debug_sv.log(l_moduleName, 'Total deliveries', NVL(x_TotDeliveries, 0));
    wsh_debug_Sv.log(l_moduleName, 'number of Successful deliveries', NVL(x_SuccessDeliv, 0));
    wsh_debug_sv.log(l_moduleName, 'number of Trips', NVL(x_Trips, 0));
    wsh_debug_sv.log(l_moduleName, 'Return Status', x_return_status);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
    --
    WHEN FND_API.G_EXC_ERROR THEN
      --
      x_TotDeliveries := v_DelivTab.COUNT;
      x_SuccessDeliv := NVL(g_SuccDelivs, 0);
      x_Trips	:= NVL(g_Trips, 0);
      --
      IF x_SuccessDeliv = x_TotDeliveries THEN
       x_return_status := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
      ELSIF x_SuccessDeliv = 0 THEN
       x_return_status := WSH_UTIL_CORE.g_RET_STS_ERROR;
      ELSE
       x_return_status := WSH_UTIL_CORE.g_RET_STS_WARNING;
      END IF;
      --
      IF l_debugOn THEN
        wsh_debug_sv.pop(l_moduleName || ' - FND_API.G_EXC_ERROR');
      END IF;
      --
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      x_TotDeliveries := v_DelivTab.COUNT;
      x_SuccessDeliv := NVL(g_SuccDelivs, 0);
      x_Trips	:= NVL(g_Trips, 0);
      --
      IF x_SuccessDeliv = x_TotDeliveries THEN
       x_return_status := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
      ELSIF x_SuccessDeliv = 0 THEN
       x_return_status := WSH_UTIL_CORE.g_RET_STS_ERROR;
      ELSE
       x_return_status := WSH_UTIL_CORE.g_RET_STS_WARNING;
      END IF;
      --
      IF l_debugOn THEN
        wsh_debug_sv.pop(l_moduleName || ' - FND_API.G_EXC_UNEXP_ERROR');
      END IF;
      --
    WHEN OTHERS THEN
      --
      x_TotDeliveries := v_DelivTab.COUNT;
      x_SuccessDeliv := NVL(g_SuccDelivs, 0);
      x_Trips	:= NVL(g_Trips, 0);
      --
      IF x_SuccessDeliv = x_TotDeliveries THEN
       x_return_status := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
      ELSIF x_SuccessDeliv = 0 THEN
       x_return_status := WSH_UTIL_CORE.g_RET_STS_ERROR;
      ELSE
       x_return_status := WSH_UTIL_CORE.g_RET_STS_WARNING;
      END IF;
      --
      wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.CREATE_CONSOLIDATED_TRIPS');
      --
      IF l_debugOn THEN
        wsh_debug_sv.pop(l_moduleName || ' - Unknown error - ' || SQLERRM);
      END IF;
      --
      RAISE;
      --
END Create_Consolidated_Trips;


PROCEDURE BuildQuery(p_deliv_status		IN VARCHAR2,
		     p_pickup_start		IN DATE,
		     p_pickup_end		IN DATE,
		     p_dropoff_start		IN DATE,
		     p_dropoff_end		IN DATE,
                     p_client_id                IN NUMBER,  -- Modified R12.1.1 LSP PROJECT
		     p_ship_from_org_id		IN NUMBER,
		     p_customer_id		IN NUMBER,
		     p_ship_to_location		IN NUMBER,
		     p_ship_method_code		IN VARCHAR2,
		     x_query			OUT NOCOPY VARCHAR2,
		     x_return_status		OUT NOCOPY VARCHAR2) IS
  --
  l_debugOn	     BOOLEAN;
  l_moduleName	     CONSTANT VARCHAR2(2000) := 'wsh.plsql.' || G_PKG_NAME || '.BuildQuery';
  v_Select	     VARCHAR2(1000);
  v_From	     VARCHAR2(1000);
  v_Where	     VARCHAR2(1000);
  v_OrderBy	     VARCHAR2(1000);
  l_msg_count        NUMBER;
  l_msg_data	     NUMBER;
  --

  l_gc3_is_installed VARCHAR2(1); -- OTM R12, glog proj

BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'p_deliv_status', p_deliv_status);
    wsh_debug_sv.log(l_moduleName, 'p_customer_id', p_customer_id);
    wsh_debug_sv.log(l_moduleName, 'p_pickup_start', p_pickup_start);
    wsh_debug_sv.log(l_moduleName, 'p_pickup_end', p_pickup_end);
    wsh_debug_sv.log(l_moduleName, 'p_dropoff_start', p_dropoff_start);
    wsh_debug_sv.log(l_moduleName, 'p_dropoff_end', p_dropoff_end);
    wsh_debug_sv.log(l_moduleName, 'p_client_id', p_client_id); -- Modified R12.1.1 LSP PROJECT
    wsh_debug_sv.log(l_moduleName, 'p_ship_from_org_id', p_ship_from_org_id);
    wsh_debug_sv.log(l_moduleName, 'p_ship_to_location', p_ship_to_location);
    wsh_debug_sv.log(l_moduleName, 'p_ship_method_code', p_ship_method_code);
  END IF;
  --
  v_select := 'SELECT  wnd.DELIVERY_ID, wnd.ORGANIZATION_ID, wnd.STATUS_CODE, wnd.PLANNED_FLAG, ' ||
              ' wnd.NAME, wnd.INITIAL_PICKUP_DATE, wnd.INITIAL_PICKUP_LOCATION_ID, ' ||
              ' wnd.ULTIMATE_DROPOFF_LOCATION_ID, wnd.ULTIMATE_DROPOFF_DATE, wnd.CUSTOMER_ID, ' ||
              ' wnd.INTMED_SHIP_TO_LOCATION_ID, wnd.SHIP_METHOD_CODE, wnd.DELIVERY_TYPE, ' ||
              ' wnd.CARRIER_ID, wnd.SERVICE_LEVEL, wnd.MODE_OF_TRANSPORT, ' ||
     	      ' wnd.SHIPMENT_DIRECTION, wnd.PARTY_ID, wnd.SHIPPING_CONTROL, ' ||
              ' NVL(wnd.ignore_for_planning, ''N''), NULL ';
  --
  v_From := ' FROM wsh_new_deliveries wnd ';
  --
  v_where := ' WHERE wnd.shipment_direction IN (''O'', ''IO'') AND ' ||
	     ' NOT EXISTS (SELECT 1 FROM wsh_delivery_legs ' ||
      	     ' WHERE delivery_id = wnd.delivery_id) ';
  --
  IF p_customer_id IS NOT NULL THEN
    --
    v_where := v_Where || ' AND wnd.customer_id = :x_CustomerID';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := p_customer_id;
    --
  END IF;
  --


  IF p_pickup_start IS NOT NULL THEN
    --
    v_Where := v_Where || ' AND to_char(wnd.initial_pickup_date, ''DD/MM/YYYY HH24:MI:SS'') >= :x_PickupStart';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := to_char(p_pickup_start, 'DD/MM/YYYY HH24:MI:SS');
    --
  END IF;
  --
  IF p_pickup_end IS NOT NULL THEN
    --
    v_Where := v_Where || ' AND to_char(wnd.initial_pickup_date, ''DD/MM/YYYY HH24:MI:SS'') <= :x_PickupEnd';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := to_char(p_pickup_end, 'DD/MM/YYYY HH24:MI:SS');
    --
  END IF;
  --
  IF p_dropoff_start IS NOT NULL THEN
    --
    v_Where := v_Where || ' AND to_char(wnd.ultimate_dropoff_date,''DD/MM/YYYY HH24:MI:SS'') >= :x_DropOffStart';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := to_char(p_dropoff_start, 'DD/MM/YYYY HH24:MI:SS');
    --
  END IF;
  --
  IF p_dropoff_end IS NOT NULL THEN
    --
    v_Where := v_Where || ' AND to_char(wnd.ultimate_dropoff_date, ''DD/MM/YYYY HH24:MI:SS'') <= :x_DropOffEnd';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := to_char(p_dropoff_end, 'DD/MM/YYYY HH24:MI:SS');
    --
  END IF;
  --
  /*Modified R12.1.1 LSP PROJECT*/
  IF p_client_id IS NOT NULL THEN
    --
    v_where := v_Where || ' AND wnd.client_id = :x_ClientID';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := p_client_id;
    --
  END IF;
  --
  /*Modified R12.1.1 LSP PROJECT*/
  IF p_ship_from_org_id IS NOT NULL THEN
    --
    v_where := v_where || ' AND wnd.organization_id = :x_SFOrgid';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := p_ship_from_org_id;
    --
  END IF;
  --
  IF p_ship_to_location IS NOT NULL THEN
    --
    v_where := v_where || ' AND wnd.ultimate_dropoff_location_id = :x_shiptoLoc';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := p_ship_to_location;
    --
  END IF;
  --
  IF p_ship_method_code IS NOT NULL THEN
    --
    v_where := v_where || ' AND wnd.ship_method_code = :x_ShipMdcode';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := p_ship_method_code;
    --
  END IF;
  --
  IF p_deliv_status IS NOT NULL THEN
   --
   IF p_deliv_status = 'BOTH' THEN
    --
    v_where := v_where || ' AND (wnd.status_code = ''CO''  OR
             wnd.status_code = ''OP'')';
    --
   ELSE
    --
    v_where := v_where || ' AND wnd.status_code =  :x_delivStatus';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := p_deliv_status;
     --
   END IF;
   --
  END IF;
  --

  --OTM R12, glog proj, use Global Variable
  l_gc3_is_installed := WSH_UTIL_CORE.G_GC3_IS_INSTALLED;

  -- If null, call the function
  IF l_gc3_is_installed IS NULL THEN
    l_gc3_is_installed := WSH_UTIL_CORE.GC3_IS_INSTALLED;
  END IF;
  -- end of OTM R12, glog proj

  IF l_gc3_is_installed = 'Y' THEN
    -- Process Delivery should only work for Ignore for Planning Delivery
    v_where := v_where || ' AND (wnd.ignore_for_planning = :x_ignore_for_planning)';
    g_BindVarTab(g_BindVarTab.COUNT + 1) := 'Y';
  END IF;
  -- end of OTM R12, glog project
  --

  v_OrderBy := ' ORDER BY wnd.status_code, wnd.organization_id, wnd.ship_method_code';
  --
  x_Query := v_select || v_from || v_where || v_OrderBy;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'v_Select', v_Select);
    wsh_debug_sv.log(l_moduleName, 'v_From', v_From);
    wsh_debug_sv.log(l_moduleName, 'v_Where', v_Where);
    wsh_debug_sv.log(l_moduleName, 'v_OrderBy', v_OrderBy);
    wsh_debug_sv.log(l_moduleName, 'x_Query', x_Query);
    wsh_debug_sv.log(l_moduleName, 'g_BindVarTab.COUNT', g_BindVarTab.COUNT);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    x_Query := NULL;
    x_return_status := WSH_UTIL_CORE.g_RET_STS_UNEXP_ERROR;
    --
    wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.CREATE_CONSOLIDATED_TRIPS');
    --
    IF l_debugOn THEN
     wsh_debug_sv.log(l_moduleName, 'Unexpected error', SUBSTRB(SQLERRM, 1, 200));
     wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END BuildQuery;


PROCEDURE CreateAssignHashValue(p_grp_ship_from	  IN 	VARCHAR2,
            		        p_grp_ship_method IN	VARCHAR2,
			        x_del_rec	  IN OUT NOCOPY  t_DelivRec,
				x_HashTable	  IN OUT NOCOPY HashTable,
				x_RetSts	  OUT NOCOPY VARCHAR2,
				x_UseDeliv	  OUT NOCOPY VARCHAR2) IS
  --
  l_debugOn	BOOLEAN;
  l_moduleName	CONSTANT VARCHAR2(2000) := 'wsh.plsql.' || G_PKG_NAME || '.CreateAssignHashValue';
  --
  l_orgType		VARCHAR2(10);
  l_hashStr		VARCHAR2(100);
  l_hashVal		NUMBER;
  l_index		NUMBER;
  b_exists		BOOLEAN;
  l_exists		BOOLEAN;
  i			NUMBER;
  l_separator		VARCHAR2(1);
  l_num_warnings	NUMBER;
  l_num_errors		NUMBER;
  v_RetSts		VARCHAR2(1);
  l_hashSize		NUMBER;
  --
BEGIN
  --
  l_debugOn  := WSH_DEBUG_INTERFACE.g_debug;
  x_RetSts   := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
  x_UseDeliv := 'Y';
  b_exists := FALSE;
  l_exists := FALSE;
  l_separator := '-';
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'Delivery ID', x_del_rec.delivery_id);
    wsh_debug_sv.log(l_moduleName, 'Organization ID',
                     x_del_rec.organization_id);
    wsh_debug_sv.log(l_moduleName, 'Ignore For Planning',
                     x_del_rec.ignore_for_planning);
  END IF;
  --
  l_orgType := WSH_UTIL_VALIDATE.Get_Org_Type(
		 p_organization_id => x_del_rec.organization_id,
             	 p_delivery_id     => x_del_rec.delivery_id,
                 x_return_status   => v_RetSts);
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Org Type', l_orgType);
  END IF;
  --
  wsh_util_core.api_post_call(
      p_return_status    => v_RetSts,
      x_num_warnings     => l_num_warnings,
      x_num_errors       => l_num_errors);
  --
  IF l_orgType IS NULL THEN
   l_orgType := 'STD';
  END IF;
  --
  -- Deliveries that belong to TPW/CMS orgs
  -- are not eligible for trip consolidation
  --
  IF (l_orgType LIKE '%TPW%' OR l_orgType LIKE '%CMS%') THEN
    x_UseDeliv := 'N';
  END IF;
  --
  l_hashStr := l_orgType || l_separator || x_del_rec.status_code ||
               l_separator || x_del_rec.ignore_for_planning;
  --
  IF p_grp_ship_from = 'Y' THEN
   l_hashStr := l_hashStr || l_separator || x_del_rec.organization_id;
  END IF;
  --
  IF p_grp_ship_method = 'Y' THEN
   l_hashStr := l_hashStr || l_separator || x_del_rec.ship_method_code;
  END IF;
  --
  l_hashVal := dbms_utility.get_hash_value(name      => l_hashStr,
					   base      => g_hashBase,
                                  	   hash_size => g_hashSize);
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'l_hashStr', l_hashStr);
    wsh_debug_sv.log(l_moduleName, 'l_hashVal', l_hashVal);
  END IF;
  --
  IF x_HashTable.EXISTS(l_hashVal) THEN
   --{
   IF l_hashStr = x_HashTable(l_hashVal).HashString THEN
    --
    b_exists := TRUE;
    x_del_rec.hash_value := l_hashVal;
    --
   ELSE /* hash collision */
    --{
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Hash collision, so regenerating hash value');
    END IF;
    --
    l_hashSize := g_HashSize;
    --
    WHILE NOT l_exists LOOP
     --{
     l_hashSize := l_hashSize + 1;
     l_hashVal := dbms_utility.get_hash_value(name 	=> l_hashStr,
					      base 	=> g_hashBase,
                                  	      hash_size => l_hashSize);
     --
     IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName, 'l_hashStr', l_hashStr);
       wsh_debug_sv.log(l_moduleName, 'l_hashVal', l_hashVal);
     END IF;
     --
     IF x_HashTable.EXISTS(l_hashVal) THEN
      --{
      IF l_hashStr = x_HashTable(l_hashVal).HashString THEN
       --
       l_exists := TRUE;
       b_exists := TRUE;
       x_del_rec.hash_value := l_hashVal;
       EXIT;
       --
      END IF;
      --}
     ELSE
      --
      b_exists := FALSE;
      x_del_rec.hash_value := l_hashVal;
      EXIT;
      --
     END IF;
     --}
    END LOOP;
    --}
   END IF;
   --}
  ELSE /* first entry in hash table */
   --{
   x_del_rec.hash_value := l_hashVal;
   --}
  END IF;
  --
  IF NOT b_exists THEN
    x_HashTable(l_hashVal).hashString := l_hashStr;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'Delivery Hash Value', x_del_rec.hash_value);
    wsh_debug_sv.log(l_moduleName, 'Include delivery for trip creation', x_UseDeliv);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
      --
      x_RetSts := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      --
      wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.CreateAssignHashValue');
      --
      IF l_debugOn THEN
        wsh_debug_sv.log(l_moduleName, 'Unexpected Error', SUBSTRB(SQLERRM,1,200));
        wsh_debug_sv.pop(l_moduleName);
      END IF;
      --
      RAISE;
      --
END CreateAssignHashValue;


FUNCTION FetchDelivery(p_Deliv_ref  IN 		  t_Cursor_ref,
                       x_deliv_rec  IN OUT NOCOPY t_DelivRec) RETURN BOOLEAN IS
  --
  l_debugOn	BOOLEAN;
  l_moduleName	CONSTANT VARCHAR2(2000) := 'wsh.plsql.' || G_PKG_NAME || '.FetchDelivery';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
  END IF;
  --
  FETCH p_Deliv_ref INTO
	x_deliv_rec.delivery_id, x_deliv_rec.organization_id,
	x_deliv_rec.status_code, x_deliv_rec.planned_flag, x_deliv_rec.name,
	x_deliv_rec.initial_pickup_date, x_deliv_rec.initial_pickup_location_id,
	x_deliv_rec.ultimate_dropoff_location_id, x_deliv_rec.ultimate_dropoff_date,
	x_deliv_rec.customer_id, x_deliv_rec.intmed_ship_to_location_id,
	x_deliv_rec.ship_method_code, x_deliv_rec.delivery_type,
	x_deliv_rec.carrier_id, x_deliv_rec.service_level,
	x_deliv_rec.mode_of_transport, x_deliv_rec.shipment_direction,
	x_deliv_rec.party_id, x_deliv_rec.shipping_control,
        x_deliv_rec.ignore_for_planning, x_deliv_rec.hash_value;
  --
  IF p_Deliv_ref%NOTFOUND THEN
   --
   IF l_debugOn THEN
     wsh_debug_sv.pop(l_moduleName || ' - FALSE');
   END IF;
   RETURN FALSE;
   --
  ELSE
   --
   IF l_debugOn THEN
     wsh_debug_sv.logmsg(l_moduleName, 'Fetching delivery ' || x_deliv_rec.delivery_id);
     wsh_debug_sv.pop(l_moduleName || ' - TRUE');
   END IF;
   RETURN TRUE;
   --
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.FetchDelivery');
    --
    IF l_debugOn THEN
      wsh_debug_sv.logmsg(l_moduleName, 'Unexpected Error in FetchDelivery');
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END FetchDelivery;



PROCEDURE BuildDelivRec(p_DelivRec IN t_DelivRec,
			x_DelivRec IN OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
			x_RetSts   OUT NOCOPY VARCHAR2) IS
  --
  l_debugOn	BOOLEAN;
  l_moduleName	CONSTANT VARCHAR2(2000) := 'wsh.plsql.' || G_PKG_NAME || '.BuildDelivRec';
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  x_RetSts := WSH_UTIL_CORE.g_RET_STS_SUCCESS;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
  END IF;
  --
  x_DelivRec.delivery_id := p_DelivRec.delivery_id;
  x_DelivRec.organization_id := p_DelivRec.organization_id;
  x_DelivRec.status_code := p_DelivRec.status_code;
  x_DelivRec.planned_flag := p_DelivRec.planned_flag;
  x_DelivRec.name := p_DelivRec.name;
  x_DelivRec.initial_pickup_date := p_DelivRec.initial_pickup_date;
  x_DelivRec.initial_pickup_location_id := p_DelivRec.initial_pickup_location_id;
  x_DelivRec.ultimate_dropoff_location_id := p_DelivRec.ultimate_dropoff_location_id;
  x_DelivRec.ultimate_dropoff_date := p_DelivRec.ultimate_dropoff_date;
  x_DelivRec.customer_id := p_DelivRec.customer_id;
  x_DelivRec.intmed_ship_to_location_id := p_DelivRec.intmed_ship_to_location_id;
  x_DelivRec.ship_method_code := p_DelivRec.ship_method_code;
  x_DelivRec.delivery_type := p_DelivRec.delivery_type;
  x_DelivRec.carrier_id := p_DelivRec.carrier_id;
  x_DelivRec.service_level := p_DelivRec.service_level;
  x_DelivRec.mode_of_transport := p_DelivRec.mode_of_transport;
  x_DelivRec.shipment_direction := p_DelivRec.shipment_direction;
  x_DelivRec.party_id := p_DelivRec.party_id;
  x_DelivRec.shipping_control := p_DelivRec.shipping_control;
  x_DelivRec.ignore_for_planning := p_DelivRec.ignore_for_planning;
  --
  IF l_debugOn THEN
   wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN OTHERS THEN
    --
    x_RetSts := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.BuildDelivRec');
    --
    IF l_debugOn THEN
      wsh_debug_sv.log(l_moduleName, 'Unexpected error', SUBSTRB(SQLERRM,1,200));
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END BuildDelivRec;



PROCEDURE GroupDelivsIntoTrips(p_DelivGrpRec	 IN	t_DelivGrpRec,
			       x_delOutRec	 OUT NOCOPY WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type,
			       x_return_status   OUT NOCOPY VARCHAR2) IS
  --
  l_debugOn		BOOLEAN;
  l_moduleName		CONSTANT VARCHAR2(2000) := 'wsh.plsql.' || G_PKG_NAME || '.GroupDelivsIntoTrips';
  i			NUMBER;
  j			NUMBER;
  k			NUMBER;
  m                     NUMBER;
  l_return_status	VARCHAR2(1);
  l_trip_name_tab	wsh_util_core.column_tab_type;
  l_num_warnings	NUMBER;
  l_num_errors		NUMBER;
  l_delivery_tab	WSH_UTIL_CORE.ID_TAB_TYPE;
  l_trip_tab            WSH_UTIL_CORE.ID_TAB_TYPE;
  v_Index		NUMBER;
  v_DelCount            NUMBER;
  v_TotalDelCount       NUMBER;
  v_numCalls            NUMBER;
  --
  CURSOR c_DeliveryCount(p_tripId IN NUMBER) IS
  SELECT count(DISTINCT delivery_id)
  FROM wsh_trips wt, wsh_trip_stops wts1,
       wsh_trip_stops wts2, wsh_delivery_legs wdl
  WHERE wt.trip_id = p_tripId
  AND wts1.stop_id = wdl.pick_up_stop_id
  AND wts2.stop_id = wdl.drop_off_stop_id
  AND wts1.trip_id = wt.trip_id
  AND wts2.trip_id = wt.trip_id;
  --
BEGIN
  --
  l_debugOn := WSH_DEBUG_INTERFACE.g_debug;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  v_DelCount := 0;
  v_TotalDelCount := 0;
  v_numCalls := 0;
  l_num_errors := 0;
  l_num_warnings := 0;
  --
  IF l_debugOn IS NULL THEN
     l_debugOn := wsh_debug_sv.is_debug_enabled;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.push(l_moduleName);
    wsh_debug_sv.log(l_moduleName, 'p_delIDTab.COUNT', p_DelivGrpRec.deliv_IDTab.COUNT);
    wsh_debug_sv.log(l_moduleName, 'p_max_Delivs', p_DelivGrpRec.max_Delivs);
    --
    wsh_debug_sv.logmsg(l_moduleName,
      '===========Complete Set of Input Deliveries===========');
    v_Index := p_DelivGrpRec.deliv_IDTab.FIRST;
    WHILE v_Index IS NOT NULL LOOP
     --
     wsh_debug_sv.log(l_moduleName, 'Index', v_Index);
     wsh_debug_sv.log(l_moduleName, 'Delivery Id',
                      p_DelivGrpRec.deliv_IDTab(v_Index));
     v_Index := p_DelivGrpRec.deliv_IDTab.NEXT(v_Index);
     --
    END LOOP;
    --
  END IF;
  --
  i := p_DelivGrpRec.deliv_IDTab.FIRST;
  j := 1;
  k := 1;
  --
  WHILE i IS NOT NULL LOOP
   --{
   l_delivery_tab(j) := p_DelivGrpRec.deliv_IDTab(i);
   --
   IF (l_delivery_tab.COUNT = p_DelivGrpRec.max_Delivs) OR
      (i = p_DelivGrpRec.deliv_IDTab.COUNT) THEN
    --{
    IF l_debugOn THEN
      --{
      wsh_debug_sv.log(l_moduleName, '# of delivs. passed to AutoCreate_trip_multi',l_delivery_tab.COUNT);
      wsh_debug_sv.logmsg(l_moduleName,
        '========Deliveries passed to Autocreate Trip==========');
      --
      v_Index := l_delivery_tab.FIRST;
      WHILE v_Index IS NOT NULL LOOP
        --
        wsh_debug_sv.log(l_moduleName, 'Index', v_Index);
        wsh_debug_sv.log(l_moduleName, 'Delivery Id', l_delivery_tab(v_Index));
        v_Index := l_delivery_tab.NEXT(v_Index);
        --
      END LOOP;
      --}
    END IF;
    --
    BEGIN
     --{
     v_TotalDelCount := 0;
     v_numCalls := v_numCalls + 1;
     SAVEPOINT Before_Autocreate_Trip;
     --
     WSH_TRIPS_ACTIONS.AutoCreate_Trip_multi(
         p_del_rows      => l_delivery_tab,
         x_trip_ids      => l_trip_tab,
         x_trip_names    => l_trip_name_tab,
         x_return_status => l_return_status);
     --
     wsh_util_core.api_post_call(
       p_return_status    => l_return_status,
       x_num_warnings     => l_num_warnings,
       x_num_errors       => l_num_errors);
     --
     FOR m IN l_trip_tab.FIRST..l_trip_tab.LAST LOOP
       --{
       x_delOutRec.result_id_tab(k):=l_trip_tab(m);
       --
       IF l_debugOn THEN
         wsh_debug_sv.log(l_moduleName, 'Index k', k);
         wsh_debug_sv.log(l_moduleName, 'Trip ID', x_delOutRec.result_id_tab(k));
       END IF;
       --
       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        --{
        v_DelCount := 0;
        OPEN c_DeliveryCount(x_delOutRec.result_id_tab(k));
        FETCH c_DeliveryCount INTO v_DelCount;
        CLOSE c_DeliveryCount;
        --
        IF l_debugOn THEN
         wsh_debug_sv.log(l_moduleName, 'v_DelCount', v_DelCount);
        END IF;
        --}
       ELSE
        v_DelCount := l_delivery_tab.COUNT;
       END IF;
       --
       v_TotalDelCount := v_TotalDelCount + v_DelCount;
       --
       k:=k+1;
       --}
     END LOOP;
     --
     IF l_debugOn THEN
      wsh_debug_sv.log(l_moduleName,'v_TotalDelCount', v_TotalDelCount);
     END IF;
     --
     j := 0;
     g_SuccDelivs := NVL(g_SuccDelivs,0) + v_TotalDelCount;
     g_Trips := NVL(g_Trips,0) + l_trip_tab.COUNT;
     x_DelOutRec.num_success_Delivs := NVL(x_DelOutRec.num_success_Delivs,0) +
				       v_TotalDelCount;
     l_delivery_tab.DELETE;
     --
     IF l_debugOn THEN
       wsh_debug_sv.log(l_moduleName, '# of trips until now', g_Trips);
       wsh_debug_sv.log(l_moduleName, '# of successful delivs until now', g_SuccDelivs);
       wsh_debug_sv.log(l_moduleName, '# of successful delivs in this batch', x_DelOutRec.num_success_Delivs);
     END IF;
     --}
    EXCEPTION
     --{
     WHEN FND_API.G_EXC_ERROR THEN
      --
      j := 0;
      l_delivery_tab.DELETE;
      ROLLBACK TO Before_Autocreate_Trip;
      --
      IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Expected Error for this set of deliveries');
      END IF;
      --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --
      j := 0;
      l_delivery_tab.DELETE;
      ROLLBACK TO Before_Autocreate_Trip;
      --
      IF l_debugOn THEN
       wsh_debug_sv.logmsg(l_moduleName, 'Unexpected Error for this set of deliveries');
      END IF;
      --}
    END;
    --}
   END IF;
   --
   i := p_DelivGrpRec.deliv_IDTab.NEXT(i);
   j := j + 1;
   --}
  END LOOP;
  --
  IF l_debugOn THEN
   wsh_debug_Sv.log(l_moduleName, '# of calls to Autocreate Trip', v_numCalls);
   wsh_debug_sv.log(l_moduleName, '# errors from these calls', l_num_errors);
   wsh_debug_sv.log(l_moduleName, '# warnings from these calls', l_num_warnings);
  END IF;
  --
  IF l_num_errors > 0 AND  l_num_errors = v_numCalls THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
  ELSIF ((l_num_errors > 0 AND l_num_errors < v_numCalls) OR
         l_num_warnings > 0) THEN
   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
  ELSE
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  END IF;
  --
  IF l_debugOn THEN
    wsh_debug_sv.log(l_moduleName, 'x_return_status', x_return_status);
    wsh_debug_sv.pop(l_moduleName);
  END IF;
  --
  EXCEPTION
   --
   WHEN FND_API.G_EXC_ERROR THEN
    --
    x_Return_Status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    --
    IF l_debugOn THEN
      wsh_debug_sv.pop(l_moduleName || ' - FND_API.G_EXC_ERROR');
    END IF;
    --
    RAISE;
    --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    IF l_debugOn THEN
      wsh_debug_sv.pop(l_moduleName || ' - FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
    RAISE;
   --
   WHEN OTHERS THEN
    --
    x_Return_Status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    --
    wsh_util_core.default_handler('WSH_TRIP_CONSOLIDATION.GroupDelivsIntoTrips');
    --
    IF l_debugOn THEN
      wsh_Debug_sv.logmsg(l_moduleName, 'Unexpected error in GroupDelivsIntoTrips' || SQLERRM);
      wsh_debug_sv.pop(l_moduleName);
    END IF;
    --
    RAISE;
    --
END GroupDelivsIntoTrips;



END WSH_TRIP_CONSOLIDATION;

/
