--------------------------------------------------------
--  DDL for Package PO_SOURCING3_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SOURCING3_SV" AUTHID CURRENT_USER as
/* $Header: POXSCS3S.pls 115.6 2003/01/14 22:01:06 davidng ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_SOURCING3_SV

  DESCRIPTION:		This package contains the server side Supplier Item
			Catalog and Sourcing Application Program Interfaces
			(APIs).

  CLIENT/SERVER:	Server

  OWNER:		Liza Broadbent

  FUNCTION/PROCEDURE:	get_catalog_startup_values()
			val_src_dest()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_catalog_startup_values()

  DESCRIPTION:		This procedure returns the startup values needed
		        for the Supplier-Item Catalog


  PARAMETERS:		 X_functional_currency_code     IN OUT VARCHAR2,
		         X_sob_id			IN OUT NUMBER,
		         X_sob_short_name		IN OUT VARCHAR2,
		         X_structure_id		        IN OUT NUMBER,
		         X_category_set_id		IN OUT NUMBER,
			 X_instance_org_id		IN OUT NUMBER,
		         X_instance_org_code		IN OUT VARCHAR2,
			 X_instance_org_name		IN OUT VARCHAR2,
			 X_display_find			IN OUT VARCHAR2,
			 X_default_results		IN OUT VARCHAR2,
			 X_display_inverse_rate		IN OUT VARCHAR2,
			 X_employee_id			IN OUT NUMBER,
			 X_employee_name		IN OUT VARCHAR2,
			 X_def_deliver_to_loc_id	IN OUT NUMBER,
			 X_def_deliver_to_loc_name	IN OUT VARCHAR2,
			 X_def_deliver_to_org_id	IN OUT NUMBER,
			 X_def_deliver_to_org_name	IN OUT VARCHAR2,
			 X_def_deliver_to_org_code	IN OUT VARCHAR2,
			 X_ship_for_del_loc_id	        IN OUT NUMBER,
			 X_ship_for_del_loc_name        IN OUT VARCHAR2,
			 X_legal_requisition_option	IN OUT VARCHAR2,
			 X_chart_of_accounts_id		IN OUT NUMBER,
			 X_gl_date			IN OUT DATE,
			 X_window_org_id		IN OUT NUMBER,
			 X_window_org_name		IN OUT VARCHAR2,
			 X_enforce_full_lot_control     IN OUT VARCHAR2,
			 X_disposition_warning_flag	IN OUT VARCHAR2,
			 X_item_cross_ref_type	        IN OUT VARCHAR2)


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	14-AUG-95	LBROADBE
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
				     X_def_deliver_to_loc_name  IN OUT NOCOPY VARCHAR2,
				     X_def_deliver_to_org_id    IN OUT NOCOPY NUMBER,
   				     X_def_deliver_to_org_name  IN OUT NOCOPY VARCHAR2,
				     X_def_deliver_to_org_code  IN OUT NOCOPY VARCHAR2,
				     X_ship_for_del_loc_id      IN OUT NOCOPY NUMBER,
				     X_ship_for_del_loc_name    IN OUT NOCOPY VARCHAR2,
				     X_legal_requisition_option IN OUT NOCOPY VARCHAR2,
				     X_chart_of_accounts_id	IN OUT NOCOPY NUMBER,
				     X_gl_date			IN OUT NOCOPY DATE,
				     X_window_org_id		IN OUT NOCOPY NUMBER,
				     X_window_org_name		IN OUT NOCOPY VARCHAR2,
				     X_enforce_full_lot_control IN OUT NOCOPY VARCHAR2,
				     X_disposition_warning_flag IN OUT NOCOPY VARCHAR2,
				     X_item_cross_ref_type      IN OUT NOCOPY VARCHAR2);

END PO_SOURCING3_SV;

 

/
