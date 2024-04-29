--------------------------------------------------------
--  DDL for Package RCV_INVOICE_MATCHING_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INVOICE_MATCHING_SV" AUTHID CURRENT_USER AS
/* $Header: RCVITRMS.pls 115.3 2003/07/24 22:25:31 sumboh ship $*/

/*===========================================================================
  PACKAGE NAME:		RCV_INVOICE_MATCHING_SV

  DESCRIPTION:

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:

  PROCEDURE NAMES:	get_quantities()
			get_delivered_quantity()
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME: get_quantities()

  DESCRIPTION:
	This procedure will accept a RECEIVE or MATCH transaction id and return
	different quantities in PO and transaction UOM.

  USAGE:

  PARAMETERS:	top_transaction_id	IN
			Transaction ID of the receive or match transaction
		ordered_po_qty		IN OUT NOCOPY
			Ordered quantity of the PO shipment in PO UOM
		received_po_qty		IN OUT NOCOPY
			Received/Matched quantity of the shipment in PO UOM
		corrected_po_qty	IN OUT NOCOPY
			Correction of the received quantity in PO UOM
		delivered_po_qty	IN OUT NOCOPY
			Delivered quantity of the shipment after adjustment in PO UOM
		rtv_po_qty		IN OUT NOCOPY
			Return-to-vendor quantity after adjustment in PO UOM
		billed_po_qty		IN OUT NOCOPY
			Billed (invoiced) quantity in PO UOM
		accepted_po_qty		IN OUT NOCOPY
			Inspection accepted quantity of the shipment after adjustment
			in PO UOM
		rejected_po_qty		IN OUT NOCOPY
			Inspection rejected quantity of the shipment after adjustment
			in PO UOM
		ordered_txn_qty		IN OUT NOCOPY
			Ordered quantity of the PO shipment in transaction UOM
		received_txn_qty	IN OUT NOCOPY
			Received/Matched quantity of the shipment in transaction UOM
		corrected_txn_qty	IN OUT NOCOPY
			Correction of the received quantity in transaction UOM
		delivered_txn_qty	IN OUT NOCOPY
			Delivered quantity of the shipment after adjustment in transaction UOM
		rtv_txn_qty		IN OUT NOCOPY
			Return-to-vendor quantity after adjustment in transaction UOM
		billed_txn_qty		IN OUT NOCOPY
			Billed (invoiced) quantity in transaction UOM
		accepted_txn_qty	IN OUT NOCOPY
			Inspection accepted quantity of the shipment after adjustment
			in transaction UOM
		rejected_txn_qty	IN OUT NOCOPY
			Inspection rejected quantity of the shipment after adjustment
			in transaction UOM


  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	14-Dec-98	David Chan	Created
===========================================================================*/
PROCEDURE get_quantities	(	top_transaction_id	IN	NUMBER,
					ordered_po_qty		IN OUT	NOCOPY NUMBER,
					cancelled_po_qty	IN OUT	NOCOPY NUMBER,
					received_po_qty		IN OUT	NOCOPY NUMBER,
					corrected_po_qty	IN OUT	NOCOPY NUMBER,
					delivered_po_qty	IN OUT	NOCOPY NUMBER,
					rtv_po_qty		    IN OUT	NOCOPY NUMBER,
					billed_po_qty		IN OUT	NOCOPY NUMBER,
					accepted_po_qty		IN OUT	NOCOPY NUMBER,
					rejected_po_qty		IN OUT	NOCOPY NUMBER,
					ordered_txn_qty		IN OUT	NOCOPY NUMBER,
					cancelled_txn_qty	IN OUT	NOCOPY NUMBER,
					received_txn_qty	IN OUT	NOCOPY NUMBER,
					corrected_txn_qty	IN OUT	NOCOPY NUMBER,
					delivered_txn_qty	IN OUT	NOCOPY NUMBER,
					rtv_txn_qty		IN OUT	NOCOPY NUMBER,
					billed_txn_qty		IN OUT	NOCOPY NUMBER,
					accepted_txn_qty	IN OUT	NOCOPY NUMBER,
					rejected_txn_qty	IN OUT	NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME: get_delivered_quantity()

  DESCRIPTION:
	This procedure will accept a RECEIVE or MATCH transaction id and po
	distribution id, then return the delivered quantity and other
	related quantities in PO and transaction UOM
  USAGE:

  PARAMETERS:	rcv_transaction_id	IN
			Transaction ID of the receive or match transaction
		p_distribution_id	IN
			PO distribution ID of the distribution
		ordered_po_qty		IN OUT NOCOPY
			Ordered quantity of the PO distribution in PO UOM
		delivered_po_qty	IN OUT NOCOPY
			Delivered quantity of the PO distribution and shipment
			in PO UOM
		returned_po_qty
			Return-to-receiving quantity after adjustment in
			PO UOM
		corrected_po_qty	IN OUT NOCOPY
			Correction of the delivered quantity PO UOM
		ordered_txn_qty		IN OUT NOCOPY
			Ordered quantity of the PO distribution in transaction UOM
		delivered_txn_qty	IN OUT NOCOPY
			Delivered quantity of the PO distribution and shipment
			in transaction UOM
		returned_txn_qty
			Return-to-receiving quantity after adjustment in
			transaction UOM
		corrected_txn_qty	IN OUT NOCOPY
			Correction of the delivered quantity in transaction UOM


  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	14-Dec-98	David Chan	Created
===========================================================================*/
PROCEDURE get_delivered_quantity(	rcv_transaction_id	IN	NUMBER,
					p_distribution_id	IN	NUMBER,
                    ordered_po_qty		IN OUT	NOCOPY NUMBER,
					cancelled_po_qty	IN OUT	NOCOPY NUMBER,
					delivered_po_qty	IN OUT	NOCOPY NUMBER,
					returned_po_qty		IN OUT	NOCOPY NUMBER,
					corrected_po_qty	IN OUT	NOCOPY NUMBER,
                    ordered_txn_qty		IN OUT	NOCOPY NUMBER,
					cancelled_txn_qty	IN OUT	NOCOPY NUMBER,
					delivered_txn_qty	IN OUT	NOCOPY NUMBER,
					returned_txn_qty	IN OUT	NOCOPY NUMBER,
					corrected_txn_qty	IN OUT	NOCOPY NUMBER);

PROCEDURE Get_ReceiveAmount
(   p_api_version            IN         NUMBER,
    p_init_msg_list          IN         VARCHAR2 := FND_API.G_FALSE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_receive_transaction_id IN         NUMBER,    -- RECEIVE Transaction id
    x_billed_amt             OUT NOCOPY NUMBER,    -- rcv_transactions.amount_billed
    x_received_amt           OUT NOCOPY NUMBER,    -- amount from rcv transactions table for the corresponding RECEIVE transaction
    x_delivered_amt          OUT NOCOPY NUMBER,    -- amount from rcv transactions table for the corresponding DELIVER transaction
    x_corrected_amt          OUT NOCOPY NUMBER     -- amount from rcv transactions table for the corresponding CORRECT transaction
);

PROCEDURE Get_DeliverAmount
(   p_api_version            IN         NUMBER,
    p_init_msg_list          IN         VARCHAR2 := FND_API.G_FALSE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_receive_transaction_id IN         NUMBER,        -- Transaction id of the root RECEIVE transaction
    p_po_distribution_id     IN         NUMBER,
    x_delivered_amt          OUT NOCOPY NUMBER,        -- amount from rcv transactions table for the child DELIVER transactions
    x_corrected_amt          OUT NOCOPY NUMBER         -- amount from rcv transactions table for the corresponding CORRECT transaction
);

END RCV_INVOICE_MATCHING_SV;

 

/
