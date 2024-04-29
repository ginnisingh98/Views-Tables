--------------------------------------------------------
--  DDL for Package Body RCV_ROI_RETURN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ROI_RETURN" 
/* $Header: RCVPRERB.pls 120.4.12010000.9 2014/06/23 03:35:24 wayin ship $*/
AS
   g_asn_debug         VARCHAR2(1)                                      := asn_debug.is_debug_on; -- Bug 9152790
   x_progress          VARCHAR2(3);
   p_trx_record        rcv_roi_header_common.common_default_record_type;
   default_return_info default_return%ROWTYPE;

   PROCEDURE derive_return_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      x_progress                              := '010';
      asn_debug.put_line('enter derive_return_line ');
      /* Derive the to_org_id */
      derive_ship_to_org_info(x_cascaded_table,
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

      x_progress                              := '020';
      derive_reason_info(x_cascaded_table, n);
      /* Auto_transact_code is null for all these transaction types */
      x_cascaded_table(n).auto_transact_code  := NULL;
      rcv_roi_transaction.derive_from_locator_id(x_cascaded_table, n); -- WMS Change
      rcv_roi_transaction.derive_to_locator_id(x_cascaded_table, n); -- WMS Change

      --Bug18332568,Returns not supported for Amount based Service Lines
      IF nvl(x_cascaded_table(n).quantity,0) > 0 THEN
        derive_return_line_qty(x_cascaded_table,
                               n,
                               temp_cascaded_table
                              );
      ELSE
        rcv_error_pkg.set_error_message('RCV_NO_RTV_FOR_SERVICE_LINES');
        rcv_error_pkg.log_interface_error('RCV_TRANSACTIONS_INTERFACE',
                                          'INTERFACE_TRANSACTION_ID',
                                          x_cascaded_table(n).group_id,
                                          x_cascaded_table(n).header_interface_id,
                                          x_cascaded_table(n).interface_transaction_id);

      END IF;
   END derive_return_line;

   PROCEDURE default_return_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      asn_debug.put_line('Enter Default');
      default_common_lines(x_cascaded_table, n);

      IF (x_cascaded_table(n).derive = 'Y') THEN --{
         IF (x_cascaded_table(n).derive_index <> 0) THEN --{
            NULL;
         /* Get the values from pl/sql table */
         ELSE --} {
            asn_debug.put_line('open cursor Default');
            OPEN default_return_rti(x_cascaded_table(n).parent_interface_txn_id);
         END IF; --}
      ELSE -- } {
         OPEN default_return(x_cascaded_table(n).parent_transaction_id);
      END IF; --}

      IF (default_return%ISOPEN) THEN
         asn_debug.put_line('fetch cursor Default ' || x_cascaded_table(n).parent_transaction_id);
         FETCH default_return INTO default_return_info;
      ELSIF(default_return_rti%ISOPEN) THEN
         FETCH default_return_rti INTO default_return_info;
      END IF;

      IF (   (    default_return%ISOPEN
              AND default_return%FOUND)
          OR (    default_return_rti%ISOPEN
              AND default_return_rti%FOUND)) THEN --{
         IF    (x_cascaded_table(n).transaction_type = 'RETURN TO VENDOR')
            OR (    x_cascaded_table(n).transaction_type = 'RETURN TO RECEIVING'
                AND x_cascaded_table(n).source_document_code = 'PO') THEN

            default_po_info(x_cascaded_table,
                            n,
                            default_return_info
                           );
            default_vendor_info(x_cascaded_table,
                                n,
                                default_return_info
                               );
         ELSIF    (x_cascaded_table(n).transaction_type = 'RETURN TO CUSTOMER')
               OR (    x_cascaded_table(n).transaction_type = 'RETURN TO RECEIVING'
                   AND x_cascaded_table(n).source_document_code = 'RMA') THEN
            default_oe_info(x_cascaded_table,
                            n,
                            default_return_info
                           );
            default_customer_info(x_cascaded_table,
                                  n,
                                  default_return_info
                                 );
         END IF;

         default_shipment_info(x_cascaded_table,
                               n,
                               default_return_info
                              );
         default_wip_info(x_cascaded_table,
                          n,
                          default_return_info
                         );
         default_currency_info(x_cascaded_table,
                               n,
                               default_return_info
                              );
         default_deliver_to_info(x_cascaded_table,
                                 n,
                                 default_return_info
                                );
         default_source_info(x_cascaded_table,
                             n,
                             default_return_info
                            );
         default_item_info(x_cascaded_table,
                           n,
                           default_return_info
                          );
         default_destination_info(x_cascaded_table,
                                  n,
                                  default_return_info
                                 );
         default_location_info(x_cascaded_table,
                               n,
                               default_return_info
                              );
         default_movement_id(x_cascaded_table,
                             n,
                             default_return_info
                            );
         default_bom_resource_id(x_cascaded_table,
                                 n,
                                 default_return_info
                                );
      -- default the parent's to_lpn into the child's from_lpn
      END IF; -- if default_return%FOUND is true }

      /* FPJ WMS CHANGES START */
      IF (x_cascaded_table(n).from_subinventory IS NULL) THEN
         rcv_roi_transaction.default_from_subloc_info(x_cascaded_table, n);
      END IF;

      rcv_roi_transaction.default_to_subloc_info(x_cascaded_table, n);
      /* FPJ WMS CHANGES END */

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Set Location_id  = ' || TO_CHAR(x_cascaded_table(n).location_id));
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit default_vendor_correct');
      END IF;

      IF default_return%ISOPEN THEN
         CLOSE default_return;
      END IF;

      IF default_return_rti%ISOPEN THEN
         CLOSE default_return_rti;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END default_return_line;

   PROCEDURE derive_reason_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN OUT NOCOPY BINARY_INTEGER
   ) IS
      reason_id_record rcv_shipment_line_sv.reason_id_record_type;
   BEGIN
      IF     (x_cascaded_table(n).error_status IN('S', 'W'))
         AND (    x_cascaded_table(n).reason_id IS NULL
              AND x_cascaded_table(n).reason_name IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
         END IF;

         reason_id_record.reason_name                 := x_cascaded_table(n).reason_name;
         reason_id_record.error_record.error_status   := 'S';
         reason_id_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derive Reason_id');
         END IF;

         rcv_transactions_interface_sv.get_reason_id(reason_id_record);
         x_cascaded_table(n).reason_id                := reason_id_record.reason_id;
         x_cascaded_table(n).error_status             := reason_id_record.error_record.error_status;
         x_cascaded_table(n).error_message            := reason_id_record.error_record.error_message;
      END IF;
   END derive_reason_info;

   PROCEDURE derive_ship_to_org_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN OUT NOCOPY BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
      ship_to_org_record     rcv_shipment_object_sv.organization_id_record_type;
      x_to_organization_code VARCHAR2(5);
   BEGIN
      -- default org from header in case it is null at the line level

      IF     x_cascaded_table(n).to_organization_code IS NULL
         AND x_cascaded_table(n).error_status IN('S', 'W') THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Attempting to default the org from the ship to location');
         END IF;

         IF (x_cascaded_table(n).ship_to_location_code IS NOT NULL) THEN
            SELECT max(mp.organization_code)
            INTO   x_to_organization_code
            FROM   hr_locations hl,
                   mtl_parameters mp
            WHERE  x_cascaded_table(n).ship_to_location_code = hl.location_code
            AND    hl.inventory_organization_id = mp.organization_id;

            x_cascaded_table(n).to_organization_code  := x_to_organization_code;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Set Org Code using location code = ' || x_cascaded_table(n).to_organization_code);
            END IF;
         END IF;

         IF (    x_cascaded_table(n).to_organization_code IS NULL
             AND x_header_record.header_record.ship_to_organization_code IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Will default org change DUH to ' || x_header_record.header_record.ship_to_organization_code);
            END IF;

            x_cascaded_table(n).to_organization_code  := x_header_record.header_record.ship_to_organization_code;
         END IF;
      END IF;

      -- call derivation procedures if conditions are met

      IF     (x_cascaded_table(n).error_status IN('S', 'W'))
         AND (    x_cascaded_table(n).to_organization_id IS NULL
              AND x_cascaded_table(n).to_organization_code IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_Progress ' || x_progress);
         END IF;

         ship_to_org_record.organization_code           := x_cascaded_table(n).to_organization_code;
         ship_to_org_record.organization_id             := x_cascaded_table(n).to_organization_id;
         ship_to_org_record.error_record.error_status   := 'S';
         ship_to_org_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Into Derive Organization Record Procedure');
         END IF;

         po_orgs_sv.derive_org_info(ship_to_org_record);

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Debug Output after organization procedure');
            asn_debug.put_line(ship_to_org_record.organization_code);
            asn_debug.put_line(TO_CHAR(ship_to_org_record.organization_id));
            asn_debug.put_line(ship_to_org_record.error_record.error_status);
            asn_debug.put_line('Debug organization output over');
         END IF;

         x_cascaded_table(n).to_organization_code       := ship_to_org_record.organization_code;
         x_cascaded_table(n).to_organization_id         := ship_to_org_record.organization_id;
         x_cascaded_table(n).error_status               := ship_to_org_record.error_record.error_status;
         x_cascaded_table(n).error_message              := ship_to_org_record.error_record.error_message;
      END IF;
   END derive_ship_to_org_info;

   PROCEDURE derive_return_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
      quantity_not_postive_exception EXCEPTION;
      no_parent_line_exception       EXCEPTION;
      reject_exception               EXCEPTION;
      po_shipment_cancel_exception   EXCEPTION;  -- bug 8640033
      x_record_count                 NUMBER;
      x_remaining_quantity           NUMBER                                          := 0;
      x_remaining_qty_po_uom         NUMBER                                          := 0;
      x_bkp_qty                      NUMBER                                          := 0;
      x_progress                     VARCHAR2(3);
      x_to_organization_code         VARCHAR2(5);
      x_converted_trx_qty            NUMBER                                          := 0;
      transaction_ok                 BOOLEAN                                         := FALSE;
      rows_fetched                   NUMBER                                          := 0;
      x_tolerable_qty                NUMBER                                          := 0;
      x_first_trans                  BOOLEAN                                         := TRUE;
      x_sysdate                      DATE                                            := SYSDATE;
      current_n                      BINARY_INTEGER                                  := 0;
      insert_into_table              BOOLEAN                                         := FALSE;
      x_qty_rcv_exception_code       po_line_locations.qty_rcv_exception_code%TYPE;
      tax_amount_factor              NUMBER;
      po_asn_uom_qty                 NUMBER;
      po_primary_uom_qty             NUMBER;
      already_allocated_qty          NUMBER                                          := 0;
      x_item_id                      NUMBER;
      x_approved_flag                VARCHAR(1);
      x_cancel_flag                  VARCHAR(1);
      x_closed_code                  VARCHAR(25);
      x_shipment_type                VARCHAR(25);
      x_ship_to_organization_id      NUMBER;
      x_ship_to_location_id          NUMBER;
      x_vendor_product_num           VARCHAR(25);
      x_temp_count                   NUMBER;
      x_full_name                    VARCHAR2(240)                                   := NULL; -- Bug 2392074
      x_secondary_available_qty      NUMBER                                          := 0;
      x_fecth_parent_txn             BOOLEAN                                         := FALSE; -- Bug 14346599

/********************************************************************/
      CURSOR derive_return(
         v_parent_trx_id NUMBER
      ) IS
         SELECT rsl.item_id,
                rt.po_line_id,
                rt.transaction_type,
                rt.po_header_id,
                rt.po_line_location_id,
                rt.parent_transaction_id,
                rt.primary_unit_of_measure,
                rt.quantity,
                rt.transaction_id,
                rt.unit_of_measure
         FROM   rcv_transactions rt,
                rcv_shipment_lines rsl
         WHERE  transaction_id = v_parent_trx_id
         AND    rt.shipment_line_id = rsl.shipment_line_id
         -- bug 8640033
         AND    NOT EXISTS(SELECT 'purchase order shipment cancelled or fc'
                           FROM   po_line_locations pll
                           WHERE  pll.line_location_id = rt.po_line_location_id
                           AND    (   NVL(pll.cancel_flag, 'N') = 'Y'
                                      OR NVL(pll.closed_code, 'OPEN') = 'FINALLY CLOSED'));
         -- end bug 8640033

      CURSOR derive_return_rti(
         v_parent_interface_txn_id NUMBER
      ) IS
         SELECT rti.item_id,
                rti.po_line_id,
                rti.transaction_type,
                rti.po_header_id,
                rti.po_line_location_id,
                rti.parent_transaction_id,
                rti.primary_unit_of_measure,
                rti.quantity,
                rti.interface_transaction_id transaction_id,
                rti.unit_of_measure
         FROM   rcv_transactions_interface rti
         WHERE  interface_transaction_id = v_parent_interface_txn_id;

      x_derive_returnrec             derive_return%ROWTYPE;
      x_temp_parent_trx_qty          NUMBER                                          := 0;
      x_converted_parent_trx_qty     NUMBER                                          := 0;
      x_temp_convert_parent_trx_qty  NUMBER                                          := 0;
      x_remaining_qty_parent_uom     NUMBER                                          := 0;
      l_to_organization_id           NUMBER                                          := 0;
      l_supply_type_code             rcv_supply.supply_type_code%TYPE;
      l_transaction_type             rcv_transactions.transaction_type%TYPE;
      x_temp_already_allocated_qty   NUMBER                                          := 0;
      derive_values_from_table       BOOLEAN                                         := FALSE;
      derive_values_from_rti         BOOLEAN                                         := FALSE;
      already_derived                BOOLEAN                                         := FALSE;
      cascaded_table_index           NUMBER;
      l_parent_transaction_type      rcv_transactions.transaction_type%TYPE;
      l_grand_parent_trx_id          rcv_transactions.parent_transaction_id%TYPE;
      temp_index                     NUMBER;
        l_po_header_id po_headers_all.po_header_id%type;
        l_return_status VARCHAR2(1) :='S';
        l_complex_flag   varchar2(1);
      l_exist                       VARCHAR2(30); -- bug 8640033

   BEGIN
      asn_debug.put_line('enter derive_quantity ' || x_cascaded_table(n).parent_transaction_id);

      -- try to derive the parent_trx_id from rt. if the parent line is not in rt,
      -- try get it from rti or plsql table.
      IF (x_cascaded_table(n).parent_transaction_id IS NULL) THEN
         rcv_roi_transaction.derive_parent_id(x_cascaded_table, n);
      END IF;

      IF (x_cascaded_table(n).parent_transaction_id IS NOT NULL) THEN --{
         asn_debug.put_line('open rt cursor with parent_trx_id: ' || x_cascaded_table(n).parent_transaction_id);
         OPEN derive_return(x_cascaded_table(n).parent_transaction_id);
      ELSE
         IF --{
             (    (x_cascaded_table(n).error_status <> 'E')
              AND (x_cascaded_table(n).derive_index = 0)) THEN
            /** This means that there was no error in derive_parent_id()
              * but the parent_trx_id is not populated. The line is a child
              * and need to get the values from the rti or the plsql table.
              * If derive_values_from_table is true we will
              * derive the values from the pl/sql tables later
              * at the time when we try to see which cursor is open.
              */
            asn_debug.put_line('open rti cursor');
            OPEN derive_return_rti(x_cascaded_table(n).parent_interface_txn_id);
         END IF;
      END IF; --}

/******************************************************************/
--check line quanity > 0
      x_progress  := '097';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).quantity <= 0 THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Quantity is <= zero. quantity derive will fail');
         END IF;

         RAISE quantity_not_postive_exception;
      END IF; --} end qty > 0 check

              -- the following steps will create a set of rows linking the line_record with
              -- its corresponding po_line_location rows until the quantity value from
              -- the asn is consumed.  (Cascade)
              -- For return, there will be no cascade since there's only 1 parent txn per
              -- return, the temp_cascade_table will be deprecated in phase 2 -pjiang

      /* 2119137 : If the user populates rcv_transactions_interface
      with po_line_id, then ROI errors out with
      RCV_ASN_NO_PO_LINE_LOCATION_ID when the document_line_num
      is not provided for one time items. Modified the "if" criteria in
      such a way that the ROI validation does'nt error out when
      po_line_id is populated for one time items. */
      x_progress  := '098';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF (    (   x_cascaded_table(n).parent_transaction_id IS NOT NULL
               OR x_cascaded_table(n).parent_interface_txn_id IS NOT NULL)
          AND x_cascaded_table(n).error_status IN('S', 'W')) THEN   --{
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
         x_bkp_qty                       := x_remaining_quantity; -- used for decrementing cum qty for first record
         x_remaining_qty_po_uom          := 0;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Have assigned the quantity');
         END IF;

         -- Calculate tax_amount_factor for calculating tax_amount for
         -- each cascaded line

         tax_amount_factor               := NVL(temp_cascaded_table(current_n).tax_amount, 0) / x_remaining_quantity;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Tax Factor ' || TO_CHAR(tax_amount_factor));
            asn_debug.put_line('transaction Quantity : ' || TO_CHAR(x_remaining_quantity));
         END IF;

         x_first_trans                   := TRUE;
         transaction_ok                  := FALSE;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Before starting Cascade');
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Record Count = ' || x_record_count);
         END IF;

         LOOP --{ The loop will be removed since there is no cascading.
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Backup Qty ' || TO_CHAR(x_bkp_qty));
               asn_debug.put_line('Remaining Quantity  ' || TO_CHAR(x_remaining_quantity));
            END IF;
            x_fecth_parent_txn := FALSE; --bug 14346599
            /*
            ** Fetch the appropriate record
            */
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('DEBUG: transaction_type = ' || x_cascaded_table(n).transaction_type);
            END IF;

            IF (derive_return%ISOPEN) THEN --{
               asn_debug.put_line('fetch derive_return');
               FETCH derive_return INTO x_derive_returnrec;

               IF (derive_return%NOTFOUND) THEN
                  EXIT;
               END IF;

               rows_fetched  := derive_return%ROWCOUNT;
            ELSIF(derive_return_rti%ISOPEN) THEN --}{
               asn_debug.put_line('pjiang fetch derive_return_rti');
               FETCH derive_return_rti INTO x_derive_returnrec;

               IF (derive_return_rti%NOTFOUND) THEN
                  EXIT;
               END IF;

               rows_fetched  := derive_return_rti%ROWCOUNT;
            ELSIF(temp_cascaded_table(current_n).derive = 'Y') THEN --}{
               /* GET VALUES FROM THE PLSQL TABLE */
               asn_debug.put_line('pjiang: fetch pl/sql table');
               temp_index                                  := temp_cascaded_table(current_n).derive_index;
               x_derive_returnrec.po_line_location_id      := x_cascaded_table(temp_index).po_line_location_id;
               x_derive_returnrec.po_header_id             := x_cascaded_table(temp_index).po_header_id;
               x_derive_returnrec.po_line_id               := x_cascaded_table(temp_index).po_line_id;
               x_derive_returnrec.unit_of_measure          := x_cascaded_table(temp_index).unit_of_measure;
               x_derive_returnrec.parent_transaction_id    := x_cascaded_table(temp_index).parent_transaction_id;
               x_derive_returnrec.transaction_type         := x_cascaded_table(temp_index).transaction_type;
               x_derive_returnrec.quantity                 := x_cascaded_table(temp_index).quantity;
               x_derive_returnrec.primary_unit_of_measure  := x_cascaded_table(temp_index).primary_unit_of_measure;
               x_derive_returnrec.item_id                  := x_cascaded_table(temp_index).item_id;
               x_derive_returnrec.transaction_id           := NULL;
               rows_fetched                                := 1;
            END IF; --}


	/* R12 Complex work.
	 * We do not support any other receiving transactions other
	 * than direct receipt. Error out if it is complex work PO.
	*/

	/* Complex PO Receiving ER: Added new parameters to the below procedure call */

	PO_COMPLEX_WORK_GRP.is_complex_work_po(
		 1.0,
		 x_cascaded_table(n).po_header_id,
		 l_return_status,
		 l_complex_flag,
		 x_derive_returnrec.po_line_id,             /* Complex PO Receiving ER */
		 x_derive_returnrec.item_id,                /* Complex PO Receiving ER */
		 null,                                      /* Complex PO Receiving ER */
		 x_derive_returnrec.po_line_location_id);   /* Complex PO Receiving ER */

	IF (l_return_status IS NOT NULL AND
		  l_return_status = FND_API.g_ret_sts_success) THEN
		IF( g_asn_debug = 'Y' ) THEN
		    asn_debug.put_line('l_return_status ' || l_return_status);
		    asn_debug.put_line('l_po_header_id ' || l_po_header_id);
		END IF;
	ELSE
		IF( g_asn_debug = 'Y') THEN
		    asn_debug.put_line('l_return_status ' || l_return_status);
		END IF;
	END IF;

	IF (l_complex_flag = 'Y') THEN
		asn_debug.put_line('We do not support transaction type ' || x_cascaded_table(n).transaction_type || ' for complex work POs');
		rcv_error_pkg.set_error_message('RCV_INVALID_TRANSACTION_TYPE');
		rcv_error_pkg.log_interface_error('TRANSACTION_TYPE');
	End if;

            l_parent_transaction_type                       := x_derive_returnrec.transaction_type;
            l_grand_parent_trx_id                           := x_derive_returnrec.parent_transaction_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Parent transaction rows fetched: (should always be 1 for return) ' || TO_CHAR(rows_fetched));
               asn_debug.put_line('po_line_id  ' || TO_CHAR(x_derive_returnrec.po_line_id));
               asn_debug.put_line('po_line_location_id  ' || TO_CHAR(x_derive_returnrec.po_line_location_id));
               -- since there can only be one parent trx, there will be only one allocating
               asn_debug.put_line('the quantity available for return in parent txn: ' || x_remaining_quantity);
            END IF;
            --bug 14346599 begin, if rti's UOM is not null, we needn't to fetch it from parent txn's
            IF temp_cascaded_table(current_n).unit_of_measure IS NULL THEN
               temp_cascaded_table(current_n).unit_of_measure  := x_derive_returnrec.unit_of_measure;
               x_fecth_parent_txn := TRUE;
            END IF;
            --end bug 14346599
            asn_debug.put_line(' Entering qty calculation for return');

            IF     (x_first_trans)
               AND temp_cascaded_table(current_n).item_id IS NULL THEN
               temp_cascaded_table(current_n).item_id                  := x_derive_returnrec.item_id;
               temp_cascaded_table(current_n).primary_unit_of_measure  := x_derive_returnrec.primary_unit_of_measure;
            END IF;

            insert_into_table                               := FALSE;
            already_allocated_qty                           := 0;
            rcv_roi_transaction.get_interface_available_qty(temp_cascaded_table,
                                                            current_n,
                                                            x_converted_parent_trx_qty
                                                           );

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('return interface qty ' || x_converted_parent_trx_qty);
            END IF;

            IF (x_converted_parent_trx_qty = 0) THEN --{
               IF (temp_cascaded_table(current_n).derive = 'Y') -- derive from plsql table or rti
                                                                THEN --{
                  x_converted_parent_trx_qty  := x_derive_returnrec.quantity;
                  asn_debug.put_line(' derive  parent  ' || temp_cascaded_table(current_n).parent_interface_txn_id);
                  asn_debug.put_line(' from derive quantity ' || TO_CHAR(x_converted_parent_trx_qty));
               /* Get x_converted_parent_trx_qty from the pl/sql table or cascaded_table as needed.*/
               ELSE --}{
                  IF (g_asn_debug = 'Y') THEN --{_
                     asn_debug.put_line('calling get_available_qty for return (Negative Correct)' || x_derive_returnrec.transaction_type);
                     asn_debug.put_line('parameters passed in ............');
                     asn_debug.put_line('1. transaction_type: ' || x_cascaded_table(n).transaction_type);
                     asn_debug.put_line('2. parent id: ' || x_derive_returnrec.transaction_id);
                     asn_debug.put_line('3. receipt source code: ' || x_cascaded_table(n).receipt_source_code);
                     asn_debug.put_line('4. parent transaction_type: ' || x_derive_returnrec.transaction_type);
                     asn_debug.put_line('5. grand parent id: ' || 'NULL');
                     asn_debug.put_line('6. correction type: ' || 'NEGATIVE');
                     asn_debug.put_line('7. available quantity: ' || TO_CHAR(x_converted_parent_trx_qty));
                     asn_debug.put_line('8. tolerable_quantity: ' || TO_CHAR(x_tolerable_qty));
                     asn_debug.put_line('9. unit of measure: ' || x_derive_returnrec.unit_of_measure);
                     asn_debug.put_line('10. 2nd available quantity : ' || TO_CHAR(x_secondary_available_qty));
                  END IF; --}

                  /*begin fix of bug 13892629, we were not able perform return from different subinventory*/
                  IF x_derive_returnrec.transaction_type = 'DELIVER' THEN

                     rcv_quantities_s.get_deliver_quantity(x_derive_returnrec.transaction_id,
                                                           x_cascaded_table(n).interface_transaction_id,
                                                           x_converted_parent_trx_qty,
                                                           x_derive_returnrec.unit_of_measure,
                                                           x_secondary_available_qty
                                                           );

                  ELSE

                    rcv_quantities_s.get_available_quantity(x_cascaded_table(n).transaction_type,
                                                          x_derive_returnrec.transaction_id,
                                                          x_cascaded_table(n).receipt_source_code,
                                                          x_derive_returnrec.transaction_type,
                                                          NULL,
                                                          'NEGATIVE',
                                                          x_converted_parent_trx_qty,
                                                          x_tolerable_qty,
                                                          x_derive_returnrec.unit_of_measure,
                                                          x_secondary_available_qty
                                                         );

                  END IF;
                  /*end fix of bug 13892629*/
                  --}

                  asn_debug.put_line('qty from GET_AVAILABLE_QUANTITY for return is ' || x_converted_parent_trx_qty);

                  IF already_allocated_qty > 0 --?????what if <0 caused by positive return?
                                               THEN --{
                     x_converted_parent_trx_qty  := x_converted_parent_trx_qty - already_allocated_qty;
                     x_tolerable_qty             := x_tolerable_qty - already_allocated_qty;

                     IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line(' For return some allocated quantity. Will reduce qty');
                        asn_debug.put_line('Allocated Qty ' || TO_CHAR(already_allocated_qty));
                        asn_debug.put_line('After reducing by allocated qty');
                        asn_debug.put_line('Available Quantity ' || TO_CHAR(x_converted_parent_trx_qty));
                        asn_debug.put_line('Tolerable Quantity ' || TO_CHAR(x_tolerable_qty));
                        asn_debug.put_line('Pointer to temp table ' || TO_CHAR(current_n));
                     END IF;
                  END IF; /* if already_allocated_qty is >0 for return */ --}
               END IF; /*derive_values_from_rti is false */--}
            END IF; --}  interface_available_qty is 0.

            x_remaining_qty_parent_uom                      := rcv_transactions_interface_sv.convert_into_correct_qty(x_remaining_quantity,
                                                                                                                      temp_cascaded_table(1).unit_of_measure,
                                                                                                                      temp_cascaded_table(1).item_id,
                                                                                                                      x_derive_returnrec.unit_of_measure
                                                                                                                     );

            IF (x_remaining_qty_parent_uom <= 0) -- this is redundant with the qty check????
                                                 THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line(' Return Needs an error message in the interface tables');
                  RAISE quantity_not_postive_exception;
               END IF;
            ELSE
               /* Converted successfully and have some quantity on which we can act */
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Converted trx qty that is available ' || x_converted_parent_trx_qty);
                  asn_debug.put_line('Remaining qty in parents uom that is available ' || x_remaining_qty_parent_uom);
               END IF;

               IF (x_converted_parent_trx_qty > 0) THEN --{
                  IF (x_converted_parent_trx_qty < x_remaining_qty_parent_uom) THEN --{
                     /* Total quantity available to return is less than the qty
                      * that the user wants to return. Hence we would error out but
                      * to keep the old code we will get the remaining code here and
                      * error out later.
                      */
                     x_remaining_qty_parent_uom  := x_remaining_qty_parent_uom - x_converted_parent_trx_qty;

                     IF (temp_cascaded_table(current_n).unit_of_measure <> x_derive_returnrec.unit_of_measure) THEN
                        x_remaining_quantity  := rcv_transactions_interface_sv.convert_into_correct_qty(x_remaining_qty_parent_uom,
                                                                                                        x_derive_returnrec.unit_of_measure,
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
                  END IF; --} /* if (x_converted_parent_trx_qty < x_remaining_quantity) then */
               ELSE /* x_converted_parent_trx_qty >0 */ --}{
                  IF rows_fetched = x_record_count THEN   -- {
                                                        -- last row needs to be inserted anyway
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
            END IF;

            /* Converted qty successfully and we have some quantity on which we can act */
            asn_debug.put_line('Transaction qty in terms of the parents uom is ' || x_converted_parent_trx_qty);

            IF insert_into_table THEN --{ --start pjiang
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

               temp_cascaded_table(current_n).po_header_id             := x_derive_returnrec.po_header_id;
               temp_cascaded_table(current_n).po_line_id               := x_derive_returnrec.po_line_id;
               temp_cascaded_table(current_n).po_line_location_id      := x_derive_returnrec.po_line_location_id;
               temp_cascaded_table(current_n).primary_unit_of_measure  := x_derive_returnrec.primary_unit_of_measure;
               /*bug 14346599 comment get quantity from converted parent UOM's, because if the temp_cascaded_table(current_n).unit_of_measure
               is not null,we don't fetch the UOM from parent txn, add if condition to avoid regression */
               IF x_fecth_parent_txn THEN
                  temp_cascaded_table(current_n).quantity            := x_converted_parent_trx_qty;
               END IF;
               /*bug 14346599*/
               IF (temp_cascaded_table(current_n).primary_unit_of_measure <> x_derive_returnrec.unit_of_measure) THEN
                  temp_cascaded_table(current_n).primary_quantity  := rcv_transactions_interface_sv.convert_into_correct_qty(x_converted_parent_trx_qty,
                                                                                                                             x_derive_returnrec.unit_of_measure,
                                                                                                                             temp_cascaded_table(current_n).item_id,
                                                                                                                             temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                                            );
               ELSE
                  temp_cascaded_table(current_n).primary_quantity  := x_converted_parent_trx_qty;
               END IF;

               asn_debug.put_line('Transaction qty in terms of the primary uom is ' || temp_cascaded_table(current_n).primary_quantity);
               current_n                                               := current_n + 1;
            END IF; --}
      /* Get the available qty in PRIMARY UOM */
/*
      PO_UOM_S.UOM_CONVERT (x_converted_trx_qty,
                            l_uom,
                            x_item_id,
                            x_primary_uom,
                            l_primary_available_qty );
*/
         END LOOP; --}

                   -- post_fetch_action (x_cascaded_table, n, temp_cascaded_table);

         /* WMS CHANGE.
          * If derive_inv_quantity returns error, then we set error_status
          * to E. Close the cursors and return.
         */
         IF (x_cascaded_table(n).error_status = 'E') THEN
            IF derive_return%ISOPEN THEN
               CLOSE derive_return;
            END IF;

            IF derive_return_rti%ISOPEN THEN
               CLOSE derive_return_rti;
            END IF;

            RETURN;
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Out of the loop');
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


         -- bug 8640033
         SELECT MAX('record_exist')
         INTO   l_exist
         FROM   rcv_transactions rt,
                po_line_locations pll
         WHERE  pll.line_location_id = rt.po_line_location_id
         AND    transaction_id = x_cascaded_table(n).parent_transaction_id
         AND    (   NVL(pll.cancel_flag, 'N') = 'Y'
                 OR NVL(pll.closed_code, 'OPEN') = 'FINALLY CLOSED');

         IF l_exist = 'record_exist' THEN
            RAISE po_shipment_cancel_exception;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('The PO shipment has been cancelled or finally closed ');
               asn_debug.put_line('Parent transaction id is ' || x_cascaded_table(n).parent_transaction_id );
            END IF;

        ELSE
        -- end bug 8640033

         -- lastrecord...we have run out of rows and we still have quantity to allocate
         -- for return, this means we are trying to return more than the quantity of parent.
         -- We should simply error out this situation.
         IF x_remaining_quantity > 0 THEN   --{
                                          -- reject the transaction if this is the case. Can't return more than what we have.
            RAISE reject_exception;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('There is quantity remaining ');
               asn_debug.put_line('tolerable quantity now in plsql table ' || temp_cascaded_table(current_n).quantity);
            END IF;
         ELSE -- }{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Remaining  UOM quantity is zero ' || TO_CHAR(x_remaining_quantity));
               asn_debug.put_line('Return the cascaded rows back to the calling procedure');
            END IF;
         END IF; --} ends the check for whether last record has been reached
       END IF; -- end bug 8640033

         asn_debug.put_line('before exit current_n is ' || current_n);
      ELSE   --} {
           -- error_status and error_message are set after validate_quantity_shipped
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No parent_transaction_id/parent_interface_trx_id ');
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Status = ' || x_cascaded_table(n).error_status);
         END IF;

         IF x_cascaded_table(n).error_status IN('S', 'W', 'F') THEN --{
            RAISE no_parent_line_exception;
         END IF; --}

         RETURN;
      END IF; -- } of (asn quantity_shipped was valid)

      asn_debug.put_line('before closing cursors current_n is ' || temp_cascaded_table.COUNT);

      IF derive_return%ISOPEN THEN
         CLOSE derive_return;
      END IF;

      IF derive_return_rti%ISOPEN THEN
         CLOSE derive_return_rti;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit explode_line_quantity');
      END IF;
   -- handle errors and warnings in exception block
   EXCEPTION
      WHEN quantity_not_postive_exception THEN
         x_cascaded_table(n).error_status   := 'F';
         /* Bug 3250532 : Changed the error message from 'TBD' to 'RCV_ENTER_QTY_GT_ZERO'.
         */
         x_cascaded_table(n).error_message  := 'RCV_ENTER_QTY_GT_ZERO';
         rcv_error_pkg.set_error_message(x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_num);
         rcv_error_pkg.log_interface_error('QUANTITY', FALSE);
      WHEN no_parent_line_exception THEN
         x_cascaded_table(n).error_status  := 'E';

         IF (x_cascaded_table(n).error_message IS NULL) THEN
            /* Bug 3250532 : Changed the error message from 'TBD' to 'RCV_NO_PARENT_TRANSACTION'.
            */
            x_cascaded_table(n).error_message  := 'RCV_NO_PARENT_TRANSACTION';
         END IF;

         rcv_error_pkg.set_error_message(x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('DOCUMENT_NUM', x_cascaded_table(n).document_num);
         rcv_error_pkg.log_interface_error('NUMBER', FALSE);
      WHEN reject_exception THEN
         x_cascaded_table(n).error_status   := 'E';
         /* Bug 3250532 : Changed the error message from 'TBD' to 'RCV_TRX_QTY_EXCEEDS_AVAILABLE'.
         */
         x_cascaded_table(n).error_message  := 'RCV_TRX_QTY_EXCEEDS_AVAILABLE';
         rcv_error_pkg.set_error_message(x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('QTY_A', x_cascaded_table(n).quantity);
         rcv_error_pkg.set_token('QTY_B', x_cascaded_table(n).quantity - x_remaining_quantity);
         rcv_error_pkg.log_interface_error('QUANTITY', FALSE);
         temp_cascaded_table.DELETE;

      -- bug 8640033
      WHEN po_shipment_cancel_exception THEN
        x_cascaded_table(n).error_status   := 'E';

        x_cascaded_table(n).error_message  := 'RCV_PO_SHIPMENT_CANCELLED';
        rcv_error_pkg.set_error_message(x_cascaded_table(n).error_message);
        rcv_error_pkg.log_interface_error('PARENT_TRANSACTION_ID', FALSE);
      -- end bug 8640033

      WHEN OTHERS THEN
         IF derive_return%ISOPEN THEN
            CLOSE derive_return;
         END IF;

         IF derive_return_rti%ISOPEN THEN
            CLOSE derive_return_rti;
         END IF;

         x_cascaded_table(n).error_status  := 'F';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(n));
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('error ' || x_progress);
         END IF;
   END derive_return_line_qty;

   PROCEDURE default_common_lines(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
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
   END default_common_lines;

   PROCEDURE default_po_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return po_revision_num ' || default_return_rec.po_revision_num);
         asn_debug.put_line('Defaulting return po_header_id ' || default_return_rec.po_header_id);
         asn_debug.put_line('Defaulting return po_release_id ' || default_return_rec.po_release_id);
         asn_debug.put_line('Defaulting return po_unit_price ' || default_return_rec.po_unit_price);
         asn_debug.put_line('Defaulting return po_line_id ' || default_return_rec.po_line_id);
         asn_debug.put_line('Defaulting return po_line_location_id ' || default_return_rec.po_line_location_id);
         asn_debug.put_line('Defaulting return po_distribution_id ' || default_return_rec.po_distribution_id);
      END IF;

      x_cascaded_table(n).po_revision_num      := default_return_rec.po_revision_num;
      x_cascaded_table(n).po_header_id         := default_return_rec.po_header_id;
      x_cascaded_table(n).po_release_id        := default_return_rec.po_release_id;

      /* We used to get the unit_price from the cursor where it picks
       * up from the parent. But since PO unit_price can be change
       * retroactively, we need to pick up the unit_price from PO
       * directly. Since we would have derived line_location_id
       * and po_line_id at this point, use the values here.
       * x_cascaded_table (n).po_unit_price :=
  *      default_return_rec.po_unit_price;
      */
      SELECT NVL(pll.price_override, pl.unit_price)
      INTO   x_cascaded_table(n).po_unit_price
      FROM   po_line_locations pll,
             po_lines pl
      WHERE  pll.line_location_id = x_cascaded_table(n).po_line_location_id
      AND    pl.po_line_id = x_cascaded_table(n).po_line_id
      AND    pl.po_line_id = pll.po_line_id;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting Return po_unit_price' || x_cascaded_table(n).po_unit_price);
      END IF;

      x_cascaded_table(n).po_line_id           := default_return_rec.po_line_id;
      x_cascaded_table(n).po_line_location_id  := default_return_rec.po_line_location_id;
      x_cascaded_table(n).po_distribution_id   := default_return_rec.po_distribution_id;
   END default_po_info;

   PROCEDURE default_shipment_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting Return shipment_header_id ' || default_return_rec.shipment_header_id);
         asn_debug.put_line('Defaulting Return shipment_line_id ' || default_return_rec.shipment_line_id);
      END IF;

      x_cascaded_table(n).shipment_header_id  := default_return_rec.shipment_header_id;
      x_cascaded_table(n).shipment_line_id    := default_return_rec.shipment_line_id;
   END default_shipment_info;

   PROCEDURE default_wip_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return wip_entity_id ' || default_return_rec.wip_entity_id);
         asn_debug.put_line('Defaulting return wip_line_id ' || default_return_rec.wip_line_id);
         asn_debug.put_line('Defaulting return wip_repetitive_schedule_id ' || default_return_rec.wip_repetitive_schedule_id);
         asn_debug.put_line('Defaulting return wip_operation_seq_num ' || default_return_rec.wip_operation_seq_num);
         asn_debug.put_line('Defaulting return wip_resource_seq_num ' || default_return_rec.wip_resource_seq_num);
      END IF;

      x_cascaded_table(n).wip_entity_id               := default_return_rec.wip_entity_id;
      x_cascaded_table(n).wip_line_id                 := default_return_rec.wip_line_id;
      x_cascaded_table(n).wip_repetitive_schedule_id  := default_return_rec.wip_repetitive_schedule_id;
      x_cascaded_table(n).wip_operation_seq_num       := default_return_rec.wip_operation_seq_num;
      x_cascaded_table(n).wip_resource_seq_num        := default_return_rec.wip_resource_seq_num;
   END default_wip_info;

   PROCEDURE default_oe_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return oe_order_header_id ' || default_return_rec.oe_order_header_id);
         asn_debug.put_line('Defaulting return oe_order_line_id ' || default_return_rec.oe_order_line_id);
      END IF;

      x_cascaded_table(n).oe_order_header_id  := default_return_rec.oe_order_header_id;
      x_cascaded_table(n).oe_order_line_id    := default_return_rec.oe_order_line_id;
   END default_oe_info;

   PROCEDURE default_currency_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return currency_code ' || default_return_rec.currency_code);
         asn_debug.put_line('Defaulting return currency_conversion_type ' || default_return_rec.currency_conversion_type);
         asn_debug.put_line('Defaulting return currency_conversion_rate ' || default_return_rec.currency_conversion_rate);
         asn_debug.put_line('Defaulting return currency_conversion_date ' || default_return_rec.currency_conversion_date);
      END IF;

      x_cascaded_table(n).currency_code             := default_return_rec.currency_code;
      x_cascaded_table(n).currency_conversion_type  := default_return_rec.currency_conversion_type;
      x_cascaded_table(n).currency_conversion_rate  := default_return_rec.currency_conversion_rate;
      x_cascaded_table(n).currency_conversion_date  := default_return_rec.currency_conversion_date;
   END default_currency_info;

   PROCEDURE default_vendor_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting Return vendor_id ' || default_return_rec.vendor_id);
         asn_debug.put_line('Defaulting Return vendor_site_id ' || default_return_rec.vendor_site_id);
      END IF;

      x_cascaded_table(n).vendor_id       := default_return_rec.vendor_id;
      x_cascaded_table(n).vendor_site_id  := default_return_rec.vendor_site_id;
   END default_vendor_info;

   PROCEDURE default_customer_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting Return customer_id ' || default_return_rec.customer_id);
         asn_debug.put_line('Defaulting Return customer_site_id ' || default_return_rec.customer_site_id);
      END IF;

      x_cascaded_table(n).customer_id       := default_return_rec.customer_id;
      x_cascaded_table(n).customer_site_id  := default_return_rec.customer_site_id;
   END default_customer_info;

   PROCEDURE default_deliver_to_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting Return deliver_to_person_id ' || default_return_rec.deliver_to_person_id);
         asn_debug.put_line('Defaulting Return deliver_to_location_id ' || default_return_rec.deliver_to_location_id);
      END IF;

      x_cascaded_table(n).deliver_to_person_id    := default_return_rec.deliver_to_person_id;
      x_cascaded_table(n).deliver_to_location_id  := default_return_rec.deliver_to_location_id;
   END default_deliver_to_info;

   PROCEDURE default_source_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return receipt_source_code ' || default_return_rec.receipt_source_code);
         asn_debug.put_line('Defaulting return source_document_code ' || default_return_rec.source_document_code);
      END IF;

      x_cascaded_table(n).receipt_source_code   := default_return_rec.receipt_source_code;
      x_cascaded_table(n).source_document_code  := default_return_rec.source_document_code;
   END default_source_info;

   PROCEDURE default_item_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return primary_unit_of_measure ' || default_return_rec.primary_unit_of_measure);
         asn_debug.put_line('Defaulting return item_description ' || default_return_rec.item_description);
         asn_debug.put_line('Defaulting return category_id ' || default_return_rec.category_id);
         asn_debug.put_line('Defaulting return department_code ' || default_return_rec.department_code);
         asn_debug.put_line('Defaulting return inspection_status_code ' || default_return_rec.inspection_status_code);
         asn_debug.put_line('Defaulting return subinventory ' || default_return_rec.subinventory);
      END IF;

      x_cascaded_table(n).primary_unit_of_measure  := default_return_rec.primary_unit_of_measure;
      x_cascaded_table(n).item_description         := default_return_rec.item_description;
      x_cascaded_table(n).category_id              := default_return_rec.category_id;
      x_cascaded_table(n).department_code          := default_return_rec.department_code;
      x_cascaded_table(n).inspection_status_code   := default_return_rec.inspection_status_code;
      x_cascaded_table(n).subinventory             := default_return_rec.subinventory;
   END default_item_info;

   PROCEDURE default_destination_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return destination_context ' || default_return_rec.destination_context);
         asn_debug.put_line('Defaulting return to_organization_id ' || default_return_rec.OID);
      END IF;

      x_cascaded_table(n).destination_context  := default_return_rec.destination_context;
      x_cascaded_table(n).to_organization_id   := default_return_rec.OID;
   END default_destination_info;

   PROCEDURE default_location_info(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return location_id ' || default_return_rec.location_id);
         asn_debug.put_line('Defaulting return locator_id ' || default_return_rec.locator_id);
      END IF;

      x_cascaded_table(n).location_id  := default_return_rec.location_id;
      x_cascaded_table(n).locator_id   := default_return_rec.locator_id;
   END default_location_info;

   PROCEDURE default_movement_id(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return movement_id ' || default_return_rec.movement_id);
      END IF;

      x_cascaded_table(n).movement_id  := default_return_rec.movement_id;
   END default_movement_id;

   PROCEDURE default_bom_resource_id(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_return_rec IN            default_return%ROWTYPE
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Defaulting return bom_resource_id ' || default_return_rec.bom_resource_id);
      END IF;

      x_cascaded_table(n).bom_resource_id  := default_return_rec.bom_resource_id;
   END default_bom_resource_id;

/* WMS Changes Start */
   PROCEDURE derive_inv_qty(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      /* Bug 3639667.
       * We are calling the new procedure instead of changing the calls
       * in all the other files where we call the original procedure
       * derive_inv_qty.
      */
      derive_inv_qty_1(x_cascaded_table(n).destination_type_code,
                       x_cascaded_table(n).transaction_type,
                       x_cascaded_table(n).quantity,
                       x_cascaded_table(n).interface_transaction_id,
                       x_cascaded_table(n).to_organization_id,
                       x_cascaded_table(n).item_id,
                       x_cascaded_table(n).item_revision,
                       x_cascaded_table(n).receipt_source_code,
                       x_cascaded_table(n).po_header_id,
                       x_cascaded_table(n).unit_of_measure,
                       x_cascaded_table(n).primary_unit_of_measure,
                       x_cascaded_table(n).subinventory,
                       x_cascaded_table(n).locator_id,
                       x_cascaded_table(n).transfer_lpn_id,
                       x_cascaded_table(n).lpn_id,
                       x_cascaded_table(n).error_status,
                       x_cascaded_table(n).error_message
                      );
   END derive_inv_qty;

/* Bug 3639667.
 * The code here was originally in derive_inv_qty. But we have changed
 * the parameters here so that this can be called from the client side
 * library for the Enter returns and Enter corrections forms also.
*/
   PROCEDURE derive_inv_qty_1(
      p_destination_type_code    IN            rcv_transactions_interface.destination_type_code%TYPE,
      p_transaction_type         IN            rcv_transactions_interface.transaction_type%TYPE,
      p_quantity                 IN            rcv_transactions_interface.quantity%TYPE,
      p_interface_transaction_id IN            rcv_transactions_interface.interface_transaction_id%TYPE,
      p_to_organization_id       IN            rcv_transactions_interface.to_organization_id%TYPE,
      p_item_id                  IN            rcv_transactions_interface.item_id%TYPE,
      p_item_revision            IN            rcv_transactions_interface.item_revision%TYPE,
      p_receipt_source_code      IN            rcv_transactions_interface.receipt_source_code%TYPE,
      p_po_header_id             IN            rcv_transactions_interface.po_header_id%TYPE,
      p_unit_of_measure          IN            rcv_transactions_interface.unit_of_measure%TYPE,
      p_primary_unit_of_measure  IN            rcv_transactions_interface.primary_unit_of_measure%TYPE,
      p_subinventory             IN            rcv_transactions_interface.subinventory%TYPE,
      p_locator_id               IN            rcv_transactions_interface.locator_id%TYPE,
      p_transfer_lpn_id          IN            rcv_transactions_interface.transfer_lpn_id%TYPE,
      p_lpn_id                   IN            rcv_transactions_interface.lpn_id%TYPE,
      x_error_status             IN OUT NOCOPY VARCHAR2,
      x_error_message            IN OUT NOCOPY VARCHAR2
   ) IS
      CURSOR lot_rows(
         l_interface_id NUMBER
      ) IS
         SELECT lot_number,
                transaction_quantity
         FROM   mtl_transaction_lots_interface
         WHERE  product_transaction_id = l_interface_id;

      l_lot                        lot_rows%ROWTYPE;

      CURSOR rti_rows(
         l_interface_id NUMBER
      ) IS
         SELECT quantity
         FROM   rcv_transactions_interface
         WHERE  interface_transaction_id = l_interface_id;

      l_rti                        rti_rows%ROWTYPE;
      l_negative_inv_receipt_code  NUMBER;
      l_interface_id               NUMBER;
      l_return_status              VARCHAR2(10);
      l_msg_count                  NUMBER;
      l_msg_data                   VARCHAR2(2000);
      l_tree_mode                  NUMBER;
      l_is_serial_control          BOOLEAN                                            := FALSE;
      l_is_lot_control             BOOLEAN                                            := FALSE;
      l_is_revision_control        BOOLEAN                                            := FALSE;
      l_demand_source_type_id      NUMBER;
      l_demand_source_header_id    NUMBER;
      l_lot_number                 VARCHAR2(30);
      l_update_quantity            NUMBER;
      l_qoh                        NUMBER;
      l_att                        NUMBER;
      l_rqoh                       NUMBER;
      l_qr                         NUMBER;
      l_qs                         NUMBER;
      l_atr                        NUMBER;
      l_lot_control_code           mtl_system_items.lot_control_code%TYPE;
      l_serial_number_control_code mtl_system_items.serial_number_control_code%TYPE;
      l_revision_qty_control_code  mtl_system_items.revision_qty_control_code%TYPE;
      l_revision                   rcv_transactions_interface.item_revision%TYPE;
      l_primary_qty                NUMBER;
      l_table_name                 po_interface_errors.table_name%TYPE;
   BEGIN
      /* We need to do this only for returns and -ve corrections.
       * So return if it is not any of this transaction type.
      */
      IF (    (p_destination_type_code = 'INVENTORY')
          AND (p_transaction_type NOT IN('RETURN TO RECEIVING', 'RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'CORRECT'))) THEN --{
         RETURN;
      END IF; --}

      /* We should return if it is a +ve correction. */
      IF (    p_transaction_type = 'CORRECT'
          AND p_quantity > 0) THEN
         RETURN;
      END IF;

      l_interface_id  := p_interface_transaction_id;

      SELECT NVL(mp.negative_inv_receipt_code, -999)
      INTO   l_negative_inv_receipt_code
      FROM   mtl_system_items msi,
             mtl_parameters mp
      WHERE  mp.organization_id = p_to_organization_id
      AND    msi.organization_id = mp.organization_id
      AND    msi.inventory_item_id = p_item_id;

      IF (l_negative_inv_receipt_code = -999) THEN
         SELECT negative_inv_receipt_code
         INTO   l_negative_inv_receipt_code
         FROM   mtl_parameters
         WHERE  organization_id = p_to_organization_id;
      END IF;

      l_tree_mode     := inv_quantity_tree_pub.g_transaction_mode;

      SELECT msi.revision_qty_control_code,
             msi.lot_control_code,
             msi.serial_number_control_code
      INTO   l_revision_qty_control_code,
             l_lot_control_code,
             l_serial_number_control_code
      FROM   mtl_system_items msi
      WHERE  inventory_item_id = p_item_id
      AND    NVL(msi.organization_id, p_to_organization_id) = p_to_organization_id;

      IF l_revision_qty_control_code <> '2' THEN
         l_is_revision_control  := FALSE;
      ELSE
         l_is_revision_control  := TRUE;
         l_revision             := p_item_revision;
      END IF;

      IF NVL(l_lot_control_code, 0) = 2 THEN
         l_is_lot_control  := TRUE;
      END IF;

      IF (NVL(l_serial_number_control_code, 1) <> 1) THEN
         l_is_serial_control  := TRUE;
      END IF;

      /* WE can return only a PO or RMA */
      IF (p_receipt_source_code = 'VENDOR') THEN
         l_demand_source_type_id    := 1;
         l_demand_source_header_id  := p_po_header_id;
      ELSE
         l_demand_source_type_id    := -9999;
         l_demand_source_header_id  := -9999;
      END IF;

      IF (l_negative_inv_receipt_code = 2) THEN --{
         IF (l_is_lot_control) THEN
            OPEN lot_rows(l_interface_id);
         ELSE   /* Serial control or not a lot/serial control */
            OPEN rti_rows(l_interface_id);
         END IF;

         LOOP --{
            /* Get the primary quantity.*/
            IF (lot_rows%ISOPEN) THEN --{
               FETCH lot_rows INTO l_lot;
               EXIT WHEN lot_rows%NOTFOUND;

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('lot_number ' || l_lot.lot_number);
               END IF;

               l_lot_number   := l_lot.lot_number;
               l_primary_qty  := ABS(rcv_transactions_interface_sv.convert_into_correct_qty(l_lot.transaction_quantity,
                                                                                            p_unit_of_measure,
                                                                                            p_item_id,
                                                                                            p_primary_unit_of_measure
                                                                                           ));
            ELSIF(rti_rows%ISOPEN) THEN --}{
               FETCH rti_rows INTO l_rti;
               EXIT WHEN rti_rows%NOTFOUND;
               l_lot_number   := NULL;
               l_primary_qty  := ABS(rcv_transactions_interface_sv.convert_into_correct_qty(l_rti.quantity,
                                                                                            p_unit_of_measure,
                                                                                            p_item_id,
                                                                                            p_primary_unit_of_measure
                                                                                           ));
            END IF; --}

            inv_quantity_tree_pub.query_quantities(p_api_version_number            => 1.0,
                                                   p_init_msg_lst                  => fnd_api.g_false,
                                                   x_return_status                 => l_return_status,
                                                   x_msg_count                     => l_msg_count,
                                                   x_msg_data                      => l_msg_data,
                                                   p_organization_id               => p_to_organization_id,
                                                   p_inventory_item_id             => p_item_id,
                                                   p_tree_mode                     => l_tree_mode,
                                                   p_is_revision_control           => l_is_revision_control,
                                                   p_is_lot_control                => l_is_lot_control,
                                                   p_is_serial_control             => l_is_serial_control,
                                                   p_demand_source_type_id         => l_demand_source_type_id,
                                                   p_demand_source_header_id       => l_demand_source_header_id,
                                                   p_demand_source_line_id         => NULL,
                                                   p_demand_source_name            => NULL,
                                                   p_lot_expiration_date           => NULL,
                                                   p_revision                      => p_item_revision,
                                                   p_lot_number                    => l_lot_number,
                                                   p_subinventory_code             => p_subinventory,
                                                   p_locator_id                    => p_locator_id,
                                                   p_onhand_source                 => 3,
                                                   x_qoh                           => l_qoh,
                                                   x_rqoh                          => l_rqoh,
                                                   x_qr                            => l_qr,
                                                   x_qs                            => l_qs,
                                                   x_att                           => l_att,
                                                   x_atr                           => l_atr,
                                                   p_transfer_subinventory_code    => NULL,
                                                   p_cost_group_id                 => NULL,
                                                   p_lpn_id                        => p_transfer_lpn_id,
                                                   p_transfer_locator_id           => NULL
                                                  );

            IF (lot_rows%ISOPEN) THEN
               l_table_name  := 'MTL_TRANSACTION_LOTS_INTERFACE';
            ELSE
               l_table_name  := 'RCV_TRANSACTIONS_INTERFACE';
            END IF;

            IF (l_return_status = 'S') THEN --{
               x_error_status  := 'S';

               IF (l_primary_qty > NVL(l_att, 0)) THEN --{
                  x_error_status   := 'E';
                  x_error_message  := 'RCV_TRX_QTY_EXCEEDS_INV_AVAIL';
                  rcv_error_pkg.set_error_message(x_error_message);
                  rcv_error_pkg.set_token('PRIMARY', l_primary_qty);
                  rcv_error_pkg.set_token('SUB', l_att);
                  rcv_error_pkg.log_interface_error('PRIMARY_QUANTITY', FALSE);
                  EXIT;
               ELSE -- }{
                  x_error_status  := 'S';
               END IF; --}
            ELSE --}{
               x_error_status   := 'E';
               x_error_message  := 'RCV_TRX_QTY_EXCEEDS_INV_AVAIL';
               rcv_error_pkg.set_error_message(x_error_message);
               rcv_error_pkg.set_token('PRIMARY', l_primary_qty);
               rcv_error_pkg.set_token('SUB', l_att);
               rcv_error_pkg.log_interface_error('PRIMARY_QUANTITY', FALSE);
               EXIT;
            END IF; --}

            IF (p_transaction_type = 'CORRECT') THEN --{
               IF (SIGN(p_quantity) = 1) THEN
                  l_update_quantity  := l_primary_qty;
               ELSIF(SIGN(p_quantity) = -1) THEN
                  l_update_quantity  := -l_primary_qty;
               END IF;
            ELSE --}{
               l_update_quantity  := -l_primary_qty;
            END IF; --}

            inv_quantity_tree_pub.update_quantities(p_api_version_number         => 1.0,
                                                    p_init_msg_lst               => fnd_api.g_false,
                                                    x_return_status              => l_return_status,
                                                    x_msg_count                  => l_msg_count,
                                                    x_msg_data                   => l_msg_data,
                                                    p_organization_id            => p_to_organization_id,
                                                    p_inventory_item_id          => p_item_id,
                                                    p_tree_mode                  => l_tree_mode,
                                                    p_is_revision_control        => l_is_revision_control,
                                                    p_is_lot_control             => l_is_lot_control,
                                                    p_is_serial_control          => l_is_serial_control,
                                                    p_demand_source_type_id      => l_demand_source_type_id,
                                                    p_demand_source_header_id    => l_demand_source_header_id,
                                                    p_revision                   => l_revision,
                                                    p_lot_number                 => l_lot_number,
                                                    p_subinventory_code          => p_subinventory,
                                                    p_locator_id                 => p_locator_id,
                                                    p_primary_quantity           => l_update_quantity,
                                                    p_quantity_type              => inv_quantity_tree_pub.g_qoh,
                                                    x_qoh                        => l_qoh,
                                                    x_rqoh                       => l_rqoh,
                                                    x_qr                         => l_qr,
                                                    x_qs                         => l_qs,
                                                    x_att                        => l_att,
                                                    x_atr                        => l_atr,
                                                    p_lpn_id                     => p_lpn_id
                                                   );
         END LOOP; --}

         IF (lot_rows%ISOPEN) THEN
            CLOSE lot_rows;
         ELSIF(rti_rows%ISOPEN) THEN
            CLOSE rti_rows;
         END IF;
      END IF; --}
   END derive_inv_qty_1;
/* WMS Changes End */
END rcv_roi_return;

/
