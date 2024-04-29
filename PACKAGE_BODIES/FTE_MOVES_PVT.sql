--------------------------------------------------------
--  DDL for Package Body FTE_MOVES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_MOVES_PVT" AS
/* $Header: FTEMVTHB.pls 120.0 2005/05/26 17:08:04 appldev noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_MOVES_PVT';

--========================================================================
-- PROCEDURE : CREATE_MOVE
--
-- PARAMETERS: p_init_msg_list
--	       p_move_info   Attributes for the trip moves entity
--             x_return_status     Return status of API
-- COMMENT   :
--========================================================================

PROCEDURE CREATE_MOVE(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_move_info		IN  		MOVE_REC_TYPE,
	x_move_id		OUT NOCOPY  	NUMBER,
	x_return_status		OUT NOCOPY 	VARCHAR2
) IS

  CURSOR get_next_move IS
  SELECT fte_moves_s.nextval
  FROM sys.dual;

  l_temp_id          NUMBER;
  EMPTY_MOVE_TYPE_CODE	EXCEPTION;
  EMPTY_PLANNED_FLAG	EXCEPTION;

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;


	if (p_move_info.move_type_code IS NULL or
	    p_move_info.move_type_code = FND_API.G_MISS_CHAR) then
		RAISE EMPTY_MOVE_TYPE_CODE;
	end if;


	if (p_move_info.PLANNED_FLAG IS null or
	    p_move_info.PLANNED_FLAG = FND_API.G_MISS_CHAR) then
		RAISE EMPTY_PLANNED_FLAG;
	end if;

	OPEN get_next_move;
	FETCH get_next_move INTO x_move_id;
	CLOSE get_next_move;

	insert into FTE_MOVES
	(
		MOVE_ID         ,
		MOVE_TYPE_CODE         ,
		LANE_ID     ,
		SERVICE_LEVEL,
		PLANNED_FLAG,
		TP_PLAN_NAME,
		CM_TRIP_NUMBER,
		CREATION_DATE       ,
		CREATED_BY          ,
		LAST_UPDATE_DATE    ,
		LAST_UPDATED_BY     ,
		LAST_UPDATE_LOGIN   ,
		PROGRAM_APPLICATION_ID ,
		PROGRAM_ID             ,
		PROGRAM_UPDATE_DATE    ,
		REQUEST_ID
	)
	values
	(
		x_move_id,
		p_move_info.MOVE_TYPE_CODE,
		decode(p_move_info.LANE_ID,FND_API.G_MISS_NUM,NULL,p_move_info.LANE_ID),
		decode(p_move_info.SERVICE_LEVEL,FND_API.G_MISS_CHAR,NULL,p_move_info.SERVICE_LEVEL),
		p_move_info.PLANNED_FLAG,
		decode(p_move_info.TP_PLAN_NAME,FND_API.G_MISS_CHAR,NULL,p_move_info.TP_PLAN_NAME),
		decode(p_move_info.CM_TRIP_NUMBER,FND_API.G_MISS_NUM,NULL,p_move_info.CM_TRIP_NUMBER),
		decode(p_move_info.creation_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE,p_move_info.creation_date),
		decode(p_move_info.created_by,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_move_info.created_by),
		decode(p_move_info.last_update_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE, p_move_info.last_update_date),
		decode(p_move_info.last_updated_by,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_move_info.last_updated_by),
		decode(p_move_info.last_update_login,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.LOGIN_ID,p_move_info.last_update_login),
		decode(p_move_info.program_application_id,NULL,FND_GLOBAL.PROG_APPL_ID,FND_API.G_MISS_NUM,FND_GLOBAL.PROG_APPL_ID,p_move_info.program_application_id),
		decode(p_move_info.program_id,NULL,FND_GLOBAL.CONC_PROGRAM_ID,FND_API.G_MISS_NUM, FND_GLOBAL.CONC_PROGRAM_ID,p_move_info.program_id),
		decode(p_move_info.program_update_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE,p_move_info.program_update_date),
		decode(p_move_info.request_id,NULL,FND_GLOBAL.CONC_REQUEST_ID,FND_API.G_MISS_NUM,FND_GLOBAL.CONC_REQUEST_ID, p_move_info.request_id)
	);



	EXCEPTION
	WHEN EMPTY_MOVE_TYPE_CODE THEN
		FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_TYPE_CODE_MISSING');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	WHEN EMPTY_PLANNED_FLAG THEN
		FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_PLANNED_FLAG_MISSING');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	WHEN others THEN
	        wsh_util_core.default_handler('FTE_MOVES.CREATE_MOVES');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END CREATE_MOVE;


--========================================================================
-- PROCEDURE : Update_MOVES
--
-- PARAMETERS: p_move_info         Attributes for the trip entity
--             x_return_status     Return status of API
-- COMMENT   : Updates trip record with p_trip_info information
--========================================================================

PROCEDURE UPDATE_MOVE(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_move_info		IN		move_rec_type,
	x_return_status		OUT NOCOPY 	VARCHAR2
) IS


BEGIN

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  UPDATE FTE_MOVES SET
	MOVE_TYPE_CODE  =decode(p_move_info.MOVE_TYPE_CODE,
    				NULL,MOVE_TYPE_CODE,
    				FND_API.G_MISS_CHAR,MOVE_TYPE_CODE,
    				p_move_info.MOVE_TYPE_CODE),
	LANE_ID         =decode(p_move_info.LANE_ID,
    				NULL,LANE_ID,
    				FND_API.G_MISS_NUM,NULL,
    				p_move_info.LANE_ID),
	SERVICE_LEVEL	=decode(p_move_info.SERVICE_LEVEL,
    				NULL,SERVICE_LEVEL,
    				FND_API.G_MISS_CHAR,NULL,
    				p_move_info.SERVICE_LEVEL),
	PLANNED_FLAG	=decode(p_move_info.PLANNED_FLAG,
    				NULL,PLANNED_FLAG,
    				FND_API.G_MISS_CHAR,PLANNED_FLAG,
    				p_move_info.PLANNED_FLAG),
	TP_PLAN_NAME	=decode(p_move_info.TP_PLAN_NAME,
    				NULL,TP_PLAN_NAME,
    				FND_API.G_MISS_CHAR,NULL,
    				p_move_info.TP_PLAN_NAME),
	CM_TRIP_NUMBER	=decode(p_move_info.CM_TRIP_NUMBER,
    				NULL,CM_TRIP_NUMBER,
    				FND_API.G_MISS_NUM,NULL,
    				p_move_info.CM_TRIP_NUMBER),
	last_update_date 	= decode(p_move_info.last_update_date,
				NULL,SYSDATE,
				FND_API.G_MISS_DATE,SYSDATE,
				p_move_info.last_update_date),
	last_updated_by  	= decode(p_move_info.last_updated_by,
				NULL,FND_GLOBAL.USER_ID,
				FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,
				p_move_info.last_updated_by),
	last_update_login	= decode(p_move_info.last_update_login,
				NULL,FND_GLOBAL.LOGIN_ID,
				FND_API.G_MISS_NUM, FND_GLOBAL.LOGIN_ID,
				p_move_info.last_update_login),
	program_application_id = decode(p_move_info.program_application_id,
				NULL,program_application_id,
				FND_API.G_MISS_NUM,FND_GLOBAL.PROG_APPL_ID,
				p_move_info.program_application_id),
	program_id 		= decode(p_move_info.program_id,
				NULL,program_id,FND_API.G_MISS_NUM,
				FND_GLOBAL.CONC_PROGRAM_ID,
				p_move_info.program_id),
	program_update_date = decode(p_move_info.program_update_date,
				NULL,program_update_date,
				FND_API.G_MISS_DATE,SYSDATE,
				p_move_info.program_update_date),
	request_id 		= decode(p_move_info.request_id,
				NULL,request_id,FND_API.G_MISS_NUM,
				FND_GLOBAL.CONC_REQUEST_ID,p_move_info.request_id)
  WHERE move_id = p_move_info.move_id;

  IF (SQL%NOTFOUND) THEN
     RAISE no_data_found;
  END IF;

  EXCEPTION
     WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_MOVE_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN others THEN
	   wsh_util_core.default_handler('FTE_MOVES_PVT.UPDATE_MOVES');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END UPDATE_MOVE;


PROCEDURE DELETE_MOVE(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_move_id	     	IN	NUMBER,
	p_validate_flag 	IN  	VARCHAR2 DEFAULT 'Y',
	x_return_status		OUT 	NOCOPY 	VARCHAR2
) IS


BEGIN

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	DELETE FROM fte_moves
	WHERE move_id = p_move_id;

	IF (SQL%NOTFOUND) THEN
		FND_MESSAGE.SET_NAME('FTE','FTE_MOVE_NOT_FOUND');
		FND_MESSAGE.SET_TOKEN('MOVE_ID', p_move_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	END IF;

	-- delete corresponding entries from FTE_TRIP_MOVES
	DELETE FROM FTE_TRIP_MOVES
	WHERE MOVE_ID = p_move_id;


   EXCEPTION
         WHEN others THEN
	    wsh_util_core.default_handler('FTE_MOVES_PVT.DELETE_MOVE');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END DELETE_MOVE;


PROCEDURE MARK_MOVE_REPRICE_FLAG(
	p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_MOVE_id       IN NUMBER,
        x_return_status OUT     NOCOPY  VARCHAR2,
        x_msg_count    OUT     NOCOPY  VARCHAR2,
        x_msg_data   OUT     NOCOPY  VARCHAR2
) IS


	cursor get_trips_from_move_cur( c_move_id NUMBER) is
	    SELECT trip_id
	    FROM   fte_trip_moves
	    WHERE  move_id = c_move_id;


        l_return_status             VARCHAR2(32767);
        l_msg_count                 NUMBER;
        l_msg_data                  VARCHAR2(32767);
        l_number_of_warnings        NUMBER;
        l_number_of_errors          NUMBER;

        l_entity_ids		WSH_UTIL_CORE.id_tab_type;
        idx			NUMBER;

	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'MARK_MOVE_REPRICE_FLAG';
	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;

BEGIN

	SAVEPOINT	MARK_MOVE_REPRICE_FLAG_PUB;


        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_return_status 	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;

	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;

	idx := 1;
	FOR get_trips_from_move_rec IN get_trips_from_move_cur(p_MOVE_id)
		LOOP
		--{
			l_entity_ids(idx) := get_trips_from_move_rec.trip_id;
			idx := idx+1;
		--}
		END LOOP;
	-- END OF
	--
	--
	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:27  ',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;

	IF get_trips_from_move_cur%ISOPEN THEN
	  CLOSE get_trips_from_move_cur;
	END IF;



	WSH_DELIVERY_LEGS_ACTIONS.Mark_Reprice_Required(
	     p_entity_type           => 'TRIP',
	     p_entity_ids            => l_entity_ids,
	     x_return_status         => l_return_status);

	wsh_util_core.api_post_call(
	      p_return_status    =>l_return_status,
	      x_num_warnings     =>l_number_of_warnings,
	      x_num_errors       =>l_number_of_errors);

	IF l_number_of_errors > 0
	THEN
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	ELSIF l_number_of_warnings > 0
	THEN
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
	  WSH_DEBUG_SV.pop(l_module_name);
	END IF;



   EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO MARK_MOVE_REPRICE_FLAG_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Error Occured ' ||
					x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO MARK_MOVE_REPRICE_FLAG_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' Unexpected error Occured ' ||
					x_return_status,WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN OTHERS THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'P1DEBUG:13  ',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;

		ROLLBACK TO MARK_MOVE_REPRICE_FLAG_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,' SQL Error Occured ' ||
					SQLCODE||' '||SQLERRM, WSH_DEBUG_SV.C_PROC_LEVEL);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;


END MARK_MOVE_REPRICE_FLAG;


--
--
END FTE_MOVES_PVT;

/
