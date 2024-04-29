--------------------------------------------------------
--  DDL for Package Body PO_SETUP_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SETUP_S" as
/* $Header: POXSES1B.pls 120.1.12010000.2 2008/11/11 11:23:55 bisdas ship $*/
/*=============================  PO_SETUP_S  ===============================*/

/*===========================================================================

  FUNCTION NAME : get_flexbuilder_override

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    :

  ALGORITHM     : Use fnd_profile.get function to get
                  'PA_ALLOW_FLEXBUILDER_OVERRIDE' status
                  if value is null then
                    set the value to 'N'

  NOTES         : Display pa_allow_flexbuilder_override  is identified by
                  'PA_ALLOW_FLEXBUILDER_OVERRIDES'

                  Added sqlcode param in the call to po_message_s.sql_error
                  - SI 04/08

===========================================================================*/
FUNCTION get_flexbuilder_override RETURN VARCHAR2 is
  x_progress     VARCHAR2(3) := NULL;
  x_option_value VARCHAR2(1);
begin

  x_progress := 10;

  fnd_profile.get('PA_ALLOW_FLEXBUILDER_OVERRIDES',x_option_value);
  if x_option_value is null then
    x_option_value := 'N';
  end if;

  RETURN(x_option_value);

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_flexbuilder_override', x_progress, sqlcode);
    RAISE;

end get_flexbuilder_override;
/*===========================================================================

  FUNCTION NAME : get_display_inverse_rate

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    :

  ALGORITHM     : Use fnd_profile.get function to get 'DISPLAY_INVERSE_RATE'
                  status
                  if value is null then
                    set the value to 'N'

  NOTES         : Display inverse rate  is identified by 'DISPLAY_INVERSE_RATE'

===========================================================================*/
FUNCTION get_display_inverse_rate RETURN VARCHAR2 is

  x_progress     VARCHAR2(3) := NULL;
  x_option_value VARCHAR2(1);

begin

  x_progress := 10;

  fnd_profile.get('DISPLAY_INVERSE_RATE',x_option_value);
  if x_option_value is null then
    x_option_value := 'N';
  end if;

  RETURN(x_option_value);

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_display_inverse_rate', x_progress, sqlcode);
    RAISE;

end get_display_inverse_rate;

/*==========================================================================
  PROCEDURE NAME:	get_startup_values()

===========================================================================*/
PROCEDURE get_startup_values(x_sob_id           IN OUT NOCOPY    NUMBER,
                             x_inv_org_id       IN OUT NOCOPY    NUMBER,
                             x_ussgl_value         OUT NOCOPY    VARCHAR2 ,
                             x_flex_value          OUT NOCOPY    VARCHAR2,
                             x_inverse_rate_value  OUT NOCOPY    VARCHAR2,
                             x_period_name         OUT NOCOPY    VARCHAR2,
                             x_gl_date             OUT NOCOPY    DATE,
                             x_category_set_id     OUT NOCOPY    NUMBER,
                             x_structure_id        OUT NOCOPY    NUMBER,
                             x_user_id             OUT NOCOPY    NUMBER,
                             x_logonid             OUT NOCOPY    NUMBER,
                             x_creation_date       OUT NOCOPY    DATE,
                             x_update_date         OUT NOCOPY    DATE,
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
                             x_line_type_id              IN  OUT NOCOPY NUMBER,
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
			     x_ship_to_location		  IN OUT NOCOPY VARCHAR2,
			     x_ship_org_code		  IN OUT NOCOPY VARCHAR2,
			     x_ship_org_name		  IN OUT NOCOPY VARCHAR2,
			     x_default_rate_type_disp	  IN OUT NOCOPY VARCHAR2,
			     x_requestor_location	  IN OUT NOCOPY VARCHAR2,
			     x_requestor_org_id		  IN OUT NOCOPY NUMBER,
			     x_requestor_org		  IN OUT NOCOPY VARCHAR2,
			     x_requestor_org_code         IN OUT NOCOPY VARCHAR2,
			     x_destination_inventory	     OUT NOCOPY VARCHAR2,
                             x_gl_set_of_bks_id              OUT NOCOPY VARCHAR2,
			     x_acceptance_required_flag      OUT NOCOPY VARCHAR2) is    /* Bug 7518967 : Default Acceptance Required Check ER */

x_progress 			VARCHAR2(3)  := NULL;
x_use_ap_disp_field		VARCHAR2(80) := NULL;
x_fob_desc			VARCHAR2(240) := NULL;
x_freight_terms_desc    	VARCHAR2(240) := NULL;
x_temp_terms_id			NUMBER       := NULL;
x_temp_ship_via_lookup_code	VARCHAR2(25) := NULL;
x_is_emp			BOOLEAN      := NULL;
x_employee_is_buyer		BOOLEAN      := NULL;

/** PO UTF8 Column Expansion Project 9/18/2002 tpoon **/
/** Changed X_location_code to use %TYPE **/
-- x_location_code			VARCHAR2(20) := NULL;
x_location_code			hr_locations_all.location_code%TYPE := NULL;

x_org_id			NUMBER	     := NULL;
x_rate_type			VARCHAR2(30) := NULL;

BEGIN
  x_progress := '5';
  po_core_s.get_po_parameters(x_currency_code       ,
                              x_coa_id               ,
                              x_po_encumberance_flag  ,
                              x_req_encumberance_flag  ,
                              x_sob_id                  ,
                              x_ship_to_location_id      ,
                              x_bill_to_location_id       ,
                              x_fob_lookup_code         ,
                              x_freight_terms_lookup_code,
                              x_temp_terms_id           ,
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
                              x_inv_org_id      ,
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
		  	      x_temp_ship_via_lookup_code,
		  	      x_qty_rcv_tolerance,
			      x_acceptance_required_flag);   /* Bug 7518967 : Default Acceptance Required Check ER */


  -- dbms_output.put_line('Before Prog 10');

  x_progress := '10';
  x_ussgl_value := PO_CORE_S.Check_Federal_Instance(PO_MOAC_UTILS_PVT.Get_Current_Org_Id);  --<R12 SLA>

  -- dbms_output.put_line('Before Prog 20');

  x_progress := '20';
  x_flex_value  := get_flexbuilder_override;

  -- dbms_output.put_line('Before Prog 30');

  x_progress := '30';
  x_inverse_rate_value := get_display_inverse_rate;

  -- dbms_output.put_line('Before Prog 40');

  x_progress := '40';
  po_core_s.get_period_name(x_sob_id,
                            x_period_name,
                            x_gl_date);

  -- dbms_output.put_line('Before Prog 50');

  x_progress := '50';
  po_core_s.get_item_category_structure(x_category_set_id,x_structure_id);

  -- dbms_output.put_line('Before Prog 60');

  x_progress := '60';
  po_core_s.get_global_values(x_user_id,x_logonid,x_update_date,x_creation_date);


  x_progress := '70';
  x_line_type := po_line_types_sv.get_line_type (x_line_type_id);


  x_progress := '80';
  po_core_s.get_displayed_value ('OVERRIDE DEFAULTS',
				 'ITEM',
				 x_item_tax_override_popup,
				 x_item_account_override_popup);

  x_progress := '90';
  po_core_s.get_displayed_value ('OVERRIDE DEFAULTS',
				 'CURRENT',
				 x_curr_tax_override_popup,
				 x_curr_account_override_popup);


  x_progress := '100';
  po_core_s.get_displayed_value ('OVERRIDE DEFAULTS',
				 'AP ACCRUAL',
				 x_use_ap_disp_field,
				 x_use_ap_accrual_account);


  x_progress := '110';
  po_core_s.get_displayed_value ('DESTINATION TYPE',
				 'EXPENSE',
				 x_destination_expense);


  x_progress := '120';
  po_core_s.get_displayed_value ('RCV DESTINATION TYPE',
				 'SHOP FLOOR',
				 x_destination_shop_floor);


  x_progress := '130';
  fnd_profile.get ('REQUISITION_TYPE', x_legal_requisition_type);


  x_progress := '140';
  po_core_s.get_displayed_value ('AUTHORIZATION STATUS',
				 'INCOMPLETE',
				 x_req_incomplete);

  x_progress := '150';
  po_documents_sv.get_doc_type_info ('REQUISITION',
			       'INTERNAL',
			       x_req_source_internal);

  x_progress := '160';
  po_documents_sv.get_doc_type_info ('REQUISITION',
			       'PURCHASE',
			       x_req_source_purchase);

  x_progress := '170';
  po_core_s.get_displayed_value('FOB',
				x_fob_lookup_code,
				x_fob_disp,
				x_fob_desc,
				TRUE);


  x_progress := '180';
  po_core_s.get_displayed_value('FREIGHT TERMS',
				x_freight_terms_lookup_code,
				x_freight_terms_disp,
				x_freight_terms_desc,
				TRUE);

  x_progress := '190';
  po_terms_sv.val_ap_terms(X_temp_terms_id, X_terms_id);

  x_progress := '200';
  po_vendors_sv.val_freight_carrier(X_temp_ship_via_lookup_code,
			   	    X_inv_org_id,
			   	    X_ship_via_lookup_code);

  x_progress := '210';
  po_documents_sv.get_doc_security_level('REQUISITION',
					 'PURCHASE',
					 x_purchase_security);


  x_progress := '220';
  po_documents_sv.get_doc_security_level('REQUISITION',
					 'INTERNAL',
					 x_internal_security);


  x_progress := '230';
  po_documents_sv.get_doc_access_level('REQUISITION',
					 'INTERNAL',
					 x_internal_access);

  x_progress := '240';
  po_documents_sv.get_doc_access_level('REQUISITION',
					 'PURCHASE',
					 x_purchase_access);

  x_progress := '250';
 IF( po_employees_sv.get_employee(x_employee_id,
			       x_employee_name,
			       x_requestor_location_id,
			       x_location_code,
			       x_employee_is_buyer,
			       x_is_emp) = TRUE) THEN


   IF (x_employee_is_buyer = TRUE) THEN
     x_employee_is_buyer_flag := 'Y';

   ELSE
     x_employee_is_buyer_flag := 'N';

   END IF;
 END IF;

  x_progress := '260';
  po_vendors_sv.get_ship_to_loc_attributes(x_ship_to_location_id,
					   x_ship_to_location,
					   x_ship_org_code,
					   x_ship_org_name,
					   x_org_id,
					   x_sob_id);

  x_progress := '270';
  po_locations_s.get_loc_attributes(x_bill_to_location_id,
				    x_bill_to_location,
				    x_org_id);



  x_progress := '280';
  po_core_s.get_displayed_value ('DESTINATION TYPE',
				 'INVENTORY',
				 x_destination_inventory);

  x_progress := '290';
  po_locations_s.get_loc_org (x_requestor_location_id,
			      x_sob_id,
			      x_requestor_org_id,
			      x_requestor_org_code,
			      x_requestor_org);

  x_progress := '300';
  po_currency_sv.get_rate_type_disp (x_default_rate_type,
				     x_default_rate_type_disp);

  x_progress := '310';
  po_locations_s.get_location_code (x_requestor_location_id,
				    x_requestor_location);


  -- dbms_output.put_line('Before Prog 320');

  x_progress := '320';
  x_gl_set_of_bks_id := po_core_s.get_gl_set_of_bks_id;

  EXCEPTION
  WHEN OTHERS THEN
  -- dbms_output.put_line('After Prog ' || X_progress );
  po_message_s.sql_error('po_setup_s.get_startup_values', x_progress, sqlcode);
  raise;

END get_startup_values;


END PO_SETUP_S;

/
