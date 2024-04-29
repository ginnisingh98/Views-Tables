--------------------------------------------------------
--  DDL for Package Body WSH_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_INTERFACE" as
/* $Header: WSHDDINB.pls 120.2.12010000.4 2010/02/25 15:50:26 sankarun ship $ */

G_CALL_MODE	VARCHAR2(6) := 'ONLINE';   -- global variable for PRINTMSG


--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_INTERFACE';
--
-- anxsharm For Load Tender
-- Forward Declaration
PROCEDURE Get_Details_Snapshot(
           p_source_code IN VARCHAR2,
           p_changed_attributes  IN ChangedAttributeTabType,
           p_phase IN NUMBER,
           x_dd_ids IN OUT NOCOPY wsh_util_core.id_tab_type,
           x_out_table OUT NOCOPY wsh_interface.deliverydetailtab,
           x_return_status OUT NOCOPY VARCHAR2);

--

PROCEDURE Update_Shipping_Attributes(
  p_source_code			IN	 VARCHAR2
, p_changed_attributes	 IN	 ChangedAttributeTabType
, x_return_status		  OUT NOCOPY 	VARCHAR2
, p_log_level			  IN	 NUMBER   -- log level fix
)
IS
  l_interface_flag VARCHAR2(1);
  l_rs			 VARCHAR2(1);
  --
  invalid_source_code       exception;

l_debug_on BOOLEAN;

  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_SHIPPING_ATTRIBUTES';
  --
    --Bugfix 4070732
    l_return_status             VARCHAR2(32767);
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;

  -- K LPN CONV. rv
  l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
  l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(32767);
  -- K LPN CONV. rv
BEGIN
   -- Bugfix 4070732
   IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
   THEN
       WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
       WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
   END IF;
   -- End of Code Bugfix 4070732
  --log level fix
  IF p_log_level <> FND_API.G_MISS_NUM THEN	  --  log level fix
	WSH_UTIL_CORE.Set_Log_Level(p_log_level);
  END IF;

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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_LOG_LEVEL',P_LOG_LEVEL);

      WSH_DEBUG_SV.log(l_module_name,'COUNT OF P_CHANGED_ATTR Table',p_changed_attributes.COUNT);

  END IF;
  --
  l_rs := FND_API.G_RET_STS_SUCCESS;
  SAVEPOINT before_changes;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'INSIDE WSH_INTERFACE.UPDATE_SHIPPING_ATTRIBUTES'  );
  END IF;
  --

  Lock_Records(
	   p_source_code		=> p_source_code,
	   p_changed_attributes => p_changed_attributes,
	   x_interface_flag	 => l_interface_flag,
	   x_return_status	  => l_rs);

  IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
				  WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	IF p_source_code <> 'INV' THEN
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING WSH_INTERFACE.LOCK_RECORDS BEFORE PROCESS_RECORDS ' || L_RS  );
	  END IF;
	  --
          -- p_source_code should only be 'INV' or 'OE', else raise error.  -- jckwok
          -- 5870774: Added OKE since there will be cancellations initiated from OKE
             IF p_source_code NOT IN ('OE','WSH', 'OKE')  THEN
                 FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_SOURCE_CODE');
	         FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
	         WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.G_RET_STS_ERROR, l_module_name);
	         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                 ROLLBACK TO before_changes;
                 raise invalid_source_code;
             END IF;

	  Process_Records(
			 p_source_code		=> p_source_code,
			 p_changed_attributes => p_changed_attributes,
			 p_interface_flag	 => l_interface_flag,
			 x_return_status	  => l_rs);
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING WSH_INTERFACE.PROCESS_RECORDS ' || L_RS  );
	  END IF;
	  --

	ELSIF (p_source_code = 'INV') THEN

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_INV_PVT.UPDATE_INVENTORY_INFO',WSH_DEBUG_SV.C_PROC_LEVEL);
	  END IF;
	  --
	  WSH_USA_INV_PVT.Update_Inventory_Info(
			 p_changed_attributes => p_changed_attributes,
			 x_return_status	  => l_rs);

	ELSE

	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name, 'INVALID SOURCE CODE '  );
	  END IF;
	  --
	  FND_MESSAGE.SET_NAME('WSH', 'WSH_INVALID_SOURCE_CODE');
	  FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
	  WSH_UTIL_CORE.add_message (WSH_UTIL_CORE.G_RET_STS_ERROR);
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

	END IF; -- p_source_code
        --
        -- K LPN CONV. rv
        --
        IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
        THEN
        --{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;

            WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
              (
                p_in_rec             => l_lpn_in_sync_comm_rec,
                x_return_status      => l_return_status,
                x_out_rec            => l_lpn_out_sync_comm_rec
              );
            --
            --
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
            END IF;
            IF  l_rs = WSH_UTIL_CORE.G_RET_STS_SUCCESS
            AND l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
            THEN
              --
              l_rs := l_return_status;
              --
            ELSIF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) and l_rs <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              --
              l_rs := l_return_status;
              --
            END IF;
            --
            --
        --}
        END IF;
        --
        -- K LPN CONV. rv
        --

	IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
				WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name, 'ERROR IN WSH_INTERFACE.PROCESS_RECORDS / UPDATE_INVENTORY_INFO'  );
	  END IF;
	  --
	  ROLLBACK TO before_changes;

	END IF; -- return status after Update_INV and Process_Records

  END IF; -- l_rs after lock_records
    --

  x_return_status := l_rs;

  --
  -- Start code for Bugfix 4070732
  --
  IF  l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
  AND UPPER(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = UPPER(l_api_session_name) THEN
  --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
  --}
  ELSIF UPPER(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = UPPER(l_api_session_name) THEN
  --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{
          l_reset_flags := TRUE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                      x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            x_return_status := l_return_status;
          END IF;

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                                 ) THEN
	     ROLLBACK TO before_changes;
          END IF;
      --}
      END IF;
  --}
  END IF;
  --
  -- End of Code Bugfix 4070732
  --

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
        -- J IB --jckwok
        WHEN invalid_source_code THEN
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) and x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --
          --
          -- Start code for Bugfix 4070732
          --
          IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
          --{
              IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
              --{
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                            x_return_status => l_return_status);


                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                  END IF;
              --}
              END IF;
          --}
          END IF;
          --
          -- End of Code Bugfix 4070732
          --
          IF l_debug_on THEN
                WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INVALID_SOURCE_CODE');
	  END IF;
        --
	WHEN others THEN
	  ROLLBACK TO before_changes;
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_INTERFACE.Update_Shipping_Attributes');
          --
          -- Start code for Bugfix 4070732
          --
          IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
          --{
              IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
              --{
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
                  END IF;

                  WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                            x_return_status => l_return_status);


                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
                  END IF;

                  IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                  END IF;
              --}
              END IF;
          --}
          END IF;
          --
          -- End of Code Bugfix 4070732
          --
	  --
	  -- Debug Statements
	  --
	  IF l_debug_on THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
	      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
	  END IF;
	  --
END Update_Shipping_Attributes;



PROCEDURE Get_In_Transit_Qty(
   p_source_code				  IN	 VARCHAR2 DEFAULT 'OE',
   p_customer_id			   IN   NUMBER,
   p_ship_to_org_id			IN   NUMBER,
   p_ship_from_org_id			IN   NUMBER,
   p_inventory_item_id			IN   NUMBER,
   p_order_header_id			IN   NUMBER,
   p_cust_production_seq_num	  IN   VARCHAR2,
   p_shipper_recs			   IN   t_shipper_rec,
   p_schedule_generation_date	  IN   DATE,
   p_shipment_date			IN   DATE,
   x_in_transit_qty			OUT NOCOPY    NUMBER,
   x_return_status			OUT NOCOPY   VARCHAR2) IS
   l_ship_to_location_id number;
   l_ship_from_location_id number;
   invalid_org exception;
   invalid_cust_site exception;
   l_location_status varchar2(30);
   CURSOR C_transit_detail
   IS
   select	dd.delivery_detail_id,
		 s.stop_id,
		 s.actual_departure_date,
		 nd.name,
		 dd.shipped_quantity
   from	  wsh_delivery_Details dd,
		 wsh_trip_stops s,
		 wsh_delivery_legs dl,
		 wsh_delivery_assignments_v da,
		 wsh_new_deliveries  nd
--		 wsh_delivery_line_status_v ds
   where	 s.stop_id = dl.pick_up_stop_id
   and	   dl.delivery_id = nd.delivery_id
   and	   nd.delivery_id = da.delivery_id
--   and	   dd.delivery_detail_id = ds.delivery_detail_id
   and	   da.delivery_detail_id = dd.delivery_detail_id
   and	   s.stop_location_id = nd.initial_pickup_location_id
   and	   dd.customer_id = p_customer_id
   and	   dd.ship_to_location_id = l_ship_to_location_id
   and	   dd.ship_from_location_id = l_ship_from_location_id
   and	   dd.inventory_item_id = p_inventory_item_id
   and	  dd.source_header_id = p_order_header_id
--   and	   ds.delivery_status in ('CL', 'IT','CO')
   and    NVL(nd.shipment_direction, 'O') IN ('O', 'IO')
   and	  NVL(dd.customer_prod_seq,'*') = NVL(NVL(p_cust_production_seq_num,dd.customer_prod_seq), '*');
l_transit_detail c_transit_detail%ROWTYPE;
l_total_qty_in_transit number;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_IN_TRANSIT_QTY';
--
begin
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
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_ORG_ID',P_SHIP_TO_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_ORG_ID',P_SHIP_FROM_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_CUST_PRODUCTION_SEQ_NUM',P_CUST_PRODUCTION_SEQ_NUM);
       WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_GENERATION_DATE',P_SCHEDULE_GENERATION_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIPMENT_DATE',P_SHIPMENT_DATE);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
   l_total_qty_in_transit := 0;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_util_core.get_location_id('ORG',p_ship_from_org_id, l_ship_from_location_id, l_location_status, FALSE);
   if (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
       IF (l_location_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
        AND (l_ship_from_location_id IS NULL) THEN
           x_in_transit_qty := 0 ;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'X_INTRANSIT_QTY',
                                                          x_in_transit_qty);
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
       ELSE
	  raise INVALID_ORG;
       END IF;
   end if;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.GET_LOCATION_ID',WSH_DEBUG_SV.C_PROC_LEVEL);
   END IF;
   --
   wsh_util_core.get_location_id('CUSTOMER SITE',p_ship_to_org_id, l_ship_to_location_id, l_location_status,FALSE);
   if (l_location_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) then
       IF (l_location_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
        AND (l_ship_to_location_id IS NULL) THEN
           x_in_transit_qty := 0 ;
           x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
           IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'X_INTRANSIT_QTY',
                                                          x_in_transit_qty);
               WSH_DEBUG_SV.pop(l_module_name);
           END IF;
           RETURN;
       ELSE
	  raise invalid_cust_site;
       END IF;
   end if;
   open c_transit_detail;

   if (p_shipper_Recs.shipper_id1 is not null) then
	loop
	  fetch c_transit_detail into l_transit_detail;
	  exit when c_transit_detail%NOTFOUND;
	  if ((l_transit_detail.name <> NVL(p_shipper_recs.shipper_id1,'*'))
		 and
		  (l_transit_detail.name <> NVL(p_shipper_recs.shipper_id2,'*'))
		 and
		  (l_transit_detail.name <> NVL(p_shipper_recs.shipper_id3,'*'))
		   and
		  (l_transit_detail.name <> NVL(p_shipper_recs.shipper_id4,'*'))
		 and
		  (l_transit_detail.name <> NVL(p_shipper_recs.shipper_id5,'*')))

	  then
		  l_total_qty_in_transit := l_total_qty_in_transit + l_transit_detail.shipped_quantity;
	  end if;
	end loop;
   elsif (   (p_shipper_Recs.shipper_id1 is null) and
		 (p_shipment_date is not null)) then
	loop
	  fetch c_transit_detail into l_transit_detail;
	  exit when c_transit_detail%NOTFOUND;
	  if (p_shipment_date <  l_transit_detail.actual_departure_date ) then
		 l_total_qty_in_transit := l_total_qty_in_transit + l_transit_detail.shipped_quantity;
	  end if;
	end loop;
   elsif (p_schedule_generation_date is not null) then
	loop
	  fetch c_transit_detail into l_transit_detail;
	  exit when c_transit_detail%NOTFOUND;
	  if (p_schedule_generation_date < l_transit_detail.actual_departure_date ) then
		 l_total_qty_in_transit := l_total_qty_in_transit + l_transit_detail.shipped_quantity;
	  end if;
	end loop;
   end if;
	close c_transit_detail;
   x_in_transit_qty := l_total_qty_in_transit;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
   exception
	  when invalid_org then
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 fnd_message.set_name('WSH', 'WSH_DET_NO_LOCATION_FOR_ORG');
		 WSH_UTIL_CORE.add_message (x_return_status);
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_ORG exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_ORG');
		 END IF;
		 --
	  when invalid_cust_site then
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 fnd_message.set_name('WSH', 'WSH_DET_NO_LOCATION_FOR_SITE');
		 WSH_UTIL_CORE.add_message (x_return_status);
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'INVALID_CUST_SITE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:INVALID_CUST_SITE');
		 END IF;
		 --
	  when others then
		 wsh_util_core.default_handler('WSH_INTERFACE.Get_In_Transit_Qty');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		 END IF;
		 --
end Get_In_Transit_Qty;



--bug 1569962
PROCEDURE Get_In_Transit_Qty(
   p_source_code				  IN	 VARCHAR2 DEFAULT 'OE',
   p_customer_id			   IN   NUMBER,
   p_ship_to_org_id			IN   NUMBER,
   p_ship_from_org_id			IN   NUMBER,
   p_inventory_item_id			IN   NUMBER,
   p_order_header_id			IN   NUMBER,
   p_shipper_recs			   IN   t_shipper_rec,
   p_schedule_generation_date	  IN   DATE,
   x_in_transit_qty			OUT NOCOPY    NUMBER,
   x_return_status			OUT NOCOPY   VARCHAR2) IS

   l_seq_num varchar2(1);
   l_shipment_date date;
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_IN_TRANSIT_QTY';
   --
begin

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
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_CUSTOMER_ID',P_CUSTOMER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_TO_ORG_ID',P_SHIP_TO_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_ORG_ID',P_SHIP_FROM_ORG_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_INVENTORY_ITEM_ID',P_INVENTORY_ITEM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ORDER_HEADER_ID',P_ORDER_HEADER_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_SCHEDULE_GENERATION_DATE',P_SCHEDULE_GENERATION_DATE);
   END IF;
   --
   l_seq_num:=NULL;
   l_shipment_date:=NULL;

   Get_In_Transit_Qty(
   p_customer_id=> p_customer_id,
   p_ship_to_org_id=>p_ship_to_org_id,
   p_ship_from_org_id=>p_ship_from_org_id,
   p_inventory_item_id=>p_inventory_item_id,
   p_order_header_id=>p_order_header_id,
   p_cust_production_seq_num=>l_seq_num,
   p_shipper_recs=>p_shipper_recs,
   p_schedule_generation_date=>p_schedule_generation_date,
   p_shipment_date=>l_shipment_date,
   x_in_transit_qty=>x_in_transit_qty,
   x_return_status=>x_return_status);

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   exception
	  when others then
		 wsh_util_core.default_handler('WSH_INTERFACE.Get_In_Transit_Qty');
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
		 END IF;
		 --
end Get_In_Transit_Qty;




PROCEDURE Import_Delivery_Details (
   errbuf		   OUT NOCOPY  VARCHAR2,
   retcode		  OUT NOCOPY  VARCHAR2,
   p_source_line_id IN  NUMBER,
   p_source_code	IN  VARCHAR2)
IS
  l_source_line_id  NUMBER;
  l_rs			  VARCHAR2(1);
  l_status		  VARCHAR2(10);
  l_temp			BOOLEAN;
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'IMPORT_DELIVERY_DETAILS';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
  END IF;
  --
  WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
  G_CALL_MODE := 'CONC';

  IF p_source_line_id = -9999 THEN
	l_source_line_id := NULL;
  ELSE
	l_source_line_id := p_source_line_id;
  END IF;

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_ACTIONS_PVT.IMPORT_DELIVERY_DETAILS',WSH_DEBUG_SV.C_PROC_LEVEL);
  END IF;
  --
  WSH_USA_ACTIONS_PVT.Import_Delivery_Details(
		p_source_line_id => l_source_line_id,
		p_source_code	=> p_source_code,
		x_return_status  => l_rs);

  IF l_rs = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
	l_status := 'NORMAL';
	errbuf := 'Import Delivery Details is completed successfully';
	retcode := '0';
  ELSIF l_rs = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	l_status := 'WARNING';
	errbuf := 'Import Delivery Details is completed with warning';
	retcode := '1';
  ELSE
	l_status := 'ERROR';
	errbuf := 'Import Delivery Details is completed with error';
	retcode := '2';
  END IF;

  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_status,'');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
   WHEN OTHERS THEN
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE.PRINTMSG',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 WSH_INTERFACE.PrintMsg('Import Delivery Details failed with unexpected error ' || SQLCODE);
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_INTERFACE.PRINTMSG',WSH_DEBUG_SV.C_PROC_LEVEL);
	 END IF;
	 --
	 WSH_INTERFACE.PrintMsg('The unexpected error is ' || SQLERRM);
	 l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
	 errbuf := 'Import Delivery Details is completed with error';
	 retcode := '2';

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END IMPORT_DELIVERY_DETAILS;



PROCEDURE Default_Container(
  p_delivery_detail_id			IN	 NUMBER
, x_return_status				  OUT NOCOPY  VARCHAR2
)
IS
CURSOR C_container
IS
SELECT mci.master_container_item_id, mci.detail_container_item_id
FROM mtl_customer_items mci, wsh_delivery_details dd, oe_order_lines_all ool
WHERE dd.delivery_detail_id = p_delivery_detail_id AND
	  dd.source_line_id = ool.line_id AND
	  mci.customer_item_id(+) =  ool.ordered_item_id AND
          ool.item_identifier_type = 'CUST';

l_master_container_item_id		   NUMBER;
l_detail_container_item_id		   NUMBER;
no_container						 EXCEPTION;
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DEFAULT_CONTAINER';
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
       WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN C_Container;
   FETCH C_Container INTO l_master_container_item_id, l_detail_container_item_id;

   IF (C_Container%NOTFOUND) THEN
	  CLOSE C_Container;
	  RAISE no_container;
   ELSE
	  UPDATE wsh_delivery_details
	  SET master_container_item_id = l_master_container_item_id,
		  detail_container_item_id = l_detail_container_item_id
	  WHERE delivery_detail_id = p_delivery_detail_id;
	  CLOSE C_Container;
   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	  WHEN no_container THEN
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'NO_CONTAINER exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_CONTAINER');
		 END IF;
		 --
		 RETURN;
		 --
	  WHEN others THEN
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		 wsh_util_core.default_handler('WSH_INTERFACE.Default_Container');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Default_Container;


PROCEDURE Populate_Detail_Info(
  p_old_delivery_detail_info IN WSH_DELIVERY_DETAILS%ROWTYPE
, x_new_delivery_detail_info OUT NOCOPY wsh_glbl_var_strct_grp.delivery_details_rec_type
, x_return_status		  OUT NOCOPY  VARCHAR2
)
IS
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'POPULATE_DETAIL_INFO';
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
       WSH_DEBUG_SV.log(l_module_name,'SOURCE_CODE',p_old_delivery_detail_info.source_code);
       WSH_DEBUG_SV.log(l_module_name,'SOURCE_HEADER_ID',p_old_delivery_detail_info.source_header_id);
   END IF;
   --
   x_new_delivery_detail_info.source_code :=  p_old_delivery_detail_info.source_code;
   x_new_delivery_detail_info.source_header_id := p_old_delivery_detail_info.source_header_id;
   x_new_delivery_detail_info.source_line_id := p_old_delivery_detail_info.source_line_id;
   x_new_delivery_detail_info.customer_id := p_old_delivery_detail_info.customer_id;
   x_new_delivery_detail_info.sold_to_contact_id := p_old_delivery_detail_info.sold_to_contact_id;
   x_new_delivery_detail_info.inventory_item_id := p_old_delivery_detail_info.inventory_item_id;
   x_new_delivery_detail_info.item_description := p_old_delivery_detail_info.item_description;
   x_new_delivery_detail_info.hazard_class_id := p_old_delivery_detail_info.hazard_class_id;
   x_new_delivery_detail_info.country_of_origin := p_old_delivery_detail_info.country_of_origin;
   x_new_delivery_detail_info.classification :=  p_old_delivery_detail_info.classification;
   x_new_delivery_detail_info.ship_from_location_id :=  p_old_delivery_detail_info.ship_from_location_id;
	x_new_delivery_detail_info.ship_to_site_use_id := p_old_delivery_detail_info.ship_to_site_use_id;
	x_new_delivery_detail_info.deliver_to_site_use_id := p_old_delivery_detail_info.deliver_to_site_use_id;
   x_new_delivery_detail_info.ship_to_location_id := p_old_delivery_detail_info.ship_to_location_id;
   x_new_delivery_detail_info.deliver_to_location_id := p_old_delivery_detail_info.deliver_to_location_id;
   x_new_delivery_detail_info.ship_to_contact_id := p_old_delivery_detail_info.ship_to_contact_id;
   x_new_delivery_detail_info.deliver_to_contact_id  := p_old_delivery_detail_info.deliver_to_contact_id;
   x_new_delivery_detail_info.intmed_ship_to_location_id := p_old_delivery_detail_info.intmed_ship_to_location_id;
   x_new_delivery_detail_info.intmed_ship_to_contact_id := p_old_delivery_detail_info.intmed_ship_to_contact_id;
   x_new_delivery_detail_info.ship_tolerance_above := p_old_delivery_detail_info.ship_tolerance_above;
   x_new_delivery_detail_info.ship_tolerance_below := p_old_delivery_detail_info.ship_tolerance_below;
   x_new_delivery_detail_info.requested_quantity := 0;
   x_new_delivery_detail_info.requested_quantity_uom := p_old_delivery_detail_info.requested_quantity_uom;

  -- hwahdani start of OPM changes  (Update_Shipping)
  x_new_delivery_detail_info.requested_quantity2 := NULL;
   x_new_delivery_detail_info.requested_quantity_uom2 := p_old_delivery_detail_info.requested_quantity_uom2;
  -- hwahdani end of OPM changes (Update_Shipping)

   x_new_delivery_detail_info.subinventory := p_old_delivery_detail_info.subinventory;
   x_new_delivery_detail_info.customer_requested_lot_flag := p_old_delivery_detail_info.customer_requested_lot_flag;
   x_new_delivery_detail_info.date_requested := p_old_delivery_detail_info.date_requested;
   x_new_delivery_detail_info.date_scheduled :=  p_old_delivery_detail_info.date_scheduled;
   x_new_delivery_detail_info.master_container_item_id := p_old_delivery_detail_info.master_container_item_id;
   x_new_delivery_detail_info.detail_container_item_id :=  p_old_delivery_detail_info.detail_container_item_id;
   x_new_delivery_detail_info.load_seq_number := p_old_delivery_detail_info.load_seq_number;
   x_new_delivery_detail_info.ship_method_code := p_old_delivery_detail_info.ship_method_code;
   x_new_delivery_detail_info.carrier_id := p_old_delivery_detail_info.carrier_id;
   x_new_delivery_detail_info.freight_terms_code := p_old_delivery_detail_info.freight_terms_code;
   x_new_delivery_detail_info.shipment_priority_code := p_old_delivery_detail_info.shipment_priority_code;
   x_new_delivery_detail_info.fob_code := p_old_delivery_detail_info.fob_code;
   x_new_delivery_detail_info.customer_item_id := p_old_delivery_detail_info.customer_item_id;
   x_new_delivery_detail_info.dep_plan_required_flag := p_old_delivery_detail_info.dep_plan_required_flag;
   x_new_delivery_detail_info.customer_prod_seq := p_old_delivery_detail_info.customer_prod_seq;
   x_new_delivery_detail_info.customer_dock_code := p_old_delivery_detail_info.customer_dock_code;
   x_new_delivery_detail_info.cust_model_serial_number := p_old_delivery_detail_info.cust_model_serial_number;
   x_new_delivery_detail_info.customer_job := p_old_delivery_detail_info.customer_job;
   x_new_delivery_detail_info.customer_production_line := p_old_delivery_detail_info.customer_production_line;
   x_new_delivery_detail_info.net_weight :=  p_old_delivery_detail_info.net_weight;
   x_new_delivery_detail_info.weight_uom_code := p_old_delivery_detail_info.weight_uom_code;
   x_new_delivery_detail_info.volume := p_old_delivery_detail_info.volume;
   x_new_delivery_detail_info.volume_uom_code := p_old_delivery_detail_info.volume_uom_code;
   x_new_delivery_detail_info.released_flag := 'N';
   x_new_delivery_detail_info.mvt_stat_status := p_old_delivery_detail_info.mvt_stat_status;
   x_new_delivery_detail_info.organization_id  := p_old_delivery_detail_info.organization_id;
   x_new_delivery_detail_info.ship_set_id   := p_old_delivery_detail_info.ship_set_id;
   x_new_delivery_detail_info.arrival_set_id := p_old_delivery_detail_info.arrival_set_id;
   x_new_delivery_detail_info.ship_model_complete_flag := p_old_delivery_detail_info.ship_model_complete_flag;
   x_new_delivery_detail_info.top_model_line_id := p_old_delivery_detail_info.top_model_line_id;
   x_new_delivery_detail_info.source_header_number := p_old_delivery_detail_info.source_header_number;
   x_new_delivery_detail_info.source_header_type_id := p_old_delivery_detail_info.source_header_type_id;
   x_new_delivery_detail_info.source_header_type_name := p_old_delivery_detail_info.source_header_type_name;
   x_new_delivery_detail_info.cust_po_number := p_old_delivery_detail_info.cust_po_number;
   x_new_delivery_detail_info.ato_line_id := p_old_delivery_detail_info.ato_line_id;
   x_new_delivery_detail_info.src_requested_quantity := p_old_delivery_detail_info.src_requested_quantity;
   x_new_delivery_detail_info.src_requested_quantity_uom := p_old_delivery_detail_info.src_requested_quantity_uom;
  -- hwahdani start of OPM changes (Update_Shipping)
   x_new_delivery_detail_info.src_requested_quantity2 := p_old_delivery_detail_info.src_requested_quantity2;
   x_new_delivery_detail_info.src_requested_quantity_uom2 := p_old_delivery_detail_info.src_requested_quantity_uom2;
   x_new_delivery_detail_info.cancelled_quantity2 := p_old_delivery_detail_info.cancelled_quantity2;
  x_new_delivery_detail_info.preferred_grade := p_old_delivery_detail_info.preferred_grade;
  x_new_delivery_detail_info.lot_number := p_old_delivery_detail_info.lot_number;
-- HW OPMCONV - No need for sublot_number
--x_new_delivery_detail_info.sublot_number := p_old_delivery_detail_info.sublot_number;
  -- hwahdani end of OPM changes (Update_Shipping)

   x_new_delivery_detail_info.move_order_line_id := p_old_delivery_detail_info.move_order_line_id;
   x_new_delivery_detail_info.cancelled_quantity := p_old_delivery_detail_info.cancelled_quantity;
   x_new_delivery_detail_info.tracking_number :=  p_old_delivery_detail_info.tracking_number;
   x_new_delivery_detail_info.movement_id  := p_old_delivery_detail_info.movement_id;
   x_new_delivery_detail_info.shipping_instructions := p_old_delivery_detail_info.shipping_instructions;
   x_new_delivery_detail_info.packing_instructions := p_old_delivery_detail_info.packing_instructions;
   x_new_delivery_detail_info.project_id := p_old_delivery_detail_info.project_id;
   x_new_delivery_detail_info.task_id :=  p_old_delivery_detail_info.task_id;
   x_new_delivery_detail_info.org_id :=  p_old_delivery_detail_info.org_id;
--   x_new_delivery_detail_info.oe_interfaced_flag  := 'N';
   x_new_delivery_detail_info.split_from_detail_id := p_old_delivery_detail_info.split_from_delivery_detail_id;
--   x_new_delivery_detail_info.inv_interfaced_flag := 'N';
   x_new_delivery_detail_info.source_line_number  := p_old_delivery_detail_info.source_line_number;
   x_new_delivery_detail_info.released_status := 'N';
   x_new_delivery_detail_info.container_flag := 'N';
   x_new_delivery_detail_info.container_type_code := NULL;
   x_new_delivery_detail_info.container_name := NULL;
   x_new_delivery_detail_info.fill_percent := NULL;
   x_new_delivery_detail_info.gross_weight := NULL;
   x_new_delivery_detail_info.master_serial_number := NULL;
   x_new_delivery_detail_info.maximum_load_weight := NULL;
   x_new_delivery_detail_info.maximum_volume := NULL;
   x_new_delivery_detail_info.minimum_fill_percent := NULL;
   x_new_delivery_detail_info.seal_code :=  NULL;
   x_new_delivery_detail_info.mvt_stat_status := p_old_delivery_detail_info.mvt_stat_status;
   x_new_delivery_detail_info.unit_price := p_old_delivery_detail_info.unit_price;
   x_new_delivery_detail_info.currency_code := p_old_delivery_detail_info.currency_code;
   x_new_delivery_detail_info.inspection_flag := p_old_delivery_detail_info.inspection_flag;
   x_new_delivery_detail_info.lpn_id  := p_old_delivery_detail_info.lpn_id ;
--   x_new_delivery_detail_info.attribute15  := p_old_delivery_detail_info.attribute15 ; -- 1561078
   x_new_delivery_detail_info.original_subinventory  := p_old_delivery_detail_info.original_subinventory ;
   x_new_delivery_detail_info.pickable_flag  := p_old_delivery_detail_info.pickable_flag ;
   IF (x_new_delivery_detail_info.source_code = 'OE') THEN
	x_new_delivery_detail_info.oe_interfaced_flag := 'N' ;
	IF (x_new_delivery_detail_info.pickable_flag = 'Y') THEN
	   x_new_delivery_detail_info.inv_interfaced_flag := 'N';
	 ELSE
	  x_new_delivery_detail_info.inv_interfaced_flag := 'X';
	 END IF;
   ELSE
	x_new_delivery_detail_info.inv_interfaced_flag := 'N';
	x_new_delivery_detail_info.oe_interfaced_flag  := 'X';
   END IF;

   -- anxsharm Bug 2181132
   x_new_delivery_detail_info.source_line_set_id :=
     p_old_delivery_detail_info.source_line_set_id ;
   --
   -- Debug Statements
   --
   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;
   --
END Populate_Detail_Info;

--
--Procedure:  Process_Details
--Parameters
--            p_details_id         : Table of delivery details
--            p_cancel_delete_flag : 'C'(Cancel)/'D'(Delete)
--            x_return_status      : Return Status
--Description:
--            This procedure cancels or deletes the specified delivery details depending on p_cancel_delete_flag
--            If p_cancel_delete_flag is 'D' and source_code is WSH, the API will Cancel the delivery details although
--            p_cancel_delete_flag is specified as 'D'

PROCEDURE Process_Details(
            p_details_id         IN  WSH_UTIL_CORE.Id_Tab_Type,
            p_cancel_delete_flag IN  VARCHAR2,
            x_return_status      OUT NOCOPY  VARCHAR2) IS

CURSOR c_assignment(c_detail_id NUMBER) IS
SELECT delivery_assignment_id,
       parent_delivery_detail_id,
       delivery_id
FROM wsh_delivery_assignments_v
WHERE delivery_detail_id = c_detail_id;
l_assign_rec c_assignment%ROWTYPE;

-- HW OPMCONV - Added Qty2
CURSOR c_details(c_detail_id NUMBER) IS
SELECT delivery_detail_id,
       organization_id,
       ship_from_location_id,
       inventory_item_id,
       requested_quantity,
       picked_quantity,
       requested_quantity2,
       picked_quantity2,
       move_order_line_id,
       released_status,
       source_code,
       container_flag,
       source_line_id -- Column added for Bug 5741373
FROM wsh_delivery_details
WHERE delivery_detail_id = c_detail_id;

l_detail_rec c_details%ROWTYPE;

l_return_status			   VARCHAR2(30);
l_exception_msg_count		  NUMBER;
l_exception_msg_data		  VARCHAR2(2000);
l_planned_flag				VARCHAR2(1);
l_exception_return_status	 VARCHAR2(30);
l_exception_location_id		VARCHAR2(30);
l_dummy_exception_id		   VARCHAR2(30);
l_container_name			  VARCHAR2(30);
l_exception_error_message	  VARCHAR2(2000) := NULL;
l_move_line_id				NUMBER;
l_trolin_tbl					INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_old_tbl			  INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_out_tbl			  INV_MOVE_ORDER_PUB.Trolin_Tbl_Type;
l_trolin_rec					INV_MOVE_ORDER_PUB.Trolin_Rec_Type;
l_trolin_table_id			   NUMBER;
l_mo_line_msg_count		   NUMBER;
l_mo_line_msg_data			VARCHAR2(2000) := NULL;
process_move_order_failed	 EXCEPTION;
l_message					 VARCHAR2(2000) := NULL;
-- hwahdani BUG#:1565518
l_msg						 VARCHAR2(2000) := NULL;
-- HW OPM for OM changes
-- HW OPMCONV - Removed OPM variables
-- HW OPM changes for NOCOPY. BUG#:2694418

l_commit							   VARCHAR2(1);
l_msg_count						 NUMBER;
l_msg_data						  VARCHAR2(3000);
l_api_version_number			  NUMBER := 1.0;
l_freight_cost_count			  NUMBER := 0;
WSH_DEL_RESERVATION_FAILED  EXCEPTION;
WSH_DELETE_DETAIL_FAILED    EXCEPTION;
WSH_UNASSIGN_DETAIL_FAILED  EXCEPTION;

/* H integration: mark WSH lines as cancelled wrudge */
l_cancel_dds	WSH_UTIL_CORE.Id_Tab_Type;

l_dbi_rs                    VARCHAR2(1); -- Return Status from DBI API
-- K LPN CONV. rv
l_lpn_in_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type;
l_lpn_out_sync_comm_rec WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type;
-- K LPN CONV. rv

 -- Bug 5741373
 l_move_order_line_ids    WSH_UTIL_CORE.Id_Tab_Type;
 l_source_line_ids        WSH_UTIL_CORE.Id_Tab_Type;
 --
l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_DETAILS';
l_notfound BOOLEAN;

BEGIN

   l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
   IF l_debug_on IS NULL
   THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
   END IF;
   IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'COUNT of Details',p_details_id.count);
     WSH_DEBUG_SV.log(l_module_name,'p_cancel_delete_flag',p_cancel_delete_flag);
   END IF;
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   FOR i IN 1 .. p_details_id.COUNT
   LOOP
     OPEN c_assignment(p_details_id(i));
     FETCH c_assignment INTO l_assign_rec;
     l_notfound := c_assignment%NOTFOUND;
     CLOSE c_assignment;

     OPEN c_details(p_details_id(i));
     FETCH c_details INTO l_detail_rec;
     l_notfound := l_notfound AND c_details%NOTFOUND;
     CLOSE c_details;

     IF (l_notfound) THEN
       IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,  'NO ASSIGNMENT RECORDS ARE FOUND'  );
       END IF;
       GOTO loop_end;  -- maybe already deleted.
     END IF;

-- HW OPMCONV - Removed branching

     IF (l_assign_rec.parent_delivery_detail_id IS NOT NULL) THEN
       -- if delivery line is packed, log exception for it

       SELECT container_name
       INTO l_container_name
       FROM wsh_delivery_details
       WHERE delivery_detail_id = l_assign_rec.parent_delivery_detail_id;

       FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_PACKING');
       l_msg := FND_MESSAGE.GET;
       l_exception_location_id := l_detail_rec.ship_from_location_id;

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Line is packed.',WSH_DEBUG_SV.C_PROC_LEVEL);
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       wsh_xc_util.log_exception(
         p_api_version => 1.0,
         x_return_status   => l_exception_return_status,
         x_msg_count   => l_exception_msg_count,
         x_msg_data=> l_exception_msg_data,
         x_exception_id=> l_dummy_exception_id ,
         p_logged_at_location_id   => l_exception_location_id,
         p_exception_location_id   => l_exception_location_id,
         p_logging_entity  => 'SHIPPER',
         p_logging_entity_id   => FND_GLOBAL.USER_ID,
         p_exception_name  => 'WSH_INVALID_PACKING',
         p_message => l_msg,
         p_delivery_detail_id  => l_detail_rec.delivery_detail_id,
         p_delivery_assignment_id  => l_assign_rec.delivery_assignment_id,
         p_container_name  => l_container_name,
         p_inventory_item_id   => l_detail_rec.inventory_item_id,
         p_quantity=> l_detail_rec.requested_quantity,
         p_error_message   => l_exception_error_message
       );

       -- bug 2948940: it is OK to delete the line even when it is packed.
       --      the exception will alert the user that the container needs updating.
       --      continue flow, regardless of log_exception's return status

       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'l_exception_return_status=' || l_exception_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

     ELSIF (l_assign_rec.delivery_id IS NOT NULL) THEN
       -- if delivery line is assigned to delivery and delivery is planned,
       -- log exception for it
       SELECT planned_flag
       INTO l_planned_flag
       FROM wsh_new_deliveries
       WHERE delivery_id = l_assign_rec.delivery_id;

       IF (NVL(l_planned_flag, 'N') IN ('Y','F')) THEN
         -- hwahdani BUG#:1565518
         l_msg := NULL;
         FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_DELIVERY_PLANNING');
         l_msg := FND_MESSAGE.GET;
         l_exception_location_id := l_detail_rec.ship_from_location_id;

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Line is in planned delivery.',WSH_DEBUG_SV.C_PROC_LEVEL);
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_XC_UTIL.LOG_EXCEPTION',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         wsh_xc_util.log_exception(
           p_api_version => 1.0,
           x_return_status   => l_exception_return_status,
           x_msg_count   => l_exception_msg_count,
           x_msg_data=> l_exception_msg_data,
           x_exception_id=> l_dummy_exception_id ,
           p_logged_at_location_id   => l_exception_location_id,
           p_exception_location_id   => l_exception_location_id,
           p_logging_entity  => 'SHIPPER',
           p_logging_entity_id   => FND_GLOBAL.USER_ID,
           p_exception_name  => 'WSH_INVALID_DELIVERY_PLANNING',
           p_message => l_msg,
           p_delivery_id  => l_assign_rec.delivery_id,
           p_error_message   => l_exception_error_message
         );

         -- bug 2948940: it is OK to delete the line even when it is packed.
         --      the exception will alert the user that the container needs updating.
         --      continue flow, regardless of log_exception's return status

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'l_exception_return_status=' || l_exception_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
       END IF;
     END IF;

-- HW OPMCONV - Removed branching

       IF l_detail_rec.move_order_line_id IS NOT NULL AND
          l_detail_rec.released_status = 'S' THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_TROLIN_UTIL.QUERY_ROW',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         -- Added for bug 5741373
         l_move_order_line_ids(l_move_order_line_ids.count+1) := l_detail_rec.move_order_line_id;
         l_source_line_ids(l_source_line_ids.count+1) := l_detail_rec.source_line_id;
         --
         l_trolin_rec := INV_TROLIN_UTIL.Query_Row(p_line_id => l_detail_rec.move_order_line_id);
         l_trolin_table_id := l_trolin_tbl.count + 1;
         l_trolin_tbl(l_trolin_table_id) := l_trolin_rec;
         l_trolin_tbl(l_trolin_table_id).OPERATION := INV_GLOBALS.G_OPR_DELETE;
         l_trolin_old_tbl(l_trolin_table_id) := l_trolin_tbl(l_trolin_table_id);

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'DELETE MOVE ORDER LINE '||L_TROLIN_REC.LINE_ID  );
         END IF;
       END IF;

-- HW OPMCONV - Removed branching

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNRESERVE_DELIVERY_DETAIL',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

   -- HW OPMCONV - Added Qty2
     WSH_DELIVERY_DETAILS_ACTIONS.Unreserve_delivery_detail(
       p_delivery_detail_id => p_details_id(i),
       p_quantity_to_unreserve => NVL(l_detail_rec.picked_quantity, l_detail_rec.requested_quantity),
       p_quantity2_to_unreserve => NVL(l_detail_rec.picked_quantity2, l_detail_rec.requested_quantity2),
       p_unreserve_mode => 'UNRESERVE',
       p_override_retain_ato_rsv => 'Y',          -- 2747520
       x_return_status => l_return_status);

     IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
        l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR   THEN
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'UNRESERVE DELIVERY DETAIL '|| P_DETAILS_ID ( I ) || ' FAILED'  );
       END IF;
       raise WSH_DEL_RESERVATION_FAILED;
     END IF;

     /* H integration: 940/945 cancel 'WSH' line, not delete it wrudge */
     IF l_detail_rec.source_code = 'WSH' AND
        l_detail_rec.container_flag = 'N'  THEN

        l_cancel_dds( l_cancel_dds.count+1 ) := p_details_id(i);
     ELSE
       -- J: W/V Changes
       IF (l_assign_rec.parent_delivery_detail_id IS NOT NULL) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_CONT',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Cont(
           p_detail_id     => p_details_id(i),
           p_validate_flag => 'N',
           x_return_status => l_return_status);

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
           l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR   THEN

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UNASSIGN DETAIL FROM CONTAINER FAILED FOR DD '|| P_DETAILS_ID ( I ));
           END IF;
           raise WSH_UNASSIGN_DETAIL_FAILED;
         END IF;
       END IF;

       IF (l_assign_rec.delivery_id IS NOT NULL) THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_ACTIONS.UNASSIGN_DETAIL_FROM_DELIVERY',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_DELIVERY_DETAILS_ACTIONS.Unassign_Detail_from_Delivery(
           p_detail_id     => p_details_id(i),
           p_validate_flag => 'N',
           x_return_status => l_return_status);

         IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
           l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR   THEN

           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  'UNASSIGN DETAIL FROM DELIVERY FAILED FOR DD '|| P_DETAILS_ID ( I ));
           END IF;
           raise WSH_UNASSIGN_DETAIL_FAILED;
         END IF;
       END IF;

       IF (p_cancel_delete_flag = 'C') THEN
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.DELETE_DELIVERY_DETAILS to CANCEL',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details(
           p_delivery_detail_id => p_details_id(i),
           p_cancel_flag        => 'Y',
           x_return_status      => l_return_status );

       ELSE -- delete details
         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_PKG.DELETE_DELIVERY_DETAILS to DELETE',WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;

         WSH_DELIVERY_DETAILS_PKG.Delete_Delivery_Details(
           p_delivery_detail_id => p_details_id(i),
           p_cancel_flag        => 'N',
           x_return_status      => l_return_status );

       END IF;
       -- End J: W/V Changes

       IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR OR
         l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR   THEN

         IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,  'DELETE DELIVERY DETAIL '|| P_DETAILS_ID ( I ) || ' FAILED'  );
         END IF;
         raise WSH_DELETE_DETAIL_FAILED;
       END IF;

     END IF;

     <<loop_end>>
     NULL;
   END LOOP;

   -- Moved the call to process_move_order_line outside the loop.
   -- during bug fix 1785691.
   -- We call process_move_order_line only if the l_trolin_tab count is
   -- greater than zero, meaning there should be atleast
   -- one delivery detail with released status 'S'

-- HW OPMCONV - Removed branching

     -- Bug 5741373 : Modified the below IF condition
     -- Also, call INV Cancel_Move_Order_Line API instead of Process_Move_Order_Line
     --
     IF (l_move_order_line_ids.count >0) THEN
      --{
      FOR i in 1..l_move_order_line_ids.count
      LOOP
       --{
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit INV_MO_CANCEL_PVT.Cancel_Move_Order_Line',WSH_DEBUG_SV.C_PROC_LEVEL);
        WSH_DEBUG_SV.log(l_module_name, 'Move Order Line ID', l_move_order_line_ids(i));
        WSH_DEBUG_SV.log(l_module_name, 'Source Line ID', l_source_line_ids(i));
       END IF;
       --
       INV_MO_Cancel_PVT.Cancel_Move_Order_Line(
         x_return_status       => l_return_status,
         x_msg_count           => l_mo_line_msg_count,
         x_msg_data            => l_mo_line_msg_data,
         p_line_id             => l_move_order_line_ids(i),
         p_delete_reservations => 'Y',
         p_txn_source_line_id  => l_source_line_ids(i) );
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,  'RETURN_STATUS FROM Cancel_Move_Order_line IS '||L_RETURN_STATUS  );
       END IF;

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        --{
        FOR j IN 1..l_mo_line_msg_count
         LOOP
           --{
           l_message := FND_MSG_PUB.Get(j, 'F');
           l_message := replace(l_message, chr(0), ' ');
           IF l_debug_on THEN
             WSH_DEBUG_SV.logmsg(l_module_name,  L_MESSAGE  );
           END IF;
           --}
         END LOOP;
         RAISE Process_Move_Order_Failed;
         --}
       END IF;
       --}
      END LOOP;
      --}
     END IF;
-- HW OPMCONV - Removed branching

   /* H integration: 940/945 cancel lines  wrudge */
   IF l_cancel_dds.count > 0 THEN
     -- UPDATE is copied/modified from Backorder API
     FORALL i IN 1..l_cancel_dds.count
       UPDATE wsh_delivery_details
       SET move_order_line_id = NULL ,
           released_status = 'D',
           cycle_count_quantity = NULL,
           cycle_count_quantity2 = NULL,
           shipped_quantity = NULL,
           shipped_quantity2 = NULL,
           picked_quantity = NULL,
           picked_quantity2 = NULL,
           subinventory = NULL,
           inv_interfaced_flag = NULL,
           oe_interfaced_flag  = NULL,
           locator_id = NULL,
           preferred_grade = NULL,
-- HW OPMCONV - No need for sublot_number
--         sublot_number = NULL,
           lot_number = NULL,
           revision   = null ,
           tracking_number = NULL
       WHERE delivery_detail_id = l_cancel_dds(i);
       -- delivery assignment records are not modified for source_code WSH.
     --
     -- Use l_cancel_dds to pass as table of delivery detail ids
     -- DBI Project
     -- Update of wsh_delivery_details where requested_quantity/released_status
     -- are changed, call DBI API after the update.
     -- DBI API will check if DBI is installed
     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Calling DBI API.Detail Count-',l_cancel_dds.count);
     END IF;
     WSH_INTEGRATION.DBI_Update_Detail_Log
       (p_delivery_detail_id_tab => l_cancel_dds,
        p_dml_type               => 'UPDATE',
        x_return_status          => l_dbi_rs);

     IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Return Status after DBI Call-',l_dbi_rs);
     END IF;
     -- Only Handle Unexpected error
     IF l_dbi_rs = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
       x_return_status := l_dbi_rs;
       -- just pass this Unexpected error to calling API
       -- since there is no further code flow in this procedure, no need to RETURN
       -- just continue
     END IF;
     -- all others are same as success
     -- End of Code for DBI Project
     --

   END IF;
   --
   -- K LPN CONV. rv
   --
   IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
   THEN
   --{
       IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;

       WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
         (
           p_in_rec             => l_lpn_in_sync_comm_rec,
           x_return_status      => l_return_status,
           x_out_rec            => l_lpn_out_sync_comm_rec
         );
       --
       --
       IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
       END IF;
       --
       --
       IF   x_return_status =  WSH_UTIL_CORE.G_RET_STS_SUCCESS
       AND  l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
       THEN
         --
         x_return_status := l_return_status;
         --
       ELSIF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
       AND   x_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
       THEN
         --
         x_return_status := l_return_status;
         --
       END IF;
   --}
   END IF;
   --
   -- K LPN CONV. rv
   --

   IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name);
   END IF;

EXCEPTION

   WHEN WSH_DELETE_DETAIL_FAILED THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DELETE_DETAIL_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DELETE_DETAIL_FAILED');
     END IF;
     IF c_assignment%ISOPEN THEN
       CLOSE c_assignment;
     END IF;
     IF c_details%ISOPEN THEN
       CLOSE c_details;
     END IF;

   WHEN WSH_DEL_RESERVATION_FAILED THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
              IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
              END IF;
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DEL_RESERVATION_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DEL_RESERVATION_FAILED');
     END IF;
     IF c_assignment%ISOPEN THEN
       CLOSE c_assignment;
     END IF;
     IF c_details%ISOPEN THEN
       CLOSE c_details;
     END IF;
	  --
   WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     wsh_util_core.default_handler('WSH_INTERFACE.PROCESS_DETAILS');
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
     END IF;
          --
          -- K LPN CONV. rv
          --
          IF WSH_WMS_LPN_GRP.G_CALLBACK_REQUIRED = 'Y'
          THEN
          --{
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',WSH_DEBUG_SV.C_PROC_LEVEL);
              END IF;

              WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS
                (
                  p_in_rec             => l_lpn_in_sync_comm_rec,
                  x_return_status      => l_return_status,
                  x_out_rec            => l_lpn_out_sync_comm_rec
                );
              --
              --
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return status after calling WSH_LPN_SYNC_COMM_PKG.SYNC_LPNS_TO_WMS',l_return_status);
              END IF;
              --
              --
          --}
          END IF;
          --
          -- K LPN CONV. rv
          --

     IF l_debug_on THEN
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;
     IF c_assignment%ISOPEN THEN
       CLOSE c_assignment;
     END IF;
     IF c_details%ISOPEN THEN
       CLOSE c_details;
     END IF;

END Process_Details;

--
--Procedure:  Delete_Details
--Parameters
--            p_details_id    : Table of delivery details
--            x_return_status : Return Status
--Description:
--            This procedure calls private API process_details with p_cancel_delete_flag 'D'
--            to delete the delivery details if source_code is 'OE' and cancel delivery details
--            if source_code is 'WSH'

PROCEDURE Delete_Details(
  p_details_id    IN  WSH_UTIL_CORE.Id_Tab_Type,
  x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_DETAILS';

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'COUNT of Details',p_details_id.count);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  process_details(
    p_details_id         => p_details_id,
    p_cancel_delete_flag => 'D',
    x_return_status      => x_return_status);

  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     wsh_util_core.default_handler('WSH_INTERFACE.DELETE_DETAILS');

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Delete_Details;

--Procedure:  Cancel_Details
--Parameters
--            p_details_id    : Table of delivery details
--            x_return_status : Return Status
--Description:
--            This procedure calls private API process_details with p_cancel_delete_flag 'C'
--            to cancel the delivery details

PROCEDURE Cancel_Details(
  p_details_id    IN  WSH_UTIL_CORE.Id_Tab_Type,
  x_return_status OUT NOCOPY VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CANCEL_DETAILS';

    --Bugfix 4070732
    l_return_status             VARCHAR2(32767);
    l_api_session_name CONSTANT VARCHAR2(150) := G_PKG_NAME ||'.' || l_module_name;
    l_reset_flags BOOLEAN;

BEGIN
   -- Bugfix 4070732
   IF WSH_UTIL_CORE.G_START_OF_SESSION_API is null
   THEN
       WSH_UTIL_CORE.G_START_OF_SESSION_API     := l_api_session_name;
       WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API := FALSE;
   END IF;
   -- End of Code Bugfix 4070732
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'COUNT of Details',p_details_id.count);
  END IF;
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  process_details(
    p_details_id         => p_details_id,
    p_cancel_delete_flag => 'C',
    x_return_status      => x_return_status);

  --
  -- Start code for Bugfix 4070732
  --
  IF  x_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
  AND UPPER(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = UPPER(l_api_session_name) THEN
  --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                    x_return_status => l_return_status);


          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
  --}
  ELSIF UPPER(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = UPPER(l_api_session_name) THEN
  --{
      IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
      --{
          l_reset_flags := TRUE;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Process_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;

          WSH_UTIL_CORE.Process_stops_for_load_tender(p_reset_flags   => l_reset_flags,
                                                      x_return_status => l_return_status);

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
          END IF;

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
            x_return_status := l_return_status;
          END IF;
      --}
      END IF;
  --}
  END IF;
  --
  -- End of Code Bugfix 4070732
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
     wsh_util_core.default_handler('WSH_INTERFACE.CANCEL_DETAILS');
     --
     -- Start code for Bugfix 4070732
     --
     IF  upper(WSH_UTIL_CORE.G_START_OF_SESSION_API)  = upper(l_api_session_name) THEN
     --{
         IF NOT(WSH_UTIL_CORE.G_CALL_FTE_LOAD_TENDER_API) THEN
         --{
             IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_UTIL_CORE.Reset_stops_for_load_tender',WSH_DEBUG_SV.C_PROC_LEVEL);
             END IF;

             WSH_UTIL_CORE.Reset_stops_for_load_tender(p_reset_flags   => TRUE,
                                                       x_return_status => l_return_status);


             IF l_debug_on THEN
               WSH_DEBUG_SV.log(l_module_name,'l_return_status',l_return_status);
             END IF;

             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
             END IF;
         --}
         END IF;
     --}
     END IF;
     --
     -- End of Code Bugfix 4070732
     --

     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
     END IF;

END Cancel_Details;

PROCEDURE Get_Max_Load_Qty(
			 p_move_order_line_id		IN		NUMBER,
			 x_max_load_quantity		OUT NOCOPY 		NUMBER,
			 x_container_item_id		OUT NOCOPY 		NUMBER,
			 x_return_status			OUT NOCOPY 		VARCHAR2) IS

get_max_load_qty_failed	   EXCEPTION;
l_container_item_id	number ;
l_inventory_item_id number ;
l_max_load_quantity number ;

--bug # 3259762
l_item_name VARCHAR2(2000);
l_org_name VARCHAR2(240);
--

CURSOR c_details IS
		select detail_container_item_id , inventory_item_id  , organization_id
		from wsh_delivery_Details
		where move_order_line_id = p_move_order_line_id
                and   nvl(line_direction, 'O') IN ('O', 'IO')
		and   rownum = 1 ;

l_detail_rec c_details%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_MAX_LOAD_QTY';
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
       WSH_DEBUG_SV.log(l_module_name,'P_MOVE_ORDER_LINE_ID',P_MOVE_ORDER_LINE_ID);
   END IF;
   --
   x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   OPEN c_details;
   FETCH c_details INTO l_detail_rec;

   IF (c_details%NOTFOUND) THEN
	  CLOSE c_details;
	  RAISE get_max_load_qty_failed ;
   ELSE

                -- bug # 3259762
   		l_item_name := WSH_UTIL_CORE.Get_Item_Name(l_detail_rec.inventory_item_id, l_detail_rec.organization_id);
                l_org_name  := WSH_UTIL_CORE.Get_Org_Name(l_detail_rec.organization_id);
                --
		if l_detail_rec.detail_container_item_id is not null then

		  l_container_item_id  :=  l_detail_rec.detail_container_item_id ;

		  select max_load_quantity
		  into   l_max_load_quantity
		  from   wsh_container_items
		  where  container_item_id = l_detail_rec.detail_container_item_id
		  and	nvl ( load_item_id , l_detail_rec.inventory_item_id ) =  l_detail_rec.inventory_item_id
		  and	master_organization_id = l_detail_rec.organization_id
		  and	rownum = 1 ;

			else

		  select max_load_quantity  , container_item_id
		  into   l_max_load_quantity , l_container_item_id
		  from   wsh_container_items
		  where  load_item_id =  l_detail_rec.inventory_item_id
		  and	preferred_flag ='Y'
		  and	master_organization_id = l_detail_rec.organization_id
		  and	rownum = 1 ;

			end if ;

		   x_max_load_quantity := l_max_load_quantity ;
	   x_container_item_id := l_container_item_id ;

   END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   EXCEPTION
	  WHEN get_max_load_qty_failed THEN
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name,'GET_MAX_LOAD_QTY_FAILED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		     WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:GET_MAX_LOAD_QTY_FAILED');
		 END IF;
		 --
		 RETURN;
		 --

         --bug # 3259762
  	 WHEN NO_DATA_FOUND THEN
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	         FND_MESSAGE.SET_NAME('WSH','WSH_INVALID_CONT_LOAD');
	         FND_MESSAGE.SET_TOKEN('ITEM_NAME',l_item_name);
	         FND_MESSAGE.SET_TOKEN('ORG_NAME',l_org_name);
          	--
	        -- Debug Statements
		--
		IF l_debug_on THEN
		   WSH_DEBUG_SV.logmsg(l_module_name,'The item ' || l_item_name || ' does not have a preferred container load relationship in the organization '|| l_org_name ,WSH_DEBUG_SV.C_EXCEP_LEVEL);
		   WSH_DEBUG_SV.logmsg(l_module_name,'NO_DATA_FOUND exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		   WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:NO_DATA_FOUND');
		END IF;
		--
		RETURN;
		--


	  WHEN others THEN
		 x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		 wsh_util_core.default_handler('WSH_INTERFACE.Get_Max_Load_Qty');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Get_Max_Load_Qty;



PROCEDURE Lock_Records(
  p_source_code			IN	 VARCHAR2,
  p_changed_attributes	 IN	 ChangedAttributeTabType,
  x_interface_flag		 OUT NOCOPY 	VARCHAR2,
  x_return_status		  OUT NOCOPY 	VARCHAR2
) IS

  CURSOR c_source_line_to_lock(x_source_line_id	 NUMBER,
							   x_neg_source_line_id NUMBER,
							   x_source_code		VARCHAR2) IS
  SELECT wdd.delivery_detail_id,wdd.client_id -- LSP PROJECT : Added clientId
  FROM  wsh_delivery_details	 wdd
  WHERE wdd.source_line_id	 IN  (x_source_line_id, x_neg_source_line_id)
  AND   wdd.source_code		=  x_source_code
  AND   wdd.container_flag	 =  'N'
  AND   wdd.released_status	<> 'D';

  -- LSP PROJECT : to get clientId value for the given
  CURSOR c_get_client(c_dd_id  IN NUMBER) IS
  SELECT wdd.client_id -- LSP PROJECT : Added clientId
  FROM  wsh_delivery_details	wdd
  WHERE wdd.delivery_detail_id = c_dd_id;


  l_counter		 NUMBER;
  l_source_line_id  NUMBER;
  l_confirmed_flag  BOOLEAN := FALSE;
  l_shipped_flag	BOOLEAN := FALSE;
  l_interface_flag  VARCHAR2(1) := 'N';
  --Variable added for Standalone project
  l_standalone_mode VARCHAR2(1);
  l_rs			  VARCHAR2(1);
  -- LSP PROJECT : begin
  l_client_changed_attributes ChangedAttributeTabType;
  l_found                     BOOLEAN;
  l_client_id                 NUMBER;
  -- LSP PROJECT :end
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_RECORDS';
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
       WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
   END IF;
   --
   l_rs  := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_INTERFACE.LOCK_RECORDS '  );
	END IF;
	--
    --Standalone project
   l_standalone_mode := WMS_DEPLOY.Wms_Deployment_Mode;
   --
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name, 'l_standalone_mode', l_standalone_mode );
   END IF;
   --
   --
   <<records_loop>>
   FOR l_counter IN p_changed_attributes.FIRST .. p_changed_attributes.LAST LOOP

	 -- lock records in WSH_DELIVERY_DETAILS and wsh_delivery_assignments_v (if not Pick Confirm)
	 -- unless we are importing source lines.
	 -- We also look up delivery's status (if not Pick Confirm)
	 IF p_changed_attributes(l_counter).action_flag <> 'I' THEN

--	   check if we have already locked delivery_detail_id or source_line_id/original_source_line_id

	   IF p_changed_attributes(l_counter).delivery_detail_id <> FND_API.G_MISS_NUM THEN

		 Lock_Delivery_Detail(
		   p_delivery_detail_id	 => p_changed_attributes(l_counter).delivery_detail_id,
		   p_source_code			=> p_source_code,
		   x_confirmed_flag		 => l_confirmed_flag,
		   x_shipped_flag		   => l_shipped_flag,
		   x_interface_flag		 => l_interface_flag,
		   x_return_status		  => l_rs);

		 IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
		   EXIT records_loop;
		 END IF;
           --
           --
           -- LSP PROJECT : Populate local table if client info is there on dd.
           IF l_standalone_mode  = 'L' THEN
           --{
             OPEN  c_get_client(p_changed_attributes(l_counter).delivery_detail_id);
             FETCH c_get_client INTO l_client_id;
             CLOSE c_get_client;
             IF ( l_client_id IS NOT NULL) THEN
               l_client_changed_attributes(l_client_changed_attributes.COUNT +1) := p_changed_attributes(l_counter);
             END IF;
           --}
           END IF;
           -- LSP PROJECT : end
           --

	   ELSE

		 IF p_changed_attributes(l_counter).action_flag = 'S' THEN
		   l_source_line_id := p_changed_attributes(l_counter).original_source_line_id;
		 ELSE
		   l_source_line_id := p_changed_attributes(l_counter).source_line_id;
		 END IF;
                 l_found := FALSE; -- LSP PROJECT
		 <<source_line_loop>>
		 FOR c IN c_source_line_to_lock(   l_source_line_id,
										-1*l_source_line_id,
										   p_source_code)	 LOOP
		   Lock_Delivery_Detail(
			 p_delivery_detail_id	 => c.delivery_detail_id,
			 p_source_code			=> p_source_code,
			 x_confirmed_flag		 => l_confirmed_flag,
			 x_shipped_flag		   => l_shipped_flag,
			 x_interface_flag		 => l_interface_flag,
			 x_return_status		  => l_rs);

		   IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
			 EXIT records_loop;
		   END IF;
                   --
                   -- LSP PROJECT : Populate local table if client info is there on dd.
                   IF l_standalone_mode  = 'L' AND c.client_id is NOT NULL AND NOT l_found THEN
                     l_client_changed_attributes(l_client_changed_attributes.COUNT +1) := p_changed_attributes(l_counter);
                     l_found := TRUE;
                   END IF;
                   -- LSP PROJECT : end
                   --

		 --
		 -- Debug Statements
		 --
		 IF l_debug_on THEN
		     WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER LOCKING DELIVERY DETAILS '  );
		 END IF;
		 --

		 END LOOP; -- source_line_loop

	   END IF; -- p_changed_attributes(l_counter).delivery_detail_id <> FND_API.G_MISS_NUM

	 END IF; -- p_changed_attributes(l_counter).action_flag <> 'I'

   END LOOP; -- records_loop
   --
  -- Do we allow actions if the delivery lines are shipped or in confirmed deliveries?
  -- 5870774 : Extending/bypass this check for OKE also, since we are to allow cancellation of wdds not CLOSED or CO/ IT
  IF   (p_source_code <> 'INV' and  p_source_code <> 'OKE')
	 AND (l_interface_flag = 'N')
	 AND (l_confirmed_flag OR l_shipped_flag)
     --Standalone project
     AND nvl(l_standalone_mode, 'I') = 'I' THEN
	FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_ATTR_NOT_ALLOWED');
	l_rs := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.add_message (l_rs);
  END IF;

  --Standalone project - Start
  -- LSP PROJECT : In case of LSP mode, request can come from both LSP orders as well as
  --          normal orders and hence needs to check order lines based on clientId value
  --          and pass only records which are having clientId populated.
  IF p_source_code = 'OE' and
     (l_standalone_mode = 'D' OR (l_standalone_mode = 'L' AND l_client_changed_attributes.COUNT > 0 ))
     and (l_confirmed_flag OR l_shipped_flag)
  THEN
     IF (l_standalone_mode = 'D') THEN
       WSH_SHIPMENT_REQUEST_PKG.Validate_Delivery_Line(
         p_changed_attributes => p_changed_attributes,
         x_return_status      => l_rs );
     ELSE
       WSH_SHIPMENT_REQUEST_PKG.Validate_Delivery_Line(
         p_changed_attributes => l_client_changed_attributes,
         x_return_status      => l_rs );
     END IF;

     --
     IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'Return Status', l_rs );
     END IF;
     --

     IF l_rs <> WSH_UTIl_CORE.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('WSH', 'WSH_UPDATE_ATTR_NOT_ALLOWED');
        l_rs := WSH_UTIL_CORE.G_RET_STS_ERROR;
        WSH_UTIL_CORE.add_message (l_rs);
     END IF;
  END IF;
  --Standalone project - End

  x_return_status  := l_rs;
  x_interface_flag := l_interface_flag;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
EXCEPTION
  WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	wsh_util_core.default_handler('WSH_INTERFACE.Lock_Records');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Lock_Records;



PROCEDURE Lock_Delivery_Detail(
  p_delivery_detail_id	 IN		  NUMBER,
  p_source_code			IN		  VARCHAR2,
  x_confirmed_flag		 IN OUT NOCOPY 	  BOOLEAN,
  x_shipped_flag		   IN OUT NOCOPY 	  BOOLEAN,
  x_interface_flag		 IN OUT NOCOPY 	  VARCHAR2,
  x_return_status			 OUT NOCOPY 	  VARCHAR2) IS

  RECORD_LOCKED		 EXCEPTION;
  PRAGMA EXCEPTION_INIT(RECORD_LOCKED, -54);

  l_rs		  VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  l_dummy_id	NUMBER;
  l_del_status_code VARCHAR2(2);
  l_det_status_code VARCHAR2(2);
  l_ship_set_id     NUMBER;
  l_source_header_id NUMBER;

  -- Bug 2470320: Check if the line belongs to a ship set that
  -- has a line that is alredy pending interface.

  cursor c_check_ship_set(c_ship_set IN NUMBER, c_source_header_id IN NUMBER) is
  select ship_set_id
  from wsh_delivery_details
  where source_header_id = c_source_header_id
  and   ship_set_id = c_ship_set
  and   source_code = p_source_code
  and   oe_interfaced_flag = 'P'
  and   rownum = 1;

  -- bug 2068226: check oe_interfaced_flag = 'P'
  -- instead of looking for negative source_line_id,
  -- in case order lines are fully shipped in a stop being interfaced.
  l_interfaced_flag VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_DELIVERY_DETAIL';
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
      WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_DETAIL_ID',P_DELIVERY_DETAIL_ID);
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'X_CONFIRMED_FLAG',X_CONFIRMED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_SHIPPED_FLAG',X_SHIPPED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_INTERFACE_FLAG',X_INTERFACE_FLAG);
  END IF;
  --
  -- Bug 2684221: Lock the delivery only if source_code is not 'INV'
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'BEFORE LOCKING DELIVERY DETAILS '  );
  END IF;

  SELECT wdd.oe_interfaced_flag,
         wdd.released_status,
         wdd.ship_set_id,
         wdd.source_header_id,
         wda.delivery_id
  INTO   l_interfaced_flag,
         l_det_status_code,
         l_ship_set_id,
         l_source_header_id,
         l_dummy_id
  FROM   wsh_delivery_details wdd,
         wsh_delivery_assignments_v wda
  WHERE  wdd.delivery_detail_id = p_delivery_detail_id
  AND    wdd.delivery_detail_id = wda.delivery_detail_id
  AND    wdd.container_flag = 'N'
  FOR    UPDATE NOWAIT;

  IF l_interfaced_flag = 'P' THEN
	x_interface_flag := 'Y';
  END IF;

  IF (p_source_code = 'INV') THEN
     IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name, 'SOURCE CODE IS INV '  );
       WSH_DEBUG_SV.logmsg(l_module_name, 'Do not Lock the Delivery if source_code is INV');
     END IF;
    -- Do not Lock the Delivery if source_code is 'INV'
    IF (l_dummy_id IS NOT NULL) THEN
      SELECT wnd.status_code
      INTO   l_del_status_code
      FROM   wsh_new_deliveries wnd
      WHERE  wnd.delivery_id = l_dummy_id;
    ELSE
      l_del_status_code := 'OP';
    END IF;
  ELSE
    -- Lock the Delivery if source_code is other than 'INV'
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'SOURCE CODE IS NOT INV '  );
      WSH_DEBUG_SV.logmsg(l_module_name, 'Lock the Delivery if source_code is not INV');
    END IF;
    IF (l_dummy_id IS NOT NULL) THEN
      SELECT wnd.status_code
      INTO   l_del_status_code
      FROM   wsh_new_deliveries wnd
      WHERE  wnd.delivery_id = l_dummy_id
      FOR    UPDATE NOWAIT;
    ELSE
      l_del_status_code := 'OP';
    END IF;
  END IF;

  -- Bug 2470320: If the line is shipped, or the delivery is confirmed, we
  -- check if the line belongs to a ship set that
  -- has a line that is alredy pending interface.

  IF (l_del_status_code = 'CO') OR (l_det_status_code = 'C') THEN

    IF (x_interface_flag) <> 'Y' AND  (l_ship_set_id IS NOT NULL) THEN

       OPEN c_check_ship_set(l_ship_set_id, l_source_header_id);
       FETCH c_check_ship_set into l_ship_set_id;

       IF c_check_ship_set%FOUND THEN

         x_interface_flag := 'Y';

       END IF;

       CLOSE c_check_ship_set;

    END IF;

    IF (l_del_status_code = 'CO')  THEN
      x_confirmed_flag := TRUE;
    END IF;
    IF l_det_status_code = 'C' THEN
      x_shipped_flag := TRUE;
    END IF;

  END IF;

  x_return_status := l_rs;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
	WHEN RECORD_LOCKED THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FND_MESSAGE.Set_Name('WSH', 'WSH_NO_LOCK');
	  WSH_UTIL_CORE.add_message (x_return_status);
--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
END IF;
--
	  RETURN;

	WHEN others THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_INTERFACE.Lock_Delivery_Detail');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Lock_Delivery_Detail;



PROCEDURE Process_Records(
  p_source_code			IN	 VARCHAR2,
  p_changed_attributes	 IN	 ChangedAttributeTabType,
  p_interface_flag		 IN	 VARCHAR2,
  x_return_status		  OUT NOCOPY 	VARCHAR2
) IS

l_counter		 NUMBER;
l_rs			  VARCHAR2(1) := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
l_update_allowed  VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_RECORDS';
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
      WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
      WSH_DEBUG_SV.log(l_module_name,'P_INTERFACE_FLAG',P_INTERFACE_FLAG);
  END IF;
  --
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'IN WSH_INTERFACE.PROCESS_RECORDS'  );
  END IF;
  --

  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'CHECKING CODE RELEASE LEVEL' );
  END IF;
  --
  IF  WSH_CODE_CONTROL.Get_Code_Release_Level >= '110508' then
    /* H integration: 940/945 bug 2312168 wrudge
    **   During OM Interface, allow updates/splits to happen.
    **   Otherwise, check if changes are allowed.
    */
    IF p_interface_flag <> 'Y' THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING WSH_DELIVERY_UTIL.CHECK_UPDATES_ALLOWED'  );
       END IF;
       --
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_UTIL.CHECK_UPDATES_ALLOWED',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_DELIVERY_UTIL.Check_Updates_Allowed(
                p_changed_attributes => p_changed_attributes,
                p_source_code        => p_source_code,
                x_update_allowed     => l_update_allowed,
                x_return_status      => l_rs);
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING CHECK_UPDATES_ALLOWED ' || L_RS  );
       END IF;
       --
       -- TPW - Distributed Organization Changes - Start
       IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
       --
          IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_DETAILS_UTILITIES.Check_Updates_Allowed',WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          --
          WSH_DELIVERY_DETAILS_UTILITIES.Check_Updates_Allowed(
 	                    p_changed_attributes => p_changed_attributes,
 	                    p_source_code        => p_source_code,
 	                    x_update_allowed     => l_update_allowed,
 	                    x_return_status      => l_rs);
          --
          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'After Calling WSH_DELIVERY_DETAILS_UTILITIES.Check_Updates_Allowed', l_rs);
          END IF;
          --
       END IF;
       -- TPW - Distributed Organization Changes - End
    END IF;
  END IF;


  IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN

    IF p_interface_flag = 'N' THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING WSH_USA_ACTIONS_PVT.IMPORT_RECORDS'  );
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_ACTIONS_PVT.IMPORT_RECORDS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_USA_ACTIONS_PVT.Import_Records(
		p_source_code		=> p_source_code,
		p_changed_attributes => p_changed_attributes,
		x_return_status	  => l_rs);
    END IF;
  --
  -- Debug Statements
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'AFTER CALLING WSH_USA_ACTIONS_PVT.IMPORT_RECORDS '|| L_RS  );
  END IF;
  --
  END IF;

  IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING WSH_USA_ACTIONS_PVT.SPLIT_RECORDS'  );
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_ACTIONS_PVT.SPLIT_RECORDS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_USA_ACTIONS_PVT.Split_Records(
	  p_source_code		=> p_source_code,
	  p_changed_attributes => p_changed_attributes,
	  p_interface_flag	 => p_interface_flag,
	  x_return_status	  => l_rs);
  END IF;

  IF l_rs NOT IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING WSH_USA_ACTIONS_PVT.UPDATE_RECORDS'  );
	END IF;
	--
	--
	-- Debug Statements
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_ACTIONS_PVT.UPDATE_RECORDS',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--
	WSH_USA_ACTIONS_PVT.Update_Records(
	  p_source_code		=> p_source_code,
	  p_changed_attributes => p_changed_attributes,
	  p_interface_flag	 => p_interface_flag,
	  x_return_status	  => l_rs);
  END IF;

  -- bug 2111278
  <<record_loop>>
  FOR l_counter IN p_changed_attributes.FIRST ..p_changed_attributes.LAST LOOP
    IF p_changed_attributes(l_counter).action_flag = 'D' THEN
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name, 'CALLING WSH_USA_QUANTITY_PVT.UPDATE_ORDERED_QUANTITY'  );
       END IF;
       --
       --
       -- Debug Statements
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_USA_QUANTITY_PVT.UPDATE_ORDERED_QUANTITY',WSH_DEBUG_SV.C_PROC_LEVEL);
       END IF;
       --
       WSH_USA_QUANTITY_PVT.Update_Ordered_Quantity(
                p_changed_attribute  =>p_changed_attributes(l_counter),
                p_source_code        =>p_source_code,
                p_action_flag        => 'D',
                x_return_status      => l_rs);

        IF l_rs <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                x_return_status := l_rs;
                exit;
        END IF;
    END IF;

  END LOOP;
  --

  x_return_status := l_rs;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION
	WHEN OTHERS THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	  wsh_util_core.default_handler('WSH_INTERFACE.Process_Records');

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END Process_Records;


/*  Bug 2313898 To avoid the null messages , IF name is NOT NULL included */
PROCEDURE PRINTMSG (txt VARCHAR2,
					name VARCHAR2 DEFAULT NULL ) IS
					--
l_debug_on BOOLEAN;
					--
					l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PRINTMSG';
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
	     WSH_DEBUG_SV.log(l_module_name,'TXT',TXT);
	     WSH_DEBUG_SV.log(l_module_name,'NAME',NAME);
	 END IF;
	 --
	 IF ( g_call_mode = 'CONC' ) THEN
	   --
	   -- Debug Statements
	   --
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,  TXT  );
	   END IF;
	   --
	 ELSE
                IF name is NOT NULL then
	           FND_MESSAGE.SET_NAME('WSH', name);
		   WSH_UTIL_CORE.add_message ('E');
		END IF;
	 END IF;
	 --
	 -- Debug Statements
	 --
	 IF l_debug_on THEN
	     WSH_DEBUG_SV.pop(l_module_name);
	 END IF;
	 --
END PRINTMSG;

-- anxsharm for Load Tender
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get_Details_Snapshot
   PARAMETERS : p_source_code - Input Source Code
                p_changed_attributes Table of changed attributes for detail
                p_phase - 1 for Before the action is performed, 2 for after.
                x_dd_ids - Table of Delivery Detail ids
                x_out_table - attributes of snap shot
                x_return_status - Return Status
  DESCRIPTION : This procedure gets attributes of delivery detail
                Added for Load Tender Project but this is independent of
                FTE is installed or not.
------------------------------------------------------------------------------
*/

PROCEDURE Get_Details_Snapshot(
           p_source_code IN VARCHAR2,
           p_changed_attributes  IN ChangedAttributeTabType,
           p_phase IN NUMBER,
           x_dd_ids IN OUT NOCOPY wsh_util_core.id_tab_type,
           x_out_table OUT NOCOPY wsh_interface.deliverydetailtab,
           x_return_status OUT NOCOPY VARCHAR2) IS

-- use delivery detail id
  CURSOR get_dd_for_id (v_delivery_detail_id NUMBER)IS
    SELECT wdd.delivery_detail_id,
           wdd.requested_quantity,
           wdd.shipped_quantity,
           wdd.picked_quantity,
           wdd.gross_weight,
           wdd.net_weight,
           wdd.weight_uom_code,
           wdd.volume,
           wdd.volume_uom_code,
           wda.delivery_id,
           wda.parent_delivery_detail_id,
           wdd.released_status
      FROM wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda
     WHERE wdd.delivery_detail_id = v_delivery_detail_id
       AND wdd.delivery_detail_id = wda.delivery_detail_id;
-- cannot add wda.delivery_id is not null because this is a generic
-- API and not specific for FTE

-- use source line id
  CURSOR get_dd_for_srcline (v_source_line_id NUMBER)IS
    SELECT wdd.delivery_detail_id,
           wdd.requested_quantity,
           wdd.shipped_quantity,
           wdd.picked_quantity,
           wdd.gross_weight,
           wdd.net_weight,
           wdd.weight_uom_code,
           wdd.volume,
           wdd.volume_uom_code,
           wda.delivery_id,
           wda.parent_delivery_detail_id,
           wdd.released_status
      FROM wsh_delivery_details wdd,
           wsh_delivery_assignments_v wda
     WHERE wdd.source_line_id = v_source_line_id
       AND wdd.delivery_detail_id = wda.delivery_detail_id
       AND nvl(wdd.line_direction, 'O') IN ('O', 'IO');
  i NUMBER;
  l_dd_rec wsh_interface.delivery_detail_rec;
  l_dd_tab wsh_interface.deliverydetailtab;
  l_dd_ids wsh_util_core.id_tab_type;
  l_source_line_id wsh_delivery_details.source_line_id%TYPE;
--
  l_debug_on BOOLEAN;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DETAILS_SNAPSHOT';
--

BEGIN

  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    --
    WSH_DEBUG_SV.log(l_module_name,'source code',p_source_code);
    WSH_DEBUG_SV.log(l_module_name,'Changedattribute - count',p_changed_attributes.count);
    WSH_DEBUG_SV.log(l_module_name,'Phase',p_phase);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_dd_tab.delete;

  --bug 2769339
  IF (p_changed_attributes.count>=1) THEN

    FOR i IN p_changed_attributes.FIRST..p_changed_attributes.LAST
    LOOP

      IF p_source_code = 'INV' THEN
        -- use delivery detail id
        OPEN get_dd_for_id(p_changed_attributes(i).delivery_detail_id);
        FETCH get_dd_for_id
         INTO l_dd_rec;
        CLOSE get_dd_for_id;
      ELSIF p_source_code <> 'INV' THEN
        IF p_changed_attributes(i).action_flag = 'S' THEN
          -- use original source_line_id
          l_source_line_id := p_changed_attributes(i).original_source_line_id;
        ELSIF p_changed_attributes(i).action_flag = 'U' THEN
          -- use source_line_id for action of 'U'
          l_source_line_id := p_changed_attributes(i).source_line_id;
        END IF;
        OPEN get_dd_for_srcline(l_source_line_id);
        FETCH get_dd_for_srcline
         INTO l_dd_rec;
        CLOSE get_dd_for_srcline;
      END IF;
      l_dd_tab(l_dd_tab.count + 1) := l_dd_rec;
      l_dd_ids(l_dd_ids.count + 1) := l_dd_rec.delivery_detail_id;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'l_dd_rec.delivery_detail_id',l_dd_rec.delivery_detail_id);
      END IF;
    END LOOP;

    x_dd_ids := l_dd_ids;
    x_out_table := l_dd_tab;

  END IF;


  IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN others THEN
    wsh_util_core.default_handler('WSH_INTERFACE.get_details_snapshot');
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;


END Get_Details_Snapshot;

-- anxsharm for Load Tender

END WSH_INTERFACE;

/
