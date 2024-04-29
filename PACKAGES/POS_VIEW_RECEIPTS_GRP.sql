--------------------------------------------------------
--  DDL for Package POS_VIEW_RECEIPTS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_VIEW_RECEIPTS_GRP" AUTHID CURRENT_USER AS
/* $Header: POSGRCPS.pls 120.4.12010000.2 2014/04/21 09:03:50 pneralla ship $*/


/* Logic in this procedure is same as RCV_INVOICE_MATCHING_SV.get_quantities.
since we can not directly use the RCV function as it references secured sysnonyms,
same logic is incorporated here. Also, we are interested only in Return and Rejcted
quantities
For bug:18276920 : added parameter to get accepted_qty also*/

PROCEDURE get_quantities    (
   top_transaction_id  IN  NUMBER,
   rtv_txn_qty     IN OUT  NOCOPY NUMBER,
   rejected_txn_qty    IN OUT  NOCOPY NUMBER,
   accepted_txn_qty IN OUT NOCOPY NUMBER) ;

/**
  * Function to find if there is an LPN or a Lot or Serial exists for the given shipment
  line id.  Logic is to check if WMS installed; if not return 0.  If WMS is installed, check
  if an LPN exist in the RCV_TRANSACTION table.
  * parameters:
  *     p_rcv_shipment_line_id  The shipment line id
  *  Returns   returns 1 if there is LPN or Lot or Serial exist;
                    Return 0 if none.
*/
Function IS_LpnLotSerial_Exist(p_rcv_shipment_line_id number) return number;

PROCEDURE get_po_info  (
	p_shipment_header_id IN NUMBER,
 	p_po_switch OUT NOCOPY VARCHAR2,
	p_po_number OUT NOCOPY VARCHAR2,
 	p_po_header_id OUT NOCOPY VARCHAR2,
 	p_release_id OUT NOCOPY VARCHAR2);


PROCEDURE get_invoice_info  (
	p_shipment_header_id IN NUMBER,
 	p_invoice_switch OUT NOCOPY VARCHAR2,
	p_invoice_number OUT NOCOPY VARCHAR2,
 	p_invoice_id OUT NOCOPY VARCHAR2);

PROCEDURE get_invoice_info_for_line  (
	p_shipment_line_id IN NUMBER,
 	p_invoice_switch OUT NOCOPY VARCHAR2,
	p_invoice_number OUT NOCOPY VARCHAR2,
 	p_invoice_id OUT NOCOPY VARCHAR2);

END POS_VIEW_RECEIPTS_GRP;


/
