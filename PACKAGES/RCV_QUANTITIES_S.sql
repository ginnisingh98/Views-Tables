--------------------------------------------------------
--  DDL for Package RCV_QUANTITIES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_QUANTITIES_S" AUTHID CURRENT_USER AS
/* $Header: RCVTXQUS.pls 120.0.12010000.3 2014/04/11 05:40:18 yilali ship $*/

/*===========================================================================
  PROCEDURE NAME:	get_available_quantity()

  DESCRIPTION:
	This procedure returns the available quantity to transact for each
  Receiving transaction in the parent transactions unit of measure.

  PARAMETERS:
  Name			     Mode  Type Required    Value	       Default

  p_transaction_type	     IN  VARCHAR2  Yes  RECEIVE, MATCH, TRANSFER
     						INSPECT, DELIVER, CORRECT,
						RETURN TO VENDOR,
						RETURN TO RECEIVING,
						DIRECT RECEIPT,
						STANDARD DELIVER	N/A

  p_parent_id		     IN  NUMBER    Yes  line_location_id or
						shipment_line_id or
						transaction_id or
						po_distribution_id  	N/A

  p_receipt_source_code      IN  VARCHAR2  No   VENDOR or INVENTORY or
 						INTERNAL ORDER		NULL

  p_parent_transaction_type  IN  VARCHAR2  No   UNORDERED, RECEIVE, MATCH,
						TRANSFER, ACCEPT, REJECT,
						DELIVER, RETURN TO VENDOR  NULL

  p_grand_parent_id	     IN  NUMBER    No   line_location_id or
						shipment_line_id or
						transaction_id 		0

  p_correction_type	     IN  VARCHAR2  No   NEGATIVE or POSITIVE   NEGATIVE

  p_available_quantity   IN OUT NOCOPY  NUMBER    Yes  			N/A

  p_tolerable_quantity   IN OUT NOCOPY  NUMBER    Yes                          N/A

  p_unit_of_measure      IN OUT NOCOPY  VARCHAR2  Yes                          N/A

  DESIGN REFERENCES:	RCVTXECO.dd

  ALGORITHM:

  NOTES:

  The following is a list of transaction types and the arguments that must
  be passed in order to use this function.

  1. RECEIVE or MATCH :
     p_transaction_type		RECEIVE or MATCH
     p_parent_id		line_location_id or shipment_line_id depending
				on Vendor receipt or Internal receipt.
     p_receipt_source_code	VENDOR or INVENTORY or INTERNAL ORDER
     p_available_quantity	Output parameter
     p_tolerable_quantity	Output parameter only needed for Vendor receipt
				Returned value is null otherwise
     p_unit_of_measure		Output parameter

  2. TRANSFER or INSPECT or DELIVER
     p_transaction_type		TRANSFER or INSPECT or DELIVER
     p_parent_id		transaction id of the parent transaction
     p_available_quantity	Output parameter
     p_tolerable_quantity	Output Parameter - Return value is null
     p_unit_of_measure		Output parameter

  3. RETURN TO VENDOR or RETURN TO RECEIVING or CORRECT (negative only)
     p_transaction_type		RETURN TO VENDOR or RETURN TO RECEIVING or
				CORRECT
     p_parent_id		transaction id of the parent transaction
     p_parent_transaction_type  UNORDERED or RECEIVE or MATCH or TRANSFER or
 				ACCEPT or REJECT or DELIVER or RETURN TO VENDOR
     p_correction_type		NEGATIVE
     p_available_quantity	Output parameter
     p_tolerable_quantity	Output Parameter - Return value is null
     p_unit_of_measure		Output parameter

  4. CORRECT (positive only)
     p_transaction_type		CORRECT
     p_parent_id		transaction id of the parent transaction
     p_receipt_source_code	VENDOR or INVENTORY or INTERNAL ORDER
     p_parent_transaction_type	RECEIVE or MATCH or TRANSFER or
 				ACCEPT or REJECT or DELIVER or RETURN TO VENDOR
     p_grand_parent_id		transaction id of the grand parent transaction
				or line_location_id for corrections against
 				   Vendor RECEIVE or MATCH
 				or shipment_line_id for corrections against
				   Internal RECEIVE
     p_correction_type		POSITIVE
     p_available_quantity 	Output parameter
     p_tolerable_quantity	Output parameter required for corrections
				against Vendor Receipts or Match transactions.
				Return value is null otherwise
     p_unit_of_measure		Output parameter

  5. DIRECT RECEIPT (to be called from the Enter Receipts form)
     p_transaction_type		DIRECT RECEIPT
     p_parent_id		po_distribution_id
     p_available_quantity 	Output parameter
     p_unit_of_measure		Output parameter

  6. STANDARD DELIVER (to be called from the Receiving Transactions form)
     p_transaction_type		STANDARD DELIVER
     p_parent_id		po_distribution_id
     p_grand_parent_id		rcv_transaction_id
     p_available_quantity 	Output parameter
     p_unit_of_measure		Output parameter

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

  Please fix both the get_available_quantity procedures since this is overloaded.
===========================================================================*/
PROCEDURE get_available_quantity(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_available_quantity      IN OUT NOCOPY NUMBER,
				 p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				 p_unit_of_measure         IN OUT NOCOPY VARCHAR2);


/* ========================================================================
This procedure performs the same funciton as the one above
It is overloaded for comon receiving project as this is called from
POXPOVPO2.pld to calculate quantity_due and in order not to hhave PO library
dependednt on a  receivcing package this was overloaded.
============================================================================*/
PROCEDURE get_available_quantity(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_available_quantity      IN OUT NOCOPY NUMBER,
				 p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				 p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
				/*Bug# 1548597 */
				 p_secondary_available_qty IN OUT NOCOPY NUMBER );

/*===========================================================================

 PROCEDURE NAME:	get_available_rma_amount()

 DESCRIPTION:
	This procedure returns the available amount to transact for each
  Receiving transaction.
===========================================================================*/
PROCEDURE get_available_amount(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_available_amount        IN OUT NOCOPY NUMBER,
				 p_tolerable_amount        IN OUT NOCOPY NUMBER);

/*===========================================================================

 PROCEDURE NAME:	get_available_rma_quantity()

 DESCRIPTION:
	This procedure returns the available quantity to transact for each
  Receiving transaction in the parent transactions unit of measure for the
  RMA transactions.
===========================================================================*/

PROCEDURE get_available_rma_quantity(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_oe_order_header_id	   IN  NUMBER,
				 p_oe_order_line_id	   IN  NUMBER,
				 p_available_quantity      IN OUT NOCOPY NUMBER,
				 p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				 p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
				/*Bug# 1548597 */
				 p_secondary_available_qty IN OUT NOCOPY NUMBER );


/*===========================================================================
  PROCEDURE NAME:	val_quantity()

  DESCRIPTION:
	o VAL - If primary return qty > primary available qty give error
		RCV_TRX_QTY_EXCEEDS_AVAILABLE
  PARAMETERS:

  DESIGN REFERENCES:	RCVTXECO.dd
			RCVTXERE.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE val_quantity;

/*===========================================================================
  PROCEDURE NAME:	get_primary_qty_uom()

  DESCRIPTION:		go get the primary quantity and uom for a given
			item based on a transaction quantity and uom

  PARAMETERS:		X_transaction_qty IN NUMBER,
			X_transaction_uom IN VARCHAR2,
			X_item_id         IN NUMBER,
			X_organization_id IN NUMBER,
			X_primary_qty     IN OUT NOCOPY NUMBER,
			X_primary_uom     IN OUT NOCOPY VARCHAR2);


  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
PROCEDURE get_primary_qty_uom (
X_transaction_qty IN NUMBER,
X_transaction_uom IN VARCHAR2,
X_item_id         IN NUMBER,
X_organization_id IN NUMBER,
X_primary_qty     IN OUT NOCOPY NUMBER,
X_primary_uom     IN OUT NOCOPY VARCHAR2);

/*=========================================================================*/
FUNCTION get_pending_qty(p_line_location_id IN NUMBER) RETURN NUMBER;

/*===========================================================================
  PROCEDURE NAME:	get_ship_qty_in_int()
  DESCRIPTION:		get qty in RTI for a particular PO shipment and ASN shipment

  PARAMETERS:		p_shipment_line_id IN NUMBER,
			p_line_location_id IN NUMBER,
			p_ship_qty_in_int  IN OUT NOCOPY NUMBER


  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
PROCEDURE get_ship_qty_in_int (
p_shipment_line_id IN NUMBER,
p_line_location_id IN NUMBER,
p_ship_qty_in_int  IN OUT NOCOPY NUMBER);


/*===========================================================================
  PROCEDURE NAME:	get_available_asn_quantity()
  DESCRIPTION:		get qty in RTI for a particular  ASN shipment for
			Standard and Direct receipts
===========================================================================*/

PROCEDURE get_available_asn_quantity(
                                 p_transaction_type      IN  VARCHAR2,
                                 p_shipment_line_id      IN  NUMBER,
                                 p_line_location_id      IN  NUMBER,
                                 p_distribution_id       IN  VARCHAR2,
                                 x_unit_of_measure       IN OUT NOCOPY VARCHAR2,                                 x_available_quantity    IN OUT NOCOPY NUMBER,
                                 x_tolerable_quantity    IN OUT NOCOPY NUMBER,
                                 x_secondary_available_qty IN OUT NOCOPY NUMBER);
/*===========================================================================
  begin bug 13892629
  PROCEDURE NAME:	get_deliver_quantity()
  DESCRIPTION:		get avialable qty for RTV/RTR agaisnt deliver transaction
  via ROI.
  p_transaction_id,            deliver transaction id
  p_interface_transaction_id,  RTV/RTR RTI interface transaction id
  p_available_quantity,        avaialble qty
  p_unit_of_measure,           uom
  p_secondary_available_qty,   sec available qty
===========================================================================*/
PROCEDURE get_deliver_quantity(
			       p_transaction_id                IN  NUMBER,
			       p_interface_transaction_id      IN  NUMBER,
			       p_available_quantity            IN OUT NOCOPY NUMBER,
			       p_unit_of_measure               IN OUT NOCOPY VARCHAR2,
			       p_secondary_available_qty       IN OUT NOCOPY NUMBER );
/* end fix of bug 13892629 */


/*===========================================================================
  begin bug 18483380
  PROCEDURE NAME:	get_negative_correct_rtp_qty()
  DESCRIPTION:		get avialable qty for correction agaisnt receiving transaction
  via ROI.
  p_transaction_id,            receiving transaction id
  p_interface_transaction_id,  correction RTI interface transaction id
  p_unit_of_measure,           uom
  p_available_quantity,        avaialble qty
===========================================================================*/

PROCEDURE get_negative_correct_rtp_qty(
           p_transaction_id        IN  NUMBER,
           p_tranx_interface_id IN  NUMBER,
				   p_available_quantity IN OUT NOCOPY NUMBER);

/* end fix of bug 18483380 */


END RCV_QUANTITIES_S;

/
