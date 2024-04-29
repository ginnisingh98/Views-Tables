--------------------------------------------------------
--  DDL for Package Body GML_RCV_COMMON_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RCV_COMMON_APIS" AS
  /* $Header: GMLRCVAB.pls 120.0 2005/05/25 16:53:16 appldev noship $*/

  --  Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30) := 'GML_RCV_COMMON_APIS';


  PROCEDURE insert_mtlt(p_mtlt_rec mtl_transaction_lots_temp%ROWTYPE) IS
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
               --- Added the following 5 comlumns for OPM
               , sublot_num
               , reason_code
               , SECONDARY_QUANTITY
               , SECONDARY_UNIT_OF_MEASURE
               , qc_grade
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
               --- Added the following 5 comlumns for OPM
               , p_mtlt_rec.sublot_num
               , p_mtlt_rec.reason_code
               , p_mtlt_rec.SECONDARY_QUANTITY
               , p_mtlt_rec.SECONDARY_UNIT_OF_MEASURE
               , p_mtlt_rec.qc_grade
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
                );
  END insert_mtlt;

  FUNCTION break_lots_only(p_original_tid IN mtl_transaction_lots_temp.transaction_temp_id%TYPE, p_new_transactions_tb IN trans_rec_tb_tp)
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
               --- Added the following 5 comlumns for OPM
             , sublot_num
             , reason_code
             , SECONDARY_QUANTITY
             , SECONDARY_UNIT_OF_MEASURE
             , qc_grade
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
    l_new_primary_quantity    NUMBER; -- the quanity user wants to split
    l_transaction_temp_id     mtl_transaction_lots_temp.transaction_temp_id%TYPE;
    l_primary_quantity        NUMBER; -- the primary qty for lot
    l_secondary_quantity        NUMBER; -- the primary qty for lot
    l_transaction_quantity    NUMBER;
    l_lot_number              mtl_transaction_lots_temp.lot_number%TYPE;
    l_sublot_number           mtl_transaction_lots_temp.sublot_num%TYPE;
    l_item_no                 VARCHAR2(40);
    l_unit_of_measure         VARCHAR2(100);

    --BUG 2673970
    l_rowid                   ROWID;
  BEGIN
    FOR i IN 1 .. p_new_transactions_tb.COUNT LOOP -- Loop through all the transaction lines need to be splitted
      l_new_transaction_temp_id  := p_new_transactions_tb(i).transaction_id;
      l_new_primary_quantity     := p_new_transactions_tb(i).primary_quantity;
      l_item_no                  := p_new_transactions_tb(i).item_no;
      l_unit_of_measure          := p_new_transactions_tb(i).unit_of_measure;
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
       --- Added the following 5 comlumns for OPM
       , l_mtlt_rec.sublot_num
       , l_mtlt_rec.reason_code
       , l_mtlt_rec.SECONDARY_QUANTITY
       , l_mtlt_rec.SECONDARY_UNIT_OF_MEASURE
       , l_mtlt_rec.qc_grade
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
        l_sublot_number            := l_mtlt_rec.sublot_num;
        l_transaction_quantity  := l_mtlt_rec.transaction_quantity;

        IF (l_primary_quantity > l_new_primary_quantity)                                                -- new quantity detailed completely
                                                         -- and there is remaining lot qty
                                                         THEN
          l_mtlt_rec.transaction_temp_id   := l_new_transaction_temp_id;
          l_mtlt_rec.primary_quantity      := l_new_primary_quantity;
          l_mtlt_rec.transaction_quantity  := l_transaction_quantity * l_new_primary_quantity / l_primary_quantity;

          IF l_mtlt_rec.secondary_unit_of_measure IS NOT NULL THEN
             --- Calculate secondary qty
             GML_MOBILE_RECEIPT.Calculate_Secondary_Qty(
                               p_item_no => l_item_no,
                               p_unit_of_measure => l_unit_of_measure,
                               p_quantity => l_mtlt_rec.transaction_quantity,
                               p_lot_no   =>l_lot_number,
                               p_sublot_no   =>l_sublot_number,
                               p_secondary_unit_of_measure => l_mtlt_rec.secondary_unit_of_measure,
                               x_secondary_quantity => l_mtlt_rec.secondary_quantity);
          END IF;



          insert_mtlt(l_mtlt_rec); -- insert one line with new quantity and new txn_id

          l_primary_quantity               := l_primary_quantity - l_new_primary_quantity;
          l_transaction_quantity           := l_transaction_quantity - l_mtlt_rec.transaction_quantity;

          -- Update the existing lot rec with reduced quantity


          IF l_mtlt_rec.secondary_unit_of_measure IS NOT NULL THEN
             --- Calculate secondary qty
             GML_MOBILE_RECEIPT.Calculate_Secondary_Qty(
                               p_item_no => l_item_no,
                               p_unit_of_measure => l_unit_of_measure,
                               p_quantity => l_transaction_quantity,
                               p_lot_no   =>l_lot_number,
                               p_sublot_no   =>l_sublot_number,
                               p_secondary_unit_of_measure => l_mtlt_rec.secondary_unit_of_measure,
                               x_secondary_quantity => l_secondary_quantity);
          END IF;

          IF l_sublot_number IS NULL OR l_sublot_number = '' THEN
            UPDATE mtl_transaction_lots_temp
             SET primary_quantity = l_primary_quantity
               , transaction_quantity = l_transaction_quantity
               , secondary_quantity = l_secondary_quantity
             WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;
          ELSE
            UPDATE mtl_transaction_lots_temp
             SET primary_quantity = l_primary_quantity
               , transaction_quantity = l_transaction_quantity
               , secondary_quantity = l_secondary_quantity
             WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND sublot_num = l_sublot_number
             AND ROWID = l_rowid;
          END IF;

          EXIT; -- exit lot loop

        ELSIF(l_primary_quantity < l_new_primary_quantity) THEN
          -- new quantity is partially detailed
          -- lot qty is exhausted
          -- need to continue lot loop in this case


          IF l_sublot_number IS NULL OR l_sublot_number = '' THEN
          -- Update the lot rec with new transaction interface ID
            UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
             WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;
          ELSE
            UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
             WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND sublot_num = l_sublot_number
             AND ROWID = l_rowid;
          END IF;

          -- reduce the new qty
          l_new_primary_quantity  := l_new_primary_quantity - l_primary_quantity;
        ELSIF(l_primary_quantity = l_new_primary_quantity) THEN
          -- exact match

          IF l_sublot_number IS NULL OR l_sublot_number = '' THEN
          -- Update the lot rec with new transaction interface ID
            UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
             WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND ROWID = l_rowid;

          ELSE
            UPDATE mtl_transaction_lots_temp
             SET transaction_temp_id = l_new_transaction_temp_id
             WHERE transaction_temp_id = l_transaction_temp_id
             AND lot_number = l_lot_number
             AND sublot_num = l_sublot_number
             AND ROWID = l_rowid;
          END IF;

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


  PROCEDURE BREAK(
    p_original_tid        IN mtl_transaction_lots_temp.transaction_temp_id%TYPE
  , p_new_transactions_tb IN trans_rec_tb_tp
  , p_lot_control_code    IN NUMBER
  , p_serial_control_code IN NUMBER
  ) IS
  BEGIN

    IF break_lots_only(p_original_tid, p_new_transactions_tb) THEN
      NULL;
    END IF;

/** The following is not needed as OPM does not support serials
    IF (p_lot_control_code = 2
        AND p_serial_control_code IN(1)) THEN
      IF break_lots_only(p_original_tid, p_new_transactions_tb) THEN
        NULL;
      END IF;
    --serials not lots
      -- Toshiba Fixes for RMA
    ELSIF(p_lot_control_code = 1
          AND p_serial_control_code NOT IN(1)) THEN
      IF break_serials_only(p_original_tid, p_new_transactions_tb) THEN
        NULL;
      END IF;
    --both lot and serial
    ELSIF(p_lot_control_code = 2
          AND p_serial_control_code NOT IN(1)) THEN
      IF break_lots_serials(p_original_tid, p_new_transactions_tb) THEN
        NULL;
      END IF;
    END IF;
*/
  END BREAK;

END GML_RCV_COMMON_APIS;

/
