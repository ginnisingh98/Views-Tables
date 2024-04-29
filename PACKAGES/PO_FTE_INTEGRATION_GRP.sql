--------------------------------------------------------
--  DDL for Package PO_FTE_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_FTE_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGFTES.pls 120.0 2005/06/02 03:07:35 appldev noship $ */

TYPE po_release_rec_type IS RECORD (
    source_blanket_reference_id   NUMBER,
    source_blanket_reference_num  NUMBER,
    release_revision              NUMBER,
    header_id                     NUMBER,
    vendor_id                     NUMBER,
    ship_from_site_id             NUMBER,
    hold_code                     VARCHAR2(1),
    freight_terms_code            VARCHAR2(30),
    fob_point_code                VARCHAR2(30),
    source_header_number          VARCHAR2(150),
    source_header_type_id         NUMBER,
    source_header_type_name       VARCHAR2(240),
    org_id                        NUMBER,
    currency_code                 VARCHAR2(15),
    shipping_control              VARCHAR2(30),
    po_revision                   NUMBER,
    line_id                       NUMBER,
    inventory_item_id             NUMBER,
    item_description              VARCHAR2(250),
    hazard_class_id               NUMBER,
    revision                      VARCHAR2(3),
    supplier_item_num             VARCHAR2(30),
    source_line_number            VARCHAR2(150),
    source_line_type_code         VARCHAR2(30),
    po_shipment_line_id           NUMBER,
    country_of_origin             VARCHAR2(50),
    ship_to_location_id           NUMBER,
    ship_tolerance_above          NUMBER,
    ship_tolerance_below          NUMBER,
    shipped_quantity              NUMBER,
    request_date                  DATE,
    schedule_ship_date            DATE,
    organization_id               NUMBER,
    ordered_quantity              NUMBER,
    order_quantity_uom            VARCHAR2(3),
    cancelled_quantity            NUMBER,
    unit_list_price               NUMBER,
    preferred_grade               VARCHAR2(150),-- INVCONV increased length to 150
    ordered_quantity2             NUMBER,
    ordered_quantity_uom2         VARCHAR2(3),
    requested_quantity2           NUMBER,
    cancelled_quantity2           NUMBER,
    requested_quantity_uom2       VARCHAR2(3),
    po_shipment_line_number       NUMBER,
    days_early_receipt_allowed    NUMBER,
    days_late_receipt_allowed     NUMBER,
    drop_ship_flag                VARCHAR2(1),
    qty_rcv_exception_code        VARCHAR2(30),
    closed_flag                   VARCHAR2(1),
    closed_code                   VARCHAR2(30),
    cancelled_flag                VARCHAR2(1),
    receipt_days_exception_code   VARCHAR2(25),
    enforce_ship_to_location_code VARCHAR2(25),
    shipping_details_updated_on   DATE,
    carrier_id                    NUMBER,
    net_weight                    NUMBER,
    weight_uom_code               VARCHAR2(3),
    volume                        NUMBER,
    volume_uom_code               VARCHAR2(3)
    );

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_release_attributes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get attributes of Standard Purchase Order and Blanket Release for
--  Transportation delivery record.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_line_location_id
--  Corresponding to po_line_location_id
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Error messages number.
--x_msg_data
--  Error messages body.
--x_po_release_attributes
--Testing:
--  Call this API when only line_location_id exists.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_po_release_attributes
(
    p_api_version            IN         NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_line_location_id       IN         NUMBER,
    x_po_releases_attributes OUT NOCOPY po_release_rec_type
);

-- Following wrappers for FTE Team to po_status_check API added in DropShip FPJ project

-- Detailed comments are in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
PROCEDURE po_status_check (
    p_api_version         IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_po_status_rec       OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
);

-- Detailed comments are in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
PROCEDURE po_status_check (
    p_api_version           IN NUMBER,
    p_header_id             IN NUMBER := NULL,
    p_release_id            IN NUMBER := NULL,
    p_document_type         IN VARCHAR2 := NULL,
    p_document_subtype      IN VARCHAR2 := NULL,
    p_document_num          IN VARCHAR2 := NULL,
    p_vendor_order_num      IN VARCHAR2 := NULL,
    p_line_id               IN NUMBER := NULL,
    p_line_location_id      IN NUMBER := NULL,
    p_distribution_id       IN NUMBER := NULL,
    p_mode                  IN VARCHAR2,
    p_lock_flag             IN VARCHAR2 := 'N',
    x_po_status_rec         OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status         OUT NOCOPY VARCHAR2
);


END PO_FTE_INTEGRATION_GRP;

 

/
