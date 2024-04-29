--------------------------------------------------------
--  DDL for Package Body INV_RCV_COMMON_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RCV_COMMON_APIS" AS
  /* $Header: INVRCVCB.pls 120.17.12010000.15 2011/03/02 06:57:24 rdudani ship $*/

  --  Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30) := 'inv_RCV_COMMON_APIS';

  PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => 'inv_RCV_COMMON_APIS', p_level => p_level);
    END IF;
  END print_debug;

  PROCEDURE init_startup_values(p_organization_id IN NUMBER) IS
    l_message VARCHAR2(240);
    l_debug   NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('enter init_startup_values :  10', 1);
    END IF;

    -- query po_startup_value
    init_form_values(
      p_organization_id
    , g_po_startup_value.inv_org_id --bug 5195963
    , g_po_startup_value.org_name
    , g_po_startup_value.org_location
    , g_po_startup_value.sob_id
    , g_po_startup_value.ussgl_value
    , g_po_startup_value.period_name
    , g_po_startup_value.gl_date
    , g_po_startup_value.category_set_id
    , g_po_startup_value.structure_id
    , g_po_startup_value.user_id
    , g_po_startup_value.logon_id
    , g_po_startup_value.creation_date
    , g_po_startup_value.update_date
    , g_po_startup_value.inv_status
    , g_po_startup_value.po_status
    , g_po_startup_value.qa_status
    , g_po_startup_value.wip_status
    , g_po_startup_value.pa_status
    , g_po_startup_value.oe_status
    , g_po_startup_value.override_routing
    , g_po_startup_value.transaction_mode
    , g_po_startup_value.receipt_traveller
    , g_po_startup_value.receipt_num_code
    , g_po_startup_value.receipt_num_type
    , g_po_startup_value.po_num_type
    , g_po_startup_value.coa_id
    , g_po_startup_value.allow_express
    , g_po_startup_value.allow_cascade
    , g_po_startup_value.org_locator_control
    , g_po_startup_value.negative_inv_receipt_code
    , g_po_startup_value.gl_set_of_bks_id
    , g_po_startup_value.blind_receiving_flag
    , g_po_startup_value.allow_unordered
    , g_po_startup_value.display_inverse_rate
    , g_po_startup_value.currency_code
    , g_po_startup_value.project_reference_enabled
    , g_po_startup_value.project_control_level
    , g_po_startup_value.effectivity_control
    , g_po_startup_value.employee_id
    , g_po_startup_value.wms_install_status
    , g_po_startup_value.wms_purchased
    , l_message
    );

    IF (l_debug = 1) THEN
      print_debug('init_startup_values :  20', 4);
    END IF;

    IF g_rcv_global_var.transaction_header_id IS NULL THEN
      SELECT mtl_material_transactions_s.NEXTVAL
        INTO g_rcv_global_var.transaction_header_id
        FROM DUAL;
    END IF;

    gen_txn_group_id;

    IF (l_debug = 1) THEN
      print_debug('exit init_startup_values :  30', 1);
    END IF;
  END init_startup_values;

  -- Bug 4087032 Need to write a wrapper on LENGTH function as
  -- it creates compiltaion issues in 8i env.
  FUNCTION get_serial_length(p_from_ser IN VARCHAR2)
  return NUMBER is
  BEGIN
      return length(p_from_ser);
  END get_serial_length;

  -- for testing only   ??   need INV standard api for this
  FUNCTION get_to_serial_number(p_from_ser VARCHAR2, p_primary_quantity NUMBER)
    RETURN VARCHAR2 IS
    l_to_ser      VARCHAR2(30);
    l_number      NUMBER;
    l_temp_prefix VARCHAR2(30);
    l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    inv_validate.number_from_sequence(p_from_ser, l_temp_prefix, l_number);
    l_number  := l_number + p_primary_quantity - 1;
    l_to_ser  := SUBSTR(p_from_ser, 1, LENGTH(p_from_ser) - LENGTH(l_number)) || l_number;
    RETURN l_to_ser;
  END get_to_serial_number;

  PROCEDURE insert_mtlt(p_mtlt_rec mtl_transaction_lots_temp%ROWTYPE) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    INSERT INTO mtl_transaction_lots_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , transaction_quantity
               , primary_quantity
               , lot_number
               , lot_expiration_date
               , ERROR_CODE
               , serial_transaction_temp_id
               , group_header_id
               , put_away_rule_id
               , pick_rule_id
               , description
               , vendor_id
               , supplier_lot_number
               , territory_code
               , --country_of_origin,
                 origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , status_id
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , --kill_date,
                 best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_name
               , SECONDARY_QUANTITY --OPM Convergence
               , SECONDARY_UNIT_OF_MEASURE --OPM Convergence
                )
         VALUES (
                 p_mtlt_rec.transaction_temp_id
               , p_mtlt_rec.last_update_date
               , p_mtlt_rec.last_updated_by
               , p_mtlt_rec.creation_date
               , p_mtlt_rec.created_by
               , p_mtlt_rec.last_update_login
               , p_mtlt_rec.request_id
               , p_mtlt_rec.program_application_id
               , p_mtlt_rec.program_id
               , p_mtlt_rec.program_update_date
               , p_mtlt_rec.transaction_quantity
               , p_mtlt_rec.primary_quantity
               , p_mtlt_rec.lot_number
               , p_mtlt_rec.lot_expiration_date
               , p_mtlt_rec.ERROR_CODE
               , p_mtlt_rec.serial_transaction_temp_id
               , p_mtlt_rec.group_header_id
               , p_mtlt_rec.put_away_rule_id
               , p_mtlt_rec.pick_rule_id
               , p_mtlt_rec.description
               , p_mtlt_rec.vendor_id
               , p_mtlt_rec.supplier_lot_number
               , p_mtlt_rec.territory_code
               , --p_mtlt_rec.country_of_origin,
                 p_mtlt_rec.origination_date
               , p_mtlt_rec.date_code
               , p_mtlt_rec.grade_code
               , p_mtlt_rec.change_date
               , p_mtlt_rec.maturity_date
               , p_mtlt_rec.status_id
               , p_mtlt_rec.retest_date
               , p_mtlt_rec.age
               , p_mtlt_rec.item_size
               , p_mtlt_rec.color
               , p_mtlt_rec.volume
               , p_mtlt_rec.volume_uom
               , p_mtlt_rec.place_of_origin
               , --p_mtlt_rec.kill_date,
                 p_mtlt_rec.best_by_date
               , p_mtlt_rec.LENGTH
               , p_mtlt_rec.length_uom
               , p_mtlt_rec.recycled_content
               , p_mtlt_rec.thickness
               , p_mtlt_rec.thickness_uom
               , p_mtlt_rec.width
               , p_mtlt_rec.width_uom
               , p_mtlt_rec.curl_wrinkle_fold
               , p_mtlt_rec.lot_attribute_category
               , p_mtlt_rec.c_attribute1
               , p_mtlt_rec.c_attribute2
               , p_mtlt_rec.c_attribute3
               , p_mtlt_rec.c_attribute4
               , p_mtlt_rec.c_attribute5
               , p_mtlt_rec.c_attribute6
               , p_mtlt_rec.c_attribute7
               , p_mtlt_rec.c_attribute8
               , p_mtlt_rec.c_attribute9
               , p_mtlt_rec.c_attribute10
               , p_mtlt_rec.c_attribute11
               , p_mtlt_rec.c_attribute12
               , p_mtlt_rec.c_attribute13
               , p_mtlt_rec.c_attribute14
               , p_mtlt_rec.c_attribute15
               , p_mtlt_rec.c_attribute16
               , p_mtlt_rec.c_attribute17
               , p_mtlt_rec.c_attribute18
               , p_mtlt_rec.c_attribute19
               , p_mtlt_rec.c_attribute20
               , p_mtlt_rec.d_attribute1
               , p_mtlt_rec.d_attribute2
               , p_mtlt_rec.d_attribute3
               , p_mtlt_rec.d_attribute4
               , p_mtlt_rec.d_attribute5
               , p_mtlt_rec.d_attribute6
               , p_mtlt_rec.d_attribute7
               , p_mtlt_rec.d_attribute8
               , p_mtlt_rec.d_attribute9
               , p_mtlt_rec.d_attribute10
               , p_mtlt_rec.n_attribute1
               , p_mtlt_rec.n_attribute2
               , p_mtlt_rec.n_attribute3
               , p_mtlt_rec.n_attribute4
               , p_mtlt_rec.n_attribute5
               , p_mtlt_rec.n_attribute6
               , p_mtlt_rec.n_attribute7
               , p_mtlt_rec.n_attribute8
               , p_mtlt_rec.n_attribute9
               , p_mtlt_rec.n_attribute10
               , p_mtlt_rec.vendor_name
               , p_mtlt_rec.SECONDARY_QUANTITY --OPM Convergence
               , p_mtlt_rec.SECONDARY_UNIT_OF_MEASURE --OPM Convergence
);
  END insert_mtlt;

  --bug# 2783559
  -- Nested LPn changes.

  PROCEDURE check_lot_serial_codes(
    p_lpn_id             IN            NUMBER
  , p_req_header_id      IN            NUMBER
  , p_shipment_header_id IN            NUMBER
  , x_lot_ser_flag       OUT NOCOPY    VARCHAR2
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  ) IS
    -- Nested LPN changes changed the cursor to get all items within an LPN
    -- along with its child LPNs.

    -- Bug 3440456
    -- The following cursor is changed for performance
    --
    /*
    CURSOR get_all_items_in_lpn(p_lpn_id NUMBER) IS
      SELECT wlc.inventory_item_id
        FROM wms_lpn_contents wlc, wms_license_plate_numbers wln
       WHERE wln.lpn_id = wlc.parent_lpn_id
         AND lpn_id IN(SELECT     lpn_id
                             FROM wms_license_plate_numbers
                       START WITH lpn_id = p_lpn_id
                       CONNECT BY parent_lpn_id = PRIOR lpn_id);
    */

    CURSOR get_all_items_in_lpn(p_lpn_id NUMBER) IS
      SELECT wlc.inventory_item_id
        FROM wms_lpn_contents wlc
       WHERE wlc.parent_lpn_id
                       IN ( SELECT lpn_id
                              FROM wms_license_plate_numbers
                       START WITH lpn_id = p_lpn_id
                       CONNECT BY parent_lpn_id = PRIOR lpn_id);

    l_item_id       NUMBER;
    l_return_status VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
    l_lot_ser_flag  VARCHAR(1)     := 'Y';
    l_debug         NUMBER         := 1;
  BEGIN
    l_lot_ser_flag  := 'Y'; -- 'Y -match ' 'N- not match'
    l_progress      := 10;

    IF (l_debug = 1) THEN
      print_debug('lpn_id: ' || TO_CHAR(p_lpn_id), 1);
      print_debug('shipment num : ' || p_shipment_header_id, 1);
      print_debug(' req num: ' || p_req_header_id, 1);
    END IF;

    OPEN get_all_items_in_lpn(p_lpn_id);

    LOOP
      FETCH get_all_items_in_lpn INTO l_item_id;
      EXIT WHEN get_all_items_in_lpn%NOTFOUND;

      IF p_req_header_id IS NOT NULL THEN
        SELECT 'N'
          INTO l_lot_ser_flag
          FROM po_requisition_headers prh, po_requisition_lines prl, rcv_shipment_lines rsl, mtl_system_items msi1, mtl_system_items msi2
         WHERE prh.requisition_header_id = p_req_header_id
           AND prl.requisition_header_id = prh.requisition_header_id
           AND rsl.requisition_line_id = prl.requisition_line_id
           AND rsl.item_id = msi1.inventory_item_id
           AND rsl.item_id = l_item_id
           AND msi1.organization_id = rsl.from_organization_id
           AND(
               (NVL(msi1.lot_control_code, 1) = 1
                AND NVL(msi2.lot_control_code, 1) = 2)
               OR(NVL(msi1.serial_number_control_code, 1) IN(1, 6)
                  AND NVL(msi2.serial_number_control_code, 1) IN(2, 5))
               OR(NVL(msi1.revision_qty_control_code, 1) = 1
                  AND NVL(msi2.revision_qty_control_code, 1) = 2)
              )
           AND rsl.item_id = msi2.inventory_item_id
           AND msi2.organization_id = rsl.to_organization_id
           AND ROWNUM = 1;
      ELSIF p_shipment_header_id IS NOT NULL THEN
        SELECT 'N'
          INTO l_lot_ser_flag
          FROM rcv_shipment_lines rsl, rcv_shipment_headers rsh, mtl_system_items msi1, mtl_system_items msi2
         WHERE rsh.shipment_header_id = p_shipment_header_id
           AND rsl.shipment_header_id = rsh.shipment_header_id
           AND rsl.item_id = msi1.inventory_item_id
           AND msi1.organization_id = rsl.from_organization_id
           AND rsl.item_id = l_item_id
           AND(
               (NVL(msi1.lot_control_code, 1) = 1
                AND NVL(msi2.lot_control_code, 1) = 2)
               OR(NVL(msi1.serial_number_control_code, 1) IN(1, 6)
                  AND NVL(msi2.serial_number_control_code, 1) IN(2, 5))
               OR(NVL(msi1.revision_qty_control_code, 1) = 1
                  AND NVL(msi2.revision_qty_control_code, 1) = 2)
              )
           AND rsl.item_id = msi2.inventory_item_id
           AND msi2.organization_id = rsl.to_organization_id
           AND ROWNUM = 1;
      END IF;

      IF (l_lot_ser_flag = 'N') THEN
        EXIT;
      END IF;
    END LOOP;

    x_lot_ser_flag  := l_lot_ser_flag;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN -- item controls are valid
      x_lot_ser_flag  := 'Y';
    WHEN OTHERS THEN
      x_lot_ser_flag   := 'N';
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      print_debug(SQLCODE, 1);

      IF get_all_items_in_lpn%ISOPEN THEN
        CLOSE get_all_items_in_lpn;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('check_lot_serial_codes', l_progress, SQLCODE);
      END IF;
  END check_lot_serial_codes;

  PROCEDURE insert_msnt(p_msnt_rec mtl_serial_numbers_temp%ROWTYPE) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    INSERT INTO mtl_serial_numbers_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , request_id
               , program_application_id
               , program_id
               , program_update_date
               , vendor_serial_number
               , vendor_lot_number
               , fm_serial_number
               , to_serial_number
               , serial_prefix
               , ERROR_CODE
               , group_header_id
               , parent_serial_number
               , end_item_unit_number
               , serial_attribute_category
               , territory_code
               , --country_of_origin,
                 origination_date
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , status_id
               , time_since_new
               , cycles_since_new
               , time_since_overhaul
               , cycles_since_overhaul
               , time_since_repair
               , cycles_since_repair
               , time_since_visit
               , cycles_since_visit
               , time_since_mark
               , cycles_since_mark
               , number_of_repairs
                )
         VALUES (
                 p_msnt_rec.transaction_temp_id
               , p_msnt_rec.last_update_date
               , p_msnt_rec.last_updated_by
               , p_msnt_rec.creation_date
               , p_msnt_rec.created_by
               , p_msnt_rec.last_update_login
               , p_msnt_rec.request_id
               , p_msnt_rec.program_application_id
               , p_msnt_rec.program_id
               , p_msnt_rec.program_update_date
               , p_msnt_rec.vendor_serial_number
               , p_msnt_rec.vendor_lot_number
               , p_msnt_rec.fm_serial_number
               , p_msnt_rec.to_serial_number
               , p_msnt_rec.serial_prefix
               , p_msnt_rec.ERROR_CODE
               , p_msnt_rec.group_header_id
               , p_msnt_rec.parent_serial_number
               , p_msnt_rec.end_item_unit_number
               , p_msnt_rec.serial_attribute_category
               , p_msnt_rec.territory_code
               , --p_msnt_rec.country_of_origin,
                 p_msnt_rec.origination_date
               , p_msnt_rec.c_attribute1
               , p_msnt_rec.c_attribute2
               , p_msnt_rec.c_attribute3
               , p_msnt_rec.c_attribute4
               , p_msnt_rec.c_attribute5
               , p_msnt_rec.c_attribute6
               , p_msnt_rec.c_attribute7
               , p_msnt_rec.c_attribute8
               , p_msnt_rec.c_attribute9
               , p_msnt_rec.c_attribute10
               , p_msnt_rec.c_attribute11
               , p_msnt_rec.c_attribute12
               , p_msnt_rec.c_attribute13
               , p_msnt_rec.c_attribute14
               , p_msnt_rec.c_attribute15
               , p_msnt_rec.c_attribute16
               , p_msnt_rec.c_attribute17
               , p_msnt_rec.c_attribute18
               , p_msnt_rec.c_attribute19
               , p_msnt_rec.c_attribute20
               , p_msnt_rec.d_attribute1
               , p_msnt_rec.d_attribute2
               , p_msnt_rec.d_attribute3
               , p_msnt_rec.d_attribute4
               , p_msnt_rec.d_attribute5
               , p_msnt_rec.d_attribute6
               , p_msnt_rec.d_attribute7
               , p_msnt_rec.d_attribute8
               , p_msnt_rec.d_attribute9
               , p_msnt_rec.d_attribute10
               , p_msnt_rec.n_attribute1
               , p_msnt_rec.n_attribute2
               , p_msnt_rec.n_attribute3
               , p_msnt_rec.n_attribute4
               , p_msnt_rec.n_attribute5
               , p_msnt_rec.n_attribute6
               , p_msnt_rec.n_attribute7
               , p_msnt_rec.n_attribute8
               , p_msnt_rec.n_attribute9
               , p_msnt_rec.n_attribute10
               , p_msnt_rec.status_id
               , p_msnt_rec.time_since_new
               , p_msnt_rec.cycles_since_new
               , p_msnt_rec.time_since_overhaul
               , p_msnt_rec.cycles_since_overhaul
               , p_msnt_rec.time_since_repair
               , p_msnt_rec.cycles_since_repair
               , p_msnt_rec.time_since_visit
               , p_msnt_rec.cycles_since_visit
               , p_msnt_rec.time_since_mark
               , p_msnt_rec.cycles_since_mark
               , p_msnt_rec.number_of_repairs
                );
  END insert_msnt;

  FUNCTION break_serials_only(p_original_tid IN mtl_serial_numbers_temp.transaction_temp_id%TYPE, p_new_transactions_tb IN trans_rec_tb_tp)
    RETURN BOOLEAN IS
    CURSOR c_serials IS
      SELECT *
        FROM mtl_serial_numbers_temp
       WHERE transaction_temp_id = p_original_tid;

    l_msnt_rec                mtl_serial_numbers_temp%ROWTYPE;
    l_new_transaction_temp_id mtl_serial_numbers_temp.transaction_temp_id%TYPE;
    l_new_primary_quantity    NUMBER; -- the quanity user wants to split
    l_transaction_temp_id     mtl_transaction_lots_temp.transaction_temp_id%TYPE;
    l_from_ser                mtl_serial_numbers_temp.fm_serial_number%TYPE;
    l_to_ser                  mtl_serial_numbers_temp.to_serial_number%TYPE;
    l_new_ser                 mtl_serial_numbers_temp.fm_serial_number%TYPE;
    l_from_ser_num            NUMBER; -- number part of from serial
    l_to_ser_num              NUMBER; -- number part of to serial
    l_primary_quantity        NUMBER; -- the quantity within this serial record
    l_prefix_temp             VARCHAR2(30);
    l_debug                   NUMBER                                               := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    FOR i IN 1 .. p_new_transactions_tb.COUNT LOOP -- Loop through all the transaction lines need to be splitted
      l_new_transaction_temp_id  := p_new_transactions_tb(i).transaction_id;
      l_new_primary_quantity     := p_new_transactions_tb(i).primary_quantity;
      OPEN c_serials;

      LOOP -- Loop through all the lot record for this transaction
        FETCH c_serials INTO l_msnt_rec;
        EXIT WHEN c_serials%NOTFOUND;
        l_from_ser             := l_msnt_rec.fm_serial_number;
        l_to_ser               := l_msnt_rec.to_serial_number;
        -- get the actual number of from and to serial
        inv_validate.number_from_sequence(l_from_ser, l_prefix_temp, l_from_ser_num);
        inv_validate.number_from_sequence(l_to_ser, l_prefix_temp, l_to_ser_num);
        l_primary_quantity     := l_to_ser_num - l_from_ser_num + 1; -- initial qty for this ser record
        l_transaction_temp_id  := l_msnt_rec.transaction_temp_id; -- initial txn_int_id for this ser rec

        IF (l_primary_quantity > l_new_primary_quantity) -- new quantity detailed completely
                                                         -- and there is remaining ser qty
                                                         THEN
          l_msnt_rec.transaction_temp_id  := l_new_transaction_temp_id;
          -- need standard INV api to replace this func
          l_msnt_rec.to_serial_number     := get_to_serial_number(l_from_ser, l_new_primary_quantity);
          insert_msnt(l_msnt_rec);                          -- insert one line with new to-ser-number and new txn_id
                                   -- Update the existing ser rec with start serial number  ??
          l_new_ser                       := get_to_serial_number(l_from_ser, l_new_primary_quantity + 1);

          UPDATE mtl_serial_numbers_temp
             SET fm_serial_number = l_new_ser
           WHERE transaction_temp_id = l_transaction_temp_id
             AND fm_serial_number = l_from_ser
             AND to_serial_number = l_to_ser;

          EXIT; -- exit serial loop
        ELSIF(l_primary_quantity < l_new_primary_quantity) THEN
          -- new quantity is partially detailed
          -- ser rec qty is exhausted
          -- need to continue ser loop in this case

          -- Update the ser rec with new transaction interface ID
          UPDATE mtl_serial_numbers_temp
             SET transaction_temp_id = l_new_transaction_temp_id
           WHERE transaction_temp_id = l_transaction_temp_id
             AND fm_serial_number = l_from_ser
             AND to_serial_number = l_to_ser;

          -- reduce the new qty
          l_new_primary_quantity  := l_new_primary_quantity - l_primary_quantity;
        ELSIF(l_primary_quantity = l_new_primary_quantity) THEN
          -- exact match

          -- Update the lot rec with new transaction interface ID
          UPDATE mtl_serial_numbers_temp
             SET transaction_temp_id = l_new_transaction_temp_id
           WHERE transaction_temp_id = l_transaction_temp_id
             AND fm_serial_number = l_from_ser
             AND to_serial_number = l_to_ser;

          EXIT; -- exit serial loop
        END IF;
      END LOOP; -- end serial loop

      CLOSE c_serials;
    END LOOP; -- end transaction line loop

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_serials%ISOPEN THEN
        CLOSE c_serials;
      END IF;

      RAISE;
  END break_serials_only;

  FUNCTION break_lots_only(p_original_tid IN mtl_transaction_lots_temp.transaction_temp_id%TYPE,
  p_new_transactions_tb IN trans_rec_tb_tp)
    RETURN BOOLEAN IS
    CURSOR c_lots IS
      SELECT   ROWID
             , transaction_temp_id
             , last_update_date
             , last_updated_by
             , creation_date
             , created_by
             , last_update_login
             , request_id
             , program_application_id
             , program_id
             , program_update_date
             , transaction_quantity
             , secondary_quantity --invconv kkillams
             , primary_quantity
             , lot_number
             , lot_expiration_date
             , ERROR_CODE
             , serial_transaction_temp_id
             , group_header_id
             , put_away_rule_id
             , pick_rule_id
             , description
             , vendor_id
             , supplier_lot_number
             , territory_code
             , origination_date
             , date_code
             , grade_code
             , change_date
             , maturity_date
             , status_id
             , retest_date
             , age
             , item_size
             , color
             , volume
             , volume_uom
             , place_of_origin
             , best_by_date
             , LENGTH
             , length_uom
             , recycled_content
             , thickness
             , thickness_uom
             , width
             , width_uom
             , curl_wrinkle_fold
             , lot_attribute_category
             , c_attribute1
             , c_attribute2
             , c_attribute3
             , c_attribute4
             , c_attribute5
             , c_attribute6
             , c_attribute7
             , c_attribute8
             , c_attribute9
             , c_attribute10
             , c_attribute11
             , c_attribute12
             , c_attribute13
             , c_attribute14
             , c_attribute15
             , c_attribute16
             , c_attribute17
             , c_attribute18
             , c_attribute19
             , c_attribute20
             , d_attribute1
             , d_attribute2
             , d_attribute3
             , d_attribute4
             , d_attribute5
             , d_attribute6
             , d_attribute7
             , d_attribute8
             , d_attribute9
             , d_attribute10
             , n_attribute1
             , n_attribute2
             , n_attribute3
             , n_attribute4
             , n_attribute5
             , n_attribute6
             , n_attribute7
             , n_attribute8
             , n_attribute9
             , n_attribute10
             , vendor_name
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_original_tid
      ORDER BY DECODE(
                 inv_rcv_common_apis.g_order_lots_by
               , inv_rcv_common_apis.g_order_lots_by_exp_date, lot_expiration_date
               , inv_rcv_common_apis.g_order_lots_by_creation_date, creation_date
               , lot_expiration_date
               );

    --Changed the order  by for bug 2422193
    --ORDER BY lot_expiration_date,creation_date;

    l_mtlt_rec                mtl_transaction_lots_temp%ROWTYPE;
    l_new_transaction_temp_id mtl_transaction_lots_temp.transaction_temp_id%TYPE;
    l_new_primary_quantity      NUMBER; -- the quanity user wants to split
    l_transaction_temp_id     mtl_transaction_lots_temp.transaction_temp_id%TYPE;
    l_primary_quantity          NUMBER; -- the primary qty for lot
    l_transaction_quantity       NUMBER;
    l_sec_transaction_quantity   NUMBER; --invconv kkillams
    l_new_secondary_quantity    NUMBER; -- the quanity user wants to split
    l_lot_number              mtl_transaction_lots_temp.lot_number%TYPE;
    --BUG 2673970
    l_rowid                   ROWID;
    l_debug                   NUMBER                                               := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    FOR i IN 1 .. p_new_transactions_tb.COUNT LOOP -- Loop through all the transaction lines need to be splitted
      l_new_transaction_temp_id  := p_new_transactions_tb(i).transaction_id;
      l_new_primary_quantity     := p_new_transactions_tb(i).primary_quantity;
      l_new_secondary_quantity     := p_new_transactions_tb(i).secondary_quantity;

      OPEN c_lots;
      LOOP -- Loop through all the lot record for this transaction

           --BUG 2673970
        FETCH c_lots INTO l_rowid
       , l_mtlt_rec.transaction_temp_id
       , l_mtlt_rec.last_update_date
       , l_mtlt_rec.last_updated_by
       , l_mtlt_rec.creation_date
       , l_mtlt_rec.created_by
       , l_mtlt_rec.last_update_login
       , l_mtlt_rec.request_id
       , l_mtlt_rec.program_application_id
       , l_mtlt_rec.program_id
       , l_mtlt_rec.program_update_date
       , l_mtlt_rec.transaction_quantity
       , l_mtlt_rec.secondary_quantity --invconv kkillams
       , l_mtlt_rec.primary_quantity
       , l_mtlt_rec.lot_number
       , l_mtlt_rec.lot_expiration_date
       , l_mtlt_rec.ERROR_CODE
       , l_mtlt_rec.serial_transaction_temp_id
       , l_mtlt_rec.group_header_id
       , l_mtlt_rec.put_away_rule_id
       , l_mtlt_rec.pick_rule_id
       , l_mtlt_rec.description
       , l_mtlt_rec.vendor_id
       , l_mtlt_rec.supplier_lot_number
       , l_mtlt_rec.territory_code
       , l_mtlt_rec.origination_date
       , l_mtlt_rec.date_code
       , l_mtlt_rec.grade_code
       , l_mtlt_rec.change_date
       , l_mtlt_rec.maturity_date
       , l_mtlt_rec.status_id
       , l_mtlt_rec.retest_date
       , l_mtlt_rec.age
       , l_mtlt_rec.item_size
       , l_mtlt_rec.color
       , l_mtlt_rec.volume
       , l_mtlt_rec.volume_uom
       , l_mtlt_rec.place_of_origin
       , l_mtlt_rec.best_by_date
       , l_mtlt_rec.LENGTH
       , l_mtlt_rec.length_uom
       , l_mtlt_rec.recycled_content
       , l_mtlt_rec.thickness
       , l_mtlt_rec.thickness_uom
       , l_mtlt_rec.width
       , l_mtlt_rec.width_uom
       , l_mtlt_rec.curl_wrinkle_fold
       , l_mtlt_rec.lot_attribute_category
       , l_mtlt_rec.c_attribute1
       , l_mtlt_rec.c_attribute2
       , l_mtlt_rec.c_attribute3
       , l_mtlt_rec.c_attribute4
       , l_mtlt_rec.c_attribute5
       , l_mtlt_rec.c_attribute6
       , l_mtlt_rec.c_attribute7
       , l_mtlt_rec.c_attribute8
       , l_mtlt_rec.c_attribute9
       , l_mtlt_rec.c_attribute10
       , l_mtlt_rec.c_attribute11
       , l_mtlt_rec.c_attribute12
       , l_mtlt_rec.c_attribute13
       , l_mtlt_rec.c_attribute14
       , l_mtlt_rec.c_attribute15
       , l_mtlt_rec.c_attribute16
       , l_mtlt_rec.c_attribute17
       , l_mtlt_rec.c_attribute18
       , l_mtlt_rec.c_attribute19
       , l_mtlt_rec.c_attribute20
       , l_mtlt_rec.d_attribute1
       , l_mtlt_rec.d_attribute2
       , l_mtlt_rec.d_attribute3
       , l_mtlt_rec.d_attribute4
       , l_mtlt_rec.d_attribute5
       , l_mtlt_rec.d_attribute6
       , l_mtlt_rec.d_attribute7
       , l_mtlt_rec.d_attribute8
       , l_mtlt_rec.d_attribute9
       , l_mtlt_rec.d_attribute10
       , l_mtlt_rec.n_attribute1
       , l_mtlt_rec.n_attribute2
       , l_mtlt_rec.n_attribute3
       , l_mtlt_rec.n_attribute4
       , l_mtlt_rec.n_attribute5
       , l_mtlt_rec.n_attribute6
       , l_mtlt_rec.n_attribute7
       , l_mtlt_rec.n_attribute8
       , l_mtlt_rec.n_attribute9
       , l_mtlt_rec.n_attribute10
       , l_mtlt_rec.vendor_name;
        EXIT WHEN c_lots%NOTFOUND;
        l_primary_quantity      := l_mtlt_rec.primary_quantity; -- initial qty for this lot
        l_transaction_temp_id   := l_mtlt_rec.transaction_temp_id; -- initial txn_int_id for this lot
        l_lot_number            := l_mtlt_rec.lot_number;
        l_transaction_quantity  := l_mtlt_rec.transaction_quantity;
        l_sec_transaction_quantity  := l_mtlt_rec.secondary_quantity; --invconv kkillams

        IF (l_primary_quantity > l_new_primary_quantity)                                                -- new quantity detailed completely
                                                         -- and there is remaining lot qty
                                                         THEN
          l_mtlt_rec.transaction_temp_id   := l_new_transaction_temp_id;
          l_mtlt_rec.primary_quantity      := l_new_primary_quantity;
          l_mtlt_rec.transaction_quantity  := l_transaction_quantity * l_new_primary_quantity / l_primary_quantity;
          --invconv kkillams
	  IF  ( NVL(l_sec_transaction_quantity,-9999) > 0 ) THEN --9527367
	     l_mtlt_rec.secondary_quantity  := l_sec_transaction_quantity * l_new_secondary_quantity / l_sec_transaction_quantity;
          END IF;
          print_debug('insert_mtlt',1);
          insert_mtlt(l_mtlt_rec); -- insert one line with new quantity and new txn_id
          l_primary_quantity               := l_primary_quantity - l_new_primary_quantity;
          l_transaction_quantity           := l_transaction_quantity - l_mtlt_rec.transaction_quantity;
          --invconv kkillams
	  IF  ( NVL(l_sec_transaction_quantity,-9999) > 0 ) THEN  --9527367
	     l_sec_transaction_quantity       := l_sec_transaction_quantity -  l_mtlt_rec.secondary_quantity ;
          END IF;

          print_debug('Update 1 mtl_transaction_lots_temp',1);
          -- Update the existing lot rec with reduced quantity
          UPDATE mtl_transaction_lots_temp
             SET primary_quantity = l_primary_quantity
               , transaction_quantity = l_transaction_quantity
               , secondary_quantity = l_sec_transaction_quantity
           WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          EXIT; -- exit lot loop
        ELSIF(l_primary_quantity < l_new_primary_quantity) THEN
          -- new quantity is partially detailed
          -- lot qty is exhausted
          -- need to continue lot loop in this case

          -- Update the lot rec with new transaction interface ID
          print_debug('Update 2 mtl_transaction_lots_temp',1);
          UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
           WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          -- reduce the new qty
          l_new_primary_quantity  := l_new_primary_quantity - l_primary_quantity;
          l_new_secondary_quantity  := l_new_secondary_quantity - l_sec_transaction_quantity; --invconv kkillams
        ELSIF(l_primary_quantity = l_new_primary_quantity) THEN
          -- exact match

          print_debug('Update 3 mtl_transaction_lots_temp',1);
          -- Update the lot rec with new transaction interface ID
          UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
           WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          EXIT; -- exit lot loop
        END IF;
      END LOOP; -- end lot loop

      CLOSE c_lots;
    END LOOP; -- end transaction line loop

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_lots%ISOPEN THEN
        CLOSE c_lots;
      END IF;

      RAISE;
  END break_lots_only;

  FUNCTION break_lots_serials(
    p_original_tid        IN mtl_transaction_lots_temp.transaction_temp_id%TYPE
  , p_new_transactions_tb IN trans_rec_tb_tp
  )
    RETURN BOOLEAN IS
    CURSOR c_lots IS
      SELECT   ROWID
             , transaction_temp_id
             , last_update_date
             , last_updated_by
             , creation_date
             , created_by
             , last_update_login
             , request_id
             , program_application_id
             , program_id
             , program_update_date
             , transaction_quantity
             , secondary_quantity --invconv kkillams
             , primary_quantity
             , lot_number
             , lot_expiration_date
             , ERROR_CODE
             , serial_transaction_temp_id
             , group_header_id
             , put_away_rule_id
             , pick_rule_id
             , description
             , vendor_id
             , supplier_lot_number
             , territory_code
             , origination_date
             , date_code
             , grade_code
             , change_date
             , maturity_date
             , status_id
             , retest_date
             , age
             , item_size
             , color
             , volume
             , volume_uom
             , place_of_origin
             , best_by_date
             , LENGTH
             , length_uom
             , recycled_content
             , thickness
             , thickness_uom
             , width
             , width_uom
             , curl_wrinkle_fold
             , lot_attribute_category
             , c_attribute1
             , c_attribute2
             , c_attribute3
             , c_attribute4
             , c_attribute5
             , c_attribute6
             , c_attribute7
             , c_attribute8
             , c_attribute9
             , c_attribute10
             , c_attribute11
             , c_attribute12
             , c_attribute13
             , c_attribute14
             , c_attribute15
             , c_attribute16
             , c_attribute17
             , c_attribute18
             , c_attribute19
             , c_attribute20
             , d_attribute1
             , d_attribute2
             , d_attribute3
             , d_attribute4
             , d_attribute5
             , d_attribute6
             , d_attribute7
             , d_attribute8
             , d_attribute9
             , d_attribute10
             , n_attribute1
             , n_attribute2
             , n_attribute3
             , n_attribute4
             , n_attribute5
             , n_attribute6
             , n_attribute7
             , n_attribute8
             , n_attribute9
             , n_attribute10
             , vendor_name
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_original_tid
      ORDER BY DECODE(
                 inv_rcv_common_apis.g_order_lots_by
               , inv_rcv_common_apis.g_order_lots_by_exp_date, lot_expiration_date
               , inv_rcv_common_apis.g_order_lots_by_creation_date, creation_date
               , lot_expiration_date
               );

    --Changed the order  by for bug 2422193
    --ORDER BY lot_expiration_date,creation_date;
    l_mtlt_rec                   mtl_transaction_lots_temp%ROWTYPE;
    l_new_transaction_temp_id    mtl_transaction_lots_temp.transaction_temp_id%TYPE;
    l_new_primary_quantity       NUMBER; -- the quanity user wants to split
    l_transaction_temp_id        mtl_transaction_lots_temp.transaction_temp_id%TYPE;
    l_primary_quantity           NUMBER; -- the transaction qty for lot
    l_transaction_quantity       NUMBER;
    l_lot_number                 mtl_transaction_lots_temp.lot_number%TYPE;
    l_serial_transaction_temp_id mtl_serial_numbers_temp.transaction_temp_id%TYPE;
    l_tran_rec_tb                trans_rec_tb_tp;
    l_sec_transaction_quantity   NUMBER; --invconv kkillams
    l_new_secondary_quantity    NUMBER; -- the quanity user wants to split
    --BUG 2673970
    l_rowid                      ROWID;
    l_debug                      NUMBER                                               := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

  BEGIN
    FOR i IN 1 .. p_new_transactions_tb.COUNT LOOP -- Loop through all the transaction lines need to be splitted
      l_new_transaction_temp_id  := p_new_transactions_tb(i).transaction_id;
      l_new_primary_quantity     := p_new_transactions_tb(i).primary_quantity;
      l_new_secondary_quantity   := p_new_transactions_tb(i).secondary_quantity; --invconv
      OPEN c_lots;

      LOOP -- Loop through all the lot record for this transaction

           --BUG 2673970
        FETCH c_lots INTO l_rowid
       , l_mtlt_rec.transaction_temp_id
       , l_mtlt_rec.last_update_date
       , l_mtlt_rec.last_updated_by
       , l_mtlt_rec.creation_date
       , l_mtlt_rec.created_by
       , l_mtlt_rec.last_update_login
       , l_mtlt_rec.request_id
       , l_mtlt_rec.program_application_id
       , l_mtlt_rec.program_id
       , l_mtlt_rec.program_update_date
       , l_mtlt_rec.transaction_quantity
       , l_mtlt_rec.secondary_quantity --invconv kkillams
       , l_mtlt_rec.primary_quantity
       , l_mtlt_rec.lot_number
       , l_mtlt_rec.lot_expiration_date
       , l_mtlt_rec.ERROR_CODE
       , l_mtlt_rec.serial_transaction_temp_id
       , l_mtlt_rec.group_header_id
       , l_mtlt_rec.put_away_rule_id
       , l_mtlt_rec.pick_rule_id
       , l_mtlt_rec.description
       , l_mtlt_rec.vendor_id
       , l_mtlt_rec.supplier_lot_number
       , l_mtlt_rec.territory_code
       , l_mtlt_rec.origination_date
       , l_mtlt_rec.date_code
       , l_mtlt_rec.grade_code
       , l_mtlt_rec.change_date
       , l_mtlt_rec.maturity_date
       , l_mtlt_rec.status_id
       , l_mtlt_rec.retest_date
       , l_mtlt_rec.age
       , l_mtlt_rec.item_size
       , l_mtlt_rec.color
       , l_mtlt_rec.volume
       , l_mtlt_rec.volume_uom
       , l_mtlt_rec.place_of_origin
       , l_mtlt_rec.best_by_date
       , l_mtlt_rec.LENGTH
       , l_mtlt_rec.length_uom
       , l_mtlt_rec.recycled_content
       , l_mtlt_rec.thickness
       , l_mtlt_rec.thickness_uom
       , l_mtlt_rec.width
       , l_mtlt_rec.width_uom
       , l_mtlt_rec.curl_wrinkle_fold
       , l_mtlt_rec.lot_attribute_category
       , l_mtlt_rec.c_attribute1
       , l_mtlt_rec.c_attribute2
       , l_mtlt_rec.c_attribute3
       , l_mtlt_rec.c_attribute4
       , l_mtlt_rec.c_attribute5
       , l_mtlt_rec.c_attribute6
       , l_mtlt_rec.c_attribute7
       , l_mtlt_rec.c_attribute8
       , l_mtlt_rec.c_attribute9
       , l_mtlt_rec.c_attribute10
       , l_mtlt_rec.c_attribute11
       , l_mtlt_rec.c_attribute12
       , l_mtlt_rec.c_attribute13
       , l_mtlt_rec.c_attribute14
       , l_mtlt_rec.c_attribute15
       , l_mtlt_rec.c_attribute16
       , l_mtlt_rec.c_attribute17
       , l_mtlt_rec.c_attribute18
       , l_mtlt_rec.c_attribute19
       , l_mtlt_rec.c_attribute20
       , l_mtlt_rec.d_attribute1
       , l_mtlt_rec.d_attribute2
       , l_mtlt_rec.d_attribute3
       , l_mtlt_rec.d_attribute4
       , l_mtlt_rec.d_attribute5
       , l_mtlt_rec.d_attribute6
       , l_mtlt_rec.d_attribute7
       , l_mtlt_rec.d_attribute8
       , l_mtlt_rec.d_attribute9
       , l_mtlt_rec.d_attribute10
       , l_mtlt_rec.n_attribute1
       , l_mtlt_rec.n_attribute2
       , l_mtlt_rec.n_attribute3
       , l_mtlt_rec.n_attribute4
       , l_mtlt_rec.n_attribute5
       , l_mtlt_rec.n_attribute6
       , l_mtlt_rec.n_attribute7
       , l_mtlt_rec.n_attribute8
       , l_mtlt_rec.n_attribute9
       , l_mtlt_rec.n_attribute10
       , l_mtlt_rec.vendor_name;
        EXIT WHEN c_lots%NOTFOUND;
        l_primary_quantity            := l_mtlt_rec.primary_quantity; -- initial qty for this lot
        l_transaction_temp_id         := l_mtlt_rec.transaction_temp_id; -- initial txn_int_id for this lot
        l_serial_transaction_temp_id  := l_mtlt_rec.serial_transaction_temp_id;
        l_lot_number                  := l_mtlt_rec.lot_number;
        l_sec_transaction_quantity    := l_mtlt_rec.secondary_quantity; -- initial qty for this lot

        IF (l_primary_quantity > l_new_primary_quantity)                                                -- new quantity detailed completely
                                                         -- and there is remaining lot qty
                                                         THEN
          l_mtlt_rec.transaction_temp_id     := l_new_transaction_temp_id;
          l_mtlt_rec.primary_quantity        := l_new_primary_quantity;
          l_transaction_quantity             := l_mtlt_rec.transaction_quantity;
          l_mtlt_rec.secondary_quantity      := l_new_secondary_quantity;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_mtlt_rec.serial_transaction_temp_id
            FROM DUAL;

          l_mtlt_rec.transaction_quantity    := l_transaction_quantity * l_new_primary_quantity / l_primary_quantity;
          insert_mtlt(l_mtlt_rec); -- insert one line with new quantity and new txn_id
          l_tran_rec_tb(1).transaction_id    := l_mtlt_rec.serial_transaction_temp_id;
          l_tran_rec_tb(1).primary_quantity  := l_new_primary_quantity;
	  IF ( NVL(l_mtlt_rec.secondary_quantity,-99999) > 0 AND NVL(l_sec_transaction_quantity,-9999) > 0  )  THEN --9527367
	     l_mtlt_rec.secondary_quantity      := l_sec_transaction_quantity * l_new_secondary_quantity / l_sec_transaction_quantity;
          END IF;

          IF break_serials_only(l_serial_transaction_temp_id, l_tran_rec_tb) THEN
            NULL;
          END IF;

          l_primary_quantity                 := l_primary_quantity - l_new_primary_quantity;
          l_transaction_quantity             := l_transaction_quantity - l_mtlt_rec.transaction_quantity;
          l_sec_transaction_quantity         := l_sec_transaction_quantity - l_mtlt_rec.secondary_quantity;

          -- Update the existing lot rec with reduced quantity
          UPDATE mtl_transaction_lots_temp
             SET primary_quantity = l_primary_quantity
               , transaction_quantity = l_transaction_quantity
               , secondary_quantity = l_sec_transaction_quantity
           WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          EXIT; -- exit lot loop
        ELSIF(l_primary_quantity < l_new_primary_quantity) THEN
          -- new quantity is partially detailed
          -- lot qty is exhausted
          -- need to continue lot loop in this case

          -- Update the lot rec with new transaction interface ID
          UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
           WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          -- reduce the new qty
          l_new_primary_quantity           := l_new_primary_quantity - l_primary_quantity;
          l_new_secondary_quantity       := l_new_secondary_quantity - l_sec_transaction_quantity;
        ELSIF(l_primary_quantity = l_new_primary_quantity) THEN
          -- exact match

          -- Update the lot rec with new transaction interface ID
          UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
           WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          EXIT; -- exit lot loop
        END IF;
      END LOOP; -- end lot loop

      CLOSE c_lots;
    END LOOP; -- end transaction line loop

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_lots%ISOPEN THEN
        CLOSE c_lots;
      END IF;

      RAISE;
  END break_lots_serials;

  PROCEDURE BREAK(
    p_original_tid        IN mtl_transaction_lots_temp.transaction_temp_id%TYPE
  , p_new_transactions_tb IN trans_rec_tb_tp
  , p_lot_control_code    IN NUMBER
  , p_serial_control_code IN NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
   print_debug('Entered BREAK',1);
    --lots and not serials -- ?? VERIFY THIS
    IF (p_lot_control_code = 2
        AND p_serial_control_code IN(1)) THEN
       print_debug('break_lots_only',1);
      IF break_lots_only(p_original_tid, p_new_transactions_tb) THEN
        NULL;
      END IF;
    --serials not lots
      -- Toshiba Fixes for RMA
    ELSIF(p_lot_control_code = 1
          AND p_serial_control_code NOT IN(1)) THEN
       print_debug('break_serials_only',1);
      IF break_serials_only(p_original_tid, p_new_transactions_tb) THEN
        NULL;
      END IF;
    --both lot and serial
    ELSIF(p_lot_control_code = 2
          AND p_serial_control_code NOT IN(1)) THEN
       print_debug('break_lots_serials',1);
      IF break_lots_serials(p_original_tid, p_new_transactions_tb) THEN
        NULL;
      END IF;
    END IF;
  END BREAK;

  PROCEDURE gen_receipt_num(
    x_receipt_num     OUT NOCOPY VARCHAR2
  , p_organization_id            NUMBER
  , x_return_status   OUT NOCOPY VARCHAR2
  , x_msg_count       OUT NOCOPY NUMBER
  , x_msg_data        OUT NOCOPY VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_receipt_exists NUMBER;
    l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(400);
    l_progress       VARCHAR2(10);
    l_receipt_code   VARCHAR2(25);
    l_temp_rcpt_num  VARCHAR(30); --bug6014386
    l_debug          NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '10';

    IF (l_debug = 1) THEN
      print_debug('Enter gen_receipt_num 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

  /* Commented for bug 6014386
    UPDATE rcv_parameters
       SET next_receipt_num = next_receipt_num + 1
     WHERE organization_id = p_organization_id;

    COMMIT;
    l_progress       := '20';

    SELECT TO_CHAR(next_receipt_num)
      INTO x_receipt_num
      FROM rcv_parameters
     WHERE organization_id = p_organization_id;

    l_progress       := '30';

    BEGIN
      SELECT 1
        INTO l_receipt_exists
        FROM rcv_shipment_headers rsh
       WHERE receipt_num = x_receipt_num
         AND ship_to_org_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_receipt_exists  := 0;
      WHEN OTHERS THEN
        RAISE; -- ? multi row selected
    END;

    l_progress       := '40';

    IF (l_receipt_exists = 1) THEN
      -- need to handle receipt_num generation error  ?
      po_message_s.app_error('RCV_RC_RESET_AUTO_NUMBER');
    END IF;

    Bug 6014386 , commented upto here*/

    /*Fix for bug6014386 Begin.
      If next receipt number is not unique, we need to loop through
       and find a unique number instead of erroring the transaction.  */

 	     SELECT to_char(next_receipt_num + 1)
 	         INTO l_temp_rcpt_num
 	        FROM rcv_parameters
 	        WHERE organization_id =  p_organization_id
 	         FOR UPDATE OF next_receipt_num;

 	     l_progress       := '20';

 	     LOOP
 	       SELECT COUNT(1)
 	          INTO   l_receipt_exists
 	         FROM   rcv_shipment_headers rsh
 	         WHERE  rsh.receipt_num = l_temp_rcpt_num
 	         AND   rsh.ship_to_org_id = p_organization_id ;

 	        IF l_receipt_exists = 0 THEN
 	             UPDATE rcv_parameters
 	              SET next_receipt_num = l_temp_rcpt_num
 	             WHERE organization_id = p_organization_id ;

 	             COMMIT;  --commit the autonomous transaction

 	             EXIT;
 	         ELSE
 	           l_temp_rcpt_num := TO_CHAR(TO_NUMBER(l_temp_rcpt_num) + 1);  --increment the receipt number
 	        END IF;
 	     END LOOP;

 	      x_receipt_num := l_temp_rcpt_num;

     --Bug6014386.End

    l_progress       := '50';

    IF (l_debug = 1) THEN
      print_debug('Exit gen_receipt_num 20 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.gen_receipt_num', l_progress, SQLCODE);
      END IF;

      fnd_message.set_name('PO', 'PO_SP_GET_NEXT_AUTO_RECEIPT_NM');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END gen_receipt_num;

  PROCEDURE rcv_gen_receipt_num(
    x_receipt_num     OUT NOCOPY VARCHAR2
  , p_organization_id            NUMBER
  , x_return_status   OUT NOCOPY VARCHAR2
  , x_msg_count       OUT NOCOPY NUMBER
  , x_msg_data        OUT NOCOPY VARCHAR2
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter rcv_gen_receipt_num 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF g_rcv_global_var.receipt_num IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('Receipt number is null', 4);
      END IF;

      inv_rcv_common_apis.gen_receipt_num(
        x_receipt_num                => g_rcv_global_var.receipt_num
      , p_organization_id            => p_organization_id
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Generated the receipt number:' || g_rcv_global_var.receipt_num, 4);
    END IF;

    x_receipt_num    := g_rcv_global_var.receipt_num;
  END rcv_gen_receipt_num;

  PROCEDURE rcv_clear_global IS
    l_return_status VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
    l_debug         NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    g_po_startup_value                              := NULL;
    g_rcv_global_var                                := NULL;
    g_lot_status_tb.DELETE;
    inv_rcv_std_rcpt_apis.g_shipment_header_id      := NULL;
    inv_rcv_std_rcpt_apis.g_rcpt_match_table_gross.DELETE;
    inv_rcv_std_rcpt_apis.g_receipt_detail_index    := 1;
    inv_rcv_std_rcpt_apis.g_dummy_lpn_id            := NULL;
    inv_rcv_std_deliver_apis.g_rcvtxn_detail_index  := 1;
    inv_rcv_std_deliver_apis.g_rcvtxn_match_table_gross.DELETE;

    --Calling the procedure to clear the Global variable which conatains Lot Numbers (Bug # 3156689)
    clear_lot_rec;

  -- clear the message stack.
    fnd_msg_pub.delete_msg;
    gen_txn_group_id;

    -- set wms_purchased flag
    IF wms_install.check_install(l_return_status, l_msg_count, l_msg_data, NULL) THEN
      -- calling lpn_pack_complete to revert the weight/volume change
      IF (l_debug = 1) THEN
        print_debug('Calling wms_container_pub.lpn_pack_complete  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        print_debug('wms_container_pub.G_LPN_WT_VOL_CHANGES.count  ' || wms_container_pub.g_lpn_wt_vol_changes.COUNT, 4);
      END IF;

      IF wms_container_pub.lpn_pack_complete(1) THEN
        NULL;
      END IF;
    END IF;

    -- Bug 2355294
    -- Clear the Label Printing Record Structure
    inv_label_pvt1.g_rcv_label_print_rec_tb.DELETE;
    COMMIT;
  END rcv_clear_global;

  PROCEDURE init_form_values(
    p_org_id                    IN            NUMBER
  , x_inv_org_id                OUT NOCOPY    NUMBER ----bug 5195963
  , x_org_name                  OUT NOCOPY    VARCHAR2
  , x_org_location              OUT NOCOPY    VARCHAR2
  , x_sob_id                    OUT NOCOPY    NUMBER
  , x_ussgl_value               OUT NOCOPY    VARCHAR2
  , x_period_name               OUT NOCOPY    VARCHAR2
  , x_gl_date                   OUT NOCOPY    DATE
  , x_category_set_id           OUT NOCOPY    NUMBER
  , x_structure_id              OUT NOCOPY    NUMBER
  , x_user_id                   OUT NOCOPY    NUMBER
  , x_logon_id                  OUT NOCOPY    NUMBER
  , x_creation_date             OUT NOCOPY    DATE
  , x_update_date               OUT NOCOPY    DATE
  , x_inv_status                OUT NOCOPY    VARCHAR2
  , x_po_status                 OUT NOCOPY    VARCHAR2
  , x_qa_status                 OUT NOCOPY    VARCHAR2
  , x_wip_status                OUT NOCOPY    VARCHAR2
  , x_pa_status                 OUT NOCOPY    VARCHAR2
  , x_oe_status                 OUT NOCOPY    VARCHAR2
  , x_override_routing          OUT NOCOPY    VARCHAR2
  , x_transaction_mode          OUT NOCOPY    VARCHAR2
  , x_receipt_traveller         OUT NOCOPY    VARCHAR2
  , x_receipt_num_code          OUT NOCOPY    VARCHAR2
  , x_receipt_num_type          OUT NOCOPY    VARCHAR2
  , x_po_num_type               OUT NOCOPY    VARCHAR2
  , x_coa_id                    OUT NOCOPY    NUMBER
  , x_allow_express             OUT NOCOPY    VARCHAR2
  , x_allow_cascade             OUT NOCOPY    VARCHAR2
  , x_org_locator_control       OUT NOCOPY    NUMBER
  , x_negative_inv_receipt_code OUT NOCOPY    NUMBER
  , x_gl_set_of_bks_id          OUT NOCOPY    VARCHAR2
  , x_blind_receiving_flag      OUT NOCOPY    VARCHAR2
  , x_allow_unordered           OUT NOCOPY    VARCHAR2
  , x_display_inverse_rate      OUT NOCOPY    VARCHAR2
  , x_currency_code             OUT NOCOPY    VARCHAR2
  , x_project_reference_enabled OUT NOCOPY    NUMBER
  , x_project_control_level     OUT NOCOPY    NUMBER
  , x_effectivity_control       OUT NOCOPY    NUMBER
  , x_employee_id               OUT NOCOPY    NUMBER
  , x_wms_install_status        OUT NOCOPY    VARCHAR2
  , x_wms_purchased             OUT NOCOPY    VARCHAR2
  , x_message                   OUT NOCOPY    VARCHAR2
  ) IS
    l_org_id                NUMBER        := p_org_id;
    l_employee_name         VARCHAR2(240);
    l_requestor_location_id NUMBER;
    l_location_code         VARCHAR2(80);
    l_employee_is_buyer     BOOLEAN;
    l_is_emp                BOOLEAN;
    l_temp                  BOOLEAN;
    l_return_status         VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(400);
    l_progress              VARCHAR2(10);
    l_debug                 NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('enter init_form_values :  10', 1);
    END IF;

    l_progress  := '10';

    /* Bug 3440456 */
    -- For performance reason this is being as replaced as below.
    /*
    SELECT ood.set_of_books_id
         , sob.currency_code
      INTO x_sob_id
         , x_currency_code
      FROM org_organization_definitions ood, gl_sets_of_books sob
     WHERE organization_id = p_org_id
       AND sob.set_of_books_id = ood.set_of_books_id;
    */
    x_inv_org_id := p_org_id; --bug 5195963

    SELECT TO_NUMBER(hoi.org_information1)
           , sob.currency_code
      INTO x_sob_id
           , x_currency_code
      FROM hr_organization_information hoi, gl_sets_of_books sob
     WHERE hoi.organization_id = p_org_id
       AND (hoi.org_information_context || '') = 'Accounting Information'
       AND sob.set_of_books_id = to_number(hoi.org_information1);

    l_progress  := '20';

    BEGIN
      SELECT location_code
        INTO x_org_location
        FROM hr_locations hrl, hr_organization_units hou
       WHERE hou.location_id = hrl.location_id
         AND hou.organization_id = p_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        -- no_data_found, more than one row, etc.
        -- for any exception we just don't set org_location
        NULL;
    END;

    l_progress  := '30';

    IF (l_debug = 1) THEN
      print_debug('init_form_values :  20', 4);
    END IF;

    po_setup_s1.get_install_status(
          x_inv_status
        , x_po_status
        , x_qa_status
        , x_wip_status
        , x_oe_status
        , x_pa_status);

    IF (l_debug = 1) THEN
      print_debug('init_form_values :  30', 4);
    END IF;

    l_progress  := '40';
    rcv_setup_s2.get_startup_values(
      x_sob_id
    , l_org_id
    , x_org_name
    , x_ussgl_value
    , x_override_routing
    , x_transaction_mode
    , x_receipt_traveller
    , x_period_name
    , x_gl_date
    , x_category_set_id
    , x_structure_id
    , x_receipt_num_code
    , x_receipt_num_type
    , x_po_num_type
    , x_allow_express
    , x_allow_cascade
    , x_user_id
    , x_logon_id
    , x_creation_date
    , x_update_date
    , x_coa_id
    , x_org_locator_control
    , x_negative_inv_receipt_code
    , x_gl_set_of_bks_id
    , x_blind_receiving_flag
    , x_allow_unordered
    );

    IF (l_debug = 1) THEN
      print_debug('init_form_values :  40', 4);
    END IF;

    l_progress  := '50';

    SELECT user_defined_receipt_num_code
         , manual_receipt_num_type
      INTO x_receipt_num_code
         , x_receipt_num_type
      FROM rcv_parameters
     WHERE organization_id = p_org_id;

    l_progress  := '60';
    fnd_profile.get('DISPLAY_INVERSE_RATE', x_display_inverse_rate);

    IF x_display_inverse_rate IS NULL THEN
      x_display_inverse_rate  := 'N';
    END IF;

    l_progress  := '70';

    IF p_org_id IS NOT NULL THEN
      IF (l_debug = 1) THEN
        print_debug('init_form_values :  50', 4);
      END IF;

      po_core_s4.get_mtl_parameters(
          p_org_id
        , NULL
        , x_project_reference_enabled
        , x_project_control_level);
    END IF;

    l_progress  := '80';

    IF (pjm_unit_eff.enabled = 'Y') THEN
      x_effectivity_control  := 1;
    ELSE
      x_effectivity_control  := 2;
    END IF;

    l_progress  := '90';

    IF (l_debug = 1) THEN
      print_debug('init_form_values :  60', 4);
    END IF;

    l_temp := po_employees_sv.get_employee(
                  x_employee_id
                , l_employee_name
                , l_requestor_location_id
                , l_location_code
                , l_employee_is_buyer
                , l_is_emp);

    l_progress  := '100';

    -- set wms_installed flag
    IF wms_install.check_install(l_return_status, l_msg_count, l_msg_data, p_org_id) THEN
      x_wms_install_status  := 'I';
    ELSE
      x_wms_install_status  := 'U';
    END IF;

    l_progress  := '110';

    -- set wms_purchased flag
    IF wms_install.check_install(l_return_status, l_msg_count, l_msg_data, NULL) THEN
      x_wms_purchased  := 'I';
    ELSE
      x_wms_purchased  := 'U';
    END IF;

    l_progress  := '120';

    IF (l_debug = 1) THEN
      print_debug('init_form_values :  70 ', 4);
      print_debug('x_wms_install_status = ' || x_wms_install_status, 4);
      print_debug('x_wms_purchased = ' || x_wms_purchased, 4);
    END IF;

    IF g_rcv_global_var.receipt_num IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('init_form_values :  75 ', 4);
      END IF;

      inv_rcv_common_apis.rcv_gen_receipt_num(
        x_receipt_num                => g_rcv_global_var.receipt_num
      , p_organization_id            => p_org_id
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );
    END IF;

    IF (l_debug = 1) THEN
      print_debug('exit init_form_values :  80 ', 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('Exitting init_form_values - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.init_form_values', l_progress, SQLCODE);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => l_msg_data);
      RAISE;
  END init_form_values;

  -- Added the overloaded method to return the value of inv patch level
  -- and the po patch level to the UI. The earlier method is stubbed out
  -- to call this method in order to avoid pre-reqs.
  PROCEDURE init_rcv_ui_startup_values(
    p_organization_id     IN            NUMBER
  , x_org_id              OUT NOCOPY    NUMBER
  , x_org_location        OUT NOCOPY    VARCHAR2
  , x_org_locator_control OUT NOCOPY    NUMBER
  , x_manual_po_num_type  OUT NOCOPY    VARCHAR2
  , x_wms_install_status  OUT NOCOPY    VARCHAR2
  , x_wms_purchased       OUT NOCOPY    VARCHAR2
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , x_inv_patch_level     OUT NOCOPY    NUMBER
  , x_po_patch_level      OUT NOCOPY    NUMBER
  , x_wms_patch_level     OUT NOCOPY    NUMBER
  ) IS
    l_msg_count NUMBER;
    l_progress  VARCHAR2(5);
    l_debug     NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Entering init_rcv_ui_startup_values:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    x_return_status    := fnd_api.g_ret_sts_success;
    x_org_id           := p_organization_id;
    x_inv_patch_level  := inv_rcv_common_apis.g_inv_patch_level;
    x_po_patch_level   := inv_rcv_common_apis.g_po_patch_level;
    x_wms_patch_level  := inv_rcv_common_apis.g_wms_patch_level;
    l_progress         := '10';

    /* Bug 3440456 */
    -- For performance reason this is being as replaced as below.
    /*
    SELECT ood.set_of_books_id
         , sob.currency_code
      INTO g_po_startup_value.sob_id
         , g_po_startup_value.currency_code
      FROM org_organization_definitions ood, gl_sets_of_books sob
     WHERE organization_id = p_organization_id
       AND sob.set_of_books_id = ood.set_of_books_id;
    */

    SELECT TO_NUMBER(hoi.org_information1)
           , sob.currency_code
      INTO g_po_startup_value.sob_id
         , g_po_startup_value.currency_code
      FROM hr_organization_information hoi, gl_sets_of_books sob
     WHERE hoi.organization_id = p_organization_id
       AND (hoi.org_information_context || '') = 'Accounting Information'
       AND sob.set_of_books_id = to_number(hoi.org_information1);

    l_progress         := '20';

    -- set default org location
    BEGIN
      SELECT location_code
        INTO x_org_location
        FROM hr_locations hrl, hr_organization_units hou
       WHERE hou.location_id = hrl.location_id
         AND hou.organization_id = p_organization_id;

      l_progress  := '40';
    EXCEPTION
      WHEN OTHERS THEN
        -- no_data_found, more than one row, etc.
        -- for any exception we just don't set org_location
        NULL;
    END;

    -- set stock locator control code
    l_progress         := '50';

    SELECT NVL(stock_locator_control_code, 1)
      INTO x_org_locator_control
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

    l_progress         := '60';

    -- set manual po number type
    BEGIN
      l_progress  := '70';

      SELECT NVL(manual_po_num_type, 'ALPHANUMERIC')
        INTO x_manual_po_num_type
        FROM po_system_parameters
       WHERE ROWNUM = 1;

      l_progress  := '80';
    EXCEPTION
      WHEN OTHERS THEN
        x_manual_po_num_type  := 'ALPHANUMERIC';
    END;

    -- set wms_installed flag
    l_progress         := '90';

    IF wms_install.check_install(x_return_status, l_msg_count, x_msg_data, p_organization_id) THEN
      x_wms_install_status  := 'I';
    ELSE
      x_wms_install_status  := 'U';
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'WMS_INSTALL_CHK_ERROR'); -- error checking ems installation
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress         := '110';

    -- set wms_purchased flag
    IF wms_install.check_install(x_return_status, l_msg_count, x_msg_data, NULL) THEN
      x_wms_purchased  := 'I';
    ELSE
      x_wms_purchased  := 'U';
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('INV', 'WMS_INSTALL_CHK_ERROR'); -- error checking ems installation
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress         := '120';
    -- generate the group id to be used for all the records till the
    -- user revisits the menu.
    gen_txn_group_id;
    l_progress         := '130';

    IF (l_debug = 1) THEN
      print_debug('Exitting init_rcv_ui_startup_values:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting init_rcv_ui_startup_values - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting init_rcv_ui_startup_values - unexpected error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting init_rcv_ui_startup_values - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.init_rcv_ui_startup_values', l_progress, SQLCODE);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_msg_data);
  END init_rcv_ui_startup_values;

  PROCEDURE init_rcv_ui_startup_values(
    p_organization_id     IN            NUMBER
  , x_org_id              OUT NOCOPY    NUMBER
  , x_org_location        OUT NOCOPY    VARCHAR2
  , x_org_locator_control OUT NOCOPY    NUMBER
  , x_manual_po_num_type  OUT NOCOPY    VARCHAR2
  , x_wms_install_status  OUT NOCOPY    VARCHAR2
  , x_wms_purchased       OUT NOCOPY    VARCHAR2
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_data            OUT NOCOPY    VARCHAR2
  ) IS
    l_inv_patch_level NUMBER;
    l_po_patch_level  NUMBER;
    l_wms_patch_level NUMBER;
  BEGIN
    init_rcv_ui_startup_values(
      p_organization_id            => p_organization_id
    , x_org_id                     => x_org_id
    , x_org_location               => x_org_location
    , x_org_locator_control        => x_org_locator_control
    , x_manual_po_num_type         => x_manual_po_num_type
    , x_wms_install_status         => x_wms_install_status
    , x_wms_purchased              => x_wms_purchased
    , x_return_status              => x_return_status
    , x_msg_data                   => x_msg_data
    , x_inv_patch_level            => l_inv_patch_level
    , x_po_patch_level             => l_po_patch_level
    , x_wms_patch_level            => l_wms_patch_level
    );
  END init_rcv_ui_startup_values;

  /*************************************************
  * Name: get_po_routing_id
  * This API returns routing id for a given PO header ID
  * Routing ID is defined at PO line-location level (po_line_locations_all)
  * We use the following rule to set headers routing ID
  * If there is one line detail needs inspection the entire PO needs inspection
  * elsif there is one line detail needs direct receiving the entire PO direct
  * else (all line detail are standard) the entire PO is standard
  * rounting lookups: 1. standard   2. Inspect  3. Direct
  ******************************************************/
  PROCEDURE get_po_routing_id(
    x_po_routing_id OUT NOCOPY    NUMBER
  , x_is_expense    OUT NOCOPY    VARCHAR2
  , p_po_header_id  IN            NUMBER
  , p_po_release_id IN            NUMBER
  , p_po_line_id    IN            NUMBER
  , p_item_id       IN            NUMBER
  , p_item_desc     IN            VARCHAR2 DEFAULT NULL
  , p_organization_id IN          NUMBER   DEFAULT NULL  -- Bug 8242448
  ) IS
    --     l_po_routing_id NUMBER := 3; It should not be initialized with value 3,
    --                  otherwise, the searching will not go
    --                  to item level/org level.
    l_po_routing_id    NUMBER;
    l_po_ll_routing_id NUMBER;
    l_dest_context     VARCHAR2(30);
    l_po_dest_context  VARCHAR2(30);
    -- Bug 8242448, Code changes start
    l_wms_enabled      VARCHAR2(1) := 'N';
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(300);
    l_return_status    VARCHAR2(300);
    -- Bug 8242448, Code changes end

   /* Bug 3812507: Changing the select query in the cursors po_ll_routing_cur
   and pod_dest_context_cur to improve performance */

    CURSOR po_ll_routing_cur IS
      --   SELECT Nvl(poll.receiving_routing_id, 1) Value 1 should not be selected
      --                        in case of Nvl, otherwise the
      --                        searching mechanism will not
      --                        go to item/org level.
	SELECT poll.receiving_routing_id
	-- p_po_release_id is null and p_po_line_id is null
	FROM po_line_locations poll, po_lines pol
	WHERE pol.po_header_id = p_po_header_id
	AND poll.po_line_id = pol.po_line_id
	AND p_po_release_id is NULL
	AND p_po_line_id is null
	AND (pol.item_id = p_item_id OR (p_item_id IS NULL
	AND pol.item_id IS NULL AND pol.item_description = p_item_desc))
	AND NVL(poll.approved_flag, 'N') = 'Y'
	AND NVL(poll.cancel_flag, 'N') = 'N'
	AND NVL(poll.closed_code, 'OPEN')NOT IN ('CLOSED','CLOSED FOR RECEIVING','FINALLY CLOSED')
	/*Fix for bug #4755862*/
	AND poll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
	UNION ALL
	SELECT poll.receiving_routing_id
	-- p_po_release_id is null and p_po_line_id is not null
	FROM po_line_locations poll, po_lines pol
	WHERE poll.po_header_id = p_po_header_id
	AND poll.po_line_id = pol.po_line_id
	AND p_po_release_id is NULL
	AND (p_po_line_id is not null AND poll.po_line_id = p_po_line_id)
	AND (pol.ITEM_ID = p_item_id OR (p_item_id IS NULL
	AND pol.item_id IS NULL AND pol.item_description = p_item_desc ))
	AND NVL(poll.approved_flag, 'N') = 'Y'
	AND NVL(poll.cancel_flag, 'N') = 'N'
	AND NVL(poll.closed_code, 'OPEN') NOT IN ('CLOSED','CLOSED FOR RECEIVING','FINALLY CLOSED')
	/*Fix for bug #4755862*/
	AND poll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED')
	UNION ALL
	SELECT poll.receiving_routing_id
	-- p_po_release_id is not null
	FROM po_line_locations poll, po_lines pol
	WHERE poll.po_header_id = p_po_header_id
	AND poll.po_line_id = pol.po_line_id
	AND (p_po_release_id is NOT NULL AND poll.po_release_id = p_po_release_id)
	AND (p_po_line_id is null or poll.po_line_id = p_po_line_id)
	AND (pol.item_id = p_item_id OR (p_item_id IS NULL
	AND pol.item_id IS NULL AND pol.item_description = p_item_desc))
	AND NVL(poll.approved_flag, 'N') = 'Y'
	AND NVL(poll.cancel_flag, 'N') = 'N'
	AND NVL(poll.closed_code, 'OPEN') NOT IN ('CLOSED','CLOSED FOR RECEIVING','FINALLY CLOSED')
	/*Fix for bug #4755862*/
	AND poll.shipment_type IN('STANDARD', 'BLANKET', 'SCHEDULED');
/*
      SELECT poll.receiving_routing_id
        FROM po_line_locations poll, po_lines pol
       WHERE poll.po_header_id = p_po_header_id
         AND NVL(poll.po_release_id, -1) = NVL(p_po_release_id, NVL(poll.po_release_id, -1))
         AND NVL(poll.po_line_id, -1) = NVL(p_po_line_id, NVL(poll.po_line_id, -1))
         --AND pol.item_id = p_item_id
         AND (pol.item_id = p_item_id
              OR (p_item_id IS NULL
                  AND pol.item_id IS NULL
                  AND pol.item_description = p_item_desc
                 )
             )
         AND pol.po_line_id = poll.po_line_id
         AND NVL(poll.approved_flag, 'N') = 'Y'
         AND NVL(poll.cancel_flag, 'N') = 'N'
         AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
         AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED');
*/

    CURSOR pod_dest_context_cur IS
	SELECT DISTINCT NVL(POD.DESTINATION_TYPE_CODE,POD.DESTINATION_CONTEXT)
	-- p_po_release_id is null and p_po_line_id is null
	FROM PO_DISTRIBUTIONS POD, PO_LINES POL, PO_LINE_LOCATIONS POLL
	WHERE POL.PO_HEADER_ID = p_po_header_id
	AND POLL.PO_LINE_ID = POL.PO_LINE_ID
	AND POLL.SHIP_TO_ORGANIZATION_ID = NVL(p_organization_id, POLL.SHIP_TO_ORGANIZATION_ID)   -- Bug 8242448
	AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	AND p_po_release_id is NULL
	AND p_po_line_id is NULL
	AND (POL.ITEM_ID = p_item_id OR (p_item_id IS NULL
	AND POL.ITEM_ID IS NULL AND POL.ITEM_DESCRIPTION = p_item_desc ))
	AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	/*Added for Bug#7281141- getting the distributions against only the open line locations
	AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED' */
        AND NVL(POLL.CLOSED_CODE,'OPEN')  NOT IN ('CLOSED','CLOSED FOR RECEIVING','FINALLY CLOSED')
	AND POLL.SHIPMENT_TYPE IN ( 'STANDARD','BLANKET','SCHEDULED' )
	UNION ALL
	SELECT DISTINCT NVL(POD.DESTINATION_TYPE_CODE,POD.DESTINATION_CONTEXT)
	-- p_po_release_id is null and p_po_line_id is not null
	FROM PO_DISTRIBUTIONS POD, PO_LINES POL, PO_LINE_LOCATIONS POLL
	WHERE POLL.PO_HEADER_ID = p_po_header_id
	AND POLL.PO_LINE_ID = POL.PO_LINE_ID
	AND POLL.SHIP_TO_ORGANIZATION_ID = NVL(p_organization_id, POLL.SHIP_TO_ORGANIZATION_ID)   -- Bug 8242448
	AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	AND p_po_release_id is NULL
	AND (p_po_line_id is NOT NULL AND POLL.PO_LINE_ID = p_po_line_id)
	AND (POL.ITEM_ID = p_item_id OR (p_item_id IS NULL
	AND POL.ITEM_ID IS NULL AND POL.ITEM_DESCRIPTION = p_item_desc ))
	AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	/*Added for Bug#7281141- getting the distributions against only the open line locations
	AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED' */
        AND NVL(POLL.CLOSED_CODE,'OPEN')  NOT IN ('CLOSED','CLOSED FOR RECEIVING','FINALLY CLOSED')
	AND POLL.SHIPMENT_TYPE IN ( 'STANDARD','BLANKET','SCHEDULED' )
	UNION ALL
	SELECT DISTINCT NVL(POD.DESTINATION_TYPE_CODE,POD.DESTINATION_CONTEXT)
	-- p_po_release_id is not NULL
	FROM PO_DISTRIBUTIONS POD, PO_LINES POL, PO_LINE_LOCATIONS POLL
	WHERE POLL.PO_HEADER_ID = p_po_header_id
	AND POLL.PO_LINE_ID = POL.PO_LINE_ID
	AND POLL.SHIP_TO_ORGANIZATION_ID = NVL(p_organization_id, POLL.SHIP_TO_ORGANIZATION_ID)   -- Bug 8242448
	AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	AND (p_po_release_id is NOT NULL AND POLL.PO_RELEASE_ID = p_po_release_id)
	AND (p_po_line_id is null or poll.po_line_id = p_po_line_id)
	AND (pol.item_id = p_item_id OR (p_item_id IS NULL
	AND pol.item_id IS NULL AND pol.item_description = p_item_desc))
	AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
	AND POLL.SHIPMENT_TYPE IN ( 'STANDARD','BLANKET','SCHEDULED' );

	 -- Bug 8242448 - Code changes start

 --   As part of bug # 7281141, the cursor 'pod_dest_context_cur' is modified to fetch the
 --   distributions against po line locations whose closed_code not in status 'CLOSED','
 --   CLOSED FOR RECEIVING', 'FINALLY CLOSED', for a wms org. But for a non-wms org we
 --   need to fetch the destination type code during deliver transaction also, in order to
 --   prompt the user to enter the deliver to location instead of subinventory and locator
 --   in case of expense destination. Hence added the following cursor which will retrieve
 --   distributions against po line locations whose closed_code <> 'FINALLY CLOSED'.

    CURSOR pod_dest_context_inv_cur IS
	SELECT DISTINCT NVL(POD.DESTINATION_TYPE_CODE,POD.DESTINATION_CONTEXT)
	FROM PO_DISTRIBUTIONS POD, PO_LINES POL, PO_LINE_LOCATIONS POLL
	WHERE POL.PO_HEADER_ID = p_po_header_id
	AND POLL.PO_LINE_ID = POL.PO_LINE_ID
        AND POLL.SHIP_TO_ORGANIZATION_ID = NVL(p_organization_id, POLL.SHIP_TO_ORGANIZATION_ID)
	AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	AND p_po_release_id is NULL
	AND p_po_line_id is NULL
	AND (POL.ITEM_ID = p_item_id OR (p_item_id IS NULL
	AND POL.ITEM_ID IS NULL AND POL.ITEM_DESCRIPTION = p_item_desc ))
	AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
	AND POLL.SHIPMENT_TYPE IN ( 'STANDARD','BLANKET','SCHEDULED' )
	UNION ALL
	SELECT DISTINCT NVL(POD.DESTINATION_TYPE_CODE,POD.DESTINATION_CONTEXT)
	FROM PO_DISTRIBUTIONS POD, PO_LINES POL, PO_LINE_LOCATIONS POLL
	WHERE POLL.PO_HEADER_ID = p_po_header_id
	AND POLL.PO_LINE_ID = POL.PO_LINE_ID
        AND POLL.SHIP_TO_ORGANIZATION_ID = NVL(p_organization_id, POLL.SHIP_TO_ORGANIZATION_ID)
	AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	AND p_po_release_id is NULL
	AND (p_po_line_id is NOT NULL AND POLL.PO_LINE_ID = p_po_line_id)
	AND (POL.ITEM_ID = p_item_id OR (p_item_id IS NULL
	AND POL.ITEM_ID IS NULL AND POL.ITEM_DESCRIPTION = p_item_desc ))
	AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
        AND POLL.SHIPMENT_TYPE IN ( 'STANDARD','BLANKET','SCHEDULED' )
	UNION ALL
	SELECT DISTINCT NVL(POD.DESTINATION_TYPE_CODE,POD.DESTINATION_CONTEXT)
	FROM PO_DISTRIBUTIONS POD, PO_LINES POL, PO_LINE_LOCATIONS POLL
	WHERE POLL.PO_HEADER_ID = p_po_header_id
	AND POLL.PO_LINE_ID = POL.PO_LINE_ID
        AND POLL.SHIP_TO_ORGANIZATION_ID = NVL(p_organization_id, POLL.SHIP_TO_ORGANIZATION_ID)
	AND POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
	AND (p_po_release_id is NOT NULL AND POLL.PO_RELEASE_ID = p_po_release_id)
	AND (p_po_line_id is null or poll.po_line_id = p_po_line_id)
	AND (pol.item_id = p_item_id OR (p_item_id IS NULL
	AND pol.item_id IS NULL AND pol.item_description = p_item_desc))
	AND NVL(POLL.APPROVED_FLAG,'N') = 'Y'
	AND NVL(POLL.CANCEL_FLAG,'N') = 'N'
	AND NVL(POLL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
	AND POLL.SHIPMENT_TYPE IN ( 'STANDARD','BLANKET','SCHEDULED' );

     -- Bug 8242448 - Code changes end

/*
       SELECT DISTINCT Nvl(pod.destination_type_code,pod.destination_context)
                 FROM po_distributions pod, po_lines pol, po_line_locations poll
                WHERE pod.po_header_id = p_po_header_id
                  AND NVL(poll.po_release_id, -1) = NVL(p_po_release_id, NVL(poll.po_release_id, -1))
                  AND NVL(poll.po_line_id, -1) = NVL(p_po_line_id, NVL(poll.po_line_id, -1))
                  --AND pol.item_id = p_item_id
                  AND pod.line_location_id = poll.line_location_id
                  AND (pol.item_id = p_item_id
                       OR (p_item_id IS NULL
                           AND pol.item_id IS NULL
                           AND pol.item_description = p_item_desc
                          )
                      )
                  AND pol.po_line_id = poll.po_line_id
                  AND NVL(poll.approved_flag, 'N') = 'Y'
                  AND NVL(poll.cancel_flag, 'N') = 'N'
                  AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                  AND poll.shipment_type IN ('STANDARD', 'BLANKET', 'SCHEDULED');
*/

    l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    OPEN po_ll_routing_cur;

    IF (l_debug = 1) THEN
      print_debug('header_id ' || TO_CHAR(p_po_header_id), 4);
      print_debug('line_id ' || TO_CHAR(p_po_line_id), 4);
      print_debug('p_po_release_id ' || TO_CHAR(p_po_release_id), 4);     -- Bug 8242448
      print_debug('p_organization_id ' || TO_CHAR(p_organization_id), 4); -- Bug 8242448
      print_debug('item_id ' || TO_CHAR(p_item_id), 4);
      print_debug('item_desc ' || p_item_desc, 4);
    END IF;

    x_is_expense     := 'N';

    LOOP
      FETCH po_ll_routing_cur INTO l_po_ll_routing_id;
      EXIT WHEN po_ll_routing_cur%NOTFOUND;

      IF (l_debug = 1) THEN
        print_debug('l_po_ll_routing_id ' || l_po_ll_routing_id, 4);
      END IF;

      IF l_po_ll_routing_id = 2 THEN -- inspection
        l_po_routing_id  := 2;
        EXIT; -- inspection overrides everything
      ELSIF l_po_ll_routing_id = 1 THEN -- standard
        l_po_routing_id  := 1; -- standard overrides direct
      ELSIF(l_po_ll_routing_id = 3
            AND NVL(l_po_routing_id, 3) >= 3) THEN -- direct
        l_po_routing_id  := 3; -- direct is default if not null
      END IF;
    END LOOP;

    CLOSE po_ll_routing_cur;

    IF (l_debug = 1) THEN
      print_debug('routing_id ' || TO_CHAR(l_po_routing_id), 4);
    END IF;

    /*
    if l_po_ll_routing_id is not null then
         l_po_routing_id := l_po_ll_routing_id;
    end if;
      */
    x_po_routing_id  := l_po_routing_id;
    l_dest_context   := 'INITIAL';

     -- Bug 8242448
    IF wms_install.check_install(l_return_status, l_msg_count, l_msg_data, p_organization_id) THEN
       l_wms_enabled := 'Y';
    END IF;

      IF (l_debug = 1) THEN
       print_debug('l_wms_enabled ==  ' || l_wms_enabled, 4);
      END IF;

    IF l_wms_enabled = 'N' THEN   -- Bug 8242448
       OPEN pod_dest_context_inv_cur;
    ELSE
       OPEN pod_dest_context_cur;
    END IF;

    LOOP

      IF l_wms_enabled = 'N' THEN   -- Bug 8242448
         FETCH pod_dest_context_inv_cur INTO l_po_dest_context;
         EXIT WHEN pod_dest_context_inv_cur%NOTFOUND;
      ELSE
         FETCH pod_dest_context_cur INTO l_po_dest_context;
          EXIT WHEN pod_dest_context_cur%NOTFOUND;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('pod dest context ' || l_po_dest_context, 4);
      END IF;

      IF l_dest_context <> l_po_dest_context THEN -- inspection
        l_dest_context  := l_po_dest_context;
      END IF;

     IF l_dest_context = 'EXPENSE' THEN
       x_is_expense  := 'Y';
       EXIT ; --Added for Bug#7281141
     END IF;
    END LOOP;

      -- Bug 8242448, Closing the cursors

      IF pod_dest_context_cur%ISOPEN THEN
        CLOSE pod_dest_context_cur;
      END IF;

      IF pod_dest_context_inv_cur%ISOPEN THEN
        CLOSE pod_dest_context_inv_cur;
      END IF;

      IF (l_debug = 1) THEN
       print_debug('x_is_expense ==  ' || x_is_expense, 4);
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF po_ll_routing_cur%ISOPEN THEN
        CLOSE po_ll_routing_cur;
      END IF;

      IF pod_dest_context_cur%ISOPEN THEN
        CLOSE pod_dest_context_cur;             -- Bug 8242448
      END IF;

      IF pod_dest_context_inv_cur%ISOPEN THEN   -- Bug 8242448
        CLOSE pod_dest_context_inv_cur;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exception while getting the shipment routing', 4);
      END IF;

      RAISE;
  END get_po_routing_id;

  /*************************************************
  * Name: get_asn_routing_id
  * This API returns routing id for a given shipment_header_ID,
  * lpn_id, po_header_id combination.
  * PO_header_id, po_line_id and item_id are queried based on the combination,
  * and then passed to get_po_routing_id.
  * If any of the lines has a direct routing, this API will return direct.
  *******************************************************/
  PROCEDURE get_asn_routing_id(
    x_asn_routing_id     OUT NOCOPY    NUMBER
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , p_shipment_header_id IN            NUMBER
  , p_lpn_id             IN            NUMBER
  , p_po_header_id       IN            NUMBER
  ) IS
    l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(400);
    l_progress       VARCHAR2(10);
    l_po_header_id   NUMBER;
    l_po_line_id     NUMBER;
    l_po_release_id  NUMBER;
    l_item_id        NUMBER;
    l_asn_routing_id NUMBER        := 3; -- direct
    l_is_expense     VARCHAR2(1);
    l_temp_asn_routing_id NUMBER := 3; --Bug 5500463

    CURSOR l_curs_asn_lpn_content IS
      SELECT NVL(p_po_header_id, rsl.po_header_id) po_header_id
           , rsl.po_line_id po_line_id
           , rsl.po_release_id po_release_id
           , rsl.item_id item_id
        FROM rcv_shipment_lines rsl
       WHERE rsl.shipment_header_id = p_shipment_header_id
         AND rsl.po_header_id = NVL(p_po_header_id, rsl.po_header_id)
         AND(EXISTS(SELECT 1
                      FROM wms_lpn_contents wlc
                     WHERE wlc.source_line_id = rsl.po_line_id
                       AND wlc.parent_lpn_id = p_lpn_id)
             OR p_lpn_id IS NULL);

    -- bug 3213241
    CURSOR l_curs_asn_lpn_content_new IS
      SELECT NVL(p_po_header_id, rsl.po_header_id) po_header_id
           , rsl.po_line_id po_line_id
           , rsl.po_release_id po_release_id
           , rsl.item_id item_id
        FROM rcv_shipment_lines rsl
       WHERE rsl.shipment_header_id = p_shipment_header_id
         AND rsl.po_header_id = NVL(p_po_header_id, rsl.po_header_id)
	AND (( ( rsl.asn_lpn_id IS NOT NULL
		 AND rsl.asn_lpn_id in
		        (SELECT wlpn.lpn_id
			 FROM wms_license_plate_numbers wlpn
			 start with lpn_id = p_lpn_id
			 CONNECT BY parent_lpn_id = PRIOR lpn_id
			 )
		  )
		OR (rsl.asn_lpn_id IS NULL
		    AND exists (SELECT 1
				FROM wms_lpn_contents wlc
				WHERE wlc.source_line_id = rsl.po_line_id
				AND wlc.parent_lpn_id = p_lpn_id)
		    )
              )
              OR
              (p_lpn_id IS NULL)
             );

    l_debug          NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter get_asn_routing_id 10 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_shipment_header_id => ' || p_shipment_header_id, 4);
      print_debug('p_lpn_id => ' || p_lpn_id, 4);
      print_debug('p_po_header_id => ' || p_po_header_id, 4);
    END IF;

    x_return_status   := fnd_api.g_ret_sts_success;
    l_progress        := '10';

    IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) or
       (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)) THEN
       IF (l_debug = 1) THEN
          print_debug('In GET ASN ROUTING ID for/after patchsetJ  ', 4);
       END IF;
       OPEN l_curs_asn_lpn_content_new;
    ELSE
       IF (l_debug = 1) THEN
          print_debug('In GET ASN ROUTING ID before patchsetJ  ', 4);
       END IF;
       OPEN l_curs_asn_lpn_content;
    END IF;

    l_progress        := '20';

    LOOP
       IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) or
       (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)) THEN
         FETCH l_curs_asn_lpn_content_new INTO l_po_header_id, l_po_line_id, l_po_release_id, l_item_id;
         EXIT WHEN l_curs_asn_lpn_content_new%NOTFOUND;
       ElSE
         FETCH l_curs_asn_lpn_content INTO l_po_header_id, l_po_line_id, l_po_release_id, l_item_id;
         EXIT WHEN l_curs_asn_lpn_content%NOTFOUND;
       END IF;

      l_progress  := '30';

      IF (l_debug = 1) THEN
        print_debug('Paramters for calling get_po_routing_id : ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        print_debug('l_po_header_id => ' || l_po_header_id, 4);
        print_debug('l_po_release_id => ' || l_po_release_id, 4);
        print_debug('l_po_line_id => ' || l_po_line_id, 4);
        print_debug('l_item_id => ' || l_item_id, 4);
      END IF;

      get_po_routing_id(
        x_po_routing_id              => l_asn_routing_id
      , x_is_expense                 => l_is_expense
      , p_po_header_id               => l_po_header_id
      , p_po_release_id              => l_po_release_id
      , p_po_line_id                 => l_po_line_id
      , p_item_id                    => l_item_id
      );

      IF (l_debug = 1) THEN
        print_debug('Result of get_po_routing_id : l_asn_routing_id = ' || l_asn_routing_id, 4);
      END IF;

      l_progress  := '40';

      /*Begin Bug 5500463
      IF l_asn_routing_id <> 3 THEN -- direct found
        EXIT;
      END IF; */
      IF l_asn_routing_id = 2 THEN
        EXIT;
      ELSIF l_asn_routing_id = 1 THEN
        NULL;
      ELSIF l_asn_routing_id = 3 THEN
        IF (l_temp_asn_routing_id < 3) THEN
          l_asn_routing_id := l_temp_asn_routing_id;
        END IF;
      END IF;

      IF (l_asn_routing_id < 3) THEN
        l_temp_asn_routing_id := l_asn_routing_id;
      END IF;
      --End Bug 5500463
    END LOOP;

    l_progress        := '50';
    IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) or
       (inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)) THEN
       CLOSE l_curs_asn_lpn_content_new;
    ELSE
       CLOSE l_curs_asn_lpn_content;
    END IF;

    l_progress        := '60';
    x_asn_routing_id  := l_asn_routing_id;

    IF (l_debug = 1) THEN
      print_debug('Complete get_asn_routing_id : ' || x_asn_routing_id || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF l_curs_asn_lpn_content%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content;
      END IF;

      IF l_curs_asn_lpn_content_new%ISOPEN THEN
        CLOSE l_curs_asn_lpn_content_new;
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.get_asn_routing_id', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        print_debug('get_asn_routing_id: Other exception ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
  END get_asn_routing_id;

  /*************************************************
  * Name: get_intshp_routing_id
  * This API returns routing id for a given shipment header ID
  * Routing ID is defined at shipment line level (rcv_shipment_lines)
  * We use the following rule to set headers routing ID
  * If there is one line detail needs inspection the entire shipment needs inspection
  * elsif there is one line detail needs direct receiving the entire shipmentneeds direct
  * else (all line detail are standard) the entire shipment is standard
  * rounting lookups: 1. standard   2. Inspect  3. Direct
  ******************************************************/
  PROCEDURE get_intshp_routing_id(
    x_intshp_routing_id  OUT NOCOPY    NUMBER
  , x_is_expense         OUT NOCOPY    VARCHAR2
  , p_shipment_header_id IN            NUMBER
  , p_item_id            IN            NUMBER
  , p_item_desc          IN            VARCHAR2 DEFAULT NULL
  , p_organization_id    IN            NUMBER    -- Bug 8242448
  ) IS
    l_intshp_routing_id NUMBER;
    l_intran_routing_id NUMBER;
    l_po_header_id      NUMBER;
    l_is_expense        VARCHAR2(3) := 'N';
    -- Bug 8242448
    l_po_line_id        NUMBER;
    l_po_release_id     NUMBER;

    CURSOR intshp_rsl_routing_cur IS
      SELECT NVL(routing_header_id, 1)
           , po_header_id
           , po_line_id         -- Bug 8242448
           , po_release_id      -- Bug 8242448
        FROM rcv_shipment_lines
       WHERE shipment_header_id = p_shipment_header_id
         AND(
             (item_id IS NULL
              AND p_item_id IS NULL
              AND item_description = p_item_desc
              AND source_document_code = 'PO')
             OR (item_id = NVL(p_item_id, item_id))
            );

    l_debug             NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    OPEN intshp_rsl_routing_cur;

    IF (l_debug = 1) THEN
      print_debug('shipment header_id ' || TO_CHAR(p_shipment_header_id), 4);
      print_debug('item_id ' || TO_CHAR(p_item_id), 4);
    END IF;

    LOOP
      FETCH intshp_rsl_routing_cur INTO l_intshp_routing_id, l_po_header_id, l_po_line_id, l_po_release_id; -- Bug 8242448
      EXIT WHEN intshp_rsl_routing_cur%NOTFOUND;

      IF (l_debug = 1) THEN
        print_debug('l_intshp_routing_id: ' || l_intshp_routing_id, 4);
      END IF;

      IF l_intshp_routing_id = 2 THEN -- inspection
        l_intran_routing_id  := 2;
        EXIT; -- inspection overrides everything
      ELSIF l_intshp_routing_id = 1 THEN -- standard
        l_intran_routing_id  := 1; -- standard overrides direct
      ELSIF(l_intshp_routing_id = 3
            AND NVL(l_intran_routing_id, 3) >= 3) THEN -- direct
        l_intran_routing_id  := 3; -- direct is default if not null
      END IF;

      IF l_po_header_id IS NOT NULL THEN
        get_po_routing_id(
            l_intshp_routing_id
          , l_is_expense
          , l_po_header_id
          , l_po_release_id  -- Bug  8242448
          , l_po_line_id     -- Bug  8242448
          , p_item_id
          , p_item_desc
	  , p_organization_id);     -- Bug 8242448
      END IF;
    END LOOP;

    CLOSE intshp_rsl_routing_cur;

    IF (l_debug = 1) THEN
      print_debug('routing_id ' || TO_CHAR(l_intran_routing_id), 4);
      print_debug('is_expesne ' || l_is_expense, 4);
    END IF;

    IF l_is_expense = 'N' THEN
       BEGIN
	  SELECT 'Y'
	    INTO l_is_expense
	    FROM po_requisition_lines prl
	       , rcv_shipment_lines rsl
	    WHERE prl.requisition_line_id = rsl.requisition_line_id
	    AND prl.destination_type_code = 'EXPENSE'
	    AND rsl.shipment_header_id = p_shipment_header_id
	    AND rsl.item_id = NVL(p_item_id, rsl.item_id)
	    AND ROWNUM = 1;
       EXCEPTION
	  WHEN OTHERS THEN
	     l_is_expense := 'N';
       END;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('REQ:is_expesne ' || l_is_expense, 4);
    END IF;

    x_intshp_routing_id  := l_intran_routing_id;
    x_is_expense := l_is_expense;
  EXCEPTION
    WHEN OTHERS THEN
      IF intshp_rsl_routing_cur%ISOPEN THEN
        CLOSE intshp_rsl_routing_cur;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exception while getting the shipment routing', 4);
      END IF;

      RAISE;
  END get_intshp_routing_id;

  /*************************************************
  * Name: get_default_routing_id
  * This API returns the default routing id
  * It first uses the item level value
  * if that is null then it uses the vendor level value
  * even if that is null it uses the org level value which if null is = 1
  * We use the following rule to set headers routing ID
  * rounting lookups: 1. standard   2. Inspect  3. Direct
  ******************************************************/
  PROCEDURE get_default_routing_id(
    x_default_routing_id OUT NOCOPY    NUMBER
  , p_item_id            IN            NUMBER
  , p_organization_id    IN            NUMBER
  , p_vendor_id          IN            NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    /*  select item level controls that are not specifid at the purchase
    **  order level
    */
    IF (NVL(p_item_id, 0) <> 0) THEN
      BEGIN
        IF (l_debug = 1) THEN
          print_debug('p_item_id ' || TO_CHAR(p_item_id) || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
          print_debug('p_org_id ' || TO_CHAR(p_organization_id) || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
        END IF;

        SELECT NVL(x_default_routing_id, receiving_routing_id)
          INTO x_default_routing_id
          FROM mtl_system_items
         WHERE inventory_item_id = p_item_id
           AND organization_id = p_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('routing id  ' || TO_CHAR(x_default_routing_id) || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    /*
    ** select vendor level controls not defined in the previous levels
    */
    IF (NVL(p_vendor_id, 0) <> 0) THEN
      BEGIN
        SELECT NVL(x_default_routing_id, receiving_routing_id)
          INTO x_default_routing_id
          FROM po_vendors
         WHERE vendor_id = p_vendor_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

    /*
    ** select organization level controls not defined in the previous levels
    */
    BEGIN
      SELECT NVL(x_default_routing_id, NVL(receiving_routing_id, 1))
        INTO x_default_routing_id
        FROM rcv_parameters
       WHERE organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        RAISE;
    END;
  END get_default_routing_id;

  /*************************************************
  * Name: get_routing_id
  * This API returns routing id for a given PO header ID or shipment header
  * id or for the rma
  ******************************************************/
  PROCEDURE get_routing_id(
    x_routing_id         OUT NOCOPY    NUMBER
  , x_return_status      OUT NOCOPY    VARCHAR2
  , x_msg_count          OUT NOCOPY    NUMBER
  , x_msg_data           OUT NOCOPY    VARCHAR2
  , x_is_expense         OUT NOCOPY    VARCHAR2
  , p_po_header_id       IN            NUMBER
  , p_po_release_id      IN            NUMBER
  , p_po_line_id         IN            NUMBER
  , p_shipment_header_id IN            NUMBER
  , p_oe_order_header_id IN            NUMBER
  , p_item_id            IN            NUMBER
  , p_organization_id    IN            NUMBER
  , p_vendor_id          IN            NUMBER
  , p_lpn_id             IN            NUMBER DEFAULT NULL
  , p_item_desc          IN            VARCHAR2 DEFAULT NULL
  , p_from_lpn_id        IN            NUMBER DEFAULT NULL
  , p_project_id         IN            NUMBER DEFAULT NULL
  , p_task_id            IN            NUMBER DEFAULT NULL
  ) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(400);
    l_return_status         VARCHAR2(1);
    l_progress              VARCHAR2(10);
    l_lpn_context           NUMBER        := 5;
    l_sub                   VARCHAR2(10);
    l_locator_id            NUMBER;
    l_restrict_locator_code NUMBER;
    l_restrict_sub_code     NUMBER;
    l_dummy                 NUMBER;
    l_transaction_type      NUMBER        := 18; -- defaulted for PO receipt.
    l_is_expense            VARCHAR2(1)   := 'N';
    l_lpn_loaded            NUMBER := 0;
    l_debug                 NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_is_valid_item         VARCHAR2(1) := 'Y';
    l_project_id            NUMBER;
    l_task_id               NUMBER;
    l_pjm_org               NUMBER := 2;
    l_client_code VARCHAR(40);  /* Bug 9158529: LSP Changes */
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    x_is_expense     := 'N';
    l_progress       := '10';

    IF (l_debug = 1) THEN
      print_debug('Enter get_routing_id 10' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    /** Project Task Commingle check **/
    IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
       (inv_rcv_common_apis.g_PO_patch_level >= inv_rcv_common_apis.g_patchset_j_po) AND
        p_lpn_id IS NOT NULL AND
        p_lpn_id <> 0 ) THEN

      SELECT NVL(project_reference_enabled, 2)
      INTO   l_pjm_org
      FROM   mtl_parameters
      WHERE  organization_id = p_organization_id;

      --Do the commingling check only for a PJM org
      IF (l_pjm_org = 1) THEN

        /* Get Project_id,task_id from move order line and also from rti*/
        BEGIN
           SELECT project_id,task_id
           INTO l_project_id,l_task_id
           FROM mtl_txn_request_lines
           WHERE lpn_id = p_lpn_id
           AND ROWNUM=1;

           IF (l_debug=1) THEN
               print_debug('Found project and task from move order ', 3);
               print_debug('project_id: ' || l_project_id ,3);
               print_debug('task_id ' || l_task_id ,3);
           END IF;
        EXCEPTION
          WHEN no_data_found  THEN
            --If no MOL found, then get project and task from RTI
            BEGIN
             SELECT  project_id,task_id
             INTO    l_project_id,l_task_id
             FROM    rcv_transactions_interface
             WHERE   transfer_lpn_id = p_lpn_id
             AND     transaction_type = 'RECEIVE'
             AND     transaction_status_code = 'PENDING'
             AND     processing_status_code <> 'ERROR'
             AND     ROWNUM=1;

             IF (l_debug=1) THEN
               print_debug('Found project and task from RTI: ', 3  );
               print_debug('project_id: ' || l_project_id , 3);
               print_debug('task_id ' || l_task_id , 3);
             END IF;
            EXCEPTION
              WHEN no_data_found THEN
                l_project_id := p_project_id;
                l_task_id := p_task_id;
           END;   --End check for RTI
        END;    --End check for MOL

        IF (NVL(p_project_id,-9999) <> NVL(l_project_id,-9999)) OR
           (NVL(p_task_id,-9999) <> NVL(l_task_id,-9999)) THEN
          x_return_status  := fnd_api.g_ret_sts_error;
          x_msg_data       := 'INV_PRJ_ERR';
          fnd_message.set_name('INV', 'INV_PRJ_ERR');
          fnd_msg_pub.ADD;
        END IF;   --End if check for proj/task comm error
      END IF;   --End IF the current org is PJM org
    END IF;   --END if WMS and PO patch levels are >= J and lpn_id is not null

    /** Project Task Commingle check Ends here **/

    IF p_po_header_id IS NULL
       AND p_item_id IS NULL
       AND p_shipment_header_id IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('One time item can only be recd. on PO,  PO not given.', 4);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RETURN;
    END IF;

    IF p_po_header_id IS NOT NULL THEN
      l_progress  := '20';

      IF (l_debug = 1) THEN
        print_debug('get_routing_id 20' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      IF p_item_id IS NULL THEN
        IF p_item_desc IS NULL THEN
          IF (l_debug = 1) THEN
            print_debug('Item desc. and item id both cannot be null', 4);
          END IF;

          x_return_status  := fnd_api.g_ret_sts_unexp_error;
          RETURN;
        END IF;

        x_is_expense  := 'Y';
      END IF;

      get_po_routing_id(
          x_routing_id
        , l_is_expense
        , p_po_header_id
        , p_po_release_id
        , p_po_line_id
        , p_item_id
        , p_item_desc
        , p_organization_id);    -- Bug 8242448

      IF x_is_expense <> 'Y' THEN
        x_is_expense  := l_is_expense;
      END IF;

      l_progress  := '30';
    ELSIF p_shipment_header_id IS NOT NULL THEN
      IF (l_debug = 1) THEN
        print_debug('get_routing_id 30' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_transaction_type  := 61;
      l_progress          := '40';
      get_intshp_routing_id(x_routing_id, l_is_expense, p_shipment_header_id,
                            p_item_id, p_item_desc, p_organization_id);  -- Bug 8242448

      IF x_is_expense <> 'Y' THEN
        x_is_expense  := l_is_expense;
      END IF;

      l_progress          := '50';
    ELSIF p_oe_order_header_id IS NOT NULL THEN
      IF (l_debug = 1) THEN
        print_debug('get_routing_id 52' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_transaction_type  := 15;
      l_progress          := '54';

      BEGIN
        SELECT return_inspection_requirement
          INTO x_routing_id
          FROM mtl_system_items
         WHERE inventory_item_id = p_item_id
           AND organization_id = p_organization_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      -- 1 return_inspection_requirement implies inspection is reqd.
      -- so set the routing to inspection required else set it based
      -- on organization level profile.
      IF x_routing_id = 1 THEN
        x_routing_id  := 2;
      ELSE
           x_routing_id  := NULL;
           -- Bug 3569361
           -- Get the routing details from rcv parameters related po enhancement 3124881
           Begin
             IF (l_debug = 1) THEN
               print_debug('get_routing_id 52.1 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
             END IF;

	     /* Bug 9158529: LSP Changes */

             IF (NVL(FND_PROFILE.VALUE('WMS_DEPLOYMENT_MODE'), 1) = 3) THEN


              l_client_code := wms_deploy.get_client_code(p_item_id);


              If (l_client_code IS NOT NULL) THEN

              select RMA_RECEIPT_ROUTING_ID
  	          into   x_routing_id
  	          from mtl_client_parameters
              WHERE client_code = l_client_code;


             else

             select rma_receipt_routing_id
             into x_routing_id
             from rcv_parameters
             where organization_id = p_organization_id;

             End If;

            Else


             select rma_receipt_routing_id
             into x_routing_id
             from rcv_parameters
             where organization_id = p_organization_id;

           END IF;

	   /* End Bug 9158529 */

            Exception
              When OTHERS then
                IF (l_debug = 1) THEN
                  print_debug('get_routing_id - can not fetch routing id from rcv parameters ', 4);
                  print_debug('get_routing_id 52.2 ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
                END IF;
            End;
           END IF;

      l_progress          := '56';
    END IF;

    IF x_routing_id IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('get_routing_id 40' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
      END IF;

      l_progress  := '60';
      get_default_routing_id(x_routing_id, p_item_id, p_organization_id, p_vendor_id);
      l_progress  := '70';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('get_routing_id complete' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    IF p_lpn_id IS NOT NULL THEN
      BEGIN
        SELECT NVL(lpn_context, 5)
             , NVL(subinventory_code, '@@@')
             , NVL(locator_id, -1)
          INTO l_lpn_context
             , l_sub
             , l_locator_id
          FROM wms_license_plate_numbers
         WHERE lpn_id = p_lpn_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_lpn_context  := 5;
      END;

      IF (
          (x_routing_id = 3
           AND l_lpn_context NOT IN(1, 5, 6, 7)  --Added 6 above for bug # 2169351. added 7 - rnrao
                                                )
          OR --Added 3 here for the bug#2129214
             (
              x_routing_id IN(1, 2)
              AND l_lpn_context NOT IN(3, 5, 6, 7)
             ) --Added 6 above for bug # 2169351 added 7 - rnrao
         ) THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        --  print_debug('invalid lpn context ',9);
        x_msg_data       := 'INV_INVALID_LPN_CONTEXT';
        fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('get_routing_id complete 111:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --Do not allow receipt into a loaded LPN
      IF (l_lpn_context IN (1, 3)) THEN
        l_lpn_loaded := 0;
        BEGIN
          SELECT 1
          INTO   l_lpn_loaded
          FROM   DUAL
          WHERE  EXISTS(
                   SELECT 1
                   FROM   wms_dispatched_tasks wdt, mtl_txn_request_lines mtrl
                   WHERE  wdt.move_order_line_id = mtrl.line_id
                   AND    wdt.organization_id = p_organization_id
                   AND    wdt.status = 4
                   AND    mtrl.lpn_id IN
                     (
                      SELECT wlpn1.lpn_id
                      FROM   wms_license_plate_numbers wlpn1
                      WHERE  wlpn1.outermost_lpn_id =
                             (
                              SELECT outermost_lpn_id
                              FROM   wms_license_plate_numbers wlpn2
                              WHERE  wlpn2.lpn_id = p_lpn_id
                              )
                     )
                  );
        EXCEPTION
          WHEN OTHERS THEN
            l_lpn_loaded := 0;
        END;

        IF (l_lpn_loaded = 1) THEN
          x_return_status  := fnd_api.g_ret_sts_error;
          print_debug('get_routing_id: LPN is a loaded LPN',9);
          x_msg_data       := 'WMS_CONT_INVALID_LPN';
          fnd_message.set_name('WMS', 'WMS_LOADED_ERROR');
          fnd_msg_pub.ADD;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
          fnd_msg_pub.ADD;
        RETURN;
        END IF;
      END IF;

      -- Do the lpn related validations if the lpn context is 1 that is in inventory.
      IF l_lpn_context = 1 THEN
        SELECT NVL(restrict_locators_code, 2)
             , NVL(restrict_subinventories_code, 2)
          INTO l_restrict_locator_code
             , l_restrict_sub_code
          FROM mtl_system_items
         WHERE inventory_item_id = p_item_id
           AND organization_id = p_organization_id;

        IF l_sub <> '@@@' THEN
          IF l_restrict_sub_code = 1 THEN -- item restricted to predefined subs
            BEGIN
              SELECT 1
                INTO l_dummy
                FROM DUAL
               WHERE EXISTS(
                       SELECT 1
                         FROM mtl_item_sub_inventories mis
                        WHERE mis.organization_id = p_organization_id
                          AND mis.inventory_item_id = p_item_id
                          AND mis.secondary_inventory = l_sub
                          AND inv_material_status_grp.is_status_applicable('TRUE', NULL, l_transaction_type, NULL, NULL, p_organization_id
                             , p_item_id, l_sub, NULL, NULL, NULL, 'Z') = 'Y');
            EXCEPTION
              WHEN OTHERS THEN
                x_return_status  := fnd_api.g_ret_sts_error;
                x_msg_data       := 'INV_INT_RESSUBEXP';
                fnd_message.set_name('INV', 'INV_INT_RESSUBEXP');
                fnd_msg_pub.ADD;
                fnd_message.set_name('WMS', 'WMS_TD_LPN_LOC_NOT_FOUND');
                fnd_msg_pub.ADD;
                RETURN;
            END;
          ELSE -- item not under subinventory restrictions.
            BEGIN
              SELECT 1
                INTO l_dummy
                FROM DUAL
               WHERE EXISTS(
                       SELECT 1
                         FROM mtl_secondary_inventories msi
                        WHERE msi.organization_id = p_organization_id
                          AND NVL(msi.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                          AND msi.secondary_inventory_name = l_sub
                          AND inv_material_status_grp.is_status_applicable('TRUE', NULL, l_transaction_type, NULL, NULL, p_organization_id
                             , p_item_id, l_sub, NULL, NULL, NULL, 'Z') = 'Y');
            EXCEPTION
              WHEN OTHERS THEN
                x_return_status  := fnd_api.g_ret_sts_error;
                x_msg_data       := 'INV_SUB_RESTRICT';
                fnd_message.set_name('INV', 'INV_SUB_RESTRICT');
                fnd_msg_pub.ADD;
                fnd_message.set_name('INV', 'INV_INVALID_SUBINV');
                fnd_msg_pub.ADD;
                fnd_message.set_name('WMS', 'WMS_TD_LPN_LOC_NOT_FOUND');
                fnd_msg_pub.ADD;
                RETURN;
            END;
          END IF; -- subinventory restrictions

          IF l_locator_id <> -1 THEN
            IF l_restrict_locator_code = 1 THEN
              -- item under restricted locator control
              BEGIN
                SELECT 1
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS(
                         SELECT 1
                           FROM mtl_secondary_locators msl
                          WHERE msl.organization_id = p_organization_id
                            AND msl.inventory_item_id = p_item_id
                            AND msl.subinventory_code = l_sub
                            AND msl.secondary_locator = l_locator_id
                            AND inv_material_status_grp.is_status_applicable(
                                 'TRUE'
                               , NULL
                               , l_transaction_type
                               , NULL
                               , NULL
                               , p_organization_id
                               , p_item_id
                               , l_sub
                               , l_locator_id
                               , NULL
                               , NULL
                               , 'L'
                               ) = 'Y');
              EXCEPTION
                WHEN OTHERS THEN
                  x_return_status  := fnd_api.g_ret_sts_error;
                  x_msg_data       := 'INV_CCEOI_LOC_NOT_IN_LIST';
                  fnd_message.set_name('INV', 'INV_CCEOI_LOC_NOT_IN_LIST');
                  fnd_msg_pub.ADD;
                  fnd_message.set_name('WMS', 'WMS_TD_LPN_LOC_NOT_FOUND');
                  fnd_msg_pub.ADD;
                  RETURN;
              END;
            ELSE -- item not under restricted locator control
              BEGIN
                SELECT 1
                  INTO l_dummy
                  FROM DUAL
                 WHERE EXISTS(
                         SELECT 1
                           FROM mtl_item_locations mil
                          WHERE mil.organization_id = p_organization_id
                            AND mil.subinventory_code = l_sub
                            AND NVL(mil.disable_date, TRUNC(SYSDATE + 1)) > TRUNC(SYSDATE)
                            AND mil.inventory_location_id = l_locator_id
                            AND inv_material_status_grp.is_status_applicable(
                                 'TRUE'
                               , NULL
                               , l_transaction_type
                               , NULL
                               , NULL
                               , p_organization_id
                               , p_item_id
                               , l_sub
                               , l_locator_id
                               , NULL
                               , NULL
                               , 'L'
                               ) = 'Y');
              EXCEPTION
                WHEN OTHERS THEN
                  x_return_status  := fnd_api.g_ret_sts_error;
                  x_msg_data       := 'INV_TRX_LOCATOR_NA_DUE_MS';
                  fnd_message.set_name('INV', 'INV_TRX_LOCATOR_NA_DUE_MS');
                  fnd_message.set_token('TOKEN1', '');
                  fnd_msg_pub.ADD;
                  fnd_message.set_name('WMS', 'WMS_TD_LPN_LOC_NOT_FOUND');
                  fnd_msg_pub.ADD;
                  RETURN;
              END;
            END IF; -- locator restrictions
          END IF; -- l_locator_id <> -1
        END IF; -- l_sub <> '@@@'
      END IF; -- l_lpn_context = 1

      -- Nested LPN changes do not update LPN status after patchset J
      IF inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po
         OR inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j
         OR inv_rcv_common_apis.g_wms_patch_level < inv_rcv_common_apis.g_patchset_j THEN
        IF (l_lpn_context = 5) THEN
          -- Bug 2357196
          -- For an expense item do not set the lpn context to 1 or 3
          IF NVL(x_is_expense, 'N') <> 'Y' THEN
            UPDATE wms_license_plate_numbers
               SET lpn_context = DECODE(x_routing_id, 3, 1, 3)
             WHERE lpn_id = p_lpn_id;
          END IF;
        END IF;
      END IF;
    END IF;           -- p_lpn_id <> null
            -- print_debug('get_routing_id complete 444:' || to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'),1 );
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exiting get_routing_id - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.get_routing_id', l_progress, SQLCODE);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END get_routing_id;

  PROCEDURE create_lpn(
    p_organization_id               NUMBER
  , p_lpn             IN            VARCHAR2
  , p_lpn_id          OUT NOCOPY    NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_msg_data        OUT NOCOPY    VARCHAR2
  ) IS
    l_lpn_rec       wms_container_pub.lpn;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER                := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('create_lpn 10: ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('Parameters passed : 10.1  p_lpn = ' || p_lpn, 4);
      print_debug('Parameters passed : 10.2  p_organization_id = ' || p_organization_id, 4);
    END IF;

    l_progress                      := '10';
    x_return_status                 := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_create_lpn_sp;
    l_lpn_rec.license_plate_number  := p_lpn;

    IF wms_container_pub.validate_lpn(l_lpn_rec) = inv_validate.f THEN
      l_progress  := '20';
      wms_container_pub.create_lpn(
        p_api_version                => 1.0
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_lpn                        => p_lpn
      , p_organization_id            => p_organization_id
      , x_lpn_id                     => p_lpn_id
      , p_source                     => 5
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_lpn 20.1:  wms_container_pub.create_lpn RAISE FND_API.G_EXC_ERROR' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
          , 4);
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_LPN_GENERATION_FAIL');
        fnd_msg_pub.ADD;

        IF (l_debug = 1) THEN
          print_debug('create_lpn 20.2: wms_container_pub.create_lpn RAISE FND_API.G_EXC_UNEXPECTED_ERROR;' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 4);
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSE -- lpn exists
      IF (l_debug = 1) THEN
        print_debug('create_lpn 30', 4);
      END IF;

      l_progress  := '30';

      SELECT lpn_id
        INTO p_lpn_id
        FROM wms_license_plate_numbers
       WHERE license_plate_number = p_lpn;

      l_progress  := '40';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('create_lpn compete - x_lpn = ' || p_lpn_id || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_create_lpn_sp;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_create_lpn_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_create_lpn_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.create_lpn', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_msg_data);
  END create_lpn;

  -- This api creates a record in the mtl_transaction_lots_temp
  -- It checks if the p_transaction_temp_id is null, if it is, then it
  -- generates a new id and returns that.
  PROCEDURE insert_lot(
    p_transaction_temp_id        IN OUT NOCOPY NUMBER
  , p_created_by                 IN            NUMBER
  , p_transaction_qty            IN            NUMBER
  , p_primary_qty                IN            NUMBER
  , p_lot_number                 IN            VARCHAR2
  , p_expiration_date            IN            DATE
  , p_status_id                  IN            NUMBER := NULL
  , x_serial_transaction_temp_id OUT NOCOPY    NUMBER
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , p_secondary_quantity         IN            NUMBER --OPM Convergence

  ) IS
    l_return   NUMBER;
    l_progress VARCHAR2(10);
    l_count    NUMBER       := 0;
    l_debug    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '10';

    IF (l_debug = 1) THEN
      print_debug('Enter insert_lot: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('p_transaction_temp_id:' || p_transaction_temp_id, 4);
      print_debug('p_transaction_qty:' || p_transaction_qty, 4);
      print_debug('p_primary_qty:' || p_primary_qty, 4);
      print_debug('p_lot_number:' || p_lot_number, 4);
      print_debug('p_expiration_date:' || p_expiration_date, 4);
      print_debug('p_status_id:' || p_status_id, 4);
    END IF;

    /* For Bug#2266537. check if the lot being inserted is already there in MTLT
       with the same temp_id. If so then the quantity of the lot is updated
       instead of generating a new lot.*/
    IF p_transaction_temp_id IS NOT NULL THEN
      BEGIN
        SELECT 1
             , serial_transaction_temp_id
          INTO l_count
             , x_serial_transaction_temp_id
          FROM mtl_transaction_lots_temp
         WHERE transaction_temp_id = p_transaction_temp_id
           AND lot_number = p_lot_number
           AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count  := 0;
        WHEN OTHERS THEN
          l_count  := 0;

          IF (l_debug = 1) THEN
            print_debug('Exception trying to find lot existance', 4);
          END IF;
      END;
    ELSE
      l_count  := 0;
    END IF;

    IF l_count = 1 THEN
      IF (l_debug = 1) THEN
        print_debug('Updating mtlt existing rec', 4);
      END IF;

      UPDATE mtl_transaction_lots_temp
         SET transaction_quantity = transaction_quantity + p_transaction_qty
           , primary_quantity = primary_quantity + p_primary_qty
       WHERE transaction_temp_id = p_transaction_temp_id
         AND lot_number = p_lot_number;
    ELSE
      IF p_transaction_temp_id IS NULL THEN
        SELECT mtl_material_transactions_s.NEXTVAL
          INTO p_transaction_temp_id
          FROM DUAL;
      END IF;

      l_progress  := '20';
      l_return    :=
        inv_trx_util_pub.insert_lot_trx(
          p_trx_tmp_id                 => p_transaction_temp_id
        , p_user_id                    => p_created_by
        , p_lot_number                 => p_lot_number
        , p_trx_qty                    => p_transaction_qty
        , p_pri_qty                    => p_primary_qty
        , p_exp_date                   => p_expiration_date
        , p_status_id                  => p_status_id
        , x_ser_trx_id                 => x_serial_transaction_temp_id
        , x_proc_msg                   => x_msg_data
        , p_secondary_qty              => p_secondary_quantity --OPM Convergence
  );
      l_progress  := '30';

      -- if the trx manager returned a 1 then it could not insert the row
      IF l_return = 1 THEN
        l_progress       := '40';
        x_return_status  := fnd_api.g_ret_sts_error;
      END IF;

      l_progress  := '50';

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_lot : 60  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.insert_lot', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_lot - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'insert_lot');
      END IF;
  END insert_lot;

  -- This api creates a record in the mtl_transaction_serial_temp
  -- It checks if the p_transaction_temp_id is null, if it is, then it
  -- generates a new id and returns that.
  PROCEDURE insert_serial(
    p_serial_transaction_temp_id IN OUT NOCOPY NUMBER
  , p_org_id                     IN            NUMBER
  , p_item_id                    IN            NUMBER
  , p_rev                        IN            VARCHAR2
  , p_lot                        IN            VARCHAR2
  , p_txn_src_id                 IN            NUMBER
  , p_txn_action_id              IN            NUMBER
  , p_created_by                 IN            NUMBER
  , p_from_serial                IN            VARCHAR2
  , p_to_serial                  IN            VARCHAR2
  , p_status_id                  IN            NUMBER := NULL
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  ) IS
    l_return    NUMBER;
    l_to_serial VARCHAR2(30);
    l_progress  VARCHAR2(10);
    l_msg_count NUMBER;
    l_success   NUMBER       := 0;
    l_count     NUMBER       := 0;
    l_temp_qty  NUMBER       := 0;
    l_debug     NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '10';

    IF (l_debug = 1) THEN
      print_debug('Enter insert_serial: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    SAVEPOINT rcv_insert_serial_sp;
    l_to_serial      := p_to_serial;
    /** we are now calling INV_SERIAL_NUMBER_PUB instead of inv_trx_mgr, for "I" project vipathak
    **/
    l_return         :=
      inv_serial_number_pub.validate_serials(
        p_org_id                     => p_org_id
      , p_item_id                    => p_item_id
      , p_qty                        => l_temp_qty
      , p_rev                        => p_rev
      , p_lot                        => p_lot
      , p_start_ser                  => p_from_serial
      , p_trx_src_id                 => p_txn_src_id
      , p_trx_action_id              => p_txn_action_id
      , x_end_ser                    => l_to_serial
      , x_proc_msg                   => x_msg_data
      );
    l_progress       := '20';

    IF l_return = 1 THEN
      fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '25';
    l_count          := 0;

   -- Bug 4087032 Need to write a wrapper on LENGTH function as
   -- it creates compiltaion issues in 8i env. in the below query

    BEGIN
      SELECT 1
        INTO l_count
        FROM mtl_serial_numbers_temp msnt, mtl_transaction_lots_temp mtlt, mtl_material_transactions_temp mmtt
       WHERE (
              (p_from_serial BETWEEN msnt.fm_serial_number AND msnt.to_serial_number
	       AND get_serial_Length(p_from_serial) = get_serial_Length(msnt.fm_serial_number)
	       AND get_serial_Length(msnt.fm_serial_number) = get_serial_Length(Nvl(msnt.to_serial_number,msnt.fm_serial_number)))
	      OR
	      (p_to_serial BETWEEN msnt.fm_serial_number AND msnt.to_serial_number
	       AND get_serial_Length(p_to_serial) = get_serial_Length(msnt.fm_serial_number)
	       AND get_serial_Length(msnt.fm_serial_number) = get_serial_Length(Nvl(msnt.to_serial_number,msnt.fm_serial_number)))
             )
         AND mmtt.inventory_item_id = p_item_id
         AND mmtt.organization_id = p_org_id
         AND mtlt.transaction_temp_id(+) = mmtt.transaction_temp_id
         AND msnt.transaction_temp_id = NVL(mtlt.serial_transaction_temp_id, mmtt.transaction_temp_id);
    EXCEPTION
      WHEN OTHERS THEN
        l_count  := 0;
    END;

    IF l_count <> 0 THEN
      fnd_message.set_name('INV', 'INVALID_SERIAL_NUMBER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '30';

    IF p_serial_transaction_temp_id IS NULL THEN
      l_progress  := '40';

      SELECT mtl_material_transactions_s.NEXTVAL
        INTO p_serial_transaction_temp_id
        FROM DUAL;

      l_progress  := '50';
    END IF;

    l_progress       := '60';
    l_return         :=
      inv_trx_util_pub.insert_ser_trx(
        p_trx_tmp_id                 => p_serial_transaction_temp_id
      , p_user_id                    => p_created_by
      , p_fm_ser_num                 => p_from_serial
      , p_to_ser_num                 => p_to_serial
      , p_status_id                  => p_status_id
      , x_proc_msg                   => x_msg_data
      );
    l_progress       := '70';

    BEGIN
      UPDATE mtl_serial_numbers
         SET group_mark_id = p_serial_transaction_temp_id
       WHERE inventory_item_id = p_item_id
         AND serial_number BETWEEN p_from_serial AND p_to_serial
         AND LENGTH(serial_number) = LENGTH(p_from_serial);
    EXCEPTION
      WHEN OTHERS THEN
        IF (l_debug = 1) THEN
          print_debug('Exception updating grp. id', 4);
        END IF;
    END;

    IF (l_debug = 1) THEN
      print_debug('Insert serial vals' || p_item_id || ':' || p_from_serial || ':' || p_to_serial, 4);
      print_debug('Insert serial, inserted with ' || p_serial_transaction_temp_id || ':' || l_success, 4);
    END IF;

    -- if the trx manager returned a 1 then it could not insert the row
    IF l_return = 1 THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '80';

    IF (l_debug = 1) THEN
      print_debug('Exitting insert_serial : 90  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_insert_serial_sp;
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_serial - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => l_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.insert_serial', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_serial - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'insert_serial');
      END IF;
  END insert_serial;

   -- Bug 9274276
  PROCEDURE get_rma_uom_code (x_return_status      OUT NOCOPY VARCHAR2,
                            x_uom_code             OUT NOCOPY VARCHAR2,
                            p_order_header_id   IN            NUMBER,
                            p_item_id           IN            NUMBER,
                            p_organization_id   IN            NUMBER)
  IS
   l_progress   VARCHAR2 (10);
   l_debug      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   l_count      NUMBER;
  BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1)
   THEN
      print_debug ('Parameters passed : 10.1: p_order_header_id - ' || p_order_header_id, 4);
      print_debug ('Parameters passed : 10.2: p_item_id - ' || p_item_id, 4);
      print_debug ('Parameters passed : 10.3: p_organization_id - ' || p_organization_id, 4);
   END IF;

   x_uom_code := '@@@';
   l_progress := '10';
   l_count := 0;

   IF p_order_header_id IS NOT NULL AND p_item_id IS NOT NULL
   THEN
      l_progress := '20';
      BEGIN
         SELECT   COUNT (DISTINCT oel.order_quantity_uom)
           INTO   l_count
           FROM   oe_order_lines_all oel, oe_order_headers_all oeh
          WHERE       oel.header_id = p_order_header_id
                  AND oel.ordered_item_id = p_item_id
                  AND NVL (OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
                  AND OEL.LINE_CATEGORY_CODE = 'RETURN'
                  AND oel.cancelled_flag = 'N'
                  AND oel.open_flag = 'Y'
                  AND oel.booked_flag = 'Y'
                  AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
                  AND OEL.ORDERED_QUANTITY > NVL (OEL.SHIPPED_QUANTITY, 0)
                  AND oeh.header_id = oel.header_id
                  AND OEH.OPEN_FLAG = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_count := 0;
      END;

      IF l_count = 1
      THEN
         l_progress := '30';
         BEGIN
            SELECT   inv_ui_item_lovs.get_conversion_rate (oel.order_quantity_uom,
                                                           p_organization_id,
                                                           oel.ordered_item_id)
              INTO   x_uom_code
              FROM   oe_order_lines_all oel
             WHERE       oel.header_id = p_order_header_id
                     AND oel.ordered_item_id = p_item_id
                     AND oel.line_category_code = 'RETURN'
                     AND oel.cancelled_flag = 'N'
                     AND oel.open_flag = 'Y'
                     AND oel.booked_flag = 'Y'
                     AND oel.flow_status_code = 'AWAITING_RETURN'
                     AND EXISTS (SELECT   1
                                   FROM   oe_order_headers_all oeh
                                  WHERE   oeh.open_flag = 'Y' AND oeh.header_id = oel.header_id)
                     AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               x_uom_code := '@@@';
         END;
      END IF;
   END IF;
  EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL
      THEN
         inv_mobile_helper_functions.sql_error ('inv_rcv_common_apis.get_rma_uom_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1)
      THEN
         print_debug ('Exitting get_rma_uom_code - other exception:' || l_progress || ' ' || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, 'get_rma_uom_code');
      END IF;
  END get_rma_uom_code;
  -- Bug 9274276

  -- Bug 9274276
  PROCEDURE get_asn_uom_code (x_return_status         OUT NOCOPY VARCHAR2,
                            x_uom_code                OUT NOCOPY VARCHAR2,
                            p_shipment_header_id   IN            NUMBER,
                            p_item_id              IN            NUMBER,
                            p_organization_id      IN            NUMBER)
  IS
   l_progress   VARCHAR2 (10);
   l_debug      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
   l_count      NUMBER;
  BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1)
   THEN
      print_debug ('Parameters passed : 10.1: p_shipment_header_id - ' || p_shipment_header_id, 4);
      print_debug ('Parameters passed : 10.2: p_item_id - ' || p_item_id, 4);
      print_debug ('Parameters passed : 10.3: p_organization_id - ' || p_organization_id, 4);
   END IF;

   x_uom_code := '@@@';
   l_progress := '10';
   l_count := 0;

   IF p_shipment_header_id IS NOT NULL AND p_item_id IS NOT NULL
   THEN
      l_progress := '20';
      BEGIN
         SELECT   COUNT (DISTINCT rsl.unit_of_measure)
           INTO   l_count
           FROM   rcv_shipment_lines rsl
          WHERE       rsl.shipment_header_id = p_shipment_header_id
                  AND rsl.unit_of_measure IS NOT NULL
                  AND rsl.shipment_line_status_code <> 'FULLY RECEIVED'
                  AND rsl.item_id = p_item_id
                  AND rsl.asn_line_flag = 'Y'
                  AND rsl.to_organization_id = p_organization_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_count := 0;
      END;

      IF l_count = 1
      THEN
         l_progress := '30';
         BEGIN
            SELECT   inv_ui_item_lovs.get_conversion_rate (mum.uom_code, p_organization_id, rsl.item_id)
              INTO   x_uom_code
              FROM   rcv_shipment_lines rsl, mtl_units_of_measure mum
             WHERE       rsl.shipment_header_id = p_shipment_header_id
                     AND rsl.unit_of_measure IS NOT NULL
                     AND rsl.shipment_line_status_code <> 'FULLY RECEIVED'
                     AND rsl.item_id = p_item_id
                     AND mum.unit_of_measure(+) = rsl.unit_of_measure
                     AND rsl.asn_line_flag = 'Y'
                     AND rsl.to_organization_id = p_organization_id
                     AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               x_uom_code := '@@@';
         END;
      END IF;
   END IF;
  EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL
      THEN
         inv_mobile_helper_functions.sql_error ('inv_rcv_common_apis.get_asn_uom_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1)
      THEN
         print_debug (
               'Exitting get_asn_uom_code - other exception:' || l_progress || ' ' || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:DD:SS'),1);
      END IF;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, 'get_asn_uom_code');
      END IF;
  END get_asn_uom_code;
  -- Bug 9274276

  -- Bug 9274276
  PROCEDURE get_asn_uom_code (x_return_status         OUT NOCOPY VARCHAR2,
                            x_uom_code                OUT NOCOPY VARCHAR2,
                            p_shipment_header_id   IN            NUMBER,
                            p_item_id              IN            NUMBER,
                            p_organization_id      IN            NUMBER,
                            P_item_desc            IN            Varchar2)
  IS
     l_progress   VARCHAR2 (10);
     l_class      VARCHAR2 (10);
     l_debug      NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF (l_debug = 1)
   THEN
      print_debug ('Parameters passed : 10.1: p_shipment_header_id - ' || p_shipment_header_id, 4);
      print_debug ('Parameters passed : 10.2: p_item_id - ' || p_item_id, 4);
      print_debug ('Parameters passed : 10.3: p_organization_id - ' || p_organization_id, 4);
      print_debug ('Parameters passed : 10.5: P_item_desc - ' || P_item_desc, 4);
   END IF;

   x_uom_code := '@@@';
   l_progress := '10';

   IF p_shipment_header_id IS NOT NULL AND P_item_desc IS NOT NULL
   THEN
      l_progress := '20';
      BEGIN
         SELECT   mum.uom_code, mum.uom_class
           INTO   x_uom_code, l_class
           FROM   rcv_shipment_lines rsl, mtl_units_of_measure mum
          WHERE       rsl.shipment_header_id = p_shipment_header_id
                  AND rsl.unit_of_measure IS NOT NULL
                  AND rsl.shipment_line_status_code <> 'FULLY RECEIVED'
                  AND rsl.item_description = p_item_desc
                  AND mum.unit_of_measure(+) = rsl.unit_of_measure
                  AND rsl.asn_line_flag = 'Y'
                  AND rsl.to_organization_id = p_organization_id
                  AND ROWNUM = 1;

           SELECT   INV_UI_RCV_LOVS.get_conversion_rate_expense (muom.uom_code,
                                                                 p_organization_id,
                                                                 0,
                                                                 x_uom_code)
             INTO   x_uom_code
             FROM   mtl_uom_conversions_val_v muc, mtl_units_of_measure muom
            WHERE       muc.uom_class = l_class
                    AND muc.item_id = 0
                    AND NVL (muc.disable_date, SYSDATE + 1) > SYSDATE
                    AND muc.unit_of_measure = muom.unit_of_measure
                    AND NVL (muom.disable_date, SYSDATE + 1) > SYSDATE
                    AND muom.uom_code LIKE (x_uom_code)
         ORDER BY   muc.unit_of_measure;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_uom_code := '@@@';
      END;
   ELSIF p_shipment_header_id IS NOT NULL AND p_item_desc IS NULL
   THEN
      l_progress := '30';
      BEGIN
         SELECT   mum.uom_code, mum.uom_class
           INTO   x_uom_code, l_class
           FROM   rcv_shipment_lines rsl, mtl_units_of_measure mum
          WHERE       rsl.shipment_header_id = p_shipment_header_id
                  AND rsl.unit_of_measure IS NOT NULL
                  AND rsl.shipment_line_status_code <> 'FULLY RECEIVED'
                  AND rsl.item_id IS NULL
                  AND mum.UNIT_OF_MEASURE(+) = rsl.unit_of_measure
                  AND RSL.ASN_LINE_FLAG = 'Y'
                  AND rsl.TO_ORGANIZATION_ID = p_organization_id
                  AND ROWNUM = 1;

           SELECT   INV_UI_RCV_LOVS.get_conversion_rate_expense (muom.uom_code,
                                                                 p_organization_id,
                                                                 0,
                                                                 x_uom_code)
             INTO   x_uom_code
             FROM   mtl_uom_conversions_val_v muc, mtl_units_of_measure muom
            WHERE       muc.uom_class = l_class
                    AND muc.item_id = 0
                    AND NVL (muc.disable_date, SYSDATE + 1) > SYSDATE
                    AND muc.unit_of_measure = muom.unit_of_measure
                    AND NVL (muom.disable_date, SYSDATE + 1) > SYSDATE
                    AND muom.uom_code LIKE (x_uom_code)
         ORDER BY   muc.unit_of_measure;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_uom_code := '@@@';
      END;
   END IF;
  EXCEPTION
   WHEN OTHERS
   THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL
      THEN
         inv_mobile_helper_functions.sql_error ('inv_rcv_common_apis.get_asn_uom_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1)
      THEN
         print_debug ('Exitting get_asn_uom_code - other exception:' || l_progress || ' ' || TO_CHAR (SYSDATE, 'YYYY-MM-DD HH:DD:SS'),1);
      END IF;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, 'get_asn_uom_code');
      END IF;
  END get_asn_uom_code;
  -- Bug 9274276

--BUG#3062591
  PROCEDURE get_uom_code(
			  x_return_status      OUT NOCOPY    VARCHAR2
			, x_uom_code           OUT NOCOPY    VARCHAR2
			, p_po_header_id       IN            NUMBER
                        , p_item_id            IN            NUMBER
                        , p_organization_id    IN            NUMBER
			, p_line_no            IN            NUMBER    --BUG 4500676
			, p_item_desc          IN            VARCHAR2  --BUG 4500676
			) IS
       l_progress   VARCHAR2(10);
       l_class      VARCHAR2(10);
       l_debug      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_count      NUMBER;
  BEGIN
        x_return_status  := fnd_api.g_ret_sts_success;
        IF (l_debug = 1) THEN
             print_debug('Entering get_uom_code',4);
             print_debug('Parameters passed : 10.1: p_po_header_id - ' || p_po_header_id , 4);
	     print_debug('Parameters passed : 10.2: p_item_id - ' || p_item_id, 4);
	     print_debug('Parameters passed : 10.3: p_organization_id - ' || p_organization_id, 4);
             print_debug('Parameters passed : 10.4: p_line_no - ' || p_line_no , 4);
             print_debug('Parameters passed : 10.5: p_item_desc - ' || p_item_desc, 4);
        END IF;

        x_uom_code := '@@@';
        l_progress := '10';
	l_count    := 0;

	  --BUG 4500676: Add logic to retrieve uom_code for expense item
          IF p_po_header_id IS NOT NULL AND p_item_id IS NULL  and p_line_no is not null THEN
            l_progress  := '20';
            BEGIN
            SELECT mum.uom_code, mum.uom_class
             INTO x_uom_code, l_class
             FROM po_lines pol, mtl_units_of_measure mum
            WHERE pol.po_header_id = p_po_header_id
              AND pol.unit_meas_lookup_code IS NOT NULL
              AND pol.line_num = p_line_no
              AND pol.unit_meas_lookup_code = mum.unit_of_measure
              AND pol.po_line_id IN (SELECT poll.po_line_id
                           FROM po_line_locations_all poll, po_lines_all po
                                  WHERE poll.po_header_id = po.po_header_id
                                  AND Nvl(poll.approved_flag,'N') =  'Y'
                                  AND Nvl(poll.cancel_flag,'N') = 'N'
                                  AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING')
                                  AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                                  AND poll.ship_to_organization_id = p_organization_id
                                  AND poll.po_line_id = po.po_line_id
                                  AND po.po_header_id = p_po_header_id)
              AND ROWNUM=1;
            SELECT INV_UI_RCV_LOVS.get_conversion_rate_expense(muom.uom_code,p_organization_id  ,0,x_uom_code )
            into x_uom_code
            from
              mtl_uom_conversions_val_v muc ,
              mtl_units_of_measure muom
            where muc.uom_class = l_class
            and muc.item_id = 0
            and nvl(muc.disable_date,sysdate+1)>sysdate
            and muc.unit_of_measure = muom.unit_of_measure
            and nvl(muom.disable_date,sysdate+1) > sysdate
            and muom.uom_code like (x_uom_code)
            order by muc.unit_of_measure;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              x_uom_code := '@@@';
            END;
          Elsif p_po_header_id IS NOT NULL AND p_item_id IS NULL  and p_line_no is null and p_item_desc is not null THEN
            l_progress  := '30';
            BEGIN
            SELECT mum.uom_code, mum.uom_class
             INTO x_uom_code, l_class
             FROM po_lines pol, mtl_units_of_measure mum
            WHERE pol.po_header_id = p_po_header_id
              AND pol.unit_meas_lookup_code IS NOT NULL
              AND pol.unit_meas_lookup_code = mum.unit_of_measure
              AND pol.item_description = p_item_desc
              AND pol.po_line_id IN (SELECT poll.po_line_id
                           FROM po_line_locations_all poll, po_lines_all po
                                  WHERE poll.po_header_id = po.po_header_id
                                  AND Nvl(poll.approved_flag,'N') =  'Y'
                                  AND Nvl(poll.cancel_flag,'N') = 'N'
                                  AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING')
                                  AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                                  AND poll.ship_to_organization_id = p_organization_id
                                  AND poll.po_line_id = po.po_line_id
                                  AND po.po_header_id = p_po_header_id)
              AND ROWNUM=1;
            SELECT INV_UI_RCV_LOVS.get_conversion_rate_expense(muom.uom_code, p_organization_id  ,0,x_uom_code )
            into x_uom_code
            from
              mtl_uom_conversions_val_v muc ,
              mtl_units_of_measure muom
            where muc.uom_class = l_class
            and muc.item_id = 0
            and nvl(muc.disable_date,sysdate+1)>sysdate
            and muc.unit_of_measure = muom.unit_of_measure
            and nvl(muom.disable_date,sysdate+1) > sysdate
            and muom.uom_code like (x_uom_code)
            order by muc.unit_of_measure;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              x_uom_code := '@@@';
            END;
	  --END BUG 4500676

          ELSIF p_po_header_id IS NOT NULL AND p_item_id IS NOT NULL THEN
            l_progress  := '20';
            BEGIN
            SELECT COUNT(DISTINCT pol.unit_meas_lookup_code)
             INTO l_count
             FROM po_lines pol
            WHERE pol.po_header_id = p_po_header_id
              AND pol.unit_meas_lookup_code IS NOT NULL
              AND pol.item_id = p_item_id
	      AND pol.po_line_id IN (SELECT poll.po_line_id
	                          FROM po_line_locations_all poll, po_lines_all po
                                  WHERE poll.po_header_id = po.po_header_id
                                  AND Nvl(poll.approved_flag,'N') =  'Y'
                                  AND Nvl(poll.cancel_flag,'N') = 'N'
                                  AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING')
                                  AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                                  AND poll.ship_to_organization_id = p_organization_id
                                  AND poll.po_line_id = po.po_line_id
                                  AND po.item_id = p_item_id
                                  AND po.po_header_id = p_po_header_id);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
              l_count  := 0;
            END;

          IF l_count = 1 THEN
            l_progress  := '30';
            BEGIN
            SELECT inv_ui_item_lovs.get_conversion_rate(mum.uom_code,
                                   p_organization_id,
                                   pol.item_id)
             INTO x_uom_code
             FROM po_lines pol
                  , mtl_units_of_measure mum
            WHERE pol.po_header_id = p_po_header_id
              AND pol.unit_meas_lookup_code IS NOT NULL
              AND pol.item_id = p_item_id
              AND mum.UNIT_OF_MEASURE(+) = pol.UNIT_MEAS_LOOKUP_CODE
              AND pol.po_line_id IN (SELECT poll.po_line_id
                                  FROM po_line_locations_all poll, po_lines_all po
                                  WHERE poll.po_header_id = po.po_header_id
                                  AND Nvl(poll.approved_flag,'N') =  'Y'
                                  AND Nvl(poll.cancel_flag,'N') = 'N'
                                  AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING')
                                  AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                                  AND poll.ship_to_organization_id = p_organization_id
                                  AND poll.po_line_id = po.po_line_id
                                  AND po.item_id = p_item_id
                                  AND po.po_header_id = p_po_header_id)
              AND ROWNUM = 1;
            EXCEPTION
              WHEN OTHERS THEN
                 x_uom_code := '@@@';
            END;
          END IF;
       END IF;

       IF (l_debug = 1) THEN
	  print_debug('x_uom_code:'||x_uom_code,4);
       END IF;
   EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_uom_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_uom_code - other exception:' || l_progress ||' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_uom_code');
      END IF;

  END get_uom_code;--BUG#3062591

  -- This api is used to return the possible value that can be used for
  -- subinventory when the item and PO/Shipment Number/RMA are entered.
  -- For RMA it always returns null for subinventory.
  PROCEDURE get_sub_code(
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_sub_code           OUT NOCOPY VARCHAR2,
       x_locator_segs       OUT NOCOPY VARCHAR2,
       x_locator_id         OUT NOCOPY NUMBER,
       x_lpn_context        OUT NOCOPY NUMBER,
       x_default_source     OUT NOCOPY VARCHAR2,
       p_po_header_id       IN         NUMBER,
       p_po_release_id      IN         NUMBER,
       p_po_line_id         IN         NUMBER,
       p_shipment_header_id IN         NUMBER,
       p_oe_order_header_id IN         NUMBER,
       p_item_id            IN         NUMBER,
       p_organization_id    IN         NUMBER,
       p_lpn_id             IN         NUMBER DEFAULT NULL,
       p_project_id         IN         NUMBER DEFAULT NULL,
       p_task_id            IN         NUMBER DEFAULT NULL) IS
    l_count               NUMBER;
    l_locator_id          NUMBER := -1;
    l_lpn_context         NUMBER := 5;
    l_lpn_controlled_flag NUMBER := 2;
    l_progress            VARCHAR2(10);
    l_auto_transact_code  VARCHAR2(10);
    l_is_pjm_org          NUMBER := 2;
    l_loc_project_id      NUMBER;
    l_loc_task_id         NUMBER;
    l_debug               NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_kanban_card_id      NUMBER := -999; --Bug 4671198
    l_count_lpn           NUMBER := 0; --Bug 5928199
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    /* Two new parameter x_lpn_context and x_default_source have been added
     * to return the lpn_context and a flag that indicates how the
     * subinventory and locator have been defaulted. Possible values are:
     *   LPN  -> Sub and locator are derived from WMS_LICENSE_PLATE_NUMBERS
     *   RTI  -> Sub and locator are derived from RCV_TRANSACTIONS_INTERFACE
     *   DOC  -> Sub and locator are derived from document (POD/RSL/REQ)
     *   ITD  -> Sub and locator are derived from item transaction defaults
     *   NONE -> There is no default sub and locator being returned
     * This validation is applicable only if INV and PO patch levels are J or
     * higher and is used by the Receipt UI to default the sub and locator beans.
     * If patch levels are < J, this variable would hold the value NONE
     */
    x_default_source := 'NONE';
    x_lpn_context := 5;

    IF (l_debug = 1) THEN
      print_debug('Enter  get_sub_code: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('Parameters passed : 10.1: p_po_header_id - ' || p_po_header_id, 4);
      print_debug('Parameters passed : 10.2: p_po_release_id - ' || p_po_release_id, 4);
      print_debug('Parameters passed : 10.3: p_po_line_id - ' || p_po_line_id, 4);
      print_debug('Parameters passed : 10.4: p_shipment_header_id - ' || p_shipment_header_id, 4);
      print_debug('Parameters passed : 10.5: p_oe_order_header_id - ' || p_oe_order_header_id, 4);
      print_debug('Parameters passed : 10.6: p_item_id - ' || p_item_id, 4);
      print_debug('Parameters passed : 10.7: p_organization_id - ' || p_organization_id, 4);
      print_debug('Parameters passed : 10.8: p_lpn_id - ' || p_lpn_id, 4);
      print_debug('Parameters passed : 10.9: p_project_id - ' || p_project_id, 4);
      print_debug('Parameters passed : 10.10: p_task_id - ' || p_task_id, 4);
    END IF;

    x_sub_code       := '@@@';
    x_locator_segs   := '@@@';
    x_locator_id     := -1;
    l_progress       := '10';

    IF (p_lpn_id IS NOT NULL AND p_lpn_id > 0) THEN
      BEGIN
        SELECT NVL(subinventory_code, '@@@')
             , NVL(locator_id, -1)
             , lpn_context
          INTO x_sub_code
             , l_locator_id
             , l_lpn_context
          FROM wms_license_plate_numbers
         WHERE lpn_id = p_lpn_id;


       --added for Bug 5928199
        select count(*) into l_count_lpn
	from wms_lpn_contents
         WHERE parent_lpn_id = p_lpn_id;

        --Set the out variable for lpn_context
        x_lpn_context := l_lpn_context;
	--added for Bug 5928199
    IF (l_debug = 1) THEN
	print_debug('lpn_context'||l_lpn_context||'l_locator_id'||l_locator_id||'x_sub_code'||x_sub_code,4);
    END IF;

        --Bug #3360067
        --If the LPN resides in inventory and the current org is PJM-enabled
        --get the project_id and task_id from MTL_ITEM_LOCATIONS for this locator
        --and compare the project and task of the locator with those passed
        --In case of project/task commingling, raise an error indicating the same
      --Added extra condition l_count_lpn <> 0 for Bug 5928199
           IF (l_lpn_context = 1 AND l_locator_id IS NOT NULL AND l_count_lpn <> 0) THEN

          SELECT NVL(project_reference_enabled, 2)
          INTO   l_is_pjm_org
          FROM   mtl_parameters
          WHERE  organization_id = p_organization_id;

          IF (l_is_pjm_org = 1) THEN
            SELECT  mil.project_id
                  , mil.task_id
            INTO    l_loc_project_id
                  , l_loc_task_id
            FROM    mtl_item_locations mil
            WHERE   mil.organization_id = p_organization_id
            AND     mil.inventory_location_id = l_locator_id;

            IF (l_debug = 1) THEN
                print_debug('l_loc_project_id'||l_loc_project_id||'l_loc_task_id'||l_loc_task_id,4);
                print_debug('p_project_id'||p_project_id||'p_task_id'||p_task_id,4);
            END IF;

            IF (NVL(p_project_id,-9999) <> NVL(l_loc_project_id,-9999)) OR
               (NVL(p_task_id,-9999) <> NVL(l_loc_task_id,-9999)) THEN
              x_return_status  := fnd_api.g_ret_sts_error;
              x_msg_data       := 'INV_PRJ_ERR';
              fnd_message.set_name('INV', 'INV_PRJ_ERR');
              fnd_msg_pub.ADD;
            END IF;   --End if check for proj/task comm error
          END IF;  --END IF current org is PJM enabled
        END IF;  --END IF lpn_context = 1

        IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
            (inv_rcv_common_apis.g_po_patch_level >= inv_rcv_common_apis.g_patchset_j_po)) THEN

          --If the LPN has a sub/loc associated, set the defaulting source
          IF x_sub_code <> '@@@' AND l_locator_id IS NOT NULL THEN
            x_default_source := 'LPN';
          END IF;

          IF (l_lpn_context = 5 AND x_sub_code = '@@@') THEN

            IF (l_debug = 1) THEN
              print_debug('get_sub_code: WMS and PO are J or higher: should also check for sub/loc from RTI', 4);
            END IF;

            --Get the subinventory, locator_id and routing from rcv_transactions_interface
            --If there exists one and it is not direct then error out with the
            --"Invalid LPN context" error since we cannot commingle routings in the same LPN
            BEGIN
              SELECT  NVL(subinventory, '@@@')
                    , NVL(locator_id, -1)
                    , auto_transact_code
              INTO    x_sub_code
                    , l_locator_id
                    , l_auto_transact_code
              FROM    rcv_transactions_interface
              WHERE   transfer_lpn_id = p_lpn_id
              AND     transaction_type = 'RECEIVE'
              AND     transaction_status_code = 'PENDING'
              AND     processing_status_code <> 'ERROR'
              AND     ROWNUM = 1;

              IF (NVL(l_auto_transact_code, 'RECEIVE') <> 'DELIVER') THEN
                x_return_status  := fnd_api.g_ret_sts_error;
                x_msg_data       := 'INV_CANNOT_COMMINGLE_ROUTING';
		            fnd_message.set_name('INV', 'INV_CANNOT_COMMINGLE_ROUTING');
                fnd_msg_pub.ADD;
                RETURN;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                x_sub_code    := '@@@';
                l_locator_id  := -1;
            END;

            --If the RTI record has a sub/loc associated, set the defaulting source
            IF x_sub_code <> '@@@' THEN
              x_default_source := 'RTI';
            END IF;

          END IF;  --END IF LPN context is defined but not used
        END IF;  --END IF patch levels are J or higher
      EXCEPTION
        WHEN OTHERS THEN
          x_sub_code    := '@@@';
          l_locator_id  := -1;
          l_lpn_context := 5;
      END;
    END IF;

    IF x_sub_code = '@@@' THEN
      IF p_po_header_id IS NOT NULL THEN
        l_progress  := '20';

        BEGIN
          SELECT COUNT(DISTINCT pod.destination_subinventory)
            INTO l_count
            FROM po_distributions pod
           WHERE pod.po_header_id = p_po_header_id
             AND pod.po_line_id = NVL(p_po_line_id, pod.po_line_id)
             AND NVL(pod.po_release_id, -1) = NVL(p_po_release_id, NVL(pod.po_release_id, -1))
             AND pod.destination_subinventory IS NOT NULL
             AND pod.po_line_id IN(SELECT pol.po_line_id
                                     FROM po_lines pol
                                    WHERE pol.item_id = p_item_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count  := 0;
        END;
        l_progress  := '35';
        BEGIN
          SELECT pod.destination_subinventory, nvl(kanban_card_id, -999) --Bug 4671198
            INTO x_sub_code, l_kanban_card_id --Bug 4671198
            FROM po_distributions pod
           WHERE pod.po_header_id = p_po_header_id
             AND pod.po_line_id = NVL(p_po_line_id, pod.po_line_id)
             AND NVL(pod.po_release_id, -1) = NVL(p_po_release_id, NVL(pod.po_release_id, -1))
             AND pod.destination_subinventory IS NOT NULL
             AND pod.po_line_id IN(SELECT pol.po_line_id
                                     FROM po_lines pol
                                    WHERE pol.item_id = p_item_id)
             AND ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            x_sub_code  := '@@@';
        END;

  	--Begin bug 4671198
  	IF ((x_sub_code <> '@@@') AND (l_kanban_card_id <> -999)) THEN

        	BEGIN
          		SELECT NVL(locator_id, -1)
          		INTO l_locator_id
          		FROM mtl_kanban_cards
          		WHERE  kanban_card_id = l_kanban_card_id
          		AND    subinventory_name = x_sub_code;

          	EXCEPTION
            		WHEN NO_DATA_FOUND THEN
              			l_locator_id := -1;
        	END;
        END IF;
	--End Bug 4671198

	--If the document (POD) has a sub/loc associated, set the defaulting source
        IF x_sub_code <> '@@@' THEN
          x_default_source := 'DOC';
        END IF;
        --END IF;

        l_progress  := '37';
      ELSIF p_shipment_header_id IS NOT NULL THEN
        l_progress  := '40';

        BEGIN
          SELECT COUNT(DISTINCT rsl.to_subinventory)
            INTO l_count
            FROM rcv_shipment_lines rsl
           WHERE rsl.shipment_header_id = p_shipment_header_id
             AND rsl.item_id = NVL(p_item_id, rsl.item_id)
             AND rsl.to_subinventory IS NOT NULL;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count  := 0;
        END;

        l_progress  := '50';

        IF l_count = 1 THEN
          l_progress  := '55';

          BEGIN
            SELECT rsl.to_subinventory
                 , NVL(rsl.locator_id, -1)
              INTO x_sub_code
                 , l_locator_id
              FROM rcv_shipment_lines rsl
             WHERE rsl.shipment_header_id = p_shipment_header_id
               AND rsl.item_id = NVL(p_item_id, rsl.item_id)
               AND rsl.to_subinventory IS NOT NULL
               AND ROWNUM = 1;
          EXCEPTION
            WHEN OTHERS THEN
              x_sub_code    := '@@@';
              l_locator_id  := -1;
          END;
          --If the document (RSL) has a sub/loc associated, set the defaulting source
          IF x_sub_code <> '@@@' THEN
            x_default_source := 'DOC';
          END IF;
        END IF;
      END IF;
    END IF;

    l_progress       := '60';

    IF x_sub_code = '@@@' THEN
      l_progress  := '70';

      BEGIN
        SELECT subinventory_code
          INTO x_sub_code
          FROM mtl_item_sub_defaults
         WHERE inventory_item_id = p_item_id
           AND organization_id = p_organization_id
           AND default_type = 2;
      EXCEPTION
        WHEN OTHERS THEN
          x_sub_code  := '@@@';
      END;

      l_progress  := '80';

      /* Bug 2323718: Changed the query so that records are filtered on Project and Task */
      IF x_sub_code <> '@@@' THEN
        l_progress  := '90';

        --Set the defaulting type to indicate that the sub is available in item defaults
        x_default_source := 'ITD';

        BEGIN
          SELECT mild.locator_id
            INTO l_locator_id
            FROM mtl_item_loc_defaults mild, mtl_item_locations mil
           WHERE mild.inventory_item_id = p_item_id
             AND mild.organization_id = p_organization_id
             AND mild.subinventory_code = x_sub_code
             AND mil.inventory_location_id = mild.locator_id
             AND(p_project_id IS NULL
                 OR(p_project_id = -9999
                    AND mil.project_id IS NULL)
                 OR mil.project_id = p_project_id)
             AND NVL(mil.task_id, -1) = NVL(p_task_id, NVL(mil.task_id, -1))
             AND mild.default_type = 2;
        EXCEPTION
          WHEN OTHERS THEN
            l_locator_id  := -1;
        END;
      END IF;

--BUG 5972088
     -- Bug# 7013341, removed the condition x_locator_segs ='@@@' and added
     -- the condition l_locator_id = -1 instead, as x_locator_segs is assigned a
     -- valid value only at the end of this function once a valid locator ccid
     -- is identified from the above code logic.
     -- Hence there could be a scenario where l_locator_id is having a valid locator_id
     -- but x_locator_segs is still '@@@'.
     ELSIF x_sub_code <> '@@@' AND l_locator_id = -1 THEN
     -- End of bug# 7013341
        l_progress  := '90';
        --Set the defaulting type to indicate that the sub is available in item defaults
        x_default_source := 'ITD';
        BEGIN
          SELECT mild.locator_id
            INTO l_locator_id
            FROM mtl_item_loc_defaults mild, mtl_item_locations mil
           WHERE mild.inventory_item_id = p_item_id
             AND mild.organization_id = p_organization_id
             AND mild.subinventory_code = x_sub_code
             AND mil.inventory_location_id = mild.locator_id
             AND(p_project_id IS NULL
                 OR(p_project_id = -9999
                    AND mil.project_id IS NULL)
                 OR mil.project_id = p_project_id)
             AND NVL(mil.task_id, -1) = NVL(p_task_id, NVL(mil.task_id, -1))
             AND mild.default_type = 2;
        EXCEPTION
          WHEN OTHERS THEN
            l_locator_id  := -1;
        END;
--END BUG 5972088

    END IF;

    l_progress       := '100';

    /* Bug 2323718: Returning INV_PROJECT.get_locsegs rather than conc. segments */
    IF l_locator_id <> -1 THEN
      l_progress  := '110';

      BEGIN
        SELECT inv_project.get_locsegs(inventory_location_id, organization_id)
          INTO x_locator_segs
          FROM mtl_item_locations
         WHERE organization_id = p_organization_id
           AND inventory_location_id = l_locator_id;

        x_locator_id  := l_locator_id;
      EXCEPTION
        WHEN OTHERS THEN
          x_locator_segs  := '@@@';
          x_locator_id    := -1;
      END;
    END IF;

    l_progress       := '120';

    --If the INV or PO patch levels are < J, then we can reset the OUT variable
    --x_default_source since it would not be used for UI validations
    IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
      x_default_source := 'NONE';
      x_lpn_context := 5;
    ELSE
      --If there was no sub/locator defaulted then reset the out variable
      IF ((NVL(x_sub_code, '@@@') = '@@@') OR (x_locator_id IS NULL OR x_locator_id = -1)) THEN
        x_default_source := 'NONE';
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Exitting get_sub_code : 120  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('with values: x_locator_segs: ' || x_locator_segs || 'x_locator_id: ' || x_locator_id || 'x_sub_code: ' || x_sub_code,1);
      print_debug('x_lpn_context: ' || x_lpn_context || 'x_default_source: ' || x_default_source, 1);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_sub_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_sub_code - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_sub_code');
      END IF;
  END get_sub_code;

  -- This api is used to return the possible value that can be used for
  -- subinventory when the item and PO/Shipment Number/RMA are entered.
  -- For RMA it always returns null for subinventory.
  PROCEDURE get_sub_code(
       x_return_status      OUT NOCOPY VARCHAR2,
       x_msg_count          OUT NOCOPY NUMBER,
       x_msg_data           OUT NOCOPY VARCHAR2,
       x_sub_code           OUT NOCOPY VARCHAR2,
       x_locator_segs       OUT NOCOPY VARCHAR2,
       x_locator_id         OUT NOCOPY NUMBER,
       p_po_header_id       IN         NUMBER,
       p_po_release_id      IN         NUMBER,
       p_po_line_id         IN         NUMBER,
       p_shipment_header_id IN         NUMBER,
       p_oe_order_header_id IN         NUMBER,
       p_item_id            IN         NUMBER,
       p_organization_id    IN         NUMBER,
       p_lpn_id             IN         NUMBER DEFAULT NULL,
       p_project_id         IN         NUMBER DEFAULT NULL,
       p_task_id            IN         NUMBER DEFAULT NULL) IS
    l_lpn_context   NUMBER;
    l_default_source VARCHAR2(10);
    l_debug               NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter  get_sub_code: default implementation:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    get_sub_code(
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       x_sub_code           => x_sub_code,
       x_locator_segs       => x_locator_segs,
       x_locator_id         => x_locator_id,
       x_lpn_context        => l_lpn_context,
       x_default_source     => l_default_source,
       p_po_header_id       => p_po_header_id,
       p_po_release_id      => p_po_release_id,
       p_po_line_id         => p_po_line_id,
       p_shipment_header_id => p_shipment_header_id,
       p_oe_order_header_id => p_oe_order_header_id,
       p_item_id            => p_item_id,
       p_organization_id    => p_organization_id,
       p_lpn_id             => p_lpn_id,
       p_project_id         => p_project_id,
       p_task_id            => p_task_id);
  END get_sub_code;


--Bug 3890706 - Added the procedure to select the location based on the entry in the PO form.

PROCEDURE get_location_code
(
 x_return_status      OUT NOCOPY VARCHAR2,
 x_location_code      OUT NOCOPY VARCHAR2,
 p_po_header_id       IN         NUMBER,
 p_item_id            IN         NUMBER,
 p_po_line_id         IN         NUMBER,
 p_po_release_id      IN         NUMBER,
 p_organization_id    IN	 NUMBER,
 p_shipment_header_id IN         NUMBER DEFAULT NULL,
 p_from_lpn_id        IN         NUMBER DEFAULT NULL)

 IS
   l_progress           VARCHAR2(10);
   l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN

   x_location_code  := '' ;
   x_return_status  := fnd_api.g_ret_sts_success;

 IF (l_debug = 1) THEN
      print_debug('Enter get_location_code: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('Parameters passed : 10.1: p_po_header_id - ' || p_po_header_id, 4);
      print_debug('Parameters passed : 10.2: p_item_id - ' || p_item_id, 4);
      print_debug('Parameters passed : 10.3: p_po_release_id - ' || p_po_release_id, 4);
      print_debug('Parameters passed : 10.4: p_po_line_id - ' || p_po_line_id, 4);
      print_debug('Parameters passed : 10.5: org_id - ' || p_organization_id, 4);
      print_debug('Parameters passed : 10.6: p_shipment_header_id - ' || p_shipment_header_id, 4);
      print_debug('Parameters passed : 10.7: p_from_lpn_id - ' || p_from_lpn_id, 4);
 END IF;

 l_progress       := '10';

 IF p_po_header_id IS NOT NULL THEN

 -- bug 8643313
   BEGIN
   SELECT distinct(hl.location_code)
                        into x_location_code
                        FROM hr_locations hl, po_distributions_all pda,po_lines_all pol, PO_LINE_LOCATIONS_ALL pll
                        WHERE (hl.location_id           = pda.deliver_to_location_id)
                        AND pda.po_header_id           = p_po_header_id
                        AND pda.po_line_id             = NVL(p_po_line_id, pda.po_line_id)
                        AND Nvl(pol.item_id,-9999)      = NVL(p_item_id,Nvl(pol.item_id,-9999))
                        AND pda.destination_organization_id= p_organization_id
                        AND NVL(pda.po_release_id, -1) = NVL(p_po_release_id, NVL(pda.po_release_id, -1))
                        AND pol.po_line_id              = pda.po_line_id
                        AND NVL(pll.po_release_id, -1) = NVL(p_po_release_id, NVL(pll.po_release_id, -1))
                        AND pll.po_header_id           = p_po_header_id
                        AND pll.po_line_id             = NVL(p_po_line_id, pll.po_line_id)
                        AND pll.receiving_routing_id   = 3;
    EXCEPTION
    WHEN No_Data_Found THEN
        x_location_code := null;
    WHEN too_many_rows THEN
        x_location_code := null;
    WHEN OTHERS THEN
        x_location_code := null;

    END;

   IF (x_location_code IS NULL) THEN

   -- bug 864331
   SELECT distinct( hl.location_code )
                        into x_location_code
                        FROM hr_locations hl, po_line_locations poll,po_lines pol
                        WHERE hl.location_id            = poll.ship_to_location_id
                        AND poll.po_header_id           = p_po_header_id
                        AND poll.po_line_id             = NVL(p_po_line_id, poll.po_line_id)
                        AND Nvl(pol.item_id,-9999)      = NVL(p_item_id,Nvl(pol.item_id,-9999))--BUG 4500676
                        AND poll.ship_to_organization_id= p_organization_id
                        AND NVL(poll.po_release_id, -1) = NVL(p_po_release_id, NVL(poll.po_release_id, -1))
                        AND pol.po_line_id              = poll.po_line_id
	                AND NVL(poll.po_release_id, -1) = NVL(p_po_release_id, NVL(poll.po_release_id, -1))
        		AND Nvl(poll.approved_flag,'N') = 'Y'
		        AND Nvl(poll.cancel_flag,'N')   = 'N'
		        AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING')
	        	AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED');

	 END IF;  -- bug 864331

			l_progress :='20';
        IF (l_debug = 1) THEN
         print_debug('Checking the value for location: ' || x_location_code, 4);
        END IF;
  ELSIF p_shipment_header_id IS NOT NULL THEN
   SELECT distinct( hl.location_code )
                        into x_location_code
                        FROM hr_locations hl, rcv_shipment_lines rsl
                        WHERE hl.location_id            = nvl(rsl.deliver_to_location_id,rsl.ship_to_location_id)--bug10349270 for ASN receipt,we should get the default location against RSL.ship_to_location
                        AND   rsl.shipment_header_id    = p_shipment_header_id
                        AND   rsl.item_id               = NVL(p_item_id, rsl.item_id)
                        AND   rsl.to_organization_id    = p_organization_id
                        AND   NVL(rsl.asn_lpn_id,-1)    = NVL(p_from_lpn_id,NVL(rsl.asn_lpn_id,-1))
                        AND   rsl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED');

        IF (l_debug = 1) THEN
         print_debug('Checking the value for location of Shipment: ' || x_location_code, 4);
        END IF;

 END IF;

 EXCEPTION
     WHEN too_many_rows THEN
	l_progress := '30' ;
	IF (l_debug = 1) THEN
         print_debug('There are multiple values for location ', 4);
        END IF;
	x_location_code := '';
	RETURN;
     WHEN no_data_found THEN
	l_progress:= '40' ;
	x_location_code := '';
	RETURN;

     WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_location_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_location_code - other exception: ' ||  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_location_code');
      END IF;

END get_location_code;


--End of fix for the Bug 3890706.

--Bug 4003683 -Added the procedure to default the revision for the item.

PROCEDURE GET_REVISION_CODE(
      x_return_status      OUT NOCOPY VARCHAR2,
      x_revision_code      OUT NOCOPY VARCHAR2,
      p_document_type      IN  VARCHAR2 DEFAULT NULL,
      p_po_header_id       IN  NUMBER   DEFAULT NULL,
      p_po_line_id         IN  NUMBER   DEFAULT NULL,
      p_po_release_id      IN  NUMBER DEFAULT NULL,
      p_req_header_id      IN  NUMBER DEFAULT NULL,
      p_shipment_header_id IN  NUMBER DEFAULT NULL,
      p_item_id            IN  NUMBER DEFAULT NULL,
      p_organization_id    IN  NUMBER,
      p_oe_order_header_id IN  NUMBER DEFAULT NULL)  -- Bug #:5768262 Added parameter p_oe_order_header_id to default the revision of item for RMA

     IS
     l_progress           VARCHAR2(10);
     l_shipment_header_id NUMBER ;
     l_debug              NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_return_status      VARCHAR2(1)    := fnd_api.g_ret_sts_success;
     l_msg_count          NUMBER;
     l_msg_data           VARCHAR2(4000);
     l_rcvreq_use_intship VARCHAR2(1) := 'N' ;
     l_doc_type           VARCHAR2(50) := ' ';


  BEGIN
     l_shipment_header_id :=  p_shipment_header_id;
     x_revision_code  := '' ;
     x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
       print_debug('Enter get_revision_code: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
       print_debug('Parameters passed : 10.1: p_document_type - '      || p_document_type,     4);
       print_debug('Parameters passed : 10.2: p_po_header_id - '       || p_po_header_id,      4);
       print_debug('Parameters passed : 10.3: p_po_line_id - '         || p_po_line_id,        4);
       print_debug('Parameters passed : 10.4: p_po_release_id - '      || p_po_release_id,     4);
       print_debug('Parameters passed : 10.6: p_req_header_id - '      || p_req_header_id,     4);
       print_debug('Parameters passed : 10.7: p_shipment_header_id - ' || p_shipment_header_id,4);
       print_debug('Parameters passed : 10.8: p_item_id - '            || p_item_id,4);
       print_debug('Parameters passed : 10.8: p_organization_id - '    || p_organization_id,4);
       print_debug('Parameters passed : 10.8: p_oe_order_header_id  - '|| p_oe_order_header_id,4);
     END IF;

     l_progress       := '10';

     IF  p_document_type= 'PO' THEN
       l_progress       := '20';

       IF (l_debug = 1) THEN
           print_debug('Entering the document type for PO: ' || l_progress, 4);
       END IF;

       SELECT DISTINCT (pol.item_revision)
       INTO x_revision_code
       FROM po_line_locations poll,po_lines pol
       WHERE pol.po_header_id = p_po_header_id
       AND NVL(poll.po_line_id,-1)     = NVL(p_po_line_id, NVL(poll.po_line_id, -1))
       AND NVL(pol.item_id,-1)         = NVL(p_item_id,NVL(pol.item_id, -1))
       AND poll.ship_to_organization_id= p_organization_id
       AND NVL(poll.po_release_id, -1) = NVL(p_po_release_id, NVL(poll.po_release_id, -1))
       AND pol.po_line_id              = poll.po_line_id
       AND NVL(poll.po_release_id, -1) = NVL(p_po_release_id, NVL(poll.po_release_id, -1))
       AND Nvl(poll.approved_flag,'N') = 'Y'
       AND Nvl(poll.cancel_flag,'N')   = 'N'
       AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING')
       AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED');


     ELSIF p_document_type IN ( 'REQ', 'INTSHIP' ,'ASN') THEN

        l_progress       := '30';

        IF (l_debug = 1) THEN
          print_debug('Entering the document type for REQ/INTSHIP/ASN: ' || l_progress, 4);
        END IF;

        IF p_document_type = 'REQ' THEN

           get_req_shipment_header_id(
              x_shipment_header_id   => l_shipment_header_id
            , x_return_status        => x_return_status
            , x_msg_count            => l_msg_count
            , x_msg_data             => l_msg_data
            , p_organization_id      => p_organization_id
            , p_requiition_header_id => p_req_header_id
            , p_item_id              => p_item_id
            , p_rcv_txn_type         => 'RECEIPT'
            , p_lpn_id               => NULL
            ) ;

        END IF;

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
           IF (l_debug = 1) THEN
              print_debug('ERROR occured while getting Shipment Header ID for REQ' , 4);
           END IF;
           RAISE fnd_api.g_exc_error;
        END IF;

        IF p_document_type = 'INTSHIP' THEN
          BEGIN
            SELECT 'Y'
              INTO l_rcvreq_use_intship
              FROM dual
             WHERE EXISTS ( SELECT 1
                              FROM rcv_shipment_lines
                             WHERE shipment_header_id = l_shipment_header_id
                               AND requisition_line_id IS NOT NULL
                               AND source_document_code = 'REQ'
                           );
           EXCEPTION
             WHEN OTHERS THEN
               l_rcvreq_use_intship := 'N' ;
           END;

           IF l_rcvreq_use_intship = 'Y' THEN
             l_doc_type := 'REQ' ;
           ELSE
             l_doc_type := 'INVENTORY';
           END IF;
        END IF;

        SELECT DISTINCT(rsl.item_revision)
        INTO x_revision_code
        FROM rcv_shipment_lines rsl
        WHERE rsl.shipment_header_id = l_shipment_header_id
        AND rsl.to_organization_id   = p_organization_id
        AND rsl.item_id = NVL(p_item_id,rsl.item_id)
        AND rsl.source_document_code = DECODE (p_document_type, 'INTSHIP', l_doc_type, 'REQ' ,'REQ', 'ASN','PO', 'REQ' )
        AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED');

    ELSIF p_document_type = 'RMA'  THEN
     /* Bug #: 5768262 Adding code for handling RMA to defulting revision on receive through mobile. */
    /* This code will default the revision if RMA contains only one line or more than one line
    /* with the same revision.
    /* This code will be for 11.5.10 only. We are not handling this functionality in 11.5.9 for an RMA
    /* as unable to enter revision for an item on the order line. */
     IF ((inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j) AND
           (inv_rcv_common_apis.g_po_patch_level  >= inv_rcv_common_apis.g_patchset_j_po)) THEN
       l_progress       := '40';

      print_debug('Patchset J code - Defaulting revision for RMA',4);
        IF (l_debug = 1) THEN
            print_debug('Entering the document type for RMA: ' || l_progress, 4);
        END IF;

       SELECT DISTINCT(OEL.item_revision)
       INTO x_revision_code
             FROM
                   OE_ORDER_LINES_all OEL,
                   OE_ORDER_HEADERS_all OEH
             WHERE OEL.LINE_CATEGORY_CODE='RETURN'
               AND OEL.INVENTORY_ITEM_ID = p_item_id
               AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
               AND OEL.HEADER_ID = OEH.HEADER_ID
               AND OEH.HEADER_ID = p_oe_order_header_id
               AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
               AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN';
     END IF;
      /* End of modifications for the Bug #:5768262 */
    END IF;

    IF (l_debug = 1) THEN
     print_debug('Getting the value for revision: ' || x_revision_code, 4);
    END IF;

    l_progress       := '60';

     EXCEPTION

       WHEN NO_DATA_FOUND THEN
         IF (l_debug = 1) THEN
        print_debug('There are no values for revision to be returned ', 4);
         END IF;
         x_revision_code := '' ;
         RETURN;


       WHEN TOO_MANY_ROWS THEN
         IF (l_debug = 1) THEN
        print_debug('There is more than one value for revision to be returned ', 4);
         END IF;
         x_revision_code := '' ;
         RETURN;

       WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_revision_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_revision_code - other exception: ' ||  TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_revision_code');
      END IF;

    END GET_REVISION_CODE;

--End of fix for Bug 4003683


  /**************************************************************************
        As part of the Bug - 2181558, this code is commented out. The process of
        copying the lot attributes from the parent lot to the destination lot is
        carried out in the INV_LOT_API_PUB package.

  PROCEDURE populatelotattributes
    (x_return_status OUT VARCHAR2,
     p_organization_id IN NUMBER,
     p_from_organization_id IN NUMBER,
     p_inventory_item_id IN NUMBER,
     p_lot_number IN VARCHAR2,
     p_exists IN VARCHAR2)
    IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
     IF (l_debug = 1) THEN
        print_debug('Updating the lot number attributes',4);
     END IF;
     UPDATE mtl_lot_numbers
        SET (VENDOR_ID,
         GRADE_CODE,
         ORIGINATION_DATE,
         DATE_CODE,
         STATUS_ID,
         CHANGE_DATE,
         AGE,
         RETEST_DATE,
         MATURITY_DATE,
         LOT_ATTRIBUTE_CATEGORY,
         ITEM_SIZE,
         COLOR,
         VOLUME,
         VOLUME_UOM,
         PLACE_OF_ORIGIN,
         BEST_BY_DATE,
         LENGTH,
         LENGTH_UOM,
         RECYCLED_CONTENT,
         THICKNESS,
         THICKNESS_UOM,
         WIDTH,
         WIDTH_UOM,
         CURL_WRINKLE_FOLD,
         C_ATTRIBUTE1,
         C_ATTRIBUTE2,
         C_ATTRIBUTE3,
         C_ATTRIBUTE4,
         C_ATTRIBUTE5,
         C_ATTRIBUTE6,
         C_ATTRIBUTE7,
         C_ATTRIBUTE8,
         C_ATTRIBUTE9,
         C_ATTRIBUTE10,
         C_ATTRIBUTE11,
         C_ATTRIBUTE12,
         C_ATTRIBUTE13,
         C_ATTRIBUTE14,
         C_ATTRIBUTE15,
         C_ATTRIBUTE16,
         C_ATTRIBUTE17,
         C_ATTRIBUTE18,
         C_ATTRIBUTE19,
         C_ATTRIBUTE20,
         D_ATTRIBUTE1,
         D_ATTRIBUTE2,
         D_ATTRIBUTE3,
         D_ATTRIBUTE4,
         D_ATTRIBUTE5,
         D_ATTRIBUTE6,
         D_ATTRIBUTE7,
         D_ATTRIBUTE8,
         D_ATTRIBUTE9,
         D_ATTRIBUTE10,
         N_ATTRIBUTE1,
         N_ATTRIBUTE2,
         N_ATTRIBUTE3,
         N_ATTRIBUTE4,
         N_ATTRIBUTE5,
         N_ATTRIBUTE6,
         N_ATTRIBUTE7,
         N_ATTRIBUTE8,
         N_ATTRIBUTE10,
         SUPPLIER_LOT_NUMBER,
         N_ATTRIBUTE9,
         TERRITORY_CODE,
         vendor_name,
         attribute_category,
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15
       ) =
       (SELECT VENDOR_ID,
           GRADE_CODE,
           ORIGINATION_DATE,
           DATE_CODE,
           STATUS_ID,
           CHANGE_DATE,
           AGE,
           RETEST_DATE,
           MATURITY_DATE,
           LOT_ATTRIBUTE_CATEGORY,
           ITEM_SIZE,
           COLOR,
           VOLUME,
           VOLUME_UOM,
           PLACE_OF_ORIGIN,
           BEST_BY_DATE,
           LENGTH,
           LENGTH_UOM,
           RECYCLED_CONTENT,
           THICKNESS,
           THICKNESS_UOM,
           WIDTH,
           WIDTH_UOM,
           CURL_WRINKLE_FOLD,
           C_ATTRIBUTE1,
           C_ATTRIBUTE2,
           C_ATTRIBUTE3,
           C_ATTRIBUTE4,
           C_ATTRIBUTE5,
           C_ATTRIBUTE6,
           C_ATTRIBUTE7,
           C_ATTRIBUTE8,
           C_ATTRIBUTE9,
           C_ATTRIBUTE10,
           C_ATTRIBUTE11,
           C_ATTRIBUTE12,
           C_ATTRIBUTE13,
           C_ATTRIBUTE14,
           C_ATTRIBUTE15,
           C_ATTRIBUTE16,
           C_ATTRIBUTE17,
           C_ATTRIBUTE18,
           C_ATTRIBUTE19,
           C_ATTRIBUTE20,
           D_ATTRIBUTE1,
           D_ATTRIBUTE2,
           D_ATTRIBUTE3,
           D_ATTRIBUTE4,
           D_ATTRIBUTE5,
           D_ATTRIBUTE6,
           D_ATTRIBUTE7,
           D_ATTRIBUTE8,
           D_ATTRIBUTE9,
           D_ATTRIBUTE10,
           N_ATTRIBUTE1,
           N_ATTRIBUTE2,
           N_ATTRIBUTE3,
           N_ATTRIBUTE4,
           N_ATTRIBUTE5,
           N_ATTRIBUTE6,
           N_ATTRIBUTE7,
           N_ATTRIBUTE8,
           N_ATTRIBUTE10,
           SUPPLIER_LOT_NUMBER,
           N_ATTRIBUTE9,
           TERRITORY_CODE,
           vendor_name,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
          FROM mtl_lot_numbers
         WHERE organization_id = p_from_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number)
       WHERE organization_id = p_organization_id
         AND inventory_item_id = p_inventory_item_id
         AND lot_number = p_lot_number;
  EXCEPTION
     WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF SQLCODE IS NOT NULL THEN
       inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_sub_code', '10', SQLCODE);
        END IF;
        IF (l_debug = 1) THEN
           print_debug('Exitting populatelotattributes - other exception:'|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
        END IF;
        --
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
                , 'populatelotattributes'
                );
        END IF;

  END populatelotattributes;
  ******************************************************************************************/

  -- This is a wrapper to call inventory INV_LOT_API_PUB.insertLot
  -- it stores the inserted lot info in a global variable for
  -- transaction exception rollback
  PROCEDURE insert_dynamic_lot(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_lot_number               IN            VARCHAR2
  , p_expiration_date          IN OUT NOCOPY DATE
  , p_transaction_temp_id      IN            NUMBER DEFAULT NULL
  , p_transaction_action_id    IN            NUMBER DEFAULT NULL
  , p_transfer_organization_id IN            NUMBER DEFAULT NULL
  , p_status_id                IN            NUMBER
  , p_update_status            IN            VARCHAR2 := 'FALSE'
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_parent_lot_number        IN            VARCHAR2  DEFAULT NULL -- bug 10176719 - inserting parent lot number
  ) IS
    l_exists VARCHAR2(7)  := 'FALSE';
    v_temp   VARCHAR2(50);
    l_debug  NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_stacked_messages VARCHAR2(1000);
    l_status_id NUMBER; --Added bug3853202
    l_status_enabled VARCHAR2(1); --Added bug3998321
    l_dest_status_enabled VARCHAR2(1);  --Added bug4035918
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Inside insert_dynamic_lot', 4);
    END IF;

    IF inv_lot_api_pub.validate_unique_lot(
         p_org_id                     => p_organization_id
       , p_inventory_item_id          => p_inventory_item_id
       , p_lot_uniqueness             => NULL
       , p_auto_lot_number            => p_lot_number
       ) THEN
        /*Added select for bug 3853202*/

        IF  p_transfer_organization_id IS NOT NULL THEN
      BEGIN
	SELECT STATUS_ID
	  INTO l_status_id
	FROM MTL_LOT_NUMBERS
	WHERE LOT_NUMBER = p_lot_number
	  AND ORGANIZATION_ID = p_transfer_organization_id
	  AND INVENTORY_ITEM_ID = p_inventory_item_id;

	SELECT lot_status_enabled  --Added select for bug3998321
	INTO l_status_enabled
	FROM
	mtl_system_items
	WHERE
	inventory_item_id=p_inventory_item_id and
	organization_id=p_transfer_organization_id;

	SELECT lot_status_enabled  --Added select for bug4035918
	INTO l_dest_status_enabled
	FROM
	mtl_system_items
	WHERE
	inventory_item_id=p_inventory_item_id and
	organization_id=p_organization_id;

        SELECT 'TRUE'
          INTO l_exists
          FROM mtl_lot_numbers
         WHERE lot_number = p_lot_number
           AND organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exists  := 'FALSE';
      END;
     ELSE
	l_exists := 'FALSE';
     END IF;

      IF l_status_id IS NULL THEN  --Added bug 3853202
	l_status_id := p_status_id;
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Lot uniqueness passed so inserting lot:' || l_exists, 4);
      END IF;

      inv_lot_api_pub.insertlot(
        p_api_version                => p_api_version
      , p_init_msg_list              => p_init_msg_list
      , p_commit                     => p_commit
      , p_validation_level           => p_validation_level
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_lot_number                 => p_lot_number
      , p_expiration_date            => p_expiration_date
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_transaction_action_id      => p_transaction_action_id
      , p_transfer_organization_id   => p_transfer_organization_id
      , x_object_id                  => x_object_id
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
	  , p_parent_lot_number          => p_parent_lot_number --bug 10176719 - inserting parent lot number
				);
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	 inv_mobile_helper_functions.get_stacked_messages(l_stacked_messages);
	 IF (l_debug = 1) THEN
	    print_debug('The following messege is removed: ' ||
			l_stacked_messages,1);
	 END IF;
	 x_msg_count := 0;
	 x_msg_data := NULL;
      END IF;

    /**************************************************************************
     As part of the Bug - 2181558, this code is commented out. The process of
     copying the lot attributes from the parent lot to the destination lot is
     carried out in the INV_LOT_API_PUB package.

       -- bug 2180480
       IF p_transfer_organization_id IS NOT NULL  AND
          l_exists = 'FALSE' THEN
           -- Can come here from the receiving UI only if it is an
           -- intransit shipment receipt or an internal req. receipt
           -- for a new lot number
           populatelotattributes(x_return_status => x_return_status,
                         p_lot_number => p_lot_number,
                         p_organization_id => p_organization_id,
                         p_from_organization_id => p_transfer_organization_id,
                         p_inventory_item_id => p_inventory_item_id,
                         p_exists => l_exists);
       END IF;
    ***************************************************************************/
    ELSE
      IF (l_debug = 1) THEN
        print_debug('Lot uniqueness did not pass so not inserting lot', 4);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('INV', 'LOT_UNIQUENESS_VIOLATED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
      RETURN;
    END IF;

    IF (((x_return_status = fnd_api.g_ret_sts_success)
        AND(p_update_status = 'TRUE'))
        OR (p_transfer_organization_id IS NOT NULL  AND
          l_exists = 'FALSE' AND l_status_enabled = 'Y' AND l_dest_status_enabled = 'Y')) THEN  --Added OR condition for bug 3853202, Added l_status_enabled bug3998321
	  --Added l_dest_status_enabled = 'Y' bug4035918
      inv_material_status_grp.update_status(
        p_api_version_number         => p_api_version
      , p_init_msg_lst               => NULL
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_update_method              => inv_material_status_pub.g_update_method_receive
      , p_status_id                  => l_status_id --Changed from p_status_id bug3853202
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_sub_code                   => NULL
      , p_locator_id                 => NULL
      , p_lot_number                 => p_lot_number
      , p_serial_number              => NULL
      , p_to_serial_number           => NULL
      , p_object_type                => 'O'
      );
    END IF;
  END insert_dynamic_lot;

  -- This is a wrapper to call inventory insert_range_serial
  PROCEDURE insert_range_serial(
    p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 := fnd_api.g_false
  , p_commit                IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level      IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id     IN            NUMBER
  , p_organization_id       IN            NUMBER
  , p_from_serial_number    IN            VARCHAR2
  , p_to_serial_number      IN            VARCHAR2
  , p_revision              IN            VARCHAR2
  , p_lot_number            IN            VARCHAR2
  , p_primary_lot_quantity  IN            NUMBER
  , p_transaction_action_id IN            NUMBER
  , p_current_status        IN            NUMBER
  , p_serial_status_id      IN            NUMBER
  , p_update_serial_status  IN            VARCHAR2
  , p_inspection_required   IN            NUMBER DEFAULT NULL
  , p_hdr_id                IN            NUMBER
  , p_from_lpn_id           IN            NUMBER
  , p_to_lpn_id             IN            NUMBER
  , p_primary_uom_code      IN            VARCHAR2
  , p_call_pack_unpack      IN            VARCHAR2
  , x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_subinventory          IN            VARCHAR2 DEFAULT NULL
  , p_locator_id            IN            NUMBER DEFAULT NULL
  ) IS
    l_object_id                  NUMBER;
    l_success                    NUMBER;
    l_temp_var                   NUMBER;
    l_progress                   VARCHAR2(10);
    l_serial_packed_in_other_lpn NUMBER;
    l_debug                      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_inv_po_j_higher            BOOLEAN := FALSE;
    l_rcv_serial_flag            VARCHAR2(1) := 'N';
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter insert_range_serial: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '10';
    SAVEPOINT rcv_insert_range_serial_sp;

    -- Reported by Toshiba Issue where same Serials were getting processed
    -- Sanity Check to ensure if the Serials are not Yet Received/Packed into a different
    -- LPN i,e other than the Transaction LPN.
    -- LPN context 7 is added for receioving ASN's
    -- Added inventory_item_id check in the below sql because same serial might exist
    -- for two diff items.
    /* FP-J Lot/Serial Support Enhancement -  Check for status of Resides in Receiving (7) also */
    SELECT COUNT(1)
      INTO l_serial_packed_in_other_lpn
      FROM mtl_serial_numbers msn
     WHERE msn.current_status IN (5, 7)
       AND EXISTS(SELECT 'x'
                    FROM wms_license_plate_numbers wlpn
                   WHERE wlpn.lpn_context NOT IN(5, 6, 7)
                     AND wlpn.lpn_id = msn.lpn_id)
       AND msn.lpn_id IS NOT NULL
       AND msn.serial_number BETWEEN p_from_serial_number AND p_to_serial_number
       AND Length(msn.serial_number) = Length(p_from_serial_number)
       AND Length(p_from_serial_number) = Length(Nvl(p_to_serial_number,p_from_serial_number))
       AND msn.inventory_item_id = p_inventory_item_id
       AND ROWNUM = 1;

    IF l_serial_packed_in_other_lpn >= 1 THEN
      IF (l_debug = 1) THEN
        print_debug('Insert_range_serial: Serial Number already Packed/Received  with a Diff LPN '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      fnd_message.set_name('INV', 'INV_DUPLICATE_SERIAL');
      fnd_msg_pub.ADD;
      fnd_message.set_name('INV', 'INV_FAIL_VALIDATE_SERIAL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '20';

    /* FP-J Lot/Serial Support Enhancement -
     * Get the patch levels for INV and PO. If they are J or higher, we do not
     * want to update certain columns like lpn_id, inspection_status,
     * subinventory, locator etc. for the serial number.
     * So have declared a new flag p_rcv_serial_flag which should be passed as Y
     * to skip the updates to the serial
     * If either INV or PO J is not installed, then this flag would be set to
     * the value 'N' so that the updates continue as usual.
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
      l_inv_po_j_higher := FALSE;
      l_rcv_serial_flag := 'N';
    ELSE
      l_inv_po_j_higher := TRUE;
      l_rcv_serial_flag := 'Y';
    END IF;

    inv_serial_number_pub.insert_range_serial(
      p_api_version                => p_api_version
    , p_init_msg_list              => p_init_msg_list
    , p_commit                     => p_commit
    , p_validation_level           => p_validation_level
    , p_inventory_item_id          => p_inventory_item_id
    , p_organization_id            => p_organization_id
    , p_from_serial_number         => p_from_serial_number
    , p_to_serial_number           => p_to_serial_number
    , p_initialization_date        => SYSDATE
    , p_completion_date            => NULL
    , p_ship_date                  => NULL
    , p_revision                   => p_revision
    , p_lot_number                 => p_lot_number
    , p_current_locator_id         => NULL
    , p_subinventory_code          => NULL
    , p_trx_src_id                 => NULL
    , p_unit_vendor_id             => NULL
    , p_vendor_lot_number          => NULL
    , p_vendor_serial_number       => NULL
    , p_receipt_issue_type         => NULL
    , p_txn_src_id                 => NULL
    , p_txn_src_name               => NULL
    , p_txn_src_type_id            => NULL
    , p_transaction_id             => NULL
    , p_current_status             => p_current_status
    , p_parent_item_id             => NULL
    , p_parent_serial_number       => NULL
    , p_cost_group_id              => NULL
    , p_transaction_action_id      => p_transaction_action_id
    , p_transaction_temp_id        => NULL
    , p_status_id                  => NULL
    , p_inspection_status          => p_inspection_required
    , x_object_id                  => l_object_id
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_rcv_serial_flag            => l_rcv_serial_flag
    );

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_LOT_COMMIT_FAILURE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '30';

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    /* FP-J Lot/Serial Support Enhancement
     * If INV and PO patchset levels are "J" or higher, then do not call packunpact
     * from UI since it would be handled by the receiving TM.
     * Similarly, need not mark the serials since it would be done in the insert_msni
     * API upon creating the MSNI interface records
     */
    IF (l_inv_po_j_higher = FALSE) THEN

      IF p_update_serial_status = 'TRUE' THEN
        l_progress  := '40';
        inv_material_status_grp.update_status(
          p_api_version_number         => p_api_version
        , p_init_msg_lst               => NULL
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_update_method              => inv_material_status_pub.g_update_method_receive
        , p_status_id                  => p_serial_status_id
        , p_organization_id            => p_organization_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_sub_code                   => NULL
        , p_locator_id                 => NULL
        , p_lot_number                 => p_lot_number
        , p_serial_number              => p_from_serial_number
        , p_to_serial_number           => p_to_serial_number
        , p_object_type                => 'S'
        );
      END IF;

      l_progress       := '50';
      serial_check.inv_mark_serial(
        from_serial_number           => p_from_serial_number
      , to_serial_number             => p_to_serial_number
      , item_id                      => p_inventory_item_id
      , org_id                       => p_organization_id
      , hdr_id                       => p_hdr_id
      , temp_id                      => NULL
      , lot_temp_id                  => NULL
      , success                      => l_success
      );
      l_progress       := '60';

      IF p_call_pack_unpack = 'TRUE' THEN
        l_progress  := '70';
        inv_rcv_std_rcpt_apis.packunpack_container(
          p_api_version                => p_api_version
        , p_init_msg_list              => p_init_msg_list
        , p_commit                     => p_commit
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_from_lpn_id                => p_from_lpn_id
        , p_lpn_id                     => p_to_lpn_id
        , p_content_item_id            => p_inventory_item_id
        , p_revision                   => p_revision
        , p_lot_number                 => p_lot_number
        , p_from_serial_number         => p_from_serial_number
        , p_to_serial_number           => p_to_serial_number
        , p_uom                        => p_primary_uom_code
        , p_quantity                   => p_primary_lot_quantity
        , p_organization_id            => p_organization_id
        , p_subinventory               => p_subinventory
        , p_locator_id                 => p_locator_id
        , p_operation                  => '1'
        );
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      print_debug('insert_range_serial: INV and PO patchset levels are J or higher. No packunpack from UI. No marking from here', 4);
    END IF;   --END IF check INV and PO patch levels

    l_progress       := '80';

    IF (l_debug = 1) THEN
      print_debug('Exit insert_range_serial 90:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_insert_range_serial_sp;
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_range_serial - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_insert_range_serial_sp;

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_range_serial - unexpected error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_insert_range_serial_sp;

      IF (l_debug = 1) THEN
        print_debug('Exitting insert_range_serial - other exceptions:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.insert_range_serial', l_progress, SQLCODE);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'insert_range_serial');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE update_serial_status(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false
  , p_commit               IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level     IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id    IN            NUMBER
  , p_organization_id      IN            NUMBER
  , p_from_serial_number   IN            VARCHAR2
  , p_to_serial_number     IN            VARCHAR2
  , p_current_status       IN            NUMBER
  , p_serial_status_id     IN            NUMBER
  , p_update_serial_status IN            VARCHAR2
  , p_lot_number           IN            VARCHAR2
  , p_primary_lot_quantity IN            NUMBER
  , p_inspection_required  IN            NUMBER
  , p_hdr_id               IN            NUMBER
  , p_from_lpn_id          IN            NUMBER
  , p_to_lpn_id            IN            NUMBER
  , p_revision             IN            VARCHAR2
  , p_primary_uom_code     IN            VARCHAR2
  , p_call_pack_unpack     IN            VARCHAR2
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_subinventory         IN            VARCHAR2 DEFAULT NULL
  , p_locator_id           IN            NUMBER DEFAULT NULL
  , p_txn_src_id           IN            VARCHAR2 DEFAULT NULL
  ) IS
    l_from_ser_number     NUMBER;
    l_to_ser_number       NUMBER;
    l_range_numbers       NUMBER;
    l_temp_prefix         VARCHAR2(30);
    l_cur_serial_number   VARCHAR2(30);
    l_cur_ser_number      NUMBER;
    l_success             NUMBER;
    l_serial_num_length   NUMBER;
    l_prefix_length       NUMBER;
    l_num_suffix          VARCHAR2(30);
    l_progress            VARCHAR2(10);
    l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_restrict_rcpt_ser   VARCHAR2(1)  := NVL(fnd_profile.VALUE('INV_RESTRICT_RCPT_SER'), '0');
    l_serial_control_code VARCHAR2(10);
    l_txn_cnt             VARCHAR2(10);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter update_serial_status: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress           := '10';
    x_return_status      := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_update_serial_sp;
    l_progress           := '20';

    --
    -- For RMA's and Serial Control at SALES ORDER ISSUE don't allow the same Serial to be re-received
    -- when the serial status is 1 and it is already received once
    -- Similar Bug 2685220
    --

    IF (p_txn_src_id = '12'
        AND l_restrict_rcpt_ser = '1') THEN
      IF (l_debug = 1) THEN
        print_debug('Update Serial Status : RMA and restrict rcpt ser is Set', 1);
      END IF;

      get_serial_ctrl(x_return_status, l_serial_control_code, p_organization_id, p_inventory_item_id);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF (l_debug = 1) THEN
          print_debug('Update Serial Status : Failed in getting serial control code ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
        END IF;

        fnd_message.set_name('INV', 'INV_FAIL_VALIDATE_SERIAL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_serial_control_code = '6' THEN
        IF (l_debug = 1) THEN
          print_debug('Update Serial Status : Before Duplicate Serial Check , RMA and Serial Ctrl as SALES ISSUE', 1);
        END IF;

        BEGIN
          SELECT '1'
            INTO l_txn_cnt
            FROM DUAL
           WHERE EXISTS(
                   SELECT '1'
                     FROM mtl_serial_numbers
                    WHERE inventory_item_id = p_inventory_item_id
                      AND current_organization_id = p_organization_id
                      AND current_status = 1
                      AND serial_number BETWEEN p_from_serial_number AND p_to_serial_number
		      AND Length(serial_number) = Length(p_from_serial_number)
		      AND Length(p_from_serial_number) = Length(Nvl(p_to_serial_number, p_from_serial_number))
                      AND last_txn_source_type_id = 12);

          IF l_txn_cnt > 0 THEN
            IF (l_debug = 1) THEN
              print_debug('Update_serial_status: After Duplicate Serial Check , RMA and Serial Ctrl as SALES ISSUE Failed Here', 1);
            END IF;

            fnd_message.set_name('INV', 'INV_FAIL_VALIDATE_SERIAL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      END IF;
    END IF;

    -- get the number part of the to serial
    inv_validate.number_from_sequence(p_to_serial_number, l_temp_prefix, l_to_ser_number);
    l_progress           := '30';
    -- get the number part of the from serial
    inv_validate.number_from_sequence(p_from_serial_number, l_temp_prefix, l_from_ser_number);
    l_progress           := '40';
    -- total number of serials inserted into mtl_serial_numbers
    l_range_numbers      := l_to_ser_number - l_from_ser_number + 1;
    l_serial_num_length  := LENGTH(p_from_serial_number);
    l_prefix_length      := LENGTH(l_temp_prefix);

    FOR i IN 1 .. l_range_numbers LOOP
      l_cur_ser_number     := l_from_ser_number + i - 1;
      -- concatenate the serial number to be inserted
      l_cur_serial_number  := l_temp_prefix || LPAD(l_cur_ser_number, l_serial_num_length - NVL(l_prefix_length, 0), '0');
      l_progress           := '50';

      /* FP-J Lot/Serial Support Enhancement
       * If INV and PO patchset levels are "J" or higher, then do not call update statis
       * from UI since it would be handled by the receiving TM.
       */
      IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
          (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
        UPDATE mtl_serial_numbers
           SET previous_status = current_status
             , current_status = p_current_status
             , inspection_status = p_inspection_required
             , lot_number = p_lot_number
             , revision = p_revision
             , current_organization_id = p_organization_id
        WHERE serial_number = l_cur_serial_number
        AND inventory_item_id = p_inventory_item_id;
      ELSE
        print_debug('update_serial_status: INV and PO patchset levels are J or higher.', 4);
        print_debug('update_serial_status: Updating revision lot_number if serial code of the item is predefined and current status is defined but not used', 4);
        UPDATE mtl_serial_numbers
           SET lot_number = p_lot_number
             , revision = p_revision
        WHERE serial_number = l_cur_serial_number
        AND inventory_item_id = p_inventory_item_id
        AND current_status IN (1, 4, 5, 6);
      END IF;   --END IF check INV and PO patch levels

      l_progress           := '60';

      IF p_update_serial_status = 'TRUE' THEN
        l_progress  := '70';
        inv_material_status_grp.update_status(
          p_api_version_number         => p_api_version
        , p_init_msg_lst               => NULL
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_update_method              => inv_material_status_pub.g_update_method_receive
        , p_status_id                  => p_serial_status_id
        , p_organization_id            => p_organization_id
        , p_inventory_item_id          => p_inventory_item_id
        , p_sub_code                   => NULL
        , p_locator_id                 => NULL
        , p_lot_number                 => p_lot_number
        , p_serial_number              => l_cur_serial_number
        , p_to_serial_number           => NULL
        , p_object_type                => 'S'
        );
      END IF;

      l_progress           := '80';

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    l_progress           := '90';

    /* FP-J Lot/Serial Support Enhancement
     * If INV and PO patchset levels are "J" or higher, then do not call packunpact
     * from UI since it would be handled by the receiving TM.
     * Similarly, need not mark the serials since it would be done in the insert_msni
     * API upon creating the MSNI interface records
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
      serial_check.inv_mark_serial(
        from_serial_number           => p_from_serial_number
      , to_serial_number             => p_to_serial_number
      , item_id                      => p_inventory_item_id
      , org_id                       => p_organization_id
      , hdr_id                       => p_hdr_id
      , temp_id                      => NULL
      , lot_temp_id                  => NULL
      , success                      => l_success
      );
      l_progress           := '100';

      IF p_call_pack_unpack = 'TRUE' THEN
        l_progress  := '110';
        inv_rcv_std_rcpt_apis.packunpack_container(
          p_api_version                => p_api_version
        , p_init_msg_list              => p_init_msg_list
        , p_commit                     => p_commit
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_from_lpn_id                => p_from_lpn_id
        , p_lpn_id                     => p_to_lpn_id
        , p_content_item_id            => p_inventory_item_id
        , p_revision                   => p_revision
        , p_lot_number                 => p_lot_number
        , p_from_serial_number         => p_from_serial_number
        , p_to_serial_number           => p_to_serial_number
        , p_uom                        => p_primary_uom_code
        , p_quantity                   => p_primary_lot_quantity
        , p_organization_id            => p_organization_id
        , p_subinventory               => p_subinventory
        , p_locator_id                 => p_locator_id
        , p_operation                  => '1'
        );
      END IF;

      l_progress           := '120';

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      print_debug('update_serial_status: INV and PO patchset levels are J or higher. No packunpack from UI. No marking from here', 4);
    END IF;   --END IF check INV and PO patch levels

    l_progress           := '130';

    IF (l_debug = 1) THEN
      print_debug('Exit update_serial_status 140:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_update_serial_sp;
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting update_serial_status - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_update_serial_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting update_serial_status - unexpected error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_update_serial_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting update_serial_status - other exceptions:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.update_serial_status', l_progress, SQLCODE);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'update_serial_status');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END update_serial_status;

  PROCEDURE process_lot(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false
  , p_commit                   IN            VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN            NUMBER := fnd_api.g_valid_level_full
  , p_inventory_item_id        IN            NUMBER
  , p_organization_id          IN            NUMBER
  , p_lot_number               IN            VARCHAR2
  , p_expiration_date          IN OUT NOCOPY DATE
  , p_transaction_temp_id      IN            NUMBER DEFAULT NULL
  , p_transaction_action_id    IN            NUMBER DEFAULT NULL
  , p_transfer_organization_id IN            NUMBER DEFAULT NULL
  , p_status_id                IN            NUMBER
  , p_update_status            IN            VARCHAR2 := 'FALSE'
  , p_is_new_lot               IN            VARCHAR2 := 'TRUE'
  , p_call_pack_unpack         IN            VARCHAR2 := 'FALSE'
  , p_from_lpn_id              IN            NUMBER
  , p_to_lpn_id                IN            NUMBER
  , p_revision                 IN            VARCHAR2
  , p_lot_primary_qty          IN            NUMBER
  , p_primary_uom_code         IN            VARCHAR2
  , p_transaction_uom_code     IN            VARCHAR2 DEFAULT NULL
  , x_object_id                OUT NOCOPY    NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_subinventory             IN            VARCHAR2 DEFAULT NULL
  , p_locator_id               IN            NUMBER DEFAULT NULL
  , p_lot_secondary_qty        IN            NUMBER --OPM Convergence
  , p_secondary_uom_code       IN            VARCHAR2 --OPM Convergence
  , p_parent_lot_number        IN            VARCHAR2 DEFAULT NULL    --bug 10176719 - inserting parent lot number
  ) IS
    l_progress VARCHAR2(10);
    l_debug    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Enter process_lot: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug('Organization ID = ' || TO_CHAR(p_organization_id), 1);
      print_debug('To Organization ID = ' || TO_CHAR(p_transfer_organization_id), 1);
      print_debug('transaction_temp_id = ' || TO_CHAR(p_transaction_temp_id), 1);
      print_debug('Lot Number = ' || p_lot_number, 1);
      print_debug('Item ID = ' || TO_CHAR(p_inventory_item_id), 1);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '10';
    SAVEPOINT rcv_process_lot_sp;
    inv_rcv_std_rcpt_apis.populate_lot_rec(
      p_lot_number                 => p_lot_number
    , p_primary_qty                => p_lot_primary_qty
    , p_txn_uom_code               => p_transaction_uom_code
    , p_org_id                     => p_organization_id
    , p_item_id                    => p_inventory_item_id
    , p_secondary_quantity         => p_lot_secondary_qty --OPM Convergence
    );
    l_progress       := '20';

    IF p_is_new_lot = 'TRUE' THEN
      l_progress  := '30';
      insert_dynamic_lot(
        p_api_version                => p_api_version
      , p_init_msg_list              => p_init_msg_list
      , p_commit                     => p_commit
      , p_validation_level           => p_validation_level
      , p_inventory_item_id          => p_inventory_item_id
      , p_organization_id            => p_organization_id
      , p_lot_number                 => p_lot_number
      , p_expiration_date            => p_expiration_date
      , p_transaction_temp_id        => p_transaction_temp_id
      , p_transaction_action_id      => p_transaction_action_id
      , p_transfer_organization_id   => p_transfer_organization_id
      , p_status_id                  => p_status_id
      , p_update_status              => p_update_status
      , x_object_id                  => x_object_id
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
	  , p_parent_lot_number          => p_parent_lot_number  -- bug 10176719 - inserting parent lot number
      );
    END IF;

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_LOT_COMMIT_FAILURE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '40';

    /* FP-J Lot/Serial Support Enhancement
     * If INV and PO patchset levels are "J" or higher, then do not call packunpact
     * from UI since it would be handled by the receiving TM.
     */
    IF ((inv_rcv_common_apis.g_inv_patch_level < inv_rcv_common_apis.g_patchset_j) OR
        (inv_rcv_common_apis.g_po_patch_level < inv_rcv_common_apis.g_patchset_j_po)) THEN
      IF p_call_pack_unpack = 'TRUE' THEN
        l_progress  := '50';
        inv_rcv_std_rcpt_apis.packunpack_container(
          p_api_version                => p_api_version
        , p_init_msg_list              => p_init_msg_list
        , p_commit                     => p_commit
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , p_from_lpn_id                => p_from_lpn_id
        , p_lpn_id                     => p_to_lpn_id
        , p_content_item_id            => p_inventory_item_id
        , p_revision                   => p_revision
        , p_lot_number                 => p_lot_number
        , p_quantity                   => p_lot_primary_qty
        , p_uom                        => p_primary_uom_code
        , p_organization_id            => p_organization_id
        , p_subinventory               => p_subinventory
        , p_locator_id                 => p_locator_id
        , p_operation                  => '1'
        );
      END IF;
    ELSE
      print_debug('process_lot: INV and PO patchset levels are J or higher. No packunpack from UI. ', 4);
    END IF;   --END IF check INV and PO patch levels

    l_progress       := '60';

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('WMS', 'WMS_PACK_CONTAINER_FAIL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Exit process_lot 70:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_process_lot_sp;
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting process_lot - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_process_lot_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting process_lot - unexpected error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_process_lot_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting process_lot - other exceptions:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.process_lot', l_progress, SQLCODE);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'process_lot');
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
  END process_lot;

  PROCEDURE gen_txn_group_id IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF g_rcv_global_var.interface_group_id IS NULL THEN
      SELECT rcv_interface_groups_s.NEXTVAL
        INTO g_rcv_global_var.interface_group_id
        FROM DUAL;
    END IF;
  END gen_txn_group_id;

  PROCEDURE validate_trx_date(
    p_trx_date        IN            DATE
  , p_organization_id IN            NUMBER
  , p_sob_id          IN            NUMBER
  , x_return_status   OUT NOCOPY    VARCHAR2
  , x_error_code      OUT NOCOPY    VARCHAR2
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (p_trx_date > SYSDATE) THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_message.set_name('PO', 'RCV_TRX_FUTURE_DATE_NA');
      fnd_msg_pub.ADD;
      RETURN;
    END IF;

    BEGIN
      IF NOT(po_dates_s.val_open_period(p_trx_date, p_sob_id, 'SQLGL', p_organization_id)) THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('PO', 'PO_PO_ENTER_OPEN_GL_DATE');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;

      IF NOT(po_dates_s.val_open_period(p_trx_date, p_sob_id, 'PO', p_organization_id)) THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('PO', 'PO_PO_ENTER_OPEN_GL_DATE');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_error;

        IF SQLCODE IS NOT NULL THEN
          inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.validate_trx_date', '10', SQLCODE);
        END IF;

        fnd_message.set_name('PO', 'PO_PO_ENTER_OPEN_GL_DATE');
        fnd_msg_pub.ADD;
        RETURN;
    END;

    BEGIN
      IF NOT(po_dates_s.val_open_period(p_trx_date, p_sob_id, 'INV', p_organization_id)) THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        fnd_message.set_name('PO', 'PO_INV_NO_OPEN_PERIOD');
        fnd_msg_pub.ADD;
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_error;

        IF SQLCODE IS NOT NULL THEN
          inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.validate_trx_date', '20', SQLCODE);
        END IF;

        fnd_message.set_name('PO', 'PO_INV_NO_OPEN_PERIOD');
        fnd_msg_pub.ADD;
        RETURN;
    END;
  END validate_trx_date;

  -- Bug 2086271
  PROCEDURE get_req_shipment_header_id(
    x_shipment_header_id   OUT NOCOPY    NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_organization_id      IN            NUMBER
  , p_requiition_header_id IN            NUMBER
  , p_item_id              IN            NUMBER
  , p_rcv_txn_type         IN            VARCHAR2
  , p_lpn_id               IN            NUMBER DEFAULT NULL
  ) IS
    l_from_org_id NUMBER;
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    get_req_shipment_header_id(
      x_shipment_header_id         => x_shipment_header_id
    , x_from_org_id                => l_from_org_id
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_organization_id            => p_organization_id
    , p_requiition_header_id       => p_requiition_header_id
    , p_item_id                    => p_item_id
    , p_rcv_txn_type               => p_rcv_txn_type
    , p_lpn_id                     => p_lpn_id
    );
  END get_req_shipment_header_id;

  PROCEDURE get_req_shipment_header_id(
    x_shipment_header_id   OUT NOCOPY    NUMBER
  , x_from_org_id          OUT NOCOPY    NUMBER
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  , p_organization_id      IN            NUMBER
  , p_requiition_header_id IN            NUMBER
  , p_item_id              IN            NUMBER
  , p_rcv_txn_type         IN            VARCHAR2
  , p_lpn_id               IN            NUMBER DEFAULT NULL
  ) IS
    l_return_status VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(400);
    l_progress      VARCHAR2(10);
    l_debug         NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      print_debug('Enter get_req_shipment_header_id 10  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;

    l_progress       := '10';

    IF p_rcv_txn_type = 'RCVTXN' THEN
      l_progress  := '20';

      BEGIN
        SELECT DISTINCT rsl.shipment_header_id
                      , rsl.from_organization_id
                   INTO x_shipment_header_id
                      , x_from_org_id
                   FROM rcv_shipment_lines rsl
                  WHERE item_id = p_item_id
                    AND to_organization_id = p_organization_id
                    AND EXISTS(
                         SELECT 1
                           FROM po_requisition_lines prl, rcv_transactions rt, rcv_supply rs
                          WHERE prl.requisition_header_id = p_requiition_header_id
                            AND rsl.requisition_line_id = prl.requisition_line_id
                            AND prl.item_id = p_item_id
                            AND prl.source_type_code = 'INVENTORY'
                            AND rs.req_line_id = prl.requisition_line_id
                            AND rs.rcv_transaction_id = rt.transaction_id
                            AND rt.transaction_type <> 'UNORDERED'
                            AND rs.quantity > 0
                            AND rs.supply_type_code = 'RECEIVING'
                            AND rs.to_organization_id = p_organization_id
                            AND rt.organization_id = p_organization_id
                            AND(
                                EXISTS(
                                  SELECT 1
                                    FROM rcv_transactions rt1
                                   WHERE rt1.transaction_id = rt.transaction_id
                                     AND rt1.inspection_status_code <> 'NOT INSPECTED'
                                     AND rt1.routing_header_id = 2)
                                OR rt.routing_header_id <> 2
                                OR rt.routing_header_id IS NULL
                               ));
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          fnd_message.set_name('INV', 'INV_RCV_REQ_SHIP_MISMATCH');
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'get_req_shipment_header_id 20 - returns more than one shipment header ID for RCVTXN  '
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 1
            );
          END IF;

          RAISE fnd_api.g_exc_error;
      END;

      l_progress  := '30';
    ELSIF p_rcv_txn_type = 'RECEIPT' THEN
      l_progress  := '40';

      IF (p_item_id IS NULL
          AND p_lpn_id IS NOT NULL) THEN -- through reqexp.

        /*
            Change the below code to cater to Empty LPN scenario,
            With Nested LPNs the given LPN may be empty but not its child LPNs.
        */

        BEGIN
          /* Bug 3440456 */
          -- For performance reason this is being as replaced as below.
          /*
          SELECT DISTINCT rsl.shipment_header_id
                        , rsl.from_organization_id
                     INTO x_shipment_header_id
                        , x_from_org_id
                     FROM rcv_shipment_lines rsl, wms_lpn_contents wlc,wms_license_plate_numbers wln
                    WHERE rsl.item_id = wlc.inventory_item_id
                      AND to_organization_id = p_organization_id
                      AND wln.lpn_id IN ( SELECT lpn_id
                                          FROM wms_license_plate_numbers
                                          START WITH lpn_id = p_lpn_id
                                          CONNECT BY parent_lpn_id = PRIOR lpn_id)
                      AND wlc.parent_lpn_id = wln.lpn_id
                      AND EXISTS(
                           SELECT 1
                             FROM po_requisition_lines_all prl, mtl_supply ms
                            WHERE prl.requisition_header_id = p_requiition_header_id
                              AND prl.requisition_header_id = ms.req_header_id
                              AND prl.requisition_line_id = ms.req_line_id
                              AND ms.supply_type_code = 'SHIPMENT'
                              AND ms.quantity > 0
                              AND ms.supply_source_id = rsl.shipment_line_id
                              AND prl.item_id = wlc.inventory_item_id
                              AND prl.item_id = ms.item_id);
          */

          SELECT DISTINCT rsl.shipment_header_id
                        , rsl.from_organization_id
                     INTO x_shipment_header_id
                        , x_from_org_id
                     FROM rcv_shipment_lines rsl, wms_lpn_contents wlc
                    WHERE rsl.item_id = wlc.inventory_item_id
                      AND to_organization_id = p_organization_id
                      AND wlc.parent_lpn_id IN ( SELECT lpn_id
                                          FROM wms_license_plate_numbers
                                          START WITH lpn_id = p_lpn_id
                                          CONNECT BY parent_lpn_id = PRIOR lpn_id)
                      AND EXISTS(
                           SELECT 1
                             FROM po_requisition_lines_all prl, mtl_supply ms
                            WHERE prl.requisition_header_id = p_requiition_header_id
                              AND prl.requisition_header_id = ms.req_header_id
                              AND prl.requisition_line_id = ms.req_line_id
                              AND ms.supply_type_code = 'SHIPMENT'
                              AND ms.quantity > 0
                              AND ms.supply_source_id = rsl.shipment_line_id
                              AND prl.item_id = wlc.inventory_item_id
                              AND prl.item_id = ms.item_id);
        EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            fnd_message.set_name('INV', 'INV_RCV_REQ_SHIP_MISMATCH');
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug('get_req_shipment_header_id for reqexp 35 - returns more than one shipment header ID for RECEIPT  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
              , 1
              );
            END IF;

            RAISE fnd_api.g_exc_error;
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_LPN_ZERO_AVAIL_QTY');
            fnd_msg_pub.ADD;
            IF (l_debug = 1) THEN
              print_debug('get_req_shipment_header_id for reqexp 40 retruned no rows ', 4);
            END IF;

            RAISE fnd_api.g_exc_error;
        END; -- Express Int Req Receiving
      ELSE
        BEGIN
          SELECT DISTINCT rsl.shipment_header_id
                        , rsl.from_organization_id
                     INTO x_shipment_header_id
                        , x_from_org_id
                     FROM rcv_shipment_lines rsl
                    WHERE item_id = p_item_id
                      AND to_organization_id = p_organization_id
                      AND EXISTS(
                           SELECT 1
                             FROM po_requisition_lines prl
                            WHERE prl.requisition_header_id = p_requiition_header_id
                              AND rsl.requisition_line_id = prl.requisition_line_id
                              AND prl.item_id = p_item_id);
        EXCEPTION
          WHEN TOO_MANY_ROWS THEN
            fnd_message.set_name('INV', 'INV_RCV_REQ_SHIP_MISMATCH');
            fnd_msg_pub.ADD;

            IF (l_debug = 1) THEN
              print_debug('get_req_shipment_header_id 30 - returns more than one shipment header ID for RECEIPT  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
            END IF;

            RAISE fnd_api.g_exc_error;
        END;

        l_progress  := '50';
      END IF;
     ELSIF p_rcv_txn_type = 'INSPECT' THEN
      --BUG 3421219: Need to handle inspection as well
      BEGIN
        SELECT DISTINCT rsl.shipment_header_id
                      , rsl.from_organization_id
                   INTO x_shipment_header_id
                      , x_from_org_id
                   FROM rcv_shipment_lines rsl
                  WHERE item_id = p_item_id
                    AND to_organization_id = p_organization_id
                    AND EXISTS(
                         SELECT 1
                           FROM po_requisition_lines prl, rcv_transactions rt, rcv_supply rs
                          WHERE prl.requisition_header_id = p_requiition_header_id
                            AND rsl.requisition_line_id = prl.requisition_line_id
                            AND prl.item_id = p_item_id
                            AND prl.source_type_code = 'INVENTORY'
                            AND rs.req_line_id = prl.requisition_line_id
                            AND rs.rcv_transaction_id = rt.transaction_id
                            AND rt.transaction_type <> 'UNORDERED'
                            AND rs.quantity > 0
                            AND rs.supply_type_code = 'RECEIVING'
                            AND rs.to_organization_id = p_organization_id
                            AND rt.organization_id = p_organization_id
                            AND(EXISTS(
                                  SELECT 1
                                    FROM rcv_transactions rt1
                                   WHERE rt1.transaction_id = rt.transaction_id
                                     AND rt1.inspection_status_code = 'NOT INSPECTED'
                                     AND rt1.routing_header_id = 2)
				));
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          fnd_message.set_name('INV', 'INV_RCV_REQ_SHIP_MISMATCH');
          fnd_msg_pub.ADD;

          IF (l_debug = 1) THEN
            print_debug(
                 'get_req_shipment_header_id 20 - returns more than one shipment header ID for RCVTXN  '
              || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
            , 1
            );
          END IF;

          RAISE fnd_api.g_exc_error;
      END;

      l_progress  := '30';
    ELSE
      l_progress  := '60';
      fnd_message.set_name('INV', 'INV_RCV_TXN_NOT_DEFINED');
      fnd_msg_pub.ADD;

      IF (l_debug = 1) THEN
        print_debug('get_req_shipment_header_id 30 - receiving Txn type ' || p_rcv_txn_type || ' not defined. ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
      l_progress  := '70';
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Exitting get_req_shipment_header_id 60 - x_shipment_header_id = ' || x_shipment_header_id || '  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exiting get_req_shipment_header_id - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_req_shipment_header_id - unexpected error:' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_req_shipment_header_id - other exceptions:' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.get_req_shipment_header_id', l_progress, SQLCODE);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END;

  PROCEDURE do_check(
    p_organization_id     IN            NUMBER
  , p_inventory_item_id   IN            NUMBER
  , p_transaction_type_id IN            NUMBER
  , p_primary_quantity    IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  ) IS
    l_progress     VARCHAR2(10);
    l_check_result VARCHAR2(1);
    l_seq_num      NUMBER;
    l_debug        NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '10';
    --
    inv_shortcheckexec_pvt.checkprerequisites(
      p_api_version                => 1.0
    , p_init_msg_list              => 'F'
    , x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , p_sum_detail_flag            => 2
    , p_organization_id            => p_organization_id
    , p_inventory_item_id          => p_inventory_item_id
    , p_transaction_type_id        => p_transaction_type_id
    , x_check_result               => l_check_result
    );

    --
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      fnd_message.set_name('INV', 'INV_RCV_SHORTAGE_FAILED');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress       := '20';

    IF (l_debug = 1) THEN
      print_debug('do_check check_result - ' || l_check_result, 4);
    END IF;

    --
    IF l_check_result = 'T' THEN
      inv_shortcheckexec_pvt.execcheck(
        p_api_version                => 1.0
      , p_init_msg_list              => 'F'
      , p_commit                     => 'F'
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , p_sum_detail_flag            => 2
      , p_organization_id            => p_organization_id
      , p_inventory_item_id          => p_inventory_item_id
      , p_comp_att_qty_flag          => 1
      , p_primary_quantity           => p_primary_quantity
      , x_seq_num                    => l_seq_num
      , x_check_result               => l_check_result
      );

      --
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        fnd_message.set_name('INV', 'INV_RCV_SHORTAGE_FAILED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      l_progress  := '30';

      --Bug #4059722
      --Need to clear the quantity tree cache for subsequent calls
      inv_quantity_tree_pub.clear_quantity_cache;

      IF l_check_result = 'T' THEN
        fnd_message.set_name('INV', 'INV_RCV_SHORTAGE_EXISTS');
        fnd_msg_pub.ADD;
        x_return_status  := 'W';
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;

      IF (l_debug = 1) THEN
        print_debug('Exiting do_check - execution error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting do_check - unexpected error:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        print_debug('Exitting get_req_shipment_header_id - other exceptions:' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        , 1);
      END IF;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.get_req_shipment_header_id', l_progress, SQLCODE);
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
  END do_check;

  /*
   * Procedure to to get serial control of the item at
   * source org. Called directly in the case of Intransit
   * shipment transaction.
   * For Int Req, the overloaded method calls this procedure
   * Written as part of fix for Bug #1751998
   */
  PROCEDURE get_serial_ctrl(
    x_return_status  OUT NOCOPY    VARCHAR2
  , x_serial_control OUT NOCOPY    NUMBER
  , p_from_org_id    IN            NUMBER
  , p_item_id        IN            NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := 'S';

    SELECT serial_number_control_code
      INTO x_serial_control
      FROM mtl_system_items
     WHERE inventory_item_id = p_item_id
       AND organization_id = p_from_org_id;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := 'F';
  END get_serial_ctrl;

  /* Procedure to get the project and task from the
     source document
  */
  PROCEDURE get_document_project_task(
    x_return_status       OUT NOCOPY    VARCHAR2
  , x_project_tasks_count OUT NOCOPY    NUMBER
  , x_distributions_count OUT NOCOPY    NUMBER
  , p_document_type       IN            VARCHAR2
  , p_po_header_id        IN            NUMBER
  , p_po_line_id          IN            NUMBER
  , p_oe_header_id        IN            NUMBER
  , p_req_header_id       IN            NUMBER
  , p_shipment_header_id  IN            NUMBER
  , p_item_id             IN            NUMBER
  , p_item_rev            IN            VARCHAR2
  ) IS
    l_project_tasks_count NUMBER       := 0;
    l_distributions_count NUMBER       := 0;
    l_progress            VARCHAR2(10);
    l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Entered get_document_project_task ' || p_document_type, 4);
    END IF;

    l_progress             := '10';
    x_return_status        := fnd_api.g_ret_sts_success;

    IF p_document_type = 'PO' THEN
      SELECT   COUNT(COUNT(*)) -- get the no of project/tasks combinations
          INTO l_project_tasks_count
          FROM po_distributions_all pod, po_lines_all pol
         WHERE pod.po_header_id = p_po_header_id
           AND pod.po_line_id = NVL(p_po_line_id, pod.po_line_id)
           AND pod.project_id IS NOT NULL
           AND pod.po_header_id = pol.po_header_id
           AND pod.po_line_id = pol.po_line_id
           AND (p_item_id IS NULL OR pol.item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                  AND pol.item_revision = p_item_rev)
               )
      GROUP BY pod.project_id, pod.task_id;

      SELECT COUNT(*)
        INTO l_distributions_count
        FROM po_distributions_all pod, po_lines_all pol
       WHERE pod.po_header_id = p_po_header_id
         AND pod.po_line_id = NVL(p_po_line_id, pod.po_line_id)
         AND pod.po_header_id = pol.po_header_id
         AND pod.po_line_id = pol.po_line_id
         AND (p_item_id IS NULL OR pol.item_id = p_item_id)
         AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
               (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                AND pol.item_revision = p_item_rev)
             );

    ELSIF p_document_type = 'ASN' THEN
      SELECT   COUNT(COUNT(*))
          INTO l_project_tasks_count
          FROM po_distributions_all pod, rcv_shipment_lines rsl
         WHERE pod.po_header_id = rsl.po_header_id
           AND rsl.shipment_header_id = p_shipment_header_id
           AND (p_item_id IS NULL OR rsl.item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR rsl.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND rsl.item_revision IS NOT NULL
                  AND rsl.item_revision = p_item_rev)
               )
           AND pod.project_id IS NOT NULL
      GROUP BY project_id, task_id;

      SELECT   COUNT(COUNT(*))
          INTO l_distributions_count
          FROM po_distributions_all pod, rcv_shipment_lines rsl
         WHERE pod.po_header_id = rsl.po_header_id
           AND rsl.po_line_id = pod.po_line_id(+)
           AND rsl.po_line_location_id = pod.line_location_id(+)
           AND rsl.shipment_header_id = p_shipment_header_id
           AND (p_item_id IS NULL OR rsl.item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR rsl.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND rsl.item_revision IS NOT NULL
                  AND rsl.item_revision = p_item_rev)
              )
      GROUP BY project_id, task_id;
    ELSIF p_document_type = 'REQ' THEN
      SELECT   COUNT(COUNT(*))
          INTO l_project_tasks_count
          FROM po_req_distributions_all pod, po_requisition_lines_all pol
         WHERE pol.requisition_header_id = p_req_header_id
           AND pod.requisition_line_id = pol.requisition_line_id
           AND pod.project_id IS NOT NULL
           AND (p_item_id IS NULL OR pol.item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                  AND pol.item_revision = p_item_rev)
               )
      GROUP BY project_id, task_id;

      SELECT COUNT(*)
        INTO l_distributions_count
        FROM po_req_distributions_all pod, po_requisition_lines_all pol
       WHERE pol.requisition_header_id = p_req_header_id
         AND pod.requisition_line_id = pol.requisition_line_id
         AND (p_item_id IS NULL OR pol.item_id = p_item_id)
         AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
               (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                AND pol.item_revision = p_item_rev)
             );

 /*Added as part of bug - 5928199*/
    ELSIF p_document_type = 'INTSHIP' THEN
      IF (l_debug = 1) THEN
        print_debug('p_document_type: ' || p_document_type, 4);
	print_debug('p_req_header_id: ' || p_req_header_id, 4);
	print_debug('p_item_id: ' || p_item_id, 4);
	print_debug('p_item_rev: ' || p_item_rev, 4);
      END IF;

      SELECT   COUNT(COUNT(*))
          INTO l_project_tasks_count
          FROM po_req_distributions_all pod, po_requisition_lines_all pol
         WHERE pol.requisition_header_id = p_req_header_id
           AND pod.requisition_line_id = pol.requisition_line_id
           AND pod.project_id IS NOT NULL
           AND (p_item_id IS NULL OR pol.item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                  AND pol.item_revision = p_item_rev)
               )
      GROUP BY project_id, task_id;
      IF (l_debug = 1) THEN
        print_debug('l_project_tasks_count: ' || l_project_tasks_count, 4);
      END IF;


      SELECT COUNT(*)
        INTO l_distributions_count
        FROM po_req_distributions_all pod, po_requisition_lines_all pol
       WHERE pol.requisition_header_id = p_req_header_id
         AND pod.requisition_line_id = pol.requisition_line_id
         AND (p_item_id IS NULL OR pol.item_id = p_item_id)
         AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
               (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                AND pol.item_revision = p_item_rev)
             );
      IF (l_debug = 1) THEN
        print_debug('l_distributions_count: ' || l_distributions_count, 4);
      END IF;
   /*End of Bug - 5928199*/

    ELSIF p_document_type = 'RMA' THEN
      SELECT   COUNT(COUNT(*))
          INTO l_project_tasks_count
          FROM oe_order_lines l
         WHERE l.line_category_code = 'RETURN'
           AND l.header_id = p_oe_header_id
           AND l.project_id IS NOT NULL
           AND (p_item_id IS NULL OR l.inventory_item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR l.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND l.item_revision IS NOT NULL
                  AND l.item_revision = p_item_rev)
               )
      GROUP BY project_id, task_id;

      SELECT COUNT(*)
        INTO l_distributions_count
        FROM oe_order_lines l
       WHERE l.line_category_code = 'RETURN'
         AND l.header_id = p_oe_header_id
         AND (p_item_id IS NULL OR l.inventory_item_id = p_item_id)
         AND ( (p_item_rev IS NULL OR l.item_revision IS NULL) OR
               (p_item_rev IS NOT NULL AND l.item_revision IS NOT NULL
                AND l.item_revision = p_item_rev)
             );
    ELSIF p_document_type = 'RECEIPT' THEN
      IF p_po_header_id IS NOT NULL THEN
        SELECT   COUNT(COUNT(*)) -- get the no of project/tasks combinations
            INTO l_project_tasks_count
            FROM po_distributions_all pod, po_lines_all pol
           WHERE pod.po_header_id = p_po_header_id
             AND pod.project_id IS NOT NULL
             AND pod.po_header_id = pol.po_header_id
             AND pod.po_line_id = pol.po_line_id
             AND (p_item_id IS NULL OR pol.item_id = p_item_id)
             AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
                   (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                    AND pol.item_revision = p_item_rev)
                  )
        GROUP BY pod.project_id, pod.task_id;

        SELECT COUNT(*)
          INTO l_distributions_count
          FROM po_distributions_all pod, po_lines_all pol
         WHERE pod.po_header_id = p_po_header_id
           AND pod.po_header_id = pol.po_header_id
           AND pod.po_line_id = pol.po_line_id
           AND (p_item_id IS NULL OR pol.item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR pol.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND pol.item_revision IS NOT NULL
                  AND pol.item_revision = p_item_rev)
               );
      ELSIF p_oe_header_id IS NOT NULL THEN
        SELECT   COUNT(COUNT(*))
            INTO l_project_tasks_count
            FROM oe_order_lines l
           WHERE l.line_category_code = 'RETURN'
             AND l.header_id = p_oe_header_id
             AND l.project_id IS NOT NULL
             AND (p_item_id IS NULL OR l.inventory_item_id = p_item_id)
             AND ( (p_item_rev IS NULL OR l.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND l.item_revision IS NOT NULL
                  AND l.item_revision = p_item_rev)
               )
        GROUP BY project_id, task_id;

        SELECT COUNT(*)
          INTO l_distributions_count
          FROM oe_order_lines l
         WHERE l.line_category_code = 'RETURN'
           AND l.header_id = p_oe_header_id
           AND (p_item_id IS NULL OR l.inventory_item_id = p_item_id)
           AND ( (p_item_rev IS NULL OR l.item_revision IS NULL) OR
                 (p_item_rev IS NOT NULL AND l.item_revision IS NOT NULL
                  AND l.item_revision = p_item_rev)
               );
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('get_document_project_task: Project count ' || TO_CHAR(l_project_tasks_count) ||
                  'distribution count: ' || TO_CHAR(l_distributions_count), 4);
    END IF;
    x_project_tasks_count  := l_project_tasks_count;
    x_distributions_count  := l_distributions_count;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_progress             := '20';
      x_return_status        := fnd_api.g_ret_sts_error;
      x_project_tasks_count  := 0;

      IF (l_debug = 1) THEN
        print_debug('in get_document_project_task ' || l_progress, 4);
      END IF;
    WHEN OTHERS THEN
      l_progress             := '30';
      x_return_status        := fnd_api.g_ret_sts_error;
      x_project_tasks_count  := 0;

      IF (l_debug = 1) THEN
        print_debug('in get_document_project_task ' || l_progress, 4);
      END IF;
  END;

  /*
   * Procedure to to get serial control of the item at
   * source org. Called in the case of Internal
   * Requisition transaction.
   * First get the source org corresponding to the current line
   * and then call the overloaded procedure above to get the
   * serial control code at the source org.
   * Written as part of fix for Bug #1751998
   */
  PROCEDURE get_serial_ctrl(
    x_return_status  OUT NOCOPY    VARCHAR2
  , x_serial_control OUT NOCOPY    NUMBER
  , p_to_org_id      IN            NUMBER
  , p_ship_head_id   IN            NUMBER
  , p_requisition_id IN            NUMBER
  , p_item_id        IN            NUMBER
  ) IS
    l_from_org_id NUMBER := 0;
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := 'S';

    /*Get the From Organization for the item using shipment header
      Id, Requisition #, To Organization Id and Item ID
    */
    SELECT DISTINCT rsl.from_organization_id
               INTO l_from_org_id
               FROM rcv_shipment_lines rsl
              WHERE item_id = p_item_id
                AND to_organization_id = p_to_org_id
                AND shipment_header_id = p_ship_head_id
                AND EXISTS(
                     SELECT 1
                       FROM po_requisition_lines prl
                      WHERE prl.requisition_header_id = p_requisition_id
                        AND rsl.requisition_line_id = prl.requisition_line_id
                        AND prl.item_id = p_item_id);

    --Get the serial control of the item at the source org
    inv_rcv_common_apis.get_serial_ctrl(x_return_status => x_return_status, x_serial_control => x_serial_control
    , p_from_org_id                => l_from_org_id, p_item_id => p_item_id);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := 'F';
  END get_serial_ctrl;

  -- MANEESH - BEGIN CHANGES - FOR CROSS REFERENCE ITEM CREATION

  PROCEDURE create_cross_reference(
    p_api_version          IN            NUMBER
  , p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false
  , p_commit               IN            VARCHAR2 := fnd_api.g_false
  , p_organization_id      IN            NUMBER
  , p_inventory_item_id    IN            NUMBER
  , p_cross_reference      IN            VARCHAR2
  , p_cross_reference_type IN            VARCHAR2
  , x_return_status        OUT NOCOPY    VARCHAR2
  , x_msg_count            OUT NOCOPY    NUMBER
  , x_msg_data             OUT NOCOPY    VARCHAR2
  ) IS
    l_progress          VARCHAR2(10);
    l_cross_reference   VARCHAR2(25);
    l_inventory_item_id NUMBER;
    l_user_id           NUMBER;
    l_login_id          NUMBER;
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_progress       := '0';

    IF (l_debug = 1) THEN
      print_debug('Entered CREATE_CROSS_REFERENCE - Progress = ' || l_progress, 9);
    END IF;

    x_return_status  := fnd_api.g_ret_sts_success;
    SAVEPOINT rcv_create_cross_reference_sp;

    -- Make sure that cross_reference does not exist as a master item.
    BEGIN
      SELECT inventory_item_id
        INTO l_inventory_item_id
        FROM mtl_system_items_kfv
       WHERE concatenated_segments = p_cross_reference;

      l_progress  := '10';

      IF (l_debug = 1) THEN
        print_debug('Cross Reference matches a master item - Progress = ' || l_progress, 9);
      END IF;

      fnd_message.set_name('INV', 'INV_CROSS_REF_MATCHES_ITEM');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_progress  := '15';
    END;

    -- Make sure that cross_ref_item does not already exist.
    BEGIN
      SELECT cross_reference
        INTO l_cross_reference
        FROM mtl_cross_references
       WHERE cross_reference = p_cross_reference
         AND cross_reference_type = p_cross_reference_type
         AND organization_id = p_organization_id;

      l_progress  := '20';

      IF (l_debug = 1) THEN
        print_debug('Cross Reference already exists - Progress =  ' || l_progress, 9);
      END IF;

      fnd_message.set_name('INV', 'INV_CROSS_REF_EXISTS');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_progress  := '25';
    END;

    l_user_id        := fnd_global.user_id;
    l_login_id       := fnd_global.login_id;
    l_progress       := '30';

    -- Insert the record in mtl_cross_references
    INSERT INTO mtl_cross_references
                (
                 inventory_item_id
               , organization_id
               , cross_reference_type
               , cross_reference
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , org_independent_flag
                )
         VALUES (
                 p_inventory_item_id
               , p_organization_id
               , p_cross_reference_type
               , p_cross_reference
               , SYSDATE
               , l_user_id
               , SYSDATE
               , l_user_id
               , l_login_id
               , 'N'
                );

    x_return_status  := fnd_api.g_ret_sts_success;
    l_progress       := '40';

    IF (l_debug = 1) THEN
      print_debug('create_cross_reference complete - progress = ' || l_progress, 9);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO rcv_create_cross_reference_sp;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO rcv_create_cross_reference_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO rcv_create_cross_reference_sp;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('INV_RCV_COMMON_APIS.create_cross_reference', l_progress, SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data => x_msg_data);
  END create_cross_reference;

  -- MANEESH - END CHANGES - FOR CROSS REFERENCE ITEM CREATION

  /*
   * Procedure to to get lot control of the item at
   * source org. Called directly in the case of Intransit
   * shipment transaction.
   * For Int Req, the overloaded method calls this procedure
   * Written as part of fix for Bug #2156143.
   */
  PROCEDURE get_lot_ctrl(
    x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , x_lot_control   OUT NOCOPY    NUMBER
  , p_from_org_id   IN            NUMBER
  , p_item_id       IN            NUMBER
  ) IS
    l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT lot_control_code
      INTO x_lot_control
      FROM mtl_system_items
     WHERE inventory_item_id = p_item_id
       AND organization_id = p_from_org_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'GET_LOT_CTRL');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_lot_ctrl;

  /*
   * Procedure to to get lot control of the item at
   * source org. Called in the case of Internal
   * Requisition transaction.
   * First get the source org corresponding to the current line
   * and then call the overloaded procedure above to get the
   * lot control code at the source org.
   * Written as part of fix for Bug #2156143
   */
  PROCEDURE get_lot_ctrl(
    x_return_status  OUT NOCOPY    VARCHAR2
  , x_msg_count      OUT NOCOPY    NUMBER
  , x_msg_data       OUT NOCOPY    VARCHAR2
  , x_lot_control    OUT NOCOPY    NUMBER
  , p_to_org_id      IN            NUMBER
  , p_ship_head_id   IN            NUMBER
  , p_requisition_id IN            NUMBER
  , p_item_id        IN            NUMBER
  ) IS
    l_from_org_id NUMBER := 0;
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;

    /*Get the From Organization for the item using shipment header
      Id, Requisition #, To Organization Id and Item ID
    */
    SELECT DISTINCT rsl.from_organization_id
               INTO l_from_org_id
               FROM rcv_shipment_lines rsl
              WHERE item_id = p_item_id
                AND to_organization_id = p_to_org_id
                AND shipment_header_id = p_ship_head_id
                AND EXISTS(
                     SELECT 1
                       FROM po_requisition_lines prl
                      WHERE prl.requisition_header_id = p_requisition_id
                        AND rsl.requisition_line_id = prl.requisition_line_id
                        AND prl.item_id = p_item_id);

    --Get the lot control of the item at the source org
    inv_rcv_common_apis.get_lot_ctrl(
      x_return_status              => x_return_status
    , x_msg_count                  => x_msg_count
    , x_msg_data                   => x_msg_data
    , x_lot_control                => x_lot_control
    , p_from_org_id                => l_from_org_id
    , p_item_id                    => p_item_id
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'GET_LOT_CTRL');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END get_lot_ctrl;

  PROCEDURE get_default_task(
    x_return_status      OUT NOCOPY    VARCHAR2
  , x_task_number        OUT NOCOPY    VARCHAR2
  , p_document_type      IN            VARCHAR2
  , p_po_header_id       IN            NUMBER DEFAULT NULL
  , p_po_line_id         IN            NUMBER DEFAULT NULL
  , p_oe_header_id       IN            NUMBER DEFAULT NULL
  , p_req_header_id      IN            NUMBER DEFAULT NULL
  , p_shipment_header_id IN            NUMBER DEFAULT NULL
  , p_item_id            IN            NUMBER DEFAULT NULL
  , p_item_rev           IN            VARCHAR2 DEFAULT NULL
  , p_project_id         IN            NUMBER DEFAULT NULL
  ) IS
    l_progress VARCHAR2(10);
    l_task_id  NUMBER;
    --l_debug number        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_debug    NUMBER       := 1;
  BEGIN
    IF (l_debug = 1) THEN
      print_debug('Entered get_document_project_task ' || p_document_type, 4);
    --dbms_output.put_line('Entered get_document_project_task '|| p_document_type);
    END IF;

    l_progress       := '10';
    x_return_status  := fnd_api.g_ret_sts_success;

    IF p_project_id IS NULL THEN
      IF (l_debug = 1) THEN
        print_debug('project id is null', 4);
      --dbms_output.put_line('project id is null');
      END IF;

      RETURN;
    END IF;

    IF p_document_type = 'PO' THEN
      BEGIN
        SELECT pod.task_id
          INTO l_task_id
          FROM po_distributions_all pod, po_lines_all pol
         WHERE pod.po_header_id = p_po_header_id
           AND pod.po_line_id = NVL(p_po_line_id, pod.po_line_id)
           AND pod.project_id = p_project_id
           AND pod.po_header_id = pol.po_header_id
           AND pod.po_line_id = pol.po_line_id
           AND(p_item_id IS NULL
               OR pol.item_id = p_item_id)
           AND(p_item_rev IS NULL
               OR pol.item_revision = p_item_rev);
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('error ' || SQLERRM, 4);
          --dbms_output.put_line('error '||SQLERRM);
          END IF;
      END;

      IF (l_debug = 1) THEN
        print_debug('task= ' || TO_CHAR(l_task_id), 4);
      --dbms_output.put_line('task= '||to_char(l_task_id));
      END IF;
    ELSIF p_document_type = 'ASN' THEN
      BEGIN
        SELECT pod.task_id
          INTO l_task_id
          FROM po_distributions_all pod, rcv_shipment_lines rsl
         WHERE pod.po_header_id = rsl.po_header_id
           AND rsl.po_line_id = pod.po_line_id(+)
           AND rsl.po_line_location_id = pod.line_location_id(+)
           AND rsl.shipment_header_id = p_shipment_header_id
           AND pod.project_id = p_project_id
           AND(p_item_id IS NULL
               OR rsl.item_id = p_item_id)
           AND(p_item_rev IS NULL
               OR rsl.item_revision = p_item_rev);
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('error ' || SQLERRM, 4);
          --dbms_output.put_line('error '||SQLERRM);
          END IF;
      END;
    ELSIF p_document_type = 'REQ' THEN
      BEGIN
        SELECT pod.task_id
          INTO l_task_id
          FROM po_req_distributions_all pod, po_requisition_lines_all pol
         WHERE pol.requisition_header_id = p_req_header_id
           AND pod.requisition_line_id = pol.requisition_line_id
           AND pod.project_id = p_project_id
           AND(p_item_id IS NULL
               OR pol.item_id = p_item_id)
           AND(p_item_rev IS NULL
               OR pol.item_revision = p_item_rev);
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('error ' || SQLERRM, 4);
          --dbms_output.put_line('error '||SQLERRM);
          END IF;
      END;
    ELSIF p_document_type = 'RMA' THEN
      BEGIN
        SELECT l.task_id
          INTO l_task_id
          FROM oe_order_lines l
         WHERE l.line_category_code = 'RETURN'
           AND l.header_id = p_oe_header_id
           AND l.project_id = p_project_id
           AND(p_item_id IS NULL
               OR l.inventory_item_id = p_item_id)
           AND(p_item_rev IS NULL
               OR l.item_revision = p_item_rev);
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('error ' || SQLERRM, 4);
          --dbms_output.put_line('error '||SQLERRM);
          END IF;
      END;
    ELSIF p_document_type = 'RECEIPT' THEN
      IF p_po_header_id IS NOT NULL THEN
        BEGIN
          SELECT   pod.task_id
              INTO l_task_id
              FROM po_distributions_all pod, po_lines_all pol
             WHERE pod.po_header_id = p_po_header_id
               AND pod.project_id = p_project_id
               AND pod.po_header_id = pol.po_header_id
               AND pod.po_line_id = pol.po_line_id
               AND(p_item_id IS NULL
                   OR pol.item_id = p_item_id)
               AND(p_item_rev IS NULL
                   OR pol.item_revision = p_item_rev)
          GROUP BY pod.project_id, pod.task_id;
        EXCEPTION
          WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              print_debug('error ' || SQLERRM, 4);
            --dbms_output.put_line('error '||SQLERRM);
            END IF;
        END;
      END IF;
    ELSIF p_oe_header_id IS NOT NULL THEN
      BEGIN
        SELECT   task_id
            INTO l_task_id
            FROM oe_order_lines l
           WHERE l.line_category_code = 'RETURN'
             AND l.header_id = p_oe_header_id
             AND l.project_id = p_project_id
             AND(p_item_id IS NULL
                 OR l.inventory_item_id = p_item_id)
             AND(p_item_rev IS NULL
                 OR l.item_revision = p_item_rev)
        GROUP BY project_id, task_id;
      EXCEPTION
        WHEN OTHERS THEN
          IF (l_debug = 1) THEN
            print_debug('error ' || SQLERRM, 4);
          --dbms_output.put_line('error '||SQLERRM);
          END IF;
      END;
    END IF;

    BEGIN
      IF (l_task_id IS NOT NULL) THEN
        x_task_number  := inv_projectlocator_pub.get_task_number(l_task_id);
        print_debug('error ' || SQLERRM, 4);
      --dbms_output.put_line('task  '||x_task_number);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END;

  /**
  *   This procedure checks for the following
  *   1. Whether the given LPN or its child LPN has contents. If
  *   either the given
  *      LPN or its child LPNs do not have any contents then
  *   through error.
  *   2. Check If the LPN is already processed, and there is a
  *   RTI record exists
  *      for the LPN.

  *  @param  p_lpn_id
  *  @param  x_return_status
  *  @param  x_msg_count
  *  @param  x_msg_data
**/
  PROCEDURE validate_nested_lpn(
    p_lpn_id        IN            NUMBER
  , x_lpn_flag      OUT NOCOPY    VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  ) IS
    l_return_status  VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);
    l_progress       VARCHAR2(10);
    l_valid_lpn_flag VARCHAR(1)     := 'Y';
    l_debug          NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    x_lpn_flag  := 'N'; -- 'Y -validlpn ' 'N- Invalid lpn'
    l_progress  := 10;

    IF (l_debug = 1) THEN
      print_debug('lpn_id: ' || TO_CHAR(p_lpn_id), 1);
    END IF;

    -- Check at least one child LPN has contents.

    BEGIN
       -- Bug 3440456
       -- The following is changed because the join with WLPN is unnecessary
       /*SELECT 'Y'
         INTO x_lpn_flag
	 FROM wms_license_plate_numbers lpn, wms_lpn_contents wlc
	 WHERE lpn.lpn_id = wlc.parent_lpn_id
         AND lpn_id IN (SELECT     lpn_id
	                FROM wms_license_plate_numbers wln
                        START WITH lpn_id = p_lpn_id
                        CONNECT BY parent_lpn_id = PRIOR lpn_id);*/

       -- Bug# 3633708: Performance Fixes
       -- The following query is bad because it does a full table scan on WLC
       /*SELECT 'Y'
	 INTO x_lpn_flag
	 FROM wms_lpn_contents wlc
	 WHERE wlc.parent_lpn_id IN (SELECT lpn_id
				     FROM wms_license_plate_numbers wln
				     START WITH lpn_id = p_lpn_id
				     CONNECT BY parent_lpn_id = PRIOR lpn_id);*/

       -- Bug# 3633708: Performance Fixes
       -- Use this query instead
       SELECT 'Y'
	 INTO x_lpn_flag
	 FROM wms_license_plate_numbers wln
	 WHERE EXISTS (SELECT '1'
		       FROM wms_lpn_contents wlc
		       WHERE wlc.parent_lpn_id = wln.lpn_id)
	   START WITH wln.lpn_id = p_lpn_id
	   CONNECT BY wln.parent_lpn_id = PRIOR wln.lpn_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN -- item controls are valid
	  x_lpn_flag  := 'N';
       WHEN TOO_MANY_ROWS THEN
	  x_lpn_flag  := 'Y';
    END;

    IF x_lpn_flag = 'N' THEN
      RETURN;
    END IF;

    -- Check None of the child LPNs are already processed and have pending RTI transactions

    BEGIN
      --
      -- 3440456
      -- Retrieval of x_lpn_flag is changed
      --
      SELECT 'Y'
        INTO x_lpn_flag
        FROM wms_license_plate_numbers lpn, wms_lpn_contents wlc, rcv_transactions_interface rti
       WHERE lpn.lpn_id = wlc.parent_lpn_id
         AND lpn.lpn_id = rti.lpn_id
         AND rti.transaction_status_code = 'PENDING'
         AND lpn.lpn_id IN(SELECT     lpn_id
                                 FROM wms_license_plate_numbers wln
                           START WITH lpn_id = p_lpn_id
                           CONNECT BY parent_lpn_id = PRIOR lpn_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_lpn_flag  := 'N';
      WHEN TOO_MANY_ROWS THEN
        x_lpn_flag  := 'Y';
    END;
  EXCEPTION
    WHEN OTHERS THEN
      x_lpn_flag       := 'N';
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      print_debug(SQLCODE, 1);

      IF SQLCODE IS NOT NULL THEN
        l_progress  := 100;
        inv_mobile_helper_functions.sql_error('validate_nested_lpns', l_progress, SQLCODE);
      END IF;
  END validate_nested_lpn;

  /**
    * This procedure takes in the LPN and fetches the LPN context,
    * subinventory code and locator id.
    * If the LPN resides in receiving, it also fetches the subinventory
    * and locator for that LPN
    **/
    PROCEDURE get_rcv_sub_loc(
        x_return_status      OUT NOCOPY    VARCHAR2
      , x_msg_count          OUT NOCOPY    NUMBER
      , x_msg_data           OUT NOCOPY    VARCHAR2
      , x_lpn_context        OUT NOCOPY    NUMBER
      , x_locator_segs       OUT NOCOPY    VARCHAR2
      , x_location_id        OUT NOCOPY    NUMBER
      , x_location_code      OUT NOCOPY    VARCHAR2
      , x_sub_code           OUT NOCOPY    VARCHAR2
      , x_locator_id         OUT NOCOPY    NUMBER
      , p_lpn_id             IN            NUMBER
      , p_organization_id    IN            NUMBER) IS
      l_count       NUMBER;
      l_progress    VARCHAR2(10);
      l_debug       NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
      l_sub_code    mtl_secondary_inventories.secondary_inventory_name%TYPE;
      l_locator_id  NUMBER;
      l_location_id NUMBER;
      l_auto_transact_code VARCHAR2(10);
    BEGIN
      x_return_status  := fnd_api.g_ret_sts_success;

      IF (l_debug = 1) THEN
        print_debug('Enter  get_rcv_sub_loc: 10:' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
        print_debug('Parameters passed : 10.1: p_organization_id - ' || p_organization_id, 4);
        print_debug('Parameters passed : 10.2: p_lpn_id - ' || p_lpn_id, 4);
      END IF;

      --First check the lpn_context
      l_progress := '20';
      BEGIN
        SELECT lpn_context
             , subinventory_code
             , locator_id
        INTO   x_lpn_context
             , l_sub_code
             , l_locator_id
        FROM   wms_license_plate_numbers
        WHERE  lpn_id = p_lpn_id;
      EXCEPTION
      WHEN OTHERS THEN
        x_lpn_context := 5;
        x_locator_segs := NULL;
        x_locator_id := NULL;
        x_location_id := NULL;
        x_location_code := NULL;
        x_sub_code := NULL;
        RETURN;
      END;

      --If the LPN has a subinventory associated, get the location_code
      --from hr_locations using location_id in mtl_secondary_inventories for that sub
      IF (l_debug = 1) THEN
        print_debug('get_rcv_sub_loc: 20: values from WLPN - context: ' || x_lpn_context ||
              ', sub_code: ' || l_sub_code || ', loc_id: ' || l_locator_id, 4);
      END IF;

      IF l_sub_code IS NULL THEN
        BEGIN
          l_progress := '30';
          --Get the subinventory, locator_id and routing from rcv_transactions_interface
          --If there exists one and it is not direct then error out with the
          --"Invalid LPN context" error since we cannot commingle routings in the same LPN
          SELECT  subinventory
                , locator_id
                , location_id
                , auto_transact_code
          INTO    l_sub_code
                , l_locator_id
                , l_location_id
                , l_auto_transact_code
          FROM    rcv_transactions_interface
          WHERE   transfer_lpn_id = p_lpn_id
          AND     transaction_type = 'RECEIVE'
          AND     transaction_status_code = 'PENDING'
          AND     processing_status_code <> 'ERROR'
          AND     ROWNUM = 1;


          IF (NVL(l_auto_transact_code, 'RECEIVE') = 'DELIVER') THEN
            x_return_status  := fnd_api.g_ret_sts_error;
	    IF ((inv_rcv_common_apis.g_wms_patch_level >= inv_rcv_common_apis.g_patchset_j) or
		(inv_rcv_common_apis.g_inv_patch_level >= inv_rcv_common_apis.g_patchset_j)) THEN
	       x_msg_data       := 'INV_CANNOT_COMMINGLE_ROUTING';
	       fnd_message.set_name('INV', 'INV_CANNOT_COMMINGLE_ROUTING');
	     ELSE
	       x_msg_data       := 'INV_INVALID_LPN_CONTEXT';
	       fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
	    END IF;
            fnd_msg_pub.ADD;
            RETURN;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            BEGIN
              l_progress := 40;
              SELECT  to_subinventory
                    , to_locator_id
                    , location_id
              INTO    l_sub_code
                    , l_locator_id
                    , l_location_id
              FROM   rcv_supply
              WHERE lpn_id = p_lpn_id
              AND   to_organization_id = p_organization_id
              AND   ROWNUM = 1;
            EXCEPTION
              WHEN OTHERS THEN
                x_sub_code := NULL;
                x_locator_id := NULL;
                x_locator_segs := NULL;
                x_location_id := NULL;
                x_location_code := NULL;
                RETURN;
            END;
          WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              print_debug('get_sub_code: 20.5: Error occurred while fetching values from RTI', 1);
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END;
      END IF;   --END IF l_sub_code IS NULL

      x_locator_segs   := NULL;
      x_location_code  := NULL;

      l_progress       := '50';

      IF l_sub_code IS NOT NULL THEN
        BEGIN
          SELECT location_code
               , location_id
          INTO   x_location_code
               , x_location_id
          from   hr_locations hl
          WHERE EXISTS
            ( SELECT 1
              FROM  mtl_secondary_inventories msi
              WHERE organization_id = p_organization_id
              AND   secondary_inventory_name = l_sub_code
              AND   msi.location_id = hl.location_id)
          AND ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            x_location_id := NULL;
            x_location_code := NULL;
        END;
      ELSIF l_location_id IS NOT NULL THEN
        BEGIN
          l_progress := '60';
          SELECT location_code
               , location_id
          INTO   x_location_code
               , x_location_id
          FROM   hr_locations hl
          WHERE  location_id = l_location_id
          AND    ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_sub_code := NULL;
            l_locator_id := NULL;
            x_location_id := NULL;
            x_location_code := NULL;
          END;
      END IF;

      --Get the locator segments only if sub and locator_id are set
      IF (l_sub_code IS NOT NULL AND l_locator_id IS NOT NULL) THEN
        l_progress  := '70';
        BEGIN
          SELECT inv_project.get_locsegs(inventory_location_id, organization_id)
            INTO x_locator_segs
            FROM mtl_item_locations
           WHERE organization_id = p_organization_id
             AND inventory_location_id = l_locator_id;
        EXCEPTION
          WHEN OTHERS THEN
            x_locator_segs  := NULL;
        END;
      END IF;

      --Finally assign the values for output variables
      x_sub_code := l_sub_code;
      x_locator_id := l_locator_id;

      IF (l_debug = 1) THEN
        print_debug(' lpn_context ' || x_lpn_context, 4);
        print_debug(' sub_code  ' || x_sub_code, 4);
        print_debug(' location_code ' || x_location_code, 4);
        print_debug(' location_id   ' || x_location_id, 4);
        print_debug(' locator_segs  ' || x_locator_segs, 4);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        IF SQLCODE IS NOT NULL THEN
          inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_sub_code', l_progress, SQLCODE);
        END IF;
        IF (l_debug = 1) THEN
          print_debug('Exitting get_sub_code - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
        END IF;
        --
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
          fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_sub_code');
        END IF;
    END get_rcv_sub_loc;

    PROCEDURE validate_from_lpn(
      p_lpn_id            IN            NUMBER
    , p_req_id            IN            VARCHAR2
    , x_lpn_flag          OUT NOCOPY    VARCHAR2
    , x_count_of_lpns     OUT NOCOPY    NUMBER
    , x_return_status     OUT NOCOPY    VARCHAR2
    , x_msg_count         OUT NOCOPY    NUMBER
    , x_msg_data          OUT NOCOPY    VARCHAR2
    , p_shipment_num      IN            VARCHAR2
    , p_org_id            IN            NUMBER
    ) IS
      l_return_status   VARCHAR2(1)    := fnd_api.g_ret_sts_success;
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(4000);
      l_progress        VARCHAR2(10);
      l_req_num         VARCHAR2(10);
      l_valid_lpn_flag  VARCHAR(1)     := 'Y';
      l_order_header_id NUMBER;
      l_debug           NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    BEGIN

      -- Intialize variables
      x_lpn_flag  := 'Y'; -- 'Y -validlpn ' 'N- Invalid lpn'
      x_count_of_lpns := 1;
      x_return_status  := fnd_api.g_ret_sts_success;
      l_progress  := 10;


      IF (l_debug = 1) THEN
        print_debug('lpn_id: ' || TO_CHAR(p_lpn_id), 1);
        print_debug('req id : ' || p_req_id,1);
      END IF;
      -- Check if there is any existing RTI Record for the given LPN or their childs.

      BEGIN
        SELECT 'N' INTO x_lpn_flag
        FROM rcv_transactions_interface
        WHERE lpn_id IN ( SELECT lpn_id FROM wms_license_plate_numbers
                            START WITH lpn_id = p_lpn_id
                            CONNECT BY parent_lpn_id = PRIOR lpn_id)
        AND transaction_status_code = 'PENDING'
	AND processing_status_code <> 'ERROR'
	AND ROWNUM = 1  ;
      EXCEPTION
        WHEN no_data_found  THEN
          x_lpn_flag := 'Y';
        WHEN too_many_rows THEN
          x_lpn_flag := 'N';
      END;

      IF (l_debug = 1) THEN
        print_debug('x_lpn_flag after checking for RTI records: ' || x_lpn_flag, 1);
      END IF;


      -- Get Sales order header id for the given LPN

      l_progress := '10';
      IF (p_req_id IS NOT NULL) AND (x_lpn_flag = 'Y') THEN
         SELECT segment1
           INTO l_req_num
           FROM po_requisition_headers_all
           WHERE requisition_header_id = p_req_id;

         IF (l_debug = 1) THEN
           print_debug('segment1 : ' || l_req_num, 1);
         END IF;


        l_progress := '20';
        SELECT header_id
          INTO   l_order_header_id
          FROM   oe_order_headers_all
          WHERE  orig_sys_document_ref = l_req_num
          AND    order_source_id  = 10;

        IF (l_debug = 1) THEN
          print_debug('oe_order_header_id  : ' || l_order_header_id, 1);
        END IF;


        l_progress := '30';

        /* Bug 5073354 : Changed following query to access the base table wsh_delivery_details
        **               instead of using the view wsh_delivery_details_ob_grp_v and
        **               wsh_delivery_assignments instead of wsh_delivery_assignments_v.  This
        **               is being done to overcome performance issues reported for 10G database.
        */

        -- verify the LPN belongs choosen internal order.
        BEGIN
          SELECT 'Y' INTO x_lpn_flag
          FROM wsh_delivery_details wdd,
               wsh_delivery_assignments wda,
               wsh_delivery_details wdd1
          WHERE wdd.lpn_id IN
                (SELECT lpn_id FROM  wms_license_plate_numbers
                 START WITH lpn_id = p_lpn_id
                 CONNECT BY parent_lpn_id = PRIOR  lpn_id)
          AND wdd.delivery_detail_id = wda.parent_delivery_detail_id
          AND wda.delivery_detail_id = wdd1.delivery_detail_id
          AND NVL(wdd.line_direction,'O') IN ('O','IO')
	        AND wdd1.source_header_id = l_order_header_id
	        AND ROWNUM = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_lpn_flag := 'N';
          WHEN TOO_MANY_ROWS THEN
            x_lpn_flag := 'Y';
        END;
        l_progress := 40;

        IF (l_debug = 1) THEN
          print_debug('x_lpn_flag after checking lpn belongs to this internal order : ' || x_lpn_flag, 1);
        END IF;

        /* Bug 5073354 : Changed following query to access the base table wsh_delivery_details
        **               instead of using the view wsh_delivery_details_ob_grp_v and
        **               wsh_delivery_assignments instead of wsh_delivery_assignments_v.  This
        **               is being done to overcome performance issues reported for 10G database.
        */

        -- Verify this LPN does not belong any other internal requision
        IF(x_lpn_flag = 'Y')  THEN

           --BUG 4237975: break up query that joins wlpn with wsh
           --to improve performance
	   FOR l_lpn_rec IN (SELECT lpn_id FROM  wms_license_plate_numbers
			     START WITH lpn_id = p_lpn_id
			     CONNECT BY parent_lpn_id = PRIOR  lpn_id) LOOP
             BEGIN
		SELECT 'N' INTO x_lpn_flag
		  FROM wsh_delivery_details wdd,
		       wsh_delivery_assignments wda,
		       wsh_delivery_details wdd1
		  WHERE wdd.lpn_id = l_lpn_rec.lpn_id
		  AND wdd.delivery_detail_id = wda.parent_delivery_detail_id
		  AND wda.delivery_detail_id = wdd1.delivery_detail_id
		  AND NVL(wdd.line_direction,'O') IN ('O','IO')
		  AND wdd1.source_header_id <> l_order_header_id
		  AND ROWNUM = 1;
	     EXCEPTION
		WHEN TOO_MANY_ROWS THEN
		   x_lpn_flag := 'N';
                WHEN OTHERS THEN
                   NULL;
	     END;

	     IF (x_lpn_flag = 'N') THEN
		EXIT;
	     END IF;
	  END LOOP;


          IF (l_debug = 1) THEN
            print_debug('x_lpn_flag after checking lpn belongs oter internal orders : ' || x_lpn_flag, 1);
          END IF;

        END IF;


        l_progress :=50;

        IF (l_debug = 1) THEN
          print_debug('x_lpn_flag: ' || x_lpn_flag, 4);
        END IF;

        /* Bug 5073354 : Changed following query to access the base table wsh_delivery_details
        **               instead of using the view wsh_delivery_details_ob_grp_v and
        **               wsh_delivery_assignments instead of wsh_delivery_assignments_v.  This
        **               is being done to overcome performance issues reported for 10G database.
        */

        -- Check are there any LPNs left for this order.
        BEGIN
          SELECT 1 INTO x_count_of_lpns
          FROM wsh_delivery_details wdd,
               wsh_delivery_assignments wda,
               wsh_delivery_details wdd1
          WHERE wdd.lpn_id NOT IN
                  (SELECT lpn_id FROM  wms_license_plate_numbers
                   START WITH lpn_id = p_lpn_id
                   CONNECT BY parent_lpn_id = PRIOR  lpn_id)
            AND wdd.delivery_detail_id = wda.parent_delivery_detail_id
            AND wda.delivery_detail_id = wdd1.delivery_detail_id
            AND NVL(wdd.line_direction,'O') IN ('O','IO')
            AND wdd1.source_header_id = l_order_header_id
            AND NOT EXISTS
                  (SELECT lpn_id FROM rcv_transactions_interface
                   WHERE lpn_id = wdd.lpn_id
                   AND transaction_status_code = 'PENDING'
                   AND processing_status_code <> 'ERROR')
	    AND ROWNUM = 1;
	EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_count_of_lpns := 0;
          WHEN TOO_MANY_ROWS THEN
            x_count_of_lpns := 1;
        END;

        IF (l_debug = 1) THEN
          print_debug('x_count_of_lpns: ' || x_count_of_lpns, 4);
        END IF;

       ELSIF (p_shipment_num IS NOT NULL) THEN
	 IF (l_debug = 1) THEN
          print_debug('p_shipment_num = ' || p_shipment_num, 4);
        END IF;

	BEGIN
	   SELECT  1 INTO x_count_of_lpns
	     FROM  wms_license_plate_numbers wlpn1, rcv_shipment_headers rsh
	     WHERE rsh.shipment_num = p_shipment_num
	     AND   wlpn1.source_name = rsh.shipment_num
	     AND   ((wlpn1.lpn_context = 6 AND wlpn1.organization_id = rsh.organization_id) OR
		    (wlpn1.lpn_context = 7 AND wlpn1.organization_id = rsh.ship_to_org_id))
	     AND EXISTS (SELECT wlpn2.lpn_id
			  FROM   wms_license_plate_numbers wlpn2
			  START WITH wlpn2.lpn_id = wlpn1.lpn_id
			  CONNECT BY PRIOR wlpn2.lpn_id = wlpn2.parent_lpn_id
	                 INTERSECT
	                 SELECT rsl.asn_lpn_id
	                 FROM rcv_shipment_lines rsl
			  WHERE rsl.shipment_header_id = rsh.shipment_header_id
			  AND   NOT exists (SELECT 1
					    FROM   rcv_transactions_interface rti
					    WHERE  rti.lpn_id = rsl.asn_lpn_id
					    AND    rti.transfer_lpn_id = rsl.asn_lpn_id
					    AND    rti.to_organization_id = rsl.to_organization_id
					    AND    rti.processing_status_code <> 'ERROR'
					    AND    rti.transaction_status_code <> 'ERROR'
					    )
			  AND rsl.asn_lpn_id NOT IN (SELECT wlpn3.lpn_id
						     FROM   wms_license_plate_numbers wlpn3
						     START WITH wlpn3.lpn_id = p_lpn_id
						     CONNECT BY PRIOR wlpn3.lpn_id = wlpn3.parent_lpn_id
						     )
			 );
	EXCEPTION
	   WHEN no_data_found THEN
	      x_count_of_lpns := 0;
	   WHEN too_many_rows THEN
	      x_count_of_lpns := 1;
	END;

        IF (l_debug = 1) THEN
          print_debug('Num of unprocessed LPNs: ' || x_count_of_lpns, 4);
        END IF;

      END IF; -- End if for p_req_header_id is not null

      l_progress := 60;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.validate_from_lpn', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exitting validate_from_lpn - other exception:' || l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'validate_from_lpn');
      END IF;

   END validate_from_lpn;


/****************************************************
 *  This procedure clears the lot numbers from the
 *  global variable when there is an error.
 *  This procedure has been added for fixing the bug ( # 3156689)
 ****************************************************/

PROCEDURE  clear_lot_rec
IS
BEGIN
   print_debug('Enter clear_lot_rec: 1  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);

   inv_rcv_std_rcpt_apis.g_rcpt_lot_qty_rec_tb.DELETE;

   print_debug('clear_lot_rec: 2 End of Procedure ',1);

END clear_lot_rec;

--<R12 MOAC START>

/* Function get_operating_unit_id returns the org_id. */

FUNCTION get_operating_unit_id ( p_receipt_source_code IN VARCHAR2,
                                 p_po_header_id        IN NUMBER,
                                 p_req_line_id         IN NUMBER,
                                 p_oe_order_header_id  IN NUMBER
                                )
RETURN NUMBER IS

l_operating_unit_id MO_GLOB_ORG_ACCESS_TMP.ORGANIZATION_ID%TYPE;

l_progress           VARCHAR2(10);
l_debug              NUMBER;

BEGIN

  IF p_receipt_source_code = 'VENDOR' THEN

    l_progress       := '010';

    IF p_po_header_id IS NOT NULL THEN

      Select org_id
      into l_operating_unit_id
      from po_headers_all
      where po_header_id = p_po_header_id;

    END IF;

  ELSIF p_receipt_source_code = 'INTERNAL ORDER' THEN

    l_progress       := '020';

    IF p_req_line_id IS NOT NULL THEN

      Select org_id
      into l_operating_unit_id
      from po_requisition_lines_all
      where requisition_line_id = p_req_line_id;

    END IF;

  ELSIF p_receipt_source_code = 'CUSTOMER' THEN

    l_progress       := '030';

    IF p_oe_order_header_id IS NOT NULL THEN

      Select org_id
      into l_operating_unit_id
      from oe_order_headers_all
      where header_id = p_oe_order_header_id;

    END IF;

  END IF;

  RETURN l_operating_unit_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN

    l_debug := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    IF (l_debug = 1) THEN
       print_debug('Error getting org_id in get_operating_unit_id(): '||l_progress, 1);
    END IF;

END get_operating_unit_id;

--<R12 MOAC END>

/** Start of fix for bug 5065079 (FP of bug 4651362)
  * Following procedure is added to count the number of open shipments for
  * an internal requisition.
  **/
PROCEDURE count_req_open_shipments
  (p_organization_id         IN NUMBER,
   p_requisition_header_id   IN NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2,
   x_open_shipments          OUT NOCOPY    NUMBER
   )IS
   l_debug         NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
   BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    IF (l_debug = 1) THEN
      print_debug('Enter check_req_open_shipments 10  ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      print_debug(' p_requisition_header_id =>'||p_requisition_header_id,1);

    END IF;
    BEGIN
         SELECT count(DISTINCT rsl.shipment_header_id)
	 INTO x_open_shipments
         FROM rcv_shipment_lines rsl, po_requisition_lines prl
         WHERE to_organization_id = p_organization_id
	 AND nvl(rsl.shipment_line_status_code, ' ') <> 'FULLY RECEIVED'
         AND prl.requisition_header_id = p_requisition_header_id
         AND  rsl.requisition_line_id = prl.requisition_line_id;

    EXCEPTION
       WHEN OTHERS THEN
	  IF (l_debug = 1) THEN
	     print_debug(' Unable to query shipment. SQLCODE:'||SQLCODE||' SQLERM:'||Sqlerrm,1);
	  END IF;
	  x_open_shipments := 0;
    END;

    IF (l_debug = 1) THEN
       print_debug('x_open_shipments:'||x_open_shipments,1);
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
	 IF (l_debug = 1) THEN
              print_debug('check_req_open_shipments 30 - Unexpected error',1);
         END IF;
END count_req_open_shipments;

-- Bug 5068944 (FP of bug 4992317)
-- Defaulting the UOM from Receipt Transaction for Deliver Transaction of PO
PROCEDURE get_rec_uom_code(
                          x_return_status       OUT NOCOPY   VARCHAR2
			, x_uom_code            OUT NOCOPY   VARCHAR2
			, p_shipment_header_id  IN           NUMBER
			, p_item_id            IN            NUMBER
                        , p_organization_id    IN            NUMBER
			) IS
       l_progress   VARCHAR2(10);
       l_debug      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
       l_uom_code   VARCHAR2(3);
  BEGIN
     x_return_status  := fnd_api.g_ret_sts_success;
     x_uom_code := NULL;
     IF (l_debug = 1) THEN
	print_debug('Entering get_rec_uom_code',4);
	print_debug('Parameters passed : 10.1: p_shipment_header_id - ' || p_shipment_header_id , 4);
	print_debug('Parameters passed : 10.2: p_item_id - ' || p_item_id, 4);
	print_debug('Parameters passed : 10.3: p_organization_id - ' || p_organization_id, 4);
     END IF;

     l_progress := '10';

     IF p_shipment_header_id IS NOT NULL AND p_item_id IS NOT NULL THEN
	l_progress  := '20';
        BEGIN
	   SELECT DISTINCT mum.uom_code
	     INTO l_uom_code
	     FROM rcv_transactions rt , rcv_shipment_lines rsl, mtl_units_of_measure mum
	     WHERE rt.transaction_type = 'RECEIVE'
	     AND rsl.item_id = p_item_id
	     AND rt.organization_id = p_organization_id
	     AND rsl.shipment_header_id = rt.shipment_header_id
	     AND rt.unit_of_measure IS NOT NULL
	     AND rt.shipment_header_id = p_shipment_header_id
	     AND mum.unit_of_measure(+) = rt.unit_of_measure;
	EXCEPTION
	   WHEN OTHERS THEN
	      l_uom_code := NULL;
	END;

	IF (l_uom_code IS NOT NULL) THEN
	   x_uom_code := inv_ui_item_lovs.get_conversion_rate
	                    (l_uom_code,
			     p_organization_id,
			     p_item_id);
	 ELSE
	   x_uom_code := NULL;
	END IF;--END IF (l_uom_code IS NOT NULL) THEN
     END IF;--IF p_shipment_header_id IS NOT NULL AND p_item_id IS NOT NULL THEN

     IF (l_debug = 1) THEN
	print_debug('l_uom_code:'||l_uom_code,4);
	print_debug('x_uom_code:'||x_uom_code,4);
     END IF;

  EXCEPTION
    WHEN OTHERS THEN

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('inv_rcv_common_apis.get_rec_uom_code', l_progress, SQLCODE);
      END IF;

      IF (l_debug = 1) THEN
        print_debug('Exiting get_rec_uom_code - other exception:' || l_progress ||' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'), 1);
      END IF;

      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'get_rec_uom_code');
      END IF;

END get_rec_uom_code; -- Bug 5068944 Ends

END inv_rcv_common_apis;

/
