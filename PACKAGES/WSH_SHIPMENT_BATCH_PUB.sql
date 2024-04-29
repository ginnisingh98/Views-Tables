--------------------------------------------------------
--  DDL for Package WSH_SHIPMENT_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPMENT_BATCH_PUB" AUTHID CURRENT_USER as
/* $Header: WSHSBPBS.pls 120.0.12010000.1 2010/02/25 17:19:52 sankarun noship $ */
/*#
 * This is the public interface for creating Shipment Batches. It allows
 * grouping of eligible delivery lines into a Shipment Batch.
 * @rep:scope public
 * @rep:product WSH
 * @rep:displayname Shipment Batch
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WSH_SHIPMENT_BATCH
 */

--===================
-- PUBLIC VARS
--===================

--===================
-- PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Shipment_Batch         PUBLIC
--
-- PARAMETERS: p_api_version_number    version number of the API
--             p_init_msg_list         messages will be initialized if set as true
--             p_process_mode          'ONLINE' or 'CONCURRENT', Default Value 'CONCURRENT'
--             p_organization_id       Organization Id
--             p_customer_id           Customer Id
--             p_ship_to_location_id   Ship From Location
--             p_transaction_type_id   Sales Order Type Id
--             p_from_order_number     From Sales Order Number
--             p_to_order_number       To Sales Order Number
--             p_from_request_date     From Request Date
--             p_to_request_date       To Request Date
--             p_from_schedule_date    From Schedule Date
--             p_to_schedule_date      To Schedule Date
--             p_shipment_priority     Shipment Priority Code
--             p_include_internal_so   Include Internal Sales Order
--             p_log_level             0 or 1 to control the log messages, Default Value 0
--             p_commit                Commit Flag
--             x_request_id            Concurrent Request Id submitted for 'Create Shipment Batches' program
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Public API to create shipment batches.
--
--========================================================================

/*#
 * Creates Shipment Batches
 * @param p_api_version_number    version number of the API
 * @param p_init_msg_list         messages will be initialized if set as true
 * @param p_process_mode          ONLINE or CONCURRENT mode to create shipment batches. Default value 'CONCURRENT'
 * @param p_organization_id       Organization Id
 * @param p_customer_id           Customer Id
 * @param p_ship_to_location_id   Ship From Location
 * @param p_transaction_type_id   Sales Order Type Id
 * @param p_from_order_number     From Sales Order Number
 * @param p_to_order_number       To Sales Order Number
 * @param p_from_request_date     From Request Date
 * @param p_to_request_date       To Request Date
 * @param p_from_schedule_date    From Schedule Date
 * @param p_to_schedule_date      To Schedule Date
 * @param p_shipment_priority     Shipment Priority Code
 * @param p_include_internal_so   Include Internal Sales Order
 * @param p_log_level             Controls the log messages generated, Default Value 0
 * @param p_commit                commit flag
 * @param x_request_id            Concurrent request Id of the 'Create Shipment Batches' program
 * @param x_return_status         return status of the API
 * @param x_msg_count             number of messages, if any
 * @param x_msg_data              message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Shipment Batches
 */
PROCEDURE Create_Shipment_Batch(
          p_api_version_number   IN  NUMBER,
          p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
          p_process_mode         IN  VARCHAR2 DEFAULT 'CONCURRENT',
          p_organization_id      IN  NUMBER,
          p_customer_id          IN  NUMBER,
          p_ship_to_location_id  IN  NUMBER,
          p_transaction_type_id  IN  NUMBER,
          p_from_order_number    IN  VARCHAR2,
          p_to_order_number      IN  VARCHAR2,
          p_from_request_date    IN  DATE,
          p_to_request_date      IN  DATE,
          p_from_schedule_date   IN  DATE,
          p_to_schedule_date     IN  DATE,
          p_shipment_priority    IN  VARCHAR,
          p_include_internal_so  IN  VARCHAR   DEFAULT 'N',
          p_log_level            IN  NUMBER    DEFAULT 0,
          p_commit               IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
          x_request_id           OUT NOCOPY    NUMBER,
          x_return_status        OUT NOCOPY    VARCHAR2,
          x_msg_count            OUT NOCOPY    NUMBER,
          x_msg_data             OUT NOCOPY    VARCHAR2 );

--
--========================================================================
-- PROCEDURE : Cancel_Line         PUBLIC
--
-- PARAMETERS: p_api_version_number    version number of the API
--             p_init_msg_list         messages will be initialized if set as true
--             p_commit                commit Flag
--             p_document_number       document number
--             p_line_number           line number
--             p_cancel_quantity       quantity to unassign from Shipment batch
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Public API to unassign delivery line from a Shipment Batch.
--
--========================================================================

/*#
 * Unassing delivery line from Shipment Batch
 * @param p_api_version_number    version number of the API
 * @param p_init_msg_list         messages will be initialized if set as true
 * @param p_commit                commit flag
 * @param p_document_number       document number
 * @param p_line_number           line number
 * @param p_cancel_quantity       quantity to unassign from Shipment Batch
 * @param x_return_status         return status of the API
 * @param x_msg_count             number of messages, if any
 * @param x_msg_data              message text, if any
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Unassign Delivery Line From Shipment Batch
 */
PROCEDURE Cancel_Line(
          p_api_version_number   IN  NUMBER,
          p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_TRUE,
          p_commit               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
          p_document_number      IN  VARCHAR2,
          p_line_number          IN  VARCHAR2,
          p_cancel_quantity      IN  NUMBER,
          x_return_status        OUT NOCOPY    VARCHAR2,
          x_msg_count            OUT NOCOPY    NUMBER,
          x_msg_data             OUT NOCOPY    VARCHAR2 );

END WSH_SHIPMENT_BATCH_PUB;

/
