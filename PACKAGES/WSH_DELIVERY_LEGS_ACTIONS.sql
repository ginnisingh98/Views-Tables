--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_LEGS_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_LEGS_ACTIONS" AUTHID CURRENT_USER as
/* $Header: WSHDGACS.pls 120.0 2005/05/26 18:14:45 appldev noship $ */
/* H integration anxsharm added new parameters for assign deliveries
   of stop sequence number */
--
-- Procedure:       Assign Deliveries
-- Parameters:      p_del_rows
--                  p_trip_id
--                  p_pickup_stop_id
--                  p_pickup_stop_seq
--                  p_dropoff_stop_id
--                  p_dropoff_stop_seq
--                  p_create_flag
--                  x_return_status
-- Description:     Used to assign number of deliveries to either a trip
--                  or a pickup/dropoff stop creating delivery legs and
--                  where necessary trip stops
--                      p_del_rows     - Table of delivery ids
--                      p_trip_id      - Trip id for assignment
--                      p_pickup_stop_id - pickup stop id for assignment
--                      p_dropoff_stop_id - dropoff stop id for assignment
--                      p_pickup_location_id - pickup location id for assignment (overrides deliveries initial_pickup_location_id)
--                      p_dropoff_location_id - dropoff location id for assignment (overrides deliveries ultimate dropoff location id)
--                      p_create_flag  - Creates new trip stops if set to 'Y'
--                      x_leg_rows  - table of delivery leg ids for assignment
--                      x_return_status - Returns FND_API.G_RET_STS_[SUCCESS/ERROR/UNEXP_ERROR]
--

PROCEDURE Assign_Deliveries
    (p_del_rows     IN   wsh_util_core.id_tab_type,
     p_trip_id    IN  NUMBER := NULL,
     p_pickup_stop_id   IN   NUMBER := NULL,
     p_pickup_stop_seq  IN   NUMBER := NULL,
     p_dropoff_stop_id  IN   NUMBER := NULL,
     p_dropoff_stop_seq  IN   NUMBER := NULL,
     p_pickup_location_id IN NUMBER := NULL,
     p_dropoff_location_id IN NUMBER := NULL,
     p_create_flag    IN  VARCHAR2 := NULL,
     x_leg_rows     OUT NOCOPY  wsh_util_core.id_tab_type,
     x_return_status  OUT NOCOPY VARCHAR2,
--tkt
     p_caller           IN VARCHAR2 DEFAULT NULL,
     p_pickup_arr_date   	IN   	DATE := to_date(NULL),
     p_pickup_dep_date   	IN   	DATE := to_date(NULL),
     p_dropoff_arr_date  	IN   	DATE := to_date(NULL),
     p_dropoff_dep_date  	IN   	DATE := to_date(NULL),
     p_sc_pickup_date  	        IN      DATE   DEFAULT NULL,
     p_sc_dropoff_date   	IN      DATE   DEFAULT NULL
    );


--
--  Procedure:          Unassign_Deliveries
--  Parameters:         p_del_rows
--                      p_trip_id
--                      p_pickup_stop_id
--                      p_dropoff_stop_id
--                      x_return_status
--  Description:        This procedure will unassign deliveries from a
--                      trip or pickup/dropoff location. Same description as above for parameters
--
PROCEDURE Unassign_Deliveries
       (p_del_rows             IN   wsh_util_core.id_tab_type,
        p_trip_id              IN   NUMBER := NULL,
        p_pickup_stop_id    IN   NUMBER := NULL,
        p_dropoff_stop_id   IN   NUMBER := NULL,
        x_return_status        OUT NOCOPY VARCHAR2 );

--
-- Procedure: Set_Load_Tender
-- Parameters:  p_del_leg_rows   - Delivery_leg_id of delivery to perform
--                                    load tender action
--    p_action            - action to be performed
--    x_return_status     - status of procedure call
-- Description: This procedure will set the load_tender_flag based
--              on p_action values of
--                  TENDER  - sets load_tender_flag 'L'
--                  CANCEL  - sets load_tender_flag 'N'
--                  ACCEPT  - sets load_tender_flag 'A'
--                  REJECT  - sets load_tender_flag 'R'
--
-- COMMENTING OUT AS LOAD TENDER FUNCTIONALITY IS BEING TEMPORARILY REMOVED
/*
  PROCEDURE Set_Load_Tender
                         ( p_del_leg_rows   IN  wsh_util_core.id_tab_type,
             p_action            IN  VARCHAR2,
               x_return_status     OUT NOCOPY VARCHAR2);
*/

/*  H integration: Pricing integration csun
*/
--
-- Name        Mark_Reprice_Required
-- Purpose     This procedure will set REPRICE_REQUIRED_FLAG of
--             delivery leg record
--
-- Input Arguments
--       p_entity_type: entity type, valid values are
--                     'DELIVERY_DETAIL', 'DELIVERY', 'STOP', 'TRIP',
--                     'DELIVERY_LEG'
--       p_entity_id : the entity id of the entity type
--
  PROCEDURE Mark_Reprice_Required(
     p_entity_type           IN  VARCHAR2,
     p_entity_ids            IN  WSH_UTIL_CORE.id_tab_type,
     p_consolidation_change  IN  VARCHAR2 DEFAULT 'N',
     x_return_status         OUT NOCOPY VARCHAR2) ;


--
-- J-IB-NPARIKH-{

C_PICKUP_STOP       CONSTANT    VARCHAR2(30) := 'PICKUP';
C_DROPOFF_STOP       CONSTANT    VARCHAR2(30) := 'DROPOFF';
--

-- FUNCTION: Check_Rate_Delivery
-- PARAMETERS: p_delivery_id, p_freight_terms_code, p_shipment_direction
-- DESCRIPTION:  This API will take in a delivery id or the shipment direction and freight code
--               of a delivery. It will return values of 'Y' or 'N' depending on whether the delivery
--               needs to be rated  or does not need to be rated based on the global parameter values.


FUNCTION Check_Rate_Delivery (p_delivery_id IN NUMBER,
                              p_freight_terms_code VARCHAR2,
                              p_shipment_direction VARCHAR2,
                              x_return_status out nocopy VARCHAR2)
RETURN VARCHAR2;



END WSH_DELIVERY_LEGS_ACTIONS;


 

/
