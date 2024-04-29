--------------------------------------------------------
--  DDL for Package PO_VAL_HEADERS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_HEADERS2" AUTHID CURRENT_USER AS
  -- $Header: PO_VAL_HEADERS2.pls 120.11.12010000.3 2009/10/07 09:42:36 sknandip ship $

  -------------------------------------------------------------------------
  -- po_header_id cannot be null and must not exist in Transaction header table.
  -- Called for the create case.
  -------------------------------------------------------------------------
  PROCEDURE po_header_id(p_id_tbl           IN po_tbl_number,
                         p_po_header_id_tbl IN po_tbl_number,
                         x_result_set_id    IN OUT NOCOPY NUMBER,
                         x_result_type      OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- type_lookup_code cannot be null and must be equal to
  -- BLANKET, STANDARD or QUOTATION.
  -------------------------------------------------------------------------
  PROCEDURE type_lookup_code(p_id_tbl               IN po_tbl_number,
                             p_type_lookup_code_tbl IN po_tbl_varchar30,
                             x_results              IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                             x_result_type          OUT NOCOPY VARCHAR2);

  -----------------------------------------------------------------------------------------
  -- document_num must not null, must be unique, greater than or equal to zero and be of the correct type.
  -----------------------------------------------------------------------------------------
  PROCEDURE document_num(
     p_id_tbl                   IN             po_tbl_number,
     p_po_header_id_tbl         IN             po_tbl_number,
     p_document_num_tbl         IN             po_tbl_varchar30,
     p_type_lookup_code_tbl     IN             po_tbl_varchar30,
     p_manual_po_num_type       IN             VARCHAR2,
     p_manual_quote_num_type    IN             VARCHAR2,
     x_results                  IN OUT NOCOPY  po_validation_results_type,
     x_result_set_id            IN OUT NOCOPY  NUMBER,
     x_result_type              OUT NOCOPY     VARCHAR2);

  -------------------------------------------------------------------------
  -- validate currency_code not null and against FND_CURRENCIES.
  -------------------------------------------------------------------------
  PROCEDURE currency_code(p_id_tbl            IN po_tbl_number,
                          p_currency_code_tbl IN po_tbl_varchar30,
                          x_result_set_id     IN OUT NOCOPY NUMBER,
                          x_result_type       OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If currency_code equals functional currency code, rate_type, rate_date and rate must be null.
  -- If currency_code does not equal functional currency code, validate rate_type not null,
  -- validate rate_type against gl_daily_conversion_type_v, validate rate is not null and positive,
  -- validate rate against g1_currency_api.get_rate().
  -------------------------------------------------------------------------
  PROCEDURE rate_info(p_id_tbl              IN po_tbl_number,
                      p_currency_code_tbl   IN PO_TBL_VARCHAR30,
                      p_rate_type_tbl       IN PO_TBL_VARCHAR30,
                      p_rate_tbl            IN po_tbl_number,
                      p_rate_date_tbl       IN po_tbl_date,
                      p_func_currency_code  IN VARCHAR2,
                      p_set_of_books_id     IN NUMBER,
                      x_result_set_id       IN OUT NOCOPY NUMBER,
                      x_results             IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                      x_result_type         OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Agent Id must not be null and validate against PO_AGENTS.
  -------------------------------------------------------------------------
  PROCEDURE agent_id(p_id_tbl        IN po_tbl_number,
                     p_agent_id_tbl  IN po_tbl_number,
                     x_result_set_id IN OUT NOCOPY NUMBER,
                     x_result_type   OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate vendorId is Not Null
  -- validate vendorSiteId is Not Null
  -- validate vendor_id using po_suppliers_val_v
  -- validate vendor_site_id using po_supplier_sites_val_v
  -- validate vendor_contact_id using po_vendor_contacts
  -- validate vendor site CCR if approval status is APPROVED.
  -------------------------------------------------------------------------
  PROCEDURE vendor_info(p_id_tbl                IN po_tbl_number,
                        p_vendor_id_tbl         IN po_tbl_number,
                        p_vendor_site_id_tbl    IN po_tbl_number,
                        p_vendor_contact_id_tbl IN po_tbl_number,
		        p_type_lookup_code_tbl    IN po_tbl_varchar30, --8913559 bug
                        p_federal_instance      IN VARCHAR,
                        x_result_set_id         IN OUT NOCOPY NUMBER,
                        x_results               IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                        x_result_type           OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- ShipToLocationId must not be null and valid in HR_LOCATIONS.
  -------------------------------------------------------------------------
  PROCEDURE ship_to_location_id(p_id_tbl                  IN po_tbl_number,
                                p_ship_to_location_id_tbl IN po_tbl_number,
                                -- Bug 7007502: Added new param p_type_lookup_code_tbl
                                p_type_lookup_code_tbl    IN po_tbl_varchar30,
                                x_result_set_id           IN OUT NOCOPY NUMBER,
                                x_result_type             OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- BillToLocationId must not be null and validate against HR_LOCATIONS.
  -------------------------------------------------------------------------
  PROCEDURE bill_to_location_id(p_id_tbl                  IN po_tbl_number,
                                p_bill_to_location_id_tbl IN po_tbl_number,
                                -- Bug 7007502: Added new param p_type_lookup_code_tbl
                                p_type_lookup_code_tbl    IN po_tbl_varchar30,
                                x_result_set_id           IN OUT NOCOPY NUMBER,
                                x_result_type             OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate ship_via_lookup_code against ORG_FREIGHT
  -------------------------------------------------------------------------
  PROCEDURE ship_via_lookup_code(p_id_tbl                   IN po_tbl_number,
                                 p_ship_via_lookup_code_tbl IN PO_TBL_VARCHAR30,
                                 p_inventory_org_id         IN NUMBER,
                                 x_result_set_id            IN OUT NOCOPY NUMBER,
                                 x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate fob_lookup_code against PO_LOOKUP_CODES
  -------------------------------------------------------------------------
  PROCEDURE fob_lookup_code(p_id_tbl              IN po_tbl_number,
                            p_fob_lookup_code_tbl IN PO_TBL_VARCHAR30,
                            x_result_set_id       IN OUT NOCOPY NUMBER,
                            x_result_type         OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate freight_terms_lookup_code against PO_LOOKUP_CODES
  -------------------------------------------------------------------------
  PROCEDURE freight_terms_lookup_code(p_id_tbl                   IN po_tbl_number,
                                      p_freight_terms_lookup_tbl IN PO_TBL_VARCHAR30,
                                      x_result_set_id            IN OUT NOCOPY NUMBER,
                                      x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate shipping_control against PO_LOOKUP_CODES
  -------------------------------------------------------------------------
  PROCEDURE shipping_control(p_id_tbl               IN po_tbl_number,
                             p_shipping_control_tbl IN PO_TBL_VARCHAR30,
                             x_result_set_id        IN OUT NOCOPY NUMBER,
                             x_result_type          OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate acceptance_due_date is not null if acceptance_required_flag = Y.
  -- Only called for Blanket and SPO.
  -------------------------------------------------------------------------
  PROCEDURE acceptance_due_date(p_id_tbl                   IN po_tbl_number,
                                p_acceptance_reqd_flag_tbl IN PO_TBL_VARCHAR1,
                                p_acceptance_due_date_tbl  IN po_tbl_date,
                                x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate cancel_flag = N.  Only called for Blanket and SPO.
  -------------------------------------------------------------------------
  PROCEDURE cancel_flag(p_id_tbl          IN po_tbl_number,
                        p_cancel_flag_tbl IN PO_TBL_VARCHAR1,
                        x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                        x_result_type     OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate closed_code = OPEN.  Only called for Blanket and SPO.
  -------------------------------------------------------------------------
  PROCEDURE closed_code(p_id_tbl                   IN po_tbl_number,
                        p_closed_code_tbl          IN PO_TBL_VARCHAR30,
                        p_acceptance_reqd_flag_tbl IN PO_TBL_VARCHAR1,
                        x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                        x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate print_count = 0.  Only called for Blanket and SPO.
  -------------------------------------------------------------------------
  PROCEDURE print_count(p_id_tbl                   IN po_tbl_number,
                        p_print_count_tbl          IN po_tbl_number,
                        p_approval_status_tbl      IN PO_TBL_VARCHAR30,
                        x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                        x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate approval_status = INCOMPLETE, APPROVED, INITIATE APPROVAL.
  -- Only called for Blanket and SPO.
  -------------------------------------------------------------------------
  PROCEDURE approval_status(p_id_tbl                   IN po_tbl_number,
                            p_approval_status_tbl      IN PO_TBL_VARCHAR30,
                            x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                            x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate amount_to_encumber > 0
  -------------------------------------------------------------------------
  PROCEDURE amount_to_encumber(p_id_tbl                 IN po_tbl_number,
                               p_amount_to_encumber_tbl IN po_tbl_number,
                               x_results                IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                               x_result_type            OUT NOCOPY VARCHAR2);

------------------------------------------------------------------------------
-- Validate style_id exists in system, is active and is not enabled for complex work.
------------------------------------------------------------------------------
   PROCEDURE style_id(p_id_tbl                       IN              po_tbl_number,
                      p_style_id_tbl                 IN              po_tbl_number,
                      x_result_set_id                IN OUT NOCOPY   NUMBER,
                      x_result_type                  OUT NOCOPY      VARCHAR2);

   -- bug4911388
  -------------------------------------------------------------------------
  -- validate that acceptance_reuqired_flag has correct value
  -------------------------------------------------------------------------
   PROCEDURE acceptance_required_flag
   ( p_id_tbl IN PO_TBL_NUMBER,
     p_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
     p_acceptance_required_flag_tbl IN PO_TBL_VARCHAR1,
     x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
     x_result_type OUT NOCOPY VARCHAR2
   );


   -- bug5352625
  -------------------------------------------------------------------------
  -- validate that amount limit is valid
  -------------------------------------------------------------------------
   PROCEDURE amount_limit
   ( p_id_tbl IN PO_TBL_NUMBER,
     p_amount_limit_tbl IN PO_TBL_NUMBER,
     p_amount_agreed_tbl IN PO_TBL_NUMBER,
     x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
     x_result_type OUT NOCOPY VARCHAR2
   );


END PO_VAL_HEADERS2;

/
