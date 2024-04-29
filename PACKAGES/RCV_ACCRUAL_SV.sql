--------------------------------------------------------
--  DDL for Package RCV_ACCRUAL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ACCRUAL_SV" AUTHID CURRENT_USER AS
/* $Header: RCVACCRS.pls 120.1 2005/09/21 02:47:35 bigoyal noship $*/


  /* ======================================================================= *\
   * PROCEDURE NAME: get_received_quantity()				     *
   *									     *
   * DESCRIPTION:							     *
   *    This function will accept a RECEIVE or MATCH transaction id and      *
   *    return the quantity received in the PO's unit of measure.  This is   *
   *    mainly a function wrapper that calls the get_quantities API.         *
   *                                                                         *
   * USAGE:                                                                  *
   *    This function is called from the period end accruals concurrent      *
   *    program when the match option is set to match to receipt.            *
  \* ======================================================================= */

  FUNCTION get_received_quantity( p_transaction_id 	  IN NUMBER,
                                  p_accrual_cutoff_date   IN DATE) RETURN NUMBER;

--  PRAGMA RESTRICT_REFERENCES(get_received_quantity, WNDS);

  /* ======================================================================= *\
   * PROCEDURE NAME: get_delivered_quantity()                                *
   *                                                                         *
   * DESCRIPTION:                                                            *
   *    This function will accept a DELIVER transaction id and               *
   *    return the quantity delivered in the PO's unit of measure. This is   *
   *    mainly a function wrapper that calls the get_quantities API.         *
   *                                                                         *
   * USAGE:                                                                  *
   *    This function is called from the accounting events API               *
   *    while accounting for retroactive price changes.                      *
  \* ======================================================================= */

  FUNCTION get_delivered_quantity (p_transaction_id 	   IN NUMBER,
                                   p_accrual_cutoff_date   IN DATE) RETURN NUMBER;



  /* ======================================================================= *\
   * PROCEDURE NAME: get_quantities()    				     *
   *									     *
   * DESCRIPTION:							     *
   *    Given a transaction_id, this procedure will return the following     *
   *    transaction quantities:                                              *
   *       Ordered                                                           *
   *       Received                                                          *
   *       Corrected                                                         *
   *       Delivered                                                         *
   *       Returned To Vendor                                                *
   *       Billed                                                            *
   *       Accepted                                                          *
   *       Rejected                                                          *
   *    The quantities are returned in both the PO and Transaction's unit    *
   *    of measure.  For period end accruals, we are only concerned with     *
   *    the received transaction quantity in the PO's UOM.                   *
   *    This procedure contains the same logic as in the                     *
   *    RCV_INVOICE_MATCHING_SV package.  However, we are using inventory's  *
   *    UOM conversion routine here so that we do not violate the            *
   *    associated WNDS pragma restriction associated with this procedure    *
   *                                                                         *
   * USAGE:                                                                  *
   *    This function is called from the period end accruals concurrent      *
   *    program when the match option is set to match to receipt.            *
  \* ======================================================================= */

  PROCEDURE get_quantities (	top_transaction_id	IN              NUMBER,
				ordered_po_qty		IN OUT  NOCOPY  NUMBER,
				received_po_qty		IN OUT	NOCOPY  NUMBER,
				corrected_po_qty	IN OUT	NOCOPY  NUMBER,
				delivered_po_qty	IN OUT	NOCOPY  NUMBER,
				rtv_po_qty		IN OUT	NOCOPY  NUMBER,
				billed_po_qty		IN OUT	NOCOPY  NUMBER,
				accepted_po_qty		IN OUT	NOCOPY  NUMBER,
				rejected_po_qty		IN OUT	NOCOPY  NUMBER,
				ordered_txn_qty		IN OUT  NOCOPY  NUMBER,
				received_txn_qty	IN OUT	NOCOPY  NUMBER,
				corrected_txn_qty	IN OUT	NOCOPY  NUMBER,
				delivered_txn_qty	IN OUT	NOCOPY  NUMBER,
				rtv_txn_qty		IN OUT	NOCOPY  NUMBER,
				billed_txn_qty		IN OUT	NOCOPY  NUMBER,
				accepted_txn_qty	IN OUT	NOCOPY  NUMBER,
				rejected_txn_qty	IN OUT	NOCOPY  NUMBER,
                                p_accrual_cutoff_date   IN DATE);

--  PRAGMA RESTRICT_REFERENCES(get_quantities, WNDS);

END RCV_ACCRUAL_SV;

 

/
