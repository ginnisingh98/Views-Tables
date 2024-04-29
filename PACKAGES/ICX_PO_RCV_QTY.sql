--------------------------------------------------------
--  DDL for Package ICX_PO_RCV_QTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PO_RCV_QTY" AUTHID CURRENT_USER as
/* $Header: ICXRCQTS.pls 115.1 99/07/17 03:21:50 porting ship $ */

FUNCTION  get_net_qty (x_parent_trx_id		IN NUMBER,
	               x_primary_qty 	IN NUMBER
			      ) RETURN NUMBER;

 pragma restrict_references (get_net_qty,WNDS,RNPS,WNPS);

END icx_po_rcv_qty;

 

/
