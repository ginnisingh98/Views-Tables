--------------------------------------------------------
--  DDL for Package Body FTE_FREIGHT_RATING_DLVY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_FREIGHT_RATING_DLVY_GRP" AS
/*$Header: FTEFRDRB.pls 120.13 2005/10/25 14:53:09 susurend ship $ */
--
-- Private Package level Variables
--
   G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_FREIGHT_RATING_DLVY_GRP';

   G_RC_SUCCESS 		CONSTANT NUMBER := 0;
   G_RC_ERROR 			CONSTANT NUMBER := 1;
   G_RC_REPRICE_NOT_REQUIRED 	CONSTANT NUMBER := 2;
   G_RC_NOT_RATE_FREIGHT_TERM 	CONSTANT NUMBER := 3;
   G_RC_NOT_RATE_MANIFESTING 	CONSTANT NUMBER := 4;

   g_pricing_not_required	EXCEPTION;
   g_finished_success		EXCEPTION;
   g_finished_warning		EXCEPTION;

--
   TYPE dlv_leg_info_rec IS RECORD  --  Make these columns as %TYPE
   (
          delivery_leg_id                 NUMBER,
          delivery_id                     NUMBER,
          sequence_number                 NUMBER,
          pick_up_stop_id                 NUMBER,
          drop_off_stop_id                NUMBER,
          reprice_required                VARCHAR2(1),
          status_code                     VARCHAR2(30),
	  parent_delivery_leg_id	  NUMBER --MDC
   );
--
   TYPE dlv_leg_tab IS TABLE OF dlv_leg_info_rec INDEX BY BINARY_INTEGER;
--
   TYPE trip_info_rec IS RECORD
   (
          trip_id                         NUMBER,
          name                            VARCHAR2(30),
          planned_flag                    VARCHAR2(1),
          status_code                     VARCHAR2(2),
          carrier_id                      NUMBER,
          ship_method_code                VARCHAR2(30),
          service_level                   VARCHAR2(30),
          mode_of_transport               VARCHAR2(30),
          consolidation_allowed           VARCHAR2(1),
          lane_id                         NUMBER,
          schedule_id                     NUMBER,
          load_tender_status              wsh_trips.load_tender_status%TYPE
    );
--
   TYPE trip_info_tab IS TABLE OF trip_info_rec INDEX BY BINARY_INTEGER;
--
   TYPE dleg_trip_rec IS RECORD
   (
          delivery_leg_id                NUMBER,
          trip_id                        NUMBER
   );
--
   TYPE dleg_trip_tab IS TABLE OF dleg_trip_rec INDEX BY BINARY_INTEGER;
--
   TYPE lane_match_rec IS RECORD
   (
         trip_id                          NUMBER,
         delivery_leg_id                  NUMBER,
         delivery_id                      NUMBER,
         lane_id                          NUMBER,
         ship_method_code                 VARCHAR2(30),
         ship_method_name                 VARCHAR2(240),
         carrier_id                       NUMBER,
         service_level                    VARCHAR2(30),
         mode_of_transport                VARCHAR2(30),
         new_match                        VARCHAR2(1),
	 transit_time			  NUMBER,
	 transit_time_uom		  VARCHAR2(30)
    );
--
   TYPE lane_match_tab IS TABLE OF lane_match_rec INDEX BY BINARY_INTEGER;
--
--
  -- Package private cursors
   CURSOR c_delivery(c_dlv NUMBER)
   IS
   SELECT * FROM wsh_new_deliveries
   WHERE delivery_id = c_dlv;
--
   CURSOR c_count_delivery_details(c_delivery_id NUMBER)
   IS
   SELECT count(delivery_detail_id) FROM wsh_delivery_assignments
   WHERE (delivery_id = c_delivery_id OR parent_delivery_id= c_delivery_id);

   CURSOR c_count_delivery_details2(c_trip_id NUMBER)
   IS
   SELECT count(delivery_detail_id) FROM wsh_delivery_assignments
   WHERE delivery_id in
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
   CURSOR c_check_del_freight_term(c_delivery_id NUMBER)
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
   AND    wd.delivery_id    = c_delivery_id;

   -- count the number of deliveries which should not be rated due to freight term
   CURSOR c_check_del_freight_term2(c_trip_id NUMBER)
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
  CURSOR c_check_del_manifesting(c_delivery_id NUMBER)
  IS
  SELECT count(a.delivery_id)
  FROM   wsh_new_deliveries a,
	 mtl_parameters b,
	 wsh_carriers c
  WHERE  a.organization_id = b.organization_id
  AND    a.carrier_id = c.carrier_id
  AND    c.manifesting_enabled_flag = 'Y'
  AND    b.carrier_manifesting_flag = 'Y'
  AND    a.delivery_id = c_delivery_id;

   -- count the number of deliveries which should not be rated due to manifesting
  CURSOR c_check_del_manifesting2(c_trip_id NUMBER)
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

  CURSOR c_get_carrier_manifest_enabled(c_carrier_id NUMBER)
  IS
  SELECT manifesting_enabled_flag
  FROM   wsh_carriers
  WHERE  carrier_id = c_carrier_id;

  CURSOR c_get_del_manifest_enabled(c_delivery_id NUMBER)
  IS
  SELECT b.carrier_manifesting_flag
  FROM   wsh_new_deliveries a,
	 mtl_parameters b
  WHERE  a.organization_id = b.organization_id
  AND    a.delivery_id = c_delivery_id;
--
   CURSOR  c_carrier_services(c_shp_mthd_cd VARCHAR2)
   IS
   SELECT ship_method_code,carrier_id, service_level, mode_of_transport, ship_method_meaning
   FROM   wsh_carrier_services
   WHERE  ship_method_code = c_shp_mthd_cd;

   CURSOR c_get_ship_method (c_carrier_id VARCHAR2, c_mode_of_trans VARCHAR2, c_service_level VARCHAR2) IS
   SELECT ship_method_code, ship_method_meaning
   FROM   wsh_carrier_services
   WHERE carrier_id = c_carrier_id
     AND service_level = c_service_level
     AND mode_of_transport = c_mode_of_trans;

   CURSOR c_get_ship_method_code (c_carrier_id VARCHAR2, c_mode_of_trans VARCHAR2, c_service_level VARCHAR2, c_org_id NUMBER) IS
   SELECT a.ship_method_code, a.ship_method_meaning
   FROM wsh_carrier_services a, wsh_org_carrier_services b
   WHERE a.carrier_service_id = b.carrier_service_id
     AND b.organization_id = c_org_id
     AND b.enabled_flag = 'Y'
     AND a.enabled_flag = 'Y'
     AND a.mode_of_transport = c_mode_of_trans
     AND a.service_level = c_service_level
     AND a.carrier_id = c_carrier_id;

   CURSOR c_get_generic_carrier_flag (c_carrier_id VARCHAR2) IS
   SELECT generic_flag
   FROM   wsh_carriers
   WHERE carrier_id = c_carrier_id;

   CURSOR c_get_carrier_name(c_carrier_id NUMBER)
   IS
   SELECT hz.party_name carrier_name
   FROM hz_parties hz, wsh_carriers wc
   WHERE hz.party_id = wc.carrier_id
     AND nvl(wc.generic_flag,'N') = 'N'
     AND wc.carrier_id = c_carrier_id;

   CURSOR c_get_mode_of_transport(c_mode_of_transport_code VARCHAR2)
   IS
   SELECT meaning mode_of_transport
   FROM fnd_lookup_values_vl
   WHERE lookup_type = 'WSH_MODE_OF_TRANSPORT'
     AND nvl(start_date_active, sysdate) <= sysdate
     AND nvl(end_date_active, sysdate) >= sysdate
     AND enabled_flag='Y'
     AND lookup_code = c_mode_of_transport_code;

   CURSOR c_get_service_level(c_service_type_code VARCHAR2)
   IS
   SELECT meaning service_type
   FROM fnd_lookup_values_vl
   WHERE lookup_type = 'WSH_SERVICE_LEVELS'
     AND nvl(start_date_active, sysdate) <= sysdate
     AND nvl(end_date_active, sysdate) >= sysdate
     AND enabled_flag='Y'
     AND lookup_code = c_service_type_code;

--
   CURSOR  c_dlv_legs(c_dlv_id NUMBER)
   IS
   SELECT delivery_leg_id,
          delivery_id,
          sequence_number,
          pick_up_stop_id,
          drop_off_stop_id,
          reprice_required,
          status_code,
	  parent_delivery_leg_id
   FROM    wsh_delivery_legs
   WHERE   delivery_id = c_dlv_id;
--
   CURSOR c_leg_trip_det(c_delivery_leg_id NUMBER)
   IS
   SELECT wt.trip_id,
          wt.name,
          wt.planned_flag,
          wt.status_code,
          wt.carrier_id,
          wt.ship_method_code,
          wt.service_level,
          wt.mode_of_transport,
          wt.consolidation_allowed,
          wt.lane_id,
          wt.schedule_id,
          wt.load_tender_status
   FROM   wsh_trips wt,
          wsh_delivery_legs  wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   WHERE  wts1.stop_id = wdl.pick_up_stop_id
   AND    wts2.stop_id = wdl.drop_off_stop_id
   AND    wts1.trip_id = wt.trip_id
   AND    wts2.trip_id = wt.trip_id
   AND    wdl.delivery_leg_id = c_delivery_leg_id;
--
   CURSOR c_trip_info(c_trip_id NUMBER)
   IS
   SELECT wt.trip_id,
          wt.name,
          wt.planned_flag,
          wt.status_code,
          wt.carrier_id,
          wt.ship_method_code,
          wt.service_level,
          wt.mode_of_transport,
          wt.consolidation_allowed,
          wt.lane_id,
          wt.schedule_id,
          wt.load_tender_status
   FROM   wsh_trips wt
   WHERE  wt.trip_id = c_trip_id;

   CURSOR c_trip_first_stop(c_trip_id NUMBER)
   IS
   SELECT stop_location_id, planned_departure_date
   FROM    wsh_trip_stops
   WHERE  trip_id = c_trip_id
   AND	  stop_sequence_number =
   (SELECT min(stop_sequence_number)
    FROM wsh_trip_stops
    WHERE trip_id = c_trip_id);

   CURSOR c_trip_last_stop(c_trip_id NUMBER)
   IS
   SELECT stop_location_id, planned_arrival_date
   FROM    wsh_trip_stops
   WHERE  trip_id = c_trip_id
   AND	  stop_sequence_number =
   (SELECT max(stop_sequence_number)
    FROM wsh_trip_stops
    WHERE trip_id = c_trip_id);
--
   CURSOR c_cnt_trip_legs(c_trip_id NUMBER)
   IS
   SELECT count(wdl.delivery_leg_id)
   FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   WHERE wts1.trip_id = c_trip_id
   AND   wts2.trip_id = c_trip_id
   AND   wts1.stop_id = wdl.pick_up_stop_id
   AND   wts2.stop_id = wdl.drop_off_stop_id;

   CURSOR c_count_reprice_reqd(c_trip_id IN NUMBER) IS
   Select count(*)
   from   wsh_delivery_legs wdl, wsh_trip_stops wts1, wsh_trip_stops wts2,wsh_trips wt
   where  wdl.pick_up_stop_id    = wts1.stop_id
   and    wdl.drop_off_stop_id   = wts2.stop_id
   and    wdl.reprice_required = 'Y'
   and    wts1.trip_id           = wt.trip_id
   and    wts2.trip_id           = wt.trip_id
   and    wt.trip_id             = c_trip_id;
--
   CURSOR c_trip_legs(c_trip_id NUMBER)
   IS
   SELECT wdl.delivery_leg_id,
          wdl.delivery_id,
          wdl.sequence_number,
          wdl.pick_up_stop_id,
          wdl.drop_off_stop_id,
          wdl.reprice_required,
          wdl.status_code,
	  wdl.parent_delivery_leg_id
   FROM   wsh_delivery_legs wdl,
          wsh_trip_stops wts1,
          wsh_trip_stops wts2
   WHERE wts1.trip_id = c_trip_id
   AND   wts2.trip_id = c_trip_id
   AND   wts1.stop_id = wdl.pick_up_stop_id
   AND   wts2.stop_id = wdl.drop_off_stop_id;

   CURSOR c_get_dleg_id (c_delivery_id NUMBER)
   IS
   SELECT delivery_leg_id
   FROM wsh_delivery_legs
   WHERE delivery_id = c_delivery_id;
--
  -- Package global variables
--
    -- holds the delivery information and is compatible with delivery action group api
    -- is indexed by delivery_id
   g_dlv_tab             WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
--
     -- holds delivery leg information, indexed on delivery_leg_id
   g_dlv_leg_tab         dlv_leg_tab;
--
     -- holds trip information, indexed on trip_id
   g_trip_info_tab       trip_info_tab;
--
     -- holds association of trip and delivery_leg
   g_dleg_trip_tab       dleg_trip_tab;
--

      g_ship_date		DATE;
      g_arrival_date		DATE;
--
   --method declarations
--



PROCEDURE Get_Trip_Mode(
	p_trip_id IN NUMBER,
	p_dleg_id IN NUMBER,
	x_trip_id IN OUT NOCOPY NUMBER,
	x_mode_of_transport IN OUT NOCOPY VARCHAR2,
	x_return_status       OUT NOCOPY     VARCHAR2 )
IS


     l_trip_info trip_info_rec;
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'Get_Trip_Mode';

  BEGIN

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
       FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);


	IF(p_trip_id IS NOT NULL)
	THEN

		OPEN c_trip_info(p_trip_id);
		FETCH c_trip_info INTO l_trip_info;
		CLOSE c_trip_info;

	ELSIF(p_dleg_id IS NOT NULL)
	THEN

		OPEN c_leg_trip_det(p_dleg_id);
		FETCH c_leg_trip_det INTO l_trip_info;
		CLOSE c_leg_trip_det;

	END IF;

	x_trip_id:=l_trip_info.trip_id;
	x_mode_of_transport:=l_trip_info.mode_of_transport;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


END Get_Trip_Mode;



--
    PROCEDURE api_post_call
		(
		  p_api_name           IN     VARCHAR2,
		  p_api_return_status  IN     VARCHAR2,
		  p_message_name       IN     VARCHAR2,
		  p_trip_id            IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_id        IN     VARCHAR2 DEFAULT NULL,
		  p_delivery_leg_id    IN     VARCHAR2 DEFAULT NULL,
		  x_number_of_errors   IN OUT NOCOPY  NUMBER,
		  x_number_of_warnings IN OUT NOCOPY  NUMBER,
		  x_return_status      OUT NOCOPY     VARCHAR2
		)
    IS
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'API_POST_CALL';
      l_msg_type VARCHAR2(1);
    BEGIN
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;
            x_return_status := p_api_return_status;  -- default
	    IF p_api_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	    THEN
	      IF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		l_msg_type := 'W';
		x_number_of_warnings := x_number_of_warnings + 1;
	      ELSIF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
		l_msg_type := 'E';
		x_number_of_errors := x_number_of_errors + 1;
	      ELSIF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR THEN
		l_msg_type := 'U';
		x_number_of_errors := x_number_of_errors + 1;
	      END IF;
              IF (p_message_name IS NOT NULL
		  AND p_api_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
			FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> p_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> p_message_name,
			  p_msg_type		=> l_msg_type,
			  p_trip_id		=> p_trip_id,
			  p_delivery_id		=> p_delivery_id,
			  p_delivery_leg_id	=> p_delivery_leg_id);
               END IF;
	    End IF;
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
    EXCEPTION
	WHEN OTHERS THEN
            wsh_util_core.default_handler(G_PKG_NAME||'.API_POST_CALL');
	    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END api_post_call;
--
--
  PROCEDURE load_dlv_rec          (p_dlv_rec            IN c_delivery%ROWTYPE,
                                   x_dlv_rec            OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type)
  IS
  BEGIN
--
      x_dlv_rec.DELIVERY_ID := p_dlv_rec.DELIVERY_ID;
      x_dlv_rec.NAME := p_dlv_rec.NAME;
      x_dlv_rec.PLANNED_FLAG := p_dlv_rec.PLANNED_FLAG;
      x_dlv_rec.STATUS_CODE := p_dlv_rec.STATUS_CODE;
      x_dlv_rec.DELIVERY_TYPE := p_dlv_rec.DELIVERY_TYPE;
      x_dlv_rec.LOADING_SEQUENCE := p_dlv_rec.LOADING_SEQUENCE;
      x_dlv_rec.LOADING_ORDER_FLAG := p_dlv_rec.LOADING_ORDER_FLAG;
      x_dlv_rec.INITIAL_PICKUP_DATE := p_dlv_rec.INITIAL_PICKUP_DATE;
      x_dlv_rec.INITIAL_PICKUP_LOCATION_ID := p_dlv_rec.INITIAL_PICKUP_LOCATION_ID;
      x_dlv_rec.ORGANIZATION_ID := p_dlv_rec.ORGANIZATION_ID;
      x_dlv_rec.ULTIMATE_DROPOFF_LOCATION_ID := p_dlv_rec.ULTIMATE_DROPOFF_LOCATION_ID;
      x_dlv_rec.ULTIMATE_DROPOFF_DATE := p_dlv_rec.ULTIMATE_DROPOFF_DATE;
      x_dlv_rec.CUSTOMER_ID := p_dlv_rec.CUSTOMER_ID;
      x_dlv_rec.INTMED_SHIP_TO_LOCATION_ID := p_dlv_rec.INTMED_SHIP_TO_LOCATION_ID;
      x_dlv_rec.POOLED_SHIP_TO_LOCATION_ID := p_dlv_rec.POOLED_SHIP_TO_LOCATION_ID;
      x_dlv_rec.CARRIER_ID := p_dlv_rec.CARRIER_ID;
      x_dlv_rec.SHIP_METHOD_CODE := p_dlv_rec.SHIP_METHOD_CODE;
      x_dlv_rec.FREIGHT_TERMS_CODE := p_dlv_rec.FREIGHT_TERMS_CODE;
      x_dlv_rec.FOB_CODE := p_dlv_rec.FOB_CODE;
      x_dlv_rec.FOB_LOCATION_ID := p_dlv_rec.FOB_LOCATION_ID;
      x_dlv_rec.WAYBILL := p_dlv_rec.WAYBILL;
      x_dlv_rec.DOCK_CODE := p_dlv_rec.DOCK_CODE;
      x_dlv_rec.ACCEPTANCE_FLAG := p_dlv_rec.ACCEPTANCE_FLAG;
      x_dlv_rec.ACCEPTED_BY := p_dlv_rec.ACCEPTED_BY;
      x_dlv_rec.ACCEPTED_DATE := p_dlv_rec.ACCEPTED_DATE;
      x_dlv_rec.ACKNOWLEDGED_BY := p_dlv_rec.ACKNOWLEDGED_BY;
      x_dlv_rec.CONFIRMED_BY := p_dlv_rec.CONFIRMED_BY;
      x_dlv_rec.CONFIRM_DATE := p_dlv_rec.CONFIRM_DATE;
      x_dlv_rec.ASN_DATE_SENT := p_dlv_rec.ASN_DATE_SENT;
      x_dlv_rec.ASN_STATUS_CODE := p_dlv_rec.ASN_STATUS_CODE;
      x_dlv_rec.ASN_SEQ_NUMBER := p_dlv_rec.ASN_SEQ_NUMBER;
      x_dlv_rec.GROSS_WEIGHT := p_dlv_rec.GROSS_WEIGHT;
      x_dlv_rec.NET_WEIGHT := p_dlv_rec.NET_WEIGHT;
      x_dlv_rec.WEIGHT_UOM_CODE := p_dlv_rec.WEIGHT_UOM_CODE;
      x_dlv_rec.VOLUME := p_dlv_rec.VOLUME;
      x_dlv_rec.VOLUME_UOM_CODE := p_dlv_rec.VOLUME_UOM_CODE;
      x_dlv_rec.ADDITIONAL_SHIPMENT_INFO := p_dlv_rec.ADDITIONAL_SHIPMENT_INFO;
      x_dlv_rec.CURRENCY_CODE := p_dlv_rec.CURRENCY_CODE;
      x_dlv_rec.CREATION_DATE := p_dlv_rec.CREATION_DATE;
      x_dlv_rec.CREATED_BY := p_dlv_rec.CREATED_BY;
      x_dlv_rec.LAST_UPDATE_DATE := p_dlv_rec.LAST_UPDATE_DATE;
      x_dlv_rec.LAST_UPDATED_BY := p_dlv_rec.LAST_UPDATED_BY;
      x_dlv_rec.LAST_UPDATE_LOGIN := p_dlv_rec.LAST_UPDATE_LOGIN;
      x_dlv_rec.PROGRAM_APPLICATION_ID := p_dlv_rec.PROGRAM_APPLICATION_ID;
      x_dlv_rec.PROGRAM_ID := p_dlv_rec.PROGRAM_ID;
      x_dlv_rec.PROGRAM_UPDATE_DATE := p_dlv_rec.PROGRAM_UPDATE_DATE;
      x_dlv_rec.REQUEST_ID := p_dlv_rec.REQUEST_ID;
      x_dlv_rec.BATCH_ID := p_dlv_rec.BATCH_ID;
      x_dlv_rec.HASH_VALUE := p_dlv_rec.HASH_VALUE;
      x_dlv_rec.SOURCE_HEADER_ID := p_dlv_rec.SOURCE_HEADER_ID;
      x_dlv_rec.NUMBER_OF_LPN := p_dlv_rec.NUMBER_OF_LPN;
/* Changes for the Shipping Data Model Bug#1918342*/
      x_dlv_rec.COD_AMOUNT := p_dlv_rec.COD_AMOUNT;
      x_dlv_rec.COD_CURRENCY_CODE := p_dlv_rec.COD_CURRENCY_CODE;
      x_dlv_rec.COD_REMIT_TO := p_dlv_rec.COD_REMIT_TO;
      x_dlv_rec.COD_CHARGE_PAID_BY := p_dlv_rec.COD_CHARGE_PAID_BY;
      x_dlv_rec.PROBLEM_CONTACT_REFERENCE := p_dlv_rec.PROBLEM_CONTACT_REFERENCE;
      x_dlv_rec.PORT_OF_LOADING := p_dlv_rec.PORT_OF_LOADING;
      x_dlv_rec.PORT_OF_DISCHARGE := p_dlv_rec.PORT_OF_DISCHARGE;
      x_dlv_rec.FTZ_NUMBER := p_dlv_rec.FTZ_NUMBER;
      x_dlv_rec.ROUTED_EXPORT_TXN := p_dlv_rec.ROUTED_EXPORT_TXN;
      x_dlv_rec.ENTRY_NUMBER := p_dlv_rec.ENTRY_NUMBER;
      x_dlv_rec.ROUTING_INSTRUCTIONS := p_dlv_rec.ROUTING_INSTRUCTIONS;
      x_dlv_rec.IN_BOND_CODE := p_dlv_rec.IN_BOND_CODE;
      x_dlv_rec.SHIPPING_MARKS := p_dlv_rec.SHIPPING_MARKS;
/* H Integration: datamodel changes wrudge */
      x_dlv_rec.SERVICE_LEVEL := p_dlv_rec.SERVICE_LEVEL;
      x_dlv_rec.MODE_OF_TRANSPORT := p_dlv_rec.MODE_OF_TRANSPORT;
      x_dlv_rec.ASSIGNED_TO_FTE_TRIPS := p_dlv_rec.ASSIGNED_TO_FTE_TRIPS;
/* I Quickship : datamodel changes sperera */
      x_dlv_rec.AUTO_SC_EXCLUDE_FLAG := p_dlv_rec.AUTO_SC_EXCLUDE_FLAG;
      x_dlv_rec.AUTO_AP_EXCLUDE_FLAG := p_dlv_rec.AUTO_AP_EXCLUDE_FLAG;
      x_dlv_rec.AP_BATCH_ID := p_dlv_rec.AP_BATCH_ID;
--
  END;

   PROCEDURE convert_amount(
     	p_from_currency		IN VARCHAR2,
     	p_from_amount		IN NUMBER,
     	p_to_currency		IN VARCHAR2,
	x_to_amount		OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2)
   IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_api_name VARCHAR2(50) := 'convert_amount';
   BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

     fte_freight_pricing_util.print_msg(l_log_level,'p_from_currency= '||p_from_currency);
     fte_freight_pricing_util.print_msg(l_log_level,'p_from_amount= '||p_from_amount);
     fte_freight_pricing_util.print_msg(l_log_level,'p_to_currency= '||p_to_currency);

     x_to_amount := GL_CURRENCY_API.convert_amount(
                                     p_from_currency,
                                     p_to_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_from_amount
                                     );

     fte_freight_pricing_util.print_msg(l_log_level,'x_to_amount= '||x_to_amount);

   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level, l_api_name);

   EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

   END convert_amount;

  PROCEDURE validate_delivery      (p_delivery_id           IN NUMBER,
				    x_return_code	    OUT NOCOPY NUMBER)
  IS
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
       l_dlv_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
       c_dlv_rec             c_delivery%ROWTYPE;

      c_carr_srv_rec 		c_carrier_services%ROWTYPE;
      l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
      l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
      l_carrier_id 		NUMBER;
      l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
      l_service_level 		wsh_carrier_services.service_level%type;
--
       l_leg_id  NUMBER;
       l_trip_id  NUMBER;
       i             NUMBER := 0;
       l_dlev_leg_rec   dlv_leg_info_rec;
       l_trip_info_rec  trip_info_rec;
       l_trip_dleg_cnt  NUMBER;
       l_leg_count	NUMBER;
       l_count	NUMBER;
       l_reprice_required VARCHAR2(1);
   l_leg_trip_det_rec    c_leg_trip_det%ROWTYPE;
--
      l_return_status       VARCHAR2(30);
      l_return_status_1     VARCHAR2(30);
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_DELIVERY';
      l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_DELIVERY';

      l_check_dlv_shipmethod  VARCHAR2(1) := 'N';
--
  BEGIN
--
    x_return_code := G_RC_SUCCESS;

      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_id='||p_delivery_id);

    -- check for empty delivery
    l_count := 0;
    OPEN c_count_delivery_details(p_delivery_id);
    FETCH c_count_delivery_details INTO l_count;
    CLOSE c_count_delivery_details;
    IF ( l_count <= 0 ) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'empty delivery');

               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_EMPTY_DEL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);

	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
    END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating delivery info...');

    OPEN c_delivery(p_delivery_id);
    FETCH c_delivery INTO c_dlv_rec;
    CLOSE c_delivery;

    -- store delivery information
    load_dlv_rec (p_dlv_rec => c_dlv_rec, x_dlv_rec => l_dlv_rec);

    g_dlv_tab(p_delivery_id) := l_dlv_rec;

    IF (g_dlv_tab(p_delivery_id).ship_method_code is not null)
	AND (g_dlv_tab(p_delivery_id).carrier_id is null
	  OR g_dlv_tab(p_delivery_id).mode_of_transport is null
	  OR g_dlv_tab(p_delivery_id).service_level is null) THEN

      OPEN  c_carrier_services(g_dlv_tab(p_delivery_id).ship_method_code);
      FETCH c_carrier_services INTO c_carr_srv_rec;
      CLOSE c_carrier_services;

      g_dlv_tab(p_delivery_id).carrier_id := c_carr_srv_rec.carrier_id;
      g_dlv_tab(p_delivery_id).mode_of_transport := c_carr_srv_rec.mode_of_transport;
      g_dlv_tab(p_delivery_id).service_level := c_carr_srv_rec.service_level;

    END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'validating delivery status...');

    IF ( g_dlv_tab(p_delivery_id).status_code <> 'OP' ) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery status is not OPEN');

               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_DLV_DLV_INV_STATUS',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);

	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
    END IF;

    l_ship_method_code := g_dlv_tab(p_delivery_id).ship_method_code;
    l_carrier_id := g_dlv_tab(p_delivery_id).carrier_id;
    l_mode_of_transport := g_dlv_tab(p_delivery_id).mode_of_transport;
    l_service_level := g_dlv_tab(p_delivery_id).service_level;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery ship method code is '||l_ship_method_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery carrier id is '||l_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery mode_of_transport is '||l_mode_of_transport);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery service_level is '||l_service_level);

    -- populate dleg, trip
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating dleg and trip info...');

    -- store delivery leg, trip information if existing
    l_leg_count := 0;
    l_reprice_required := 'N';
    FOR c_dleg_rec in c_dlv_legs(p_delivery_id)
    LOOP

      l_leg_count := l_leg_count +1;
      l_leg_id := c_dleg_rec.delivery_leg_id;

      g_dlv_leg_tab(l_leg_id) := c_dleg_rec;

      OPEN c_leg_trip_det(l_leg_id);
      FETCH c_leg_trip_det INTO l_leg_trip_det_rec;
      CLOSE c_leg_trip_det;
      l_trip_id := l_leg_trip_det_rec.trip_id;
      g_trip_info_tab(l_trip_id) := l_leg_trip_det_rec;

      g_dleg_trip_tab(l_leg_id).delivery_leg_id := l_leg_id;
      g_dleg_trip_tab(l_leg_id).trip_id := l_trip_id;

        OPEN c_cnt_trip_legs(l_trip_id);
        FETCH c_cnt_trip_legs INTO l_trip_dleg_cnt;
        CLOSE c_cnt_trip_legs;

       --Need to remove following check as in R12 Multileg rating is allowed
        -- from STF.

       /* IF (l_trip_dleg_cnt > 1) THEN
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip '||l_trip_id||' has too many dlegs');

               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_TRP_MNY_DLV',
		  p_trip_id            =>     l_trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);

	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
        END IF; -- l_trip_dleg_cnt > 1
        */
      IF (g_trip_info_tab(l_leg_trip_det_rec.trip_id).ship_method_code is not null)
	AND (g_trip_info_tab(l_leg_trip_det_rec.trip_id).carrier_id is null
	  OR g_trip_info_tab(l_leg_trip_det_rec.trip_id).mode_of_transport is null
	  OR g_trip_info_tab(l_leg_trip_det_rec.trip_id).service_level is null) THEN

        OPEN  c_carrier_services(g_trip_info_tab(l_leg_trip_det_rec.trip_id).ship_method_code);
        FETCH c_carrier_services INTO c_carr_srv_rec;
        CLOSE c_carrier_services;

        g_trip_info_tab(l_leg_trip_det_rec.trip_id).carrier_id := c_carr_srv_rec.carrier_id;
        g_trip_info_tab(l_leg_trip_det_rec.trip_id).mode_of_transport := c_carr_srv_rec.mode_of_transport;
        g_trip_info_tab(l_leg_trip_det_rec.trip_id).service_level := c_carr_srv_rec.service_level;

      END IF;

        IF (g_trip_info_tab(l_trip_id).carrier_id IS NULL
	AND g_trip_info_tab(l_trip_id).mode_of_transport IS NULL
	AND g_trip_info_tab(l_trip_id).service_level IS NULL) THEN

	  -- populate trip ship method with delivery ship method
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populate trip '||l_trip_id||' with delivery ship method');
          g_trip_info_tab(l_trip_id).ship_method_code := l_ship_method_code;
          g_trip_info_tab(l_trip_id).carrier_id := l_carrier_id;
          g_trip_info_tab(l_trip_id).mode_of_transport := l_mode_of_transport;
          g_trip_info_tab(l_trip_id).service_level := l_service_level;

	END IF; -- g_trip_info_tab(l_trip_id).ship_method_code IS NULL

      IF g_trip_info_tab(l_trip_id).lane_id is null THEN
	l_reprice_required := 'Y';
      ELSE
        IF g_dlv_leg_tab(l_leg_id).reprice_required = 'Y' THEN
	  l_reprice_required := 'Y';
        END IF;
      END IF;

    END LOOP;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_leg_count='||l_leg_count);

    IF (l_leg_count > 0 AND l_reprice_required = 'N') THEN
    /*
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_DEL_REQD',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_delivery_id);
     */
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'reprice not required, do not rate.');
      x_return_code := G_RC_REPRICE_NOT_REQUIRED;
      raise g_finished_warning;
    END IF;

    -- validate freight term
    l_count := 0;
    OPEN c_check_del_freight_term(p_delivery_id);
    FETCH c_check_del_freight_term INTO l_count;
    CLOSE c_check_del_freight_term;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_DEL_FGT_TERM',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_delivery_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'do not rate the freight term.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    -- Manifesting validation
    l_count := 0;
    OPEN c_check_del_manifesting(p_delivery_id);
    FETCH c_check_del_manifesting INTO l_count;
    CLOSE c_check_del_manifesting;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_DEL_MAN',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_delivery_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery organization is manifesting enabled and carrier is manifesting enabled, do not rate.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
	WHEN g_finished_warning THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
  END validate_delivery;
--
--
  PROCEDURE create_trip           (p_delivery_id           IN NUMBER,
                                   x_trip_id               OUT NOCOPY NUMBER,
                                   x_delivery_leg_id       OUT NOCOPY NUMBER,
                                   x_return_status         OUT NOCOPY  VARCHAR2)
  IS
--
   l_delivery_out_rec    WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
   l_defaults_rec        WSH_DELIVERIES_GRP.default_parameters_rectype;
   l_action_prms         WSH_DELIVERIES_GRP.action_parameters_rectype;
   l_return_status       VARCHAR2(1);
   l_return_status_1         VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(32767);
--
   l_delivery_id         NUMBER;
   l_delivery_leg_id     NUMBER;
   l_trip_id             NUMBER;
   i                     NUMBER;
   c_dleg_rec            c_dlv_legs%ROWTYPE;
   l_leg_trip_det_rec    c_leg_trip_det%ROWTYPE;
   l_dlv_id_tab          wsh_util_core.id_tab_type;
   l_idx                 NUMBER;
--
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CREATE_TRIP';
--
--
  BEGIN
--
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;
--
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_delivery_id '||p_delivery_id,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

    l_idx := 0;
    IF (g_dlv_tab.COUNT >0) THEN
    FOR i IN g_dlv_tab.FIRST ..g_dlv_tab.LAST
    LOOP
       -- Note : id tab should not be indexe by delivery id
       --   because of wsh_trip_actions needs index beginning with 1.
      if (i = p_delivery_id) then --fix bug2883305
       l_idx := l_idx +1;
       l_dlv_id_tab(l_idx) := g_dlv_tab(i).delivery_id;
      end if; -- fix bug2883305
    END LOOP;
    END IF;

    l_action_prms.action_code   := 'AUTOCREATE-TRIP';
    l_action_prms.caller   := 'FTE';
--
    WSH_INTERFACE_GRP.Delivery_Action
     ( p_api_version_number     => 1.0,
       p_init_msg_list          => FND_API.G_FALSE,
       p_commit                 => FND_API.G_FALSE,
       p_action_prms            => l_action_prms,
       p_delivery_id_tab        => l_dlv_id_tab,
       x_delivery_out_rec       => l_delivery_out_rec,
       x_return_status          => l_return_status,
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data
     );

    -- WSH_DELIVERIES_GRP.Delivery_Action
    -- ( p_api_version_number     =>'1.0',
    --   p_init_msg_list          =>FND_API.G_TRUE,
    --  p_commit                 =>FND_API.G_FALSE,
    --  p_action_prms            => l_action_prms,
    --  p_rec_attr_tab           => g_dlv_tab,
    --  x_delivery_out_rec       => l_delivery_out_rec,
    --  x_defaults_rec           => l_defaults_rec,
    --  x_return_status          => l_return_status,
    --  x_msg_count              => l_msg_count,
    --  x_msg_data               => l_msg_data
    --);
--
           api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.Delivery_Action',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_AUTO_CR_TRP_FL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	  IF (l_return_status_1 = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                 x_return_status := l_return_status_1;
	  END IF;
--
--
    -- TODO : check error conditions
--
     FOR c_dleg_rec in c_dlv_legs(p_delivery_id)
     LOOP
        g_dlv_leg_tab(c_dleg_rec.delivery_leg_id) := c_dleg_rec;
--
        l_delivery_leg_id := c_dleg_rec.delivery_leg_id;
--
        OPEN c_leg_trip_det(l_delivery_leg_id);
        FETCH c_leg_trip_det INTO l_leg_trip_det_rec;
        CLOSE c_leg_trip_det;
--
        g_trip_info_tab(l_leg_trip_det_rec.trip_id) := l_leg_trip_det_rec;
        l_trip_id := l_leg_trip_det_rec.trip_id;
--
        g_dleg_trip_tab(c_dleg_rec.delivery_leg_id).delivery_leg_id := c_dleg_rec.delivery_leg_id;
        g_dleg_trip_tab(c_dleg_rec.delivery_leg_id).trip_id := l_leg_trip_det_rec.trip_id;
--
     END LOOP;
--
    IF l_debug_on THEN
     WSH_DEBUG_SV.logmsg(l_module_name,'l_delivery_leg_id=>'||l_delivery_leg_id
                                        ||'l_trip_id=>'||l_trip_id ,WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;
    x_delivery_leg_id  := l_delivery_leg_id;
    x_trip_id          := l_trip_id;
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.create_trip');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
  END create_trip;
--
--
  PROCEDURE update_single_trip    (p_trip_id               IN NUMBER,
                                   p_lane_id               IN NUMBER,
                                   p_carrier_id            IN NUMBER,
                                   p_ship_method_code      IN VARCHAR2,
                                   p_ship_method_name      IN VARCHAR2,
                                   p_service_level         IN VARCHAR2,
                                   p_mode_of_transport     IN VARCHAR2,
                                   -- p_consolidation_allowed IN VARCHAR2,
                                   p_vehicle_type_id	   IN NUMBER,-- If p_vehicle_type id is not passed in
				   p_vehicle_item_id	   IN NUMBER,--- then p_vehicle_item/org_id is considered
				   p_vehicle_org_id	   IN NUMBER,
				   p_rank_id		   IN NUMBER DEFAULT NULL,
				   p_append_flag	   VARCHAR2 DEFAULT NULL,
                                   x_return_status         OUT NOCOPY  VARCHAR2,
		       	           x_msg_count	           OUT NOCOPY  NUMBER,
			           x_msg_data	           OUT NOCOPY  VARCHAR2)
  IS
     l_api_version_number NUMBER := 1;
     l_trip_info_tab	WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
     l_trip_info WSH_TRIPS_PVT.Trip_Rec_Type;
     l_trip_in_rec WSH_TRIPS_GRP.TripInRecType;
     l_out_tab WSH_TRIPS_GRP.trip_Out_tab_type;
     l_vehicle_item_id NUMBER;
     l_vehicle_org_id NUMBER;
     l_return_status         VARCHAR2(1);
     l_return_status_1         VARCHAR2(1);
--
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'UPDATE_SINGLE_TRIP';
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_api_name           CONSTANT VARCHAR2(30)   := 'UPDATE_SINGLE_TRIP';
--



	CURSOR c_get_vehicle_item_org (c_vehicle_type_id IN NUMBER)
	IS
	select 	v.inventory_item_id,
		v.ORGANIZATION_ID
	from 	fte_vehicle_types v
	where 	v.vehicle_type_id = c_vehicle_type_id;


--
    cursor c_trip(c_trip_id NUMBER)
    is
    select * from wsh_trips
    where trip_id = c_trip_id;
--
    c_trip_rec c_trip%ROWTYPE;
--
  BEGIN
--
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;
--
      IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'p_trip_id=>'||p_trip_id
                                                  ||'p_lane_id=>'||p_lane_id
                                                  ||'p_ship_method_code=>'||p_ship_method_code
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_lane_id='||p_lane_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_ship_method_code='||p_ship_method_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_ship_method_name='||p_ship_method_name);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_carrier_id='||p_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_service_level='||p_service_level);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_mode_of_transport='||p_mode_of_transport);

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'fetching trip info...');
      OPEN c_trip(p_trip_id);
      FETCH c_trip into c_trip_rec;
      CLOSE c_trip;



      IF (p_vehicle_type_id IS NOT NULL)
      THEN

      	OPEN c_get_vehicle_item_org(p_vehicle_type_id);
      	FETCH c_get_vehicle_item_org INTO l_vehicle_item_id,l_vehicle_org_id;
      	CLOSE c_get_vehicle_item_org;

      ELSIF (p_vehicle_item_id IS NOT NULL AND p_vehicle_org_id IS NOT NULL)
      THEN
		l_vehicle_item_id:=p_vehicle_item_id;
		l_vehicle_org_id:=l_vehicle_org_id;

      END IF;
--
      l_trip_info.TRIP_ID                         := c_trip_rec.TRIP_ID ;
      l_trip_info.NAME                            := c_trip_rec.NAME ;
      l_trip_info.PLANNED_FLAG                    := c_trip_rec.PLANNED_FLAG ;
      l_trip_info.ARRIVE_AFTER_TRIP_ID            := c_trip_rec.ARRIVE_AFTER_TRIP_ID ;
      l_trip_info.STATUS_CODE                     := c_trip_rec.STATUS_CODE ;
      l_trip_info.VEHICLE_ITEM_ID                 := c_trip_rec.VEHICLE_ITEM_ID ;
      l_trip_info.VEHICLE_ORGANIZATION_ID         := c_trip_rec.VEHICLE_ORGANIZATION_ID ;
      l_trip_info.VEHICLE_NUMBER                  := c_trip_rec.VEHICLE_NUMBER ;
      l_trip_info.VEHICLE_NUM_PREFIX              := c_trip_rec.VEHICLE_NUM_PREFIX ;
      l_trip_info.CARRIER_ID                      := c_trip_rec.CARRIER_ID ;
      l_trip_info.SHIP_METHOD_CODE                := c_trip_rec.SHIP_METHOD_CODE ;
      l_trip_info.ROUTE_ID                        := c_trip_rec.ROUTE_ID ;
      l_trip_info.ROUTING_INSTRUCTIONS            := c_trip_rec.ROUTING_INSTRUCTIONS ;
      l_trip_info.ATTRIBUTE_CATEGORY              := c_trip_rec.ATTRIBUTE_CATEGORY ;
      l_trip_info.ATTRIBUTE1                      := c_trip_rec.ATTRIBUTE1 ;
      l_trip_info.ATTRIBUTE2                      := c_trip_rec.ATTRIBUTE2 ;
      l_trip_info.ATTRIBUTE3                      := c_trip_rec.ATTRIBUTE3 ;
      l_trip_info.ATTRIBUTE4                      := c_trip_rec.ATTRIBUTE4 ;
      l_trip_info.ATTRIBUTE5                      := c_trip_rec.ATTRIBUTE5 ;
      l_trip_info.ATTRIBUTE6                      := c_trip_rec.ATTRIBUTE6 ;
      l_trip_info.ATTRIBUTE7                      := c_trip_rec.ATTRIBUTE7 ;
      l_trip_info.ATTRIBUTE8                      := c_trip_rec.ATTRIBUTE8 ;
      l_trip_info.ATTRIBUTE9                      := c_trip_rec.ATTRIBUTE9 ;
      l_trip_info.ATTRIBUTE10                     := c_trip_rec.ATTRIBUTE10 ;
      l_trip_info.ATTRIBUTE11                     := c_trip_rec.ATTRIBUTE11 ;
      l_trip_info.ATTRIBUTE12                     := c_trip_rec.ATTRIBUTE12 ;
      l_trip_info.ATTRIBUTE13                     := c_trip_rec.ATTRIBUTE13 ;
      l_trip_info.ATTRIBUTE14                     := c_trip_rec.ATTRIBUTE14 ;
      l_trip_info.ATTRIBUTE15                     := c_trip_rec.ATTRIBUTE15 ;
      l_trip_info.CREATION_DATE                   := c_trip_rec.CREATION_DATE ;
      l_trip_info.CREATED_BY                      := c_trip_rec.CREATED_BY ;
      l_trip_info.LAST_UPDATE_DATE                := c_trip_rec.LAST_UPDATE_DATE ;
      l_trip_info.LAST_UPDATED_BY                 := c_trip_rec.LAST_UPDATED_BY ;
      l_trip_info.LAST_UPDATE_LOGIN               := c_trip_rec.LAST_UPDATE_LOGIN ;
      l_trip_info.PROGRAM_APPLICATION_ID          := c_trip_rec.PROGRAM_APPLICATION_ID ;
      l_trip_info.PROGRAM_ID                      := c_trip_rec.PROGRAM_ID ;
      l_trip_info.PROGRAM_UPDATE_DATE             := c_trip_rec.PROGRAM_UPDATE_DATE ;
      l_trip_info.REQUEST_ID                      := c_trip_rec.REQUEST_ID ;
      l_trip_info.SERVICE_LEVEL                   := c_trip_rec.SERVICE_LEVEL ;
      l_trip_info.MODE_OF_TRANSPORT               := c_trip_rec.MODE_OF_TRANSPORT ;
      l_trip_info.FREIGHT_TERMS_CODE              := c_trip_rec.FREIGHT_TERMS_CODE ;
      l_trip_info.CONSOLIDATION_ALLOWED           := c_trip_rec.CONSOLIDATION_ALLOWED ;
      l_trip_info.LOAD_TENDER_STATUS              := c_trip_rec.LOAD_TENDER_STATUS ;
      l_trip_info.ROUTE_LANE_ID                   := c_trip_rec.ROUTE_LANE_ID ;
      l_trip_info.LANE_ID                         := c_trip_rec.LANE_ID ;
      l_trip_info.SCHEDULE_ID                     := c_trip_rec.SCHEDULE_ID ;
      l_trip_info.BOOKING_NUMBER                  := c_trip_rec.BOOKING_NUMBER ;
      l_trip_info.LOAD_TENDER_NUMBER              := c_trip_rec.LOAD_TENDER_NUMBER ;
      l_trip_info.VESSEL                          := c_trip_rec.VESSEL ;
      l_trip_info.VOYAGE_NUMBER                   := c_trip_rec.VOYAGE_NUMBER ;
      l_trip_info.PORT_OF_LOADING                 := c_trip_rec.PORT_OF_LOADING ;
      l_trip_info.PORT_OF_DISCHARGE               := c_trip_rec.PORT_OF_DISCHARGE ;
      l_trip_info.WF_NAME                         := c_trip_rec.WF_NAME ;
      l_trip_info.WF_PROCESS_NAME                 := c_trip_rec.WF_PROCESS_NAME ;
      l_trip_info.WF_ITEM_KEY                     := c_trip_rec.WF_ITEM_KEY ;
      l_trip_info.CARRIER_CONTACT_ID              := c_trip_rec.CARRIER_CONTACT_ID ;
      l_trip_info.SHIPPER_WAIT_TIME               := c_trip_rec.SHIPPER_WAIT_TIME ;
      l_trip_info.WAIT_TIME_UOM                   := c_trip_rec.WAIT_TIME_UOM ;
      l_trip_info.LOAD_TENDERED_TIME              := c_trip_rec.LOAD_TENDERED_TIME ;
      l_trip_info.CARRIER_RESPONSE                := c_trip_rec.CARRIER_RESPONSE ;
--
--
            l_trip_in_rec.caller :='FTE';
            l_trip_in_rec.phase  :=1;
            l_trip_in_rec.action_code:='UPDATE';
--
 	    l_trip_info.TRIP_ID             := p_trip_id;
 	    l_trip_info.CARRIER_ID          := p_carrier_id;
 	    l_trip_info.SHIP_METHOD_CODE    := p_ship_method_code;
	    l_trip_info.SERVICE_LEVEL       := p_service_level;
	    l_trip_info.MODE_OF_TRANSPORT   := p_mode_of_transport;
	    l_trip_info.LANE_ID             := p_lane_id;
	    l_trip_info.SHIP_METHOD_NAME    := p_ship_method_name;


	    IF ((l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL))
	    THEN


	      l_trip_info.VEHICLE_ITEM_ID                 := l_vehicle_item_id;
	      l_trip_info.VEHICLE_ORGANIZATION_ID         := l_vehicle_org_id;

	    END IF;
	    IF(p_rank_id IS NOT NULL)
	    THEN
		l_trip_info.RANK_ID:=p_rank_id;
	    END IF;
	    IF(p_append_flag IS NOT NULL)
	    THEN
		l_trip_info.APPEND_FLAG:=p_append_flag;
	    END IF;

--
            l_trip_info_tab(1) := l_trip_info;
--

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling WSH_INTERFACE_GRP.Create_Update_Trip...');

	     --call wsh public API
	     WSH_INTERFACE_GRP.Create_Update_Trip
	     (
		    p_api_version_number  =>l_api_version_number,
		    p_init_msg_list       =>FND_API.G_FALSE,
		    p_commit              =>FND_API.G_FALSE,
		    x_return_status       =>l_return_status,
		    x_msg_count           =>x_msg_count,
		    x_msg_data            =>x_msg_data,
		    p_trip_info_tab       =>l_trip_info_tab,
		    p_in_rec              =>l_trip_in_rec,
		    x_out_tab             =>l_out_tab
	     );
--
           api_post_call
		(
		  p_api_name           =>     'WSH_INTERFACE_GRP.CREATE_UPDATE_TRIP',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_UPD_TRP_FAIL',
		  p_trip_id            =>     p_trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	  IF (l_return_status_1 = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                 x_return_status := l_return_status_1;
	  END IF;

--
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
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
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
  END update_single_trip;
--
--
  -- update multiple trips (connected to the delivery)
  PROCEDURE update_trips         ( p_delivery_id          IN NUMBER,
                                   p_matched_lanes        IN lane_match_tab,
                                   x_return_status         OUT NOCOPY  VARCHAR2,
		       	           x_msg_count	           OUT NOCOPY  NUMBER,
			           x_msg_data	           OUT NOCOPY  VARCHAR2)
  IS
     i   NUMBER;
     l_return_status           VARCHAR2(1);
     l_return_status_1         VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(32767);
--
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'UPDATE_TRIPS';
--
  BEGIN
      SAVEPOINT  UPDATE_TRIPS;
--
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;
--
    IF (p_matched_lanes.COUNT > 0) THEN
    FOR i IN p_matched_lanes.FIRST .. p_matched_lanes.LAST
    LOOP
--

      IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'p_matched_lanes : i =>'||i
                                                  ||'trip_id=>'||p_matched_lanes(i).trip_id
                                                  ||'delivery_leg_id=>'||p_matched_lanes(i).delivery_leg_id
                                                  ||'delivery_id=>'||p_matched_lanes(i).delivery_id
                                                  ||'lane_id=>'||p_matched_lanes(i).lane_id
                                                  ||'ship_method_code=>'||p_matched_lanes(i).ship_method_code
                                                  ||'new_match=>'||p_matched_lanes(i).new_match
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
        IF (p_matched_lanes(i).new_match = 'Y') THEN
--
            update_single_trip    (p_trip_id               => p_matched_lanes(i).trip_id,
                                   p_lane_id               => p_matched_lanes(i).lane_id,
                                   p_carrier_id            => p_matched_lanes(i).carrier_id,
                                   p_ship_method_code      => p_matched_lanes(i).ship_method_code,
                                   p_ship_method_name      => p_matched_lanes(i).ship_method_name,
                                   p_service_level         => p_matched_lanes(i).service_level,
                                   p_mode_of_transport     => p_matched_lanes(i).mode_of_transport,
                                   p_vehicle_type_id	   =>NULL,
				   p_vehicle_item_id	   =>NULL,
				   p_vehicle_org_id	   =>NULL,
                                   x_return_status         => l_return_status,
       	                           x_msg_count	           => l_msg_count,
			           x_msg_data	           => l_msg_data );
--
	  IF (l_return_status = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                       x_return_status := l_return_status;
	  END IF;
--
        END IF;
--
    END LOOP;
    END IF;
--
	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UPDATE_TRIPS;
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
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UPDATE_TRIPS;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_TRIPS;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.update_trips');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
  END update_trips;
--
  PROCEDURE unassign_trip         ( p_trip_id              IN NUMBER,
                                    x_return_status        OUT NOCOPY  VARCHAR2,
		       	            x_msg_count	           OUT NOCOPY  NUMBER,
			            x_msg_data	           OUT NOCOPY  VARCHAR2)
  IS
     i   NUMBER;
     l_return_status           VARCHAR2(1);
     l_return_status_1         VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(32767);
--
     l_delivery_out_rec    WSH_DELIVERIES_GRP.Delivery_Action_Out_Rec_Type;
     l_defaults_rec        WSH_DELIVERIES_GRP.default_parameters_rectype;
     l_action_prms         WSH_DELIVERIES_GRP.action_parameters_rectype;

     l_dlv_id_tab          wsh_util_core.id_tab_type;
     l_idx                 NUMBER;

     l_number_of_errors          NUMBER;
     l_number_of_warnings	    NUMBER;
     l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
     l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'UNASSIGN_TRIP';
--
  BEGIN
      SAVEPOINT  UNASSIGN_TRIP;
--
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;
--
    l_idx := 0;
    IF (g_dlv_tab.COUNT >0) THEN
    FOR i IN g_dlv_tab.FIRST ..g_dlv_tab.LAST
    LOOP
       -- Note : id tab should not be indexe by delivery id
       --   because of wsh_trip_actions needs index beginning with 1.
       l_idx := l_idx +1;
       l_dlv_id_tab(l_idx) := g_dlv_tab(i).delivery_id;
    END LOOP;
    END IF;

    l_action_prms.action_code   := 'UNASSIGN-TRIP';
    l_action_prms.caller   := 'FTE';
    l_action_prms.trip_id   := p_trip_id;
--

    WSH_INTERFACE_GRP.Delivery_Action
     ( p_api_version_number     => 1.0,
       p_init_msg_list          => FND_API.G_FALSE,
       p_commit                 => FND_API.G_FALSE,
       p_action_prms            => l_action_prms,
       p_delivery_id_tab        => l_dlv_id_tab,
       x_delivery_out_rec       => l_delivery_out_rec,
       x_return_status          => l_return_status,
       x_msg_count              => l_msg_count,
       x_msg_data               => l_msg_data
     );
--
           api_post_call
		(
		  p_api_name           =>     'WSH_DELIVERIES_GRP.Delivery_Action',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_UNASSGN_TRP_FL',
		  p_trip_id            =>     p_trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	  IF (l_return_status_1 = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                x_return_status := l_return_status_1;
	  END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO UNASSIGN_TRIP;
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
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO UNASSIGN_TRIP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
	WHEN OTHERS THEN
		ROLLBACK TO UNASSIGN_TRIP;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.Unassign_Trip');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
  END unassign_trip;
--
--
--

  PROCEDURE Cancel_Service  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_delivery_id              IN  NUMBER,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                  	IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
		       	     x_msg_count	        OUT NOCOPY  NUMBER,
			     x_msg_data	                OUT NOCOPY  VARCHAR2)
  IS
      i NUMBER;
      l_fc_count            NUMBER;

      l_log_level           NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_return_status       VARCHAR2(1);
      l_return_status_1     VARCHAR2(1);
--
      l_dlv_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
      l_leg_trip_det_rec    trip_info_rec;
      l_del_out_tab         WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;
      l_del_in_rec          WSH_DELIVERIES_GRP.Del_In_Rec_Type;
      c_dlv_rec             c_delivery%ROWTYPE;
--
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);
--
      l_number_of_errors            NUMBER;
      l_number_of_warnings	    NUMBER;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CANCEL_SERVICE';

      cursor c_get_dleg_summ_recs (c_dleg_id NUMBER)
      is
      SELECT freight_cost_id
      FROM   wsh_freight_costs
      WHERE  delivery_leg_id = c_dleg_id
      AND    line_type_code = 'SUMMARY'
      AND    delivery_detail_id IS NULL ;

     l_freight_cost_id  NUMBER;

  BEGIN
      -- Clear ship method and carrier information on trip
      -- Unassign trip from delivery
      -- Clear shipmethod and carrier information on delivery
      -- Delete all FTE freight cost records tied to the delivery

      SAVEPOINT  CANCEL_SERVICE;
--
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;

      IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_id=>'||p_delivery_id
                                                  ||'p_action=>'||p_action
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

       -- supported actions
      IF (p_action <> 'CANCEL') THEN
         -- raise g_invalid_action;
--
               l_return_status := FND_API.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.CANCEL_SERVICE',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_DLV_INV_ACT',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
--
      END IF;

       i := 0;
       OPEN c_delivery(p_delivery_id);
       FETCH c_delivery INTO c_dlv_rec;
       CLOSE c_delivery;

       g_dlv_tab.DELETE;
       g_dlv_leg_tab.DELETE;
       g_trip_info_tab.DELETE;
       g_dleg_trip_tab.DELETE;
--
      -- store delivery information
      load_dlv_rec (p_dlv_rec => c_dlv_rec,
                    x_dlv_rec => l_dlv_rec);
--
      g_dlv_tab(p_delivery_id) := l_dlv_rec;
--
      -- store delivery leg, trip information if existing
--
      FOR c_dleg_rec in c_dlv_legs(p_delivery_id)
      LOOP
         g_dlv_leg_tab(c_dleg_rec.delivery_leg_id) := c_dleg_rec;
--
         OPEN c_leg_trip_det(c_dleg_rec.delivery_leg_id);
         FETCH c_leg_trip_det INTO l_leg_trip_det_rec;
         CLOSE c_leg_trip_det;
--
         g_trip_info_tab(l_leg_trip_det_rec.trip_id) := l_leg_trip_det_rec;
--
         g_dleg_trip_tab(c_dleg_rec.delivery_leg_id).delivery_leg_id := c_dleg_rec.delivery_leg_id;
         g_dleg_trip_tab(c_dleg_rec.delivery_leg_id).trip_id := l_leg_trip_det_rec.trip_id;
--
      END LOOP;

      IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'g_dlv_tab.COUNT = '||g_dlv_tab.COUNT
                                                  ||'g_dlv_leg_tab.COUNT = '||g_dlv_leg_tab.COUNT
                                                  ||'g_trip_info_tab.COUNT = '||g_trip_info_tab.COUNT
                                                  ||'g_dleg_trip_tab.COUNT = '||g_dleg_trip_tab.COUNT
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      IF (g_dlv_tab.COUNT > 0 AND g_dlv_tab.EXISTS(p_delivery_id)) THEN
--
         IF ( g_dlv_tab(p_delivery_id).status_code <> 'OP'
              OR ( g_dlv_tab(p_delivery_id).status_code = 'OP'
                   AND g_dlv_tab(p_delivery_id).planned_flag = 'F') ) THEN
--
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.CANCEL_SERVICE',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_DLV_DLV_INV_STATUS',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
         END IF;
      END IF;

      IF (g_trip_info_tab.COUNT > 0 ) THEN
      FOR i in g_trip_info_tab.FIRST .. g_trip_info_tab.LAST
      LOOP
         IF (g_trip_info_tab(i).load_tender_status IS NOT NULL
             AND (g_trip_info_tab(i).load_tender_status = FTE_TENDER_PVT.S_TENDERED
                  OR g_trip_info_tab(i).load_tender_status = FTE_TENDER_PVT.S_ACCEPTED
                  OR g_trip_info_tab(i).load_tender_status = FTE_TENDER_PVT.S_AUTO_ACCEPTED ))
         THEN

           l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.Cancel_Service',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_TRP_TEND_STATUS',
		  p_trip_id            =>     g_trip_info_tab(i).trip_id,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	  IF (l_return_status_1 = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                       x_return_status := l_return_status_1;
	  END IF;

         END IF;
      END LOOP;
      END IF;
      -- Update all trips and erase ship method information
      -- 01/02/03 -- PM wants to unassign trip from delivery also.
      IF (g_trip_info_tab.COUNT > 0 ) THEN
      FOR i in g_trip_info_tab.FIRST .. g_trip_info_tab.LAST
      LOOP
             update_single_trip    (p_trip_id               => g_trip_info_tab(i).trip_id,
                                    p_lane_id               => null,
                                    p_carrier_id            => null,
                                    p_ship_method_code      => null,
                                    p_ship_method_name      => null,
                                    p_service_level         => null,
                                    p_mode_of_transport     => null,
                                    p_vehicle_type_id 	    => null,
				    p_vehicle_item_id	   =>NULL,
				    p_vehicle_org_id	   =>NULL,
                                    x_return_status         => l_return_status,
       	                            x_msg_count	            => l_msg_count,
                                    x_msg_data              => l_msg_data );

	  IF (l_return_status = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                       x_return_status := l_return_status;
	  END IF;

               unassign_trip         ( p_trip_id             => g_trip_info_tab(i).trip_id,
                                       x_return_status       => l_return_status,
       	                               x_msg_count	     => l_msg_count,
            	                       x_msg_data	     => l_msg_data );

	  IF (l_return_status = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                       x_return_status := l_return_status;
	  END IF;

      END LOOP;
      END IF;

        -- Update delivery and erase ship method information
        g_dlv_tab(p_delivery_id).CARRIER_ID        := NULL;
        g_dlv_tab(p_delivery_id).SHIP_METHOD_CODE  := NULL;
        g_dlv_tab(p_delivery_id).SERVICE_LEVEL     := NULL;
        g_dlv_tab(p_delivery_id).MODE_OF_TRANSPORT := NULL;

        l_del_in_rec.caller       := 'FTE';
        l_del_in_rec.phase        := 1;
        l_del_in_rec.action_code  := 'UPDATE';

        WSH_INTERFACE_GRP.Create_Update_Delivery
        ( p_api_version_number     =>1.0,
          p_init_msg_list          =>FND_API.G_FALSE,
          -- p_commit                 =>'F',
          p_commit                 =>FND_API.G_FALSE,
          p_in_rec                 =>l_del_in_rec,
          p_rec_attr_tab           => g_dlv_tab,
          x_del_out_rec_tab        => l_del_out_tab,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data);

           api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.Delivery_Action',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_UPD_DLV_FL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	  IF (l_return_status_1 = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                       x_return_status := l_return_status_1;
	  END IF;

      -- TO DO : Use Table handlers for these

      -- Delete all freight cost records for all delivery legs
      IF (g_dlv_leg_tab.COUNT > 0 ) THEN
      FOR i IN g_dlv_leg_tab.FIRST..g_dlv_leg_tab.LAST
      LOOP
        IF (g_dlv_leg_tab(i).delivery_leg_id IS NOT NULL
            AND g_dlv_leg_tab(i).delivery_id = p_delivery_id)
        THEN

          l_fc_count := 0;

          SELECT count(freight_cost_id) INTO l_fc_count
          FROM WSH_FREIGHT_COSTS
          WHERE delivery_leg_id = g_dlv_leg_tab(i).delivery_leg_id
          AND (
                 ( charge_source_code = 'PRICING_ENGINE'
                   AND line_type_code <> 'SUMMARY'
                  )
               OR
                  (line_type_code = 'SUMMARY'
                   AND delivery_detail_id IS NOT NULL
                   )
              );

          IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'About to update wfc for delivery_leg_id =>'
                                            ||g_dlv_leg_tab(i).delivery_leg_id
                                            ,WSH_DEBUG_SV.C_PROC_LEVEL);
              WSH_DEBUG_SV.log(l_module_name,'l_fc_count=>'||l_fc_count
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          -- TO DO: handle locking issues

          IF (l_fc_count >0) THEN

            DELETE FROM WSH_FREIGHT_COSTS
            WHERE delivery_leg_id = g_dlv_leg_tab(i).delivery_leg_id
            AND (
                 ( charge_source_code = 'PRICING_ENGINE'
                   AND line_type_code <> 'SUMMARY'
                  )
               OR
                  (line_type_code = 'SUMMARY'
                   AND delivery_detail_id IS NOT NULL
                   )
                );

          END IF;

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'wfc records deleted : '||l_fc_count
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          -- update SUMMARY freight cost record and set freight cost type id to -1

          l_freight_cost_id := null;
          OPEN c_get_dleg_summ_recs(g_dlv_leg_tab(i).delivery_leg_id);
          FETCH c_get_dleg_summ_recs INTO l_freight_cost_id;
          CLOSE c_get_dleg_summ_recs;


          IF ( l_freight_cost_id IS NOT NULL ) THEN
            UPDATE wsh_freight_costs
            SET    freight_cost_type_id = -1,
                   charge_source_code = NULL,
                   unit_amount = NULL,
                   total_amount = NULL,
                   currency_code = NULL,
                   last_update_date = SYSDATE,
                   last_updated_by = FND_GLOBAL.USER_ID
            WHERE freight_cost_id = l_freight_cost_id;

            IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'wfc updated : freight_cost_id =>'||l_freight_cost_id
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
          END IF;

        END IF;
      END LOOP;
      END IF;

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CANCEL_SERVICE;
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
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CANCEL_SERVICE;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
	WHEN OTHERS THEN
		ROLLBACK TO CANCEL_SERVICE;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.Cancel_Service');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END Cancel_Service;

  PROCEDURE Cancel_Service  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_delivery_list           	IN  WSH_UTIL_CORE.id_tab_type,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
		       	     x_msg_count	        OUT NOCOPY  NUMBER,
			     x_msg_data	                OUT NOCOPY  VARCHAR2)
  IS
      i NUMBER;
      l_fc_count            NUMBER;
      l_delivery_id         NUMBER;
      l_success_cnt         NUMBER := 0;
      l_error_cnt           NUMBER := 0;
      l_warn_cnt            NUMBER := 0;

      l_return_status       VARCHAR2(1);
      l_return_status_1     VARCHAR2(1);
--
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);
--
      l_number_of_errors            NUMBER;
      l_number_of_warnings	    NUMBER;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'CANCEL_SERVICE2';


  BEGIN

      -- For each delivery, call Cancel_Service
      -- check return status
      -- if all deliveries return success, then return_status = SUCCESS
      -- if all deliveries return error, then return_status = ERROR
      -- if some deliveries return error, then return_status = WARNING

      SAVEPOINT  CANCEL_SERVICE;
--
      x_return_status := FND_API.G_RET_STS_SUCCESS;
--
      IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
      END IF;

       -- supported actions
      IF (p_action <> 'CANCEL') THEN
         -- raise g_invalid_action;
--
               l_return_status := FND_API.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.CANCEL_SERVICE',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_DLV_INV_ACT',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
--
      END IF;

      IF (p_delivery_list.COUNT >0) THEN
      FOR i in p_delivery_list.FIRST .. p_delivery_list.LAST
      LOOP
          l_delivery_id := p_delivery_list(i);
          IF l_debug_on THEN
                   WSH_DEBUG_SV.logmsg(l_module_name,'>>>Now processing delivery_id = '||l_delivery_id
                                                ,WSH_DEBUG_SV.C_PROC_LEVEL);
          END IF;
          Cancel_Service   (
			     p_api_version	      => 1.0,
			     p_delivery_id            => l_delivery_id,
                             p_action                 => 'CANCEL',
                             p_commit                 => p_commit,
                             x_return_status          => l_return_status,
                             x_msg_count              => l_msg_count,
                             x_msg_data               => l_msg_data);

          api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.Cancel_Service',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_CAN_SRV_FL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     l_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	  IF (l_return_status_1 = 'E')
	  THEN
                l_error_cnt := l_error_cnt + 1;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
                l_error_cnt := l_error_cnt + 1;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                l_warn_cnt := l_warn_cnt + 1;
          ELSE
                l_success_cnt := l_success_cnt + 1;
	  END IF;


      END LOOP;
      END IF;

      IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'p_delivery_list.COUNT = '||p_delivery_list.COUNT
                                                 ||'l_success_cnt = '||l_success_cnt
                                                 ||'l_error_cnt   = '||l_error_cnt
                                                 ||'l_warn_cnt    = '||l_warn_cnt
                                                ,WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      IF (l_success_cnt = p_delivery_list.COUNT) THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSIF (l_error_cnt = p_delivery_list.COUNT) THEN
       	  RAISE FND_API.G_EXC_ERROR;
      ELSE
          x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      END IF;

      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
      END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CANCEL_SERVICE;
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
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CANCEL_SERVICE;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
--
	WHEN OTHERS THEN
		ROLLBACK TO CANCEL_SERVICE;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.Cancel_Service');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

  END Cancel_Service;


  PROCEDURE print_delivery_tab
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'print_delivery_tab';
      l_api_name           CONSTANT VARCHAR2(30)   := 'PRINT_DELIVERY_TAB';
     i NUMBER;
  BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN g_dlv_tab -------------');
    i := g_dlv_tab.FIRST;
    IF (i is not null) THEN
    LOOP
      fte_freight_pricing_util.print_msg(l_log_level,'delivery_id='||g_dlv_tab(i).delivery_id);
      fte_freight_pricing_util.print_msg(l_log_level,'ship_method_ocde='||g_dlv_tab(i).ship_method_code);
      fte_freight_pricing_util.print_msg(l_log_level,'initial_pickup_location_id='||g_dlv_tab(i).initial_pickup_location_id);
      fte_freight_pricing_util.print_msg(l_log_level,'ultimate_dropoff_location_id='||g_dlv_tab(i).ultimate_dropoff_location_id);
      fte_freight_pricing_util.print_msg(l_log_level,'initial_pickup_date='||g_dlv_tab(i).initial_pickup_date);
      fte_freight_pricing_util.print_msg(l_log_level,'ultimate_dropoff_date='||g_dlv_tab(i).ultimate_dropoff_date);
      fte_freight_pricing_util.print_msg(l_log_level,'status_code='||g_dlv_tab(i).status_code);
      fte_freight_pricing_util.print_msg(l_log_level,'planned_flag='||g_dlv_tab(i).planned_flag);
      fte_freight_pricing_util.print_msg(l_log_level,'carrier_id='||g_dlv_tab(i).carrier_id);
      fte_freight_pricing_util.print_msg(l_log_level,'mode_of_transport='||g_dlv_tab(i).mode_of_transport);
      fte_freight_pricing_util.print_msg(l_log_level,'service_level='||g_dlv_tab(i).service_level);
      fte_freight_pricing_util.print_msg(l_log_level,'organization_id='||g_dlv_tab(i).organization_id);
      fte_freight_pricing_util.print_msg(l_log_level,'-----------------------');
    EXIT WHEN (i >= g_dlv_tab.LAST);
    i := g_dlv_tab.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.print_msg(l_log_level,'-----------END g_dlv_tab -------------');

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
  WHEN others THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  END print_delivery_tab;

  PROCEDURE print_dleg_tab
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'print_dleg_tab';
      l_api_name           CONSTANT VARCHAR2(30)   := 'PRINT_DLEG_TAB';
     i NUMBER;
  BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN g_dlv_leg_tab -------------');
    i := g_dlv_leg_tab.FIRST;
    IF (i is not null) THEN
    LOOP
      fte_freight_pricing_util.print_msg(l_log_level,'delivery_leg_id='||g_dlv_leg_tab(i).delivery_leg_id);
      fte_freight_pricing_util.print_msg(l_log_level,'delivery_id='||g_dlv_leg_tab(i).delivery_id);
      fte_freight_pricing_util.print_msg(l_log_level,'sequence_number='||g_dlv_leg_tab(i).sequence_number);
      fte_freight_pricing_util.print_msg(l_log_level,'pick_up_stop_id='||g_dlv_leg_tab(i).pick_up_stop_id);
      fte_freight_pricing_util.print_msg(l_log_level,'drop_off_stop_id='||g_dlv_leg_tab(i).drop_off_stop_id);
      fte_freight_pricing_util.print_msg(l_log_level,'reprice_required='||g_dlv_leg_tab(i).reprice_required);
      fte_freight_pricing_util.print_msg(l_log_level,'status_code='||g_dlv_leg_tab(i).status_code);
      fte_freight_pricing_util.print_msg(l_log_level,'parent_delivery_leg_id='||g_dlv_leg_tab(i).parent_delivery_leg_id);
      fte_freight_pricing_util.print_msg(l_log_level,'-----------------------');
    EXIT WHEN (i >= g_dlv_leg_tab.LAST);
    i := g_dlv_leg_tab.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.print_msg(l_log_level,'-----------END g_dlv_leg_tab -------------');

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
  WHEN others THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  END print_dleg_tab;

  PROCEDURE print_trip_tab
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'print_trip_tab';
      l_api_name           CONSTANT VARCHAR2(30)   := 'PRINT_TRIP_TAB';
     i NUMBER;
  BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN g_trip_info_tab -------------');
    i := g_trip_info_tab.FIRST;
    IF (i is not null) THEN
    LOOP
      fte_freight_pricing_util.print_msg(l_log_level,'trip_id='||g_trip_info_tab(i).trip_id);
      fte_freight_pricing_util.print_msg(l_log_level,'name='||g_trip_info_tab(i).name);
      fte_freight_pricing_util.print_msg(l_log_level,'planned_flag='||g_trip_info_tab(i).planned_flag);
      fte_freight_pricing_util.print_msg(l_log_level,'status_code='||g_trip_info_tab(i).status_code);
      fte_freight_pricing_util.print_msg(l_log_level,'carrier_id='||g_trip_info_tab(i).carrier_id);
      fte_freight_pricing_util.print_msg(l_log_level,'ship_method_code='||g_trip_info_tab(i).ship_method_code);
      fte_freight_pricing_util.print_msg(l_log_level,'service_level='||g_trip_info_tab(i).service_level);
      fte_freight_pricing_util.print_msg(l_log_level,'mode_of_transport='||g_trip_info_tab(i).mode_of_transport);
      fte_freight_pricing_util.print_msg(l_log_level,'consolidation_allowed='||g_trip_info_tab(i).consolidation_allowed);
      fte_freight_pricing_util.print_msg(l_log_level,'lane_id='||g_trip_info_tab(i).lane_id);
      fte_freight_pricing_util.print_msg(l_log_level,'schedule_id='||g_trip_info_tab(i).schedule_id);
      fte_freight_pricing_util.print_msg(l_log_level,'load_tender_status='||g_trip_info_tab(i).load_tender_status);
      fte_freight_pricing_util.print_msg(l_log_level,'-----------------------');
    EXIT WHEN (i >= g_trip_info_tab.LAST);
    i := g_trip_info_tab.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.print_msg(l_log_level,'-----------END g_trip_info_tab -------------');

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
  WHEN others THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  END print_trip_tab;

  PROCEDURE print_dleg_trip_tab
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'print_dleg_trip_tab';
      l_api_name           CONSTANT VARCHAR2(30)   := 'PRINT_DLEG_TRIP_TAB';
     i NUMBER;
  BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN g_dleg_trip_tab -------------');
    i := g_dleg_trip_tab.FIRST;
    IF (i is not null) THEN
    LOOP
      fte_freight_pricing_util.print_msg(l_log_level,'delivery_leg_id='||g_dleg_trip_tab(i).delivery_leg_id);
      fte_freight_pricing_util.print_msg(l_log_level,'trip_id='||g_dleg_trip_tab(i).trip_id);
      fte_freight_pricing_util.print_msg(l_log_level,'-----------------------');
    EXIT WHEN (i >= g_dleg_trip_tab.LAST);
    i := g_dleg_trip_tab.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.print_msg(l_log_level,'-----------END g_dleg_trip_tab -------------');

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
  WHEN others THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  END print_dleg_trip_tab;

  PROCEDURE print_matched_lane_tab(p_matched_lane_tab lane_match_tab)
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'print_matched_lane_tab';
      l_api_name           CONSTANT VARCHAR2(30)   := 'PRINT_MATCHED_LANE_TAB';
     i NUMBER;
  BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    fte_freight_pricing_util.print_msg(l_log_level,'-----------BEGIN p_matched_lane_tab -------------');
    i := p_matched_lane_tab.FIRST;
    IF (i is not null) THEN
    LOOP
      fte_freight_pricing_util.print_msg(l_log_level,'trip_id='||p_matched_lane_tab(i).trip_id);
      fte_freight_pricing_util.print_msg(l_log_level,'delivery_leg_id='||p_matched_lane_tab(i).delivery_leg_id);
      fte_freight_pricing_util.print_msg(l_log_level,'delivery_id='||p_matched_lane_tab(i).delivery_id);
      fte_freight_pricing_util.print_msg(l_log_level,'lane_id='||p_matched_lane_tab(i).lane_id);
      fte_freight_pricing_util.print_msg(l_log_level,'ship_method_code='||p_matched_lane_tab(i).ship_method_code);
      fte_freight_pricing_util.print_msg(l_log_level,'ship_method_name='||p_matched_lane_tab(i).ship_method_name);
      fte_freight_pricing_util.print_msg(l_log_level,'carrier_id='||p_matched_lane_tab(i).carrier_id);
      fte_freight_pricing_util.print_msg(l_log_level,'service_level='||p_matched_lane_tab(i).service_level);
      fte_freight_pricing_util.print_msg(l_log_level,'mode_of_transport='||p_matched_lane_tab(i).mode_of_transport);
      fte_freight_pricing_util.print_msg(l_log_level,'new_match='||p_matched_lane_tab(i).new_match);
      fte_freight_pricing_util.print_msg(l_log_level,'-----------------------');
    EXIT WHEN (i >= p_matched_lane_tab.LAST);
    i := p_matched_lane_tab.NEXT(i);
    END LOOP;
    END IF;
    fte_freight_pricing_util.print_msg(l_log_level,'-----------END p_matched_lane_tab -------------');

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
  WHEN others THEN
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  END print_matched_lane_tab;
--
  PROCEDURE validate_nontl_trip    (p_trip_id               IN NUMBER,
                                    x_return_code           OUT NOCOPY  NUMBER)
  IS
    l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_NONTL_TRIP';
    l_return_status       VARCHAR2(30);
    l_return_status_1     VARCHAR2(30);
    l_number_of_errors          NUMBER;
    l_number_of_warnings	    NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_NONTL_TRIP';

    l_dlv_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
    c_dlv_rec             c_delivery%ROWTYPE;
    l_dleg_rec   dlv_leg_info_rec;
    l_trip_info_rec  trip_info_rec;
    l_trip_dleg_cnt  NUMBER;
    l_leg_trip_det_rec    c_leg_trip_det%ROWTYPE;
       l_count	NUMBER;

      c_carr_srv_rec 		c_carrier_services%ROWTYPE;
      l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
      l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
      l_carrier_id 		NUMBER;
      l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
      l_service_level 		wsh_carrier_services.service_level%type;
  BEGIN

    x_return_code := G_RC_SUCCESS;

    IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);

    OPEN c_cnt_trip_legs(p_trip_id);
    FETCH c_cnt_trip_legs INTO l_trip_dleg_cnt;
    CLOSE c_cnt_trip_legs;

    IF (l_trip_dleg_cnt <= 0) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip '||p_trip_id||' has no delivery');
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_TRP_NO_DLV',
		  p_trip_id            =>     p_trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);

	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
    END IF;

    -- check for empty delivery
    l_count := 0;
    OPEN c_count_delivery_details2(p_trip_id);
    FETCH c_count_delivery_details2 INTO l_count;
    CLOSE c_count_delivery_details2;
    IF ( l_count <= 0 ) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'empty delivery');

               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_TRP_NO_DEL_CONTENT',
		  p_trip_id            =>     p_trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);

	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR )
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        END IF;
    END IF;
/*
    -- after autocreate trip for delivery, the reprice required flag on leg is set to 'N'
    -- since lane is null, we do not need to validate reprice required flag on leg.

    l_count := 0;
    OPEN c_count_reprice_reqd(p_trip_id);
    FETCH c_count_reprice_reqd INTO l_count;
    CLOSE c_count_reprice_reqd;

    IF (l_count = 0) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRICING_NOT_REQUIRED',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'reprice not required, do not rate.');
      x_return_code := G_RC_REPRICE_NOT_REQUIRED;
      raise g_finished_warning;
    END IF;
*/
    -- validate freight term
    l_count := 0;
    OPEN c_check_del_freight_term2(p_trip_id);
    FETCH c_check_del_freight_term2 INTO l_count;
    CLOSE c_check_del_freight_term2;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_FGT_TERM',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'do not rate the freight term.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    -- Manifesting validation
    l_count := 0;
    OPEN c_check_del_manifesting2(p_trip_id);
    FETCH c_check_del_manifesting2 INTO l_count;
    CLOSE c_check_del_manifesting2;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_MAN',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery organization is manifesting enabled and carrier is manifesting enabled, do not rate.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    -- populate dleg
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating dleg, trip, delivery info...');

    OPEN c_trip_legs(p_trip_id);
    FETCH c_trip_legs INTO l_dleg_rec;
    CLOSE c_trip_legs;

    g_dlv_leg_tab(l_dleg_rec.delivery_leg_id) := l_dleg_rec;

    g_dleg_trip_tab(l_dleg_rec.delivery_leg_id).delivery_leg_id := l_dleg_rec.delivery_leg_id;
    g_dleg_trip_tab(l_dleg_rec.delivery_leg_id).trip_id := p_trip_id;


    OPEN c_delivery(l_dleg_rec.delivery_id);
    FETCH c_delivery INTO c_dlv_rec;
    CLOSE c_delivery;

    -- store delivery information
    load_dlv_rec (p_dlv_rec => c_dlv_rec, x_dlv_rec => l_dlv_rec);
    g_dlv_tab(l_dleg_rec.delivery_id) := l_dlv_rec;

    IF (g_dlv_tab(l_dleg_rec.delivery_id).ship_method_code is not null)
	AND (g_dlv_tab(l_dleg_rec.delivery_id).carrier_id is null
	  OR g_dlv_tab(l_dleg_rec.delivery_id).mode_of_transport is null
	  OR g_dlv_tab(l_dleg_rec.delivery_id).service_level is null) THEN

      OPEN  c_carrier_services(g_dlv_tab(l_dleg_rec.delivery_id).ship_method_code);
      FETCH c_carrier_services INTO c_carr_srv_rec;
      CLOSE c_carrier_services;

      g_dlv_tab(l_dleg_rec.delivery_id).carrier_id := c_carr_srv_rec.carrier_id;
      g_dlv_tab(l_dleg_rec.delivery_id).mode_of_transport := c_carr_srv_rec.mode_of_transport;
      g_dlv_tab(l_dleg_rec.delivery_id).service_level := c_carr_srv_rec.service_level;

    END IF;


    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
	WHEN g_finished_warning THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END validate_nontl_trip;
--
  PROCEDURE validate_tl_trip       (p_trip_id               IN NUMBER,
                                    x_return_code           OUT NOCOPY  NUMBER)
  IS
    l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'VALIDATE_TL_TRIP';
    l_return_status       VARCHAR2(30);
    l_return_status_1     VARCHAR2(30);
    l_number_of_errors          NUMBER;
    l_number_of_warnings	    NUMBER;
      l_api_name           CONSTANT VARCHAR2(30)   := 'VALIDATE_TL_TRIP';

    l_dlv_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
    c_dlv_rec             c_delivery%ROWTYPE;
    l_dleg_rec   dlv_leg_info_rec;
    l_trip_info_rec  trip_info_rec;
    l_trip_dleg_cnt  NUMBER;
    l_leg_trip_det_rec    c_leg_trip_det%ROWTYPE;
       l_count	NUMBER;

      c_carr_srv_rec 		c_carrier_services%ROWTYPE;
      l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
      l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
      l_carrier_id 		NUMBER;
      l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
      l_service_level 		wsh_carrier_services.service_level%type;
  BEGIN

    x_return_code := G_RC_SUCCESS;

    IF l_debug_on THEN
         wsh_debug_sv.push(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);

    -- validate freight term
    l_count := 0;
    OPEN c_check_del_freight_term2(p_trip_id);
    FETCH c_check_del_freight_term2 INTO l_count;
    CLOSE c_check_del_freight_term2;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_FGT_TERM',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'do not rate the freight term.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    -- Manifesting validation
    l_count := 0;
    OPEN c_check_del_manifesting2(p_trip_id);
    FETCH c_check_del_manifesting2 INTO l_count;
    CLOSE c_check_del_manifesting2;
    IF ( l_count > 0 ) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_NOTRATE_TRP_MAN',
			  p_msg_type		=> 'E',
			  p_trip_id		=> p_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery organization is manifesting enabled and carrier is manifesting enabled, do not rate.');
      x_return_code := G_RC_NOT_RATE_FREIGHT_TERM;
      raise g_finished_warning;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  EXCEPTION
	WHEN g_finished_warning THEN
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_code := G_RC_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END validate_tl_trip;

  PROCEDURE Search_Services(
    p_delivery_leg_id	IN NUMBER DEFAULT NULL,
    p_trip_id		IN NUMBER DEFAULT NULL,
    p_trip_msg_flag	IN VARCHAR2 DEFAULT 'N',
    p_carrier_id	IN NUMBER DEFAULT NULL,
    p_mode_of_transport	IN VARCHAR2 DEFAULT NULL,
    p_service_level	IN VARCHAR2 DEFAULT NULL,
    x_matched_services  OUT NOCOPY  lane_match_tab,
    x_return_status     OUT NOCOPY  VARCHAR2)
  IS
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_return_status           VARCHAR2(1);
      l_return_status_1         VARCHAR2(1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      i NUMBER;
      j NUMBER;

      l_delivery_id         NUMBER;
      l_trip_id             NUMBER;

      c_carr_srv_rec 		c_carrier_services%ROWTYPE;
      l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
      l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
      l_carrier_id 		NUMBER;
      l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
      l_service_level 		wsh_carrier_services.service_level%type;

      l_generic_carrier    	VARCHAR2(1);
      l_initial_pickup_location_id	NUMBER;
      l_ultimate_dropoff_location_id	NUMBER;
      l_initial_pickup_date		DATE;
      l_ultimate_dropoff_date		DATE;

      l_lane_count	NUMBER;
     l_search_criteria fte_search_criteria_rec;
     l_lanes_tab  fte_lane_tab;
     l_lane_rec   fte_lane_rec;
     l_schedules_tab  fte_schedule_tab;

     l_msg            VARCHAR2(240);
     l_status         VARCHAR2(1);
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'SEARCH_SERVICES';
      l_api_name           CONSTANT VARCHAR2(30)   := 'SEARCH_SERVICES';
  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_leg_id='||p_delivery_leg_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_msg_flag='||p_trip_msg_flag);

    IF p_trip_id is not null THEN
      l_trip_id := p_trip_id;
      l_delivery_id := null;
    ELSE -- p_delivery_leg_id is not null
      l_trip_id := g_dleg_trip_tab(p_delivery_leg_id).trip_id;
      l_delivery_id := g_dlv_leg_tab(p_delivery_leg_id).delivery_id;
    END IF; -- p_delivery_leg_id is not null

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_trip_id='||l_trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_delivery_id='||l_delivery_id);

    l_carrier_id := g_trip_info_tab(l_trip_id).carrier_id;
    l_mode_of_transport := g_trip_info_tab(l_trip_id).mode_of_transport;
    l_service_level := g_trip_info_tab(l_trip_id).service_level;
    l_ship_method_code := g_trip_info_tab(l_trip_id).ship_method_code;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ship_method_code='||l_ship_method_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'carrier_id='||l_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'mode_of_transport='||l_mode_of_transport);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'service_level='||l_service_level);

    IF (p_carrier_id is not null) or (p_mode_of_transport is not null)
	or (p_service_level is not null) THEN
      l_carrier_id := p_carrier_id;
      l_mode_of_transport := p_mode_of_transport;
      l_service_level := p_service_level;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'replace the search ship method with input ship method');
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ship_method_code='||l_ship_method_code);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'carrier_id='||l_carrier_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'mode_of_transport='||l_mode_of_transport);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'service_level='||l_service_level);
    END IF;

    IF (l_carrier_id is not NULL) THEN
      OPEN c_get_generic_carrier_flag(l_carrier_id);
      FETCH c_get_generic_carrier_flag INTO l_generic_carrier;
      CLOSE c_get_generic_carrier_flag;

      IF l_generic_carrier = 'Y' THEN
        l_carrier_id := null;
      END IF;
    END IF;

    IF p_trip_id is not null THEN

      OPEN c_trip_first_stop(p_trip_id);
      FETCH c_trip_first_stop INTO l_initial_pickup_location_id, l_initial_pickup_date;
      CLOSE c_trip_first_stop;

      OPEN c_trip_last_stop(p_trip_id);
      FETCH c_trip_last_stop INTO l_ultimate_dropoff_location_id, l_ultimate_dropoff_date;
      CLOSE c_trip_last_stop;

    ELSE -- p_delivery_leg_id is not null

      l_initial_pickup_location_id := g_dlv_tab(l_delivery_id).initial_pickup_location_id;
      l_ultimate_dropoff_location_id := g_dlv_tab(l_delivery_id).ultimate_dropoff_location_id;
      l_initial_pickup_date := g_dlv_tab(l_delivery_id).initial_pickup_date;
      l_ultimate_dropoff_date := g_dlv_tab(l_delivery_id).ultimate_dropoff_date;

    END IF; -- p_delivery_leg_id is not null

    g_ship_date := l_initial_pickup_date;
    g_arrival_date := l_ultimate_dropoff_date;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating search criteria...');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_initial_pickup_location_id='||l_initial_pickup_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ultimate_dropoff_location_id='||l_ultimate_dropoff_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_initial_pickup_date='||l_initial_pickup_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ultimate_dropoff_date='||l_ultimate_dropoff_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_carrier_id='||l_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_mode_of_transport='||l_mode_of_transport);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_service_level='||l_service_level);

    l_search_criteria := fte_search_criteria_rec(
                  relax_flag             => 'Y',
                  origin_loc_id          => l_initial_pickup_location_id,
                  destination_loc_id     => l_ultimate_dropoff_location_id,
                  origin_country         => null,
                  origin_state           => null,
                  origin_city            => null,
                  origin_zip             => null,
                  destination_country    => null,
                  destination_state      => null,
                  destination_city       => null,
                  destination_zip        => null,
                  mode_of_transport      => l_mode_of_transport,
                  lane_number            => null,
                  carrier_id             => l_carrier_id,
                  carrier_name           => null,
                  commodity_catg_id      => null,
                  commodity              => null,
                  service_code           => l_service_level,
                  service                => null,
                  --equipment_code         => null, -- removed J+
                  --equipment              => null, -- removed J+
                  schedule_only_flag     => null,
                  dep_date_from          => l_initial_pickup_date,
                  dep_date_to            => l_initial_pickup_date,
                  arr_date_from          => l_ultimate_dropoff_date,
                  arr_date_to            => l_ultimate_dropoff_date,
                  lane_ids_string        => null,
                  delivery_leg_id        => null,
                  exists_in_database     => null,
                  delivery_id            => null,
                  sequence_number        => null,
                  pick_up_stop_id        => null,
                  drop_off_stop_id       => null,
                  pickupstop_location_id => l_initial_pickup_location_id,
                  dropoffstop_location_id => l_ultimate_dropoff_location_id,
		  ship_to_site_id 	 => null,
		  vehicle_id		 => null,
		  --Changes made to fte_search_criteria_rec 19-FEB-2004
		  effective_date         => l_initial_pickup_date,
		  effective_date_type    => '=',
		  tariff_name		 => null -- Added J+
		  );

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling FTE_LANE_SEARCH.Search_Lanes...');
    FTE_LANE_SEARCH.Search_Lanes(
      p_search_criteria 	=> l_search_criteria,
      p_search_type 		=> 'L',
      p_source_type 		=> 'R',
      p_num_results 		=> 999, -- no limit on the search result
      x_lane_results 		=> l_lanes_tab,
      x_schedule_results 	=> l_schedules_tab,
      x_return_message 		=> l_msg_data,
      x_return_status 		=> l_status);

    IF p_trip_msg_flag = 'Y' THEN
           api_post_call
		(
		  p_api_name           =>     'FTE_LANE_SEARCH.Search_Lanes',
		  p_api_return_status  =>     l_status,
		  p_message_name       =>     'FTE_PRC_TRP_LN_SRCH_FAIL',
		  p_trip_id            =>     l_trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
    ELSE
           api_post_call
		(
		  p_api_name           =>     'FTE_LANE_SEARCH.Search_Lanes',
		  p_api_return_status  =>     l_status,
		  p_message_name       =>     'FTE_PRC_DLV_LN_SRCH_FAIL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     l_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
    END IF;
--
	  IF (l_return_status_1 = 'E')
	  THEN
	  	RAISE FND_API.G_EXC_ERROR;
	  ELSIF (l_return_status_1 = 'U')
	  THEN
	  	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
          THEN
                x_return_status := l_return_status_1;
	  END IF;

/*
  -- for testing
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'manually set up lane results... ');

  l_lanes_tab := fte_lane_tab();

  l_lane_rec := fte_lane_rec(
		lane_id 		=> 1369,
		carrier_id		=> 15451,
		rate_chart_id		=> null,
		mode_of_transport	=> 'LTL',
		origin_id		=> null,
		destination_id		=> null,
		basis			=> null,
		commodity_catg_id	=> null,
		service_code		=> 'D2D',
		comm_fc_class_code	=> null,
		transit_time		=> null,
		transit_time_uom	=> null,
 lane_number		=> null,
 equipment_code		=> null,
 schedules_flag_code	=> null,
 distance		=> null,
 distance_uom		=> null,
 carrier_name		=> null,
 mode_of_transport_code	=> null,
 commodity		=> null,
 equipment		=> null,
 service		=> null,
 schedules_flag		=> null,
 port_of_loading	=> null,
 port_of_discharge	=> null,
 rate_chart_name	=> null,
 owner_id		=> null,
 special_handling	=> null,
 addl_instr		=> null,
 commodity_flag		=> null,
 equipment_flag		=> null,
 service_flag		=> null,
 rate_chart_view_flag	=> null,
 effective_date		=> null,
 expiry_date		=> null,
 origin_region_type	=> null,
 dest_region_type	=> null
			);

  l_lanes_tab.EXTEND;
  i := 1;
  l_lanes_tab(i) := l_lane_rec;

  l_lane_rec := fte_lane_rec(
		lane_id 		=> 1378,
		carrier_id		=> 15453,
		rate_chart_id		=> null,
		mode_of_transport	=> 'LTL',
		origin_id		=> null,
		destination_id		=> null,
		basis			=> null,
		commodity_catg_id	=> null,
		service_code		=> 'D2D',
		comm_fc_class_code	=> null,
		transit_time		=> null,
		transit_time_uom	=> null,
 lane_number		=> null,
 equipment_code		=> null,
 schedules_flag_code	=> null,
 distance		=> null,
 distance_uom		=> null,
 carrier_name		=> null,
 mode_of_transport_code	=> null,
 commodity		=> null,
 equipment		=> null,
 service		=> null,
 schedules_flag		=> null,
 port_of_loading	=> null,
 port_of_discharge	=> null,
 rate_chart_name	=> null,
 owner_id		=> null,
 special_handling	=> null,
 addl_instr		=> null,
 commodity_flag		=> null,
 equipment_flag		=> null,
 service_flag		=> null,
 rate_chart_view_flag	=> null,
 effective_date		=> null,
 expiry_date		=> null,
 origin_region_type	=> null,
 dest_region_type	=> null
			);

  l_lanes_tab.EXTEND;
  i := 2;
  l_lanes_tab(i) := l_lane_rec;
*/
    l_lane_count := l_lanes_tab.COUNT;
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'l_lanes_tab.COUNT =>'||l_lane_count
                                                   ,WSH_DEBUG_SV.C_PROC_LEVEL);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found '||l_lane_count||' lanes');
    IF (l_lane_count > 0) THEN
      j := 0;
      FOR i IN l_lanes_tab.FIRST..l_lanes_tab.LAST LOOP

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found lane_id '||l_lanes_tab(i).lane_id);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found mode_of_transport_code '||l_lanes_tab(i).mode_of_transport_code);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found carrier_id '||l_lanes_tab(i).carrier_id);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found service_code '||l_lanes_tab(i).service_code);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found transit_time '||l_lanes_tab(i).transit_time);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found transit_time_uom '||l_lanes_tab(i).transit_time_uom);
	  l_ship_method_code := null;
	  l_ship_method_meaning := null;
	  IF ((l_delivery_id IS NULL) OR (g_dlv_tab(l_delivery_id).organization_id is null)) THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'del org is null, do not filter ship method by del org');
            OPEN c_get_ship_method(l_lanes_tab(i).carrier_id,l_lanes_tab(i).mode_of_transport_code,l_lanes_tab(i).service_code);
            FETCH c_get_ship_method INTO l_ship_method_code, l_ship_method_meaning;
            CLOSE c_get_ship_method;
	  ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'filtering ship_method by del org '||g_dlv_tab(l_delivery_id).organization_id);
            OPEN c_get_ship_method_code(l_lanes_tab(i).carrier_id,l_lanes_tab(i).mode_of_transport_code,l_lanes_tab(i).service_code, g_dlv_tab(l_delivery_id).organization_id);
            FETCH c_get_ship_method_code INTO l_ship_method_code, l_ship_method_meaning;
            CLOSE c_get_ship_method_code;
	  END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found l_ship_method_code '||l_ship_method_code);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found l_ship_method_meaning '||l_ship_method_meaning);

	  IF (l_ship_method_code is not null) THEN
	    j := j +1;
	    x_matched_services(j).lane_id := l_lanes_tab(i).lane_id;
	    x_matched_services(j).trip_id := l_trip_id;
	    x_matched_services(j).delivery_leg_id := p_delivery_leg_id;
	    x_matched_services(j).delivery_id := l_delivery_id;
	    x_matched_services(j).carrier_id := l_lanes_tab(i).carrier_id;
	    x_matched_services(j).service_level := l_lanes_tab(i).service_code;
	    x_matched_services(j).mode_of_transport := l_lanes_tab(i).mode_of_transport_code;
	    x_matched_services(j).ship_method_code := l_ship_method_code;
	    x_matched_services(j).ship_method_name := l_ship_method_meaning;

	    --For Seq tender ,also copy transit times
	    x_matched_services(j).transit_time:=l_lanes_tab(i).transit_time;
	    x_matched_services(j).transit_time_uom:=l_lanes_tab(i).transit_time_uom;

	  ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'filter out this lane');
	  END IF;

      END LOOP;
    END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END Search_Services;
--

  PROCEDURE populate_shipment(
    p_delivery_leg_id   IN	    NUMBER DEFAULT NULL,
    p_trip_id           IN      NUMBER DEFAULT NULL,
    x_return_status     OUT NOCOPY  VARCHAR2)
  IS
   CURSOR c_get_delivery_from_leg(c_delivery_leg_id IN NUMBER) IS
   Select wdd.delivery_detail_id,
          wda.delivery_id,
          wdl.delivery_leg_id,
          nvl(wdl.reprice_required,'N') as reprice_required,
          wda.parent_delivery_detail_id,
          wdd.customer_id             ,
          wdd.sold_to_contact_id    ,
          wdd.inventory_item_id    ,
          wdd.item_description    ,
          wdd.hazard_class_id    ,
          wdd.country_of_origin ,
          wdd.classification   ,
          wdd.requested_quantity             ,
          wdd.requested_quantity_uom        ,
          wdd.master_container_item_id     ,
          wdd.detail_container_item_id    ,
          wdd.customer_item_id           ,
          wdd.net_weight                ,
          wdd.organization_id          ,
          wdd.container_flag          ,
          wdd.container_type_code    ,
          wdd.container_name        ,
          wdd.fill_percent         ,
          wdd.gross_weight        ,
          wdd.currency_code     ,
          wdd.freight_class_cat_id        ,
          wdd.commodity_code_cat_id      ,
          wdd.weight_uom_code           ,
          wdd.volume                   ,
          wdd.volume_uom_code         ,
          wdd.tp_attribute_category  ,
          wdd.tp_attribute1         ,
          wdd.tp_attribute2        ,
          wdd.tp_attribute3       ,
          wdd.tp_attribute4                        ,
          wdd.tp_attribute5                       ,
          wdd.tp_attribute6                      ,
          wdd.tp_attribute7                     ,
          wdd.tp_attribute8                    ,
          wdd.tp_attribute9                   ,
          wdd.tp_attribute10                 ,
          wdd.tp_attribute11                ,
          wdd.tp_attribute12               ,
          wdd.tp_attribute13              ,
          wdd.tp_attribute14             ,
          wdd.tp_attribute15            ,
          wdd.attribute_category       ,
          wdd.attribute1              ,
          wdd.attribute2             ,
          wdd.attribute3            ,
          wdd.attribute4           ,
          wdd.attribute5          ,
          wdd.attribute6         ,
          wdd.attribute7        ,
          wdd.attribute8       ,
          wdd.attribute9      ,
          wdd.attribute10    ,
          wdd.attribute11   ,
          wdd.attribute12  ,
          wdd.attribute13 ,
          wdd.attribute14,
          wdd.attribute15,
          'FTE',           -- source_type
          NULL,            -- source_line_id
          NULL,            -- source_header_id
          NULL,            -- source_consolidation_id
          NULL,            -- ship_date
          NULL,            -- arrival_date
          NULL,             -- comm_category_id : FTE J estimate rate
	  wda.type,
	  wda.parent_delivery_id,
	  wdl.parent_delivery_leg_id
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda, wsh_delivery_legs wdl,
	  wsh_new_deliveries wd
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wda.delivery_id        = wdl.delivery_id
   and    wdl.delivery_id 	 = wd.delivery_id
   and	  (wda.type IS null  OR wda.type <> 'O')
   and    wdl.delivery_leg_id    = c_delivery_leg_id;

   CURSOR c_get_delivery_from_trip(c_trip_id IN NUMBER) IS
   Select wdd.delivery_detail_id,
          wda.delivery_id,
          wdl.delivery_leg_id,
          nvl(wdl.reprice_required,'N') as reprice_required,
          wda.parent_delivery_detail_id,
          wdd.customer_id             ,
          wdd.sold_to_contact_id    ,
          wdd.inventory_item_id    ,
          wdd.item_description    ,
          wdd.hazard_class_id    ,
          wdd.country_of_origin ,
          wdd.classification   ,
          wdd.requested_quantity             ,
          wdd.requested_quantity_uom        ,
          wdd.master_container_item_id     ,
          wdd.detail_container_item_id    ,
          wdd.customer_item_id           ,
          wdd.net_weight                ,
          wdd.organization_id          ,
          wdd.container_flag          ,
          wdd.container_type_code    ,
          wdd.container_name        ,
          wdd.fill_percent         ,
          wdd.gross_weight        ,
          wdd.currency_code     ,
          wdd.freight_class_cat_id        ,
          wdd.commodity_code_cat_id      ,
          wdd.weight_uom_code           ,
          wdd.volume                   ,
          wdd.volume_uom_code         ,
          wdd.tp_attribute_category  ,
          wdd.tp_attribute1         ,
          wdd.tp_attribute2        ,
          wdd.tp_attribute3       ,
          wdd.tp_attribute4                        ,
          wdd.tp_attribute5                       ,
          wdd.tp_attribute6                      ,
          wdd.tp_attribute7                     ,
          wdd.tp_attribute8                    ,
          wdd.tp_attribute9                   ,
          wdd.tp_attribute10                 ,
          wdd.tp_attribute11                ,
          wdd.tp_attribute12               ,
          wdd.tp_attribute13              ,
          wdd.tp_attribute14             ,
          wdd.tp_attribute15            ,
          wdd.attribute_category       ,
          wdd.attribute1              ,
          wdd.attribute2             ,
          wdd.attribute3            ,
          wdd.attribute4           ,
          wdd.attribute5          ,
          wdd.attribute6         ,
          wdd.attribute7        ,
          wdd.attribute8       ,
          wdd.attribute9      ,
          wdd.attribute10    ,
          wdd.attribute11   ,
          wdd.attribute12  ,
          wdd.attribute13 ,
          wdd.attribute14,
          wdd.attribute15,
          'FTE',           -- source_type
          NULL,            -- source_line_id
          NULL,            -- source_header_id
          NULL,            -- source_consolidation_id
          NULL,            -- ship_date
          NULL,            -- arrival_date
          NULL,             -- comm_category_id : FTE J estimate rate
	  wda.type,
	  wda.parent_delivery_id,
	  wdl.parent_delivery_leg_id
   from   wsh_delivery_details wdd, wsh_delivery_assignments wda, wsh_delivery_legs wdl,
	  wsh_new_deliveries wd, wsh_trips wt, wsh_trip_stops wts1, wsh_trip_stops wts2
   where  wdd.delivery_detail_id = wda.delivery_detail_id
   and    wda.delivery_id        = wdl.delivery_id
   and    wdl.delivery_id 	 = wd.delivery_id
   and 	  wdl.pick_up_stop_id = wts1.stop_id
   and	  wdl.drop_off_stop_id	= wts2.stop_id
   and 	  wts1.trip_id				= wt.trip_id
   and	  (wda.type IS null  OR wda.type <> 'O')
   and    wt.trip_id				= c_trip_id;

   l_delvy_det_rec     fte_freight_pricing.shipment_line_rec_type;
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'POPULATE_SHIPMENT';
      l_api_name           CONSTANT VARCHAR2(30)   := 'POPULATE_SHIPMENT';

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    fte_freight_pricing.g_shipment_line_rows.DELETE;

    IF p_delivery_leg_id IS NOT NULL
    THEN
         OPEN c_get_delivery_from_leg(p_delivery_leg_id);

         LOOP
            FETCH c_get_delivery_from_leg INTO l_delvy_det_rec;
            EXIT WHEN c_get_delivery_from_leg%NOTFOUND;
            fte_freight_pricing.g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
         END LOOP;
         IF c_get_delivery_from_leg%ROWCOUNT = 0 THEN
            CLOSE c_get_delivery_from_leg;
            raise g_pricing_not_required;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Matching number of delivery lines : '||c_get_delivery_from_leg%ROWCOUNT);
         END IF;

         CLOSE c_get_delivery_from_leg;
    ELSIF p_trip_id IS NOT NULL THEN
         OPEN c_get_delivery_from_trip(p_trip_id);

         LOOP
            FETCH c_get_delivery_from_trip INTO l_delvy_det_rec;
            EXIT WHEN c_get_delivery_from_trip%NOTFOUND;
            fte_freight_pricing.g_shipment_line_rows(l_delvy_det_rec.delivery_detail_id) := l_delvy_det_rec;
         END LOOP;
         IF c_get_delivery_from_trip%ROWCOUNT = 0 THEN
            CLOSE c_get_delivery_from_trip;
            raise g_pricing_not_required;
         ELSE
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Matching number of delivery lines : '||c_get_delivery_from_trip%ROWCOUNT);
         END IF;
         CLOSE c_get_delivery_from_trip;

    END IF;

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  EXCEPTION
	WHEN g_pricing_not_required THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_pricing_not_required');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END populate_shipment;




PROCEDURE Tender_Trip(
	p_trip_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2)
IS

	l_msg_count	NUMBER;
	l_msg_data      VARCHAR2(32767);
	l_action_prms FTE_TRIP_ACTION_PARAM_REC;
	l_action_out_rec FTE_ACTION_OUT_REC;
	l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
	l_api_name VARCHAR2(50) := 'Tender_Trip';
	l_return_status VARCHAR2(1);

BEGIN

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);




	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Before calling FTE_MLS_WRAPPER.Trip_Action'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

	l_action_prms:=FTE_TRIP_ACTION_PARAM_REC(
		phase=>NULL,
		action_code=>FTE_TENDER_PVT.S_TENDERED,
		organization_id=>NULL,
		report_set_id=>NULL,
		override_flag=>NULL,
		trip_name=>NULL,
		actual_date=>NULL,
		stop_id=>NULL,
		action_flag=>NULL,
		autointransit_flag=>NULL,
		autoclose_flag=>NULL,
		stage_del_flag=>NULL,
		ship_method=>NULL,
		bill_of_lading_flag=>NULL,
		defer_interface_flag=>NULL,
		actual_departure_date=>NULL
		);


	FTE_MLS_WRAPPER.Trip_Action(
		p_api_version_number=>1,
		p_init_msg_list=>FND_API.G_FALSE,
		p_tripId=>p_trip_id,
		p_action_prms=>l_action_prms,
		x_msg_count=>l_msg_count,
		x_msg_data=>l_msg_data,
		x_action_out_rec=>l_action_out_rec,
		x_return_status=>l_return_status);

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'After calling FTE_MLS_WRAPPER.Trip_Action Return status:'||l_return_status||' Message:'||l_msg_data);




	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

END Tender_Trip;

PROCEDURE Sequential_Tender(
	p_rank_rec IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec,
	p_vehicle_type IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2)
IS

CURSOR get_global_expand_rank_flag IS
SELECT wgp.expand_carrier_rankings
FROM WSH_GLOBAL_PARAMETERS wgp;

CURSOR get_rank_id(c_trip_id IN NUMBER) IS
SELECT t.rank_id
FROM WSH_TRIPS t
WHERE t.trip_id=c_trip_id;


CURSOR c_get_vehicle_item_org (c_vehicle_type_id IN NUMBER)
IS
select 	v.inventory_item_id,
	v.ORGANIZATION_ID
from 	fte_vehicle_types v
where 	v.vehicle_type_id = c_vehicle_type_id;


l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'Sequential_Tender';
l_rank_tab FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_out_rank_tab FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
l_rank_id	NUMBER;
l_append_flag	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data      VARCHAR2(32767);
l_ship_method_meaning VARCHAR2(32767);
l_ship_method_code VARCHAR2(30);
l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
l_api_name VARCHAR2(50) := 'Sequential_Tender';
l_return_status VARCHAR2(1);

l_vehicle_item_id NUMBER;
l_vehicle_org_id NUMBER;

BEGIN


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

	OPEN get_rank_id(p_rank_rec.trip_id);
	FETCH get_rank_id INTO l_rank_id;
	CLOSE get_rank_id;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'RANK ID '||l_rank_id);

	-- If rank_id is null this  means that routing guide produced no results
	-- As a result rating will need to populate the append flag on the trip
	--with the same value as the global expand flag

	l_append_flag:=NULL;
	IF (l_rank_id IS NULL)
	THEN

		OPEN get_global_expand_rank_flag;
		FETCH get_global_expand_rank_flag INTO l_append_flag;
		CLOSE get_global_expand_rank_flag;

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Append flag '||l_append_flag);

	END IF;

	l_vehicle_item_id:=NULL;
	l_vehicle_org_id:=NULL;


	IF (p_vehicle_type IS NOT NULL)
	THEN


		OPEN c_get_vehicle_item_org(p_vehicle_type);
		FETCH c_get_vehicle_item_org INTO l_vehicle_item_id,l_vehicle_org_id;
		CLOSE c_get_vehicle_item_org;


	END IF;




	l_rank_tab(1):=p_rank_rec;

	IF((l_vehicle_item_id IS NOT NULL) AND (l_vehicle_org_id IS NOT NULL))
	THEN
		l_rank_tab(1).vehicle_item_id:=l_vehicle_item_id;
		l_rank_tab(1).vehicle_org_id:=l_vehicle_org_id;

	ELSE
		l_vehicle_item_id:=NULL;
		l_vehicle_org_id:=NULL;


	END IF;

	IF (l_rank_id IS NOT NULL)
	THEN
		l_rank_tab(1).rank_id:=l_rank_id;

	END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Rank record contents');
	FTE_TRIP_RATING_GRP.Display_Rank_Rec(p_rank_rec=>l_rank_tab(1));


	IF(l_rank_id IS NOT NULL)
	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Before calling FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION UPDATE');
		FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION(
			p_api_version_number	=>1,
			p_init_msg_list		=>FND_API.G_FALSE,
			p_action_code		=>FTE_CARRIER_RANK_LIST_PVT.S_UPDATE,
			p_ranklist		=>l_rank_tab,
			p_trip_id		=>p_rank_rec.trip_id,
			p_rank_id		=>l_rank_id,
			x_return_status		=>l_return_status,
			x_msg_count		=>l_msg_count,
			x_msg_data		=>l_msg_data);

	ELSE

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Before calling FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION CREATE');

		l_rank_tab(1).rank_sequence:=1;
		l_rank_tab(1).is_current:='Y';
		l_rank_tab(1).source:=FTE_CARRIER_RANK_LIST_PVT.S_SOURCE_LCSS;

		FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION(
			p_api_version_number	=>1,
			p_init_msg_list		=>FND_API.G_FALSE,
			p_action_code		=>FTE_CARRIER_RANK_LIST_PVT.S_CREATE,
			p_ranklist		=>l_rank_tab,
			p_trip_id		=>p_rank_rec.trip_id,
			p_rank_id		=>NULL,
			x_return_status		=>l_return_status,
			x_msg_count		=>l_msg_count,
			x_msg_data		=>l_msg_data);


	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'After calling FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION Return status:'||l_return_status||' Message:'||l_msg_data);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN

		     raise FTE_FREIGHT_PRICING_UTIL.g_rank_list_update_fail;
		END IF;
	END IF;
	IF ((l_out_rank_tab.FIRST IS NOT NULL) AND(l_out_rank_tab(l_out_rank_tab.FIRST).rank_id IS NOT NULL))
	THEN

		l_rank_id:=l_out_rank_tab(l_out_rank_tab.FIRST).rank_id;
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'RANK ID After calling FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION'||l_rank_id);
	ELSE

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'NO RANK ID After calling FTE_CARRIER_RANK_LIST_PVT.RANK_LIST_ACTION');
		--Commenting out as Rank list API handles update of rank on trip
		--raise FTE_FREIGHT_PRICING_UTIL.g_rank_list_update_fail;

	END IF;




	OPEN c_get_ship_method (p_rank_rec.carrier_id,p_rank_rec.mode_of_transport,p_rank_rec.service_level);
	FETCH c_get_ship_method INTO l_ship_method_code,l_ship_method_meaning;
	CLOSE c_get_ship_method;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'SM Code,meaning:'||l_ship_method_code||':'||l_ship_method_meaning);

	update_single_trip    (p_trip_id               => p_rank_rec.trip_id,
		p_lane_id               => p_rank_rec.lane_id,
		p_carrier_id            => p_rank_rec.carrier_id,
		p_ship_method_code      => l_ship_method_code,
		p_ship_method_name      => l_ship_method_meaning,
		p_service_level         => p_rank_rec.service_level,
		p_mode_of_transport     => p_rank_rec.mode_of_transport,
		p_vehicle_type_id	=> p_vehicle_type,
		p_vehicle_item_id	=> NULL,
		p_vehicle_org_id	=> NULL,
		--p_rank_id		=>l_rank_id, This update is handled by rank list API
		p_append_flag		=>l_append_flag,
		x_return_status         => l_return_status,
		x_msg_count	        => l_msg_count,
		x_msg_data	        => l_msg_data );

	IF (l_return_status = 'E')
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = 'U')
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
	THEN
	       x_return_status := l_return_status;
	END IF;


	Tender_Trip(
		p_trip_id	=>p_rank_rec.trip_id,
		x_return_status	=> l_return_status);

	IF (l_return_status = 'E')
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = 'U')
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


   WHEN FTE_FREIGHT_PRICING_UTIL.g_rank_list_update_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_rank_list_update_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);



END Sequential_Tender;



  PROCEDURE rate_tl_trip  (
	p_trip_id 		IN VARCHAR2,
	p_seq_tender_flag IN VARCHAR2 DEFAULT 'N',
        x_return_status         OUT NOCOPY  VARCHAR2)
  IS
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_TL_TRIP';
      l_api_name           CONSTANT VARCHAR2(30)   := 'RATE_TL_TRIP';
      l_return_status           VARCHAR2(1);
      l_return_status_1         VARCHAR2(1);
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);

    l_lane_rate		  NUMBER;
    l_lane_rate_uom	  VARCHAR2(10);
    l_trip_charge_rec        FTE_TL_CACHE.TL_trip_output_rec_type;
    l_stop_charge_tab        FTE_TL_CACHE.TL_trip_stop_output_tab_type;
    l_cost_alloc_parameters 	FTE_TL_COST_ALLOCATION.TL_allocation_params_rec_type;


    l_lowest_trip_lane_index NUMBER;
    l_lowest_lane_index NUMBER;
    l_lowest_lane_rate NUMBER;
    l_lowest_lane_rate_uom VARCHAR2(10);
    l_lowest_lane_trip_charge_rec        FTE_TL_CACHE.TL_trip_output_rec_type;
    l_lowest_lane_stop_charge_tab        FTE_TL_CACHE.TL_trip_stop_output_tab_type;
    l_lowest_lane_fct        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_all_lane_failed BOOLEAN;
    l_converted_amount	    NUMBER;
    l_vehicle_type NUMBER;

      l_matched_lanes       lane_match_tab;
      l_matched_lane_count	NUMBER;
      l_trip_dleg_cnt		NUMBER;
      l_lane_ids		dbms_utility.number_array;

      c_carr_srv_rec 		c_carrier_services%ROWTYPE;
      l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
      l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
      l_carrier_id 		NUMBER;
      l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
      l_service_level 		wsh_carrier_services.service_level%type;
l_rank_rec FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

      IF (g_trip_info_tab(p_trip_id).lane_id is not null) THEN
	null;
      ELSE -- no lane on trip
    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no lane on trip, searching services...');
  	Search_Services(
	  p_trip_id 	=> p_trip_id,
	  p_trip_msg_flag	=> 'Y',
    	  x_matched_services 	=> l_matched_lanes,
          x_return_status       => l_return_status);

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
	        END IF;

	l_matched_lane_count := l_matched_lanes.COUNT;
	IF (l_matched_lane_count = 0) THEN -- no lane found
    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no lane found');
	  RAISE FND_API.G_EXC_ERROR;
	END IF; -- no lane found
      END IF; -- no lane on trip

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found following lanes...');
	  print_matched_lane_tab(p_matched_lane_tab => l_matched_lanes);

	  l_all_lane_failed := true;

	  -- l_lane_ids as  dbms_utility.number_array
	  FOR i in l_matched_lanes.FIRST..l_matched_lanes.LAST LOOP
	    l_lane_ids(i) := l_matched_lanes(i).lane_id;
	  END LOOP;

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling FTE_TL_RATING.BEGIN_LCSS...');


	FTE_TL_RATING.BEGIN_LCSS (
		p_trip_id=> p_trip_id,
		p_lane_rows => l_lane_ids,
		x_trip_index=> l_lowest_trip_lane_index,
		x_trip_charges_rec=>l_trip_charge_rec,
		x_stop_charges_tab=> l_stop_charge_tab,
		x_total_cost=>l_lane_rate,
		x_currency=>l_lane_rate_uom,
		x_vehicle_type=>l_vehicle_type,
		x_lane_ref=>l_lowest_lane_index,
		x_return_status => l_return_status);

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	IF (l_return_status = 'E')
	THEN
	      RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = 'U')
	THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
	THEN
	       x_return_status := l_return_status;
	END IF;




	IF (l_lowest_trip_lane_index IS NULL)
	THEN


    		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no rates found');

    		FTE_TL_RATING.ABORT_LCSS(x_return_status => l_return_status);

	    	RAISE FND_API.G_EXC_ERROR;

	END IF;


      	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'updating trip with lane_id and shipmethod...');
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip_id='||p_trip_id);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(l_lowest_lane_index).lane_id);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'carrier_id='||l_matched_lanes(l_lowest_lane_index).carrier_id);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship_method_code='||l_matched_lanes(l_lowest_lane_index).ship_method_code);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship_method_name='||l_matched_lanes(l_lowest_lane_index).ship_method_name);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'service_level='||l_matched_lanes(l_lowest_lane_index).service_level);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'mode_of_transport='||l_matched_lanes(l_lowest_lane_index).mode_of_transport);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lowest rate='||l_lane_rate);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lowest_rate curr='||l_lane_rate_uom);


	    IF(p_seq_tender_flag='N')
	    THEN

		    -- update trip with lane_id, ship_method
		    update_single_trip(
			p_trip_id		=> p_trip_id,
			p_lane_id		=> l_matched_lanes(l_lowest_lane_index).lane_id,
			p_carrier_id		=> l_matched_lanes(l_lowest_lane_index).carrier_id,
			p_ship_method_code	=> l_matched_lanes(l_lowest_lane_index).ship_method_code,
			p_ship_method_name	=> l_matched_lanes(l_lowest_lane_index).ship_method_name,
			p_service_level		=> l_matched_lanes(l_lowest_lane_index).service_level,
			p_mode_of_transport	=> l_matched_lanes(l_lowest_lane_index).mode_of_transport,
			p_vehicle_type_id 	    => l_vehicle_type,
			p_vehicle_item_id	   =>NULL,
			p_vehicle_org_id	   =>NULL,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data);

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

			IF (l_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
			THEN
			       x_return_status := l_return_status;
			END IF;

		ELSE


			l_rank_rec.trip_id:=p_trip_id;
			l_rank_rec.lane_id:=l_matched_lanes(l_lowest_lane_index).lane_id;
			l_rank_rec.carrier_id:=l_matched_lanes(l_lowest_lane_index).carrier_id;
			l_rank_rec.service_level:=l_matched_lanes(l_lowest_lane_index).service_level;
			l_rank_rec.mode_of_transport:=l_matched_lanes(l_lowest_lane_index).mode_of_transport;
			l_rank_rec.estimated_rate:=l_lane_rate;
			l_rank_rec.currency_code:=l_lane_rate_uom;
			l_rank_rec.estimated_transit_time:=l_matched_lanes(l_lowest_lane_index).transit_time;
			l_rank_rec.transit_time_uom:=l_matched_lanes(l_lowest_lane_index).transit_time_uom;

			Sequential_Tender(
				p_rank_rec=>l_rank_rec,
				p_vehicle_type=>l_vehicle_type,
				x_return_status=>l_return_status);


			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

			IF (l_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
			THEN
			       x_return_status := l_return_status;
			END IF;



		END IF;


	FTE_TL_RATING.END_LCSS (
		p_trip_index=> l_lowest_trip_lane_index,
		p_trip_charges_rec=>l_trip_charge_rec,
		p_stop_charges_tab=> l_stop_charge_tab,
		x_return_status => l_return_status);


	IF (l_return_status = 'E')
	THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = 'U')
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
	THEN
	       x_return_status := l_return_status;
	END IF;


	 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling Trip_Select_Service_Init for trip:'||p_trip_id||'At:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

	 FTE_WORKFLOW_UTIL.Trip_Select_Service_Init(
		p_trip_id           =>p_trip_id,
		x_return_status     =>l_return_status);

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip_Select_Service_Init return_status:'||l_return_status||'At:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));



    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  EXCEPTION
	WHEN g_finished_success THEN
    	  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END rate_tl_trip;

  PROCEDURE rate_trip2  (
                         p_trip_id			IN  NUMBER,
                         p_seq_tender_flag		IN VARCHAR2 DEFAULT 'N',
                         x_return_status            OUT NOCOPY  VARCHAR2)
  IS
--
    l_api_name           CONSTANT VARCHAR2(30)   := 'RATE_TRIP2';
    l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
    l_return_status           VARCHAR2(1);
    l_return_code             NUMBER;
    l_return_status_1         VARCHAR2(1);
    --
    i                         NUMBER;
    j                         NUMBER;
    k                         NUMBER;
    l_dlv_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
    l_leg_count           NUMBER := 0;
    l_dlv_leg_list        WSH_UTIL_CORE.id_tab_type;
    l_lane_ids            WSH_UTIL_CORE.id_tab_type;
    l_trip_ids            WSH_UTIL_CORE.id_tab_type;
    l_lane_ret_code       NUMBER;
    l_delivery_leg_id     NUMBER;
    l_delivery_id         NUMBER;
    l_dleg_id     	    NUMBER;
    l_trip_id             NUMBER;
    l_lane_id             NUMBER;
    l_leg_trip_det_rec    trip_info_rec;
    l_matched_lanes       lane_match_tab;
    l_lane_match_rec      lane_match_rec;
    l_prc_in_rec          FTE_FREIGHT_PRICING.FtePricingInRecType;
    l_dummy               VARCHAR2(1);
    l_matched_lane_count	NUMBER;
    --
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(32767);
    --
    l_number_of_errors          NUMBER;
    l_number_of_warnings	    NUMBER;
    l_commit                 VARCHAR2(100) := FND_API.G_FALSE;
    l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
    l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_TRIP2';

    l_lane_rate		  NUMBER;
    l_lane_rate_uom	  VARCHAR2(10);
    l_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lowest_lane_index NUMBER;
    l_lowest_lane_rate NUMBER;
    l_lowest_lane_rate_uom VARCHAR2(10);
    l_lowest_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lowest_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_all_lane_failed BOOLEAN;
    l_converted_amount	    NUMBER;
    l_currency_code         VARCHAR2(30);

    l_tl_rating_flag	VARCHAR2(1);
    c_carr_srv_rec 		c_carrier_services%ROWTYPE;
    l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
    l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
    l_carrier_id 		NUMBER;
    l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
    l_service_level 		wsh_carrier_services.service_level%type;

    l_org_manifest_enabled		VARCHAR2(1);
    l_carrier_manifest_enabled 	VARCHAR2(1);
    l_rank_rec FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;


--
  BEGIN
--
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_trip_id '|| p_trip_id,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);

    g_dlv_tab.DELETE;
    g_dlv_leg_tab.DELETE;
    g_trip_info_tab.DELETE;
    g_dleg_trip_tab.DELETE;
    l_matched_lanes.DELETE;

      -- populate trip table
      -- g_trip_info has one trip
      OPEN c_trip_info(p_trip_id);
      FETCH c_trip_info INTO l_leg_trip_det_rec;
      CLOSE c_trip_info;

      g_trip_info_tab(p_trip_id) := l_leg_trip_det_rec;

      print_trip_tab();

    -- FTE_TRIP_RATING_GRP.Rate_Trip calls Rate_Delivery with trip_id only if
    -- full ship method and lane id is null on the trip

    l_ship_method_code := g_trip_info_tab(p_trip_id).ship_method_code;
    l_carrier_id := g_trip_info_tab(p_trip_id).carrier_id;
    l_mode_of_transport := g_trip_info_tab(p_trip_id).mode_of_transport;
    l_service_level := g_trip_info_tab(p_trip_id).service_level;
    l_lane_id := g_trip_info_tab(p_trip_id).lane_id;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_ship_method_code='||l_ship_method_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_carrier_id='||l_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_mode_of_transport='||l_mode_of_transport);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_service_level='||l_service_level);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_id='||l_lane_id);

        --IF l_ship_method_code is null OR l_carrier_id is null OR l_mode_of_transport is null
    IF l_carrier_id is null OR l_mode_of_transport is null
    OR l_service_level is null OR l_lane_id is not null THEN
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'should have full ship method and lane is null to reach this point!!!');
        raise FND_API.G_EXC_ERROR;
    END IF;


      IF (l_mode_of_transport = 'TRUCK') THEN
        l_tl_rating_flag := 'Y';

      validate_tl_trip(
	p_trip_id 	=> p_trip_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_code = G_RC_REPRICE_NOT_REQUIRED THEN
	raise g_finished_success;
      ELSIF (l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;

      	rate_tl_trip(
	  p_trip_id 		=> p_trip_id,
          x_return_status       => l_return_status);

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
		  raise g_finished_warning;
	        END IF;

		raise g_finished_success;

      ELSE -- mode_of_transport <> 'TRUCK'
        l_tl_rating_flag := 'N';
      END IF;

      IF (l_leg_trip_det_rec.lane_id is not null) THEN
	null;
      ELSE -- no lane on trip

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no lane on trip, validating trip...');
      validate_nontl_trip(
	p_trip_id 	=> p_trip_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_code = G_RC_REPRICE_NOT_REQUIRED THEN
	raise g_finished_success;
      ELSIF (l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;

      END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'done with validation, here is what we got...');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_tl_rating_flag='||l_tl_rating_flag);

    print_delivery_tab();
    print_dleg_tab();
    print_trip_tab();
    print_dleg_trip_tab();

    l_leg_count := g_dlv_leg_tab.COUNT;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'total '||l_leg_count||' delivery legs');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through delivery legs...');

    l_dleg_id := g_dlv_leg_tab.FIRST;
    --FOR l_dleg_id IN g_dlv_leg_tab.FIRST .. g_dlv_leg_tab.LAST
    --LOOP
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ldeg_id='||l_dleg_id);
      l_trip_id := g_dleg_trip_tab(l_dleg_id).trip_id;
      l_lane_id := g_trip_info_tab(l_trip_id).lane_id;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_trip_id='||l_trip_id);
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_id='||l_lane_id);

         -- Need to delete existing freight cost records
         -- for this delivery leg

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'deleting existing freight cost records...');

	FTE_TRIP_RATING_GRP.Delete_Main_Records(
		p_trip_id=>l_trip_id,
		p_init_prc_log=>'N',
		x_return_status   =>  l_return_status ) ;

         --fte_freight_pricing.delete_invalid_fc_recs (
         --    p_delivery_leg_id =>  l_dleg_id,
         --    x_return_status   =>  l_return_status ) ;

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
	        END IF;

      IF (l_lane_id is not null) THEN
    	null;
      ELSE -- no lane on trip

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no lane on trip, searching services...');
  	    Search_Services(
        --p_delivery_leg_id 	=> l_dleg_id,
	p_trip_id=>l_trip_id,--MDC
        p_trip_msg_flag	=> l_tl_rating_flag,
        x_matched_services 	=> l_matched_lanes,
        x_return_status       => l_return_status);

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
	        END IF;

	l_matched_lane_count := l_matched_lanes.COUNT;
	IF (l_matched_lane_count = 0) THEN -- no lane found

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no services found.');
	  RAISE FND_API.G_EXC_ERROR;

	ELSE -- found lane

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found following lanes...');
	  print_matched_lane_tab(p_matched_lane_tab => l_matched_lanes);

	  l_all_lane_failed := true;

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating shipment...');
	  /*
  	  populate_shipment(
            p_delivery_leg_id 	=> l_dleg_id,
            x_return_status     => l_return_status);
	   */
	  populate_shipment(
	    p_trip_id 	=> l_trip_id,
	    x_return_status     => l_return_status);


    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
	        END IF;

	  FOR i IN l_matched_lanes.FIRST..l_matched_lanes.LAST LOOP

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rate shipment on lane '||l_matched_lanes(i).lane_id||'...');

         FTE_FREIGHT_PRICING_UTIL.get_currency_code
         (
            p_trip_id       => p_trip_id,
            p_carrier_id    => l_matched_lanes(i).carrier_id,
            x_currency_code => l_currency_code,
            x_return_status => l_return_status
          );


        fte_freight_pricing.shipment_rating
        (
            p_lane_id                       => l_matched_lanes(i).lane_id,
            p_service_type                  => l_matched_lanes(i).service_level,
            p_mode_of_transport             => l_matched_lanes(i).mode_of_transport,
            p_ship_date                     => g_ship_date,
            p_arrival_date                  => g_arrival_date,
            p_currency_code                 => l_currency_code,
            x_summary_lanesched_price       => l_lane_rate,
            x_summary_lanesched_price_uom   => l_lane_rate_uom,
            x_freight_cost_temp_price       => l_lane_fct_price,
            x_freight_cost_temp_charge      => l_lane_fct_charge,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data
        );

	    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
		AND (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

	      -- shipment_rating failed
      	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment rating failed');
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||i);
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(i).lane_id);

	      --FTE_FREIGHT_PRICING_UTIL.setmsg(
		--	  p_api			=> l_module_name,
		--	  p_exc			=> ' ',
		--	  p_msg_name		=> 'FTE_PRC_RATE_TRP_LANE_FL',
		--	  p_msg_type		=> 'E',
		--	  p_trip_id		=> p_trip_id,
		--	  p_lane_id		=> l_matched_lanes(i).lane_id);

	    ELSE -- shipment_rating success or warning

    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating success');
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||i);
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(i).lane_id);
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate='||l_lane_rate);
    	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate_uom='||l_lane_rate_uom);

	      IF (l_all_lane_failed) THEN

		l_lowest_lane_index := i;
		l_lowest_lane_rate := l_lane_rate;
		l_lowest_lane_rate_uom := l_lane_rate_uom;
		l_lowest_lane_fct_price := l_lane_fct_price;
		l_lowest_lane_fct_charge := l_lane_fct_charge;
		l_all_lane_failed := false;

	      ELSE  -- l_all_lane_failed = false
		--compare with current lowest cost lane;

	        IF (l_lowest_lane_rate_uom <> l_lane_rate_uom) THEN
	          convert_amount(
     		    p_from_currency		=>l_lane_rate_uom,
     		    p_from_amount		=>l_lane_rate,
     		    p_to_currency		=>l_lowest_lane_rate_uom,
		    x_to_amount			=>l_converted_amount,
		    x_return_status		=> l_return_status);

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
	        END IF;

	        ELSE
		  l_converted_amount := l_lane_rate;
	        END IF;
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_converted_amount='||l_converted_amount);
		IF (l_lowest_lane_rate > l_converted_amount) THEN
		  l_lowest_lane_index := i;
		  l_lowest_lane_rate := l_lane_rate;
		  l_lowest_lane_rate_uom := l_lane_rate_uom;
		  l_lowest_lane_fct_price := l_lane_fct_price;
		  l_lowest_lane_fct_charge := l_lane_fct_charge;
		END IF;

	      END IF;  -- l_all_lane_failed = false

              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_index='||l_lowest_lane_index);
              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_id='||l_matched_lanes(l_lowest_lane_index).lane_id);
              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate='||l_lowest_lane_rate);
              FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate_uom='||l_lowest_lane_rate_uom);
	    END IF;  -- shipment_rating success or warning

	  END LOOP; -- matched_lane loop

	  IF (l_all_lane_failed) THEN

    	  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no rates found.');
	  RAISE FND_API.G_EXC_ERROR;

	  ELSE

      	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'updating trip with lane_id and shipmethod...');
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip_id='||l_trip_id);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(l_lowest_lane_index).lane_id);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'carrier_id='||l_matched_lanes(l_lowest_lane_index).carrier_id);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship_method_code='||l_matched_lanes(l_lowest_lane_index).ship_method_code);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship_method_name='||l_matched_lanes(l_lowest_lane_index).ship_method_name);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'service_level='||l_matched_lanes(l_lowest_lane_index).service_level);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'mode_of_transport='||l_matched_lanes(l_lowest_lane_index).mode_of_transport);
	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate='||l_lowest_lane_rate);
	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate_uom='||l_lowest_lane_rate_uom);


	    IF(p_seq_tender_flag='N')
	    THEN

		    -- update trip with lane_id, ship_method
		    update_single_trip(
			p_trip_id		=> l_trip_id,
			p_lane_id		=> l_matched_lanes(l_lowest_lane_index).lane_id,
			p_carrier_id		=> l_matched_lanes(l_lowest_lane_index).carrier_id,
			p_ship_method_code	=> l_matched_lanes(l_lowest_lane_index).ship_method_code,
			p_ship_method_name	=> l_matched_lanes(l_lowest_lane_index).ship_method_name,
			p_service_level		=> l_matched_lanes(l_lowest_lane_index).service_level,
			p_mode_of_transport	=> l_matched_lanes(l_lowest_lane_index).mode_of_transport,
			p_vehicle_type_id 	    => null,
			p_vehicle_item_id	   =>NULL,
			p_vehicle_org_id	   =>NULL,
			x_return_status		=> l_return_status,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_msg_data);

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

			IF (l_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
			THEN
			       x_return_status := l_return_status;
			END IF;
		ELSE

			l_rank_rec.trip_id:=l_trip_id;
			l_rank_rec.lane_id:=l_matched_lanes(l_lowest_lane_index).lane_id;
			l_rank_rec.carrier_id:=l_matched_lanes(l_lowest_lane_index).carrier_id;
			l_rank_rec.service_level:=l_matched_lanes(l_lowest_lane_index).service_level;
			l_rank_rec.mode_of_transport:=l_matched_lanes(l_lowest_lane_index).mode_of_transport;

			l_rank_rec.estimated_rate:=l_lowest_lane_rate;
			l_rank_rec.mode_of_transport:=l_lowest_lane_rate_uom;

			l_rank_rec.estimated_transit_time:=l_matched_lanes(l_lowest_lane_index).transit_time;
			l_rank_rec.transit_time_uom:=l_matched_lanes(l_lowest_lane_index).transit_time_uom;


			Sequential_Tender(
				p_rank_rec=>l_rank_rec,
				p_vehicle_type=>NULL,
				x_return_status=>l_return_status);


			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

			IF (l_return_status = 'E')
			THEN
				RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
			THEN
			       x_return_status := l_return_status;
			END IF;


		END IF;

      	    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'move freight costs to main...');
  	    -- update wsh_freight_costs with l_lowest_rate
	    fte_freight_pricing.Move_fc_temp_to_main (
		p_delivery_leg_id	   => l_dleg_id,
        	p_freight_cost_temp_price  => l_lowest_lane_fct_price,
        	p_freight_cost_temp_charge => l_lowest_lane_fct_charge,
        	x_return_status            => l_return_status);

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
	        END IF;

		 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling Trip_Select_Service_Init for trip:'||l_trip_id||'At:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

		 FTE_WORKFLOW_UTIL.Trip_Select_Service_Init(
		 	p_trip_id           =>l_trip_id,
            		x_return_status     =>l_return_status);

            	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip_Select_Service_Init return_status:'||l_return_status||'At:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));


	  END IF;

	END IF; -- found lane

      END IF; -- no lane on trip

--MDC making all the calles trip centric
--    EXIT WHEN l_dleg_id = g_dlv_leg_tab.LAST;
--    l_dleg_id  := g_dlv_leg_tab.NEXT(l_dleg_id);
--    END LOOP; -- dleg loop


--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

EXCEPTION


WHEN g_finished_warning THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN g_finished_success THEN

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  END rate_trip2;

  -- J+ Added new input parameters:
  -- p_carrier_id, p_mode_of_transport, p_service_level
  -- assumes that input ship method is validated by the caller and will be used to
  -- search the services if any of them is not null
  PROCEDURE Rate_Delivery  (
                 p_api_version          IN NUMBER DEFAULT 1.0,
                 p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                 p_delivery_id          IN  NUMBER DEFAULT NULL,
                 p_trip_id              IN  NUMBER DEFAULT NULL,
                 p_action               IN  VARCHAR2 DEFAULT 'RATE',
                 p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                 p_init_prc_log         IN  VARCHAR2 DEFAULT 'Y',
                 p_carrier_id           IN NUMBER DEFAULT NULL,
                 p_mode_of_transport    IN VARCHAR2 DEFAULT NULL,
                 p_service_level        IN VARCHAR2 DEFAULT NULL,
                 p_seq_tender_flag      IN VARCHAR2 DEFAULT 'N',
                 x_return_status        OUT NOCOPY  VARCHAR2,
                 x_msg_count            OUT NOCOPY  NUMBER,
                 x_msg_data             OUT NOCOPY  VARCHAR2)
  IS
--
      l_api_version	CONSTANT NUMBER := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)   := 'RATE_DELIVERY';
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_return_status           VARCHAR2(1);
      l_return_code             NUMBER;
      l_return_status_1         VARCHAR2(1);
--
      i                         NUMBER;
      j                         NUMBER;
      k                         NUMBER;
      l_dlv_rec             WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
      l_leg_count           NUMBER := 0;
      l_dlv_leg_list        WSH_UTIL_CORE.id_tab_type;
      l_lane_ids            WSH_UTIL_CORE.id_tab_type;
      l_trip_ids            WSH_UTIL_CORE.id_tab_type;
      l_lane_ret_code       NUMBER;
      l_delivery_leg_id     NUMBER;
      l_delivery_id         NUMBER;
      l_dleg_id     	    NUMBER;
      l_trip_id             NUMBER;
      l_lane_id             NUMBER;
      l_leg_trip_det_rec    trip_info_rec;
      l_matched_lanes       lane_match_tab;
      l_lane_match_rec      lane_match_rec;
      l_prc_in_rec          FTE_FREIGHT_PRICING.FtePricingInRecType;
      l_dummy               VARCHAR2(1);
      l_matched_lane_count	NUMBER;
--
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);
--
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_commit                 VARCHAR2(100) := FND_API.G_FALSE;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_DELIVERY';

    l_lane_rate		  NUMBER;
    l_lane_rate_uom	  VARCHAR2(10);
    l_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lowest_lane_index NUMBER;
    l_lowest_lane_rate NUMBER;
    l_lowest_lane_rate_uom VARCHAR2(10);
    l_lowest_lane_fct_price        fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_lowest_lane_fct_charge       fte_freight_pricing.Freight_Cost_Temp_Tab_Type;
    l_all_lane_failed BOOLEAN;
    l_converted_amount	    NUMBER;

    l_tl_rating_flag	VARCHAR2(1);
    l_tl_lower	BOOLEAN;
    l_vehicle_type NUMBER;
    l_tl_lane_rows dbms_utility.number_array;
    l_tl_lane_refs dbms_utility.number_array;


    l_lowest_tl_trip_index   NUMBER;
    l_trip_charge_rec FTE_TL_CACHE.TL_trip_output_rec_type;
    l_stop_charge_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;

    l_tl_lane_rate   NUMBER;
    l_tl_lane_curr VARCHAR2(10);
    l_lowest_tl_lane_index   NUMBER;
    l_rank_rec FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec;


    c_carr_srv_rec 		c_carrier_services%ROWTYPE;
    l_ship_method_code 	wsh_carrier_services.ship_method_code%type;
    l_ship_method_meaning 	wsh_carrier_services.ship_method_meaning%type;
    l_carrier_id 		NUMBER;
    l_mode_of_transport 	wsh_carrier_services.mode_of_transport%type;
    l_service_level 		wsh_carrier_services.service_level%type;

    l_carrier_name		hz_parties.party_name%type;
    l_mode_of_transport2	fnd_lookup_values_vl.meaning%type;
    l_service_level2		fnd_lookup_values_vl.meaning%type;

    l_del_has_trip			VARCHAR2(1) := 'N';
    l_del_org_manifest_enabled	VARCHAR2(1) := 'N';
    l_carrier_manifest_enabled 	VARCHAR2(1) := 'N';

    l_del_out_tab         WSH_DELIVERIES_GRP.Del_Out_Tbl_Type;
    l_del_in_rec          WSH_DELIVERIES_GRP.Del_In_Rec_Type;
    l_seq_tender_flag VARCHAR2(1);
    l_action_params           FTE_TRIP_RATING_GRP.action_param_rec;
    l_temp_trips_tab          WSH_UTIL_CORE.id_tab_type;
    l_currency_code           VARCHAR2(30);

--
  BEGIN
--
--
--
    SAVEPOINT  RATE_DELIVERY;
--
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
                         (
                           l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME
                          )
    THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      		FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;
--
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_delivery_id '|| p_delivery_id,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_trip_id '|| p_trip_id,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_action '|| p_action,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_commit '|| p_commit,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

    IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.initialize_logging( x_return_status  => l_return_status );

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
        api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_PRICING_UTIL.initialize_logging',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_INIT_LOG_FL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;

    ELSE
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Initialize Logging successful ');
    END IF;
    END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_id='||p_delivery_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_id='||p_trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_action='||p_action);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_commit='||p_commit);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_carrier_id='||p_carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_mode_of_transport='||p_mode_of_transport);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_service_level='||p_service_level);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_seq_tender_flag='||p_seq_tender_flag);


    -- If delivery id is passed in and it has multiple legs set flag to N
    l_seq_tender_flag:=p_seq_tender_flag;

    --R12 Hiding Project
    l_seq_tender_flag:='N';


    -- supported actions
    IF (p_action <> 'RATE') THEN
      -- raise g_invalid_action;
--
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'invalid action');

               l_return_status := FND_API.G_RET_STS_ERROR;
        api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_DLV_INV_ACT',
		  p_trip_id            =>     p_trip_id,
		  p_delivery_id        =>     p_delivery_id,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
--
    END IF;
--
    IF (p_delivery_id is null and p_trip_id is null) THEN
      -- invalid parameters;
--
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'invalid input parameters');

               l_return_status := FND_API.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     'FTE_FREIGHT_RATING_DLVY_GRP.RATE_DELIVERY',
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_INV_PARM',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
--
    END IF;
--
--
    g_dlv_tab.DELETE;
    g_dlv_leg_tab.DELETE;
    g_trip_info_tab.DELETE;
    g_dleg_trip_tab.DELETE;
    l_matched_lanes.DELETE;

    IF (p_delivery_id is not null) THEN

      l_tl_rating_flag := 'N';

      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'validating delivery...');

      validate_delivery(
	p_delivery_id 	=> p_delivery_id,
	x_return_code => l_return_code);

      IF l_return_code = G_RC_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_code = G_RC_REPRICE_NOT_REQUIRED THEN
	raise g_finished_success;
      ELSIF (l_return_code = G_RC_NOT_RATE_FREIGHT_TERM
	     OR l_return_code = G_RC_NOT_RATE_MANIFESTING) THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
	raise g_finished_warning;
      END IF;

      OPEN c_get_del_manifest_enabled(p_delivery_id);
      FETCH c_get_del_manifest_enabled INTO l_del_org_manifest_enabled;
      CLOSE c_get_del_manifest_enabled;

      l_leg_count := g_dlv_leg_tab.COUNT;
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'total '||l_leg_count||' delivery legs');

      IF (l_leg_count > 1)
      THEN
      --For multileg deliveries dont perform seq tendering
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Multileg delivery setting seq_tender flag to N');
	l_seq_tender_flag:='N';
      END IF;

      IF (l_leg_count <= 0) THEN

	-- auto-create trip for delivery
      	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'auto-creating trip for delivery...');
        create_trip(
          p_delivery_id          => p_delivery_id,
          x_trip_id              => l_trip_id,
          x_delivery_leg_id      => l_delivery_leg_id,
          x_return_status        => l_return_status);

    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	       IF (l_return_status = 'E')
	       THEN
		       RAISE FND_API.G_EXC_ERROR;
	       ELSIF (l_return_status = 'U')
	       THEN
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
               THEN
                       x_return_status := l_return_status;
	       END IF;

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip_id='||l_trip_id);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'delivery_leg_id='||l_delivery_leg_id);

      ELSE
	l_del_has_trip := 'Y';
      END IF; -- l_leg_count <= 0

    ELSE -- p_trip_id is not null

      rate_trip2(
      p_trip_id 		=> p_trip_id,
      p_seq_tender_flag	=>l_seq_tender_flag,
          x_return_status       => l_return_status);

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

	        IF (l_return_status = 'E')
	        THEN
	     	      RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status = 'U')
	        THEN
	  	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
		  raise g_finished_warning;
	        END IF;

		raise g_finished_success;

    END IF;

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'done with validation, here is what we got...');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_tl_rating_flag='||l_tl_rating_flag);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_del_has_trip='||l_del_has_trip);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_del_org_manifest_enabled='||l_del_org_manifest_enabled);

    print_delivery_tab();
    print_dleg_tab();
    print_trip_tab();
    print_dleg_trip_tab();

    l_leg_count := g_dlv_leg_tab.COUNT;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'total '||l_leg_count||' delivery legs');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'looping through delivery legs...');


   /* l_dleg_id := g_dlv_leg_tab.FIRST;
    LOOP
    IF (g_dlv_leg_tab(l_dleg_id).parent_delivery_leg_id IS NULL)
    THEN
        IF l_trips_to_rate_ids.COUNT > 0 THEN
        FOR i IN l_trips_to_rate_ids.FIRST..l_trips_to_rate_ids.LAST
        LOOP
            IF g_dleg_trip_tab(l_dleg_id).trip_id <> l_trips_to_rate_ids(i) THEN
                l_trips_to_rate_ids.EXTEND;
                l_trips_to_rate_ids(l_trips_to_rate_ids.LAST) := g_dleg_trip_tab(l_dleg_id).trip_id;
            END IF;
        END LOOP;
    EXIT WHEN l_dleg_id = g_dlv_leg_tab.LAST;
    l_dleg_id := g_dlv_leg_tab.NEXT(l_dleg_id);
    END LOOP; -- dleg loop
*/
    l_dleg_id := g_dlv_leg_tab.FIRST;

    -- Modified for R12 to do Trip level rating to support multileg deliveries
    --Get the Trip for Delivery Leg and rate the trip
    --FOR l_dleg_id IN g_dlv_leg_tab.FIRST .. g_dlv_leg_tab.LAST

    LOOP
	IF (g_dlv_leg_tab(l_dleg_id).parent_delivery_leg_id IS NULL)
	THEN

	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ldeg_id='||l_dleg_id);
	      l_trip_id := g_dleg_trip_tab(l_dleg_id).trip_id;
	      l_lane_id := g_trip_info_tab(l_trip_id).lane_id;
	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_trip_id='||l_trip_id);
	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_id='||l_lane_id);

		 -- Need to delete existing freight cost records
		 -- for this delivery leg

	      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'deleting existing freight cost records...');


		FTE_TRIP_RATING_GRP.Delete_Main_Records(
			p_trip_id=>l_trip_id,
			p_init_prc_log=>'N',
			x_return_status   =>  l_return_status ) ;


		 --fte_freight_pricing.delete_invalid_fc_recs (
		 --    p_delivery_leg_id =>  l_dleg_id,
		 --    x_return_status   =>  l_return_status ) ;

		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

			IF (l_return_status = 'E')
			THEN
			      RAISE FND_API.G_EXC_ERROR;
			ELSIF (l_return_status = 'U')
			THEN
			      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
			THEN
			       x_return_status := l_return_status;
			END IF;



	      IF (l_lane_id is not null) THEN
	    	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip '||l_trip_id||' already has a lane '||l_lane_id);
		    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rate as in Pack I');

               -- lock delivery leg
               SELECT reprice_required INTO l_dummy
               FROM   wsh_delivery_legs
               WHERE  delivery_leg_id = l_dleg_id
               FOR UPDATE OF reprice_required NOWAIT;

               -- Always set the reprice flag for now
               UPDATE wsh_delivery_legs
               SET reprice_required = 'Y'
               WHERE delivery_leg_id = l_dleg_id;

               l_prc_in_rec.api_version_number := 1.0;
               l_prc_in_rec.delivery_leg_id    := l_dleg_id;
    --
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling FTE_FREIGHT_PRICING.shipment_price_consolidate...');

                l_action_params.caller :=  'FTE';
                l_action_params.event  := 'RE-RATING';
                l_action_params.action := 'RATE';
                l_temp_trips_tab(1)    := l_trip_id;
                l_action_params.trip_id_list := l_temp_trips_tab;

                FTE_TRIP_RATING_GRP.Rate_Trip (
                             p_api_version              => 1.0,
                             p_init_msg_list            => FND_API.G_FALSE,
                             p_action_params            => l_action_params,
                             p_commit                   => FND_API.G_FALSE,
                             p_init_prc_log             => 'N',
                             x_return_status            => l_return_status,
                             x_msg_count                => l_msg_count,
                             x_msg_data                 => l_msg_data);

                 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                IF (l_return_status = 'E')
                THEN
                      RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = 'U')
                THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
                END IF;

                --raise g_finished_success;

          ELSE -- no lane on trip

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no lane on trip, searching services...');

            Search_Services
            (
              p_trip_id 	=> l_trip_id,
              p_trip_msg_flag	=> l_tl_rating_flag,
              p_carrier_id 		=> p_carrier_id,
              p_mode_of_transport	=> p_mode_of_transport,
              p_service_level	=> p_service_level,
              x_matched_services 	=> l_matched_lanes,
              x_return_status       => l_return_status
            );

        /*Search_Services(
          p_delivery_leg_id 	=> l_dleg_id,
          p_trip_msg_flag	=> l_tl_rating_flag,
          p_carrier_id 		=> p_carrier_id,
          p_mode_of_transport	=> p_mode_of_transport,
          p_service_level	=> p_service_level,
          x_matched_services 	=> l_matched_lanes,
          x_return_status       => l_return_status);*/

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

            IF (l_return_status = 'E')
            THEN
                  RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status = 'U')
            THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
            THEN
                   x_return_status := l_return_status;
            END IF;

        l_matched_lane_count := l_matched_lanes.COUNT;
        IF (l_matched_lane_count = 0) THEN -- no lane found

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no services found.');
          RAISE FND_API.G_EXC_ERROR;
        ELSE -- found lane

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'found following lanes...');
          print_matched_lane_tab(p_matched_lane_tab => l_matched_lanes);

          l_all_lane_failed := true;

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'populating shipment...');

          populate_shipment(
            p_trip_id 	=> l_trip_id,
            x_return_status     => l_return_status);

          /*populate_shipment(
            p_delivery_leg_id 	=> l_dleg_id,
            x_return_status     => l_return_status);*/

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

            IF (l_return_status = 'E')
            THEN
                  RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status = 'U')
            THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
            THEN
                   x_return_status := l_return_status;
            END IF;

          j:=1;
          l_tl_lane_rows.delete;
          l_tl_lane_refs.delete;
          FOR i IN l_matched_lanes.FIRST..l_matched_lanes.LAST
          LOOP


            IF ((l_matched_lanes(i).mode_of_transport IS NOT NULL) AND (l_matched_lanes(i).mode_of_transport='TRUCK'))
            THEN

              l_tl_lane_rows(j):=l_matched_lanes(i).lane_id;
              l_tl_lane_refs(j):=i;
              j:=j+1;

            ELSE




                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'rate shipment on lane '||l_matched_lanes(i).lane_id||'...');

                 FTE_FREIGHT_PRICING_UTIL.get_currency_code
                 (
                    p_trip_id       => l_trip_id,
                    p_carrier_id    => l_matched_lanes(i).carrier_id,
                    x_currency_code => l_currency_code,
                    x_return_status => l_return_status
                  );


                fte_freight_pricing.shipment_rating (
                p_lane_id                  => l_matched_lanes(i).lane_id,
                p_service_type             => l_matched_lanes(i).service_level,
                p_mode_of_transport        => l_matched_lanes(i).mode_of_transport,
                p_ship_date                => g_ship_date,
                p_arrival_date             => g_arrival_date,
                p_currency_code            => l_currency_code,
                x_summary_lanesched_price  => l_lane_rate,
                x_summary_lanesched_price_uom	=> l_lane_rate_uom,
                x_freight_cost_temp_price  	=> l_lane_fct_price,
                x_freight_cost_temp_charge 	=> l_lane_fct_charge,
                x_return_status           	=> l_return_status,
                x_msg_count               	=> l_msg_count,
                x_msg_data                	=> l_msg_data );

                IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                AND (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN

			      -- shipment_rating failed
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment rating failed');
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||i);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(i).lane_id);

                  --FTE_FREIGHT_PRICING_UTIL.setmsg(
                --	  p_api			=> l_module_name,
                --	  p_exc			=> ' ',
                --	  p_msg_name		=> 'FTE_PRC_RATE_DEL_LANE_FL',
                --	  p_msg_type		=> 'E',
                --	  p_delivery_id		=> p_delivery_id,
                --	  p_lane_id		=> l_matched_lanes(i).lane_id);

                ELSE -- shipment_rating success or warning

                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'shipment_rating success');
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_index='||i);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(i).lane_id);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate='||l_lane_rate);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lane_rate_uom='||l_lane_rate_uom);

                  IF (l_all_lane_failed) THEN

                l_lowest_lane_index := i;
                l_lowest_lane_rate := l_lane_rate;
                l_lowest_lane_rate_uom := l_lane_rate_uom;
                l_lowest_lane_fct_price := l_lane_fct_price;
                l_lowest_lane_fct_charge := l_lane_fct_charge;
                l_all_lane_failed := false;

                  ELSE  -- l_all_lane_failed = false
                --compare with current lowest cost lane;

                IF (l_lowest_lane_rate_uom <> l_lane_rate_uom) THEN
                  convert_amount(
                    p_from_currency		=>l_lane_rate_uom,
                    p_from_amount		=>l_lane_rate,
                    p_to_currency		=>l_lowest_lane_rate_uom,
                    x_to_amount			=>l_converted_amount,
                    x_return_status		=> l_return_status);

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                IF (l_return_status = 'E')
                THEN
                      RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = 'U')
                THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
                END IF;

                ELSE
                  l_converted_amount := l_lane_rate;
                END IF;
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_converted_amount='||l_converted_amount);
                IF (l_lowest_lane_rate > l_converted_amount) THEN
                  l_lowest_lane_index := i;
                  l_lowest_lane_rate := l_lane_rate;
                  l_lowest_lane_rate_uom := l_lane_rate_uom;
                  l_lowest_lane_fct_price := l_lane_fct_price;
                  l_lowest_lane_fct_charge := l_lane_fct_charge;
                END IF;

                  END IF;  -- l_all_lane_failed = false

                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_index='||l_lowest_lane_index);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_id='||l_matched_lanes(l_lowest_lane_index).lane_id);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate='||l_lowest_lane_rate);
                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_lowest_lane_rate_uom='||l_lowest_lane_rate_uom);
                END IF;  -- shipment_rating success or warning

            END IF;	-- mode <> TRUCK

          END LOOP; -- matched_lane loop

          l_vehicle_type:=NULL;
          l_stop_charge_tab.delete;
          l_lowest_tl_lane_index:=NULL;

          IF (l_tl_lane_rows.COUNT > 0)
          THEN

            FTE_TL_RATING.BEGIN_LCSS (
                p_trip_id=> l_trip_id,
                p_lane_rows => l_tl_lane_rows,
                x_trip_index=> l_lowest_tl_trip_index,
                x_trip_charges_rec=>l_trip_charge_rec,
                x_stop_charges_tab=> l_stop_charge_tab,
                x_total_cost=>l_tl_lane_rate,
                x_currency=>l_tl_lane_curr,
                x_vehicle_type=>l_vehicle_type,
                x_lane_ref=>l_lowest_tl_lane_index,
                x_return_status => l_return_status);

              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
              THEN
             IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
             THEN

                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'TL LCSS failed');

                l_lowest_tl_lane_index:=NULL;

                --raise FTE_FREIGHT_PRICING_UTIL.g_tl_veh_for_lane_sched_fail;
             END IF;
              END IF;



          END IF;

          IF (l_all_lane_failed AND l_lowest_tl_lane_index IS NULL) THEN

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'no rates found.');
            RAISE FND_API.G_EXC_ERROR;
          ELSE

            IF((l_lowest_tl_lane_index IS NOT NULL) AND (l_all_lane_failed))
            THEN
                l_tl_lower:=TRUE;

            ELSIF((l_lowest_tl_lane_index IS NULL) AND NOT(l_all_lane_failed))
            THEN
                l_tl_lower:=FALSE;
            ELSE

                IF (l_lowest_lane_rate_uom <> l_tl_lane_curr)
                THEN
                    convert_amount(
                    p_from_currency		=>l_tl_lane_curr,
                    p_from_amount		=>l_tl_lane_rate,
                    p_to_currency		=>l_lowest_lane_rate_uom,
                    x_to_amount			=>l_converted_amount,
                    x_return_status		=> l_return_status);

                    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                    IF (l_return_status = 'E')
                    THEN
                          RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status = 'U')
                    THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                           x_return_status := l_return_status;
                    END IF;
                ELSE

                    l_converted_amount:=l_tl_lane_rate;
                END IF;

                IF (l_lowest_lane_rate < l_converted_amount)
                THEN

                    l_tl_lower:=FALSE;
                ELSE
                    l_tl_lower:=TRUE;
                END IF;

            END IF;
            IF (l_tl_lower)
            THEN
                l_lowest_lane_index:=l_tl_lane_refs(l_lowest_tl_lane_index);
                l_lowest_lane_rate_uom:=l_tl_lane_curr;
                l_lowest_lane_rate:=l_tl_lane_rate;
            ELSE
                --For  non-TL rate clear out TL vehicle type
                l_vehicle_type:=NULL;

            END IF;

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'carrier_id='||l_matched_lanes(l_lowest_lane_index).carrier_id);

            OPEN c_get_carrier_manifest_enabled(l_matched_lanes(l_lowest_lane_index).carrier_id);
            FETCH c_get_carrier_manifest_enabled INTO l_carrier_manifest_enabled;
            CLOSE c_get_carrier_manifest_enabled;

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_del_has_trip='||l_del_has_trip);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_del_org_manifest_enabled='||l_del_org_manifest_enabled);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_carrier_manifest_enabled='||l_carrier_manifest_enabled);

            IF p_delivery_id is not null   AND l_del_has_trip = 'N'    AND l_del_org_manifest_enabled = 'Y'
            AND l_carrier_manifest_enabled = 'Y' THEN

                  -- enhancement 3036126
                  ROLLBACK TO RATE_DELIVERY;
                  x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;

                  OPEN c_get_carrier_name(l_matched_lanes(l_lowest_lane_index).carrier_id);
                  FETCH c_get_carrier_name INTO l_carrier_name;
                  CLOSE c_get_carrier_name;

                  OPEN c_get_mode_of_transport(l_matched_lanes(l_lowest_lane_index).mode_of_transport);
                  FETCH c_get_mode_of_transport INTO l_mode_of_transport2;
                  CLOSE c_get_mode_of_transport;

                  OPEN c_get_service_level(l_matched_lanes(l_lowest_lane_index).service_level);
                  FETCH c_get_service_level INTO l_service_level2;
                  CLOSE c_get_service_level;

                  FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LCSS_MANIFEST');
                  FND_MESSAGE.SET_TOKEN('CARRIER_NAME',l_carrier_name);
                  FND_MESSAGE.SET_TOKEN('MODE_OF_TRANSPORT',l_mode_of_transport2);
                  FND_MESSAGE.SET_TOKEN('SERVICE_LEVEL',l_service_level2);
                  FND_MSG_PUB.ADD;

                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'least cost service is from manifesting enabled carrier and del org is manifesting enabled, do not save trip or rate.');

                  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'updating shipmethod on delivery...');

                  g_dlv_tab(p_delivery_id).CARRIER_ID        := l_matched_lanes(l_lowest_lane_index).carrier_id;
                  g_dlv_tab(p_delivery_id).SHIP_METHOD_CODE  := l_matched_lanes(l_lowest_lane_index).ship_method_code;
                  g_dlv_tab(p_delivery_id).SERVICE_LEVEL     := l_matched_lanes(l_lowest_lane_index).service_level;
                  g_dlv_tab(p_delivery_id).MODE_OF_TRANSPORT := l_matched_lanes(l_lowest_lane_index).mode_of_transport;

                  l_del_in_rec.caller       := 'FTE';
                  l_del_in_rec.phase        := 1;
                  l_del_in_rec.action_code  := 'UPDATE';

                  WSH_INTERFACE_GRP.Create_Update_Delivery
                    ( p_api_version_number     =>1.0,
                    p_init_msg_list          =>FND_API.G_FALSE,
                    p_commit                 =>FND_API.G_FALSE,
                    p_in_rec                 =>l_del_in_rec,
                    p_rec_attr_tab           => g_dlv_tab,
                    x_del_out_rec_tab        => l_del_out_tab,
                    x_return_status          => l_return_status,
                    x_msg_count              => l_msg_count,
                    x_msg_data               => l_msg_data
                  );

                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                IF (l_return_status = 'E')
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = 'U')
                THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status;
                END IF;

            ELSE

                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'updating trip with lane_id and shipmethod...');
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip_id='||l_trip_id);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lane_id='||l_matched_lanes(l_lowest_lane_index).lane_id);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'carrier_id='||l_matched_lanes(l_lowest_lane_index).carrier_id);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship_method_code='||l_matched_lanes(l_lowest_lane_index).ship_method_code);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'ship_method_name='||l_matched_lanes(l_lowest_lane_index).ship_method_name);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'service_level='||l_matched_lanes(l_lowest_lane_index).service_level);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'mode_of_transport='||l_matched_lanes(l_lowest_lane_index).mode_of_transport);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'vehicle_type='||l_vehicle_type);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lowest rate='||l_lowest_lane_rate);
                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'lowest rate UOM='||l_lowest_lane_rate_uom);
                IF(l_seq_tender_flag='N')
                THEN
                    -- update trip with lane_id, ship_method
                    update_single_trip(
                    p_trip_id		=> l_trip_id,
                    p_lane_id		=> l_matched_lanes(l_lowest_lane_index).lane_id,
                    p_carrier_id		=> l_matched_lanes(l_lowest_lane_index).carrier_id,
                    p_ship_method_code	=> l_matched_lanes(l_lowest_lane_index).ship_method_code,
                    p_ship_method_name	=> l_matched_lanes(l_lowest_lane_index).ship_method_name,
                    p_service_level		=> l_matched_lanes(l_lowest_lane_index).service_level,
                    p_mode_of_transport	=> l_matched_lanes(l_lowest_lane_index).mode_of_transport,
                    p_vehicle_type_id 	    => l_vehicle_type,
                    p_vehicle_item_id	   =>NULL,
                    p_vehicle_org_id	   =>NULL,
                    x_return_status		=> l_return_status,
                    x_msg_count		=> l_msg_count,
                    x_msg_data		=> l_msg_data);

                    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                    IF (l_return_status = 'E')
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status = 'U')
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                           x_return_status := l_return_status;
                    END IF;
                ELSE
                    l_rank_rec.trip_id:=l_trip_id;
                    l_rank_rec.lane_id:=l_matched_lanes(l_lowest_lane_index).lane_id;
                    l_rank_rec.carrier_id:=l_matched_lanes(l_lowest_lane_index).carrier_id;
                    l_rank_rec.service_level:=l_matched_lanes(l_lowest_lane_index).service_level;
                    l_rank_rec.mode_of_transport:=l_matched_lanes(l_lowest_lane_index).mode_of_transport;
                    l_rank_rec.estimated_rate:=l_lowest_lane_rate;
                    l_rank_rec.currency_code:=l_lowest_lane_rate_uom;

                    l_rank_rec.estimated_transit_time:=l_matched_lanes(l_lowest_lane_index).transit_time;
                    l_rank_rec.transit_time_uom:=l_matched_lanes(l_lowest_lane_index).transit_time_uom;


                    Sequential_Tender(
                        p_rank_rec=>l_rank_rec,
                        p_vehicle_type=>l_vehicle_type,
                        x_return_status=>l_return_status);

                    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                    IF (l_return_status = 'E')
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status = 'U')
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                           x_return_status := l_return_status;
                    END IF;
                END IF;

                IF(l_tl_lower)
                THEN
                    FTE_TL_RATING.END_LCSS (
                        p_trip_index=> l_lowest_tl_trip_index,
                        p_trip_charges_rec=>l_trip_charge_rec,
                        p_stop_charges_tab=> l_stop_charge_tab,
                        x_return_status => l_return_status);

                    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                    IF (l_return_status = 'E')
                    THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status = 'U')
                    THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                           x_return_status := l_return_status;
                    END IF;
                ELSE
                    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'move freight costs to main...');
                    -- update wsh_freight_costs with l_lowest_rate
                    fte_freight_pricing.Move_fc_temp_to_main (
                    p_delivery_leg_id	   => l_dleg_id,
                    p_freight_cost_temp_price  => l_lowest_lane_fct_price,
                    p_freight_cost_temp_charge => l_lowest_lane_fct_charge,
                    x_return_status            => l_return_status);

                    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_return_status='||l_return_status);

                    IF (l_return_status = 'E') THEN
                        RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status = 'U') THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING ) THEN
                        x_return_status := l_return_status;
                    END IF;
                 END IF;

                 FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling Trip_Select_Service_Init for trip:'||l_trip_id||'At:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

                 FTE_WORKFLOW_UTIL.Trip_Select_Service_Init(
                    p_trip_id           =>l_trip_id,
                    x_return_status     =>l_return_status);

                FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Trip_Select_Service_Init return_status:'||l_return_status||'At:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

            END IF;

          END IF;

        END IF; -- found lane

      END IF; -- no lane on trip
    ELSE

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Skipping rating dleg:'||l_dleg_id||' as it has a parent dleg');
    END IF;


    EXIT WHEN l_dleg_id = g_dlv_leg_tab.LAST;
    l_dleg_id := g_dlv_leg_tab.NEXT(l_dleg_id);
    END LOOP; -- dleg loop

--
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;

  EXCEPTION
	WHEN g_finished_warning THEN

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
--
	WHEN g_finished_success THEN

    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
--
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO RATE_DELIVERY;
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
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO RATE_DELIVERY;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
--
	WHEN OTHERS THEN
		ROLLBACK TO RATE_DELIVERY;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
  END Rate_Delivery;
--
  PROCEDURE Rate_Delivery  (
			     p_api_version		IN NUMBER DEFAULT 1.0,
			     p_init_msg_list		VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit                  	IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_in_param_rec		IN rate_del_in_param_rec,
			     x_out_param_rec		OUT NOCOPY  rate_del_out_param_rec,
                             x_return_status            OUT NOCOPY  VARCHAR2,
		       	     x_msg_count	        OUT NOCOPY  NUMBER,
			     x_msg_data	                OUT NOCOPY  VARCHAR2)
  IS
--
      l_api_version	CONSTANT NUMBER := 1.0;
      l_api_name           CONSTANT VARCHAR2(30)   := 'RATE_DELIVERY';
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_return_status           VARCHAR2(1);
      l_return_status_1         VARCHAR2(1);
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_DELIVERY';
--
      i                         NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);
--
      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_failed_delivery_id_list 	WSH_UTIL_CORE.id_tab_type;
      l_seq_tender_flag VARCHAR2(1);
  BEGIN
--
    --fix bug3715247
    --SAVEPOINT  RATE_MULTIPLE_DELIVERY;
--
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
                         (
                           l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME
                          )
    THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      		FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FTE_FREIGHT_PRICING_UTIL.initialize_logging( x_return_status  => l_return_status );

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
               api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_PRC_INIT_LOG_FL',
		  p_trip_id            =>     null,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = 'E')
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = 'U')
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;

    ELSE
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Initialize Logging successful ');
    END IF;

    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_in_param_rec.action='||p_in_param_rec.action);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_commit='||p_commit);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_in_param_rec.delivery_id_list.COUNT='||p_in_param_rec.delivery_id_list.COUNT);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_in_param_rec.seq_tender_flag='||p_in_param_rec.seq_tender_flag);

    l_seq_tender_flag:=p_in_param_rec.seq_tender_flag;

    --R12 Hiding Project
    l_seq_tender_flag:='N';

    IF(l_seq_tender_flag IS NULL)
    THEN
    	l_seq_tender_flag:='N';
    END IF;
    l_number_of_warnings := 0;
    IF (p_in_param_rec.delivery_id_list.COUNT > 0) THEN
      i := p_in_param_rec.delivery_id_list.FIRST;
      --FOR i in p_in_param_rec.delivery_id_list.FIRST..p_in_param_rec.delivery_id_list.LAST
      LOOP

	Rate_Delivery(
	  p_delivery_id		=> p_in_param_rec.delivery_id_list(i),
	  p_init_prc_log	=> 'N',
	  p_seq_tender_flag	=>l_seq_tender_flag,
          x_return_status	=> l_return_status,
	  x_msg_count		=> l_msg_count,
	  x_msg_data		=> l_msg_data);

      	IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
           (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
	  l_failed_delivery_id_list(i) := p_in_param_rec.delivery_id_list(i);

	      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_RATE_DEL_FL',
			  p_msg_type		=> 'E',
			  p_delivery_id		=> p_in_param_rec.delivery_id_list(i));

	ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
	  l_number_of_warnings := l_number_of_warnings + 1;
	END IF;

      EXIT WHEN i = p_in_param_rec.delivery_id_list.LAST;
      i := p_in_param_rec.delivery_id_list.NEXT(i);
      END LOOP;-- p_delivery_id_list loop
    END IF; -- p_delivery_id_list.COUNT > 0

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_failed_delivery_id_list.COUNT='||l_failed_delivery_id_list.COUNT);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_number_of_warnings='||l_number_of_warnings);

    IF l_failed_delivery_id_list.COUNT > 0 THEN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
      x_out_param_rec.failed_delivery_id_list := l_failed_delivery_id_list;

      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;

      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_RATE_MUL_DEL_FL',
			  p_msg_type		=> 'E');

    --fix bug3715247
      --ROLLBACK TO RATE_MULTIPLE_DELIVERY;
    ELSE
      IF l_number_of_warnings > 0 THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
      ELSE
        x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      END IF;
      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
      END IF;
    END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
--
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    FTE_FREIGHT_PRICING_UTIL.close_logs;

  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;

      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_RATE_MUL_DEL_FL',
			  p_msg_type		=> 'E');

    --fix bug3715247
		--ROLLBACK TO RATE_MULTIPLE_DELIVERY;
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
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
          FTE_FREIGHT_PRICING_UTIL.close_logs;
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;

      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_RATE_MUL_DEL_FL',
			  p_msg_type		=> 'E');

    --fix bug3715247
		--ROLLBACK TO RATE_MULTIPLE_DELIVERY;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exception(l_module_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
          FTE_FREIGHT_PRICING_UTIL.close_logs;
--
	WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_LOG_FILE_NAME');
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;

      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_RATE_MUL_DEL_FL',
			  p_msg_type		=> 'E');

    --fix bug3715247
		--ROLLBACK TO RATE_MULTIPLE_DELIVERY;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.'||l_api_name);
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
          FTE_FREIGHT_PRICING_UTIL.close_logs;
  END Rate_Delivery;

PROCEDURE Rate_Delivery2 (
  p_api_version         IN		NUMBER DEFAULT 1.0,
  p_init_msg_list	IN		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit	    	IN  		VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status	OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  p_init_prc_log	IN  		VARCHAR2 DEFAULT 'Y',
  p_delivery_in_rec	IN		delivery_in_rec_type
)
IS
  l_api_version		CONSTANT NUMBER := 1.0;
  l_api_name           	CONSTANT VARCHAR2(30)   := 'Rate_Delivery2';
  l_log_level           NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(32767);
  l_delivery_id		NUMBER;
  l_carrier_id 		NUMBER;
  l_mode_of_transport	VARCHAR2(30);
  l_service_level	VARCHAR2(30);
  l_lookup		VARCHAR2(30);
  l_leg_trip_det_rec    c_leg_trip_det%ROWTYPE;
  l_leg_id 		NUMBER;
  l_trip_id		NUMBER;
  l_leg_count		NUMBER;
BEGIN

  SAVEPOINT  RATE_DELIVERY2;

  IF NOT FND_API.Compatible_API_Call (
    	   	l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.initialize_logging( x_return_status  => l_return_status );
    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FTE_FREIGHT_PRICING_UTIL.setmsg(
			  p_api			=> l_api_name,
			  p_exc			=> ' ',
			  p_msg_name		=> 'FTE_PRC_INIT_LOG_FL',
			  p_msg_type		=> 'E');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_api_version='||p_api_version);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_init_msg_list='||p_init_msg_list);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_commit='||p_commit);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_init_prc_log='||p_init_prc_log);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_in_rec.name='||p_delivery_in_rec.name);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_in_rec.carrier_name='||p_delivery_in_rec.carrier_name);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_in_rec.mode_of_transport='||p_delivery_in_rec.mode_of_transport);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_delivery_in_rec.service_level='||p_delivery_in_rec.service_level);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  -- validate delivery name and get delivery_id
  WSH_UTIL_VALIDATE.Validate_Delivery_Name (
    p_delivery_id    	=> l_delivery_id,
    p_delivery_name  	=> p_delivery_in_rec.name,
    x_return_status  	=> l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Invalid delivery name '||p_delivery_in_rec.name);
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- validate carrier_name and get carrier_id
  WSH_UTIL_VALIDATE.Validate_Carrier (
    p_carrier_name 	=> p_delivery_in_rec.carrier_name,
    x_carrier_id   	=> l_carrier_id,
    x_return_status  	=> l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Invalid carrier name '||p_delivery_in_rec.carrier_name);
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- validate mode_of_transport and get mode_of_transport_code
  l_lookup := p_delivery_in_rec.mode_of_transport;
  WSH_UTIL_VALIDATE.Validate_Lookup (
    p_lookup_type     	=> 'WSH_MODE_OF_TRANSPORT',
    p_lookup_code       => l_lookup,
    p_meaning           => null,
    x_return_status  	=> l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Invalid mode of transport '|| l_lookup);
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_mode_of_transport := p_delivery_in_rec.mode_of_transport;

  -- validate service_level and get service_level_code
  l_lookup := p_delivery_in_rec.service_level;
  WSH_UTIL_VALIDATE.Validate_Lookup (
    p_lookup_type     	=> 'WSH_SERVICE_LEVELS',
    p_lookup_code       => l_lookup,
    p_meaning           => null,
    x_return_status  	=> l_return_status);
  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Invalid sevice level '|| l_lookup);
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_service_level := p_delivery_in_rec.service_level;

  -- if delivery is on multiple trips, error out
  l_leg_count := 0;
  OPEN c_get_dleg_id(l_delivery_id);
  LOOP
    FETCH c_get_dleg_id INTO l_leg_id;
    EXIT WHEN c_get_dleg_id%NOTFOUND;
    l_leg_count := l_leg_count + 1;
    IF l_leg_count > 1 THEN
      EXIT;
    END IF;
  END LOOP;
  CLOSE c_get_dleg_id;
  IF l_leg_count > 1 THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_DLV_MNY_TRP');-- todo PM new msg
      FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_in_rec.name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- if delivery is on one trip, trip has multiple deliveries, error out
  OPEN c_leg_trip_det(l_leg_id);
  FETCH c_leg_trip_det INTO l_leg_trip_det_rec;
  CLOSE c_leg_trip_det;

  l_trip_id := l_leg_trip_det_rec.trip_id;
  OPEN c_cnt_trip_legs(l_trip_id);
  FETCH c_cnt_trip_legs INTO l_leg_count;
  CLOSE c_cnt_trip_legs;

  IF (l_leg_count > 1) THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_TRP_MNY_DLV');
      FND_MESSAGE.SET_TOKEN('TRIP_ID', l_trip_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_carrier_id is not null) or (l_mode_of_transport is not null)
     or (l_service_level is not null) THEN

    Cancel_Service  (
      p_delivery_id 	=> l_delivery_id,
      x_return_status 	=> l_return_status,
      x_msg_count  	=> l_msg_count,
      x_msg_data  	=> l_msg_data);

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      -- if cancel service adds the message to the stack,
      -- we do not need to add again.
      --FND_MESSAGE.SET_NAME('FTE','FTE_PRC_CAN_SRV_FL');
      --FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_in_rec.name);
      --FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  Rate_Delivery (
    p_delivery_id 	=> l_delivery_id,
    p_init_prc_log 	=> 'N',
    p_carrier_id 	=> l_carrier_id,
    p_mode_of_transport => l_mode_of_transport,
    p_service_level 	=> l_service_level,
    x_return_status 	=> l_return_status,
    x_msg_count  	=> l_msg_count,
    x_msg_data  	=> l_msg_data);

  IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
      FND_MESSAGE.SET_NAME('FTE','FTE_PRC_RERATE_SHIPMENT_FAIL');
      FND_MESSAGE.SET_TOKEN('DEL_NAMES', p_delivery_in_rec.name);
      FND_MESSAGE.SET_TOKEN('LOGFILE',FTE_FREIGHT_PRICING_UTIL.get_log_file_name());
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- End of API body

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);

  IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO RATE_DELIVERY2;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO RATE_DELIVERY2;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO RATE_DELIVERY2;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level
  	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_count='||x_msg_count);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_msg_data='||x_msg_data);
    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
    IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
    END IF;
END Rate_Delivery2;

--
END FTE_FREIGHT_RATING_DLVY_GRP;

/
