--------------------------------------------------------
--  DDL for Package POS_PO_RCV_QTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PO_RCV_QTY" AUTHID CURRENT_USER as
/* $Header: POSRCQTS.pls 120.0.12010000.4 2010/06/16 11:18:06 ramkandu ship $ */

FUNCTION  get_net_qty (x_parent_trx_id		IN NUMBER,
	               x_primary_qty 	IN NUMBER
			      ) RETURN NUMBER;
FUNCTION get_receive_rcv( x_shipment_line_id in number) return number;
 pragma restrict_references (get_net_qty,WNDS,RNPS,WNPS);


/* Bug 1086123
 * We used to call the function get_net_quantity to get
 * quantity received. But this was incorrectly handled. So created
 * new function get_net_qty_rcv and called this from the view
 * POS_RCV_TRANSACTIONS_V.
*/
/* Bug 9648379
  modified the function to pass the transaction id of the received shipment transaction
  which can be used to get correct net received quantity for a particular distribution
*/
FUNCTION  get_net_qty_rcv (x_shipment_line_id		IN NUMBER,
	               x_primary_qty 	IN NUMBER,
                 x_transaction_id IN NUMBER
			      ) RETURN NUMBER;

 pragma restrict_references (get_net_qty_rcv,WNDS,RNPS,WNPS);


FUNCTION  get_net_received_qty (p_txn_id IN NUMBER)
return number;

/* Bug 9648379
  added this function to pass the transaction id of the received shipment transaction
  which can be used to get correct net received amount for a particular distribution
*/
FUNCTION  get_net_rcv_amt(x_shipment_line_id		IN NUMBER,
		       x_primary_amt		IN NUMBER,
           x_transaction_id IN NUMBER
			      ) RETURN NUMBER;


/* Code changes for bug - 9502912 - Start
   Added this funtion to get the qty_received from po_line_locations_all table
   if the value in po_line_locations_archive_all is zero.
*/

FUNCTION  get_qty_rcv (line_loc_id IN NUMBER)
return number;


END pos_po_rcv_qty;


/
