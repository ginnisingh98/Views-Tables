--------------------------------------------------------
--  DDL for Package WSH_FTE_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FTE_INTEGRATION" AUTHID CURRENT_USER as
/* $Header: WSHFTEIS.pls 120.4.12000000.1 2007/01/16 05:46:06 appldev ship $ */


-- constants for the Source attribute in rank lists
C_RANKLIST_SOURCE_TP   CONSTANT   VARCHAR2(2) := 'TP';

-- constants for the entity type in GET_ORG_ORGANIZATION_INFO
C_ORG_INFO_TRIP        CONSTANT   VARCHAR2(4) := 'TRIP';
C_ORG_INFO_STOP        CONSTANT   VARCHAR2(4) := 'STOP';
C_ORG_INFO_DELIVERY    CONSTANT   VARCHAR2(8) := 'DELIVERY';
C_ORG_INFO_DETAIL      CONSTANT   VARCHAR2(6) := 'DETAIL';



-- ------------------------------------------------- --
--                                                   --
-- Tables and records for Carrier Selection          --
-- ----------------------------                      --
--                                                   --
-- ------------------------------------------------- --
--SBAKSHI(S)
--
TYPE wsh_cs_output_message_rec IS RECORD (sequence_number   NUMBER,
                                          message_type      VARCHAR2(1),
                                          message_code      VARCHAR2(30),
                                          message_text      VARCHAR2(2000),
                                          level             NUMBER,
                                          query_id          NUMBER,
                                          group_id          NUMBER,
                                          rule_id           NUMBER,
                                          result_id         NUMBER);

TYPE wsh_cs_output_message_tab IS TABLE OF wsh_cs_output_message_rec INDEX BY BINARY_INTEGER;

TYPE WSH_CS_ENTITY_REC_TYPE IS RECORD(
		delivery_id				NUMBER,
		delivery_name				VARCHAR2(30),
	        trip_id					NUMBER,
                trip_name				VARCHAR2(30),
                organization_id				NUMBER,
                triporigin_internalorg_id		NUMBER,
		gross_weight				NUMBER,
                weight_uom_code				VARCHAR2(3),
                volume					NUMBER,
                volume_uom_code				VARCHAR2(3),
                initial_pickup_loc_id			NUMBER,
                ultimate_dropoff_loc_id			NUMBER,
		customer_id				NUMBER,
		customer_site_id			NUMBER,
		freight_terms_code			VARCHAR2(30),
                initial_pickup_date			DATE,
                ultimate_dropoff_date			DATE,
                fob_code				VARCHAR2(30),
                start_search_level			VARCHAR2(10),
		transit_time				NUMBER,
		rule_id					NUMBER,
		result_found_flag			VARCHAR2(1));

TYPE WSH_CS_ENTITY_TAB_TYPE IS TABLE OF WSH_CS_ENTITY_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE WSH_CS_RESULT_REC_TYPE IS RECORD(
		rule_id					NUMBER,
		rule_name				VARCHAR2(30),
		delivery_id				NUMBER,
                organization_id                         NUMBER,
                initial_pickup_location_id		NUMBER,
                ultimate_dropoff_location_id		NUMBER,
                trip_id					NUMBER,
                result_type				VARCHAR2(30), -- Rank / Multileg / Ranked multileg / Ranked itinerary
                rank					NUMBER,
                leg_destination				NUMBER,
                leg_sequence				NUMBER,
  --            itinerary_id				NUMBER,	-- Future use for ranked itenerary
                carrier_id				NUMBER,
                mode_of_transport			VARCHAR2(30),
                service_level				VARCHAR2(30),
                ship_method_code			VARCHAR2(30),
                freight_terms_code			VARCHAR2(30),
                consignee_carrier_ac_no			VARCHAR2(240), --WSH_TRIPS
--              track_only_flag				VARCHAR2(1),
                result_level				VARCHAR(5),
		pickup_date				DATE,
		dropoff_date				DATE,
		min_transit_time			NUMBER,
		max_transit_time			NUMBER,
		append_flag				VARCHAR2(1)
		--,routing_rule_id				NUMBER
                );

TYPE WSH_CS_RESULT_TAB_TYPE IS TABLE OF WSH_CS_RESULT_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE CARRIER_RANK_LIST_REC_TYPE IS RECORD (
                rank_id                                 NUMBER,
                trip_id                                 NUMBER,
                rank_sequence                           NUMBER,
                carrier_id                              NUMBER,
                mode_of_transport                       VARCHAR2(30),
                service_level                           VARCHAR2(30),
                freight_terms_code			VARCHAR2(30),
                consignee_carrier_ac_no			VARCHAR2(240), --WSH_TRIPS
                lane_id                                 NUMBER,
                source                                  VARCHAR2(30),
                is_current                              VARCHAR2(1),
                call_rg_flag                            VARCHAR2(1)
                );

TYPE CARRIER_RANK_LIST_TBL_TYPE IS TABLE OF CARRIER_RANK_LIST_REC_TYPE INDEX BY BINARY_INTEGER;

--
--SBAKSHI(E)
--

--
-- Types for Rating
--

TYPE rating_action_param_rec IS RECORD (
     caller         VARCHAR2(30),
     event          VARCHAR2(30),
     action         VARCHAR2(30),
     trip_id_list   WSH_UTIL_CORE.id_tab_type);   -- list of trip_ids

-- types for Rate_Delivery
TYPE rate_del_in_param_rec IS RECORD(
  delivery_id_list	WSH_UTIL_CORE.id_tab_type,
  seq_tender_flag       VARCHAR2(1),
  action		VARCHAR2(30));

TYPE rate_del_out_param_rec IS RECORD(
  failed_delivery_id_list	WSH_UTIL_CORE.id_tab_type);

-- J+ Types for Auto Tender Project
TYPE WSH_TRIP_ACTION_PARAM_REC is RECORD
   (phase                          NUMBER,
  action_code                    VARCHAR2(500),
  organization_id                NUMBER,
  report_set_id                  NUMBER,
  override_flag                  VARCHAR2(500),
  trip_name                      VARCHAR2(30),
  actual_date                    DATE,
  stop_id                        NUMBER,
  action_flag                    VARCHAR2(1),
  autointransit_flag             VARCHAR2(1),
  autoclose_flag                 VARCHAR2(1),
  stage_del_flag                 VARCHAR2(1),
  ship_method                    VARCHAR2(30),
  bill_of_lading_flag            VARCHAR2(1),
  defer_interface_flag           VARCHAR2(1),
  actual_departure_date          DATE);

TYPE WSH_TRIP_ACTION_OUT_REC IS RECORD
(  result_id_tab                WSH_UTIL_CORE.id_tab_type,
  valid_ids_tab                 WSH_UTIL_CORE.id_tab_type,
  delivery_id_tab               WSH_UTIL_CORE.id_tab_type,
  failed_ids_tab                WSH_UTIL_CORE.id_tab_type, -- different from FTE datastructure
  selection_issue_flag          VARCHAR2(1),
  packing_slip_number           VARCHAR2(50),
  num_success_delivs            NUMBER,
  split_quantity                NUMBER,
  split_quantity2               NUMBER);

--
--
--  Procedure:          Shipment_Price_Consolidate
--  Parameters:         p_delivery_leg_id
--                      p_trip_id  ( segment id for FTE, trip id for WSH)
--                      x_return_status
--  Description:        This procedure is a wapper for
--                      FTE_FREIGHT_PRICING.shipment_price_consolidate
--                      to calculate the cost from FTE
--                      and have the result records populated in
--                      wsh_freight_costs table
--
PROCEDURE shipment_price_consolidate (
        p_delivery_leg_id      IN     NUMBER DEFAULT NULL,
        p_trip_id              IN     NUMBER DEFAULT NULL,
        x_return_status        OUT    NOCOPY VARCHAR2 ) ;

-- WSH get_rate_from_FTE demo flow
PROCEDURE Rate_Delivery  (
                             p_api_version              IN NUMBER DEFAULT 1.0,
                             p_init_msg_list            IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
			     p_in_param_rec		IN rate_del_in_param_rec,
			     x_out_param_rec		OUT NOCOPY  rate_del_out_param_rec,
                             x_return_status            OUT NOCOPY  VARCHAR2,
                             x_msg_count                OUT NOCOPY  NUMBER,
                             x_msg_data                 OUT NOCOPY  VARCHAR2);

-- WSH get_rate_from_FTE demo flow (multiple deliveries)
PROCEDURE Cancel_Service  (
                             p_api_version              IN NUMBER DEFAULT 1.0,
                             p_init_msg_list            VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_delivery_list            IN  WSH_UTIL_CORE.id_tab_type,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
                             x_msg_count                OUT NOCOPY  NUMBER,
                             x_msg_data                 OUT NOCOPY  VARCHAR2);

-- WSH get_rate_from_FTE demo flow (single delivery)
PROCEDURE Cancel_Service  (
                             p_api_version              IN NUMBER DEFAULT 1.0,
                             p_init_msg_list            VARCHAR2 DEFAULT FND_API.G_FALSE,
                             p_delivery_id              IN  NUMBER,
                             p_action                   IN  VARCHAR2 DEFAULT 'CANCEL',
                             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY  VARCHAR2,
                             x_msg_count                OUT NOCOPY  NUMBER,
                             x_msg_data                 OUT NOCOPY  VARCHAR2);

PROCEDURE trip_stop_validations
    ( p_stop_rec  IN WSH_TRIP_STOPS_PVT.trip_stop_rec_type,
      p_trip_rec  IN WSH_TRIPS_PVT.trip_rec_type,
      p_action    IN VARCHAR2,
      x_return_status OUT NOCOPY VARCHAR2) ;


--
--SBAKSHI(S)
--
/*
-- Commenting for R12
PROCEDURE CARRIER_SELECTION(p_cs_input_header_rec    IN OUT NOCOPY wsh_cs_input_header_rec,
                            p_cs_input_attribute_tab IN OUT NOCOPY wsh_cs_input_attribute_tab,
                            p_object_name            IN  VARCHAR2,
                            p_object_id              IN  NUMBER,
                            p_messaging_yn           IN  VARCHAR2,
                            x_cs_output_result_tab   OUT NOCOPY wsh_cs_output_result_tab,
                            x_cs_output_message_tab  OUT NOCOPY wsh_cs_output_message_tab,
                            x_return_message         OUT NOCOPY VARCHAR2,
                            x_return_status          OUT NOCOPY VARCHAR2);
*/

PROCEDURE CARRIER_SELECTION( p_format_cs_tab		IN  OUT  NOCOPY		WSH_FTE_INTEGRATION.wsh_cs_entity_tab_type,
			     p_messaging_yn		IN			VARCHAR2,
			     p_caller			IN			VARCHAR2,
                             p_entity                   IN                      VARCHAR2,
			     x_cs_output_tab		OUT	NOCOPY		WSH_FTE_INTEGRATION.wsh_cs_result_tab_type,
		             x_cs_output_message_tab	OUT	NOCOPY		WSH_FTE_INTEGRATION.wsh_cs_output_message_tab,
			     x_return_message		OUT	NOCOPY		VARCHAR2,
			     x_return_status		OUT	NOCOPY		VARCHAR2);

--
--SBAKSHI(E)
--
FUNCTION get_cc_object_name(
             --p_comp_class_id            IN NUMBER,
             p_object_type             IN      VARCHAR2,
             p_object_value_num        IN NUMBER DEFAULT NULL,
             p_object_parent_id        IN NUMBER DEFAULT NULL,
             p_object_value_char       IN VARCHAR2 DEFAULT NULL,
             x_fac_company_name        OUT NOCOPY      VARCHAR2,
             x_fac_company_type        OUT NOCOPY  VARCHAR2 ) RETURN VARCHAR2;


--  Procedure : Get_Vehicle_Type
--  Purpose   : Gets vehicle type ID from FTE_VEHICLE_TYPES

PROCEDURE Get_Vehicle_Type(
             p_vehicle_item_id     IN  NUMBER,
             p_vehicle_org_id      IN  NUMBER,
             x_vehicle_type_id     OUT NOCOPY  NUMBER,
             x_return_status       OUT NOCOPY VARCHAR2);

--PROCEDURE GET_VEHICLE_ORG_ID : Gets the vehicle org in fte_vehicle_types
PROCEDURE GET_VEHICLE_ORG_ID
   (p_inventory_item_id         IN NUMBER,
    x_vehicle_org_id            OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2);

-- +======================================================================+
--   Procedure :
--           Rate_Trip  (pack J+)
--
--   Description:
--           Rate Trip from various event points
--   Inputs:
--           p_api_version              => api version
--           p_init_msg_list            => init message list
--           p_action_params            => parameters identifying the
--                                         action to be performed
--                    -> caller -> 'FTE','WSH'
--                    -> event  -> 'TP-RELEASE','SHIP-CONFIRM'
--                    -> action -> 'RATE'
--                    -> trip_id_list -> valid trip_id list
--           p_commit                   => FND_API.G_FALSE / G_TRUE
--   Output:
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--           x_msg_count                OUT NOCOPY  NUMBER,
--           x_msg_data                 OUT NOCOPY  VARCHAR2);
--
-- +======================================================================+

PROCEDURE Rate_Trip (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_action_params            IN  rating_action_param_rec,
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2);

-- +======================================================================+
--   Procedure :
--           Trip_Action  (pack J+)
--
--   Description:
--           Execute Trip Actions for Input of trips
--   Inputs:
--           p_api_version              => api version
--           p_init_msg_list            => init message list
--           p_action_params            => parameters identifying the
--                                         action to be performed
--                    -> action_code ->    'TENDER'
--           p_commit                   => FND_API.G_FALSE / G_TRUE
--   Output:
--           x_action_out_rec           => parameters identifying the Success
--                                         and Error Trip ids
--           x_return_status            OUT NOCOPY VARCHAR2 => Return status
--           x_msg_count                OUT NOCOPY  NUMBER,
--           x_msg_data                 OUT NOCOPY  VARCHAR2);
--
-- +======================================================================+
PROCEDURE  Trip_Action (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
              p_trip_id_tab             IN  WSH_UTIL_CORE.id_tab_type,
             p_action_params            IN  wsh_trip_action_param_rec,
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_action_out_rec           OUT NOCOPY wsh_trip_action_out_rec,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2);

PROCEDURE RANK_LIST_ACTION(
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2,
             p_action_code              IN  VARCHAR2,
             p_ranklist                 IN  OUT NOCOPY CARRIER_RANK_LIST_TBL_TYPE,
             p_trip_id                  IN  NUMBER,
             p_rank_id                  IN  NUMBER
             --x_ranklist                 OUT NOCOPY CARRIER_RANK_LIST_TBL_TYPE
             );

FUNCTION GET_TRIP_MOVE(
             p_trip_id                   IN  NUMBER) RETURN NUMBER;


-- ----------------------------------------------------------------------
-- Procedure:   CARRIER_SEL_CREATE_TRIP
--
-- Parameters:  p_delivery_id               Delivery ID
--              p_carrier_sel_result_rec    WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE
--              x_trip_id                   Trip Id
--              x_trip_name                 Trip Name
--              x_return_message            Return Message
--              x_return_status             Return Status
--
-- COMMENT   : This procedure is called from Process Carrier Selection API
--             in order to create trip for deliveries not assigned to trips
--
--             This procedure is a wrapper for FTE_ACS_TRIP_PKG.CARRIER_SEL_CREATE_TRIP
--
--  ----------------------------------------------------------------------
PROCEDURE CARRIER_SEL_CREATE_TRIP( p_delivery_id               IN  NUMBER,
                                   --p_initial_pickup_loc_id     IN  NUMBER,
                                   --p_ultimate_dropoff_loc_id   IN  NUMBER,
                                   --p_initial_pickup_date       IN  DATE,
                                   --p_ultimate_dropoff_date     IN  DATE,
                                   p_carrier_sel_result_rec    IN WSH_FTE_INTEGRATION.WSH_CS_RESULT_REC_TYPE,
                                   x_trip_id                   OUT NOCOPY NUMBER,
                                   x_trip_name                 OUT NOCOPY VARCHAR2,
                                   x_return_message            OUT NOCOPY VARCHAR2,
                                   x_return_status             OUT NOCOPY VARCHAR2);




-- ----------------------------------------------------------------------
-- Procedure:   GET_ORG_ORGANIZATION_INFO
--
-- Parameters:
--              p_init_msg_list             Flag to initialize message stack
--              x_return_message            Return Message
--              x_msg_count                 count of messages
--              p_msg_data                  message text
--              x_organization_id           inventory organization identifier
--              x_org_id                    operating unit identifier
--              p_entity_id                 entity identifier
--              p_entity_type               'TRIP' or 'DELIVERY'
--              p_org_id_flag               flag to optionally get x_org_id
--                                             FND_API.G_TRUE -> yes
--                                             FND_API.G_FALSE -> no
--
--
-- COMMENT   : This procedure calls FTE to associate a trip with
--             inventory organization and optionally the operating unit.
--
--             This procedure is a wrapper for
--             FTE_WSH_INTEGRATION_PKG.GET_ORG_ORGANIZATION_INFO
--
--             FTE will always be called regardless of
--             WSH_UTIL_CORE.FTE_Is_Installed value.
--
--  ----------------------------------------------------------------------
PROCEDURE GET_ORG_ORGANIZATION_INFO(
       p_init_msg_list    IN             VARCHAR2,
       x_return_status       OUT NOCOPY  VARCHAR2,
       x_msg_count           OUT NOCOPY  NUMBER,
       x_msg_data            OUT NOCOPY  VARCHAR2,
       x_organization_id     OUT NOCOPY  NUMBER,
       x_org_id              OUT NOCOPY  NUMBER,
       p_entity_id        IN             NUMBER,
       p_entity_type      IN             VARCHAR2,
       p_org_id_flag      IN             VARCHAR2);



-- ----------------------------------------------------------------------
-- Procedure:   CREATE_RANK_LIST_BULK
--
-- Parameters:
--              p_api_version_number        API version number (1)
--              p_init_msg_list             Flag to initialize message stack
--              x_return_message            Return Message
--              x_msg_count                 count of messages
--              p_msg_data                  message text
--              p_source                    source of call; valid values:
--                                            C_RANKLIST_SOURCE_%
--              p_trip_id_tab               table of trip identifiers
--
--
-- COMMENT   : This procedure calls FTE to perform a bulk operation
--             on ranking carriers in trips.
--
--             This procedure is a wrapper for
--             FTE_CARRIER_RANK_LIST_PVT.CREATE_RANK_LIST_BULK
--
--             It will pull the required values from WSH_TRIPS to
--             build the rank list for the FTE API.
--
--  ----------------------------------------------------------------------
PROCEDURE CREATE_RANK_LIST_BULK(
    p_api_version_number IN            NUMBER,
    p_init_msg_list      IN            VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_source             IN            VARCHAR2,
    p_trip_id_tab        IN            WSH_UTIL_CORE.ID_TAB_TYPE);

END WSH_FTE_INTEGRATION;

 

/
