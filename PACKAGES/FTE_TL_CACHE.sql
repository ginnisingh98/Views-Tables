--------------------------------------------------------
--  DDL for Package FTE_TL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TL_CACHE" AUTHID CURRENT_USER AS
/* $Header: FTEVTLCS.pls 120.1 2007/11/30 05:57:45 sankarun ship $ */

FAKE_DLEG_ID NUMBER:=-1;
FAKE_TRIP_ID NUMBER:= -1;
FAKE_STOP_ID_1 NUMBER:=-1;
FAKE_STOP_ID_2 NUMBER:=-2;
FAKE_LOCATION_ID_1 NUMBER:=-1;
FAKE_LOCATION_ID_2 NUMBER:=-2;


TYPE TL_trip_data_input_rec_type IS RECORD (

trip_id                        NUMBER,
lane_id                        NUMBER,
schedule_id		       NUMBER,
service_type                   VARCHAR2(30),
carrier_id                     NUMBER,
mode_of_transport              VARCHAR2(30),
vehicle_type                   NUMBER,
price_list_id                  NUMBER,
loaded_distance                NUMBER,
unloaded_distance              NUMBER,
number_of_pallets              NUMBER,
number_of_containers           NUMBER,
time                           NUMBER,
number_of_stops                NUMBER,
total_trip_distance            NUMBER,
total_direct_distance          NUMBER,
distance_method                VARCHAR2(30),
total_weight                   NUMBER,
total_volume                   NUMBER,
continuous_move                 VARCHAR2(1),
planned_departure_date         DATE,
planned_arrival_date           DATE,
dead_head                      VARCHAR2(1),
stop_reference                 NUMBER,
delivery_leg_reference         NUMBER,
child_dleg_reference         NUMBER);

TYPE TL_trip_data_input_tab_type IS TABLE OF  TL_trip_data_input_rec_type INDEX BY BINARY_INTEGER;


TYPE TL_TRIP_STOP_INPUT_REC_TYPE IS RECORD(


stop_id	                       NUMBER,
trip_id	                       NUMBER,
location_id	               NUMBER,
weekday_layovers	       NUMBER,
weekend_layovers	       NUMBER,
distance_to_next_stop	       NUMBER,
time_to_next_stop	       NUMBER,
pickup_weight	               NUMBER,
pickup_volume	               NUMBER,
pickup_pallets	               NUMBER,
pickup_containers	       NUMBER,
loading_protocol	       VARCHAR2(30),
dropoff_weight	               NUMBER,
dropoff_volume	               NUMBER,
dropoff_pallets	               NUMBER,
dropoff_containers	       NUMBER,
stop_region	               NUMBER,
stop_zone	               VARCHAR2(30),
planned_arrival_date	       DATE,
planned_departure_date	       DATE,
stop_type		       VARCHAR2(30),--either PU,DO,PD,NA
physical_stop_id 		NUMBER,    --added for dummy stop fix
physical_location_id		NUMBER,    --added for dummy stop fix
fac_pickup_weight		NUMBER,
fac_pickup_volume		NUMBER,
fac_dropoff_weight		NUMBER,
fac_dropoff_volume		NUMBER,
fac_charge_basis		VARCHAR2(30),
fac_handling_time	       NUMBER,
fac_currency	       VARCHAR2(30),
fac_modifier_id	       NUMBER,
fac_pricelist_id	       NUMBER,
fac_weight_uom_class      VARCHAR2(30),
fac_weight_uom            VARCHAR2(30),
fac_volume_uom_class      VARCHAR2(30),
fac_volume_uom            VARCHAR2(30),
fac_distance_uom_class    VARCHAR2(30),
fac_distance_uom          VARCHAR2(30),
fac_time_uom_class        VARCHAR2(30),
fac_time_uom              VARCHAR2(30));


TYPE TL_TRIP_STOP_INPUT_TAB_TYPE IS TABLE OF  TL_TRIP_STOP_INPUT_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE TL_CARRIER_PREF_REC_TYPE IS RECORD(

carrier_id                     NUMBER,
max_out_of_route               NUMBER,
min_cm_distance                NUMBER,
min_cm_time                    NUMBER,
cm_free_dh_mileage             NUMBER,
cm_first_load_discount_flag    VARCHAR2(1),
currency                       VARCHAR2(30),
cm_rate_variant        	       VARCHAR2(30),
unit_basis                     VARCHAR2(30),
weight_uom_class               VARCHAR2(30),
weight_uom                     VARCHAR2(30),
volume_uom_class               VARCHAR2(30),
volume_uom                     VARCHAR2(30),
distance_uom_class             VARCHAR2(30),
distance_uom                   VARCHAR2(30),
time_uom_class                 VARCHAR2(30),
time_uom                       VARCHAR2(30),
region_level		       VARCHAR2(30),
distance_calculation_method    VARCHAR2(30),
dim_factor 		       NUMBER,
dim_weight_uom 		       VARCHAR2(30),
dim_volume_uom 		       VARCHAR2(30),
dim_length_uom 		       VARCHAR2(30),
dim_min_volume 		       NUMBER
);

TYPE TL_CARRIER_PREF_TAB_TYPE IS TABLE OF  TL_CARRIER_PREF_REC_TYPE INDEX BY BINARY_INTEGER;



TYPE TL_delivery_leg_rec_type IS RECORD(

delivery_leg_id                NUMBER,
trip_id                        NUMBER,
delivery_id                    NUMBER,
pickup_stop_id                 NUMBER,
pickup_location_id             NUMBER,
dropoff_stop_id                NUMBER,
dropoff_location_id            NUMBER,
weight                         NUMBER,
volume                         NUMBER,
pallets                        NUMBER,
containers                     NUMBER,
distance                       NUMBER,
direct_distance			NUMBER,
parent_dleg_id			NUMBER,--MDC
children_weight			NUMBER,--MDC
children_volume			NUMBER,--MDC
is_parent_dleg			VARCHAR2(1),-- MDC 'Y' or 'N'
parent_with_no_consol_lpn	VARCHAR2(1) --MDC 'Y' or 'N'
);

TYPE TL_delivery_leg_tab_type IS TABLE OF TL_delivery_leg_rec_type INDEX BY BINARY_INTEGER;

TYPE TL_DLV_DETAIL_MAP_REC_TYPE IS RECORD(
delivery_id	NUMBER,
delivery_detail_id NUMBER);

TYPE TL_DLV_DETAIL_MAP_TAB_TYPE IS TABLE OF TL_DLV_DETAIL_MAP_REC_TYPE INDEX BY BINARY_INTEGER;





TYPE TL_TRIP_OUTPUT_REC_TYPE IS RECORD (
trip_id	              NUMBER,
base_dist_load_chrg   NUMBER,
base_dist_load_unit_chrg NUMBER,
base_dist_unload_chrg NUMBER,
base_dist_unload_unit_chrg NUMBER,

base_unit_chrg        NUMBER,
base_unit_unit_chrg   NUMBER,

base_time_chrg        NUMBER,
base_time_unit_chrg   NUMBER,

base_flat_chrg        NUMBER,

stop_off_chrg         NUMBER,
out_of_route_chrg     NUMBER,
document_chrg         NUMBER,
handling_chrg         NUMBER,
handling_chrg_basis   NUMBER,
fuel_chrg	      NUMBER,
cm_discount_percent   NUMBER,
cm_discount_value     NUMBER,
currency              VARCHAR2(30),
total_trip_rate       NUMBER,
stop_charge_reference NUMBER  --pointer to the stop charge to handle multiple
);


TYPE TL_TRIP_OUTPUT_TAB_TYPE IS TABLE OF TL_TRIP_OUTPUT_REC_TYPE  INDEX BY BINARY_INTEGER;


TYPE TL_TRIP_STOP_OUTPUT_REC_TYPE IS RECORD (
stop_id                           NUMBER,
trip_id                           NUMBER,
weekday_layover_chrg              NUMBER,
weekend_layover_chrg              NUMBER,
loading_chrg                      NUMBER,
loading_chrg_basis                NUMBER,
ast_loading_chrg                  NUMBER,
ast_loading_chrg_basis            NUMBER,
unloading_chrg                    NUMBER,
unloading_chrg_basis              NUMBER,
ast_unloading_chrg                NUMBER,
ast_unloading_chrg_basis          NUMBER,
origin_surchrg                    NUMBER,
destination_surchrg               NUMBER,
fac_loading_chrg                  NUMBER,
fac_loading_chrg_basis            NUMBER,
fac_ast_loading_chrg              NUMBER,
fac_ast_loading_chrg_basis        NUMBER,
fac_unloading_chrg                NUMBER,
fac_unloading_chrg_basis          NUMBER,
fac_ast_unloading_chrg            NUMBER,
fac_ast_unloading_chrg_basis      NUMBER,
fac_handling_chrg                 NUMBER,
fac_handling_chrg_basis           NUMBER,
fac_currency                      VARCHAR2(30) );


TYPE TL_TRIP_STOP_OUTPUT_TAB_TYPE IS TABLE OF TL_TRIP_STOP_OUTPUT_REC_TYPE INDEX BY BINARY_INTEGER;




--Delivery Leg Cache
g_tl_delivery_leg_rows TL_delivery_leg_tab_type;

--Trip Cache
g_tl_trip_rows  TL_trip_data_input_tab_type;

--Trip Stop Rows
g_tl_trip_stop_rows  TL_TRIP_STOP_INPUT_TAB_TYPE;

--Carrier preference cache
g_tl_carrier_pref_rows  TL_CARRIER_PREF_TAB_TYPE;


g_tl_shipment_line_rows         FTE_FREIGHT_PRICING.shipment_line_tab_type;

--The following hash and map , are the equivalent of wsh_delivery_assignments, they capture which dlv-details are assigned to which dlv

--Delivery Detail map cache
--This contains a list dlv-details. All the dlv-details belonging to a dlv are contiguous.Given an index to the first dlv-dtl of a dlv
-- all the dlv-dtls for that dlv can be found by sequentially accessing records until dlv-dtl belonging to another dlv is found.
g_tl_delivery_detail_map TL_DLV_DETAIL_MAP_TAB_TYPE;

--Delivery to delivery detail hash

-- This is a hash indexed by delivery id, it returns an index into the Delivery detail map cache. It points to the begining of the list of
--dlv-details belonging to that dlv
g_tl_delivery_detail_hash DBMS_UTILITY.NUMBER_ARRAY;


--For MDC, all containers that are above the top level detail of deliveries
g_tl_int_shipment_line_rows FTE_FREIGHT_PRICING.shipment_line_tab_type;

--This will hold the child delivery legs information.
--These delivery legs will not be in g_tl_delivery_leg_rows.
--The weight will always be non-dimensional.
g_tl_chld_delivery_leg_rows TL_delivery_leg_tab_type;


PROCEDURE TL_Build_Cache_For_Move(
	p_fte_move_id 	IN 	NUMBER,
        x_return_status OUT NOCOPY 	VARCHAR2);

PROCEDURE TL_Build_Cache_For_Trip(
	p_wsh_trip_id IN	NUMBER,
 	x_return_status OUT NOCOPY	VARCHAR2);

PROCEDURE TL_Build_Cache_For_Delivery(
	p_wsh_new_delivery_id  	IN	NUMBER,
	p_wsh_delivery_leg_id 	IN	NUMBER ,
	p_lane_rows 	IN	DBMS_UTILITY.NUMBER_ARRAY,
	p_schedule_rows IN 	DBMS_UTILITY.NUMBER_ARRAY,
	x_return_status 	OUT	NOCOPY	VARCHAR2);

PROCEDURE TL_Build_Cache_For_OM(
	x_return_status	OUT 	NOCOPY	VARCHAR2);

PROCEDURE TL_BUILD_CACHE_FOR_TRP_COMPARE(
	p_wsh_trip_id IN Number ,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
	x_return_status OUT NOCOPY Varchar2);


PROCEDURE TL_BUILD_CACHE_FOR_LCS(
	p_wsh_trip_id IN Number ,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN dbms_utility.number_array ,
	p_vehicle_rows IN  dbms_utility.number_array,
	x_return_status OUT NOCOPY Varchar2);



PROCEDURE Delete_Cache(x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Display_Cache;

PROCEDURE get_approximate_distance_time(
  p_from_location_id		IN NUMBER,
  p_to_location_id		IN NUMBER,
  x_distance			OUT NOCOPY NUMBER,
  x_distance_uom		OUT NOCOPY VARCHAR2,
  x_transit_time		OUT NOCOPY NUMBER,
  x_transit_time_uom		OUT NOCOPY VARCHAR2,
  x_return_status		OUT NOCOPY VARCHAR2);


PROCEDURE FPA_Get_Trip_Info(
    p_trip_id 			IN NUMBER,
    x_distance 			OUT NOCOPY NUMBER,
    x_distance_uom 		OUT NOCOPY VARCHAR2,
    x_weight 			OUT NOCOPY VARCHAR2,
    x_weight_uom 		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2);


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
    p_destination_id IN NUMBER DEFAULT NULL);


PROCEDURE Get_Vehicle_Type(
	p_trip_id IN NUMBER,
	p_vehicle_item_id IN NUMBER,
	x_vehicle_type IN OUT NOCOPY NUMBER,
	x_return_status	OUT NOCOPY VARCHAR2);


PROCEDURE Calculate_Dimensional_Weight(
	p_carrier_pref_rec IN TL_CARRIER_PREF_REC_TYPE,
	p_weight IN NUMBER,
	p_volume IN NUMBER,
	x_dim_weight IN OUT NOCOPY NUMBER,
	x_return_status	OUT	NOCOPY	VARCHAR2);




PROCEDURE TL_BUILD_CACHE_FOR_DLV_COMPARE(
	p_wsh_delivery_id IN Number ,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
	p_dep_date                IN     DATE DEFAULT sysdate,
	p_arr_date                IN     DATE DEFAULT sysdate,
	p_pickup_location_id IN NUMBER,
	p_dropoff_location_id IN NUMBER,
	x_return_status OUT NOCOPY Varchar2);


PROCEDURE TL_BUILD_CACHE_FOR_OM(
	p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_lane_rows IN dbms_utility.number_array ,
	p_schedule_rows IN  dbms_utility.number_array,
	p_vehicle_rows IN  dbms_utility.number_array,
	x_return_status OUT NOCOPY Varchar2);



END FTE_TL_CACHE;

/
