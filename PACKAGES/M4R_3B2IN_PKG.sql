--------------------------------------------------------
--  DDL for Package M4R_3B2IN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4R_3B2IN_PKG" AUTHID CURRENT_USER AS
/* $Header: M4R3B2IS.pls 120.0 2005/05/24 16:17:52 appldev noship $ */

PROCEDURE RCV_TXN_INPROCESS
   (p_document_line_num IN NUMBER,
    p_document_shipment_line_num IN NUMBER,
    p_release_num IN NUMBER,
    p_po_number IN VARCHAR,
    p_supplier_code IN VARCHAR,
    p_item_num IN VARCHAR,
    p_supplier_item_num IN VARCHAR,
    p_org_id  OUT NOCOPY NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_po_header_id OUT NOCOPY NUMBER,
    p_vendor_id  OUT NOCOPY  NUMBER,
    p_vendor_site_id  OUT NOCOPY  NUMBER,
    p_ship_to_edi_location_code IN VARCHAR,
    p_ship_to_location_id OUT NOCOPY VARCHAR,
    p_error_code  OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);

PROCEDURE  RCV_TXN_INPROCESS2
   (p_po_header_id IN NUMBER,
    p_line_num IN NUMBER,
    p_document_shipment_line_num IN NUMBER,
    p_release_num IN NUMBER,
    p_item_id OUT NOCOPY NUMBER,
    p_item_num OUT NOCOPY VARCHAR,
    p_item_revision OUT NOCOPY VARCHAR,
    p_supplier_item_num OUT NOCOPY VARCHAR,
    p_ship_to_location_id IN OUT NOCOPY NUMBER,
    p_po_line_id OUT NOCOPY NUMBER,
    p_line_location_id OUT NOCOPY NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_po_release_id OUT NOCOPY NUMBER,
    p_uom_code IN VARCHAR,
    p_unit_of_measure OUT NOCOPY VARCHAR,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);

PROCEDURE GET_VALUES_HEADER
(p_header_interface_id IN NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_vendor_id OUT NOCOPY NUMBER,
    p_vendor_site_id OUT NOCOPY NUMBER,
    p_bill_of_lading OUT NOCOPY VARCHAR,
    p_waybill_airbill_num OUT NOCOPY VARCHAR,
	p_packing_slip OUT NOCOPY VARCHAR,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR
	);

END M4R_3B2IN_PKG;

 

/
