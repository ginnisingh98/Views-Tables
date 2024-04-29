--------------------------------------------------------
--  DDL for Package POA_EDW_RCV_TXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_RCV_TXNS_PKG" AUTHID CURRENT_USER AS
/*$Header: poafrcvs.pls 120.1 2005/06/13 13:04:25 sriswami noship $*/
   VERSION                 CONSTANT CHAR(80) :=
     '$Header: poafrcvs.pls 120.1 2005/06/13 13:04:25 sriswami noship $';

 /* This function returns (total) net source_doc_quantity
    (i.e. with corrections) for all transactions with this
    transaction type and originated from this rcv_shipment_line.

    For the receipt to this shipment line, it will return total
    accepted, rejected, delivered, etc..., net source_doc_quantity
    to this receipt.
 */

    Function Qty_Net_Child_Txns (p_shipment_line_id in NUMBER,
			         p_transaction_type in VARCHAR2)
                                      return NUMBER;

  /*This function returns total corrections again this transaction */
    Function Qty_Corrected (p_transaction_id in NUMBER)
                                      return NUMBER;

  /* The function returns all child-txns (total) net_qty with
    (recursive) parent_transaction_id = p_parent_txn_id and with
    transaction_type = this p_transaction_type.
    net_qty = (sum) quantity + correct_quantity.

    <<<Source_Doc_Quantiy is used in all quantities.>>>
  */
    Function Qty_Net_Child_Txns_Recursive (
	         p_parent_txn_id    in NUMBER,
	         p_transaction_type in VARCHAR2)  return  NUMBER;

    PRAGMA RESTRICT_REFERENCES (Qty_Net_Child_Txns, WNDS, WNPS, RNPS);

    PRAGMA RESTRICT_REFERENCES (Qty_Corrected, WNDS, WNPS, RNPS);

    PRAGMA RESTRICT_REFERENCES (Qty_Net_Child_Txns_Recursive,
				WNDS, WNPS, RNPS);

  /*This function returns the date of last delivery against this
    rcv_shipment_line_id
   */
   Function Date_Last_Delivery (p_shipment_line_id in NUMBER)
                                                 return DATE;

    PRAGMA RESTRICT_REFERENCES (Date_Last_Delivery, WNDS, WNPS, RNPS);

END POA_EDW_RCV_TXNS_PKG;

 

/
