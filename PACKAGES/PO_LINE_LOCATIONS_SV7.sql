--------------------------------------------------------
--  DDL for Package PO_LINE_LOCATIONS_SV7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_LOCATIONS_SV7" AUTHID CURRENT_USER AS
/* $Header: POXPISVS.pls 120.0.12000000.1 2007/01/16 23:04:49 appldev ship $ */

/*==================================================================
  PROCEDURE NAME:  validate_po_line_coordination()

  DESCRIPTION:    This API is used to validate to see if we can
                  find a coordinated releationship between
                  po_lines table and po_line_locations table.

  PARAMETERS:     X_interface_header_id      IN NUMBER,
                  X_interface_line_id        IN NUMBER,
                  X_item_id                  IN NUMBER,
                  X_item_description         IN VARCHAR2,
                  X_item_revision            IN VARCHAR2,
                  X_po_line_id               IN NUMBER,
                  X_po_header_id             IN NUMBER,
                  X_unit_of_measure          IN VARCHAR2,
                  X_line_type_id             IN NUMBER,
                  X_category_id              IN NUMBER,
                  X_type_lookup_code         IN VARCHAR2,
                  X_header_processable_flag  IN OUT NOCOPY VARCHAR2

  DESIGN
  REFERENCES:     832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE
  HISTORY:        Created       1-MAY-1996     Daisy Yu
  Bug 2845962. Added a new IN  14-MAR-2003     David Ng
  parameter p_line_num.
=======================================================================*/
PROCEDURE validate_po_line_coordination(
                                    X_interface_header_id      IN NUMBER,
                                    X_interface_line_id        IN NUMBER,
                                    X_item_id                  IN NUMBER,
                                    X_item_description         IN VARCHAR2,
                                    X_item_revision            IN VARCHAR2,
                                    X_po_line_id               IN NUMBER,
                                    X_po_header_id             IN NUMBER,
                                    X_unit_of_measure          IN VARCHAR2,
                                    X_line_type_id             IN NUMBER,
                                    X_category_id              IN NUMBER,
                                    X_type_lookup_code         IN VARCHAR2,
                                    X_header_processable_flag  IN OUT NOCOPY VARCHAR2,
                                    p_line_num                 IN NUMBER,
                                    p_job_id                   IN NUMBER --<FPJ SERVICES>
);

/*==================================================================
  PROCEDURE NAME:  validate_po_line_locations()

  DESCRIPTION:    This API is used to validate columns which will be
                  inserted into po_line_locations table during the
                  purchasing docs open interface load.

  PARAMETERS:	  all columns in po_line_locations

  DESIGN
  REFERENCES:	  832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	21-FEB-1996	DXYU
                  MOdified      22-FEB-1996     DXYU
                  Modified      26-APR-1996     DXYU

=======================================================================*/
 PROCEDURE validate_po_line_locations(
                             x_interface_header_id            IN NUMBER,
                             x_interface_line_id              IN NUMBER,
                             x_line_location_id               IN NUMBER,
                             x_last_update_date               IN DATE,
                             x_last_updated_by                IN NUMBER,
                             x_po_header_id                   IN NUMBER,
                             x_po_line_id                     IN NUMBER,
                             x_last_update_login              IN NUMBER,
                             x_creation_date                  IN DATE,
                             x_created_by                     IN NUMBER,
                             x_quantity                       IN NUMBER,
                             x_quantity_received              IN NUMBER,
                             x_quantity_accepted              IN NUMBER,
                             x_quantity_rejected              IN NUMBER,
                             x_quantity_billed                IN NUMBER,
                             x_quantity_cancelled             IN NUMBER,
                             x_unit_meas_lookup_code          IN VARCHAR2,
                             x_po_release_id                  IN NUMBER,
                             x_ship_to_location_id            IN NUMBER,
                             x_ship_via_lookup_code           IN VARCHAR2,
                             x_need_by_date                   IN DATE,
                             x_promised_date                  IN DATE,
                             x_last_accept_date               IN DATE,
                             x_price_override                 IN NUMBER,
                             x_encumbered_flag                IN VARCHAR2,
                             x_encumbered_date                IN DATE,
                             x_fob_lookup_code                IN VARCHAR2,
                             x_freight_terms_lookup_code      IN VARCHAR2,
                             x_taxable_flag                   IN VARCHAR2,
                             x_tax_name                       IN VARCHAR2,
                             x_estimated_tax_amount           IN NUMBER,
                             x_from_header_id                 IN NUMBER,
                             x_from_line_id                   IN NUMBER,
                             x_from_line_location_id          IN NUMBER,
                             x_start_date                     IN DATE,
                             x_end_date                       IN DATE,
                             x_lead_time                      IN NUMBER,
                             x_lead_time_unit                 IN VARCHAR2,
                             x_price_discount                 IN NUMBER,
                             x_terms_id                       IN NUMBER,
                             x_approved_flag                  IN VARCHAR2,
                             x_approved_date                  IN DATE,
                             x_closed_flag                    IN VARCHAR2,
                             x_cancel_flag                    IN VARCHAR2,
                             x_cancelled_by                   IN NUMBER,
                             x_cancel_date                    IN DATE,
                             x_cancel_reason                  IN VARCHAR2,
                             x_firm_status_lookup_code        IN VARCHAR2,
                             x_firm_date                      IN DATE,
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
                             x_unit_of_measure_class          IN VARCHAR2,
                             x_attribute11                    IN VARCHAR2,
                             x_attribute12                    IN VARCHAR2,
                             x_attribute13                    IN VARCHAR2,
                             x_attribute14                    IN VARCHAR2,
                             x_attribute15                    IN VARCHAR2,
                             x_inspection_required_flag       IN VARCHAR2,
                             x_receipt_required_flag          IN VARCHAR2,
                             x_qty_rcv_tolerance              IN NUMBER,
                             x_qty_rcv_exception_code         IN VARCHAR2,
                             x_enforce_ship_to_loc_code       IN VARCHAR2,
                             x_allow_sub_receipts_flag        IN VARCHAR2,
                             x_days_early_receipt_allowed     IN NUMBER,
                             x_days_late_receipt_allowed      IN NUMBER,
                             x_receipt_days_exception_code    IN VARCHAR2,
                             x_invoice_close_tolerance        IN NUMBER,
                             x_receive_close_tolerance        IN NUMBER,
                             x_ship_to_organization_id        IN NUMBER,
                             x_shipment_num                   IN NUMBER,
                             x_source_shipment_id             IN NUMBER,
                             x_shipment_type                  IN VARCHAR2,
                             x_closed_code                    IN VARCHAR2,
                             x_request_id                     IN NUMBER,
                             x_program_application_id         IN NUMBER,
                             x_program_id                     IN NUMBER,
                             x_program_update_date            IN DATE,
                             x_ussgl_transaction_code         IN VARCHAR2,
                             x_government_context             IN VARCHAR2,
                             x_receiving_routing_id           IN NUMBER,
                             x_accrue_on_receipt_flag         IN VARCHAR2,
                             x_closed_reason                  IN VARCHAR2,
                             x_closed_date                    IN DATE,
                             x_closed_by                      IN NUMBER,
                             x_org_id                         IN NUMBER,
                             X_def_inv_org_id                 IN NUMBER,
                             x_header_processable_flag        IN OUT NOCOPY VARCHAR2,
                             x_hd_type_lookup_code            IN VARCHAR2,
                             X_item_id                        IN NUMBER,
                             X_item_revision                  IN VARCHAR2,
                             p_item_category_id               IN NUMBER,          --< Shared Proc FPJ >
                             x_transaction_flow_header_id     OUT NOCOPY NUMBER, --< Shared Proc FPJ >
                             p_order_type_lookup_code         IN VARCHAR2, --<SERVICES FPJ>
                             p_purchase_basis                 IN VARCHAR2, --<SERVICES FPJ>
                             p_job_id                         IN NUMBER
);

/*==================================================================
  PROCEDURE NAME:  val_line_location_id_unqiue()

  DESCRIPTION:    This API is used to validate the unqiueness of
		  line_location_id in PO_LINE_LOCATIONS. IF will return
		  TRUE if line_location_id is UNIQUE; FALSE otherwise.

  MODULE TYPE:    Function

  RETURNS:	  TRUE if validation succeeds
		  FALSE otherwise

  PARAMETER:      X_line_location_id    IN   VARCHAR2

  DESIGN
  REFERENCES:     832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created       1-MAY-1996     Daisy Yu

=======================================================================*/
FUNCTION val_line_location_id_unique(X_line_location_id IN NUMBER)
     	RETURN BOOLEAN;

END PO_LINE_LOCATIONS_SV7;

 

/
