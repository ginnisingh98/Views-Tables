--------------------------------------------------------
--  DDL for Package Body FTE_SS_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_SS_INTERFACE" AS
/* $Header: FTESSITB.pls 120.21 2005/11/04 14:18:32 nltan noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_SS_INTERFACE';


-- For Rel 12 HBHAGAVA

--{
PROCEDURE RATE_SORT_WRAPPER(p_ss_rate_sort_tbl IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
			    x_ss_rate_sort_tbl  OUT NOCOPY  FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type)
IS

l_ss_rate_sort_rec FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;


BEGIN

	x_ss_rate_sort_tbl := FTE_SS_INTERFACE.G_SS_RATE_SORT_RESULTS;



EXCEPTION

WHEN OTHERS THEN
	wsh_util_core.default_handler('FTE_SS_INTERFACE.RATE_SORT_WRAPPER');

END RATE_SORT_WRAPPER;
--}



--{
PROCEDURE GET_RANKED_RESULTS(  p_rule_id          IN NUMBER,
                               x_routing_results  OUT NOCOPY  FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
                               x_return_status      OUT NOCOPY VARCHAR2)
IS



BEGIN

		-- return back rank list tbl type

	IF (G_RG_DEBUG = 'ON')
	THEN
		x_routing_results := G_ROUTING_GUIDE_RESULTS;
		x_return_status := 'S';
	ELSE
	/**
		FTE_ACS_TRIP_PKG.get_ranked_results(p_rule_id,
						x_routing_results,
						x_return_status);
	*/
		x_return_status := 'S';
	END IF;


END GET_RANKED_RESULTS;
--}


--{
PROCEDURE ROUTING_GUIDE_MAIN(x_routing_results  OUT NOCOPY  FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
                             x_return_status      OUT NOCOPY VARCHAR2)
IS



BEGIN

		-- return back rank list tbl type

	IF (G_SEQ_DEBUG = 'ON')
	THEN
		x_routing_results := G_ROUTING_GUIDE_RESULTS;
	END IF;

	x_return_status := 'S';

END ROUTING_GUIDE_MAIN;
--}


PROCEDURE LOG(p_module_name	VARCHAR2,
		p_text		VARCHAR2,
		p_level		VARCHAR2)
IS



BEGIN

	      WSH_DEBUG_SV.logmsg(p_module_name,p_text,p_level);
	      --dbms_output.put_line(p_module_name || ' ' || p_text);

END LOG;


PROCEDURE DERIVE_INITIAL_SHIPMETHOD(
	p_rank_list_rec		IN	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec,
	x_carrier_id		OUT NOCOPY	NUMBER,
	x_service_level		OUT NOCOPY	VARCHAR2,
	x_mode_of_transport	OUT NOCOPY	VARCHAR2)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'DERIVE_INITIAL_SHIPMETHOD';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


BEGIN

		IF l_debug_on THEN
		      WSH_DEBUG_SV.push(l_module_name);
		END IF;


		x_carrier_id := p_rank_list_rec.carrier_id;
		x_service_level := p_rank_list_rec.service_level;
		x_mode_of_transport := p_rank_list_rec.mode_of_transport;

		IF l_debug_on
		THEN
		      LOG(l_module_name,
			' InitSMConfig value  ' || p_rank_list_rec.INITSMCONFIG || ' , ' ||
					length(p_rank_list_rec.INITSMCONFIG),
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		IF (length(p_rank_list_rec.INITSMCONFIG) = 1)
		THEN
		--{
			IF (p_rank_list_rec.INITSMCONFIG = 'C')
			THEN
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Pass in carrier as search option ' ||
					 p_rank_list_rec.carrier_id,
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				x_service_level := null;
				x_mode_of_transport := null;

			--}
			ELSIF (p_rank_list_rec.INITSMCONFIG = 'S')
			THEN
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Pass in Service level as search option ' ||
					 p_rank_list_rec.service_level,
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				x_carrier_id := null;
				x_mode_of_transport := null;
				-- Just service level is part of partial shipmethod
			ELSIF (p_rank_list_rec.INITSMCONFIG = 'M')
			THEN
			--{
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Pass in Mode as search option ' ||
					 p_rank_list_rec.mode_of_transport,
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				x_carrier_id := null;
				x_service_level := null;
			--}
			END IF;
			--}
		ELSIF (length(p_rank_list_rec.INITSMCONFIG) = 2)
		THEN
		--{
			IF (p_rank_list_rec.INITSMCONFIG = 'CS')
			THEN
				-- carrier and service level is part of partial shipmethod
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Carrier and Service level ' ||
					 p_rank_list_rec.carrier_id || ' ' ||
					 p_rank_list_rec.service_level,
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				x_mode_of_transport := null;

			ELSIF (p_rank_list_rec.INITSMCONFIG = 'CM')
			THEN
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Carrier and Mode ' ||
					 p_rank_list_rec.carrier_id || ' ' ||
					 p_rank_list_rec.mode_of_transport,
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				x_service_level := null;

			ELSIF (p_rank_list_rec.INITSMCONFIG = 'SM')
			THEN
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Service level and Mode ' ||
					 p_rank_list_rec.service_level|| ' ' ||
					 p_rank_list_rec.mode_of_Transport,
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
				x_carrier_id := null;
			END IF;
		--}
		ELSE
			IF l_debug_on
			THEN
			      LOG(l_module_name,
				' Pass in null for all values ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			x_carrier_id := NULL;
			x_service_level := NULL;
			x_mode_of_transport := NULL;

		END IF;

		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		END IF;
EXCEPTION

WHEN OTHERS THEN
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
END DERIVE_INITIAL_SHIPMETHOD;


PROCEDURE CREATE_SEARCH_CRITERIA_WF(
	P_API_VERSION_NUMBER		IN		NUMBER,
	P_INIT_MSG_LIST			IN		VARCHAR2,
	P_COMMIT			IN		VARCHAR2,
	P_CALLER			IN		VARCHAR2,
	P_FTE_SS_ATTR_REC		IN		FTE_SS_ATTR_REC,
	X_SS_RATE_SORT_TAB		OUT NOCOPY	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	X_SAVE_RANK_LIST		OUT NOCOPY	VARCHAR2,
	X_RANK_EXIST_TAB		OUT NOCOPY	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	NUMBER,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2)
IS
--{


--{ Local variables

l_api_name              CONSTANT VARCHAR2(30)   := 'CREATE_SEARCH_CRITERIA_WF';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_rank_list_tbl			FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_routing_results		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_rank_list_rec			FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;
l_routing_results_rec		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;

l_rank_exist_rec		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;
l_new_rank_list_rec		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;

l_tbl_count		    NUMBER;
l_initsmconfig		    VARCHAR2(3);
l_uismconfig		    VARCHAR2(3);

l_carrier_id		    NUMBER;
l_service_level		    VARCHAR2(30);
l_mode_of_transport	    VARCHAR2(30);


--}

BEGIN


	SAVEPOINT   CREATE_SEARCH_CRITERIA_WF_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	-- Get the rank list
	FTE_CARRIER_RANK_LIST_PVT.GET_RANK_LIST(
		p_init_msg_list	        => 1.0,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		x_ranklist		=> l_rank_list_tbl,
		p_trip_id		=> P_FTE_SS_ATTR_REC.TRIP_ID);

	l_tbl_count := l_rank_list_tbl.COUNT;

	IF l_debug_on
	THEN
	      LOG(l_module_name,' Carrier Rank list count ' ||
	      			l_tbl_count,WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Append list flag = ' ||
				P_FTE_SS_ATTR_REC.APPEND_LIST_FLAG,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Rule Id = ' ||
				P_FTE_SS_ATTR_REC.RULE_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Existing Rank Id = ' ||
				P_FTE_SS_ATTR_REC.RANK_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF (l_tbl_count = 0)
	THEN
	--{
		-- This is not possible for workflow.

		IF l_debug_on
		THEN
		      LOG(l_module_name,' This is possible when there is nothing in rank list ' ||
		      			'and user is doing search serivces from UI. Just add ' ||
		      			' UI level info and search ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

	--}
	ELSIF (l_tbl_count = 1)
	THEN
	--{
		l_rank_list_rec := l_rank_list_tbl(1);

		IF l_debug_on
		THEN
		      LOG(l_module_name,' Found entry. Source = ' ||
					l_rank_list_rec.source,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      LOG(l_module_name,' InitSMConfig = ' ||
					l_rank_list_rec.INITSMCONFIG,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      LOG(l_module_name,' Lane Id = ' ||
					l_rank_list_rec.LANE_ID,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		X_RANK_EXIST_TAB(1) := 	l_rank_list_rec;

		IF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_RG)
		THEN
		--{
			-- First copy the existing service to out tab so that it can be send back


			-- there is a service on the rank entry but it is possible to have
			-- initial shipmethod as partial. So we have to check initsmconfig

			IF (l_rank_list_rec.INITSMCONFIG = 'CSM')
			THEN
			--{
			    IF l_debug_on
			    THEN
					LOG(l_module_name,
					' Initial Shipmethod is full ',WSH_DEBUG_SV.C_PROC_LEVEL);
			    END IF;

			    -- 1 Full SM / 1 Full SM with Service Case
			    -- Check append list flag
			    IF (P_FTE_SS_ATTR_REC.APPEND_LIST_FLAG = 'Y')
			    THEN
			    --{
				IF l_debug_on
				THEN
					LOG(l_module_name,
					' Calling Routing Guide Rule _id ' ||
							P_FTE_SS_ATTR_REC.RULE_ID,
								WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				GET_RANKED_RESULTS(p_rule_id => P_FTE_SS_ATTR_REC.RULE_ID,
						    x_routing_results => l_routing_results,
						    x_return_status => l_return_status);


				IF (l_return_status = 'E')
				THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_status = 'U')
				THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;



				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Build X_SS_RATE_SORT_TAB for search ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				IF (l_routing_results.COUNT > 0)
				THEN
				--{

					FOR i IN l_routing_results.FIRST..l_routing_results.LAST
					LOOP
					--{
						X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_routing_results(i);
					--}
					END LOOP;
				--}
				END IF;

			    --}
			    ELSE
			    --{
				-- return. we don't have to do anything here.
				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Append flag is N return back ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
			    --}
			    END IF;
			--}
			ELSE
			--{ -- Initail routing guide condition is partial

				-- initail shipmethod config is partial. So we have to derive
				-- partial value and then do search based on that.
				-- make sure we still keep existing serivce in ranklist
				-- with ranksequence number 1.
				-- Do not go to routing guide but we have to check
				-- UI values and see if user changed shipmethod info

				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Initial configuration is Partial SM. ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				      LOG(l_module_name,
					' Derive SM information ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				DERIVE_INITIAL_SHIPMETHOD(
					p_rank_list_rec	=> l_rank_list_rec,
					x_carrier_id	=> l_carrier_id,
					x_service_level => l_service_level,
					x_mode_of_transport => l_mode_of_transport);

				IF l_debug_on
				THEN
				      LOG(l_module_name,
					' Pass in these parameters for search.  ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				      LOG(l_module_name,
					' Carrier _id ' || l_carrier_id,WSH_DEBUG_SV.C_PROC_LEVEL);
				      LOG(l_module_name,
					' Service level ' || l_service_level,WSH_DEBUG_SV.C_PROC_LEVEL);
				      LOG(l_module_name,
					' Mode ' || l_mode_of_transport,WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				  l_new_rank_list_rec.CARRIER_ID := l_carrier_id;
				  l_new_rank_list_rec.SERVICE_LEVEL := l_mode_of_transport;
				  l_new_rank_list_rec.MODE_OF_TRANSPORT := l_service_level;
				  l_new_rank_list_rec.SOURCE := 'RG';
				  l_new_rank_list_rec.INITSMCONFIG := l_rank_list_rec.INITSMCONFIG;
				  l_new_rank_list_rec.SORT := 'RL';

				  X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_new_rank_list_rec;

			--}
			END IF;
		--}
		ELSIF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_LCSS)
		THEN
		--{
			IF l_debug_on
			THEN
			      LOG(l_module_name,
				' Search using LCSS So just calling rate, sort search for open search',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			l_new_rank_list_rec.SOURCE := 'LCSS';
			l_new_rank_list_rec.INITSMCONFIG := l_rank_list_rec.INITSMCONFIG;
			l_new_rank_list_rec.SORT := 'UI';

			X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
					l_new_rank_list_rec;

		--}
		ELSIF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_TP)
		THEN
		--{

			IF l_debug_on
			THEN
			      LOG(l_module_name,
				' We have a entry from TP So call Routing Guide to get Routing guide results',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			      LOG(l_module_name,
				' We Do not have Rule id so we have to call main Routing guide API ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			-- Routing guide may enter these values into Rank list table directly
			-- that i still need to resolve

			ROUTING_GUIDE_MAIN(x_routing_results => l_routing_results,
					x_return_status => l_return_status);

			IF (l_routing_results.COUNT > 0)
			THEN
			--{

				FOR i IN l_routing_results.FIRST..l_routing_results.LAST
				LOOP
				--{
					l_routing_results(i).SOURCE := 'RG';
					l_routing_results(i).SORT := 'RL';

					X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_routing_results(i);

				--}
				END LOOP;
			--}
			END IF;

		--}
		END IF;

	--}
	END IF;

	X_SAVE_RANK_LIST := FND_API.G_TRUE;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO CREATE_SEARCH_CRITERIA_WF_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO CREATE_SEARCH_CRITERIA_WF_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	ROLLBACK TO CREATE_SEARCH_CRITERIA_WF_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.CREATE_SEARCH_CRITERIA_WF');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}

END CREATE_SEARCH_CRITERIA_WF;

--}

PROCEDURE CREATE_SEARCH_CRITERIA_UI(
	P_API_VERSION_NUMBER		IN		NUMBER,
	P_INIT_MSG_LIST			IN		VARCHAR2,
	P_COMMIT			IN		VARCHAR2,
	P_CALLER			IN		VARCHAR2,
	P_FTE_SS_ATTR_REC		IN		FTE_SS_ATTR_REC,
	X_LIST_CREATE_TYPE		OUT NOCOPY	VARCHAR2,
	X_SS_RATE_SORT_TAB		OUT NOCOPY	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	X_SAVE_RANK_LIST		OUT NOCOPY	VARCHAR2,
	X_RANK_EXIST_TAB		OUT NOCOPY	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	NUMBER,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2)
IS
--{


--{ Local variables

l_api_name              CONSTANT VARCHAR2(30)   := 'CREATE_SEARCH_CRITERIA_UI';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

-- values existing in rank list table
l_rank_list_tbl			FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_rank_list_rec			FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;


-- routing guide result table
l_routing_results		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_new_rank_list_rec		FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;
l_temp_rank_tbl			FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_tbl_count		    NUMBER;
l_initsmconfig		    VARCHAR2(3);
l_uismconfig		    VARCHAR2(3);

l_carrier_id		    NUMBER;
l_service_level		    VARCHAR2(30);
l_mode_of_transport	    VARCHAR2(30);

l_sm_modified	    VARCHAR2(1);

l_uiShipmethod VARCHAR2(1000);
l_rankShipmethod VARCHAR2(1000);


--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}

--}

BEGIN


	SAVEPOINT   CREATE_SEARCH_CRITERIA_UI_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	-- Get the rank list
	FTE_CARRIER_RANK_LIST_PVT.GET_RANK_LIST(
		p_init_msg_list	        => 1.0,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		x_ranklist		=> l_rank_list_tbl,
		p_trip_id		=> P_FTE_SS_ATTR_REC.TRIP_ID);

	l_tbl_count := l_rank_list_tbl.COUNT;

	IF l_debug_on
	THEN
		LOG(l_module_name,' Carrier Rank list count ' ||
				l_tbl_count,WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' Append list flag = ' ||
				P_FTE_SS_ATTR_REC.APPEND_LIST_FLAG,
				WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' Rule Id = ' ||
				P_FTE_SS_ATTR_REC.RULE_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' Existing Rank Id = ' ||
				P_FTE_SS_ATTR_REC.RANK_ID,WSH_DEBUG_SV.C_PROC_LEVEL);

		LOG(l_module_name,' P_FTE_SS_ATTR_REC.CARRIER_ID ' || P_FTE_SS_ATTR_REC.CARRIER_ID ,
			WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' P_FTE_SS_ATTR_REC.SERVICE_LEVEL ' || P_FTE_SS_ATTR_REC.SERVICE_LEVEL,
			WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT ' || P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT,
			WSH_DEBUG_SV.C_PROC_LEVEL);


	END IF;

	IF (l_tbl_count = 0)
	THEN
	--{
		IF l_debug_on
		THEN
		      LOG(l_module_name,' This is possible when there is nothing in rank list ' ||
		      			' and user does search services from UI ' ||
		      			' In this case just add user pref to search criteira ', WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		l_new_rank_list_rec.CARRIER_ID := P_FTE_SS_ATTR_REC.CARRIER_ID;
		l_new_rank_list_rec.SERVICE_LEVEL := P_FTE_SS_ATTR_REC.SERVICE_LEVEL;
		l_new_rank_list_rec.MODE_OF_TRANSPORT := P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT;
		l_new_rank_list_rec.SOURCE := FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_UI;
		l_new_rank_list_rec.SORT := 'UI';

		X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) := l_new_rank_list_rec;

		X_LIST_CREATE_TYPE := 'USER';
		X_SAVE_RANK_LIST := FND_API.G_FALSE;

		RETURN;

	--}
	ELSIF (l_tbl_count = 1)
	THEN
	--{
		l_rank_list_rec := l_rank_list_tbl(1);

		IF l_debug_on
		THEN
		      LOG(l_module_name,' Found entry. Source = ' || l_rank_list_rec.source,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      LOG(l_module_name,' InitSMConfig = ' ||l_rank_list_rec.INITSMCONFIG,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      LOG(l_module_name,' Lane Id = ' || l_rank_list_rec.LANE_ID,
					WSH_DEBUG_SV.C_PROC_LEVEL);

			LOG(l_module_name,' l_rank_list_rec.CARRIER_ID ' || l_rank_list_rec.CARRIER_ID ,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' l_rank_list_rec.SERVICE_LEVEL ' || l_rank_list_rec.SERVICE_LEVEL,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' l_rank_list_rec.MODE_OF_TRANSPORT ' || l_rank_list_rec.MODE_OF_TRANSPORT,
				WSH_DEBUG_SV.C_PROC_LEVEL);

		END IF;


		IF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_RG)
		THEN
		--{

			-- there is a service on the rank entry but it is possible to have
			-- initial shipmethod as partial. So we have to check initsmconfig

			IF (l_rank_list_rec.INITSMCONFIG = 'CSM'
				AND l_rank_list_rec.LANE_ID IS NOT NULL)
			THEN
			--{
			    IF l_debug_on
			    THEN
					LOG(l_module_name,
					' Initial Shipmethod is full ',WSH_DEBUG_SV.C_PROC_LEVEL);
			    END IF;

			    IF (l_rank_list_rec.LANE_ID IS NOT NULL)
			    THEN
				-- First copy the existing service to out tab so that it can be send back
				X_RANK_EXIST_TAB(1) := 	l_rank_list_rec;
			    END IF;

			    -- 1 Full SM / 1 Full SM with Service Case
			    -- Check append list flag
			    IF (P_FTE_SS_ATTR_REC.APPEND_LIST_FLAG = 'Y')
			    THEN
			    --{
				IF l_debug_on
				THEN
					LOG(l_module_name,
					' Calling Routing Guide Rule _id ' ||
							P_FTE_SS_ATTR_REC.RULE_ID,
								WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				GET_RANKED_RESULTS(p_rule_id => P_FTE_SS_ATTR_REC.RULE_ID,
						    x_routing_results => l_routing_results,
						    x_return_status => l_return_status);


				IF (l_return_status = 'E')
				THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_status = 'U')
				THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;



				IF l_debug_on
				THEN
				      LOG(l_module_name,' Build X_SS_RATE_SORT_TAB for search ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				IF (l_routing_results.COUNT > 0)
				THEN
				--{

					FOR i IN l_routing_results.FIRST..l_routing_results.LAST
					LOOP
					--{
						l_routing_results(i).SORT := 'RL';
						X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_routing_results(i);
					--}
					END LOOP;
				--}
				END IF;

				X_SAVE_RANK_LIST := FND_API.G_TRUE;

			    --}
			    ELSE
			    --{
				IF l_debug_on
				THEN
				      LOG(l_module_name, ' Append flag is N Do not call RG ', WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;


				IF (l_rank_list_rec.LANE_ID IS NOT NULL)
				THEN
				-- First copy the existing service to out tab so that it can be send back
				X_RANK_EXIST_TAB(1) := 	l_rank_list_rec;
				END IF;

				-- add this entry to search criteria. we have to search again
				-- to get rates and price request id
				l_rank_list_rec.SORT := 'RL';
				X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
					l_rank_list_rec;

				X_SAVE_RANK_LIST := FND_API.G_FALSE;
			    --}
			    END IF;

			--}
			ELSE
			--{

			    IF l_debug_on
			    THEN
					LOG(l_module_name,
					' Initial Shipmethod is Partial or only 1 Full shipmethod ',WSH_DEBUG_SV.C_PROC_LEVEL);
					LOG(l_module_name,
					' l_rank_list_rec.INITSMCONFIG ' || l_rank_list_rec.INITSMCONFIG,WSH_DEBUG_SV.C_PROC_LEVEL);

			    END IF;


			    IF (P_FTE_SS_ATTR_REC.APPEND_LIST_FLAG = 'Y')
			    THEN
				    X_SAVE_RANK_LIST := FND_API.G_TRUE;
				    l_rank_list_rec.SORT := 'RL';
				    l_rank_list_rec.RANK_ID := null;
				    X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) := l_rank_list_rec;
			    ELSE
				    X_SAVE_RANK_LIST := FND_API.G_FALSE;

			    END IF;


			    -- blow out the entry from rank list table. This is save because
			    -- if user cancels the transaction, we do not loose routing guide info.
			    -- but user clicks save that means he picked up some service so we do not
			    -- need this partial shipmethod info anyway. We have INITSMCONFIG to find out
			    -- what was the initial config anyway

			    FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION(
				p_api_version_number	=> 1.0,
				p_init_msg_list	        => FND_API.G_FALSE,
				x_return_status		=> l_return_status,
				x_msg_count		=> l_msg_count,
				x_msg_data		=> l_msg_data,
				p_action_code		=> FTE_CARRIER_RANK_LIST_PVT.S_DELETE,
				p_ranklist		=> l_temp_rank_tbl,
				p_trip_id		=> P_FTE_SS_ATTR_REC.trip_id,
				p_rank_id		=> null);

			    wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);

			    -- and update trip rank id to null. User is going to pick on again.
			    -- calling shipping API


				FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

				-- Update trip information
				p_trip_info.RANK_ID 		:= NULL;
				p_trip_info.TRIP_ID 		:= P_FTE_SS_ATTR_REC.trip_id;

				p_trip_info_tab(1)		:=p_trip_info;
				p_trip_in_rec.caller		:='FTE_LOAD_TENDER';
				p_trip_in_rec.phase		:=NULL;
				p_trip_in_rec.action_code	:='UPDATE';

				IF l_debug_on
				THEN
				      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ' ||
				      			' Updating rank id to null in UIWrapper ' ,
							  WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;


				WSH_INTERFACE_GRP.Create_Update_Trip
				(
				    p_api_version_number	=>p_api_version_number,
				    p_init_msg_list		=>FND_API.G_FALSE,
				    p_commit			=>FND_API.G_FALSE,
				    x_return_status		=>l_return_status,
				    x_msg_count			=>l_msg_count,
				    x_msg_data			=>l_msg_data,
				    p_trip_info_tab		=>p_trip_info_tab,
				    p_in_rec			=>p_trip_in_rec,
				    x_out_tab			=>x_out_tab
				);

				IF l_debug_on
				THEN
				      WSH_DEBUG_SV.logmsg(l_module_name,' REturn value from Create update trip ' ||
								l_return_status,
							  WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				wsh_util_core.api_post_call(
				      p_return_status    =>l_return_status,
				      x_num_warnings     =>l_number_of_warnings,
				      x_num_errors       =>l_number_of_errors,
				      p_msg_data	 =>l_msg_data);


				IF l_number_of_errors > 0
				THEN
				    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				    RAISE FND_API.G_EXC_ERROR;
				ELSIF l_number_of_warnings > 0
				THEN
				    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				ELSE
				    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
				END IF;



			 --}
			 END IF;
		--}
		ELSIF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_TP)
		THEN
		--{

			-- Call routing guide if Append flag is set to Y.
			    IF l_debug_on
			    THEN
					LOG(l_module_name,
					' TP Initial Shipmethod is full ',WSH_DEBUG_SV.C_PROC_LEVEL);
			    END IF;

			    X_RANK_EXIST_TAB(1) := 	l_rank_list_rec;

			    -- 1 Full SM / 1 Full SM with Service Case
			    -- Check append list flag
			    IF (P_FTE_SS_ATTR_REC.APPEND_LIST_FLAG = 'Y')
			    THEN
			    --{
				IF l_debug_on
				THEN
					LOG(l_module_name,
					' Calling Routing Guide Rule _id ' ||
							P_FTE_SS_ATTR_REC.RULE_ID,
								WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				GET_RANKED_RESULTS(p_rule_id => P_FTE_SS_ATTR_REC.RULE_ID,
						    x_routing_results => l_routing_results,
						    x_return_status => l_return_status);


				IF (l_return_status = 'E')
				THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF (l_return_status = 'U')
				THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

				IF l_debug_on
				THEN
				      LOG(l_module_name,' Build X_SS_RATE_SORT_TAB for search ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				IF (l_routing_results.COUNT > 0)
				THEN
				--{

					FOR i IN l_routing_results.FIRST..l_routing_results.LAST
					LOOP
					--{
						l_routing_results(i).SORT := 'RL';
						X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_routing_results(i);
					--}
					END LOOP;
				--}
				END IF;

				X_SAVE_RANK_LIST := FND_API.G_TRUE;

			    --}
			    ELSE
			    --{
				IF l_debug_on
				THEN
				      LOG(l_module_name, ' Append flag is N Do not call RG ', WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;


				X_SAVE_RANK_LIST := FND_API.G_FALSE;
			    --}
			    END IF;
		--}
		ELSIF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_UI)
		THEN
		--{

			    IF l_debug_on
			    THEN
					LOG(l_module_name,
					' Rank list created manually add 1 entry to existing services list ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
			    END IF;

			    IF (l_rank_list_rec.LANE_ID IS NOT NULL)
			    THEN
				-- First copy the existing service to out tab so that it can be send back
				X_RANK_EXIST_TAB(1) := 	l_rank_list_rec;
			    END IF;

			    -- add this entry to search criteria. we have to search again
			    -- to get rates and price request id
				l_rank_list_rec.SORT := 'RL';
				X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
					l_rank_list_rec;


		--}
		ELSIF (l_rank_list_rec.source = FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_LCSS)
		THEN
		--{
			IF l_debug_on
			THEN
			      LOG(l_module_name,
				' Search using LCSS So just calling rate, sort search for open search',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			IF (l_rank_list_rec.LANE_ID IS NOT NULL)
			THEN
			-- First copy the existing service to out tab so that it can be send back
				X_RANK_EXIST_TAB(1) := 	l_rank_list_rec;
			END IF;


			l_new_rank_list_rec.SOURCE := 'LCSS';
			l_new_rank_list_rec.INITSMCONFIG := l_rank_list_rec.INITSMCONFIG;
			l_new_rank_list_rec.SORT := 'UI';

			X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
					l_new_rank_list_rec;

			X_SAVE_RANK_LIST := FND_API.G_TRUE;
			X_LIST_CREATE_TYPE := 'SYSTEM';

		END IF;


		-- Check if UI level shipmethod is different than the
		-- one in rank list. If different then we have to search based on that
		IF l_debug_on
		THEN
			LOG(l_module_name,' Checking If UI level is different than the rank list entry ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' l_rank_list_rec.CARRIER_ID ' || l_rank_list_rec.CARRIER_ID ,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' l_rank_list_rec.SERVICE_LEVEL ' || l_rank_list_rec.SERVICE_LEVEL,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' l_rank_list_rec.MODE_OF_TRANSPORT ' || l_rank_list_rec.MODE_OF_TRANSPORT,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' P_FTE_SS_ATTR_REC.CARRIER_ID ' || P_FTE_SS_ATTR_REC.CARRIER_ID ,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' P_FTE_SS_ATTR_REC.SERVICE_LEVEL ' || P_FTE_SS_ATTR_REC.SERVICE_LEVEL,
				WSH_DEBUG_SV.C_PROC_LEVEL);
			LOG(l_module_name,' P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT ' || P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT,
				WSH_DEBUG_SV.C_PROC_LEVEL);

		END IF;


		IF ((P_FTE_SS_ATTR_REC.CARRIER_ID = l_rank_list_rec.CARRIER_ID)
		AND (P_FTE_SS_ATTR_REC.SERVICE_LEVEL = l_rank_list_rec.SERVICE_LEVEL)
		AND (P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT = l_rank_list_rec.MODE_OF_TRANSPORT))
		THEN
		--{


			IF l_debug_on
			THEN
				LOG(l_module_name,' Not Different ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;
		--}
		ELSE
		--{

			IF l_debug_on
			THEN
				LOG(l_module_name,' Different ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			l_new_rank_list_rec.CARRIER_ID := P_FTE_SS_ATTR_REC.CARRIER_ID;
			l_new_rank_list_rec.SERVICE_LEVEL := P_FTE_SS_ATTR_REC.SERVICE_LEVEL;
			l_new_rank_list_rec.MODE_OF_TRANSPORT := P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT;
			l_new_rank_list_rec.SOURCE := FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_UI;
			l_new_rank_list_rec.SORT := 'UI';

			X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) := l_new_rank_list_rec;

		--}
		END IF;
	--}
	ELSIF (l_tbl_count > 1)
	THEN
	--{

		l_sm_modified := 'Y';

		FOR i IN l_rank_list_tbl.FIRST..l_rank_list_tbl.LAST
		LOOP
		--{

			-- Add to rank exist only if it has a lane

			IF (l_rank_list_tbl(i).LANE_ID IS NOT NULL)
			THEN

				X_RANK_EXIST_TAB(X_RANK_EXIST_TAB.COUNT) := 	l_rank_list_tbl(i);

				-- add this to search parameters.
				l_rank_list_tbl(i).SORT := 'RL';
				X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) := l_rank_list_tbl(i);
				X_LIST_CREATE_TYPE := 'SYSTEM';
			ELSE
				-- add it to search parameter. we have to search based on this
				-- SM

				IF l_debug_on
				THEN
				      WSH_DEBUG_SV.logmsg(l_module_name,' X_LIST_CREATE_TYPE ' ||
							X_LIST_CREATE_TYPE,WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				IF (X_LIST_CREATE_TYPE = 'SYSTEM')
				THEN
					IF l_debug_on
					THEN
					      WSH_DEBUG_SV.logmsg(l_module_name,' X_LIST_CREATE_TYPE ' ||
							'SYSTEM' ,WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;
				ELSE
					X_LIST_CREATE_TYPE := 'USER';
				END IF;

				l_rank_list_tbl(i).SORT := 'RL';
			        X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) := l_rank_list_tbl(i);

			        -- delete this from rank list table.
			        DELETE FTE_CARRIER_RANK_LIST
			        WHERE RANK_ID = l_rank_list_tbl(i).RANK_ID;

			        IF (P_FTE_SS_ATTR_REC.RANK_ID = l_rank_list_tbl(i).RANK_ID)
			        THEN

					FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

					-- Update trip information
					p_trip_info.RANK_ID 		:= NULL;
					p_trip_info.TRIP_ID 		:= P_FTE_SS_ATTR_REC.trip_id;

					p_trip_info_tab(1)		:=p_trip_info;
					p_trip_in_rec.caller		:='FTE_LOAD_TENDER';
					p_trip_in_rec.phase		:=NULL;
					p_trip_in_rec.action_code	:='UPDATE';

					IF l_debug_on
					THEN
					      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ' ||
					      			' Setting rank id to null in UIWrapper ',
								  WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;


					WSH_INTERFACE_GRP.Create_Update_Trip
					(
					    p_api_version_number	=>p_api_version_number,
					    p_init_msg_list		=>FND_API.G_FALSE,
					    p_commit			=>FND_API.G_FALSE,
					    x_return_status		=>l_return_status,
					    x_msg_count			=>l_msg_count,
					    x_msg_data			=>l_msg_data,
					    p_trip_info_tab		=>p_trip_info_tab,
					    p_in_rec			=>p_trip_in_rec,
					    x_out_tab			=>x_out_tab
					);

					IF l_debug_on
					THEN
					      WSH_DEBUG_SV.logmsg(l_module_name,' REturn value from Create update trip ' ||
									l_return_status,
								  WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;

					wsh_util_core.api_post_call(
					      p_return_status    =>l_return_status,
					      x_num_warnings     =>l_number_of_warnings,
					      x_num_errors       =>l_number_of_errors,
					      p_msg_data	 =>l_msg_data);

					IF l_number_of_errors > 0
					THEN
					    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
					    RAISE FND_API.G_EXC_ERROR;
					ELSIF l_number_of_warnings > 0
					THEN
					    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
					ELSE
					    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
					END IF;


			        END IF;

			END IF;



			-- Check if shipmethod on the UI is different from
			-- rank list existing shipmethods
			-- If l_is_sm_modified is set to Y then we have UI sm modified
			-- so we do not have to check anymore

			IF (l_sm_modified = 'Y')
			THEN


				IF ((P_FTE_SS_ATTR_REC.CARRIER_ID = l_rank_list_tbl(i).CARRIER_ID)
				AND (P_FTE_SS_ATTR_REC.SERVICE_LEVEL = l_rank_list_tbl(i).SERVICE_LEVEL)
				AND (P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT = l_rank_list_tbl(i).MODE_OF_TRANSPORT))
				THEN
				--{
					IF l_debug_on
					THEN
						LOG(l_module_name,' Shipmethod did not modify ',WSH_DEBUG_SV.C_PROC_LEVEL);
					END IF;

					l_sm_modified := 'N';
				END IF;
			END IF;
		--}
		END LOOP;

		IF (l_sm_modified = 'Y')
		THEN

			l_new_rank_list_rec.CARRIER_ID := P_FTE_SS_ATTR_REC.CARRIER_ID;
			l_new_rank_list_rec.SERVICE_LEVEL := P_FTE_SS_ATTR_REC.SERVICE_LEVEL;
			l_new_rank_list_rec.MODE_OF_TRANSPORT := P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT;

			l_new_rank_list_rec.SOURCE := FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_UI;

			IF (P_FTE_SS_ATTR_REC.CARRIER_ID IS NULL
			    AND P_FTE_SS_ATTR_REC.SERVICE_LEVEL IS NULL
			    AND P_FTE_SS_ATTR_REC.MODE_OF_TRANSPORT IS NULL)
			THEN
				l_new_rank_list_rec.SOURCE := FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_LCSS;
			END IF;

			l_new_rank_list_rec.SORT := 'UI';

			X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
								l_new_rank_list_rec;

		END IF;

		X_SAVE_RANK_LIST := FND_API.G_TRUE;


	--}
	END IF;

	IF l_debug_on
	THEN
	      LOG(l_module_name,
		' save rank list Value ' || X_SAVE_RANK_LIST,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO CREATE_SEARCH_CRITERIA_UI_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO CREATE_SEARCH_CRITERIA_UI_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	ROLLBACK TO CREATE_SEARCH_CRITERIA_UI_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.CREATE_SEARCH_CRITERIA_UI');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}

END CREATE_SEARCH_CRITERIA_UI;

--}



PROCEDURE SEARCH_SERVICES(
	P_INIT_MSG_LIST			IN	VARCHAR2,
	P_API_VERSION_NUMBER		IN	NUMBER,
	P_COMMIT			IN	VARCHAR2,
	P_CALLER			IN	VARCHAR2,
	P_FTE_SS_ATTR_REC		IN	FTE_SS_ATTR_REC,
	X_RATING_REQUEST_ID		OUT NOCOPY	NUMBER,
	X_LIST_CREATE_TYPE		OUT NOCOPY	VARCHAR2,
	X_SS_RATE_SORT_TAB		OUT NOCOPY	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	NUMBER,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2)
IS
--{


--{ Local variables


l_api_name              CONSTANT VARCHAR2(30)   := 'SEARCH_SERVICES';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_list_create_type	   VARCHAR2(32767);

l_search_criteria_tbl	   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_search_results_tbl	   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_existing_service_tbl	   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_existing_sm_tbl	   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_manual_services_tbl	   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_rank_list_in_param_tbl   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_save_rank_list	   VARCHAR2(1); -- Search Services

l_rank_list_action	   VARCHAR2(30);

l_rating_request_id	   NUMBER;

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


--}

BEGIN


	SAVEPOINT   SEARCH_SERVICES_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	IF l_debug_on
	THEN
	      LOG(l_module_name,' P_caller ' ||
	      			p_caller,WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Append list flag ' ||
	      			P_FTE_SS_ATTR_REC.append_list_flag,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF (p_caller = S_CALLER_WF)
	THEN
	--{

		-- Use NVL
		IF (P_FTE_SS_ATTR_REC.append_list_flag = 'N' OR
		    P_FTE_SS_ATTR_REC.append_list_flag IS NULL)
		THEN
		--{
			IF l_debug_on
			THEN
			      LOG(l_module_name,' Return back because we cannot expand ' ||
						p_caller,WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			return;
		--}
		END IF;


		IF l_debug_on
		THEN
		      LOG(l_module_name,' Call FTE_SS_INTERFACE.CREATE_SEARCH_CRITERIA_WF ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		CREATE_SEARCH_CRITERIA_WF(
			P_API_VERSION_NUMBER		=> 1.0,
			P_INIT_MSG_LIST			=> FND_API.G_FALSE,
			P_COMMIT			=> p_commit,
			P_CALLER			=> p_caller,
			P_FTE_SS_ATTR_REC		=> p_fte_ss_attr_rec,
			X_SS_RATE_SORT_TAB		=> l_search_criteria_tbl,
			X_SAVE_RANK_LIST		=> l_save_rank_list,
			X_RANK_EXIST_TAB		=> l_existing_service_tbl,
			X_RETURN_STATUS			=> l_return_status,
			X_MSG_COUNT			=> l_msg_count,
			X_MSG_DATA			=> l_msg_data);

		IF l_debug_on
		THEN
		      LOG(l_module_name,' Result FTE_SS_INTERFACE.CREATE_SEARCH_CRITERIA_WF ' ||
						l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

		IF l_debug_on
		THEN
		      LOG(l_module_name,' copy existing service in the rank list to out tab X_SS_RATE_SORT TAB ' ||
						l_existing_service_tbl.COUNT,
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
	--}
	ELSIF (p_caller = S_CALLER_UI) THEN
	--{
		IF l_debug_on
		THEN
		      LOG(l_module_name,' Call FTE_SS_INTERFACE.CREATE_SEARCH_CRITERIA_UI ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		CREATE_SEARCH_CRITERIA_UI(
			P_API_VERSION_NUMBER		=> 1.0,
			P_INIT_MSG_LIST			=> FND_API.G_FALSE,
			P_COMMIT			=> p_commit,
			P_CALLER			=> p_caller,
			P_FTE_SS_ATTR_REC		=> p_fte_ss_attr_rec,
			X_LIST_CREATE_TYPE		=> x_list_create_type,
			X_SS_RATE_SORT_TAB		=> l_search_criteria_tbl,
			X_SAVE_RANK_LIST		=> l_save_rank_list,
			X_RANK_EXIST_TAB		=> l_existing_service_tbl,
			X_RETURN_STATUS			=> l_return_status,
			X_MSG_COUNT			=> l_msg_count,
			X_MSG_DATA			=> l_msg_data);

		IF l_debug_on
		THEN
		      LOG(l_module_name,' Result FTE_SS_INTERFACE.CREATE_SEARCH_CRITERIA_UI ' ||
						l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
		      LOG(l_module_name,' List Create Type ' || x_list_create_type,
						WSH_DEBUG_SV.C_PROC_LEVEL);

		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);

	--}
	END IF;


	IF l_debug_on
	THEN
		LOG(l_module_name,' Printing the SEARCH CRITERIA ', WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' ********************************************** ', WSH_DEBUG_SV.C_PROC_LEVEL);

		IF (l_search_criteria_tbl.COUNT > 0)
		THEN
		--{

			FOR i IN l_search_criteria_tbl.FIRST..l_search_criteria_tbl.LAST
			LOOP
			--{

				LOG(l_module_name,' 		&&&&&&&&&&&&&&&&&&&&&&&& ', WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' l_search_criteria_tbl.RANK_ID		 ' || l_search_criteria_tbl(i).RANK_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				LOG(l_module_name,' l_search_criteria_tbl.RANK_SEQUENCE		 ' || l_search_criteria_tbl(i).RANK_SEQUENCE,WSH_DEBUG_SV.C_PROC_LEVEL);
				LOG(l_module_name,' l_search_criteria_tbl.CARRIER_ID		 ' || l_search_criteria_tbl(i).CARRIER_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' l_search_criteria_tbl.SERVICE_LEVEL		 ' || l_search_criteria_tbl(i).SERVICE_LEVEL,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' l_search_criteria_tbl.MODE_OF_TRANSPORT	 ' || l_search_criteria_tbl(i).MODE_OF_TRANSPORT,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' l_search_criteria_tbl.SOURCE	 	 ' || l_search_criteria_tbl(i).SOURCE,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' l_search_criteria_tbl.SORT	 	 	 ' || l_search_criteria_tbl(i).SORT,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' l_search_criteria_tbl.INITSMCONFIG	 	 	 ' || l_search_criteria_tbl(i).INITSMCONFIG,WSH_DEBUG_SV.C_PROC_LEVEL);
				LOG(l_module_name,' 		&&&&&&&&&&&&&&&&&&&&&&&& ', WSH_DEBUG_SV.C_PROC_LEVEL);

			--}
			END LOOP;
		--}
		END IF;
		LOG(l_module_name,' ********************************************** ', WSH_DEBUG_SV.C_PROC_LEVEL);
		LOG(l_module_name,' End Printing the search criteria ', WSH_DEBUG_SV.C_PROC_LEVEL);

	END IF;




	IF (l_search_criteria_tbl.COUNT > 0)
	THEN
	--{

		IF (G_SEQ_DEBUG = 'ON')
		THEN
		--{
			IF l_debug_on
			THEN
			      LOG(l_module_name,' Calling RATE_SORT_WRAPPER ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			RATE_SORT_WRAPPER(p_ss_rate_sort_tbl => l_search_criteria_tbl,
			    x_ss_rate_sort_tbl  => l_search_results_tbl);
			x_rating_request_id := 121212;
		--}
		ELSE
		--{

			IF l_debug_on
			THEN
			      LOG(l_module_name,' Calling FTE_TRIP_RATING_GRP.Search_Rate_Sort ',
							WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			FTE_TRIP_RATING_GRP.Search_Rate_Sort(
				p_api_version   	   => 1.0,
				p_init_msg_list            => FND_API.G_FALSE,
				p_ss_rate_sort_tab         => l_search_criteria_tbl,
				p_ss_rate_sort_atr_rec 	   => P_FTE_SS_ATTR_REC,
				x_ss_rate_sort_tab 	   => l_search_results_tbl,
				x_rating_request_id        => x_rating_request_id,
				x_return_status            => l_return_status,
				x_msg_count                => l_msg_count,
				x_msg_data                 => l_msg_data);
		--}
		END IF;
	--}
	END IF;

	IF l_debug_on
	THEN
	      LOG(l_module_name,' Return message after calling Search Rate sort ' ||
					l_return_status,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	IF l_debug_on
	THEN
	      LOG(l_module_name,' Existing Service count l_existing_service_tbl.COUNT ' ||
					l_existing_service_tbl.COUNT,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Search Service result count l_search_results_tbl.COUNT ' ||
					l_search_results_tbl.COUNT,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Rating request id ' || x_rating_request_id,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;



	IF (l_search_results_tbl.COUNT=0)
	THEN
	--{
		IF l_debug_on
		THEN
		      LOG(l_module_name,' search result count is 0 ' ||
						l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		-- we cannot do anything
	--}
	ELSIF (x_rating_request_id IS NOT NULL)
	THEN
	--{  We have to procced only if price request id is not null.

		-- Remove duplicated between existing and search resutls

		IF (l_existing_service_tbl.COUNT > 0)
		THEN
		--{

			IF l_debug_on
			THEN
			      LOG(l_module_name,' Eliminating Duplicates ',
							WSH_DEBUG_SV.C_PROC_LEVEL);

			END IF;

			-- remove the existing services from l_search_results tbl
			FOR i IN l_search_results_tbl.FIRST..l_search_results_tbl.LAST
			LOOP
			--{
				FOR j IN l_existing_service_tbl.FIRST..l_existing_service_tbl.LAST
				LOOP
				--{
					LOG(l_module_name,' Compare Lane Id. l_search_results_tbl ' ||
							l_search_results_tbl(i).LANE_ID || ' with l_existing_service_tbl ' ||
							l_existing_service_tbl(j).LANE_ID , WSH_DEBUG_SV.C_PROC_LEVEL);

					LOG(l_module_name,' Compare VEHICLE. l_search_results_tbl ' ||
							l_search_results_tbl(i).VEHICLE_ITEM_ID || ' with l_existing_service_tbl ' ||
							l_existing_service_tbl(j).VEHICLE_ITEM_ID, WSH_DEBUG_SV.C_PROC_LEVEL);


					IF (l_search_results_tbl(i).LANE_ID <> -99)
					THEN
					--{
						IF  (l_search_results_tbl(i).LANE_ID = l_existing_service_tbl(j).LANE_ID)
						THEN
						--{
							IF (((l_search_results_tbl(i).VEHICLE_ITEM_ID IS NULL)
							     AND (l_existing_service_tbl(j).VEHICLE_ITEM_ID IS NULL))
							OR  ((l_search_results_tbl(i).VEHICLE_ITEM_ID =
							     l_existing_service_tbl(j).VEHICLE_ITEM_ID )))
							THEN

								-- Check if vehicle is same. if yes
								IF l_debug_on
								THEN
								      LOG(l_module_name,
									' Remove this service. Do not send it to Rank list ' || l_search_results_tbl(i).LANE_ID, WSH_DEBUG_SV.C_PROC_LEVEL);

								END IF;

								l_search_results_tbl(i).LANE_ID := -99;
								l_search_results_tbl(i).VEHICLE_ITEM_ID := -99;

								IF l_debug_on
								THEN
								      LOG(l_module_name,
									' But copy the rate information from search restuls to the existins ' ||
									 ' because that is the latest rate ' , WSH_DEBUG_SV.C_PROC_LEVEL);
								END IF;

							l_existing_service_tbl(j).ESTIMATED_RATE :=
									l_search_results_tbl(i).ESTIMATED_RATE;
							l_existing_service_tbl(j).CURRENCY_CODE :=
									l_search_results_tbl(i).CURRENCY_CODE;
							l_existing_service_tbl(j).ESTIMATED_TRANSIT_TIME :=
									l_search_results_tbl(i).ESTIMATED_TRANSIT_TIME;
							l_existing_service_tbl(j).TRANSIT_TIME_UOM :=
									l_search_results_tbl(i).TRANSIT_TIME_UOM;

							END IF;

						--}
						END IF;
					--}
					END IF;
				--}
				END LOOP;
			--}
			END LOOP;

			-- Set action to APPEND since we are going to append to the list instead
			-- of creating scratch.

			l_rank_list_action := FTE_CARRIER_RANK_LIST_PVT.S_APPEND;
		--}
		ELSE
		--{
			-- no existing service
			-- so save everything to RANK LIST TABLE.

			IF l_debug_on
			THEN
			      LOG(l_module_name,' Save everything. Except Manual. ' ,
							WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			l_rank_list_action := FTE_CARRIER_RANK_LIST_PVT.S_CREATE;

		--}
		END IF;


		-- Add all existing services to out parameter.

		IF (l_existing_service_tbl.COUNT > 0)
		THEN
		--{
			FOR i IN l_existing_service_tbl.FIRST..l_existing_service_tbl.LAST
			LOOP
			--{
				X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) := l_existing_service_tbl(i);

				IF l_debug_on
				THEN
					LOG(l_module_name,' Printing existing service ', WSH_DEBUG_SV.C_PROC_LEVEL);
					LOG(l_module_name,' ********************************************** ', WSH_DEBUG_SV.C_PROC_LEVEL);


					Log(l_module_name,' l_existing_service_tbl.RANK_ID		 ' || l_existing_service_tbl(i).RANK_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.RANK_SEQUENCE	 ' || l_existing_service_tbl(i).RANK_SEQUENCE,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.CARRIER_ID		 ' || l_existing_service_tbl(i).CARRIER_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.SERVICE_LEVEL	 ' || l_existing_service_tbl(i).SERVICE_LEVEL,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.MODE_OF_TRANSPORT	 ' || l_existing_service_tbl(i).MODE_OF_TRANSPORT,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.LANE_ID	 	 ' || l_existing_service_tbl(i).LANE_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.SOURCE	 	 ' || l_existing_service_tbl(i).SOURCE,WSH_DEBUG_SV.C_PROC_LEVEL);
					Log(l_module_name,' l_existing_service_tbl.SORT	 	 	 ' || l_existing_service_tbl(i).SORT,WSH_DEBUG_SV.C_PROC_LEVEL);

					LOG(l_module_name,' ********************************************** ', WSH_DEBUG_SV.C_PROC_LEVEL);
					LOG(l_module_name,' End Printing existing service ', WSH_DEBUG_SV.C_PROC_LEVEL);

				END IF;

			--}
			END LOOP;
		--}
		END IF;




		-- Now create the l_rank_list_in_param_tbl. from l_search_results_tbl.
		-- Just make sure that we do not pass in any service with -99 because it is eliminated
		-- in previous step because it is a duplicate. And also check for Manual. We
		-- should not save them

		FOR j IN l_search_results_tbl.FIRST..l_search_results_tbl.LAST
		LOOP
		--{
			IF (l_search_results_tbl(j).LANE_ID <> -99)
			THEN
			--{
				l_search_results_tbl(j).IS_CURRENT := 'N';


				IF (l_search_results_tbl(j).SOURCE = 'MAN')
				THEN
				--{

					l_manual_services_tbl(l_manual_services_tbl.COUNT+1) :=
							l_search_results_tbl(j);
				--}
				ELSE
				--{
					l_rank_list_in_param_tbl(l_rank_list_in_param_tbl.COUNT+1)
						:= l_search_results_tbl(j);
				--}
				END IF;
			--}
			END IF;
		--}
		END LOOP;



		IF (l_save_rank_list = FND_API.G_TRUE AND
			l_rank_list_in_param_tbl.COUNT > 0)
		THEN
		--{

				-- Since we are saving something, we should
				-- we should set the X_LIST_CREATE_TYPE to SYSTEM.
				-- So that from UI it can be append instead of create new
				X_LIST_CREATE_TYPE := 'SYSTEM';

				-- If there are no existing services, then we just need to assign
				-- rank sequences to the search results (not the manual once).
				-- because these services will be saved to DB.
				IF (l_existing_service_tbl.COUNT = 0)
				THEN
				--{
					FOR j IN l_rank_list_in_param_tbl.FIRST..l_rank_list_in_param_tbl.LAST
					LOOP
					--{
						l_rank_list_in_param_tbl(j).RANK_SEQUENCE := j;
					--}
					END LOOP;
				--}
				END IF;

				-- Now call RANK_ACTION API to save information
				FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION(
					p_api_version_number	=> 1.0,
					p_init_msg_list	        => FND_API.G_FALSE,
					x_return_status		=> l_return_status,
					x_msg_count		=> l_msg_count,
					x_msg_data		=> l_msg_data,
					p_action_code		=> l_rank_list_action,
					p_ranklist		=> l_rank_list_in_param_tbl,
					p_trip_id		=> P_FTE_SS_ATTR_REC.trip_id,
					p_rank_id		=> null);

				wsh_util_core.api_post_call(
				      p_return_status    =>l_return_status,
				      x_num_warnings     =>l_number_of_warnings,
				      x_num_errors       =>l_number_of_errors,
				      p_msg_data	 =>l_msg_data);


				IF l_number_of_errors > 0
				THEN
				    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				    RAISE FND_API.G_EXC_ERROR;
				ELSIF l_number_of_warnings > 0
				THEN
				    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
				ELSE
				    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
				END IF;
		--}
		END IF;

		IF (l_rank_list_in_param_tbl.COUNT > 0)
		THEN
		--{

			-- If there are no existing services, then we just need to assign
			-- rank sequences to the search results (not the manual once).
			-- because these services will be saved to DB.
			IF (l_existing_service_tbl.COUNT = 0)
			THEN
			--{
				FOR j IN l_rank_list_in_param_tbl.FIRST..l_rank_list_in_param_tbl.LAST
				LOOP
				--{
					l_rank_list_in_param_tbl(j).RANK_SEQUENCE := j;
				--}
				END LOOP;
			--}
			END IF;

			IF (l_existing_service_tbl.COUNT =0)
			THEN
			--{

				IF l_debug_on
				THEN
				      LOG(l_module_name,' l_existing_service_tbl.count  = 0 ' ,
								WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;


				FOR i IN l_rank_list_in_param_tbl.FIRST..l_rank_list_in_param_tbl.LAST
				LOOP
				--{
					l_rank_list_in_param_tbl(i).RANK_SEQUENCE := i;
					X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_rank_list_in_param_tbl(i);

				--}
				END LOOP;
			--}
			ELSE
			--{
				IF l_debug_on
				THEN
				      LOG(l_module_name,' l_existing_service_tbl.count is not 0 ' ,
								WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				FOR i IN l_rank_list_in_param_tbl.FIRST..l_rank_list_in_param_tbl.LAST
				LOOP
				--{
					X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
							l_rank_list_in_param_tbl(i);

				--}
				END LOOP;
			--}
			END IF;
		--}
		END IF;

		-- Add manual services to the out record at the end.
		IF (l_manual_services_tbl.COUNT > 0)
		THEN
		--{
			FOR i IN l_manual_services_tbl.FIRST..l_manual_services_tbl.LAST
			LOOP
			--{
				X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT+1) :=
						l_manual_services_tbl(i);
			--}
			END LOOP;
		--}
		END IF;
	--}
	ELSE
	--{
		IF l_debug_on
		THEN
		      LOG(l_module_name,' Rating request id is null so do not do anything. ' ,
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

	--}
	END IF;

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;



	-- If trip is is null, in DWB case, we should not update the trip
	-- because there is no trip. UI call is going to set append flag to N
	-- later : HBHAGAVA
	IF (P_FTE_SS_ATTR_REC.TRIP_ID IS NOT NULL)
	THEN

		FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

		-- Update trip information
		p_trip_info.APPEND_FLAG 		:= 'N';
		p_trip_info.TRIP_ID 		:= P_FTE_SS_ATTR_REC.trip_id;

		p_trip_info_tab(1)		:=p_trip_info;
		p_trip_in_rec.caller		:='FTE_LOAD_TENDER';
		p_trip_in_rec.phase		:=NULL;
		p_trip_in_rec.action_code	:='UPDATE';

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ' ||
					' Updating append flag to N ',
					  WSH_DEBUG_SV.C_PROC_LEVEL);
		      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ' ||
					' Trip Id ' || p_trip_info.TRIP_ID,
					  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>p_api_version_number,
		    p_init_msg_list		=>FND_API.G_FALSE,
		    p_commit			=>FND_API.G_FALSE,
		    x_return_status		=>l_return_status,
		    x_msg_count			=>l_msg_count,
		    x_msg_data			=>l_msg_data,
		    p_trip_info_tab		=>p_trip_info_tab,
		    p_in_rec			=>p_trip_in_rec,
		    x_out_tab			=>x_out_tab
		);

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' REturn value from Create update trip ' ||
						l_return_status,
					  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);


		IF l_number_of_errors > 0
		THEN
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		    RAISE FND_API.G_EXC_ERROR;
		ELSIF l_number_of_warnings > 0
		THEN
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		ELSE
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
		END IF;
	END IF;

	IF l_debug_on
	THEN
		Log(l_module_name,' PRINTING ALL SERVICES ********** ',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	-- Printing all the services
	IF (X_SS_RATE_SORT_TAB.COUNT > 0)
	THEN


		FOR i IN X_SS_RATE_SORT_TAB.FIRST..X_SS_RATE_SORT_TAB.LAST
		LOOP
		--{
			IF l_debug_on
			THEN
				Log(l_module_name,' ******************** ',WSH_DEBUG_SV.C_PROC_LEVEL);

				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).RANK_ID 		 ' || X_SS_RATE_SORT_TAB(i).RANK_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).RANK_SEQUENCE		 ' || X_SS_RATE_SORT_TAB(i).RANK_SEQUENCE,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).CARRIER_ID		 ' || X_SS_RATE_SORT_TAB(i).CARRIER_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).SERVICE_LEVEL		 ' || X_SS_RATE_SORT_TAB(i).SERVICE_LEVEL,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).MODE_OF_TRANSPORT	 ' || X_SS_RATE_SORT_TAB(i).MODE_OF_TRANSPORT,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).LANE_ID		 ' || X_SS_RATE_SORT_TAB(i).LANE_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).SOURCE		 ' || X_SS_RATE_SORT_TAB(i).SOURCE,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).ESTIMATED_RATE	 ' || X_SS_RATE_SORT_TAB(i).ESTIMATED_RATE,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).CURRENCY_CODE		 ' || X_SS_RATE_SORT_TAB(i).CURRENCY_CODE,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).VEHICLE_ITEM_ID	 ' || X_SS_RATE_SORT_TAB(i).VEHICLE_ITEM_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).VEHICLE_ORG_ID	 ' || X_SS_RATE_SORT_TAB(i).VEHICLE_ORG_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).ESTIMATED_TRANSIT_TIME ' || X_SS_RATE_SORT_TAB(i).ESTIMATED_TRANSIT_TIME,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).TRANSIT_TIME_UOM	  ' || X_SS_RATE_SORT_TAB(i).TRANSIT_TIME_UOM,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).CONSIGNEE_CARRIER_AC_NO ' || X_SS_RATE_SORT_TAB(i).CONSIGNEE_CARRIER_AC_NO,WSH_DEBUG_SV.C_PROC_LEVEL);
				Log(l_module_name,' X_SS_RATE_SORT_TAB(i).FREIGHT_TERMS_CODE	  ' || X_SS_RATE_SORT_TAB(i).FREIGHT_TERMS_CODE,WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

		--}
		END LOOP;
	END IF;

	IF l_debug_on
	THEN
		Log(l_module_name,' END PRINTING ALL SERVICES ********** ',WSH_DEBUG_SV.C_PROC_LEVEL);
	        LOG(l_module_name,' X_LIST_CREATE_TYPE value ' || X_LIST_CREATE_TYPE,
					WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );

	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO SEARCH_SERVICES_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO SEARCH_SERVICES_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	ROLLBACK TO SEARCH_SERVICES_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.SEARCH_SERVICES');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}

END SEARCH_SERVICES;

--}
PROCEDURE SEARCH_SERVICES_UIWRAPPER(
	P_INIT_MSG_LIST			IN	VARCHAR2,
	P_API_VERSION_NUMBER		IN	NUMBER,
	P_COMMIT			IN	VARCHAR2,
	P_CALLER			IN	VARCHAR2,
	P_FTE_SS_ATTR_REC		IN	FTE_SS_ATTR_REC,
	X_RATING_REQUEST_ID		OUT NOCOPY	NUMBER,
	X_LIST_CREATE_TYPE		OUT NOCOPY	VARCHAR2,
	X_SS_RATE_SORT_TAB		OUT NOCOPY	FTE_SS_RATE_SORT_TAB_TYPE,
	X_RETURN_STATUS			OUT NOCOPY	VARCHAR2,
	X_MSG_COUNT			OUT NOCOPY	NUMBER,
	X_MSG_DATA			OUT NOCOPY	VARCHAR2)
IS


--{ Local variables


l_api_name              CONSTANT VARCHAR2(30)   := 'SEARCH_SERVICES_UIWRAPPER';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_list_create_type	   VARCHAR2(32767);

l_SS_RATE_SORT_TAB	   FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_ss_rate_sort_rec	FTE_SS_RATE_SORT_REC;

--}

BEGIN


	SAVEPOINT   SEARCH_SERVICES_UIWRAPPER_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	IF l_debug_on
	THEN
	      LOG(l_module_name,' P_caller ' ||
	      			p_caller,WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Append list flag ' ||
	      			P_FTE_SS_ATTR_REC.append_list_flag,WSH_DEBUG_SV.C_PROC_LEVEL);
	      LOG(l_module_name,' Calling FTE_SS_INTERFACE.SEARCH_SERVICES ' ||
	      			P_FTE_SS_ATTR_REC.append_list_flag,WSH_DEBUG_SV.C_PROC_LEVEL);

	END IF;


	FTE_SS_INTERFACE.SEARCH_SERVICES(
		P_INIT_MSG_LIST			=> P_INIT_MSG_LIST,
		P_API_VERSION_NUMBER		=> 1.0,
		P_COMMIT			=> P_COMMIT,
		P_CALLER			=> P_CALLER,
		P_FTE_SS_ATTR_REC		=> p_FTE_SS_ATTR_REC,
		X_RATING_REQUEST_ID		=> X_RATING_REQUEST_ID,
		X_LIST_CREATE_TYPE		=> X_LIST_CREATE_TYPE,
		X_SS_RATE_SORT_TAB		=> l_SS_RATE_SORT_TAB,
		x_return_status			=> l_return_status,
		x_msg_count			=> l_msg_count,
		x_msg_data			=> l_msg_data);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>l_msg_data);


	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	-- Update trip append flag to N

	-- looping through


	IF l_debug_on
	THEN

		LOG(l_module_name,' List Create Type ' || x_list_create_type,
						WSH_DEBUG_SV.C_PROC_LEVEL);

		Log(l_module_name,' Looping through all results to return back values to UI ',WSH_DEBUG_SV.C_PROC_LEVEL);

	END IF;

	-- Printing all the services
	IF (L_SS_RATE_SORT_TAB.COUNT > 0)
	THEN

		X_SS_RATE_SORT_TAB	:= FTE_SS_RATE_SORT_TAB_TYPE();

		FOR i IN l_SS_RATE_SORT_TAB.FIRST..l_SS_RATE_SORT_TAB.LAST
		LOOP
		--{

			l_ss_rate_sort_rec := FTE_SS_RATE_SORT_REC(
						l_SS_RATE_SORT_TAB(i).RANK_ID,
						l_SS_RATE_SORT_TAB(i).RANK_SEQUENCE,
						l_SS_RATE_SORT_TAB(i).LANE_ID,
						l_SS_RATE_SORT_TAB(i).SCHEDULE_ID,
						l_SS_RATE_SORT_TAB(i).CARRIER_ID,
						l_SS_RATE_SORT_TAB(i).MODE_OF_TRANSPORT,
						l_SS_RATE_SORT_TAB(i).SERVICE_LEVEL,
						l_SS_RATE_SORT_TAB(i).VEHICLE_ITEM_ID,
						l_SS_RATE_SORT_TAB(i).VEHICLE_ORG_ID,
						l_SS_RATE_SORT_TAB(i).SORT,
						l_SS_RATE_SORT_TAB(i).SOURCE,
						l_SS_RATE_SORT_TAB(i).ESTIMATED_RATE,
						l_SS_RATE_SORT_TAB(i).CURRENCY_CODE,
						l_SS_RATE_SORT_TAB(i).ESTIMATED_TRANSIT_TIME,
						l_SS_RATE_SORT_TAB(i).TRANSIT_TIME_UOM,
						l_SS_RATE_SORT_TAB(i).SCHEDULE_FROM,
						l_SS_RATE_SORT_TAB(i).SCHEDULE_TO,
						l_SS_RATE_SORT_TAB(i).IS_CURRENT,
						l_SS_RATE_SORT_TAB(i).VERSION,
						l_SS_RATE_SORT_TAB(i).SINGLE_CURR_RATE,
						l_SS_RATE_SORT_TAB(i).CONSIGNEE_CARRIER_AC_NO,
						l_SS_RATE_SORT_TAB(i).FREIGHT_TERMS_CODE);
			X_SS_RATE_SORT_TAB.EXTEND;
			X_SS_RATE_SORT_TAB(X_SS_RATE_SORT_TAB.COUNT) := l_ss_rate_sort_rec;

		--}
		END LOOP;
	END IF;

	IF l_debug_on
	THEN
		Log(l_module_name,' END PRINTING ALL SERVICES ********** ',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );

	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO SEARCH_SERVICES_UIWRAPPER_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO SEARCH_SERVICES_UIWRAPPER_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	ROLLBACK TO SEARCH_SERVICES_UIWRAPPER_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.SEARCH_SERVICES_UIWRAPPER');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}

END SEARCH_SERVICES_UIWRAPPER;




--{


PROCEDURE GET_RANKED_RESULTS_WRAPPER
  ( p_api_version_number     IN   		NUMBER,
    p_init_msg_list          IN   		VARCHAR2,
    x_return_status          OUT NOCOPY 	VARCHAR2,
    x_msg_count              OUT NOCOPY 	NUMBER,
    x_msg_data               OUT NOCOPY 	VARCHAR2,
    x_routing_guide	     OUT NOCOPY		FTE_SS_RATE_SORT_TAB_TYPE,
    p_routing_rule_id		     IN			NUMBER)

IS
--{


--{ Local variables


l_api_name              CONSTANT VARCHAR2(30)   := 'GET_RANKED_RESULTS_WRAPPER';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_routing_results 	 FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_mode				VARCHAR2(80);
l_service			VARCHAR2(80);
l_carrierName			VARCHAR2(360);

--}

BEGIN


	SAVEPOINT   GET_RANKED_RESULTS_WRAPPER_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	IF l_debug_on
	THEN
	      LOG(l_module_name,' Calling Routing guide with rule id ',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	x_routing_guide := FTE_SS_RATE_SORT_TAB_TYPE();

	/**
	FTE_ACS_TRIP_PKG.get_ranked_results(p_rule_id => p_routing_rule_id,
					x_routing_results => l_routing_results,
					x_return_status => l_return_status);
	*/
	IF l_debug_on
	THEN
	      LOG(l_module_name,' return status from GET_RANKED_RESULTS ' || l_return_status,
	      			WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors,
	      p_msg_data	 =>'');




	FOR i IN l_routing_results.FIRST..l_routing_results.LAST
	LOOP
		x_routing_guide.EXTEND;


		/**
		l_service := null;

		IF (l_routing_results(i).SERVICE_LEVEL IS NOT NULL)
		THEN
			l_service := WSH_UTIL_CORE.GET_LOOKUP_MEANING('WSH_SERVICE_LEVELS',
							l_routing_results(i).SERVICE_LEVEL);
		END IF;

		l_mode := null;
		IF (l_routing_results(i).MODE_OF_TRANSPORT IS NOT NULL)
		THEN
			l_mode := WSH_UTIL_CORE.GET_LOOKUP_MEANING('WSH_MODE_OF_TRANSPORT',
							l_routing_results(i).MODE_OF_TRANSPORT);
		END IF;

		l_carrierName := null;
		IF (l_routing_results(i).CARRIER_ID IS NOT NULL)
		THEN
			l_carrierName := FTE_MLS_UTIL.GET_CARRIER_NAME(
						l_routing_results(i).CARRIER_ID);
		END IF;
		*/

		x_routing_guide(x_routing_guide.COUNT) :=
			FTE_SS_RATE_SORT_REC(
				null,
				l_routing_results(i).RANK_SEQUENCE,
				null,
				NULL,
				l_routing_results(i).CARRIER_ID,
				l_routing_results(i).MODE_OF_TRANSPORT,
				l_routing_results(i).SERVICE_LEVEL,
				l_routing_results(i).VEHICLE_ITEM_ID,
				NULL,
				NULL,
				l_routing_results(i).SOURCE,
				null,
				null,
				null,
				null,
				NULL,--l_carrier_rank_list_rec.SCHEDULE_FROM		,
				NULL,--l_carrier_rank_list_rec.SCHEDULE_TO		,
				null,
				null,
				NULL,
				l_routing_results(i).CONSIGNEE_CARRIER_AC_NO ,
				l_routing_results(i).FREIGHT_TERMS_CODE);

	END LOOP;

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	-- Update trip append flag to N

	-- Standard call to get message count and if count is 1,get message info.
	--
	FND_MSG_PUB.Count_And_Get
	  (
	    p_count =>  x_msg_count,
	    p_data  =>  x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );

	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

--}
EXCEPTION
--{
WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO GET_RANKED_RESULTS_WRAPPER_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO GET_RANKED_RESULTS_WRAPPER_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;
WHEN OTHERS THEN
	ROLLBACK TO GET_RANKED_RESULTS_WRAPPER_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.GET_RANKED_RESULTS_WRAPPER');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


--}
--
END GET_RANKED_RESULTS_WRAPPER;

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

	/* R12 Hiding Project
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
	*/

	-- Step 4: Update Trip
	-- If delivery_id is null, this call is coming from TripWB. Update Trip with
	-- 	current service from FTE_SS_ATTR_REC and rank id.
	-- Else this call is coming from DWB or MI. Update Trip with Rank Id only.

	-- Step 4a: Set reprice flag to N

	IF l_trip_id IS NOT NULL THEN
		FTE_FREIGHT_PRICING.unmark_reprice_required(
			p_segment_id 		=> l_trip_id,
			x_return_status 	=> l_return_status);

	        IF l_debug_on THEN
        	    WSH_DEBUG_SV.logmsg(l_module_name, 'After unmark reprice status:'||l_return_status);
        	END IF;
	END IF;

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

	  WSH_UTIL_CORE.API_POST_CALL(
	      	p_return_status    =>l_return_status,
	      	x_num_warnings     =>l_number_of_warnings,
	      	x_num_errors       =>l_number_of_errors,
	     	p_msg_data	   =>l_msg_data);

/* Hiding Project - Do not Raise Service Events
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

	  WSH_UTIL_CORE.API_POST_CALL(
	      	p_return_status    =>l_return_status,
	      	x_num_warnings     =>l_number_of_warnings,
	      	x_num_errors       =>l_number_of_errors,
	     	p_msg_data	   =>l_msg_data);

*/
	END IF;

	  IF l_debug_on THEN
	        WSH_DEBUG_SV.logmsg(l_module_name, 'API:FTE_MLS_WRAPPER.UPDATE_SERVICE_ON_TRIP');
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_return_status:'||l_return_status);
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_warnings:'||l_number_of_warnings);
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_number_of_errors:'||l_number_of_errors);
	        WSH_DEBUG_SV.logmsg(l_module_name, 'l_msg_data:'||l_msg_data);
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

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_number_of_warnings > 0 THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	ELSE
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;


	FND_MSG_PUB.Count_And_Get
	(
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	);

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


END FTE_SS_INTERFACE;

/
