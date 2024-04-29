--------------------------------------------------------
--  DDL for Package Body RCV_INT_ORG_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INT_ORG_TRANSFER" AS
/* $Header: RCVIOTFB.pls 120.8.12010000.8 2010/11/23 11:03:58 sadibhat ship $*/
   g_asn_debug VARCHAR2(1) :=  asn_debug.is_debug_on; -- Bug 9152790
   x_progress  VARCHAR2(3);
   e_validation_error  EXCEPTION;
   PROCEDURE derive_int_org_rcv_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      x_progress  := '000';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter int_org_rcv line');
      END IF;

      -- 1) derive ship to org info
      rcv_roi_transaction.derive_ship_to_org_info(x_cascaded_table,
                                                  n,
                                                  x_header_record
                                                 );
      x_progress  := '002';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('x_progress ' || x_progress);
      END IF;

      x_progress  := '010';
      -- 5) derive item info
      rcv_roi_transaction.derive_item_info(x_cascaded_table, n);
      x_progress  := '015';
      rcv_roi_header_common.derive_uom_info(x_cascaded_table, n);
      -- 6) derive substitute item info
      rcv_roi_transaction.derive_substitute_item_info(x_cascaded_table, n);
      x_progress  := '020';
      -- 8) derive from org info
      rcv_roi_transaction.derive_from_org_info(x_cascaded_table, n);
      x_progress  := '035';
      -- 12) derive routing header info
      rcv_roi_transaction.derive_routing_header_info(x_cascaded_table, n);
      x_progress  := '070';
      asn_debug.put_line('progress in IOrcv : x_progress = ' || x_progress);
      -- derive auto transact code
      rcv_roi_transaction.derive_auto_transact_code(x_cascaded_table, n);
      asn_debug.put_line('progress in IOrcv : before derive qty');
      -- quantity > 0
      derive_int_org_rcv_line_qty(x_cascaded_table,
                                  n,
                                  temp_cascaded_table
                                 );
   END derive_int_org_rcv_line;

   PROCEDURE derive_int_org_rcv_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
      -- x_include_closed_po varchar2(1);   -- bug 1887728

      CURSOR shipments(
         v_shipment_header_id NUMBER,
--         v_shipment_num       VARCHAR2, --Bugfix 5201151
         v_document_line_num  NUMBER,
         v_item_id            NUMBER,
         v_ship_to_org_id     NUMBER,
         v_ship_from_org_id   NUMBER,
	 v_shipment_line_id   NUMBER -- Bug 10257814
      ) IS
         SELECT rsh.shipment_header_id shipment_header_id,
                rsh.shipment_num shipment_num,
                rsl.shipment_line_id shipment_line_id,
                rsl.item_id item_id,
                rsl.item_description item_description,
                rsl.to_organization_id to_organization_id,
                rsl.from_organization_id from_organization_id,
                rsl.routing_header_id routing_header_id,
                rsl.category_id category_id,
                rsh.currency_code currency_code,
                rsh.conversion_rate currency_conversion_rate,
                rsh.conversion_rate_type currency_conversion_type,
                rsh.conversion_date currency_conversion_date,
                rsl.to_subinventory to_subinventory,
                rsl.ship_to_location_id ship_to_location_id,
                rsl.deliver_to_location_id deliver_to_location_id,
                rsl.deliver_to_person_id deliver_to_person_id,
                rsl.ussgl_transaction_code ussgl_transaction_code,
                rsl.destination_type_code destination_type_code,
                rsl.destination_context destination_context,
                rsl.unit_of_measure unit_of_measure,
                rsl.primary_unit_of_measure primary_unit_of_measure
         FROM   rcv_shipment_headers rsh,
                rcv_shipment_lines rsl
-- Following 2 lines are commented out for Bugfix 5201151
--         WHERE  rsh.shipment_header_id = NVL(v_shipment_header_id, rsh.shipment_header_id)
--         AND    NVL(rsh.shipment_num, '0') = NVL(v_shipment_num, NVL(rsh.shipment_num, '0'))
         WHERE  rsh.shipment_header_id = v_shipment_header_id   -- Bugfix 5201151
         AND    rsl.shipment_header_id = rsh.shipment_header_id
         AND    NVL(rsl.item_id, 0) = NVL(v_item_id, NVL(rsl.item_id, 0))
         AND    rsl.line_num = NVL(v_document_line_num, rsl.line_num)
         AND    rsl.to_organization_id = NVL(v_ship_to_org_id, rsl.to_organization_id)
         AND    rsl.from_organization_id = NVL(v_ship_from_org_id, rsl.from_organization_id)
         AND    (NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'FULLY RECEIVED')
         AND    rsh.receipt_source_code = 'INVENTORY'
	 AND    rsl.shipment_line_id = NVL(v_shipment_line_id, rsl.shipment_line_id); -- Bug 10257814;

      CURSOR count_shipments(
         v_shipment_header_id NUMBER,
--         v_shipment_num       VARCHAR2,  -- Bugfix 5201151
         v_document_line_num  VARCHAR,
         v_item_id            NUMBER,
         v_ship_to_org_id     NUMBER,
         v_ship_from_org_id   NUMBER,
	 v_shipment_line_id   NUMBER -- Bug 10257814
      ) IS
         SELECT COUNT(*) AS line_count
         FROM   rcv_shipment_headers rsh,
                rcv_shipment_lines rsl
-- Following 2 lines are commented out for Bugfix 5201151
--         WHERE  rsh.shipment_header_id = NVL(v_shipment_header_id, rsh.shipment_header_id)
--         AND    NVL(rsh.shipment_num, '0') = NVL(v_shipment_num, NVL(rsh.shipment_num, '0'))
         WHERE  rsh.shipment_header_id = v_shipment_header_id   -- Bugfix 5201151
         AND    rsl.shipment_header_id = rsh.shipment_header_id
         AND    NVL(rsl.item_id, 0) = NVL(v_item_id, NVL(rsl.item_id, 0))
         AND    rsl.line_num = NVL(v_document_line_num, rsl.line_num)
         AND    rsl.to_organization_id = NVL(v_ship_to_org_id, rsl.to_organization_id)
         AND    rsl.from_organization_id = NVL(v_ship_from_org_id, rsl.from_organization_id)
         AND    (NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'FULLY RECEIVED')
         AND    rsh.receipt_source_code = 'INVENTORY'
	 AND    rsl.shipment_line_id = NVL(v_shipment_line_id, rsl.shipment_line_id); -- Bug 10257814;

      x_shipmentrec                shipments%ROWTYPE;
      x_countshipmentrec           count_shipments%ROWTYPE;
      x_record_count               NUMBER                                          := 0;
      x_remaining_quantity         NUMBER                                          := 0;
      x_remaining_qty_po_uom       NUMBER                                          := 0;
      x_progress                   VARCHAR2(3);
      x_to_organization_code       VARCHAR2(5);
      x_converted_trx_qty          NUMBER                                          := 0;
      transaction_ok               BOOLEAN                                         := FALSE;
      rows_fetched                 NUMBER                                          := 0;
      x_tolerable_qty              NUMBER                                          := 0;
      x_first_trans                BOOLEAN                                         := TRUE;
      x_sysdate                    DATE                                            := SYSDATE;
      current_n                    BINARY_INTEGER                                  := 0;
      insert_into_table            BOOLEAN                                         := FALSE;
      x_qty_rcv_exception_code     po_line_locations.qty_rcv_exception_code%TYPE;
      tax_amount_factor            NUMBER;
      x_temp_already_allocated_qty NUMBER;
      x_remaining_qty_rsl_uom      NUMBER;
      lastrecord                   BOOLEAN                                         := FALSE;
      already_allocated_qty        NUMBER                                          := 0;
      x_item_id                    NUMBER;
      x_ship_to_organization_id    NUMBER;
      x_sob_id                     NUMBER                                          := NULL;
      x_secondary_available_qty    NUMBER                                          := 0;
      x_full_name                  VARCHAR2(240)                                   := NULL; -- Bug 2392074
      l_shipment_header_id         rcv_shipment_headers.shipment_header_id%TYPE; -- Bugfix 5201151
      --Bug 8631613
      l_temp_qty NUMBER;
      l_pri_temp_qty NUMBER;
      --Bug 8631613
   BEGIN
--check line quanity > 0
      x_progress                      := '097';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('inside line qty calculation of int org rcv');
         asn_debug.put_line('x_progress ' || x_progress);
      END IF;

      IF x_cascaded_table(n).error_status NOT IN('S', 'W') THEN
         RETURN;
      END IF;

      IF x_cascaded_table(n).quantity <= 0 THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('quantity is <= zero. cascade will fail');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_num);
         rcv_error_pkg.log_interface_error('QUANTITY');
      END IF; --} end qty > 0 check

      x_progress                      := '098';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('x_progress ' || x_progress);
         asn_debug.put_line('the shipment info is = ' || TO_CHAR(x_cascaded_table(n).shipment_header_id) || ' num = ' || x_cascaded_table(n).shipment_num);
      END IF;

      -- as long as shipment num or shipment header id is specified we can continue
      IF (    x_cascaded_table(n).shipment_header_id IS NULL
          AND x_cascaded_table(n).shipment_num IS NULL) THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no shipment num/shipment header specified ');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_IOT_NO_SHIP_INFO', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('SHIPMENT_NUM', x_cascaded_table(n).shipment_num);
         rcv_error_pkg.log_interface_error('SHIPMENT_NUM');
      END IF; -- } of (asn quantity_shipped was valid)


              -- copy record from main table to temp table

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('copy record from main table to temp table');
      END IF;

      current_n                       := 1;
      temp_cascaded_table(current_n)  := x_cascaded_table(n);

      -- Bugfix 5201151
      IF (    x_cascaded_table(n).shipment_header_id IS NULL
          AND x_cascaded_table(n).shipment_num IS NOT NULL) THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Shipment header is not provided hence deriving shipment header id for shipment num ' || x_cascaded_table(n).shipment_num );
         END IF;

/*  Bug:6313315
     Added where clause condition rsh.receipt_source_code = 'INVENTORY'.
     As we can have same shipment number for ISO shipment and Inter org shipment,
     we need to filter the shipment record by receipt_source_code.
 */
         BEGIN
	 	SELECT	distinct rsh.shipment_header_id
	 	INTO	l_shipment_header_id
	 	FROM	rcv_shipment_headers rsh,
			rcv_shipment_lines rsl
	 	WHERE	shipment_num = temp_cascaded_table(current_n).shipment_num
		AND	rsh.shipment_header_id = rsl.shipment_header_id
                AND     rsl.to_organization_id = NVL(temp_cascaded_table(current_n).to_organization_id, to_organization_id)
                AND     rsl.from_organization_id = NVL(temp_cascaded_table(current_n).from_organization_id, from_organization_id)
                AND     rsh.receipt_source_code = 'INVENTORY';--Bug: 6313315

		 IF (g_asn_debug = 'Y') THEN
		    asn_debug.put_line('Shipment header = ' || l_shipment_header_id );
		 END IF;

	 EXCEPTION
	 	WHEN	NO_DATA_FOUND
	 	THEN
			 x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
			 rcv_error_pkg.set_error_message('RCV_IOT_NO_SHIP_INFO', x_cascaded_table(n).error_message);
			 rcv_error_pkg.set_token('SHIPMENT_NUM', temp_cascaded_table(current_n).shipment_num);
			 rcv_error_pkg.log_interface_error('SHIPMENT_NUM');

			 IF (g_asn_debug = 'Y') THEN
			    asn_debug.put_line(TO_CHAR(n));
			    asn_debug.put_line('No shipment_header_id found for shipment_num = ' || temp_cascaded_table(current_n).shipment_num );
			    asn_debug.put_line('error ' || x_progress);
			 END IF;
		WHEN	OTHERS
		THEN
			 x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
			 rcv_error_pkg.set_sql_error_message('derive_int_org_rcv_line_qty', x_progress);
			 x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
			 rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');

			 IF (g_asn_debug = 'Y') THEN
			    asn_debug.put_line(TO_CHAR(n));
			    asn_debug.put_line('Error while selecting shipment_header_id for shipment_num = ' || temp_cascaded_table(current_n).shipment_num );
			    asn_debug.put_line(sqlerrm);
			    asn_debug.put_line('error ' || x_progress);
			 END IF;
	 END;
      ELSE
         l_shipment_header_id := temp_cascaded_table(current_n).shipment_header_id;
      END IF; -- } deriving shipment_header_id if it NULL from shipment_num
      -- End of code for Bugfix 5201151

      -- get all rows which meet this condition
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('get all rows which meet this condition');
         asn_debug.put_line('transaction type = ' || x_cascaded_table(n).transaction_type);
         asn_debug.put_line('auto transact code = ' || x_cascaded_table(n).auto_transact_code);
      END IF;

      --{ open the cursors
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('open shipment records');
         asn_debug.put_line('shipment header id ' || TO_CHAR(temp_cascaded_table(current_n).shipment_header_id));
         asn_debug.put_line('item id ' || TO_CHAR(temp_cascaded_table(current_n).item_id));
         asn_debug.put_line('shipment line num ' || TO_CHAR(temp_cascaded_table(current_n).document_line_num));
         asn_debug.put_line('ship to organization id ' || TO_CHAR(temp_cascaded_table(current_n).to_organization_id));
         asn_debug.put_line('from org id ' || TO_CHAR(temp_cascaded_table(current_n).from_organization_id));
	 asn_debug.put_line('shipment line id ' || TO_CHAR(temp_cascaded_table(current_n).shipment_line_id)); -- Bug 10257814
         asn_debug.put_line('proceed to open cursor');
      END IF;

      OPEN shipments(-- temp_cascaded_table(current_n).shipment_header_id, -- Bugfix 5201151
                           -- temp_cascaded_table(current_n).shipment_num, -- Bugfix 5201151
                     l_shipment_header_id,                                 -- Bugfix 5201151
                     temp_cascaded_table(current_n).document_line_num,
                     temp_cascaded_table(current_n).item_id,
                     temp_cascaded_table(current_n).to_organization_id,
                     temp_cascaded_table(current_n).from_organization_id,
		      temp_cascaded_table(current_n).shipment_line_id -- Bug 10257814
                    );
      -- count_shipments just gets the count of rows found in shipments

      OPEN count_shipments(-- temp_cascaded_table(current_n).shipment_header_id, -- Bugfix 5201151
                           -- temp_cascaded_table(current_n).shipment_num,       -- Bugfix 5201151
                           l_shipment_header_id,                                 -- Bugfix 5201151
                           temp_cascaded_table(current_n).document_line_num,
                           temp_cascaded_table(current_n).item_id,
                           temp_cascaded_table(current_n).to_organization_id,
                           temp_cascaded_table(current_n).from_organization_id,
			   temp_cascaded_table(current_n).shipment_line_id -- Bug 10257814
                          );

      -- }

      -- assign shipped quantity to remaining quantity
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('assign shipped quantity to remaining quantity');
         asn_debug.put_line('pointer in temp_cascade ' || TO_CHAR(current_n));
      END IF;

      x_remaining_quantity            := temp_cascaded_table(current_n).quantity;
      x_remaining_qty_po_uom          := 0;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('have assigned the quantity');
      END IF;

      -- calculate tax_amount_factor for calculating tax_amount for
      -- each cascaded line

      IF NVL(temp_cascaded_table(current_n).tax_amount, 0) <> 0 THEN
         tax_amount_factor  := temp_cascaded_table(current_n).tax_amount / x_remaining_quantity;
      ELSE
         tax_amount_factor  := 0;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('tax factor ' || TO_CHAR(tax_amount_factor));
         asn_debug.put_line('shipped quantity : ' || TO_CHAR(x_remaining_quantity));
      END IF;

      x_first_trans                   := TRUE;
      transaction_ok                  := FALSE;
      /*
      ** get the count of the number of records depending on the
      */
      FETCH count_shipments INTO x_countshipmentrec;
      x_record_count                  := x_countshipmentrec.line_count;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before starting cascade');
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('record count = ' || x_record_count);
      END IF;

      LOOP --{ over the count of shipment records obtained
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('remaining quantity asn uom ' || TO_CHAR(x_remaining_quantity));
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('open shipments and fetch');
         END IF;

         /*
         ** fetch the cursor
         */
         --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('fetching shipments cursor');
         END IF;

         FETCH shipments INTO x_shipmentrec;

         /*
         ** check if this is the last record
         */
         IF (shipments%NOTFOUND) THEN
            lastrecord  := TRUE;
         END IF;

         rows_fetched             := shipments%ROWCOUNT;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('shipment rows fetched ' || TO_CHAR(rows_fetched));
         END IF;

         -- }


         IF (   lastrecord
             OR x_remaining_quantity <= 0) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('hit exit condition');
            END IF;

            IF NOT x_first_trans THEN
               -- x_first_trans has been reset which means some cascade has
               -- happened. otherwise current_n = 1
               current_n  := current_n - 1;
            END IF;

            -- do the tolerance act here
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('temp table pointer ' || TO_CHAR(current_n));
               asn_debug.put_line('check which condition has occured');
            END IF;

            -- lastrecord...we have run out of rows and we still have quantity to allocate
            IF x_remaining_quantity > 0 THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('There is quantity remaining');
                  asn_debug.put_line('Need to check qty tolerances');
               END IF;

               IF     rows_fetched > 0
                  AND NOT x_first_trans THEN --{
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(' in inter org transfer rcv Extra Quantity ' || TO_CHAR(x_remaining_quantity));
                  END IF;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('delete the temp table ');
                  END IF;

                  IF temp_cascaded_table.COUNT > 0 THEN
                     FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                        temp_cascaded_table.DELETE(i);
                     END LOOP;
                  END IF;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('mark the actual table with error status');
                     asn_debug.put_line('Error Status ' || x_cascaded_table(n).error_status);
                     asn_debug.put_line('Error message ' || x_cascaded_table(n).error_message);
                  END IF;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Need to insert a row into po_interface_errors for transfer');
                  END IF;

                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.set_error_message('RCV_SHIP_QTY_OVER_TOLERANCE', x_cascaded_table(n).error_message);
                  rcv_error_pkg.set_token('QTY_A', x_cascaded_table(n).quantity);
                  rcv_error_pkg.set_token('QTY_B', x_cascaded_table(n).quantity - x_remaining_quantity);
                  rcv_error_pkg.log_interface_error('QUANTITY');
               ELSE --}{ else for rows fetched = 0 OR x_first_trans = true
                  IF rows_fetched = 0 THEN
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No rows were retrieved from cursor.');
                     END IF;
                  ELSIF x_first_trans THEN
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No rows were cascaded');
                     END IF;
                  END IF;

                  -- 1) should we check to see why no rows were fetched ??
                  --2) should we error out the row in rti if another check proved
                  -- there are rows in rsl for this rti row

                  -- Delete the temp_cascaded_table just to be sure
                  IF temp_cascaded_table.COUNT > 0 THEN
                     FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                        temp_cascaded_table.DELETE(i);
                     END LOOP;
                  END IF;

                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.set_error_message('PO_CHNG_WRONG_DOC_TYPE', x_cascaded_table(n).error_message);
                  rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID');
               END IF; --} ends row fetched > 0 and not first transaction

                       -- all the rows in the temp cascaded table
                       -- will be deleted
                       -- as we cannot over/under receive against a inter-org transfer receive
            ELSE -- }{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Remaining  UOM quantity is zero ' || TO_CHAR(x_remaining_quantity));
                  asn_debug.put_line('Return the cascaded rows back to the calling procedure');
               END IF;
            END IF; --} ends the check for whether last record has been reached

                    -- close cursors

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('close cursors shipments, count_shipments');
            END IF;

            IF shipments%ISOPEN THEN
               CLOSE shipments;
            END IF;

            IF count_shipments%ISOPEN THEN
               CLOSE count_shipments;
            END IF;

            EXIT;
         END IF; --} matches lastrecord or x_remaining_quantity <= 0

                 -- eliminate the row if it fails the date check

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('count in temp_cascade_table : ' || TO_CHAR(temp_cascaded_table.COUNT));
            asn_debug.put_line('cursor record ' || TO_CHAR(rows_fetched));
            asn_debug.put_line('int org rcv : calling get available qty');
         END IF;

         -- removed rcv_transactions_interface_sv.check_date_tolerance;
         -- removed check shipto_location enforcement
         -- removed check receipt days exception code

         --{
            --matches shipmentdistributionrec.receipt_days_exception_code = none
                -- we will do it for the first record only. subsequent records in the
                -- temp_table are copies of the previous one
         IF     (x_first_trans)
            AND temp_cascaded_table(current_n).item_id IS NULL THEN --{
            temp_cascaded_table(current_n).item_id                  := x_shipmentrec.item_id;
            temp_cascaded_table(current_n).primary_unit_of_measure  := x_shipmentrec.primary_unit_of_measure;
         END IF; --}

         insert_into_table        := FALSE;
         already_allocated_qty    := 0;

         /*
         ** get the available quantity for the shipment line (rsl)
         ** that is available for allocation by this interface transaction
         ** the available qty can only be found from rsl
         ** the else condition should never arise : confirm from priya ??
         */
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('shipment line id : ' || TO_CHAR(x_shipmentrec.shipment_line_id));
            asn_debug.put_line('uom ' || x_shipmentrec.unit_of_measure);
            asn_debug.put_line('converted trx qty : ' || TO_CHAR(x_converted_trx_qty));
            asn_debug.put_line('tolerable qty : ' || TO_CHAR(x_tolerable_qty));
            asn_debug.put_line('receipt source code' || x_cascaded_table(n).receipt_source_code);
         END IF;

         IF (    x_cascaded_table(n).transaction_type = 'RECEIVE'
             AND NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') IN('RECEIVE', 'DELIVER')) THEN --{
            /*bug# 1548597 */
            rcv_quantities_s.get_available_quantity('RECEIVE',
                                                    x_shipmentrec.shipment_line_id,
                                                    x_cascaded_table(n).receipt_source_code, -- ?? specifying the rti receipt source code for now
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    x_converted_trx_qty,
                                                    x_tolerable_qty,
                                                    x_shipmentrec.unit_of_measure, -- this is rsl.unit_of_measure
                                                    x_secondary_available_qty
                                                   );

            -- if qtys have already been allocated for this item during
                 -- a cascade process which has not been written to the db yet, we need to
                 -- decrement it from the total available quantity
                 -- we traverse the actual pl/sql table and accumulate the quantity by matching the
                 -- item_id

            IF n > 1 THEN -- we will do this for all rows except the 1st
               FOR i IN 1 ..(n - 1) LOOP
                  IF x_cascaded_table(i).item_id = x_shipmentrec.item_id THEN
                     x_temp_already_allocated_qty  := rcv_roi_transaction.convert_into_correct_qty(x_cascaded_table(i).quantity,
                                                                                                   x_cascaded_table(i).unit_of_measure,
                                                                                                   x_cascaded_table(i).item_id,
                                                                                                   x_shipmentrec.unit_of_measure
                                                                                                  );
                     already_allocated_qty         := already_allocated_qty + x_temp_already_allocated_qty;
                  END IF;
               END LOOP;
            END IF;
         END IF; --}

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('after call to get_available quantity');
            asn_debug.put_line('available quantity ' || TO_CHAR(x_converted_trx_qty));
            asn_debug.put_line('tolerable quantity ' || TO_CHAR(x_tolerable_qty));
            asn_debug.put_line('pointer to temp table ' || TO_CHAR(current_n));
            asn_debug.put_line(' Already allocated qty now in terms of shipment rec uom is ' || already_allocated_qty);
         END IF;

         -- if qty has already been allocated then reduce available and tolerable
         -- qty by the allocated amount

         IF NVL(already_allocated_qty, 0) > 0 THEN --{
            x_converted_trx_qty  := x_converted_trx_qty - already_allocated_qty;
            x_tolerable_qty      := x_tolerable_qty - already_allocated_qty;

            IF x_converted_trx_qty < 0 THEN
               x_converted_trx_qty  := 0;
            END IF;

            IF x_tolerable_qty < 0 THEN
               x_tolerable_qty  := 0;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('have some allocated quantity. will reduce qty');
               asn_debug.put_line('allocated qty ' || TO_CHAR(already_allocated_qty));
               asn_debug.put_line('after reducing by allocated qty');
               asn_debug.put_line('available quantity ' || TO_CHAR(x_converted_trx_qty));
               asn_debug.put_line('tolerable quantity ' || TO_CHAR(x_tolerable_qty));
               asn_debug.put_line('pointer to temp table ' || TO_CHAR(current_n));
            END IF;
         END IF; --}

                 -- we can use the first record since the item_id and uom are not going to change
                     -- check that we can convert between asn-> po  uom
                     --                                   po -> asn uom
                     --                                   po -> primary uom
                     -- if any of the conversions fail then we cannot use that record

         x_remaining_qty_rsl_uom  := 0; -- initialize
         x_remaining_qty_rsl_uom  := rcv_roi_transaction.convert_into_correct_qty(x_remaining_quantity,
                                                                                  temp_cascaded_table(1).unit_of_measure,
                                                                                  temp_cascaded_table(1).item_id,
                                                                                  x_shipmentrec.unit_of_measure
                                                                                 );

         IF x_remaining_qty_rsl_uom = 0 THEN --{   -- no point continuing
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('need an error message in the interface tables');
               asn_debug.put_line('cannot interconvert between diff uoms');
            END IF;
         ELSE -- we have converted the qty between uoms succesfully } {
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('current item id ' || TO_CHAR(temp_cascaded_table(1).item_id));
               asn_debug.put_line('current asn quantity ' || TO_CHAR(x_remaining_quantity));
               asn_debug.put_line('current asn uom ' || temp_cascaded_table(1).unit_of_measure);
               asn_debug.put_line('converted rsl uom quantity ' || TO_CHAR(x_remaining_qty_rsl_uom));
            END IF;

            IF x_converted_trx_qty > 0 THEN --{
               IF (x_converted_trx_qty < x_remaining_qty_rsl_uom) THEN -- compare like uoms {
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('total qty available to be received is less than remaining qty');
                  END IF;

                  x_remaining_qty_rsl_uom  := x_remaining_qty_rsl_uom - x_converted_trx_qty;
                  -- change rsl uom qty to uom of first line in cascaded table so both qtys are in sync
                  x_remaining_quantity     := rcv_roi_transaction.convert_into_correct_qty(x_remaining_qty_rsl_uom,
                                                                                           x_shipmentrec.unit_of_measure,
                                                                                           temp_cascaded_table(1).item_id,
                                                                                           temp_cascaded_table(1).unit_of_measure
                                                                                          );
                  insert_into_table        := TRUE;
               ELSE --} {
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('total qty available to be received is > remaining qty ');
                  END IF;

                  x_converted_trx_qty      := x_remaining_qty_rsl_uom;
                  insert_into_table        := TRUE;
                  x_remaining_qty_rsl_uom  := 0;
                  x_remaining_quantity     := 0;
               END IF; --}
            ELSE -- no qty for this record but if last row we need it } {
               IF rows_fetched = x_record_count THEN                                  --{ last row needs to be inserted anyway
                                                     -- so that the row can be used based on qty tolerance checks
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('quantity is less then 0 but last record');
                  END IF;

                  insert_into_table    := TRUE;
                  x_converted_trx_qty  := 0;
               ELSE --} {
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('<= 0 quantity but more records in cursor');
                  END IF;

                  x_remaining_qty_po_uom  := 0; -- we may have a diff uom on the next iteration

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('we have to deal with remaining_qty > 0 and x_converted_trx_qty -ve');
                  END IF;

                  insert_into_table       := FALSE;
               END IF; --}
            END IF; --}
         END IF; --} remaining_qty_po_uom <> 0

         IF insert_into_table THEN --{
            IF (x_first_trans) THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('first time ' || TO_CHAR(current_n));
               END IF;

               x_first_trans  := FALSE;
            ELSE --} { not x_first_trans
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('next time ' || TO_CHAR(current_n));
               END IF;

               temp_cascaded_table(current_n)  := temp_cascaded_table(current_n - 1);
            END IF; --} matches x_first_transfer

                    -- source_doc_qty should be in rsl's uom

            temp_cascaded_table(current_n).source_doc_quantity         := x_converted_trx_qty; -- in rsl uom
            temp_cascaded_table(current_n).source_doc_unit_of_measure  := x_shipmentrec.unit_of_measure;

            IF (temp_cascaded_table(current_n).unit_of_measure <> x_shipmentrec.unit_of_measure) THEN
            --Bug 8631613 For some conversions residual qty. is causing issues while doing put away.
               l_temp_qty := rcv_roi_transaction.convert_into_correct_qty(x_converted_trx_qty,
                                                                          x_shipmentrec.unit_of_measure,
                                                                          temp_cascaded_table(current_n).item_id,
                                                                          temp_cascaded_table(current_n).unit_of_measure
                                                                         ); -- in asn uom

               IF ( Round(l_temp_qty,7) <> temp_cascaded_table(current_n).quantity  ) THEN
               temp_cascaded_table(current_n).quantity := l_temp_qty;
               END IF;

               /*temp_cascaded_table(current_n).quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_trx_qty,
                                                                                                        x_shipmentrec.unit_of_measure,
                                                                                                        temp_cascaded_table(current_n).item_id,
                                                                                                        temp_cascaded_table(current_n).unit_of_measure
                                                                                                       ); -- in asn uom*/
             --Bug 8631613
            ELSE
               temp_cascaded_table(current_n).quantity  := x_converted_trx_qty;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Transaction qty in terms of the transaction uom is ' || temp_cascaded_table(current_n).quantity);
            END IF;

            -- primary qty in primary uom
            IF (temp_cascaded_table(current_n).primary_unit_of_measure <> x_shipmentrec.unit_of_measure) THEN
            --Bug 8631613
               l_pri_temp_qty:=rcv_roi_transaction.convert_into_correct_qty(x_converted_trx_qty,
                                                                            x_shipmentrec.unit_of_measure,
                                                                            temp_cascaded_table(current_n).item_id,
                                                                            temp_cascaded_table(current_n).primary_unit_of_measure
                                                                           );
               IF (Round(l_pri_temp_qty,7) <> NVL(temp_cascaded_table(current_n).primary_quantity,-1)) THEN
                  temp_cascaded_table(current_n).primary_quantity := l_pri_temp_qty;
               END IF;

               /*temp_cascaded_table(current_n).primary_quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_trx_qty,
                                                                                                                x_shipmentrec.unit_of_measure,
                                                                                                                temp_cascaded_table(current_n).item_id,
                                                                                                                temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                               );*/
            ELSE
               temp_cascaded_table(current_n).primary_quantity        := x_converted_trx_qty;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Transaction qty in terms of the primary uom is ' || temp_cascaded_table(current_n).primary_quantity);
               END IF;

               temp_cascaded_table(current_n).inspection_status_code  := 'NOT INSPECTED';
               temp_cascaded_table(current_n).interface_source_code   := 'RCV';
               -- temp_cascaded_table(current_n).currency_code   := x_shipmentrec.currency_code;
               temp_cascaded_table(current_n).tax_amount              := ROUND(temp_cascaded_table(current_n).quantity * tax_amount_factor, 4);

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('current tax amount ' || TO_CHAR(temp_cascaded_table(current_n).tax_amount));
               END IF;

               -- confirm the data in rsh and rsl for the provided info
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line(   'rsl : cat '
                                     || x_shipmentrec.category_id
                                     || ' item desc '
                                     || x_shipmentrec.item_description
                                     || ' header '
                                     || x_shipmentrec.shipment_header_id
                                     || ' ship num '
                                     || x_shipmentrec.shipment_num
                                     || ' line '
                                     || x_shipmentrec.shipment_line_id);
               END IF;

               temp_cascaded_table(current_n).category_id             := x_shipmentrec.category_id;
               temp_cascaded_table(current_n).item_description        := x_shipmentrec.item_description;

               IF temp_cascaded_table(current_n).to_organization_id IS NULL THEN --{
                  temp_cascaded_table(current_n).to_organization_id  := x_shipmentrec.to_organization_id;
               END IF; --}

               IF temp_cascaded_table(current_n).from_organization_id IS NULL THEN --{
                  temp_cascaded_table(current_n).from_organization_id  := x_shipmentrec.from_organization_id;
               END IF; --}

                       -- set the shipment num/header if

               IF    temp_cascaded_table(current_n).shipment_header_id IS NULL
                  OR temp_cascaded_table(current_n).shipment_num IS NULL THEN
                  temp_cascaded_table(current_n).shipment_header_id  := x_shipmentrec.shipment_header_id;
                  temp_cascaded_table(current_n).shipment_num        := x_shipmentrec.shipment_num;
               END IF;

               -- set the shipment line id
               IF temp_cascaded_table(current_n).shipment_line_id IS NULL THEN
                  temp_cascaded_table(current_n).shipment_line_id  := x_shipmentrec.shipment_line_id;
               END IF;

               -- copy the distribution specific information only if this is a direct receipt.
               IF (   x_cascaded_table(n).transaction_type = 'DELIVER'
                   OR NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER') THEN --{
                  temp_cascaded_table(current_n).destination_type_code  := x_shipmentrec.destination_type_code;
                  temp_cascaded_table(current_n).destination_context    := x_shipmentrec.destination_type_code;

                  IF (NVL(temp_cascaded_table(current_n).deliver_to_location_id, 0) = 0) THEN
                     temp_cascaded_table(current_n).deliver_to_location_id  := x_shipmentrec.deliver_to_location_id;
                  END IF;

                  /* bug 2392074 - if the deliver_to_person mentioned in the po_distributions is
                       invalid or inactive at the time of receipt we need to clear the deliver to person,
                       as this is an optional field. */
                  IF (NVL(temp_cascaded_table(current_n).deliver_to_person_id, 0) = 0) THEN --{
                     temp_cascaded_table(current_n).deliver_to_person_id  := x_shipmentrec.deliver_to_person_id;

                     IF (temp_cascaded_table(current_n).deliver_to_person_id IS NOT NULL) THEN --{
                        BEGIN
                           SELECT NVL(MAX(hre.full_name), 'notfound')
                           INTO   x_full_name
                           FROM   hr_employees_current_v hre
                           WHERE  (   hre.inactive_date IS NULL
                                   OR hre.inactive_date > SYSDATE)
                           AND    hre.employee_id = temp_cascaded_table(current_n).deliver_to_person_id;

                           IF (x_full_name = 'notfound') THEN
                              temp_cascaded_table(current_n).deliver_to_person_id  := NULL;
                           END IF;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              temp_cascaded_table(current_n).deliver_to_person_id  := NULL;

                              IF (g_asn_debug = 'Y') THEN
                                 asn_debug.put_line('the deliver to person entered in  po is currently inactive');
                                 asn_debug.put_line(' so it is cleared off');
                              END IF;
                           WHEN OTHERS THEN
                              temp_cascaded_table(current_n).deliver_to_person_id  := NULL;

                              IF (g_asn_debug = 'Y') THEN
                                 asn_debug.put_line('some exception has occured');
                                 asn_debug.put_line('this exception is due to the po deliver to person');
                                 asn_debug.put_line('the deliver to person is optional');
                                 asn_debug.put_line('so cleared off the deliver to person');
                              END IF;
                        END;
                     END IF; --}
                  END IF; --}

                  IF (temp_cascaded_table(current_n).subinventory IS NULL) THEN
                     temp_cascaded_table(current_n).subinventory  := x_shipmentrec.to_subinventory;
                  END IF;

                  -- bug 1361786
                  IF (temp_cascaded_table(current_n).ussgl_transaction_code IS NULL) THEN
                     temp_cascaded_table(current_n).ussgl_transaction_code  := x_shipmentrec.ussgl_transaction_code;
                  END IF;
               END IF; --} matches txn not deliver

               current_n                                              := current_n + 1;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('increment pointer by 1 ' || TO_CHAR(current_n));
               END IF;
            END IF; --} matches if insert into table
         END IF; --} matches shipmentdistributionrec.receipt_days_exception_code = none
      END LOOP; --}

      IF shipments%ISOPEN THEN
         CLOSE shipments;
      END IF;

      IF count_shipments%ISOPEN THEN
         CLOSE count_shipments;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('exit derive_int_org_rcv_line_qty');
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         IF shipments%ISOPEN THEN
            CLOSE shipments;
         END IF;

         IF count_shipments%ISOPEN THEN
            CLOSE count_shipments;
         END IF;
      WHEN OTHERS THEN
         IF shipments%ISOPEN THEN
            CLOSE shipments;
         END IF;

         IF count_shipments%ISOPEN THEN
            CLOSE count_shipments;
         END IF;

         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('derive_int_org_rcv_line_qty', x_progress);
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
         rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(n));
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('error ' || x_progress);
         END IF;
   END derive_int_org_rcv_line_qty;

   PROCEDURE default_int_org_rcv_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      x_progress             VARCHAR2(3);
      x_locator_control      NUMBER;
      x_success              BOOLEAN;
      p_trx_record           rcv_roi_header_common.common_default_record_type;

      /* bug2382337:
      * Change the name of the parameters passed into the cursor
      */
      CURSOR shipments(
         v_shipment_header_id NUMBER,
         v_shipment_line_id   NUMBER
      ) IS
         SELECT rsh.shipment_header_id,
                rsh.shipment_num,
                rsl.shipment_line_id,
                rsl.item_description,
                rsl.to_organization_id,
                rsl.from_organization_id,
                rsl.routing_header_id,
                rsl.category_id,
                rsh.currency_code,
                rsh.conversion_rate currency_conversion_rate,
                rsh.conversion_rate_type currency_conversion_type,
                rsh.conversion_date currency_conversion_date,
                rsl.to_subinventory,
                rsl.ship_to_location_id
         FROM   rcv_shipment_headers rsh,
                rcv_shipment_lines rsl
         WHERE  rsh.shipment_header_id = v_shipment_header_id
         AND    rsh.shipment_header_id = rsl.shipment_header_id
         AND    rsl.shipment_line_id = v_shipment_line_id;

      default_shipment_info  shipments%ROWTYPE;
      -- X_success boolean;
      x_default_subinventory VARCHAR2(10);
      x_default_locator_id   NUMBER;
   BEGIN
      p_trx_record.destination_type_code           := x_cascaded_table(n).destination_type_code;
      p_trx_record.transaction_type                := x_cascaded_table(n).transaction_type;
      p_trx_record.processing_mode_code            := x_cascaded_table(n).processing_mode_code;
      p_trx_record.processing_status_code          := x_cascaded_table(n).processing_status_code;
      p_trx_record.transaction_status_code         := x_cascaded_table(n).transaction_status_code;
      p_trx_record.auto_transact_code              := x_cascaded_table(n).auto_transact_code;
      rcv_roi_header_common.commondefaultcode(p_trx_record);
      x_cascaded_table(n).destination_type_code    := p_trx_record.destination_type_code;
      x_cascaded_table(n).transaction_type         := p_trx_record.transaction_type;
      x_cascaded_table(n).processing_mode_code     := p_trx_record.processing_mode_code;
      x_cascaded_table(n).processing_status_code   := p_trx_record.processing_status_code;
      x_cascaded_table(n).transaction_status_code  := p_trx_record.transaction_status_code;
      x_cascaded_table(n).auto_transact_code       := p_trx_record.auto_transact_code;
      x_cascaded_table(n).destination_context      := x_cascaded_table(n).destination_type_code;

      --open the cursor
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('default_int_org_rcv : defaulting called with shipment_header =  ' || x_cascaded_table(n).shipment_header_id || ' and shipment_line = ' || x_cascaded_table(n).shipment_line_id);
      END IF;

      OPEN shipments(x_cascaded_table(n).shipment_header_id, x_cascaded_table(n).shipment_line_id);

      IF (shipments%ISOPEN) THEN
         FETCH shipments INTO default_shipment_info;
      END IF;

      IF (shipments%FOUND) THEN --{
         x_cascaded_table(n).shipment_num              := default_shipment_info.shipment_num;
         x_cascaded_table(n).item_description          := default_shipment_info.item_description;
         x_cascaded_table(n).to_organization_id        := default_shipment_info.to_organization_id;
         x_cascaded_table(n).from_organization_id      := default_shipment_info.from_organization_id;
         x_cascaded_table(n).routing_header_id         := default_shipment_info.routing_header_id;
         x_cascaded_table(n).shipment_header_id        := default_shipment_info.shipment_header_id;
         x_cascaded_table(n).shipment_line_id          := default_shipment_info.shipment_line_id;
         x_cascaded_table(n).category_id               := default_shipment_info.category_id;
         --currency defaulting
         x_cascaded_table(n).currency_code             := default_shipment_info.currency_code;
         x_cascaded_table(n).currency_conversion_rate  := default_shipment_info.currency_conversion_rate;
         x_cascaded_table(n).currency_conversion_type  := default_shipment_info.currency_conversion_type;
         x_cascaded_table(n).currency_conversion_date  := default_shipment_info.currency_conversion_date;
         --- WMS Changes
         rcv_roi_transaction.default_to_subloc_info(x_cascaded_table, n);

         -- if deliver transaction
            -- if location not entered on form => location_id and deliver_to_location_id are null
            -- if location entered on form => location_id and deliver_to_location_id are the same
         IF (   NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER'
             OR x_cascaded_table(n).transaction_type = 'DELIVER') THEN --{
            IF (    (   x_cascaded_table(n).location_id IS NOT NULL
                     OR x_cascaded_table(n).deliver_to_location_id IS NOT NULL)
                AND x_cascaded_table(n).deliver_to_location_id <> x_cascaded_table(n).location_id) THEN
               IF x_cascaded_table(n).location_id IS NULL THEN
                  x_cascaded_table(n).location_id  := x_cascaded_table(n).deliver_to_location_id;
               ELSE
                  x_cascaded_table(n).deliver_to_location_id  := x_cascaded_table(n).location_id;
               END IF;
            END IF;
         END IF; --} matches auto transact code = DELIVER

                 -- if receive transaction
                    -- location has to be entered and the location_id is always = ship_to_location_id : cannot be defaulted
                    -- deliver to location id and deliver to person id do not have to be defaulted

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('should have defaulted the location id to the ship to location id');
            asn_debug.put_line('ship_to_loc ' || x_cascaded_table(n).ship_to_location_id || ' loc ' || NVL(x_cascaded_table(n).location_id, -1) || ' txn ' || x_cascaded_table(n).transaction_type || ' txn code ' || x_cascaded_table(n).auto_transact_code);
         END IF;

         IF (    x_cascaded_table(n).transaction_type = 'RECEIVE'
             AND x_cascaded_table(n).auto_transact_code = 'RECEIVE') THEN --{
            IF (NVL(NVL(x_cascaded_table(n).location_id, x_cascaded_table(n).ship_to_location_id), -1) <> -1) THEN --{
               IF     x_cascaded_table(n).location_id IS NOT NULL
                  AND x_cascaded_table(n).ship_to_location_id IS NOT NULL THEN --{
                  x_cascaded_table(n).ship_to_location_id  := x_cascaded_table(n).location_id;
               ELSE
                  IF x_cascaded_table(n).location_id IS NULL THEN
                     x_cascaded_table(n).location_id  := x_cascaded_table(n).ship_to_location_id;
                  ELSE
                     x_cascaded_table(n).ship_to_location_id  := x_cascaded_table(n).location_id;
                  END IF;
               END IF; --}
            END IF; --}

            IF (    x_cascaded_table(n).location_id IS NULL
                AND x_cascaded_table(n).ship_to_location_id IS NULL
                AND default_shipment_info.ship_to_location_id IS NOT NULL) THEN --{
               x_cascaded_table(n).ship_to_location_id  := default_shipment_info.ship_to_location_id;
               x_cascaded_table(n).location_id          := x_cascaded_table(n).ship_to_location_id;
            END IF; --}
         END IF; --}
      END IF; --} matches shipment found

      /*
      BEGIN Comment: Bug: 4735484

      SELECT NVL(x_cascaded_table(n).use_mtl_lot, lot_control_code),
             NVL(x_cascaded_table(n).use_mtl_serial, serial_number_control_code)
      INTO   x_cascaded_table(n).use_mtl_lot,
             x_cascaded_table(n).use_mtl_serial
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = x_cascaded_table(n).item_id
      AND    mtl_system_items.organization_id = x_cascaded_table(n).to_organization_id;

      END Comment: Bug: 4735484
      */
      x_cascaded_table(n).interface_source_code    := 'RCV';

      IF (x_cascaded_table(n).source_document_code IS NULL) THEN
         x_cascaded_table(n).source_document_code  := 'INVENTORY';
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit default_int_org_rcv_line');
      END IF;

      IF shipments%ISOPEN THEN
         CLOSE shipments;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END default_int_org_rcv_line;

   PROCEDURE validate_int_org_rcv_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter validate_int_org_rcv_line');
      END IF;

      x_progress  := '000';
      rcv_roi_transaction.validate_shipment_source(x_cascaded_table, n);  /* bug9705269 */
      rcv_roi_transaction.validate_transaction_date(x_cascaded_table, n);
      rcv_roi_transaction.validate_transaction_uom(x_cascaded_table, n);
      rcv_roi_transaction.validate_item_info(x_cascaded_table, n);
      /*Bug 8671559
        Adding IF condition to ensure that the validation call for freight carriers is not made for
        Inter-Org Transfers when the values are the same at the header and transaction levels.
      */
      IF (x_cascaded_table(n).freight_carrier_code = x_header_record.header_record.freight_carrier_code) THEN
          NULL;
      ELSE
          rcv_roi_transaction.validate_freight_carrier_code(x_cascaded_table, n);
      END IF;
      /* End of fix for Bug 8671559 */
      rcv_roi_transaction.validate_dest_type(x_cascaded_table, n);

      IF (x_cascaded_table(n).ship_to_location_id IS NOT NULL) THEN
         rcv_roi_transaction.validate_ship_to_loc(x_cascaded_table, n);
      END IF;

      rcv_roi_transaction.validate_deliver_to_person(x_cascaded_table, n);
      rcv_roi_transaction.validate_routing_record(x_cascaded_table, n);
      rcv_roi_transaction.validate_deliver_to_loc(x_cascaded_table, n);
      rcv_roi_transaction.validate_subinventory(x_cascaded_table, n);
      rcv_roi_transaction.validate_locator(x_cascaded_table, n);
      rcv_roi_transaction.validate_tax_code(x_cascaded_table,
                                            n,
                                            x_header_record.header_record.asn_type
                                           );   /* Bug3454491 */
      rcv_roi_transaction.validate_country_of_origin(x_cascaded_table, n);
      /* Bug 3735972.
       * We used to call rcv_roi_transaction.validate_ref_integrity that had
       * code only for PO.
       * We now  have a similar one to validate internal orders and
       * inter-org shipments in rcv_int_org_transfer package.
      */
      rcv_int_org_transfer.validate_ref_integrity(x_cascaded_table,
                                                 n,
                                                 x_header_record
                                                );
      rcv_roi_transaction.exchange_sub_items(x_cascaded_table, n);

      /* INVCONV , introduced following call . Punit Kumar */
      rcv_roi_transaction.validate_opm_attributes(x_cascaded_table, n);

      /* end , INVCONV */


      /* If destination_type_code is inventory then we need to make
       * sure that we can correct this qty since it might have been
       * already reserved in inventory.
      */
      IF (x_cascaded_table(n).destination_type_code = 'INVENTORY') THEN --{
         rcv_roi_return.derive_inv_qty(x_cascaded_table, n);
      END IF; --}
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END validate_int_org_rcv_line;

--=======================================================================================


   PROCEDURE derive_int_org_trans_del(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_int_org_trans_del ');
      END IF;

      /* Derive the to_org_id */
      rcv_roi_transaction.derive_ship_to_org_info(x_cascaded_table,
                                                  n,
                                                  x_header_record
                                                 );

      IF (x_cascaded_table(n).unit_of_measure IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
         END IF;

         SELECT muom.uom_code
         INTO   x_cascaded_table(n).uom_code
         FROM   mtl_units_of_measure muom
         WHERE  muom.unit_of_measure = x_cascaded_table(n).unit_of_measure;
      ELSE
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('uom_code not dereived as unit_of_measure is null');
         END IF;
      END IF;

      x_progress                              := '026';

      /* Locator info derivation is done for the Receiving locators FPJ
            * project. Need to verify this with karun to see whether this is
            * needed for Transfer also.
       */
      IF (x_cascaded_table(n).transaction_type = 'TRANSFER') THEN
         asn_debug.put_line('doing ship to location /locator derivations ');
         rcv_roi_transaction.derive_location_info(x_cascaded_table, n);
         rcv_roi_transaction.derive_from_locator_id(x_cascaded_table, n); -- WMS Change
         rcv_roi_transaction.derive_to_locator_id(x_cascaded_table, n); -- WMS Change
      END IF;

      x_progress                              := '091';
      rcv_roi_transaction.derive_reason_info(x_cascaded_table, n);
      /* Auto_transact_code is null for all these transaction types */
      x_cascaded_table(n).auto_transact_code  := NULL;
      derive_trans_del_line_quantity(x_cascaded_table,
                                     n,
                                     temp_cascaded_table
                                    );
   END derive_int_org_trans_del;

   PROCEDURE default_int_org_trans_del(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      p_trx_record                  rcv_roi_header_common.common_default_record_type;

      /* 3456476.
       * We need to default inspection_status_code only for ACCEPT/REJECT
       * transactions. For others get it from their parent.
       * Removed the code that defaulted inspection_status_code to
       * NOT INSPECTED for all the transactions other than ACCEPT/REJECT.
      */
      CURSOR int_org_transfer(
         v_parent_trx_id NUMBER
      ) IS
         SELECT rt.po_revision_num,
                rsl.item_description,
                rsup.po_release_id,
                rt.location_id loc_id,
                rt.organization_id,
                rt.inspection_status_code,
                rt.routing_header_id,
                rt.currency_code,
                rt.currency_conversion_rate,
                rt.currency_conversion_type,
                rt.currency_conversion_date,
                rt.location_id,
                rsup.shipment_header_id,
                rsup.shipment_line_id,
                rsl.category_id,
                --rt.vendor_id,
                --rt.vendor_site_id,
                --rt.po_unit_price,
                --rt.movement_id,
                rt.deliver_to_person_id,
                rt.deliver_to_location_id,
                rt.subinventory,
                rt.transfer_lpn_id
         FROM   rcv_transactions rt,
                rcv_shipment_lines rsl,
                rcv_supply rsup
         WHERE  rt.transaction_id = v_parent_trx_id
         AND    rt.transaction_id = rsup.rcv_transaction_id
         AND    rsup.supply_type_code = 'RECEIVING'
         AND    rsl.shipment_line_id = rsup.shipment_line_id
         AND    rt.transaction_id = rsup.rcv_transaction_id
         AND    rt.transaction_type <> 'UNORDERED';

      CURSOR int_org_transfer_rti(
         v_parent_inter_trx_id NUMBER
      ) IS
         SELECT rti.po_revision_num,
                rti.item_description,
                rti.po_release_id,
                rti.location_id loc_id,
                rti.to_organization_id organization_id,
                rti.inspection_status_code,
                rti.routing_header_id,
                rti.currency_code,
                rti.currency_conversion_rate,
                rti.currency_conversion_type,
                rti.currency_conversion_date,
                rti.location_id,
                rti.shipment_header_id,
                rti.shipment_line_id,
                rti.category_id,
                --rti.vendor_id,
                --rti.vendor_site_id,
                --rti.po_unit_price,
                --rti.movement_id,
                rti.deliver_to_person_id,
                rti.deliver_to_location_id,
                rti.subinventory,
                rti.transfer_lpn_id
         FROM   rcv_transactions_interface rti
         WHERE  interface_transaction_id = v_parent_inter_trx_id;

      default_int_org_transfer_info int_org_transfer%ROWTYPE;
      x_progress                    VARCHAR2(3);
      x_locator_control             NUMBER;
      x_default_subinventory        VARCHAR2(10);
      x_default_locator_id          NUMBER;
      x_success                     BOOLEAN;
      x_tax_name                    VARCHAR2(50); -- Bug 6331613
/*  default variables */
      l_project_id                  NUMBER;
      l_task_id                     NUMBER;
      l_locator_id                  NUMBER;
      temp_index                    NUMBER;
   BEGIN
      p_trx_record.destination_type_code           := x_cascaded_table(n).destination_type_code;
      p_trx_record.transaction_type                := x_cascaded_table(n).transaction_type;
      p_trx_record.processing_mode_code            := x_cascaded_table(n).processing_mode_code;
      p_trx_record.processing_status_code          := x_cascaded_table(n).processing_status_code;
      p_trx_record.transaction_status_code         := x_cascaded_table(n).transaction_status_code;
      p_trx_record.auto_transact_code              := x_cascaded_table(n).auto_transact_code;
      rcv_roi_header_common.commondefaultcode(p_trx_record);
      x_cascaded_table(n).destination_type_code    := p_trx_record.destination_type_code;
      x_cascaded_table(n).transaction_type         := p_trx_record.transaction_type;
      x_cascaded_table(n).processing_mode_code     := p_trx_record.processing_mode_code;
      x_cascaded_table(n).processing_status_code   := p_trx_record.processing_status_code;
      x_cascaded_table(n).transaction_status_code  := p_trx_record.transaction_status_code;
      x_cascaded_table(n).auto_transact_code       := p_trx_record.auto_transact_code;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter Default int org transfer');
      END IF;

      IF (x_cascaded_table(n).derive = 'Y') THEN --{
         IF (x_cascaded_table(n).derive_index <> 0) THEN --{
            /* Get the values from pl/sql table */
            temp_index                                    := x_cascaded_table(n).derive_index;
            x_cascaded_table(n).item_description          := x_cascaded_table(temp_index).item_description;
            x_cascaded_table(n).to_organization_id        := x_cascaded_table(temp_index).to_organization_id;
            x_cascaded_table(n).routing_header_id         := x_cascaded_table(temp_index).routing_header_id;
            x_cascaded_table(n).currency_code             := x_cascaded_table(temp_index).currency_code;
            x_cascaded_table(n).currency_conversion_rate  := x_cascaded_table(temp_index).currency_conversion_rate;
            x_cascaded_table(n).currency_conversion_type  := x_cascaded_table(temp_index).currency_conversion_type;
            x_cascaded_table(n).currency_conversion_date  := x_cascaded_table(temp_index).currency_conversion_date;
            x_cascaded_table(n).shipment_header_id        := x_cascaded_table(temp_index).shipment_header_id;
            x_cascaded_table(n).inspection_status_code    := x_cascaded_table(temp_index).inspection_status_code;
            x_cascaded_table(n).shipment_line_id          := x_cascaded_table(temp_index).shipment_line_id;
            x_cascaded_table(n).category_id               := x_cascaded_table(temp_index).category_id;

            -- default the parent's to_lpn into the child's from_lpn
            IF (x_cascaded_table(n).lpn_id IS NULL) THEN
               x_cascaded_table(n).lpn_id  := x_cascaded_table(temp_index).transfer_lpn_id;

               --insert warning message into po_interface_errors
               IF (x_cascaded_table(n).lpn_id IS NOT NULL) THEN
                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
                  rcv_error_pkg.set_error_message('RCV_LPN_UNPACK_WARNING', x_cascaded_table(n).error_message);
                  rcv_error_pkg.set_token('LPN_ID', x_cascaded_table(n).lpn_id);
                  rcv_error_pkg.log_interface_warning('LPN_ID');
               END IF;
            END IF;

            IF (x_cascaded_table(n).location_id IS NULL) THEN
               x_cascaded_table(n).location_id  := x_cascaded_table(temp_index).location_id;
            END IF;

            IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN --{
               IF (NVL(x_cascaded_table(n).deliver_to_person_id, 0) = 0) THEN
                  x_cascaded_table(n).deliver_to_person_id  := x_cascaded_table(temp_index).deliver_to_person_id;
               END IF;

               IF (NVL(x_cascaded_table(n).deliver_to_location_id, 0) = 0) THEN
                  x_cascaded_table(n).deliver_to_location_id  := x_cascaded_table(temp_index).deliver_to_location_id;
               END IF;

               IF (x_cascaded_table(n).subinventory IS NULL) THEN
                  x_cascaded_table(n).subinventory  := x_cascaded_table(temp_index).subinventory;
               END IF;
            END IF; --}
         ELSE --} {
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('open cursor Default');
            END IF;

            OPEN int_org_transfer_rti(x_cascaded_table(n).parent_interface_txn_id);
         END IF; --}
      ELSE -- } {
         OPEN int_org_transfer(x_cascaded_table(n).parent_transaction_id);
      END IF; --}

      IF (int_org_transfer%ISOPEN) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('fetch cursor Default');
         END IF;

         FETCH int_org_transfer INTO default_int_org_transfer_info;
      ELSIF(int_org_transfer_rti%ISOPEN) THEN
         FETCH int_org_transfer_rti INTO default_int_org_transfer_info;
      END IF;

      IF (   (    int_org_transfer%ISOPEN
              AND int_org_transfer%FOUND)
          OR (    int_org_transfer_rti%ISOPEN
              AND int_org_transfer_rti%FOUND)) THEN --{
         IF (g_asn_debug = 'Y') THEN --{
            asn_debug.put_line('Defaulting Transfer item_description' || default_int_org_transfer_info.item_description);
            asn_debug.put_line('Defaulting Transfer organization_id' || default_int_org_transfer_info.organization_id);
            asn_debug.put_line('Defaulting Transfer inspection_status_code' || default_int_org_transfer_info.inspection_status_code);
            asn_debug.put_line('Defaulting Transfer routing_header_id' || default_int_org_transfer_info.routing_header_id);
            asn_debug.put_line('Defaulting Transfer currency_code' || default_int_org_transfer_info.currency_code);
            asn_debug.put_line('Defaulting Transfer currency_conversion_rate' || default_int_org_transfer_info.currency_conversion_rate);
            asn_debug.put_line('Defaulting Transfer currency_conversion_type' || default_int_org_transfer_info.currency_conversion_type);
            asn_debug.put_line('Defaulting Transfer currency_conversion_date' || default_int_org_transfer_info.currency_conversion_date);
            asn_debug.put_line('Defaulting Transfer shipment_header_id' || default_int_org_transfer_info.shipment_header_id);
            asn_debug.put_line('Defaulting Transfer shipment_line_id' || default_int_org_transfer_info.shipment_line_id);
            asn_debug.put_line('Defaulting Transfer category_id' || default_int_org_transfer_info.category_id);
            asn_debug.put_line('Defaulting Transfer DELIVER_TO_PERSON_ID' || default_int_org_transfer_info.deliver_to_person_id);
            asn_debug.put_line('Defaulting Transfer DELIVER_TO_LOCATION_ID' || default_int_org_transfer_info.deliver_to_location_id);
            asn_debug.put_line('Defaulting Transfer SUBINVENTORY' || default_int_org_transfer_info.subinventory);
         END IF; --}

                 --x_cascaded_table(n).po_revision_num := default_int_org_transfer_info.po_revision_num;

         x_cascaded_table(n).item_description          := default_int_org_transfer_info.item_description;
         --x_cascaded_table(n).po_release_id := default_int_org_transfer_info.po_release_id;
         x_cascaded_table(n).to_organization_id        := default_int_org_transfer_info.organization_id;
         x_cascaded_table(n).inspection_status_code    := default_int_org_transfer_info.inspection_status_code;
         x_cascaded_table(n).routing_header_id         := default_int_org_transfer_info.routing_header_id;
         x_cascaded_table(n).currency_code             := default_int_org_transfer_info.currency_code;
         x_cascaded_table(n).currency_conversion_rate  := default_int_org_transfer_info.currency_conversion_rate;
         x_cascaded_table(n).currency_conversion_type  := default_int_org_transfer_info.currency_conversion_type;
         x_cascaded_table(n).currency_conversion_date  := default_int_org_transfer_info.currency_conversion_date;
         x_cascaded_table(n).shipment_header_id        := default_int_org_transfer_info.shipment_header_id;
         x_cascaded_table(n).shipment_line_id          := default_int_org_transfer_info.shipment_line_id;
         x_cascaded_table(n).category_id               := default_int_org_transfer_info.category_id;

         IF (x_cascaded_table(n).location_id IS NULL) THEN
            x_cascaded_table(n).location_id  := default_int_org_transfer_info.loc_id;
         END IF;

         -- default the parent's to_lpn into the child's from_lpn
         IF (x_cascaded_table(n).lpn_id IS NULL) THEN
            x_cascaded_table(n).lpn_id  := default_int_org_transfer_info.transfer_lpn_id;

            --insert warning message into po_interface_errors
            IF (x_cascaded_table(n).lpn_id IS NOT NULL) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
               rcv_error_pkg.set_error_message('RCV_LPN_UNPACK_WARNING', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('LPN_ID', x_cascaded_table(n).lpn_id);
               rcv_error_pkg.log_interface_warning('LPN_ID');
            END IF;
         END IF;

         IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN --{
            IF (NVL(x_cascaded_table(n).deliver_to_person_id, 0) = 0) THEN
               x_cascaded_table(n).deliver_to_person_id  := default_int_org_transfer_info.deliver_to_person_id;
            END IF;

            IF (NVL(x_cascaded_table(n).deliver_to_location_id, 0) = 0) THEN
               x_cascaded_table(n).deliver_to_location_id  := default_int_org_transfer_info.deliver_to_location_id;
            END IF;

            IF (x_cascaded_table(n).subinventory IS NULL) THEN
               x_cascaded_table(n).subinventory  := default_int_org_transfer_info.subinventory;
            END IF;
         END IF; --}
      END IF; -- if int_org_transfer%found is true }

      /*
      BEGIN Comment: Bug: 4735484

      SELECT NVL(x_cascaded_table(n).use_mtl_lot, lot_control_code),
             NVL(x_cascaded_table(n).use_mtl_serial, serial_number_control_code)
      INTO   x_cascaded_table(n).use_mtl_lot,
             x_cascaded_table(n).use_mtl_serial
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = x_cascaded_table(n).item_id
      AND    mtl_system_items.organization_id = x_cascaded_table(n).to_organization_id;

      END Comment: Bug: 4735484
      */
      x_cascaded_table(n).interface_source_code    := 'RCV';

      /* 3456476.
       * We need to default inspection_status_code only for ACCEPT/REJECT
       * transactions. For others get it from their parent.
       * Removed the code that defaulted inspection_status_code to
       * NOT INSPECTED for all the transactions other than ACCEPT/REJECT.
      */
      IF (x_cascaded_table(n).transaction_type = 'ACCEPT') THEN
         x_cascaded_table(n).inspection_status_code  := 'ACCEPTED';
         x_cascaded_table(n).destination_context     := 'RECEIVING';
      ELSIF(x_cascaded_table(n).transaction_type = 'REJECT') THEN
         x_cascaded_table(n).inspection_status_code  := 'REJECTED';
         x_cascaded_table(n).destination_context     := 'RECEIVING';
      END IF;

      /* Only for deliver, to_subinventory is  a required field. If the user
       * has not provided then we will not default for the other transactions.
       * from_subinventory will be the to_sub of the parent .
       */
      ---WMS Changes
      rcv_roi_transaction.default_from_subloc_info(x_cascaded_table, n);

      IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
         rcv_roi_transaction.default_to_subloc_info(x_cascaded_table, n);
      END IF;

      /*
      ** Make sure to set the location_id properly
      */
      IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
         x_cascaded_table(n).location_id  := x_cascaded_table(n).deliver_to_location_id;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Set Location_id  = ' || TO_CHAR(x_cascaded_table(n).location_id));
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit default_vendor_trans_del');
      END IF;

      IF int_org_transfer%ISOPEN THEN
         CLOSE int_org_transfer;
      END IF;

      IF int_org_transfer_rti%ISOPEN THEN
         CLOSE int_org_transfer_rti;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END default_int_org_trans_del;

   PROCEDURE derive_trans_del_line_quantity(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
      x_include_closed_po           VARCHAR2(1); -- Bug 1887728
      /*
      ** Might be a compatibility issue between the two record definitions
      */
      x_record_count                NUMBER;
      x_remaining_quantity          NUMBER                                   := 0;
      x_remaining_qty_po_uom        NUMBER                                   := 0;
      x_progress                    VARCHAR2(3);
      x_to_organization_code        VARCHAR2(5);
      x_converted_trx_qty           NUMBER                                   := 0;
      transaction_ok                BOOLEAN                                  := FALSE;
      rows_fetched                  NUMBER                                   := 0;
      x_tolerable_qty               NUMBER                                   := 0;
      x_first_trans                 BOOLEAN                                  := TRUE;
      --x_sysdate       DATE  := sysdate;
      current_n                     BINARY_INTEGER                           := 0;
      insert_into_table             BOOLEAN                                  := FALSE;
      --x_qty_rcv_exception_code       po_line_locations.qty_rcv_exception_code%type;
      tax_amount_factor             NUMBER;
      lastrecord                    BOOLEAN                                  := FALSE;
      already_allocated_qty         NUMBER                                   := 0;
      x_item_id                     NUMBER;
      x_temp_count                  NUMBER;
      x_full_name                   VARCHAR2(240)                            := NULL; -- Bug 2392074
      /* Bug# 1548597 */
      x_secondary_available_qty     NUMBER                                   := 0;

/********************************************************************/
      CURSOR int_org_transfer(
         v_parent_trx_id      NUMBER,
         v_to_organization_id NUMBER
      ) IS
         SELECT   rsup.rcv_transaction_id rcv_transaction_id,
                  rt.transaction_date transaction_date,
                  rt.transaction_type,
                  rt.unit_of_measure unit_of_meas,
                  rt.primary_unit_of_measure,
                  rt.primary_quantity,
                  rsup.to_organization_id,
                  --RT.PO_UNIT_PRICE unit_price,
                  rsl.category_id,
                  rsl.item_description,
                  --RSUP.PO_LINE_ID,
                  rt.location_id,
                  rsup.item_id,
                  rsl.deliver_to_person_id, --pod.DELIVER_TO_PERSON_ID ,
                  rsl.deliver_to_location_id, --pod.DELIVER_TO_LOCATION_ID ,
                  rsup.to_subinventory destination_subinventory, --pod.destination_subinventory  ,
                  rt.destination_type_code,
                  rt.organization_id destination_organization_id, --pod.destination_organization_id,
                  rt.quantity qty,
                  0 interface_available_qty
         FROM     rcv_supply rsup,
                  rcv_transactions rt,
                  rcv_shipment_lines rsl
         WHERE    rt.transaction_id = v_parent_trx_id
         AND      rsup.to_organization_id = NVL(v_to_organization_id, rsup.to_organization_id)
         AND      rsup.supply_type_code = 'RECEIVING'
         AND      rsl.shipment_line_id = rsup.shipment_line_id
         AND      rt.transaction_id = rsup.rcv_transaction_id
         AND      rt.transaction_type <> 'UNORDERED'
         ORDER BY transaction_date ASC;

      CURSOR int_org_transfer_rti(
         v_parent_inter_trx_id NUMBER
      ) IS
         SELECT rti.interface_transaction_id rcv_transaction_id,
                rti.transaction_date transaction_date,
                rti.transaction_type,
                rti.unit_of_measure unit_of_meas,
                rti.primary_unit_of_measure,
                rti.primary_quantity,
                rti.to_organization_id,
                rti.category_id,
                rti.item_description,
                rti.location_id,
                rti.item_id,
                rti.deliver_to_person_id,
                rti.deliver_to_location_id,
                rti.subinventory destination_subinventory,
                rti.destination_type_code,
                rti.to_organization_id destination_organization_id,
                rti.quantity qty,
                rti.interface_available_qty
         FROM   rcv_transactions_interface rti
         WHERE  interface_transaction_id = v_parent_inter_trx_id;

      x_int_org_transferrec         int_org_transfer%ROWTYPE;
      x_temp_parent_trx_qty         NUMBER                                   := 0;
      x_converted_parent_trx_qty    NUMBER                                   := 0;
      x_temp_convert_parent_trx_qty NUMBER                                   := 0;
      x_remaining_qty_parent_uom    NUMBER                                   := 0;
      l_to_organization_id          NUMBER                                   := 0;
      x_temp_already_allocated_qty  NUMBER                                   := 0;
      derive_values_from_table      BOOLEAN                                  := FALSE;
      derive_values_from_rti        BOOLEAN                                  := FALSE;
      already_derived               BOOLEAN                                  := FALSE;
      cascaded_table_index          NUMBER;
      temp_index                    NUMBER;
      l_supply_code                 rcv_supply.supply_type_code%TYPE;
      l_transaction_type            rcv_transactions.transaction_type%TYPE;
      --Bug 8631613
      l_temp_qty NUMBER;
      l_pri_temp_qty NUMBER;
      --Bug 8631613
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_quantity ' || x_cascaded_table(n).parent_transaction_id);
      END IF;

      IF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('open int_org_transfer table ' || x_cascaded_table(n).parent_transaction_id);
         END IF;

         OPEN int_org_transfer(x_cascaded_table(n).parent_transaction_id, x_cascaded_table(n).to_organization_id);
         already_derived  := TRUE;
      END IF; --}

      IF (NOT already_derived) THEN --{
         rcv_roi_transaction.derive_parent_id(x_cascaded_table, n);

         /* This means that there was no error in derive_parent_id which means that the
         * this is a child and need to get the values from the rti and not from the plsql table.
         */
         IF (    (x_cascaded_table(n).error_status <> 'E')
             AND (    x_cascaded_table(n).derive = 'Y'
                  AND x_cascaded_table(n).derive_index = 0)) THEN
            /* if derive_values_from_table is true, then we derive the values from the pl/sql tables later
            * at the time when we try to see which cursor is open. We will have x_cascaded_table(n).
            * parent_interface_txn_id) populated with the correct value.
            */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' open pl/sql table');
            END IF;

            OPEN int_org_transfer_rti(x_cascaded_table(n).parent_interface_txn_id);
         END IF;
      END IF; --}

/******************************************************************/
--check line quantity > 0
      x_progress                      := '097';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF x_cascaded_table(n).quantity <= 0 THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Quantity is <= zero. Cascade will fail');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_num);
         rcv_error_pkg.log_interface_error('QUANTITY');
      END IF; --} end qty > 0 check

              -- the following steps will create a set of rows linking the line_record with
              -- its corresponding po_line_location rows until the quantity value from
              -- the asn is consumed.  (Cascade)

      x_progress                      := '098';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF (    x_cascaded_table(n).parent_transaction_id IS NULL
          AND x_cascaded_table(n).parent_interface_txn_id IS NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No parent transaction found ');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_NO_PARENT_TRANSACTION', x_cascaded_table(n).error_message);
         rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID');
      END IF;

      -- Copy record from main table to temp table
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Copy record from main table to temp table');
      END IF;

      current_n                       := 1;
      temp_cascaded_table(current_n)  := x_cascaded_table(n);

      -- Get all rows which meet this condition
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Get all rows which meet this condition');
         asn_debug.put_line('Transaction Type = ' || x_cascaded_table(n).transaction_type);
         asn_debug.put_line('Auto Transact Code = ' || x_cascaded_table(n).auto_transact_code);
      END IF;

      -- Assign shipped quantity to remaining quantity
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Assign populated quantity to remaining quantity');
         asn_debug.put_line('Pointer in temp_cascade ' || TO_CHAR(current_n));
      END IF;

      x_remaining_quantity            := temp_cascaded_table(current_n).quantity;
      x_remaining_qty_po_uom          := 0;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Have assigned the quantity');
      END IF;

      -- Calculate tax_amount_factor for calculating tax_amount for
      -- each cascaded line

      IF NVL(temp_cascaded_table(current_n).tax_amount, 0) <> 0 THEN
         tax_amount_factor  := temp_cascaded_table(current_n).tax_amount / x_remaining_quantity;
      ELSE
         tax_amount_factor  := 0;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Tax Factor ' || TO_CHAR(tax_amount_factor));
         asn_debug.put_line('Shipped Quantity : ' || TO_CHAR(x_remaining_quantity));
      END IF;

      x_first_trans                   := TRUE;
      transaction_ok                  := FALSE;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Before starting Cascade');
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Record Count = ' || x_record_count);
      END IF;

      LOOP --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Remaining Quantity ASN UOM ' || TO_CHAR(x_remaining_quantity));
         END IF;

         /*
         ** Fetch the appropriate record
         */
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('DEBUG: transaction_type = ' || x_cascaded_table(n).transaction_type);
         END IF;

         IF (int_org_transfer%ISOPEN) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' fetch int_org_transfer');
            END IF;

            FETCH int_org_transfer INTO x_int_org_transferrec;

            IF (int_org_transfer%NOTFOUND) THEN
               lastrecord  := TRUE;
            END IF;

            rows_fetched  := int_org_transfer%ROWCOUNT;
         ELSIF(int_org_transfer_rti%ISOPEN) THEN --}{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' fetch int_org_transfer_rti');
            END IF;

            FETCH int_org_transfer_rti INTO x_int_org_transferrec;

            IF (int_org_transfer_rti%NOTFOUND) THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('transfer last row');
               END IF;

               lastrecord  := TRUE;
            END IF;

            rows_fetched  := int_org_transfer_rti%ROWCOUNT;
         ELSIF(temp_cascaded_table(current_n).derive = 'Y') THEN --}{
            /* GET VALUES FROM THE PLSQL TABLE */
            /* Populate x_int_org_transferrec with these values since
            * we are using x_int_org_transferrec later.
            * We have temp_cascaded_table(current_n).
            * parent_interface_txn_id) populated with
            * with the correct value. Also we have cascaded_table_index
            * with the correct pl/sql table index number;
            */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' fetch pl/sql table');
            END IF;

            temp_index                                      := temp_cascaded_table(current_n).derive_index;
            x_int_org_transferrec.unit_of_meas              := x_cascaded_table(temp_index).unit_of_measure;
            x_int_org_transferrec.transaction_date          := x_cascaded_table(temp_index).transaction_date;
            x_int_org_transferrec.transaction_type          := x_cascaded_table(temp_index).transaction_type;
            x_int_org_transferrec.primary_unit_of_measure   := x_cascaded_table(temp_index).primary_unit_of_measure;
            x_int_org_transferrec.primary_quantity          := x_cascaded_table(temp_index).primary_quantity;
            x_int_org_transferrec.to_organization_id        := x_cascaded_table(temp_index).to_organization_id;
            x_int_org_transferrec.category_id               := x_cascaded_table(temp_index).category_id;
            x_int_org_transferrec.item_description          := x_cascaded_table(temp_index).item_description;
            x_int_org_transferrec.location_id               := x_cascaded_table(temp_index).location_id;
            x_int_org_transferrec.item_id                   := x_cascaded_table(temp_index).item_id;
            x_int_org_transferrec.deliver_to_person_id      := x_cascaded_table(temp_index).deliver_to_person_id;
            x_int_org_transferrec.deliver_to_location_id    := x_cascaded_table(temp_index).deliver_to_location_id;
            x_int_org_transferrec.destination_subinventory  := x_cascaded_table(temp_index).subinventory;
            x_int_org_transferrec.destination_type_code     := x_cascaded_table(temp_index).destination_type_code;
            x_int_org_transferrec.qty                       := x_cascaded_table(temp_index).quantity;
            rows_fetched                                    := 1;
            lastrecord                                      := TRUE;
         END IF; --}

                 --x_remaining_quantity:= temp_cascaded_table(current_n).quantity;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Transfer Rows fetched ' || TO_CHAR(rows_fetched));
            --asn_debug.put_line('po_line_id  ' || to_char(x_int_org_transferrec.po_line_id));
            --asn_debug.put_line('po_dist  ' || to_char(x_int_org_transferrec.po_distribution_id));
            asn_debug.put_line('Transfer remainaing qty ' || x_remaining_quantity);
         END IF;

         IF (   lastrecord
             OR x_remaining_quantity <= 0) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Hit exit condition');
            END IF;

            IF NOT x_first_trans THEN
               -- x_first_trans has been reset which means some cascade has
               -- happened. Otherwise current_n = 1
               asn_debug.put_line('current_n before is ' || current_n);
               current_n  := current_n - 1;
            END IF;

            -- do the tolerance act here
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Temp table pointer ' || TO_CHAR(current_n));
               asn_debug.put_line('Check which condition has occured');
            END IF;

            -- lastrecord...we have run out of rows and we still have quantity to allocate
            IF x_remaining_quantity > 0 THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('There is quantity remaining');
                  asn_debug.put_line('Need to check qty tolerances');
               END IF;

               IF     rows_fetched > 0
                  AND NOT x_first_trans THEN --{
                  NULL;

                  /* for transfer,accept an reject type we dont have the
               * tolerance check. Hence error out.
               * We cannot transfer quantities more than that was received.
               */
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(' in transfer Extra ASN UOM Quantity ' || TO_CHAR(x_remaining_quantity));
                     asn_debug.put_line('Extra PO UOM Quantity ' || TO_CHAR(x_remaining_qty_po_uom));
                  END IF;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('delete the temp table ');
                  END IF;

                  IF temp_cascaded_table.COUNT > 0 THEN
                     FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                        temp_cascaded_table.DELETE(i);
                     END LOOP;
                  END IF;

                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.set_error_message('RCV_SHIP_QTY_OVER_TOLERANCE', x_cascaded_table(n).error_message);
                  rcv_error_pkg.set_token('QTY_A', x_cascaded_table(n).quantity);
                  rcv_error_pkg.set_token('QTY_B', x_cascaded_table(n).quantity - x_remaining_quantity);
                  rcv_error_pkg.log_interface_error('QUANTITY');
               ELSE --}{ else for rows fetched = 0 OR x_first_trans = true
                  IF rows_fetched = 0 THEN
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No rows were retrieved from cursor.');
                     END IF;
                  ELSIF x_first_trans THEN
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No rows were cascaded');
                     END IF;
                  END IF;

                  x_temp_count                      := 1;

                  IF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN --{
                     SELECT MAX(rsup.supply_type_code),
                            MAX(rt.transaction_type)
                     INTO   l_supply_code,
                            l_transaction_type
                     FROM   rcv_transactions rt,
                            rcv_supply rsup
                     WHERE  rt.transaction_id = temp_cascaded_table(current_n).parent_transaction_id
                     AND    rsup.rcv_transaction_id = rt.transaction_id;

                     IF l_supply_code <> 'RECEIVING' THEN
                        rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
                     ELSIF l_transaction_type = 'UNORDERED' THEN
                        rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE', x_cascaded_table(n).error_message);
                     END IF;
                  ELSE
                     rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE', x_cascaded_table(n).error_message);
                  END IF; --}


                          -- Delete the temp_cascaded_table just to be sure

                  IF temp_cascaded_table.COUNT > 0 THEN
                     FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                        temp_cascaded_table.DELETE(i);
                     END LOOP;
                  END IF;

                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID');
               END IF;      --} end else for rows fetched = 0 OR x_first_trans = true
                       -- end x_remaining_qty > 0 => this is the last record
            ELSE -- }{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Remaining  UOM quantity is zero ' || TO_CHAR(x_remaining_quantity));
                  asn_debug.put_line('Return the cascaded rows back to the calling procedure');
               END IF;
            END IF; --} ends the check for whether last record has been reached

                    -- close cursors

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Close cursors shipments, count_shipments, distributions, count_disributions ' || current_n);
            END IF;

            IF int_org_transfer%ISOPEN THEN
               CLOSE int_org_transfer;
            END IF;

            IF int_org_transfer_rti%ISOPEN THEN
               CLOSE int_org_transfer_rti;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('before exit current_n is ' || current_n);
            END IF;

            EXIT;
         END IF; --} matches lastrecord or x_remaining_quantity <= 0

                 -- eliminate the row if it fails the date check

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(' Entering qty calculateion for transfer');
         END IF;

         IF     (x_first_trans)
            AND temp_cascaded_table(current_n).item_id IS NULL THEN
            temp_cascaded_table(current_n).item_id                  := x_int_org_transferrec.item_id;
            temp_cascaded_table(current_n).primary_unit_of_measure  := x_int_org_transferrec.primary_unit_of_measure;
         END IF;

         insert_into_table           := FALSE;
         already_allocated_qty       := 0;
         -- need to find out if the parent is in rti
         rcv_roi_transaction.get_interface_available_qty(temp_cascaded_table,
                                                         current_n,
                                                         x_converted_parent_trx_qty
                                                        );

         IF (x_converted_parent_trx_qty = 0) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('calling transfer get_available_qty ');
            END IF;

            -- the call for transfer/deliver should be the same
            rcv_quantities_s.get_available_quantity('TRANSFER',
                                                    x_int_org_transferrec.rcv_transaction_id,
                                                    temp_cascaded_table(current_n).receipt_source_code,
                                                    NULL,
                                                    x_int_org_transferrec.rcv_transaction_id,
                                                    NULL,
                                                    x_converted_parent_trx_qty,
                                                    x_tolerable_qty,
                                                    x_int_org_transferrec.unit_of_meas,
                                                    /*Bug# 1548597 */
                                                    x_secondary_available_qty
                                                   );
         END IF; --}

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('qty from GET_AVAILABLE_QUANTITY for transfer is ' || x_converted_parent_trx_qty);
         END IF;

         x_remaining_qty_parent_uom  := rcv_roi_transaction.convert_into_correct_qty(x_remaining_quantity,
                                                                                     temp_cascaded_table(1).unit_of_measure,
                                                                                     temp_cascaded_table(1).item_id,
                                                                                     x_int_org_transferrec.unit_of_meas
                                                                                    );

         IF (x_remaining_qty_parent_uom = 0) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' Transfer Need an error message in the interface tables');
            END IF;
         ELSE   /* Converted qty successfully and we have some quantity on which we can act */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Converted trx qty that is available ' || x_converted_parent_trx_qty);
               asn_debug.put_line('Remaining qty in parents uom that is available ' || x_remaining_qty_parent_uom);
            END IF;

            IF (x_converted_parent_trx_qty > 0) THEN --{
               IF (x_converted_parent_trx_qty < x_remaining_qty_parent_uom) THEN --{
                  /* Total quantity available to transfer is less than the qty
                     * that the user wants to transfer. Hence we would error out but
                     * to keep the old code we will get the remaining code here and
                     * error out later.
                     */
                  x_remaining_qty_parent_uom  := x_remaining_qty_parent_uom - x_converted_parent_trx_qty;

                  IF (temp_cascaded_table(current_n).unit_of_measure <> x_int_org_transferrec.unit_of_meas) THEN
                     x_remaining_quantity  := rcv_roi_transaction.convert_into_correct_qty(x_remaining_qty_parent_uom,
                                                                                           x_int_org_transferrec.unit_of_meas,
                                                                                           temp_cascaded_table(1).item_id,
                                                                                           temp_cascaded_table(1).unit_of_measure
                                                                                          );
                  ELSE
                     x_remaining_quantity  := x_remaining_qty_parent_uom;
                  END IF;

                  insert_into_table           := TRUE;
               ELSE --}{
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('We are in >= Qty branch ');
                  END IF;

                  x_converted_parent_trx_qty  := x_remaining_qty_parent_uom;
                  insert_into_table           := TRUE;
                  x_remaining_qty_parent_uom  := 0;
                  x_remaining_quantity        := 0;
               END IF; --} /* if (x_converted_parent_trx_qty < x_remaining_qty_parent_uom) then */
            ELSE /* x_converted_parent_trx_qty >0 */ --}{
               IF rows_fetched = x_record_count THEN                    -- { last row needs to be inserted anyway
                                                     -- so that the row can be used based on qty tolerance checks
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('Quantity is less then 0 but last record');
                  END IF;

                  insert_into_table    := TRUE;
                  x_converted_trx_qty  := 0;
               ELSE --}{
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('<= 0 Quantity but more records in cursor');
                  END IF;

                  x_remaining_qty_po_uom  := 0; -- we may have a diff uom on the next iteration

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('We have to deal with remaining_qty > 0 and x_converted_trx_qty -ve');
                  END IF;

                  insert_into_table       := FALSE;
               END IF; --}
            END IF; /*x_converted_parent_trx_qty >0 */ --}
         END IF; -- } Converted qty successfully and we have some quantity on which we can act

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Transaction qty in terms of the parents uom is ' || x_converted_parent_trx_qty);
         END IF;

         IF insert_into_table THEN --{ --start
            IF (x_first_trans) THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('First Time ' || TO_CHAR(current_n));
               END IF;

               x_first_trans  := FALSE;
            ELSE --}{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Next Time ' || TO_CHAR(current_n));
               END IF;

               temp_cascaded_table(current_n)  := temp_cascaded_table(current_n - 1);
            END IF; --}

            temp_cascaded_table(current_n).primary_unit_of_measure  := x_int_org_transferrec.primary_unit_of_measure;

            IF (temp_cascaded_table(current_n).unit_of_measure <> x_int_org_transferrec.unit_of_meas) THEN
             --Bug 8631613 For some conversions residual qty. is causing issues while doing put away.
                l_temp_qty  := rcv_roi_transaction.convert_into_correct_qty( x_converted_parent_trx_qty,
                                                                             x_int_org_transferrec.unit_of_meas,
                                                                             temp_cascaded_table(current_n).item_id,
                                                                             temp_cascaded_table(current_n).unit_of_measure
                                                                            ); -- in asn uom
               IF ( Round(l_temp_qty,7) <> temp_cascaded_table(current_n).quantity  ) THEN
               temp_cascaded_table(current_n).quantity := l_temp_qty;
               END IF;
               /*temp_cascaded_table(current_n).quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_parent_trx_qty,
                                                                                                        x_int_org_transferrec.unit_of_meas,
                                                                                                        temp_cascaded_table(current_n).item_id,
                                                                                                        temp_cascaded_table(current_n).unit_of_measure
                                                                                                       ); -- in asn uom*/


               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Transaction qty in terms of the transaction uom is ' || temp_cascaded_table(current_n).quantity);
               END IF;
            ELSE
               temp_cascaded_table(current_n).quantity  := x_converted_parent_trx_qty;
            END IF;

            IF (temp_cascaded_table(current_n).primary_unit_of_measure <> x_int_org_transferrec.unit_of_meas) THEN
            --Bug 8631613
               l_pri_temp_qty  := rcv_roi_transaction.convert_into_correct_qty(x_converted_parent_trx_qty,
                                                                               x_int_org_transferrec.unit_of_meas,
                                                                               temp_cascaded_table(current_n).item_id,
                                                                               temp_cascaded_table(current_n).primary_unit_of_measure
                                                                               );
               IF (Round(l_pri_temp_qty,7) <> NVL(temp_cascaded_table(current_n).primary_quantity,-1)) THEN
                  temp_cascaded_table(current_n).primary_quantity := l_pri_temp_qty;
               END IF;

               /*temp_cascaded_table(current_n).primary_quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_parent_trx_qty,
                                                                                                                x_int_org_transferrec.unit_of_meas,
                                                                                                                temp_cascaded_table(current_n).item_id,
                                                                                                                temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                               );*/
            --Bug 8631613
            ELSE
               temp_cascaded_table(current_n).primary_quantity  := x_converted_parent_trx_qty;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Transaction qty in terms of the primary uom is ' || temp_cascaded_table(current_n).primary_quantity);
            END IF;

            --sugatas put here
            --temp_cascaded_table(current_n).inspection_status_code  := x_int_org_transferrec.inspection_status_code;
            temp_cascaded_table(current_n).interface_source_code    := 'RCV';

            -- destination type code will be parent's destination type code if txn type not deliver
            IF (NVL(x_cascaded_table(n).transaction_type, 'RECEIVE') <> 'DELIVER') THEN --{
               temp_cascaded_table(current_n).destination_type_code  := x_int_org_transferrec.destination_type_code;
               temp_cascaded_table(current_n).destination_context    := x_int_org_transferrec.destination_type_code;
            ELSIF(NVL(x_cascaded_table(n).transaction_type, 'RECEIVE') = 'DELIVER') THEN                                                                            --}{
                                                                                         --          temp_cascaded_table(current_n).currency_conversion_date  := x_int_org_transferrec.rate_date;
                                                                                         --         temp_cascaded_table(current_n).currency_conversion_rate  := x_int_org_transferrec.rate;
               /* Bug 8314096 The destination_type_code was being explicitly set to 'INVENTORY' even for 'EXPENSE' items.
                  This was resulting in DELIVER transaction error through mobile, due to missing subinventory data,
                  which is admissible in case of destination_type_code 'EXPENSE'. The previous code is as follows :
               temp_cascaded_table(current_n).destination_type_code  := 'INVENTORY';
                   Changed the code to set destination_type_code as 'INVENTORY' only if it is NULL. */

               temp_cascaded_table(current_n).destination_type_code  := Nvl(temp_cascaded_table(current_n).destination_type_code,'INVENTORY');


               -- temp_cascaded_table(current_n).destination_context  := temp_cascaded_table(current_n).destination_type_code;
               IF (NVL(temp_cascaded_table(current_n).deliver_to_location_id, 0) = 0) THEN
                  temp_cascaded_table(current_n).deliver_to_location_id  := x_int_org_transferrec.deliver_to_location_id;
               END IF;

               /* Bug 2392074 - If the deliver_to_person mentioned in the po_distributions is
                  invalid or inactive at the time of Receipt we need to clear the deliver to person,
                  as this is an optional field. */
               IF (NVL(temp_cascaded_table(current_n).deliver_to_person_id, 0) = 0) THEN --{
                  temp_cascaded_table(current_n).deliver_to_person_id  := x_int_org_transferrec.deliver_to_person_id;

                  IF (temp_cascaded_table(current_n).deliver_to_person_id IS NOT NULL) THEN --{
                     BEGIN
                        SELECT NVL(MAX(hre.full_name), 'notfound')
                        INTO   x_full_name
                        FROM   hr_employees_current_v hre
                        WHERE  (   hre.inactive_date IS NULL
                                OR hre.inactive_date > SYSDATE)
                        AND    hre.employee_id = temp_cascaded_table(current_n).deliver_to_person_id;

                        IF (x_full_name = 'notfound') THEN
                           temp_cascaded_table(current_n).deliver_to_person_id  := NULL;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           temp_cascaded_table(current_n).deliver_to_person_id  := NULL;

                           IF (g_asn_debug = 'Y') THEN
                              asn_debug.put_line('The deliver to person entered in IOT is currently inactive');
                              asn_debug.put_line(' So it is cleared off');
                           END IF;
                        WHEN OTHERS THEN
                           temp_cascaded_table(current_n).deliver_to_person_id  := NULL;

                           IF (g_asn_debug = 'Y') THEN
                              asn_debug.put_line('Some exception has occured');
                              asn_debug.put_line('This exception is due to the IOT deliver to person');
                              asn_debug.put_line('The deliver to person is optional');
                              asn_debug.put_line('So cleared off the deliver to person');
                           END IF;
                     END;
                  END IF; --}
               END IF; --}

               IF (temp_cascaded_table(current_n).subinventory IS NULL) THEN
                  temp_cascaded_table(current_n).subinventory  := x_int_org_transferrec.destination_subinventory;
               END IF;
            END IF; --}

            current_n                                               := current_n + 1;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Increment pointer by 1 ' || TO_CHAR(current_n));
            END IF;
         END IF; --}

         asn_debug.put_line('finished processing one row in derive_qty for IOT transfers/delivers/accept/reject ');
      END LOOP; --}

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before closing cursors current_n is ' || temp_cascaded_table.COUNT);
      END IF;

      IF int_org_transfer%ISOPEN THEN
         CLOSE int_org_transfer;
      END IF;

      IF int_org_transfer_rti%ISOPEN THEN
         CLOSE int_org_transfer_rti;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit derive_trans_del_line_quantity');
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         IF int_org_transfer%ISOPEN THEN
            CLOSE int_org_transfer;
         END IF;

         IF int_org_transfer_rti%ISOPEN THEN
            CLOSE int_org_transfer_rti;
         END IF;
      WHEN OTHERS THEN
         IF int_org_transfer%ISOPEN THEN
            CLOSE int_org_transfer;
         END IF;

         IF int_org_transfer_rti%ISOPEN THEN
            CLOSE int_org_transfer_rti;
         END IF;

         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('derive_trans_del_line_quantity', x_progress);
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
         rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(n));
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('error ' || x_progress);
         END IF;
   END derive_trans_del_line_quantity;

/*-------- corrections --------------------------*/
   PROCEDURE derive_int_org_cor_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_correction_line ');
      END IF;

      /* Derive the to_org_id */
      rcv_roi_transaction.derive_ship_to_org_info(x_cascaded_table,
                                                  n,
                                                  x_header_record
                                                 );

      IF (x_cascaded_table(n).unit_of_measure IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
         END IF;

         SELECT muom.uom_code
         INTO   x_cascaded_table(n).uom_code
         FROM   mtl_units_of_measure muom
         WHERE  muom.unit_of_measure = x_cascaded_table(n).unit_of_measure;
      ELSE
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('uom_code not dereived as unit_of_measure is null');
         END IF;
      END IF;

      x_progress                              := '091';
      rcv_roi_transaction.derive_reason_info(x_cascaded_table, n);
      /* Auto_transact_code is null for all these transaction types */
      x_cascaded_table(n).auto_transact_code  := NULL;
      derive_int_org_cor_line_qty(x_cascaded_table,
                                  n,
                                  temp_cascaded_table
                                 );
   END derive_int_org_cor_line;

   PROCEDURE derive_int_org_cor_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
      x_record_count               NUMBER;
      x_remaining_quantity         NUMBER                                        := 0;
      x_progress                   VARCHAR2(3);
      x_converted_trx_qty          NUMBER                                        := 0;
      rows_fetched                 NUMBER                                        := 0;
      x_tolerable_qty              NUMBER                                        := 0;
      x_first_trans                BOOLEAN                                       := TRUE;
      current_n                    BINARY_INTEGER                                := 0;
      insert_into_table            BOOLEAN                                       := FALSE;
      tax_amount_factor            NUMBER;
      lastrecord                   BOOLEAN                                       := FALSE;
      already_allocated_qty        NUMBER                                        := 0;
      /* Bug# 1548597 */
      x_secondary_available_qty    NUMBER                                        := 0;

/********************************************************************/
      -- Bug 3584779, expanded int_org_cor_rt to pick up parent transactions of type RETURN TO CUSTOMER as well.
      -- also copied the restriction into the RTI cursor as well
      CURSOR int_org_cor_rt(
         v_parent_trx_id      NUMBER,
         v_to_organization_id NUMBER
      ) IS
         SELECT   rt.transaction_id rcv_transaction_id,
                  rt.parent_transaction_id grand_parent_txn_id,
                  rt.transaction_date transaction_date,
                  rt.transaction_type parent_transaction_type,
                  rt.quantity qty,
                  rt.unit_of_measure unit_of_meas,
                  rt.primary_unit_of_measure,
                  rt.primary_quantity,
                  rt.organization_id,
                  rsl.category_id,
                  rsl.item_description,
                  rsl.shipment_line_id,
                  rsl.shipment_header_id,
                  rt.location_id,
                  rsl.item_id,
                  rt.deliver_to_person_id,
                  rt.deliver_to_location_id,
                  rt.subinventory destination_subinventory,
                  rt.destination_type_code,
                  rsl.ussgl_transaction_code,
                  rt.oe_order_line_id
         FROM     rcv_transactions rt,
                  rcv_shipment_lines rsl
         WHERE    rt.transaction_id = v_parent_trx_id
         AND      rt.shipment_line_id = rsl.shipment_line_id
         AND      rt.organization_id = NVL(v_to_organization_id, rt.organization_id)
         AND      rt.transaction_type IN('RECEIVE', 'TRANSFER', 'ACCEPT', 'REJECT', 'RETURN TO CUSTOMER')
         ORDER BY rt.transaction_id;

      CURSOR int_org_cor_rti(
         v_parent_interface_txn_id NUMBER
      ) IS
         SELECT rti.interface_transaction_id rcv_transaction_id,
                rti.parent_transaction_id grand_parent_txn_id,
                rti.transaction_date transaction_date,
                rti.transaction_type parent_transaction_type,
                rti.quantity qty,
                rti.unit_of_measure unit_of_meas,
                rti.primary_unit_of_measure,
                rti.primary_quantity,
                rti.to_organization_id organization_id,
                rti.category_id,
                rti.item_description,
                rti.shipment_line_id,
                rti.shipment_header_id,
                rti.location_id,
                rti.item_id,
                rti.deliver_to_person_id,
                rti.deliver_to_location_id,
                rti.subinventory destination_subinventory,
                rti.destination_type_code,
                rti.ussgl_transaction_code,
                rti.oe_order_line_id
         FROM   rcv_transactions_interface rti
         WHERE  interface_transaction_id = v_parent_interface_txn_id
         AND    rti.transaction_type IN('RECEIVE', 'TRANSFER', 'ACCEPT', 'REJECT', 'RETURN TO CUSTOMER');

      int_org_cor_rec              int_org_cor_rt%ROWTYPE;
      x_converted_parent_trx_qty   NUMBER                                        := 0;
      -- x_remaining_qty_parent_uom      NUMBER                              := 0;
      l_to_organization_id         NUMBER                                        := 0;
      l_transaction_type           rcv_transactions.transaction_type%TYPE;
      x_temp_already_allocated_qty NUMBER                                        := 0;
      derive_values_from_table     BOOLEAN                                       := FALSE;
      derive_values_from_rti       BOOLEAN                                       := FALSE;
      already_derived              BOOLEAN                                       := FALSE;
      l_grand_parent_trx_id        rcv_transactions.parent_transaction_id%TYPE;
      temp_index                   NUMBER;
      l_supply_code                rcv_supply.supply_type_code%TYPE;

      /* Bug#5369121 */
      l_primary_uom                 rcv_transactions_interface.unit_of_measure%TYPE;
      l_transaction_uom             rcv_transactions.unit_of_measure%TYPE;
      l_interface_quantity          NUMBER;
      l_interface_qty_in_trx_uom    NUMBER;
      l_item_id                     NUMBER;
      /* Bug#5369121 */

   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_quantity ' || x_cascaded_table(n).parent_transaction_id);
      END IF;

      IF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN --{
         already_derived  := TRUE;
      END IF; --}

      IF (    NOT already_derived
          AND (x_cascaded_table(n).parent_interface_txn_id IS NULL)
          AND (x_cascaded_table(n).parent_source_transaction_num IS NOT NULL)) THEN --{
         /* This means that there can be a row in RT with src_txn_id
          * populated or it can be a child.
         */
         BEGIN
            SELECT transaction_id
            INTO   x_cascaded_table(n).parent_transaction_id
            FROM   rcv_transactions
            WHERE  source_transaction_num = x_cascaded_table(n).parent_source_transaction_num;

            already_derived  := TRUE;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- this is fine since this could be a child.
               NULL;
         END;
      END IF; --}

      IF already_derived THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(' open int_org_cor_rt table ' || x_cascaded_table(n).parent_transaction_id);
         END IF;

         OPEN int_org_cor_rt(x_cascaded_table(n).parent_transaction_id, x_cascaded_table(n).to_organization_id);
      END IF; ---}

      IF (NOT already_derived) THEN --{
         rcv_roi_transaction.derive_parent_id(x_cascaded_table, n);

         /* This means that there was no error in
          * derive_parent_id which means that the
          * this is a child and need to get the values
          * from the rti and not from the plsql table.
         */
         IF (    x_cascaded_table(n).error_status <> 'E'
             AND x_cascaded_table(n).derive = 'Y'
             AND x_cascaded_table(n).derive_index = 0) THEN
            /* if derive_values_from_table is true, then we
             * derive the values from the pl/sql tables later
             * at the time when we try to see which cursor is open.
             * We will have x_cascaded_table(n).
             * parent_interface_txn_id) populated with teh
             * correct value.
            */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' open pl/sql table');
            END IF;

            OPEN int_org_cor_rti(x_cascaded_table(n).parent_interface_txn_id);
         END IF;
      END IF; --}

/******************************************************************/
--check line quanity > 0
      x_progress                      := '097';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (x_cascaded_table(n).quantity = 0) THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Quantity is <= zero. Cascade will fail');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_num);
         rcv_error_pkg.log_interface_error('QUANTITY');
      END IF; --} end qty > 0 check

      x_progress                      := '098';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF (    x_cascaded_table(n).parent_transaction_id IS NULL
          AND x_cascaded_table(n).parent_interface_txn_id IS NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No parent transaction found ');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_NO_PARENT_TRANSACTION', x_cascaded_table(n).error_message);
         rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID');
      END IF;

      -- Copy record from main table to temp table
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Copy record from main table to temp table');
      END IF;

      current_n                       := 1;
      temp_cascaded_table(current_n)  := x_cascaded_table(n);

      -- Get all rows which meet this condition
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Get all rows which meet this condition');
         asn_debug.put_line('Transaction Type = ' || x_cascaded_table(n).transaction_type);
         asn_debug.put_line('Auto Transact Code = ' || x_cascaded_table(n).auto_transact_code);
      END IF;

      -- Assign shipped quantity to remaining quantity
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Assign populated quantity to remaining quantity');
         asn_debug.put_line('Pointer in temp_cascade ' || TO_CHAR(current_n));
      END IF;

      x_remaining_quantity            := temp_cascaded_table(current_n).quantity;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Have assigned the quantity');
      END IF;

      -- Calculate tax_amount_factor for calculating tax_amount for
      -- each cascaded line

      IF NVL(temp_cascaded_table(current_n).tax_amount, 0) <> 0 THEN
         tax_amount_factor  := temp_cascaded_table(current_n).tax_amount / x_remaining_quantity;
      ELSE
         tax_amount_factor  := 0;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Tax Factor ' || TO_CHAR(tax_amount_factor));
         asn_debug.put_line('transaction Quantity : ' || TO_CHAR(x_remaining_quantity));
      END IF;

      x_first_trans                   := TRUE;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Before starting Cascade');
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Record Count = ' || x_record_count);
      END IF;

      LOOP --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Remaining Quantity  ' || TO_CHAR(x_remaining_quantity));
         END IF;

         /*
         ** Fetch the appropriate record
         */
         IF (int_org_cor_rt%ISOPEN) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' fetch int_org_cor_rt');
            END IF;

            FETCH int_org_cor_rt INTO int_org_cor_rec;

            IF (int_org_cor_rt%NOTFOUND) THEN
               lastrecord  := TRUE;
            END IF;

            rows_fetched  := int_org_cor_rt%ROWCOUNT;
         ELSIF(int_org_cor_rti%ISOPEN) THEN --}{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' fetch int_org_cor_rti');
            END IF;

            FETCH int_org_cor_rti INTO int_org_cor_rec;

            IF (int_org_cor_rti%NOTFOUND) THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('correct last row');
               END IF;

               lastrecord  := TRUE;
            END IF;

            rows_fetched  := int_org_cor_rti%ROWCOUNT;
         ELSIF(temp_cascaded_table(current_n).derive = 'Y') THEN --}{
            /* GET VALUES FROM THE PLSQL TABLE */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' fetch pl/sql table');
            END IF;

            temp_index                                := temp_cascaded_table(current_n).derive_index;
            int_org_cor_rec.unit_of_meas              := x_cascaded_table(temp_index).unit_of_measure;
            int_org_cor_rec.grand_parent_txn_id       := x_cascaded_table(temp_index).parent_transaction_id;
            int_org_cor_rec.transaction_date          := x_cascaded_table(temp_index).transaction_date;
            int_org_cor_rec.parent_transaction_type   := x_cascaded_table(temp_index).transaction_type;
            int_org_cor_rec.qty                       := x_cascaded_table(temp_index).quantity;
            int_org_cor_rec.primary_unit_of_measure   := x_cascaded_table(temp_index).primary_unit_of_measure;
            int_org_cor_rec.primary_quantity          := x_cascaded_table(temp_index).primary_quantity;
            int_org_cor_rec.organization_id           := x_cascaded_table(temp_index).to_organization_id;
            int_org_cor_rec.category_id               := x_cascaded_table(temp_index).category_id;
            int_org_cor_rec.item_description          := x_cascaded_table(temp_index).item_description;
            int_org_cor_rec.location_id               := x_cascaded_table(temp_index).location_id;
            int_org_cor_rec.item_id                   := x_cascaded_table(temp_index).item_id;
            int_org_cor_rec.shipment_line_id          := x_cascaded_table(temp_index).shipment_line_id;
            int_org_cor_rec.deliver_to_person_id      := x_cascaded_table(temp_index).deliver_to_person_id;
            int_org_cor_rec.deliver_to_location_id    := x_cascaded_table(temp_index).deliver_to_location_id;
            int_org_cor_rec.destination_subinventory  := x_cascaded_table(temp_index).subinventory;
            int_org_cor_rec.destination_type_code     := x_cascaded_table(temp_index).destination_type_code;
            int_org_cor_rec.ussgl_transaction_code    := x_cascaded_table(temp_index).ussgl_transaction_code;
            /* Also fetch parent transaction type and grand parent trx id into
             * the correct variables.
            */
            rows_fetched                              := 1;
            lastrecord                                := TRUE;
         END IF;                 --}
                 --x_remaining_quantity:= temp_cascaded_table(current_n).quantity;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Correct Rows fetched ' || TO_CHAR(rows_fetched));
            asn_debug.put_line('correct remainaing qty ' || x_remaining_quantity);
         END IF;

         IF (lastrecord) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Hit exit condition');
            END IF;

            IF NOT x_first_trans THEN
               -- x_first_trans has been reset which means some cascade has
               -- happened. Otherwise current_n = 1
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('current_n before is ' || current_n);
               END IF;

               current_n  := current_n - 1;
            END IF;

            -- do the tolerance act here
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Temp table pointer ' || TO_CHAR(current_n));
               asn_debug.put_line('Check which condition has occured');
            END IF;

            -- lastrecord...we have run out of rows and we still have quantity to allocate
            /* Do abs(x_remaining_quantity) since it can be a negative
          * or positive correction.
            */
            IF ABS(x_remaining_quantity) > 0 THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('There is quantity remaining ');
                  asn_debug.put_line('tolerable quantity now in plsql table ' || temp_cascaded_table(current_n).quantity);
                  asn_debug.put_line('rows_fetched ' || rows_fetched);
               END IF;

               IF NOT x_first_trans THEN
                  asn_debug.put_line('not first txn');
               END IF;

               IF     rows_fetched > 0
                  AND NOT x_first_trans THEN --{
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(' inside transaction_type ' || int_org_cor_rec.parent_transaction_type);
                  END IF;

                  IF (SIGN(temp_cascaded_table(current_n).quantity) IN(-1, -1)) THEN --{
                     /* for correct,accept an reject type we dont have the
                  * tolerance check. Hence error out.
                     * We cannot correct quantities more than that was received.
                  */
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line(' in correct extra Quantity ' || TO_CHAR(x_remaining_quantity));
                     END IF;

                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('delete the temp table ');
                     END IF;

                     IF temp_cascaded_table.COUNT > 0 THEN
                        FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                           temp_cascaded_table.DELETE(i);
                        END LOOP;
                     END IF;

                     x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                     rcv_error_pkg.set_error_message('RCV_SHIP_QTY_OVER_TOLERANCE', x_cascaded_table(n).error_message);
                     rcv_error_pkg.set_token('QTY_A', x_cascaded_table(n).quantity);
                     rcv_error_pkg.set_token('QTY_B', x_cascaded_table(n).quantity - x_remaining_quantity);
                     rcv_error_pkg.log_interface_error('QUANTITY');
                  END IF; --}ends check for a -ve correction
               ELSE --}{ else for rows fetched = 0 OR x_first_trans = true
                  IF rows_fetched = 0 THEN
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No rows were retrieved from cursor.');
                     END IF;
                  ELSIF x_first_trans THEN
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No rows were cascaded');
                     END IF;
                  END IF;

                  IF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN --{
                     /* Give an error just like it is done for the
                      * the receipt transaction;
                     */
                     SELECT MAX(rsup.supply_type_code),
                            MAX(rt.transaction_type)
                     INTO   l_supply_code,
                            l_transaction_type
                     FROM   rcv_transactions rt,
                            rcv_supply rsup
                     WHERE  rt.transaction_id = temp_cascaded_table(current_n).parent_transaction_id
                     AND    rsup.rcv_transaction_id = rt.transaction_id;

                     IF l_supply_code <> 'RECEIVING' THEN
                        rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
                     ELSIF l_transaction_type = 'UNORDERED' THEN
                        rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE', x_cascaded_table(n).error_message);
                     END IF;
                  ELSE
                     rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE', x_cascaded_table(n).error_message);
                  END IF; --}

                          -- Delete the temp_cascaded_table just to be sure

                  IF temp_cascaded_table.COUNT > 0 THEN
                     FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                        temp_cascaded_table.DELETE(i);
                     END LOOP;
                  END IF;

                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID');
               END IF; --} end else for rows fetched = 0 OR x_first_trans = true
            ELSE -- }{ this is the else for whether remaining qty is not  0
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Remaining  UOM quantity is zero ' || TO_CHAR(x_remaining_quantity));
                  asn_debug.put_line('Return the cascaded rows back to the calling procedure');
               END IF;
            END IF; --} ends the check for whether last record has been reached

                    -- close cursors

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Close cursors  ' || current_n);
            END IF;

            IF int_org_cor_rt%ISOPEN THEN
               CLOSE int_org_cor_rt;
            END IF;

            IF int_org_cor_rti%ISOPEN THEN
               CLOSE int_org_cor_rti;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('before exit current_n is ' || current_n);
            END IF;

            EXIT;
         END IF; --} matches the condition of lastrecord has been reached

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(' the iot rec uom is ' || int_org_cor_rec.unit_of_meas);
            asn_debug.put_line(' the iot rec primary uom is ' || int_org_cor_rec.primary_unit_of_measure);
            asn_debug.put_line(' Entering qty calculateion for correct');
         END IF;

         -- bug fix 5269121 :it is wrong to
         --copy the parents unit of measure into the childs unit of measure, as this will be the one
         --which will be finally populated into RT for the child record (correction record).
         --temp_cascaded_table(current_n).unit_of_measure  := int_org_cor_rec.unit_of_meas;

         IF (    x_first_trans
             AND temp_cascaded_table(current_n).item_id IS NULL) THEN
            temp_cascaded_table(current_n).item_id                  := int_org_cor_rec.item_id;
            temp_cascaded_table(current_n).primary_unit_of_measure  := int_org_cor_rec.primary_unit_of_measure;
         END IF;

         insert_into_table                               := FALSE;
         already_allocated_qty                           := 0;
         -- need to find out if the parent/grandparent are in rti
         rcv_roi_transaction.get_interface_available_qty(temp_cascaded_table,
                                                         current_n,
                                                         x_converted_parent_trx_qty
                                                        );

         IF (x_converted_parent_trx_qty = 0) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('calling Correct get_available_qty ' || int_org_cor_rec.parent_transaction_type);
            END IF;

            -- this is a negative correction
            IF (SIGN(temp_cascaded_table(current_n).quantity) = -1) THEN --{
               rcv_quantities_s.get_available_quantity('CORRECT',
                                                       int_org_cor_rec.rcv_transaction_id,
                                                       temp_cascaded_table(current_n).receipt_source_code,
                                                       int_org_cor_rec.parent_transaction_type,
                                                       NULL,
                                                       'NEGATIVE',
                                                       x_converted_parent_trx_qty,
                                                       x_tolerable_qty,
                                                       int_org_cor_rec.unit_of_meas,
                                                       x_secondary_available_qty
                                                      );

                     /* Bug#5369121 - START */
                     IF (g_asn_debug = 'Y') THEN
                         asn_debug.put_line('x_converted_parent_trx_qty:' || x_converted_parent_trx_qty);
                         asn_debug.put_line('transaction_quantity:' || temp_cascaded_table(current_n).quantity);
                     END IF;

                     IF (x_converted_parent_trx_qty < ABS(temp_cascaded_table(current_n).quantity)) THEN

                         SELECT  rt.unit_of_measure,
                                 rsl.item_id,
                                 rt.primary_unit_of_measure
                         INTO    l_transaction_uom,
                                 l_item_id,
                                 l_primary_uom
                         FROM    rcv_transactions rt,
                                 rcv_shipment_lines rsl
                         WHERE   rsl.shipment_line_id = rt.shipment_line_id
                         AND     rt.transaction_id = int_org_cor_rec.rcv_transaction_id;

                         SELECT NVL(SUM(interface_transaction_qty),0)
                         INTO   l_interface_quantity
                         FROM   rcv_transactions_interface
                         WHERE  (transaction_status_code = 'PENDING'
                                AND processing_status_code <> 'ERROR')
                         AND    group_id = temp_cascaded_table(current_n).group_id
                         AND    transaction_type = 'CORRECT'
                         AND    parent_transaction_id IN ( SELECT transaction_id
                                        FROM rcv_transactions
                                        WHERE parent_transaction_id = int_org_cor_rec.rcv_transaction_id);

                         IF (l_interface_quantity = 0) THEN

                             /*
                             ** There is no unprocessed quantity. Simply set the
                             ** x_interface_qty_in_trx_uom to 0. There is no need for uom
                             ** conversion.
                             */

                             l_interface_qty_in_trx_uom := 0;

                         ELSE

                             /*
                             ** There is unprocessed quantity. Convert it to the transaction uom
                             ** so that the available quantity can be calculated in the trx uom
                             */

                             IF (g_asn_debug = 'Y') THEN
                                     asn_debug.put_line('Before uom_convert:');
                                     asn_debug.put_line('l_interface_quantity' || l_interface_quantity);
                                     asn_debug.put_line('l_primary_uom' || l_primary_uom);
                                     asn_debug.put_line('l_transaction_uom' || l_transaction_uom);
                                     asn_debug.put_line('l_item_id' || l_item_id);
                             END IF;

                             po_uom_s.uom_convert(l_interface_quantity, l_primary_uom, l_item_id,
                                                 l_transaction_uom, l_interface_qty_in_trx_uom);

                         END IF;

                         x_converted_parent_trx_qty := x_converted_parent_trx_qty - l_interface_qty_in_trx_uom;

                         IF (g_asn_debug = 'Y') THEN
                             asn_debug.put_line('x_converted_parent_trx_qty:' || x_converted_parent_trx_qty);
                         END IF;

                     END IF;
                     /* Bug#5369121 - END */
            ELSE --}{ this is a positive correction
               IF (int_org_cor_rec.parent_transaction_type NOT IN('RECEIVE')) THEN
                  l_grand_parent_trx_id  := int_org_cor_rec.grand_parent_txn_id;
               ELSIF(int_org_cor_rec.parent_transaction_type IN('RECEIVE')) THEN
                  /* If parent is RECEIVE, grand parent is the source doc */
                  IF (temp_cascaded_table(current_n).parent_transaction_id IS NOT NULL) THEN
                     IF temp_cascaded_table(current_n).source_document_code = 'RMA' THEN
                        l_grand_parent_trx_id  := int_org_cor_rec.oe_order_line_id;
                     ELSE
                        l_grand_parent_trx_id  := int_org_cor_rec.shipment_line_id;
                     END IF;
                  ELSIF(temp_cascaded_table(current_n).parent_interface_txn_id IS NOT NULL) THEN
                     l_grand_parent_trx_id  := int_org_cor_rec.shipment_line_id;
                  END IF;
               END IF;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('grand parent trx id' || l_grand_parent_trx_id);
                  asn_debug.put_line('rcv_transaction id' || int_org_cor_rec.rcv_transaction_id);
                  asn_debug.put_line('parent txn type' || int_org_cor_rec.parent_transaction_type);
               END IF;

               IF (l_grand_parent_trx_id IS NOT NULL) THEN
                  rcv_quantities_s.get_available_quantity('CORRECT',
                                                          int_org_cor_rec.rcv_transaction_id,
                                                          temp_cascaded_table(current_n).receipt_source_code,
                                                          int_org_cor_rec.parent_transaction_type,
                                                          l_grand_parent_trx_id,
                                                          'POSITIVE',
                                                          x_converted_parent_trx_qty,
                                                          x_tolerable_qty,
                                                          int_org_cor_rec.unit_of_meas,
                                                          x_secondary_available_qty
                                                         );
               END IF;
            END IF; --}

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('qty from GET_AVAILABLE_QUANTITY for corrections is ' || x_converted_parent_trx_qty);
            END IF;
         END IF; --} matches the parent trx qty = 0

         IF (x_remaining_quantity = 0) THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line(' correct Need an error message in the interface tables');
            END IF;
         ELSE
            /* Converted successfully and have some quantity on which we can act */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Converted trx qty that is available ' || x_converted_parent_trx_qty);
               asn_debug.put_line('Remaining qty in parents uom that is available ' || x_remaining_quantity);
            END IF;

            IF (    (rows_fetched = x_record_count)
                AND (SIGN(temp_cascaded_table(current_n).quantity) = 1)) THEN --{
               x_converted_trx_qty  := x_tolerable_qty;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Last Row : ' || TO_CHAR(x_converted_trx_qty));
               END IF;
            END IF; --}

            IF (x_converted_parent_trx_qty > 0) THEN --{
               /* Compare with abs(x_remaining_qty) here since we want
                * to make sure that the qty we have is greater than
                * the available qty irrespective of whether this is
                * positive or negative correction.
               */
               IF (x_converted_parent_trx_qty < ABS(x_remaining_quantity)) THEN --{
                  /* Total quantity available to correct is less than the qty
                   * that the user wants to correct. Hence we would error out but
                   * to keep the old code we will get the remaining code here and
                   * error out later.
                   */
                  x_remaining_quantity        := x_remaining_quantity - SIGN(temp_cascaded_table(current_n).quantity) * x_converted_parent_trx_qty;
                  x_converted_parent_trx_qty  := SIGN(temp_cascaded_table(current_n).quantity) * x_converted_parent_trx_qty;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('remaning qty after allocation is : ' || TO_CHAR(x_remaining_quantity));
                  END IF;

                  insert_into_table           := TRUE;
               ELSE --}{
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('We are in >= Qty branch ');
                  END IF;

                  x_converted_parent_trx_qty  := x_remaining_quantity;
                  insert_into_table           := TRUE;
                  x_remaining_quantity        := 0;
               END IF; --} /* if (x_converted_parent_trx_qty < x_remaining_quantity) then */
            ELSE    /* x_converted_parent_trx_qty >0 */ --}{
                 -- so that the row can be used based on qty tolerance checks
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Quantity is less then 0 but last record');
               END IF;

               insert_into_table    := TRUE;
               x_converted_trx_qty  := 0;
            END IF; /*x_converted_parent_trx_qty >0 */ --}
         END IF;

         /* Converted qty successfully and we have some quantity on which we can act */
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Txn qty in terms of the parents uom is ' || x_converted_parent_trx_qty);
         END IF;

         IF insert_into_table THEN --{ --start
            IF (x_first_trans) THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('First Time ' || TO_CHAR(current_n));
               END IF;

               x_first_trans  := FALSE;
            ELSE --}{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Next Time ' || TO_CHAR(current_n));
               END IF;

               temp_cascaded_table(current_n)  := temp_cascaded_table(current_n - 1);
            END IF; --}

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('primary uom before ' || temp_cascaded_table(current_n).primary_unit_of_measure);
               asn_debug.put_line('normal uom is ' || int_org_cor_rec.unit_of_meas);
            END IF;

            temp_cascaded_table(current_n).primary_unit_of_measure  := int_org_cor_rec.primary_unit_of_measure;
            temp_cascaded_table(current_n).quantity                 := x_converted_parent_trx_qty;
            temp_cascaded_table(current_n).shipment_line_id         := int_org_cor_rec.shipment_line_id;

            IF (temp_cascaded_table(current_n).primary_unit_of_measure <> int_org_cor_rec.unit_of_meas) THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('primary uoms not the same and need to convert quantity');
               END IF;

               temp_cascaded_table(current_n).primary_quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_parent_trx_qty,
                                                                                                                int_org_cor_rec.unit_of_meas,
                                                                                                                temp_cascaded_table(current_n).item_id,
                                                                                                                temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                               );
            ELSE
               temp_cascaded_table(current_n).primary_quantity  := x_converted_parent_trx_qty;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('txn qty in primary uom is ' || temp_cascaded_table(current_n).primary_quantity);
            END IF;

            current_n                                               := current_n + 1;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Increment pointer by 1 ' || TO_CHAR(current_n));
            END IF;
         END IF; --}

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('finished assigning line qty for one row in cursor for IOT corrections ');
         END IF;
      END LOOP; --}

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before closing cursors current_n is ' || temp_cascaded_table.COUNT);
      END IF;

      IF int_org_cor_rt%ISOPEN THEN
         CLOSE int_org_cor_rt;
      END IF;

      IF int_org_cor_rti%ISOPEN THEN
         CLOSE int_org_cor_rti;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit explode_line_quantity');
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         IF int_org_cor_rt%ISOPEN THEN
            CLOSE int_org_cor_rt;
         END IF;

         IF int_org_cor_rti%ISOPEN THEN
            CLOSE int_org_cor_rti;
         END IF;
      WHEN OTHERS THEN
         IF int_org_cor_rt%ISOPEN THEN
            CLOSE int_org_cor_rt;
         END IF;

         IF int_org_cor_rti%ISOPEN THEN
            CLOSE int_org_cor_rti;
         END IF;

         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('derive_int_org_cor_line_qty', x_progress);
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
         rcv_error_pkg.log_interface_error('INTERFACE_TRANSACTION_ID');

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(n));
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('error ' || x_progress);
         END IF;
   END derive_int_org_cor_line_qty;

   PROCEDURE default_int_org_cor_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      p_trx_record                rcv_roi_header_common.common_default_record_type;

      CURSOR int_org_cor_rt(
         v_parent_trx_id NUMBER
      ) IS
         SELECT   rsl.item_description,
                  rt.location_id loc_id,
                  rt.organization_id,
                  rt.routing_header_id,
                  rt.destination_type_code,
                  rt.destination_context,
                  rt.inspection_status_code,
                  rt.currency_code,
                  rt.currency_conversion_rate,
                  rt.currency_conversion_type,
                  rt.currency_conversion_date,
                  rt.location_id,
                  rt.shipment_header_id,
                  rt.shipment_line_id,
                  rsl.category_id,
                  rt.deliver_to_person_id,
                  rt.deliver_to_location_id,
                  rt.subinventory,
                  rt.lpn_id,
                  rt.transfer_lpn_id,
                  rt.transaction_type
         FROM     rcv_transactions rt,
                  rcv_shipment_lines rsl
         WHERE    rt.transaction_id = v_parent_trx_id
         AND      rt.transaction_type IN('RECEIVE', 'TRANSFER', 'ACCEPT', 'REJECT')
         AND      rt.shipment_line_id = rsl.shipment_line_id
         ORDER BY rt.transaction_id;

      CURSOR int_org_cor_rti(
         v_parent_inter_trx_id NUMBER
      ) IS
         SELECT rti.item_description,
                rti.location_id loc_id,
                rti.to_organization_id organization_id,
                rti.routing_header_id,
                rti.destination_type_code,
                rti.destination_context,
                rti.inspection_status_code,
                rti.currency_code,
                rti.currency_conversion_rate,
                rti.currency_conversion_type,
                rti.currency_conversion_date,
                rti.location_id,
                rti.shipment_header_id,
                rti.shipment_line_id,
                rti.category_id,
                rti.deliver_to_person_id,
                rti.deliver_to_location_id,
                rti.subinventory,
                rti.lpn_id,
                rti.transfer_lpn_id,
                rti.transaction_type
         FROM   rcv_transactions_interface rti
         WHERE  interface_transaction_id = v_parent_inter_trx_id;

      --bug 3704623
      CURSOR int_org_cor_rsl(
         p_shipment_line_id rcv_shipment_lines.shipment_line_id%TYPE
      ) IS
         SELECT to_organization_id,
                from_organization_id
         FROM   rcv_shipment_lines
         WHERE  shipment_line_id = p_shipment_line_id;

      x_from_organization_id      rcv_shipment_lines.from_organization_id%TYPE;
      x_to_organization_id        rcv_shipment_lines.to_organization_id%TYPE;
      default_int_org_cor_rt_info int_org_cor_rt%ROWTYPE;
      x_progress                  VARCHAR2(3);
      temp_index                  NUMBER;
      lpn_error                   NUMBER                                           := 0;
   BEGIN
      p_trx_record.destination_type_code           := x_cascaded_table(n).destination_type_code;
      p_trx_record.transaction_type                := x_cascaded_table(n).transaction_type;
      p_trx_record.processing_mode_code            := x_cascaded_table(n).processing_mode_code;
      p_trx_record.processing_status_code          := x_cascaded_table(n).processing_status_code;
      p_trx_record.transaction_status_code         := x_cascaded_table(n).transaction_status_code;
      p_trx_record.auto_transact_code              := x_cascaded_table(n).auto_transact_code;
      rcv_roi_header_common.commondefaultcode(p_trx_record);
      x_cascaded_table(n).destination_type_code    := p_trx_record.destination_type_code;
      x_cascaded_table(n).transaction_type         := p_trx_record.transaction_type;
      x_cascaded_table(n).processing_mode_code     := p_trx_record.processing_mode_code;
      x_cascaded_table(n).processing_status_code   := p_trx_record.processing_status_code;
      x_cascaded_table(n).transaction_status_code  := p_trx_record.transaction_status_code;
      x_cascaded_table(n).auto_transact_code       := p_trx_record.auto_transact_code;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter Default for IOT Corrections');
      END IF;

      IF (x_cascaded_table(n).derive = 'Y') THEN --{
         IF (x_cascaded_table(n).derive_index <> 0) THEN --{
            NULL;
            /* Get the values from pl/sql table */
            temp_index                                    := x_cascaded_table(n).derive_index;
            x_cascaded_table(n).item_description          := x_cascaded_table(temp_index).item_description;
            x_cascaded_table(n).destination_type_code     := x_cascaded_table(temp_index).destination_type_code;
            x_cascaded_table(n).destination_context       := x_cascaded_table(temp_index).destination_context;
            x_cascaded_table(n).inspection_status_code    := x_cascaded_table(temp_index).inspection_status_code;
            x_cascaded_table(n).to_organization_id        := x_cascaded_table(temp_index).to_organization_id;
            x_cascaded_table(n).from_organization_id      := x_cascaded_table(temp_index).from_organization_id;
            x_cascaded_table(n).routing_header_id         := x_cascaded_table(temp_index).routing_header_id;
            x_cascaded_table(n).currency_code             := x_cascaded_table(temp_index).currency_code;
            x_cascaded_table(n).currency_conversion_rate  := x_cascaded_table(temp_index).currency_conversion_rate;
            x_cascaded_table(n).currency_conversion_type  := x_cascaded_table(temp_index).currency_conversion_type;
            x_cascaded_table(n).currency_conversion_date  := x_cascaded_table(temp_index).currency_conversion_date;
            x_cascaded_table(n).shipment_header_id        := x_cascaded_table(temp_index).shipment_header_id;
            x_cascaded_table(n).shipment_line_id          := x_cascaded_table(temp_index).shipment_line_id;
            x_cascaded_table(n).category_id               := x_cascaded_table(temp_index).category_id;

            -- LPN defaulting
            IF (x_cascaded_table(n).quantity > 0) THEN
               -- for +ve corrections :
               -- we are defaulting the parent's from_lpn to child's from_lpn
               -- and parent's to_lpn to child's to_lpn
               -- only if those fields are null
               IF (x_cascaded_table(n).lpn_id IS NULL) THEN
                  x_cascaded_table(n).lpn_id  := x_cascaded_table(temp_index).lpn_id;

                  IF (x_cascaded_table(n).lpn_id IS NOT NULL) THEN
                     lpn_error  := 1;
                  END IF;
               END IF;

               IF (x_cascaded_table(n).transfer_lpn_id IS NULL) THEN
                  x_cascaded_table(n).transfer_lpn_id  := x_cascaded_table(temp_index).transfer_lpn_id;

                  IF (x_cascaded_table(n).transfer_lpn_id IS NOT NULL) THEN
                     lpn_error  := 1;
                  END IF;
               END IF;

               --insert warning message into po_interface_errors
               IF (lpn_error = 1) THEN
                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
                  rcv_error_pkg.set_error_message('RCV_LPN_UNPACK_WARNING', x_cascaded_table(n).error_message);
                  rcv_error_pkg.set_token('LPN_ID', x_cascaded_table(n).lpn_id);
                  rcv_error_pkg.log_interface_warning('LPN_ID');
               END IF;
            ELSE -- its a -ve correction
                  -- for -ve corrections :
                  -- we are defaulting the parent's from_lpn to child's to_lpn
                  -- and parent's to_lpn to child's from_lpn
                  -- only if those fields are null
               IF (x_cascaded_table(n).lpn_id IS NULL) THEN
                  x_cascaded_table(n).lpn_id  := x_cascaded_table(temp_index).transfer_lpn_id;

                  IF (x_cascaded_table(n).lpn_id IS NOT NULL) THEN
                     lpn_error  := 1;
                  END IF;
               END IF;

               IF (x_cascaded_table(n).transfer_lpn_id IS NULL) THEN
                  x_cascaded_table(n).transfer_lpn_id  := x_cascaded_table(temp_index).lpn_id;

                  IF (x_cascaded_table(n).transfer_lpn_id IS NOT NULL) THEN
                     lpn_error  := 1;
                  END IF;
               END IF;

               --insert warning message into po_interface_errors
               IF (lpn_error = 1) THEN
                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
                  rcv_error_pkg.set_error_message('RCV_LPN_UNPACK_WARNING', x_cascaded_table(n).error_message);
                  rcv_error_pkg.set_token('LPN_ID', x_cascaded_table(n).lpn_id);
                  rcv_error_pkg.log_interface_warning('LPN_ID');
               END IF;
            END IF;

            x_cascaded_table(n).location_id               := x_cascaded_table(temp_index).location_id;
            x_cascaded_table(n).deliver_to_person_id      := x_cascaded_table(temp_index).deliver_to_person_id;
            x_cascaded_table(n).deliver_to_location_id    := x_cascaded_table(temp_index).deliver_to_location_id;
            x_cascaded_table(n).subinventory              := x_cascaded_table(temp_index).subinventory;
         ELSE --} {
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('open cursor Default');
            END IF;

            OPEN int_org_cor_rti(x_cascaded_table(n).parent_interface_txn_id);
         END IF; --}
      ELSE -- } {
         OPEN int_org_cor_rt(x_cascaded_table(n).parent_transaction_id);
      END IF; --}

      IF (int_org_cor_rt%ISOPEN) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('fetch cursor Default ' || x_cascaded_table(n).parent_transaction_id);
         END IF;

         FETCH int_org_cor_rt INTO default_int_org_cor_rt_info;
      ELSIF(int_org_cor_rti%ISOPEN) THEN
         FETCH int_org_cor_rti INTO default_int_org_cor_rt_info;
      END IF;

      IF (   (    int_org_cor_rt%ISOPEN
              AND int_org_cor_rt%FOUND)
          OR (    int_org_cor_rti%ISOPEN
              AND int_org_cor_rti%FOUND)) THEN                                                           --{
                                               -- bug 3704623, if a shipment line is specified, use the shipment line's to_org and from_org id's
         IF (    default_int_org_cor_rt_info.shipment_line_id IS NOT NULL
             AND default_int_org_cor_rt_info.transaction_type = 'RECEIVE') THEN
            OPEN int_org_cor_rsl(default_int_org_cor_rt_info.shipment_line_id);
            FETCH int_org_cor_rsl INTO x_to_organization_id,
             x_from_organization_id;
            CLOSE int_org_cor_rsl;
         END IF;

         IF (g_asn_debug = 'Y') THEN --{
            asn_debug.put_line('Defaulting Cor item_description' || default_int_org_cor_rt_info.item_description);
            asn_debug.put_line('Defaulting Cor location_id' || default_int_org_cor_rt_info.loc_id);
            asn_debug.put_line('Defaulting Cor to organization_id' || NVL(x_to_organization_id, default_int_org_cor_rt_info.organization_id));
            asn_debug.put_line('Defaulting Cor from organization_id' || NVL(x_from_organization_id, default_int_org_cor_rt_info.organization_id));
            asn_debug.put_line('Defaulting Cor routing_header_id' || default_int_org_cor_rt_info.routing_header_id);
            asn_debug.put_line('Defaulting Cor currency_code' || default_int_org_cor_rt_info.currency_code);
            asn_debug.put_line('Defaulting Cor currency_conversion_rate' || default_int_org_cor_rt_info.currency_conversion_rate);
            asn_debug.put_line('Defaulting Cor currency_conversion_type' || default_int_org_cor_rt_info.currency_conversion_type);
            asn_debug.put_line('Defaulting cor currency_conversion_date' || default_int_org_cor_rt_info.currency_conversion_date);
            asn_debug.put_line('Defaulting cor shipment_header_id' || default_int_org_cor_rt_info.shipment_header_id);
            asn_debug.put_line('Defaulting cor shipment_line_id' || default_int_org_cor_rt_info.shipment_line_id);
            asn_debug.put_line('Defaulting cor category_id' || default_int_org_cor_rt_info.category_id);
            asn_debug.put_line('Defaulting cor DELIVER_TO_PERSON_ID' || default_int_org_cor_rt_info.deliver_to_person_id);
            asn_debug.put_line('Defaulting Corr DELIVER_TO_LOCATION_ID' || default_int_org_cor_rt_info.deliver_to_location_id);
            asn_debug.put_line('Defaulting Cor subinv' || default_int_org_cor_rt_info.subinventory);
         END IF; --}

         x_cascaded_table(n).item_description          := default_int_org_cor_rt_info.item_description;
         x_cascaded_table(n).destination_type_code     := default_int_org_cor_rt_info.destination_type_code;
         x_cascaded_table(n).destination_context       := default_int_org_cor_rt_info.destination_context;
         x_cascaded_table(n).inspection_status_code    := default_int_org_cor_rt_info.inspection_status_code;
         x_cascaded_table(n).to_organization_id        := NVL(x_to_organization_id, default_int_org_cor_rt_info.organization_id);
         x_cascaded_table(n).from_organization_id      := NVL(x_from_organization_id, default_int_org_cor_rt_info.organization_id);
         x_cascaded_table(n).routing_header_id         := default_int_org_cor_rt_info.routing_header_id;
         x_cascaded_table(n).currency_code             := default_int_org_cor_rt_info.currency_code;
         x_cascaded_table(n).currency_conversion_rate  := default_int_org_cor_rt_info.currency_conversion_rate;
         x_cascaded_table(n).currency_conversion_type  := default_int_org_cor_rt_info.currency_conversion_type;
         x_cascaded_table(n).currency_conversion_date  := default_int_org_cor_rt_info.currency_conversion_date;
         x_cascaded_table(n).shipment_header_id        := default_int_org_cor_rt_info.shipment_header_id;
         x_cascaded_table(n).shipment_line_id          := default_int_org_cor_rt_info.shipment_line_id;
         x_cascaded_table(n).category_id               := default_int_org_cor_rt_info.category_id;
         x_cascaded_table(n).location_id               := default_int_org_cor_rt_info.loc_id;
         x_cascaded_table(n).deliver_to_person_id      := default_int_org_cor_rt_info.deliver_to_person_id;
         x_cascaded_table(n).deliver_to_location_id    := default_int_org_cor_rt_info.deliver_to_location_id;
         x_cascaded_table(n).subinventory              := default_int_org_cor_rt_info.subinventory;

         -- LPN defaulting
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(' defaulting lpn_id and transfer_lpn_id for int org cor');
         END IF;

         IF (x_cascaded_table(n).quantity > 0) THEN                                        --{
                                                    -- for +ve corrections :
                                                       -- we are defaulting the parent's from_lpn to child's from_lpn
                                                       -- and parent's to_lpn to child's to_lpn
                                                       -- only if those fields are null
            IF (x_cascaded_table(n).lpn_id IS NULL) THEN
               x_cascaded_table(n).lpn_id  := default_int_org_cor_rt_info.lpn_id;

               IF (x_cascaded_table(n).lpn_id IS NOT NULL) THEN
                  lpn_error  := 1;
               END IF;
            END IF;

            IF (x_cascaded_table(n).transfer_lpn_id IS NULL) THEN
               x_cascaded_table(n).transfer_lpn_id  := default_int_org_cor_rt_info.transfer_lpn_id;

               IF (x_cascaded_table(n).transfer_lpn_id IS NOT NULL) THEN
                  lpn_error  := 1;
               END IF;
            END IF;

            --insert warning message into po_interface_errors
            IF (lpn_error = 1) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
               rcv_error_pkg.set_error_message('RCV_LPN_UNPACK_WARNING', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('LPN_ID', x_cascaded_table(n).lpn_id);
               rcv_error_pkg.log_interface_warning('LPN_ID');
            END IF;
         ELSE   -- its a -ve correction
              -- for -ve corrections :
                 -- we are defaulting the parent's from_lpn to child's to_lpn
                 -- and parent's to_lpn to child's from_lpn
                 -- only if those fields are null
            IF (x_cascaded_table(n).lpn_id IS NULL) THEN
               x_cascaded_table(n).lpn_id  := default_int_org_cor_rt_info.transfer_lpn_id;

               IF (x_cascaded_table(n).lpn_id IS NOT NULL) THEN
                  lpn_error  := 1;
               END IF;
            END IF;

            IF (x_cascaded_table(n).transfer_lpn_id IS NULL) THEN
               x_cascaded_table(n).transfer_lpn_id  := default_int_org_cor_rt_info.lpn_id;

               IF (x_cascaded_table(n).transfer_lpn_id IS NOT NULL) THEN
                  lpn_error  := 1;
               END IF;
            END IF;

            --insert warning message into po_interface_errors
            IF (lpn_error = 1) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_warning;
               rcv_error_pkg.set_error_message('RCV_LPN_UNPACK_WARNING', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('LPN_ID', x_cascaded_table(n).lpn_id);
               rcv_error_pkg.log_interface_warning('LPN_ID');
            END IF;
         END IF; --}
      END IF; -- if po_transfer%found is true }

      /* Default the from and to subinventory and locator_id */
      ----WMS Changes
      rcv_roi_transaction.default_from_subloc_info(x_cascaded_table, n);
      rcv_roi_transaction.default_to_subloc_info(x_cascaded_table, n);

      /*
      BEGIN Comment: Bug: 4735484

      SELECT NVL(x_cascaded_table(n).use_mtl_lot, lot_control_code),
             NVL(x_cascaded_table(n).use_mtl_serial, serial_number_control_code)
      INTO   x_cascaded_table(n).use_mtl_lot,
             x_cascaded_table(n).use_mtl_serial
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = x_cascaded_table(n).item_id
      AND    mtl_system_items.organization_id = x_cascaded_table(n).to_organization_id;

      END Comment: Bug: 4735484
      */
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Set Location_id  = ' || TO_CHAR(x_cascaded_table(n).location_id));
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit default_int_org_cor_line');
      END IF;

      IF int_org_cor_rt%ISOPEN THEN
         CLOSE int_org_cor_rt;
      END IF;

      IF int_org_cor_rti%ISOPEN THEN
         CLOSE int_org_cor_rti;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END default_int_org_cor_line;
------corrections--------------------------------

/* Bug 3735972.
 * We used to call validate_ref_integrity that had code only for PO.
 * We need to have a similar one to validate internal orders and
 * inter-org shipments.
*/

    PROCEDURE validate_ref_integrity(
        x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                IN            BINARY_INTEGER,
        x_header_record  IN            rcv_roi_preprocessor.header_rec_type
    ) IS
        x_error_status       VARCHAR2(1);
	x_header_id number;
    BEGIN

	IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
            RETURN;
        END IF;

        /* Bug 3883367.  Do NOT validate ref integrity if x_header_record.header_record.receipt_header_id */
        IF (x_header_record.header_record.receipt_header_id IS NULL) THEN
            RETURN;
        END IF;

	x_error_status  := rcv_error_pkg.g_ret_sts_error;

	IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating ref integrity');
        END IF;

	IF (g_asn_debug = 'Y') THEN
	        asn_debug.put_line('transaction_type '||(x_cascaded_table(n).transaction_type ));
		asn_debug.put_line('shipment_header_id '||(x_header_record.header_record.receipt_header_id ));
		asn_debug.put_line('shipment_line_id '||(x_cascaded_table(n).shipment_line_id ));
	end if;
	/* Get the shipment_header_id for that shipment_line_id and the
	 * shipment_header_id in the header record. If you dont get it then
	 * this means that you are trying to receive a shipment line that
	 * does not belong to the shipment header_id (hence shipment num)
	 * in the header and so error out.
	*/
        If (x_cascaded_table(n).transaction_type = 'RECEIVE') then
                select nvl(max(shipment_header_id),0)
                into x_header_id
                from rcv_shipment_lines
                where shipment_header_id =
                        x_header_record.header_record.receipt_header_id
                and shipment_line_id = x_cascaded_table(n).shipment_line_id;

		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('max shipment_header_id '||x_header_id );
		end if;

                IF (x_header_id = 0) THEN
			IF (g_asn_debug = 'Y') THEN
				asn_debug.put_line('No header id found. This shipment line does not belong to the same shipment as that of the header' );
			end if;
			rcv_error_pkg.set_error_message('RCV_INTORD_MISMATCH_SHIPMENTS');
			RAISE e_validation_error;

                else
			IF (g_asn_debug = 'Y') THEN
				asn_debug.put_line('Header id found' );
			end if;
                END IF;

        end if;
    EXCEPTION
        WHEN e_validation_error THEN
            x_cascaded_table(n).error_status   := x_error_status;
            x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

	    IF x_cascaded_table(n).error_message = 'RCV_INTORD_MISMATCH_SHIPMENTS' THEN
		rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'SHIPMENT_HEADER_ID');

	    end if;
    END validate_ref_integrity;


END rcv_int_org_transfer;


/
