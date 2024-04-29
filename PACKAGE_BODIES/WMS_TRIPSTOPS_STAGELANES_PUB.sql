--------------------------------------------------------
--  DDL for Package Body WMS_TRIPSTOPS_STAGELANES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TRIPSTOPS_STAGELANES_PUB" AS
/* $Header: WMSDKTSB.pls 120.4.12010000.2 2008/08/19 09:54:02 anviswan ship $ */

PROCEDURE trace(p_message IN VARCHAR2) iS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
        inv_pick_wave_pick_confirm_pub.tracelog(err_msg => p_message,
					         module  => 'WMSDKTSB: ');
END trace;

PROCEDURE get_stgln_for_tripstop(
            x_return_status               OUT NOCOPY VARCHAR2
   				, x_msg_count                   OUT NOCOPY NUMBER
   				, x_msg_data                    OUT NOCOPY VARCHAR2
   				, p_org_id                      IN         NUMBER
   				, p_trip_stop                   IN         NUMBER
   				, x_stg_ln_id                   OUT NOCOPY NUMBER
   				, x_sub_code                    OUT NOCOPY VARCHAR2)
IS
	l_chk_dkdr_trpstp_exts  BOOLEAN;
	l_dock_id               NUMBER := 0;
	l_staging_lane_id       NUMBER := 0;
	l_stg_ln_id             NUMBER := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (l_debug = 1) THEN
   	trace('in getstgln for tripstop');
   	trace('org id ' || to_char(p_org_id));
   	trace('trip_stop' || to_char(p_trip_stop));
	END IF;
	  check_dockdoor_tripstop_exists(  x_return_status
                                 , x_msg_count
                                 , x_msg_data
                                 , p_trip_stop
                                 , l_dock_id
                                 , l_staging_lane_id
                                 , l_chk_dkdr_trpstp_exts);

	 IF (l_debug = 1) THEN
   	 trace ('After check_dockdoor_tripstop_exists.');
   	 trace('PROCEDURE get_stgln_for_tripstop dock door id =  ' || l_dock_id);
   	 trace('PROCEDURE get_stgln_for_tripstop staging lane id = ' || l_staging_lane_id);
   	trace(' return status' || x_return_status);
	 END IF;


/*******************************************************************************************************/
/* If a record already exists for trip stop in wms_dock_appointments,_b then 'l_chk_dkdr_trpstp_exts'  */
/* will be set to TRUE. The trip stop/dock door relationship has to be exist beforehand.If it doesn't  */
/* exist this API will exit. If the trip stop/dock door relationship already exists, then check if a   */
/* staging lane is already/*assigned to this trip stop. If a staging lane is not already assigned then */
/* 'l_staging_lane_id' will be set to '0'  and the /*dock door id will be returned in 'l_dock_id'.     */
/* If a staging lane is already assigned then 'l_staging_lane_id' will be set to that staging lane and */
/* will be returned alongwith the 'l_dock_id'. In this case a message will be given that a staging lane*/
/* already exists for this trip stop and will be passed to the calling	program.		       */
/*******************************************************************************************************/

  IF (l_chk_dkdr_trpstp_exts AND l_dock_id <> 0 AND  nvl(l_staging_lane_id,0)=0)
  --If the trip stop doesn't have a staging lane assigned then...
    THEN
      x_stg_ln_id := get_available_staginglane( x_return_status
                                              , x_msg_count
                                              , x_msg_data
                                              , p_trip_stop
                                              , l_dock_id);
      l_stg_ln_id := x_stg_ln_id;

      IF (l_debug = 1) THEN
         trace('no staaging lane . so assigned it to l_stg_ln_id = ' || l_stg_ln_id );
   	trace('return status from get available staging lane' || x_return_status);
      END IF;
      IF l_stg_ln_id <> -1 THEN
    	  x_sub_code := get_subinventory_code( x_return_status
    	                                     , x_msg_count
    	                                     , x_msg_data
    	                                     , p_org_id
    	                                     , l_stg_ln_id);
	IF (l_debug = 1) THEN
   	trace('return status from get_subinventory code' || x_return_status);
	END IF;
      ELSE
         x_stg_ln_id := NULL;
         x_sub_code := NULL;
      END IF;

     IF (l_debug = 1) THEN
        trace('PROCEDURE get_stgln_for_tripstop  - IF (chk_dkdr_trpstp_exts AND  l_staging_lane_id = 0)staging lane id returned =  ' || l_stg_ln_id);
        trace('PROCEDURE get_stgln_for_tripstop  - IF (chk_dkdr_trpstp_exts AND  l_staging_lane_id = 0) Subinventory Code returned =  ' || x_sub_code);
     END IF;

  ELSIF (l_staging_lane_id <> 0)
  --If a staging lane already exists for this trip stop, then return the staging lane id to the calling
  --program.
  THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_STGLN_ASSIGNED');
      FND_MSG_PUB.ADD;
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
         trace('Staging lane already exists for this trip stop');
      END IF;

      x_stg_ln_id := l_staging_lane_id;
      l_stg_ln_id := l_staging_lane_id;

      IF (l_debug = 1) THEN
         trace('Before call to  x_sub_code := get_subinventory_code');
      END IF;

      x_sub_code := get_subinventory_code( x_return_status
                                         , x_msg_count
                                         , x_msg_data
                                         , p_org_id
                                         , x_stg_ln_id);

      IF (l_debug = 1) THEN
         trace('PROCEDURE get_stgln_for_tripstop  - IF (chk_dkdr_trpstp_exts AND  l_staging_lane_id = 0)staging lane id returned =  ' || l_stg_ln_id);
         trace('PROCEDURE get_stgln_for_tripstop  - IF (chk_dkdr_trpstp_exts AND  l_staging_lane_id = 0) Subinventory Code returned =  ' || x_sub_code);
      END IF;


  ELSIF ((l_dock_id = 0) AND (l_staging_lane_id <> 0))
  --check if the trip stop has a dock door assigned.
  THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DKDR_NOT_EXISTS');
      FND_MSG_PUB.ADD;
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data =>  x_msg_data);

      IF (l_debug = 1) THEN
         trace('Dock Door not associated to trip stop');
      END IF;

  END IF;

END get_stgln_for_tripstop;

----------------------------------------------------------------------------------------------------------
/****************************************************************************************************/
/* This procedure checks if any of the staging lanes associated with the dock door is available.    */
/* The dock door associated with the trip stop and the staging lanes associated with the dock       */
/* is derived in the function "check_dkdr_trpstp_exists".For every staging lane associated with     */
/* the dock door, this procedure calls function "check_assigned_staginglanes"( checks for staging   */
/* lanes which have been already assigned). If an available staging lane is not found, then         */
/* we check for the earliest available staging lane and return that staging lane to the calling     */
/* program as well as updated in table "wms_dock_appointments_b" for the trip stop in question.     */
/****************************************************************************************************/

FUNCTION get_available_staginglane(
              x_return_status               OUT NOCOPY VARCHAR2
   				  , x_msg_count                   OUT NOCOPY NUMBER
   				  , x_msg_data                    OUT NOCOPY VARCHAR2
   				  , p_trip_stop                   IN         NUMBER
   				  , p_dock_id                     IN         NUMBER)
RETURN NUMBER
IS
    CURSOR  get_stglanes_for_dkdr_cur  IS
    SELECT  stage_lane_id
    FROM    wms_staginglanes_assignments
    WHERE   dock_door_id = p_dock_id
    AND     enabled = 'Y'
    -- Bug# 4612553: Available staging lanes should be ordered by the number entry sequence
    ORDER BY entry_sequence;

    x_staging_lane_id  NUMBER:= 0;
    l_loop_counter     NUMBER:= 0;

    get_stglanes_for_dkdr_rec get_stglanes_for_dkdr_cur%rowtype;

    l_cur_staging_lane_id NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    OPEN get_stglanes_for_dkdr_cur;
    IF (l_debug = 1) THEN
       trace('FUNCTION get_available_staginglane trip stop id = ' || p_trip_stop);
       trace('FUNCTION get_available_staginglane dock door id = ' || p_dock_id);
    END IF;
    LOOP
      IF (l_debug = 1) THEN
         trace('loop counter = ' || l_loop_counter);
      END IF;
      FETCH get_stglanes_for_dkdr_cur into get_stglanes_for_dkdr_rec;
      IF (l_debug = 1) THEN
         trace('after fetch');
      END IF;
      EXIT WHEN get_stglanes_for_dkdr_cur%NOTFOUND;
      l_loop_counter := l_loop_counter + 1;
      IF (l_debug = 1) THEN
         trace('loop counter = ' || l_loop_counter);
      END IF;

      IF (l_debug = 1) THEN
         trace('get_stglanes_for_dkdr_rec.stage_lane_id = : ' || get_stglanes_for_dkdr_rec.stage_lane_id);
      END IF;
      l_cur_staging_lane_id := get_stglanes_for_dkdr_rec.stage_lane_id;

      x_staging_lane_id := check_if_stagelane_assigned(  x_return_status
                                                       , x_msg_count
                                                       , x_msg_data
                                                       , get_stglanes_for_dkdr_rec.stage_lane_id
                                                       , p_trip_stop
                                                       , p_dock_id);

      IF (l_debug = 1) THEN
         trace('FUNCTION get_available_staginglane loop counter = ' || l_loop_counter);
         trace('FUNCTION get_available_staginglane staging lane id = ' || x_staging_lane_id);
   	trace('return status from  checkif stagelane assigned= ' || x_return_status);
      END IF;

        --IF (x_staging_lane_id <> 0) or (x_staging_lane_id <> 1) THEN
      IF x_staging_lane_id  not in (0,1)
      THEN
          IF (l_debug = 1) THEN
             trace('FUNCTION get_available_staginglane- IF (x_staging_lane_id <> 0)- staging lane id =  ' || x_staging_lane_id);
          END IF;
          CLOSE get_stglanes_for_dkdr_cur;
          RETURN x_staging_lane_id;
      END IF;

    END LOOP;

    --CLOSE get_stglanes_for_dkdr_cur;

    IF (l_loop_counter = 0 )
    THEN
         IF (l_debug = 1) THEN
            trace('No staging lanes assigned to Dock Door');
         END IF;
         FND_MESSAGE.SET_NAME('WMS', 'WMS_NO_ASSIGNED_STGLNS_FOR_DKDR');
         FND_MSG_PUB.ADD;
         --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);


         CLOSE get_stglanes_for_dkdr_cur;

     ELSIF (l_loop_counter = 1 ) AND  x_staging_lane_id = 0 THEN  --bug 5117541
       --means only one staging lane is associated with the dock-door and
       -- this staging lane IS occupied BY anohter trip. This CASE will arise
       -- WHEN the Sales ORDER has multiple trip AND ALL trips have
       -- concurrent dock-door appointment AT the same dock-door

       IF (l_debug = 1) THEN
	  trace('Only one Staging lane in dock-door and engaged - still	ASSIGN it');
       END IF;

        update_staging_lane_id( x_return_status
  	                          , x_msg_count
  	                          , x_msg_data
  	                          , l_cur_staging_lane_id
  	                          , p_trip_stop
  	                          , p_dock_id);

       CLOSE get_stglanes_for_dkdr_cur;
     RETURN l_cur_staging_lane_id;

    END IF;

    CLOSE get_stglanes_for_dkdr_cur;

    IF (l_debug = 1) THEN
       trace('Out of the loop means  that all the staging lanes are taken.');
    END IF;

      IF x_staging_lane_id in(0,1)
      THEN
  	    IF (l_debug = 1) THEN
     	    trace('Inside IF x_staging_lane_id in(0,1)  THEN : dock id = ' || p_dock_id);
  	    END IF;


	    x_staging_lane_id :=  get_earliest_available_stglane(p_dock_id);

  	    IF (l_debug = 1) THEN
     	    trace('After get_earliest_available_stglane has returned staging lane id =  ' || x_staging_lane_id);
  	    END IF;

  	    update_staging_lane_id( x_return_status
  	                          , x_msg_count
  	                          , x_msg_data
  	                          , x_staging_lane_id
  	                          , p_trip_stop
  	                          , p_dock_id);

  	    IF (l_debug = 1) THEN
     	    trace('After get_earliest_available_stglane(p_dock_id) Staging lane_id = '|| x_staging_lane_id);
  	    END IF;
            RETURN x_staging_lane_id;
	IF (l_debug = 1) THEN
   	trace('the status returned from update staging lane id is ' || x_return_status);
	END IF;
      END IF;

EXCEPTION
   WHEN no_data_found THEN
   IF (l_debug = 1) THEN
      trace('No staging lanes exist for dock door assigned to this trip stop');
   END IF;
   RETURN -1;

   WHEN others THEN
   IF (l_debug = 1) THEN
      trace('SQL error code '|| sqlcode||', error message '||sqlerrm);
   END IF;
   RETURN -1;

END get_available_staginglane;
----------------------------------------------------------------------------------------------------------------
/****************************************************************************************************/
/* For every staging lane returned by the cursor "get_stglanes_for_dkdr_cur", we check if           */
/* it exists in table wms_dock_appointments_b. If it exists then we move on to the next             */
/* staging lane assigned to the dock door. The staging lane (p_stg_lane_id) is returned if          */
/* this staging lane has not been assigned to any appointments in wms_dock_appointments_b           */
/****************************************************************************************************/

FUNCTION check_if_stagelane_assigned(
              x_return_status               OUT NOCOPY VARCHAR2
				    , x_msg_count                   OUT NOCOPY NUMBER
				    , x_msg_data                    OUT NOCOPY VARCHAR2
				    , p_stg_lane_id                 IN         NUMBER
				    , p_trip_stop                   IN         NUMBER
				    , p_dock_id                     IN         NUMBER)
RETURN NUMBER
IS
        l_dummy  NUMBER := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
   	trace('Before select in FUNCTION check_if_stagelane_assigned');
	END IF;

        -- Bug 4915199, changing 'trunc(end_time)>=trunc(sysdate)' to 'end_time>=sysdate'
        --   to take time of the day into consideration.

        SELECT 1 into l_dummy
	FROM DUAL WHERE EXISTS (SELECT staging_lane_id
				FROM   wms_dock_appointments_b
				WHERE  staging_lane_id = p_stg_lane_id
				and  end_time>=sysdate);

	-- Bug 3122401. SQL was considering old appointments also. This is
	-- incorrect. A Staging lane should only be considered as
	--	unavailable IF it has an appointment FOR the same day OR
	-- the future
	IF (l_debug = 1) THEN
   	trace('Staging lane has been already assigned and so return is 0');
	END IF;

	RETURN 0;


EXCEPTION
   WHEN no_data_found  THEN
       update_staging_lane_id(  x_return_status
                              , x_msg_count
                              , x_msg_data
                              , p_stg_lane_id
                              , p_trip_stop
                              , p_dock_id);
       RETURN p_stg_lane_id;
       IF (l_debug = 1) THEN
          trace('Exception WHEN NO_DATA_FOUND in FUNCTION check_if_stagelane_assigned');
       END IF;

  WHEN too_many_rows  THEN
     IF (l_debug = 1) THEN
        trace('Exception WHEN too_many_rows in FUNCTION check_if_stagelane_assigned');
     END IF;
     RETURN 1;

  WHEN others THEN
     IF (l_debug = 1) THEN
        trace('Exception WHEN OTHERS in FUNCTION check_if_stagelane_assigned');
     END IF;
     RETURN 1;

END check_if_stagelane_assigned;


/****************************************************************************************************/
/*											            */
/*											            */
/*											            */
/****************************************************************************************************/

FUNCTION get_earliest_available_stglane( p_dock_id  IN  NUMBER)
RETURN NUMBER
IS
     x_stage_id            NUMBER := 0;
     l_date_end_time       VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	  IF (l_debug = 1) THEN
   	  trace('FUNCTION get_earliest_available_stglane - dock door id passed = ' || p_dock_id);
	  END IF;


          -- Bug 4915199, changing 'trunc(end_time)>=trunc(sysdate)' to 'end_time>=sysdate'
          --   to take time of the day into consideration.

      BEGIN
	  SELECT  staging_lane_id, to_char(end_time, 'DD-MON-YY HH:MI:SS')
          INTO   x_stage_id, l_date_end_time
          FROM   wms_dock_appointments_b
          WHERE  end_time = (SELECT min(end_time)
                                FROM   wms_dock_appointments_b
                                WHERE  dock_id  = p_dock_id
                                  AND    staging_lane_id is not NULL
                                  AND    end_time>=sysdate)
               AND    staging_lane_id is not NULL
               AND rownum = 1
               AND dock_id=p_dock_id;
      EXCEPTION
        when others then
            x_stage_id:= null;
           l_date_end_time := null;
      END;


	-- Bug 3122401. SQL was considering old appointments also. This is
          -- incorrect. A Staging lane should only be considered as
          -- unavailable IF it has an appointment FOR the same day OR
	  -- the future. Also the staging lane selected was not limited to
          --   the same dock door


  	  IF (l_debug = 1) THEN
     	  trace('FUNCTION get_earliest_available_stglane - Stage lane id selected =  ' || x_stage_id);
     	  trace('FUNCTION get_earliest_available_stglane - End time =  ' || l_date_end_time);
  	  END IF;

   	  RETURN x_stage_id;

EXCEPTION
   WHEN no_data_found  THEN
    IF (l_debug = 1) THEN
       trace('WHEN NO_DATA_FOUND in FUNCTION get_earliest_available_stglane');
    END IF;
   null;

   WHEN OTHERS THEN
    IF (l_debug = 1) THEN
       trace('when other in get_earliest_availabe_stglane');
    END IF;
   null;
END get_earliest_available_stglane;


/****************************************************************************************************/
/*												    */
/*												    */
/*												    */
/****************************************************************************************************/

PROCEDURE check_dockdoor_tripstop_exists(
              x_return_status              OUT NOCOPY VARCHAR2
   					, x_msg_count                  OUT NOCOPY NUMBER
   					, x_msg_data                   OUT NOCOPY VARCHAR2
   					, p_trip_stop                  IN         NUMBER
   					, x_dock_id                    OUT NOCOPY NUMBER
   					, x_staging_lane_id            OUT NOCOPY NUMBER
   					, x_dkdr_trpstp_exists	       OUT NOCOPY BOOLEAN)
IS
      -- l_dkdr_trpstp_exists BOOLEAN := TRUE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF (l_debug = 1) THEN
       trace('Before select in FUNCTION check_dockdoor_tripstop_exists trip stop =  ' || p_trip_stop);
    END IF;

    -- Bug 4915199, adding filter on end_date to choose earliest future date.
    SELECT nvl(dock_id,0), nvl(staging_lane_id ,0)
    INTO  x_dock_id, x_staging_lane_id
    FROM  wms_dock_appointments_b
    WHERE trip_stop = p_trip_stop
      and end_time = (SELECT min(end_time)
                        FROM wms_dock_appointments_b
                        WHERE trip_stop = p_trip_stop
                          and end_time >= sysdate)
      and rownum = 1;

    IF (l_debug = 1) THEN
       trace('FUNCTION check_dockdoor_tripstop_exists dock door id ' || x_dock_id);
       trace('FUNCTION check_dockdoor_tripstop_exists staging lane id ' || x_staging_lane_id);
    END IF;

    x_dkdr_trpstp_exists := TRUE ;
    x_return_status := FND_API.G_RET_STS_SUCCESS; --returns success value

EXCEPTION
   WHEN no_data_found THEN
      IF (l_debug = 1) THEN
         trace('There is no trip stop with this number' || p_trip_stop );
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_NO_TRIPSTOP_EXISTS');
      FND_MSG_PUB.ADD;
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
                (
                   p_count         =>      x_msg_count
                 , p_data          =>      x_msg_data
                 );


      x_dkdr_trpstp_exists := FALSE ;
      x_dock_id := 0;
      x_staging_lane_id := 0;

      IF (l_debug = 1) THEN
         trace('FUNCTION check_dockdoor_tripstop_exists trip stops' || p_trip_stop);
         trace('FUNCTION check_dockdoor_tripstop_exists dock id' || x_dock_id);
         trace('FUNCTION check_dockdoor_tripstop_exists staging lane id' || x_staging_lane_id);
      END IF;

      -- RETURN l_dkdr_trpstp_exists;

   WHEN TOO_MANY_ROWS THEN
      IF (l_debug = 1) THEN
         trace('There is more than one record which matches this trip stop');
      END IF;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_DUP_TRIPSTOPS');
      FND_MSG_PUB.ADD;
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
               (
                  p_count         =>      x_msg_count
                , p_data          =>      x_msg_data
                );

      x_dkdr_trpstp_exists := TRUE ;
      --x_dock_id := 0;
      --x_staging_lane_id := 0;
      --RETURN l_dkdr_trpstp_exists;

   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         trace('Inside When Others');
      END IF;
      x_dkdr_trpstp_exists := FALSE ;
      x_dock_id := 0;
      x_staging_lane_id := 0;
      -- RETURN l_dkdr_trpstp_exists;

END check_dockdoor_tripstop_exists;


/****************************************************************************************************/
/*												    */
/*												    */
/*												    */
/****************************************************************************************************/

PROCEDURE update_staging_lane_id(
            x_return_status               OUT NOCOPY VARCHAR2
   				, x_msg_count                   OUT NOCOPY NUMBER
   				, x_msg_data                    OUT NOCOPY VARCHAR2
   				, p_stage_lane_id               IN         NUMBER
   				, p_trip_stop                   IN         NUMBER
   				, p_dock_id                     IN         NUMBER)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SAVEPOINT update_dock_sp;
   --x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      trace('Before update PROCEDURE update_staging_lane_id = ' || p_stage_lane_id);
      trace('Before update PROCEDURE update_staging_lane_id = ' || p_trip_stop);
      trace('Before update PROCEDURE update_staging_lane_id = ' || p_dock_id);
   END IF;
   UPDATE wms_dock_appointments_b
   SET
 	  STAGING_LANE_ID = p_stage_lane_id,
 	  LAST_UPDATED_BY = 1,
 	  LAST_UPDATE_DATE = sysdate,
 	  LAST_UPDATE_LOGIN = 1
   WHERE  DOCK_ID   = p_dock_id
   AND    TRIP_STOP = p_trip_stop;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_debug = 1) THEN
      trace('After update PROCEDURE update_staging_lane_id');
   END IF;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO update_dock_sp;
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('WMS', 'WMS_DOCK_UPDATE_FAIL');
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,p_data => x_msg_data);

END update_staging_lane_id;


/****************************************************************************************************/
/*												    */
/*												    */
/*												    */
/****************************************************************************************************/
FUNCTION get_subinventory_code(
                x_return_status               OUT NOCOPY VARCHAR2
   			      , x_msg_count                   OUT NOCOPY NUMBER
   			      , x_msg_data                    OUT NOCOPY VARCHAR2
   			      , p_org_id                      IN         NUMBER
   			      , p_staging_lane_id             IN         NUMBER)
RETURN VARCHAR2
IS
     l_sub_code    VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    IF (l_debug = 1) THEN
       trace('Before select in FUNCTION get_subinventory_code Staging lane  =  '||p_staging_lane_id);
    END IF;

    SELECT subinventory_code
    INTO  l_sub_code
    FROM  mtl_item_locations
    WHERE INVENTORY_LOCATION_ID = p_staging_lane_id
    AND   ORGANIZATION_ID       = p_org_id;

    IF (l_debug = 1) THEN
       trace('FUNCTION get_subinventory_code staging lane id   = ' || p_staging_lane_id);
       trace('FUNCTION get_subinventory_code subinventory_code = ' || l_sub_code);
       trace('FUNCTION get_subinventory_code Organization Id   = ' || p_org_id);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS; -- returns success values
    RETURN l_sub_code;

EXCEPTION
   WHEN no_data_found THEN
	   IF (l_debug = 1) THEN
   	   trace('INSIDE exception no_data_found in  FUNCTION get_subinventory_code  Staging lane  =  '||p_staging_lane_id);
	   END IF;
	   l_sub_code := null;

	   IF (l_debug = 1) THEN
   	   trace('FUNCTION get_subinventory_code staging lane id   = ' || p_staging_lane_id);
   	   trace('FUNCTION get_subinventory_code subinventory_code = ' || l_sub_code);
   	   trace('FUNCTION get_subinventory_code Organization Id   = ' || p_org_id);
	   END IF;

	   FND_MESSAGE.SET_NAME('WMS', 'WMS_NO_SUBINV_ASSIGNED_TO_LOCATION');
	   FND_MSG_PUB.ADD;
	   --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
	   RETURN l_sub_code;

   WHEN too_many_rows THEN
      l_sub_code := null;
      FND_MESSAGE.SET_NAME('WMS', 'WMS_TOO_MANY_ROWS');
      FND_MSG_PUB.ADD;
      --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

      RETURN l_sub_code;

END get_subinventory_code;


END WMS_TRIPSTOPS_STAGELANES_PUB;


/
