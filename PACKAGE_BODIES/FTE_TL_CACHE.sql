--------------------------------------------------------
--  DDL for Package Body FTE_TL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TL_CACHE" AS
/* $Header: FTEVTLCB.pls 120.9 2007/11/30 05:52:38 sankarun ship $ */






g_tl_pallet_item_type VARCHAR2(30):=NULL;

--Structure used to addup quntities on a dleg

TYPE TL_dleg_quantity_rec_type IS RECORD(

delivery_leg_id	NUMBER,
weight		NUMBER,
volume		NUMBER,
pallets		NUMBER,
containers	NUMBER,
distance	NUMBER,
empty_flag	VARCHAR2(1)

);

TYPE TL_dleg_quantity_tab_type IS TABLE OF TL_dleg_quantity_rec_type INDEX BY
BINARY_INTEGER;

--Structure used to gather inputs for mileage interface

TYPE TL_stop_distance_rec_type IS RECORD(

from_stop_id	NUMBER,
from_location_id 	NUMBER,
to_stop_id	NUMBER,
to_location_id	NUMBER,
distance	NUMBER,
time		NUMBER,
cumulative_distance NUMBER,
empty_flag	VARCHAR2(1)

);

TYPE TL_stop_distance_tab_type IS TABLE OF TL_stop_distance_rec_type INDEX BY
BINARY_INTEGER;


TYPE TL_stop_quantity_rec_type IS RECORD(
stop_id	NUMBER,
pickup_weight		NUMBER,
pickup_volume		NUMBER,
dropoff_weight		NUMBER,
dropoff_volume		NUMBER
);

TYPE TL_stop_quantity_tab_type IS TABLE OF TL_stop_quantity_rec_type INDEX BY
BINARY_INTEGER;


PROCEDURE TL_Get_Currency(
            p_delivery_id IN NUMBER,
            p_trip_id      IN NUMBER,
            p_location_id IN NUMBER,
            p_carrier_id IN NUMBER,
            x_currency_code IN OUT NOCOPY VARCHAR2 ,
            x_return_status OUT NOCOPY VARCHAR2 ) IS

	l_return_status VARCHAR2(1);
	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;


BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Get_Currency','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'p_delivery_id:'||p_delivery_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'p_trip_id:'||p_trip_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'p_location_id:'||p_location_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'p_carrier_id:'||p_carrier_id);



	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'COMMENTED OUT CALL FOR NOW');

/*
	FTE_FREIGHT_PRICING_UTIL.get_currency_code (
		p_delivery_id=>p_delivery_id,
		p_trip_id=>p_trip_id,
		p_location_id=>p_location_id,
		p_carrier_id=>p_carrier_id,
		x_currency_code=>x_currency_code,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_util_get_currency_fail;
	       END IF;
	END IF;
*/

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'x_currency_code:'||x_currency_code);

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Get_Currency');




EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_util_get_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Get_Currency',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_util_get_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Get_Currency');


WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Get_Currency',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Get_Currency');


END TL_Get_Currency;



PROCEDURE Calculate_Dimensional_Weight(
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	p_weight IN NUMBER,
	p_volume IN NUMBER,
	x_dim_weight IN OUT NOCOPY NUMBER,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS


	l_converted_volume NUMBER;
	l_converted_weight NUMBER;
	l_dim_weight NUMBER;
	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Calculate_Dimensional_Weight','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_dim_weight:=p_weight;
	IF ((p_carrier_pref_rec.dim_factor IS NOT NULL) AND (p_carrier_pref_rec.dim_factor>0))
	THEN

		l_converted_volume:=NULL;

		l_converted_volume:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_carrier_pref_rec.volume_uom,
			p_carrier_pref_rec.dim_volume_uom,
			p_volume,
			0);

		IF (l_converted_volume IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail;
		END IF;

		IF (l_converted_volume >= p_carrier_pref_rec.dim_min_volume)
		THEN
			l_converted_weight:=l_converted_volume/p_carrier_pref_rec.dim_factor;
			l_dim_weight:=NULL;
			l_dim_weight:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				p_carrier_pref_rec.dim_weight_uom,
				p_carrier_pref_rec.weight_uom,
				l_converted_weight,
				0);


			IF (l_dim_weight IS NULL)
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;
			END IF;

			IF (l_dim_weight > p_weight)
			THEN

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Old Wt:'||p_weight||' Applying DIM WT:'||l_dim_weight);

				x_dim_weight:=l_dim_weight;

			END IF;

		END IF;


	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Calculate_Dimensional_Weight');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;



EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Calculate_Dimensional_Weight',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Calculate_Dimensional_Weight');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Calculate_Dimensional_Weight',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Calculate_Dimensional_Weight');


WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Calculate_Dimensional_Weight',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Calculate_Dimensional_Weight');



END Calculate_Dimensional_Weight;



PROCEDURE Get_Vehicle_Type(
	p_trip_id IN NUMBER,
	p_vehicle_item_id IN NUMBER,
	x_vehicle_type IN OUT NOCOPY NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2) IS

CURSOR get_vehicle_item(c_trip_id IN NUMBER)
       IS
       SELECT t.vehicle_item_id
       FROM  wsh_trips t
       WHERE t.trip_id=c_trip_id;


	l_vehicle_item NUMBER;
	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Vehicle_Type','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_vehicle_item_id IS NULL)
	THEN

		OPEN get_vehicle_item(p_trip_id);
		FETCH get_vehicle_item INTO l_vehicle_item;
		CLOSE get_vehicle_item;
	ELSE
		l_vehicle_item:=p_vehicle_item_id;
	END IF;

	IF (l_vehicle_item IS NOT NULL)
	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Calling vehicle API inventory item:'||l_vehicle_item||' trip : '||p_trip_id);

		x_vehicle_type:=FTE_VEHICLE_PKG.GET_VEHICLE_TYPE_ID(
			p_inventory_item_id=> l_vehicle_item);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Vehicle API returned:'||x_vehicle_type);

		IF (x_vehicle_type = -1)
		THEN
			x_vehicle_type:=NULL;

		END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicle_Type');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Vehicle_Type',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicle_Type');





END Get_Vehicle_Type;


PROCEDURE Get_Pricelist_Id(
	p_lane_id	IN NUMBER,
	p_departure_date IN DATE,
	p_arrival_date IN DATE,
	x_pricelist_id	IN OUT NOCOPY NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2) IS


CURSOR get_price_list_id(
	c_lane_id IN NUMBER,
	c_departure_date IN DATE,
	c_arrival_date IN DATE)
	IS
	SELECT flrc.list_header_id
	FROM fte_lane_rate_charts flrc
	WHERE flrc.lane_id = c_lane_id
	AND (flrc.start_date_active is null
		OR flrc.start_date_active <= c_departure_date )
	AND    (flrc.end_date_active is null
		OR flrc.end_date_active > c_departure_date );



	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Pricelist_Id','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN get_price_list_id(p_lane_id,p_departure_date,p_arrival_date);
	FETCH get_price_list_id INTO x_pricelist_id;
	CLOSE get_price_list_id;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Pricelist_Id');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Pricelist_Id',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Pricelist_Id');


END Get_Pricelist_Id;

PROCEDURE Initialize_Cache_Indices(
	x_trip_index	IN OUT NOCOPY NUMBER,
	x_stop_index	IN OUT NOCOPY NUMBER,
	x_dleg_index	IN OUT NOCOPY NUMBER,
	x_carrier_index	IN OUT NOCOPY NUMBER,
	x_child_dleg_index IN OUT NOCOPY NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2) IS

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Initialize_Cache_Indices','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	--Initializes all indices

	IF(g_tl_trip_rows.LAST IS NULL)
	THEN
		x_trip_index:=1;
	ELSE
		x_trip_index:=g_tl_trip_rows.LAST+1;
	END IF;

	IF(g_tl_trip_stop_rows.LAST IS NULL)
	THEN
		x_stop_index:=1;
	ELSE
		x_stop_index:=g_tl_trip_stop_rows.LAST+1;
	END IF;

	IF(g_tl_carrier_pref_rows.LAST IS NULL)
	THEN
		x_carrier_index:=1;
	ELSE
		x_carrier_index:=g_tl_carrier_pref_rows.LAST+1;
	END IF;

	IF(g_tl_delivery_leg_rows.LAST IS NULL)
	THEN
		x_dleg_index:=1;
	ELSE
		x_dleg_index:=g_tl_delivery_leg_rows.LAST+1;
	END IF;

	IF(g_tl_chld_delivery_leg_rows.LAST IS NULL)
	THEN
		x_child_dleg_index:=1;
	ELSE
		x_child_dleg_index:=g_tl_chld_delivery_leg_rows.LAST+1;
	END IF;





  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Cache_Indices');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Initialize_Cache_Indices',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Cache_Indices');


END Initialize_Cache_Indices;


--Determines if a dlv detail is counted as a pallet

PROCEDURE Is_Detail_Pallet(
	p_dlv_detail_id IN NUMBER,
	x_pallet IN OUT NOCOPY VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2) IS


	CURSOR get_pallet_item_type IS

	SELECT 	wgp.pallet_item_type
	FROM	wsh_global_parameters wgp;


	CURSOR get_item_type(c_dtl_id IN NUMBER) IS
	SELECT m.container_type_code
	FROM 	mtl_system_items_b m ,
		wsh_delivery_details d
	WHERE 	d.inventory_item_id=m.inventory_item_id  and
		d.organization_id = m.organization_id and
		d.delivery_detail_id=c_dtl_id;

	l_item_type VARCHAR2(30);

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Is_Detail_Pallet','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (g_tl_pallet_item_type IS NULL)
	THEN

		OPEN get_pallet_item_type;
		FETCH get_pallet_item_type INTO g_tl_pallet_item_type;
		CLOSE get_pallet_item_type;

		IF (g_tl_pallet_item_type IS NULL)
		THEN
			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Is_Detail_Pallet',
			--	p_exc=>'g_tl_no_pallet_item_type');

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_pallet_item_type;

		END IF;

	END IF;

	l_item_type:=NULL;
	x_pallet:='N';
	OPEN get_item_type(p_dlv_detail_id);
	FETCH get_item_type INTO l_item_type;
	IF (get_item_type%FOUND)
	THEN

		IF((l_item_type is not NULL) AND (l_item_type=g_tl_pallet_item_type))
		THEN
			x_pallet:='Y';
		END IF;

	END IF;
	CLOSE get_item_type;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Is_Detail_Pallet');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_pallet_item_type THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Is_Detail_Pallet',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_pallet_item_type');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Is_Detail_Pallet');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Is_Detail_Pallet',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Is_Detail_Pallet');


END Is_Detail_Pallet;


--This is used to cache all the information for delivery search services
--It is not used in TL Rating currently

PROCEDURE TL_Build_Cache_For_Delivery(
	p_wsh_new_delivery_id  	IN	NUMBER,
	p_wsh_delivery_leg_id 	IN	NUMBER ,
	p_lane_rows 	IN	DBMS_UTILITY.NUMBER_ARRAY,
	p_schedule_rows IN 	DBMS_UTILITY.NUMBER_ARRAY,
	x_return_status 	OUT	NOCOPY	VARCHAR2) IS


l_return_status	VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Build_Cache_For_Delivery','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

END TL_Build_Cache_For_Delivery;



--Place holder for TL Rating from OM
--Not used

PROCEDURE TL_Build_Cache_For_OM(
	x_return_status	OUT 	NOCOPY	VARCHAR2) IS



l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Build_Cache_For_OM','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_OM');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_OM');

END TL_Build_Cache_For_OM;


--Validates a single cached trip structure

PROCEDURE Validate_Trip_Info(
	x_trip_info IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_return_status 	OUT	NOCOPY	VARCHAR2) IS

l_return_status	VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Validate_Trip_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (x_trip_info.trip_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_trip_id;
	END IF;
	IF (x_trip_info.lane_id IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
                --   	p_exc=>'g_tl_trp_no_lane_id',
                --     	p_trip_id=>x_trip_info.trip_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_lane_id;
	END IF;

	IF (x_trip_info.service_type IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
                --     	p_exc=>'g_tl_trp_no_service_type',
                --    	p_trip_id=>x_trip_info.trip_id);
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_service_type;
	END IF;

	IF (x_trip_info.carrier_id IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
		--	p_exc=>'g_tl_trp_no_carrier_id',
		--	p_trip_id=>x_trip_info.trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_carrier_id;
	END IF;
	IF (x_trip_info.mode_of_transport IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
		--	p_exc=>'g_tl_trp_no_mode',
		--	p_trip_id=>x_trip_info.trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_mode;
	END IF;

	IF (x_trip_info.vehicle_type IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
		--	p_exc=>'g_tl_trp_no_vehicle_type',
		--	p_trip_id=>x_trip_info.trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_vehicle_type;
	END IF;

	IF (x_trip_info.price_list_id IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
		--	p_exc=>'g_tl_trp_no_price_list_id',
		--	p_trip_id=>x_trip_info.trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_price_list_id;
	END IF;

	IF (x_trip_info.loaded_distance IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_ld_distance;
	END IF;

	IF(x_trip_info.unloaded_distance IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_ud_distance;
	END IF;

	IF (x_trip_info.number_of_pallets IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_pallets;
	END IF;

	IF (x_trip_info.number_of_containers IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_containers;
	END IF;

	IF(x_trip_info.total_weight IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_weight;
	END IF;

	IF(x_trip_info.total_volume IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_volume;
	END IF;

	IF (x_trip_info.time IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_time;
	END IF;

	IF (x_trip_info.number_of_stops IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_number_of_stops;
	END IF;

	IF (x_trip_info.total_trip_distance IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_total_trp_distance;
	END IF;

	IF(x_trip_info.total_direct_distance IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_total_dir_distance;
	END IF;


	IF (x_trip_info.distance_method IS NULL)
	THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_distance_method;
		x_trip_info.distance_method:='FULL_ROUTE';
	END IF;

	IF (x_trip_info.continuous_move IS NULL)
	THEN
		x_trip_info.continuous_move:='N';
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_continous_move;
	END IF;

	IF (x_trip_info.planned_departure_date IS NULL)
	THEN

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
		--	p_exc=>'g_tl_trp_no_departure_date',
		--	p_trip_id=>x_trip_info.trip_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_departure_date;
	END IF;

	IF (x_trip_info.planned_arrival_date IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Trip_Info',
		--	p_exc=>'g_tl_trp_no_arrival_date',
		--	p_trip_id=>x_trip_info.trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_arrival_date;
	END IF;

	IF (x_trip_info.dead_head IS NULL)
	THEN
		x_trip_info.dead_head:='N';
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_dead_head;
	END IF;

	IF (x_trip_info.stop_reference IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_stop_reference;
	END IF;

	--Can be null for a dead head
	--IF (x_trip_info.delivery_leg_reference IS NULL)
	--THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_dleg_reference;
	--END IF;




        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_trip_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_trip_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_lane_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_lane_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_service_type THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_service_type');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_carrier_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_carrier_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_mode THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_mode');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_vehicle_type THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_vehicle_type');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_price_list_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_price_list_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_ld_distance THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_ld_distance');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_ud_distance THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_ud_distance');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_pallets THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_pallets');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_containers THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_containers');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_weight THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_weight');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_volume THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_volume');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_time THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_time');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_number_of_stops THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_number_of_stops');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_total_trp_distance THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_total_trp_distance');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_total_dir_distance THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_total_dir_distance');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_distance_method THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_distance_method');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_departure_date THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_departure_date');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_arrival_date THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_arrival_date');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_stop_reference THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_stop_reference');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_dleg_reference THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_dleg_reference');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Info');

END Validate_Trip_Info;


PROCEDURE Validate_Fac_Info(
	p_carrier_pref_rec  IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_info IN OUT NOCOPY TL_trip_stop_input_rec_type,
	x_return_status 	OUT	NOCOPY	VARCHAR2) IS

	l_cancel_fac VARCHAR2(1);
	l_quantity_pickup NUMBER;
	l_quantity_dropoff NUMBER;

BEGIN



---Facility validation
---If any critical faciolity info is missing, set all of them to values shown below.
---Setting the fac_pricelistId to NULL indicates that NO Fac charges will be calculated
--- if the charge basis is returned weight then there will be a weight uom, if it
-- returns volume there will be a volume uom

	l_cancel_fac:='N';

	IF((x_stop_info.fac_charge_basis IS NULL) OR
	   (x_stop_info.fac_currency IS NULL) OR
	   (x_stop_info.fac_modifier_id IS NULL) OR
	   (x_stop_info.fac_pricelist_id IS NULL) OR
	   (x_stop_info.loading_protocol IS NULL) OR
	   ((x_stop_info.fac_charge_basis=FTE_RTG_GLOBALS.G_CARRIER_WEIGHT_BASIS)
	   	AND (x_stop_info.fac_weight_uom IS NULL)) OR
	   ((x_stop_info.fac_charge_basis=FTE_RTG_GLOBALS.G_CARRIER_VOLUME_BASIS)
	   	AND (x_stop_info.fac_volume_uom IS NULL))
	   )
	THEN

		l_cancel_fac:='Y';

		--l_warning_count:=l_warning_count+1;

		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Stop_Info',
		--	p_exc=>'g_tl_stp_no_fac_wrn',
		--	p_msg_type=>'W',
		--	p_location_id=>x_stop_info.location_id,
		--	p_stop_id=>x_stop_info.stop_id);

	ELSE

		--Convert to fac weight uoms

		IF (x_stop_info.fac_charge_basis=FTE_RTG_GLOBALS.G_CARRIER_WEIGHT_BASIS)
		THEN

			l_quantity_pickup:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				p_carrier_pref_rec.weight_uom,
				x_stop_info.fac_weight_uom,
				x_stop_info.pickup_weight,
				0);



			l_quantity_dropoff:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				p_carrier_pref_rec.weight_uom,
				x_stop_info.fac_weight_uom,
				x_stop_info.dropoff_weight,
				0);



			IF ((l_quantity_pickup IS NULL) OR (l_quantity_dropoff IS NULL))
			THEN

				l_cancel_fac:='Y';

			END IF;

			x_stop_info.fac_pickup_weight:=l_quantity_pickup;
			x_stop_info.fac_dropoff_weight:=l_quantity_dropoff;

		ELSIF (x_stop_info.fac_charge_basis=FTE_RTG_GLOBALS.G_CARRIER_VOLUME_BASIS)
		THEN

			--Convert to fac volume uoms

			l_quantity_pickup:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				p_carrier_pref_rec.volume_uom,
				x_stop_info.fac_volume_uom,
				x_stop_info.pickup_weight,
				0);

			l_quantity_dropoff:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				p_carrier_pref_rec.volume_uom,
				x_stop_info.fac_volume_uom,
				x_stop_info.dropoff_volume,
				0);

			IF ((l_quantity_pickup IS NULL) OR (l_quantity_dropoff IS NULL))
			THEN

				l_cancel_fac:='Y';

			END IF;

			x_stop_info.fac_pickup_volume:=l_quantity_pickup;
			x_stop_info.fac_dropoff_volume:=l_quantity_dropoff;

		END IF;

	END IF;


	IF (l_cancel_fac='Y')
	THEN

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,' Reseting fac infor for stop ID '
        ||x_stop_info.stop_id||' protocol:'||x_stop_info.loading_protocol||' pricelist_id:'
        ||x_stop_info.fac_pricelist_id||' fac_modifier_id:'
        ||x_stop_info.fac_modifier_id||' fac_charge_basis:'||x_stop_info.fac_charge_basis||' fac_currency:'
        ||x_stop_info.fac_currency||' fac_weight_uom:'||x_stop_info.fac_weight_uom||' fac_volume_uom:'
        ||x_stop_info.fac_volume_uom);

		--Do Not erase the carrier protocol, we do not want carrier charges to get applied
		--if facility information is incomplete
		--bug 3635952
		--x_stop_info.loading_protocol:='CARRIER';

		x_stop_info.fac_pricelist_id:=NULL;
		x_stop_info.fac_modifier_id:=NULL;
		x_stop_info.fac_charge_basis:=NULL;
		x_stop_info.fac_currency:=p_carrier_pref_rec.currency;
		x_stop_info.fac_weight_uom:=NULL;
		x_stop_info.fac_volume_uom:=NULL;

		x_stop_info.fac_pickup_weight:=NULL;
		x_stop_info.fac_pickup_volume:=NULL;
		x_stop_info.fac_dropoff_weight:=NULL;
		x_stop_info.fac_dropoff_volume:=NULL;

	END IF;

END Validate_Fac_Info;

--Validates a single cached stop structure

PROCEDURE Validate_Stop_Info(
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_info IN OUT NOCOPY TL_trip_stop_input_rec_type,
	x_return_status 	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Validate_Stop_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(x_stop_info.stop_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_stop_id;
	END IF;

	IF(x_stop_info.trip_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_trip_id;
	END IF;

	IF(x_stop_info.location_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_location_id;
	END IF;

	IF(x_stop_info.weekday_layovers IS NULL)
	THEN
		x_stop_info.weekday_layovers:=0;
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_weekday_layovers;
	END IF;

	IF(x_stop_info.weekend_layovers IS NULL)
	THEN
		x_stop_info.weekend_layovers:=0;
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_weekend_layovers;
	END IF;

	IF(x_stop_info.distance_to_next_stop IS NULL)
	THEN

	 	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'NO dist in '||x_stop_info.stop_id);
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_distance;
	END IF;

	IF(x_stop_info.time_to_next_stop IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_time;
	END IF;

	IF(x_stop_info.pickup_weight IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_weight;
	END IF;

	IF(x_stop_info.pickup_volume IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_volume;
	END IF;

	IF(x_stop_info.pickup_pallets IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_pallets;
	END IF;

	IF(x_stop_info.pickup_containers IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_containers;
	END IF;


	IF(x_stop_info.dropoff_weight IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_weight;
	END IF;

	IF(x_stop_info.dropoff_volume IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_volume;
	END IF;

	IF(x_stop_info.dropoff_pallets IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_pallets;
	END IF;

	IF(x_stop_info.dropoff_containers IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_containers;
	END IF;

	--Can be NULL
	--IF(x_stop_info.stop_region IS NULL)
	--THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_stop_region;
	--END IF;

	IF(x_stop_info.planned_arrival_date IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_arrival_date;
	END IF;

	IF(x_stop_info.planned_departure_date IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_departure_date;
	END IF;

	IF(x_stop_info.stop_type IS NULL)
	THEN
		x_stop_info.stop_type:='NA';
	END IF;


	Validate_Fac_Info(
		p_carrier_pref_rec=>p_carrier_pref_rec,
		x_stop_info=>x_stop_info,
		x_return_status=>l_return_status);


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_stop_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_stop_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_trip_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_trip_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_location_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_location_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_weekday_layovers THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_weekday_layovers');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_weekend_layovers THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_weekend_layovers');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_distance THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_distance');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_time THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_time');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_weight THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_pickup_weight');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_volume THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_pickup_volume');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_pallets THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_pickup_pallets');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_pickup_containers THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_pickup_containers');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_loading_protocol THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_loading_protocol');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_weight THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_dropoff_weight');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_volume THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_dropoff_volume');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_pallets THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_dropoff_pallets');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_dropoff_containers THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_dropoff_containers');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_stop_region THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_stop_region');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_arrival_date THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_arrival_date');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_departure_date THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_departure_date');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_charge_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_charge_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_currency THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_currency');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_modifier_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_modifier_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_pricelist_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_pricelist_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_weight_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_weight_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_volume_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_volume_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_distance_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_distance_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_stp_no_fac_time_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_stp_no_fac_time_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Stop_Info');

END Validate_Stop_Info;

--Validates a single cached delivery leg structure

PROCEDURE Validate_Dleg_Info(
	x_dleg_info IN OUT NOCOPY TL_delivery_leg_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Validate_Dleg_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF (x_dleg_info.delivery_leg_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_delivery_leg_id;
	END IF;


	IF (x_dleg_info.trip_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_trip_id;
	END IF;

	IF (x_dleg_info.delivery_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_delivery_id;
	END IF;

	IF (x_dleg_info.pickup_stop_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_pickup_stop_id;
	END IF;

	IF (x_dleg_info.pickup_location_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_pickup_loc_id;
	END IF;

	IF (x_dleg_info.dropoff_stop_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_dropoff_stop_id;
	END IF;

	IF (x_dleg_info.dropoff_location_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_dropoff_loc_id;
	END IF;

	IF (x_dleg_info.weight IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_weight;
	END IF;

	IF (x_dleg_info.volume IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_volume;
	END IF;

	IF (x_dleg_info.pallets IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_pallets;
	END IF;


	IF (x_dleg_info.containers IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_containers;
	END IF;

	IF (x_dleg_info.distance IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_distance;
	END IF;

	IF (x_dleg_info.direct_distance IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_direct_distance;
	END IF;

	IF (x_dleg_info.children_weight IS NULL)
	THEN
		x_dleg_info.children_weight:=0;
	END IF;

	IF (x_dleg_info.children_volume IS NULL)
	THEN
		x_dleg_info.children_volume:=0;
	END IF;

	IF (x_dleg_info.is_parent_dleg IS NULL)
	THEN
		x_dleg_info.is_parent_dleg:='N';
	END IF;

	IF (x_dleg_info.parent_with_no_consol_lpn IS NULL)
	THEN
		x_dleg_info.parent_with_no_consol_lpn:='N';
	END IF;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');


	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_delivery_leg_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_delivery_leg_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_trip_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_trip_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_delivery_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_delivery_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

 WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_pickup_stop_id THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_pickup_stop_id');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_pickup_loc_id THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_pickup_loc_id');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_dropoff_stop_id THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_dropoff_stop_id');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');
 WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_dropoff_loc_id THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_dropoff_loc_id');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_weight THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_weight');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_volume THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_volume');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_pallets THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_pallets');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_containers THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_containers');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_distance THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_distance');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dlg_no_direct_distance THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dlg_no_direct_distance');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dleg_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dleg_Info');

END  Validate_Dleg_Info;


--Validates a single cached delivery detail structure

PROCEDURE Validate_Dlv_Detail_Info(
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_dlv_detail_info IN OUT NOCOPY FTE_FREIGHT_PRICING.shipment_line_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Validate_Dlv_Detail_Info','start');


	IF (x_dlv_detail_info.delivery_detail_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_dlv_dtl_id;
	END IF;

	IF (x_dlv_detail_info.delivery_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_dlv_id;
	END IF;

	IF (x_dlv_detail_info.delivery_leg_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_dlg_id;
	END IF;

	IF (x_dlv_detail_info.gross_weight IS NULL)
	THEN
		--3958974
		x_dlv_detail_info.gross_weight:=0;
		x_dlv_detail_info.weight_uom_code:=p_carrier_pref_rec.weight_uom;

		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Dlv_Detail_Info',
		--	p_exc=>'g_tl_dtl_no_gross_weight',
		--	p_delivery_detail_id=>x_dlv_detail_info.delivery_detail_id);

		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_gross_weight;
	END IF;

	IF (x_dlv_detail_info.weight_uom_code IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Dlv_Detail_Info',
		--	p_exc=>'g_tl_dtl_no_weight_uom',
		--	p_delivery_detail_id=>x_dlv_detail_info.delivery_detail_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_weight_uom;
	END IF;

	IF (x_dlv_detail_info.volume IS NULL)
	THEN
		--3958974
		x_dlv_detail_info.volume:=0;
		x_dlv_detail_info.volume_uom_code:=p_carrier_pref_rec.volume_uom;
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Dlv_Detail_Info',
		--	p_exc=>'g_tl_dtl_no_volume',
		--	p_delivery_detail_id=>x_dlv_detail_info.delivery_detail_id);

		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_volume;
	END IF;

	IF (x_dlv_detail_info.volume_uom_code IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Dlv_Detail_Info',
		--	p_exc=>'g_tl_dtl_no_volume_uom',
		--	p_delivery_detail_id=>x_dlv_detail_info.delivery_detail_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_volume_uom;
	END IF;


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_dlv_dtl_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_dlv_dtl_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_dlv_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_dlv_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_dlg_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_dlg_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_gross_weight THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_gross_weight');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_weight_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_weight_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_volume THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_volume');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_volume_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_volume_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Dlv_Detail_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Dlv_Detail_Info');

END  Validate_Dlv_Detail_Info;

--Validates a single cached carrier structure

PROCEDURE Validate_Carrier_Info(
	x_carrier_info IN OUT NOCOPY TL_CARRIER_PREF_REC_TYPE,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Validate_Carrier_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(x_carrier_info.carrier_id IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_carrier_id;
	END IF;

          -- VVP:09/18/03
          -- Per Hema, out of route charges need to be calculated
          -- regardless of distance calc method, eventhough typicaly
          -- this charge is not needed for Full Route method
          -- Also, if max_out_of_route is NULL, this means that no charge to be applied
          -- - this is not the same as max_out_of_route=0

	IF(x_carrier_info.max_out_of_route IS NULL)
	THEN
		-- x_carrier_info.max_out_of_route:=0;
		x_carrier_info.max_out_of_route:=NULL;
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_max_out_of_route;
	END IF;

	IF(x_carrier_info.min_cm_distance IS NULL)
	THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_min_cm_distance;
		x_carrier_info.min_cm_distance:=0;
	END IF;

	IF(x_carrier_info.min_cm_time IS NULL)
	THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_min_cm_time;
		x_carrier_info.min_cm_time:=0;
	END IF;

	IF(x_carrier_info.cm_free_dh_mileage IS NULL)
	THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_free_dh_mileage;
		x_carrier_info.cm_free_dh_mileage:=0;
	END IF;

	IF(x_carrier_info.cm_first_load_discount_flag IS NULL)
	THEN
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_frst_ld_dsc_flg;
		x_carrier_info.cm_first_load_discount_flag:='Y';
	END IF;


	IF(x_carrier_info.currency IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_currency',
		--	p_carrier_id=>x_carrier_info.carrier_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_currency;
	END IF;

	IF(x_carrier_info.cm_rate_variant IS NULL)
	THEN
		null;

		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_cm_rate_variant',
		--	p_carrier_id=>x_carrier_info.carrier_id);

	        --raise error only if the trip is part of continous move
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_rate_variant;
	END IF;

	IF(x_carrier_info.unit_basis IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_unit_basis',
		--	p_carrier_id=>x_carrier_info.carrier_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_unit_basis;
	END IF;

	IF(x_carrier_info.weight_uom IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_weight_uom',
		--	p_carrier_id=>x_carrier_info.carrier_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_weight_uom;
	END IF;

	IF(x_carrier_info.volume_uom IS NULL)
	THEN

		--Show only generic message

		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_volume_uom',
		--	p_carrier_id=>x_carrier_info.carrier_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_volume_uom;
	END IF;

	IF(x_carrier_info.distance_uom IS NULL)
	THEN

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_distance_uom',
		--	p_carrier_id=>x_carrier_info.carrier_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_distance_uom;
	END IF;


	IF(x_carrier_info.time_uom IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Validate_Carrier_Info',
		--	p_exc=>'g_tl_car_no_time_uom',
		--	p_carrier_id=>x_carrier_info.carrier_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_time_uom;
	END IF;

	--IF(x_carrier_info.region_level IS NULL)
	--THEN

	--END IF;

	IF(x_carrier_info.distance_calculation_method IS NULL)
	THEN
		x_carrier_info.distance_calculation_method:='FULL_ROUTE';
	END IF;

	IF((x_carrier_info.dim_factor IS NULL)
		OR (x_carrier_info.dim_factor=0)
		OR(x_carrier_info.dim_weight_uom IS NULL)
		OR (x_carrier_info.dim_volume_uom IS NULL)
		OR (x_carrier_info.dim_length_uom IS NULL) )
	THEN
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Dim Factor is:'||
		x_carrier_info.dim_factor||' Dim weight UOM:'||x_carrier_info.dim_weight_uom||
		'Dim Vol UOM:'||x_carrier_info.dim_volume_uom
		||' Dim Dimension UOM:'||x_carrier_info.dim_length_uom);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Resetting Dim parameters');

		x_carrier_info.dim_factor:=NULL;
		x_carrier_info.dim_weight_uom:=NULL;
		x_carrier_info.dim_volume_uom:=NULL;
		x_carrier_info.dim_length_uom:=NULL;
		x_carrier_info.dim_min_volume:=NULL;
	END IF;


	IF (x_carrier_info.dim_min_volume IS NULL)
	THEN
	    x_carrier_info.dim_min_volume:=0;
	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_carrier_id THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_carrier_id');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_max_out_of_route THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_max_out_of_route');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_min_cm_distance THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_min_cm_distance');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_min_cm_time THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_min_cm_time');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_free_dh_mileage THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_cm_free_dh_mileage');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_frst_ld_dsc_flg THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_cm_frst_ld_dsc_flg');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_currency THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_currency');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_rate_variant THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_cm_rate_variant');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_unit_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_unit_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_weight_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_weight_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_volume_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_volume_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_distance_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_distance_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_time_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_time_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Carrier_Info');

END  Validate_Carrier_Info;


PROCEDURE Validate_Trip_Cache(
	p_trip_index IN NUMBER,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Validate_Trip_Cache','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF( g_tl_trip_rows.EXISTS(p_trip_index)  AND g_tl_carrier_pref_rows.EXISTS(p_trip_index))
	THEN

		IF ((g_tl_trip_rows(p_trip_index).continuous_move = 'Y')
			AND (g_tl_carrier_pref_rows(p_trip_index).cm_rate_variant IS NULL))
		THEN
			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Validate_Trip_Cache',
			--	p_exc=>'g_tl_car_no_cm_rate_variant',
			--	p_carrier_id=>g_tl_carrier_pref_rows(p_trip_index).carrier_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_rate_variant;

		END IF;
	ELSE
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trip_index_invalid;

	END IF;






        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Cache');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_car_no_cm_rate_variant THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Cache',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_car_no_cm_rate_variant');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Cache');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trip_index_invalid THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Cache',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trip_index_invalid');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Cache');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Validate_Trip_Cache',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Validate_Trip_Cache');


END Validate_Trip_Cache;


PROCEDURE Partially_Delete_Cache(
	p_trip_index IN NUMBER,
	p_carrier_index	IN NUMBER,
	p_stop_index IN NUMBER,
	p_dleg_index IN NUMBER,
	p_child_dleg_index IN NUMBER) IS
BEGIN

	g_tl_trip_rows.DELETE(p_trip_index);
	g_tl_carrier_pref_rows.DELETE(p_carrier_index);

	g_tl_trip_stop_rows.DELETE(p_stop_index,g_tl_trip_stop_rows.LAST);
	g_tl_delivery_leg_rows.DELETE(p_dleg_index,g_tl_delivery_leg_rows.LAST);
	g_tl_chld_delivery_leg_rows.DELETE(p_child_dleg_index,g_tl_chld_delivery_leg_rows.LAST);

END Partially_Delete_Cache;

--Deletes everything in the global cached structures

PROCEDURE Delete_Cache(x_return_status OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Delete_Cache','start');

	--Delivery Leg Cache
	g_tl_delivery_leg_rows.DELETE;

	--Child Delivery Leg Cache
	g_tl_chld_delivery_leg_rows.DELETE;


	--Trip Cache
	g_tl_trip_rows.DELETE;

	--Trip Stop Rows
	g_tl_trip_stop_rows.DELETE;

	--Carrier preference cache
	g_tl_carrier_pref_rows.DELETE;


	--Delivery Detail map cache

	g_tl_delivery_detail_map.DELETE;

	--Delivery to delivery detail hash

	g_tl_delivery_detail_hash.DELETE;


	--Delete cache of delivery details

	g_tl_shipment_line_rows.DELETE;


	g_tl_int_shipment_line_rows.DELETE;


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Cache');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Delete_Cache',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Cache');

END Delete_Cache;

-- Adds the delivery detail record into the gloabal cache

PROCEDURE Insert_Into_Dlv_Dtl_Cache(
	p_dlv_dtl_rec IN FTE_FREIGHT_PRICING.shipment_line_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_map_index NUMBER;
	l_map_rec TL_DLV_DETAIL_MAP_REC_TYPE;


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Into_Dlv_Dtl_Cache','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	IF ( NOT ( g_tl_shipment_line_rows.EXISTS(
		p_dlv_dtl_rec.delivery_detail_id ) ) )
	THEN

		--Add the association that this dlv detail belongs to a specific delivery

		IF (g_tl_delivery_detail_map.LAST IS NULL)
		THEN
			l_map_index:=1;
		ELSE
			l_map_index:=g_tl_delivery_detail_map.LAST+1;
		END IF;
		IF
		(NOT(g_tl_delivery_detail_hash.EXISTS(p_dlv_dtl_rec.delivery_id)
		))
		THEN
			g_tl_delivery_detail_hash(p_dlv_dtl_rec.delivery_id):=
			l_map_index;

		END IF;

		l_map_rec.delivery_id:=p_dlv_dtl_rec.delivery_id;
		l_map_rec.delivery_detail_id:=p_dlv_dtl_rec.delivery_detail_id;


		g_tl_delivery_detail_map(l_map_index):=l_map_rec;


		--Add to cache

		g_tl_shipment_line_rows(
			p_dlv_dtl_rec.delivery_detail_id):=p_dlv_dtl_rec;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Into_Dlv_Dtl_Cache');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Into_Dlv_Dtl_Cache',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Into_Dlv_Dtl_Cache');

END Insert_Into_Dlv_Dtl_Cache;

-- Consolidated the records from WSH_CARRIER, WSH_CARRIER_SERVICE
--Into a single record
--Use the info in wsh_carrier_service, if not fall back on wsh_carrier

PROCEDURE Combine_Carrier_Info(
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_carrier_service_pref_rec IN OUT NOCOPY TL_CARRIER_PREF_REC_TYPE,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Combine_Carrier_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	IF (x_carrier_service_pref_rec.carrier_id IS NULL)
	THEN
		x_carrier_service_pref_rec.carrier_id:=
			p_carrier_pref_rec.carrier_id;
	END IF;

	IF (x_carrier_service_pref_rec.max_out_of_route IS NULL)
	THEN
		x_carrier_service_pref_rec.max_out_of_route:=
			p_carrier_pref_rec.max_out_of_route;
	END IF;

	IF (x_carrier_service_pref_rec.min_cm_distance IS NULL)
	THEN
		x_carrier_service_pref_rec.min_cm_distance:=
			p_carrier_pref_rec.min_cm_distance;
	END IF;

	IF (x_carrier_service_pref_rec.min_cm_time IS NULL)
	THEN
		x_carrier_service_pref_rec.min_cm_time:=
			p_carrier_pref_rec.min_cm_time;
	END IF;

	IF (x_carrier_service_pref_rec.cm_free_dh_mileage IS NULL)
	THEN
		x_carrier_service_pref_rec.cm_free_dh_mileage:=
			p_carrier_pref_rec.cm_free_dh_mileage;
	END IF;

	IF (x_carrier_service_pref_rec.cm_first_load_discount_flag IS NULL)
	THEN
		x_carrier_service_pref_rec.cm_first_load_discount_flag:=
			p_carrier_pref_rec.cm_first_load_discount_flag;
	END IF;

	IF (x_carrier_service_pref_rec.currency IS NULL)
	THEN
		x_carrier_service_pref_rec.currency:=
			p_carrier_pref_rec.currency;
	END IF;

	IF (x_carrier_service_pref_rec.cm_rate_variant IS NULL)
	THEN
		x_carrier_service_pref_rec.cm_rate_variant:=
			p_carrier_pref_rec.cm_rate_variant;
	END IF;

	IF (x_carrier_service_pref_rec.unit_basis IS NULL)
	THEN
		x_carrier_service_pref_rec.unit_basis:=
			p_carrier_pref_rec.unit_basis;
	END IF;

	IF (x_carrier_service_pref_rec.weight_uom_class IS NULL)
	THEN
		x_carrier_service_pref_rec.weight_uom_class:=
			p_carrier_pref_rec.weight_uom_class;
	END IF;

	IF (x_carrier_service_pref_rec.weight_uom IS NULL)
	THEN
		x_carrier_service_pref_rec.weight_uom:=
			p_carrier_pref_rec.weight_uom;
	END IF;

	IF (x_carrier_service_pref_rec.volume_uom_class IS NULL)
	THEN
		x_carrier_service_pref_rec.volume_uom_class:=
			p_carrier_pref_rec.volume_uom_class;
	END IF;

	IF (x_carrier_service_pref_rec.volume_uom IS NULL)
	THEN
		x_carrier_service_pref_rec.volume_uom:=
			p_carrier_pref_rec.volume_uom;
	END IF;

	IF (x_carrier_service_pref_rec.distance_uom_class IS NULL)
	THEN
		x_carrier_service_pref_rec.distance_uom_class:=
			p_carrier_pref_rec.distance_uom_class;
	END IF;

	IF (x_carrier_service_pref_rec.distance_uom IS NULL)
	THEN
		x_carrier_service_pref_rec.distance_uom:=
			p_carrier_pref_rec.distance_uom;
	END IF;

	IF (x_carrier_service_pref_rec.time_uom_class IS NULL)
	THEN
		x_carrier_service_pref_rec.time_uom_class:=
			p_carrier_pref_rec.time_uom_class;
	END IF;

	IF (x_carrier_service_pref_rec.time_uom IS NULL)
	THEN
		x_carrier_service_pref_rec.time_uom:=
			p_carrier_pref_rec.time_uom;
	END IF;

	IF (x_carrier_service_pref_rec.region_level IS NULL)
	THEN
		x_carrier_service_pref_rec.region_level:=
			p_carrier_pref_rec.region_level;
	END IF;

	IF (x_carrier_service_pref_rec.distance_calculation_method IS NULL)
	THEN
		x_carrier_service_pref_rec.distance_calculation_method:=
			p_carrier_pref_rec.distance_calculation_method;
	END IF;

	--Dim Weight

	IF((x_carrier_service_pref_rec.dim_factor IS NULL) OR(x_carrier_service_pref_rec.dim_factor=0))
	THEN
	--If Dim factor is null or 0 at carrier service level then take all the parameters at the carrier level
		x_carrier_service_pref_rec.dim_factor	 :=p_carrier_pref_rec.dim_factor;
		x_carrier_service_pref_rec.dim_weight_uom:=p_carrier_pref_rec.dim_weight_uom;
		x_carrier_service_pref_rec.dim_volume_uom:=p_carrier_pref_rec.dim_volume_uom;
		x_carrier_service_pref_rec.dim_length_uom:=p_carrier_pref_rec.dim_length_uom;
		x_carrier_service_pref_rec.dim_min_volume:=p_carrier_pref_rec.dim_min_volume;

	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Combine_Carrier_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Combine_Carrier_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Combine_Carrier_Info');

END Combine_Carrier_Info;



--Adds weight/vol/containers/pallets from the dlv detail into the stop
-- and dleg where it is picked up from

PROCEDURE Add_Pickup_Quantity(
	p_dlv_detail_rec  IN FTE_FREIGHT_PRICING.shipment_line_rec_type,
	p_carrier_pref IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dleg_quantity_tab IN OUT NOCOPY TL_dleg_quantity_tab_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_weight NUMBER;
l_volume NUMBER;
l_dim_weight NUMBER;

l_dleg_id NUMBER;
l_dleg_quantity_rec TL_dleg_quantity_rec_type;
l_pallet VARCHAR2(1);
l_mdc_add_to_stop VARCHAR2(1);
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Add_Pickup_Quantity','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_volume:=0;
	l_weight:=NULL;
	l_mdc_add_to_stop:='Y';

	IF((p_dlv_detail_rec.parent_delivery_leg_id IS NOT NULL)
	AND NOT ((p_dlv_detail_rec.assignment_type IS NOT NULL) AND (p_dlv_detail_rec.assignment_type='C')
	AND (p_dlv_detail_rec.parent_delivery_detail_id IS NULL) ))
	THEN
		l_mdc_add_to_stop:='N';
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'MDC Add to stop flag'||l_mdc_add_to_stop);

	l_dleg_id:=p_dlv_detail_rec.delivery_leg_id;

	IF(l_dleg_id IS NULL)
	THEN

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Add_Pickup_Quantity',
		--	p_exc=>'g_tl_no_dleg_id_in_dtl',
		--	p_delivery_detail_id=>p_dlv_detail_rec.delivery_detail_id);

		--throw an exception to delivery detail id
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_dleg_id_in_dtl;


	END IF;

	--Add to dleg table, if the dleg of the dtl does not exist
	--The dleg entry is used to hold summed quantities for all
	--details on the dleg

	IF (NOT(x_dleg_quantity_tab.EXISTS(l_dleg_id) ))
	THEN

		--Add new row

		l_dleg_quantity_rec.delivery_leg_id:=l_dleg_id;
		l_dleg_quantity_rec.weight:=0;
		l_dleg_quantity_rec.volume:=0;
		l_dleg_quantity_rec.pallets:=0;
		l_dleg_quantity_rec.containers:=0;
		x_dleg_quantity_tab(l_dleg_id):=l_dleg_quantity_rec;

	END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'
	picked up'||p_dlv_detail_rec.gross_weight);


	IF (p_dlv_detail_rec.volume IS NOT NULL)
	THEN


		l_volume:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
		p_dlv_detail_rec.volume_uom_code,
		p_carrier_pref.volume_uom,
		p_dlv_detail_rec.volume,
		0);


		IF (l_volume IS NULL)
		THEN

			--throw an exception UOM conversion failed
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail;


		END IF;

		--Add to stop

		IF (l_mdc_add_to_stop='Y')
		THEN

			x_stop_rec.pickup_volume:=x_stop_rec.pickup_volume + l_volume;
		END IF;

		--Add to dleg

		x_dleg_quantity_tab(l_dleg_id).volume:=
		x_dleg_quantity_tab(l_dleg_id).volume+l_volume;

	END IF;



	IF (p_dlv_detail_rec.gross_weight IS NOT NULL)
	THEN
		l_weight:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_dlv_detail_rec.weight_uom_code,
			p_carrier_pref.weight_uom,
			p_dlv_detail_rec.gross_weight,
			0);

		IF (l_weight IS NULL)
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(
				FTE_FREIGHT_PRICING_UTIL.G_DBG,
				' picked up is null');

			--throw an exception UOM conversion failed
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;


		END IF;

		IF (l_mdc_add_to_stop='Y')
		THEN


			Calculate_Dimensional_Weight(
				p_carrier_pref_rec=>p_carrier_pref,
				p_weight=>l_weight,
				p_volume=>l_volume,
				x_dim_weight=>l_dim_weight,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail;
			       END IF;
			END IF;


			--Add to stop

			x_stop_rec.pickup_weight:=x_stop_rec.pickup_weight + l_dim_weight;


			--Add to dleg

			x_dleg_quantity_tab(l_dleg_id).weight:=
			x_dleg_quantity_tab(l_dleg_id).weight+l_dim_weight;
		ELSE

			--Non dim weight
			x_dleg_quantity_tab(l_dleg_id).weight:=
			x_dleg_quantity_tab(l_dleg_id).weight+l_weight;


		END IF;


	END IF;









	Is_Detail_Pallet(
		p_dlv_detail_id=>	p_dlv_detail_rec.delivery_detail_id,
		x_pallet=>	l_pallet ,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_is_dtl_pallet_fail;
	       END IF;
	END IF;

	--Detail is either a container or a pallet,not both

	IF(l_pallet='Y')
	THEN
		x_dleg_quantity_tab(l_dleg_id).pallets:=
			x_dleg_quantity_tab(l_dleg_id).pallets+1;

		IF (l_mdc_add_to_stop='Y')
		THEN

			x_stop_rec.pickup_pallets:=x_stop_rec.pickup_pallets+1;
		END IF;

	--Number of containers is number of top level delivery details

	ELSIF (p_dlv_detail_rec.parent_delivery_detail_id IS NULL)
	THEN

		--Add to stop
		IF (l_mdc_add_to_stop='Y')
		THEN

			x_stop_rec.pickup_containers:=x_stop_rec.pickup_containers + 1;
		END IF;

		--Add to dleg

		x_dleg_quantity_tab(l_dleg_id).containers:=
			x_dleg_quantity_tab(l_dleg_id).containers+1;

	END IF;





        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Pickup_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_calc_dim_weight_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_is_dtl_pallet_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Pickup_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_is_dtl_pallet_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_dleg_id_in_dtl THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Pickup_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_dleg_id_in_dtl');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Pickup_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Pickup_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Pickup_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Pickup_Quantity');


END Add_Pickup_Quantity;

--Adds weight/vol/containers/pallets from the dlv detail into the stop
-- and dleg where it is droppped off


PROCEDURE Add_Dropoff_Quantity(
	p_dlv_detail_rec  IN FTE_FREIGHT_PRICING.shipment_line_rec_type,
	p_carrier_pref IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_return_status	OUT	NOCOPY	VARCHAR2)
IS


	l_weight	NUMBER;
	l_volume 	NUMBER;
	l_dim_weight    NUMBER;
	l_pallet VARCHAR2(1);
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Add_Dropoff_Quantity','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF((p_dlv_detail_rec.parent_delivery_leg_id IS NOT NULL)
	AND NOT ((p_dlv_detail_rec.assignment_type IS NOT NULL) AND (p_dlv_detail_rec.assignment_type='C')
	AND (p_dlv_detail_rec.parent_delivery_detail_id IS NULL) ))
	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'MDC Not adding Dropoff Quantity');

	ELSE

		l_weight:=NULL;
		l_volume:=0;



		IF (p_dlv_detail_rec.volume IS NOT NULL)
		THEN
			l_volume:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_dlv_detail_rec.volume_uom_code,
			p_carrier_pref.volume_uom,
			p_dlv_detail_rec.volume,
			0);

			IF (l_volume IS NULL)
			THEN

				--throw an exception UOM conversion failed
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail;

			END IF;

			x_stop_rec.dropoff_volume:=x_stop_rec.dropoff_volume +
				l_volume;

		END IF;


		IF (p_dlv_detail_rec.gross_weight IS NOT NULL)
		THEN
			l_weight:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_dlv_detail_rec.weight_uom_code,
			p_carrier_pref.weight_uom,
			p_dlv_detail_rec.gross_weight,
			0);

			IF (l_weight IS NULL)
			THEN

				--throw an exception UOM conversion failed
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;

			END IF;

			Calculate_Dimensional_Weight(
				p_carrier_pref_rec=>p_carrier_pref,
				p_weight=>l_weight,
				p_volume=>l_volume,
				x_dim_weight=>l_dim_weight,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail;
			       END IF;
			END IF;


			x_stop_rec.dropoff_weight:=x_stop_rec.dropoff_weight +
				l_dim_weight;
		END IF;




		Is_Detail_Pallet(
			p_dlv_detail_id=>	p_dlv_detail_rec.delivery_detail_id,
			x_pallet=>	l_pallet ,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_is_dtl_pallet_fail;
		       END IF;
		END IF;

		IF(l_pallet='Y')
		THEN
			x_stop_rec.dropoff_pallets:=
				x_stop_rec.dropoff_pallets+1;

		--Number of containers is number of top level delivery details

		ELSIF (p_dlv_detail_rec.parent_delivery_detail_id IS NULL)
		THEN
			x_stop_rec.dropoff_containers:=
				x_stop_rec.dropoff_containers +1;
		END IF;

	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Dropoff_Quantity');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Dropoff_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_calc_dim_weight_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Dropoff_Quantity');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_is_dtl_pallet_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Dropoff_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_is_dtl_pallet_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Dropoff_Quantity');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Dropoff_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Dropoff_Quantity');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Dropoff_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Dropoff_Quantity');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Dropoff_Quantity',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Dropoff_Quantity');


END Add_Dropoff_Quantity;

--Populates structure which will be used to query the MILEAGE TABLES

PROCEDURE Add_Inputs_For_Distance(
	p_from_stop_rec IN TL_TRIP_STOP_INPUT_REC_TYPE,
	p_to_stop_rec IN  TL_TRIP_STOP_INPUT_REC_TYPE,
	p_empty_flag IN VARCHAR2 ,
	x_stop_distance_tab IN OUT NOCOPY TL_stop_distance_tab_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_stop_distance_rec	TL_stop_distance_rec_type;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Add_Inputs_For_Distance','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_stop_distance_rec.from_stop_id:=p_from_stop_rec.stop_id;
	l_stop_distance_rec.from_location_id:=p_from_stop_rec.location_id;
	l_stop_distance_rec.to_stop_id:=p_to_stop_rec.stop_id;
	l_stop_distance_rec.to_location_id:=p_to_stop_rec.location_id;


	l_stop_distance_rec.cumulative_distance:=0;
	l_stop_distance_rec.empty_flag:=p_empty_flag;


FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
			l_stop_distance_rec.from_stop_id||' inserted in tab');

	x_stop_distance_tab(l_stop_distance_rec.from_stop_id):=
	l_stop_distance_rec;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Inputs_For_Distance');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Inputs_For_Distance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Inputs_For_Distance');


END  Add_Inputs_For_Distance;

PROCEDURE get_approximate_distance_time(
  p_from_location_id		IN NUMBER,
  p_to_location_id		IN NUMBER,
  x_distance			OUT NOCOPY NUMBER,
  x_distance_uom		OUT NOCOPY VARCHAR2,
  x_transit_time		OUT NOCOPY NUMBER,
  x_transit_time_uom		OUT NOCOPY VARCHAR2,
  x_return_status		OUT NOCOPY VARCHAR2)
IS
   CURSOR c_get_latitude_longitude (c_location_id NUMBER) IS
   SELECT latitude, longitude
   FROM   wsh_locations
   WHERE wsh_location_id = c_location_id;

  CURSOR c_get_dis_emp_constant IS
  SELECT tl_hway_dis_emp_constant
  FROM wsh_global_parameters;

  CURSOR c_get_speed IS
  SELECT avg_hway_speed
  FROM wsh_global_parameters;

  CURSOR c_get_distance_uom IS
  SELECT distance_uom
  FROM wsh_global_parameters;

  CURSOR c_get_time_uom IS
  SELECT time_uom
  FROM wsh_global_parameters;

  l_log_level             NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name              CONSTANT VARCHAR2(30)   := 'get_approximate_distance_time';
  l_return_status         VARCHAR2(1);

  l_no_latitude_longitude		EXCEPTION;
  l_no_highway_distance_multi	EXCEPTION;
  l_no_average_speed			EXCEPTION;

  l_from_latitude_in_degrees	NUMBER;
  l_from_latitude_in_radians	NUMBER;
  l_from_longitude_in_degrees	NUMBER;
  l_to_latitude_in_degrees	NUMBER;
  l_to_latitude_in_radians	NUMBER;
  l_to_longitude_in_degrees	NUMBER;

  l_earth_radius_multiplier	CONSTANT NUMBER := 69.075;
  l_pi				CONSTANT NUMBER := 3.1416;
  l_degrees_to_radians		CONSTANT NUMBER := l_pi/180;
  l_radians_to_degrees		CONSTANT NUMBER := 180/l_pi;
  l_distance_uom		CONSTANT VARCHAR2(30) := 'MI';

  l_highway_distance_multiplier NUMBER;
  l_average_speed_value		NUMBER;
  l_speed_distance_uom		VARCHAR2(30);
  l_speed_time_uom		VARCHAR2(30);

  l_euclidean_distance		NUMBER;
  l_highway_distance		NUMBER;
  l_transit_time		NUMBER;

  l_t1				NUMBER;
  l_t2				NUMBER;
  l_t3				NUMBER;
  l_t4				NUMBER;
  l_t5				NUMBER;
  l_t6				NUMBER;
BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
  FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name);

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_from_location_id='||p_from_location_id);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_to_location_id='||p_to_location_id);

  -- get latitude and longitude in degrees from wsh_locations
  OPEN c_get_latitude_longitude(p_from_location_id);
  FETCH c_get_latitude_longitude INTO l_from_latitude_in_degrees, l_from_longitude_in_degrees;
  CLOSE c_get_latitude_longitude;

  OPEN c_get_latitude_longitude(p_to_location_id);
  FETCH c_get_latitude_longitude INTO l_to_latitude_in_degrees, l_to_longitude_in_degrees;
  CLOSE c_get_latitude_longitude;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_from_latitude_in_degrees='||l_from_latitude_in_degrees);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_from_longitude_in_degrees='||l_from_longitude_in_degrees);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_to_latitude_in_degrees='||l_to_latitude_in_degrees);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_to_longitude_in_degrees='||l_to_longitude_in_degrees);

  IF (l_from_latitude_in_degrees is null) OR (l_from_longitude_in_degrees is null)
    OR (l_to_latitude_in_degrees is null) OR (l_to_longitude_in_degrees is null) THEN
    raise l_no_latitude_longitude;
  END IF;

  -- todo: get highway distance multiplier from profile option
  --l_highway_distance_multiplier := 0.17;
  OPEN c_get_dis_emp_constant;
  FETCH c_get_dis_emp_constant INTO l_highway_distance_multiplier;
  CLOSE c_get_dis_emp_constant;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_highway_distance_multiplier='||l_highway_distance_multiplier);

  IF l_highway_distance_multiplier is null THEN
    raise l_no_highway_distance_multi;
  END IF;

  -- todo: get average speed profile options
  --l_average_speed_value := 59;
  --l_speed_distance_uom := 'MI'; -- Mile
  --l_speed_time_uom := 'HR'; -- Hour
  OPEN c_get_speed;
  FETCH c_get_speed INTO l_average_speed_value;
  CLOSE c_get_speed;
  OPEN c_get_distance_uom;
  FETCH c_get_distance_uom INTO l_speed_distance_uom;
  CLOSE c_get_distance_uom;
  OPEN c_get_time_uom;
  FETCH c_get_time_uom INTO l_speed_time_uom;
  CLOSE c_get_time_uom;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_average_speed_value='||l_average_speed_value);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_speed_distance_uom='||l_speed_distance_uom);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_speed_time_uom='||l_speed_time_uom);

  IF (l_average_speed_value is null) OR (l_speed_distance_uom is null)
    OR (l_speed_time_uom is null) THEN
    raise l_no_average_speed;
  END IF;

  l_from_latitude_in_radians := l_degrees_to_radians * l_from_latitude_in_degrees;
  l_to_latitude_in_radians := l_degrees_to_radians * l_to_latitude_in_degrees;

  SELECT SIN(l_from_latitude_in_radians) INTO l_t1 FROM DUAL;
  SELECT SIN(l_to_latitude_in_radians) INTO l_t2 FROM DUAL;
  SELECT COS(l_from_latitude_in_radians) INTO l_t3 FROM DUAL;
  SELECT COS(l_to_latitude_in_radians) INTO l_t4 FROM DUAL;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_t1='||l_t1);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_t2='||l_t2);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_t3='||l_t3);
  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_t4='||l_t4);

  SELECT COS(l_degrees_to_radians * (l_from_longitude_in_degrees - l_to_longitude_in_degrees))
  INTO l_t5 FROM DUAL;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_t5='||l_t5);

  SELECT ACOS(l_t1 * l_t2 + l_t3 * l_t4 * l_t5)
  INTO l_t6 FROM DUAL;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_t6='||l_t6);

  l_euclidean_distance := l_earth_radius_multiplier * l_radians_to_degrees * l_t6;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_euclidean_distance='||l_euclidean_distance);

  l_highway_distance := (1 + l_highway_distance_multiplier) * l_euclidean_distance;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_highway_distance='||l_highway_distance);

  IF l_distance_uom <> l_speed_distance_uom THEN
    l_t6 := FTE_FREIGHT_PRICING_UTIL.convert_uom(
		l_speed_distance_uom,
		l_distance_uom,
		l_average_speed_value,
		0);
  ELSE
    l_t6 := l_average_speed_value;
  END IF;

  l_transit_time := l_highway_distance / l_t6;

  FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_transit_time='||l_transit_time);

  x_distance := l_highway_distance;
  x_distance_uom := l_distance_uom;
  x_transit_time := l_transit_time;
  x_transit_time_uom := l_speed_time_uom;

  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);


EXCEPTION
   WHEN l_no_latitude_longitude THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'l_no_latitude_longitude');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN l_no_highway_distance_multi THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'l_no_highway_distance_multi');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN l_no_average_speed THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'l_no_average_speed');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception(l_api_name,FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
END get_approximate_distance_time;

PROCEDURE Call_Mileage_Interface(
	p_stop_index IN NUMBER,
	p_dleg_index IN NUMBER,
	p_carrier_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_distance_tab IN OUT NOCOPY TL_stop_distance_tab_type,
	x_trip_rec IN OUT NOCOPY  TL_trip_data_input_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_stop_ref_first NUMBER;
l_stop_ref_last  NUMBER;
l_dleg_ref_first NUMBER;
l_dleg_ref_last  NUMBER;
l_trip_ref	 NUMBER;

i NUMBER;
j NUMBER;
k NUMBER;
l_from_location_tab wsh_util_core.id_tab_type;
l_to_location_tab wsh_util_core.id_tab_type;
l_distances_tab wsh_util_core.id_tab_type;
l_time_tab wsh_util_core.id_tab_type;
l_distance_uom	VARCHAR2(30);
l_time_uom	VARCHAR2(30);
l_distance NUMBER;
l_time NUMBER;
l_quantity	NUMBER;
l_carrier_distance_uom	VARCHAR2(30);
l_carrier_time_uom VARCHAR2(30);
l_location_tab FTE_DIST_INT_PKG.fte_dist_input_tab;
l_location_rec FTE_DIST_INT_PKG.fte_dist_input_rec;
l_location_log_tab FTE_DIST_INT_PKG.fte_dist_output_message_tab;

l_location_out_tab FTE_DIST_INT_PKG.fte_dist_output_tab;
l_mileage_api_fail VARCHAR2(1);

l_return_message VARCHAR2(32767);

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Call_Mileage_Interface','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	i:=1;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 1');
	--Copy all the stop from to's

	l_stop_ref_first:=i;
	j:=x_stop_distance_tab.FIRST;
	WHILE(j IS NOT NULL)
	LOOP
		l_location_rec.origin_id:=x_stop_distance_tab(j).from_location_id;
		l_location_rec.destination_id:=x_stop_distance_tab(j).to_location_id;

		l_location_tab(i):=l_location_rec;

		i:=i+1;
		j:=x_stop_distance_tab.NEXT(j);
	END LOOP;
	l_stop_ref_last:=i-1;

	l_dleg_ref_first:=i;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 2');

	--Copy all the dleg from to (for direct distance)
	--dlegs may not exist for a trip(dead heads)

	j:=p_dleg_index;
	WHILE((j IS NOT NULL) AND (g_tl_delivery_leg_rows.EXISTS(j)))
	LOOP
		l_location_rec.origin_id:=g_tl_delivery_leg_rows(j).pickup_location_id;
		l_location_rec.destination_id:=g_tl_delivery_leg_rows(j).dropoff_location_id;

		l_location_tab(i):=l_location_rec;

		i:=i+1;
		j:=g_tl_delivery_leg_rows.NEXT(j);
	END LOOP;
	IF (i <> l_dleg_ref_first)
	THEN
		l_dleg_ref_last:=i-1;
	ELSE
		l_dleg_ref_last:=l_dleg_ref_first;
	END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 3');
	--Copy trip from to (direct distance)
	l_trip_ref:=i;

	l_location_rec.origin_id:=g_tl_trip_stop_rows(p_stop_index).location_id;
	l_location_rec.destination_id:=g_tl_trip_stop_rows(g_tl_trip_stop_rows.LAST).location_id;

	l_location_tab(i):=l_location_rec;

	l_mileage_api_fail:='N';

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 4');

	--Call Mileage api
	 FTE_DIST_INT_PKG.GET_DISTANCE_TIME(
	    p_distance_input_tab=> l_location_tab,
	    p_location_region_flag=> 'L',
	    p_messaging_yn => 'Y',
	    p_api_version  => '1',
	    p_command => NULL,
	    x_distance_output_tab=> l_location_out_tab,
	    x_distance_message_tab => l_location_log_tab,
	    x_return_message =>l_return_message,
	    x_return_status => l_return_status);

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FTE_DIST_INT_PKG.GET_DISTANCE_TIME, status:'||l_return_status||' msg:'||l_return_message);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	       	    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,' Interface to mileage tables failed, using approximate distances, time:g_tl_get_dist_time_fail.');

	       	    l_mileage_api_fail:='Y';

		    l_warning_count:=l_warning_count+1;

		    --FTE_FREIGHT_PRICING_UTIL.setmsg (
			--p_api=>'Call_Mileage_Interface',
			--p_exc=>'g_tl_get_dist_time_fail',
			--p_msg_type=>'W',
			--p_trip_id=> x_trip_rec.trip_id);

		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_dist_time_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 5');
	IF (l_location_tab.FIRST IS NOT NULL)
	THEN
		FOR i in l_location_tab.FIRST .. l_location_tab.LAST
		LOOP
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' MILEAGE distances, time:'||l_location_tab(i).origin_id || ' : '||
				l_location_tab(i).destination_id);

		END LOOP;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 6');

	IF ((l_mileage_api_fail= 'N') AND (l_location_out_tab.FIRST IS NOT NULL) )
	THEN

		FOR i in l_location_out_tab.FIRST .. l_location_out_tab.LAST
		LOOP
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' MILEAGE distances, time:'||l_location_out_tab(i).origin_location_id || ' : '||
				l_location_out_tab(i).destination_location_id||' : '||l_location_out_tab(i).distance||' : '||
				l_location_out_tab(i).distance_uom||' : '||l_location_out_tab(i).transit_time||' : '|| l_location_out_tab(i).transit_time_uom);

		END LOOP;

	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 7');

	l_carrier_distance_uom:=p_carrier_rec.distance_uom;
	l_carrier_time_uom:=p_carrier_rec.time_uom;

	IF(NOT((l_carrier_time_uom IS NOT NULL) AND (l_carrier_distance_uom IS NOT NULL)))
	THEN

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Call_Mileage_Interface',
		--	p_exc=>'g_tl_no_car_time_dist_uom',
		--	p_carrier_id=>p_carrier_rec.carrier_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_car_time_dist_uom;

	END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 7');
	--Copy back stop distance,time

	i:=l_location_tab.FIRST;
	j:=x_stop_distance_tab.FIRST;
	k:=l_location_out_tab.FIRST;
	WHILE(j IS NOT NULL)
	LOOP
		x_stop_distance_tab(j).time:=NULL;
		x_stop_distance_tab(j).distance:=NULL;

		IF( (l_mileage_api_fail='N') AND  l_location_out_tab.EXISTS(k) AND (l_location_tab(i).origin_id=l_location_out_tab(k).origin_location_id)
		  AND(l_location_tab(i).destination_id=l_location_out_tab(k).destination_location_id))
		THEN
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Now using MILEAGE distances, time:'||l_location_tab(i).origin_id || ' : '||
			l_location_tab(i).destination_id);

			--Mileage API can return both distance and time or just one of them

                        -- VVP:09/17/03
                        -- If distance or time from mileage table is 0
                        -- then null it out so that it will
                        -- move on to mileage approximation

			IF ((l_location_out_tab(k).distance_uom IS NOT NULL) AND
				(l_location_out_tab(k).distance IS NOT NULL)
                               --AND (l_location_out_tab(k).distance <> 0)  -- 17-Sep-2004 if mileage returns 0 accept it
                           )
			THEN

				l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_location_out_tab(k).distance_uom,
					l_carrier_distance_uom,
					l_location_out_tab(k).distance,
					0);
				IF(l_quantity IS NULL)
				THEN

					raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

				END IF;

				x_stop_distance_tab(j).distance:=l_quantity;

			END IF;

			IF ((l_location_out_tab(k).transit_time_uom IS NOT NULL) AND
				(l_location_out_tab(k).transit_time IS NOT NULL)
                                -- AND (l_location_out_tab(k).transit_time <> 0)  -- If mileage returns 0 accept it
                              )
			THEN


				l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_location_out_tab(k).transit_time_uom,
					l_carrier_time_uom,
					l_location_out_tab(k).transit_time,
					0);

				IF(l_quantity IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_time_uom_conv_fail;
				END IF;
				x_stop_distance_tab(j).time:=l_quantity;
			END IF;


			k:=k+1;
		END IF;
		IF ((x_stop_distance_tab(j).time IS NULL) OR (x_stop_distance_tab(j).distance IS NULL))
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Now using approximate distances, time:'||l_location_tab(i).origin_id || ' : '||
			l_location_tab(i).destination_id);
			get_approximate_distance_time(
			  p_from_location_id =>l_location_tab(i).origin_id,
			  p_to_location_id =>l_location_tab(i).destination_id,
			  x_distance => l_distance,
			  x_distance_uom => l_distance_uom,
			  x_transit_time => l_time,
			  x_transit_time_uom =>l_time_uom,
  			  x_return_status =>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_apprx_dist_time_fail;
			       END IF;
			END IF;

  			IF (x_stop_distance_tab(j).distance IS NULL)
  			THEN
				l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
						l_distance_uom,
						l_carrier_distance_uom,
						l_distance,
						0);

				IF(l_quantity IS NULL)
				THEN

					raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

				END IF;

				x_stop_distance_tab(j).distance:=l_quantity;
			END IF;

			IF(x_stop_distance_tab(j).time IS NULL)
			THEN

				l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_time_uom,
					l_carrier_time_uom,
					l_time,
					0);

				IF(l_quantity IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_time_uom_conv_fail;
				END IF;

				x_stop_distance_tab(j).time:=l_quantity;
			END IF;

		END IF;


		j:=x_stop_distance_tab.NEXT(j);
		i:=i+1;
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 8');

	--Copy back dleg direct distance

	j:=p_dleg_index;
	WHILE((j IS NOT NULL) AND (g_tl_delivery_leg_rows.EXISTS(j)))
	LOOP

		g_tl_delivery_leg_rows(j).direct_distance:=NULL;

		IF((l_mileage_api_fail='N') AND l_location_out_tab.EXISTS(k) AND (l_location_tab(i).origin_id=l_location_out_tab(k).origin_location_id)
		  AND(l_location_tab(i).destination_id=l_location_out_tab(k).destination_location_id))
		THEN
                        --VVP: 09/18/03 : added distance<>0 condition
			IF ((l_location_out_tab(k).distance_uom IS NOT NULL) AND
				(l_location_out_tab(k).distance IS NOT NULL))
				--(l_location_out_tab(k).distance <> 0)) --If mileage returns 0 accept it
			THEN


				l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_location_out_tab(k).distance_uom,
					l_carrier_distance_uom,
					l_location_out_tab(k).distance,
					0);
				IF(l_quantity IS NULL)
				THEN

					raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

				END IF;

				g_tl_delivery_leg_rows(j).direct_distance:=l_quantity;

			END IF;
			k:=k+1;
		END IF;

		IF (g_tl_delivery_leg_rows(j).direct_distance IS NULL)
		THEN

			get_approximate_distance_time(
			  p_from_location_id =>l_location_tab(i).origin_id,
			  p_to_location_id =>l_location_tab(i).destination_id,
			  x_distance => l_distance,
			  x_distance_uom => l_distance_uom,
			  x_transit_time => l_time,
			  x_transit_time_uom =>l_time_uom,
  			  x_return_status =>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_apprx_dist_time_fail;
			       END IF;
			END IF;


			l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				l_distance_uom,
				l_carrier_distance_uom,
				l_distance,
				0);
			IF(l_quantity IS NULL)
			THEN

				raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

			END IF;

			g_tl_delivery_leg_rows(j).direct_distance:=l_quantity;

		END IF;

		i:=i+1;
		j:=g_tl_delivery_leg_rows.NEXT(j);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' DBG 9');

	--Copy back trip direct distance

	x_trip_rec.total_direct_distance:=NULL;

	IF((l_mileage_api_fail='N') AND l_location_out_tab.EXISTS(k) AND (l_location_tab(i).origin_id=l_location_out_tab(k).origin_location_id)
	  AND(l_location_tab(i).destination_id=l_location_out_tab(k).destination_location_id))
	THEN

		IF ((l_location_out_tab(k).distance_uom IS NOT NULL) AND
			(l_location_out_tab(k).distance IS NOT NULL))
			--AND (l_location_out_tab(k).distance <> 0))--If mileage returns 0 accept it
		THEN

			l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				l_location_out_tab(k).distance_uom,
				l_carrier_distance_uom,
				l_location_out_tab(k).distance,
				0);
			IF(l_quantity IS NULL)
			THEN

				raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

			END IF;
			x_trip_rec.total_direct_distance:=l_quantity;
		END IF;
		k:=k+1;

	END IF;

	IF (x_trip_rec.total_direct_distance IS NULL)
	THEN

		get_approximate_distance_time(
		  p_from_location_id =>l_location_tab(i).origin_id,
		  p_to_location_id =>l_location_tab(i).destination_id,
		  x_distance => l_distance,
		  x_distance_uom => l_distance_uom,
		  x_transit_time => l_time,
		  x_transit_time_uom =>l_time_uom,
		  x_return_status =>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_apprx_dist_time_fail;
		       END IF;
		END IF;


		l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			l_distance_uom,
			l_carrier_distance_uom,
			l_distance,
			0);
		IF(l_quantity IS NULL)
		THEN

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

		END IF;

		x_trip_rec.total_direct_distance:=l_quantity;
	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_apprx_dist_time_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_apprx_dist_time_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_dist_time_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_dist_time_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_car_time_dist_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_car_time_dist_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_time_dist_uom THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_time_dist_uom');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_time_dist THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_time_dist');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_time_dist_for_stop THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_time_dist_for_stop');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dist_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_time_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_time_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_time_dist_for_dleg THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_time_dist_for_dleg');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_time_dist_for_trip THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_time_dist_for_trip');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Call_Mileage_Interface',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Call_Mileage_Interface');

END Call_Mileage_Interface;


--Gets all the distances from the mileage tables

PROCEDURE Get_Distances(
	p_stop_index IN NUMBER,
	p_dleg_index IN NUMBER,
	p_carrier_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_distance_tab IN OUT NOCOPY TL_stop_distance_tab_type,
	x_trip_rec IN OUT NOCOPY  TL_trip_data_input_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS


	l_stop_index 	NUMBER;
	l_dleg_index 	NUMBER;
	i NUMBER;
	l_loaded_distance NUMBER;
	l_unloaded_distance NUMBER;
	l_cumulative_distance NUMBER;
	l_time	NUMBER;

        l_cum_dist_tmp_tab   WSH_UTIL_CORE.id_tab_type; --vvp
        l_prev_dist          NUMBER; --vvp

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Distances','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_stop_index:=p_stop_index;
	l_dleg_index:=p_dleg_index;

	--- GEt distances from mileage table API , store results back in
	--x_stop_distance_tab

	Call_Mileage_Interface(
		p_stop_index=>	p_stop_index,
		p_dleg_index=>	p_dleg_index,
		p_carrier_rec =>	p_carrier_rec,
		x_stop_distance_tab=>	x_stop_distance_tab,
		x_trip_rec=>	x_trip_rec,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_call_mileage_if_fail;
	       END IF;
	END IF;

	--Store distances in stop table
	l_stop_index:=p_stop_index;
	l_unloaded_distance:=0;
	l_loaded_distance:=0;
	l_cumulative_distance:=0;
	l_time:=0;
        l_prev_dist :=0;
	WHILE (l_stop_index IS NOT NULL)
	LOOP

		IF (g_tl_trip_stop_rows(l_stop_index).trip_id <>
		x_trip_rec.trip_id)
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'
			Exiting loop');
			EXIT;
		END IF;

		IF
		(x_stop_distance_tab.EXISTS(
			g_tl_trip_stop_rows(l_stop_index).stop_id))
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
			g_tl_trip_stop_rows(l_stop_index).stop_id||' is in tab'||x_stop_distance_tab(
			 g_tl_trip_stop_rows(l_stop_index).stop_id).distance);

			g_tl_trip_stop_rows(l_stop_index).distance_to_next_stop
				:=x_stop_distance_tab(
			 g_tl_trip_stop_rows(l_stop_index).stop_id).distance;


			g_tl_trip_stop_rows(l_stop_index).time_to_next_stop
				:=x_stop_distance_tab(
			 g_tl_trip_stop_rows(l_stop_index).stop_id).time;

			--add up time
			l_time:=l_time+x_stop_distance_tab(
			 g_tl_trip_stop_rows(l_stop_index).stop_id).time;

			IF
			(x_stop_distance_tab(
				g_tl_trip_stop_rows(l_stop_index).stop_id
				).empty_flag='N')
			THEN
				l_loaded_distance:=l_loaded_distance+
				x_stop_distance_tab(
					g_tl_trip_stop_rows(l_stop_index).stop_id
				).distance;
			ELSE
				l_unloaded_distance:=l_unloaded_distance+
				x_stop_distance_tab(
					g_tl_trip_stop_rows(
					l_stop_index
					).stop_id).distance;
			END IF;

                        -- VVP : 09/17/03
                        -- Replaced the commented out code with following code
                        -- to correct problems with cumulative distance logic
                        -- New table is used to hold cumulative distance
                        -- because x_stop_distance_tab
                        -- does not contain the last stop of the trip
                        -- <code>

                        l_cumulative_distance := l_cumulative_distance
                                                     + l_prev_dist;

                         -- now point prev_dist to current stop distance
                        l_prev_dist :=
			        x_stop_distance_tab(
				      g_tl_trip_stop_rows(l_stop_index).stop_id
				      ).distance;

                        -- this table holds cumulative distance for stops
                        l_cum_dist_tmp_tab(
			         g_tl_trip_stop_rows(l_stop_index).stop_id
			         )  :=l_cumulative_distance;
		        FTE_FREIGHT_PRICING_UTIL.print_msg(
                          FTE_FREIGHT_PRICING_UTIL.G_DBG,
                        'stop_id,cum_dist ->'||g_tl_trip_stop_rows(l_stop_index)
                        .stop_id||','||l_cumulative_distance);
                        -- </code>

                        /*   -- VVP - commented out 09/17/03
			l_cumulative_distance:=l_cumulative_distance+
			x_stop_distance_tab(
				g_tl_trip_stop_rows(l_stop_index).stop_id
				).distance;

			x_stop_distance_tab(
			 g_tl_trip_stop_rows(l_stop_index).stop_id
			 ).cumulative_distance:=l_cumulative_distance;
                        */

		ELSE
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
			g_tl_trip_stop_rows(l_stop_index).stop_id||' not in tab');

                        -- VVP : 09/17/03
                        -- <code>
                        l_cumulative_distance := l_cumulative_distance
                                                     + l_prev_dist;
                         -- current stop distance is 0
                        l_prev_dist :=0;

                        l_cum_dist_tmp_tab(
			         g_tl_trip_stop_rows(l_stop_index).stop_id
			         )  :=l_cumulative_distance;
		        FTE_FREIGHT_PRICING_UTIL.print_msg(
                          FTE_FREIGHT_PRICING_UTIL.G_DBG,
                        'stop_id,cum_dist ->'||g_tl_trip_stop_rows(l_stop_index)
                        .stop_id||','||l_cumulative_distance);
                        -- </code>

		END IF;

		l_stop_index:=g_tl_trip_stop_rows.NEXT(l_stop_index);

	END LOOP;

	--Store unloaded,loaded, total distance in trip rec

	x_trip_rec.loaded_distance:=l_loaded_distance;
	x_trip_rec.unloaded_distance:=l_unloaded_distance;
	x_trip_rec.total_trip_distance:=l_loaded_distance+l_unloaded_distance;
	x_trip_rec.time:=l_time;

	WHILE(g_tl_delivery_leg_rows.EXISTS(l_dleg_index))
	LOOP
                -- VVP : 09/17/03
                -- replaced the commented out code with following code
                -- to correct problems with cumulative distance logic

                -- <code>
		IF
		(l_cum_dist_tmp_tab.EXISTS(g_tl_delivery_leg_rows(l_dleg_index)
		.pickup_stop_id))
		THEN
			IF
			(l_cum_dist_tmp_tab.EXISTS(
				g_tl_delivery_leg_rows(
					l_dleg_index
				).dropoff_stop_id))
			THEN
			g_tl_delivery_leg_rows(l_dleg_index).distance:=
			l_cum_dist_tmp_tab(g_tl_delivery_leg_rows(l_dleg_index)
			.dropoff_stop_id) -
			l_cum_dist_tmp_tab(g_tl_delivery_leg_rows(l_dleg_index)
			.pickup_stop_id);
                        END IF;
                 END IF;
                -- </code>

                /*   -- VVP - commented out 09/17/03
		IF
		(x_stop_distance_tab.EXISTS(g_tl_delivery_leg_rows(l_dleg_index)
		.pickup_stop_id))
		THEN
			IF
			(x_stop_distance_tab.EXISTS(
				g_tl_delivery_leg_rows(
					l_dleg_index
				).dropoff_stop_id))
			THEN
			g_tl_delivery_leg_rows(l_dleg_index).distance:=
			x_stop_distance_tab(g_tl_delivery_leg_rows(l_dleg_index)
			.dropoff_stop_id).cumulative_distance  -
			x_stop_distance_tab(g_tl_delivery_leg_rows(l_dleg_index)
			.pickup_stop_id).cumulative_distance;
			ELSE
				g_tl_delivery_leg_rows(l_dleg_index).distance:=
				x_stop_distance_tab(
					g_tl_delivery_leg_rows(
						l_dleg_index
					).pickup_stop_id).distance;
			END IF;
		END IF;
                */



		l_dleg_index:=l_dleg_index+1;
	END LOOP;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Distances');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_call_mileage_if_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Distances',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_call_mileage_if_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Distances');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Distances',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Distances');



END Get_Distances;


--The quantities at the stop level are added to the trip level

PROCEDURE Update_Trip_With_Stop_Info(
	p_stop_rec IN TL_TRIP_STOP_INPUT_REC_TYPE ,
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Update_Trip_With_Stop_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_trip_rec.number_of_pallets:=x_trip_rec.number_of_pallets +
	p_stop_rec.pickup_pallets;
	x_trip_rec.number_of_containers:=x_trip_rec.number_of_containers +
	p_stop_rec.pickup_containers;
	x_trip_rec.total_weight:=x_trip_rec.total_weight +
	p_stop_rec.pickup_weight;
	x_trip_rec.total_volume:=x_trip_rec.total_volume +
	p_stop_rec.pickup_volume;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Trip_With_Stop_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Trip_With_Stop_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Trip_With_Stop_Info');

END Update_Trip_With_Stop_Info;


--GEts all the facility related information

PROCEDURE Get_Facility_Info(
	p_stop_index IN NUMBER,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_fac_info_rec FTE_LOCATION_PARAMETERS_PKG.TL_FAC_INFO_REC_TYPE;
	l_fac_info_tab FTE_LOCATION_PARAMETERS_PKG.TL_FAC_INFO_TAB_TYPE;
	l_stop_index NUMBER;
	i NUMBER;
	l_return_status VARCHAR2(1);
	l_stop_rec  TL_TRIP_STOP_INPUT_REC_TYPE;



l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Facility_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_stop_index:=p_stop_index;
	i:=0;
	WHILE(g_tl_trip_stop_rows.EXISTS(l_stop_index))
	LOOP

		l_fac_info_rec.location_id:=
		g_tl_trip_stop_rows(l_stop_index).location_id;
		l_fac_info_rec.stop_id:=
		g_tl_trip_stop_rows(l_stop_index).stop_id;
		l_fac_info_tab(i):=l_fac_info_rec;
		i:=i+1;
		l_stop_index:=l_stop_index+1;
	END LOOP;

	FTE_LOCATION_PARAMETERS_PKG.Get_Fac_Info( l_fac_info_tab,l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		    	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,' Interface to facility failed:g_tl_get_fac_info_fail');
		    	l_warning_count:=l_warning_count+1;

		    	FTE_FREIGHT_PRICING_UTIL.setmsg (
			 p_api=>'Get_Facility_Info',
			 p_exc=>'g_tl_get_fac_info_fail',
			 p_msg_type=>'W',
			 p_trip_id=> g_tl_trip_stop_rows(p_stop_index).trip_id);

			--raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_fac_info_fail;
	       END IF;
	END IF;

	l_stop_index:=p_stop_index;
	i:=0;
	WHILE(l_fac_info_tab.EXISTS(i))
	LOOP

		l_stop_rec:=g_tl_trip_stop_rows(l_stop_index);
		l_fac_info_rec:=l_fac_info_tab(i);

		l_stop_rec.loading_protocol:=l_fac_info_rec.loading_protocol;


		l_stop_rec.fac_charge_basis:=l_fac_info_rec.fac_charge_basis;


		l_stop_rec.fac_handling_time:=l_fac_info_rec.fac_handling_time;

		l_stop_rec.fac_currency:=l_fac_info_rec.fac_currency;

		l_stop_rec.fac_modifier_id:=l_fac_info_rec.fac_modifier_id;
		l_stop_rec.fac_pricelist_id:=l_fac_info_rec.fac_pricelist_id;

		l_stop_rec.fac_weight_uom_class:=
			l_fac_info_rec.fac_weight_uom_class;
		l_stop_rec.fac_weight_uom:=l_fac_info_rec.fac_weight_uom;

		l_stop_rec.fac_volume_uom_class:=
			l_fac_info_rec.fac_volume_uom_class;
		l_stop_rec.fac_volume_uom:=l_fac_info_rec.fac_volume_uom;

		l_stop_rec.fac_distance_uom_class:=
			l_fac_info_rec.fac_distance_uom_class;
		l_stop_rec.fac_distance_uom:=l_fac_info_rec.fac_distance_uom;

		l_stop_rec.fac_time_uom_class:=
			l_fac_info_rec.fac_time_uom_class;
		l_stop_rec.fac_time_uom:=l_fac_info_rec.fac_time_uom;


		g_tl_trip_stop_rows(l_stop_index):=l_stop_rec;

		i:=i+1;
		l_stop_index:=l_stop_index+1;
	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Facility_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_fac_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Facility_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_fac_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Facility_Info');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Facility_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Facility_Info');


END Get_Facility_Info;


--Gets the region(at the level specified by the carrier) for the location

PROCEDURE Get_Region_For_Location(
	p_location_id IN NUMBER,
	p_region_type IN VARCHAR2,
	x_region_id	IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS


CURSOR get_region_id(c_location_id IN NUMBER, c_region_type IN NUMBER) IS
	SELECT 	rl.region_id,
		rl.region_type
	FROM wsh_region_locations rl
	WHERE 	rl.location_id= c_location_id and
		rl.region_type >= c_region_type
	ORDER BY rl.region_type ASC;

CURSOR get_exact_region_id(c_region_id IN NUMBER,c_region_type IN NUMBER) IS
	SELECT 	r.region_id,
		r.region_type,
		r.parent_region_id
	FROM 	wsh_regions r
	WHERE 	r.region_id = c_region_id AND
		r.region_type >=c_region_type;


l_region_id 	NUMBER;
l_region_type	NUMBER;
l_parent_region_id NUMBER;
l_flag 	VARCHAR2(1);
l_region_type_id NUMBER;
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Region_For_Location','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_region_id:=NULL;

	l_region_type_id:=NULL;

	IF(p_region_type='COUNTRY')
	THEN
		l_region_type_id:=0;
	ELSIF(p_region_type='STATE')
	THEN
		l_region_type_id:=1;
	ELSIF(p_region_type='CITY')
	THEN
		l_region_type_id:=2;
	ELSIF(p_region_type='POSTAL_CODE')
	THEN
		l_region_type_id:=3;
	END IF;

	IF (l_region_type_id IS NOT NULL)
	THEN


		OPEN get_region_id(p_location_id,l_region_type_id);
		FETCH get_region_id INTO l_region_id,l_region_type;
		IF (get_region_id%FOUND)
		THEN


			IF(l_region_type = l_region_type_id)
			THEN
				x_region_id:=l_region_id;
			ELSE
				l_flag:='Y';
				--Keep going up the region hierarchy till region a
				--at the right level is found
				WHILE(l_flag = 'Y')
				LOOP

					OPEN get_exact_region_id(
						l_region_id,
						l_region_type_id);
					FETCH get_exact_region_id INTO
						l_region_id,
						l_region_type,
						l_parent_region_id;
					IF (get_exact_region_id%FOUND)
					THEN
						IF (l_region_type=l_region_type_id)
						THEN

							x_region_id:=l_region_id;
							l_flag:='N';
						ELSIF((l_parent_region_id IS NOT NULL)
						 AND(l_parent_region_id <> -1))
						THEN
						     l_region_id:=l_parent_region_id;
						ELSE

						      l_flag:='N';

						END IF;
					ELSE
						l_flag:='N';
					END IF;
					CLOSE get_exact_region_id;
				END LOOP;

			END IF;


		END IF;
		CLOSE get_region_id;

	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Region_For_Location');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Region_For_Location',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Region_For_Location');


END Get_Region_For_Location;

PROCEDURE Display_Trip_Cache_Row(p_trip_rec  TL_trip_data_input_rec_type) IS

	l_warning_count 	NUMBER:=0;
BEGIN
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'START TRIP');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  TripID             :'||p_trip_rec.trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Lane ID            :'||p_trip_rec.lane_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  ScheduleId         :'||p_trip_rec.schedule_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Service Type       :'||p_trip_rec.service_type);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Vehicle            :'||p_trip_rec.vehicle_type);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PriceList          :'||p_trip_rec.price_list_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Triploaded         :'||p_trip_rec.loaded_distance);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Unloaded           :'||p_trip_rec.unloaded_distance);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Pallets            :'||p_trip_rec.number_of_pallets);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG ,
        '  Containers         :'||p_trip_rec.number_of_containers);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Time               :'||p_trip_rec.time);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Stops              :'||p_trip_rec.number_of_stops);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Distance           :'||p_trip_rec.total_trip_distance);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Direct             :'||p_trip_rec.total_direct_distance);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Distance Method    :'||p_trip_rec.distance_method);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Total Weight       :'||p_trip_rec.total_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Total Volume       :'||p_trip_rec.total_volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Continuous Move    :'||p_trip_rec.continuous_move);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Trip departure     :'||p_trip_rec.planned_departure_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Arrival            :'||p_trip_rec.planned_arrival_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Deadhead           :'||p_trip_rec.dead_head);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  StopRef            :'||p_trip_rec.stop_reference);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DLegRef            :'||p_trip_rec.delivery_leg_reference);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Child DLegRef      :'||p_trip_rec.child_dleg_reference);

    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'END TRIP');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');

END Display_Trip_Cache_Row;

PROCEDURE Display_Carrier_Cache_Row(p_carrier_rec   TL_CARRIER_PREF_REC_TYPE) IS

	l_warning_count 	NUMBER:=0;
BEGIN


    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'START CARRIER');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Carrier ID         :'||p_carrier_rec.carrier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  MaxOutRoute        :'||p_carrier_rec.max_out_of_route);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  MinCMDist          :'||p_carrier_rec.min_cm_time);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  MinCMTime          :'||p_carrier_rec.min_cm_time);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FreeDeadHeadMileage:'||p_carrier_rec.cm_free_dh_mileage);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FirstLoadDiscFlag  :'||p_carrier_rec.cm_first_load_discount_flag);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Currency           :'||p_carrier_rec.currency);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Discount/Rate      :'||p_carrier_rec.cm_rate_variant);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  UnitBasis          :'||p_carrier_rec.unit_basis);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  WeightUomClass     :'||p_carrier_rec.weight_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  WeightUom          :'||p_carrier_rec.weight_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  VolumeUomClass     :'||p_carrier_rec.volume_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  VolumeUom          :'||p_carrier_rec.volume_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DistanceUomClass   :'||p_carrier_rec.distance_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DistanceUom        :'||p_carrier_rec.distance_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  TimeUomClass       :'||p_carrier_rec.time_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  TimeUom            :'||p_carrier_rec.time_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  RegionLevel        :'||p_carrier_rec.region_level);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DistanceCalcMethod :'||p_carrier_rec.distance_calculation_method);

    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Dim Factor	      :'||p_carrier_rec.dim_factor);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Dim Weight UOM     :'||p_carrier_rec.dim_weight_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Dim Volume UOM     :'||p_carrier_rec.dim_volume_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Dim Dimension UOM  :'||p_carrier_rec.dim_length_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Dim Min Vol        :'||p_carrier_rec.dim_min_volume);




    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'END CARRIER');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');

END Display_Carrier_Cache_Row;


PROCEDURE Display_Stop_Cache_Row(p_stop_rec  TL_TRIP_STOP_INPUT_REC_TYPE) IS

	l_warning_count 	NUMBER:=0;
BEGIN

    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'START STOP');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  StopID             :'||p_stop_rec.stop_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  TripID             :'||p_stop_rec.trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Location           :'||p_stop_rec.location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  WkDayLay           :'||p_stop_rec.weekday_layovers);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  WkEndLay           :'||p_stop_rec.weekend_layovers);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Distance           :'||p_stop_rec.distance_to_next_stop);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Time               :'||p_stop_rec.time_to_next_stop);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PkWt               :'||p_stop_rec.pickup_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PkVol              :'||p_stop_rec.pickup_volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PkPallets          :'||p_stop_rec.pickup_pallets);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PkContainers       :'||p_stop_rec.pickup_containers);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Protocol           :'||p_stop_rec.loading_protocol);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DrpWt              :'||p_stop_rec.dropoff_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DrpVol             :'||p_stop_rec.dropoff_volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DrpPallets         :'||p_stop_rec.dropoff_pallets);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DrpContainer       :'||p_stop_rec.dropoff_containers);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Region             :'||p_stop_rec.stop_region);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Zone               :'||p_stop_rec.stop_zone);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Arrival            :'||p_stop_rec.planned_arrival_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Departure          :'||p_stop_rec.planned_departure_date);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Stop Type          :'||p_stop_rec.stop_type);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacPickupWt        :'||p_stop_rec.fac_pickup_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacPickupVol       :'||p_stop_rec.fac_pickup_volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacDropoffWt       :'||p_stop_rec.fac_dropoff_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacDropoffVol      :'||p_stop_rec.fac_dropoff_volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacChargeBasis     :'||p_stop_rec.fac_charge_basis);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacHandlingTime    :'||p_stop_rec.fac_handling_time);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacCurrency        :'||p_stop_rec.fac_currency);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacModifierId      :'||p_stop_rec.fac_modifier_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacPricelistId     :'||p_stop_rec.fac_pricelist_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacWeightUomClass  :'||p_stop_rec.fac_weight_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacWeightUom       :'||p_stop_rec.fac_weight_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacVolumeUomClass  :'||p_stop_rec.fac_volume_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacVolumeUom       :'||p_stop_rec.fac_volume_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacDistUomClass    :'||p_stop_rec.fac_distance_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacDistUom         :'||p_stop_rec.fac_distance_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacTimeUomClass    :'||p_stop_rec.fac_time_uom_class);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  FacTimeUom         :'||p_stop_rec.fac_time_uom);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'END STOP');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');

END Display_Stop_Cache_Row;


PROCEDURE Display_DLeg_Cache_Row(p_dleg_rec TL_delivery_leg_rec_type ) IS

	l_warning_count 	NUMBER:=0;
BEGIN
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'START DLEG');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DlegId             :'||p_dleg_rec.delivery_leg_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  TripId             :'||p_dleg_rec.trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DeliveryId         :'||p_dleg_rec.delivery_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PickstopId         :'||p_dleg_rec.pickup_stop_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  PickuplocationId   :'||p_dleg_rec.pickup_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DrpStopId          :'||p_dleg_rec.dropoff_stop_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DrpLocId           :'||p_dleg_rec.dropoff_location_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Weight             :'||p_dleg_rec.weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Volume             :'||p_dleg_rec.volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Pallets            :'||p_dleg_rec.pallets);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Containers         :'||p_dleg_rec.containers);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Distance           :'||p_dleg_rec.distance);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Direct Distance    :'||p_dleg_rec.direct_distance);


    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Parent dleg is     :'||p_dleg_rec.parent_dleg_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Children Weight    :'||p_dleg_rec.children_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Children Volume    :'||p_dleg_rec.children_volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Is parent          :'||p_dleg_rec.is_parent_dleg);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Parent no consol   :'||p_dleg_rec.parent_with_no_consol_lpn);



    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'END DLEG');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');

END Display_DLeg_Cache_Row;


PROCEDURE Display_Dlv_Detail_Cache_Row (p_dlv_det_rec
FTE_FREIGHT_PRICING.shipment_line_rec_type) IS

	l_warning_count 	NUMBER:=0;
BEGIN
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'START DELIVERY_DETAIL');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DlvDetailId        :'||p_dlv_det_rec.delivery_detail_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  DeliveryId         :'||p_dlv_det_rec.delivery_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  RepriceReqd        :'||p_dlv_det_rec.reprice_required);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  ParentDlvDetailId  :'||p_dlv_det_rec.parent_delivery_detail_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  GrossWt            :'||p_dlv_det_rec.gross_weight);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  WtUom              :'||p_dlv_det_rec.weight_uom_code);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Volume             :'||p_dlv_det_rec.volume);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  VolumeUom          :'||p_dlv_det_rec.volume_uom_code);

    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Assignment type    :'||p_dlv_det_rec.assignment_type);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Parent Dlv Id      :'||p_dlv_det_rec.parent_delivery_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        '  Parent Dleg id          :'||p_dlv_det_rec.parent_delivery_leg_id);


    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        'END DELIVERY_DETAIL');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' ');

END Display_Dlv_Detail_Cache_Row;

PROCEDURE Display_Cache IS

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
i NUMBER;

	l_warning_count 	NUMBER:=0;
BEGIN
    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;

    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Display_Cache','start');
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Starting cache display');

    i:=g_tl_trip_rows.FIRST;
    WHILE (( i IS NOT NULL) AND (g_tl_trip_rows.EXISTS(i)))
    LOOP
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     ' TRIP ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');

        Display_Trip_Cache_Row(
        	p_trip_rec	=>	g_tl_trip_rows(i));
        i:=g_tl_trip_rows.NEXT(i);
    END LOOP;



    i:=g_tl_trip_stop_rows.FIRST;
    WHILE (( i IS NOT NULL) AND (g_tl_trip_stop_rows.EXISTS(i)))
    LOOP
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --             ' STOP ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        Display_Stop_Cache_Row(
        	p_stop_rec	=>	g_tl_trip_stop_rows(i));
        i:=g_tl_trip_stop_rows.NEXT(i);
    END LOOP;


    i:=g_tl_delivery_leg_rows.FIRST;
    WHILE (( i IS NOT NULL) AND (g_tl_delivery_leg_rows.EXISTS(i)))
    LOOP

        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --             ' DLEG ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');


        Display_DLeg_Cache_Row(
        	p_dleg_rec	=>	g_tl_delivery_leg_rows(i));

        i:=g_tl_delivery_leg_rows.NEXT(i);
    END LOOP;


    i:=g_tl_chld_delivery_leg_rows.FIRST;
    WHILE (( i IS NOT NULL) AND (g_tl_chld_delivery_leg_rows.EXISTS(i)))
    LOOP

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                     ' CHILD DLEG ');
        Display_DLeg_Cache_Row(
        	p_dleg_rec	=>	g_tl_chld_delivery_leg_rows(i));

        i:=g_tl_chld_delivery_leg_rows.NEXT(i);
    END LOOP;



    i:=g_tl_carrier_pref_rows.FIRST;
    WHILE (( i IS NOT NULL) AND (g_tl_carrier_pref_rows.EXISTS(i)))
    LOOP
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --             ' CARRIER ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        Display_Carrier_Cache_Row(
        	p_carrier_rec	=>	g_tl_carrier_pref_rows(i));
        i:=g_tl_carrier_pref_rows.NEXT(i);
    END LOOP;


    i:=g_tl_shipment_line_rows.FIRST;
    WHILE (( i IS NOT NULL) AND
        (g_tl_shipment_line_rows.EXISTS(i)))
    LOOP
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --             ' DLV DETAIL ');
        -- FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
        --     '  ');

        Display_Dlv_Detail_Cache_Row(
            p_dlv_det_rec =>	g_tl_shipment_line_rows(i));

        i:=g_tl_shipment_line_rows.NEXT(i);
    END LOOP;


    i:=g_tl_int_shipment_line_rows.FIRST;
    WHILE (( i IS NOT NULL) AND
        (g_tl_int_shipment_line_rows.EXISTS(i)))
    LOOP
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                    ' INT DLV DETAIL ');

        Display_Dlv_Detail_Cache_Row(
            p_dlv_det_rec =>	g_tl_int_shipment_line_rows(i));

        i:=g_tl_int_shipment_line_rows.NEXT(i);
    END LOOP;



    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Display_Cache');

END  Display_Cache;


PROCEDURE Get_Stop_Type(x_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE)
IS

 	l_pickup_flag VARCHAR2(1);
 	l_dropoff_flag VARCHAR2(1);

BEGIN
	l_pickup_flag:='N';
	l_dropoff_flag:='N';

	IF ((x_stop_rec.pickup_weight >0) OR(x_stop_rec.pickup_volume>0) OR
	(x_stop_rec.pickup_pallets >0) OR(x_stop_rec.pickup_containers>0)
	)
	THEN
		l_pickup_flag:='Y';

	END IF;

	IF ((x_stop_rec.dropoff_weight >0) OR(x_stop_rec.dropoff_volume>0) OR
	(x_stop_rec.dropoff_pallets >0) OR(x_stop_rec.dropoff_containers>0)
	)
	THEN
		l_dropoff_flag:='Y';

	END IF;

	IF ((l_pickup_flag='Y') AND (l_dropoff_flag='N'))
	THEN

		x_stop_rec.stop_type:='PU';
	ELSIF ((l_pickup_flag='N') AND (l_dropoff_flag='Y'))
	THEN
		x_stop_rec.stop_type:='DO';
	ELSIF ((l_pickup_flag='Y') AND (l_dropoff_flag='Y'))
	THEN
		x_stop_rec.stop_type:='PD';
	ELSE
		x_stop_rec.stop_type:='NA';
	END IF;


END Get_Stop_Type;


-- Pass in either an internal stop id or an internal location id
-- Go through the cache and replace the dropoff stop id or relocation id with the physcial stop id or location id
PROCEDURE Replace_Dleg_Dropoff(
	p_dleg_index_start IN NUMBER,
	p_internal_stop_id IN NUMBER,
	p_internal_location_id IN NUMBER,
	p_actual_stop_id IN NUMBER,
	p_actual_location_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2)
IS
i NUMBER;

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Replace_Dleg_Dropoff','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	IF (p_internal_location_id IS NOT NULL)
	THEN

		i:=p_dleg_index_start;
		WHILE (( i IS NOT NULL) AND (g_tl_delivery_leg_rows.EXISTS(i)))
		LOOP
			IF (g_tl_delivery_leg_rows(i).dropoff_location_id = p_internal_location_id)
			THEN
				g_tl_delivery_leg_rows(i).dropoff_location_id:=p_actual_location_id;
			END IF;
			i:=g_tl_delivery_leg_rows.NEXT(i);
		END LOOP;


	ELSIF (p_internal_stop_id IS NOT NULL)
	THEN
		i:=p_dleg_index_start;
		WHILE (( i IS NOT NULL) AND (g_tl_delivery_leg_rows.EXISTS(i)))
		LOOP
			IF (g_tl_delivery_leg_rows(i).dropoff_stop_id = p_internal_stop_id)
			THEN
				g_tl_delivery_leg_rows(i).dropoff_stop_id:=p_actual_stop_id;
				g_tl_delivery_leg_rows(i).dropoff_location_id:=p_actual_location_id;
			END IF;
			i:=g_tl_delivery_leg_rows.NEXT(i);
		END LOOP;


	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Replace_Dleg_Dropoff');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Replace_Dleg_Dropoff',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Replace_Dleg_Dropoff');

END Replace_Dleg_Dropoff;



PROCEDURE Classify_Detail(
	x_dlv_dtl_rec IN OUT NOCOPY FTE_FREIGHT_PRICING.shipment_line_rec_type,
	x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

END Classify_Detail;


PROCEDURE Cache_Int_Containers (
	p_trip_id IN NUMBER,
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_return_status OUT NOCOPY VARCHAR2)
IS

CURSOR get_int_containers (c_trip_id IN NUMBER) RETURN
FTE_FREIGHT_PRICING.shipment_line_rec_type IS

	SELECT	dd.delivery_detail_id,
		dl.delivery_id,
		dl.delivery_leg_id,
		dl.reprice_required,
		da.parent_delivery_detail_id,
		dd.customer_id,
		dd.sold_to_contact_id,
		dd.inventory_item_id,
		dd.item_description,
		dd.hazard_class_id,
		dd.country_of_origin,
		dd.classification,
		dd.requested_quantity,
		dd.requested_quantity_uom,
		dd.master_container_item_id,
		dd.detail_container_item_id,
		dd.customer_item_id,
		dd.net_weight,
		dd.organization_id,
		dd.container_flag,
		dd.container_type_code,
		dd.container_name,
		dd.fill_percent,
		dd.gross_weight,
		dd.currency_code,dd.freight_class_cat_id,
		dd.commodity_code_cat_id,
		dd.weight_uom_code ,
		dd.volume,
		dd.volume_uom_code,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,
		da.type,
		da.parent_delivery_id,
		dl.parent_delivery_leg_id
	FROM 	wsh_delivery_assignments da,
		wsh_delivery_legs dl ,
		wsh_delivery_details dd,
		wsh_trip_stops s
	WHERE 	da.delivery_id=dl.delivery_id and
		dl.pick_up_stop_id=s.stop_id and
		s.trip_id = c_trip_id and
		da.parent_delivery_detail_id is NOT null and
		(da.type IS NULL OR da.type='S') and
		da.delivery_detail_id = dd.delivery_detail_id
	ORDER BY
		da.delivery_id;

	l_dlv_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;
	l_return_status VARCHAR2(1);

	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Cache_Int_Containers','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;




	OPEN get_int_containers(p_trip_id);
	FETCH get_int_containers INTO l_dlv_detail_rec;
	WHILE(get_int_containers%FOUND)
	LOOP
		IF ((l_dlv_detail_rec.delivery_leg_id IS NOT NULL)
			AND
			((g_tl_delivery_leg_rows.EXISTS(l_dlv_detail_rec.delivery_leg_id))
			AND (g_tl_delivery_leg_rows(l_dlv_detail_rec.delivery_leg_id).is_parent_dleg='Y'))
			OR
			((g_tl_chld_delivery_leg_rows.EXISTS(l_dlv_detail_rec.delivery_leg_id))
			AND (g_tl_chld_delivery_leg_rows(l_dlv_detail_rec.delivery_leg_id).is_parent_dleg='Y')))
		THEN


			Validate_Dlv_Detail_Info(
				p_carrier_pref_rec=>p_carrier_pref_rec,
				x_dlv_detail_info=>l_dlv_detail_rec,
				x_return_status	=>	l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_int_containers;

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail;
			       END IF;
			END IF;


			IF ( NOT ( g_tl_int_shipment_line_rows.EXISTS(
				l_dlv_detail_rec.delivery_detail_id ) ) )
			THEN

				--Add to cache

				g_tl_int_shipment_line_rows(
					l_dlv_detail_rec.delivery_detail_id):=l_dlv_detail_rec;
			END IF;



		END IF;


		FETCH get_int_containers INTO l_dlv_detail_rec;
	END LOOP;


	CLOSE get_int_containers;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Int_Containers');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Int_Containers',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Int_Containers');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Int_Containers',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Int_Containers');


END Cache_Int_Containers;


PROCEDURE	Sync_Child_Dleg_Cache(
	p_initial_dleg_index IN NUMBER,
	p_intial_child_dleg_index IN NUMBER,
	p_current_dleg_index IN NUMBER,
	p_chld_dleg_index IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2)
IS

l_parent_dleg_id NUMBER;
l_parent_dleg_index NUMBER;
l_parent_dleg_hash DBMS_UTILITY.NUMBER_ARRAY;
l_child_dleg_hash DBMS_UTILITY.NUMBER_ARRAY;

l_curr_dleg_list DBMS_UTILITY.NUMBER_ARRAY;
l_next_dleg_list DBMS_UTILITY.NUMBER_ARRAY;

l_parent_dleg_rec TL_delivery_leg_rec_type;
l_child_dleg_rec TL_delivery_leg_rec_type;
l_dleg_id NUMBER;
i NUMBER;
l_dlegs_with_no_consol_chld DBMS_UTILITY.NUMBER_ARRAY;
l_dlegs_with_no_consol DBMS_UTILITY.NUMBER_ARRAY;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Sync_Child_Dleg_Cache','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	--Build hash for access from dleg id to child dleg cache

	i:=p_intial_child_dleg_index;
	WHILE (i < p_chld_dleg_index)
	LOOP
		IF (g_tl_chld_delivery_leg_rows(i).is_parent_dleg='N')
		THEN
			l_curr_dleg_list(g_tl_chld_delivery_leg_rows(i).delivery_leg_id):=
				g_tl_chld_delivery_leg_rows(i).delivery_leg_id;
		END IF;

		IF(NOT (l_child_dleg_hash.EXISTS(g_tl_chld_delivery_leg_rows(i).delivery_leg_id)))
		THEN
			l_child_dleg_hash(g_tl_chld_delivery_leg_rows(i).delivery_leg_id):=i;

		ELSE
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Already in child hash:'||g_tl_chld_delivery_leg_rows(i).delivery_leg_id);

		END IF;

		i:=i+1;
	END LOOP;


	--Build hash for access from dleg id to dleg cache

	i:=p_initial_dleg_index;
	WHILE (i < p_current_dleg_index)
	LOOP

		IF (g_tl_delivery_leg_rows(i).is_parent_dleg='N')
		THEN
			l_curr_dleg_list(g_tl_delivery_leg_rows(i).delivery_leg_id):=
				g_tl_delivery_leg_rows(i).delivery_leg_id;
		END IF;


		IF(NOT (l_parent_dleg_hash.EXISTS(g_tl_delivery_leg_rows(i).delivery_leg_id)))
		THEN
			l_parent_dleg_hash(g_tl_delivery_leg_rows(i).delivery_leg_id):=i;

		ELSE
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Already in child hash:'||g_tl_delivery_leg_rows(i).delivery_leg_id);

		END IF;

		i:=i+1;
	END LOOP;




	i:=p_intial_child_dleg_index;
	WHILE (i < p_chld_dleg_index)
	LOOP
		l_parent_dleg_id:=g_tl_chld_delivery_leg_rows(i).parent_dleg_id;
		IF ((l_parent_dleg_id IS NOT NULL) AND (l_parent_dleg_hash.EXISTS(l_parent_dleg_id)))
		THEN
			l_parent_dleg_index:=l_parent_dleg_hash(l_parent_dleg_id);

			g_tl_delivery_leg_rows(l_parent_dleg_index).is_parent_dleg:='Y';

			IF (l_curr_dleg_list.EXISTS(g_tl_delivery_leg_rows(l_parent_dleg_index).delivery_leg_id))
			THEN
				l_curr_dleg_list.DELETE(g_tl_delivery_leg_rows(l_parent_dleg_index).delivery_leg_id);
			END IF;


			IF ((g_tl_delivery_leg_rows(l_parent_dleg_index).weight=0) AND
			(g_tl_delivery_leg_rows(l_parent_dleg_index).volume=0))
			THEN
				g_tl_delivery_leg_rows(l_parent_dleg_index).parent_with_no_consol_lpn:='Y';
				l_dlegs_with_no_consol(l_parent_dleg_index):=l_parent_dleg_index;
			END IF;

			--Copy parent attributes

			g_tl_chld_delivery_leg_rows(i).pickup_stop_id:=
				g_tl_delivery_leg_rows(l_parent_dleg_index).pickup_stop_id;
			g_tl_chld_delivery_leg_rows(i).pickup_location_id:=
				g_tl_delivery_leg_rows(l_parent_dleg_index).pickup_location_id;
			g_tl_chld_delivery_leg_rows(i).dropoff_stop_id:=
				g_tl_delivery_leg_rows(l_parent_dleg_index).dropoff_stop_id;
			g_tl_chld_delivery_leg_rows(i).dropoff_location_id:=
				g_tl_delivery_leg_rows(l_parent_dleg_index).dropoff_location_id;
			g_tl_chld_delivery_leg_rows(i).distance:=
				g_tl_delivery_leg_rows(l_parent_dleg_index).distance;
			g_tl_chld_delivery_leg_rows(i).direct_distance:=
				g_tl_delivery_leg_rows(l_parent_dleg_index).direct_distance;



		ELSIF ((l_parent_dleg_id IS NOT NULL) AND (l_child_dleg_hash.EXISTS(l_parent_dleg_id)))
		THEN

			l_parent_dleg_index:=l_child_dleg_hash(l_parent_dleg_id);

			g_tl_chld_delivery_leg_rows(l_parent_dleg_index).is_parent_dleg:='Y';


			IF (l_curr_dleg_list.EXISTS(g_tl_chld_delivery_leg_rows(l_parent_dleg_index).delivery_leg_id))
			THEN
				l_curr_dleg_list.DELETE(g_tl_chld_delivery_leg_rows(l_parent_dleg_index).delivery_leg_id);
			END IF;


			IF ((g_tl_chld_delivery_leg_rows(l_parent_dleg_index).weight=0) AND
			(g_tl_chld_delivery_leg_rows(l_parent_dleg_index).volume=0))
			THEN
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).parent_with_no_consol_lpn:='Y';
				l_dlegs_with_no_consol_chld(l_parent_dleg_index):=l_parent_dleg_index;
			END IF;

			--Copy parent attributes

			g_tl_chld_delivery_leg_rows(i).pickup_stop_id:=
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).pickup_stop_id;
			g_tl_chld_delivery_leg_rows(i).pickup_location_id:=
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).pickup_location_id;
			g_tl_chld_delivery_leg_rows(i).dropoff_stop_id:=
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).dropoff_stop_id;
			g_tl_chld_delivery_leg_rows(i).dropoff_location_id:=
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).dropoff_location_id;
			g_tl_chld_delivery_leg_rows(i).distance:=
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).distance;
			g_tl_chld_delivery_leg_rows(i).direct_distance:=
				g_tl_chld_delivery_leg_rows(l_parent_dleg_index).direct_distance;


		END IF;

		i:=i+1;

	END LOOP;


	--l_curr_dleg_list  has all dleg ids that have is_parent='N'
	l_next_dleg_list.DELETE;

	WHILE (l_curr_dleg_list.COUNT > 0)
	LOOP
		i:=l_curr_dleg_list.FIRST;
		WHILE ( i IS NOT NULL)
		LOOP
			l_parent_dleg_rec.delivery_leg_id:=NULL;
			l_child_dleg_rec.delivery_leg_id:=NULL;

			IF (l_child_dleg_hash.EXISTS(l_curr_dleg_list(i)))
			THEN
				l_child_dleg_rec:=g_tl_chld_delivery_leg_rows(l_child_dleg_hash(l_curr_dleg_list(i)));



			ELSIF (l_parent_dleg_hash.EXISTS(l_curr_dleg_list(i)))
			THEN

				l_child_dleg_rec:=g_tl_delivery_leg_rows(l_parent_dleg_hash(l_curr_dleg_list(i)));
			END IF;


			IF (l_child_dleg_rec.delivery_leg_id IS NOT NULL)
			THEN

				IF (l_child_dleg_hash.EXISTS(l_child_dleg_rec.parent_dleg_id))
				THEN
					l_parent_dleg_index:=l_child_dleg_hash(l_child_dleg_rec.parent_dleg_id);
					IF(g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_weight IS NULL)
					THEN

						g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_weight:=0;

					END IF;
					IF(g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_volume IS NULL)
					THEN
						g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_volume:=0;
					END IF;


					g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_weight:=
						l_child_dleg_rec.weight+g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_weight;

					g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_volume:=
						l_child_dleg_rec.volume+g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_volume;


					IF (l_child_dleg_rec.children_weight IS NOT NULL)
					THEN

						g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_weight:=
							l_child_dleg_rec.children_weight+g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_weight;

					END IF;

					IF (l_child_dleg_rec.children_volume IS NOT NULL)
					THEN

						g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_volume:=
							l_child_dleg_rec.children_volume+g_tl_chld_delivery_leg_rows(l_parent_dleg_index).children_volume;

					END IF;

					--Add parent to next dleg list
					l_next_dleg_list(l_child_dleg_rec.parent_dleg_id):=l_child_dleg_rec.parent_dleg_id;

				ELSIF(l_parent_dleg_hash.EXISTS(l_child_dleg_rec.parent_dleg_id))
				THEN

					l_parent_dleg_index:=l_parent_dleg_hash(l_child_dleg_rec.parent_dleg_id);
					IF(g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight IS NULL)
					THEN

						g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight:=0;

					END IF;
					IF(g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume IS NULL)
					THEN
						g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume:=0;
					END IF;


					g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight:=
						l_child_dleg_rec.weight+g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight;

					g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume:=
						l_child_dleg_rec.volume+g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume;


					IF (l_child_dleg_rec.children_weight IS NOT NULL)
					THEN

						g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight:=
							l_child_dleg_rec.children_weight+g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight;

					END IF;

					IF (l_child_dleg_rec.children_volume IS NOT NULL)
					THEN

						g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume:=
							l_child_dleg_rec.children_volume+g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume;

					END IF;

					--Add parent to next dleg list
					l_next_dleg_list(l_child_dleg_rec.parent_dleg_id):=l_child_dleg_rec.parent_dleg_id;

				END IF;




			ELSE

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No child dleg rec');

			END IF;



			i:=l_curr_dleg_list.NEXT(i);
		END LOOP;


		l_curr_dleg_list.DELETE;
		l_curr_dleg_list:=l_next_dleg_list;
		l_next_dleg_list.DELETE;


	END LOOP;


	--Set weight and volume for dlegs with no_consol_lpn
	i:=l_dlegs_with_no_consol.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		g_tl_delivery_leg_rows(i).weight:=g_tl_delivery_leg_rows(i).children_weight;
		g_tl_delivery_leg_rows(i).volume:=g_tl_delivery_leg_rows(i).children_volume;

		i:=l_dlegs_with_no_consol.NEXT(i);
	END LOOP;

	i:=l_dlegs_with_no_consol_chld.FIRST;
	WHILE(i IS NOT NULL)
	LOOP
		g_tl_chld_delivery_leg_rows(i).weight:=g_tl_chld_delivery_leg_rows(i).children_weight;
		g_tl_chld_delivery_leg_rows(i).volume:=g_tl_chld_delivery_leg_rows(i).children_volume;

		i:=l_dlegs_with_no_consol_chld.NEXT(i);

	END LOOP;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Sync_Child_Dleg_Cache');
EXCEPTION


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Sync_Child_Dleg_Cache',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Sync_Child_Dleg_Cache');


END Sync_Child_Dleg_Cache;



--Caches a trip,it's stops,carrier, dlegs,delivery details into the global cache

PROCEDURE Cache_Trip(
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_trip_index IN OUT NOCOPY NUMBER,
	x_carrier_index IN OUT NOCOPY NUMBER,
	x_stop_index IN OUT NOCOPY NUMBER,
	x_dleg_index IN OUT NOCOPY NUMBER,
	x_child_dleg_index IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS



--Get all the dlv details that are picked up from the passed in stop

CURSOR get_picked_up_dlv_details(c_pick_up_stop_id IN NUMBER) RETURN
FTE_FREIGHT_PRICING.shipment_line_rec_type IS

	SELECT	dd.delivery_detail_id,
		dl.delivery_id,
		dl.delivery_leg_id,
		dl.reprice_required,
		da.parent_delivery_detail_id,
		dd.customer_id,
		dd.sold_to_contact_id,
		dd.inventory_item_id,
		dd.item_description,
		dd.hazard_class_id,
		dd.country_of_origin,
		dd.classification,
		dd.requested_quantity,
		dd.requested_quantity_uom,
		dd.master_container_item_id,
		dd.detail_container_item_id,
		dd.customer_item_id,
		dd.net_weight,
		dd.organization_id,
		dd.container_flag,
		dd.container_type_code,
		dd.container_name,
		dd.fill_percent,
		dd.gross_weight,
		dd.currency_code,dd.freight_class_cat_id,
		dd.commodity_code_cat_id,
		dd.weight_uom_code ,
		dd.volume,
		dd.volume_uom_code,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,
		da.type,
		da.parent_delivery_id,
		dl.parent_delivery_leg_id
	FROM 	wsh_delivery_assignments da,
		wsh_delivery_legs dl ,
		wsh_delivery_details dd
	WHERE 	da.delivery_id=dl.delivery_id and
		dl.pick_up_stop_id=c_pick_up_stop_id and
		da.delivery_detail_id = dd.delivery_detail_id and
		(
			( (da.type IS NULL OR da.type='S') and (da.parent_delivery_detail_id is null) and (dl.parent_delivery_leg_id is null))  -- non-MDC trips top level details
			OR
			((da.type='O') and (da.parent_delivery_detail_id is null) and (dl.parent_delivery_leg_id is null))
			--MDC trip top level details of top level parent deliveries .If in these cases the type is made 'S' we would not need an extra clause.
			OR
			( (da.type='C' ) and (dl.parent_delivery_leg_id is not null) and
			exists ( select pdl.pick_up_stop_id from wsh_delivery_legs pdl where pdl.delivery_leg_id=dl.parent_delivery_leg_id and pdl.pick_up_stop_id=c_pick_up_stop_id  and pdl.delivery_id=da.parent_delivery_id))
			--MDC trip ,top level details of deliveries that have parents that are on the same trip
		)
	ORDER BY
		da.delivery_id;





--gets all the details dropped off at a given stop
CURSOR get_dropped_off_dlv_details(c_drop_off_stop_id IN NUMBER) RETURN
FTE_FREIGHT_PRICING.shipment_line_rec_type IS
	SELECT	dd.delivery_detail_id,
		dl.delivery_id,
		dl.delivery_leg_id,
		dl.reprice_required,
		da.parent_delivery_detail_id,
		dd.customer_id,
		dd.sold_to_contact_id,
		dd.inventory_item_id,
		dd.item_description,
		dd.hazard_class_id,
		dd.country_of_origin,
		dd.classification,
		dd.requested_quantity,
		dd.requested_quantity_uom,
		dd.master_container_item_id,
		dd.detail_container_item_id,
		dd.customer_item_id,
		dd.net_weight,
		dd.organization_id,
		dd.container_flag,
		dd.container_type_code,
		dd.container_name,
		dd.fill_percent,
		dd.gross_weight,
		dd.currency_code,dd.freight_class_cat_id,
		dd.commodity_code_cat_id,
		dd.weight_uom_code ,
		dd.volume,
		dd.volume_uom_code,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,
		da.type,
		da.parent_delivery_id,
		dl.parent_delivery_leg_id
	FROM 	wsh_delivery_assignments da,
		wsh_delivery_legs dl ,
		wsh_delivery_details dd
	WHERE 	da.delivery_id=dl.delivery_id and
		dl.drop_off_stop_id=c_drop_off_stop_id and
		da.delivery_detail_id = dd.delivery_detail_id and
		(
			( (da.type IS NULL OR da.type='S') and (da.parent_delivery_detail_id is null) and (dl.parent_delivery_leg_id is null))
			-- non-MDC trips top level details
			OR
			((da.type='O') and (da.parent_delivery_detail_id is null) and (dl.parent_delivery_leg_id is null))
			--MDC trip top level details of top level parent deliveries.If in these cases the type is made 'S' we would not need an extra clause.
			OR
			( (da.type='C' ) and (dl.parent_delivery_leg_id is not null) and
			exists ( select pdl.drop_off_stop_id from wsh_delivery_legs pdl where pdl.delivery_leg_id=dl.parent_delivery_leg_id and pdl.drop_off_stop_id=c_drop_off_stop_id  and pdl.delivery_id=da.parent_delivery_id))
			--MDC trip ,top level details of deliveries that have parents that are on the same trip
		)
	ORDER BY
		da.delivery_id;


--Gets info from wsh_carriers

CURSOR get_carrier_pref(c_carrier_id IN NUMBER) RETURN TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		c.currency_code,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		c.weight_uom,
		null,
		c.volume_uom,
		null,
		c.distance_uom,
		null,
		c.time_uom,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIERS c
	WHERE 	c.carrier_id=c_carrier_id;


----

--Gets info from wsh_carrier_services

CURSOR get_carrier_service_pref(c_carrier_id IN NUMBER,c_service_level IN
VARCHAR2) RETURN TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		null,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIER_SERVICES c
	WHERE 	c.carrier_id=c_carrier_id and
		c.service_level=c_service_level;

--Gets all the stops for a given trip ,ordered by sequence number

CURSOR get_stop_info(c_trip_id IN NUMBER) RETURN TL_trip_stop_input_rec_type IS

	SELECT 	s.stop_id ,
		s.trip_id,
		s.stop_location_id,
		NVL(s.wkday_layover_stops,0),
		NVL(s.wkend_layover_stops,0),
		null,
		null,
		0,
		0,
		0,
		0,
		null,
		0,
		0,
		0,
		0,
		null,
		null,
		s.planned_arrival_date,
		s.planned_departure_date,
		null,
		s.physical_stop_id,
		s.physical_location_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null
	FROM wsh_trip_stops s
	WHERE  s.trip_id=c_trip_id
	ORDER by s.stop_sequence_number;

--Gets all the dlegs that start from the given stop

CURSOR get_dleg_info(c_pick_up_stop_id IN NUMBER) RETURN
TL_delivery_leg_rec_type IS

	SELECT	dl.delivery_leg_id,
		s.trip_id,
		dl.delivery_id,
		dl.pick_up_stop_id,
		null,
		dl.drop_off_stop_id,
		s.stop_location_id,
		0,
		0,
		0,
		0,
		0,
		0,
		dl.parent_delivery_leg_id,
		0,
		0,
		null,
		null
	FROM 	wsh_delivery_legs dl,
		wsh_trip_stops s
	WHERE 	dl.drop_off_stop_id = s.stop_id and
		dl.pick_up_stop_id=c_pick_up_stop_id;




	l_carrier_service_rec  TL_CARRIER_PREF_REC_TYPE ;
	l_carrier_rec	TL_CARRIER_PREF_REC_TYPE ;
	l_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_stop_count NUMBER;
	l_dlv_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;
	l_quantity NUMBER;
	l_current_weight NUMBER;
	l_previous_weight NUMBER;
	l_dleg_tab 	 TL_dleg_quantity_tab_type;
	l_dleg_rec TL_delivery_leg_rec_type;
	l_stop_distance_tab	TL_stop_distance_tab_type;
	l_empty_flag	VARCHAR2(1);
	l_initial_stop_index NUMBER;
	l_initial_dleg_index NUMBER;
	l_initial_child_dleg_index NUMBER;
	l_region_id 	NUMBER;
	l_internal_stop_id NUMBER;
	l_internal_location_id NUMBER;
	l_actual_stop_id NUMBER;
	i NUMBER;
	l_physical_previous_flag VARCHAR2(1);


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Cache_Trip','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_initial_stop_index:=x_stop_index;
	l_initial_dleg_index:=x_dleg_index;
	l_initial_child_dleg_index:=x_child_dleg_index;




	--Get Carrier pref

	IF ((x_trip_rec.carrier_id IS NULL) OR (x_trip_rec.service_type IS
		NULL))
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Trip',
		--	p_exc=>'g_tl_no_carrier_or_service',
		--	p_trip_id=>x_trip_rec.trip_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_carrier_or_service;

	END IF;

	OPEN
	get_carrier_service_pref(
		x_trip_rec.carrier_id,
		x_trip_rec.service_type);

	FETCH get_carrier_service_pref INTO l_carrier_service_rec;
	IF (get_carrier_service_pref%NOTFOUND)
	THEN

		--No carrier_service_pref found, will have to use only carrier
		--pref
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No carrier Service entry found');

	END IF;
	CLOSE get_carrier_service_pref;

	OPEN  get_carrier_pref(x_trip_rec.carrier_id);
	FETCH get_carrier_pref INTO l_carrier_rec;
	IF (get_carrier_pref%NOTFOUND)
	THEN


		CLOSE get_carrier_pref;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Trip',
		--	p_exc=>'g_tl_get_carrier_pref_fail',
		--	p_trip_id=>x_trip_rec.trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_carrier_pref_fail;


	END IF;
	CLOSE get_carrier_pref;



	Combine_Carrier_Info(
		p_carrier_pref_rec	=>	l_carrier_rec,
		x_carrier_service_pref_rec	=>	l_carrier_service_rec,
		x_return_status 	=> l_return_status);



	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	  		raise FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail;
	       END IF;
	END IF;

	TL_Get_Currency(
		p_delivery_id=>NULL,
		p_trip_id=>x_trip_rec.trip_id,
		p_location_id=>NULL,
		p_carrier_id=>l_carrier_service_rec.carrier_id,
		x_currency_code=>l_carrier_service_rec.currency,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
	       END IF;
	END IF;



	--l_carrier_service_rec now has all the carrier info

	Validate_Carrier_Info(
		x_carrier_info 	=>	l_carrier_service_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Trip',
			--	p_exc=>'g_tl_validate_carrier_fail',
			--	p_carrier_id=>l_carrier_service_rec.carrier_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail;
		END IF;
	END IF;


	--These 2 variables are used to determine if there is a segment
	--in the trip which is unloaded, then we know that the
	--distance between those 2 stops is unloaded distance

	l_current_weight:=0;
	l_previous_weight:=NULL;

	l_internal_stop_id:=NULL;
	l_internal_location_id:=NULL;
	--Query all Stop for the trip

	l_stop_count:=0;
	OPEN get_stop_info(x_trip_rec.trip_id);
	FETCH get_stop_info INTO l_stop_rec;
	WHILE(get_stop_info%FOUND)
	LOOP

		--11.5.10+Check if the stop fetched is an internal stop
		IF (l_stop_rec.physical_stop_id IS NOT NULL)
		THEN
			--11.5.10+store internal stop id
			l_internal_stop_id:=l_stop_rec.stop_id;
			l_actual_stop_id:=l_stop_rec.physical_stop_id;

			--11.5.10+the physical stop is before the internal stop
			IF ((l_stop_count > 0 ) AND (g_tl_trip_stop_rows(x_stop_index-1).stop_id = l_actual_stop_id))
			THEN
				l_stop_rec:=g_tl_trip_stop_rows(x_stop_index-1);
				l_physical_previous_flag:='Y';

			--11.5.10+the physical stop is after the internal stop
			ELSE
				--fetch actual stop
				FETCH get_stop_info INTO l_stop_rec;
				IF ((NOT (get_stop_info%FOUND)) OR (l_stop_rec.stop_id <> l_actual_stop_id))
				THEN
					CLOSE get_stop_info;
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Pointer to dummy stop not next in sequence. Stop ID:'
						||l_internal_stop_id||' Physical stop id:'||l_actual_stop_id);
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail;

				END IF;
				l_physical_previous_flag:='N';
			END IF;
		ELSIF (	l_stop_rec.physical_location_id IS NOT NULL)
		THEN
			--11.5.10+no internal stop only an internal location

			l_internal_location_id:=l_stop_rec.location_id;
			l_stop_rec.location_id:=l_stop_rec.physical_location_id;

		END IF;
		--11.5.10+
		IF (l_internal_stop_id IS NULL)
		THEN

			--Get region for stop

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get region for location '||
			l_stop_rec.location_id||' : '||l_carrier_service_rec.region_level|| ' : '||l_stop_rec.stop_region);

			Get_Region_For_Location(
				p_location_id=>	l_stop_rec.location_id,
				p_region_type=>	l_carrier_service_rec.region_level,
				x_region_id=>	l_stop_rec.stop_region,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
				  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
			       END IF;
			END IF;

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get_Region_For_LocationRES: '||
				l_stop_rec.location_id ||':'||l_stop_rec.stop_region);
		END IF;

		--GEts details droppped off at this stop
		IF (l_internal_stop_id IS NOT NULL)
		THEN
			OPEN get_dropped_off_dlv_details(l_internal_stop_id);
		ELSE
			OPEN get_dropped_off_dlv_details(l_stop_rec.stop_id);
		END IF;

		FETCH get_dropped_off_dlv_details INTO l_dlv_detail_rec;
		WHILE(get_dropped_off_dlv_details%FOUND)
		LOOP

			Classify_Detail(
				x_dlv_dtl_rec=>l_dlv_detail_rec,
				x_return_status=>l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_dropped_off_dlv_details;
			       	  CLOSE get_stop_info;

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_classify_dtl_fail;
			       END IF;
			END IF;




			Validate_Dlv_Detail_Info(
				p_carrier_pref_rec=>l_carrier_service_rec,
				x_dlv_detail_info=>l_dlv_detail_rec,
				x_return_status	=>	l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_dropped_off_dlv_details;
			       	  CLOSE get_stop_info;

				  --Show only generic message
				  --FTE_FREIGHT_PRICING_UTIL.setmsg (
				--	p_api=>'Cache_Trip',
				--	p_exc=>'g_tl_validate_dlv_dtl_fail',
				--	p_delivery_detail_id=>l_dlv_detail_rec.delivery_detail_id);


			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail;
			       END IF;
			END IF;

			--Adds dropoff quantities to l_stop_rec


			Add_Dropoff_Quantity(
				p_dlv_detail_rec    =>l_dlv_detail_rec,
				p_carrier_pref  =>l_carrier_service_rec,
				x_stop_rec	    =>l_stop_rec,
				x_return_status	=>	l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			       	  CLOSE get_dropped_off_dlv_details;
			       	  CLOSE get_stop_info;
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_dropoff_qty_fail;
			       END IF;
			END IF;


			--Insert into delivery detail cache
			Insert_Into_Dlv_Dtl_Cache(
				p_dlv_dtl_rec=>l_dlv_detail_rec,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_dropped_off_dlv_details;
			       	  CLOSE get_stop_info;
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail;
			       END IF;
			END IF;

			FETCH get_dropped_off_dlv_details INTO l_dlv_detail_rec;

		END LOOP;
		CLOSE get_dropped_off_dlv_details;



		--Gets details picked up at the stop
		--11.5.10+
		IF (l_internal_stop_id IS NOT NULL)
		THEN
			OPEN get_picked_up_dlv_details(l_internal_stop_id);
		ELSE
			OPEN get_picked_up_dlv_details(l_stop_rec.stop_id);
		END IF;

		FETCH get_picked_up_dlv_details INTO l_dlv_detail_rec;
		WHILE(get_picked_up_dlv_details%FOUND)
		LOOP

			Classify_Detail(
				x_dlv_dtl_rec=>l_dlv_detail_rec,
				x_return_status=>l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_picked_up_dlv_details;
			       	  CLOSE get_stop_info;

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_classify_dtl_fail;
			       END IF;
			END IF;



			Validate_Dlv_Detail_Info(
				p_carrier_pref_rec=>l_carrier_service_rec,
				x_dlv_detail_info	=>l_dlv_detail_rec,
				x_return_status		=>l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_picked_up_dlv_details;
			       	  CLOSE get_stop_info;

				--Show only generic message
				--FTE_FREIGHT_PRICING_UTIL.setmsg (
				--	p_api=>'Cache_Trip',
				--	p_exc=>'g_tl_validate_dlv_dtl_fail',
				--	p_delivery_detail_id=>l_dlv_detail_rec.delivery_detail_id);

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail;
			       END IF;
			END IF;

			--Adds picked up quantities to l_stop_rec
			Add_Pickup_Quantity(
				p_dlv_detail_rec=>	l_dlv_detail_rec,
				p_carrier_pref=>	l_carrier_service_rec,
				x_stop_rec=>	l_stop_rec,
				x_dleg_quantity_tab=>	l_dleg_tab,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_picked_up_dlv_details;
			       	  CLOSE get_stop_info;
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_pickup_qty_fail;
			       END IF;
			END IF;

			--Insert into delivery detail cache
			Insert_Into_Dlv_Dtl_Cache(
				p_dlv_dtl_rec=>l_dlv_detail_rec,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_picked_up_dlv_details;
			       	  CLOSE get_stop_info;

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail;
			       END IF;
			END IF;

			FETCH get_picked_up_dlv_details INTO l_dlv_detail_rec;

		END LOOP;
		CLOSE get_picked_up_dlv_details;

		--Query up delivery legs picked up at this stop
		--11.5.10+
		IF (l_internal_stop_id IS NOT NULL)
		THEN
			OPEN get_dleg_info(l_internal_stop_id);
		ELSE
			OPEN get_dleg_info(l_stop_rec.stop_id);
		END IF;


		FETCH get_dleg_info INTO l_dleg_rec;
		WHILE (get_dleg_info%FOUND)
		LOOP

			--11.5.10+if we used an internal_stop_id then
			--mask the dleg as having being picked up from the
			--actual stop id

			IF (l_internal_stop_id IS NOT NULL)
			THEN
				l_dleg_rec.pickup_stop_id:=l_stop_rec.stop_id;

			END IF;

			--At this point all the quantities of all the details
			--picked up at this stop, have been summed up
			--copy the summed up quantities to the dleg rec

			l_dleg_rec.pickup_location_id:=l_stop_rec.location_id;
			IF (l_dleg_tab.EXISTS(l_dleg_rec.delivery_leg_id))
			THEN
			 l_dleg_rec.weight:=
			  l_dleg_tab(l_dleg_rec.delivery_leg_id).weight;
			 l_dleg_rec.volume:=
			  l_dleg_tab(l_dleg_rec.delivery_leg_id).volume;
			 l_dleg_rec.pallets:=
			  l_dleg_tab(l_dleg_rec.delivery_leg_id).pallets;
			 l_dleg_rec.containers:=
			  l_dleg_tab(l_dleg_rec.delivery_leg_id).containers;
			END IF;

			--Insert into dleg cache
			Validate_Dleg_Info(
				x_dleg_info=>	l_dleg_rec,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_dleg_info;
			       	  CLOSE get_stop_info;

				 --Show only generic message
				 -- FTE_FREIGHT_PRICING_UTIL.setmsg (
				--	p_api=>'Cache_Trip',
				--	p_exc=>'g_tl_validate_dleg_fail',
				--	p_delivery_leg_id=>l_dleg_rec.delivery_leg_id);

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail;
			       END IF;
			END IF;

			IF(l_dleg_rec.parent_dleg_id IS NOT NULL)
			THEN
			--MDC insert into child dleg cache

				g_tl_chld_delivery_leg_rows(x_child_dleg_index):=l_dleg_rec;
				x_child_dleg_index:=x_child_dleg_index+1;

			ELSE

				g_tl_delivery_leg_rows(x_dleg_index):=l_dleg_rec;
				x_dleg_index:=x_dleg_index+1;
			END IF;

			FETCH get_dleg_info INTO l_dleg_rec;

		END LOOP;
		CLOSE  get_dleg_info;

		IF ((l_internal_stop_id IS NOT NULL) AND (l_physical_previous_flag= 'N'))
		THEN
			--11.5.10+Clean up dlegs which were previously fetched having
			--dropoff at the internal stop

			Replace_Dleg_Dropoff(
				p_dleg_index_start =>l_initial_dleg_index,
				p_internal_stop_id => l_internal_stop_id,
				p_internal_location_id => NULL,
				p_actual_stop_id => l_stop_rec.stop_id,
				p_actual_location_id => l_stop_rec.location_id,
				x_return_status	=>	l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  CLOSE get_stop_info;
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_replace_dleg_fail;
				       END IF;
				END IF;


			--We dont use the flag anymore now
			l_internal_stop_id:=NULL;

		ELSIF((l_internal_stop_id IS NOT NULL) AND (l_physical_previous_flag= 'Y'))
		THEN

			--11.5.10+

			Replace_Dleg_Dropoff(
				p_dleg_index_start =>l_initial_dleg_index,
				p_internal_stop_id => l_internal_stop_id,
				p_internal_location_id => NULL,
				p_actual_stop_id => l_stop_rec.stop_id,
				p_actual_location_id => l_stop_rec.location_id,
				x_return_status	=>	l_return_status);


				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  CLOSE get_stop_info;
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_replace_dleg_fail;
				       END IF;
				END IF;


			--11.5.10+We dont use the flag anymore now
			l_internal_stop_id:=NULL;

			--11.5.10+Update current weight of the trip

			l_current_weight:=l_current_weight+l_stop_rec.pickup_weight-
				l_stop_rec.dropoff_weight
				-(g_tl_trip_stop_rows(x_stop_index-1).pickup_weight-g_tl_trip_stop_rows(x_stop_index-1).dropoff_weight);

			l_previous_weight:=l_current_weight;

			--11.5.10+Update the trip with internal stop pickup dropoff quantities

			x_trip_rec.number_of_pallets:=x_trip_rec.number_of_pallets +
				l_stop_rec.pickup_pallets-g_tl_trip_stop_rows(x_stop_index-1).pickup_pallets;
			x_trip_rec.number_of_containers:=x_trip_rec.number_of_containers +
				l_stop_rec.pickup_containers-g_tl_trip_stop_rows(x_stop_index-1).pickup_containers;
			x_trip_rec.total_weight:=x_trip_rec.total_weight +
				l_stop_rec.pickup_weight-g_tl_trip_stop_rows(x_stop_index-1).pickup_weight;
			x_trip_rec.total_volume:=x_trip_rec.total_volume +
				l_stop_rec.pickup_volume-g_tl_trip_stop_rows(x_stop_index-1).pickup_volume;

			g_tl_trip_stop_rows(x_stop_index-1):=l_stop_rec;

			FETCH get_stop_info INTO l_stop_rec;

		ELSE
			IF (l_internal_location_id IS NOT NULL)
			THEN
				--11.5.10+
				Replace_Dleg_Dropoff(
					p_dleg_index_start =>l_initial_dleg_index,
					p_internal_stop_id => NULL,
					p_internal_location_id => l_internal_location_id,
					p_actual_stop_id => NULL,
					p_actual_location_id => l_stop_rec.location_id,
					x_return_status	=>	l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  CLOSE get_stop_info;
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_replace_dleg_fail;
				       END IF;
				END IF;



				l_internal_location_id:=NULL;
			END IF;

			--Update current weight of the trip

			l_current_weight:=l_current_weight+l_stop_rec.pickup_weight-
				l_stop_rec.dropoff_weight;

			--Prepare inputs for distance query
			IF (l_stop_count>0)
			THEN

				--if from previous stop to this stop
				--there was no weight , then we need
				--to count this as unloaded distance

				IF (l_previous_weight <=0)
				THEN
					l_empty_flag:='Y';
				ELSE
					l_empty_flag:='N';

				END IF;

				-- Create inputs for query to mileage tables


				Add_Inputs_For_Distance(
				 p_from_stop_rec=> g_tl_trip_stop_rows(x_stop_index-1),
				 p_to_stop_rec=> 	l_stop_rec,
				 p_empty_flag=>	l_empty_flag,
				 x_stop_distance_tab=>	l_stop_distance_tab,
				 x_return_status	=>	l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN

					  CLOSE get_stop_info;

					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail;
				       END IF;
				END IF;

			END IF;


			--Update trip rec

			Update_Trip_With_Stop_Info(
				p_stop_rec	=>	l_stop_rec,
				x_trip_rec	=>	x_trip_rec,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  CLOSE get_stop_info;
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail;
			       END IF;
			END IF;
			--Insert Stop info into Cache

			--Perform validation after getting dist,time,fac info

			g_tl_trip_stop_rows(x_stop_index):=l_stop_rec;
			x_stop_index:=x_stop_index+1;
			l_stop_count:=l_stop_count+1;
			l_previous_weight:=l_current_weight;

			FETCH get_stop_info INTO l_stop_rec;
		END IF;-- for l_internal_stop_id IS NOT NULL

	END LOOP;
	CLOSE get_stop_info;

	--Set time,distance of last stop to 0

	g_tl_trip_stop_rows(x_stop_index-1).distance_to_next_stop:=0;
	g_tl_trip_stop_rows(x_stop_index-1).time_to_next_stop:=0;





	--GEt distances/time from mileage table, update, stop, dleg buffer, trip
	--loaded, unlaoded distances

	Get_Distances(
		p_stop_index	=>	l_initial_stop_index,
		p_dleg_index	=>	l_initial_dleg_index,
		p_carrier_rec	=>	l_carrier_service_rec,
		x_stop_distance_tab	=>l_stop_distance_tab,
		x_trip_rec	=>	x_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
--			FTE_FREIGHT_PRICING_UTIL.setmsg (
--				p_api=>'Cache_Trip',
--				p_exc=>'g_tl_get_distances_fail',
--				p_trip_id=>x_trip_rec.trip_id);


          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail;
       		END IF;
	END IF;


	--Get facility Info and store into stop cache
	Get_Facility_Info(p_stop_index	=>	l_initial_stop_index,
			x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get facility information');
	          --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail;
	       END IF;
	END IF;

	--Validate All Stops(all the stop,distance,time,fac info has beengathered

	FOR i IN l_initial_stop_index..(x_stop_index-1)
	LOOP
		--Determine if the stop is pickup/dropoff/both or none
		Get_Stop_Type(x_stop_rec=>g_tl_trip_stop_rows(i));

		Validate_Stop_Info(
		p_carrier_pref_rec=>l_carrier_service_rec,
		x_stop_info=>	g_tl_trip_stop_rows(i),
		x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Trip',
			--	p_exc=>'g_tl_validate_stop_fail',
			--	p_stop_id=>g_tl_trip_stop_rows(i).stop_id);

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail;
		       END IF;
		END IF;

	END LOOP;





	--Update trip rec
	x_trip_rec.number_of_stops:=l_stop_count;


	x_trip_rec.distance_method:=l_carrier_service_rec.distance_calculation_method;

	--get the arrival and dep dates of the trip
	--from first and last stop

	x_trip_rec.planned_departure_date:=
	g_tl_trip_stop_rows(l_initial_stop_index).planned_departure_date;
	x_trip_rec.planned_arrival_date:=
	g_tl_trip_stop_rows(x_stop_index-1).planned_arrival_date;


--
	x_trip_rec.price_list_id:=NULL;
	Get_Pricelist_Id(
		p_lane_id	=>x_trip_rec.lane_id,
		p_departure_date => x_trip_rec.planned_departure_date,
		p_arrival_date => x_trip_rec.planned_arrival_date,
		x_pricelist_id	=> x_trip_rec.price_list_id,
		x_return_status	=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Trip',
			--	p_exc=>'g_tl_get_pricelistid_fail',
			--	p_trip_id=>x_trip_rec.trip_id,
			--	p_lane_id=>x_trip_rec.lane_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_pricelistid_fail;
	       END IF;
	END IF;
	IF (x_trip_rec.price_list_id IS NULL)
	THEN
		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Trip',
		--	p_exc=>'g_tl_get_pricelistid_fail',
		--	p_trip_id=>x_trip_rec.trip_id,
		--	p_lane_id=>x_trip_rec.lane_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_pricelistid_fail;
	END IF;


	--Dead head trip has no dlegs 3958974

	IF (l_initial_dleg_index = x_dleg_index)
	THEN
		x_trip_rec.dead_head:='Y';
	ELSE
		x_trip_rec.dead_head:='N';
	END IF;

	x_trip_rec.stop_reference:=l_initial_stop_index;
	x_trip_rec.delivery_leg_reference:=l_initial_dleg_index;



	IF(l_initial_child_dleg_index = x_child_dleg_index)
	THEN
		--Non MDC trip

		x_trip_rec.child_dleg_reference:=NULL;

	ELSE

		--MDC trip
		x_trip_rec.child_dleg_reference:=l_initial_child_dleg_index;

		Sync_Child_Dleg_Cache(
			p_initial_dleg_index=>l_initial_dleg_index,
			p_intial_child_dleg_index=>l_initial_child_dleg_index,
			p_current_dleg_index=>x_dleg_index,
			p_chld_dleg_index=>x_child_dleg_index,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_sync_dleg_fail;
		       END IF;
		END IF;

		Cache_Int_Containers (
			p_trip_id=>x_trip_rec.trip_id,
			p_carrier_pref_rec=>l_carrier_service_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cache_int_cont_fail;
		       END IF;
		END IF;

	END IF;


	--Insert into trip cache

	Validate_Trip_Info(
		x_trip_info=>	x_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Trip',
		--	p_exc=>'g_tl_validate_trip_fail',
		--	p_trip_id=>x_trip_rec.trip_id);

	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail;
	       END IF;
	END IF;



	g_tl_trip_rows(x_trip_index):=x_trip_rec;
	x_trip_index:=x_trip_index+1;

	--Insert carrier info into cache
	g_tl_carrier_pref_rows(x_carrier_index):=l_carrier_service_rec;
	x_carrier_index:=x_carrier_index+1;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_sync_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_sync_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_int_cont_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_int_cont_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_replace_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_replace_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_pu_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_pricelistid_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_pricelistid_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_carrier_or_service THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_carrier_or_service');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_carrier_pref_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_carrier_pref_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_combine_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_dropoff_qty_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_dropoff_qty_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_pickup_qty_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_pickup_qty_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_insert_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_ip_dist_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_updt_trip_with_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_distances_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_facility_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_reg_for_loc_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Trip');

END Cache_Trip;


PROCEDURE Initialize_Single_Dummy_Detail(
	p_weight IN NUMBER,
	p_weight_uom IN VARCHAR2,
	p_volume IN NUMBER,
	p_volume_uom IN VARCHAR2,
	x_dlv_detail_info IN OUT NOCOPY FTE_FREIGHT_PRICING.shipment_line_rec_type,
	x_return_status OUT	NOCOPY	VARCHAR2) IS
BEGIN


	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize_Single_Dummy_Detail','start');


	x_dlv_detail_info.delivery_detail_id:=FAKE_DLEG_ID;
	x_dlv_detail_info.delivery_id:=FAKE_DLEG_ID;
	x_dlv_detail_info.delivery_leg_id:=FAKE_DLEG_ID;

	x_dlv_detail_info.gross_weight:=p_weight;
	x_dlv_detail_info.weight_uom_code:=p_weight_uom;

	x_dlv_detail_info.volume:=p_volume;
	x_dlv_detail_info.volume_uom_code:=p_volume_uom;




	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FTE_FREIGHT_PRICING_UTIL.unset_method(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize_Single_Dummy_Detail');




END Initialize_Single_Dummy_Detail;


--Used for delivery search services

PROCEDURE Initialize_Dummy_Dleg(
	p_pickup_location IN NUMBER,
	p_dropoff_location IN NUMBER,
	p_dlv_id IN NUMBER,
	x_dleg_rec IN OUT NOCOPY TL_delivery_leg_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Initialize_Dummy_Dleg','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_dleg_rec.delivery_leg_id:=FAKE_DLEG_ID;
	x_dleg_rec.trip_id:=FAKE_TRIP_ID;
	x_dleg_rec.delivery_id:=p_dlv_id;
	x_dleg_rec.pickup_stop_id:=FAKE_STOP_ID_1;
	x_dleg_rec.pickup_location_id:=p_pickup_location;
	x_dleg_rec.dropoff_stop_id:=FAKE_STOP_ID_2;
	x_dleg_rec.dropoff_location_id:=p_dropoff_location;
	x_dleg_rec.weight:=0;
	x_dleg_rec.volume:=0;
	x_dleg_rec.pallets:=0;
	x_dleg_rec.containers:=0;

	--Get distance, time
	x_dleg_rec.distance:=0;
	x_dleg_rec.direct_distance:=0;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Dummy_Dleg');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Initialize_Dummy_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Dummy_Dleg');


END  Initialize_Dummy_Dleg;

--Used for delivery search services
PROCEDURE Initialize_Dummy_Trip(
	p_departure_date IN DATE,
	p_arrival_date IN DATE,
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Initialize_Dummy_Trip','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_trip_rec.trip_id:=FAKE_TRIP_ID;
	x_trip_rec.planned_departure_date:=p_departure_date;
	x_trip_rec.planned_arrival_date:=p_arrival_date;
	x_trip_rec.number_of_stops:=2;
	--x_trip_rec.distance_method:=?
	x_trip_rec.continuous_move:='N';
	x_trip_rec.dead_head:='N';


	x_trip_rec.loaded_distance:=0;
	x_trip_rec.unloaded_distance:=0;
	x_trip_rec.number_of_pallets:=0;
	x_trip_rec.number_of_containers:=0;
	x_trip_rec.time:=0;

	x_trip_rec.total_trip_distance:=0;
	x_trip_rec.total_direct_distance:=0;

	x_trip_rec.total_weight:=0;
	x_trip_rec.total_volume:=0;





        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Dummy_Trip');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Initialize_Dummy_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Dummy_Trip');


END  Initialize_Dummy_Trip;


--Used for delivery search services
PROCEDURE Initialize_Dummy_Stop(
	p_date IN DATE,
	p_location IN NUMBER,
	x_stop_rec IN OUT NOCOPY  TL_TRIP_STOP_INPUT_REC_TYPE,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Initialize_Dummy_Stop','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_stop_rec.stop_id:=FAKE_STOP_ID_1;
	x_stop_rec.trip_id:=FAKE_TRIP_ID;
	x_stop_rec.location_id:=p_location;
	x_stop_rec.weekday_layovers:=0;
	x_stop_rec.weekend_layovers:=0;
	x_stop_rec.planned_arrival_date:=p_date;
	x_stop_rec.planned_departure_date:=p_date;

	x_stop_rec.distance_to_next_stop:=0;
	x_stop_rec.time_to_next_stop:=0;
	x_stop_rec.pickup_weight:=0;
	x_stop_rec.pickup_volume:=0;
	x_stop_rec.pickup_pallets:=0;
	x_stop_rec.pickup_containers:=0;

	x_stop_rec.dropoff_weight:=0;
	x_stop_rec.dropoff_volume:=0;
	x_stop_rec.dropoff_pallets:=0;
	x_stop_rec.dropoff_containers:=0;

	x_stop_rec.fac_pickup_weight:=0;
	x_stop_rec.fac_pickup_volume:=0;
	x_stop_rec.fac_dropoff_weight:=0;
	x_stop_rec.fac_dropoff_volume:=0;

	x_stop_rec.fac_handling_time:=0;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Dummy_Stop');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Initialize_Dummy_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Dummy_Stop');


END  Initialize_Dummy_Stop;


--Adds all the delivery details of a delivery into the cache
--Used in delivery search services

PROCEDURE Add_Delivery_Details(
	p_delivery_id IN NUMBER,
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_pickup_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dropoff_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dleg_rec IN OUT NOCOPY TL_delivery_leg_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2)
IS

--Gets all the details for a delivery


	CURSOR get_dlv_details(c_delivery_id IN NUMBER) RETURN
	FTE_FREIGHT_PRICING.shipment_line_rec_type IS

	SELECT	dd.delivery_detail_id,
		da.delivery_id,
		FAKE_DLEG_ID,
		'Y',
		da.parent_delivery_detail_id,
		dd.customer_id,
		dd.sold_to_contact_id,
		dd.inventory_item_id,
		dd.item_description,
		dd.hazard_class_id,
		dd.country_of_origin,
		dd.classification,
		dd.requested_quantity,
		dd.requested_quantity_uom,
		dd.master_container_item_id,
		dd.detail_container_item_id,
		dd.customer_item_id,
		dd.net_weight,
		dd.organization_id,
		dd.container_flag,
		dd.container_type_code,
		dd.container_name,
		dd.fill_percent,
		dd.gross_weight,
		dd.currency_code,
		dd.freight_class_cat_id,
		dd.commodity_code_cat_id,
		dd.weight_uom_code ,
		dd.volume,
		dd.volume_uom_code,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,
		null,--MDC columns
		null,--MDC columns
		null--MDC columns
	FROM 	wsh_delivery_assignments da,
		wsh_delivery_details dd
	WHERE 	da.delivery_id=c_delivery_id and
		da.parent_delivery_detail_id is null and
		da.delivery_detail_id = dd.delivery_detail_id;


	l_dlv_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;


l_dleg_tab TL_dleg_quantity_tab_type;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Add_Delivery_Details','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	OPEN get_dlv_details(p_delivery_id);
	FETCH get_dlv_details INTO l_dlv_detail_rec;
	WHILE (get_dlv_details%FOUND)
	LOOP

		Validate_Dlv_Detail_Info(
			p_carrier_pref_rec =>p_carrier_pref_rec,
			x_dlv_detail_info	=>l_dlv_detail_rec,
			x_return_status		=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		       	  CLOSE get_dlv_details;


		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail;
		       END IF;
		END IF;

		--Insert into delivery detail cache

		Add_Dropoff_Quantity(
			p_dlv_detail_rec    =>l_dlv_detail_rec,
			p_carrier_pref  =>p_carrier_pref_rec,
			x_stop_rec	    =>x_dropoff_stop_rec,
			x_return_status	=>	l_return_status);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  CLOSE get_dlv_details;
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_dropoff_qty_fail;
		       END IF;
		END IF;


		--Adds picked up quantities to l_stop_rec
		Add_Pickup_Quantity(
			p_dlv_detail_rec=>	l_dlv_detail_rec,
			p_carrier_pref=>	p_carrier_pref_rec,
			x_stop_rec=>	x_pickup_stop_rec,
			x_dleg_quantity_tab=>	l_dleg_tab,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  CLOSE get_dlv_details;
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_pickup_qty_fail;

		       END IF;
		END IF;



		--Insert into dlv details cache
		Insert_Into_Dlv_Dtl_Cache(
			p_dlv_dtl_rec=>l_dlv_detail_rec,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		       	  CLOSE get_dlv_details;
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail;
		       END IF;
		END IF;


		FETCH get_dlv_details INTO l_dlv_detail_rec;
	END LOOP;

	IF (l_dleg_tab.EXISTS(x_dleg_rec.delivery_leg_id))
	THEN
	 x_dleg_rec.weight:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).weight;
	 x_dleg_rec.volume:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).volume;
	 x_dleg_rec.pallets:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).pallets;
	 x_dleg_rec.containers:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).containers;
	END IF;




	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'ADDDELIVERY DETAILS w:'||x_dleg_rec.weight ||' v:'|| x_dleg_rec.volume||' conta:'|| x_dleg_rec.containers||
	'pall:'||x_dleg_rec.pallets);


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Delivery_Details');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Delivery_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Delivery_Details');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Delivery_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_insert_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Delivery_Details');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Delivery_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Delivery_Details');


END Add_Delivery_Details;

--Given a schedule ID it constructs the carrier record
--Used for trip/delivery search services

PROCEDURE Get_Carrier_Pref_For_Schedule(
	p_schedule_id IN NUMBER,
	x_carrier_service_rec IN OUT NOCOPY TL_CARRIER_PREF_REC_TYPE,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS



--GEts carr info from schedule id

	CURSOR get_carr_from_sched(c_schedule_id IN NUMBER) RETURN
	TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		c.currency_code,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		c.weight_uom,
		null,
		c.volume_uom,
		null,
		c.distance_uom,
		null,
		c.time_uom,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIERS c ,
		FTE_LANES l,
		FTE_SCHEDULES s
	WHERE 	c.carrier_id=l.carrier_id and
		s.schedules_id=c_schedule_id and
		s.lane_id=l.lane_id;

--GEts carr service info from schedule id

	CURSOR get_carr_service_from_sched(c_schedule_id IN NUMBER) RETURN
	TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		null,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIER_SERVICES c ,
		FTE_LANES l,
		FTE_SCHEDULES s
	WHERE 	c.carrier_id=l.carrier_id and
		c.service_level=l.service_type_code and
		s.schedules_id=c_schedule_id and
		s.lane_id=l.lane_id;

	l_carrier_rec TL_CARRIER_PREF_REC_TYPE;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Carrier_Pref_For_Schedule','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	OPEN get_carr_from_sched(p_schedule_id);
	FETCH get_carr_from_sched INTO l_carrier_rec;
	IF (get_carr_from_sched%NOTFOUND)
	THEN

		CLOSE get_carr_from_sched;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Get_Carrier_Pref_For_Schedule',
		--	p_exc=>'g_tl_get_car_from_sched_fail',
		--	p_schedule_id=>p_schedule_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_from_sched_fail;

		END IF;
	CLOSE get_carr_from_sched;



	OPEN get_carr_service_from_sched(p_schedule_id);
	FETCH get_carr_service_from_sched INTO x_carrier_service_rec;
	IF (get_carr_service_from_sched%NOTFOUND)
	THEN


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Carrier Service not found');
	END IF;
	CLOSE get_carr_service_from_sched;

	Combine_Carrier_Info(
		p_carrier_pref_rec	=>	l_carrier_rec,
		x_carrier_service_pref_rec	=>	x_carrier_service_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Schedule');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_from_sched_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Carrier_Pref_For_Schedule',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_from_sched_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Schedule');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Carrier_Pref_For_Schedule',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_combine_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Schedule');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Carrier_Pref_For_Schedule',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Schedule');


END Get_Carrier_Pref_For_Schedule;

--Given a Lane ID cosntructs a carrier record
--Used for trip/delivery search services

PROCEDURE Get_Carrier_Pref_For_Lane(
	p_lane_id IN NUMBER,
	x_carrier_service_rec IN OUT NOCOPY TL_CARRIER_PREF_REC_TYPE,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS


--GEts carr info from lane

	CURSOR get_carr_from_lane(c_lane_id IN NUMBER) RETURN
	TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		c.currency_code,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		c.weight_uom,
		null,
		c.volume_uom,
		null,
		c.distance_uom,
		null,
		c.time_uom,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIERS c ,
		FTE_LANES l
	WHERE 	c.carrier_id=l.carrier_id and
		l.lane_id=c_lane_id;


--gets carr service info from lane

	CURSOR get_carr_service_from_lane(c_lane_id IN NUMBER) RETURN
	TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		null,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIER_SERVICES c ,
		FTE_LANES l
	WHERE 	c.carrier_id=l.carrier_id and
		c.service_level=l.service_type_code and
		l.lane_id=c_lane_id;


	l_carrier_rec TL_CARRIER_PREF_REC_TYPE;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Carrier_Pref_For_Lane','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN get_carr_from_lane(p_lane_id);
	FETCH get_carr_from_lane INTO l_carrier_rec;
	IF (get_carr_from_lane%NOTFOUND)
	THEN

		CLOSE get_carr_from_lane;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Get_Carrier_Pref_For_Lane',
		--	p_exc=>'g_tl_get_carr_from_lane_fail',
		--	p_lane_id=>p_lane_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_carr_from_lane_fail;

	END IF;
	CLOSE get_carr_from_lane;

	OPEN get_carr_service_from_lane(p_lane_id);
	FETCH get_carr_service_from_lane INTO x_carrier_service_rec;
	IF (get_carr_service_from_lane%NOTFOUND)
	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No carr service found');
	END IF;
	CLOSE get_carr_service_from_lane;

	Combine_Carrier_Info(
		p_carrier_pref_rec	=>	l_carrier_rec,
		x_carrier_service_pref_rec	=>	x_carrier_service_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Lane');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_carr_from_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Carrier_Pref_For_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_carr_from_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Carrier_Pref_For_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_combine_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Lane');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Carrier_Pref_For_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Carrier_Pref_For_Lane');


END Get_Carrier_Pref_For_Lane;

--Used in trip search services
--
PROCEDURE Get_Trip_Info_From_Lane(
	p_lane_id IN NUMBER,
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_return_status OUT NOCOPY VARCHAR2) IS


--Gets the lane info required for the trip cache

	CURSOR get_lane_info(c_lane_id IN NUMBER) IS
	SELECT	l.lane_id,
		l.carrier_id,
		l.mode_of_transportation_code,
		l.service_type_code,
		flrc.list_header_id
	FROM fte_lanes l,
	     fte_lane_rate_charts flrc
	WHERE l.lane_id=c_lane_id
	      AND (l.lane_id = flrc.lane_id )
	      AND    (flrc.start_date_active is null
	      	OR flrc.start_date_active <= x_trip_rec.planned_departure_date )
	      AND    (flrc.end_date_active is null
	      	OR flrc.end_date_active > x_trip_rec.planned_departure_date );


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Trip_Info_From_Lane','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN get_lane_info(p_lane_id);
	FETCH get_lane_info INTO
		x_trip_rec.lane_id,x_trip_rec.carrier_id,
		x_trip_rec.mode_of_transport,x_trip_rec.service_type,
		x_trip_rec.price_list_id;

	IF (get_lane_info%NOTFOUND)
	THEN

		CLOSE get_lane_info;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Get_Trip_Info_From_Lane',
		--	p_exc=>'g_tl_get_lane_info_fail',
		--	p_lane_id=>p_lane_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_lane_info_fail;

	END IF;
	CLOSE get_lane_info;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Info_From_Lane');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_lane_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Info_From_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_lane_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Info_From_Lane');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Info_From_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Info_From_Lane');


END Get_Trip_Info_From_Lane;

--Used in trip search services

PROCEDURE Get_Trip_Info_From_Schedule(
	p_schedule_id IN NUMBER,
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_return_status OUT NOCOPY VARCHAR2
	) IS

--Gets the lane/sched info required for the trip cache

	CURSOR get_schedule_info(c_schedule_id IN NUMBER) IS
	SELECT	l.lane_id,
		l.carrier_id,
		l.mode_of_transportation_code,
		l.service_type_code,
		s.schedules_id,
		flrc.list_header_id
	FROM 	fte_lanes l,
		fte_schedules s,
		fte_lane_rate_charts flrc
	WHERE 	l.lane_id=s.lane_id
	      AND (l.lane_id = flrc.lane_id )
	      AND    (flrc.start_date_active is null
		OR flrc.start_date_active <= x_trip_rec.planned_departure_date )
	      AND    (flrc.end_date_active is null
		OR flrc.end_date_active > x_trip_rec.planned_departure_date )
	      AND s.schedules_id=c_schedule_id;



l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Trip_Info_From_Schedule','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN get_schedule_info(p_schedule_id);
	FETCH get_schedule_info INTO
		x_trip_rec.lane_id,x_trip_rec.carrier_id,
		x_trip_rec.mode_of_transport,x_trip_rec.service_type,
		x_trip_rec.schedule_id,x_trip_rec.price_list_id;

	IF (get_schedule_info%NOTFOUND)
	THEN
		CLOSE get_schedule_info;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Get_Trip_Info_From_Schedule',
		--	p_exc=>'g_tl_get_schedule_info_fail',
		--	p_schedule_id=>p_schedule_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_schedule_info_fail;

	END IF;
	CLOSE get_schedule_info;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Info_From_Schedule');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_schedule_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Info_From_Schedule',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_schedule_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Info_From_Schedule');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Info_From_Schedule',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Info_From_Schedule');


END Get_Trip_Info_From_Schedule;

--The weight/volumes are converted into the UOMs of the carrier and the dummy records
--are updated
--Used in delivery search services

PROCEDURE Update_Dummy_Records(
	p_weight_uom IN VARCHAR2,
	p_volume_uom IN VARCHAR2,
	p_weight IN NUMBER,
	p_volume IN NUMBER,
	p_containers IN NUMBER,
	p_pallets IN NUMBER,
	x_carrier_rec IN OUT NOCOPY TL_CARRIER_PREF_REC_TYPE ,
	x_trip_rec IN OUT NOCOPY  TL_trip_data_input_rec_type,
	x_pickup_stop IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dropoff_stop IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dleg IN OUT NOCOPY   TL_delivery_leg_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_quantity NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Update_Dummy_Records','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_quantity:=
	FTE_FREIGHT_PRICING_UTIL.convert_uom(
		p_weight_uom,
		x_carrier_rec.weight_uom,
		p_weight,
		0);

	IF (l_quantity IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;
	END IF;

	x_trip_rec.total_weight:=l_quantity;

	l_quantity:=
	FTE_FREIGHT_PRICING_UTIL.convert_uom(
		p_volume_uom,
		x_carrier_rec.volume_uom,
		p_volume,
		0);


	IF (l_quantity IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail;
	END IF;

	x_trip_rec.total_volume:=l_quantity;

	x_trip_rec.number_of_containers:=p_containers;
	x_trip_rec.number_of_pallets:=p_pallets;


	x_pickup_stop.pickup_weight:=x_trip_rec.total_weight;
	x_pickup_stop.pickup_volume:=x_trip_rec.total_volume;
	x_pickup_stop.pickup_containers:=x_trip_rec.number_of_containers;
	x_pickup_stop.pickup_pallets:=x_trip_rec.number_of_pallets;


	x_pickup_stop.dropoff_weight:=0;
	x_pickup_stop.dropoff_volume:=0;
	x_pickup_stop.dropoff_containers:=0;
	x_pickup_stop.dropoff_pallets:=0;


	x_dropoff_stop.dropoff_weight:=x_trip_rec.total_weight;
	x_dropoff_stop.dropoff_volume:=x_trip_rec.total_volume;
	x_dropoff_stop.dropoff_containers:=x_trip_rec.number_of_containers;
	x_dropoff_stop.dropoff_pallets:=x_trip_rec.number_of_pallets;


	x_dropoff_stop.pickup_weight:=0;
	x_dropoff_stop.pickup_volume:=0;
	x_dropoff_stop.pickup_containers:=0;
	x_dropoff_stop.pickup_pallets:=0;

	x_dleg.weight:=x_trip_rec.total_weight;
	x_dleg.volume:=x_trip_rec.total_volume;
	x_dleg.containers:=x_trip_rec.number_of_containers;
	x_dleg.pallets:=x_trip_rec.number_of_pallets;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Dummy_Records');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Dummy_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Dummy_Records');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Dummy_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Dummy_Records');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Update_Dummy_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Update_Dummy_Records');

END  Update_Dummy_Records;


--For delivery search services
--
PROCEDURE TL_Build_Cache_For_Delivery(
	p_wsh_new_delivery_id  IN Number,
	p_dleg_id IN NUMBER,
	p_pickup_location IN NUMBER,
	p_dropoff_location IN NUMBER,
	p_departure_date IN DATE,
	p_arrival_date IN DATE,
	p_lane_rows IN DBMS_UTILITY.number_array ,
	p_schedule_rows IN DBMS_UTILITY.number_array,
	x_return_status OUT NOCOPY Varchar2) IS


	CURSOR get_dleg_from_dlv(c_delivery_id IN  NUMBER) RETURN
	TL_delivery_leg_rec_type IS
	SELECT	FAKE_DLEG_ID,
		FAKE_TRIP_ID,
		d.delivery_id,
		FAKE_STOP_ID_1,
		d.initial_pickup_location_id,
		FAKE_STOP_ID_2,
		d.ultimate_dropoff_location_id,
		0,
		0,
		0,
		0,
		0,
		0,
		null,--MDC
		0,
		0,
		null,
		null
	FROM 	wsh_new_deliveries d
	WHERE 	d.delivery_id =c_delivery_id;


	CURSOR get_dates_loc_from_dlv(c_delivery_id IN NUMBER) IS
	SELECT	d.initial_pickup_date,
		d.ultimate_dropoff_date,
		d.initial_pickup_location_id,
		d.ultimate_dropoff_location_id
	FROM wsh_new_deliveries d
	WHERE d.delivery_id=c_delivery_id;

	CURSOR get_dleg_info(c_dleg_id IN NUMBER) RETURN
	TL_delivery_leg_rec_type IS

	SELECT	dl.delivery_leg_id,
		null,
		dl.delivery_id,
		dl.pick_up_stop_id,
		null,
		dl.drop_off_stop_id,
		null,
		0,
		0,
		0,
		0,
		0,
		0,
		dl.parent_delivery_leg_id,
		0,
		0,
		null,
		null
	FROM 	wsh_delivery_legs dl
	WHERE 	dl.delivery_leg_id=c_dleg_id;



	CURSOR get_trip_info_from_stop(c_stop_id IN NUMBER ) RETURN
	TL_trip_data_input_rec_type IS

	SELECT	t.trip_id,
		t.lane_id,
		null,
		t.service_level,
		t.carrier_id,
		t.mode_of_transport,
		null,  --t.vehicle_item_id,
		null,
		0,
		0,
		0,
		0,
		0,
		0,
		null, -- t.total_trip_distance,
		null, -- t.total_direct_distance,
		null,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		null
	FROM  	wsh_trips t ,
		wsh_trip_stops s
	WHERE 	t.trip_id=s.trip_id AND
		s.stop_id=c_stop_id;

	CURSOR get_trip_id_from_dleg(c_dleg_id IN NUMBER) IS
	SELECT	s.trip_id
	FROM 	wsh_delivery_legs dl,
		wsh_trip_stops s
	WHERE dl.delivery_leg_id=c_dleg_id AND
	      dl.pick_up_stop_id=s.stop_id;



	CURSOR get_lane_info_with_lane_id(c_lane_id IN NUMBER) IS
	SELECT	l.lane_id,
		l.service_type_code,
		l.mode_of_transportation_code,
		l.pricelist_id
	FROM FTE_LANES l
	WHERE l.lane_id=c_lane_id;





	CURSOR get_lane_info_with_schedule_id(c_schedule_id IN NUMBER) IS
	SELECT	l.lane_id,
		l.service_type_code,
		l.mode_of_transportation_code,
		l.pricelist_id
	FROM 	FTE_LANES l,
		FTE_SCHEDULES s
	WHERE 	l.lane_id=s.lane_id and
		s.schedules_id=c_schedule_id;

	l_dleg_rec TL_delivery_leg_rec_type;
	l_trip_rec TL_trip_data_input_rec_type;
	l_trip_id NUMBER;
	l_pickup_stop_rec  TL_TRIP_STOP_INPUT_REC_TYPE;
	l_dropoff_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;

	l_dlv_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;
	i NUMBER;
	l_carrier_rec TL_CARRIER_PREF_REC_TYPE;


	l_carrier_index NUMBER;
	l_trip_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index NUMBER;

	l_weight_uom VARCHAR2(30);
	l_volume_uom VARCHAR2(30);
	l_weight NUMBER;
	l_volume NUMBER;
	l_containers NUMBER;
	l_pallets NUMBER;
	l_quantity NUMBER;

	l_departure_date DATE;
	l_arrival_date DATE;
	l_pickup_location NUMBER;
	l_dropoff_location NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Build_Cache_For_Delivery','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	IF (p_dleg_id IS NOT NULL)
	THEN
		OPEN get_trip_id_from_dleg(p_dleg_id);
		FETCH get_trip_id_from_dleg INTO l_trip_id;
		IF(get_trip_id_from_dleg%NOTFOUND)
		THEN

			CLOSE get_trip_id_from_dleg;
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_trip_id_from_dleg_fail;

		END IF;

		CLOSE get_trip_id_from_dleg;

		--Assumes that if dleg id exists a trip and a lane associated
		--with that exists, the passed lanes/schedules are ignored
		TL_Build_Cache_For_Trip(
			p_wsh_trip_id	=>	l_trip_id,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_trp_fail;
		       END IF;
		END IF;

		RETURN;


	END IF;
	IF ((p_pickup_location IS NULL) OR (p_dropoff_location IS NULL) OR
	(p_arrival_date IS NULL) OR (p_departure_date IS NULL))
	--construct dleg based on delivery
	THEN


		OPEN get_dates_loc_from_dlv(p_wsh_new_delivery_id);
		FETCH get_dates_loc_from_dlv INTO
			l_departure_date,l_arrival_date,l_pickup_location,
			l_dropoff_location;
		IF(get_dates_loc_from_dlv%NOTFOUND)
		THEN
			CLOSE get_dates_loc_from_dlv;

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_dates_loc_from_dlv_fail;

		END IF;

		CLOSE get_dates_loc_from_dlv;


	ELSE
		l_pickup_location:=p_pickup_location;
		l_dropoff_location:=p_dropoff_location;
		l_departure_date:=p_departure_date;
		l_arrival_date:=p_arrival_date;


	END IF;

	--Create Dummy DLEG

	Initialize_Dummy_Dleg(
		p_pickup_location	=>l_pickup_location,
		p_dropoff_location	=>l_dropoff_location,
		p_dlv_id	=>p_wsh_new_delivery_id,
		x_dleg_rec	=>l_dleg_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail;
	       END IF;
	END IF;

	--Create Dummy Trip

	Initialize_Dummy_Trip(
		p_departure_date	=>l_departure_date,
		p_arrival_date	=>l_arrival_date,
		x_trip_rec	=>l_trip_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_trip_fail;
		       END IF;
	END IF;
	--Create Dummy Stops

	Initialize_Dummy_Stop(
		p_date	=>l_departure_date,
		p_location=>l_pickup_location,
		x_stop_rec	=>l_pickup_stop_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail;
		END IF;
	END IF;



	Initialize_Dummy_Stop(
		p_date	=>	l_arrival_date,
		p_location	=>	l_dropoff_location,
		x_stop_rec	=>	l_dropoff_stop_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_do_stop_fail;
		END IF;
	END IF;


	--Get the wieight/vol/container/pallets of the delivery

/*

	 Add_Delivery_Details(
	 	p_delivery_id	=>p_wsh_new_delivery_id,
	 	x_weight_uom	=>l_weight_uom,
	 	x_volume_uom	=>l_volume_uom,
	 	x_weight	=>l_weight,
	 	x_volume	=>l_volume,
	 	x_containers	=>l_containers,
	 	x_pallets	=>l_pallets,
	 	x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_dlv_dtl_fail;
	       END IF;
	END IF;


*/
	--Get Facility Info
	g_tl_trip_stop_rows(1):=l_pickup_stop_rec;

	g_tl_trip_stop_rows(2):=l_dropoff_stop_rec;

	Get_Facility_Info(
		p_stop_index	=>	1,
		x_return_status	=>l_return_status);
	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail;
	       END IF;
	END IF;

	l_pickup_stop_rec:=g_tl_trip_stop_rows(1);
	l_dropoff_stop_rec:=g_tl_trip_stop_rows(2);

	--Get lane/carrier info

	l_carrier_index:=1;

	i:=p_lane_rows.FIRST;
	WHILE ( (i IS NOT NULL) AND (p_lane_rows.EXISTS(i)) )
	LOOP
		IF (p_lane_rows(i) IS NOT NULL)
		THEN

			Get_Carrier_Pref_For_Lane(
				p_lane_id	=>p_lane_rows(i),
				x_carrier_service_rec	=>l_carrier_rec,
				x_return_status	=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail;
			       END IF;
			END IF;

			TL_Get_Currency(
				p_delivery_id=>p_wsh_new_delivery_id,
				p_trip_id=>NULL,
				p_location_id=>NULL,
				p_carrier_id=>l_carrier_rec.carrier_id,
				x_currency_code=>l_carrier_rec.currency,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
			       END IF;
			END IF;



			FTE_FREIGHT_PRICING_UTIL.print_msg(
				FTE_FREIGHT_PRICING_UTIL.G_DBG,
				'After get carrier pref for lane i:'
				||i||' wuom:'||l_carrier_rec.weight_uom||
				' vuom:'||l_carrier_rec.volume_uom);
			--Insert into Carrier Cache

			g_tl_carrier_pref_rows(l_carrier_index):=l_carrier_rec;


			--Insert into Trip Cache


			g_tl_trip_rows(l_carrier_index):=l_trip_rec;

			g_tl_trip_rows(l_carrier_index).stop_reference:=
				2*l_carrier_index;
			g_tl_trip_rows(l_carrier_index).delivery_leg_reference:=
				l_carrier_index;


			OPEN get_lane_info_with_lane_id(p_lane_rows(i));

			FETCH get_lane_info_with_lane_id INTO
			g_tl_trip_rows(l_carrier_index).lane_id,
			g_tl_trip_rows(l_carrier_index).service_type,
			g_tl_trip_rows(l_carrier_index).mode_of_transport,
			g_tl_trip_rows(l_carrier_index).price_list_id;

			IF(get_lane_info_with_lane_id%NOTFOUND)
			THEN
				CLOSE get_lane_info_with_lane_id;

				raise FTE_FREIGHT_PRICING_UTIL.g_tl_lane_info_with_id_fail;

			END IF;
			CLOSE get_lane_info_with_lane_id;


			--Insert into Stop cache

			g_tl_trip_stop_rows(2*l_carrier_index):=
			l_pickup_stop_rec;
			g_tl_trip_stop_rows((2*l_carrier_index)+1):=
			l_dropoff_stop_rec;

			--Insert into dleg cache
			g_tl_delivery_leg_rows(l_carrier_index):=l_dleg_rec;






			Update_Dummy_Records(
				p_weight_uom	=>l_weight_uom ,
				p_volume_uom	=>l_volume_uom,
				p_weight	=>l_weight,
				p_volume	=>l_volume,
				p_containers	=>l_containers,
				p_pallets	=>l_pallets,
				x_carrier_rec	=>g_tl_carrier_pref_rows(l_carrier_index),
				x_trip_rec	=>g_tl_trip_rows(l_carrier_index),
				x_pickup_stop	=>g_tl_trip_stop_rows(2*l_carrier_index),
				x_dropoff_stop	=>g_tl_trip_stop_rows((2*l_carrier_index)+1),
				x_dleg	=>g_tl_delivery_leg_rows(l_carrier_index),
				x_return_status	=>l_return_status
				);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_dummy_recs_fail;
			       END IF;
			END IF;

			l_carrier_index:=l_carrier_index+1;

		END IF;
		i:=p_lane_rows.NEXT(i);

	END LOOP;

	i:=p_schedule_rows.FIRST;
	WHILE ( (i IS NOT NULL) AND (p_schedule_rows.EXISTS(i)) )
	LOOP

		IF (p_schedule_rows(i) IS NOT NULL)
		THEN

			Get_Carrier_Pref_For_Schedule(
				p_schedule_id=>	p_schedule_rows(i),
				x_carrier_service_rec=>	l_carrier_rec,
				x_return_status	=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail;
			       END IF;
			END IF;

			TL_Get_Currency(
				p_delivery_id=>p_wsh_new_delivery_id,
				p_trip_id=>NULL,
				p_location_id=>NULL,
				p_carrier_id=>l_carrier_rec.carrier_id,
				x_currency_code=>l_carrier_rec.currency,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
			       END IF;
			END IF;

			--Insert into Carrier Cache

			g_tl_carrier_pref_rows(l_carrier_index):=l_carrier_rec;

			--Insert into Trip Cache

			g_tl_trip_rows(l_carrier_index):=l_trip_rec;


			OPEN get_lane_info_with_schedule_id(p_schedule_rows(i));
			FETCH get_lane_info_with_schedule_id INTO
			g_tl_trip_rows(l_carrier_index).lane_id,
			g_tl_trip_rows(l_carrier_index).service_type,
			g_tl_trip_rows(l_carrier_index).mode_of_transport,
			g_tl_trip_rows(l_carrier_index).price_list_id;

			IF(get_lane_info_with_schedule_id%NOTFOUND)
			THEN
				--Throw an exception?
				CLOSE get_lane_info_with_schedule_id;
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_lane_info_with_sched_fail;

			END IF;

			CLOSE get_lane_info_with_schedule_id;

			--Store schedule id
			g_tl_trip_rows(l_carrier_index).schedule_id:=
				p_schedule_rows(i);

			--Insert into Stop cache

			g_tl_trip_stop_rows(2*l_carrier_index):=
				l_pickup_stop_rec;
			g_tl_trip_stop_rows((2*l_carrier_index)+1):=
				l_dropoff_stop_rec;

			--Insert into dleg cache
			g_tl_delivery_leg_rows(l_carrier_index):=l_dleg_rec;

			Update_Dummy_Records(
				p_weight_uom=>	l_weight_uom ,
				p_volume_uom=>	l_volume_uom,
				p_weight=>	l_weight,
				p_volume=>	l_volume,
				p_containers=>	l_containers,
				p_pallets=>	l_pallets,
				x_carrier_rec=> g_tl_carrier_pref_rows(l_carrier_index),
				x_trip_rec=>	g_tl_trip_rows(l_carrier_index),
				x_pickup_stop=>	g_tl_trip_stop_rows(2*l_carrier_index),
				x_dropoff_stop=>g_tl_trip_stop_rows((2*l_carrier_index)+1),
				x_dleg=>g_tl_delivery_leg_rows(l_carrier_index),
				x_return_status	=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_dummy_recs_fail;
			       END IF;
			END IF;

			l_carrier_index:=l_carrier_index+1;
		END IF;
		i:=p_lane_rows.NEXT(i);
	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trip_id_from_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trip_id_from_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_build_cache_trp_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_build_cache_trp_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dates_loc_from_dlv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dates_loc_from_dlv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_pu_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_do_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_do_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_facility_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_lane_info_with_id_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_lane_info_with_id_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_updt_dummy_recs_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_updt_dummy_recs_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_schd_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_lane_info_with_sched_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_lane_info_with_sched_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Delivery',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Delivery');


END TL_Build_Cache_For_Delivery;

--For trip search services
--assumes that the lane already assigned for the trip

PROCEDURE TL_Build_Cache_For_Trip(
	p_wsh_trip_id IN	NUMBER,
 	x_return_status OUT NOCOPY	VARCHAR2) IS

--Gets the trip info
--the pricelist id will be populated after the trip departure,arrival dates are queried
	CURSOR get_trip_info(c_trip_id IN NUMBER ) RETURN
	TL_trip_data_input_rec_type IS
	SELECT	t.trip_id,
		t.lane_id,
		null,
		t.service_level,
		t.carrier_id,
		t.mode_of_transport,
		t.vehicle_item_id,
		null,
		0,
		0,
		0,
		0,
		0,
		0,
		null, -- t.total_trip_distance,
		null, -- t.total_direct_distance,
		null,
		0,
		0,
		'N',
		null,
		null,
		null,
		null,
		null,
		null
	FROM  	wsh_trips t
	WHERE 	 t.trip_id=c_trip_id;

	l_trip_index NUMBER;
	l_carrier_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index NUMBER;
	l_child_dleg_index NUMBER;
	l_trip_rec  TL_trip_data_input_rec_type;

	l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Build_Cache_For_Trip','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;



	OPEN get_trip_info(p_wsh_trip_id);
	FETCH get_trip_info INTO l_trip_rec;
	IF (get_trip_info%NOTFOUND)
	THEN

		CLOSE get_trip_info;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'TL_Build_Cache_For_Trip',
		--	p_exc=>'g_tl_get_trip_info_fail',
		--	p_trip_id=>p_wsh_trip_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail;

	END IF;
	CLOSE get_trip_info;


	Get_Vehicle_Type(p_trip_id => l_trip_rec.trip_id,
			 p_vehicle_item_id =>l_trip_rec.vehicle_type,
			 x_vehicle_type => l_trip_rec.vehicle_type,
			 x_return_status => l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail;
	       END IF;
	END IF;



	--We assume that the lane id is present for this trip

	Cache_Trip(
		x_trip_rec	=>	l_trip_rec,
		x_trip_index	=>	l_trip_index,
		x_carrier_index	=>	l_carrier_index,
		x_stop_index	=>	l_stop_index,
		x_dleg_index	=>	l_dleg_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status	=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Trip');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_vehicle_type_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trip_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Trip');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Trip');


END TL_BUILD_CACHE_FOR_TRIP;




PROCEDURE TL_Build_Cache_For_Move(
	p_fte_move_id 	IN 	NUMBER,
        x_return_status OUT NOCOPY 	VARCHAR2) IS


--GEts all the trips for the move ordered by seq number
--the priclist ids will be populated after the trip departure,arrival dates are queried

	CURSOR get_move_trip_info(c_move_id IN NUMBER ) RETURN
	TL_trip_data_input_rec_type IS
	SELECT	t.trip_id,
		t.lane_id,
		null,
		t.service_level,
		t.carrier_id,
		t.mode_of_transport,
		t.vehicle_item_id,
		null,
		0,
		0,
		0,
		0,
		0,
		0,
		null, -- t.total_trip_distance,
		null, -- t.total_direct_distance,
		null,
		0,
		0,
		'Y',
		null,
		null,
		null,
		null,
		null,
		null
	FROM  	wsh_trips t ,
		fte_trip_moves m
	WHERE 	m.move_id=c_move_id and
		t.trip_id=m.trip_id
	ORDER BY m.sequence_number;



	l_trip_index NUMBER;
	l_carrier_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index	NUMBER;
	l_child_dleg_index NUMBER;
	l_trip_rec  TL_trip_data_input_rec_type;


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Build_Cache_For_Move','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;

	OPEN get_move_trip_info(p_fte_move_id);
	FETCH get_move_trip_info INTO l_trip_rec;
	WHILE (get_move_trip_info%FOUND)
	LOOP

		Get_Vehicle_Type(p_trip_id => l_trip_rec.trip_id,
			 	 p_vehicle_item_id =>l_trip_rec.vehicle_type,
				 x_vehicle_type => l_trip_rec.vehicle_type,
				 x_return_status => l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		       	  CLOSE get_move_trip_info;
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail;
		       END IF;
		END IF;

		--Cache each trip of the move

		Cache_Trip(
			x_trip_rec	=>	l_trip_rec,
			x_trip_index	=>	l_trip_index,
			x_carrier_index	=>	l_carrier_index,
			x_stop_index	=>	l_stop_index ,
			x_dleg_index	=>	l_dleg_index ,
			x_child_dleg_index=>l_child_dleg_index,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		       	  CLOSE get_move_trip_info;
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail;
		       END IF;
		END IF;

		Validate_Trip_Cache(
			p_trip_index=> (l_trip_index -1),
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		       	  CLOSE get_move_trip_info;
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trp_cache_fail;
		       END IF;
		END IF;


		FETCH get_move_trip_info INTO l_trip_rec;

	END LOOP;
	CLOSE get_move_trip_info;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Move');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_vehicle_type_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Move');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trp_cache_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_trp_cache_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Move');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
	   x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	   FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
	   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Move');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Move');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Build_Cache_For_Move',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Build_Cache_For_Move');


END  TL_Build_Cache_For_Move;

--For trip search services , all the data is queried for the first lane only
--It is then copied , UOM/Currency converted for the other lanes

PROCEDURE Cache_First_Trip_Lane(
	p_trip_id IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_vehicle IN NUMBER,
	x_trip_index IN OUT NOCOPY NUMBER,
	x_carrier_index IN OUT NOCOPY NUMBER,
	x_stop_index IN OUT NOCOPY NUMBER,
	x_dleg_index IN OUT NOCOPY NUMBER,
	x_child_dleg_index IN OUT NOCOPY NUMBER,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	CURSOR get_trip_info(c_trip_id IN NUMBER ) RETURN
	TL_trip_data_input_rec_type IS
	SELECT	t.trip_id,
		t.lane_id,
		null,
		t.service_level,
		t.carrier_id,
		t.mode_of_transport,
		null, --t.vehicle_item_id,
		null,
		0,
		0,
		0,
		0,
		0,
		0,
		null, -- t.total_trip_distance,
		null, -- t.total_direct_distance,
		null,
		0,
		0,
		null,
		null,
		null,
		null,
		null,
		null,
		null
	FROM  wsh_trips t
	WHERE t.trip_id=c_trip_id;

	CURSOR get_lane_info(c_lane_id IN NUMBER) IS
	SELECT	null,
		l.carrier_id,
		l.service_type_code,
		l.mode_of_transportation_code
	FROM fte_lanes l
	WHERE l.lane_id=c_lane_id;

	CURSOR get_schedule_info(c_schedule_id IN NUMBER) IS
	SELECT  l.lane_id,
	  	null,
	  	l.carrier_id,
	  	l.service_type_code,
	  	l.mode_of_transportation_code
	FROM 	fte_lanes l,
		fte_schedules s
	WHERE 	s.schedules_id=c_schedule_id and
		s.lane_id=l.lane_id;



	l_trip_rec TL_trip_data_input_rec_type;
	l_return_status VARCHAR2(1);


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Cache_First_Trip_Lane','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN get_trip_info(p_trip_id);
	FETCH get_trip_info INTO l_trip_rec;
	IF (get_trip_info%NOTFOUND)
	THEN
		CLOSE get_trip_info;

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_First_Trip_Lane',
		--	p_exc=>'g_tl_get_trip_info_fail',
		--	p_trip_id=>p_trip_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail;

	END IF;
	CLOSE get_trip_info;

	--Used the passed in vehicel type

	l_trip_rec.vehicle_type:=p_vehicle;

	IF (p_schedule_id IS NOT NULL)
	THEN
		l_trip_rec.schedule_id:=p_schedule_id;
		OPEN get_schedule_info(p_schedule_id);
		FETCH get_schedule_info INTO
		l_trip_rec.lane_id,l_trip_rec.price_list_id,
		l_trip_rec.carrier_id,l_trip_rec.service_type,
		l_trip_rec.mode_of_transport;

		IF (get_schedule_info%NOTFOUND)
		THEN
			CLOSE get_schedule_info;

			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_First_Trip_Lane',
			--	p_exc=>'g_tl_get_schedule_info_fail',
			--	p_schedule_id=>p_schedule_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_schedule_info_fail;


		END IF;
		CLOSE get_schedule_info;


		Cache_Trip(
			x_trip_rec	=>	l_trip_rec,
			x_trip_index	=>	x_trip_index,
			x_carrier_index	=>	x_carrier_index,
			x_stop_index	=>	x_stop_index ,
			x_dleg_index	=>	x_dleg_index ,
			x_child_dleg_index=>	x_child_dleg_index,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail;
		       END IF;
		END IF;

	ELSIF (p_lane_id IS NOT NULL)
	THEN
		l_trip_rec.lane_id:=p_lane_id;
		OPEN get_lane_info(p_lane_id);
		FETCH get_lane_info INTO
		l_trip_rec.price_list_id,l_trip_rec.carrier_id,
		l_trip_rec.service_type,l_trip_rec.mode_of_transport;

		IF (get_lane_info%NOTFOUND)
		THEN
			CLOSE get_lane_info;

			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_First_Trip_Lane',
			--	p_exc=>'g_tl_get_lane_info_fail',
			--	p_lane_id=>p_lane_id);

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_lane_info_fail;

		END IF;
		CLOSE get_lane_info;

		Cache_Trip(
			x_trip_rec	=>	l_trip_rec,
			x_trip_index	=>	x_trip_index,
			x_carrier_index	=>	x_carrier_index,
			x_stop_index	=>	x_stop_index,
			x_dleg_index	=>	x_dleg_index,
			x_child_dleg_index=>x_child_dleg_index,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail;
		       END IF;
		END IF;

	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Trip_Lane');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trip_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_schedule_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_schedule_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_lane_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_lane_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Trip_Lane');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Trip_Lane');


END  Cache_First_Trip_Lane;


--Each lane/scheduel in the trip search services may have a diff carrier
--with diff UOMs, the quantities are converted here

PROCEDURE Convert_UOM_For_Trip(
	p_carrier_rec_from IN TL_CARRIER_PREF_REC_TYPE,
	p_carrier_rec_to IN TL_CARRIER_PREF_REC_TYPE ,
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_stop_quantity_tab IN OUT NOCOPY TL_stop_quantity_tab_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_quantity NUMBER;

l_stop_quantity_rec TL_stop_quantity_rec_type;
i NUMBER;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Convert_UOM_For_Trip','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
	p_carrier_rec_from.distance_uom,
	p_carrier_rec_to.distance_uom,
	x_trip_rec.loaded_distance,
	0);

	IF (l_quantity IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

	END IF;
	x_trip_rec.loaded_distance:=l_quantity;


	l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
	p_carrier_rec_from.distance_uom,
	p_carrier_rec_to.distance_uom,
	x_trip_rec.unloaded_distance,
	0);


	IF (l_quantity IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

	END IF;
	x_trip_rec.unloaded_distance:=l_quantity;

	l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
	p_carrier_rec_from.distance_uom,
	p_carrier_rec_to.distance_uom,
	x_trip_rec.total_trip_distance,
	0);

	IF (l_quantity IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

	END IF;
	x_trip_rec.total_trip_distance:=l_quantity;


	l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
	p_carrier_rec_from.distance_uom,
	p_carrier_rec_to.distance_uom,
	x_trip_rec.total_direct_distance,
	0);

	IF (l_quantity IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

	END IF;
	x_trip_rec.total_direct_distance:=l_quantity;



	x_trip_rec.total_weight:=0;
	x_trip_rec.total_volume:=0;
	i:=x_stop_quantity_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		x_trip_rec.total_weight:=x_trip_rec.total_weight+
					x_stop_quantity_tab(i).pickup_weight;

		x_trip_rec.total_volume:=x_trip_rec.total_volume+
					x_stop_quantity_tab(i).pickup_volume;

		i:=x_stop_quantity_tab.NEXT(i);
	END LOOP;




        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Trip');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dist_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Trip');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Trip');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Trip');


END Convert_UOM_For_Trip;


--Each lane/scheduel in the trip search services may have a diff carrier
--with diff UOMs, the quantities are converted here

PROCEDURE Convert_UOM_For_Stop(
	p_carrier_rec_from IN TL_CARRIER_PREF_REC_TYPE,
	p_carrier_rec_to IN TL_CARRIER_PREF_REC_TYPE,
	x_stop_rec IN OUT NOCOPY TL_trip_stop_input_rec_type,
	x_stop_quantity_tab IN OUT NOCOPY TL_stop_quantity_tab_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_quantity NUMBER;

l_stop_quantity_rec TL_stop_quantity_rec_type;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Convert_UOM_For_Stop','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
	p_carrier_rec_from.distance_uom,
	p_carrier_rec_to.distance_uom,
	x_stop_rec.distance_to_next_stop,
	0);

	IF (l_quantity IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;
	END IF;
	x_stop_rec.distance_to_next_stop:=l_quantity;



	IF(x_stop_quantity_tab.EXISTS(x_stop_rec.stop_id))
	THEN
		l_stop_quantity_rec:=x_stop_quantity_tab(x_stop_rec.stop_id);
		x_stop_rec.dropoff_weight:=l_stop_quantity_rec.dropoff_weight;
		x_stop_rec.dropoff_volume:=l_stop_quantity_rec.dropoff_volume;
		x_stop_rec.pickup_weight:=l_stop_quantity_rec.pickup_weight;
		x_stop_rec.pickup_volume:=l_stop_quantity_rec.pickup_volume;

	ELSE
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;

	END IF;





        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Stop');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dist_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Stop');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Stop');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Stop');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Stop');


END Convert_UOM_For_Stop;


--Each lane/scheduel in the trip search services may have a diff carrier
--with diff UOMs, the quantities are converted here

PROCEDURE Convert_UOM_For_Dleg(
	p_carrier_rec_from IN TL_CARRIER_PREF_REC_TYPE,
	p_carrier_rec_to IN TL_CARRIER_PREF_REC_TYPE,
	x_dleg_rec IN OUT NOCOPY TL_delivery_leg_rec_type,
	x_stop_quantity_tab IN OUT NOCOPY TL_stop_quantity_tab_type,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS

	l_quantity NUMBER;
	l_map_index NUMBER;
	l_volume NUMBER;
	l_weight NUMBER;
	l_dim_weight NUMBER;
	l_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;
	l_stop_quantity_rec TL_stop_quantity_rec_type;
	l_add_to_stops_flag VARCHAR2(1);

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Convert_UOM_For_Dleg','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	l_stop_quantity_rec.pickup_weight:=0;
	l_stop_quantity_rec.pickup_volume:=0;
	l_stop_quantity_rec.dropoff_weight:=0;
	l_stop_quantity_rec.dropoff_volume:=0;



	IF (NOT x_stop_quantity_tab.EXISTS(x_dleg_rec.pickup_stop_id))
	THEN

		x_stop_quantity_tab(x_dleg_rec.pickup_stop_id):=l_stop_quantity_rec;
		l_stop_quantity_rec.stop_id:=x_dleg_rec.pickup_stop_id;


	END IF;

	IF (NOT x_stop_quantity_tab.EXISTS(x_dleg_rec.dropoff_stop_id))
	THEN

		x_stop_quantity_tab(x_dleg_rec.dropoff_stop_id):=l_stop_quantity_rec;
		l_stop_quantity_rec.stop_id:=x_dleg_rec.dropoff_stop_id;


	END IF;


	l_map_index:=NULL;
	x_dleg_rec.volume:=0;
	x_dleg_rec.weight:=0;

	IF (FTE_TL_CACHE.g_tl_delivery_detail_hash.EXISTS(x_dleg_rec.delivery_id))
	THEN

		l_map_index:=
		FTE_TL_CACHE.g_tl_delivery_detail_hash(
			x_dleg_rec.delivery_id);


		WHILE((l_map_index IS NOT NULL) AND (g_tl_delivery_detail_map.EXISTS(l_map_index)
		)
		AND(g_tl_delivery_detail_map(
			l_map_index).delivery_id=
			x_dleg_rec.delivery_id))
		LOOP

			l_detail_rec:= g_tl_shipment_line_rows(
					g_tl_delivery_detail_map(l_map_index).delivery_detail_id);

			l_volume:=NULL;
			l_weight:=NULL;
			l_add_to_stops_flag:='Y';

			--If we hit an MDC child leg where the MDC does not
			-- have a consol LPN, then we add to stop quantities
			--This flag should not change across details of a leg

			IF ((x_dleg_rec.parent_dleg_id IS NOT NULL)
				AND (l_detail_rec.assignment_type IS NOT NULL)
				AND (l_detail_rec.assignment_type='C')
				AND (l_detail_rec.parent_delivery_detail_id IS NULL))
			THEN
				l_add_to_stops_flag:='Y';
			--But in all other MDC cases, if we are dealing with
			--a child dleg we do not add to stops
			--(prevent double counting with parent dleg)
			ELSIF(x_dleg_rec.parent_dleg_id IS NOT NULL)
			THEN
				l_add_to_stops_flag:='N';
			END IF;

		        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Add to stop flag:'||l_add_to_stops_flag
				||' dtl id:'||l_detail_rec.delivery_detail_id||' dleg id:'||x_dleg_rec.delivery_leg_id);

			l_volume:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_detail_rec.volume_uom_code,
					p_carrier_rec_to.volume_uom,
					l_detail_rec.volume,
					0);

			IF(l_volume IS NULL)
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail;

			END IF;

			x_dleg_rec.volume:=x_dleg_rec.volume+l_volume;


			IF (l_add_to_stops_flag='Y')
			THEN
				x_stop_quantity_tab(x_dleg_rec.dropoff_stop_id).dropoff_volume:=
					x_stop_quantity_tab(x_dleg_rec.dropoff_stop_id).dropoff_volume+l_volume;

				x_stop_quantity_tab(x_dleg_rec.pickup_stop_id).pickup_volume:=
					x_stop_quantity_tab(x_dleg_rec.pickup_stop_id).pickup_volume+l_volume;

			END IF;


			l_weight:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_detail_rec.weight_uom_code,
					p_carrier_rec_to.weight_uom,
					l_detail_rec.gross_weight,
					0);

			IF(l_weight IS NULL)
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;

			END IF;


			Calculate_Dimensional_Weight(
				p_carrier_pref_rec=>p_carrier_rec_to,
				p_weight=>l_weight,
				p_volume=>l_volume,
				x_dim_weight=>l_dim_weight,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail;
			       END IF;
			END IF;


			x_dleg_rec.weight:=x_dleg_rec.weight+l_dim_weight;

			IF (l_add_to_stops_flag='Y')
			THEN

				x_stop_quantity_tab(x_dleg_rec.dropoff_stop_id).dropoff_weight:=
					x_stop_quantity_tab(x_dleg_rec.dropoff_stop_id).dropoff_weight+l_dim_weight;

				x_stop_quantity_tab(x_dleg_rec.pickup_stop_id).pickup_weight:=
					x_stop_quantity_tab(x_dleg_rec.pickup_stop_id).pickup_weight+l_dim_weight;

			END IF;

			l_map_index:=l_map_index+1;
		END LOOP;
	END IF;




	l_quantity:=
	FTE_FREIGHT_PRICING_UTIL.convert_uom(
		p_carrier_rec_from.distance_uom,
		p_carrier_rec_to.distance_uom,
		x_dleg_rec.distance,
		0);

	IF (l_quantity IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail;

	END IF;
	x_dleg_rec.distance:=l_quantity;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Dleg');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_calc_dim_weight_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Dleg');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dist_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dist_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Dleg');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Dleg');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Dleg');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Convert_UOM_For_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Convert_UOM_For_Dleg');


END Convert_UOM_For_Dleg;



PROCEDURE Cache_Next_Trip_Lane(
	p_trip_id IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_vehicle IN NUMBER,
	x_trip_index IN OUT NOCOPY NUMBER,
	x_carrier_index IN OUT NOCOPY NUMBER,
	x_stop_index IN OUT NOCOPY NUMBER,
	x_dleg_index IN OUT NOCOPY NUMBER,
	x_child_dleg_index IN OUT NOCOPY NUMBER,
	x_return_status	OUT	NOCOPY	VARCHAR2) IS


	l_initial_dleg_index NUMBER;
	l_initial_child_dleg_index NUMBER;
	l_stop_last	NUMBER;
	l_dleg_last	NUMBER;
	l_child_dleg_last NUMBER;
	i		NUMBER;
	j		NUMBER;
	k		NUMBER;
	l_trip_rec  TL_trip_data_input_rec_type;
	l_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_carrier_rec  TL_CARRIER_PREF_REC_TYPE;
	l_dleg_rec  TL_delivery_leg_rec_type;

	l_currency_trip_id NUMBER;
	l_currency_location_id NUMBER;

	l_stop_quantity_tab TL_stop_quantity_tab_type;

	l_return_status VARCHAR2(1);


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Cache_Next_Trip_Lane','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	l_initial_dleg_index:=x_dleg_index;
	l_initial_child_dleg_index:=x_child_dleg_index;

	l_trip_rec:=g_tl_trip_rows(x_trip_index-1);

	l_trip_rec.vehicle_type:=p_vehicle;


	l_trip_rec.delivery_leg_reference:=x_dleg_index;
	l_trip_rec.stop_reference:=x_stop_index;

	l_trip_rec.lane_id:=NULL;
	l_trip_rec.schedule_id:=NULL;

	l_stop_last:=g_tl_trip_rows(x_trip_index-1).stop_reference;
	l_dleg_last:=g_tl_trip_rows(x_trip_index-1).delivery_leg_reference;

	l_child_dleg_last:=g_tl_trip_rows(x_trip_index-1).child_dleg_reference;

	IF(l_child_dleg_last IS NULL)
	THEN

		l_trip_rec.child_dleg_reference:=NULL;
	ELSE
		l_trip_rec.child_dleg_reference:=x_child_dleg_index;

	END IF;

	IF (p_schedule_id IS NOT NULL)
	THEN

		--Gather info from schedule

		 Get_Carrier_Pref_For_Schedule(
			p_schedule_id=>	p_schedule_id,
			x_carrier_service_rec=>	l_carrier_rec,
			x_return_status	=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail;
		       END IF;
		END IF;

		 Get_Trip_Info_From_Schedule(
			p_schedule_id=>	p_schedule_id,
			x_trip_rec=>	l_trip_rec,
			x_return_status	=>l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		 THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
			   raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_schd_fail;
			END IF;
		END IF;




		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Trip and priice list id'||l_trip_rec.trip_id||':'||l_trip_rec.lane_id||':'||l_trip_rec.price_list_id);

	ELSIF (p_lane_id IS NOT NULL)
	THEN


		--Gather info from lane

		Get_Carrier_Pref_For_Lane(
			p_lane_id	=>p_lane_id,
			x_carrier_service_rec	=>l_carrier_rec,
			x_return_status	=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail;
		       END IF;
		END IF;

		Get_Trip_Info_From_Lane(
			p_lane_id=>	p_lane_id,
			x_trip_rec=>	l_trip_rec,
			x_return_status	=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_lane_fail;
		       END IF;
		END IF;


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Trip and priice list id'||l_trip_rec.trip_id||':'||l_trip_rec.lane_id||':'||l_trip_rec.price_list_id);

	ELSE

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Next_Trip_Lane',
		--	p_exc=>'g_tl_no_lane_sched',
		--	p_trip_id=>p_trip_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched;

		--throw exception
	END IF;


	--Copy over previous trip,carrier

	g_tl_trip_rows(x_trip_index):=l_trip_rec;
	g_tl_carrier_pref_rows(x_carrier_index):=l_carrier_rec;


	--MULTICURRENCY
	IF(p_trip_id = FAKE_TRIP_ID)
	THEN
		l_currency_trip_id:=NULL;
		IF((g_tl_trip_stop_rows(l_stop_last).location_id IS NULL)
		OR (g_tl_trip_stop_rows(l_stop_last).location_id = FAKE_STOP_ID_1)
		OR (g_tl_trip_stop_rows(l_stop_last).location_id = FAKE_STOP_ID_2))
		THEN
			l_currency_location_id:=NULL;
		ELSE
			l_currency_location_id:=g_tl_trip_stop_rows(l_stop_last).location_id;
		END IF;

	ELSE
		l_currency_trip_id:=p_trip_id;
		l_currency_location_id:=NULL;
	END IF;



	TL_Get_Currency(
		p_delivery_id=>NULL,
		p_trip_id=>l_currency_trip_id,
		p_location_id=>l_currency_location_id,
		p_carrier_id=>l_carrier_rec.carrier_id,
		x_currency_code=>l_carrier_rec.currency,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
	       END IF;
	END IF;


	Validate_Carrier_Info(
		x_carrier_info 	=>	g_tl_carrier_pref_rows(x_carrier_index),
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN

			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Next_Trip_Lane',
			--	p_exc=>'g_tl_validate_carrier_fail',
			--	p_carrier_id=>g_tl_carrier_pref_rows(x_carrier_index).carrier_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail;
		END IF;
	END IF;


	l_stop_quantity_tab.DELETE;

	j:=x_dleg_index-1;
	FOR k IN l_dleg_last ..j
	LOOP

		--Copy over previous trip's dlegs

		g_tl_delivery_leg_rows(x_dleg_index):=
			g_tl_delivery_leg_rows(k);



		--Convert uoms as it may have a diff carrier

		Convert_UOM_For_Dleg(
			p_carrier_rec_from=>	g_tl_carrier_pref_rows(x_carrier_index-1),
			p_carrier_rec_to=>	g_tl_carrier_pref_rows(x_carrier_index),
			x_dleg_rec=>	g_tl_delivery_leg_rows(x_dleg_index),
			x_stop_quantity_tab=>l_stop_quantity_tab,
			x_return_status	=>l_return_status);



		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_dleg_fail;
		       END IF;
		END IF;

		Validate_Dleg_Info(
			x_dleg_info=>	g_tl_delivery_leg_rows(x_dleg_index),
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  --Show only generic message
			  --FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Next_Trip_Lane',
			--	p_exc=>'g_tl_validate_dleg_fail',
			--	p_delivery_leg_id=>g_tl_delivery_leg_rows(x_dleg_index).delivery_leg_id);


			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail;
		       END IF;
		END IF;

		x_dleg_index:=x_dleg_index+1;
		l_dleg_last:=l_dleg_last+1;

	END LOOP;


	IF (l_child_dleg_last IS NOT NULL)
	THEN


		j:=x_child_dleg_index-1;
		FOR k IN l_child_dleg_last ..j
		LOOP

			--Copy over previous trip's dlegs

			g_tl_chld_delivery_leg_rows(x_child_dleg_index):=
				g_tl_chld_delivery_leg_rows(k);



			--Convert uoms as it may have a diff carrier

			Convert_UOM_For_Dleg(
				p_carrier_rec_from=>	g_tl_carrier_pref_rows(x_carrier_index-1),
				p_carrier_rec_to=>	g_tl_carrier_pref_rows(x_carrier_index),
				x_dleg_rec=>	g_tl_chld_delivery_leg_rows(x_child_dleg_index),
				x_stop_quantity_tab=>l_stop_quantity_tab,
				x_return_status	=>l_return_status);



			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_dleg_fail;
			       END IF;
			END IF;

			Validate_Dleg_Info(
				x_dleg_info=>	g_tl_chld_delivery_leg_rows(x_child_dleg_index),
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

				--Show only generic message
				--  FTE_FREIGHT_PRICING_UTIL.setmsg (
				--	p_api=>'Cache_Next_Trip_Lane',
				--	p_exc=>'g_tl_validate_dleg_fail',
				--	p_delivery_leg_id=>g_tl_chld_delivery_leg_rows(x_child_dleg_index).delivery_leg_id);


				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail;
			       END IF;
			END IF;

			x_child_dleg_index:=x_child_dleg_index+1;
			l_child_dleg_last:=l_child_dleg_last+1;

		END LOOP;

		--Clear all the children_weight,children_volume in the parent dlegs
		--For sync to work
		i:=l_initial_dleg_index;
		WHILE(i<x_dleg_index)
		LOOP
			g_tl_delivery_leg_rows(i).children_weight:=0;
			g_tl_delivery_leg_rows(i).children_volume:=0;

			i:=g_tl_delivery_leg_rows.NEXT(i);
		END LOOP;



		Sync_Child_Dleg_Cache(
			p_initial_dleg_index=>l_initial_dleg_index,
			p_intial_child_dleg_index=>l_initial_child_dleg_index,
			p_current_dleg_index=>x_dleg_index,
			p_chld_dleg_index=>x_child_dleg_index,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_sync_dleg_fail;
		       END IF;
		END IF;


	END IF;



	j:=x_stop_index-1;
	FOR k IN l_stop_last ..j
	LOOP

		--Copy over previous trip's stops

		g_tl_trip_stop_rows(x_stop_index):=
			g_tl_trip_stop_rows(k);


		--Each carrier may have a different region level
		--Therefore the stop regions are recalculated

		g_tl_trip_stop_rows(x_stop_index).stop_region:=NULL;

		Get_Region_For_Location(
			p_location_id=>	g_tl_trip_stop_rows(x_stop_index).location_id,
			p_region_type=>	g_tl_carrier_pref_rows(x_carrier_index).region_level,
			x_region_id=>	g_tl_trip_stop_rows(x_stop_index).stop_region,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,
			  'Failed to get region for location:'
			  ||g_tl_trip_stop_rows(x_stop_index).location_id
			  ||'Carrier:'||g_tl_carrier_pref_rows(x_carrier_index).carrier_id
			  ||'Region Level:'||g_tl_carrier_pref_rows(x_carrier_index).region_level);

			  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
		       END IF;
		END IF;


		--Convert uoms as it may have a diff carrier

		Convert_UOM_For_Stop(
			p_carrier_rec_from=>	g_tl_carrier_pref_rows(x_carrier_index-1),
			p_carrier_rec_to=>	g_tl_carrier_pref_rows(x_carrier_index),
			x_stop_rec=>	g_tl_trip_stop_rows(x_stop_index),
			x_stop_quantity_tab=>l_stop_quantity_tab,
			x_return_status	=>l_return_status);



		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_stop_fail;
		       END IF;
		END IF;

		Validate_Stop_Info(
		p_carrier_pref_rec => g_tl_carrier_pref_rows(x_carrier_index),
		x_stop_info=>	g_tl_trip_stop_rows(x_stop_index),
		x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Next_Trip_Lane',
			--	p_exc=>'g_tl_validate_stop_fail',
			--	p_stop_id=>g_tl_trip_stop_rows(x_stop_index).stop_id);


			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail;
		       END IF;
		END IF;

		x_stop_index:=x_stop_index+1;
		l_stop_last:=l_stop_last+1;

	END LOOP;



	--Make UOM conversion for diff carrier

	Convert_UOM_For_Trip(
		p_carrier_rec_from=>	g_tl_carrier_pref_rows(x_carrier_index-1),
		p_carrier_rec_to=>	g_tl_carrier_pref_rows(x_carrier_index),
		x_trip_rec=>	g_tl_trip_rows(x_trip_index),
		x_stop_quantity_tab=>l_stop_quantity_tab,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_trip_fail;
	       END IF;
	END IF;

	Validate_Trip_Info(
		x_trip_info=>	g_tl_trip_rows(x_trip_index),
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		--Show only generic message
		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Next_Trip_Lane',
		--	p_exc=>'g_tl_validate_trip_fail',
		--	p_trip_id=>p_trip_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail;
	       END IF;
	END IF;




	x_trip_index:=x_trip_index+1;
	x_carrier_index:=x_carrier_index+1;



       	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_sync_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_sync_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trp_inf_frm_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_lane_sched_veh');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_schd_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_dleg_id_in_dtl THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_dleg_id_in_dtl');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_lane_sched');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_convert_uom_for_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_convert_uom_for_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_convert_uom_for_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_convert_uom_for_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_Next_Trip_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_Next_Trip_Lane');


END Cache_Next_Trip_Lane;



--Cache info for the trip search services
--For each lane/sched passed in a seperate trip and associates
--stops,dlegs,carr will be cached. However the ids for the trips
--stops,dlegs, carr will remain the same

PROCEDURE TL_BUILD_CACHE_FOR_TRP_COMPARE(
	p_wsh_trip_id IN Number ,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
	x_return_status OUT NOCOPY Varchar2) IS




	l_trip_index NUMBER;
	l_carrier_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index	NUMBER;
	l_child_dleg_index NUMBER;

	l_last_trip_index 	NUMBER;
	l_last_carrier_index 	NUMBER;
	l_last_stop_index 	NUMBER;
	l_last_dleg_index	NUMBER;


	i NUMBER;
	j NUMBER;

	l_cached_first_trip_flag VARCHAR2(1);


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;


	l_cached_first_trip_flag:='N';
	i:=p_lane_rows.FIRST;

	-- Query up the trip/stops/dleg and cache it
	WHILE (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND
	p_vehicle_rows.EXISTS(i) AND (l_cached_first_trip_flag='N'))
	LOOP

		 Cache_First_Trip_Lane(
		  p_trip_id	=>	p_wsh_trip_id ,
		  p_lane_id	=>	p_lane_rows(i) ,
		  p_schedule_id	=>	p_schedule_rows(i) ,
		  p_vehicle	=>	p_vehicle_rows(i) ,
		  x_trip_index	=>	l_trip_index ,
		  x_carrier_index	=>	l_carrier_index ,
		  x_stop_index	=>	l_stop_index ,
		  x_dleg_index	=>	l_dleg_index ,
		  x_child_dleg_index=>l_child_dleg_index,
		  x_return_status=>	l_return_status);

		  l_cached_first_trip_flag:='Y';

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		  THEN
		         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		         THEN

		         	Delete_Cache(x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
				       END IF;
				END IF;

				Initialize_Cache_Indices(
					x_trip_index=>	l_trip_index,
					x_stop_index=>	l_stop_index,
					x_dleg_index=>	l_dleg_index,
					x_carrier_index=>l_carrier_index,
					x_child_dleg_index=>l_child_dleg_index,
					x_return_status=> l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
				       END IF;
				END IF;

				l_cached_first_trip_flag:='N';
		         END IF;
		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

	IF (l_cached_first_trip_flag='N')
	THEN


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached;

	END IF;

	--The first lane/schedule has been cached
	--For the remaining lanes/schedules we shall copy the data we captured above
	--and alter the UOMs according to the lanes




	--Alter and copy into cache for each lane



	WHILE ( (i IS NOT NULL) AND (p_lane_rows.EXISTS(i)))
	LOOP

		IF (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND p_vehicle_rows.EXISTS(i)
			AND ((p_lane_rows(i) IS NOT NULL) OR (p_schedule_rows(i) IS NOT NULL) ))
		THEN

			--Store all the indices

			l_last_trip_index:=l_trip_index;
			l_last_carrier_index:=l_carrier_index;
			l_last_stop_index:=l_stop_index;
			l_last_dleg_index:=l_dleg_index;



			Cache_Next_Trip_Lane(
				p_trip_id=>p_wsh_trip_id,
				p_lane_id=> p_lane_rows(i),
				p_schedule_id=> p_schedule_rows(i),
				p_vehicle=> p_vehicle_rows(i) ,
				x_trip_index => l_trip_index,
				x_carrier_index=>l_carrier_index,
				x_stop_index=>l_stop_index,
				x_dleg_index=>l_dleg_index,
				x_child_dleg_index=>l_child_dleg_index,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				   l_warning_count:=l_warning_count+1;
			       	   IF (p_schedule_rows(i) IS NOT NULL)
			       	   THEN

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache trip'
			       	   	   ||p_wsh_trip_id||' schedule '||p_schedule_rows(i)||':g_tl_cmp_trip_sched_fail');

					--Show only generic message
					   --FTE_FREIGHT_PRICING_UTIL.setmsg (
						--p_api=>'TL_BUILD_CACHE_FOR_TRP_COMPARE',
						--p_exc=>'g_tl_cmp_trip_sched_fail',
						--p_msg_type=>'W',
						--p_trip_id=> p_wsh_trip_id,
						--p_schedule_id=>p_schedule_rows(i));
				    ELSE

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache trip'
			       	   	   ||p_wsh_trip_id||' lane '||p_lane_rows(i)||':g_tl_cmp_trip_lane_fail');
				    --Show only generic message
					--   FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_BUILD_CACHE_FOR_TRP_COMPARE',
					--	p_exc=>'g_tl_cmp_trip_lane_fail',
					--	p_msg_type=>'W',
					--	p_trip_id=> p_wsh_trip_id,
					--	p_lane_id=>p_lane_rows(i));


				    END IF;

				--Restore indices

				l_trip_index:=l_last_trip_index;
				l_carrier_index:=l_last_carrier_index;
				l_stop_index:=l_last_stop_index;
				l_dleg_index:=l_last_dleg_index;


				--DELETE Newly added cache

				Partially_Delete_Cache(
					p_trip_index=>l_trip_index,
					p_carrier_index=>l_carrier_index,
					p_stop_index=>l_stop_index,
					p_dleg_index=>l_dleg_index,
					p_child_dleg_index=>l_child_dleg_index);

			       END IF;
			END IF;




		ELSE

			--Show only generic message
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_BUILD_CACHE_FOR_TRP_COMPARE',
			--	p_exc=>'g_tl_no_lane_sched_veh',
			--	p_trip_id=>p_wsh_trip_id);

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh;

		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_TRP_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_trips_cached');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_TRP_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_first_trp_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_TRP_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_first_trp_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_TRP_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_lane_sched_veh');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_TRP_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_TRP_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_TRP_COMPARE');


END TL_BUILD_CACHE_FOR_TRP_COMPARE;



PROCEDURE Get_internal_location(
       p_dummy_location_id   IN         NUMBER,
       x_internal_location_id    OUT NOCOPY NUMBER,
       x_return_status               OUT NOCOPY VARCHAR2)

IS


	CURSOR c_get_internal_loc_id (c_int_cust_loc_id IN  NUMBER)
	IS
	SELECT ploc.LOCATION_ID internal_org_location_id
	FROM PO_LOCATION_ASSOCIATIONS_ALL ploc,
	     hz_cust_site_uses_all site_uses,
	     hz_cust_acct_sites_all acct_sites,
	     HZ_PARTY_SITES sites
	WHERE ploc.SITE_USE_ID = site_uses.SITE_USE_ID
	AND site_uses.CUST_ACCT_SITE_ID = acct_sites.CUST_ACCT_SITE_ID
	AND acct_sites.PARTY_SITE_ID = sites.PARTY_SITE_ID
	AND ploc.CUSTOMER_ID = acct_sites.CUST_ACCOUNT_ID
	AND sites.location_id = c_int_cust_loc_id;


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_internal_location','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_internal_location_id :=NULL;

	IF(p_dummy_location_id IS NOT NULL)
	THEN
		OPEN c_get_internal_loc_id(p_dummy_location_id);
		FETCH c_get_internal_loc_id INTO x_internal_location_id;
		CLOSE c_get_internal_loc_id;

	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_internal_location');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_internal_location',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_internal_location');



END Get_internal_location;



PROCEDURE Cache_First_Delivery_Lane(
		p_wsh_delivery_id IN NUMBER,
		p_lane_id IN NUMBER,
		p_schedule_id IN NUMBER,
	        p_dep_date                IN     DATE DEFAULT sysdate,
	        p_arr_date                IN     DATE DEFAULT sysdate,
		p_pickup_location IN NUMBER,
		p_dropoff_location IN NUMBER,
		p_vehicle_type_id IN NUMBER,
		x_trip_index IN OUT NOCOPY NUMBER,
		x_carrier_index IN OUT NOCOPY NUMBER,
		x_stop_index IN OUT NOCOPY NUMBER,
		x_dleg_index IN OUT NOCOPY NUMBER,
		x_return_status OUT NOCOPY Varchar2)
IS



	CURSOR get_dates_loc_from_dlv(c_delivery_id IN NUMBER) IS
	SELECT	d.initial_pickup_date,
		d.ultimate_dropoff_date,
		d.initial_pickup_location_id,
		d.ultimate_dropoff_location_id
	FROM wsh_new_deliveries d
	WHERE d.delivery_id=c_delivery_id;




	l_internal_location NUMBER;


	l_trip_rec TL_trip_data_input_rec_type;

	l_carrier_rec	TL_CARRIER_PREF_REC_TYPE ;
	l_pickup_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_dropoff_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;

	l_dleg_rec TL_delivery_leg_rec_type;
	l_stop_distance_tab	TL_stop_distance_tab_type;
	l_initial_stop_index NUMBER;
	l_initial_dleg_index NUMBER;
	l_region_id 	NUMBER;

	l_pickup_location NUMBER;
	l_dropoff_location NUMBER;
	l_departure_date DATE;
	l_arrival_date DATE;

	i NUMBER;
	l_physical_previous_flag VARCHAR2(1);


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;




BEGIN


	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Cache_First_Delivery_Lane','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_initial_stop_index:=x_stop_index;
	l_initial_dleg_index:=x_dleg_index;




	IF ((p_pickup_location IS NULL) OR (p_dropoff_location IS NULL) OR
	(p_arr_date IS NULL) OR (p_dep_date IS NULL))
	--construct dleg based on delivery
	THEN


		OPEN get_dates_loc_from_dlv(p_wsh_delivery_id);
		FETCH get_dates_loc_from_dlv INTO
			l_departure_date,l_arrival_date,l_pickup_location,
			l_dropoff_location;
		IF(get_dates_loc_from_dlv%NOTFOUND)
		THEN
			CLOSE get_dates_loc_from_dlv;

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_dates_loc_from_dlv_fail;

		END IF;

		CLOSE get_dates_loc_from_dlv;


	ELSE
		l_pickup_location:=p_pickup_location;
		l_dropoff_location:=p_dropoff_location;
		l_departure_date:=p_dep_date;
		l_arrival_date:=p_arr_date;


	END IF;

	l_internal_location:=NULL;
	Get_internal_location(
	       p_dummy_location_id=>l_dropoff_location,
	       x_internal_location_id=>l_internal_location,
       	       x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_int_loc_fail;
	       END IF;
	END IF;
	IF (l_internal_location IS NOT NULL)
	THEN
		l_dropoff_location:=l_internal_location;

	END IF;



	--Create Dummy DLEG

	Initialize_Dummy_Dleg(
		p_pickup_location	=>l_pickup_location,
		p_dropoff_location	=>l_dropoff_location,
		p_dlv_id	=>p_wsh_delivery_id,
		x_dleg_rec	=>l_dleg_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail;
	       END IF;
	END IF;

	--Create Dummy Trip

	Initialize_Dummy_Trip(
		p_departure_date	=>l_departure_date,
		p_arrival_date	=>l_arrival_date,
		x_trip_rec	=>l_trip_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_trip_fail;
		       END IF;
	END IF;
	--Create Dummy Stops

	Initialize_Dummy_Stop(
		p_date	=>l_departure_date,
		p_location=>l_pickup_location,
		x_stop_rec	=>l_pickup_stop_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail;
		END IF;
	END IF;


	l_pickup_stop_rec.stop_id:=FAKE_STOP_ID_1;

	Initialize_Dummy_Stop(
		p_date	=>	l_arrival_date,
		p_location	=>	l_dropoff_location,
		x_stop_rec	=>	l_dropoff_stop_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_do_stop_fail;
		END IF;
	END IF;

	l_dropoff_stop_rec.stop_id:=FAKE_STOP_ID_2;


	l_trip_rec.vehicle_type:=p_vehicle_type_id;

	IF (p_lane_id IS NOT NULL)
	THEN
		Get_Carrier_Pref_For_Lane(
			p_lane_id =>p_lane_id,
			x_carrier_service_rec=>l_carrier_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail;
			END IF;
		END IF;


		Get_Trip_Info_From_Lane(
			p_lane_id=>	p_lane_id,
			x_trip_rec=>	l_trip_rec,
			x_return_status	=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_lane_fail;
		       END IF;
		END IF;


	ELSIF (p_schedule_id IS NOT NULL)
	THEN
		Get_Carrier_Pref_For_Schedule(
			p_schedule_id =>p_schedule_id,
			x_carrier_service_rec=>l_carrier_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail;
			END IF;
		END IF;



		Get_Trip_Info_From_Schedule(
			p_schedule_id=>	p_schedule_id,
			x_trip_rec=>	l_trip_rec,
			x_return_status	=>l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		 THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
			   raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_schd_fail;
			END IF;
		END IF;


	END IF;

	--MULTICURRENCY
	TL_Get_Currency(
		p_delivery_id=>p_wsh_delivery_id,
		p_trip_id=>NULL,
		p_location_id=>NULL,
		p_carrier_id=>l_carrier_rec.carrier_id,
		x_currency_code=>l_carrier_rec.currency,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
	       END IF;
	END IF;

	Validate_Carrier_Info(
		x_carrier_info 	=>	l_carrier_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_Cache_First_Estimate_Trip',
			--	p_exc=>'g_tl_validate_carrier_fail',
			--	p_carrier_id=>l_carrier_rec.carrier_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail;
		END IF;
	END IF;

	--Insert carrier info into cache
	g_tl_carrier_pref_rows(x_carrier_index):=l_carrier_rec;
	x_carrier_index:=x_carrier_index+1;




	Get_Region_For_Location(
		p_location_id=>	l_pickup_stop_rec.location_id,
		p_region_type=>	l_carrier_rec.region_level,
		x_region_id=>	l_pickup_stop_rec.stop_region,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get_Region_For_LocationRES: '||
		l_pickup_stop_rec.location_id ||':'||l_pickup_stop_rec.stop_region);



	Get_Region_For_Location(
		p_location_id=>	l_dropoff_stop_rec.location_id,
		p_region_type=>	l_carrier_rec.region_level,
		x_region_id=>	l_dropoff_stop_rec.stop_region,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get_Region_For_LocationRES: '||
		l_dropoff_stop_rec.location_id ||':'||l_dropoff_stop_rec.stop_region);


	--Get the wieight/vol/container/pallets of the delivery

	Add_Delivery_Details(
		p_delivery_id =>p_wsh_delivery_id,
		p_carrier_pref_rec =>l_carrier_rec,
		x_pickup_stop_rec =>l_pickup_stop_rec,
		x_dropoff_stop_rec=>l_dropoff_stop_rec,
		x_dleg_rec =>l_dleg_rec,
		x_return_status	=>l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_dlv_dtl_fail;
	       END IF;
	END IF;



	Validate_Dleg_Info(
		x_dleg_info=>	l_dleg_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail;
	       END IF;
	END IF;

	g_tl_delivery_leg_rows(x_dleg_index):=l_dleg_rec;
	x_dleg_index:=x_dleg_index+1;



	Add_Inputs_For_Distance(
	 p_from_stop_rec=> l_pickup_stop_rec,
	 p_to_stop_rec=> 	l_dropoff_stop_rec,
	 p_empty_flag=>	'N',
	 x_stop_distance_tab=>	l_stop_distance_tab,
	 x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail;
	       END IF;
	END IF;



	--Update trip rec

	Update_Trip_With_Stop_Info(
		p_stop_rec	=>	l_pickup_stop_rec,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail;
	       END IF;
	END IF;
	--Insert Stop info into Cache

	--Perform validation after getting dist,time,fac info

	g_tl_trip_stop_rows(x_stop_index):=l_pickup_stop_rec;
	x_stop_index:=x_stop_index+1;





	--Update trip rec

	Update_Trip_With_Stop_Info(
		p_stop_rec	=>	l_dropoff_stop_rec,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail;
	       END IF;
	END IF;
	--Insert Stop info into Cache

	--Perform validation after getting dist,time,fac info

	g_tl_trip_stop_rows(x_stop_index):=l_dropoff_stop_rec;
	x_stop_index:=x_stop_index+1;




	g_tl_trip_stop_rows(x_stop_index-1).distance_to_next_stop:=0;
	g_tl_trip_stop_rows(x_stop_index-1).time_to_next_stop:=0;





	--GEt distances/time from mileage table, update, stop, dleg buffer, trip
	--loaded, unlaoded distances

	Get_Distances(
		p_stop_index	=>	l_initial_stop_index,
		p_dleg_index	=>	l_initial_dleg_index,
		p_carrier_rec	=>	l_carrier_rec,
		x_stop_distance_tab	=>l_stop_distance_tab,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail;
       		END IF;
	END IF;


	--Get facility Info and store into stop cache
	Get_Facility_Info(p_stop_index	=>	l_initial_stop_index,
			x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get facility information');
	          --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail;
	       END IF;
	END IF;

	--Validate All Stops(all the stop,distance,time,fac info has beengathered

	FOR i IN l_initial_stop_index..(x_stop_index-1)
	LOOP
		--Determine if the stop is pickup/dropoff/both or none
		Get_Stop_Type(x_stop_rec=>g_tl_trip_stop_rows(i));

		Validate_Stop_Info(
		p_carrier_pref_rec=>l_carrier_rec,
		x_stop_info=>	g_tl_trip_stop_rows(i),
		x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail;
		       END IF;
		END IF;

	END LOOP;





	--Update trip rec
	l_trip_rec.number_of_stops:=2;


	l_trip_rec.distance_method:=l_carrier_rec.distance_calculation_method;

	--get the arrival and dep dates of the trip
	--from first and last stop

	l_trip_rec.planned_departure_date:=
		g_tl_trip_stop_rows(l_initial_stop_index).planned_departure_date;
	l_trip_rec.planned_arrival_date:=
		g_tl_trip_stop_rows(x_stop_index-1).planned_arrival_date;

	--Dead head trip has no dlegs 3958974

	l_trip_rec.dead_head:='N';


	l_trip_rec.stop_reference:=l_initial_stop_index;
	l_trip_rec.delivery_leg_reference:=l_initial_dleg_index;

	--Insert into trip cache

	Validate_Trip_Info(
		x_trip_info=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail;
	       END IF;
	END IF;

	g_tl_trip_rows(x_trip_index):=l_trip_rec;
	x_trip_index:=x_trip_index+1;




        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;



EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dates_loc_from_dlv_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dates_loc_from_dlv_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_int_loc_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_int_loc_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_pu_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_do_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_do_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');




   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trp_inf_frm_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_schd_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_schd_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trp_inf_frm_schd_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_reg_for_loc_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_pickup_qty_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_pickup_qty_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_ip_dist_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_updt_trip_with_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_distances_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_facility_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Cache_First_Delivery_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Cache_First_Delivery_Lane');



END Cache_First_Delivery_Lane;



PROCEDURE TL_BUILD_CACHE_FOR_DLV_COMPARE(
	p_wsh_delivery_id IN Number ,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
	p_dep_date                IN     DATE DEFAULT sysdate,
	p_arr_date                IN     DATE DEFAULT sysdate,
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	x_return_status OUT NOCOPY Varchar2)

IS
	l_trip_index NUMBER;
	l_carrier_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index	NUMBER;
	l_child_dleg_index NUMBER;

	l_last_trip_index 	NUMBER;
	l_last_carrier_index 	NUMBER;
	l_last_stop_index 	NUMBER;
	l_last_dleg_index	NUMBER;


	i NUMBER;
	j NUMBER;

	l_cached_first_trip_flag VARCHAR2(1);


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;


	l_cached_first_trip_flag:='N';
	i:=p_lane_rows.FIRST;

	-- Query up the trip/stops/dleg and cache it
	WHILE (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND
	p_vehicle_rows.EXISTS(i) AND (l_cached_first_trip_flag='N'))
	LOOP


		Cache_First_Delivery_Lane(
		p_wsh_delivery_id =>p_wsh_delivery_id,
		p_lane_id =>p_lane_rows(i),
		p_schedule_id =>p_schedule_rows(i),
	        p_dep_date =>p_dep_date,
	        p_arr_date =>p_arr_date,
		p_pickup_location=>p_pickup_location_id,
		p_dropoff_location=>p_dropoff_location_id,
		p_vehicle_type_id => p_vehicle_rows(i),
		x_trip_index => l_trip_index,
		x_carrier_index => l_carrier_index,
		x_stop_index => l_stop_index,
		x_dleg_index => l_dleg_index ,
		x_return_status =>l_return_status);



		  l_cached_first_trip_flag:='Y';

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		  THEN
		         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		         THEN

		         	Delete_Cache(x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
				       END IF;
				END IF;

				Initialize_Cache_Indices(
					x_trip_index=>	l_trip_index,
					x_stop_index=>	l_stop_index,
					x_dleg_index=>	l_dleg_index,
					x_carrier_index=>l_carrier_index,
					x_child_dleg_index=>l_child_dleg_index,
					x_return_status=> l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
				       END IF;
				END IF;

				l_cached_first_trip_flag:='N';
		         END IF;
		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

	IF (l_cached_first_trip_flag='N')
	THEN


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached;

	END IF;

	--The first lane/schedule has been cached
	--For the remaining lanes/schedules we shall copy the data we captured above
	--and alter the UOMs according to the lanes




	--Alter and copy into cache for each lane



	WHILE ( (i IS NOT NULL) AND (p_lane_rows.EXISTS(i)))
	LOOP

		IF (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND p_vehicle_rows.EXISTS(i)
			AND ((p_lane_rows(i) IS NOT NULL) OR (p_schedule_rows(i) IS NOT NULL) ))
		THEN

			--Store all the indices

			l_last_trip_index:=l_trip_index;
			l_last_carrier_index:=l_carrier_index;
			l_last_stop_index:=l_stop_index;
			l_last_dleg_index:=l_dleg_index;



			Cache_Next_Trip_Lane(
				p_trip_id=>FAKE_TRIP_ID,
				p_lane_id=> p_lane_rows(i),
				p_schedule_id=> p_schedule_rows(i),
				p_vehicle=> p_vehicle_rows(i) ,
				x_trip_index => l_trip_index,
				x_carrier_index=>l_carrier_index,
				x_stop_index=>l_stop_index,
				x_dleg_index=>l_dleg_index,
				x_child_dleg_index=>l_child_dleg_index,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				   l_warning_count:=l_warning_count+1;
			       	   IF (p_schedule_rows(i) IS NOT NULL)
			       	   THEN

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache Delivery'
			       	   	   ||p_wsh_delivery_id||' schedule '||p_schedule_rows(i)||':g_tl_cmp_trip_sched_fail');

					   --FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_BUILD_CACHE_FOR_DLV_COMPARE',
					--	p_exc=>'g_tl_cmp_trip_sched_fail',
					--	p_msg_type=>'W',
					--	p_trip_id=> p_wsh_trip_id,
					--	p_schedule_id=>p_schedule_rows(i));
				    ELSE

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache delivery'
			       	   	   ||p_wsh_delivery_id||' lane '||p_lane_rows(i)||':g_tl_cmp_trip_lane_fail');

					--   FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_BUILD_CACHE_FOR_DLV_COMPARE',
					--	p_exc=>'g_tl_cmp_trip_lane_fail',
					--	p_msg_type=>'W',
					--	p_trip_id=> p_wsh_trip_id,
					--	p_lane_id=>p_lane_rows(i));


				    END IF;

				--Restore indices

				l_trip_index:=l_last_trip_index;
				l_carrier_index:=l_last_carrier_index;
				l_stop_index:=l_last_stop_index;
				l_dleg_index:=l_last_dleg_index;


				--DELETE Newly added cache

				Partially_Delete_Cache(
					p_trip_index=>l_trip_index,
					p_carrier_index=>l_carrier_index,
					p_stop_index=>l_stop_index,
					p_dleg_index=>l_dleg_index,
					p_child_dleg_index=>l_child_dleg_index);

			       END IF;
			END IF;




		ELSE

			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_BUILD_CACHE_FOR_DLV_COMPARE',
			--	p_exc=>'g_tl_no_lane_sched_veh',
			--	p_trip_id=>p_wsh_trip_id);

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh;

		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_DLV_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_trips_cached');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_DLV_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_first_trp_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_DLV_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_first_trp_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_DLV_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_lane_sched_veh');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_DLV_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_DLV_COMPARE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_DLV_COMPARE');
END TL_BUILD_CACHE_FOR_DLV_COMPARE;




PROCEDURE TL_BUILD_CACHE_FOR_LCS(
	p_wsh_trip_id IN Number ,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN dbms_utility.number_array ,
	p_vehicle_rows IN  dbms_utility.number_array,
	x_return_status OUT NOCOPY Varchar2) IS



l_vehicle_type_id NUMBER;
l_vehicle_rows dbms_utility.number_array;
l_schedule_rows dbms_utility.number_array;
l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
i NUMBER;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_BUILD_CACHE_FOR_LCS','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	TL_BUILD_CACHE_FOR_TRP_COMPARE(
		p_wsh_trip_id=>	p_wsh_trip_id,
		p_lane_rows=>	p_lane_rows,
		p_schedule_rows=>	p_schedule_rows,
		p_vehicle_rows=>	p_vehicle_rows,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_trp_cmp_fail;
	       END IF;
	END IF;
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_LCS');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_vehicle_type_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_LCS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_vehicle_type_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_LCS');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_bld_cache_trp_cmp_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_LCS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_bld_cache_trp_cmp_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_LCS');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_vehicle_type THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_LCS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_vehicle_type');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_LCS');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_LCS',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_LCS');


END TL_BUILD_CACHE_FOR_LCS;

PROCEDURE Test_Mileage IS

l_location_tab FTE_DIST_INT_PKG.fte_dist_input_tab;
l_location_rec FTE_DIST_INT_PKG.fte_dist_input_rec;
l_location_log_tab FTE_DIST_INT_PKG.fte_dist_output_message_tab;

l_location_out_tab FTE_DIST_INT_PKG.fte_dist_output_tab;

l_return_message VARCHAR2(32767);

l_return_status VARCHAR2(1);


	l_warning_count 	NUMBER:=0;
BEGIN

	FOR i in 1..11
	LOOP
		l_location_tab(i):=l_location_rec;

	END LOOP;

	/*

	l_location_tab(1).origin_id:=207;
	l_location_tab(2).origin_id:=1091;
	l_location_tab(3).origin_id:=204;
	l_location_tab(4).origin_id:=1067;
	l_location_tab(5).origin_id:=1876;
	l_location_tab(6).origin_id:=207;
	l_location_tab(7).origin_id:=204;
	l_location_tab(8).origin_id:=204;
	l_location_tab(9).origin_id:=1067;
	l_location_tab(10).origin_id:=1876;
	l_location_tab(11).origin_id:=207;


	l_location_tab(1).destination_id:=1091;
	l_location_tab(2).destination_id:=204;
	l_location_tab(3).destination_id:=1067;
	l_location_tab(4).destination_id:=1876;
	l_location_tab(5).destination_id:=2881;
	l_location_tab(6).destination_id:=1091;
	l_location_tab(7).destination_id:=1067;
	l_location_tab(8).destination_id:=2881;
	l_location_tab(9).destination_id:=1876;
	l_location_tab(10).destination_id:=2881;
	l_location_tab(11).destination_id:=2881;
	*/

	l_location_tab(1).origin_id:=207;
	l_location_tab(2).origin_id:=1091;
	l_location_tab(3).origin_id:=204;
	l_location_tab(4).origin_id:=1067;
	l_location_tab(5).origin_id:=1876;
	l_location_tab(6).origin_id:=207;
	l_location_tab(7).origin_id:=204;
	l_location_tab(8).origin_id:=204;
	l_location_tab(9).origin_id:=1067;
	l_location_tab(10).origin_id:=1876;
	l_location_tab(11).origin_id:=207;


	l_location_tab(1).destination_id:=1091;
	l_location_tab(2).destination_id:=204;
	l_location_tab(3).destination_id:=1067;
	l_location_tab(4).destination_id:=1876;
	l_location_tab(5).destination_id:=2881;
	l_location_tab(6).destination_id:=1093;
	l_location_tab(7).destination_id:=1068;
	l_location_tab(8).destination_id:=2881;
	l_location_tab(9).destination_id:=1878;
	l_location_tab(10).destination_id:=2882;
	l_location_tab(11).destination_id:=2881;



 	FTE_DIST_INT_PKG.GET_DISTANCE_TIME(
	    p_distance_input_tab=> l_location_tab,
	    p_location_region_flag=> 'L',
	    p_messaging_yn => 'Y',
	    p_api_version  => '1',
	    p_command => NULL,
	    x_distance_output_tab=> l_location_out_tab,
	    x_distance_message_tab => l_location_log_tab,
	    x_return_message =>l_return_message,
	    x_return_status => l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	       	    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,' Interface to mileage tables failed, using approximate distances, time');
	       	    --l_mileage_api_fail:='Y';
		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_dist_time_fail;
	       END IF;
	END IF;

	 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Inputs');

	FOR i in l_location_tab.FIRST .. l_location_tab.LAST
	LOOP
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' MILEAGE distances, time:'||l_location_tab(i).origin_id || ' : '||
			l_location_tab(i).destination_id);

	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Outputs');

	FOR i in l_location_out_tab.FIRST .. l_location_out_tab.LAST
	LOOP
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' MILEAGE distances, time:'||l_location_out_tab(i).origin_location_id || ' : '||
			l_location_out_tab(i).destination_location_id||' : '||l_location_out_tab(i).distance||' : '||
			l_location_out_tab(i).distance_uom||' : '||l_location_out_tab(i).transit_time||' : '|| l_location_out_tab(i).transit_time_uom);

	END LOOP;

END;


PROCEDURE Get_Trip_Carrier(
	p_trip_id IN NUMBER,
	x_trip_rec IN OUT NOCOPY TL_trip_data_input_rec_type,
	x_carrier_rec IN OUT NOCOPY TL_CARRIER_PREF_REC_TYPE,
	x_return_status OUT NOCOPY VARCHAR2) IS



	CURSOR get_trip_info(c_trip_id IN NUMBER ) RETURN
	TL_trip_data_input_rec_type IS
	SELECT	t.trip_id,
		t.lane_id,
		null,
		t.service_level,
		t.carrier_id,
		t.mode_of_transport,
		t.vehicle_item_id,
		null,
		0,
		0,
		0,
		0,
		0,
		0,
		null, -- t.total_trip_distance,
		null, -- t.total_direct_distance,
		null,
		0,
		0,
		'N',
		null,
		null,
		null,
		null,
		null,
		null
	FROM  	wsh_trips t
	WHERE 	 t.trip_id=c_trip_id;

--Gets info from wsh_carriers

CURSOR get_carrier_pref(c_carrier_id IN NUMBER) RETURN TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		c.currency_code,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		c.weight_uom,
		null,
		c.volume_uom,
		null,
		c.distance_uom,
		null,
		c.time_uom,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIERS c
	WHERE 	c.carrier_id=c_carrier_id;


----

--Gets info from wsh_carrier_services

CURSOR get_carrier_service_pref(c_carrier_id IN NUMBER,c_service_level IN
VARCHAR2) RETURN TL_CARRIER_PREF_REC_TYPE IS
	SELECT	c.carrier_id,
		c.max_out_of_route,
		c.min_cm_distance,
		c.min_cm_time,
		c.cm_free_dh_mileage,
		c.cm_first_load_discount,
		null,
		c.cm_rate_variant,
		c.unit_rate_basis,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		c.origin_dstn_surcharge_level,
		c.distance_calculation_method,
		c.dim_dimensional_factor,
		c.dim_weight_uom,
		c.dim_volume_uom,
		c.dim_dimension_uom,
		c.dim_min_pack_vol
	FROM 	WSH_CARRIER_SERVICES c
	WHERE 	c.carrier_id=c_carrier_id and
		c.service_level=c_service_level;



	l_carrier_rec	TL_CARRIER_PREF_REC_TYPE;
	l_carrier_service_rec TL_CARRIER_PREF_REC_TYPE;

	l_return_status VARCHAR2(1);


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Trip_Carrier','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	OPEN get_trip_info(p_trip_id);
	FETCH get_trip_info INTO x_trip_rec;
	IF (get_trip_info%NOTFOUND)
	THEN

		CLOSE get_trip_info;

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail;

	END IF;
	CLOSE get_trip_info;

	--Get Carrier pref

	IF (x_trip_rec.carrier_id IS NULL)
	THEN

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_carrier_id;

	END IF;

	IF (x_trip_rec.service_type IS NOT NULL)
	THEN

		OPEN
		get_carrier_service_pref(
			x_trip_rec.carrier_id,
			x_trip_rec.service_type);

		FETCH get_carrier_service_pref INTO l_carrier_service_rec;
		IF (get_carrier_service_pref%NOTFOUND)
		THEN

			--No carrier_service_pref found, will have to use only carrier
			--pref
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No carrier Service entry found');

		END IF;
		CLOSE get_carrier_service_pref;
	END IF;

	OPEN  get_carrier_pref(x_trip_rec.carrier_id);
	FETCH get_carrier_pref INTO l_carrier_rec;
	IF (get_carrier_pref%NOTFOUND)
	THEN


		CLOSE get_carrier_pref;


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_carrier_pref_fail;


	END IF;
	CLOSE get_carrier_pref;




	Combine_Carrier_Info(
		p_carrier_pref_rec	=>	l_carrier_rec,
		x_carrier_service_pref_rec	=>	l_carrier_service_rec,
		x_return_status 	=> l_return_status);



	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	  		raise FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail;
	       END IF;
	END IF;



	x_carrier_rec:=l_carrier_service_rec;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Carrier');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Carrier',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trip_info_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Carrier');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_carrier_id THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Carrier',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_carrier_id');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Carrier');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_carrier_pref_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Carrier',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_carrier_pref_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Carrier');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_combine_carrier_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Carrier',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_combine_carrier_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Carrier');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Carrier',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Carrier');



END Get_Trip_Carrier;

PROCEDURE Get_Trip_Weight(
	p_trip_rec IN TL_trip_data_input_rec_type,
	p_carrier_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_weight OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS


CURSOR get_dlv_details(c_trip_id IN NUMBER) RETURN
FTE_FREIGHT_PRICING.shipment_line_rec_type IS
	SELECT	dd.delivery_detail_id,
		dl.delivery_id,
		dl.delivery_leg_id,
		dl.reprice_required,
		da.parent_delivery_detail_id,
		dd.customer_id,
		dd.sold_to_contact_id,
		dd.inventory_item_id,
		dd.item_description,
		dd.hazard_class_id,
		dd.country_of_origin,
		dd.classification,
		dd.requested_quantity,
		dd.requested_quantity_uom,
		dd.master_container_item_id,
		dd.detail_container_item_id,
		dd.customer_item_id,
		dd.net_weight,
		dd.organization_id,
		dd.container_flag,
		dd.container_type_code,
		dd.container_name,
		dd.fill_percent,
		dd.gross_weight,
		dd.currency_code,dd.freight_class_cat_id,
		dd.commodity_code_cat_id,
		dd.weight_uom_code ,
		dd.volume,
		dd.volume_uom_code,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,null,null,null,null,null,null,null,null,null,
		null,null,null,
		da.type,
		da.parent_delivery_id,
		dl.parent_delivery_leg_id
	FROM 	wsh_delivery_assignments da,
		wsh_delivery_legs dl ,
		wsh_delivery_details dd,
		wsh_trip_stops s
	WHERE 	da.delivery_id=dl.delivery_id and
		s.trip_id=c_trip_id and
		dl.pick_up_stop_id=s.stop_id and
		da.parent_delivery_detail_id is null and
		da.delivery_detail_id = dd.delivery_detail_id and
		((da.type IS NULL OR da.type='S')
		OR
		(da.type='O' and dl.parent_delivery_leg_id is null)
		)
	ORDER BY
		da.delivery_id;


	l_quantity NUMBER;
	l_dlv_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;

	l_return_status VARCHAR2(1);


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Trip_Weight','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_weight:=0;
	OPEN get_dlv_details(p_trip_rec.trip_id);
	FETCH get_dlv_details INTO l_dlv_detail_rec;
	WHILE (get_dlv_details%FOUND)
	LOOP
		l_quantity:=NULL;
		IF((l_dlv_detail_rec.weight_uom_code IS NOT NULL )
		 AND (l_dlv_detail_rec.gross_weight IS NOT NULL))
		THEN
			l_quantity:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				l_dlv_detail_rec.weight_uom_code,
				p_carrier_rec.weight_uom,
				l_dlv_detail_rec.gross_weight,
				0);

		END IF;

		IF (l_quantity IS NOT NULL)
		THEN
			x_weight:=x_weight+l_quantity;

		ELSE
			x_weight:=NULL;
			CLOSE get_dlv_details;
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_gross_weight;
		END IF;

		FETCH get_dlv_details INTO l_dlv_detail_rec;
	END LOOP;
	CLOSE get_dlv_details;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Weight');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dtl_no_gross_weight THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Weight',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dtl_no_gross_weight');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Weight');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Weight',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Weight');


END Get_Trip_Weight;

PROCEDURE Get_Trip_Distance(
	p_trip_rec IN TL_trip_data_input_rec_type,
	p_carrier_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_distance OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS


--Gets all the stops for a given trip ,ordered by sequence number

CURSOR get_stop_info(c_trip_id IN NUMBER) RETURN TL_trip_stop_input_rec_type IS
	SELECT 	s.stop_id ,
		s.trip_id,
		s.stop_location_id,
		NVL(s.wkday_layover_stops,0),
		NVL(s.wkend_layover_stops,0),
		null,
		null,
		0,
		0,
		0,
		0,
		null,
		0,
		0,
		0,
		0,
		null,
		null,
		s.planned_arrival_date,
		s.planned_departure_date,
		null,
		s.physical_stop_id,
		s.physical_location_id,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null
	FROM wsh_trip_stops s
	WHERE  s.trip_id=c_trip_id AND (s.physical_stop_id is NULL)
	ORDER by s.stop_sequence_number;


	l_carrier_index NUMBER;
	l_trip_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index NUMBER;
	l_child_dleg_index NUMBER;
	l_current_weight NUMBER;
	l_previous_weight NUMBER;
	l_stop_count NUMBER;
	l_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_stop_distance_tab TL_stop_distance_tab_type;
	l_trip_rec TL_trip_data_input_rec_type;
	l_initial_stop_index NUMBER;
	l_initial_dleg_index NUMBER;

	l_return_status VARCHAR2(1);


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Trip_Distance','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_distance:=NULL;

	l_trip_rec:=p_trip_rec;

	Delete_Cache(x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;


	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;

	l_initial_stop_index:=l_stop_index;
	l_initial_dleg_index:=l_dleg_index;

	l_current_weight:=0;
	l_previous_weight:=NULL;


	--Query all Stop for the trip

	l_stop_count:=0;
	OPEN get_stop_info(l_trip_rec.trip_id);
	FETCH get_stop_info INTO l_stop_rec;
	WHILE(get_stop_info%FOUND)
	LOOP

		--11.5.10+
		IF (l_stop_rec.physical_location_id IS NOT NULL)
		THEN
			l_stop_rec.location_id:=l_stop_rec.physical_location_id;
		END IF;

		--Prepare inputs for distance query
		IF (l_stop_count>0)
		THEN


			-- Create inputs for query to mileage tables


			Add_Inputs_For_Distance(
			 p_from_stop_rec=> g_tl_trip_stop_rows(l_stop_index-1),
			 p_to_stop_rec=> 	l_stop_rec,
			 p_empty_flag=>	'Y',
			 x_stop_distance_tab=>	l_stop_distance_tab,
			 x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

			       	  CLOSE get_stop_info;

			          raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail;
			       END IF;
			END IF;

		END IF;


		--Insert Stop info into Cache


		g_tl_trip_stop_rows(l_stop_index):=l_stop_rec;
		l_stop_index:=l_stop_index+1;
		l_stop_count:=l_stop_count+1;


		FETCH get_stop_info INTO l_stop_rec;

	END LOOP;
	CLOSE get_stop_info;

	--Set time,distance of last stop to 0

	g_tl_trip_stop_rows(l_stop_index-1).distance_to_next_stop:=0;
	g_tl_trip_stop_rows(l_stop_index-1).time_to_next_stop:=0;





	--GEt distances/time from mileage table, update, stop, dleg buffer, trip
	--loaded, unlaoded distances

	Get_Distances(
		p_stop_index	=>	l_initial_stop_index,
		p_dleg_index	=>	l_initial_dleg_index,
		p_carrier_rec	=>	p_carrier_rec,
		x_stop_distance_tab	=>l_stop_distance_tab,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
--			FTE_FREIGHT_PRICING_UTIL.setmsg (
--				p_api=>'Cache_Trip',
--				p_exc=>'g_tl_get_distances_fail',
--				p_trip_id=>x_trip_rec.trip_id);


          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail;
       		END IF;
	END IF;



	IF (p_carrier_rec.distance_calculation_method = 'DIRECT_ROUTE')
	THEN
		x_distance:=l_trip_rec.total_direct_distance;
	ELSE
		x_distance:=l_trip_rec.total_trip_distance;
	END IF;


	Delete_Cache(x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Distance');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Distance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Distance');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Distance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Distance');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Distance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_ip_dist_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Distance');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Distance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_distances_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Distance');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Trip_Distance',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Trip_Distance');


END Get_Trip_Distance;

PROCEDURE FPA_Get_Trip_Info(
    p_trip_id IN NUMBER,
    x_distance OUT NOCOPY NUMBER,
    x_distance_uom OUT NOCOPY VARCHAR2,
    x_weight OUT NOCOPY VARCHAR2,
    x_weight_uom OUT NOCOPY VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2) IS

	l_trip_rec TL_trip_data_input_rec_type;
	l_carrier_rec TL_CARRIER_PREF_REC_TYPE;

	l_return_status VARCHAR2(1);


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'FPA_Get_Trip_Info','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FPA_Trip_Info for trip'||p_trip_id);
	x_distance:=NULL;
	x_distance_uom:=NULL;
	x_weight:=NULL;
	x_weight_uom:=NULL;

	Get_Trip_Carrier(
		p_trip_id=>p_trip_id,
		x_trip_rec=>l_trip_rec,
		x_carrier_rec=>l_carrier_rec,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail;
	       END IF;
	END IF;

	x_distance_uom:=l_carrier_rec.distance_uom;
	x_weight_uom:=l_carrier_rec.weight_uom;
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FPA_Trip_Info Distance method:'
		||l_carrier_rec.distance_calculation_method);

	Get_Trip_Distance(
		p_trip_rec=>l_trip_rec,
		p_carrier_rec=>l_carrier_rec,
		x_distance=>x_distance,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	        x_distance:=NULL;
	        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FPA_Trip_Info Distance errored');
          	--raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_total_trp_distance;
	       END IF;
	END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FPA_Trip_Info Distance'||x_distance||':'||
		x_distance_uom);
	Get_Trip_Weight(
		p_trip_rec=>l_trip_rec,
		p_carrier_rec=>l_carrier_rec,
		x_weight=>x_weight,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	       	x_weight:=NULL;
	        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FPA_Trip_Info Weight errored');
          	--raise FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_weight;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'FPA_Trip_Info Weight'||x_weight||':'||
		x_weight_uom);


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_Get_Trip_Info');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;



EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trip_info_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('FPA_Get_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trip_info_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_Get_Trip_Info');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_total_trp_distance THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('FPA_Get_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_total_trp_distance');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_Get_Trip_Info');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_trp_no_weight THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('FPA_Get_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_trp_no_weight');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_Get_Trip_Info');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('FPA_Get_Trip_Info',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'FPA_Get_Trip_Info');

END FPA_Get_Trip_Info;


PROCEDURE Get_Transit_Time_From_Distance(
	p_distance IN NUMBER,
	p_distance_uom IN VARCHAR2,
	p_time_uom IN VARCHAR2,
	x_time IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

  CURSOR c_get_speed IS
  SELECT avg_hway_speed
  FROM wsh_global_parameters;

  CURSOR c_get_distance_uom IS
  SELECT distance_uom
  FROM wsh_global_parameters;

  CURSOR c_get_time_uom IS
  SELECT time_uom
  FROM wsh_global_parameters;

l_average_speed_value NUMBER;
l_speed_distance_uom VARCHAR2(30);
l_speed_time_uom VARCHAR2(30);
l_time NUMBER;


BEGIN

	  x_time:=NULL;


	  OPEN c_get_speed;
	  FETCH c_get_speed INTO l_average_speed_value;
	  CLOSE c_get_speed;
	  OPEN c_get_distance_uom;
	  FETCH c_get_distance_uom INTO l_speed_distance_uom;
	  CLOSE c_get_distance_uom;
	  OPEN c_get_time_uom;
	  FETCH c_get_time_uom INTO l_speed_time_uom;
	  CLOSE c_get_time_uom;

	  IF ((l_average_speed_value IS NOT NULL)
	  	AND (l_speed_distance_uom IS NOT NULL) AND (l_speed_time_uom IS NOT NULL)
	  	AND (p_distance_uom IS NOT NULL) AND (p_time_uom IS NOT NULL))
	  THEN


		l_average_speed_value:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			l_speed_distance_uom,
			p_distance_uom,
			l_average_speed_value,
			0);
		IF ((l_average_speed_value IS NOT NULL) AND (l_average_speed_value <> 0))
		THEN
			l_time:=p_distance/l_average_speed_value;

			x_time:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			l_speed_time_uom,
			p_time_uom,
			l_time,
			0);

		END IF;

	  END IF;

END Get_Transit_Time_From_Distance;


PROCEDURE TL_Cache_First_Estimate_Trip(
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	p_ship_date IN DATE,
	p_delivery_date IN DATE,
	p_vehicle_type IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_weight IN NUMBER,
	p_weight_uom IN VARCHAR2,
	p_volume IN NUMBER,
	p_volume_uom IN VARCHAR2,
	p_distance IN NUMBER,
	p_distance_uom in VARCHAR2,
	x_trip_index IN OUT NOCOPY NUMBER,
	x_carrier_index IN OUT NOCOPY NUMBER,
	x_stop_index IN OUT NOCOPY NUMBER,
	x_dleg_index IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2,
    --Bug 6625274
    p_origin_id IN NUMBER DEFAULT NULL,
    p_destination_id IN NUMBER DEFAULT NULL) IS


	CURSOR get_lane_info(c_lane_id IN NUMBER) IS
	SELECT	null,
		l.carrier_id,
		l.service_type_code,
		l.mode_of_transportation_code
	FROM fte_lanes l
	WHERE l.lane_id=c_lane_id;

	CURSOR get_schedule_info(c_schedule_id IN NUMBER) IS
	SELECT  l.lane_id,
	  	null,
	  	l.carrier_id,
	  	l.service_type_code,
	  	l.mode_of_transportation_code
	FROM 	fte_lanes l,
		fte_schedules s
	WHERE 	s.schedules_id=c_schedule_id and
		s.lane_id=l.lane_id;



	l_trip_rec  TL_trip_data_input_rec_type;
	l_carrier_rec TL_CARRIER_PREF_REC_TYPE;
	l_pickup_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_dropoff_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;

	l_dleg_rec TL_delivery_leg_rec_type;
	l_dlv_detail_info FTE_FREIGHT_PRICING.shipment_line_rec_type;

	l_initial_stop_index NUMBER;
	l_initial_dleg_index NUMBER;
	l_stop_distance_tab TL_stop_distance_tab_type;

	l_return_status VARCHAR2(1);
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
	l_warning_count 	NUMBER:=0;

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Cache_First_Estimate_Trip','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	--Store initial index values

	l_initial_stop_index:=x_stop_index;
	l_initial_dleg_index:=x_dleg_index;


	IF (p_lane_id IS NOT NULL)
	THEN
		Get_Carrier_Pref_For_Lane(
			p_lane_id =>p_lane_id,
			x_carrier_service_rec=>l_carrier_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail;
			END IF;
		END IF;
	ELSIF (p_schedule_id IS NOT NULL)
	THEN
		Get_Carrier_Pref_For_Schedule(
			p_schedule_id =>p_schedule_id,
			x_carrier_service_rec=>l_carrier_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail;
			END IF;
		END IF;


	END IF;

	IF (l_carrier_rec.cm_rate_variant IS NULL)
	THEN
	--Verify exact code
	--this is done so that the carrier can be validated for freight estimate
	--even if the carrier does not have cm_rate_variant
		l_carrier_rec.cm_rate_variant:='DISCOUNT';
	END IF;


	--MULTICURRENCY
	TL_Get_Currency(
		p_delivery_id=>NULL,
		p_trip_id=>NULL,
		p_location_id=>p_pickup_location_id,
		p_carrier_id=>l_carrier_rec.carrier_id,
		x_currency_code=>l_carrier_rec.currency,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
	       END IF;
	END IF;


	Validate_Carrier_Info(
		x_carrier_info 	=>	l_carrier_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_Cache_First_Estimate_Trip',
			--	p_exc=>'g_tl_validate_carrier_fail',
			--	p_carrier_id=>l_carrier_rec.carrier_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail;
		END IF;
	END IF;

	--Insert carrier info into cache
	g_tl_carrier_pref_rows(x_carrier_index):=l_carrier_rec;
	x_carrier_index:=x_carrier_index+1;



	l_trip_rec.trip_id:=FAKE_TRIP_ID;



	IF (p_schedule_id IS NOT NULL)
	THEN
		l_trip_rec.schedule_id:=p_schedule_id;
		OPEN get_schedule_info(p_schedule_id);
		FETCH get_schedule_info INTO
		l_trip_rec.lane_id,l_trip_rec.price_list_id,
		l_trip_rec.carrier_id,l_trip_rec.service_type,
		l_trip_rec.mode_of_transport;

		IF (get_schedule_info%NOTFOUND)
		THEN
			CLOSE get_schedule_info;

			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_Cache_First_Estimate_Trip',
			--	p_exc=>'g_tl_get_schedule_info_fail',
			--	p_schedule_id=>p_schedule_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_schedule_info_fail;


		END IF;
		CLOSE get_schedule_info;



	ELSIF (p_lane_id IS NOT NULL)
	THEN
		l_trip_rec.lane_id:=p_lane_id;
		OPEN get_lane_info(p_lane_id);
		FETCH get_lane_info INTO
		l_trip_rec.price_list_id,l_trip_rec.carrier_id,
		l_trip_rec.service_type,l_trip_rec.mode_of_transport;

		IF (get_lane_info%NOTFOUND)
		THEN
			CLOSE get_lane_info;

			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_Cache_First_Estimate_Trip',
			--	p_exc=>'g_tl_get_lane_info_fail',
			--	p_lane_id=>p_lane_id);

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_lane_info_fail;

		END IF;
		CLOSE get_lane_info;


	END IF;





	l_trip_rec.vehicle_type:=p_vehicle_type;




	Get_Pricelist_Id(
		p_lane_id=>p_lane_id,
		p_departure_date=>p_ship_date,
		p_arrival_date=>p_delivery_date,
		x_pricelist_id=>l_trip_rec.price_list_id,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

--			FTE_FREIGHT_PRICING_UTIL.setmsg (
--				p_api=>'TL_Cache_First_Estimate_Trip',
--				p_exc=>'g_tl_get_pricelistid_fail',
--				p_trip_id=>l_trip_rec.trip_id,
--				p_lane_id=>l_trip_rec.lane_id);

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_pricelistid_fail;
	       END IF;
	END IF;


	l_trip_rec.unloaded_distance:=0;
	IF (p_distance IS NOT NULL)
	THEN
		l_trip_rec.loaded_distance:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_distance_uom,
			l_carrier_rec.distance_uom,
			p_distance,
			0);

	ELSE
		l_trip_rec.loaded_distance:=NULL;
	END IF;


	l_trip_rec.number_of_pallets:=0;
	l_trip_rec.number_of_containers:=1;
	l_trip_rec.time:=0;
	l_trip_rec.number_of_stops:=2;
	l_trip_rec.total_trip_distance:=l_trip_rec.loaded_distance;
	l_trip_rec.total_direct_distance:=l_trip_rec.loaded_distance;
	l_trip_rec.distance_method:=l_carrier_rec.distance_calculation_method;

	IF ((l_carrier_rec.weight_uom IS NOT NULL) AND (p_weight_uom IS NOT NULL))
	THEN
		l_trip_rec.total_weight:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_weight_uom,
			l_carrier_rec.weight_uom,
			p_weight,
			0);
	END IF;
	IF (l_trip_rec.total_weight IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail;
	END IF;


	IF ((l_carrier_rec.volume_uom IS NOT NULL) AND (p_volume_uom IS NOT NULL))
	THEN
		l_trip_rec.total_volume:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
			p_volume_uom,
			l_carrier_rec.volume_uom,
			p_volume,
			0);

	END IF;
	IF (l_trip_rec.total_volume IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail;
	END IF;


	l_trip_rec.continuous_move:='N';
	l_trip_rec.planned_departure_date:=p_ship_date;


	--In case delivery date is not passed in ,
	--use ship date as the delivery date
	IF (p_delivery_date IS NOT NULL)
	THEN
		l_trip_rec.planned_arrival_date:=p_delivery_date;
	ELSE
		l_trip_rec.planned_arrival_date:=p_ship_date;
	END IF;


	l_trip_rec.dead_head:='N';
	l_trip_rec.stop_reference:=x_stop_index;

	l_trip_rec.delivery_leg_reference:=x_dleg_index;



	l_pickup_stop_rec.stop_id:=FAKE_STOP_ID_1;
	l_pickup_stop_rec.trip_id:=l_trip_rec.trip_id;
	l_pickup_stop_rec.stop_region:=NULL;
	IF (p_pickup_location_id IS NOT NULL)
	THEN
		l_pickup_stop_rec.location_id:=p_pickup_location_id;

		Get_Region_For_Location(
			p_location_id=>	l_pickup_stop_rec.location_id,
			p_region_type=>	l_carrier_rec.region_level,
			x_region_id=>	l_pickup_stop_rec.stop_region,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
			  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
		       END IF;
		END IF;

	ELSE
		l_pickup_stop_rec.location_id:=FAKE_STOP_ID_1;
         --Bug 6625274
        l_pickup_stop_rec.stop_region := p_origin_id;

	END IF;
	l_pickup_stop_rec.weekday_layovers:=0;
	l_pickup_stop_rec.weekend_layovers:=0;
	l_pickup_stop_rec.distance_to_next_stop:=0;
	l_pickup_stop_rec.time_to_next_stop:=0;
	l_pickup_stop_rec.pickup_weight:=l_trip_rec.total_weight;
	l_pickup_stop_rec.pickup_volume:=l_trip_rec.total_volume;
	l_pickup_stop_rec.pickup_pallets:=0;
	l_pickup_stop_rec.pickup_containers:=1;
	l_pickup_stop_rec.loading_protocol:=NULL;
	l_pickup_stop_rec.dropoff_weight:=0;
	l_pickup_stop_rec.dropoff_volume:=0;
	l_pickup_stop_rec.dropoff_pallets:=0;
	l_pickup_stop_rec.dropoff_containers:=0;

	l_pickup_stop_rec.stop_zone:=NULL;
	l_pickup_stop_rec.planned_arrival_date:=l_trip_rec.planned_departure_date;
	l_pickup_stop_rec.planned_departure_date:=l_trip_rec.planned_departure_date;
	l_pickup_stop_rec.stop_type:='PU';



	l_dropoff_stop_rec.stop_id:=FAKE_STOP_ID_2;
	l_dropoff_stop_rec.trip_id:=l_trip_rec.trip_id;
	l_dropoff_stop_rec.stop_region:=NULL;

	IF (p_dropoff_location_id IS NOT NULL)
	THEN
		l_dropoff_stop_rec.location_id:=p_dropoff_location_id;

		Get_Region_For_Location(
			p_location_id=>	l_dropoff_stop_rec.location_id,
			p_region_type=>	l_carrier_rec.region_level,
			x_region_id=>	l_dropoff_stop_rec.stop_region,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
			  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
		       END IF;
		END IF;

	ELSE
		l_dropoff_stop_rec.location_id:=FAKE_LOCATION_ID_2;
        --Bug 6625274
        l_dropoff_stop_rec.stop_region:=p_destination_id;

	END IF;
	l_dropoff_stop_rec.weekday_layovers:=0;
	l_dropoff_stop_rec.weekend_layovers:=0;
	l_dropoff_stop_rec.distance_to_next_stop:=0;
	l_dropoff_stop_rec.time_to_next_stop:=0;
	l_dropoff_stop_rec.pickup_weight:=0;
	l_dropoff_stop_rec.pickup_volume:=0;
	l_dropoff_stop_rec.pickup_pallets:=0;
	l_dropoff_stop_rec.pickup_containers:=0;
	l_dropoff_stop_rec.loading_protocol:=NULL;
	l_dropoff_stop_rec.dropoff_weight:=l_trip_rec.total_weight;
	l_dropoff_stop_rec.dropoff_volume:=l_trip_rec.total_volume;
	l_dropoff_stop_rec.dropoff_pallets:=0;
	l_dropoff_stop_rec.dropoff_containers:=1;

	l_dropoff_stop_rec.stop_zone:=NULL;
	l_dropoff_stop_rec.planned_arrival_date:=l_trip_rec.planned_arrival_date;
	l_dropoff_stop_rec.planned_departure_date:=l_trip_rec.planned_arrival_date;
	l_dropoff_stop_rec.stop_type:='DO';



	Add_Inputs_For_Distance(
		p_from_stop_rec=>l_pickup_stop_rec,
		p_to_stop_rec=>l_dropoff_stop_rec,
		p_empty_flag=>'N',
		x_stop_distance_tab=>l_stop_distance_tab,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail;
	       END IF;
	END IF;


	--Create Dummy DLEG

	Initialize_Dummy_Dleg(
		p_pickup_location	=>l_pickup_stop_rec.location_id,
		p_dropoff_location	=>l_dropoff_stop_rec.location_id,
		p_dlv_id	=>FAKE_DLEG_ID,
		x_dleg_rec	=>l_dleg_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail;
	       END IF;
	END IF;




	Update_Dummy_Records(
		p_weight_uom	=>l_carrier_rec.weight_uom ,
		p_volume_uom	=>l_carrier_rec.volume_uom,
		p_weight	=>l_trip_rec.total_weight,
		p_volume	=>l_trip_rec.total_volume,
		p_containers	=>l_trip_rec.number_of_containers,
		p_pallets	=>l_trip_rec.number_of_pallets,
		x_carrier_rec	=>l_carrier_rec,
		x_trip_rec	=>l_trip_rec,
		x_pickup_stop	=>l_pickup_stop_rec,
		x_dropoff_stop	=>l_dropoff_stop_rec,
		x_dleg	=>l_dleg_rec,
		x_return_status	=>l_return_status
		);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_dummy_recs_fail;
	       END IF;
	END IF;


	--Insert pickup stop
	g_tl_trip_stop_rows(x_stop_index):=l_pickup_stop_rec;
	x_stop_index:=x_stop_index+1;

	--Insert dropoff stop
	g_tl_trip_stop_rows(x_stop_index):=l_dropoff_stop_rec;
	x_stop_index:=x_stop_index+1;



	--Insert dleg

	Validate_Dleg_Info(
		x_dleg_info=>	l_dleg_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail;
	       END IF;
	END IF;

	g_tl_delivery_leg_rows(x_dleg_index):=l_dleg_rec;
	x_dleg_index:=x_dleg_index+1;



	Initialize_Single_Dummy_Detail(
		p_weight=>l_trip_rec.total_weight,
		p_weight_uom=>l_carrier_rec.weight_uom,
		p_volume=>l_trip_rec.total_volume,
		p_volume_uom=>l_carrier_rec.volume_uom,
		x_dlv_detail_info=>l_dlv_detail_info,
		x_return_status=>l_return_status);

	Insert_Into_Dlv_Dtl_Cache(
		p_dlv_dtl_rec=>l_dlv_detail_info,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail;
	       END IF;
	END IF;



	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'BEFORE FAC CALL');
	--Get facility Info and store into stop cache
	Get_Facility_Info(p_stop_index	=>	l_initial_stop_index,
			x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get facility information');
	          --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'AFTER FAC CALL');

	IF (l_trip_rec.loaded_distance IS NULL)
	THEN

		Get_Distances(
			p_stop_index	=>	l_initial_stop_index,
			p_dleg_index	=>	l_initial_dleg_index,
			p_carrier_rec	=>	l_carrier_rec,
			x_stop_distance_tab	=>l_stop_distance_tab,
			x_trip_rec	=>	l_trip_rec,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
	--			FTE_FREIGHT_PRICING_UTIL.setmsg (
	--				p_api=>'Cache_Trip',
	--				p_exc=>'g_tl_get_distances_fail',
	--				p_trip_id=>x_trip_rec.trip_id);


				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail;
			END IF;
		END IF;
	ELSE
		Get_Transit_Time_From_Distance(
			p_distance=> l_trip_rec.loaded_distance,
			p_distance_uom=> l_carrier_rec.distance_uom,
			p_time_uom=> l_carrier_rec.time_uom,
			x_time=>l_trip_rec.time,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN

				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail;
			END IF;
		END IF;

		g_tl_trip_stop_rows(l_initial_stop_index).distance_to_next_stop:=l_trip_rec.loaded_distance;
		g_tl_trip_stop_rows(l_initial_stop_index).time_to_next_stop:=l_trip_rec.time;

	END IF;


	--Insert into trip cache

	Validate_Trip_Info(
		x_trip_info=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		--FTE_FREIGHT_PRICING_UTIL.setmsg (
		--	p_api=>'Cache_Trip',
		--	p_exc=>'g_tl_validate_trip_fail',
		--	p_trip_id=>l_trip_rec.trip_id);

	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail;
	       END IF;
	END IF;

	g_tl_trip_rows(x_trip_index):=l_trip_rec;
	x_trip_index:=x_trip_index+1;


	FOR i IN l_initial_stop_index..(x_stop_index-1)
	LOOP
		--Determine if the stop is pickup/dropoff/both or none
		Get_Stop_Type(x_stop_rec=>g_tl_trip_stop_rows(i));

		Validate_Stop_Info(
		p_carrier_pref_rec=>l_carrier_rec,
		x_stop_info=>	g_tl_trip_stop_rows(i),
		x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN

			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Cache_Trip',
			--	p_exc=>'g_tl_validate_stop_fail',
			--	p_stop_id=>g_tl_trip_stop_rows(i).stop_id);

			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail;
		       END IF;
		END IF;

	END LOOP;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');

EXCEPTION



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_insert_dlv_dtl_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_dleg_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dleg_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_updt_dummy_recs_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_updt_dummy_recs_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_currency_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_ip_dist_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_stop_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_trip_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_distances_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_vol_uom_conv_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_vol_uom_conv_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_weight_uom_conv_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_weight_uom_conv_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_pricelistid_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_pricelistid_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_lane_info_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_lane_info_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_schedule_info_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_schedule_info_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');




   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_carrier_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_schd_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_lane_fail');
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_Estimate_Trip',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_Estimate_Trip');



END TL_Cache_First_Estimate_Trip;



PROCEDURE TL_BUILD_CACHE_FOR_ESTIMATE(
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
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
	x_return_status OUT NOCOPY Varchar2,
     --Bug 6625274
    p_origin_id IN NUMBER DEFAULT NULL,
    p_destination_id IN NUMBER DEFAULT NULL) IS




	l_trip_index NUMBER;
	l_carrier_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index	NUMBER;
	l_child_dleg_index	NUMBER;

	l_last_trip_index 	NUMBER;
	l_last_carrier_index 	NUMBER;
	l_last_stop_index 	NUMBER;
	l_last_dleg_index	NUMBER;


	i NUMBER;
	j NUMBER;

	l_cached_first_trip_flag VARCHAR2(1);


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;


	l_cached_first_trip_flag:='N';
	i:=p_lane_rows.FIRST;

	-- Query up the trip/stops/dleg and cache it
	WHILE (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND
	p_vehicle_rows.EXISTS(i) AND (l_cached_first_trip_flag='N'))
	LOOP



		TL_Cache_First_Estimate_Trip(
		p_pickup_location_id=>p_pickup_location_id,
		p_dropoff_location_id=>p_dropoff_location_id,
		p_ship_date=>p_ship_date,
		p_delivery_date=>p_delivery_date,
		p_vehicle_type=>p_vehicle_rows(i),
		p_lane_id=>p_lane_rows(i),
		p_schedule_id=>p_schedule_rows(i),
		p_weight=>p_weight,
		p_weight_uom=>p_weight_uom,
		p_volume=>p_volume,
		p_volume_uom=>p_volume_uom,
		p_distance=>p_distance,
		p_distance_uom=>p_distance_uom,
		x_trip_index=>l_trip_index,
		x_carrier_index=>l_carrier_index,
		x_stop_index=>l_stop_index,
		x_dleg_index=>l_dleg_index,
		x_return_status=>l_return_status,
         --Bug 6625274
        p_origin_id => p_origin_id,
        p_destination_id => p_destination_id);


		  l_cached_first_trip_flag:='Y';

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		  THEN
		         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		         THEN

		         	Delete_Cache(x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
				       END IF;
				END IF;

				Initialize_Cache_Indices(
					x_trip_index=>	l_trip_index,
					x_stop_index=>	l_stop_index,
					x_dleg_index=>	l_dleg_index,
					x_carrier_index=>l_carrier_index,
					x_child_dleg_index=>l_child_dleg_index,
					x_return_status=> l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
				       END IF;
				END IF;

				l_cached_first_trip_flag:='N';
		         END IF;
		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

	IF (l_cached_first_trip_flag='N')
	THEN


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached;

	END IF;

	--The first lane/schedule has been cached
	--For the remaining lanes/schedules we shall copy the data we captured above
	--and alter the UOMs according to the lanes




	--Alter and copy into cache for each lane



	WHILE ( (i IS NOT NULL) AND (p_lane_rows.EXISTS(i)))
	LOOP

		IF (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND p_vehicle_rows.EXISTS(i)
			AND ((p_lane_rows(i) IS NOT NULL) OR (p_schedule_rows(i) IS NOT NULL) ))
		THEN

			--Store all the indices

			l_last_trip_index:=l_trip_index;
			l_last_carrier_index:=l_carrier_index;
			l_last_stop_index:=l_stop_index;
			l_last_dleg_index:=l_dleg_index;



			Cache_Next_Trip_Lane(
				p_trip_id=>FAKE_TRIP_ID,
				p_lane_id=> p_lane_rows(i),
				p_schedule_id=> p_schedule_rows(i),
				p_vehicle=> p_vehicle_rows(i) ,
				x_trip_index => l_trip_index,
				x_carrier_index=>l_carrier_index,
				x_stop_index=>l_stop_index,
				x_dleg_index=>l_dleg_index,
				x_child_dleg_index=>l_child_dleg_index,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				   l_warning_count:=l_warning_count+1;
			       	   IF (p_schedule_rows(i) IS NOT NULL)
			       	   THEN

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache trip'
			       	   	   ||' schedule '||p_schedule_rows(i)||':g_tl_cmp_trip_sched_fail');

				    ELSE

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache trip'
			       	   	   ||' lane '||p_lane_rows(i)||':g_tl_cmp_trip_lane_fail');



				    END IF;

				--Restore indices

				l_trip_index:=l_last_trip_index;
				l_carrier_index:=l_last_carrier_index;
				l_stop_index:=l_last_stop_index;
				l_dleg_index:=l_last_dleg_index;


				--DELETE Newly added cache

				Partially_Delete_Cache(
					p_trip_index=>l_trip_index,
					p_carrier_index=>l_carrier_index,
					p_stop_index=>l_stop_index,
					p_dleg_index=>l_dleg_index,
					p_child_dleg_index=>l_child_dleg_index);

			       END IF;
			END IF;




		ELSE


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh;

		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_trips_cached');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_first_trp_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_first_trp_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_lane_sched_veh');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_ESTIMATE',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_ESTIMATE');


END TL_BUILD_CACHE_FOR_ESTIMATE;


PROCEDURE Copy_Source_Line_To_Detail(
	p_source_lines_rec IN FTE_PROCESS_REQUESTS.fte_source_line_rec,
	x_dlv_dtl_rec IN OUT NOCOPY FTE_FREIGHT_PRICING.shipment_line_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2)
IS

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Copy_Source_Line_To_Detail','start');

      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


      x_dlv_dtl_rec.delivery_detail_id  	:= p_source_lines_rec.source_line_id;
      x_dlv_dtl_rec.delivery_id         	:= p_source_lines_rec.consolidation_id;


      x_dlv_dtl_rec.delivery_leg_id     	:= p_source_lines_rec.consolidation_id;


      x_dlv_dtl_rec.reprice_required    	:= 'Y';
      x_dlv_dtl_rec.parent_delivery_detail_id	:= NULL;
      x_dlv_dtl_rec.customer_id         	:= p_source_lines_rec.customer_id;
      x_dlv_dtl_rec.sold_to_contact_id  	:= NULL;
      x_dlv_dtl_rec.inventory_item_id   	:= p_source_lines_rec.inventory_item_id;
      x_dlv_dtl_rec.item_description    	:= NULL;
      x_dlv_dtl_rec.hazard_class_id     	:= NULL;
      x_dlv_dtl_rec.country_of_origin   	:= NULL;
      x_dlv_dtl_rec.classification     	 	:= NULL;
      x_dlv_dtl_rec.requested_quantity  	:= p_source_lines_rec.source_quantity;
      x_dlv_dtl_rec.requested_quantity_uom   	:= p_source_lines_rec.source_quantity_uom;
      x_dlv_dtl_rec.master_container_item_id    := NULL;
      x_dlv_dtl_rec.detail_container_item_id    := NULL;
      x_dlv_dtl_rec.customer_item_id            := NULL;
      x_dlv_dtl_rec.net_weight                  := p_source_lines_rec.weight;
      x_dlv_dtl_rec.organization_id             := p_source_lines_rec.ship_from_org_id;
      x_dlv_dtl_rec.container_flag              := 'N';
      x_dlv_dtl_rec.container_type_code         := NULL;
      x_dlv_dtl_rec.container_name              := NULL;
      x_dlv_dtl_rec.fill_percent                := NULL;
      x_dlv_dtl_rec.gross_weight                := p_source_lines_rec.weight;
      x_dlv_dtl_rec.currency_code               := p_source_lines_rec.freight_rate_currency;
      x_dlv_dtl_rec.freight_class_cat_id        := NULL;
      x_dlv_dtl_rec.commodity_code_cat_id       := NULL;
      x_dlv_dtl_rec.weight_uom_code             := p_source_lines_rec.weight_uom_code;
      x_dlv_dtl_rec.volume                      := p_source_lines_rec.volume;
      x_dlv_dtl_rec.volume_uom_code             := p_source_lines_rec.volume_uom_code;
      x_dlv_dtl_rec.tp_attribute_category       := NULL;
      x_dlv_dtl_rec.tp_attribute1               := NULL;
      x_dlv_dtl_rec.tp_attribute2               := NULL;
      x_dlv_dtl_rec.tp_attribute3               := NULL;
      x_dlv_dtl_rec.tp_attribute4               := NULL;
      x_dlv_dtl_rec.tp_attribute5               := NULL;
      x_dlv_dtl_rec.tp_attribute6               := NULL;
      x_dlv_dtl_rec.tp_attribute7               := NULL;
      x_dlv_dtl_rec.tp_attribute8               := NULL;
      x_dlv_dtl_rec.tp_attribute9               := NULL;
      x_dlv_dtl_rec.tp_attribute10              := NULL;
      x_dlv_dtl_rec.tp_attribute11              := NULL;
      x_dlv_dtl_rec.tp_attribute12              := NULL;
      x_dlv_dtl_rec.tp_attribute13              := NULL;
      x_dlv_dtl_rec.tp_attribute14              := NULL;
      x_dlv_dtl_rec.tp_attribute15              := NULL;
      x_dlv_dtl_rec.attribute_category          := NULL;
      x_dlv_dtl_rec.attribute1                  := NULL;
      x_dlv_dtl_rec.attribute2                  := NULL;
      x_dlv_dtl_rec.attribute3                  := NULL;
      x_dlv_dtl_rec.attribute4                  := NULL;
      x_dlv_dtl_rec.attribute5                  := NULL;
      x_dlv_dtl_rec.attribute6                  := NULL;
      x_dlv_dtl_rec.attribute7                  := NULL;
      x_dlv_dtl_rec.attribute8                  := NULL;
      x_dlv_dtl_rec.attribute9                  := NULL;
      x_dlv_dtl_rec.attribute10                 := NULL;
      x_dlv_dtl_rec.attribute11                 := NULL;
      x_dlv_dtl_rec.attribute12                 := NULL;
      x_dlv_dtl_rec.attribute13                 := NULL;
      x_dlv_dtl_rec.attribute14                 := NULL;
      x_dlv_dtl_rec.attribute15                 := NULL;
      x_dlv_dtl_rec.source_type                 := p_source_lines_rec.source_type;
      x_dlv_dtl_rec.source_line_id              := p_source_lines_rec.source_line_id;
      x_dlv_dtl_rec.source_header_id            := p_source_lines_rec.source_header_id;
      x_dlv_dtl_rec.source_consolidation_id     := p_source_lines_rec.consolidation_id;
      x_dlv_dtl_rec.ship_date                   := p_source_lines_rec.ship_date;
      x_dlv_dtl_rec.arrival_date                := p_source_lines_rec.arrival_date;
      -- FTE J rate estimate
      x_dlv_dtl_rec.comm_category_id            := p_source_lines_rec.commodity_category_id;


      FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Copy_Source_Line_To_Detail');

      IF (l_warning_count > 0)
      THEN
	x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
      END IF;

EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Copy_Source_Line_To_Detail',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Copy_Source_Line_To_Detail');


END Copy_Source_Line_To_Detail;



PROCEDURE Add_Source_Lines_As_Details(
	p_consolidation_id IN NUMBER,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	x_pickup_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dropoff_stop_rec IN OUT NOCOPY TL_TRIP_STOP_INPUT_REC_TYPE,
	x_dleg_rec IN OUT NOCOPY TL_delivery_leg_rec_type,
	x_return_status	OUT	NOCOPY	VARCHAR2)
IS


l_dlv_detail_rec FTE_FREIGHT_PRICING.shipment_line_rec_type;


l_dleg_tab TL_dleg_quantity_tab_type;
i NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Add_Source_Lines_As_Details','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	i:=p_source_lines_tab.FIRST;
	WHILE (i IS NOT NULL)
	LOOP
		IF((p_source_lines_tab(i).consolidation_id IS NOT NULL)
		AND (p_source_lines_tab(i).consolidation_id=p_consolidation_id)
		AND (nvl(p_source_lines_tab(i).freight_rating_flag,'Y') = 'Y'))
		THEN

			Copy_Source_Line_To_Detail(p_source_lines_rec=>p_source_lines_tab(i),
				x_dlv_dtl_rec=>l_dlv_detail_rec,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_copy_src_dtl_fail;
			       END IF;
			END IF;



			Validate_Dlv_Detail_Info(
				p_carrier_pref_rec =>p_carrier_pref_rec,
				x_dlv_detail_info	=>l_dlv_detail_rec,
				x_return_status		=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail;
			       END IF;
			END IF;

			--Insert into delivery detail cache

			Add_Dropoff_Quantity(
				p_dlv_detail_rec    =>l_dlv_detail_rec,
				p_carrier_pref  =>p_carrier_pref_rec,
				x_stop_rec	    =>x_dropoff_stop_rec,
				x_return_status	=>	l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_dropoff_qty_fail;
			       END IF;
			END IF;


			--Adds picked up quantities to l_stop_rec
			Add_Pickup_Quantity(
				p_dlv_detail_rec=>	l_dlv_detail_rec,
				p_carrier_pref=>	p_carrier_pref_rec,
				x_stop_rec=>	x_pickup_stop_rec,
				x_dleg_quantity_tab=>	l_dleg_tab,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN

				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_pickup_qty_fail;

			       END IF;
			END IF;



			--Insert into dlv details cache
			Insert_Into_Dlv_Dtl_Cache(
				p_dlv_dtl_rec=>l_dlv_detail_rec,
				x_return_status	=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail;
			       END IF;
			END IF;
		END IF;

		i:=p_source_lines_tab.NEXT(i);
	END LOOP;

	IF (l_dleg_tab.EXISTS(x_dleg_rec.delivery_leg_id))
	THEN
	 x_dleg_rec.weight:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).weight;
	 x_dleg_rec.volume:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).volume;
	 x_dleg_rec.pallets:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).pallets;
	 x_dleg_rec.containers:=
	  l_dleg_tab(x_dleg_rec.delivery_leg_id).containers;
	END IF;




	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'ADDDELIVERY DETAILS w:'||x_dleg_rec.weight ||' v:'|| x_dleg_rec.volume||' conta:'|| x_dleg_rec.containers||
	'pall:'||x_dleg_rec.pallets);


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Source_Lines_As_Details');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Source_Lines_As_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Source_Lines_As_Details');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_insert_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Source_Lines_As_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_insert_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Source_Lines_As_Details');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Add_Source_Lines_As_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Add_Source_Lines_As_Details');


END Add_Source_Lines_As_Details;


PROCEDURE TL_Cache_First_OM_Lane(
		p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
		p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
		p_lane_id IN NUMBER,
		p_schedule_id IN NUMBER,
		p_vehicle_type_id IN NUMBER,
		x_trip_index IN OUT NOCOPY NUMBER,
		x_carrier_index IN OUT NOCOPY NUMBER,
		x_stop_index IN OUT NOCOPY NUMBER,
		x_dleg_index IN OUT NOCOPY NUMBER,
		x_return_status OUT NOCOPY Varchar2)
IS

	l_internal_location NUMBER;


	l_trip_rec TL_trip_data_input_rec_type;

	l_carrier_rec	TL_CARRIER_PREF_REC_TYPE ;
	l_pickup_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_dropoff_stop_rec TL_TRIP_STOP_INPUT_REC_TYPE;
	l_dleg_rec TL_delivery_leg_rec_type;
	l_stop_distance_tab	TL_stop_distance_tab_type;
	l_initial_stop_index NUMBER;
	l_initial_dleg_index NUMBER;
	l_region_id 	NUMBER;
	l_pickup_location NUMBER;
	l_dropoff_location NUMBER;
	l_departure_date DATE;
	l_arrival_date DATE;
	i NUMBER;
	l_physical_previous_flag VARCHAR2(1);
	l_return_status VARCHAR2(1);
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
	l_warning_count 	NUMBER:=0;


BEGIN


	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_Cache_First_OM_Lane','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	l_initial_stop_index:=x_stop_index;
	l_initial_dleg_index:=x_dleg_index;




	--
	l_pickup_location:=p_source_header_rec.ship_from_location_id;
	l_dropoff_location:=p_source_header_rec.ship_to_location_id;
	l_departure_date:=p_source_header_rec.ship_date;

	IF (l_departure_date IS NULL)
	THEN

		l_departure_date:=SYSDATE;
	END IF;

	l_arrival_date:=p_source_header_rec.arrival_date;

	IF (l_arrival_date IS NULL)
	THEN

		l_arrival_date:=l_departure_date;

	END IF;



	l_internal_location:=NULL;
	Get_internal_location(
	       p_dummy_location_id=>l_dropoff_location,
	       x_internal_location_id=>l_internal_location,
       	       x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_int_loc_fail;
	       END IF;
	END IF;
	IF (l_internal_location IS NOT NULL)
	THEN
		l_dropoff_location:=l_internal_location;

	END IF;



	--Create Dummy DLEG

	Initialize_Dummy_Dleg(
		p_pickup_location	=>l_pickup_location,
		p_dropoff_location	=>l_dropoff_location,
		p_dlv_id	=>p_source_header_rec.consolidation_id,
		x_dleg_rec	=>l_dleg_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail;
	       END IF;
	END IF;

	--Use the consolidation id as the dleg id, to match rates with the consolidation

	l_dleg_rec.delivery_leg_id:=p_source_header_rec.consolidation_id;
	l_dleg_rec.trip_id:=p_source_header_rec.consolidation_id;

	--Create Dummy Trip

	Initialize_Dummy_Trip(
		p_departure_date	=>l_departure_date,
		p_arrival_date	=>l_arrival_date,
		x_trip_rec	=>l_trip_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_trip_fail;
		       END IF;
	END IF;


	--Use the consolidation id as the trip id, to match rates with the consolidation

	l_trip_rec.trip_id:=p_source_header_rec.consolidation_id;

	--Create Dummy Stops

	Initialize_Dummy_Stop(
		p_date	=>l_departure_date,
		p_location=>l_pickup_location,
		x_stop_rec	=>l_pickup_stop_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail;
		END IF;
	END IF;


	l_pickup_stop_rec.stop_id:=FAKE_STOP_ID_1;
	l_pickup_stop_rec.trip_id:=p_source_header_rec.consolidation_id;

	Initialize_Dummy_Stop(
		p_date	=>	l_arrival_date,
		p_location	=>	l_dropoff_location,
		x_stop_rec	=>	l_dropoff_stop_rec,
		x_return_status	=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_do_stop_fail;
		END IF;
	END IF;

	l_dropoff_stop_rec.stop_id:=FAKE_STOP_ID_2;
	l_dropoff_stop_rec.trip_id:=p_source_header_rec.consolidation_id;

	l_trip_rec.vehicle_type:=p_vehicle_type_id;

	IF (p_lane_id IS NOT NULL)
	THEN
		Get_Carrier_Pref_For_Lane(
			p_lane_id =>p_lane_id,
			x_carrier_service_rec=>l_carrier_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail;
			END IF;
		END IF;


		Get_Trip_Info_From_Lane(
			p_lane_id=>	p_lane_id,
			x_trip_rec=>	l_trip_rec,
			x_return_status	=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_lane_fail;
		       END IF;
		END IF;


	ELSIF (p_schedule_id IS NOT NULL)
	THEN
		Get_Carrier_Pref_For_Schedule(
			p_schedule_id =>p_schedule_id,
			x_carrier_service_rec=>l_carrier_rec,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail;
			END IF;
		END IF;



		Get_Trip_Info_From_Schedule(
			p_schedule_id=>	p_schedule_id,
			x_trip_rec=>	l_trip_rec,
			x_return_status	=>l_return_status);

		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		 THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
			   raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_schd_fail;
			END IF;
		END IF;


	END IF;

	--MULTICURRENCY
	TL_Get_Currency(
		p_delivery_id=>NULL,
		p_trip_id=>NULL,
		p_location_id=>l_pickup_location,
		p_carrier_id=>l_carrier_rec.carrier_id,
		x_currency_code=>l_carrier_rec.currency,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail;
	       END IF;
	END IF;

	Validate_Carrier_Info(
		x_carrier_info 	=>	l_carrier_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_Cache_First_Estimate_Trip',
			--	p_exc=>'g_tl_validate_carrier_fail',
			--	p_carrier_id=>l_carrier_rec.carrier_id);


			raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail;
		END IF;
	END IF;

	--Insert carrier info into cache
	g_tl_carrier_pref_rows(x_carrier_index):=l_carrier_rec;
	x_carrier_index:=x_carrier_index+1;




	Get_Region_For_Location(
		p_location_id=>	l_pickup_stop_rec.location_id,
		p_region_type=>	l_carrier_rec.region_level,
		x_region_id=>	l_pickup_stop_rec.stop_region,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get_Region_For_LocationRES: '||
		l_pickup_stop_rec.location_id ||':'||l_pickup_stop_rec.stop_region);



	Get_Region_For_Location(
		p_location_id=>	l_dropoff_stop_rec.location_id,
		p_region_type=>	l_carrier_rec.region_level,
		x_region_id=>	l_dropoff_stop_rec.stop_region,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get region for location ');
		  --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail;
	       END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get_Region_For_LocationRES: '||
		l_dropoff_stop_rec.location_id ||':'||l_dropoff_stop_rec.stop_region);


	Add_Source_Lines_As_Details(
		p_consolidation_id=>p_source_header_rec.consolidation_id,
		p_source_lines_tab=>p_source_lines_tab,
		p_carrier_pref_rec=>l_carrier_rec,
		x_pickup_stop_rec=>l_pickup_stop_rec,
		x_dropoff_stop_rec=>l_dropoff_stop_rec,
		x_dleg_rec=>l_dleg_rec,
		x_return_status=>l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_src_as_dtl_fail;
	       END IF;
	END IF;



	Validate_Dleg_Info(
		x_dleg_info=>	l_dleg_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail;
	       END IF;
	END IF;

	g_tl_delivery_leg_rows(x_dleg_index):=l_dleg_rec;
	x_dleg_index:=x_dleg_index+1;



	Add_Inputs_For_Distance(
	 p_from_stop_rec=> l_pickup_stop_rec,
	 p_to_stop_rec=> 	l_dropoff_stop_rec,
	 p_empty_flag=>	'N',
	 x_stop_distance_tab=>	l_stop_distance_tab,
	 x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail;
	       END IF;
	END IF;



	--Update trip rec

	Update_Trip_With_Stop_Info(
		p_stop_rec	=>	l_pickup_stop_rec,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail;
	       END IF;
	END IF;
	--Insert Stop info into Cache

	--Perform validation after getting dist,time,fac info

	g_tl_trip_stop_rows(x_stop_index):=l_pickup_stop_rec;
	x_stop_index:=x_stop_index+1;





	--Update trip rec

	Update_Trip_With_Stop_Info(
		p_stop_rec	=>	l_dropoff_stop_rec,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail;
	       END IF;
	END IF;
	--Insert Stop info into Cache

	--Perform validation after getting dist,time,fac info

	g_tl_trip_stop_rows(x_stop_index):=l_dropoff_stop_rec;
	x_stop_index:=x_stop_index+1;




	g_tl_trip_stop_rows(x_stop_index-1).distance_to_next_stop:=0;
	g_tl_trip_stop_rows(x_stop_index-1).time_to_next_stop:=0;





	--GEt distances/time from mileage table, update, stop, dleg buffer, trip
	--loaded, unlaoded distances

	Get_Distances(
		p_stop_index	=>	l_initial_stop_index,
		p_dleg_index	=>	l_initial_dleg_index,
		p_carrier_rec	=>	l_carrier_rec,
		x_stop_distance_tab	=>l_stop_distance_tab,
		x_trip_rec	=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail;
       		END IF;
	END IF;


	--Get facility Info and store into stop cache
	Get_Facility_Info(p_stop_index	=>	l_initial_stop_index,
			x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to get facility information');
	          --raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail;
	       END IF;
	END IF;

	--Validate All Stops(all the stop,distance,time,fac info has beengathered

	FOR i IN l_initial_stop_index..(x_stop_index-1)
	LOOP
		--Determine if the stop is pickup/dropoff/both or none
		Get_Stop_Type(x_stop_rec=>g_tl_trip_stop_rows(i));

		Validate_Stop_Info(
		p_carrier_pref_rec=>l_carrier_rec,
		x_stop_info=>	g_tl_trip_stop_rows(i),
		x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail;
		       END IF;
		END IF;

	END LOOP;





	--Update trip rec
	l_trip_rec.number_of_stops:=2;


	l_trip_rec.distance_method:=l_carrier_rec.distance_calculation_method;

	--get the arrival and dep dates of the trip
	--from first and last stop

	l_trip_rec.planned_departure_date:=
		g_tl_trip_stop_rows(l_initial_stop_index).planned_departure_date;
	l_trip_rec.planned_arrival_date:=
		g_tl_trip_stop_rows(x_stop_index-1).planned_arrival_date;

	--Dead head trip has no dlegs 3958974

	l_trip_rec.dead_head:='N';


	l_trip_rec.stop_reference:=l_initial_stop_index;
	l_trip_rec.delivery_leg_reference:=l_initial_dleg_index;

	--Insert into trip cache

	Validate_Trip_Info(
		x_trip_info=>	l_trip_rec,
		x_return_status	=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN

	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail;
	       END IF;
	END IF;

	g_tl_trip_rows(x_trip_index):=l_trip_rec;
	x_trip_index:=x_trip_index+1;




        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;



EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_int_loc_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_int_loc_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_pu_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_pu_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_dummy_do_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_dummy_do_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');




   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trp_inf_frm_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_car_prf_for_schd_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_car_prf_for_schd_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_trp_inf_frm_schd_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_trp_inf_frm_schd_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_carrier_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_carrier_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_reg_for_loc_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_reg_for_loc_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_src_as_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_src_as_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_pickup_qty_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_pickup_qty_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_add_ip_dist_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_add_ip_dist_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_updt_trip_with_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_updt_trip_with_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_distances_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_distances_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_facility_info_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_facility_info_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_validate_trip_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_validate_trip_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_Cache_First_OM_Lane',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_Cache_First_OM_Lane');

END TL_Cache_First_OM_Lane;



PROCEDURE TL_BUILD_CACHE_FOR_OM(
	p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
	x_return_status OUT NOCOPY Varchar2)
IS

	l_trip_index NUMBER;
	l_carrier_index NUMBER;
	l_stop_index NUMBER;
	l_dleg_index	NUMBER;
	l_child_dleg_index	NUMBER;

	l_last_trip_index 	NUMBER;
	l_last_carrier_index 	NUMBER;
	l_last_stop_index 	NUMBER;
	l_last_dleg_index	NUMBER;


	i NUMBER;
	j NUMBER;

	l_cached_first_trip_flag VARCHAR2(1);


l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_BUILD_CACHE_FOR_OM','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	Initialize_Cache_Indices(
		x_trip_index=>	l_trip_index,
		x_stop_index=>	l_stop_index,
		x_dleg_index=>	l_dleg_index,
		x_carrier_index=>l_carrier_index,
		x_child_dleg_index=>l_child_dleg_index,
		x_return_status=> l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
	       END IF;
	END IF;


	l_cached_first_trip_flag:='N';
	i:=p_lane_rows.FIRST;

	-- Query up the trip/stops/dleg and cache it
	WHILE (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND
	p_vehicle_rows.EXISTS(i) AND (l_cached_first_trip_flag='N'))
	LOOP

		TL_Cache_First_OM_Lane(
			p_source_header_rec=>p_source_header_rec,
			p_source_lines_tab=>p_source_lines_tab,
			p_lane_id=>p_lane_rows(i),
			p_schedule_id=>p_schedule_rows(i),
			p_vehicle_type_id => p_vehicle_rows(i),
			x_trip_index => l_trip_index,
			x_carrier_index => l_carrier_index,
			x_stop_index => l_stop_index,
			x_dleg_index => l_dleg_index ,
			x_return_status =>l_return_status);


		  l_cached_first_trip_flag:='Y';

		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		  THEN
		         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		         THEN

		         	Delete_Cache(x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail;
				       END IF;
				END IF;

				Initialize_Cache_Indices(
					x_trip_index=>	l_trip_index,
					x_stop_index=>	l_stop_index,
					x_dleg_index=>	l_dleg_index,
					x_carrier_index=>l_carrier_index,
					x_child_dleg_index=>l_child_dleg_index,
					x_return_status=> l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail;
				       END IF;
				END IF;

				l_cached_first_trip_flag:='N';
		         END IF;
		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

	IF (l_cached_first_trip_flag='N')
	THEN


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached;

	END IF;

	--The first lane/schedule has been cached
	--For the remaining lanes/schedules we shall copy the data we captured above
	--and alter the UOMs according to the lanes




	--Alter and copy into cache for each lane



	WHILE ( (i IS NOT NULL) AND (p_lane_rows.EXISTS(i)))
	LOOP

		IF (p_lane_rows.EXISTS(i) AND p_schedule_rows.EXISTS(i) AND p_vehicle_rows.EXISTS(i)
			AND ((p_lane_rows(i) IS NOT NULL) OR (p_schedule_rows(i) IS NOT NULL) ))
		THEN

			--Store all the indices

			l_last_trip_index:=l_trip_index;
			l_last_carrier_index:=l_carrier_index;
			l_last_stop_index:=l_stop_index;
			l_last_dleg_index:=l_dleg_index;



			Cache_Next_Trip_Lane(
				p_trip_id=>FAKE_TRIP_ID,
				p_lane_id=> p_lane_rows(i),
				p_schedule_id=> p_schedule_rows(i),
				p_vehicle=> p_vehicle_rows(i) ,
				x_trip_index => l_trip_index,
				x_carrier_index=>l_carrier_index,
				x_stop_index=>l_stop_index,
				x_dleg_index=>l_dleg_index,
				x_child_dleg_index=>l_child_dleg_index,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				   l_warning_count:=l_warning_count+1;
			       	   IF (p_schedule_rows(i) IS NOT NULL)
			       	   THEN

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache OM Consolidations'
			       	   	   ||p_source_header_rec.consolidation_id||' schedule '||p_schedule_rows(i)||':g_tl_cmp_trip_sched_fail');

					   --FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_BUILD_CACHE_FOR_OM',
					--	p_exc=>'g_tl_cmp_trip_sched_fail',
					--	p_msg_type=>'W',
					--	p_trip_id=> p_wsh_trip_id,
					--	p_schedule_id=>p_schedule_rows(i));
				    ELSE

			       	   	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Failed to cache delivery'
			       	   	   ||p_source_header_rec.consolidation_id||' lane '||p_lane_rows(i)||':g_tl_cmp_trip_lane_fail');

					--   FTE_FREIGHT_PRICING_UTIL.setmsg (
					--	p_api=>'TL_BUILD_CACHE_FOR_OM',
					--	p_exc=>'g_tl_cmp_trip_lane_fail',
					--	p_msg_type=>'W',
					--	p_trip_id=> p_wsh_trip_id,
					--	p_lane_id=>p_lane_rows(i));


				    END IF;

				--Restore indices

				l_trip_index:=l_last_trip_index;
				l_carrier_index:=l_last_carrier_index;
				l_stop_index:=l_last_stop_index;
				l_dleg_index:=l_last_dleg_index;


				--DELETE Newly added cache

				Partially_Delete_Cache(
					p_trip_index=>l_trip_index,
					p_carrier_index=>l_carrier_index,
					p_stop_index=>l_stop_index,
					p_dleg_index=>l_dleg_index,
					p_child_dleg_index=>l_child_dleg_index);

			       END IF;
			END IF;




		ELSE

			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'TL_BUILD_CACHE_FOR_OM',
			--	p_exc=>'g_tl_no_lane_sched_veh',
			--	p_trip_id=>p_wsh_trip_id);

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh;

		END IF;

		i:=p_lane_rows.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_trips_cached THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_trips_cached');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_init_cache_indices_fail THEN
   	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
   	FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_init_cache_indices_fail');
   	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cache_first_trp_lane_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cache_first_trp_lane_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_lane_sched_veh THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_lane_sched_veh');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_cache_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_cache_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_BUILD_CACHE_FOR_OM',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_BUILD_CACHE_FOR_OM');



END TL_BUILD_CACHE_FOR_OM;



END FTE_TL_CACHE;

/
