--------------------------------------------------------
--  DDL for Package PO_VAL_LINES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VAL_LINES2" AUTHID CURRENT_USER AS
  -- $Header: PO_VAL_LINES2.pls 120.17.12010000.10 2014/07/03 06:12:35 jiarsun ship $

  -------------------------------------------------------------------------
  -- The lookup code specified in over_tolerance_error_flag with the lookup type
  -- 'RECEIVING CONTROL LEVEL' has to exist in po_lookup_codes and still active.
  -- This method is called only for Standard PO and quotation documents
  -------------------------------------------------------------------------
  PROCEDURE over_tolerance_err_flag(p_id_tbl                      IN po_tbl_number,
                                    p_over_tolerance_err_flag_tbl IN po_tbl_varchar30,
                                    x_result_set_id               IN OUT NOCOPY NUMBER,
                                    x_result_type                 OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Expiration date on the line cannot be earlier than the header effective start date and
  -- cannot be later than header effective end date
  -------------------------------------------------------------------------
  PROCEDURE expiration_date_blanket(p_id_tbl                IN po_tbl_number,
                                    p_expiration_date_tbl   IN po_tbl_date,
                                    p_header_start_date_tbl IN po_tbl_date,
                                    p_header_end_date_tbl   IN po_tbl_date,
                                    x_results               IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                    x_result_type           OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- For blanket document with purchase type 'TEMP LABOR', the global agreement
  -- flag has to be 'Y'.  Global_agreement_flag and outside operation flag
  -- cannot both be 'Y'
  -------------------------------------------------------------------------
  PROCEDURE global_agreement_flag(p_id_tbl                    IN po_tbl_number,
                                  p_global_agreement_flag_tbl IN po_tbl_varchar1,
                                  p_purchase_basis_tbl        IN po_tbl_varchar30,
                                  p_line_type_id_tbl          IN PO_TBL_NUMBER,
                                  x_result_set_id             IN OUT NOCOPY NUMBER,
                                  x_results                   IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                  x_result_type               OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is 'RATE', amount has to be null
  -------------------------------------------------------------------------
  PROCEDURE amount_blanket(p_id_tbl                     IN po_tbl_number,
                           p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                           p_amount_tbl                 IN po_tbl_number,
                           x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                           x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If services procurement is not enabled, the order_type_lookup_code cannot
  -- be  'FIXED PRICE' or 'RATE'.
  -------------------------------------------------------------------------
  PROCEDURE order_type_lookup_code(p_id_tbl                     IN po_tbl_number,
                                   p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                                   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                   x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If purchase basis is not 'TEMP LABOR' or document type is not STANDARD ,
  -- contractor first name and last name fields should be empty
  -------------------------------------------------------------------------
  PROCEDURE contractor_name(p_id_tbl                    IN po_tbl_number,
                            p_doc_type                  IN VARCHAR2,
                            p_purchase_basis_tbl        IN po_tbl_varchar30,
                            p_contractor_last_name_tbl  IN po_tbl_varchar2000,
                            p_contractor_first_name_tbl IN po_tbl_varchar2000,
                            x_results                   IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                            x_result_type               OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If purchase basis is TEMP LABOR, then job id must be null
  -------------------------------------------------------------------------
  PROCEDURE job_id(p_id_tbl                    IN po_tbl_number,
                   p_job_id_tbl                IN po_tbl_number,
                   p_job_business_group_id_tbl IN po_tbl_number,
                   p_purchase_basis_tbl        IN po_tbl_varchar30,
                   p_category_id_tbl           IN po_tbl_number,
                   x_result_set_id             IN OUT NOCOPY NUMBER,
                   x_results                   IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                   x_result_type               OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If services procurement not enabled, order_type_lookup_code cannot be
  -- 'FIXED PRICE' or 'RATE'
  -------------------------------------------------------------------------
  PROCEDURE job_business_group_id(p_id_tbl                    IN po_tbl_number,
                                  p_job_id_tbl                IN po_tbl_number,
                                  p_job_business_group_id_tbl IN po_tbl_number,
                                  p_purchase_basis_tbl        IN po_tbl_varchar30,
                                  x_result_set_id             IN OUT NOCOPY NUMBER,
                                  x_result_type               OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If purchase_basis = 'TEMP LABOR', then capital_expense_flag cannot = 'Y'
  -------------------------------------------------------------------------
  PROCEDURE capital_expense_flag(p_id_tbl                   IN po_tbl_number,
                                 p_purchase_basis_tbl       IN po_tbl_varchar30,
                                 p_capital_expense_flag_tbl IN po_tbl_varchar1,
                                 x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                 x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If purchase_basis = 'TEMP LABOR', then un_number must be null
  -------------------------------------------------------------------------
  PROCEDURE un_number_id(p_id_tbl             IN po_tbl_number,
                         p_purchase_basis_tbl IN po_tbl_varchar30,
                         p_un_number_id_tbl   IN po_tbl_number,
                         x_result_set_id      IN OUT NOCOPY NUMBER,
                         x_results            IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                         x_result_type        OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If purchase_basis = 'TEMP LABOR', then un_number must be null
  -------------------------------------------------------------------------
  PROCEDURE hazard_class_id(p_id_tbl              IN po_tbl_number,
                            p_purchase_basis_tbl  IN po_tbl_varchar30,
                            p_hazard_class_id_tbl IN po_tbl_number,
                            x_result_set_id       IN OUT NOCOPY NUMBER,
                            x_results             IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                            x_result_type         OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is 'FIXED PRICE', 'RATE', or 'AMOUNT', item_id has to be null
  -------------------------------------------------------------------------
  PROCEDURE item_id(p_id_tbl                     IN po_tbl_number,
                    p_item_id_tbl                IN po_tbl_number,
                    p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                    p_line_type_id_tbl           IN po_tbl_number,
                    p_inventory_org_id           IN NUMBER,
                    x_result_set_id              IN OUT NOCOPY NUMBER,
                    x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                    x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Make sure that the item_description is populated, and also need to find out if it is different
  -- from what is setup for the item. Would not allow item_description update  if item attribute
  -- allow_item_desc_update_flag is N.
  -------------------------------------------------------------------------
  PROCEDURE item_description(p_id_tbl                     IN po_tbl_number,
                             p_item_description_tbl       IN po_tbl_varchar2000,
                             p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                             p_item_id_tbl                IN po_tbl_number,
                             p_create_or_update_item      IN VARCHAR2,
                             p_inventory_org_id           IN NUMBER,
                             x_result_set_id              IN OUT NOCOPY NUMBER,
                             x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- check to see if x_item_unit_of_measure is valid in mtl_item_uoms_view
  -------------------------------------------------------------------------
  PROCEDURE unit_meas_lookup_code(p_id_tbl                     IN po_tbl_number,
                                  p_unit_meas_lookup_code_tbl  IN po_tbl_varchar30,
                                  p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                                  p_item_id_tbl                IN po_tbl_number,
                                  p_line_type_id_tbl           IN po_tbl_number,
                                  p_inventory_org_id           IN NUMBER,
                                  x_result_set_id              IN OUT NOCOPY NUMBER,
                                  x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                  x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  --  if order_type_lookup_code is FIXED PRICE or RATE, or item id is null, then item revision has to be NULL.
  -- Check to see if there are x_item_revision exists in mtl_item_revisions table
  -------------------------------------------------------------------------
  PROCEDURE item_revision(p_id_tbl                     IN po_tbl_number,
                          p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                          p_item_revision_tbl          IN po_tbl_varchar5,
                          p_item_id_tbl                IN po_tbl_number,
                          x_result_set_id              IN OUT NOCOPY NUMBER,
                          x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                          x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- validate and make sure category_id is a valid category within the default category set for Purchasing.
  -- Validate if X_category_id belong to the X_item.  Check if the Purchasing Category set
  -- has 'Validate flag' ON. If Yes, we will validate the Category to exist in the 'Valid Category List'.
  -- If No, we will just validate if the category is Enable and Active.
  -------------------------------------------------------------------------
  PROCEDURE category_id(p_id_tbl                     IN po_tbl_number,
                        p_category_id_tbl            IN po_tbl_number,
                        p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                        p_item_id_tbl                IN po_tbl_number,
                        p_inventory_org_id           IN NUMBER,
                        x_result_set_id              IN OUT NOCOPY NUMBER,
                        x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                        x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Validate ip_category_id is not empty for Blanket and Quotation;
  -- Validate ip_category_id is valid if not empty
  -------------------------------------------------------------------------
   PROCEDURE ip_category_id(
      p_id_tbl                       IN              po_tbl_number,
      p_ip_category_id_tbl           IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2);

  -------------------------------------------------------------------------
  --If order_type_lookup_code is not  'FIXED PRICE', unit_price cannot be null and cannot be less than zero.
  --If line_type_id is not null and order_type_lookup_code is 'AMOUNT',
  -- unit_price should be the same as the one defined in the line_type.
  --If order_type_lookup_code is 'FIXED PRICE', unit_price has to be null.
  -------------------------------------------------------------------------
  PROCEDURE unit_price(p_id_tbl                     IN po_tbl_number,
                       p_unit_price_tbl             IN po_tbl_number,
                       p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                       p_line_type_id_tbl           IN po_tbl_number,
                       x_result_set_id              IN OUT NOCOPY NUMBER,
                       x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                       x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', quantity cannot be less than zero
  -- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', quantity has to be null.
  -------------------------------------------------------------------------
  PROCEDURE quantity(p_id_tbl                     IN po_tbl_number,
                     p_quantity_tbl               IN po_tbl_number,
                     p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                     x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                     x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', amount has to be null
  -------------------------------------------------------------------------
  PROCEDURE amount(p_id_tbl                     IN po_tbl_number,
                   p_amount_tbl                 IN po_tbl_number,
                   p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                   x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                   x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- For rate based temp labor line, the currency rate_type cannot be 'user'
  -------------------------------------------------------------------------
  PROCEDURE rate_type(p_id_tbl                     IN po_tbl_number,
                      p_rate_type_tbl              IN po_tbl_varchar30,
                      p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                      x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                      x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Line num must be populated and cannot be <= 0.
  -- Line num has to be unique in a requisition.
  -------------------------------------------------------------------------
  PROCEDURE line_num(p_id_tbl                     IN po_tbl_number,
                     p_po_header_id_tbl           IN po_tbl_number,
                     p_line_num_tbl               IN po_tbl_number,
                     p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                     p_draft_id_tbl               IN PO_TBL_NUMBER,     -- bug5129752
                     x_result_set_id              IN OUT NOCOPY NUMBER,
                     x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                     x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Po_line_id must be populated and unique.
  -------------------------------------------------------------------------
  PROCEDURE po_line_id(p_id_tbl           IN PO_TBL_NUMBER,
                       p_po_line_id_tbl IN PO_TBL_NUMBER,
                       p_po_header_id_tbl IN PO_TBL_NUMBER,
                       x_result_set_id    IN OUT NOCOPY NUMBER,
                       x_result_type      OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Line type id must be populated and exist in po_line_types_val_v
  -------------------------------------------------------------------------
  PROCEDURE line_type_id(p_id_tbl           IN PO_TBL_NUMBER,
                         p_line_type_id_tbl IN PO_TBL_NUMBER,
                         x_result_set_id    IN OUT NOCOPY NUMBER,
                         x_result_type      OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Validate style related information.
  -------------------------------------------------------------------------
  PROCEDURE style_related_info(p_id_tbl                IN              po_tbl_number,
                               p_style_id_tbl          IN              po_tbl_number,
                               p_line_type_id_tbl      IN              po_tbl_number,
                               p_purchase_basis_tbl    IN              po_tbl_varchar30,
                               x_result_set_id         IN OUT NOCOPY   NUMBER,
                               x_result_type           OUT NOCOPY      VARCHAR2);

  -------------------------------------------------------------------------
  -- If price_type_lookup_code is not null, it has to be a valid price type in po_lookup_codes
  -------------------------------------------------------------------------
  PROCEDURE price_type_lookup_code(p_id_tbl                     IN PO_TBL_NUMBER,
                                   p_price_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
                                   x_result_set_id              IN OUT NOCOPY NUMBER,
                                   x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  --Start date is required for Standard PO with purchase basis 'TEMP LABOR'
  --Expiration date if provided should be later than the start date
  --If purchase basis is not 'TEMP LABOR', start_date and expiration_date have to be null
  -------------------------------------------------------------------------
  PROCEDURE start_date_standard(p_id_tbl              IN PO_TBL_NUMBER,
                                p_start_date_tbl      IN PO_TBL_DATE,
                                p_expiration_date_tbl IN PO_TBL_DATE,
                                p_purchase_basis_tbl  IN PO_TBL_VARCHAR30,
                                x_results             IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                x_result_type         OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is not 'RATE' or 'FIXED PRICE', and item_id is not null, then bom_item_type cannot be 1 or 2.
  -------------------------------------------------------------------------
  PROCEDURE item_id_standard(p_id_tbl                     IN PO_TBL_NUMBER,
                             p_item_id_tbl                IN PO_TBL_NUMBER,
                             p_order_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
                             p_inventory_org_id           IN NUMBER,
                             x_result_set_id              IN OUT NOCOPY NUMBER,
                             x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Quantity cannot be zero for SPO
  -- And quantity cannot be empty for SPO if order type is QUANTITY/AMOUNT
  -------------------------------------------------------------------------
  PROCEDURE quantity_standard(p_id_tbl                     IN PO_TBL_NUMBER,
                              p_quantity_tbl               IN PO_TBL_NUMBER,
                              p_order_type_lookup_code_tbl IN po_tbl_varchar30,
                              x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                              x_result_type                OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', amount cannot be null
  -------------------------------------------------------------------------
  PROCEDURE amount_standard(p_id_tbl                     IN PO_TBL_NUMBER,
                            p_amount_tbl                 IN PO_TBL_NUMBER,
                            p_order_type_lookup_code_tbl IN PO_TBL_VARCHAR30,
                            x_results                    IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                            x_result_type                OUT NOCOPY VARCHAR2);

-- bug5016163 START
-------------------------------------------------------------------------
--  Price break lookup code should be valid
-------------------------------------------------------------------------
   PROCEDURE price_break_lookup_code(
      p_id_tbl                     IN              po_tbl_number,
      p_price_break_lookup_code_tbl IN              po_tbl_varchar30,
      p_global_agreement_flag_tbl   IN               po_tbl_varchar1,
      p_order_type_lookup_code_tbl  IN              po_tbl_varchar30,
      p_purchase_basis_tbl          IN              po_tbl_varchar30,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2);

-- bug5016163 END

  -------------------------------------------------------------------------
  --  If allow_price_override_flag is 'N', then not_to_exceed_price has to be null.
  -- If not_to_exceed_price is not null, then it cannot be less than unit_price.
  -------------------------------------------------------------------------
  PROCEDURE not_to_exceed_price(p_id_tbl                   IN PO_TBL_NUMBER,
                                p_not_to_exceed_price_tbl  IN PO_TBL_NUMBER,
                                p_allow_price_override_tbl IN PO_TBL_VARCHAR1,
                                p_unit_price_tbl           IN PO_TBL_NUMBER,
                                x_results                  IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE,
                                x_result_type              OUT NOCOPY VARCHAR2);

  -------------------------------------------------------------------------
  -- Validate ip_category_id is valid if not empty
  -------------------------------------------------------------------------
   PROCEDURE ip_category_id_update(
      p_id_tbl                       IN              po_tbl_number,
      p_ip_category_id_tbl           IN              po_tbl_number,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2);

  -----------------------------------------------------------------------------
  -- We need to validate UOM against po_lines_all and po_units_of_measure_val_v
  -----------------------------------------------------------------------------
  PROCEDURE uom_update(p_id_tbl                       IN              po_tbl_number,
                       p_unit_meas_lookup_code_tbl    IN              po_tbl_varchar30,
                       p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
                       p_po_header_id_tbl             IN              po_tbl_number,
                       p_po_line_id_tbl               IN              po_tbl_number,
                       x_results                      IN OUT NOCOPY   po_validation_results_type,
                       x_result_set_id                IN OUT NOCOPY   NUMBER,
                       x_result_type                  OUT NOCOPY      VARCHAR2);

   -------------------------------------------------------------------------
   -- Make sure that the item_description can be different from what is setup in the item master.
   -- Would not allow item_description update if item attribute allow_item_desc_update_flag is N.
   -- Also need to check the value in po_lines_all to make sure it is the same there, if necessary.
   -------------------------------------------------------------------------
   PROCEDURE item_desc_update(p_id_tbl                       IN              po_tbl_number,
                              p_item_description_tbl         IN              po_tbl_varchar2000,
                              p_item_id_tbl                  IN              po_tbl_number,
                              p_inventory_org_id             IN              NUMBER,
                              p_po_header_id_tbl             IN              po_tbl_number,
                              p_po_line_id_tbl               IN              po_tbl_number,
                              x_results                      IN OUT NOCOPY   po_validation_results_type,
                              x_result_set_id                IN OUT NOCOPY   NUMBER,
                              x_result_type                  OUT NOCOPY      VARCHAR2);

   ----------------------------------------------------------------------------------------
   -- Called in create case for Blanket AND SPO, negotiated_by_preparer must be 'Y' or 'N'.
   ----------------------------------------------------------------------------------------
   PROCEDURE negotiated_by_preparer(
      p_id_tbl                       IN              po_tbl_number,
      p_negotiated_by_preparer_tbl   IN              po_tbl_varchar1,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2);

   --------------------------------------------------------------------------------------
   -- Called in update case for Blanket, negotiated_by_preparer must be NULL, 'Y' or 'N'.
   --------------------------------------------------------------------------------------
   PROCEDURE negotiated_by_prep_update(
      p_id_tbl                       IN              po_tbl_number,
      p_negotiated_by_preparer_tbl   IN              po_tbl_varchar1,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2);

   -------------------------------------------------------------------------
   -- If either item_id or job_id are populated, then you are not allowed to change the po_category_id
   -- If change is allowed, the new category_id must be valid.
   -------------------------------------------------------------------------
   PROCEDURE category_id_update(
      p_id_tbl                       IN              po_tbl_number,
      p_category_id_tbl              IN              po_tbl_number,
      p_po_line_id_tbl               IN              po_tbl_number,
      p_order_type_lookup_code_tbl   IN              po_tbl_varchar30,
      p_item_id_tbl                  IN              po_tbl_number,
      p_job_id_tbl                   IN              po_tbl_number,
      p_inventory_org_id             IN              NUMBER,
      x_result_set_id                IN OUT NOCOPY   NUMBER,
      x_results                      IN OUT NOCOPY   po_validation_results_type,
      x_result_type                  OUT NOCOPY      VARCHAR2);

   -------------------------------------------------------------------------
   -- In the UPDATE case, unit_price cannot be negative.  Also handle #DEL.
   -------------------------------------------------------------------------
   PROCEDURE unit_price_update(
      p_id_tbl         IN              po_tbl_number,
      p_po_line_id_tbl IN              po_tbl_number, -- bug5008206
      p_draft_id_tbl   IN              po_tbl_number, -- bug5258790
      p_unit_price_tbl IN              po_tbl_number,
      x_results        IN OUT NOCOPY   po_validation_results_type,
      x_result_set_id  IN OUT NOCOPY   NUMBER, -- bug5008206
      x_result_type    OUT NOCOPY      VARCHAR2);

   -- bug5258790 START
   PROCEDURE amount_update
   (  p_id_tbl          IN              po_tbl_number,
      p_po_line_id_tbl  IN              po_tbl_number, -- bug5008206
      p_draft_id_tbl    IN              po_tbl_number,
      p_amount_tbl      IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_set_id   IN OUT NOCOPY   NUMBER,        -- bug5008206
      x_result_type     OUT NOCOPY      VARCHAR2
   );
   -- bug5258790 END
   -- bug8633959 START
   -------------------------------------------------------------------------
   -- Check for the valid category selected from the Category LOV in BWC
   -------------------------------------------------------------------------
   PROCEDURE check_valid_category
   (
      p_category      IN VARCHAR2,
      x_results       OUT NOCOPY VARCHAR2,
      x_result_msg    OUT NOCOPY VARCHAR2
   );
     PROCEDURE category_combination_valid
   (  p_po_line_id_tbl  IN              po_tbl_number,
      p_category_id_tbl IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_type     OUT NOCOPY      VARCHAR2
   );

   -- bug8633959 END

   -- bug14075368 START
   -------------------------------------------------------------------------
   -- Check for the valid item selected from the Item LOV in BWC
   -------------------------------------------------------------------------
   PROCEDURE check_valid_item
   (
      p_item          IN VARCHAR2,
      x_results       OUT NOCOPY VARCHAR2,
      x_result_msg    OUT NOCOPY VARCHAR2
   );
     PROCEDURE item_combination_valid
   (  p_po_line_id_tbl  IN              po_tbl_number,
      p_item_id_tbl     IN              po_tbl_number,
      x_results         IN OUT NOCOPY   po_validation_results_type,
      x_result_type     OUT NOCOPY      VARCHAR2
   );

   -- bug14075368 END

   -- <PDOI Enhancement Bug#17063664 START>
     PROCEDURE validate_source_doc(
                       p_id_tbl                       IN              po_tbl_number,
                       p_from_header_id_tbl           IN              po_tbl_number,
                       p_from_line_id_tbl             IN              po_tbl_number,
                       p_contract_id_tbl              IN              po_tbl_number,
                       p_org_id_tbl                   IN              po_tbl_number,
                       p_item_id_tbl                  IN              po_tbl_number,
                       p_item_rev_tbl                 IN              po_tbl_varchar5,
                       p_item_descp_tbl               IN              po_tbl_varchar2000,
                       p_job_id_tbl                   IN              po_tbl_number,
                       p_order_type_lookup_tbl        IN              po_tbl_varchar30,
                       p_purchase_basis_tbl           IN              po_tbl_varchar30,
                       p_matching_basis_tbl           IN              po_tbl_varchar30,
                       p_category_id                  IN              po_tbl_number,
                       p_uom_tbl                      IN              po_tbl_varchar30,
                       p_vendor_id_tbl                IN              po_tbl_number,
                       p_vendor_site_id_tbl           IN              po_tbl_number,
                       p_currency_code_tbl            IN              po_tbl_varchar30,
                       p_style_id_tbl                 IN              po_tbl_number,
                       p_unit_price_tbl               IN              po_tbl_number,
                       x_results                      IN OUT NOCOPY   po_validation_results_type,
                       x_result_set_id                IN OUT NOCOPY   NUMBER,
                       x_result_type                  OUT NOCOPY      VARCHAR2);

    PROCEDURE validate_src_blanket_exists(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2);

    PROCEDURE validate_src_contract_exists(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2) ;

     PROCEDURE validate_src_only_one(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_from_hdr_id_tbl    IN            PO_TBL_NUMBER
                  , p_contract_id_tbl    IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2);


    PROCEDURE validate_src_doc_global(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl   IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl IN            PO_TBL_NUMBER
                  , p_src_doc_ga_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2);

    PROCEDURE validate_src_doc_vendor(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_vendor_id_tbl         IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl      IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl    IN            PO_TBL_NUMBER
                  , p_src_doc_vendor_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2) ;

    PROCEDURE validate_src_doc_vendor_site(
                    p_line_id_tbl          IN            PO_TBL_NUMBER
                  , p_vendor_site_id_tbl   IN            PO_TBL_NUMBER
                  , p_org_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl     IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_enable_all_sites IN            PO_TBL_VARCHAR1
                  , x_result_set_id        IN OUT NOCOPY NUMBER
                  , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_doc_approved(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl      IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl    IN            PO_TBL_NUMBER
                  , p_src_auth_status_tbl   IN            PO_TBL_VARCHAR30
                  , p_src_approved_date_tbl IN            PO_TBL_DATE
                  , p_src_approved_flag_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_doc_hold(
                    p_line_id_tbl          IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl     IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_doc_hold_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id        IN OUT NOCOPY NUMBER
                  , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_doc_currency(
                    p_line_id_tbl          IN            PO_TBL_NUMBER
                  , p_currency_tbl         IN            PO_TBL_VARCHAR30
                  , p_org_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl     IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_doc_currency_tbl IN            PO_TBL_VARCHAR30
                  , p_src_doc_org_id_tbl   IN            PO_TBL_NUMBER
                  , x_result_set_id        IN OUT NOCOPY NUMBER
                  , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_doc_closed_code(
                    p_line_id_tbl             IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl        IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl      IN            PO_TBL_NUMBER
                  , p_src_doc_closed_code_tbl IN            PO_TBL_VARCHAR30
                  , x_result_set_id           IN OUT NOCOPY NUMBER
                  , x_result_type             OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_doc_cancel(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl       IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_cancel_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_doc_frozen(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl       IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_frozen_flg_tbl IN            PO_TBL_VARCHAR1
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2);

     PROCEDURE validate_src_doc_style(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_style_id_tbl           IN            PO_TBL_NUMBER
                  , p_src_doc_type_tbl       IN            PO_TBL_VARCHAR30
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_style_id_tbl   IN            PO_TBL_NUMBER
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2) ;

      PROCEDURE validate_src_bpa_expiry_date(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_end_date_tbl   IN            PO_TBL_DATE
                  , p_src_doc_expiration_tbl IN            PO_TBL_DATE
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_cpa_expiry_date(
                    p_line_id_tbl            IN            PO_TBL_NUMBER
                  , p_src_doc_hdr_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_end_date_tbl   IN            PO_TBL_DATE
                  , x_result_set_id          IN OUT NOCOPY NUMBER
                  , x_result_type            OUT NOCOPY    VARCHAR2) ;

     PROCEDURE validate_src_line_not_null(
                   p_line_id_tbl         IN            PO_TBL_NUMBER
                 , p_src_doc_hdr_id_tbl  IN            PO_TBL_NUMBER
                 , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id       IN OUT NOCOPY NUMBER
                 , x_result_type         OUT    NOCOPY VARCHAR2);

    PROCEDURE validate_src_line_item(
                    p_line_id_tbl         IN            PO_TBL_NUMBER
                  , p_item_id_tbl         IN            PO_TBL_NUMBER
                  , p_item_descp_tbl      IN            PO_TBL_VARCHAR2000
                  , p_category_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_item_id_tbl     IN            PO_TBL_NUMBER
                  , p_src_item_descp_tbl  IN            PO_TBL_VARCHAR2000
                  , p_src_category_id_tbl IN            PO_TBL_NUMBER
                  , x_result_set_id       IN OUT NOCOPY NUMBER
                  , x_result_type         OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_line_item_rev(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_item_rev_tbl       IN            PO_TBL_VARCHAR5
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_item_rev_tbl   IN            PO_TBL_VARCHAR5
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_src_line_job(
                    p_line_id_tbl        IN            PO_TBL_NUMBER
                  , p_job_id_tbl         IN            PO_TBL_NUMBER
                  , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                  , p_src_job_id_tbl     IN            PO_TBL_NUMBER
                  , x_result_set_id      IN OUT NOCOPY NUMBER
                  , x_result_type        OUT NOCOPY    VARCHAR2);

     PROCEDURE validate_src_line_cancel_flag(
                        p_line_id_tbl         IN            PO_TBL_NUMBER
                      , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                      , p_src_line_cancel_tbl     IN            PO_TBL_VARCHAR1
                      , x_result_set_id       IN OUT NOCOPY NUMBER
                      , x_result_type         OUT NOCOPY    VARCHAR2) ;

      PROCEDURE validate_src_line_closed_code(
                        p_line_id_tbl         IN            PO_TBL_NUMBER
                      , p_src_doc_line_id_tbl IN            PO_TBL_NUMBER
                      , p_src_line_closed_tbl IN            PO_TBL_VARCHAR30
                      , x_result_set_id       IN OUT NOCOPY NUMBER
                      , x_result_type         OUT NOCOPY    VARCHAR2)  ;

      PROCEDURE validate_src_line_order_type(
                        p_line_id_tbl             IN            PO_TBL_NUMBER
                      , p_order_type_lookup_tbl   IN            PO_TBL_VARCHAR30
                      , p_src_doc_line_id_tbl     IN            PO_TBL_NUMBER
                      , p_src_line_order_type_tbl IN            PO_TBL_VARCHAR30
                      , x_result_set_id           IN OUT NOCOPY NUMBER
                      , x_result_type             OUT NOCOPY    VARCHAR2)  ;

      PROCEDURE validate_src_line_pur_basis(
                        p_line_id_tbl           IN            PO_TBL_NUMBER
                      , p_purchase_basis_tbl    IN            PO_TBL_VARCHAR30
                      , p_src_doc_line_id_tbl   IN            PO_TBL_NUMBER
                      , p_src_line_purchase_tbl IN            PO_TBL_VARCHAR30
                      , x_result_set_id         IN OUT NOCOPY NUMBER
                      , x_result_type           OUT NOCOPY    VARCHAR2) ;

      PROCEDURE validate_src_line_match_basis(
                        p_line_id_tbl           IN            PO_TBL_NUMBER
                      , p_matching_basis_tbl    IN            PO_TBL_VARCHAR30
                      , p_src_doc_line_id_tbl   IN            PO_TBL_NUMBER
                      , p_src_line_matching_tbl IN            PO_TBL_VARCHAR30
                      , x_result_set_id         IN OUT NOCOPY NUMBER
                      , x_result_type           OUT NOCOPY    VARCHAR2)  ;

       PROCEDURE validate_src_line_uom(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_uom_tbl               IN            PO_TBL_VARCHAR30
                  , p_src_doc_line_id_tbl   IN            PO_TBL_NUMBER
                  , p_src_line_uom_tbl      IN            PO_TBL_VARCHAR30
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_src_allow_price_ovr(
                    p_line_id_tbl           IN            PO_TBL_NUMBER
                  , p_unit_price_tbl        IN            PO_TBL_NUMBER
                  , p_src_allow_price_tbl   IN            PO_TBL_VARCHAR1
                  , x_result_set_id         IN OUT NOCOPY NUMBER
                  , x_result_type           OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_req_reference(
                       p_id_tbl                       IN              po_tbl_number,
                       p_po_line_id_tbl               IN              po_tbl_number,
                       p_req_line_id_tbl              IN              po_tbl_number,
                       p_from_header_id_tbl           IN              po_tbl_number,
                       p_contract_id_tbl              IN              po_tbl_number,
                       p_style_id_tbl                 IN              po_tbl_number,
                       p_purchasing_org_id_tbl        IN              po_tbl_number,
                       p_item_id_tbl                  IN              po_tbl_number,
                       p_job_id_tbl                   IN              po_tbl_number,
                       p_purchase_basis_tbl           IN              po_tbl_varchar30,
                       p_matching_basis_tbl           IN              po_tbl_varchar30,
                       p_document_type_tbl            IN              po_tbl_varchar30,
                       p_cons_from_supp_flag_tbl      IN              po_tbl_varchar1,
                       p_txn_flow_header_id_tbl       IN              po_tbl_number,
                       p_vendor_id_tbl                IN              po_tbl_number,
                       p_vendor_site_id_tbl           IN              po_tbl_number,
                       x_results                      IN OUT NOCOPY   po_validation_results_type,
                       x_result_set_id                IN OUT NOCOPY   NUMBER,
                       x_result_type                  OUT NOCOPY      VARCHAR2);

      PROCEDURE validate_req_exists(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

     PROCEDURE validate_no_ship_dist(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2) ;

      PROCEDURE validate_req_status(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_status_tbl       IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqs_in_pool_flag(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_in_pool_flg_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqs_cancel_flag(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_cancel_flag_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqs_closed_code(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_closed_code_tbl IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqs_modfd_by_agt(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_mod_by_agnt_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqs_at_srcing_flg(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_at_src_flag_tbl IN            PO_TBL_VARCHAR1
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqs_line_loc(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_reqs_line_loc_tbl    IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2) ;

      PROCEDURE validate_req_item(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_item_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_item_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2) ;

      PROCEDURE validate_req_job(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_job_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_job_id_tbl      IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_req_pur_basis(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_pur_basis_tbl        IN            PO_TBL_VARCHAR30
                 , p_req_pur_bas_tbl      IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_req_match_basis(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_match_basis_tbl      IN            PO_TBL_VARCHAR30
                 , p_req_match_bas_tbl    IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_pcard(
                       p_line_id_tbl          IN            PO_TBL_NUMBER
                     , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                     , p_req_pcard_id_tbl     IN            PO_TBL_NUMBER
                     , x_result_set_id        IN OUT NOCOPY NUMBER
                     , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_reqorg_srcdoc(
                       p_line_id_tbl          IN            PO_TBL_NUMBER
                     , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                     , p_source_doc_id_tbl    IN            PO_TBL_NUMBER
                     , p_req_org_id_tbl       IN            PO_TBL_NUMBER
                     , x_result_set_id        IN OUT NOCOPY NUMBER
                     , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_style_dest_progress(
                       p_line_id_tbl          IN            PO_TBL_NUMBER
                     , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                     , p_hdr_style_id_tbl     IN            PO_TBL_NUMBER
                     , p_hdr_type_tbl         IN            PO_TBL_VARCHAR30
                     , p_req_dest_code_tbl    IN            PO_TBL_VARCHAR30
                     , x_result_set_id        IN OUT NOCOPY NUMBER
                     , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_style_line_progress(
                       p_line_id_tbl          IN            PO_TBL_NUMBER
                     , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                     , p_hdr_style_id_tbl     IN            PO_TBL_NUMBER
                     , p_hdr_type_tbl         IN            PO_TBL_VARCHAR30
                     , p_req_pur_basis_tbl    IN            PO_TBL_VARCHAR30
                     , p_req_order_type_tbl   IN            PO_TBL_VARCHAR30
                     , x_result_set_id        IN OUT NOCOPY NUMBER
                     , x_result_type          OUT NOCOPY    VARCHAR2);

      PROCEDURE validate_style_pcard(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_hdr_style_id_tbl     IN            PO_TBL_NUMBER
                 , p_hdr_type_tbl         IN            PO_TBL_VARCHAR30
                 , p_req_pcard_id_tbl     IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_req_vmi_bpa(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_vmi_flag_tbl     IN            PO_TBL_VARCHAR1
                 , p_source_doc_id_tbl    IN            PO_TBL_NUMBER
                 , p_source_doc_type_tbl  IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_req_vmi_supplier(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_vendor_id_tbl        IN            PO_TBL_NUMBER
                 , p_vendor_site_tbl      IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_vmi_flag_tbl     IN            PO_TBL_VARCHAR1
                 , p_sugstd_vend_id_tbl   IN            PO_TBL_NUMBER
                 , p_sugstd_vend_site_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_req_on_spo(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_hdr_type_lookup_tbl  IN            PO_TBL_VARCHAR30
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_req_pcard_supp(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_vendor_id_tbl        IN            PO_TBL_NUMBER
                 , p_vendor_site_tbl      IN            PO_TBL_NUMBER
                 , p_req_line_id_tbl      IN            PO_TBL_NUMBER
                 , p_req_pcard_id_tbl     IN            PO_TBL_NUMBER
                 , p_sugstd_vend_id_tbl   IN            PO_TBL_NUMBER
                 , p_sugstd_vend_site_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

        PROCEDURE validate_oke_contract_hdr(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_oke_contract_hdr_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

       PROCEDURE validate_oke_contract_ver(
                   p_line_id_tbl          IN            PO_TBL_NUMBER
                 , p_oke_contract_hdr_tbl IN            PO_TBL_NUMBER
                 , p_oke_contract_ver_tbl IN            PO_TBL_NUMBER
                 , x_result_set_id        IN OUT NOCOPY NUMBER
                 , x_result_type          OUT NOCOPY    VARCHAR2);

   -- <PDOI Enhancement Bug#17063664 END>

  --Bug 19139957 Start
  -------------------------------------------------------------------------
  -- Check the category segment value.
  -- If there's character the same as segment separator in the value,
  -- add a '\' before the separator value so that fnd code can identify it.

  -- p_category  The category code combination before formatted
  -- p_structure_id  The structure id of the item category
  -- p_format_category The category code combination after formatted.
  -------------------------------------------------------------------------
  PROCEDURE format_category_segment
  (
    p_category IN VARCHAR2,
    p_structure_id IN NUMBER,
    p_format_category OUT NOCOPY VARCHAR2
  );
  --Bug19139957 End


END PO_VAL_LINES2;

/
