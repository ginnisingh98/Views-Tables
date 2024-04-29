--------------------------------------------------------
--  DDL for Package WSH_TMS_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TMS_RELEASE" AUTHID CURRENT_USER as
/* $Header: WSHTMRLS.pls 120.1.12010000.4 2009/12/03 14:23:06 anvarshn ship $ */

G_TMS_RELEASE_CODE CONSTANT VARCHAR2(30) := 'TMS_RELEASE';
G_TMS_DELETE_CODE CONSTANT VARCHAR2(30)  := 'TMS_DELETE';

TYPE interface_errors_tab_type IS TABLE OF WSH_INTERFACE_ERRORS%ROWTYPE INDEX BY
BINARY_INTEGER;

TYPE tms_dleg_rec_type IS RECORD (
         delivery_leg_interface_id    NUMBER,
         delivery_interface_id        NUMBER,
         pickup_stop_location_id      VARCHAR2(30),  --NUMBER,
         pickup_stop_sequence         NUMBER,
         dropoff_stop_location_id     VARCHAR2(30),  --NUMBER,
         dropoff_stop_sequence        NUMBER,
         trip_interface_id            NUMBER,
         delivery_leg_id              NUMBER,
         delivery_id                  NUMBER,
         pick_up_stop_interface_id    NUMBER,
         drop_off_stop_interface_id   NUMBER,
         weight_uom                   VARCHAR2(3),
         volume_uom                   VARCHAR2(3),
         organization_id              NUMBER,
         tms_version_number           NUMBER, -- EBS tms_version_number
         otm_tms_version_number       NUMBER, -- OTM sent tms_version_number
         initial_pickup_location_id   NUMBER,
         ultimate_dropoff_location_id NUMBER,
         processed_flag               VARCHAR2(1),
         tms_interface_flag           VARCHAR2(3)  -- EBS tms_interface_flag.
     );
TYPE tms_dleg_tab_type IS TABLE OF tms_dleg_rec_type INDEX BY BINARY_INTEGER;

TYPE tms_stop_rec_type IS RECORD (
          stop_interface_id         NUMBER,
          stop_id                   NUMBER,
          tp_stop_id                NUMBER,
          stop_location_id          VARCHAR2(30),
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
          trip_interface_id         NUMBER,
          timezone_code             VARCHAR2(50), -- ECO 5101760
          dml_action                VARCHAR2(1),
          tp_attribute_category     WSH_TRIP_STOPS.TP_ATTRIBUTE_CATEGORY%TYPE,
          tp_attribute1             WSH_TRIP_STOPS.TP_ATTRIBUTE1%TYPE,
          tp_attribute2             WSH_TRIP_STOPS.TP_ATTRIBUTE2%TYPE,
          tp_attribute3             WSH_TRIP_STOPS.TP_ATTRIBUTE3%TYPE,
          tp_attribute4             WSH_TRIP_STOPS.TP_ATTRIBUTE4%TYPE,
          tp_attribute5             WSH_TRIP_STOPS.TP_ATTRIBUTE5%TYPE,
          tp_attribute6             WSH_TRIP_STOPS.TP_ATTRIBUTE6%TYPE,
          tp_attribute7             WSH_TRIP_STOPS.TP_ATTRIBUTE7%TYPE,
          tp_attribute8             WSH_TRIP_STOPS.TP_ATTRIBUTE8%TYPE,
          tp_attribute9             WSH_TRIP_STOPS.TP_ATTRIBUTE9%TYPE,
          tp_attribute10            WSH_TRIP_STOPS.TP_ATTRIBUTE10%TYPE,
          tp_attribute11            WSH_TRIP_STOPS.TP_ATTRIBUTE11%TYPE,
          tp_attribute12            WSH_TRIP_STOPS.TP_ATTRIBUTE12%TYPE,
          tp_attribute13            WSH_TRIP_STOPS.TP_ATTRIBUTE13%TYPE,
          tp_attribute14            WSH_TRIP_STOPS.TP_ATTRIBUTE14%TYPE,
          tp_attribute15            WSH_TRIP_STOPS.TP_ATTRIBUTE15%TYPE,
          attribute_category         WSH_TRIP_STOPS.ATTRIBUTE_CATEGORY%TYPE,
          attribute1                 WSH_TRIP_STOPS.ATTRIBUTE1%TYPE,
          attribute2                 WSH_TRIP_STOPS.ATTRIBUTE2%TYPE,
          attribute3                 WSH_TRIP_STOPS.ATTRIBUTE3%TYPE,
          attribute4                 WSH_TRIP_STOPS.ATTRIBUTE4%TYPE,
          attribute5                 WSH_TRIP_STOPS.ATTRIBUTE5%TYPE,
          attribute6                 WSH_TRIP_STOPS.ATTRIBUTE6%TYPE,
          attribute7                 WSH_TRIP_STOPS.ATTRIBUTE7%TYPE,
          attribute8                 WSH_TRIP_STOPS.ATTRIBUTE8%TYPE,
          attribute9                 WSH_TRIP_STOPS.ATTRIBUTE9%TYPE,
          attribute10                WSH_TRIP_STOPS.ATTRIBUTE10%TYPE,
          attribute11                WSH_TRIP_STOPS.ATTRIBUTE11%TYPE,
          attribute12                WSH_TRIP_STOPS.ATTRIBUTE12%TYPE,
          attribute13                WSH_TRIP_STOPS.ATTRIBUTE13%TYPE,
          attribute14                WSH_TRIP_STOPS.ATTRIBUTE14%TYPE,
          attribute15                WSH_TRIP_STOPS.ATTRIBUTE15%TYPE
     );
          --wv_frozen_flag            WSH_TRIP_STOPS.wv_frozen_flag%TYPE
          --wsh_physical_location_id  NUMBER  -- if populated, plan stop has been mapped to a TE internal stop

TYPE tms_stop_tab_type IS TABLE OF tms_stop_rec_type INDEX BY BINARY_INTEGER;


TYPE tms_trip_rec_type IS RECORD (
         trip_interface_id          NUMBER,
         group_id                   NUMBER, --Bug7717569
         trip_id                    NUMBER,
         tp_plan_name               WSH_TRIPS.TP_PLAN_NAME%TYPE,
         tp_trip_number             WSH_TRIPS.TP_TRIP_NUMBER%TYPE,
         planned_flag               WSH_TRIPS.PLANNED_FLAG%TYPE,
         wsh_planned_flag           WSH_TRIPS.PLANNED_FLAG%TYPE,
         wsh_status_code            WSH_TRIPS.STATUS_CODE%TYPE,
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
         ignore_for_planning        WSH_TRIPS.IGNORE_FOR_PLANNING%TYPE,
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
         vehicle_item_name          WSH_TRIPS_INTERFACE.VEHICLE_ITEM_NAME%TYPE,
         interface_action_code
WSH_TRIPS_INTERFACE.INTERFACE_ACTION_CODE%TYPE,
         attribute_category         WSH_TRIPS.ATTRIBUTE_CATEGORY%TYPE,
         attribute1                 WSH_TRIPS.ATTRIBUTE1%TYPE,
         attribute2                 WSH_TRIPS.ATTRIBUTE2%TYPE,
         attribute3                 WSH_TRIPS.ATTRIBUTE3%TYPE,
         attribute4                 WSH_TRIPS.ATTRIBUTE4%TYPE,
         attribute5                 WSH_TRIPS.ATTRIBUTE5%TYPE,
         attribute6                 WSH_TRIPS.ATTRIBUTE6%TYPE,
         attribute7                 WSH_TRIPS.ATTRIBUTE7%TYPE,
         attribute8                 WSH_TRIPS.ATTRIBUTE8%TYPE,
         attribute9                 WSH_TRIPS.ATTRIBUTE9%TYPE,
         attribute10                WSH_TRIPS.ATTRIBUTE10%TYPE,
         attribute11                WSH_TRIPS.ATTRIBUTE11%TYPE,
         attribute12                WSH_TRIPS.ATTRIBUTE12%TYPE,
         attribute13                WSH_TRIPS.ATTRIBUTE13%TYPE,
         attribute14                WSH_TRIPS.ATTRIBUTE14%TYPE,
         attribute15                WSH_TRIPS.ATTRIBUTE15%TYPE
     );
TYPE tms_trip_tab_type IS TABLE OF tms_trip_rec_type INDEX BY BINARY_INTEGER;

TYPE delivery_rec IS RECORD
  (delivery_interface_id   NUMBER,
   organization_id         NUMBER,
   tms_version_number      NUMBER,
   name                    VARCHAR2(30),
   status_code             VARCHAR2(2));

TYPE delivery_tab IS TABLE OF delivery_rec INDEX BY VARCHAR2(38);

--
--  Procedure:          release_planned_shipment
--  Parameters:
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
--  Description:
--               Reconciliate shipping data with the GC3 plan populated
--               in the WSH interface tables.
--
--
-- Bug#7491598(ER,defer planned shipment iface): Added new parameters which are
-- used when invoked the planned shipment interface manually.
PROCEDURE release_planned_shipment(
  errbuf              OUT NOCOPY   VARCHAR2,
  retcode             OUT NOCOPY   VARCHAR2,
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
  );

--
--  Procedure:          purge_interface_data
--  Parameters:
--    p_tp_plan_name      : Tp_plan_name
--    p_trip_interface_id : Trip Interface Id
--    p_commit_flag       : Y - commit changes; N - do not commit
--    p_exception_action  : 'PURGE' or 'CLOSE'
--    x_return_status     : return status
--
--  Description:
--               Delete the records from WSH interface tables
--               and close/purge the appropriate exceptions
--
PROCEDURE purge_interface_data(
  p_tp_plan_name           IN            VARCHAR2 DEFAULT NULL,
  p_trip_interface_id      IN            VARCHAR2 DEFAULT NULL,
  p_commit_flag            IN            VARCHAR2,
  p_exception_action       IN            VARCHAR2 DEFAULT 'PURGE',
  x_return_status             OUT NOCOPY VARCHAR2);

--
--  Procedure:         find_deliveries_for_trip
--  Parameters:
--    p_trip_id         : Trip Id
--    p_tp_plan_name    : Tp_plan_name
--    x_return_status   : return status
-- Two types of outputs are required from this API
-- 1) x_delivery_tab    : Table of Delivery ids
-- 2) x_delivery_id_tab : Table of Delivery id+Revision+Delivery interface_id
--
--  Description:   Find deliveries for input of trip id or tp_plan_name
--
PROCEDURE find_deliveries_for_trip(
  p_trip_id         IN            NUMBER,
  p_tp_plan_name    IN            VARCHAR2,
  x_delivery_tab       OUT NOCOPY WSH_TMS_RELEASE.delivery_tab,
  x_delivery_id_tab    OUT NOCOPY WSH_UTIL_CORE.id_tab_type,
  x_return_status      OUT NOCOPY VARCHAR2);

--
PROCEDURE launch_release_request
  (p_group_id      IN            NUMBER,
   x_request_id       OUT NOCOPY NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2);

END WSH_TMS_RELEASE;

/
