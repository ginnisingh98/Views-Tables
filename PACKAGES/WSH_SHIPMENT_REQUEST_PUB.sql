--------------------------------------------------------
--  DDL for Package WSH_SHIPMENT_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPMENT_REQUEST_PUB" AUTHID CURRENT_USER as
/* $Header: WSHSRPBS.pls 120.0.12010000.3 2009/12/03 12:19:56 mvudugul noship $ */
/*#
 * This is the public interface for the Shipment Request entity. It allows
 * execution of various Shipment Request functions, including creation, update
 * of Shipment Request and other actions.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Shipment Request
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_SHIPMENT_REQUEST
 */

--===================
-- PUBLIC VARS
--===================

TYPE Shipment_Details_Rec_Type IS RECORD (
   delivery_detail_interface_id   WSH_DEL_DETAILS_INTERFACE.delivery_detail_interface_id%TYPE,
   line_number                    WSH_DEL_DETAILS_INTERFACE.line_number%TYPE,
   item_number                    WSH_DEL_DETAILS_INTERFACE.item_number%TYPE,
   inventory_item_id              WSH_DEL_DETAILS_INTERFACE.inventory_item_id%TYPE,
   item_description               WSH_DEL_DETAILS_INTERFACE.item_description%TYPE,
   requested_quantity             WSH_DEL_DETAILS_INTERFACE.requested_quantity%TYPE,
   requested_quantity_uom         WSH_DEL_DETAILS_INTERFACE.requested_quantity_uom%TYPE,
   customer_item_number           WSH_DEL_DETAILS_INTERFACE.customer_item_number%TYPE,
   customer_item_id               WSH_DEL_DETAILS_INTERFACE.customer_item_id%TYPE,
   date_requested                 WSH_DEL_DETAILS_INTERFACE.date_requested%TYPE,
   date_scheduled                 WSH_DEL_DETAILS_INTERFACE.date_scheduled%TYPE,
   ship_tolerance_above           WSH_DEL_DETAILS_INTERFACE.ship_tolerance_above%TYPE,
   ship_tolerance_below           WSH_DEL_DETAILS_INTERFACE.ship_tolerance_below%TYPE,
   packing_instructions           WSH_DEL_DETAILS_INTERFACE.packing_instructions%TYPE,
   shipping_instructions          WSH_DEL_DETAILS_INTERFACE.shipping_instructions%TYPE,
   shipment_priority_code         WSH_DEL_DETAILS_INTERFACE.shipment_priority_code%TYPE,
   ship_set_name                  WSH_DEL_DETAILS_INTERFACE.ship_set_name%TYPE,
   subinventory                   WSH_DEL_DETAILS_INTERFACE.subinventory%TYPE,
   revision                       WSH_DEL_DETAILS_INTERFACE.revision%TYPE,
   locator_code                   WSH_DEL_DETAILS_INTERFACE.locator_code%TYPE,
   locator_id                     WSH_DEL_DETAILS_INTERFACE.locator_id%TYPE,
   lot_number                     WSH_DEL_DETAILS_INTERFACE.lot_number%TYPE,
   unit_selling_price             WSH_DEL_DETAILS_INTERFACE.unit_selling_price%TYPE,
   currency_code                  WSH_DEL_DETAILS_INTERFACE.currency_code%TYPE,
   earliest_pickup_date           WSH_DEL_DETAILS_INTERFACE.earliest_pickup_date%TYPE,
   latest_pickup_date             WSH_DEL_DETAILS_INTERFACE.latest_pickup_date%TYPE,
   earliest_dropoff_date          WSH_DEL_DETAILS_INTERFACE.earliest_dropoff_date%TYPE,
   latest_dropoff_date            WSH_DEL_DETAILS_INTERFACE.latest_dropoff_date%TYPE,
   cust_po_number                 WSH_DEL_DETAILS_INTERFACE.cust_po_number%TYPE,
   source_header_number           WSH_DEL_DETAILS_INTERFACE.source_header_number%TYPE,
   source_line_number             WSH_DEL_DETAILS_INTERFACE.source_line_number%TYPE,
   src_requested_quantity         WSH_DEL_DETAILS_INTERFACE.src_requested_quantity%TYPE,
   src_requested_quantity_uom     WSH_DEL_DETAILS_INTERFACE.src_requested_quantity_uom%TYPE);

TYPE Shipment_Details_Rec_Tab IS TABLE OF Shipment_Details_Rec_Type index by binary_integer;

TYPE Shipment_Request_Rec_Type IS RECORD (
   delivery_interface_id          WSH_NEW_DEL_INTERFACE.delivery_interface_id%TYPE,
   transaction_id                 WSH_TRANSACTIONS_HISTORY.transaction_id%TYPE,
   document_number                NUMBER,
   document_revision              WSH_TRANSACTIONS_HISTORY.document_revision%TYPE,
   action_type                    WSH_TRANSACTIONS_HISTORY.action_type%TYPE,
   organization_code              WSH_NEW_DEL_INTERFACE.organization_code%TYPE,
   customer_id                    WSH_NEW_DEL_INTERFACE.customer_id%TYPE,
   customer_name                  WSH_NEW_DEL_INTERFACE.customer_name%TYPE,
   ship_to_customer_id            WSH_NEW_DEL_INTERFACE.ship_to_customer_id%TYPE,
   ship_to_customer_name          WSH_NEW_DEL_INTERFACE.ship_to_customer_name%TYPE,
   ship_to_address_id             WSH_NEW_DEL_INTERFACE.ship_to_address_id%TYPE,
   ship_to_address1               WSH_NEW_DEL_INTERFACE.ship_to_address1%TYPE,
   ship_to_address2               WSH_NEW_DEL_INTERFACE.ship_to_address2%TYPE,
   ship_to_address3               WSH_NEW_DEL_INTERFACE.ship_to_address3%TYPE,
   ship_to_address4               WSH_NEW_DEL_INTERFACE.ship_to_address4%TYPE,
   ship_to_city                   WSH_NEW_DEL_INTERFACE.ship_to_city%TYPE,
   ship_to_state                  WSH_NEW_DEL_INTERFACE.ship_to_state%TYPE,
   ship_to_country                WSH_NEW_DEL_INTERFACE.ship_to_country%TYPE,
   ship_to_postal_code            WSH_NEW_DEL_INTERFACE.ship_to_postal_code%TYPE,
   ship_to_contact_id             WSH_NEW_DEL_INTERFACE.ship_to_contact_id%TYPE,
   ship_to_contact_name           WSH_NEW_DEL_INTERFACE.ship_to_contact_name%TYPE,
   ship_to_contact_phone          WSH_NEW_DEL_INTERFACE.ship_to_contact_phone%TYPE,
   invoice_to_customer_id         WSH_NEW_DEL_INTERFACE.invoice_to_customer_id%TYPE,
   invoice_to_customer_name       WSH_NEW_DEL_INTERFACE.invoice_to_customer_name%TYPE,
   invoice_to_address_id          WSH_NEW_DEL_INTERFACE.invoice_to_address_id%TYPE,
   invoice_to_address1            WSH_NEW_DEL_INTERFACE.invoice_to_address1%TYPE,
   invoice_to_address2            WSH_NEW_DEL_INTERFACE.invoice_to_address2%TYPE,
   invoice_to_address3            WSH_NEW_DEL_INTERFACE.invoice_to_address3%TYPE,
   invoice_to_address4            WSH_NEW_DEL_INTERFACE.invoice_to_address4%TYPE,
   invoice_to_city                WSH_NEW_DEL_INTERFACE.invoice_to_city%TYPE,
   invoice_to_state               WSH_NEW_DEL_INTERFACE.invoice_to_state%TYPE,
   invoice_to_country             WSH_NEW_DEL_INTERFACE.invoice_to_country%TYPE,
   invoice_to_postal_code         WSH_NEW_DEL_INTERFACE.invoice_to_postal_code%TYPE,
   invoice_to_contact_id          WSH_NEW_DEL_INTERFACE.invoice_to_contact_id%TYPE,
   invoice_to_contact_name        WSH_NEW_DEL_INTERFACE.invoice_to_contact_name%TYPE,
   invoice_to_contact_phone       WSH_NEW_DEL_INTERFACE.invoice_to_contact_phone%TYPE,
   deliver_to_customer_id         WSH_NEW_DEL_INTERFACE.deliver_to_customer_id%TYPE,
   deliver_to_customer_name       WSH_NEW_DEL_INTERFACE.deliver_to_customer_name%TYPE,
   deliver_to_address_id          WSH_NEW_DEL_INTERFACE.deliver_to_address_id%TYPE,
   deliver_to_address1            WSH_NEW_DEL_INTERFACE.deliver_to_address1%TYPE,
   deliver_to_address2            WSH_NEW_DEL_INTERFACE.deliver_to_address2%TYPE,
   deliver_to_address3            WSH_NEW_DEL_INTERFACE.deliver_to_address3%TYPE,
   deliver_to_address4            WSH_NEW_DEL_INTERFACE.deliver_to_address4%TYPE,
   deliver_to_city                WSH_NEW_DEL_INTERFACE.deliver_to_city%TYPE,
   deliver_to_state               WSH_NEW_DEL_INTERFACE.deliver_to_state%TYPE,
   deliver_to_country             WSH_NEW_DEL_INTERFACE.deliver_to_country%TYPE,
   deliver_to_postal_code         WSH_NEW_DEL_INTERFACE.deliver_to_postal_code%TYPE,
   deliver_to_contact_id          WSH_NEW_DEL_INTERFACE.deliver_to_contact_id%TYPE,
   deliver_to_contact_name        WSH_NEW_DEL_INTERFACE.deliver_to_contact_name%TYPE,
   deliver_to_contact_phone       WSH_NEW_DEL_INTERFACE.deliver_to_contact_phone%TYPE,
   carrier_code                   WSH_NEW_DEL_INTERFACE.carrier_code%TYPE,
   service_level                  WSH_NEW_DEL_INTERFACE.service_level%TYPE,
   mode_of_transport              WSH_NEW_DEL_INTERFACE.mode_of_transport%TYPE,
   freight_terms_code             WSH_NEW_DEL_INTERFACE.freight_terms_code%TYPE,
   fob_code                       WSH_NEW_DEL_INTERFACE.fob_code%TYPE,
   currency_code                  WSH_NEW_DEL_INTERFACE.currency_code%TYPE,
   transaction_type_id            WSH_NEW_DEL_INTERFACE.transaction_type_id%TYPE,
   price_list_id                  WSH_NEW_DEL_INTERFACE.price_list_id%TYPE,
   client_code                    WSH_NEW_DEL_INTERFACE.client_code%TYPE, --LSP PROJECT
   shipment_details_tab           Shipment_Details_Rec_Tab
);

TYPE Criteria_Rec_Type IS RECORD (
   shipment_request_status        WSH_TRANSACTIONS_HISTORY.transaction_status%TYPE,
   from_shipment_request_number   NUMBER,
   to_shipment_request_number     NUMBER,
   from_shipment_request_date     WSH_TRANSACTIONS_HISTORY.creation_date%TYPE,
   to_shipment_request_date       WSH_TRANSACTIONS_HISTORY.creation_date%TYPE,
   transaction_id                 WSH_TRANSACTIONS_HISTORY.transaction_id%TYPE,
   client_code                    WSH_NEW_DEL_INTERFACE.client_code%TYPE); -- LSP PROJECT : Added Client_code

TYPE Interface_Errors_Rec_Type IS RECORD (
   document_number                WSH_TRANSACTIONS_HISTORY.document_number%TYPE,
   document_revision              WSH_TRANSACTIONS_HISTORY.document_revision%TYPE,
   line_number                    WSH_DEL_DETAILS_INTERFACE.line_number%TYPE,
   error_message                  WSH_INTERFACE_ERRORS.error_message%TYPE);



TYPE Interface_Errors_Rec_Tab IS TABLE OF Interface_Errors_Rec_Type index by binary_integer;


--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Shipment_Request         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_action_code           'QUERY', 'CREATE', 'UPDATE' or 'DELETE'
--	           p_shipment_request_info Attributes for the shipment request entity
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Creates or Updates or Deletes Shipment Request
--             specified in p_shipment_request_info
--========================================================================

/*#
 * Query or Create or update or delete a shipment request with information specified in p_shipment_request_info
 * @param p_api_version_number    version number of the API
 * @param p_init_msg_list         messages will be initialized if set as true
 * @param p_action_code           action to be performed, could be 'QUERY', 'CREATE' or 'UPDATE' or 'DELETE'
 * @param p_shipment_request_info attributes for the shipment request entity
 * @param x_interface_errors_info error messages for the shipment request entity, if any
 * @param p_commit                commit flag
 * @param x_return_status         return status of the API
 * @param x_msg_count             number of messages, if any
 * @param x_msg_data              message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Query Create Update Delete Shipment Request
 */
  PROCEDURE Shipment_Request
  ( p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_TRUE,
    p_action_code            IN   VARCHAR2 DEFAULT NULL,
    p_shipment_request_info  IN   OUT NOCOPY Shipment_Request_Rec_Type,
    x_interface_errors_info  OUT NOCOPY Interface_Errors_Rec_Tab,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2);

--========================================================================
-- PROCEDURE : Process_Shipment_Requests         PUBLIC
--
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             p_process_mode          'ONLINE' or 'CONCURRENT'
--	           p_criteria_info         Attributes for the Process Shipment Request criteria
--	           p_log_level             0 or 1 to control the log messages
--             x_request_id            Concurrent request id when p_process_mode is 'CONCURRENT'
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Processes Shipment Requests as per criteria
--             specified in p_criteria_info
--========================================================================

/*#
 * Processes shipment requests with information specified in p_criteria_info
 * @param p_api_version_number  version number of the API
 * @param p_init_msg_list       messages will be initialized if set as true
 * @param p_process_mode        ONLINE or CONCURRENT to process shipment requests
 * @param p_criteria_info       criteria to select shipment requests
 * @param p_log_level           Controls the log messages generated
 * @param p_commit              Commit flag
 * @param x_request_id          Concurrent request Id of the 'Process Shipment Requests' program
 * @param x_return_status       return status of the API
 * @param x_msg_count           number of messages, if any
 * @param x_msg_data            message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Shipment Requests
 */
  PROCEDURE Process_Shipment_Requests
  ( p_api_version_number     IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 DEFAULT  FND_API.G_TRUE,
    p_process_mode           IN  VARCHAR2 DEFAULT 'CONCURRENT',
    p_criteria_info          IN  Criteria_Rec_Type,
    p_log_level              IN  NUMBER   DEFAULT 0,
    p_commit                 IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_request_id             OUT NOCOPY    NUMBER,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2);

END WSH_SHIPMENT_REQUEST_PUB;

/
