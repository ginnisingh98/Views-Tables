--------------------------------------------------------
--  DDL for Package WSH_DELIVERY_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DELIVERY_VALIDATIONS" AUTHID CURRENT_USER as
/* $Header: WSHDEVLS.pls 120.3.12010000.2 2009/12/03 15:13:53 gbhargav ship $ */
--<TPA_PUBLIC_NAME=WSH_TPA_DELIVERY_PKG>
--<TPA_PUBLIC_FILE_NAME=WSHTPDE>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Ship_Set
-- Parameters:    delivery_id, x_return_status
-- Description:   Checks if Ship Set is together and returns x_valid_flag
--                TRUE - if Ship Set is together
--                FALSE - if Ship Set is not together
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Ship_Set( p_delivery_id IN NUMBER,
					 x_valid_flag  OUT NOCOPY  BOOLEAN,
					 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Smc
-- Parameters:    delivery_id, x_return_status
-- Description:   Checks if Ship Model is complete and returns x_valid_flag
--                TRUE - if Ship Model is complete
--                FALSE - if Ship Model is not complete
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Smc( p_delivery_id IN NUMBER,
				 x_valid_flag  OUT NOCOPY  BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Arrival_Set
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks if Arrival set is complete and returns a valid_flag
--                TRUE - if Arrival Set is complete
--                FALSE - if Arrival Set is not complete
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Arrival_Set( p_delivery_id IN NUMBER,
				 x_valid_flag  OUT NOCOPY  BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Not_I_T
-- Parameters:    p_delivery_id, delivery_status, x_return_status
-- Description:   Checks if delivery is In-transit status and sets a warning
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Del_Not_I_T( p_delivery_id IN NUMBER,
                     p_delivery_status IN VARCHAR2,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Released_Lines
-- Parameters:    p_delivery_id, rel_num, unrel_num, x_return_status
-- Description:   Checks if delivery has atleast one released and one unreleased lines and sets a warning
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Released_Lines( p_delivery_id IN NUMBER,
                     rel_num IN NUMBER,
                     unrel_num IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Unpacked
-- Parameters:    p_delivery_id, p_cont_exists_flag, p_unpacked_flag, x_return_status
-- Description:   Checks if delivery has containers and is unpacked and issues a warning
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Del_Unpacked( p_delivery_id IN NUMBER,
                     p_cont_exists_flag IN BOOLEAN,
                     p_unpacked_flag IN BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Overfilled
-- Parameters:    p_delivery_id, p_cont_exists_flag, p_unpacked_flag, x_return_status
-- Description:   Checks if delivery has containers and does not have overfilled containers and issues a warning
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Del_Overfilled( p_delivery_id IN NUMBER,
                     p_cont_exists_flag IN BOOLEAN,
                     p_overfilled_flag IN BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Underfilled
-- Parameters:    p_delivery_id, p_cont_exists_flag, p_underfilled_flag, x_return_status
-- Description:   Checks if delivery has containers and does not have under filled containers and issues a warning
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Del_Underfilled( p_delivery_id IN NUMBER,
                     p_cont_exists_flag IN BOOLEAN,
                     p_underfilled_flag IN BOOLEAN,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Del_Final_Dest
-- Parameters:    p_delivery_id, p_final_dropoff_id, p_ultimate_dropoff_id, x_return_status
-- Description:   Checks if delivery final destination matches ultimate dropoff destination and returns a warning if it does not
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.deliveryTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Del_Final_Dest( p_delivery_id IN NUMBER,
                     p_final_dropoff_id IN NUMBER,
                     p_ultimate_dropoff_id IN NUMBER,
				 x_return_status OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DELIVERYTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Calendar
-- Parameters:    p_entity_type, p_ship_date, p_ship_assoc_type, p_ship_location_id,
--                p_freight_code, p_freight_org_id,
--			   p_receive_date, p_receive_assoc_type, p_receive_location_id,
--			   x_return_status
-- Description:   Checks if p_ship_date and p_rec_date are valid for the calendar
--                at location p_location_id
--                Values for p_entity_type are
--                    DELIVERY
--                Values for p_assoc_type are
--                    CUSTOMER
--                    VENDOR
--                    ORG
--                    CARRIER
-- FOR TPA SELECTOR USE: wsh_tpa_selector_pkg.defaultTP
--
-----------------------------------------------------------------------------

PROCEDURE Check_Calendar ( p_entity_type     		IN  VARCHAR2,
                           p_entity_id                 IN  NUMBER,
					  p_ship_date               	IN  DATE,
					  p_ship_assoc_type         	IN  VARCHAR2,
					  p_ship_location_id     	IN  NUMBER,
					  p_freight_code       		IN  VARCHAR2,
					  p_freight_org_id     		IN  NUMBER,
					  p_receive_date              IN  DATE,
					  p_receive_assoc_type        IN  VARCHAR2,
					  p_receive_location_id       IN  NUMBER,
					  p_update_flag               IN  VARCHAR2,
					  x_return_status			OUT NOCOPY  VARCHAR2);
--<TPA_PUBLIC_NAME>
--<TPA_DEFAULT_TPS=WSH_TPA_SELECTOR_PKG.DEFAULTTP>

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Plan
-- Parameters:    delivery_id, x_return_status
-- Description:   Checks for Plan action pre-requisites which are
--          - Delivery status is OPEN or PACKED
-- 		  - At least one delivery detail is assigned
--		  - SMC models must be together [warning]
--		  - Ship Sets must be complete [warning]
--                - Delivery flow on trip/s is valid [error/warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Plan ( p_delivery_id 		IN  NUMBER,
		       x_return_status 		OUT NOCOPY  VARCHAR2,
                       p_called_for_sc          IN BOOLEAN default false);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Unplan
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Unplan action pre-requisites which are
-- 		  - Delivery status is OPEN or IN-TRANSIT
--                - Delivery is planned
--
-----------------------------------------------------------------------------

PROCEDURE Check_Unplan ( p_delivery_id 		IN  NUMBER,
		         x_return_status 	OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Tender_Load
-- Parameters:    p_delivery_leg_id, x_return_status
-- Description:   Checks for Tender Load action pre-requisites which are
-- 		  - Satisfies rules for Plan
--                - Weight/Volume information must be specified
--
-----------------------------------------------------------------------------

PROCEDURE Check_Tender_Load ( p_delivery_leg_id IN  NUMBER,
		             x_return_status 	OUT NOCOPY  VARCHAR2);




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Assign_Trip
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Assign Trip action pre-requisites which are
-- 		  - Delivery status is not CLOSED
--		  - Trip status is not CLOSED
--                - Pickup Stop status is OPEN or ARRIVED
--                - Pickup Stop sequence number is smaller than Dropoff Stop sequence number
--                - If GROUP_BY_CARRIER_FLAG set then freight carrier same as that on trip [warning]
--                - Delivery status is not IN-TRANSIT [warning]
--                - If trip is Planned and has Vehicle information then no stops on the trip are over filled by addition of this delivery [warning]

--
-----------------------------------------------------------------------------

PROCEDURE Check_Assign_Trip ( p_delivery_id     IN  NUMBER,
			      p_trip_id 	IN  NUMBER,
			      p_pickup_stop_id 	IN NUMBER,
		       	      p_dropoff_stop_id IN NUMBER,
		              x_return_status 	OUT NOCOPY  VARCHAR2);



/******* Commented this out for bug 2554849
-----------------------------------------------------------------------------
--
-- Procedure:     Check_Unassign_Trip
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Unassign Trip action pre-requisites which are
-- 		  - Delivery status is not CLOSED
--		  - Trip status is not CLOSED
--                - Delivery status is not IN-TRANSIT [warning]
--                - If trip is Planned and has Vehicle information then no stops on the trip are under filled by removal of this delivery [warning]
--                - No Bill of Lading is assigned to this delivery for this trip [warning] NOTE: this warning will inform the user that all Bill of Ladings will be deleted.
--
-----------------------------------------------------------------------------

PROCEDURE Check_Unassign_Trip ( p_delivery_id   IN  NUMBER,
			      	p_trip_id 	IN  NUMBER,
		              	x_return_status OUT NOCOPY  VARCHAR2);
********** */




-----------------------------------------------------------------------------
--
-- Procedure:     Check_Pack
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Pack action pre-requisites which are
--		  - Delivery status is OPEN
--                - All items being shipped on this delivery are packed in containers
--                - Details (shipped quantity, inventory controls ) must be specified for all delivery lines
--                - If containers are assigned to the delivery then they are not over/under packed [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Pack ( p_delivery_id 		IN  NUMBER,
		       x_return_status 		OUT NOCOPY  VARCHAR2);



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Confirm
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Confirm action pre-requisites which are
--		  - Delivery Status is OPEN or PACKED
--                - Details (shipped quantity, inventory controls ) must be specified for all delivery details (lines)
--                - At least one delivery detail (line) is released
--                - All delivery details (lines) are released [warning]
--                - If delivery status is OPEN and containers are assigned to this delivery then all items being shipped on this delivery are packed [warning]
--                - If delivery status is OPEN then containers for this delivery are not over/under packed [warning]
--                - SMC models must be together [warning]
--                - Ship Sets must be complete [warning]
--                - Delivery flow on trip/s is valid [error/warning]
--
-----------------------------------------------------------------------------


PROCEDURE Check_Confirm ( p_delivery_id 	IN  NUMBER,
                          p_cont_exists_flag     IN  BOOLEAN,
                          p_enforce_packing_flag IN  VARCHAR2,
                          p_overfilled_flag      IN  BOOLEAN,
                          p_underfilled_flag     IN  BOOLEAN,
			  p_ship_from_location   IN NUMBER ,
			  p_ship_to_location     IN NUMBER ,
			  p_freight_code         IN VARCHAR2 ,
			  p_organization_id      IN NUMBER  ,
			  p_initial_pickup_date   IN DATE ,
			  p_ultimate_dropoff_date IN DATE ,
			  p_actual_dep_date 	  IN DATE ,
		          x_return_status 	OUT NOCOPY  VARCHAR2) ;

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Reopen
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Reopen action pre-requisites which are
--		  - Delivery status is PACKED or CONFIRMED
--
-----------------------------------------------------------------------------

PROCEDURE Check_Reopen ( p_delivery_id 		IN  NUMBER,
		         x_return_status 	OUT NOCOPY  VARCHAR2);



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Intransit
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Reopen action pre-requisites which are
--		  - Delivery status is CONFIRMED
--                - First pickup stop status is CLOSED
--
-----------------------------------------------------------------------------

PROCEDURE Check_Intransit ( p_delivery_id 	IN  NUMBER,
		            x_return_status 	OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Close
-- Parameters:    p_delivery_id = delivery being closed
--                p_manual_flag = 'Y' if user invokes the UI action Close Del.
--                                'N' if its drop-off stop is being closed
--		  p_old_status_code = delivery's original status_code
--                x_return_status = SUCCESS -> can close,
--                                  ERROR -> cannot close
--
-- Description:   Checks for Close action pre-requisites which are
--                - POD has been received
--                - If POD not received then last drop-off stop status is ARRIVED or CLOSED
--		  If manually closing, the pre-requisite is either:
--                - Delivery is open with no details or legs assigned.
--                - Delivery is IN TRANSIT and owns all stops still open.
--
-----------------------------------------------------------------------------

PROCEDURE Check_Close ( p_delivery_id 		IN  NUMBER,
			p_manual_flag		IN  VARCHAR2,
			p_old_status_code	IN  VARCHAR2,
		        x_return_status 	OUT NOCOPY  VARCHAR2);



-----------------------------------------------------------------------------
--
-- Procedure:     Check_Delete_Delivery
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Delete Delivery action pre-requisites which are
--                - Delivery status is OPEN
--                - No freight costs assigned to delivery [warning]
--                - No Bill of Ladings assigned to delivery [warning]
--                - No delivery details assigned to this delivery [warning]
--
-----------------------------------------------------------------------------

PROCEDURE Check_Delete_Delivery ( p_delivery_id   	IN  NUMBER,
		        	  x_return_status 	OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------------
--
-- Procedure:     Check_Change_Carrier
-- Parameters:    p_delivery_id, x_return_status
-- Description:   Checks for Change Carrier action pre-requisites which are
--                - Delivery status is OPEN
--                - If GROUP_BY_CARRIER_FLAG is set then delivery details do not have a Ship Method specified
--
-----------------------------------------------------------------------------

PROCEDURE Check_Change_Carrier ( p_delivery_id 		IN  NUMBER,
		        	 x_return_status 	OUT NOCOPY  VARCHAR2);

-----------------------------------------------------------------------------


-- This procedure added for bug 2074768
--
-- Procedure:     Check_Delivery_for_tolerances
-- Parameters:    p_delivery_id, x_source_line_id , x_source_code , x_max_quantity , x_return_status
-- Description:   Checks for Confirm shipped_quantities in a delivery's lines

-- History    :   HW OPM added x_max_quantity2 for OPM
-----------------------------------------------------------------------------
PROCEDURE Check_Delivery_for_tolerances ( p_delivery_id 	   IN  NUMBER,
                                          x_source_line_id        OUT NOCOPY   NUMBER,
                                          x_source_code           OUT NOCOPY   VARCHAR,
					  x_max_quantity          OUT NOCOPY   NUMBER,
					  x_max_quantity2         OUT NOCOPY  NUMBER,
	                                  x_return_status OUT NOCOPY  VARCHAR2 );

-----------------------------------------------------------------------------
--
-- Procedure:     Check_Detail_for_Confirm
-- Parameters:    p_detail_id, p_check_credit_init_flag, x_line_inv_flag_rec, x_return_status
-- Description:   Checks for Confirm action pre-requisites which are
--                Check for inventory controls
--                Check for credit and holds
-- NOT YET IMPLEMENTED Check for exceptions
--
-----------------------------------------------------------------------------
PROCEDURE Check_Detail_for_Confirm ( p_detail_id 	   IN  NUMBER,
                                     p_check_credit_init_flag  IN  BOOLEAN, -- bug 2343058
                                     x_line_inv_flag_rec   OUT NOCOPY  wsh_delivery_details_inv.inv_control_flag_rec,
	                             x_return_status OUT NOCOPY  VARCHAR2);


--
--  Procedure:    Get_Disabled_List
--
--  Parameters:   p_delivery_id -- delivery the detail is assigned to
--                p_list_type -- 'FORM', will return list of form field names
--                                 'TABLE', will return list of table column
--								names
--                x_return_status  -- return status for execution of this API
-- 			   x_disabled_list  -- the disabled columns/fields in a trip
--                x_msg_count -- number of error message
--                x_msg_data  -- error message if API failed
--

PROCEDURE Get_Disabled_List(
  p_delivery_id          	IN   NUMBER
, p_list_type           	IN   VARCHAR2
, x_return_status        	OUT NOCOPY   VARCHAR2
, x_disabled_list        	OUT NOCOPY   wsh_util_core.column_tab_type
, x_msg_count           	OUT NOCOPY   NUMBER
, x_msg_data            	OUT NOCOPY   VARCHAR2
, p_caller IN VARCHAR2 DEFAULT NULL --public api changes
);

-----------------------------------------------------------------------------
--
-- Function:      Check_SS_Imp_Pending
-- Parameters:    p_source_code,
--                p_source_header_id, p_ship_set_id, p_check_transactable,
--                x_return_status
--                  p_check_transactable: If p_check_transactable is Y then
--                                          check whether any transactable
--                                          line is not imported
--                                        else
--                                          check whether any line is not imported
-- Description:   Checks if any lines in the ship set are not yet imported
--                FALSE - All lines are imported into shipping
--                TRUE  - Some lines are not imported into shipping
--
-----------------------------------------------------------------------------
FUNCTION Check_SS_Imp_Pending(
  p_source_code                 IN   VARCHAR2
, p_source_header_id            IN   NUMBER
, p_ship_set_id                 IN   NUMBER
, p_check_transactable          IN   VARCHAR2
, x_return_status               OUT NOCOPY   VARCHAR2
) return BOOLEAN;

----------------------------------------------------------------------------
--
-- FUNCTION: Del_Assigned_To_Trip
--
-- PARAMETERS: p_delivery_id
--
-- DESCRIPTION: Returns 'Y' if delivery is assigned to a trip
--
-------------------------------------------------------------------------------

FUNCTION Del_Assigned_To_Trip(
  p_delivery_id                IN   NUMBER,
  x_return_status              OUT NOCOPY   VARCHAR2
) RETURN VARCHAR2;


--Harmonizing Project
TYPE DeliveryActionsRec  IS RECORD(
status_code         wsh_new_deliveries.status_code%TYPE,
planned_flag        wsh_new_deliveries.planned_flag%TYPE,
caller		    VARCHAR2(100),
action_not_allowed  VARCHAR2(100),
org_type            VARCHAR2(30),
message_name        VARCHAR2(2000),
shipment_direction  VARCHAR2(30),
--OTM R12
ignore_for_planning WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE,
tms_interface_flag  WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE,
otm_enabled WSH_SHIPPING_PARAMETERS.OTM_ENABLED%TYPE   -- OTM R12 - Bug#5399341
--
);
-- A Column called message_name has been added to the record
-- "DeliveryActionsRec" so that we can set the exact message
-- for each record as to why an action is not valid.
-- The message_name will contain the message short name
-- and appended with its respective tokens with
-- "-" as a separator between the message name and the
-- tokens and a "," seperator between each of
-- the tokens.

TYPE DeliveryActionsTabType IS TABLE of  DeliveryActionsRec  INDEX BY BINARY_INTEGER;

TYPE dlvy_rec_type IS RECORD(
delivery_id		NUMBER,
organization_id 	NUMBER,
status_code		VARCHAR2(32000),
planned_flag		VARCHAR2(32000),
shipment_direction      VARCHAR2(30),
delivery_type           VARCHAR2(30),
--OTM R12
ignore_for_planning     WSH_NEW_DELIVERIES.IGNORE_FOR_PLANNING%TYPE,
tms_interface_flag      WSH_NEW_DELIVERIES.TMS_INTERFACE_FLAG%TYPE,
otm_enabled    WSH_SHIPPING_PARAMETERS.OTM_ENABLED%TYPE,   -- OTM R12 - Bug#539934a
client_id               NUMBER  --- LSP PROJECT
--
);

TYPE dlvy_rec_tab_type IS TABLE OF dlvy_rec_type INDEX BY BINARY_INTEGER;

--OTM R12
TYPE trip_info_rec_type IS RECORD(
trip_id           WSH_TRIPS.TRIP_ID%TYPE,
name              WSH_TRIPS.NAME%TYPE,
status_code       WSH_TRIPS.STATUS_CODE%TYPE
);

TYPE trip_info_tab_type IS TABLE OF trip_info_rec_type INDEX BY BINARY_INTEGER;
--

PROCEDURE Is_Action_Enabled(
		p_dlvy_rec_tab		IN	dlvy_rec_tab_type,
		p_action		IN	VARCHAR2,
		p_caller		IN	VARCHAR2,
                p_tripid                IN      NUMBER DEFAULT null,
		x_return_status		OUT NOCOPY 	VARCHAR2,
		x_valid_ids		OUT NOCOPY  	wsh_util_core.id_tab_type,
		x_error_ids		OUT NOCOPY  	wsh_util_core.id_tab_type,
		x_valid_index_tab      	OUT NOCOPY 	wsh_util_core.id_tab_type);


--
-- Overloaded procedure
--
PROCEDURE Get_Disabled_List  (
  p_delivery_rec          IN  WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
, p_in_rec		  IN  WSH_DELIVERIES_GRP.Del_In_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_delivery_rec          OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type
);

PROCEDURE Init_Delivery_Actions_Tbl (
  p_action                   IN                VARCHAR2
, x_delivery_actions_tab     OUT    NOCOPY           DeliveryActionsTabType
, x_return_status            OUT    NOCOPY           VARCHAR2
);

PROCEDURE Derive_Delivery_Uom (
  p_delivery_id         IN  NUMBER,
  p_organization_id     IN  NUMBER,
  x_volume_uom_code     IN OUT NOCOPY VARCHAR2,
  x_weight_uom_code     IN OUT NOCOPY VARCHAR2,
  x_wt_nullify_flag     OUT NOCOPY BOOLEAN,
  x_vol_nullify_flag    OUT NOCOPY BOOLEAN,
  x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Routed_Export_Txn(
  x_rtd_expt_txn_code IN OUT NOCOPY VARCHAR2,
  p_rtd_expt_txn_meaning IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Derive_Number_Of_LPN(
  p_delivery_id    IN NUMBER,
  x_number_of_lpn  IN OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2);

--Harmonizing Project

PROCEDURE Chk_Dup_Pickup_Dropoff_Locns(
  p_delivery_id  IN NUMBER,
  p_pickup_location_id IN NUMBER,
  p_dropoff_location_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2);



FUNCTION Check_ITM_Required( p_delivery_id IN NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

-- PROCEDURE:   Log_ITM_Exception (Pack J: ITM integration)
-- DESCRIPTION: If the delivery need to be marked for ITM screening, log an
--              exception against the delivery.
-- PARAMETERS:  p_delivery_id - delivery that needs to be checked for ITM.
--              p_location_id - ship from location of delivery, required when
--                              loggin exceptions.
--              p_action_type - Whether the check is made at 'SHIP_CONFIRM'
--                              time or at 'CREATION' of delivery.

PROCEDURE Log_ITM_Exception(p_delivery_id in NUMBER,
                            p_ship_from_location_id in NUMBER,
                            p_action_type in VARCHAR2,
                            x_return_status out nocopy VARCHAR2);



TYPE exception_rec_type IS RECORD (
delivery_id NUMBER,
severity    VARCHAR2(30),
exception_id NUMBER);

TYPE exception_rec_tab_type is table of exception_rec_type index by binary_integer;


PROCEDURE check_exception(
  p_deliveries_tab           IN    wsh_util_core.id_tab_type
, x_exceptions_exist          OUT NOCOPY  VARCHAR2
, x_exceptions_tab           OUT NOCOPY  wsh_delivery_validations.exception_rec_tab_type
, x_return_status            OUT NOCOPY  VARCHAR2);


-- J-IB-NPARIKH-{
--
--
-- ----------------------------------------------------------------------
-- Procedure:   has_lines
-- Parameters:  p_delivery_id in  number
--              returns varchar2
--                  'Y' -- Has non-container lines
--                  'N' -- Does not have any non-container lines
-- Description: Checks if delivery has any non-container lines
--  ----------------------------------------------------------------------
FUNCTION has_lines
            (
               p_delivery_id      IN              NUMBER
            )
RETURN VARCHAR2;
--
--
--
-- This record type is used by following APIs
-- check_close, check_inTransit and
-- WSH_NEW_DELIVERY_ACTIONS.setInTransit, WSH_NEW_DELIVERY_ACTIONS.setClose
--
TYPE ChgStatus_in_rec_type
IS RECORD
    (
      delivery_id           NUMBER,
      name                  VARCHAR2(30),
      status_code           VARCHAR2(30), --Delivery's current status (DB Value)
      put_messages          BOOLEAN DEFAULT TRUE,
						-- Put error/warning messages on stack during check_close/check_inTransit
      -- FALSE means do not put error messages on stack
      -- can be used by callers who just want to check whether a delivery's
      -- status can be changed or not.
      --
						--
      manual_flag           VARCHAR2(10),
						-- 'Y', if called from UI as part of delivery close action
						-- 'N', if called from stop close action
						--
						--
      caller                VARCHAR2(32767),
      actual_date           DATE, -- Stop close date
      stop_id               NUMBER -- Stop being closed
    );
--
--
PROCEDURE Check_Close
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
PROCEDURE get_shipping_control
            (
               p_delivery_id            IN         NUMBER,
               x_shipping_control       OUT NOCOPY VARCHAR2,
               x_routing_response_id    OUT NOCOPY NUMBER,
               x_routing_request_flag   OUT NOCOPY VARCHAR2,
               x_return_status          OUT NOCOPY VARCHAR2
            );
--
-- J-IB-NPARIKH-}

--Function added for Bugfix 3562492
--========================================================================
-- FUNCTION : Is_del_eligible_pick
--
-- PARAMETERS:
--             x_return_status         return status
--             p_delivery_id             Delivery ID
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : This Function checks whether a Delivery id is eligible for Pick Release
--             , if a Delivery is eligible it returns TRUE else it returns FALSE.
--             The return status of this Function is always Success except in case
--             of unexpected error.
--========================================================================
FUNCTION  Is_del_eligible_pick(
                      p_delivery_id  IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

--OTM R12
PROCEDURE get_trip_information
(p_delivery_id        IN         NUMBER,
 x_trip_info_rec      OUT NOCOPY TRIP_INFO_REC_TYPE,
 x_return_status      OUT NOCOPY VARCHAR2
);

PROCEDURE GET_DELIVERY_INFORMATION
(p_delivery_id   IN         NUMBER,
 x_delivery_rec  OUT NOCOPY WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type,
 x_return_status OUT NOCOPY VARCHAR2);
--END OTM R12

END WSH_DELIVERY_VALIDATIONS;

/
