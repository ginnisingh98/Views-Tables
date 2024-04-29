--------------------------------------------------------
--  DDL for Package Body POS_PO_RCV_QTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PO_RCV_QTY" as
/* $Header: POSRCQTB.pls 120.0.12010000.5 2012/10/16 07:05:18 ppotnuru ship $*/

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

FUNCTION get_receive_rcv( x_shipment_line_id in number) return number
is
l_quantity number;
begin
	select sum(quantity) into l_quantity from rcv_transactions where
	shipment_line_id = x_shipment_line_id
	and transaction_type = 'RECEIVE';

	return l_quantity;

end get_receive_rcv;

/* Bug 1086123
 * We used to call the function get_net_quantity to get
 * the quantity received in which we the primary_quantity from
 * rcv_transactions for the Correct transaction type
 * and x_net_qty := x_net_qty - x_correct_qty;
 * This is wrong since it should ve x_net_qty + x_correct_qty.
 * Also now we have to consider RETURN transactions.
 * So created this new function get_net_qty_rcv which will
 * be called from the view POS_RCV_TRANSACTIONS_V.
 */
/* Bug 9648379
  modified the function to pass the transaction id of the received shipment transaction
  which can be used to get correct net received quantity for a particular distribution
*/
FUNCTION  get_net_qty_rcv (x_shipment_line_id		IN NUMBER,
		       x_primary_qty		IN NUMBER,
           x_transaction_id IN NUMBER
			      ) RETURN NUMBER
IS

cursor c1(x_shipment_line_id NUMBER, x_parent_id NUMBER) IS
SELECT rt2.quantity, rt2.transaction_type, rt.transaction_type
FROM rcv_transactions rt2, rcv_transactions rt
WHERE rt2.shipment_line_id = x_shipment_line_id
AND
(
   (rt2.parent_transaction_id = x_parent_id AND rt2.transaction_type IN ('CORRECT', 'RETURN TO VENDOR') AND rt.transaction_id = x_parent_id)  OR
   (  rt.transaction_id=rt2.parent_transaction_id    and   rt.transaction_type = 'RETURN TO VENDOR' )
);

x_correct_qty   number;
x_net_qty       number;
x_trans_type    varchar2(25);
x_parent_type   varchar2(25);
x_parent_id     NUMBER;

BEGIN
        x_net_qty := x_primary_qty;
        x_parent_id := x_transaction_id;

        open c1(x_shipment_line_id, x_parent_id);
        loop
                fetch c1 into x_correct_qty, x_trans_type, x_parent_type;
                exit when c1%NOTFOUND;

                if (x_trans_type = 'CORRECT' and x_parent_type='RECEIVE') then
                        x_net_qty := x_net_qty + x_correct_qty;
                elsif(x_trans_type = 'CORRECT' AND x_parent_type='RETURN TO VENDOR') then
                        x_net_qty := x_net_qty - x_correct_qty;
                end if;
                if (x_trans_type = 'RETURN TO VENDOR') then
                        x_net_qty := x_net_qty - x_correct_qty;
                end if;
        end loop;
        close c1;
        return (x_net_qty);

END get_net_qty_rcv;

/* Bug 9648379
  added this function to pass the transaction id of the received shipment transaction
  which can be used to get correct net received amount for a particular distribution
*/
FUNCTION get_net_rcv_amt(x_shipment_line_id		IN NUMBER,
		       x_primary_amt		IN NUMBER,
           x_transaction_id IN NUMBER
			      ) RETURN NUMBER

IS

cursor c1(x_shipment_line_id NUMBER, x_parent_id NUMBER) is
SELECT rt2.amount, rt2.transaction_type, rt.transaction_type
FROM rcv_transactions rt2, rcv_transactions rt
WHERE rt2.shipment_line_id = x_shipment_line_id
AND rt2.parent_transaction_id = x_parent_id
AND rt2.transaction_type IN ('CORRECT', 'RETURN TO VENDOR')
AND rt.transaction_id = x_parent_id;

x_correct_amt   number;
x_net_amt      number;
x_trans_type    varchar2(25);
x_parent_type   varchar2(25);
x_parent_id     NUMBER;

BEGIN
        x_net_amt := x_primary_amt;
        x_parent_id := x_transaction_id;

        open c1(x_shipment_line_id, x_parent_id);
        loop
                fetch c1 into x_correct_amt, x_trans_type, x_parent_type;
                exit when c1%NOTFOUND;

                if (x_trans_type = 'CORRECT' and x_parent_type='RECEIVE') then
                        x_net_amt := x_net_amt + x_correct_amt;
                elsif(x_trans_type = 'CORRECT' AND x_parent_type='RETURN TO VENDOR') then
                        x_net_amt := x_net_amt - x_correct_amt;
                end if;
                if (x_trans_type = 'RETURN TO VENDOR') then
                        x_net_amt := x_net_amt - x_correct_amt;
                end if;
        end loop;
        close c1;
        return (x_net_amt);

END get_net_rcv_amt;

FUNCTION  get_net_received_qty (p_txn_id IN NUMBER)
return number IS

   X_received_quantity  NUMBER := 0;

   l_txn_id              NUMBER := 0;
   l_quantity            NUMBER := 0;
   l_transaction_type    VARCHAR2(25) := '';
   l_parent_id           NUMBER := 0;
   l_parent_type         VARCHAR2(25) := '';

   CURSOR l_txn_history_csr (c_transaction_id NUMBER) IS
     SELECT transaction_id,
            quantity,
            transaction_type,
            parent_transaction_id
     FROM   rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

  BEGIN

       OPEN l_txn_history_csr(p_txn_id);
       LOOP
         FETCH l_txn_history_csr INTO l_txn_id,
                                  l_quantity,
                                  l_transaction_type,
                                  l_parent_id;
         EXIT WHEN l_txn_history_csr%NOTFOUND;

         IF l_transaction_type = 'RECEIVE' THEN
           X_received_quantity := X_received_quantity + l_quantity;

         ELSIF l_transaction_type = 'RETURN TO VENDOR' THEN
           X_received_quantity := X_received_quantity - l_quantity;

         ELSIF l_transaction_type = 'CORRECT' THEN
           /* The correction function is based on parent transaction type */

           SELECT transaction_type
           INTO   l_parent_type
           FROM   rcv_transactions
           WHERE  transaction_id = l_parent_id;

           IF l_parent_type = 'RECEIVE' THEN
             X_received_quantity := X_received_quantity + l_quantity;

           ELSIF l_parent_type = 'RETURN TO VENDOR' THEN
             X_received_quantity := X_received_quantity - l_quantity;

           END IF;

         END IF;

       END LOOP;

       CLOSE l_txn_history_csr;

       return X_received_quantity;

  EXCEPTION
    WHEN others THEN
      IF l_txn_history_csr%isopen THEN
         close l_txn_history_csr;
      end if;
      raise;
end get_net_received_qty;


/* Code changes for bug - 9502912 - Start
   Added this funtion to get the qty_received from po_line_locations_all table
   if the value in po_line_locations_archive_all is zero.
*/

FUNCTION Get_qty_rcv (line_loc_id IN NUMBER)
RETURN NUMBER
IS
  qty_rec NUMBER;
BEGIN
  SELECT quantity_received
  INTO   qty_rec
  FROM   po_line_locations_all
  WHERE  line_location_id = line_loc_id;

  RETURN qty_rec;
END get_qty_rcv;


end pos_po_rcv_qty;

/
