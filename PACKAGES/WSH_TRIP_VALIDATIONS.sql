--------------------------------------------------------
--  DDL for Package WSH_TRIP_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_VALIDATIONS" AUTHID CURRENT_USER as
/* $Header: WSHTRVLS.pls 120.1 2007/01/05 00:20:23 anxsharm noship $ */

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Plan
-- Parameters:    trip_id, x_return_status
-- Description:   Checks for Plan action pre-requisites which are
--		  - at least two stops are assigned
--		  - Vehicle or Ship Method information is specified
--		  - Stop sequences are valid
--		  - If trip has vehicle information then vehicle is not over/under filled at any stop [warning]
--		  - At least one delivery is assigned to trip [warning]
--  NOTE: Planning of a trip would automatically update weight/volume
--     information for stops and deliveries if they are not already specified.
--
-----------------------------------------------------------------------------

PROCEDURE Check_Plan ( p_trip_id 		IN  NUMBER,
		       x_return_status 		OUT NOCOPY  VARCHAR2,
                       p_caller                 IN      VARCHAR2 DEFAULT NULL);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Unplan
-- Parameters:    trip_id, x_return_status
-- Description:   Checks for Unplan action pre-requisites which are
--                - Trip status is not CLOSED
--                - Trip is planned
--
-----------------------------------------------------------------------------

PROCEDURE Check_Unplan ( p_trip_id 		IN  NUMBER,
		         x_return_status 	OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Trip_Close
-- Parameters:    trip_id, x_return_status
-- Description:   Checks for Trip Close action pre-requisites which are
-- 		  - Trip status is OPEN or IN-TRANSIT
--		  - If trip status is IN-TRANSIT then last stop status is ARRIVED or CLOSED [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Trip_Close ( p_trip_id 		IN  NUMBER,
		             x_return_status 	OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Trip_Delete
-- Parameters:    trip_id, x_return_status
-- Description:   Checks for Trip Delete action pre-requisites which are
-- 		  - Trip status is OPEN
--		  - No deliveries are assigned to trip [warning]
--		  - No freight costs are attached to trip [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Trip_Delete ( p_trip_id 	IN  NUMBER,
		              x_return_status 	OUT NOCOPY  VARCHAR2,
                              p_caller        IN      VARCHAR2 DEFAULT NULL);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Change_Carrier
-- Parameters:    trip_id, x_return_status
-- Description:   Checks for Change Carrier action pre-requisites which are
-- 		  Trip status is OPEN
--		  If  GROUP_BY_CARRIER_FLAG is set for any delivery on trip then Ship Method for deliveries and delivery details on this trip is not specified
--
-----------------------------------------------------------------------------

PROCEDURE Check_Change_Carrier ( p_trip_id 	 IN  NUMBER,
		                 x_return_status OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Stop_Arrive
-- Parameters:    stop_id, x_linked_stop_id, x_return_status
-- Description:   Checks for Arrive action pre-requisites which are
--                (these prerequisites need to be updated)  --wr
--		  - Actual Arrival Date is specified ( if date is not specified
--		    then default the current date in Actual Arrival Date)
--		  - Not the first stop on a trip
--		  - Previous stop on this trip is CLOSED [warning]
-- NOTE: this warning allows the user to Close All Previous Stops, Ignore or Cancel.
--
-----------------------------------------------------------------------------

PROCEDURE Check_Stop_Arrive ( p_stop_id 	IN  NUMBER,
                              x_linked_stop_id  OUT NOCOPY  NUMBER,  --wr
		              x_return_status 	OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Stop_Close
-- Parameters:    stop_id, x_return_status
-- Description:   Checks for Stop Close action pre-requisites which are
--		  - Actual Arrival Date and Actual Departure Date are specified
--		    (if first or last trip stop on a trip then only one of the
--                  two dates need to be specified)
--		  - Previous stop on this trip is CLOSED (except for the first trip stop) [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Stop_Close ( p_stop_id 		IN  NUMBER,
		             x_return_status 	OUT NOCOPY  VARCHAR2,
                             p_caller        IN      VARCHAR2 DEFAULT NULL);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Assign_Trip
-- Parameters:    stop_id, x_return_status
-- Description:   Checks for Assign Trip action pre-requisites which are
--		  - Trip status is not CLOSED
--		  - Trip is not planned
--		  - If trip has Vehicle information then vehicle is not over/under filled at this and subsequent stops [warning]
--               NOTE: The above three rules apply to both trip to be unassigned from and trip to be assigned to
--		  - Stop with the same location does not exist for the trip to be assigned to [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Assign_Trip ( p_stop_id 	IN  NUMBER,
			      p_trip_id		IN  NUMBER,
		              x_return_status 	OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Delete_Stop
-- Parameters:    stop_id, x_return_status, p_trip_flag
-- Description:   Checks for Delete Stop action pre-requisites which are
-- 		  - Stop status is OPEN
--                - Trip status is not CLOSED
--                - Trip is not planned
--                - No deliveries are assigned to this stop [warning]
-- NOTE: p_trip_flag is used to restrict delivery checks to only pickup deliveries
--
-----------------------------------------------------------------------------

PROCEDURE Check_Stop_Delete ( p_stop_id        IN  NUMBER,
		                    x_return_status  OUT NOCOPY  VARCHAR2,
						p_trip_flag      IN  VARCHAR2 DEFAULT 'N',
                                   p_caller        IN      VARCHAR2 DEFAULT NULL);

-----------------------------------------------------------------------------
--
-- Procedure:     Get_Disabled_List
-- Parameters:    stop_id, x_return_status, p_trip_flag
-- Description:   Get the disabled columns/fields in a trip
--
-----------------------------------------------------------------------------

PROCEDURE Get_Disabled_List (
						p_trip_id        IN  NUMBER,
						p_list_type		  IN  VARCHAR2,
						x_return_status  OUT NOCOPY  VARCHAR2,
						x_disabled_list  OUT NOCOPY  wsh_util_core.column_tab_type,
						x_msg_count             OUT NOCOPY      NUMBER,
						x_msg_data              OUT NOCOPY      VARCHAR2,
						p_caller IN VARCHAR2 DEFAULT NULL --public api changes
						);


-----------------------------------------------------------------------------
--
-- Procedure:     Valdiate Planned Trip
-- Parameters:    p_stop_id, x_return_status, p_stop_sequence_number
-- Description:   Get the trip status for update of stop sequence
--
-----------------------------------------------------------------------------
PROCEDURE validate_planned_trip
  (p_stop_id IN NUMBER,
   p_stop_sequence_number IN NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2
  );


--Harmonizing Project
TYPE TripActionsRec  IS RECORD(
status_code	        WSH_TRIPS.STATUS_CODE%TYPE,
planned_flag	        WSH_TRIPS.PLANNED_FLAG%TYPE,
load_tender_status      WSH_TRIPS.LOAD_TENDER_STATUS%TYPE,
message_name            VARCHAR2(2000),
caller		        VARCHAR2(100),
action_not_allowed	VARCHAR2(100),
shipments_type_flag     VARCHAR2(30),
ignore_for_planning     WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE); -- OTM R12, glog proj

TYPE TripActionsTabType IS TABLE of  TripActionsRec  INDEX BY BINARY_INTEGER;

TYPE trip_rec_type IS RECORD(
trip_id	             NUMBER,
organization_id      NUMBER,
status_code	     VARCHAR2(32000),
planned_flag	     VARCHAR2(32000),
load_tender_status   VARCHAR2(32000),
lane_id              NUMBER,
shipments_type_flag  VARCHAR2(30),
ignore_for_planning  WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE); -- OTM R12, glog proj

TYPE trip_rec_tab_type IS TABLE OF trip_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE Is_Action_Enabled(
		p_trip_rec_tab		IN	trip_rec_tab_type,
		p_action		IN	VARCHAR2,
		p_caller		IN	VARCHAR2,
		x_return_status		OUT	NOCOPY VARCHAR2,
		x_valid_ids		OUT 	NOCOPY wsh_util_core.id_tab_type,
		x_error_ids		OUT 	NOCOPY wsh_util_core.id_tab_type,
		x_valid_index_tab	OUT	NOCOPY wsh_util_core.id_tab_type);


PROCEDURE Validate_Arrive_after_trip(
  p_trip_id                   IN              NUMBER,
  p_arr_after_trip_id         IN OUT          NOCOPY   NUMBER,
  p_arr_after_trip_name       IN              VARCHAR2,
  x_return_status            OUT              NOCOPY VARCHAR2
);

PROCEDURE Validate_Consol_Allowed(
  p_trip_info                   IN      WSH_TRIPS_PVT.trip_rec_type,
  p_db_trip_info                IN      WSH_TRIPS_PVT.trip_rec_type,
  x_return_status            	OUT     NOCOPY VARCHAR2);

--
-- Overloaded procedure
--
PROCEDURE Get_Disabled_List  (
  p_trip_rec          IN  WSH_TRIPS_PVT.trip_rec_type
, p_in_rec	      IN  WSH_TRIPS_GRP.TripInRecType
, x_return_status     OUT NOCOPY VARCHAR2
, x_msg_count         OUT NOCOPY NUMBER
, x_msg_data          OUT NOCOPY VARCHAR2
, x_trip_rec          OUT NOCOPY WSH_TRIPS_PVT.trip_rec_type
);


PROCEDURE Init_Trip_Actions_Tbl (
  p_action                   IN                VARCHAR2
, x_Trip_actions_tab         OUT   NOCOPY            TripActionsTabType
, x_return_status            OUT   NOCOPY            VARCHAR2
);

--Harmonizing Project

--anxsharm for Load Tender Project
/*
-----------------------------------------------------------------------------
   PROCEDURE  : Get Trip Calc Wtvol
   PARAMETERS : p_tab_id - entity id
                p_entity - entity name -DELIVERY,TRIP,TRIP_STOP,DELIVERY_DETAIL
                p_action_code - action code for each action
                p_phase - 1 for Before the action is performed, 2 for after.
                x_trip_id_tab - Table of Trip ids
                x_return_status - Return Status
  DESCRIPTION : This procedure finds the trip for each entity on the basis
                of p_entity.After the trip is determined, calculate the
                weight/volume for the trip.
------------------------------------------------------------------------------
*/

PROCEDURE Get_Trip_Calc_Wtvol
  (p_tab_id      IN wsh_util_core.id_tab_type,
   p_entity      IN VARCHAR2,
   p_action_code IN VARCHAR2,
   p_phase       IN NUMBER,
   x_trip_id_tab IN OUT NOCOPY wsh_util_core.id_tab_type,
   x_return_status OUT NOCOPY VARCHAR2
   );

--End for Load Tender Project

-- J-IB-NPARIKH-{
--
TYPE ChgStatus_in_rec_type
IS RECORD
    (
      trip_id               NUMBER,
      name                  VARCHAR2(30),
      new_status_code       VARCHAR2(30),
      put_messages          BOOLEAN DEFAULT TRUE,
      manual_flag           VARCHAR2(10),
      caller                VARCHAR2(32767),
      actual_date           DATE,
      stop_id               NUMBER,
      linked_stop_id        NUMBER
    );
--
--
PROCEDURE check_Close
            (
               p_in_rec             IN         ChgStatus_in_rec_type,
               x_return_status      OUT NOCOPY VARCHAR2,
               x_allowed            OUT NOCOPY VARCHAR2
            ) ;
--
--
PROCEDURE check_inTransit
            (
               p_in_rec             IN         ChgStatus_in_rec_type,
               x_return_status      OUT NOCOPY VARCHAR2,
               x_allowed            OUT NOCOPY VARCHAR2
            ) ;
--
FUNCTION has_outbound_deliveries
    (
      p_trip_id       IN            NUMBER,
      p_stop_id       IN            NUMBER DEFAULT NULL
    )
RETURN VARCHAR2;
--
FUNCTION has_inbound_deliveries
    (
      p_trip_id       IN            NUMBER,
      p_stop_id       IN            NUMBER DEFAULT NULL
    )
RETURN VARCHAR2;
--
FUNCTION has_mixed_deliveries
    (
      p_trip_id       IN            NUMBER,
      p_stop_id       IN            NUMBER DEFAULT NULL
    )
RETURN VARCHAR2;
--
PROCEDURE Validate_Trip_status
    (
      p_trip_id       IN            NUMBER,
      p_action        IN            VARCHAR2,
      x_return_status OUT NOCOPY    VARCHAR2
    );
--
-- J-IB-NPARIKH-}
--

-- bug 3516052
PROCEDURE Validate_Stop_Dates
    (
      p_trip_id       IN            NUMBER,
      x_return_status OUT NOCOPY    VARCHAR2,
      p_caller        IN      VARCHAR2 DEFAULT NULL
    );

END WSH_TRIP_VALIDATIONS;

/
