--------------------------------------------------------
--  DDL for Package FTE_TL_RATING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TL_RATING" AUTHID CURRENT_USER AS
/* $Header: FTEVTLRS.pls 120.1 2007/11/30 06:08:02 sankarun ship $ */




 -- Public Procedures --

-- +======================================================================+
--   Procedure :
--           tl_rate_trip
--
--   Description:
--           Rates a trip. To be called from main rating apis.
--   Inputs:
--           p_trip_id  IN NUMBER       => a valid wsh trip id
--           p_output_type IN VARCHAR2  => 'M'- main table
--                                         'T'- temp table
--                                         'P'- plsql table
--           p_check_reprice_flag IN VARCHAR2  => 'Y'- checks repirce flag on delivery legs
--                                         	'N'- always rates
--   Output:
--           x_output_cost_tab OUT NOCOPY
--                   FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type
--                  => Table which may hold the rates for the trip
--                     if p_output_type = 'P'
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--           No direct
--
--   DB:
--           No direct
-- +======================================================================+

  PROCEDURE tl_rate_trip (
                   p_trip_id           IN  NUMBER ,
                   p_output_type       IN  VARCHAR2,
                   p_check_reprice_flag IN VARCHAR2 DEFAULT 'N',
                   x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
                   x_return_status     OUT NOCOPY VARCHAR2);


-- +======================================================================+
--   Procedure :
--           tl_rate_move
--
--   Description:
--           Rates a continuous move.
--   Inputs:
--           p_fte_move_id IN NUMBER       => a valid wsh trip id
--           p_output_type IN VARCHAR2  => 'M'- main table
--                                         'T'- temp table
--                                         'P'- plsql table
--           p_build_cache IN VARCHAR2  => 'Y'- rebuild cache
--                                         'N'- don't rebuild cache
--   Output:
--           x_output_cost_tab OUT NOCOPY
--                   FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type
--                  => Table which may hold the rates for the trip
--                     if p_output_type = 'P'
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--           No direct
--
--   DB:
--           No direct
-- +======================================================================+

  PROCEDURE tl_rate_move (
                   p_fte_move_id       IN  NUMBER ,
                   p_output_type       IN  VARCHAR2,
                   x_output_cost_tab   OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
                   x_return_status     OUT NOCOPY VARCHAR2);

--rates the given TL trip, using lanes/schedules. Used for multileg search services

PROCEDURE TL_TRIP_PRICE_COMPARE(
	p_wsh_trip_id       IN Number ,
	p_lane_rows         IN  dbms_utility.number_array ,
	p_schedule_rows     IN  dbms_utility.number_array,
	p_vehicle_rows      IN  dbms_utility.number_array,
        x_request_id        IN OUT NOCOPY NUMBER,
        x_lane_sched_sum_rows   OUT NOCOPY  dbms_utility.number_array,
        x_lane_sched_curr_rows  OUT NOCOPY  dbms_utility.name_array,
	x_return_status     OUT NOCOPY Varchar2);


-- This copies over rated from fte_freight_cost_temp to wsh_freight_costs
-- It deletes the rates from fte_freight_cost_temp
--Either the lane id or the schedule id have to be specified.The rates of a trip
--are identified by a combination of the lane/schedule id and the comparison request id

PROCEDURE Move_Records_To_Main(
	p_trip_id IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_comparison_request_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2);

--Deletes all the rates for the trip , from WSH_FREIGHT_COSTS

PROCEDURE Delete_Main_Records(
	p_trip_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2);


--Calculates an estimate of the TL price for the given weight/vol using the lanes/schedules.
--Used for Freight Estimate. Pickup/dropoff location can be null.
--It returns rates as base price, accessory charges

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
    p_origin_id IN NUMBER DEFAULT NULL,
    p_destination_id  IN NUMBER DEFAULT NULL);



PROCEDURE Get_Vehicles_For_LaneSchedules(
	p_trip_id                  IN  NUMBER DEFAULT NULL,
	p_lane_rows 	IN dbms_utility.number_array,
	p_schedule_rows IN dbms_utility.number_array,
	p_vehicle_rows IN dbms_utility.number_array,
	x_vehicle_rows  OUT NOCOPY dbms_utility.number_array,
	x_lane_rows 	OUT NOCOPY dbms_utility.number_array,
	x_schedule_rows OUT NOCOPY dbms_utility.number_array,
	x_ref_rows	OUT NOCOPY dbms_utility.number_array,
	x_return_status        OUT NOCOPY Varchar2);



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
	x_return_status        OUT NOCOPY Varchar2);



PROCEDURE TL_OM_RATING(
	p_lane_rows            IN  dbms_utility.number_array ,
	p_schedule_rows        IN  dbms_utility.number_array,
	p_lane_info_tab   IN FTE_FREIGHT_RATING_PUB.lane_info_tab_type,
	p_source_header_rec IN FTE_PROCESS_REQUESTS.fte_source_header_rec,
	p_source_lines_tab IN FTE_PROCESS_REQUESTS.fte_source_line_tab,
	p_LCSS_flag IN VARCHAR2,
	x_source_header_rates_tab  IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_header_rates_tab,
	x_source_line_rates_tab	IN OUT NOCOPY	FTE_PROCESS_REQUESTS.fte_source_line_rates_tab,
	x_return_status        OUT NOCOPY Varchar2);



PROCEDURE BEGIN_LCSS (
	p_trip_id 	IN NUMBER,
	p_lane_rows IN dbms_utility.number_array ,
	x_trip_index       OUT NOCOPY NUMBER,
	x_trip_charges_rec  OUT NOCOPY FTE_TL_CACHE.TL_trip_output_rec_type ,
	x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_total_cost    OUT NOCOPY NUMBER,
	x_currency      OUT NOCOPY VARCHAR2,
	x_vehicle_type OUT NOCOPY NUMBER,
	x_lane_ref	OUT NOCOPY NUMBER,
	x_return_status  OUT NOCOPY  VARCHAR2);


PROCEDURE END_LCSS (
	p_trip_index 		IN 	NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN 		FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_return_status         OUT NOCOPY  VARCHAR2);


PROCEDURE ABORT_LCSS (
	x_return_status         OUT NOCOPY  VARCHAR2);


PROCEDURE LCSS (
	p_trip_id 		IN NUMBER,
	p_lane_rows IN dbms_utility.number_array ,
	x_return_status         OUT NOCOPY  VARCHAR2);


PROCEDURE Move_Dlv_Records_To_Main(
	p_dleg_id IN NUMBER,
	p_lane_id IN NUMBER,
	p_schedule_id IN NUMBER,
	p_comparison_request_id IN NUMBER,
	x_return_status OUT NOCOPY VARCHAR2);



END FTE_TL_RATING;





/
