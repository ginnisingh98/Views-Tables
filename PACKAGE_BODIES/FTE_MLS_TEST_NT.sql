--------------------------------------------------------
--  DDL for Package Body FTE_MLS_TEST_NT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_MLS_TEST_NT" as
/* $Header: FTEMLTEB.pls 120.4 2005/07/14 08:18 nltan noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_MLS_TEST_NT';
--
--========================================================================
-- PROCEDURE : ASSIGN_SERVICE_TENDER        FTE wrapper
--
-- COMMENT   : Procedure assigns service, creates/updates ranked list,
--             tenders, and deletes rates. TripId should exist in the db.
--	       If FTE_SS_ATTR_REC.DELIVERY_ID and
--	       FTE_SS_ATTR_REC.DELIVERY_LEG_ID are null, then it means the
--             caller is TWB. Otherwise, the caller is DWB or ManItinerary
-- CALLER    : FTE UI: TripWB, DeliveryWB, ManageItinerary
--========================================================================
--
PROCEDURE ASSIGN_SERVICE_TENDER
(
	p_API_VERSION_NUMBER	IN	NUMBER,
	p_INIT_MSG_LIST		IN	VARCHAR2,
	p_COMMIT		IN	VARCHAR2,
	p_SS_ATTR_REC		IN	FTE_SS_ATTR_REC,
	p_SS_RATE_SORT_TAB	IN OUT NOCOPY FTE_SS_RATE_SORT_TAB_TYPE,
	p_TENDER_ATTR_REC	IN	FTE_TENDER_ATTR_REC,
	p_REQUEST_ID		IN	NUMBER,
	p_SERVICE_ACTION	IN	VARCHAR2,
	p_LIST_ACTION		IN	VARCHAR2,
	x_RETURN_STATUS		OUT NOCOPY VARCHAR2,
	x_MSG_COUNT		OUT NOCOPY NUMBER,
	x_MSG_DATA		OUT NOCOPY VARCHAR2)
  IS
	l_number_of_warnings	NUMBER;
	l_number_of_errors	NUMBER;
	l_return_status         VARCHAR2(32767);
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(32767);

	l_trip_id		NUMBER;
	l_delivery_leg_id	NUMBER;
	l_delivery_id		NUMBER;
	l_lane_id		NUMBER;
	l_carrier_id		NUMBER;
	l_mode			VARCHAR2(30);
	l_service_level		VARCHAR2(30);
	l_veh_item_id		NUMBER;
	l_veh_org_id		NUMBER;
	l_rank_id		NUMBER;
	l_schedule_id		NUMBER;

	l_ret_trip_name		VARCHAR2(30);
	l_ret_trip_id		NUMBER;
	l_list_action		VARCHAR2(30);

	l_ss_rate_sort_rec	FTE_SS_RATE_SORT_REC;
	l_action_out_rec	FTE_ACTION_OUT_REC;
	l_trip_action_param	FTE_TRIP_ACTION_PARAM_REC;

    	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.'|| G_PKG_NAME ||'.'||'ASSIGN_SERVICE_TENDER';

  BEGIN

  SAVEPOINT	ASSIGN_SERVICE_TENDER_PUB;

      	-- Initialize message list if p_init_msg_list is set to TRUE.
    	--
    	IF FND_API.to_Boolean( p_init_msg_list )
    	THEN
    		FND_MSG_PUB.initialize;
    	END IF;
	--
    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;
    	--
  	--
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;

	-- local variables used to check API return values
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	l_trip_id 		:= p_ss_attr_rec.trip_id;
	l_delivery_leg_id 	:= p_ss_attr_rec.delivery_leg_id;
	l_delivery_id		:= p_ss_attr_rec.delivery_id;
	l_list_action		:= p_list_action;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'TripId:LegId:DeliveryId:'
            		||l_trip_id||':'||l_delivery_leg_id||':'||l_delivery_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Service Action:List Action:'
            		||p_service_action||':'||p_list_action);
        END IF;

	-- Step 1: Check if old service exists on trip
	-- If p_service_action indicates service is currently assigned, delete old rates
	-- and raise appropriate business event
	IF ( p_service_action = 'UPDATE' AND l_trip_id IS NOT NULL
		AND l_delivery_leg_id IS NULL ) THEN

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Deleting Main Records for:'||l_trip_id);
        END IF;

		FTE_TRIP_RATING_GRP.DELETE_MAIN_RECORDS(
			p_trip_id => l_trip_id,
			x_return_status => l_return_status);


		WSH_UTIL_CORE.API_POST_CALL(
		      	p_return_status    =>l_return_status,
		      	x_num_warnings     =>l_number_of_warnings,
		      	x_num_errors       =>l_number_of_errors,
		      	p_msg_data	   =>l_msg_data);
	END IF;

	-- Step 2: Check if l_list_action is correct.
	-- Get the first record in the service table.
	-- If LaneId is null, change l_list_action = 'SET_CURRENT'.

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'List Action:'||p_list_action);
            WSH_DEBUG_SV.logmsg(l_module_name, ' Service List Size:'||p_ss_rate_sort_tab.count);
        END IF;

	IF ( l_list_action = 'APPEND' ) THEN
	    l_ss_rate_sort_rec := p_ss_rate_sort_tab(1);

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Append Check Rank Id:'||l_ss_rate_sort_rec.rank_id);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Append Check Lane Id:'||l_ss_rate_sort_rec.lane_id);
              END IF;

	      IF (l_ss_rate_sort_rec.rank_id IS NOT NULL AND l_ss_rate_sort_rec.lane_id IS NULL) THEN
	    	     -- l_ss_rate_sort_rec.schedule_id IS NULL AND
		l_rank_id := l_ss_rate_sort_rec.rank_id;
		l_list_action := 'SET_CURRENT';

	        IF l_debug_on THEN
	            WSH_DEBUG_SV.logmsg(l_module_name, 'Only rank id populated:'||l_rank_id);
	        END IF;
	      END IF;
	END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, ' New List Action:'||l_list_action);
        END IF;


	-- Step 3: Create, Append or SetCurrent Ranked List depending on list action_code
	-- Values will be CREATE OR APPEND. Modify APPEND to be either APPEND or SET_CURRENT
	-- CREATE: Manual condition, set IS_CURRENT for selected service
	-- SET_CURRENT: Only pass user entry as current. Version is increased. Do no
	--	pass service tab, only rankId
	-- APPEND: Pass in one record service tab (entry has no rankId or sequence)
	--	Entry appended to existing list with next ranked seq. Set IS_CURRENT on record.
	-- OUT param is the new rankId to be stored on the trip

	IF ( l_list_action IS NOT NULL AND l_trip_id IS NOT NULL) THEN
	  IF ( p_list_action = 'SET_CURRENT' ) THEN
	  	FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION_UIWRAPPER(
	  		p_API_VERSION_NUMBER	=> 1.0,
	  		p_INIT_MSG_LIST		=> FND_API.G_TRUE,
	  		p_ACTION_CODE		=> l_list_action,
	  		p_RANKLIST		=> p_ss_rate_sort_tab,
	  		p_RANK_ID		=> l_rank_id,
	  		p_TRIP_ID		=> l_trip_id,
	  		x_RETURN_STATUS		=> l_return_status,
	  		x_MSG_COUNT		=> l_msg_count,
	  		x_MSG_DATA		=> l_msg_data);
	  ELSE
	  	FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION_UIWRAPPER(
	  		p_API_VERSION_NUMBER	=> 1.0,
	  		p_INIT_MSG_LIST		=> FND_API.G_TRUE,
	  		p_ACTION_CODE		=> l_list_action,
	  		p_RANKLIST		=> p_ss_rate_sort_tab,
	  		p_RANK_ID		=> l_rank_id,
	  		p_TRIP_ID		=> l_trip_id,
	  		x_RETURN_STATUS		=> l_return_status,
	  		x_MSG_COUNT		=> l_msg_count,
	  		x_MSG_DATA		=> l_msg_data);
	  END IF;

	  WSH_UTIL_CORE.API_POST_CALL(
      	    p_return_status	=> l_return_status,
      	    x_num_warnings     	=> l_number_of_warnings,
            x_num_errors       	=> l_number_of_errors,
     	    p_msg_data	       	=> l_msg_data);

	END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'New Rank Id:'||l_rank_id);
        END IF;

	-- Step 4: Update Trip
	-- If delivery_id is null, this call is coming from TripWB. Update Trip with
	-- 	current service from FTE_SS_ATTR_REC and rank id.
	-- Else this call is coming from DWB or MI. Update Trip with Rank Id only.

	IF (l_delivery_id IS NULL ) THEN -- Coming from TWB

		l_lane_id	:= p_ss_attr_rec.lane_id;
		l_schedule_id	:= p_ss_attr_rec.schedule_id;
		l_carrier_id	:= p_ss_attr_rec.carrier_id;
		l_mode		:= p_ss_attr_rec.mode_of_transport;
		l_service_level	:= p_ss_attr_rec.service_level;
		l_veh_item_id	:= p_ss_attr_rec.vehicle_item_id;
		l_veh_org_id	:= p_ss_attr_rec.vehicle_org_id;

	  FTE_MLS_WRAPPER.UPDATE_SERVICE_ON_TRIP(
		p_API_VERSION_NUMBER	=> 1.0,
		p_INIT_MSG_LIST		=> FND_API.G_TRUE,
		p_COMMIT		=> FND_API.G_FALSE,
 		p_CALLER		=> 'FTE',
		p_SERVICE_ACTION	=> p_service_action,
		p_DELIVERY_ID		=> l_delivery_id,
		p_DELIVERY_LEG_ID	=> l_delivery_leg_id,
		p_TRIP_ID		=> l_trip_id,
		p_LANE_ID		=> l_lane_id,
		p_SCHEDULE_ID		=> null, -- Need to change to real schedule
		p_CARRIER_ID		=> l_carrier_id,
		p_SERVICE_LEVEL		=> l_service_level,
		p_MODE_OF_TRANSPORT	=> l_mode,
		p_VEHICLE_ITEM_ID	=> l_veh_item_id,
		p_VEHICLE_ORG_ID	=> l_veh_org_id,
		p_CONSIGNEE_CARRIER_AC_NO => FND_API.G_MISS_CHAR,
		p_FREIGHT_TERMS_CODE	=> FND_API.G_MISS_CHAR,
		x_RETURN_STATUS		=> l_return_status,
		x_MSG_COUNT		=> l_msg_count,
		x_MSG_DATA		=> l_msg_data);

	ELSE -- Coming from DWB/MI
	  FTE_MLS_WRAPPER.UPDATE_SERVICE_ON_TRIP(
		p_API_VERSION_NUMBER	=> 1.0,
		p_INIT_MSG_LIST		=> FND_API.G_TRUE,
		p_COMMIT		=> FND_API.G_FALSE,
 		p_CALLER		=> 'FTE',
		p_SERVICE_ACTION	=> p_service_action,
		p_DELIVERY_ID		=> l_delivery_id,
		p_DELIVERY_LEG_ID	=> l_delivery_leg_id,
		p_TRIP_ID		=> l_trip_id,
		p_LANE_ID		=> FND_API.G_MISS_NUM,
		p_SCHEDULE_ID		=> FND_API.G_MISS_NUM,
		p_CARRIER_ID		=> FND_API.G_MISS_NUM,
		p_SERVICE_LEVEL		=> FND_API.G_MISS_CHAR,
		p_MODE_OF_TRANSPORT	=> FND_API.G_MISS_CHAR,
		p_VEHICLE_ITEM_ID	=> FND_API.G_MISS_NUM,
		p_VEHICLE_ORG_ID	=> FND_API.G_MISS_NUM,
		p_CONSIGNEE_CARRIER_AC_NO => FND_API.G_MISS_CHAR,
		p_FREIGHT_TERMS_CODE	=> FND_API.G_MISS_CHAR,
		x_RETURN_STATUS		=> l_return_status,
		x_MSG_COUNT		=> l_msg_count,
		x_MSG_DATA		=> l_msg_data);
	END IF;

	-- Step 5: Move FC Rates
	-- If delivery_id is null, this call is coming from TripWB.

        IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling Move FC TEMP Request Id:'||p_request_id);
              WSH_DEBUG_SV.logmsg(l_module_name,' If Delivery Id is NULL, from TWB:'||l_delivery_id);
        END IF;

	IF ( p_request_id IS NOT NULL ) THEN

	  IF (l_delivery_id IS NULL ) THEN -- Coming from TWB

	    FTE_TRIP_RATING_GRP.Move_Records_To_Main(
               p_trip_id          	=> l_trip_id,
               p_lane_id          	=> l_lane_id,
               p_schedule_id      	=> l_schedule_id,
               p_service_type_code	=> l_service_level,
               p_comparison_request_id 	=> p_request_id,
               x_return_status    	=> l_return_status);
/*
	  ELSE -- Coming from DWB/MI

            FTE_FREIGHT_PRICING.MOVE_FC_TEMP_TO_MAIN(
 		p_init_msg_list   	=> FND_API.G_FALSE,
                p_request_id      	=> p_request_id,
                p_trip_id	  	=> l_trip_id,
                p_lane_id         	=> l_lane_id,
                p_schedule_id     	=> l_schedule_id,
                p_service_type_code 	=> l_service_level,
                x_return_status   	=> l_return_status);
*/

	  END IF;

          WSH_UTIL_CORE.API_POST_CALL(
		p_return_status    =>l_return_status,
		x_num_warnings     =>l_number_of_warnings,
		x_num_errors       =>l_number_of_errors,
		p_msg_data	   =>l_msg_data);

	END IF;

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Pre Raising Tender Event CarrierContactId:'
              					||p_tender_attr_rec.car_contact_id);
          END IF;

	-- Step 6: Raise Tender event
	IF ( p_tender_attr_rec IS NOT NULL AND
		p_tender_attr_rec.car_contact_id IS NOT NULL) THEN

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Raising Tender Event CarrierContactId:'
              					||p_tender_attr_rec.car_contact_id);
          END IF;

 	  -- Create Trip Actions Tab
 	  l_trip_action_param := FTE_TRIP_ACTION_PARAM_REC(null,'TENDERED',
 					null,null,null,null,null,null,
 					null,null,null,null,null,null,
 					null,null);

 	  FTE_MLS_WRAPPER.TRIP_ACTION(
 		p_api_version_number	=> 1.0,
 		p_init_msg_list		=> FND_API.G_TRUE,
 		p_action_prms		=> l_trip_action_param,
 		p_trip_info_rec		=> p_tender_attr_rec,
 		x_action_out_rec	=> l_action_out_rec,
 		x_return_status		=> l_return_status,
 		x_msg_count		=> l_msg_count,
 		x_msg_data		=> l_msg_data);

	  WSH_UTIL_CORE.API_POST_CALL(
	      	p_return_status    =>l_return_status,
	      	x_num_warnings     =>l_number_of_warnings,
	      	x_num_errors       =>l_number_of_errors,
	     	p_msg_data	   =>l_msg_data);
	END IF;


        IF l_debug_on THEN
            WSH_DEBUG_SV.POP(l_module_name);
        END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO ASSIGN_SERVICE_TENDER_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO ASSIGN_SERVICE_TENDER_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO ASSIGN_SERVICE_TENDER_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
END ASSIGN_SERVICE_TENDER;
--
PROCEDURE SEARCH_SERVICES
(
	p_API_VERSION_NUMBER	IN	NUMBER,
	p_INIT_MSG_LIST		IN	VARCHAR2,
	p_COMMIT		IN	VARCHAR2,
	p_CALLER		IN	VARCHAR2,
	p_FTE_SS_ATTR_REC	IN	FTE_SS_ATTR_REC,
	x_LIST_CREATE_TYPE	OUT NOCOPY VARCHAR2,
	x_SS_RATE_SORT_TAB	OUT NOCOPY FTE_SS_RATE_SORT_TAB_TYPE,
	x_PRICING_REQUEST_ID	OUT NOCOPY NUMBER,
	x_RETURN_STATUS		OUT NOCOPY VARCHAR2,
	x_MSG_COUNT		OUT NOCOPY NUMBER,
	x_MSG_DATA		OUT NOCOPY VARCHAR2
)
  IS
    	l_ss_rate_sort_rec	FTE_SS_RATE_SORT_REC;
    	l_ss_rate_sort_rec2	FTE_SS_RATE_SORT_REC;
        l_ss_rate_sort_rec3     FTE_SS_RATE_SORT_REC;
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.'|| G_PKG_NAME ||'.'||'SEARCH_SERVICES';

  BEGIN

  SAVEPOINT	SEARCH_SERVICES_PUB;


    	-- Initialize message list if p_init_msg_list is set to TRUE.
    	--
    	--IF FND_API.to_Boolean( p_init_msg_list )
    	--THEN
    		FND_MSG_PUB.initialize;
    	--END IF;
	--
    	IF l_debug_on THEN
    	      wsh_debug_sv.push(l_module_name);
	END IF;
    	--
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;

	x_SS_RATE_SORT_TAB	:= FTE_SS_RATE_SORT_TAB_TYPE();
	--x_LIST_CREATE_TYPE	:= 'MAN';
        x_LIST_CREATE_TYPE      := 'RG';
	--

   	l_ss_rate_sort_rec3	:= FTE_SS_RATE_SORT_REC(
   		3, 3,
      		14003, null, 67278, 'LTL', 'LTL', null, null,
     		null, 'MAN', 650, 'USD',
     		0, 'DAY', null, null,
     		'N', 0, 205, null, null);

  	x_SS_RATE_SORT_TAB.EXTEND;
  	x_SS_RATE_SORT_TAB(1)	:= l_ss_rate_sort_rec3;

	l_ss_rate_sort_rec	:= FTE_SS_RATE_SORT_REC(
    		1, 1,
    		1408, null, 14012, 'LTL', 'LTL', null, null,
   		null, 'RG', 900, 'KRW',
   		5, 'DAY', null, null,
   		'N', 1, 100, null, null);

  	x_SS_RATE_SORT_TAB.EXTEND;
  	x_SS_RATE_SORT_TAB(2)	:= l_ss_rate_sort_rec;

   	l_ss_rate_sort_rec2	:= FTE_SS_RATE_SORT_REC(
   		2, 2,
      		1490, null, 49275, 'TRUCK', 'STANDARD', 16817, 204,
     		null, 'MAN', 643, 'USD',
     		'2', 'DAY', null, null,
     		'Y', 0, 200, null, null);

  	x_SS_RATE_SORT_TAB.EXTEND;
  	x_SS_RATE_SORT_TAB(3)	:= l_ss_rate_sort_rec2;

	x_PRICING_REQUEST_ID	:= 21;

	--
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO SEARCH_SERVICES_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO SEARCH_SERVICES_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN OTHERS THEN
		ROLLBACK TO SEARCH_SERVICES_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
END SEARCH_SERVICES;
--
END FTE_MLS_TEST_NT;

/
