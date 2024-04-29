--------------------------------------------------------
--  DDL for Package RCV_DATES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_DATES_S" AUTHID CURRENT_USER AS
/* $Header: RCVTXDAS.pls 115.1 2002/11/23 00:56:18 sbull ship $*/

/*===========================================================================

  FUNCTION NAME:	val_trx_date()

  DESCRIPTION:

	Function performs the following validations:

	1) Transaction date must be less than or equal to sysdate.

	2) For transacation types of 'RECEIVE' or 'MATCH' for a vendor, calls
	   val_receipt_date_tolerance to validate that the transaction date
	   falls within the Early/Late receipt date tolerance.

	3) Calls PO_DATES_S.val_open_period to check if transaction date is in
 	   an open GL period.

	4) Calls PO_DATES_S.val_open_period to first check if inventory is
	   installed.  If so, it checks that the transaction date is in an open
	   inventory period.

	5) Calls PO_DATES_S.val_open_period to first check if purchasing is
           installed.  If so, it checks that the transaction date is in an open
           purchasing period.

	6) Parent transaction date must be less than or equal to the
	   transaction date unless transaction type is 'RECEIVE'or 'UNORDERED'
	   (which have no parents).  If the parent transaction date is null,
	   get the date using the parent transaction id.

	7) For transacation type of 'RECEIVE' internally, the transaction date
 	   must be greater than or equal to the shipped date for shipment
	   lines.

  PARAMETERS:

  Parameter	  IN/OUT   Datatype	Description
  --------------- -------- ------------ --------------------------------------

  x_trx_date        IN 	   DATE		Transaction Date to be validated.

  x_trx_type	    IN     VARCHAR2	Transaction Type:
					  ACCEPT, CORRECT, DELIVER, MATCH,
					  RECEIVE, REJECT, RETURN TO RECEIVING,
			   		  RETURN TO VENDOR, TRANSFER, UNORDERED

  x_parent_trx_date IN     DATE		Parent Transaction Date.

  x_line_loc_id	    IN     NUMBER	Line location ID.  Used for validating
					receipt date tolerance for transaction
					types 'RECEIVE' or 'MATCH' that are for
					a vendor.

  x_ship_line_id    IN     NUMBER	Shipment line ID.  Used for validating
					shipment date for transaction type
					'RECEIVE' internally.  Null otherwise.

  x_parent_trx_id   IN     NUMBER	Parent transaction ID.  Line location
					ID for transaction types 'RECEIVE' or
					'MATCH' that are for a vendor.
					Shipment line ID for transaction types
 					'RECEIVE' or 'MATCH' internally.
					Parent transaction ID otherwise.

  x_sob_id	    IN     NUMBER	Set of Books ID.

  x_org_id	    IN     NUMBER	Organization ID.

  x_receipt_source_code IN VARCHAR2     Receipt Source Code:
					  Internal Order
					  Inventory
					  Vendor

  RETURN VALUE:	    TRUE if all of the above date checks are TRUE.
		    FALSE if any of the above date checks are FALSE.

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXECO.dd
			RCVTXERE.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_trx_date(x_trx_date            IN DATE,
		      x_trx_type	    IN VARCHAR2,
		      x_parent_trx_date     IN OUT NOCOPY DATE,
		      x_line_loc_id	    IN NUMBER,
		      x_ship_line_id	    IN NUMBER,
		      x_parent_trx_id	    IN NUMBER,
		      x_sob_id		    IN NUMBER,
		      x_org_id		    IN NUMBER,
		      x_receipt_source_code IN VARCHAR2) RETURN BOOLEAN;

/*===========================================================================
  FUNCTION NAME:	val_receipt_date_tolerance()

  DESCRIPTION:		Determines if the receipt date falls within the
			receipt date tolerance window.  If it does, the
			function returns a value of TRUE, otherwise it
			returns FALSE.

  PARAMETERS:

  Parameter	  IN/OUT   Datatype	Description
  --------------- -------- ------------ --------------------------------------
  x_line_loc_id	   IN 	   NUMBER	Line location ID for vendor receipts.
  x_receipt_date   IN 	   DATE		Receipt date.

  RETURN VALUE: 	TRUE if transaction date is within receipt date
			tolerance, FALSE otherwise

  DESIGN REFERENCES:	RCVRCERC.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION val_receipt_date_tolerance(x_line_loc_id   IN NUMBER,
				    x_receipt_date  IN DATE) RETURN BOOLEAN;


END RCV_DATES_S;

 

/
