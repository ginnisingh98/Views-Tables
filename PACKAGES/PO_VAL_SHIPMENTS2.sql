--------------------------------------------------------
--  DDL for Package PO_VAL_SHIPMENTS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_SHIPMENTS2" AUTHID CURRENT_USER AS
  -- $Header: PO_VAL_SHIPMENTS2.pls 120.10.12010000.3 2013/10/25 11:32:28 inagdeo ship $

  -------------------------------------------------------------------------
  -- if purchase_basis is 'TEMP LABOR', the need_by_date column must be null
  -------------------------------------------------------------------------
  PROCEDURE need_by_date(p_id_tbl             IN PO_TBL_NUMBER,
                         p_purchase_basis_tbl IN PO_TBL_VARCHAR30,
                         p_need_by_date_tbl   IN PO_TBL_DATE,
                         x_results            IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type        OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- if purchase_basis is 'TEMP LABOR', the promised_date must be null
  -------------------------------------------------------------------------
  PROCEDURE promised_date(p_id_tbl             IN PO_TBL_NUMBER,
                          p_purchase_basis_tbl IN PO_TBL_VARCHAR30,
                          p_promised_date_tbl  IN PO_TBL_DATE,
                          x_results            IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                          x_result_type        OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate shipment type
  -------------------------------------------------------------------------
  PROCEDURE shipment_type(p_id_tbl            IN PO_TBL_NUMBER,
                          p_shipment_type_tbl IN PO_TBL_VARCHAR30,
       		          p_style_id_tbl      IN po_tbl_number, -- PDOI for Complex PO Project
                          p_doc_type          IN VARCHAR2,
                          x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                          x_result_type       OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- PDOI for Complex PO Project: Validate payment type.
  -------------------------------------------------------------------------
  PROCEDURE payment_type(p_id_tbl            IN PO_TBL_NUMBER,
                         po_line_id_tbl      IN PO_TBL_NUMBER,
                         p_style_id_tbl      IN PO_TBL_NUMBER,
                         p_payment_type_tbl  IN PO_TBL_VARCHAR30,
                         p_shipment_type_tbl IN PO_TBL_VARCHAR30,
                         x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type       OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate shipment num is not null, greater than zero and unique
  -------------------------------------------------------------------------
  PROCEDURE shipment_num(p_id_tbl            IN PO_TBL_NUMBER,
                         p_shipment_num_tbl  IN PO_TBL_NUMBER,
                         p_shipment_type_tbl IN PO_TBL_VARCHAR30,
                         p_po_header_id_tbl  IN PO_TBL_NUMBER,
                         p_po_line_id_tbl    IN PO_TBL_NUMBER,
                         p_draft_id_tbl      IN PO_TBL_NUMBER, -- bug 4642348
                         p_style_id_tbl      IN PO_TBL_NUMBER, -- PDOI for Complex PO Project
                         p_doc_type          IN VARCHAR2,      -- bug 4642348
                         x_result_set_id     IN OUT NOCOPY NUMBER,
                         x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type       OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is RATE or FIXED PRICE, validate quantity is not null
  -------------------------------------------------------------------------
  PROCEDURE quantity(p_id_tbl                     IN PO_TBL_NUMBER,
                     p_quantity_tbl               IN PO_TBL_NUMBER,
                     p_order_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
		     p_shipment_type_tbl          IN PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project
                     p_style_id_tbl               IN PO_TBL_NUMBER,     -- PDOI for Complex PO Project
                     p_payment_type_tbl           IN PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project
                     p_line_quantity_tbl          IN PO_TBL_NUMBER,     -- PDOI for Complex PO Project
                     x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                     x_result_type                OUT NOCOPY VARCHAR2);

 -- PDOI for Complex PO Project: Validate amount at shipment, for DELIVERY
  -- type shipment of 'complex PO with contract financing enabled'.
  -------------------------------------------------------------------------
  PROCEDURE amount(p_id_tbl                     IN PO_TBL_NUMBER,
                   p_amount_tbl                 IN PO_TBL_NUMBER,
                   p_shipment_type_tbl          IN PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project
                   p_style_id_tbl               IN PO_TBL_NUMBER,     -- PDOI for Complex PO Project
                   p_payment_type_tbl           IN PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project
                   p_line_amount_tbl            IN PO_TBL_NUMBER,     -- PDOI for Complex PO Project
                   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                   x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is not FIXED PRICE, price_override cannot be null
  -------------------------------------------------------------------------
  PROCEDURE price_override(p_id_tbl                     IN PO_TBL_NUMBER,
                           p_price_override_tbl         IN PO_TBL_NUMBER,
                           p_order_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
          	           p_shipment_type_tbl          IN PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project
                           p_style_id_tbl               IN PO_TBL_NUMBER,     -- PDOI for Complex PO Project
                           p_payment_type_tbl           IN PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project
                           p_line_unit_price_tbl        IN PO_TBL_NUMBER,     -- PDOI for Complex PO Project
                           x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is not FIXED PRICE, price_discount cannot be null
  -- and price discount cannot be less than zero or greater than 100
  -------------------------------------------------------------------------
  PROCEDURE price_discount(p_id_tbl                     IN PO_TBL_NUMBER,
                           p_price_discount_tbl         IN PO_TBL_NUMBER,
                           p_price_override_tbl         IN PO_TBL_NUMBER,
                           p_order_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
                           x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate ship_to_organization_id
  -------------------------------------------------------------------------
  PROCEDURE ship_to_organization_id(p_id_tbl                      IN PO_TBL_NUMBER,
                                    p_ship_to_organization_id_tbl IN PO_TBL_NUMBER,
                                    p_item_id_tbl                 IN PO_TBL_NUMBER,
                                    p_item_revision_tbl           IN PO_TBL_VARCHAR5,
                                    p_ship_to_location_id_tbl     IN PO_TBL_NUMBER,
                                    x_result_set_id               IN OUT NOCOPY NUMBER,
                                    x_result_type                 OUT NOCOPY VARCHAR2);


  -------------------------------------------------------------------------
  -- validate price break attributes
  -------------------------------------------------------------------------
  PROCEDURE price_break_attributes(p_id_tbl                  IN PO_TBL_NUMBER,
                                   p_from_date_tbl           IN PO_TBL_DATE,
                                   p_to_date_tbl             IN PO_TBL_DATE,
                                   p_quantity_tbl            IN PO_TBL_NUMBER,
                                   p_ship_to_org_id_tbl      IN PO_TBL_NUMBER,
                                   p_ship_to_location_id_tbl IN PO_TBL_NUMBER,
                                   x_results                 IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                   x_result_type             OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate_effective_dates
  -------------------------------------------------------------------------
  PROCEDURE effective_dates(p_id_tbl                   IN PO_TBL_NUMBER,
                            p_line_expiration_date_tbl IN PO_TBL_DATE,
                            p_to_date_tbl              IN PO_TBL_DATE,
                            p_from_date_tbl            IN PO_TBL_DATE,
                            p_header_start_date_tbl    IN PO_TBL_DATE,
                            p_header_end_date_tbl      IN PO_TBL_DATE,
                            p_price_break_lookup_code_tbl IN PO_TBL_VARCHAR30, -- bug5016163
                            x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                            x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If shipment_type is STANDARD and enforce_ship_to_loc_code is not equal
  -- to NONE, REJECT or WARNING
  -------------------------------------------------------------------------
  PROCEDURE enforce_ship_to_loc_code(p_id_tbl                       IN PO_TBL_NUMBER,
                                     p_enforce_ship_to_loc_code_tbl IN PO_TBL_VARCHAR30,
                                     p_shipment_type_tbl            IN PO_TBL_VARCHAR30,
                                     p_order_type_lookup_tbl        IN PO_TBL_VARCHAR30, -- <<PDOI Enhancement Bug#17063664>>
                                     x_results                      IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                     x_result_type                  OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If shipment_type is STANDARD and allow_sub_receipts_flag is not equal
  -- to NONE, REJECT or WARNING
  -------------------------------------------------------------------------
  PROCEDURE allow_sub_receipts_flag(p_id_tbl                      IN PO_TBL_NUMBER,
                                    p_shipment_type_tbl           IN PO_TBL_VARCHAR30,
                                    p_allow_sub_receipts_flag_tbl IN PO_TBL_VARCHAR1,
                                    p_order_type_lookup_tbl       IN PO_TBL_VARCHAR30, -- <<PDOI Enhancement Bug#17063664>>
                                    x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                    x_result_type                 OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If shipment_type is STANDARD and days_early_receipt_allowed is not null
  -- and less than zero.
  -------------------------------------------------------------------------
  PROCEDURE days_early_receipt_allowed(p_id_tbl                      IN PO_TBL_NUMBER,
                                       p_shipment_type_tbl           IN PO_TBL_VARCHAR30,
                                       p_days_early_rcpt_allowed_tbl IN PO_TBL_NUMBER,
                                       p_order_type_lookup_tbl       IN PO_TBL_VARCHAR30, -- <<PDOI Enhancement Bug#17063664>>
                                       x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                       x_result_type                 OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If shipment_type is STANDARD and receipt_days_expection_code is not null
  -- and not 'NONE', 'REJECT' not 'WARNING'
  -------------------------------------------------------------------------
  PROCEDURE receipt_days_exception_code(p_id_tbl                       IN PO_TBL_NUMBER,
                                        p_shipment_type_tbl            IN PO_TBL_VARCHAR30,
                                        p_rcpt_days_exception_code_tbl IN PO_TBL_VARCHAR30,
                                        p_order_type_lookup_tbl       IN PO_TBL_VARCHAR30, -- <<PDOI Enhancement Bug#17063664>>
                                        x_results                      IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                        x_result_type                  OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If shipment_type is STANDARD and invoice_close_tolerance is not null
  -- and less than or equal to zero or greater than or equal to 100.
  -------------------------------------------------------------------------
  PROCEDURE invoice_close_tolerance(p_id_tbl                      IN PO_TBL_NUMBER,
                                    p_shipment_type_tbl           IN PO_TBL_VARCHAR30,
                                    p_invoice_close_tolerance_tbl IN PO_TBL_NUMBER,
                                    x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                    x_result_type                 OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If shipment_type is STANDARD and receive_close_tolerance is not null
  -- and less than or equal to zero or greater than or equal to 100.
  -------------------------------------------------------------------------
  PROCEDURE receive_close_tolerance(p_id_tbl                      IN PO_TBL_NUMBER,
                                    p_shipment_type_tbl           IN PO_TBL_VARCHAR30,
                                    p_receive_close_tolerance_tbl IN PO_TBL_NUMBER,
                                    x_results                     IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                    x_result_type                 OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Validate that receiving routing id exists in rcv_routing_headers
  -------------------------------------------------------------------------
  PROCEDURE receiving_routing_id(p_id_tbl                   IN PO_TBL_NUMBER,
                                 p_shipment_type_tbl        IN PO_TBL_VARCHAR30,
                                 p_receiving_routing_id_tbl IN PO_TBL_NUMBER,
                                 p_order_type_lookup_tbl    IN  po_tbl_varchar30, -- <<PDOI Enhancement Bug#17063664>>
                                 x_result_set_id            IN OUT NOCOPY NUMBER,
                                 x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Validate accrue_on_receipt_flag is Y or N, if not null.
  -------------------------------------------------------------------------
  PROCEDURE accrue_on_receipt_flag(p_id_tbl                     IN PO_TBL_NUMBER,
                                   p_accrue_on_receipt_flag_tbl IN PO_TBL_VARCHAR1,
                                   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                   x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- PDOI for Complex PO Project: Validate advance amount at shipment.
  -------------------------------------------------------------------------
  PROCEDURE advance_amt_le_amt(p_id_tbl                        IN PO_TBL_NUMBER,
                               p_payment_type_tbl              IN PO_TBL_VARCHAR30,
                               p_advance_tbl                   IN PO_TBL_NUMBER,
                               p_amount_tbl                    IN PO_TBL_NUMBER,
                               p_quantity_tbl                  IN PO_TBL_NUMBER,
                               p_price_tbl                     IN PO_TBL_NUMBER,
                               x_results                       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                               x_result_type                   OUT NOCOPY    VARCHAR2);


   -------------------------------------------------------------------------------------
   -- Validate price_breaks_flag = Y for the given style
   -------------------------------------------------------------------------------------
   PROCEDURE style_related_info(p_id_tbl               IN              po_tbl_number,
                                p_style_id_tbl         IN              po_tbl_number,
                                x_result_set_id        IN OUT NOCOPY   NUMBER,
                                x_result_type          OUT NOCOPY      VARCHAR2);

  -------------------------------------------------------------------------
  -- tax_code_id and tax_name must be valid if either is not null;
  -- If tax_name and tax_code_id are both not null,
  -- then tax_code_id and tax_name must be a valid combination.
  -------------------------------------------------------------------------
  PROCEDURE tax_name(p_id_tbl            IN PO_TBL_NUMBER,
                     p_tax_name_tbl      IN PO_TBL_VARCHAR30,
                     p_tax_code_id_tbl   IN PO_TBL_NUMBER,
                     p_need_by_date_tbl  IN PO_TBL_DATE,
                     p_allow_tax_code_override IN VARCHAR2,
                     p_operating_unit    IN NUMBER,
                     x_result_set_id     IN OUT NOCOPY NUMBER,
                     x_result_type       OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------
-- fob_lookup_code must be valid in PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE fob_lookup_code(p_id_tbl                IN              po_tbl_number,
                             p_fob_lookup_code_tbl   IN              po_tbl_varchar30,
                             x_result_set_id         IN OUT NOCOPY   NUMBER,
                             x_result_type           OUT NOCOPY      VARCHAR2);

-------------------------------------------------------------------------
-- freight_terms must be valid in PO_LOOKUP_CODES
-------------------------------------------------------------------------
   PROCEDURE freight_terms(p_id_tbl              IN              po_tbl_number,
                           p_freight_terms_tbl   IN              po_tbl_varchar30,
                           x_result_set_id       IN OUT NOCOPY   NUMBER,
                           x_result_type         OUT NOCOPY      VARCHAR2);

-------------------------------------------------------------------------
-- freight_carrier must be valid in ORG_FREIGHT
-------------------------------------------------------------------------
   PROCEDURE freight_carrier(p_id_tbl                IN              po_tbl_number,
                             p_freight_carrier_tbl   IN              po_tbl_varchar30,
                             p_inventory_org_id      IN              NUMBER,
                             x_result_set_id         IN OUT NOCOPY   NUMBER,
                             x_result_type           OUT NOCOPY      VARCHAR2);

-------------------------------------------------------------------------
-- validate qty_rcv_exception_code against PO_LOOKUP_CODES
-------------------------------------------------------------------------
  PROCEDURE qty_rcv_exception_code(
    p_id_tbl                       IN              po_tbl_number,
    p_qty_rcv_exception_code_tbl   IN              po_tbl_varchar30,
    x_result_set_id                IN OUT NOCOPY   NUMBER,
    x_result_type                  OUT NOCOPY      VARCHAR2);

-------------------------------------------------------------------------
-- Cannot create price breaks for Amount-Based or Fixed Price lines in a
-- Blanket Purchase Agreement.
-------------------------------------------------------------------------
  PROCEDURE price_break(
    p_id_tbl                       IN              po_tbl_number,
    p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
    x_results                      IN OUT NOCOPY   po_validation_results_type,
    x_result_type                  OUT NOCOPY      VARCHAR2);

-------------------------------------------------------------------------
-- <<PDOI Enhancement Bug#17063664>>
-- Validate that inspection_reqd_flag is N for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE inspection_reqd_flag(
    p_id_tbl                     IN              po_tbl_number,
    p_shipment_type_tbl          IN              po_tbl_varchar30,
    p_inspection_reqd_flag_tbl   IN              po_tbl_varchar1,
    p_order_type_lookup_tbl      IN              po_tbl_varchar30,
    x_result_set_id              IN OUT NOCOPY   NUMBER,
    x_result_type                OUT NOCOPY      VARCHAR2);

-------------------------------------------------------------------------
-- <<PDOI Enhancement Bug#17063664>>
-- Validate that days_late_rcpt_allowed is N for Fixed Price and Rate based lines.
-------------------------------------------------------------------------
  PROCEDURE days_late_rcpt_allowed(
    p_id_tbl                     IN              po_tbl_number,
    p_shipment_type_tbl          IN              po_tbl_varchar30,
    p_days_late_rcpt_allowed_tbl IN              po_tbl_number,
    p_order_type_lookup_tbl      IN              po_tbl_varchar30,
    x_result_set_id              IN OUT NOCOPY   NUMBER,
    x_result_type                OUT NOCOPY      VARCHAR2);

END PO_VAL_SHIPMENTS2;

/
