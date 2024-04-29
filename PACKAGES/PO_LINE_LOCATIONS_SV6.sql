--------------------------------------------------------
--  DDL for Package PO_LINE_LOCATIONS_SV6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINE_LOCATIONS_SV6" AUTHID CURRENT_USER AS
/* $Header: POXPIISS.pls 120.0.12000000.1 2007/01/16 23:03:59 appldev ship $ */

/*==================================================================
  PROCEDURE NAME: insert_po_line_locations()

  DESCRIPTION:    This API is used to insert a new row in
                  po_line_locations

  PARAMETERS:

  DESIGN
  REFERENCES:	  832valapl.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:	  Created	22-FEB-1996	DXYU


=======================================================================*/
 PROCEDURE insert_po_line_locations(
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
                             x_tax_code_id                    IN NUMBER,
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
                             x_closed_flag                    IN VARCHAR2,
                             x_cancel_flag                    IN VARCHAR2,
                             x_cancelled_by                   IN NUMBER,
                             x_cancel_date                    IN DATE,
                             x_cancel_reason                  IN VARCHAR2,
                             x_firm_status_lookup_code        IN VARCHAR2,
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
                             x_inspection_required_flag       IN VARCHAR2,
                             x_receipt_required_flag          IN VARCHAR2,
                             x_qty_rcv_tolerance              IN NUMBER,
                             x_qty_rcv_exception_code         IN VARCHAR2,
                             x_enforce_ship_to_loc_code  IN VARCHAR2,
                             x_allow_sub_receipts_flag IN VARCHAR2,
                             x_days_early_receipt_allowed     IN VARCHAR2,
                             x_days_late_receipt_allowed      IN VARCHAR2,
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
                             p_transaction_flow_header_id     IN NUMBER,  --< Shared Proc FPJ >
                             --<SERVICES FPJ START>
                             p_amount                         IN NUMBER,
                             p_order_type_lookup_code         IN VARCHAR2,
                             p_purchase_basis                 IN VARCHAR2,
                             --<SERVICES FPJ END>
                             x_match_option	IN VARCHAR2 DEFAULT NULL,
            	             X_note_to_receiver IN VARCHAR2 default null  --togeorge 09/28/2000

			     );


 END PO_LINE_LOCATIONS_SV6;

 

/
