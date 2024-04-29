--------------------------------------------------------
--  DDL for Package WSH_SHIPMENT_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_SHIPMENT_REQUEST_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHSRPKS.pls 120.0.12010000.5 2009/12/03 12:08:35 mvudugul noship $ */

   TYPE Del_Interface_Rec_Type IS RECORD (
        delivery_interface_id          WSH_NEW_DEL_INTERFACE.delivery_interface_id%TYPE,
        organization_code              WSH_NEW_DEL_INTERFACE.organization_code%TYPE,
        organization_id                WSH_NEW_DEL_INTERFACE.organization_id%TYPE,
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
        transaction_type_id            WSH_NEW_DEL_INTERFACE.transaction_type_id%TYPE,
        price_list_id                  WSH_NEW_DEL_INTERFACE.price_list_id%TYPE,
        payment_term_id                NUMBER,
        currency_code                  WSH_NEW_DEL_INTERFACE.currency_code%TYPE,
        carrier_code                   WSH_NEW_DEL_INTERFACE.carrier_code%TYPE,
        carrier_id                     WSH_NEW_DEL_INTERFACE.carrier_id%TYPE,
        service_level                  WSH_NEW_DEL_INTERFACE.service_level%TYPE,
        mode_of_transport              WSH_NEW_DEL_INTERFACE.mode_of_transport%TYPE,
        freight_terms_code             WSH_NEW_DEL_INTERFACE.freight_terms_code%TYPE,
        fob_code                       WSH_NEW_DEL_INTERFACE.fob_code%TYPE,
        ship_method_code               VARCHAR2(30),
        org_id                         NUMBER,
        document_revision              NUMBER,
        order_number                   NUMBER,
        client_code                    VARCHAR2(10) --LSP PROJECT
        );

   TYPE Del_Details_Interface_Rec_Type IS RECORD (
        delivery_detail_interface_id   WSH_DEL_DETAILS_INTERFACE.delivery_detail_interface_id%TYPE,
        lot_number                     WSH_DEL_DETAILS_INTERFACE.lot_number%TYPE,
        subinventory                   WSH_DEL_DETAILS_INTERFACE.subinventory%TYPE,
        revision                       WSH_DEL_DETAILS_INTERFACE.revision%TYPE,
        locator_id                     WSH_DEL_DETAILS_INTERFACE.locator_id%TYPE,
        locator_code                   WSH_DEL_DETAILS_INTERFACE.locator_code%TYPE,
        line_number                    WSH_DEL_DETAILS_INTERFACE.line_number%TYPE,
        customer_item_number           WSH_DEL_DETAILS_INTERFACE.customer_item_number%TYPE,
        customer_item_id               WSH_DEL_DETAILS_INTERFACE.customer_item_id%TYPE,
        item_number                    WSH_DEL_DETAILS_INTERFACE.item_number%TYPE,
        inventory_item_id              WSH_DEL_DETAILS_INTERFACE.inventory_item_id%TYPE,
        organization_id                WSH_DEL_DETAILS_INTERFACE.organization_id%TYPE,
        item_description               WSH_DEL_DETAILS_INTERFACE.item_description%TYPE,
        requested_quantity             WSH_DEL_DETAILS_INTERFACE.requested_quantity%TYPE,
        requested_quantity_uom         WSH_DEL_DETAILS_INTERFACE.requested_quantity_uom%TYPE,
        src_requested_quantity         WSH_DEL_DETAILS_INTERFACE.src_requested_quantity%TYPE,
        src_requested_quantity_uom     WSH_DEL_DETAILS_INTERFACE.src_requested_quantity_uom%TYPE,
        currency_code                  WSH_DEL_DETAILS_INTERFACE.currency_code%TYPE,
        unit_selling_price             WSH_DEL_DETAILS_INTERFACE.unit_selling_price%TYPE,
        ship_tolerance_above           WSH_DEL_DETAILS_INTERFACE.ship_tolerance_above%TYPE,
        ship_tolerance_below           WSH_DEL_DETAILS_INTERFACE.ship_tolerance_below%TYPE,
        date_requested                 WSH_DEL_DETAILS_INTERFACE.date_requested%TYPE,
        date_scheduled                 WSH_DEL_DETAILS_INTERFACE.date_scheduled%TYPE,
        earliest_pickup_date           WSH_DEL_DETAILS_INTERFACE.earliest_pickup_date%TYPE,
        latest_pickup_date             WSH_DEL_DETAILS_INTERFACE.latest_pickup_date%TYPE,
        earliest_dropoff_date          WSH_DEL_DETAILS_INTERFACE.earliest_dropoff_date%TYPE,
        latest_dropoff_date            WSH_DEL_DETAILS_INTERFACE.latest_dropoff_date%TYPE,
        ship_set_name                  WSH_DEL_DETAILS_INTERFACE.ship_set_name%TYPE,
        packing_instructions           WSH_DEL_DETAILS_INTERFACE.packing_instructions%TYPE,
        shipping_instructions          WSH_DEL_DETAILS_INTERFACE.shipping_instructions%TYPE,
        shipment_priority_code         WSH_DEL_DETAILS_INTERFACE.shipment_priority_code%TYPE,
        source_header_number           WSH_DEL_DETAILS_INTERFACE.source_header_number%TYPE,
        source_line_number             WSH_DEL_DETAILS_INTERFACE.source_line_number%TYPE,
        cust_po_number                 WSH_DEL_DETAILS_INTERFACE.cust_po_number%TYPE,
        line_id                        NUMBER,
        schedule_date_changed          VARCHAR2(1) := 'N',
        changed_flag                   VARCHAR2(1) := 'N'
        );
   TYPE Del_Details_Interface_Rec_Tab IS TABLE OF Del_Details_Interface_Rec_Type index by binary_integer;

   TYPE OM_Header_Rec_Type IS RECORD (
        header_id                       NUMBER,
        open_flag                       VARCHAR2(1),
        order_type_id                   NUMBER,
        org_id                          NUMBER,
        version_number                  NUMBER,
        sold_to_org_id                  NUMBER,
        ship_to_org_id                  NUMBER,
        invoice_to_org_id               NUMBER,
        deliver_to_org_id               NUMBER,
        ship_from_org_id                NUMBER,
        invoice_to_contact_id           NUMBER,
        deliver_to_contact_id           NUMBER,
        ship_to_contact_id              NUMBER,
        sold_to_contact_id              NUMBER,
        price_list_id                   NUMBER,
        payment_term_id                 NUMBER,
        shipping_method_code            VARCHAR2(30),
        freight_terms_code              VARCHAR2(30),
        fob_point_code                  VARCHAR2(30),
        currency_code                   VARCHAR2(3),
        ship_to_changed                 BOOLEAN := FALSE,
        invoice_to_changed              BOOLEAN := FALSE,
        deliver_to_changed              BOOLEAN := FALSE,
        invoice_to_contact_changed      BOOLEAN := FALSE,
        deliver_to_contact_changed      BOOLEAN := FALSE,
        ship_to_contact_changed         BOOLEAN := FALSE,
        shipping_method_changed         BOOLEAN := FALSE,
        freight_terms_changed           BOOLEAN := FALSE,
        fob_point_changed               BOOLEAN := FALSE,
        header_attributes_changed       BOOLEAN := FALSE );

   TYPE OM_Line_Rec_Type IS RECORD (
        line_id                NUMBER,
        open_flag              VARCHAR2(1),
        ordered_quantity       NUMBER,
        inventory_item_id      NUMBER,
        ordered_item_id        NUMBER,
        order_quantity_uom     VARCHAR2(3),
        ship_tolerance_above   NUMBER,
        ship_tolerance_below   NUMBER,
        request_date           DATE,
        schedule_ship_date     DATE,
        ship_set_name          VARCHAR2(30),
        shipping_instructions  VARCHAR2(2000),
        packing_instructions   VARCHAR2(2000),
        shipment_priority_code VARCHAR2(30),
        cust_po_number         VARCHAR2(50),
        subinventory           VARCHAR2(10),
        unit_selling_price     NUMBER );

   TYPE OM_Line_Tbl_Type is table of OM_Line_Rec_Type index by binary_integer;

--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Shipment_Request_Inbound
--
-- PARAMETERS:
--       errbuf                 => Message returned to Concurrent Manager
--       retcode                => Code (0, 1, 2) returned to Concurrent Manager
--       p_transaction_status   => Either AP, ER, NULL
--       p_deploy_mode          => Dummy for LSP(Enable or Disable Client)
--	 p_client_code          => Client Code  -- Modified R12.1.1 LSP PROJECT
--	 p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       p_log_level            => Either 1(Debug), 0(No Debug)
-- COMMENT:
--       API will be invoked from Concurrent Manager whenever concurrent program
--       'Process Shipment Requests' is triggered.
--=============================================================================
--
   PROCEDURE Shipment_Request_Inbound (
             errbuf                 OUT NOCOPY   VARCHAR2,
             retcode                OUT NOCOPY   NUMBER,
             p_transaction_status   IN  VARCHAR2,
             p_deploy_mode          IN  VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
             p_client_code          IN  VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
             p_from_document_number IN  NUMBER,
             p_to_document_number   IN  NUMBER,
             p_from_creation_date   IN  VARCHAR2,
             p_to_creation_date     IN  VARCHAR2,
             p_transaction_id       IN  NUMBER,
             p_log_level            IN  NUMBER );


--=============================================================================
-- PUBLIC PROCEDURE :
--       Process_Shipment_Request
--
-- PARAMETERS:
--       p_commit_flag          => Either FND_API.G_TRUE, FND_API.G_FALSE
--       p_transaction_status   => Either AP, ER, NULL
--	 p_client_code          => Client Code  -- Modified R12.1.1 LSP PROJECT
--	 p_from_document_number => From Document Number
--       p_to_document_number   => To Document Number
--       p_from_creation_date   => From Creation Date
--       p_to_creation_date     => To Creation Date
--       p_transaction_id       => Transacation id to be processed
--       x_return_status        => Return Status of API (S,W,E,U)
-- COMMENT:
--       Based on input parameter values, eligble records for processing are
--       queried from WTH table. Calling Workflow API WF_ENGINE.handleError to
--       process further, if WTH row queried is triggered from Workflow.
--       Calling Overloaded API Process_Shipment_Request, if WTH row queried is
--       NOT triggered from Workflow.
--=============================================================================
--
   PROCEDURE Process_Shipment_Request (
             p_commit_flag          IN  VARCHAR2,
             p_transaction_status   IN  VARCHAR2,
             p_client_code          IN  VARCHAR2,  -- Modified R12.1.1 LSP PROJECT
             p_from_document_number IN  NUMBER,
             p_to_document_number   IN  NUMBER,
             p_from_creation_date   IN  VARCHAR2,
             p_to_creation_date     IN  VARCHAR2,
             p_transaction_id       IN  NUMBER,
             x_return_status        OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Overloaded Process_Shipment_Request
--
-- PARAMETERS:
--       p_transaction_rec => Transaction History Record
--       p_commit_flag     => Either FND_API.G_TRUE, FND_API.G_FALSE
--       x_return_status   => Return Status of API (Either S,E,U)
-- COMMENT:
--       Calls APIs to validate data from Interface tables WNDI(Order Header)
--       and WDDI(Order Lines). Calls OM Process Order Group API
--       OE_ORDER_GRP.Process_Order to Create/Update/Cancel Sales Order.
--       Attributes related to shipping are validated, If PO group api returns
--       success.
--       If PO group api returns error then corresponding error messages are
--       logged in Wsh_Interface_Errors table.
--=============================================================================
--
   PROCEDURE Process_Shipment_Request (
             p_transaction_rec      IN  WSH_TRANSACTIONS_HISTORY_PKG.Txns_History_Record_Type,
             p_commit_flag          IN  VARCHAR2,
             x_return_status        OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Get_Standalone_Defaults
--
-- PARAMETERS:
--       p_delivery_interface_id  => Delivery Interface Id
--       x_delivery_interface_rec => Delivery Interface Record
--       x_return_status          => Return Status of API (S,E,U)
-- COMMENT:
--       Queries WNDI details, validates organization and derives
--       operating unit for organization.
--=============================================================================
--
   PROCEDURE Get_Standalone_Defaults (
             p_delivery_interface_id  IN         NUMBER,
             x_delivery_interface_rec OUT NOCOPY Del_Interface_Rec_Type,
             x_return_status          OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Header_Exists
--
-- PARAMETERS:
--       p_order_number       => Order Number
--       p_order_type_id      => Order Type
--       x_om_header_rec_type => Standalone related order header attributes record
--       x_return_status      => Return Status of API (Either S,U)
-- COMMENT:
--       Queries standalone related order header attributes from table
--       Oe_Order_Headers_All based on Order Number and Order Type passed.
--=============================================================================
--
   PROCEDURE Check_Header_Exists (
             p_order_number       IN         NUMBER,
             p_order_type_id      IN         NUMBER,
             x_OM_Header_Rec_Type OUT NOCOPY OM_Header_Rec_Type,
             x_return_status      OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Line_Exists
--
-- PARAMETERS:
--       p_header_id        => Order Header Id
--       p_line_number      => Order Line Number
--       x_om_line_rec_type => Standalone related order line attributes record
--       x_return_status    => Return Status of API (Either S,U)
-- COMMENT:
--       Queries standalone related order lines attributes from table
--       Oe_Order_Lines_All based on Header Id and Line Number passed.
--=============================================================================
--
   PROCEDURE Check_Line_Exists (
             p_header_id        IN         NUMBER,
             p_line_number      IN         NUMBER,
             x_OM_Line_Rec_Type OUT NOCOPY OM_Line_Rec_Type,
             x_return_status    OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Lock_SR_Lines
--
-- PARAMETERS:
--       p_header_id             => Order Header Id
--       p_delivery_interface_id => Delivery Interface Id
--       p_interface_records     => Either Y or N
--       x_return_status         => Return Status of API (Either S,E,U)
-- COMMENT:
--       API to Lock records from OEH, OEL and WDD table.
--       Based on p_interface_records value,
--       Y : Lock records from OEL, WDD corresponding to records from WDDI
--           Interface Table
--       N : Lock records from OEL, WDD for lines which are not populated in
--           WDDI Interface Table
--=============================================================================
--
   PROCEDURE Lock_SR_Lines (
             p_header_id             IN NUMBER,
             p_delivery_interface_id IN NUMBER,
             p_interface_records     IN VARCHAR2,
             x_return_status         OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Delivery_Line
--
-- PARAMETERS:
--       p_changed_attributes => Changed Attributes passed from OM
--       x_return_status      => Return Status of API (Either S,E,U)
-- COMMENT:
--       Only Requested Quantity can be updated during Shipment Request process
--       for Shipment lines if any delivery line is in a confirmed delivery or
--       has been shipped.
--=============================================================================
--
   PROCEDURE Validate_Delivery_Line (
             p_changed_attributes IN  WSH_INTERFACE.ChangedAttributeTabType,
             x_return_status      OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Check_Header_Attr_Changed
--
-- PARAMETERS:
--       p_del_interface_rec => Delivery Interface Record
--       p_om_header_rec     => Standalone related order header attributes record
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to check if following order header attributes are being changed
--       1) ShipTo Customer, Address, Contact
--       2) InvoiceTo Customer, Address, Contact
--       3) DeliverTo Customer, Address, Contact
--       4) Ship Method Code
--       5) Freight Terms
--       6) FOB Code
--=============================================================================
--
   PROCEDURE Check_Header_Attr_Changed(
             p_del_interface_rec IN OUT NOCOPY Del_Interface_Rec_Type,
             p_om_header_rec     IN OUT NOCOPY OM_Header_Rec_Type,
             x_return_status     OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Populate_Header_Rec
--
-- PARAMETERS:
--       p_action_type       => Either D(Cancel),A(Add),C(Change or Update)
--       p_om_header_rec     => Standalone related order header attributes record
--       p_del_interface_rec => Delivery Interface Record
--       x_header_rec        => Order Header Record
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to populate Order Header attributes.
--       If order header already exists only the operation related attributes
--       are populated.
--=============================================================================
--
   PROCEDURE Populate_Header_Rec(
             p_action_type           IN VARCHAR2,
             p_om_header_rec         IN OM_Header_Rec_Type,
             p_del_interface_rec     IN Del_Interface_Rec_Type,
             x_header_rec            OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type,
             x_return_status         OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Derive_Header_Rec
--
-- PARAMETERS:
--       p_om_header_rec     => Standalone related order header attributes record
--       x_del_interface_rec => Delivery Interface Record
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive/validate standalone related order header attributes
--       populated in Wsh_New_Del_Interface table.
--=============================================================================
--
   PROCEDURE Derive_Header_Rec(
             p_om_header_rec         IN OUT NOCOPY OM_Header_Rec_Type,
             x_del_interface_rec     IN OUT NOCOPY Del_Interface_Rec_Type,
             x_return_status         OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Derive_Line_Rec
--
-- PARAMETERS:
--       p_header_id                 => Header Id
--       p_del_interface_rec         => Delivery Interface Record
--       x_om_line_tbl_type          => Table of standalone related order line attributes
--       x_details_interface_rec_tab => Table of Delivery Detail Interface Record
--       x_interface_error_tab       => Table of Interface error records
--       x_return_status             => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to derive/validate standalone related order line attributes
--       populated in Wsh_Del_Details_Interface table.
--=============================================================================
--
   PROCEDURE Derive_Line_Rec(
             p_header_id                 IN NUMBER,
             p_del_interface_rec         IN OUT NOCOPY Del_Interface_Rec_Type,
             x_om_line_tbl_type          OUT NOCOPY OM_Line_Tbl_Type,
             x_details_interface_rec_tab OUT NOCOPY Del_Details_Interface_Rec_Tab,
             x_interface_error_tab       OUT NOCOPY WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab,
             x_return_status             OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Populate_Line_Records
--
-- PARAMETERS:
--       p_om_line_tbl_type          => Table of standalone related order line attributes
--       p_details_interface_rec_tab => Table of Delivery Detail Interface Record
--       p_om_header_rec_type        => Standalone Order Header attributes
--       p_delivery_interface_rec    => Delivery Interface Record
--       x_line_tbl                  => Table of Order Line attributes
--       x_line_details_tbl          => Table of Delivery Detail Interface Id
--       x_return_status             => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to populate Order Line attributes.
--       If order line already exists only the changed attributes are populated.
--=============================================================================
--
   PROCEDURE Populate_Line_Records(
             p_om_line_tbl_type          IN OM_Line_Tbl_Type,
             p_details_interface_rec_tab IN Del_Details_Interface_Rec_Tab,
             p_om_header_rec_type        IN OM_Header_Rec_Type,
             p_delivery_interface_rec    IN Del_Interface_Rec_Type,
             x_line_tbl                  OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type,
             x_line_details_tbl          OUT NOCOPY WSH_UTIl_CORE.Id_Tab_Type,
             x_return_status             OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Organization
--
-- PARAMETERS:
--       p_org_code        => Organization Code
--       p_organization_id => Organization Id
--       x_return_status   => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate organization id/code passed. Organization should
--       be WMS enabled and NOT Process manufacturing enabled.
--=============================================================================
--
   PROCEDURE Validate_Organization(
             p_org_code          IN VARCHAR2,
             p_organization_id   IN OUT NOCOPY NUMBER,
             x_return_status     OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Ship_Method
--
-- PARAMETERS:
--       p_carrier_code      => Freight Code
--       p_organization_id   => Organization id
--       p_service_level     => Service Level
--       p_mode_of_transport => Mode of Transport
--       x_ship_method_code  => Ship Method Code derived
--       x_return_status     => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate lookups Service Level and Mode of Transaport. Derives
--       Ship Method code based on Carrier Id, Service Level, Mode of transport
--       and Organization passed.
--=============================================================================
--
   PROCEDURE Validate_Ship_Method(
             p_carrier_code      IN  VARCHAR2,
             p_organization_id   IN  NUMBER,
             p_service_level     IN  VARCHAR2,
             p_mode_of_transport IN  VARCHAR2,
             x_ship_method_code  OUT NOCOPY VARCHAR2,
             x_return_status     OUT NOCOPY VARCHAR2 );
--
--=============================================================================
-- PUBLIC PROCEDURE :
--       Validate_Interface_Details
--
-- PARAMETERS:
--       p_details_interface_tab    => Table of Delivery Detail Interface record
--       x_interface_errors_rec_tab => Table of Interface Error records
--       x_return_status            => Return Status of API (Either S,E,U)
--
-- COMMENT:
--       API to validate Inventory attributes like revision, locator.
--       Inventory attributes cannot be changed if delivery line corresponding
--       to shipment line is picked or in a confirmed delivery or has been shipped.
--       Schedule dates cannot be changed if delivery line corresponding to
--       shipment line is in a confirmed delivery or has been shipped.
--=============================================================================
--
   PROCEDURE Validate_Interface_Details(
             p_details_interface_tab IN OUT NOCOPY Del_Details_Interface_Rec_Tab,
             x_interface_error_tab   OUT NOCOPY WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_tab,
             x_return_status         OUT NOCOPY VARCHAR2 );

END WSH_SHIPMENT_REQUEST_PKG;

/
