--------------------------------------------------------
--  DDL for Package Body RCV_INVOICE_MATCHING_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INVOICE_MATCHING_SV" AS
/* $Header: RCVITRMB.pls 120.1.12010000.3 2011/10/25 19:20:04 vthevark ship $*/

/*======================  RCV_INVOICE_MATCHING_SV   ===================*/

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'RCV_INVOICE_MATCHING_SV';

PROCEDURE get_quantities	(	top_transaction_id	IN	NUMBER,
					ordered_po_qty		IN OUT NOCOPY  NUMBER,
					cancelled_po_qty	IN OUT	NOCOPY NUMBER,
					received_po_qty		IN OUT	NOCOPY NUMBER,
					corrected_po_qty	IN OUT	NOCOPY NUMBER,
					delivered_po_qty	IN OUT	NOCOPY NUMBER,
					rtv_po_qty		IN OUT	NOCOPY NUMBER,
					billed_po_qty		IN OUT	NOCOPY NUMBER,
					accepted_po_qty		IN OUT	NOCOPY NUMBER,
					rejected_po_qty		IN OUT	NOCOPY NUMBER,
					ordered_txn_qty		IN OUT NOCOPY  NUMBER,
					cancelled_txn_qty	IN OUT	NOCOPY NUMBER,
					received_txn_qty	IN OUT	NOCOPY NUMBER,
					corrected_txn_qty	IN OUT	NOCOPY NUMBER,
					delivered_txn_qty	IN OUT	NOCOPY NUMBER,
					rtv_txn_qty		IN OUT	NOCOPY NUMBER,
					billed_txn_qty		IN OUT	NOCOPY NUMBER,
					accepted_txn_qty	IN OUT	NOCOPY NUMBER,
					rejected_txn_qty	IN OUT	NOCOPY NUMBER)	IS

   X_progress            VARCHAR2(3)  := '000';

   X_primary_uom         VARCHAR2(25) := '';
   X_txn_uom             VARCHAR2(25) := '';
   X_po_uom              VARCHAR2(25) := '';
   X_pr_to_txn_rate      NUMBER := 1;
   X_pr_to_po_rate       NUMBER := 1;
   X_po_to_txn_rate      NUMBER := 1;
   X_item_id             NUMBER := 0;
   X_line_location_id    NUMBER := 0;
   X_distribution_id     NUMBER := 0; --Bug 10074319
   X_received_quantity   NUMBER := 0;
   X_corrected_quantity  NUMBER := 0;
   X_delivered_quantity  NUMBER := 0;
   X_rtv_quantity        NUMBER := 0;
   X_accepted_quantity   NUMBER := 0;
   X_rejected_quantity   NUMBER := 0;

   v_primary_uom         VARCHAR2(25) := '';
   v_po_uom              VARCHAR2(25) := '';
   v_txn_uom             VARCHAR2(25) := '';
   v_txn_id              NUMBER := 0;
   v_primary_quantity    NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';
   v_shipment_line_id    NUMBER := 0;
   v_line_location_id    NUMBER := 0;
   v_distribution_id     NUMBER := 0; --Bug 10074319
/* Bug 2033579 Added two variables to store grand parent type and id */
   grand_parent_type VARCHAR2(25) := '';
   grand_parent_id       NUMBER := 0;

   /* This cursor recursively query up all the children of the
   ** top transaction (RECEIVE or MATCH)
   */
   -- Bug 6115619
      p_api_version NUMBER := 1.0;
      x_skip_status VARCHAR2(1);
      x_msg_count NUMBER;
      x_msg_data VARCHAR2(2400);
      x_return_status VARCHAR2(10);

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
       po_distribution_id, --Bug 10074319
       parent_transaction_id
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

BEGIN
     -- return if invalid input parameters

     IF top_transaction_id IS NULL THEN

       RETURN;

     END IF;

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
                                v_distribution_id, --Bug 10074319
                                v_parent_id;

       EXIT WHEN c_txn_history%NOTFOUND;

       X_progress := '002';

       IF v_transaction_type = 'RECEIVE' OR v_transaction_type = 'MATCH' THEN

         /* Find out the item_id for UOM conversion */

         SELECT
           item_id
         INTO
           X_item_id
         FROM
           rcv_shipment_lines
         WHERE
           shipment_line_id = v_shipment_line_id;

         X_received_quantity := v_primary_quantity;
         X_line_location_id := v_line_location_id;
         X_distribution_id := v_distribution_id; --Bug 10074319
         X_primary_uom := v_primary_uom;
         X_txn_uom := v_txn_uom;
         X_po_uom := v_po_uom;

          /* Bug 6115619.With skip lot enable while creating an invoice with match to receipt
            and match level as 4 way,accepted quantity was not calculated properly because for skipped transactions RT is not created.*/
            BEGIN
            QA_SKIPLOT_RCV_GRP.IS_LOT_SKIPPED(p_api_version =>p_api_version,
                           p_transaction_id =>top_transaction_id,
                           x_skip_status=>x_skip_status,
                           x_return_status=>x_return_status,
                           x_msg_count=>x_msg_count,
                           x_msg_data=>x_msg_data);

           IF x_return_status = 'S' THEN
             IF x_skip_status = 'T' THEN
               X_accepted_quantity := X_received_quantity;
             END IF;
           END IF;
           EXCEPTION
           WHEN OTHERS then
            po_message_s.sql_error('Error in call to QA_SKIPLOT_RCV_GRP.IS_LOT_SKIPPED', X_progress, sqlcode);
            raise;
           END;
           -- End Bug 6115619
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

         -- Bug 6115619
         IF v_parent_type IN ('RECEIVE','RETURN TO RECEIVING') AND x_skip_status ='T' THEN
            x_accepted_quantity := x_accepted_quantity - v_primary_quantity; -- saravanan
         END IF;

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

/*Bug 2288641 Handling the No data found exception becuase when correction is
 done on a Receipt grand_parent_id will be -1 in that case the sql below will
 not return any records which shouldn't be treated as an error.
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

           X_corrected_quantity := X_corrected_quantity + v_primary_quantity;

           -- Bug 6115619
           IF x_skip_status ='T' THEN
              x_accepted_quantity := x_accepted_quantity + v_primary_quantity;
           END IF;


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

           -- Bug 6115619
           IF grand_parent_type = 'RECEIVE' AND x_skip_status ='T' THEN
              x_accepted_quantity := x_accepted_quantity - v_primary_quantity;
           END IF;

         ELSIF v_parent_type = 'DELIVER' THEN

           X_delivered_quantity := X_delivered_quantity + v_primary_quantity;

         ELSIF v_parent_type = 'ACCEPT' THEN
/*Bug 2033579 When performing a correction on Accept transaction and if its
  grand parent is Reject transaction then the Rejected quantity will be adjusted*/

             if grand_parent_type = 'REJECT' THEN
		X_rejected_quantity := X_rejected_quantity - v_primary_quantity;
	     end if;

           /* Bug 4038533: When performing a correction on ACCEPT transaction if grand parent
           **              transaction is ACCEPT then the accepted qty should not be adjusted.
           */

             if grand_parent_type <> 'ACCEPT' THEN
               X_accepted_quantity := X_accepted_quantity + v_primary_quantity;
             end if;

         ELSIF v_parent_type = 'REJECT' THEN
/*Bug 2033579 When performing a correction on Reject Transaction and if its
  grand parent is Accept transaction then the accepted quantity will be
  adjusted.
*/
	     if grand_parent_type = 'ACCEPT' THEN
               X_accepted_quantity := X_accepted_quantity - v_primary_quantity;
             end if;

           /* Bug 4038533: When performing a correction on REJECT transaction if grand parent
           **              transaction is REJECT then the rejected qty should not be adjusted.
           */

             if grand_parent_type <> 'REJECT' THEN
               X_rejected_quantity := X_rejected_quantity + v_primary_quantity;
             end if;

         ELSIF v_parent_type = 'RETURN TO RECEIVING' THEN

           X_delivered_quantity := X_delivered_quantity - v_primary_quantity;

         END IF;
       END IF;

     END LOOP;

     CLOSE c_txn_history;

     X_progress := '003';

     /* Get the orderd, billed quantity from PO */
     /* Bug 10074319 if match to specific distributions, then get info from POD*/
     IF X_distribution_id IS NOT NULL THEN
         SELECT
         pod.quantity_ordered,
         pod.quantity_cancelled,
         rt.quantity_billed	-- This quantity is in transaction UOM
       INTO
         ordered_po_qty,
         cancelled_po_qty,
         billed_txn_qty
       FROM
         po_distributions pod,
         rcv_transactions  rt
       WHERE
         rt.transaction_id = top_transaction_id and
         rt.po_distribution_id = pod.po_distribution_id;
     ELSIF X_line_location_id IS NOT NULL THEN
       SELECT
         ps.quantity,
         ps.quantity_cancelled,
         rt.quantity_billed	-- This quantity is in transaction UOM
       INTO
         ordered_po_qty,
         cancelled_po_qty,
         billed_txn_qty
       FROM
         po_line_locations ps,
         rcv_transactions  rt
       WHERE
         rt.transaction_id = top_transaction_id and
         rt.po_line_location_id = ps.line_location_id;
     ELSE
       ordered_po_qty := 0;
       billed_txn_qty := 0;
     END IF;

     X_progress := '004';

     /* Get UOM conversion rates */

     X_pr_to_po_rate := po_uom_s.po_uom_convert(X_primary_uom, X_po_uom, X_item_id);
     X_pr_to_txn_rate := po_uom_s.po_uom_convert(X_primary_uom, X_txn_uom, X_item_id);
     X_po_to_txn_rate := po_uom_s.po_uom_convert(X_po_uom, X_txn_uom, X_item_id);

     X_progress := '005';

     /* Calculate the quantity with uom info */
     corrected_po_qty := X_pr_to_po_rate * X_corrected_quantity;
     delivered_po_qty := X_pr_to_po_rate * X_delivered_quantity;
     rtv_po_qty := X_pr_to_po_rate * X_rtv_quantity;
     accepted_po_qty := X_pr_to_po_rate * X_accepted_quantity;
     rejected_po_qty := X_pr_to_po_rate * X_rejected_quantity;

     billed_po_qty := billed_txn_qty / X_po_to_txn_rate;	-- txn to po rate is inverse of
								-- X_po_to_txn_rate

     ordered_txn_qty := X_po_to_txn_rate * ordered_po_qty;
     cancelled_txn_qty := X_po_to_txn_rate * cancelled_po_qty;

     received_txn_qty := X_pr_to_txn_rate * X_received_quantity;
     corrected_txn_qty := X_pr_to_txn_rate * X_corrected_quantity;
     delivered_txn_qty := X_pr_to_txn_rate * X_delivered_quantity;
     rtv_txn_qty := X_pr_to_txn_rate * X_rtv_quantity;
     accepted_txn_qty := X_pr_to_txn_rate * X_accepted_quantity;
     rejected_txn_qty := X_pr_to_txn_rate * X_rejected_quantity;

     X_progress := '006';

/* Bug 2964160 need to round off the quantities before passing them out
   Bug 10074319  rounding to 9 decimals to match the standard precision in RCV */
  ordered_po_qty    := round(ordered_po_qty,9);
  cancelled_po_qty  := round(cancelled_po_qty,9);
  received_po_qty   := round(received_po_qty,9);
  corrected_po_qty  := round(corrected_po_qty,9);
  delivered_po_qty  := round(delivered_po_qty,9);
  rtv_po_qty        := round(rtv_po_qty,9);
  billed_po_qty     := round(billed_po_qty,9);
  accepted_po_qty   := round(accepted_po_qty,9);
  rejected_po_qty   := round(rejected_po_qty,9);
  ordered_txn_qty   := round(ordered_txn_qty,9);
  cancelled_txn_qty := round(cancelled_txn_qty,9);
  received_txn_qty  := round(received_txn_qty,9);
  corrected_txn_qty := round(corrected_txn_qty,9);
  delivered_txn_qty := round(delivered_txn_qty,9);
  rtv_txn_qty       := round(rtv_txn_qty,9);
  billed_txn_qty    := round(billed_txn_qty,9);
  accepted_txn_qty  := round(accepted_txn_qty,9);
  rejected_txn_qty  := round(rejected_txn_qty,9);

EXCEPTION

  when others then
    po_message_s.sql_error('get_transaction_quantities', X_progress, sqlcode);
    raise;

END get_quantities;

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
					corrected_txn_qty	IN OUT	NOCOPY NUMBER) IS

   X_progress            VARCHAR2(3)  := '000';

   X_primary_uom         VARCHAR2(25) := '';
   X_txn_uom             VARCHAR2(25) := '';
   X_po_uom              VARCHAR2(25) := '';
   X_pr_to_txn_rate      NUMBER := 1;
   X_pr_to_po_rate       NUMBER := 1;
   X_po_to_txn_rate      NUMBER := 1;
   X_item_id             NUMBER := 0;
   X_corrected_quantity  NUMBER := 0;
   X_delivered_quantity  NUMBER := 0;
   X_returned_quantity   NUMBER := 0;

   X_deliver_txn_id      NUMBER := 0;

   v_txn_id              NUMBER := 0;
   v_primary_quantity    NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';

  /* This cursor recursively query up all the children of the
  ** top transaction (DELIVER)
  */

   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     SELECT
       transaction_id,
       primary_quantity,
       transaction_type,
       parent_transaction_id
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

   /* This cursor query up the all the deliver transactions */

   CURSOR c_deliver_txn (c_transaction_id NUMBER, c_distribution_id NUMBER) IS
     SELECT
       transaction_id
     FROM
       rcv_transactions
     WHERE
       transaction_type = 'DELIVER' AND
       po_distribution_id = c_distribution_id
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id
                AND PRIOR transaction_type <> 'DELIVER';

BEGIN

     -- return if invalid input parameters

     IF rcv_transaction_id IS NULL or p_distribution_id IS NULL THEN

       RETURN;

     END IF;

     /* Query up UOM info */

     SELECT
       sl.item_id,
       rt.primary_unit_of_measure,
       rt.source_doc_unit_of_measure,
       rt.unit_of_measure
     INTO
       X_item_id,
       X_primary_uom,
       X_po_uom,
       X_txn_uom
     FROM
       rcv_shipment_lines sl,
       rcv_transactions   rt
     WHERE
       rt.transaction_id = rcv_transaction_id AND
       rt.shipment_line_id = sl.shipment_line_id;

     X_progress := '001';

     OPEN c_deliver_txn(rcv_transaction_id, p_distribution_id);

     LOOP

       FETCH c_deliver_txn INTO X_deliver_txn_id;

       EXIT WHEN c_deliver_txn%NOTFOUND;

       X_progress := '002';

       OPEN c_txn_history(X_deliver_txn_id);

       X_progress := '003';

       LOOP
         FETCH c_txn_history INTO v_txn_id,
                                  v_primary_quantity,
                                  v_transaction_type,
                                  v_parent_id;

         EXIT WHEN c_txn_history%NOTFOUND;

         X_progress := '004';

         IF v_transaction_type = 'DELIVER' THEN

           X_delivered_quantity := X_delivered_quantity + v_primary_quantity;

         ELSIF v_transaction_type = 'RETURN TO RECEIVING' THEN

           X_returned_quantity := X_returned_quantity + v_primary_quantity;

         ELSIF v_transaction_type = 'CORRECT' THEN

           /* The correction function is based on parent transaction type */

           SELECT
             transaction_type
           INTO
             v_parent_type
           FROM
             rcv_transactions
           WHERE
             transaction_id = v_parent_id;

           IF v_parent_type = 'DELIVER' THEN

             X_corrected_quantity := X_corrected_quantity + v_primary_quantity;

           ELSIF v_parent_type = 'RETURN TO RECEIVING' THEN

             X_returned_quantity := X_returned_quantity + v_primary_quantity;

           END IF;
         END IF;

       END LOOP;

       CLOSE c_txn_history;

     END LOOP;

     CLOSE c_deliver_txn;

     X_progress := '005';

     SELECT
       pd.quantity_ordered,
       pd.quantity_cancelled
     INTO
       ordered_po_qty,
       cancelled_po_qty
     FROM
       po_distributions pd
     WHERE
       pd.po_distribution_id = p_distribution_id;

     /* Get UOM conversion rates */

     X_progress := '006';

     X_pr_to_po_rate := po_uom_s.po_uom_convert(X_primary_uom, X_po_uom, X_item_id);
     X_pr_to_txn_rate := po_uom_s.po_uom_convert(X_primary_uom, X_txn_uom, X_item_id);
     X_po_to_txn_rate := po_uom_s.po_uom_convert(X_po_uom, X_txn_uom, X_item_id);

     X_progress := '007';

     /* Calculate the quantity with uom info */

     delivered_po_qty := X_pr_to_po_rate * X_delivered_quantity;
     returned_po_qty := X_pr_to_po_rate * X_returned_quantity;
     corrected_po_qty := X_pr_to_po_rate * X_corrected_quantity;

     ordered_txn_qty := X_po_to_txn_rate * ordered_po_qty;
     cancelled_txn_qty := X_po_to_txn_rate * cancelled_po_qty;

     delivered_txn_qty := X_pr_to_txn_rate * X_delivered_quantity;
     returned_txn_qty := X_pr_to_txn_rate * X_returned_quantity;
     corrected_txn_qty := X_pr_to_txn_rate * X_corrected_quantity;

EXCEPTION

  when others then
    po_message_s.sql_error('get_delivered_quantity', X_progress, sqlcode);
    raise;

END get_delivered_quantity;

PROCEDURE Get_ReceiveAmount
(   p_api_version            IN         NUMBER,
    p_init_msg_list          IN         VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_receive_transaction_id IN         NUMBER,    -- RECEIVE Transaction id
    x_billed_amt             OUT NOCOPY NUMBER,    -- rcv_transactions.amount_billed
    x_received_amt           OUT NOCOPY NUMBER,    -- amount from rcv transactions table for the corresponding RECEIVE transaction
    x_delivered_amt          OUT NOCOPY NUMBER,    -- amount from rcv transactions table for the corresponding DELIVER transaction
    x_corrected_amt          OUT NOCOPY NUMBER     -- amount from rcv transactions table for the corresponding CORRECT transaction
) IS
   l_api_name            CONSTANT VARCHAR2(30)    := 'Get_ReceiveAmount';
   l_api_version         CONSTANT NUMBER          := 1.0;

   X_progress            VARCHAR2(3)  := '000';
   l_parent_type         VARCHAR2(25) := '';

   -- This cursor recursively query up all the children of the RECEIVE transaction
   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     SELECT
       transaction_id,
       amount,
       amount_billed,
       transaction_type,
       shipment_line_id,
       po_line_location_id,
       parent_transaction_id,
       PRIOR transaction_type parent_transaction_type
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

BEGIN
     -- standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --initialize message list if p_init_msg_list is set
     IF FND_API.To_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --initialize return status to true
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- return if invalid input parameters
     IF p_receive_transaction_id IS NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;

     X_progress := '001';

     -- loop through all child transactions
     FOR l_transaction_record IN c_txn_history(p_receive_transaction_id)
     LOOP

       X_progress := '004';

       IF l_transaction_record.transaction_type = 'RECEIVE' OR l_transaction_record.transaction_type = 'MATCH' THEN
           x_received_amt := nvl(x_received_amt,0) + nvl(l_transaction_record.amount,0);
           x_billed_amt := nvl(x_billed_amt,0) + nvl(l_transaction_record.amount_billed,0);

       ELSIF l_transaction_record.transaction_type = 'DELIVER' THEN
           x_delivered_amt := nvl(x_delivered_amt,0) + nvl(l_transaction_record.amount,0);
       ELSIF l_transaction_record.transaction_type = 'CORRECT' THEN
           IF l_transaction_record.parent_transaction_type = 'RECEIVE' OR
              l_transaction_record.parent_transaction_type = 'MATCH' THEN
             x_corrected_amt := nvl(x_corrected_amt,0) + nvl(l_transaction_record.amount,0);
           END IF;
       END IF;

     END LOOP;  -- c_txn_history

     X_progress := '005';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    po_message_s.sql_error('Get_DeliverAmount', X_progress, sqlcode);
    RAISE;

END Get_ReceiveAmount;

PROCEDURE Get_DeliverAmount
(   p_api_version            IN         NUMBER,
    p_init_msg_list          IN         VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_receive_transaction_id IN         NUMBER,        -- Transaction id of the root RECEIVE transaction
    p_po_distribution_id     IN         NUMBER,
    x_delivered_amt          OUT NOCOPY NUMBER,        -- amount from rcv transactions table for the child DELIVER transactions
    x_corrected_amt          OUT NOCOPY NUMBER         -- amount from rcv transactions table for the child CORRECT transactions
) IS
   l_api_name            CONSTANT VARCHAR2(30)    := 'Get_DeliverAmount';
   l_api_version         CONSTANT NUMBER          := 1.0;

   X_progress            VARCHAR2(3)  := '000';

  /* This cursor recursively query up all the children of the
  ** top transaction (DELIVER)
  */
   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     SELECT
       transaction_id,
       amount,
       transaction_type,
       parent_transaction_id,
       PRIOR transaction_type parent_transaction_type
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

   /* This cursor query up the all the deliver transactions */
   CURSOR c_deliver_txn (c_transaction_id NUMBER, c_distribution_id NUMBER) IS
     SELECT
       transaction_id
     FROM
       rcv_transactions
     WHERE
       transaction_type = 'DELIVER' AND
       po_distribution_id = c_distribution_id
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id
            AND PRIOR transaction_type <> 'DELIVER';

BEGIN
     -- standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     --initialize message list if p_init_msg_list is set
     IF FND_API.To_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --initialize return status to true
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- return if invalid input parameters
     IF p_receive_transaction_id IS NULL OR p_po_distribution_id IS NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;

     X_progress := '001';

     FOR l_deliver_record IN c_deliver_txn (p_receive_transaction_id, p_po_distribution_id)
     LOOP

       X_progress := '002';

       FOR l_transaction_record IN c_txn_history (l_deliver_record.transaction_id)
       LOOP

         X_progress := '004';

         IF l_transaction_record.transaction_type = 'DELIVER' THEN
           x_delivered_amt := nvl(x_delivered_amt,0) + nvl(l_transaction_record.amount,0);
         ELSIF l_transaction_record.transaction_type = 'CORRECT' AND l_transaction_record.parent_transaction_type = 'DELIVER' THEN
           x_corrected_amt := nvl(x_corrected_amt,0) + nvl(l_transaction_record.amount,0);
         END IF;

       END LOOP;  -- c_txn_history

     END LOOP;  -- c_deliver_txn

     X_progress := '005';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    po_message_s.sql_error('Get_DeliverAmount', X_progress, sqlcode);
    RAISE;

END Get_DeliverAmount;

END RCV_INVOICE_MATCHING_SV;

/
