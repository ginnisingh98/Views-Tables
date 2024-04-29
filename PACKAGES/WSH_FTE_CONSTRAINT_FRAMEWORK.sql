--------------------------------------------------------
--  DDL for Package WSH_FTE_CONSTRAINT_FRAMEWORK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FTE_CONSTRAINT_FRAMEWORK" AUTHID CURRENT_USER as
/* $Header: WSHFCFWS.pls 120.2 2006/02/01 06:15:20 jnpinto noship $ */

-- Global Variables

g_hash_base                  NUMBER := 1;
g_hash_size                  NUMBER := power(2, 25);
g_is_fte_installed           VARCHAR2(1) := WSH_UTIL_CORE.FTE_Is_Installed;
g_is_tp_installed            VARCHAR2(1) := NULL;
g_session_id                 NUMBER;

G_SHIPORG_FACILITY           VARCHAR2(30) := 'ORG_FAC';
G_SHIPORG_FACILITY_NUM       NUMBER := 101;
G_CUSTOMER_FACILITY          VARCHAR2(30) := 'CUS_FAC';
G_CUSTOMER_FACILITY_NUM      NUMBER := 102;
G_SUPPLIER_FACILITY          VARCHAR2(30) := 'SUP_FAC';
G_SUPPLIER_FACILITY_NUM      NUMBER := 103;
G_FACILITY_CARRIER           VARCHAR2(30) := 'FAC_CAR';
G_FACILITY_CARRIER_NUM       NUMBER := 104;
G_FACILITY_MODE              VARCHAR2(30) := 'FAC_MOD';
G_FACILITY_MODE_NUM          NUMBER := 105;
G_FACILITY_VEHICLE           VARCHAR2(30) := 'FAC_VEH';
G_FACILITY_VEHICLE_NUM       NUMBER := 106;
G_ITEM_FACILITY              VARCHAR2(30) := 'ITM_FAC';
G_ITEM_FACILITY_NUM          NUMBER := 107;
G_ITEMCAT_FACILITY           VARCHAR2(30) := 'ITC_FAC';
G_ITEMCAT_FACILITY_NUM       NUMBER := 108;
G_CUSTOMER_CUSTOMER          VARCHAR2(30) := 'CUS_CUS';
G_CUSTOMER_CUSTOMER_NUM      NUMBER := 109;
G_ITEM_MODE                  VARCHAR2(30) := 'ITM_MOD';
G_ITEM_MODE_NUM              NUMBER := 110;
G_ITEMCAT_MODE               VARCHAR2(30) := 'ITC_MOD';
G_ITEMCAT_MODE_NUM           NUMBER := 111;
G_ITEM_CARRIER               VARCHAR2(30) := 'ITM_CAR';
G_ITEM_CARRIER_NUM           NUMBER := 112;
G_ITEMCAT_CARRIER            VARCHAR2(30) := 'ITC_CAR';
G_ITEMCAT_CARRIER_NUM        NUMBER := 113;
G_ITEM_VEHICLE               VARCHAR2(30) := 'ITM_VEH';
G_ITEM_VEHICLE_NUM           NUMBER := 114;
G_ITEMCAT_VEHICLE            VARCHAR2(30) := 'ITC_VEH';
G_ITEMCAT_VEHICLE_NUM        NUMBER := 115;
G_ITEMCAT_ITEMCAT            VARCHAR2(30) := 'ITC_ITC';
G_ITEMCAT_ITEMCAT_NUM        NUMBER := 116;
G_ITEM_ITEM                  VARCHAR2(30) := 'ITM_ITM';
G_ITEM_ITEM_NUM              NUMBER := 117;
G_ITEM_ITEMCAT               VARCHAR2(30) := 'ITM_ITC';
G_ITEM_ITEMCAT_NUM           NUMBER := 118;

--#REG-ZON
G_REGION_FACILITY            VARCHAR2(30) := 'REG_FAC';
G_REGION_FACILITY_NUM	     NUMBER := 119;
--#REG-ZON

G_AUTOCRT_DLVY               VARCHAR2(30) := 'ACD';
G_ASSIGN_DLVB_DLVY           VARCHAR2(30) := 'ADD';
G_AUTOCRT_DLVY_TRIP          VARCHAR2(30) := 'ACT';
G_AUTOCRT_MDC                VARCHAR2(30) := 'ACM';
G_ASSIGN_DLVY_TRIP           VARCHAR2(30) := 'ADT';
G_UNASSIGN_DLVY_TRIP         VARCHAR2(30) := 'UDT';
G_PACK_DLVB                  VARCHAR2(30) := 'PKG';
G_CRT_TRIP_STOP              VARCHAR2(30) := 'CTS';
G_DLEG_LANE_SEARCH           VARCHAR2(30) := 'DLS';
G_DLEG_TRIP_SEARCH           VARCHAR2(30) := 'DST';
G_DLEG_CRT                   VARCHAR2(30) := 'CDL';
G_CREATE_DLVY                VARCHAR2(30) := 'CRD';
G_UPDATE_DLVY                VARCHAR2(30) := 'UPD';
G_UPDATE_DLEG                VARCHAR2(30) := 'UDL';
G_UPDATE_TRIP                VARCHAR2(30) := 'UPT';
G_UPDATE_STOP                VARCHAR2(30) := 'UPS';
G_DELETE_STOP                VARCHAR2(30) := 'DTS';

G_FACILITY                   VARCHAR2(30) := 'FAC';
G_COMP_ORG                   VARCHAR2(30) := 'ORG';
G_COMP_CUSTOMER              VARCHAR2(30) := 'CUS';
G_COMP_SUPPLIER              VARCHAR2(30) := 'SUP';
G_COMP_CARRIER               VARCHAR2(30) := 'CAR';

G_DELIVERY                   VARCHAR2(30) := 'DLVY';
G_DELIVERY_LEG               VARCHAR2(30) := 'DLEG';
G_TRIP                       VARCHAR2(30) := 'TRIP';
G_STOP                       VARCHAR2(30) := 'STOP';
G_DEL_DETAIL                 VARCHAR2(30) := 'DLVB';
G_CAR_SERVICE                VARCHAR2(30) := 'CRSV';
G_LANE                       VARCHAR2(30) := 'LANE';
G_LOCATION                   VARCHAR2(30) := 'LOCATION';
G_CALLING_API                VARCHAR2(60) := NULL;
 -- MDC Constraints
  TYPE  deconsol_output_rec_type IS RECORD (
	          deconsol_location NUMBER,
	          entity_id NUMBER,
	          validation_status VARCHAR2(1));

  TYPE deconsol_output_tab_type IS TABLE OF deconsol_output_rec_type INDEX BY BINARY_INTEGER;
-- MDC Constraints end

  TYPE comp_constraint_tab_type IS TABLE OF WSH_FTE_COMP_CONSTRAINTS%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE comp_class_tab_type IS TABLE OF WSH_FTE_COMP_CLASSES%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE line_constraint_rec_type IS RECORD (
       line_constraint_index                    NUMBER
     , entity_type                              VARCHAR2(30)
     , entity_line_id                           NUMBER
     , constraint_id                            NUMBER
     , constraint_class_code                    VARCHAR2(30)
     , violation_type                           VARCHAR2(1)
     );

  TYPE line_constraint_tab_type IS TABLE OF line_constraint_rec_type INDEX BY BINARY_INTEGER;

  -- Indexed by hash of comp_class code
  g_comp_class_tab           comp_class_tab_type;

  -- Indexed by hash of attributes that constitute a unique combination
  g_comp_constraint_tab      comp_constraint_tab_type;

  /* Following are entity based record structures
     to be used for constraint validations */

  TYPE detail_ccinfo_rec_type IS RECORD (
        DELIVERY_DETAIL_ID                     NUMBER
      , DELIVERY_ID                            NUMBER DEFAULT NULL
      , EXISTS_IN_DATABASE                     VARCHAR2(1)
      , CUSTOMER_ID                            NUMBER
      , INVENTORY_ITEM_ID                      NUMBER
      , SHIP_FROM_LOCATION_ID                  NUMBER
      , ORGANIZATION_ID                        NUMBER
      , SHIP_TO_LOCATION_ID                    NUMBER
      , INTMED_SHIP_TO_LOCATION_ID             NUMBER
      , RELEASED_STATUS                        VARCHAR2(1)
      , CONTAINER_FLAG                         VARCHAR2(1)
      , DATE_REQUESTED                         DATE
      , DATE_SCHEDULED                         DATE
      , SHIP_METHOD_CODE                       VARCHAR2(30)
      , CARRIER_ID                             NUMBER
      , PARTY_ID                               NUMBER
      , LINE_DIRECTION                         VARCHAR2(30)
      , SHIPPING_CONTROL                       VARCHAR2(30)
      --#DUM_LOC(S) Will be populated with PHYSICAL Location id
      --when Ship to location is dummy.
      , PHYSICAL_SHIP_TO_LOCATION_ID	       NUMBER DEFAULT NULL
      --#DUM_LOC(E)
      );


  TYPE detail_ccinfo_tab_type IS TABLE OF  detail_ccinfo_rec_type INDEX BY BINARY_INTEGER;

  TYPE delivery_ccinfo_rec_type IS RECORD (
        DELIVERY_ID                            NUMBER
      , TRIP_ID                                NUMBER DEFAULT NULL
      , EXISTS_IN_DATABASE                     VARCHAR2(1)
      , NAME                                   VARCHAR2(30)
      , PLANNED_FLAG                           VARCHAR2(1)
      , STATUS_CODE                            VARCHAR2(2)
      , INITIAL_PICKUP_DATE                    DATE
      , INITIAL_PICKUP_LOCATION_ID             NUMBER
      , ULTIMATE_DROPOFF_LOCATION_ID           NUMBER
      , ULTIMATE_DROPOFF_DATE                  DATE
      , CUSTOMER_ID                            NUMBER
      , INTMED_SHIP_TO_LOCATION_ID             NUMBER
      , SHIP_METHOD_CODE                       VARCHAR2(30)
      --alksharm
      , DELIVERY_TYPE                          VARCHAR2(30)
      , CARRIER_ID                             NUMBER
      , ORGANIZATION_ID                        NUMBER
      , SERVICE_LEVEL                          VARCHAR2(30)
      , MODE_OF_TRANSPORT                      VARCHAR2(30)
      , PARTY_ID                               NUMBER
      , SHIPMENT_DIRECTION                     VARCHAR2(30)
      , SHIPPING_CONTROL                       VARCHAR2(30)
      --#DUM_LOC(S) Will be populated with PHYSICAL location id
      --when drop off location id is dummy.
      , PHYSICAL_DROPOFF_LOCATION_ID	       NUMBER DEFAULT NULL
      --#DUM_LOC(E)
    );


  TYPE delivery_ccinfo_tab_type IS TABLE OF  delivery_ccinfo_rec_type INDEX BY BINARY_INTEGER;

  TYPE dleg_ccinfo_rec_type IS RECORD (
       DELIVERY_LEG_ID                         NUMBER
     , EXISTS_IN_DATABASE                      VARCHAR2(1)
     , DELIVERY_ID                             NUMBER
     , PARENT_DELIVERY_LEG_ID                  NUMBER
     , SEQUENCE_NUMBER                         NUMBER
     , CARRIER_ID                              NUMBER
     , SERVICE_LEVEL                           VARCHAR2(30)
     , MODE_OF_TRANSPORT                       VARCHAR2(30)
     , PICK_UP_STOP_ID                         NUMBER
     , DROP_OFF_STOP_ID                        NUMBER
     , PICKUPSTOP_LOCATION_ID                  NUMBER
     , DROPOFFSTOP_LOCATION_ID                 NUMBER
     , PICKUP_STOP_PA_DATE                     DATE
     , DROPOFF_STOP_PA_DATE                    DATE
     );

  TYPE dleg_ccinfo_tab_type IS TABLE OF  dleg_ccinfo_rec_type INDEX BY BINARY_INTEGER;

  TYPE trip_ccinfo_rec_type IS RECORD (
       TRIP_ID                                 NUMBER
     , EXISTS_IN_DATABASE                      VARCHAR2(1)
     , NAME                                    VARCHAR2(30)
     , PLANNED_FLAG                            VARCHAR2(1)
     , STATUS_CODE                             VARCHAR2(2)
     , VEHICLE_ITEM_ID                         NUMBER
     , VEHICLE_NUMBER                          VARCHAR2(30)
     , CARRIER_ID                              NUMBER
     , SHIP_METHOD_CODE                        VARCHAR2(30)
     , VEHICLE_ORGANIZATION_ID                 NUMBER
     , VEHICLE_NUM_PREFIX                      VARCHAR2(10)
     , SERVICE_LEVEL                           VARCHAR2(30)
     , MODE_OF_TRANSPORT                       VARCHAR2(30)
     );

  TYPE trip_ccinfo_tab_type IS TABLE OF trip_ccinfo_rec_type INDEX BY BINARY_INTEGER;

  TYPE stop_ccinfo_rec_type IS RECORD (
       STOP_ID                                 NUMBER
     , EXISTS_IN_DATABASE                      VARCHAR2(1)
     , TRIP_ID                                 NUMBER DEFAULT NULL
     , STOP_LOCATION_ID                        NUMBER
     , STATUS_CODE                             VARCHAR2(2)
     , STOP_SEQUENCE_NUMBER                    NUMBER
     , PLANNED_ARRIVAL_DATE                    DATE
     , PLANNED_DEPARTURE_DATE                  DATE
     , ACTUAL_ARRIVAL_DATE                     DATE
     , ACTUAL_DEPARTURE_DATE                   DATE
     --#DUM_LOC(S)
     , PHYSICAL_LOCATION_ID		       NUMBER DEFAULT NULL
     , PHYSICAL_STOP_ID			       NUMBER DEFAULT NULL
     --#DUM_LOC(E)
     );

  TYPE stop_ccinfo_tab_type IS TABLE OF stop_ccinfo_rec_type INDEX BY BINARY_INTEGER;

  TYPE lane_ccinfo_rec_type IS RECORD (
      LANE_ID                                  NUMBER
    , LANE_NUMBER                              VARCHAR2(30)
    , LANE_TYPE                                VARCHAR2(20)
    , OWNER_ID                                 NUMBER
    , CARRIER_ID                               NUMBER
    , ORIGIN_ID                                NUMBER
    , DESTINATION_ID                           NUMBER
    , MODE_OF_TRANSPORTATION_CODE              VARCHAR2(30)
    );

  TYPE lane_ccinfo_tab_type IS TABLE OF lane_ccinfo_rec_type INDEX BY BINARY_INTEGER;

  TYPE target_tripstop_cc_rec_type IS RECORD (
      PICKUP_STOP_ID                           NUMBER
    , PICKUP_STOP_SEQ                          NUMBER
    , PICKUP_STOP_PA_DATE                      DATE
    , PICKUP_STOP_PD_DATE                      DATE
    , DROPOFF_STOP_ID                          NUMBER
    , DROPOFF_STOP_SEQ                         NUMBER
    , DROPOFF_STOP_PA_DATE                     DATE
    , DROPOFF_STOP_PD_DATE                     DATE
    , PICKUP_LOCATION_ID                       NUMBER
    , DROPOFF_LOCATION_ID                      NUMBER
    );

  TYPE target_tripstop_cc_tab_type IS TABLE of target_tripstop_cc_rec_type INDEX BY BINARY_INTEGER;

  TYPE item_item_mustuse_rec_type IS RECORD (
      input_item_id                            NUMBER
    , input_itemorg_id                         NUMBER
    , target_item_id                           NUMBER
    , target_itemorg_id                        NUMBER
    , carrier_result                           VARCHAR2(1)
    , mode_result                              VARCHAR2(1)
    , vehicle_result                           VARCHAR2(1)
    , hash_string                              VARCHAR2(200)
    );

  TYPE item_item_mustuse_tab_type IS TABLE of item_item_mustuse_rec_type INDEX BY BINARY_INTEGER;

  TYPE item_location_mustuse_rec_type IS RECORD (
      target_location_id                       NUMBER
    , input_item_id                            NUMBER
    , input_itemorg_id                         NUMBER
    , carrier_result                           VARCHAR2(1)
    , mode_result                              VARCHAR2(1)
    , vehicle_result                           VARCHAR2(1)
    , hash_string                              VARCHAR2(200)
    );

  TYPE item_location_mustuse_tab_type IS TABLE of item_location_mustuse_rec_type INDEX BY BINARY_INTEGER;

  TYPE item_exclusive_rec_type IS RECORD (
      comp_class_code                           VARCHAR2(30)
    , item_id                                   NUMBER
    , itemorg_id                                NUMBER
    , object2_id                                NUMBER
    , object2_char                              VARCHAR2(30)
    , validate_result                           VARCHAR2(1)
    , hash_string                               VARCHAR2(200)
    );

  TYPE item_exclusive_tab_type IS TABLE of item_exclusive_rec_type INDEX BY BINARY_INTEGER;

  TYPE fac_exclusive_rec_type IS RECORD (
      comp_class_code                           VARCHAR2(30)
    , object1_type                              VARCHAR2(30)
    , object1_id                                NUMBER
    , object2_id                                NUMBER
    , object2_char                              VARCHAR2(30)
    , validate_result                           VARCHAR2(1)
    , hash_string                               VARCHAR2(200)
    );

  TYPE fac_exclusive_tab_type IS TABLE of fac_exclusive_rec_type INDEX BY BINARY_INTEGER;

   --#REG-ZON
  TYPE loc_reg_constraint_rec_type IS RECORD (
       location_id		NUMBER
     , object2_id		NUMBER
     , constraint_id		NUMBER
     , constraint_type		VARCHAR2(1)
     , hash_string		VARCHAR2(200)
     );

  TYPE loc_reg_constraint_tab_type IS TABLE of loc_reg_constraint_rec_type INDEX BY BINARY_INTEGER;
  --#REG-ZON

  /* END entity record structures */

--      Public APIs for Shipping/Transportation events

--  Whenever a calling application calls any of the following entity dependent
--  APIs, they should index p_exception_list by the appropriate
--  global variables for the specific compability class code provided here
--  the API will skip the compatibility classes that have been mentioned in p_exception_list
--  If nothing is provided, the API will perform all checks
--  Can be useful if constraint checks are done in stages

--***************************************************************************--

--========================================================================
-- PROCEDURE : validate_constraint_dlvy    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_in_ids                    Table of delivery ids to process
--                                         Either of the next two should be passed
--             p_delivery_info             Table of delivery records to process
--                                         Only one of p_in_ids and p_delivery_info should be passed
--             p_dlvy_assigned_lines       Table of assigned delivery details of
--                                         input deliveries. Pass if queried information available
--                                         If not passed, the API will query
--             p_target_trip               Applicable for Assign delivery to Trip only
--                                         Record of target trip information
--             p_target_tripstops          Input pickup and dropoff stop/location of the delivery(s)
--                                         in that target trip
--             p_target_trip_assign_dels   Table of deliveries in target trip
--                                         If not passed, the API will query
--             p_target_trip_dlvy_lines    Table of delivery details in target trip
--                                         If not passed, the API will query
--             p_target_trip_incl_stops    Table of tripstops already in the target trip_
--                                         If not passed, the API will query
--             x_validate_result           Constraint Validation result : S / F
--             x_line_groups               Includes Successful and warning lines
--                                         after constraint check
--                                         Contains information of which input delivery should
--                                         be grouped in which output group for trip creation
--             x_group_info                Output groups for input deliveries
--             x_failed_lines              Table of input delivery lines that failed
--                                         constraint check
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Can be called for
--             A. Autocreate Trip (ACT)
--             B. Assign Delivery to Trip (ADT)
--             C. Update a delivery (UPD)
--             D. Manually create a delivery (CRD)
--             When specifying a target trip, group all deliveries that are being planned
--             to the target trip
--========================================================================


PROCEDURE validate_constraint_dlvy(
             p_init_msg_list            IN              VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN              VARCHAR2 DEFAULT NULL,
             p_exception_list           IN              WSH_UTIL_CORE.Column_Tab_Type,
             p_in_ids                   IN              WSH_UTIL_CORE.id_tab_type,
             p_delivery_info            IN              delivery_ccinfo_tab_type,
             p_dlvy_assigned_lines      IN              detail_ccinfo_tab_type,
             p_target_trip              IN              trip_ccinfo_rec_type,
             p_target_tripstops         IN OUT  NOCOPY  target_tripstop_cc_rec_type,
             p_target_trip_assign_dels  IN		delivery_ccinfo_tab_type,
             p_target_trip_dlvy_lines   IN              detail_ccinfo_tab_type,
             p_target_trip_incl_stops   IN              stop_ccinfo_tab_type,
             x_validate_result          OUT NOCOPY      VARCHAR2,
             x_line_groups              OUT NOCOPY      WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type,
             x_group_info               OUT NOCOPY      WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
             x_failed_lines             OUT NOCOPY      WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type,
             x_msg_count                OUT NOCOPY      NUMBER,
             x_msg_data                 OUT NOCOPY      VARCHAR2,
             x_return_status            OUT NOCOPY      VARCHAR2);


--***************************************************************************--

--========================================================================
-- PROCEDURE : validate_constraint_dleg    Called by constraint Wrapper API
--                                         and the Lane search API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_delivery_leg_rec          Input delivery leg record
--             p_target_trip               Table of target trips for delivery leg trip search
--             p_target_lane               Table of target lane for delivery leg lane search
--             x_succ_trips                List of input trips that passed constraint check
--             x_succ_lanes                List of input lanes that passed constraint check
--             x_validate_result           Constraint Validation result : S / F
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Lane search for delivery leg (DLS)
--========================================================================

PROCEDURE validate_constraint_dleg(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN      WSH_UTIL_CORE.Column_Tab_Type,
             p_delivery_leg_rec         IN      dleg_ccinfo_rec_type,
             p_target_trip              IN      trip_ccinfo_tab_type,
             p_target_lane              IN      lane_ccinfo_tab_type,
             x_succ_trips               OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
             x_succ_lanes               OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
             x_validate_result          OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2,
             x_return_status            OUT NOCOPY  VARCHAR2);


--***************************************************************************--

--========================================================================
-- PROCEDURE : validate_constraint_dlvb    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_in_ids                    Table of delivery ids to process
--                                         Either of the next two should be passed
--             p_del_detail_info           Table of delivery detail records to process
--                                         Only one of p_in_ids and p_del_detail_info should be passed
--             p_target_delivery           Applicable for Assign delivery detail to delivery only
--                                         Record of target delivery information
--             p_target_container          Applicable for Assign delivery detail to container only
--                                         Record of target container information
--                                         If not passed, the API will query
--             p_dlvy_assigned_lines       Table of delivery details already in target
--                                         delivery or target container
--                                         If not passed, the API will query
--             x_validate_result           Constraint Validation result : S / F
--             x_failed_lines              Table of input delivery lines that failed
--                                         constraint check
--             x_line_groups               Includes Successful and warning lines
--                                         after constraint check
--                                         Contains information of which input delivery should
--                                         be grouped in which output group for trip creation
--             x_group_info                Output groups for input deliveries
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Autocreate Delivery (ACD)
--             B. Assign detail to Delivery (ADD)
--             C. Packing (PKG)
--             When specifying a target delivery, group all delivery lines that are being planned
--             to the target delivery
--========================================================================

PROCEDURE validate_constraint_dlvb(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN      WSH_UTIL_CORE.Column_Tab_Type,
             p_in_ids                   IN      WSH_UTIL_CORE.id_tab_type,
             p_del_detail_info          IN      detail_ccinfo_tab_type,
             p_target_delivery          IN      delivery_ccinfo_rec_type,
             p_target_container         IN      detail_ccinfo_rec_type,
             p_dlvy_assigned_lines      IN      detail_ccinfo_tab_type,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_failed_lines             OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.failed_line_tab_type,
             x_line_groups              OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.line_group_tab_type,
             x_group_info               OUT NOCOPY    WSH_FTE_COMP_CONSTRAINT_PKG.cc_group_tab_type,
             x_msg_count                OUT NOCOPY    NUMBER,
             x_msg_data                 OUT NOCOPY    VARCHAR2,
             x_return_status            OUT NOCOPY    VARCHAR2);


--***************************************************************************--

--========================================================================
-- PROCEDURE : validate_constraint_trip    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_trip_info                 Table of Trip records to process
--             p_trip_assigned_dels        Table of delivery records already in the trip
--                                         If not passed, the API will query
--             p_trip_dlvy_lines           Table of delivery details already in the trip
--                                         If not passed, the API will query
--             p_trip_incl_stops           Table of Stop records already in the trip
--                                         If not passed, the API will query
--             x_fail_trips                Table of input trips that failed constraint check
--             x_validate_result           Constraint Validation result : S / F
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Update an existing trip (UPT)
--========================================================================

PROCEDURE validate_constraint_trip(
             p_init_msg_list            IN      VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN      WSH_UTIL_CORE.Column_Tab_Type,
             p_trip_info                IN      trip_ccinfo_tab_type,
             p_trip_assigned_dels       IN      delivery_ccinfo_tab_type,
             p_trip_dlvy_lines          IN      detail_ccinfo_tab_type,
             p_trip_incl_stops          IN      stop_ccinfo_tab_type,
             x_fail_trips               OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_msg_count                OUT NOCOPY    NUMBER,
             x_msg_data                 OUT NOCOPY    VARCHAR2,
             x_return_status            OUT NOCOPY    VARCHAR2);

--***************************************************************************--

--========================================================================
-- PROCEDURE : validate_constraint_stop    Called by constraint Wrapper API
--                                         and the Group API.
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_action_code               Predefined action code
--             p_exception_list            Compatibility classes to skip if any
--                                         indexed by class code numbers
--             p_stop_info                 Table of Stop records to process
--             p_parent_trip_info          Table of Parent Trip records
--                                         If not passed, the API will query
--             x_fail_stops                Table of input stops that failed constraint check
--             x_validate_result           Constraint Validation result : S / F
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             A. Create a new stop ( CTS)
--             B. Update an existing stop (UPS)
--             C. Delete a stop (DTS)
--========================================================================

PROCEDURE validate_constraint_stop(
             p_init_msg_list            IN            VARCHAR2 DEFAULT fnd_api.g_false,
             p_action_code              IN	      VARCHAR2 DEFAULT NULL,
             p_exception_list           IN	      WSH_UTIL_CORE.Column_Tab_Type,
             p_stop_info                IN            stop_ccinfo_tab_type,
	     p_parent_trip_info         IN	      trip_ccinfo_tab_type,
             x_fail_stops               OUT NOCOPY    WSH_UTIL_CORE.id_tab_type,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_msg_count                OUT NOCOPY    NUMBER,
             x_msg_data                 OUT NOCOPY    VARCHAR2,
             x_return_status            OUT NOCOPY    VARCHAR2);

-- Utility APIs

--***************************************************************************--

--========================================================================
-- PROCEDURE : get_constraint_display      Called by constraint Wrapper API
--                                         and FTE constraint UI
--
-- PARAMETERS: p_constraint_id             Constraint id to get information about
--             x_obj1_display              Display name of constraint object1 in input constraint
--             x_obj1_parent_display       Display name of constraint object1 parent
--             x_obj2_display              Display name of constraint object2 in input constraint
--             x_obj2_parent_display       Display name of constraint object2 parent
--             x_condition_display         Display name of constraint type
--                                         (Exclusive / Inclusive) in input constraint
--             x_fac1_company_type         Display name of company type if constraint object1
--                                         is a facility
--             x_fac1_company_name         Display name of company name if constraint object1
--                                         is a facility
--             x_fac2_company_type         Display name of company type if constraint object2
--                                         is a facility
--             x_fac2_company_name         Display name of company name if constraint object2
--                                         is a facility
--             x_comp_class_code           Display meaning of compatibility class code
--                                         for the input constraint
--             x_severity                  Display meaning of severity setting of the
--                                         compatibility class for the input constraint
--             x_return_status             Return status
-- COMMENT   : This procedure is used to perform for following actions
--             Takes as input a constraint id
--             and returns the names of the objects
--             which are associated by this constraint definition
--========================================================================

PROCEDURE get_constraint_display(
             p_constraint_id           IN NUMBER,
             x_obj1_display            OUT NOCOPY      VARCHAR2,
             x_obj1_parent_display     OUT NOCOPY      VARCHAR2,
             x_obj2_display            OUT NOCOPY      VARCHAR2,
             x_obj2_parent_display     OUT NOCOPY      VARCHAR2,
             x_condition_display       OUT NOCOPY      VARCHAR2,
             x_fac1_company_type       OUT NOCOPY      VARCHAR2,
             x_fac1_company_name       OUT NOCOPY      VARCHAR2,
             x_fac2_company_type       OUT NOCOPY      VARCHAR2,
             x_fac2_company_name       OUT NOCOPY      VARCHAR2,
             x_comp_class_code         OUT NOCOPY      VARCHAR2,
             x_severity                OUT NOCOPY      VARCHAR2,
             x_return_status           OUT NOCOPY      VARCHAR2 );


--***************************************************************************--

--========================================================================
-- FUNCTION :  is_last_trip                PUBLIC
--
-- PARAMETERS: p_delivery_id               Input delivery
--             p_initial_pu_loc_id         Delivery's initial pickup location
--             p_ultimate_do_loc_id        Delivery's ultimate dropoff location
--                                         Above two are queried if any of them found to be NULL
--             p_target_stops_in_trip      Input pickup and dropoff stop/location of the delivery(s)
--                                         in the target trip in case of assign delivery to trip
--             p_target_trip_id            Target trip
--             x_return_status             Return status
-- COMMENT   :
-- Applicable for Assign delivery to Trip
-- Determines whether the target trip is the last trip for an input delivery
-- in order to finish the multileg delivery
--========================================================================

FUNCTION is_last_trip (
            p_delivery_id           IN NUMBER,
            p_initial_pu_loc_id     IN NUMBER DEFAULT NULL,
            p_ultimate_do_loc_id    IN NUMBER DEFAULT NULL,
            p_target_trip_id        IN NUMBER,
            p_target_stops_in_trip  IN target_tripstop_cc_rec_type,
            x_return_status         OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;

PROCEDURE populate_constraint_cache(
          p_comp_class_code          IN      VARCHAR2 DEFAULT NULL,
          x_return_status            OUT NOCOPY    VARCHAR2);


/*--========================================================================
-- PROCEDURE : validate_constraint        PRIVATE
--
-- PARAMETERS: p_comp_class_code          Compatibility class code
--             p_constraint_type          Constraint Type : Exclusive / Inclusive
--             p_object1_type	          Constraint Object1 Type
--             p_object1_parent_id        Constraint Object1 Parent id
--                                        Required only if object1 = Item
--             p_object1_val_num          Constraint Object1 id
--             p_object1_val_char         Constraint Object1 character code
--             p_object1_physical_id      Physical Location Id - Passed in only for CUS_FAC for Customer Facility
--             p_object2_type	          Constraint Object2 Type
--             p_object2_parent_id        Constraint Object2 Parent id
--             p_object2_val_num          Constraint Object2 id
--             p_object2_val_char         Constraint Object2 character code
--                                        Currently used for Mode of Transport code only
--             p_direct_shipment          Is the shipment multileg
--             x_validate_result          Constraint Validation result : S / E / W
--             x_failed_constraint        failed constraint id in case of failure, null if success
--             x_return_status            Return status
-- COMMENT   :
--      This is an internal procedure to determine if two objects
--      have a constraint defined between them under the scope of a particular compatibility class
--      Hence, returns constraint severity
--      1. Passed I : if a constraint for this combination exists of type 'I'
--      2. Passed E : if a constraint for this combination exists of type 'E'

--      Assumes object1 and object2 have been passed as the class requires/defines
--========================================================================

PROCEDURE validate_constraint(
             p_comp_class_code          IN      VARCHAR2,
             p_constraint_type          IN      VARCHAR2 DEFAULT 'E',
             p_object1_type	        IN      VARCHAR2 DEFAULT NULL,
             p_object1_parent_id        IN      NUMBER   DEFAULT NULL,
             p_object1_val_char         IN      VARCHAR2 DEFAULT NULL,
             p_object1_val_num          IN      NUMBER   DEFAULT NULL,
             p_object1_physical_id	IN	NUMBER	 DEFAULT NULL,
	         p_object2_type	        IN      VARCHAR2 DEFAULT NULL,
             p_object2_parent_id        IN      NUMBER   DEFAULT NULL,
             p_object2_val_char         IN      VARCHAR2 DEFAULT NULL,
             p_object2_val_num          IN      NUMBER   DEFAULT NULL,
             p_direct_shipment          IN      BOOLEAN  DEFAULT FALSE,
             x_validate_result          OUT NOCOPY    VARCHAR2,
             x_failed_constraint        OUT NOCOPY    line_constraint_rec_type,
             x_return_status            OUT NOCOPY    VARCHAR2);*/

-- MDC Constraints

--***************************************************************************--
--========================================================================
-- PROCEDURE : VALIDATE_CONSTRAINT_DECONSOL
--
-- PARAMETERS: p_init_msg_list             FND_API.G_TRUE to reset list
--             p_delivery_info             Table of delivery records to process
--                                         Only one of p_in_ids and p_delivery_info should be passed
--             p_in_ids                    Table of delivery ids to process
--             p_rule_deconsol_location    Default deconsolidation location passed
--             p_rule_override_deconsol    If true, default deconsolidation location passed
--                                         takes precedence.
--             x_output_id_tab             Output tab with deconsol location specified for deliveries
--             x_msg_count                 Number of messages in the list
--             x_msg_data                  Text of messages
--             x_return_status             Return status
-- COMMENT   : This procedure stamps each of the deliveries with deconsolidation locations,
--             procedure is to find deconsolidation locations for a group of deliveries passed
--========================================================================
PROCEDURE validate_constraint_deconsol( p_init_msg_list          IN  VARCHAR2 DEFAULT fnd_api.g_false,
                                        p_delivery_info          IN  OUT NOCOPY   delivery_ccinfo_tab_type,
                                        p_in_ids                 IN  wsh_util_core.id_tab_type,
                                        p_rule_deconsol_location IN   NUMBER default NULL,
                                        p_rule_override_deconsol IN  BOOLEAN  DEFAULT  FALSE,
                                        p_rule_to_zone_id        IN   NUMBER  DEFAULT  NULL,
                                        p_caller                 IN  VARCHAR2 DEFAULT NULL,
                                        x_output_id_tab          OUT  NOCOPY deconsol_output_tab_type,
                                        x_return_status          OUT  NOCOPY VARCHAR2,
                                        x_msg_count              OUT  NOCOPY NUMBER,
                                        x_msg_data               OUT  NOCOPY VARCHAR2);

-- MDC Constraints end

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_customer_from_loc      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_customer_id              Carrier at the input location
--             x_return_status            Return status
-- COMMENT   :
-- Returns the customer id of the customer
-- having a location at input wsh location id
--========================================================================

PROCEDURE get_customer_from_loc(
              p_location_id    IN  NUMBER,
              --x_customer_id     OUT NOCOPY  NUMBER,
              x_customer_id_tab     OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
              x_return_status  OUT NOCOPY  VARCHAR2);

--***************************************************************************--
--========================================================================
-- PROCEDURE : get_org_from_location      PRIVATE
--
-- PARAMETERS: p_location_id              Input Location id
--             x_organization_tab         Organizations for the input location
--             x_return_status            Return status
-- COMMENT   :
--             Returns table of organizations for location.
--========================================================================
PROCEDURE get_org_from_location(
         p_location_id         IN  NUMBER,
         x_organization_tab    OUT NOCOPY  WSH_UTIL_CORE.id_tab_type,
         x_return_status       OUT NOCOPY  VARCHAR2);

END WSH_FTE_CONSTRAINT_FRAMEWORK;


 

/
