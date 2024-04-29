--------------------------------------------------------
--  DDL for Package Body RCV_PROCESSOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_PROCESSOR_PVT" AS
/* $Header: RCVPROCB.pls 120.2.12010000.5 2012/03/08 03:23:05 honwei ship $ */
--
-- Purpose: To maintain reservation
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- pparthas      07/24/03 Created Package
--

   g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

   PROCEDURE insert_rcv_lots_supply(
      p_api_version              IN            NUMBER,
      p_init_msg_list            IN            VARCHAR2,
      x_return_status            OUT NOCOPY    VARCHAR2,
      p_interface_transaction_id IN            NUMBER,
      p_shipment_line_id         IN            NUMBER,
      p_supply_source_id         IN            NUMBER,
      p_source_type_code         IN            VARCHAR2,
      p_transaction_type         IN            VARCHAR2
   ) IS
      CURSOR c IS
         SELECT rls.ROWID
         FROM   rcv_lots_supply rls,
                rcv_transactions rt
         WHERE  rt.interface_transaction_id = p_interface_transaction_id
         AND    rls.transaction_id = rt.transaction_id;

      l_rowid                     VARCHAR2(255);
      l_transaction_id            rcv_transactions.transaction_id%TYPE;
      l_lot_count                 NUMBER;
      l_organization_id           NUMBER;
      l_lpn_id                    rcv_supply.lpn_id%TYPE;
      l_validation_flag           rcv_transactions_interface.validation_flag%TYPE;

      CURSOR lot_numbers(
         l_interface_id NUMBER
      ) IS
         SELECT   mtlt.lot_number,
                  SUM(mtlt.primary_quantity),
                  SUM(mtlt.transaction_quantity),
                  rti.shipment_line_id, --Bug 7443786
                  rti.item_id,
                  rti.unit_of_measure,
                  rti.to_organization_id
         FROM     mtl_transaction_lots_temp mtlt,
                  rcv_transactions_interface rti
         WHERE    product_transaction_id = l_interface_id
         AND      product_code = 'RCV'
         AND      rti.interface_transaction_id = mtlt.product_transaction_id
         GROUP BY mtlt.lot_number,
                  rti.shipment_header_id,
                  rti.shipment_line_id,
                  rti.item_id,
                  rti.unit_of_measure,
                  rti.to_organization_id;

      /* Bug 4870857: Added condition for shipment_line_id in the Exists clause
      **              to restrict the rows returned by the Cursor within a
      **              given shipment header.
      */

      /* Bug 7443786: Modified the cursor supply_quantity query to drive
      **             by the shipment_line_id instead of shipment_header_id,
      **             as it results in data corruption.
      */

      /* add rowid for bug 9839004 */
      CURSOR supply_quantity(
         l_lot_num            VARCHAR2,
         l_shipment_line_id NUMBER
      ) IS
         SELECT rls.rowid,
                rls.quantity,
                rls.primary_quantity
         FROM   rcv_lots_supply rls
         WHERE  rls.lot_num = l_lot_num
         AND    rls.supply_type_code = 'SHIPMENT'
         AND    rls.shipment_line_id = l_shipment_line_id;

      l_lot_num                   rcv_lots_supply.lot_num%TYPE;
      l_qty_to_be_updated         NUMBER;
      l_primary_qty_to_be_updated NUMBER;
      l_ship_id                   NUMBER;
      l_ship_line_id              NUMBER;
      l_rls_qty                   NUMBER;
      l_rls_primary_qty           NUMBER;
      l_item_id                   rcv_transactions_interface.item_id%TYPE;
      l_parent_uom                VARCHAR2(25);
      l_txn_uom                   VARCHAR2(25);
      l_primary_uom               VARCHAR2(25);
      l_to_org_id                 NUMBER;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_shipment_line_id ' || p_shipment_line_id);
         asn_debug.put_line('p_supply_source_id ' || p_supply_source_id);
         asn_debug.put_line('p_source_type_code ' || p_source_type_code);
         asn_debug.put_line('p_transaction_type ' || p_transaction_type);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_lot_count
      FROM   mtl_transaction_lots_temp mtlt
      WHERE  mtlt.product_transaction_id = p_interface_transaction_id
      AND    mtlt.product_code = 'RCV';

      IF (l_lot_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_lot_count ' || l_lot_count);
      END IF;

      /* We need to insert into rcv_lots_supply and
       * rcv_serials_supply table only when we come through ROI
       * or when we come through desktop and have lpn info.
       * We insert lpn_id in rcv_supply. So return if there is
       * a value and validation_flag is N.
      */
      SELECT NVL(validation_flag, 'N')
      INTO   l_validation_flag
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      SELECT NVL(lpn_id, -999)
      INTO   l_lpn_id
      FROM   rcv_supply
      WHERE  supply_source_id = p_supply_source_id;

      IF (    l_validation_flag = 'N'
          AND l_lpn_id = -999) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_validation_flag ' || l_validation_flag);
         asn_debug.put_line('l_lpn_id ' || l_lpn_id);
      END IF;

      SELECT transaction_id,
             organization_id
      INTO   l_transaction_id,
             l_organization_id
      FROM   rcv_transactions rt
      WHERE  rt.interface_transaction_id = p_interface_transaction_id;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before insert_lot_supply');
      END IF;

      insert_lot_supply(p_interface_transaction_id,
                        'RECEIVING',
                        p_supply_source_id,
                        x_return_status
                       );

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('After insert_lot_supply');
      END IF;

      /* If this is a receive for an internal shipment or interorg transfer
       * then we need to update the values for the shipment
       * supply in rcv_lots_supply.
      */
      /* INVCONV , update for process transactions also.
         Remove the process specific restriction. Punit Kumar */

      -- roi enhacements for OPM.bug# 3061052
      -- don't update for OPM transactions.

     /* IF (gml_process_flags.check_process_orgn(p_organization_id    => l_organization_id) = 0) THEN */

         IF (    p_transaction_type = 'RECEIVE'
             AND p_source_type_code IN('INVENTORY', 'REQ')) THEN --{
            /* Bug 3376348, 3459830.
             * It might happen that the original shipment lines are split
             * into multiple shipment_lines (when lpn has 2 lots for eg).
             * So instead of using shipment_line_id to delete use
             * shipment_header_id.
            */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('In insert rcv_lots_supply for source type code INVENTORY or REQ');
            END IF;

            OPEN lot_numbers(p_interface_transaction_id);

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Opened lot_numbers cursor');
            END IF;

            LOOP --{
               FETCH lot_numbers INTO l_lot_num,
                l_primary_qty_to_be_updated,
                l_qty_to_be_updated,
                l_ship_line_id,
                l_item_id,
                l_txn_uom,
                l_to_org_id;
               EXIT WHEN lot_numbers%NOTFOUND;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('After fetch');
                  asn_debug.put_line('l_lot_num ' || l_lot_num);
                  asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                  asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                  asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                  asn_debug.put_line('l_item_id ' || l_item_id);
                  asn_debug.put_line('l_txn_uom ' || l_txn_uom);
                  asn_debug.put_line('l_to_org_id ' || l_to_org_id);
               END IF;

               SELECT MAX(primary_unit_of_measure)
               INTO   l_primary_uom
               FROM   mtl_system_items
               WHERE  mtl_system_items.inventory_item_id = l_item_id
               AND    mtl_system_items.organization_id = l_to_org_id;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('l_primary_uom ' || l_primary_uom);
               END IF;

               /* l_qty_to_be_updated shd be in
                * terms of the parent's uom. For
                * shipment supply qty, it must be
                * in terms of uom in rsl.
               */
               OPEN supply_quantity(l_lot_num,
                                    l_ship_line_id --Bug 7443786
                                   );

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Opened supply_quantity cursor');
               END IF;

               /* add rowid for bug 9839004 */
               LOOP --{
                  FETCH supply_quantity INTO l_rowid, l_rls_qty,
                   l_rls_primary_qty;
                  EXIT WHEN supply_quantity%NOTFOUND
                        OR l_primary_qty_to_be_updated = 0;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('l_rowid ' || l_rowid);
                     asn_debug.put_line('l_rls_qty ' || l_rls_qty);
                     asn_debug.put_line('l_rls_primary_qty ' || l_rls_primary_qty);
                     asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                  END IF;

                  SELECT unit_of_measure
                  INTO   l_parent_uom
                  FROM   rcv_shipment_lines
                  WHERE  shipment_line_id = l_ship_line_id;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('l_parent_uom ' || l_parent_uom);
                  END IF;

                  IF (l_txn_uom <> l_parent_uom) THEN
                     l_qty_to_be_updated  := rcv_transactions_interface_sv.convert_into_correct_qty(l_primary_qty_to_be_updated,
                                                                                                    l_primary_uom,
                                                                                                    l_item_id,
                                                                                                    l_parent_uom
                                                                                                   );
                  END IF;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                     asn_debug.put_line('l_rls_primary_qty ' || l_rls_primary_qty);
                     asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                  END IF;

                  IF (l_rls_primary_qty >= l_primary_qty_to_be_updated) THEN --{
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('rls primary qty greater');
                        asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                        asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                        asn_debug.put_line('l_lot_num ' || l_lot_num);
                        asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                     END IF;

                     /* add rowid for bug 9839004 */
                     UPDATE rcv_lots_supply rls
                        SET quantity = quantity - l_qty_to_be_updated,
                            primary_quantity = primary_quantity - l_primary_qty_to_be_updated
                      WHERE rls.lot_num = l_lot_num
                     AND    shipment_line_id = l_ship_line_id
                     AND    rls.supply_type_code = 'SHIPMENT'
                     AND    rls.rowid = l_rowid;

                     l_qty_to_be_updated          := 0;
                     l_primary_qty_to_be_updated  := 0;
                  ELSE --}{
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('rls primary qty lesser');
                        asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                        asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                        asn_debug.put_line('l_lot_num ' || l_lot_num);
                        asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                     END IF;

                     /* add rowid for bug 9839004 */
                     UPDATE rcv_lots_supply rls
                        SET quantity = 0,
                            primary_quantity = 0
                      WHERE rls.lot_num = l_lot_num
                     AND    shipment_line_id = l_ship_line_id
                     AND    rls.supply_type_code = 'SHIPMENT'
                     AND    rls.rowid = l_rowid;

                     l_qty_to_be_updated          := l_qty_to_be_updated - l_rls_qty;
                     l_primary_qty_to_be_updated  := l_primary_qty_to_be_updated - l_rls_primary_qty;

                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                        asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                     END IF;
                  END IF; --}
               END LOOP; --}

               CLOSE supply_quantity;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Close supply_quantity ');
               END IF;
	       IF l_primary_qty_to_be_updated <> 0 THEN --Bug 7443786
 	          asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
 	          asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
 	          /*Bug 13792458 when ISO or IOT from_organization is not lot controlled, it will not consume rcv_lots_supply quantity */
 	          --asn_debug.put_line('SHIPMENT supply for above qty not available to consume..Fail the transaction...');
 	          --raise NO_DATA_FOUND;
 	          /*End Bug 13792458 */
 	       END IF; --Bug 7443786
            END LOOP; --}

            CLOSE lot_numbers;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Close lot_numbers cursor for source type code INVENTORY or REQ');
            END IF;
         END IF; --}
    /*  END IF; */

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit insert_rcv_lots_supply');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no_data_found insert_rcv_lots_supply');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_INSERT_LOT_SUPPLY_FAIL',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('others insert_rcv_lots_supply');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_INSERT_LOT_SUPPLY_ERROR',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
   END insert_rcv_lots_supply;

--
   PROCEDURE insert_rcv_serials_supply(
      p_api_version              IN            NUMBER,
      p_init_msg_list            IN            VARCHAR2,
      x_return_status            OUT NOCOPY    VARCHAR2,
      p_interface_transaction_id IN            NUMBER,
      p_shipment_line_id         IN            NUMBER,
      p_supply_source_id         IN            NUMBER,
      p_source_type_code         IN            VARCHAR2,
      p_transaction_type         IN            VARCHAR2
   ) IS
      CURSOR select_serials(
         p_interface_transaction_id NUMBER
      ) IS
         SELECT msnt.fm_serial_number,
                msnt.to_serial_number,
                mtlt.lot_number
         FROM   mtl_serial_numbers_temp msnt,
                mtl_transaction_lots_temp mtlt
         WHERE  msnt.product_transaction_id = p_interface_transaction_id
         AND    msnt.product_code = 'RCV'
         AND    msnt.transaction_temp_id = mtlt.serial_transaction_temp_id(+);

      l_select_serials         select_serials%ROWTYPE;
      l_serial_prefix          VARCHAR2(31);
      l_from_serial_number     NUMBER;
      l_to_serial_number       NUMBER;
      l_serial_num_length      NUMBER;
      l_prefix_length          NUMBER;
      l_cur_serial_numeric     NUMBER;
      l_cur_serial_number      VARCHAR2(30);
      l_range_numbers          NUMBER;
      l_serial_suffix_length   NUMBER;
      l_delete_shipment_supply VARCHAR2(1)                                       := 'N';
      l_transaction_id         rcv_transactions.transaction_id%TYPE;
      l_serial_count           NUMBER;
      l_lpn_id                 rcv_supply.lpn_id%TYPE;
      l_validation_flag        rcv_transactions_interface.validation_flag%TYPE;
      l_shipment_header_id     rcv_shipment_headers.shipment_header_id%TYPE;
      l_item_id                rcv_transactions_interface.item_id%TYPE;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_shipment_line_id ' || p_shipment_line_id);
         asn_debug.put_line('p_supply_source_id ' || p_supply_source_id);
         asn_debug.put_line('p_source_type_code ' || p_source_type_code);
         asn_debug.put_line('p_transaction_type ' || p_transaction_type);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_serial_count
      FROM   mtl_serial_numbers_temp msnt
      WHERE  msnt.product_transaction_id = p_interface_transaction_id
      AND    msnt.product_code = 'RCV';

      IF (l_serial_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_serial_count ' || l_serial_count);
      END IF;

      /* We need to insert into rcv_lots_supply and
       * rcv_serials_supply table only when we come through ROI
       * or when we come through desktop and have lpn info.
       * We insert lpn_id in rcv_supply. So return if there is
       * a value and validation_flag is N.
      */
      SELECT NVL(validation_flag, 'N')
      INTO   l_validation_flag
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      SELECT NVL(lpn_id, -999)
      INTO   l_lpn_id
      FROM   rcv_supply
      WHERE  supply_source_id = p_supply_source_id;

      IF (    l_validation_flag = 'N'
          AND l_lpn_id = -999) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_validation_flag ' || l_validation_flag);
         asn_debug.put_line('l_lpn_id ' || l_lpn_id);
      END IF;

      OPEN select_serials(p_interface_transaction_id);

      /* If this is a receive for an internal shipment or interorg transfer
       *  then we need to delete the values for the shipment
       * supply in rcv_shipment_supply since we would have created the
       * receiving supply for the serial numbers that are used for
       * receiving. Set l_delete_shipment_supply to Y. This will be
       * used later to delete the shipment serial supply row.
      */
      IF (    p_transaction_type = 'RECEIVE'
          AND p_source_type_code IN('INVENTORY', 'REQ')) THEN
         l_delete_shipment_supply  := 'Y';
      END IF;

      LOOP --{
         FETCH select_serials INTO l_select_serials;
         EXIT WHEN select_serials%NOTFOUND;
         split_serial_number(l_select_serials.fm_serial_number,
                             l_serial_prefix,
                             l_from_serial_number
                            );
         split_serial_number(l_select_serials.to_serial_number,
                             l_serial_prefix,
                             l_to_serial_number
                            );
         l_range_numbers      := l_to_serial_number - l_from_serial_number + 1;
         l_serial_num_length  := LENGTH(l_select_serials.fm_serial_number);

         /* Start Bug#3359105: Modified the following code to consider
          * the case when the Serial number is numeric instead of being
          * alphanumeric. In this case l_serial_prefix is NULL and
          * so needs proper handling.
              */
         IF l_serial_prefix IS NOT NULL THEN
            l_prefix_length         := LENGTH(l_serial_prefix);
            l_serial_suffix_length  := l_serial_num_length - l_prefix_length;
         ELSE
            l_prefix_length         := 0;
            l_serial_suffix_length  := l_serial_num_length;
         END IF;

         /* End  Bug#3359105 */
         SELECT transaction_id
         INTO   l_transaction_id
         FROM   rcv_transactions rt
         WHERE  rt.interface_transaction_id = p_interface_transaction_id;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_range_numbers ' || l_range_numbers);
            asn_debug.put_line('l_serial_num_length ' || l_serial_num_length);
            asn_debug.put_line('l_prefix_length ' || l_prefix_length);
            asn_debug.put_line('l_serial_suffix_length ' || l_serial_suffix_length);
         END IF;

         FOR i IN 1 .. l_range_numbers LOOP --{
            l_cur_serial_numeric  := l_from_serial_number + i - 1;
            --l_cur_serial_number :=l_serial_prefix || l_cur_serial_numeric;
            l_cur_serial_number   := l_serial_prefix || LPAD(TO_CHAR(l_cur_serial_numeric),
                                                             l_serial_suffix_length,
                                                             '0'
                                                            );

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_serial_prefix ' || l_serial_prefix);
               asn_debug.put_line('l_cur_serial_numeric ' || l_cur_serial_numeric);
               asn_debug.put_line('l_serial_suffix_length ' || l_serial_suffix_length);
               asn_debug.put_line('l_cur_serial_number ' || l_serial_suffix_length);
            END IF;

            insert_serial_supply(p_interface_transaction_id,
                                 l_select_serials.lot_number,
                                 l_cur_serial_number,
                                 'RECEIVING',
                                 p_supply_source_id,
                                 x_return_status
                                );

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('After insert_serial_supply ');
            END IF;
         END LOOP; --}

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_delete_shipment_supply ' || l_delete_shipment_supply);
         END IF;

         IF (l_delete_shipment_supply = 'Y') THEN
            SELECT shipment_header_id,
                   item_id
            INTO   l_shipment_header_id,
                   l_item_id
            FROM   rcv_shipment_lines
            WHERE  shipment_line_id = p_shipment_line_id;

            /* Bug 3376348.
             * It might happen that the original shipment lines are split
             * into multiple shipment_lines (when lpn has 2 lots for eg).
             * So instead of using shipment_line_id to delete use
             * shipment_header_id.
            */
            DELETE FROM rcv_serials_supply rss
                  WHERE supply_type_code = 'SHIPMENT'
            AND         (   l_select_serials.lot_number IS NULL
                         OR NVL(lot_num, l_select_serials.lot_number) = l_select_serials.lot_number)
            AND         (serial_num BETWEEN(l_serial_prefix || LPAD(TO_CHAR(l_from_serial_number),
                                                                    l_serial_suffix_length,
                                                                    '0'
                                                                   )) AND(l_serial_prefix || LPAD(TO_CHAR(l_to_serial_number),
                                                                                                  l_serial_suffix_length,
                                                                                                  '0'
                                                                                                 )))
            AND         EXISTS(SELECT 1
                               FROM   rcv_shipment_lines rsl
                               WHERE  rsl.shipment_header_id = l_shipment_header_id
                               AND    rsl.shipment_line_id = rss.shipment_line_id
                               AND    rsl.item_id = l_item_id);
         END IF;
      END LOOP; --}

      CLOSE select_serials;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit insert_rcv_serials_supply ');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no_data_found insert_rcv_serials_supply ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_INSERT_SERIAL_SUPPLY_FAIL',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('others insert_rcv_serials_supply ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_INSERT_SERIAL_SUPPLY_ERROR',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
   END insert_rcv_serials_supply;

   PROCEDURE split_serial_number(
      p_sequence IN            VARCHAR2,
      x_prefix   OUT NOCOPY    VARCHAR2,
      x_number   OUT NOCOPY    NUMBER
   ) IS
      l_ascii_0                  NUMBER;
      l_ascii_code_minus_ascii_0 NUMBER;
      l_sequence_length          NUMBER;
      l_loop_index               NUMBER;
   BEGIN
      l_sequence_length  := LENGTH(p_sequence);
      l_loop_index       := l_sequence_length;
      l_ascii_0          := ASCII('0');

      WHILE l_loop_index >= 1 LOOP
         l_ascii_code_minus_ascii_0  := ASCII(SUBSTR(p_sequence,
                                                     l_loop_index,
                                                     1
                                                    )) - l_ascii_0;
         EXIT WHEN(   0 > l_ascii_code_minus_ascii_0
                   OR l_ascii_code_minus_ascii_0 > 9);
         l_loop_index                := l_loop_index - 1;
      END LOOP;

      IF (l_loop_index = 0) THEN
         x_prefix  := '';
         x_number  := TO_NUMBER(p_sequence);
      ELSIF(l_loop_index = l_sequence_length) THEN
         x_prefix  := p_sequence;
         x_number  := -1;
      ELSE
         x_prefix  := SUBSTR(p_sequence,
                             1,
                             l_loop_index
                            );
         x_number  := TO_NUMBER(SUBSTR(p_sequence, l_loop_index + 1));
      END IF;
   END split_serial_number;

   PROCEDURE update_rcv_lots_supply(
      p_api_version              IN            NUMBER,
      p_init_msg_list            IN            VARCHAR2,
      x_return_status            OUT NOCOPY    VARCHAR2,
      p_interface_transaction_id IN            NUMBER,
      p_transaction_type         IN            VARCHAR2,
      p_shipment_line_id         IN            NUMBER,
      p_source_type_code         IN            VARCHAR2,
      p_parent_supply_id         IN            NUMBER,
      p_correction_type          IN            VARCHAR2
   ) IS
      CURSOR lot_cursor(
         p_interface_id NUMBER
      ) IS

      /* INVCONV , Remove sublot_num as part of new lot model. Punit Kumar */

         /** OPM change Bug# 3061052 add sublot_num **/
         SELECT   mtlt.lot_number,
                  /* INVCONV */
               /*   mtlt.sublot_num, */
                  /* end , INVCONV*/
                  SUM(mtlt.primary_quantity),
                  SUM(mtlt.transaction_quantity),
                  SUM(mtlt.secondary_quantity),
                  rti.shipment_line_id, --Bug 7443786
                  rti.item_id,
                  rti.unit_of_measure,
                  rti.to_organization_id
         FROM     mtl_transaction_lots_temp mtlt,
                  rcv_transactions_interface rti
         WHERE    product_transaction_id = p_interface_id
         AND      product_code = 'RCV'
         AND      rti.interface_transaction_id = mtlt.product_transaction_id
         GROUP BY mtlt.lot_number,
                 /* INVCONV */
                 /* mtlt.sublot_num, */
                  /* end , INVCONV*/
                  rti.shipment_header_id,
                  rti.shipment_line_id,
                  rti.item_id,
                  rti.unit_of_measure,
                  rti.to_organization_id;

/** Bug 5571740:
 *      Changed the declaration of l_lot_num from varchar2(30) to rcv_lots_supply.lot_num%TYPE
 */
      l_lot_num                     rcv_lots_supply.lot_num%TYPE;
      l_factor                      NUMBER;
      l_parent_trans_type           rcv_transactions.transaction_type%TYPE;
      l_count                       NUMBER;
      l_count1                      NUMBER;
      l_count2                      NUMBER;
      l_transaction_id              rcv_transactions.transaction_id%TYPE;
      l_lot_count                   NUMBER;
      l_update_shipment_supply      VARCHAR2(1)                                       := 'N';
      l_organization_id             NUMBER;
      /* INVCONV*/
   /*   l_sublot_num                  VARCHAR2(32); */
      /*end , INVCONV*/
      l_lpn_id                      rcv_supply.lpn_id%TYPE;
      l_validation_flag             rcv_transactions_interface.validation_flag%TYPE;

      CURSOR supply_quantity(
         l_lot_num          VARCHAR2,
         /* INVCONV*/
      /*   l_sublot_num       VARCHAR2, */
         /*end , INVCONV*/
         p_parent_supply_id NUMBER,
         l_item_id          NUMBER
      ) IS
         SELECT rls.quantity,
                rls.primary_quantity
         FROM   rcv_lots_supply rls
         WHERE  rls.lot_num = l_lot_num
         /* INVCONV*/
         /*
         AND    (   (rls.sublot_num = l_sublot_num)
                 OR (    rls.sublot_num IS NULL
                     AND l_sublot_num IS NULL))
         */
         /* end , INVCONV */
         AND    rls.supply_type_code = 'RECEIVING'
         AND    rls.transaction_id = p_parent_supply_id;

      /* Bug 4870857: Added condition for shipment_line_id in the Exists clause
      **              to restrict the rows returned by the Cursor within a
      **              given shipment header.
      */
      CURSOR shipment_supply_quantity( --Bug 7443786
         l_lot_num            VARCHAR2,
         l_shipment_line_id NUMBER
      ) IS
         SELECT rls.quantity,
                rls.primary_quantity
         FROM   rcv_lots_supply rls
         WHERE  rls.lot_num = l_lot_num
         AND    rls.supply_type_code = 'SHIPMENT'
         AND    rls.shipment_line_id = l_shipment_line_id;

      l_qty_to_be_updated           NUMBER;
      l_primary_qty_to_be_updated   NUMBER;
      l_secondary_qty_to_be_updated NUMBER;
      l_ship_id                     NUMBER;
      l_ship_line_id                NUMBER;
      l_rls_qty                     NUMBER;
      l_rls_primary_qty             NUMBER;
      l_item_id                     rcv_transactions_interface.item_id%TYPE;
      l_parent_uom                  VARCHAR2(25);
      l_parent_secondary_uom        VARCHAR2(25);
      l_txn_uom                     VARCHAR2(25);
      l_primary_uom                 VARCHAR2(25);
      l_to_org_id                   NUMBER;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter update_rcv_lots_supply ');
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_transaction_type ' || p_transaction_type);
         asn_debug.put_line('p_shipment_line_id ' || p_shipment_line_id);
         asn_debug.put_line('p_source_type_code ' || p_source_type_code);
         asn_debug.put_line('p_parent_supply_id ' || p_parent_supply_id);
         asn_debug.put_line('p_correction_type ' || p_correction_type);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_lot_count
      FROM   mtl_transaction_lots_temp mtlt
      WHERE  mtlt.product_transaction_id = p_interface_transaction_id
      AND    mtlt.product_code = 'RCV';

      IF (l_lot_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_lot_count ' || l_lot_count);
      END IF;

      /* We need to insert into rcv_lots_supply and
       * rcv_serials_supply table only when we come through ROI
       * or when we come through desktop and have lpn info.
       * We insert lpn_id in rcv_supply. So return if there is
       * a value and validation_flag is N.
      */
      SELECT NVL(validation_flag, 'N')
      INTO   l_validation_flag
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      SELECT NVL(lpn_id, -999)
      INTO   l_lpn_id
      FROM   rcv_supply
      WHERE  supply_source_id = p_parent_supply_id;

      IF (    l_validation_flag = 'N'
          AND l_lpn_id = -999) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_validation_flag ' || l_validation_flag);
         asn_debug.put_line('l_lpn_id ' || l_lpn_id);
      END IF;

      /* When we update rcv_supply, we call this procedure and set
       * the p_correction_type depending upon whether we need to add
       * or subtract supply from rcv_lots_supply.
      */
      IF (p_correction_type = 'POSITIVE') THEN
         l_factor  := -1;
      ELSE
         l_factor  := 1;
      END IF;

      /* We need to insert or update rcv_lot_supply only when there is
       * already a row existing in rcv_lots_supply for a corresponding
       * row in rcv_supply. If not dont do anything.
      */
      SELECT COUNT(*)
      INTO   l_count
      FROM   rcv_lots_supply
      WHERE  transaction_id = p_parent_supply_id
      AND    supply_type_code = 'RECEIVING';

      IF (l_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_count ' || l_count);
      END IF;

      SELECT transaction_type,
             organization_id,
             unit_of_measure,
             secondary_unit_of_measure
      INTO   l_parent_trans_type,
             l_organization_id,
             l_parent_uom,
             l_parent_secondary_uom
      FROM   rcv_transactions
      WHERE  transaction_id = p_parent_supply_id;

      /* INVCONV , Update for OPM transactions also. Punit Kumar */

      -- roi enhacements for OPM.bug# 3061052
      -- don't update for OPM transactions.

     /* IF (gml_process_flags.check_process_orgn(p_organization_id    => l_organization_id) = 0) THEN */
         IF (    p_transaction_type = 'CORRECTION'
             AND l_parent_trans_type = 'RECEIVE'
             AND p_source_type_code IN('INVENTORY', 'REQ')) THEN --{
            l_update_shipment_supply  := 'Y';
         END IF; --}
     /* END IF; */

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_update_shipment_supply ' || l_update_shipment_supply);
         asn_debug.put_line(' INVCONV , Update shipment supply for OPM transactions also.');
      END IF;

      OPEN lot_cursor(p_interface_transaction_id);

      LOOP --{
         FETCH lot_cursor INTO l_lot_num,
            /* INVCONV */
          /* l_sublot_num, */
            /* end , INVCONV */
          l_primary_qty_to_be_updated,
          l_qty_to_be_updated,
          l_secondary_qty_to_be_updated,
          l_ship_line_id, --Bug 7443786
          l_item_id,
          l_txn_uom,
          l_to_org_id;
         EXIT WHEN lot_cursor%NOTFOUND;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Opened lot_cursor ');
            asn_debug.put_line('l_lot_num ' || l_lot_num);
            asn_debug.put_line('INVCONV, Subllot_num has been removed in update_lot_supply1 ');
            /*INVCONV*/
          /*  asn_debug.put_line('l_sublot_num ' || l_sublot_num); */
            /*end , INVCONV*/
            asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
            asn_debug.put_line('l_secondary_qty_to_be_updated ' || l_secondary_qty_to_be_updated);
            asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
            asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
            asn_debug.put_line('l_item_id ' || l_item_id);
            asn_debug.put_line('l_txn_uom, ' || l_txn_uom);
            asn_debug.put_line('l_to_org_id ' || l_to_org_id);
         END IF;

         /* If there is already a row existing for this lot_num, update
          * the quantity. Else insert a new one since this might be a
          * new lot_num for this transaction. At this point, inventory
          * would have validated these numbers.
         */

         /* INVCONV , Remove sublot_num. Punit Kumar */

         /** OPM change Bug# 3061052 added sublot_num check**/
         SELECT COUNT(*)
         INTO   l_count1
         FROM   rcv_lots_supply
         WHERE  transaction_id = p_parent_supply_id
         AND    lot_num = l_lot_num
         /* INVCONV */
         /*
         AND    (   (sublot_num = l_sublot_num)
                 OR (    sublot_num IS NULL
                     AND l_sublot_num IS NULL))
          */
          /*end , INVCONV*/
         AND    supply_type_code = 'RECEIVING';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_count1 ' || l_count1);
            asn_debug.put_line('INVCONV, Subllot_num has been removed in update_lot_supply2 ');
         END IF;

         IF (l_count1 = 0) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Before insert_lot_supply  ' || l_count1);
            END IF;

            insert_lot_supply(p_interface_transaction_id,
                              'RECEIVING',
                              p_parent_supply_id,
                              x_return_status
                             );

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('After insert_lot_supply  ' || l_count1);
            END IF;
         ELSE --}{
            /** OPM Change Bug# 3061052 add sublot_num check **/
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Else update rcv_lots_supply');
            END IF;

            SELECT MAX(primary_unit_of_measure)
            INTO   l_primary_uom
            FROM   mtl_system_items
            WHERE  mtl_system_items.inventory_item_id = l_item_id
            AND    mtl_system_items.organization_id = l_to_org_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_primary_uom ' || l_primary_uom);
            END IF;

            /* l_qty_to_be_updated shd be in
             * terms of the parent's uom. For
             * shipment supply qty, it must be
             * in terms of uom in rsl.
            */
            IF (l_txn_uom <> l_parent_uom) THEN
               l_qty_to_be_updated  := rcv_transactions_interface_sv.convert_into_correct_qty(l_primary_qty_to_be_updated,
                                                                                              l_primary_uom,
                                                                                              l_item_id,
                                                                                              l_parent_uom
                                                                                             );
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
               asn_debug.put_line('l_factor ' || l_factor);
               asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
               asn_debug.put_line('l_secondary_qty_to_be_updated ' || l_secondary_qty_to_be_updated);
               asn_debug.put_line('l_lot_num ' || l_lot_num);
               asn_debug.put_line('p_parent_supply_id ' || p_parent_supply_id);
               /* INVCONV*/
              /* asn_debug.put_line('l_sublot_num ' || l_sublot_num); */
               /*end , INVCONV*/
               asn_debug.put_line('INVCONV, Subllot_num has been removed in update_lot_supply3 ');
            END IF;

            /* INVCONV , Remove sublot_num. Punit Kumar */

            UPDATE rcv_lots_supply rls
               SET quantity = quantity -(l_qty_to_be_updated * l_factor),
                   primary_quantity = primary_quantity -(l_primary_qty_to_be_updated * l_factor),
                   secondary_quantity = secondary_quantity -(l_secondary_qty_to_be_updated * l_factor)
             WHERE rls.lot_num = l_lot_num
            AND    rls.transaction_id = p_parent_supply_id
            AND    rls.supply_type_code = 'RECEIVING' ;
            /* INVCONV */
            /*
            AND    (   (rls.sublot_num = l_sublot_num)
                    OR (    rls.sublot_num IS NULL
                        AND l_sublot_num IS NULL));
             */
            /* end , INVCONV */

         END IF; --}

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_update_shipment_supply ' || l_update_shipment_supply);
            asn_debug.put_line('INVCONV, Subllot_num has been removed in update_lot_supply4 ');
         END IF;

         IF (l_update_shipment_supply = 'Y') THEN --{
            SELECT COUNT(*)
            INTO   l_count2
            FROM   rcv_lots_supply
            WHERE  shipment_line_id = p_shipment_line_id
            AND    supply_type_code = 'SHIPMENT'
            AND    lot_num = l_lot_num;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_count2 ' || l_count2);
            END IF;

            /* If correction type is positive, then there would
             * definitely be a row for shipment supply else we will
             * not be able to correct. For negative correction, there
             * may or may not be a row. Hence get the count and insert
             * a new shipment supply row if there is no row or update
             * if there is already a shipment supply row. For ASNs the
             * shipment lot numbers are just suggestions and users can
             * override those values. Hence update if the lot number
             * already exists. We will delete all the shipment supply
             * from rcv_lot and serial tables when we fully receive
             * the asn in the processor.
            */
            IF (   (    p_correction_type = 'POSITIVE'
                    AND l_count2 >= 1)
                OR (    p_correction_type = 'NEGATIVE'
                    AND l_count2 >= 1)) THEN --{
               /* Bug 3376348.
                * It might happen that the original shipment lines are split
                * into multiple shipment_lines (when lpn has 2 lots for eg).
                * So instead of using shipment_line_id to delete use
                * shipment_header_id.
               */
               SELECT MAX(primary_unit_of_measure)
               INTO   l_primary_uom
               FROM   mtl_system_items
               WHERE  mtl_system_items.inventory_item_id = l_item_id
               AND    mtl_system_items.organization_id = l_to_org_id;

               /* l_qty_to_be_updated shd be in
                               * terms of the parent's uom. For
                               * shipment supply qty, it must be
                               * in terms of uom in rsl.
                              */
               OPEN shipment_supply_quantity(l_lot_num,
                                             l_ship_line_id --Bug 7443786
                                            );

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Opened shipment_supply_quantity ');
               END IF;

               LOOP --{
                  FETCH shipment_supply_quantity INTO l_rls_qty,
                   l_rls_primary_qty;
                  EXIT WHEN shipment_supply_quantity%NOTFOUND
                        OR l_primary_qty_to_be_updated = 0;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('l_rls_qty ' || l_rls_qty);
                     asn_debug.put_line('l_rls_primary_qty ' || l_rls_primary_qty);
                     asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                  END IF;

                  SELECT unit_of_measure
                  INTO   l_parent_uom
                  FROM   rcv_shipment_lines
                  WHERE  shipment_line_id = l_ship_line_id;

                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line('l_parent_uom ' || l_parent_uom);
                  END IF;

                  IF (l_txn_uom <> l_parent_uom) THEN
                     l_qty_to_be_updated  := rcv_transactions_interface_sv.convert_into_correct_qty(l_primary_qty_to_be_updated,
                                                                                                    l_primary_uom,
                                                                                                    l_item_id,
                                                                                                    l_parent_uom
                                                                                                   );
                  END IF;

                  IF (l_rls_primary_qty >= l_primary_qty_to_be_updated) THEN --{
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('rls_primary_qty is greater ');
                        asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                        asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                        asn_debug.put_line('l_lot_num ' || l_lot_num);
                        asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                     END IF;

                     UPDATE rcv_lots_supply rls
                        SET quantity = quantity -(l_qty_to_be_updated * l_factor),
                            primary_quantity = primary_quantity -(l_primary_qty_to_be_updated * l_factor)
                      WHERE rls.lot_num = l_lot_num
                     AND    shipment_line_id = l_ship_line_id
                     AND    rls.supply_type_code = 'SHIPMENT';

                     l_qty_to_be_updated          := 0;
                     l_primary_qty_to_be_updated  := 0;
                  ELSE --}{
                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('rls_primary_qty is lesser ');
                        asn_debug.put_line('l_qty_to_be_updated ' || l_qty_to_be_updated);
                        asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
                        asn_debug.put_line('l_lot_num ' || l_lot_num);
                        asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
                     END IF;

                     UPDATE rcv_lots_supply rls
                        SET quantity = quantity -(quantity * l_factor),
                            primary_quantity = primary_quantity -(primary_quantity * l_factor)
                      WHERE rls.lot_num = l_lot_num
                     AND    shipment_line_id = l_ship_line_id
                     AND    rls.supply_type_code = 'SHIPMENT';

                     l_qty_to_be_updated          := l_qty_to_be_updated - l_rls_qty;
                     l_primary_qty_to_be_updated  := l_primary_qty_to_be_updated - l_rls_primary_qty;
                  END IF; --}
               END LOOP; --}

               CLOSE shipment_supply_quantity;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Close shipment_supply_quantity  ');
               END IF;

	        IF l_primary_qty_to_be_updated <> 0 THEN --Bug 7443786
 	           asn_debug.put_line('l_ship_line_id ' || l_ship_line_id);
 	           asn_debug.put_line('l_primary_qty_to_be_updated ' || l_primary_qty_to_be_updated);
 	           /*Bug 13792458 when ISO or IOT from_organization is not lot controlled, it will not consume rcv_lots_supply quantity */
 	           --asn_debug.put_line('SHIPMENT supply for above qty not available to consume..Fail the transaction...');
 	           --raise NO_DATA_FOUND;
 	          /*End Bug 13792458 */
 	        END IF; --Bug 7443786
/*
         select shipment_header_id,item_id
         into l_shipment_header_id,l_item_id
         from rcv_shipment_lines
         where shipment_line_id = p_shipment_line_id;

         update rcv_lots_supply rls
         set    rls.quantity =
            (select rls.quantity +
                (sum(mtlt.transaction_quantity) * l_factor)
                   from   mtl_transaction_lots_temp mtlt
             where  mtlt.product_transaction_ID =
               p_interface_transaction_id
             and mtlt.product_code = 'RCV'
                  and rls.lot_num =  mtlt.lot_number),
             rls.primary_quantity =
            (select rls.primary_quantity -
             (sum(mtlt.primary_quantity) * l_factor)
            from   mtl_transaction_lots_temp mtlt
            where  mtlt.product_transaction_ID =
               p_interface_transaction_id
             and mtlt.product_code = 'RCV'
            and    rls.lot_num =  mtlt.lot_number)
           where supply_type_code = 'SHIPMENT'
               AND exists (select 1 from rcv_shipment_lines rsl
          where rsl.shipment_header_id = l_shipment_header_id
          and rsl.shipment_line_id = rls.shipment_line_id
               and rsl.item_id = l_item_id)
           and rls.lot_num  = l_lot_num;
*/
            END IF; --}
         END IF; --}
      END LOOP; --}

      CLOSE lot_cursor;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Close lot_cursor  ');
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit update_rcv_lots_supply ');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no_data_found update_rcv_lots_supply ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_UPDATE_LOT_SUPPLY_FAIL',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('others update_rcv_lots_supply ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_UPDATE_LOT_SUPPLY_ERROR',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
   END update_rcv_lots_supply;

   PROCEDURE update_rcv_serials_supply(
      p_api_version              IN            NUMBER,
      p_init_msg_list            IN            VARCHAR2,
      x_return_status            OUT NOCOPY    VARCHAR2,
      p_interface_transaction_id IN            NUMBER,
      p_transaction_type         IN            VARCHAR2,
      p_shipment_line_id         IN            NUMBER,
      p_source_type_code         IN            VARCHAR2,
      p_parent_supply_id         IN            NUMBER,
      p_correction_type          IN            VARCHAR2
   ) IS
      CURSOR select_serials(
         p_interface_transaction_id NUMBER
      ) IS
         SELECT msnt.fm_serial_number,
                msnt.to_serial_number,
                mtlt.lot_number
         FROM   mtl_serial_numbers_temp msnt,
                mtl_transaction_lots_temp mtlt
         WHERE  msnt.product_transaction_id = p_interface_transaction_id
         AND    msnt.product_code = 'RCV'
         AND    msnt.transaction_temp_id = mtlt.serial_transaction_temp_id(+);

      l_select_serials         select_serials%ROWTYPE;
      l_insert_serial          VARCHAR2(1)                                       := 'N';
      l_delete_serial          VARCHAR2(1)                                       := 'N';
      l_count                  NUMBER;
      l_serial_prefix          VARCHAR2(31);
      l_from_serial_number     NUMBER;
      l_to_serial_number       NUMBER;
      l_serial_num_length      NUMBER;
      l_prefix_length          NUMBER;
      l_serial_suffix_length   NUMBER;
      l_cur_serial_numeric     NUMBER;
      l_cur_serial_number      VARCHAR2(30);
      l_range_numbers          NUMBER;
      l_serial_count           NUMBER;
      l_update_shipment_supply VARCHAR2(1)                                       := 'N';
      l_parent_trans_type      rcv_transactions.transaction_type%TYPE;
      l_lpn_id                 rcv_supply.lpn_id%TYPE;
      l_validation_flag        rcv_transactions_interface.validation_flag%TYPE;
      l_shipment_header_id     rcv_shipment_headers.shipment_header_id%TYPE;
      l_item_id                rcv_transactions_interface.item_id%TYPE;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter update_rcv_serials_supply ');
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_transaction_type ' || p_transaction_type);
         asn_debug.put_line('p_shipment_line_id ' || p_shipment_line_id);
         asn_debug.put_line('p_source_type_code ' || p_source_type_code);
         asn_debug.put_line('p_parent_supply_id ' || p_parent_supply_id);
         asn_debug.put_line('p_correction_type ' || p_correction_type);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_serial_count
      FROM   mtl_serial_numbers_temp msnt
      WHERE  msnt.product_transaction_id = p_interface_transaction_id
      AND    msnt.product_code = 'RCV';

      IF (l_serial_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_Serial_count ' || l_serial_count);
      END IF;

      /* We need to insert into rcv_lots_supply and
       * rcv_serials_supply table only when we come through ROI
       * or when we come through desktop and have lpn info.
       * We insert lpn_id in rcv_supply. So return if there is
       * a value and validation_flag is N.
      */
      SELECT NVL(validation_flag, 'N')
      INTO   l_validation_flag
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      SELECT NVL(lpn_id, -999)
      INTO   l_lpn_id
      FROM   rcv_supply
      WHERE  supply_source_id = p_parent_supply_id;

      IF (    l_validation_flag = 'N'
          AND l_lpn_id = -999) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_validation_flag ' || l_validation_flag);
         asn_debug.put_line('l_lpn_id ' || l_lpn_id);
      END IF;

      OPEN select_serials(p_interface_transaction_id);

      /* Correction_type is positive when we need to insert new rows and
       * and will be negative when we need to delete the existing rows.
       * We need to insert new rows only when we already have rows
       * in rcv_serials_supply for the corresponding row in rcv_supply.
      */
      IF (p_correction_type = 'POSITIVE') THEN --{
         SELECT COUNT(*)
         INTO   l_count
         FROM   rcv_serials_supply
         WHERE  transaction_id = p_parent_supply_id
         AND    supply_type_code = 'RECEIVING';

         IF (l_count > 0) THEN
            l_insert_serial  := 'Y';
         END IF;
      ELSIF(p_correction_type = 'NEGATIVE') THEN --}{
         l_delete_serial  := 'Y';
      END IF; --}

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_insert_serial ' || l_insert_serial);
         asn_debug.put_line('l_delete_serial ' || l_delete_serial);
      END IF;

      SELECT transaction_type
      INTO   l_parent_trans_type
      FROM   rcv_transactions
      WHERE  transaction_id = p_parent_supply_id;

      IF (    p_transaction_type = 'CORRECTION'
          AND l_parent_trans_type = 'RECEIVE'
          AND p_source_type_code IN('INVENTORY', 'REQ')) THEN --{
         l_update_shipment_supply  := 'Y';
      END IF; --}

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_update_shipment_supply ' || l_update_shipment_supply);
      END IF;

      LOOP --{
         FETCH select_serials INTO l_select_serials;
         EXIT WHEN select_serials%NOTFOUND;
         split_serial_number(l_select_serials.fm_serial_number,
                             l_serial_prefix,
                             l_from_serial_number
                            );
         split_serial_number(l_select_serials.to_serial_number,
                             l_serial_prefix,
                             l_to_serial_number
                            );
         l_range_numbers      := l_to_serial_number - l_from_serial_number + 1;
         l_serial_num_length  := LENGTH(l_select_serials.fm_serial_number);

         /* Start Bug#3359105: Modified the following code to consider
     * the case when the Serial number is numeric instead of being
        * alphanumeric. In this case l_serial_prefix is NULL and
     * so needs proper handling.
          */
         IF l_serial_prefix IS NOT NULL THEN
            l_prefix_length         := LENGTH(l_serial_prefix);
            l_serial_suffix_length  := l_serial_num_length - l_prefix_length;
         ELSE
            l_prefix_length         := 0;
            l_serial_suffix_length  := l_serial_num_length;
         END IF;

         /* End  Bug#3359105 */
         IF (l_delete_serial = 'Y') THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('l_serial_prefix ' || l_serial_prefix);
               asn_debug.put_line('l_from_serial_number ' || l_from_serial_number);
               asn_debug.put_line('l_to_serial_number ' || l_to_serial_number);
            END IF;

            DELETE FROM rcv_serials_supply
                  WHERE transaction_id = p_parent_supply_id
            AND         supply_type_code = 'RECEIVING'
            AND         (   l_select_serials.lot_number IS NULL
                         OR NVL(lot_num, l_select_serials.lot_number) = l_select_serials.lot_number)
            AND         (serial_num BETWEEN(l_serial_prefix || LPAD(TO_CHAR(l_from_serial_number),
                                                                    l_serial_suffix_length,
                                                                    '0'
                                                                   )) AND(l_serial_prefix || LPAD(TO_CHAR(l_to_serial_number),
                                                                                                  l_serial_suffix_length,
                                                                                                  '0'
                                                                                                 )));
         END IF; --}

         FOR i IN 1 .. l_range_numbers LOOP --{
            l_cur_serial_numeric  := l_from_serial_number + i - 1;
            -- l_cur_serial_number := l_serial_prefix || l_cur_serial_numeric;
            l_cur_serial_number   := l_serial_prefix || LPAD(TO_CHAR(l_cur_serial_numeric),
                                                             l_serial_suffix_length,
                                                             '0'
                                                            );

            IF (l_insert_serial = 'Y') THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Before insert_serial_supply ');
               END IF;

               insert_serial_supply(p_interface_transaction_id,
                                    l_select_serials.lot_number,
                                    l_cur_serial_number,
                                    'RECEIVING',
                                    p_parent_supply_id,
                                    x_return_status
                                   );

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('After insert_serial_supply ');
               END IF;
            END IF; --}

            IF (    (l_update_shipment_supply = 'Y')
                AND (l_delete_serial = 'Y')) THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Before insert_serial_supply  when update and delete serial is Y');
               END IF;

               insert_serial_supply(p_interface_transaction_id,
                                    l_select_serials.lot_number,
                                    l_cur_serial_number,
                                    'SHIPMENT',
                                    p_parent_supply_id,
                                    x_return_status
                                   );

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('After insert_serial_supply  when update and delete serial is Y');
               END IF;
            END IF; --}
         END LOOP; --}

         IF (    (l_update_shipment_supply = 'Y')
             AND (l_insert_serial = 'Y')) THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Before  delete  when update and insert serial is Y');
            END IF;

            SELECT shipment_header_id,
                   item_id
            INTO   l_shipment_header_id,
                   l_item_id
            FROM   rcv_shipment_lines
            WHERE  shipment_line_id = p_shipment_line_id;

            /* Bug 3376348.
             * It might happen that the original shipment lines are split
             * into multiple shipment_lines (when lpn has 2 lots for eg).
             * So instead of using shipment_line_id to delete use
             * shipment_header_id.
            */
            DELETE FROM rcv_serials_supply rss
                  WHERE supply_type_code = 'SHIPMENT'
            AND         (   l_select_serials.lot_number IS NULL
                         OR NVL(lot_num, l_select_serials.lot_number) = l_select_serials.lot_number)
            AND         (serial_num BETWEEN(l_serial_prefix || LPAD(TO_CHAR(l_from_serial_number),
                                                                    l_serial_suffix_length,
                                                                    '0'
                                                                   )) AND(l_serial_prefix || LPAD(TO_CHAR(l_to_serial_number),
                                                                                                  l_serial_suffix_length,
                                                                                                  '0'
                                                                                                 )))
            AND         EXISTS(SELECT 1
                               FROM   rcv_shipment_lines rsl
                               WHERE  rsl.shipment_header_id = l_shipment_header_id
                               AND    rsl.shipment_line_id = rss.shipment_line_id
                               AND    rsl.item_id = l_item_id);

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('After  delete  when update and insert serial is Y');
            END IF;
         END IF; --}
      END LOOP; --}

      CLOSE select_serials;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no_data_found update_rcv_serials_supply');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_UPDATE_SERIAL_SUPPLY_FAIL',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('others update_rcv_serials_supply');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;

         INSERT INTO po_interface_errors
                     (interface_type,
                      interface_transaction_id,
                      error_message,
                      processing_date,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      request_id,
                      program_application_id,
                      program_id,
                      program_update_date
                     )
            SELECT 'RECEIVING',
                   p_interface_transaction_id,
                   'RCV_UPDATE_SERIAL_SUPPLY_ERROR',
                   SYSDATE,
                   rti.creation_date,
                   rti.created_by,
                   rti.last_update_date,
                   rti.last_updated_by,
                   rti.last_update_login,
                   rti.request_id,
                   rti.program_application_id,
                   rti.program_id,
                   rti.program_update_date
            FROM   rcv_transactions_interface rti
            WHERE  rti.interface_transaction_id = p_interface_transaction_id;
   END update_rcv_serials_supply;

   PROCEDURE insert_lot_supply(
      p_interface_transaction_id IN            NUMBER,
      p_supply_type_code         IN            VARCHAR2,
      p_supply_source_id         IN            NUMBER,
      x_return_status            OUT NOCOPY    VARCHAR2
   ) IS
      CURSOR c IS
         SELECT rls.ROWID
         FROM   rcv_lots_supply rls
         WHERE  rls.transaction_id = p_supply_source_id;

      l_rowid           VARCHAR2(255);
      l_lot_count       NUMBER;
      l_lpn_id          rcv_supply.lpn_id%TYPE;
      l_validation_flag rcv_transactions_interface.validation_flag%TYPE;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter insert_lots_supply');
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_supply_type_code ' || p_supply_type_code);
         asn_debug.put_line('p_supply_source_id ' || p_supply_source_id);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_lot_count
      FROM   mtl_transaction_lots_temp mtlt
      WHERE  mtlt.product_transaction_id = p_interface_transaction_id
      AND    mtlt.product_code = 'RCV';

      IF (l_lot_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_lot_count ' || l_lot_count);
      END IF;

      /* We need to insert into rcv_lots_supply and
       * rcv_serials_supply table only when we come through ROI
       * or when we come through desktop and have lpn info.
       * We insert lpn_id in rcv_supply. So return if there is
       * a value and validation_flag is N.
      */
      SELECT NVL(validation_flag, 'N')
      INTO   l_validation_flag
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      SELECT NVL(lpn_id, -999)
      INTO   l_lpn_id
      FROM   rcv_supply
      WHERE  supply_source_id = p_supply_source_id;

      IF (    l_validation_flag = 'N'
          AND l_lpn_id = -999) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_validation_flag ' || l_validation_flag);
         asn_debug.put_line('l_lpn_id ' || l_lpn_id);
      END IF;
      /* INVCONV, Remove sublot_num . Punit Kumar*/

      INSERT INTO rcv_lots_supply
                  (supply_type_code,
                   shipment_line_id,
                   transaction_id,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   created_by,
                   creation_date,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   lot_num,
                   quantity,
                   primary_quantity,
                   expiration_date,
                   /** OPM change Bug# 3061052**/
                   secondary_quantity,
                   /*INVCONV*/
                   /* sublot_num, */
                   /*end , INVCONV*/
                   reason_code
                  )
         SELECT p_supply_type_code,
                rs.shipment_line_id,
                DECODE(p_supply_type_code,
                       'RECEIVING', rs.supply_source_id,
                       NULL
                      ),
                rs.last_updated_by,
                rs.last_update_date,
                rs.last_update_login,
                rs.created_by,
                rs.creation_date,
                rs.request_id,
                rs.program_application_id,
                rs.program_id,
                SYSDATE,
                mtltview.lot_number,
                mtltview.qty,
                mtltview.primary_qty,
                mtltview.lot_expiration_date,
                mtltview.secondary_qty,
               /*INVCONV*/
              /*  mtltview.sublot_num, */
               /*end , INVCONV*/
                mtltview.reason_code
         FROM   rcv_supply rs,
                (SELECT   SUM(mtlt.transaction_quantity) qty,
                          SUM(mtlt.primary_quantity) primary_qty,
                          SUM(mtlt.secondary_quantity) secondary_qty,
                          mtlt.lot_number,
                          mtlt.lot_expiration_date,
                          mtlt.product_transaction_id,
                          mtlt.product_code,
                          /*INVCONV*/
                         /*  mtlt.sublot_num, */
                           /*end , INVCONV*/
                          mtlt.reason_code
                 FROM     mtl_transaction_lots_temp mtlt
                 GROUP BY mtlt.product_transaction_id,
                          mtlt.lot_number,
                        /*INVCONV*/
                        /*  mtlt.sublot_num, */
                        /*end , INVCONV*/
                          mtlt.lot_expiration_date,
                          mtlt.product_code,
                          mtlt.reason_code) mtltview
         WHERE  (    mtltview.product_transaction_id = p_interface_transaction_id
                 AND mtltview.product_code = 'RCV'
                 AND rs.supply_source_id = p_supply_source_id);

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('After insert into rcv_lots_supply ');
         asn_debug.put_line('INVCONV, Subllot_num has been removed in insert_lot_supply1 ');
      END IF;

      OPEN c;
      FETCH c INTO l_rowid;

      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit insert_lots_supply ');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no_data_found insert_lots_supply ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;
         RAISE;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('others insert_lots_supply ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         RAISE;
   END insert_lot_supply;

   PROCEDURE insert_serial_supply(
      p_interface_transaction_id IN            NUMBER,
      p_lot_number               IN            VARCHAR2,
      p_serial_number            IN            VARCHAR2,
      p_supply_type_code         IN            VARCHAR2,
      p_supply_source_id         IN            NUMBER,
      x_return_status            OUT NOCOPY    VARCHAR2
   ) IS
      CURSOR c IS
         SELECT rss.ROWID
         FROM   rcv_serials_supply rss
         WHERE  rss.transaction_id = p_supply_source_id;

      l_rowid           VARCHAR2(255);
      l_serial_count    NUMBER;
      l_lpn_id          rcv_supply.lpn_id%TYPE;
      l_validation_flag rcv_transactions_interface.validation_flag%TYPE;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter insert_serial_supply ');
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_serial_number ' || p_serial_number);
         asn_debug.put_line('p_lot_number ' || p_lot_number);
         asn_debug.put_line('p_supply_type_code ' || p_supply_type_code);
         asn_debug.put_line('p_supply_source_id ' || p_supply_source_id);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_serial_count
      FROM   mtl_serial_numbers_temp msnt
      WHERE  msnt.product_transaction_id = p_interface_transaction_id
      AND    msnt.product_code = 'RCV';

      IF (l_serial_count = 0) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_serial_count  ' || l_serial_count);
      END IF;

      /* We need to insert into rcv_lots_supply and
       * rcv_serials_supply table only when we come through ROI
       * or when we come through desktop and have lpn info.
       * We insert lpn_id in rcv_supply. So return if there is
       * a value and validation_flag is N.
      */
      SELECT NVL(validation_flag, 'N')
      INTO   l_validation_flag
      FROM   rcv_transactions_interface
      WHERE  interface_transaction_id = p_interface_transaction_id;

      SELECT NVL(lpn_id, -999)
      INTO   l_lpn_id
      FROM   rcv_supply
      WHERE  supply_source_id = p_supply_source_id;

      IF (    l_validation_flag = 'N'
          AND l_lpn_id = -999) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('l_validation_flag  ' || l_validation_flag);
         asn_debug.put_line(' l_lpn_id  ' || l_lpn_id);
      END IF;

      /* We can only use rcv_transactions but in cases of direct deliver
       * there will be two rows in rt with same interface_txn_id. Hence
       * use rcv_supply and this way we will only use the receiving row.
      */
      INSERT INTO rcv_serials_supply
                  (supply_type_code,
                   shipment_line_id,
                   transaction_id,
                   lot_num,
                   serial_num,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date
                  )
         SELECT p_supply_type_code,
                rs.shipment_line_id,
                DECODE(p_supply_type_code,
                       'RECEIVING', rs.supply_source_id,
                       NULL
                      ),
                p_lot_number,
                p_serial_number,
                rs.last_update_date,
                rs.last_updated_by,
                rs.creation_date,
                rs.created_by,
                rs.last_update_login,
                rs.request_id,
                rs.program_application_id,
                rs.program_id,
                rs.program_update_date
         FROM   rcv_supply rs
         WHERE  rs.supply_source_id = p_supply_source_id;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line(' After insert into rcv_serials_supply');
      END IF;

      OPEN c;
      FETCH c INTO l_rowid;

      IF (c%NOTFOUND) THEN
         CLOSE c;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line(' Exit insert_serial_supply');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(' no_data_found insert_serial_supply');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;
         RAISE;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(' others insert_serial_supply');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         RAISE;
   END insert_serial_supply;

   PROCEDURE insert_lot_transactions(
      p_interface_transaction_id  IN            NUMBER,
      p_lot_context               IN            VARCHAR2,
      p_lot_context_id            IN            NUMBER,
      p_source_transaction_id     IN            NUMBER,
      p_correction_transaction_id IN            NUMBER,
      p_negate_qty                IN            VARCHAR2,
      x_return_status             OUT NOCOPY    VARCHAR2
   ) IS
      l_lot_count       NUMBER;
      l_lpn_id          rcv_supply.lpn_id%TYPE;
      l_validation_flag rcv_transactions_interface.validation_flag%TYPE;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line(' enter insert_lot_transactions');
         asn_debug.put_line('p_interface_transaction_id ' || p_interface_transaction_id);
         asn_debug.put_line('p_lot_context ' || p_lot_context);
         asn_debug.put_line('p_lot_context_id ' || p_lot_context_id);
         asn_debug.put_line('p_source_transaction_id ' || p_source_transaction_id);
         asn_debug.put_line('p_correction_transaction_id ' || p_correction_transaction_id);
         asn_debug.put_line('p_negate_qty ' || p_negate_qty);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_success;

      /* We can now come here if it is a lot-serial item and there is
       * no row in mtl_transaction_lots_temp if user has not entered
       * any lot/serial info for this transaction(Receive, Transfer etc).
       * In this case we do not error nor insert. So return.
      */
      SELECT COUNT(*)
      INTO   l_lot_count
      FROM   mtl_transaction_lots_temp mtlt
      WHERE  mtlt.product_transaction_id = p_interface_transaction_id
      AND    mtlt.product_code = 'RCV';

      IF (l_lot_count = 0) THEN
         RETURN;
      END IF;

      /* INVCONV , sublot_num to be removed as part of new lot model. Punit Kumar*/

      INSERT INTO rcv_lot_transactions
                  (lot_transaction_type,
                   shipment_line_id,
                   transaction_id,
                   source_transaction_id,
                   correction_transaction_id,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   transaction_date,
                   item_id,
                   lot_num,
                   quantity,
                   primary_quantity,
                   expiration_date,
                   /* INVCONV */
                  /* sublot_num, */
                   /* end , INVCONV*/
                   secondary_quantity,
                   reason_code
                  )
         SELECT DECODE(p_lot_context,
                       'CORRECTION', 'TRANSACTION',
                       p_lot_context
                      ),
                rti.shipment_line_id,
                DECODE(p_lot_context,
                       'SHIPMENT', -1,
                       p_lot_context_id
                      ),
                DECODE(p_lot_context,
                       'SHIPMENT', -1,
                       p_source_transaction_id
                      ),
                p_correction_transaction_id,
                rti.created_by,
                rti.creation_date,
                rti.last_updated_by,
                rti.last_update_date,
                rti.last_update_login,
                rti.request_id,
                rti.program_application_id,
                rti.program_id,
                SYSDATE,
                rti.transaction_date,
                rti.item_id,
                mtltview.lot_number,
                DECODE(p_negate_qty,
                       'Y',(mtltview.qty * -1),
                       mtltview.qty
                      ),
                DECODE(p_negate_qty,
                       'Y',(mtltview.primary_qty * -1),
                       mtltview.primary_qty
                      ),
                mtltview.lot_expiration_date,
               /*INVCONV*/
              /*  mtltview.sublot_num, */
               /*end ,INVCONV*/
                mtltview.secondary_qty,
                mtltview.reason_code
         FROM   rcv_transactions_interface rti,
                (SELECT   SUM(mtlt.transaction_quantity) qty,
                          SUM(mtlt.primary_quantity) primary_qty,
                          SUM(mtlt.secondary_quantity) secondary_qty,
                          mtlt.lot_number,
                          mtlt.lot_expiration_date,
                          mtlt.product_transaction_id,
                           /*INVCONV*/
                         /* mtlt.sublot_num, */
                           /*end , INVCONV*/
                          mtlt.reason_code,
                          mtlt.product_code
                 FROM     mtl_transaction_lots_temp mtlt
                 GROUP BY mtlt.product_transaction_id,
                          mtlt.lot_number,
                          mtlt.lot_expiration_date,
                           /* INVCONV*/
                        /*  mtlt.sublot_num, */
                           /*end , INVCONV*/
                          mtlt.reason_code,
                          mtlt.product_code) mtltview
         WHERE  mtltview.product_transaction_id = p_interface_transaction_id
         AND    mtltview.product_code = 'RCV'
         AND    rti.interface_transaction_id = mtltview.product_transaction_id;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit insert_lot_transactions ');
         asn_debug.put_line('INVCONV , sublot_num has not been inserted in rcv_lot_transactions');
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no_data_found insert_lot_transactions ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_error;
         RAISE;
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('others insert_lot_transactions ');
         END IF;

         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         RAISE;
   END insert_lot_transactions;

   PROCEDURE validate_lpn_groups(
      p_request_id IN NUMBER,
      p_group_id   IN NUMBER
   ) IS
      l_lpn_group_id           rcv_transactions_interface.lpn_group_id%TYPE;
      l_ret_status             VARCHAR2(20);
      l_msg_cnt                NUMBER;
      l_msg_data               VARCHAR2(100);
      l_return                 BOOLEAN                                        := TRUE;
      l_header_id              NUMBER;
      l_ship_id                NUMBER;
      l_asn_type               VARCHAR2(10);
      x_fail_if_one_line_fails VARCHAR2(1)                                    := 'N';
      x_interface_type         VARCHAR2(25)                                   := 'RCV-856';
      x_dummy_flag             VARCHAR2(1)                                    := 'Y';
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter validate_lpn_groups ');
         asn_debug.put_line('group_id ' || p_group_id);
         asn_debug.put_line('p_request_id ' || p_request_id);
      END IF;

      fnd_profile.get('RCV_FAIL_IF_LINE_FAILS', x_fail_if_one_line_fails);
      OPEN rcv_processor_pvt.lpn_grps_cur(p_request_id, p_group_id);

      LOOP --{
         FETCH rcv_processor_pvt.lpn_grps_cur INTO l_lpn_group_id;
         EXIT WHEN rcv_processor_pvt.lpn_grps_cur%NOTFOUND;

         IF l_lpn_group_id IS NOT NULL THEN --{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Before calling inv api ');
            END IF;

            l_return  := inv_rcv_integration_apis.validate_lpn_info(1.0,
                                                                    fnd_api.g_true,
                                                                    l_ret_status,
                                                                    l_msg_cnt,
                                                                    l_msg_data,
                                                                    inv_rcv_integration_apis.g_exists_or_create,
                                                                    l_lpn_group_id
                                                                   );

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('After calling inv api ');
            END IF;

            --If l_ret_status <> fnd_api.g_ret_sts_success then --
            IF (l_return <> TRUE) THEN --{
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('l_return is false ');
               END IF;

               IF (x_fail_if_one_line_fails = 'Y') THEN
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(' fail line is Y');
                  END IF;

                  SELECT NVL(header_interface_id, -999),
                         auto_transact_code,
                         shipment_header_id
                  INTO   l_header_id,
                         l_asn_type,
                         l_ship_id
                  FROM   rcv_transactions_interface
                  WHERE  lpn_group_id = l_lpn_group_id
                  AND    GROUP_ID = DECODE(p_group_id,
                                           0, GROUP_ID,
                                           p_group_id
                                          )
                  AND    ROWNUM < 2;
               END IF;

               /* for an asn, when the profile option says fail all lines,
               we must delete the shipment_header if it exists
               update the rhi and rti to error for the shipment_headerid */
               IF     l_header_id <> -999
                  AND l_asn_type = 'SHIP' THEN --{
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(' This is an ASN');
                  END IF;

                  UPDATE rcv_headers_interface
                     SET processing_status_code = 'ERROR'
                   WHERE header_interface_id = l_header_id;

                  rcv_roi_preprocessor.update_rti_error(p_group_id               => p_group_id,
                                                        p_interface_id           => NULL,
                                                        p_header_interface_id    => l_header_id,
                                                        p_lpn_group_id           => NULL
                                                       );
               ELSE
                  /* for non-ASN transactions we should update the corresponding lpn group
                  to error */
                  IF (g_asn_debug = 'Y') THEN
                     asn_debug.put_line(' Before updating rti error');
                  END IF;

                  rcv_roi_preprocessor.update_rti_error(p_group_id               => p_group_id,
                                                        p_interface_id           => NULL,
                                                        p_header_interface_id    => NULL,
                                                        p_lpn_group_id           => l_lpn_group_id
                                                       );
               END IF;        --}
                       -- insert into interface errors
                       -- need to get correct error message for pushing to errors table

               rcv_error_pkg.set_error_message('RCV_TRANSACTIONS_INTERFACE');
               rcv_error_pkg.set_token('LPN_GROUP_ID', l_lpn_group_id);
               rcv_error_pkg.log_interface_error('LPN_GROUP_ID', FALSE);
            END IF; --}
         END IF; --}
      END LOOP; --}

      CLOSE rcv_processor_pvt.lpn_grps_cur;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line(' Exit validate_lpn_groups');
      END IF;
   END validate_lpn_groups;
END rcv_processor_pvt;

/
