--------------------------------------------------------
--  DDL for Package RCV_OE_RMA_RECEIPTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_OE_RMA_RECEIPTS_SV" AUTHID CURRENT_USER AS
/* $Header: RCVRMARS.pls 120.0 2005/06/01 17:23:45 appldev noship $*/


/*===========================================================================

  FUNCTION NAME:	rma_val_receipt_date_tolerance()

  DESCRIPTION:

		Checks that the receipt date is within the receipt date
		tolerance.

  PARAMETERS:

  Parameter	  IN/OUT   Datatype	Description
  --------------- -------- ------------ --------------------------------------

  x_oe_order_header_id IN  NUMBER	RMA header id

  x_oe_order_line_id   IN  NUMBER	RMA line id

  x_receipt_date       IN  DATE		Receipt Date to be validated.

  RETURN VALUE:	    TRUE if receipt date is within tolerance
		    FALSE otherwise.

  DESIGN REFERENCES:	RCVRCERC.dd x
			RCVTXECO.dd _/
			RCVTXERE.dd x
			RCVTXERT.dd x

  CHANGE HISTORY:
===========================================================================*/



FUNCTION rma_val_receipt_date_tolerance (x_oe_order_header_id   IN NUMBER,
				     	 x_oe_order_line_id     IN NUMBER,
				     	 x_receipt_date         IN DATE)
RETURN BOOLEAN;

/* <R12 MOAC START>
**   Changed the signature of the following procedure rma_get_org_info.
**   The procedure now has only 2 parameters.
*/

PROCEDURE rma_get_org_info (x_new_org_id        OUT NOCOPY NUMBER,
			    X_oe_order_line_id  IN NUMBER
			   );

/* <R12 MOAC END> */

END RCV_OE_RMA_RECEIPTS_SV;

 

/
