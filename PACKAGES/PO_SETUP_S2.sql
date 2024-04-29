--------------------------------------------------------
--  DDL for Package PO_SETUP_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SETUP_S2" AUTHID CURRENT_USER as
/* $Header: POXSES3S.pls 120.0.12010000.2 2008/11/11 11:26:20 bisdas ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_SETUP_S2

  DESCRIPTION:

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:

  PROCEDURE NAMES:	get_combined_startup_values

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_combined_startup_values()

  DESCRIPTION:		This procedure combines the call to several server
                        procedures for getting the PO startup values.
                        The purpose is to enhance the PO startup performance by
                        reducing the number of server procedural calls from
                        the client procedure 'Init_PO_control_block'.


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:                This procedure has reached the maxiumum number of parameters
                        that PL/SQL supports.  If new parameters are to be added later,
                        it is recommended to combine parameters into one.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      	WLAU	7/3/1996	Created
===========================================================================*/

PROCEDURE get_combined_startup_values
			    (x_sob_id           	  IN OUT NOCOPY    NUMBER,
                             x_inv_org_id       	  IN OUT NOCOPY    NUMBER,
                             x_ussgl_value         	     OUT NOCOPY    VARCHAR2 ,
                             x_flex_value          	     OUT NOCOPY    VARCHAR2,
                             x_inverse_rate_value  	     OUT NOCOPY    VARCHAR2,
                             x_period_name         	     OUT NOCOPY    VARCHAR2,
                             x_gl_date                       OUT NOCOPY    DATE,
                             x_category_set_id     	     OUT NOCOPY    NUMBER,
                             x_structure_id        	     OUT NOCOPY    NUMBER,
                             x_user_id             	     OUT NOCOPY    NUMBER,
                             x_logon_id             	     OUT NOCOPY    NUMBER,
                             x_creation_date       	     OUT NOCOPY    DATE,
                             x_update_date         	     OUT NOCOPY    DATE,
                             x_currency_code                 OUT NOCOPY VARCHAR2,
                             x_coa_id                        OUT NOCOPY NUMBER,
                             x_po_encumberance_flag          OUT NOCOPY VARCHAR2,
                             x_req_encumberance_flag         OUT NOCOPY VARCHAR2,
                             x_ship_to_location_id        IN OUT NOCOPY NUMBER,
                             x_bill_to_location_id        IN OUT NOCOPY NUMBER,
                             x_fob_lookup_code            IN OUT NOCOPY VARCHAR2,
                             x_freight_terms_lookup_code  IN OUT NOCOPY VARCHAR2,
                             x_terms_id                   IN OUT NOCOPY NUMBER,
                             x_default_rate_type          IN OUT NOCOPY VARCHAR2,
                             x_taxable_flag                  OUT NOCOPY VARCHAR2,
                             x_receiving_flag                OUT NOCOPY VARCHAR2,
                             x_enforce_buyer_name_flag       OUT NOCOPY VARCHAR2,
                             x_enforce_buyer_auth_flag       OUT NOCOPY VARCHAR2,
                             x_line_type_id               IN OUT NOCOPY NUMBER,
                             x_manual_po_num_type            OUT NOCOPY VARCHAR2,
                             x_po_num_code                   OUT NOCOPY VARCHAR2,
                             x_price_lookup_code             OUT NOCOPY VARCHAR2,
                             x_invoice_close_tolerance       OUT NOCOPY NUMBER,
                             x_receive_close_tolerance       OUT NOCOPY NUMBER,
                             x_security_structure_id         OUT NOCOPY NUMBER,
                             x_expense_accrual_code          OUT NOCOPY VARCHAR2,
                             x_rev_sort_ordering             OUT NOCOPY NUMBER,
                             x_min_rel_amount                OUT NOCOPY NUMBER,
                             x_notify_blanket_flag           OUT NOCOPY VARCHAR2,
                             x_budgetary_control_flag        OUT NOCOPY VARCHAR2,
                             x_user_defined_req_num_code     OUT NOCOPY VARCHAR2,
                             x_rfq_required_flag             OUT NOCOPY VARCHAR2,
                             x_manual_req_num_type           OUT NOCOPY VARCHAR2,
                             x_enforce_full_lot_qty          OUT NOCOPY VARCHAR2,
                             x_disposition_warning_flag      OUT NOCOPY VARCHAR2,
                             x_reserve_at_completion_flag    OUT NOCOPY VARCHAR2,
                             x_user_defined_rcpt_num_code    OUT NOCOPY VARCHAR2,
                             x_manual_rcpt_num_type          OUT NOCOPY VARCHAR2,
			     x_use_positions_flag	     OUT NOCOPY VARCHAR2,
			     x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	     x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	     x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	     x_manual_quote_num_type	     OUT NOCOPY VARCHAR2,
		  	     x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	     x_manual_rfq_num_type	     OUT NOCOPY VARCHAR2,
		  	     x_ship_via_lookup_code	  IN OUT NOCOPY VARCHAR2,
		  	     x_qty_rcv_tolerance	     OUT NOCOPY NUMBER,
			     x_line_type		     OUT NOCOPY VARCHAR2,
			     x_item_tax_override_popup	     OUT NOCOPY VARCHAR2,
			     x_item_account_override_popup   OUT NOCOPY VARCHAR2,
			     x_curr_tax_override_popup       OUT NOCOPY VARCHAR2,
			     x_curr_account_override_popup   OUT NOCOPY VARCHAR2,
			     x_use_ap_accrual_account 	     OUT NOCOPY VARCHAR2,
			     x_destination_expense 	     OUT NOCOPY VARCHAR2,
			     x_destination_shop_floor 	     OUT NOCOPY VARCHAR2,
			     x_legal_requisition_type 	     OUT NOCOPY VARCHAR2,
			     x_req_source_internal	     OUT NOCOPY VARCHAR2,
			     x_req_source_purchase           OUT NOCOPY VARCHAR2,
			     x_req_incomplete		     OUT NOCOPY VARCHAR2,
			     x_fob_disp			     OUT NOCOPY VARCHAR2,
			     x_freight_terms_disp	     OUT NOCOPY VARCHAR2,
			     x_internal_access		     OUT NOCOPY VARCHAR2,
			     x_purchase_access		     OUT NOCOPY VARCHAR2,
			     x_internal_security	     OUT NOCOPY VARCHAR2,
			     x_purchase_security	     OUT NOCOPY VARCHAR2,
			     x_employee_id		     OUT NOCOPY NUMBER,
			     x_employee_name		     OUT NOCOPY VARCHAR2,
			     x_employee_is_buyer_flag	     OUT NOCOPY VARCHAR2,
			     x_requestor_location_id	  IN OUT NOCOPY NUMBER,
			     x_bill_to_location		  IN OUT NOCOPY VARCHAR2,
			     x_ship_to_location           IN OUT NOCOPY VARCHAR2,
			     x_ship_org_code		  IN OUT NOCOPY VARCHAR2,
			     x_ship_org_name		  IN OUT NOCOPY VARCHAR2,
			     x_default_rate_type_disp	  IN OUT NOCOPY VARCHAR2,
			     x_requestor_location	  IN OUT NOCOPY VARCHAR2,
			     x_requestor_org_id		  IN OUT NOCOPY NUMBER,
			     x_requestor_org		  IN OUT NOCOPY VARCHAR2,
			     x_requestor_org_code	  IN OUT NOCOPY VARCHAR2,
			     x_destination_inventory	     OUT NOCOPY VARCHAR2,
                             x_gl_set_of_bks_id              OUT NOCOPY VARCHAR2,
			     x_combined_install_statuses     OUT NOCOPY VARCHAR2,
                             x_payment_terms              IN OUT NOCOPY VARCHAR2,
                             x_acceptance_required_flag      OUT NOCOPY VARCHAR2);    /* Bug 7518967 : Default Acceptance Required Check ER */



END PO_SETUP_S2;

/
