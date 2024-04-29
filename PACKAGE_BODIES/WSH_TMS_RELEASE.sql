--------------------------------------------------------
--  DDL for Package Body WSH_TMS_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TMS_RELEASE" as
/* $Header: WSHTMRLB.pls 120.12.12010000.4 2009/12/03 14:24:22 anvarshn ship $ */

G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TMS_RELEASE';

--
-- Forward Declaration of Internal procedures
--
PROCEDURE stamp_interface_error(
            p_group_id            IN            NUMBER,
            p_entity_table_name   IN            VARCHAR2,
            p_entity_interface_id IN            NUMBER,
            p_message_name        IN            VARCHAR2,
            p_message_appl        IN            VARCHAR2 DEFAULT NULL,
            p_message_text        IN            VARCHAR2 DEFAULT NULL,
            p_token_1_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_1_value       IN            VARCHAR2 DEFAULT NULL,
            p_token_2_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_2_value       IN            VARCHAR2 DEFAULT NULL,
            p_token_3_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_3_value       IN            VARCHAR2 DEFAULT NULL,
            p_token_4_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_4_value       IN            VARCHAR2 DEFAULT NULL,
            p_dleg_tab            IN            TMS_DLEG_TAB_TYPE,
            x_errors_tab          IN OUT NOCOPY INTERFACE_ERRORS_TAB_TYPE,
            x_return_status          OUT NOCOPY VARCHAR2);

PROCEDURE compare_trip_for_deliveries
  (p_dleg_tab         IN OUT NOCOPY TMS_DLEG_TAB_TYPE,
   p_trip_id          IN            NUMBER,
   x_unassign_id_tab  IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
   --x_unassign_ver_tab IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
   x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE process_internal_locations
  (x_delivery_tab IN OUT NOCOPY TMS_DLEG_TAB_TYPE,
   x_stop_tab     IN OUT NOCOPY TMS_STOP_TAB_TYPE,
   x_return_status   OUT NOCOPY VARCHAR2);

-- Get Server Time for Timezone conversion
PROCEDURE get_server_time
  (p_source_time            IN      DATE,
   p_source_timezone_code   IN      VARCHAR2,
   x_server_time               OUT  NOCOPY DATE,
   x_return_status             OUT  NOCOPY VARCHAR2,
   x_msg_count                 OUT  NOCOPY NUMBER,
   x_msg_data                  OUT  NOCOPY VARCHAR2);


-- End of Forward Declarations
--

--====================================================
--
-- Procedure: Release_planned_shipment
-- Description: This procedure processes the data populated in the Interface
--              tables by the BPEL Inbound process.
-- parameters
--  IN:
--      p_group_id           list of group_ids to process their
--                           WSH_TRIPS_INTERFACE records and
--                           their associated table records.
--
--      p_latest_version     if 'Y'/null then process only if inbound delivery
--                           tms_version_number matches on the EBS delivery.
--                           if 'N' then process the all inbound deliveries
--                           irrespective of version number but EBS delivery
--                           tms_interface_flag should be 'UP'/'UR'.
--                           tms_interface_flag will be remain at 'UR'/'UP' when
--                           procesed the lower version delivery.
--
--      p_tp_plan_low        process all trips from wsh_trip_interface
--                           table which are having tp_plan_name greater than or
--                           equal to 'p_tp_plan_low'
--
--      p_tp_plan_high       process all trips from wsh_trip_interface
--                           table which are having tp_plan_name less than or
--                           equal to 'p_tp_plan_high'
--
--      p_dummy              Dummy parameter to disable
--                           p_del_name_low,p_del_name_high
--                           p_organization_id,p_del_pickup_date_low and
--                           p_del_pickup_date_high
--                           on the concurrent program parameters windonw
--                           when entered p_tp_plan_low/p_tp_plan_high.
--
--      Organization_id      Process all shipments which are associated to the
--                           OTM enabled organization id.
--
--      p_del_name_low       Process all shipments which are associated to the
--                           deliveries from wsh_new_del_interface which
--                           having delivery name greater than or equal to
--                            p_del_name_low
--
--      p_del_name_high      Process all shipments which are associated to the
--                           deliveries from wsh_new_del_interface which
--                           having delivery name less than or equal to
--                           p_del_name_high
--
--     p_del_pickup_date_low Process all shipments which are associated to the
--                           deliveries which having initial pickup date
--                           greater than or equal to p_del_pickup_date_low
--
--     p_del_pickup_date_high low Process all shipments which are associated to
--                            the deliveries which having initial pickup date
--                            less than or equal to p_del_pickup_date_high
--  OUT:
--      errbuf       Error message.
--      retcode      Error Code 1:Successs, 2:Warning and 3:Error.
--
-- Usage:
-- 1. Glog triggered Inbound BPEL process will call the concurrent program
--    to call this procedure
-- 2. When user fixes interface errors and re-processes the data, this
--    procedure is called(from Interface Message Corrections Form)
-- Assumption: This procedure is called for a single group id
--
-- 3. When user submits the planned shipment con. request manually.
-- The process flow would be in this order
--
-- Process group_id(single id only and not table of ids)
--   Initialize table of unassigned_delivery_ids.
--1.	Gather Trips Interface Data for the input group id
--2.	Gather Trip Stops Interface Data for the input group id
--      trip_interface_id is also populated for linking purpose
--3.	Gather Delivery Legs Interface Data for the input group id
--      trip_interface_id is also populated for linking purpose
--4.	LOOP Start with 1st trip record,
--      ai.  If trip exists in EBS,Lock Trip (call Table Handler)
--      aii. If trip exists in EBS,Lock Trip Stops (call Table Handler)
--      b.  Lock Delivery/Delivery Legs + compare revision (call Table Handler)
--      c.  Process Trips: create/update
--      d.  Process Trip Stops: delete/update/create
--      e.  Process Deliveries: assign/unassign
-- OTM R12
--      f.  This step is no longer required as trip weight is calculated in previous step itself
--          Calculate wt/vol for the trip (includes stops) (call Group API)
-- OTM R12
--      g.  Freight Costs
--      h.  Stamping the loading sequence number for WMS org
--      i.  Calling WMS api to send the Dock Appointment info. from OTM to WMS for WMS org.
--      j.  If any errors exist, then log errors in wsh_interface_errors table and
--          (error)exceptions for all the deliveries within this GC3 trip (as per l_dleg_info_tab)
--          Elsif no errors encountered: Log (info only) Delivery Exception, Update Interface Status
--          to 'ANSWER_RECEIVED', Purge
--	END LOOP;
--5.  For group_id, Update delivery status based on unassigned_delivery_ids,
--    Update the Table directly and not call WSHDETHB.update_tms_interface_flag
--    to AWAITING_ANSWER
--    Do not mark these deliveries as ignore for planning.
--
--====================================================
-- Bug#7491598(ER,defer planned shipment iface): Added new parameters which are used
-- when invoked the planned shipment interface manually.
PROCEDURE release_planned_shipment(
  errbuf                   OUT NOCOPY   VARCHAR2,
  retcode                  OUT NOCOPY   VARCHAR2,
  p_group_id               IN           NUMBER   DEFAULT NULL,
  p_latest_version         IN           VARCHAR2 DEFAULT NULL,
  p_tp_plan_low            IN           VARCHAR2 DEFAULT NULL,
  p_tp_plan_high           IN           VARCHAR2 DEFAULT NULL,
  p_dummy                  IN           VARCHAR2 DEFAULT NULL,
  p_deploy_mode            IN           VARCHAR2 DEFAULT NULL, -- Modified R12.1.1 LSP PROJECT
  p_client_id              IN           NUMBER   DEFAULT NULL, -- Modified R12.1.1 LSP PROJECT
  p_organization_id        IN           NUMBER   DEFAULT NULL,
  p_del_name_low           IN           VARCHAR2 DEFAULT NULL,
  p_del_name_high          IN           VARCHAR2 DEFAULT NULL,
  p_del_pickup_date_low    IN           VARCHAR2 DEFAULT NULL,
  p_del_pickup_date_high   IN           VARCHAR2 DEFAULT NULL
  ) IS

  -- Cursor to fetch Trip information for the input group id
  CURSOR c_tms_interface_trips IS
    SELECT wti.trip_interface_id,
           wti.group_id, --Bug7717569
           wt.trip_id,
           wti.tp_plan_name,
           wt.tp_trip_number,
           wti.planned_flag,
           wt.planned_flag                   wsh_planned_flag,
           wt.status_code                    wsh_status_code,
           wt.name,
           wti.vehicle_item_id,
           wti.vehicle_organization_id,
           wti.vehicle_num_prefix,
           wti.vehicle_number,
           wti.carrier_id                    carrier_id,
           wt.ship_method_code,
           wt.route_id,
           wt.routing_instructions,
           wti.service_level,
           wti.mode_of_transport,
           wti.freight_terms_code,
           wt.seal_code,
           wt.shipments_type_flag,
           'N'                               wsh_ignore_for_planning,
           wt.booking_number,
           wt.vessel,
           wt.voyage_number,
           wt.port_of_loading,
           wt.port_of_discharge,
           wt.carrier_contact_id,
           wt.shipper_wait_time,
           wt.wait_time_uom,
           wt.carrier_response,
           wt.operator,
           wti.vehicle_item_name,
           wti.interface_action_code,
           wt.attribute_category,
           wt.attribute1,
           wt.attribute2,
           wt.attribute3,
           wt.attribute4,
           wt.attribute5,
           wt.attribute6,
           wt.attribute7,
           wt.attribute8,
           wt.attribute9,
           wt.attribute10,
           wt.attribute11,
           wt.attribute12,
           wt.attribute13,
           wt.attribute14,
           wt.attribute15
      FROM wsh_trips_interface          wti,
           wsh_trips                    wt
     WHERE wti.group_id = p_group_id --p_group_id is the input parameter
       AND wti.interface_action_code  IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
       AND wt.tp_plan_name(+)         = wti.tp_plan_name
  ORDER BY wti.trip_interface_id;

  -- Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Trip information for the input tp plan name
  CURSOR c_tms_interface_trips_plan(p_tp_plan_low IN varchar2,p_tp_plan_high IN varchar2) IS
    SELECT wti.trip_interface_id,
           wti.group_id, --Bug7717569
           wt.trip_id,
           wti.tp_plan_name,
           wt.tp_trip_number,
           wti.planned_flag,
           wt.planned_flag                   wsh_planned_flag,
           wt.status_code                    wsh_status_code,
           wt.name,
           wti.vehicle_item_id,
           wti.vehicle_organization_id,
           wti.vehicle_num_prefix,
           wti.vehicle_number,
           wti.carrier_id                    carrier_id,
           wt.ship_method_code,
           wt.route_id,
           wt.routing_instructions,
           wti.service_level,
           wti.mode_of_transport,
           wti.freight_terms_code,
           wt.seal_code,
           wt.shipments_type_flag,
           'N'                               wsh_ignore_for_planning,
           wt.booking_number,
           wt.vessel,
           wt.voyage_number,
           wt.port_of_loading,
           wt.port_of_discharge,
           wt.carrier_contact_id,
           wt.shipper_wait_time,
           wt.wait_time_uom,
           wt.carrier_response,
           wt.operator,
           wti.vehicle_item_name,
           wti.interface_action_code,
           wt.attribute_category,
           wt.attribute1,
           wt.attribute2,
           wt.attribute3,
           wt.attribute4,
           wt.attribute5,
           wt.attribute6,
           wt.attribute7,
           wt.attribute8,
           wt.attribute9,
           wt.attribute10,
           wt.attribute11,
           wt.attribute12,
           wt.attribute13,
           wt.attribute14,
           wt.attribute15
      FROM wsh_trips_interface          wti,
           wsh_trips                    wt
     WHERE wti.tp_plan_name >= nvl(p_tp_plan_low,wti.tp_plan_name)
       AND  wti.tp_plan_name <= nvl(p_tp_plan_high,wti.tp_plan_name)
       AND wti.interface_action_code  IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
       AND wt.tp_plan_name(+)         = wti.tp_plan_name
  ORDER BY wti.trip_interface_id;

  -- Bug#7491598(ER,defer planned shipment iface):Cursor to fetch Trip information for the input delivery,org,and pickup dates.
  CURSOR c_tms_interface_trips_del(p_del_name_low varchar2,p_del_name_high varchar2,l_organization_id NUMBER,l_del_pickup_date_low DATE,l_del_pickup_date_high DATE,p_client_id NUMBER) IS -- Modified R12.1.1 LSP PROJECT
    SELECT wti.trip_interface_id,
           wti.group_id, --Bug7717569
           wt.trip_id,
           wti.tp_plan_name,
           wt.tp_trip_number,
           wti.planned_flag,
           wt.planned_flag                   wsh_planned_flag,
           wt.status_code                    wsh_status_code,
           wt.name,
           wti.vehicle_item_id,
           wti.vehicle_organization_id,
           wti.vehicle_num_prefix,
           wti.vehicle_number,
           wti.carrier_id                    carrier_id,
           wt.ship_method_code,
           wt.route_id,
           wt.routing_instructions,
           wti.service_level,
           wti.mode_of_transport,
           wti.freight_terms_code,
           wt.seal_code,
           wt.shipments_type_flag,
           'N'                               wsh_ignore_for_planning,
           wt.booking_number,
           wt.vessel,
           wt.voyage_number,
           wt.port_of_loading,
           wt.port_of_discharge,
           wt.carrier_contact_id,
           wt.shipper_wait_time,
           wt.wait_time_uom,
           wt.carrier_response,
           wt.operator,
           wti.vehicle_item_name,
           wti.interface_action_code,
           wt.attribute_category,
           wt.attribute1,
           wt.attribute2,
           wt.attribute3,
           wt.attribute4,
           wt.attribute5,
           wt.attribute6,
           wt.attribute7,
           wt.attribute8,
           wt.attribute9,
           wt.attribute10,
           wt.attribute11,
           wt.attribute12,
           wt.attribute13,
           wt.attribute14,
           wt.attribute15
      FROM wsh_trips_interface          wti,
           wsh_trips                    wt
     WHERE wti.interface_action_code  IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
       AND wt.tp_plan_name(+)         = wti.tp_plan_name
       AND wti.group_id in
       (SELECT wti.group_id FROM  wsh_new_del_interface wndi,
         wsh_del_legs_interface wdli,
         wsh_trip_stops_interface wtsi,
         wsh_trips_interface wti,
         wsh_new_deliveries wnd
     where wndi.interface_action_code IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
     AND wdli.delivery_interface_id = wndi.delivery_interface_id
     AND wdli.pick_up_stop_interface_id = wtsi.stop_interface_id
     AND wtsi.trip_interface_id = wti.trip_interface_id
     AND wnd.delivery_id = wndi.delivery_id
     AND wndi.name >= nvl(p_del_name_low,wndi.name)
     AND wndi.name <= nvl(p_del_name_high,wndi.name)
     AND wnd.organization_id = NVL(l_organization_id,wnd.organization_id)
     AND wnd.initial_pickup_date >= nvl(l_del_pickup_date_low,wnd.initial_pickup_date)
     AND wnd.initial_pickup_date <= nvl(l_del_pickup_date_high,wnd.initial_pickup_date)
     AND NVL(wnd.client_id , -1)= NVL(NVL(p_client_id,wnd.client_id), -1) -- Modified R12.1.1 LSP PROJECT
     )
  ORDER BY wti.trip_interface_id;

  --Bug#7491598(ER,defer planned shipment iface):  Cursor to fetch Trip information for all group ids
  CURSOR c_tms_interface_trips_all IS
    SELECT wti.trip_interface_id,
           wti.group_id, --Bug7717569
           wt.trip_id,
           wti.tp_plan_name,
           wt.tp_trip_number,
           wti.planned_flag,
           wt.planned_flag                   wsh_planned_flag,
           wt.status_code                    wsh_status_code,
           wt.name,
           wti.vehicle_item_id,
           wti.vehicle_organization_id,
           wti.vehicle_num_prefix,
           wti.vehicle_number,
           wti.carrier_id                    carrier_id,
           wt.ship_method_code,
           wt.route_id,
           wt.routing_instructions,
           wti.service_level,
           wti.mode_of_transport,
           wti.freight_terms_code,
           wt.seal_code,
           wt.shipments_type_flag,
           'N'                               wsh_ignore_for_planning,
           wt.booking_number,
           wt.vessel,
           wt.voyage_number,
           wt.port_of_loading,
           wt.port_of_discharge,
           wt.carrier_contact_id,
           wt.shipper_wait_time,
           wt.wait_time_uom,
           wt.carrier_response,
           wt.operator,
           wti.vehicle_item_name,
           wti.interface_action_code,
           wt.attribute_category,
           wt.attribute1,
           wt.attribute2,
           wt.attribute3,
           wt.attribute4,
           wt.attribute5,
           wt.attribute6,
           wt.attribute7,
           wt.attribute8,
           wt.attribute9,
           wt.attribute10,
           wt.attribute11,
           wt.attribute12,
           wt.attribute13,
           wt.attribute14,
           wt.attribute15
      FROM wsh_trips_interface          wti,
           wsh_trips                    wt
     WHERE wti.interface_action_code  IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
       AND wt.tp_plan_name(+)         = wti.tp_plan_name
  ORDER BY wti.trip_interface_id;


  -- Cursor to fetch Trip Stop information for the input group id(Order by trip_interface_id)
  CURSOR c_tms_interface_stops IS
    SELECT wtsi.stop_interface_id,
           wtsi.stop_id, -- will be populated after create or update, not from GC3
           wtsi.tp_stop_id,
           wtsi.stop_location_id,
           wtsi.stop_sequence_number,
           wtsi.planned_arrival_date,
           wtsi.planned_departure_date,
           wtsi.departure_gross_weight,
           wtsi.departure_net_weight,
           wtsi.weight_uom_code,
           wtsi.departure_volume,
           wtsi.volume_uom_code,
           wtsi.departure_seal_code,
           wtsi.departure_fill_percent,
           wtsi.wkend_layover_stops,
           wtsi.wkday_layover_stops,
           wtsi.shipments_type_flag,
           wtsi.trip_interface_id,
           wtsi.timezone_code,
           'C' dml_action,           -- indicates if stop has to be created or updated
           null tp_attribute_category,
           null tp_attribute1,
           null tp_attribute2,
           null tp_attribute3,
           null tp_attribute4,
           null tp_attribute5,
           null tp_attribute6,
           null tp_attribute7,
           null tp_attribute8,
           null tp_attribute9,
           null tp_attribute10,
           null tp_attribute11,
           null tp_attribute12,
           null tp_attribute13,
           null tp_attribute14,
           null tp_attribute15,
           null attribute_category,
           null attribute1,
           null attribute2,
           null attribute3,
           null attribute4,
           null attribute5,
           null attribute6,
           null attribute7,
           null attribute8,
           null attribute9,
           null attribute10,
           null attribute11,
           null attribute12,
           null attribute13,
           null attribute14,
           null attribute15
      FROM wsh_trip_stops_interface     wtsi,
           wsh_trips_interface          wti
     WHERE wti.group_id = p_group_id --p_group_id is the input parameter
       AND wtsi.trip_interface_id      = wti.trip_interface_id
       AND wtsi.interface_action_code  = G_TMS_RELEASE_CODE
       AND wti.interface_action_code   = G_TMS_RELEASE_CODE
  ORDER BY wtsi.trip_interface_id,wtsi.stop_sequence_number ;

  --Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Trip Stop information for the input tp plan names(Order by trip_interface_id)
  CURSOR c_tms_interface_stops_plan(p_tp_plan_low varchar2,p_tp_plan_high varchar2) IS
    SELECT wtsi.stop_interface_id,
           wtsi.stop_id, -- will be populated after create or update, not from GC3
           wtsi.tp_stop_id,
           wtsi.stop_location_id,
           wtsi.stop_sequence_number,
           wtsi.planned_arrival_date,
           wtsi.planned_departure_date,
           wtsi.departure_gross_weight,
           wtsi.departure_net_weight,
           wtsi.weight_uom_code,
           wtsi.departure_volume,
           wtsi.volume_uom_code,
           wtsi.departure_seal_code,
           wtsi.departure_fill_percent,
           wtsi.wkend_layover_stops,
           wtsi.wkday_layover_stops,
           wtsi.shipments_type_flag,
           wtsi.trip_interface_id,
           wtsi.timezone_code,
           'C' dml_action,           -- indicates if stop has to be created or updated
           null tp_attribute_category,
           null tp_attribute1,
           null tp_attribute2,
           null tp_attribute3,
           null tp_attribute4,
           null tp_attribute5,
           null tp_attribute6,
           null tp_attribute7,
           null tp_attribute8,
           null tp_attribute9,
           null tp_attribute10,
           null tp_attribute11,
           null tp_attribute12,
           null tp_attribute13,
           null tp_attribute14,
           null tp_attribute15,
           null attribute_category,
           null attribute1,
           null attribute2,
           null attribute3,
           null attribute4,
           null attribute5,
           null attribute6,
           null attribute7,
           null attribute8,
           null attribute9,
           null attribute10,
           null attribute11,
           null attribute12,
           null attribute13,
           null attribute14,
           null attribute15
      FROM wsh_trip_stops_interface     wtsi,
           wsh_trips_interface          wti
     WHERE wti.tp_plan_name >= nvl(p_tp_plan_low,wti.tp_plan_name)
       AND  wti.tp_plan_name <= nvl(p_tp_plan_high,wti.tp_plan_name)
       AND wtsi.trip_interface_id      = wti.trip_interface_id
       AND wtsi.interface_action_code  = G_TMS_RELEASE_CODE
       AND wti.interface_action_code   = G_TMS_RELEASE_CODE
  ORDER BY wtsi.trip_interface_id,wtsi.stop_sequence_number ;

  --Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Trip Stop information for the input delivery (Order by trip_interface_id)
  CURSOR c_tms_interface_stops_del(p_del_name_low varchar2,p_del_name_high varchar2,l_organization_id NUMBER,l_del_pickup_date_low DATE,l_del_pickup_date_high DATE,p_client_id NUMBER) IS-- Modified R12.1.1 LSP PROJECT
    SELECT wtsi.stop_interface_id,
           wtsi.stop_id, -- will be populated after create or update, not from GC3
           wtsi.tp_stop_id,
           wtsi.stop_location_id,
           wtsi.stop_sequence_number,
           wtsi.planned_arrival_date,
           wtsi.planned_departure_date,
           wtsi.departure_gross_weight,
           wtsi.departure_net_weight,
           wtsi.weight_uom_code,
           wtsi.departure_volume,
           wtsi.volume_uom_code,
           wtsi.departure_seal_code,
           wtsi.departure_fill_percent,
           wtsi.wkend_layover_stops,
           wtsi.wkday_layover_stops,
           wtsi.shipments_type_flag,
           wtsi.trip_interface_id,
           wtsi.timezone_code,
           'C' dml_action,           -- indicates if stop has to be created or updated
           null tp_attribute_category,
           null tp_attribute1,
           null tp_attribute2,
           null tp_attribute3,
           null tp_attribute4,
           null tp_attribute5,
           null tp_attribute6,
           null tp_attribute7,
           null tp_attribute8,
           null tp_attribute9,
           null tp_attribute10,
           null tp_attribute11,
           null tp_attribute12,
           null tp_attribute13,
           null tp_attribute14,
           null tp_attribute15,
           null attribute_category,
           null attribute1,
           null attribute2,
           null attribute3,
           null attribute4,
           null attribute5,
           null attribute6,
           null attribute7,
           null attribute8,
           null attribute9,
           null attribute10,
           null attribute11,
           null attribute12,
           null attribute13,
           null attribute14,
           null attribute15
      FROM wsh_trip_stops_interface     wtsi,
           wsh_trips_interface          wti
     WHERE wtsi.trip_interface_id      = wti.trip_interface_id
       AND wtsi.interface_action_code  = G_TMS_RELEASE_CODE
       AND wti.interface_action_code   = G_TMS_RELEASE_CODE
       AND wti.group_id in
       (SELECT wti.group_id FROM  wsh_new_del_interface wndi,
         wsh_del_legs_interface wdli,
         wsh_trip_stops_interface wtsi,
         wsh_trips_interface wti,
         wsh_new_deliveries wnd
     where wndi.interface_action_code IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
     AND wdli.delivery_interface_id = wndi.delivery_interface_id
     AND wdli.pick_up_stop_interface_id = wtsi.stop_interface_id
     AND wtsi.trip_interface_id = wti.trip_interface_id
     AND wnd.delivery_id = wndi.delivery_id
     AND wndi.name >= nvl(p_del_name_low,wndi.name)
     AND wndi.name <= nvl(p_del_name_high,wndi.name)
     AND wnd.organization_id = NVL(p_organization_id,wnd.organization_id)
     AND wnd.initial_pickup_date >= nvl(l_del_pickup_date_low,wnd.initial_pickup_date)
     AND wnd.initial_pickup_date <= nvl(l_del_pickup_date_high,wnd.initial_pickup_date)
     AND NVL(wnd.client_id , -1)= NVL(NVL(p_client_id,wnd.client_id), -1))  -- Modified R12.1.1 LSP PROJECT
  ORDER BY wtsi.trip_interface_id,wtsi.stop_sequence_number ;

--Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Trip Stop information for the all group ids (Order by trip_interface_id)
  CURSOR c_tms_interface_stops_all IS
    SELECT wtsi.stop_interface_id,
           wtsi.stop_id, -- will be populated after create or update, not from GC3
           wtsi.tp_stop_id,
           wtsi.stop_location_id,
           wtsi.stop_sequence_number,
           wtsi.planned_arrival_date,
           wtsi.planned_departure_date,
           wtsi.departure_gross_weight,
           wtsi.departure_net_weight,
           wtsi.weight_uom_code,
           wtsi.departure_volume,
           wtsi.volume_uom_code,
           wtsi.departure_seal_code,
           wtsi.departure_fill_percent,
           wtsi.wkend_layover_stops,
           wtsi.wkday_layover_stops,
           wtsi.shipments_type_flag,
           wtsi.trip_interface_id,
           wtsi.timezone_code,
           'C' dml_action,           -- indicates if stop has to be created or updated
           null tp_attribute_category,
           null tp_attribute1,
           null tp_attribute2,
           null tp_attribute3,
           null tp_attribute4,
           null tp_attribute5,
           null tp_attribute6,
           null tp_attribute7,
           null tp_attribute8,
           null tp_attribute9,
           null tp_attribute10,
           null tp_attribute11,
           null tp_attribute12,
           null tp_attribute13,
           null tp_attribute14,
           null tp_attribute15,
           null attribute_category,
           null attribute1,
           null attribute2,
           null attribute3,
           null attribute4,
           null attribute5,
           null attribute6,
           null attribute7,
           null attribute8,
           null attribute9,
           null attribute10,
           null attribute11,
           null attribute12,
           null attribute13,
           null attribute14,
           null attribute15
      FROM wsh_trip_stops_interface     wtsi,
           wsh_trips_interface          wti
     WHERE wtsi.trip_interface_id      = wti.trip_interface_id
       AND wtsi.interface_action_code  = G_TMS_RELEASE_CODE
       AND wti.interface_action_code   = G_TMS_RELEASE_CODE
  ORDER BY wtsi.trip_interface_id,wtsi.stop_sequence_number ;


  -- Cursor to fetch Delivery Leg information for the input group id(order by trip_interface_id)
  CURSOR c_tms_interface_dlegs IS
    SELECT wdli.delivery_leg_interface_id,
           wdli.delivery_interface_id,
           wtsi_pu.stop_location_id     pickup_stop_location_id, -- pickup stop location
           wtsi_pu.stop_sequence_number pickup_stop_sequence,    -- pickup stop sequence
           wtsi_do.stop_location_id     dropoff_stop_location_id,-- dropoff stop location
           wtsi_do.stop_sequence_number dropoff_stop_sequence,   -- dropoff stop sequence
           wtsi_pu.trip_interface_id,                        -- trip_interface_id
           wdli.delivery_leg_id,
           wdli.delivery_id,
           wdli.pick_up_stop_interface_id,
           wdli.drop_off_stop_interface_id,
           wnd.weight_uom_code  weight_uom,
           wnd.volume_uom_code  volume_uom,
           wnd.organization_id,           -- Organization id, used for deriving default UOM
           wnd.tms_version_number,        -- used before locking the delivery and rollback updates
           wndi.tms_version_number otm_tms_version_number,  -- OTM sent Version number
           wnd.initial_pickup_location_id,-- used while logging exceptions
           wnd.ultimate_dropoff_location_id,-- used for internal Locations
           'N'  processed_flag,            -- used to indicate which deliveries have to be assigned
           wnd.tms_interface_flag          -- used to check whether tms version check can be avoided.
      FROM wsh_del_legs_interface       wdli,
           wsh_new_del_interface        wndi,
           wsh_trip_stops_interface     wtsi_pu,
           wsh_trip_stops_interface     wtsi_do,
           wsh_trips_interface          wti,
           wsh_new_deliveries           wnd
     WHERE wti.group_id = p_group_id --p_group_id is the input parameter
       AND wti.interface_action_code       = G_TMS_RELEASE_CODE
       AND wtsi_pu.trip_interface_id       = wti.trip_interface_id
       AND wtsi_pu.stop_interface_id       = wdli.pick_up_stop_interface_id
       AND wtsi_pu.interface_action_code   = G_TMS_RELEASE_CODE
       AND wtsi_do.trip_interface_id       = wti.trip_interface_id
       AND wtsi_do.stop_interface_id       = wdli.drop_off_stop_interface_id
       AND wtsi_do.interface_action_code   = G_TMS_RELEASE_CODE
       -- OTM R12 no need to have outer join
       AND wnd.delivery_id                 = wdli.delivery_id
       AND wndi.delivery_id                = wdli.delivery_id
       AND wdli.interface_action_code      = G_TMS_RELEASE_CODE
       --AND wnd.delivery_id(+)              = wdli.delivery_id
       --AND wnd.delivery_id                 = wndi.delivery_id
       -- OTM R12
       -- Fix Bug 5134725
       --AND nvl(wnd.tms_version_number,-99) = nvl(wndi.tms_version_number,-99) -- version number check
  ORDER BY wtsi_pu.trip_interface_id,wdli.sequence_number;

  --Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Delivery Leg information for the input plan (order by trip_interface_id)
  CURSOR c_tms_interface_dlegs_plan(p_tp_plan_low varchar2,p_tp_plan_high varchar2) IS
    SELECT wdli.delivery_leg_interface_id,
           wdli.delivery_interface_id,
           wtsi_pu.stop_location_id     pickup_stop_location_id, -- pickup stop location
           wtsi_pu.stop_sequence_number pickup_stop_sequence,    -- pickup stop sequence
           wtsi_do.stop_location_id     dropoff_stop_location_id,-- dropoff stop location
           wtsi_do.stop_sequence_number dropoff_stop_sequence,   -- dropoff stop sequence
           wtsi_pu.trip_interface_id,                        -- trip_interface_id
           wdli.delivery_leg_id,
           wdli.delivery_id,
           wdli.pick_up_stop_interface_id,
           wdli.drop_off_stop_interface_id,
           wnd.weight_uom_code  weight_uom,
           wnd.volume_uom_code  volume_uom,
           wnd.organization_id,           -- Organization id, used for deriving default UOM
           wnd.tms_version_number,        -- used before locking the delivery and rollback updates
           wndi.tms_version_number otm_tms_version_number,  -- OTM sent Version number
           wnd.initial_pickup_location_id,-- used while logging exceptions
           wnd.ultimate_dropoff_location_id,-- used for internal Locations
           'N'  processed_flag,            -- used to indicate which deliveries have to be assigned
           wnd.tms_interface_flag          -- used to check whether tms version check can be avoided.
      FROM wsh_del_legs_interface       wdli,
           wsh_new_del_interface        wndi,
           wsh_trip_stops_interface     wtsi_pu,
           wsh_trip_stops_interface     wtsi_do,
           wsh_trips_interface          wti,
           wsh_new_deliveries           wnd
     WHERE wti.tp_plan_name >= nvl(p_tp_plan_low,wti.tp_plan_name)
       AND  wti.tp_plan_name <= nvl(p_tp_plan_high,wti.tp_plan_name)
       AND wti.interface_action_code       = G_TMS_RELEASE_CODE
       AND wtsi_pu.trip_interface_id       = wti.trip_interface_id
       AND wtsi_pu.stop_interface_id       = wdli.pick_up_stop_interface_id
       AND wtsi_pu.interface_action_code   = G_TMS_RELEASE_CODE
       AND wtsi_do.trip_interface_id       = wti.trip_interface_id
       AND wtsi_do.stop_interface_id       = wdli.drop_off_stop_interface_id
       AND wtsi_do.interface_action_code   = G_TMS_RELEASE_CODE
       -- OTM R12 no need to have outer join
       AND wnd.delivery_id                 = wdli.delivery_id
       AND wndi.delivery_id                = wdli.delivery_id
       AND wdli.interface_action_code      = G_TMS_RELEASE_CODE
       --AND wnd.delivery_id(+)              = wdli.delivery_id
       --AND wnd.delivery_id                 = wndi.delivery_id
       -- OTM R12
       -- Fix Bug 5134725
       --AND nvl(wnd.tms_version_number,-99) = nvl(wndi.tms_version_number,-99) -- version number check
  ORDER BY wtsi_pu.trip_interface_id,wdli.sequence_number;

  --Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Delivery Leg information for the input del(order by trip_interface_id)
  CURSOR c_tms_interface_dlegs_del(p_del_name_low varchar2,p_del_name_high varchar2,l_organization_id NUMBER,l_del_pickup_date_low DATE,l_del_pickup_date_high DATE, p_client_id NUMBER) IS-- Modified R12.1.1 LSP PROJECT
    SELECT wdli.delivery_leg_interface_id,
           wdli.delivery_interface_id,
           wtsi_pu.stop_location_id     pickup_stop_location_id, -- pickup stop location
           wtsi_pu.stop_sequence_number pickup_stop_sequence,    -- pickup stop sequence
           wtsi_do.stop_location_id     dropoff_stop_location_id,-- dropoff stop location
           wtsi_do.stop_sequence_number dropoff_stop_sequence,   -- dropoff stop sequence
           wtsi_pu.trip_interface_id,                        -- trip_interface_id
           wdli.delivery_leg_id,
           wdli.delivery_id,
           wdli.pick_up_stop_interface_id,
           wdli.drop_off_stop_interface_id,
           wnd.weight_uom_code  weight_uom,
           wnd.volume_uom_code  volume_uom,
           wnd.organization_id,           -- Organization id, used for deriving default UOM
           wnd.tms_version_number,        -- used before locking the delivery and rollback updates
           wndi.tms_version_number otm_tms_version_number,  -- OTM sent Version number
           wnd.initial_pickup_location_id,-- used while logging exceptions
           wnd.ultimate_dropoff_location_id,-- used for internal Locations
           'N'  processed_flag,            -- used to indicate which deliveries have to be assigned
           wnd.tms_interface_flag          -- used to check whether tms version check can be avoided.
      FROM wsh_del_legs_interface       wdli,
           wsh_new_del_interface        wndi,
           wsh_trip_stops_interface     wtsi_pu,
           wsh_trip_stops_interface     wtsi_do,
           wsh_trips_interface          wti,
           wsh_new_deliveries           wnd
     WHERE wti.interface_action_code       = G_TMS_RELEASE_CODE
       AND wtsi_pu.trip_interface_id       = wti.trip_interface_id
       AND wtsi_pu.stop_interface_id       = wdli.pick_up_stop_interface_id
       AND wtsi_pu.interface_action_code   = G_TMS_RELEASE_CODE
       AND wtsi_do.trip_interface_id       = wti.trip_interface_id
       AND wtsi_do.stop_interface_id       = wdli.drop_off_stop_interface_id
       AND wtsi_do.interface_action_code   = G_TMS_RELEASE_CODE
       -- OTM R12 no need to have outer join
       AND wnd.delivery_id                 = wdli.delivery_id
       AND wndi.delivery_id                = wdli.delivery_id
       AND wdli.interface_action_code      = G_TMS_RELEASE_CODE
       AND wti.group_id in
       (SELECT wti.group_id FROM  wsh_new_del_interface wndi,
         wsh_del_legs_interface wdli,
         wsh_trip_stops_interface wtsi,
         wsh_trips_interface wti,
         wsh_new_deliveries wnd
     where wndi.interface_action_code IN (G_TMS_RELEASE_CODE,G_TMS_DELETE_CODE)
     AND wdli.delivery_interface_id = wndi.delivery_interface_id
     AND wdli.pick_up_stop_interface_id = wtsi.stop_interface_id
     AND wtsi.trip_interface_id = wti.trip_interface_id
     AND wnd.delivery_id = wndi.delivery_id
     AND wndi.name >= nvl(p_del_name_low,wndi.name)
     AND wndi.name <= nvl(p_del_name_high,wndi.name)
     AND wnd.organization_id = NVL(p_organization_id,wnd.organization_id)
     AND wnd.initial_pickup_date >= nvl(l_del_pickup_date_low,wnd.initial_pickup_date)
     AND wnd.initial_pickup_date <= nvl(l_del_pickup_date_high,wnd.initial_pickup_date)
     AND NVL(wnd.client_id,-1) = NVL(NVL(p_client_id,wnd.client_id),-1) -- Modified R12.1.1 LSP PROJECT
     )
  ORDER BY wtsi_pu.trip_interface_id,wdli.sequence_number;

 --Bug#7491598(ER,defer planned shipment iface): Cursor to fetch Delivery Leg information for all group ids(order by trip_interface_id)
  CURSOR c_tms_interface_dlegs_all IS
    SELECT wdli.delivery_leg_interface_id,
           wdli.delivery_interface_id,
           wtsi_pu.stop_location_id     pickup_stop_location_id, -- pickup stop location
           wtsi_pu.stop_sequence_number pickup_stop_sequence,    -- pickup stop sequence
           wtsi_do.stop_location_id     dropoff_stop_location_id,-- dropoff stop location
           wtsi_do.stop_sequence_number dropoff_stop_sequence,   -- dropoff stop sequence
           wtsi_pu.trip_interface_id,                        -- trip_interface_id
           wdli.delivery_leg_id,
           wdli.delivery_id,
           wdli.pick_up_stop_interface_id,
           wdli.drop_off_stop_interface_id,
           wnd.weight_uom_code  weight_uom,
           wnd.volume_uom_code  volume_uom,
           wnd.organization_id,           -- Organization id, used for deriving default UOM
           wnd.tms_version_number,        -- used before locking the delivery and rollback updates
           wndi.tms_version_number otm_tms_version_number,  -- OTM sent Version number
           wnd.initial_pickup_location_id,-- used while logging exceptions
           wnd.ultimate_dropoff_location_id,-- used for internal Locations
           'N'  processed_flag,            -- used to indicate which deliveries have to be assigned
           wnd.tms_interface_flag          -- used to check whether tms version check can be avoided.
      FROM wsh_del_legs_interface       wdli,
           wsh_new_del_interface        wndi,
           wsh_trip_stops_interface     wtsi_pu,
           wsh_trip_stops_interface     wtsi_do,
           wsh_trips_interface          wti,
           wsh_new_deliveries           wnd
     WHERE wti.interface_action_code       = G_TMS_RELEASE_CODE
       AND wtsi_pu.trip_interface_id       = wti.trip_interface_id
       AND wtsi_pu.stop_interface_id       = wdli.pick_up_stop_interface_id
       AND wtsi_pu.interface_action_code   = G_TMS_RELEASE_CODE
       AND wtsi_do.trip_interface_id       = wti.trip_interface_id
       AND wtsi_do.stop_interface_id       = wdli.drop_off_stop_interface_id
       AND wtsi_do.interface_action_code   = G_TMS_RELEASE_CODE
       -- OTM R12 no need to have outer join
       AND wnd.delivery_id                 = wdli.delivery_id
       AND wndi.delivery_id                = wdli.delivery_id
       AND wdli.interface_action_code      = G_TMS_RELEASE_CODE
     ORDER BY wtsi_pu.trip_interface_id,wdli.sequence_number;

  -- Find Trip Stops
  -- Will pick physical and dummy both, as they would be on
  -- same trip
  -- Further, use this same cursor to populate l_stop_local_tab
  -- and override selected values in l_stop_info_tab
  CURSOR c_get_stops (p_trip_id IN NUMBER) IS
    SELECT stop_id,stop_location_id,stop_sequence_number,
           physical_stop_id,physical_location_id,departure_gross_weight,departure_net_weight,
           departure_volume,weight_uom_code,volume_uom_code,departure_seal_code,
           departure_fill_percent,
           tp_attribute_category,
           tp_attribute1,
           tp_attribute2,
           tp_attribute3,
           tp_attribute4,
           tp_attribute5,
           tp_attribute6,
           tp_attribute7,
           tp_attribute8,
           tp_attribute9,
           tp_attribute10,
           tp_attribute11,
           tp_attribute12,
           tp_attribute13,
           tp_attribute14,
           tp_attribute15,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
      FROM wsh_trip_stops
     WHERE trip_id = p_trip_id;

  -- Find Deliveries associated to a stop
  -- GC3 sends only physical stops back to EBS
  -- 1st select is for deliveries with matching pickup
  -- 2nd select is for deliveries with matching dropoff
  -- 3rd select is for deliveries having dropoff as
  --     dummy stop which is linked to this physical stop
  CURSOR c_get_deliveries(p_stop_id IN NUMBER) IS
    SELECT wdl.delivery_id, wnd.organization_id,wnd.tms_version_number
      FROM wsh_delivery_legs wdl,
           wsh_new_deliveries wnd
     WHERE wdl.pick_up_stop_id = p_stop_id
       AND wnd.delivery_id = wdl.delivery_id
     UNION
    SELECT wdl.delivery_id, wnd.organization_id,wnd.tms_version_number
      FROM wsh_delivery_legs wdl,
           wsh_new_deliveries wnd
     WHERE wdl.drop_off_stop_id = p_stop_id
       AND wnd.delivery_id = wdl.delivery_id
     UNION
    SELECT wdl.delivery_id, wnd.organization_id,wnd.tms_version_number
      FROM wsh_delivery_legs wdl,
           wsh_new_deliveries wnd,
           wsh_trip_stops wts
     WHERE wdl.drop_off_stop_id = wts.stop_id
       AND wnd.delivery_id = wdl.delivery_id
       AND wts.physical_stop_id = p_stop_id;


  -- Find Delivery Legs for the delivery id
  CURSOR c_get_dleg_id (p_delivery_id IN NUMBER) IS
    SELECT delivery_leg_id
      FROM wsh_delivery_legs
     WHERE delivery_id = p_delivery_id;

  -- Freight Cost Interface Data
  CURSOR c_freight_int_cur (p_delivery_id IN NUMBER) IS
    SELECT freight_cost_interface_id,
           freight_cost_id,
           freight_cost_type_id,
           freight_cost_type_code,
           unit_amount,
           uom,
           total_amount,
           currency_code,
           delivery_id
      FROM wsh_freight_costs_interface
     WHERE delivery_id = p_delivery_id
       AND interface_action_code = G_TMS_RELEASE_CODE;

  CURSOR c_get_currency_code(p_trip_interface_id IN NUMBER) IS
    SELECT wc.currency_code, wti.carrier_id
      FROM wsh_trips_interface wti,
           wsh_carriers wc
     WHERE wti.trip_interface_id = p_trip_interface_id
       AND wti.carrier_id = wc.carrier_id;

  -- OTM R12
  CURSOR c_get_frcost_type_id(c_name IN VARCHAR2, c_fc_type_code IN VARCHAR2) IS
    SELECT freight_cost_type_id
      FROM wsh_freight_cost_types
     --WHERE name = 'OTM Freight Cost'
     WHERE name = c_name
     AND freight_cost_type_code = c_fc_type_code;
     --WHERE name = 'ORACLE TRANSPORTATION MANAGEMENT'
       --AND freight_cost_type_code = 'FREIGHT';

  -- Bug#7491598(ER,defer planned shipment iface): Lock each interace record. Becuase
  -- records can be deleted by the receiveshipmentfromOTM BPEL process (via the API WSH_OTM_INBOUND_GRP.initiate_planned_shipment).
  CURSOR c_lock_trip_interface(c_trip_interface_id NUMBER) IS
  SELECT wti.trip_interface_id,
        wndi.delivery_interface_id,
       wdli.delivery_leg_interface_id,
       wtsi.stop_interface_id,
       wfci.freight_cost_interface_id
  from wsh_trips_interface wti ,
  wsh_trip_stops_interface wtsi ,
  wsh_del_legs_interface wdli ,
  wsh_freight_costs_interface wfci,
  wsh_new_del_interface wndi
  where  wti.trip_interface_id   =  c_trip_interface_id --Bug7717569
  and wdli.delivery_interface_id = wndi.delivery_interface_id
  and wndi.delivery_interface_id = wfci.delivery_interface_id (+)
  and wndi.interface_action_code = 'TMS_RELEASE'
  and wdli.pick_up_stop_interface_id = wtsi.stop_interface_id
  and wtsi.trip_interface_id = wti.trip_interface_id
  FOR UPDATE NOWAIT;

  l_lock_rec c_lock_trip_interface%ROWTYPE;

  -- bug 6700792: OTM Dock Door App Sched Proj
  l_dock_appt_tab       WMS_DOCK_APPOINTMENTS_PUB.DOCKAPPTTABTYPE;
  l_dock_appt_index     NUMBER;
  --

  l_trip_info_rec       tms_trip_rec_type;
  l_stop_info_rec       tms_stop_rec_type;
  l_dleg_info_rec       tms_dleg_rec_type;

  --l_del_wti_index       NUMBER;
  l_trip_index          NUMBER := 0;
  l_stop_index          NUMBER := 0;
  l_dleg_index          NUMBER := 0;

  -- Variables to store information about various entities
  l_trip_info_tab        tms_trip_tab_type;
  l_stop_info_tab        tms_stop_tab_type;
  l_dleg_info_tab        tms_dleg_tab_type;
  l_del_wti_tab          WSH_UTIL_CORE.id_tab_type;    --  OTM R12

  l_stop_local_tab       tms_stop_tab_type;
  l_dleg_local_tab       tms_dleg_tab_type;

  -- List of Delivery ids which are unassigned during the flow
  l_unassigned_delivery_id_tab WSH_UTIL_CORE.id_tab_type;
  l_unassigned_dlvy_version_tab WSH_UTIL_CORE.id_tab_type;
  l_delivery_info_tab             WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type;
  l_delivery_info                 WSH_NEW_DELIVERIES_PVT.Delivery_Rec_Type;
  l_new_interface_flag_tab        WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_unassigned_del_index          NUMBER;

  -- Populate Errors
  l_errors_tab           interface_errors_tab_type;

  l_return_status        VARCHAR2(1);
  l_group_error_count    NUMBER := 0;

  -- Variables to store(new) ids after creation
  l_trip_id              NUMBER;
  l_stop_id_tab          WSH_UTIL_CORE.id_tab_type;

  -- successful deliveries, used for freight costs and set in process_delivery section
  l_dlvy_id_tab          WSH_UTIL_CORE.id_tab_type;
  l_dlvy_version_tab     WSH_UTIL_CORE.id_tab_type;

  l_ret_code             BOOLEAN;
  l_temp                 BOOLEAN;
  l_completion_status    VARCHAR2(30);

  l_success_trips        NUMBER;
  l_error_trips          NUMBER;

  -- OTM R12 populate record structure to call update_tms_interface_flag
  l_upd_dlvy_id_tab      WSH_UTIL_CORE.id_tab_type;
  l_upd_dlvy_tms_tab     WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  -- OTM R12
  -- Bug#7491598(ER,defer planned shipment iface)
  l_del_pickup_date_low DATE;
  l_del_pickup_date_high DATE;
  -- Bug#7491598(ER,defer planned shipment iface)

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'RELEASE_PLANNED_SHIPMENT';
  --
  l_debug_on BOOLEAN;
  --
BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name, 'p_group_id', p_group_id);
    WSH_DEBUG_SV.log(l_module_name, 'p_latest_version', p_latest_version);
    WSH_DEBUG_SV.log(l_module_name, 'p_tp_plan_low', p_tp_plan_low);
    WSH_DEBUG_SV.log(l_module_name, 'p_tp_plan_high', p_tp_plan_high);
    WSH_DEBUG_SV.log(l_module_name, 'p_dummy', p_dummy);
    WSH_DEBUG_SV.log(l_module_name, 'p_client_id', p_client_id); -- Modified R12.1.1 LSP PROJECT
    WSH_DEBUG_SV.log(l_module_name, 'p_organization_id', p_organization_id);
    WSH_DEBUG_SV.log(l_module_name, 'p_del_name_low', p_del_name_low);
    WSH_DEBUG_SV.log(l_module_name, 'p_del_name_high', p_del_name_high);
    WSH_DEBUG_SV.log(l_module_name, 'p_del_pickup_date_low', p_del_pickup_date_low);
    WSH_DEBUG_SV.log(l_module_name, 'p_del_pickup_date_high', p_del_pickup_date_high);
    WSH_DEBUG_SV.logmsg(l_module_name, 'START PROCESSING...');
  END IF;
  --Bug#7491598(ER,defer planned shipment iface)
  IF p_group_id IS NULL THEN
  --{
      -- pick up dates
      IF (p_del_pickup_date_low IS NOT NULL) THEN
      --{
          SELECT fnd_date.chardt_to_date(p_del_pickup_date_low)
          INTO l_del_pickup_date_low
          FROM dual;
      --}
      END IF;
      IF (p_del_pickup_date_high IS NOT NULL) THEN
      --{
          SELECT fnd_date.chardt_to_date(p_del_pickup_date_high)
          INTO l_del_pickup_date_high
          FROM dual;
      --}
      END IF;
  --} group id is null
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'l_del_pickup_date_low', l_del_pickup_date_low);
    WSH_DEBUG_SV.log(l_module_name, 'l_del_pickup_date_high', l_del_pickup_date_high);
  END IF;


  -- --Bug#7491598(ER,defer planned shipment iface): Group Id check needs to be removed.
  -- Check for p_group_id
  /*
  IF p_group_id IS NULL THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_GROUP_ID_IS_REQUIRED');
    WSH_UTIL_CORE.PrintMsg(fnd_message.get);
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
    errbuf := 'Exception occurred in Release_Planned_Shipment';
    retcode := '2';
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, 'Group Id cannot be Null');
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    RETURN;
  END IF;
*/
  l_success_trips     := 0;
  l_error_trips       := 0;
  l_completion_status := 'NORMAL';

  -- Process for input group_id
  -- Initialize List of unassigned delivery ids, this list is used for a group id
  l_unassigned_delivery_id_tab.DELETE;
  l_unassigned_dlvy_version_tab.DELETE;

  -- Initialize the tables for trips, stops and delivery legs
  -- index all the tables by trip_interface_id
  l_trip_info_tab.DELETE;
  l_stop_info_tab.DELETE;
  l_dleg_info_tab.DELETE;
  -- bug 6700792: OTM Dock Door App Sched Proj
  l_dock_appt_tab.DELETE;
  l_dock_appt_index := 0;

  --SAVEPOINT process_group;
  --

  --=======================================================================
  -- 1. Get All Trips Information
  -- Loop to find trips for the group_id
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    WSH_DEBUG_SV.logmsg(l_module_name,'1. Gather Trips Interface data');
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
  END IF;
  -- Bug#7491598(ER,defer planned shipment iface)
  IF (P_GROUP_ID is not null) THEN
     OPEN c_tms_interface_trips;
  ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
     OPEN c_tms_interface_trips_plan(p_tp_plan_low,p_tp_plan_high);
  ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
     OPEN c_tms_interface_trips_del(p_del_name_low,p_del_name_high,p_organization_id,l_del_pickup_date_low,l_del_pickup_date_high, p_client_id); -- Modified R12.1.1 LSP PROJECT
  ELSE
     OPEN c_tms_interface_trips_all;
  END IF;

  LOOP --{
      IF (P_GROUP_ID is not null) THEN
          FETCH c_tms_interface_trips INTO l_trip_info_rec;
          EXIT WHEN c_tms_interface_trips%NOTFOUND;
      ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
          FETCH c_tms_interface_trips_plan INTO l_trip_info_rec;
          EXIT WHEN c_tms_interface_trips_plan%NOTFOUND;
      ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
          FETCH c_tms_interface_trips_del INTO l_trip_info_rec;
          EXIT WHEN c_tms_interface_trips_del%NOTFOUND;
      ELSE
          FETCH c_tms_interface_trips_all INTO l_trip_info_rec;
          EXIT WHEN c_tms_interface_trips_all%NOTFOUND;
      END IF;
    /*
    FETCH c_tms_interface_trips
     INTO l_trip_info_rec;
    EXIT WHEN c_tms_interface_trips%NOTFOUND; */

    --l_trip_index := l_trip_info_rec.trip_interface_id;
    --l_trip_index := l_trip_index + 1;
    l_trip_index := l_trip_info_tab.count + 1;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Trip Interface id', l_trip_info_rec.trip_interface_id);
    END IF;
    --l_trip_info_tab(l_trip_info_tab.count + 1) := l_trip_info_rec;
    l_trip_info_tab(l_trip_index) := l_trip_info_rec;

    -- OTM R12
    l_del_wti_tab(l_trip_index) := l_trip_info_rec.trip_interface_id;


  END LOOP;--}
  IF (P_GROUP_ID is not null) THEN
     CLOSE c_tms_interface_trips;
  ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
     CLOSE c_tms_interface_trips_plan;
  ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN  -- Modified R12.1.1 LSP PROJECT
     CLOSE c_tms_interface_trips_del;
  ELSE
     CLOSE c_tms_interface_trips_all;
  END IF;
 -- Bug#7491598(ER,defer planned shipment iface): end
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Count Trip Info Tab:', l_trip_info_tab.count);
  END IF;

  --=======================================================================
  -- 2. Get All Trip Stops Information(order by trip ids)
  -- Loop to find trip stops for the group_id
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    WSH_DEBUG_SV.logmsg(l_module_name,'2. Gather Trip Stops Interface data');
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
  END IF;
  -- --Bug#7491598(ER,defer planned shipment iface): Begin
  IF (P_GROUP_ID is not null) THEN
     OPEN c_tms_interface_stops;
  ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
     OPEN c_tms_interface_stops_plan(p_tp_plan_low,p_tp_plan_high);
  ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
     OPEN c_tms_interface_stops_del(p_del_name_low,p_del_name_high,p_organization_id,l_del_pickup_date_low,l_del_pickup_date_high , p_client_id);-- Modified R12.1.1 LSP PROJECT
  ELSE
     OPEN c_tms_interface_stops_all;
  END IF;

  LOOP --{
      IF (P_GROUP_ID is not null) THEN
          FETCH c_tms_interface_stops INTO l_stop_info_rec;
          EXIT WHEN c_tms_interface_stops%NOTFOUND;
      ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
          FETCH c_tms_interface_stops_plan INTO l_stop_info_rec;
          EXIT WHEN c_tms_interface_stops_plan%NOTFOUND;
      ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN-- Modified R12.1.1 LSP PROJECT
          FETCH c_tms_interface_stops_del INTO l_stop_info_rec;
          EXIT WHEN c_tms_interface_stops_del%NOTFOUND;
      ELSE
          FETCH c_tms_interface_stops_all INTO l_stop_info_rec;
          EXIT WHEN c_tms_interface_stops_all%NOTFOUND;
      END IF;
    /* FETCH c_tms_interface_stops
     INTO l_stop_info_rec;
    EXIT WHEN c_tms_interface_stops%NOTFOUND; */
    --l_stop_index := l_stop_index + 1;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Trip Interface id', l_stop_info_rec.trip_interface_id);
      WSH_DEBUG_SV.log(l_module_name,'Stop Interface id', l_stop_info_rec.stop_interface_id);
      WSH_DEBUG_SV.log(l_module_name,'Stop Location id',  l_stop_info_rec.stop_location_id);
      WSH_DEBUG_SV.log(l_module_name,'Stop Sequence No.', l_stop_info_rec.stop_sequence_number);
      WSH_DEBUG_SV.log(l_module_name,'Timezone Code', l_stop_info_rec.timezone_code);
    END IF;
    l_stop_info_tab(l_stop_info_tab.count + 1) := l_stop_info_rec;

  END LOOP;--}
  IF (P_GROUP_ID is not null) THEN
     CLOSE c_tms_interface_stops;
  ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
     CLOSE c_tms_interface_stops_plan;
  ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
     CLOSE c_tms_interface_stops_del;
  ELSE
     CLOSE c_tms_interface_stops_all;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Count Trip Stop Info Tab:', l_stop_info_tab.count);
  END IF;

  --=======================================================================
  -- 3. For each trip stop, get Delivery Leg information(order by trip ids)
  -- Loop to find delivery legs for the group_id
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    WSH_DEBUG_SV.logmsg(l_module_name,'3. Gather Delivery Legs Interface data');
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
  END IF;
  --Bug#7491598(ER,defer planned shipment iface): Begin
  IF (P_GROUP_ID is not null) THEN
     OPEN c_tms_interface_dlegs;
  ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
     OPEN c_tms_interface_dlegs_plan(p_tp_plan_low,p_tp_plan_high);
  ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
     OPEN c_tms_interface_dlegs_del(p_del_name_low,p_del_name_high,p_organization_id,l_del_pickup_date_low,l_del_pickup_date_high , p_client_id); -- Modified R12.1.1 LSP PROJECT
  ELSE
     OPEN c_tms_interface_dlegs_all;
  END IF;

  LOOP --{
      IF (P_GROUP_ID is not null) THEN
          FETCH c_tms_interface_dlegs INTO l_dleg_info_rec;
          EXIT WHEN c_tms_interface_dlegs%NOTFOUND;
      ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
          FETCH c_tms_interface_dlegs_plan INTO l_dleg_info_rec;
          EXIT WHEN c_tms_interface_dlegs_plan%NOTFOUND;
      ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
          FETCH c_tms_interface_dlegs_del INTO l_dleg_info_rec;
          EXIT WHEN c_tms_interface_dlegs_del%NOTFOUND;
      ELSE
          FETCH c_tms_interface_dlegs_all INTO l_dleg_info_rec;
          EXIT WHEN c_tms_interface_dlegs_all%NOTFOUND;
      END IF;
  /*LOOP --{
    FETCH c_tms_interface_dlegs
     INTO l_dleg_info_rec;
    EXIT WHEN c_tms_interface_dlegs%NOTFOUND; */
    l_dleg_index := l_dleg_info_rec.trip_interface_id;
    --l_dleg_index := l_dleg_index + 1;
    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Trip Interface id', l_dleg_info_rec.trip_interface_id);
      WSH_DEBUG_SV.log(l_module_name,'Pickup Stop Interface id', l_dleg_info_rec.pick_up_stop_interface_id);
      WSH_DEBUG_SV.log(l_module_name,'Pickup Stop Location id', l_dleg_info_rec.pickup_stop_location_id);
      WSH_DEBUG_SV.log(l_module_name,'Dropoff Stop Interface id', l_dleg_info_rec.drop_off_stop_interface_id);
      WSH_DEBUG_SV.log(l_module_name,'Dropoff Stop Location id', l_dleg_info_rec.dropoff_stop_location_id);
      WSH_DEBUG_SV.log(l_module_name,'Delivery id', l_dleg_info_rec.delivery_id);
      WSH_DEBUG_SV.log(l_module_name,'EBS Version Number', l_dleg_info_rec.tms_version_number);
      WSH_DEBUG_SV.log(l_module_name,'OTM Version Number', l_dleg_info_rec.otm_tms_version_number);
    END IF;

    l_dleg_info_tab(l_dleg_info_tab.count + 1) := l_dleg_info_rec;
  END LOOP;--}

  IF (P_GROUP_ID is not null) THEN
     CLOSE c_tms_interface_dlegs;
  ELSIF ( p_tp_plan_low is not NULL OR p_tp_plan_high is not NULL) THEN
     CLOSE c_tms_interface_dlegs_plan;
  ELSIF ( p_del_name_low is not NULL OR p_del_name_high is not NULL OR p_organization_id IS NOT NULL OR l_del_pickup_date_low IS NOT NULL OR l_del_pickup_date_high IS NOT NULL OR p_client_id IS NOT NULL) THEN -- Modified R12.1.1 LSP PROJECT
     CLOSE c_tms_interface_dlegs_del;
  ELSE
     CLOSE c_tms_interface_dlegs_all;
  END IF;
  --Bug#7491598(ER,defer planned shipment iface): end
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Count Delivery Leg Info Tab:', l_dleg_info_tab.count);
  END IF;

  -- OTM R12 Clean up for all trips in a bulk delete outside the loop

  IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'CLEAN UP EXISTING DATA FOR ALL TRIPS');
  END IF;

    -- Delete Records in Interface errors table and exceptions table
    -- for the associated entities. This will ensure there are no duplicate
    -- or multiple errors and exceptions logged.
    -- Perform this for each trip_interface_id

    -- OTM R12
    IF l_del_wti_tab.COUNT > 0 THEN

    -- Errors are logged always for the deliveries
    --FORALL l_del_wti_index in INDICES OF l_del_wti_tab
    FORALL i in l_del_wti_tab.FIRST..l_del_wti_tab.LAST
    DELETE from wsh_interface_errors wie
     WHERE wie.interface_table_name = 'WSH_NEW_DEL_INTERFACE'
       AND wie.interface_id in (
           select wdli.delivery_interface_id
             from wsh_trip_stops_interface wtsi,
                  wsh_del_legs_interface wdli
            where wtsi.trip_interface_id = l_del_wti_tab(i)
              and wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
              and wtsi.interface_action_code = G_TMS_RELEASE_CODE
              and wdli.interface_action_code = G_TMS_RELEASE_CODE)
       AND wie.interface_action_code = G_TMS_RELEASE_CODE;

    -- Exceptions are logged always for the deliveries
    FORALL i in l_del_wti_tab.FIRST..l_del_wti_tab.LAST
    DELETE from WSH_EXCEPTIONS we
     WHERE we.delivery_id in (
             select wdli.delivery_id
              from  wsh_trip_stops_interface wtsi,
                        wsh_del_legs_interface wdli
             where  wtsi.trip_interface_id = l_del_wti_tab(i)
               and  wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
               and  wtsi.interface_action_code = G_TMS_RELEASE_CODE
               and  wdli.interface_action_code = G_TMS_RELEASE_CODE)
         and we.status = 'OPEN'
         and we.exception_name IN ('WSH_OTM_SHIPMENT_ERROR','WSH_OTM_INVALID_LOC');

    END IF;
    -- OTM R12

    --
    -- Specially committing the delete transactions above to avoid multiple errors
    -- and exceptions.
    -- This is for each trip, In case of multiple trips, the record would have been
    -- committed or rolledback at end of each transaction, so it will not overlap
    --
    COMMIT;
    --
    -- NO CREATE/UPDATE/DELETE transactions should be added before the above delete transaction
    --
  -- OTM R12

  SAVEPOINT process_group;
  --=======================================================================
  -- 4. Loop thru all trips in l_trip_info_tab
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    WSH_DEBUG_SV.logmsg(l_module_name,'4. START LOOPING THROUGH EACH TRIP');
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
  END IF;

  -- Trip count should be > 0
  IF l_trip_info_tab.count > 0 THEN--{
  FOR i in l_trip_info_tab.FIRST..l_trip_info_tab.LAST
  LOOP--{

    l_dleg_local_tab.DELETE;
    l_stop_local_tab.DELETE;
    l_dlvy_id_tab.DELETE;
    -- OTM R12 Cleaning up will be done for all trips in a bulk delete outside the loop

    SAVEPOINT process_single_trip;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Populate Delivery Legs Info in Local Table');
    END IF;

    -- Loop through l_dleg_info_tab to find the deliveries for current trip
    IF l_dleg_info_tab.COUNT > 0 THEN
      FOR del_check in l_dleg_info_tab.FIRST..l_dleg_info_tab.LAST
      LOOP
        IF l_dleg_info_tab(del_check).trip_interface_id = l_trip_info_tab(i).trip_interface_id THEN
          -- Copy the relevant records in identical record structure
          l_dleg_local_tab(l_dleg_local_tab.count+1) := l_dleg_info_tab(del_check);
        END IF;
      END LOOP;
    END IF;

    -- Locking Bug 5135606 for Trip, Stop,Dleg and Delivery
    -- Need to raise appropriate messages as they are not raised from the
    -- core APIs
    IF l_trip_info_tab(i).trip_id IS NOT NULL THEN--{

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
        WSH_DEBUG_SV.logmsg(l_module_name,'4ai. LOCK TRIP:-'||l_trip_info_tab(i).trip_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      END IF;

      BEGIN
        -- Lock Trip
        WSH_TRIPS_PVT.lock_trip_no_compare
          (p_trip_id => l_trip_info_tab(i).trip_id);
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_OTM_IB_LOCK_TRIP');
          FND_MESSAGE.SET_TOKEN('TRIP_NAME',WSH_TRIPS_PVT.get_name(l_trip_info_tab(i).trip_id));
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'trip not locked: l_return_status', l_return_status);
          END IF;
          GOTO trip_error;
      END;

      -- 4a. Lock corresponding trip stops in EBS(for trip_id)
      -- Trip has to exist in EBS for locking this stops
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
        WSH_DEBUG_SV.logmsg(l_module_name,'4aii. LOCK TRIP STOP');
        WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      END IF;
      DECLARE
        l_stop_id NUMBER;
      BEGIN--{
        FOR rec in c_get_stops(l_trip_info_tab(i).trip_id)
        LOOP
          l_stop_id := rec.stop_id;
          wsh_trip_stops_pvt.lock_trip_stop_no_compare(
            p_stop_id => rec.stop_id);
        END LOOP;

      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('WSH','WSH_OTM_IB_LOCK_STOP');
          FND_MESSAGE.SET_TOKEN('STOP_NAME',WSH_TRIP_STOPS_PVT.get_name(l_stop_id,'FTE_TMS_INTEGRATION'));
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'trip stop not locked: l_return_status', l_return_status);
          END IF;
          GOTO trip_error;
      END;--}

    END IF;--}

    -- 4b. Locking of Delivery and Delivery legs is required even when there is no trip in EBS

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      WSH_DEBUG_SV.logmsg(l_module_name,'4b. LOCK DELIVERY AND DELIVERY LEG');
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    END IF;
    IF l_dleg_local_tab.count > 0 THEN
      FOR m in l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
      -- Lock corresponding delivery legs in EBS
      LOOP--{
        -- Need to lock delivery legs even if the delivery was assigned to a different trip
        IF l_dleg_local_tab(m).trip_interface_id = l_trip_info_tab(i).trip_interface_id THEN--{
          BEGIN
            -- lock legs in this delivery
            wsh_delivery_legs_pvt.lock_dlvy_leg_no_compare(
              p_delivery_id => l_dleg_local_tab(m).delivery_id);

          EXCEPTION
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_OTM_IB_LOCK_DLEG');
              FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',wsh_new_deliveries_pvt.get_name(l_dleg_local_tab(m).delivery_id));
              WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Delivery Leg not locked: l_return_status', l_return_status);
              END IF;
              GOTO trip_error;
          END;

          -- Lock corresponding deliveries in EBS
          -- Compare the version number in the where clause of the cursor c_tms_interface_legs
          BEGIN
            wsh_new_deliveries_pvt.lock_dlvy_no_compare(
              p_delivery_id => l_dleg_local_tab(m).delivery_id);
          EXCEPTION
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('WSH','WSH_OTM_IB_LOCK_DLVY');
              FND_MESSAGE.SET_TOKEN('DELIVERY_NAME',wsh_new_deliveries_pvt.get_name(l_dleg_local_tab(m).delivery_id));
              WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Delivery not locked: l_return_status', l_return_status);
              END IF;
              GOTO trip_error;
          END;
        END IF;--}
      END LOOP; --} -- across l_dleg_local_tab
    END IF;
    -- 4c. Process Trip
    -- Vehicle Derivation
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      WSH_DEBUG_SV.logmsg(l_module_name,'4c. PROCESS TRIP');
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    END IF;
    DECLARE

      l_rs                   VARCHAR2(1);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(32767);

      l_trip_input_tab       WSH_TRIPS_PVT.Trip_Attr_Tbl_Type;
      l_in_rec               WSH_TRIPS_GRP.tripInRecType;
      l_trip_output_tab      WSH_TRIPS_GRP.trip_Out_Tab_Type;

      l_stop_location_id     NUMBER;
      l_organization_tab     WSH_UTIL_CORE.id_tab_type;

    BEGIN--{

      -- try to lock the trip interface records
      IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Locking the trip interface record:'||l_trip_info_tab(i).trip_interface_id);
      END IF;
      OPEN c_lock_trip_interface(l_trip_info_tab(i).trip_interface_id) ;
      FETCH  c_lock_trip_interface INTO l_lock_rec;
      CLOSE c_lock_trip_interface;
      -- For each trip, Copy Values from l_trip_info_tab to l_trip_input_tab

      -- Derive the Vehicle Item Id based on the name
      IF l_trip_info_tab(i).vehicle_item_name IS NOT NULL
         AND l_trip_info_tab(i).interface_action_code = G_TMS_RELEASE_CODE THEN--{
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Vehicle Item Name:'||l_trip_info_tab(i).vehicle_item_name);
        END IF;
        -- Get the first stop location from l_stop_info_tab
        -- l_stop_info would be populated
        FOR i_vehicle in l_stop_info_tab.FIRST..l_stop_info_tab.LAST
        LOOP--{
          IF l_stop_info_tab(i_vehicle).trip_interface_id = l_trip_info_tab(i).trip_interface_id
          THEN
            -- stop location id would be not null
            -- ECO 5008405, check here
            -- Stop Location id in Interface table is Varchar2
            -- need to convert it to number
            BEGIN --(
              l_stop_location_id :=
                to_number(l_stop_info_tab(i_vehicle).stop_location_id);
            EXCEPTION
              WHEN OTHERS THEN
              -- capture cases where stop_location_id is not a number
              -- special case, need to handle error a bit differently
              l_return_status := 'T';
              FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
              WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Invalid Stop Location, l_return_status:', l_return_status);
              END IF;
              GOTO trip_error;
            END;--}

            EXIT; -- exit the loop after 1st match
          END IF;
        END LOOP;--}

        IF l_stop_location_id IS NULL THEN
          --l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          l_return_status := 'T';
          FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Unable to Derive Stop Location', l_return_status);
          END IF;
          GOTO trip_error;
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling wsh_util_core.get_org_from_location:'||l_stop_location_id);
        END IF;
        --get_org_from_location
        WSH_UTIL_CORE.get_org_from_location(
              p_location_id       => l_stop_location_id,
              x_organization_tab  => l_organization_tab,
              x_return_status     => l_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'return status:'||l_rs);
          WSH_DEBUG_SV.logmsg(l_module_name,'Organizations Count:'||l_organization_tab.Count);
        END IF;

        --Bug 5931958. Added the OR condition l_organization_tab.COUNT = 0
        IF (l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) OR
            (l_organization_tab.COUNT = 0 ))THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('WSH','WSH_LOC_ORG_UNDEFINED');
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Error: Failed to get Organization from stop location id ',
                                             l_stop_location_id );
          END IF;
          GOTO trip_error;
        END IF;

        -- Assign first record in organization table
        l_trip_info_tab(i).vehicle_organization_id := l_organization_tab(l_organization_tab.FIRST);
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_EXTERNAL_INTERFACE_SV.Validate_Item');
        END IF;

        WSH_EXTERNAL_INTERFACE_SV.Validate_Item
          (p_concatenated_segments => l_trip_info_tab(i).vehicle_item_name,
           p_organization_id       => l_organization_tab(l_organization_tab.FIRST),
           x_inventory_item_id     => l_trip_info_tab(i).vehicle_item_id,
           x_return_status         => l_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'return status:'||l_rs);
          WSH_DEBUG_SV.logmsg(l_module_name,'Vehicle Item id:'||l_trip_info_tab(i).vehicle_item_id);
        END IF;

        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('WSH','WSH_VEHICLE_TYPE_UNDEFINED');
          FND_MESSAGE.SET_TOKEN('ITEM',l_trip_info_tab(i).vehicle_item_name);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION',
                                 WSH_UTIL_CORE.get_org_name (p_organization_id =>l_organization_tab(l_organization_tab.FIRST)));
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Validate Item Failed: l_return_status', l_return_status);
          END IF;
          GOTO trip_error;
        END IF;

      END IF;--}

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Vehicle Item id:'||l_trip_info_tab(i).vehicle_item_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Vehicle Org:'||l_trip_info_tab(i).vehicle_organization_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Vehicle Num Prefix:'||l_trip_info_tab(i).vehicle_num_prefix);
        WSH_DEBUG_SV.logmsg(l_module_name,'Vehicle Number:'||l_trip_info_tab(i).vehicle_number);
        WSH_DEBUG_SV.logmsg(l_module_name,'Carrier id:'||l_trip_info_tab(i).carrier_id);
        WSH_DEBUG_SV.logmsg(l_module_name,'Mode of Transport:'||l_trip_info_tab(i).mode_of_transport);
        WSH_DEBUG_SV.logmsg(l_module_name,'Service Level:'||l_trip_info_tab(i).service_level);
        WSH_DEBUG_SV.logmsg(l_module_name,'Tp Plan Name:'||l_trip_info_tab(i).tp_plan_name);
        WSH_DEBUG_SV.logmsg(l_module_name,'Interface Action Code:'||l_trip_info_tab(i).interface_action_code);
      END IF;

      --
      -- This logic would be only for G_TMS_DELETE_CODE
      --
      -- HANDLE INTERFACE_ACTION_CODE of DELETE HERE...and UNASSIGN THE DELIVERIES in EBS
      IF l_trip_info_tab(i).interface_action_code = G_TMS_DELETE_CODE THEN--{

        DECLARE
          l_delivery_tab         WSH_TMS_RELEASE.delivery_tab;
          l_delivery_id_tab      WSH_UTIL_CORE.id_tab_type;

          l_del_attrs            WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
          l_del_action_prms      WSH_DELIVERIES_GRP.action_parameters_rectype;
          l_del_action_rec       WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
          l_del_defaults         WSH_DELIVERIES_GRP.default_parameters_rectype;

          l_rs                   VARCHAR2(1);
          l_msg_count            NUMBER;
          l_msg_data             VARCHAR2(32767);

        BEGIN
          -- Find EBS deliveries which are currently assigned to this GC3 trip
          -- Delete Shipment would be sent only for existing trips!
          find_deliveries_for_trip(
            p_trip_id         => l_trip_info_tab(i).trip_id,
            p_tp_plan_name    => NULL,
            x_delivery_tab    => l_delivery_tab, -- dlvy_interface_id + tms_version_number
            x_delivery_id_tab => l_delivery_id_tab, -- dlvy ids
            x_return_status   => l_rs);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after find_deliveries_for_trip'||l_rs);
          END IF;

          -- Handle return status here !!!
          IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Find Deliveries for Trip Failed,l_return_status:', l_return_status);
            END IF;
            GOTO trip_error;
          END IF;

          -- All the deliveries are assigned to sametrip, so combine them for single call
          IF l_delivery_id_tab.count > 0 THEN--{
            FOR del_rec IN l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
            LOOP--{
              -- For each delivery, derive the organization id
              -- No information is passed from GC3, count of l_delivery_tab and l_delivery_id_tab
              -- is identical
              l_del_attrs(l_del_attrs.count + 1).delivery_id := l_delivery_id_tab(del_rec);
              l_del_attrs(l_del_attrs.count).organization_id :=
                l_delivery_tab(l_delivery_id_tab(del_rec)).organization_id;

              IF l_delivery_tab(l_delivery_id_tab(del_rec)).status_code = 'OP' THEN
                l_unassigned_delivery_id_tab(l_unassigned_delivery_id_tab.count + 1) :=
                   l_delivery_id_tab(del_rec);
                l_unassigned_dlvy_version_tab(l_unassigned_delivery_id_tab.count) :=
                   l_delivery_tab(l_delivery_id_tab(del_rec)).tms_version_number;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Status of Delivery '||
                   l_delivery_id_tab(del_rec)||'-->'||l_delivery_tab(l_delivery_id_tab(del_rec)).status_code);
                END IF;
              END IF;
            END LOOP; --}
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Deliveries to be unassigned:'||l_del_attrs.count);
              WSH_DEBUG_SV.logmsg(l_module_name,'Overall Unassign Count:'||l_unassigned_delivery_id_tab.count);
              WSH_DEBUG_SV.logmsg(l_module_name,'Unassign Version Count:'||l_unassigned_dlvy_version_tab.count);
            END IF;

            l_del_action_prms.caller      := 'FTE_TMS_INTEGRATION'; --'FTE_TMS_RELEASE';
            l_del_action_prms.action_code := 'UNASSIGN-TRIP';
            l_del_action_prms.trip_id     := l_trip_info_tab(i).trip_id;

            WSH_DELIVERIES_GRP.delivery_action(
              p_api_version_number => 1.0,
              p_init_msg_list      => FND_API.G_TRUE,
              p_commit             => FND_API.G_FALSE,
              p_action_prms        => l_del_action_prms,
              p_rec_attr_tab       => l_del_attrs,
              x_delivery_out_rec   => l_del_action_rec,
              x_defaults_rec       => l_del_defaults,
              x_return_status      => l_rs,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Unassign Delivery'||l_rs);
            END IF;
            IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Unassign Delivery from Trip Failed: l_return_status', l_return_status);
              END IF;
              GOTO trip_error;
            END IF;
          END IF;--} -- delivery_id_tab.count
        END;
        -- if above unassignment was success, proceed to next trip
        l_success_trips := l_success_trips + 1;
        EXIT;--skip to next trip
      END IF;--} -- interface_action_code is DELETE

      --
      -- This logic would be only for G_TMS_RELEASE_CODE
      --

      l_trip_input_tab(1).VEHICLE_NUM_PREFIX           := l_trip_info_tab(i).vehicle_num_prefix;
      l_trip_input_tab(1).VEHICLE_NUMBER               := l_trip_info_tab(i).vehicle_number;
      l_trip_input_tab(1).VEHICLE_ITEM_ID              := l_trip_info_tab(i).vehicle_item_id;
      l_trip_input_tab(1).VEHICLE_ORGANIZATION_ID      := l_trip_info_tab(i).vehicle_organization_id;

      l_trip_input_tab(1).trip_id                      := l_trip_info_tab(i).trip_id;
      l_trip_input_tab(1).CARRIER_ID                   := l_trip_info_tab(i).carrier_id;
      l_trip_input_tab(1).SHIP_METHOD_CODE             := l_trip_info_tab(i).ship_method_code;
      l_trip_input_tab(1).ROUTE_ID                     := l_trip_info_tab(i).route_id;
      l_trip_input_tab(1).ROUTING_INSTRUCTIONS         := l_trip_info_tab(i).routing_instructions;
      l_trip_input_tab(1).SERVICE_LEVEL                := l_trip_info_tab(i).service_level;
      l_trip_input_tab(1).MODE_OF_TRANSPORT            := l_trip_info_tab(i).mode_of_transport;
      l_trip_input_tab(1).FREIGHT_TERMS_CODE           := l_trip_info_tab(i).freight_terms_code;
      l_trip_input_tab(1).SEAL_CODE                    := l_trip_info_tab(i).seal_code;
      l_trip_input_tab(1).TP_PLAN_NAME                 := l_trip_info_tab(i).tp_plan_name;
      l_trip_input_tab(1).TP_TRIP_NUMBER               := l_trip_info_tab(i).tp_trip_number;
      l_trip_input_tab(1).SHIPMENTS_TYPE_FLAG          := l_trip_info_tab(i).shipments_type_flag;
      l_trip_input_tab(1).BOOKING_NUMBER               := l_trip_info_tab(i).booking_number;
      l_trip_input_tab(1).VESSEL                       := l_trip_info_tab(i).vessel;
      l_trip_input_tab(1).VOYAGE_NUMBER                := l_trip_info_tab(i).voyage_number;
      l_trip_input_tab(1).PORT_OF_LOADING              := l_trip_info_tab(i).port_of_loading;
      l_trip_input_tab(1).PORT_OF_DISCHARGE            := l_trip_info_tab(i).port_of_discharge;
      l_trip_input_tab(1).CARRIER_CONTACT_ID           := l_trip_info_tab(i).carrier_contact_id;
      l_trip_input_tab(1).SHIPPER_WAIT_TIME            := l_trip_info_tab(i).shipper_wait_time;
      l_trip_input_tab(1).WAIT_TIME_UOM                := l_trip_info_tab(i).wait_time_uom;
      l_trip_input_tab(1).CARRIER_RESPONSE             := l_trip_info_tab(i).carrier_response;
      l_trip_input_tab(1).OPERATOR                     := l_trip_info_tab(i).operator;
      l_trip_input_tab(1).IGNORE_FOR_PLANNING          := 'N';
      l_trip_input_tab(1).attribute_category           := l_trip_info_tab(i).attribute_category;
      l_trip_input_tab(1).attribute1                   := l_trip_info_tab(i).attribute1;
      l_trip_input_tab(1).attribute2                   := l_trip_info_tab(i).attribute2;
      l_trip_input_tab(1).attribute3                   := l_trip_info_tab(i).attribute3;
      l_trip_input_tab(1).attribute4                   := l_trip_info_tab(i).attribute4;
      l_trip_input_tab(1).attribute5                   := l_trip_info_tab(i).attribute5;
      l_trip_input_tab(1).attribute6                   := l_trip_info_tab(i).attribute6;
      l_trip_input_tab(1).attribute7                   := l_trip_info_tab(i).attribute7;
      l_trip_input_tab(1).attribute8                   := l_trip_info_tab(i).attribute8;
      l_trip_input_tab(1).attribute9                   := l_trip_info_tab(i).attribute9;
      l_trip_input_tab(1).attribute10                  := l_trip_info_tab(i).attribute10;
      l_trip_input_tab(1).attribute11                  := l_trip_info_tab(i).attribute11;
      l_trip_input_tab(1).attribute12                  := l_trip_info_tab(i).attribute12;
      l_trip_input_tab(1).attribute13                  := l_trip_info_tab(i).attribute13;
      l_trip_input_tab(1).attribute14                  := l_trip_info_tab(i).attribute14;
      l_trip_input_tab(1).attribute15                  := l_trip_info_tab(i).attribute15;

      IF l_trip_info_tab(i).trip_id IS NOT NULL THEN--{
        --trip already exists in EBS
        l_in_rec.action_code := 'UPDATE';
        l_trip_input_tab(1).NAME          := WSH_TRIPS_PVT.get_name(l_trip_info_tab(i).trip_id);
      ELSE -- trip doesnot exist in EBS
        l_in_rec.action_code := 'CREATE';
        l_trip_input_tab(1).NAME          := l_trip_info_tab(i).name;
      END IF; --}

      l_in_rec.caller := 'FTE_TMS_INTEGRATION';

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_TRIPS_GRP.Create_Update_Trip:'||l_in_rec.action_code);
      END IF;

      WSH_TRIPS_GRP.Create_Update_Trip(
        p_api_version_number =>  1.0,
        p_init_msg_list      =>  FND_API.G_TRUE,
        p_commit             =>  FND_API.G_FALSE,
        x_return_status      =>  l_rs,
        x_msg_count          =>  l_msg_count,
        x_msg_data           =>  l_msg_data,
        p_trip_info_tab      =>  l_trip_input_tab,
        p_In_rec             =>  l_in_rec,
        x_Out_tab            =>  l_trip_output_tab);


      IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Create Update Trip Failed: l_return_status', l_return_status);
        END IF;
        GOTO trip_error;
      END IF;

      -- Trip id after create or update
      IF l_trip_output_tab.count > 0 AND l_in_rec.action_code = 'CREATE' THEN
        l_trip_id := l_trip_output_tab(l_trip_output_tab.FIRST).trip_id;

      ELSIF l_in_rec.action_code = 'UPDATE' THEN -- trip_id is already known
        l_trip_id := l_trip_info_tab(i).trip_id;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Create_Update_Trip,return status:'||l_rs);
        WSH_DEBUG_SV.logmsg(l_module_name,'Trip id:'||l_trip_id);
      END IF;

    END;--} process trip


    -- 4d. Process Trip Stops
    -- populate stop UOM in case of creation
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      WSH_DEBUG_SV.logmsg(l_module_name,'4d. PROCESS TRIP STOPS');
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    END IF;

    DECLARE
      -- Find Deliveries associated to a stop
      l_stop_matches         VARCHAR2(1); -- stop sent by GC3 matches stop in EBS
      l_stop_delete_tab      WSH_UTIL_CORE.id_tab_type; -- stops to be deleted
      --l_dlvy_unassign_tab    WSH_UTIL_CORE.id_tab_type; -- deliveries to be unassigned

      l_del_attrs            WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
      l_del_action_prms      WSH_DELIVERIES_GRP.action_parameters_rectype;
      l_del_action_rec       WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
      l_del_defaults         WSH_DELIVERIES_GRP.default_parameters_rectype;

      l_stop_attrs           WSH_TRIP_STOPS_PVT.stop_attr_tbl_type;
      l_stop_action_prms     WSH_TRIP_STOPS_GRP.action_parameters_rectype;
      l_stop_action_rec      WSH_TRIP_STOPS_GRP.StopActionOutRecType;
      l_stop_defaults        WSH_TRIP_STOPS_GRP.default_parameters_rectype;
      l_stop_in_rec          WSH_TRIP_STOPS_GRP.stopInRecType;
      l_stop_out_tab         WSH_TRIP_STOPS_GRP.stop_out_tab_type;
      l_stop_wt_vol_out_tab  WSH_TRIP_STOPS_GRP.stop_wt_vol_tab_type;

      l_del_count            NUMBER;
      l_stop_count           NUMBER;

      l_rs                   VARCHAR2(1);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(32767);
      l_location_id          NUMBER;
      l_is_duplicate         VARCHAR2(1);
      l_physical_loc_id      NUMBER;

    BEGIN--{


      -- Populate the trip stops for this trip in a different table
      -- Further processing will use a table with less records
      -- l_stop_info_tab would not be null
      l_stop_local_tab.DELETE;
      FOR stop_count IN l_stop_info_tab.FIRST..l_stop_info_tab.LAST
      LOOP--{
        IF l_stop_info_tab(stop_count).trip_interface_id = l_trip_info_tab(i).trip_interface_id THEN
          -- Add ECO 5008405 here to validate stop location!!!
          -- If location_id is NULL or invalid, log exception
          -- and delete data relevant to this trip_interface_id,
          BEGIN --(
            l_location_id
              :=  to_number(l_stop_info_tab(stop_count).stop_location_id);
          EXCEPTION
            WHEN OTHERS THEN
            -- capture cases where stop_location_id is not a number
            -- special case, need to handle error a bit differently
            l_return_status := 'T';
            FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
            WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Invalid Stop Location, l_return_status:', l_return_status);
            END IF;
            GOTO trip_error;
          END;--}


          WSH_UTIL_VALIDATE.VALIDATE_LOCATION
            (p_location_id =>l_location_id,
             x_return_status => l_rs);

          IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := 'T';-- special case, need to handle error a bit differently
            FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
            WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Invalid Stop Location, l_return_status:', l_return_status);
            END IF;
            GOTO trip_error;
          END IF;

          l_stop_local_tab(l_stop_local_tab.count + 1) := l_stop_info_tab(stop_count);
        END IF;
      END LOOP;--}

      IF l_trip_info_tab(i).trip_id IS NOT NULL THEN--{

        -- Get trip stops in EBS
        -- Find the EBS stops and compare against data being sent
        -- by GC3, if existing EBS stops donot match new GC3 sent
        -- stops, then delete the stops and unassign associated
        -- deliveries
        FOR rec in c_get_stops(l_trip_info_tab(i).trip_id)
        LOOP--{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'===== EBS STOPS =======');
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop id:'||rec.stop_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Location id:'||rec.stop_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop Seq Num:'||rec.stop_sequence_number);
            WSH_DEBUG_SV.logmsg(l_module_name,'Physical Stop id:'||rec.physical_stop_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Physical Location id:'||rec.physical_location_id);
          END IF;

          l_stop_matches := 'N';
          FOR stop_index in l_stop_local_tab.FIRST..l_stop_local_tab.LAST
          LOOP--{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'===== GC3 STOP DESCRIPTION =======');
              WSH_DEBUG_SV.logmsg(l_module_name,'Location id:'||l_stop_local_tab(stop_index).stop_location_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Stop Seq Num:'||l_stop_local_tab(stop_index).stop_sequence_number);
            END IF;

            -- Compare the GC3 sent stop location + stop sequence number
            IF to_number(l_stop_local_tab(stop_index).stop_location_id) = rec.stop_location_id AND
               l_stop_local_tab(stop_index).stop_sequence_number = rec.stop_sequence_number
            THEN--{
              -- Physical Stop Match
              -- Stop with matching Location + Sequence Number in GC3 and EBS
              l_stop_matches := 'Y';
              -- Stop_id would normally be null and dml_action be 'C'
              -- But for update scenario, mark it as U and with stop id
              l_stop_local_tab(stop_index).dml_action := 'U';
              l_stop_local_tab(stop_index).stop_id    := rec.stop_id;

              -- Populate other fields to ensure they are not overridden during Update
              l_stop_local_tab(stop_index).departure_gross_weight  := rec.departure_gross_weight;
              l_stop_local_tab(stop_index).departure_net_weight    := rec.departure_net_weight;
              l_stop_local_tab(stop_index).departure_volume        := rec.departure_volume;
              l_stop_local_tab(stop_index).weight_uom_code         := rec.weight_uom_code;
              l_stop_local_tab(stop_index).volume_uom_code         := rec.volume_uom_code;
              l_stop_local_tab(stop_index).departure_seal_code     := rec.departure_seal_code;
              l_stop_local_tab(stop_index).departure_fill_percent  := rec.departure_fill_percent;

              l_stop_local_tab(stop_index).tp_attribute_category   := rec.tp_attribute_category;
              l_stop_local_tab(stop_index).tp_attribute1           := rec.tp_attribute1;
              l_stop_local_tab(stop_index).tp_attribute2           := rec.tp_attribute2;
              l_stop_local_tab(stop_index).tp_attribute3           := rec.tp_attribute3;
              l_stop_local_tab(stop_index).tp_attribute4           := rec.tp_attribute4;
              l_stop_local_tab(stop_index).tp_attribute5           := rec.tp_attribute5;
              l_stop_local_tab(stop_index).tp_attribute6           := rec.tp_attribute6;
              l_stop_local_tab(stop_index).tp_attribute7           := rec.tp_attribute7;
              l_stop_local_tab(stop_index).tp_attribute8           := rec.tp_attribute8;
              l_stop_local_tab(stop_index).tp_attribute9           := rec.tp_attribute9;
              l_stop_local_tab(stop_index).tp_attribute10          := rec.tp_attribute10;
              l_stop_local_tab(stop_index).tp_attribute11          := rec.tp_attribute11;
              l_stop_local_tab(stop_index).tp_attribute12          := rec.tp_attribute12;
              l_stop_local_tab(stop_index).tp_attribute13          := rec.tp_attribute13;
              l_stop_local_tab(stop_index).tp_attribute14          := rec.tp_attribute14;
              l_stop_local_tab(stop_index).tp_attribute15          := rec.tp_attribute15;

              l_stop_local_tab(stop_index).attribute_category   := rec.attribute_category;
              l_stop_local_tab(stop_index).attribute1           := rec.attribute1;
              l_stop_local_tab(stop_index).attribute2           := rec.attribute2;
              l_stop_local_tab(stop_index).attribute3           := rec.attribute3;
              l_stop_local_tab(stop_index).attribute4           := rec.attribute4;
              l_stop_local_tab(stop_index).attribute5           := rec.attribute5;
              l_stop_local_tab(stop_index).attribute6           := rec.attribute6;
              l_stop_local_tab(stop_index).attribute7           := rec.attribute7;
              l_stop_local_tab(stop_index).attribute8           := rec.attribute8;
              l_stop_local_tab(stop_index).attribute9           := rec.attribute9;
              l_stop_local_tab(stop_index).attribute10          := rec.attribute10;
              l_stop_local_tab(stop_index).attribute11          := rec.attribute11;
              l_stop_local_tab(stop_index).attribute12          := rec.attribute12;
              l_stop_local_tab(stop_index).attribute13          := rec.attribute13;
              l_stop_local_tab(stop_index).attribute14          := rec.attribute14;
              l_stop_local_tab(stop_index).attribute15          := rec.attribute15;

              -- End of Populating other fields
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Matching Stop found,id:'||rec.stop_id);
              END IF;
              EXIT; --from the l_stop_local_tab loop
            ELSE -- also check for Internal Location

              -- If the EBS Stop has the dummy location for incoming GC3 stop
              -- then convert EBS Stop Location to physical location and then
              -- compare
              WSH_LOCATIONS_PKG.convert_internal_cust_location(
                p_internal_cust_location_id => rec.stop_location_id,
                --p_internal_cust_location_id => l_stop_local_tab(stop_index).stop_location_id,
                x_internal_org_location_id  => l_physical_loc_id,
                x_return_status             => l_rs);

              -- Treat this also as Invalid Stop Location
              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                l_return_status := 'T';-- special case, need to handle error a bit differently
                FND_MESSAGE.SET_NAME('WSH','WSH_OI_INVALID_LOCATION');
                WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'Invalid Stop Location, l_return_status:', l_return_status);
                END IF;
                GOTO trip_error;
              END IF;

              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Physical Location:',l_physical_loc_id);
              END IF;

              -- Compare the GC3 sent stop location + stop sequence number
              IF to_number(l_stop_local_tab(stop_index).stop_location_id) = l_physical_loc_id AND
                 l_stop_local_tab(stop_index).stop_sequence_number = rec.stop_sequence_number
              THEN--{
                -- Physical Stop Match
                -- Stop with matching Location + Sequence Number in GC3 and EBS
                l_stop_matches := 'Y';
                -- Stop_id would normally be null and dml_action be 'C'
                -- But for update scenario, mark it as U and with stop id
                l_stop_local_tab(stop_index).dml_action := 'U';
                l_stop_local_tab(stop_index).stop_id    := rec.stop_id;

                -- Populate other fields to ensure they are not overridden during Update
                l_stop_local_tab(stop_index).departure_gross_weight  := rec.departure_gross_weight;
                l_stop_local_tab(stop_index).departure_net_weight    := rec.departure_net_weight;
                l_stop_local_tab(stop_index).departure_volume        := rec.departure_volume;
                l_stop_local_tab(stop_index).weight_uom_code         := rec.weight_uom_code;
                l_stop_local_tab(stop_index).volume_uom_code         := rec.volume_uom_code;
                l_stop_local_tab(stop_index).departure_seal_code     := rec.departure_seal_code;
                l_stop_local_tab(stop_index).departure_fill_percent  := rec.departure_fill_percent;

                l_stop_local_tab(stop_index).tp_attribute_category   := rec.tp_attribute_category;
                l_stop_local_tab(stop_index).tp_attribute1           := rec.tp_attribute1;
                l_stop_local_tab(stop_index).tp_attribute2           := rec.tp_attribute2;
                l_stop_local_tab(stop_index).tp_attribute3           := rec.tp_attribute3;
                l_stop_local_tab(stop_index).tp_attribute4           := rec.tp_attribute4;
                l_stop_local_tab(stop_index).tp_attribute5           := rec.tp_attribute5;
                l_stop_local_tab(stop_index).tp_attribute6           := rec.tp_attribute6;
                l_stop_local_tab(stop_index).tp_attribute7           := rec.tp_attribute7;
                l_stop_local_tab(stop_index).tp_attribute8           := rec.tp_attribute8;
                l_stop_local_tab(stop_index).tp_attribute9           := rec.tp_attribute9;
                l_stop_local_tab(stop_index).tp_attribute10          := rec.tp_attribute10;
                l_stop_local_tab(stop_index).tp_attribute11          := rec.tp_attribute11;
                l_stop_local_tab(stop_index).tp_attribute12          := rec.tp_attribute12;
                l_stop_local_tab(stop_index).tp_attribute13          := rec.tp_attribute13;
                l_stop_local_tab(stop_index).tp_attribute14          := rec.tp_attribute14;
                l_stop_local_tab(stop_index).tp_attribute15          := rec.tp_attribute15;

                l_stop_local_tab(stop_index).attribute_category   := rec.attribute_category;
                l_stop_local_tab(stop_index).attribute1           := rec.attribute1;
                l_stop_local_tab(stop_index).attribute2           := rec.attribute2;
                l_stop_local_tab(stop_index).attribute3           := rec.attribute3;
                l_stop_local_tab(stop_index).attribute4           := rec.attribute4;
                l_stop_local_tab(stop_index).attribute5           := rec.attribute5;
                l_stop_local_tab(stop_index).attribute6           := rec.attribute6;
                l_stop_local_tab(stop_index).attribute7           := rec.attribute7;
                l_stop_local_tab(stop_index).attribute8           := rec.attribute8;
                l_stop_local_tab(stop_index).attribute9           := rec.attribute9;
                l_stop_local_tab(stop_index).attribute10          := rec.attribute10;
                l_stop_local_tab(stop_index).attribute11          := rec.attribute11;
                l_stop_local_tab(stop_index).attribute12          := rec.attribute12;
                l_stop_local_tab(stop_index).attribute13          := rec.attribute13;
                l_stop_local_tab(stop_index).attribute14          := rec.attribute14;
                l_stop_local_tab(stop_index).attribute15          := rec.attribute15;
                -- End of Populating other fields

                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Matching Stop found,id:'||rec.stop_id);
                END IF;
                EXIT; --from the l_stop_local_tab loop
              END IF;--}
            END IF;--}
          END LOOP;--} -- looping thru l_stop_local_tab

          -- No incoming stop from GC3 on this trip matches existing stop in EBS
          IF l_stop_matches = 'N' THEN--{
            --
            -- Need to unassign any deliveries associates to this stop and then
            -- delete this stop in EBS.
            -- The call to Delete Stops will delete the delivery legs and remove any
            -- association between delivery and trip.
            -- But the GC3 need is to unassign these deliveries from trip and mark them
            -- with tms_interface_flag = 'CREATION_REQUIRED' on successful operation.
            -- The deliveries will be left as include for planning.
            --
            -- i.  Find deliveries associated with this stop id and then unassign
            -- using loop instead of bulk fetch, as a loop would be required to populate
            -- l_del_attrs.delivery_id
            l_del_attrs.DELETE;
            FOR del_rec in c_get_deliveries(rec.stop_id)
            LOOP
              -- Need to make sure this delivery has not already been selected
              -- For example, if GC3 sends request to delete 2 trip stops which
              -- are linked to 1 delivery, then donot launch unassign-trip twice
              l_is_duplicate := 'N';

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Unassign Dlvy Tab count:'||l_unassigned_delivery_id_tab.count);
              END IF;
              IF l_del_attrs.count > 0 THEN
                FOR duplicate in l_del_attrs.FIRST..l_del_attrs.LAST
                LOOP
                  IF l_del_attrs(duplicate).delivery_id = del_rec.delivery_id THEN
                    -- Duplicate record found
                    l_is_duplicate := 'Y';
                  END IF;
                END LOOP;
              END IF;

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Is Duplicate:'||l_is_duplicate);
              END IF;

              -- Only increase the count for non-duplicate deliveries
              -- Cursor would have selected deliveries with dummy stops, Internal Location
              IF l_is_duplicate = 'N' THEN
                l_del_count := l_del_attrs.count + 1;
                l_del_attrs(l_del_count).delivery_id := del_rec.delivery_id;
                l_del_attrs(l_del_count).organization_id := del_rec.organization_id;
                l_unassigned_delivery_id_tab(l_unassigned_delivery_id_tab.count + 1) :=
                 del_rec.delivery_id;
                l_unassigned_dlvy_version_tab(l_unassigned_delivery_id_tab.count) :=
                 del_rec.tms_version_number;

              END IF;

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'After populating l_del_attrs count:'||l_del_attrs.count);
                WSH_DEBUG_SV.logmsg(l_module_name,'After populating Unassign Dlvy Tab count:'||l_unassigned_delivery_id_tab.count);
              END IF;

            END LOOP;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Deliveries associated to the stop:'||l_del_attrs.count);
            END IF;

            IF l_del_attrs.count > 0 THEN--{
              l_del_action_prms.caller      := 'FTE_TMS_INTEGRATION'; --'FTE_TMS_RELEASE';
              l_del_action_prms.action_code := 'UNASSIGN-TRIP';
              l_del_action_prms.trip_id     := l_trip_info_tab(i).trip_id;

              WSH_DELIVERIES_GRP.delivery_action(
                p_api_version_number => 1.0,
                p_init_msg_list      => FND_API.G_TRUE,
                p_commit             => FND_API.G_FALSE,
                p_action_prms        => l_del_action_prms,
                p_rec_attr_tab       => l_del_attrs,
                x_delivery_out_rec   => l_del_action_rec,
                x_defaults_rec       => l_del_defaults,
                x_return_status      => l_rs,
                x_msg_count          => l_msg_count,
                x_msg_data           => l_msg_data);

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Unassign Delivery'||l_rs);
              END IF;

              -- Handle error here !!!, should these deliveries be deleted from unassign table list??
              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'Unassign Delivery Failed: l_return_status', l_return_status);
                END IF;
                GOTO trip_error;
              END IF;
            END IF;--}

            -- ii. Call WSH_TRIP_STOPS_GRP.Stop_Action() to DELETE
            l_stop_action_prms.caller      := 'FTE_TMS_INTEGRATION';
            l_stop_action_prms.action_code := 'DELETE';
            l_stop_attrs(1).stop_id := rec.stop_id;
            l_stop_attrs(1).trip_id := l_trip_info_tab(i).trip_id;

            WSH_TRIP_STOPS_GRP.stop_action(
              p_api_version_number => 1.0,
              p_init_msg_list      => FND_API.G_TRUE,
              p_commit             => FND_API.G_FALSE,
              p_action_prms        => l_stop_action_prms,
              p_rec_attr_tab       => l_stop_attrs,
              x_stop_out_rec       => l_stop_action_rec,
              x_def_rec            => l_stop_defaults,
              x_return_status      => l_rs,
              x_msg_count          => l_msg_count,
              x_msg_data           => l_msg_data);

            -- Handle return status here, treat warning as success
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after deleting stop'||l_rs);
            END IF;
            IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              -- go to trip_error
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Delete Trip Stop Failed: l_return_status', l_return_status);
              END IF;
              GOTO trip_error;
            END IF;
          END IF;--} -- if l_stop_matches = 'N'

        END LOOP;--} -- processing pre-existing stops existing in EBS for the GC3 trip

      END IF;--} -- if l_trip_info_tab(i).trip_id is not null, trip pre-existed in EBS

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Before Internal Locations Check, Stop Local Table, Count'||l_stop_local_tab.count);
      END IF;

      -- Internal Locations Check here
      -- Call Process Internal Locations Here
      IF l_dleg_local_tab.count > 0 AND l_stop_local_tab.count > 0 THEN--{
        process_internal_locations
          (x_delivery_tab  => l_dleg_local_tab,
           x_stop_tab      => l_stop_local_tab,
           x_return_status => l_rs);

        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Process Internal Location, l_return_status:', l_return_status);
          END IF;
          GOTO trip_error;
        END IF;
      END IF;--}

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After Internal Locations Check,Stop Local Table, Count'||l_stop_local_tab.count);
      END IF;

      -- Loop across l_stop_local_tab for Create and Update stops
      -- Initialize l_stop_attrs
      -- l_stop_local_tab would not be not null
      FOR stop_rec IN l_stop_local_tab.FIRST..l_stop_local_tab.LAST
      LOOP--{
        -- Find stops based on the trip_interface_id link and process only these
        -- Look at removing this later as l_stop_local_tab is only for the selected trip
        -- !!!! REMOVE condition !!!
        IF l_stop_local_tab(stop_rec).trip_interface_id = l_trip_info_tab(i).trip_interface_id
        THEN--{

          l_stop_attrs.DELETE;
          -- Group API does not accept create and update together
          -- as action can either be CREATE or UPDATE
          l_stop_in_rec.caller := 'FTE_TMS_INTEGRATION';

          IF l_stop_local_tab(stop_rec).dml_action = 'C' THEN--{
            -- action is CREATE
            l_stop_in_rec.action_code := 'CREATE';
          ELSE -- dml_action = 'U'
            -- action is UPDATE
            l_stop_in_rec.action_code := 'UPDATE';
          END IF; --}

          l_stop_count := l_stop_attrs.count + 1;

          l_stop_attrs(l_stop_count).STOP_ID                  := l_stop_local_tab(stop_rec).stop_id;
          l_stop_attrs(l_stop_count).TP_STOP_ID               := l_stop_local_tab(stop_rec).tp_stop_id;
          l_stop_attrs(l_stop_count).TRIP_ID                  := l_trip_id;
          --
          l_stop_attrs(l_stop_count).STOP_LOCATION_ID         := to_number(l_stop_local_tab(stop_rec).stop_location_id);
          l_stop_attrs(l_stop_count).STOP_SEQUENCE_NUMBER     := l_stop_local_tab(stop_rec).stop_sequence_number;
          --
          -- ECO 5101760
          -- Convert Stop level planned dates, based on the timezone code
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'OTM sent Planned Arrival Date',l_stop_local_tab(stop_rec).planned_arrival_date);
            WSH_DEBUG_SV.log(l_module_name,'OTM sent Planned Departure Date',l_stop_local_tab(stop_rec).planned_departure_date);
          END IF;

          get_server_time
            (p_source_time            => l_stop_local_tab(stop_rec).planned_arrival_date,
             p_source_timezone_code   => l_stop_local_tab(stop_rec).timezone_code,
             x_server_time            => l_stop_local_tab(stop_rec).PLANNED_ARRIVAL_DATE,
             x_return_status          => l_rs,
             x_msg_count              => l_msg_count,
             x_msg_data               => l_msg_data);

          IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Get Server Time for Planned Arrival Date, l_return_status:', l_return_status);
            END IF;
            GOTO trip_error;
          END IF;

          get_server_time
            (p_source_time            => l_stop_local_tab(stop_rec).planned_departure_date,
             p_source_timezone_code   => l_stop_local_tab(stop_rec).timezone_code,
             x_server_time            => l_stop_local_tab(stop_rec).PLANNED_DEPARTURE_DATE,
             x_return_status          => l_rs,
             x_msg_count              => l_msg_count,
             x_msg_data               => l_msg_data);

          IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Get Server Time for Planned Arrival Date, l_return_status:', l_return_status);
            END IF;
            GOTO trip_error;
          END IF;

          l_stop_attrs(l_stop_count).PLANNED_ARRIVAL_DATE     := l_stop_local_tab(stop_rec).planned_arrival_date;
          l_stop_attrs(l_stop_count).PLANNED_DEPARTURE_DATE   := l_stop_local_tab(stop_rec).planned_departure_date;

          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Converted Planned Arrival Date',l_stop_attrs(l_stop_count).PLANNED_ARRIVAL_DATE);
            WSH_DEBUG_SV.log(l_module_name,'Converted Planned Departure Date',l_stop_attrs(l_stop_count).PLANNED_departure_DATE);
          END IF;
          -- End of ECO 5101760
          --
          l_stop_attrs(l_stop_count).DEPARTURE_GROSS_WEIGHT   := nvl(l_stop_local_tab(stop_rec).departure_gross_weight,0);
          l_stop_attrs(l_stop_count).DEPARTURE_NET_WEIGHT     := nvl(l_stop_local_tab(stop_rec).departure_net_weight,0);
          l_stop_attrs(l_stop_count).DEPARTURE_VOLUME         := nvl(l_stop_local_tab(stop_rec).departure_volume,0);
          l_stop_attrs(l_stop_count).DEPARTURE_SEAL_CODE      := l_stop_local_tab(stop_rec).departure_seal_code;
          l_stop_attrs(l_stop_count).DEPARTURE_FILL_PERCENT   := l_stop_local_tab(stop_rec).departure_fill_percent;
          l_stop_attrs(l_stop_count).WKEND_LAYOVER_STOPS      := l_stop_local_tab(stop_rec).wkend_layover_stops;
          l_stop_attrs(l_stop_count).WKDAY_LAYOVER_STOPS      := l_stop_local_tab(stop_rec).wkday_layover_stops;
          l_stop_attrs(l_stop_count).SHIPMENTS_TYPE_FLAG      := l_stop_local_tab(stop_rec).shipments_type_flag;
          --l_stop_attrs(l_stop_count).weight_uom_code          := l_stop_local_tab(stop_rec).weight_uom_code;
          --l_stop_attrs(l_stop_count).volume_uom_code          := l_stop_local_tab(stop_rec).volume_uom_code;

          --UOM to be derived from delivery for new trip stops only
          IF l_stop_local_tab(stop_rec).stop_id IS NULL THEN--{
            -- For the stop_interface_id in l_stop_local_tab(stop_rec), find delivery uom
            IF l_dleg_local_tab.COUNT > 0 THEN
              FOR dleg_rec IN l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
              LOOP--{
                IF l_dleg_local_tab(dleg_rec).pick_up_stop_interface_id = l_stop_local_tab(stop_rec).stop_interface_id THEN
                  -- For 1st delivery, get the organization id
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_WV_UTILS.GET_DEFAULT_UOMS for pickup');
                  END IF;
                  --
                  wsh_wv_utils.get_default_uoms
                    (p_organization_id => l_dleg_local_tab(dleg_rec).organization_id,
                     x_weight_uom_code => l_stop_local_tab(stop_rec).weight_uom_code,
                     x_volume_uom_code => l_stop_local_tab(stop_rec).volume_uom_code,
                     x_return_status   => l_rs);
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_WV_UTILS.GET_DEFAULT_UOMS'||l_rs);
                  END IF;
                  -- Handle return Status error!!!
                  IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name, 'Get_Default_UOM failed: l_return_status', l_return_status);
                    END IF;
                    GOTO trip_error;
                  END IF;

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'WT UOM:'||l_stop_local_tab(stop_rec).weight_uom_code||'VOLUME UOM:'||l_stop_local_tab(stop_rec).volume_uom_code);
                  END IF;
                ELSE -- to find UOM for dropoff stops, which are not pickups
                  IF l_dleg_local_tab(dleg_rec).drop_off_stop_interface_id = l_stop_local_tab(stop_rec).stop_interface_id THEN--{
                  -- For 1st delivery, get the organization id
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Calling WSH_WV_UTILS.GET_DEFAULT_UOMS for dropoff');
                  END IF;
                  --
                  wsh_wv_utils.get_default_uoms
                    (p_organization_id => l_dleg_local_tab(dleg_rec).organization_id,
                     x_weight_uom_code => l_stop_local_tab(stop_rec).weight_uom_code,
                     x_volume_uom_code => l_stop_local_tab(stop_rec).volume_uom_code,
                     x_return_status   => l_rs);
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'Return Status from WSH_WV_UTILS.GET_DEFAULT_UOMS'||l_rs);
                  END IF;
                  IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name, 'Get_Default_UOM Failed: l_return_status', l_return_status);
                    END IF;
                    GOTO trip_error;
                  END IF;
                  -- Handle return Status error!!!

                  IF l_debug_on THEN
                    WSH_DEBUG_SV.logmsg(l_module_name,'WT UOM:'||l_stop_local_tab(stop_rec).weight_uom_code||'VOLUME UOM:'||l_stop_local_tab(stop_rec).volume_uom_code);
                  END IF;

                  END IF; --}
                END IF;
              END LOOP;--}
            END IF;
          END IF; --} -- derive UOM

          l_stop_attrs(l_stop_count).WEIGHT_UOM_CODE       := l_stop_local_tab(stop_rec).weight_uom_code;
          l_stop_attrs(l_stop_count).VOLUME_UOM_CODE       := l_stop_local_tab(stop_rec).volume_uom_code;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE_CATEGORY := l_stop_local_tab(stop_rec).tp_attribute_category;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE1         := l_stop_local_tab(stop_rec).tp_attribute1;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE10        := l_stop_local_tab(stop_rec).tp_attribute10;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE11        := l_stop_local_tab(stop_rec).tp_attribute11;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE12        := l_stop_local_tab(stop_rec).tp_attribute12;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE13        := l_stop_local_tab(stop_rec).tp_attribute13;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE14        := l_stop_local_tab(stop_rec).tp_attribute14;
          l_stop_attrs(l_stop_count).TP_ATTRIBUTE15        := l_stop_local_tab(stop_rec).tp_attribute15;

          l_stop_attrs(l_stop_count).ATTRIBUTE_CATEGORY    := l_stop_local_tab(stop_rec).attribute_category;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE1            := l_stop_local_tab(stop_rec).attribute1;
          l_stop_attrs(l_stop_count).ATTRIBUTE10           := l_stop_local_tab(stop_rec).attribute10;
          l_stop_attrs(l_stop_count).ATTRIBUTE11           := l_stop_local_tab(stop_rec).attribute11;
          l_stop_attrs(l_stop_count).ATTRIBUTE12           := l_stop_local_tab(stop_rec).attribute12;
          l_stop_attrs(l_stop_count).ATTRIBUTE13           := l_stop_local_tab(stop_rec).attribute13;
          l_stop_attrs(l_stop_count).ATTRIBUTE14           := l_stop_local_tab(stop_rec).attribute14;
          l_stop_attrs(l_stop_count).ATTRIBUTE15           := l_stop_local_tab(stop_rec).attribute15;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop id:'||l_stop_local_tab(stop_rec).stop_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop Location id:'||l_stop_local_tab(stop_rec).stop_location_id);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop Sequence Number:'||l_stop_local_tab(stop_rec).stop_sequence_number);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop PAD:'||l_stop_local_tab(stop_rec).planned_arrival_date);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop PDD:'||l_stop_local_tab(stop_rec).planned_departure_date);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop Wt UOM:'||l_stop_local_tab(stop_rec).weight_uom_code);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop Vol UOM:'||l_stop_local_tab(stop_rec).volume_uom_code);
            WSH_DEBUG_SV.logmsg(l_module_name,'Before Calling Create_update_Stop,count:'||l_stop_attrs.count);
          END IF;

          wsh_trip_stops_grp.Create_Update_Stop(
            p_api_version_number     =>    1.0,
            p_init_msg_list          =>    FND_API.G_FALSE,
            p_commit                 =>    FND_API.G_FALSE,
            p_in_rec                 =>    l_stop_in_rec,
            p_rec_attr_tab           =>    l_stop_attrs,
            x_stop_out_tab           =>    l_stop_out_tab,
            x_return_status          =>    l_rs,
            x_msg_count              =>    l_msg_count,
            x_msg_data               =>    l_msg_data,
            x_stop_wt_vol_out_tab    =>    l_stop_wt_vol_out_tab);


          -- Handle return status and error Here !!!
          IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Create Update Trip Stop Failed: l_return_status', l_return_status);
            END IF;
            GOTO trip_error;
          END IF;


          -- Need Stop id while assigning delivery to trip, for Update it is already populated
          IF l_stop_in_rec.action_code = 'CREATE' AND l_stop_out_tab.count > 0 THEN
            l_stop_local_tab(stop_rec).stop_id := l_stop_out_tab(l_stop_out_tab.FIRST).stop_id;
          END IF;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Create_Update_stop'||l_rs);
            WSH_DEBUG_SV.logmsg(l_module_name,'Stop id after Create_Update_stop'||l_stop_local_tab(stop_rec).stop_id);
          END IF;

          -- OTM Dock Door App Sched Proj
	  DECLARE
	  CURSOR c_dock_appt_rec(c_stop_interface_id IN NUMBER, c_group_id IN NUMBER) IS
          SELECT wtsi.dock_name, wnd.organization_id, wtsi.start_time, wtsi.end_time
          FROM   wsh_del_legs_interface       wdli,
                 wsh_new_del_interface        wndi,
                 wsh_new_deliveries           wnd,
                 wsh_trip_stops_interface     wtsi,
                 wsh_trips_interface          wti
          WHERE  wti.group_id = c_group_id
          AND    wti.interface_action_code       = G_TMS_RELEASE_CODE
          AND    wtsi.trip_interface_id          = wti.trip_interface_id
          AND    wtsi.stop_interface_id          = wdli.pick_up_stop_interface_id
          AND    wtsi.interface_action_code      = G_TMS_RELEASE_CODE
          AND    wnd.delivery_id                 = wdli.delivery_id
          AND    wndi.delivery_id                = wdli.delivery_id
          AND    wdli.interface_action_code      = G_TMS_RELEASE_CODE
          AND    wtsi.stop_interface_id = c_stop_interface_id;

	  l_dock_name           VARCHAR2(200);
          l_organization_id     NUMBER;
          l_start_time          DATE;
	  x_start_time          DATE := NULL;
          l_end_time            DATE;
	  x_end_time            DATE := NULL;
          l_shipping_parameters WSH_SHIPPING_PARAMS_PVT.PARAMETER_REC_TYP;

	  BEGIN
	    -- Fetching Dock Door Appt Scheduling info for the pick_up_stop
	    --Bug7717569 replaced p_group_id with l_trip_info_tab(i).group_id
            OPEN c_dock_appt_rec(l_stop_local_tab(stop_rec).stop_interface_id,l_trip_info_tab(i).group_id);
	    -- Getting info for the first record as the info. will be same even if several deliveries have the same pick up stop
            FETCH c_dock_appt_rec INTO l_dock_name, l_organization_id, l_start_time, l_end_time;
	    CLOSE c_dock_appt_rec;
            IF (l_organization_id IS NOT NULL) THEN  --{
              IF (wsh_util_validate.check_wms_org(l_organization_id) = 'Y') THEN --{
	        IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Calling WSH_SHIPPING_PARAMS_PVT.GET',WSH_DEBUG_SV.C_PROC_LEVEL);
		END IF;
                WSH_SHIPPING_PARAMS_PVT.GET(p_organization_id => l_organization_id,
                                            x_param_info      => l_shipping_parameters,
                                            x_return_status   => l_rs);

                IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                      WSH_DEBUG_SV.log(l_module_name, 'WSH_SHIPPING_PARAMS_PVT.GET Failed: l_return_status', l_return_status);
                   END IF;
                   GOTO trip_error;
                END IF;

                IF (l_shipping_parameters.dock_appt_scheduling_flag = 'Y') THEN

		  IF (l_start_time IS NOT NULL) THEN
		    get_server_time(p_source_time          => l_start_time,
                                    p_source_timezone_code => l_stop_local_tab(stop_rec).timezone_code,
                                    x_server_time          => x_start_time,
                                    x_return_status        => l_rs,
                                    x_msg_count            => l_msg_count,
                                    x_msg_data             => l_msg_data);

                    IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'Get Server Time for Dock Door Appointment Start Time, l_return_status:', l_return_status);
                      END IF;
                      GOTO trip_error;
                    END IF;
		  END IF;

                  IF (l_end_time IS NOT NULL) THEN
		    get_server_time(p_source_time          => l_end_time,
                                    p_source_timezone_code => l_stop_local_tab(stop_rec).timezone_code,
                                    x_server_time          => x_end_time,
                                    x_return_status        => l_rs,
                                    x_msg_count            => l_msg_count,
                                    x_msg_data             => l_msg_data);

                    IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      IF l_debug_on THEN
                        WSH_DEBUG_SV.log(l_module_name, 'Get Server Time for Dock Door Appointment End Time, l_return_status:', l_return_status);
                      END IF;
                      GOTO trip_error;
                    END IF;
		  END IF;

                  -- Populating table with the Dock Door App Sched Info. to be sent to WMS
                  l_dock_appt_index := l_dock_appt_tab.COUNT + 1;
                  l_dock_appt_tab(l_dock_appt_index).dock_name := l_dock_name;
                  l_dock_appt_tab(l_dock_appt_index).trip_stop_id := l_stop_local_tab(stop_rec).stop_id;
                  l_dock_appt_tab(l_dock_appt_index).organization_id := l_organization_id;
		  l_dock_appt_tab(l_dock_appt_index).start_time := x_start_time;
                  l_dock_appt_tab(l_dock_appt_index).end_time := x_end_time;

		  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'l_dock_appt_tab('||l_dock_appt_index||').dock_name',l_dock_appt_tab(l_dock_appt_index).dock_name);
                    WSH_DEBUG_SV.log(l_module_name, 'l_dock_appt_tab('||l_dock_appt_index||').stop_id',l_dock_appt_tab(l_dock_appt_index).trip_stop_id);
                    WSH_DEBUG_SV.log(l_module_name, 'l_dock_appt_tab('||l_dock_appt_index||').organization_id',l_dock_appt_tab(l_dock_appt_index).organization_id);
                    WSH_DEBUG_SV.log(l_module_name, 'l_dock_appt_tab('||l_dock_appt_index||').start_time',l_dock_appt_tab(l_dock_appt_index).start_time);
                    WSH_DEBUG_SV.log(l_module_name, 'l_dock_appt_tab('||l_dock_appt_index||').end_time',l_dock_appt_tab(l_dock_appt_index).end_time);
		  END IF;
                END IF; --} Cheking dock_appt_schedling_flag
	      END IF; --} Checking WMS Org
            END IF; --} Checking l_organization_id as NULL
	  EXCEPTION
	    WHEN OTHERS THEN
	      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Error while fetching Dock Door Appointment Scheduling Info.');
              END IF;
	      IF (c_dock_appt_rec%ISOPEN) THEN
		CLOSE c_dock_appt_rec;
	      END IF;
              GOTO trip_error;
          END;

          DECLARE
            CURSOR c_1 IS
              select stop_id,stop_location_id,stop_sequence_number,
                     physical_stop_id,physical_location_id
                from wsh_trip_stops
               where stop_id = l_stop_local_tab(stop_rec).stop_id;
          BEGIN
            FOR st in c_1
            LOOP
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Stop id:'||st.stop_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Stop Location id:'||st.stop_location_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Stop Seq Num:'||st.stop_sequence_number);
                WSH_DEBUG_SV.logmsg(l_module_name,'Physical Stop id:'||st.physical_stop_id);
                WSH_DEBUG_SV.logmsg(l_module_name,'Physical Loc id:'||st.physical_location_id);
              END IF;
            END LOOP;
          END;

        END IF;--} -- matching trip_interface_id to process only relevant records
      END LOOP;--} -- looping across l_stop_local_tab

    END;--} -- end of process trip stops


    -- 4e. Process Deliveries
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      WSH_DEBUG_SV.logmsg(l_module_name,'4e. PROCESS DELIVERIES');
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    END IF;

    DECLARE

      l_delivery_tab         WSH_TMS_RELEASE.delivery_tab;
      l_delivery_id_tab      WSH_UTIL_CORE.id_tab_type;

      l_del_attrs            WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
      l_del_action_prms      WSH_DELIVERIES_GRP.action_parameters_rectype;
      l_del_action_rec       WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
      l_del_defaults         WSH_DELIVERIES_GRP.default_parameters_rectype;

      l_rs                   VARCHAR2(1);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(32767);

      -- flag
      l_del_matches          VARCHAR2(1);

      l_dleg_count           NUMBER;
      l_del_index            WSH_UTIL_CORE.id_tab_type;

    BEGIN--{
      l_delivery_id_tab.DELETE;
      l_del_attrs.DELETE;

      --l_dleg_local_tab.DELETE;
      IF l_dleg_local_tab.COUNT > 0 THEN
        -- Bug 5134725
        -- EBS Version Number will always be equal to or greater than the OTM sent version
        -- Stop further processing, if the EBS version number is greater than OTM version
        -- Bug#7491598(ER,defer planned shipment iface): check the parameter p_latest_version
        -- before raising the error. Processing of lower tms version deliveries is allowed only
        -- when the EBS delivery is 'UPDATE required' from OTM status(tms_interface_flag value should be 'UR'/'UP').
        FOR del_version IN l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
        LOOP --{
          IF l_dleg_local_tab(del_version).tms_version_number >  l_dleg_local_tab(del_version).otm_tms_version_number  THEN
          --{
              IF ( NVL(p_latest_version,'Y') = 'N' AND l_dleg_local_tab(del_version).tms_interface_flag NOT IN ('UR','UP') ) THEN
              --{
                  -- raise error
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'EBS and OTM version number donot match');
                  END IF;
                  FND_MESSAGE.SET_NAME('WSH','WSH_OTM_IB_NOT_UPD_VERSION_ERR');
                  WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                  l_rs := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  EXIT; -- out of this loop
              --}
              END IF;
              --
              IF NVL(p_latest_version,'Y') = 'Y' THEN
              --{
                  -- raise error
                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'EBS and OTM version number donot match');
                  END IF;
                  FND_MESSAGE.SET_NAME('WSH','WSH_OTM_IB_VERSION_ERROR');
                  WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                  l_rs := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  EXIT; -- out of this loop
              --}
              END IF;
          --}
          END IF;
        END LOOP;--}
        -- End of Bug 5134725

        -- Handle return status here !!!
        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          -- go to trip_error
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Version Comparison failed,l_return_status:', l_return_status);
          END IF;
          GOTO trip_error;
        END IF;
        -- End of Bug 5134725
        --
      END IF;

      IF l_trip_info_tab(i).trip_id IS NOT NULL THEN--{
        -- Find EBS deliveries which are currently assigned to this GC3 trip
        find_deliveries_for_trip(
          p_trip_id         => l_trip_info_tab(i).trip_id,
          p_tp_plan_name    => NULL,
          x_delivery_tab    => l_delivery_tab, -- dlvy_interface_id + tms_version_number
          x_delivery_id_tab => l_delivery_id_tab, -- dlvy ids
          x_return_status   => l_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after find_deliveries_for_trip'||l_rs);
        END IF;
        -- Handle return status here !!!
        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          -- go to trip_error
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Find Deliveries for Trip Failed,l_return_status:', l_return_status);
          END IF;
          GOTO trip_error;
        END IF;

        -- Compare the List of deliveries assigned to the Trip(per EBS) with
        -- list of deliveries assigned to the Trip(per GC3)
        -- l_delivery_id_tab and l_delivery_tab count are identical
        IF l_delivery_id_tab.count > 0 THEN
          FOR del_rec IN l_delivery_id_tab.FIRST..l_delivery_id_tab.LAST
          LOOP--{
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Delivery id:',l_delivery_id_tab(del_rec));
            END IF;
            l_del_matches := 'N';
            FOR del_intface_rec IN l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
            LOOP--{
              -- Get only relevant deliveries, based on trip_interface_id
              -- Compare the list
              IF (l_delivery_id_tab(del_rec) = l_dleg_local_tab(del_intface_rec).delivery_id) THEN
                  l_del_matches := 'Y';  --matching delivery found
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name,'Match Delivery id:',l_dleg_local_tab(del_intface_rec).delivery_id);
                END IF;
                EXIT;
              END IF;
            END LOOP;--}

            IF l_del_matches = 'Y' THEN--{
              -- This EBS delivery is still on the same GC3 trip
              -- Will compare if the stops/legs have changed for this assignment
              -- Delivery is on same trip, but new stop linking,then unassign and assign
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Delivery:'||l_delivery_id_tab(del_rec)||' is already assigned to Trip:'||l_trip_info_tab(i).trip_id);
              END IF;
            ELSE -- l_del_matches = 'N'
              -- This EBS delivery is to be unassigned from the GC3 trip
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Delivery:'||l_delivery_id_tab(del_rec)||' to be unassigned from Trip:'||l_trip_info_tab(i).trip_id);
              END IF;
              -- Populate l_del_attrs for call to delivery_action()
              l_del_attrs(l_del_attrs.count + 1).delivery_id := l_delivery_id_tab(del_rec);
              l_del_attrs(l_del_attrs.count).organization_id :=
                l_delivery_tab(l_delivery_id_tab(del_rec)).organization_id;
              -- Append to the l_unassigned_delivery_id_tab
              l_unassigned_delivery_id_tab(l_unassigned_delivery_id_tab.count + 1) :=
                  l_delivery_id_tab(del_rec);
              l_unassigned_dlvy_version_tab(l_unassigned_delivery_id_tab.count) :=
                 l_delivery_tab(l_delivery_id_tab(del_rec)).tms_version_number;
            END IF;--}
          END LOOP;--}
        END IF;
      END IF; --} -- if l_trip_info_tab(i).trip_id is not null

      -- The above Unassignments can be grouped together, as they are for
      -- Deliveries from SAME TRIP.
      -- Bulk Unassignment of Deliveries From Trip
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Deliveries to be unassigned:'||l_del_attrs.count);
      END IF;

      IF l_del_attrs.count > 0 THEN--{
        l_del_action_prms.caller      := 'FTE_TMS_INTEGRATION'; --'FTE_TMS_RELEASE';
        l_del_action_prms.action_code := 'UNASSIGN-TRIP';
        l_del_action_prms.trip_id     := l_trip_info_tab(i).trip_id;

        WSH_DELIVERIES_GRP.delivery_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_del_action_prms,
          p_rec_attr_tab       => l_del_attrs,
          x_delivery_out_rec   => l_del_action_rec,
          x_defaults_rec       => l_del_defaults,
          x_return_status      => l_rs,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Unassign Delivery'||l_rs);
        END IF;
        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Unassign Delivery from Trip Failed: l_return_status', l_return_status);
          END IF;
          GOTO trip_error;
        END IF;
      END IF;--}
      -- End of Using Bulk Unassignment

      -- Call Compare and Unassign API
      -- l_trip_info_tab(i).trip_id can be null or not null
      -- Need to unassign in this API itself as the current trip can
      -- be different for different delivery OR the trip can be same but stops might
      -- have been modified(example: different dropoff stop)
      -- l_unassigned_delivery_id_tab is not being MODIFIED in this procedure
      -- so no need to populate the version tab l_unassigned_dlvy_version_tab
      --
      compare_trip_for_deliveries
        (p_dleg_tab        => l_dleg_local_tab, --IN/OUT
         p_trip_id         => l_trip_info_tab(i).trip_id,
         x_unassign_id_tab => l_unassigned_delivery_id_tab,
         --x_unassign_ver_tab => l_unassigned_dlvy_version_tab,
         x_return_status   => l_rs);
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Comparing Trips:'||l_rs);
      END IF;
      -- Handle return Status here !!!
      IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Compare Trip for Deliveries Failed: l_return_status', l_return_status);
        END IF;
        GOTO trip_error;
      END IF;

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unassign Delivery Tab Count:'||l_unassigned_delivery_id_tab.count);
      END IF;

      --
      -- ASSIGN ALL DELIVERIES in l_dleg_local_tab to l_trip_info_tab(i).trip_id
      -- DELETE the deliveries from l_unassigned_delivery_id_tab, which were successfully assigned
      -- One option is to not populate l_unassigned_delivery_id_tab after procedure
      -- compare_trip_for_deliveries as the input set of delivery ids is based on the deliveries
      -- which have to be assigned to the trip l_trip_id using the stops

      l_del_attrs.DELETE;
      l_del_action_prms := NULL;
      l_del_action_rec  := NULL;
      l_del_defaults    := NULL;

      l_del_action_prms.caller      := 'FTE_TMS_INTEGRATION';
      l_del_action_prms.action_code := 'ASSIGN-TRIP';

      -- identical for all deliveries in l_dleg_local_tab
      l_del_action_prms.trip_id     := l_trip_id;

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'DLEG LOCAL TAB COUNT:', l_dleg_local_tab.count);
        WSH_DEBUG_SV.log(l_module_name, 'DLVY ID TAB COUNT:', l_dlvy_id_tab.count);
      END IF;

      IF l_dleg_local_tab.count > 0 THEN--{
        FOR assign_count IN l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
        LOOP--{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery:'||l_dleg_local_tab(assign_count).delivery_id||' has processed flag of:'||l_dleg_local_tab(assign_count).processed_flag);
          END IF;
          -- No need to process the deliveries which still have the same assignment
          -- as before
          IF l_dleg_local_tab(assign_count).processed_flag = 'Y' THEN--{
            l_dlvy_id_tab(l_dlvy_id_tab.count + 1) := l_dleg_local_tab(assign_count).delivery_id;
            l_dlvy_version_tab(l_dlvy_id_tab.count) := l_dleg_local_tab(assign_count).tms_version_number;
            -- skip to next delivery
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Skip Delivery:', l_dleg_local_tab(assign_count).delivery_id);
            END IF;
            -- do not exit

          ELSE--} --{

            -- Again processing one delivery at a time as we need to specify the pickup
            -- and dropoff stop details which are a record and not table
            -- Always populating 1st index
            l_del_attrs(1).delivery_id        := l_dleg_local_tab(assign_count).delivery_id;
            l_del_attrs(1).organization_id    := l_dleg_local_tab(assign_count).organization_id;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Process Delivery:',l_dleg_local_tab(assign_count).delivery_id);
            END IF;

            -- Need to find EBS stop id, GC3 sent planned dates
            -- Location and Sequence Number are part of dleg data structure
            FOR pkup_stop IN l_stop_local_tab.FIRST..l_stop_local_tab.LAST
            LOOP
              IF( l_stop_local_tab(pkup_stop).stop_interface_id
                   = l_dleg_local_tab(assign_count).pick_up_stop_interface_id ) AND
                 (to_number(l_stop_local_tab(pkup_stop).stop_location_id)
                   = to_number(l_dleg_local_tab(assign_count).pickup_stop_location_id)) --for Internal Location
                 -- as the dummy and physical stops in this table have same stop_interface_id
                 -- but different stop_location_id
              THEN
                -- Pickup Information
                l_del_action_prms.pickup_stop_id   := l_stop_local_tab(pkup_stop).stop_id;
                l_del_action_prms.pickup_loc_id    := to_number(l_stop_local_tab(pkup_stop).stop_location_id);
                l_del_action_prms.pickup_stop_seq  := l_stop_local_tab(pkup_stop).stop_sequence_number;
                l_del_action_prms.pickup_arr_date  := l_stop_local_tab(pkup_stop).planned_arrival_date;
                l_del_action_prms.pickup_dep_date  := l_stop_local_tab(pkup_stop).planned_departure_date;
                --l_del_action_prms.pickup_stop_status := 'OP';
              END IF;
            END LOOP;

            FOR dropoff_stop IN l_stop_local_tab.FIRST..l_stop_local_tab.LAST
            LOOP
              IF (l_stop_local_tab(dropoff_stop).stop_interface_id
                   = l_dleg_local_tab(assign_count).drop_off_stop_interface_id) AND
                 (to_number(l_stop_local_tab(dropoff_stop).stop_location_id)
                   = to_number(l_dleg_local_tab(assign_count).dropoff_stop_location_id)) --for Internal Location
              THEN
                -- Dropoff Information
                l_del_action_prms.dropoff_stop_id  := l_stop_local_tab(dropoff_stop).stop_id;
                l_del_action_prms.dropoff_loc_id   := to_number(l_stop_local_tab(dropoff_stop).stop_location_id);
                l_del_action_prms.dropoff_stop_seq := l_stop_local_tab(dropoff_stop).stop_sequence_number;
                l_del_action_prms.dropoff_arr_date := l_stop_local_tab(dropoff_stop).planned_arrival_date;
                l_del_action_prms.dropoff_dep_date := l_stop_local_tab(dropoff_stop).planned_departure_date;
                --l_del_action_prms.dropoff_stop_status := 'OP';
              END IF;
            END LOOP;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'========================================');
              WSH_DEBUG_SV.logmsg(l_module_name,'Calling Assign Delivery to Trip API');
              WSH_DEBUG_SV.logmsg(l_module_name,'Delivery id:'||l_dleg_local_tab(assign_count).delivery_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Trip id:'||l_del_action_prms.trip_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'---------Pickup Stop information----------');
              WSH_DEBUG_SV.logmsg(l_module_name,'Pickup Stop id:'||l_del_action_prms.pickup_stop_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Pickup Stop Location id:'||l_del_action_prms.pickup_loc_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Pickup Stop Sequence:'||l_del_action_prms.pickup_stop_seq);
              WSH_DEBUG_SV.logmsg(l_module_name,'Pickup Pl Arr Date:'||l_del_action_prms.pickup_arr_date);
              WSH_DEBUG_SV.logmsg(l_module_name,'Pickup Pl Dep Date:'||l_del_action_prms.pickup_dep_date);
              WSH_DEBUG_SV.logmsg(l_module_name,'---------Dropoff Stop information----------');
              WSH_DEBUG_SV.logmsg(l_module_name,'Dropoff Stop id:'||l_del_action_prms.dropoff_stop_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Dropoff Stop Location id:'||l_del_action_prms.dropoff_loc_id);
              WSH_DEBUG_SV.logmsg(l_module_name,'Dropoff Stop Sequence:'||l_del_action_prms.dropoff_stop_seq);
              WSH_DEBUG_SV.logmsg(l_module_name,'Dropoff Pl Arr Date:'||l_del_action_prms.dropoff_arr_date);
              WSH_DEBUG_SV.logmsg(l_module_name,'Dropoff Pl Dep Date:'||l_del_action_prms.dropoff_dep_date);
              WSH_DEBUG_SV.logmsg(l_module_name,'========================================');
            END IF;

            WSH_DELIVERIES_GRP.delivery_action(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_TRUE,
            p_commit             => FND_API.G_FALSE,
            p_action_prms        => l_del_action_prms,
            p_rec_attr_tab       => l_del_attrs,
            x_delivery_out_rec   => l_del_action_rec,
            x_defaults_rec       => l_del_defaults,
            x_return_status      => l_rs,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Assign Delivery to Trip'||l_rs);
            END IF;

            IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Assign Delivery to Trip Failed: l_return_status', l_return_status);
              END IF;
              GOTO trip_error;
            ELSIF l_rs = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              l_dleg_local_tab(assign_count).processed_flag := 'Y';
              l_dlvy_id_tab(l_dlvy_id_tab.count + 1) := l_dleg_local_tab(assign_count).delivery_id;
              l_dlvy_version_tab(l_dlvy_id_tab.count) := l_dleg_local_tab(assign_count).tms_version_number;
            END IF;

          END IF;--}
        END LOOP;--}
      END IF;--}

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Deliveries successfully assigned to trip:'||l_dlvy_id_tab.count);
        WSH_DEBUG_SV.logmsg(l_module_name,'Unassign Delivery Count:'||l_unassigned_delivery_id_tab.count);
      END IF;

      -- Make sure the successfully assigned deliveries are removed from
      -- l_unassigned_delivery_id_tab.
      l_del_index.DELETE;
      IF l_dlvy_id_tab.count > 0 AND l_unassigned_delivery_id_tab.count > 0 THEN--{
        FOR assign_count IN l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
        LOOP--{
          FOR unassign_count IN l_unassigned_delivery_id_tab.FIRST..l_unassigned_delivery_id_tab.LAST
          LOOP
            IF l_unassigned_delivery_id_tab(unassign_count) = l_dlvy_id_tab(assign_count) THEN
              --Index of record to be removed from Unassign Table
              l_del_index(l_del_index.count + 1) := unassign_count;
            END IF;
          END LOOP;
        END LOOP;--}

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Unassign Dlvy Index Count:'||l_del_index.count);
        END IF;

        -- Actual Deletion from the Unassign Delivery Table
        IF l_del_index.count > 0 THEN
          FOR i_del IN l_del_index.FIRST..l_del_index.LAST
          LOOP
            l_unassigned_delivery_id_tab.DELETE(l_del_index(i_del));
            l_unassigned_dlvy_version_tab.DELETE(l_del_index(i_del));
          END LOOP;
        END IF;
      END IF; --}

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'After compare, Unassign Dlvy Count:'||l_unassigned_delivery_id_tab.count);
        WSH_DEBUG_SV.logmsg(l_module_name,'After compare, Unassign Version Count:'||l_unassigned_dlvy_version_tab.count);
      END IF;

    END;--} -- process delivery

    -- OTM R12
    -- 4f.  Calculate wt/vol for the trip (includes stops) (call Group API)
    -- This step is no longer required as trip weight is calculated in previous step itself
    -- OTM R12

    -- 4g. Process Freight Costs for each delivery
    -- Still within the loop of l_trip_info_tab, so trip_interface_id is known
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      WSH_DEBUG_SV.logmsg(l_module_name,'4g. PROCESS FREIGHT COSTS');
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    END IF;

    DECLARE
      -- Delivery id in wsh_freight_costs_interface would be populated
      -- while importing information from Glog

      -- variables
      l_freight_info_tab WSH_FREIGHT_COSTS_GRP.freight_rec_tab_type;
      l_in_rec           WSH_FREIGHT_COSTS_GRP.freightInRecType;
      l_out_tab          WSH_FREIGHT_COSTS_GRP.freight_out_tab_type;
      l_rs               VARCHAR2(1);
      l_msg_count        NUMBER;
      l_msg_data         VARCHAR2(32767);

      l_carrier_cur_code VARCHAR2(15) := NULL;
      l_carrier_id       NUMBER := NULL;
      l_count            NUMBER := 0;
      l_frcost_type_id   NUMBER := NULL;
      l_dleg_id_tab      WSH_UTIL_CORE.id_tab_type; -- for deleting Dleg freight cost
      l_index            NUMBER;
      --l_conversion_type_code VARCHAR2(30);   -- OTM R12
      l_conversion_type_code FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE := NULL;   -- OTM R12

    BEGIN--{
      -- For successfully processed deliveries Only
      -- The deliveries are marked successful after process delivery section
      -- PROVIDE THE INPUT OF DELIVERY IDS !!!!! l_dlvy_id_tab
      IF l_dlvy_id_tab.count > 0 THEN

        IF l_frcost_type_id IS NULL THEN
          -- Seed Data, expected to be always populated
          OPEN c_get_frcost_type_id('OTM Freight Cost','FREIGHT'); -- OTM R12
          FETCH c_get_frcost_type_id
           INTO l_frcost_type_id;
          CLOSE c_get_frcost_type_id;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Freight Cost Type Id:'||l_frcost_type_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Count of Delivery Id:'||l_dlvy_id_tab.count);
          END IF;
        END IF;

        -- NEED TO DELETE THE EXISTING FREIGHT COST RECORDS FOR THE DELIVERY FOR THIS TYPE
        -- and then Insert new records
        l_dleg_id_tab.DELETE;
        FOR l_index in l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
        LOOP--{
          -- get all legs
          FOR rec in c_get_dleg_id(l_dlvy_id_tab(l_index))
          LOOP
            l_dleg_id_tab(l_dleg_id_tab.count + 1) := rec.delivery_leg_id;
          END LOOP;
        END LOOP;--}

        -- Records for Delivery Legs
        FORALL k in l_dleg_id_tab.FIRST..l_dleg_id_tab.LAST
          DELETE FROM wsh_freight_costs
           WHERE delivery_id = l_dleg_id_tab(k)
             AND freight_cost_type_id = l_frcost_type_id;

        -- Records for Delivery
        FORALL j in l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
          DELETE FROM wsh_freight_costs
           WHERE delivery_id = l_dlvy_id_tab(j)
             AND freight_cost_type_id = l_frcost_type_id;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'After Deleting Freight Cost Records:');
        END IF;

        FOR p in l_dlvy_id_tab.FIRST..l_dlvy_id_tab.LAST
        LOOP--{
          -- There can be multiple freight cost records for each delivery
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,'Different Delivery id:',l_dlvy_id_tab(p));
          END IF;

          FOR rec in c_freight_int_cur(l_dlvy_id_tab(p))
          LOOP--{
            -- Single record is being created, so always use 1
            l_count := 1;
            --l_count := l_count + 1;

            -- OTM R12 l_frcost_type_id IS NULL will never happen as this cursor already used above

            l_freight_info_tab(l_count).freight_cost_type_id :=  l_frcost_type_id; --rec.freight_cost_type_id;
            --l_freight_info_tab(l_count).freight_cost_type  :=  rec.freight_cost_type_code;
            l_freight_info_tab(l_count).unit_amount          :=  rec.unit_amount;
            l_freight_info_tab(l_count).uom                  :=  rec.uom;
            l_freight_info_tab(l_count).total_amount         :=  rec.total_amount;
            l_freight_info_tab(l_count).currency_code        :=  rec.currency_code;
            l_freight_info_tab(l_count).delivery_id          :=  rec.delivery_id;

            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name,'Delivery id:',l_freight_info_tab(l_count).delivery_id);
              WSH_DEBUG_SV.log(l_module_name,'Unit Amount:',l_freight_info_tab(l_count).Unit_amount);
              WSH_DEBUG_SV.log(l_module_name,'Total Amount:',l_freight_info_tab(l_count).Total_amount);
              WSH_DEBUG_SV.log(l_module_name,'Currency Code:',l_freight_info_tab(l_count).currency_code);
            END IF;

            -- OTM R12, start of Bug 5952842(5729276)
            IF l_conversion_type_code IS NULL THEN--{
              WSH_UTIL_CORE.get_currency_conversion_type(
                        x_curr_conv_type => l_conversion_type_code,
                        x_return_status  => l_rs);

              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'get_currency_conversion_type Failed');
                END IF;
                GOTO trip_error;
              END IF;

            END IF;--}

            -- OTM R12
            l_freight_info_tab(l_count).conversion_type_code := l_conversion_type_code;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Conversion Type: '||l_freight_info_tab(l_count).conversion_type_code);
            END IF;
            -- OTM R12, end of Bug 5952842(5729276)

            -- OTM R12 Only if freight cost record has currency
            IF l_freight_info_tab(l_count).currency_code IS NOT NULL AND
               l_freight_info_tab(l_count).unit_amount IS NOT NULL THEN
            --{

            -- OTM R12 11510 code was opening this cursor for every delivery
             IF l_carrier_id IS NULL THEN

               OPEN c_get_currency_code(l_trip_info_tab(i).trip_interface_id);
               FETCH c_get_currency_code INTO l_carrier_cur_code,l_carrier_id;

               IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Carrier Currency Code:'||l_carrier_cur_code);
                 WSH_DEBUG_SV.logmsg(l_module_name, 'Carrier id:'||l_carrier_id);
               END IF;

               -- OTM R12 check if carrier has a non-null currency
               IF c_get_currency_code%NOTFOUND THEN
                       l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                       IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name, 'Carrier not found ');
                       END IF;
                       FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_ID_NOT_FOUND');
                       WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                       CLOSE c_get_currency_code;
                       GOTO trip_error;
               ELSE
                       WSH_UTIL_VALIDATE.Validate_Carrier(
                               p_carrier_name  => NULL,
                               x_carrier_id    => l_carrier_id,
                               x_return_status => l_rs);

                       IF l_debug_on THEN
                               WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_UTIL_VALIDATE.Validate_Carrier:',l_rs);
                       END IF;

                       IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                               IF l_debug_on THEN
                                 WSH_DEBUG_SV.log(l_module_name, 'Validate Carrier Failed: l_return_status', l_return_status);
                               END IF;
                               CLOSE c_get_currency_code;
                               GOTO trip_error;
                       END IF;
               END IF;
               CLOSE c_get_currency_code;

               IF l_carrier_cur_code IS NULL THEN
                       l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                       IF l_debug_on THEN
                         WSH_DEBUG_SV.log(l_module_name, 'Carrier Currency not defined ');
                       END IF;
                       FND_MESSAGE.SET_NAME('WSH','WSH_CARRIER_NO_CURRENCY');
                       WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                       GOTO trip_error;
               END IF;

               -- OTM R12 check if carrier has a non-null currency
             END IF;

            -- Per ECO 5008405, Validate GC3 sent currency
            -- Need to adjust precision, dependent on WSHUTVLB new parameter
             IF ( l_freight_info_tab(l_count).currency_code <> fnd_api.g_miss_char ) THEN--{
               WSH_UTIL_VALIDATE.Validate_Currency(
                p_currency_code => l_freight_info_tab(l_count).currency_code,
                p_currency_name => NULL,
                p_amount        => l_freight_info_tab(l_count).unit_amount,
                p_otm_enabled   => 'Y', -- OTM R12
                x_return_status => l_rs,
                x_adjusted_amount => l_freight_info_tab(l_count).unit_amount); -- OTM R12

               IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name,'Return Status from WSH_UTIL_VALIDATE.Validate_Currency:',l_rs);
               END IF;
               -- Handle error here !!!
               -- ECO 5008405 handle here !!!
               IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'Validate Currency Failed: l_return_status', l_return_status);
                END IF;
                GOTO trip_error;
               ELSE -- OTM R12
                IF l_debug_on THEN
                  WSH_DEBUG_SV.log(l_module_name, 'Validate Currency result: x_adjusted_amount : ', l_freight_info_tab(l_count).unit_amount);
                END IF;
               END IF;
             END IF;--}


             -- OTM R12 old code would have inserted currency even if carrier's currency was null
             -- This was not correct
             -- COMPARE carrier currency UOM with GC3 Currency UOM. If different, then
             -- Convert the Amount to carrier UOM
             -- else use the amount specified in the interface table directly.

             --IF (l_carrier_cur_code IS NOT NULL) AND
             --   (l_freight_info_tab(l_count).currency_code IS NOT NULL) AND

             IF (l_carrier_cur_code <> l_freight_info_tab(l_count).currency_code) THEN--{

               -- Logic to populate l_conversion_type_code is moved above
               -- Issue raised in Bug 5952842 (5729276)

              -- OTM R12 Why was 11510 using total_amount here
              -- validated unit_amount above

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Calling GL_CURRENCY_API.convert_uom:');
                WSH_DEBUG_SV.logmsg(l_module_name, 'Currency Code:'||l_freight_info_tab(l_count).currency_code);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Conversion Type: '||l_freight_info_tab(l_count).conversion_type_code);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Carrier Currency Code:'||l_carrier_cur_code);
                -- OTM R12 print unit here as total is not being used
                --WSH_DEBUG_SV.logmsg(l_module_name, 'Freight Cost Amount:'||l_freight_info_tab(l_count).total_amount);
                WSH_DEBUG_SV.logmsg(l_module_name, 'Freight Cost Amount:'||l_freight_info_tab(l_count).unit_amount);
              END IF;

              -- Convert API should be called only when the carrier has been validated above
              DECLARE

                gl_currency_excp      EXCEPTION;

                -- Bug 5886042
                -- currency conversion_type in the error message should be
                -- user_conversion_type

                l_user_conv_type           VARCHAR2(30) := NULL;

                CURSOR c_get_user_conv_type(p_curr_conv_type varchar2) IS
                  SELECT user_conversion_type
                    FROM gl_daily_conversion_types
                   WHERE conversion_type = p_curr_conv_type;
                --
                -- end of Bug 5886042

              BEGIN--{
                -- Convert Amount from GC3 currency code to carrier currency code
                -- OTM R12 Why using total_amount here

                -- OTM R12 use positional style
                l_freight_info_tab(l_count).total_amount
                  := GL_CURRENCY_API.convert_amount(
                        x_from_currency   =>  l_freight_info_tab(l_count).currency_code,
                        x_to_currency     =>  l_carrier_cur_code,
                        x_conversion_date =>  SYSDATE,
                        x_conversion_type =>  l_freight_info_tab(l_count).conversion_type_code,
                        x_amount          =>  l_freight_info_tab(l_count).unit_amount);

                  IF l_freight_info_tab(l_count).total_amount IS NULL THEN
                     RAISE gl_currency_excp;
                  END IF;
                -- OTM R12 use positional style

              EXCEPTION
                -- OTM R12 Start
                WHEN gl_currency_api.no_rate THEN
                  -- Bug 5886042
                  -- currency conversion_type in the error message should be
                  -- user_conversion_type
                  BEGIN
                    OPEN c_get_user_conv_type(l_conversion_type_code);
                    FETCH c_get_user_conv_type INTO l_user_conv_type;
                    CLOSE c_get_user_conv_type;
                  EXCEPTION
                    WHEN OTHERS THEN
                      l_user_conv_type := l_conversion_type_code;
                      IF c_get_user_conv_type%ISOPEN THEN
                        CLOSE c_get_user_conv_type;
                      END IF;

                      IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred while getting the user currency conversion type');
                        WSH_DEBUG_SV.log(l_module_name, 'l_currency_conversion_type', l_conversion_type_code);
                      END IF;
                  END;
                  -- end of changes for Bug 5886042

                  FND_MESSAGE.SET_NAME('WSH','WSH_CURR_CONV_ERROR');
                  FND_MESSAGE.SET_TOKEN('FROM_CURR',l_freight_info_tab(l_count).currency_code);
                  FND_MESSAGE.SET_TOKEN('TO_CURR',l_carrier_cur_code);
                  FND_MESSAGE.SET_TOKEN('CONV_TYPE',l_user_conv_type);-- Bug 5886042
                  WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                  l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'GL_CURRENCY_API.CONVERT_AMOUNT'
                                    ||' failed no_rate', l_return_status);
                  END IF;
                  GOTO trip_error;
                WHEN gl_currency_api.invalid_currency THEN
                  -- Bug 5886042
                  -- currency conversion_type in the error message should be
                  -- user_conversion_type
                  BEGIN
                    OPEN c_get_user_conv_type(l_conversion_type_code);
                    FETCH c_get_user_conv_type INTO l_user_conv_type;
                    CLOSE c_get_user_conv_type;
                  EXCEPTION
                    WHEN OTHERS THEN
                      l_user_conv_type := l_conversion_type_code;
                      IF c_get_user_conv_type%ISOPEN THEN
                        CLOSE c_get_user_conv_type;
                      END IF;

                      IF l_debug_on THEN
                        WSH_DEBUG_SV.logmsg(l_module_name, 'Error occurred while getting the user currency conversion type');
                        WSH_DEBUG_SV.log(l_module_name, 'l_currency_conversion_type', l_conversion_type_code);
                      END IF;
                  END;
                  -- end of changes for Bug 5886042

                  FND_MESSAGE.SET_NAME('WSH','WSH_CURR_CONV_ERROR');
                  FND_MESSAGE.SET_TOKEN('FROM_CURR',l_freight_info_tab(l_count).currency_code);
                  FND_MESSAGE.SET_TOKEN('TO_CURR',l_carrier_cur_code);
                  FND_MESSAGE.SET_TOKEN('CONV_TYPE',l_user_conv_type);-- Bug 5886042
                  WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                  l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'GL_CURRENCY_API.CONVERT_AMOUNT'
                                    ||' failed invalid_currency', l_return_status);
                  END IF;
                  GOTO trip_error;

                -- OTM R12 end
                WHEN gl_currency_excp THEN
                  l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'GL_CURRENCY_API.CONVERT_AMOUNT returned NULL :', l_return_status);
                  END IF;
                  GOTO trip_error;

                WHEN OTHERS THEN
                  l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                  IF l_debug_on THEN
                    WSH_DEBUG_SV.log(l_module_name, 'GL_CURRENCY_API.CONVERT_AMOUNT failed:', l_return_status);
                  END IF;
                  GOTO trip_error;
              END;--}

              l_freight_info_tab(l_count).currency_code := l_carrier_cur_code;
              l_freight_info_tab(l_count).unit_amount   := l_freight_info_tab(l_count).total_amount;

              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name, 'Converted Amount:'||l_freight_info_tab(l_count).total_amount);
                WSH_DEBUG_SV.logmsg(l_module_name, 'New Currency Code:'||l_freight_info_tab(l_count).currency_code);
              END IF;

             END IF;--}

             --
             -- Call Create_Update_freight_cost here, for each record
             -- The API was not accepting 2 freight cost records for same delivery_id
             -- Need to look into this later!!!
             -- l_freight_info_tab.count will be > 0

             l_in_rec.action_code := 'CREATE';
             l_in_rec.caller      := 'FTE_TMS_INTEGRATION'; --'FTE_TMS_RELEASE';

             IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Calling WSH_FREIGHT_COSTS_GRP.Create_Update_Freight_Costs');
             END IF;

             WSH_FREIGHT_COSTS_GRP.Create_Update_Freight_Costs
              (p_api_version_number =>  1.0,
               p_init_msg_list      =>  FND_API.G_TRUE,
               p_commit             =>  FND_API.G_FALSE,
               p_freight_info_tab   =>  l_freight_info_tab,
               p_in_rec             =>  l_in_rec,
               x_out_tab            =>  l_out_tab,
               x_return_status      =>  l_rs,
               x_msg_count          =>  l_msg_count,
               x_msg_data           =>  l_msg_data);

             IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Return Status after Create Freight Cost:'||l_rs);
             END IF;

             IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
              l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
              IF l_debug_on THEN
                WSH_DEBUG_SV.log(l_module_name, 'Create_Update_Freight_Costs Failed: l_return_status', l_return_status);
              END IF;
              EXIT; -- need to exit out of the parent loop also!!!
              -- OTM R12 will never reach this GOTO and GOTO not required as the immediate next section is trip_error
              --GOTO trip_error;
             END IF;
             -- end of call to create_update_freight API

           END IF;--}-- only if freight cost record has currency

          END LOOP;--}-- loop across freight_costs_interface table
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN
            EXIT; -- need to exit out of the parent loop also!!!
            -- OTM R12 will never reach this GOTO and GOTO not required as the immediate next section is trip_error
            --GOTO trip_error;
          END IF;
        END LOOP;--} -- loop across successful deliveries
      END IF;


      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Freight Info Table Count:'||l_freight_info_tab.count);
      END IF;
    END; --}

    -- OTM Dock Door App Sched Proj
    -- 4h. Stamping the Loading Sequence Number for OTM enabled WMS organization
    DECLARE
    CURSOR c_stops (c_trip_id IN number) IS
    SELECT wts.stop_id stop_id
    FROM   wsh_trips wt,
           wsh_trip_stops wts
    WHERE  wt.trip_id = c_trip_id
    AND    wt.trip_id = wts.trip_id
    ORDER  BY wts.stop_sequence_number DESC;

    CURSOR c_lock_deliveries_and_details (c_drop_off_stop_id IN number) IS
    SELECT wnd.delivery_id, wdd.delivery_detail_id
    FROM   wsh_new_deliveries wnd,
           wsh_delivery_legs wdl,
           wsh_delivery_assignments wda, wsh_delivery_details wdd
    WHERE  wdl.drop_off_stop_id = c_drop_off_stop_id
    AND    wdl.delivery_id = wnd.delivery_id
    AND    WSH_UTIL_VALIDATE.CHECK_WMS_ORG(wnd.organization_id) = 'Y'
    AND    wnd.delivery_id = wda.delivery_id
    AND    wda.delivery_detail_id = wdd.delivery_detail_id
    FOR UPDATE OF wnd.loading_sequence, wdd.load_seq_number NOWAIT;

    l_del_tab             WSH_UTIL_CORE.ID_TAB_TYPE;
    l_del_det_tab         WSH_UTIL_CORE.ID_TAB_TYPE;
    l_loading_sequence    NUMBER := 0;
    l_stop_id_rec         NUMBER;

    BEGIN
      FOR crec in c_stops(l_trip_id) LOOP
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Locking Deliveries and Details for stop '||crec.stop_id);
        END IF;

	l_stop_id_rec := crec.stop_id;
        l_loading_sequence := l_loading_sequence + 10;
	l_del_tab.DELETE;
	l_del_det_tab.DELETE;

	OPEN  c_lock_deliveries_and_details (crec.stop_id);
        FETCH c_lock_deliveries_and_details BULK COLLECT INTO l_del_tab, l_del_det_tab;

        IF l_del_tab.COUNT > 0 THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Updating Deliveries and Details With Loading Sequence '||l_loading_sequence);
          END IF;

          FORALL i in l_del_tab.FIRST..l_del_tab.LAST
            UPDATE wsh_new_deliveries
            SET    loading_sequence = l_loading_sequence,
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
            WHERE  delivery_id = l_del_tab(i);

          FORALL i in l_del_det_tab.FIRST..l_del_det_tab.LAST
            UPDATE wsh_delivery_details
            SET    load_seq_number = l_loading_sequence,
                   last_update_date   = SYSDATE,
                   last_updated_by    = FND_GLOBAL.USER_ID,
                   last_update_login  = FND_GLOBAL.LOGIN_ID
            WHERE  delivery_detail_id = l_del_det_tab(i);
	END IF;

        CLOSE c_lock_deliveries_and_details;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF c_lock_deliveries_and_details%ISOPEN then
          CLOSE c_lock_deliveries_and_details;
        END IF;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Unable to lock Deliveries/Details for drop off stop '||l_stop_id_rec);
          WSH_DEBUG_SV.log(l_module_name, 'l_return_status', l_return_status);
        END IF;
        GOTO trip_error;
    END;

    -- 4i. Calling the WMS API
    DECLARE
    l_rs                  VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(32767);
    l_message             VARCHAR2(2000);
    BEGIN
      IF (l_dock_appt_tab.COUNT > 0) THEN --{
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Calling wms_dock_appointments_pub.OTM_Dock_Appointment',WSH_DEBUG_SV.C_PROC_LEVEL);
	END IF;
	-- Calling the WMS API with the Dock Door App Sched Info.
        wms_dock_appointments_pub.OTM_Dock_Appointment(p_dock_appt_tab => l_dock_appt_tab,
                                                       x_return_status => l_rs,
                                                       x_msg_count => l_msg_count,
                                                       x_msg_data => l_msg_data);
        IF l_debug_on THEN
	  WSH_DEBUG_SV.log(l_module_name, 'wms_dock_appointments_pub.OTM_Dock_Appointment: Return Status', l_rs);
	END IF;
        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FOR l_err_msg IN 1..l_msg_count LOOP
            l_message := fnd_msg_pub.get(l_err_msg,'F');
	    l_message := replace(l_message,chr(0),' ');
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'ERROR: '|| l_message);
            END IF;
          END LOOP;
	  fnd_msg_pub.delete_msg();
	  FND_MESSAGE.SET_NAME('WSH','WSH_DOCK_SCHED_ERROR');
          WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
          GOTO trip_error;
        END IF;
      END IF; --} l_dock_appt_tab.COUNT > 0
    EXCEPTION
      WHEN OTHERS THEN
        l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Error while calling wms_dock_appointments_pub.OTM_Dock_Appointment' || SQLERRM);
	END IF;
        GOTO trip_error;
    END;
    --

    -- For each trip interface
    <<trip_error>>

    -- 4j. Final Step : error logging, cleaning up interface table
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
      WSH_DEBUG_SV.logmsg(l_module_name,'4h. DATA CLEANUP FOR THE TRIP');
      WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    END IF;

    DECLARE
      l_rs                 VARCHAR2(1);
      l_msg_count          NUMBER;
      l_msg_data           VARCHAR2(32767);
      l_exception_id       NUMBER;
      l_exception_message  VARCHAR2(2000);
      l_exception_name     VARCHAR2(30);
      l_count              NUMBER;

    BEGIN--{

      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Status here:'||l_return_status );
      END IF;

      -- Based on errors for each trip
      -- Status of T is for special case of Invalid Location for Trip Stop
      -- For Invalid Location error, donot insert records in error table,
      -- Only Log Delivery Level Error exceptions and purge the data from
      -- Interface tables
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,'T') THEN --{
      --IF l_errors_tab.count > 0 THEN
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Rollback.....' );
        END IF;

        ROLLBACK TO process_single_trip;

        l_error_trips := l_error_trips + 1;
        -- Set completion status to Warning, no concept of error
        -- so no need to count and conditionally set error/warning
        l_completion_status := 'WARNING';

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Set Completion to WARNING');
          WSH_DEBUG_SV.logmsg(l_module_name,'Before Inserting in Interface error,count:'||l_dleg_local_tab.count );
        END IF;

        IF l_return_status = 'T' THEN--{
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'Before Purging the Interface Data' );
          END IF;

          -- Need to purge the data in interface tables for invalid stop location
          -- Also, clean up existing Freight cost and Exceptions in EBS
          purge_interface_data(
            p_tp_plan_name       => NULL,
            p_trip_interface_id  => l_trip_info_tab(i).trip_interface_id,
            p_commit_flag        => 'N',
            p_exception_action   => 'PURGE',
            x_return_status      => l_rs);

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name,'After Purging the Interface Data:'||l_rs );
          END IF;

          -- OTM R12
          IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'purge_interface_data Failed');
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- OTM R12

        END IF;--}

        -- For Delete Shipment Cases, there will not be any delivery level information
        IF l_dleg_local_tab.count > 0 THEN--{
          IF l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR THEN--{

            -- Insert record in wsh_interface_errors table
            -- Generic error message is to be logged against all deliveries
            -- Handled in stamp_interface_errors
            stamp_interface_error(
              p_group_id            => l_trip_info_tab(i).group_id, --Bug7717569 replaced p_group_id with l_trip_info_tab(i).group_id
              p_entity_table_name   => 'WSH_NEW_DELIVERIES_INTERFACE',
              p_entity_interface_id => l_trip_info_tab(i).trip_interface_id,
              p_message_name        => 'WSH_OTM_GENERIC', -- NEW MESSAGE !!!
              p_dleg_tab            => l_dleg_local_tab,
              x_errors_tab          => l_errors_tab,
              x_return_status       => l_rs);

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Stamp_Interface_error'||l_rs);
            END IF;

            -- OTM R12
            IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'stamp_interface_error Failed');
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- OTM R12

          END IF;--} -- l_return_status = E

          IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name,'Now Logging Error Exceptions' );
          END IF;

          -- Log error level exception for all deliveries, use l_dleg_local_tab
          -- to find deliveries which are on this trip
          IF l_return_status = 'T' THEN
            l_exception_name := 'WSH_OTM_INVALID_LOC'; -- Need new exception here
            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_INVALID_LOC');
          ELSE
            l_exception_name := 'WSH_OTM_SHIPMENT_ERROR';
            FND_MESSAGE.SET_NAME('WSH', 'WSH_OTM_DELIVERY_FAIL');
          END IF;

          l_exception_message := FND_MESSAGE.Get;

          FOR rec IN l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
          LOOP--{
            IF l_dleg_local_tab(rec).trip_interface_id = l_trip_info_tab(i).trip_interface_id THEN
              l_exception_id := NULL;  -- need to initialize for each exception

              WSH_XC_UTIL.log_exception(
                  p_api_version           => 1.0,
                  x_return_status         => l_rs,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  x_exception_id          => l_exception_id,
                  p_exception_location_id => l_dleg_local_tab(rec).initial_pickup_location_id,
                  p_logged_at_location_id => l_dleg_local_tab(rec).initial_pickup_location_id,
                  p_logging_entity        => 'SHIPPER',
                  p_logging_entity_id     => FND_GLOBAL.USER_ID,
                  p_exception_name        => l_exception_name, -- 'WSH_OTM_SHIPMENT_ERROR',
                  p_message               => substrb(l_exception_message,1,2000),
                  p_delivery_id           => l_dleg_local_tab(rec).delivery_id);
              IF l_debug_on THEN
                WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Log_exception'||l_rs);
              END IF;

              -- OTM R12
              IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'WSH_XC_UTIL.log_exception Failed');
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              -- OTM R12

            END IF;
          END LOOP; --}
        END IF;--} --l_dleg_local_tab.count > 0

      ELSE -- l_return_status <> 'E' --} --{

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Success; Now Setting Interface flag to ANSWER RECEIVED' );
        END IF;

        -- l_dlvy_id_tab only has successfully processed deliveries
        -- l_dlvy_id_tab was used in freight_costs section also, make sure it is
        -- still kept only for good deliveries!!!
        -- Do not update the tms_version_number, to accept multiple messages from
        -- GC3 for same version of the delivery
        -- TMS_VERSION_NUMBER gets updated due to the EBS code flow, need to set it back
        -- to the original value
        -- OTM R12 Use update_tms_interface_flag API

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Before Logging Information Only Exceptions' );
        END IF;

        -- All the records in l_dleg_local_tab should have been processed
        -- Count should be identical in l_dleg_local_tab and l_dlvy_id_tab
        IF l_dleg_local_tab.COUNT > 0 THEN
          FOR rec IN l_dleg_local_tab.FIRST..l_dleg_local_tab.LAST
          LOOP--{
            IF l_dleg_local_tab(rec).trip_interface_id = l_trip_info_tab(i).trip_interface_id THEN


              -- Bug#7491598(ER,defer planned shipment iface): Closing of exceptions should be done only
              -- when EBS delivery tms version number is less than or equal to tms version number from OTM
              IF l_dleg_local_tab(rec).tms_version_number <=  l_dleg_local_tab(rec).otm_tms_version_number  THEN
              --{
                  --
                  -- ECO 5171627 Close the previous AWAIT Trip exception
                  -- OTM R12
                  WSH_XC_UTIL.Purge (
                      p_api_version       => 1.0,
                      x_return_status     => l_rs,
                      x_msg_count         => l_msg_count,
                      x_msg_data          => l_msg_data,
                      x_no_of_recs_purged => l_count,
                      p_exception_name    => 'WSH_OTM_DEL_AWAIT_TRIP',
                      p_delivery_id       => l_dleg_local_tab(rec).delivery_id,
                      p_delivery_contents => 'N',
                      p_action            => 'CLOSED'
                      );

                  IF l_debug_on THEN
                      WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after WSH_XC_UTIL.Purge' || l_rs);
                  END IF;
                  -- OTM R12
                  IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                      l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                      IF l_debug_on THEN
                          WSH_DEBUG_SV.log(l_module_name, 'WSH_XC_UTIL.Purge Failed');
                      END IF;
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  -- OTM R12 populate record structure to call update_tms_interface_flag
                  l_upd_dlvy_id_tab(l_upd_dlvy_id_tab.COUNT + 1)   := l_dleg_local_tab(rec).delivery_id;
                  l_upd_dlvy_tms_tab(l_upd_dlvy_tms_tab.COUNT + 1) := WSH_NEW_DELIVERIES_PVT.C_TMS_ANSWER_RECEIVED;
                  -- OTM R12
              ELSE
                  l_upd_dlvy_id_tab(l_upd_dlvy_id_tab.COUNT + 1)   := l_dleg_local_tab(rec).delivery_id;
                  l_upd_dlvy_tms_tab(l_upd_dlvy_tms_tab.COUNT + 1) := l_dleg_local_tab(rec).tms_interface_flag;  --update to the old status.
              --}
              END IF;
              -- -- Bug#7491598(ER,defer planned shipment iface):end
            END IF;

          END LOOP; --}

        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Before Purging the Interface Data' );
        END IF;

        -- Need to purge the data in interface tables after successful processing
        -- p_exception_action is 'CLOSE' to close specific exceptions logged for the
        -- deliveries
        purge_interface_data(
          p_tp_plan_name       => NULL,
          p_trip_interface_id  => l_trip_info_tab(i).trip_interface_id,
          p_commit_flag        => 'N',
          p_exception_action   => 'CLOSE', --'PURGE' is called by Arindam
          x_return_status      => l_rs);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'After Purging the Interface Data:'||l_rs );
        END IF;

        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'purge_interface_data Failed');
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_success_trips := l_success_trips + 1;

      END IF;--} -- l_return_status <> 'E'
    END;--} -- end of data cleanup
    -- For each trip, delete the messages on stack
    fnd_msg_pub.delete_msg();
  END LOOP; --} for each trip in l_trip_info_tab
  END IF; --}l_trip_info_tab.count > 0
  --=======================================================================

  -- 5. Final Step : error logging, cleaning up interface table
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    WSH_DEBUG_SV.logmsg(l_module_name,'5. UNASSIGN DELIVERIES FROM TRIP');
    WSH_DEBUG_SV.logmsg(l_module_name,'===============================');
    WSH_DEBUG_SV.logmsg(l_module_name,'Deliveries to be Unassigned :'||l_unassigned_delivery_id_tab.count);
    WSH_DEBUG_SV.logmsg(l_module_name,'Version of Deliveries to be Unassigned :'||l_unassigned_dlvy_version_tab.count);
  END IF;
  IF l_unassigned_delivery_id_tab.count > 0 THEN--{
    l_unassigned_del_index := l_unassigned_delivery_id_tab.FIRST;
    WHILE (l_unassigned_del_index IS NOT NULL )
    LOOP--{
      --glog proj, getting initial value of the delivery(ie. interface_flag)
      l_delivery_info_tab.DELETE;
      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'l_unassigned_delivery_id_tab('||l_unassigned_del_index||')='||
                                         l_unassigned_delivery_id_tab(l_unassigned_del_index));

        WSH_DEBUG_SV.logmsg(l_module_name,'Calling program unit WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD',WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;

      WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD(p_delivery_id => l_unassigned_delivery_id_tab(l_unassigned_del_index),
                                             x_delivery_rec => l_delivery_info,
                                             x_return_status => l_return_status);

      -- OTM R12
      IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
                   --l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                   IF l_debug_on THEN
                     WSH_DEBUG_SV.log(l_module_name, 'WSH_NEW_DELIVERIES_PVT.TABLE_TO_RECORD Failed');
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       -- OTM R12


      l_delivery_info_tab(l_delivery_info_tab.COUNT+1) := l_delivery_info;

      IF WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_unassigned_delivery_id_tab(l_unassigned_del_index)) = 'N' THEN
        -- set the flag to AW
        l_new_interface_flag_tab(l_delivery_info_tab.count) := WSH_NEW_DELIVERIES_PVT.C_TMS_AWAITING_ANSWER;

      ELSIF WSH_NEW_DELIVERY_ACTIONS.IS_DELIVERY_EMPTY(l_unassigned_delivery_id_tab(l_unassigned_del_index)) = 'Y' THEN
        -- set the flag to NS
        l_new_interface_flag_tab(l_delivery_info_tab.count) := WSH_NEW_DELIVERIES_PVT.C_TMS_NOT_TO_BE_SENT;
      END IF;

      -- OTM R12 populate record structure to call update_tms_interface_flag
      l_upd_dlvy_id_tab(l_upd_dlvy_id_tab.COUNT + 1)   := l_unassigned_delivery_id_tab(l_unassigned_del_index);
      l_upd_dlvy_tms_tab(l_upd_dlvy_tms_tab.COUNT + 1) := l_new_interface_flag_tab(l_delivery_info_tab.count);
      -- OTM R12
      l_unassigned_del_index := l_unassigned_delivery_id_tab.NEXT(l_unassigned_del_index);

    END LOOP;--}

    IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Delivery Info Tab Count:'||l_delivery_info_tab.count);
      WSH_DEBUG_SV.log(l_module_name,'New Interface Flag Tab Count:'||l_new_interface_flag_tab.count);
    END IF;

  END IF; --}

  -- OTM R12 call update_tms_interface_flag here

  WSH_NEW_DELIVERIES_PVT.update_tms_interface_flag
               ( p_delivery_id_tab        => l_upd_dlvy_id_tab,
		 p_tms_interface_flag_tab => l_upd_dlvy_tms_tab,
		 x_return_status          => l_return_status);

  IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name, 'update_tms_interface_flag  : l_return_status : ', l_return_status);
  END IF;
  IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
     --l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
     ROLLBACK TO process_group;
     l_completion_status := 'WARNING';
     --l_completion_status := 'ERROR';
  ELSE

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Now Committing for the group....');
    END IF;

    COMMIT;

  END IF;
  -- OTM R12

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'======================================');
    WSH_DEBUG_SV.logmsg(l_module_name,'Completion Status'||l_completion_status);
    WSH_DEBUG_SV.logmsg(l_module_name,'Trip Error Count'||l_error_trips);
    WSH_DEBUG_SV.logmsg(l_module_name,'Trip Success Count'||l_success_trips);
    WSH_DEBUG_SV.logmsg(l_module_name,'======================================');
  END IF;

  IF l_completion_status = 'WARNING' THEN
    errbuf := 'Atleast one trip was not Interfaced';
    retcode := '1';
    l_ret_code := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
  ELSIF l_completion_status = 'NORMAL' THEN
    retcode := '0';
    l_ret_code := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
  -- OTM R12
/*
  ELSE -- Cannot come here
    errbuf := 'Exception occurred in Release_Planned_Shipment';
    retcode := '2';
    l_ret_code := FND_CONCURRENT.SET_COMPLETION_STATUS(l_completion_status,'');
*/
  -- OTM R12
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'ERRBUF',errbuf);
    WSH_DEBUG_SV.log(l_module_name,'RETCODE',retcode);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO process_group;
      --
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      --
      -- Always concurrent request,no online option
      l_ret_code := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
      errbuf := 'Exception occurred in Release_Planned_Shipment';
      retcode := '2';
      --
  WHEN OTHERS THEN
    -- OTM R12
    --ROLLBACK;
    ROLLBACK TO process_group;
    -- OTM R12
    IF c_tms_interface_trips%ISOPEN THEN
      CLOSE c_tms_interface_trips;
    END IF;
    IF c_tms_interface_stops%ISOPEN THEN
      CLOSE c_tms_interface_stops;
    END IF;
    IF c_tms_interface_dlegs%ISOPEN THEN
      CLOSE c_tms_interface_dlegs;
    END IF;
    IF c_tms_interface_trips_plan%ISOPEN THEN
      CLOSE c_tms_interface_trips_plan;
    END IF;
    IF c_tms_interface_trips_del%ISOPEN THEN
      CLOSE c_tms_interface_trips_del;
    END IF;
    IF c_tms_interface_trips_all%ISOPEN THEN
      CLOSE c_tms_interface_trips_all;
    END IF;
    IF c_tms_interface_stops_plan%ISOPEN THEN
      CLOSE c_tms_interface_stops_plan;
    END IF;
    IF c_tms_interface_stops_del%ISOPEN THEN
      CLOSE c_tms_interface_stops_del;
    END IF;
    IF c_tms_interface_stops_all%ISOPEN THEN
      CLOSE c_tms_interface_stops_all;
    END IF;

    IF c_tms_interface_dlegs_plan%ISOPEN THEN
      CLOSE c_tms_interface_dlegs_plan;
    END IF;
    IF c_tms_interface_dlegs_del%ISOPEN THEN
      CLOSE c_tms_interface_dlegs_del;
    END IF;
    IF c_tms_interface_dlegs_all%ISOPEN THEN
      CLOSE c_tms_interface_dlegs_all;
    END IF;
    IF c_lock_trip_interface%ISOPEN THEN
      CLOSE c_lock_trip_interface;
    END IF;
    IF c_get_stops%ISOPEN THEN
      CLOSE c_get_stops;
    END IF;
    IF c_get_deliveries%ISOPEN THEN
      CLOSE c_get_deliveries;
    END IF;
    IF c_get_dleg_id%ISOPEN THEN
      CLOSE c_get_dleg_id;
    END IF;
    IF c_freight_int_cur%ISOPEN THEN
      CLOSE c_freight_int_cur;
    END IF;
    IF c_get_currency_code%ISOPEN THEN
      CLOSE c_get_currency_code;
    END IF;
    --
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( 'WSH_TMS_RELEASE', 'Release_Planned_Shipment' );
    END IF;
    --
    -- Always concurrent request,no online option
    l_ret_code := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
    errbuf := 'Exception occurred in Release_Planned_Shipment';
    retcode := '2';
    --
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.RELEASE_PLANNED_SHIPMENT',
                        l_module_name);
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END release_planned_shipment;

--=========================================================================
-- Procedure: PURGE_INTERFACE_DATA
-- Description:
--   wsh_del_details_interface and wsh_del_assgn_interface will not be populated
--   Purge records in wsh_freight_costs_interface
--   If p_exception_action =PURGE, then purge the exceptions
--     for WSH_OTM_SHIPMENT_ERROR
--   elsif p_exception_action = CLOSE, then close the exception
--     for WSH_OTM_SHIPMENT_ERROR(used for reprocessing from Interface Mesg
--     Corrections Form)
--   Purge any records in wsh_interface_errors
--   Purge records in wsh_new_del_interface
--   Purge records in wsh_del_legs_interface
--   Purge records in wsh_trip_stops_interface
--   Purge records in wsh_trips_interface
--   Index exists on group_id and trip_interface_id of wsh_trips_interface,
--    so use trip_interface_id.
--
-- Usage:
-- 1. Inbound BPEL Process calls this API to purge data based on tp_plan_name
-- 2. Inbound Interface Code calls this to purge interface data and close
--    exceptions
-- Assumption: One of the two p_tp_plan_name or p_trip_interface_id will
-- be populated
--
--=========================================================================
PROCEDURE purge_interface_data(
  p_tp_plan_name           IN            VARCHAR2 DEFAULT NULL,
  p_trip_interface_id      IN            VARCHAR2 DEFAULT NULL,
  p_commit_flag            IN            VARCHAR2,
  p_exception_action       IN            VARCHAR2 DEFAULT 'PURGE',
  x_return_status             OUT NOCOPY VARCHAR2) IS

  CURSOR c_get_interface_id (p_tp_plan_name IN VARCHAR2) IS
  SELECT wti.trip_interface_id
    FROM wsh_trips_interface wti
   WHERE wti.tp_plan_name = p_tp_plan_name
     AND wti.interface_action_code = G_TMS_RELEASE_CODE;

  l_trip_interface_id     NUMBER;
  l_trip_interface_id_tab WSH_UTIL_CORE.id_tab_type;

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_INTERFACE_DATA';
  --
  l_debug_on BOOLEAN;
  --
BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Tp Plan Name:', p_tp_plan_name);
    WSH_DEBUG_SV.log(l_module_name,'Trip Interface Id:', p_trip_interface_id);
    WSH_DEBUG_SV.log(l_module_name,'p_commit_flag:', p_commit_flag);
    WSH_DEBUG_SV.log(l_module_name,'p_exception_action:', p_exception_action);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  SAVEPOINT BEFORE_PURGE;

  -- Derive the trip_interface_id
  IF p_trip_interface_id IS NULL THEN
    OPEN c_get_interface_id (p_tp_plan_name);
    FETCH c_get_interface_id BULK COLLECT
     INTO l_trip_interface_id_tab;
    CLOSE c_get_interface_id;
  ELSE
    l_trip_interface_id_tab(1) := p_trip_interface_id;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Count of Trip Interface Ids:', l_trip_interface_id_tab.count);
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Freight Costs Interface Data');
  END IF;

    IF l_trip_interface_id_tab.count > 0 THEN--{

      IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Trip Interface Id:', l_trip_interface_id_tab(l_trip_interface_id_tab.FIRST));
      END IF;

    -- Purge wsh_freight_cost_interface
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_freight_costs_interface wfci
     where wfci.delivery_interface_id in (
           select wdli.delivery_interface_id
             from wsh_trip_stops_interface wtsi,
                  wsh_del_legs_interface wdli
            where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
              and wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
              and wtsi.interface_action_code = G_TMS_RELEASE_CODE
              and wdli.interface_action_code = G_TMS_RELEASE_CODE)
       and wfci.interface_action_code = G_TMS_RELEASE_CODE;


    IF p_exception_action = 'PURGE' THEN--{
      -- Purge exceptions logged for the deliveries
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Exceptions');
      END IF;
      FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
      DELETE from WSH_EXCEPTIONS we
       WHERE we.delivery_id in (
             select wdli.delivery_id
              from  wsh_trip_stops_interface wtsi,
                        wsh_del_legs_interface wdli
             where  wtsi.trip_interface_id = l_trip_interface_id_tab(i)
               and  wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
               and  wtsi.interface_action_code = G_TMS_RELEASE_CODE
               and  wdli.interface_action_code = G_TMS_RELEASE_CODE)
         and we.status = 'OPEN'
         and we.exception_name IN ('WSH_OTM_SHIPMENT_ERROR','WSH_OTM_INVALID_LOC');

    ELSIF p_exception_action = 'CLOSE' THEN
      -- Close exceptions logged for the deliveries
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Start Closing Exceptions');
      END IF;
      FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
      UPDATE WSH_EXCEPTIONS we
         SET status = 'CLOSED'
       WHERE we.delivery_id in (
             select wdli.delivery_id
               from wsh_trip_stops_interface wtsi,
                    wsh_del_legs_interface wdli
              where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
                and wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
                and wtsi.interface_action_code = G_TMS_RELEASE_CODE
                and wdli.interface_action_code = G_TMS_RELEASE_CODE)
                and we.exception_name IN ('WSH_OTM_SHIPMENT_ERROR','WSH_OTM_INVALID_LOC')
                and we.status = 'OPEN';
    END IF;--}

    -- Purge wsh_interface_errors
    -- for each of the above entity, there could be errors logged in wsh_interface_errors
    -- table_name can be WSH_NEW_DEL_INTERFACE, WSH_TRIP_STOPS_INTERFACE,
    -- WSH_TRIPS_INTERFACE

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Interface Errors Data for delivery');
    END IF;
    -- Delete errors logged for deliveries
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_interface_errors wie
     where wie.interface_table_name = 'WSH_NEW_DEL_INTERFACE'
       and wie.interface_id in (
           select wdli.delivery_interface_id
             from wsh_trip_stops_interface wtsi,
                  wsh_del_legs_interface wdli
            where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
              and wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
              and wtsi.interface_action_code = G_TMS_RELEASE_CODE
              and wdli.interface_action_code = G_TMS_RELEASE_CODE)
       and wie.interface_action_code = G_TMS_RELEASE_CODE;

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Interface Errors Data for Trip Stops');
    END IF;
    -- Delete errors logged for trip stops
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_interface_errors wie
     where wie.interface_table_name = 'WSH_TRIP_STOPS_INTERFACE'
       and wie.interface_id in (
           select wtsi.stop_interface_id
            from wsh_trip_stops_interface wtsi
           where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
             and wtsi.interface_action_code = G_TMS_RELEASE_CODE)
       and wie.interface_action_code = G_TMS_RELEASE_CODE;

    -- Delete errors logged for trips
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Interface Errors Data for Trips');
    END IF;
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_interface_errors wie
     where wie.interface_table_name = 'WSH_TRIPS_INTERFACE'
       and wie.interface_id = l_trip_interface_id_tab(i)
       and wie.interface_action_code = G_TMS_RELEASE_CODE;

    -- Purge wsh_new_del_interface
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Deliveries Interface Data');
    END IF;
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_new_del_interface wndi
     where wndi.delivery_interface_id in (
           select wdli.delivery_interface_id
             from wsh_trip_stops_interface wtsi,
                  wsh_del_legs_interface wdli
            where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
              and wtsi.stop_interface_id = wdli.pick_up_stop_interface_id
              and wtsi.interface_action_code = G_TMS_RELEASE_CODE
              and wdli.interface_action_code = G_TMS_RELEASE_CODE)
       and wndi.interface_action_code = G_TMS_RELEASE_CODE;

    -- Purge wsh_del_legs_interface
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Delivery Legs Interface Data');
    END IF;
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_del_legs_interface wdli
     where wdli.pick_up_stop_interface_id in (
           select wtsi.stop_interface_id
             from wsh_trip_stops_interface wtsi
            where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
              and wtsi.interface_action_code = G_TMS_RELEASE_CODE)
       and    wdli.interface_action_code = G_TMS_RELEASE_CODE;

    -- Purge wsh_trip_stops_interface
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Trip Stops Interface Data');
    END IF;
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_trip_stops_interface wtsi
     where wtsi.trip_interface_id = l_trip_interface_id_tab(i)
       and wtsi.interface_action_code = G_TMS_RELEASE_CODE;

    -- Purge wsh_trips_interface
    -- (Trips have to be the last entity interface table purged
    --  because this is the only entity interface table having TP_PLAN_NAME.)
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Start Purging Trips Interface Data');
    END IF;
    FORALL i in l_trip_interface_id_tab.FIRST..l_trip_interface_id_tab.LAST
    Delete from wsh_trips_interface wti
     where wti.trip_interface_id = l_trip_interface_id_tab(i)
       and wti.INTERFACE_ACTION_CODE = G_TMS_RELEASE_CODE;

    END IF;--}

  IF p_commit_flag = 'Y' THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Committing....');
    END IF;
    commit;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_get_interface_id%ISOPEN THEN
      CLOSE c_get_interface_id;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    ROLLBACK to before_purge;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.PURGE_INTERFACE_DATA',
                        l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END purge_interface_data;

--====================================================
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
--               p_dleg_tab            Table of Delivery Leg information
--               x_errors_tab          list of errors to insert into wsh_interface_errors at the end
--               x_return_status       return status
--
--  Description:
--               Inserts the error information for each delivery
--
--
--====================================================
PROCEDURE stamp_interface_error(
            p_group_id            IN            NUMBER,
            p_entity_table_name   IN            VARCHAR2,
            p_entity_interface_id IN            NUMBER,
            p_message_name        IN            VARCHAR2,
            p_message_appl        IN            VARCHAR2 DEFAULT NULL,
            p_message_text        IN            VARCHAR2 DEFAULT NULL,
            p_token_1_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_1_value       IN            VARCHAR2 DEFAULT NULL,
            p_token_2_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_2_value       IN            VARCHAR2 DEFAULT NULL,
            p_token_3_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_3_value       IN            VARCHAR2 DEFAULT NULL,
            p_token_4_name        IN            VARCHAR2 DEFAULT NULL,
            p_token_4_value       IN            VARCHAR2 DEFAULT NULL,
            p_dleg_tab            IN            TMS_DLEG_TAB_TYPE,
            x_errors_tab          IN OUT NOCOPY INTERFACE_ERRORS_TAB_TYPE,
            x_return_status          OUT NOCOPY VARCHAR2) IS

  TYPE text_tab_type IS TABLE OF WSH_INTERFACE_ERRORS.ERROR_MESSAGE%TYPE INDEX BY BINARY_INTEGER;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'STAMP_INTERFACE_ERROR';
  --
  l_debug_on BOOLEAN;
  --
  l_index BINARY_INTEGER := NULL;
  l_message_appl VARCHAR2(30) := p_message_appl;
  c NUMBER;
  l_buffer VARCHAR2(4000);
  l_index_out NUMBER;

  --
  l_groups        WSH_UTIL_CORE.ID_TAB_TYPE;
  l_table_names   WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_interface_ids WSH_UTIL_CORE.ID_TAB_TYPE;
  l_message_names WSH_UTIL_CORE.COLUMN_TAB_TYPE;
  l_messages      text_tab_type;

  l_message       VARCHAR2(4000);
  l_message_name  VARCHAR2(30);
  l_dleg_tab      tms_dleg_tab_type;
  l_dlvy_id_tab   WSH_UTIL_CORE.id_tab_type;

  l_msg_data      VARCHAR2(240);

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_group_id', p_group_id);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_table_name', p_entity_table_name);
    WSH_DEBUG_SV.log(l_module_name,'p_entity_interface_id', p_entity_interface_id);
    WSH_DEBUG_SV.log(l_module_name,'p_message_appl', p_message_appl);
    WSH_DEBUG_SV.log(l_module_name,'p_message_name', p_message_name);
    WSH_DEBUG_SV.log(l_module_name,'p_message_text', p_message_text);
    WSH_DEBUG_SV.log(l_module_name,'p_token_1_name', p_token_1_name);
    WSH_DEBUG_SV.log(l_module_name,'p_token_1_value', p_token_1_value);
    WSH_DEBUG_SV.log(l_module_name,'p_token_2_name', p_token_2_name);
    WSH_DEBUG_SV.log(l_module_name,'p_token_2_value', p_token_2_value);
    WSH_DEBUG_SV.log(l_module_name,'p_token_3_name', p_token_3_name);
    WSH_DEBUG_SV.log(l_module_name,'p_token_3_value', p_token_3_value);
    WSH_DEBUG_SV.log(l_module_name,'p_token_4_name', p_token_4_name);
    WSH_DEBUG_SV.log(l_module_name,'p_token_4_value', p_token_4_value);
    WSH_DEBUG_SV.logmsg(l_module_name,'Count of Input Deliveries:'||p_dleg_tab.count);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_index := x_errors_tab.COUNT + 1;

  IF p_message_text IS NULL THEN --{
    l_message_appl := NVL(l_message_appl, 'WSH');

    FND_MESSAGE.SET_NAME(l_message_appl, 'WSH_OTM_GENERIC');
    -- remove the above, when message is seeded
    --FND_MESSAGE.SET_NAME(l_message_appl, p_message_name);
    -- OTM R12 the tokens are not used at all
/*
    IF p_token_1_name IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token_1_name, p_token_1_value);
      IF p_token_2_name IS NOT NULL THEN
        FND_MESSAGE.SET_TOKEN(p_token_2_name, p_token_2_value);
        IF p_token_3_name IS NOT NULL THEN
          FND_MESSAGE.SET_TOKEN(p_token_3_name, p_token_3_value);
          IF p_token_4_name IS NOT NULL THEN
            FND_MESSAGE.SET_TOKEN(p_token_4_name, p_token_4_value);
          END IF;
        END IF;
      END IF;
    END IF;
*/
    -- OTM R12

    fnd_msg_pub.add;

  ELSE
    x_errors_tab(l_index).ERROR_MESSAGE            := p_message_text;
    x_errors_tab(l_index).INTERFACE_TABLE_NAME     := p_entity_table_name;
    x_errors_tab(l_index).INTERFACE_ID             := p_entity_interface_id;
    x_errors_tab(l_index).INTERFACE_ERROR_GROUP_ID := p_group_id;
    x_errors_tab(l_index).MESSAGE_NAME             := p_message_name;

    l_index := l_index +1;
  END IF; --}

  c := FND_MSG_PUB.count_msg;
  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'COUNT--',c);
  END IF;

  FOR i in 1..c LOOP--{
  --FOR i in REVERSE(c)..1 LOOP--{

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'C:'||i);
    END IF;

    FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE,
          p_msg_index => i,
          p_data => l_buffer,
          p_msg_index_out => l_index_out);

    -- Concatenate the message
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'l_buffer:'||l_buffer);
    END IF;
    l_message := l_message||l_buffer;

   -- l_index := l_index + 1;
  END LOOP;--}

  FND_MSG_PUB.initialize;

  l_message_name := 'WSH_OTM_GENERIC';

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'l_index--',l_index);
    WSH_DEBUG_SV.logmsg(l_module_name,'l_message:'||substr(l_message,1,200));
    WSH_DEBUG_SV.logmsg(l_module_name,'Continued l_message:'||substr(l_message,201,200));
    WSH_DEBUG_SV.logmsg(l_module_name,'Continued l_message:'||substr(l_message,401,200));
  END IF;


  -- Populate the Delivery_interface_id
  IF p_dleg_tab.count > 0 THEN--{
    FOR i in p_dleg_tab.FIRST..p_dleg_tab.LAST
    LOOP
      l_dlvy_id_tab(l_dlvy_id_tab.count + 1) := p_dleg_tab(i).delivery_interface_id;
    END LOOP;

    IF l_dlvy_id_tab.count > 0 THEN
      FORALL i IN p_dleg_tab.FIRST .. p_dleg_tab.LAST
        INSERT INTO WSH_INTERFACE_ERRORS (
          INTERFACE_ERROR_ID,
          INTERFACE_ERROR_GROUP_ID,
          INTERFACE_TABLE_NAME,
          INTERFACE_ID,
          INTERFACE_ACTION_CODE,
          MESSAGE_NAME,
          ERROR_MESSAGE,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY)
          VALUES (
          WSH_INTERFACE_ERRORS_S.nextval,
          p_group_id, --l_groups(i),
          'WSH_NEW_DEL_INTERFACE', --l_table_names(i),
          l_dlvy_id_tab(i),--l_interface_ids(i),
          G_TMS_RELEASE_CODE,
          l_message_name,
          l_message,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID);
    END IF;

  END IF;--}

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.STAMP_INTERFACE_ERROR',
                        l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END stamp_interface_error;

--====================================================
-- Procedure: find_deliveries_for_trip
-- Description: This Procedure returns a table of delivery ids
--              and a table of records(delivery_interface_id, revision)
--              based on input of either tp_plan_name or trip_id.
-- Usage : Inbound BPEL process will also call this API before
-- populating the Interface tables.
--====================================================
PROCEDURE find_deliveries_for_trip(
  p_trip_id         IN            NUMBER,
  p_tp_plan_name    IN            VARCHAR2,
  x_delivery_tab       OUT NOCOPY WSH_TMS_RELEASE.delivery_tab,
  x_delivery_id_tab    OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
  x_return_status      OUT NOCOPY VARCHAR2) IS

  -- Query deliveries based on p_trip_id
  CURSOR c_get_deliveries1 IS
    SELECT wdl.delivery_id,
           wnd.tms_version_number,
           wnd.organization_id,
           wnd.name,
           wnd.status_code
      FROM wsh_delivery_legs wdl,
           wsh_trip_stops    wts,
           wsh_new_deliveries wnd
     WHERE wdl.pick_up_stop_id = wts.stop_id
       AND wts.trip_id = p_trip_id
       AND wdl.delivery_id = wnd.delivery_id(+);

  -- Query deliveries based on tp_plan_name
  CURSOR c_get_deliveries2 IS
    SELECT wdl.delivery_id,
           wnd.tms_version_number,
           wnd.organization_id,
           wnd.name,
           wnd.status_code
      FROM wsh_delivery_legs wdl,
           wsh_trip_stops    wts,
	   wsh_trips wt,
	   wsh_new_deliveries wnd
     WHERE wdl.pick_up_stop_id = wts.stop_id
       AND wts.trip_id = wt.trip_id
       AND wt.tp_plan_name = p_tp_plan_name
       AND wdl.delivery_id = wnd.delivery_id(+);

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'FIND_DELIVERIES_FOR_TRIP';
  --
  l_debug_on BOOLEAN;
  --
  --l_index NUMBER := 0;
  l_index VARCHAR2(38) := NULL;

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Tp Plan Name:', p_tp_plan_name);
    WSH_DEBUG_SV.log(l_module_name,'Trip Id:', p_trip_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_trip_id IS NOT NULL THEN--{
    FOR rec in c_get_deliveries1
    LOOP
      l_index  :=  rec.delivery_id;
      x_delivery_tab(l_index).tms_version_number := rec.tms_version_number;
      x_delivery_tab(l_index).organization_id := rec.organization_id;
      x_delivery_tab(l_index).name            := rec.name;
      x_delivery_tab(l_index).status_code     := rec.status_code;
      -- leave delivery_interface_id as null in x_delivery_tab
      x_delivery_id_tab(x_delivery_id_tab.count + 1) := rec.delivery_id;
    END LOOP;
  ELSIF p_tp_plan_name IS NOT NULL THEN
    FOR rec in c_get_deliveries2
    LOOP
      l_index :=  rec.delivery_id;
      x_delivery_tab(l_index).tms_version_number := rec.tms_version_number;
      x_delivery_tab(l_index).organization_id := rec.organization_id;
      x_delivery_tab(l_index).name            := rec.name;
      x_delivery_tab(l_index).status_code     := rec.status_code;
      -- leave delivery_interface_id as null
      x_delivery_id_tab(x_delivery_id_tab.count + 1) := rec.delivery_id;
    END LOOP;
  END IF;--}

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'x_delivery_id_tab.count', x_delivery_id_tab.count);
    WSH_DEBUG_SV.log(l_module_name, 'x_delivery_tab.count', x_delivery_tab.count);
    WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_get_deliveries1 %ISOPEN THEN
      CLOSE c_get_deliveries1;
    END IF;
    IF c_get_deliveries2 %ISOPEN THEN
      CLOSE c_get_deliveries2;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.FIND_DELIVERIES_FOR_TRIP',
                        l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
END find_deliveries_for_trip;

--====================================================
-- Procedure: compare_trip_for_deliveries
-- Description: This Procedure returns a table of delivery ids
--              which have been unassigned from their current trips
--              (as they have to be placed on GC3 trip)
--              GC3 trip may or may not have been created in EBS, so
--              p_trip_id is optional field
--              Also appends to existing list of deliveries to be
--              unassigned and their version numbers
-- Usage : Internal
--====================================================
PROCEDURE compare_trip_for_deliveries
  (p_dleg_tab         IN OUT NOCOPY TMS_DLEG_TAB_TYPE,
   p_trip_id          IN            NUMBER,
   x_unassign_id_tab  IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
   --x_unassign_ver_tab IN OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
   x_return_status       OUT NOCOPY VARCHAR2) IS

CURSOR c_get_current_trip(p_delivery_id IN NUMBER) IS
SELECT wdl.delivery_leg_id,
       wdl.pick_up_stop_id         pick_up_stop_id,
       wdl.drop_off_stop_id        drop_off_stop_id,
       wts_pu.stop_location_id     pickup_stop_location_id,
       wts_pu.stop_sequence_number pickup_stop_sequence,
       wts_do.stop_location_id     dropoff_stop_location_id,
       wts_do.stop_sequence_number dropoff_stop_sequence,
       wts_pu.trip_id              trip_id
  FROM wsh_delivery_legs wdl,
       wsh_trip_stops wts_pu,
       wsh_trip_stops wts_do
 WHERE wdl.delivery_id = p_delivery_id
   AND wdl.pick_up_stop_id = wts_pu.stop_id
   AND wdl.drop_off_stop_id = wts_do.stop_id ;

  l_current_trip_id  NUMBER;

  l_del_attrs            WSH_NEW_DELIVERIES_PVT.delivery_attr_tbl_type;
  l_del_action_prms      WSH_DELIVERIES_GRP.action_parameters_rectype;
  l_del_action_rec       WSH_DELIVERIES_GRP.delivery_action_out_rec_type;
  l_del_defaults         WSH_DELIVERIES_GRP.default_parameters_rectype;

  l_rs                   VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(32767);

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'COMPARE_TRIP_FOR_DELIVERIES';
  --
  l_debug_on BOOLEAN;
  --

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Input Delivery Count:', p_dleg_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Trip Id:', p_trip_id);
    WSH_DEBUG_SV.log(l_module_name,'Unassign Delivery Count:', x_unassign_id_tab.count);
  --  WSH_DEBUG_SV.log(l_module_name,'Unassign Delivery Version Count:', x_unassign_ver_tab.count);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF p_dleg_tab.count > 0 THEN

  FOR dlvy_count IN p_dleg_tab.FIRST..p_dleg_tab.LAST
  LOOP--{
    -- Loop as there can be multiple trips for a delivery!!!
    FOR dleg_rec IN c_get_current_trip(p_dleg_tab(dlvy_count).delivery_id)
    LOOP--{

      l_del_attrs.DELETE;
      l_current_trip_id := dleg_rec.trip_id;

      -- All assignments happen together, later
      IF (
          -- If trips are different, then need to unassign the delivery from trip
          (l_current_trip_id IS NOT NULL AND l_current_trip_id <> nvl(p_trip_id,-99))
          OR
          (
           -- Need to check if the pickup and dropoff stops are identical or different
           -- If different, then need to unassign the delivery from trip
           (l_current_trip_id IS NOT NULL AND p_trip_id IS NOT NULL AND l_current_trip_id = p_trip_id)
            AND
           (dleg_rec.pickup_stop_location_id <> to_number(p_dleg_tab(dlvy_count).pickup_stop_location_id) OR
            dleg_rec.pickup_stop_sequence <> p_dleg_tab(dlvy_count).pickup_stop_sequence OR
            dleg_rec.dropoff_stop_location_id <> to_number(p_dleg_tab(dlvy_count).dropoff_stop_location_id) OR
            dleg_rec.dropoff_stop_sequence <> p_dleg_tab(dlvy_count).dropoff_stop_sequence)
          )
         ) THEN--{


        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Need to UNASSIGN DELIVERY');
        END IF;

        -- Cannot do BULK UNASSIGNMENT HERE, as there can be multiple trips and the
        -- deliveries could be associated with different trips
        -- Delivery_action API gives an option to specify multiple deliveries
        -- but single trip.
        -- This unassign is for single delivery from single trip
        l_del_attrs(l_del_attrs.count + 1).delivery_id := p_dleg_tab(dlvy_count).delivery_id;
        l_del_attrs(l_del_attrs.count).organization_id := p_dleg_tab(dlvy_count).organization_id;

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Deliveries to be unassigned:'||l_del_attrs.count);
        END IF;

        l_del_action_prms.caller      := 'FTE_TMS_INTEGRATION'; --'FTE_TMS_RELEASE';
        l_del_action_prms.action_code := 'UNASSIGN-TRIP';
        l_del_action_prms.trip_id     := l_current_trip_id;

        WSH_DELIVERIES_GRP.delivery_action(
          p_api_version_number => 1.0,
          p_init_msg_list      => FND_API.G_TRUE,
          p_commit             => FND_API.G_FALSE,
          p_action_prms        => l_del_action_prms,
          p_rec_attr_tab       => l_del_attrs,
          x_delivery_out_rec   => l_del_action_rec,
          x_defaults_rec       => l_del_defaults,
          x_return_status      => l_rs,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data);

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name,'Return Status after Unassign Delivery'||l_rs);
        END IF;
        IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_rs;
          EXIT;
        END IF;
        -- THESE WILL BE ASSIGNED LATER, SO WHY POPULATE IN UNASSIGNED TAB AND THEN DELETE LATER!!!!!
        -- CHECK THIS !!!!
      ELSIF (
        -- Need to check if the pickup and dropoff stops are identical or different
        -- If identical, then NO need to unassign the delivery from trip
        -- skip this delivery while processing the deliveries
        (l_current_trip_id IS NOT NULL AND p_trip_id IS NOT NULL AND l_current_trip_id = p_trip_id)
         AND
        (dleg_rec.pickup_stop_location_id = to_number(p_dleg_tab(dlvy_count).pickup_stop_location_id) AND
         dleg_rec.pickup_stop_sequence = p_dleg_tab(dlvy_count).pickup_stop_sequence AND
         dleg_rec.dropoff_stop_location_id = to_number(p_dleg_tab(dlvy_count).dropoff_stop_location_id) AND
         dleg_rec.dropoff_stop_sequence = p_dleg_tab(dlvy_count).dropoff_stop_sequence)
        ) THEN

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'DELIVERY IS ALREADY ASSIGNED TO TRIP');
        END IF;
        p_dleg_tab(dlvy_count).processed_flag := 'Y';
      END IF;--}
    END LOOP;--}

    IF l_rs IN (WSH_UTIL_CORE.G_RET_STS_ERROR, WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_rs;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name, 'Error Processing Delivery id:'||(p_dleg_tab(dlvy_count).delivery_id));
      END IF;
      EXIT;
    END IF;
  END LOOP;--}
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Unassign Delivery Count:', x_unassign_id_tab.count);
   -- WSH_DEBUG_SV.log(l_module_name,'Unassign Delivery Version Count:', x_unassign_ver_tab.count);
    WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_get_current_trip %ISOPEN THEN
      CLOSE c_get_current_trip;
    END IF;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.COMPARE_TRIP_FOR_DELIVERIES',
                        l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END compare_trip_for_deliveries;

--
-- Procedure  : launch_release_request
-- Description: Submit a concurrent request
-- Parameters :
--   Input
--      p_group_id      Input group id
--   Output
--      x_request_id    Request id of the concurrent program
--      x_return_status Return Status
--
PROCEDURE launch_release_request
  (p_group_id      IN            NUMBER,
   x_request_id       OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2) IS

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LAUNCH_RELEASE_REQUEST';
  --
  l_debug_on BOOLEAN;
  --

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Group Id:', p_group_id);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  x_request_id := FND_REQUEST.Submit_Request
                    (application => 'WSH',
                     program     => 'WSHOTMRL',
                     argument1   => p_group_id);
--  COMMIT;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name, 'Request id:', x_request_id);
    WSH_DEBUG_SV.log(l_module_name, 'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_request_id    := 0;
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.LAUNCH_RELEASE_REQUEST',
                        l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END launch_release_request;

--===================================================================
-- Procedure  : Process Internal Locations
-- Description: Process Internal Locations before Create or Update
--              of Stops in EBS based on the information sent from
--              GC3.
--              Refer to ECO 5033116
-- Parameters :
--   In/Out
--      x_delivery_tab : Delivery Information received from GC3
--      x_stop_tab     : Stop Information received from GC3
--   Output
--      x_return_status: Return Status
--
-- Possible Scenarios
--  Single Delivery
--                   Pickup         Dropoff
--        Delivery1 :  M1             M2'
--
-- Multiple Delivery
--                   Pickup         Dropoff
--        Delivery1 :  M1             M2'
--        Delivery2 :  M2             XYZ
-- For OUTBOUND only scenarios
-- Dummy location will never be pickup stop location and
-- Physical location cannot be the dropoff stop location
--
--===================================================================
PROCEDURE process_internal_locations
  (x_delivery_tab IN OUT NOCOPY TMS_DLEG_TAB_TYPE,
   x_stop_tab     IN OUT NOCOPY TMS_STOP_TAB_TYPE,
   x_return_status   OUT NOCOPY VARCHAR2) IS


  l_stop_tab             TMS_STOP_TAB_TYPE;
  l_new_stop_tab         TMS_STOP_TAB_TYPE;
  l_dlvy_tab             TMS_DLEG_TAB_TYPE;
  l_return_status        VARCHAR2(1);
  l_physical_loc_id      NUMBER;
  l_dropoff_location_id  NUMBER;
  l_update_stop          VARCHAR2(1);
  l_index                NUMBER;

  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_INTERNAL_LOCATIONS';
  --
  l_debug_on BOOLEAN;
  --

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'Delivery Tab Count:', x_delivery_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Stop Tab Count:', x_stop_tab.count);
  END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_stop_tab := x_stop_tab;
  l_dlvy_tab := x_delivery_tab;

  FOR i IN l_stop_tab.FIRST..l_stop_tab.LAST
  LOOP--{

    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name, '=====================================');
      WSH_DEBUG_SV.logmsg(l_module_name, 'Stop Location:'||l_stop_tab(i).stop_location_id);
    END IF;

    IF x_delivery_tab.count = 1 THEN -- Single Delivery in the GC3 Trip--{
      -- Match Stop Location to Delivery Dropoff Location
      l_dropoff_location_id := to_number(x_delivery_tab(x_delivery_tab.FIRST).ultimate_dropoff_location_id);
      IF l_dropoff_location_id = to_number(l_stop_tab(i).stop_location_id) THEN--{
        -- no action required as Dropoff Location matches incoming stop
        --null;
        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Dropoff Location Matches Stop Location');
        END IF;
      ELSIF l_dropoff_location_id <> to_number(l_stop_tab(i).stop_location_id) THEN--} --{

        IF l_debug_on THEN
          WSH_DEBUG_SV.logmsg(l_module_name, 'Dropoff Location Does not match Stop Location');
        END IF;

        -- get the physical location corresponding to delivery
        -- dropoff location and match with Stop Location
        WSH_LOCATIONS_PKG.convert_internal_cust_location(
          p_internal_cust_location_id => l_dropoff_location_id,
          x_internal_org_location_id  => l_physical_loc_id,
          x_return_status             => l_return_status);

        IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                               WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
        THEN
          x_return_status := l_return_status;
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Conversion Failed,l_return_status', l_return_status);
          END IF;
          EXIT; -- exit out of the stop_tab loop
        END IF;

        IF l_debug_on THEN
          WSH_DEBUG_SV.log(l_module_name, 'Delivery Physical Location Id:'||l_physical_loc_id);
          WSH_DEBUG_SV.log(l_module_name, 'Stop Location Id:'||l_stop_tab(i).stop_location_id);
        END IF;

        IF l_physical_loc_id IS NOT NULL AND
           to_number(l_stop_tab(i).stop_location_id) = l_physical_loc_id THEN
          IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name, 'Delivery Dropoff Dummy Location Matches Incoming Stop Location');
          END IF;
          -- As there is only 1 delivery involved, create the stop based on the
          -- dummy location. Delivery assignment is done based on this location.
          -- x_stop_tab matches l_stop_tab, same index
          --l_stop_tab(i).stop_location_id := l_dropoff_location_id;
          x_stop_tab(i).stop_location_id := l_dropoff_location_id;
          x_delivery_tab(x_delivery_tab.FIRST).dropoff_stop_location_id := l_dropoff_location_id;
          -- Keep the other attributes same, like Sequence,dates
        END IF;

      END IF;--}

    ELSE -- Multiple Deliveries coming in the GC3 trip --} --{
      -- Loop thru the deliveries to compare the dropoff location of deliveries
      -- with current stop location
      FOR j in x_delivery_tab.FIRST..x_delivery_tab.LAST
      LOOP--{

        -- Match Stop Location to Delivery Dropoff Location
        l_dropoff_location_id := to_number(x_delivery_tab(j).ultimate_dropoff_location_id);
        IF l_dropoff_location_id = to_number(l_stop_tab(i).stop_location_id) THEN--{
          -- no action required as Dropoff Location matches incoming stop
          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Dropoff Location Matches Stop Location for delivery:'||x_delivery_tab(j).delivery_id);
          END IF;

        ELSIF l_dropoff_location_id <> to_number(l_stop_tab(i).stop_location_id) THEN--} --{

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Dropoff Location Does not match Stop Location for delivery:'||x_delivery_tab(j).delivery_id);
          END IF;

          -- get the physical location corresponding to delivery
          -- dropoff location and match with Stop Location
          WSH_LOCATIONS_PKG.convert_internal_cust_location(
            p_internal_cust_location_id => l_dropoff_location_id,
            x_internal_org_location_id  => l_physical_loc_id,
            x_return_status             => l_return_status);

          IF l_return_status IN (WSH_UTIL_CORE.G_RET_STS_ERROR,
                                 WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
          THEN
            x_return_status := l_return_status;
            IF l_debug_on THEN
              WSH_DEBUG_SV.log(l_module_name, 'Conversion Failed,l_return_status', l_return_status);
            END IF;
            EXIT; -- exit out of the stop_tab loop
          END IF;

          IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery Physical Location Id:'||l_physical_loc_id);
            WSH_DEBUG_SV.logmsg(l_module_name, 'Stop Location Id:'||l_stop_tab(i).stop_location_id);
          END IF;

          -- The physical location for delivery dropoff location matches the incoming stop
          -- location.
          IF l_physical_loc_id IS NOT NULL AND
             to_number(l_stop_tab(i).stop_location_id) = l_physical_loc_id THEN--{
            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'Delivery Dropoff Dummy Location Matches Incoming Stop Location');
            END IF;

            l_update_stop := 'Y';
            -- As there are multiple deliveries, need to evaluate the pickup of those
            -- as well to see if any of them have location matching to the physical
            FOR k in l_dlvy_tab.FIRST..l_dlvy_tab.LAST
            LOOP
              -- Compare the deliveries except the current delivery
              -- and the Pickup location of those match the Incoming Stop
              -- Location
              IF l_dlvy_tab(k).delivery_id <> x_delivery_tab(j).delivery_id AND
                 to_number(l_dlvy_tab(k).pickup_stop_location_id) = to_number(l_stop_tab(i).stop_location_id) THEN
                -- There exist other deliveries linked to this stop location,
                -- Cannot convert the Incoming Stop location to correspond to the dummy
                -- Need to create a new stop for the Dummy Location
                l_update_stop := 'N';
                IF l_debug_on THEN
                  WSH_DEBUG_SV.logmsg(l_module_name,'Atleast one delivery uses this location as pickup, delivery_id:'||l_dlvy_tab(k).delivery_id);
                END IF;
                EXIT; -- out of this loop for delivery, once a match is found
              END IF;
            END LOOP;

            IF l_debug_on THEN
              WSH_DEBUG_SV.logmsg(l_module_name, 'L_UPDATE_STOP FLAG:'||l_update_stop);
            END IF;

            IF l_update_stop = 'Y' THEN--{
              -- Update the Stop Location for current stop to match delivery location
              -- x_stop_tab matches l_stop_tab
              --l_stop_tab(i).stop_location_id := l_dropoff_location_id;
              x_stop_tab(i).stop_location_id := l_dropoff_location_id;
              -- Update Delivery tab, which is used while assigning delivery to trip
              x_delivery_tab(j).dropoff_stop_location_id := l_dropoff_location_id;

            ELSE -- l_update_stop = N, when other deliveries use physical location

              -- Assign current Stop record to the new stop table
              l_index := l_new_stop_tab.count + 1;
              l_new_stop_tab(l_index) := l_stop_tab(i);
              -- Keep all information same, except location
              -- Stop interface id is also kept the same!
              -- Stop Sequence Number is incremented for all the following stops
              l_new_stop_tab(l_index).stop_location_id := l_dropoff_location_id;
              -- For this delivery, set dropoff, which is used in Assign Delivery to Trip
              x_delivery_tab(j).dropoff_stop_location_id := l_dropoff_location_id;

              -- As the SSN can be in sent by GC3 in any order. Hence,
              -- Update Stop Sequence Number for all the stops with sequence number
              -- higher than the stop for dummy location. Also, update SSN for the
              -- current stop being processed which has SSN same as the dummy stop
              -- Loop across x_stop_tab, x_stop_tab is ordered by SSN for each trip
              FOR stop_update IN x_stop_tab.FIRST..x_stop_tab.LAST
              LOOP
                IF x_stop_tab(stop_update).stop_sequence_number >= l_stop_tab(i).stop_sequence_number
                THEN
                  -- This will ensure dummy and physical stops are created together
                  -- Physical and other higher stops (with higher SSN are pushed out by 1)
                  x_stop_tab(stop_update).stop_sequence_number
                   :=  x_stop_tab(stop_update).stop_sequence_number + 1;
                END IF;
              END LOOP;
            END IF;--} -- l_update_stop condition

          END IF;--} -- physical location of delivery matches incoming stop location
        END IF;--} -- dropoff location comparison with incoming stop location
      END LOOP;--} -- across delivery_tab
    END IF; --} -- single or multiple count of deliveries

  END LOOP;--} -- across stop_tab Loop

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'New Dummy Stop Tab Count:', l_new_stop_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Input Stop Tab Count:', x_stop_tab.count);
  END IF;

  IF l_new_stop_tab.count > 0 THEN--{
    FOR new_stop in l_new_stop_tab.FIRST..l_new_stop_tab.LAST
    LOOP
      -- This record will be inserted towards the end of x_stop_tab, but
      -- that is fine for create/update as well as for Assignment where
      -- delivery dropoff location is compared with stop location and
      -- delivery leg dropoff stop interface id to differenciate between
      -- the physical and dummy dropoffs.
      x_stop_tab(l_stop_tab.count + 1) := l_new_stop_tab(new_stop);
    END LOOP;
  END IF;--}

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'Delivery Tab Count:', x_delivery_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'Output Stop Tab Count:', x_stop_tab.count);
    WSH_DEBUG_SV.log(l_module_name,'x_return_status', x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Close any open cursors
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    WSH_UTIL_CORE.DEFAULT_HANDLER(
                        'WSH_TMS_RELEASE.PROCESS_INTERNAL_LOCATIONS',l_module_name);
    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END process_internal_locations;

--
--
-- ECO 5101760
-- Get Server Time for Timezone conversion
PROCEDURE get_server_time
  (p_source_time            IN      DATE,
   p_source_timezone_code   IN      VARCHAR2,
   x_server_time               OUT  NOCOPY DATE,
   x_return_status             OUT  NOCOPY VARCHAR2,
   x_msg_count                 OUT  NOCOPY NUMBER,
   x_msg_data                  OUT  NOCOPY VARCHAR2) IS

  CURSOR c_get_timezone_id(c_timezone_code IN VARCHAR2) IS
    SELECT upgrade_tz_id
    FROM fnd_timezones_b
    WHERE  timezone_code = c_timezone_code;

  l_server_tz_id              NUMBER;
  l_source_tz_id              NUMBER;

  invalid_timezone            EXCEPTION;

  l_debug_on                       CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
  l_module_name                    CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_server_time';

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push (l_module_name);
    WSH_DEBUG_SV.logmsg(l_module_name,'p_source_timezone_code  : '||p_source_timezone_code);
    WSH_DEBUG_SV.logmsg(l_module_name,'p_source_time  : '||to_char(p_source_time,'DD-MON-RRRR HH24:MI:SS'));
  END IF;

  IF p_source_timezone_code IS NULL THEN
    RAISE invalid_timezone;
  END IF;

  OPEN c_get_timezone_id(p_source_timezone_code);
  FETCH c_get_timezone_id INTO l_source_tz_id;
  IF c_get_timezone_id%NOTFOUND THEN
    RAISE invalid_timezone;
  END IF;
  CLOSE c_get_timezone_id;

  l_server_tz_id := FND_PROFILE.value('SERVER_TIMEZONE_ID');

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Server tz id :'||l_server_tz_id);
  END IF;

  HZ_TIMEZONE_PUB.Get_Time(
       p_api_version                   =>  1.0,
       p_init_msg_list                 =>  'F',
       p_source_tz_id                  =>  l_source_tz_id,
       p_dest_tz_id                    =>  l_server_tz_id,
       p_source_day_time               =>  p_source_time,
       x_dest_day_time                 =>  x_server_time,
       x_return_status                 =>  x_return_status,
       x_msg_count                     =>  x_msg_count,
       x_msg_data                      =>  x_msg_data);

  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'Returning time : '|| x_server_time);
    WSH_DEBUG_SV.logmsg(l_module_name,'Returning x_return_status : '|| x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN invalid_timezone THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_OTM_INVALID_TIMEZONE');
    WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    x_msg_data := 'Input Timezone is not a valid FND timezone code';
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_timezone');
    END IF;
    --

  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    x_msg_data := 'Oracle error message is '|| SQLERRM;
    WSH_UTIL_CORE.default_handler('WSH_OTM_INBOUND_GRP.get_server_time');
    --
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
      WSH_DEBUG_SV.logmsg(l_module_name,'-------------- END ----------------');
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR');
    END IF;
    --
END get_server_time;

--====================================================

END WSH_TMS_RELEASE;

/
