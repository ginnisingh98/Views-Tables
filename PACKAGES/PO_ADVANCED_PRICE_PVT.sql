--------------------------------------------------------
--  DDL for Package PO_ADVANCED_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ADVANCED_PRICE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXQPRVS.pls 120.5.12010000.5 2013/10/03 08:53:07 inagdeo ship $*/


  g_NO_VALID_PERIOD_EXC EXCEPTION;
  g_SUBMISSION_CHECK_EXC EXCEPTION;

-------------------------------------------------------------------------------
-- Package types
-------------------------------------------------------------------------------
-- Header record type
  TYPE Header_Rec_Type IS RECORD
  (org_id PO_HEADERS.org_id%TYPE
   , p_order_header_id PO_HEADERS.po_header_id%TYPE
   , supplier_id PO_HEADERS.vendor_id%TYPE
   , supplier_site_id PO_HEADERS.vendor_site_id%TYPE
   , creation_date PO_HEADERS.creation_date%TYPE
   , order_type VARCHAR2(20) -- REQUISITION/PO
   , ship_to_location_id PO_HEADERS.ship_to_location_id%TYPE
   , ship_to_org_id PO_HEADERS.org_id%TYPE
-- New Attributes for Receiving
-- <FSC R12 START>
   , shipment_header_id RCV_SHIPMENT_HEADERS.shipment_header_id%TYPE
   , hazard_class RCV_SHIPMENT_HEADERS.hazard_class%TYPE
   , hazard_code RCV_SHIPMENT_HEADERS.hazard_code%TYPE
   , shipped_date RCV_SHIPMENT_HEADERS.shipped_date%TYPE
   , shipment_num RCV_SHIPMENT_HEADERS.shipment_num%TYPE
   , carrier_method RCV_SHIPMENT_HEADERS.carrier_method%TYPE
   , packaging_code RCV_SHIPMENT_HEADERS.packaging_code%TYPE
   , freight_carrier_code RCV_SHIPMENT_HEADERS.freight_carrier_code%TYPE
   , freight_terms RCV_SHIPMENT_HEADERS.freight_terms%TYPE
   , currency_code RCV_SHIPMENT_HEADERS.currency_code%TYPE
   , rate RCV_SHIPMENT_HEADERS.conversion_rate%TYPE
   , rate_type RCV_SHIPMENT_HEADERS.conversion_rate_type%TYPE
   , source_org_id RCV_SHIPMENT_HEADERS.organization_id%TYPE
   , expected_receipt_date RCV_SHIPMENT_HEADERS.expected_receipt_date%TYPE
--  <FSC R12 END>
   );

--  Line record type
  TYPE Line_Rec_Type IS RECORD
  (order_line_id PO_LINES.po_line_id%TYPE
   , agreement_type PO_HEADERS.type_lookup_code%TYPE
   , agreement_id PO_HEADERS.po_header_id%TYPE
   , agreement_line_id PO_LINES.po_line_id%TYPE --<R12 GBPA Adv Pricing>
   , supplier_id PO_HEADERS.vendor_id%TYPE
   , supplier_site_id PO_HEADERS.vendor_site_id%TYPE
   , ship_to_location_id PO_LINE_LOCATIONS.ship_to_location_id%TYPE
   , ship_to_org_id PO_LINE_LOCATIONS.ship_to_organization_id%TYPE
   , supplier_item_num PO_LINES.vendor_product_num%TYPE
   , item_revision PO_LINES.item_revision%TYPE
   , item_id PO_LINES.item_id%TYPE
   , category_id PO_LINES.category_id%TYPE
   , rate PO_HEADERS.rate%TYPE
   , rate_type PO_HEADERS.rate_type%TYPE
   , currency_code PO_HEADERS.currency_code%TYPE
   , need_by_date PO_LINE_LOCATIONS.need_by_date%TYPE
-- <FSC R12 START>
-- New Attributes for Receiving
   , shipment_line_id RCV_SHIPMENT_LINES.shipment_line_id%TYPE
   , primary_unit_of_measure RCV_SHIPMENT_LINES.primary_unit_of_measure%TYPE
   , to_organization_id RCV_SHIPMENT_LINES.to_organization_id%TYPE
   , unit_of_measure RCV_SHIPMENT_LINES.unit_of_measure%TYPE
   , source_document_code RCV_SHIPMENT_LINES.source_document_code%TYPE
   , unit_price RCV_SHIPMENT_LINES.shipment_unit_price%TYPE
   , quantity RCV_SHIPMENT_LINES.quantity_received%TYPE
   , order_type VARCHAR2(20) DEFAULT NULL-- REQUISITION/PO/GBPA --added for Enhanced Pricing
--  <FSC R12 END>
   --<PDOI Enhancement Bug#17063664>
   , existing_line_flag VARCHAR2(1) DEFAULT NULL -- Flag to identify if line exists in base table
   , allow_price_override_flag VARCHAR2(1) DEFAULT NULL -- Flag to identify allow_price_override_flag on source doc line
   );

-- <FSC R12 START>
-- QP Result Record to capture information returned by QP.
-- Record to keep the freight charge info per line
  TYPE Freight_Charges_Rec_Type IS RECORD
  (
   charge_type_code QP_PREQ_LDETS_TMP_T.charge_type_code%TYPE,
   freight_charge QP_PREQ_LDETS_TMP_T.ORDER_QTY_ADJ_AMT%TYPE,
   pricing_status_code QP_PREQ_LDETS_TMP_T.pricing_status_code%TYPE,
   pricing_status_text QP_PREQ_LDETS_TMP_T.pricing_status_text%TYPE
   );

  TYPE Freight_Charges_Rec_Tbl_Type IS TABLE OF Freight_Charges_Rec_Type;

--Record to keep the price/charge info per line.
  TYPE Qp_Price_Result_Rec_Type IS RECORD
  (
   line_index QP_PREQ_LDETS_TMP_T.line_index%TYPE,
   line_id NUMBER,
   base_unit_price NUMBER,
   adjusted_price NUMBER,
   freight_charge_rec_tbl freight_charges_rec_tbl_type,
   pricing_status_code QP_PREQ_LDETS_TMP_T.pricing_status_code%TYPE,
   pricing_status_text QP_PREQ_LDETS_TMP_T.pricing_status_text%TYPE
   );

  TYPE Qp_Price_Result_Rec_Tbl_Type IS TABLE OF Qp_Price_Result_Rec_Type;

  TYPE Line_Tbl_Type IS TABLE OF Line_Rec_Type;
-- <FSC R12 END>
-------------------------------------------------------------------------------
-- Global package variables
-------------------------------------------------------------------------------

--Global Variables for Attribute Mapping during Pricing
  G_HDR Header_Rec_Type;
  G_LINE Line_Rec_Type;

-------------------------------------------------------------------------------
-- Package procedures
-------------------------------------------------------------------------------

  PROCEDURE get_advanced_price
  (p_org_id IN NUMBER
   , p_supplier_id IN NUMBER
   , p_supplier_site_id IN NUMBER
   , p_creation_date IN DATE
   , p_order_type IN VARCHAR2
   , p_ship_to_location_id IN NUMBER
   , p_ship_to_org_id IN NUMBER
   , p_order_header_id IN NUMBER
   , p_order_line_id IN NUMBER
   , p_item_revision IN VARCHAR2 -- Bug 3330884
   , p_item_id IN NUMBER
   , p_category_id IN NUMBER
   , p_supplier_item_num IN VARCHAR2
   , p_agreement_type IN VARCHAR2
   , p_agreement_id IN NUMBER
   , p_agreement_line_id IN NUMBER DEFAULT NULL --<R12 GBPA Adv Pricing>
   , p_rate IN NUMBER
   , p_rate_type IN VARCHAR2
   , p_currency_code IN VARCHAR2
   , p_need_by_date IN DATE
   , p_quantity IN NUMBER
   , p_uom IN VARCHAR2
   , p_unit_price IN NUMBER
   --<Enhanced Pricing Start>
   , p_draft_id IN NUMBER DEFAULT NULL
    --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
   , p_pricing_call_src IN VARCHAR2 DEFAULT NULL --parameter to identify calls from retro and auto creation
   --<Enhanced Pricing End>
   , x_base_unit_price OUT NOCOPY NUMBER
   , x_unit_price OUT NOCOPY NUMBER
   , x_return_status OUT NOCOPY VARCHAR2
   );


  FUNCTION is_valid_qp_line_type
  (p_line_type_id IN NUMBER
   ) RETURN BOOLEAN;

  -- <FSC R12 START>
  PROCEDURE get_advanced_price
    (p_header_rec IN Header_Rec_Type
    , p_line_rec_tbl IN Line_Tbl_Type
    , p_request_type IN VARCHAR2
    , p_pricing_event IN VARCHAR2
    , p_has_header_pricing IN BOOLEAN
    , p_return_price_flag IN BOOLEAN
    , p_return_freight_flag IN BOOLEAN
    , p_price_adjustment_flag IN BOOLEAN DEFAULT NULL  -- <PDOI Enhancement Bug#17063664>
    , p_draft_id  IN NUMBER DEFAULT NULL -- <PDOI Enhancement Bug#17063664>
    , x_price_tbl OUT NOCOPY Qp_Price_Result_Rec_Tbl_Type
    , x_return_status OUT NOCOPY VARCHAR2);
  -- <FSC R12 END>

  --<Enhanced Pricing Start:>
  PROCEDURE call_pricing_manual_modifier
    (p_org_id IN NUMBER
    , p_supplier_id IN NUMBER
    , p_supplier_site_id IN NUMBER
    , p_creation_date IN DATE
    , p_order_type IN VARCHAR2
    , p_ship_to_location_id IN NUMBER
    , p_ship_to_org_id IN NUMBER
    , p_order_header_id IN NUMBER
    , p_order_line_id IN NUMBER
    , p_item_revision IN VARCHAR2
    , p_item_id IN NUMBER
    , p_category_id IN NUMBER
    , p_supplier_item_num IN VARCHAR2
    , p_agreement_type IN VARCHAR2
    , p_agreement_id IN NUMBER
    , p_agreement_line_id IN NUMBER DEFAULT NULL --<R12 GBPA Adv Pricing>
    , p_rate IN NUMBER
    , p_rate_type IN VARCHAR2
    , p_currency_code IN VARCHAR2
    , p_need_by_date IN DATE
    , p_quantity IN NUMBER
    , p_uom IN VARCHAR2
    , p_unit_price IN NUMBER
    , x_return_status OUT NOCOPY VARCHAR2
    );
  --<Enhanced Pricing End>

  --<PDOI Enhancement Bug#17063664>
  PROCEDURE get_advanced_price
  (  p_api_version            IN         NUMBER
   , x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type
   , x_return_status          OUT NOCOPY VARCHAR2
   );

END PO_ADVANCED_PRICE_PVT;

/
