--------------------------------------------------------
--  DDL for Package Body FTE_TL_RATING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TL_RATING" AS
/* $Header: FTEVTLRB.pls 120.14 2007/11/30 06:03:34 sankarun ship $ */



--Works only for a 2-stop trip

PROCEDURE Update_Distance_To_Next_Stop(
	p_trip_id IN NUMBER,
	x_return_status  OUT NOCOPY VARCHAR2)
IS
CURSOR get_trip_stops(c_trip_id IN NUMBER) IS
SELECT s.stop_id
FROM WSH_TRIP_STOPS s
WHERE s.trip_id=c_trip_id
ORDER BY s.stop_sequence_number;


l_distances dbms_utility.number_array;
l_stop_ids  dbms_utility.number_array;
l_distance_uom VARCHAR2(30);
l_weight NUMBER;
l_weight_uom VARCHAR2(30);

i NUMBER;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Update_Distance_To_Next_Stop','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_distances(1):=NULL;
	l_distance_uom:=NULL;

	FTE_TL_CACHE.FPA_Get_Trip_Info(
	    p_trip_id=>p_trip_id,
	    x_distance=>l_distances(1),
	    x_distance_uom=>l_distance_uom,
	    x_weight=>l_weight,
	    x_weight_uom=>l_weight_uom,
	    x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_fpa_get_trip_inf_fail;
	       END IF;
	END IF;

	i:=1;
	OPEN get_trip_stops(p_trip_id);
	FETCH get_trip_stops INTO l_stop_ids(i);
	WHILE (get_trip_stops%FOUND)
	LOOP

		i:=i+1;
		FETCH get_trip_stops INTO l_stop_ids(i);
	END LOOP;
	CLOSE get_trip_stops;

	IF (i <=3)
	THEN

		IF( (l_distances(1) IS NOT NULL ) AND (l_distance_uom IS NOT NULL))
		THEN
		    l_distances(2):=0;

		    FORALL i IN l_distances.FIRST..l_distances.LAST
		      UPDATE wsh_trip_stops
		      SET  	distance_to_next_stop = l_distances(i),
				distance_uom = l_distance_uom
		      WHERE stop_id = l_stop_ids(i);

		END IF;
	ELSE

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Update_Distance_To_Next_Stop:'||p_trip_id||' has more than 2 stops');

	END IF;



	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Distance_To_Next_Stop');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fpa_get_trip_inf_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Distance_To_Next_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fpa_get_trip_inf_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Distance_To_Next_Stop');


WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Distance_To_Next_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Distance_To_Next_Stop');


END Update_Distance_To_Next_Stop;



PROCEDURE Get_Vehicles_For_LaneSchedules(
	p_trip_id                  IN  NUMBER DEFAULT NULL,
	p_lane_rows 	IN dbms_utility.number_array,
	p_schedule_rows IN dbms_utility.number_array,
	p_vehicle_rows IN dbms_utility.number_array,
	x_vehicle_rows  OUT NOCOPY dbms_utility.number_array,
	x_lane_rows 	OUT NOCOPY dbms_utility.number_array,
	x_schedule_rows OUT NOCOPY dbms_utility.number_array,
	x_ref_rows	OUT NOCOPY dbms_utility.number_array,
	x_return_status        OUT NOCOPY Varchar2) IS




	--Gets the default vehicle for the lane through the carrier service level.
	CURSOR get_lane_def_vehicle (c_lane_id IN NUMBER) IS
	SELECT	c.default_vehicle_type_id
	FROM 	WSH_CARRIER_SERVICES c ,
		FTE_LANES l
	WHERE 	c.carrier_id=l.carrier_id and
		c.service_level=l.service_type_code and
		l.lane_id=c_lane_id;

	--Gets the default vehicle for the schedule through the carrier service level.
	CURSOR get_schedule_def_vehicle(c_schedule_id IN NUMBER) IS
	SELECT	c.default_vehicle_type_id
	FROM 	WSH_CARRIER_SERVICES c ,
		FTE_LANES l,
		FTE_SCHEDULES s
	WHERE 	c.carrier_id=l.carrier_id and
		c.service_level=l.service_type_code and
		s.schedules_id=c_schedule_id and
		s.lane_id=l.lane_id;

	--Gets all the vehicles for the carrier of the lane.

	CURSOR get_lane_carrier_vehicles(c_lane_id IN NUMBER) IS
	SELECT 	wcvt.vehicle_type_id,
		l.carrier_id
	FROM 	wsh_carrier_vehicle_types wcvt,
		fte_lanes l
	WHERE 	l.lane_id=c_lane_id
		and l.carrier_id=wcvt.carrier_id
		and wcvt.assigned_flag='Y';


	--Gets all the vehicles for the carrier of the schedule.
	CURSOR get_schedule_carrier_vehicles(c_schedule_id IN NUMBER) IS
	SELECT 	wcvt.vehicle_type_id,
		l.carrier_id
	FROM 	wsh_carrier_vehicle_types wcvt,
		fte_lanes l ,
		fte_schedules s
	WHERE 	s.schedules_id=c_schedule_id
		and l.lane_id=s.lane_id
		and l.carrier_id=wcvt.carrier_id
		and wcvt.assigned_flag='Y';

l_trip_vehicle_type NUMBER;
l_carrier_id NUMBER;
l_vehicle_type NUMBER;
l_vehicle_index NUMBER;
l_default_vehicle NUMBER;
l_index NUMBER;
l_carrier_hash dbms_utility.number_array;--indexed by carrier id has a pointer to l_vehicle_list
l_vehicle_list dbms_utility.number_array;

l_invalid_trip_vehicle dbms_utility.number_array;

i NUMBER;
j NUMBER;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Vehicles_For_LaneSchedules','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


 	l_trip_vehicle_type:=NULL;

 	IF (p_trip_id IS NOT NULL)
 	THEN

		FTE_TL_CACHE.Get_Vehicle_Type(p_trip_id => p_trip_id,
				 p_vehicle_item_id =>NULL,
				 x_vehicle_type => l_trip_vehicle_type,
				 x_return_status => l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail;
		       END IF;
		END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Trip:'||p_trip_id||' Trip Vehicle:'||l_trip_vehicle_type);

	i:=p_lane_rows.FIRST;
	j:=i;
	WHILE ((i IS NOT NULL) AND((p_lane_rows(i) IS NOT NULL) OR (p_schedule_rows(i) IS NOT NULL)) )
	LOOP

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Inputs Lane:'||p_lane_rows(i)||' Schedule:'||p_schedule_rows(i)||' Vehicle:'||p_vehicle_rows(i)||' Index:'||i);
		l_carrier_id:=NULL;
		IF (l_trip_vehicle_type IS NOT NULL)
		THEN
			--Need to check if trip vehicle is valid for the lane,assume it is not at  start
			l_invalid_trip_vehicle(i):=1;
		ELSE
			--No trip vehicle no need to check

			l_invalid_trip_vehicle(i):=0;
		END IF;

		IF (p_vehicle_rows.EXISTS(i) AND p_vehicle_rows(i) IS NOT NULL)
		THEN
			x_lane_rows(j):=p_lane_rows(i);
			x_schedule_rows(j):=p_schedule_rows(i);
			x_vehicle_rows(j):=p_vehicle_rows(i);
			x_ref_rows(j):=i;
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ouput with passed in  vehicle Lane:'||x_lane_rows(j)||' Schedule:'||x_schedule_rows(j)||' Vehicle:'||x_vehicle_rows(j)||' Index:'||j);
			j:=j+1;
		ELSE
			--Fetch all vehicle for the lane
			l_vehicle_type:=NULL;
			l_carrier_id:=NULL;
			IF(p_lane_rows(i) IS NOT NULL)
			THEN
				OPEN get_lane_carrier_vehicles(p_lane_rows(i));
				FETCH get_lane_carrier_vehicles INTO l_vehicle_type,l_carrier_id;
				IF((l_vehicle_type IS NOT NULL) AND (l_carrier_id IS NOT NULL) AND(NOT l_carrier_hash.EXISTS(l_carrier_id)))
				THEN
					l_vehicle_index:=l_vehicle_list.LAST;
					IF (l_vehicle_index IS NULL)
					THEN
						l_vehicle_index:=0;

					END IF;
					l_vehicle_index:=l_vehicle_index+1;

					l_carrier_hash(l_carrier_id):=l_vehicle_index;
					WHILE(get_lane_carrier_vehicles%FOUND)
					LOOP
						l_vehicle_list(l_vehicle_index):=l_vehicle_type;
						l_vehicle_index:=l_vehicle_index+1;

						--Check if the trip vehicle is valid
						IF ((l_invalid_trip_vehicle(i)=1) AND (l_trip_vehicle_type IS NOT NULL) AND (l_trip_vehicle_type=l_vehicle_type))
						THEN
							FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Trip vehicle:'||l_trip_vehicle_type||' Valid for lane:'||p_lane_rows(i));
							l_invalid_trip_vehicle(i):=0;
						END IF;

						FETCH get_lane_carrier_vehicles INTO l_vehicle_type,l_carrier_id;
					END LOOP;
					--End of vehicle list for a carrier
					l_vehicle_list(l_vehicle_index):=NULL;




				END IF;
				CLOSE get_lane_carrier_vehicles;

				l_default_vehicle:=NULL;
				OPEN get_lane_def_vehicle(p_lane_rows(i));
				FETCH get_lane_def_vehicle INTO l_default_vehicle;
				CLOSE get_lane_def_vehicle;

			ELSE
				OPEN get_schedule_carrier_vehicles(p_lane_rows(i));
				FETCH get_schedule_carrier_vehicles INTO l_vehicle_type,l_carrier_id;
				IF((l_vehicle_type IS NOT NULL) AND (l_carrier_id IS NOT NULL) AND(NOT l_carrier_hash.EXISTS(l_carrier_id)))
				THEN
					l_vehicle_index:=l_vehicle_list.LAST;
					IF (l_vehicle_index IS NULL)
					THEN
						l_vehicle_index:=0;

					END IF;
					l_vehicle_index:=l_vehicle_index+1;

					l_carrier_hash(l_carrier_id):=l_vehicle_index;
					WHILE(get_schedule_carrier_vehicles%FOUND)
					LOOP
						l_vehicle_list(l_vehicle_index):=l_vehicle_type;
						l_vehicle_index:=l_vehicle_index+1;

						--Check if the trip vehicle is valid
						IF ((l_invalid_trip_vehicle(i)=1) AND (l_trip_vehicle_type IS NOT NULL) AND (l_trip_vehicle_type=l_vehicle_type))
						THEN
							FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Trip vehicle:'||l_trip_vehicle_type||' Valid for Schedule:'||p_schedule_rows(i));
							l_invalid_trip_vehicle(i):=0;
						END IF;


						FETCH get_schedule_carrier_vehicles INTO l_vehicle_type,l_carrier_id;
					END LOOP;
					--End of vehicle list for a carrier
					l_vehicle_list(l_vehicle_index):=NULL;

				END IF;
				CLOSE get_schedule_carrier_vehicles;

				l_default_vehicle:=NULL;
				OPEN get_schedule_def_vehicle(p_schedule_rows(i));
				FETCH get_schedule_def_vehicle INTO l_default_vehicle;
				CLOSE get_schedule_def_vehicle;

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Default vehicle:'||l_default_vehicle||'  for schedule:'||p_schedule_rows(i));

			END IF;

			--Available vehicles for the lane/schedule as well as default is fetched at this point

			IF (l_trip_vehicle_type IS NOT NULL)
			THEN


				IF((l_carrier_id IS NOT NULL) AND (l_carrier_hash.EXISTS(l_carrier_id)) AND (l_invalid_trip_vehicle(i)=1))
				THEN

					l_index:=l_carrier_hash(l_carrier_id);
					IF(l_index IS NOT NULL)
					THEN
						WHILE((l_vehicle_list.EXISTS(l_index))
							AND(l_vehicle_list(l_index) IS NOT NULL)
							AND (l_invalid_trip_vehicle(i)=1))
						LOOP
							IF (l_vehicle_list(l_index)=l_trip_vehicle_type)
							THEN
								l_invalid_trip_vehicle(i):=0;

							END IF;

							l_index:=l_index+1;
						END LOOP;
					END IF;


				END IF;

				IF(l_invalid_trip_vehicle(i)=1)
				THEN
					x_vehicle_rows(j):=NULL;
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Invalid Vehicle');

				ELSE
					x_vehicle_rows(j):=l_trip_vehicle_type;

				END IF;

				x_lane_rows(j):=p_lane_rows(i);
				x_schedule_rows(j):=p_schedule_rows(i);
				x_ref_rows(j):=i;
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ouput with trip vehicle Lane:'||x_lane_rows(j)||' Schedule:'||x_schedule_rows(j)||' Vehicle:'||x_vehicle_rows(j)||' Index:'||j);
				j:=j+1;


			ELSIF(l_default_vehicle IS NOT NULL)
			THEN
				x_lane_rows(j):=p_lane_rows(i);
				x_schedule_rows(j):=p_schedule_rows(i);
				x_vehicle_rows(j):=l_default_vehicle;
				x_ref_rows(j):=i;
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ouput with default vehicle Lane:'||x_lane_rows(j)||' Schedule:'||x_schedule_rows(j)||' Vehicle:'||x_vehicle_rows(j)||' Index:'||j);
				j:=j+1;

			ELSIF(l_carrier_id IS NOT NULL)
			THEN
				IF (l_carrier_hash.EXISTS(l_carrier_id))
				THEN
					l_index:=l_carrier_hash(l_carrier_id);
					IF(l_index IS NOT NULL)
					THEN
						WHILE((l_vehicle_list.EXISTS(l_index))
							AND(l_vehicle_list(l_index) IS NOT NULL))
						LOOP
							x_lane_rows(j):=p_lane_rows(i);
							x_schedule_rows(j):=p_schedule_rows(i);
							x_vehicle_rows(j):=l_vehicle_list(l_index);
							x_ref_rows(j):=i;
							FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ouput with carrier vehicle Lane:'||x_lane_rows(j)||' Schedule:'||x_schedule_rows(j)||' Vehicle:'||x_vehicle_rows(j)||' Index:'||j);
							j:=j+1;


							l_index:=l_index+1;
						END LOOP;

					END IF;

				END IF;


			ELSE
			--No vehicles are present copy over input lanes to outputs

				x_lane_rows(j):=p_lane_rows(i);
				x_schedule_rows(j):=p_schedule_rows(i);
				x_vehicle_rows(j):=NULL;
				x_ref_rows(j):=i;
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ouput no vehicle:'||x_lane_rows(j)||' Schedule:'||x_schedule_rows(j)||' Vehicle:'||x_vehicle_rows(j)||' Index:'||j);
				j:=j+1;


			END IF;




		END IF;




		i:=p_lane_rows.NEXT(i);
	END LOOP;




	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicles_For_LaneSchedules');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Vehicles_For_LaneSchedules',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_vehicle_type_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicles_For_LaneSchedules');


WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Vehicles_For_LaneSchedules',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicles_For_LaneSchedules');


END Get_Vehicles_For_LaneSchedules;


PROCEDURE Update_Pricing_Required_Flag(
	p_trip_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS

	CURSOR lock_dlegs( c_trip_id IN NUMBER ) IS
	SELECT 	dl.reprice_required
	FROM 	wsh_delivery_legs dl ,
		wsh_trip_stops s
	WHERE 	dl.pick_up_stop_id = s.stop_id
		and s.trip_id=c_trip_id
	FOR UPDATE NOWAIT;


l_temp_rec VARCHAR2(1);
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Update_Pricing_Required_Flag','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	SAVEPOINT Update_Pricing_Required_Flag;

	OPEN lock_dlegs(p_trip_id);
	FETCH lock_dlegs INTO l_temp_rec;
	CLOSE lock_dlegs;

	UPDATE wsh_delivery_legs dl
	SET dl.reprice_required='N'
	WHERE 	dl.pick_up_stop_id IN
		(select s.stop_id FROM wsh_trip_stops s where
			s.trip_id=p_trip_id );

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Pricing_Required_Flag');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
WHEN others THEN
	ROLLBACK TO Update_Pricing_Required_Flag;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Pricing_Required_Flag',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Pricing_Required_Flag');


END Update_Pricing_Required_Flag;



PROCEDURE Check_Freight_Terms_Manifest(
	p_trip_id IN NUMBER,
	p_move_id IN NUMBER,
	x_term_manifest_flag OUT NOCOPY VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2) IS

-- count the number of deliveries which should not be rated due to freight term
   CURSOR c_check_trip_freight_term(c_trip_id IN NUMBER)
   IS
   SELECT count(wd.delivery_id)
   FROM   wsh_new_deliveries wd, wsh_global_parameters wgp
   WHERE (
	  ((wd.shipment_direction in ('I'))
	   and (wgp.rate_ib_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ib_dels_fgt_term <> wd.freight_terms_code)
	  )
   	  OR
	  ((wd.shipment_direction in ('D'))
	   and (wgp.rate_ds_dels_fgt_term_id is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ds_dels_fgt_term_id <> wd.freight_terms_code)
	  )
   	  OR
	  ((nvl(wd.shipment_direction,'O') in ('O','IO'))
           and (wgp.skip_rate_ob_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
 	   and (wgp.skip_rate_ob_dels_fgt_term = wd.freight_terms_code)
	  )
	 )
   AND    wd.delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id = c_trip_id
   	 AND   wts2.trip_id = c_trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);


   -- count the number of deliveries which should not be rated due to manifesting
  CURSOR c_check_trip_manifesting(c_trip_id IN NUMBER)
  IS
  SELECT count(a.delivery_id)
  FROM   wsh_new_deliveries a,
	 mtl_parameters b,
	 wsh_carriers c
  WHERE  a.organization_id = b.organization_id
  AND    a.carrier_id = c.carrier_id
  AND    c.manifesting_enabled_flag = 'Y'
  AND    b.carrier_manifesting_flag = 'Y'
  AND    a.delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id = c_trip_id
   	 AND   wts2.trip_id = c_trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);

-- count the number of deliveries which should not be rated due to freight term
   CURSOR c_check_move_freight_term(c_move_id IN NUMBER)
   IS
   SELECT count(wd.delivery_id)
   FROM   wsh_new_deliveries wd, wsh_global_parameters wgp
   WHERE (
	  ((wd.shipment_direction in ('I'))
	   and (wgp.rate_ib_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ib_dels_fgt_term <> wd.freight_terms_code)
	  )
   	  OR
	  ((wd.shipment_direction in ('D'))
	   and (wgp.rate_ds_dels_fgt_term_id is not null)
	   and (wd.freight_terms_code is not null)
	   and (wgp.rate_ds_dels_fgt_term_id <> wd.freight_terms_code)
	  )
   	  OR
	  ((nvl(wd.shipment_direction,'O') in ('O','IO'))
           and (wgp.skip_rate_ob_dels_fgt_term is not null)
	   and (wd.freight_terms_code is not null)
 	   and (wgp.skip_rate_ob_dels_fgt_term = wd.freight_terms_code)
	  )
	 )
   AND    wd.delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id IN (SELECT m.trip_id from fte_trip_moves m where m.move_id= c_move_id)
   	 AND   wts2.trip_id = wts1.trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);


   -- count the number of deliveries which should not be rated due to manifesting
  CURSOR c_check_move_manifesting(c_move_id IN NUMBER)
  IS
  SELECT count(a.delivery_id)
  FROM   wsh_new_deliveries a,
	 mtl_parameters b,
	 wsh_carriers c
  WHERE  a.organization_id = b.organization_id
  AND    a.carrier_id = c.carrier_id
  AND    c.manifesting_enabled_flag = 'Y'
  AND    b.carrier_manifesting_flag = 'Y'
  AND    a.delivery_id in
   	(SELECT wdl.delivery_id
   	 FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   	 WHERE wts1.trip_id IN (SELECT m.trip_id from fte_trip_moves m where m.move_id=c_move_id)
   	 AND   wts2.trip_id = wts1.trip_id
   	 AND   wts1.stop_id = wdl.pick_up_stop_id
   	 AND   wts2.stop_id = wdl.drop_off_stop_id
   	);

l_count NUMBER;
l_log_level     NUMBER;

BEGIN
	l_log_level:=FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Check_Freight_Terms_Manifest','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_term_manifest_flag:='N';
	IF (p_move_id IS NULL)
	THEN
	    -- validate freight term
	    l_count := 0;
	    OPEN c_check_trip_freight_term(p_trip_id);
	    FETCH c_check_trip_freight_term INTO l_count;
	    CLOSE c_check_trip_freight_term;
	    IF ( l_count > 0 ) THEN

	      x_term_manifest_flag:='Y';
	      FTE_FREIGHT_PRICING_UTIL.setmsg(
				  p_api			=> 'Check_Freight_Terms_Manifest',
				  p_exc			=> ' ',
				  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_FGT_TERM',
				  p_msg_type		=> 'W',
				  p_trip_id		=> p_trip_id);


	    END IF;

	    -- Manifesting validation
	    l_count := 0;
	    OPEN c_check_trip_manifesting(p_trip_id);
	    FETCH c_check_trip_manifesting INTO l_count;
	    CLOSE c_check_trip_manifesting;
	    IF ( l_count > 0 ) THEN
	      x_term_manifest_flag:='Y';
	      FTE_FREIGHT_PRICING_UTIL.setmsg(
				  p_api			=> 'Check_Freight_Terms_Manifest',
				  p_exc			=> ' ',
				  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_MAN',
				  p_msg_type		=> 'W',
				  p_trip_id		=> p_trip_id);



	    END IF;


	ELSE

	    -- validate freight term
	    l_count := 0;
	    OPEN c_check_move_freight_term(p_move_id);
	    FETCH c_check_move_freight_term INTO l_count;
	    CLOSE c_check_move_freight_term;
	    IF ( l_count > 0 ) THEN

	      x_term_manifest_flag:='Y';
	      FTE_FREIGHT_PRICING_UTIL.setmsg(
				  p_api			=> 'Check_Freight_Terms_Manifest',
				  p_exc			=> ' ',
				  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_FGT_TERM',
				  p_msg_type		=> 'W',
				  p_move_id		=> p_move_id);


	    END IF;

	    -- Manifesting validation
	    l_count := 0;
	    OPEN c_check_move_manifesting(p_move_id);
	    FETCH c_check_move_manifesting INTO l_count;
	    CLOSE c_check_move_manifesting;
	    IF ( l_count > 0 ) THEN
	      x_term_manifest_flag:='Y';
	      FTE_FREIGHT_PRICING_UTIL.setmsg(
				  p_api			=> 'Check_Freight_Terms_Manifest',
				  p_exc			=> ' ',
				  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_MAN',
				  p_msg_type		=> 'W',
				  p_move_id		=> p_move_id);



	    END IF;



	END IF;
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Check_Freight_Terms_Manifest');

EXCEPTION
WHEN others THEN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Check_Freight_Terms_Manifest',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Check_Freight_Terms_Manifest');


END Check_Freight_Terms_Manifest;

PROCEDURE Move_Records_To_Main(
	p_trip_id IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_comparison_request_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR lock_temp_rec(c_lane_id IN NUMBER,
			c_schedule_id IN NUMBER,
			c_vehicle_type_id IN NUMBER,
			c_request_id IN NUMBER) IS
	SELECT *
	FROM FTE_FREIGHT_COSTS_TEMP fct
	WHERE ( fct.comparison_request_id = c_request_id)
	AND  ((fct.lane_id = c_lane_id) OR (fct.schedule_id= c_schedule_id))
	AND (fct.vehicle_type_id = c_vehicle_type_id)
	AND(fct.CHARGE_SOURCE_CODE='PRICING_ENGINE')
	FOR UPDATE NOWAIT;


l_temp_rec FTE_FREIGHT_COSTS_TEMP%ROWTYPE;
l_empty_freight_rec WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_freight_rec WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_freight_cost_id NUMBER;
l_return_status VARCHAR2(1);
l_rowid VARCHAR2(30);
l_init_msg_list            VARCHAR2(30) :=FND_API.G_FALSE;
l_trip_vehicle_type NUMBER;

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Move_Records_To_Main','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 	SAVEPOINT  Move_Records_To_Main;
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_trip_id = '||p_trip_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_lane_id = '||p_lane_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_schedule_id = '||p_schedule_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_comparison_request_id = '||p_comparison_request_id);

	l_trip_vehicle_type:=NULL;
	FTE_TL_CACHE.Get_Vehicle_Type(p_trip_id => p_trip_id,
			 p_vehicle_item_id =>NULL,
			 x_vehicle_type => l_trip_vehicle_type,
			 x_return_status => l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Vehicle:'||l_trip_vehicle_type);

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>1');

	IF (p_lane_id IS NULL AND p_schedule_id IS NULL)
 	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Lane:'||p_lane_id||'Schedule:'||p_schedule_id||'Vehicle:'||l_trip_vehicle_type);
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_lane_sched_null;

 	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>2');
 	FOR l_temp_rec IN lock_temp_rec(p_lane_id,p_schedule_id,l_trip_vehicle_type,p_comparison_request_id)
 	LOOP

	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>3');
	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                      'l_temp_rec.freight_cost_id='||l_temp_rec.freight_cost_id);

 		-- l_freight_rec.freight_cost_id:=l_temp_rec.freight_cost_id;
		--Clear all values
		l_freight_rec:=l_empty_freight_rec;

 		l_freight_rec.freight_cost_id:= NULL;
			l_freight_rec.freight_cost_type_id:=l_temp_rec.freight_cost_type_id;
			l_freight_rec.unit_amount:=l_temp_rec.unit_amount;
			l_freight_rec.calculation_method:=l_temp_rec.calculation_method;
			l_freight_rec.uom:=l_temp_rec.uom;
			l_freight_rec.quantity:=l_temp_rec.quantity;
			l_freight_rec.total_amount:=l_temp_rec.total_amount;
			l_freight_rec.currency_code:=l_temp_rec.currency_code;
			l_freight_rec.conversion_date:=l_temp_rec.conversion_date;
			l_freight_rec.conversion_rate:=l_temp_rec.conversion_rate;
			l_freight_rec.conversion_type_code:=l_temp_rec.conversion_type_code;
			l_freight_rec.trip_id:=l_temp_rec.trip_id;

			l_freight_rec.stop_id:=l_temp_rec.stop_id;
			l_freight_rec.delivery_id:=l_temp_rec.delivery_id;
			l_freight_rec.delivery_leg_id:=l_temp_rec.delivery_leg_id;
			l_freight_rec.delivery_detail_id:=l_temp_rec.delivery_detail_id;
			l_freight_rec.request_id:=l_temp_rec.request_id;
			l_freight_rec.line_type_code:=l_temp_rec.line_type_code;
			l_freight_rec.pricing_list_header_id:=
			 l_temp_rec.pricing_list_header_id;
			l_freight_rec.pricing_list_line_id:=l_temp_rec.pricing_list_line_id;
			l_freight_rec.applied_to_charge_id:=l_temp_rec.applied_to_charge_id;
			l_freight_rec.charge_unit_value:=l_temp_rec.charge_unit_value;
			l_freight_rec.charge_source_code:=l_temp_rec.charge_source_code;
			l_freight_rec.estimated_flag:=l_temp_rec.estimated_flag;


			--billable columns
			l_freight_rec.BILLABLE_UOM:= l_temp_rec.BILLABLE_UOM;
			l_freight_rec.BILLABLE_BASIS:= l_temp_rec.BILLABLE_BASIS;
			l_freight_rec.BILLABLE_QUANTITY:=l_temp_rec.BILLABLE_QUANTITY;


			l_freight_rec.creation_date:=l_temp_rec.creation_date;
		        l_freight_rec.created_by:= l_temp_rec.created_by;
		        l_freight_rec.last_update_date:= l_temp_rec.last_update_date;
		        l_freight_rec.last_updated_by:=l_temp_rec.last_updated_by;
		        l_freight_rec.last_update_login:= l_temp_rec.last_update_login;
		        l_freight_rec.program_application_id:=l_temp_rec.program_application_id;
		        l_freight_rec.program_id:= l_temp_rec.program_id;
			l_freight_rec.program_update_date:= l_temp_rec.program_update_date;


 		IF ((l_freight_rec.delivery_leg_id IS NOT NULL)
 		 AND(l_freight_rec.delivery_detail_id IS NULL)
 		 AND (l_freight_rec.line_type_code='SUMMARY'))
 		THEN
	          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>4');
			l_freight_rec.freight_cost_id:=NULL;
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Dleg ID:'||l_freight_rec.delivery_leg_id);
 			l_freight_rec.freight_cost_id:=FTE_FREIGHT_PRICING.get_fc_id_from_dleg(l_freight_rec.delivery_leg_id);

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FC ID:'||l_freight_rec.freight_cost_id);


			IF (l_freight_rec.freight_cost_id IS NULL )
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_fc_id_fail;

			END IF;

	          FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>5');

		      WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
			 p_rowid                  =>  l_rowid,
			 p_freight_cost_info      =>  l_freight_rec,
			 x_return_status          =>  l_return_status);

			 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Update_Freight_Cost');
				raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
			    ELSE
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Update_Freight_Cost returned warning ');
			    END IF;
			 END IF;

 		ELSE
	               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>6');

 			WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
			          p_freight_cost_info      =>  l_freight_rec,
			          x_rowid                  =>  l_rowid,
			          x_freight_cost_id        =>  l_freight_cost_id,
          			x_return_status          =>  l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_fail;
				END IF;
			END IF;


 		END IF;

 	END LOOP;

----Reset pricing required flags

	Update_Pricing_Required_Flag(
		p_trip_id=>p_trip_id,
		x_return_status =>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
		'Failied to set reprice required flag for TRIP ID:'||p_trip_id);
	       END IF;
	END IF;

---Delete  fc temp record
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>7');

	DELETE
	FROM FTE_FREIGHT_COSTS_TEMP fct
		WHERE ( fct.comparison_request_id = p_comparison_request_id)
		AND  ((fct.lane_id = p_lane_id) OR (fct.schedule_id= p_schedule_id))
	AND(fct.CHARGE_SOURCE_CODE='PRICING_ENGINE');

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>8');

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail THEN
 	 ROLLBACK TO  Move_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_vehicle_type_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');


WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
 	 ROLLBACK TO  Move_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_update_freight_cost_failed');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');



WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_fc_id_fail THEN
 	 ROLLBACK TO  Move_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_fc_id_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');



WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_fail THEN
 	 ROLLBACK TO  Move_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_fr_cost_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_lane_sched_null THEN
 	 ROLLBACK TO Move_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_move_rec_lane_sched_null');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');



WHEN others THEN
 	ROLLBACK TO Move_Records_To_Main;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');


END Move_Records_To_Main;



PROCEDURE Move_Dlv_Records_To_Main(
	p_dleg_id IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_comparison_request_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR c_check_fake(c_lane_id IN NUMBER,
			c_schedule_id IN NUMBER,
			c_vehicle_type_id IN NUMBER,
			c_request_id IN NUMBER,
			c_fake_trip_id IN NUMBER) IS
	SELECT fct.trip_id
	FROM FTE_FREIGHT_COSTS_TEMP fct
	WHERE ( fct.comparison_request_id = c_request_id)
	AND  ((fct.lane_id = c_lane_id) OR (fct.schedule_id= c_schedule_id))
	AND (fct.vehicle_type_id = c_vehicle_type_id)
	AND(fct.CHARGE_SOURCE_CODE='PRICING_ENGINE')
	AND (fct.trip_id IS NOT NULL)
	AND ( fct.trip_id = c_fake_trip_id)
	AND ROWNUM=1;


CURSOR c_get_dleg_info_from_dleg(c_dleg_id IN NUMBER)
IS
	SELECT  dl.delivery_id,
		s.trip_id,
		dl.pick_up_stop_id,
		dl.drop_off_stop_id
	FROM    wsh_delivery_legs dl,
		wsh_trip_stops s
	WHERE   dl.drop_off_stop_id = s.stop_id and
		dl.delivery_leg_id=c_dleg_id;


CURSOR lock_temp_rec(c_lane_id IN NUMBER,
			c_schedule_id IN NUMBER,
			c_vehicle_type_id IN NUMBER,
			c_request_id IN NUMBER) IS
	SELECT *
	FROM FTE_FREIGHT_COSTS_TEMP fct
	WHERE ( fct.comparison_request_id = c_request_id)
	AND  ((fct.lane_id = c_lane_id) OR (fct.schedule_id= c_schedule_id))
	AND (fct.vehicle_type_id = c_vehicle_type_id)
	AND(fct.CHARGE_SOURCE_CODE='PRICING_ENGINE')
	FOR UPDATE NOWAIT;


l_temp_rec FTE_FREIGHT_COSTS_TEMP%ROWTYPE;
l_empty_freight_rec WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_freight_rec WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
l_freight_cost_id NUMBER;
l_return_status VARCHAR2(1);
l_rowid VARCHAR2(30);
l_init_msg_list            VARCHAR2(30) :=FND_API.G_FALSE;
l_trip_vehicle_type NUMBER;
l_delivery_id NUMBER;
l_trip_id NUMBER;
l_pickup_stop_id NUMBER;
l_dropoff_stop_id NUMBER;
l_fake_trip NUMBER;

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Move_Dlv_Records_To_Main','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 	SAVEPOINT  Move_Dlv_Records_To_Main;
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_dleg_id = '||p_dleg_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_lane_id = '||p_lane_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_schedule_id = '||p_schedule_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
               'p_comparison_request_id = '||p_comparison_request_id);

	--Get trip/stop/delivery info from the dleg

	OPEN c_get_dleg_info_from_dleg(p_dleg_id);
	FETCH c_get_dleg_info_from_dleg INTO l_delivery_id,l_trip_id,l_pickup_stop_id,l_dropoff_stop_id;
	CLOSE c_get_dleg_info_from_dleg;


	l_trip_vehicle_type:=NULL;
	FTE_TL_CACHE.Get_Vehicle_Type(p_trip_id => l_trip_id,
			 p_vehicle_item_id =>NULL,
			 x_vehicle_type => l_trip_vehicle_type,
			 x_return_status => l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Vehicle:'||l_trip_vehicle_type);

	IF (p_lane_id IS NULL AND p_schedule_id IS NULL)
 	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Lane:'||p_lane_id||'Schedule:'||p_schedule_id||'Vehicle:'||l_trip_vehicle_type);
 		raise FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_lane_sched_null;

 	END IF;

	--Check for fake trip

	OPEN c_check_fake(p_lane_id,p_schedule_id,l_trip_vehicle_type,p_comparison_request_id,FTE_TL_CACHE.FAKE_TRIP_ID);
	FETCH c_check_fake INTO l_fake_trip;
	IF(c_check_fake%FOUND)
	THEN
		l_fake_trip:=FTE_TL_CACHE.FAKE_TRIP_ID;

	ELSE
		l_fake_trip:=NULL;

	END IF;
	CLOSE c_check_fake;

	IF (l_fake_trip IS NOT NULL)
	THEN



		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>1');

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>2');
		FOR l_temp_rec IN lock_temp_rec(p_lane_id,p_schedule_id,l_trip_vehicle_type,p_comparison_request_id)
		LOOP

		        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>3');
		        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
			      'l_temp_rec.freight_cost_id='||l_temp_rec.freight_cost_id);

			-- l_freight_rec.freight_cost_id:=l_temp_rec.freight_cost_id;
			--Clear all values
			l_freight_rec:=l_empty_freight_rec;


			l_freight_rec.freight_cost_id:= NULL;
			l_freight_rec.freight_cost_type_id:=l_temp_rec.freight_cost_type_id;
			l_freight_rec.unit_amount:=l_temp_rec.unit_amount;
			l_freight_rec.calculation_method:=l_temp_rec.calculation_method;
			l_freight_rec.uom:=l_temp_rec.uom;
			l_freight_rec.quantity:=l_temp_rec.quantity;
			l_freight_rec.total_amount:=l_temp_rec.total_amount;
			l_freight_rec.currency_code:=l_temp_rec.currency_code;
			l_freight_rec.conversion_date:=l_temp_rec.conversion_date;
			l_freight_rec.conversion_rate:=l_temp_rec.conversion_rate;
			l_freight_rec.conversion_type_code:=l_temp_rec.conversion_type_code;

			--Plug in real trip id
			IF (l_temp_rec.trip_id IS NOT NULL)
			THEN
				l_freight_rec.trip_id:=l_trip_id;
			END IF;


			--Plug in real stop id
			IF ((l_temp_rec.stop_id IS NOT NULL) AND (l_temp_rec.stop_id = FTE_TL_CACHE.FAKE_STOP_ID_1))
			THEN

				l_freight_rec.stop_id:=l_pickup_stop_id;

			ELSIF((l_temp_rec.stop_id IS NOT NULL) AND (l_temp_rec.stop_id = FTE_TL_CACHE.FAKE_STOP_ID_2))
			THEN
				l_freight_rec.stop_id:=l_dropoff_stop_id;

			ELSE
				l_freight_rec.stop_id:=l_temp_rec.stop_id;

			END IF;




			l_freight_rec.delivery_id:=l_temp_rec.delivery_id;


			--Plug in real dleg id
			IF((l_temp_rec.delivery_leg_id IS NOT NULL) AND (l_temp_rec.delivery_leg_id = FTE_TL_CACHE.FAKE_DLEG_ID))
			THEN
				l_freight_rec.delivery_leg_id:=p_dleg_id;
			ELSE
				l_freight_rec.delivery_leg_id:=l_temp_rec.delivery_leg_id;
			END IF;


			l_freight_rec.delivery_detail_id:=l_temp_rec.delivery_detail_id;
			l_freight_rec.request_id:=l_temp_rec.request_id;
			l_freight_rec.line_type_code:=l_temp_rec.line_type_code;
			l_freight_rec.pricing_list_header_id:=
			 l_temp_rec.pricing_list_header_id;
			l_freight_rec.pricing_list_line_id:=l_temp_rec.pricing_list_line_id;
			l_freight_rec.applied_to_charge_id:=l_temp_rec.applied_to_charge_id;
			l_freight_rec.charge_unit_value:=l_temp_rec.charge_unit_value;
			l_freight_rec.charge_source_code:=l_temp_rec.charge_source_code;
			l_freight_rec.estimated_flag:=l_temp_rec.estimated_flag;


			--billable columns
			l_freight_rec.BILLABLE_UOM:= l_temp_rec.BILLABLE_UOM;
			l_freight_rec.BILLABLE_BASIS:= l_temp_rec.BILLABLE_BASIS;
			l_freight_rec.BILLABLE_QUANTITY:=l_temp_rec.BILLABLE_QUANTITY;


			l_freight_rec.creation_date:=l_temp_rec.creation_date;
			l_freight_rec.created_by:= l_temp_rec.created_by;
			l_freight_rec.last_update_date:= l_temp_rec.last_update_date;
			l_freight_rec.last_updated_by:=l_temp_rec.last_updated_by;
			l_freight_rec.last_update_login:= l_temp_rec.last_update_login;
			l_freight_rec.program_application_id:=
				l_temp_rec.program_application_id;
			l_freight_rec.program_id:= l_temp_rec.program_id;
			l_freight_rec.program_update_date:= l_temp_rec.program_update_date;


			IF ((l_freight_rec.delivery_leg_id IS NOT NULL)
			 AND(l_freight_rec.delivery_detail_id IS NULL)
			 AND (l_freight_rec.line_type_code='SUMMARY'))
			THEN
			  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>4');
			l_freight_rec.freight_cost_id:=NULL;
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Dleg ID:'||l_freight_rec.delivery_leg_id);
 			l_freight_rec.freight_cost_id:=FTE_FREIGHT_PRICING.get_fc_id_from_dleg(l_freight_rec.delivery_leg_id);

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FC ID:'||l_freight_rec.freight_cost_id);


			IF (l_freight_rec.freight_cost_id IS NULL )
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_fc_id_fail;

			END IF;

			  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>5');

			      WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
				 p_rowid                  =>  l_rowid,
				 p_freight_cost_info      =>  l_freight_rec,
				 x_return_status          =>  l_return_status);

				 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
				    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
					FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Update_Freight_Cost');
					raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
				    ELSE
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Update_Freight_Cost returned warning ');
				    END IF;
				 END IF;

			ELSE
			       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>6');

				WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
					  p_freight_cost_info      =>  l_freight_rec,
					  x_rowid                  =>  l_rowid,
					  x_freight_cost_id        =>  l_freight_cost_id,
					x_return_status          =>  l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_fail;
					END IF;
				END IF;


			END IF;

		END LOOP;

	----Reset pricing required flags

		Update_Pricing_Required_Flag(
			p_trip_id=>l_trip_id,
			x_return_status =>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
			'Failied to set reprice required flag for TRIP ID:'||l_trip_id);
		       END IF;
		END IF;

	---Delete  fc temp record
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>7');

		DELETE
		FROM FTE_FREIGHT_COSTS_TEMP fct
			WHERE ( fct.comparison_request_id = p_comparison_request_id)
			AND  ((fct.lane_id = p_lane_id) OR (fct.schedule_id= p_schedule_id))
		AND(fct.CHARGE_SOURCE_CODE='PRICING_ENGINE');

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>8');


		Update_Distance_To_Next_Stop(
			p_trip_id =>l_trip_id,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
			'Failied to update stop distances for :'||l_trip_id);
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_update_dist_stop_fail;
		       END IF;
		END IF;




	ELSE


		Move_Records_To_Main(
			p_trip_id =>l_trip_id,
			p_lane_id=>p_lane_id,
			p_schedule_id =>p_schedule_id,
			p_comparison_request_id=>p_comparison_request_id,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_to_main_fail;
		       END IF;
		END IF;

	END IF;






	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_update_dist_stop_fail THEN
 	 ROLLBACK TO  Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_update_dist_stop_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');



WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_to_main_fail THEN
 	 ROLLBACK TO  Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_move_rec_to_main_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail THEN
 	 ROLLBACK TO  Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_vehicle_type_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');


WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
 	 ROLLBACK TO  Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_update_freight_cost_failed');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');



WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_fc_id_fail THEN
 	 ROLLBACK TO  Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_fc_id_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');



WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_fail THEN
 	 ROLLBACK TO  Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_fr_cost_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_lane_sched_null THEN
 	 ROLLBACK TO Move_Dlv_Records_To_Main;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_move_rec_lane_sched_null');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');



WHEN others THEN
 	ROLLBACK TO Move_Dlv_Records_To_Main;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Dlv_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Dlv_Records_To_Main');


END Move_Dlv_Records_To_Main;



PROCEDURE Delete_Main_Records(
        p_trip_id IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR lock_trip_recs(c_trip_id IN NUMBER ) IS

        SELECT wfc.freight_cost_id
        FROM wsh_freight_costs wfc
        WHERE   wfc.trip_id = c_trip_id
                and wfc.charge_source_code='PRICING_ENGINE'
        FOR UPDATE NOWAIT;

CURSOR get_stops(c_trip_id IN NUMBER ) IS
        SELECT s.stop_id
        FROM wsh_trip_stops s
        WHERE s.trip_id= c_trip_id;


CURSOR lock_stop_rec(c_stop_id IN NUMBER ) IS

        SELECT wfc.freight_cost_id
        FROM wsh_freight_costs wfc
        WHERE wfc.stop_id =c_stop_id
              and wfc.charge_source_code='PRICING_ENGINE'
        FOR UPDATE OF wfc.freight_cost_id NOWAIT;


CURSOR get_dlegs(c_trip_id IN NUMBER) IS

        SELECT dl.delivery_leg_id FROM wsh_delivery_legs dl , wsh_trip_stops s
        WHERE dl.pick_up_stop_id=s.stop_id and s.trip_id=p_trip_id;

CURSOR lock_detail_recs(c_trip_id IN NUMBER) IS
        SELECT wfc.freight_cost_id
        FROM wsh_freight_costs wfc,
             wsh_delivery_legs dl ,
             wsh_trip_stops s
        WHERE wfc.delivery_leg_id = dl.delivery_leg_id
              and dl.pick_up_stop_id=s.stop_id
              and s.trip_id=c_trip_id
              and wfc.charge_source_code='PRICING_ENGINE'
              -- and wfc.delivery_detail_id is not null
              FOR UPDATE OF wfc.freight_cost_id NOWAIT;


l_lock_ids DBMS_UTILITY.NUMBER_ARRAY;
l_stop_ids DBMS_UTILITY.NUMBER_ARRAY;
l_dleg_ids DBMS_UTILITY.NUMBER_ARRAY;

l_wfc_detail_ids DBMS_UTILITY.NUMBER_ARRAY;
l_wfc_stop_ids DBMS_UTILITY.NUMBER_ARRAY;
l_wfc_trip_ids DBMS_UTILITY.NUMBER_ARRAY;
l_wfc_one_stop_ids DBMS_UTILITY.NUMBER_ARRAY;
l_wfc_temp_stop_ids DBMS_UTILITY.NUMBER_ARRAY;

l_lock_id NUMBER;
j NUMBER;
i NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

        l_warning_count         NUMBER:=0;
BEGIN

        FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
        FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Delete_Main_Records','start');

        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        SAVEPOINT  Delete_Main_Records;



        --lock trip level recs

        OPEN lock_trip_recs(p_trip_id);
        FETCH lock_trip_recs BULK COLLECT INTO l_wfc_trip_ids;
        CLOSE lock_trip_recs;

	--Delete trip level records

	IF (l_wfc_trip_ids.FIRST IS NOT NULL)
	THEN

		FORALL i IN l_wfc_trip_ids.FIRST..l_wfc_trip_ids.LAST
			DELETE
			FROM wsh_freight_costs wfc
			WHERE wfc.freight_cost_id = l_wfc_trip_ids(i);
	END IF;




        --select all the stops for the trip

        OPEN get_stops(p_trip_id);
        FETCH get_stops BULK COLLECT INTO l_stop_ids;
        CLOSE get_stops;

        IF (l_stop_ids.FIRST IS NOT NULL)
        THEN


		--lock stop recs one stop at a time(done for performance)


		l_wfc_stop_ids.delete;
		l_wfc_temp_stop_ids.delete;
		l_lock_id:=NULL;
		FOR i IN l_stop_ids.FIRST..l_stop_ids.LAST
		LOOP
			OPEN lock_stop_rec(l_stop_ids(i));
			FETCH lock_stop_rec BULK COLLECT INTO l_wfc_one_stop_ids;
			IF (l_wfc_one_stop_ids.FIRST IS NOT NULL)
			THEN

				FOR j IN l_wfc_one_stop_ids.FIRST .. l_wfc_one_stop_ids.LAST
				LOOP
					IF (l_wfc_one_stop_ids(j) IS NOT NULL)
					THEN
						l_wfc_temp_stop_ids(l_wfc_one_stop_ids(j)):=l_wfc_one_stop_ids(j);

					END IF;

				END LOOP;

			END IF;
			CLOSE lock_stop_rec;

		END LOOP;


                --delete stop recs

                IF (l_wfc_temp_stop_ids.FIRST IS NOT NULL)
                THEN

                	--consolidate array so that it is contiguos

                	i:=1;
                	j:=l_wfc_temp_stop_ids.FIRST;
                	WHILE(j IS NOT NULL)
                	LOOP
                		l_wfc_stop_ids(i):=l_wfc_temp_stop_ids(j);
                		i:=i+1;
                		j:=l_wfc_temp_stop_ids.NEXT(j);

                	END LOOP;

			FORALL i IN l_wfc_stop_ids.FIRST..l_wfc_stop_ids.LAST
				DELETE
				FROM wsh_freight_costs wfc
				WHERE wfc.freight_cost_id = l_wfc_stop_ids(i) ;
		END IF;


                --Do not delete delivery_leg level summaries

        	--get dlegs

                OPEN get_dlegs(p_trip_id);
                FETCH get_dlegs BULK COLLECT INTO l_dleg_ids;
                CLOSE get_dlegs;


                IF(l_dleg_ids.FIRST IS NOT NULL)
                THEN

                        --locks both dleg and detail recs

                        OPEN lock_detail_recs(p_trip_id);
                        FETCH lock_detail_recs BULK COLLECT INTO l_wfc_detail_ids;
                        CLOSE lock_detail_recs;



			IF (l_wfc_detail_ids.FIRST IS NOT NULL)
			THEN
				--Delete detail level records


				FORALL i IN l_wfc_detail_ids.FIRST..l_wfc_detail_ids.LAST
					DELETE
					FROM wsh_freight_costs wfc
					WHERE wfc.freight_cost_id = l_wfc_detail_ids(i)
					and wfc.delivery_detail_id is not null;


				 --Clear rates for dleg recs

				FORALL i IN l_wfc_detail_ids.FIRST..l_wfc_detail_ids.LAST
					UPDATE wsh_freight_costs wfc
					set wfc.unit_amount=null,
					    wfc.total_amount=null,
					    wfc.currency_code=null
					WHERE wfc.freight_cost_id = l_wfc_detail_ids(i)
					and wfc.line_type_code='SUMMARY'
					and wfc.delivery_detail_id is null;
			END IF;



                END IF;

        END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Main_Records');
        IF (l_warning_count > 0)
        THEN
                x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
        END IF;
EXCEPTION
WHEN others THEN
        ROLLBACK TO Delete_Main_Records;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Delete_Main_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Main_Records');


END Delete_Main_Records;



PROCEDURE Is_Pricing_Required(
	p_trip_id IN NUMBER,
	p_move_id IN NUMBER,
	x_reprice_flag OUT NOCOPY VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2) IS

CURSOR get_dlegs_to_be_priced(c_trip_id IN NUMBER) IS
	SELECT 	dl.delivery_leg_id
	FROM 	wsh_delivery_legs dl ,
		wsh_trip_stops s
	WHERE 	dl.pick_up_stop_id = s.stop_id
		and s.trip_id=c_trip_id
		and ( NVL(dl.reprice_required,'Y') = 'Y');


CURSOR get_move_dlegs_to_be_priced(c_move_id IN NUMBER) IS
	SELECT 	dl.delivery_leg_id
	FROM 	wsh_delivery_legs dl ,
		wsh_trip_stops s
	WHERE
		s.trip_id IN (
			SELECT m.trip_id from fte_trip_moves m where m.move_id=c_move_id
		)
		and dl.pick_up_stop_id = s.stop_id
		and ( NVL(dl.reprice_required,'Y') = 'Y');


	l_temp NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Is_Pricing_Required','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF (p_move_id IS NOT NULL)
	THEN
		OPEN get_move_dlegs_to_be_priced(p_move_id);
		FETCH get_move_dlegs_to_be_priced INTO l_temp;
		IF (get_move_dlegs_to_be_priced%FOUND)
		THEN
			x_reprice_flag:='Y';
		ELSE
			x_reprice_flag:='N';
		END IF;
		CLOSE get_move_dlegs_to_be_priced;


	ELSE

		OPEN get_dlegs_to_be_priced(p_trip_id);
		FETCH get_dlegs_to_be_priced INTO l_temp;
		IF (get_dlegs_to_be_priced%FOUND)
		THEN
			x_reprice_flag:='Y';
		ELSE
			x_reprice_flag:='N';
		END IF;
		CLOSE get_dlegs_to_be_priced;

	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Is_Pricing_Required');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Is_Pricing_Required',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Is_Pricing_Required');


END Is_Pricing_Required;


PROCEDURE Handle_CM_Discount_Variant(
		p_fte_move_id	IN NUMBER,
		p_trip_index_start IN NUMBER,
		p_trip_index_end  IN NUMBER,
		p_output_type       IN  VARCHAR2,
		x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
                x_return_status     OUT NOCOPY VARCHAR2) IS

--All the trip charges in the move will be stored in this table
l_store_trip_rows  FTE_TL_CACHE.TL_trip_output_tab_type;

--All the stops of the diff trips in the move will be stored here
l_store_trip_stop_rows  FTE_TL_CACHE.TL_trip_stop_output_tab_type;

--All the total charges for the trips are stored in this table, indexed by trip id
l_trip_charges_tab dbms_utility.number_array;

--This table indexed by the trip_id has a reference to the stops for that trip in l_store_trip_stop_rows
l_stop_references dbms_utility.number_array;
l_total_trip_charge	NUMBER;
l_non_cm_charge NUMBER;
l_cm_charge	NUMBER;
i NUMBER;
j NUMBER;
k NUMBER;
l_cm_discount NUMBER;
l_effective_discount NUMBER;
l_cost_allocation_parameters FTE_TL_COST_ALLOCATION.TL_allocation_params_rec_type;
l_output_cost_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;

l_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
l_empty_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
l_stop_charges_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Handle_CM_Discount_Variant','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	FTE_TL_COST_ALLOCATION.Get_Cost_Allocation_Parameters(
		x_cost_allocation_parameters=>	l_cost_allocation_parameters,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail;
	       END IF;
	END IF;

	l_cost_allocation_parameters.output_type:=p_output_type;

	l_cm_charge:=0;
	l_non_cm_charge:=0;


	j:=1;
	i:=p_trip_index_start;
	WHILE(i <= p_trip_index_end)
	LOOP

		FTE_TL_CORE.tl_core (
		   p_trip_rec          => FTE_TL_CACHE.g_tl_trip_rows(i),
		   p_stop_tab          => FTE_TL_CACHE.g_tl_trip_stop_rows,
		   p_carrier_pref      => FTE_TL_CACHE.g_tl_carrier_pref_rows(i),
		   x_trip_charges_rec  => l_trip_charges_rec,
		   x_stop_charges_tab  => l_stop_charges_tab,
		   x_return_status     => l_return_status );

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  FTE_FREIGHT_PRICING_UTIL.setmsg (
				p_api=>'Handle_CM_Discount_Variant',
				p_exc=>'g_tl_core_fail',
				p_trip_id=>FTE_TL_CACHE.g_tl_trip_rows(i).trip_id);

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail;
		       END IF;
		END IF;



		IF(l_trip_charges_rec.cm_discount_percent IS NOT NULL)
		THEN
			IF (l_trip_charges_rec.cm_discount_percent <> 0)
			THEN
				l_cm_discount:=l_trip_charges_rec.cm_discount_percent;
			END IF;
		END IF;

		--Get total cost of the trip(without cm disc)

		FTE_TL_COST_ALLOCATION.Get_Total_Trip_Cost(
			p_trip_index=>	i,
			p_trip_charges_rec=>	l_trip_charges_rec,
			p_stop_charges_tab=>	l_stop_charges_tab,
			x_charge=>l_total_trip_charge,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail;
		       END IF;
		END IF;



		--Store total cost of trip
		l_trip_charges_tab(l_trip_charges_rec.trip_id):=l_total_trip_charge;

		--Store trip level charges
		l_store_trip_rows(i):=l_trip_charges_rec;

		--Store refernce to stop level charges
		l_stop_references(l_trip_charges_rec.trip_id):=j;

		--Store stop level charges

		k:=l_stop_charges_tab.FIRST;
		WHILE(k IS NOT NULL)
		LOOP
			l_store_trip_stop_rows(j):=l_stop_charges_tab(k);
			j:=j+1;

			k:=l_stop_charges_tab.NEXT(k);
		END LOOP;

		IF(FTE_TL_CACHE.g_tl_trip_rows(i).dead_head='N')
		THEN
			l_non_cm_charge:=l_non_cm_charge+
				l_trip_charges_tab(FTE_TL_CACHE.g_tl_trip_rows(i).trip_id);
		END IF;
		l_cm_charge:=l_cm_charge
			+l_trip_charges_tab(FTE_TL_CACHE.g_tl_trip_rows(i).trip_id);

		i:=i+1;
	END LOOP;

	--Calculate effective discount

	--l_cm_discount 0..100
	--l_effective_discount 0..1 . 0% effective discount => l_effective_discount=1
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'cm charge:'||l_cm_charge||' non cm charge '||l_non_cm_charge);
	IF(l_non_cm_charge <> 0)
	THEN
		l_effective_discount:=((100-l_cm_discount)*l_cm_charge)/(l_non_cm_charge*100);
	ELSE
		l_effective_discount:=1-0;

	END IF;

	--If the cm discount is not beneficial (makes it more expensive) then dont apply it

	--IF ((l_effective_discount > 1) OR (l_effective_discount < 0))
	--THEN
	--	l_effective_discount:=1;
	--END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Effective discount'||l_effective_discount);

	--Allocate discount to non-dead head trips

	i:=l_store_trip_rows.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF((FTE_TL_CACHE.g_tl_trip_rows(i).dead_head='N') AND
		NOT((FTE_TL_CACHE.g_tl_carrier_pref_rows(i).cm_first_load_discount_flag='N')AND (i= l_store_trip_rows.FIRST)))
		THEN
			FTE_TL_COST_ALLOCATION.Scale_Trip_Charges(
				p_discount=>	l_effective_discount,
				x_trip_charges_rec=>	l_store_trip_rows(i),
				x_return_status=> l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_scale_trip_charges_fail;
			       END IF;
			END IF;



			l_trip_charges_rec:=l_store_trip_rows(i);
			l_trip_charges_rec.cm_discount_value:=
				l_trip_charges_tab(l_trip_charges_rec.trip_id)*(1-l_effective_discount);
			l_stop_charges_tab.DELETE;
			j:=l_stop_references(l_trip_charges_rec.trip_id);
			WHILE( j IS NOT NULL )
			LOOP
				IF (l_store_trip_stop_rows(j).trip_id <> l_trip_charges_rec.trip_id)
				THEN
					EXIT;
				END IF;

				FTE_TL_COST_ALLOCATION.Scale_Stop_Charges(
					p_discount=>	l_effective_discount,
					x_stop_charges_rec=>	l_store_trip_stop_rows(j),
					x_return_status=> l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_scale_stop_charges_fail;
				       END IF;
				END IF;

				l_stop_charges_tab(l_store_trip_stop_rows(j).stop_id):=l_store_trip_stop_rows(j);
				j:=l_store_trip_stop_rows.NEXT(j);

			END LOOP;

			IF (p_output_type='M')
			THEN
				Delete_Main_Records(
					p_trip_id=>l_trip_charges_rec.trip_id,
					x_return_status=>l_return_status);
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail;
				       END IF;
				END IF;


			END IF;

			FTE_TL_COST_ALLOCATION.TL_COST_ALLOCATION(
				p_trip_index=>	i,
				p_trip_charges_rec=>	l_trip_charges_rec,
				p_stop_charges_tab=>	l_stop_charges_tab,
				p_cost_allocation_parameters=>	l_cost_allocation_parameters,
				x_output_cost_tab=>	l_output_cost_tab,
				x_return_status=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

				  FTE_FREIGHT_PRICING_UTIL.setmsg (
					p_api=>'Handle_CM_Discount_Variant',
					p_exc=>'g_tl_cost_allocation_fail',
					p_trip_id=>l_trip_charges_rec.trip_id);

				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail;
			       END IF;
			END IF;

			IF (p_output_type='M')
			THEN

				Update_Pricing_Required_Flag(
				p_trip_id=>l_trip_charges_rec.trip_id,
				x_return_status =>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
					'Failied to set reprice required flag for TRIP ID:'||l_trip_charges_rec.trip_id);
				       END IF;
				END IF;
			END IF;


			l_stop_charges_tab.DELETE;
			l_trip_charges_rec:=l_empty_trip_charges_rec;
		END IF;


		i:=l_store_trip_rows.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_main_rec_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_cost_alloc_param_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


 WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cost_allocation_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


 WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_scale_trip_charges_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_scale_trip_charges_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_scale_stop_charges_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_scale_stop_charges_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_tot_trp_cost_fail');
	 FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_core_fail');
	 FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');

 WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Discount_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Discount_Variant');


END Handle_CM_Discount_Variant;


PROCEDURE Handle_CM_Rate_Variant(
		p_fte_move_id	IN NUMBER,
		p_trip_index_start IN NUMBER,
		p_trip_index_end  IN NUMBER,
		p_output_type       IN  VARCHAR2,
		x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
                x_return_status     OUT NOCOPY VARCHAR2) IS

i 	NUMBER;
j 	NUMBER;
k	NUMBER;
l_total_trip_charge	NUMBER;
l_factor	NUMBER;

l_cost_allocation_parameters FTE_TL_COST_ALLOCATION.TL_allocation_params_rec_type;
l_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
l_empty_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
l_stop_charges_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;

--All the trip charges in the move will be stored in this table
l_store_trip_rows  FTE_TL_CACHE.TL_trip_output_tab_type;

--All the stops of the diff trips in the move will be stored here
l_store_trip_stop_rows  FTE_TL_CACHE.TL_trip_stop_output_tab_type;

--All the total charges for the trips are stored in this table, indexed by trip id
l_trip_charges_tab dbms_utility.number_array;

--This table indexed by the trip_id has a reference to the stops for that trip in l_store_trip_stop_rows
l_stop_references dbms_utility.number_array;

l_dead_head_charge NUMBER;
l_load_charge NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Handle_CM_Rate_Variant','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	FTE_TL_COST_ALLOCATION.Get_Cost_Allocation_Parameters(
		x_cost_allocation_parameters=>	l_cost_allocation_parameters,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail;
	       END IF;
	END IF;

	l_cost_allocation_parameters.output_type:=p_output_type;

	l_dead_head_charge:=0;
	l_load_charge:=0;

	j:=1;
	i:=p_trip_index_start;
	WHILE(i <= p_trip_index_end)
	LOOP

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'trip index:'||i||'stop ref'||FTE_TL_CACHE.g_tl_trip_rows(i).stop_reference);

		FTE_TL_CORE.tl_core (
		   p_trip_rec          => FTE_TL_CACHE.g_tl_trip_rows(i),
		   p_stop_tab          => FTE_TL_CACHE.g_tl_trip_stop_rows,
		   p_carrier_pref      => FTE_TL_CACHE.g_tl_carrier_pref_rows(i),
		   x_trip_charges_rec  => l_trip_charges_rec,
		   x_stop_charges_tab  => l_stop_charges_tab,
		   x_return_status     => l_return_status );

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  FTE_FREIGHT_PRICING_UTIL.setmsg (
				p_api=>'Handle_CM_Rate_Variant',
				p_exc=>'g_tl_core_fail',
				p_trip_id=>FTE_TL_CACHE.g_tl_trip_rows(i).trip_id);

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail;
		       END IF;
		END IF;

		--Get total cost of the trip(without cm disc)

		FTE_TL_COST_ALLOCATION.Get_Total_Trip_Cost(
			p_trip_index=>	i,
			p_trip_charges_rec=>	l_trip_charges_rec,
			p_stop_charges_tab=>	l_stop_charges_tab,
			x_charge=>l_total_trip_charge,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail;
		       END IF;
		END IF;

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Total cost for trip '||
			l_trip_charges_rec.trip_id||' : '||l_total_trip_charge);

		--Store total cost of trip
		l_trip_charges_tab(l_trip_charges_rec.trip_id):=l_total_trip_charge;

		--Store trip level charges
		l_store_trip_rows(i):=l_trip_charges_rec;

		--Store refernce to stop level charges
		l_stop_references(l_trip_charges_rec.trip_id):=j;

		--Store stop level charges

		k:=l_stop_charges_tab.FIRST;
		WHILE(k IS NOT NULL)
		LOOP
			l_store_trip_stop_rows(j):=l_stop_charges_tab(k);
			j:=j+1;

			k:=l_stop_charges_tab.NEXT(k);
		END LOOP;

		IF(FTE_TL_CACHE.g_tl_trip_rows(i).dead_head='Y')
		THEN
			l_dead_head_charge:=l_dead_head_charge+
				l_trip_charges_tab(FTE_TL_CACHE.g_tl_trip_rows(i).trip_id);
		ELSE
			l_load_charge:=l_load_charge
			+l_trip_charges_tab(FTE_TL_CACHE.g_tl_trip_rows(i).trip_id);

		END IF;



		i:=i+1;
	END LOOP;



-- Allocate costs to non dead heads

	i:=l_store_trip_rows.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		IF(FTE_TL_CACHE.g_tl_trip_rows(i).dead_head='N')
		THEN
			IF (l_load_charge <> 0)
			THEN
				l_factor:=1+l_dead_head_charge/l_load_charge;
			ELSE
				l_factor:=1;
			END IF;


			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Effective discount (Rate)trip: '||
			FTE_TL_CACHE.g_tl_trip_rows(i).trip_id||' : '||l_factor);

			FTE_TL_COST_ALLOCATION.Scale_Trip_Charges(
				p_discount=>	l_factor,
				x_trip_charges_rec=>	l_store_trip_rows(i),
				x_return_status=> l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_scale_trip_charges_fail;
			       END IF;
			END IF;


			l_trip_charges_rec:=l_store_trip_rows(i);

			l_stop_charges_tab.DELETE;
			j:=l_stop_references(l_trip_charges_rec.trip_id);
			WHILE( j IS NOT NULL )
			LOOP
				IF (l_store_trip_stop_rows(j).trip_id <> l_trip_charges_rec.trip_id)
				THEN
					EXIT;
				END IF;

				FTE_TL_COST_ALLOCATION.Scale_Stop_Charges(
					p_discount=>	l_factor,
					x_stop_charges_rec=>	l_store_trip_stop_rows(j),
					x_return_status=> l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_scale_stop_charges_fail;
				       END IF;
				END IF;

				l_stop_charges_tab(l_store_trip_stop_rows(j).stop_id):=l_store_trip_stop_rows(j);
				j:=l_store_trip_stop_rows.NEXT(j);

			END LOOP;

			IF (p_output_type='M')
			THEN
				Delete_Main_Records(
					p_trip_id=>l_trip_charges_rec.trip_id,
					x_return_status=>l_return_status);
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail;
				       END IF;
				END IF;


			END IF;


			FTE_TL_COST_ALLOCATION.TL_COST_ALLOCATION(
				p_trip_index=>	i,
				p_trip_charges_rec=>	l_trip_charges_rec,
				p_stop_charges_tab=>	l_stop_charges_tab,
				p_cost_allocation_parameters=>	l_cost_allocation_parameters,
				x_output_cost_tab=>	x_output_cost_tab,
				x_return_status=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

				  FTE_FREIGHT_PRICING_UTIL.setmsg (
					p_api=>'Handle_CM_Rate_Variant',
					p_exc=>'g_tl_cost_allocation_fail',
					p_trip_id=>l_trip_charges_rec.trip_id);

				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail;
			       END IF;
			END IF;

			IF (p_output_type='M')
			THEN

				Update_Pricing_Required_Flag(
				p_trip_id=>l_trip_charges_rec.trip_id,
				x_return_status =>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
					'Failied to set reprice required flag for TRIP ID:'||l_trip_charges_rec.trip_id);
				       END IF;
				END IF;
			END IF;



			l_stop_charges_tab.DELETE;
			l_trip_charges_rec:=l_empty_trip_charges_rec;
		END IF;
		i:=l_store_trip_rows.NEXT(i);


	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_tot_trp_cost_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_scale_trip_charges_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_scale_trip_charges_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_scale_stop_charges_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_scale_stop_charges_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_main_rec_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_cost_alloc_param_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cost_allocation_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail THEN
	 x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	 FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_core_fail');
	 FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');

 WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Handle_CM_Rate_Variant',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Handle_CM_Rate_Variant');


END Handle_CM_Rate_Variant;


PROCEDURE TL_Rate_Move (
                   p_fte_move_id       IN  NUMBER ,
                   p_output_type       IN  VARCHAR2,
                   x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
                   x_return_status     OUT NOCOPY VARCHAR2) IS


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
l_trip_index_start NUMBER;
l_trip_index_end NUMBER;


	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Rate_Move','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF (FTE_TL_CACHE.g_tl_trip_rows.LAST IS NULL)
	THEN
		l_trip_index_start:=1;
	ELSE
		l_trip_index_start:=FTE_TL_CACHE.g_tl_trip_rows.LAST+1;
	END IF;

	FTE_TL_CACHE.TL_Build_Cache_For_Move(
		p_fte_move_id=> 	p_fte_move_id,
        	x_return_status=> l_return_status);



	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN


		  FTE_FREIGHT_PRICING_UTIL.setmsg (
		   p_api=>'TL_Rate_Move',
		   p_exc=>'g_tl_build_cache_move_fail',
		   p_move_id=>p_fte_move_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_move_fail;
	       END IF;
	END IF;

	l_trip_index_end:=FTE_TL_CACHE.g_tl_trip_rows.LAST;
	FTE_TL_CACHE.Display_Cache;

	IF (FTE_TL_CACHE.g_tl_carrier_pref_rows(l_trip_index_start).cm_rate_variant='RATE')
	THEN
		Handle_CM_Rate_Variant(
			p_fte_move_id=>	p_fte_move_id,
			p_trip_index_start=>	l_trip_index_start,
			p_trip_index_end=>	l_trip_index_end,
			p_output_type=>	p_output_type,
			x_output_cost_tab=>	x_output_cost_tab,
                	x_return_status=>	l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_handle_cm_rate_var_fail;
		       END IF;
		END IF;


	ELSIF (FTE_TL_CACHE.g_tl_carrier_pref_rows(l_trip_index_start).cm_rate_variant='DISCOUNT')
	THEN
		Handle_CM_Discount_Variant(
			p_fte_move_id=>	p_fte_move_id,
			p_trip_index_start=>	l_trip_index_start,
			p_trip_index_end=>	l_trip_index_end,
			p_output_type=>	p_output_type,
			x_output_cost_tab=>	x_output_cost_tab,
			x_return_status=>	l_return_status);

                IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_handle_cm_disc_var_fail;
		       END IF;
		END IF;


	ELSE
		  FTE_FREIGHT_PRICING_UTIL.setmsg (
		   p_api=>'TL_Rate_Move',
		   p_exc=>'g_tl_car_no_cm_rate_variant',
		   p_carrier_id=>FTE_TL_CACHE.g_tl_carrier_pref_rows(l_trip_index_start).carrier_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_rate_variant;

	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Move');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_rate_variant THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_cm_rate_variant');
	  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Move');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_handle_cm_disc_var_fail THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_handle_cm_disc_var_fail');
	  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Move');

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_handle_cm_rate_var_fail THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_handle_cm_rate_var_fail');
	  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Move');

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_move_fail THEN
	  x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	  FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_build_cache_move_fail');
	  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Move');

 WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Move');


END TL_Rate_Move;



PROCEDURE TL_Rate_Cached_Trip (
	   p_trip_index           IN  NUMBER ,
	   p_output_type       IN  VARCHAR2,
           p_request_id        IN  NUMBER DEFAULT NULL,
	   x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
	   x_return_status     OUT NOCOPY VARCHAR2) IS


 l_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
 l_stop_charges_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;
 l_cost_allocation_parameters FTE_TL_COST_ALLOCATION.TL_allocation_params_rec_type;
 l_output_cost_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;

 l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Rate_Cached_Trip','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	FTE_TL_CORE.tl_core (
		   p_trip_rec          => FTE_TL_CACHE.g_tl_trip_rows(p_trip_index),
		   p_stop_tab          => FTE_TL_CACHE.g_tl_trip_stop_rows,
		   p_carrier_pref      => FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index),
		   x_trip_charges_rec  => l_trip_charges_rec,
		   x_stop_charges_tab  => l_stop_charges_tab,
		   x_return_status     => l_return_status );

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  --FTE_FREIGHT_PRICING_UTIL.setmsg (
		  --	p_api=>'TL_Rate_Cached_Trip',
		  --	p_exc=>'g_tl_core_fail',
		  --	p_trip_id=>FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail;
	       END IF;
	END IF;


	FTE_TL_COST_ALLOCATION.Get_Cost_Allocation_Parameters(
		x_cost_allocation_parameters=>	l_cost_allocation_parameters,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail;
	       END IF;
	END IF;

	l_cost_allocation_parameters.comparison_request_id := p_request_id;
	l_cost_allocation_parameters.output_type := p_output_type;

	FTE_TL_COST_ALLOCATION.TL_COST_ALLOCATION(
		p_trip_index=>	p_trip_index,
		p_trip_charges_rec=>	l_trip_charges_rec,
		p_stop_charges_tab=>	l_stop_charges_tab,
		p_cost_allocation_parameters=>	l_cost_allocation_parameters,
		x_output_cost_tab=>	l_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  FTE_FREIGHT_PRICING_UTIL.setmsg (
			p_api=>'TL_Rate_Cached_Trip',
			p_exc=>'g_tl_cost_allocation_fail',
			p_trip_id=>l_trip_charges_rec.trip_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;
EXCEPTION

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_cost_alloc_param_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cost_allocation_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_core_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip');
   WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip');


END TL_Rate_Cached_Trip;






PROCEDURE TL_Rate_Cached_Trip_Multiple (
	   p_start_trip_index           IN  NUMBER ,
	   p_end_trip_index           IN  NUMBER ,
	   p_output_type       IN  VARCHAR2,
           p_request_id        IN  NUMBER DEFAULT NULL,
           p_allocate_flag IN VARCHAR2,
           x_lane_sched_sum_rows  OUT NOCOPY  dbms_utility.number_array,
	   x_lane_sched_curr_rows OUT NOCOPY  dbms_utility.name_array,
	   x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
	   x_exceptions_tab    OUT NOCOPY FTE_TL_CORE.tl_exceptions_tab_type,
	   x_trip_charges_tab 	OUT NOCOPY FTE_TL_CACHE.TL_trip_output_tab_type ,
	   x_stop_charges_tab 	OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	   x_return_status     OUT NOCOPY VARCHAR2) IS


 i 	NUMBER;
 j 	NUMBER;
 k NUMBER;
 l_exceptions_tab FTE_TL_CORE.tl_exceptions_tab_type;
 l_trip_charges_tab FTE_TL_CACHE.TL_TRIP_OUTPUT_TAB_TYPE;
 l_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
 l_stop_charges_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;
 l_stop_charges_one_trip_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;
 l_cost_allocation_parameters FTE_TL_COST_ALLOCATION.TL_allocation_params_rec_type;


 l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Rate_Cached_Trip_Multiple','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	l_exceptions_tab.delete;

	FTE_TL_CORE.TL_Core_Multiple (
		    p_start_trip_index=>p_start_trip_index,
		    p_end_trip_index=>p_end_trip_index,
	            p_trip_tab=>FTE_TL_CACHE.g_tl_trip_rows,
	            p_stop_tab=>FTE_TL_CACHE.g_tl_trip_stop_rows,
	            p_carrier_pref_tab=>FTE_TL_CACHE.g_tl_carrier_pref_rows,
	            x_trip_charges_tab=>l_trip_charges_tab,
	            x_stop_charges_tab=>l_stop_charges_tab,
		    x_exceptions_tab=>l_exceptions_tab,
	            x_return_status     => l_return_status );


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  --FTE_FREIGHT_PRICING_UTIL.setmsg (
		  --	p_api=>'TL_Rate_Cached_Trip',
		  --	p_exc=>'g_tl_core_fail',
		  --	p_trip_id=>FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail;
	       END IF;
	END IF;







	FTE_TL_COST_ALLOCATION.Get_Cost_Allocation_Parameters(
		x_cost_allocation_parameters=>	l_cost_allocation_parameters,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail;
	       END IF;
	END IF;

	l_cost_allocation_parameters.comparison_request_id := p_request_id;
	l_cost_allocation_parameters.output_type := p_output_type;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, 'Begining cost allocation index:'||p_start_trip_index||'  to:'||p_end_trip_index);

	k:=p_start_trip_index;
	i:=p_start_trip_index;
	WHILE(i<=p_end_trip_index)
	LOOP


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, 'Allocating index:'||i);
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG, 'Allocating index:'||i||'check_tlqp_ouputfail:'||l_exceptions_tab(i).check_tlqp_ouputfail||'check_qp_ipl_fail:'||l_exceptions_tab(i).check_qp_ipl_fail );
		IF ((l_exceptions_tab(i).check_tlqp_ouputfail='N') AND (l_exceptions_tab(i).check_qp_ipl_fail='N'))
		THEN

			l_stop_charges_one_trip_tab.delete;
			j:=l_trip_charges_tab(i).stop_charge_reference;
			WHILE((FTE_TL_CACHE.g_tl_trip_rows(i).number_of_stops > 0) AND
			(j<(FTE_TL_CACHE.g_tl_trip_rows(i).number_of_stops+l_trip_charges_tab(i).stop_charge_reference)))
			LOOP

				l_stop_charges_one_trip_tab(j):=l_stop_charges_tab(j);
				j:=j+1;
			END LOOP;


			x_lane_sched_sum_rows(k):=NULL;

			--Populate summary rates

			FTE_TL_COST_ALLOCATION.Get_Total_Trip_Cost(
				p_trip_index=>	i,
				p_trip_charges_rec=>	l_trip_charges_tab(i),
				p_stop_charges_tab=>	l_stop_charges_one_trip_tab,
				x_charge=>x_lane_sched_sum_rows(k),
				x_return_status=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail;
			       END IF;
			END IF;

			l_trip_charges_tab(i).total_trip_rate:=x_lane_sched_sum_rows(k);
			x_lane_sched_curr_rows(k):=FTE_TL_CACHE.g_tl_carrier_pref_rows(i).currency;


			IF (p_allocate_flag = 'Y')
			THEN


				FTE_TL_COST_ALLOCATION.TL_COST_ALLOCATION(
					p_trip_index=>	i,
					p_trip_charges_rec=>	l_trip_charges_tab(i),
					p_stop_charges_tab=>	l_stop_charges_one_trip_tab,
					p_cost_allocation_parameters=>	l_cost_allocation_parameters,
					x_output_cost_tab=>	x_output_cost_tab,
					x_return_status=>	l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN

					  --FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_Rate_Cached_Trip',
					--	p_exc=>'g_tl_cost_allocation_fail',
					--	p_trip_id=>l_trip_charges_rec.trip_id);

					l_exceptions_tab(i).allocation_failed:='Y';

					  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail;
				       END IF;
				END IF;

				IF (x_output_cost_tab.FIRST IS NOT NULL)
				THEN

					FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG-1:'||
					x_output_cost_tab(x_output_cost_tab.FIRST).lane_id||':'||
					x_output_cost_tab(x_output_cost_tab.FIRST).vehicle_type_id||':'||
					x_output_cost_tab(x_output_cost_tab.FIRST).delivery_leg_id||':'||
					x_output_cost_tab(x_output_cost_tab.FIRST).delivery_detail_id||':'||
					x_output_cost_tab(x_output_cost_tab.FIRST).freight_cost_id);

				END IF;
			ELSE

			   	x_trip_charges_tab:=l_trip_charges_tab;
	   			x_stop_charges_tab:= l_stop_charges_tab;


			END IF;
		ELSE

			x_lane_sched_sum_rows(k):=NULL;
			x_lane_sched_curr_rows(k):=NULL;

		END IF;

		k:=k+1;
		i:=i+1;
	END LOOP;


	x_exceptions_tab:=l_exceptions_tab;
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip_Multiple');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;
EXCEPTION

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip_Multiple',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_cost_alloc_param_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip_Multiple');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip_Multiple',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cost_allocation_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip_Multiple');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip_Multiple',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_core_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip_Multiple');
   WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Cached_Trip_Multiple',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Cached_Trip_Multiple');


END TL_Rate_Cached_Trip_Multiple;












  PROCEDURE TL_Rate_Trip (
	   p_trip_id           IN  NUMBER ,
	   p_output_type       IN  VARCHAR2,
	   p_check_reprice_flag IN VARCHAR2 DEFAULT 'N',
	   x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
	   x_return_status     OUT NOCOPY VARCHAR2) IS

 CURSOR get_move_id(c_trip_id IN NUMBER) IS
 	SELECT tm.move_id
 	FROM	FTE_TRIP_MOVES tm
 	WHERE tm.trip_id=c_trip_id;

 l_move_id NUMBER;
 l_output_cost_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
 l_reprice_flag VARCHAR2(1);
 l_term_manifest_flag VARCHAR2(1);

 l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN

 	SAVEPOINT TL_Rate_Trip;

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Rate_Trip','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;


 	OPEN get_move_id(p_trip_id);
 	FETCH get_move_id INTO l_move_id;
 	IF(get_move_id%FOUND)
 	THEN
 		CLOSE get_move_id;

		Check_Freight_Terms_Manifest(
			p_trip_id=> NULL,
			p_move_id=> l_move_id,
			x_term_manifest_flag=> l_term_manifest_flag,
			x_return_status => l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_check_freight_term_fail;
		       END IF;
		END IF;


		IF (l_term_manifest_flag='Y')
		THEN
		--move should not be rated because of freight terms,manifesting
		--messages have been set already

			l_warning_count:=l_warning_count+1;

		ELSE
		--No freight term/manifesting issues

			IF (p_check_reprice_flag = 'Y')
			THEN
				Is_Pricing_Required(
					p_trip_id => NULL,
					p_move_id => l_move_id,
					x_reprice_flag => l_reprice_flag,
					x_return_status => l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_is_pricing_required_fail;
				       END IF;
				END IF;
			ELSE
				l_reprice_flag:='Y';
			END IF;

			IF (l_reprice_flag = 'Y')
			THEN

				TL_Rate_Move(
					p_fte_move_id=>	l_move_id,
					p_output_type=>	p_output_type,
					x_output_cost_tab=>	l_output_cost_tab,
					x_return_status	=>	l_return_status);


				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_move_fail;
				       END IF;
				END IF;
			ELSE
				l_warning_count:=l_warning_count+1;
				FTE_FREIGHT_PRICING_UTIL.setmsg(
				  p_api			=> 'TL_Rate_Trip',
				  p_exc			=> ' ',
				  --p_msg_name		=> 'FTE_PRICING_NOT_REQUIRED',
				  p_msg_type		=> 'W');

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
				'  Not rating move:'||l_move_id||' because of reprice flag ');
			END IF;
		END IF;

 	ELSE
 		CLOSE get_move_id;

		Check_Freight_Terms_Manifest(
			p_trip_id=> p_trip_id,
			p_move_id=> NULL,
			x_term_manifest_flag=> l_term_manifest_flag,
			x_return_status => l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_check_freight_term_fail;
		       END IF;
		END IF;


		IF (l_term_manifest_flag='Y')
		THEN
		--trip should not be rated because of freight terms,manifesting
		--messages have been set already

			l_warning_count:=l_warning_count+1;

		ELSE
		--No freight term/manifesting issues

			IF (p_check_reprice_flag = 'Y')
			THEN
				Is_Pricing_Required(
					p_trip_id => p_trip_id,
					p_move_id => NULL,
					x_reprice_flag => l_reprice_flag,
					x_return_status => l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_is_pricing_required_fail;
				       END IF;
				END IF;
			ELSE
				l_reprice_flag:='Y';
			END IF;

			IF (l_reprice_flag = 'Y')
			THEN
				IF (p_output_type='M')
				THEN

					Delete_Main_Records(
						p_trip_id => p_trip_id,
						x_return_status =>l_return_status);

					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
					THEN
					       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					       THEN
						  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail;
					       END IF;
					END IF;
				END IF;


				FTE_TL_CACHE.TL_Build_Cache_For_Trip(
					p_wsh_trip_id =>	p_trip_id,
					x_return_status =>	l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					FTE_FREIGHT_PRICING_UTIL.setmsg (
						p_api=>'TL_Rate_Trip',
						p_exc=>'g_tl_build_cache_trp_fail',
						p_trip_id=>p_trip_id);

					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_trp_fail;
				       END IF;
				END IF;

				FTE_TL_CACHE.Display_Cache;

				TL_Rate_Cached_Trip (
					p_trip_index=>	FTE_TL_CACHE.g_tl_trip_rows.LAST,
					p_output_type=>	p_output_type,
					x_output_cost_tab=>	x_output_cost_tab,
					x_return_status=>	l_return_status
				);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail;
				       END IF;
				END IF;

				IF (p_output_type='M')
				THEN

					Update_Pricing_Required_Flag(
					p_trip_id=>p_trip_id,
					x_return_status =>l_return_status);

					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
					THEN
					       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					       THEN
						FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
						'Failied to set reprice required flag for TRIP ID:'||p_trip_id);
					       END IF;
					END IF;
				END IF;

			ELSE
				-- Pricing not required
				l_warning_count:=l_warning_count+1;
				FTE_FREIGHT_PRICING_UTIL.setmsg(
				  p_api			=> 'TL_Rate_Trip',
				  p_exc			=> ' ',
				  --p_msg_name		=> 'FTE_PRICING_NOT_REQUIRED',
				  p_msg_type		=> 'W');

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Pricing was not required for TRIP ID:'||p_trip_id);

			END IF;
		END IF;

 	END IF;

 	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;
EXCEPTION



    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_check_freight_term_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_check_freight_term_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_main_rec_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_is_pricing_required_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_is_pricing_required_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_move_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_move_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_trp_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_build_cache_trp_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_cached_trip_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

    WHEN others THEN
    	 ROLLBACK TO TL_Rate_Trip;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Rate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Rate_Trip');

 END TL_Rate_Trip;


PROCEDURE Populate_Summary_Rates(
	p_lane_rows            IN  dbms_utility.number_array ,
	p_schedule_rows        IN  dbms_utility.number_array,
	p_vehicle_rows         IN  dbms_utility.number_array,
	p_start_trip_index     IN NUMBER,
	p_end_trip_index       IN NUMBER,
	p_exceptions_tab    IN FTE_TL_CORE.tl_exceptions_tab_type,
        x_lane_sched_sum_rows  IN OUT NOCOPY  dbms_utility.number_array,
        x_lane_sched_curr_rows IN OUT NOCOPY  dbms_utility.name_array,
	x_summary_cache_ref OUT NOCOPY dbms_utility.number_array,
	x_return_status        OUT NOCOPY Varchar2) IS

l_lane_sched_sum_rows  dbms_utility.number_array;
l_lane_sched_curr_rows dbms_utility.name_array;
i NUMBER;
j NUMBER;
l_lane_cached VARCHAR2(1);



 l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Populate_Summary_Rates','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;




	i:=p_lane_rows.FIRST;
	j:=p_start_trip_index;
	WHILE(i IS NOT NULL)
	LOOP
		l_lane_sched_sum_rows(i):=NULL;
		l_lane_sched_curr_rows(i):=NULL;
		x_summary_cache_ref(i):=NULL;

		IF( (j IS NOT NULL) AND (p_end_trip_index IS NOT NULL) AND (j<= p_end_trip_index))
		THEN

			l_lane_cached:='N';

			--Get rates only if that lane/schedule was cached

			IF( (FTE_TL_CACHE.g_tl_trip_rows(j).schedule_id IS NOT NULL)
				AND (FTE_TL_CACHE.g_tl_trip_rows(j).schedule_id= p_schedule_rows(i)) AND (p_vehicle_rows(i)=FTE_TL_CACHE.g_tl_trip_rows(j).vehicle_type ))
			THEN
				l_lane_cached:='Y';

			ELSIF ((FTE_TL_CACHE.g_tl_trip_rows(j).lane_id IS NOT NULL)
				AND (FTE_TL_CACHE.g_tl_trip_rows(j).lane_id= p_lane_rows(i))  AND (p_vehicle_rows(i)=FTE_TL_CACHE.g_tl_trip_rows(j).vehicle_type ))
			THEN
				l_lane_cached:='Y';

			END IF;


			IF (l_lane_cached= 'Y')
			THEN

				IF (
				p_exceptions_tab(j).check_tlqp_ouputfail='N' AND
				p_exceptions_tab(j).check_qp_ipl_fail='N' AND
				p_exceptions_tab(j).not_on_pl_flag='N' AND
				p_exceptions_tab(j).price_req_failed='N' AND
				p_exceptions_tab(j).allocation_failed='N'
				)
				THEN

					l_lane_sched_sum_rows(i):=x_lane_sched_sum_rows(j);
					l_lane_sched_curr_rows(i):=x_lane_sched_curr_rows(j);
					x_summary_cache_ref(i):=j;

				END IF;



				j:=j+1;
			END IF;

		END IF;

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL Lane:'||p_lane_rows(i)||'TL Schedule:'||p_schedule_rows(i)||'TL Vehicle:'||p_vehicle_rows(i)||' Rate:'||l_lane_sched_sum_rows(i)||l_lane_sched_curr_rows(i)|| ' Index:'||i);

		i:=p_lane_rows.NEXT(i);
	END LOOP;


	x_lane_sched_sum_rows.DELETE;
	x_lane_sched_curr_rows.DELETE;
	x_lane_sched_sum_rows:=l_lane_sched_sum_rows;
	x_lane_sched_curr_rows:=l_lane_sched_curr_rows;

 	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_Summary_Rates');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;
EXCEPTION


    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Populate_Summary_Rates',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_Summary_Rates');


END Populate_Summary_Rates;




PROCEDURE TL_TRIP_PRICE_COMPARE(
	p_wsh_trip_id          IN Number ,
	p_lane_rows            IN  dbms_utility.number_array ,
	p_schedule_rows        IN  dbms_utility.number_array,
	p_vehicle_rows         IN  dbms_utility.number_array,
        x_request_id           IN OUT NOCOPY NUMBER,
        x_lane_sched_sum_rows  OUT NOCOPY  dbms_utility.number_array,
        x_lane_sched_curr_rows OUT NOCOPY  dbms_utility.name_array,
	x_return_status        OUT NOCOPY Varchar2) IS

l_output_tab	FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
i 	NUMBER;
l_request_id    NUMBER;
l_exceptions_tab FTE_TL_CORE.tl_exceptions_tab_type;
l_trip_charges_tab	FTE_TL_CACHE.TL_trip_output_tab_type;
l_stop_charges_tab  FTE_TL_CACHE.TL_trip_stop_output_tab_type;
l_summary_cache_ref dbms_utility.number_array;

CURSOR c_get_req_id IS
SELECT fte_pricing_comp_request_s.nextval
FROM   sys.dual;

CURSOR c_trip_sum(c_trip_id NUMBER, c_request_id NUMBER,
                  c_lane_id NUMBER, c_schedule_id NUMBER)
IS
SELECT ffct.total_amount, ffct.currency_code
FROM fte_freight_costs_temp ffct, wsh_freight_cost_types wfct
WHERE ffct.freight_cost_type_id = wfct.freight_cost_type_id
AND wfct.name='SUMMARY'
AND ffct.trip_id = c_trip_id
AND ffct.comparison_request_id = c_request_id
AND  nvl(lane_id,-1) = nvl(c_lane_id,-1)
AND  nvl(schedule_id, -1) = nvl(c_schedule_id,-1);


l_term_manifest_flag VARCHAR2(1);
l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Trip_Price_Compare','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	Check_Freight_Terms_Manifest(
		p_trip_id=> p_wsh_trip_id,
		p_move_id=> NULL,
		x_term_manifest_flag=> l_term_manifest_flag,
		x_return_status => l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_check_freight_term_fail;
	       END IF;
	END IF;


	IF (l_term_manifest_flag='Y')
	THEN
	--trip should not be rated because of freight terms,manifesting
	--messages have been set already

		IF (x_request_id IS NULL OR x_request_id = 0) THEN

		   OPEN c_get_req_id;
		   FETCH c_get_req_id INTO l_request_id;
		   CLOSE c_get_req_id;

		   x_request_id := l_request_id;

		ELSE
		   l_request_id := x_request_id;
		END IF;

		l_warning_count:=l_warning_count+1;

	ELSE
	--No freight term/manifesting issues


		FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
		       END IF;
		END IF;

		FTE_TL_CACHE.TL_BUILD_CACHE_FOR_TRP_COMPARE(
			p_wsh_trip_id => p_wsh_trip_id,
			p_lane_rows=>	p_lane_rows,
			p_schedule_rows=> p_schedule_rows,
			p_vehicle_rows =>p_vehicle_rows,
			x_return_status=> l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  FTE_FREIGHT_PRICING_UTIL.setmsg (
				   p_api=>'TL_Trip_Price_Compare',
				   p_msg_type=>'W',
				   p_exc=>'g_tl_bld_cache_trp_cmp_fail',
				   p_trip_id=>p_wsh_trip_id);

				  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_trp_cmp_fail;
			       END IF;
			END IF;


		FTE_TL_CACHE.Display_Cache;

		IF (x_request_id IS NULL OR x_request_id = 0) THEN

		   OPEN c_get_req_id;
		   FETCH c_get_req_id INTO l_request_id;
		   CLOSE c_get_req_id;

		   x_request_id := l_request_id;

		ELSE
		   l_request_id := x_request_id;
		END IF;


		fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'comp request_id='||l_request_id);


		IF(FTE_TL_CACHE.g_tl_trip_rows.FIRST IS NOT NULL)
		THEN

			TL_Rate_Cached_Trip_Multiple (
			   p_start_trip_index  =>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
			   p_end_trip_index    =>FTE_TL_CACHE.g_tl_trip_rows.LAST,
			   p_output_type       =>'T',
		           p_request_id        =>l_request_id,
			   p_allocate_flag=>'Y',
			   x_lane_sched_sum_rows=>x_lane_sched_sum_rows,
			   x_lane_sched_curr_rows=>x_lane_sched_curr_rows,
			   x_output_cost_tab   =>l_output_tab,
			   x_exceptions_tab    =>l_exceptions_tab,
			   x_trip_charges_tab  =>l_trip_charges_tab,
			   x_stop_charges_tab  =>l_stop_charges_tab,
	   		   x_return_status     =>l_return_status);

	   		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			       		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'TL_Rate_Cached_Trip_Multiple has failed');
			       		raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail;
			       END IF;
			END IF;



			Populate_Summary_Rates(
				p_lane_rows=>p_lane_rows,
				p_schedule_rows=>p_schedule_rows,
				p_vehicle_rows=>p_vehicle_rows,
				p_start_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
				p_end_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.LAST,
				p_exceptions_tab=>l_exceptions_tab,
				x_lane_sched_sum_rows=>x_lane_sched_sum_rows,
				x_lane_sched_curr_rows=>x_lane_sched_curr_rows,
				x_summary_cache_ref=>l_summary_cache_ref,
				x_return_status=>l_return_status);

	   		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			       		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Populate_Summary_Rates has failed');
			       		raise FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail;
			       END IF;
			END IF;


	        END IF;

		fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Finished multiple rating and allocation..now checkign errors' );


		i:=l_exceptions_tab.FIRST;
		WHILE ( i IS NOT NULL)
		LOOP

			fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Error index :'||i );

			IF (
			l_exceptions_tab(i).check_tlqp_ouputfail='Y' OR
    			l_exceptions_tab(i).check_qp_ipl_fail='Y' OR
    			l_exceptions_tab(i).not_on_pl_flag='Y' OR
    			l_exceptions_tab(i).price_req_failed='Y' OR
    			l_exceptions_tab(i).allocation_failed='Y'
    			)
    			THEN

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Rate cached trip failed for trip index:'||i);
			       --Add warning message
				   l_warning_count:=l_warning_count+1;

				   IF (FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id IS NOT NULL)
				   THEN
					   --Show only generic message
					   --FTE_FREIGHT_PRICING_UTIL.setmsg (
						--p_api=>'TL_Trip_Price_Compare',
						--p_exc=>'g_tl_trip_cmp_rate_schd_fail',
						--p_msg_type=>'W',
						--p_trip_id=> p_wsh_trip_id,
						--p_schedule_id=>FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id);
					NULL;

				   ELSE
					--Show only generic message
					--   FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_Trip_Price_Compare',
					--	p_exc=>'g_tl_trip_cmp_rate_lane_fail',
					--	p_msg_type=>'W',
					--	p_trip_id=> p_wsh_trip_id,
					--	p_lane_id=>FTE_TL_CACHE.g_tl_trip_rows(i).lane_id);

					NULL;

				   END IF;



    			END IF;


			i:=l_exceptions_tab.NEXT(i);
		END LOOP;


	END IF;


	--In case there was a failure populate rates/currencies with NULL

        i := p_lane_rows.FIRST;
        WHILE (i IS NOT NULL)
        LOOP
        -- Note lane_id and schedule_id cannot be NOT NULL for the same index
        -- However, both tables must contain the same indices
            IF (NOT(x_lane_sched_sum_rows.EXISTS(i)))
            THEN
            	x_lane_sched_sum_rows(i):=NULL;
            	x_lane_sched_curr_rows(i):=NULL;

            END IF;

            fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Index:'||i||' Rate:'||x_lane_sched_sum_rows(i)||' Curr:'||x_lane_sched_curr_rows(i));


            i := p_lane_rows.NEXT(i);
        END LOOP;


 FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;
EXCEPTION



    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_populate_summary_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_check_freight_term_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_check_freight_term_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_trp_cmp_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_bld_cache_trp_cmp_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_cached_trip_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_move_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_move_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_trp_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_build_cache_trp_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');


    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Trip_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Trip_Price_Compare');



END TL_TRIP_PRICE_COMPARE;



PROCEDURE TL_DELIVERY_PRICE_COMPARE(
	p_wsh_delivery_id          IN Number ,
	p_lane_rows            IN  dbms_utility.number_array ,
	p_schedule_rows        IN  dbms_utility.number_array,
	p_vehicle_rows         IN  dbms_utility.number_array,
	p_dep_date                IN     DATE DEFAULT sysdate,
	p_arr_date                IN     DATE DEFAULT sysdate,
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	x_request_id           IN OUT NOCOPY NUMBER,
	x_lane_sched_sum_rows  OUT NOCOPY  dbms_utility.number_array,
	x_lane_sched_curr_rows OUT NOCOPY  dbms_utility.name_array,
	x_return_status        OUT NOCOPY Varchar2)
IS


CURSOR c_get_req_id IS
SELECT fte_pricing_comp_request_s.nextval
FROM   sys.dual;

CURSOR c_trip_sum(c_trip_id NUMBER, c_request_id NUMBER,
                  c_lane_id NUMBER, c_schedule_id NUMBER)
IS
SELECT ffct.total_amount, ffct.currency_code
FROM fte_freight_costs_temp ffct, wsh_freight_cost_types wfct
WHERE ffct.freight_cost_type_id = wfct.freight_cost_type_id
AND wfct.name='SUMMARY'
AND ffct.trip_id = c_trip_id
AND ffct.comparison_request_id = c_request_id
AND  nvl(lane_id,-1) = nvl(c_lane_id,-1)
AND  nvl(schedule_id, -1) = nvl(c_schedule_id,-1);



l_output_tab	FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
i 	NUMBER;
l_request_id    NUMBER;
l_exceptions_tab FTE_TL_CORE.tl_exceptions_tab_type;
l_trip_charges_tab	FTE_TL_CACHE.TL_trip_output_tab_type;
l_stop_charges_tab  FTE_TL_CACHE.TL_trip_stop_output_tab_type;
l_summary_cache_ref dbms_utility.number_array;


l_term_manifest_flag VARCHAR2(1);
l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Delivery_Price_Compare','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	--No freight term/manifesting issues


	FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;

	FTE_TL_CACHE.TL_BUILD_CACHE_FOR_DLV_COMPARE(
		p_wsh_delivery_id => p_wsh_delivery_id,
		p_lane_rows=>	p_lane_rows,
		p_schedule_rows=> p_schedule_rows,
		p_vehicle_rows =>p_vehicle_rows,
		p_dep_date=>p_dep_date,
		p_arr_date=>p_arr_date,
		p_pickup_location_id=>p_pickup_location_id,
		p_dropoff_location_id=>p_dropoff_location_id,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

	       	  --l_warning_count:=l_warning_count+1;

		  --FTE_FREIGHT_PRICING_UTIL.setmsg (
		  -- p_api=>'TL_Delivery_Price_Compare',
		  -- p_msg_type=>'W',
		  -- p_exc=>'g_tl_bld_cache_trp_cmp_fail',
		  -- p_trip_id=>p_wsh_trip_id);
		NULL;
		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_trp_cmp_fail;
	       END IF;
	END IF;


	FTE_TL_CACHE.Display_Cache;

	IF (x_request_id IS NULL OR x_request_id = 0) THEN

	   OPEN c_get_req_id;
	   FETCH c_get_req_id INTO l_request_id;
	   CLOSE c_get_req_id;

	   x_request_id := l_request_id;

	ELSE
	   l_request_id := x_request_id;
	END IF;


	fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'comp request_id='||l_request_id);


	IF(FTE_TL_CACHE.g_tl_trip_rows.FIRST IS NOT NULL)
	THEN

		TL_Rate_Cached_Trip_Multiple (
		   p_start_trip_index  =>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
		   p_end_trip_index    =>FTE_TL_CACHE.g_tl_trip_rows.LAST,
		   p_output_type       =>'T',
		   p_request_id        =>l_request_id,
		   p_allocate_flag=>'Y',
		   x_lane_sched_sum_rows=>x_lane_sched_sum_rows,
		   x_lane_sched_curr_rows=>x_lane_sched_curr_rows,
		   x_output_cost_tab   =>l_output_tab,
		   x_exceptions_tab    =>l_exceptions_tab,
		   x_trip_charges_tab  =>l_trip_charges_tab,
		   x_stop_charges_tab  =>l_stop_charges_tab,
		   x_return_status     =>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'TL_Rate_Cached_Trip_Multiple has failed');
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail;
		       END IF;
		END IF;

		Populate_Summary_Rates(
			p_lane_rows=>p_lane_rows,
			p_schedule_rows=>p_schedule_rows,
			p_vehicle_rows=>p_vehicle_rows,
			p_start_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
			p_end_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.LAST,
			p_exceptions_tab=>l_exceptions_tab,
			x_lane_sched_sum_rows=>x_lane_sched_sum_rows,
			x_lane_sched_curr_rows=>x_lane_sched_curr_rows,
			x_summary_cache_ref=>l_summary_cache_ref,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Populate_Summary_Rates has failed');
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail;
		       END IF;
		END IF;

	END IF;

	fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Finished multiple rating and allocation..now checkign errors.' );

	i:=l_exceptions_tab.FIRST;

	WHILE ( i IS NOT NULL)
	LOOP

		fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Error index :'||i );

		IF (
		l_exceptions_tab(i).check_tlqp_ouputfail='Y' OR
		l_exceptions_tab(i).check_qp_ipl_fail='Y' OR
		l_exceptions_tab(i).not_on_pl_flag='Y' OR
		l_exceptions_tab(i).price_req_failed='Y' OR
		l_exceptions_tab(i).allocation_failed='Y'
		)
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Rate cached trip failed for trip index:'||i);
		       --Add warning message
			   l_warning_count:=l_warning_count+1;

			   --IF (FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id IS NOT NULL)
			   --THEN

			--	   FTE_FREIGHT_PRICING_UTIL.setmsg (
			--		p_api=>'TL_Delivery_Price_Compare',
			--		p_exc=>'g_tl_trip_cmp_rate_schd_fail',
			--		p_msg_type=>'W',
			--		p_trip_id=> p_wsh_trip_id,
			--		p_schedule_id=>FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id);


			   --ELSE

			--	   FTE_FREIGHT_PRICING_UTIL.setmsg (
			--		p_api=>'TL_Delivery_Price_Compare',
			--		p_exc=>'g_tl_trip_cmp_rate_lane_fail',
			--		p_msg_type=>'W',
			--		p_trip_id=> p_wsh_trip_id,
			--		p_lane_id=>FTE_TL_CACHE.g_tl_trip_rows(i).lane_id);

			   --END IF;



		END IF;


		i:=l_exceptions_tab.NEXT(i);
	END LOOP;



	--Populate null into rates/currencies in case there was a failure

        i := p_lane_rows.FIRST;
        WHILE (i IS NOT NULL)
        LOOP
        -- Note lane_id and schedule_id cannot be NOT NULL for the same index
        -- However, both tables must contain the same indices
            IF (NOT(x_lane_sched_sum_rows.EXISTS(i)))
            THEN
            	x_lane_sched_sum_rows(i):=NULL;
            	x_lane_sched_curr_rows(i):=NULL;

            END IF;

            fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Index:'||i||' Rate:'||x_lane_sched_sum_rows(i)||' Curr:'||x_lane_sched_curr_rows(i));


            i := p_lane_rows.NEXT(i);
        END LOOP;


 FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;
EXCEPTION




    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_populate_summary_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_check_freight_term_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_check_freight_term_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_trp_cmp_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_bld_cache_trp_cmp_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_cached_trip_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_move_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_move_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_trp_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_build_cache_trp_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');


    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Delivery_Price_Compare',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Delivery_Price_Compare');





END TL_DELIVERY_PRICE_COMPARE;



PROCEDURE Get_Base_Accessory_Charges(
	p_trip_index IN NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN 	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_base_price IN OUT NOCOPY NUMBER,
	x_acc_charge IN OUT NOCOPY NUMBER,
	x_currency IN OUT NOCOPY VARCHAR2,
	x_return_status        OUT NOCOPY Varchar2) IS


 l_charge NUMBER;
 l_return_status VARCHAR2(1);
 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
 l_warning_count 	NUMBER:=0;

BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Base_Accessory_Charges','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FTE_TL_COST_ALLOCATION.Get_Total_Trip_Cost(
		p_trip_index=>p_trip_index,
		p_trip_charges_rec=>p_trip_charges_rec,
		p_stop_charges_tab=>p_stop_charges_tab,
		x_charge=> l_charge,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail;
	       END IF;
	END IF;

	--Calculate base price
	x_base_price:=p_trip_charges_rec.base_dist_load_chrg+p_trip_charges_rec.base_dist_unload_chrg+
			p_trip_charges_rec.base_unit_chrg+p_trip_charges_rec.base_time_chrg+
			p_trip_charges_rec.base_flat_chrg;


	--Calculate accessory charges
	x_acc_charge:=l_charge - x_base_price;

	--
	x_currency:=p_trip_charges_rec.currency;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Base_Accessory_Charges');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Base_Accessory_Charges',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_tot_trp_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Base_Accessory_Charges');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Base_Accessory_Charges',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Base_Accessory_Charges');


END Get_Base_Accessory_Charges;


PROCEDURE TL_FREIGHT_ESTIMATE(
	p_lane_rows            IN  dbms_utility.number_array ,
	p_schedule_rows        IN  dbms_utility.number_array,
	p_vehicle_rows         IN  dbms_utility.number_array,
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	p_ship_date IN DATE,
	p_delivery_date IN DATE,
	p_weight IN NUMBER,
	p_weight_uom IN VARCHAR2,
	p_volume IN NUMBER,
	p_volume_uom IN VARCHAR2,
	p_distance IN NUMBER,
	p_distance_uom in VARCHAR2,
        x_lane_sched_base_rows  OUT NOCOPY  dbms_utility.number_array,
        x_lane_sched_acc_rows  OUT NOCOPY  dbms_utility.number_array,
        x_lane_sched_curr_rows OUT NOCOPY  dbms_utility.name_array,
	x_return_status        OUT NOCOPY Varchar2,
     --Bug 6625274
    p_origin_id  IN NUMBER DEFAULT NULL,
    p_destination_id IN NUMBER DEFAULT NULL) IS


 l_trip_charges_rec FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE;
 l_stop_charges_tab FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_TAB_TYPE;
 i NUMBER;
 j NUMBER;
 l_return_status VARCHAR2(1);
 l_rating_fail VARCHAR2(1);
 l_cache_fail VARCHAR2(1);
 l_lane_fail VARCHAR2(1);
 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
 l_warning_count 	NUMBER:=0;

BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_FREIGHT_ESTIMATE','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_cache_fail:='N';

	FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;


	FTE_TL_CACHE.TL_BUILD_CACHE_FOR_ESTIMATE(
		p_lane_rows=>p_lane_rows,
		p_schedule_rows=> p_schedule_rows,
		p_vehicle_rows=>p_vehicle_rows,
		p_pickup_location_id=>p_pickup_location_id,
		p_dropoff_location_id=>p_dropoff_location_id,
		p_ship_date=>p_ship_date,
		p_delivery_date=>p_delivery_date,
		p_weight=>p_weight,
		p_weight_uom=>p_weight_uom,
		p_volume=>p_volume,
		p_volume_uom=>p_volume_uom ,
		p_distance=>p_distance,
		p_distance_uom=>p_distance_uom,
		x_return_status=>l_return_status,
        --Bug 6625274
        p_origin_id => p_origin_id,
        p_destination_id => p_destination_id);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	       	l_cache_fail:='Y';
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Failed to build cache for estimate');

		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_cache_estimate_fail;
	       END IF;
	END IF;

	FTE_TL_CACHE.Display_Cache;

	i:=FTE_TL_CACHE.g_tl_trip_rows.FIRST;
	j:=p_lane_rows.FIRST;
	WHILE( j IS NOT NULL)
	LOOP

		--Have entries in output for every lane/schedule passed in

		x_lane_sched_base_rows(j):=NULL;
		x_lane_sched_acc_rows(j):=NULL;
		x_lane_sched_curr_rows(j):=NULL;

		l_lane_fail:='Y';

		--Get rates only if that lane/schedule was cached

		IF( (i IS NOT NULL) AND (FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id IS NOT NULL)
			AND (FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id= p_schedule_rows(j)) AND (p_vehicle_rows(j)=FTE_TL_CACHE.g_tl_trip_rows(i).vehicle_type ))
		THEN
			l_lane_fail:='N';

		ELSIF ((i IS NOT NULL) AND (FTE_TL_CACHE.g_tl_trip_rows(i).lane_id IS NOT NULL)
			AND (FTE_TL_CACHE.g_tl_trip_rows(i).lane_id= p_lane_rows(j))  AND (p_vehicle_rows(j)=FTE_TL_CACHE.g_tl_trip_rows(i).vehicle_type ))
		THEN
			l_lane_fail:='N';

		END IF;


		IF ((l_cache_fail='N') AND (l_lane_fail='N'))
		THEN

			l_rating_fail:='N';

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Now Rating Lane'|| FTE_TL_CACHE.g_tl_trip_rows(i).lane_id||
				' Schedule :'||FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id);

			FTE_TL_CORE.tl_core (
			   p_trip_rec          => FTE_TL_CACHE.g_tl_trip_rows(i),
			   p_stop_tab          => FTE_TL_CACHE.g_tl_trip_stop_rows,
			   p_carrier_pref      => FTE_TL_CACHE.g_tl_carrier_pref_rows(i),
			   x_trip_charges_rec  => l_trip_charges_rec,
			   x_stop_charges_tab  => l_stop_charges_tab,
			   x_return_status     => l_return_status );

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  l_rating_fail:='Y';
				  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL Core failed for trip index :'||i);
				  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail;
			       END IF;
			END IF;


			IF (l_rating_fail='N')
			THEN

				Get_Base_Accessory_Charges(
					p_trip_index=>i,
					p_trip_charges_rec=>l_trip_charges_rec,
					p_stop_charges_tab=>l_stop_charges_tab,
					x_base_price=>x_lane_sched_base_rows(j),
					x_acc_charge=>x_lane_sched_acc_rows(j),
					x_currency=>x_lane_sched_curr_rows(j),
					x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN

					  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL base,acc charges failed for trip index :'||i);
					  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_base_acc_chrg_fail;
				       END IF;
				END IF;
			END IF;

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'For Lane'|| FTE_TL_CACHE.g_tl_trip_rows(i).lane_id||
				' Schedule :'||FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id);

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Estimate:'||x_lane_sched_base_rows(j)||
				':'||x_lane_sched_acc_rows(j)||':'||x_lane_sched_curr_rows(j));

			i:=FTE_TL_CACHE.g_tl_trip_rows.NEXT(i);
		END IF;
		j:=p_lane_rows.NEXT(j);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_FREIGHT_ESTIMATE');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;

EXCEPTION

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_FREIGHT_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_FREIGHT_ESTIMATE');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_estimate_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_FREIGHT_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_estimate_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_FREIGHT_ESTIMATE');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_core_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_FREIGHT_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_core_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_FREIGHT_ESTIMATE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_base_acc_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_FREIGHT_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_base_acc_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_FREIGHT_ESTIMATE');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_FREIGHT_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_FREIGHT_ESTIMATE');


END TL_FREIGHT_ESTIMATE;



PROCEDURE Populate_OM_Rates(
	p_start_trip_index 		IN 	NUMBER,
	p_end_trip_index 		IN 	NUMBER,
	p_lane_info_tab   IN FTE_FREIGHT_RATING_PUB.lane_info_tab_type,
	p_output_cost_tab 	IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_LCSS_flag IN VARCHAR2,
	p_lane_sched_sum_rows  IN  dbms_utility.number_array,
	p_lane_sched_curr_rows IN  dbms_utility.name_array,
	p_filtered_rows IN dbms_utility.number_array,
	p_ref_rows IN dbms_utility.number_array,
	p_summary_cache_ref IN dbms_utility.number_array,
	x_source_header_rates_tab  IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_source_line_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_return_status 	OUT 	NOCOPY	VARCHAR2)
IS

l_source_header_rate_rec FTE_PROCESS_REQUESTS.fte_source_header_rates_rec;
l_source_line_rate_rec FTE_PROCESS_REQUESTS.fte_source_line_rates_rec;
l_detail_records FTE_PROCESS_REQUESTS.fte_source_line_rates_tab;
l_detail_price dbms_utility.number_array;
l_detail_charge dbms_utility.number_array;
l_price NUMBER;
l_charge NUMBER;


i NUMBER;
j NUMBER;
k NUMBER;
l NUMBER;
m NUMBER;
l_target_currency VARCHAR2(30);
l_converted_amount NUMBER;

 l_return_status VARCHAR2(1);
 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
 l_warning_count 	NUMBER:=0;

BEGIN

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Populate_OM_Rates','start');

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


  IF (p_source_header_rec.currency is NULL)
  THEN
    l_target_currency := 'USD';
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'source header currency is null, use USD');
  ELSE
    l_target_currency := p_source_header_rec.currency;
  END IF;

  k:=p_output_cost_tab.FIRST;


  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates count:'||p_output_cost_tab.COUNT);

  i:=p_lane_sched_sum_rows.FIRST;



  m:=x_source_header_rates_tab.LAST;
  IF(m IS NULL)
  THEN
  	m:=1;
  ELSE
  	m:=m+1;
  END IF;


  j:=x_source_line_rates_tab.LAST;
  IF(j IS NULL)
  THEN
  	j:=1;
  ELSE
  	j:=j+1;
  END IF;



  WHILE (i IS NOT NULL)
  LOOP


    IF (p_filtered_rows(i) = 1)
    THEN




	  IF((p_lane_sched_sum_rows(i) IS NOT NULL))
	  THEN

		x_source_header_rates_tab(m):=l_source_header_rate_rec;
	  	IF (l_target_currency <> p_lane_sched_curr_rows(i))
	  	THEN


			l_converted_amount:=GL_CURRENCY_API.convert_amount(
			     p_lane_sched_curr_rows(i),
			     l_target_currency,
			     SYSDATE,
			     'Corporate',
			     p_lane_sched_sum_rows(i)
			     );

			IF (l_converted_amount IS NULL)
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
			END IF;
		ELSE

			l_converted_amount:=p_lane_sched_sum_rows(i);
		END IF;

		x_source_header_rates_tab(m).consolidation_id := FTE_TL_CACHE.g_tl_trip_rows(p_summary_cache_ref(i)).trip_id;

		x_source_header_rates_tab(m).lane_id := FTE_TL_CACHE.g_tl_trip_rows(p_summary_cache_ref(i)).lane_id;
		x_source_header_rates_tab(m).carrier_id := FTE_TL_CACHE.g_tl_trip_rows(p_summary_cache_ref(i)).carrier_id;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-12');
		x_source_header_rates_tab(m).carrier_freight_code := p_lane_info_tab(p_ref_rows(i)).carrier_freight_code;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-13');
		x_source_header_rates_tab(m).service_level := FTE_TL_CACHE.g_tl_trip_rows(p_summary_cache_ref(i)).service_type;
		x_source_header_rates_tab(m).mode_of_transport := FTE_TL_CACHE.g_tl_trip_rows(p_summary_cache_ref(i)).mode_of_transport;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-14');
		x_source_header_rates_tab(m).ship_method_code := p_lane_info_tab(p_ref_rows(i)).ship_method_code;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-15');
		x_source_header_rates_tab(m).cost_type_id := NULL;
		x_source_header_rates_tab(m).cost_type := 'SUMMARY';
		x_source_header_rates_tab(m).price := l_converted_amount;
		x_source_header_rates_tab(m).currency := l_target_currency;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-16');
		x_source_header_rates_tab(m).transit_time := p_lane_info_tab(p_ref_rows(i)).transit_time;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-17');
		x_source_header_rates_tab(m).transit_time_uom := p_lane_info_tab(p_ref_rows(i)).transit_time_uom;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-18');
		x_source_header_rates_tab(m).vehicle_type_id:=FTE_TL_CACHE.g_tl_trip_rows(p_summary_cache_ref(i)).vehicle_type;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-19');
		x_source_header_rates_tab(m).first_line_index := j;


		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-20');

		l_detail_records.DELETE;
		l_detail_price.DELETE;

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG0:'||x_source_header_rates_tab(m).lane_id||':'||x_source_header_rates_tab(m).vehicle_type_id||':'||x_source_header_rates_tab(m).consolidation_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG00:'||p_output_cost_tab(k).lane_id||':'||p_output_cost_tab(k).vehicle_type_id||':'||p_output_cost_tab(k).delivery_leg_id||':'||p_output_cost_tab(k).delivery_detail_id);
		--base charges:- base unloaded, base loaded, base unit, base time, base flat(PRICE/FTEPRICE)
		--All the rest are surcharges, subract base from summary to get (CHARGE/FTECHARGE)
		--Copy main fields from the summary record

		-- Position at first detail cost type of this consolidation/lane/vehicle

		WHILE((p_output_cost_tab.EXISTS(k)) AND((p_output_cost_tab(k).lane_id <> x_source_header_rates_tab(m).lane_id)
		OR (p_output_cost_tab(k).vehicle_type_id <> x_source_header_rates_tab(m).vehicle_type_id)))
		LOOP

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG.1:'||
			p_output_cost_tab(k).lane_id||':'||p_output_cost_tab(k).vehicle_type_id||
			':'||p_output_cost_tab(k).delivery_leg_id||':'||p_output_cost_tab(k).delivery_detail_id||
			':'||p_output_cost_tab(k).freight_cost_id);
			k:=p_output_cost_tab.NEXT(k);
		END LOOP;

		WHILE( (p_output_cost_tab.EXISTS(k)) AND(p_output_cost_tab(k).lane_id = x_source_header_rates_tab(m).lane_id)
		AND (p_output_cost_tab(k).vehicle_type_id = x_source_header_rates_tab(m).vehicle_type_id) AND ( (p_output_cost_tab(k).delivery_leg_id IS NULL) OR (p_output_cost_tab(k).delivery_leg_id <> x_source_header_rates_tab(m).consolidation_id)))
		LOOP
			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG.2');
			k:=p_output_cost_tab.NEXT(k);
		END LOOP;

		WHILE(p_output_cost_tab.EXISTS(k)) AND (p_output_cost_tab(k).delivery_leg_id IS NOT NULL) AND (p_output_cost_tab(k).delivery_leg_id = x_source_header_rates_tab(m).consolidation_id)
		AND (p_output_cost_tab(k).lane_id = x_source_header_rates_tab(m).lane_id) AND ((p_output_cost_tab(k).vehicle_type_id = x_source_header_rates_tab(m).vehicle_type_id)
		AND (p_output_cost_tab(k).delivery_detail_id IS NULL))
		LOOP

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG.3');
			k:=p_output_cost_tab.NEXT(k);
		END LOOP;


		WHILE((p_output_cost_tab.EXISTS(k)) AND (p_output_cost_tab(k).delivery_leg_id IS NOT NULL) AND (p_output_cost_tab(k).delivery_leg_id = x_source_header_rates_tab(m).consolidation_id)
		AND (p_output_cost_tab(k).lane_id = x_source_header_rates_tab(m).lane_id) AND ((p_output_cost_tab(k).vehicle_type_id = x_source_header_rates_tab(m).vehicle_type_id))
		AND (p_output_cost_tab(k).delivery_detail_id IS NOT NULL))
		LOOP

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG1');
			--If we come across a summary detail entry store it

			IF ((p_output_cost_tab(k).line_type_code IS NOT NULL)
			   AND(p_output_cost_tab(k).line_type_code='SUMMARY'))
			THEN

				IF (l_detail_records.EXISTS(p_output_cost_tab(k).delivery_detail_id))
				THEN
					FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Detail Summary already exists: ERROR');

				ELSE
					l_detail_records(p_output_cost_tab(k).delivery_detail_id):=l_source_line_rate_rec;
					l_detail_records(p_output_cost_tab(k).delivery_detail_id).source_line_id:=p_output_cost_tab(k).delivery_detail_id;
					l_detail_records(p_output_cost_tab(k).delivery_detail_id).priced_quantity:=p_output_cost_tab(k).billable_quantity;
					l_detail_records(p_output_cost_tab(k).delivery_detail_id).priced_uom:=p_output_cost_tab(k).billable_uom;
					l_detail_records(p_output_cost_tab(k).delivery_detail_id).currency:=l_target_currency;
					l_detail_records(p_output_cost_tab(k).delivery_detail_id).adjusted_price:=p_output_cost_tab(k).total_amount;

					FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG2');
				END IF;

			--If we come across a price record total it up

			ELSIF ((p_output_cost_tab(k).line_type_code IS NOT NULL)
			   AND(p_output_cost_tab(k).line_type_code='TLPRICE'))
			THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG3');
				--Do currency conversion later as all the detail rates are in carrier currency

				IF (l_detail_price.EXISTS(p_output_cost_tab(k).delivery_detail_id))
				THEN
					l_detail_price(p_output_cost_tab(k).delivery_detail_id):=l_detail_price(p_output_cost_tab(k).delivery_detail_id)
						+p_output_cost_tab(k).total_amount;

				ELSE
					l_detail_price(p_output_cost_tab(k).delivery_detail_id):=p_output_cost_tab(k).total_amount;

				END IF;



			ELSE
				--Its a charge record
				null;

				FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG4');
			END IF;





			k:=p_output_cost_tab.NEXT(k);
		END LOOP;



		l:=l_detail_price.FIRST;
		WHILE(l IS NOT NULL)
		LOOP


			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG5');
			x_source_line_rates_tab(j):=l_detail_records(l);

			--PRICE record


			l_price:=l_detail_price(l);
			l_charge:=x_source_line_rates_tab(j).adjusted_price - l_price;

			x_source_line_rates_tab(j).cost_type_id:=NULL;
			x_source_line_rates_tab(j).line_type_code := 'PRICE';
			x_source_line_rates_tab(j).cost_type      := 'FTEPRICE';
			x_source_line_rates_tab(j).cost_sub_type  := 'PRICE';

			IF (l_target_currency <> p_lane_sched_curr_rows(i))
			THEN


				l_converted_amount:=GL_CURRENCY_API.convert_amount(
				     p_lane_sched_curr_rows(i),
				     l_target_currency,
				     SYSDATE,
				     'Corporate',
				     l_price
				     );

				IF (l_converted_amount IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
				END IF;

			ELSE
				l_converted_amount:=l_price;

			END IF;


			x_source_line_rates_tab(j).currency:=l_target_currency;
			x_source_line_rates_tab(j).adjusted_price:=l_converted_amount;


			IF((x_source_line_rates_tab(j).priced_quantity IS NOT NULL) AND (x_source_line_rates_tab(j).priced_quantity <> 0))
			THEN

				FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG6');
				x_source_line_rates_tab(j).adjusted_unit_price:=l_converted_amount/x_source_line_rates_tab(j).priced_quantity;
				x_source_line_rates_tab(j).unit_price     := l_converted_amount/x_source_line_rates_tab(j).priced_quantity;

			ELSE
				FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG7');
				x_source_line_rates_tab(j).adjusted_unit_price:=l_converted_amount;
				x_source_line_rates_tab(j).unit_price     := l_converted_amount;


			END IF;
			x_source_line_rates_tab(j).base_price     := l_converted_amount;

			x_source_line_rates_tab(j).consolidation_id := x_source_header_rates_tab(m).consolidation_id;
			x_source_line_rates_tab(j).lane_id := x_source_header_rates_tab(m).lane_id ;
			x_source_line_rates_tab(j).carrier_id := x_source_header_rates_tab(m).carrier_id;
			x_source_line_rates_tab(j).carrier_freight_code := x_source_header_rates_tab(m).carrier_freight_code;
			x_source_line_rates_tab(j).service_level := x_source_header_rates_tab(m).service_level;
			x_source_line_rates_tab(j).mode_of_transport := x_source_header_rates_tab(m).mode_of_transport;
			x_source_line_rates_tab(j).ship_method_code := x_source_header_rates_tab(m).ship_method_code;




			--Create another record for charges

			j:=j+1;

			--CHARGE record

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG8');
			x_source_line_rates_tab(j):=l_detail_records(l);

			x_source_line_rates_tab(j).cost_type_id:=NULL;
			x_source_line_rates_tab(j).line_type_code := 'CHARGE';
			x_source_line_rates_tab(j).cost_type      := 'FTECHARGE';
			x_source_line_rates_tab(j).cost_sub_type  := 'CHARGE';

			IF (l_target_currency <> p_lane_sched_curr_rows(i))
			THEN
				l_converted_amount:=GL_CURRENCY_API.convert_amount(
				     p_lane_sched_curr_rows(i),
				     l_target_currency,
				     SYSDATE,
				     'Corporate',
				     l_charge
				     );

				IF (l_converted_amount IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
				END IF;
			ELSE
				l_converted_amount:=l_charge;

			END IF;


			x_source_line_rates_tab(j).currency:=l_target_currency;
			x_source_line_rates_tab(j).adjusted_price:=l_converted_amount;


			IF((x_source_line_rates_tab(j).priced_quantity IS NOT NULL) AND (x_source_line_rates_tab(j).priced_quantity <> 0))
			THEN
				x_source_line_rates_tab(j).adjusted_unit_price:=l_converted_amount/x_source_line_rates_tab(j).priced_quantity;
				x_source_line_rates_tab(j).unit_price     := l_converted_amount/x_source_line_rates_tab(j).priced_quantity;

			ELSE
				x_source_line_rates_tab(j).adjusted_unit_price:=l_converted_amount;
				x_source_line_rates_tab(j).unit_price     := l_converted_amount;


			END IF;
			x_source_line_rates_tab(j).base_price     := l_converted_amount;

			x_source_line_rates_tab(j).consolidation_id := x_source_header_rates_tab(m).consolidation_id;
			x_source_line_rates_tab(j).lane_id := x_source_header_rates_tab(m).lane_id ;
			x_source_line_rates_tab(j).carrier_id := x_source_header_rates_tab(m).carrier_id;
			x_source_line_rates_tab(j).carrier_freight_code := x_source_header_rates_tab(m).carrier_freight_code;
			x_source_line_rates_tab(j).service_level := x_source_header_rates_tab(m).service_level;
			x_source_line_rates_tab(j).mode_of_transport := x_source_header_rates_tab(m).mode_of_transport;
			x_source_line_rates_tab(j).ship_method_code := x_source_header_rates_tab(m).ship_method_code;



			j:=j+1;


			l:=l_detail_price.NEXT(l);

		END LOOP;




		--increment to next delivery detail rate for next iter of the loop

		WHILE((k IS NOT NULL) AND (p_output_cost_tab(k).delivery_detail_id IS NULL))
		LOOP

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'src line rates DBG9');
			k:=p_output_cost_tab.NEXT(k);
		END LOOP;

	  	m:=m+1;

	  END IF;--p_lane_sched_sum_rows(i) IS NOT NULL


    END IF;--filtered rows


    i:=p_lane_sched_sum_rows.NEXT(i);

  END LOOP;




  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_OM_Rates');
  IF (l_warning_count > 0)
  THEN
	x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;

  EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Populate_OM_Rates',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_OM_Rates');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Populate_OM_Rates',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Populate_OM_Rates');




END Populate_OM_Rates;



-- Only the lanes for which the corresponding x_filtered_list_flag(i)=1 need to be considered
-- For the lanes which were expanded due to vehicles only one of them will have x_filtered_list_flag(i)=1
-- Some lanes need not have a rate
-- If p_LCSS_flag ='Y' the least cost is identified


PROCEDURE TL_Filter_For_Vehicle_Cost(
		p_lane_sched_sum_rows  IN  dbms_utility.number_array,
		p_lane_sched_curr_rows IN  dbms_utility.name_array,
		p_ref_rows IN dbms_utility.number_array,
		p_LCSS_flag IN VARCHAR2,
		x_filtered_list_flag OUT NOCOPY dbms_utility.number_array,
		x_least_index OUT NOCOPY NUMBER,
		x_return_status        OUT NOCOPY Varchar2)
IS

	l_lane_min_ref NUMBER;
	l_lane_min_rate NUMBER;
	l_lane_min_currency VARCHAR2(30);
	l_lane_min_index NUMBER;


	l_LCSS_ref NUMBER;
	l_LCSS_rate NUMBER;
	l_LCSS_currency VARCHAR2(30);
	l_LCSS_index NUMBER;


	l_converted_amount NUMBER;
	i NUMBER;
	l_return_status VARCHAR2(1);
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
	l_warning_count 	NUMBER:=0;

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Filter_For_Vehicle_Cost','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;




  	IF (p_LCSS_flag='Y')
  	THEN

  		l_LCSS_ref:=NULL;
		l_LCSS_rate:=NULL;
		l_LCSS_currency:=NULL;
		l_LCSS_index:=NULL;
		x_least_index:=NULL;

		i:=p_lane_sched_sum_rows.FIRST;

		WHILE(i IS NOT NULL)
		LOOP
			x_filtered_list_flag(i):=0;
			IF (p_lane_sched_sum_rows(i) IS NOT NULL)
			THEN

				IF (l_LCSS_currency IS NULL)
				THEN


					l_LCSS_rate:=p_lane_sched_sum_rows(i);
					l_LCSS_currency:=p_lane_sched_curr_rows(i);
					l_LCSS_index:=i;
					x_filtered_list_flag(i):=1;
					x_least_index:=i;

				ELSE

					IF(l_LCSS_currency <> p_lane_sched_curr_rows(i))
					THEN
						l_converted_amount:=GL_CURRENCY_API.convert_amount(
						     p_lane_sched_curr_rows(i),
						     l_LCSS_currency,
						     SYSDATE,
						     'Corporate',
						     p_lane_sched_sum_rows(i)
						     );

						IF (l_converted_amount IS NULL)
						THEN
							raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
						END IF;


					ELSE

						l_converted_amount:=p_lane_sched_sum_rows(i);

					END IF;

					IF (l_converted_amount < l_LCSS_rate)
					THEN

						x_filtered_list_flag(l_LCSS_index):=0;

						l_LCSS_rate:=p_lane_sched_sum_rows(i);
						l_LCSS_currency:=p_lane_sched_curr_rows(i);
						l_LCSS_index:=i;
						x_filtered_list_flag(i):=1;
						x_least_index:=i;

					END IF;


				 END IF;

			END IF;


			i:=p_lane_sched_sum_rows.NEXT(i);
		END LOOP;


  	ELSE
  	--LCSS_flag='N'



		l_lane_min_ref:=NULL;
		l_lane_min_rate:=NULL;
		l_lane_min_currency:=NULL;
		l_lane_min_index:=NULL;




		i:=p_lane_sched_sum_rows.FIRST;

		WHILE(i IS NOT NULL)
		LOOP
			IF((l_lane_min_ref IS NOT NULL) AND (p_ref_rows(i) = l_lane_min_ref))
			THEN
				-- A vehicle with some rate is preferred to a vehicle with no rate

				IF((l_lane_min_rate IS NOT NULL) AND (p_lane_sched_curr_rows(i) IS NOT NULL) AND (l_lane_min_currency <> p_lane_sched_curr_rows(i)))
				THEN

					l_converted_amount:=GL_CURRENCY_API.convert_amount(
					     p_lane_sched_curr_rows(i),
					     l_lane_min_currency,
					     SYSDATE,
					     'Corporate',
					     p_lane_sched_sum_rows(i)
					     );

					IF (l_converted_amount IS NULL)
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
					END IF;


				ELSE

					l_converted_amount:=p_lane_sched_sum_rows(i);

				END IF;

				IF ((l_converted_amount IS NOT NULL) AND ((l_lane_min_rate IS NULL) OR (l_converted_amount < l_lane_min_rate)) )
				THEN
					x_filtered_list_flag(l_lane_min_index):=0;
					x_filtered_list_flag(i):=1;

					l_lane_min_ref:=p_ref_rows(i);
					l_lane_min_rate:=p_lane_sched_sum_rows(i);
					l_lane_min_currency:=p_lane_sched_curr_rows(i);
					l_lane_min_index:=i;


				ELSE
					x_filtered_list_flag(i):=0;


				END IF;


			ELSE

				x_filtered_list_flag(i):=1;
				l_lane_min_ref:=p_ref_rows(i);
				l_lane_min_rate:=p_lane_sched_sum_rows(i);
				l_lane_min_currency:=p_lane_sched_curr_rows(i);
				l_lane_min_index:=i;

			END IF;


			i:=p_lane_sched_sum_rows.NEXT(i);
		END LOOP;


	END IF;



  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Filter_For_Vehicle_Cost');
  IF (l_warning_count > 0)
  THEN
	x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
  END IF;



  EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Filter_For_Vehicle_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Filter_For_Vehicle_Cost');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Filter_For_Vehicle_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Filter_For_Vehicle_Cost');


END TL_Filter_For_Vehicle_Cost;


PROCEDURE TL_OM_RATING(
	p_lane_rows            IN  dbms_utility.number_array ,
	p_schedule_rows        IN  dbms_utility.number_array,
	p_lane_info_tab   IN FTE_FREIGHT_RATING_PUB.lane_info_tab_type,
	p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_LCSS_flag IN VARCHAR2,
	x_source_header_rates_tab  IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_source_line_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_return_status        OUT NOCOPY Varchar2)
IS

l_exploded_lane_rows         dbms_utility.number_array;
l_exploded_schedule_rows     dbms_utility.number_array;
l_exploded_vehicle_rows      dbms_utility.number_array;
l_exploded_ref_rows      dbms_utility.number_array;
l_vehicle_rows      dbms_utility.number_array;

l_output_tab	FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
i 	NUMBER;
l_request_id    NUMBER;
l_exceptions_tab FTE_TL_CORE.tl_exceptions_tab_type;
l_trip_charges_tab	FTE_TL_CACHE.TL_trip_output_tab_type;
l_stop_charges_tab  FTE_TL_CACHE.TL_trip_stop_output_tab_type;

l_lane_sched_sum_rows dbms_utility.number_array;
l_lane_sched_curr_rows dbms_utility.name_array;
l_filtered_rows dbms_utility.number_array;
l_summary_cache_ref dbms_utility.number_array;

l_least_index NUMBER;
l_return_status VARCHAR2(1);
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
l_warning_count 	NUMBER:=0;

BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_OM_Rating','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	--No freight term/manifesting issues


	FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;

	l_vehicle_rows.delete;

	i:=p_lane_rows.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		l_vehicle_rows(i):=NULL;
		i:=p_lane_rows.NEXT(i);
	END LOOP;


	FTE_TL_RATING.Get_Vehicles_For_LaneSchedules(
		p_trip_id	=>NULL,
		p_lane_rows	=>p_lane_rows,
		p_schedule_rows =>p_schedule_rows,
		p_vehicle_rows	=>l_vehicle_rows,
		x_vehicle_rows  =>l_exploded_vehicle_rows,
		x_lane_rows 	=>l_exploded_lane_rows,
		x_schedule_rows =>l_exploded_schedule_rows,
		x_ref_rows	=>l_exploded_ref_rows,
		x_return_status =>l_return_status);
      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      THEN
	 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	 THEN
	    raise FTE_FREIGHT_PRICING_UTIL.g_tl_veh_for_lane_sched_fail;
	 END IF;
      END IF;



	FTE_TL_CACHE.TL_BUILD_CACHE_FOR_OM(
		p_source_header_rec=>p_source_header_rec,
		p_source_lines_tab=>p_source_lines_tab,
		p_lane_rows=>l_exploded_lane_rows,
		p_schedule_rows=>l_exploded_schedule_rows,
		p_vehicle_rows=>l_exploded_vehicle_rows,
		x_return_status=>l_return_status);



      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      THEN
	 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	 THEN
	    raise FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_om_fail;
	 END IF;
      END IF;

	FTE_TL_CACHE.Display_Cache;


	IF(FTE_TL_CACHE.g_tl_trip_rows.FIRST IS NOT NULL)
	THEN

		TL_Rate_Cached_Trip_Multiple (
		   p_start_trip_index  =>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
		   p_end_trip_index    =>FTE_TL_CACHE.g_tl_trip_rows.LAST,
		   p_output_type       =>'P',
		   p_request_id        =>1,
		   p_allocate_flag=>'Y',
		   x_lane_sched_sum_rows=>l_lane_sched_sum_rows,
		   x_lane_sched_curr_rows=>l_lane_sched_curr_rows,
		   x_output_cost_tab   =>l_output_tab,
		   x_exceptions_tab    =>l_exceptions_tab,
		   x_trip_charges_tab  =>l_trip_charges_tab,
		   x_stop_charges_tab  =>l_stop_charges_tab,
		   x_return_status     =>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'TL_Rate_Cached_Trip_Multiple has failed');
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail;
		       END IF;
		END IF;


		Populate_Summary_Rates(
			p_lane_rows=>l_exploded_lane_rows,
			p_schedule_rows=>l_exploded_schedule_rows,
			p_vehicle_rows=>l_exploded_vehicle_rows,
			p_start_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
			p_end_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.LAST,
			p_exceptions_tab=>l_exceptions_tab,
			x_lane_sched_sum_rows=>l_lane_sched_sum_rows,
			x_lane_sched_curr_rows=>l_lane_sched_curr_rows,
			x_summary_cache_ref=>l_summary_cache_ref,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Populate_Summary_Rates has failed');
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail;
		       END IF;
		END IF;


	END IF;

	fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Finished multiple rating and allocation..now checkign errors' );

	i:=l_exceptions_tab.FIRST;
	WHILE ( i IS NOT NULL)
	LOOP

		fte_freight_pricing_util.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Error index :'||i );

		IF (
		l_exceptions_tab(i).check_tlqp_ouputfail='Y' OR
		l_exceptions_tab(i).check_qp_ipl_fail='Y' OR
		l_exceptions_tab(i).not_on_pl_flag='Y' OR
		l_exceptions_tab(i).price_req_failed='Y' OR
		l_exceptions_tab(i).allocation_failed='Y'
		)
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Rate cached trip failed for trip index:'||i);
		       --Add warning message
			   l_warning_count:=l_warning_count+1;

			   --IF (FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id IS NOT NULL)
			   --THEN

			--	   FTE_FREIGHT_PRICING_UTIL.setmsg (
			--		p_api=>'TL_OM_Rating',
			--		p_exc=>'g_tl_trip_cmp_rate_schd_fail',
			--		p_msg_type=>'W',
			--		p_trip_id=> p_wsh_trip_id,
			--		p_schedule_id=>FTE_TL_CACHE.g_tl_trip_rows(i).schedule_id);


			   --ELSE

			--	   FTE_FREIGHT_PRICING_UTIL.setmsg (
			--		p_api=>'TL_OM_Rating',
			--		p_exc=>'g_tl_trip_cmp_rate_lane_fail',
			--		p_msg_type=>'W',
			--		p_trip_id=> p_wsh_trip_id,
			--		p_lane_id=>FTE_TL_CACHE.g_tl_trip_rows(i).lane_id);

			   --END IF;



		END IF;


		i:=l_exceptions_tab.NEXT(i);
	END LOOP;


	TL_Filter_For_Vehicle_Cost(
		p_lane_sched_sum_rows=>l_lane_sched_sum_rows,
		p_lane_sched_curr_rows=>l_lane_sched_curr_rows,
		p_ref_rows=>l_exploded_ref_rows,
		p_LCSS_flag=>p_LCSS_flag,
		x_filtered_list_flag=>l_filtered_rows,
		x_least_index=>l_least_index,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_om_filt_least_veh_fail;
	       END IF;
	END IF;



	FTE_FREIGHT_PRICING.print_fc_temp_rows(
	  p_fc_temp_rows  => l_output_tab,
	  x_return_status => l_return_status);


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Lane Shed Sum Count:'||l_lane_sched_sum_rows.COUNT);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Filter Count:'||l_filtered_rows.COUNT);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Cache Ref:'||l_summary_cache_ref.COUNT);
	i:=l_lane_sched_sum_rows.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'index:'||i||' Price:'||l_lane_sched_sum_rows(i)||l_lane_sched_curr_rows(i)||' Filter:'||l_filtered_rows(i)||' Cache Ref:'||l_summary_cache_ref(i));
		i:=l_lane_sched_sum_rows.NEXT(i);

	END LOOP;

	Populate_OM_Rates(
		p_start_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
		p_end_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.LAST,
		p_lane_info_tab=>p_lane_info_tab,
		p_output_cost_tab=>l_output_tab,
		p_source_header_rec=>p_source_header_rec,
		p_source_lines_tab=>p_source_lines_tab,
		p_LCSS_flag=>p_LCSS_flag,
		p_lane_sched_sum_rows=>l_lane_sched_sum_rows,
		p_lane_sched_curr_rows=>l_lane_sched_curr_rows,
		p_filtered_rows=>l_filtered_rows,
		p_ref_rows=>l_exploded_ref_rows,
		p_summary_cache_ref=>l_summary_cache_ref,
		x_source_header_rates_tab=>x_source_header_rates_tab,
		x_source_line_rates_tab=>x_source_line_rates_tab,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_om_populate_rate_fail;
	       END IF;
	END IF;


 	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;

EXCEPTION


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_populate_summary_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_om_filt_least_veh_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_om_filt_least_veh_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_om_populate_rate_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_om_populate_rate_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');



    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_veh_for_lane_sched_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_veh_for_lane_sched_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_cached_trip_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');



    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_om_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_bld_cache_om_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');


    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('TL_OM_Rating',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_OM_Rating');

END TL_OM_RATING;



PROCEDURE BEGIN_LCSS (
	p_trip_id 	IN NUMBER,
	p_lane_rows IN dbms_utility.number_array ,
	x_trip_index       OUT NOCOPY NUMBER,
	x_trip_charges_rec  OUT NOCOPY FTE_TL_CACHE.TL_trip_output_rec_type ,
	x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_total_cost    OUT NOCOPY NUMBER,
	x_currency      OUT NOCOPY VARCHAR2,
	x_vehicle_type OUT NOCOPY NUMBER,
	x_lane_ref OUT NOCOPY NUMBER,
	x_return_status  OUT NOCOPY  VARCHAR2)
IS

i NUMBER;
l_schedule_rows	dbms_utility.number_array;
l_exploded_lane_rows         dbms_utility.number_array;
l_exploded_schedule_rows     dbms_utility.number_array;
l_exploded_vehicle_rows      dbms_utility.number_array;
l_exploded_ref_rows      dbms_utility.number_array;
l_vehicle_rows      dbms_utility.number_array;

l_output_tab	FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
l_request_id    NUMBER;
l_exceptions_tab FTE_TL_CORE.tl_exceptions_tab_type;
l_lane_sched_sum_rows dbms_utility.number_array;
l_lane_sched_curr_rows dbms_utility.name_array;
l_filtered_rows dbms_utility.number_array;
l_trip_charges_tab	FTE_TL_CACHE.TL_trip_output_tab_type;
l_stop_charges_tab  FTE_TL_CACHE.TL_trip_stop_output_tab_type;
l_least_index	NUMBER;
l_summary_cache_ref dbms_utility.number_array;
l_least_cache_index NUMBER;

l_return_status VARCHAR2(1);
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
l_warning_count 	NUMBER:=0;

BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'BEGIN_LCSS','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	i:=p_lane_rows.FIRST;
	WHILE ( i IS NOT NULL)
	LOOP
		l_vehicle_rows(i):=NULL;
		l_schedule_rows(i):=NULL;
		i:=p_lane_rows.NEXT(i);
	END LOOP;


	FTE_TL_RATING.Get_Vehicles_For_LaneSchedules(
		p_trip_id	=>NULL,
		p_lane_rows	=>p_lane_rows,
		p_schedule_rows =>l_schedule_rows,
		p_vehicle_rows	=>l_vehicle_rows,
		x_vehicle_rows  =>l_exploded_vehicle_rows,
		x_lane_rows 	=>l_exploded_lane_rows,
		x_schedule_rows =>l_exploded_schedule_rows,
		x_ref_rows	=>l_exploded_ref_rows,
		x_return_status =>l_return_status);

      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      THEN
	 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	 THEN
	    raise FTE_FREIGHT_PRICING_UTIL.g_tl_veh_for_lane_sched_fail;
	 END IF;
      END IF;



	FTE_TL_CACHE.TL_BUILD_CACHE_FOR_LCS(
	    p_wsh_trip_id => p_trip_id,
	    p_lane_rows => l_exploded_lane_rows,
	    p_schedule_rows =>l_exploded_schedule_rows,
	    p_vehicle_rows=>l_exploded_vehicle_rows,
	    x_return_status => l_return_status);


      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      THEN
	 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
	 THEN
	    raise FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_lcss_fail;
	 END IF;
      END IF;




	FTE_TL_CACHE.DISPLAY_CACHE();

	IF (FTE_TL_CACHE.g_tl_trip_rows.FIRST IS NOT NULL)
	THEN

		TL_Rate_Cached_Trip_Multiple (
		   p_start_trip_index  =>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
		   p_end_trip_index    =>FTE_TL_CACHE.g_tl_trip_rows.LAST,
		   p_output_type       =>'P',
		   p_request_id        =>NULL,
		   p_allocate_flag=>'N',
		   x_lane_sched_sum_rows=>l_lane_sched_sum_rows,
		   x_lane_sched_curr_rows=>l_lane_sched_curr_rows,
		   x_output_cost_tab   =>l_output_tab,
		   x_exceptions_tab    =>l_exceptions_tab,
		   x_trip_charges_tab  =>l_trip_charges_tab,
		   x_stop_charges_tab  =>l_stop_charges_tab,
		   x_return_status     =>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'TL_Rate_Cached_Trip_Multiple has failed');
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail;
		       END IF;
		END IF;

		Populate_Summary_Rates(
			p_lane_rows=>l_exploded_lane_rows,
			p_schedule_rows=>l_exploded_schedule_rows,
			p_vehicle_rows=>l_exploded_vehicle_rows,
			p_start_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.FIRST,
			p_end_trip_index=>FTE_TL_CACHE.g_tl_trip_rows.LAST,
			p_exceptions_tab=>l_exceptions_tab,
			x_lane_sched_sum_rows=>l_lane_sched_sum_rows,
			x_lane_sched_curr_rows=>l_lane_sched_curr_rows,
			x_summary_cache_ref=>l_summary_cache_ref,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Populate_Summary_Rates has failed');
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail;
		       END IF;
		END IF;




		TL_Filter_For_Vehicle_Cost(
			p_lane_sched_sum_rows=>l_lane_sched_sum_rows,
			p_lane_sched_curr_rows=>l_lane_sched_curr_rows,
			p_ref_rows=>l_exploded_ref_rows,
			p_LCSS_flag=>'Y',
			x_filtered_list_flag=>l_filtered_rows,
			x_least_index=>l_least_index,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

				raise FTE_FREIGHT_PRICING_UTIL.g_tl_om_filt_least_veh_fail;
		       END IF;
		END IF;


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_least_index:'||l_least_index);

		--l_least_index is the least index in the summary rates, this may not correspond to the cache index
		--Some lanes for which rates were null may not have been cached. This could result in the l_least_index
		-- not being a valid reference into the cache.

		IF (l_least_index IS NOT NULL)
		THEN

			x_trip_index:=l_summary_cache_ref(l_least_index);
		END IF;

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_least_cache index:'||x_trip_index);

		IF(x_trip_index IS NOT NULL)
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-1');
			x_lane_ref:=l_exploded_ref_rows(l_least_index);
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-2');
			x_vehicle_type:=l_exploded_vehicle_rows(l_least_index);
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-3');
			x_trip_charges_rec:=l_trip_charges_tab(x_trip_index);
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-4');

			x_total_cost:=x_trip_charges_rec.total_trip_rate;

			x_currency:=x_trip_charges_rec.currency;

			x_stop_charges_tab.delete;

			i:=x_trip_charges_rec.stop_charge_reference;
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-5');
			WHILE((FTE_TL_CACHE.g_tl_trip_rows(x_trip_index).number_of_stops > 0) AND
			(i<(FTE_TL_CACHE.g_tl_trip_rows(x_trip_index).number_of_stops+x_trip_charges_rec.stop_charge_reference)))
			LOOP
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-6');
				x_stop_charges_tab(i):=l_stop_charges_tab(i);
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-7');
				i:=i+1;
			END LOOP;


		END IF;
	END IF;

 	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');

 	IF (l_warning_count > 0)
 	THEN
 		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
 	END IF;


EXCEPTION


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_populate_summary_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('BEGIN_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_populate_summary_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_veh_for_lane_sched_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('BEGIN_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_veh_for_lane_sched_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_lcss_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('BEGIN_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_build_cache_lcss_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_rate_cached_trip_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('BEGIN_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_rate_cached_trip_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_om_filt_least_veh_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('BEGIN_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_om_filt_least_veh_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');

    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('BEGIN_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'BEGIN_LCSS');



END BEGIN_LCSS;


PROCEDURE END_LCSS (
	p_trip_index 		IN 	NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN 		FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_return_status         OUT NOCOPY  VARCHAR2)
IS


l_output_cost_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
l_cost_allocation_parameters FTE_TL_COST_ALLOCATION.TL_allocation_params_rec_type;


l_return_status VARCHAR2(1);
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
l_warning_count 	NUMBER:=0;

BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'END_LCSS','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	FTE_TL_COST_ALLOCATION.Get_Cost_Allocation_Parameters(
		x_cost_allocation_parameters => l_cost_allocation_parameters,
		x_return_status	=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail;
	       END IF;
	END IF;


	l_cost_allocation_parameters.output_type := 'M';

	FTE_TL_COST_ALLOCATION.TL_COST_ALLOCATION(
	  p_trip_index       => p_trip_index,
	  p_trip_charges_rec => p_trip_charges_rec,
	  p_stop_charges_tab => p_stop_charges_tab,
	  p_cost_allocation_parameters=> l_cost_allocation_parameters,
	  x_output_cost_tab => l_output_cost_tab,
	  x_return_status	=> l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail;
	       END IF;
	END IF;


	Update_Pricing_Required_Flag(
		p_trip_id=>FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id,
		x_return_status =>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
		'Failied to set reprice required flag for TRIP ID:'||FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id);
	       END IF;
	END IF;


	FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;

 	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'END_LCSS');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('END_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'END_LCSS');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_cost_alloc_param_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('END_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_cost_alloc_param_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'END_LCSS');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cost_allocation_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('END_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cost_allocation_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'END_LCSS');


    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('END_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'END_LCSS');


END END_LCSS;



PROCEDURE ABORT_LCSS (
	x_return_status         OUT NOCOPY  VARCHAR2)
IS
 l_return_status VARCHAR2(1);

 l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

 	l_warning_count 	NUMBER:=0;
BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'ABORT_LCSS','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	FTE_TL_CACHE.Delete_Cache(x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;

 	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'ABORT_LCSS');


	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('ABORT_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'ABORT_LCSS');

    WHEN others THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('ABORT_LCSS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
         FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'ABORT_LCSS');


END ABORT_LCSS;

PROCEDURE LCSS (
	p_trip_id 		IN NUMBER,
	p_lane_rows IN dbms_utility.number_array ,
	x_return_status         OUT NOCOPY  VARCHAR2)
IS
BEGIN

	NULL;

END LCSS;



END FTE_TL_RATING;

/
