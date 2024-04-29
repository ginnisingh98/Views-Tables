--------------------------------------------------------
--  DDL for Package Body WSH_DATA_PROTECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DATA_PROTECTION" as
/* $Header: WSHUTDPB.pls 120.0 2005/05/26 18:36:34 appldev noship $ */

	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_DATA_PROTECTION';
	p_message_type	CONSTANT VARCHAR2(1) := 'E';

--
--  Procedure:	Get_Disabled_List
--
--  Parameters:	p_entity_type - type of entity: DLVB, DLVY, DLEG, STOP, TRIP
--                p_entity_id - Id for entity
--                p_parent_entity_id - Parent Id for entity:
--                                    DLVY is parent for DLVB and DLEG
--                                    TRIP is parent for STOP
--	                p_entity_status - Status of entity
--                p_entity_planned_state - Planned state of entity
--                p_list_type     - Type of column names to choose
--                                   'WSHFSTRX'  will return STF field names
--                                   unless p_caller is like FTE%
--                x_disabled_list - list of disabled columns
--	                x_return_status - Status of procedure call
--                p_caller        - identify caller; FTE% will get table column names
--
--  Description: This procedure will return a list of disabled columns for
--               update restrictions on the form, unless the first element
--               has the value 'FULL', in which case the list is as below:
--                  'FULL' and list count = 1, means all columns need to
--                       be disabled
--                  'FULL' and list count > 1, means all columns except
--                       the columns that follow are disabled or "entered."
--                  '+column_name' (i.e., column name marked by '+')
--                        means that column_name has "Entered" status,
--                        which is disabled only if the column has a
--                        non-NULL value (i.e., enabled only if NULL).

PROCEDURE Get_Disabled_List (
		-- Standard parameters
		p_api_version					IN NUMBER,
		p_init_msg_list				IN VARCHAR2,
		x_return_status				OUT NOCOPY  VARCHAR2,
		x_msg_count						OUT NOCOPY  NUMBER,
		x_msg_data						OUT NOCOPY  VARCHAR2,

		-- Program Specific Parameters
		p_entity_type    	IN   VARCHAR2,
		p_entity_id		IN   NUMBER,
		p_parent_entity_id 	IN   NUMBER,
      p_list_type            IN   VARCHAR2,
		x_disabled_list    	OUT NOCOPY   wsh_util_core.column_tab_type,
                p_caller                IN   VARCHAR2 DEFAULT NULL
)
IS

	-- standard version infermation
	l_api_version	CONSTANT	NUMBER		:= 1.0;
	l_api_name		CONSTANT	VARCHAR2(30):= 'Get_Disabled_List';

CURSOR get_delivery_status(x_delivery_id NUMBER) IS
  SELECT status_code, planned_flag
  FROM   wsh_new_deliveries
  WHERE  delivery_id = x_delivery_id;

CURSOR has_delivery_details(x_delivery_id NUMBER) IS
  SELECT delivery_assignment_id
  FROM   wsh_delivery_assignments_v
  WHERE  delivery_id = x_delivery_id
  AND    rownum = 1;

CURSOR has_legs(x_delivery_id NUMBER) IS
  SELECT delivery_leg_id
  FROM   wsh_delivery_legs
  WHERE  delivery_id = x_delivery_id
  AND    rownum = 1;

CURSOR get_trip_status(x_entity_id NUMBER) IS
  SELECT status_code, planned_flag
  FROM   wsh_trips
  WHERE  trip_id = x_entity_id;

CURSOR get_stop_status(x_stop_id NUMBER) IS
  SELECT status_code
  FROM   wsh_trip_stops
  WHERE  stop_id = x_stop_id;

CURSOR get_leg_status(x_leg_id NUMBER) IS
  SELECT delivery_id, pick_up_stop_id, drop_off_stop_id
  FROM   wsh_delivery_legs
  WHERE  delivery_leg_id = x_leg_id;

CURSOR has_pick_up_deliveries(x_stop_id NUMBER) IS
  SELECT delivery_id
  FROM   wsh_delivery_legs
  WHERE  pick_up_stop_id = x_stop_id
  AND    rownum = 1;

CURSOR has_drop_off_deliveries(x_stop_id NUMBER) IS
  SELECT delivery_id
  FROM   wsh_delivery_legs
  WHERE  drop_off_stop_id = x_stop_id
  AND    rownum = 1;

	i              NUMBER := 0;
	dummy_id       NUMBER := 0;
	l_status_code  VARCHAR2(10) := NULL;
	l_planned_flag VARCHAR2(10) := NULL;

	l_pick_up_stop	get_stop_status%ROWTYPE;
	l_drop_off_stop get_stop_status%ROWTYPE;
	l_delivery_id  NUMBER := 0;
	l_pick_up_stop_id NUMBER := 0;
	l_drop_off_stop_id NUMBER := 0;

	l_msg_summary					VARCHAR2(2000) := NULL;
	l_msg_details					VARCHAR2(4000) := NULL;

	WSH_INV_LIST_TYPE	EXCEPTION;
	WSH_DP_NO_ENTITY  EXCEPTION;
	WSH_DP_NO_STOP		EXCEPTION;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_DISABLED_LIST';
--
BEGIN

  	-- Standard begin of API savepoint
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
	    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_TYPE',P_ENTITY_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_ENTITY_ID',P_ENTITY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_PARENT_ENTITY_ID',P_PARENT_ENTITY_ID);
	    WSH_DEBUG_SV.log(l_module_name,'P_LIST_TYPE',P_LIST_TYPE);
	    WSH_DEBUG_SV.log(l_module_name,'P_CALLER',P_CALLER);
	END IF;
	--
	SAVEPOINT	Log_Exception_PUB;
	-- Standard call to check for call compatibility.
	IF NOT FND_API.compatible_api_call(	l_api_version,
 													p_api_version,
													l_api_name,
													G_PKG_NAME) THEN
	 	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_boolean(p_init_msg_list)	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- clear up the list table
   x_disabled_list.delete;

    /*
    ***
    **** TRIP
    ***
    */
   IF (p_entity_type = 'TRIP') THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_VALIDATIONS.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_TRIP_VALIDATIONS.Get_Disabled_List(
					p_trip_id  => p_entity_id,
					p_list_type	=> p_list_type,
					x_return_status => x_return_status,
					x_disabled_list =>x_disabled_list,
					x_msg_count  => x_msg_count,
					x_msg_data => x_msg_data,
                                        p_caller   => p_caller
		);


    /*
    ***
    **** STOP
    ***
    */
    ELSIF (p_entity_type = 'TRIP STOP') THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_TRIP_STOPS_PVT.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_TRIP_STOPS_PVT.Get_Disabled_List(
					p_stop_id => p_entity_id,
					p_parent_entity_id => p_parent_entity_id,
					p_list_type	=> p_list_type,
					x_return_status => x_return_status,
					x_disabled_list =>x_disabled_list,
					x_msg_count  => x_msg_count,
					x_msg_data => x_msg_data,
                                        p_caller   => p_caller
		);

	 /*
    ***
    **** DLEG
    ***
    */

    ELSIF (p_entity_type = 'DELIVERY LEG') or
	       (p_entity_type = 'BILL OF LADING') THEN
     --
     -- Debug Statements
     --
     IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_LEGS_PVT.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     --
     WSH_DELIVERY_LEGS_PVT.Get_Disabled_List(
					p_delivery_leg_id => p_entity_id,
					p_parent_entity_id => p_parent_entity_id,
					p_list_type	=> p_list_type,
					x_return_status => x_return_status,
					x_disabled_list =>x_disabled_list,
					x_msg_count  => x_msg_count,
					x_msg_data => x_msg_data
                );


    /*
    ***
    **** DELIVERY DETAIL
    ***
    */



	ELSIF (p_entity_type = 'DELIVERY DETAIL') THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DETAILS_VALIDATIONS.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_DETAILS_VALIDATIONS.Get_Disabled_List(
			p_delivery_detail_id  	=> p_entity_id,
			p_delivery_id				=> p_parent_entity_id,
			p_list_type					=> p_list_type,
			x_return_status			=> x_return_status,
			x_disabled_list 			=> x_disabled_list,
			x_msg_count  				=> x_msg_count,
			x_msg_data 					=> x_msg_data,
                        p_caller   => p_caller
			);

    /*
    ***
    **** DELIVERY
    ***
    */
	ELSIF (p_entity_type = 'DELIVERY') THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_DELIVERY_VALIDATIONS.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_DELIVERY_VALIDATIONS.Get_Disabled_List(
			p_delivery_id  			=> p_entity_id,
			p_list_type					=> p_list_type,
			x_return_status			=> x_return_status,
			x_disabled_list 			=> x_disabled_list,
			x_msg_count  				=> x_msg_count,
			x_msg_data 					=> x_msg_data,
                        p_caller   => p_caller
			);

    /*
    ***
    **** PACK SLIP
    ***
    */
	ELSIF (p_entity_type = 'PACK SLIP') THEN
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PACKING_SLIPS_PVT.GET_DISABLED_LIST',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--
		WSH_PACKING_SLIPS_PVT.Get_Disabled_List(
			p_delivery_id  			=> p_entity_id,
			p_list_type					=> p_list_type,
			x_return_status			=> x_return_status,
			x_disabled_list 			=> x_disabled_list,
			x_msg_count  				=> x_msg_count,
			x_msg_data 					=> x_msg_data
			);

    END IF;


--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  EXCEPTION

  WHEN WSH_DP_NO_ENTITY THEN
		FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_ENTITY');
		WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_ENTITY exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_ENTITY');
		END IF;
		--
  WHEN WSH_DP_NO_STOP THEN
		FND_MESSAGE.SET_NAME('WSH', 'WSH_DP_NO_STOP');
		WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_DP_NO_STOP exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_DP_NO_STOP');
		END IF;
		--
  WHEN WSH_INV_LIST_TYPE THEN
  		FND_MESSAGE.SET_NAME('WSH', 'WSH_INV_LIST_TYPE');
		WSH_UTIL_CORE.ADD_MESSAGE(p_message_type);
		x_return_status := FND_API.G_RET_STS_ERROR;
		WSH_UTIL_CORE.get_messages('Y', l_msg_summary, l_msg_details, x_msg_count);
		if x_msg_count > 1 then
			x_msg_data := l_msg_summary || l_msg_details;
		else
			x_msg_data := l_msg_summary;
		end if;
		--
		-- Debug Statements
		--
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'WSH_INV_LIST_TYPE exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
		    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:WSH_INV_LIST_TYPE');
		END IF;
		--
  WHEN OTHERS THEN
    IF get_delivery_status%ISOPEN THEN
      CLOSE get_delivery_status;
    END IF;
    IF has_delivery_details%ISOPEN THEN
      CLOSE has_delivery_details;
    END IF;
    IF has_legs%ISOPEN THEN
      CLOSE has_legs;
    END IF;

    IF get_trip_status%ISOPEN THEN
      CLOSE get_trip_status;
    END IF;

    FND_MESSAGE.Set_Name('WSH','WSH_UNEXPECTED_ERROR');
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


END WSH_DATA_PROTECTION;

/
