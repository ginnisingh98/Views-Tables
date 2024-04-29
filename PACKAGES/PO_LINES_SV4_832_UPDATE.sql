--------------------------------------------------------
--  DDL for Package PO_LINES_SV4_832_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV4_832_UPDATE" AUTHID CURRENT_USER AS
/* $Header: POXPILUS.pls 120.0.12000000.1 2007/01/16 23:04:26 appldev ship $ */



/*===================================================================
  PACKAGE NAME:	  PO_LINES_SV4_832_UPDATE

  DESCRIPTION:

  CLIENT/SERVER:  Server

  LIBRARY NAME

  OWNER:	  Imran Ali

  CHANGE HISTORY:  Created  06/26/98  Iali

  PROCEDURE NAMES: update_po_line()

===================================================================*/

/*==================================================================
  PROCEDURE NAME:  update_po_line()

  DESCRIPTION:    This API is used to update price and description information
		  on po_line and price breaks on po_line_locations.

  PARAMETERS:


  DESIGN
  REFERENCES:     edi_832_hld.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSE ISSUES:

  CHANGE
  HISTORY:        Created  06/26/98  Iali

=======================================================================*/

--
--   PROCEDURE NAME: 	update_po_line()
--

PROCEDURE  update_po_line( X_interface_header_id            IN NUMBER,
                           X_interface_line_id              IN NUMBER,
                           X_line_num                       IN NUMBER,
                           X_po_line_id                     IN NUMBER,
                           X_shipment_num               IN OUT NOCOPY NUMBER,
                           X_line_location_id           IN OUT NOCOPY NUMBER,
                           X_shipment_type                  IN VARCHAR2,
                           X_requisition_line_id            IN NUMBER,
                           X_document_num                   IN VARCHAR2,
                           X_po_header_id                   IN NUMBER,
                           X_release_num                    IN NUMBER,
                           X_po_release_id                  IN NUMBER,
                           X_source_shipment_id             IN NUMBER,
                           X_contract_num                   IN VARCHAR2,
                           X_line_type                      IN VARCHAR2,
                           X_line_type_id                   IN NUMBER,
                           X_item                           IN VARCHAR2,
                           X_item_id                        IN OUT NOCOPY NUMBER,
                           X_item_revision                  IN VARCHAR2,
                           X_category                       IN VARCHAR2,
                           X_category_id                    IN NUMBER,
                           X_item_description               IN VARCHAR2,
                           X_vendor_product_num             IN VARCHAR2,
                           X_uom_code                       IN VARCHAR2,
                           X_unit_of_measure                IN VARCHAR2,
                           X_quantity                       IN NUMBER,
                           X_committed_amount               IN NUMBER,
                           X_min_order_quantity             IN NUMBER,
                           X_max_order_quantity             IN NUMBER,
                           X_base_unit_price                IN NUMBER,	-- <FPJ Advanced Price>
                           X_unit_price                     IN NUMBER,
                           X_list_price_per_unit            IN NUMBER,
                           X_market_price                   IN NUMBER,
                           X_allow_price_override_flag      IN VARCHAR2,
                           X_not_to_exceed_price            IN NUMBER,
                           X_negotiated_by_preparer_flag    IN VARCHAR2,
                           X_un_number                      IN VARCHAR2,
                           X_un_number_id                   IN NUMBER,
                           X_hazard_class                   IN VARCHAR2,
                           X_hazard_class_id                IN NUMBER,
                           X_note_to_vendor                 IN VARCHAR2,
                           X_transaction_reason_code        IN VARCHAR2,
                           X_taxable_flag                   IN VARCHAR2,
                           X_tax_name                       IN VARCHAR2,
                           X_type_1099                      IN VARCHAR2,
                           X_capital_expense_flag           IN VARCHAR2,
                           X_inspection_required_flag       IN VARCHAR2,
                           X_receipt_required_flag          IN VARCHAR2,
                           X_payment_terms                  IN VARCHAR2,
                           X_terms_id                       IN NUMBER,
                           X_price_type                     IN VARCHAR2,
                           X_min_release_amount             IN NUMBER,
                           X_price_break_lookup_code        IN VARCHAR2,
                           X_ussgl_transaction_code         IN VARCHAR2,
                           X_closed_code                    IN VARCHAR2,
                           X_closed_reason                  IN VARCHAR2,
                           X_closed_date                    IN DATE,
                           X_closed_by                      IN NUMBER,
                           X_invoice_close_tolerance        IN NUMBER,
                           X_receive_close_tolerance        IN NUMBER,
                           X_firm_flag                      IN VARCHAR2,
                           X_days_early_receipt_allowed     IN NUMBER,
                           X_days_late_receipt_allowed      IN NUMBER,
                           X_enforce_ship_to_loc_code       IN VARCHAR2,
                           X_allow_sub_receipts_flag        IN VARCHAR2,
                           X_receiving_routing              IN VARCHAR2,
                           X_receiving_routing_id           IN NUMBER,
                           X_qty_rcv_tolerance              IN NUMBER,
                           X_over_tolerance_error_flag      IN VARCHAR2,
                           X_qty_rcv_exception_code         IN VARCHAR2,
                           X_receipt_days_exception_code    IN VARCHAR2,
                           X_ship_to_organization_code      IN VARCHAR2,
                           X_ship_to_organization_id        IN NUMBER,
                           X_ship_to_location               IN VARCHAR2,
                           X_ship_to_location_id            IN NUMBER,
                           X_need_by_date                   IN DATE,
                           X_promised_date                  IN DATE,
                           X_accrue_on_receipt_flag         IN VARCHAR2,
                           X_lead_time                      IN NUMBER,
                           X_lead_time_unit                 IN VARCHAR2,
                           X_price_discount                 IN NUMBER,
                           X_freight_carrier                IN VARCHAR2,
                           X_fob                            IN VARCHAR2,
                           X_freight_terms                  IN VARCHAR2,
                           X_effective_date                 IN DATE,
                           X_expiration_date                IN DATE,
                           X_from_header_id                 IN NUMBER,
                           X_from_line_id                   IN NUMBER,
                           X_from_line_location_id          IN NUMBER,
                           X_line_attribute_catg_lines      IN VARCHAR2,
                           X_line_attribute1                IN VARCHAR2,
                           X_line_attribute2                IN VARCHAR2,
                           X_line_attribute3                IN VARCHAR2,
                           X_line_attribute4                IN VARCHAR2,
                           X_line_attribute5                IN VARCHAR2,
                           X_line_attribute6                IN VARCHAR2,
                           X_line_attribute7                IN VARCHAR2,
                           X_line_attribute8                IN VARCHAR2,
                           X_line_attribute9                IN VARCHAR2,
                           X_line_attribute10               IN VARCHAR2,
                           X_line_attribute11               IN VARCHAR2,
                           X_line_attribute12               IN VARCHAR2,
                           X_line_attribute13               IN VARCHAR2,
                           X_line_attribute14               IN VARCHAR2,
                           X_line_attribute15               IN VARCHAR2,
                           X_shipment_attribute_category    IN VARCHAR2,
                           X_shipment_attribute1            IN VARCHAR2,
                           X_shipment_attribute2            IN VARCHAR2,
                           X_shipment_attribute3            IN VARCHAR2,
                           X_shipment_attribute4            IN VARCHAR2,
                           X_shipment_attribute5            IN VARCHAR2,
                           X_shipment_attribute6            IN VARCHAR2,
                           X_shipment_attribute7            IN VARCHAR2,
                           X_shipment_attribute8            IN VARCHAR2,
                           X_shipment_attribute9            IN VARCHAR2,
                           X_shipment_attribute10           IN VARCHAR2,
                           X_shipment_attribute11           IN VARCHAR2,
                           X_shipment_attribute12           IN VARCHAR2,
                           X_shipment_attribute13           IN VARCHAR2,
                           X_shipment_attribute14           IN VARCHAR2,
                           X_shipment_attribute15           IN VARCHAR2,
                           X_last_update_date               IN DATE,
                           X_last_updated_by                IN NUMBER,
                           X_last_update_login              IN NUMBER,
                           X_creation_date                  IN DATE,
                           X_created_by                     IN NUMBER,
                           X_request_id                     IN NUMBER,
                           X_program_application_id         IN NUMBER,
                           X_program_id                     IN NUMBER,
                           X_program_update_date            IN DATE,
                           X_organization_id                IN NUMBER,
			   X_item_attribute_category	    IN VARCHAR2,
                           X_item_attribute1                IN VARCHAR2,
                           X_item_attribute2                IN VARCHAR2,
                           X_item_attribute3                IN VARCHAR2,
                           X_item_attribute4                IN VARCHAR2,
                           X_item_attribute5                IN VARCHAR2,
                           X_item_attribute6                IN VARCHAR2,
                           X_item_attribute7                IN VARCHAR2,
                           X_item_attribute8                IN VARCHAR2,
                           X_item_attribute9                IN VARCHAR2,
                           X_item_attribute10               IN VARCHAR2,
                           X_item_attribute11               IN VARCHAR2,
                           X_item_attribute12               IN VARCHAR2,
                           X_item_attribute13               IN VARCHAR2,
                           X_item_attribute14               IN VARCHAR2,
                           X_item_attribute15               IN VARCHAR2,
                           X_unit_weight                    IN NUMBER,
                           X_weight_uom_code                IN VARCHAR2,
                           X_volume_uom_code                IN VARCHAR2,
                           X_unit_volume                    IN NUMBER,
                           X_template_id                    IN NUMBER,
                           X_template_name                  IN VARCHAR2,
                           X_line_reference_num             IN VARCHAR2,
                           X_sourcing_rule_name             IN VARCHAR2,
                           X_quantity_committed             IN NUMBER,
                           X_government_context             IN VARCHAR2,
	                   X_hd_load_sourcing_flag          IN  VARCHAR2,
                           X_load_sourcing_rules_flag       IN VARCHAR2,
                           X_update_po_line_flag            IN  VARCHAR2,
                           X_create_po_line_loc_flag        IN  VARCHAR2,
                           X_header_processable_flag        IN  OUT NOCOPY VARCHAR2,
                           X_create_items                   IN  VARCHAR2,       -- Always "N"
                           X_def_purch_org_id               IN  NUMBER,
                           X_def_inv_org_id                 IN  NUMBER,
                           X_def_master_org_id              IN  NUMBER,
                           X_approved_flag                  IN VARCHAR2,
                           X_approved_date                  IN DATE,
                           X_vendor_id                      IN NUMBER,
                           X_document_type                  IN VARCHAR2,
                           X_current_po_header_id           IN NUMBER,
                           X_line_quantity                  IN NUMBER,
			   X_approval_status		    IN VARCHAR2,
			   X_rel_gen_method		    IN VARCHAR2,
			   X_price_tolerance_flag 	    IN OUT NOCOPY VARCHAR2,
			   X_price_breaks_deleted	    IN OUT NOCOPY VARCHAR2,
			   X_line_updated_flag		    IN OUT NOCOPY  VARCHAR2,
			   --togeorge 09/28/2000
			   --added  oke variables
			   X_note_to_receiver         	    IN VARCHAR2,
			   X_oke_contract_header_id         IN NUMBER,
			   X_oke_contract_version_id        IN NUMBER,
                           --<SERVICES FPJ START>
                           p_job_id                         IN NUMBER,
                           p_amount                         IN NUMBER,
                           p_order_type_lookup_code         IN VARCHAR2,
                           p_purchase_basis                 IN VARCHAR2
                           --<SERVICES FPJ END>
		);


--
--   PROCEDURE NAME: 	delete_po_line()
--

PROCEDURE delete_po_line(
                        X_interface_header_id	NUMBER,
			X_interface_line_id	NUMBER,
                        X_po_line_id		NUMBER,
                        X_line_location_id	NUMBER,
                        X_shipment_type		VARCHAR2,
			X_document_num		VARCHAR2,
			X_po_header_id		NUMBER,
			X_item			NUMBER,
 			X_item_id		NUMBER,
 			X_item_revision		VARCHAR2,
 			X_category		VARCHAR2,
 			X_category_id		NUMBER,
 			X_item_description	VARCHAR2,
 			X_vendor_product_num	VARCHAR2);

--
--   PROCEDURE NAME: 	item_exists()
--

PROCEDURE item_exists  ( X_ItemType      IN  VARCHAR2,
                         X_ItemKey       IN  VARCHAR2,
                         X_Item_exist    OUT NOCOPY VARCHAR2,
                         X_Item_end_date OUT NOCOPY DATE );

--
--   PROCEDURE NAME: 	Start_Pricat_WF()
--

PROCEDURE Start_Pricat_WF ( X_ItemType      	  IN  VARCHAR2,
                            X_ItemKey       	  IN  VARCHAR2,
			    X_interface_header_id IN  NUMBER,
			    X_po_header_id        IN  NUMBER,
			    X_batch_id		  IN  NUMBER,
			    X_document_type_code  IN  VARCHAR2,
			    X_document_sub_type   IN  VARCHAR2,
			    X_commit_interval	  IN  NUMBER,
			    X_any_item_udpated    IN  VARCHAR2,
			    X_buyer_id		  IN  NUMBER);


END PO_LINES_SV4_832_UPDATE;

 

/
