--------------------------------------------------------
--  DDL for Package Body FTE_TRIP_MOVES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TRIP_MOVES_PVT" AS
/* $Header: FTEMTTHB.pls 115.3 2004/05/08 00:26:12 wrudge noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_TRIP_MOVES_PVT';


--========================================================================
-- PROCEDURE : VALIDATE_SEQUENCE
--
-- PARAMETERS:
--	       p_trip_moves_info   Attributes for the trip moves entity
--             x_return_status     Return status of API
-- COMMENT   :
--========================================================================

PROCEDURE Validate_Sequence
(
	p_trip_moves_info	IN		TRIP_MOVES_REC_TYPE,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  CURSOR check_sequence_create (v_move_id NUMBER,
                                v_sequence NUMBER) IS
  SELECT trip_move_id
  FROM fte_trip_moves
  WHERE move_id = v_move_id
  and sequence_number = v_sequence;

  CURSOR check_sequence_update (v_move_id NUMBER,
	                       v_sequence NUMBER,
                               v_trip_move_id NUMBER) IS
  SELECT trip_move_id
  FROM fte_trip_moves
  WHERE move_id = v_move_id
  and sequence_number = v_sequence
  and trip_move_id <> v_trip_move_id;

  CURSOR check_move_id (v_move_id NUMBER) IS
  SELECT move_id FROM fte_moves
  WHERE move_id = v_move_id;

  empty_sequence EXCEPTION;
  duplicate_sequence EXCEPTION;
  empty_move	EXCEPTION;

  l_number NUMBER;
  l_found  BOOLEAN;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  --validate sequence

  if (p_trip_moves_info.sequence_number = null
      or p_trip_moves_info.sequence_number = FND_API.G_MISS_NUM) then
    RAISE empty_sequence;
  end if;

  OPEN check_move_id(p_trip_moves_info.move_id);
  FETCH check_move_id INTO l_number;

  IF (check_move_id%NOTFOUND) THEN
    CLOSE check_move_id;
    RAISE empty_move;
  END IF;

  CLOSE check_move_id;

  IF p_trip_moves_info.trip_move_id IS NULL THEN
    OPEN check_sequence_create(p_trip_moves_info.move_id, p_trip_moves_info.sequence_number);
    FETCH check_sequence_create INTO l_number;
    l_found := check_sequence_create%FOUND;
    CLOSE check_sequence_create;
  ELSE
    OPEN check_sequence_update(p_trip_moves_info.move_id,
                               p_trip_moves_info.sequence_number,
                               p_trip_moves_info.trip_move_id);
    FETCH check_sequence_update INTO l_number;
    l_found := check_sequence_update%FOUND;
    CLOSE check_sequence_update;
  END IF;


  IF l_found THEN
    RAISE duplicate_sequence;
  END IF;

  EXCEPTION
    WHEN empty_move THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_MISSING');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN empty_sequence THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_SEQUENCE_MISSING');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN duplicate_sequence THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_SEQUENCE_DUP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN others THEN
      IF check_sequence_create%ISOPEN THEN
        CLOSE check_sequence_create;
      END IF;
      IF check_sequence_update%ISOPEN THEN
        CLOSE check_sequence_update;
      END IF;
      IF check_move_id%ISOPEN THEN
        CLOSE check_move_id;
      END IF;
      wsh_util_core.default_handler('FTE_TRIP_MOVES_PUB.Validate_Sequence');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

END Validate_Sequence;


--========================================================================
-- PROCEDURE : validate_unique_trip
--
-- PARAMETERS:
--	       p_trip_moves_info   Attributes for the trip moves entity
--             x_return_status     Return status of API
-- COMMENT   :
--========================================================================

PROCEDURE validate_unique_trip
(
	p_trip_moves_info	IN		TRIP_MOVES_REC_TYPE,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  CURSOR check_unique_trip_create(v_move_id NUMBER,
                                  v_trip_id NUMBER) IS
  SELECT trip_move_id
  FROM fte_trip_moves
  WHERE move_id = v_move_id
  and trip_id = v_trip_id;


  CURSOR check_unique_trip_update(v_move_id NUMBER,
                                  v_trip_id NUMBER,
                                  v_trip_move_id NUMBER) IS
  SELECT trip_move_id
  FROM fte_trip_moves
  WHERE move_id = v_move_id
  and trip_id = v_trip_id
  and trip_move_id <> v_trip_move_id;

  CURSOR check_trip_id (v_trip_id NUMBER) IS
  SELECT trip_id FROM wsh_trips
  WHERE trip_id = v_trip_id;


  duplicate_trip EXCEPTION;
  empty_trip 	EXCEPTION;

  l_number NUMBER;
  l_found  BOOLEAN;

BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  OPEN check_trip_id(p_trip_moves_info.trip_id);
  FETCH check_trip_id INTO l_number;

  IF (check_trip_id%NOTFOUND) THEN
    CLOSE check_trip_id;
    RAISE empty_trip;
  END IF;

  CLOSE check_trip_id;


  IF p_trip_moves_info.trip_move_id IS NULL THEN
    OPEN check_unique_trip_create(p_trip_moves_info.move_id,
                           p_trip_moves_info.trip_id);
    FETCH check_unique_trip_create INTO l_number;

    IF (check_unique_trip_create%FOUND) THEN
      CLOSE check_unique_trip_create;
      RAISE duplicate_trip;
    END IF;

    CLOSE check_unique_trip_create;

  ELSE

    OPEN check_unique_trip_update(p_trip_moves_info.move_id,
                           p_trip_moves_info.trip_id,
                           p_trip_moves_info.trip_move_id);
    FETCH check_unique_trip_update INTO l_number;

    IF (check_unique_trip_update%FOUND) THEN
      CLOSE check_unique_trip_update;
      RAISE duplicate_trip;
    END IF;

    CLOSE check_unique_trip_update;
  END IF;

  EXCEPTION
    WHEN empty_trip THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_TRIP_MISSING');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN duplicate_trip THEN
      FND_MESSAGE.SET_NAME('FTE', 'FTE_MOVE_TRIP_DUP');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
    WHEN others THEN
      if check_trip_id%ISOPEN THEN
        close check_trip_id;
      end if;
      if check_unique_trip_create%ISOPEN THEN
        close check_unique_trip_create;
      end if;
      if check_unique_trip_update%ISOPEN THEN
        close check_unique_trip_update;
      end if;
      wsh_util_core.default_handler('FTE_TRIP_MOVES_PUB.validate_unique_trip');
      x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
      WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

END validate_unique_trip;



--========================================================================
-- PROCEDURE : CREATE_TRIP_MOVES
--
-- PARAMETERS: p_init_msg_list
--	       p_trip_moves_info   Attributes for the trip moves entity
--             x_return_status     Return status of API
-- COMMENT   :
--========================================================================

PROCEDURE CREATE_TRIP_MOVES
(
	p_init_msg_list	        IN   		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_trip_moves_info	IN		TRIP_MOVES_REC_TYPE,
	x_trip_move_id		OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

  CURSOR get_next_trip_move IS
  SELECT fte_trip_moves_s.nextval
  FROM sys.dual;

  l_temp_id          NUMBER;

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	Validate_Sequence
	(
		p_trip_moves_info,
		x_return_status
	);

	IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		RETURN;
	END IF;

	Validate_Unique_trip
	(
		p_trip_moves_info,
		x_return_status
	);

	IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		RETURN;
	END IF;


	OPEN get_next_trip_move;
	FETCH get_next_trip_move INTO x_trip_move_id;
	CLOSE get_next_trip_move;

	insert into FTE_TRIP_MOVES
	(
		TRIP_MOVE_ID	,
		MOVE_ID         ,
		TRIP_ID         ,
		SEQUENCE_NUMBER     ,
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
		x_trip_move_id,
		p_trip_moves_info.MOVE_ID,
		p_trip_moves_info.TRIP_ID,
		p_trip_moves_info.SEQUENCE_NUMBER,
		decode(p_trip_moves_info.creation_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE,p_trip_moves_info.creation_date),
		decode(p_trip_moves_info.created_by,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_trip_moves_info.created_by),
		decode(p_trip_moves_info.last_update_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE, p_trip_moves_info.last_update_date),
		decode(p_trip_moves_info.last_updated_by,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,p_trip_moves_info.last_updated_by),
		decode(p_trip_moves_info.last_update_login,NULL,FND_GLOBAL.USER_ID,FND_API.G_MISS_NUM,FND_GLOBAL.LOGIN_ID,p_trip_moves_info.last_update_login),
		decode(p_trip_moves_info.program_application_id,NULL,FND_GLOBAL.PROG_APPL_ID,FND_API.G_MISS_NUM,FND_GLOBAL.PROG_APPL_ID,p_trip_moves_info.program_application_id),
		decode(p_trip_moves_info.program_id,NULL,FND_GLOBAL.CONC_PROGRAM_ID,FND_API.G_MISS_NUM, FND_GLOBAL.CONC_PROGRAM_ID,p_trip_moves_info.program_id),
		decode(p_trip_moves_info.program_update_date,NULL,SYSDATE,FND_API.G_MISS_DATE,SYSDATE,p_trip_moves_info.program_update_date),
		decode(p_trip_moves_info.request_id,NULL,FND_GLOBAL.CONC_REQUEST_ID,FND_API.G_MISS_NUM,FND_GLOBAL.CONC_REQUEST_ID, p_trip_moves_info.request_id)
	);

	EXCEPTION
	WHEN others THEN
	        wsh_util_core.default_handler('FTE_TRIP_MOVES.CREATE_TRIP_MOVES');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
END Create_Trip_Moves;


--========================================================================
-- PROCEDURE : Update_Trip_MOVES
--
-- PARAMETERS: p_trip_info         Attributes for the trip entity
--             x_return_status     Return status of API
-- COMMENT   : Updates trip record with p_trip_info information
--========================================================================

PROCEDURE Update_Trip_Moves(
	p_init_msg_list	        IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_trip_moves_info	IN		TRIP_MOVES_REC_TYPE,
	x_return_status		OUT NOCOPY	VARCHAR2
) IS

FTE_DUPLICATE_MOVE exception;

BEGIN

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Validate_Sequence
	(
		p_trip_moves_info,
		x_return_status
	);

	IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		RETURN;
	END IF;

	Validate_Unique_trip
	(
		p_trip_moves_info,
		x_return_status
	);

	IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		RETURN;
	END IF;


  UPDATE fte_trip_moves SET
    SEQUENCE_NUMBER  	= decode(p_trip_moves_info.SEQUENCE_NUMBER,
    				NULL,SEQUENCE_NUMBER,
    				FND_API.G_MISS_NUM,NULL,
    				p_trip_moves_info.SEQUENCE_NUMBER),
    last_update_date 	= decode(p_trip_moves_info.last_update_date,
    			  	NULL,SYSDATE,
    			  	FND_API.G_MISS_DATE,SYSDATE,
    			  	p_trip_moves_info.last_update_date),
    last_updated_by  	= decode(p_trip_moves_info.last_updated_by,
    				NULL,FND_GLOBAL.USER_ID,
    				FND_API.G_MISS_NUM,FND_GLOBAL.USER_ID,
    				p_trip_moves_info.last_updated_by),
    last_update_login	= decode(p_trip_moves_info.last_update_login,
    				NULL,FND_GLOBAL.LOGIN_ID,
    				FND_API.G_MISS_NUM, FND_GLOBAL.LOGIN_ID,
    				p_trip_moves_info.last_update_login),
    program_application_id = decode(p_trip_moves_info.program_application_id,
    				NULL,program_application_id,
    				FND_API.G_MISS_NUM,FND_GLOBAL.PROG_APPL_ID,
    				p_trip_moves_info.program_application_id),
    program_id 		= decode(p_trip_moves_info.program_id,
    				NULL,program_id,FND_API.G_MISS_NUM,
    				FND_GLOBAL.CONC_PROGRAM_ID,
    				p_trip_moves_info.program_id),
    program_update_date = decode(p_trip_moves_info.program_update_date,
    				NULL,program_update_date,
    				FND_API.G_MISS_DATE,SYSDATE,
    				p_trip_moves_info.program_update_date),
    request_id 		= decode(p_trip_moves_info.request_id,
    				NULL,request_id,FND_API.G_MISS_NUM,
    				FND_GLOBAL.CONC_REQUEST_ID,p_trip_moves_info.request_id)
  WHERE trip_move_id = p_trip_moves_info.trip_move_id;

  IF (SQL%NOTFOUND) THEN
     RAISE no_data_found;
  END IF;

  EXCEPTION
     WHEN FTE_DUPLICATE_MOVE THEN
  	   FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_MOVE_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN others THEN
	   wsh_util_core.default_handler('FTE_TRIP_MOVES_PVT.UPDATE_TRIP_MOVES');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Update_Trip_Moves;


PROCEDURE Delete_Trip_moves(
	p_init_msg_list	        IN 		VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_trip_move_id	     	IN		NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2
  ) IS


BEGIN

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	DELETE FROM fte_trip_moves
	WHERE trip_move_id = p_trip_move_id;

	IF (SQL%NOTFOUND) THEN
		FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_MOVE_NOT_FOUND');
		FND_MESSAGE.SET_TOKEN('TRIP_MOVE_ID', p_trip_move_id);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
	END IF;

   EXCEPTION
         WHEN others THEN
	    wsh_util_core.default_handler('FTE_TRIP_MOVES_PVT.DELETE_TRIP_MOVES');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Delete_Trip_moves;

--
--
END FTE_TRIP_MOVES_PVT;

/
