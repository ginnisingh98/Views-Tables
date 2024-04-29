--------------------------------------------------------
--  DDL for Package WSH_TP_RELEASE_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TP_RELEASE_INT" AUTHID CURRENT_USER as
/* $Header: WSHTPRES.pls 120.0 2005/05/26 18:29:00 appldev noship $ */


TYPE interface_errors_tab_type IS TABLE OF WSH_INTERFACE_ERRORS%ROWTYPE INDEX BY BINARY_INTEGER;

TYPE plan_detail_rec_type IS RECORD (
         dd_interface_id            NUMBER,
         delivery_detail_id         NUMBER,
         tp_delivery_detail_id      NUMBER,
         mapped_quantity            NUMBER,
         mapped_quantity_uom        WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY_UOM%TYPE,
         map_split_flag             VARCHAR2(1),
         released_status            WSH_DELIVERY_DETAILS.RELEASED_STATUS%TYPE,
         move_order_line_id         NUMBER,
         line_direction             WSH_DELIVERY_DETAILS.LINE_DIRECTION%TYPE,
         source_code                WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE,
         source_header_id           NUMBER,
         source_line_set_id         NUMBER,
         source_line_id             NUMBER,
         po_shipment_line_id        NUMBER, -- scope for mapping inbound/drop details
         ship_set_id                NUMBER,
         top_model_line_id          NUMBER,
         ato_line_id                NUMBER,
         ship_model_complete_flag   WSH_DELIVERY_DETAILS.SHIP_MODEL_COMPLETE_FLAG%TYPE,
         ship_from_location_id      NUMBER,
         ship_to_location_id        NUMBER,
         organization_id            NUMBER,
         customer_id                NUMBER,
         fob_code                   WSH_DELIVERY_DETAILS.FOB_CODE%TYPE,
         freight_terms_code         WSH_DELIVERY_DETAILS.FREIGHT_TERMS_CODE%TYPE,
         intmed_ship_to_location_id NUMBER,
         ship_method_code           WSH_DELIVERY_DETAILS.SHIP_METHOD_CODE%TYPE,
         mode_of_transport          WSH_DELIVERY_DETAILS.MODE_OF_TRANSPORT%TYPE,
         service_level              WSH_DELIVERY_DETAILS.SERVICE_LEVEL%TYPE,
         carrier_id                 NUMBER,
         shipping_control           WSH_DELIVERY_DETAILS.SHIPPING_CONTROL%TYPE,
         vendor_id                  WSH_DELIVERY_DETAILS.VENDOR_ID%TYPE,
         party_id                   WSH_DELIVERY_DETAILS.PARTY_ID%TYPE,
         topmost_cont_id            NUMBER,
         current_delivery_id        NUMBER,
         target_delivery_index      NUMBER,
         wv_frozen_flag             WSH_DELIVERY_DETAILS.WV_FROZEN_FLAG%TYPE
     );
TYPE plan_detail_tab_type IS TABLE OF plan_detail_rec_type INDEX BY BINARY_INTEGER;





TYPE plan_delivery_rec_type IS RECORD (
         del_interface_id           NUMBER,
         delivery_id                NUMBER,
         tp_delivery_number         WSH_NEW_DELIVERIES.TP_DELIVERY_NUMBER%TYPE,
         tp_plan_name               WSH_NEW_DELIVERIES.TP_PLAN_NAME%TYPE,
         planned_flag               WSH_NEW_DELIVERIES.PLANNED_FLAG%TYPE,
         wsh_planned_flag           WSH_NEW_DELIVERIES.PLANNED_FLAG%TYPE,
         initial_pickup_location_id   NUMBER,
         ultimate_dropoff_location_id NUMBER,
         initial_pickup_date        DATE,
         ultimate_dropoff_date      DATE,
         ship_method_code           WSH_NEW_DELIVERIES.SHIP_METHOD_CODE%TYPE,
         mode_of_transport          WSH_NEW_DELIVERIES.MODE_OF_TRANSPORT%TYPE,
         service_level              WSH_NEW_DELIVERIES.SERVICE_LEVEL%TYPE,
         freight_terms_code         WSH_NEW_DELIVERIES.FREIGHT_TERMS_CODE%TYPE,
         name                       WSH_NEW_DELIVERIES.NAME%TYPE,
         loading_sequence           WSH_NEW_DELIVERIES.LOADING_SEQUENCE%TYPE,
         loading_order_flag         WSH_NEW_DELIVERIES.LOADING_ORDER_FLAG%TYPE,
         fob_location_id            WSH_NEW_DELIVERIES.FOB_LOCATION_ID%TYPE,
         waybill                    WSH_NEW_DELIVERIES.WAYBILL%TYPE,
         currency_code              WSH_NEW_DELIVERIES.CURRENCY_CODE%TYPE,
         party_id                   WSH_NEW_DELIVERIES.PARTY_ID%TYPE,
         shipping_control           WSH_NEW_DELIVERIES.SHIPPING_CONTROL%TYPE,
         vendor_id                  WSH_NEW_DELIVERIES.VENDOR_ID%TYPE,
         organization_id            NUMBER,
         customer_id                NUMBER,
         fob_code                   WSH_DELIVERY_DETAILS.FOB_CODE%TYPE,
         intmed_ship_to_location_id NUMBER,
         carrier_id                 NUMBER,
         shipment_direction         WSH_NEW_DELIVERIES.SHIPMENT_DIRECTION%TYPE,
         additional_shipment_info   WSH_NEW_DELIVERIES.ADDITIONAL_SHIPMENT_INFO%TYPE,
         gross_weight               WSH_NEW_DELIVERIES.GROSS_WEIGHT%TYPE,
         net_weight                 WSH_NEW_DELIVERIES.NET_WEIGHT%TYPE,
         weight_uom_code            WSH_NEW_DELIVERIES.WEIGHT_UOM_CODE%TYPE,
         volume                     WSH_NEW_DELIVERIES.VOLUME%TYPE,
         volume_uom_code            WSH_NEW_DELIVERIES.VOLUME_UOM_CODE%TYPE,
         pooled_ship_to_location_id WSH_NEW_DELIVERIES.POOLED_SHIP_TO_LOCATION_ID%TYPE,
         dock_code                  WSH_NEW_DELIVERIES.DOCK_CODE%TYPE,
         ilines_count               NUMBER, -- count interface lines in plan
         lines_count                NUMBER, -- count delivery lines mapped
         s_lines_count              NUMBER, -- count delivery lines released to warehouse
         dangling_conts_count       NUMBER, -- count dangling topmost containers
         wms_org_flag               VARCHAR2(1),
         assign_details_count       NUMBER,
         leg_base_index             NUMBER,
         wv_frozen_flag             WSH_NEW_DELIVERIES.WV_FROZEN_FLAG%TYPE,
         physical_ultimate_do_loc_id NUMBER -- internal org location to drop off
     );
TYPE plan_delivery_tab_type IS TABLE OF plan_delivery_rec_type INDEX BY BINARY_INTEGER;



TYPE plan_leg_rec_type IS RECORD (
         leg_interface_id           NUMBER,
         delivery_leg_id            NUMBER,
         del_interface_id           NUMBER,
         delivery_index             NUMBER,
         pickup_stop_index          NUMBER,
         dropoff_stop_index         NUMBER,
         trip_index                 NUMBER
     );
TYPE plan_leg_tab_type IS TABLE OF plan_leg_rec_type INDEX BY BINARY_INTEGER;



TYPE plan_stop_rec_type IS RECORD (
          stop_interface_id         NUMBER,
          stop_id                   NUMBER,
          tp_stop_id                NUMBER,
          trip_index                NUMBER,
          stop_location_id          NUMBER,
          stop_sequence_number      NUMBER,
          planned_arrival_date      DATE,
          planned_departure_date    DATE,
          departure_gross_weight    NUMBER,
          departure_net_weight      NUMBER,
          weight_uom_code           WSH_TRIP_STOPS.WEIGHT_UOM_CODE%TYPE,
          departure_volume          NUMBER,
          volume_uom_code           WSH_TRIP_STOPS.VOLUME_UOM_CODE%TYPE,
          departure_seal_code       WSH_TRIP_STOPS.DEPARTURE_SEAL_CODE%TYPE,
          departure_fill_percent    NUMBER,
          wkend_layover_stops       WSH_TRIP_STOPS.wkend_layover_stops%TYPE,
          wkday_layover_stops       WSH_TRIP_STOPS.wkday_layover_stops%TYPE,
          shipments_type_flag       WSH_TRIP_STOPS.shipments_type_flag%TYPE,
          wv_frozen_flag            WSH_TRIP_STOPS.wv_frozen_flag%TYPE,
          internal_do_count         NUMBER, -- count of internal customer location drop-offs
          external_pd_count         NUMBER, -- count of pickup/dropoff activities at this physical stop
          wsh_physical_location_id  NUMBER  -- if populated, plan stop has been mapped to a TE internal stop
     );
TYPE plan_stop_tab_type IS TABLE OF plan_stop_rec_type INDEX BY BINARY_INTEGER;



TYPE plan_trip_rec_type IS RECORD (
         trip_interface_id          NUMBER,
         trip_id                    NUMBER,
         tp_plan_name               WSH_TRIPS.TP_PLAN_NAME%TYPE,
         tp_trip_number             WSH_TRIPS.TP_TRIP_NUMBER%TYPE,
         planned_flag               WSH_TRIPS.PLANNED_FLAG%TYPE,
         wsh_planned_flag           WSH_TRIPS.PLANNED_FLAG%TYPE,
         stop_base_index            NUMBER,
         name                       WSH_TRIPS.NAME%TYPE,
         vehicle_item_id            WSH_TRIPS.VEHICLE_ITEM_ID%TYPE,
         vehicle_organization_id    WSH_TRIPS.VEHICLE_ORGANIZATION_ID%TYPE,
         vehicle_num_prefix         WSH_TRIPS.VEHICLE_NUM_PREFIX%TYPE,
         vehicle_number             WSH_TRIPS.VEHICLE_NUMBER%TYPE,
         carrier_id                 WSH_TRIPS.CARRIER_ID%TYPE,
         ship_method_code           WSH_TRIPS.SHIP_METHOD_CODE%TYPE,
         route_id                   WSH_TRIPS.ROUTE_ID%TYPE,
         routing_instructions       WSH_TRIPS.ROUTING_INSTRUCTIONS%TYPE,
         service_level              WSH_TRIPS.SERVICE_LEVEL%TYPE,
         mode_of_transport          WSH_TRIPS.MODE_OF_TRANSPORT%TYPE,
         freight_terms_code         WSH_TRIPS.FREIGHT_TERMS_CODE%TYPE,
         seal_code                  WSH_TRIPS.SEAL_CODE%TYPE,
         shipments_type_flag        WSH_TRIPS.SHIPMENTS_TYPE_FLAG%TYPE,
         consolidation_allowed      WSH_TRIPS.CONSOLIDATION_ALLOWED%TYPE,
         schedule_id                WSH_TRIPS.SCHEDULE_ID%TYPE,
         route_lane_id              WSH_TRIPS.ROUTE_LANE_ID%TYPE,
         lane_id                    WSH_TRIPS.LANE_ID%TYPE,
         booking_number             WSH_TRIPS.BOOKING_NUMBER%TYPE,
         vessel                     WSH_TRIPS.VESSEL%TYPE,
         voyage_number              WSH_TRIPS.VOYAGE_NUMBER%TYPE,
         port_of_loading            WSH_TRIPS.PORT_OF_LOADING%TYPE,
         port_of_discharge          WSH_TRIPS.PORT_OF_DISCHARGE%TYPE,
         carrier_contact_id         WSH_TRIPS.CARRIER_CONTACT_ID%TYPE,
         shipper_wait_time          WSH_TRIPS.SHIPPER_WAIT_TIME%TYPE,
         wait_time_uom              WSH_TRIPS.WAIT_TIME_UOM%TYPE,
         carrier_response           WSH_TRIPS.CARRIER_RESPONSE%TYPE,
         operator                   WSH_TRIPS.OPERATOR%TYPE,
         linked_stop_count          NUMBER -- count of physical stops with both internal drop offs and external activities
     );
TYPE plan_trip_tab_type IS TABLE OF plan_trip_rec_type INDEX BY BINARY_INTEGER;


TYPE used_detail_rec_type IS RECORD (
         delivery_detail_id           NUMBER,
         dd_interface_id              NUMBER,
         available_quantity           NUMBER,
         available_quantity_uom       WSH_DELIVERY_DETAILS.REQUESTED_QUANTITY_UOM%TYPE,
         current_delivery_id          NUMBER,
         topmost_cont_id              NUMBER,
         target_delivery_index        NUMBER,
         track_cont_content_found     BOOLEAN,
         released_status              VARCHAR2(1),
         move_order_line_id           NUMBER,
         split_count                  NUMBER,
         need_unassignment            BOOLEAN,
         organization_id              NUMBER,
         line_direction               WSH_DELIVERY_DETAILS.LINE_DIRECTION%TYPE
     );
TYPE used_details_tab_type IS TABLE OF used_detail_rec_type INDEX BY BINARY_INTEGER;



TYPE track_cont_rec_type IS RECORD(
          topmost_cont_id              NUMBER,
          line_dd_interface_id         NUMBER,
          plan_dd_index                NUMBER, -- inbound/drop: index to x_plan_details for first line
          current_delivery_id          NUMBER,
          target_delivery_index        NUMBER,
          lines_staged                 BOOLEAN,
          cont_content_base_index      NUMBER,
          lpn_id                       NUMBER,
          released_status              VARCHAR2(1),
          source_code                  WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE,
          organization_id              NUMBER
     );
TYPE track_cont_tab_type IS TABLE OF track_cont_rec_type INDEX BY BINARY_INTEGER;



TYPE track_cont_content_rec_type IS RECORD(
          track_cont_index          NUMBER,
          delivery_detail_id        NUMBER
     );
TYPE track_cont_content_tab_type IS TABLE OF track_cont_content_rec_type INDEX BY BINARY_INTEGER;



TYPE delivery_unassign_rec IS RECORD (
         delivery_detail_id         NUMBER,
         delivery_id                NUMBER,
         organization_id            NUMBER,
         container_flag             VARCHAR2(1),
         lines_staged               BOOLEAN,
         wms_org_flag               VARCHAR2(1),
         source_code                WSH_DELIVERY_DETAILS.SOURCE_CODE%TYPE,
         released_status            WSH_DELIVERY_DETAILS.RELEASED_STATUS%TYPE,
         lpn_id                     NUMBER,
         plan_dd_index              NUMBER,  -- index to x_plan_details for plan line
         plan_del_index             NUMBER,  -- index to x_plan_deliveries for plan delivery
         wv_frozen_flag             WSH_NEW_DELIVERIES.WV_FROZEN_FLAG%TYPE,
         initial_pickup_location_id WSH_NEW_DELIVERIES.INITIAL_PICKUP_LOCATION_ID%TYPE
     );
TYPE delivery_unassign_tab_type IS TABLE OF delivery_unassign_rec INDEX BY BINARY_INTEGER;



TYPE trip_unassign_rec IS RECORD (
         delivery_id         NUMBER,
         organization_id     NUMBER,
         trip_id             NUMBER,
         trip_index          NUMBER,
         delivery_leg_id     NUMBER,
         pickup_stop_id      NUMBER,
         dropoff_stop_id     NUMBER
     );
TYPE trip_unassign_tab_type IS TABLE OF trip_unassign_rec INDEX BY BINARY_INTEGER;


TYPE obsoleted_stop_rec IS RECORD (
          trip_id            NUMBER,
          stop_id            NUMBER
     );
TYPE obsoleted_stop_tab_type IS TABLE OF obsoleted_stop_rec INDEX BY BINARY_INTEGER;


TYPE context_rec_type IS RECORD (
          group_id                  NUMBER,
          wms_in_group              BOOLEAN,
          wv_exception_details wsh_util_core.id_tab_type,
          wv_exception_dels wsh_util_core.id_tab_type,
          wv_exception_stops wsh_util_core.id_tab_type,
          auto_tender_flag          VARCHAR2(1),
          linked_trip_count         NUMBER -- count of trips having linked stops
     );



--
--  Procedure:          release_plan
--  Parameters:
--               p_group_ids           list of group_ids to process their
--                                     WSH_TRIPS_INTERFACE records and
--                                     their associated tables' records.
--               p_commit_flag         Y - commit changes; N - do not commit
--               x_return_status       return status
--
--  Description:
--               Reconciliate shipping data with the transportation
--               plan populated in the WSH and FTE interface tables.
--
--
PROCEDURE release_plan(
  p_group_ids              IN            WSH_TP_RELEASE_GRP.id_tab_type,
  p_commit_flag            IN            VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2);


--
--  Procedure:          purge_interface_tables
--  Parameters:
--               p_group_ids           list of group_ids to purge their
--                                     WSH_TRIPS_INTERFACE records and
--                                     their associated tables' records.
--                                     WSH_INTERFACE_ERRORS will be purged.
--               p_commit_flag         Y - commit changes; N - do not commit
--               x_return_status       return status
--
--  Description:
--               Delete the records from WSH and FTE interface tables.
--
PROCEDURE purge_interface_tables(
  p_group_ids              IN            WSH_TP_RELEASE_GRP.id_tab_type,
  p_commit_flag            IN            VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2);



--
--  Procedure:          stamp_interface_error
--  Parameters:
--               p_group_id            group identifier where the error is found
--               p_entity_table_name   entity table where the error is found
--               p_entity_interface_id record where the error is found
--               p_message_name        message name identifying the error
--               p_message_appl        message application name (NULL means 'WSH')
--               p_message_text        optional text for output to the user-
--               p_token_1_name        optional token 1 name
--               p_token_1_value       optional token 1 value
--               p_token_2_name        optional token 2 name
--               p_token_2_value       optional token 2 value
--               p_token_3_name        optional token 3 name
--               p_token_3_value       optional token 3 value
--               p_token_4_name        optional token 4 name
--               p_token_4_value       optional token 4 value
--               p_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               puts the error information into the list p_errors_tab
--
PROCEDURE stamp_interface_error(
            p_group_id           IN            NUMBER,
            p_entity_table_name  IN            VARCHAR2,
            p_entity_interface_id   IN         NUMBER,
            p_message_name       IN            VARCHAR2,
            p_message_appl       IN            VARCHAR2 DEFAULT NULL,
            p_message_text       IN            VARCHAR2 DEFAULT NULL,
            p_token_1_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_1_value      IN            VARCHAR2 DEFAULT NULL,
            p_token_2_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_2_value      IN            VARCHAR2 DEFAULT NULL,
            p_token_3_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_3_value      IN            VARCHAR2 DEFAULT NULL,
            p_token_4_name       IN            VARCHAR2 DEFAULT NULL,
            p_token_4_value      IN            VARCHAR2 DEFAULT NULL,
            x_errors_tab         IN OUT NOCOPY interface_errors_tab_type,
            x_return_status         OUT NOCOPY VARCHAR2);



END WSH_TP_RELEASE_INT;

 

/
