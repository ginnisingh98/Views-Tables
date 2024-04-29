--------------------------------------------------------
--  DDL for Package Body FTE_TRIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TRIPS_PVT" AS
/* $Header: FTETRTHB.pls 115.22 2003/04/24 23:48:35 nltan noship $ */

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_TRIPS_PVT';



-- Wrapper around create_trip and update_trip
-- (create pl/sql record and depending on p_action_code is 'CREATE' or 'UPDATE' or 'DELETE'

 PROCEDURE Create_Update_Delete_Fte_Trip
		(
 		p_api_version_number     IN   NUMBER,
		p_init_msg_list          IN   VARCHAR2,
		x_msg_count              OUT NOCOPY  NUMBER,
		x_msg_data               OUT NOCOPY  VARCHAR2,
		 pp_FTE_TRIP_ID                        IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_NAME                               IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_STATUS_CODE                        IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_PRIVATE_TRIP                       IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		pp_VALIDATION_REQUIRED                IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_CREATION_DATE                      IN      DATE DEFAULT FND_API.G_MISS_DATE,
		 pp_CREATED_BY                         IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_LAST_UPDATE_DATE                   IN      DATE DEFAULT FND_API.G_MISS_DATE,
		 pp_LAST_UPDATED_BY                    IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_LAST_UPDATE_LOGIN                  IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_PROGRAM_APPLICATION_ID             IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_PROGRAM_ID                         IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_PROGRAM_UPDATE_DATE                IN      DATE DEFAULT FND_API.G_MISS_DATE,
		 pp_REQUEST_ID                         IN      NUMBER DEFAULT FND_API.G_MISS_NUM,
		 pp_ATTRIBUTE_CATEGORY                 IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE1                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE2                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE3                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE4                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE5                        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE6                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE7                         IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE8                        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE9                        IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE10                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE11                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE12                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE13                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE14                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ATTRIBUTE15                       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
		 pp_ROUTE_ID                          IN       NUMBER DEFAULT FND_API.G_MISS_NUM,
		 p_action_code			   IN 	    VARCHAR2,
		 x_trip_id		OUT NOCOPY	NUMBER,
		 x_name             OUT NOCOPY  VARCHAR2,
		 x_return_status	OUT NOCOPY	VARCHAR2
		) IS
  -- <insert here your local variables declaration>
  l_api_version_number CONSTANT NUMBER := 1.0;
  l_api_name           CONSTANT VARCHAR2(30):= 'Create_Update_Fte_Trip';

  -- <insert here your local variables declaration>
  l_message VARCHAR2(50);


l_tmp_out NUMBER;

  p_trip_info  fte_trip_rec_type;

  BEGIN

     -- wsh_debug_sv.start_debug ('FteTrip-' || pp_fte_trip_id);
	wsh_debug_sv.start_debug ('FteTrip');
      wsh_debug_sv.dpush (c_sdebug, 'Create_Update_Delete_Fte_Trip');

      wsh_debug_sv.dlog (c_debug,'Name',pp_name);
      wsh_debug_sv.dlog (c_debug,'Action',p_action_code);

  --  Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call
         ( l_api_version_number
         , p_api_version_number
         , l_api_name
         , G_PKG_NAME
         )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --  Initialize message stack if required
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;


     x_return_status := FND_API.G_RET_STS_SUCCESS;

--create trip  record
		 p_trip_info.FTE_TRIP_ID            :=pp_fte_trip_id;
		 p_trip_info.NAME                   :=pp_name;
		 p_trip_info.STATUS_CODE            :=pp_status_code;
		 p_trip_info.PRIVATE_TRIP           :=pp_private_trip;
		 p_trip_info.VALIDATION_REQUIRED    :=pp_validation_required;
		 p_trip_info.CREATION_DATE          :=pp_creation_date;
		 p_trip_info.CREATED_BY             :=pp_created_by;
		 p_trip_info.LAST_UPDATE_DATE       :=pp_last_update_date;
		 p_trip_info.LAST_UPDATED_BY        :=pp_last_updated_by;
		 p_trip_info.LAST_UPDATE_LOGIN      :=pp_last_update_login;
		 p_trip_info.PROGRAM_APPLICATION_ID :=pp_program_application_id;
		 p_trip_info.PROGRAM_ID             :=pp_program_id;
		 p_trip_info.PROGRAM_UPDATE_DATE    :=pp_program_update_date;
		 p_trip_info.REQUEST_ID             :=pp_request_id;
		 p_trip_info.ATTRIBUTE_CATEGORY     :=pp_attribute_category;
		 p_trip_info.ATTRIBUTE1             :=pp_attribute1;
		 p_trip_info.ATTRIBUTE2             :=pp_attribute2;
		 p_trip_info.ATTRIBUTE3             :=pp_attribute3;
		 p_trip_info.ATTRIBUTE4             :=pp_attribute4;
		 p_trip_info.ATTRIBUTE5             :=pp_attribute5;
		 p_trip_info.ATTRIBUTE6             :=pp_attribute6;
		 p_trip_info.ATTRIBUTE7             :=pp_attribute7;
		 p_trip_info.ATTRIBUTE8             :=pp_attribute8;
		 p_trip_info.ATTRIBUTE9             :=pp_attribute9;
		 p_trip_info.ATTRIBUTE10            :=pp_attribute10;
		 p_trip_info.ATTRIBUTE11            :=pp_attribute11;
		 p_trip_info.ATTRIBUTE12            :=pp_attribute12;
		 p_trip_info.ATTRIBUTE13            :=pp_attribute13;
		 p_trip_info.ATTRIBUTE14            :=pp_attribute14;
		 p_trip_info.ATTRIBUTE15            :=pp_attribute15;
		 p_trip_info.ROUTE_ID               :=pp_route_id;


	if (p_action_code='CREATE') then
		Create_Trip (p_trip_info	     =>p_trip_info,
		 x_trip_id	     =>x_trip_id,
		 x_name              =>x_name,
		 x_return_status     =>x_return_status
		);
	elsif (p_action_code='UPDATE') then
	  	Update_Trip
		(p_trip_info		=>p_trip_info,
		 x_return_status 	=>x_return_status);
	elsif (p_action_code='DELETE') then
 		Delete_Trip(p_trip_id	=>p_trip_info.fte_trip_id,
  		x_return_status	=>x_return_status);
	end if;

  -- report success

     FND_MSG_PUB.Count_And_Get
     ( p_encoded => FND_API.G_FALSE,
	p_count => x_msg_count
     , p_data  => x_msg_data
     );

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dlog (c_debug,'Message Count',x_msg_count);
      wsh_debug_sv.dlog (c_debug,'Message Data',x_msg_data);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
	p_count => x_msg_count
        , p_data  => x_msg_data
        );
      wsh_debug_sv.dlog (c_debug,'In error in Create_Update_Delete');
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
	  p_count => x_msg_count
        , p_data  => x_msg_data
        );
      wsh_debug_sv.dlog (c_debug,'In Unexpected error in Create_Update_Delete');
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

     WHEN others THEN
	   wsh_util_core.default_handler('FTE_TRIPS_PVT.Create_Update_Delete_Fte_Trip');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	 FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
	  p_count => x_msg_count
        , p_data  => x_msg_data
        );
      wsh_debug_sv.dlog (c_debug,'In others in Create_Update_Delete');
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

  END Create_Update_Delete_Fte_Trip;





--========================================================================
-- PROCEDURE : Create_Trip
--
-- PARAMETERS: p_trip_info         Attributes for the trip entity
--             x_return_status     Return status of API
-- COMMENT   : Creates trip record with p_trip_info information
--========================================================================

 PROCEDURE Create_Trip
		(p_trip_info	     IN	fte_trip_rec_type,
		 x_trip_id		OUT NOCOPY	NUMBER,
		 x_name             OUT NOCOPY  VARCHAR2,
		 x_return_status	OUT NOCOPY	VARCHAR2
		) IS

  CURSOR get_next_trip IS
    SELECT fte_trips_s.nextval
    FROM sys.dual;

  CURSOR check_trip_names (v_trip_name   VARCHAR2) IS
  SELECT fte_trip_id FROM fte_trips
  WHERE name = v_trip_name;

  CURSOR check_trip_ids (v_trip_id   NUMBER) IS
  SELECT fte_trip_id FROM fte_trips
  WHERE fte_trip_id = v_trip_id;

  l_name	           fte_trips.name%TYPE;
  l_row_check	      NUMBER;
  l_temp_id          NUMBER;

  l_tmp_count  NUMBER := 0;

  wsh_duplicate_name EXCEPTION;

BEGIN

      wsh_debug_sv.dpush (c_sdebug, 'Create_Trip');

      wsh_debug_sv.dlog (c_debug,'trip_id ',p_trip_info.fte_trip_id);
      wsh_debug_sv.dlog (c_debug,'Name ',p_trip_info.name);

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_trip_id := p_trip_info.fte_trip_id;
  x_name := p_trip_info.name;

      wsh_debug_sv.dlog (c_debug,'about to validate trip id...');

  IF (x_trip_id IS NULL) OR (x_trip_id = FND_API.G_MISS_NUM) THEN

     LOOP

       OPEN get_next_trip;
       FETCH get_next_trip INTO x_trip_id;
       CLOSE get_next_trip;

       l_row_check := NULL;

       OPEN  check_trip_ids(x_trip_id);
       FETCH check_trip_ids INTO l_row_check;

       IF (check_trip_ids%NOTFOUND) THEN
          CLOSE check_trip_ids;
	     EXIT;
       END IF;

       CLOSE check_trip_ids;

     END LOOP;


  END IF;

      wsh_debug_sv.dlog (c_debug,'about to validate trip name...');

  IF (x_name IS NULL) OR (x_name = FND_API.G_MISS_CHAR) THEN
        l_temp_id := x_trip_id;
        LOOP
              l_name := to_char(l_temp_id);

              OPEN check_trip_names( l_name);
              FETCH check_trip_names INTO l_row_check;

              IF (check_trip_names%NOTFOUND) THEN
                 CLOSE check_trip_names;
                 EXIT;
              END IF;

              CLOSE check_trip_names;

              OPEN get_next_trip;
              FETCH get_next_trip INTO l_temp_id;
              CLOSE get_next_trip;

        END LOOP;

        x_trip_id := l_temp_id;
        x_name := l_name;

  ELSE

      wsh_debug_sv.dlog (c_debug,'about to call Validate_CreateTrip...');

--validation
	Validate_CreateTrip (p_trip_name =>x_name,
	                     x_return_status=>x_return_status);

	IF 	(x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
		AND (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)
	THEN
           RETURN;
	END IF;

  END IF;

      wsh_debug_sv.dlog (c_debug,'about to insert into fte_trips table...');
      wsh_debug_sv.dlog (c_debug,'trip id ', x_trip_id);
      wsh_debug_sv.dlog (c_debug,'name', x_name);

  INSERT INTO fte_trips(
 FTE_TRIP_ID         ,
 NAME               ,
 STATUS_CODE         ,
 PRIVATE_TRIP        ,
 VALIDATION_REQUIRED ,
 CREATION_DATE       ,
 CREATED_BY          ,
 LAST_UPDATE_DATE    ,
 LAST_UPDATED_BY     ,
 LAST_UPDATE_LOGIN   ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_UPDATE_DATE    ,
 REQUEST_ID             ,
 ATTRIBUTE_CATEGORY     ,
 ATTRIBUTE1             ,
 ATTRIBUTE2             ,
 ATTRIBUTE3             ,
 ATTRIBUTE4             ,
 ATTRIBUTE5             ,
 ATTRIBUTE6             ,
 ATTRIBUTE7             ,
 ATTRIBUTE8             ,
 ATTRIBUTE9             ,
 ATTRIBUTE10            ,
 ATTRIBUTE11            ,
 ATTRIBUTE12            ,
 ATTRIBUTE13            ,
 ATTRIBUTE14            ,
 ATTRIBUTE15            ,
 ROUTE_ID
 )
 VALUES(
    x_trip_id,
    x_name,
    'OP',
    decode(p_trip_info.private_trip, FND_API.G_MISS_CHAR, NULL, p_trip_info.private_trip),
    decode(p_trip_info.validation_required, FND_API.G_MISS_CHAR, NULL, p_trip_info.validation_required),
    decode(p_trip_info.creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    decode(p_trip_info.created_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.created_by),
    decode(p_trip_info.last_update_date,FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    decode(p_trip_info.last_updated_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.last_updated_by),
    decode(p_trip_info.last_update_login,FND_API.G_MISS_NUM, FND_GLOBAL.LOGIN_ID, NULL, FND_GLOBAL.LOGIN_ID, p_trip_info.last_update_login),
    decode(p_trip_info.program_application_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_application_id),
    decode(p_trip_info.program_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_id),
    decode(p_trip_info.program_update_date, FND_API.G_MISS_DATE, NULL, p_trip_info.program_update_date),
    decode(p_trip_info.request_id, FND_API.G_MISS_NUM, NULL, p_trip_info.request_id),
    decode(p_trip_info.attribute_category, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute_category),
    decode(p_trip_info.attribute1, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute1),
    decode(p_trip_info.attribute2, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute2),
    decode(p_trip_info.attribute3, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute3),
    decode(p_trip_info.attribute4, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute4),
    decode(p_trip_info.attribute5, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute5),
    decode(p_trip_info.attribute6, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute6),
    decode(p_trip_info.attribute7, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute7),
    decode(p_trip_info.attribute8, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute8),
    decode(p_trip_info.attribute9, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute9),
    decode(p_trip_info.attribute10, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute10),
    decode(p_trip_info.attribute11, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute11),
    decode(p_trip_info.attribute12, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute12),
    decode(p_trip_info.attribute13, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute13),
    decode(p_trip_info.attribute14, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute14),
    decode(p_trip_info.attribute15, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute15),
    decode(p_trip_info.route_id, FND_API.G_MISS_NUM, NULL, p_trip_info.route_id)
  );

      wsh_debug_sv.dlog (c_debug,'right after insert statement---');
      wsh_debug_sv.dlog (c_debug,'SQL%FOUND', SQL%FOUND);
      wsh_debug_sv.dlog (c_debug,'SQL%ROWCOUNT', SQL%ROWCOUNT);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);

  EXCEPTION
     WHEN wsh_duplicate_name THEN
  	   FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dlog (c_debug,'wsh_duplicate_name exception');
      wsh_debug_sv.dpop (c_sdebug);

     WHEN others THEN
	   wsh_util_core.default_handler('FTE_TRIPS_PVT.CREATE_TRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dlog (c_debug,'others exception');
      wsh_debug_sv.dpop (c_sdebug);

END Create_Trip;


 PROCEDURE Validate_CreateTrip
		(p_trip_id	IN NUMBER DEFAULT FND_API.G_MISS_NUM,
		 p_trip_name	IN VARCHAR2,
		 x_return_status	OUT NOCOPY	VARCHAR2
		) IS

  CURSOR check_trip_names (v_trip_name   VARCHAR2) IS
  SELECT fte_trip_id FROM fte_trips
  WHERE name = v_trip_name;

  l_name	           fte_trips.name%TYPE;
  l_row_check	      NUMBER;
  wsh_duplicate_name EXCEPTION;

BEGIN

      wsh_debug_sv.dpush (c_sdebug, 'Validate_CreateTrip');

      wsh_debug_sv.dlog (c_debug,'trip_id ',p_trip_id);
      wsh_debug_sv.dlog (c_debug,'Name ',p_trip_name);

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      wsh_debug_sv.dlog (c_debug,'about to check trip name... ');

  OPEN check_trip_names(p_trip_name);
  FETCH check_trip_names INTO l_row_check;

  IF (check_trip_names%FOUND) THEN
     CLOSE check_trip_names;
     RAISE wsh_duplicate_name;
  END IF;
  CLOSE check_trip_names;

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);

  EXCEPTION
     WHEN wsh_duplicate_name THEN
  	   FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dlog (c_debug,'wsh_duplicate_name exception');
      wsh_debug_sv.dpop (c_sdebug);

     WHEN others THEN
	   wsh_util_core.default_handler('FTE_TRIPS_PVT.VALIDATE_CREATETRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dlog (c_debug,'others exception');
      wsh_debug_sv.dpop (c_sdebug);

END Validate_CreateTrip;





--========================================================================
-- PROCEDURE : Update_Trip
--
-- PARAMETERS: p_trip_info         Attributes for the trip entity
--             x_return_status     Return status of API
-- COMMENT   : Updates trip record with p_trip_info information
--========================================================================

PROCEDURE Update_Trip(
	p_trip_info		IN	fte_trip_rec_type,
	x_return_status 	OUT NOCOPY 	VARCHAR2) IS

  CURSOR check_trip_names (v_trip_name   VARCHAR2) IS
  SELECT fte_trip_id FROM fte_trips
  WHERE name = v_trip_name;

  l_row_check	      NUMBER;

  wsh_duplicate_name EXCEPTION;
BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

--validation
  Validate_UpdateTrip(p_trip_id	      =>p_trip_info.fte_trip_id,
		      p_trip_name     =>p_trip_info.name,
		      p_trip_status   =>p_trip_info.status_code,
		      x_return_status => x_return_status);

	IF 	(x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
		AND (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)
	THEN
           RETURN;
	END IF;


  UPDATE fte_trips SET
    fte_trip_id 			= decode(p_trip_info.fte_trip_id,FND_API.G_MISS_NUM, fte_trip_id, p_trip_info.fte_trip_id),
    name				= decode(p_trip_info.name, FND_API.G_MISS_CHAR, name, p_trip_info.name),
    status_code				= decode(p_trip_info.status_code, FND_API.G_MISS_CHAR, status_code, p_trip_info.status_code),
    private_trip=decode(p_trip_info.private_trip, FND_API.G_MISS_CHAR, NULL, p_trip_info.private_trip),
    validation_required=decode(p_trip_info.validation_required, FND_API.G_MISS_CHAR, NULL, p_trip_info.validation_required),
    creation_date=decode(p_trip_info.creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    created_by=decode(p_trip_info.created_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.created_by),
    last_update_date=decode(p_trip_info.last_update_date,FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, p_trip_info.creation_date),
    last_updated_by=decode(p_trip_info.last_updated_by,FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, NULL, FND_GLOBAL.USER_ID, p_trip_info.last_updated_by),
    last_update_login=decode(p_trip_info.last_update_login,FND_API.G_MISS_NUM, FND_GLOBAL.LOGIN_ID, NULL, FND_GLOBAL.LOGIN_ID, p_trip_info.last_update_login),
    program_application_id=decode(p_trip_info.program_application_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_application_id),
   program_id= decode(p_trip_info.program_id, FND_API.G_MISS_NUM, NULL, p_trip_info.program_id),
    program_update_date=decode(p_trip_info.program_update_date, FND_API.G_MISS_DATE, NULL, p_trip_info.program_update_date),
    request_id=decode(p_trip_info.request_id, FND_API.G_MISS_NUM, NULL, p_trip_info.request_id),
    attribute_category=decode(p_trip_info.attribute_category, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute_category),
    attribute1=decode(p_trip_info.attribute1, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute1),
    attribute2=decode(p_trip_info.attribute2, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute2),
    attribute3=decode(p_trip_info.attribute3, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute3),
    attribute4=decode(p_trip_info.attribute4, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute4),
    attribute5=decode(p_trip_info.attribute5, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute5),
    attribute6=decode(p_trip_info.attribute6, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute6),
    attribute7=decode(p_trip_info.attribute7, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute7),
    attribute8=decode(p_trip_info.attribute8, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute8),
    attribute9=decode(p_trip_info.attribute9, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute9),
    attribute10=decode(p_trip_info.attribute10, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute10),
    attribute11=decode(p_trip_info.attribute11, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute11),
    attribute12=decode(p_trip_info.attribute12, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute12),
    attribute13=decode(p_trip_info.attribute13, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute13),
    attribute14=decode(p_trip_info.attribute14, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute14),
    attribute15=decode(p_trip_info.attribute15, FND_API.G_MISS_CHAR, NULL, p_trip_info.attribute15),
    route_id=decode(p_trip_info.route_id, FND_API.G_MISS_NUM, NULL, p_trip_info.route_id)
  WHERE fte_trip_id = p_trip_info.fte_trip_id;



  IF (SQL%NOTFOUND) THEN
     RAISE no_data_found;
  END IF;

  EXCEPTION
     WHEN wsh_duplicate_name THEN
  	   FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN others THEN
	   wsh_util_core.default_handler('FTE_TRIPS_PVT.UPDATE_TRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Update_Trip;


PROCEDURE Validate_UpdateTrip(
	p_trip_id		IN	NUMBER,
	p_trip_name		IN	VARCHAR2,
	p_trip_status		IN	VARCHAR2,
	x_return_status 	OUT NOCOPY 	VARCHAR2) IS

  CURSOR check_trip_names (v_trip_name   VARCHAR2) IS
  SELECT fte_trip_id FROM fte_trips
  WHERE name = v_trip_name;

  l_row_check	      NUMBER;

  no_fte_trip_id EXCEPTION;
  wsh_duplicate_name EXCEPTION;
  invalid_fte_trip_status EXCEPTION;
BEGIN

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF (p_trip_id = FND_API.G_MISS_NUM) THEN
	RAISE no_fte_trip_id;
  END IF;

   IF (p_trip_status = 'CL') THEN
	RAISE invalid_fte_trip_status;
  END IF;

  if (p_trip_name<>to_char(p_trip_id)) then
        OPEN check_trip_names(p_trip_name);
        FETCH check_trip_names INTO l_row_check;

        IF (check_trip_names%FOUND) THEN
	   if (l_row_check<>(p_trip_id)) then
             CLOSE check_trip_names;
             RAISE wsh_duplicate_name;
	   end if;
        END IF;

        CLOSE check_trip_names;
  end if;

  EXCEPTION
     WHEN wsh_duplicate_name THEN
  	   FND_MESSAGE.Set_Name('FND', 'FORM_DUPLICATE_KEY_IN_INDEX');
  	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN no_fte_trip_id THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_NO_TRIP_ID');
	   FND_MESSAGE.SET_TOKEN('TRIP_ID', p_trip_id);
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN invalid_fte_trip_status THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TRIP_STATUS');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     WHEN others THEN
	   wsh_util_core.default_handler('FTE_TRIPS_PVT.VALIDATE_UPDATETRIP');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Validate_UpdateTrip;





PROCEDURE Delete_Trip(
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY	VARCHAR2
  ) IS

  l_trip_id	NUMBER;
  l_return_status VARCHAR2(1);


  others EXCEPTION;

BEGIN

   x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_trip_id := p_trip_id;

--validate
   Validate_DeleteTrip(p_trip_id=>l_trip_id,
		x_return_status=>x_return_status
		);

	IF 	(x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
		AND (x_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING)
	THEN
           RETURN;
	END IF;

    DELETE FROM fte_trips
    WHERE fte_trip_id = l_trip_id;

     IF (SQL%NOTFOUND) THEN
	FND_MESSAGE.SET_NAME('FTE','FTE_NO_TRIP_ID');
	FND_MESSAGE.SET_TOKEN('TRIP_ID', l_trip_id);
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
     END IF;

   EXCEPTION
         WHEN others THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.DELETE_TRIP');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Delete_Trip;


PROCEDURE Validate_DeleteTrip(
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY	VARCHAR2
  ) IS

  CURSOR trip_segments (l_trip_id IN NUMBER) IS
  SELECT wsh_trip_id
  FROM  fte_wsh_trips
  WHERE  fte_trip_id = l_trip_id;

  l_trip_id	NUMBER;
  l_wsh_trip_ids    NUMBER;
  l_return_status VARCHAR2(1);
  l_trip_name VARCHAR2(30);

  others EXCEPTION;

BEGIN

   x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   l_trip_id := p_trip_id;

	OPEN trip_segments(l_trip_id);
	fetch trip_segments into l_wsh_trip_ids;
	IF (trip_segments%NOTFOUND) THEN
	  return;
	else
	    get_trip_name
		(
		  p_trip_id                 =>l_trip_id,
	          x_trip_name      	    =>l_trip_name,
	          x_return_status	    =>x_return_status
		);
	    FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_DELETE_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	    wsh_util_core.add_message(x_return_status);
	end if;

   EXCEPTION
      WHEN others THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.VALIDATE_DELETETRIP');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

END Validate_DeleteTrip;


-- Trip Segment validation for a Trip
PROCEDURE Validate_Trip(
  p_trip_id		IN	NUMBER,
  x_return_status	OUT NOCOPY	VARCHAR2,
  x_msg_count 		OUT NOCOPY 	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2
  ) IS

  CURSOR trip_segments (l_trip_id IN NUMBER) IS
  SELECT wsh_trip_id, sequence_number
  FROM  fte_wsh_trips
  WHERE  fte_trip_id = l_trip_id
  order by sequence_number;

  CURSOR trip_stops (l_wsh_trip_id IN NUMBER) IS
  select stop_id, stop_location_id, stop_sequence_number
  from wsh_trip_stops
  where trip_id=l_wsh_trip_id
  order by stop_sequence_number;

  l_trip_segments    trip_segments%ROWTYPE;
  l_trip_stops	     trip_stops%ROWTYPE;

  l_segment_origin NUMBER;
  l_segment_dest NUMBER;
  l_trip_segment_name VARCHAR2(100);
  l_count NUMBER;
  L_SEGMENT_SEQUENCENUM_NEXT NUMBER;
  L_SEGMENT_SEQUENCENUM_PREV NUMBER;
l_c number;
l_trip_name VARCHAR2(30);


  cannot_delete_trip EXCEPTION;
  invalid_connect_segment EXCEPTION;
  others EXCEPTION;

BEGIN

   wsh_debug_sv.start_debug ('FteTrip-' || p_trip_id);
   wsh_debug_sv.dpush (c_sdebug, 'Validate_Trip');

   x_return_Status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

   IF p_trip_id IS NOT NULL THEN
	l_count:=0;
	FOR l_trip_segments IN trip_segments(p_trip_id) LOOP
	   l_count:=l_count+1;

	   --3. segment number shud be unique (order by seq no and just check
	   --   next seq num.)
	   l_segment_sequencenum_next:=l_trip_segments.sequence_number;
	   if ((l_segment_sequencenum_prev=l_segment_sequencenum_next)) then

		wsh_debug_sv.dlog (c_debug,'segment number unique check');

		UPDATE FTE_TRIPS SET validation_required='Y'
		where fte_trip_id=p_trip_id;

  	       IF (SQL%NOTFOUND) THEN
    		 RAISE no_data_found;
  	       END IF;
		get_trip_name
		(
		  p_trip_id                 =>p_trip_id,
	          x_trip_name      	    =>l_trip_name,
	          x_return_status	    =>x_return_status
		);
		FND_MESSAGE.SET_NAME('FTE','FTE_DUPLICATE_SEQ_NUM');
		FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
	    	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    	wsh_util_core.add_message(x_return_status);

	        wsh_debug_sv.dpop (c_sdebug);
	        wsh_debug_sv.stop_debug;

	        FND_MSG_PUB.Count_And_Get
	        ( p_encoded => FND_API.G_FALSE,
		  p_count => x_msg_count
	         ,p_data  => x_msg_data
	         );
		return;

	   end if;
	   l_segment_sequencenum_prev:=l_trip_segments.sequence_number;


	   fte_mls_util.get_first_stop_location_id(
	          P_trip_segment_id         =>l_trip_segments.wsh_trip_id,
		  x_trip_segment_name       =>l_trip_segment_name,
		  x_first_stop_location_id  =>l_segment_origin,
	          x_return_status	    =>x_return_status
		);

	   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		wsh_debug_sv.dlog (c_debug,'could not get 1st stop location');
	       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	       UPDATE FTE_TRIPS SET validation_required='Y'
		where fte_trip_id=p_trip_id;
  	       IF (SQL%NOTFOUND) THEN
    		 RAISE no_data_found;
  	       END IF;

	      wsh_debug_sv.dpop (c_sdebug);
	      wsh_debug_sv.stop_debug;

              FND_MSG_PUB.Count_And_Get
              ( p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count
               ,p_data  => x_msg_data
              );
              RETURN;

	   END IF;

           open trip_stops(l_trip_segments.wsh_trip_id);
	   LOOP
	   fetch trip_stops into l_trip_stops;
	   EXIT WHEN trip_stops%NOTFOUND;
	   END LOOP;

	  --1. segment shud have atleast 2 stops
	   if ((trip_stops%ROWCOUNT<2)) then
	       CLOSE trip_stops;
		wsh_debug_sv.dlog (c_debug,'segment shud have atleast 2 stops');
		UPDATE FTE_TRIPS SET validation_required='Y'
		where fte_trip_id=p_trip_id;

  	        IF (SQL%NOTFOUND) THEN
    		   RAISE no_data_found;
  	        END IF;
	    	FND_MESSAGE.SET_NAME('FTE','FTE_SEGMENT_NO_TWO_STOPS');
	    	FND_MESSAGE.SET_TOKEN('WSH_TRIP_NAME',l_trip_segment_name);
	    	x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	    	wsh_util_core.add_message(x_return_status);

      		wsh_debug_sv.dpop (c_sdebug);
     		wsh_debug_sv.stop_debug;
          	FND_MSG_PUB.Count_And_Get
          	( p_encoded => FND_API.G_FALSE,
		 p_count => x_msg_count
           	,p_data  => x_msg_data
           	);
		return;
	   end if;
	   CLOSE trip_stops;



	   --2.origin of 1st segment=dest. of next segment
	   if ((l_count>1) AND (l_segment_dest<>l_segment_origin)) then
		wsh_debug_sv.dlog (c_debug,'origin of 1st segment!=dest. of next segment');
	       UPDATE FTE_TRIPS SET validation_required='Y'
		where fte_trip_id=p_trip_id;
  	       IF (SQL%NOTFOUND) THEN
    		 RAISE no_data_found;
  	       END IF;

	       get_trip_name
		(
		  p_trip_id                 =>p_trip_id,
	          x_trip_name      	    =>l_trip_name,
	          x_return_status	    =>x_return_status
		);
	       FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_CONNECT_SEGMENT');
	       FND_MESSAGE.SET_TOKEN('TRIP_NAME',l_trip_name);
               x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	       wsh_util_core.add_message(x_return_status);
	       wsh_debug_sv.dpop (c_sdebug);
	       wsh_debug_sv.stop_debug;

	       FND_MSG_PUB.Count_And_Get
               ( p_encoded => FND_API.G_FALSE,
		  p_count => x_msg_count
                 ,p_data  => x_msg_data
               );
	       return;
	   end if;

	   fte_mls_util.get_last_stop_location_id(
	          P_trip_segment_id         =>l_trip_segments.wsh_trip_id,
		  x_trip_segment_name       =>l_trip_segment_name,
		  x_last_stop_location_id   =>l_segment_dest,
	          x_return_status	    =>x_return_status
		);

	   IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		wsh_debug_sv.dlog (c_debug,'could not get last stop location');
	       x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

	       UPDATE FTE_TRIPS SET validation_required='Y'
	       where fte_trip_id=p_trip_id;
  	       IF (SQL%NOTFOUND) THEN
    		 RAISE no_data_found;
  	       END IF;
	       wsh_debug_sv.dpop (c_sdebug);
	       wsh_debug_sv.stop_debug;

               RETURN;
	   END IF;


	END LOOP;

	IF (x_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		wsh_debug_sv.dlog (c_debug,'validation success');
        	UPDATE FTE_TRIPS SET validation_required='N'
		where fte_trip_id=p_trip_id;
  		IF (SQL%NOTFOUND) THEN
    	  	  RAISE no_data_found;
  		END IF;
	END IF;
   else
	raise no_data_found;
   END IF;

      wsh_debug_sv.dlog (c_debug,'Return Status',x_Return_Status);
      wsh_debug_sv.dpop (c_sdebug);
      wsh_debug_sv.stop_debug;

   EXCEPTION
     WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_TRIP_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
      	   wsh_debug_sv.dpop (c_sdebug);
           wsh_debug_sv.stop_debug;
	   --  Get message count and data
          FND_MSG_PUB.Count_And_Get
          ( p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count
           ,p_data  => x_msg_data
           );
      WHEN others THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.VALIDATE_DELETETRIP');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	    wsh_debug_sv.dpop (c_sdebug);
            wsh_debug_sv.stop_debug;
	    --  Get message count and data
            FND_MSG_PUB.Count_And_Get
            ( p_encoded => FND_API.G_FALSE,
	      p_count => x_msg_count
             ,p_data  => x_msg_data
            );
END Validate_Trip;

    PROCEDURE get_trip_name
		(
		  p_trip_id                 IN     NUMBER,
	          x_trip_name      	    OUT NOCOPY	   VARCHAR2,
	          x_return_status	    OUT NOCOPY	   VARCHAR2
		)
    IS

	l_trip_name   VARCHAR2(32767);

	CURSOR get_trip_cur
	IS
	SELECT name
	FROM   fte_trips
	WHERE  fte_trip_id = p_trip_id;

    BEGIN

	l_trip_name := NULL;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FOR get_trip_rec IN get_trip_cur
	LOOP
	    l_trip_name := get_trip_rec.name;
	END LOOP;

	IF l_trip_name IS NULL
	THEN
	    RAISE NO_DATA_FOUND;
	END IF;

	x_trip_name     := l_trip_name;

    EXCEPTION
	WHEN OTHERS THEN
            wsh_util_core.default_handler('FTE_TRIPS_PVT.GET_TRIP_NAME');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_TRIP_NAME_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_ID',p_trip_id);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END get_trip_name;


-- pass in del ids as a comma seperated list which will
-- be assigned to fte_trip
-- comma seperated list will be of form d100, d101, .. (have to remove
-- "d" before update)

    PROCEDURE assign_deliveries_to_ftetrip
		(
                p_del_ids               IN      VARCHAR2,
		p_fte_trip_id		IN	NUMBER,
		p_wsh_trip_id		IN	NUMBER,
  		x_return_status		OUT NOCOPY	VARCHAR2,
  		x_msg_count 		OUT NOCOPY 	NUMBER,
 		x_msg_data		OUT NOCOPY	VARCHAR2
		)
    IS

	l_del_ids dbms_utility.UNCL_ARRAY;
	l_del_id VARCHAR2(30);
	l_dleg_id NUMBER;
	l_noofrows BINARY_INTEGER;

	cursor c_dlegs(p_del_id NUMBER) is
	select delivery_leg_id
	from wsh_delivery_legs wdl, wsh_trip_stops wts
	where wdl.pick_up_stop_id = wts.stop_id
	and wts.trip_id = p_wsh_trip_id
	and wdl.delivery_id=p_del_id;


    BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	dbms_utility.comma_to_table(
			list	=>p_del_ids,
			tablen	=>l_noofrows,
			tab	=>l_del_ids
			);



	FOR i IN l_del_ids.FIRST..l_del_ids.LAST LOOP
           l_del_id:=l_del_ids(i);
	   l_del_id:=substr(l_del_id,2);

	   for c_dleg in c_dlegs(l_del_id) loop
		l_dleg_id:=c_dleg.delivery_leg_id;

		UPDATE wsh_delivery_legs SET fte_trip_id=p_fte_trip_id
		where delivery_leg_id=l_dleg_id;

  		IF (SQL%NOTFOUND) THEN
    	  	  RAISE no_data_found;
  		END IF;
	   end loop;
	END LOOP;

    EXCEPTION
      WHEN no_data_found THEN
	   FND_MESSAGE.SET_NAME('FTE','FTE_DELIVERY_NOT_FOUND');
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   WSH_UTIL_CORE.ADD_MESSAGE(x_return_status);
          FND_MSG_PUB.Count_And_Get
          ( p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count
           ,p_data  => x_msg_data
           );
      WHEN others THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.assign_deliveries_to_ftetrip');
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
          ( p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count
           ,p_data  => x_msg_data
           );
    END assign_deliveries_to_ftetrip;


FUNCTION GET_TRIP_BY_TENDER_NUMBER(p_tender_number	NUMBER)
	RETURN NUMBER
	IS

	l_trip_id 	NUMBER	:= -9999;

	cursor get_trip_cur(c_tender_number NUMBER) is
	select trip_id
	from wsh_trips
	where load_tender_number = c_tender_number;

	BEGIN

		FOR get_trip_rec IN get_trip_cur(p_tender_number)
			LOOP
			--{
				l_trip_id	:=	get_trip_rec.trip_id;
			--}
			END LOOP;
		-- END OF get trip segment info
		--
		--
		IF get_trip_cur%ISOPEN THEN
		  CLOSE get_trip_cur;
		END IF;

		return l_trip_id;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE;
END GET_TRIP_BY_TENDER_NUMBER;
--
--
--
--
PROCEDURE GET_LAST_STOP_LOCATION_INFO
	(
	  P_trip_segment_id         	IN		NUMBER,
	  x_trip_segment_name       	IN OUT NOCOPY 		VARCHAR2,
	  x_last_stop_location_id   	OUT NOCOPY     	NUMBER,
	  x_return_status		OUT NOCOPY	   	VARCHAR2,
	  x_planned_arvl_dt    		OUT NOCOPY		DATE,
	  x_planned_dept_dt		OUT NOCOPY		DATE
	)
IS
	--{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_last_stop_cur
		(
		  p_trip_id IN NUMBER
		)
	IS
	SELECT stop_id, stop_location_id, stop_sequence_number,
		planned_departure_date,planned_arrival_date
	FROM   wsh_trip_stops
	WHERE  trip_id =  p_trip_id
	AND    stop_sequence_number = ( select max(stop_sequence_number)
				   from wsh_trip_stops
				   where trip_id = p_trip_id);
	--}
BEGIN
	--{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
		p_trip_segment_id         => p_trip_segment_id,
		x_trip_segment_name       => x_trip_segment_name,
		x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
		x_return_status := l_return_status;
		--
		--
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
		--{
		    RETURN;
		--}
		END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	x_last_stop_location_id := NULL;
	--
	FOR get_last_stop_rec IN get_last_stop_cur ( p_trip_Segment_id )
	LOOP
	--{
	    x_last_stop_location_id := get_last_stop_rec.stop_location_id;
	    x_planned_arvl_dt	:=	get_last_stop_rec.planned_arrival_date;
	    x_planned_dept_dt	:=	get_last_stop_rec.planned_departure_date;

	--}
	END LOOP;
	--}

	EXCEPTION
	--{
	WHEN OTHERS THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.GET_LAST_STOP_LOCATION_INFO');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_LAST_STOP_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',x_trip_segment_name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--}
END GET_LAST_STOP_LOCATION_INFO;
--
--
PROCEDURE GET_FIRST_STOP_LOCATION_INFO
	(
	  P_trip_segment_id         	IN		NUMBER,
	  x_trip_segment_name       	IN OUT NOCOPY 		VARCHAR2,
	  x_first_stop_location_id   	OUT NOCOPY     	NUMBER,
	  x_return_status		OUT NOCOPY	   	VARCHAR2,
	  x_planned_arvl_dt    		OUT NOCOPY		DATE,
	  x_planned_dept_dt		OUT NOCOPY		DATE
	)
IS
	--{
	l_return_status VARCHAR2(32767);
	--
	--
	CURSOR get_first_stop_cur
		(
		  p_trip_id IN NUMBER
		)
	IS
	SELECT stop_id, stop_location_id, stop_sequence_number,
		planned_departure_date,planned_arrival_date
	FROM   wsh_trip_stops
	WHERE  trip_id =  p_trip_id
	AND    stop_sequence_number = ( select min(stop_sequence_number)
				   from wsh_trip_stops
				   where trip_id = p_trip_id);
	--}
BEGIN
	--{
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--
	--
	IF x_trip_segment_name IS NULL
	THEN
	--{
	    get_trip_segment_name
	      (
		p_trip_segment_id         => p_trip_segment_id,
		x_trip_segment_name       => x_trip_segment_name,
		x_return_status	          => l_return_status
	      );
	    --
	    --
	    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	    --{
		x_return_status := l_return_status;
		--
		--
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
		--{
		    RETURN;
		--}
		END IF;
	    --}
	    END IF;
	--}
	END IF;
	--
	--
	x_first_stop_location_id := NULL;
	--
	FOR get_first_stop_rec IN get_first_stop_cur( p_trip_Segment_id )
	LOOP
	--{
	    x_first_stop_location_id := 	get_first_stop_rec.stop_location_id;
	    x_planned_arvl_dt	:=	get_first_stop_rec.planned_arrival_date;
	    x_planned_dept_dt	:=	get_first_stop_rec.planned_departure_date;

	--}
	END LOOP;
	--}

	EXCEPTION
	--{
	WHEN OTHERS THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.GET_FIRST_STOP_LOCATION_INFO');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_FIRST_STOP_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_NAME',x_trip_segment_name);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--}
END GET_FIRST_STOP_LOCATION_INFO;
--
--
PROCEDURE GET_TRIP_SEGMENT_NAME
	(
	  p_trip_segment_id                 IN     NUMBER,
	  x_trip_segment_name      	    OUT NOCOPY	   VARCHAR2,
	  x_return_status	    OUT NOCOPY	   VARCHAR2
	)
IS
	--{
	l_trip_segment_name   VARCHAR2(32767);
	--
	--
	CURSOR get_trip_segment_cur
	IS
	SELECT name
	FROM   wsh_trips
	WHERE  trip_id = p_trip_segment_id;
	--}
BEGIN
	--{
		l_trip_segment_name := NULL;
		--
		FOR get_trip_segment_rec IN get_trip_segment_cur
		LOOP
		--{
		    l_trip_segment_name := get_trip_segment_rec.name;
		--}
		END LOOP;
		--
		--
		IF l_trip_segment_name IS NULL
		THEN
		    RAISE NO_DATA_FOUND;
		END IF;
		--
		--
		x_trip_segment_name     := l_trip_segment_name;
		--
		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	--}
	EXCEPTION
	--{
	WHEN OTHERS THEN
	    wsh_util_core.default_handler('FTE_TRIPS_PVT.GET_TRIP_SEGMENT_NAME');
	    FND_MESSAGE.SET_NAME('FTE','FTE_GET_TRIP_SEG_NAME_ERROR');
	    FND_MESSAGE.SET_TOKEN('TRIP_SEGMENT_ID',p_trip_segment_id);
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	--}
END GET_TRIP_SEGMENT_NAME;

--
PROCEDURE GET_SHIPMENT_INFORMATION
	(p_init_msg_list           IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_tender_number		  IN	 NUMBER,
	x_return_status           OUT NOCOPY    VARCHAR2,
	x_msg_count               OUT NOCOPY    NUMBER,
	x_msg_data                OUT NOCOPY    VARCHAR2,
	x_shipment_info		  OUT NOCOPY	 VARCHAR2,
	x_shipping_org_name	  OUT NOCOPY	 VARCHAR2)
IS

	--{
        l_api_name              CONSTANT VARCHAR2(30)   := 'GET_SHIPMENT_INFORMATION';
        l_api_version           CONSTANT NUMBER         := 1.0;

	l_trip_id		NUMBER;
	l_found_first_stop 	VARCHAR2(1);
	l_stop_id		NUMBER;

	l_init_weight_uom	VARCHAR2(10)	:=	NULL;
	l_init_volume_uom	VARCHAR2(10)	:=	NULL;
	l_stop_weight_measure	VARCHAR2(20);
	l_stop_volume_measure   VARCHAR2(20);
	l_stop_total_weight	NUMBER;
	l_stop_total_volume	NUMBER;

	l_pickup_location_id	NUMBER;
	l_planned_arrival_date  DATE;
	l_planned_departure_date DATE;
	l_dropoff_location_id	NUMBER;
	l_pickup_location	VARCHAR2(1000);
	l_dropoff_location	VARCHAR2(1000);

	l_stop_count		NUMBER;
	l_loop_count		NUMBER	:= 1;
	l_mssg_text		VARCHAR2(1000);

	-- Cursor to get trip stop info
	--
	CURSOR get_trip_stop_info_cur (c_trip_id IN NUMBER)
	IS
	SELECT departure_gross_weight, weight_uom_code,
		   departure_volume,volume_uom_code,
		   wt.unit_of_measure_tl weight, vol.unit_of_measure_tl volume ,
		   st.stop_id stopid,st.planned_arrival_date, st.planned_departure_date,
		   st.stop_location_id
	FROM wsh_trip_stops st,mtl_units_of_measure wt, mtl_units_of_measure vol
	WHERE st.trip_id = c_trip_id
	AND wt.UOM_CODE (+)= st.weight_uom_code
	AND vol.UOM_CODE (+)= st.volume_uom_code
	order by st.stop_sequence_number;
	---
	--
	-- Cursor to get org info
	--
	CURSOR get_org_info_cur	(c_stop_id IN NUMBER)
	IS
	SELECT distinct(org.organization_name) org_name
	FROM wsh_delivery_legs dlegs, wsh_new_deliveries dlvy,
		wsh_trip_stops stops, org_organization_definitions  org
	WHERE dlegs.delivery_id = dlvy.delivery_id
	AND dlegs.pick_up_stop_id  = stops.stop_id
	AND org.organization_id = dlvy.organization_id
	AND stops.stop_id = c_stop_id;
	--

	--}
BEGIN
	--{

	-- Get Trip id

        SAVEPOINT   GET_SHIPMENT_INFORMATION_PUB;

	IF FND_API.to_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;

	l_trip_id	:= GET_TRIP_BY_TENDER_NUMBER(p_tender_number);

	IF (l_trip_id = -9999)
	THEN
	    	FND_MESSAGE.SET_NAME('FTE','FTE_INVLD_TEND_NUM_NOTRIP');
	    	FND_MESSAGE.SET_TOKEN('TENDER_NUMBER',p_tender_number);
		WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    	RAISE FND_API.G_EXC_ERROR;
	END IF;

	--get the stop information
	-- first get the stop info. get the first stop and find out the
	-- deliveries on it. the find the org name from there
	--

	-- first get the stop count
	SELECT count(*) INTO l_stop_count FROM WSH_TRIP_STOPS
	WHERE TRIP_ID = l_trip_id;

	l_found_first_stop := NULL;

	x_shipment_info	 := NULL;
	FOR get_trip_stop_info_rec IN get_trip_stop_info_cur(l_trip_id)
	LOOP
		--{
			l_stop_id := get_trip_stop_info_rec.STOPID;
			l_pickup_location_id := get_trip_stop_info_rec.stop_location_id;
			l_planned_departure_date := get_trip_stop_info_rec.planned_departure_date;
			l_stop_total_weight := get_trip_stop_info_rec.departure_gross_weight;
			l_stop_total_volume := get_trip_stop_info_rec.departure_volume;
			l_stop_weight_measure := get_trip_stop_info_rec.weight;
			l_stop_volume_measure := get_trip_stop_info_rec.volume;

			-- now find the org info based on this stop
			IF (l_loop_count = 1)
			THEN
			--IF (l_found_first_stop IS NULL)
			--THEN
				l_found_first_stop := 'Y';

				FOR get_org_info_rec IN get_org_info_cur(l_stop_id)
				LOOP
				--{
					x_shipping_org_name := get_org_info_rec.org_name;

				--}
				END LOOP;
				-- END OF get_org_info
				IF get_org_info_cur%ISOPEN THEN
				  CLOSE get_org_info_cur;
				END IF;
			END IF;
			-- build shipment info
			-- Get the weight volume info
			--
			--
			l_pickup_location := NULL;

			FTE_MLS_UTIL.get_location_info(l_pickup_location_id,
							l_pickup_location,x_return_status);

			IF (l_loop_count = 1)
			THEN
				FND_MESSAGE.SET_NAME('FTE', 'FTE_MLS_TENDER_EMAIL_HDR_PU');
				l_mssg_text := FND_MESSAGE.GET;
				x_shipment_info := l_mssg_text;

				--x_shipment_info	:= 'Shipment Pickup Information:' || FND_GLOBAL.TAB ||
				--	   'Date and Time,' || FND_GLOBAL.TAB ||
				--	   FND_GLOBAL.TAB || 'Weight,' || FND_GLOBAL.TAB || 'Volume' ||
				--	   FND_GLOBAL.NEWLINE || 'Pickup Location:';
			ELSIF (l_loop_count = l_stop_count)
			THEN
				FND_MESSAGE.SET_NAME('FTE', 'FTE_MLS_TENDER_EMAIL_HDR_DO');
				l_mssg_text := FND_MESSAGE.GET;
				x_shipment_info := x_shipment_info || FND_GLOBAL.NEWLINE || l_mssg_text;

				--x_shipment_info	:= x_shipment_info || FND_GLOBAL.NEWLINE ||
				--		'Shipment Delivery Information:' || FND_GLOBAL.TAB ||
				--	   FND_GLOBAL.TAB || 'Date and Time,' || FND_GLOBAL.TAB ||
				--	   FND_GLOBAL.TAB || 'Weight,' || FND_GLOBAL.TAB || 'Volume' ||
				--	   FND_GLOBAL.NEWLINE || 'Dropoff Location:';
			ELSIF (l_loop_count < l_stop_count)
			THEN
				FND_MESSAGE.SET_NAME('FTE', 'FTE_MLS_TENDER_EMAIL_HDR_INT');
				l_mssg_text := FND_MESSAGE.GET;
				x_shipment_info := x_shipment_info || FND_GLOBAL.NEWLINE ||
							l_mssg_text ||' '|| (l_loop_count-1);

				--x_shipment_info	:= x_shipment_info || FND_GLOBAL.NEWLINE ||
				--		'Intermediate Location Information:' || FND_GLOBAL.TAB ||
				--	   FND_GLOBAL.TAB || 'Date and Time,' || FND_GLOBAL.TAB ||
				--	   FND_GLOBAL.TAB || 'Weight,' || FND_GLOBAL.TAB || 'Volume' ||
				--	   FND_GLOBAL.NEWLINE || 'Intermediate Location:' || (l_loop_count-1);
			END IF;

			x_shipment_info := x_shipment_info || FND_GLOBAL.NEWLINE ||
					   l_pickup_location || FND_GLOBAL.TAB ||
					   l_planned_departure_date || FND_GLOBAL.TAB ||
					   to_char(l_stop_total_weight) || ' ' || l_stop_weight_measure ||
					   FND_GLOBAL.TAB ||
					   to_char(l_stop_total_volume) || ' ' || l_stop_volume_measure ||
					   FND_GLOBAL.NEWLINE;


			l_loop_count	:= l_loop_count+1;
		--}
	END LOOP;
	-- END OF  get_trip_stop_info_cur
	--
	--
	IF get_trip_stop_info_cur%ISOPEN THEN
	  CLOSE get_trip_stop_info_cur;
	END IF;
	--

	--}
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_SHIPMENT_INFORMATION_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_SHIPMENT_INFORMATION_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
       WHEN OTHERS THEN
                ROLLBACK TO GET_SHIPMENT_INFORMATION_PUB;
                wsh_util_core.default_handler('FTE_TRIPS_PVT.GET_SHIPMENT_INFORMATION');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}
END GET_SHIPMENT_INFORMATION;
--
--
--
--============================================================================
-- PROCEDURE : Get_Trip_Info_From_Dlvy
--
-- COMMENT   : Sums converted weight and volume picked-up on all stops on trip
--============================================================================
PROCEDURE GET_TRIP_INFO_FROM_DLVY
		(p_tender_number		  IN	 NUMBER,
	 	 p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
		 x_return_status          OUT NOCOPY    VARCHAR2,
 		 x_msg_count              OUT NOCOPY    NUMBER,
		 x_msg_data               OUT NOCOPY    VARCHAR2,
		 x_total_weight		  OUT NOCOPY NUMBER,
		 x_weight_uom		  OUT NOCOPY VARCHAR2,
		 x_total_volume		  OUT NOCOPY NUMBER,
		 x_volume_uom		  OUT NOCOPY VARCHAR2)
IS

	--{
		l_api_name              CONSTANT VARCHAR2(30)   := 'GET_TRIP_INFO_FROM_DLVY';
        	l_api_version           CONSTANT NUMBER         := 1.0;

		l_trip_id 			NUMBER := 0;
		l_trip_weight_measure	VARCHAR2(20);
		l_trip_volume_measure   VARCHAR2(20);
		l_trip_total_weight	NUMBER := 0;
		l_trip_total_volume	NUMBER := 0;

		-- Cursor to get total weight and vol info by delivery
		CURSOR get_dlvy_weight_vol_cur (c_trip_id IN NUMBER)
		IS
		SELECT delivery_id, gross_weight, weight_uom_code, volume, volume_uom_code
		FROM wsh_new_deliveries
		WHERE delivery_id IN
			(SELECT distinct(wdl.delivery_id)
  			 FROM wsh_trip_stops wts, --t
				wsh_delivery_legs wdl --d
			 WHERE wdl.pick_up_stop_id = wts.stop_id
			 AND wts.trip_id = l_trip_id);
	--}

BEGIN
	--{
	-- Get Trip id

	SAVEPOINT   GET_TRIP_INFO_FROM_DLVY_PUB;

	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;


	l_trip_id	:= GET_TRIP_BY_TENDER_NUMBER(p_tender_number);

	IF (l_trip_id = -9999)

	THEN
	    	FND_MESSAGE.SET_NAME('FTE','FTE_INVLD_TEND_NUM_NOTRIP');
	    	FND_MESSAGE.SET_TOKEN('TENDER_NUMBER',p_tender_number);
		WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
	    	RAISE FND_API.G_EXC_ERROR;
	END IF;

	l_trip_weight_measure := NULL;
	l_trip_volume_measure := NULL;

	-- get the weight volume information from the delivery
	FOR get_dlvy_weight_vol_rec IN get_dlvy_weight_vol_cur(l_trip_id)
	LOOP
		--{

			-- set preferred uom to first delivery found
			IF (l_trip_weight_measure IS NULL
				AND get_dlvy_weight_vol_rec.weight_uom_code IS NOT NULL)
			THEN
				l_trip_weight_measure := get_dlvy_weight_vol_rec.weight_uom_code;
			END IF;

	 		IF (l_trip_volume_measure IS NULL
				AND get_dlvy_weight_vol_rec.volume_uom_code IS NOT NULL )
			THEN
				l_trip_volume_measure := get_dlvy_weight_vol_rec.volume_uom_code;
			END IF;

			-- convert then sum weight, volume
			IF (get_dlvy_weight_vol_rec.gross_weight IS NOT NULL
				AND get_dlvy_weight_vol_rec.weight_uom_code IS NOT NULL)
			THEN
				l_trip_total_weight := l_trip_total_weight +
				WSH_WV_UTILS.convert_uom(get_dlvy_weight_vol_rec.weight_uom_code,
								 l_trip_weight_measure,
								 get_dlvy_weight_vol_rec.gross_weight,
								 0); -- Within same UOM class

			END IF;

			IF (get_dlvy_weight_vol_rec.volume IS NOT NULL
				AND get_dlvy_weight_vol_rec.volume_uom_code IS NOT NULL )
			THEN

				l_trip_total_volume := l_trip_total_volume +
				WSH_WV_UTILS.convert_uom(get_dlvy_weight_vol_rec.volume_uom_code,
								 l_trip_volume_measure,
								 get_dlvy_weight_vol_rec.volume,
								 0); -- Within same UOM class
			END IF;

		--};

	END LOOP;

	-- END OF get_dlvy_weight_vol_cur

	x_total_weight := l_trip_total_weight;
	x_total_volume := l_trip_total_volume;
	x_weight_uom := l_trip_weight_measure;
	x_volume_uom := l_trip_volume_measure;

	--dbms_output.put_line(' weight: ' || x_total_weight || x_weight_uom || ' - volume: ' || x_total_volume || x_volume_uom );

	--
	--
	IF get_dlvy_weight_vol_cur%ISOPEN THEN
	  CLOSE get_dlvy_weight_vol_cur;
	END IF;
	--

--}
--
	EXCEPTION
    	--{
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO GET_TRIP_INFO_FROM_DLVY_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO GET_TRIP_INFO_FROM_DLVY_PUB;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );
       WHEN OTHERS THEN
                ROLLBACK TO GET_TRIP_INFO_FROM_DLVY_PUB;
                wsh_util_core.default_handler('FTE_TRIPS_PVT.GET_TRIP_INFO_FROM_DLVY');
                x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                  (
                     p_count  => x_msg_count,
                     p_data  =>  x_msg_data,
	             p_encoded => FND_API.G_FALSE
                  );

	--}

END GET_TRIP_INFO_FROM_DLVY;

--
--
--
END FTE_TRIPS_PVT;

/
