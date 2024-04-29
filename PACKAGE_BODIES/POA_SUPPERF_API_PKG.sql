--------------------------------------------------------
--  DDL for Package Body POA_SUPPERF_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SUPPERF_API_PKG" AS
/* $Header: POASPAPB.pls 115.7 2003/12/09 09:04:34 bthammin ship $ */

   -- get_receipt_date
   -- ----------------
   -- This function returns the receipt date from rcv_transactions.  There can
   -- be multiple receipts for a single shipment, so we are only accounting for
   -- the earliest receipt date
   --
   FUNCTION get_receipt_date(p_line_location_id NUMBER)
      RETURN DATE
   IS
      v_receipt_date 	DATE := NULL;
      x_progress 	VARCHAR2(3);
   BEGIN

      x_progress := '001';

      SELECT MIN(transaction_date)
      INTO   v_receipt_date
      FROM   rcv_transactions
      WHERE  po_line_location_id = p_line_location_id
      AND    transaction_type = 'RECEIVE';

      RETURN(v_receipt_date);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(v_receipt_date);
      WHEN OTHERS THEN
     	 POA_LOG.put_line('get_receipt_date:  ' || x_progress
			  || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_receipt_date);

   END get_receipt_date;





   -- get_avg_price - this may need to be converted to primary uom
   -- -------------
   -- This function returns the average purchase price of an item on a single
   -- shipment across multiple distribution lines.  The price is also
   -- converted to functional currency.  Since there is only one price at
   -- the shipment level, we can first find the average rate across the
   -- distributions and then multiplying that with the price that is
   -- passed in as a parameter.
   --
   FUNCTION get_avg_price(p_line_location_id NUMBER,
                          p_price_override   NUMBER)
      RETURN NUMBER
   IS
      v_ave_rate  NUMBER;
      v_ave_price NUMBER := 0;
      x_progress  VARCHAR2(3);
   BEGIN

      x_progress := '001';

      SELECT sum(quantity_ordered * nvl(rate, 1)) /
	     DECODE(sum(quantity_ordered), 0, 1, sum(quantity_ordered))
      INTO   v_ave_rate
      FROM   po_distributions_all
      WHERE  line_location_id = p_line_location_id
      AND    nvl(distribution_type,'-99') <> 'AGREEMENT';

      v_ave_price := v_ave_rate * p_price_override;

      RETURN(v_ave_price);

   EXCEPTION
      WHEN OTHERS THEN
    	 POA_LOG.put_line('get_avg_price:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_ave_price);

   END get_avg_price;





   -- get_primary_avg_price
   -- ---------------------
   -- This function returns the average price of an item on a single
   -- shipment across multiple distribution lines.  Basically, it calls
   -- get_avg_price() and then converts the result into the primary
   -- unit of measure of the item.
   --
   FUNCTION get_primary_avg_price(p_line_location_id NUMBER,
                                  p_price_override   NUMBER,
                                  p_item_id          NUMBER,
                                  p_organization_id  NUMBER,
                                  p_uom              VARCHAR2)
      RETURN NUMBER
   IS
      v_avg_price         NUMBER;
      v_uom_rate          NUMBER;
      v_primary_uom       NUMBER;
      v_primary_avg_price NUMBER := 0;
      x_progress          VARCHAR2(3);
   BEGIN

      v_avg_price := get_avg_price(p_line_location_id, p_price_override);
      v_primary_uom := get_primary_uom(p_item_id, p_organization_id);

      v_uom_rate := inv_convert.inv_um_convert(p_item_id,
                                               5,
                                               NULL, NULL, NULL,
                                               p_uom,
                                               v_primary_uom);

      IF (v_uom_rate IS NOT NULL) AND (v_uom_rate <> 0) THEN
         v_primary_avg_price := v_avg_price / v_uom_rate;
      ELSE
	 v_primary_avg_price := v_avg_price;
      END IF;

      RETURN(v_primary_avg_price);

   EXCEPTION
      WHEN OTHERS THEN
    	 POA_LOG.put_line('get_primary_avg_price:  ' || x_progress
			  || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_primary_avg_price);

   END get_primary_avg_price;





   -- get_num_receipts
   -- ----------------
   -- This function counts the number of receipts for a specific shipment
   -- and returns that number.  If there has not been a receive transaction
   -- for this shipment, we return 0.
   --
   FUNCTION get_num_receipts(p_line_location_id NUMBER)
      RETURN NUMBER
   IS
      v_num_receipts NUMBER := 0;
      x_progress     VARCHAR2(3);
   BEGIN

      x_progress := '001';

      SELECT count(*)
      INTO   v_num_receipts
      FROM   rcv_transactions
      WHERE  po_line_location_id = p_line_location_id
      AND    transaction_type = 'RECEIVE';

      RETURN(v_num_receipts);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(v_num_receipts);
      WHEN OTHERS THEN
    	 POA_LOG.put_line('get_num_receipts:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_num_receipts);

   END get_num_receipts;




   -- get_quantity_late
   -- -----------------
   -- This function returns the quantity of a shipment that is received late.
   -- The quantity returned is in the primary unit of measure.  If expected
   -- date is null, then we return zero and assume the shipment is on time.
   --
   FUNCTION get_quantity_late(p_line_location_id  NUMBER,
                              p_expected_date     DATE,
                              p_days_late_allowed NUMBER)
      RETURN NUMBER
   IS
      v_quantity_late	NUMBER := 0;
      v_txn_qty		NUMBER := 0;
      v_correction_qty	NUMBER := 0;
      x_progress	VARCHAR2(3);
   BEGIN

      IF p_expected_date IS NOT NULL THEN
         x_progress := '001';

         SELECT SUM(primary_quantity)
         INTO   v_txn_qty
         FROM   rcv_transactions
         WHERE  po_line_location_id = p_line_location_id
         AND    transaction_type    = 'RECEIVE'
         AND    transaction_date - NVL(p_days_late_allowed, 0)
				    > p_expected_date;

         x_progress := '002';

         SELECT SUM(rcor.primary_quantity)
         INTO   v_correction_qty
         FROM   rcv_transactions    rcor,
	        rcv_transactions    rct
         WHERE  rcor.po_line_location_id = p_line_location_id
	 AND    rcor.transaction_type    = 'CORRECT'
	 AND    rct.transaction_id	 = rcor.parent_transaction_id
	 AND    rct.transaction_type     = 'RECEIVE'
         AND    rct.transaction_date - NVL(p_days_late_allowed, 0)
					 > p_expected_date;
      END IF;

      v_quantity_late := NVL(v_txn_qty, 0) +  NVL(v_correction_qty, 0);

      RETURN(v_quantity_late);

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('get_quantity_late:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_quantity_late);

   END get_quantity_late;





   -- get_quantity_early
   -- ------------------
   -- This function returns the quantity of a shipment that is received early.
   -- The quantity returned is in the primary unit of measure.  If expected
   -- date is null, then we return zero and assume the shipment is on time.
   --
   FUNCTION get_quantity_early(p_line_location_id  NUMBER,
                               p_expected_date     DATE,
                               p_days_early_allowed NUMBER)
      RETURN NUMBER
   IS
      v_quantity_early	NUMBER := 0;
      v_txn_qty		NUMBER := 0;
      v_correction_qty	NUMBER := 0;
      x_progress	VARCHAR2(3);
   BEGIN

      IF p_expected_date IS NOT NULL THEN
         x_progress := '001';

         SELECT SUM(primary_quantity)
         INTO   v_txn_qty
         FROM   rcv_transactions
         WHERE  po_line_location_id = p_line_location_id
         AND    transaction_type    = 'RECEIVE'
         AND    transaction_date + NVL(p_days_early_allowed, 0)
				    < p_expected_date;

         x_progress := '002';

         SELECT SUM(rcor.primary_quantity)
         INTO   v_correction_qty
         FROM   rcv_transactions    rcor,
	        rcv_transactions    rct
         WHERE  rcor.po_line_location_id = p_line_location_id
	 AND    rcor.transaction_type    = 'CORRECT'
	 AND    rct.transaction_id	 = rcor.parent_transaction_id
	 AND    rct.transaction_type     = 'RECEIVE'
         AND    rct.transaction_date + NVL(p_days_early_allowed, 0)
					 < p_expected_date;
      END IF;

      v_quantity_early := NVL(v_txn_qty, 0) +  NVL(v_correction_qty, 0);

      RETURN(v_quantity_early);

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('get_quantity_early:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_quantity_early);

   END get_quantity_early;





   -- get_quantity_past_due
   -- ---------------------
   -- This function returns the past-due quantity.
   -- A shipment has past-due quantity if today is past the expected date
   -- plus the late days allowed and there are still quantity not received.
   -- If there is no expected date the shipment will never be past due.
   --
   FUNCTION get_quantity_past_due(p_quantity_ordered  NUMBER,
                                  p_quantity_received NUMBER,
                              	  p_expected_date     DATE,
                              	  p_days_late_allowed NUMBER)
      RETURN NUMBER
   IS
      v_quantity_past_due   NUMBER;
   BEGIN

      IF ((p_expected_date IS NOT NULL)				AND
          (sysdate > (p_expected_date + p_days_late_allowed))	AND
          (p_quantity_received < p_quantity_ordered))		THEN

         v_quantity_past_due := p_quantity_ordered - p_quantity_received;
      ELSE

         v_quantity_past_due := 0;

      END IF;

      RETURN(v_quantity_past_due);

   END get_quantity_past_due;





   -- get_primary_uom
   -- ---------------
   -- This function returns the primary unit of measure of an item.
   --
   FUNCTION get_primary_uom(p_item_id NUMBER, p_organization_id NUMBER)
      RETURN VARCHAR2
   IS
      v_primary_uom 	VARCHAR2(25) := NULL;
      x_progress    	VARCHAR2(3);
   BEGIN

      x_progress := '001';

      SELECT primary_unit_of_measure
      INTO   v_primary_uom
      FROM   mtl_system_items 			items,
	     financials_system_params_all 	fsp
      WHERE  NVL(fsp.org_id, -999)	= NVL(p_organization_id, -999)
      AND    items.organization_id      = fsp.inventory_organization_id
      AND    inventory_item_id 		= p_item_id;

      RETURN(v_primary_uom);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
    	 POA_LOG.put_line('No primary UOM found for item ' || p_item_id || ' and org ' || p_organization_id);
      	 POA_LOG.put_line(' ');
	 RAISE;
         RETURN(v_primary_uom);
       WHEN OTHERS THEN
     	 POA_LOG.put_line('get_primary_uom:  ' || x_progress || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_primary_uom);
   END get_primary_uom;





   -- get_primary_quantity
   -- --------------------
   -- This is a function to convert a given quantity to a primary quantity
   -- that is in the item's primary unit of measure.
   --
   FUNCTION get_primary_quantity(p_quantity        NUMBER,
                                 p_item_id         NUMBER,
                                 p_organization_id NUMBER,
                                 p_uom             VARCHAR2)
      RETURN NUMBER
   IS
      v_primary_uom      VARCHAR2(25);
      v_primary_quantity NUMBER := 0;
   BEGIN

      v_primary_uom := get_primary_uom(p_item_id, p_organization_id);

      v_primary_quantity := inv_convert.inv_um_convert(p_item_id,
                                                       5,
                                                       p_quantity,
                                                       NULL,
                                                       NULL,
                                                       p_uom,
                                                       v_primary_uom
                                                      );
      RETURN(v_primary_quantity);

   END get_primary_quantity;





   -- get_quantity_purchased
   -- ----------------------
   -- This function returns the quantity that is purchased for the
   -- shipment line.  If the shipment is finally closed, the maximum
   -- betweent the quantity received and the quantity billed is returned.
   -- Otherwise, If the shipment is not finally closed, we check to see if
   -- it has been cancelled.  If it has been cancelled, the difference
   -- between the quantity ordered and quantity cancelled is returned,
   -- otherwise, we return the quantity ordered as the quantity purchased.
   --
   FUNCTION get_quantity_purchased(p_quantity_ordered   NUMBER,
                                   p_quantity_billed    NUMBER,
                                   p_quantity_cancelled NUMBER,
                                   p_quantity_received  NUMBER,
                                   p_cancel_flag        VARCHAR2,
                                   p_closed_code        VARCHAR2)

      RETURN NUMBER
   IS
      v_quantity_purchased         NUMBER := 0;
   BEGIN

      IF p_closed_code = 'FINALLY CLOSED' THEN
         v_quantity_purchased := greatest(p_quantity_received,
                                          p_quantity_billed);
      ELSE
         IF p_cancel_flag = 'Y' THEN
            v_quantity_purchased := p_quantity_ordered - p_quantity_cancelled;
         ELSE
            v_quantity_purchased := p_quantity_ordered;
         END IF;
      END IF;

      RETURN(v_quantity_purchased);

   END get_quantity_purchased;





   -- get_total_amount
   -- ----------------
   -- This function returns the total purchase amount for a single shipment.
   -- To perform this calculation, we first select all the distributions for
   -- the given shipment.  For each distribution, we multiply the quantity
   -- purchased, the price override, and the currency conversion rate.  We
   -- then sum up this amount to find the total amount for the shipment.
   -- Question: What happens if price override is null?
   --
   FUNCTION get_total_amount(p_line_location_id NUMBER,
                             p_cancel_flag      VARCHAR2,
                             p_closed_code      VARCHAR2,
                             p_price            NUMBER)
      RETURN NUMBER
   IS
      CURSOR C_DIST IS
         SELECT nvl(quantity_delivered, 0) quantity_delivered,
                nvl(quantity_billed, 0) quantity_billed,
                nvl(quantity_cancelled, 0) quantity_cancelled,
                quantity_ordered,
                nvl(rate, 1) rate
         FROM   po_distributions_all
         WHERE  line_location_id = p_line_location_id
         AND    nvl(distribution_type,'-99')  <> 'AGREEMENT';

      v_c_info             C_DIST%ROWTYPE;
      v_quantity_purchased NUMBER;
      v_total_amount       NUMBER := 0;
      x_progress           VARCHAR2(3);
   BEGIN
      x_progress := '001';

      OPEN C_DIST;
      LOOP

         FETCH C_DIST INTO v_c_info;
         EXIT WHEN C_DIST%NOTFOUND;

         -- gotta make sure all quantities are in the same uom...
         -- all these are in distributions level, so i think i'm ok...
         v_quantity_purchased := get_quantity_purchased(
                                         v_c_info.quantity_ordered,
                                         v_c_info.quantity_billed,
                                         v_c_info.quantity_cancelled,
                                         v_c_info.quantity_delivered,
                                         p_cancel_flag,
                                         p_closed_code);

         v_total_amount := v_total_amount +
                           (v_quantity_purchased * p_price * v_c_info.rate);

      END LOOP;
      CLOSE C_DIST;

      RETURN(v_total_amount);

   EXCEPTION
       WHEN OTHERS THEN
   	 POA_LOG.put_line('get_total_amount:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_total_amount);

   END get_total_amount;





   -- get_suppliers
   -- -------------
   -- This function gets the supplier ids of the top suppliers limited by
   -- a user specified sort criteria and a user specified number of suppliers
   -- parameter.  This is only called from the report client.
   --
   FUNCTION get_suppliers(p_order_by            NUMBER,
                          p_item                NUMBER,
                          p_fdate               DATE,
                          p_tdate               DATE,
                          p_number_of_suppliers NUMBER)
      RETURN VARCHAR2
   IS
      type T_FLEXREF is REF CURSOR;
      v_cursor_blk    T_FLEXREF;
      v_supplier_id   NUMBER;
      v_totals        NUMBER;
      v_num_suppliers NUMBER := 0;
      v_suppliers     VARCHAR2(2000);
      x_progress      VARCHAR2(3);
   BEGIN
      IF p_order_by = 1 THEN
         x_progress := '001';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(quantity_rejected) /
		   decode(sum(nvl(quantity_received, 0)), 0, 1,
			  sum(nvl(quantity_received, 0))) defects
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY defects desc;

      ELSIF p_order_by = 2 THEN
         x_progress := '002';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(nvl(quantity_received_late, 0) +
		       nvl(quantity_received_early, 0) +
                       nvl(quantity_past_due, 0)) /
		     nvl(sum(quantity_ordered), 1) exceptions
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY exceptions desc;

      ELSIF p_order_by = 3 THEN
         x_progress := '003';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(quantity_purchased) volume
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY volume desc;

      ELSIF p_order_by = 4 THEN
         x_progress := '004';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(quantity_ordered * purchase_price) /
		     nvl(sum(quantity_ordered), 1) price
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY price desc;

      ELSIF p_order_by = 5 THEN
         x_progress := '005';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(amount) amount
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY amount desc;

      ELSIF p_order_by = 6 THEN
         x_progress := '006';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(quantity_rejected) /
		   decode(sum(nvl(quantity_received, 0)), 0, 1,
			  sum(nvl(quantity_received, 0))) defects
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY defects asc;

      ELSIF p_order_by = 7 THEN
         x_progress := '007';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(nvl(quantity_received_late, 0) +
                       nvl(quantity_received_early, 0) +
                       nvl(quantity_past_due, 0)) /
		     nvl(sum(quantity_ordered), 1) exceptions
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY exceptions asc;

      ELSIF p_order_by = 8 THEN
         x_progress := '008';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(quantity_purchased) volume
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY volume asc;

      ELSIF p_order_by = 9 THEN
         x_progress := '009';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(quantity_ordered * purchase_price) /
		     nvl(sum(quantity_ordered), 1) price
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY price asc;

      ELSIF p_order_by = 10 THEN
         x_progress := '010';

         OPEN v_cursor_blk FOR
            SELECT supplier_id,
                   sum(amount) amount
            FROM   poa_bis_supplier_performance_v
            WHERE  item_id = p_item
            AND    date_dimension between p_fdate and p_tdate
            GROUP BY supplier_id
            ORDER BY amount asc;
      END IF;

      LOOP

         FETCH v_cursor_blk INTO v_supplier_id, v_totals;
         EXIT WHEN v_cursor_blk%NOTFOUND
              OR   v_num_suppliers >= p_number_of_suppliers;

         v_suppliers := v_suppliers || ', ' || v_supplier_id;
         v_num_suppliers := v_num_suppliers + 1;

      END LOOP;

      v_suppliers := '( -1' || v_suppliers || ')';

      RETURN(v_suppliers);

      CLOSE v_cursor_blk;

   EXCEPTION
      WHEN OTHERS THEN
   	 POA_LOG.put_line('get_suppliers:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_suppliers);

   END get_suppliers;




   -- get_last_trx_date
   -- -----------------
   -- This procedure returns the last update date for a particular
   -- shipment line.
   -- The dates considered are for:
   --	- rcv_transactions 	- last_update_date
   --   - po_line_locations_all - last_update_date
   --  If any of these records changed after the last collection,
   --  the shipment data need to be re-collected.
   --
   FUNCTION get_last_trx_date(p_line_location_id 	NUMBER)
     RETURN DATE
   IS
      x_progress 		VARCHAR2(3);
      v_max_rcv_date 		DATE := NULL;
      v_shipment_date		DATE := NULL;
   BEGIN

      x_progress := '001';

      --
      -- Get max date from rcv_transactions, including corrections
      --
      BEGIN
	 SELECT MAX(last_update_date)
	 INTO   v_max_rcv_date
	 FROM   rcv_transactions
	 WHERE  po_line_location_id = p_line_location_id;

      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    v_max_rcv_date := NULL;
      END;

      x_progress := '002';

      --
      -- Get max date from po_line_locations_all
      --
      BEGIN
	 SELECT last_update_date
	 INTO   v_shipment_date
	 FROM   po_line_locations_all
	 WHERE  line_location_id = p_line_location_id;
      END;

      RETURN(GREATEST(NVL(v_max_rcv_date, v_shipment_date - 1),
		      v_shipment_date));

   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
         RETURN NULL;

   END get_last_trx_date;




   -- get_rcv_txn_qty
   -- --------------------
   -- This function returns the quantity received, accepted, or rejected,
   -- from a shipment line.
   -- The quantity returned is in the primary unit of measure.
   --
   FUNCTION get_rcv_txn_qty(p_line_location_id  NUMBER,
                            p_txn_type		VARCHAR2)
      RETURN NUMBER
   IS
      v_quantity        	NUMBER := 0;
      v_txn_qty			NUMBER := 0;
      v_correction_qty		NUMBER := 0;
      x_progress		VARCHAR2(3);
      invalid_type		EXCEPTION;
   BEGIN

      x_progress := '001';

      IF p_txn_type NOT IN ('RECEIVE', 'ACCEPT', 'REJECT') THEN
         RAISE invalid_type;
      END IF;

      x_progress := '002';

      SELECT SUM(primary_quantity)
      INTO   v_txn_qty
      FROM   rcv_transactions
      WHERE  po_line_location_id = p_line_location_id
      AND    transaction_type    = p_txn_type;

      x_progress := '003';

      SELECT SUM(rcor.primary_quantity)
      INTO   v_correction_qty
      FROM   rcv_transactions    rcor,
             rcv_transactions    rct
      WHERE  rcor.po_line_location_id = p_line_location_id
      AND    rcor.transaction_type    = 'CORRECT'
      AND    rct.transaction_id	      = rcor.parent_transaction_id
      AND    rct.transaction_type     = p_txn_type;

      v_quantity := NVL(v_txn_qty, 0) +  NVL(v_correction_qty, 0);

      RETURN(v_quantity);

   EXCEPTION
      WHEN invalid_type THEN
   	 POA_LOG.put_line('get_rcv_txn_qty:  ' || x_progress
                          || ' ' || 'Invalid transaction Type - '
                          || p_txn_type);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_quantity);

      WHEN OTHERS THEN
   	 POA_LOG.put_line('get_rcv_txn_qty:  ' || x_progress
                          || ' ' || sqlerrm);
      	 POA_LOG.put_line(' ');
         RAISE;
         RETURN(v_quantity);

   END get_rcv_txn_qty;



END POA_SUPPERF_API_PKG;

/
