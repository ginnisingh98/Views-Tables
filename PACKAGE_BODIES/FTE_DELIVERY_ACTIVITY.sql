--------------------------------------------------------
--  DDL for Package Body FTE_DELIVERY_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_DELIVERY_ACTIVITY" AS
/* $Header: FTEDLACB.pls 120.1 2005/06/03 16:24:22 appldev  $ */

--===================
-- TYPES
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_DELIVERY_ACTIVITES';


--===================
-- PROCEDURES
--===================



PROCEDURE ADD_HISTORY(

		p_delivery_id		IN NUMBER,
		p_delivery_leg_id	IN NUMBER,
		p_trip_id		IN NUMBER,
		p_activity_date		IN DATE,
		p_activity_type		IN VARCHAR2,
		p_request_id		IN NUMBER,
		p_action_by		IN NUMBER,
		p_action_by_name	IN VARCHAR2,
		p_remarks		IN VARCHAR2,
		p_result_status		IN VARCHAR2,
		p_initial_status	IN VARCHAR2,
		p_carrier_id		IN NUMBER,
		p_mode_of_transport     IN VARCHAR2,
		p_service_level         IN VARCHAR2,
		x_return_status     	OUT NOCOPY VARCHAR2,
		x_error_msg         	OUT NOCOPY VARCHAR2,
		x_error_tkn         	OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1) := 'S';
l_error_msg VARCHAR2(1000) := null;
l_error_tkn VARCHAR2(1000) := null;

s_activity_id NUMBER;

BEGIN

    select wsh_delivery_leg_activities_s.nextval into s_activity_id from dual;

    insert into wsh_delivery_leg_activities
        (ACTIVITY_ID, DELIVERY_LEG_ID, ACTIVITY_DATE, ACTIVITY_TYPE, CREATION_DATE, CREATED_BY,
         LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
         ACTION_BY, ACTION_BY_NAME, REMARKS, RESULT_STATUS, INITIAL_STATUS, TRIP_ID,CARRIER_ID,MODE_OF_TRANSPORT,SERVICE_LEVEL) values
        (s_activity_id, p_delivery_leg_id, p_activity_date, p_activity_type, sysdate, -1,
         sysdate, -1, 1,
         p_action_by, p_action_by_name, p_remarks, p_result_status, p_initial_status, p_trip_id,p_carrier_id,p_mode_of_transport,p_service_level);


    x_return_status := l_return_status;
    x_error_msg := l_error_msg;
    x_error_tkn := l_error_tkn;



EXCEPTION

    WHEN OTHERS THEN
	x_return_Status := 'E';
	x_error_msg := SQLERRM;
	x_error_tkn := 'ADD_HISTORY';

END ADD_HISTORY;

PROCEDURE ADD_HISTORY(

		p_trip_id		IN NUMBER,
		p_activity_date		IN DATE,
		p_activity_type		IN VARCHAR2,
		p_request_id		IN NUMBER,
		p_action_by		IN NUMBER,
		p_action_by_name	IN VARCHAR2,
		p_remarks		IN VARCHAR2,
		p_result_status		IN VARCHAR2,
		p_initial_status	IN VARCHAR2,
		x_return_status     	OUT NOCOPY VARCHAR2,
		x_error_msg         	OUT NOCOPY VARCHAR2,
		x_error_tkn         	OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1) := 'S';
l_error_msg VARCHAR2(1000) := null;
l_error_tkn VARCHAR2(1000) := null;

s_activity_id NUMBER;

cursor c_dlegs(p_trip_id NUMBER) is
select wdl.delivery_id delivery_id, wdl.delivery_leg_id delivery_leg_id ,
wt.carrier_id carrier_id, wt.mode_of_transport mode_of_transport , wt.service_level service_level
from wsh_delivery_legs wdl, wsh_trip_stops wts,wsh_trips wt
where wdl.pick_up_stop_id = wts.stop_id
and wts.trip_id = p_trip_id
and wt.trip_id= p_trip_id;

BEGIN


    FOR c_rec IN c_dlegs(p_trip_id) LOOP

	ADD_HISTORY(c_rec.delivery_id, c_rec.delivery_leg_id, p_trip_id,
		    p_activity_date, p_activity_type, p_request_id,
		    p_action_by, p_action_by_name, p_remarks,
		    p_result_status, p_initial_status,
		    c_rec.carrier_id,c_rec.mode_of_transport,c_rec.service_level,
		    l_return_status, l_error_msg, l_error_tkn);


	IF l_return_status <> 'S' THEN EXIT; END IF;

    END LOOP;

    x_return_status := l_return_status;
    x_error_msg := l_error_msg;
    x_error_tkn := l_error_tkn;

END ADD_HISTORY;

-- Rel 12


PROCEDURE ADD_HISTORY(
		p_init_msg_list           IN     VARCHAR2,
		p_trip_id		  IN	 NUMBER,
		p_delivery_leg_activity_rec IN delivery_leg_activity_rec,
	        x_return_status           OUT NOCOPY  VARCHAR2,
		x_msg_count               OUT NOCOPY  NUMBER,
		x_msg_data                OUT NOCOPY  VARCHAR2)
IS
--{ Local variables

l_api_name              CONSTANT VARCHAR2(30)   := 'ADD_HISTORY';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' ||
					l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

s_activity_id			NUMBER;

-- Cursor
CURSOR c_dlegs(c_trip_id NUMBER) is
	SELECT wdl.delivery_id delivery_id, wdl.delivery_leg_id delivery_leg_id ,
		wt.carrier_id carrier_id, wt.mode_of_transport mode_of_transport ,
		wt.service_level service_level, wt.wf_item_key, wt.rank_id
	FROM wsh_delivery_legs wdl, wsh_trip_stops wts,wsh_trips wt
	WHERE wdl.pick_up_stop_id = wts.stop_id
	AND wts.trip_id = c_trip_id
	AND wt.trip_id= c_trip_id ;
--}

BEGIN


	SAVEPOINT   ADD_HISTORY_PUB;
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

	dbms_output.put_line( ' Testing 12 ' || p_delivery_leg_activity_rec.activity_type);
	dbms_output.put_line( ' Trip Id ' || p_trip_id);


	FOR c_rec IN c_dlegs(p_trip_id) LOOP

	    SELECT wsh_delivery_leg_activities_s.nextval into s_activity_id FROM DUAL;

	    IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Inserting',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	    END IF;

	    dbms_output.put_line( ' Testing 1212 ' || p_delivery_leg_activity_rec.activity_type);


	    INSERT INTO wsh_delivery_leg_activities
		(	ACTIVITY_ID,
			DELIVERY_LEG_ID,
			ACTIVITY_DATE,
			ACTIVITY_TYPE,
			CREATION_DATE,
			CREATED_BY,
		 	LAST_UPDATE_DATE,
		 	LAST_UPDATED_BY,
		 	LAST_UPDATE_LOGIN,
		 	ACTION_BY,
		 	ACTION_BY_NAME,
		 	REMARKS,
		 	RESULT_STATUS,
		 	INITIAL_STATUS,
		 	TRIP_ID,
		 	CARRIER_ID,
		 	MODE_OF_TRANSPORT,
		 	SERVICE_LEVEL,
		 	RANK_ID,
		 	RANK_VERSION,
		 	WF_ITEM_KEY)
	     VALUES
		(	s_activity_id,
			c_rec.delivery_leg_id,
			SYSDATE,
			p_delivery_leg_activity_rec.activity_type,
			SYSDATE,
			FND_GLOBAL.USER_ID, -- created by
		 	SYSDATE, -- last update date
		 	FND_GLOBAL.USER_ID, -- last updatd by
		 	FND_GLOBAL.USER_ID, -- last upd login
		 	p_delivery_leg_activity_rec.action_by,
		 	p_delivery_leg_activity_rec.action_by_name,
		 	p_delivery_leg_activity_rec.remarks,
		 	p_delivery_leg_activity_rec.result_status,
		 	p_delivery_leg_activity_rec.initial_status,
		 	p_delivery_leg_activity_rec.trip_id,
		 	c_rec.carrier_id,
		 	c_rec.mode_of_transport,
		 	c_rec.service_level,
		 	p_delivery_leg_activity_rec.rank_id,
		 	p_delivery_leg_activity_rec.rank_version,
		 	p_delivery_leg_activity_rec.wf_item_key);


	END LOOP;


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
	ROLLBACK TO ADD_HISTORY_PUB;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Error Occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO ADD_HISTORY_PUB;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Unxepected Error Occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
WHEN OTHERS THEN
	ROLLBACK TO ADD_HISTORY_PUB;
	wsh_util_core.default_handler('FTE_DELIVERY_ACTIVITY.ADD_HISTORY');
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
	   IF l_debug_on THEN
	       WSH_DEBUG_SV.logmsg(l_module_name,'Other error Occured',WSH_DEBUG_SV.C_EXCEP_LEVEL);
	       WSH_DEBUG_SV.pop(l_module_name);
	   END IF;
--}
END ADD_HISTORY;

END FTE_DELIVERY_ACTIVITY;

/
