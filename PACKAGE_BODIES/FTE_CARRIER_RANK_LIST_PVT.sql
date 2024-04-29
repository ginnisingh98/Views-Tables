--------------------------------------------------------
--  DDL for Package Body FTE_CARRIER_RANK_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_CARRIER_RANK_LIST_PVT" AS
/* $Header: FTECLTHB.pls 120.7 2005/08/05 16:05:30 hbhagava noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_CARRIER_RANK_LIST_PVT';





PROCEDURE LOG(p_module_name	VARCHAR2,
		p_text		VARCHAR2,
		p_level		VARCHAR2)
IS



BEGIN

	      WSH_DEBUG_SV.logmsg(p_module_name,p_text,p_level);

END LOG;


PROCEDURE UPDATE_RANK(
	p_rank_info_rec		IN		carrier_rank_list_rec,
	x_return_status		OUT NOCOPY 	VARCHAR2
) IS

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	UPDATE FTE_CARRIER_RANK_LIST SET
	CARRIER_ID   = decode(p_rank_info_rec.CARRIER_ID,NULL,CARRIER_ID,
					FND_API.G_MISS_NUM,NULL,
    					p_rank_info_rec.CARRIER_ID),
	SERVICE_LEVEL =decode(p_rank_info_rec.SERVICE_LEVEL,NULL,SERVICE_LEVEL,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.SERVICE_LEVEL),
	MODE_OF_TRANSPORT =	decode(p_rank_info_rec.MODE_OF_TRANSPORT,NULL,MODE_OF_TRANSPORT,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.MODE_OF_TRANSPORT),
	LANE_ID   = decode(p_rank_info_rec.LANE_ID,NULL,LANE_ID,
					FND_API.G_MISS_NUM,NULL,
    					p_rank_info_rec.LANE_ID),
	--SOURCE =	decode(p_rank_info_rec.SOURCE,NULL,SOURCE,
    	--				FND_API.G_MISS_CHAR,NULL,
    	--				p_rank_info_rec.SOURCE),
	ENABLED =	decode(p_rank_info_rec.ENABLED,NULL,ENABLED,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ENABLED),
	ESTIMATED_RATE   = decode(p_rank_info_rec.ESTIMATED_RATE,NULL,ESTIMATED_RATE,
					FND_API.G_MISS_NUM,NULL,
    					p_rank_info_rec.ESTIMATED_RATE),
	CURRENCY_CODE =	decode(p_rank_info_rec.CURRENCY_CODE,NULL,CURRENCY_CODE,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.CURRENCY_CODE),
	VEHICLE_ITEM_ID   = decode(p_rank_info_rec.VEHICLE_ITEM_ID,NULL,VEHICLE_ITEM_ID,
					FND_API.G_MISS_NUM,NULL,
    					p_rank_info_rec.VEHICLE_ITEM_ID),
	VEHICLE_ORG_ID   = decode(p_rank_info_rec.VEHICLE_ORG_ID,NULL,VEHICLE_ORG_ID,
					FND_API.G_MISS_NUM,NULL,
    					p_rank_info_rec.VEHICLE_ORG_ID),
	ESTIMATED_TRANSIT_TIME   = decode(p_rank_info_rec.ESTIMATED_TRANSIT_TIME,NULL,ESTIMATED_TRANSIT_TIME,
					FND_API.G_MISS_NUM,NULL,
    					p_rank_info_rec.ESTIMATED_TRANSIT_TIME),
	TRANSIT_TIME_UOM =	decode(p_rank_info_rec.TRANSIT_TIME_UOM,NULL,TRANSIT_TIME_UOM,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.TRANSIT_TIME_UOM),
	VERSION =	decode(p_rank_info_rec.VERSION,NULL,VERSION,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.VERSION),
	CONSIGNEE_CARRIER_AC_NO =	decode(p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO,NULL,CONSIGNEE_CARRIER_AC_NO,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO),
	FREIGHT_TERMS_CODE =	decode(p_rank_info_rec.FREIGHT_TERMS_CODE,NULL,FREIGHT_TERMS_CODE,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.FREIGHT_TERMS_CODE),
	CALL_RG_FLAG =	decode(p_rank_info_rec.CALL_RG_FLAG,NULL,CALL_RG_FLAG,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.CALL_RG_FLAG),
	ATTRIBUTE_CATEGORY =	decode(p_rank_info_rec.ATTRIBUTE_CATEGORY,NULL,ATTRIBUTE_CATEGORY,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE_CATEGORY),
	ATTRIBUTE1 =	decode(p_rank_info_rec.ATTRIBUTE1,NULL,ATTRIBUTE1,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE1),
	ATTRIBUTE2 =	decode(p_rank_info_rec.ATTRIBUTE2,NULL,ATTRIBUTE2,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE2),
	ATTRIBUTE3 =	decode(p_rank_info_rec.ATTRIBUTE3,NULL,ATTRIBUTE3,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE3),
	ATTRIBUTE4 =	decode(p_rank_info_rec.ATTRIBUTE4,NULL,ATTRIBUTE4,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE4),
	ATTRIBUTE5 =	decode(p_rank_info_rec.ATTRIBUTE5,NULL,ATTRIBUTE5,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE5),
	ATTRIBUTE6 =	decode(p_rank_info_rec.ATTRIBUTE6,NULL,ATTRIBUTE6,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE6),
	ATTRIBUTE7 =	decode(p_rank_info_rec.ATTRIBUTE7,NULL,ATTRIBUTE7,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE7),
	ATTRIBUTE8 =	decode(p_rank_info_rec.ATTRIBUTE8,NULL,ATTRIBUTE8,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE8),
	ATTRIBUTE9 =	decode(p_rank_info_rec.ATTRIBUTE9,NULL,ATTRIBUTE9,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE9),
	ATTRIBUTE10 =	decode(p_rank_info_rec.ATTRIBUTE10,NULL,ATTRIBUTE10,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE10),
	ATTRIBUTE11 =	decode(p_rank_info_rec.ATTRIBUTE11,NULL,ATTRIBUTE11,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE11),
	ATTRIBUTE12 =	decode(p_rank_info_rec.ATTRIBUTE12,NULL,ATTRIBUTE12,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE12),
	ATTRIBUTE13 =	decode(p_rank_info_rec.ATTRIBUTE13,NULL,ATTRIBUTE13,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE13),
	ATTRIBUTE14 =	decode(p_rank_info_rec.ATTRIBUTE14,NULL,ATTRIBUTE14,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE14),
	ATTRIBUTE15 =	decode(p_rank_info_rec.ATTRIBUTE15,NULL,ATTRIBUTE15,
    					FND_API.G_MISS_CHAR,NULL,
    					p_rank_info_rec.ATTRIBUTE15),
	last_update_date 	= SYSDATE,
	last_updated_by  	= FND_GLOBAL.USER_ID,
	last_update_login	= FND_GLOBAL.USER_ID
	WHERE rank_id = p_rank_info_rec.rank_id;

  IF (SQL%NOTFOUND) THEN
     RAISE no_data_found;
  END IF;

EXCEPTION
     WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_RANK_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN others THEN
	   wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.UPDATE');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END UPDATE_RANK;

PROCEDURE SET_RANK_CURRENT(
			p_rank_info_rec		IN		carrier_rank_list_rec,
			p_trip_id		IN		NUMBER,
			x_return_status		OUT NOCOPY 	VARCHAR2)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'SET_RANK_CURRENT';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

x_rank_list_rec		  carrier_rank_list_rec;
l_rank_list_rec		  carrier_rank_list_rec;

l_currentSet		  VARCHAR2(32767);
l_trip_id		  NUMBER;

l_trip_name		  VARCHAR2(32767);

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


CURSOR get_trip IS
	SELECT trip_id INTO l_trip_id FROM FTE_CARRIER_RANK_LIST
	WHERE TRIP_ID = p_trip_id
	AND ROWNUM = 1;


BEGIN

  	SAVEPOINT	SET_RANK_CURRENT_PUB;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF l_debug_on
	THEN
	      Log(l_module_name,' Calling Update Rank to update version ' ,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	UPDATE_RANK(p_rank_info_rec => p_rank_info_rec,
		    x_return_status => l_return_status);
	-- Update trip with this rank id

	IF (l_return_status = 'E')
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = 'U')
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Change this call with Shipping API

	IF l_debug_on
	THEN
	      Log(l_module_name,' Update trip with rank id ' || p_rank_info_rec.rank_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

	-- Update trip information
	p_trip_info.RANK_ID 		:= p_rank_info_rec.rank_id;
	p_trip_info.TRIP_ID 		:= p_trip_id;

	p_trip_info_tab(1)		:=p_trip_info;
	p_trip_in_rec.caller		:='FTE_LOAD_TENDER';
	p_trip_in_rec.phase		:=NULL;
	p_trip_in_rec.action_code	:='UPDATE';

	IF l_debug_on
	THEN
	      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ',
				  WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	WSH_INTERFACE_GRP.Create_Update_Trip
	(
	    p_api_version_number	=>1.0,
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


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO SET_RANK_CURRENT_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO SET_RANK_CURRENT_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO SET_RANK_CURRENT_PUB;
		WSH_UTIL_CORE.DEFAULT_HANDLER('FTE_CARRIER_RANK_LIST_PVT.SET_RANK_CURRENT');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

END SET_RANK_CURRENT;



PROCEDURE DELETE_RANK_LIST(
	p_trip_id	     	IN	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_RANK';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_tender_status	VARCHAR2(30);

l_trip_name	VARCHAR2(32767);

l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


CURSOR GET_TENDER_STATUS IS
	SELECT LOAD_TENDER_STATUS FROM WSH_TRIPS
	WHERE TRIP_ID = p_trip_id;

BEGIN

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	-- Check tender status of trip if it is tendered / accepted we cannot delete rank list

	OPEN GET_TENDER_STATUS;
	FETCH GET_TENDER_STATUS INTO l_tender_status;


	IF (GET_TENDER_STATUS%NOTFOUND)
	THEN
		CLOSE GET_TENDER_STATUS;

		FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TRIP');
		FND_MESSAGE.SET_TOKEN('TRIP_ID', p_trip_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
		RAISE FND_API.G_EXC_ERROR;

	END IF;

	CLOSE GET_TENDER_STATUS;

	IF (l_tender_status = FTE_TENDER_PVT.S_TENDERED OR
		l_tender_status = FTE_TENDER_PVT.S_ACCEPTED OR
		l_tender_status = FTE_TENDER_PVT.S_AUTO_ACCEPTED)
	THEN

		FND_MESSAGE.SET_NAME('FTE','FTE_CNT_DELETE_TENDER_CHECK');
		FND_MESSAGE.SET_TOKEN('TENDER_STATUS',
				WSH_UTIL_CORE.Get_Lookup_Meaning('WSH_TENDER_STATUS',
                         				l_tender_status));
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	BEGIN

		DELETE FROM fte_carrier_rank_list
		WHERE trip_id = p_trip_id;


		IF (SQL%NOTFOUND) THEN
			RAISE NO_DATA_FOUND;
		END IF;
	EXCEPTION
	     WHEN no_data_found THEN
			SELECT NAME INTO l_trip_name FROM WSH_TRIPS WHERE TRIP_ID = p_trip_id;
			FND_MESSAGE.SET_NAME('FTE','FTE_RANK_TRIP_NOT_FOUND');
			FND_MESSAGE.SET_TOKEN('TRIP_NAME', l_trip_name);
			x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
			RAISE FND_API.G_EXC_ERROR;
	END;


		FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

		-- Update trip information
		p_trip_info.RANK_ID 		:= NULL;
		--p_trip_info.APPEND_FLAG 	:= 'N';
		p_trip_info.TRIP_ID 		:= p_trip_id;

		p_trip_info_tab(1)		:=p_trip_info;
		p_trip_in_rec.caller		:='FTE_LOAD_TENDER';
		p_trip_in_rec.phase		:=NULL;
		p_trip_in_rec.action_code	:='UPDATE';

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ',
					  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>1.0,
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

	IF l_debug_on
	THEN
	      Log(l_module_name,' Return value after deleting RANK LIST ' || x_return_status,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on
		THEN
		      Log(l_module_name,' Return value from DELETE_RANK_LIST ' || x_return_status,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		END IF;
         WHEN others THEN
		    wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.DELETE_RANK_LIST');
		    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
		      WSH_DEBUG_SV.pop(l_module_name);
		END IF;

END DELETE_RANK_LIST;

PROCEDURE CREATE_RANK(
		p_rank_info_rec		IN		carrier_rank_list_rec,
		p_derive_init_sm_config IN 		VARCHAR2,
		x_rank_id		OUT NOCOPY  	NUMBER,
		x_return_status		OUT NOCOPY 	VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'CREATE_RANK';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


  CURSOR get_next_rank_id IS
  SELECT fte_carrier_rank_list_s.nextval
  FROM sys.dual;

  l_temp_id          NUMBER;
  EMPTY_TRIP_ID		EXCEPTION;
  EMPTY_RANK_SEQUENCE	EXCEPTION;

  l_config	VARCHAR(3);


BEGIN

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	if (p_rank_info_rec.trip_id IS NULL or
	    p_rank_info_rec.trip_id = FND_API.G_MISS_NUM) then
		RAISE EMPTY_TRIP_ID;
	end if;


	if (p_rank_info_rec.RANK_SEQUENCE IS null or
	    p_rank_info_rec.RANK_SEQUENCE = FND_API.G_MISS_NUM) then
		RAISE EMPTY_RANK_SEQUENCE;
	end if;

	OPEN get_next_rank_id;
	FETCH get_next_rank_id INTO x_rank_id;
	CLOSE get_next_rank_id;


	l_config := '';
	Log(l_module_name,' Derive init sm config ' || p_derive_init_sm_config,
					WSH_DEBUG_SV.C_PROC_LEVEL);


	IF (p_derive_init_sm_config = FND_API.G_FALSE)
	THEN
		l_config := p_rank_info_rec.INITSMCONFIG;
		Log(l_module_name,' l_config ' || l_config,
					WSH_DEBUG_SV.C_PROC_LEVEL);

	ELSE

		IF (p_rank_info_rec.CARRIER_ID IS NOT NULL) THEN
			l_config := 'C';
		END IF;

		IF (p_rank_info_rec.SERVICE_LEVEL IS NOT NULL) THEN
			l_config := l_config || 'S';
		END IF;

		IF (p_rank_info_rec.MODE_OF_TRANSPORT IS NOT NULL) THEN
			l_config := l_config || 'M';
		END IF;
	END IF;

	IF l_debug_on
	THEN

	      Log(l_module_name,' Creating Rank list Entry ' ,	WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.TRIP_ID			 ' || p_rank_info_rec.TRIP_ID			,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.RANK_SEQUENCE		 ' || p_rank_info_rec.RANK_SEQUENCE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CARRIER_ID		 	 ' || p_rank_info_rec.CARRIER_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.SERVICE_LEVEL		 ' || p_rank_info_rec.SERVICE_LEVEL,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.MODE_OF_TRANSPORT	 	 ' || p_rank_info_rec.MODE_OF_TRANSPORT,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.LANE_ID			 ' || p_rank_info_rec.LANE_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.SOURCE			 ' || p_rank_info_rec.SOURCE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.ESTIMATED_RATE		 ' || p_rank_info_rec.ESTIMATED_RATE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CURRENCY_CODE		 ' || p_rank_info_rec.CURRENCY_CODE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.VEHICLE_ITEM_ID		 ' || p_rank_info_rec.VEHICLE_ITEM_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.VEHICLE_ORG_ID		 ' || p_rank_info_rec.VEHICLE_ORG_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.ESTIMATED_TRANSIT_TIME	 ' || p_rank_info_rec.ESTIMATED_TRANSIT_TIME,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.TRANSIT_TIME_UOM	 	 ' || p_rank_info_rec.TRANSIT_TIME_UOM,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO	 ' || p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.FREIGHT_TERMS_CODE	 	 ' || p_rank_info_rec.FREIGHT_TERMS_CODE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' l_config				 	 ' || l_config		,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CALL_RG_FLAG ' || p_rank_info_rec.CALL_RG_FLAG,WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	insert into FTE_CARRIER_RANK_LIST
	(
		  RANK_ID                   ,
		  TRIP_ID                   ,
		  RANK_SEQUENCE             ,
		  CARRIER_ID		    ,
		  SERVICE_LEVEL	            ,
		  MODE_OF_TRANSPORT         ,
		  LANE_ID                   ,
		  SOURCE		    ,
		  ENABLED		    ,
		  ESTIMATED_RATE	    ,
		  CURRENCY_CODE		    ,
		  VEHICLE_ITEM_ID	    ,
		  VEHICLE_ORG_ID	    ,
		  ESTIMATED_TRANSIT_TIME    ,
		  TRANSIT_TIME_UOM	    ,
		  VERSION		    ,
		  CONSIGNEE_CARRIER_AC_NO   ,
		  FREIGHT_TERMS_CODE	    ,
		  INITSMCONFIG		    ,
		  CALL_RG_FLAG		    ,
		  ATTRIBUTE_CATEGORY        ,
		  ATTRIBUTE1                ,
		  ATTRIBUTE2                ,
		  ATTRIBUTE3                ,
		  ATTRIBUTE4                ,
		  ATTRIBUTE5                ,
		  ATTRIBUTE6                ,
		  ATTRIBUTE7                ,
		  ATTRIBUTE8                ,
		  ATTRIBUTE9                ,
		  ATTRIBUTE10               ,
		  ATTRIBUTE11               ,
		  ATTRIBUTE12               ,
		  ATTRIBUTE13               ,
		  ATTRIBUTE14               ,
		  ATTRIBUTE15               ,
		  CREATION_DATE             ,
		  CREATED_BY                ,
		  LAST_UPDATE_DATE          ,
		  LAST_UPDATED_BY           ,
		  LAST_UPDATE_LOGIN
	)
	values
	(
		x_rank_id,
		p_rank_info_rec.TRIP_ID,
		p_rank_info_rec.RANK_SEQUENCE,
		decode(p_rank_info_rec.CARRIER_ID,FND_API.G_MISS_NUM,NULL,p_rank_info_rec.CARRIER_ID),
		decode(p_rank_info_rec.SERVICE_LEVEL,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.SERVICE_LEVEL),
		decode(p_rank_info_rec.MODE_OF_TRANSPORT,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.MODE_OF_TRANSPORT),
		decode(p_rank_info_rec.LANE_ID,FND_API.G_MISS_NUM,NULL,p_rank_info_rec.LANE_ID),
		decode(p_rank_info_rec.SOURCE,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.SOURCE),
		'Y',
		decode(p_rank_info_rec.ESTIMATED_RATE,FND_API.G_MISS_NUM,NULL,p_rank_info_rec.ESTIMATED_RATE),
		decode(p_rank_info_rec.CURRENCY_CODE,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.CURRENCY_CODE),
		decode(p_rank_info_rec.VEHICLE_ITEM_ID,FND_API.G_MISS_NUM,NULL,p_rank_info_rec.VEHICLE_ITEM_ID),
		decode(p_rank_info_rec.VEHICLE_ORG_ID,FND_API.G_MISS_NUM,NULL,p_rank_info_rec.VEHICLE_ORG_ID),
		decode(p_rank_info_rec.ESTIMATED_TRANSIT_TIME,FND_API.G_MISS_NUM,NULL,p_rank_info_rec.ESTIMATED_TRANSIT_TIME),

		decode(p_rank_info_rec.TRANSIT_TIME_UOM,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.TRANSIT_TIME_UOM),
		0,

		decode(p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO),
		decode(p_rank_info_rec.FREIGHT_TERMS_CODE,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.FREIGHT_TERMS_CODE),
		l_config,
		decode(p_rank_info_rec.CALL_RG_FLAG,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.CALL_RG_FLAG),
		decode(p_rank_info_rec.ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE_CATEGORY),
		decode(p_rank_info_rec.ATTRIBUTE1,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE1),
		decode(p_rank_info_rec.ATTRIBUTE2,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE2),
		decode(p_rank_info_rec.ATTRIBUTE3,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE3),
		decode(p_rank_info_rec.ATTRIBUTE4,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE4),
		decode(p_rank_info_rec.ATTRIBUTE5,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE5),
		decode(p_rank_info_rec.ATTRIBUTE6,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE6),
		decode(p_rank_info_rec.ATTRIBUTE7,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE7),
		decode(p_rank_info_rec.ATTRIBUTE8,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE8),
		decode(p_rank_info_rec.ATTRIBUTE9,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE9),
		decode(p_rank_info_rec.ATTRIBUTE10,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE10),
		decode(p_rank_info_rec.ATTRIBUTE11,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE11),
		decode(p_rank_info_rec.ATTRIBUTE12,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE12),
		decode(p_rank_info_rec.ATTRIBUTE13,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE13),
		decode(p_rank_info_rec.ATTRIBUTE14,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE14),
		decode(p_rank_info_rec.ATTRIBUTE15,FND_API.G_MISS_CHAR,NULL,p_rank_info_rec.ATTRIBUTE15),

		decode(p_rank_info_rec.creation_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE,p_rank_info_rec.creation_date),
		decode(p_rank_info_rec.created_by,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_rank_info_rec.created_by),
		decode(p_rank_info_rec.last_update_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE, p_rank_info_rec.last_update_date),
		decode(p_rank_info_rec.last_updated_by,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_rank_info_rec.last_updated_by),
		decode(p_rank_info_rec.last_update_login,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.LOGIN_ID,p_rank_info_rec.last_update_login)
	);

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION
	WHEN EMPTY_TRIP_ID THEN
		FND_MESSAGE.SET_NAME('FTE', 'FTE_RANK_TRIP_ID_MISSING');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	WHEN EMPTY_RANK_SEQUENCE THEN
		FND_MESSAGE.SET_NAME('FTE', 'FTE_RANK_SEQUENCE_MISSING');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	WHEN others THEN
	        wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.CREATE');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END CREATE_RANK;


PROCEDURE CREATE_RANK_LIST(
		p_ranklist		IN OUT NOCOPY	carrier_rank_list_tbl_type,
		p_trip_id		IN		NUMBER,
		x_return_status		OUT NOCOPY 	VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'CREATE_RANK_LIST';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

x_rank_list_rec		  carrier_rank_list_rec;
l_rank_list_rec		  carrier_rank_list_rec;

l_currentSet		  VARCHAR2(32767);
l_trip_id		  NUMBER;

l_trip_name		  VARCHAR2(32767);

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


CURSOR get_trip IS
	SELECT trip_id INTO l_trip_id FROM FTE_CARRIER_RANK_LIST
	WHERE TRIP_ID = p_trip_id
	AND ROWNUM = 1;


BEGIN

  	SAVEPOINT	CREATE_RANK_LIST_PUB;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--{
	IF l_debug_on
	THEN
	      Log(l_module_name,' Creating Rank List for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	-- Check if rank list exists for tis trip

	OPEN get_trip;
	FETCH get_trip INTO l_trip_id;

	IF (get_trip%NOTFOUND) THEN
		CLOSE get_trip;
	ELSE
		CLOSE get_trip;

		SELECT NAME INTO l_trip_name FROM WSH_TRIPS WHERE TRIP_ID = p_trip_id;

		FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_LIST_EXISTS');
		FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
		WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	l_currentSet := FND_API.G_FALSE;

	FOR i IN p_ranklist.FIRST..p_ranklist.LAST LOOP

		l_rank_list_rec := p_ranklist(i);
		l_rank_list_rec.trip_id := p_trip_id;

		CREATE_RANK(p_rank_info_rec	=> l_rank_list_rec,
			p_derive_init_sm_config => FND_API.G_TRUE,
		       x_rank_id	=> l_rank_id,
		       x_return_status	=> l_return_status);


		IF (l_return_status = 'E')
		THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_status = 'U')
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		p_ranklist(i).rank_id := l_rank_id;

		IF l_debug_on
		THEN
		      Log(l_module_name,' Rank Id ' || l_rank_id,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' IS CURRENT ' || p_ranklist(i).IS_CURRENT,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Return value  ' || p_ranklist(i).IS_CURRENT,
					WSH_DEBUG_SV.C_PROC_LEVEL);

		END IF;


		IF (p_ranklist(i).IS_CURRENT = 'Y') THEN

			IF (l_currentSet = FND_API.G_TRUE) THEN
				SELECT NAME INTO l_trip_name FROM WSH_TRIPS WHERE TRIP_ID = p_trip_id;

				FND_MESSAGE.SET_NAME('FTE','FTE_CANNOT_SET_MORE_CURR');
				FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
				WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			l_currentSet := FND_API.G_TRUE;
			p_ranklist(i).VERSION := 1;


			IF l_debug_on
			THEN
			      Log(l_module_name,' Calling SET RANK CURRENT API ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			SET_RANK_CURRENT(p_rank_info_rec => p_ranklist(i),
					 p_trip_id => p_trip_id,
					 x_return_status => l_return_status);

			IF l_debug_on
			THEN
			      Log(l_module_name,' After calling SET_RANK_CURRENT ' || l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;



			IF (l_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

			-- Change this call with Shipping API

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

	END LOOP;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_RANK_LIST_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_RANK_LIST_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO CREATE_RANK_LIST_PUB;
		WSH_UTIL_CORE.DEFAULT_HANDLER('FTE_CARRIER_RANK_LIST_PVT.CREATE_RANK_LIST');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

END CREATE_RANK_LIST;


PROCEDURE UPDATE_RANK_LIST(
		p_ranklist		IN OUT NOCOPY	carrier_rank_list_tbl_type,
		p_trip_id		IN		NUMBER,
		x_return_status		OUT NOCOPY 	VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'UPDATE_RANK_LIST';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

x_rank_list_rec		  carrier_rank_list_rec;

l_currentSet		  VARCHAR2(32767);
l_trip_id		  NUMBER;
l_trip_name		VARCHAR2(32767);

CURSOR get_trip IS
	SELECT trip_id INTO l_trip_id FROM FTE_CARRIER_RANK_LIST
	WHERE TRIP_ID = p_trip_id
	AND ROWNUM = 1;


BEGIN

  	SAVEPOINT	UPDATE_RANK_LIST_PUB;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--{
	IF l_debug_on
	THEN
	      Log(l_module_name,' Updating Rank List for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	-- Check if rank list exists for tis trip

	OPEN get_trip;
	FETCH get_trip INTO l_trip_id;

	IF (get_trip%NOTFOUND) THEN
		CLOSE get_trip;

		SELECT NAME INTO l_trip_name FROM WSH_TRIPS WHERE TRIP_ID = p_trip_id;

		FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_LIST_NOTEXISTS');
		FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
		WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	CLOSE get_trip;

	IF (p_ranklist.COUNT > 0)
	THEN
	--{

		FOR i IN p_ranklist.FIRST..p_ranklist.LAST LOOP

			IF l_debug_on
			THEN
			      Log(l_module_name,' Updating Rank id ' || p_ranklist(i).RANK_ID,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			UPDATE_RANK(p_rank_info_rec	=> p_ranklist(i),
			       x_return_status	=> l_return_status);

			IF (x_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (x_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

			--x_rank_list_rec := p_ranklist(i);

			--x_ranklist(i) := x_rank_list_rec;

		END LOOP;
	--}
	END IF;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_RANK_LIST_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_RANK_LIST_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_RANK_LIST_PUB;
		WSH_UTIL_CORE.DEFAULT_HANDLER('FTE_CARRIER_RANK_LIST_PVT.UPDATE_RANK_LIST');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

END UPDATE_RANK_LIST;




PROCEDURE APPEND_RANK_LIST(
		p_ranklist		IN OUT NOCOPY	carrier_rank_list_tbl_type,
		p_trip_id		IN		NUMBER,
		x_return_status		OUT NOCOPY 	VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30)   := 'APPEND_RANK_LIST';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;


l_rank_list_rec		  carrier_rank_list_rec;

l_max_rank_seq		   NUMBER;
idx			   NUMBER;

l_currentSet		  VARCHAR2(32767);
l_trip_name		  VARCHAR2(32767);


CURSOR get_max_seq IS
	SELECT MAX(RANK_SEQUENCE)
	FROM FTE_CARRIER_RANK_LIST
	WHERE TRIP_ID = p_trip_id;


BEGIN

  	SAVEPOINT	APPEND_RANK_LIST_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	--{
	IF l_debug_on
	THEN
	      Log(l_module_name,' Append Rank List for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	SELECT MAX(RANK_SEQUENCE) INTO l_max_rank_seq
	FROM FTE_CARRIER_RANK_LIST
	WHERE TRIP_ID = p_trip_id;

	IF (l_max_rank_seq IS NULL) THEN
		FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_LIST_NOTEXISTS');
		FND_MESSAGE.SET_TOKEN('TRIP_ID',p_trip_id);
		WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	IF l_debug_on
	THEN
	      Log(l_module_name,' Found max seq ' || l_max_rank_seq,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      Log(l_module_name,' Appending to Rank List ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	idx :=1;
	FOR i IN p_ranklist.FIRST..p_ranklist.LAST LOOP


		p_ranklist(i).RANK_SEQUENCE := l_max_rank_seq+idx;
		p_ranklist(i).TRIP_ID := p_trip_id;

		CREATE_RANK(p_rank_info_rec	=> p_ranklist(i),
		       p_derive_init_sm_config	=> FND_API.G_FALSE,
		       x_rank_id	=> l_rank_id,
		       x_return_status	=> l_return_status);


		IF l_debug_on
		THEN
		      Log(l_module_name,' After calling CREATE_RANK l_return_status ' ||
		      			l_return_status,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		wsh_util_core.api_post_call(
		      p_return_status    =>l_return_status,
		      x_num_warnings     =>l_number_of_warnings,
		      x_num_errors       =>l_number_of_errors,
		      p_msg_data	 =>l_msg_data);



		IF (p_ranklist(i).IS_CURRENT = 'Y') THEN

			IF (l_currentSet = FND_API.G_TRUE) THEN
				SELECT NAME INTO l_trip_name FROM WSH_TRIPS WHERE TRIP_ID = p_trip_id;

				FND_MESSAGE.SET_NAME('FTE','FTE_CANNOT_SET_MORE_CURR');
				FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
				WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
				RAISE FND_API.G_EXC_ERROR;
			END IF;

			l_currentSet := FND_API.G_TRUE;
			p_ranklist(i).VERSION := 1;
			p_ranklist(i).RANK_ID := l_rank_id;


			IF l_debug_on
			THEN
			      Log(l_module_name,' Calling SET RANK CURRENT API ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			SET_RANK_CURRENT(p_rank_info_rec => p_ranklist(i),
					 p_trip_id => p_trip_id,
					 x_return_status => l_return_status);

			IF l_debug_on
			THEN
			      Log(l_module_name,' After calling SET_RANK_CURRENT ' || l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;



			IF (l_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;

			-- Change this call with Shipping API

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);



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

		p_ranklist(i).RANK_ID := l_rank_id;

		idx := idx+1;

	END LOOP;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO APPEND_RANK_LIST_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO APPEND_RANK_LIST_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		ROLLBACK TO APPEND_RANK_LIST_PUB;
		WSH_UTIL_CORE.DEFAULT_HANDLER('FTE_CARRIER_RANK_LIST_PVT.APPEND_RANK_LIST');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
END APPEND_RANK_LIST;



PROCEDURE RANK_LIST_ACTION(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_action_code		IN		VARCHAR2,
	p_ranklist		IN OUT NOCOPY	carrier_rank_list_tbl_type,
	p_trip_id		IN		NUMBER,
	p_rank_id		IN		NUMBER)
IS


l_api_name              CONSTANT VARCHAR2(30)   := 'RANK_LIST_ACTION';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

l_carrier_rank_list_rec	   CARRIER_RANK_LIST_REC;
--}

l_current_version	   NUMBER;
l_temp_id		   NUMBER;

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}


BEGIN


	SAVEPOINT   RANK_LIST_ACTION_PUB;
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

	--{
	IF (p_action_code = S_CREATE) THEN
		IF l_debug_on
		THEN
		      Log(l_module_name,' Creating Rank List for trip ' || p_trip_id,
		      			WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		CREATE_RANK_LIST(
			p_ranklist		=> p_ranklist,
			p_trip_id		=> p_trip_id,
			x_return_status		=> l_return_status);

 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' l_return_status after CREATE_RANK_LIST ' ||
 		      			l_return_status,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;


	ELSIF (p_action_code = S_UPDATE) THEN
		IF l_debug_on
		THEN
		      Log(l_module_name,' Updating Rank List for trip. TBD ' || p_trip_id,
		      			WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		UPDATE_RANK_LIST(
			p_ranklist		=> p_ranklist,
			p_trip_id		=> p_trip_id,
			x_return_status		=> l_return_status);


 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' l_return_status after UPDATE_RANK_LIST ' ||
 		      			l_return_status,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

	ELSIF (p_action_code = S_DELETE) THEN
 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' Delete Rank List for trip ' || p_trip_id,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

 		DELETE_RANK_LIST(p_trip_id		=> p_trip_id,
 			x_return_status		=> l_return_status);

 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' l_return_status after DELETE_RANK_LIST ' ||
 		      			l_return_status,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;


 	ELSIF (p_action_code = S_SET_CURRENT) THEN
 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' Setting Current Rank ' || p_trip_id,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

 		BEGIN


			SELECT VERSION INTO l_current_version
			FROM FTE_CARRIER_RANK_LIST
			WHERE RANK_ID = p_rank_id;

			IF (SQL%NOTFOUND) THEN
				RAISE NO_DATA_FOUND;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('FTE','FTE_RANK_NOT_FOUND');
				FND_MESSAGE.SET_TOKEN('RANK_ID', p_rank_id);
				x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
				WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
				RAISE FND_API.G_EXC_ERROR;

		END;



		l_carrier_rank_list_rec.VERSION := l_current_version+1;
		l_carrier_rank_list_rec.rank_id := p_rank_id;
		UPDATE_RANK(p_rank_info_rec => l_carrier_rank_list_rec,
			    x_return_status => l_return_status);


		IF l_debug_on
		THEN
		      Log(l_module_name,' After calling UPDATE_RANK ' || l_return_status,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		IF (l_return_status = 'E')
		THEN
			RAISE FND_API.G_EXC_ERROR;
		ELSIF (l_return_status = 'U')
		THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;



		-- Change this call with Shipping API

		IF l_debug_on
		THEN
		      Log(l_module_name,' Update trip with rank id ' ,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		FTE_MLS_WRAPPER.INITIALIZE_TRIP_REC(x_trip_info => p_trip_info);

		-- Update trip information
		p_trip_info.RANK_ID 		:= p_rank_id;
		p_trip_info.TRIP_ID 		:= p_trip_id;

		p_trip_info_tab(1)		:=p_trip_info;
		p_trip_in_rec.caller		:='FTE_LOAD_TENDER';
		p_trip_in_rec.phase		:=NULL;
		p_trip_in_rec.action_code	:='UPDATE';

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Before calling CREATE_UPDATE_TRIP ' ||
					' Rank list Action ',
					  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		WSH_INTERFACE_GRP.Create_Update_Trip
		(
		    p_api_version_number	=>1.0,
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


 	ELSIF (p_action_code = S_APPEND) THEN
 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' Append Rank List for trip ' || p_trip_id,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

		APPEND_RANK_LIST(
			p_ranklist		=> p_ranklist,
			p_trip_id		=> p_trip_id,
			x_return_status		=> l_return_status);

 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' l_return_status after APPEND_RANK_LIST ' ||
 		      			l_return_status,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

 	ELSIF (p_action_code = S_REPLACE) THEN
		-- Request from Arindam

 		IF l_debug_on
 		THEN
 		      Log(l_module_name,'  Replace existing rank list. Calling Delete first ' || p_trip_id,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

		SELECT count(*) INTO l_temp_id FROM FTE_CARRIER_RANK_LIST
		WHERE TRIP_ID = p_trip_id and rownum = 1;

		IF (l_temp_id > 0) THEN

			-- First call delete on rank list
			DELETE_RANK_LIST(p_trip_id		=> p_trip_id,
				x_return_status		=> l_return_status);

			IF l_debug_on
			THEN
			      Log(l_module_name,' l_return_status after DELETE_RANK_LIST ' ||
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


		-- now call create
		IF l_debug_on
		THEN
		      Log(l_module_name,' Creating Rank for replace action ' || p_trip_id,
		      			WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		CREATE_RANK_LIST(
			p_ranklist		=> p_ranklist,
			p_trip_id		=> p_trip_id,
			x_return_status		=> l_return_status);

 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' l_return_status after CREATE_RANK_LIST for replace action ' ||
 		      			l_return_status,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;

		SELECT RANK_ID INTO l_temp_id
		FROM WSH_TRIPS
		where TRIP_ID = p_trip_id;

 		IF l_debug_on
 		THEN
 		      Log(l_module_name,' rank id after CREATE_RANK_LIST for replace action ' ||
 		      			l_temp_id,
 		      			WSH_DEBUG_SV.C_PROC_LEVEL);
 		END IF;


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



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO RANK_LIST_ACTION_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO RANK_LIST_ACTION_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	 WHEN OTHERS THEN
		ROLLBACK TO RANK_LIST_ACTION_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


END RANK_LIST_ACTION;


PROCEDURE RANK_LIST_ACTION_UIWRAPPER(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_action_code		IN		VARCHAR2,
	p_ranklist		IN OUT NOCOPY	FTE_SS_RATE_SORT_TAB_TYPE,
	p_trip_id		IN		NUMBER,
	p_rank_id		IN		NUMBER)
IS


l_api_name              CONSTANT VARCHAR2(30)   := 'RANK_LIST_ACTION_UIWRAPPER';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

l_carrier_rank_list_rec	   CARRIER_RANK_LIST_REC;
l_carrier_rank_list_tbl	   carrier_rank_list_tbl_type;
l_return_rank_list_tbl	   CARRIER_RANK_LIST_TBL_TYPE;
l_return_ss_rate_sort_rec  FTE_SS_RATE_SORT_REC;

x_ranklist		FTE_SS_RATE_SORT_TAB_TYPE;

--}

l_current_version	   NUMBER;


BEGIN


	SAVEPOINT   RANK_LIST_ACTION_UIWRAPPER_PUB;
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

	--{

	IF (p_ranklist IS NOT NULL
	AND p_ranklist.COUNT > 0)
	THEN
		IF l_debug_on
		THEN
		      Log(l_module_name,' Transfering from UI list to PLSQL List ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		FOR i IN p_ranklist.FIRST..p_ranklist.LAST LOOP


			l_carrier_rank_list_rec.RANK_ID := p_ranklist(i).RANK_ID;
			l_carrier_rank_list_rec.TRIP_ID := p_trip_id;
			l_carrier_rank_list_rec.RANK_SEQUENCE			:= p_ranklist(i).RANK_SEQUENCE;
			l_carrier_rank_list_rec.LANE_ID				:= p_ranklist(i).LANE_ID;
			--l_carrier_rank_list_rec.SCHEDULE_ID			:= p_ranklist(i).SCHEDULE_ID;
			l_carrier_rank_list_rec.CARRIER_ID			:= p_ranklist(i).CARRIER_ID;
			l_carrier_rank_list_rec.MODE_OF_TRANSPORT		:= p_ranklist(i).MODE_OF_TRANSPORT;
			l_carrier_rank_list_rec.SERVICE_LEVEL			:= p_ranklist(i).SERVICE_LEVEL	;
			l_carrier_rank_list_rec.VEHICLE_ITEM_ID			:= p_ranklist(i).VEHICLE_ITEM_ID;
			l_carrier_rank_list_rec.VEHICLE_ORG_ID			:= p_ranklist(i).VEHICLE_ORG_ID	;
			l_carrier_rank_list_rec.SOURCE				:= p_ranklist(i).SOURCE	;
			l_carrier_rank_list_rec.ESTIMATED_RATE				:= p_ranklist(i).RATE;
			l_carrier_rank_list_rec.CURRENCY_CODE			:= p_ranklist(i).CURRENCY;
			l_carrier_rank_list_rec.ESTIMATED_TRANSIT_TIME		:= p_ranklist(i).EST_TRANSIT_TIME	;
			l_carrier_rank_list_rec.TRANSIT_TIME_UOM		:= p_ranklist(i).EST_TRANSIT_TIME_UOM	;
			--l_carrier_rank_list_rec.SCHEDULE_FROM			:= p_ranklist(i).SCHEDULE_FROM		;
			--l_carrier_rank_list_rec.SCHEDULE_TO			:= p_ranklist(i).SCHEDULE_TO		;
			l_carrier_rank_list_rec.IS_CURRENT			:= p_ranklist(i).IS_CURRENT		;
			l_carrier_rank_list_rec.CONSIGNEE_CARRIER_AC_NO 	:= p_ranklist(i).CONSIGNEE_CARRIER_AC_NO;
			l_carrier_rank_list_rec.FREIGHT_TERMS_CODE		:= p_ranklist(i).FREIGHT_TERMS_CODE	;

			l_carrier_rank_list_tbl(i) := l_carrier_rank_list_rec;
		END LOOP;
	END IF;


	RANK_LIST_ACTION(
		p_api_version_number	=> p_api_version_number,
		p_init_msg_list	        => FND_API.G_FALSE,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_action_code		=> p_action_code,
		p_ranklist		=> l_carrier_rank_list_tbl,
		p_trip_id		=> p_trip_id,
		p_rank_id		=> p_rank_id);

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

	-- now send back all the information back through x_ranklist

	IF (l_carrier_rank_list_tbl IS NOT NULL
	AND l_carrier_rank_list_tbl.COUNT > 0)
	THEN

		x_ranklist := FTE_SS_RATE_SORT_TAB_TYPE();

		IF l_debug_on
		THEN
		      Log(l_module_name,' Transfering from PLSQL list to UI List ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		FOR i IN l_carrier_rank_list_tbl.FIRST..l_carrier_rank_list_tbl.LAST LOOP


			l_carrier_rank_list_rec := l_carrier_rank_list_tbl(i);
			l_return_ss_rate_sort_rec := FTE_SS_RATE_SORT_REC(
					l_carrier_rank_list_rec.RANK_ID,
					l_carrier_rank_list_rec.RANK_SEQUENCE,
					l_carrier_rank_list_rec.LANE_ID		,
					NULL,--l_carrier_rank_list_rec.SCHEDULE_ID,
					l_carrier_rank_list_rec.CARRIER_ID	,
					l_carrier_rank_list_rec.MODE_OF_TRANSPORT,
					l_carrier_rank_list_rec.SERVICE_LEVEL	,
					l_carrier_rank_list_rec.VEHICLE_ITEM_ID	,
					NULL,--l_carrier_rank_list_rec.VEHICLE_ORG_ID	,
					NULL,
					l_carrier_rank_list_rec.SOURCE	,
					l_carrier_rank_list_rec.ESTIMATED_RATE	,
					l_carrier_rank_list_rec.CURRENCY_CODE,
					l_carrier_rank_list_rec.ESTIMATED_TRANSIT_TIME,
					l_carrier_rank_list_rec.TRANSIT_TIME_UOM,
					NULL,--l_carrier_rank_list_rec.SCHEDULE_FROM		,
					NULL,--l_carrier_rank_list_rec.SCHEDULE_TO		,
					l_carrier_rank_list_rec.IS_CURRENT		,
					l_carrier_rank_list_rec.VERSION,
					NULL,
					l_carrier_rank_list_rec.CONSIGNEE_CARRIER_AC_NO ,
					l_carrier_rank_list_rec.FREIGHT_TERMS_CODE	);
			x_ranklist.EXTEND;
			x_ranklist(x_ranklist.COUNT) := l_return_ss_rate_sort_rec;

		END LOOP;
	END IF;

	p_ranklist := x_ranklist;


	x_return_status := l_return_status;

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



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO RANK_LIST_ACTION_UIWRAPPER_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO RANK_LIST_ACTION_UIWRAPPER_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	 WHEN OTHERS THEN
		ROLLBACK TO RANK_LIST_ACTION_UIWRAPPER_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION_UIWRAPPER_PUB');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


END RANK_LIST_ACTION_UIWRAPPER;


PROCEDURE GET_RANK_DETAILS(
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	x_rankdetails		OUT NOCOPY	carrier_rank_list_rec,
	p_rank_id		IN		NUMBER)
IS


l_api_name              CONSTANT VARCHAR2(30)   := 'GET_RANK_DETAILS';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

--}

l_current_version	   NUMBER;

CURSOR get_rank_details_c IS
  SELECT RANK_ID                  ,
  TRIP_ID                  ,
  RANK_SEQUENCE            ,
  CARRIER_ID		   ,
  SERVICE_LEVEL	           ,
  MODE_OF_TRANSPORT        ,
  LANE_ID                  ,
  SOURCE		   ,
  ENABLED		   ,
  ESTIMATED_RATE	   ,
  CURRENCY_CODE		   ,
  VEHICLE_ITEM_ID	   ,
  ESTIMATED_TRANSIT_TIME   ,
  TRANSIT_TIME_UOM	   ,
  VERSION		   ,
  CONSIGNEE_CARRIER_AC_NO  ,
  FREIGHT_TERMS_CODE	   ,
  INITSMCONFIG		   ,
  ATTRIBUTE_CATEGORY       ,
  ATTRIBUTE1               ,
  ATTRIBUTE2               ,
  ATTRIBUTE3               ,
  ATTRIBUTE4               ,
  ATTRIBUTE5               ,
  ATTRIBUTE6               ,
  ATTRIBUTE7               ,
  ATTRIBUTE8               ,
  ATTRIBUTE9               ,
  ATTRIBUTE10              ,
  ATTRIBUTE11              ,
  ATTRIBUTE12              ,
  ATTRIBUTE13              ,
  ATTRIBUTE14              ,
  ATTRIBUTE15              ,
  CREATION_DATE            ,
  CREATED_BY               ,
  LAST_UPDATE_DATE         ,
  LAST_UPDATED_BY          ,
  LAST_UPDATE_LOGIN        ,
  'N',0,'SORT',NULL,NULL,-99,VEHICLE_ORG_ID,
  CALL_RG_FLAG
FROM FTE_CARRIER_RANK_LIST WHERE RANK_ID = p_rank_id;

BEGIN


	SAVEPOINT   GET_RANK_DETAILS_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	OPEN  get_rank_details_c;
	FETCH get_rank_details_c INTO x_rankdetails;

	IF (get_rank_details_c%NOTFOUND) THEN
	FND_MESSAGE.SET_NAME('FTE','FTE_RANK_NOT_FOUND');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		wsh_util_core.add_message(x_return_status);
	ELSE
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	END IF;

	CLOSE get_rank_details_c;


	--
	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO GET_RANK_DETAILS_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO GET_RANK_DETAILS_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	 WHEN OTHERS THEN
		ROLLBACK TO GET_RANK_DETAILS_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.GET_RANK_DETAILS');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


END GET_RANK_DETAILS;
--

PROCEDURE GET_RANK_LIST(
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	x_ranklist		OUT NOCOPY	carrier_rank_list_tbl_type,
	p_trip_id		IN		NUMBER)
IS


l_api_name              CONSTANT VARCHAR2(30)   := 'GET_RANK_LIST';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;
l_carrier_rank_list_rec		carrier_rank_list_rec;

--}

l_current_version	   NUMBER;

CURSOR get_rank_list_c IS
  SELECT RANK_ID           ,
  TRIP_ID                  ,
  RANK_SEQUENCE            ,
  CARRIER_ID		   ,
  SERVICE_LEVEL	           ,
  MODE_OF_TRANSPORT        ,
  LANE_ID                  ,
  SOURCE		   ,
  ENABLED		   ,
  ESTIMATED_RATE	   ,
  CURRENCY_CODE		   ,
  VEHICLE_ITEM_ID	   ,
  ESTIMATED_TRANSIT_TIME   ,
  TRANSIT_TIME_UOM	   ,
  VERSION		   ,
  CONSIGNEE_CARRIER_AC_NO  ,
  FREIGHT_TERMS_CODE	   ,
  INITSMCONFIG		   ,
  ATTRIBUTE_CATEGORY       ,
  ATTRIBUTE1               ,
  ATTRIBUTE2               ,
  ATTRIBUTE3               ,
  ATTRIBUTE4               ,
  ATTRIBUTE5               ,
  ATTRIBUTE6               ,
  ATTRIBUTE7               ,
  ATTRIBUTE8               ,
  ATTRIBUTE9               ,
  ATTRIBUTE10              ,
  ATTRIBUTE11              ,
  ATTRIBUTE12              ,
  ATTRIBUTE13              ,
  ATTRIBUTE14              ,
  ATTRIBUTE15              ,
  CREATION_DATE            ,
  CREATED_BY               ,
  LAST_UPDATE_DATE         ,
  LAST_UPDATED_BY          ,
  LAST_UPDATE_LOGIN        ,
  'N' IS_CURRENT,NULL SINGLE_CURR_RATE,NULL SORT,NULL SCHEDULE_FROM,NULL SCHEDULE_TO,NULL SCHEDULE_ID,
  VEHICLE_ORG_ID,
  CALL_RG_FLAG
FROM FTE_CARRIER_RANK_LIST WHERE trip_id = p_trip_id
ORDER BY RANK_ID, RANK_SEQUENCE;

idx	NUMBER;
BEGIN


	SAVEPOINT   GET_RANK_LIST_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	IF l_debug_on
	THEN
	      Log(l_module_name,' Getting rank list for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	idx := 1;
	FOR get_rank_list_rec IN get_rank_list_c
		LOOP
		--{
			--l_carrier_rank_list_rec := get_rank_list_rec;
  l_carrier_rank_list_rec.RANK_ID                   	:= get_rank_list_rec.RANK_ID;
  l_carrier_rank_list_rec.TRIP_ID                   	:= get_rank_list_rec.TRIP_ID;
  l_carrier_rank_list_rec.RANK_SEQUENCE             	:= get_rank_list_rec.RANK_SEQUENCE ;
  l_carrier_rank_list_rec.CARRIER_ID		    	:= get_rank_list_rec.CARRIER_ID	;
  l_carrier_rank_list_rec.SERVICE_LEVEL	            	:= get_rank_list_rec.SERVICE_LEVEL;
  l_carrier_rank_list_rec.MODE_OF_TRANSPORT         	:= get_rank_list_rec.MODE_OF_TRANSPORT;
  l_carrier_rank_list_rec.LANE_ID                   	:= get_rank_list_rec.LANE_ID          ;
  l_carrier_rank_list_rec.SOURCE		    	:= get_rank_list_rec.SOURCE		 ;
  l_carrier_rank_list_rec.ENABLED		    	:= get_rank_list_rec.ENABLED		 ;
  l_carrier_rank_list_rec.ESTIMATED_RATE	    	:= get_rank_list_rec.ESTIMATED_RATE	 ;
  l_carrier_rank_list_rec.CURRENCY_CODE		    	:= get_rank_list_rec.CURRENCY_CODE	;
  l_carrier_rank_list_rec.VEHICLE_ITEM_ID	    	:= get_rank_list_rec.VEHICLE_ITEM_ID	 ;
  l_carrier_rank_list_rec.ESTIMATED_TRANSIT_TIME    	:= get_rank_list_rec.ESTIMATED_TRANSIT_TIME    ;
  l_carrier_rank_list_rec.TRANSIT_TIME_UOM	    	:= get_rank_list_rec.TRANSIT_TIME_UOM	  ;
  l_carrier_rank_list_rec.VERSION		    	:= get_rank_list_rec.VERSION		    ;
  l_carrier_rank_list_rec.CONSIGNEE_CARRIER_AC_NO   	:= get_rank_list_rec.CONSIGNEE_CARRIER_AC_NO   ;
  l_carrier_rank_list_rec.FREIGHT_TERMS_CODE	    	:= get_rank_list_rec.FREIGHT_TERMS_CODE	  ;
  l_carrier_rank_list_rec.INITSMCONFIG		    	:= get_rank_list_rec.INITSMCONFIG		  ;
  l_carrier_rank_list_rec.ATTRIBUTE_CATEGORY        	:= get_rank_list_rec.ATTRIBUTE_CATEGORY        ;
  l_carrier_rank_list_rec.ATTRIBUTE1                	:= get_rank_list_rec.ATTRIBUTE1                ;
  l_carrier_rank_list_rec.ATTRIBUTE2                	:= get_rank_list_rec.ATTRIBUTE2                ;
  l_carrier_rank_list_rec.ATTRIBUTE3                	:= get_rank_list_rec.ATTRIBUTE3                ;
  l_carrier_rank_list_rec.ATTRIBUTE4                	:= get_rank_list_rec.ATTRIBUTE4                ;
  l_carrier_rank_list_rec.ATTRIBUTE5                	:= get_rank_list_rec.ATTRIBUTE5                ;
  l_carrier_rank_list_rec.ATTRIBUTE6                	:= get_rank_list_rec.ATTRIBUTE6                ;
  l_carrier_rank_list_rec.ATTRIBUTE7                	:= get_rank_list_rec.ATTRIBUTE7                ;
  l_carrier_rank_list_rec.ATTRIBUTE8                	:= get_rank_list_rec.ATTRIBUTE8                ;
  l_carrier_rank_list_rec.ATTRIBUTE9                	:= get_rank_list_rec.ATTRIBUTE9                ;
  l_carrier_rank_list_rec.ATTRIBUTE10               	:= get_rank_list_rec.ATTRIBUTE10               ;
  l_carrier_rank_list_rec.ATTRIBUTE11               	:= get_rank_list_rec.ATTRIBUTE11               ;
  l_carrier_rank_list_rec.ATTRIBUTE12               	:= get_rank_list_rec.ATTRIBUTE12               ;
  l_carrier_rank_list_rec.ATTRIBUTE13               	:= get_rank_list_rec.ATTRIBUTE13               ;
  l_carrier_rank_list_rec.ATTRIBUTE14               	:= get_rank_list_rec.ATTRIBUTE14               ;
  l_carrier_rank_list_rec.ATTRIBUTE15               	:= get_rank_list_rec.ATTRIBUTE15               ;
  l_carrier_rank_list_rec.CREATION_DATE             	:= get_rank_list_rec.CREATION_DATE             ;
  l_carrier_rank_list_rec.CREATED_BY                	:= get_rank_list_rec.CREATED_BY                ;
  l_carrier_rank_list_rec.LAST_UPDATE_DATE          	:= get_rank_list_rec.LAST_UPDATE_DATE          ;
  l_carrier_rank_list_rec.LAST_UPDATED_BY           	:= get_rank_list_rec.LAST_UPDATED_BY           ;
  l_carrier_rank_list_rec.LAST_UPDATE_LOGIN         	:= get_rank_list_rec.LAST_UPDATE_LOGIN         ;
  l_carrier_rank_list_rec.IS_CURRENT		    	:= get_rank_list_rec.IS_CURRENT		  ;
  l_carrier_rank_list_rec.SINGLE_CURR_RATE		:= get_rank_list_rec.SINGLE_CURR_RATE	;
  l_carrier_rank_list_rec.SORT				:= get_rank_list_rec.SORT			;
  l_carrier_rank_list_rec.SCHEDULE_FROM			:= get_rank_list_rec.SCHEDULE_FROM		;
  l_carrier_rank_list_rec.SCHEDULE_TO			:= get_rank_list_rec.SCHEDULE_TO		;
  l_carrier_rank_list_rec.SCHEDULE_ID			:= get_rank_list_rec.SCHEDULE_ID		;
  l_carrier_rank_list_rec.VEHICLE_ORG_ID		:= get_rank_list_rec.VEHICLE_ORG_ID	;
  l_carrier_rank_list_rec.CALL_RG_FLAG		:= get_rank_list_rec.CALL_RG_FLAG;

			x_ranklist(idx) := l_carrier_rank_list_rec;
			idx := idx+1;

		--}
		END LOOP;

	-- END OF
	IF get_rank_list_c%ISOPEN THEN
	  CLOSE get_rank_list_c;
	END IF;
	--

	IF l_debug_on
	THEN
	      Log(l_module_name,' Done getting rank list for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO GET_RANK_LIST_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO GET_RANK_LIST_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	 WHEN OTHERS THEN
		ROLLBACK TO GET_RANK_LIST_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.GET_RANK_LIST');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


END GET_RANK_LIST;



PROCEDURE REMOVE_SERVICE_APPLY_NEXT(
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_trip_id		IN		NUMBER,
	p_price_request_id	IN		NUMBER)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'REMOVE_SERVICE_APPLY_NEXT';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_rank_rec		    carrier_rank_list_rec;
x_list_tbl      	    FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_list_tbl		    FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;

l_current_rank_sequence 	NUMBER;

l_list_exhausted	    VARCHAR2(32767);
l_trip_name			WSH_TRIPS.NAME%TYPE;

--{Trip update parameters
  p_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
  p_trip_info 		WSH_TRIPS_PVT.Trip_Rec_Type;
  p_trip_in_rec 	WSH_TRIPS_GRP.TripInRecType;
  x_out_tab 		WSH_TRIPS_GRP.trip_Out_tab_type;
--}



CURSOR get_next_rank(p_current_sequence NUMBER) IS
		  SELECT RANK_ID           ,
		  TRIP_ID                  ,
		  RANK_SEQUENCE            ,
		  CARRIER_ID		   ,
		  SERVICE_LEVEL	           ,
		  MODE_OF_TRANSPORT        ,
		  LANE_ID                  ,
		  SOURCE		   ,
		  ENABLED		   ,
		  ESTIMATED_RATE	   ,
		  CURRENCY_CODE		   ,
		  VEHICLE_ITEM_ID	   ,
		  ESTIMATED_TRANSIT_TIME   ,
		  TRANSIT_TIME_UOM	   ,
		  VERSION		   ,
		  CONSIGNEE_CARRIER_AC_NO  ,
		  FREIGHT_TERMS_CODE	   ,
		  INITSMCONFIG		   ,
		  ATTRIBUTE_CATEGORY       ,
		  ATTRIBUTE1               ,
		  ATTRIBUTE2               ,
		  ATTRIBUTE3               ,
		  ATTRIBUTE4               ,
		  ATTRIBUTE5               ,
		  ATTRIBUTE6               ,
		  ATTRIBUTE7               ,
		  ATTRIBUTE8               ,
		  ATTRIBUTE9               ,
		  ATTRIBUTE10              ,
		  ATTRIBUTE11              ,
		  ATTRIBUTE12              ,
		  ATTRIBUTE13              ,
		  ATTRIBUTE14              ,
		  ATTRIBUTE15              ,
		  CREATION_DATE            ,
		  CREATED_BY               ,
		  LAST_UPDATE_DATE         ,
		  LAST_UPDATED_BY          ,
		  LAST_UPDATE_LOGIN        ,
  'N' IS_CURRENT,NULL SINGLE_CURR_RATE,NULL SORT,NULL SCHEDULE_FROM,NULL SCHEDULE_TO,NULL SCHEDULE_ID,
  VEHICLE_ORG_ID,CALL_RG_FLAG
	  FROM FTE_CARRIER_RANK_LIST rank_list
	  WHERE rank_list.trip_id = p_trip_id
	  AND 	rank_list.RANK_SEQUENCE = (p_current_sequence+1);

BEGIN


	SAVEPOINT   REMOVE_SERVICE_APPLY_NEXT_PUB;
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
	l_msg_data		:= 0;


	l_list_exhausted := 'F';
	IF l_debug_on
	THEN
	      Log(l_module_name,' Check current rank sequence ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	BEGIN


		SELECT RANK_SEQUENCE INTO l_current_rank_sequence
		FROM FTE_CARRIER_RANK_LIST rank_list, WSH_TRIPS trips
		WHERE trips.trip_id = p_trip_id
		AND trips.RANK_ID = rank_list.RANK_ID;

		IF (SQL%NOTFOUND) THEN
			RAISE NO_DATA_FOUND;
		END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   FND_MESSAGE.SET_NAME('FTE','FTE_RANK_NOT_FOUND');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
		   RAISE FND_API.G_EXC_ERROR;
	END;

	IF l_debug_on
	THEN
	      Log(l_module_name,' Current rank sequence  ' || l_current_rank_sequence,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


		--Get the next shipmethod in the sequence based on current sequence

	OPEN  get_next_rank(l_current_rank_sequence);
	FETCH get_next_rank INTO l_rank_rec;

	IF l_debug_on
	THEN
	      Log(l_module_name,' Executed rank query ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (get_next_rank%NOTFOUND) THEN
		SELECT NAME INTO l_trip_name from WSH_TRIPS
		WHERE TRIP_ID = p_trip_id;

		FND_MESSAGE.SET_NAME('FTE','FTE_RANK_LIST_EXAUSTED');
		FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);

		l_list_exhausted := 'T';
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
		wsh_util_core.add_message(x_return_status);
	END IF;

	CLOSE get_next_rank;


	IF (l_list_exhausted = 'T')
	THEN
	--{

		IF l_debug_on
		THEN
		      Log(l_module_name,' Rank list exhausted so nothing to do ' ,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
	--}
	ELSE
	--{

		-- First cancel service
		IF l_debug_on
		THEN
		      Log(l_module_name,' cancel service on the trip. Also get rid of rates ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		IF l_debug_on
		THEN
		      Log(l_module_name,' Now update trip with next shipmethod ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Carrier Id ' || l_rank_rec.CARRIER_ID,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Service Level ' || l_rank_rec.SERVICE_LEVEL,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Mode Of Transport ' || l_rank_rec.MODE_OF_TRANSPORT,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Lane Id ' || l_rank_rec.LANE_ID,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Freight Terms Code ' || l_rank_rec.FREIGHT_TERMS_CODE,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		      Log(l_module_name,' Consignee carrier ac no ' || l_rank_rec.CONSIGNEE_CARRIER_AC_NO,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		-- Call shipping API to update trip information with next shipmethod
		/**
		UPDATE WSH_TRIPS
		SET 	CARRIER_ID = l_rank_rec.CARRIER_ID,
			SERVICE_LEVEL = l_rank_rec.SERVICE_LEVEL,
			MODE_OF_TRANSPORT = l_rank_rec.MODE_OF_TRANSPORT,
			VEHICLE_ITEM_ID = l_rank_rec.VEHICLE_ITEM_ID,
			VEHICLE_ORGANIZATION_ID	= l_rank_rec.VEHICLE_ORG_ID,
			LANE_ID = l_rank_rec.LANE_ID,
			FREIGHT_TERMS_CODE = l_rank_rec.FREIGHT_TERMS_CODE,
			CONSIGNEE_CARRIER_AC_NO = l_rank_rec.CONSIGNEE_CARRIER_AC_NO
		WHERE	TRIP_ID = p_trip_id;
		*/

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' Calling UPDATE_SERVICE_ON_TRIP ' ||
						l_return_status,
					  WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		FTE_MLS_WRAPPER.UPDATE_SERVICE_ON_TRIP(
			p_API_VERSION_NUMBER	=> 1.0,
			p_INIT_MSG_LIST		=> FND_API.G_FALSE,
			p_COMMIT		=> FND_API.G_FALSE,
			p_CALLER		=> 'FTE_LOAD_TENDER',
			p_SERVICE_ACTION	=> 'UPDATE',
			p_DELIVERY_ID		=> null,
			p_DELIVERY_LEG_ID	=> null,
			p_TRIP_ID		=> p_trip_id,
			p_LANE_ID		=> l_rank_rec.LANE_ID,
			p_SCHEDULE_ID		=> l_rank_rec.SCHEDULE_ID,
			p_CARRIER_ID		=> l_rank_rec.CARRIER_ID,
			p_SERVICE_LEVEL		=> l_rank_rec.SERVICE_LEVEL,
			p_MODE_OF_TRANSPORT	=> l_rank_rec.MODE_OF_TRANSPORT,
			p_VEHICLE_ITEM_ID	=> l_rank_rec.VEHICLE_ITEM_ID,
			p_VEHICLE_ORG_ID	=> l_rank_rec.VEHICLE_ORG_ID,
			p_CONSIGNEE_CARRIER_AC_NO => l_rank_rec.CONSIGNEE_CARRIER_AC_NO,
			p_FREIGHT_TERMS_CODE	=> l_rank_rec.FREIGHT_TERMS_CODE,
			x_RETURN_STATUS		=> l_return_status,
			x_MSG_COUNT		=> l_msg_count,
			x_MSG_DATA		=> l_msg_data);

		IF l_debug_on
		THEN
		      WSH_DEBUG_SV.logmsg(l_module_name,' REturn value from UPDATE_SERVICE_ON_TRIP ' ||
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


		IF (p_price_request_id IS NOT NULL)
		THEN
			IF l_debug_on
			THEN
			      Log(l_module_name,' Price request is not null so call move ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

 			FTE_TRIP_RATING_GRP.Move_Records_To_Main (p_trip_id          => p_trip_id,
                                               			  p_lane_id          => l_rank_rec.LANE_ID,
                                               			  p_schedule_id      => l_rank_rec.SCHEDULE_ID,
                                               			  p_service_type_code => l_rank_rec.SERVICE_LEVEL,
                                               			  p_comparison_request_id => p_price_request_id,
                                               			  x_return_status    => l_return_status);

			IF l_debug_on
			THEN
			      Log(l_module_name,' After calling move rates ' || l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors);

		ELSE
			IF l_debug_on
			THEN
			      Log(l_module_name,' Price request is null so call re-price ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			FTE_MLS_WRAPPER.REPRICE_TRIP(p_api_version => 1.0,
							p_init_msg_list => FND_API.G_FALSE,
							p_trip_id	=> p_trip_id,
							x_return_status => l_return_status,
							x_msg_count     => l_msg_count,
							x_msg_data      => l_msg_data);

			IF l_debug_on
			THEN
			      Log(l_module_name,' After calling reprice trip ' || l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			IF l_debug_on
			THEN
			      Log(l_module_name,' Number of errors ' || l_number_of_errors,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			      Log(l_module_name,' l_msg_data ' || l_msg_data,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			      Log(l_module_name,' Continue even if rating failed ',
						WSH_DEBUG_SV.C_PROC_LEVEL);

			END IF;

			-- Continue even if rating failed
			/**
			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);
			**/
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

		l_list_tbl(1) := l_rank_rec;

		IF l_debug_on
		THEN
		      Log(l_module_name,' Before Calling Rank List Action to set current ' ||
						l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		RANK_LIST_ACTION(
			p_api_version_number	=> 1.0,
			p_init_msg_list	        => FND_API.G_FALSE,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data,
			p_action_code		=> FTE_CARRIER_RANK_LIST_PVT.S_SET_CURRENT,
			p_ranklist		=> l_list_tbl,
			p_trip_id		=> p_trip_id,
			p_rank_id		=> l_rank_rec.RANK_ID);


		IF l_debug_on
		THEN
		      Log(l_module_name,' Result FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION ' ||
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
	ROLLBACK TO REMOVE_SERVICE_APPLY_NEXT_PUB;
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
	ROLLBACK TO REMOVE_SERVICE_APPLY_NEXT_PUB;
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
	ROLLBACK TO REMOVE_SERVICE_APPLY_NEXT_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.REMOVE_SERVICE_APPLY_NEXT');
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

END REMOVE_SERVICE_APPLY_NEXT;


PROCEDURE IS_RANK_LIST_EXHAUSTED(
	p_init_msg_list	        IN   		VARCHAR2,
	x_is_exhausted		OUT NOCOPY	VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_trip_id		IN		NUMBER)
IS

l_api_name              CONSTANT VARCHAR2(30)   := 'IS_RANK_LIST_EXHAUSTED';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_count 		    NUMBER;



BEGIN


	SAVEPOINT   IS_RANK_LIST_EXHAUSTED_PUB;
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


	x_is_exhausted := 'F';

	BEGIN


		SELECT COUNT(*) INTO l_count FROM FTE_CARRIER_RANK_LIST
		WHERE (VERSION IS NULL OR VERSION = 0)
		AND trip_id = p_trip_id;

		IF (SQL%NOTFOUND) THEN
		   RAISE NO_DATA_FOUND;
		END IF;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   FND_MESSAGE.SET_NAME('FTE','FTE_RANK_NOT_FOUND');
		   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
		   RAISE FND_API.G_EXC_ERROR;

	END;

	IF l_debug_on
	THEN
	      Log(l_module_name,' Remaining Services in the rank list  ' || l_count,
	      		WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (l_count = 0)
	THEN
		x_is_exhausted := 'T';
		IF l_debug_on
		THEN
		      Log(l_module_name,' Carrier rank list exhausted ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
	ELSE
		IF l_debug_on
		THEN
		      Log(l_module_name,' Carrier rank list not exhausted ',
						WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

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
	ROLLBACK TO IS_RANK_LIST_EXHAUSTED_PUB;
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
	ROLLBACK TO IS_RANK_LIST_EXHAUSTED_PUB;
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
	ROLLBACK TO IS_RANK_LIST_EXHAUSTED_PUB;
	wsh_util_core.default_handler('FTE_SS_INTERFACE.REMOVE_SERVICE_APPLY_NEXT');
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

END IS_RANK_LIST_EXHAUSTED;


PROCEDURE PRINT_RANK_LIST(p_trip_id		IN		NUMBER)
IS


l_api_name              CONSTANT VARCHAR2(30)   := 'PRINT_RANK_LIST';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


l_return_status             VARCHAR2(32767);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(32767);
l_number_of_warnings	    NUMBER;
l_number_of_errors	    NUMBER;

l_result_code			VARCHAR2(32767);
l_rank_id			NUMBER;

--}

l_current_version	   NUMBER;

CURSOR get_rank_list_c IS
  SELECT RANK_ID           ,
  TRIP_ID                  ,
  RANK_SEQUENCE            ,
  CARRIER_ID		   ,
  SERVICE_LEVEL	           ,
  MODE_OF_TRANSPORT        ,
  LANE_ID                  ,
  SOURCE		   ,
  ENABLED		   ,
  ESTIMATED_RATE	   ,
  CURRENCY_CODE		   ,
  VEHICLE_ITEM_ID	   ,
  VEHICLE_ORG_ID	   ,
  ESTIMATED_TRANSIT_TIME   ,
  TRANSIT_TIME_UOM	   ,
  VERSION		   ,
  CONSIGNEE_CARRIER_AC_NO  ,
  FREIGHT_TERMS_CODE	   ,
  INITSMCONFIG		   ,
  ATTRIBUTE_CATEGORY       ,
  ATTRIBUTE1               ,
  ATTRIBUTE2               ,
  ATTRIBUTE3               ,
  ATTRIBUTE4               ,
  ATTRIBUTE5               ,
  ATTRIBUTE6               ,
  ATTRIBUTE7               ,
  ATTRIBUTE8               ,
  ATTRIBUTE9               ,
  ATTRIBUTE10              ,
  ATTRIBUTE11              ,
  ATTRIBUTE12              ,
  ATTRIBUTE13              ,
  ATTRIBUTE14              ,
  ATTRIBUTE15              ,
  CREATION_DATE            ,
  CREATED_BY               ,
  LAST_UPDATE_DATE         ,
  LAST_UPDATED_BY          ,
  LAST_UPDATE_LOGIN        ,
  'N'
FROM FTE_CARRIER_RANK_LIST WHERE trip_id = p_trip_id
ORDER BY RANK_ID , RANK_SEQUENCE;

idx	NUMBER;

BEGIN


	SAVEPOINT   PRINT_RANK_LIST_PUB;
	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	IF l_debug_on
	THEN
	      Log(l_module_name,' Getting rank list for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	idx := 1;
	FOR p_rank_info_rec IN get_rank_list_c
		LOOP
		--{

		IF l_debug_on
		THEN
Log(l_module_name,' p_rank_info_rec.RANK_ID 			 ' || p_rank_info_rec.RANK_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.TRIP_ID 			 ' || p_rank_info_rec.TRIP_ID			,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.RANK_SEQUENCE		 ' || p_rank_info_rec.RANK_SEQUENCE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CARRIER_ID		 	 ' || p_rank_info_rec.CARRIER_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.SERVICE_LEVEL		 ' || p_rank_info_rec.SERVICE_LEVEL,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.MODE_OF_TRANSPORT	 	 ' || p_rank_info_rec.MODE_OF_TRANSPORT,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.LANE_ID			 ' || p_rank_info_rec.LANE_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.SOURCE			 ' || p_rank_info_rec.SOURCE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.ESTIMATED_RATE		 ' || p_rank_info_rec.ESTIMATED_RATE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CURRENCY_CODE		 ' || p_rank_info_rec.CURRENCY_CODE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.VEHICLE_ITEM_ID		 ' || p_rank_info_rec.VEHICLE_ITEM_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.VEHICLE_ORG_ID		 ' || p_rank_info_rec.VEHICLE_ORG_ID,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.ESTIMATED_TRANSIT_TIME	 ' || p_rank_info_rec.ESTIMATED_TRANSIT_TIME,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.TRANSIT_TIME_UOM	 	 ' || p_rank_info_rec.TRANSIT_TIME_UOM,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO	 ' || p_rank_info_rec.CONSIGNEE_CARRIER_AC_NO,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' p_rank_info_rec.FREIGHT_TERMS_CODE	 	 ' || p_rank_info_rec.FREIGHT_TERMS_CODE,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' l_config				 	 ' || p_rank_info_rec.INITSMCONFIG ,WSH_DEBUG_SV.C_PROC_LEVEL);
Log(l_module_name,' ********************************************* ' ,WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
		--}
		END LOOP;

	-- END OF
	IF get_rank_list_c%ISOPEN THEN
	  CLOSE get_rank_list_c;
	END IF;
	--

	IF l_debug_on
	THEN
	      Log(l_module_name,' Done getting rank list for trip ' || p_trip_id,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	--

	IF l_debug_on THEN
	      WSH_DEBUG_SV.pop(l_module_name);
	END IF;



EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO PRINT_RANK_LIST_PUB;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO PRINT_RANK_LIST_PUB;
	 WHEN OTHERS THEN
		ROLLBACK TO PRINT_RANK_LIST_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.PRINT_RANK_LIST');
END PRINT_RANK_LIST;


--{

PROCEDURE DELETE_RANK_LIST_UIWRAPPER(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_trip_id		IN		FTE_ID_TAB_TYPE)
IS

l_warning_tab	FTE_ID_TAB_TYPE;
l_error_tab	FTE_ID_TAB_TYPE;
l_success_tab	FTE_ID_TAB_TYPE;

l_return_status	VARCHAR2(1);

l_trip_names	VARCHAR2(4000);
l_temp_name	VARCHAR2(100);

l_api_name              CONSTANT VARCHAR2(30)   := 'DELETE_RANK_LIST_UIWRAPPER';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;


BEGIN

	SAVEPOINT   DELETE_RANK_LIST_UIWRAPPER_PUB;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF l_debug_on
	THEN
	      Log(l_module_name,' Delete rank list ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	l_warning_tab	:= FTE_ID_TAB_TYPE();
	l_error_tab	:= FTE_ID_TAB_TYPE();
	l_success_tab	:= FTE_ID_TAB_TYPE();


	IF (p_trip_id.COUNT > 0)
	THEN
		-- loop through each trip and call delete
		FOR i IN p_trip_id.FIRST..p_trip_id.LAST LOOP

			IF l_debug_on
			THEN
			      Log(l_module_name,' Calling DELETE_RANK_LIST for trip ' || p_trip_id(i) ,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;

			DELETE_RANK_LIST(p_trip_id		=> p_trip_id(i),
				x_return_status		=> l_return_status);


			IF l_debug_on
			THEN
			      Log(l_module_name,' Return message after delete rank for trip ' || p_trip_id(i) || ' ' ||
			      			l_return_status,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
			THEN
			    l_error_tab.EXTEND;
			    l_error_tab(l_error_tab.COUNT) := p_trip_id(i);
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

			    -- Get the trip name
			    SELECT NAME INTO l_temp_name FROM WSH_TRIPS
			    WHERE TRIP_ID = p_trip_id(i);

			    l_trip_names := l_trip_names || ', ' || l_temp_name;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING)
			THEN
			    l_warning_tab.EXTEND;
			    l_warning_tab(l_warning_tab.COUNT) := p_trip_id(i);
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS)
			THEN
			    l_success_tab.EXTEND;
			    l_success_tab(l_success_Tab.COUNT) := p_trip_id(i);
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			ELSE
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;


		END LOOP;
	ELSE

		IF l_debug_on
		THEN
		      Log(l_module_name,' Trip id table is empty ',
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

	END IF;

	IF l_debug_on
	THEN
	      Log(l_module_name,' Success count ' || l_success_tab.count,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      Log(l_module_name,' Error count  ' || l_error_tab.count,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      Log(l_module_name,' Warning count  ' || l_warning_tab.count,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	      Log(l_module_name,' Trip count  ' || p_trip_id.count,
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (l_success_tab.count = p_trip_id.count)
	THEN
		--FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_RANK_DEL_SUCCESS');
		--FND_MSG_PUB.ADD;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	ELSIF (l_error_tab.count = p_trip_id.count)
	THEN
		FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_RANK_DEL_FAIL');
		FND_MESSAGE.SET_TOKEN('TRIP_NAMES', l_trip_names);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	ELSE
		FND_MESSAGE.SET_NAME('FTE','FTE_MULTI_RANK_DEL_WARN');
		FND_MESSAGE.SET_TOKEN('TRIP_NAMES', l_trip_names);
		FND_MSG_PUB.ADD;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO DELETE_RANK_LIST_UIWRAPPER_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO DELETE_RANK_LIST_UIWRAPPER_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	 WHEN OTHERS THEN
		ROLLBACK TO DELETE_RANK_LIST_UIWRAPPER_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.DELETE_RANK_LIST_UIWRAPPER');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


END DELETE_RANK_LIST_UIWRAPPER;


--}



--{

PROCEDURE CREATE_RANK_LIST_BULK(
	p_api_version_number	IN		NUMBER,
	p_init_msg_list	        IN   		VARCHAR2,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	p_ranklist		IN OUT	NOCOPY	carrier_rank_list_bulk_rec)
IS

l_return_status	VARCHAR2(1);

l_trip_names	VARCHAR2(4000);
l_temp_name	VARCHAR2(100);
l_trip_id	NUMBER;
l_trip_name     VARCHAR2(100);

l_api_name              CONSTANT VARCHAR2(30)   := 'CREATE_RANK_LIST_BULK';
l_api_version           CONSTANT NUMBER         := 1.0;
l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || l_api_name;

l_temp_table carrier_rank_list_bulk_rec;

CURSOR get_trip (trip_id NUMBER) IS
	SELECT trip_id FROM FTE_CARRIER_RANK_LIST
	WHERE TRIP_ID = trip_id
	AND ROWNUM = 1;

idx	NUMBER;

BEGIN

	SAVEPOINT   CREATE_RANK_LIST_BULK_PUB;

	IF l_debug_on THEN
	      WSH_DEBUG_SV.push(l_module_name);
	END IF;


	x_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;

	IF l_debug_on
	THEN
	      Log(l_module_name,' Loop through all the rank list table and check failure cases ',
				WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	idx := 1;
	FOR i IN p_ranklist.TRIP_ID.FIRST..p_ranklist.TRIP_ID.LAST
	LOOP

		IF l_debug_on
		THEN
		      Log(l_module_name,' Trip Id ' || p_ranklist.TRIP_ID(i) || ' i value ' || i,
					WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;


		BEGIN

			SELECT trip_id INTO l_trip_id
				FROM FTE_CARRIER_RANK_LIST
			WHERE TRIP_ID = p_ranklist.TRIP_ID(i)
			AND ROWNUM = 1;

			IF (SQL%NOTFOUND) THEN
				RAISE NO_DATA_FOUND;
			ELSE

				IF l_debug_on
				THEN
				      Log(l_module_name,' Rank list exist for trip  ' || p_ranklist.TRIP_ID(i),
							WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;

				SELECT NAME INTO l_trip_name FROM WSH_TRIPS WHERE TRIP_ID = p_ranklist.TRIP_ID(i);
				l_trip_names := l_trip_names || ', ' || l_trip_name;
			END IF;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN

			SELECT FTE_CARRIER_RANK_LIST_S.NEXTVAL INTO
				p_ranklist.RANK_ID(i) FROM DUAL;

			IF l_debug_on
			THEN
			      Log(l_module_name,' Rank Id ' || p_ranklist.RANK_ID(i) || ' i value ' || i,
						WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;


			l_temp_table.RANK_ID(idx) := 		p_ranklist.RANK_ID(i);
			l_temp_table.TRIP_ID(idx)                := p_ranklist.TRIP_ID(i);
			l_temp_table.RANK_SEQUENCE(idx)             := p_ranklist.RANK_SEQUENCE(i);
			l_temp_table.CARRIER_ID(idx)		       := p_ranklist.CARRIER_ID(i);
			l_temp_table.SERVICE_LEVEL(idx)	       := p_ranklist.SERVICE_LEVEL(i);
			l_temp_table.MODE_OF_TRANSPORT(idx)         := p_ranklist.MODE_OF_TRANSPORT(i);
			l_temp_table.LANE_ID(idx)                   := p_ranklist.LANE_ID(i);
			l_temp_table.SOURCE(idx)		       := p_ranklist.SOURCE(i);
			l_temp_table.ESTIMATED_RATE(idx)	       := p_ranklist.ESTIMATED_RATE(i);
			l_temp_table.CURRENCY_CODE(idx)		:= p_ranklist.CURRENCY_CODE(i);
			l_temp_table.VEHICLE_ITEM_ID(idx)	       := p_ranklist.VEHICLE_ITEM_ID(i);
			l_temp_table.VEHICLE_ORG_ID(idx)	       := p_ranklist.VEHICLE_ORG_ID(i);
			l_temp_table.ESTIMATED_TRANSIT_TIME(idx)    := p_ranklist.ESTIMATED_TRANSIT_TIME(i);
			l_temp_table.TRANSIT_TIME_UOM(idx)	       := p_ranklist.TRANSIT_TIME_UOM(i);
			l_temp_table.CONSIGNEE_CARRIER_AC_NO(idx)   := p_ranklist.CONSIGNEE_CARRIER_AC_NO(i);
			l_temp_table.FREIGHT_TERMS_CODE(idx)	    	:= p_ranklist.FREIGHT_TERMS_CODE(i);
			l_temp_table.ATTRIBUTE_CATEGORY(idx)        := p_ranklist.ATTRIBUTE_CATEGORY(i);
			l_temp_table.ATTRIBUTE1(idx)                := p_ranklist.ATTRIBUTE1(i);
			l_temp_table.ATTRIBUTE2(idx)                := p_ranklist.ATTRIBUTE2(i);
			l_temp_table.ATTRIBUTE3(idx)                := p_ranklist.ATTRIBUTE3(i);
			l_temp_table.ATTRIBUTE4(idx)                := p_ranklist.ATTRIBUTE4(i);
			l_temp_table.ATTRIBUTE5(idx)                := p_ranklist.ATTRIBUTE5(i);
			l_temp_table.ATTRIBUTE6(idx)                := p_ranklist.ATTRIBUTE6(i);
			l_temp_table.ATTRIBUTE7(idx)                := p_ranklist.ATTRIBUTE7(i);
			l_temp_table.ATTRIBUTE8(idx)                := p_ranklist.ATTRIBUTE8(i);
			l_temp_table.ATTRIBUTE9(idx)                := p_ranklist.ATTRIBUTE9(i);
			l_temp_table.ATTRIBUTE10(idx)               := p_ranklist.ATTRIBUTE10(i);
			l_temp_table.ATTRIBUTE11(idx)               := p_ranklist.ATTRIBUTE11(i);
			l_temp_table.ATTRIBUTE12(idx)               := p_ranklist.ATTRIBUTE12(i);
			l_temp_table.ATTRIBUTE13(idx)               := p_ranklist.ATTRIBUTE13(i);
			l_temp_table.ATTRIBUTE14(idx)               := p_ranklist.ATTRIBUTE14(i);
			l_temp_table.ATTRIBUTE15(idx)               := p_ranklist.ATTRIBUTE15(i);

			idx := idx+1;
		END;


	END LOOP;

	IF l_debug_on
	THEN
	      Log(l_module_name,' After copy ',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;


	IF (l_temp_table.RANK_ID.COUNT > 0)
	THEN
		FORALL i IN l_temp_table.RANK_ID.FIRST..l_temp_table.RANK_ID.LAST
			insert into FTE_CARRIER_RANK_LIST
			(	  RANK_ID                   ,
				  TRIP_ID                   ,
				  RANK_SEQUENCE             ,
				  CARRIER_ID		    ,
				  SERVICE_LEVEL	            ,
				  MODE_OF_TRANSPORT         ,
				  LANE_ID                   ,
				  SOURCE		    ,
				  ENABLED		    ,
				  ESTIMATED_RATE	    ,
				  CURRENCY_CODE		    ,
				  VEHICLE_ITEM_ID	    ,
				  VEHICLE_ORG_ID	    ,
				  ESTIMATED_TRANSIT_TIME    ,
				  TRANSIT_TIME_UOM	    ,
				  VERSION		    ,
				  CONSIGNEE_CARRIER_AC_NO   ,
				  FREIGHT_TERMS_CODE	    ,
				  INITSMCONFIG		    ,
				  CALL_RG_FLAG		    ,
				  ATTRIBUTE_CATEGORY        ,
				  ATTRIBUTE1                ,
				  ATTRIBUTE2                ,
				  ATTRIBUTE3                ,
				  ATTRIBUTE4                ,
				  ATTRIBUTE5                ,
				  ATTRIBUTE6                ,
				  ATTRIBUTE7                ,
				  ATTRIBUTE8                ,
				  ATTRIBUTE9                ,
				  ATTRIBUTE10               ,
				  ATTRIBUTE11               ,
				  ATTRIBUTE12               ,
				  ATTRIBUTE13               ,
				  ATTRIBUTE14               ,
				  ATTRIBUTE15               ,
				  CREATION_DATE             ,
				  CREATED_BY                ,
				  LAST_UPDATE_DATE          ,
				  LAST_UPDATED_BY           ,
				  LAST_UPDATE_LOGIN
			)
			values
			(
				l_temp_table.RANK_ID(i),
				l_temp_table.TRIP_ID(i),
				l_temp_table.RANK_SEQUENCE(i),
				decode(l_temp_table.CARRIER_ID(i),FND_API.G_MISS_NUM,NULL,l_temp_table.CARRIER_ID(i)),
				decode(l_temp_table.SERVICE_LEVEL(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.SERVICE_LEVEL(i)),
				decode(l_temp_table.MODE_OF_TRANSPORT(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.MODE_OF_TRANSPORT(i)),
				decode(l_temp_table.LANE_ID(i),FND_API.G_MISS_NUM,NULL,l_temp_table.LANE_ID(i)),
				decode(l_temp_table.SOURCE(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.SOURCE(i)),
				'Y',
				decode(l_temp_table.ESTIMATED_RATE(i),FND_API.G_MISS_NUM,NULL,l_temp_table.ESTIMATED_RATE(i)),
				decode(l_temp_table.CURRENCY_CODE(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.CURRENCY_CODE(i)),
				decode(l_temp_table.VEHICLE_ITEM_ID(i),FND_API.G_MISS_NUM,NULL,l_temp_table.VEHICLE_ITEM_ID(i)),
				decode(l_temp_table.VEHICLE_ORG_ID(i),FND_API.G_MISS_NUM,NULL,l_temp_table.VEHICLE_ORG_ID(i)),
				decode(l_temp_table.ESTIMATED_TRANSIT_TIME(i),FND_API.G_MISS_NUM,NULL,l_temp_table.ESTIMATED_TRANSIT_TIME(i)),
				decode(l_temp_table.TRANSIT_TIME_UOM(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.TRANSIT_TIME_UOM(i)),
				0,
				decode(l_temp_table.CONSIGNEE_CARRIER_AC_NO(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.CONSIGNEE_CARRIER_AC_NO(i)),
				decode(l_temp_table.FREIGHT_TERMS_CODE(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.FREIGHT_TERMS_CODE(i)),
				'CSM',
				'Y',
				decode(l_temp_table.ATTRIBUTE_CATEGORY(i),FND_API.G_MISS_CHAR,NULL,
										l_temp_table.ATTRIBUTE_CATEGORY(i)),
				decode(l_temp_table.ATTRIBUTE1(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE1(i)),
				decode(l_temp_table.ATTRIBUTE2(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE2(i)),
				decode(l_temp_table.ATTRIBUTE3(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE3(i)),
				decode(l_temp_table.ATTRIBUTE4(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE4(i)),
				decode(l_temp_table.ATTRIBUTE5(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE5(i)),
				decode(l_temp_table.ATTRIBUTE6(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE6(i)),
				decode(l_temp_table.ATTRIBUTE7(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE7(i)),
				decode(l_temp_table.ATTRIBUTE8(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE8(i)),
				decode(l_temp_table.ATTRIBUTE9(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE9(i)),
				decode(l_temp_table.ATTRIBUTE10(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE10(i)),
				decode(l_temp_table.ATTRIBUTE11(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE11(i)),
				decode(l_temp_table.ATTRIBUTE12(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE12(i)),
				decode(l_temp_table.ATTRIBUTE13(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE13(i)),
				decode(l_temp_table.ATTRIBUTE14(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE14(i)),
				decode(l_temp_table.ATTRIBUTE15(i),FND_API.G_MISS_CHAR,NULL,l_temp_table.ATTRIBUTE15(i)),
				SYSDATE,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID
			);

			IF l_debug_on
			THEN
			      Log(l_module_name,' After Insert ',WSH_DEBUG_SV.C_PROC_LEVEL);
			END IF;



			FOR i IN l_temp_table.TRIP_ID.FIRST..l_temp_table.TRIP_ID.LAST
			LOOP
				UPDATE WSH_TRIPS
				SET RANK_ID = l_temp_table.RANK_ID(i)
				WHERE TRIP_ID = l_temp_table.TRIP_ID(i);

				IF l_debug_on
				THEN
				      Log(l_module_name,' Rank Id ' || l_temp_table.RANK_ID(i),WSH_DEBUG_SV.C_PROC_LEVEL);
				END IF;
			END LOOP;
	END IF;

	IF (l_trip_names IS NOT NULL)
	THEN

		FND_MESSAGE.SET_NAME('FTE','FTE_RANK_CRE_FAILED_TRIPS');
		FND_MESSAGE.SET_TOKEN('trip_names', l_trip_names);
		FND_MSG_PUB.ADD;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CREATE_RANK_LIST_BULK_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CREATE_RANK_LIST_BULK_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
	 WHEN OTHERS THEN
		ROLLBACK TO CREATE_RANK_LIST_BULK_PUB;
		wsh_util_core.default_handler('FTE_CARRIER_RANK_LIST_PVT.CREATE_RANK_LIST_BULK');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );


END CREATE_RANK_LIST_BULK;


--}


--
END FTE_CARRIER_RANK_LIST_PVT;

/
