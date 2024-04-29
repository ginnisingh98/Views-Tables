--------------------------------------------------------
--  DDL for Package Body WSH_SHIPPING_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SHIPPING_INFO" as
/* $Header: WSHSHINB.pls 120.2.12010000.2 2009/07/30 11:18:56 ueshanka ship $ */

/*
--  FILENAME
--
--      WSHSHINB.pls
--
--  DESCRIPTION
--
--      Body of package WSH_SHIPPING_INFO
--
--  NOTES
--
--  HISTORY
--
--  Aug  15, 2001     Raju Varghese                Bug#1924574 for hr_locations
--       : Removed Calls to hr_locations
--       : Using API WSH_UTIL_CORE.get_location_desriptions instead for HR changes
--         and performance Reasons.
--
*/

--
-- Package exceptions
--

  wsh_tracking_exception	EXCEPTION;

  wsh_unexpected_error	EXCEPTION;

--
--  Procedure:		Fill_Track_Record
--  Parameters:		p_record_number - Tracking record number
--			p_delivery_status - Delivery status
--			p_trip_name - Trip name
--			p_location_name - Location name
--			p_actual_arrival_date - Actual arrival date
--			p_actual_departure_date - Actual departure date
--			p_ship_method_code - Ship method code
--                      p_carrier_name     - Carrier Name (For Bug 5697730)
--			p_bill_of_lading - Bill of Lading
--			x_tracking_details - Tracking Record
--  Description:	This procedure will populates the Tracking
--			record table with information based on the
--			record number
--

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SHIPPING_INFO';
  --
  PROCEDURE Fill_Track_Record
		(p_record_number		IN   VARCHAR2,
		 p_delivery_status		IN   VARCHAR2 ,
		 p_trip_name			IN   VARCHAR2 ,
		 p_location_name		IN   VARCHAR2 ,
		 p_actual_arrival_date		IN   DATE ,
		 p_actual_departure_date	IN   DATE ,
		 p_ship_method_code		IN   VARCHAR2 ,
		 p_bill_of_lading		IN   VARCHAR2 ,
                 p_carrier_name                 IN   VARCHAR2, -- Bug 5697730
		 x_tracking_details		IN OUT NOCOPY  Tracking_Info_Tab_Typ
		) IS

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FILL_TRACK_RECORD';
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
        WSH_DEBUG_SV.log(l_module_name,'P_RECORD_NUMBER',P_RECORD_NUMBER);
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_STATUS',P_DELIVERY_STATUS);
        WSH_DEBUG_SV.log(l_module_name,'P_TRIP_NAME',P_TRIP_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_LOCATION_NAME',P_LOCATION_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_ACTUAL_ARRIVAL_DATE',P_ACTUAL_ARRIVAL_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_ACTUAL_DEPARTURE_DATE',P_ACTUAL_DEPARTURE_DATE);
        WSH_DEBUG_SV.log(l_module_name,'P_SHIP_METHOD_CODE',P_SHIP_METHOD_CODE);
        WSH_DEBUG_SV.log(l_module_name,'P_BILL_OF_LADING',P_BILL_OF_LADING);
        WSH_DEBUG_SV.log(l_module_name,'P_CARRIER_NAME',P_CARRIER_NAME);
    END IF;
    --
    IF p_record_number IS NULL THEN
      FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
      Raise Wsh_Tracking_Exception;
    END IF;

    x_tracking_details(p_record_number).delivery_status := p_delivery_status;

    x_tracking_details(p_record_number).trip_name := p_trip_name;

    x_tracking_details(p_record_number).location_name := p_location_name;

    x_tracking_details(p_record_number).actual_arrival_date
           := p_actual_arrival_date;

    x_tracking_details(p_record_number).actual_departure_date
		:= p_actual_departure_date;

    x_tracking_details(p_record_number).ship_method_code
		:= p_ship_method_code;

    x_tracking_details(p_record_number).bill_of_lading
		:= p_bill_of_lading;
    --
    -- Bug 5697730
    x_tracking_details(p_record_number).carrier_name := p_carrier_name;
    --

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Fill_Track_Record;


--
--  Procedure:		Track_Delivery
--  Parameters:		p_delivery_name - Name of Delivery to track
--			p_mode - 'FULL' or 'CURRENT'
--			x_tracking_details - Record of all the tracking
--			                     details for a shipment
--  Description:	This procedure will provide tracking information
--			for a delivery
--

  PROCEDURE Track_Delivery
		(p_delivery_name	IN   VARCHAR2,
		 p_mode			IN   VARCHAR2,
		 x_tracking_details	OUT NOCOPY   Tracking_Info_Tab_Typ
		) IS
-- 1924574 Changes: Removed the hr_locations join and passing  dl.initial_pickup_location_id
--                  to WSH_UTIL_CORE.get_location_description
  CURSOR get_delivery_info (v_delivery_name VARCHAR2) IS
  SELECT wl.meaning status,
	 to_char(NULL) name,
         WSH_UTIL_CORE.get_location_description(dl.initial_pickup_location_id,'CSZ') pickup_loc,
	 to_date(NULL) pu_arrival_date,
	 to_date(NULL) pu_departure_date,
	 to_char(NULL) dropoff_loc,
	 to_date(NULL) do_arrival_date,
	 to_date(NULL) do_departure_date,
	 dl.ship_method_code,
         hp.party_name carrier_name, -- Bug 5697730
	 to_char(NULL) bill_of_lading
  FROM	 wsh_lookups wl,
	 wsh_new_deliveries dl,
         hz_parties hp, hz_party_usg_assignments hpu
  WHERE	 dl.name = v_delivery_name
  AND    hp.party_id(+) = dl.carrier_id -- Bug 5697730
  AND    hp.party_id = hpu.party_id(+) -- Bug 5697730
  AND    hpu.party_usage_code(+) = 'TRANSPORTATION_PROVIDER' -- Bug 5697730
  AND	 wl.lookup_type = 'DELIVERY_STATUS'
  AND	 wl.lookup_code = dl.status_code
  AND    nvl(dl.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO') -- J inbound logistics jckwok
  AND	 dl.status_code not in ('CL','IT'); -- sperera 940/945 -- sperera 940/945

  l_del get_delivery_info%ROWTYPE;

-- 1924574 Changes: Removed the joins with hr_locations join and passing  ts1,ts2.stop_location_id
--                  to WSH_UTIL_CORE.get_location_description

-- Bug 3146273 : Removed the wsh_document_instances table from the Cursor
--               "get_shipped_delivery_info"
--               and added new cursor "get_bill_of_lading" to get the sequence_number from the
--               wsh_document_instances table

  CURSOR get_bill_of_lading(v_delivery_leg_id VARCHAR2) IS
  SELECT sequence_number  bill_of_lading
  FROM   wsh_document_instances
  WHERE  entity_id = v_delivery_leg_id
  AND    entity_name = 'WSH_DELIVERY_LEGS'
  AND    status <> 'CANCELLED' --Bug 8597679 :Added the condition to filter out cancelld BOl
  AND    document_type= 'BOL';

  CURSOR get_trip_delivery_info (v_delivery_name VARCHAR2) IS
  SELECT wl.meaning status,
	 t.name,
	 WSH_UTIL_CORE.get_location_description(ts1.stop_location_id,'CSZ') pickup_loc,
	 ts1.actual_arrival_date pu_arrival_date,
	 ts1.actual_departure_date pu_departure_date,
	 WSH_UTIL_CORE.get_location_description(ts2.stop_location_id,'CSZC') dropoff_loc,
	 ts2.actual_arrival_date do_arrival_date,
	 ts2.actual_departure_date do_departure_date,
	 t.ship_method_code,
         hp.party_name carrier_name, -- Bug 5697730
         dg.delivery_leg_id
  FROM	 wsh_lookups wl,
	 wsh_trips t,
	 wsh_trip_stops ts1,
	 wsh_trip_stops ts2,
	-- wsh_document_instances di,   -- Bug 3146273
	 wsh_delivery_legs dg,
	 wsh_new_deliveries dl,
         hz_parties hp, hz_party_usg_assignments hpu -- Bug 5697730
  WHERE	 dl.name = v_delivery_name
  AND    hp.party_id(+) = t.carrier_id -- Bug 5697730
  AND    hp.party_id = hpu.party_id(+) -- Bug 5697730
  AND    hpu.party_usage_code(+) = 'TRANSPORTATION_PROVIDER' -- Bug 5697730
  AND	 dg.delivery_id = dl.delivery_id
  AND	 dg.pick_up_stop_id = ts1.stop_id
 -- AND	 ts1.status_code = 'CL'
  AND	 dg.drop_off_stop_id = ts2.stop_id
  AND	 ts1.trip_id = t.trip_id
  --AND	 dg.delivery_leg_id = di.entity_id(+)   -- Bug 3146273
  AND	 wl.lookup_type = 'DELIVERY_STATUS'
  AND	 wl.lookup_code = dl.status_code
  AND    nvl(dl.SHIPMENT_DIRECTION , 'O') IN ('O', 'IO') -- J inbound logistics jckwok
  ORDER BY ts1.planned_arrival_date asc;

  l_trip_del get_trip_delivery_info%ROWTYPE;

  l_tmpTrackLine Tracking_Info_Rec_Typ;
  l_bill_of_lading wsh_document_instances.sequence_number%TYPE:= null;

  i	NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRACK_DELIVERY';
--
  BEGIN

    -- First, get Unshipped Delivery Information
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
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_DELIVERY_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
    END IF;
    --
    --Get Delivery With Trip Details
    OPEN    get_trip_delivery_info(p_delivery_name);
    i := 0;
    LOOP
      FETCH   get_trip_delivery_info
      INTO    l_trip_del;
      EXIT WHEN get_trip_delivery_info%NOTFOUND;
      -- BUG 3146273: jckwok: open get_bill_of_lading with new leg id
      OPEN    get_bill_of_lading (l_trip_del.delivery_leg_id);
      l_bill_of_lading := null;
      FETCH   get_bill_of_lading
      INTO    l_bill_of_lading;
      CLOSE get_bill_of_lading;
      -- BUG 3146273: jckwok

      -- Update Current record information, arrival date is
      -- previous entries arrival date at location
      i := i + 1;
      Fill_Track_Record (
        p_record_number		=> i,
        p_delivery_status	=> l_trip_del.status,
        p_trip_name		=> l_trip_del.name,
        p_location_name		=> l_trip_del.pickup_loc,
        p_actual_arrival_date	=> FND_API.G_MISS_DATE,
        p_actual_departure_date	=> l_trip_del.pu_departure_date,
        p_ship_method_code	=> l_trip_del.ship_method_code,
        p_bill_of_lading	=> l_bill_of_lading,
        p_carrier_name          => l_trip_del.carrier_name, -- Bug 5697730
        x_tracking_details	=> x_tracking_details);
      i := i + 1;
      Fill_Track_Record (
        p_record_number		=> i,
        p_delivery_status	=> l_trip_del.status,
        p_trip_name		=> l_trip_del.name,
        p_location_name		=> l_trip_del.dropoff_loc,
        p_actual_arrival_date	=> l_trip_del.do_arrival_date,
        p_actual_departure_date	=> NULL,
        p_ship_method_code	=> NULL,
        p_bill_of_lading	=> NULL,
        p_carrier_name          => NULL, -- Bug 5697730
        x_tracking_details	=> x_tracking_details);
      -- Avoid infinite loop problem by terminating on
      -- large number
      IF i = 100 THEN
        FND_MESSAGE.Set_Name('WSH','WSH_UNEXP_ERROR');
	      RAISE wsh_unexpected_error;
      END IF;
    END LOOP;
    CLOSE get_trip_delivery_info;

    IF i=0 THEN --Get Delivery Without Trip
      OPEN    get_delivery_info(p_delivery_name);
      FETCH   get_delivery_info INTO   l_del;
      IF get_delivery_info%FOUND THEN
        i := i + 1;
        Fill_Track_Record (
          p_record_number		=> i,
          p_delivery_status	=> l_del.status,
          p_trip_name		=> l_del.name,
          p_location_name		=> l_del.pickup_loc,
          p_actual_arrival_date	=> NULL,
          p_actual_departure_date	=> l_del.pu_departure_date,
          p_ship_method_code	=> l_del.ship_method_code,
          p_bill_of_lading	=> l_del.bill_of_lading,
          p_carrier_name        => l_del.carrier_name, -- Bug 5697730
          x_tracking_details	=> x_tracking_details);
      END IF;
      CLOSE get_delivery_info;
     ELSE
        IF p_mode = 'CURRENT' THEN
          l_tmpTrackLine := x_tracking_details(x_tracking_details.LAST);
    -- Bug: 1114924 since the last record in the table will always have NULL BOL and should be same as the previous one.
          l_tmpTrackLine.bill_of_lading := x_tracking_details(x_tracking_details.count-1).bill_of_lading;
    -- Bug: 1570332 since the last record in the table will always have NULL ship method code and should be same as the previous one.
          l_tmpTrackLine.ship_method_code := x_tracking_details(x_tracking_details.count-1).ship_method_code;
          l_tmpTrackLine.carrier_name := x_tracking_details(x_tracking_details.count-1).carrier_name; -- Bug 5697730
          l_tmpTrackLine.actual_departure_date := x_tracking_details(x_tracking_details.count-1).actual_departure_date;
          x_tracking_details.DELETE;
          x_tracking_details(1) := l_tmpTrackLine;
        END IF;
    END IF;
    IF(i=0) THEN
      FND_MESSAGE.Set_Name('WSH','WSH_UNEXP_ERROR');
      RAISE wsh_unexpected_error;
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
      IF get_trip_delivery_info%ISOPEN THEN
        CLOSE get_trip_delivery_info;
      END IF;
      IF get_delivery_info%ISOPEN THEN
        CLOSE get_delivery_info;
      END IF;
      IF get_bill_of_lading%ISOPEN THEN
        CLOSE get_bill_of_lading;
      END IF;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      --
      RAISE;

  END Track_Delivery;

--
--  Procedure:		Track_Shipment
--  Parameters:		p_delivery_name - Name of Delivery to track
--			p_tracking_number_dd - Tracking Number of Delivery
--			                       Line
--			p_mode - 'FULL' or 'CURRENT'
--			         'FULL' Gives complete tracking information
--			         'CURRENT' Provides simple tracking information
--			         a) If the delivery is not shipped, initial
--			            trip/location information is provided
--			         b) If the delivery is shipped, it provides
--			            the current shipment information
--				 c) If the delivery has been delivered, it
--			            provides the final trip/location
--				    information when delivered to the
--				    customer
--			x_tracking_details - Record of all the tracking
--			                     details for a shipment
--			x_return_status - Status of procedure call
--			                  - FND_API.G_RET_STS_SUCCESS
--			                  - FND_API.G_RET_STS_ERROR
--  Description:	This procedure will provide tracking information
--			for a shipment
--

  PROCEDURE Track_Shipment
		(p_delivery_name	IN   VARCHAR2 DEFAULT NULL,
		 p_tracking_number_dd	IN   VARCHAR2 DEFAULT NULL,
		 p_mode			IN   VARCHAR2,
		 x_tracking_details	OUT NOCOPY   Tracking_Info_Tab_Typ,
		 x_return_status	OUT NOCOPY   VARCHAR2
		) IS

	l_delivery_name	VARCHAR2(30);
	--
	l_debug_on BOOLEAN;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'TRACK_SHIPMENT';
	--
  BEGIN
    -- Setup parameters
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
        WSH_DEBUG_SV.log(l_module_name,'P_DELIVERY_NAME',P_DELIVERY_NAME);
        WSH_DEBUG_SV.log(l_module_name,'P_TRACKING_NUMBER_DD',P_TRACKING_NUMBER_DD);
        WSH_DEBUG_SV.log(l_module_name,'P_MODE',P_MODE);
    END IF;
    --
    x_tracking_details.delete;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate parameters
    IF p_delivery_name IS NULL  THEN
      FND_MESSAGE.Set_Name('WSH','WSH_NO_TRACKING_INFO_SPECIFIED');
      RAISE wsh_tracking_exception;
    END IF;

    IF p_mode NOT IN ('FULL','CURRENT') THEN
      FND_MESSAGE.Set_Name('WSH','WSH_INVALID_TRACKING_MODE');
      RAISE wsh_tracking_exception;
    END IF;

    --Bug 3639940
    IF p_delivery_name IS NOT NULL THEN
	Track_Delivery(p_delivery_name, p_mode, x_tracking_details);
    END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION

  WHEN wsh_tracking_exception THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
     IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_TRACKING_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_TRACKING_EXCEPTION');
     END IF;
      --

    WHEN wsh_unexpected_error THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      --
      -- Debug Statements
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'WSH_UNEXPECTED_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
          WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_UNEXPECTED_ERROR');
      END IF;
      --
    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

	--
	-- Debug Statements
	--

IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
END IF;
--
END;
END WSH_SHIPPING_INFO;

/
