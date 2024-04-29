--------------------------------------------------------
--  DDL for Package Body INV_RCV_DIR_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_DIR_RCPT_APIS" AS
  /* $Header: INVDIRDB.pls 120.8.12010000.13 2012/06/15 05:20:51 jianpyu ship $*/

  --Variable to store interface_transaction_id for lot and serial splits
  g_interface_transaction_id  NUMBER;

  PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER DEFAULT 4) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => 'INV_RCV_DIR_RCPT_APIS', p_level => p_level);
    END IF;
  END print_debug;

  PROCEDURE populate_default_values(
    p_rcv_transaction_rec  IN OUT NOCOPY  inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp
  , p_rcv_rcpt_rec         IN OUT NOCOPY  inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp
  , p_group_id             IN             NUMBER
  , p_organization_id      IN             NUMBER
  , p_item_id              IN             NUMBER
  , p_revision             IN             VARCHAR2
  , p_source_type          IN             VARCHAR2
  , p_subinventory_code    IN             VARCHAR2
  , p_locator_id           IN             NUMBER
  , p_transaction_temp_id  IN             NUMBER
  , p_lot_control_code     IN             NUMBER
  , p_serial_control_code  IN             NUMBER
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL
  , p_express_transaction  IN             VARCHAR2  DEFAULT NULL--Bug 5550783
  ) IS
    l_interface_transaction_id  NUMBER;
    -- this is used to keep track of the id used to insert the row in rti

    l_lot_serial_break_tbl      inv_rcv_common_apis.trans_rec_tb_tp;
    -- table that will store the record into which the lot/serial entered
    -- have to be broken.

    --     l_transaction_type VARCHAR2(20) := 'DELIVER';
         -- I thought till 07/16/2000 that this should be deliver, but seems
         -- that it should actually be receive.
    l_transaction_type          VARCHAR2(20) := 'RECEIVE';
    l_valid_ship_to_location    BOOLEAN;
    l_valid_deliver_to_location BOOLEAN;
    l_valid_deliver_to_person   BOOLEAN;
    l_valid_subinventory        BOOLEAN;
    l_debug                     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    --Bug 5550783 start
     IF (l_debug = 1) THEN
       print_debug('populate_default_values: p_express_transaction= ' ||p_express_transaction , 4);
     END IF;
    --Bug 5550783 end

    IF (l_debug = 1) THEN
      print_debug('Enter populate_default_values: 1   ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    --validate deliver to info
    IF (l_debug = 1) THEN
      print_debug('populate_default_values 20: ', 4);
    END IF;

    rcv_transactions_sv.val_destination_info(
      p_organization_id
    , p_item_id
    , NULL
    , p_rcv_rcpt_rec.deliver_to_location_id
    , p_rcv_rcpt_rec.deliver_to_person_id
    , p_rcv_rcpt_rec.destination_subinventory
    , l_valid_ship_to_location
    , l_valid_deliver_to_location
    , l_valid_deliver_to_person
    , l_valid_subinventory
    );

    IF (l_debug = 1) THEN
      print_debug('populate_default_values: 30 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    -- since user fill in deliver to subinventory and locator, and they are validated through LOV
    -- we dont need to validate or default them here as receiving does.

    IF l_valid_deliver_to_person THEN
      p_rcv_transaction_rec.deliver_to_person_id := p_rcv_rcpt_rec.deliver_to_person_id;
    END IF;

    IF l_valid_deliver_to_location THEN
      p_rcv_transaction_rec.deliver_to_location_id := p_rcv_rcpt_rec.deliver_to_location_id;
    END IF;

    p_rcv_transaction_rec.destination_subinventory := p_subinventory_code;
    p_rcv_transaction_rec.locator_id := p_locator_id;
    -- revision should be passed into matching logic

    p_rcv_transaction_rec.item_revision := p_revision;
    p_rcv_rcpt_rec.item_revision := p_revision;

    IF (l_debug = 1) THEN
      print_debug(
        'populate_default_values: 3 - before inv_rcv_std_rcpt_apis.insert_txn_interface  '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    l_interface_transaction_id :=
      inv_rcv_std_rcpt_apis.insert_txn_interface(
        p_rcv_transaction_rec
      , p_rcv_rcpt_rec
      , p_group_id
      , l_transaction_type
      , p_organization_id
      , p_rcv_transaction_rec.deliver_to_location_id
      , p_source_type
      , NULL
      , p_project_id
      , p_task_id
      , p_express_transaction--Bug 5550783
      );
    --Store the interface_transaction_id in a global variable
    g_interface_transaction_id := l_interface_transaction_id;

    IF (l_debug = 1) THEN
      print_debug(
        'populate_default_values: 4 - after inv_rcv_std_rcpt_apis.insert_txn_interface  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
      print_debug('populate_default_values: 4.1 -  l_interface_transaction_id = ' || l_interface_transaction_id, 4);
    END IF;

    /* FP-J Lot/Serial Support Enhancement
     * If INV J and PO J are installed then lot and serial splits are done based
     * on the interface tables (MTLI/MSNI).
     * If either of these are not installed, use the existing logic to break
     * lots and serials based on temp records MTLI/MSNT
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN

      l_lot_serial_break_tbl(1).transaction_id := l_interface_transaction_id;
      l_lot_serial_break_tbl(1).primary_quantity := p_rcv_transaction_rec.primary_quantity;

      IF (l_debug = 1) THEN
        print_debug(
          'populate_default_values: 5 - before inv_rcv_std_deliver_apis.insert_lot_serial  '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4
        );
      END IF;

      inv_rcv_std_deliver_apis.insert_lot_serial(
            l_lot_serial_break_tbl
          , p_transaction_temp_id
          , p_lot_control_code
          , p_serial_control_code
          , l_interface_transaction_id);
    ELSE
      IF (l_debug = 1) THEN
        print_debug('INV J and PO J are installed. Splitting of lots and serials through interface, not temp tables', 4);
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug(
           'About exit populate_default_values: 6 - after inv_rcv_std_deliver_apis.insert_lot_serial  '
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;
  END populate_default_values;

  /** Bug #4147209 -
    * New procedure added to populate the attribute_category
    * and attributes 1-15 columns of the enter receipts record type
    * with the values passed from the Mobile Receipt UI
    */
  PROCEDURE set_attribute_vals (
      p_rcv_rcpt_rec         IN OUT NOCOPY  inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp
    , p_attribute_category   IN             VARCHAR2  DEFAULT NULL
    , p_attribute1           IN             VARCHAR2  DEFAULT NULL
    , p_attribute2           IN             VARCHAR2  DEFAULT NULL
    , p_attribute3           IN             VARCHAR2  DEFAULT NULL
    , p_attribute4           IN             VARCHAR2  DEFAULT NULL
    , p_attribute5           IN             VARCHAR2  DEFAULT NULL
    , p_attribute6           IN             VARCHAR2  DEFAULT NULL
    , p_attribute7           IN             VARCHAR2  DEFAULT NULL
    , p_attribute8           IN             VARCHAR2  DEFAULT NULL
    , p_attribute9           IN             VARCHAR2  DEFAULT NULL
    , p_attribute10          IN             VARCHAR2  DEFAULT NULL
    , p_attribute11          IN             VARCHAR2  DEFAULT NULL
    , p_attribute12          IN             VARCHAR2  DEFAULT NULL
    , p_attribute13          IN             VARCHAR2  DEFAULT NULL
    , p_attribute14          IN             VARCHAR2  DEFAULT NULL
    , p_attribute15          IN             VARCHAR2  DEFAULT NULL) IS
  BEGIN
    p_rcv_rcpt_rec.attribute_category := p_attribute_category;
    p_rcv_rcpt_rec.attribute1         := p_attribute1;
    p_rcv_rcpt_rec.attribute2         := p_attribute2;
    p_rcv_rcpt_rec.attribute3         := p_attribute3;
    p_rcv_rcpt_rec.attribute4         := p_attribute4;
    p_rcv_rcpt_rec.attribute5         := p_attribute5;
    p_rcv_rcpt_rec.attribute6         := p_attribute6;
    p_rcv_rcpt_rec.attribute7         := p_attribute7;
    p_rcv_rcpt_rec.attribute8         := p_attribute8;
    p_rcv_rcpt_rec.attribute9         := p_attribute9;
    p_rcv_rcpt_rec.attribute10        := p_attribute10;
    p_rcv_rcpt_rec.attribute11        := p_attribute11;
    p_rcv_rcpt_rec.attribute12        := p_attribute12;
    p_rcv_rcpt_rec.attribute13        := p_attribute13;
    p_rcv_rcpt_rec.attribute14        := p_attribute14;
    p_rcv_rcpt_rec.attribute15        := p_attribute15;
  END set_attribute_vals;

  PROCEDURE create_osp_drct_dlvr_rti_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_po_release_id         IN             NUMBER
  , p_po_line_id            IN             NUMBER
  , p_po_line_location_id   IN             NUMBER
  , p_po_distribution_id    IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_transaction_temp_id   IN             NUMBER
  , p_revision              IN             VARCHAR2
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - DFF cols
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
) IS
    l_rcpt_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec     inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block
    l_transaction_type        VARCHAR2(20) := 'DELIVER';
    l_total_primary_qty       NUMBER       := 0;
    l_msg_count               NUMBER;
    l_return_status           VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                NUMBER;
    l_rcv_rcpt_rec            inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
    l_err_message             VARCHAR2(100);
    l_temp_message            VARCHAR2(100);
    l_msg_prod                VARCHAR2(5);
    l_progress                VARCHAR2(10);

    CURSOR l_curs_rcpt_detail(v_po_distribution_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'VENDOR' source_type_code
           , 'VENDOR' receipt_source_code
           , 'PO' order_type_code
           , '' order_type
           , poll.po_header_id po_header_id
           , poh.segment1 po_number
           , poll.po_line_id po_line_id
           , pol.line_num po_line_number
           , poll.line_location_id po_line_location_id
           , poll.shipment_num po_shipment_number
           , poll.po_release_id po_release_id
           , por.release_num po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
           --Passing as NULL for the columns for which values are not known. --Bug #3878174
           , TO_NUMBER(NULL) rcv_shipment_header_id
           , NULL rcv_shipment_number
           , TO_NUMBER(NULL) rcv_shipment_line_id
           , TO_NUMBER(NULL) rcv_line_number
           , TO_NUMBER(NULL) from_organization_id
/*
           , poh.po_header_id rcv_shipment_header_id
           , poh.segment1 rcv_shipment_number
           , pol.po_line_id rcv_shipment_line_id
           , pol.line_num rcv_line_number
           , poh.po_header_id from_organization_id
*/
           , poll.ship_to_organization_id to_organization_id
           , poh.vendor_id vendor_id
           , '' SOURCE
           , poh.vendor_site_id vendor_site_id
           , '' outside_operation_flag
           , pol.item_id item_id
           , NULL uom_code
--         , pol.unit_meas_lookup_code primary_uom
	   , msi.primary_unit_of_measure primary_uom /* Bug 5665041:Primary UOM should be taken from MSI*/
           , mum.uom_class primary_uom_class
           , NULL item_allowed_units_lookup_code
           , NULL item_locator_control
           , '' restrict_locators_code
           , '' restrict_subinventories_code
           , NULL shelf_life_code
           , NULL shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , NULL item_number
           , pol.item_revision item_revision
           , pol.item_description item_description
           , pol.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , pol.vendor_product_num vendor_item_number
           , poll.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , NULL packing_slip
           , poll.receiving_routing_id routing_id
           , '' routing_name
           , poll.need_by_date need_by_date
           , NVL(poll.promised_date, poll.need_by_date) expected_receipt_date
           , poll.quantity ordered_qty
           , pol.unit_meas_lookup_code ordered_uom
           , NULL ussgl_transaction_code
           , poll.government_context government_context
           , poll.inspection_required_flag inspection_required_flag
           , poll.receipt_required_flag receipt_required_flag
           , poll.enforce_ship_to_location_code enforce_ship_to_location_code
           , NVL(poll.price_override, pol.unit_price) unit_price
           , poh.currency_code currency_code
           , poh.rate_type currency_conversion_type
           , poh.rate_date currency_conversion_date
           , poh.rate currency_conversion_rate
           , poh.note_to_receiver note_to_receiver
           , pod.destination_type_code destination_type_code
           , pod.deliver_to_person_id deliver_to_person_id
           , pod.deliver_to_location_id deliver_to_location_id
           , pod.destination_subinventory destination_subinventory
           , poll.attribute_category attribute_category
           , poll.attribute1 attribute1
           , poll.attribute2 attribute2
           , poll.attribute3 attribute3
           , poll.attribute4 attribute4
           , poll.attribute5 attribute5
           , poll.attribute6 attribute6
           , poll.attribute7 attribute7
           , poll.attribute8 attribute8
           , poll.attribute9 attribute9
           , poll.attribute10 attribute10
           , poll.attribute11 attribute11
           , poll.attribute12 attribute12
           , poll.attribute13 attribute13
           , poll.attribute14 attribute14
           , poll.attribute15 attribute15
           , poll.closed_code closed_code
           , NULL asn_type
           , NULL bill_of_lading
           , TO_DATE(NULL) shipped_date
           , NULL freight_carrier_code
           , NULL waybill_airbill_num
           , NULL freight_bill_num
           , NULL vendor_lot_num
           , NULL container_num
           , NULL truck_num
           , NULL bar_code_label
           , '' rate_type_display
           , poll.match_option match_option
           , poll.country_of_origin_code country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , pod.po_distribution_id
           , pod.quantity_ordered - pod.quantity_delivered qty_ordered
           , pod.wip_entity_id
           , pod.wip_operation_seq_num
           , pod.wip_resource_seq_num
           , pod.wip_repetitive_schedule_id
           , pod.wip_line_id
           , pod.bom_resource_id
           , '' destination_type
           , '' LOCATION
           , pod.rate currency_conversion_rate_pod
           , pod.rate_date currency_conversion_date_pod
           , pod.project_id project_id
           , pod.task_id task_id
           , pol.secondary_uom secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , pol.secondary_qty secondary_quantity --OPM Convergence
      FROM   po_headers poh
           , po_line_locations poll
           , po_lines pol
           , po_releases por
           , mtl_system_items msi
           , mtl_units_of_measure mum
           , po_distributions pod
      WHERE  pod.po_distribution_id = v_po_distribution_id
      AND    poh.po_header_id = poll.po_header_id
      AND    pol.po_line_id = poll.po_line_id
      AND    poll.po_release_id = por.po_release_id(+)
      AND    pod.line_location_id = poll.line_location_id
      AND    mum.unit_of_measure(+) = pol.unit_meas_lookup_code
      AND    NVL(msi.organization_id, poll.ship_to_organization_id) = poll.ship_to_organization_id
      AND    msi.inventory_item_id(+) = pol.item_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok      BOOLEAN;   --Return status of lot_serial_split API
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter create_osp_drct_dlvr_rti_rec: 1 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    SAVEPOINT crt_po_rti_sp;
    l_progress := '10';

    -- query po_startup_value
    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec: 2.1 - group_id created: ' || l_group_id, 4);
      END IF;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec: 2.2 - group_id stored already: ' || l_group_id, 4);
      END IF;
    END IF;

    l_progress := '30';
    OPEN l_curs_rcpt_detail(p_po_distribution_id);
    l_progress := '31';
    FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
    l_rcv_rcpt_rec.item_id := p_item_id;
    l_progress := '32';
    CLOSE l_curs_rcpt_detail;
    l_progress := '33';
    -- bug 2743146
    -- Make sure that the po_distribution passed does satisfy the tolerance
    -- limits by calling the matching algorithm for that.
    -- initialize input record for matching algorithm
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id :=
                                                                                                                   p_organization_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).GROUP_ID := l_group_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_header_id := l_rcv_rcpt_rec.po_header_id; --Added for bug 9525003
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_release_id := p_po_release_id;
    -- line id, line location id and distribution id will be passed only from the putaway api.
    -- line id however, can also be passed through the UI if the line number
    -- field is enabled on the UI.
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_id :=
                                                                                                           l_rcv_rcpt_rec.po_line_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_location_id :=
                                                                                                  l_rcv_rcpt_rec.po_line_location_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_distribution_id :=
                                                                                                                p_po_distribution_id;

    IF p_item_id IS NOT NULL THEN
      BEGIN
        SELECT primary_unit_of_measure
        INTO   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
        FROM   mtl_system_items
        WHERE  mtl_system_items.inventory_item_id = p_item_id
        AND    mtl_system_items.organization_id = p_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;

          IF (l_debug = 1) THEN
            print_debug('create_osp_drct_dlvr_rti_rec: 3 - get primary_unit_of_measure exception', 4);
          END IF;
      END;
    ELSE
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure := NULL;
    END IF;

    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).revision := p_revision;
    --inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;
    --inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?

    IF (l_debug = 1) THEN
      print_debug(
        'create_osp_drct_dlvr_rti_rec: 4 - before inv_rcv_txn_interface.matching_logic' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    l_progress := '40';
    inv_rcv_txn_interface.matching_logic(
      x_return_status          => x_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => x_message
    , x_cascaded_table         => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross
    , n                        => inv_rcv_std_rcpt_apis.g_receipt_detail_index
    , temp_cascaded_table      => l_rcpt_match_table_detail
    , p_receipt_num            => NULL
    , p_shipment_header_id     => NULL
    , p_lpn_id                 => NULL
    );

    IF (l_debug = 1) THEN
      print_debug(
        'create_osp_drct_dlvr_rti_rec: 5 - after inv_rcv_txn_interface.matching_logic' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    -- x_status is not successful if there is any execution error in matching.
    IF x_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
          'Exiting create_osp_drct_dlvr_rti_rec 60.2: Unexpect error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1
        );
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index ..(
                                                               inv_rcv_std_rcpt_apis.g_receipt_detail_index
                                                             + l_rcpt_match_table_detail.COUNT
                                                             - 1
                                                            ) LOOP
      IF l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- End bug fix 2743146


    l_progress := '60';
    l_rcv_transaction_rec.po_distribution_id := p_po_distribution_id;
    l_rcv_transaction_rec.transaction_qty := p_rcv_qty;
    l_rcv_transaction_rec.transaction_uom := p_rcv_uom;
    l_rcv_transaction_rec.primary_quantity :=
                 rcv_transactions_interface_sv.convert_into_correct_qty(p_rcv_qty, p_rcv_uom, p_item_id, l_rcv_rcpt_rec.primary_uom);
    l_rcv_transaction_rec.primary_uom := l_rcv_rcpt_rec.primary_uom;
    l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
    l_progress := '64';
    -- update following fields for po_distribution related values
    l_rcv_transaction_rec.currency_conversion_date := l_rcv_rcpt_rec.currency_conversion_date_pod;
    l_rcv_transaction_rec.currency_conversion_rate := l_rcv_rcpt_rec.currency_conversion_rate_pod;
    l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.qty_ordered;
    l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
    -- wip related fields
    l_rcv_transaction_rec.wip_entity_id := l_rcv_rcpt_rec.wip_entity_id;
    l_rcv_transaction_rec.wip_operation_seq_num := l_rcv_rcpt_rec.wip_operation_seq_num;
    l_rcv_transaction_rec.wip_resource_seq_num := l_rcv_rcpt_rec.wip_resource_seq_num;
    l_rcv_transaction_rec.wip_repetitive_schedule_id := l_rcv_rcpt_rec.wip_repetitive_schedule_id;
    l_rcv_transaction_rec.wip_line_id := l_rcv_rcpt_rec.wip_line_id;
    l_rcv_transaction_rec.bom_resource_id := l_rcv_rcpt_rec.bom_resource_id;

    --Bug #4147209 - Populate the record type with the DFF attribute category
    --and segment values passed from the mobile UI
    set_attribute_vals(
        p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
      , p_attribute_category  => p_attribute_category
      , p_attribute1          => p_attribute1
      , p_attribute2          => p_attribute2
      , p_attribute3          => p_attribute3
      , p_attribute4          => p_attribute4
      , p_attribute5          => p_attribute5
      , p_attribute6          => p_attribute6
      , p_attribute7          => p_attribute7
      , p_attribute8          => p_attribute8
      , p_attribute9          => p_attribute9
      , p_attribute10         => p_attribute10
      , p_attribute11         => p_attribute11
      , p_attribute12         => p_attribute12
      , p_attribute13         => p_attribute13
      , p_attribute14         => p_attribute14
      , p_attribute15         => p_attribute15);

    IF (l_debug = 1) THEN
      print_debug('create_osp_drct_dlvr_rti_rec: 8 - before populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    populate_default_values(
      p_rcv_transaction_rec     => l_rcv_transaction_rec
    , p_rcv_rcpt_rec            => l_rcv_rcpt_rec
    , p_group_id                => l_group_id
    , p_organization_id         => p_organization_id
    , p_item_id                 => p_item_id
    , p_revision                => p_revision
    , p_source_type             => p_source_type
    , p_subinventory_code       => NULL
    , p_locator_id              => NULL
    , p_transaction_temp_id     => p_transaction_temp_id
    , p_lot_control_code        => NULL
    , p_serial_control_code     => NULL
    );


    /* FP-J Lot/Serial Support Enhancement
     * Populate the table to store the information of the RTIs created and
     * split the lots and serials based on RTI quantity
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po )) THEN

      --BUG 3326408,3346758,3405320
      --If there are any serials confirmed from the UI for an item that is
      --lot controlled and serial control dynamic at SO issue,
      --do not NULL out serial_transaction_temp_id. In other cases,
      --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
      IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
          l_rcv_rcpt_rec.serial_number_control_code IN (1,6)) THEN
	      IF (l_debug = 1) THEN
	        print_debug('create_osp_drct_dlvr_rti_rec 8.6:
			      serial_control_code IS '||l_rcv_rcpt_rec.serial_number_control_code || ' , need TO NULL OUT mtli', 4);
	      END IF;
        BEGIN
          UPDATE mtl_transaction_lots_interface
	          SET  serial_transaction_temp_id = NULL
	          WHERE product_transaction_id = p_transaction_temp_id
	          AND   product_code = 'RCV';
	      EXCEPTION
	        WHEN OTHERS THEN
		        IF (l_debug = 1) THEN
		          print_debug('create_osp_drct_dlvr_rti_rec 8.7: Error nulling serial temp id OF MTLI', 4);
		      END IF;
	      END ;
      END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

      l_new_rti_info(1).orig_interface_trx_id := p_transaction_temp_id;
      l_new_rti_info(1).new_interface_trx_id := g_interface_transaction_id;
      l_new_rti_info(1).quantity := l_rcv_transaction_rec.transaction_qty;

      l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
      IF ( NOT l_split_lot_serial_ok) THEN
        IF (l_debug = 1) THEN
          print_debug('create_osp_drct_dlvr_rti_rec 8.1: Failure in split_lot_serial', 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec 8.2: Call split_lot_serial is OK', 4);
      END IF;
    END IF;


    IF (l_debug = 1) THEN
      print_debug('create_osp_drct_dlvr_rti_rec: 9 - after populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '65';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 18
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '70';
    -- Clear the Lot Rec
    inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;

    IF (l_debug = 1) THEN
      print_debug('Exiting create_osp_drct_dlvr_rti_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_dir_rcpt_apis.create_osp_drct_dlvr_rti_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_osp_drct_dlvr_rti_rec: OTHER exception : ' || SQLCODE || '  '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;
  END create_osp_drct_dlvr_rti_rec;

  PROCEDURE create_po_drct_dlvr_rti_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_po_release_id         IN             NUMBER
  , p_po_line_id            IN             NUMBER
  , p_po_line_location_id   IN             NUMBER
  , p_po_distribution_id    IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_subinventory                         VARCHAR2
  , p_locator_id                           NUMBER
  , p_transaction_temp_id   IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_serial_control_code   IN             NUMBER
  , p_lpn_id                IN             NUMBER
  , p_revision              IN             VARCHAR2
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_inv_item_id           IN             NUMBER
  , p_item_desc             IN             VARCHAR2
  , p_location_id           IN             NUMBER
  , p_is_expense            IN             VARCHAR2
  , p_project_id            IN             NUMBER
  , p_task_id               IN             NUMBER
  , p_country_code          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_rcv_qty     IN             NUMBER DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom           IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom_code      IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  ) IS
    l_rcpt_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec     inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block
    l_transaction_type        VARCHAR2(20) := 'DELIVER';
    l_total_primary_qty       NUMBER       := 0;
    l_msg_count               NUMBER;
    l_return_status           VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                NUMBER;
    l_rcv_rcpt_rec            inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
    --l_mmtt_rec mtl_material_transactions_temp%ROWTYPE;

    l_err_message             VARCHAR2(100);
    l_temp_message            VARCHAR2(100);
    l_msg_prod                VARCHAR2(5);
    l_progress                VARCHAR2(10);

    CURSOR l_curs_rcpt_detail(v_po_distribution_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'VENDOR' source_type_code
           , 'VENDOR' receipt_source_code
           , 'PO' order_type_code
           , '' order_type
           , poll.po_header_id po_header_id
           , poh.segment1 po_number
           , poll.po_line_id po_line_id
           , pol.line_num po_line_number
           , poll.line_location_id po_line_location_id
           , poll.shipment_num po_shipment_number
           , poll.po_release_id po_release_id
           , por.release_num po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
            --Passing as NULL for the columns for which values are not known. --Bug #3878174
           , TO_NUMBER(NULL)  rcv_shipment_header_id
           , NULL rcv_shipment_number
           , TO_NUMBER(NULL)  rcv_shipment_line_id
           , TO_NUMBER(NULL)  rcv_line_number
           , TO_NUMBER(NULL)  from_organization_id
/*
           , poh.po_header_id rcv_shipment_header_id
           , poh.segment1 rcv_shipment_number
           , pol.po_line_id rcv_shipment_line_id
           , pol.line_num rcv_line_number
           , poh.po_header_id from_organization_id
*/
           , poll.ship_to_organization_id to_organization_id
           , poh.vendor_id vendor_id
           , '' SOURCE
           , poh.vendor_site_id vendor_site_id
           , '' outside_operation_flag
           , pol.item_id item_id
           , -- Bug 2073164
             NULL uom_code
--         , pol.unit_meas_lookup_code primary_uom
	   , msi.primary_unit_of_measure primary_uom /* Bug 5665041:Primary UOM should be taken from MSI*/
           , mum.uom_class primary_uom_class
           , NULL item_allowed_units_lookup_code
           , NULL item_locator_control
           , '' restrict_locators_code
           , '' restrict_subinventories_code
           , NULL shelf_life_code
           , NULL shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , NULL item_number
           , pol.item_revision item_revision
           , pol.item_description item_description
           , pol.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , pol.vendor_product_num vendor_item_number
           , poll.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , NULL packing_slip
           , poll.receiving_routing_id routing_id
           , '' routing_name
           , poll.need_by_date need_by_date
           , NVL(poll.promised_date, poll.need_by_date) expected_receipt_date
           , poll.quantity ordered_qty
           , pol.unit_meas_lookup_code ordered_uom
           , NULL ussgl_transaction_code
           , poll.government_context government_context
           , poll.inspection_required_flag inspection_required_flag
           , poll.receipt_required_flag receipt_required_flag
           , poll.enforce_ship_to_location_code enforce_ship_to_location_code
           , NVL(poll.price_override, pol.unit_price) unit_price
           , poh.currency_code currency_code
           , poh.rate_type currency_conversion_type
           , poh.rate_date currency_conversion_date
           , poh.rate currency_conversion_rate
           , poh.note_to_receiver note_to_receiver
           , pod.destination_type_code destination_type_code
           , pod.deliver_to_person_id deliver_to_person_id
           , pod.deliver_to_location_id deliver_to_location_id
           , pod.destination_subinventory destination_subinventory
           , poll.attribute_category attribute_category
           , poll.attribute1 attribute1
           , poll.attribute2 attribute2
           , poll.attribute3 attribute3
           , poll.attribute4 attribute4
           , poll.attribute5 attribute5
           , poll.attribute6 attribute6
           , poll.attribute7 attribute7
           , poll.attribute8 attribute8
           , poll.attribute9 attribute9
           , poll.attribute10 attribute10
           , poll.attribute11 attribute11
           , poll.attribute12 attribute12
           , poll.attribute13 attribute13
           , poll.attribute14 attribute14
           , poll.attribute15 attribute15
           , poll.closed_code closed_code
           , NULL asn_type
           , NULL bill_of_lading
           , TO_DATE(NULL) shipped_date
           , NULL freight_carrier_code
           , NULL waybill_airbill_num
           , NULL freight_bill_num
           , NULL vendor_lot_num
           , NULL container_num
           , NULL truck_num
           , NULL bar_code_label
           , '' rate_type_display
           , poll.match_option match_option
           , poll.country_of_origin_code country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --POLL.NOTE_TO_RECEIVER PLL_NOTE_TO_RECEIVER,
             pod.po_distribution_id
           , pod.quantity_ordered - pod.quantity_delivered qty_ordered
           , pod.wip_entity_id
           , pod.wip_operation_seq_num
           , pod.wip_resource_seq_num
           , pod.wip_repetitive_schedule_id
           , pod.wip_line_id
           , pod.bom_resource_id
           , '' destination_type
           , '' LOCATION
           , pod.rate currency_conversion_rate_pod
           , pod.rate_date currency_conversion_date_pod
           , pod.project_id project_id
           , pod.task_id task_id
           , pol.secondary_uom secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , pol.secondary_qty secondary_quantity --OPM Convergence
      FROM   po_headers poh
           , po_line_locations poll
           , po_lines pol
           , po_releases por
           , mtl_system_items msi
           , mtl_units_of_measure mum
           , po_distributions pod
      WHERE  pod.po_distribution_id = v_po_distribution_id
      AND    poh.po_header_id = poll.po_header_id
      AND    pol.po_line_id = poll.po_line_id
      AND    poll.po_release_id = por.po_release_id(+)
      AND    pod.line_location_id = poll.line_location_id
      AND    mum.unit_of_measure(+) = pol.unit_meas_lookup_code
      AND    NVL(msi.organization_id, poll.ship_to_organization_id) = poll.ship_to_organization_id
      AND    msi.inventory_item_id(+) = pol.item_id
      AND    (p_project_id IS NULL
              OR(p_project_id = -9999
                 AND pod.project_id IS NULL) -- bug 2669021
              OR pod.project_id = p_project_id)
      AND    (p_task_id IS NULL
              OR pod.task_id = p_task_id);

    l_debug                   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok     BOOLEAN;   --Return status of lot_serial_split API
    l_msni_count              NUMBER := 0;
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter create_po_drct_dlvr_rti_rec: 1 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    SAVEPOINT crt_po_rti_sp;
    l_progress := '10';

    -- query po_startup_value
    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec: 2.1 - group_id created: ' || l_group_id, 4);
      END IF;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec: 2.2 - group_id stored already: ' || l_group_id, 4);
      END IF;
    END IF;

    l_progress := '30';
    -- initialize input record for matching algorithm
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;

    IF (l_debug = 1) THEN
      print_debug(
        'create_po_rcpt_intf_rec: 40-S - p_inv_item_id' || TO_CHAR(p_inv_item_id) || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    IF p_inv_item_id IS NOT NULL THEN -- p_item_id has substitute item id
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_inv_item_id;
    ELSE
      IF p_item_id IS NOT NULL THEN
        inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
      ELSE
        IF (l_debug = 1) THEN
          print_debug('create_po_rcpt_intf_rec: Item id is null - One time item', 4);
        END IF;

        inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := NULL;
        inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_desc := p_item_desc;
      END IF;
    END IF;

    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id :=
                                                                                                                   p_organization_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).GROUP_ID := l_group_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_header_id := p_po_header_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_release_id := p_po_release_id;
    -- line id, line location id and distribution id will be passed only from the putaway api.
    -- line id however, can also be passed through the UI if the line number
    -- field is enabled on the UI.
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_id := p_po_line_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_line_location_id :=
                                                                                                               p_po_line_location_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_distribution_id :=
                                                                                                                p_po_distribution_id;

    IF p_item_id IS NOT NULL THEN
      BEGIN
        SELECT primary_unit_of_measure
        INTO   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
        FROM   mtl_system_items
        WHERE  mtl_system_items.inventory_item_id = p_item_id
        AND    mtl_system_items.organization_id = p_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;

          IF (l_debug = 1) THEN
            print_debug('create_po_drct_dlvr_rti_rec: 3 - get primary_unit_of_measure exception', 4);
          END IF;
      END;
    ELSE
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure := NULL;
    END IF;

    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).revision := p_revision;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?

    IF (l_debug = 1) THEN
      print_debug(
        'create_po_drct_dlvr_rti_rec: 4 - before inv_rcv_txn_interface.matching_logic' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    l_progress := '40';
    inv_rcv_txn_interface.matching_logic(
      x_return_status          => x_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => x_message
    , x_cascaded_table         => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross
    , n                        => inv_rcv_std_rcpt_apis.g_receipt_detail_index
    , temp_cascaded_table      => l_rcpt_match_table_detail
    , p_receipt_num            => NULL
    , p_shipment_header_id     => NULL
    , p_lpn_id                 => NULL
    );

    IF (l_debug = 1) THEN
      print_debug('create_po_drct_dlvr_rti_rec: 5 - after inv_rcv_txn_interface.matching_logic'
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4);
    END IF;

    -- x_status is not successful if there is any execution error in matching.
    IF x_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('Exiting create_po_drct_dlvr_rti_rec 60.2: Unexpect error calling matching'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index ..(
                                                               inv_rcv_std_rcpt_apis.g_receipt_detail_index
                                                             + l_rcpt_match_table_detail.COUNT
                                                             - 1
                                                            ) LOOP
      IF l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI
    IF (l_debug = 1) THEN
      print_debug('create_po_drct_dlvr_rti_rec: 6 - start loop ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '60';

    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '62';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).po_distribution_id);
      l_progress := '64';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      -- Earlier item_id was filled with PO Line Item ID if the parameter p_inv_item_id
      -- is not null, so that matching logic finds shipments. Now, in order to actually
      -- insert RTI, replace item_id with a new value which is nothing but the substitute
      -- item.
      l_rcv_rcpt_rec.item_id := p_item_id;
      l_progress := '66';
      CLOSE l_curs_rcpt_detail;
      l_progress := '68';

      IF (l_debug = 1) THEN
        print_debug('create_po_rcvtxn_intf_rec found a match 60', 4);
        print_debug('Matching returned values 60.1 - distribution_id:'
          || l_rcpt_match_table_detail(match_result_count).po_distribution_id
        , 4);
        print_debug('Matching returned values 60.1 - transaction_quantity:'
          || l_rcpt_match_table_detail(match_result_count).quantity
        , 4);
        print_debug('Matching returned values 60.1 - transaction_uom:'
          || l_rcpt_match_table_detail(match_result_count).unit_of_measure
        , 4);
        print_debug('Matching returned values 60.1 - primary_quantity:'
          || l_rcpt_match_table_detail(match_result_count).primary_quantity
        , 4);
        print_debug(
          'Matching returned values 60.1 - primary_uom:' || l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure
        , 4
        );
      END IF;

      l_rcv_transaction_rec.po_distribution_id := l_rcpt_match_table_detail(match_result_count).po_distribution_id;
      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      /* OPM Convergence we dont base matching logic on secondary uom and secondary quantity.
       * Instead we calculate the secondary qty based on the ratio on which primary qty is split.
       */
      l_progress := '70';
      l_rcv_transaction_rec.secondary_uom := p_rcv_sec_uom;
      print_debug('create_po_drct_dlvr_rti_rec: sec_uom ' || p_rcv_sec_uom);
      l_rcv_transaction_rec.secondary_uom_code := p_rcv_sec_uom_code;
      print_debug('create_po_drct_dlvr_rti_rec: sec_uom_code ' || p_rcv_sec_uom_code);
      l_rcv_transaction_rec.secondary_quantity := (l_rcpt_match_table_detail(match_result_count).quantity/p_rcv_qty) * p_secondary_rcv_qty;
      print_debug('secondary quantity after matching logic qty is obtained is ' ||l_rcv_transaction_rec.secondary_quantity);

      -- Nested LPN changes. Populate p_lpn_id as NULL for patchset J and above
      IF inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po OR
         inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j OR
         inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN

         l_rcv_transaction_rec.lpn_id := p_lpn_id;
         l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      ELSE
        l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      END IF;

      -- update following fields for po_distribution related values
      l_rcv_transaction_rec.currency_conversion_date := l_rcv_rcpt_rec.currency_conversion_date_pod;
      l_rcv_transaction_rec.currency_conversion_rate := l_rcv_rcpt_rec.currency_conversion_rate_pod;
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.qty_ordered;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;

      -- wip related fields
      IF l_rcv_rcpt_rec.wip_entity_id > 0 THEN
        l_rcv_transaction_rec.wip_entity_id := l_rcv_rcpt_rec.wip_entity_id;
        l_rcv_transaction_rec.wip_operation_seq_num := l_rcv_rcpt_rec.wip_operation_seq_num;
        l_rcv_transaction_rec.wip_resource_seq_num := l_rcv_rcpt_rec.wip_resource_seq_num;
        l_rcv_transaction_rec.wip_repetitive_schedule_id := l_rcv_rcpt_rec.wip_repetitive_schedule_id;
        l_rcv_transaction_rec.wip_line_id := l_rcv_rcpt_rec.wip_line_id;
        l_rcv_transaction_rec.bom_resource_id := l_rcv_transaction_rec.bom_resource_id;
      -- there is getting actual values call for wip
      -- since they are not inserted in RTI, I am not calling it here
      -- the code is in
      -- rcv_transactions_sv.get_wip_info ()
      END IF;

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.country_of_origin_code := p_country_code;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec: 8 - before populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      -- Deliver_to_location_id is mandatory for Expense Items case
      -- So if no deliver_to_location_id is present in the distributions of po for Expense Items
      -- we will default it to the value passed from the mobile UI.

      IF inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po OR
         inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j OR
         inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
          NULL;
      ELSE
          if l_rcv_rcpt_rec.destination_type_code = 'EXPENSE' then
                    IF (l_debug = 1) THEN
                            print_debug('create_po_drct_dlvr_rti_rec: p_location_id ='|| p_location_id, 4);
                            print_debug('create_po_drct_dlvr_rti_rec: l_rcv_transaction_rec.deliver_to_location_id ='|| l_rcv_transaction_rec.deliver_to_location_id, 4);
                    END IF;
                  if l_rcv_transaction_rec.deliver_to_location_id is null and
                      p_location_id is not null then
                     l_rcv_transaction_rec.deliver_to_location_id := p_location_id;
                  End if;
          End if;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);


      populate_default_values(
        p_rcv_transaction_rec     => l_rcv_transaction_rec
      , p_rcv_rcpt_rec            => l_rcv_rcpt_rec
      , p_group_id                => l_group_id
      , p_organization_id         => p_organization_id
      , p_item_id                 => p_item_id
      , p_revision                => p_revision
      , p_source_type             => p_source_type
      , p_subinventory_code       => p_subinventory
      , p_locator_id              => p_locator_id
      , p_transaction_temp_id     => p_transaction_temp_id
      , p_lot_control_code        => p_lot_control_code
      , p_serial_control_code     => p_serial_control_code
      , p_project_id              => p_project_id
      , p_task_id                 => p_task_id
      );


      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
        /*OPM Convergence. Populate the calculated secondary quantity */
        l_new_rti_info(match_result_count).sec_qty := l_rcv_transaction_rec.secondary_quantity;

        IF (l_debug = 1) THEN
          print_debug('create_po_drct_dlvr_rti_rec: 8.5 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec: 9 - after populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress := '80';
    END LOOP;

    /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      --BUG 3326408,3346758,3405320
      --If there are any serials confirmed from the UI for an item that is
      --lot controlled and serial control dynamic at SO issue,
      --do not NULL out serial_transaction_temp_id. In other cases,
      --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
      IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
          l_rcv_rcpt_rec.serial_number_control_code IN(1,6)) THEN
	      IF (l_debug = 1) THEN
	        print_debug('create_po_drct_dlvr_rti_rec 9.6: serial_control_code IS 6, need TO NULL OUT mtli', 4);
	      END IF;
        BEGIN
          UPDATE mtl_transaction_lots_interface
	          SET  serial_transaction_temp_id = NULL
	          WHERE product_transaction_id = p_transaction_temp_id
	          AND   product_code = 'RCV';
	      EXCEPTION
	        WHEN OTHERS THEN
		        IF (l_debug = 1) THEN
		          print_debug('create_po_drct_dlvr_rti_rec 9.7: Error nulling serial temp id OF MTLI', 4);
		        END IF;
	      END ;
      END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

      l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
      IF ( NOT l_split_lot_serial_ok) THEN
        IF (l_debug = 1) THEN
          print_debug('create_po_drct_dlvr_rti_rec 10.1: Failure in split_lot_serial', 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec 10.2: Call split_lot_serial is OK', 4);
      END IF;
    END IF;   --END IF check INV J and PO J installed

    -- append index in input table where the line to be detailed needs to be inserted
    --inv_rcv_std_rcpt_apis.g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + inv_rcv_std_rcpt_apis.g_receipt_detail_index;

    l_progress := '90';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 18
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';
    -- Clear the Lot Rec
    inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;

    IF (l_debug = 1) THEN
      print_debug('Exiting create_po_drct_dlvr_rti_rec:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_po_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_dir_rcpt_apis.create_po_drct_dlvr_rti_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_po_drct_dlvr_rti_rec: OTHER exception : ' || SQLCODE || '  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;
  END create_po_drct_dlvr_rti_rec;

  PROCEDURE create_int_shp_dr_del_rti_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_shipment_header_id    IN             NUMBER
  , p_shipment_line_id      IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_subinventory                         VARCHAR2
  , p_locator_id                           NUMBER
  , p_transaction_temp_id   IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_serial_control_code   IN             NUMBER
  , p_from_lpn_id           IN             NUMBER
  , p_lpn_id                IN             NUMBER
  , p_revision              IN             VARCHAR2
  , p_project_id            IN             NUMBER DEFAULT NULL
  , p_task_id               IN             NUMBER DEFAULT NULL
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_country_code          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_rcv_qty     IN             NUMBER DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom           IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom_code      IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - DFF cols
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  ) IS
    l_rcpt_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec     inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block
    l_transaction_type        VARCHAR2(20) := 'DELIVER';
    l_total_primary_qty       NUMBER       := 0;
    l_msg_count               NUMBER;
    l_return_status           VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                NUMBER;
    l_rcv_rcpt_rec            inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
    l_mmtt_rec                mtl_material_transactions_temp%ROWTYPE;
    l_err_message             VARCHAR2(100);
    l_temp_message            VARCHAR2(100);
    l_msg_prod                VARCHAR2(5);
    l_progress                VARCHAR2(10);
    l_receipt_num             VARCHAR2(30);

	l_lot_number              VARCHAR2(80) := NULL ;--12596775

    CURSOR l_curs_rcpt_detail(v_shipment_line_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'INTERNAL' source_type_code
           , DECODE(rsl.source_document_code, 'INVENTORY', 'INVENTORY', 'REQ', 'INTERNAL ORDER') receipt_source_code
           , rsl.source_document_code order_type_code
           , '' order_type
           --Passing as NULL for the columns for which value is not known.  --Bug #3878174
           , TO_NUMBER(NULL) po_header_id
           , NULL po_number
           , TO_NUMBER(NULL) po_line_id
           , TO_NUMBER(NULL) po_line_number
           , TO_NUMBER(NULL) po_line_location_id
           , NULL po_shipment_number
           , TO_NUMBER(NULL) po_release_id
           , TO_NUMBER(NULL) po_release_number
/*
           , rsh.shipment_header_id po_header_id
           , rsh.shipment_num po_number
           , rsl.shipment_line_id po_line_id
           , rsl.line_num po_line_number
           , rsl.shipment_line_id po_line_location_id
           , rsl.line_num po_shipment_number
           , rsh.shipment_header_id po_release_id
           , rsh.shipment_header_id po_release_number
*/
           , porh.requisition_header_id req_header_id
           , porh.segment1 req_number
           , porl.requisition_line_id req_line_id
           , porl.line_num req_line
           , rsl.req_distribution_id req_distribution_id
           , rsl.shipment_header_id rcv_shipment_header_id
           , rsh.shipment_num rcv_shipment_number
           , rsl.shipment_line_id rcv_shipment_line_id
           , rsl.line_num rcv_line_number
           , rsl.from_organization_id from_organization_id
           , rsl.to_organization_id to_organization_id
           , rsl.shipment_line_id vendor_id
           , '' SOURCE
           , TO_NUMBER(NULL) vendor_site_id
           , 'N' outside_operation_flag
           , rsl.item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , rsl.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , DECODE(msi1.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_from
           , NULL item_number
           , rsl.item_revision item_revision
           , rsl.item_description item_description
           , rsl.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , rsl.vendor_item_num vendor_item_number
           , rsh.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , rsh.packing_slip packing_slip
           , rsl.routing_header_id routing_id
           , '' routing_name
           , porl.need_by_date need_by_date
           , rsh.expected_receipt_date expected_receipt_date
           , rsl.quantity_shipped ordered_qty
           , rsl.primary_unit_of_measure ordered_uom
           , rsh.ussgl_transaction_code ussgl_transaction_code
           , rsh.government_context government_context
           , NULL inspection_required_flag
           , NULL receipt_required_flag
           , NULL enforce_ship_to_location_code
           , TO_NUMBER(NULL) unit_price
           , NULL currency_code
           , NULL currency_conversion_type
           , TO_DATE(NULL) currency_conversion_date
           , TO_NUMBER(NULL) currency_conversion_rate
           , NULL note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       NOTE_TO_RECEIVER,
             rsl.destination_type_code destination_type_code
           , rsl.deliver_to_person_id deliver_to_person_id
           , rsl.deliver_to_location_id deliver_to_location_id
           , rsl.to_subinventory destination_subinventory
           , rsl.attribute_category attribute_category
           , rsl.attribute1 attribute1
           , rsl.attribute2 attribute2
           , rsl.attribute3 attribute3
           , rsl.attribute4 attribute4
           , rsl.attribute5 attribute5
           , rsl.attribute6 attribute6
           , rsl.attribute7 attribute7
           , rsl.attribute8 attribute8
           , rsl.attribute9 attribute9
           , rsl.attribute10 attribute10
           , rsl.attribute11 attribute11
           , rsl.attribute12 attribute12
           , rsl.attribute13 attribute13
           , rsl.attribute14 attribute14
           , rsl.attribute15 attribute15
           , 'OPEN' closed_code
           , NULL asn_type
           , rsh.bill_of_lading bill_of_lading
           , rsh.shipped_date shipped_date
           , rsh.freight_carrier_code freight_carrier_code
           , rsh.waybill_airbill_num waybill_airbill_num
           , rsh.freight_bill_number freight_bill_num
           , rsl.vendor_lot_num vendor_lot_num
           , rsl.container_num container_num
           , rsl.truck_num truck_num
           , rsl.bar_code_label bar_code_label
           , NULL rate_type_display
           , 'P' match_option
           , NULL country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
             NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , NULL project_id
           , NULL task_id
            , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence
      FROM   rcv_shipment_headers rsh
           , rcv_shipment_lines rsl
           , po_requisition_headers porh
           , po_requisition_lines porl
           , mtl_system_items msi
           , mtl_system_items msi1
           , mtl_units_of_measure mum
      WHERE  rsh.receipt_source_code <> 'VENDOR'
      AND    rsl.requisition_line_id = porl.requisition_line_id(+)
      AND    porl.requisition_header_id = porh.requisition_header_id(+)
      AND    rsh.shipment_header_id = rsl.shipment_header_id
      AND    mum.unit_of_measure(+) = rsl.unit_of_measure
      AND    msi.organization_id(+) = rsl.to_organization_id
      AND    msi.inventory_item_id(+) = rsl.item_id
      AND    msi1.organization_id(+) = rsl.from_organization_id
      AND    msi1.inventory_item_id(+) = rsl.item_id
      AND    rsl.shipment_line_id = v_shipment_line_id
      AND    (
              (
               rsl.source_document_code = 'REQ'
               AND EXISTS(
                    SELECT '1'
                    FROM   po_req_distributions_all prd
                    WHERE  prd.requisition_line_id = porl.requisition_line_id
                     AND
                           (
                            p_project_id IS NULL
                            OR(p_project_id = -9999
                               AND prd.project_id IS NULL)
                            OR -- bug 2669021
                               prd.project_id = p_project_id
                           )
                    AND    (p_task_id IS NULL
                            OR prd.task_id = p_task_id))
              )
              OR rsl.source_document_code <> 'REQ'
             );

-- 3441084 Requisition_line_id also needs to be joined in the above Query otherwise will do
-- a full scan on po_req_distributions_all which is not good.


    l_debug                   NUMBER  := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info            inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok     BOOLEAN;   --Return status of lot_serial_split API
    l_msni_count              NUMBER := 0;

    CURSOR l_curs_rcpt_lots_detail IS  -- 13972742
    SELECT lot_number, transaction_quantity
    FROM mtl_transaction_lots_interface
    WHERE product_transaction_id = p_transaction_temp_id ;
    end_loop NUMBER := 0;
    l_rcpt_lots l_curs_rcpt_lots_detail%ROWTYPE;
    l_transaction_quantity NUMBER;

  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter create_int_shp_dr_del_rti_rec: 1 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    SAVEPOINT crt_intship_rti_sp;

    -- query po_startup_value
    BEGIN
      /* Bug #2516729
       * Fetch rcv_shipment_headers.receipt_number for the given shipment_header_id.
       * If it exists , assign it to the global variable for receipt # (g_rcv_global_var.receipt_num)
       * in order that a new receipt # is not created everytime and the existing receipt # is used
       */
      BEGIN
        SELECT receipt_num
        INTO   l_receipt_num
        FROM   rcv_shipment_headers
        WHERE  shipment_header_id = p_shipment_header_id
        AND    ship_to_org_id = p_organization_id;

	--Bug 4552825 - Assign the value only if it is not null
	IF l_receipt_num IS NOT NULL THEN
	   inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
	END IF;

        IF (l_debug = 1) THEN
          print_debug('create_int_shp_dr_del_rti_rec: 10.1 ' || inv_rcv_common_apis.g_rcv_global_var.receipt_num, 1);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_receipt_num := NULL;
      END;

      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec: 2.1 - group_id created: ' || l_group_id, 4);
      END IF;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec: 2.2 - group_id stored already: ' || l_group_id, 4);
      END IF;
    END IF;
    /*	comment for bug 13972742
    --12596775
    IF NVL(p_lot_control_code ,1) = 2 THEN
      BEGIN

		 IF (l_debug = 1) THEN
 	         print_debug(' Fetching the Lot Number from MTLI ', 4);
 	     END IF;

        SELECT lot_number
          INTO l_lot_number
          FROM mtl_transaction_lots_interface
         WHERE product_transaction_id = p_transaction_temp_id ;

      EXCEPTION
       WHEN No_Data_Found THEN
         IF (l_debug = 1) THEN
           print_debug('create_int_shp_dr_del_rti_rec: No Lot records in MTLI for id :'||p_transaction_temp_id,4);
         END IF;
         l_lot_number :=NULL;
       WHEN too_many_rows THEN
         IF (l_debug = 1) THEN
           print_debug('create_int_shp_dr_del_rti_rec: More than one records in MTLI for id :'||p_transaction_temp_id,4);
         END IF;
         l_lot_number :=NULL; --For multiple lots dont input to matching logic
      END;
    END IF;

 	     IF (l_debug = 1) THEN
 	         print_debug('create_int_shp_dr_del_rti_rec: 2.2.1 lot_number: ' || l_lot_number, 4);
 	     END IF;
    --12596775
     */
    l_progress := '30';

     LOOP  --13972742
     l_lot_number := NULL;
     l_transaction_quantity:=p_rcv_qty;
     IF end_loop =1 THEN
       EXIT;
     ELSE
       IF NVL(p_lot_control_code ,1) = 1 THEN
          end_loop := 1;
       ELSE
          IF NOT l_curs_rcpt_lots_detail%ISOPEN   THEN
             OPEN  l_curs_rcpt_lots_detail;
          END IF;
          FETCH l_curs_rcpt_lots_detail INTO l_rcpt_lots;
          IF  l_curs_rcpt_lots_detail%NOTFOUND THEN
             IF end_loop =0 THEN
                end_loop :=1;
             else
                CLOSE l_curs_rcpt_lots_detail;
                EXIT;
             END IF;
          ELSE
             l_lot_number := l_rcpt_lots.lot_number;
             l_transaction_quantity := l_rcpt_lots.transaction_quantity;
             end_loop :=2;
          END if;
       END IF;
     END IF;
     IF (l_debug = 1) THEN
 	   print_debug('create_int_shp_dr_del_rti_rec: 2.2.1 lot_number: ' || l_lot_number, 4);
           print_debug('create_int_shp_dr_del_rti_rec: 2.2.1 l_transaction_quantity: ' || l_transaction_quantity, 4);
     END IF;

    -- initialize input record for matching algorithm
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := l_transaction_quantity;--13972742
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).GROUP_ID := l_group_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id :=
                                                                                                                   p_organization_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).shipment_header_id :=
                                                                                                                p_shipment_header_id;
    -- line id will be passed only from the putaway api.
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).shipment_line_id :=
                                                                                                                  p_shipment_line_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id    := p_task_id;
	inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).lot_number := l_lot_number;  --12596775

    BEGIN
      SELECT primary_unit_of_measure
      INTO   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          print_debug('create_int_shp_dr_del_rti_rec: 3 - get primary_unit_of_measure exception', 4);
        END IF;
    END;

    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?
    l_progress := '40';

    IF (l_debug = 1) THEN
      print_debug(
        'create_int_shp_dr_del_rti_rec: 4.0 - before inv_rcv_txn_interface.matching_logic'
        || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
      print_debug('create_int_shp_dr_del_rti_rec: 4.0 - p_from_lpn_id => '||p_from_lpn_id,4);
    END IF;
     l_rcpt_match_table_detail.DELETE; --13972742
    inv_rcv_txn_match.matching_logic(
      x_return_status         => x_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => x_message
    , x_cascaded_table        => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross
    , n                       => inv_rcv_std_rcpt_apis.g_receipt_detail_index
    , temp_cascaded_table     => l_rcpt_match_table_detail
    , p_receipt_num           => NULL
    , p_match_type            => 'INTRANSIT SHIPMENT'
    , p_lpn_id                => p_from_lpn_id --BUG 4613635 : pass
    						--from_lpn_id to matching_logic so that
						--the rsl with the correct asn_lpn_id
						--can be matched
    );

    IF (l_debug = 1) THEN
      print_debug(
        'create_int_shp_dr_del_rti_rec: 4  - after inv_rcv_txn_interface.matching_logic' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
      print_debug('create_int_shp_dr_del_rti_rec: 4.1 - after matching  l_return_status = ' || x_status, 4);
      print_debug('create_int_shp_dr_del_rti_rec: 4.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_int_shp_dr_del_rti_rec: 4.3 - after matching  l_msg_data = ' || x_message, 4);
    END IF;

    -- x_status is not successful if there is any execution error in matching.
    IF x_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec 60.2: Unexpect error calling matching'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index ..(
                                                               inv_rcv_std_rcpt_apis.g_receipt_detail_index
                                                             + l_rcpt_match_table_detail.COUNT
                                                             - 1
                                                            ) LOOP
      IF l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    l_progress := '50';

    IF (l_debug = 1) THEN
      print_debug('create_int_shp_dr_del_rti_rec: 90 - start loop ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_rcv_transaction_rec.rcv_shipment_line_id := l_rcv_rcpt_rec.rcv_shipment_line_id;
    -- loop through results returned by matching algorithm
    l_progress := '60';

    IF (l_debug = 1) THEN
      print_debug('create_int_shp_dr_del_rti_rec no recs matched by matching 95:' || l_rcpt_match_table_detail.COUNT, 4);
    END IF;

    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '62';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).shipment_line_id);
      l_progress := '64';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '66';
      CLOSE l_curs_rcpt_detail;
      l_progress := '68';

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec found a match 100', 4);
        print_debug('Matching returned values 100.1 - shipment_line_id:'
          || l_rcpt_match_table_detail(match_result_count).shipment_line_id
        , 4);
        print_debug('Matching returned values 100.1 - transaction_quantity:'
          || l_rcpt_match_table_detail(match_result_count).quantity
        , 4);
        print_debug('Matching returned values 100.1 - transaction_uom:'
          || l_rcpt_match_table_detail(match_result_count).unit_of_measure
        , 4);
        print_debug('Matching returned values 100.1 - primary_quantity:'
          || l_rcpt_match_table_detail(match_result_count).primary_quantity
        , 4);
        print_debug(
          'Matching returned values 100.1 - primary_uom:' || l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure
        , 4
        );
      END IF;

      l_rcv_transaction_rec.rcv_shipment_line_id := l_rcpt_match_table_detail(match_result_count).shipment_line_id;

      -- Get the transfer_cost_group_id from rcv_shipment_lines
      BEGIN
        SELECT cost_group_id
        INTO   l_rcv_transaction_rec.transfer_cost_group_id
        FROM   rcv_shipment_lines
        WHERE  shipment_line_id = l_rcv_transaction_rec.rcv_shipment_line_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('exception in getting transfer cost group id', 4);
          END IF;

          l_rcv_transaction_rec.transfer_cost_group_id := NULL;
      END;

      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      l_progress := '70';

      /* OPM Convergence we dont base matching logic on secondary uom and secondary quantity.
       * Instead we calculate the secondary qty based on the ratio on which primary qty is split.
       */
      l_progress := '70';
      l_rcv_transaction_rec.secondary_uom := p_rcv_sec_uom;
      print_debug('create_po_drct_dlvr_rti_rec: sec_uom ' || p_rcv_sec_uom);
      l_rcv_transaction_rec.secondary_uom_code := p_rcv_sec_uom_code;
      print_debug('create_po_drct_dlvr_rti_rec: sec_uom_code ' || p_rcv_sec_uom_code);
      l_rcv_transaction_rec.secondary_quantity := (l_rcpt_match_table_detail(match_result_count).quantity/p_rcv_qty) * p_secondary_rcv_qty;
      print_debug('secondary quantity after matching logic qty is obtained is ' ||l_rcv_transaction_rec.secondary_quantity);

      -- Nested LPN changes If FromLPN is not null and Patchset Level of INV,WMS,PO
      -- are at J then pass From_lpn_id as lpn_id otherwise use old code.
      --IF p_from_lpn_id IS NOT NULL
      IF inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po
         AND inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j
         AND inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j THEN
        l_rcv_transaction_rec.lpn_id := p_from_lpn_id;
      ELSE
        l_rcv_transaction_rec.lpn_id := p_lpn_id;
      END IF;

      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;

      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.country_of_origin_code := p_country_code;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec: 110 - before populate_default_values'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      populate_default_values(
        p_rcv_transaction_rec     => l_rcv_transaction_rec
      , p_rcv_rcpt_rec            => l_rcv_rcpt_rec
      , p_group_id                => l_group_id
      , p_organization_id         => p_organization_id
      , p_item_id                 => p_item_id
      , p_revision                => p_revision
      , p_source_type             => p_source_type
      , p_subinventory_code       => p_subinventory
      , p_locator_id              => p_locator_id
      , p_transaction_temp_id     => p_transaction_temp_id
      , p_lot_control_code        => p_lot_control_code
      , p_serial_control_code     => p_serial_control_code
      , p_project_id              => p_project_id
      , p_task_id                 => p_task_id
      );


      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
        IF (l_debug = 1) THEN
          print_debug('create_int_shp_dr_del_rti_rec: 115 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec: 120 - after populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      l_progress := '80';

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec: 125 - before update_rcv_serials_supply'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * No updates to rcv_serials_supply if INV J and PO J are installed
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
        IF l_rcv_rcpt_rec.req_line_id IS NOT NULL
           AND p_serial_control_code NOT IN(1, 6) THEN
          -- update rss for req
          inv_rcv_std_deliver_apis.update_rcv_serials_supply(
            x_return_status        => l_return_status
          , x_msg_count            => l_msg_count
          , x_msg_data             => x_message
          , p_shipment_line_id     => l_rcv_transaction_rec.rcv_shipment_line_id
          );
        END IF;

        IF (l_debug = 1) THEN
          print_debug('create_int_shp_dr_del_rti_rec: 127 - after update_rcv_serials_supply'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4);
        END IF;
      END IF;   --END IF PO J and INV J installed
       IF NVL(p_lot_control_code ,1) = 2 AND l_lot_number IS NOT NULL THEN   -- for 13972742
           l_new_rti_info(match_result_count).lot_number := l_rcpt_match_table_detail(match_result_count).lot_number;
           l_new_rti_info(match_result_count).quantity := l_rcpt_match_table_detail(match_result_count).quantity;
             IF (l_debug = 1) THEN
       		 print_debug('l_new_rti_info(match_result_count).lot_number='|| l_new_rti_info(match_result_count).lot_number, 4);
             END IF;
      END IF;
    END LOOP;

    /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      --BUG 3326408,3346758,3405320
      --If there are any serials confirmed from the UI for an item that is
      --lot controlled and serial control dynamic at SO issue,
      --do not NULL out serial_transaction_temp_id. In other cases,
      --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
      l_msni_count := 0;
      IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
          l_rcv_rcpt_rec.serial_number_control_code IN(1,6)) THEN
	      IF (l_debug = 1) THEN
	        print_debug('create_int_shp_dr_del_rti_rec 128.2: serial_control_code IS 6, need TO NULL OUT mtli', 4);
	      END IF;
	      BEGIN
          IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN
            SELECT count(1)
            INTO   l_msni_count
            FROM   mtl_serial_numbers_interface
            WHERE  product_transaction_id = p_transaction_temp_id
            AND    product_code = 'RCV';
          END IF;
          IF (l_msni_count = 0) THEN
            UPDATE mtl_transaction_lots_interface
	          SET  serial_transaction_temp_id = NULL
	          WHERE product_transaction_id = p_transaction_temp_id
	          AND   product_code = 'RCV';
          END IF;
	      EXCEPTION
	        WHEN OTHERS THEN
		        IF (l_debug = 1) THEN
		          print_debug('create_int_shp_dr_del_rti_rec 128.4: Error nulling serial temp id OF MTLI', 4);
		      END IF;
	      END ;
      END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

      l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
      IF ( NOT l_split_lot_serial_ok) THEN
        IF (l_debug = 1) THEN
          print_debug('create_int_shp_dr_del_rti_rec 129.1: Failure in split_lot_serial', 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec 128.2: Call split_lot_serial is OK', 4);
      END IF;
    END IF;   --END IF check INV J and PO J installed
    END LOOP; --- 13972742

    -- append index in input table where the line to be detailed needs to be inserted
    --inv_rcv_std_rcpt_apis.g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + inv_rcv_std_rcpt_apis.g_receipt_detail_index;
    l_progress := '90';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 61
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';
    -- Clear the Lot Rec
    inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;

    IF (l_debug = 1) THEN
      print_debug('About exit create_int_shp_dr_del_rti_rec: 130 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_intship_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_dir_rcpt_apis.create_int_shp_dr_del_rti_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_int_shp_dr_del_rti_rec;

  PROCEDURE create_rma_drct_dlvr_rti_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_oe_order_header_id    IN             NUMBER
  , p_oe_order_line_id      IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_subinventory                         VARCHAR2
  , p_locator_id                           NUMBER
  , p_transaction_temp_id   IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_serial_control_code   IN             NUMBER
  , p_lpn_id                IN             NUMBER
  , p_revision              IN             VARCHAR2
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_project_id            IN             NUMBER
  , p_task_id               IN             NUMBER
  , p_country_code          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_rcv_qty     IN             NUMBER DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom           IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom_code      IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - DFF cols
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  ) IS
    l_rcpt_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec     inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block
    l_transaction_type        VARCHAR2(20) := 'DELIVER';
    l_total_primary_qty       NUMBER       := 0;
    l_msg_count               NUMBER;
    l_return_status           VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                NUMBER;
    l_rcv_rcpt_rec            inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
    l_mmtt_rec                mtl_material_transactions_temp%ROWTYPE;
    l_err_message             VARCHAR2(100);
    l_temp_message            VARCHAR2(100);
    l_msg_prod                VARCHAR2(5);
    l_progress                VARCHAR2(10);

    CURSOR l_curs_rcpt_detail(v_oe_order_line_id NUMBER) IS
      SELECT 'N' line_chkbox
           , 'CUSTOMER' source_type_code
           , 'CUSTOMER' receipt_source_code
           , '' order_type_code
           , '' order_type
           , TO_NUMBER(NULL) po_header_id
           , NULL po_number
           , TO_NUMBER(NULL) po_line_id
           , TO_NUMBER(NULL) po_line_number
           , TO_NUMBER(NULL) po_line_location_id
           , TO_NUMBER(NULL) po_shipment_number
           , TO_NUMBER(NULL) po_release_id
           , TO_NUMBER(NULL) po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
           , TO_NUMBER(NULL) rcv_shipment_header_id
           , NULL rcv_shipment_number
           , TO_NUMBER(NULL) rcv_shipment_line_id
           , TO_NUMBER(NULL) rcv_line_number
           , NVL(oel.ship_to_org_id, oeh.ship_to_org_id) from_organization_id
           , NVL(oel.ship_from_org_id, oeh.ship_from_org_id) to_organization_id
           , TO_NUMBER(NULL) vendor_id
           , '' SOURCE
           , TO_NUMBER(NULL) vendor_site_id
           , NULL outside_operation_flag
           , oel.inventory_item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , mum.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , msi.segment1 item_number
           , oel.item_revision item_revision
           , msi.description item_description
           , TO_NUMBER(NULL) item_category_id
           , NULL hazard_class
           , NULL un_number
           , NULL vendor_item_number
           , oel.ship_from_org_id ship_to_location_id
           , '' ship_to_location
           , NULL packing_slip
           , TO_NUMBER(NULL) routing_id
           , NULL routing_name
           , oel.request_date need_by_date
           , NVL(oel.promise_date, oel.request_date) expected_receipt_date
           , oel.ordered_quantity ordered_qty
           , '' ordered_uom
           , NULL ussgl_transaction_code
           , NULL government_context
           , DECODE(msi.return_inspection_requirement, 1, 'Y', 'N') inspection_required_flag--bug 4700067
           , 'Y' receipt_required_flag
           , 'N' enforce_ship_to_location_code
           , oel.unit_selling_price unit_price
           , oeh.transactional_curr_code currency_code
           , oeh.conversion_type_code currency_conversion_type
           , oeh.conversion_rate_date currency_conversion_date
           , oeh.conversion_rate currency_conversion_rate
           , NULL note_to_receiver
           , NULL destination_type_code
           , oel.deliver_to_contact_id deliver_to_person_id
           , oel.deliver_to_org_id deliver_to_location_id
           , NULL destination_subinventory
           , oel.CONTEXT attribute_category
           , oel.attribute1 attribute1
           , oel.attribute2 attribute2
           , oel.attribute3 attribute3
           , oel.attribute4 attribute4
           , oel.attribute5 attribute5
           , oel.attribute6 attribute6
           , oel.attribute7 attribute7
           , oel.attribute8 attribute8
           , oel.attribute9 attribute9
           , oel.attribute10 attribute10
           , oel.attribute11 attribute11
           , oel.attribute12 attribute12
           , oel.attribute13 attribute13
           , oel.attribute14 attribute14
           , oel.attribute15 attribute15
           , NULL closed_code
           , NULL asn_type
           , NULL bill_of_lading
           , TO_DATE(NULL) shipped_date
           , NULL freight_carrier_code
           , NULL waybill_airbill_num
           , NULL freight_bill_num
           , NULL vendor_lot_num
           , NULL container_num
           , NULL truck_num
           , NULL bar_code_label
           , NULL rate_type_display
           , NULL match_option
           , NULL country_of_origin_code
           , oel.header_id oe_order_header_id
           , oeh.order_number oe_order_num
           , oel.line_id oe_order_line_id
           , oel.line_number oe_order_line_num
           , oel.sold_to_org_id customer_id
           , NVL(oel.ship_to_org_id, oeh.ship_to_org_id) customer_site_id
           , '' customer_item_num
           , '' pll_note_to_receiver
           , NULL po_distribution_id
           , NULL qty_ordered
           , NULL wip_entity_id
           , NULL wip_operation_seq_num
           , NULL wip_resource_seq_num
           , NULL wip_repetitive_schedule_id
           , NULL wip_line_id
           , NULL bom_resource_id
           , '' destination_type
           , '' LOCATION
           , NULL currency_conversion_rate_pod
           , NULL currency_conversion_date_pod
           , NULL project_id
           , NULL task_id
           , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence
      FROM   oe_order_lines_all oel
           , oe_order_headers_all oeh
           , mtl_system_items msi
           , mtl_units_of_measure mum
      WHERE  oel.line_category_code = 'RETURN'
      AND    oel.header_id = oeh.header_id
      AND    oel.inventory_item_id = msi.inventory_item_id
      AND    oel.ship_from_org_id = msi.organization_id
      AND    msi.primary_uom_code = mum.uom_code
      AND    oel.booked_flag = 'Y'
      AND    oel.ordered_quantity > NVL(oel.shipped_quantity, 0)
      AND    msi.mtl_transactions_enabled_flag = 'Y'
      AND    oel.line_id = v_oe_order_line_id
      AND    (p_project_id IS NULL
              OR(p_project_id = -9999
                 AND oel.project_id IS NULL)
              OR -- bug 2669021
                 oel.project_id = p_project_id)
      AND    (p_task_id IS NULL
              OR oel.task_id = p_task_id);

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info         inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok  BOOLEAN;   --Return status of lot_serial_split API
  BEGIN
    x_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter create_rma_drct_dlvr_rti_rec: 1 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress := '10';
    SAVEPOINT crt_rma_rti_sp;

    -- query po_startup_value
    BEGIN
      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE;
    END;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec: 2.1 - group_id created: ' || l_group_id, 4);
      END IF;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec: 2.2 - group_id stored already: ' || l_group_id, 4);
      END IF;
    END IF;

    -- initialize input record for matching algorithm
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).GROUP_ID := l_group_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id :=
                                                                                                                   p_organization_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).oe_order_header_id :=
                                                                                                                p_oe_order_header_id;
    -- line id will be passed only from the putaway api.
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).oe_order_line_id :=
                                                                                                                  p_oe_order_line_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id; --bug# 2794612
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id; --bug# 2794612

    BEGIN
      SELECT primary_unit_of_measure
      INTO   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          print_debug('create_rma_drct_dlvr_rti_rec: 3 - get primary_unit_of_measure exception', 4);
        END IF;
    END;

    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?
    l_progress := '40';

    IF (l_debug = 1) THEN
      print_debug(
        'create_rma_drct_dlvr_rti_rec: 4 - before inv_rcv_txn_interface.matching_logic' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
    END IF;

    inv_rcv_txn_match.matching_logic(
      x_return_status         => x_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => x_message
    , x_cascaded_table        => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross
    , n                       => inv_rcv_std_rcpt_apis.g_receipt_detail_index
    , temp_cascaded_table     => l_rcpt_match_table_detail
    , p_receipt_num           => NULL
    , p_match_type            => 'RMA'
    , p_lpn_id                => NULL
    );

    IF (l_debug = 1) THEN
      print_debug(
        'create_rma_drct_dlvr_rti_rec: 4  - after inv_rcv_txn_interface.matching_logic' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
      , 4
      );
      print_debug('create_rma_drct_dlvr_rti_rec: 4.1 - after matching  l_return_status = ' || x_status, 4);
      print_debug('create_rma_drct_dlvr_rti_rec: 4.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_rma_drct_dlvr_rti_rec: 4.3 - after matching  l_msg_data = ' || x_message, 4);
    END IF;

    -- x_status is not successful if there is any execution error in matching.
    IF x_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF x_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec 60.2: Unexpect error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index ..(
                                                               inv_rcv_std_rcpt_apis.g_receipt_detail_index
                                                             + l_rcpt_match_table_detail.COUNT
                                                             - 1
                                                            ) LOOP
      IF l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI

    IF (l_debug = 1) THEN
      print_debug('create_rma_drct_dlvr_rti_rec: 6 - start loop ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    -- loop through results returned by matching algorithm
    l_progress := '60';

    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '62';
      OPEN l_curs_rcpt_detail(l_rcpt_match_table_detail(match_result_count).oe_order_line_id);
      l_progress := '64';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '66';
      CLOSE l_curs_rcpt_detail;
      l_progress := '68';

      IF (l_debug = 1) THEN
        print_debug('create_int_shp_dr_del_rti_rec found a match 60', 4);
        print_debug('Matching returned values 60.1 - oe_order_line_id:'
          || l_rcpt_match_table_detail(match_result_count).oe_order_line_id
        , 4);
        print_debug('Matching returned values 60.1 - transaction_quantity:'
          || l_rcpt_match_table_detail(match_result_count).quantity
        , 4);
        print_debug('Matching returned values 60.1 - transaction_uom:'
          || l_rcpt_match_table_detail(match_result_count).unit_of_measure
        , 4);
        print_debug('Matching returned values 60.1 - primary_quantity:'
          || l_rcpt_match_table_detail(match_result_count).primary_quantity
        , 4);
        print_debug(
          'Matching returned values 60.1 - primary_uom:' || l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure
        , 4
        );
      END IF;

      l_rcv_transaction_rec.oe_order_line_id := l_rcpt_match_table_detail(match_result_count).oe_order_line_id;
      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      l_progress := '70';

      IF (l_debug = 1) THEN
         print_debug('In create_rma_drct_dlvr_rti_rec 7.1: p_rcv_qty'|| p_rcv_qty, 1);
         print_debug('In create_rma_drct_dlvr_rti_rec 7.2: l_rcpt_match_table_detail(match_result_count).quantity'|| l_rcpt_match_table_detail(match_result_count).quantity, 1);
         print_debug('In create_rma_drct_dlvr_rti_rec 7.3: p_secondary_rcv_qty'|| p_secondary_rcv_qty, 1);
         print_debug('In create_rma_drct_dlvr_rti_rec 7.4: p_rcv_sec_uom'|| p_rcv_sec_uom, 1);
         print_debug('In create_rma_drct_dlvr_rti_rec 7.5: p_rcv_sec_uom_code'|| p_rcv_sec_uom_code, 1);
      END IF;

      -- Forward port Bug 7604079
      -- Assign secondary quantity and uoms.
      l_rcv_transaction_rec.secondary_quantity := (l_rcpt_match_table_detail(match_result_count).quantity/p_rcv_qty) *  p_secondary_rcv_qty;
      l_rcv_transaction_rec.secondary_uom := p_rcv_sec_uom;
      l_rcv_transaction_rec.secondary_uom_code := p_rcv_sec_uom_code;

      IF (l_debug = 1) THEN
         print_debug('In create_rma_drct_dlvr_rti_rec 7.6: l_rcv_transaction_rec.secondary_quantity'|| l_rcv_transaction_rec.secondary_quantity, 1);
      END IF;

      -- Nested LPN changes. Populate p_lpn_id as NULL for patchset J and above
      IF inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po OR
         inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j OR
         inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN

         l_rcv_transaction_rec.lpn_id := p_lpn_id;
         l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      ELSE
        l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      END IF;


      IF p_country_code IS NOT NULL THEN
        l_rcv_rcpt_rec.country_of_origin_code := p_country_code;
      END IF;

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec: 8 - before populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      populate_default_values(
        p_rcv_transaction_rec     => l_rcv_transaction_rec
      , p_rcv_rcpt_rec            => l_rcv_rcpt_rec
      , p_group_id                => l_group_id
      , p_organization_id         => p_organization_id
      , p_item_id                 => p_item_id
      , p_revision                => p_revision
      , p_source_type             => p_source_type
      , p_subinventory_code       => p_subinventory
      , p_locator_id              => p_locator_id
      , p_transaction_temp_id     => p_transaction_temp_id
      , p_lot_control_code        => p_lot_control_code
      , p_serial_control_code     => p_serial_control_code
      , p_project_id              => p_project_id
      , p_task_id                 => p_task_id
      );


      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
        IF (l_debug = 1) THEN
          print_debug('create_rma_drct_dlvr_rti_rec: 115 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec: 9 - after populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;

      l_progress := '80';
    END LOOP;

    /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN

       l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
      IF ( NOT l_split_lot_serial_ok) THEN
        IF (l_debug = 1) THEN
          print_debug('create_rma_drct_dlvr_rti_rec 9.1: Failure in split_lot_serial', 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec 9.2: Call split_lot_serial is OK', 4);
      END IF;
    END IF;   --END IF check INV J and PO J installed

    -- append index in input table where the line to be detailed needs to be inserted
    --inv_rcv_std_rcpt_apis.g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + inv_rcv_std_rcpt_apis.g_receipt_detail_index;

    l_progress := '90';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 15
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '100';
    -- Clear the Lot Rec
    inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;

    IF (l_debug = 1) THEN
      print_debug('About exit create_rma_drct_dlvr_rti_rec: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_rma_drct_dlvr_rti_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_rma_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_dir_rcpt_apis.create_rma_drct_dlvr_rti_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_rma_drct_dlvr_rti_rec;

  PROCEDURE create_asn_con_dd_intf_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_shipment_header_id    IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_subinventory                         VARCHAR2
  , p_locator_id                           NUMBER
  , p_from_lpn_id           IN             NUMBER
  , p_lpn_id                IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_serial_control_code   IN             NUMBER
  , p_revision              IN             VARCHAR2
  , p_transaction_temp_id   IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_project_id            IN             NUMBER
  , p_task_id               IN             NUMBER
  , p_country_code          IN             VARCHAR2 DEFAULT NULL
  , p_item_desc             IN             VARCHAR2 DEFAULT NULL
  , p_secondary_rcv_qty     IN             NUMBER DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom           IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom_code      IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - DFF cols
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  , p_express_transaction   IN             VARCHAR2  DEFAULT NULL--Bug 5550783
  , p_location_id           IN             NUMBER    DEFAULT NULL  --Bug 13490287
  ) IS
    l_rcpt_match_table_detail inv_rcv_common_apis.cascaded_trans_tab_type; -- output for matching algorithm
    l_rcv_transaction_rec     inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp; -- rcv_transaction block
    l_transaction_type        VARCHAR2(20) := 'DELIVER';
    l_total_primary_qty       NUMBER       := 0;
    l_match_type              VARCHAR2(20);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(400);
    l_return_status           VARCHAR2(1)  := fnd_api.g_ret_sts_success;
    l_group_id                NUMBER;
    l_rcv_rcpt_rec            inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp;
    l_mmtt_rec                mtl_material_transactions_temp%ROWTYPE;
    l_err_message             VARCHAR2(100);
    l_temp_message            VARCHAR2(100);
    l_msg_prod                VARCHAR2(5);
    l_progress                VARCHAR2(10);
    l_receipt_num             VARCHAR2(30);
    l_lpn_id                  NUMBER := p_lpn_id;

    CURSOR l_curs_rcpt_detail(v_shipment_line_id NUMBER, v_po_distribution_id NUMBER) IS
      SELECT 'N' line_chkbox
           , p_source_type source_type_code
           , 'VENDOR' receipt_source_code
           , 'PO' order_type_code
           , '' order_type
           , poll.po_header_id po_header_id
           , poh.segment1 po_number
           , poll.po_line_id po_line_id
           , pol.line_num po_line_number
           , poll.line_location_id po_line_location_id
           , poll.shipment_num po_shipment_number
           , poll.po_release_id po_release_id
           , por.release_num po_release_number
           , TO_NUMBER(NULL) req_header_id
           , NULL req_number
           , TO_NUMBER(NULL) req_line_id
           , TO_NUMBER(NULL) req_line
           , TO_NUMBER(NULL) req_distribution_id
           , rsh.shipment_header_id rcv_shipment_header_id
           , rsh.shipment_num rcv_shipment_number
           , rsl.shipment_line_id rcv_shipment_line_id
           , rsl.line_num rcv_line_number
           , rsl.from_organization_id from_organization_id  --Bug #3878174
/*
           , NVL(rsl.from_organization_id, poh.po_header_id) from_organization_id
*/
           , rsl.to_organization_id to_organization_id
           , rsh.vendor_id vendor_id
           , '' SOURCE
           , poh.vendor_site_id vendor_site_id -- Bug 6403165
           , '' outside_operation_flag
           , rsl.item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , rsl.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , NULL item_rev_control_flag_from
           , NULL item_number
           , rsl.item_revision item_revision
           , rsl.item_description item_description
           , rsl.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , rsl.vendor_item_num vendor_item_number
           , rsl.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , rsl.packing_slip packing_slip
           , rsl.routing_header_id routing_id
           , '' routing_name
           , poll.need_by_date need_by_date
           , rsh.expected_receipt_date expected_receipt_date
           , poll.quantity ordered_qty
           , pol.unit_meas_lookup_code ordered_uom
           , rsl.ussgl_transaction_code ussgl_transaction_code
           , rsl.government_context government_context
           , poll.inspection_required_flag inspection_required_flag
           , poll.receipt_required_flag receipt_required_flag
           , poll.enforce_ship_to_location_code enforce_ship_to_location_code
           , NVL(poll.price_override, pol.unit_price) unit_price
           , poh.currency_code currency_code
           , poh.rate_type currency_conversion_type
           , poh.rate_date currency_conversion_date
           , poh.rate currency_conversion_rate
           , poh.note_to_receiver note_to_receiver
           , pod.destination_type_code destination_type_code
           , pod.deliver_to_person_id deliver_to_person_id
           , pod.deliver_to_location_id deliver_to_location_id
           , pod.destination_subinventory destination_subinventory
           , rsl.attribute_category attribute_category
           , rsl.attribute1 attribute1
           , rsl.attribute2 attribute2
           , rsl.attribute3 attribute3
           , rsl.attribute4 attribute4
           , rsl.attribute5 attribute5
           , rsl.attribute6 attribute6
           , rsl.attribute7 attribute7
           , rsl.attribute8 attribute8
           , rsl.attribute9 attribute9
           , rsl.attribute10 attribute10
           , rsl.attribute11 attribute11
           , rsl.attribute12 attribute12
           , rsl.attribute13 attribute13
           , rsl.attribute14 attribute14
           , rsl.attribute15 attribute15
           , poll.closed_code closed_code
           , rsh.asn_type asn_type
           , rsh.bill_of_lading bill_of_lading
           , rsh.shipped_date shipped_date
           , rsh.freight_carrier_code freight_carrier_code
           , rsh.waybill_airbill_num waybill_airbill_num
           , rsh.freight_bill_number freight_bill_num
           , rsl.vendor_lot_num vendor_lot_num
           , rsl.container_num container_num
           , rsl.truck_num truck_num
           , rsl.bar_code_label bar_code_label
           , '' rate_type_display
           , poll.match_option match_option
           , rsl.country_of_origin_code country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --POLL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
             pod.po_distribution_id po_distribution_id
           , pod.quantity_ordered - pod.quantity_delivered qty_ordered
           , pod.wip_entity_id wip_entity_id
           , pod.wip_operation_seq_num wip_operation_seq_num
           , pod.wip_resource_seq_num wip_resource_seq_num
           , pod.wip_repetitive_schedule_id wip_repetitive_schedule_id
           , pod.wip_line_id wip_line_id
           , pod.bom_resource_id bom_resource_id
           , '' destination_type
           , '' LOCATION
           , pod.rate currency_conversion_rate_pod
           , pod.rate_date currency_conversion_date_pod
           , pod.project_id project_id
           , pod.task_id task_id
           , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence
      FROM   rcv_shipment_lines rsl
           , rcv_shipment_headers rsh
           , po_headers poh
           , po_line_locations poll
           , po_lines pol
           , po_releases por
           , mtl_system_items msi
           , mtl_units_of_measure mum
           , po_distributions pod
      WHERE  pod.po_distribution_id = v_po_distribution_id
      AND    pod.line_location_id = poll.line_location_id
      AND    NVL(poll.approved_flag, 'N') = 'Y'
      AND    NVL(poll.cancel_flag, 'N') = 'N'
      AND    NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
      AND    poll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
      AND    poh.po_header_id = poll.po_header_id
      AND    pol.po_line_id = poll.po_line_id
      AND    poll.po_release_id = por.po_release_id(+)
      AND    mum.unit_of_measure(+) = rsl.unit_of_measure
      AND    NVL(msi.organization_id, rsl.to_organization_id) = rsl.to_organization_id
      AND    msi.inventory_item_id(+) = rsl.item_id
      AND    poll.line_location_id = rsl.po_line_location_id
      AND    rsl.shipment_header_id = rsh.shipment_header_id
      AND    rsh.asn_type IN('ASN', 'ASBN', 'LCM')    -- For LCM Project
      AND    rsl.shipment_line_status_code <> 'CANCELLED'
      AND    rsl.shipment_line_id = v_shipment_line_id
      AND    (p_project_id IS NULL
              OR(p_project_id = -9999
                 AND pod.project_id IS NULL)
              OR -- bug 2669021
                 pod.project_id = p_project_id)
      AND    (p_task_id IS NULL
              OR pod.task_id = p_task_id)
      UNION
      SELECT 'N' line_chkbox
           , 'INTERNAL' source_type_code
           , DECODE(rsl.source_document_code, 'INVENTORY', 'INVENTORY', 'REQ', 'INTERNAL ORDER') receipt_source_code
           , rsl.source_document_code order_type_code
           , '' order_type
           , rsh.shipment_header_id po_header_id
           , rsh.shipment_num po_number
           , rsl.shipment_line_id po_line_id
           , rsl.line_num po_line_number
           , rsl.shipment_line_id po_line_location_id
           , rsl.line_num po_shipment_number
           , rsh.shipment_header_id po_release_id
           , rsh.shipment_header_id po_release_number
           , porh.requisition_header_id req_header_id
           , porh.segment1 req_number
           , porl.requisition_line_id req_line_id
           , porl.line_num req_line
           , rsl.req_distribution_id req_distribution_id
           , rsl.shipment_header_id rcv_shipment_header_id
           , rsh.shipment_num rcv_shipment_number
           , rsl.shipment_line_id rcv_shipment_line_id
           , rsl.line_num rcv_line_number
           , rsl.from_organization_id from_organization_id
           , rsl.to_organization_id to_organization_id
           , rsl.shipment_line_id vendor_id
           , '' SOURCE
           , TO_NUMBER(NULL) vendor_site_id
           , 'N' outside_operation_flag
           , rsl.item_id item_id
           , -- Bug 2073164
             NULL uom_code
           , rsl.unit_of_measure primary_uom
           , mum.uom_class primary_uom_class
           , NVL(msi.allowed_units_lookup_code, 2) item_allowed_units_lookup_code
           , NVL(msi.location_control_code, 1) item_locator_control
           , DECODE(msi.restrict_locators_code, 1, 'Y', 'N') restrict_locators_code
           , DECODE(msi.restrict_subinventories_code, 1, 'Y', 'N') restrict_subinventories_code
           , NVL(msi.shelf_life_code, 1) shelf_life_code
           , NVL(msi.shelf_life_days, 0) shelf_life_days
           , msi.serial_number_control_code serial_number_control_code
           , msi.lot_control_code lot_control_code
           , DECODE(msi.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_to
           , DECODE(msi1.revision_qty_control_code, 1, 'N', 2, 'Y', 'N') item_rev_control_flag_from
           , NULL item_number
           , rsl.item_revision item_revision
           , rsl.item_description item_description
           , rsl.category_id item_category_id
           , '' hazard_class
           , '' un_number
           , rsl.vendor_item_num vendor_item_number
           , rsh.ship_to_location_id ship_to_location_id
           , '' ship_to_location
           , rsh.packing_slip packing_slip
           , rsl.routing_header_id routing_id
           , '' routing_name
           , porl.need_by_date need_by_date
           , rsh.expected_receipt_date expected_receipt_date
           , rsl.quantity_shipped ordered_qty
           , rsl.primary_unit_of_measure ordered_uom
           , rsh.ussgl_transaction_code ussgl_transaction_code
           , rsh.government_context government_context
           , NULL inspection_required_flag
           , NULL receipt_required_flag
           , NULL enforce_ship_to_location_code
           , TO_NUMBER(NULL) unit_price
           , NULL currency_code
           , NULL currency_conversion_type
           , TO_DATE(NULL) currency_conversion_date
           , TO_NUMBER(NULL) currency_conversion_rate
           , NULL note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       NOTE_TO_RECEIVER,
             rsl.destination_type_code destination_type_code
           , rsl.deliver_to_person_id deliver_to_person_id
           , rsl.deliver_to_location_id deliver_to_location_id
           , rsl.to_subinventory destination_subinventory
           , rsl.attribute_category attribute_category
           , rsl.attribute1 attribute1
           , rsl.attribute2 attribute2
           , rsl.attribute3 attribute3
           , rsl.attribute4 attribute4
           , rsl.attribute5 attribute5
           , rsl.attribute6 attribute6
           , rsl.attribute7 attribute7
           , rsl.attribute8 attribute8
           , rsl.attribute9 attribute9
           , rsl.attribute10 attribute10
           , rsl.attribute11 attribute11
           , rsl.attribute12 attribute12
           , rsl.attribute13 attribute13
           , rsl.attribute14 attribute14
           , rsl.attribute15 attribute15
           , 'OPEN' closed_code
           , NULL asn_type
           , rsh.bill_of_lading bill_of_lading
           , rsh.shipped_date shipped_date
           , rsh.freight_carrier_code freight_carrier_code
           , rsh.waybill_airbill_num waybill_airbill_num
           , rsh.freight_bill_number freight_bill_num
           , rsl.vendor_lot_num vendor_lot_num
           , rsl.container_num container_num
           , rsl.truck_num truck_num
           , rsl.bar_code_label bar_code_label
           , NULL rate_type_display
           , 'P' match_option
           , NULL country_of_origin_code
           , TO_NUMBER(NULL) oe_order_header_id
           , TO_NUMBER(NULL) oe_order_num
           , TO_NUMBER(NULL) oe_order_line_id
           , TO_NUMBER(NULL) oe_order_line_num
           , TO_NUMBER(NULL) customer_id
           , TO_NUMBER(NULL) customer_site_id
           , NULL customer_item_num
           , NULL pll_note_to_receiver
           , --PORL.NOTE_TO_RECEIVER       PLL_NOTE_TO_RECEIVER,
             TO_NUMBER(NULL) po_distribution_id
           , TO_NUMBER(NULL) qty_ordered
           , TO_NUMBER(NULL) wip_entity_id
           , TO_NUMBER(NULL) wip_operation_seq_num
           , TO_NUMBER(NULL) wip_resource_seq_num
           , TO_NUMBER(NULL) wip_repetitive_schedule_id
           , TO_NUMBER(NULL) wip_line_id
           , TO_NUMBER(NULL) bom_resource_id
           , '' destination_type
           , '' LOCATION
           , TO_NUMBER(NULL) currency_conversion_rate_pod
           , TO_DATE(NULL) currency_conversion_date_pod
           , TO_NUMBER(NULL) project_id
           , TO_NUMBER(NULL) task_id
         , NULL secondary_uom --OPM Convergence
           , NULL secondary_uom_code --OPM Convergence
           , NULL secondary_quantity --OPM Convergence
      FROM   rcv_shipment_headers rsh
           , rcv_shipment_lines rsl
           , po_requisition_headers porh
           , po_requisition_lines porl
           , mtl_system_items msi
           , mtl_system_items msi1
           , mtl_units_of_measure mum
      WHERE  rsh.receipt_source_code <> 'VENDOR'
      AND    rsl.requisition_line_id = porl.requisition_line_id(+)
      AND    porl.requisition_header_id = porh.requisition_header_id(+)
      AND    rsh.shipment_header_id = rsl.shipment_header_id
      AND    mum.unit_of_measure(+) = rsl.unit_of_measure
      AND    msi.organization_id(+) = rsl.to_organization_id
      AND    msi.inventory_item_id(+) = rsl.item_id
      AND    msi1.organization_id(+) = rsl.from_organization_id
      AND    msi1.inventory_item_id(+) = rsl.item_id
      AND    rsh.asn_type IS NULL
      AND    rsl.shipment_line_id = v_shipment_line_id
      AND    (
              (
               rsl.source_document_code = 'REQ'
               AND EXISTS(
                    SELECT '1'
                    FROM   po_req_distributions_all prd
                    WHERE  prd.requisition_line_id = porl.requisition_line_id
                      AND  (
                            p_project_id IS NULL
                            OR(p_project_id = -9999
                               AND prd.project_id IS NULL)
                            OR -- bug 2669021
                               prd.project_id = p_project_id
                           )
                    AND    (p_task_id IS NULL
                            OR prd.task_id = p_task_id))
              )
              OR rsl.source_document_code <> 'REQ'
             );

-- 3441084 Requisition_line_id also needs to be joined in the above Query otherwise will do
-- a full scan on po_req_distributions_all which is not good.

    l_debug  NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --table to store all RTId, quantity and original_rti_id for lot/serial splits
    l_new_rti_info         inv_rcv_integration_apis.child_rec_tb_tp;
    l_split_lot_serial_ok  BOOLEAN;   --Return status of lot_serial_split API
    l_msni_count           NUMBER := 0;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_asn_con_dd_intf_rec: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_move_order_header_id = ' || p_move_order_header_id, 4);
      print_debug('p_organization_id = ' || p_organization_id, 4);
      print_debug('p_shipment_header_id = ' || p_shipment_header_id, 4);
      print_debug('p_po_header_id = ' || p_po_header_id, 4);
      print_debug('p_item_id = ' || p_item_id, 4);
      print_debug('p_rcv_qty = ' || p_rcv_qty, 4);
      print_debug('p_rcv_uom = ' || p_rcv_uom, 4);
      print_debug('p_rcv_uom_code = ' || p_rcv_uom_code, 4);
      print_debug('p_source_type = ' || p_source_type, 4);
      print_debug('p_subinventory = ' || p_subinventory, 4);
      print_debug('p_locator_id = ' || p_locator_id, 4);
      print_debug('p_transaction_temp_id = ' || p_transaction_temp_id, 4);
      print_debug('p_from_lpn_id = ' || p_from_lpn_id, 4);
      print_debug('p_lpn_id = ' || p_lpn_id, 4);
      print_debug('p_lot_control_code = ' || p_lot_control_code, 4);
      print_debug('p_revision = ' || p_revision, 4);
      print_debug('p_project_id = ' || p_project_id, 4);
      print_debug('p_task_id = ' || p_task_id, 4);
    END IF;

    SAVEPOINT crt_asn_con_rti_sp;
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    -- query po_startup_value
    BEGIN
      /* Bug 2516729
       * Fetch rcv_shipment_headers.receipt_number for the given shipment_header_id.
       * If it exists , assign it to the global variable for receipt # (g_rcv_global_var.receipt_num)
       * in order that a new receipt # is not created everytime and the existing receipt # is used
       */
      BEGIN
        SELECT receipt_num
        INTO   l_receipt_num
        FROM   rcv_shipment_headers
        WHERE  shipment_header_id = p_shipment_header_id
        AND    ship_to_org_id = p_organization_id;

	--Bug 4552825 - Assign the value only if it is not null
	IF l_receipt_num IS NOT NULL THEN
	   inv_rcv_common_apis.g_rcv_global_var.receipt_num := l_receipt_num;
	END IF;

        IF (l_debug = 1) THEN
          print_debug('create_asn_con_dd_intf_rec: 10.1 ' || inv_rcv_common_apis.g_rcv_global_var.receipt_num, 1);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_receipt_num := NULL;
      END;

      inv_rcv_common_apis.init_startup_values(p_organization_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_RCV_PARAM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    -- default header level non-DB items in rcv_transaction block
    -- and default other values need to be insert into RTI

    IF (l_debug = 1) THEN
      print_debug('create_asn_con_dd_intf_rec: 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    l_progress := '20';

    -- default l_group_id ? clear group id after done
    IF inv_rcv_common_apis.g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
      INTO   l_group_id
      FROM   DUAL;

      inv_rcv_common_apis.g_rcv_global_var.interface_group_id := l_group_id;
    ELSE
      l_group_id := inv_rcv_common_apis.g_rcv_global_var.interface_group_id;
    END IF;

    l_progress := '30';
    -- call matching algorithm   ?

    -- initialize input record for matching algorithm
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).GROUP_ID := l_group_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).transaction_type := 'DELIVER';
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).quantity := p_rcv_qty;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).unit_of_measure := p_rcv_uom;

    IF p_item_id IS NOT NULL THEN
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
    ELSE
      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec: Item id is null - One time item', 4);
      END IF;

      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := NULL;
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_desc := p_item_desc;
    END IF;

    --inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).item_id := p_item_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).to_organization_id := p_organization_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).shipment_header_id := p_shipment_header_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).po_header_id := p_po_header_id;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).expected_receipt_date := SYSDATE; --?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).tax_amount := 0; -- ?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status := 'S'; -- ?
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).project_id := p_project_id; --BUG# 2794612
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).task_id := p_task_id; --BUG# 2794612
    l_progress := '60';

    IF p_item_id IS NOT NULL THEN
      SELECT primary_unit_of_measure
      INTO   inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure
      FROM   mtl_system_items
      WHERE  mtl_system_items.inventory_item_id = p_item_id
      AND    mtl_system_items.organization_id = p_organization_id;

      l_progress := '70';
    ELSE
      inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).primary_unit_of_measure := NULL;
      l_progress := '71';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('create_asn_con_dd_intf_rec: 30 before matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    IF p_source_type = 'ASN' THEN
      l_match_type := 'ASN';
    ELSIF p_source_type = 'LCM' THEN       -- For LCM Project
      l_match_type := 'LCM';              -- For LCM Project
    ELSE
      l_match_type := 'INTRANSIT SHIPMENT';

      -- Nested LPN changes
      -- Costgroup updates will be done by TM from patchset J

      IF inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po
         OR inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j
         OR inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
        BEGIN
          SELECT cost_group_id
          INTO   l_rcv_transaction_rec.cost_group_id
          FROM   wms_lpn_contents wlpnc
          WHERE  organization_id = p_organization_id
          AND    parent_lpn_id = p_lpn_id
          AND    wlpnc.inventory_item_id = p_item_id
          AND    EXISTS(SELECT 1
                        FROM   cst_cost_group_accounts
                        WHERE  organization_id = p_organization_id
                        AND    cost_group_id = wlpnc.cost_group_id);
        EXCEPTION
          WHEN OTHERS THEN
            l_rcv_transaction_rec.cost_group_id := NULL;
        END;

        IF l_rcv_transaction_rec.cost_group_id IS NULL THEN
          UPDATE wms_lpn_contents wlpnc
          SET cost_group_id = NULL
          WHERE  organization_id = p_organization_id
          AND    parent_lpn_id = p_lpn_id
          AND    wlpnc.inventory_item_id = p_item_id
          AND    NOT EXISTS(SELECT 1
                            FROM   cst_cost_group_accounts
                            WHERE  organization_id = p_organization_id
                            AND    cost_group_id = wlpnc.cost_group_id);
        END IF;
      END IF;
    END IF;

    -- bug 3213241
    IF inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po
      AND inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j
      AND inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j THEN
       l_lpn_id := p_from_lpn_id;
     ELSE
       l_lpn_id := p_lpn_id;
    END IF;

    inv_rcv_txn_match.matching_logic(
      x_return_status         => l_return_status
    , --?
      x_msg_count             => l_msg_count
    , x_msg_data              => l_msg_data
    , x_cascaded_table        => inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross
    , n                       => inv_rcv_std_rcpt_apis.g_receipt_detail_index
    , temp_cascaded_table     => l_rcpt_match_table_detail
    , p_receipt_num           => NULL
    , p_match_type            => l_match_type
    , p_lpn_id                => l_lpn_id
    );

    IF (l_debug = 1) THEN
      print_debug('create_asn_con_dd_intf_rec: 40 after matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      print_debug('create_asn_con_dd_intf_rec: 40.1 - after matching  l_return_status = ' || l_return_status, 4);
      print_debug('create_asn_con_dd_intf_rec: 40.2 - after matching  l_msg_count = ' || l_msg_count, 4);
      print_debug('create_asn_con_dd_intf_rec: 40.3 - after matching  l_msg_data = ' || l_msg_data, 4);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec 60.1: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_MATCH_ERROR');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec 60.2: Unexpect error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_status = 'E' THEN
      l_err_message := inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross(inv_rcv_std_rcpt_apis.g_receipt_detail_index).error_message;
      fnd_message.set_name('INV', l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec 70: error calling matching' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    l_err_message := '@@@';

    FOR i IN inv_rcv_std_rcpt_apis.g_receipt_detail_index ..(
                                                               inv_rcv_std_rcpt_apis.g_receipt_detail_index
                                                             + l_rcpt_match_table_detail.COUNT
                                                             - 1
                                                            ) LOOP
      IF (l_debug = 1) THEN
	 print_debug('Error Status:'||
		     l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index +1).error_status
		     , 4);
	 print_debug('Error Message:'||
		     l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index +1).error_message
		     , 4);
      END IF;

      IF l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_status = 'W' THEN
        x_status := 'W';
        l_temp_message := l_rcpt_match_table_detail(i - inv_rcv_std_rcpt_apis.g_receipt_detail_index + 1).error_message;

        IF l_temp_message IS NULL THEN
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          l_msg_prod := 'INV';
          EXIT;
        END IF;

        IF l_err_message = '@@@' THEN
          l_err_message := l_temp_message;
          l_msg_prod := 'INV';
        ELSIF l_temp_message <> l_err_message THEN
          l_msg_prod := 'INV';
          l_err_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
          EXIT;
        END IF;
      END IF;
    END LOOP;

    IF l_err_message <> '@@@' THEN
      fnd_message.set_name(l_msg_prod, l_err_message);
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec 80: adding tolerance message ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;

    -- load the matching algorithm result into input data structure


    -- based on return from matching algorithm,
    -- determine which line in rcv_transaction block to be inserted into RTI
    -- loop through results returned by matching algorithm
    FOR match_result_count IN 1 .. l_rcpt_match_table_detail.COUNT LOOP
      l_progress := '72';

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec 82: opening outer cursor for', 4);
        print_debug('shipment_line_id => ' || l_rcpt_match_table_detail(match_result_count).shipment_line_id, 4);
        print_debug('po_distribution_id => ' || l_rcpt_match_table_detail(match_result_count).po_distribution_id, 4);
      END IF;

      OPEN l_curs_rcpt_detail(
            l_rcpt_match_table_detail(match_result_count).shipment_line_id
          , l_rcpt_match_table_detail(match_result_count).po_distribution_id
                             );
      l_progress := '74';
      FETCH l_curs_rcpt_detail INTO l_rcv_rcpt_rec;
      l_progress := '76';
      CLOSE l_curs_rcpt_detail;
      l_progress := '78';
      l_rcv_transaction_rec.rcv_shipment_line_id := l_rcpt_match_table_detail(match_result_count).shipment_line_id;
      l_rcv_transaction_rec.po_distribution_id := l_rcpt_match_table_detail(match_result_count).po_distribution_id;

      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_con_dd_intf_rec: 90.1 - the '
          || match_result_count
          || 'th record of matching results - rcv_shipment_line_id = '
          || l_rcpt_match_table_detail(match_result_count).shipment_line_id
        , 4
        );
      END IF;

      -- update following fields from matching algorithm return value
      l_rcv_transaction_rec.transaction_qty := l_rcpt_match_table_detail(match_result_count).quantity;
      l_rcv_transaction_rec.transaction_uom := l_rcpt_match_table_detail(match_result_count).unit_of_measure;
      l_rcv_transaction_rec.primary_quantity := l_rcpt_match_table_detail(match_result_count).primary_quantity;
      l_rcv_transaction_rec.primary_uom := l_rcpt_match_table_detail(match_result_count).primary_unit_of_measure;

    --  Bug 13445129
      -- Assign secondary quantity and uoms.
      l_rcv_transaction_rec.secondary_quantity := (l_rcpt_match_table_detail(match_result_count).quantity/p_rcv_qty) *  p_secondary_rcv_qty;
      l_rcv_transaction_rec.secondary_uom := p_rcv_sec_uom;
      l_rcv_transaction_rec.secondary_uom_code := p_rcv_sec_uom_code;

      IF (l_debug = 1) THEN
         print_debug('In create_asn_con_dd_intf_rec 90.1.1: l_rcv_transaction_rec.secondary_quantity'|| l_rcv_transaction_rec.secondary_quantity, 1);
      END IF;
      --  end Bug 13445129

      -- Nested lpn changes.
      -- Pass From_lpn_id instead of p_lpn_id for creating confirm receipts.
      --IF p_from_lpn_id IS NOT NULL
      IF inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po
         AND inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j
         AND inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j THEN
        l_rcv_transaction_rec.lpn_id := p_from_lpn_id;
      ELSE
        l_rcv_transaction_rec.lpn_id := p_lpn_id;
      END IF;

      l_rcv_transaction_rec.transfer_lpn_id := p_lpn_id;
      -- update following fields for po_distribution related values
      l_rcv_transaction_rec.currency_conversion_date := l_rcv_rcpt_rec.currency_conversion_date_pod;
      l_rcv_transaction_rec.currency_conversion_rate := l_rcv_rcpt_rec.currency_conversion_rate_pod;
      -- following fileds can have distribution level values
      -- therefore they are set here instead of in the common insert code
      l_rcv_transaction_rec.ordered_qty := l_rcv_rcpt_rec.qty_ordered;
      --Bug 2073164
      l_rcv_rcpt_rec.uom_code := p_rcv_uom_code;
      l_total_primary_qty := l_total_primary_qty + l_rcv_transaction_rec.primary_quantity;
      -- l_rcv_transaction_rec.lpn_id := p_lpn_id;

      -- wip related fields
      IF l_rcv_rcpt_rec.wip_entity_id > 0 THEN
        l_rcv_transaction_rec.wip_entity_id := l_rcv_rcpt_rec.wip_entity_id;
        l_rcv_transaction_rec.wip_operation_seq_num := l_rcv_rcpt_rec.wip_operation_seq_num;
        l_rcv_transaction_rec.wip_resource_seq_num := l_rcv_rcpt_rec.wip_resource_seq_num;
        l_rcv_transaction_rec.wip_repetitive_schedule_id := l_rcv_rcpt_rec.wip_repetitive_schedule_id;
        l_rcv_transaction_rec.wip_line_id := l_rcv_rcpt_rec.wip_line_id;
        l_rcv_transaction_rec.bom_resource_id := l_rcv_transaction_rec.bom_resource_id;
      -- there is getting actual values call for wip
      -- since they are not inserted in RTI, I am not calling it here
      -- the code is in
      -- rcv_transactions_sv.get_wip_info ()
      END IF;

      /***Bug 13490287  */
      -- Deliver_to_location_id is mandatory for Expense Items case
      -- So if no deliver_to_location_id is present in the distributions of po for Expense Items
      -- we will default it to the value passed from the mobile UI.

      IF inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po OR
         inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j OR
         inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
          NULL;
      ELSE
          if l_rcv_rcpt_rec.destination_type_code = 'EXPENSE' then
                    IF (l_debug = 1) THEN
                            print_debug('create_asn_con_dd_intf_rec: p_location_id ='|| p_location_id, 4);
                            print_debug('create_asn_con_dd_intf_rec: l_rcv_transaction_rec.deliver_to_location_id ='|| l_rcv_transaction_rec.deliver_to_location_id, 4);
                    END IF;

                  if l_rcv_transaction_rec.deliver_to_location_id is null and
                      p_location_id is not null THEN
                     l_rcv_transaction_rec.deliver_to_location_id := p_location_id;
                  End if;
          End if;
      END IF;

      /***End Bug 13490287 */

      --Bug #4147209 - Populate the record type with the DFF attribute category
      --and segment values passed from the mobile UI
      set_attribute_vals(
          p_rcv_rcpt_rec        =>  l_rcv_rcpt_rec
        , p_attribute_category  => p_attribute_category
        , p_attribute1          => p_attribute1
        , p_attribute2          => p_attribute2
        , p_attribute3          => p_attribute3
        , p_attribute4          => p_attribute4
        , p_attribute5          => p_attribute5
        , p_attribute6          => p_attribute6
        , p_attribute7          => p_attribute7
        , p_attribute8          => p_attribute8
        , p_attribute9          => p_attribute9
        , p_attribute10         => p_attribute10
        , p_attribute11         => p_attribute11
        , p_attribute12         => p_attribute12
        , p_attribute13         => p_attribute13
        , p_attribute14         => p_attribute14
        , p_attribute15         => p_attribute15);

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec: 100 before populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress := '80';
      populate_default_values(
        p_rcv_transaction_rec     => l_rcv_transaction_rec
      , p_rcv_rcpt_rec            => l_rcv_rcpt_rec
      , p_group_id                => l_group_id
      , p_organization_id         => p_organization_id
      , p_item_id                 => p_item_id
      , p_revision                => p_revision
      , p_source_type             => p_source_type
      , p_subinventory_code       => p_subinventory
      , p_locator_id              => p_locator_id
      , p_transaction_temp_id     => p_transaction_temp_id
      , p_lot_control_code        => p_lot_control_code
      , p_serial_control_code     => p_serial_control_code
      , p_project_id              => p_project_id
      , p_task_id                 => p_task_id
      , p_express_transaction     => p_express_transaction--Bug 5550783
      );
      /* FP-J Lot/Serial Support Enhancement
       * Populate the table to store the information of the RTIs created used for
       * splitting the lots and serials based on RTI quantity
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
          (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
        l_new_rti_info(match_result_count).orig_interface_trx_id := p_transaction_temp_id;
        l_new_rti_info(match_result_count).new_interface_trx_id := g_interface_transaction_id;
        l_new_rti_info(match_result_count).quantity := l_rcv_transaction_rec.transaction_qty;
        IF (l_debug = 1) THEN
          print_debug('create_asn_con_dd_intf_rec: 105 - Populated the table for lot/serial split', 4);
        END IF;
      END IF;   --END IF populate the table to store RTI info that was just created

      l_progress := '90';

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec: 110 after populate_default_values' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;
    END LOOP;

    /* FP-J Lot/Serial Support Enhancement
     * Call the split_lot API to split the lots and serials inserted from the UI
     * based on the quantity of each RTI record
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
        (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN
      l_msni_count := 0;
	    --BUG 3326408,3346758,3405320
      --If there are any serials confirmed from the UI for an item that is
      --lot controlled and serial control dynamic at SO issue,
      --do not NULL out serial_transaction_temp_id. In other cases,
      --NULL OUT serial_temp_id so that split_lot_serial does not look at MSNI
      IF (l_rcv_rcpt_rec.lot_control_code = 2 AND
          l_rcv_rcpt_rec.serial_number_control_code IN (1,6)) THEN
	      IF (l_debug = 1) THEN
	        print_debug('create_asn_con_dd_intf_rec 110.2: serial_control_code IS 6, need TO NULL OUT mtli', 4);
	      END IF;

	      BEGIN
          IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN
            SELECT count(1)
            INTO   l_msni_count
            FROM   mtl_serial_numbers_interface
            WHERE  product_transaction_id = p_transaction_temp_id
            AND    product_code = 'RCV';
          END IF;

          IF l_msni_count = 0 THEN
            UPDATE mtl_transaction_lots_interface
	          SET  serial_transaction_temp_id = NULL
	          WHERE product_transaction_id = p_transaction_temp_id
	          AND   product_code = 'RCV';
          END IF;
	      EXCEPTION
	        WHEN OTHERS THEN
		        IF (l_debug = 1) THEN
		          print_debug('create_asn_con_dd_intf_rec 110.4: Error nulling serial temp id OF MTLI', 4);
		        END IF;
	      END ;
      END IF;--IF (l_rcv_rcpt_rec.serial_number_control_code = 6) THEN

      l_split_lot_serial_ok := inv_rcv_integration_apis.split_lot_serial(
              p_api_version   => 1.0
            , p_init_msg_lst  => FND_API.G_FALSE
            , x_return_status =>  l_return_status
            , x_msg_count     =>  l_msg_count
            , x_msg_data      =>  x_message
            , p_new_rti_info  =>  l_new_rti_info);
      IF ( NOT l_split_lot_serial_ok) THEN
        IF (l_debug = 1) THEN
          print_debug('create_asn_con_dd_intf_rec 115.1: Failure in split_lot_serial', 4);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec 115.2: Call split_lot_serial is OK', 4);
      END IF;
    END IF;   --END IF check INV J and PO J installed

    IF l_curs_rcpt_detail%ISOPEN THEN
      CLOSE l_curs_rcpt_detail;
    END IF;

    -- append index in input table where the line to be detailed needs to be inserted
    --g_receipt_detail_index := l_rcpt_match_table_detail.COUNT + g_receipt_detail_index;

    -- UPDATE lpn context
    l_progress := '100';

    -- Nested LPN changes
    IF inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po
       OR inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j
       OR inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
      UPDATE wms_license_plate_numbers
      SET lpn_context = 3
      WHERE  lpn_id = p_lpn_id;
    END IF;

    l_progress := '110';
    l_progress := '120';
    inv_rcv_common_apis.do_check(
      p_organization_id         => p_organization_id
    , p_inventory_item_id       => p_item_id
    , p_transaction_type_id     => 18
    , p_primary_quantity        => l_total_primary_qty
    , x_return_status           => l_return_status
    , x_msg_count               => l_msg_count
    , x_msg_data                => x_message
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '130';

    -- Calling The ASN Discrepnacy  Details
    IF (l_debug = 1) THEN
      print_debug('Before Calling ASN Ddetails ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    inv_cr_asn_details.create_asn_details(
      p_organization_id
    , l_group_id
    , l_rcv_rcpt_rec
    , l_rcv_transaction_rec
    , inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb
    , TO_NUMBER(NULL)
    , l_return_status
    , l_msg_data
    );

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      x_status := l_return_status;
    END IF;

    l_progress := '140';
    -- Clear the Lot Rec
    inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;

    IF (l_debug = 1) THEN
      print_debug('About exit create_asn_con_dd_intf_rec: 140' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO crt_asn_con_rti_sp;
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO crt_asn_con_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO crt_asn_con_rti_sp;
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_rcpt_detail%ISOPEN THEN
        CLOSE l_curs_rcpt_detail;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_asn_con_dd_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_con_dd_intf_rec: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END;

  PROCEDURE create_asn_exp_dd_intf_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_shipment_header_id    IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_source_type           IN             VARCHAR2
  , p_subinventory                         VARCHAR2
  , p_locator_id                           NUMBER
  , p_lpn_id                IN             NUMBER
  , p_transaction_temp_id   IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_project_id            IN             NUMBER
  , p_task_id               IN             NUMBER
  , p_country_code          IN             VARCHAR2 DEFAULT NULL
  , p_secondary_rcv_qty     IN             NUMBER DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom           IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_rcv_sec_uom_code      IN             VARCHAR2 DEFAULT NULL  --OPM Convergence
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - DFF cols
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  ) IS
    -- Bug 2182881
    -- changed the cursor as for lot_numbers it was not joining with
    -- organization_id.
    CURSOR l_curs_asn_lpn_content IS
      SELECT lpnc.lpn_id
           , lpnc.inventory_item_id
           , lpnc.revision
           , lpnc.quantity
           , lpnc.uom_code
           , lpnc.lot_control_code
           , lpnc.serial_number_control_code
           , lpnc.primary_uom_code
           , p_po_header_id
           , lpnc.lot_number
           , mln.expiration_date
           , mln.status_id
           , lpnc.lpn_org_id
	   , lpnc.secondary_quantity   --Bug 7656734
      FROM   mtl_lot_numbers mln
           , (SELECT wlpn.lpn_id
                   , wlpnc.inventory_item_id
                   , msi.organization_id
                   , msi.lot_control_code
                   , msi.serial_number_control_code
                   , msi.primary_uom_code
                   , wlpnc.revision
                   , wlpnc.quantity
                   , wlpnc.uom_code
                   , wlpnc.lot_number
                   , wlpnc.source_line_id
                   , wlpn.organization_id lpn_org_id
		   , wlpnc.secondary_quantity   --Bug 7656734
              FROM   wms_lpn_contents wlpnc, wms_license_plate_numbers wlpn, mtl_system_items msi, rcv_shipment_headers rsh
              WHERE  rsh.shipment_header_id = p_shipment_header_id
              AND    (wlpn.source_header_id = rsh.shipment_header_id
                      OR wlpn.source_name = rsh.shipment_num)
              AND    wlpn.lpn_context IN(6, 7)                                  -- only those pre-ASN receiving ones
                                               -- Nested LPN changes to explode the LPN
                                               --AND wlpnc.parent_lpn_id = Nvl(p_lpn_id, wlpn.lpn_id)
                                               -- In case user tries to to ASN reciept by giving only PO Number
                                               -- LPN id will be NULL, In this case we should not expand the LPN
                                               -- in which case start with lpn_id = p_lpn_id will fail.
              AND    (wlpnc.parent_lpn_id = NVL(p_lpn_id, wlpn.lpn_id)
                      OR wlpnc.parent_lpn_id IN(SELECT     lpn_id
                                                FROM       wms_license_plate_numbers
                                                START WITH lpn_id = p_lpn_id
                                                CONNECT BY parent_lpn_id = PRIOR lpn_id))
              AND    wlpnc.inventory_item_id = msi.inventory_item_id
              AND    msi.organization_id = p_organization_id
              AND    wlpn.lpn_id = wlpnc.parent_lpn_id
              AND    (
                      wlpnc.source_line_id IN(SELECT pola.po_line_id
                                              FROM   po_lines_all pola
                                              WHERE  pola.po_header_id = NVL(p_po_header_id, pola.po_header_id))
                      OR wlpnc.source_line_id IS NULL
                     )) lpnc
      WHERE  lpnc.inventory_item_id = mln.inventory_item_id(+)
      AND    lpnc.lot_number = mln.lot_number(+)
      AND    lpnc.organization_id = mln.organization_id(+);

    CURSOR l_curs_serial_number(v_inventory_item_id NUMBER, v_revision VARCHAR2
              , v_lot_number VARCHAR2, v_lpn_id NUMBER) IS
      -- bug 2182881
      -- added nvl around the cursor
      SELECT serial_number
            , status_id
      FROM   mtl_serial_numbers
      WHERE  inventory_item_id = v_inventory_item_id
      AND    (revision = v_revision
              OR(revision IS NULL
                 AND v_revision IS NULL))
      AND    (lot_number = v_lot_number
              OR(lot_number IS NULL
                 AND v_lot_number IS NULL))
      AND    lpn_id = v_lpn_id;

    TYPE number_tab_tp IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    TYPE date_tab_tp IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;

    TYPE varchar_tab_tp IS TABLE OF VARCHAR2(30)
      INDEX BY BINARY_INTEGER;

    l_msnt_transaction_temp_id number_tab_tp;
    l_msnt_last_update_date    date_tab_tp;
    l_msnt_last_updated_by     number_tab_tp;
    l_msnt_creation_date       date_tab_tp;
    l_msnt_created_by          number_tab_tp;
    l_msnt_fm_serial_number    varchar_tab_tp;
    l_msnt_to_serial_number    varchar_tab_tp;
    l_lpn_id                   NUMBER;
    l_inventory_item_id        NUMBER;
    l_revision                 VARCHAR2(30);
    l_quantity                 NUMBER;
    l_uom_code                 VARCHAR2(3);
    l_lot_control_code         NUMBER;
    l_serial_control_code      NUMBER;
    l_unit_of_measure          VARCHAR2(25);
    l_po_header_id             NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number               VARCHAR2(80);
    l_lot_expiration_date      DATE;
    l_return_status            VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(400);
    l_progress                 VARCHAR2(10);
    l_transaction_temp_id      NUMBER;
    l_serial_txn_temp_id       NUMBER;
    l_primary_uom_code         VARCHAR2(3);
    l_primary_qty              NUMBER;
    l_uom_conv_ratio           NUMBER;
    l_serial_number            VARCHAR2(30);
    l_msnt_rec                 mtl_serial_numbers_temp%ROWTYPE;
    l_serial_number_count      NUMBER;
    l_label_status             VARCHAR2(500);
    l_debug                    NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    l_transaction_interface_id    NUMBER;
    l_product_transaction_id      NUMBER;
    l_serial_transaction_temp_id  NUMBER;
    l_lot_status_id               NUMBER;
    l_serial_status_id            NUMBER;
    l_lot_prm_quantity            NUMBER; --lot quantity in primary uom
    l_from_org_id                 NUMBER;
    l_lpn_org                     NUMBER;
    l_lpn_controlled_flag         NUMBER := 1;
    l_to_lpn_id                   NUMBER;
    l_secondary_quantity          NUMBER;  --Bug 7656734
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_asn_exp_dd_intf_rec: 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_move_order_header_id = ' || p_move_order_header_id, 4);
      print_debug('p_organization_id = ' || p_organization_id, 4);
      print_debug('p_shipment_header_id = ' || p_shipment_header_id, 4);
      print_debug('p_po_header_id = ' || p_po_header_id, 4);
      print_debug('p_subinventory = ' || p_subinventory, 4);
      print_debug('p_locator_id = ' || p_locator_id, 4);
      print_debug('p_transaction_temp_id = ' || p_transaction_temp_id, 4);
      print_debug('p_source_type = ' || p_source_type, 4);
      print_debug('p_lpn_id = ' || p_lpn_id, 4);
      print_debug('project id = ' || p_project_id);
    END IF;

    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';
    OPEN l_curs_asn_lpn_content;
    l_progress := '20';


    -- Check if the ToSubinventory is LPN controlled.
    SELECT NVL(lpn_controlled_flag,1)
      INTO l_lpn_controlled_flag
      FROM mtl_secondary_inventories
     WHERE secondary_inventory_name =  p_subinventory
       AND organization_id = p_organization_id;

    IF (l_debug = 1) THEN
       print_debug('create_asn_exp_dd_intf_rec: 0 ' || l_lpn_controlled_flag, 9);
    END IF;


    LOOP
      FETCH l_curs_asn_lpn_content INTO l_lpn_id
     , l_inventory_item_id
     , l_revision
     , l_quantity
     , l_uom_code
     , l_lot_control_code
     , l_serial_control_code
     , l_primary_uom_code
     , l_po_header_id
     , l_lot_number
     , l_lot_expiration_date
     , l_lot_status_id
     , l_lpn_org
     , l_secondary_quantity;   --Bug 7656734
      EXIT WHEN l_curs_asn_lpn_content%NOTFOUND;
      l_progress := '30';

      IF inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po
         OR inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j
         OR inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
        inv_rcv_std_rcpt_apis.update_lpn_org(
          p_organization_id     => p_organization_id
        , p_lpn_id              => l_lpn_id
        , x_return_status       => l_return_status
        , x_msg_count           => l_msg_count
        , x_msg_data            => l_msg_data
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      l_progress := '35';

      SELECT unit_of_measure
      INTO   l_unit_of_measure
      FROM   mtl_item_uoms_view
      WHERE  uom_code = l_uom_code
      AND    organization_id = p_organization_id
      AND    inventory_item_id = l_inventory_item_id;

      l_progress := '40';

      /* FP-J Lot/Serial Support Enhancement
       * If either INV J or PO J are not installed, then retain the existing logic
       * to create temp records for lots and serials
       * If both INV J and PO J are installed, create interface records for the lots/serials
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
          (inv_rcv_common_apis.g_po_patch_level  < inv_rcv_common_apis.g_patchset_j_po)) THEN
        -- insert into mtlt
        IF l_lot_number IS NOT NULL THEN
          IF (l_debug = 1) THEN
            print_debug('create_asn_exp_dd_intf_rec: 25 before inv_rcv_common_apis.insert_lot'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4);
          END IF;

          inv_convert.inv_um_conversion(from_unit => l_uom_code, to_unit => l_primary_uom_code, item_id => l_inventory_item_id
          , uom_rate      => l_uom_conv_ratio);

          IF l_uom_conv_ratio = -99999 THEN -- uom conversion failure
            fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                'create_asn_exp_dd_intf_rec 25.1 - txn/primary uom ratio calculation failed'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 4
              );
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

	  IF (p_source_type = 'INTERNAL' AND l_lot_control_code = 2) THEN
          BEGIN
                SELECT expiration_date
                INTO l_lot_expiration_date
                FROM mtl_lot_numbers
                WHERE inventory_item_id = l_inventory_item_id
                AND organization_id = l_lpn_org
                AND lot_number = l_lot_number;
          EXCEPTION
                WHEN OTHERS THEN
                l_lot_expiration_date := NULL;
          END;
         END IF;

	 IF (l_debug = 1) THEN
         	print_debug('l_lot_expiration_date = '||l_lot_expiration_date, 4);
	 END IF;

          l_primary_qty := l_quantity * l_uom_conv_ratio;
          inv_rcv_common_apis.insert_lot(
            p_transaction_temp_id            => l_transaction_temp_id
          , p_created_by                     => fnd_global.user_id
          , p_transaction_qty                => l_quantity
          , p_primary_qty                    => l_primary_qty
          , p_lot_number                     => l_lot_number
          , p_expiration_date                => l_lot_expiration_date
          , p_status_id                      => NULL
          , x_serial_transaction_temp_id     => l_serial_txn_temp_id
          , x_return_status                  => l_return_status
          , x_msg_data                       => l_msg_data
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                   'create_asn_exp_dd_intf_rec 25.1: inv_rcv_common_apis.insert_lot RAISE FND_API.G_EXC_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                   'create_asn_exp_dd_intf_rec 25.2: inv_rcv_common_apis.insert_lot RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;   --END IF ret_status = unexp_error
        END IF;   --END IF item is lot controlled

        l_progress := '41';

        -- insert into msnt

        IF l_serial_control_code = 2
           OR l_serial_control_code = 5 THEN
          IF (l_debug = 1) THEN
            print_debug('create_asn_exp_dd_intf_rec 27.1 - insert serial temp' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;

          OPEN l_curs_serial_number(l_inventory_item_id, l_revision, l_lot_number, l_lpn_id);
          l_serial_number_count := 0;

          IF l_serial_txn_temp_id IS NULL THEN -- Not lot controlled
            l_progress := '42';

            SELECT mtl_material_transactions_s.NEXTVAL
            INTO   l_serial_txn_temp_id
            FROM   DUAL;

            l_progress := '44';
            l_transaction_temp_id := l_serial_txn_temp_id;
          END IF;

          LOOP
            l_progress := '45';
            FETCH l_curs_serial_number INTO l_serial_number, l_serial_status_id;
            l_progress := '46';
            EXIT WHEN l_curs_serial_number%NOTFOUND;
            l_serial_number_count := l_serial_number_count + 1;
            l_msnt_transaction_temp_id(l_serial_number_count) := l_serial_txn_temp_id;
            l_msnt_last_update_date(l_serial_number_count) := SYSDATE;
            l_msnt_last_updated_by(l_serial_number_count) := fnd_global.user_id;
            l_msnt_creation_date(l_serial_number_count) := SYSDATE;
            l_msnt_created_by(l_serial_number_count) := fnd_global.user_id;
            l_msnt_fm_serial_number(l_serial_number_count) := l_serial_number;
            l_msnt_to_serial_number(l_serial_number_count) := l_serial_number;
          END LOOP;

          IF (l_debug = 1) THEN
            print_debug('create_asn_exp_dd_intf_rec 27.2 - Number of serial temp records : ' || l_msnt_transaction_temp_id.COUNT, 4);
          END IF;

          CLOSE l_curs_serial_number;
          l_progress := '47';
          FORALL i IN 1 .. l_msnt_transaction_temp_id.COUNT
            INSERT INTO mtl_serial_numbers_temp
                        (
                         transaction_temp_id
                       , last_update_date
                       , last_updated_by
                       , creation_date
                       , created_by
                       , fm_serial_number
                       , to_serial_number
                        )
            VALUES      (
                         l_msnt_transaction_temp_id(i)
                       , l_msnt_last_update_date(i)
                       , l_msnt_last_updated_by(i)
                       , l_msnt_creation_date(i)
                       , l_msnt_created_by(i)
                       , l_msnt_fm_serial_number(i)
                       , l_msnt_to_serial_number(i)
                        );
          l_progress := '48';
          FORALL i IN 1 .. l_msnt_transaction_temp_id.COUNT
            UPDATE mtl_serial_numbers
            SET group_mark_id = l_serial_txn_temp_id
            WHERE  inventory_item_id = l_inventory_item_id
            AND    serial_number = l_msnt_fm_serial_number(i);
          l_progress := '49';
        END IF;   --END IF item is serial controlled

      --INV J and PO J are installed. So create interface records MTLI and MSNI
      --instead of temp records
      ELSE
        --Reset the variables that store the IDs
        l_transaction_interface_id := NULL;
        l_serial_transaction_temp_id := NULL;
        l_product_transaction_id := NULL;

        IF l_lot_control_code > 1 THEN
          IF l_lot_number IS NOT NULL THEN
            --Convert the lot quantity into Item's Primary UOM code
            IF l_uom_code <> l_primary_uom_code THEN
              l_lot_prm_quantity := inv_convert.inv_um_convert(
                    item_id       =>  l_inventory_item_id
                  , precision     =>  NULL
                  , from_quantity =>  l_quantity
                  , from_unit     =>  l_uom_code
                  , to_unit       =>  l_primary_uom_code
                  , from_name     =>  NULL
                  , to_name       =>  NULL);

              --Check for failure
              IF l_lot_prm_quantity = -99999 THEN
                fnd_message.set_name('INV', 'INV_INT_UOMCONVCODE');
                fnd_msg_pub.ADD;
                IF (l_debug = 1) THEN
                  print_debug('create_asn_exp_rcpt_intf_rec: 20.2 - txn/primary uom conversion failed', 4);
                END IF;
                RAISE fnd_api.g_exc_error;
              END IF;   --END IF check for failure

            ELSE
              l_lot_prm_quantity := l_quantity;
            END IF;

             IF ((p_source_type = 'INTERNAL') AND (l_lpn_org <> p_organization_id)) THEN
              l_from_org_id := l_lpn_org;
            ELSE
              l_from_org_id := p_organization_id;
            END IF;

            --Create MTLI record for the lot and the lot quantity for this content
            --Set the flag for the API to populate the lot attributes
            inv_rcv_integration_apis.insert_mtli(
                p_api_version                 =>  1.0
              , p_init_msg_lst                =>  FND_API.G_FALSE
              , x_return_status               =>  l_return_status
              , x_msg_count                   =>  l_msg_count
              , x_msg_data                    =>  l_msg_data
              , p_transaction_interface_id    =>  l_transaction_interface_id
              , p_lot_number                  =>  l_lot_number
              , p_transaction_quantity        =>  l_quantity
              , p_primary_quantity            =>  l_lot_prm_quantity
	      , p_secondary_quantity          =>  l_secondary_quantity   --Bug 7656734
              , p_organization_id             =>  l_from_org_id
              , p_inventory_item_id           =>  l_inventory_item_id
              , p_expiration_date             =>  l_lot_expiration_date
              , p_status_id                   =>  l_lot_status_id
              , x_serial_transaction_temp_id  =>  l_serial_transaction_temp_id
              , p_product_transaction_id      =>  l_product_transaction_id
              , p_product_code                =>  'RCV'
              , p_att_exist                   =>  'Y'
              , p_update_mln                  =>  'N'
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (l_debug = 1) THEN
                print_debug('create_asn_exp_dd_intf_rec 28.1: Error in MTLI creation', 4);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (l_debug = 1) THEN
              print_debug('create_asn_exp_dd_intf_rec 28.2: txn i/f id: ' || l_transaction_interface_id
                            || ' serial temp : ' || l_serial_transaction_temp_id || ' prod txn id: ' || l_product_transaction_id, 4);
            END IF;
          END IF;   --END IF l_lot_number IS NOT NULL

          --Create MSNI records for the serials within lots
          --Bug #3405320
          --Create MSNI records even if serial control code is dynamic at SO Issue in
          --receiving org if there are serials shipped
          IF ((l_serial_control_code IN (2, 5)) OR
              (l_serial_control_code = 6 AND p_source_type IN ('INTERNAL', 'INVENTORY'))) THEN
	          -- bug 3196554
	          OPEN l_curs_serial_number(l_inventory_item_id, l_revision, l_lot_number, l_lpn_id);
            --Loop through the serials in the lot
            LOOP
              FETCH l_curs_serial_number INTO l_serial_number, l_serial_status_id;
              EXIT WHEN l_curs_serial_number%NOTFOUND;
	            IF (l_debug = 1) THEN
		            print_debug('create_asn_exp_dd_intf_rec 28.2.1: Before MSNI creation', 4);
	            END IF;
              --For each serial number in the lot create one MSNI record. The
              --serial attributes would be populated by the API
              inv_rcv_integration_apis.insert_msni(
                  p_api_version                 =>  1.0
                , p_init_msg_lst                =>  FND_API.G_FALSE
                , x_return_status               =>  l_return_status
                , x_msg_count                   =>  l_msg_count
                , x_msg_data                    =>  l_msg_data
                , p_transaction_interface_id    =>  l_serial_transaction_temp_id
                , p_fm_serial_number            =>  l_serial_number
                , p_to_serial_number            =>  l_serial_number
                , p_organization_id             =>  p_organization_id
                , p_inventory_item_id           =>  l_inventory_item_id
                , p_status_id                   =>  l_serial_status_id
                , p_product_transaction_id      =>  l_product_transaction_id
                , p_product_code                =>  'RCV'
                , p_att_exist                   =>  'Y'
                , p_update_msn                  =>  'N'
              );

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF (l_debug = 1) THEN
                  print_debug('create_asn_exp_dd_intf_rec 28.3: Error in MSNI creation', 4);
                END IF;
                RAISE FND_API.G_EXC_ERROR;
              END IF;
            END LOOP;   --END LOOP through serials for the lot

            --Close the serial cursor
            IF l_curs_serial_number%ISOPEN THEN
              CLOSE l_curs_serial_number;
            END IF;
          END IF;   --END IF item is lot and serial controlled

      	  -- bug 3180322
      	  -- This code was inside the serial control and lot control
      	  -- However we should be setting this variable irrespective of
      	  -- whether it is lot and serial control or just lot controlled
      	  --Set the variable l_transaction_temp_id that should be passed to
      	  --create_asn_con_dd_intf_rec to product_transaction_id since lots
      	  --and serials would be split based on this value
      	  l_transaction_temp_id := l_product_transaction_id;

        --If the item is serial controlled, loop through the serials within
        --the LPN and create one MSNI record for each serial number
        --The attributes for each serial number would be fetched by the API
        ELSIF (l_serial_control_code IN (2, 5) OR
               l_serial_control_code = 6 AND p_source_type IN ('INTERNAL', 'INVENTORY')) THEN
	        -- bug 3196554
	        OPEN l_curs_serial_number(l_inventory_item_id, l_revision, l_lot_number, l_lpn_id);
          --Loop through the serials in the lot
          LOOP
            FETCH l_curs_serial_number INTO l_serial_number, l_serial_status_id;
            EXIT WHEN l_curs_serial_number%NOTFOUND;
            --For each serial number in the lot create one MSNI record. The
            --serial attributes would be populated by the API
 	          IF (l_debug = 1) THEN
	            print_debug('create_asn_exp_dd_intf_rec 28.3.1: Before MSNI creation', 4);
	          END IF;
            inv_rcv_integration_apis.insert_msni(
                p_api_version                 =>  1.0
              , p_init_msg_lst                =>  FND_API.G_FALSE
              , x_return_status               =>  l_return_status
              , x_msg_count                   =>  l_msg_count
              , x_msg_data                    =>  l_msg_data
              , p_transaction_interface_id    =>  l_transaction_interface_id
              , p_fm_serial_number            =>  l_serial_number
              , p_to_serial_number            =>  l_serial_number
              , p_organization_id             =>  p_organization_id
              , p_inventory_item_id           =>  l_inventory_item_id
              , p_status_id                   =>  l_serial_status_id
              , p_product_transaction_id      =>  l_product_transaction_id
              , p_product_code                =>  'RCV'
              , p_att_exist                   =>  'Y'
              , p_update_msn                  =>  'N'
            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF (l_debug = 1) THEN
                print_debug('create_asn_exp_dd_intf_rec 28.4: Error in MSNI creation', 4);
              END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_debug = 1) THEN
              print_debug('create_asn_exp_dd_intf_rec 28.5: txn i/f id: ' || l_transaction_interface_id || ' prod txn id: ' || l_product_transaction_id, 4);
            END IF;
          END LOOP;   --END LOOP through serials for the LPN

          --Set the variable l_transaction_temp_id that should be passed to
          --create_asn_con_dd_intf_rec to product_transaction_id since lots
          --and serials would be split based on this value
          l_transaction_temp_id := l_product_transaction_id;

          --Close the serial cursor
          IF l_curs_serial_number%ISOPEN THEN
            CLOSE l_curs_serial_number;
          END IF;
        END IF;    --END IF check lot and serial control codes
      END IF;   --END IF check INV patchset J and PO patchset J are installed

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_dd_intf_rec: 30 before create_asn_con_dd_intf_rec' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      -- If subinventory is Non-LPN controlled then pass to_lpn

      IF (l_lpn_controlled_flag = 2) THEN
        l_to_lpn_id  := NULL ;
      ELSE
        l_to_lpn_id := l_lpn_id;
      END IF;

      -- Nested LPN changes.
      -- Passed new parameter p_from_lpn_id also as l_lpn_id
      create_asn_con_dd_intf_rec(
        p_move_order_header_id     => p_move_order_header_id
      , p_organization_id          => p_organization_id
      , p_shipment_header_id       => p_shipment_header_id
      , p_po_header_id             => l_po_header_id
      , p_item_id                  => l_inventory_item_id
      , p_rcv_qty                  => l_quantity
      , p_rcv_uom                  => l_unit_of_measure
      , p_rcv_uom_code             => l_uom_code
      , p_source_type              => p_source_type
      , p_subinventory             => p_subinventory
      , p_locator_id               => p_locator_id
      , p_from_lpn_id              => l_lpn_id
      , p_lpn_id                   => l_to_lpn_id
      , p_lot_control_code         => l_lot_control_code
      , p_serial_control_code      => l_serial_control_code
      , p_revision                 => l_revision
      , p_transaction_temp_id      => NVL(l_transaction_temp_id, p_transaction_temp_id)
      , x_status                   => l_return_status
      , x_message                  => l_msg_data
      , p_project_id               => p_project_id
      , p_task_id                  => p_task_id
      , p_attribute_category       => p_attribute_category  --Bug #4147209
      , p_attribute1               => p_attribute1
      , p_attribute2               => p_attribute2
      , p_attribute3               => p_attribute3
      , p_attribute4               => p_attribute4
      , p_attribute5               => p_attribute5
      , p_attribute6               => p_attribute6
      , p_attribute7               => p_attribute7
      , p_attribute8               => p_attribute8
      , p_attribute9               => p_attribute9
      , p_attribute10              => p_attribute10
      , p_attribute11              => p_attribute11
      , p_attribute12              => p_attribute12
      , p_attribute13              => p_attribute13
      , p_attribute14              => p_attribute14
      , p_attribute15              => p_attribute15
      , p_express_transaction       => 'Y'--Bug 5550783
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_asn_exp_dd_intf_rec 40.1:create_asn_con_dd_intf_rec  RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_asn_exp_dd_intf_rec 40.2: create_asn_con_dd_intf_rec RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4
          );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_dd_intf_rec: 50 after create_asn_con_dd_intf_rec' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 4);
      END IF;
    END LOOP;

    --BUG 4567903: Need to set the status so that the UI will show the
    --correct messages
    x_status := l_return_status;
    IF (l_debug = 1) THEN
       print_debug('x_status:'||x_status,4);
       print_debug('x_message:'||x_message,4);
    END IF;
    --END BUG 4567903

    -- Nested LPN changes, If INVJ,POJ,WMSJ Installed then
    -- insert WLPNI for FromLPN with parent as NULL.

    IF inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po
       AND inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j
       AND inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j THEN
      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_exp_dd_intf_rec: 50.1 - Before inserting into wlpni for p_lpn_id with parent NULL '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF ((p_source_type = 'INTERNAL') AND (l_lpn_org <> p_organization_id)) THEN
	 l_from_org_id := l_lpn_org;
       ELSE
	 l_from_org_id := p_organization_id;
      END IF;

      -- Nested LPN changes. Insert WLPNI
      inv_rcv_integration_apis.insert_wlpni(
          p_api_version           => 1.0
         ,x_return_status         => l_return_status
         ,x_msg_count             => l_msg_count
         ,x_msg_data              => l_msg_data
         ,p_organization_id       => l_from_org_id -- BUG 4096028: should
					           -- from org_id
         ,p_lpn_id                => p_lpn_id
         ,p_license_plate_number  => NULL
         ,p_lpn_group_id          => inv_rcv_common_apis.g_rcv_global_var.interface_group_id
         ,p_parent_lpn_id         => NULL
         );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_asn_exp_dd_intf_rec 50.2:create_asn_con_dd_intf_rec -  RAISE FND_API.G_EXC_ERROR after insert_wlpni;'|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug(
             'create_asn_exp_dd_intf_rec: 50.1 - After inserting into wlpni for p_lpn_id with parent NULL '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;
    END IF;

    l_progress := '60';

    IF l_curs_asn_lpn_content%ISOPEN THEN
      CLOSE l_curs_asn_lpn_content;
    END IF;

    l_progress := '70';

    -- UPDATE lpn context


    IF inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po
       OR inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j
       OR inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN

      UPDATE wms_license_plate_numbers
      SET lpn_context = 3
      WHERE  source_header_id = p_shipment_header_id
      AND    lpn_id = NVL(p_lpn_id, lpn_id);

      l_progress := '80';

      -- UPDATE the lpn history table with source name as ASNEXP since no packing happened.
      -- This is needed to help the cleanup later on
      -- Nothing else is updated to keep in synch with license_plate_number update

      IF (l_debug = 1) THEN
        print_debug(' create_asn_exp_dd_intf_rec: Before Update lpn history  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        print_debug(
             ' create_asn_exp_dd_intf_rec: Group_id = '
          || inv_rcv_common_apis.g_rcv_global_var.interface_group_id
          || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      UPDATE wms_lpn_histories
      SET source_name = 'ASNEXP'
        , source_header_id = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      WHERE  lpn_context = 7
      AND    parent_lpn_id IN(SELECT lpn_id
                              FROM   wms_license_plate_numbers
                              WHERE  source_header_id = p_shipment_header_id
                              AND    lpn_id = NVL(p_lpn_id, lpn_id));
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Exit create_asn_exp_dd_intf_rec: 90 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_dd_intf_rec:  FND_API.g_exc_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_dd_intf_rec: fnd_api.g_exc_unexpected_error ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_STD_RCPT_APIS.create_asn_exp_dd_intf_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);

      IF (l_debug = 1) THEN
        print_debug('create_asn_exp_dd_intf_rec: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END create_asn_exp_dd_intf_rec;

  PROCEDURE create_osp_direct_rti_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_po_release_id         IN             NUMBER
  , p_po_line_id            IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_transaction_temp_id   IN             NUMBER
  , p_revision              IN             VARCHAR2
  , p_po_distribution_id    IN             NUMBER
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  ) IS
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
    l_label_status  VARCHAR2(500);
    l_progress      VARCHAR2(10);
    l_txn_id_tbl    inv_label.transaction_id_rec_type;
    l_counter       NUMBER := 0;

    CURSOR c_rti_txn_id IS
      /* Bug 2443163 */
      /* SELECT MIN(rti.interface_transaction_id) */
      /* Group BY LPN_ID is changed for Express Receipts */
      /* Also  duplicate print of LPN labels is avoided */
      SELECT   MAX(rti.interface_transaction_id)
      FROM     rcv_transactions_interface rti
      WHERE    rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      GROUP BY DECODE(p_source_type, 'ASNEXP', rti.interface_transaction_id, 'SHIPMENTEXP', rti.interface_transaction_id, NULL);
    -- GROUP BY rti.lpn_id;

    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_osp_direct_rti_rec: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN
       --BUG 3440184: For performance reason, use the follow query
       --instead of gl_sets_of_books
       SELECT TO_NUMBER(hoi.org_information1)
	 INTO inv_rcv_common_apis.g_po_startup_value.sob_id
	 FROM hr_organization_information hoi
	 WHERE hoi.organization_id = p_organization_id
	 AND (hoi.org_information_context || '') = 'Accounting Information';

      --SELECT ood.set_of_books_id
      --INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
      --FROM   org_organization_definitions ood, gl_sets_of_books sob
      --WHERE  organization_id = p_organization_id
      --AND    sob.set_of_books_id = ood.set_of_books_id;
    END IF;

    l_progress := '10';
    -- first check if the transaction date satisfies the validation.
    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_status
    , x_error_code          => x_message
    );

    IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    IF p_po_header_id IS NULL
       AND p_item_id IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('create_osp_direct_rti_rec: 2 item id and po number cannot be NULL', 4);
      END IF;

      x_status := fnd_api.g_ret_sts_error;
      RETURN;
    END IF;

    l_progress := '30';
    create_osp_drct_dlvr_rti_rec(
      p_move_order_header_id     => p_move_order_header_id
    , p_organization_id          => p_organization_id
    , p_po_header_id             => p_po_header_id
    , p_po_release_id            => p_po_release_id
    , p_po_line_id               => p_po_line_id
    , p_po_line_location_id      => NULL
    , p_po_distribution_id       => p_po_distribution_id
    , p_item_id                  => p_item_id
    , p_rcv_qty                  => p_rcv_qty
    , p_rcv_uom                  => p_rcv_uom
    , p_rcv_uom_code             => p_rcv_uom_code
    , p_source_type              => p_source_type
    , p_transaction_temp_id      => p_transaction_temp_id
    , p_revision                 => p_revision
    , x_status                   => l_return_status
    , x_message                  => x_message
    , p_attribute_category       => p_attribute_category  --Bug #4147209
    , p_attribute1               => p_attribute1
    , p_attribute2               => p_attribute2
    , p_attribute3               => p_attribute3
    , p_attribute4               => p_attribute4
    , p_attribute5               => p_attribute5
    , p_attribute6               => p_attribute6
    , p_attribute7               => p_attribute7
    , p_attribute8               => p_attribute8
    , p_attribute9               => p_attribute9
    , p_attribute10              => p_attribute10
    , p_attribute11              => p_attribute11
    , p_attribute12              => p_attribute12
    , p_attribute13              => p_attribute13
    , p_attribute14              => p_attribute14
    , p_attribute15              => p_attribute15
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
             'create_osp_direct_rti_rec 20.1: create_osp_drct_dlvr_rti_rec RAISE FND_API.G_EXC_ERROR;'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug(
             'create_osp_direct_rti_rec 20.2: create_osp_drct_dlvr_rti_rec FND_API.G_EXC_UNEXPECTED_ERROR;'
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '40';

    IF (l_debug = 1) THEN
      print_debug('create_osp_direct_rti_rec calling print_label: 6' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    x_status := l_return_status; -- l_return_status can be 'W', we want to carry that over
                                 -- calling label printing API

    IF l_return_status <> fnd_api.g_ret_sts_error THEN
      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug(
          'create_osp_direct_rti_rec: 8.1 before  inv_label.print_label ' || inv_rcv_common_apis.g_rcv_global_var.interface_group_id, 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed, do not call label printing API at this stage
       */
      IF ((inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po) OR
          (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)) THEN

       IF (p_source_type <> 'VENDOR') THEN --Bug #4079952 ..For PO receipt, code in rcv_insert_update_header(INVSTDRB.pls) will be called.
        l_counter := 1;
        OPEN c_rti_txn_id;

        LOOP
          FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
          EXIT WHEN c_rti_txn_id%NOTFOUND;

          IF (l_debug = 1) THEN
            print_debug('create_osp_direct_rti_rec calling printing for:' || l_txn_id_tbl(l_counter), 4);
          END IF;

          l_counter := l_counter + 1;
        END LOOP;

        CLOSE c_rti_txn_id;
        inv_label.print_label(
          x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , x_label_status           => l_label_status
        , p_api_version            => 1.0
        , p_print_mode             => 1
        , p_business_flow_code     => 1
        , p_transaction_id         => l_txn_id_tbl
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;
          x_status := 'W';

          IF (l_debug = 1) THEN
            print_debug('create_osp_direct_rti_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;   --END IF l_debug = 1
        END IF;   --END IF label ret_status <> S
       END IF ; --Bug #4079952
      ELSE
        IF (l_debug = 1) THEN
          print_debug('INV J and PO J are installed. NO label printing from UI', 4);
        END IF;
      END IF;   --END IF INV J and PO J installed
    END IF;   --END IF ret_status = Success

    IF (l_debug = 1) THEN
      print_debug('create_osp_direct_rti_rec exiting print_label: 7' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('About exit create_osp_direct_rti_rec: 8' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('create_osp_direct_rti_rec: 8.1   - x_status = ' || x_status, 4);
      print_debug('create_osp_direct_rti_rec: 8.2   -  x_message= ' || x_message, 4);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_dir_rcpt_apis.create_osp_direct_rti_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_osp_direct_rti_rec;

  PROCEDURE create_direct_rti_rec(
    p_move_order_header_id  IN OUT NOCOPY  NUMBER
  , p_organization_id       IN             NUMBER
  , p_po_header_id          IN             NUMBER
  , p_po_release_id         IN             NUMBER
  , p_po_line_id            IN             NUMBER
  , p_shipment_header_id    IN             NUMBER
  , p_oe_order_header_id    IN             NUMBER
  , p_item_id               IN             NUMBER
  , p_rcv_qty               IN             NUMBER
  , p_rcv_uom               IN             VARCHAR2
  , p_rcv_uom_code          IN             VARCHAR2
  , p_source_type           IN             VARCHAR2
  , p_subinventory          IN             VARCHAR2
  , p_locator_id            IN             NUMBER
  , p_transaction_temp_id   IN             NUMBER
  , p_lot_control_code      IN             NUMBER
  , p_serial_control_code   IN             NUMBER
  , p_lpn_id                IN             NUMBER
  , p_revision              IN             VARCHAR2
  , x_status                OUT NOCOPY     VARCHAR2
  , x_message               OUT NOCOPY     VARCHAR2
  , p_inv_item_id           IN             NUMBER DEFAULT NULL
  , p_item_desc             IN             VARCHAR2 DEFAULT NULL
  , p_location_id           IN             NUMBER DEFAULT NULL
  , p_is_expense            IN             VARCHAR2 DEFAULT NULL
  , p_project_id            IN             NUMBER DEFAULT NULL
  , p_task_id               IN             NUMBER DEFAULT NULL
  , p_country_code          IN             VARCHAR2 DEFAULT NULL
  , p_from_lpn_id           IN             NUMBER -- Nested LPN changes
  , p_secondary_rcv_qty     IN             NUMBER --OPM Convergence
  , p_rcv_sec_uom           IN             VARCHAR2 --OPM Convergence
  , p_rcv_sec_uom_code      IN             VARCHAR2 --OPM Convergence
  , p_attribute_category    IN             VARCHAR2  DEFAULT NULL  --Bug #4147209 - DFF cols
  , p_attribute1            IN             VARCHAR2  DEFAULT NULL
  , p_attribute2            IN             VARCHAR2  DEFAULT NULL
  , p_attribute3            IN             VARCHAR2  DEFAULT NULL
  , p_attribute4            IN             VARCHAR2  DEFAULT NULL
  , p_attribute5            IN             VARCHAR2  DEFAULT NULL
  , p_attribute6            IN             VARCHAR2  DEFAULT NULL
  , p_attribute7            IN             VARCHAR2  DEFAULT NULL
  , p_attribute8            IN             VARCHAR2  DEFAULT NULL
  , p_attribute9            IN             VARCHAR2  DEFAULT NULL
  , p_attribute10           IN             VARCHAR2  DEFAULT NULL
  , p_attribute11           IN             VARCHAR2  DEFAULT NULL
  , p_attribute12           IN             VARCHAR2  DEFAULT NULL
  , p_attribute13           IN             VARCHAR2  DEFAULT NULL
  , p_attribute14           IN             VARCHAR2  DEFAULT NULL
  , p_attribute15           IN             VARCHAR2  DEFAULT NULL
  ) IS
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
    l_label_status  VARCHAR2(500);
    l_progress      VARCHAR2(10);
    l_txn_id_tbl    inv_label.transaction_id_rec_type;
    l_counter       NUMBER      := 0;
    l_subinventory  VARCHAR2(10);
    l_locator_id    NUMBER;

-- For LCM
    l_tx_type       VARCHAR2(40);
-- END FOR LCM


    CURSOR c_rti_txn_id IS
      /* Bug 2443163 */
      /* SELECT MIN(rti.interface_transaction_id) */
      /* Group BY LPN_ID is changed for Express Receipts */
      /* Also  duplicate print of LPN labels is avoided */
      SELECT   MAX(rti.interface_transaction_id)
      FROM     rcv_transactions_interface rti
      WHERE    rti.GROUP_ID = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      GROUP BY DECODE(p_source_type, 'ASNEXP', rti.interface_transaction_id, 'SHIPMENTEXP', rti.interface_transaction_id, NULL);

    -- GROUP BY rti.lpn_id;
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    IF (l_debug = 1) THEN
      print_debug('create_direct_rti_rec: 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('txn temp id: ' || p_transaction_temp_id, 4);
    END IF;

    IF inv_rcv_common_apis.g_po_startup_value.sob_id IS NULL THEN

      --BUG 3440184: For performance reason, use the follow query
      --instead of gl_sets_of_books

      SELECT TO_NUMBER(hoi.org_information1)
      INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
      FROM hr_organization_information hoi
      WHERE hoi.organization_id = p_organization_id
        AND (hoi.org_information_context || '') = 'Accounting Information';

      -- SELECT ood.set_of_books_id
      -- INTO   inv_rcv_common_apis.g_po_startup_value.sob_id
      -- FROM   org_organization_definitions ood, gl_sets_of_books sob
      -- WHERE  organization_id = p_organization_id
      -- AND    sob.set_of_books_id = ood.set_of_books_id;

    END IF;

    l_progress := '10';
    -- first check if the transaction date satisfies the validation.
    inv_rcv_common_apis.validate_trx_date(
      p_trx_date            => SYSDATE
    , p_organization_id     => p_organization_id
    , p_sob_id              => inv_rcv_common_apis.g_po_startup_value.sob_id
    , x_return_status       => x_status
    , x_error_code          => x_message
    );

    IF x_status <> fnd_api.g_ret_sts_success THEN
      RETURN;
    END IF;

    IF p_shipment_header_id IS NULL THEN -- Added this check to fix bug no. 2159179
      IF p_po_header_id IS NULL
         AND p_item_id IS NULL THEN
        IF (l_debug = 1) THEN
          print_debug('create_direct_rti_rec: 2 item id and po number cannot be NULL', 4);
        END IF;

        x_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;

    l_progress := '30';

    IF p_po_header_id IS NOT NULL
       AND p_source_type <> 'ASNEXP'
       AND p_source_type <> 'LCMEXP'   -- For LCM Project
       AND p_source_type <> 'LCMCONFM' -- For LCM Project
       AND p_source_type <> 'ASNCONFM' -- bug fix 2129249
                                       THEN
      l_progress := '40';

      IF (l_debug = 1) THEN
        print_debug('create_direct_rti_rec: 4 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        print_debug('create_direct_rti_rec: 4.1  p_po_header_id = ' || p_po_header_id, 4);
      END IF;

      IF p_item_id IS NULL
         AND p_item_desc IS NULL THEN
        IF (l_debug = 1) THEN
          print_debug('create_direct_rti_rec: 2 item id and po number cannot be NULL', 4);
        END IF;

        x_status := fnd_api.g_ret_sts_error;
        RETURN;
      END IF;

      l_subinventory := p_subinventory;
      l_locator_id := p_locator_id;

      IF p_location_id IS NOT NULL THEN
        l_subinventory := '';
        l_locator_id := '';
      END IF;

      create_po_drct_dlvr_rti_rec(
        p_move_order_header_id     => p_move_order_header_id
      , p_organization_id          => p_organization_id
      , p_po_header_id             => p_po_header_id
      , p_po_release_id            => p_po_release_id
      , p_po_line_id               => p_po_line_id
      , p_po_line_location_id      => NULL
      , p_po_distribution_id       => NULL
      , p_item_id                  => p_item_id
      , p_rcv_qty                  => p_rcv_qty
      , p_rcv_uom                  => p_rcv_uom
      , p_rcv_uom_code             => p_rcv_uom_code
      , p_source_type              => p_source_type
      , p_subinventory             => l_subinventory
      , p_locator_id               => l_locator_id
      , p_transaction_temp_id      => p_transaction_temp_id
      , p_lot_control_code         => p_lot_control_code
      , p_serial_control_code      => p_serial_control_code
      , p_lpn_id                   => p_lpn_id
      , p_revision                 => p_revision
      , x_status                   => l_return_status
      , x_message                  => x_message
      , p_inv_item_id              => p_inv_item_id
      , p_item_desc                => p_item_desc
      , p_location_id              => p_location_id
      , p_is_expense               => p_is_expense
      , p_project_id               => p_project_id
      , p_task_id                  => p_task_id
      , p_country_code             => p_country_code
      , p_secondary_rcv_qty        => p_secondary_rcv_qty  --OPM Convergence
      , p_rcv_sec_uom              => p_rcv_sec_uom --OPM Convergence
      , p_rcv_sec_uom_code         => p_rcv_sec_uom_code --OPM Convergence
      , p_attribute_category       => p_attribute_category  --Bug #4147209
      , p_attribute1               => p_attribute1
      , p_attribute2               => p_attribute2
      , p_attribute3               => p_attribute3
      , p_attribute4               => p_attribute4
      , p_attribute5               => p_attribute5
      , p_attribute6               => p_attribute6
      , p_attribute7               => p_attribute7
      , p_attribute8               => p_attribute8
      , p_attribute9               => p_attribute9
      , p_attribute10              => p_attribute10
      , p_attribute11              => p_attribute11
      , p_attribute12              => p_attribute12
      , p_attribute13              => p_attribute13
      , p_attribute14              => p_attribute14
      , p_attribute15              => p_attribute15
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_direct_rti_rec 20.1: create_po_drct_dlvr_rti_rec RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_PO_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_direct_rti_rec 20.2: create_po_drct_dlvr_rti_rec FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF p_shipment_header_id IS NOT NULL THEN
      l_progress := '50';

      IF (l_debug = 1) THEN
        print_debug('create_direct_rti_rec: 22' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        print_debug('create_direct_rti_rec: 22.1  p_shipment_header_id = ' || p_shipment_header_id, 4);
      END IF;

      IF p_source_type = 'ASNEXP'
         OR p_source_type = 'LCMEXP'  -- For LCM Project
         OR p_source_type = 'SHIPMENTEXP'
         OR p_source_type = 'SHIPMENT'
         OR p_source_type = 'REQEXP' THEN
        IF p_source_type = 'ASNEXP' THEN
          IF (l_debug = 1) THEN
            print_debug(
              'create_direct_rti_rec: 23 - calling  create_asn_exp_dd_intf_rec for ASNEXP'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
          END IF;

-- For Bug 7440217 added code to handle LCM Doc also
      IF p_source_type = 'ASNEXP' THEN
           l_tx_type := 'ASN';
      ELSIF p_source_type = 'LCMEXP' THEN   -- For LCM Project
           l_tx_type := 'LCM';   -- For LCM Project
      END IF;
-- End for Bug 7440217

          create_asn_exp_dd_intf_rec(
            p_move_order_header_id     => p_move_order_header_id
          , p_organization_id          => p_organization_id
          , p_shipment_header_id       => p_shipment_header_id
          , p_po_header_id             => p_po_header_id
          , p_source_type              => l_tx_type
          , p_subinventory             => p_subinventory
          , p_locator_id               => p_locator_id
          , p_lpn_id                   => p_lpn_id
          , p_transaction_temp_id      => p_transaction_temp_id
          , x_status                   => l_return_status
          , x_message                  => l_msg_data
          , p_project_id               => p_project_id
          , p_task_id                  => p_task_id
          , p_country_code             => p_country_code
          , p_secondary_rcv_qty        => p_secondary_rcv_qty  --OPM Convergence
          , p_rcv_sec_uom              => p_rcv_sec_uom --OPM Convergence
          , p_rcv_sec_uom_code         => p_rcv_sec_uom_code --OPM Convergence
          , p_attribute_category       => p_attribute_category
          , p_attribute1               => p_attribute1
          , p_attribute2               => p_attribute2
          , p_attribute3               => p_attribute3
          , p_attribute4               => p_attribute4
          , p_attribute5               => p_attribute5
          , p_attribute6               => p_attribute6
          , p_attribute7               => p_attribute7
          , p_attribute8               => p_attribute8
          , p_attribute9               => p_attribute9
          , p_attribute10              => p_attribute10
          , p_attribute11              => p_attribute11
          , p_attribute12              => p_attribute12
          , p_attribute13              => p_attribute13
          , p_attribute14              => p_attribute14
          , p_attribute15              => p_attribute15
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
            fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL'); -- MSGTBD
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                   'create_direct_rti_rec 23.1: create_asn_exp_dd_intf_rec  RAISE FND_API.G_EXC_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            fnd_message.set_name('INV', 'INV_RCV_CREATE_ASNEXP_RTI_FAIL'); -- MSGTBD
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                   'create_direct_rti_rec 23.2: create_asn_exp_dd_intf_rec  FND_API.G_EXC_UNEXPECTED_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          l_progress := '50';

          IF (l_debug = 1) THEN
            print_debug(
                 'create_direct_rti_rec: 24 - calling  create_asn_exp_dd_intf_rec for intransit shipment'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
          END IF;

          create_asn_exp_dd_intf_rec(
            p_move_order_header_id     => p_move_order_header_id
          , p_organization_id          => p_organization_id
          , p_shipment_header_id       => p_shipment_header_id
          , p_po_header_id             => p_po_header_id
          , p_source_type              => 'INTERNAL'
          , p_subinventory             => p_subinventory
          , p_locator_id               => p_locator_id
          , p_lpn_id                   => p_lpn_id
          , p_transaction_temp_id      => p_transaction_temp_id
          , x_status                   => l_return_status
          , x_message                  => l_msg_data
          , p_project_id               => p_project_id
          , p_task_id                  => p_task_id
          , p_country_code             => p_country_code
          , p_secondary_rcv_qty        => p_secondary_rcv_qty  --OPM Convergence
          , p_rcv_sec_uom              => p_rcv_sec_uom --OPM Convergence
          , p_rcv_sec_uom_code         => p_rcv_sec_uom_code --OPM Convergence
          , p_attribute_category       => p_attribute_category
          , p_attribute1               => p_attribute1
          , p_attribute2               => p_attribute2
          , p_attribute3               => p_attribute3
          , p_attribute4               => p_attribute4
          , p_attribute5               => p_attribute5
          , p_attribute6               => p_attribute6
          , p_attribute7               => p_attribute7
          , p_attribute8               => p_attribute8
          , p_attribute9               => p_attribute9
          , p_attribute10              => p_attribute10
          , p_attribute11              => p_attribute11
          , p_attribute12              => p_attribute12
          , p_attribute13              => p_attribute13
          , p_attribute14              => p_attribute14
          , p_attribute15              => p_attribute15
          );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
	     --BUG 3433072: The message below is not defined.  Plus, it
	     --create_asn_exp_dd_intf_rec fails, it will fails with a error
	     --message.
	     --fnd_message.set_name('INV', 'INV_RCV_CRT_INTSHIPEXP_RTI_FAIL'); -- MSGTBD
	     --fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                   'create_direct_rti_rec 24.1: create_asn_exp_dd_intf_rec for IntShip RAISE FND_API.G_EXC_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	     --BUG 3433072: The message below is not defined
	     --fnd_message.set_name('INV', 'INV_RCV_CREATE_INTSHIPEXP_RTI_FAIL');
	     fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL');
	     fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug(
                   'create_direct_rti_rec 24.2: create_asn_exp_dd_intf_rec for IntShip RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
                || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
            END IF;

            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        END IF;
      ELSIF p_source_type IN ('ASNCONFM', 'LCMCONFM') THEN   -- For LCM Project

        l_progress := '60';

-- For Bug 7440217 added code to handle LCM Doc also
      IF p_source_type = 'ASNCONFM' THEN
           l_tx_type := 'ASN';
      ELSIF p_source_type = 'LCMCONFM' THEN     -- For LCM Project
           l_tx_type := 'LCM';       -- For LCM Project
      END IF;
-- End for Bug 7440217

        IF (l_debug = 1) THEN
          print_debug('create_direct_rti_rec: 25  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
        END IF;

        create_asn_con_dd_intf_rec(
          p_move_order_header_id     => p_move_order_header_id
        , p_organization_id          => p_organization_id
        , p_shipment_header_id       => p_shipment_header_id
        , p_po_header_id             => p_po_header_id
        , p_item_id                  => p_item_id
        , p_rcv_qty                  => p_rcv_qty
        , p_rcv_uom                  => p_rcv_uom
        , p_rcv_uom_code             => p_rcv_uom_code
        , p_source_type              => l_tx_type
        , p_subinventory             => p_subinventory
        , p_locator_id               => p_locator_id
        , p_from_lpn_id              => p_from_lpn_id
        , -- Nested LPN changes
          p_lpn_id                   => p_lpn_id
        , p_lot_control_code         => p_lot_control_code
        , p_serial_control_code      => p_serial_control_code
        , p_revision                 => p_revision
        , p_transaction_temp_id      => p_transaction_temp_id
        , x_status                   => l_return_status
        , x_message                  => l_msg_data
        , p_project_id               => p_project_id
        , p_task_id                  => p_task_id
        , p_country_code             => p_country_code
        , p_item_desc                => p_item_desc
        , p_secondary_rcv_qty        => p_secondary_rcv_qty  --OPM Convergence
        , p_rcv_sec_uom              => p_rcv_sec_uom --OPM Convergence
        , p_rcv_sec_uom_code         => p_rcv_sec_uom_code --OPM Convergence
        , p_attribute_category       => p_attribute_category
        , p_attribute1               => p_attribute1
        , p_attribute2               => p_attribute2
        , p_attribute3               => p_attribute3
        , p_attribute4               => p_attribute4
        , p_attribute5               => p_attribute5
        , p_attribute6               => p_attribute6
        , p_attribute7               => p_attribute7
        , p_attribute8               => p_attribute8
        , p_attribute9               => p_attribute9
        , p_attribute10              => p_attribute10
        , p_attribute11              => p_attribute11
        , p_attribute12              => p_attribute12
        , p_attribute13              => p_attribute13
        , p_attribute14              => p_attribute14
        , p_attribute15              => p_attribute15
        , p_express_transaction      => NULL--Bug 5550783
        , p_location_id              => p_location_id --Bug 13490287
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_ASNCON_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_direct_rti_rec 25.1: create_asn_con_dd_intf_rec RAISE FND_API.G_EXC_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CREATE_INTSHIPEXP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_direct_rti_rec 25.2: create_asn_con_dd_intf_rec RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 4
            );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        create_int_shp_dr_del_rti_rec(
          p_move_order_header_id     => p_move_order_header_id
        , p_organization_id          => p_organization_id
        , p_shipment_header_id       => p_shipment_header_id
        , p_shipment_line_id         => NULL
        , p_item_id                  => p_item_id
        , p_rcv_qty                  => p_rcv_qty
        , p_rcv_uom                  => p_rcv_uom
        , p_rcv_uom_code             => p_rcv_uom_code
        , p_source_type              => p_source_type
        , p_subinventory             => p_subinventory
        , p_locator_id               => p_locator_id
        , p_transaction_temp_id      => p_transaction_temp_id
        , p_lot_control_code         => p_lot_control_code
        , p_serial_control_code      => p_serial_control_code
        , p_from_lpn_id              => p_from_lpn_id
        , -- Nested LPN Changes
          p_lpn_id                   => p_lpn_id
        , p_revision                 => p_revision
        , p_project_id               => p_project_id
        , p_task_id                  => p_task_id
        , x_status                   => l_return_status
        , x_message                  => x_message
        , p_country_code             => p_country_code
        , p_secondary_rcv_qty        => p_secondary_rcv_qty  --OPM Convergence
        , p_rcv_sec_uom              => p_rcv_sec_uom --OPM Convergence
        , p_rcv_sec_uom_code         => p_rcv_sec_uom_code --OPM Convergence
        , p_attribute_category       => p_attribute_category
        , p_attribute1               => p_attribute1
        , p_attribute2               => p_attribute2
        , p_attribute3               => p_attribute3
        , p_attribute4               => p_attribute4
        , p_attribute5               => p_attribute5
        , p_attribute6               => p_attribute6
        , p_attribute7               => p_attribute7
        , p_attribute8               => p_attribute8
        , p_attribute9               => p_attribute9
        , p_attribute10              => p_attribute10
        , p_attribute11              => p_attribute11
        , p_attribute12              => p_attribute12
        , p_attribute13              => p_attribute13
        , p_attribute14              => p_attribute14
        , p_attribute15              => p_attribute15
        );

        IF l_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_direct_rti_rec 40.1: create_int_shp_dr_del_rti_rec RAISE FND_API.G_EXC_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_INSHP_RTI_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'create_direct_rti_rec 40.2:create_int_shp_dr_del_rti_rec FND_API.G_EXC_UNEXPECTED_ERROR;'
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    ELSIF p_oe_order_header_id IS NOT NULL THEN
      l_progress := '60';

      IF (l_debug = 1) THEN
        print_debug('create_direct_rti_rec: 6' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        print_debug('create_direct_rti_rec: 6.1  p_oe_order_header_id = ' || p_oe_order_header_id, 4);
      END IF;

      create_rma_drct_dlvr_rti_rec(
        p_move_order_header_id     => p_move_order_header_id
      , p_organization_id          => p_organization_id
      , p_oe_order_header_id       => p_oe_order_header_id
      , p_oe_order_line_id         => NULL
      , p_item_id                  => p_item_id
      , p_rcv_qty                  => p_rcv_qty
      , p_rcv_uom                  => p_rcv_uom
      , p_rcv_uom_code             => p_rcv_uom_code
      , p_source_type              => p_source_type
      , p_subinventory             => p_subinventory
      , p_locator_id               => p_locator_id
      , p_transaction_temp_id      => p_transaction_temp_id
      , p_lot_control_code         => p_lot_control_code
      , p_serial_control_code      => p_serial_control_code
      , p_lpn_id                   => p_lpn_id
      , p_revision                 => p_revision
      , x_status                   => l_return_status
      , x_message                  => x_message
      , p_project_id               => p_project_id
      , p_task_id                  => p_task_id
      , p_country_code             => p_country_code
      , p_secondary_rcv_qty        => p_secondary_rcv_qty  --OPM Convergence
      , p_rcv_sec_uom              => p_rcv_sec_uom --OPM Convergence
      , p_rcv_sec_uom_code         => p_rcv_sec_uom_code --OPM Convergence
      , p_attribute_category       => p_attribute_category
      , p_attribute1               => p_attribute1
      , p_attribute2               => p_attribute2
      , p_attribute3               => p_attribute3
      , p_attribute4               => p_attribute4
      , p_attribute5               => p_attribute5
      , p_attribute6               => p_attribute6
      , p_attribute7               => p_attribute7
      , p_attribute8               => p_attribute8
      , p_attribute9               => p_attribute9
      , p_attribute10              => p_attribute10
      , p_attribute11              => p_attribute11
      , p_attribute12              => p_attribute12
      , p_attribute13              => p_attribute13
      , p_attribute14              => p_attribute14
      , p_attribute15              => p_attribute15
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_direct_rti_rec 50.1: create_rma_drct_dlvr_rti_rec RAISE FND_API.G_EXC_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('INV', 'INV_RCV_CREATE_RMA_RTI_FAIL'); -- MSGTBD
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug(
               'create_direct_rti_rec 50.2: create_rma_drct_dlvr_rti_rec RAISE FND_API.G_EXC_UNEXPECTED_ERROR;'
            || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    l_progress := '80';

    IF (l_debug = 1) THEN
      print_debug('create_direct_rti_rec calling print_label: 6' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    x_status := l_return_status; -- l_return_status can be 'W', we want to carry that over

                                 -- calling label printing API

    IF l_return_status <> fnd_api.g_ret_sts_error THEN
      l_progress := '80';

      IF (l_debug = 1) THEN
        print_debug('create_direct_rti_rec: 8.1 before  inv_label.print_label ' || inv_rcv_common_apis.g_rcv_global_var.interface_group_id, 4);
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If INV J and PO J are installed, do not call label printing API at this stage
       */
      IF ((inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po) OR
          (inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j)) THEN

       IF (p_source_type <> 'VENDOR') THEN  --Bug #4079952.. For PO receipt code in rcv_insert_update_header(INVSTDRB.pls) will be called.

        l_counter := 1;
        OPEN c_rti_txn_id;

        LOOP
          FETCH c_rti_txn_id INTO l_txn_id_tbl(l_counter);
          EXIT WHEN c_rti_txn_id%NOTFOUND;

          IF (l_debug = 1) THEN
            print_debug('create_direct_rti_rec calling printing for:' || l_txn_id_tbl(l_counter), 4);
          END IF;

          l_counter := l_counter + 1;
        END LOOP;

        CLOSE c_rti_txn_id;
        inv_label.print_label(
          x_return_status          => l_return_status
        , x_msg_count              => l_msg_count
        , x_msg_data               => l_msg_data
        , x_label_status           => l_label_status
        , p_api_version            => 1.0
        , p_print_mode             => 1
        , p_business_flow_code     => 1
        , p_transaction_id         => l_txn_id_tbl
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          fnd_message.set_name('INV', 'INV_RCV_CRT_PRINT_LAB_FAIL'); -- MSGTBD
          fnd_msg_pub.ADD;
          x_status := 'W';

          IF (l_debug = 1) THEN
            print_debug('create_direct_rti_rec 8.2: inv_label.print_label FAILED;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
          END IF;   --END IF l_debug = 1
        END IF;   --END IF label ret status <> S
       END IF ; --Bug #4079952
      ELSE
        IF (l_debug = 1) THEN
          print_debug('INV J and PO J are installed. NO label printing from UI', 4);
        END IF;
      END IF;   --END IF INV J and PO J installed
    END IF;   --END IF ret status = Successs

    IF (l_debug = 1) THEN
      print_debug('create_direct_rti_rec exiting print_label: 7' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
    END IF;

    IF (l_debug = 1) THEN
      print_debug('About exit create_direct_rti_rec: 8' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('create_direct_rti_rec: 8.1   - x_status = ' || x_status, 4);
      print_debug('create_direct_rti_rec: 8.2   -  x_message= ' || x_message, 4);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
    WHEN OTHERS THEN
      x_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_dir_rcpt_apis.create_direct_rti_rec', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_message);
  END create_direct_rti_rec;
/*
PROCEDURE pack_lpn_txn
  IS
     l_proc_msg VARCHAR2(400);
     l_return_status NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      print_debug('Enter pack_lpn_txn: 1'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')  , 1);
   END IF;

   l_return_status := inv_lpn_trx_pub.process_lpn_trx
     (p_trx_hdr_id => inv_rcv_common_apis.g_rcv_global_var.transaction_header_id,
      p_mode => 2,  -- putaway mode
      p_commit => 'F',
      x_proc_msg => l_proc_msg);

   IF (l_debug = 1) THEN
      print_debug('About exit pack_lpn_txn: 2'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS')  , 1);
   END IF;


END pack_lpn_txn;
*/
END inv_rcv_dir_rcpt_apis;

/
