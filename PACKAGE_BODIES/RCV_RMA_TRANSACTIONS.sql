--------------------------------------------------------
--  DDL for Package Body RCV_RMA_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_RMA_TRANSACTIONS" 
/* $Header: RCVRMATB.pls 120.9.12010000.12 2012/07/12 01:20:12 xiameng ship $*/
AS
   g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on;  -- Bug 9152790: rcv debug enhancement
   x_progress  VARCHAR2(3);
   TYPE t_used_rma_line_amounts is table of number index by binary_integer;
   g_used_rma_line_amounts t_used_rma_line_amounts;

   CURSOR default_rma(
      v_line_id NUMBER
   ) IS
      SELECT oel.line_number oe_order_line_num,
             msi.description item_description,
             oel.sold_to_org_id customer_id,
             oel.ship_to_org_id customer_site_id,
             oel.ship_to_org_id from_organization_id,
             oel.ship_from_org_id to_organization_id,
             oel.unit_selling_price unit_price,
             oeh.transactional_curr_code currency_code,
             oeh.conversion_type_code currency_conversion_type,
             oeh.conversion_rate_date currency_conversion_date,
             oeh.conversion_rate currency_conversion_rate,
             oel.subinventory subinventory,
             oel.ship_from_org_id deliver_to_location_id
      FROM   oe_order_headers oeh,
             oe_order_lines oel,
             mtl_system_items msi
      WHERE  oel.line_id = v_line_id
      AND    oel.header_id = oeh.header_id
      AND    oel.booked_flag = 'Y'
      AND    oel.ordered_quantity > NVL(oel.shipped_quantity, 0)
      AND    oeh.open_flag = 'Y'
      AND    oel.line_category_code = 'RETURN'
      AND    oel.open_flag = 'Y'
      AND    oel.flow_status_code = 'AWAITING_RETURN'
      AND    msi.organization_id = oe_sys_parameters.VALUE('MASTER_ORGANIZATION_ID', oel.org_id)
      AND    msi.inventory_item_id = oel.inventory_item_id;

   -- specs for package level procedures
   -- helpers for derive_rma_line
   PROCEDURE derive_order_header_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_order_line_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_document_line_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_customer_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_transit_org_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_uom_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_org_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE derive_deliver_to_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE derive_auto_transact_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE explode_line_quantity(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   );

-- helpers for default_rma_line
   PROCEDURE default_source_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_id      IN            rcv_headers_interface.header_interface_id%TYPE
   );

   PROCEDURE default_destination_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE default_item_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE default_transaction_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE default_processing_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE default_from_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_from_rma(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE default_customer_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_customer_site_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_from_org_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_ship_to_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_currency_info_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_shipment_num_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_freight_carrier_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_bill_of_lading_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_packing_slip_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_ship_date_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_receipt_date_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_num_containers_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_waybill_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_tax_name_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   );

   PROCEDURE default_routing_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

-- helpers for validate_rma_line
   PROCEDURE validate_txn_date(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_qty_invoiced(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_uom_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_item_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_freight_carrier_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_destination_type(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_tax_name(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_country_of_origin(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_ref_integrity(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   );

   PROCEDURE validate_uom(
      x_uom_record IN OUT NOCOPY rcv_shipment_line_sv.quantity_shipped_record_type
   );

   PROCEDURE validate_item(
      x_item_id_record     IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type,
      x_auto_transact_code IN            rcv_transactions_interface.auto_transact_code%TYPE
   );

   -- main public procedures
   PROCEDURE derive_rma_line(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter derive_rma_line');
         asn_debug.put_line('Current pointer in actual table ' || TO_CHAR(n));
         asn_debug.put_line('Current error status ' || x_cascaded_table(n).error_status);
         asn_debug.put_line('To Organization Id ' || NVL(TO_CHAR(x_cascaded_table(n).to_organization_id), 'NULL'));
         asn_debug.put_line('To Organization Code ' || NVL(x_cascaded_table(n).to_organization_code, 'NULL'));
      END IF;

      x_progress  := '000';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      -- derive_location_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_location_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_ship_to_location_info(x_cascaded_table, n);
      x_progress  := '010';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      --derive_org_info(x_cascaded_table, n, x_header_record);
      rcv_roi_transaction.derive_ship_to_org_info(x_cascaded_table,
                                                  n,
                                                  x_header_record
                                                 );
      x_progress  := '020';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_customer_info(x_cascaded_table, n);
      x_progress  := '030';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_order_header_info(x_cascaded_table, n);
      x_progress  := '040';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      -- derive_item_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_item_info(x_cascaded_table, n);
      x_progress  := '050';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_order_line_info(x_cascaded_table, n);
      x_progress  := '060';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_document_line_info(x_cascaded_table, n);
      x_progress  := '070';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_uom_info(x_cascaded_table, n);
      x_progress  := '080';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_transit_org_info(x_cascaded_table, n);
      x_progress  := '090';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      -- derive_routing_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_routing_header_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_routing_step_info(x_cascaded_table, n);
      x_progress  := '100';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_deliver_to_info(x_cascaded_table, n);
      x_progress  := '120';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      -- derive_locator_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_to_locator_id(x_cascaded_table, n);
      x_progress  := '130';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      -- derive_reason_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_reason_info(x_cascaded_table, n);
      x_progress  := '140';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      derive_auto_transact_info(x_cascaded_table, n);
      x_progress  := '150';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
      explode_line_quantity(x_cascaded_table,
                            n,
                            temp_cascaded_table,
                            x_header_record
                           );
      x_progress  := '170';
      asn_debug.put_line('RMA derive ' || x_progress || ' error status: ' || NVL(x_cascaded_table(n).error_status, 'NULL'));
   END derive_rma_line;

   PROCEDURE derive_rma_trans_del(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('enter derive_cust_trans_del ');
      END IF;

      /* Derive the to_org_id */
      derive_org_info(x_cascaded_table,
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
            asn_debug.put_line('uom_code not derived as unit_of_measure is null');
         END IF;
      END IF;

      x_progress                              := '026';

      /* Locator info derivation is done for the Receiving locators FPJ
       * project. Need to verify this with karun to see whether this is
       * needed for Transfer also.
      */
      IF (x_cascaded_table(n).transaction_type = 'TRANSFER') THEN
         rcv_roi_transaction.derive_location_info(x_cascaded_table, n);
         rcv_roi_transaction.derive_from_locator_id(x_cascaded_table, n); -- WMS Change
         rcv_roi_transaction.derive_to_locator_id(x_cascaded_table, n); -- WMS Change
      END IF;

      x_progress                              := '091';
      -- derive_reason_info(x_cascaded_table, n);
      rcv_roi_transaction.derive_reason_info(x_cascaded_table, n);
      /* Auto_transact_code is null for all these transaction types */
      x_cascaded_table(n).auto_transact_code  := NULL;
      /* quantity derivation is the same as interorg transfers */
      rcv_int_org_transfer.derive_trans_del_line_quantity(x_cascaded_table,
                                                          n,
                                                          temp_cascaded_table
                                                         );
   END derive_rma_trans_del;

   PROCEDURE derive_rma_correction_line(
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
      derive_org_info(x_cascaded_table,
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
      /* Quantity calculation is the same as for interorg transfer */
      rcv_int_org_transfer.derive_int_org_cor_line_qty(x_cascaded_table,
                                                       n,
                                                       temp_cascaded_table
                                                      );
   END derive_rma_correction_line;

   PROCEDURE default_rma_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_id      IN            rcv_headers_interface.header_interface_id%TYPE,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
      x_locator_control      NUMBER;
      x_default_subinventory VARCHAR2(10);
      x_default_locator_id   NUMBER;
      x_success              BOOLEAN;
      x_tax_name             VARCHAR2(50); -- Bug 6331613
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('In default_rma_line');
      END IF;

      x_progress                                  := '000';
      -- set default_rma values
      x_cascaded_table(n).header_interface_id     := x_header_id;
      x_cascaded_table(n).inspection_status_code  := 'NOT INSPECTED';
      x_cascaded_table(n).interface_source_code   := 'RCV';
      -- default columns based on the rma
      default_from_rma(x_cascaded_table, n);
      default_source_info(x_cascaded_table,
                          n,
                          x_header_id
                         );
      default_destination_info(x_cascaded_table, n);
      default_transaction_info(x_cascaded_table, n);
      default_processing_info(x_cascaded_table, n);
      default_item_info(x_cascaded_table, n);
      default_routing_info(x_cascaded_table, n);
      -- default columns based on the header
      default_from_header(x_cascaded_table,
                          n,
                          x_header_record
                         );
      /** bug 3609664, default subinventory and locator info.
       *  This is needed for direct deliver since rcv_roi_transaction.
       *  default_vendor_tran_del() will not be called.
       */
      IF x_cascaded_table(n).auto_transact_code = 'DELIVER' THEN
          rcv_roi_transaction.default_to_subloc_info(x_cascaded_table, n);
      END IF;

      x_progress                                  := '010';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit default_rma_line');
      END IF;
   END default_rma_line;

/*===========================================================================

  PROCEDURE NAME:   validate_rma_line()

===========================================================================*/
   PROCEDURE validate_rma_line(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Enter validate_rma_line');
      END IF;

      x_progress  := '000';

      -- Bug 3219200: don't require ship_to_location_id for direct delivery
      IF     x_cascaded_table(n).transaction_type = 'RECEIVE'
         AND x_cascaded_table(n).auto_transact_code <> 'DELIVER' THEN
         rcv_roi_transaction.validate_ship_to_loc(x_cascaded_table, n);
      END IF;

      validate_txn_date(x_cascaded_table, n);
      validate_qty_invoiced(x_cascaded_table, n);
      validate_uom_info(x_cascaded_table, n);
      validate_item_info(x_cascaded_table, n);
      validate_freight_carrier_info(x_cascaded_table, n);
      rcv_roi_transaction.validate_subinventory(x_cascaded_table, n);
      rcv_roi_transaction.validate_locator(x_cascaded_table, n); -- Bug 10021661
      validate_destination_type(x_cascaded_table, n);
      rcv_roi_transaction.validate_routing_record(x_cascaded_table, n);
      validate_tax_name(x_cascaded_table, n);
      validate_country_of_origin(x_cascaded_table, n);
      validate_ref_integrity(x_cascaded_table, n);
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
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('validate_rma_line', x_progress);
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('I have hit an exception');
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('Exit validate_rma_line');
         END IF;
   END validate_rma_line;

/**
 * Helper procedures for derive_rma_lines
 */
   PROCEDURE derive_uom_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      -- primary uom
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).item_id IS NOT NULL
         AND x_cascaded_table(n).primary_unit_of_measure IS NULL THEN
         BEGIN
            /* BUG 608353 */
        /*Commenting defaulting of use_mtl_lot and use_mtl_serial
               BUG 4735484
        */
            SELECT primary_unit_of_measure
                   --NVL(x_cascaded_table(n).use_mtl_lot, lot_control_code),
                   --NVL(x_cascaded_table(n).use_mtl_serial, serial_number_control_code)
            INTO   x_cascaded_table(n).primary_unit_of_measure
                   --x_cascaded_table(n).use_mtl_lot,
                   --x_cascaded_table(n).use_mtl_serial
            FROM   mtl_system_items
            WHERE  mtl_system_items.inventory_item_id = x_cascaded_table(n).item_id
            AND    mtl_system_items.organization_id = x_cascaded_table(n).to_organization_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Primary UOM: ' || x_cascaded_table(n).primary_unit_of_measure);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_cascaded_table(n).error_status   := 'W';
               x_cascaded_table(n).error_message  := 'Need an error message';

               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Primary UOM error');
               END IF;
         END;
      END IF;

      -- uom_code
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
            asn_debug.put_line('uom_code not derived as unit_of_measure is null');
         END IF;
      END IF;
   END derive_uom_info;

   PROCEDURE derive_order_header_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      -- bug 3223993 - derive oe_order_num and document num from each other
      IF (x_cascaded_table(n).oe_order_num IS NOT NULL) THEN
         x_cascaded_table(n).document_num  := x_cascaded_table(n).oe_order_num;
      ELSIF(x_cascaded_table(n).document_num IS NOT NULL) THEN
         x_cascaded_table(n).oe_order_num  := x_cascaded_table(n).document_num;
      END IF;

      -- We need order num and org_id since we can receive RMAs created in other OU
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).oe_order_header_id IS NULL
         AND x_cascaded_table(n).oe_order_num IS NOT NULL
         AND x_cascaded_table(n).to_organization_id IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Deriving order_header_id');
         END IF;

         -- bug 3224001: change query to get the correct header for the given order_num

         SELECT DISTINCT oeh.header_id
         INTO            x_cascaded_table(n).oe_order_header_id
         FROM            oe_order_headers_all oeh,
                         oe_order_lines_all oel,
                         oe_transaction_types_all oett
         WHERE           oeh.order_number = x_cascaded_table(n).oe_order_num
         AND             oeh.header_id = oel.header_id
         AND             oel.line_category_code = 'RETURN'
         AND             oel.line_type_id = oett.transaction_type_id
         AND             oett.order_category_code IN('MIXED', 'RETURN')
         AND             oel.open_flag = 'Y'
         AND             oeh.booked_flag = 'Y'
         AND             (   (    oeh.ship_from_org_id IS NOT NULL
                              AND oeh.ship_from_org_id = x_cascaded_table(n).to_organization_id)
                          OR EXISTS(SELECT 1
                                    FROM   oe_order_lines_all oela
                                    WHERE  oela.header_id = oeh.header_id
                                    AND    oela.ship_from_org_id = x_cascaded_table(n).to_organization_id));

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derived oe_order_header_id ' || x_cascaded_table(n).oe_order_header_id);
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Cannot derive order_header_id - no data found');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_ORDER_HEADER_ID', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('NUMBER', x_cascaded_table(n).oe_order_num);
         rcv_error_pkg.log_interface_error('OE_ORDER_NUM', FALSE);
      WHEN TOO_MANY_ROWS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Cannot derive order_header_id - too many rows');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_ORDER_HEADER_ID', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('NUMBER', x_cascaded_table(n).oe_order_num);
         rcv_error_pkg.log_interface_error('OE_ORDER_NUM', FALSE);
      WHEN OTHERS THEN
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('derive_order_header_info', '000');
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
         rcv_error_pkg.log_interface_error('OE_ORDER_NUM', FALSE);
   END derive_order_header_info;

   PROCEDURE derive_order_line_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      my_line_id NUMBER;
      my_item_id NUMBER;
   BEGIN
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).oe_order_line_id IS NULL
         AND x_cascaded_table(n).oe_order_header_id IS NOT NULL
         AND x_cascaded_table(n).document_line_num IS NOT NULL THEN
         SELECT line_id,
                inventory_item_id
         INTO   my_line_id,
                my_item_id
         FROM   oe_order_lines_all
         WHERE  header_id = x_cascaded_table(n).oe_order_header_id
         AND    line_number = x_cascaded_table(n).document_line_num
         -- pjiang: extra filter for oe line split
         AND    flow_status_code = 'AWAITING_RETURN';

         x_cascaded_table(n).oe_order_line_id  := my_line_id;

         IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Derived oe_order_line_id ' || TO_CHAR(x_cascaded_table(n).oe_order_line_id));
         END IF;

         IF x_cascaded_table(n).item_id IS NULL THEN
            x_cascaded_table(n).item_id  := my_item_id;

            IF g_asn_debug = 'Y' THEN
               asn_debug.put_line('Derived item_id ' || TO_CHAR(x_cascaded_table(n).item_id));
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_ORDER_HEADER_ID', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('NUMBER', x_cascaded_table(n).oe_order_num);
         rcv_error_pkg.log_interface_error('OE_ORDER_NUM', FALSE);
      WHEN OTHERS THEN
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('derive_order_header_info', '000');
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
         rcv_error_pkg.log_interface_error('OE_ORDER_NUM', FALSE);
   END derive_order_line_info;

   PROCEDURE derive_document_line_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).document_line_num IS NULL
         AND x_cascaded_table(n).oe_order_line_id IS NOT NULL
         AND x_cascaded_table(n).oe_order_header_id IS NOT NULL THEN
         SELECT line_number
         INTO   x_cascaded_table(n).document_line_num
         FROM   oe_order_lines_all
         WHERE  line_id = x_cascaded_table(n).oe_order_line_id;
      END IF;
   END derive_document_line_info;

   PROCEDURE derive_customer_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      -- derive customer_id from customer_account_number
      IF     x_cascaded_table(n).customer_id IS NULL
         AND x_cascaded_table(n).customer_account_number IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Deriving customer_id from customer_account_number');
         END IF;

         SELECT acct.cust_account_id
         INTO   x_cascaded_table(n).customer_id
         FROM   hz_cust_accounts acct
         WHERE  acct.account_number = x_cascaded_table(n).customer_account_number;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derived customer_id ' || x_cascaded_table(n).customer_id);
         END IF;
      END IF;

      -- derive customer_id from customer_party_name if name is unique
      IF     x_cascaded_table(n).customer_id IS NULL
         AND x_cascaded_table(n).customer_party_name IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Deriving customer_id from customer_account_number');
         END IF;

         BEGIN
            SELECT acct.cust_account_id
            INTO   x_cascaded_table(n).customer_id
            FROM   hz_parties party,
                   hz_cust_accounts acct
            WHERE  acct.party_id = party.party_id
            AND    party.party_name = x_cascaded_table(n).customer_party_name;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               NULL;
         END;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derived customer_id ' || x_cascaded_table(n).customer_id);
         END IF;
      END IF;

      -- derive customer_site_id from from_organization_id
      IF     x_cascaded_table(n).customer_site_id IS NULL
         AND x_cascaded_table(n).from_organization_id IS NOT NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Deriving customer_site_id from from_organization_id');
         END IF;

         x_cascaded_table(n).customer_account_number  := x_cascaded_table(n).from_organization_id;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derived customer_site_id ' || x_cascaded_table(n).customer_site_id);
         END IF;
      END IF;
   END derive_customer_info;

   PROCEDURE derive_org_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
      ship_to_org_record rcv_shipment_object_sv.organization_id_record_type;
   BEGIN
      -- derive from location_info
      IF     x_cascaded_table(n).to_organization_id IS NULL
         AND x_cascaded_table(n).to_organization_code IS NULL
         AND x_cascaded_table(n).error_status IN('S', 'W') THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Attempting to derive the org from the ship to location');
         END IF;

         IF (x_cascaded_table(n).ship_to_location_id IS NOT NULL) THEN
            SELECT MAX(org.organization_id)
            INTO   x_cascaded_table(n).to_organization_code
            FROM   hr_locations hl,
                   HR_ALL_ORGANIZATION_UNITS org --Bug 5217526. Earlier used org_organization_definitions
            WHERE  x_cascaded_table(n).ship_to_location_id = hl.location_id
            AND    hl.inventory_organization_id = org.organization_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Set Org using location id ');
            END IF;
         ELSIF(x_cascaded_table(n).ship_to_location_code IS NOT NULL) THEN
            SELECT MAX(org.organization_id)
            INTO   x_cascaded_table(n).to_organization_code
            FROM   hr_locations hl,
                   HR_ALL_ORGANIZATION_UNITS org --Bug 5217526. Earlier used org_organization_definitions
            WHERE  x_cascaded_table(n).ship_to_location_code = hl.location_code
            AND    hl.inventory_organization_id = org.organization_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Set Org using location code ');
            END IF;
         END IF;
      END IF;

      -- derive from to_organization_code
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).to_organization_id IS NULL
         AND x_cascaded_table(n).to_organization_code IS NOT NULL THEN
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

      -- couldn't derive, default from header instead
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).to_organization_id IS NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Will default org id from header ' || x_header_record.header_record.ship_to_organization_id);
         END IF;

         x_cascaded_table(n).to_organization_id  := x_header_record.header_record.ship_to_organization_id;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Derived to_organization_id ' || x_cascaded_table(n).to_organization_id);
      END IF;
   END derive_org_info;

   PROCEDURE derive_transit_org_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      transit_org_record rcv_shipment_object_sv.organization_id_record_type;
   BEGIN
      IF     (x_cascaded_table(n).error_status IN('S', 'W'))
         AND (    x_cascaded_table(n).intransit_owning_org_id IS NULL
              AND x_cascaded_table(n).intransit_owning_org_code IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
         END IF;

         transit_org_record.organization_code           := x_cascaded_table(n).intransit_owning_org_code;
         transit_org_record.organization_id             := x_cascaded_table(n).intransit_owning_org_id;
         transit_org_record.error_record.error_status   := 'S';
         transit_org_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Intransit Owning Org Record Procedure');
         END IF;

         po_orgs_sv.derive_org_info(transit_org_record);

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Intransit organization code ' || transit_org_record.organization_code);
            asn_debug.put_line('Intransit organization id ' || TO_CHAR(transit_org_record.organization_id));
            asn_debug.put_line('Intransit error status ' || transit_org_record.error_record.error_status);
         END IF;

         x_cascaded_table(n).intransit_owning_org_code  := transit_org_record.organization_code;
         x_cascaded_table(n).intransit_owning_org_id    := transit_org_record.organization_id;
         x_cascaded_table(n).error_status               := transit_org_record.error_record.error_status;
         x_cascaded_table(n).error_message              := transit_org_record.error_record.error_message;
      END IF;
   END derive_transit_org_info;

   PROCEDURE derive_deliver_to_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      employee_id_record rcv_shipment_object_sv.employee_id_record_type;
      location_id_record rcv_shipment_object_sv.location_id_record_type;
   BEGIN
      -- deliver_to_person_id
      IF     (x_cascaded_table(n).error_status IN('S', 'W'))
         AND (    x_cascaded_table(n).deliver_to_person_id IS NULL
              AND x_cascaded_table(n).deliver_to_person_name IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
         END IF;

         employee_id_record.employee_name               := x_cascaded_table(n).deliver_to_person_name;
         employee_id_record.employee_id                 := x_cascaded_table(n).deliver_to_person_id;
         employee_id_record.error_record.error_status   := 'S';
         employee_id_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In Derive deliver_to_person_id Information');
         END IF;

         po_employees_sv.derive_employee_info(employee_id_record);

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Employee name ' || employee_id_record.employee_name);
            asn_debug.put_line('Employee id ' || TO_CHAR(employee_id_record.employee_id));
            asn_debug.put_line('Employee error status ' || employee_id_record.error_record.error_status);
         END IF;

         x_cascaded_table(n).deliver_to_person_name     := employee_id_record.employee_name;
         x_cascaded_table(n).deliver_to_person_id       := employee_id_record.employee_id;
         x_cascaded_table(n).error_status               := employee_id_record.error_record.error_status;
         x_cascaded_table(n).error_message              := employee_id_record.error_record.error_message;
      END IF;

      -- deliver_to_location
      IF     (x_cascaded_table(n).error_status IN('S', 'W'))
         AND (    x_cascaded_table(n).deliver_to_location_id IS NULL
              AND x_cascaded_table(n).deliver_to_location_code IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
         END IF;

         location_id_record.location_code               := x_cascaded_table(n).deliver_to_location_code;
         location_id_record.error_record.error_status   := 'S';
         location_id_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Derive deliver_to_location_id');
         END IF;

         rcv_transactions_interface_sv.get_location_id(location_id_record);
         x_cascaded_table(n).deliver_to_location_id     := location_id_record.location_id;
         x_cascaded_table(n).error_status               := location_id_record.error_record.error_status;
         x_cascaded_table(n).error_message              := location_id_record.error_record.error_message;
      END IF;
   END derive_deliver_to_info;

   PROCEDURE derive_auto_transact_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      IF     (x_cascaded_table(n).error_status IN('S', 'W'))
         AND x_cascaded_table(n).auto_transact_code IS NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('X_progress ' || x_progress);
            asn_debug.put_line('Setting auto_transact_code to transaction_type ' || x_cascaded_table(n).transaction_type);
         END IF;

         x_cascaded_table(n).auto_transact_code  := x_cascaded_table(n).transaction_type;
      END IF;
   END derive_auto_transact_info;

   PROCEDURE explode_line_quantity(
      x_cascaded_table    IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                   IN OUT NOCOPY BINARY_INTEGER,
      temp_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record     IN            rcv_roi_preprocessor.header_rec_type
   ) IS
      -- declare the line cursor
    /* Bug 4740567
     * Include oe order line_id also in addition to line_num since
     * when line_num is null and the rma lines have same rti id,
     * the cursor was fetching the first line_id itself and overriding
     * the value provided by the mobile txn.
    */
      CURSOR rma_lines(
         v_header_id        NUMBER,
     v_line_id          NUMBER, --bug 4740567
         v_item_id          NUMBER,
         v_rma_line_num     NUMBER,
         v_ship_to_org_id   NUMBER, -- rcv.to_organization_id == oel.ship_from_org_id
         v_customer_item_id NUMBER
      ) IS
         SELECT   NVL(oel.ship_to_org_id, oeh.ship_to_org_id) customer_site_id,
                  NVL(oel.ship_from_org_id, oeh.ship_from_org_id) to_organization_id,
                  NVL(oel.sold_to_org_id, oeh.sold_to_org_id) customer_id,
                  NVL(oel.promise_date, oel.request_date) expected_receipt_date,
                  oel.ordered_quantity ordered_qty,
                  'N' enforce_ship_to_location_code,
                  oel.deliver_to_contact_id deliver_to_person_id,
                  oel.deliver_to_org_id deliver_to_location_id,
                  oel.header_id oe_order_header_id,
                  oel.line_id oe_order_line_id,
                  oeh.order_number oe_order_num,
                  oel.line_number oe_order_line_num,
                  oel.inventory_item_id item_id,
                  mum.unit_of_measure,
                  msi.description description
         FROM     oe_order_headers_all oeh,
                  oe_order_lines_all oel,
                  oe_transaction_types_all olt,
                  oe_transaction_types_tl t,
                  mtl_units_of_measure_tl mum,
                  mtl_system_items msi
         WHERE    oeh.header_id = v_header_id
         AND      oeh.header_id = oel.header_id
     AND      oel.line_id = NVL(v_line_id, oel.line_id)-- bug 4740567
         AND      oel.line_number = NVL(v_rma_line_num, oel.line_number)
         AND      oeh.open_flag = 'Y'
         AND      oel.line_category_code = 'RETURN'
         AND      oel.open_flag = 'Y'
         AND      oel.inventory_item_id = NVL(v_item_id, oel.inventory_item_id)
         AND      oel.ship_from_org_id = NVL(v_ship_to_org_id, oel.ship_from_org_id)
         AND      oel.line_type_id = olt.transaction_type_id
         AND      olt.transaction_type_code = 'LINE'
         AND      olt.transaction_type_id = t.transaction_type_id
         AND      t.LANGUAGE = USERENV('LANG')
         AND      msi.organization_id = oe_sys_parameters.VALUE('MASTER_ORGANIZATION_ID', oel.org_id)
         AND      msi.inventory_item_id = oel.inventory_item_id
         AND      (   oel.ordered_item_id = NVL(v_customer_item_id, oel.ordered_item_id)
                   OR oel.ordered_item_id IS NULL)
         AND      oel.booked_flag = 'Y'
         AND      oel.ordered_quantity > NVL(oel.shipped_quantity, 0)
         AND      oel.flow_status_code = 'AWAITING_RETURN'
         AND      oel.order_quantity_uom = mum.uom_code
         AND      mum.LANGUAGE = USERENV('LANG')
         ORDER BY expected_receipt_date;

      -- declare variables
      x_rma_line_record         rma_lines%ROWTYPE;
      txn_remaining_qty         NUMBER                                              := 0;
      txn_remaining_qty_rma_uom NUMBER                                              := 0;
      rma_line_qty              NUMBER                                              := 0;
      allocate_qty              NUMBER                                              := 0;
      rma_lines_fetched         NUMBER                                              := 0;
      transaction_ok            BOOLEAN                                             := FALSE;
      high_range_date           DATE;
      low_range_date            DATE;
      valid_date                BOOLEAN;
      insert_into_table         BOOLEAN                                             := FALSE;
      tax_amount_factor         NUMBER;
      rma_txn_uom_qty           NUMBER;
      rma_primary_uom_qty       NUMBER;
      already_allocated_qty     NUMBER                                              := 0;
      x_item_id                 NUMBER;
      x_routing_id              NUMBER;
      x_rcv_date_exception      VARCHAR2(20);
      x_allow_substitutes       VARCHAR2(1)                                         := 'N';
      x_qty_rcv_tolerance       NUMBER;
      x_qty_rcv_exception       VARCHAR2(80);
      x_days_early_receipt      NUMBER;
      x_days_late_receipt       NUMBER;
      x_enforce_ship_to_loc     VARCHAR2(25)                                        := 'N';
      x_line_category_code      VARCHAR2(30);
      x_customer_item_num       rcv_transactions_interface.customer_item_num%TYPE;
      x_ship_to_organization_id NUMBER;
      x_ship_to_location_id     NUMBER;
      x_full_name               VARCHAR2(240);
      x_sob_id                  NUMBER;
      x_header_open_flag        VARCHAR2(1);
      x_line_open_flag          VARCHAR2(1);
      x_oe_msg_count            NUMBER;
      x_oe_msg_data             VARCHAR2(240);
      x_under_return_tolerance  NUMBER;
      x_oe_return_status        VARCHAR2(30);
      x_shipped_quantity        NUMBER;
      x_booked_flag             VARCHAR2(1);
      x_flow_status_code        VARCHAR2(30);
      x_ordered_quantity        NUMBER;
      rma_uom_qty               NUMBER;
      primary_uom_qty           NUMBER;
      rma_receipt_uom_qty       NUMBER;
      defined                   BOOLEAN;
   BEGIN
      --check line quanity > 0
      x_progress         := '097';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      IF    x_cascaded_table(n).error_status NOT IN('S', 'W')
         OR x_cascaded_table(n).quantity <= 0 THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Quantity is <= zero. Cascade will fail');
         END IF;

         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
         rcv_error_pkg.set_token('ITEM', x_cascaded_table(n).item_num);
         rcv_error_pkg.log_interface_error('ITEM_NUM', FALSE);
         RETURN;
      END IF; --} end qty > 0 check

      /**
       * The following steps will create a set of rows linking the line record with
       * its corresponding shipment rows until the quantity value from
       * the rma is consumed.  (Cascade)
       */
      x_progress         := '098';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('X_progress ' || x_progress);
      END IF;

      -- check order info
      IF (   x_cascaded_table(n).oe_order_header_id IS NULL
          OR (    x_cascaded_table(n).item_id IS NULL
              AND x_cascaded_table(n).customer_item_num IS NULL
              AND x_cascaded_table(n).oe_order_line_id IS NULL
              AND x_cascaded_table(n).document_line_num IS NULL)) THEN --{
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No oe_order_header_id/item_id ');
            asn_debug.put_line('Status = ' || x_cascaded_table(n).error_status);
         END IF;

         -- only set error if not already set
         IF x_cascaded_table(n).error_status IN('S', 'W', 'F') THEN --{
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ITEM_NO_SHIP_QTY', x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_error('ITEM_NUM', FALSE);
         END IF; --}

         RETURN;
      END IF;

      -- }

      -- Assign shipped quantity to remaining quantity
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Assign txn quantity to remaining quantity');
      END IF;

      txn_remaining_qty  := x_cascaded_table(n).quantity;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Have assigned the quantity');
      END IF;

      -- Calculate tax_amount_factor for calculating tax_amount for
      -- each cascaded line
      tax_amount_factor  := NVL(x_cascaded_table(n).tax_amount, 0) / txn_remaining_qty;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Tax Factor ' || TO_CHAR(tax_amount_factor));
         asn_debug.put_line('Txn Quantity : ' || TO_CHAR(txn_remaining_qty));
         asn_debug.put_line('Before starting Cascade');
      END IF;

      -- make sure the temp table is clean before we start using it
      temp_cascaded_table.DELETE;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Executing RMA Lines cursor with:');
         asn_debug.put_line('oe_order_header_id: ' || x_cascaded_table(n).oe_order_header_id);
         asn_debug.put_line('item_id: ' || x_cascaded_table(n).item_id);
         asn_debug.put_line('oe_order_line_num: ' || x_cascaded_table(n).oe_order_line_num);
         asn_debug.put_line('to_organization_id: ' || x_cascaded_table(n).to_organization_id);
         asn_debug.put_line('customer_item_num: ' || x_cascaded_table(n).customer_item_num);
      END IF;

      FOR x_rma_line_record IN rma_lines(x_cascaded_table(n).oe_order_header_id,
                         x_cascaded_table(n).oe_order_line_id, --bug 4740567
                                         x_cascaded_table(n).item_id,
                                         x_cascaded_table(n).oe_order_line_num,
                                         x_cascaded_table(n).to_organization_id,
                                         x_cascaded_table(n).customer_item_id
                                        ) LOOP   --{
                                               -- preserve a count to use after cursor is closed
         rma_lines_fetched          := rma_lines%ROWCOUNT;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('RMA Lines fetched ' || TO_CHAR(rma_lines_fetched));
            asn_debug.put_line('Remaining Quantity ' || TO_CHAR(txn_remaining_qty));
            asn_debug.put_line('Fetched order header id ' || x_rma_line_record.oe_order_header_id);
            asn_debug.put_line('Fetched order line id ' || x_rma_line_record.oe_order_line_id);
            asn_debug.put_line('Fetched order number ' || x_rma_line_record.oe_order_num);
         END IF;

         -- done allocating transaction quantity
         IF txn_remaining_qty <= 0 THEN
            asn_debug.put_line('Done allocating transaction quantity');
            EXIT;
         END IF;

         -- maintain a dense table
         IF temp_cascaded_table.COUNT = 0 THEN
            -- copy txn from main table to temp table
            temp_cascaded_table(temp_cascaded_table.COUNT + 1)  := x_cascaded_table(n);
         ELSE
            -- copy from previous row
            temp_cascaded_table(temp_cascaded_table.COUNT + 1)  := temp_cascaded_table(temp_cascaded_table.LAST);
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Count in temp_cascade_table : ' || TO_CHAR(temp_cascaded_table.COUNT));
            asn_debug.put_line('Cursor record ' || TO_CHAR(rma_lines%ROWCOUNT));
            asn_debug.put_line('Check date tolerance');
         END IF;

         -- default to successful matching to current line
         insert_into_table          := TRUE;
         -- check for date tolerance
         -- Call rcv_core_s.get_receiving_controls to get the values of days early, days late receipt values
         rcv_core_s.get_receiving_controls(NULL,
                                           x_rma_line_record.item_id,
                                           NULL,
                                           x_rma_line_record.to_organization_id,
                                           x_enforce_ship_to_loc,
                                           x_allow_substitutes,
                                           x_routing_id,
                                           x_qty_rcv_tolerance,
                                           x_qty_rcv_exception,
                                           x_days_early_receipt,
                                           x_days_late_receipt,
                                           x_rcv_date_exception
                                          );
         valid_date                 := rcv_oe_rma_receipts_sv.rma_val_receipt_date_tolerance(x_rma_line_record.oe_order_header_id,
                                                                                             x_rma_line_record.oe_order_line_id,
                                                                                             NVL(temp_cascaded_table(1).expected_receipt_date, x_header_record.header_record.expected_receipt_date)
                                                                                            );

         /* bug 1060261 - added error message to be shown when the expected date is outside tolerance range */
         IF (    x_rcv_date_exception = 'REJECT'
             AND NOT valid_date) THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ASN_DATE_OUT_TOL', x_cascaded_table(n).error_message);
            rcv_error_pkg.set_token('DELIVERY DATE', NVL(temp_cascaded_table(1).expected_receipt_date, x_header_record.header_record.expected_receipt_date));
            rcv_error_pkg.log_interface_error('DOCUMENT_NUM', FALSE);
            insert_into_table                 := FALSE;
         END IF; --}

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Days exception Code ' || NVL(x_rcv_date_exception, 'NONE'));
         END IF;

         /*
         ** Get the available quantity for the line
         ** that is available for allocation by this interface transaction
         */
         rma_line_qty               := x_rma_line_record.ordered_qty;

         /* If there are other rows in rti before for this line id then we need to reduce
          * the available qty for this line to be less by that qty */
         IF insert_into_table THEN
            already_allocated_qty  := 0;

            /* bug 4505906, this looks like it should work, EXCEPT that the cascaded table applies to
               only the current RTI row, not the previous RTI rows. major failure!
               So the fix is to keep track of the used rows in this session with a binary indexed table
            FOR i IN 1 ..(n - 1) LOOP
               IF x_cascaded_table(i).oe_order_line_id = x_rma_line_record.oe_order_line_id THEN
                  already_allocated_qty  := already_allocated_qty + x_cascaded_table(i).source_doc_quantity;
               END IF;
            END LOOP;
            */

            --Bug 8494868 When oe_line_id crossed 2^31 the pl/sql table should not throw any exception.
             IF g_used_rma_line_amounts.exists(mod(x_rma_line_record.oe_order_line_id,2147483648)) THEN
               already_allocated_qty := g_used_rma_line_amounts(mod(x_rma_line_record.oe_order_line_id,2147483648));
               asn_debug.put_line('amount '||already_allocated_qty||' already allocated for order line '||x_rma_line_record.oe_order_line_id);
            END IF;

         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Available Quantity ' || TO_CHAR(rma_line_qty));
         END IF;

         -- if qty has already been allocated then reduce available and tolerable
         -- qty by the allocated amount
         IF NVL(already_allocated_qty, 0) > 0 THEN --{
            rma_line_qty  := rma_line_qty - already_allocated_qty;

            IF rma_line_qty < 0 THEN
               rma_line_qty  := 0;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Have some allocated quantity. Will reduce qty');
               asn_debug.put_line('Allocated Qty ' || TO_CHAR(already_allocated_qty));
               asn_debug.put_line('After reducing by allocated qty');
               asn_debug.put_line('Available Quantity ' || TO_CHAR(rma_line_qty));
            END IF;
         END IF;

         --}

         -- if this line has no more quantity available to allocate, skip to the next one
         insert_into_table          :=     insert_into_table
                                       AND (rma_line_qty > 0);
         -- We can use the first record since the item_id and uom are not going to change
         -- Check that we can convert between ASN-> PO  uom
         --                                   PO -> ASN uom
         --                                   PO -> PRIMARY uom
         -- If any of the conversions fail then we cannot use that record
         txn_remaining_qty_rma_uom  := 0; -- initialize
         rma_uom_qty                := 0; -- initialize
         primary_uom_qty            := 0; -- initialize

         IF insert_into_table THEN
            txn_remaining_qty_rma_uom  := rcv_transactions_interface_sv.convert_into_correct_qty(txn_remaining_qty,
                                                                                                 temp_cascaded_table(1).unit_of_measure,
                                                                                                 temp_cascaded_table(1).item_id,
                                                                                                 x_rma_line_record.unit_of_measure
                                                                                                );
            -- using arbit qty for RMA->Receipt UOM, RMA->Primary UOM conversion as this is just a check
            rma_receipt_uom_qty        := rcv_transactions_interface_sv.convert_into_correct_qty(1000,
                                                                                                 x_rma_line_record.unit_of_measure,
                                                                                                 temp_cascaded_table(1).item_id,
                                                                                                 temp_cascaded_table(1).unit_of_measure
                                                                                                );
            rma_primary_uom_qty        := rcv_transactions_interface_sv.convert_into_correct_qty(1000,
                                                                                                 x_rma_line_record.unit_of_measure,
                                                                                                 temp_cascaded_table(1).item_id,
                                                                                                 temp_cascaded_table(1).primary_unit_of_measure
                                                                                                );
         END IF;

         IF    txn_remaining_qty_rma_uom = 0
            OR rma_receipt_uom_qty = 0
            OR rma_primary_uom_qty = 0 THEN
            --{   PO -> ASN uom, PO -> PRIMARY UOM
            -- no point in going further for this record
            -- as we cannot convert between the ASN -> PO uoms
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Need an error message in the interface tables');
               asn_debug.put_line('Cannot interconvert between diff UOMs');
               asn_debug.put_line('This RMA line cannot be used as the uoms ');
               asn_debug.put_line(temp_cascaded_table(1).unit_of_measure || ' ' || x_rma_line_record.unit_of_measure);
               asn_debug.put_line('cannot be converted for item ' || TO_CHAR(temp_cascaded_table(1).item_id));
               insert_into_table  := FALSE;
            END IF;
         ELSE --}{
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Current Item Id ' || TO_CHAR(temp_cascaded_table(1).item_id));
               asn_debug.put_line('Current Txn Quantity ' || TO_CHAR(txn_remaining_qty));
               asn_debug.put_line('Current Txn UOM ' || temp_cascaded_table(1).unit_of_measure);
               asn_debug.put_line('Converted RMA UOM Quantity ' || TO_CHAR(txn_remaining_qty_rma_uom));
               asn_debug.put_line('RMA UOM ' || x_rma_line_record.unit_of_measure);
            END IF;
         END IF; --}

         IF insert_into_table THEN                                               --{ allocate part of the txn qty to this line
                                   -- record where we are allocating the qty from
            temp_cascaded_table(temp_cascaded_table.LAST).oe_order_line_id            := x_rma_line_record.oe_order_line_id;

                 -- allocate as much of the txn qty to this line as possible
            /* Bug 3423602.
             * rma_line_qty is in terms of rma uom. We need to
             * compare it with txn_remaining_qty_rma_uom and not with
             * txn_remaining_qty which was what we were doing before.
             * Changed the code in this procedure to change txn_remaining_qty
             * to txn_remaining_qty_rma_uom wherever necessary.
            */
            IF rma_line_qty < txn_remaining_qty_rma_uom THEN
               allocate_qty  := rma_line_qty;
            ELSE
               allocate_qty  := txn_remaining_qty_rma_uom;
            END IF;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Quantity to allocate to this line: ' || allocate_qty);
            END IF;

            --bug 4505906, record the used quantity in this session
            --Bug 8494868 When oe_line_id crossed 2^31 the pl/sql table should not throw any exception.
             g_used_rma_line_amounts(mod(x_rma_line_record.oe_order_line_id,2147483648)) := already_allocated_qty + allocate_qty;

            /* source_doc_quantity -> in rma_uom
                 primary_quantity    -> in primary_uom
                 quantity -> in txn uom */
            temp_cascaded_table(temp_cascaded_table.LAST).source_doc_quantity         := allocate_qty; -- in rma uom
            temp_cascaded_table(temp_cascaded_table.LAST).source_doc_unit_of_measure  := x_rma_line_record.unit_of_measure;

            -- bug 1363369 fix carried forward FROM bug# 1337314
            -- No need to do the following conversion if the cursor returns one row
            -- for a corresponding record in the interface, as the quantity is already in asn uom.
            -- If the cursor fetches more than one row then the quantity in the interface will be
            -- distributed accross the fetched rows and hence need to do the following conversion.
            IF rma_lines%ROWCOUNT > 1 THEN
               temp_cascaded_table(temp_cascaded_table.LAST).quantity  := rcv_transactions_interface_sv.convert_into_correct_qty(allocate_qty,
                                                                                                                                 x_rma_line_record.unit_of_measure,
                                                                                                                                 temp_cascaded_table(temp_cascaded_table.LAST).item_id,
                                                                                                                                 temp_cascaded_table(temp_cascaded_table.LAST).unit_of_measure
                                                                                                                                );
            END IF;

            -- Primary qty in Primary UOM
            temp_cascaded_table(temp_cascaded_table.LAST).primary_quantity            := rcv_transactions_interface_sv.convert_into_correct_qty(allocate_qty,
                                                                                                                                                x_rma_line_record.unit_of_measure,
                                                                                                                                                temp_cascaded_table(temp_cascaded_table.LAST).item_id,
                                                                                                                                                temp_cascaded_table(temp_cascaded_table.LAST).primary_unit_of_measure
                                                                                                                                               );
            temp_cascaded_table(temp_cascaded_table.LAST).tax_amount                  := ROUND(temp_cascaded_table(temp_cascaded_table.LAST).quantity * tax_amount_factor, 4);

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Current Tax Amount ' || TO_CHAR(temp_cascaded_table(temp_cascaded_table.LAST).tax_amount));
            END IF;

            -- update the remaining quantity
            txn_remaining_qty_rma_uom                                                 := txn_remaining_qty_rma_uom - allocate_qty;
            txn_remaining_qty                                                         := rcv_transactions_interface_sv.convert_into_correct_qty(txn_remaining_qty_rma_uom,
                                                                                                                                                x_rma_line_record.unit_of_measure,
                                                                                                                                                temp_cascaded_table(1).item_id,
                                                                                                                                                temp_cascaded_table(1).unit_of_measure
                                                                                                                                               );
         ELSE   -- }{ matches if insert_into_table
              -- remove the row if the current line is not matched to the txn
            temp_cascaded_table.DELETE(temp_cascaded_table.COUNT);
         END IF; --} matches if insert_into_table
      END LOOP;

      --}

      -- finished processing all lines
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Hit exit condition');
         asn_debug.put_line('Temp table size ' || TO_CHAR(temp_cascaded_table.COUNT));
         asn_debug.put_line('Rows fetched ' || TO_CHAR(rma_lines_fetched));
      END IF;

      -- if nothing was processed, find out why, and quit
      IF     x_cascaded_table(n).quantity > 0
         AND txn_remaining_qty = x_cascaded_table(n).quantity THEN --{
         IF rma_lines_fetched = 0 THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('No rows were retrieved from cursor.');
            END IF;
         ELSE
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('No rows were cascaded');
            END IF;
         END IF;

         BEGIN
            SELECT NVL(oeh.open_flag, 'N'),
                   NVL(oel.line_category_code, 'N'),
                   NVL(oel.open_flag, 'N'),
                   NVL(oel.inventory_item_id, 0),
                   NVL(mci.customer_item_number, 'N'),
                   NVL(oel.booked_flag, 'N'),
                   NVL(oel.flow_status_code, 'N'),
                   oel.ordered_quantity,
                   NVL(oel.shipped_quantity, 0)
            INTO   x_header_open_flag,
                   x_line_category_code,
                   x_line_open_flag,
                   x_item_id,
                   x_customer_item_num,
                   x_booked_flag,
                   x_flow_status_code,
                   x_ordered_quantity,
                   x_shipped_quantity
            FROM   oe_order_headers_all oeh,
                   oe_order_lines_all oel,
                   mtl_customer_items mci
            WHERE  oeh.header_id = x_cascaded_table(n).oe_order_header_id
            AND    oeh.header_id = oel.header_id
            AND    oel.line_number = NVL(x_cascaded_table(n).oe_order_line_num, oel.line_number)
            AND    oel.inventory_item_id = NVL(x_cascaded_table(n).item_id, oel.inventory_item_id)
            AND    oel.ordered_item_id = mci.customer_item_id(+);

            IF x_item_id <> NVL(temp_cascaded_table(temp_cascaded_table.COUNT).item_id, x_item_id) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'ITEM_NUM');
               rcv_error_pkg.set_token('VALUE', temp_cascaded_table(temp_cascaded_table.COUNT).item_num);
               rcv_error_pkg.log_interface_error('ITEM_NUM', FALSE);
            ELSIF x_ship_to_organization_id <> NVL(temp_cascaded_table(temp_cascaded_table.COUNT).to_organization_id, x_ship_to_organization_id) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'TO_ORGANIZATION_CODE');
               rcv_error_pkg.set_token('VALUE', temp_cascaded_table(temp_cascaded_table.COUNT).to_organization_code);
               rcv_error_pkg.log_interface_error('TO_ORGANIZATION_CODE', FALSE);
            ELSIF x_ship_to_location_id <> NVL(NVL(temp_cascaded_table(temp_cascaded_table.COUNT).ship_to_location_id, x_header_record.header_record.location_id), x_ship_to_location_id) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'SHIP_TO_LOCATION_CODE');
               rcv_error_pkg.set_token('VALUE', temp_cascaded_table(temp_cascaded_table.COUNT).ship_to_location_code);
               rcv_error_pkg.log_interface_error('SHIP_TO_LOCATION_CODE', FALSE);
            ELSIF x_header_open_flag <> 'Y' THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'OPEN_FLAG');
               rcv_error_pkg.set_token('VALUE', x_header_open_flag);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            ELSIF x_line_category_code <> 'RETURN' THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'LINE_CATEGORY_CODE');
               rcv_error_pkg.set_token('VALUE', x_line_category_code);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            ELSIF x_line_open_flag <> 'Y' THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'OPEN_FLAG');
               rcv_error_pkg.set_token('VALUE', x_header_open_flag);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            ELSIF x_customer_item_num <> NVL(temp_cascaded_table(temp_cascaded_table.COUNT).customer_item_num, x_customer_item_num) THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'CUSTOMER_ITEM_NUM');
               rcv_error_pkg.set_token('VALUE', temp_cascaded_table(temp_cascaded_table.COUNT).customer_item_num);
               rcv_error_pkg.log_interface_error('CUSTOMER_ITEM_NUM', FALSE);
            ELSIF x_booked_flag <> 'Y' THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'BOOKED_FLAG');
               rcv_error_pkg.set_token('VALUE', x_booked_flag);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            ELSIF x_flow_status_code <> 'AWAITING RETURN' THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'FLOW_STATUS_CODE');
               rcv_error_pkg.set_token('VALUE', x_flow_status_code);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            ELSIF x_ordered_quantity < x_shipped_quantity THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'SHIPPED_QUANTITY');
               rcv_error_pkg.set_token('VALUE', x_shipped_quantity);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            ELSE
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'OE_ORDER_HEADER_ID');
               rcv_error_pkg.set_token('VALUE', x_cascaded_table(n).oe_order_header_id);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('COLUMN', 'OE_ORDER_HEADER_ID');
               rcv_error_pkg.set_token('VALUE', x_cascaded_table(n).oe_order_header_id);
               rcv_error_pkg.log_interface_error('OE_ORDER_HEADER_ID', FALSE);
         END;

         -- Delete the temp_cascaded_table and return
         temp_cascaded_table.DELETE;
      ELSIF txn_remaining_qty > 0 THEN
         -- }{
         -- something was processed, check for overtolerance

         -- get tolerable qty

         --<R12 MOAC>
         /* get_rma_tolerances procedure is not operating unit context sensitive.
            Removed the call to fnd_global.apps_initialize */

         /* Bug 5660538: Removed references to x_rma_line_record */

         oe_rma_receiving.get_rma_tolerances(temp_cascaded_table(temp_cascaded_table.LAST).oe_order_line_id,
                                             x_under_return_tolerance,
                                             x_qty_rcv_tolerance,
                                             x_oe_return_status,
                                             x_oe_msg_count,
                                             x_oe_msg_data
                                            );

         -- check remaining qty vs tolerance qty using the last rma line's tolerance
         IF (txn_remaining_qty_rma_uom > rma_line_qty * x_qty_rcv_tolerance / 100) THEN
            -- the txn qty exceeds the tolerable qty
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Extra Txn UOM Quantity ' || TO_CHAR(txn_remaining_qty));
               asn_debug.put_line('Extra RMA UOM Quantity ' || TO_CHAR(txn_remaining_qty_rma_uom));
               asn_debug.put_line('delete the temp table ');
            END IF;

            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_SHIP_QTY_OVER_TOLERANCE', x_cascaded_table(n).error_message);
            rcv_error_pkg.set_token('QTY_A', x_cascaded_table(n).quantity);
            rcv_error_pkg.set_token('QTY_B', x_cascaded_table(n).quantity - txn_remaining_qty);
            rcv_error_pkg.log_interface_error('QUANTITY', FALSE);
            temp_cascaded_table.DELETE;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('mark the actual table with error status');
               asn_debug.put_line('Error Status ' || x_cascaded_table(n).error_status);
               asn_debug.put_line('Error message ' || x_cascaded_table(n).error_message);
            END IF;
         ELSE
            -- }{ the txn qty does not exceed tolerance, allocate remaining to last row
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('txn qty does not exceed tolerance');
            END IF;

            /** Bug 5408054:
              * When the cursor 'rma_lines' fetches only 1 record, then transaction qty is not getting
              * modified, so we should not add again the remaining quanity with the transaction
              * quanity, as it will result in exceeding the transaction quantity entered by the
              * the user and also transaction will fail due to exceeding the over tolerance limit.
              * When the cursor 'rma_lines' fetches more than 1 record, then only transaction
              * quantity( ordered quantity + tolerance qty) is set to ordered quanity, in that
              * case we have to sum the remaining quantity.
              * So, we have to add the remaining qty with transaction qty, only when the
              * the number of records fetched by the cursor 'rma_lines' is greater than 1.
             */
            IF rma_lines_fetched > 1 THEN
               temp_cascaded_table(temp_cascaded_table.LAST).quantity          := temp_cascaded_table(temp_cascaded_table.LAST).quantity + txn_remaining_qty;
            END IF;
            temp_cascaded_table(temp_cascaded_table.LAST).primary_quantity     :=   temp_cascaded_table(temp_cascaded_table.LAST).primary_quantity
                                                                                  + rcv_transactions_interface_sv.convert_into_correct_qty(txn_remaining_qty,
                                                                                                                                           temp_cascaded_table(temp_cascaded_table.LAST).unit_of_measure,
                                                                                                                                           temp_cascaded_table(temp_cascaded_table.LAST).item_id,
                                                                                                                                           temp_cascaded_table(temp_cascaded_table.LAST).primary_unit_of_measure
                                                                                                                                          );
            temp_cascaded_table(temp_cascaded_table.LAST).source_doc_quantity  :=   temp_cascaded_table(temp_cascaded_table.LAST).source_doc_quantity
                                                                                  + rcv_transactions_interface_sv.convert_into_correct_qty(txn_remaining_qty,
                                                                                                                                           temp_cascaded_table(temp_cascaded_table.LAST).unit_of_measure,
                                                                                                                                           temp_cascaded_table(temp_cascaded_table.LAST).item_id,
                                                                                                                                           temp_cascaded_table(temp_cascaded_table.LAST).source_doc_unit_of_measure
                                                                                                                                          );
         END IF; -- } end if remaining > tolerance
      END IF; --} end if remaining > 0

              -- successful execution

      IF txn_remaining_qty = 0 THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Remaining Txn UOM quantity is zero ' || TO_CHAR(txn_remaining_qty));
            asn_debug.put_line('Remaining RMA UOM quantity is zero ' || TO_CHAR(txn_remaining_qty_rma_uom));
            asn_debug.put_line('Return the cascaded rows back to the calling procedure');
         END IF;
      END IF;

      -- OPM change.Bug# 3061052
      -- if original receiving transaction line is split and secondary quantity is specified then
      -- set secondary quantity for the split lines to NULL.

      /* INVCONV , remove OPM installation checks */
      IF     x_cascaded_table(n).error_status IN('S', 'W')
        /* AND gml_process_flags.opm_installed = 1 */
         AND x_cascaded_table(n).secondary_quantity IS NOT NULL THEN
         IF temp_cascaded_table.COUNT > 1 THEN
            FOR j IN 1 .. temp_cascaded_table.COUNT LOOP
               temp_cascaded_table(j).secondary_quantity  := NULL;
            END LOOP;
         END IF;
      END IF;
      /* end , INVCONV*/
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Exit explode_line_quantity');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('explode_line_quantity', x_progress);
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(n));
            asn_debug.put_line(SQLERRM);
            asn_debug.put_line('error ' || x_progress);
         END IF;
   END explode_line_quantity;

   PROCEDURE default_source_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_id      IN            rcv_headers_interface.header_interface_id%TYPE
   ) IS
   BEGIN
      x_cascaded_table(n).header_interface_id  := x_header_id;

      --x_cascaded_table(n).shipment_line_status_code := 'OPEN';

      IF x_cascaded_table(n).source_document_code IS NULL THEN
         x_cascaded_table(n).source_document_code  := 'RMA';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting SOURCE_DOCUMENT_CODE ' || x_cascaded_table(n).source_document_code);
         END IF;
      END IF;

      /* Bug3593237 - START */
      /*
         Current Location was not getting displayed in Receiving Transactions
         form since location_id was not defaulted when it was null.
         Defaulting location_id from deliver_to_location_id
         incase of deliver transaction and from ship_to_location_id for all other
         transactions because in any case other than deliver transaction
         ship_to_location_id should get displayed as the current location in
         Receiving Transactions form.
       */
      IF (x_cascaded_table(n).location_id IS NULL) THEN
         IF (   NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER'
             OR x_cascaded_table(n).transaction_type = 'DELIVER') THEN
            x_cascaded_table(n).location_id  := x_cascaded_table(n).deliver_to_location_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Defaulting LOCATION_ID ' || x_cascaded_table(n).deliver_to_location_id);
            END IF;
         ELSE
            x_cascaded_table(n).location_id  := x_cascaded_table(n).ship_to_location_id;

            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Defaulting LOCATION_ID ' || x_cascaded_table(n).ship_to_location_id);
            END IF;
         END IF;
      END IF;
   /* Bug3593237 - END */
   END default_source_info;

   PROCEDURE default_destination_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      IF    x_cascaded_table(n).destination_type_code IS NULL
         OR (    x_cascaded_table(n).destination_type_code = 'INVENTORY'
             AND x_cascaded_table(n).auto_transact_code = 'RECEIVE') THEN
         x_cascaded_table(n).destination_type_code  := 'RECEIVING';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting DESTINATION_TYPE_CODE ' || x_cascaded_table(n).destination_type_code);
         END IF;
      END IF;

      /* Bug 3592340.
       * If auto_transact_code is DELIVER and the transaction type is
       * RECEIVE, then this means we need to do direct delivery and hence
       * the destination_type_code needs to be INVENTORY and not
       * RECEIVING. So default it to INVENTORY.
      */
      IF (    x_cascaded_table(n).transaction_type = 'RECEIVE'
          AND x_cascaded_table(n).auto_transact_code = 'DELIVER') THEN
         x_cascaded_table(n).destination_type_code  := 'INVENTORY';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting DESTINATION_TYPE_CODE for direct delivery ' || x_cascaded_table(n).destination_type_code);
         END IF;
      END IF;

      IF x_cascaded_table(n).destination_context IS NULL THEN
         x_cascaded_table(n).destination_context  := x_cascaded_table(n).destination_type_code;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting DESTINATION_CONTEXT ' || x_cascaded_table(n).destination_context);
         END IF;
      END IF;
   END default_destination_info;

   PROCEDURE default_transaction_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      IF x_cascaded_table(n).transaction_type IS NULL THEN
         x_cascaded_table(n).transaction_type  := 'RECEIVE';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting TRANSACTION_TYPE ' || x_cascaded_table(n).transaction_type);
         END IF;
      END IF;
   END default_transaction_info;

   PROCEDURE default_processing_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      IF x_cascaded_table(n).processing_mode_code IS NULL THEN
         x_cascaded_table(n).processing_mode_code  := 'BATCH';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting PROCESSING_MODE_CODE ' || x_cascaded_table(n).processing_mode_code);
         END IF;
      END IF;

      x_cascaded_table(n).processing_status_code  := 'RUNNING';

      IF x_cascaded_table(n).processing_status_code IS NULL THEN
         -- This has to be set to running otherwise C code in rvtbm
              -- will not pick it up
         x_cascaded_table(n).processing_status_code  := 'RUNNING';

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting PROCESSING_STATUS_CODE ' || x_cascaded_table(n).processing_status_code);
         END IF;
      END IF;
   END default_processing_info;

   PROCEDURE default_routing_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      x_inspection_required_flag VARCHAR2(1);
      l_client_code VARCHAR(40);  /* Bug 9169143: LSP Changes */

   BEGIN
      /* Bug 3228851 - get the default rma routing from rcv_parameters */
      SELECT NVL(MIN(inspection_required_flag), 'N')
      INTO   x_inspection_required_flag
      FROM   oe_po_enter_receipts_v
      WHERE  oe_order_header_id = x_cascaded_table(n).oe_order_header_id
      AND    item_id = x_cascaded_table(n).item_id;

      IF (x_inspection_required_flag = 'Y') THEN
         x_cascaded_table(n).routing_header_id  := 2;
      ELSIF x_cascaded_table(n).routing_header_id IS NULL THEN

      /* Bug 9169143: LSP Changes */

         IF (NVL(FND_PROFILE.VALUE('WMS_DEPLOYMENT_MODE'), 1) = 3) THEN

      l_client_code := wms_deploy.get_client_code(x_cascaded_table(n).item_id);

         If (l_client_code IS NOT NULL) THEN
               select rma_receipt_routing_id
               into   x_cascaded_table(n).routing_header_id
               from   mtl_client_parameters
               WHERE  client_code = l_client_code;

         ELSE

              SELECT NVL(MIN(rma_receipt_routing_id), 1)
              INTO   x_cascaded_table(n).routing_header_id
              FROM   rcv_parameters
              WHERE  organization_id = x_cascaded_table(n).to_organization_id;

         End If;
      Else

         SELECT NVL(MIN(rma_receipt_routing_id), 1)
         INTO   x_cascaded_table(n).routing_header_id
         FROM   rcv_parameters
         WHERE  organization_id = x_cascaded_table(n).to_organization_id;

     END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulted routing_header_id ' || x_cascaded_table(n).routing_header_id);
         END IF;

      IF x_cascaded_table(n).routing_step_id IS NULL THEN
         x_cascaded_table(n).routing_step_id  := 1;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting routing_step_id ' || x_cascaded_table(n).routing_step_id);
         END IF;
      END IF;

      END IF;

/* End LSP changes */

   END default_routing_info;

   PROCEDURE default_from_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      default_customer_header(x_cascaded_table,
                              n,
                              x_header_record
                             );
      default_customer_site_header(x_cascaded_table,
                                   n,
                                   x_header_record
                                  );
      default_from_org_header(x_cascaded_table,
                              n,
                              x_header_record
                             );
      -- default_to_org_header(x_cascaded_table, n, x_header_record);
      default_ship_to_header(x_cascaded_table,
                             n,
                             x_header_record
                            );
      default_currency_info_header(x_cascaded_table,
                                   n,
                                   x_header_record
                                  );
      default_shipment_num_header(x_cascaded_table,
                                  n,
                                  x_header_record
                                 );
      default_freight_carrier_header(x_cascaded_table,
                                     n,
                                     x_header_record
                                    );
      default_bill_of_lading_header(x_cascaded_table,
                                    n,
                                    x_header_record
                                   );
      default_packing_slip_header(x_cascaded_table,
                                  n,
                                  x_header_record
                                 );
      default_ship_date_header(x_cascaded_table,
                               n,
                               x_header_record
                              );
      default_receipt_date_header(x_cascaded_table,
                                  n,
                                  x_header_record
                                 );
      default_num_containers_header(x_cascaded_table,
                                    n,
                                    x_header_record
                                   );
      default_waybill_header(x_cascaded_table,
                             n,
                             x_header_record
                            );
      default_tax_name_header(x_cascaded_table,
                              n,
                              x_header_record
                             );
   END default_from_header;

   PROCEDURE default_item_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      item_id_record    rcv_shipment_line_sv.item_id_record_type;
      l_category_set_id mtl_category_sets_b.category_set_id%TYPE;
   BEGIN
      -- default the item_revision

      /* Bug 3299421 : WMS Mobile applications do not need the item_revision to
                       be defaulted during preprocessing for transactions other than
                       "Deliver". Added the condition in the If clause where we
                       check if the transaction is from mobile and if so do not
                       default the item revision.
      */
      IF     x_cascaded_table(n).item_revision IS NULL
         AND (NVL(x_cascaded_table(n).mobile_txn, 'N') = 'N')
         AND x_cascaded_table(n).error_status IN('S', 'W') THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting item revision');
         END IF;

         item_id_record.item_id                     := x_cascaded_table(n).item_id;
         item_id_record.po_line_id                  := x_cascaded_table(n).oe_order_line_id;
         item_id_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
         item_id_record.item_revision               := x_cascaded_table(n).item_revision;
         item_id_record.error_record.error_status   := 'S';
         item_id_record.error_record.error_message  := NULL;
         default_item_revision(item_id_record);
         x_cascaded_table(n).item_revision          := item_id_record.item_revision;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(NVL(item_id_record.item_revision, 'Item Revision is null'));
         END IF;

         x_cascaded_table(n).error_status           := item_id_record.error_record.error_status;
         x_cascaded_table(n).error_message          := item_id_record.error_record.error_message;
      END IF;

      -- default the category_id
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).category_id IS NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting item category id');
         END IF;

         -- get the default category_set_id for PO
         -- refer to INIT_RCV_CONTROL_BLOCK in POXCOSEU.pld, which eventually calls PO_CORE_S.get_item_category_structure
         SELECT category_set_id
         INTO   l_category_set_id
         FROM   mtl_default_category_sets
         WHERE  functional_area_id = 2;

         -- get the category_id for this item, org, and category_set
         -- based on RCV_RECEIPTS_EH.event('POST-QUERY')
         SELECT MAX(category_id)
         INTO   x_cascaded_table(n).category_id
         FROM   mtl_item_categories
         WHERE  inventory_item_id = x_cascaded_table(n).item_id
         AND    organization_id = x_cascaded_table(n).to_organization_id
         AND    category_set_id = l_category_set_id;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulted category_id ' || x_cascaded_table(n).category_id);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('default_item_info', '000');
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
   END default_item_info;

   PROCEDURE default_from_rma(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      default_rma_record default_rma%ROWTYPE;
   BEGIN
      IF     x_cascaded_table(n).error_status IN('S', 'W')
         AND x_cascaded_table(n).oe_order_line_id IS NOT NULL THEN
         OPEN default_rma(x_cascaded_table(n).oe_order_line_id);
         FETCH default_rma INTO default_rma_record;

         -- default the receiving org info
         IF x_cascaded_table(n).to_organization_id IS NULL THEN
            x_cascaded_table(n).to_organization_id  := default_rma_record.to_organization_id;
         END IF;

         -- default the customer info
         IF x_cascaded_table(n).customer_id IS NULL THEN
            x_cascaded_table(n).customer_id  := default_rma_record.customer_id;
         END IF;

         IF x_cascaded_table(n).customer_site_id IS NULL THEN
            x_cascaded_table(n).customer_site_id  := default_rma_record.customer_site_id;
         END IF;

         -- default currency info
         IF x_cascaded_table(n).currency_code IS NULL THEN
            x_cascaded_table(n).currency_code             := default_rma_record.currency_code;
            x_cascaded_table(n).currency_conversion_type  := default_rma_record.currency_conversion_type;
            x_cascaded_table(n).currency_conversion_rate  := default_rma_record.currency_conversion_rate;
            x_cascaded_table(n).currency_conversion_date  := default_rma_record.currency_conversion_date;
         END IF;

         -- default pricing info
         IF x_cascaded_table(n).po_unit_price IS NULL THEN
            x_cascaded_table(n).po_unit_price  := default_rma_record.unit_price;
         END IF;

         -- default item description
         IF x_cascaded_table(n).item_description IS NULL THEN
            x_cascaded_table(n).item_description  := default_rma_record.item_description;
         END IF;

         -- default destination_info
         IF x_cascaded_table(n).destination_type_code IS NULL THEN
            x_cascaded_table(n).destination_type_code  := 'RECEIVING';
         END IF;

         IF x_cascaded_table(n).destination_context IS NULL THEN
            x_cascaded_table(n).destination_context  := x_cascaded_table(n).destination_type_code;
         END IF;

         -- bug 3592327
         IF x_cascaded_table(n).subinventory IS NULL THEN
            x_cascaded_table(n).subinventory  := default_rma_record.subinventory;
         END IF;

         -- bug 3592327
         IF (x_cascaded_table(n).deliver_to_location_id IS NULL) THEN
            IF (   NVL(x_cascaded_table(n).auto_transact_code, 'RECEIVE') = 'DELIVER'
                OR x_cascaded_table(n).transaction_type = 'DELIVER') THEN
               x_cascaded_table(n).deliver_to_location_id  := default_rma_record.deliver_to_location_id;
            END IF;
         END IF;

         CLOSE default_rma;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_cascaded_table(n).error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('default_from_rma', '000');
         x_cascaded_table(n).error_message  := rcv_error_pkg.get_last_message;
         CLOSE default_rma;
   END default_from_rma;

   PROCEDURE default_ship_to_info_rma(
      x_cascaded_table   IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN            BINARY_INTEGER,
      default_rma_record IN            default_rma%ROWTYPE
   ) IS
   BEGIN
      -- ship_to_org
      IF (    x_cascaded_table(n).error_status IN('S', 'W')
          AND x_cascaded_table(n).to_organization_id IS NULL
          AND default_rma_record.to_organization_id IS NOT NULL) THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting org id from default RMA');
         END IF;

         x_cascaded_table(n).to_organization_id  := default_rma_record.to_organization_id;
      END IF;
   END default_ship_to_info_rma;

   PROCEDURE default_customer_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (    x_cascaded_table(n).error_status IN('S', 'W')
          AND x_cascaded_table(n).customer_id IS NULL) THEN
         IF (x_header_record.header_record.customer_id IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Defaulting customer info from header');
            END IF;

            x_cascaded_table(n).customer_id  := x_header_record.header_record.customer_id;
         ELSE
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('No customer info available');
            END IF;

            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
            rcv_error_pkg.set_token('COLUMN', 'CUSTOMER_ID');
            rcv_error_pkg.set_token('VALUE', x_header_record.header_record.customer_id);
            rcv_error_pkg.log_interface_error('CUSTOMER_ID', FALSE);
         END IF;
      END IF;
   END default_customer_header;

   PROCEDURE default_customer_site_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF (    x_cascaded_table(n).error_status IN('S', 'W')
          AND x_cascaded_table(n).customer_site_id IS NULL) THEN
         IF (x_header_record.header_record.customer_site_id IS NOT NULL) THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Defaulting customer site info from header');
            END IF;

            x_cascaded_table(n).customer_site_id  := x_header_record.header_record.customer_site_id;
         ELSE
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('No customer site info available');
            END IF;

            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_PDOI_DERV_ERROR', x_cascaded_table(n).error_message);
            rcv_error_pkg.set_token('COLUMN', 'CUSTOMER_SITE_ID');
            rcv_error_pkg.set_token('VALUE', x_header_record.header_record.customer_site_id);
            rcv_error_pkg.log_interface_error('CUSTOMER_SITE_ID', FALSE);
         END IF;
      END IF;
   END default_customer_site_header;

   PROCEDURE default_from_org_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF     x_cascaded_table(n).from_organization_id IS NULL
         AND x_cascaded_table(n).from_organization_code IS NULL THEN
         x_cascaded_table(n).from_organization_id    := x_header_record.header_record.from_organization_id;
         x_cascaded_table(n).from_organization_code  := x_header_record.header_record.from_organization_code;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER FROM_ORGANIZATION_ID ' || TO_CHAR(x_cascaded_table(n).from_organization_id));
            asn_debug.put_line('Defaulting from HEADER FROM_ORGANIZATION_CODE ' || x_cascaded_table(n).from_organization_code);
         END IF;
      END IF;
   END default_from_org_header;

   PROCEDURE default_ship_to_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      -- ship_to_org
      IF     x_cascaded_table(n).to_organization_id IS NULL
         AND x_cascaded_table(n).to_organization_code IS NULL THEN
         x_cascaded_table(n).to_organization_id    := x_header_record.header_record.ship_to_organization_id;
         x_cascaded_table(n).to_organization_code  := x_header_record.header_record.ship_to_organization_code;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER TO_ORGANIZATION_ID ' || TO_CHAR(x_cascaded_table(n).to_organization_id));
            asn_debug.put_line('Defaulting from HEADER TO_ORGANIZATION_CODE ' || x_cascaded_table(n).to_organization_code);
         END IF;
      END IF;

      -- ship_to_location
      IF (    x_cascaded_table(n).ship_to_location_id IS NULL
          AND x_cascaded_table(n).ship_to_location_code IS NULL) THEN -- Check this with George
         x_cascaded_table(n).ship_to_location_code  := x_header_record.header_record.location_code;
         x_cascaded_table(n).ship_to_location_id    := x_header_record.header_record.location_id;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER LOCATION_ID ' || TO_CHAR(x_cascaded_table(n).location_id));
         END IF;
      END IF;
   END default_ship_to_header;

   PROCEDURE default_currency_info_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF     x_cascaded_table(n).currency_code IS NULL
         AND x_cascaded_table(n).currency_conversion_type IS NULL
         AND x_cascaded_table(n).currency_conversion_rate IS NULL
         AND x_cascaded_table(n).currency_conversion_date IS NULL THEN
         x_cascaded_table(n).currency_code             := x_header_record.header_record.currency_code;
         x_cascaded_table(n).currency_conversion_type  := x_header_record.header_record.conversion_rate_type;
         x_cascaded_table(n).currency_conversion_rate  := x_header_record.header_record.conversion_rate;
         x_cascaded_table(n).currency_conversion_date  := x_header_record.header_record.conversion_rate_date;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER CURRENCY_CODE ' || x_cascaded_table(n).currency_code);
            asn_debug.put_line('Defaulting from HEADER CURRENCY_CONVERSION_TYPE ' || x_cascaded_table(n).currency_conversion_type);
            asn_debug.put_line('Defaulting from HEADER CURRENCY_CONVERSION_RATE ' || TO_CHAR(x_cascaded_table(n).currency_conversion_rate));
            asn_debug.put_line('Defaulting from HEADER CURRENCY_CONVERSION_DATE ' || TO_CHAR(x_cascaded_table(n).currency_conversion_date, 'DD/MM/YYYY'));
         END IF;
      END IF;
   END default_currency_info_header;

   PROCEDURE default_shipment_num_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).shipment_num IS NULL THEN
         x_cascaded_table(n).shipment_num  := x_header_record.header_record.shipment_num;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER SHIPMENT_NUM ' || x_cascaded_table(n).shipment_num);
         END IF;
      END IF;
   END default_shipment_num_header;

   PROCEDURE default_freight_carrier_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).freight_carrier_code IS NULL THEN
         x_cascaded_table(n).freight_carrier_code  := x_header_record.header_record.freight_carrier_code;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER FREIGHT_CARRIER_CODE ' || x_cascaded_table(n).freight_carrier_code);
         END IF;
      END IF;
   END default_freight_carrier_header;

   PROCEDURE default_bill_of_lading_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).bill_of_lading IS NULL THEN
         x_cascaded_table(n).bill_of_lading  := x_header_record.header_record.bill_of_lading;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER BILL_OF_LADING ' || x_cascaded_table(n).bill_of_lading);
         END IF;
      END IF;
   END default_bill_of_lading_header;

   PROCEDURE default_packing_slip_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).packing_slip IS NULL THEN
         x_cascaded_table(n).packing_slip  := x_header_record.header_record.packing_slip;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER PACKING_SLIP ' || x_cascaded_table(n).packing_slip);
         END IF;
      END IF;
   END default_packing_slip_header;

   PROCEDURE default_ship_date_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).shipped_date IS NULL THEN
         x_cascaded_table(n).shipped_date  := x_header_record.header_record.shipped_date;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER SHIPPED_DATE ' || TO_CHAR(x_cascaded_table(n).shipped_date, 'DD/MM/YYYY'));
         END IF;
      END IF;
   END default_ship_date_header;

   PROCEDURE default_receipt_date_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).expected_receipt_date IS NULL THEN
         x_cascaded_table(n).expected_receipt_date  := x_header_record.header_record.expected_receipt_date;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER EXPECTED_RECEIPT_DATE ' || TO_CHAR(x_cascaded_table(n).expected_receipt_date, 'DD/MM/YYYY'));
         END IF;
      END IF;
   END default_receipt_date_header;

   PROCEDURE default_num_containers_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).num_of_containers IS NULL THEN
         x_cascaded_table(n).num_of_containers  := x_header_record.header_record.num_of_containers;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER NUM_OF_CONTAINERS ' || TO_CHAR(x_cascaded_table(n).num_of_containers));
         END IF;
      END IF;
   END default_num_containers_header;

   PROCEDURE default_waybill_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).waybill_airbill_num IS NULL THEN
         x_cascaded_table(n).waybill_airbill_num  := x_header_record.header_record.waybill_airbill_num;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER WAYBILL_AIRBILL_NUM ' || x_cascaded_table(n).waybill_airbill_num);
         END IF;
      END IF;
   END default_waybill_header;

   PROCEDURE default_tax_name_header(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER,
      x_header_record  IN            rcv_roi_preprocessor.header_rec_type
   ) IS
   BEGIN
      IF x_cascaded_table(n).tax_name IS NULL THEN
         x_cascaded_table(n).tax_name  := x_header_record.header_record.tax_name;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Defaulting from HEADER TAX_NAME ' || x_cascaded_table(n).tax_name);
         END IF;
      END IF;
   END default_tax_name_header;

   PROCEDURE validate_freight_carrier_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      NULL;
   END validate_freight_carrier_info;

   PROCEDURE validate_qty_invoiced(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      NULL;
   END validate_qty_invoiced;

   PROCEDURE validate_uom_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      uom_record rcv_shipment_line_sv.quantity_shipped_record_type;
   BEGIN
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Before call to validate UOM');
         asn_debug.put_line('Quantity ' || TO_CHAR(x_cascaded_table(n).quantity));
      END IF;

      /* Commenting the following line because OE stores UOM differently
       * from PO, causing conversion problems.
       * Conversion check is already done in derive quantities anyway.
       */
      -- uom_record.po_line_id := x_cascaded_table(n).oe_order_line_id;

      uom_record.quantity_shipped            := x_cascaded_table(n).quantity;
      uom_record.unit_of_measure             := x_cascaded_table(n).unit_of_measure;
      uom_record.item_id                     := x_cascaded_table(n).item_id;
      uom_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
      uom_record.po_header_id                := x_cascaded_table(n).oe_order_header_id;
      uom_record.primary_unit_of_measure     := x_cascaded_table(n).primary_unit_of_measure;
      uom_record.error_record.error_status   := 'S';
      uom_record.error_record.error_message  := NULL;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating UOM');
      END IF;

      validate_uom(uom_record);
      x_cascaded_table(n).error_status       := uom_record.error_record.error_status;
      x_cascaded_table(n).error_message      := uom_record.error_record.error_message;
      rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                          'UNIT_OF_MEASURE',
                                          FALSE
                                         );
   END validate_uom_info;

   PROCEDURE validate_item_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      item_revision_record rcv_shipment_line_sv.item_id_record_type;
      item_id_record       rcv_shipment_line_sv.item_id_record_type;
   BEGIN
      -- item_id
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      item_id_record.item_id                     := x_cascaded_table(n).item_id;
      item_id_record.po_line_id                  := x_cascaded_table(n).oe_order_line_id;
      item_id_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
      item_id_record.item_description            := x_cascaded_table(n).item_description;
      item_id_record.item_num                    := x_cascaded_table(n).item_num;
      item_id_record.vendor_item_num             := NULL; -- x_cascaded_table(n).vendor_item_num;
      /* bug 608353 */
      item_id_record.use_mtl_lot                 := x_cascaded_table(n).use_mtl_lot;
      item_id_record.use_mtl_serial              := x_cascaded_table(n).use_mtl_serial;
      item_id_record.error_record.error_status   := 'S';
      item_id_record.error_record.error_message  := NULL;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating Item');
         asn_debug.put_line(TO_CHAR(x_cascaded_table(n).item_id));
      END IF;

      /*
      ** If this is a one time item shipment and you've matched up based on a
      ** document line num then skip the processing based on setting the validation
      ** for the item to be the same as what is set on the line.
      */
      IF (    x_cascaded_table(n).item_id IS NULL
          AND x_cascaded_table(n).oe_order_line_id IS NOT NULL) THEN
         item_id_record.error_record.error_status   := x_cascaded_table(n).error_status;
         item_id_record.error_record.error_message  := x_cascaded_table(n).error_message;
      ELSE
         validate_item(item_id_record, x_cascaded_table(n).auto_transact_code); -- bug 608353
      END IF;

      x_cascaded_table(n).error_status           := item_id_record.error_record.error_status;
      x_cascaded_table(n).error_message          := item_id_record.error_record.error_message;
      rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'ITEM_NUM');
      -- item_description
      item_id_record.item_description            := x_cascaded_table(n).item_description;
      item_id_record.error_record.error_status   := 'S';
      item_id_record.error_record.error_message  := NULL;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating Item Description ' || item_id_record.item_description);
      END IF;

      rcv_transactions_interface_sv1.validate_item_description(item_id_record);
      x_cascaded_table(n).error_status           := item_id_record.error_record.error_status;
      x_cascaded_table(n).error_message          := item_id_record.error_record.error_message;
      rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'ITEM_DESCRIPTION');

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Error status after validate item description ' || x_cascaded_table(n).error_status);
      END IF;

      -- item_revision
      IF (x_cascaded_table(n).item_revision IS NOT NULL) THEN
         item_revision_record.item_revision               := x_cascaded_table(n).item_revision;
         item_revision_record.po_line_id                  := x_cascaded_table(n).oe_order_line_id;
         item_revision_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
         item_revision_record.item_id                     := x_cascaded_table(n).item_id;
         item_revision_record.error_record.error_status   := 'S';
         item_revision_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Item Revision');
         END IF;

         validate_item_revision(item_revision_record);
         x_cascaded_table(n).error_status                 := item_revision_record.error_record.error_status;
         x_cascaded_table(n).error_message                := item_revision_record.error_record.error_message;
         x_cascaded_table(n).item_revision                := item_revision_record.item_revision;
         rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status, 'ITEM_REVISION');
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         NULL;
   END validate_item_info;

   PROCEDURE validate_txn_date(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      x_sob_id      NUMBER;
      x_val_open_ok BOOLEAN;
      -- Bug 12582249 add logic to check whether transaction date is earlier than shipment date
      x_parent_txn_id    rcv_transactions.transaction_id%type;
      x_parent_txn_date  rcv_transactions.transaction_date%type;
      x_oe_order_line_id oe_order_lines_all.line_id%type;
      x_oe_reference_order_line_id oe_order_lines_all.reference_line_id%type;
      x_so_issue_transaction_date mtl_material_transactions.transaction_date%type;
      x_item_id mtl_material_transactions.inventory_item_id%type;
      x_oe_reference_order_num oe_order_headers_all.order_number%type;
      x_oe_reference_order_line varchar2(30);
      -- Bug 12582249 End
   BEGIN
      /*Bug 2327318 Implemented the validation Transaction date should not be greater than
      sysdate */
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (x_cascaded_table(n).transaction_date > SYSDATE) THEN
         x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_TRX_FUTURE_DATE_NA', x_cascaded_table(n).error_message);
         rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
      END IF;

      -- bug 642624 validate if PO and GL periods are open in pre-processor

      /* Bug 2653229 - To check if the transaction date falls in the open period only
        when the auto transact code is not SHIP. */
      IF (x_cascaded_table(n).auto_transact_code <> 'SHIP') THEN
      --Bug 8464283 Modified the below sql so that sob_id will be taken for receiving org
      --rather than based on context.
         BEGIN
            select set_of_books_id
            into   x_sob_id
            FROM   org_organization_definitions
            WHERE  organization_id = x_cascaded_table(n).to_organization_id ;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Set of books id not defined');
               END IF;
         END;

         BEGIN
            x_val_open_ok  := po_dates_s.val_open_period(x_cascaded_table(n).transaction_date,
                                                         x_sob_id,
                                                         'SQLGL',
                                                         x_cascaded_table(n).to_organization_id
                                                        );
         EXCEPTION
            WHEN OTHERS THEN
               x_val_open_ok  := FALSE;
         END;

         IF NOT(x_val_open_ok) THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_CNL_NO_PERIOD', x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
         END IF;

         BEGIN
            x_val_open_ok  := po_dates_s.val_open_period(x_cascaded_table(n).transaction_date,
                                                         x_sob_id,
                                                         'INV',
                                                         x_cascaded_table(n).to_organization_id
                                                        );
         EXCEPTION
            WHEN OTHERS THEN
               x_val_open_ok  := FALSE;
         END;

         IF NOT(x_val_open_ok) THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_INV_NO_OPEN_PERIOD', x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
         END IF;

         BEGIN
            x_val_open_ok  := po_dates_s.val_open_period(x_cascaded_table(n).transaction_date,
                                                         x_sob_id,
                                                         'PO',
                                                         x_cascaded_table(n).to_organization_id
                                                        );
         EXCEPTION
            WHEN OTHERS THEN
               x_val_open_ok  := FALSE;
         END;

         IF NOT(x_val_open_ok) THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('PO_PO_ENTER_OPEN_GL_DATE', x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
         END IF;   /* End of Bug# 2379848 */
      END IF; -- auto transact code = SHIP

      -- Bug 12582249, add logic to check whether transaction date is earlier than shipment date
      -- Check whether transaction_date < parent transaction date
      x_parent_txn_id := x_cascaded_table(n).parent_transaction_id;
      if (x_parent_txn_id is not null) then
          BEGIN
              SELECT transaction_date into x_parent_txn_date
              from rcv_transactions rt
              where rt.transaction_id = x_parent_txn_id;
          Exception
              WHEN OTHERS THEN
                  x_parent_txn_date := null;
          END;

          if ( (x_parent_txn_date IS NOT NULL)
              and (x_cascaded_table(n).transaction_date < x_parent_txn_date) ) then
              x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
              rcv_error_pkg.set_error_message('RCV_TRX_ENTER_DT_GT_PARENT_DT', x_cascaded_table(n).error_message);
              rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
          end if;
      end if;

      -- Check whether transaction date < parent transaction date in RTI
      x_parent_txn_id := x_cascaded_table(n).parent_interface_txn_id;
      if (x_parent_txn_id is not null) then
          BEGIN
              SELECT transaction_date into x_parent_txn_date
              from rcv_transactions_interface rti
              where rti.interface_transaction_id = x_parent_txn_id;
          Exception
              WHEN OTHERS THEN
                  x_parent_txn_date := null;
          END;

          if ( (x_parent_txn_date IS NOT NULL)
              and (x_cascaded_table(n).transaction_date < x_parent_txn_date) ) then
              x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
              rcv_error_pkg.set_error_message('RCV_TRX_ENTER_DT_GT_PARENT_DT', x_cascaded_table(n).error_message);
              rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
          end if;
      end if;

      -- Check whether transaction date < sales order shipped date
      x_oe_order_line_id := x_cascaded_table(n).oe_order_line_id;
      BEGIN
           SELECT oola.reference_line_id
             INTO x_oe_reference_order_line_id
             FROM oe_order_lines_all oola
            WHERE oola.line_id = x_oe_order_line_id
              AND oola.return_context = 'ORDER';
      EXCEPTION
         WHEN OTHERS THEN
              x_oe_reference_order_line_id := NULL;
      END;

      IF x_oe_reference_order_line_id IS NOT NULL THEN
         BEGIN
           x_item_id := x_cascaded_table(n).item_id;
           SELECT max(mmt.transaction_date)
             INTO x_so_issue_transaction_date
             FROM mtl_material_transactions mmt
            WHERE mmt.inventory_item_id = x_item_id
              AND mmt.transaction_type_id = 33
              AND mmt.transaction_action_id = 1
              AND mmt.transaction_source_type_id = 2
              AND mmt.trx_source_line_id = x_oe_reference_order_line_id;
          EXCEPTION
            WHEN OTHERS THEN
              x_so_issue_transaction_date := NULL;
          END;

         IF ( ( x_so_issue_transaction_date IS NOT NULL)
              AND (x_cascaded_table(n).transaction_date < x_so_issue_transaction_date) )
            OR x_so_issue_transaction_date is null -- bug 14168623 if so not being shipped then not allow to do RMA
             THEN
               SELECT ooha.order_number, oola.line_number||'.'||oola.shipment_number
                 INTO x_oe_reference_order_num, x_oe_reference_order_line
                 FROM oe_order_headers_all ooha, oe_order_lines_all oola
                WHERE ooha.header_id = oola.header_id
                  AND oola.line_id = x_oe_reference_order_line_id;

               x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
               rcv_error_pkg.set_error_message('RCV_OE_DATE_OUT_OF_RANGE', x_cascaded_table(n).error_message);
               rcv_error_pkg.set_token('RMA_DATE', x_cascaded_table(n).transaction_date);
               rcv_error_pkg.set_token('SO_ISSUE_DATE', x_so_issue_transaction_date);
               rcv_error_pkg.set_token('REF_SO_NUM', x_oe_reference_order_num);
               rcv_error_pkg.set_token('REF_SO_LINE_NUMBER', x_oe_reference_order_line);
               rcv_error_pkg.log_interface_error('TRANSACTION_DATE');
         END IF;

      END IF;
      -- Bug 12582249 End
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         NULL;
   END validate_txn_date;

   PROCEDURE validate_freight_carrier_code(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      freight_carrier_record rcv_shipment_line_sv.freight_carrier_record_type;
   BEGIN
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (x_cascaded_table(n).freight_carrier_code IS NOT NULL) THEN
         freight_carrier_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
         freight_carrier_record.freight_carrier_code        := x_cascaded_table(n).freight_carrier_code;
         freight_carrier_record.po_header_id                := x_cascaded_table(n).po_header_id;
         freight_carrier_record.error_record.error_status   := 'S';
         freight_carrier_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Freight Carrier');
         END IF;

         rcv_transactions_interface_sv1.validate_freight_carrier(freight_carrier_record);
         x_cascaded_table(n).error_status                   := freight_carrier_record.error_record.error_status;
         x_cascaded_table(n).error_message                  := freight_carrier_record.error_record.error_message;
         rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                             'FREIGHT_CARRIER_CODE',
                                             FALSE
                                            );
      END IF;
   END validate_freight_carrier_code;

   PROCEDURE validate_destination_type(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      po_lookup_code_record rcv_shipment_line_sv.po_lookup_code_record_type;
   BEGIN
      /*
      ** Validate Destination Type.  This value is always required
      */
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      po_lookup_code_record.lookup_code                 := x_cascaded_table(n).destination_type_code;
      po_lookup_code_record.lookup_type                 := 'RCV DESTINATION TYPE';
      po_lookup_code_record.error_record.error_status   := 'S';
      po_lookup_code_record.error_record.error_message  := NULL;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating Destination Type Code');
      END IF;

      rcv_transactions_interface_sv1.validate_po_lookup_code(po_lookup_code_record);
      x_cascaded_table(n).error_status                  := po_lookup_code_record.error_record.error_status;
      x_cascaded_table(n).error_message                 := po_lookup_code_record.error_record.error_message;
      rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                          'DESTINATION_TYPE_CODE',
                                          FALSE
                                         );
   END validate_destination_type;

   PROCEDURE validate_deliver_to_info(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      employee_record rcv_shipment_line_sv.employee_record_type;
   BEGIN
      /*
      ** Validate deliver to person.  This value is always optional
      */
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      employee_record.employee_id                 := x_cascaded_table(n).deliver_to_person_id;
      employee_record.to_organization_id          := x_cascaded_table(n).to_organization_id;
      employee_record.destination_type_code       := x_cascaded_table(n).destination_type_code;
      employee_record.transaction_date            := x_cascaded_table(n).transaction_date;
      employee_record.error_record.error_status   := 'S';
      employee_record.error_record.error_message  := NULL;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating Deliver to Person');
      END IF;

      rcv_transactions_interface_sv1.validate_employee(employee_record);
      x_cascaded_table(n).error_status            := employee_record.error_record.error_status;
      x_cascaded_table(n).error_message           := employee_record.error_record.error_message;
      rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                          'DELIVER_TO_PERSON_ID',
                                          FALSE
                                         );
   END validate_deliver_to_info;

   PROCEDURE validate_tax_name(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
   BEGIN
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating tax_name: ' || x_cascaded_table(n).tax_name);
      END IF;
   END validate_tax_name;

   PROCEDURE validate_country_of_origin(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      country_of_origin_record rcv_shipment_line_sv.country_of_origin_record_type;
   BEGIN
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating country_of_origin_code: ' || x_cascaded_table(n).country_of_origin_code);
      END IF;

      IF (x_cascaded_table(n).country_of_origin_code IS NOT NULL) THEN
         country_of_origin_record.country_of_origin_code      := x_cascaded_table(n).country_of_origin_code;
         country_of_origin_record.error_record.error_status   := 'S';
         country_of_origin_record.error_record.error_message  := NULL;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Validating Country of Origin Code');
         END IF;

         rcv_transactions_interface_sv1.validate_country_of_origin(country_of_origin_record);
         x_cascaded_table(n).error_status                     := country_of_origin_record.error_record.error_status;
         x_cascaded_table(n).error_message                    := country_of_origin_record.error_record.error_message;
         rcv_error_pkg.log_interface_message(x_cascaded_table(n).error_status,
                                             'COUNTRY_OF_ORIGIN_CODE',
                                             FALSE
                                            );
      END IF;
   END validate_country_of_origin;

/*===========================================================================

  PROCEDURE NAME: validate_item()

  Copied from rcv_transactions_interface_sv1 and modified for RMA use

===========================================================================*/
   PROCEDURE validate_item(
      x_item_id_record     IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type,
      x_auto_transact_code IN            rcv_transactions_interface.auto_transact_code%TYPE
   ) IS -- bug 608353
      x_progress        VARCHAR2(3);
      x_inventory_item  mtl_system_items.inventory_item_id%TYPE;
      x_organization_id mtl_system_items.organization_id%TYPE;
      x_item_id_po      oe_order_lines_all.inventory_item_id%TYPE;
      x_error_status    VARCHAR2(1);
   BEGIN
      x_error_status  := rcv_error_pkg.g_ret_sts_error;
      x_progress      := '000';

      SELECT NVL(MAX(inventory_item_id), -9999)
      INTO   x_inventory_item
      FROM   mtl_system_items
      WHERE  inventory_item_id = x_item_id_record.item_id;

      IF (x_inventory_item = -9999) THEN
         rcv_error_pkg.set_error_message('RCV_ITEM_ID');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      SELECT NVL(MAX(inventory_item_id), -9999)
      INTO   x_inventory_item
      FROM   mtl_system_items
      WHERE  SYSDATE BETWEEN NVL(start_date_active, SYSDATE - 1) AND NVL(end_date_active, SYSDATE + 1)
      AND    inventory_item_id = x_item_id_record.item_id
      AND    organization_id = NVL(x_item_id_record.to_organization_id,organization_id); -- Bug 12985791

      IF (x_inventory_item = -9999) THEN
         rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ACTIVE');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      /* Bug 2160314.
        * We used to have nvl(max(organization_id),0) here before. But if the
        * organization_id is itself 0, then this will give us a problem in
        * the next step when we check if  x_organization_id = 0. So changed
        * the statement to nvl(max(organization_id),-9999) and also the
        * check below. Similarly changed the select statement and the
        * check for nvl(max(item_id),0).
       */
      SELECT NVL(MAX(organization_id), -9999)
      INTO   x_organization_id
      FROM   mtl_system_items
      WHERE  inventory_item_id = x_item_id_record.item_id
      AND    organization_id = NVL(x_item_id_record.to_organization_id, organization_id);

      IF (x_organization_id = -9999) THEN
         rcv_error_pkg.set_error_message('RCV_ITEM_NOT_IN_ORG');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      SELECT NVL(MAX(inventory_item_id), -9999)
      INTO   x_item_id_po
      FROM   oe_order_lines_all
      WHERE  line_id = x_item_id_record.po_line_id
      AND    inventory_item_id = x_item_id_record.item_id;

      IF (x_item_id_po = -9999) THEN
         rcv_error_pkg.set_error_message('RCV_ITEM_NOT_ON_PO');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      /* Bug 2898324 The non-purchasable items were allowed to be
         received thru ROI. The validation on purchasable flag
         is not based on the receving org. Added a filter condition
         based on organization id.
       */

      /* Fix for bug 2989299.
         Commenting the following sql as we should not validate an item
         based on it's purchasing flags at the time of receipt creation.
         Only at the time of creating the Purchase Order this flag has
         to be checked upon. Please see bug 2706571 for more details.
         For the time being we are not checking on item's stockable flag
         thru ROI. If required we will incorporate later.
      */
      SELECT NVL(MAX(inventory_item_id), -9999)
      INTO   x_item_id_po
      FROM   oe_order_lines_all
      WHERE  line_id = x_item_id_record.po_line_id
      AND    inventory_item_id = x_item_id_record.item_id;

      IF (x_item_id_po <> x_item_id_record.item_id) THEN
         rcv_error_pkg.set_error_message('RCV_NOT_PO_LINE_NUM');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      /* bug 608353, do not support lot and serial control if DELIVER is used */
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating Item: ' || x_auto_transact_code);
         asn_debug.put_line('Validating Item: ' || x_item_id_record.use_mtl_lot);
         asn_debug.put_line('Validating Item: ' || x_item_id_record.use_mtl_serial);
      END IF;
   /* We now support Lot-serial Transactions. Hence removed the code that
    * sets error message to RCV_LOT_SERIAL_NOT_SUPPORTED.
    */
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         x_item_id_record.error_record.error_status   := x_error_status;
         x_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;

         IF (x_item_id_record.error_record.error_message = 'RCV_ITEM_ID') THEN
            rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
         ELSIF(x_item_id_record.error_record.error_message = 'RCV_ITEM_NOT_ACTIVE') THEN
            rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
         ELSIF(x_item_id_record.error_record.error_message = 'RCV_ITEM_NOT_IN_ORG') THEN
            rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
            rcv_error_pkg.set_token('ORGANIZATION', x_item_id_record.to_organization_id);
         ELSIF(x_item_id_record.error_record.error_message = 'RCV_ITEM_NOT_ON_PO') THEN
            rcv_error_pkg.set_token('ITEM', x_item_id_record.item_id);
            rcv_error_pkg.set_token('PO_NUMBER', x_item_id_record.po_line_id);
         ELSIF(x_item_id_record.error_record.error_message = 'RCV_NOT_PO_LINE_NUM') THEN
            rcv_error_pkg.set_token('PO_ITEM', x_item_id_po);
            rcv_error_pkg.set_token('SHIPMENT_ITEM', x_item_id_record.item_id);
         END IF;
   END validate_item;

/*===========================================================================

  PROCEDURE NAME: validate_item_revision()

  Copied from rcv_transactions_interface_sv1 and modified for RMA use

===========================================================================*/
   PROCEDURE validate_item_revision(
      x_item_revision_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
   ) IS
      x_inventory_item        mtl_system_items.inventory_item_id%TYPE;
      x_progress              VARCHAR2(3);
      x_revision_control_flag VARCHAR2(1);
      x_error_status          VARCHAR2(1);
   BEGIN
      x_error_status  := rcv_error_pkg.g_ret_sts_error;

      -- check whether the item is under revision control
      -- If it is not then item should not have any revisions

      SELECT DECODE(msi.revision_qty_control_code,
                    1, 'N',
                    2, 'Y',
                    'N'
                   )
      INTO   x_revision_control_flag
      FROM   mtl_system_items msi
      WHERE  inventory_item_id = x_item_revision_record.item_id
      AND    organization_id = x_item_revision_record.to_organization_id;

      IF x_revision_control_flag = 'N' THEN
/*  Bug 1913887 : Check if the item is Non-revision controlled
    and the revision entered matches with the one in PO, then
    return without any error, else return with error
*/
         SELECT NVL(MAX(line_id), 0)
         INTO   x_inventory_item
         FROM   oe_order_lines_all
         WHERE  line_id = x_item_revision_record.po_line_id
         AND    NVL(item_revision, x_item_revision_record.item_revision) = x_item_revision_record.item_revision;

         IF (x_inventory_item <> 0) THEN
            RETURN;
         END IF;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Item is not under revision control');
         END IF;

         rcv_error_pkg.set_error_message('RCV_ITEM_REV_NOT_ALLOWED');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      -- Check whether the revision number exists

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Revision number :  ' || x_item_revision_record.item_revision);
      END IF;

      SELECT NVL(MAX(inventory_item_id), 0)
      INTO   x_inventory_item
      FROM   mtl_item_revisions
      WHERE  inventory_item_id = x_item_revision_record.item_id
      AND    organization_id = NVL(x_item_revision_record.to_organization_id, organization_id)
      AND    revision = x_item_revision_record.item_revision;

      IF (x_inventory_item = 0) THEN
         rcv_error_pkg.set_error_message('PO_RI_INVALID_ITEM_REVISION');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      -- Check whether revision is still active

      SELECT NVL(MAX(inventory_item_id), 0) -- does this accurately check for active revisions??
      INTO   x_inventory_item
      FROM   MTL_ITEM_REVISIONS_B mir --Bug 5217526. Earlier using mtl_item_revisions_org_val_v
      WHERE  mir.inventory_item_id = x_item_revision_record.item_id
      AND    mir.organization_id = NVL(x_item_revision_record.to_organization_id, mir.organization_id)
      AND    mir.revision = x_item_revision_record.item_revision;

      IF (x_inventory_item = 0) THEN
         rcv_error_pkg.set_error_message('PO_RI_INVALID_ITEM_REVISION');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      -- Check whether rma revision matches this revision if rma revision is not null

      SELECT NVL(MAX(line_id), 0)
      INTO   x_inventory_item
      FROM   oe_order_lines_all
      WHERE  line_id = x_item_revision_record.po_line_id
      AND    NVL(item_revision, x_item_revision_record.item_revision) = x_item_revision_record.item_revision;

      IF (x_inventory_item = 0) THEN
         x_error_status  := rcv_error_pkg.g_ret_sts_warning;
         rcv_error_pkg.set_error_message('RCV_NOT_PO_REVISION');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         x_item_revision_record.error_record.error_status   := x_error_status;
         x_item_revision_record.error_record.error_message  := rcv_error_pkg.get_last_message;

         IF (x_item_revision_record.error_record.error_message = 'RCV_ITEM_REV_NOT_ALLOWED') THEN
            rcv_error_pkg.set_token('ITEM', x_item_revision_record.item_id);
         ELSIF(x_item_revision_record.error_record.error_message = 'RCV_NOT_PO_REVISION') THEN
            rcv_error_pkg.set_token('PO_REV', x_inventory_item);
            rcv_error_pkg.set_token('SHIPMENT_REV', x_item_revision_record.item_revision);
         END IF;
   END validate_item_revision;

   PROCEDURE validate_ref_integrity(
      x_cascaded_table IN OUT NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                IN            BINARY_INTEGER
   ) IS
      x_customer_item_num rcv_transactions_interface.customer_item_num%TYPE;
      x_customer_id       rcv_transactions_interface.customer_id%TYPE;
      x_order_line_id     oe_order_lines_all.line_id%TYPE;
   BEGIN
      IF (x_cascaded_table(n).error_status NOT IN('S', 'W')) THEN
         RETURN;
      END IF;

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Validating ref integrity');
      END IF;

      -- check customer item number
      IF (x_cascaded_table(n).customer_item_num IS NOT NULL) THEN
         SELECT NVL(MAX(oel.line_id), 0)
         INTO   x_order_line_id
         FROM   oe_order_lines_all oel,
                mtl_customer_items mci
         WHERE  oel.line_id = x_cascaded_table(n).oe_order_line_id
         AND    oel.ordered_item_id = mci.customer_item_id
         AND    mci.customer_item_number = x_cascaded_table(n).customer_item_num;

         IF (x_order_line_id = 0) THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_NOT_CUST_ITEM', x_cascaded_table(n).error_message);
            rcv_error_pkg.set_token('TXN_CUSTOMER_ITEM', x_cascaded_table(n).customer_item_num);
            rcv_error_pkg.set_token('RMA_CUSTOMER_ITEM', x_order_line_id);
            rcv_error_pkg.log_interface_error('CUSTOMER_ITEM_NUM');
         END IF;
      END IF;

      -- check customer id
      IF (x_cascaded_table(n).customer_id IS NOT NULL) THEN
         SELECT (NVL(oeh.sold_to_org_id, 0))
         INTO   x_customer_id
         FROM   oe_order_headers_all oeh
         WHERE  oeh.header_id = x_cascaded_table(n).oe_order_header_id;

         IF (x_customer_id = 0) THEN
            x_cascaded_table(n).error_status  := rcv_error_pkg.g_ret_sts_error;
            rcv_error_pkg.set_error_message('RCV_ERC_MISMATCH_RMA_CUST', x_cascaded_table(n).error_message);
            rcv_error_pkg.log_interface_error('CUSTOMER_ID');
         END IF;
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         NULL;
   END validate_ref_integrity;

   -- Copied from rcv_transactions_interface_sv1.validate_uom and modified for RMAs
   PROCEDURE validate_uom(
      x_uom_record IN OUT NOCOPY rcv_shipment_line_sv.quantity_shipped_record_type
   ) IS
      x_unit_of_measure             rcv_transactions_interface.unit_of_measure%TYPE   := NULL;
      x_unit_meas_lookup_code_lines po_lines_all.unit_meas_lookup_code%TYPE           := NULL;
      x_progress                    VARCHAR2(3);
      x_new_conversion              NUMBER                                            := 0;
      x_primary_unit_of_measure     mtl_system_items.primary_unit_of_measure%TYPE     := NULL;
      x_error_status                VARCHAR2(1);
   BEGIN
      x_error_status  := rcv_error_pkg.g_ret_sts_error;
      x_progress      := '000';

      -- check that the uom is valid
      SELECT NVL(MAX(unit_of_measure), 'notfound')
      INTO   x_unit_of_measure
      FROM   mtl_units_of_measure
      WHERE  unit_of_measure = x_uom_record.unit_of_measure;

      IF (x_unit_of_measure = 'notfound') THEN
         rcv_error_pkg.set_error_message('PO_PDOI_INVALID_UOM_CODE');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      -- check that system date is less than the disabled_date
      IF NOT po_uom_s.val_unit_of_measure(x_uom_record.unit_of_measure) THEN
         rcv_error_pkg.set_error_message('PO_PDOI_INVALID_UOM_CODE');
         RAISE rcv_error_pkg.e_fatal_error;
      END IF;

      -- one-time purchase item
      IF (x_uom_record.item_id IS NOT NULL) THEN
         -- must have a primary uom at this point since the first select stmt succeeded

         SELECT primary_unit_of_measure
         INTO   x_primary_unit_of_measure
         FROM   mtl_system_items_kfv
         WHERE  inventory_item_id = x_uom_record.item_id
         AND    organization_id = NVL(x_uom_record.to_organization_id, organization_id); -- Raj added as org_id is part of uk

         IF (NVL(x_uom_record.primary_unit_of_measure, x_primary_unit_of_measure) <> x_primary_unit_of_measure) THEN
            x_error_status  := rcv_error_pkg.g_ret_sts_warning;
            rcv_error_pkg.set_error_message('RCV_UOM_NOT_PRIMARY');
            RAISE rcv_error_pkg.e_fatal_error;
         END IF;

         x_new_conversion  := 0;

         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line(TO_CHAR(x_uom_record.quantity_shipped));
            asn_debug.put_line(x_uom_record.unit_of_measure);
            asn_debug.put_line(TO_CHAR(x_uom_record.item_id));
            asn_debug.put_line(x_primary_unit_of_measure);
            asn_debug.put_line(x_uom_record.primary_unit_of_measure);
         END IF;

         po_uom_s.uom_convert(x_uom_record.quantity_shipped,
                              x_uom_record.unit_of_measure,
                              x_uom_record.item_id,
                              x_primary_unit_of_measure,
                              x_new_conversion
                             );

         IF (x_new_conversion = 0) THEN
            rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PRIMARY');
            RAISE rcv_error_pkg.e_fatal_error;
         ELSIF(x_new_conversion <> x_uom_record.primary_quantity) THEN
            rcv_error_pkg.set_error_message('RCV_QTY_NOT_PRIMARY');
            RAISE rcv_error_pkg.e_fatal_error;
         END IF;
      END IF;

      SELECT NVL(MAX(order_quantity_uom), 'notfound')
      INTO   x_unit_meas_lookup_code_lines
      FROM   oe_order_lines_all
      WHERE  line_id = x_uom_record.po_line_id;

      IF     (x_unit_meas_lookup_code_lines <> 'notfound')
         AND (x_unit_meas_lookup_code_lines <> x_uom_record.unit_of_measure) THEN
         x_new_conversion  := 0;
         po_uom_s.uom_convert(x_uom_record.quantity_shipped,
                              x_uom_record.unit_of_measure,
                              x_uom_record.item_id,
                              x_unit_meas_lookup_code_lines,
                              x_new_conversion
                             );

         IF (x_new_conversion = 0) THEN
            rcv_error_pkg.set_error_message('RCV_UOM_NO_CONV_PO');
            RAISE rcv_error_pkg.e_fatal_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN rcv_error_pkg.e_fatal_error THEN
         x_uom_record.error_record.error_status   := x_error_status;
         x_uom_record.error_record.error_message  := rcv_error_pkg.get_last_message;

         IF (x_uom_record.error_record.error_message = 'PO_PDOI_INVALID_UOM_CODE') THEN
            rcv_error_pkg.set_token('VALUE', x_uom_record.unit_of_measure);
         ELSIF(x_uom_record.error_record.error_message = 'RCV_UOM_NO_CONV_PRIMARY') THEN
            rcv_error_pkg.set_token('SHIPMENT_UNIT', x_new_conversion);
            rcv_error_pkg.set_token('PRIMARY_UNIT', x_uom_record.primary_quantity);
         ELSIF(x_uom_record.error_record.error_message = 'RCV_UOM_NO_CONV_PRIMARY') THEN
            rcv_error_pkg.set_token('SHIPMENT_UNIT', x_new_conversion);
            rcv_error_pkg.set_token('PO_UNIT', x_uom_record.primary_quantity);
         END IF;
   END validate_uom;

   PROCEDURE default_item_revision(
      x_item_revision_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
   ) IS
      x_revision_control_flag VARCHAR2(1);
      x_number_of_inv_dest    NUMBER;
      x_item_rev_exists       BOOLEAN;
   BEGIN
      /* Check whether item is under revision control */
      SELECT DECODE(msi.revision_qty_control_code,
                    1, 'N',
                    2, 'Y',
                    'N'
                   )
      INTO   x_revision_control_flag
      FROM   mtl_system_items msi
      WHERE  inventory_item_id = x_item_revision_record.item_id
      AND    organization_id = x_item_revision_record.to_organization_id;

      /* If item is under revision control

               if revision is null then try to pick up item_revision from oe_order_lines

               if revision is still null and
                  there are any destination_type=INVENTORY then

                      try to pick up latest revision from mtl_item_revisions

               end if
         else
            item should not have any revisions which we will validate in the validation phase */
      IF x_revision_control_flag = 'Y' THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Item is under revision control');
         END IF;

         IF x_item_revision_record.item_revision IS NULL THEN -- pick up revision from source document
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Picking up from source document');
            END IF;

            SELECT item_revision
            INTO   x_item_revision_record.item_revision
            FROM   oe_order_lines_all
            WHERE  oe_order_lines_all.line_id = x_item_revision_record.po_line_id;
         END IF;

         IF x_item_revision_record.item_revision IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
               asn_debug.put_line('Picking up latest implementation since source doc is null');
            END IF;

            po_items_sv2.get_latest_item_rev(x_item_revision_record.item_id,
                                             x_item_revision_record.to_organization_id,
                                             x_item_revision_record.item_revision,
                                             x_item_rev_exists
                                            );
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exception in procedure default_item_revision');
         END IF;
   END default_item_revision;

/*===========================================================================

  PROCEDURE NAME:   check_date_tolerance()

===========================================================================*/
   PROCEDURE check_date_tolerance(
      expected_receipt_date       IN            DATE,
      promised_date               IN            DATE,
      days_early_receipt_allowed  IN            NUMBER,
      days_late_receipt_allowed   IN            NUMBER,
      receipt_days_exception_code IN OUT NOCOPY VARCHAR2
   ) IS
      x_sysdate       DATE := SYSDATE;
      high_range_date DATE;
      low_range_date  DATE;
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Check date tolerance');
      END IF;

      IF (expected_receipt_date IS NOT NULL) THEN
         IF (promised_date IS NOT NULL) THEN
            low_range_date   := promised_date - NVL(days_early_receipt_allowed, 0);
            high_range_date  := promised_date + NVL(days_late_receipt_allowed, 0);
         ELSE
            low_range_date   := x_sysdate - NVL(days_early_receipt_allowed, 0);
            high_range_date  := x_sysdate + NVL(days_late_receipt_allowed, 0);
         END IF;

         IF (    expected_receipt_date >= low_range_date
             AND expected_receipt_date <= high_range_date) THEN
            receipt_days_exception_code  := 'NONE';
         ELSE
            IF receipt_days_exception_code = 'REJECT' THEN
               receipt_days_exception_code  := 'REJECT';
            ELSIF receipt_days_exception_code = 'WARNING' THEN
               receipt_days_exception_code  := 'NONE';
            END IF;
         END IF;
      ELSE
         receipt_days_exception_code  := 'NONE';
      END IF;

      IF receipt_days_exception_code IS NULL THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('In null days exception code');
         END IF;

         receipt_days_exception_code  := 'NONE';
      END IF;
   END check_date_tolerance;

   FUNCTION convert_into_correct_qty(
      source_qty IN NUMBER,
      source_uom IN VARCHAR2,
      item_id    IN NUMBER,
      dest_uom   IN VARCHAR2
   )
      RETURN NUMBER IS
      correct_qty NUMBER;
   BEGIN
      IF source_uom <> dest_uom THEN
         po_uom_s.uom_convert(source_qty,
                              source_uom,
                              item_id,
                              dest_uom,
                              correct_qty
                             );
      ELSE
         correct_qty  := source_qty;
      END IF;

      RETURN(correct_qty);
   EXCEPTION
      WHEN OTHERS THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Could not convert between UOMs');
            asn_debug.put_line('Will return 0');
         END IF;

         correct_qty  := 0;
         RETURN(correct_qty);
   END convert_into_correct_qty;

/*===========================================================================

  PROCEDURE NAME:   get_location_id()

===========================================================================*/
   PROCEDURE get_location_id(
      x_location_id_record IN OUT NOCOPY rcv_shipment_object_sv.location_id_record_type
   ) IS
   BEGIN
      SELECT MAX(location_id)
      INTO   x_location_id_record.location_id
      FROM   hr_locations
      WHERE  location_code = x_location_id_record.location_code;

      IF (x_location_id_record.location_id IS NULL) THEN
         x_location_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ASN_LOCATION_ID', x_location_id_record.error_record.error_message);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_location_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('get_location_id', '000');
         x_location_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END get_location_id;

/*===========================================================================

  PROCEDURE NAME:   get_locator_id()

===========================================================================*/
   PROCEDURE get_locator_id(
      x_locator_id_record IN OUT NOCOPY rcv_shipment_line_sv.locator_id_record_type
   ) IS
   BEGIN
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('inside get_locator_id');
      END IF;

      IF (x_locator_id_record.subinventory IS NULL) THEN
         SELECT MAX(ml.inventory_location_id)
         INTO   x_locator_id_record.locator_id
         FROM   mtl_item_locations_kfv ml
         WHERE  ml.concatenated_segments = x_locator_id_record.LOCATOR
         AND    (   ml.disable_date > SYSDATE
                 OR ml.disable_date IS NULL)
         AND    ml.subinventory_code IS NULL;
      ELSE
         SELECT MAX(ml.inventory_location_id)
         INTO   x_locator_id_record.locator_id
         FROM   mtl_item_locations_kfv ml
         WHERE  ml.concatenated_segments = x_locator_id_record.LOCATOR
         AND    (   ml.disable_date > SYSDATE
                 OR ml.disable_date IS NULL)
         AND    ml.subinventory_code = x_locator_id_record.subinventory;
      END IF;

      IF (x_locator_id_record.locator_id IS NULL) THEN
         x_locator_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ALL_INVALID_LOCATOR', x_locator_id_record.error_record.error_message);
      /* Bug 3591830 Changed the error message name from RCV_ASN_LOCATOR_ID
      ** to RCV_ALL_INVALID_LOCATOR since there was no error message by name
      ** RCV_ASN_LOCATOR_ID in the application.
      */
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_locator_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('get_locator_id', '000');
         x_locator_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END get_locator_id;

/*===========================================================================

  PROCEDURE NAME:   get_routing_header_id()

===========================================================================*/
   PROCEDURE get_routing_header_id(
      x_routing_header_id_record IN OUT NOCOPY rcv_shipment_line_sv.routing_header_id_rec_type
   ) IS
   BEGIN
      SELECT MAX(routing_header_id)
      INTO   x_routing_header_id_record.routing_header_id
      FROM   rcv_routing_headers
      WHERE  routing_name = x_routing_header_id_record.routing_code;

      IF (x_routing_header_id_record.routing_header_id IS NULL) THEN
         x_routing_header_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ASN_ROUTING_HEADER_ID', x_routing_header_id_record.error_record.error_message);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_routing_header_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('get_routing_header_id', '000');
         x_routing_header_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END get_routing_header_id;

/*===========================================================================

  PROCEDURE NAME:   get_routing_step_id()

===========================================================================*/
   PROCEDURE get_routing_step_id(
      x_routing_step_id_record IN OUT NOCOPY rcv_shipment_line_sv.routing_step_id_rec_type
   ) IS
   BEGIN
      SELECT MAX(routing_step_id)
      INTO   x_routing_step_id_record.routing_step_id
      FROM   rcv_routing_steps
      WHERE  step_name = x_routing_step_id_record.routing_step;

      IF (x_routing_step_id_record.routing_step_id IS NULL) THEN
         x_routing_step_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ASN_ROUTING_STEP_ID', x_routing_step_id_record.error_record.error_message);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_routing_step_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('get_routing_step_id', '000');
         x_routing_step_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END get_routing_step_id;

/*===========================================================================

  PROCEDURE NAME:   get_reason_id()

===========================================================================*/
   PROCEDURE get_reason_id(
      x_reason_id_record IN OUT NOCOPY rcv_shipment_line_sv.reason_id_record_type
   ) IS
   BEGIN
      SELECT MAX(reason_id)
      INTO   x_reason_id_record.reason_id
      FROM   mtl_transaction_reasons
      WHERE  reason_name = x_reason_id_record.reason_name;

      IF (x_reason_id_record.reason_id IS NULL) THEN
         x_reason_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_error;
         rcv_error_pkg.set_error_message('RCV_ASN_REASON_ID', x_reason_id_record.error_record.error_message);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_reason_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('get_reason_id', '000');
         x_reason_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END get_reason_id;

/*===========================================================================

  PROCEDURE NAME:   get_item_id()

===========================================================================*/
   PROCEDURE get_item_id(
      x_item_id_record IN OUT NOCOPY rcv_shipment_line_sv.item_id_record_type
   ) IS
   BEGIN
      IF (x_item_id_record.item_num IS NOT NULL) THEN
         SELECT MIN(inventory_item_id),
                MIN(primary_unit_of_measure),
                MIN(lot_control_code), -- bug 608353
                MIN(serial_number_control_code)
         INTO   x_item_id_record.item_id,
                x_item_id_record.primary_unit_of_measure,
                x_item_id_record.use_mtl_lot, -- bug 608353
                x_item_id_record.use_mtl_serial
         FROM   mtl_item_flexfields
         WHERE  item_number = x_item_id_record.item_num
         AND    organization_id = x_item_id_record.to_organization_id;

         IF (x_item_id_record.item_id IS NULL) THEN
            SELECT MIN(inventory_item_id),
                   MIN(primary_unit_of_measure),
                   MIN(lot_control_code), -- bug 608353
                   MIN(serial_number_control_code)
            INTO   x_item_id_record.item_id,
                   x_item_id_record.primary_unit_of_measure,
                   x_item_id_record.use_mtl_lot,
                   x_item_id_record.use_mtl_serial
            FROM   mtl_item_flexfields
            WHERE  item_number = x_item_id_record.vendor_item_num
            AND    organization_id = x_item_id_record.to_organization_id;
         END IF;
      END IF;

      IF (x_item_id_record.item_id IS NULL) THEN
         x_item_id_record.error_record.error_status  := rcv_error_pkg.g_ret_sts_warning;
         rcv_error_pkg.set_error_message('RCV_ITEM_ID', x_item_id_record.error_record.error_message);
         rcv_error_pkg.set_token('ITEM', x_item_id_record.item_num);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_item_id_record.error_record.error_status   := rcv_error_pkg.g_ret_sts_unexp_error;
         rcv_error_pkg.set_sql_error_message('get_item_id', '000');
         x_item_id_record.error_record.error_message  := rcv_error_pkg.get_last_message;
   END get_item_id;

/*===========================================================================

  PROCEDURE NAME:   get_org_id()

  This call is done by EDI to obtain the org_id give the location id

===========================================================================*/
   PROCEDURE get_org_id_from_hr_loc_id(
      p_hr_location_id  IN            NUMBER,
      x_organization_id OUT NOCOPY    NUMBER
   ) IS
   BEGIN
      SELECT inventory_organization_id
      INTO   x_organization_id
      FROM   hr_locations
      WHERE  location_id = p_hr_location_id;
   EXCEPTION
      WHEN OTHERS THEN
         x_organization_id  := NULL;
   END get_org_id_from_hr_loc_id;
END rcv_rma_transactions;

/
