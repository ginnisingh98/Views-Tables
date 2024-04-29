--------------------------------------------------------
--  DDL for Package POS_ASN_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASN_XML" AUTHID CURRENT_USER AS
/* $Header: POSASNXS.pls 120.0.12010000.2 2008/08/27 05:25:12 pilamuru ship $*/

 Procedure validate_shipment_num
  (p_shipment_num  IN  VARCHAR,
   p_vendor_id IN NUMBER,
   p_vendor_site_id IN NUMBER,
   p_ship_to_org_id IN NUMBER,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR);


 Procedure validate_shipment_date
  (p_shipment_date    IN  DATE,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR);


 Procedure validate_receipt_date
   (p_shipment_date    IN  DATE,
    p_expected_receipt_date IN DATE,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);


 Procedure validate_quantity
  (p_line_location_id  IN  NUMBER,
   p_quantity IN  NUMBER,
   p_unit_of_measure  IN  VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR);


 Procedure validate_freight_carrier_code
  (p_freight_code    IN  VARCHAR,
   p_error_code OUT NOCOPY NUMBER);


 Procedure validate_freight_terms
  (p_freight_terms    IN  VARCHAR,
   p_error_code OUT NOCOPY NUMBER);


 Procedure use_preProcessor
  (p_group_id IN  NUMBER,
   p_org_id IN  NUMBER,
   p_error_message OUT NOCOPY VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_po_num OUT NOCOPY VARCHAR,
   p_line_num OUT NOCOPY NUMBER,
   p_po_shipment_line_num OUT NOCOPY NUMBER);


  Procedure  derive_location_id
    (p_ship_to_partner_id  IN  VARCHAR,
     p_org_id IN NUMBER,
     p_address1  IN  VARCHAR,
     p_address2  IN  VARCHAR,
     p_city  IN VARCHAR,
     p_postal_code IN VARCHAR,
     p_country  IN VARCHAR,
     p_po_line_location_id IN NUMBER,
     p_ship_to_location_id OUT NOCOPY NUMBER,
     p_auto_transact_code OUT NOCOPY VARCHAR,
     p_transaction_type OUT NOCOPY VARCHAR,
     p_error_code OUT NOCOPY NUMBER,
     p_error_message OUT NOCOPY VARCHAR);


 Procedure  derive_org_id
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
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);


   Procedure derive_vendor_id
    (p_org_id IN NUMBER,
     p_supplier_code IN VARCHAR,
     p_vendor_id  OUT NOCOPY  NUMBER,
     p_vendor_site_id  OUT NOCOPY  NUMBER,
     p_error_code  OUT NOCOPY NUMBER,
     p_error_message OUT NOCOPY VARCHAR);


    Procedure store_line_vendor_error
     (p_error_code IN NUMBER,
      p_error_message IN VARCHAR,
      line_vendor_error_code OUT NOCOPY NUMBER,
      line_vendor_error_message OUT NOCOPY VARCHAR);


   Procedure store_line_org_error
    (p_error_code IN NUMBER,
     p_error_message IN VARCHAR,
     line_org_error_code OUT NOCOPY NUMBER,
     line_org_error_message OUT NOCOPY VARCHAR);


   Procedure store_line_location_error
    (p_error_code IN NUMBER,
     p_error_message IN VARCHAR,
     line_location_error_code OUT NOCOPY NUMBER,
     line_location_error_message OUT NOCOPY VARCHAR);


   Procedure get_user_id
   (p_user_name IN VARCHAR,
    p_user_id OUT NOCOPY NUMBER,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);

  Procedure pre_validate
   (p_header_interface_id IN NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_vendor_id OUT NOCOPY NUMBER,
    p_vendor_site_id OUT NOCOPY NUMBER,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);


  Procedure derive_line_cols
   (p_po_header_id IN NUMBER,
    p_line_num IN NUMBER,
    p_document_shipment_line_num IN NUMBER,
    p_release_num IN NUMBER,
    p_item_id OUT NOCOPY NUMBER,
    p_item_num OUT NOCOPY VARCHAR,
    p_item_revision OUT NOCOPY VARCHAR,
    p_supplier_item_num OUT NOCOPY VARCHAR,
    --p_ship_to_location_id IN OUT NOCOPY NUMBER,
    p_ship_to_location_id OUT NOCOPY NUMBER,
    p_po_line_id OUT NOCOPY NUMBER,
    p_line_location_id OUT NOCOPY NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_po_release_id OUT NOCOPY NUMBER,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR);


 Procedure populate_doc_id
  (p_header_interface_id IN NUMBER,
   p_location_id IN NUMBER,
   p_bill_of_lading IN VARCHAR,
   p_packing_slip IN VARCHAR,
   p_waybill_airbill_num IN VARCHAR);

Procedure derive_unit_of_measure
  (p_uom_code IN VARCHAR,
   p_unit_of_measure OUT NOCOPY VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR);


  END POS_ASN_XML;


/
