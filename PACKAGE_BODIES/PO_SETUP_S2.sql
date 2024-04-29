--------------------------------------------------------
--  DDL for Package Body PO_SETUP_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SETUP_S2" as
/* $Header: POXSES3B.pls 120.0.12010000.2 2008/11/11 11:27:15 bisdas ship $*/
/*==========================================================================
  PROCEDURE NAME:	get_combined_startup_values()

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
			     x_acceptance_required_flag      OUT NOCOPY VARCHAR2) IS    /* Bug 7518967 : Default Acceptance Required Check ER */


 x_progress     		VARCHAR2  (3) := NULL;
 x_inv_status 			VARCHAR2  (1);
 x_po_status			VARCHAR2  (1);
 x_qa_status 			VARCHAR2  (1);
 x_wip_status			VARCHAR2  (1);
 x_oe_status 			VARCHAR2  (1);
 x_pa_status 			VARCHAR2  (1);

 BEGIN

 x_progress := '10';

 PO_SETUP_S.GET_STARTUP_VALUES (x_sob_id,
                                x_inv_org_id,
                                x_ussgl_value,
                                x_flex_value,
                                x_inverse_rate_value,
                                x_period_name,
                                x_gl_date,
                                x_category_set_id,
                                x_structure_id,
                                x_user_id,
                                x_logon_id,
                                x_creation_date,
                                x_update_date,
                                x_currency_code,
                                x_coa_id               ,
                                x_po_encumberance_flag  ,
                                x_req_encumberance_flag  ,
                                x_ship_to_location_id      ,
                                x_bill_to_location_id       ,
                                x_fob_lookup_code         ,
                                x_freight_terms_lookup_code,
                                x_terms_id           ,
                                x_default_rate_type   ,
                                x_taxable_flag         ,
                                x_receiving_flag        ,
                                x_enforce_buyer_name_flag,
                                x_enforce_buyer_auth_flag,
                                x_line_type_id       ,
                                x_manual_po_num_type  ,
                                x_po_num_code          ,
                                x_price_lookup_code     ,
                                x_invoice_close_tolerance,
                                x_receive_close_tolerance,
                                x_security_structure_id,
                                x_expense_accrual_code,
                                x_rev_sort_ordering,
                                x_min_rel_amount    ,
                                x_notify_blanket_flag,
                                x_budgetary_control_flag,
                                x_user_defined_req_num_code,
                                x_rfq_required_flag,
                                x_manual_req_num_type,
                                x_enforce_full_lot_qty,
                                x_disposition_warning_flag,
                                x_reserve_at_completion_flag,
                                x_user_defined_rcpt_num_code,
                                x_manual_rcpt_num_type,
  				x_use_positions_flag,
  				x_default_quote_warning_delay,
  				x_inspection_required_flag,
  				x_user_defined_quote_num_code,
  				x_manual_quote_num_type,
  				x_user_defined_rfq_num_code,
  				x_manual_rfq_num_type,
  				x_ship_via_lookup_code,
  				x_qty_rcv_tolerance,
				x_line_type,
  				x_item_tax_override_popup,
  				x_item_account_override_popup,
  				x_curr_tax_override_popup,
  				x_curr_account_override_popup,
  				x_use_ap_accrual_account,
  				x_destination_expense,
				x_destination_shop_floor,
  				x_legal_requisition_type,
  				x_req_source_internal,
  				x_req_source_purchase,
  				x_req_incomplete,
   				x_fob_disp,
  				x_freight_terms_disp,
  				x_internal_access,
  				x_purchase_access,
  				x_internal_security,
  				x_purchase_security,
  				x_employee_id,
  				x_employee_name,
  				x_employee_is_buyer_flag,
  				x_requestor_location_id,
  				x_bill_to_location,
  				x_ship_to_location,
  				x_ship_org_code	,
  				x_ship_org_name,
				x_default_rate_type_disp,
				x_requestor_location,
				x_requestor_org_id,
				x_requestor_org,
				x_requestor_org_code,
				x_destination_inventory,
                                x_gl_set_of_bks_id,
				x_acceptance_required_flag);      /* Bug 7518967 : Default Acceptance Required Check ER */

 x_progress := '15';

 PO_SETUP_S1.GET_INSTALL_STATUS(x_inv_status,
                                x_po_status,
                                x_qa_status,
				x_wip_status,
				x_oe_status,
				x_pa_status);

 --
 -- Concatentate all other products install status into one combined parameter.
 -- The receiving procedure should use substring function to parse the return
 -- status by the relative position.
 --

 x_combined_install_statuses := NVL(x_inv_status,'N') ||
                                NVL(x_po_status,'N')  ||
                                NVL(x_qa_status,'N')  ||
				NVL(x_wip_status,'N') ||
				NVL(x_oe_status,'N')  ||
				NVL(x_pa_status,'N');

 x_progress := '20';
 PO_TERMS_SV.GET_TERMS_NAME    (x_terms_id,
				x_payment_terms);

  EXCEPTION
  WHEN OTHERS THEN
  dbms_output.put_line('After Prog ' || X_progress );
  po_message_s.sql_error('po_setup_s.get_startup_values', x_progress, sqlcode);
  raise;

 END get_combined_startup_values;


END PO_SETUP_S2;

/
