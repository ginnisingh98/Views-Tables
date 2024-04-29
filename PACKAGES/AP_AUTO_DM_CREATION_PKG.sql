--------------------------------------------------------
--  DDL for Package AP_AUTO_DM_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AUTO_DM_CREATION_PKG" AUTHID CURRENT_USER AS
/* $Header: apcrtdms.pls 120.1 2003/06/13 19:41:49 isartawi noship $ */


/*-------------------------------------------------------------------------
p_rcv_txn_id : The transaction_id for which the RTS is issues (should always
	       be the id of the RECEIVE transaction)
p_rts_txn_id : The transaction id of the RTS itself.(i.e. the RETURN
	       transaction)
p_po_dist_id : If the Return is done against a delivery and the
	       po_distribution_id is known. If this is null, the quantity
	       will be prorated across the po distributions.
p_quantity   : The quantity returned. Please note that the quantity should be
	       in the same UOM as the Receive Transaction, because we are
	       matching against that transaction. The quantity should be
	       negative.
p_qty_uom    : The UOM the quantity is in.
p_unit_price : The price at which the goods are returned. This price will be
	       the same as the PO price but should be passed in terms of
	       x_qty_uom. The quantity and unit_price are used to get the
	       amount and these 2 should correspondto the same UOM. The unit
	       price should be positive.
p_user_id    : AOL User Id from the Form
p_login_id   : AOL Login Id from the form
p_calling_seq: The name of the module calling this function. Used for exception
	       handling

This procedure returns a Boolean value of TRUE when it completes sucessfully
and will return a value of FALSE when either a known exception or an unhandled
exception occurs. The Oracle error is stored on the message stack when an
unhandled exception occures. a meaningful error is stored when a known
exception occurs.
--------------------------------------------------------------------------*/

Function  Create_DM (
		p_rcv_txn_id		IN	NUMBER,
		p_rts_txn_id		IN	NUMBER,
		p_po_dist_id		IN	NUMBER,
		p_quantity		IN	NUMBER,
		p_qty_uom		IN	VARCHAR2,
		p_unit_price		IN	NUMBER,
		p_user_id		IN 	NUMBER,
		p_login_id		IN	NUMBER,
		p_calling_sequence	IN	VARCHAR2)
RETURN BOOLEAN;

END AP_AUTO_DM_CREATION_PKG;


 

/
