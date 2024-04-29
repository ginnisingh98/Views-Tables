--------------------------------------------------------
--  DDL for Package WSH_TRIPS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIPS_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHTRACS.pls 120.2.12000000.1 2007/01/16 05:51:31 appldev ship $ */

-- trip stops are created 10 minutes apart
C_TEN_MINUTES    CONSTANT NUMBER       := 1/144;
C_TEN_SECONDS    CONSTANT NUMBER       := 1/8640;


TYPE cs_trip_rec_type IS RECORD (
                              Trip_id wsh_trips.trip_id%TYPE,
                              Trip_name wsh_trips.name%TYPE,
                              Planned_flag wsh_trips.planned_flag%TYPE,
                              Status_code wsh_trips.status_code%TYPE,
                              Carrier_id wsh_trips.carrier_id%TYPE,
                              Mode_of_transport wsh_trips.mode_of_transport%TYPE,
                              Service_level wsh_trips.service_level%TYPE,
                              Ship_method_code wsh_trips.ship_method_code%TYPE,
                              --Track_only_flag wsh_trips.track_only_flag%TYPE,
                              Consignee_car_ac_no wsh_trips.consignee_carrier_ac_no%TYPE,
                              Freight_terms_code wsh_trips.freight_terms_code%TYPE,
                              Load_tender_status wsh_trips.load_tender_status%TYPE,
                              Lane_id wsh_trips.lane_id%TYPE,
                              Rank_id wsh_trips.rank_id%TYPE);

TYPE cs_trip_tab_type IS TABLE OF cs_trip_rec_type INDEX BY BINARY_INTEGER;

TYPE cs_stop_rec_type IS RECORD (
        STOP_ID                   wsh_trip_stops.stop_id%TYPE
      , TRIP_ID                   wsh_trip_stops.trip_id%TYPE
      --To handle dummy locations #DUM_LOC(S)
      , STOP_LOCATION_ID          wsh_trip_stops.stop_location_id%TYPE
      , STATUS_CODE               wsh_trip_stops.STATUS_CODE%TYPE
      , STOP_SEQUENCE_NUMBER      wsh_trip_stops.STOP_SEQUENCE_NUMBER%TYPE
      , PLANNED_ARRIVAL_DATE      wsh_trip_stops.PLANNED_ARRIVAL_DATE%TYPE
      , PLANNED_DEPARTURE_DATE    wsh_trip_stops.PLANNED_DEPARTURE_DATE%TYPE
      , ACTUAL_ARRIVAL_DATE       wsh_trip_stops.ACTUAL_ARRIVAL_DATE%TYPE
      , ACTUAL_DEPARTURE_DATE     wsh_trip_stops.ACTUAL_DEPARTURE_DATE%TYPE
      --DUM_LOC(S)
      , PHYSICAL_LOCATION_ID      wsh_trip_stops.PHYSICAL_LOCATION_ID%TYPE
      --#DUM_LOC(E)
      , PHYSICAL_STOP_ID          wsh_trip_stops.PHYSICAL_STOP_ID%TYPE
      , pick_up_weight            wsh_trip_stops.pick_up_weight%TYPE
      , weight_uom_code           wsh_trip_stops.weight_uom_code%TYPE
      , pick_up_volume            wsh_trip_stops.pick_up_volume%TYPE
      , volume_uom_code           wsh_trip_stops.volume_uom_code%TYPE
    );

TYPE cs_stop_tab_type IS TABLE OF cs_stop_rec_type INDEX BY BINARY_INTEGER;

-- SSN change
FUNCTION Get_Stop_Seq_Mode return NUMBER;

-- PROCEDURE Get_Trip_Defaults
-- This procedure will return a record of trip defaults used for trip confirmation

PROCEDURE Get_Trip_Defaults(p_trip_id in NUMBER,
                            p_trip_name in VARCHAR2 DEFAULT NULL,
                            x_def_rec IN OUT  NOCOPY WSH_TRIPS_GRP.default_parameters_rectype,
                            x_return_Status OUT NOCOPY varchar2 ) ;

--
-- Procedure:   Confirm_Trip
-- Parameters:  p_trip_id, p_action_flag, p_intransit_flag,
--              p_close_flag, p_stage_del_flag, p_report_set_id,
--              p_ship_method, p_actual_dep_date, p_bol_flag, p_defer_interface_flag,
--              x_return_status
-- Description: Selects all the Stops for the Trip, if the Trip is passed
--              and calls Confirm_Stop for each Stop.


PROCEDURE Confirm_Trip (
                         p_trip_id    IN NUMBER,
                         p_action_flag    IN  VARCHAR2,
                         p_intransit_flag IN  VARCHAR2,
                         p_close_flag    IN   VARCHAR2,
                         p_stage_del_flag   IN   VARCHAR2,
                         p_report_set_id  IN   NUMBER,
                         p_ship_method    IN   VARCHAR2,
                         p_actual_dep_date  IN   DATE,
                         p_bol_flag    IN   VARCHAR2,
                         p_defer_interface_flag  IN VARCHAR2,
			 p_mbol_flag  IN VARCHAR2, -- Added MBOL flag
                         x_return_status   OUT   NOCOPY VARCHAR2) ;



--
-- Procedure:     Plan
-- Parameters:    p_trip_rows, p_action, x_return_status
-- Description:   Sets the planned flag of the trip to 'Y'or 'N' after
--                performing plan/unplan action checks. P_action has the values
--                - 'PLAN'
--                - 'UNPLAN'

PROCEDURE Plan(
		p_trip_rows 	  	IN 	wsh_util_core.id_tab_type,
                p_action                IN      VARCHAR2,
		x_return_status	  	OUT NOCOPY 	VARCHAR2);


--
-- Procedure:	Change_Status
-- Parameters:	p_trip_rows, p_status_code, x_return_status
-- Description:	Sets the status code of the trip to p_status_code after
--		performing status code checks.
--		p_trip_rows - a table of trip_ids

PROCEDURE Change_Status (
		p_trip_id 		IN 	NUMBER,
		p_status_code		IN	VARCHAR2,
		x_return_status		OUT NOCOPY 	VARCHAR2);

--
-- Procedure:	Autocreate_Trip_multi
--              New procedure which gets the ignore_for_planning flag
--              and groups them on the basis of that.
-- Parameters:	p_del_rows, x_trip_ids, x_trip_names, x_return_status
-- Description:	Autocreates trip from a table of deliveries
--		p_del_rows  - a table of delivery_ids
--              p_entity    - indicates the entity on which the action is
--                            being performed.  It can be either
--                            'D' : delivery
--                            'L' : Line
--		x_trip_ids   - the autocreated trip ids
--		x_trip_names - the autocreated trip names

PROCEDURE autocreate_trip_multi(
		p_del_rows 		IN 	wsh_util_core.id_tab_type,
		p_entity      IN  VARCHAR2 DEFAULT 'D',
                x_trip_ids    OUT NOCOPY    wsh_util_core.id_tab_type,
                x_trip_names  OUT NOCOPY    wsh_util_core.Column_Tab_Type,
		x_return_status 	OUT NOCOPY  	VARCHAR2);

--
-- Procedure:	Autocreate_Trip
-- Parameters:	p_del_rows, x_trip_id, x_trip_name, x_return_status
-- Description:	Autocreates trip from a table of deliveries
--		p_del_rows  - a table of delivery_ids
--              p_entity    - indicates the entity on which the action is
--                            being performed.  It can be either
--                            'D' : delivery
--                            'L' : Line
--		x_trip_id   - the autocreated trip id
--		x_trip_name - the autocreated trip name
--	NOTE:	Trip Stop/Delivery Leg sequences are not generated automatically

PROCEDURE autocreate_trip(
		p_del_rows 		IN 	wsh_util_core.id_tab_type,
                p_entity                IN      VARCHAR2 DEFAULT 'D',
		x_trip_id 		OUT NOCOPY  	NUMBER,
		x_trip_name 		OUT NOCOPY  	VARCHAR2,
		x_return_status 	OUT NOCOPY  	VARCHAR2,
                p_sc_pickup_date        IN      DATE   DEFAULT NULL,
                p_sc_dropoff_date       IN      DATE   DEFAULT NULL);



--
-- Procedure:	Autocreate_Del_Trip
-- Parameters:	p_line_rows, p_init_flag, p_max_detail_commit,
--		p_del_rows, x_trip_id, x_trip_name, x_return_status
-- Description:	Autocreates trip from a table of delivery details
--		Calls Autocreate_deliveries to create deliveries and then
--		Autocreate_trip to create trip, stops and delivery legs
--		p_line_rows - a table of delivery_detail_ids
--		p_org_rows - a table of organization_ids.  If this table is not available to pass
--                    - then pass a dummy value in. the table will get regenerated when
--                    - calling WSH_DELIVERY_AUTOCREATE.autocreate_del_across_orgs
--		x_trip_id	  - the autocreated trip id
--		x_trip_name - the autocreated trip name
--	NOTE:	Trip Stop/Delivery Leg sequences are not generated automatically

--Compatibility Changes - removed trip_id, trip_name and added x_trip_rows
PROCEDURE autocreate_del_trip(
         p_line_rows     	IN    	wsh_util_core.id_tab_type,
         p_org_rows      	IN    	wsh_util_core.id_tab_type,
         p_max_detail_commit  	IN 	NUMBER := 1000,
         x_del_rows      	OUT NOCOPY wsh_util_core.id_tab_type,
         x_trip_rows      	OUT NOCOPY wsh_util_core.id_tab_type,
         x_return_status   	OUT NOCOPY VARCHAR2);

--
-- Procedure:	Assign_Trip (for delivery details)
-- Parameters:	p_line_rows, p_trip_id, p_del_rows, x_return_status
-- Description:	Autocreates deliveries from a table of delivery details
--		and then assigns these deliveries to the trip
--		p_line_rows - table of delivery_detail_ids
--		p_trip_id   - the trip id to assign details to
--		x_del_rows  - table of autocreated deliveries
--	NOTE:	Trip Stop/Delivery Leg sequences are not generated automatically

PROCEDURE assign_trip(
		p_line_rows 		IN 	wsh_util_core.id_tab_type,
		p_trip_id   		IN 	NUMBER,
		x_del_rows		OUT NOCOPY  	wsh_util_core.id_tab_type,
		x_return_status 	OUT NOCOPY  	VARCHAR2);

--
-- Procedure:	Assign_Trip (for deliveries)
-- Description:	Assigns a table of deliveries to a trip
--		p_del_rows - a table of delivery_ids
--		p_trip_id  - the trip id to assign deliveries to
--        p_pickup_stop_id - the stop id to pickup deliveries (optional)
--        p_dropoff_stop_id - the stop id to dropoff deliveries (optional)
--        p_pickup_location_id - the stop location id to pickup deliveries (optional)
--        p_dropoff_location_id - the stop location id to dropoff deliveries (optional)

--	NOTE:	Trip Stop/Delivery Leg sequences are not generated automatically
/* H integration - for sequence number added parameters */


PROCEDURE assign_trip(
		p_del_rows 		IN 	wsh_util_core.id_tab_type,
		p_trip_id 		IN 	NUMBER,
		p_pickup_stop_id	IN	NUMBER := NULL,
		p_pickup_stop_seq	IN	NUMBER := NULL,
		p_dropoff_stop_id 	IN   	NUMBER := NULL,
		p_dropoff_stop_seq 	IN   	NUMBER := NULL,
		p_pickup_location_id 	IN  	NUMBER := NULL,
		p_dropoff_location_id 	IN 	NUMBER := NULL,
		p_pickup_arr_date   	IN   	DATE := to_date(NULL),
		p_pickup_dep_date   	IN   	DATE := to_date(NULL),
		p_dropoff_arr_date  	IN   	DATE := to_date(NULL),
		p_dropoff_dep_date  	IN   	DATE := to_date(NULL),
		x_return_status 	OUT 	VARCHAR2,
                p_caller                IN      VARCHAR2 DEFAULT NULL);



--
-- Procedure:	Trip_Weight_Volume
-- Parameters:	p_trip_rows, p_start_departure_date,x_return_status
-- Description:	Calculates stop wt/vol for multiple trips
--		p_trip_rows	   - the trip ids to calculate wt/vol
--              p_override_flag    - automatically updates the trip wt/vol
--              p_calc_wv_if_frozen  - 'Y' if Manually entered W/V can be overridden
--              p_start_departure_date - the departure date from which point
--                                   onward all stops wt/vol is calculated
--              p_calc_del_wv  - If value is 'Y', the W/V will be recalculated using delivery W/V apis
--                               Else W/V on delivery will be used
--              x_return_status - this returns an error if all trips had errors.
--              p_suppress_errors - 'Y': do not return error for #2 and #3 below (bug 2366163)
--                                Each trip can have errors if
--                                    1) no trip stops are found
--                                    2) any trip stop does not have uom info
--                                    3) delivery wt/vol calculation fails

PROCEDURE Trip_weight_volume(
		p_trip_rows 		IN 	wsh_util_core.id_tab_type,
                p_override_flag 	IN 	VARCHAR2,
                p_calc_wv_if_frozen     IN      VARCHAR2 DEFAULT 'Y',
		p_start_departure_date 	IN 	DATE,
                p_calc_del_wv           IN      VARCHAR2 DEFAULT 'Y',
		x_return_status 	OUT NOCOPY  	VARCHAR2,
                p_suppress_errors       IN      VARCHAR2 DEFAULT NULL,
                p_caller                IN      VARCHAR2 DEFAULT NULL);



--
-- Procedure:	Validate_Stop_Sequence
-- Parameters:	p_trip_id, x_return_status
-- Description:	Validate sequence of a trip based on planned dates
--		p_trip_id	   - the trip id to validate stop sequences
--              x_return_status - this returns an error if the sequence is invalid

PROCEDURE Validate_Stop_Sequence(
		p_trip_id 		IN 	NUMBER,
		x_return_status 	OUT NOCOPY  	VARCHAR2);

--
-- Procedure:	Check_Unassign_Trip
-- Parameters:	p_del_rows, x_trip_rows, x_return_status
-- Description:	Validate if the deliveries can be unassigned together and
--                  returns a trip_id
--              x_return_status - this returns an error if the sequence is invalid

PROCEDURE Check_Unassign_Trip(
		p_del_rows 		IN 	wsh_util_core.id_tab_type,
		x_trip_rows		OUT NOCOPY   wsh_util_core.id_tab_type,
		x_return_status 	OUT NOCOPY  	VARCHAR2);


--
-- Procedure:	Unassign_Trip
-- Parameters:	p_del_rows, p_trip_id, x_return_status
-- Description: Unassigns deliveries from a trip by calling the
--              wsh_delivery_legs_actions.unassign_deliveries procedure

PROCEDURE Unassign_Trip(
		p_del_rows 		IN 	wsh_util_core.id_tab_type,
		p_trip_id		     IN   NUMBER,
		x_return_status 	OUT NOCOPY  	VARCHAR2);


-- J-IB-NPARIKH-{
PROCEDURE changeStatus
            (
              p_in_rec             IN          WSH_TRIP_VALIDATIONS.ChgStatus_in_rec_type,
              x_return_status      OUT NOCOPY  VARCHAR2
            ) ;
-- J-IB-NPARIKH-}

-- J: W/V Changes

-- Start of comments
-- API name : calc_stop_fill_percent
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calculates the fill% of stop with specified W/V info
-- Parameters :
-- IN:
--    p_stop_id      IN NUMBER Required
--    p_gross_weight IN  NUMBER
--      Gross Wt. of the stop
--    p_volume       IN  NUMBER
--      Volume of the stop
-- OUT:
--    x_stop_fill_percent OUT NUMBER
--       gives the calculated fill%
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE calc_stop_fill_percent(
            p_stop_id           IN  NUMBER,
            p_gross_weight      IN  NUMBER,
            p_volume            IN  NUMBER,
            x_stop_fill_percent OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2);

-- Start of comments
-- API name : Fte_Load_Tender
-- Type     : Public
-- Pre-reqs : None.
-- Function : Calls the FTE API to check for any change in Stop Info
-- Parameters :
-- IN:
--    p_stop_id      IN NUMBER Required
--    p_gross_weight IN  NUMBER
--      Gross Wt. of the stop
--    p_net_weight IN  NUMBER
--      Net Wt. of the stop
--    p_volume       IN  NUMBER
--      Volume of the stop
--    p_fill_percent IN  NUMBER
--      Fill Percent of the stop
-- OUT:
--    x_return_status OUT VARCHAR2 Required
--       give the return status of API
-- Version : 1.0
-- End of comments

PROCEDURE Fte_Load_Tender(
            p_stop_id       IN NUMBER,
            p_gross_weight  IN NUMBER,
            p_net_weight    IN NUMBER,
            p_volume        IN NUMBER,
            p_fill_percent  IN NUMBER,
            x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE generateRoutingResponse
            (
              p_action_prms            IN   WSH_TRIPS_GRP.action_parameters_rectype,
              p_rec_attr_tab           IN   WSH_TRIPS_PVT.Trip_Attr_Tbl_Type,
              x_return_status          OUT     NOCOPY  VARCHAR2
            );

-- bug 3516052
PROCEDURE reset_stop_planned_dates
          ( p_trip_id       IN NUMBER,
            p_caller        IN VARCHAR2,
           x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE reset_stop_planned_dates
          ( p_trip_ids          IN  wsh_util_core.id_tab_type,
            p_caller            IN VARCHAR2,
            x_success_trip_ids  OUT NOCOPY  wsh_util_core.id_tab_type,
            x_return_status     OUT NOCOPY  VARCHAR2);


PROCEDURE Handle_Internal_Stops
    (   p_trip_ids          IN         wsh_util_core.id_tab_type,
        p_caller            IN         VARCHAR2,
        x_success_trip_ids  OUT NOCOPY wsh_util_core.id_tab_type,
        x_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE PROCESS_CARRIER_SELECTION (
        p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false,
        p_trip_id_tab              IN            wsh_util_core.id_tab_type,
        p_caller                   IN  VARCHAR2 DEFAULT NULL, -- WSH_FSTRX / WSH_PUB /  WSH_GROUP/ FTE
        x_msg_count                OUT NOCOPY    NUMBER,
        x_msg_data                 OUT NOCOPY    VARCHAR2,
        x_return_status            OUT NOCOPY  VARCHAR2);


--Set to trip_id for which WSH_FTE_INTEGRATION.Rate_Trip api has been called.
g_rate_trip_id  NUMBER;

PROCEDURE Remove_Consolidation(
                p_trip_id_tab   IN wsh_util_core.id_tab_type,
                p_unassign_all  IN VARCHAR2,
                p_caller        IN VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2);


END WSH_TRIPS_ACTIONS;

 

/
