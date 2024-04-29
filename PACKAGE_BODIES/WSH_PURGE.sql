--------------------------------------------------------
--  DDL for Package Body WSH_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_PURGE" AS
/* $Header: WSHPURGB.pls 120.4.12010000.3 2009/03/05 07:32:44 selsubra ship $ */

-- Description: Constant to distinguish CONCURRENT request from
-- ONLINE request
G_CONC_REQ VARCHAR2(1) := FND_API.G_TRUE;

--Package Name
G_PKG_NAME 	CONSTANT VARCHAR2(50):='WSH_PURGE';

-----------------------------------------------------------------------------
--
-- Procedure:   Process_Purge
-- Parameters:	errbuf	 Parameter for the Concurrent Program to get the error.
--		retcode	 Parameter for the Concurrent Program to get the return code
--		p_execution_mode  Specifies whether to Purge Data or View Purge Set
--		p_source_system	 Only the delivery details belonging to this Source System
--				 would be considered eligible for Purge
--		p_ship_from_org	 Only the deliveries belonging to this Ship From Org
--				 would be considered eligible for Purge
--		p_order_number_from  Only the delivery details having source_header_number
--				     greater than Order Number From would be considered eligible for Purge
--		p_order_number_to  Only the delivery details having source_header_number
--				   less than Order Number To would be considered eligible for Purge
--		p_order_type  Only the delivery details belonging to this Order Type
--			      would be considered eligible for Purge
--		p_ship_date_from  Only the deliveries having initial_pickup_date greater
--				  than Ship Date From would be considered eligible for Purge
--		p_ship_date_to  Only the deliveries having initial_pickup_date less than
--				Ship Date To would be considered eligible for Purge
--		p_delete_beyond_x_ship_days  Only the deliveries having initial_pickup_date less
--					     than the specified date would be considered eligible for Purge
--		p_purge_intransit_trips	Decides whether to purge In Transit Trips or not
--		p_delete_empty_records	Decides whether to delete empty record or not.
--					The empty records can be Empty Trips, Orphaned Empty Deliveries,
--					Delivery with Empty containers, Empty Containers
--		p_create_date_from	Only Empty records having creation_date greater than this
--					date would be purged
--		p_create_date_to	Only Empty records having creation_date less than this
--					date would be purged
--		p_del_beyond_creation_days	Only Empty records having creation_date less than
--						this date would be purged
--		p_sort_per_criteria	Sorts the report output according to Trip,
--					Delivery or Order Number
--		p_print_detail	If "Detail with LPN", the report would contain the parameters / summary
--				page and all detail pages with Trips, Deliveries and
--				Sales Orders with Container data eligible to purge or purged.
--				If "Detail", the report would contain the parameters / summary
--				page and all detail pages with Trips, Deliveries and
--				Sales Orders data eligible to purge or purged.
--				If "Summary", the report would contain only the parameters / summary page.

-- Description: This procedure is called by the concurrent program. The procedure has the following structure
--		calls Get_Purge_Set - To get the valid entities to be purged
--		calls Purge_Entities - To purge data in Shipping/FTE tables
--		calls Generate_Report - To generate the report through XML publisher
-----------------------------------------------------------------------------

PROCEDURE Process_Purge(	errbuf   OUT NOCOPY VARCHAR2,
				retcode  OUT NOCOPY VARCHAR2,
				p_execution_mode varchar2,
				p_source_system varchar2,
				p_ship_from_org number,
				p_order_number_from varchar2,
				p_source_system_dummy varchar2,
				p_order_number_to varchar2,
				p_dummy_order varchar2,
				p_order_type number,
				p_ship_date_from varchar2,
				p_ship_date_to varchar2,
				p_dummy_ship_date varchar2,
				p_delete_beyond_x_ship_days number,
				p_dummy_x_ship_days varchar2,
				p_purge_intransit_trips varchar2,
				p_delete_empty_records varchar2,
				p_create_date_from varchar2,
				p_create_date_to varchar2,
				p_dummy_create_date varchar2,
				p_del_beyond_creation_days number,
				p_dummy_x_create_days varchar2,
				p_sort_per_criteria varchar2,
				p_print_detail varchar2
		     )IS

l_return_status VARCHAR2(1);
l_debug_on BOOLEAN;

--PLSQL tables for the entities
l_tbl_trip_purge_set Trip_ID_Tbl_Type; --Trip
l_tbl_delivery_purge_set Delivery_ID_Tbl_Type; --Delivery
l_tbl_del_detail_purge_set  Del_Detail_ID_Tbl_Type; -- Delivery Detail
l_tbl_del_leg_purge_set  Del_Leg_ID_Tbl_Type; --Delivery Leg
l_tbl_trip_stop_purge_set  Trip_Stop_ID_Tbl_Type; --Trip Stop
l_tbl_container_purge_set Container_ID_Tbl_Type; --Container

l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_PURGE';

BEGIN

	-- Set for logging
	IF G_CONC_REQ = FND_API.G_TRUE THEN
		WSH_UTIL_CORE.Enable_Concurrent_Log_Print;
	END IF;

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    WSH_DEBUG_SV.log(l_module_name,'P_EXECUTION_MODE',p_execution_mode);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_SYSTEM',p_source_system);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_ORG',p_ship_from_org);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER_FROM',p_order_number_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER_To',p_order_number_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE',p_order_type);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE_FROM',p_ship_date_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE_TO',p_ship_date_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_BEYOND_X_SHIP_DAYS',p_delete_beyond_x_ship_days);
	    WSH_DEBUG_SV.log(l_module_name,'P_PURGE_INTRANSIT_TRIPS',p_purge_intransit_trips);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_EMPTY_Records',p_delete_empty_records);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATE_DATE_FROM',p_create_date_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATE_DATE_TO',p_create_date_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_DEL_BEYOND_CREATION_DAYS',p_del_beyond_creation_days);
	    WSH_DEBUG_SV.log(l_module_name,'P_SORT_PER_CRITERIA',p_sort_per_criteria);
	    WSH_DEBUG_SV.log(l_module_name,'P_PRINT_DETAIL',p_print_detail);
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.GET_PURGE_SET', WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	--call Get_Purge_Set
	Get_Purge_Set(	p_source_system 		=> p_source_system ,
			p_ship_from_org      		=> p_ship_from_org ,
			p_order_number_from  		=> p_order_number_from ,
			p_order_number_to    		=> p_order_number_to ,
			p_order_type         		=> p_order_type ,
			p_ship_date_from       		=> p_ship_date_from ,
			p_ship_date_to         		=> p_ship_date_to ,
			p_delete_beyond_x_ship_days	=> p_delete_beyond_x_ship_days ,
			p_purge_intransit_trips 	=> p_purge_intransit_trips ,
			p_delete_empty_records 		=> p_delete_empty_records ,
			p_create_date_from     		=> p_create_date_from ,
			p_create_date_to       		=> p_create_date_to ,
			p_del_beyond_creation_days 	=> p_del_beyond_creation_days ,
			x_tbl_trip_purge_set		=> l_tbl_trip_purge_set  ,
			x_tbl_delivery_purge_set	=> l_tbl_delivery_purge_set,
			x_tbl_del_details_purge_set 	=> l_tbl_del_detail_purge_set,
			x_tbl_del_legs_purge_set	=> l_tbl_del_leg_purge_set ,
			x_tbl_trip_stops_purge_set	=> l_tbl_trip_stop_purge_set,
			x_tbl_containers_purge_set   	=> l_tbl_container_purge_set,
			x_return_status    		=> l_return_status
	              );

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		IF G_CONC_REQ = FND_API.G_TRUE THEN
			errbuf := 'Error occurred in WSH_PURGE.GET_PURGE_SET';
			retcode := '2';
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		RETURN;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.GENERATE_PURGE_REPORT', WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	--call Generate_Purge_Report
	Generate_Purge_Report(	p_execution_mode 		=> p_execution_mode ,
				p_source_system  		=> p_source_system ,
				p_ship_from_org    		=> p_ship_from_org ,
				p_order_number_from		=> p_order_number_from ,
				p_order_number_to  		=> p_order_number_to ,
				p_order_type       		=> p_order_type ,
				p_ship_date_from     		=> p_ship_date_from ,
				p_ship_date_to       		=> p_ship_date_to ,
				p_delete_beyond_x_ship_days	=> p_delete_beyond_x_ship_days ,
				p_purge_intransit_trips		=> p_purge_intransit_trips ,
				p_delete_empty_records		=> p_delete_empty_records ,
				p_create_date_from   		=> p_create_date_from ,
				p_create_date_to     		=> p_create_date_to ,
				p_del_beyond_creation_days 	=> p_del_beyond_creation_days ,
				p_sort_per_criteria		=> p_sort_per_criteria ,
				p_print_detail   		=> p_print_detail ,
				p_tbl_trip_purge_set		=> l_tbl_trip_purge_set  ,
				p_tbl_delivery_purge_set	=> l_tbl_delivery_purge_set,
				p_tbl_container_purge_set	=> l_tbl_container_purge_set,
				p_count_legs    		=> l_tbl_del_leg_purge_set.COUNT ,
				p_count_stops      		=> l_tbl_trip_stop_purge_set.COUNT,
				p_count_details    		=> l_tbl_del_detail_purge_set.COUNT,
				p_count_containers        	=> l_tbl_container_purge_set.COUNT,
				x_return_status			=> l_return_status
			     );

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		IF G_CONC_REQ = FND_API.G_TRUE THEN
			errbuf := 'Error occurred in WSH_PURGE.GENERATE_PURGE_REPORT';
			retcode := '2';
		END IF;

		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		RETURN;
	END IF;

	IF p_execution_mode = 'P' THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_ENTITIES', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		--call Purge_Entities
		  Purge_Entities(p_tbl_trip_purge_set 		=> l_tbl_trip_purge_set  ,
				 p_tbl_delivery_purge_set	=> l_tbl_delivery_purge_set ,
				 p_tbl_del_details_purge_set	=> l_tbl_del_detail_purge_set ,
				 p_tbl_del_legs_purge_set	=> l_tbl_del_leg_purge_set ,
				 p_tbl_trip_stops_purge_set	=> l_tbl_trip_stop_purge_set ,
				 p_tbl_containers_purge_set	=> l_tbl_container_purge_set ,
				 x_return_status		=> l_return_status
				);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			IF G_CONC_REQ = FND_API.G_TRUE THEN
				errbuf := 'Error occurred in WSH_PURGE.PURGE_ENTITIES';
				retcode := '2';
			END IF;

			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	l_tbl_trip_purge_set.DELETE;
	l_tbl_delivery_purge_set.DELETE;
	l_tbl_del_detail_purge_set.DELETE;
	l_tbl_del_leg_purge_set.DELETE;
	l_tbl_trip_stop_purge_set.DELETE;
	l_tbl_container_purge_set.DELETE;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

END Process_Purge;


/*-----------------------------------------------------------------------------
Procedure:  Get_Purge_Set
Parameters: p_source_system Only the delivery details belonging to this Source System
            would be considered eligible for Purge
            p_ship_from_org Only the deliveries belonging to this Ship From Org
            would be considered eligible for Purge
            p_order_number_from Only the delivery details having source_header_number
            greater than Order Number From would be considered eligible for Purge
            p_order_number_to Only the delivery details having source_header_number
            less than Order Number To would be considered eligible for Purge
            p_order_type Only the delivery details belonging to this Order Type
            would be considered eligible for Purge
            p_ship_date_from Only the deliveries having initial_pickup_date greater
            than Ship Date From would be considered eligible for Purge
            p_ship_date_to  Only the deliveries having initial_pickup_date less than
            Ship Date To would be considered eligible for Purge
            p_delete_beyond_x_ship_days  Only the deliveries having initial_pickup_date greater
            than the specified date would be considered eligible for Purge
            p_purge_intransit_trips Decides whether to purge In Transit Trips or not
            p_delete_empty_records Decides whether to delete empty record or not.
            The empty records can be Empty Trips, Orphaned Empty Deliveries,
            Delivery with Empty containers, Empty Containers
            p_create_date_from Only Empty records having creation_date greater than this
            date would be purged
            p_create_date_to Only Empty records having creation_date less than this
            date would be purged
            p_del_beyond_creation_days Only Empty records having creation_date greater than
            this date would be purged
            x_tbl_trip_purge_set - pl/sql table of trip id's eligible for purge
            x_tbl_delivery_purge_set -  pl/sql table of delivery id's eligible for purge
            x_tbl_del_details_purge_set - pl/sql table of delivery detail id's eligible for purge
            x_tbl_del_legs_purge_set - pl/sql table of delivery leg id's eligible for purge
            x_tbl_trip_stops_purge_set - pl/sql table of trip stop id's eligible for purge
            x_tbl_containers_purge_set - pl/sql table of container id's eligible for purge
            x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API gets all the Shipping Data from the view WSH_PURGE_SET_V
             and puts it into the plsql tables for respective entities after validating it
             with the user given parameters
==============================================================================
Input: Parameters as given in the FDD.
Output: Table of Record Types for Trips, Stops, Legs,
        Deliveries, Containers, Details
================================================================================
Logic: i) Build Trip SQL for purge set types:
          NON_EMPTY - Complete Shipping Entities

      ii) Build Delivery SQL for purge set type:
          EMPTYDELS - Orphaned empty deliveries without any details

          only Delete Empty Records, creation date from, to and delete beyond
          x creation days will be honoured.

     iii) Execute the Trip ,Delivery and Container dynamically built SQLs and populate the
          Table of record types for trip,delivery and containers.

	  Add Trip IDs for purge set types :
	  EMPTYTRIPS - Orphaned Trips without any deliveries assigned to them

      iv) For NON_EMPTY purge sets get the deliveries for all
          trips and add delivery ids to the purge set for deliveries.

       v) For a given trip get all the stops and create a stops purge set.

      vi) For a given delivery get all the delivery legs and details and create
          a purge set.

     vii) From NON_EMPTY get all the container ids(wdd.container_flag='Y') and
          populate them in container purge set
-----------------------------------------------------------------------------*/

PROCEDURE Get_Purge_Set(p_source_system varchar2,
			p_ship_from_org number,
			p_order_number_from varchar2,
			p_order_number_to varchar2,
			p_order_type number,
			p_ship_date_from varchar2,
			p_ship_date_to varchar2,
			p_delete_beyond_x_ship_days number,
			p_purge_intransit_trips varchar2,
			p_delete_empty_records varchar2,
			p_create_date_from varchar2,
			p_create_date_to varchar2,
			p_del_beyond_creation_days number,
			x_tbl_trip_purge_set OUT  NOCOPY Trip_ID_Tbl_Type ,
			x_tbl_delivery_purge_set OUT  NOCOPY Delivery_ID_Tbl_Type,
			x_tbl_del_details_purge_set OUT  NOCOPY Del_Detail_ID_Tbl_Type,
			x_tbl_del_legs_purge_set OUT  NOCOPY Del_Leg_ID_Tbl_Type,
			x_tbl_trip_stops_purge_set OUT  NOCOPY Trip_Stop_ID_Tbl_Type,
			x_tbl_containers_purge_set OUT  NOCOPY Container_ID_Tbl_Type,
			x_return_status OUT  NOCOPY VARCHAR2
			)IS

	l_debug_on BOOLEAN;
	l_return_status VARCHAR2(1);

	trip_sql VARCHAR2(4000);
	delivery_sql VARCHAR2(4000);
	empty_trip_sql VARCHAR2(4000);
	empty_container_sql VARCHAR2(4000);

	l_source_system VARCHAR2(20);
	l_loop_index NUMBER;
	i number;

	l_trip_id NUMBER;
	l_delivery_id NUMBER;
	l_stop_id NUMBER;
	l_leg_id NUMBER;
	l_detail_id NUMBER;
	l_container_id NUMBER;
	l_container_flag VARCHAR2(1);

	l_trip_name VARCHAR2(30);
	l_delivery_name VARCHAR2(30);

	l_trip_purge_row Trip_ID_Rec_Type;
	l_del_purge_row Delivery_ID_Rec_Type;

	l_tbl_trip_purge_set Trip_ID_Tbl_Type;

	TYPE PurgeCurType IS REF CURSOR;
	c_trip_purge_cur PurgeCurType;
	c_del_purge_cur PurgeCurType;
	c_empty_trip_cur PurgeCurType;
	c_empty_containers PurgeCurType;

	CURSOR c_dels_for_trip(p_tripid NUMBER) IS
	SELECT	distinct wnd.delivery_id, wnd.name
	FROM	wsh_trips wt,
		wsh_trip_stops wts,
		wsh_delivery_legs wdl,
		wsh_new_deliveries wnd
	WHERE	wt.trip_id = wts.trip_id
	AND	wts.stop_id = wdl.pick_up_stop_id
	AND	wdl.delivery_id = wnd.delivery_id
	AND	wts.trip_id = p_tripid;

	CURSOR c_stops_for_trip(p_tripid NUMBER) IS
	SELECT	stop_id
	FROM	wsh_trip_stops
	WHERE	trip_id= p_tripid;

	CURSOR c_legs_for_del(p_deliveryid NUMBER) IS
	SELECT	delivery_leg_id
	FROM	wsh_delivery_legs
	WHERE	delivery_id = p_deliveryid;

	CURSOR c_details_for_del(p_deliveryid NUMBER) IS
	SELECT	wda.delivery_detail_id,
		wdd.container_flag
	FROM	wsh_delivery_assignments_v wda,
		wsh_delivery_details wdd
	WHERE	wda.delivery_id = p_deliveryid
	AND	wda.delivery_detail_id = wdd.delivery_detail_id;


	--cursor to select empty trips would come from dynamic sql
	--cursor to select empty dels would come from dynamic sql
	--(based on create date from and to)

	/*
	--cursor to select orphaned deliveries with only empty containers
	CURSOR c_delivery_empty_containers IS
	SELECT	wnd.delivery_id
		--wda.delivery_detail_id
	FROM	wsh_new_deliveries wnd,
		wsh_delivery_assignments_v wda,
		wsh_delivery_legs wdl
	WHERE	wnd.delivery_id = wda.delivery_id
	AND	wnd.delivery_id = wdl.delivery_id(+)
	AND	wdl.delivery_leg_id IS NULL
	AND	NOT EXISTS (
			SELECT	1
			FROM	wsh_delivery_details wdd,
				wsh_delivery_assignments_v wda1
			WHERE	wdd.delivery_Detail_id = wda1.delivery_detail_id
			AND	wda1.delivery_id = wnd.delivery_id
			AND	wdd.container_flag = 'N'
         ) ;
	*/

	--cursor to select orphaned empty containers
/*	CURSOR c_empty_containers IS
	SELECT
	wdd.delivery_detail_id,
	'EMPTYLPNS'
	--wdd.container_name dd_lpn_number,
	FROM
	wsh_delivery_assignments_v wda,
	wsh_delivery_details wdd
	WHERE
	wda.delivery_detail_id = wdd.delivery_detail_id AND
	wdd.container_flag = 'Y'AND
	wda.delivery_id IS NULL AND
	NOT EXISTS (
			SELECT 1
			FROM
			wsh_delivery_assignments_v wda2
			WHERE
			wda2.parent_delivery_detail_id = wda.delivery_detail_id
		    ) ;
*/

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_PURGE_SET';

BEGIN

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_SYSTEM',p_source_system);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_ORG',p_ship_from_org);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER_FROM',p_order_number_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER_To',p_order_number_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE',p_order_type);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE_FROM',p_ship_date_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE_TO',p_ship_date_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_BEYOND_X_SHIP_DAYS',p_delete_beyond_x_ship_days);
	    WSH_DEBUG_SV.log(l_module_name,'P_PURGE_INTRANSIT_TRIPS',p_purge_intransit_trips);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_EMPTY_Records',p_delete_empty_records);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATE_DATE_FROM',p_create_date_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATE_DATE_TO',p_create_date_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_DEL_BEYOND_CREATION_DAYS',p_del_beyond_creation_days);
	END IF;

	x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--construct trip_sql
	trip_sql := 'SELECT
                       trip_id,trip_name,''NON_EMPTY'' purge_set_type
                       FROM
                       wsh_purge_set_v outer
                       GROUP BY trip_id,trip_name
		       HAVING count(outer.dd_id) = (SELECT count(inner.dd_id)
                                         FROM
                                         wsh_purge_set_v inner ';
        --check whether FTE is installed
        IF (wsh_util_core.fte_is_installed='Y') THEN
	        trip_sql := trip_sql || ',fte_invoice_headers fih ' ;
	END IF;

	trip_sql := trip_sql || '
	              WHERE inner.trip_id = outer.trip_id
		      ';
	--dbms_output.put_line(trip_sql);

	IF (p_ship_from_org IS NOT NULL) THEN
		trip_sql := trip_sql || '
		AND inner.del_ship_from_org =  '
		|| p_ship_from_org ;
	END IF;

	IF (p_ship_date_from IS NOT NULL) THEN
		trip_sql := trip_sql ||
		' AND inner.del_pickup_date BETWEEN  ''' ||  FND_DATE.CANONICAL_TO_DATE(p_ship_date_from) ||
		''' AND ''' || FND_DATE.CANONICAL_TO_DATE(p_ship_date_to) || '''';
	ELSE
		trip_sql := trip_sql ||
		' AND inner.del_pickup_date < '''
		|| to_date(SYSDATE - p_delete_beyond_x_ship_days,'DD-MM-YYYY') ||'''' ;
	END IF;


	IF (p_source_system = 'ALL') THEN
		trip_sql := trip_sql || '
		AND inner.dd_source_code IN (''OE'',''PO'',''WSH'') ' ;
	ELSIF (p_source_system = 'OE') THEN
		trip_sql := trip_sql || '
		AND inner.dd_source_code IN (''OE'',''WSH'') ' ;
	ELSIF (p_source_system = 'PO') THEN
		trip_sql := trip_sql || '
		AND inner.dd_source_code IN (''PO'',''WSH'') ' ;
	ELSIF (p_source_system = 'WSH') THEN
		trip_sql := trip_sql || '
		AND inner.dd_source_code = ''WSH'' ' ;
	END IF;

	--check to take order type
	IF (p_order_type IS NOT NULL) THEN
		trip_sql := trip_sql ||
		' AND inner.dd_source_header_type_id = '
		|| p_order_type ;
	END IF; --end check to take order type

	--check to take order number range
	IF (p_order_number_from IS NOT NULL) THEN
		trip_sql := trip_sql ||
				' AND inner.dd_source_header_number BETWEEN '
				||  p_order_number_from ||
				' AND ' || p_order_number_to || ' ' ;
	END IF;--end check to take order number range

	--check for deleting Intransit Trips
	IF (p_purge_intransit_trips = 'Y') THEN
		trip_sql :=  trip_sql ||
				' AND inner.trip_status IN (''CL'',''IT'') ' ;
	ELSE
		trip_sql :=  trip_sql ||
	            		' AND inner.trip_status IN (''CL'') ' ;
        END IF;--end check for deleting Intransit Trips

	trip_sql :=  trip_sql ||
	               ' AND DECODE(inner.dd_source_code,
                       ''OE'',(DECODE((SELECT count(oe.order_number)
                                       FROM oe_order_headers_all oe
                                       WHERE oe.header_id= inner.dd_source_header_id),0,''FALSE'',''TRUE'')),
                       ''PO'',( DECODE((SELECT count(po.po_header_id)
                                        FROM po_headers_all po
                                        WHERE po.po_header_id= inner.dd_source_header_id),0,''FALSE'',''TRUE'')),
                       ''WSH'', ''FALSE'',
                       ''TRUE'') = ''FALSE''
		       ';
        --check whether FTE is installed
        IF (wsh_util_core.fte_is_installed='Y') THEN
	trip_sql :=  trip_sql ||
	               'AND fih.bol(+) = inner.bol
		       AND  DECODE(fih.bill_status,
		       ''PAID'', ''Y'',
                       ''OBSOLETE'' ,''Y'',
                       NULL, ''Y'',
                       ''N'') = ''Y''
                       ';
        END IF;--end check whether FTE is installed
	--end construct trip_sql

	trip_sql :=  trip_sql ||
			')' ;

	--check whether to delete empty records
        IF (p_delete_empty_records ='Y') THEN
		--construct delivery_sql for empty deliveries
		delivery_sql := 'SELECT
				wnd.delivery_id,wnd.name
				FROM
				wsh_new_deliveries wnd,
				wsh_delivery_assignments_v wda,
				wsh_delivery_legs wdl
				WHERE
				wda.delivery_id(+) = wnd.delivery_id AND
				wnd.delivery_id = wdl.delivery_id(+) AND
				wdl.delivery_leg_id IS NULL AND
				wda.delivery_detail_id IS NULL ' ;

				--check for taking creation dates
				IF (p_create_date_from  IS NOT NULL) THEN
				   delivery_sql :=  delivery_sql || '
				   AND wnd.creation_date
				   BETWEEN '''|| FND_DATE.CANONICAL_TO_DATE(p_create_date_from) || '''
				   AND '''|| FND_DATE.CANONICAL_TO_DATE(p_create_date_to) || '''' ;
				ELSE
				   delivery_sql :=  delivery_sql || '
				   AND wnd.creation_date  < '''
				   || to_date(SYSDATE - p_del_beyond_creation_days,'DD-MM-YYYY') ||'''' ;
				END IF; --end check for taking creation dates

		delivery_sql := delivery_sql  || '
				ORDER BY wnd.name ' ;
		--end construct delivery_sql

		--construct SQL for empty trips
		empty_trip_sql := '	SELECT	distinct wt.trip_id, wt.name
					FROM	wsh_trips wt,
						wsh_trip_stops wts,
						wsh_delivery_legs wdl1,
						wsh_delivery_legs wdl2
					WHERE	';

		--check for taking creation dates
		IF (p_create_date_from  IS NOT NULL) THEN
		   empty_trip_sql :=  empty_trip_sql || '
		   wt.creation_date
		   BETWEEN '''|| FND_DATE.CANONICAL_TO_DATE(p_create_date_from) || '''
		   AND '''|| FND_DATE.CANONICAL_TO_DATE(p_create_date_to) || '''' ;
		ELSE
		   empty_trip_sql :=  empty_trip_sql || '
		   wt.creation_date  < '''
		   || to_date(SYSDATE - p_del_beyond_creation_days,'DD-MM-YYYY') ||'''' ;
		END IF; --end check for taking creation dates

		empty_trip_sql := empty_trip_sql || '
				AND	wt.trip_id = wts.trip_id(+)
				AND	wdl1.pick_up_stop_id(+) = wts.stop_id
				AND	wdl2.drop_off_stop_id(+) = wts.stop_id
				AND	wdl1.delivery_leg_id IS NULL
				AND	wdl2.delivery_leg_id IS NULL
				AND	NOT EXISTS
					(	SELECT	1
						FROM	wsh_trip_stops wtss,
							wsh_delivery_legs wdl1s
						WHERE	wtss.trip_id = wt.trip_id
						AND	wdl1s.pick_up_stop_id = wtss.stop_id
					)
				 ' ;
		--end contructing SQL for empty trips

		--construct SQL for empty containers
		empty_container_sql := 'SELECT 	wdd.delivery_detail_id,
					''EMPTYLPNS''
					--wdd.container_name dd_lpn_number,
					FROM
					wsh_delivery_assignments_v wda,
					wsh_delivery_details wdd
					WHERE	wda.delivery_detail_id = wdd.delivery_detail_id
					AND	wdd.container_flag = ''Y''
					AND	wda.delivery_id IS NULL ';

		--check for taking creation dates
		IF (p_create_date_from  IS NOT NULL) THEN
		   empty_container_sql :=  empty_container_sql || '
		   AND wdd.creation_date
		   BETWEEN '''|| FND_DATE.CANONICAL_TO_DATE(p_create_date_from) || '''
		   AND '''|| FND_DATE.CANONICAL_TO_DATE(p_create_date_to) || '''' ;
		ELSE
		   empty_container_sql :=  empty_container_sql || '
		   AND wdd.creation_date  < '''
		   || to_date(SYSDATE - p_del_beyond_creation_days,'DD-MM-YYYY') ||'''' ;
		END IF; --end check for taking creation dates

		empty_container_sql := empty_container_sql || '
					AND	NOT EXISTS (
							SELECT 1
							FROM
							wsh_delivery_assignments_v wda2
							WHERE
							wda2.parent_delivery_detail_id = wda.delivery_detail_id
						    ) ' ;

	END IF; --end check whether to delete empty records

	--fetch trip ids for non empty trips and insert into PL/SQL table
	OPEN c_trip_purge_cur FOR trip_sql;
	FETCH c_trip_purge_cur BULK COLLECT into x_tbl_trip_purge_set;
	CLOSE c_trip_purge_cur;

	IF x_tbl_trip_purge_set.COUNT > 0 THEN --check for number of records in plsql table
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.VALIDATE_TRIPS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Check whether LPNs belonging to the trips are eligible to purge from WMS
		Validate_Trips(	p_tbl_trip_purge_set	=> x_tbl_trip_purge_set,
				x_tbl_trip_purge_set	=> l_tbl_trip_purge_set,
				x_return_status		=> l_return_status );

		x_tbl_trip_purge_set := l_tbl_trip_purge_set;

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	--check whether to fetch empty records
	IF (p_delete_empty_records ='Y') THEN
		--fetch trip ids for empty trips and insert into PL/SQL table
		OPEN c_empty_trip_cur FOR empty_trip_sql;
		LOOP
			FETCH c_empty_trip_cur into l_trip_id,l_trip_name;
			EXIT WHEN c_empty_trip_cur%NOTFOUND;
			x_tbl_trip_purge_set(x_tbl_trip_purge_set.COUNT+1).trip_id := l_trip_id;
			x_tbl_trip_purge_set(x_tbl_trip_purge_set.COUNT).trip_name := l_trip_name;
			x_tbl_trip_purge_set(x_tbl_trip_purge_set.COUNT).purge_set_type := 'EMPTYTRIPS';
		END LOOP;
		CLOSE c_empty_trip_cur;

		--fetch delivery ids for empty deliveries
		OPEN c_del_purge_cur FOR delivery_sql;
		LOOP
			FETCH c_del_purge_cur into l_delivery_id,l_delivery_name;
			EXIT WHEN c_del_purge_cur%NOTFOUND;
			x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT+1).delivery_id := l_delivery_id;
			x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT).delivery_name := l_delivery_name;
			x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT).purge_set_type := 'EMPTYDELS';
		END LOOP;
		CLOSE c_del_purge_cur;

		--fetch delivery ids for Deliveries having empty containers only
	/*	OPEN c_delivery_empty_containers;
		LOOP
			FETCH c_delivery_empty_containers into l_delivery_id;
			EXIT WHEN c_delivery_empty_containers%NOTFOUND;
			x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT+1).delivery_id := l_delivery_id;
			x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT).purge_set_type := 'DEL_EMPTYLPNS';
		END LOOP;
		CLOSE c_delivery_empty_containers;
	*/
		--fetch container id for orphaned empty containers
		OPEN c_empty_containers FOR empty_container_sql;
		FETCH c_empty_containers BULK COLLECT INTO x_tbl_containers_purge_set;
		CLOSE c_empty_containers;
	END IF; --end check whether to fetch empty records

	--add the deliveries belonging to trips from the table x_tbl_trip_purge_set
	--to the table x_delivery_tbl_trip_set
	IF x_tbl_trip_purge_set.COUNT > 0 THEN
	FOR l_loop_index in x_tbl_trip_purge_set.FIRST .. x_tbl_trip_purge_set.LAST
	LOOP
		l_trip_id := x_tbl_trip_purge_set(l_loop_index).trip_id;

		IF (x_tbl_trip_purge_set(l_loop_index).purge_set_type = 'NON_EMPTY') THEN
			OPEN c_dels_for_trip(l_trip_id);
			LOOP
				FETCH c_dels_for_trip into l_delivery_id,l_delivery_name;
				EXIT WHEN c_dels_for_trip%NOTFOUND;
				--x_tbl_delivery_purge_set.EXTEND;
				x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT+1).delivery_id := l_delivery_id;
				x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT).delivery_name := l_delivery_name;
				x_tbl_delivery_purge_set(x_tbl_delivery_purge_set.COUNT).purge_set_type := 'NON_EMPTY';
			END LOOP;
			CLOSE c_dels_for_trip;
		END IF;
		--fetch trip stops for the trips
		OPEN c_stops_for_trip(l_trip_id);
		LOOP
			FETCH c_stops_for_trip into l_stop_id;
			EXIT WHEN c_stops_for_trip%NOTFOUND;
			x_tbl_trip_stops_purge_set(x_tbl_trip_stops_purge_set.COUNT+1).stop_id := l_stop_id;
		END LOOP;
		CLOSE c_stops_for_trip;
	END LOOP; -- end adding delivery ids to plsql table
	END IF;

	--fetch delivery legs and delivery details for Delivery Ids into PL/SQL table
	IF x_tbl_delivery_purge_set.COUNT > 0 THEN
	FOR l_loop_index in x_tbl_delivery_purge_set.FIRST .. x_tbl_delivery_purge_set.LAST
	LOOP
		l_delivery_id := x_tbl_delivery_purge_set(l_loop_index).delivery_id;
		--fetch delivery legs
		IF (x_tbl_delivery_purge_set(l_loop_index).purge_set_type = 'NON_EMPTY') THEN
			OPEN c_legs_for_del(l_delivery_id);
			LOOP
				FETCH c_legs_for_del INTO l_leg_id;
				EXIT WHEN c_legs_for_del%NOTFOUND;
				x_tbl_del_legs_purge_set(x_tbl_del_legs_purge_set.COUNT+1).delivery_leg_id := l_leg_id;
			END LOOP;
			CLOSE c_legs_for_del;
		END IF;
		--fetch delivery details and containers for non empty deliveries
		IF x_tbl_delivery_purge_set(l_loop_index).purge_set_type = 'NON_EMPTY' THEN
			OPEN c_details_for_del(l_delivery_id);
			LOOP
				FETCH c_details_for_del INTO l_detail_id,l_container_flag;
				EXIT WHEN c_details_for_del%NOTFOUND;
				--l_container_flag = 'Y' would be Container
				IF l_container_flag = 'N' THEN -- Delivery Detail
					x_tbl_del_details_purge_set(x_tbl_del_details_purge_set.COUNT+1).delivery_detail_id := l_detail_id;
				ELSE -- Container
					x_tbl_containers_purge_set(x_tbl_containers_purge_set.COUNT+1).container_id := l_detail_id;
					x_tbl_containers_purge_set(x_tbl_containers_purge_set.COUNT).purge_set_type := 'NON_EMPTY';
				END IF;
			END LOOP;
			CLOSE c_details_for_del;
		END IF;

		--fetch empty containers for deliveries
	/*	IF x_tbl_delivery_purge_set(l_loop_index).purge_set_type = 'DEL_EMPTYLPNS' THEN
			OPEN c_details_for_del(l_delivery_id);
			LOOP
				FETCH c_details_for_del INTO l_detail_id,l_container_flag;
				EXIT WHEN c_details_for_del%NOTFOUND;
				x_tbl_containers_purge_set(x_tbl_containers_purge_set.COUNT+1).container_id := l_detail_id;
				x_tbl_containers_purge_set(x_tbl_containers_purge_set.COUNT).purge_set_type := 'EMPTYLPNS';
			END LOOP;
			CLOSE c_details_for_del;
		END IF; */
	END LOOP;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Get_Purge_Set;


/*-----------------------------------------------------------------------------

Procedure:	Purge_Entities
Parameters:	p_tbl_trip_purge_set - pl/sql table of trip id's eligible for purge
 		p_tbl_delivery_purge_set -  pl/sql table of delivery id's eligible for purge
 		p_tbl_del_details_purge_set -  pl/sql table of delivery detail id's eligible for purge
 		p_tbl_del_legs_purge_set - pl/sql table of delivery leg id's eligible for purge
 		p_tbl_trip_stops_purge_set - pl/sql table of trip stop id's eligible for purge
 		p_tbl_containers_purge_set  pl/sql - table of container id's eligible for purge
		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description:	This API calls the individual APIs to delete the data in
		Shipping and Transportation tables
=============================================================================
   Input: Table of Record Types for Trips, Stops, Legs, Deliveries, Containers, Details
   Output: Return Status - success or failure
==============================================================================
   Logic: i) Call Purge_Delivery_Details
         ii) Call Purge_Containers
        iii) Call Purge_Delivery_Legs
         iv) Call Purge_Trip_Stops
          v) Call Purge_Deliveries
         vi) Call Purge_Trips
-----------------------------------------------------------------------------*/

PROCEDURE Purge_Entities(	p_tbl_trip_purge_set Trip_ID_Tbl_Type ,
				p_tbl_delivery_purge_set Delivery_ID_Tbl_Type,
				p_tbl_del_details_purge_set Del_Detail_ID_Tbl_Type,
				p_tbl_del_legs_purge_set Del_Leg_ID_Tbl_Type,
				p_tbl_trip_stops_purge_set Trip_Stop_ID_Tbl_Type,
				p_tbl_containers_purge_set Container_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			)IS
	l_debug_on BOOLEAN;
	l_return_status VARCHAR2(1);

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_ENTITIES';
BEGIN

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF p_tbl_del_details_purge_set.COUNT > 0 THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_DELIVERY_DETAILS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge Delivery Details
		Purge_Delivery_Details(	p_tbl_del_detail_purge_set	=> p_tbl_del_details_purge_set,
					x_return_status			=> l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF p_tbl_containers_purge_set.COUNT > 0 THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_CONTAINERS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge Containers
		Purge_Containers(p_tbl_containers_purge_set => p_tbl_containers_purge_set,
				 x_return_status            => l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF p_tbl_del_legs_purge_set.COUNT > 0 THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_DELIVERY_LEGS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge Delivery Legs
		Purge_Delivery_Legs(p_tbl_del_leg_purge_set	=> p_tbl_del_legs_purge_set,
				    x_return_status		=> l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF p_tbl_trip_stops_purge_set.COUNT > 0 THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_TRIP_STOPS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge Trip Stops
		Purge_Trip_Stops(p_tbl_trip_stop_purge_set	=> p_tbl_trip_stops_purge_set,
				 x_return_status		=> l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF (p_tbl_delivery_purge_set.COUNT > 0 OR p_tbl_trip_purge_set.COUNT > 0) THEN

		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_WORKFLOW', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge workflows related to Trips and Deliveries
		Purge_Workflow(	p_tbl_trip_purge_set	=> p_tbl_trip_purge_set,
				p_tbl_delivery_purge_set=> p_tbl_delivery_purge_set,
				x_return_status		=> l_return_status);

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF p_tbl_delivery_purge_set.COUNT > 0 THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_DELIVERIES', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge Deliveries
		Purge_Deliveries(p_tbl_delivery_purge_set	=> p_tbl_delivery_purge_set,
				 x_return_status		=> l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF p_tbl_trip_purge_set.COUNT > 0 THEN
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_PURGE.PURGE_TRIPS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--Purge Trips
		Purge_Trips(p_tbl_trip_purge_set	=> p_tbl_trip_purge_set,
			    x_return_status		=> l_return_status);

		IF l_debug_on THEN
		    WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;


END Purge_Entities;


/*-----------------------------------------------------------------------------
Procedure: Purge_Trips
Parameters: p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
	    x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description:	This API delete the data in Shipping and Transportation
		related to trip
==============================================================================
Input: Table of Record Types for Trips
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
WSH_EXCEPTIONS, WSH_FREIGHT_COSTS, WSH_DOCUMENT_INSTANCES,WSH_TRIPS
-----------------------------------------------------------------------------*/

PROCEDURE Purge_Trips(		p_tbl_trip_purge_set Trip_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
		     )IS

	l_debug_on	BOOLEAN;
	l_loop_index	NUMBER;
	l_trip_id	NUMBER;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_TRIPS';
BEGIN

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR l_loop_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
	LOOP
		l_trip_id := p_tbl_trip_purge_set(l_loop_index).trip_id;

		DELETE
		FROM	wsh_exceptions
		WHERE	trip_id = l_trip_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_exceptions: TRIP_ID=' || l_trip_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_freight_costs
		WHERE	trip_id = l_trip_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_freight_costs: TRIP_ID=' || l_trip_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_document_instances
		WHERE	entity_id = l_trip_id
		AND	entity_name = 'WSH_TRIPS';

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_document_instances: TRIP_ID=' || l_trip_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_trips
		WHERE	trip_id = l_trip_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_trips: TRIP_ID=' || l_trip_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

	END LOOP;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Trips;


/*-----------------------------------------------------------------------------
Procedure:   Purge_Deliveries
Parameters:  p_tbl_delivery_purge_set pl/sql table of delivery id's eligible for purge
             x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
related to delivery
=============================================================================+
Input: Table of Record Types for Deliveries
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          WSH_EXCEPTIONS, WSH_TRANSACTIONS_HISTORY, WSH_DOCUMENT_INSTANCES,
          WSH_FREIGHT_COSTS

	  If FTE is installed,
             FTE_SHIPMENT_STATUS_DETAILS, FTE_SHIPMENT_STATUS_EXCEPTIONS,
             FTE_MESSAGE_PARTNER, FTE_MESSAGE_CONTACT, FTE_MESSAGE_LOCATION,
             FTE_DELIVERY_PROOF, FTE_SHIPMENT_STATUS_HEADERS

          If ITM Screening is done,
             WSH_ITM_RESPONSE_LINES, WSH_ITM_RESPONSE_HEADERS, WSH_ITM_REQUEST_CONTROL,
             WSH_INBOUND_TXN_HISTORY
	  and finally WSH_NEW_DELIVERIES.
-----------------------------------------------------------------------------*/

PROCEDURE Purge_Deliveries(	p_tbl_delivery_purge_set Delivery_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			)IS
	l_debug_on	BOOLEAN;
	l_loop_index	NUMBER;
	l_delivery_id	NUMBER;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_DELIVERIES';
BEGIN

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR l_loop_index in p_tbl_delivery_purge_set.FIRST .. p_tbl_delivery_purge_set.LAST
	LOOP

		l_delivery_id := p_tbl_delivery_purge_set(l_loop_index).delivery_id;

		DELETE
		FROM	wsh_exceptions
		WHERE	delivery_id = l_delivery_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_exceptions: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_transactions_history
		WHERE	entity_number = to_char(l_delivery_id)
		AND	entity_type   = 'DLVY';

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_transactions_history: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_freight_costs
		WHERE	delivery_id = l_delivery_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_freight_costs: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_document_instances
		WHERE	entity_id = l_delivery_id
		AND	entity_name = 'WSH_NEW_DELIVERIES';

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_document_instances: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		IF (wsh_util_core.fte_is_installed='Y') THEN

			DELETE
			FROM	fte_shipment_status_details
			WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_shipment_status_details: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_shipment_status_exceptions
			WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_shipment_status_exceptions: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_message_partner
			WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_message_partner: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_message_address
			WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_message_address: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_message_contact
			WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_message_contact: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_message_location
			WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_message_location: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;


			DELETE
			FROM	fte_delivery_proof
                        WHERE 	transaction_id IN (SELECT transaction_id
                                                   FROM   fte_shipment_status_headers
						   WHERE  delivery_id = l_delivery_id);

			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_delivery_proof: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;


			DELETE
			FROM	fte_shipment_status_headers
			WHERE 	delivery_id = l_delivery_id;


			IF SQL%FOUND THEN
			IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_shipment_status_headers: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;
		END IF;

		DELETE
		FROM	wsh_itm_response_lines
		WHERE 	response_header_id IN (	SELECT	wirh.response_header_id
						FROM	wsh_itm_response_headers wirh,
							wsh_itm_request_control wirc
						WHERE	wirc.original_system_reference = l_delivery_id
						AND	wirc.request_control_id = wirh.request_control_id
						AND	wirc.service_type_code = 'WSH_EXPORT_COMPLIANCE' );

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_itm_response_lines: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_itm_response_headers
		WHERE 	request_control_id IN (	SELECT	request_control_id
						FROM	wsh_itm_request_control
						WHERE	original_system_reference = l_delivery_id
						AND	service_type_code = 'WSH_EXPORT_COMPLIANCE' )  ;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_itm_response_headers: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_itm_request_control
		WHERE 	original_system_reference = l_delivery_id
		AND	service_type_code = 'WSH_EXPORT_COMPLIANCE';

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_itm_request_control: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_inbound_txn_history
		WHERE	shipment_header_id IN (	SELECT rcv_shipment_header_id
						FROM wsh_new_deliveries
						WHERE delivery_id = l_delivery_id) ;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_inbound_txn_history: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_new_deliveries
		WHERE	delivery_id = l_delivery_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_new_deliveries: DELIVERY_ID=' || l_delivery_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

	END LOOP;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Deliveries;


/*-----------------------------------------------------------------------------
Procedure:   Purge_Trip_Stops
Parameters:  p_tbl_trip_stop_purge_set  pl/sql table of trip stop id's
             eligible for purge
             x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
related to trip stop
==============================================================================
Input: Table of Record Types for Trip Stops
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          WSH_EXCEPTIONS, WSH_FREIGHT_COSTS, WSH_TRIP_STOPS
-----------------------------------------------------------------------------*/

PROCEDURE Purge_Trip_Stops(	p_tbl_trip_stop_purge_set Trip_Stop_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			)IS
	l_debug_on	BOOLEAN;
	l_loop_index	NUMBER;
	l_stop_id	NUMBER;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_TRIP_STOPS';
BEGIN

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR l_loop_index in p_tbl_trip_stop_purge_set.FIRST .. p_tbl_trip_stop_purge_set.LAST
	LOOP
		l_stop_id := p_tbl_trip_stop_purge_set(l_loop_index).stop_id;

		DELETE
		FROM	wsh_exceptions
		WHERE	trip_stop_id = l_stop_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_exceptions: STOP_ID=' || l_stop_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_freight_costs
		WHERE	stop_id = l_stop_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_freight_costs: STOP_ID=' || l_stop_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_trip_stops
		WHERE	stop_id = l_stop_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_trip_stops: STOP_ID=' || l_stop_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

	END LOOP;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Trip_Stops;


/*-----------------------------------------------------------------------------
Procedure:   Purge_Delivery_Legs
Parameters:  p_tbl_del_leg_purge_set pl/sql table of delivery leg id's eligible for purge
             x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
             related to delivery leg
==============================================================================
   Input: Table of Record Types for Delivery Legs
   Output: Return Status - success or failure
==============================================================================
   Logic: i) Delete records from the following tables:
             WSH_FREIGHT_COSTS, WSH_DOCUMENT_INSTANCES, WSH_DELIVERY_LEG_ACTIVITIES,
             WSH_DELIVERY_LEG_DETAILS, WSH_DELIVERY_LEGS

             If FTE is installed,
             FTE_INVOICE_LINES, FTE_INVOICE_HISTORY, FTE_INVOICE_HEADERS,
             FTE_FAILURE_REASONS
-----------------------------------------------------------------------------*/

PROCEDURE Purge_Delivery_Legs(	p_tbl_del_leg_purge_set Del_Leg_ID_Tbl_Type,
				x_return_status OUT  NOCOPY VARCHAR2
			)IS
	l_debug_on	BOOLEAN;
	l_loop_index	NUMBER;
	l_leg_id	NUMBER;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_DELIVERY_LEGS';
BEGIN
	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR l_loop_index in p_tbl_del_leg_purge_set.FIRST .. p_tbl_del_leg_purge_set.LAST
	LOOP
		l_leg_id := p_tbl_del_leg_purge_set(l_loop_index).delivery_leg_id;

		DELETE
		FROM	wsh_freight_costs
		WHERE	delivery_leg_id = l_leg_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_freight_costs: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		IF (wsh_util_core.fte_is_installed='Y') THEN

			DELETE
			FROM	fte_invoice_lines
			WHERE	invoice_header_id IN (	SELECT	fih.invoice_header_id
							FROM	fte_invoice_headers fih,
								wsh_document_instances wdi
							WHERE	wdi.entity_id = l_leg_id
							AND	wdi.entity_name = 'WSH_DELIVERY_LEGS'
							AND	wdi.sequence_number = fih.bol
						    ) ;
			IF SQL%FOUND THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_invoice_lines: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_invoice_headers
			WHERE	bol IN (SELECT	sequence_number
					FROM	wsh_document_instances
					WHERE	entity_id = l_leg_id
					AND	entity_name = 'WSH_DELIVERY_LEGS') ;

			IF SQL%FOUND THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_invoice_headers: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_invoice_history
			WHERE	bol IN (SELECT	sequence_number
					FROM	wsh_document_instances
					WHERE	entity_id = l_leg_id
					AND	entity_name = 'WSH_DELIVERY_LEGS') ;

			IF SQL%FOUND THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_invoice_history: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

			DELETE
			FROM	fte_failure_reasons
			WHERE	bol IN (	SELECT	sequence_number
					FROM	wsh_document_instances
					WHERE	entity_id = l_leg_id
					AND	entity_name = 'WSH_DELIVERY_LEGS') ;

			IF SQL%FOUND THEN
			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from fte_failure_reasons: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
			END IF;

		END IF;

		DELETE
		FROM	wsh_document_instances
		WHERE	entity_id = l_leg_id
		AND	entity_name = 'WSH_DELIVERY_LEGS';

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_document_instances: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_delivery_leg_activities
		WHERE	delivery_leg_id = l_leg_id ;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_leg_activities: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_delivery_leg_details
		WHERE	delivery_leg_id = l_leg_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_leg_details: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;


		DELETE
		FROM	wsh_delivery_legs
		WHERE	delivery_leg_id = l_leg_id ;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_legs: LEG_ID=' || l_leg_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;
	END LOOP;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Delivery_Legs;


/*-----------------------------------------------------------------------------
Procedure:  Purge_Delivery_Details
Parameters: p_tbl_del_detail_purge_set pl/sql table of delivery detail id's
	    eligible for purge
            x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API delete the data in Shipping and Transportation
             related to delivery detail
=============================================================================
Input: Table of Record Types for Delivery Details
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          WSH_FREIGHT_COSTS, WSH_SERIAL_NUMBERS, WSH_EXCEPTIONS,
          wsh_delivery_assignments_v, WSH_DELIVERY_DETAILS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Delivery_Details(p_tbl_del_detail_purge_set Del_Detail_ID_Tbl_Type,
				 x_return_status OUT  NOCOPY VARCHAR2
				)IS
	l_debug_on	BOOLEAN;
	l_loop_index	NUMBER;
	l_detail_id	NUMBER;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_DELIVERY_DETAILS';
BEGIN
	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR l_loop_index in p_tbl_del_detail_purge_set.FIRST .. p_tbl_del_detail_purge_set.LAST
	LOOP
		l_detail_id := p_tbl_del_detail_purge_set(l_loop_index).delivery_detail_id;

		DELETE
		FROM	wsh_serial_numbers
		WHERE	delivery_detail_id = l_detail_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_serial_numbers: DELIVERY_DETAIL_ID=' || l_detail_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_exceptions
		WHERE	delivery_detail_id = l_detail_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_exceptions: DELIVERY_DETAIL_ID=' || l_detail_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_freight_costs
		WHERE	delivery_detail_id = l_detail_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_freight_costs: DELIVERY_DETAIL_ID=' || l_detail_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_delivery_assignments_v
		WHERE	delivery_detail_id = l_detail_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_assignments_v: DELIVERY_DETAIL_ID=' || l_detail_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_delivery_details
		WHERE	delivery_detail_id = l_detail_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_details: DELIVERY_DETAIL_ID=' || l_detail_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;
	END LOOP;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Delivery_Details;


/*-----------------------------------------------------------------------------
Procedure: Purge_Containers
Parameters: p_tbl_containers_purge_set pl/sql table of container id's eligible for purge
            x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

Description: This API calls the WMS API to delete the data in WMS
             related to Containers
==============================================================================
Input: Table of Record Types for Container Ids
Output: Return Status - success or failure
==============================================================================
Logic: i) Delete records from the following tables:
          wsh_delivery_assignments_v, WSH_DELIVERY_DETAILS
-----------------------------------------------------------------------------*/
PROCEDURE Purge_Containers(p_tbl_containers_purge_set Container_ID_Tbl_Type,
			   x_return_status OUT  NOCOPY VARCHAR2
		           )IS
	l_debug_on	BOOLEAN;
	l_loop_index	NUMBER;
	l_container_id	NUMBER;
	l_lpn_id	NUMBER;
	l_return_status VARCHAR2(1);

	l_msg_count NUMBER;
	l_msg_data VARCHAR2(32767);

	l_wms_lpn_record WMS_Data_Type_Definitions_PUB.LPNPurgeRecordType;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_CONTAINERS';
BEGIN
	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR l_loop_index in p_tbl_containers_purge_set.FIRST .. p_tbl_containers_purge_set.LAST
	LOOP
		l_container_id := p_tbl_containers_purge_set(l_loop_index).container_id;


		DELETE
		FROM	wsh_exceptions
		WHERE	delivery_detail_id = l_container_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_exceptions: CONTAINER_ID=' || l_container_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_freight_costs
		WHERE	delivery_detail_id = l_container_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_freight_costs: CONTAINER_ID=' || l_container_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_delivery_assignments_v
		WHERE	delivery_detail_id = l_container_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_assignments_v: CONTAINER_ID=' || l_container_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		DELETE
		FROM	wsh_delivery_details
		WHERE	delivery_detail_id = l_container_id
		RETURNING lpn_id INTO l_lpn_id;

		IF SQL%FOUND THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'Deleted from wsh_delivery_details: CONTAINER_ID=' || l_container_id, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		END IF;

		IF l_lpn_id IS NOT NULL THEN -- Populate the LPN IDs in the table
			l_wms_lpn_record.LPN_IDs(l_wms_lpn_record.LPN_IDs.COUNT+1) := l_lpn_id;
		END IF;
	END LOOP;

	--Call the WMS API to DELETE the LPNs
	IF l_debug_on THEN
	    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_CONTAINER_GRP.LPN_PURGE_ACTIONS', WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	WMS_Container_GRP.LPN_Purge_Actions(	p_api_version	=>1.0,
						p_init_msg_list	=>FND_API.G_TRUE,
						p_commit	=>'FALSE',
						x_return_status	=>l_return_status,
						x_msg_count	=>l_msg_count,
						x_msg_data	=>l_msg_data,
						p_caller	=>'WSH',
						p_action	=>WMS_Container_GRP.G_LPN_PURGE_ACTION_DELETE,
						p_lpn_purge_rec	=> l_wms_lpn_record
					   );

	IF l_debug_on THEN
		WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
		WSH_DEBUG_SV.log(l_module_name,'L_MSG_DATA',l_msg_data);
	END IF;

	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		x_return_status := l_return_status;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
		RETURN;
	END IF;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Purge_Containers;

-----------------------------------------------------------------------------
--
-- Procedure:   Generate_Purge_Report
-- Parameters:  p_execution_mode  Specifies whether to Purge Data or View Purge Set
--		p_source_system	 Only the delivery details belonging to this Source System
--				 would be considered eligible for Purge
--		p_ship_from_org	 Only the deliveries belonging to this Ship From Org
--				 would be considered eligible for Purge
--		p_order_number_from  Only the delivery details having source_header_number
--				     greater than Order Number From would be considered eligible for Purge
--		p_order_number_to  Only the delivery details having source_header_number
--				   less than Order Number To would be considered eligible for Purge
--		p_order_type  Only the delivery details belonging to this Order Type
--			      would be considered eligible for Purge
--		p_ship_date_from  Only the deliveries having initial_pickup_date greater
--				  than Ship Date From would be considered eligible for Purge
--		p_ship_date_to  Only the deliveries having initial_pickup_date less than
--				Ship Date To would be considered eligible for Purge
--		p_delete_beyond_x_ship_days  Only the deliveries having initial_pickup_date greater
--					     than the specified date would be considered eligible for Purge
--		p_purge_intransit_trips	Decides whether to purge In Transit Trips or not
--		p_delete_empty_records	Decides whether to delete empty record or not.
--					The empty records can be Empty Trips, Orphaned Empty Deliveries,
--					Delivery with Empty containers, Empty Containers
--		p_create_date_from	Only Empty records having creation_date greater than this
--					date would be purged
--		p_create_date_to	Only Empty records having creation_date less than this
--					date would be purged
--		p_del_beyond_creation_days	Only Empty records having creation_date greater than
--						this date would be purged
--		p_sort_per_criteria	Sorts the report output according to Trip,
--					Delivery or Order Number
--		p_print_detail	If Low, the report would contain the parameters / summary
--				page and all detail pages with Trips, Deliveries and
--				Sales Orders data eligible to purge or purged.
--				If No, the report would contain only the parameters / summary page.
--		p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		p_tbl_delivery_purge_set  pl/sql table of delivery id's eligible for purge
--		p_tbl_delivery_purge_set  pl/sql table of container ids's eligible for purge
--		p_count_legs  count of delivery legs to be purged/eligible to be purged
--		p_count_stops count of trip stops to be purged/eligible to be purged
--		p_count_details count of delivery details to be purged/eligible to be purged
--		p_count_containers count of containers to be purged/eligible to be purged
--		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:	This API generates the XML and writes it in output file
--		of the concurrent program to be used by the XML Publisher
--		to generate the XML report
-----------------------------------------------------------------------------

PROCEDURE Generate_Purge_Report(p_execution_mode varchar2,
				p_source_system varchar2,
				p_ship_from_org number,
				p_order_number_from varchar2,
				p_order_number_to varchar2,
				p_order_type number,
				p_ship_date_from varchar2,
				p_ship_date_to varchar2,
				p_delete_beyond_x_ship_days number,
				p_purge_intransit_trips varchar2,
				p_delete_empty_records varchar2,
				p_create_date_from varchar2,
				p_create_date_to varchar2,
				p_del_beyond_creation_days number,
				p_sort_per_criteria varchar2,
				p_print_detail varchar2,
				p_tbl_trip_purge_set  Trip_ID_Tbl_Type ,
				p_tbl_delivery_purge_set  Delivery_ID_Tbl_Type,
				p_tbl_container_purge_set Container_ID_Tbl_Type,
				p_count_legs NUMBER,
				p_count_stops NUMBER,
				p_count_details NUMBER,
				p_count_containers NUMBER,
				x_return_status OUT  NOCOPY VARCHAR2
				)IS
	l_debug_on BOOLEAN;

	l_trip_id NUMBER;
	l_delivery_id NUMBER;
	l_delivery_name VARCHAR2(30);
	l_trip_name VARCHAR2(30);
	l_sales_order VARCHAR2(150);
	l_bol_number NUMBER;
	l_container_id NUMBER;
	l_waybill VARCHAR2(30);
	l_gross_weight NUMBER;
	l_ship_to VARCHAR2(500);
	l_customer_name VARCHAR2(50);
	l_pickup_date DATE;
	l_dropoff_date DATE;
	l_ship_date DATE;
	l_order_type VARCHAR2(240);
	l_create_date DATE;

	l_trip_index NUMBER;
	l_delivery_index NUMBER;
	l_sales_order_index NUMBER;
	l_container_index NUMBER;

	l_nonempty_count NUMBER;
	l_lpn_count NUMBER;
	l_empty_trip_count NUMBER;
	l_empty_del_count NUMBER;
	l_empty_lpn_count NUMBER;
        l_buff_size NUMBER;

	l_err varchar2(500);

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GENERATE_PURGE_REPORT';

	--Get Deliveries for Trips
	CURSOR c_dels_for_trip(p_tripid NUMBER) IS
	SELECT	distinct del_id,
		del_name,
		del_waybill,
		del_gross_weight,
		del_ui_location_code,
		del_customer_name,
		del_pickup_date,
		del_dropoff_date,
		del_ship_date,
		bol
	FROM	wsh_purge_set_v
	WHERE	trip_id =  p_tripid;

	--Added hints to the query for bug 4891951
	CURSOR c_bols_for_del(p_delivery_id NUMBER) IS
	SELECT	/*+use_nl(v.wda, v.wnd, v.wdl)*/ distinct v.bol
	FROM	wsh_purge_set_v v
	WHERE	v.del_id = p_delivery_id
	AND	v.bol is not null;

	--Get Sales Order Details for Deliveries
	--Added hints to the query for bug 4891951
	CURSOR	c_so_for_delivery(p_delivery_id NUMBER) IS
	SELECT	/*+use_nl(v.wda, v.wnd, v.wdl)*/ DISTINCT v.dd_source_header_number,
		v.dd_source_header_type_name--,
--		dd_creation_date
	FROM	wsh_purge_set_v v
	WHERE	v.del_id = p_delivery_id
	AND	v.dd_source_header_number is not null;

	CURSOR c_dels_trips_for_order(p_ordernumber VARCHAR2) IS
	SELECT	distinct trip_id,
		trip_name,
		del_id,
		del_name,
		del_waybill,
		del_gross_weight,
		del_ui_location_code,
		del_customer_name,
		del_pickup_date,
		del_dropoff_date,
		del_ship_date,
		bol
	FROM	wsh_purge_set_v
	WHERE	dd_source_header_number= p_ordernumber;

	--Get Containers for Sales Orders
	/*CURSOR	c_containers_for_so(order_number varchar2) IS
	SELECT	distinct wda.parent_delivery_detail_id
	FROM	wsh_delivery_assignments_v wda,
		wsh_delivery_details wdd
	WHERE	wda.delivery_detail_id = wdd.delivery_detail_id
	AND	wdd.source_header_number = order_number
	AND	wda.parent_delivery_detail_id IS NOT NULL;
	*/

	/*CURSOR	c_containers_for_so(order_number varchar2) IS
	SELECT DISTINCT wda.parent_delivery_detail_id
	FROM   wsh_delivery_assignments_v wda ,wsh_Delivery_Details wdd
	WHERE  wda.parent_delivery_detail_id is not null
	AND wdd.delivery_Detail_id = wda.delivery_detail_id
	CONNECT BY PRIOR wda.delivery_detail_id = wda.parent_delivery_detail_id
	START WITH wdd.source_header_number =order_number;
	*/

	CURSOR	c_containers_for_so(p_order_number varchar2) IS
	SELECT DISTINCT wda.parent_delivery_detail_id
	FROM   wsh_delivery_assignments_v wda
	WHERE  wda.parent_delivery_detail_id is not null
	CONNECT BY PRIOR wda.delivery_detail_id = wda.parent_delivery_detail_id
	START WITH wda.delivery_id IN (select wda1.delivery_id from
	wsh_delivery_assignments_v wda1, wsh_delivery_Details wdd
	WHERE wda1.delivery_Detail_id = wdd.delivery_Detail_id
	and     wdd.source_header_number = p_order_number);

BEGIN
	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_nonempty_count := 0;
	l_lpn_count := 0;
	l_empty_trip_count := 0;
	l_empty_del_count := 0;
	l_empty_lpn_count := 0;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.log(l_module_name,'P_EXECUTION_MODE',p_execution_mode);
	    WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_SYSTEM',p_source_system);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_FROM_ORG',p_ship_from_org);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER_FROM',p_order_number_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_NUMBER_To',p_order_number_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_ORDER_TYPE',p_order_type);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE_FROM',p_ship_date_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_SHIP_DATE_TO',p_ship_date_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_BEYOND_X_SHIP_DAYS',p_delete_beyond_x_ship_days);
	    WSH_DEBUG_SV.log(l_module_name,'P_PURGE_INTRANSIT_TRIPS',p_purge_intransit_trips);
	    WSH_DEBUG_SV.log(l_module_name,'P_DELETE_EMPTY_Records',p_delete_empty_records);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATE_DATE_FROM',p_create_date_from);
	    WSH_DEBUG_SV.log(l_module_name,'P_CREATE_DATE_TO',p_create_date_to);
	    WSH_DEBUG_SV.log(l_module_name,'P_DEL_BEYOND_CREATION_DAYS',p_del_beyond_creation_days);
	    WSH_DEBUG_SV.log(l_module_name,'P_SORT_PER_CRITERIA',p_sort_per_criteria);
	    WSH_DEBUG_SV.log(l_module_name,'P_PRINT_DETAIL',p_print_detail);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNT_LEGS',p_count_legs);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNT_STOPS',p_count_stops);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNT_DETAILS',p_count_details);
	    WSH_DEBUG_SV.log(l_module_name,'P_COUNT_ContainerS',p_count_containers);
	END IF;

	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<?xml version="1.0" ?>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ROWSET>');
	IF p_execution_mode = 'V' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<EXEC_MODE>View Purge Selection</EXEC_MODE>');
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<COUNT_HEADING>Eligible to Purge</COUNT_HEADING>');
	ELSE
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<EXEC_MODE>Purge</EXEC_MODE>');
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<COUNT_HEADING>Purged</COUNT_HEADING>)');
	END IF;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<CURR_DATE>'|| SYSDATE ||'</CURR_DATE>');

	IF (p_source_system = 'ALL') THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SOURCE_SYSTEM>All</SOURCE_SYSTEM>');
	ELSIF (p_source_system = 'OE') THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SOURCE_SYSTEM>Order Management</SOURCE_SYSTEM>');
	ELSIF (p_source_system = 'PO') THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SOURCE_SYSTEM>Purchasing</SOURCE_SYSTEM>');
	ELSIF (p_source_system = 'WSH') THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SOURCE_SYSTEM>Shipping</SOURCE_SYSTEM>');
	END IF;

	IF p_ship_from_org IS NOT NULL THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SHIP_ORG>' ||
			WSH_UTIL_CORE.GET_ORG_NAME(p_organization_id => to_number(p_ship_from_org)) ||
						'</SHIP_ORG>');
	ELSE
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SHIP_ORG></SHIP_ORG>');
	END IF;

	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ORDER_NUM_FROM>' || p_order_number_from || '</ORDER_NUM_FROM>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ORDER_NUM_TO>' || p_order_number_to || '</ORDER_NUM_TO>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<ORDER_TYPE>' || p_order_type || '</ORDER_TYPE>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SHIP_DATE_FROM>' || FND_DATE.CANONICAL_TO_DATE(p_ship_date_from) || '</SHIP_DATE_FROM>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SHIP_DATE_TO>' || FND_DATE.CANONICAL_TO_DATE(p_ship_date_to) || '</SHIP_DATE_TO>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<DEL_SHIP_DAYS>' || p_delete_beyond_x_ship_days || '</DEL_SHIP_DAYS>');

	IF p_purge_intransit_trips = 'Y' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<CLOSE_IT_TRIPS>Yes</CLOSE_IT_TRIPS>');
	ELSE
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<CLOSE_IT_TRIPS>No</CLOSE_IT_TRIPS>');
	END IF;

	IF p_delete_empty_records = 'Y' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<DEL_EMPTY>Yes</DEL_EMPTY>');
	ELSE
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<DEL_EMPTY>No</DEL_EMPTY>');
	END IF;

	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<CREATE_DATE_FROM>'|| FND_DATE.CANONICAL_TO_DATE(p_create_date_from) ||'</CREATE_DATE_FROM>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<CREATE_DATE_TO>'|| FND_DATE.CANONICAL_TO_DATE(p_create_date_to) ||'</CREATE_DATE_TO>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<DEL_CREATE_DAYS>' || p_del_beyond_creation_days || '</DEL_CREATE_DAYS>');

	IF p_sort_per_criteria = 'T' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_CRITERIA>Trip</SORT_CRITERIA>');
	ELSIF p_sort_per_criteria = 'D' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_CRITERIA>Delivery</SORT_CRITERIA>');
	ELSIF p_sort_per_criteria = 'O' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_CRITERIA>Order</SORT_CRITERIA>');
	END IF;

	IF p_print_detail='L' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<PRINT_DETAIL>Detail with LPN</PRINT_DETAIL>');
	ELSIF p_print_detail='D' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<PRINT_DETAIL>Detail</PRINT_DETAIL>');
	ELSIF p_print_detail='S' THEN
		FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<PRINT_DETAIL>Summary</PRINT_DETAIL>');
	END IF;

	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<PURGED_BY>'|| FND_GLOBAL.USER_NAME ||'</PURGED_BY>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<REQUEST_ID>' ||FND_GLOBAL.CONC_REQUEST_ID ||'</REQUEST_ID>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<NO_OF_TRIPS>' || p_tbl_trip_purge_set.COUNT || '</NO_OF_TRIPS>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<NO_OF_STOPS>' || p_count_stops || '</NO_OF_STOPS>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<NO_OF_DELS>' || p_tbl_delivery_purge_set.COUNT || '</NO_OF_DELS>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<NO_OF_LINES>' || p_count_details || '</NO_OF_LINES>');

	IF p_print_detail <> 'S' THEN --check for print detail
	IF p_tbl_trip_purge_set.COUNT > 0 THEN
	FOR l_trip_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
	LOOP
		l_trip_id := p_tbl_trip_purge_set(l_trip_index).trip_id;
		l_trip_name := p_tbl_trip_purge_set(l_trip_index).trip_name;
		IF (p_tbl_trip_purge_set(l_trip_index).purge_set_type = 'NON_EMPTY') THEN
			--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP>');
			--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP_ID>' || l_trip_id || '</TRIP_ID>');
			l_nonempty_count := l_nonempty_count +1;
			OPEN c_dels_for_trip(l_trip_id);
			LOOP
				FETCH c_dels_for_trip into l_delivery_id,l_delivery_name,l_waybill,l_gross_weight,
				l_ship_to,l_customer_name,l_pickup_date,l_dropoff_date,l_ship_date,l_bol_number ;
				EXIT WHEN c_dels_for_trip%NOTFOUND;

				IF p_sort_per_criteria <> 'O' THEN --check for sort by order
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<TRIP>');
				IF P_SORT_PER_CRITERIA = 'T' THEN
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>' || l_trip_name || '</SORT_ID>');
				ELSIF P_SORT_PER_CRITERIA = 'D' THEN
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>' || l_delivery_name || '</SORT_ID>');
				END IF ;
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP_ID>' || l_trip_name || '</TRIP_ID>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DELIVERY_ID>' || l_delivery_name || '</DELIVERY_ID>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<WAYBILL>' || l_waybill || '</WAYBILL>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BOL>' || l_bol_number || '</BOL>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<GROSS_WEIGHT>' || l_gross_weight || '</GROSS_WEIGHT>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SHIP_TO>' || l_ship_to || '</SHIP_TO>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<CUSTOMER><![CDATA[ ' || l_customer_name || ']]></CUSTOMER>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<PICKUP_DATE>' || l_pickup_date || '</PICKUP_DATE>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DROPOFF_DATE>' || l_dropoff_date || '</DROPOFF_DATE>');
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SHIP_DATE>' || l_ship_date || '</SHIP_DATE>');
				END IF;--check for sort by order

				OPEN c_so_for_delivery(l_delivery_id);
				LOOP
					FETCH c_so_for_delivery into l_sales_order,l_order_type;
					EXIT WHEN c_so_for_delivery%NOTFOUND;
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SALES_ORDER>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<ORDER_NUMBER>' || l_sales_order || '</ORDER_NUMBER>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<ORDER_TYPE>' || l_order_type || '</ORDER_TYPE>');
					IF p_print_detail = 'L' THEN --check whether to print container details
						FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<CONTAINER>');
						OPEN c_containers_for_so(l_sales_order);
						LOOP
							l_lpn_count := l_lpn_count+1;
							FETCH c_containers_for_so into l_container_id;
							EXIT WHEN c_containers_for_so%NOTFOUND;
							IF l_lpn_count = 1 THEN
								FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_container_id);
							ELSE
								FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ,' || l_container_id);
							END IF;
						END LOOP;
						CLOSE c_containers_for_so;
						FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</CONTAINER>');
					END IF; -- end check to print container details

					IF p_sort_per_criteria = 'O' THEN --check for sort by order
					OPEN c_dels_trips_for_order(l_sales_order);
					LOOP
					FETCH c_dels_trips_for_order into l_trip_id,l_trip_name,l_delivery_id,
					l_delivery_name,l_waybill,l_gross_weight,l_ship_to,l_customer_name,
					l_pickup_date,l_dropoff_date,l_ship_date,l_bol_number ;
					EXIT WHEN c_dels_trips_for_order%NOTFOUND;
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<TRIP>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP_ID>' || l_trip_name || '</TRIP_ID>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DELIVERY_ID>' || l_delivery_name || '</DELIVERY_ID>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<WAYBILL>' || l_waybill || '</WAYBILL>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<BOL>' || l_bol_number || '</BOL>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<GROSS_WEIGHT>' || l_gross_weight || '</GROSS_WEIGHT>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SHIP_TO>' || l_ship_to || '</SHIP_TO>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<CUSTOMER><![CDATA[ ' || l_customer_name || ']]></CUSTOMER>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<PICKUP_DATE>' || l_pickup_date || '</PICKUP_DATE>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DROPOFF_DATE>' || l_dropoff_date || '</DROPOFF_DATE>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<SHIP_DATE>' || l_ship_date || '</SHIP_DATE>');
					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</TRIP>');
					END LOOP;
					CLOSE c_dels_trips_for_order;
					END IF; --check for sort by order

					FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</SALES_ORDER>');
				END LOOP;
				CLOSE c_so_for_delivery;
				IF p_sort_per_criteria <> 'O' THEN --check for sort by order
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</TRIP>');
				END IF; --check for sort by order
			END LOOP;
			CLOSE c_dels_for_trip;
			--FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</TRIP>');
		END IF;
	END LOOP;
	END IF; --check for number of records in plsql table

	-- print empty trips
	IF p_tbl_trip_purge_set.COUNT > 0 THEN --check for number of records in plsql table
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<EMPTY_TRIPS>');
        l_buff_size := 0 ;     -- Reset the buffer size to zero
	FOR l_trip_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
	LOOP
		l_trip_id := p_tbl_trip_purge_set(l_trip_index).trip_id;
		l_trip_name := p_tbl_trip_purge_set(l_trip_index).trip_name;
		IF (p_tbl_trip_purge_set(l_trip_index).purge_set_type = 'EMPTYTRIPS') THEN
			l_empty_trip_count := l_empty_trip_count+1;
			/*FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<TRIP>');
			IF P_SORT_PER_CRITERIA = 'T' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>' || lpad(l_trip_id,10,'0') || '</SORT_ID>');
			ELSIF P_SORT_PER_CRITERIA = 'D' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>999999999</SORT_ID>');
			END IF ;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP_ID>' || l_trip_id || '</TRIP_ID>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DELIVERY_ID></DELIVERY_ID>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</TRIP>');*/

                        --Bug 8204644
                        IF ( l_buff_size = 0 AND l_empty_trip_count=1 ) THEN
				l_buff_size := lengthb(l_trip_name);
				FND_FILE.PUT(FND_FILE.OUTPUT,l_trip_name);
                        ELSIF ( l_buff_size = 0 AND l_empty_trip_count<>1 ) THEN
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,',');
                                l_buff_size := lengthb(l_trip_name);
                                FND_FILE.PUT(FND_FILE.OUTPUT,l_trip_name);
			ELSIF l_buff_size < 30000 THEN
				l_buff_size := l_buff_size + lengthb(l_trip_name) + 2;
				FND_FILE.PUT(FND_FILE.OUTPUT, ', ' || l_trip_name);
			ELSIF l_buff_size >= 30000 THEN
				l_buff_size := 0;
				FND_FILE.PUT(FND_FILE.OUTPUT, ', ' || l_trip_name );
			END IF;
                        --Bug 8204644
		END IF;
	END LOOP;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</EMPTY_TRIPS>');
	END IF; --check for number of records in plsql table

	-- print empty deliveries
	IF p_tbl_delivery_purge_set.COUNT > 0 THEN --check for number of records in plsql table
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<EMPTY_DELS>');
        l_buff_size := 0 ;     -- Reset the buffer size to zero
	FOR l_delivery_index in p_tbl_delivery_purge_set.FIRST .. p_tbl_delivery_purge_set.LAST
	LOOP
		l_delivery_id := p_tbl_delivery_purge_set(l_delivery_index).delivery_id;
		l_delivery_name := p_tbl_delivery_purge_set(l_delivery_index).delivery_name;
		IF (p_tbl_delivery_purge_set(l_delivery_index).purge_set_type = 'EMPTYDELS') THEN
			l_empty_del_count := l_empty_del_count+1 ;

                        --Bug 8204644
                        IF ( l_buff_size = 0 AND l_empty_del_count=1 ) THEN
			        l_buff_size := lengthb(l_delivery_name);
			        FND_FILE.PUT(FND_FILE.OUTPUT,l_delivery_name);
                        ELSIF ( l_buff_size = 0 AND l_empty_del_count<>1 ) THEN
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,',');
                                l_buff_size := lengthb(l_delivery_name);
                                FND_FILE.PUT(FND_FILE.OUTPUT,l_delivery_name);
			ELSIF l_buff_size < 30000 THEN
			        l_buff_size := l_buff_size + lengthb(l_delivery_name) + 2;
				FND_FILE.PUT(FND_FILE.OUTPUT, ', ' || l_delivery_name);
			ELSIF l_buff_size >= 30000 THEN
				l_buff_size := 0;
				FND_FILE.PUT(FND_FILE.OUTPUT, ', ' || l_delivery_name );
			END IF;
                        --Bug 8204644

			/*FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<TRIP>');
			IF P_SORT_PER_CRITERIA = 'T' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>999999999</SORT_ID>');
			ELSIF P_SORT_PER_CRITERIA = 'D' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>' || lpad(l_delivery_id,10,'0') || '</SORT_ID>');
			END IF ;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP_ID></TRIP_ID>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DELIVERY_ID>' || l_delivery_id || '</DELIVERY_ID>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</TRIP>');*/

		END IF;
	END LOOP;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</EMPTY_DELS>');
	END IF; --check for number of records in plsql table

	-- print empty containers
	IF p_tbl_container_purge_set.COUNT > 0 THEN --check for number of records in plsql table
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<EMPTY_LPNS>');
        l_buff_size := 0 ;     -- Reset the buffer size to zero
	FOR l_container_index in p_tbl_container_purge_set.FIRST .. p_tbl_container_purge_set.LAST
	LOOP
		l_container_id := p_tbl_container_purge_set(l_container_index).container_id;
		IF (p_tbl_container_purge_set(l_container_index).purge_set_type = 'EMPTYLPNS') THEN
			l_empty_lpn_count := l_empty_lpn_count+1 ;

                        --Bug 8204644
                        IF ( l_buff_size = 0 AND l_empty_lpn_count=1 ) THEN
			        l_buff_size := lengthb(l_container_id);
				FND_FILE.PUT(FND_FILE.OUTPUT,l_container_id);
                        ELSIF ( l_buff_size = 0 AND l_empty_lpn_count<>1 ) THEN
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,',');
                                l_buff_size := lengthb(l_container_id);
                                FND_FILE.PUT(FND_FILE.OUTPUT,l_container_id);
			ELSIF l_buff_size < 30000 THEN
				l_buff_size := l_buff_size + lengthb(l_container_id) + 2;
				FND_FILE.PUT(FND_FILE.OUTPUT, ', ' || l_container_id);
			ELSIF l_buff_size >= 30000 THEN
				l_buff_size := 0;
				FND_FILE.PUT(FND_FILE.OUTPUT, ', ' || l_container_id );
			END IF;
                        --Bug 8204644

			/*FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<TRIP>');
			IF P_SORT_PER_CRITERIA = 'T' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>999999999</SORT_ID>');
			ELSIF P_SORT_PER_CRITERIA = 'D' THEN
				FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<SORT_ID>' || lpad(l_delivery_id,10,'0') || '</SORT_ID>');
			END IF ;
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<TRIP_ID></TRIP_ID>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<DELIVERY_ID>' || l_delivery_id || '</DELIVERY_ID>');
			FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</TRIP>');*/

		END IF;
	END LOOP;
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'</EMPTY_LPNS>');
	END IF; --check for number of records in plsql table

	END IF; --check for print detail
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<NON_EMPTY_COUNT>' || l_nonempty_count || '</NON_EMPTY_COUNT>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<EMPTY_TRIP_COUNT>' || l_empty_trip_count || '</EMPTY_TRIP_COUNT>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<EMPTY_DEL_COUNT>' || l_empty_del_count || '</EMPTY_DEL_COUNT>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'<EMPTY_LPN_COUNT>' || l_empty_lpn_count || '</EMPTY_LPN_COUNT>');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</ROWSET>');

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    l_err := SQLERRM;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END Generate_Purge_Report;


-----------------------------------------------------------------------------
--
-- Procedure:   Purge_Workflow
-- Parameters:  p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		p_tbl_delivery_purge_set  pl/sql table of delivery id's eligible for purge
--		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:	This API deletes the workflows for Trip and Delivery.
-----------------------------------------------------------------------------

PROCEDURE Purge_Workflow(p_tbl_trip_purge_set   Trip_ID_Tbl_Type ,
			 p_tbl_delivery_purge_set    Delivery_ID_Tbl_Type,
			 x_return_status OUT  NOCOPY VARCHAR2) IS

	l_debug_on BOOLEAN;
	l_return_status VARCHAR2(1);

	l_delivery_ids_tab WSH_UTIL_CORE.column_tab_type;
	l_trip_ids_tab WSH_UTIL_CORE.column_tab_type;

	l_success_count NUMBER;

	l_module_name  CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_WORKFLOW';

BEGIN

	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--Check for number of ids in delivery table
	IF p_tbl_delivery_purge_set.COUNT > 0 THEN
		FOR l_delivery_index in p_tbl_delivery_purge_set.FIRST .. p_tbl_delivery_purge_set.LAST
		LOOP
			l_delivery_ids_tab(l_delivery_index) := p_tbl_delivery_purge_set(l_delivery_index).delivery_id;
		END LOOP;

		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.PURGE_ENTITY', WSH_DEBUG_SV.C_PROC_LEVEL);
		    WSH_DEBUG_SV.logmsg(l_module_name,'no of delivery ids =' || l_delivery_ids_tab.count, WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		WSH_WF_STD.Purge_Entity(
				       p_entity_type	=> 'DELIVERY',
				       p_entity_ids	=>l_delivery_ids_tab,
				       --p_action IN VARCHAR2 DEFAULT 'PURGE',
				       --p_docommit IN BOOLEAN DEFAULT FALSE,
				       x_success_count	=> l_success_count,
				       x_return_status	=> l_return_status) ;

		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
			WSH_DEBUG_SV.log(l_module_name,'L_SUCCESS_COUNT',l_success_count);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF; --Check for number of ids in delivery table

	--Check for number of ids in trip table
	IF p_tbl_trip_purge_set.COUNT > 0 THEN
		FOR l_trip_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
		LOOP
			l_trip_ids_tab(l_trip_index) := p_tbl_trip_purge_set(l_trip_index).trip_id;
		END LOOP;

		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_WF_STD.PURGE_ENTITY', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		WSH_WF_STD.Purge_Entity(
				       p_entity_type	=> 'TRIP',
				       p_entity_ids	=>l_trip_ids_tab,
				       --p_action IN VARCHAR2 DEFAULT 'PURGE',
				       --p_docommit IN BOOLEAN DEFAULT FALSE,
				       x_success_count	=> l_success_count,
				       x_return_status	=> l_return_status) ;

		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
			WSH_DEBUG_SV.log(l_module_name,'L_SUCCESS_COUNT',l_success_count);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;
	END IF; --Check for number of ids in trip table

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

END Purge_Workflow;


-----------------------------------------------------------------------------
--
-- Procedure:   Validate_Trips
-- Parameters:  p_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		x_tbl_trip_purge_set  pl/sql table of trip id's eligible for purge
--		after validating all the LPNs belonging to the trip with WMS API
--		x_return_status - Returns WSH_UTIL_CORE.G_RET_STS_SUCCESS if Success

-- Description:	This API call the WMS_Container_Grp API for checking the validity of
--		each LPN belonging to a particular trip.
--		The WMS LPN Purge API returns the list of LPN Ids that are eligible to
--		be purged from WMS side. If the number of LPNs returned by WMS
--		is same as the number of LPNs passed by this API that means that
--		all the LPNs within the trip are eligible to be purged and the
--		further validations for MDC/Moves can be performed on the trip.
--		If the count is not same then the trip is marked as in eligible for
--		purge and is excluded from the list of trips to be purged.
--		This API also checks whether the trip is a part of valid Continuous
--		Move(CM). A valid CM is one in which all the the trips are eligible
--		for purge. If not then the Trip is not eligible to be purged.
--		This API also checks whether the trip is a part of valid MDC
--		configuration. A valid MDC configurationis one in which all
--		the the trips are eligible for purge. If not then the Trip is
--		not eligible to be purged.
-----------------------------------------------------------------------------
PROCEDURE Validate_Trips(	p_tbl_trip_purge_set Trip_ID_Tbl_Type ,
				x_tbl_trip_purge_set OUT  NOCOPY Trip_ID_Tbl_Type ,
				x_return_status OUT  NOCOPY VARCHAR2) IS

	l_debug_on BOOLEAN;
	l_return_status VARCHAR2(1);

	l_trip_id    NUMBER;
	l_move_id    NUMBER;
	l_lpn_id     NUMBER;
	l_trip_index NUMBER;
	l_loop_index NUMBER;
	l_old_move   NUMBER;
	l_new_move   NUMBER;
	l_mdc_trip   NUMBER;
	l_lpn_count  NUMBER;

	l_lpn_valid  BOOLEAN;
	l_move_valid BOOLEAN;
	l_trip_valid BOOLEAN;
	l_move_found BOOLEAN;
	l_trip_found BOOLEAN;

	l_err        VARCHAR2(500);
	sql_tripmove VARCHAR2(4000);

	l_msg_count NUMBER;
	l_msg_data VARCHAR2(32767);

	l_wms_lpn_record WMS_Data_Type_Definitions_PUB.LPNPurgeRecordType;

	--TYPE IDTableType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	--l_lpn_ids IDTableType;

	l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_TRIPS';

	TYPE PurgeCurType IS REF CURSOR;
	c_trip_moves PurgeCurType; --The cursor gets all the moves their trips
					--wherever the move has more than 1 trip
	l_tbl_trip_moves Trip_moves_Tbl_Type;
	l_tbl_trip_mdc WSH_UTIL_CORE.ID_TAB_TYPE;

	CURSOR c_lpns_for_trip(p_tripid NUMBER) IS
	SELECT	wdd.lpn_id
	FROM	wsh_trips wt,
		wsh_trip_stops wts,
		wsh_delivery_legs wdl,
		wsh_new_deliveries wnd,
		wsh_delivery_assignments_v wda,
		wsh_delivery_details wdd
	WHERE	wt.trip_id = wts.trip_id
	AND	wts.stop_id = wdl.pick_up_stop_id
	AND	wdl.delivery_id = wnd.delivery_id
	AND	wda.delivery_id = wnd.delivery_id
	AND	wda.delivery_detail_id = wdd.delivery_detail_id
	AND	wdd.container_flag = 'Y'
	AND	wdd.lpn_id IS NOT NULL
	AND	wts.trip_id = p_tripid;

    -- Bug 5084113
    /* Replaced the query below with a non recursive query
        The query below was fetching,
        1. All the deliveries of consolidation type( wnd.delivery_type = 'CONSOLIDATION' or wdl.parent_delivery_leg_id IS NULL )
        2. Search for possible consolidations within the above list.
        3. Build the list of deliveries under consolidation deliveries in step2 and identify the list of trips.

	CURSOR c_get_mdc_trips(p_tripid NUMBER) IS
	SELECT
	DISTINCT wt1.trip_id
	FROM
	wsh_trips wt1,
	wsh_trip_stops pickup_stop1,
	wsh_trip_stops dropoff_stop1,
	wsh_delivery_legs wdl1
	WHERE
	wdl1.pick_up_stop_id = pickup_stop1.stop_id AND
	wdl1.drop_off_stop_id = dropoff_stop1.stop_id AND
	wt1.trip_id = pickup_stop1.trip_id AND
	wt1.trip_id = dropoff_stop1.trip_id AND
	wdl1.delivery_id IN (SELECT delivery_id
			     FROM   wsh_delivery_legs
			     START WITH delivery_id IN (SELECT delivery_id
						      FROM wsh_delivery_legs
						      WHERE parent_delivery_leg_id IS NULL
						      START WITH delivery_id IN (SELECT wdl.delivery_id
										     FROM
										     wsh_new_deliveries wnd,
										     wsh_delivery_legs wdl,
										     wsh_trip_stops pickup_stop,
										     wsh_trip_stops dropoff_stop,
										     wsh_trips wt
										     WHERE
										     wnd.delivery_id = wdl.delivery_id AND
										     wdl.pick_up_stop_id = pickup_stop.stop_id AND
										     wdl.drop_off_stop_id = dropoff_stop.stop_id AND
										     wt.trip_id = pickup_stop.trip_id AND
										     wt.trip_id = dropoff_stop.trip_id AND
										     ((wnd.delivery_type = 'CONSOLIDATION')
										      OR
										      (wdl.parent_delivery_leg_id IS NULL)
										     ) AND
										     wt.trip_id = p_tripid)
						      CONNECT BY delivery_leg_id = PRIOR parent_delivery_leg_id )
			     CONNECT BY parent_delivery_leg_id = PRIOR delivery_leg_id)
	ORDER BY wt1.trip_id;
    */

    CURSOR c_get_mdc_trips(p_tripid NUMBER) IS
    SELECT
    DISTINCT wt1.trip_id
    FROM
    wsh_trips wt1,
    wsh_trip_stops wts,
    wsh_delivery_legs wdl1
    WHERE
    (wdl1.pick_up_stop_id = wts.stop_id OR
    wdl1.drop_off_stop_id = wts.stop_id) AND
    wt1.trip_id = wts.trip_id AND
    wdl1.delivery_id IN
    (
     SELECT delivery_id
     FROM wsh_delivery_legs
     WHERE parent_delivery_leg_id
     IN
     (
          SELECT wdl.delivery_leg_id
          FROM
          wsh_delivery_legs wdl,
          wsh_trip_stops wts,
          wsh_trips wt
          WHERE
          (wdl.pick_up_stop_id = wts.stop_id OR
          wdl.drop_off_stop_id = wts.stop_id) AND
          wt.trip_id = wts.trip_id AND
          wdl.parent_delivery_leg_id IS NULL AND
          wt.trip_id =  p_tripid
     )
    )
    ORDER BY wt1.trip_id;

BEGIN
	-- Debug Statements
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_lpn_valid := TRUE;

	IF (wsh_util_core.fte_is_installed='Y') THEN
		sql_tripmove := 'SELECT move_id, trip_id
				FROM fte_trip_moves
				WHERE move_id IN
				(SELECT move_id
				FROM fte_trip_moves
				GROUP BY move_id
				HAVING count(trip_id) >1 )
				ORDER BY move_id';

		OPEN c_trip_moves FOR sql_tripmove;
		FETCH c_trip_moves BULK COLLECT into l_tbl_trip_moves;
		CLOSE c_trip_moves;
	END IF;

	FOR l_trip_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
	LOOP
		l_lpn_valid := TRUE;
		l_trip_id := p_tbl_trip_purge_set(l_trip_index).trip_id;
		--Get all the LPNs for the Trip
		OPEN c_lpns_for_trip(l_trip_id);
		FETCH c_lpns_for_trip BULK COLLECT into l_wms_lpn_record.LPN_IDs;
		CLOSE c_lpns_for_trip;

		l_lpn_count := l_wms_lpn_record.LPN_IDs.COUNT;

		--call WMS API to check whether the LPN is eligible for purge
		IF l_debug_on THEN
		    WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WMS_CONTAINER_GRP.LPN_PURGE_ACTIONS', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		WMS_Container_GRP.LPN_Purge_Actions(	p_api_version	=>1.0,
							p_init_msg_list	=>FND_API.G_TRUE,
							p_commit	=>'FALSE',
							x_return_status	=>l_return_status,
							x_msg_count	=>l_msg_count,
							x_msg_data	=>l_msg_data,
							p_caller	=>'WSH',
							p_action	=>WMS_Container_GRP.G_LPN_PURGE_ACTION_VALIDATE,
							p_lpn_purge_rec	=> l_wms_lpn_record
						   );

		IF l_debug_on THEN
			WSH_DEBUG_SV.log(l_module_name,'L_RETURN_STATUS',l_return_status);
			WSH_DEBUG_SV.log(l_module_name,'L_MSG_DATA',l_msg_data);
		END IF;

		IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			IF l_debug_on THEN
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;
			RETURN;
		END IF;

		IF l_lpn_count <> l_wms_lpn_record.LPN_IDs.COUNT THEN
			l_lpn_valid := FALSE;
		END IF;

		--Check for Trip Moves/MDC related validations only when LPN check returns TRUE
		IF l_lpn_valid THEN -- is there some other way to stop the loop here and
				    -- and continue the loop with the next value ?
			l_trip_valid := TRUE;
			l_move_found := FALSE;
			--Check for Trip Moves related validations
			IF l_tbl_trip_moves.COUNT > 0 THEN
				FOR l_loop_index in l_tbl_trip_moves.FIRST .. l_tbl_trip_moves.LAST
				LOOP
					IF l_tbl_trip_moves(l_loop_index).trip_id = l_trip_id THEN
						l_move_id := l_tbl_trip_moves(l_loop_index).move_id;
						l_move_found := TRUE;
						FOR l_move_index in l_tbl_trip_moves.FIRST .. l_tbl_trip_moves.LAST
						LOOP
							l_old_move := l_new_move;
							l_new_move :=l_tbl_trip_moves(l_move_index).move_id;
							IF (l_old_move IS NOT NULL AND l_old_move <> l_new_move) THEN
								EXIT;
							END IF;

							IF l_tbl_trip_moves(l_move_index).move_id = l_move_id THEN
								l_trip_id := l_tbl_trip_moves(l_move_index).trip_id;
								l_trip_valid := FALSE;
								FOR l_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
								LOOP
									IF p_tbl_trip_purge_set(l_index).trip_id = l_trip_id THEN
										l_trip_valid := TRUE;
									END IF;
									EXIT WHEN l_trip_valid;
								END LOOP;

								IF NOT l_trip_valid THEN
									EXIT;
								END IF;
							END IF;
						END LOOP;
					END IF;
					EXIT WHEN l_move_found;
				END LOOP;
			END IF;
			--End Check for Trip Moves related validations

			--Check for MDC related validations only if Trip Move related validation returns TRUE
			IF l_trip_valid THEN
				OPEN c_get_mdc_trips(l_trip_id);
				FETCH c_get_mdc_trips BULK COLLECT into l_tbl_trip_mdc;
				CLOSE c_get_mdc_trips;
				--Check for MDC related validations
				IF l_tbl_trip_mdc.COUNT > 1 THEN
					FOR l_loop_index in l_tbl_trip_mdc.FIRST .. l_tbl_trip_mdc.LAST
					LOOP
						l_mdc_trip := l_tbl_trip_mdc(l_loop_index);
						l_trip_valid := FALSE;
						FOR l_index in p_tbl_trip_purge_set.FIRST .. p_tbl_trip_purge_set.LAST
						LOOP
							IF p_tbl_trip_purge_set(l_index).trip_id = l_mdc_trip THEN
								l_trip_valid := TRUE;
							END IF;
							EXIT WHEN l_trip_valid;
						END LOOP;
						EXIT WHEN NOT l_trip_valid;
					END LOOP;
				END IF; --End check for MDC related validations
			END IF;--Check for MDC related validations only if Trip Move related validation returns TRUE
		END IF; --End Check for Trip Moves/MDC related validations only when LPN check returns TRUE

		IF l_lpn_valid AND l_trip_valid THEN
			x_tbl_trip_purge_set(x_tbl_trip_purge_set.COUNT+1).trip_id := p_tbl_trip_purge_set(l_trip_index).trip_id;
			x_tbl_trip_purge_set(x_tbl_trip_purge_set.COUNT).trip_name := p_tbl_trip_purge_set(l_trip_index).trip_name;
			x_tbl_trip_purge_set(x_tbl_trip_purge_set.COUNT).purge_set_type := p_tbl_trip_purge_set(l_trip_index).purge_set_type;
		END IF ;
	END LOOP;

	IF l_debug_on THEN
	    WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR ;
    l_err := SQLERRM;

    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '||
	SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END Validate_Trips ;

END WSH_PURGE;

/
