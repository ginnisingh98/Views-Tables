--------------------------------------------------------
--  DDL for Package Body PO_SOURCING3_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING3_SV" as
/* $Header: POXSCS3B.pls 115.2 2002/11/26 19:51:23 sbull ship $ */

/*=============================  PO_SOURCING3_SV  ===========================*/

/*===========================================================================

  PROCEDURE NAME:	get_catalog_startup_values()

===========================================================================*/
PROCEDURE get_catalog_startup_values(X_functional_currency_code IN OUT NOCOPY VARCHAR2,
				     X_sob_id			IN OUT NOCOPY NUMBER,
				     X_sob_short_name		IN OUT NOCOPY VARCHAR2,
				     X_structure_id		IN OUT NOCOPY NUMBER,
				     X_category_set_id		IN OUT NOCOPY NUMBER,
				     X_instance_org_id		IN OUT NOCOPY NUMBER,
				     X_instance_org_code	IN OUT NOCOPY VARCHAR2,
				     X_instance_org_name	IN OUT NOCOPY VARCHAR2,
				     X_display_find		IN OUT NOCOPY VARCHAR2,
				     X_default_results		IN OUT NOCOPY VARCHAR2,
				     X_display_inverse_rate	IN OUT NOCOPY VARCHAR2,
				     X_employee_id		IN OUT NOCOPY NUMBER,
				     X_employee_name		IN OUT NOCOPY VARCHAR2,
		                     X_def_deliver_to_loc_id	IN OUT NOCOPY NUMBER,
			             X_def_deliver_to_loc_name	IN OUT NOCOPY VARCHAR2,
			             X_def_deliver_to_org_id	IN OUT NOCOPY NUMBER,
			             X_def_deliver_to_org_name	IN OUT NOCOPY VARCHAR2,
			             X_def_deliver_to_org_code	IN OUT NOCOPY VARCHAR2,
				     X_ship_for_del_loc_id	IN OUT NOCOPY NUMBER,
				     X_ship_for_del_loc_name    IN OUT NOCOPY VARCHAR2,
				     X_legal_requisition_option IN OUT NOCOPY VARCHAR2,
				     X_chart_of_accounts_id	IN OUT NOCOPY NUMBER,
				     X_gl_date			IN OUT NOCOPY DATE,
				     X_window_org_id		IN OUT NOCOPY NUMBER,
				     X_window_org_name		IN OUT NOCOPY VARCHAR2,
				     X_enforce_full_lot_control IN OUT NOCOPY VARCHAR2,
				     X_disposition_warning_flag IN OUT NOCOPY VARCHAR2,
				     X_item_cross_ref_type	IN OUT NOCOPY VARCHAR2) IS

  X_progress          varchar2(3) := NULL;
  X_period_name	      varchar2(15):= NULL;
  X_employee_flag     boolean;
  X_is_emp            boolean;
  X_employee_is_buyer boolean;
  X_loc_is_valid      boolean;
  X_multi_org_form    boolean := FALSE;

BEGIN

  /* Get category set and structure. */

  X_progress := '010';
  po_core_s.get_item_category_structure(X_category_set_id,
					X_structure_id);

  /* Get Catalog profile options. */

  X_progress := '020';
  X_display_find := po_sourcing2_sv.get_display_find_option;

  X_progress := '030';
  X_default_results := po_sourcing2_sv.get_default_results_option;

  /* Get Legal Requisition Type profile option */

  X_progress := '031';
  fnd_profile.get('REQUISITION_TYPE', X_legal_requisition_option);

  /* Get the menu title */

  X_progress := '035';
  po_core_s3.get_window_org_sob(X_multi_org_form,
			        X_window_org_id,
			        X_window_org_name);

  /* Get the disposition message item cross reference type.
  */

  X_progress := '036';
  fnd_profile.get('PO_ITEM_REFERENCE_WARNING', X_item_cross_ref_type);

  /* Get working organization and set of books information.
  ** Also obtain the disposition warning flag from the
  ** purchasing options table.
  */

  X_progress := '040';

    SELECT fsp.inventory_organization_id,
	   ood.organization_code,
	   ood.organization_name,
	   fsp.set_of_books_id,
	   gsb.short_name,
	   gsb.currency_code,
	   gsb.chart_of_accounts_id,
	   psp.disposition_warning_flag,
	   psp.enforce_full_lot_quantities
    INTO   X_instance_org_id,
	   X_instance_org_code,
	   X_instance_org_name,
	   X_sob_id,
	   X_sob_short_name,
	   X_functional_currency_code,
	   X_chart_of_accounts_id,
	   X_disposition_warning_flag,
	   X_enforce_full_lot_control
    FROM   financials_system_parameters fsp,
	   gl_sets_of_books gsb,
	   org_organization_definitions ood,
	   po_system_parameters psp
    WHERE  fsp.set_of_books_id = gsb.set_of_books_id
    AND	   fsp.inventory_organization_id = ood.organization_id;


  /* Get the GL Date for the set of books. */

  X_progress := '041';
  po_core_s.get_period_name(X_sob_id,
			    X_period_name,
			    X_gl_date);

  /* Get current employee information for deliver-to defaults. */

  X_progress := '050';
  X_employee_flag := po_employees_sv.get_employee(X_employee_id,
						  X_employee_name,
						  X_def_deliver_to_loc_id,
						  X_def_deliver_to_loc_name,
						  X_employee_is_buyer,
						  X_is_emp);

  /* Get default deliver-to organization information for the default
  ** location.
  */

  X_progress := '060';
  po_locations_s.get_loc_org(X_def_deliver_to_loc_id,
			     X_sob_id,
			     X_def_deliver_to_org_id,
			     X_def_deliver_to_org_code,
			     X_def_deliver_to_org_name);

  /* Get the ship-to location associated with this deliver-to location.
  */

  X_progress := '065';
  X_loc_is_valid := po_locations_s.get_ship_to_location(X_def_deliver_to_loc_id,
						        X_ship_for_del_loc_id);

  /* Get the ship-to location name for this id. */

  X_progress := '066';
  po_locations_s.get_location_code(X_ship_for_del_loc_id,
				   X_ship_for_del_loc_name);


  /* Get the inverse rate profile option.
  ** DEBUG -- have my own call to fnd_profile.get because call to po_setup_s
  ** function to do this is not working.
  */

  X_progress := '080';
  fnd_profile.get('DISPLAY_INVERSE_RATE', X_display_inverse_rate);

EXCEPTION

  when others then
    po_message_s.sql_error('get_catalog_startup_values', X_progress, sqlcode);
    raise;

END get_catalog_startup_values;

END PO_SOURCING3_SV;

/
