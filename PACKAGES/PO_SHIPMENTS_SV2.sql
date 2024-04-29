--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV2" AUTHID CURRENT_USER AS
/* $Header: POXPOS2S.pls 120.0.12010000.2 2011/12/09 09:40:39 inagdeo ship $*/

/*===========================================================================
  FUNCTION  NAME:	get_number_shipments

  DESCRIPTION:		Gets the number of shipments for a Planned
			or Blanket purchase order line.

  PARAMETERS:		X_po_line_id           IN     NUMBER,
		        X_shipment_type        IN     VARCHAR2

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION get_number_shipments
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2) RETURN NUMBER;

/*===========================================================================
  FUNCTION  NAME:	val_release_shipments

  DESCRIPTION:		Validates if there are any release shipments
			created.  If there is, we return failure.

  PARAMETERS:		X_po_line_id           IN     NUMBER,
		        X_shipment_type     IN     VARCHAR2

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/2	Created

===========================================================================*/
   FUNCTION val_release_shipments
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2) RETURN BOOLEAN;



/*===========================================================================
  PROCEDURE NAME:	get_shipment_status

  DESCRIPTION:		Gets the status flags of the shipment including:
				approved,
				cancelled,
				closed,
				encumbered

  PARAMETERS:

  DESIGN REFERENCES:	X_line_location_id     IN     NUMBER
		        X_shipment_type     IN     VARCHAR2
		        X_approved_flag        IN OUT VARCHAR2
		        X_encumbered_flag      IN OUT VARCHAR2
		        X_closed_code          IN OUT VARCHAR2
		        X_cancelled_flag       IN OUT VARCHAR2

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  PROCEDURE get_shipment_status
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
                       X_line_location_id     IN     NUMBER,
		       X_approved_flag        IN OUT NOCOPY VARCHAR2,
		       X_encumbered_flag      IN OUT NOCOPY VARCHAR2,
		       X_closed_code          IN OUT NOCOPY VARCHAR2,
		       X_cancelled_flag       IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  FUNCTION NAME:	update_shipment_quantity

  DESCRIPTION:		Updates the quantity on the shipment
			to be same as it is on the purchase
			order line.

  PARAMETERS:

  DESIGN REFERENCES:	X_line_location_id     IN     NUMBER
		        X_shipment_type     IN     VARCHAR2
		        X_line_quantity        IN     NUMBER


  ALGORITHM:

  NOTES:

  OPEN ISSUES:		Should we be checking finally closed? DEBUG.
			(5/1 - KP)

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION update_shipment_qty
		      (X_line_location_id     IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2,
		       X_line_quantity        IN     NUMBER) RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_ship_qty

  DESCRIPTION:		Validates if the shipment quantity can
			be updated with a planned or standard
			purchase order line quantity is updated.

  PARAMETERS:		X_po_line_id           IN     NUMBER
		        X_shipment_type     IN     VARCHAR2
		        X_line_quantity        IN     NUMBER

  DESIGN REFERENCES:


  ALGORITHM:		If this is not a standard or planned purchase
			order, do not update the shipment quantity.

			Get the number of shipments.

			If there is more than one shipment, do
			not update the shipment quantity.

			Get the status of the shipment.

			If the shipment is cancelled or encumbered,
			do not update the shipment quantity.

			Otherwise, update the shipment quantity.

  NOTES:

  OPEN ISSUES:		Should we be checking finally closed? DEBUG.
			(KP - 5/1)

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION val_ship_qty
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2,
		       X_line_quantity        IN     NUMBER) RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	val_ship_price

  DESCRIPTION:		Validates if the shipment price can be
			updated and calls the routine to update
			the shipment price.

  PARAMETERS:		X_po_line_id           IN     NUMBER
		        X_shipment_type     IN     VARCHAR2
		        X_unit_price           IN     NUMBER

  DESIGN REFERENCES:


  ALGORITHM:		If this is anything but a standard or planned purchase
			order, the price on the shipment cannot be updated.

			If it is a standard or planned purchase order, update
			the price.

  NOTES:

  OPEN ISSUES:		Should we be checking finally closed? DEBUG.
			(5/1 - KP)

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION val_ship_price
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2,
		       X_unit_price           IN     NUMBER    ) RETURN BOOLEAN;



/*===========================================================================
  FUNCTION NAME:	update_shipment_price

  DESCRIPTION:		Updates the price of the shipment.  This is
			called when a standard or planned purchase
		        order line is updated.  This should
			only be done if the shipment is not
			cancelled.

  PARAMETERS:		X_po_line_id           IN     NUMBER
		        X_shipment_type     IN     VARCHAR2
		        X_unit_price           IN     NUMBER

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION update_shipment_price
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type     IN     VARCHAR2,
		       X_unit_price           IN     NUMBER) RETURN BOOLEAN;


/*===========================================================================
  --togeorge 05/18/2001
  --Bug# 1712919
  PROCEDURE NAME:	get_drop_ship_cust_locations
			On enter po and release forms ship to location code
			is required column. Since hz_locations does not
			store location_code and corresponding location
			code is null in hr_locations table, when a drop
			ship PO/Rel is queried in the form the user wont
			be allowed to save the records. So this procedure
			gets the concatenated address1 and city from
			hz_locations table for this specific condition.
			Called from POXPOPOS.pld(post_query)

===========================================================================*/
   PROCEDURE get_drop_ship_cust_locations
		      (x_ship_to_location_id  	IN     NUMBER,
		       x_ship_to_location_code  IN OUT NOCOPY VARCHAR2);

/*===========================================================================
  Bug 12830677
  PROCEDURE NAME: null_reference_fields
                  To remove reference at shipment level.

===========================================================================*/
   PROCEDURE null_reference_fields  (X_po_line_id   IN     NUMBER);


END PO_SHIPMENTS_SV2;

/
