--------------------------------------------------------
--  DDL for Package PO_ITEMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ITEMS_SV" AUTHID CURRENT_USER as
/* $Header: POXCOI1S.pls 120.1.12010000.5 2012/09/03 10:40:23 jksampat ship $ */
/*===========================================================================
  PACKAGE NAME:		PO_ITEMS_SV

  DESCRIPTION:		This package contains the server side Item related
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  PROCEDURE NAMES:	val_item_org()
			get_item_info()
			get_item_defaults()
			get_hazard_class()
			get_un_number()
			val_item_revision()
			val_item_rev_controls()
			val_category()
===========================================================================*/

/*===========================================================================
  FUNCTION NAME:	val_category()

  DESCRIPTION:		This function checks whether a given Item Category
			is still valid.


  PARAMETERS:	   	X_category_id  IN NUMBER
			X_structure_id IN NUMBER

  RETURN TYPE:		BOOLEAN

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	09-JUL-1995	LBROADBE
			Changed to	14-AUG-1995	LBROADBE
			Function
===========================================================================*/
FUNCTION val_category(X_category_id  IN NUMBER,
		      X_structure_id IN NUMBER) return BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:	val_item_org()

  DESCRIPTION:		This procedure validates the item and it's revision
			are valid for a selected organization.  If
			has no revision, it verifies the item only is valid
			for the selected organization.

  PARAMETERS:		X_item_revision		  IN		VARCHAR2,
			X_item_id		  IN		NUMBER,
			X_master_ship_org_id	  IN		NUMBER,
			X_outside_operation_flag  IN		VARCHAR2,
			X_item_valid		  IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE val_item_org (X_item_revision		  IN		VARCHAR2,
			X_item_id		  IN		NUMBER,
			X_master_ship_org_id	  IN		NUMBER,
			X_outside_operation_flag  IN	 	VARCHAR2,
			X_item_valid		  IN OUT	NOCOPY VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:	get_item_info()

  DESCRIPTION:		This procedure is a cover routine which gets numerous
			item related information when the item has been
			modified.

  PARAMETERS:		X_type_lookup_code		IN	VARCHAR2,
			X_category_set_id		IN	NUMBER,
			X_item_id			IN	NUMBER,
			X_inventory_organization_id	IN	NUMBER,
			X_item_description		IN OUT	VARCHAR2,
			X_unit_meas_lookup_code		IN OUT	VARCHAR2,
			X_unit_price			IN OUT	NUMBER,
			X_category_id			IN OUT	NUMBER,
			X_purchasing_enabled_flag	IN OUT	VARCHAR2,
			X_internal_order_enabled_flag	IN OUT	VARCHAR2,
			X_outside_op_uom_type		IN OUT	VARCHAR2,
			X_inventory_asset_flag		IN OUT	VARCHAR2,
			X_allow_item_desc_update_flag	IN OUT	VARCHAR2,
			X_allowed_units_lookup_code	IN OUT	NUMBER,
			X_primary_unit_class		IN OUT	VARCHAR2,
			X_rfq_required_flag		IN OUT	VARCHAR2,
			X_un_number_id			IN OUT	NUMBER,
			X_hazard_class_id		IN OUT	NUMBER,
			X_inv_planned_item_flag		IN OUT	VARCHAR2,
			X_mrp_planned_item_flag		IN OUT	VARCHAR2,
			X_taxable_flag 			IN OUT 	VARCHAR2,
			X_market_price			IN OUT	NUMBER,
			X_invoice_close_tolerance	IN OUT	NUMBER,
			X_receive_close_tolerance	IN OUT	NUMBER,
			X_receipt_required_flag		IN OUT	VARCHAR2,
			X_restrict_subinventories_code	IN OUT	NUMBER,
			X_hazard_class			IN OUT	VARCHAR2,
			X_un_number			IN OUT	VARCHAR2,
			X_stock_enabled_flag		IN OUT	VARCHAR2,
			X_outside_operation_flag	IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXPOREL.doc
			../POXRQERQ.doc
			../POXSCERQ.dd
			../RCVRCERC.dd
			../RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE get_item_info(X_type_lookup_code		IN	VARCHAR2,
			X_category_set_id		IN	NUMBER,
			X_item_id			IN	NUMBER,
			X_inventory_organization_id	IN	NUMBER,
			X_source_type_lookup_code	IN	VARCHAR2,
			X_item_description		IN OUT	NOCOPY VARCHAR2,
			X_unit_meas_lookup_code		IN OUT	NOCOPY VARCHAR2,
			X_unit_price			IN OUT	NOCOPY NUMBER,
			X_category_id			IN OUT	NOCOPY NUMBER,
			X_purchasing_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			X_internal_order_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			X_outside_op_uom_type		IN OUT	NOCOPY VARCHAR2,
			X_inventory_asset_flag		IN OUT	NOCOPY VARCHAR2,
			X_allow_item_desc_update_flag	IN OUT	NOCOPY VARCHAR2,
			X_allowed_units_lookup_code	IN OUT	NOCOPY NUMBER,
			X_primary_unit_class		IN OUT	NOCOPY VARCHAR2,
			X_rfq_required_flag		IN OUT	NOCOPY VARCHAR2,
			X_un_number_id			IN OUT	NOCOPY NUMBER,
			X_hazard_class_id		IN OUT	NOCOPY NUMBER,
			X_inv_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_mrp_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_taxable_flag 			IN OUT NOCOPY 	VARCHAR2,
			X_market_price			IN OUT	NOCOPY NUMBER,
			X_invoice_close_tolerance	IN OUT	NOCOPY NUMBER,
			X_receive_close_tolerance	IN OUT	NOCOPY NUMBER,
			X_receipt_required_flag		IN OUT	NOCOPY VARCHAR2,
			X_restrict_subinventories_code	IN OUT	NOCOPY NUMBER,
			X_hazard_class			IN OUT	NOCOPY VARCHAR2,
			X_un_number			IN OUT	NOCOPY VARCHAR2,
			X_stock_enabled_flag		IN OUT	NOCOPY VARCHAR2,
			X_outside_operation_flag	IN OUT	NOCOPY VARCHAR2,
			-- MC INVCONV START
			X_secondary_default_ind		IN OUT NOCOPY VARCHAR2,
    	           	X_grade_control_flag		IN OUT NOCOPY VARCHAR2,
   			X_secondary_unit_of_measure	IN OUT NOCOPY VARCHAR2);
   			-- MC INVCONV END

/*===========================================================================
  PROCEDURE NAME:	get_item_defaults()

  DESCRIPTION:		This procedure gets default information based on
			the value of the item, category set, and current
			organization.

  PARAMETERS:		X_type_lookup_code		IN	VARCHAR2,
			X_category_set_id		IN	NUMBER,
			X_item_id			IN	NUMBER,
			X_inventory_organization_id	IN	NUMBER,
			X_source_type_lookup_code	IN	VARCHAR2,
			X_item_description		IN OUT	VARCHAR2,
			X_unit_meas_lookup_code		IN OUT	VARCHAR2,
			X_unit_price			IN OUT	NUMBER,
			X_category_id			IN OUT	NUMBER,
			X_purchasing_enabled_flag	IN OUT	VARCHAR2,
			X_internal_order_enabled_flag	IN OUT	VARCHAR2,
			X_outside_op_uom_type		IN OUT	VARCHAR2,
			X_inventory_asset_flag		IN OUT	VARCHAR2,
			X_allow_item_desc_update_flag	IN OUT	VARCHAR2,
			X_allowed_units_lookup_code	IN OUT	NUMBER,
			X_primary_unit_class		IN OUT	VARCHAR2,
			X_rfq_required_flag		IN OUT	VARCHAR2,
			X_un_number_id			IN OUT	NUMBER,
			X_hazard_class_id		IN OUT	NUMBER,
			X_inv_planned_item_flag		IN OUT	VARCHAR2,
			X_mrp_planned_item_flag		IN OUT	VARCHAR2,
			X_planned_item_flag		IN OUT	VARCHAR2,
			X_taxable_flag 			IN OUT 	VARCHAR2,
			X_market_price			IN OUT	NUMBER,
			X_invoice_close_tolerance	IN OUT	NUMBER,
			X_receive_close_tolerance	IN OUT	NUMBER,
			X_receipt_required_flag		IN OUT	VARCHAR2,
			X_restrict_subinventories_code	IN OUT	NUMBER,
			X_stock_enabled_flag		IN OUT  VARCHAR2,
			X_outside_operation_flag	IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXRQERQ.doc
			../POXSCERQ.dd
  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE get_item_defaults
		       (X_type_lookup_code		IN	VARCHAR2,
			X_category_set_id		IN	NUMBER,
			X_item_id			IN	NUMBER,
			X_inventory_organization_id	IN	NUMBER,
			X_source_type_lookup_code	IN	VARCHAR2,
			X_item_description		IN OUT	NOCOPY VARCHAR2,
			X_unit_meas_lookup_code		IN OUT	NOCOPY VARCHAR2,
			X_unit_price			IN OUT	NOCOPY NUMBER,
			X_category_id			IN OUT	NOCOPY NUMBER,
			X_purchasing_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			X_internal_order_enabled_flag	IN OUT	NOCOPY VARCHAR2,
			X_outside_op_uom_type		IN OUT	NOCOPY VARCHAR2,
			X_inventory_asset_flag		IN OUT	NOCOPY VARCHAR2,
			X_allow_item_desc_update_flag	IN OUT	NOCOPY VARCHAR2,
			X_allowed_units_lookup_code	IN OUT	NOCOPY NUMBER,
			X_primary_unit_class		IN OUT	NOCOPY VARCHAR2,
			X_rfq_required_flag		IN OUT	NOCOPY VARCHAR2,
			X_un_number_id			IN OUT	NOCOPY NUMBER,
			X_hazard_class_id		IN OUT	NOCOPY NUMBER,
			X_inv_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_mrp_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_planned_item_flag		IN OUT	NOCOPY VARCHAR2,
			X_taxable_flag 			IN OUT NOCOPY 	VARCHAR2,
			X_market_price			IN OUT	NOCOPY NUMBER,
			X_invoice_close_tolerance	IN OUT	NOCOPY NUMBER,
			X_receive_close_tolerance	IN OUT	NOCOPY NUMBER,
			X_receipt_required_flag		IN OUT	NOCOPY VARCHAR2,
			X_restrict_subinventories_code	IN OUT	NOCOPY NUMBER,
			X_stock_enabled_flag		IN OUT	NOCOPY VARCHAR2,
			X_outside_operation_flag	IN OUT	NOCOPY VARCHAR2,
			-- MC INVCONV START
			X_secondary_default_ind		IN OUT NOCOPY VARCHAR2,
    	           	X_grade_control_flag		IN OUT NOCOPY VARCHAR2,
   			X_secondary_unit_of_measure	IN OUT NOCOPY VARCHAR2);
   			-- MC INVCONV END

/*===========================================================================
  PROCEDURE NAME:	get_hazard_class()

  DESCRIPTION:		This procedure gets the hazard class using the hazard
			class id.

  PARAMETERS:		X_hazard_class_id		IN	NUMBER,
			X_hazard_class			IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE get_hazard_class
			(X_hazard_class_id		IN	NUMBER,
		 	 X_hazard_class			IN OUT	NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	get_un_number()

  DESCRIPTION:		This procedure gets the UN number using the
			un_number_id.

  PARAMETERS:		X_un_number_id			IN	NUMBER,
			X_un_number			IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXPOMPO.doc
			../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE get_un_number(X_un_number_id			IN	NUMBER,
			X_un_number			IN OUT	NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	val_item_revision()

  DESCRIPTION:		This procedure verifies the item revision is valid
			for the destination organization.  If it is not, it
			clears the destination organization information.

  PARAMETERS:		X_item_revision			IN	VARCHAR2,
			X_item_id			IN	NUMBER,
			X_destination_org_id		IN OUT	NUMBER,
			X_deliver_to_location_id	IN OUT	NUMBER,
			X_destination_subinventory	IN OUT	VARCHAR2,
			X_destination_org_name		IN OUT	VARCHAR2,
			X_revision_is_valid		IN OUT	VARCHAR2

  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-MAY-95	MSNYDER
===========================================================================*/

PROCEDURE val_item_revision(X_item_revision		IN	VARCHAR2,
			    X_item_id			IN	NUMBER,
			    X_destination_org_id	IN OUT	NOCOPY NUMBER,
			    X_deliver_to_location_id	IN OUT	NOCOPY NUMBER,
			    X_destination_subinventory	IN OUT	NOCOPY VARCHAR2,
			    X_destination_org_name	IN OUT	NOCOPY VARCHAR2,
			    X_revision_is_valid		IN OUT	NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	get_secondary_attributes()

  DESCRIPTION:

  PARAMETERS:		X_item_id                    IN      NUMBER,
			X_inventory_organization_id  IN      NUMBER,
			X_fetch_secondary_uom	IN      VARCHAR2 DEFAULT 'Y',
			X_secondary_unit_of_measure	IN OUT  NOCOPY VARCHAR2,
			X_secondary_default_ind	   OUT  NOCOPY VARCHAR2,
			X_grade_control_flag		   OUT  NOCOPY VARCHAR2,
			X_secondary_unit_of_measure_tl  OUT  NOCOPY VARCHAR2);

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		10-nov-2004	PBAMB
===========================================================================*/
PROCEDURE get_secondary_attributes (
			   X_item_id                    IN      NUMBER,
			   X_inventory_organization_id  IN      NUMBER,
			   X_fetch_secondary_uom	IN      VARCHAR2 DEFAULT 'Y',
			   X_secondary_unit_of_measure	IN OUT  NOCOPY VARCHAR2,
			   X_secondary_default_ind	   OUT  NOCOPY VARCHAR2,
			   X_grade_control_flag		   OUT  NOCOPY VARCHAR2,
			   X_secondary_unit_of_measure_tl  OUT  NOCOPY VARCHAR2);

-- bug5467964 START
PROCEDURE has_valid_item_rev_for_line
( p_item_id IN NUMBER,
  p_has_line_been_saved_flag IN VARCHAR2,
  p_po_line_id IN NUMBER,
  p_sob_id IN NUMBER,
  x_result OUT NOCOPY VARCHAR2
);
-- bug5467964 END

END PO_ITEMS_SV;

/
