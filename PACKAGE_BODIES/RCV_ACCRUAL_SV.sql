--------------------------------------------------------
--  DDL for Package Body RCV_ACCRUAL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ACCRUAL_SV" AS
/* $Header: RCVACCRB.pls 120.1 2005/09/21 02:35:56 bigoyal noship $*/


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
   *    It is also used by the accounting events API to get received 	     *
   *    quantity while accounting for retroactive price adjustments.	     *
  \* ======================================================================= */

  FUNCTION get_received_quantity (p_transaction_id IN NUMBER,
                                  p_accrual_cutoff_date   IN DATE) RETURN NUMBER
  IS

     X_progress  	 VARCHAR2(3);

     v_ordered_po_qty 	 NUMBER;
     v_received_po_qty 	 NUMBER;
     v_corrected_po_qty  NUMBER;
     v_delivered_po_qty  NUMBER;
     v_rtv_po_qty        NUMBER;
     v_billed_po_qty     NUMBER;
     v_accepted_po_qty   NUMBER;
     v_rejected_po_qty   NUMBER;
     v_ordered_txn_qty   NUMBER;
     v_received_txn_qty  NUMBER;
     v_corrected_txn_qty NUMBER;
     v_delivered_txn_qty NUMBER;
     v_rtv_txn_qty       NUMBER;
     v_billed_txn_qty    NUMBER;
     v_accepted_txn_qty  NUMBER;
     v_rejected_txn_qty  NUMBER;
     l_debug             VARCHAR2(80);

  BEGIN

     X_progress := '001';

    l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

     get_quantities(p_transaction_id,
		    v_ordered_po_qty,
                    v_received_po_qty,
                    v_corrected_po_qty,
		    v_delivered_po_qty,
		    v_rtv_po_qty,
		    v_billed_po_qty,
		    v_accepted_po_qty,
		    v_rejected_po_qty,
		    v_ordered_txn_qty,
		    v_received_txn_qty,
		    v_corrected_txn_qty,
		    v_delivered_txn_qty,
		    v_rtv_txn_qty,
		    v_billed_txn_qty,
		    v_accepted_txn_qty,
		    v_rejected_txn_qty,
		    p_accrual_cutoff_date);

     X_progress := '002';

    if (l_debug = 'Y') then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Received Qty : '||TO_CHAR(v_received_po_qty));
        FND_FILE.PUT_LINE(FND_FILE.LOG,'RTV Qty : ' || to_char(v_rtv_po_qty));
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Corrected Qty : ' || to_char(v_corrected_po_qty));
    end if;
     RETURN(v_received_po_qty-v_rtv_po_qty+v_corrected_po_qty);

  EXCEPTION

     WHEN OTHERS THEN
        RAISE;

  END get_received_quantity;

  /* ======================================================================= *\
   * PROCEDURE NAME: get_delivered_quantity()				     *
   *									     *
   * DESCRIPTION:							     *
   *    This function will accept a DELIVER transaction id and      	     *
   *    return the quantity delivered in the PO's unit of measure. This is   *
   *    mainly a function wrapper that calls the get_quantities API.         *
   *                                                                         *
   * USAGE:                                                                  *
   *    This function is called from the accounting events API		     *
   *    while accounting for retroactive price changes.		             *
  \* ======================================================================= */

  FUNCTION get_delivered_quantity (p_transaction_id IN NUMBER,
                                  p_accrual_cutoff_date   IN DATE) RETURN NUMBER
  IS

     X_progress  	 VARCHAR2(3);

     v_ordered_po_qty 	 NUMBER;
     v_received_po_qty 	 NUMBER;
     v_corrected_po_qty  NUMBER;
     v_delivered_po_qty  NUMBER;
     v_rtv_po_qty        NUMBER;
     v_billed_po_qty     NUMBER;
     v_accepted_po_qty   NUMBER;
     v_rejected_po_qty   NUMBER;
     v_ordered_txn_qty   NUMBER;
     v_received_txn_qty  NUMBER;
     v_corrected_txn_qty NUMBER;
     v_delivered_txn_qty NUMBER;
     v_rtv_txn_qty       NUMBER;
     v_billed_txn_qty    NUMBER;
     v_accepted_txn_qty  NUMBER;
     v_rejected_txn_qty  NUMBER;
     l_debug             VARCHAR2(80);

  BEGIN

     X_progress := '001';

    l_debug := FND_PROFILE.VALUE('MRP_DEBUG');

     get_quantities(p_transaction_id,
		    v_ordered_po_qty,
                    v_received_po_qty,
                    v_corrected_po_qty,
		    v_delivered_po_qty,
		    v_rtv_po_qty,
		    v_billed_po_qty,
		    v_accepted_po_qty,
		    v_rejected_po_qty,
		    v_ordered_txn_qty,
		    v_received_txn_qty,
		    v_corrected_txn_qty,
		    v_delivered_txn_qty,
		    v_rtv_txn_qty,
		    v_billed_txn_qty,
		    v_accepted_txn_qty,
		    v_rejected_txn_qty,
		    p_accrual_cutoff_date);

     X_progress := '002';

    if (l_debug = 'Y') then
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Delivered Qty : '||TO_CHAR(v_delivered_po_qty));
    end if;
     RETURN(v_delivered_po_qty);

  EXCEPTION

     WHEN OTHERS THEN
        RAISE;
END get_delivered_quantity;



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

  PROCEDURE get_quantities(	top_transaction_id	IN              NUMBER,
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
                                p_accrual_cutoff_date   IN DATE)	IS

     X_progress            VARCHAR2(3);

     X_primary_uom         VARCHAR2(25);
     X_txn_uom             VARCHAR2(25);
     X_po_uom              VARCHAR2(25);
     X_pr_to_txn_rate      NUMBER := 1;
     X_pr_to_po_rate       NUMBER := 1;
     X_po_to_txn_rate      NUMBER := 1;
     X_item_id             NUMBER := 0;
     X_line_location_id    NUMBER := 0;
     X_received_quantity   NUMBER := 0;
     X_corrected_quantity  NUMBER := 0;
     X_delivered_quantity  NUMBER := 0;
     X_rtv_quantity        NUMBER := 0;
     X_accepted_quantity   NUMBER := 0;
     X_rejected_quantity   NUMBER := 0;

     v_primary_uom         VARCHAR2(25);
     v_po_uom              VARCHAR2(25);
     v_txn_uom             VARCHAR2(25);
     v_txn_id              NUMBER := 0;
     v_primary_quantity    NUMBER := 0;
     v_transaction_type    VARCHAR2(25);
     v_parent_id           NUMBER := 0;
     v_parent_type         VARCHAR2(25);
     v_shipment_line_id    NUMBER := 0;
     v_line_location_id    NUMBER := 0;
/* Bug 2033579 Added two variables to store grand parent type and id */
   grand_parent_type VARCHAR2(25);
   grand_parent_id       NUMBER := 0;



     /* This cursor recursively query up all the children of the
     ** top transaction (RECEIVE or MATCH)
     */

     /* Moved trunc() off the database columns */

     CURSOR c_txn_history (c_transaction_id NUMBER) IS
       SELECT
         transaction_id,
         primary_quantity,
         primary_unit_of_measure,
         unit_of_measure,
         source_doc_unit_of_measure,
         transaction_type,
         shipment_line_id,
         po_line_location_id,
         parent_transaction_id
       FROM
         rcv_transactions
       WHERE transaction_date <= trunc(p_accrual_cutoff_date)+1
       START WITH transaction_id = c_transaction_id
       CONNECT BY parent_transaction_id = PRIOR transaction_id;

  BEGIN

     OPEN c_txn_history(top_transaction_id);

     X_progress := '001';

     LOOP
        FETCH c_txn_history INTO v_txn_id,
                                 v_primary_quantity,
                                 v_primary_uom,
                                 v_txn_uom,
                                 v_po_uom,
                                 v_transaction_type,
                                 v_shipment_line_id,
                                 v_line_location_id,
                                 v_parent_id;

        EXIT WHEN c_txn_history%NOTFOUND;

        X_progress := '002';

	/* This was done for the receive transaction in the old code. Moving it
	   out and getting the UOM information based on the top transaction_id,
	   so it will work when called for a Receive and a Deliver transaction. */
	IF(v_txn_id = top_transaction_id) THEN
           /* Find out the item_id for UOM conversion */

           SELECT
             item_id
           INTO
             X_item_id
           FROM
             rcv_shipment_lines
           WHERE
             shipment_line_id = v_shipment_line_id;

           X_line_location_id := v_line_location_id;
           X_primary_uom := v_primary_uom;
           X_txn_uom := v_txn_uom;
           X_po_uom := v_po_uom;

	END IF;

        IF v_transaction_type = 'RECEIVE' OR v_transaction_type = 'MATCH' THEN

           X_received_quantity := v_primary_quantity;

        ELSIF v_transaction_type = 'RETURN TO VENDOR' THEN

/*Bug2033579 When Performing 'Return to vendor' on Accept or Reject Transaction
  accepted quantity and Rejected quantity are not calculated correctly
*/

         SELECT
           transaction_type
         INTO
           v_parent_type
         FROM
           rcv_transactions
         WHERE
           transaction_id = v_parent_id;

        if v_parent_type = 'ACCEPT' THEN
              X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
        end if;

        if v_parent_type = 'REJECT' THEN
              X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
        end if;

           X_rtv_quantity := X_rtv_quantity + v_primary_quantity;

        ELSIF v_transaction_type = 'DELIVER' THEN

           X_delivered_quantity := X_delivered_quantity + v_primary_quantity;

        ELSIF v_transaction_type = 'ACCEPT' THEN
/*Bug 2033579 Accept quantity is not determined correctly when received goods
  are inspected more than once by pressing Inspection button and quantity is
  accepted.
*/
         SELECT
           transaction_type
         INTO
           v_parent_type
         FROM
           rcv_transactions
         WHERE
           transaction_id = v_parent_id;

        if v_parent_type <> 'ACCEPT'  THEN
          X_accepted_quantity := X_accepted_quantity + v_primary_quantity;
        end if;

        if v_parent_type = 'REJECT' THEN
          X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
        end if;

        ELSIF v_transaction_type = 'REJECT' THEN
/*Bug 2033579 Reject quantity is not determined correctly when received goods
  are inspected more than once by pressing Inspection button and quantity is
  Rejected.
*/
         SELECT
           transaction_type
         INTO
           v_parent_type
         FROM
           rcv_transactions
         WHERE
           transaction_id = v_parent_id;

        if v_parent_type <> 'REJECT'  then
          X_rejected_quantity := X_rejected_quantity + v_primary_quantity;
        end if;
        if v_parent_type = 'ACCEPT' then
           X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
        end if;

        ELSIF v_transaction_type = 'RETURN TO RECEIVING' THEN

           X_delivered_quantity := X_delivered_quantity - v_primary_quantity;

        ELSIF v_transaction_type = 'CORRECT' THEN

           /* The correction function is based on parent transaction type */

           SELECT
             transaction_type,parent_transaction_id
           INTO
             v_parent_type,grand_parent_id
           FROM
             rcv_transactions
           WHERE
             transaction_id = v_parent_id;

/*Bug 2272666 Added the no data found exception for the select statement itself
  Earlier the no data found exception was handled for the entire function which
  is removed because for this sql case it is not getting excuted sometimes.
  If correction is done just after doing a receipt the grand parent id will be
  -1 in that case the sql below won't fetch any records.
*/
       BEGIN

         SELECT
           transaction_type
         INTO
           grand_parent_type
         FROM
           rcv_transactions
         WHERE
           transaction_id = grand_parent_id;
       EXCEPTION

         WHEN NO_DATA_FOUND THEN
         NULL;

       END;

           IF v_parent_type = 'RECEIVE' OR v_parent_type = 'MATCH' THEN

              X_corrected_quantity := X_corrected_quantity +
                                      v_primary_quantity;

           ELSIF v_parent_type = 'RETURN TO VENDOR' THEN
/*Bug 2033579 When performing a correction on Return to Vendor and if its grand
  parent is accept or Reject Transaction then the accepted or rejected quantity
  will be adjusted accordingly.
*/

          if grand_parent_type = 'ACCEPT' THEN
            X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
          end if;

          if grand_parent_type = 'REJECT' THEN
            X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
          end if;

              X_rtv_quantity := X_rtv_quantity + v_primary_quantity;

           ELSIF v_parent_type = 'DELIVER' THEN

              X_delivered_quantity := X_delivered_quantity +
                                      v_primary_quantity;

           ELSIF v_parent_type = 'ACCEPT' THEN
/*Bug 2033579 When performing a correction on Accept transaction and if its
  grand parent is Reject transaction then the Rejected quantity will be adjusted*/

             if grand_parent_type = 'REJECT' THEN
                X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
             end if;

              X_accepted_quantity := X_accepted_quantity + v_primary_quantity;

           ELSIF v_parent_type = 'REJECT' THEN
/*Bug 2033579 When performing a correction on Reject Transaction and if its
  grand parent is Accept transaction then the accepted quantity will be
  adjusted.
*/
             if grand_parent_type = 'ACCEPT' THEN
               X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
             end if;

              X_rejected_quantity := X_rejected_quantity + v_primary_quantity;

           ELSIF v_parent_type = 'RETURN TO RECEIVING' THEN

              X_delivered_quantity := X_delivered_quantity -
                                      v_primary_quantity;

           END IF;

        END IF;

     END LOOP;

     CLOSE c_txn_history;

     X_progress := '003';

     /* Get the orderd, billed quantity from PO */

     IF X_line_location_id IS NOT NULL THEN
        SELECT
          ps.quantity,
          rt.quantity_billed	-- This quantity is in transaction UOM
        INTO
          ordered_po_qty,
          billed_txn_qty
        FROM
          po_line_locations ps,
          rcv_transactions  rt
        WHERE
          rt.transaction_id = top_transaction_id and
          rt.po_line_location_id = ps.line_location_id;
     ELSE
        ordered_po_qty := 0;
        billed_po_qty := 0;
     END IF;

     X_progress := '004';


     /* Get UOM conversion rates using INV apis */

     X_pr_to_po_rate := inv_convert.inv_um_convert(X_item_id, 10,
                                                   NULL, NULL, NULL,
                                                   X_primary_uom, X_po_uom);

     X_pr_to_txn_rate := inv_convert.inv_um_convert(X_item_id, 10,
                                                   NULL, NULL, NULL,
                                                   X_primary_uom, X_txn_uom);

     X_po_to_txn_rate := inv_convert.inv_um_convert(X_item_id, 10,
                                                   NULL, NULL, NULL,
                                                   X_po_uom, X_txn_uom);

     X_progress := '005';


     /* Calculate the quantity with uom info */

     received_po_qty := X_pr_to_po_rate * X_received_quantity;
     corrected_po_qty := X_pr_to_po_rate * X_corrected_quantity;
     delivered_po_qty := X_pr_to_po_rate * X_delivered_quantity;
     rtv_po_qty := X_pr_to_po_rate * X_rtv_quantity;
     accepted_po_qty := X_pr_to_po_rate * X_accepted_quantity;
     rejected_po_qty := X_pr_to_po_rate * X_rejected_quantity;
     billed_po_qty := billed_po_qty / X_po_to_txn_rate; -- txn to po rate is
							-- inverse of
							-- X_po_to_txn_rate

     ordered_txn_qty := X_po_to_txn_rate * ordered_po_qty;
     received_txn_qty := X_pr_to_txn_rate * X_received_quantity;
     corrected_txn_qty := X_pr_to_txn_rate * X_corrected_quantity;
     delivered_txn_qty := X_pr_to_txn_rate * X_delivered_quantity;
     rtv_txn_qty := X_pr_to_txn_rate * X_rtv_quantity;
     accepted_txn_qty := X_pr_to_txn_rate * X_accepted_quantity;
     rejected_txn_qty := X_pr_to_txn_rate * X_rejected_quantity;

     X_progress := '006';

  EXCEPTION

     WHEN OTHERS THEN
        RAISE;

  END get_quantities;


END RCV_ACCRUAL_SV;

/
