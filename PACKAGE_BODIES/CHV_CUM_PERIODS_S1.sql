--------------------------------------------------------
--  DDL for Package Body CHV_CUM_PERIODS_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_CUM_PERIODS_S1" as
/* $Header: CHVPRCQB.pls 120.0.12010000.6 2014/04/25 11:02:10 adevadul ship $ */

/*===========================================================================

  PROCEDURE NAME:	test_get_cum_qty_received

===========================================================================*/
   PROCEDURE test_get_cum_qty_received IS

      X_qty_received_primary NUMBER;
      X_qty_received_purch NUMBER;

      BEGIN

         --dbms_output.put_line('before call');

	 chv_cum_periods_s1.get_cum_qty_received(83,
				       85,
				       45050,
				       205,
				       'N',
				       'sysdate',
				       'sysdate + 30',
				       'Each',
				       X_qty_received_primary,
				       X_qty_received_purch);

         --dbms_output.put_line('after call');
         --dbms_output.put_line('qty rcv primary'||X_qty_received_primary);
         --dbms_output.put_line('qty rcv purch'||X_qty_received_purch);

      END test_get_cum_qty_received;


/****************************************************************************
**
**PROCEDURE NAME:	get_cum_qty_received
**
****************************************************************************/
PROCEDURE get_cum_qty_received (X_vendor_id IN NUMBER,
				X_vendor_site_id IN NUMBER,
                                X_item_id IN NUMBER,
			        X_organization_id IN NUMBER,
			        X_rtv_transactions_included IN VARCHAR2,
				X_cum_period_start IN DATE,
				X_cum_period_end IN DATE,
			        X_purchasing_unit_of_measure IN VARCHAR2,
				X_qty_received_primary IN OUT NOCOPY NUMBER,
				X_qty_received_purchasing IN OUT NOCOPY NUMBER) IS

X_transaction_uom_code varchar2(3);
X_purchasing_uom_code  varchar2(3);
X_primary_uom_code     varchar2(3);
X_uom_rate number;
X_primary_unit_of_measure varchar2(25);
X_unit_of_measure varchar2(25);
X_conversion_rate number;
X_quantity_received number;
X_transaction_id number;
X_rtv_primary_quantity number;
X_rtv_transaction_id number;
X_corrtv_primary_quantity number;
X_total_qty_received_primary number;
X_progress varchar2(3) := '000';
X_adjustment_quantity number;
X_tot_received_purch number;
X_tot_received_primary number;

-- Define the cursor that gets the receipt transaction plus all
-- of the corrections against the receipt
-- Note: We must use the item_id on the po_line instead of
-- on the receipt to account for substitute receipts.
/* Bug 2251090 fixed. In the where clause  of the below sql, added
     the nvl() statement for x_cum_period_end to take care of null
     condition.
  */
CURSOR C IS
      SELECT rsl.quantity_received,
	     rsl.unit_of_measure,
	     rsl.primary_unit_of_measure,
	     rct.transaction_id
      FROM   rcv_shipment_lines rsl,
	     po_headers poh,
	     po_lines pol,
	     rcv_transactions rct
      WHERE  rct.shipment_line_id = rsl.shipment_line_id
      AND    rct.transaction_type = 'RECEIVE'
      AND    rsl.po_header_id = poh.po_header_id
      AND    rsl.po_line_id = pol.po_line_id
      AND    poh.vendor_id = X_vendor_id
      AND    poh.vendor_site_id = X_vendor_site_id
      AND    rsl.to_organization_id = X_organization_id
-- Bug#18661723: Cummins GBPA Support : Start
--      AND    poh.supply_agreement_flag = 'Y'
AND     (
                (
                        poh.type_lookup_code = 'BLANKET'
                AND     poh.supply_agreement_flag = 'Y'
                )
        OR      (
                        poh.type_lookup_code = 'STANDARD'
                AND     EXISTS
                        (
                        SELECT  1
                        FROM    po_headers ph1
                        WHERE   pol.from_header_id IS NOT NULL
                        AND     pol.from_header_id = ph1.po_header_id
                        AND     ph1.type_lookup_code = 'BLANKET'
                        AND     ph1.global_agreement_flag = 'Y'
                        AND     ph1.supply_agreement_flag = 'Y'
                        )
                )
        )
-- Bug#18661723: Cummins GBPA Support : End
      AND    pol.item_id = X_item_id
      AND    rct.transaction_date between X_cum_period_start
			          and     nvl(X_cum_period_end,rct.transaction_date+1)
/* Bug#3067808 Added the following retrictive coindition to the SQL so that
** the correct value for transaction_id is retrived from receiving tables
** only for which the ASL entries exists.
*/
      AND    EXISTS  (select '1'
                      from po_asl_attributes_val_v paa,
                           po_asl_documents pad
                     WHERE paa.vendor_id = x_vendor_id
                       AND paa.vendor_site_id = x_vendor_site_id
                       AND paa.item_id = x_item_id
                       AND paa.using_organization_id =
                           (SELECT MAX(paa2.using_organization_id)
                            FROM   po_asl_attributes_val_v paa2
                            WHERE  decode(paa2.using_organization_id, -1,
                                          x_organization_id,
                                          paa2.using_organization_id) =
                                          x_organization_id
                               AND paa2.vendor_id = x_vendor_id
                               AND paa2.vendor_site_id = x_vendor_site_id
                               AND paa2.item_id = x_item_id)
                               AND  paa.asl_id = pad.asl_id
-- Bug#18661723: Cummins GBPA Support : Start
--                             AND  pad.document_header_id = poh.po_header_id
AND (
                        (
                                poh.type_lookup_code = 'BLANKET'
                        AND     pad.document_header_id = poh.po_header_id
                        )
                OR      (
                                poh.type_lookup_code = 'STANDARD'
                        AND     pad.document_header_id = pol.from_header_id
                        )
                )
-- Bug#18661723: Cummins GBPA Support : End
);
/* Bug#3067808 END */


-- Define the cursor to the the rtv transactions against
-- the receipt transaction
CURSOR C2 IS
         SELECT rct.primary_quantity,
	        rct.transaction_id
	 FROM   rcv_transactions rct
         WHERE  rct.transaction_type = 'RETURN TO VENDOR'
         AND    rct.parent_transaction_id = X_transaction_id;

/* Bug 2251090 fixed. In the where clause  of the below sql, added
     the nvl() statement for cum_period_end_date to take care of null
     condition.
  */
  /*bug 8881513 While running the auto schedule program in supplier scheduling
               product there was a performance issue.
	       Modified the sql in the cursor c_trxn_date as per the receiving
               team advice.*/
CURSOR C3 IS
      SELECT rsl.quantity_received,
	     rsl.unit_of_measure,
	     rsl.primary_unit_of_measure
      FROM   rcv_shipment_lines rsl,
	     po_headers poh,
	     po_lines pol
      WHERE  pol.item_id = X_item_id
      AND    rsl.po_line_id = pol.po_line_id
      AND    pol.po_header_id = poh.po_header_id
      AND    poh.vendor_id = X_vendor_id
      AND    poh.vendor_site_id = X_vendor_site_id
      AND    rsl.to_organization_id = X_organization_id
-- Bug#18661723: Cummins GBPA Support : Start
--      AND    poh.supply_agreement_flag = 'Y'
AND     (
                (
                        poh.type_lookup_code = 'BLANKET'
                AND     poh.supply_agreement_flag = 'Y'
                )
        OR      (
                        poh.type_lookup_code = 'STANDARD'
                AND     EXISTS
                        (
                        SELECT  1
                        FROM    po_headers ph1
                        WHERE   pol.from_header_id IS NOT NULL
                        AND     pol.from_header_id = ph1.po_header_id
                        AND     ph1.type_lookup_code = 'BLANKET'
                        AND     ph1.global_agreement_flag = 'Y'
                        AND     ph1.supply_agreement_flag = 'Y'
                        )
                )
        )
-- Bug#18661723: Cummins GBPA Support : End
      AND    exists
		(select 1
	         from   rcv_transactions rct
	         where  rct.transaction_date between x_cum_period_start
				             and     nvl(x_cum_period_end,
						rct.transaction_date+1)
                 and    rct.shipment_line_id = rsl.shipment_line_id
		 AND rct.shipment_header_id = rsl.shipment_header_id --bug 8881513
                 AND rct.organization_id = rsl.to_organization_id --bug 8881513
	         and    rct.transaction_type = 'RECEIVE')

/* Bug#3067808 Added the following retrictive coindition to the SQL so that
** the correct value for transaction_id is retrived from receiving tables
** only for which the ASL entries exists.
*/
      AND    EXISTS  (select '1'
                      from po_asl_attributes_val_v paa,
                           po_asl_documents pad
                     WHERE paa.vendor_id = x_vendor_id
                       AND paa.vendor_site_id = x_vendor_site_id
                       AND paa.item_id = x_item_id
                       AND paa.using_organization_id =
                           (SELECT MAX(paa2.using_organization_id)
                            FROM   po_asl_attributes_val_v paa2
                            WHERE  decode(paa2.using_organization_id, -1,
                                          x_organization_id,
                                          paa2.using_organization_id) =
                                          x_organization_id
                               AND paa2.vendor_id = x_vendor_id
                               AND paa2.vendor_site_id = x_vendor_site_id
                               AND paa2.item_id = x_item_id)
                               AND  paa.asl_id = pad.asl_id
-- Bug#18661723: Cummins GBPA Support : Start
--                               AND  pad.document_header_id = poh.po_header_id
AND (
                        (
                                poh.type_lookup_code = 'BLANKET'
                        AND     pad.document_header_id = poh.po_header_id
                        )
                OR      (
                                poh.type_lookup_code = 'STANDARD'
                        AND     pad.document_header_id = pol.from_header_id
                        )
                )
-- Bug#18661723: Cummins GBPA Support : End
);
/* Bug#3067808 END */

BEGIN

   -- RTV transactions are included in the CUM period that the
   -- receipt transactions are done in.  This means if the CUM period
   -- is closed that we performed the receipt transaction in,
   -- the RTV will be included in the closed CUM period.


   IF (x_rtv_transactions_included = 'Y') THEN

   --dbms_output.put_line('Get CUM Qty: Rtv transactions included');

      -- Open the cursor that gets all of the shipment lines that
      -- match the vendor, vendor site, org, item, in the cum period
      OPEN C3;

      -- For each of these shipment lines, get each of the rtvs
      -- against the shipment line.
      LOOP

	 --dbms_output.put_line('Get CUM Qty: before fetch');
	 --dbms_output.put_Line('Get CUM Qty: Item'||X_item_id);
         --dbms_output.put_line('Get CUM Qty: Vendor'||X_vendor_id);
         --dbms_output.put_line('Get CUM Qty: Site'||X_vendor_site_id);
	 --dbms_output.put_line('Get CUM Qty: Org'||X_organization_id);
         --dbms_output.put_line('Get CUM Qty: Start'||X_cum_period_start);
         --dbms_output.put_line('Get CUM Qty: End'||X_cum_period_end);

      X_progress := '010';

      FETCH C3 INTO X_quantity_received,
		      X_unit_of_measure,
		      X_primary_unit_of_measure;

      EXIT WHEN C3%notfound;


      --dbms_output.put_line('Get CUM Qty: X_qty_rcv'||X_quantity_received);
      --dbms_output.put_line('Get CUM Qty: X_prim_unit_of_meas'||X_primary_unit_of_measure);

      -- We need to convert the shipment line uom to the primary uom
      -- and the purchasing uom.

      --dbms_output.put_line('Get CUM Qty: X_qty_rcv_prim'||X_qty_received_primary);

      X_progress := '020';

      SELECT uom_code
      INTO   X_transaction_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = X_unit_of_measure;

      X_progress := '030';

      --dbms_output.put_line('purchasing unit of meas'||X_purchasing_unit_of_measure);
      SELECT uom_code
      INTO   X_purchasing_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = X_purchasing_unit_of_measure;

      --dbms_output.put_line('puom code'||X_purchasing_uom_code);

      X_progress := '040';

      SELECT uom_code
      INTO   X_primary_uom_code
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = X_primary_unit_of_measure;

      X_progress := '050';

      inv_convert.inv_um_conversion(X_transaction_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_conversion_rate);

      X_qty_received_primary := X_conversion_rate * X_quantity_received;

      --dbms_output.put_line('Qty rcv primary'||to_char(X_qty_received_primary));
      --dbms_output.put_line('Get CUM Qty: X_conversion_rate'||X_conversion_rate);

      X_progress := '060';

      --dbms_output.put_line('Get CUM Qty: purch_uom'||X_purchasing_uom_code);
      --dbms_output.put_line('Get CUM Qty: Primary_uom'||X_primary_uom_code);

      inv_convert.inv_um_conversion(X_primary_uom_code,
				    X_purchasing_uom_code,
				    X_item_id, X_uom_rate);

      --dbms_output.put_line('Get CUM Qty: X_uom_rate'||X_uom_rate);

      X_qty_received_purchasing := X_uom_rate * X_qty_received_primary;

      --dbms_output.put_line('X_qty_rcv_purch'||to_char(X_qty_received_purchasing));

      X_tot_received_primary := nvl(X_tot_received_primary,0) +
				nvl(X_qty_received_primary,0);

      X_tot_received_purch := nvl(X_tot_received_purch,0) +
			      nvl(X_qty_received_purchasing,0);

      END LOOP;

      CLOSE C3;

/* Bug#2559847 Changed the Where clause of the below SQL from
** ccp.cum_period_end_date = x_cum_period_end  to
** ccp.cum_period_end_date >= x_cum_period_end. This is done to find a cum
** period record.The variable x_cum_period_end that gets passed to this
** procedure is set to the horizon_end_date if the horizon_end_date is less
** than cum period end date. In that case,by equating the x_cum_period_end,
** will not find the record. Hence It has to be >= x_cum_period_end
*/

      select sum(adjustment_quantity)
      into   x_adjustment_quantity
      from   chv_cum_adjustments cha,
             chv_cum_periods ccp
      where  cha.organization_id = X_organization_id
      and    cha.vendor_id = X_vendor_id
      and    cha.vendor_site_id = X_vendor_site_id
      and    cha.item_id = X_item_id
      and    cha.cum_period_id = ccp.cum_period_id
      and    ccp.cum_period_start_date = X_cum_period_start
      and    ccp.cum_period_end_date  >= X_cum_period_end
      and    ccp.organization_id       = cha.organization_id;

      X_tot_received_purch := nvl(X_tot_received_purch,0) +
			           nvl(X_adjustment_quantity,0);


      --dbms_output.put_line('purch+adjust received'||to_char(X_tot_received_purch));

      -- This will happen if there are no rcv txn's, but an adjustment
      IF (X_primary_uom_code is null) THEN

        SELECT primary_uom_code
	INTO   X_primary_uom_code
        FROM   mtl_system_items
        WHERE  inventory_item_id = X_item_id
        AND    organization_id = X_organization_id;

        --dbms_output.put_line('primary with no rcv txn'||X_primary_uom_code);


        SELECT uom_code
        INTO   X_purchasing_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = X_purchasing_unit_of_measure;

      END IF;

      --dbms_output.put_line('purchasing uom'||X_purchasing_uom_code);

      inv_convert.inv_um_conversion(X_purchasing_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_uom_rate);

      --dbms_output.put_line('uom rate'||to_char(X_uom_rate));

      X_tot_received_primary := X_tot_received_purch * X_uom_rate;

     --dbms_output.put_line('prim+adjust received'||to_char(X_tot_received_primary));

     X_qty_received_purchasing := X_tot_received_purch;
     X_qty_received_primary := X_tot_received_primary;

   ELSE

      --dbms_output.put_line('Get CUM Qty: before open');

      X_progress := '070';

      -- Open the cursor that gets all of the shipment lines that
      -- match the vendor, vendor site, org, item, in the cum period
      OPEN C;

      -- For each of these shipment lines, get each of the rtvs
      -- against the shipment line.
      LOOP

	 --dbms_output.put_line('Get CUM Qty: before fetch');
	 --dbms_output.put_Line('Get CUM Qty: Item'||X_item_id);
         --dbms_output.put_line('Get CUM Qty: Vendor'||X_vendor_id);
         --dbms_output.put_line('Get CUM Qty: Site'||X_vendor_site_id);
	 --dbms_output.put_line('Get CUM Qty: Org'||X_organization_id);
         --dbms_output.put_line('Get CUM Qty: Start'||X_cum_period_start);
         --dbms_output.put_line('Get CUM Qty: End'||X_cum_period_end);


         X_progress := '080';

         FETCH C INTO X_quantity_received,
		      X_unit_of_measure,
		      X_primary_unit_of_measure,
		      X_transaction_id;

         EXIT WHEN C%notfound;


	 --dbms_output.put_line('Get CUM Qty: before unit of meas check'||X_unit_of_measure||X_primary_unit_of_measure);

         --dbms_output.put_line('Get CUM Qty: TRANSACTION_ID'||X_transaction_id);

         -- Get the uom code since we only have the unit of measure.
	 -- We need to the uom code to execute uom_convert.
	 -- We CANNOT just get the primary quantity from rcv_transactions
         -- since it will not have the corrections to that quantity.
         -- The rcv_shipment line includes the quantity received +
         -- all corrects to that quantity.
         X_progress := '090';
         SELECT uom_code
         INTO   X_transaction_uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = X_unit_of_measure;

         X_progress := '100';
         SELECT uom_code
         INTO   X_primary_uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = X_primary_unit_of_measure;

         X_progress := '110';
         SELECT uom_code
         INTO   X_purchasing_uom_code
         FROM   mtl_units_of_measure
         WHERE  unit_of_measure = X_purchasing_unit_of_measure;

         --dbms_output.put_line('Get CUM Qty: before uom convert call');

         X_progress := '120';
         inv_convert.inv_um_conversion(X_transaction_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_conversion_rate);

         -- Calculate the qty received in the primary unit of measure.
         X_qty_received_primary := X_conversion_rate * X_quantity_received;

         --dbms_output.put_line('Get CUM Qty: qty rcv'||X_qty_received_primary);

	 X_total_qty_received_primary := nvl(X_total_qty_received_primary,0) +
			nvl(X_qty_received_primary,0);

	 --dbms_output.put_line('Get CUM Qty: top total'||X_total_qty_received_primary);

         --dbms_output.put_line('Get CUM Qty: before open of c2');

         X_progress := '130';

         -- Open the cursor to get the rtv's against the shipment line/
	 -- transaction we are working with.
	 OPEN C2;

	 -- For each rtv transaction get the corrections against it.
         LOOP

	    --dbms_output.put_line('Get CUM Qty: before c2 fetch');

            X_progress := '140';

            FETCH C2 INTO X_rtv_primary_quantity,
			  X_rtv_transaction_id;

	    EXIT WHEN C2%notfound;

	    --dbms_output.put_line('Get CUM Qty: before sum');


	    X_total_qty_received_primary := nvl(X_total_qty_received_primary,0)
			 + nvl(X_rtv_primary_quantity,0);

	    --dbms_output.put_line('Get CUM Qty: middle total'||X_total_qty_received_primary);

	    BEGIN

               X_progress := '150';

               SELECT sum(rct.primary_quantity)
               INTO   X_corrtv_primary_quantity
	       FROM   rcv_transactions rct
	       WHERE  rct.transaction_type = 'CORRECT'
	       AND    rct.parent_transaction_id = X_rtv_transaction_id;

	    EXCEPTION
	      WHEN NO_DATA_FOUND then null;
	      WHEN OTHERS then raise;

            END;

	    X_total_qty_received_primary := nvl(X_total_qty_received_primary,0)
		+ nvl(X_corrtv_primary_quantity,0);

	    --dbms_output.put_line('Get CUM Qty: qtyrcvprim'||X_qty_received_primary);
            --dbms_output.put_line('Get CUM Qty: qtyrtvprim'||X_rtv_primary_quantity);
            --dbms_output.put_line('Get CUM Qty: qtyrtvcorprim'||X_corrtv_primary_quantity);

	    --dbms_output.put_line('Get CUM Qty: inner total'||X_total_qty_received_primary);

         END LOOP;

         CLOSE C2;

      END LOOP;

      CLOSE C;

      --dbms_output.put_line('Get CUM Qty: qty rcv'||X_qty_received_primary);
      --dbms_output.put_line('Get CUM Qty: total'||X_total_qty_received_primary);

      X_qty_received_primary  := x_total_qty_received_primary;

      X_progress := '160';
      inv_convert.inv_um_conversion(X_primary_uom_code,
				    X_purchasing_uom_code,
				    X_item_id, X_conversion_rate);

      X_qty_received_purchasing :=
		round((x_qty_received_primary * X_conversion_rate), 5);

/* Bug#2559847 Changed the Where clause of the below SQL from
** ccp.cum_period_end_date = x_cum_period_end  to
** ccp.cum_period_end_date >= x_cum_period_end. This is done to find a cum
** period record.The variable x_cum_period_end that gets passed to this
** procedure is set to the horizon_end_date if the horizon_end_date is less
** than cum period end date. In that case,by equating the x_cum_period_end,
** will not find the record. Hence It has to be >= x_cum_period_end
*/
      select sum(adjustment_quantity)
      into   x_adjustment_quantity
      from   chv_cum_adjustments cha,
             chv_cum_periods ccp
      where  cha.organization_id = X_organization_id
      and    cha.vendor_id = X_vendor_id
      and    cha.vendor_site_id = X_vendor_site_id
      and    cha.item_id = X_item_id
      and    cha.cum_period_id = ccp.cum_period_id
      and    ccp.cum_period_start_date = X_cum_period_start
      and    ccp.cum_period_end_date  >= X_cum_period_end
      and    ccp.organization_id       = cha.organization_id;

      X_qty_received_purchasing := nvl(X_qty_received_purchasing,0) +
			           nvl(X_adjustment_quantity,0);


      -- This will happen if there are no rcv txn's, but an adjustment
      IF (X_primary_uom_code is null) THEN

        SELECT primary_uom_code
	INTO   X_primary_uom_code
        FROM   mtl_system_items
        WHERE  inventory_item_id = X_item_id
        AND    organization_id = X_organization_id;

        --dbms_output.put_line('primary with no rcv txn'||X_primary_uom_code);


        SELECT uom_code
        INTO   X_purchasing_uom_code
        FROM   mtl_units_of_measure
        WHERE  unit_of_measure = X_purchasing_unit_of_measure;

      END IF;

      inv_convert.inv_um_conversion(X_purchasing_uom_code,
				    X_primary_uom_code,
				    X_item_id, X_uom_rate);

      X_qty_received_primary := X_qty_received_purchasing * X_uom_rate;


   END IF;

   EXCEPTION
     WHEN OTHERS THEN
        po_message_s.sql_error('get_cum_qty_received', X_progress, sqlcode);
	raise;

END get_cum_qty_received;

END CHV_CUM_PERIODS_S1;

/
