--------------------------------------------------------
--  DDL for Package Body POA_EDW_RCV_TXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_EDW_RCV_TXNS_PKG" AS
/*$Header: poafrcvb.pls 120.1 2005/06/13 13:01:37 sriswami noship $*/
   VERSION                 CONSTANT CHAR(80) :=
     '$Header: poafrcvb.pls 120.1 2005/06/13 13:01:37 sriswami noship $';

 /* This function returns (total) net source_doc_quantity
    (i.e. with corrections) for all transactions with this
    transaction type and originated from this rcv_shipment_line.

    For the receipt to this shipment line, it will return total
    accepted, rejected, delivered, etc..., net source_doc_quantity
    to this receipt.
 */
 Function Qty_Net_Child_Txns (p_shipment_line_id in NUMBER,
			      p_transaction_type in VARCHAR2)
                                  return NUMBER IS

     l_qty      NUMBER := 0;
     l_sum      NUMBER;

 BEGIN
    if p_shipment_line_id is NULL OR
       p_transaction_type is NULL then
         return (0);
    end if;

  /*First, sum all quantities of this txn_type before correction */
    select sum(nvl(source_doc_quantity, 0)) into l_sum
      from rcv_transactions
     where shipment_line_id = p_shipment_line_id
       and transaction_type = p_transaction_type;

    l_qty := l_qty + nvl(l_sum, 0);

  /*Then, take corrections into account */
    select sum(nvl(rcv1.source_doc_quantity, 0)) into l_sum
      from rcv_transactions rcv1
     where rcv1.parent_transaction_id in
               (select transaction_id
                  from rcv_transactions rcv2
                 where rcv2.shipment_line_id = p_shipment_line_id
  		   and rcv2.transaction_type = p_transaction_type)
       and rcv1.transaction_type = 'CORRECT';

    l_qty := l_qty + nvl(l_sum, 0);

    return (l_qty);

  EXCEPTION
     when others then
	return (0);
  END Qty_Net_Child_Txns;


  /*This function returns total corrections again this transaction */

  Function Qty_Corrected (p_transaction_id in NUMBER)
                                       return NUMBER IS

    l_qty     NUMBER := 0;
    l_sum     NUMBER;

  BEGIN
    if p_transaction_id is NULL then
      return (0);
    end if;

    select sum(nvl(source_doc_quantity, 0)) into l_sum
      from rcv_transactions
     where parent_transaction_id = p_transaction_id
       and transaction_type = 'CORRECT';

    l_qty := l_qty + nvl(l_sum, 0);

    return (l_qty);

  EXCEPTION
     when others then
	return (0);
  END Qty_Corrected;


 /* The function returns all child-txns (total) net_qty with
    (recursive) parent_transaction_id = p_parent_txn_id and with
    transaction_type = this p_transaction_type.
    net_qty = (sum) quantity + correct_quantity.

    <<<Source_Doc_Quantiy is used in all quantities.>>>
  */
  Function Qty_Net_Child_Txns_Recursive (
	          p_parent_txn_id    in NUMBER,
		  p_transaction_type in VARCHAR2) return  NUMBER IS

     l_qty          NUMBER := 0;
     l_txn_id       NUMBER;
     l_qty_cor_sum  NUMBER;

     cursor txn_cur (p_pid in NUMBER) IS
	select transaction_id, nvl(source_doc_quantity, 0) s_qty,
	       transaction_type
	  from rcv_transactions
	  where parent_transaction_id = p_pid;

  BEGIN
     if p_parent_txn_id    is NULL OR
        p_transaction_type is NULL then
        return (0);
     end if;

     for rec_txn in txn_cur(p_parent_txn_id) loop
	/* consider all children txns */
	l_txn_id := rec_txn.transaction_id;

	if rec_txn.transaction_type = p_transaction_type then
	   /* this matches our type, add to qty */
	   l_qty := l_qty + rec_txn.s_qty;

	  if p_transaction_type <> 'CORRECT' then
	      /* take account for corrections */
    	    select sum(nvl(source_doc_quantity, 0)) into l_qty_cor_sum
	    from rcv_transactions
	    where parent_transaction_id = l_txn_id
	      and transaction_type = 'CORRECT';

  	    l_qty := l_qty + nvl(l_qty_cor_sum, 0);
          end if;
	end if;

	/* consider recursively for this child */
        l_qty := l_qty + Qty_Net_Child_Txns (l_txn_id,
	  	 		             p_transaction_type);
     end loop;

     return (l_qty);

  EXCEPTION
     when others then
	if txn_cur%ISOPEN then
	   close txn_cur;
	end if;
	return (0);
  END Qty_Net_Child_Txns_Recursive;


  /*This function returns the date of last delivery against this
    rcv_shipment_line_id. If no delivery, returns NULL.
   */
   Function Date_Last_Delivery (p_shipment_line_id in NUMBER)
                                                 return DATE IS
    l_date  DATE := NULL;

   BEGIN

    select max(transaction_date) into l_date
      from rcv_transactions
     where shipment_line_id = p_shipment_line_id
       and transaction_type = 'DELIVER';

    return l_date;

   EXCEPTION
     when others then
	return NULL;
   END Date_Last_Delivery;

END POA_EDW_RCV_TXNS_PKG;

/
