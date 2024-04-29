--------------------------------------------------------
--  DDL for Package Body RCV_INT_ORDER_PP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_INT_ORDER_PP_PVT" AS
/* $Header: RCVPPIOB.pls 120.6.12010000.9 2012/06/07 08:08:40 yilali ship $ */

-- GLOBAL VARIABLES
   g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790
   x_progress  VARCHAR2(3);

-- LOCAL PROCEDURES

   PROCEDURE derive_io_rcv_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   );

   PROCEDURE derive_trans_del_line_quantity(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   );

   PROCEDURE derive_io_correct_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   );

   PROCEDURE derive_io_shipment_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN OUT NOCOPY BINARY_INTEGER
   );

-- GLOBAL PROCEDURES

   PROCEDURE derive_internal_order_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      rcv_roi_header_common.derive_ship_to_org_info(p_header_record);
      rcv_roi_header_common.derive_from_org_info(p_header_record);
      rcv_roi_header_common.derive_location_info(p_header_record);
      rcv_roi_header_common.derive_receiver_info(p_header_record);
   -- derive shipment info?
   END derive_internal_order_header;

   PROCEDURE default_internal_order_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      rcv_roi_header_common.default_last_update_info(p_header_record);
      rcv_roi_header_common.default_creation_info(p_header_record);
      -- default_shipment_num(p_header_record);
      -- RCV_ROI_HEADER_COMMON.default_shipment_header_id(p_header_record);

      /* Bug3591830 - Uncommented the call to default_receipt_info
      ** as receipt numbers were not getting generated while
      ** receiving and delivering Internal Orders through ROI
      */
      rcv_roi_header_common.default_receipt_info(p_header_record);
      rcv_roi_header_common.default_ship_to_location_info(p_header_record);

      -- RCV_ROI_HEADER_COMMON.genReceiptNum(p_header_record);

      -- for CANCEL

      -- IF p_header_record.header_record.transaction_type = 'CANCEL'
      /* Bug 3314675.
       * Call default_shipment_info to default the shipment_header_id if the
       * shipment_num is given for an inter-org/internal req receipts.
      */
      IF (   p_header_record.header_record.receipt_header_id IS NULL
          OR p_header_record.header_record.shipment_num IS NULL) THEN
         default_shipment_info(p_header_record);
      END IF;
   END default_internal_order_header;

   PROCEDURE validate_internal_order_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      rcv_roi_header_common.validate_trx_type(p_header_record);
       -- validate_document_type(p_header_record);
       -- validate_currency_code(p_header_record);
      -- RCV_ROI_HEADER_COMMON.validate_shipment_date(p_header_record);
       -- validate_receipt_date(p_header_record);
      rcv_roi_header_common.validate_expected_receipt_date(p_header_record);
      -- RCV_ROI_HEADER_COMMON.validate_receipt_num(p_header_record);
      rcv_roi_header_common.validate_ship_to_org_info(p_header_record);
      rcv_roi_header_common.validate_from_org_info(p_header_record);
      rcv_roi_header_common.validate_location_info(p_header_record);
      -- RCV_ROI_HEADER_COMMON.validate_payment_terms_info(p_header_record);
      rcv_roi_header_common.validate_receiver_info(p_header_record);
      rcv_roi_header_common.validate_freight_carrier_info(p_header_record);
   END validate_internal_order_header;

   /* Bug 3314675.
    * default_shipment_info defaults the shipment_header_id if the
    * shipment_num is given for an inter-org/internal req receipts.
   */
   PROCEDURE default_shipment_info(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
      x_count NUMBER;
   BEGIN
      IF p_header_record.header_record.receipt_header_id IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Shipment header Id has been provided');
         END IF;

         RETURN;
      END IF;

      IF (   p_header_record.header_record.shipment_num IS NULL
          OR p_header_record.header_record.shipment_num = '0'
          OR REPLACE(p_header_record.header_record.shipment_num,
                     ' ',
                     ''
                    ) IS NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Shipment num is still null');
            /* Bug 4907179 */
            asn_debug.put_line('Not able to default shipment_header_id, erroring out the transaction');
         END IF;

         /* Bug 4907179: Logging error in PO_INTERFACE_ERRORS table and erroring out the transaction, as
                         we are not able to default the shipment_header_id.
                         Reason: If shipment_header_id is not defaulted, we won't be able to stamp
                                 the receipt number created in RCV_SHIPMENT_HEADERS table, through
                                 rcv_int_order_pp_pvt.update_header() procedure.*/
         p_header_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_NO_SHIPMENT_NUM', p_header_record.error_record.error_message);
         rcv_error_pkg.log_interface_error('RCV_HEADERS_INTERFACE', 'SHIPMENT_NUM', false);/* Bug 4907179 */

         RETURN;
      END IF;

      SELECT MAX(shipment_header_id)
      INTO   p_header_record.header_record.receipt_header_id
      FROM   rcv_shipment_headers
      WHERE  shipment_num = p_header_record.header_record.shipment_num
      AND    receipt_source_code IN('INVENTORY', 'INTERNAL ORDER');
   EXCEPTION
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exception in when others in default_shipment_info ');
         END IF;

         rcv_error_pkg.set_sql_error_message('default_shipment_info', '000');
         p_header_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         p_header_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END default_shipment_info;

   PROCEDURE update_header(
      p_header_record IN OUT NOCOPY rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      -- Bug 12591134: Start
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('enter update_header');
      END IF;

      IF NVL(p_header_record.header_record.test_flag, 'N') = 'Y' THEN
         IF (p_header_record.header_record.receipt_num IS NOT NULL) THEN
             BEGIN
                  UPDATE rcv_shipment_headers
                  SET    receipt_num            = p_header_record.header_record.receipt_num,
                         last_update_date       = p_header_record.header_record.last_update_date,
                         last_updated_by        = p_header_record.header_record.last_updated_by,
                         last_update_login      = p_header_record.header_record.last_update_login,
                         request_id             = fnd_global.conc_request_id,
                         program_application_id = fnd_global.prog_appl_id,
                         program_id             = fnd_global.conc_program_id,
                         program_update_date    = SYSDATE
                  WHERE  shipment_header_id     = p_header_record.header_record.receipt_header_id
                  AND    receipt_num IS NULL;

                  IF (g_asn_debug = 'Y') THEN
                      asn_debug.put_line('Updated receipt_num in RSH');
                  END IF;
             EXCEPTION
                 WHEN NO_DATA_FOUND THEN NULL;
             END;
         END IF;
         RETURN;
      END IF;
      -- Bug 12591134: End
      UPDATE rcv_shipment_headers
         SET shipment_header_id = p_header_record.header_record.receipt_header_id,
             last_update_date = p_header_record.header_record.last_update_date,
             last_updated_by = p_header_record.header_record.last_updated_by,
             creation_date = p_header_record.header_record.creation_date,
             created_by = p_header_record.header_record.created_by,
             last_update_login = p_header_record.header_record.last_update_login,
             receipt_source_code = p_header_record.header_record.receipt_source_code,
             vendor_id = p_header_record.header_record.vendor_id,
             vendor_site_id = p_header_record.header_record.vendor_site_id,
             shipment_num = p_header_record.header_record.shipment_num,
             receipt_num = NVL(receipt_num, p_header_record.header_record.receipt_num),
             ship_to_location_id = p_header_record.header_record.location_id,
             ship_to_org_id = p_header_record.header_record.ship_to_organization_id,
             bill_of_lading = p_header_record.header_record.bill_of_lading,
             packing_slip = p_header_record.header_record.packing_slip,
             shipped_date = Nvl(p_header_record.header_record.shipped_date,shipped_date),--BUG 5087622
             freight_carrier_code = p_header_record.header_record.freight_carrier_code,
             expected_receipt_date = p_header_record.header_record.expected_receipt_date,
             employee_id = p_header_record.header_record.employee_id,
             num_of_containers = p_header_record.header_record.num_of_containers,
             waybill_airbill_num = p_header_record.header_record.waybill_airbill_num,
             comments = p_header_record.header_record.comments,
             attribute_category = p_header_record.header_record.attribute_category,
             attribute1 = p_header_record.header_record.attribute1,
             attribute2 = p_header_record.header_record.attribute2,
             attribute3 = p_header_record.header_record.attribute3,
             attribute4 = p_header_record.header_record.attribute4,
             attribute5 = p_header_record.header_record.attribute5,
             attribute6 = p_header_record.header_record.attribute6,
             attribute7 = p_header_record.header_record.attribute7,
             attribute8 = p_header_record.header_record.attribute8,
             attribute9 = p_header_record.header_record.attribute9,
             attribute10 = p_header_record.header_record.attribute10,
             attribute11 = p_header_record.header_record.attribute11,
             attribute12 = p_header_record.header_record.attribute12,
             attribute13 = p_header_record.header_record.attribute13,
             attribute14 = p_header_record.header_record.attribute14,
             attribute15 = p_header_record.header_record.attribute15,
             ussgl_transaction_code = p_header_record.header_record.usggl_transaction_code,
             request_id = fnd_global.conc_request_id,
             program_application_id = fnd_global.prog_appl_id,
             program_id = fnd_global.conc_program_id,
             program_update_date = SYSDATE,
             asn_type = p_header_record.header_record.asn_type,
             edi_control_num = p_header_record.header_record.edi_control_num,
             notice_creation_date = p_header_record.header_record.notice_creation_date,
             gross_weight = p_header_record.header_record.gross_weight,
             gross_weight_uom_code = p_header_record.header_record.gross_weight_uom_code,
             net_weight = p_header_record.header_record.net_weight,
             net_weight_uom_code = p_header_record.header_record.net_weight_uom_code,
             tar_weight = p_header_record.header_record.tar_weight,
             tar_weight_uom_code = p_header_record.header_record.tar_weight_uom_code,
             packaging_code = p_header_record.header_record.packaging_code,
             carrier_method = p_header_record.header_record.carrier_method,
             carrier_equipment = p_header_record.header_record.carrier_equipment,
             special_handling_code = p_header_record.header_record.special_handling_code,
             hazard_code = p_header_record.header_record.hazard_code,
             hazard_class = p_header_record.header_record.hazard_class,
             hazard_description = p_header_record.header_record.hazard_description,
             freight_terms = p_header_record.header_record.freight_terms,
             freight_bill_number = p_header_record.header_record.freight_bill_number,
             invoice_date = p_header_record.header_record.invoice_date,
             invoice_amount = p_header_record.header_record.total_invoice_amount,
             tax_name = p_header_record.header_record.tax_name,
             tax_amount = p_header_record.header_record.tax_amount,
             freight_amount = p_header_record.header_record.freight_amount,
             invoice_status_code = p_header_record.header_record.invoice_status_code,
             currency_code = p_header_record.header_record.currency_code,
             conversion_rate_type = p_header_record.header_record.conversion_rate_type,
             conversion_rate = p_header_record.header_record.conversion_rate,
             conversion_date = p_header_record.header_record.conversion_rate_date,
             payment_terms_id = p_header_record.header_record.payment_terms_id,
             invoice_num = p_header_record.header_record.invoice_num
       WHERE shipment_header_id = p_header_record.header_record.receipt_header_id;
   END update_header;

   PROCEDURE derive_io_receive_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      x_progress                         := '000';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter internal order receiving line');
      END IF;

      -- 1) derive ship to org info
      rcv_roi_transaction.derive_ship_to_org_info(x_cascaded_table,
                                                  n,
                                                  x_header_record
                                                 );
      x_progress                         := '002';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('x_progress ' || x_progress);
      END IF;

      x_progress                         := '010';
      -- 5) derive item info
      rcv_roi_transaction.derive_item_info(x_cascaded_table, n);
      x_progress                         := '015';
      rcv_roi_header_common.derive_uom_info(x_cascaded_table, n);
      -- 6) derive substitute item info
      rcv_roi_transaction.derive_substitute_item_info(x_cascaded_table, n);
      x_progress                         := '020';
      -- 8) derive from org info
      rcv_roi_transaction.derive_from_org_info(x_cascaded_table, n);
      x_progress                         := '035';
      -- 12) derive routing header info
      rcv_roi_transaction.derive_routing_header_info(x_cascaded_table, n);
      x_progress                         := '070';
      asn_debug.put_line('progress in Internal Orders rcv : x progress = ' || x_progress);
      -- derive auto transact code
      rcv_roi_transaction.derive_auto_transact_code(x_cascaded_table, n);
      -- 13) bug 3379550
      x_progress                         := '071';
      asn_debug.put_line('progress in Internal Orders rcv : x progress = ' || x_progress);
      /* Bug 3684984.
       * We are getting all the values we used to get in the foll. code
       * in the cursor in derive_io_rcv_line_qty.
      derive_io_shipment_info(x_cascaded_table, n);
      */
      asn_debug.put_line('progress in Internal Orders rcv : before derive qty');
      -- quantity > 0
      derive_io_rcv_line_qty(x_cascaded_table,
                             n,
                             temp_cascaded_table
                            );
      /* Bug3591830 - Calling the routine derive_to_locator_id to
      ** derive the locator_id from locator if locator_id is null
      ** and locator is specified. If an invalid locator is specified
      ** then corresponding error message needs to be populated in the
      ** interface errors table
      */
      /* Bug3591830 - START */
      rcv_roi_transaction.derive_to_locator_id(x_cascaded_table, n);
      temp_cascaded_table(n).locator_id  := x_cascaded_table(n).locator_id;
      asn_debug.put_line('progress in Internal Orders rcv : after derive_to_locator_id -> locator_id = ' || temp_cascaded_table(n).locator_id);
      rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                          'LOCATOR_ID',
                                          FALSE
                                         );
   /* Bug3591830 - END */
   END derive_io_receive_line;

   PROCEDURE derive_io_trans_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_io_trans_line ');
      END IF;

      rcv_roi_transaction.derive_parent_id(x_cascaded_table, n);
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
      /* Bug#4037821 - START */
      /* Derive the locator_id even in case of deliver transactions */
      IF (x_cascaded_table(n).transaction_type IN ('TRANSFER','DELIVER')) THEN
          IF (x_cascaded_table(n).transaction_type = 'TRANSFER') THEN
             asn_debug.put_line('doing ship to location /locator derivations ');
             rcv_roi_transaction.derive_location_info(x_cascaded_table, n);
             rcv_roi_transaction.derive_from_locator_id(x_cascaded_table, n); -- WMS Change
          END IF;
          rcv_roi_transaction.derive_to_locator_id(x_cascaded_table, n); -- WMS Change
      END IF;
      /* Bug#4037821 - END */

      x_progress                              := '071';
      asn_debug.put_line('progress in Internal Orders rcv : x progress = ' || x_progress);
      derive_io_shipment_info(x_cascaded_table, n);
      x_progress                              := '091';
      rcv_roi_transaction.derive_reason_info(x_cascaded_table, n);
      /* Auto_transact_code is null for all these transaction types */
      x_cascaded_table(n).auto_transact_code  := NULL;
      derive_trans_del_line_quantity(x_cascaded_table,
                                     n,
                                     temp_cascaded_table
                                    );
   END derive_io_trans_line;

   PROCEDURE derive_io_correct_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_correction_line ');
      END IF;

      rcv_roi_transaction.derive_parent_id(x_cascaded_table, n);
      /* Derive the to_org_id */
      rcv_roi_transaction.derive_ship_to_org_info(x_cascaded_table,
                                                  n,
                                                  x_header_record
                                                 );

      IF (x_cascaded_table(n).unit_of_measure IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('x_progress ' || x_progress);
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

      x_progress                              := '071';
      asn_debug.put_line('progress in Internal Orders rcv : x progress = ' || x_progress);
      derive_io_shipment_info(x_cascaded_table, n);
      x_progress                              := '091';
      rcv_roi_transaction.derive_reason_info(x_cascaded_table, n);
      /* Auto_transact_code is null for all these transaction types */
      x_cascaded_table(n).auto_transact_code  := NULL;
      derive_io_correct_line_qty(x_cascaded_table,
                                 n,
                                 temp_cascaded_table
                                );
   END derive_io_correct_line;

   PROCEDURE default_io_receive_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      l_routing_header_id NUMBER;
   BEGIN
      -- logic should match int-org transfer
      rcv_int_org_transfer.default_int_org_rcv_line(x_cascaded_table, n);
      -- EXCEPT we should get the SO internal Receipt Routing.
      l_routing_header_id                    := x_cascaded_table(n).routing_header_id;

      IF (NVL(l_routing_header_id, 0) = 0) THEN
         BEGIN
            SELECT NVL(receiving_routing_id, 0)
            INTO   l_routing_header_id
            FROM   mtl_system_items
            WHERE  inventory_item_id = x_cascaded_table(n).item_id
            AND    organization_id = x_cascaded_table(n).to_organization_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               RAISE;
         END;

         IF (l_routing_header_id = 0) THEN
            BEGIN
               SELECT NVL(routing_header_id, 0)
               INTO   l_routing_header_id
               FROM   mtl_interorg_parameters
               WHERE  from_organization_id = x_cascaded_table(n).from_organization_id
               AND    to_organization_id = x_cascaded_table(n).to_organization_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  RAISE;
            END;
         END IF;

         IF (l_routing_header_id = 0) THEN
            BEGIN
               SELECT NVL(receiving_routing_id, 0)
               INTO   l_routing_header_id
               FROM   rcv_parameters
               WHERE  organization_id = x_cascaded_table(n).to_organization_id;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  RAISE;
            END;
         END IF;
      END IF;

      l_routing_header_id                    := x_cascaded_table(n).routing_header_id;
      x_cascaded_table(n).routing_header_id  := l_routing_header_id;
   END default_io_receive_line;

   PROCEDURE default_io_trans_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      -- logic should match int-org transfer
      rcv_int_org_transfer.default_int_org_trans_del(x_cascaded_table, n);
   END default_io_trans_line;

   PROCEDURE default_io_correct_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      -- logic should match int-org transfer
      rcv_int_org_transfer.default_int_org_cor_line(x_cascaded_table, n);
   END default_io_correct_line;

   PROCEDURE validate_io_receive_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
       l_parent_deliver_to_person_id NUMBER := null;  --Bug#6375015
       l_skip_validation             NUMBER := 0; --Bug#6375015
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter validate_io_receive_line');
      END IF;

      x_progress  := '000';
      rcv_roi_transaction.validate_shipment_source(x_cascaded_table, n);  /* bug9705269 */
      rcv_roi_transaction.validate_transaction_date(x_cascaded_table, n);
      rcv_roi_transaction.validate_transaction_uom(x_cascaded_table, n);
      rcv_roi_transaction.validate_item_info(x_cascaded_table, n);

      /*Bug 7836753
        Adding IF condition to ensure that the validation call for freight carriers is not made for
        Internal Orders and Inter-org transfers when the values are same at the header and transaction levels.
      */
      IF (x_cascaded_table(n).freight_carrier_code = x_header_record.header_record.freight_carrier_code) THEN
          NULL;
      ELSE
          rcv_roi_transaction.validate_freight_carrier_code(x_cascaded_table, n);
      END IF;
      /* End of fix for Bug 7836753 */

      rcv_roi_transaction.validate_dest_type(x_cascaded_table, n);

      IF (x_cascaded_table(n).ship_to_location_id IS NOT NULL) THEN
         rcv_roi_transaction.validate_ship_to_loc(x_cascaded_table, n);
      END IF;
      /* Bug:6375015
        There is no defaulting done for the deliver_to_person_id or validation against the parent_txn's
        deliver_to_person_id in case of ROI transaction. But in case of forms we are defaluting the
        deliver_to_person_id, if there is no validation failure on the deliver_to_person_id in Receipts/
        Receiving Transaction forms. If there is validation failure, deliver_to_person_id is nulled out
        and user can enter any deliver_to_person who is active in case of Receipts/Receiving Trasactions
        form. In case of Returns/Corrections, deliver_to_person_id is not editable and it is defaulted
        from the parent transaction, even if that person is terminated.
        So, added the following code to synch up the behaviour of forms and ROI
         a) if deliver_to_person_id is null, default the  deliver_to_person_id from the
            parent_txn/rsl as done in forms.
         b) If the deliver_to_person_id is not null, we have to validate against the
            parent_txn's deliver_to_person.
         c) Skip the call to validate_deliver_to_person, if deliver_to_person is defaulted
            from the parent transaction.
        */
/* code fix for the Bug:6375015 starts */
        IF (x_cascaded_table(n).deliver_to_person_id is null) THEN
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Inside deliver_to_person_id is null...');
           END IF;

           IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
              --In case of transaction_type DELIVER, we need parent transaction.
              --If this condition is not added, it will try to defalut the deliver_to_person
              --of the parent transaction. But form is not behaving like that.
              --So added this condition to default the deliver_to_person of the source document.
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Transaction type is DELIVER...');
                 asn_debug.put_line('defaulting deliver_to_person_id from RSL...');
              END IF;
              get_deliver_to_person_from_rsl(x_cascaded_table,n);
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('After call to get_deliver_to_person_from_rsl...');
              END IF;
           ELSIF (x_cascaded_table(n).parent_transaction_id is not null) THEN
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Inside parent_transaction_id.is not null and the value is:'||x_cascaded_table(n).parent_transaction_id);
              END IF;
              l_parent_deliver_to_person_id := get_deliver_to_person_from_rt(x_cascaded_table,n);
              --We can safely skip the validate_deliver_to_person call
              l_skip_validation := 1;
              x_cascaded_table(n).deliver_to_person_id := l_parent_deliver_to_person_id;
              IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('deliver_to_person_is is set to :'||l_parent_deliver_to_person_id);
              END IF;
           ELSIF (x_cascaded_table(n).parent_interface_txn_id is not null) THEN
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Inside parent_interface_transaction_id.is not null and the value is:'||x_cascaded_table(n).parent_interface_txn_id);
              END IF;
              l_parent_deliver_to_person_id := get_deliver_to_person_from_rti(x_cascaded_table,n);
              --We can safely skip the validate_deliver_to_person call
              l_skip_validation := 1;
              x_cascaded_table(n).deliver_to_person_id := l_parent_deliver_to_person_id;
              IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('deliver_to_person_is is set to :'||l_parent_deliver_to_person_id);
              END IF;
           ELSE--IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('defaulting deliver_to_person_id from RSL...');
              END IF;
              get_deliver_to_person_from_rsl(x_cascaded_table,n);
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('After call to get_deliver_to_person_from_rsl...');
              END IF;
           END IF;--IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
        ELSE--(x_cascaded_table(n).deliver_to_person_id is null)
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('Inside deliver_to_person_id is not null and the value is :'||x_cascaded_table(n).deliver_to_person_id);
           END IF;

           IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
              --In forms user can select any active deliver_to_person for DELIVER transaction.
              --In case of transaction_type DELIVER, we need parent transaction.
              --If this condition is not added, it will validate against the deliver_to_person mentioned
              --the parent RECEIVE transaction. But form is not behaving like that.
              --So, added this condition to skip deliver_to_person validation against parent txn
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Transaction type is DELIVER...');
              END IF;
           ELSIF (x_cascaded_table(n).parent_transaction_id is not null) THEN
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Inside parent_transaction_id.is not null and the value is:'||x_cascaded_table(n).parent_transaction_id);
              END IF;
              l_parent_deliver_to_person_id := get_deliver_to_person_from_rt(x_cascaded_table,n);
              --We can safely skip the validate_deliver_to_person call, validation against
              --parent transaction is handled here itself.
                 l_skip_validation := 1;
              IF nvl(l_parent_deliver_to_person_id,-99) <> x_cascaded_table(n).deliver_to_person_id THEN
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('RTI.deliver_to_person_id is different to that of parent txn...');
                 END IF;
               --deliver_to_person_id mismatches with the parent txn's deliver_to_person, so clear it off
                 x_cascaded_table(n).deliver_to_person_id   := null;
                 x_cascaded_table(n).deliver_to_person_name := null;

              --set the deliver_to_person_id to that of parent transaction
                 x_cascaded_table(n).deliver_to_person_id := l_parent_deliver_to_person_id;
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('deliver_to_person_is is set to that of parent RT txn');
                 END IF;
              END IF;
           ELSIF (x_cascaded_table(n).parent_interface_txn_id is not null) THEN
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Inside parent_interface_transaction_id.is not null and the value is:'||x_cascaded_table(n).parent_interface_txn_id);
              END IF;
              l_parent_deliver_to_person_id := get_deliver_to_person_from_rti(x_cascaded_table,n);
              --We can safely skip the validate_deliver_to_person call, validation against
              --parent transaction is handled here itself.
                 l_skip_validation := 1;
              IF nvl(l_parent_deliver_to_person_id,-99) <> x_cascaded_table(n).deliver_to_person_id THEN
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('RTI.deliver_to_person_id is different to that of parent txn...');
                 END IF;
               --deliver_to_person_id mismatches with the parent txn's deliver_to_person, so clear it off
                 x_cascaded_table(n).deliver_to_person_id   := null;
                 x_cascaded_table(n).deliver_to_person_name := null;

              --set the deliver_to_person_id to that of parent transaction
                 x_cascaded_table(n).deliver_to_person_id := l_parent_deliver_to_person_id;

                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('deliver_to_person_is is set to that of parent RT txn');
                 END IF;
              END IF;
           END IF;--IF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
        END IF;--(x_cascaded_table(n).deliver_to_person_id is null)

        IF l_skip_validation = 0 THEN
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('validate_deliver_to_person is called');
           END IF;
           rcv_roi_transaction.validate_deliver_to_person(x_cascaded_table, n);
           IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('After validate_deliver_to_person: ' || x_cascaded_table(n).error_status);
           END IF;
        ELSE
           IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('call to validate_deliver_to_person is skipped');
           END IF;
        END IF;/* code fix for the Bug:6375015 ends */

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
/** OPM change Bug# 3061052**/
      rcv_roi_transaction.validate_opm_attributes(x_cascaded_table, n);

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
   END validate_io_receive_line;

   PROCEDURE derive_io_rcv_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
      /*  Bug 3684984.
       *  Added the columns requisition_line_id, employee_id and
       * po_line_location_id to the cursor. We used to get this before
       * in derive_io_shipment_info. Now we are not calling it for
       * the receive transaction.
      */
      CURSOR shipments(
         v_shipment_header_id NUMBER,
--       v_shipment_num       VARCHAR2, --Bugfix 5201155
         v_document_line_num  NUMBER,
         v_item_id            NUMBER,
         v_ship_to_org_id     NUMBER,
         v_ship_from_org_id   NUMBER,
         v_shipment_line_id   NUMBER -- Bug 8374257
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
                rsl.primary_unit_of_measure primary_unit_of_measure,
                rsl.requisition_line_id requisition_line_id,
                rsl.po_line_location_id po_line_location_id,
                rsl.employee_id employee_id
         FROM   rcv_shipment_headers rsh,
                rcv_shipment_lines rsl,
		po_requisition_lines_all porl
-- Following 2 lines are commented out for Bugfix 5201155
--         WHERE  rsh.shipment_header_id = NVL(v_shipment_header_id, rsh.shipment_header_id)
--         AND    NVL(rsh.shipment_num, '0') = NVL(v_shipment_num, NVL(rsh.shipment_num, '0'))
         WHERE  rsh.shipment_header_id = v_shipment_header_id   -- Bugfix 5201155
         AND    rsl.shipment_header_id = rsh.shipment_header_id
         AND    NVL(rsl.item_id, 0) = NVL(v_item_id, NVL(rsl.item_id, 0))
         AND    porl.line_num = NVL(v_document_line_num, porl.line_num)--bug 5483231
	 AND    porl.requisition_line_id = rsl.requisition_line_id--bug 5483231
         AND    rsl.to_organization_id = NVL(v_ship_to_org_id, rsl.to_organization_id)
         AND    rsl.from_organization_id = NVL(v_ship_from_org_id, rsl.from_organization_id)
         AND    (NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'FULLY RECEIVED')
         AND    rsh.receipt_source_code = 'INTERNAL ORDER'
         AND    rsl.shipment_line_id = NVL(v_shipment_line_id, rsl.shipment_line_id); -- Bug 8374257

      CURSOR count_shipments(
         v_shipment_header_id NUMBER,
--         v_shipment_num       VARCHAR2,  -- Bugfix 5201155
         v_document_line_num  VARCHAR,
         v_item_id            NUMBER,
         v_ship_to_org_id     NUMBER,
         v_ship_from_org_id   NUMBER,
         v_shipment_line_id   NUMBER -- Bug 8374257
      ) IS
         SELECT COUNT(*) AS line_count
         FROM   rcv_shipment_headers rsh,
                rcv_shipment_lines rsl,
		po_requisition_lines_all porl
-- Following 2 lines are commented out for Bugfix 5201155
--         WHERE  rsh.shipment_header_id = NVL(v_shipment_header_id, rsh.shipment_header_id)
--         AND    NVL(rsh.shipment_num, '0') = NVL(v_shipment_num, NVL(rsh.shipment_num, '0'))
         WHERE  rsh.shipment_header_id = v_shipment_header_id   -- Bugfix 5201155
         AND    rsl.shipment_header_id = rsh.shipment_header_id
         AND    NVL(rsl.item_id, 0) = NVL(v_item_id, NVL(rsl.item_id, 0))
         AND    porl.line_num = NVL(v_document_line_num, porl.line_num)--bug 5483231
	 AND    porl.requisition_line_id = rsl.requisition_line_id--bug 5483231
         AND    rsl.to_organization_id = NVL(v_ship_to_org_id, rsl.to_organization_id)
         AND    rsl.from_organization_id = NVL(v_ship_from_org_id, rsl.from_organization_id)
         AND    (NVL(rsl.shipment_line_status_code, 'EXPECTED') <> 'FULLY RECEIVED')
         AND    rsh.receipt_source_code = 'INTERNAL ORDER'
         AND    rsl.shipment_line_id = NVL(v_shipment_line_id, rsl.shipment_line_id); -- Bug 8374257

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
      l_shipment_header_id         rcv_shipment_headers.shipment_header_id%TYPE; -- Bugfix 5201155
   BEGIN
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
          AND x_cascaded_table(n).shipment_num IS NULL) THEN
         -- error_status and error_message are set after validate_quantity_shipped
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('no shipment num/shipment header specified ');
            asn_debug.put_line('status = ' || x_cascaded_table(n).error_status);
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

      -- Bugfix 5201155
      IF (    x_cascaded_table(n).shipment_header_id IS NULL
          AND x_cascaded_table(n).shipment_num IS NOT NULL) THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Shipment header is not provided hence deriving shipment header id for shipment num ' || x_cascaded_table(n).shipment_num );
         END IF;

/*  Bug:6313315
     Added where clause condition rsh.receipt_source_code = 'INTERNAL ORDER'.
     As we can have same shipment number for ISO shipment and Inter org shipment
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
                AND     rsh.receipt_source_code = 'INTERNAL ORDER';--Bug: 6313315

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
      -- End of code for Bugfix 5201155

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
         asn_debug.put_line('shipment line id ' || TO_CHAR(temp_cascaded_table(current_n).shipment_line_id)); -- Bug 8374257
         asn_debug.put_line('proceed to open cursor');
      END IF;

      OPEN shipments(-- temp_cascaded_table(current_n).shipment_header_id, -- Bugfix 5201155
                     -- temp_cascaded_table(current_n).shipment_num, -- Bugfix 5201155
                     l_shipment_header_id,                                 -- Bugfix 5201155
                     temp_cascaded_table(current_n).document_line_num,
                     temp_cascaded_table(current_n).item_id,
                     temp_cascaded_table(current_n).to_organization_id,
                     temp_cascaded_table(current_n).from_organization_id,
                     temp_cascaded_table(current_n).shipment_line_id -- Bug 8374257
                    );
      -- count_shipments just gets the count of rows found in shipments

      OPEN count_shipments(-- temp_cascaded_table(current_n).shipment_header_id, -- Bugfix 5201155
                           -- temp_cascaded_table(current_n).shipment_num,       -- Bugfix 5201155
                           l_shipment_header_id,
                           temp_cascaded_table(current_n).document_line_num,
                           temp_cascaded_table(current_n).item_id,
                           temp_cascaded_table(current_n).to_organization_id,
                           temp_cascaded_table(current_n).from_organization_id,
                           temp_cascaded_table(current_n).shipment_line_id -- Bug 8374257
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
                     asn_debug.put_line(' in internal order transfer rcv Extra Quantity ' || TO_CHAR(x_remaining_quantity));
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
                  --  there are rows in rsl for this rti row

                  -- Delete the temp_cascaded_table just to be sure
                  IF temp_cascaded_table.COUNT > 0 THEN
                     FOR i IN 1 .. temp_cascaded_table.COUNT LOOP
                        temp_cascaded_table.DELETE(i);
                     END LOOP;
                  END IF;

                  x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
                  rcv_error_pkg.set_error_message('RCV_TP_INVALID_TRX_TYPE', x_cascaded_table(n).error_message);
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
         END IF;        --}
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
                  -- Bug 13744041: Start
                  IF (x_shipmentrec.unit_of_measure <> temp_cascaded_table(1).unit_of_measure AND
                      round(x_remaining_quantity,5) <  0.00005) THEN
                      x_converted_trx_qty      := x_remaining_qty_rsl_uom + x_converted_trx_qty;
                      x_remaining_qty_rsl_uom  := 0;
                      x_remaining_quantity     := 0;
                  END IF;
                  -- Bug 13744041: End
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
               IF rows_fetched = x_record_count THEN                                    --{ last row needs to be inserted anyway
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
               temp_cascaded_table(current_n).quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_trx_qty,
                                                                                                        x_shipmentrec.unit_of_measure,
                                                                                                        temp_cascaded_table(current_n).item_id,
                                                                                                        temp_cascaded_table(current_n).unit_of_measure
                                                                                                       ); -- in asn uom
               temp_cascaded_table(current_n).quantity := round (temp_cascaded_table(current_n).quantity,5); -- Bug 13744041
            ELSE
               temp_cascaded_table(current_n).quantity  := round (x_converted_trx_qty,5); -- Bug 13744041
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Transaction qty in terms of the transaction uom is ' || temp_cascaded_table(current_n).quantity);
            END IF;

            -- primary qty in primary uom
            IF (temp_cascaded_table(current_n).primary_unit_of_measure <> x_shipmentrec.unit_of_measure) THEN
               temp_cascaded_table(current_n).primary_quantity  := rcv_roi_transaction.convert_into_correct_qty(x_converted_trx_qty,
                                                                                                                x_shipmentrec.unit_of_measure,
                                                                                                                temp_cascaded_table(current_n).item_id,
                                                                                                                temp_cascaded_table(current_n).primary_unit_of_measure
                                                                                                               );
               temp_cascaded_table(current_n).primary_quantity := round (temp_cascaded_table(current_n).primary_quantity,5);  -- Bug 13744041
            ELSE
               temp_cascaded_table(current_n).primary_quantity        := round(x_converted_trx_qty,5); -- Bug 13744041

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

               /* Bug 3684984.
                * We added requisition_line_id, po_line_location_id
                * and employee_id to the shipment cursor. Copy that
                * to temp_cascaded_table. This used to happen in
                * derive_io_shipment_info before.
               */
               IF temp_cascaded_table(current_n).requisition_line_id IS NULL THEN
                  temp_cascaded_table(current_n).requisition_line_id  := x_shipmentrec.requisition_line_id;
               END IF;

               IF temp_cascaded_table(current_n).po_line_location_id IS NULL THEN
                  temp_cascaded_table(current_n).po_line_location_id  := x_shipmentrec.po_line_location_id;
               END IF;

               IF temp_cascaded_table(current_n).employee_id IS NULL THEN
                  temp_cascaded_table(current_n).employee_id  := x_shipmentrec.employee_id;
               END IF;

               /* End of bug 3684984. */

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

                -- OPM change.Bug# 3061052
                -- if original receiving transaction line is split and secondary quantity is specified then
                -- set secondary quantity for the split lines to NULL.
     /* INVCONV , removed opm installed flag . Punit Kumar */
      IF  /*   gml_process_flags.opm_installed = 1
         AND */ x_cascaded_table(n).secondary_quantity IS NOT NULL THEN
         IF temp_cascaded_table.COUNT > 1 THEN
            FOR j IN 1 .. temp_cascaded_table.COUNT LOOP
               temp_cascaded_table(j).secondary_quantity  := NULL;
            END LOOP;
         END IF;
      END IF;
      /* end , INVCONV */

      IF shipments%ISOPEN THEN
         CLOSE shipments;
      END IF;

      IF count_shipments%ISOPEN THEN
         CLOSE count_shipments;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('exit derive_io_rcv_line_qty');
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

         rcv_error_pkg.set_sql_error_message('derive_io_rcv_line_qty', x_progress);
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(n));
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('error ' || x_progress);
         END IF;
   END derive_io_rcv_line_qty;

   PROCEDURE derive_trans_del_line_quantity(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
   BEGIN
      -- logic should match inter-org transfer, so
      rcv_int_org_transfer.derive_trans_del_line_quantity(x_cascaded_table,
                                                          n,
                                                          temp_cascaded_table
                                                         );
   END derive_trans_del_line_quantity;

   PROCEDURE derive_io_correct_line_qty(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type
   ) IS
   BEGIN
      -- logic is the same for inter_org xfer, so...
      rcv_int_org_transfer.derive_int_org_cor_line_qty(x_cascaded_table,
                                                       n,
                                                       temp_cascaded_table
                                                      );
   END derive_io_correct_line_qty;

   PROCEDURE derive_io_shipment_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN OUT NOCOPY BINARY_INTEGER
   ) IS
      l_shipment_header_id    NUMBER;
      l_shipment_line_id      NUMBER;
      l_requisition_line_id   NUMBER;
      l_ship_to_location_id   NUMBER;
      l_subinventory          VARCHAR2(255);
      l_po_line_location_id   NUMBER;
      l_destination_type_code VARCHAR2(255);
      l_to_organization_id    NUMBER;
      l_item_id               NUMBER;
      l_category_id           NUMBER;
      l_employee_id           NUMBER;
   BEGIN
      IF (   x_cascaded_table(n).parent_transaction_id IS NULL
          OR x_cascaded_table(n).parent_transaction_id = 0) THEN
         SELECT rsh.shipment_header_id
         INTO   l_shipment_header_id
         FROM   rcv_shipment_headers rsh
         WHERE  shipment_num = x_cascaded_table(n).shipment_num
         AND    receipt_source_code = 'INTERNAL ORDER';

         SELECT rsl.shipment_line_id
         INTO   l_shipment_line_id
         FROM   rcv_shipment_lines rsl
         WHERE  rsl.shipment_header_id = l_shipment_header_id
         AND    rsl.item_description = x_cascaded_table(n).item_description
         AND    ROWNUM = 1;
      ELSE
         SELECT rt.shipment_header_id,
                rt.shipment_line_id
         INTO   l_shipment_header_id,
                l_shipment_line_id
         FROM   rcv_transactions rt
         WHERE  transaction_id = x_cascaded_table(n).parent_transaction_id;
      END IF;

      SELECT rsl.requisition_line_id,
             rsl.ship_to_location_id,
             rsl.to_subinventory,
             rsl.po_line_location_id,
             rsl.destination_type_code,
             rsl.to_organization_id,
             rsl.item_id,
             rsl.category_id,
             rsl.employee_id
      INTO   l_requisition_line_id,
             l_ship_to_location_id,
             l_subinventory,
             l_po_line_location_id,
             l_destination_type_code,
             l_to_organization_id,
             l_item_id,
             l_category_id,
             l_employee_id
      FROM   rcv_shipment_lines rsl
      WHERE  rsl.shipment_header_id = l_shipment_header_id
      AND    rsl.shipment_line_id = l_shipment_line_id;

      x_cascaded_table(n).requisition_line_id    := NVL(x_cascaded_table(n).requisition_line_id, l_requisition_line_id);
      x_cascaded_table(n).ship_to_location_id    := NVL(x_cascaded_table(n).ship_to_location_id, l_ship_to_location_id);
      --bug 13684997: Do not derive subinventory value when transaction_type in ('ACCEPT', 'REJECT') and MOBILE_TXN = 'Y'
      IF NOT((x_cascaded_table(n).transaction_type IN('ACCEPT', 'REJECT')) AND x_cascaded_table(n).MOBILE_TXN = 'Y') THEN
         x_cascaded_table(n).subinventory           := NVL(x_cascaded_table(n).subinventory, l_subinventory);
      END IF;
      --bug 13684997 end
      x_cascaded_table(n).po_line_location_id    := NVL(x_cascaded_table(n).po_line_location_id, l_po_line_location_id);
      x_cascaded_table(n).destination_type_code  := NVL(x_cascaded_table(n).destination_type_code, l_destination_type_code);
      x_cascaded_table(n).to_organization_id     := NVL(x_cascaded_table(n).to_organization_id, l_to_organization_id);
      x_cascaded_table(n).item_id                := NVL(x_cascaded_table(n).item_id, l_item_id);
      x_cascaded_table(n).category_id            := NVL(x_cascaded_table(n).category_id, l_category_id);
      x_cascaded_table(n).employee_id            := NVL(x_cascaded_table(n).employee_id, l_employee_id);
   END derive_io_shipment_info;

/* Procedure get_deliver_to_person_from_rsl() is added as part of Bug#6375015 fix.
   This procedure  is called from validate_io_rcv_line().
   At this point of time, all the defaulting and derivation would have happened,
   so rcv_shipment_line_id would be available.
   This procedure tries to default the deliver_to_person_id mentioned in the rsl.
   If rcv_shipment_line_id is not known, it will try to get the value based on
   rcv_shipment_header_id only if the rsh has got only one rsl.
 */
    PROCEDURE get_deliver_to_person_from_rsl(
        x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                   IN BINARY_INTEGER
    ) IS
       l_deliver_to_person_id        NUMBER;
       l_rsl_count          NUMBER;
    BEGIN
      --At this point shipment_line_id would haven been defaulted/derived
       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Inside get_deliver_to_person_from_rsl...');
       END IF;
       IF (x_cascaded_table(n).shipment_line_id is not null) THEN
          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Inside rsl is not null..rsl value :'||x_cascaded_table(n).shipment_line_id);
          END IF;

          BEGIN
             select deliver_to_person_id
               into l_deliver_to_person_id
               from rcv_shipment_lines
              where shipment_line_id = x_cascaded_table(n).shipment_line_id;

              x_cascaded_table(n).deliver_to_person_id := l_deliver_to_person_id;
              IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('defaulted deliver_to_person_id as:'||l_deliver_to_person_id);
               END IF;
          EXCEPTION
              WHEN OTHERS then
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Exception occured while getting deliver_to_person_id thru rsl');
                 END IF;
          END;
       ELSIF (x_cascaded_table(n).shipment_header_id is not null) THEN
          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Inside rsh not null..rsh value :'||x_cascaded_table(n).shipment_header_id);
          END IF;

          BEGIN
             select count(shipment_line_id)
               into l_rsl_count
               from rcv_shipment_lines
              where shipment_header_id = x_cascaded_table(n).shipment_header_id;

             IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Inside rsh not null..l_rsl_count:'||l_rsl_count);
             END IF;

             IF l_rsl_count = 1 THEN
                select deliver_to_person_id
                  into l_deliver_to_person_id
                  from rcv_shipment_lines
                 where shipment_header_id = x_cascaded_table(n).shipment_header_id;
                 x_cascaded_table(n).deliver_to_person_id := l_deliver_to_person_id;
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('defaulted deliver_to_person_id as:'||l_deliver_to_person_id);
                 END IF;
             ELSE--l_rsl_count = 1
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('deliver_to_person_id  not defalued as rsh has more than 1 rsl');
                 END IF;
             END IF;--l_rsl_count = 1
          EXCEPTION
              WHEN OTHERS then
                 IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Exception occured while getting deliver_to_person_id thru rsh');
                 END IF;
          END;
       END IF;--(x_cascaded_table(n).shipment_line_id is not null)
    END get_deliver_to_person_from_rsl;

/* Function get_deliver_to_person_from_rt() is added as part of Bug#6375015 fix.
   This function is called from validate_io_rcv_line() and it tries to default
   the deliver_to_person_id mentioned in the parent transaction(i.e from rcv_transactions).
 */
    FUNCTION get_deliver_to_person_from_rt(
        x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                   IN BINARY_INTEGER
    ) RETURN NUMBER IS
       l_parent_deliver_to_person_id NUMBER := null;
    BEGIN
       select deliver_to_person_id
         into l_parent_deliver_to_person_id
         from rcv_transactions
        where transaction_id = x_cascaded_table(n).parent_transaction_id;

        IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Got deliver_to_person_id of parent txn as:'||l_parent_deliver_to_person_id);
        END IF;
        return l_parent_deliver_to_person_id;
    EXCEPTION
       WHEN OTHERS then
          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Exception occured in get_deliver_to_person_from_rt');
          END IF;
          return null;
    END get_deliver_to_person_from_rt;

/* Function get_deliver_to_person_from_rti() is added as part of Bug#6375015 fix.
   This function is called from validate_io_rcv_line() and it tries to default
   the deliver_to_person_id mentioned in the parent transaction(i.e from rcv_transactions_interface).
 */

    FUNCTION get_deliver_to_person_from_rti(
        x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
        n                   IN BINARY_INTEGER
    ) RETURN NUMBER IS
       l_parent_deliver_to_person_id NUMBER := null;
    BEGIN
       select deliver_to_person_id
         into l_parent_deliver_to_person_id
         from rcv_transactions_interface
        where interface_transaction_id = x_cascaded_table(n).parent_transaction_id;

        IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Got deliver_to_person_id of parent txn as:'||l_parent_deliver_to_person_id);
        END IF;
        return l_parent_deliver_to_person_id;
    EXCEPTION
       WHEN OTHERS then
          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Exception occured in get_deliver_to_person_from_rti');
          END IF;
          return null;
    END get_deliver_to_person_from_rti;

END rcv_int_order_pp_pvt;

/
