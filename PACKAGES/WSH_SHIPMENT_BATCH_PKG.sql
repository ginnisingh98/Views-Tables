--------------------------------------------------------
--  DDL for Package WSH_SHIPMENT_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPMENT_BATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHSBPKS.pls 120.0.12010000.1 2010/02/25 17:09:17 sankarun noship $ */

   TYPE Shipment_Batch_Record IS RECORD (
        customer_id                    WSH_DELIVERY_DETAILS.customer_id%TYPE,
        organization_id                WSH_DELIVERY_DETAILS.organization_id%TYPE,
        ship_from_location_id          WSH_DELIVERY_DETAILS.ship_from_location_id%TYPE,
        org_id                         WSH_DELIVERY_DETAILS.org_id%TYPE,
        currency_code                  WSH_DELIVERY_DETAILS.currency_code%TYPE,
        ship_to_site_use_id            WSH_DELIVERY_DETAILS.ship_to_site_use_id%TYPE,
        invoice_to_site_use_id         NUMBER,
        deliver_to_site_use_id         WSH_DELIVERY_DETAILS.deliver_to_site_use_id%TYPE,
        ship_to_contact_id             WSH_DELIVERY_DETAILS.ship_to_contact_id%TYPE,
        invoice_to_contact_id          NUMBER,
        deliver_to_contact_id          WSH_DELIVERY_DETAILS.deliver_to_contact_id%TYPE,
        ship_method_code               WSH_DELIVERY_DETAILS.ship_method_code%TYPE,
        freight_terms_code             WSH_DELIVERY_DETAILS.freight_terms_code%TYPE,
        fob_code                       WSH_DELIVERY_DETAILS.fob_code%TYPE,
        group_id                       NUMBER );

   TYPE Shipment_Batch_Tbl IS TABLE OF Shipment_Batch_Record index by binary_integer;

--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Create_Shipment_Batch
--
-- PARAMETERS:
--       errbuf                 => Message returned to Concurrent Manager
--       retcode                => Code (0, 1, 2) returned to Concurrent Manager
--       p_organization_id      => Orgnaization
--       p_customer_id          => Consignee/Customer
--       p_ship_to_location_id  => Ship To Location
--       p_transaction_type_id  => Sales Order Type
--       p_from_order_number    => From Order Number
--       p_to_order_number      => To Order Number
--       p_from_request_date    => From Request Date
--       p_to_request_date      => To Request Date
--       p_from_schedule_date   => From Schedule Date
--       p_to_schedule_date     => To Schedule Date
--       p_shipment_priority    => Shipment Priority
--       p_include_internal_so  => Incude Internal Sales Order
--       p_log_level            => Either 1(Debug), 0(No Debug)
--
-- COMMENT:
--       API will be invoked from Concurrent Manager whenever concurrent program
--       'Create Shipment Batches' is triggered.
--       Wrapper for 'Crete Shipment Batch' API
--=============================================================================
--
   PROCEDURE Create_Shipment_Batch (
             errbuf                 OUT NOCOPY   VARCHAR2,
             retcode                OUT NOCOPY   NUMBER,
             p_organization_id      IN  NUMBER,
             p_customer_id          IN  NUMBER,
             p_ship_to_location_id  IN  NUMBER,
             p_transaction_type_id  IN  NUMBER,
             p_from_order_number    IN  VARCHAR2,
             p_to_order_number      IN  VARCHAR2,
             p_from_request_date    IN  VARCHAR2,
             p_to_request_date      IN  VARCHAR2,
             p_from_schedule_date   IN  VARCHAR2,
             p_to_schedule_date     IN  VARCHAR2,
             p_shipment_priority    IN  VARCHAR,
             p_include_internal_so  IN  VARCHAR,
             p_log_level            IN  NUMBER );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Create_Shipment_Batch
--
-- PARAMETERS:
--       p_organization_id      => Orgnaization
--       p_customer_id          => Consignee/Customer
--       p_ship_to_location_id  => Ship To Location
--       p_transaction_type_id  => Sales Order Type
--       p_from_order_number    => From Order Number
--       p_to_order_number      => To Order Number
--       p_from_request_date    => From Request Date
--       p_to_request_date      => To Request Date
--       p_from_schedule_date   => From Schedule Date
--       p_to_schedule_date     => To Schedule Date
--       p_shipment_priority    => Shipment Priority
--       p_include_internal_so  => Incude Internal Sales Order
--       x_return_status        => Return Status of API (S,W,E,U)
--
-- COMMENT:
--       Based on input parameter values, eligble records from WDD are fetced.
--       Records fetched are grouped into Shipment Batches based on grouping
--       criteria returned from WSH_CUSTOM_PUB.Shipment_Batch_Group_Criteria
--       Custom API. A record is inserted into Wsh_Shipment_Batches table for
--       each shipment Batch and corresponding batch name is stamped in WDD.
--
--       Mandatory grouping criteria for Shipment Batch is
--          a) Customer
--          b) Ship To Site
--          c) Organization
--          d) Org (Operating Unit)
--          e) Currency Code
--       Optional grouping criteria for Shipment Batch is
--          a) Invoice To Location
--          b) Deliver To Location
--          c) Ship To Contact
--          d) Invoice To Contact
--          e) Deliver To Contact
--          f) Ship Method
--          g) Freight Terms
--          h) FOB
--          i) Within/Across Orders
--=============================================================================
--
   PROCEDURE Create_Shipment_Batch (
             p_organization_id      IN  NUMBER,
             p_customer_id          IN  NUMBER,
             p_ship_to_location_id  IN  NUMBER,
             p_transaction_type_id  IN  NUMBER,
             p_from_order_number    IN  VARCHAR2,
             p_to_order_number      IN  VARCHAR2,
             p_from_request_date    IN  VARCHAR2,
             p_to_request_date      IN  VARCHAR2,
             p_from_schedule_date   IN  VARCHAR2,
             p_to_schedule_date     IN  VARCHAR2,
             p_shipment_priority    IN  VARCHAR,
             p_include_internal_so  IN  VARCHAR,
             x_return_status        OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Cancel_Line
--
-- PARAMETERS:
--       p_document_number      => Shipment Batch Document Number
--       p_line_number          => Shipment Batch Line Number
--       p_cancel_quantity      => quantity to unassign from Shipment batch
--       x_return_status        => Return Status of API (S,E,U)
--
-- COMMENT:
--       Delivery line(s) corresponding to document number and document line
--       number will be unassigned from Shipment Batch till the cancel quantity
--       is met.
--
--=============================================================================
--
   PROCEDURE Cancel_Line(
             p_document_number      IN  VARCHAR2,
             p_line_number          IN  VARCHAR2,
             p_cancel_quantity      IN  NUMBER,
             x_return_status        OUT NOCOPY    VARCHAR2 );

END WSH_SHIPMENT_BATCH_PKG;

/
