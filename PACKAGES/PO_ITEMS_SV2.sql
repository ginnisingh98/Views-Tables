--------------------------------------------------------
--  DDL for Package PO_ITEMS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ITEMS_SV2" AUTHID CURRENT_USER as
/* $Header: POXCOI2S.pls 120.0 2005/06/01 19:45:33 appldev noship $ */
/*===========================================================================
  PACKAGE NAME:		PO_ITEMS_SV2

  DESCRIPTION:		This package contains the server side Item related
			Application Program Interfaces (APIs). This api
			obtains information based on the item and organization.

  CLIENT/SERVER:	Server

  OWNER:		Melissa Snyder

  PROCEDURE NAMES:	get_item_details()
                        get_item_status()
			get_item_cost ()

===========================================================================*/

 procedure get_item_details( X_item_id                     IN     NUMBER,
                             X_inventory_organization_id   IN     NUMBER,
                             X_planned_item_flag           IN OUT NOCOPY VARCHAR2,
                             X_outside_operation_flag      IN OUT NOCOPY VARCHAR2,
                             X_outside_op_uom_type         IN OUT NOCOPY VARCHAR2,
                             X_invoice_close_tolerance     IN OUT NOCOPY NUMBER,
                             X_receive_close_tolerance     IN OUT NOCOPY NUMBER,
                             X_receipt_required_flag       IN OUT NOCOPY VARCHAR2,
                             X_stock_enabled_flag          IN OUT NOCOPY VARCHAR2,
			     X_internal_orderable	   IN OUT NOCOPY VARCHAR2,
			     X_purchasing_enabled	   IN OUT NOCOPY VARCHAR2,
			     X_inventory_asset_flag	   IN OUT NOCOPY VARCHAR2,
                             /* INVCONV BEGIN PBAMB */
                             X_secondary_default_ind	   IN OUT NOCOPY VARCHAR2,
    	                     X_grade_control_flag	   IN OUT NOCOPY VARCHAR2,
                             X_secondary_unit_of_measure   IN OUT NOCOPY VARCHAR2 );
                             /* INVCONV END PBAMB */

/*===========================================================================
  PROCEDURE NAME:	get_item_status

  DESCRIPTION:		Get the item status for autocreating shipments/distributions.
                        This has been created to cause the least amount of
                        ripple effect to all other people who might have already
                        used either get_item_details or get_item_info procedures.
                        This can ceratinly be merged into both those procedures.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		31-JUL-95         SIYER
==============================================================================*/

 procedure get_item_status( X_item_id                      IN     NUMBER,
                            X_ship_org_id                  IN     NUMBER,
                            X_item_status                  IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	get_latest_item_rev

  DESCRIPTION:		get the latest implemented item rev to be used as
                        a default for the Enter Receipts form

  PARAMETERS:		X_item_id			IN	NUMBER,
                        X_organization_id               IN      NUMBER
                        X_item_revision			IN OUT	VARCHAR2,
			X_rev_exists		        OUT	BOOLEAN

  DESIGN REFERENCES:	../RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		27-JUN-95         GKELLNER
===========================================================================*/

PROCEDURE get_latest_item_rev (
X_item_id         IN NUMBER,
X_organization_id IN NUMBER,
X_item_revision   IN OUT NOCOPY VARCHAR2,
X_rev_exists      OUT NOCOPY BOOLEAN);

/*===========================================================================
  PROCEDURE NAME:	val_item_rev_controls

  DESCRIPTION:		get the item revision control flag and if needed, try
			to get the most up-to-date revision.
			You only need to check for item rev if you're doing an
			receipt/delivery for an inventory final destination

  PARAMETERS:		X_transaction_type      IN VARCHAR2
			X_auto_transact_code    IN VARCHAR2
			X_po_line_location_id   IN NUMBER
			X_shipment_line_id      IN NUMBER
			X_to_organization_id    IN NUMBER
			X_destination_type_code IN VARCHAR2
			X_item_id               IN NUMBER
			X_item_revision         IN VARCHAR2

  RETURN 		BOOLEAN  - Is the item rev valid based on the
			destination type

  DESIGN REFERENCES:	../RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		10-JUL-95         GKELLNER
===========================================================================*/

FUNCTION val_item_rev_controls (
X_transaction_type      IN VARCHAR2,
X_auto_transact_code    IN VARCHAR2,
X_po_line_location_id   IN NUMBER,
X_shipment_line_id      IN NUMBER,
X_to_organization_id    IN NUMBER,
X_destination_type_code IN VARCHAR2,
X_item_id               IN NUMBER,
X_item_revision         IN VARCHAR2)
RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	get_item_cost

  DESCRIPTION:		Obtain the item cost. If the
			cost is not available then this
			procedure returns zero.

  PARAMETERS:		x_item_id		  IN  NUMBER
			x_organization_id	  IN  NUMBER
			x_inv_cost		  OUT NUMBER

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	04/16	Created
===========================================================================*/

PROCEDURE get_item_cost	(x_item_id   		 IN  NUMBER,
		         x_organization_id	 IN  NUMBER,
			 x_inv_cost		 OUT NOCOPY NUMBER);

END PO_ITEMS_SV2;

 

/
