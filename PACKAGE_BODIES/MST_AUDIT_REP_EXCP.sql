--------------------------------------------------------
--  DDL for Package Body MST_AUDIT_REP_EXCP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_AUDIT_REP_EXCP" AS
/* $Header: MSTEAREB.pls 115.27 2004/05/05 21:40:19 jansanch noship $ */

  --global variables
  distScaleFactor NUMBER;
  avgDrvSpeed NUMBER;
	tp_time_uom VARCHAR2(3);
  tp_distance_uom VARCHAR2(3);
	tp_dimension_uom VARCHAR2(3);
	tp_volume_uom VARCHAR2(3);
  user_id NUMBER(15);
	tp_plan_id NUMBER;
	msg_seq_num NUMBER;

  PROCEDURE MissingLatLongCoordExcptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER;
    dummyThreshold NUMBER;
  BEGIN
	 	-- Delete previous occurrences of this exception in mst_exceptions and the details table
	 	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 704;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 704;

		--check if exception appears in mst_excep_preferences (it does not have a threshold but
    --if it is enabled there should be an entry in that table with a dummy value for threshold).
		dummyThreshold := getExceptionThreshold(704,userIdIn);
    --if no threshold found it means exception is disabled, so exit procedure
    IF dummyThreshold  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;

		--Create fresh entry for exception and keep exception_id for updates in details table
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
                                created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
												VALUES (mst_exceptions_s.nextval, plan_idIn, 700, 704, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 704;

		INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																			 location_id,
																			 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																			 CREATION_DATE, STATUS)
	  SELECT mst_exception_details_s.nextval, excptnId , plan_idIn, 704,
					 location_id,
					 userIdIn, userIdIn,-1,sysdate, sysdate, 3
		FROM (SELECT distinct wsh_location_id as location_id
				  FROM WSH_LOCATIONS loc,
							 MST_DELIVERY_DETAILS det
					WHERE det.plan_id = plan_idIn
						AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
						AND	( det.ship_from_location_id = loc.wsh_location_id
								 OR det.ship_to_location_id = loc.wsh_location_id)
						AND ( latitude is null OR longitude is null)
					UNION
					SELECT distinct wsh_location_id as location_id
					FROM FTE_LOCATION_PARAMETERS param,
							 WSH_LOCATIONS loc
					WHERE loc.wsh_location_id = param.location_id
						AND ( param.consolidation_allowed = 'Y'
								OR param.deconsolidation_allowed = 'Y'
								OR param.crossdocking_allowed = 'Y')
						AND ( loc.latitude is null OR loc.longitude is null));

		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

		--in case no exception of this type was generate delete entry in mst_exceptions table
		DELETE FROM mst_exceptions
		WHERE exception_count = 0 and exception_id = excptnId;

		COMMIT;
	END MissingLatLongCoordExcptn;




	PROCEDURE MissingDistanceDataExcptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER;
    dummyThreshold NUMBER;
		distanceEnginePresent VARCHAR(10);
  BEGIN
	 	-- Delete previous occurrences of this exception in mst_exceptions and the details table
	 	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 900;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 900;

		--Determine if distance engine is present (if it is not then no exception of this type should be generated)
		distanceEnginePresent := fnd_profile.value('MST_MILEAGE_ENGINE_AVAIL');
		IF distanceEnginePresent <> 'Y' THEN
			debug_output('No mileage engine present, no check for this exception. MST_MILEAGE_ENGINE_AVAIL=' || distanceEnginePresent);
			RETURN;
		END IF;


		--check if exception appears in mst_excep_preferences (it does not have a threshold but
    --if it is enabled there should be an entry in that table with a dummy value for threshold).
		dummyThreshold := getExceptionThreshold(900,userIdIn);
    --if no threshold found it means exception is disabled, so exit procedure
    IF dummyThreshold  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;

		--Create fresh entry for exception and keep exception_id for updates in details table
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
                                created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
												VALUES (mst_exceptions_s.nextval, plan_idIn, 900, 900, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 900;


		--find ship_from or ship_to locations whose zip-code does not appear in the distance table
		INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																			 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																			 CREATION_DATE, STATUS,
																			 delivery_detail_id, delivery_id)
		SELECT mst_exception_details_s.nextval, excptnId , plan_idIn, 900,
			     userIdIn, userIdIn,-1,sysdate, sysdate,3,
					 delivery_detail_id, delivery_id
	  FROM ( SELECT DISTINCT det.delivery_detail_id AS delivery_detail_id, da.delivery_id AS delivery_id
					 FROM MST_DELIVERY_DETAILS det,
				 				MST_DELIVERY_ASSIGNMENTS da,
				 				WSH_REGION_LOCATIONS origReg,
				 				WSH_REGION_LOCATIONS destReg
					 WHERE det.PLAN_ID = plan_idIn
						AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
						AND det.delivery_detail_id = da.delivery_detail_id (+)
						AND da.parent_delivery_detail_id is null
						AND origReg.location_id = det.ship_from_location_id
						AND destReg.location_id = det.ship_to_location_id

						--FTE_LOCATION_MILEAGES is distance table
						--key is <origin_id, destination_id,IDENTIFIER_TYPE>. Origin and destination are FK to WSH_REGIONS.
            --IDENTIFIER_TYPE can be city or state (Anuj)
		  			AND NOT EXISTS (SELECT DISTANCE
														FROM FTE_LOCATION_MILEAGES
														WHERE origReg.region_id = origin_id
															AND destReg.region_id = destination_id));


		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

		--in case no exception of this type was generated delete entry in mst_exceptions table
		DELETE FROM mst_exceptions
		WHERE exception_count = 0 and exception_id = excptnId;

		commit;
	END MissingDistanceDataExcptn;



  --Delivery lines with zero pieces, cube or weight
	PROCEDURE DL_with_zero_values (plan_idIn NUMBER, userIdIn NUMBER) IS
  	excptnId NUMBER;
    dummyThreshold NUMBER;
  BEGIN
  		--Delete previous occurrences of this exception in mst_exceptions and the details table
    	DELETE FROM mst_exception_details
  		WHERE plan_id = plan_idIn
  			AND exception_type = 219;

    	DELETE FROM mst_exceptions
  		WHERE plan_id = plan_idIn
  			AND exception_type = 219;

  		--check if exception appears in mst_excep_preferences (it does not have a threshold but
      --if it is enabled there should be an entry in that table with a dummy value for threshold).
  		dummyThreshold := getExceptionThreshold(219,userIdIn);
      --if no threshold found it means exception is disabled, so exit procedure
      IF dummyThreshold  = -999 THEN
        debug_output('exception calculation disabled');
  			RETURN;
      END IF;

  		--Create fresh entry for exception and keep exception_id for updates in details table
  		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
                                  created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
  																CREATION_DATE)
  												VALUES (mst_exceptions_s.nextval, plan_idIn, 200, 219, 0, userIdIn,
  																userIdIn,-1,sysdate, sysdate);

  		SELECT exception_id INTO excptnId
  		FROM mst_exceptions
  		WHERE plan_id = plan_idIn
  			AND exception_type = 219;


  		--check highest level delivery lines for zero values in pieces, weight and volume
  		INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
  																			 delivery_detail_id, delivery_id,
  																			 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
  																			 CREATION_DATE, STATUS)
  		SELECT mst_exception_details_s.nextval, excptnId , det.plan_id, 219,
						 det.delivery_detail_id, da.delivery_id,
             userIdIn, userIdIn,-1,sysdate, sysdate,3
  		FROM MST_DELIVERY_DETAILS det,
  				 MST_DELIVERY_ASSIGNMENTS da
  		WHERE det.plan_id = plan_idIn
				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
  			AND det.delivery_detail_id = da.delivery_detail_id (+)
  			AND da.parent_delivery_detail_id is null
  			AND (	det.NET_WEIGHT = 0 OR det.NET_WEIGHT IS NULL
  						OR det.VOLUME = 0 OR det.VOLUME IS NULL
  						OR det.REQUESTED_QUANTITY = 0);


  		--check for all items associated to delivery lines to see if they have zero cube or weight
/*
  		INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
  																			 delivery_detail_id,  delivery_id,
  																			 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
  																			 CREATION_DATE,STATUS)
  		SELECT mst_exception_details_s.nextval, excptnId , det.plan_id,219,
						 det.delivery_detail_id, da.delivery_id,
             userIdIn, userIdIn,-1,sysdate, sysdate,3
  		FROM MST_DELIVERY_DETAILS det,
  				 MTL_SYSTEM_ITEMS it,
					 MST_DELIVERY_ASSIGNMENTS da
  		WHERE det.plan_id = plan_idIn
				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
				AND det.delivery_detail_id = da.delivery_detail_id (+)
  			AND it.inventory_item_id = det.inventory_item_id
  			AND it.organization_id = det.organization_id
  			AND (	it.unit_volume = 0 OR it.unit_volume IS NULL
  						OR it.unit_weight = 0 OR it.unit_weight IS NULL);
  */

  		--update count of this exception in mst_exceptions
  		UPDATE mst_exceptions
  		SET EXCEPTION_COUNT = (	select count(*)
  														from mst_exception_details det
  														where det.exception_id = excptnId)
  		WHERE EXCEPTION_id = excptnId;

			--in case no exception of this type was generated delete entry in mst_exceptions table
			DELETE FROM mst_exceptions
			WHERE exception_count = 0 and exception_id = excptnId;

  		commit;
  END DL_with_zero_values;


	PROCEDURE DimensionViolForPieceExcptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER; -- used to get the parent exception id when inserting records in exception details.
		deliveryId NUMBER;
--		total NUMBER; -- used to count occurrences of vehicles with infinite length, height and width.
		length NUMBER;
		width NUMBER;
		height NUMBER;
		maxDimV NUMBER; --maximum dimension of (length, widht, height) of biggest vehicle
		midDimV NUMBER; --volume (length * width * height) of the biggest vehicle
		minDimV NUMBER; --minimum dimension of (length, widht, height) of biggest vehicle
		maxDimP NUMBER; --maximum dimension of (length, widht, height) for the piece
		midDimP NUMBER; --volume (length * width * height) for the piece
		minDimP NUMBER; --minimum dimension of (length, widht, height) for the piece
		vehicle_dimension_uom_code VARCHAR2(3); -- UOM of length, width and height of vehicle
		p_conv_found BOOLEAN;
		p_conv_rate NUMBER;
		thresholdPct NUMBER;

		--Allows access to the relevant pieces and their dimensions.
		CURSOR c_pieces IS
			SELECT det.delivery_detail_id,
						 IT.UNIT_LENGTH, IT.UNIT_WIDTH, IT.UNIT_HEIGHT, it.DIMENSION_UOM_CODE, it.inventory_item_id
			FROM 	MST_DELIVERY_DETAILS DET,
						MTL_SYSTEM_ITEMS IT
			WHERE IT.INVENTORY_ITEM_ID = DET.INVENTORY_ITEM_ID
				AND det.organization_id = it.organization_id
		    AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
				AND det.plan_id = plan_idIn;

	BEGIN
		--clean previous exceptions of this type
  	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 902;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 902;

		--get the threshold from mst_excep_preferences
		thresholdPct := getExceptionThreshold(902,userIdIn);
    debug_output('thresholdPct='||thresholdPct);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdPct  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;

		--find dimensions of vehicle with biggest volume
		BEGIN
			SELECT
				NVL(CONV_TO_UOM(vt.usable_length, si.dimension_uom_code, tp_dimension_uom, si.inventory_item_id),-99),
				NVL(CONV_TO_UOM(vt.usable_width, si.dimension_uom_code, tp_dimension_uom, si.inventory_item_id),-99),
				NVL(CONV_TO_UOM(vt.usable_height, si.dimension_uom_code, tp_dimension_uom, si.inventory_item_id),-99)
			INTO length, width, height
			FROM fte_vehicle_types vt,
					 mtl_system_items_b si
			WHERE vt.inventory_item_id = si.inventory_item_id
				AND vt.organization_id = si.organization_id
				AND vt.usable_length is not null
				AND vt.usable_width is not null
				AND vt.usable_height is not null
				AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 	 FROM wsh_carriers carr, wsh_carrier_services serv,
																				wsh_carrier_vehicle_types carrVeh
																	 WHERE carr.carrier_id = serv.carrier_id
																		AND serv.mode_of_transport like 'TRUCK'
																		AND carrVeh.carrier_id = carr.carrier_id)
				AND NVL(CONV_TO_UOM(si.internal_volume, si.volume_uom_code, tp_volume_uom, si.inventory_item_id),0) =
						(SELECT MAX(NVL(CONV_TO_UOM(si2.internal_volume, si2.volume_uom_code, tp_volume_uom, si2.inventory_item_id),0))
						 FROM fte_vehicle_types vt2,
								  mtl_system_items_b si2
						 WHERE vt2.inventory_item_id = si2.inventory_item_id
						   AND vt2.organization_id = si2.organization_id
							 AND vt2.usable_length is not null
							 AND vt2.usable_width is not null
							 AND vt2.usable_height is not null
							 AND vt2.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 					FROM wsh_carriers carr, wsh_carrier_services serv,
																							wsh_carrier_vehicle_types carrVeh
																				 	WHERE carr.carrier_id = serv.carrier_id
																				 		AND serv.mode_of_transport like 'TRUCK'
																						AND carrVeh.carrier_id = carr.carrier_id))
			  AND ROWNUM = 1;  --we need to pick one vehicle

	    EXCEPTION
      	WHEN NO_DATA_FOUND THEN
					length := -99;
				  width := -99;
					height := -99;
    END;


		--determine how many rows in fte_vehicle_types contain null in at least one of the dimension fields
--		SELECT COUNT(*) INTO total
--		FROM fte_vehicle_types vt,
--				mtl_system_items_b si
--		WHERE vt.inventory_item_id = si.inventory_item_id
--			AND vt.organization_id = si.organization_id
--			AND (usable_length IS NULL
--					OR usable_width IS NULL
--					OR usable_height IS NULL
--					OR dimension_uom_code IS NULL);

		--if there is at least one record in vehicle_types with null (=-99) in one of its dimensions then assume
		--that vehicle has infinite capacity. Consequently, no exception of this type will be generated
		--On the other hand, if that count is zero then we check for the exception
--		IF total > 0 THEN

    debug_output('length='||length || ', width=' || width || ', height=' || height );
    --We do not insert a row if count = 0
		IF length <> -99 AND width <> -99 AND height <> -99 THEN
			--Find max, med, and min of the three dimensions
			IF length > width AND length > height THEN
				maxDimV := length;
				SELECT GREATEST(width, height) INTO midDimV FROM dual;
				SELECT LEAST(width, height) INTO minDimV FROM dual;
			ELSE
				IF width > height THEN
					maxDimV := width;
					SELECT GREATEST(length, height) INTO midDimV FROM dual;
					SELECT LEAST(length, height) INTO minDimV FROM dual;
				ELSE
					maxDimV := height;
					SELECT GREATEST(width, length) INTO midDimV FROM dual;
					SELECT LEAST(width, length) INTO minDimV FROM dual;
				END IF;
			END IF;

      debug_output('maxDimV='||maxDimV || ', midDimV=' || midDimV || ', minDimV=' || minDimV );

	    --insert entry in mst_exceptions
			INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                            created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																  CREATION_DATE)
													VALUES (mst_exceptions_s.nextval, plan_idIn, 900, 902, 0,userIdIn,
																userIdIn,-1,sysdate, sysdate);

			SELECT exception_id INTO excptnId
			FROM mst_exceptions
			WHERE plan_id = plan_idIn
				AND exception_type = 902;

			FOR c1rec IN c_pieces LOOP

				--Find max, med, and min of the three dimensions
				IF c1rec.UNIT_LENGTH > c1rec.UNIT_WIDTH AND c1rec.UNIT_LENGTH > c1rec.UNIT_HEIGHT THEN
					maxDimP := c1rec.UNIT_LENGTH;
					SELECT GREATEST(c1rec.UNIT_WIDTH, c1rec.UNIT_HEIGHT) INTO midDimP FROM dual;
					SELECT LEAST(c1rec.UNIT_WIDTH, c1rec.UNIT_HEIGHT) INTO minDimP FROM dual;
				ELSE
					IF c1rec.UNIT_WIDTH > c1rec.UNIT_HEIGHT THEN
					maxDimP := c1rec.UNIT_WIDTH;
					SELECT GREATEST(c1rec.UNIT_LENGTH, c1rec.UNIT_HEIGHT) INTO midDimP FROM dual;
					SELECT LEAST(c1rec.UNIT_LENGTH, c1rec.UNIT_HEIGHT) INTO minDimP FROM dual;
					ELSE
						maxDimP := c1rec.UNIT_HEIGHT;
						SELECT GREATEST(c1rec.UNIT_WIDTH, c1rec.UNIT_LENGTH) INTO midDimP FROM dual;
						SELECT LEAST(c1rec.UNIT_WIDTH, c1rec.UNIT_LENGTH) INTO minDimP FROM dual;
					END IF;
				END IF;

				GET_UOM_CONVERSION_RATES(c1rec.dimension_uom_code,
																 tp_dimension_uom,
																 c1rec.inventory_item_id,
																 p_conv_found,
																 p_conv_rate);
				IF p_conv_found = true THEN
					maxDimP := maxDimP * p_conv_rate;
					minDimP := minDimP * p_conv_rate;
					midDimP := midDimP * p_conv_rate;

          IF 100*((maxDimP/maxDimV)-1)>thresholdPct
							OR  100*((minDimP/minDimV)-1)>thresholdPct
				  		OR  100*((midDimP/midDimV)-1)>thresholdPct THEN
							--obtain delivery_id
              BEGIN
  							SELECT da.delivery_id
		  					INTO deliveryId
				  			FROM mst_delivery_assignments da,
						  			 mst_delivery_details det
  							WHERE det.delivery_detail_id = da.delivery_detail_id (+)
		  								AND det.plan_id = plan_idIn
                      AND c1rec.delivery_detail_id = det.delivery_detail_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    debug_output('delivery_detail_id could not be associated to delivery_id');
                    deliveryId := NULL;
                  WHEN TOO_MANY_ROWS THEN
                    debug_output('delivery_detail_id associated to more than one delivery_id');
                    deliveryId := NULL;
              END;

              debug_output('delivery_detail_id=' || c1rec.delivery_detail_id || ', maxDimP='||maxDimP || ', midDimP=' || midDimP || ', minDimP=' || minDimP );

              --insert exceptions detected into mst_exception_details
              INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id,
                                                 exception_type, delivery_detail_id,
                                                 delivery_id, number1, number2, number3, char1,
                                                 created_by, last_updated_by, LAST_UPDATE_LOGIN,
                                                 LAST_UPDATE_DATE, CREATION_DATE, STATUS)
                                         VALUES (mst_exception_details_s.nextval, excptnId, plan_idIn,
                                                 902, c1rec.delivery_detail_id,
                                                 deliveryId, length, width, height, tp_dimension_uom,
                                                 userIdIn, userIdIn,-1,sysdate, sysdate, 3);
          END IF;
        END IF;
      END LOOP;

			--update count of this exception in mst_exceptions
			UPDATE mst_exceptions
			SET EXCEPTION_COUNT = (	select count(*)
															from mst_exception_details det
															where det.exception_id = excptnId)
			WHERE EXCEPTION_id = excptnId;

  		--in case no exception of this type was generated delete entry in mst_exceptions table
		  DELETE FROM mst_exceptions
  		WHERE exception_count = 0 and exception_id = excptnId;
		END IF;

		COMMIT;
	END DimensionViolForPieceExcptn;



	PROCEDURE WgtVolViolForPieceExcptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER; -- used to get the parent exception id when inserting records in exception details.
		maxVolumeV NUMBER; -- volume of the biggest vehicle available
		maxWeightV NUMBER; -- weight of the biggest vehicle available
		exceptionFlag BOOLEAN;
		tp_volume_uom VARCHAR2(3);
		tp_weight_uom VARCHAR2(3);
		thresholdPct NUMBER;

--	  --Obtain pieces to check
--		CURSOR c_pieces IS
--			SELECT DELIVERY_DETAIL_ID,  det.inventory_item_id,
--						net_weight, si.unit_length, si.unit_width, si.unit_height,
--						requested_quantity, si.weight_uom_code, si.dimension_uom_code
--			FROM 	MST_DELIVERY_DETAILS det,
--						MTL_SYSTEM_ITEMS si
--			WHERE det.PLAN_ID = plan_idIn
--				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
--				AND det.requested_quantity = 1
--				AND det.inventory_item_id = si.inventory_item_id
--				AND det.organization_id = si.organization_id;

	  --According to HLD (6/12/03) we need to check total weight and volume in delivery line for
    --those delivery lines which consist of a package or pallet, or contain quantity = 1.
	  --Obtain delivery lines to be checked (weight and volume converted to tp uom)
		CURSOR c_pieces (tp_vol_uom VARCHAR2, tp_wgt_uom VARCHAR2) IS
			SELECT det.delivery_detail_id,  da.delivery_id,
						NVL(det.net_weight,0) weight,
						NVL(det.volume,0) volume
			FROM 	MST_DELIVERY_DETAILS det,
						MTL_SYSTEM_ITEMS si,
						MST_DELIVERY_ASSIGNMENTS da
			WHERE det.PLAN_ID = plan_idIn
				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
				AND det.delivery_detail_id = da.delivery_detail_id (+)
				AND (det.requested_quantity = 1 OR det.container_flag = 1)
				AND det.inventory_item_id = si.inventory_item_id
				AND det.organization_id = si.organization_id;

		maxVolVehTypeId NUMBER;
		maxWgtVehTypeId NUMBER;

	BEGIN
		--clean previous exceptions of this type
  	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 903;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 903;

		--get the threshold from mst_excep_preferences
    thresholdPct := getExceptionThreshold(903,userIdIn);
    debug_output('thresholdPct='||thresholdPct);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdPct  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;

		--get tp uoms from mst_plans
		SELECT weight_uom, volume_uom
		INTO   tp_weight_uom, tp_volume_uom
		FROM mst_plans
		WHERE plan_id = plan_idIn;


		--find vehicle with the biggest volume
		SELECT MAX(NVL(CONV_TO_UOM(si.internal_volume, si.volume_uom_code, tp_volume_uom, si.inventory_item_id),0)) as volume
		INTO maxVolumeV
		FROM fte_vehicle_types vt,
				 mtl_system_items_b si
		WHERE vt.inventory_item_id = si.inventory_item_id
		  AND vt.organization_id = si.organization_id
			AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 FROM wsh_carriers carr, wsh_carrier_services serv, wsh_carrier_vehicle_types carrVeh
																 WHERE carr.carrier_id = serv.carrier_id
																  AND serv.mode_of_transport like 'TRUCK'
																	AND carrVeh.carrier_id = carr.carrier_id);


		--find vehicle with the biggest weight
		SELECT MAX(NVL(CONV_TO_UOM(si.maximum_load_weight, si.weight_uom_code,tp_weight_uom, si.inventory_item_id),0)) as load_weight
		INTO maxWeightV
		FROM fte_vehicle_types vt,
				mtl_system_items_b si
		WHERE vt.inventory_item_id = si.inventory_item_id
			AND vt.organization_id = si.organization_id
			AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 FROM wsh_carriers carr, wsh_carrier_services serv, wsh_carrier_vehicle_types carrVeh
																 WHERE carr.carrier_id = serv.carrier_id
																  AND serv.mode_of_transport like 'TRUCK'
																	AND carrVeh.carrier_id = carr.carrier_id);


		debug_output('maxVolume = ' || maxVolumeV || ' ' || tp_volume_uom || ' (veh id=' || maxVolVehTypeId || ')' );
 		debug_output('maxWeight = ' || maxWeightV || ' ' || tp_weight_uom || ' (veh id=' || maxWgtVehTypeId || ')' );

	  --insert entry in mst_exceptions
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
													VALUES (mst_exceptions_s.nextval, plan_idIn, 900, 903, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);


		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 903;

		FOR piece IN c_pieces(tp_volume_uom,tp_weight_uom) LOOP
			exceptionFlag := false;

			IF maxVolumeV > 0 THEN
				IF 100*((piece.volume/maxVolumeV)-1) > thresholdPct THEN
					exceptionFlag := true;
					--debug_output('Exception volume!!');
				END IF;
			END IF;

			IF maxWeightV > 0 THEN
				IF 100*((piece.weight/maxWeightV)-1) > thresholdPct THEN
					exceptionFlag := true;
					--debug_output('Exception weight!!');
				END IF;
			END IF;

			--if maxVolumeV = 0  or maxWeightV = 0 then we assume it is infinite and no exceptions is generated
			IF exceptionFlag = true THEN
   			debug_output('delivery_detail_id = ' || TO_CHAR(piece.delivery_detail_id) || ', volume = ' || piece.volume || ', weight = ' || piece.weight);

				--insert exception detected into mst_exception_details
				INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																					 delivery_detail_id, delivery_id,
																					 number1, number2,
																					 char1, char2,
																					 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																					 CREATION_DATE, STATUS)
																	 VALUES (mst_exception_details_s.nextval, excptnId , plan_idIn, 903,
																					 piece.delivery_detail_id, piece.delivery_id,
																					 maxWeightV, maxVolumeV,
																					 tp_weight_uom, tp_volume_uom,
																					 userIdIn, userIdIn,-1,sysdate, sysdate,3);
			END IF;
		END LOOP;

		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

  	--in case no exception of this type was generated delete entry in mst_exceptions table
    DELETE FROM mst_exceptions
    WHERE exception_count = 0 and exception_id = excptnId;

		commit;
	END WgtVolViolForPieceExcptn;


	PROCEDURE WgtVolViolForDLExcptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER; -- used to get the parent exception id when inserting records in exception details.
		maxVolumeV NUMBER; -- volume of the biggest vehicle available
		maxWeightV NUMBER; -- weight of the biggest vehicle available
		exceptionFlag BOOLEAN;
		tp_weight_uom VARCHAR2(3);
		tp_volume_uom VARCHAR2(3);
    thresholdPct NUMBER;

		CURSOR c_DL (tp_vol_uom VARCHAR2, tp_wgt_uom VARCHAR2) IS
			SELECT det.delivery_detail_id,  da.delivery_id,
						 NVL(det.net_weight,0) weight,
						 NVL(det.volume,0) volume
			FROM 	MST_DELIVERY_DETAILS det,
						MTL_SYSTEM_ITEMS si,
						MST_DELIVERY_ASSIGNMENTS da
			WHERE det.PLAN_ID = plan_idIn
				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
				AND det.delivery_detail_id = da.delivery_detail_id (+)
				AND det.requested_quantity > 1
				AND det.inventory_item_id = si.inventory_item_id
				AND det.organization_id = si.organization_id;

	BEGIN
		--clean previous exceptions of this type
  	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 904;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 904;

    --get the threshold from mst_excep_preferences
	  thresholdPct := getExceptionThreshold(904,userIdIn);
    debug_output('thresholdPct='||thresholdPct);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdPct  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;


		--get tp uoms from mst_plans
		SELECT weight_uom, volume_uom
		INTO   tp_weight_uom, tp_volume_uom
		FROM mst_plans
		WHERE plan_id = plan_idIn;


/* Debug query
 SELECT si.internal_volume as volume,  si.volume_uom_code, VEHICLE_TYPE_ID, vt.inventory_item_id , vt.organization_id
                FROM fte_vehicle_types vt,
                     mtl_system_items_b si
                WHERE vt.inventory_item_id = si.inventory_item_id
                        AND vt.organization_id = si.organization_id
                        AND vt.vehicle_type_id in (select distinct vehicle_type_id
                                                   from wsh_carriers carr, wsh_carrier_services serv, WSH_CARRIER_VEHICLE_TYPES carrVeh
                                                    where carr.carrier_id = serv.carrier_id
                                                    and serv.mode_of_transport like 'TRUCK'
                                                    and carrVeh.carrier_id = carr.carrier_id)
                        AND si.internal_volume  =
                                        (SELECT MAX(si.internal_volume) as volume
                                        FROM fte_vehicle_types vt,
                                                         mtl_system_items_b si
                                        WHERE vt.inventory_item_id = si.inventory_item_id
                                        AND vt.organization_id = si.organization_id
                                        AND vt.vehicle_type_id in (select distinct vehicle_type_id
                                                                   from wsh_carriers carr, wsh_carrier_services serv, WSH_CARRIER_VEHICLE_TYPES carrVeh
                                                                   where carr.carrier_id = serv.carrier_id
                                                                    and serv.mode_of_transport like 'TRUCK'
                                                                    and carrVeh.carrier_id = carr.carrier_id))
                        AND ROWNUM = 1;
*/

		--find vehicle with the biggest volume
		SELECT MAX(NVL(CONV_TO_UOM(si.internal_volume, si.volume_uom_code, tp_volume_uom, si.inventory_item_id),0)) as volume
		INTO maxVolumeV
		FROM fte_vehicle_types vt,
				 mtl_system_items_b si
		WHERE vt.inventory_item_id = si.inventory_item_id
		  AND vt.organization_id = si.organization_id
			AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 FROM wsh_carriers carr, wsh_carrier_services serv, wsh_carrier_vehicle_types carrVeh
																 WHERE carr.carrier_id = serv.carrier_id
																  AND serv.mode_of_transport like 'TRUCK'
																	AND carrVeh.carrier_id = carr.carrier_id);


		--find vehicle with the biggest weight
		SELECT MAX(NVL(CONV_TO_UOM(si.maximum_load_weight, si.weight_uom_code,tp_weight_uom, si.inventory_item_id),0)) as load_weight
		INTO maxWeightV
		FROM fte_vehicle_types vt,
				mtl_system_items_b si
		WHERE vt.inventory_item_id = si.inventory_item_id
			AND vt.organization_id = si.organization_id
			AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 FROM wsh_carriers carr, wsh_carrier_services serv, wsh_carrier_vehicle_types carrVeh
																 WHERE carr.carrier_id = serv.carrier_id
																  AND serv.mode_of_transport like 'TRUCK'
																	AND carrVeh.carrier_id = carr.carrier_id);


		debug_output('maxVolume = ' || maxVolumeV || ' ' || tp_volume_uom || ', maxWeight = ' || maxWeightV || ' ' || tp_weight_uom);

	  --insert entry in mst_exceptions
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
													VALUES (mst_exceptions_s.nextval, plan_idIn, 900, 904, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 904;

		FOR deliveryLine IN c_DL(tp_volume_uom, tp_weight_uom) LOOP

			exceptionFlag := false;
			IF maxVolumeV > 0 THEN
				-- debug_output('volumeDL ' || TO_CHAR(deliveryLine.volume));
				IF 100*((deliveryLine.volume/maxVolumeV)-1) > thresholdPct THEN
					exceptionFlag := true;
					-- debug_output('Exception volume!!');
				END IF;
			END IF;

			IF maxWeightV > 0 THEN
        -- debug_output('weightDL ' || TO_CHAR(deliveryLine.weight));
				IF 100*((deliveryLine.weight/maxWeightV)-1) > thresholdPct THEN
					exceptionFlag := true;
					-- debug_output('Exception weight!!');
				END IF;
			END IF;

			IF exceptionFlag = true THEN
				--insert exception detected into mst_exception_details
   			debug_output('delivery_detail_id = ' || TO_CHAR(deliveryLine.DELIVERY_DETAIL_ID) || ', volume = ' || deliveryLine.volume || ', weight = ' || deliveryLine.weight);

				INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																					 delivery_detail_id, delivery_id,
																					 number1, number2, char1, char2,
																					 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																					 CREATION_DATE, STATUS)
																	 VALUES (mst_exception_details_s.nextval, excptnId , plan_idIn, 904,
																					 deliveryLine.DELIVERY_DETAIL_ID, deliveryLine.delivery_id,
																					 maxWeightV, maxVolumeV, tp_weight_uom, tp_volume_uom,
																					 userIdIn, userIdIn,-1,sysdate, sysdate, 3);
			END IF;
		END LOOP;


		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

		--in case no exception of this type was generated delete entry in mst_exceptions table
	  DELETE FROM mst_exceptions
 		WHERE exception_count = 0 and exception_id = excptnId;

		commit;
	END WgtVolViolForDLExcptn;




	PROCEDURE WgtVolViolForFirmDelivExcptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER; -- used to get the parent exception id when inserting records in exception details.
		maxVolumeV NUMBER; -- volume of the biggest vehicle available
		maxWeightV NUMBER; -- weight of the biggest vehicle available
		exceptionFlag BOOLEAN;
		tp_weight_uom VARCHAR2(3);
		tp_volume_uom VARCHAR2(3);
    thresholdPct NUMBER;

		CURSOR c_firmDel IS
			SELECT delivery_id, NVL(gross_weight,0) weight, NVL(volume,0) volume
			FROM 	MST_DELIVERIES
			WHERE PLAN_ID = plan_idIn
				AND (PLANNED_FLAG <> 2
						 OR PRESERVE_GROUPING_FLAG <> 2
						 OR KNOWN_TE_FIRM_STATUS <> 3);
	BEGIN
		--clean previous exceptions of this type
  	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 905;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 905;

    --get the threshold from mst_excep_preferences
	  thresholdPct := getExceptionThreshold(905,userIdIn);
    debug_output('thresholdPct='||thresholdPct);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdPct  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;


		--get tp uoms from mst_plans
		SELECT weight_uom, volume_uom
		INTO   tp_weight_uom, tp_volume_uom
		FROM mst_plans
		WHERE plan_id = plan_idIn;

		--find vehicle with the biggest volume
		SELECT MAX(NVL(CONV_TO_UOM(si.internal_volume, si.volume_uom_code, tp_volume_uom, si.inventory_item_id),0)) as volume
		INTO maxVolumeV
		FROM fte_vehicle_types vt,
				 mtl_system_items_b si
		WHERE vt.inventory_item_id = si.inventory_item_id
		  AND vt.organization_id = si.organization_id
			AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 FROM wsh_carriers carr, wsh_carrier_services serv, wsh_carrier_vehicle_types carrVeh
																 WHERE carr.carrier_id = serv.carrier_id
																  AND serv.mode_of_transport like 'TRUCK'
																	AND carrVeh.carrier_id = carr.carrier_id);


		--find vehicle with the biggest weight
		SELECT MAX(NVL(CONV_TO_UOM(si.maximum_load_weight, si.weight_uom_code,tp_weight_uom, si.inventory_item_id),0)) as load_weight
		INTO maxWeightV
		FROM fte_vehicle_types vt,
				mtl_system_items_b si
		WHERE vt.inventory_item_id = si.inventory_item_id
			AND vt.organization_id = si.organization_id
			AND vt.vehicle_type_id IN (SELECT distinct vehicle_type_id
    														 FROM wsh_carriers carr, wsh_carrier_services serv, wsh_carrier_vehicle_types carrVeh
																 WHERE carr.carrier_id = serv.carrier_id
																  AND serv.mode_of_transport like 'TRUCK'
																	AND carrVeh.carrier_id = carr.carrier_id);


		debug_output('maxVolume = ' || maxVolumeV || ' ' || tp_volume_uom || ', maxWeight = ' || maxWeightV || ' ' || tp_weight_uom);

	  --insert entry in mst_exceptions
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
													VALUES (mst_exceptions_s.nextval, plan_idIn, 900, 905, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 905;

		FOR delivery IN c_firmDel LOOP
			debug_output('deliv=' || TO_CHAR(delivery.delivery_id) ||
									 ', volume=' || TO_CHAR(delivery.volume) ||
									 ', weight=' || TO_CHAR(delivery.weight));
			exceptionFlag := false;
			IF maxVolumeV > 0 THEN
				IF 100*((delivery.volume/maxVolumeV)-1) > thresholdPct THEN
					exceptionFlag := true;
					--debug_output('Exception volume!!');
				END IF;
			END IF;

			IF maxWeightV > 0 THEN
				IF 100*((delivery.weight/maxWeightV)-1) > thresholdPct THEN
					exceptionFlag := true;
					--debug_output('Exception weight!!');
				END IF;
			END IF;

			IF exceptionFlag = true THEN
				--insert exception detected into mst_exception_details
   			debug_output('delivery_id = ' || TO_CHAR(delivery.DELIVERY_ID) || ', volume = ' || delivery.volume || ', weight = ' || delivery.weight);

				INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																					 delivery_id,
																					 number1, number2, char1, char2,
																					 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																					 CREATION_DATE, STATUS)
																	 VALUES (mst_exception_details_s.nextval, excptnId , plan_idIn, 905,
																					 delivery.delivery_id,
																					 maxWeightV, maxVolumeV, tp_weight_uom, tp_volume_uom,
																					 userIdIn, userIdIn,-1,sysdate, sysdate, 3);
			END IF;
		END LOOP;


		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

		--in case no exception of this type was generated delete entry in mst_exceptions table
	  DELETE FROM mst_exceptions
 		WHERE exception_count = 0 and exception_id = excptnId;

		commit;
	END WgtVolViolForFirmDelivExcptn;



	PROCEDURE InsufficientIntransitTimeExptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER;
		requiredTransitTimeInHrs NUMBER;
		availTimeInDays NUMBER;
		distance NUMBER;

		--According to Anuj doing the join without using the source_location_code is safe. However, in the case
		--in the future we need to do that join then we will need an index on that column, since it takes a
    --considerable amount of time to perform this query adding those two conditions.
		CURSOR cursor_DL IS
			SELECT distinct delivery_id, det.delivery_detail_id,
						 det.ship_from_location_id ship_from_location_id,
						 det.ship_to_location_id ship_to_location_id,
						 latest_acceptable_date, earliest_pickup_date
			FROM MST_DELIVERY_DETAILS det,
					 MST_DELIVERY_ASSIGNMENTS da,
					 WSH_LOCATIONS loc1,
					 WSH_LOCATIONS loc2
			WHERE det.plan_id = plan_idIn
				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
				AND det.delivery_detail_id = da.delivery_detail_id (+)
    		AND parent_delivery_detail_id is null
			  AND loc1.wsh_location_id = det.ship_from_location_id
			  AND loc2.wsh_location_id = det.ship_to_location_id;

		--Auxiliary data structures to cache all the data to insert in exception_details
		TYPE delivery_id_t IS TABLE OF MST_DELIVERIES.DELIVERY_ID%TYPE INDEX BY BINARY_INTEGER;
		TYPE delivery_detail_id_t IS TABLE OF MST_DELIVERY_DETAILS.DELIVERY_DETAIL_ID%TYPE INDEX BY BINARY_INTEGER;
		TYPE distance_t IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
		TYPE time_t IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

		all_details_delivery_id delivery_id_t;
		all_details_delivery_detail_id delivery_detail_id_t;
		all_details_distance distance_t;
		all_details_time time_t;
		all_details_availTime time_t;
		j NUMBER;
    thresholdInHrs NUMBER;
		planStartDate DATE;

	BEGIN
		--Delete previous occurrences of this exception in mst_exceptions and the details table
	 	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 104;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 104;

		--get the threshold from mst_excep_preferences
		thresholdInHrs := getExceptionThreshold(104,userIdIn);
    debug_output('thresholdInHrs=' ||thresholdInHrs);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdInHrs  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;

		--current date is plan_start_date (not sysdate)
		--SELECT plan_start_date into planStartDate
		SELECT start_date into planStartDate
		FROM mst_plans
	  WHERE plan_id = plan_idIn;

		--Create fresh entry for exception and keep exception_id for updates in details table
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
												VALUES (mst_exceptions_s.nextval, plan_idIn, 100, 104, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 104;

		j := 0;
		FOR delivLine IN cursor_DL LOOP
			requiredTransitTimeInHrs := GET_MINIMUM_TRANSIT_TIME(delivLine.ship_from_location_id, delivLine.ship_to_location_id, plan_idIn);

			debug_output('delivery_detail_id=' || delivLine.delivery_detail_id || 'reqTransitTime=' || requiredTransitTimeInHrs);

			IF delivLine.earliest_pickup_date < planStartDate THEN
				IF delivLine.latest_acceptable_date < planStartDate THEN
					availTimeInDays := 0;
				ELSE
					availTimeInDays := delivLine.latest_acceptable_date - planStartDate;
				END IF;
			ELSE
				availTimeInDays := delivLine.latest_acceptable_date - delivLine.earliest_pickup_date;
			END IF;

			debug_output('availTransitTime=' || availTimeInDays*24);

			-- ****************** check for ocurrence of the exception ***********************
			IF ((availTimeInDays*24 + thresholdInHrs) < (requiredTransitTimeInHrs)) THEN
					--determine distance for this O-D pair
			  BEGIN
          --FTE_LOCATION_MILEAGES is distance table
          --key is <origin_id, destination_id,IDENTIFIER_TYPE>. Origin and destination are FK to WSH_REGIONS.
          --IDENTIFIER_TYPE can be city or state (Anuj)
          --select MIN distance because we might have more than one entry in distance table. Take the one with minimum distance for now.
          --Should we use distance_level profile to choose which one?
          SELECT MIN(lm.distance)
          INTO distance
      		FROM FTE_LOCATION_MILEAGES lm,
      				 WSH_REGION_LOCATIONS origReg,
      				 WSH_REGION_LOCATIONS destReg
      		WHERE origReg.location_id = delivLine.ship_from_location_id
      			AND destReg.location_id = delivLine.ship_to_location_id
            AND origReg.region_id = origin_id
      			AND destReg.region_id = destination_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              distance := -9999;
      	END;

  			debug_output('delivery_detail_id=' || delivLine.delivery_detail_id || ', distance=' || distance
                     || ', requiredTransitTimeInHrs='||requiredTransitTimeInHrs || ', availTimeInHrs=' ||  availTimeInDays * 24);

				all_details_delivery_id(j) := delivLine.delivery_id;
				all_details_delivery_detail_id(j) := delivLine.delivery_detail_id;
			  all_details_distance(j) := distance;
				all_details_time(j) := requiredTransitTimeInHrs;
				all_details_availTime(j) := availTimeInDays * 24;
				j := j + 1;
			END IF;
		END LOOP;

		--bulk add all exception_details
    --This is used to improve performance (using this insert inside the loop makes the procedure
    --take minutes to execute, compared to seconds in this way in test data).
		IF j > 0 THEN
			FORALL k IN all_details_delivery_id.FIRST..all_details_delivery_id.LAST
				INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																					 delivery_id, delivery_detail_id,
																					 number1, number2,
																					 number3,
																					 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																					 CREATION_DATE, STATUS)
																	 VALUES (mst_exception_details_s.nextval, excptnId , plan_IdIn, 104,
																					 all_details_delivery_id(k), all_details_delivery_detail_id(k),
																				   all_details_distance(k), all_details_time(k),
																					 all_details_availTime(k),
 																					 userIdIn, userIdIn,-1,sysdate, sysdate, 3);
		END IF;

		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

    --in case no exception of this type was generated delete entry in mst_exceptions table
	  DELETE FROM mst_exceptions
 		WHERE exception_count = 0 and exception_id = excptnId;
  	commit;

	END InsufficientIntransitTimeExptn;


	PROCEDURE PastDueOrdersExptn (plan_idIn NUMBER, userIdIn NUMBER) IS
		excptnId NUMBER;
		requiredTransitTimeInHrs NUMBER;
		availTransitTimeInHrs NUMBER;
    thresholdInHrs NUMBER;

		--highest level delivery lines that are past due.
		CURSOR cursor_past_due_orders IS
			SELECT DISTINCT da.delivery_id, det.delivery_detail_id,
						 det.ship_from_location_id, det.ship_to_location_id,
						 ((det.latest_acceptable_date - plan.start_date)*24) AS availTime
			FROM MST_DELIVERY_DETAILS det,
					 MST_DELIVERY_ASSIGNMENTS da,
					 MST_PLANS plan
			WHERE det.plan_id = plan_idIn
				AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null   --added so we consider only input data from TE
				AND det.delivery_detail_id = da.delivery_detail_id (+)
				AND da.parent_delivery_detail_id is null
				AND plan.plan_id = plan_idIn
				AND (   (det.latest_acceptable_date + thresholdInHrs/24 < plan.start_date)
				  	 OR (det.latest_pickup_date + thresholdInHrs/24 < plan.start_date) );
	BEGIN
		--Delete previous occurrences of this exception in mst_exceptions and the details table
	 	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 105;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 105;

		--get the threshold from mst_excep_preferences
		thresholdInHrs := getExceptionThreshold(105,userIdIn);
    debug_output('thresholdInHrs='||thresholdInHrs);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdInHrs  = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;


		--Create fresh entry for exception and keep exception_id for updates in details table
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
												VALUES (mst_exceptions_s.nextval, plan_idIn, 100, 105, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 105;


		--store the details in mst_exception_details
		FOR delivLine IN cursor_past_due_orders LOOP

			requiredTransitTimeInHrs := GET_MINIMUM_TRANSIT_TIME(delivLine.ship_from_location_id, delivLine.ship_to_location_id, plan_idIn);

			IF delivLine.availTime < 0 THEN
				availTransitTimeInHrs := 0;
			ELSE
				availTransitTimeInHrs := delivLine.availTime;
			END IF;

      debug_output('delivery_detail_id='||delivLine.delivery_detail_id || ', delivLine.availTime=' || delivLine.availTime ||
                   ', requiredTransitTimeInHrs=' || requiredTransitTimeInHrs);
			INSERT INTO mst_exception_details (exception_detail_id, exception_id, plan_id, exception_type,
																				 delivery_id, delivery_detail_id,
																				 number2, number3,
																				 created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																				 CREATION_DATE, STATUS)
																VALUES (mst_exception_details_s.nextval, excptnId , plan_IdIn, 105,
																				delivLine.delivery_id, delivLine.delivery_detail_id,
																				requiredTransitTimeInHrs, availTransitTimeInHrs,
																				userIdIn, userIdIn,-1,sysdate, sysdate, 3);
		END LOOP;

		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

    --in case no exception of this type was generated delete entry in mst_exceptions table
	  DELETE FROM mst_exceptions
 		WHERE exception_count = 0 and exception_id = excptnId;
  	commit;
	END PastDueOrdersExptn;


	--input:
  --  ship_from: location_id of origin
  --  ship_to: location_id of destination
	--output:
  --  minimum transit time irrespective of mode/vehicle features (in tp_uom which represents hours)
	FUNCTION GET_MINIMUM_TRANSIT_TIME(ship_from NUMBER, ship_to NUMBER, plan_idIn NUMBER) RETURN NUMBER IS
		minimumTransitTime NUMBER;
		tl_minimumTransitTime NUMBER;
		Distance NUMBER;
	  PI NUMBER;
		HighwayDistance NUMBER;
		lat_1 NUMBER;
		lat_2 NUMBER;
		lon_1 NUMBER;
		lon_2 NUMBER;

-- Anuj says FTE_LANES is not going to be populated by TE
--		CURSOR c_LTLParcel_transit_times IS
--			SELECT lane_id, carrier_id, mode_of_transportation_code, lanes.transit_time, lanes.transit_time_uom
--			FROM WSH_REGION_LOCATIONS rl1,
--					 WSH_REGION_LOCATIONS rl2,
--					 FTE_LANES lanes
--			WHERE rl1.location_id = ship_from
--      	AND rl2.location_id = ship_to
--				AND lanes.ORIGIN_ID = rl1.region_id
--			  AND lanes.DESTINATION_ID = rl2.region_id;

	BEGIN
			--check LTL and Parcel
			SELECT NVL(MIN(NVL(CONV_TO_UOM(sm.INTRANSIT_TIME,sm.TIME_UOM_CODE,tp_time_uom,0),99999)),99999)
			INTO minimumTransitTime
			FROM MTL_INTERORG_SHIP_METHODS sm,
			     WSH_REGION_LOCATIONS rl1,
		  	   WSH_REGION_LOCATIONS rl2
			WHERE rl1.location_id = ship_from
			  AND rl2.location_id = ship_to
		  	AND (   ship_from = sm.from_location_id AND ship_to = sm.to_location_id
    				OR (ship_from = sm.from_location_id AND rl2.region_id = sm.to_region_id)
	    	 		OR (rl1.region_id = sm.from_region_id AND ship_to = sm.to_location_id)
	    		 	OR (rl1.region_id = sm.from_region_id AND rl2.region_id = sm.to_region_id));

--			debug_output('minPCL_LTL_TransitTime=' || minimumTransitTime);

      --Check TL
      --FTE_LOCATION_MILEAGES is distance table
      --key is <origin_id, destination_id,IDENTIFIER_TYPE>. Origin and destination are FK to WSH_REGIONS.
      --IDENTIFIER_TYPE can be city or state (Anuj)
      --TRANSIT_TIME, TRANSIT_TIME_UOM are columns of interest here.
      BEGIN
        SELECT MIN(CONV_TO_UOM(distTable.transit_time,distTable.transit_time_uom,tp_time_uom,0))
        INTO tl_minimumTransitTime
        FROM FTE_LOCATION_MILEAGES distTable,
      			 WSH_REGION_LOCATIONS origReg,
          	 WSH_REGION_LOCATIONS destReg
        WHERE origReg.location_id = ship_from
          AND destReg.location_id = ship_to
          AND origReg.region_id = distTable.origin_id
          AND destReg.region_id = distTable.destination_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             tl_minimumTransitTime := -23453;
             debug_output('no TL transit time in FTE_LOCATION_MILEAGES');
      END;
      IF tl_minimumTransitTime IS NULL THEN
        tl_minimumTransitTime := -23453;
        debug_output('TL transit time in FTE_LOCATION_MILEAGES is null after conversion');
      END IF;


--      debug_output('origin=' || ship_from || ', destination=' || ship_to || ', tl_minimumTransitTime=' || tl_minimumTransitTime);
--			IF no entry in dist. table THEN
      IF tl_minimumTransitTime = -23453 THEN
				--we need to use lat/long method
				BEGIN
					SELECT NVL(latitude,0), NVL(longitude,0)
					INTO lat_1, lon_1
					FROM  WSH_LOCATIONS
					WHERE wsh_location_id = ship_from;
--					debug_output('ship_from=' || ship_from || ', lat=' || lat_1 || ', long=' || lon_1);
			    EXCEPTION WHEN no_data_found then
					debug_output('Error:  no entry in distance table and latitude/longitude is null for location_id = ' || ship_from);
					RETURN 99999;
				END;

				BEGIN
					SELECT NVL(latitude,0), NVL(longitude,0)
					INTO lat_2, lon_2
					FROM  WSH_LOCATIONS
					WHERE wsh_location_id = ship_to;
--					debug_output('ship_to=' || ship_to || ', lat=' || lat_2 || ', long=' || lon_2);

			    EXCEPTION WHEN no_data_found then
					debug_output('Error:  no entry in distance table and latitude/longitude is null for location_id = ' || ship_to);
					RETURN 99999;
				END;

	  	  PI := 3.1415926;
				Distance := 69.075 * 180/PI *
										(ACOS ((SIN(PI /180*lat_1) * SIN(PI /180*lat_2)) +
													 (COS(PI /180*lat_1) * COS(PI /180*lat_2) * COS(PI /180*ABS(lon_1 - lon_2)))
										));
				HighwayDistance := (1+distScaleFactor)*Distance;
				tl_minimumTransitTime := HighwayDistance / avgDrvSpeed;
--			  debug_output('HighwayDistance=' || HighwayDistance || ', Distance=' || Distance || ', distScaleFactor=' || distScaleFactor );
			END IF;

--			debug_output('min_TL_TransitTime=' || tl_minimumTransitTime);

			IF tl_minimumTransitTime < minimumTransitTime THEN
				minimumTransitTime := tl_minimumTransitTime;
			END IF;

		RETURN minimumTransitTime;
	END GET_MINIMUM_TRANSIT_TIME;


	PROCEDURE FacCalViolForPickUpExptn (plan_idIn NUMBER, userIdIn NUMBER) IS
	  thresholdInHrs NUMBER;

		--type used to cache association between location id and calendar code (getCalendar gets too expensive for this query)
		TYPE calendar_map_type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
		calendar_lookup calendar_map_type;


		CURSOR cursor_DL IS
			SELECT det.delivery_detail_id, det.ship_from_location_id, da.delivery_id,
						det.earliest_pickup_date, det.latest_pickup_date
			FROM  MST_DELIVERY_DETAILS det,
					  MST_DELIVERY_ASSIGNMENTS da
			WHERE da.delivery_detail_id = det.delivery_detail_id (+)
			 AND da.parent_delivery_detail_id is null
			 AND det.plan_id = plan_idIn
			 AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null;   --added so we consider only input data from TE


		excptnId NUMBER;
		exceptionFlag NUMBER;
		delivDetail NUMBER;
		delivId NUMBER;
		openTime DATE;
		closeTime DATE;
		shipFrom NUMBER;
		earliest_pickup_date DATE;
		latest_pickup_date DATE;
		start_open DATE;
		end_open DATE;
		seq_num NUMBER;

		local_EPD DATE;
		server_EPD DATE;
		local_LPD DATE;
		server_LPD DATE;
		numberOfCalDays NUMBER;

		calCode VARCHAR2(10);
	BEGIN
		--clean previous exceptions of this type
  	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 404;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 404;

		--get the threshold from mst_excep_preferences
    thresholdInHrs:= getExceptionThreshold(404,userIdIn);
    debug_output('thresholdInHrs='||thresholdInHrs || ', sysdate = ' || sysdate);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdInHrs = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;


	  --insert entry in mst_exceptions
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
												VALUES (mst_exceptions_s.nextval,plan_idIn, 400, 404, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 404;

		--Obtain number of extra days to consider in plan (using snapshot's logic here) (6/6/2003)
		numberOfCalDays := fnd_profile.value('MST_CALENDAR_EXTRA_DAYS');
		IF numberOfCalDays is null THEN
		  numberOfCalDays := 30;
		END IF;


		debug_output('starting cache of calendar codes');


		--cache shipping calendar code and location id association
		--Use  MST_SNAPSHOT_TASK_UTIL.getCalendar function to obtain calendar code
		    --   Input : locationId, type = 'SHIPPING' or 'RECEIVING'
		    --   Output: calendarCode
		FOR delivLine IN cursor_DL LOOP
			calendar_lookup(delivLine.ship_from_location_id) :=	MST_SNAPSHOT_TASK_UTIL.getCalendar(delivLine.ship_from_location_id, 'SHIPPING');
	  END LOOP;


		debug_output('starting deliv detail loop');

	  --loop trough delivery details
		OPEN cursor_DL;
		LOOP
			--get next row (delivery detail)
		  FETCH cursor_DL INTO delivDetail, shipFrom, delivId,
													 earliest_pickup_date, latest_pickup_date;
			EXIT WHEN cursor_DL%NOTFOUND;

			IF  earliest_pickup_date IS NOT NULL AND latest_pickup_date IS NOT NULL THEN
				-- Adjust pickup time window to local time zone for ship_from facility (using Jin's function)
				local_EPD := MST_GEOCODING.Get_local_time(shipFrom,earliest_pickup_date);
				server_EPD := earliest_pickup_date;
				local_LPD := MST_GEOCODING.Get_local_time(shipFrom,latest_pickup_date);
				server_LPD := latest_pickup_date;
/*
				debug_output('local_EPD=' || to_char(local_EPD,'MM/DD/YYYY HH24:MI:SS') || ', server_EPD=' || to_char(server_EPD,'MM/DD/YYYY HH24:MI:SS') ||
										 ', local_LPD=' || to_char(local_LPD,'MM/DD/YYYY HH24:MI:SS') || ', server_LPD=' || to_char(server_LPD,'MM/DD/YYYY HH24:MI:SS') );
*/
			END IF;

			calCode := calendar_lookup(shipFrom);

/*
			debug_output('checking delivery_detail_id=' || delivDetail ||
									 ', cal_code=' || calCode || ', earliest_pkup_date=' || to_char(earliest_pickup_date,'MM/DD/YYYY HH24:MI:SS') ||
									 ', latest_pickup_date=' || to_char(latest_pickup_date,'MM/DD/YYYY HH24:MI:SS') );
*/

			IF calCode = '-23453' THEN
				debug_output('NULL calendar for delivery_detail_id' || delivDetail);
			ELSIF earliest_pickup_date IS NULL OR latest_pickup_date IS NULL THEN
				debug_output('earliest_pickup_date IS NULL OR latest_pickup_date IS NULL');
			ELSE

				--Note: database stores dates in julian format, i.e. is a double whose unit is a day.
				--This query allows access to the expanded windows of activity of the origin facility
  		  --Query based on what is currently being used in snapshot to populate calendars flat-file (6/6/2003)
				BEGIN
					SELECT 2 INTO exceptionFlag  --SYS_NO (no exception since there is at least one overlapping shift)
					FROM DUAL
					WHERE EXISTS
						( SELECT  caldates.CALENDAR_DATE
							FROM	BOM_CALENDAR_DATES caldates,
									 	BOM_SHIFT_DATES  sdates,
									 	BOM_SHIFT_TIMES bshift,
									 	MST_PLANS plan
							WHERE plan.plan_id = plan_idIn
							 AND caldates.CALENDAR_CODE = sdates.CALENDAR_CODE (+)
							 AND caldates.CALENDAR_DATE = sdates.SHIFT_DATE (+)
							 AND sdates.CALENDAR_CODE = bshift.CALENDAR_CODE (+)
							 AND sdates.SHIFT_NUM = bshift.SHIFT_NUM (+)
							 AND caldates.SEQ_NUM  is not null
							 AND sdates.SEQ_NUM(+)  is not null
--							 AND caldates.CALENDAR_DATE between sysdate and plan.CUTOFF_DATE+numberOfCalDays
							 AND caldates.CALENDAR_DATE between local_EPD-1 and local_LPD+1
							 AND caldates.CALENDAR_CODE = calCode
--check if any shift falls inside [EPD,LPD]
					     AND ( 	( local_EPD <= (caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) AND
					          	(caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) <= local_LPD)
				           OR
											( local_EPD <= (caldates.CALENDAR_DATE+bshift.TO_TIME/86400) AND
					            (caldates.CALENDAR_DATE+bshift.TO_TIME/86400) <= local_LPD)
--check if EPD or LPD falls inside any shift
									 OR
											( (caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) <= local_EPD AND
					             local_EPD <= ( caldates.CALENDAR_DATE+bshift.TO_TIME/86400) )
									 OR
											( (caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) <= local_LPD AND
					             local_LPD <= ( caldates.CALENDAR_DATE+bshift.TO_TIME/86400) )  ) );


					EXCEPTION WHEN no_data_found then
						exceptionFlag := 1; --SYS_YES (there is an exception since there is no overlapping shift)
				END;

				IF exceptionFlag = 1 THEN
					debug_output('Exception detected, delivDet=' || delivDetail);

					--insert exception detected into mst_exception_details
					INSERT INTO mst_exception_details
											 (exception_detail_id,exception_id, plan_id, exception_type,
												delivery_detail_id, delivery_id,
												date1, date2,
												created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
												CREATION_DATE, STATUS)
								VALUES (mst_exception_details_s.nextval, excptnId , plan_idIn, 404,
												delivDetail, delivId,
												server_EPD, server_LPD,
												userIdIn, userIdIn,-1,sysdate, sysdate, 3);
				END IF;
			END IF;
		END LOOP;
		CLOSE cursor_DL;

		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

    --in case no exception of this type was generated delete entry in mst_exceptions table
	  DELETE FROM mst_exceptions
 		WHERE exception_count = 0 and exception_id = excptnId;
  	commit;

	END FacCalViolForPickUpExptn;



	PROCEDURE FacCalViolForDeliveryExptn (plan_idIn NUMBER, userIdIn NUMBER) IS
	  thresholdInHrs NUMBER;

		--type used to cache association between location id and calendar code (getCalendar gets too expensive for this query)
		TYPE calendar_map_type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
		calendar_lookup calendar_map_type;

		CURSOR cursor_DL IS
			SELECT det.delivery_detail_id, det.ship_to_location_id, da.delivery_id,
						 det.earliest_acceptable_date, det.latest_acceptable_date
			FROM  MST_DELIVERY_DETAILS det,
					  MST_DELIVERY_ASSIGNMENTS da
			WHERE da.delivery_detail_id = det.delivery_detail_id (+)
			 AND da.parent_delivery_detail_id is null
			 AND det.plan_id = plan_idIn
			 AND det.SPLIT_FROM_DELIVERY_DETAIL_ID is null;   --added so we consider only input data from TE

		excptnId NUMBER;
		exceptionFlag NUMBER;
		delivDetail NUMBER;
		delivId NUMBER;
		openTime DATE;
		closeTime DATE;
		shipTo NUMBER;
		earliest_acceptable_date DATE;
		latest_acceptable_date DATE;
		start_open DATE;
		end_open DATE;

		local_EDD DATE;
		server_EDD DATE;
		local_LDD DATE;
		server_LDD DATE;
		numberOfCalDays NUMBER;

		calCode VARCHAR2(10);
	BEGIN
		--clean previous exceptions of this type
  	DELETE FROM mst_exception_details
		WHERE plan_id = plan_idIn
			AND exception_type = 405;

  	DELETE FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 405;


		--get the threshold from mst_excep_preferences
    thresholdInHrs := getExceptionThreshold(405,userIdIn);
    debug_output('thresholdInHrs='||thresholdInHrs || ', sysdate = ' || sysdate);
    --if no threshold found it means exception is disabled, so exit procedure
    IF thresholdInHrs = -999 THEN
      debug_output('exception calculation disabled');
			RETURN;
    END IF;


	  --insert entry in mst_exceptions
		INSERT INTO mst_exceptions (exception_id, plan_id, exception_group, exception_type, exception_count,
			                          created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
																CREATION_DATE)
												VALUES (mst_exceptions_s.nextval, plan_idIn, 400, 405, 0, userIdIn,
																userIdIn,-1,sysdate, sysdate);

		SELECT exception_id INTO excptnId
		FROM mst_exceptions
		WHERE plan_id = plan_idIn
			AND exception_type = 405;


		--Obtain number of extra days to consider in plan (using snapshot's logic here) (6/6/2003)
		numberOfCalDays := fnd_profile.value('MST_CALENDAR_EXTRA_DAYS');
		IF numberOfCalDays is null THEN
		  numberOfCalDays := 30;
		END IF;


		debug_output('starting cache of calendar codes');


		--cache receiving calendar code and location id association
		FOR delivLine IN cursor_DL LOOP
			calendar_lookup(delivLine.ship_to_location_id) :=	MST_SNAPSHOT_TASK_UTIL.getCalendar(delivLine.ship_to_location_id, 'RECEIVING');
	  END LOOP;


		debug_output('starting deliv detail loop');

	  --loop trough delivery details
		OPEN cursor_DL;
		LOOP
			--get next row (delivery detail)
		  FETCH cursor_DL INTO delivDetail, shipTo, delivId,
													 earliest_acceptable_date, latest_acceptable_date;
			EXIT WHEN cursor_DL%NOTFOUND;

			IF  earliest_acceptable_date IS NOT NULL AND latest_acceptable_date IS NOT NULL THEN
				-- Adjust dropoff time window to local time zone for ship_to facility (using Jin's function)
				local_EDD := MST_GEOCODING.Get_local_time(shipTo,earliest_acceptable_date);
				server_EDD := earliest_acceptable_date;
				local_LDD := MST_GEOCODING.Get_local_time(shipTo,latest_acceptable_date);
				server_LDD := latest_acceptable_date;
/*
				debug_output('local_EDD=' || to_char(local_EDD,'MM/DD/YYYY HH24:MI:SS') || ', server_EDD=' || to_char(server_EDD,'MM/DD/YYYY HH24:MI:SS') ||
									 ', local_LDD=' || to_char(local_LDD,'MM/DD/YYYY HH24:MI:SS') || ', server_LDD=' || to_char(server_LDD,'MM/DD/YYYY HH24:MI:SS') );
*/
			END IF;

			calCode := calendar_lookup(shipTo);

/*
			debug_output('checking delivery_detail_id=' || delivDetail ||
									 ', cal_code=' || calCode || ', earliest_acceptable_date=' || to_char(earliest_acceptable_date,'MM/DD/YYYY HH24:MI:SS') ||
									 ', latest_acceptable_date=' || to_char(latest_acceptable_date,'MM/DD/YYYY HH24:MI:SS') );
*/

			IF calCode = '-23453' THEN
				debug_output('NULL calendar for delivery_detail_id' || delivDetail);
			ELSIF earliest_acceptable_date IS NULL OR latest_acceptable_date IS NULL THEN
				debug_output('earliest_acceptable_date IS NULL OR latest_acceptable_date IS NULL');
			ELSE


				--Note: database stores dates in julian format, i.e. is a double whose unit is a day.
				--This query allows access to the expanded windows of activity of the origin facility
  		  --Query based on what is currently being used in snapshot to populate calendars flat-file (6/6/2003)
				BEGIN
					SELECT 2 INTO exceptionFlag  --SYS_NO (no exception since there is at least one overlapping shift)
					FROM DUAL
					WHERE EXISTS
						( SELECT  caldates.CALENDAR_DATE
							FROM	BOM_CALENDAR_DATES caldates,
									 	BOM_SHIFT_DATES  sdates,
									 	BOM_SHIFT_TIMES bshift,
									 	MST_PLANS plan
							WHERE plan.plan_id = plan_idIn
							 AND caldates.CALENDAR_CODE = sdates.CALENDAR_CODE (+)
							 AND caldates.CALENDAR_DATE = sdates.SHIFT_DATE (+)
							 AND sdates.CALENDAR_CODE = bshift.CALENDAR_CODE (+)
							 AND sdates.SHIFT_NUM = bshift.SHIFT_NUM (+)
							 AND caldates.SEQ_NUM  is not null
							 AND sdates.SEQ_NUM(+)  is not null
--							 AND caldates.CALENDAR_DATE between sysdate and plan.CUTOFF_DATE+numberOfCalDays
							 AND caldates.CALENDAR_DATE between local_EDD-1 and local_LDD+1
							 AND caldates.CALENDAR_CODE = calCode
--check if any shift falls inside [EDD,LDD]
					     AND ( 	( local_EDD <= (caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) AND
					          	(caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) <= local_LDD)
				           OR
											( local_EDD <= (caldates.CALENDAR_DATE+bshift.TO_TIME/86400) AND
					            (caldates.CALENDAR_DATE+bshift.TO_TIME/86400) <= local_LDD)
--check if EDD or LDD falls inside any shift
									 OR
											( (caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) <= local_EDD AND
					             local_EDD <= ( caldates.CALENDAR_DATE+bshift.TO_TIME/86400) )
									 OR
											( (caldates.CALENDAR_DATE+bshift.FROM_TIME/86400) <= local_LDD AND
					             local_LDD <= ( caldates.CALENDAR_DATE+bshift.TO_TIME/86400) )  ) );

					EXCEPTION WHEN no_data_found then
						exceptionFlag := 1; --SYS_YES (there is an exception since there is no overlapping shift)
					END;

				IF exceptionFlag = 1 THEN
					debug_output('Exception detected, delivDet=' || delivDetail);
					--insert exception detected into mst_exception_details
					INSERT INTO mst_exception_details
										 (exception_detail_id, exception_id, plan_id, exception_type,
											delivery_detail_id, delivery_id,
											date1, date2,
											created_by, last_updated_by, LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
											CREATION_DATE, STATUS)
							VALUES (mst_exception_details_s.nextval, excptnId , plan_idIn, 405,
											delivDetail, delivId,
											server_EDD, server_LDD,
											userIdIn, userIdIn,-1,sysdate, sysdate, 3);
				END IF;
			END IF;
		END LOOP;
		CLOSE cursor_DL;

		--update count of this exception in mst_exceptions
		UPDATE mst_exceptions
		SET EXCEPTION_COUNT = (	select count(*)
														from mst_exception_details det
														where det.exception_id = excptnId)
		WHERE EXCEPTION_id = excptnId;

    --in case no exception of this type was generated delete entry in mst_exceptions table
	  DELETE FROM mst_exceptions
 		WHERE exception_count = 0 and exception_id = excptnId;
  	commit;

	END FacCalViolForDeliveryExptn;



	FUNCTION CONV_TO_UOM(src_value NUMBER, src_uom_code VARCHAR2,
	                     dest_uom_code VARCHAR2,
	                     inventory_item_id NUMBER DEFAULT 0) RETURN NUMBER IS
		p_conv_found BOOLEAN;
	  p_conv_rate NUMBER;
		dest_value NUMBER;
	BEGIN
		GET_UOM_CONVERSION_RATES(src_uom_code, dest_uom_code, inventory_item_id,
														 p_conv_found, p_conv_rate);

		IF p_conv_found = true THEN
			dest_value := src_value * p_conv_rate;
		ELSE
			dest_value := NULL;
		END IF;
		RETURN dest_value;
	END CONV_TO_UOM;

	/*----------------------------------------------------+
	| This procedure takes as input 2 uom codes in the    |
	| same uom class or across classes and returns a      |
	| conv_rate between them.                             |
	| If a conversion is not found then it sets           |
	| the output variable conv_found to FALSE             |
	| and returns a conv_rate of 1.                       |
	| Note: code based on                                 |
  |       MSC_X_UTIL.GET_UOM_CONVERSION_RATES           |
	+-----------------------------------------------------*/

	PROCEDURE GET_UOM_CONVERSION_RATES(p_uom_code IN VARCHAR2,
	                                   p_dest_uom_code IN VARCHAR2,
	                               		 p_inventory_item_id IN NUMBER DEFAULT 0,
		 									   						 p_conv_found OUT NOCOPY BOOLEAN,
	                                   p_conv_rate  OUT NOCOPY NUMBER) IS
	l_uom_class VARCHAR2(10);
	l_dest_uom_class VARCHAR2(10);
	BEGIN


		/*-------------------------------------------------------------+
		| Rownum = 1 is used to account for the corner case APS bug    |
		| when the same uom code points to different unit of measures  |
		| in multiple instances. This can be removed when APS makes    |
		| the fix to allow only 1 uom code in addition to unit of 	   |
		| measure in MSC_UNITS_OF_MEASURE.							   |
		+--------------------------------------------------------------*/

		/*-----------------------------------------------------+
		| Inventory Item Id = non zero is required only if 	   |
		| we are doing conversions across uom classes		       |
		+------------------------------------------------------*/

		BEGIN
			SELECT uom_class INTO l_uom_class
			FROM mtl_units_of_measure
			WHERE uom_code = p_uom_code
				AND ROWNUM = 1;

			EXCEPTION WHEN no_data_found then
			p_conv_found := FALSE;
			p_conv_rate := 1.0;
			RETURN;
		END;

		BEGIN
	    SELECT uom_class INTO l_dest_uom_class
	    FROM mtl_units_of_measure
	    WHERE uom_code = p_dest_uom_code
				AND ROWNUM = 1;

	    EXCEPTION WHEN no_data_found then
	    p_conv_found := FALSE;
	    p_conv_rate := 1.0;
	    RETURN;
		END;


		IF (l_uom_class = l_dest_uom_class) THEN
			BEGIN
				SELECT muc1.conversion_rate/muc2.conversion_rate INTO p_conv_rate
				FROM mtl_uom_conversions muc1,
		    		 mtl_uom_conversions muc2
				WHERE muc1.inventory_item_id = 0
					AND muc2.inventory_item_id = 0
					AND muc1.uom_class = muc2.uom_class
					AND muc1.uom_class = l_uom_class
					AND muc1.uom_code = p_uom_code
					AND muc2.uom_code = p_dest_uom_code
					AND ROWNUM = 1;

				EXCEPTION when NO_DATA_FOUND then
				p_conv_found := FALSE;
				p_conv_rate := 1.0;
				return;
			END;

		ELSE
			BEGIN
	    	SELECT muc.conversion_rate INTO p_conv_rate
	      FROM mtl_uom_conversions_view muc
	      WHERE muc.inventory_item_id = p_inventory_item_id
	      	AND muc.primary_uom_code = p_uom_code
	      	AND muc.uom_code = p_dest_uom_code
					AND rownum = 1;

				EXCEPTION when NO_DATA_FOUND then
				--The following alternative was taken from Anuj's snapshot file (jansanch)
			  BEGIN
   				SELECT muc.conversion_rate INTO p_conv_rate
	     		FROM mtl_uom_conversions_view muc
		     	WHERE muc.inventory_item_id = p_inventory_item_id
	      		AND muc.primary_uom_code = p_dest_uom_code
  	    		AND muc.uom_code = p_uom_code
						AND rownum = 1;
					EXCEPTION when NO_DATA_FOUND then
	      		p_conv_found := FALSE;
		     		p_conv_rate := 1.0;
	 	    		return;
				END;
			END;
		END IF;

		p_conv_found := TRUE;

	END;


	PROCEDURE testConv(source varchar2, dest varchar2) IS
		p_conv_found BOOLEAN;
		p_conv_rate NUMBER;
	BEGIN

			GET_UOM_CONVERSION_RATES(source,dest,0,p_conv_found,p_conv_rate);
			IF p_conv_found = TRUE THEN
				debug_output('found, conv_rate=' || TO_CHAR(p_conv_rate));
			ELSE
				debug_output('not found');
			END IF;
	END testConv;

  --returns thresold (first looks for user value, then for global value if no user value is defined)
  --if no entry appears in mst_excep_preferences returns -999 (this is equivalent to a disabled exception)
  FUNCTION getExceptionThreshold (exceptionType NUMBER, userIdIn NUMBER) RETURN NUMBER IS
	  total NUMBER;
    threshold NUMBER;
	BEGIN
		--get the threshold from mst_excep_preferences
   BEGIN
     SELECT nvl(threshold_value,0) INTO threshold
     FROM mst_excep_preferences
     WHERE exception_type = exceptionType
       and user_id = -9999
       and ROWNUM = 1;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     --exception is disabled
              threshold := -999;
   END;
    RETURN threshold;
	END getExceptionThreshold;


  PROCEDURE initializeGlobalVariables(plan_idIn IN NUMBER, user_idIn IN NUMBER) IS
		p_conv_found BOOLEAN;
	  convRateTime NUMBER;
    convRateDistance NUMBER;
    lAvgHwayDist NUMBER;
    lDisConstant NUMBER;
    lDistanceUomCode VARCHAR2(3);
    lTimeUomCode VARCHAR2(3);
  BEGIN
		tp_plan_id := plan_idIn;

    --get TP UOMs
		SELECT p.TIME_UOM, p.DISTANCE_UOM, p.dimension_uom, p.volume_uom
    INTO tp_time_uom, tp_distance_uom, tp_dimension_uom, tp_volume_uom
    FROM MST_PLANS p
		WHERE plan_id = plan_idIn;
    debug_output('tp_distance_uom=' || tp_distance_uom || ', tp_time_uom=' || tp_time_uom);
    debug_output('tp_dimension_uom=' || tp_dimension_uom || ', tp_volume_uom=' || tp_volume_uom);

    --Code adapted from snapshot "/mstdev/mst/11.5/src/snap/mstsplno.ppc" to obtain avg_driving_speed and distance_scale_factor
    BEGIN
      SELECT  nvl(wgp.AVG_HWAY_SPEED,'-99') , nvl(wgp.TL_HWAY_DIS_EMP_CONSTANT,'-99'), wgp.GU_DISTANCE_UOM, wgp.TIME_UOM
      INTO lAvgHwayDist, lDisConstant, lDistanceUomCode, lTimeUomCode
      FROM MST_PARAMETERS mgp,  WSH_GLOBAL_PARAMETERS wgp, MST_PARAMETERS mup
      WHERE mgp.user_id  = -9999
        and mup.user_id = user_idIn
        and rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      BEGIN
        debug_output('first select gave no results in parameters query');
        SELECT nvl(wgp.AVG_HWAY_SPEED,'-99'), nvl(wgp.TL_HWAY_DIS_EMP_CONSTANT,'-99'), wgp.GU_DISTANCE_UOM, wgp.TIME_UOM
        INTO lAvgHwayDist, lDisConstant, lDistanceUomCode, lTimeUomCode
        FROM MST_PARAMETERS mgp, WSH_GLOBAL_PARAMETERS wgp
        WHERE mgp.user_id  = -9999
          and rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          debug_output('second select gave no results in parameters query, assuming defaults');
          lAvgHwayDist := 59;
          lDisConstant := 0;
          lTimeUomCode := tp_time_uom;
          lDistanceUomCode := tp_distance_uom;
      END;
    END;

    debug_output('AvgHwayDist= ' || lAvgHwayDist || ',lDistanceUomCode=<' || lDistanceUomCode || '>,lTimeUomCode=' || lTimeUomCode || ', lDisConstant=' || lDisConstant);
    IF lDistanceUomCode <> tp_distance_uom AND lDistanceUomCode <> '-99' THEN
      GET_UOM_CONVERSION_RATES(lDistanceUomCode, tp_distance_uom, 0, p_conv_found, convRateDistance);
      IF p_conv_found = false THEN
        convRateDistance := 1;
      END IF;
    ELSE
      convRateDistance := 1;
    END IF;
    debug_output('convRateDistance=' || convRateDistance);

    IF lTimeUomCode <> tp_time_uom AND lTimeUomCode <> '-99' THEN
      GET_UOM_CONVERSION_RATES(lTimeUomCode, tp_time_uom, 0, p_conv_found, convRateTime);
      IF p_conv_found = false THEN
        convRateTime := 1;
      END IF;
    ELSE
      convRateTime := 1;
    END IF;
    debug_output('convRateTime=' || convRateTime);

    --set global variables for later use
    avgDrvSpeed := (lAvgHwayDist * convRateDistance)/convRateTime;
    distScaleFactor := lDisConstant;

 		debug_output('avgDrvSpeed = ' || avgDrvSpeed);
		debug_output('distScaleFactor = ' || distScaleFactor);
    debug_output('----');
  END initializeGlobalVariables;

	--Run all the exceptions in the audit report (each exception checks if it is enabled or not)
	PROCEDURE runAuditReport(errbuf OUT NOCOPY VARCHAR2,
												   retcode OUT NOCOPY NUMBER,
													 plan_idIn IN NUMBER,
													 snapshotIsCaller IN NUMBER DEFAULT 2) IS
		planRows NUMBER;
    user_id NUMBER(15);

		mst_state NUMBER;
		mst_program NUMBER;
		mst_request_id NUMBER;
	  own_request_id NUMBER;
	BEGIN
		msg_seq_num  := 0;

		SELECT count(*) into planRows
		FROM mst_plans
	  WHERE plan_id = plan_idIn;

		IF planRows <> 1 THEN
			SELECT 'no entry or too many entries in mst plans for plan ' || TO_CHAR(plan_idIn)
			INTO errbuf
			FROM dual;
			retcode := 2;
			RETURN;
		END IF;


    --Obtain data from mst_plans
    SELECT created_by, state, program, request_id
		INTO	user_id, mst_state, mst_program, mst_request_id
    FROM mst_plans
    WHERE plan_id = plan_idIn;

		debug_output('MST_PLANS.state=' || mst_state);
		debug_output('MST_PLANS.program=' || mst_program);
		debug_output('MST_PLANS.request_id=' || mst_request_id);
		debug_output('snapshotIsCaller=' || snapshotIsCaller);

		--Determine if audit report can be run. Need to check if another instance of engine/snapshot/audit is running
		--Obtain own request id
		own_request_id := fnd_profile.value('CONC_REQUEST_ID');
		IF own_request_id IS NULL THEN
			debug_output('No CONC_REQUEST_ID present');
		END IF;
		debug_output('own_request_id=' || own_request_id);


	IF mst_request_id <> own_request_id THEN
		--Prevent audit report from running when data has not been snapshoted
		IF mst_state IS NULL THEN
			debug_output('Data needs to be snapshoted before running audit report');
			SELECT 'Data needs to be snapshoted before running audit report'
			INTO errbuf
			FROM dual;
			retcode := 3;
			RETURN;
		END IF;
	ELSE
		debug_output('mst_request_id == owd_request_id');
	END IF;

/*
		IF mst_request_id <> own_request_id THEN
			--IF state <> snapshot done AND state <> optimization done THEN exit
			IF mst_state <> 1 AND mst_state <> 2 THEN
				debug_output('Audit report cannot be run in current state, state = ' || TO_CHAR(mst_state));
				SELECT 'Audit report cannot be run in current state, state = ' || TO_CHAR(mst_state)
				INTO errbuf
				FROM dual;
				retcode := 3;
				RETURN;
			END IF;
		ELSE
			debug_output('mst_request_id == owd_request_id');
		END IF;
*/

		--update MST_PLANS signaling successful start of audit report
		UPDATE MST_PLANS
		SET state=4, program=8, request_id = own_request_id
	  WHERE plan_id = plan_idIn;
		COMMIT;

		debug_output('Entering initializeGlobalVariables');
    initializeGlobalVariables(plan_idIn, user_id);
		debug_output('Done with initializeGlobalVariables');

    debug_output('----');

		debug_output('Entering MissingLatLongCoordExcptn');
		MissingLatLongCoordExcptn(plan_idIn, user_id);
		debug_output('Done with MissingLatLongCoordExcptn');

    debug_output('----');

		debug_output('Entering MissingDistanceDataExcptn');
		MissingDistanceDataExcptn(plan_idIn, user_id);
		debug_output('Done with MissingDistanceDataExcptn');

    debug_output('----');

		debug_output('Entering DimensionViolForPieceExcptn');
		DimensionViolForPieceExcptn(plan_idIn,user_id);
		debug_output('Done with DimensionViolForPieceExcptn');

    debug_output('----');

		debug_output('Entering DL_with_zero_values');
		DL_with_zero_values(plan_idIn,user_id);
		debug_output('Done with DL_with_zero_values');

    debug_output('----');

		debug_output('Entering WgtVolViolForPieceExcptn');
		WgtVolViolForPieceExcptn(plan_idIn,user_id);
		debug_output('Done with WgtVolViolForPieceExcptn');

    debug_output('----');

		debug_output('Entering WgtVolViolForDLExcptn');
		WgtVolViolForDLExcptn(plan_idIn,user_id);
		debug_output('Done with WgtVolViolForDLExcptn');

    debug_output('----');

		debug_output('Entering WgtVolViolForFirmDelivExcptn');
		WgtVolViolForFirmDelivExcptn(plan_idIn,user_id);
		debug_output('Done with WgtVolViolForFirmDelivExcptn');

    debug_output('----');

		debug_output('Entering InsufficientIntransitTimeExptn');
		InsufficientIntransitTimeExptn(plan_idIn,user_id);
		debug_output('Done with InsufficientIntransitTimeExptn');

    debug_output('----');

		debug_output('Entering PastDueOrdersExptn');
		PastDueOrdersExptn(plan_idIn,user_id);
		debug_output('Done with PastDueOrdersExptn');

    debug_output('----');

		debug_output('Entering FacCalViolForPickUpExptn');
		FacCalViolForPickUpExptn(plan_idIn,user_id);
		debug_output('Done with FacCalViolForPickUpExptn');

    debug_output('----');

		debug_output('Entering FacCalViolForDeliveryExptn');
		FacCalViolForDeliveryExptn(plan_idIn,user_id);
		debug_output('Done with FacCalViolForDeliveryExptn');

    commit;

		--if snapshotIsCaller == 1 then update state to 1
		IF snapshotIsCaller = 1 THEN
			mst_state := 1;
		END IF;

		--update MST_PLANS signaling successful end of audit report
		UPDATE MST_PLANS
		SET state=mst_state, program=NULL
	  WHERE plan_id = plan_idIn;
		debug_output('Update MST_PLANS.program = NULL');
		debug_output('Update MST_PLANS.state = ' || mst_state);
		debug_output('Audit report finished successfully, exiting now...');
    commit;

		errbuf := NULL;
		retcode := 0;
	END runAuditReport;


	PROCEDURE debug_output(p_str in varchar2) IS
   var NUMBER;
  BEGIN
--    fnd_file.put_line( FND_FILE.LOG, p_str);
--dbms_output.put_line(p_str);

/*
Use following to create table for debug:
	create table mst_audit_rep_excp_debug(pk number, plan_id number,message_seq_num number, date_message date,message varchar2(255));
	create sequence mst_audit_rep_excp_debug_s;
Then uncomment code to insert messages to that table
*/

/*
	  insert into mst_audit_rep_excp_debug(pk, plan_id,message_seq_num, date_message,message)
					 values (mst_audit_rep_excp_debug_s.nextval, tp_plan_id, msg_seq_num, sysdate, p_str);
	  msg_seq_num := msg_seq_num + 1;
		commit;
*/
	  var := 0;
  END debug_output;

END MST_AUDIT_REP_EXCP;

/
