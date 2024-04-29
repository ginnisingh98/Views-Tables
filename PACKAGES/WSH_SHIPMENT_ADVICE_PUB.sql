--------------------------------------------------------
--  DDL for Package WSH_SHIPMENT_ADVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPMENT_ADVICE_PUB" AUTHID CURRENT_USER as
/* $Header: WSHSAPBS.pls 120.0.12010000.1 2010/02/25 17:14:03 sankarun noship $ */
/*#
 * This is the public interface for the Shipment Advice entity. It allows
 * execution of  'creation' of Shipment Advice and 'Processing' the same.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Shipment Advice
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_SHIPMENT_ADVICE
 */

--===================
-- PUBLIC VARS
--===================

TYPE Freight_Cost_Rec_Type IS RECORD (
     freight_cost_type_code       WSH_FREIGHT_COSTS_INTERFACE.freight_cost_type_code%TYPE,
     unit_amount                  WSH_FREIGHT_COSTS_INTERFACE.unit_amount%TYPE,
     currency_code                WSH_FREIGHT_COSTS_INTERFACE.currency_code%TYPE,
     attribute_category           WSH_FREIGHT_COSTS_INTERFACE.attribute_category%TYPE,
     attribute1                   WSH_FREIGHT_COSTS_INTERFACE.attribute1%TYPE,
     attribute2                   WSH_FREIGHT_COSTS_INTERFACE.attribute2%TYPE,
     attribute3                   WSH_FREIGHT_COSTS_INTERFACE.attribute3%TYPE,
     attribute4                   WSH_FREIGHT_COSTS_INTERFACE.attribute4%TYPE,
     attribute5                   WSH_FREIGHT_COSTS_INTERFACE.attribute5%TYPE,
     attribute6                   WSH_FREIGHT_COSTS_INTERFACE.attribute6%TYPE,
     attribute7                   WSH_FREIGHT_COSTS_INTERFACE.attribute7%TYPE,
     attribute8                   WSH_FREIGHT_COSTS_INTERFACE.attribute8%TYPE,
     attribute9                   WSH_FREIGHT_COSTS_INTERFACE.attribute9%TYPE,
     attribute10                  WSH_FREIGHT_COSTS_INTERFACE.attribute10%TYPE,
     attribute11                  WSH_FREIGHT_COSTS_INTERFACE.attribute11%TYPE,
     attribute12                  WSH_FREIGHT_COSTS_INTERFACE.attribute12%TYPE,
     attribute13                  WSH_FREIGHT_COSTS_INTERFACE.attribute13%TYPE,
     attribute14                  WSH_FREIGHT_COSTS_INTERFACE.attribute14%TYPE,
     attribute15                  WSH_FREIGHT_COSTS_INTERFACE.attribute15%TYPE );

TYPE Freight_Cost_Rec_Tab IS TABLE OF Freight_Cost_Rec_Type index by binary_integer;

TYPE Container_Rec_Type IS RECORD (
     delivery_detail_number       WSH_DEL_DETAILS_INTERFACE.delivery_detail_id%TYPE,
     attribute_category           WSH_DEL_DETAILS_INTERFACE.attribute_category%TYPE,
     attribute1                   WSH_DEL_DETAILS_INTERFACE.attribute1%TYPE,
     attribute2                   WSH_DEL_DETAILS_INTERFACE.attribute2%TYPE,
     attribute3                   WSH_DEL_DETAILS_INTERFACE.attribute3%TYPE,
     attribute4                   WSH_DEL_DETAILS_INTERFACE.attribute4%TYPE,
     attribute5                   WSH_DEL_DETAILS_INTERFACE.attribute5%TYPE,
     attribute6                   WSH_DEL_DETAILS_INTERFACE.attribute6%TYPE,
     attribute7                   WSH_DEL_DETAILS_INTERFACE.attribute7%TYPE,
     attribute8                   WSH_DEL_DETAILS_INTERFACE.attribute8%TYPE,
     attribute9                   WSH_DEL_DETAILS_INTERFACE.attribute9%TYPE,
     attribute10                  WSH_DEL_DETAILS_INTERFACE.attribute10%TYPE,
     attribute11                  WSH_DEL_DETAILS_INTERFACE.attribute11%TYPE,
     attribute12                  WSH_DEL_DETAILS_INTERFACE.attribute12%TYPE,
     attribute13                  WSH_DEL_DETAILS_INTERFACE.attribute13%TYPE,
     attribute14                  WSH_DEL_DETAILS_INTERFACE.attribute14%TYPE,
     attribute15                  WSH_DEL_DETAILS_INTERFACE.attribute15%TYPE,
     container_name               WSH_DEL_DETAILS_INTERFACE.container_name%TYPE,
     item_number                  WSH_DEL_DETAILS_INTERFACE.item_number%TYPE,
     item_description             WSH_DEL_DETAILS_INTERFACE.item_description%TYPE,
     gross_weight                 WSH_DEL_DETAILS_INTERFACE.gross_weight%TYPE,
     net_weight                   WSH_DEL_DETAILS_INTERFACE.net_weight%TYPE,
     weight_uom_code              WSH_DEL_DETAILS_INTERFACE.weight_uom_code%TYPE,
     volume                       WSH_DEL_DETAILS_INTERFACE.volume%TYPE,
     volume_uom_code              WSH_DEL_DETAILS_INTERFACE.volume_uom_code%TYPE,
     wv_frozen_flag               WSH_DEL_DETAILS_INTERFACE.wv_frozen_flag%TYPE,
     filled_volume                WSH_DEL_DETAILS_INTERFACE.filled_volume%TYPE,
     fill_percent                 WSH_DEL_DETAILS_INTERFACE.fill_percent%TYPE,
     seal_code                    WSH_DEL_DETAILS_INTERFACE.seal_code%TYPE,
     packing_instructions         WSH_DEL_DETAILS_INTERFACE.packing_instructions%TYPE,
     shipping_instructions        WSH_DEL_DETAILS_INTERFACE.shipping_instructions%TYPE,
     tracking_number              WSH_DEL_DETAILS_INTERFACE.tracking_number%TYPE,
     Container_Freight_Tab        Freight_Cost_Rec_Tab );

TYPE Container_Rec_Tab IS TABLE OF Container_Rec_Type index by binary_integer;

TYPE Master_Container_Rec_Type IS RECORD (
     delivery_detail_number       WSH_DEL_DETAILS_INTERFACE.delivery_detail_id%TYPE,
     attribute_category           WSH_DEL_DETAILS_INTERFACE.attribute_category%TYPE,
     attribute1                   WSH_DEL_DETAILS_INTERFACE.attribute1%TYPE,
     attribute2                   WSH_DEL_DETAILS_INTERFACE.attribute2%TYPE,
     attribute3                   WSH_DEL_DETAILS_INTERFACE.attribute3%TYPE,
     attribute4                   WSH_DEL_DETAILS_INTERFACE.attribute4%TYPE,
     attribute5                   WSH_DEL_DETAILS_INTERFACE.attribute5%TYPE,
     attribute6                   WSH_DEL_DETAILS_INTERFACE.attribute6%TYPE,
     attribute7                   WSH_DEL_DETAILS_INTERFACE.attribute7%TYPE,
     attribute8                   WSH_DEL_DETAILS_INTERFACE.attribute8%TYPE,
     attribute9                   WSH_DEL_DETAILS_INTERFACE.attribute9%TYPE,
     attribute10                  WSH_DEL_DETAILS_INTERFACE.attribute10%TYPE,
     attribute11                  WSH_DEL_DETAILS_INTERFACE.attribute11%TYPE,
     attribute12                  WSH_DEL_DETAILS_INTERFACE.attribute12%TYPE,
     attribute13                  WSH_DEL_DETAILS_INTERFACE.attribute13%TYPE,
     attribute14                  WSH_DEL_DETAILS_INTERFACE.attribute14%TYPE,
     attribute15                  WSH_DEL_DETAILS_INTERFACE.attribute15%TYPE,
     container_name               WSH_DEL_DETAILS_INTERFACE.container_name%TYPE,
     item_number                  WSH_DEL_DETAILS_INTERFACE.item_number%TYPE,
     item_description             WSH_DEL_DETAILS_INTERFACE.item_description%TYPE,
     gross_weight                 WSH_DEL_DETAILS_INTERFACE.gross_weight%TYPE,
     net_weight                   WSH_DEL_DETAILS_INTERFACE.net_weight%TYPE,
     weight_uom_code              WSH_DEL_DETAILS_INTERFACE.weight_uom_code%TYPE,
     volume                       WSH_DEL_DETAILS_INTERFACE.volume%TYPE,
     volume_uom_code              WSH_DEL_DETAILS_INTERFACE.volume_uom_code%TYPE,
     wv_frozen_flag               WSH_DEL_DETAILS_INTERFACE.wv_frozen_flag%TYPE,
     filled_volume                WSH_DEL_DETAILS_INTERFACE.filled_volume%TYPE,
     fill_percent                 WSH_DEL_DETAILS_INTERFACE.fill_percent%TYPE,
     seal_code                    WSH_DEL_DETAILS_INTERFACE.seal_code%TYPE,
     packing_instructions         WSH_DEL_DETAILS_INTERFACE.packing_instructions%TYPE,
     shipping_instructions        WSH_DEL_DETAILS_INTERFACE.shipping_instructions%TYPE,
     tracking_number              WSH_DEL_DETAILS_INTERFACE.tracking_number%TYPE,
     Master_Container_Freight_Tab Freight_Cost_Rec_Tab,
     Container_Tab                Container_Rec_Tab );

TYPE Master_Container_Rec_Tab IS TABLE OF Master_Container_Rec_Type index by binary_integer;

TYPE Delivery_Details_Rec_Type IS RECORD (
     item_number                   WSH_DEL_DETAILS_INTERFACE.item_number%TYPE,
     requested_quantity            WSH_DEL_DETAILS_INTERFACE.requested_quantity%TYPE,
     requested_quantity_uom        WSH_DEL_DETAILS_INTERFACE.requested_quantity_uom%TYPE,
     item_description              WSH_DEL_DETAILS_INTERFACE.item_description%TYPE,
     revision                      WSH_DEL_DETAILS_INTERFACE.revision%TYPE,
     shipped_quantity              WSH_DEL_DETAILS_INTERFACE.shipped_quantity%TYPE,
     volume                        WSH_DEL_DETAILS_INTERFACE.volume%TYPE,
     volume_uom_code               WSH_DEL_DETAILS_INTERFACE.volume_uom_code%TYPE,
     gross_weight                  WSH_DEL_DETAILS_INTERFACE.gross_weight%TYPE,
     net_weight                    WSH_DEL_DETAILS_INTERFACE.net_weight%TYPE,
     weight_uom_code               WSH_DEL_DETAILS_INTERFACE.weight_uom_code%TYPE,
     delivery_detail_number        WSH_DEL_DETAILS_INTERFACE.delivery_detail_id%TYPE,
     source_line_id                WSH_DEL_DETAILS_INTERFACE.source_line_id%TYPE,
     load_seq_number               WSH_DEL_DETAILS_INTERFACE.load_seq_number%TYPE,
     subinventory                  WSH_DEL_DETAILS_INTERFACE.subinventory%TYPE,
     lot_number                    WSH_DEL_DETAILS_INTERFACE.lot_number%TYPE,
     preferred_grade               WSH_DEL_DETAILS_INTERFACE.preferred_grade%TYPE,
     serial_number                 WSH_DEL_DETAILS_INTERFACE.serial_number%TYPE,
     to_serial_number              WSH_DEL_DETAILS_INTERFACE.to_serial_number%TYPE,
     attribute_category            WSH_DEL_DETAILS_INTERFACE.attribute_category%TYPE,
     attribute1                    WSH_DEL_DETAILS_INTERFACE.attribute1%TYPE,
     attribute2                    WSH_DEL_DETAILS_INTERFACE.attribute2%TYPE,
     attribute3                    WSH_DEL_DETAILS_INTERFACE.attribute3%TYPE,
     attribute4                    WSH_DEL_DETAILS_INTERFACE.attribute4%TYPE,
     attribute5                    WSH_DEL_DETAILS_INTERFACE.attribute5%TYPE,
     attribute6                    WSH_DEL_DETAILS_INTERFACE.attribute6%TYPE,
     attribute7                    WSH_DEL_DETAILS_INTERFACE.attribute7%TYPE,
     attribute8                    WSH_DEL_DETAILS_INTERFACE.attribute8%TYPE,
     attribute9                    WSH_DEL_DETAILS_INTERFACE.attribute9%TYPE,
     attribute10                   WSH_DEL_DETAILS_INTERFACE.attribute10%TYPE,
     attribute11                   WSH_DEL_DETAILS_INTERFACE.attribute11%TYPE,
     attribute12                   WSH_DEL_DETAILS_INTERFACE.attribute12%TYPE,
     attribute13                   WSH_DEL_DETAILS_INTERFACE.attribute13%TYPE,
     attribute14                   WSH_DEL_DETAILS_INTERFACE.attribute14%TYPE,
     attribute15                   WSH_DEL_DETAILS_INTERFACE.attribute15%TYPE,
     source_header_number          WSH_DEL_DETAILS_INTERFACE.source_header_number%TYPE,
     line_direction                WSH_DEL_DETAILS_INTERFACE.line_direction%TYPE,
     wv_frozen_flag                WSH_DEL_DETAILS_INTERFACE.wv_frozen_flag%TYPE,
     cycle_count_quantity          WSH_DEL_DETAILS_INTERFACE.cycle_count_quantity%TYPE,
     locator_code                  WSH_DEL_DETAILS_INTERFACE.locator_code%TYPE,
     parent_delivery_detail_number NUMBER,
     Detail_Freight_Tab            Freight_Cost_Rec_Tab );

TYPE Delivery_Details_Rec_Tab IS TABLE OF Delivery_Details_Rec_Type index by binary_integer;

TYPE Delivery_Rec_Type IS RECORD (
     document_number              WSH_TRANSACTIONS_HISTORY.document_number%TYPE,
     name                         WSH_NEW_DEL_INTERFACE.name%TYPE,
     description                  WSH_NEW_DEL_INTERFACE.description%TYPE,
     initial_pickup_date          WSH_NEW_DEL_INTERFACE.initial_pickup_date%TYPE,
     ultimate_dropoff_date        WSH_NEW_DEL_INTERFACE.ultimate_dropoff_date%TYPE,
     freight_terms_code           WSH_NEW_DEL_INTERFACE.freight_terms_code%TYPE,
     gross_weight                 WSH_NEW_DEL_INTERFACE.gross_weight%TYPE,
     net_weight                   WSH_NEW_DEL_INTERFACE.net_weight%TYPE,
     weight_uom_code              WSH_NEW_DEL_INTERFACE.weight_uom_code%TYPE,
     number_of_lpn                WSH_NEW_DEL_INTERFACE.number_of_lpn%TYPE,
     volume                       WSH_NEW_DEL_INTERFACE.volume%TYPE,
     volume_uom_code              WSH_NEW_DEL_INTERFACE.volume_uom_code%TYPE,
     shipping_marks               WSH_NEW_DEL_INTERFACE.shipping_marks%TYPE,
     fob_code                     WSH_NEW_DEL_INTERFACE.fob_code%TYPE,
     ship_method_code             WSH_NEW_DEL_INTERFACE.ship_method_code%TYPE,
     organization_code            WSH_NEW_DEL_INTERFACE.organization_code%TYPE,
     loading_sequence             WSH_NEW_DEL_INTERFACE.loading_sequence%TYPE,
     attribute_category           WSH_NEW_DEL_INTERFACE.attribute_category%TYPE,
     attribute1                   WSH_NEW_DEL_INTERFACE.attribute1%TYPE,
     attribute2                   WSH_NEW_DEL_INTERFACE.attribute2%TYPE,
     attribute3                   WSH_NEW_DEL_INTERFACE.attribute3%TYPE,
     attribute4                   WSH_NEW_DEL_INTERFACE.attribute4%TYPE,
     attribute5                   WSH_NEW_DEL_INTERFACE.attribute5%TYPE,
     attribute6                   WSH_NEW_DEL_INTERFACE.attribute6%TYPE,
     attribute7                   WSH_NEW_DEL_INTERFACE.attribute7%TYPE,
     attribute8                   WSH_NEW_DEL_INTERFACE.attribute8%TYPE,
     attribute9                   WSH_NEW_DEL_INTERFACE.attribute9%TYPE,
     attribute10                  WSH_NEW_DEL_INTERFACE.attribute10%TYPE,
     attribute11                  WSH_NEW_DEL_INTERFACE.attribute11%TYPE,
     attribute12                  WSH_NEW_DEL_INTERFACE.attribute12%TYPE,
     attribute13                  WSH_NEW_DEL_INTERFACE.attribute13%TYPE,
     attribute14                  WSH_NEW_DEL_INTERFACE.attribute14%TYPE,
     attribute15                  WSH_NEW_DEL_INTERFACE.attribute15%TYPE,
     waybill                      WSH_NEW_DEL_INTERFACE.waybill%TYPE,
     carrier_code                 WSH_NEW_DEL_INTERFACE.carrier_code%TYPE,
     service_level                WSH_NEW_DEL_INTERFACE.service_level%TYPE,
     mode_of_transport            WSH_NEW_DEL_INTERFACE.mode_of_transport%TYPE,
     wv_frozen_flag               WSH_NEW_DEL_INTERFACE.wv_frozen_flag%TYPE,
     shipment_direction           WSH_NEW_DEL_INTERFACE.shipment_direction%TYPE,
     delivered_date               WSH_NEW_DEL_INTERFACE.delivered_date%TYPE,
     customer_name                WSH_NEW_DEL_INTERFACE.customer_name%TYPE,
     INITIAL_PICKUP_LOCATION_CODE WSH_NEW_DEL_INTERFACE.INITIAL_PICKUP_LOCATION_CODE%TYPE,
     SHIP_TO_CUSTOMER_NAME        WSH_NEW_DEL_INTERFACE.SHIP_TO_CUSTOMER_NAME%TYPE,
     SHIP_TO_ADDRESS1             WSH_NEW_DEL_INTERFACE.SHIP_TO_ADDRESS1%TYPE,
     SHIP_TO_ADDRESS2             WSH_NEW_DEL_INTERFACE.SHIP_TO_ADDRESS2%TYPE,
     SHIP_TO_ADDRESS3             WSH_NEW_DEL_INTERFACE.SHIP_TO_ADDRESS3%TYPE,
     SHIP_TO_ADDRESS4             WSH_NEW_DEL_INTERFACE.SHIP_TO_ADDRESS4%TYPE,
     SHIP_TO_CITY                 WSH_NEW_DEL_INTERFACE.SHIP_TO_CITY%TYPE,
     SHIP_TO_STATE                WSH_NEW_DEL_INTERFACE.SHIP_TO_STATE%TYPE,
     SHIP_TO_COUNTRY              WSH_NEW_DEL_INTERFACE.SHIP_TO_COUNTRY%TYPE,
     SHIP_TO_POSTAL_CODE          WSH_NEW_DEL_INTERFACE.SHIP_TO_POSTAL_CODE%TYPE,
     actual_departure_date        WSH_TRIP_STOPS_INTERFACE.actual_departure_date%TYPE,
     actual_arrival_date          WSH_TRIP_STOPS_INTERFACE.actual_arrival_date%TYPE,
     departure_seal_code          WSH_TRIP_STOPS_INTERFACE.departure_seal_code%TYPE,
     vehicle_number               WSH_TRIPS_INTERFACE.vehicle_number%TYPE,
     vehicle_num_prefix           WSH_TRIPS_INTERFACE.vehicle_num_prefix%TYPE,
     route_id                     WSH_TRIPS_INTERFACE.route_id%TYPE,
     routing_instructions         WSH_TRIPS_INTERFACE.routing_instructions%TYPE,
     operator                     WSH_TRIPS_INTERFACE.operator%TYPE,
     delivery_details_tab         Delivery_Details_Rec_Tab,
     container_tab                Master_Container_Rec_Tab,
     delivery_freight_tab         Freight_Cost_Rec_Tab );

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Shipment_Advice         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_action                'CREATE'
--             p_delivery_rec          Attributes for the Shipment Advice entity
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
--========================================================================
/*#
 * Query or Create or update or delete a shipment request with information specified in p_shipment_request_info
 * @param p_api_version_number    version number of the API
 * @param p_init_msg_list         messages will be initialized if set as true
 * @param p_delivery_rec          Attributes for the Shipment Advice entity
 * @param p_action                action to be performed, could be 'CREATE'.
 * @param p_commit                commit flag
 * @param x_return_status         return status of the API
 * @param x_msg_count             number of messages, if any
 * @param x_msg_data              message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Shipment Advice
 */
PROCEDURE Shipment_Advice(
                p_api_version_number     IN  NUMBER,
                p_init_msg_list          IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
                p_delivery_rec           IN  Delivery_Rec_Type,
                p_action                 IN VARCHAR2,
                p_commit                 IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                x_return_status          OUT NOCOPY    VARCHAR2,
                x_msg_count              OUT NOCOPY    NUMBER,
                x_msg_data               OUT NOCOPY    VARCHAR2);

--========================================================================
-- PROCEDURE : Process_Shipment_Advice         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_process_mode          'ONLINE' or 'CONCURRENT'
--             p_log_level             0 or 1 to control the log messages
--             p_transaction_status    Status of Shipment Advice
--             p_from_document_number  From Document Number
--             p_to_document_number    To Document Number
--             p_from_creation_date    From Creation Date
--             p_to_creation_date      To Creation Date
--             p_transaction_id        Trasaction Id of Transaction History to be processed
--             x_return_status         return status
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Processes Shipment Advice as per criteria
--             specified in p_transaction_status,p_from_document_number,
--             p_to_document_number,p_from_creation_date and p_to_creation_date
--========================================================================

/*#
 * Processes shipment advices with information specified in prams
 * @param p_api_version_number   version number of the API
 * @param p_init_msg_list        messages will be initialized if set as true
 * @param p_commit               Commit flag
 * @param p_process_mode         ONLINE or CONCURRENT to process shipment requests
 * @param p_log_level            Controls the log messages generated
 * @param p_transaction_status   Status of Shipment Advice
 * @param p_from_document_number From Document Number
 * @param p_to_document_number   To Document Number
 * @param p_from_creation_date   From Creation Date
 * @param p_to_creation_date     To Creation Date
 * @param p_transaction_id       Trasaction Id of Transaction History to be processed
 * @param x_request_id           Concurrent request Id of the 'Process Shipment Requests' program
 * @param x_return_status        return status of the API
 * @param x_msg_count            number of messages, if any
 * @param x_msg_data             message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Shipment Advice
 */

PROCEDURE Process_Shipment_Advice (
                p_api_version_number   IN  NUMBER,
                p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
                p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                p_process_mode         IN  VARCHAR2 DEFAULT 'CONCURRENT',
                p_log_level            IN  NUMBER   DEFAULT 0,
                p_transaction_status   IN  VARCHAR2,
                p_from_document_number IN  VARCHAR2,
                p_to_document_number   IN  VARCHAR2,
                p_from_creation_date   IN  DATE,
                p_to_creation_date     IN  DATE,
                p_transaction_id       IN  NUMBER,
                x_request_id           OUT NOCOPY NUMBER,
                x_return_status        OUT NOCOPY VARCHAR2,
                x_msg_count            OUT NOCOPY    NUMBER,
                x_msg_data             OUT NOCOPY    VARCHAR2);

END WSH_SHIPMENT_ADVICE_PUB;

/
