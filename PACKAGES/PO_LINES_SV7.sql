--------------------------------------------------------
--  DDL for Package PO_LINES_SV7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV7" AUTHID CURRENT_USER AS
/* $Header: POXPIVLS.pls 120.0.12000000.1 2007/01/16 23:05:09 appldev ship $ */

/*==================================================================
  PROCEDURE NAME:  validate_item_related_info()

  DESCRIPTION:    This API is used to validate item related attibutes
                  in po_lines table.

  PARAMETERS:     X_interface_header_id   IN NUMBER,
                  X_interface_line_id     IN NUMBER,
                  X_item_id               IN NUMBER,
                  X_unit_of_measure       IN VARCHAR2,
                  X_item_revision         IN VARCHAR2,
                  X_category_id           IN NUMBER,
                  X_def_inv_org_id        IN NUMBER,
                  X_outside_operation_flag IN VARCHAR2,
                  X_header_processable_flag IN OUT VARCHAR2 ,
                  X_global_agreement_flag   IN VARCHAR2   -- FPI GA
                  X_type_lookup_code        IN VARCHAR2   -- Bug 3362369
  DESIGN
  REFERENCES:     832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       02-MAY-1996     DXYU
  		  Modified	13-Jun-1996	KKCHAN
			* added item_description as one more parameter.
		  Modified      18-Jun-1996     KKCHAN
			* added create_or_update_item_flag as one more param.

===================================================================*/
PROCEDURE validate_item_related_info(X_interface_header_id     IN NUMBER,
                                     X_interface_line_id       IN NUMBER,
                                     X_item_id                 IN NUMBER,
				     X_item_description	       IN VARCHAR2,
                                     X_unit_of_measure         IN VARCHAR2,
                                     X_item_revision           IN VARCHAR2,
                                     X_category_id             IN NUMBER,
                                     X_def_inv_org_id          IN NUMBER,
                                     X_outside_operation_flag  IN VARCHAR2,
				     X_create_or_update_item_flag IN VARCHAR2,
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
                                     X_global_agreement_flag   IN VARCHAR2, -- FPI GA
                                     X_type_lookup_code        IN VARCHAR2);-- Bug 3362369

/*==================================================================
  PROCEDURE NAME:  validate_item_with_line_type()

  DESCRIPTION:    This API is used to validate item related attibutes
                  with the value from po_line_types in po_lines table.

  PARAMETERS:     X_interface_header_id     IN NUMBER,
                  X_interface_line_id       IN NUMBER,
                  X_line_type_id            IN NUMBER,
                  X_category_id             IN NUMBER,
                  X_unit_of_measure         IN VARCHAR2,
                  X_unit_price              IN NUMBER,
                  X_item_id                 IN NUMBER,
		  X_item_description	    IN VARCHAR2,
                  X_item_revision           IN VARCHAR2,
                  X_def_inv_org_id          IN NUMBER,
                  X_header_processable_flag IN OUT VARCHAR2,
                  X_global_agreement_flag          IN VARCHAR2 -- FPI GA
                  X_type_lookup_code        IN VARCHAR2 -- Bug 3362369
  DESIGN
  REFERENCES:     832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       02-MAY-1996     DXYU
		  Modified	18-Jun-1996     KKCHAN


===================================================================*/
PROCEDURE validate_item_with_line_type(
                                   X_interface_header_id     IN NUMBER,
                                   X_interface_line_id       IN NUMBER,
                                   X_line_type_id            IN NUMBER,
                                   X_category_id             IN NUMBER,
                                   X_unit_of_measure         IN VARCHAR2,
                                   X_unit_price              IN NUMBER,
                                   X_item_id                 IN NUMBER,
				   X_item_description	     IN VARCHAR2,
                                   X_item_revision           IN VARCHAR2,
                                   X_def_inv_org_id          IN NUMBER,
				   X_create_or_update_item_flag IN VARCHAR2,
                                   X_header_processable_flag IN OUT NOCOPY VARCHAR2,
                                   X_global_agreement_flag   IN VARCHAR2 default null, -- FPI GA
                                   X_type_lookup_code        IN VARCHAR2   default null);  -- Bug 3362369
/*==================================================================
  PROCEDURE NAME:  validate_po_lines()

  DESCRIPTION:    This API is used to validate columns which will be
                  inserted into po_lines table during the purchasing
                  docs open interface load.

  PARAMETERS:	  all columns in po_lines

  DESIGN
  REFERENCES:	  832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	20-FEB-1996	DXYU
		  Modified      06-MAR-1996     DXYU
                  Modified      30-APR-1996     DXYU

=======================================================================*/
 PROCEDURE validate_po_lines(x_interface_header_id            IN NUMBER,
                             x_interface_line_id              IN NUMBER,
                             x_current_po_header_id           IN NUMBER,
                             x_po_line_id                     IN NUMBER,
                             x_last_update_date               IN DATE,
                             x_last_updated_by                IN NUMBER,
                             x_po_header_id                   IN NUMBER,
                             x_line_type_id                   IN NUMBER,
                             x_line_num                       IN NUMBER,
                             x_last_update_login              IN NUMBER,
                             x_creation_date                  IN DATE,
                             x_created_by                     IN NUMBER,
                             x_item_id                        IN NUMBER,
                             x_item_revision                  IN VARCHAR2,
                             x_category_id                    IN NUMBER,
                             x_item_description               IN VARCHAR2,
                             x_unit_meas_lookup_code          IN VARCHAR2,
                             x_quantity_committed             IN NUMBER,
                             x_committed_amount               IN NUMBER,
                             x_allow_price_override_flag      IN VARCHAR2,
                             x_not_to_exceed_price            IN NUMBER,
                             x_list_price_per_unit            IN NUMBER,
                             X_base_unit_price                IN NUMBER,	-- <FPJ Advanced Price>
                             x_unit_price                     IN NUMBER,
                             x_quantity                       IN NUMBER,
                             x_un_number_id                   IN NUMBER,
                             x_hazard_class_id                IN NUMBER,
                             x_note_to_vendor                 IN VARCHAR2,
                             x_from_header_id                 IN NUMBER,
                             x_from_line_id                   IN NUMBER,
                             x_min_order_quantity             IN NUMBER,
                             x_max_order_quantity             IN NUMBER,
                             x_qty_rcv_tolerance              IN NUMBER,
                             x_over_tolerance_error_flag      IN VARCHAR2,
                             x_market_price                   IN NUMBER,
                             x_unordered_flag                 IN VARCHAR2,
                             x_closed_flag                    IN VARCHAR2,
                             x_cancel_flag                    IN VARCHAR2,
                             x_cancelled_by                   IN NUMBER,
                             x_cancel_date                    IN DATE,
                             x_cancel_reason                  IN VARCHAR2,
                             x_vendor_product_num             IN VARCHAR2,
                             x_contract_num                   IN VARCHAR2,
                             x_taxable_flag                   IN VARCHAR2,
                             x_tax_name                       IN VARCHAR2,
			     x_tax_code_id		      IN NUMBER,
                             x_type_1099                      IN VARCHAR2,
                             x_capital_expense_flag           IN VARCHAR2,
                             x_negotiated_by_preparer_flag    IN VARCHAR2,
                             x_attribute_category             IN VARCHAR2,
                             x_attribute1                     IN VARCHAR2,
                             x_attribute2                     IN VARCHAR2,
                             x_attribute3                     IN VARCHAR2,
                             x_attribute4                     IN VARCHAR2,
                             x_attribute5                     IN VARCHAR2,
                             x_attribute6                     IN VARCHAR2,
                             x_attribute7                     IN VARCHAR2,
                             x_attribute8                     IN VARCHAR2,
                             x_attribute9                     IN VARCHAR2,
                             x_attribute10                    IN VARCHAR2,
                             x_attribute11                    IN VARCHAR2,
                             x_attribute12                    IN VARCHAR2,
                             x_attribute13                    IN VARCHAR2,
                             x_attribute14                    IN VARCHAR2,
                             x_attribute15                    IN VARCHAR2,
                             x_min_release_amount             IN NUMBER,
                             x_price_type_lookup_code         IN VARCHAR2,
                             x_closed_code                    IN VARCHAR2,
                             x_price_break_lookup_code        IN VARCHAR2,
                             x_ussgl_transaction_code         IN VARCHAR2,
                             x_government_context             IN VARCHAR2,
                             x_request_id                     IN NUMBER,
                             x_program_application_id         IN NUMBER,
                             x_program_id                     IN NUMBER,
                             x_program_update_date            IN DATE,
                             x_closed_date                    IN DATE,
                             x_closed_reason                  IN VARCHAR2,
                             x_closed_by                      IN NUMBER,
                             x_transaction_reason_code        IN VARCHAR2,
                             x_org_id                         IN NUMBER,
                             x_line_reference_num             IN VARCHAR2,
                             x_terms_id                       IN NUMBER,
                             x_qty_rcv_exception_code         IN VARCHAR2,
                             x_lead_time_unit                 IN VARCHAR2,
                             x_freight_carrier                IN VARCHAR2,
                             x_fob                            IN VARCHAR2,
                             x_freight_terms                  IN VARCHAR2,
                             x_release_num                    IN NUMBER,
                             x_po_release_id                  IN NUMBER,
                             x_source_shipment_id             IN NUMBER,
                             x_inspection_required_flag       IN VARCHAR2,
                             x_receipt_required_flag          IN VARCHAR2,
                             x_receipt_days_exception_code    IN VARCHAR2,
                             x_need_by_date                   IN DATE,
                             x_promised_date                  IN DATE,
                             x_lead_time                      IN NUMBER,
                             x_invoice_close_tolerance        IN NUMBER,
                             x_receive_close_tolerance        IN NUMBER,
                             x_firm_flag                      IN VARCHAR2,
                             x_days_early_receipt_allowed     IN NUMBER,
                             x_days_late_receipt_allowed      IN NUMBER,
                             x_enforce_ship_to_loc_code       IN VARCHAR2,
                             x_allow_sub_receipts_flag        IN VARCHAR2,
                             x_receiving_routing              IN VARCHAR2,
                             x_receiving_routing_id           IN NUMBER,
                             x_header_processable_flag        IN OUT NOCOPY VARCHAR2,
                             x_def_inv_org_id                 IN NUMBER,
                             x_uom_code                       IN VARCHAR2,
                             x_hd_type_lookup_code            IN VARCHAR2,
			     x_create_or_update_item_flag     IN VARCHAR2,
                             X_global_agreement_flag          IN VARCHAR2 default null, -- FPI GA
                             p_shipment_num                   IN NUMBER, /* <TIMEPHASED FPI> */
                             p_contract_id                    IN NUMBER, -- <GC FPJ>
                             --<SERVICES FPJ START>
                             p_job_id                         IN NUMBER,
                             p_effective_date                 IN DATE,
                             p_expiration_date                IN DATE,
                             p_amount                         IN NUMBER,
                             p_order_type_lookup_code         IN VARCHAR2,
                             p_purchase_basis                 IN VARCHAR2,
                             p_service_uom_class              IN VARCHAR2
                             --<SERVICES FPJ END>
                             -- <bug 3325447 start>
                             , p_contractor_first_name        IN VARCHAR2
                             , p_contractor_last_name         IN VARCHAR2
                             -- <bug 3325447 end>
                             , p_job_business_group_id        IN NUMBER --<BUG 3296145>
		);


END PO_LINES_SV7;

 

/
