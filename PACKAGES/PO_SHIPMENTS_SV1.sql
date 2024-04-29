--------------------------------------------------------
--  DDL for Package PO_SHIPMENTS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SHIPMENTS_SV1" AUTHID CURRENT_USER as
/* $Header: POXPOS1S.pls 115.2 2002/11/25 22:39:35 sbull ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_SHIPMENTS_SV1

  DESCRIPTION:		Contains the server side Shipment APIS

  CLIENT/SERVER:	Server

  LIBRARY NAME:		NONE

  OWNER:		KPOWELL

  PROCEDURES/FUNCTIONS:
			get_shipment_num()
			get_planned_ship_info()
			val_ship_num_unique()
			get_quantity_ordered()
			get_quantity_released()
			val_quantity_released()


===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_shipment_num

  DESCRIPTION:		Gets the next shipment number to be defaulted for
			a line or a release.

			For a release, pass in release_id
			For a po, rfq, quote, pass in line_id

  PARAMETERS:		X_po_release_id		IN	NUMBER
			X_po_line_id 		IN      NUMBER
			X_shipment_num		IN OUT  NUMBER

  DESIGN REFERENCES:


  ALGORITHM:		Get the maximum shipment number associated with
			a release or a line.

			If a value is not returned, then no shipments
			have been created to date and the value should
			be set to 1.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		4/20	Created

===========================================================================*/
  PROCEDURE get_shipment_num
		      (X_po_release_id IN     NUMBER,
		       X_po_line_id    IN     NUMBER,
		       X_shipment_num  IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:	get_planned_shipment_info

  DESCRIPTION:		Gets the planned shipment information when
			creating a scheduled release shipment against
			the planned shipment.

  PARAMETERS:		X_source_shipment_id      IN     NUMBER,
                        X_set_of_books_id         IN     NUMBER,
                        X_ship_to_location_code   IN OUT VARCHAR2,
		        X_ship_to_location_id     IN OUT NUMBER,
		        X_ship_to_org_code        IN OUT VARCHAR2,
		        X_ship_to_organization_id IN OUT NUMBER,
		        X_quantity                IN OUT NUMBER

  DESIGN REFERENCES:


  ALGORITHM:		Get the information from the planned shipment.

			Get the location code associated with the
			planned ship to location id.

			Get the organization code associated with the
			planned ship to organization id.

  NOTES:

  OPEN ISSUES:		DEBUG.  Need to include the calls to the
			location and organization routines. (KP - 5/4)


  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/4	Created
                        SIYER           6/6     Added the calls to location
                                                and org rtns.
                                                Needed an additional parameter
                                                X_set_of_books_id.
===========================================================================*/
  PROCEDURE get_planned_ship_info
		      (X_source_shipment_id      IN     NUMBER,
                       X_set_of_books_id         IN     NUMBER,
                       X_ship_to_location_code   IN OUT NOCOPY VARCHAR2,
		       X_ship_to_location_id     IN OUT NOCOPY NUMBER,
		       X_ship_to_org_code        IN OUT NOCOPY VARCHAR2,
		       X_ship_to_organization_id IN OUT NOCOPY NUMBER,
		       X_quantity                IN OUT NOCOPY NUMBER,
		       X_price_override		 IN OUT NOCOPY NUMBER,
		       X_promised_date	         IN OUT NOCOPY DATE,
		       X_need_by_date            IN OUT NOCOPY DATE,
		       X_taxable_flag 		 IN OUT NOCOPY VARCHAR2,
		       X_tax_name                IN OUT NOCOPY VARCHAR2,
                       X_enforce_ship_to_location   IN OUT NOCOPY VARCHAR2,
                       X_allow_substitute_receipts  IN OUT NOCOPY VARCHAR2,
                       X_receiving_routing_id       IN OUT NOCOPY NUMBER  ,
                       X_qty_rcv_tolerance          IN OUT NOCOPY NUMBER  ,
                       X_qty_rcv_exception_code     IN OUT NOCOPY VARCHAR2  ,
                       X_days_early_receipt_allowed IN OUT NOCOPY NUMBER ,
                       X_last_accept_date        IN OUT NOCOPY DATE,
		       X_days_late_receipt_allowed  IN OUT NOCOPY NUMBER  ,
                       X_receipt_days_exception_code IN OUT NOCOPY VARCHAR2  ,
                       X_invoice_close_tolerance IN OUT NOCOPY NUMBER,
		       X_receive_close_tolerance IN OUT NOCOPY NUMBER,
		       X_accrue_on_receipt_flag  IN OUT NOCOPY VARCHAR2,
		       X_receipt_required_flag   IN OUT NOCOPY VARCHAR2,
		       X_inspection_required_flag IN OUT NOCOPY VARCHAR2);



/*===========================================================================
  FUNCTION  NAME:	get_sched_released_qty

  DESCRIPTION:		Gets the quantity released against a planned
			purchase order shipment or planned purchase
			order line.

  PARAMETERS:		X_source_id        IN NUMBER,
		        X_entity_level     IN VARCHAR2,
			X_shipment_type    IN VARCHAR2

  DESIGN REFERENCES:


  ALGORITHM:		If this is for a planned purchase order line,
			  get the quantity released as the sum of
			  quantity ordered - quantity cancelled for
			  all scheduled release shipments against
			  the planned purchase order line.

			If this is for a planned purchase order shipment,
			  get the quantity released as the sum of
			  quantity ordered - quantity cancelled for
			  all scheduled release shipments against
			  the planned purchase order shipment.

			If this is for a scheduled purchase order shipment,
			  1.  get the planned purchase order shipment
				number that it is create from
			  2.  get the quantity released as the sum
				of quantity ordered - quantity cancelled for
				all scheduled release shipments against
				the planned purchase order shipment.
  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION get_sched_released_qty
		      (X_source_id            IN     NUMBER,
		       X_entity_level         IN     VARCHAR2,
		       X_shipment_type        IN     VARCHAR2) RETURN NUMBER;

/*===========================================================================
  FUNCTION  NAME:	val_sched_released_qty

  DESCRIPTION:		Verify if the quantity released is greater
			than the quantity ordered.  If it is,
			the form needs to display a message to the
			user.

  PARAMETERS:		X_entity_level         IN     VARCHAR2,
		        X_line_id              IN     NUMBER,
		        X_line_location_id     IN     NUMBER,
		        X_shipment_type        IN     VARCHAR2,
		        X_quantity_ordered     IN     NUMBER,
                        X_source_shipment_id   IN     NUMBER

  DESIGN REFERENCES:


  ALGORITHM:		This routine can be called either from the
			planned purchase order line or shipment or
			the scheduled release.

			If this is called for a planned purchase order
			shipment, the user should pass in the
			quantity ordered on the purchase order shipment.
			We will then call the routine to get the
			total quantity released for the planned purchase
			order shipment.

			If this is called for a scheduled shipment,
			the user will need to get the quantity ordered
			on the planned purchase order shipment and
			then the total quantity released against the
			planned purchase order shipment.

			If this is called for a planned purchase order
			line, the user should pass in the quantity
			ordered on the purchase order line.
			We will then call the routine to get the
			total quantity released for the planned purchase
			order line.

			If the quantity released is greater than the
			quantity ordered, return failure.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL		5/1	Created

===========================================================================*/
  FUNCTION val_sched_released_qty
		      (X_entity_level         IN     VARCHAR2,
		       X_line_id              IN     NUMBER,
		       X_line_location_id     IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
		       X_quantity_ordered     IN     NUMBER,
                       X_source_shipment_id   IN     NUMBER ) RETURN BOOLEAN;

END PO_SHIPMENTS_SV1;

 

/
