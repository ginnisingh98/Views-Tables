--------------------------------------------------------
--  DDL for Package Body ICX_PO_RCV_QTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PO_RCV_QTY" as
/* $Header: ICXRCQTB.pls 115.1 99/07/17 03:21:47 porting ship $*/

/*===========================================================================

  FUNCTION NAME:	get_net_qty

===========================================================================*/
FUNCTION  get_net_qty (x_parent_trx_id		IN NUMBER,
		       x_primary_qty		IN NUMBER
			      ) RETURN NUMBER is


x_correct_qty	number;
x_net_qty 	number;


BEGIN

     SELECT nvl(sum(rt.primary_quantity), 0)
     INTO   x_correct_qty
     FROM   rcv_transactions rt
     WHERE  rt.parent_transaction_id = x_parent_trx_id
     AND    rt.transaction_type =  'CORRECT';

  x_net_qty := x_primary_qty - x_correct_qty;

  return (x_net_qty);

END get_net_qty;

end icx_po_rcv_qty;

/
