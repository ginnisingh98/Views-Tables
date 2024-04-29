--------------------------------------------------------
--  DDL for Package WSH_TRIP_STOPS_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRIP_STOPS_VALIDATIONS" AUTHID CURRENT_USER as
/* $Header: WSHSTVLS.pls 120.0.12000000.1 2007/01/16 05:50:53 appldev ship $ */

--Harmonizing Project
TYPE StopActionsRec  IS RECORD(
status_code	wsh_trip_stops.status_code%TYPE,
caller		VARCHAR2(100),
action_not_allowed	VARCHAR2(100),
shipments_type_flag     VARCHAR2(30));  -- J Inbound Logistics jckwok

TYPE StopActionsTabType IS TABLE of  StopActionsRec  INDEX BY BINARY_INTEGER;

TYPE stop_rec_type IS RECORD(
stop_id		NUMBER,
organization_id NUMBER,
status_code	VARCHAR2(32000),
shipments_type_flag     VARCHAR2(30));  -- J Inbound Logistics jckwok

TYPE stop_rec_tab_type IS TABLE OF stop_rec_type INDEX BY BINARY_INTEGER;
--Harmonizing Project

/*
 For every New stop entered or Updated
1. Check if stop sequence number is positive integer
2. Check if stop status is OPEN
3. Check if there is any existing stop on the trip with identical stop sequence
   number
4. Check if the new planned arrival date is greater than the planned arrival date of
   arrived or closed stop
*/
TYPE stop_details IS RECORD(
  stop_id         NUMBER,
  trip_id         NUMBER,
  status_code     VARCHAR2(1),
  stop_sequence_number NUMBER,
  planned_arrival_date DATE,
  planned_departure_date DATE,
  physical_location_id NUMBER,
  physical_stop_id     NUMBER
  );

TYPE stop_details_tab IS TABLE OF stop_details INDEX BY BINARY_INTEGER;

TYPE dleg_details IS RECORD(
  pick_up_stop_id         NUMBER,
  drop_off_stop_id        NUMBER,
  delivery_id             NUMBER
  );

TYPE dleg_details_tab IS TABLE OF dleg_details INDEX BY BINARY_INTEGER;

PROCEDURE validate_sequence_number
  (p_stop_id IN NUMBER,
   p_stop_sequence_number IN NUMBER,
   p_trip_id IN NUMBER,
   p_status_code IN VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE validate_closed_stop_seq
    (p_trip_id IN NUMBER ,
     p_stop_sequence_number IN NUMBER,
     x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE validate_unique_sequence
    (p_trip_id IN NUMBER ,
     p_stop_id IN NUMBER ,
     p_stop_sequence_number IN NUMBER,
     x_return_status OUT NOCOPY  VARCHAR2);


PROCEDURE check_for_negative_number
  (p_stop_sequence_number IN NUMBER,
   x_return_status OUT NOCOPY  VARCHAR2) ;

PROCEDURE validate_stop_status
  (p_stop_status IN VARCHAR2,
   x_return_status OUT NOCOPY  VARCHAR2) ;

PROCEDURE valid_delivery_on_trip
     (p_stop_id IN NUMBER,
      p_trip_id IN NUMBER,
      p_stop_sequence_number IN NUMBER,
      x_del_to_unassign OUT NOCOPY  WSH_UTIL_CORE.ID_TAB_TYPE,
      x_return_status OUT NOCOPY  VARCHAR2);

PROCEDURE get_new_sequence_number
  (x_stop_sequence_number IN OUT NOCOPY  NUMBER,
   p_trip_id              IN NUMBER,
   p_status_code          IN VARCHAR2,
   p_stop_id              IN NUMBER,
   p_new_flag             IN VARCHAR2,
   x_return_status        OUT NOCOPY  VARCHAR2);


--Harmonizing Project
PROCEDURE Is_Action_Enabled(
		p_stop_rec_tab		IN      stop_rec_tab_type,
		p_action		IN	VARCHAR2,
		p_caller		IN	VARCHAR2,
		x_return_status		OUT NOCOPY 	VARCHAR2,
		x_valid_ids		OUT NOCOPY  	wsh_util_core.id_tab_type,
		x_error_ids		OUT NOCOPY  	wsh_util_core.id_tab_type,
		x_valid_index_tab 	OUT NOCOPY   	wsh_util_core.id_tab_type);


--
-- Bug 2678363 - Added p_in_rec as a parameter instead of p_action
--
PROCEDURE Get_Disabled_List  (
  p_stop_rec              IN  WSH_TRIP_STOPS_PVT.trip_stop_rec_type
, p_parent_entity_id      IN  NUMBER
, p_in_rec		  IN  WSH_TRIP_STOPS_GRP.stopInRecType
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_stop_rec              OUT NOCOPY WSH_TRIP_STOPS_PVT.trip_stop_rec_type
);


PROCEDURE Init_Stop_Actions_Tbl (
  p_action                   IN                VARCHAR2
, x_stop_actions_tab         OUT  NOCOPY             StopActionsTabType
, x_return_status            OUT  NOCOPY             VARCHAR2
);
--Harmonizing Project

-- J-IB-NPARIKH-{
--
-- 3 Record types added for stop close check API.
--
TYPE chkClose_in_rec_type
IS RECORD
    (
      stop_id               NUMBER,
      put_messages          BOOLEAN DEFAULT TRUE,
      -- FALSE means do not put error messages on stack
      -- can be used by callers who just want to check whether a stop
      -- can be closed or not.
      --
      --
      manual_flag           BOOLEAN DEFAULT TRUE,
      caller                VARCHAR2(32767),
      actual_date           DATE             -- Stop close date
    );
--
--
TYPE dlvy_rec_type
IS RECORD
    (
      id_tbl           wsh_util_core.id_tab_type,
      name_tbl         wsh_util_core.Column_Tab_Type,
      statusCode_tbl   wsh_util_core.Column_Tab_Type,
      orgId_tbl        wsh_util_core.id_tab_type
    );
--
--
TYPE chkclose_out_rec_type
IS RECORD
    (
      close_allowed              VARCHAR2(10),
      --  'Y' : Allowed
      --  'YW': Allowed with warnings
      --  'N' : Not Allowed
      --  'NW': Not Allowed with warnings
      --
      --
      stop_name                  VARCHAR2(60),
      stop_sequence_number       NUMBER,
      initial_pu_dlvy_recTbl     dlvy_rec_type,
      -- Deliveries starting from this stop, which can be set to in-transit.
      --
      initial_pu_err_dlvy_id_tbl wsh_util_core.id_tab_type,
      -- Deliveries starting from this stop, which cannot be set to in-transit.
      --
      ultimate_do_dlvy_recTbl    dlvy_rec_type,
      -- Deliveries ending at this stop, which can be closed.
      --
      trip_id                    NUMBER,
      trip_status_code           VARCHAR2(30),
      ship_method_code           VARCHAR2(30),
      carrier_id                 NUMBER,
      mode_of_transport          VARCHAR2(30),
      service_level              VARCHAR2(30),
      trip_new_status_code       VARCHAR2(30),
      -- new status code of trip, as result of stop closure
      --
      trip_seal_code             VARCHAR2(32767),
      trip_name                  VARCHAR2(30),
      linked_stop_id             NUMBER   --wr
    );

PROCEDURE refreshShipmentsTypeFlag
    (
      p_trip_id              IN            NUMBER,
      p_stop_id              IN            NUMBER,
      p_action               IN            VARCHAR2 DEFAULT 'ASSIGN',
      p_shipment_direction   IN            VARCHAR2 DEFAULT 'O',
      x_shipments_type_flag  IN OUT NOCOPY VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2
    ) ;


PROCEDURE get_stop_close_date
    (
        p_trip_id               IN          NUMBER,
        p_stop_id               IN          NUMBER,
        p_stop_sequence_number  IN          NUMBER,
        x_stop_close_date       OUT NOCOPY  DATE,
        x_return_status         OUT NOCOPY  VARCHAR2
    );

PROCEDURE Check_Stop_Close -----trvlb
            (
              p_in_rec                   IN          chkClose_in_rec_type,
              x_out_rec                  OUT NOCOPY  chkClose_out_rec_type,
              x_return_status            OUT NOCOPY  VARCHAR2
            ) ;

-- J-IB-NPARIKH-}


END WSH_TRIP_STOPS_VALIDATIONS;

 

/
