--------------------------------------------------------
--  DDL for Package Body INV_TXN_MANAGER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TXN_MANAGER_PUB" AS
/* $Header: INVTXMGB.pls 120.28.12010000.5 2010/02/05 07:19:32 ksaripal ship $ */

  g_pkg_name VARCHAR2(30) := 'INV_TXN_MANAGER_PUB';
  g_interface_id NUMBER;
  g_tree_id NUMBER;
  --------------------------------------------------
-- Private Procedures and Functions
--------------------------------------------------

  /** Following portion of the code is the common objects DECLARATION/DEFINITION
    that are used in the Package **/
  l_error_code          VARCHAR2 (3000);
  l_error_exp           VARCHAR2 (3000);
  l_debug               NUMBER;

  TYPE seg_rec_type IS RECORD (
    colname    VARCHAR2 (30)
  , colvalue   VARCHAR2 (150)
  );

  TYPE bool_array IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

--client_info_org_id NUMBER := -1;
--pjm_installed NUMBER := -1;
  ts_default            NUMBER          := 1;
  ts_save_only          NUMBER          := 2;
  ts_process            NUMBER          := 3;
  salorder              NUMBER          := 2;
  intorder              NUMBER          := 8;
  job_schedule          NUMBER          := 5;
  mds_relief            NUMBER          := 1;
  mps_relief            NUMBER          := 2;
  r_work_order          NUMBER          := 1;
  r_purch_order         NUMBER          := 2;
  r_sales_order         NUMBER          := 3;
  to_be_processed       NUMBER          := 2;
  not_to_be_processed   NUMBER          := 1;
--moved this to INVTXGGS.pls.
--gi_flow_schedule NUMBER := 0 ;
  g_true                NUMBER          := 1;
  g_false               NUMBER          := 0;
  g_userid              NUMBER;

/*FUNCTION getitemid( itemid OUT NUMBER, orgid IN NUMBER, rowid VARCHAR2);
FUNCTION getacctid( acct OUT nocopy NUMBER, orgid IN NUMBER, rowid VARCHAR2);
FUNCTION setorgclientinfo(orgid IN NUMBER);
FUNCTION getlocid(locid OUT nocopy NUMBER, orgid IN NUMBER, subinv NUMBER,
                        rowid VARCHAR2, locctrl NUMBER);
FUNCTION getxlocid(locid OUT nocopy  NUMBER, orgid IN NUMBER, subinv IN VARCHAR2,
                        rowid IN VARCHAR2, locctrl IN NUMBER);
FUNCTION getsrcid(trxsrc OUT nocopy  NUMBER, srctype IN NUMBER, orgid IN NUMBER,
                        rowid IN VARCHAR2);
PROCEDURE errupdate(rowid IN VARCHAR2);
FUNCTION lotcheck(rowid IN VARCHAR2, orgid IN NUMBER, itemid IN NUMBER, intid IN NUMBER,
                      priuom IN VARCHAR2, trxuom VARCHAR2, lotuniq IN NUMBER,
                      shlfcode IN NUMBER, shlfdays IN NUMBER, serctrl IN NUMBER,
          srctype IN NUMBER, acttype IN NUMBER);
FUNCTION validate_loc_for_project(ltv_locid IN NUMBER, ltv_orgid IN NUMBER,
                                     ltv_srctype IN NUMBER, ltv_trxact IN NUMBER,
                                     ltv_trx_src_id IN NUMBER, tev_flow_schedule  IN NUMBER);
FUNCTION validate_unit_number(unit_number IN NUMBER, orgid IN NUMBER,
                                 itemid IN NUMBER, srctype IN NUMBER, acttype IN NUMBER);
*/
  TYPE seg_arr_type IS TABLE OF seg_rec_type
    INDEX BY BINARY_INTEGER;

--TYPE segment_array IS TABLE OF segment_rec_type INDEX BY BINARY_INTEGER;
  TYPE segment_array IS TABLE OF VARCHAR2 (200);



/******************************************************************
 *
 * loaderrmsg
 *
 ******************************************************************/
  PROCEDURE loaderrmsg (mesg1 IN VARCHAR2, mesg2 IN VARCHAR2)
  IS
  BEGIN
    fnd_message.set_name ('INV', mesg1);
    l_error_code := fnd_message.get;
    fnd_message.set_name ('INV', mesg2);
    l_error_exp := fnd_message.get;
  END;

/*******************************************************************
 * LotTrxInsert(p_transaction_interface_id IN NUMBER)
 * Added this function to process lot split, merge and translate.
   * As part of J-dev, we will bypass this API.
   * This API has been onbsoleted.
   * we will use tmpinsert() to move records.
 *******************************************************************/

  /** end of lot transactions changes **/

  /******************************************************************
 * Check_Partial_Split - private procedure to check if the lot split
 * transaction is a partial split, i.e., there are remaining qty
 * in the parent lots. In this case, we need to insert additional
 * record in mmtt for the remaining qty
 * This procedure assumes that the primary qty is already calculated
 * and the qty comparison is done with the primary qty.
 * This procedure is called after calling LotTrxInsert
 * As part of J-dev, we will use tmpInsert to
 * move lot transaction records from MTI to MMTT. (also for I)
 * Some changes have been made in this API  for I + J, to enable bulk
 * insert. do not re-insert the parent transaction.
 *  do not insert into MMTT here, but into MTI only, if we are
 *  creating a new record for this transaction
 *
 *  CHANGES FOR OSFM SUPPORT FOR SERIALIZED LOT ITEMS:
 *  Store all the resulting serials into l_rs_serial_tbl.
 *  Loop through the source Serials. If the serial is not present in
 *  l_rs_serial_tbl then add the serial to p_rem_serial_tbl.
 *  End Loop
 *  Loop through the p_rem_serial_tbl
 *   insert MSNI for that serial
 *  End Loop
 *  Update the MTLI with serial_txn_temp_id for the serials inserted
 *  into MSNI.
 *******************************************************************/


FUNCTION check_partial_split (p_parent_id IN NUMBER, p_current_index IN NUMBER)
  RETURN BOOLEAN
IS
  CURSOR mti_csr (p_interface_id NUMBER)
  IS
    SELECT mti.transaction_header_id
         , mti.acct_period_id
         , mti.distribution_account_id
         , mti.transaction_interface_id
         , mti.transaction_type_id
         , mti.source_code
         , mti.source_line_id
         , mti.source_header_id
         , mti.inventory_item_id
         , mti.revision
         , mti.organization_id
         , mti.subinventory_code
         , mti.locator_id
         , mti.transaction_quantity
         , mti.primary_quantity
         , mti.transaction_uom
         , mti.lpn_id
         , mti.transfer_lpn_id
         , mti.cost_group_id
         , mti.transaction_source_type_id
         , mti.transaction_action_id
         , mti.parent_id
         , mti.created_by
         , mtli.lot_number
         , mtli.lot_expiration_date
         , mtli.description
         , mtli.vendor_id
         , mtli.supplier_lot_number
         , mtli.territory_code
         , mtli.grade_code
         , mtli.origination_date
         , mtli.date_code
         , mtli.status_id
         , mtli.change_date
         , mtli.age
         , mtli.retest_date
         , mtli.maturity_date
         , mtli.lot_attribute_category
         , mtli.item_size
         , mtli.color
         , mtli.volume
         , mtli.volume_uom
         , mtli.place_of_origin
         , mtli.best_by_date
         , mtli.LENGTH
         , mtli.length_uom
         , mtli.recycled_content
         , mtli.thickness
         , mtli.thickness_uom
         , mtli.width
         , mtli.width_uom
         , mtli.curl_wrinkle_fold
         , mtli.c_attribute1
         , mtli.c_attribute2
         , mtli.c_attribute3
         , mtli.c_attribute4
         , mtli.c_attribute5
         , mtli.c_attribute6
         , mtli.c_attribute7
         , mtli.c_attribute8
         , mtli.c_attribute9
         , mtli.c_attribute10
         , mtli.c_attribute11
         , mtli.c_attribute12
         , mtli.c_attribute13
         , mtli.c_attribute14
         , mtli.c_attribute15
         , mtli.c_attribute16
         , mtli.c_attribute17
         , mtli.c_attribute18
         , mtli.c_attribute19
         , mtli.c_attribute20
         , mtli.d_attribute1
         , mtli.d_attribute2
         , mtli.d_attribute3
         , mtli.d_attribute4
         , mtli.d_attribute5
         , mtli.d_attribute6
         , mtli.d_attribute7
         , mtli.d_attribute8
         , mtli.d_attribute9
         , mtli.d_attribute10
         , mtli.n_attribute1
         , mtli.n_attribute2
         , mtli.n_attribute3
         , mtli.n_attribute4
         , mtli.n_attribute5
         , mtli.n_attribute6
         , mtli.n_attribute7
         , mtli.n_attribute8
         , mtli.n_attribute9
         , mtli.n_attribute10
         , mtli.attribute1
         , mtli.attribute2
         , mtli.attribute3
         , mtli.attribute4
         , mtli.attribute5
         , mtli.attribute6
         , mtli.attribute7
         , mtli.attribute8
         , mtli.attribute9
         , mtli.attribute10
         , mtli.attribute11
         , mtli.attribute12
         , mtli.attribute13
         , mtli.attribute14
         , mtli.attribute15
         , mtli.attribute_category
         , mtli.parent_object_type      --R12 Genealogy enhancements
         , mtli.parent_object_id        --R12 Genealogy enhancements
         , mtli.parent_object_number    --R12 Genealogy enhancements
         , mtli.parent_item_id          --R12 Genealogy enhancements
         , mtli.parent_object_type2     --R12 Genealogy enhancements
         , mtli.parent_object_id2       --R12 Genealogy enhancements
         , mtli.parent_object_number2   --R12 Genealogy enhancements
         , msi.description item_description
         , msi.location_control_code
         , msi.restrict_subinventories_code
         , msi.restrict_locators_code
         , msi.revision_qty_control_code
         , msi.primary_uom_code
         , msi.shelf_life_code
         , msi.shelf_life_days
         , msi.allowed_units_lookup_code
         , mti.transaction_batch_id
         , mti.transaction_batch_seq
         , mti.kanban_card_id
         , mti.transaction_mode                                        --J-dev
      FROM mtl_transactions_interface mti
         , mtl_transaction_lots_interface mtli
         , mtl_system_items_b msi
     WHERE mti.transaction_interface_id = p_interface_id
       AND mti.transaction_interface_id = mtli.transaction_interface_id
       AND mti.organization_id = msi.organization_id
       AND mti.inventory_item_id = msi.inventory_item_id
       AND mti.process_flag = 1;

  CURSOR msni_csr (p_serial_number VARCHAR2, p_parent_id NUMBER)
  IS
    SELECT transaction_interface_id
         , last_update_login
         , created_by
         , last_updated_by
         , request_id
         , program_application_id
         , program_id
         , program_update_date
         , vendor_serial_number
         , vendor_lot_number
         , fm_serial_number
         , to_serial_number
         , parent_serial_number
         , serial_attribute_category
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
         , attribute_category
         , attribute1
         , attribute2
         , attribute3
         , attribute4
         , attribute5
         , attribute6
         , attribute7
         , attribute8
         , attribute9
         , attribute10
         , attribute11
         , attribute12
         , attribute13
         , attribute14
         , attribute15
         , status_id
         , territory_code
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
         , parent_object_type       --R12 Genealogy enhancements
         , parent_object_id         --R12 Genealogy enhancements
         , parent_object_number     --R12 Genealogy enhancements
         , parent_item_id           --R12 Genealogy enhancements
         , parent_object_type2      --R12 Genealogy enhancements
         , parent_object_id2        --R12 Genealogy enhancements
         , parent_object_number2    --R12 Genealogy enhancements
      FROM mtl_serial_numbers_interface msni
     WHERE msni.transaction_interface_id =
                       (SELECT serial_transaction_temp_id
                          FROM mtl_transaction_lots_interface mtli
                         WHERE mtli.transaction_interface_id = p_parent_id)
       AND inv_serial_number_pub.get_serial_diff (msni.fm_serial_number
                                                , p_serial_number
                                                 ) <> -1
       AND inv_serial_number_pub.get_serial_diff (msni.fm_serial_number
                                                , NVL (msni.to_serial_number
                                                     , msni.fm_serial_number
                                                      )
                                                 ) >=
             inv_serial_number_pub.get_serial_diff (msni.fm_serial_number
                                                  , p_serial_number
                                                   );
  l_msni_csr  msni_csr%ROWTYPE;

  /*This cursor will get the serials for the resulting lots*/
  CURSOR msni_rs_serials_csr (p_parent_id NUMBER)
  IS
    SELECT fm_serial_number
         , NVL (to_serial_number, fm_serial_number) to_serial_number
      FROM mtl_serial_numbers_interface msni
     WHERE msni.transaction_interface_id IN (
             SELECT serial_transaction_temp_id
               FROM mtl_transaction_lots_interface mtli
              WHERE mtli.transaction_interface_id IN (
                      SELECT transaction_interface_id
                        FROM mtl_transactions_interface mti
                       WHERE mti.parent_id = p_parent_id
                         AND mti.transaction_interface_id <> mti.parent_id));

  l_msni_rs_serials_csr        msni_rs_serials_csr%ROWTYPE;

  /*This cursor will get the serials for the starting lots*/
  CURSOR msni_st_serials_csr (p_parent_id NUMBER)
  IS
    SELECT fm_serial_number
         , NVL (to_serial_number, fm_serial_number) to_serial_number
      FROM mtl_serial_numbers_interface msni
     WHERE msni.transaction_interface_id =
             (SELECT serial_transaction_temp_id
                FROM mtl_transaction_lots_interface mtli
               WHERE mtli.transaction_interface_id =
                       (SELECT transaction_interface_id
                          FROM mtl_transactions_interface mti
                         WHERE mti.parent_id = p_parent_id
                           AND mti.transaction_interface_id = mti.parent_id));

  l_msni_st_serials_csr        msni_st_serials_csr%ROWTYPE;
  l_frm_serial                 VARCHAR2 (30);
  l_to_serial                  VARCHAR2 (30);
  l_st_serial_tbl              inv_lot_trx_validation_pub.serial_number_table;
  l_rs_serial_tbl              inv_lot_trx_validation_pub.serial_number_table;
  l_rem_serial_tbl             inv_lot_trx_validation_pub.serial_number_table;
  l_count                      NUMBER                                     := 0;
  l_partial_total_qty          NUMBER                                     := 0;
  l_remaining_qty              NUMBER                                     := 0;
  l_split_qty                  NUMBER                                     := 0;
  l_split_uom                  VARCHAR2 (3);
  l_transaction_interface_id   NUMBER;                                 --J-dev
  l_serial_code                NUMBER;
  l_serial_diff                NUMBER;
  l_sysdate                    DATE;
  l_rem_var_index              mtl_serial_numbers.serial_number%TYPE;
  l_next_serial                VARCHAR2(30);
  l_old_serial                 VARCHAR2(30);
  l_sequence                   NUMBER;
BEGIN
  IF (l_debug = 1)
  THEN
    inv_log_util.TRACE ('l_breadcrumb 10', 'INV_TXN_MANAGER_PUB', '9');
  END IF;
  l_sysdate := SYSDATE;
  SELECT COUNT (parent_id)
    INTO l_count
    FROM mtl_transactions_interface
   WHERE parent_id = p_parent_id;

  SELECT ABS (primary_quantity)
    INTO l_split_qty
    FROM mtl_transactions_interface
   WHERE transaction_interface_id = p_parent_id;

  SELECT SUM (ABS (primary_quantity))
    INTO l_partial_total_qty
    FROM mtl_transactions_interface
   WHERE parent_id = p_parent_id AND transaction_interface_id <> p_parent_id;

  l_remaining_qty := l_split_qty - l_partial_total_qty;

    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE ('l_remaining_qty '|| l_remaining_qty, 'INV_TXN_MANAGER_PUB', '9');
      inv_log_util.TRACE ('l_partial_total_qty '|| l_partial_total_qty, 'INV_TXN_MANAGER_PUB', '9');
      inv_log_util.TRACE ('l_split_qty '|| l_split_qty, 'INV_TXN_MANAGER_PUB', '9');
      inv_log_util.TRACE ('p_current_index '|| p_current_index, 'INV_TXN_MANAGER_PUB', '9');
      inv_log_util.TRACE ('l_count '|| l_count, 'INV_TXN_MANAGER_PUB', '9');
    END IF;

  IF (p_current_index = l_count AND l_remaining_qty > 0)
  THEN
    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_transaction_interface_id                                  --J-dev
      FROM DUAL;

    --shuld execute only once
    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE ('l_breadcrumb 20', 'INV_TXN_MANAGER_PUB', '9');
    END IF;

    FOR l_mti_csr IN mti_csr (p_parent_id)
    LOOP
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('l_breadcrumb 30', 'INV_TXN_MANAGER_PUB', '9');
      END IF;

      INSERT INTO mtl_transactions_interface
                  (transaction_header_id
                 , transaction_interface_id
                 , transaction_mode
                 , lock_flag
                 , source_code
                 , source_line_id
                 , source_header_id
                 , process_flag
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , inventory_item_id
                 , revision
                 , organization_id
                 , subinventory_code
                 , locator_id
                 , transaction_quantity
                 , primary_quantity
                 , transaction_uom
                 , transaction_type_id
                 , transaction_action_id
                 , transaction_source_type_id
                 , transaction_date
                 , acct_period_id
                 , distribution_account_id
                 ,
                   /*item_description ,
                   item_location_control_code ,
                   item_restrict_subinv_code
                   ,item_restrict_locators_code ,
                   item_revision_qty_control_code ,
                   item_primary_uom_code
                   ,item_shelf_life_code ,
                   item_shelf_life_days ,
                   item_lot_control_code
                   ,item_serial_control_code ,
                   allowed_units_lookup_code,*/--J-dev not in MTI
                   parent_id
                 ,                                                     --J-dev
                   lpn_id
                 , transfer_lpn_id
                 , cost_group_id
                 , transaction_batch_id
                 , transaction_batch_seq
                 , kanban_card_id
                  )
           VALUES (l_mti_csr.transaction_header_id
                 , l_transaction_interface_id
                 ,                                                     --J-dev
                   l_mti_csr.transaction_mode                     /*2722754 */
                 , 2
                 , l_mti_csr.source_code
                 , l_mti_csr.source_line_id
                 , l_mti_csr.source_header_id
                 ,                                                     --J-dev
                   1
                 ,                                                     --J-dev
                   l_sysdate
                 , l_mti_csr.created_by
                 , l_sysdate
                 , l_mti_csr.created_by
                 , l_mti_csr.created_by
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , l_mti_csr.inventory_item_id
                 , l_mti_csr.revision
                 , l_mti_csr.organization_id
                 , l_mti_csr.subinventory_code
                 , l_mti_csr.locator_id
                 , l_remaining_qty
                 , l_remaining_qty
                 , l_mti_csr.primary_uom_code
                 , l_mti_csr.transaction_type_id
                 , l_mti_csr.transaction_action_id
                 , l_mti_csr.transaction_source_type_id
                 , l_sysdate
                 , l_mti_csr.acct_period_id
                 , l_mti_csr.distribution_account_id
                 ,
                   /*l_mti_csr.item_description,
                   l_mti_csr.location_control_code,
                   l_mti_csr.restrict_subinventories_code,
                   l_mti_csr.restrict_locators_code,
                   l_mti_csr.revision_qty_control_code,
                   l_mti_csr.primary_uom_code,
                   l_mti_csr.shelf_life_code,
                   l_mti_csr.shelf_life_days,
                   2,
                   1,
                   l_mti_csr.allowed_units_lookup_code,*/--J-dev Not in MTI
                   l_mti_csr.parent_id
                 , null--l_mti_csr.lpn_id
                 , l_mti_csr.lpn_id
                 , l_mti_csr.cost_group_id
                 , l_mti_csr.transaction_batch_id
                 , l_mti_csr.transaction_batch_seq
                 , l_mti_csr.kanban_card_id
                  );

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('l_breadcrumb 40', 'INV_TXN_MANAGER_PUB', '9');
      END IF;

      INSERT INTO mtl_transaction_lots_interface
                  (transaction_interface_id                            --J-dev
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
                 , description
                 , vendor_id
                 , supplier_lot_number
                 , territory_code
                 , grade_code
                 , origination_date
                 , date_code
                 , status_id
                 , change_date
                 , age
                 , retest_date
                 , maturity_date
                 , lot_attribute_category
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
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , attribute_category
                 , parent_object_type       --R12 Genealogy enhancements
                 , parent_object_id         --R12 Genealogy enhancements
                 , parent_object_number     --R12 Genealogy enhancements
                 , parent_item_id           --R12 Genealogy enhancements
                 , parent_object_type2      --R12 Genealogy enhancements
                 , parent_object_id2        --R12 Genealogy enhancements
                 , parent_object_number2    --R12 Genealogy enhancements
                 )
           VALUES (l_transaction_interface_id
                 , l_sysdate
                 , l_mti_csr.created_by
                 , l_sysdate
                 , l_mti_csr.created_by
                 , l_mti_csr.created_by
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , l_remaining_qty
                 , l_remaining_qty
                 , l_mti_csr.lot_number
                 , l_mti_csr.lot_expiration_date
                 , l_mti_csr.description
                 , l_mti_csr.vendor_id
                 , l_mti_csr.supplier_lot_number
                 , l_mti_csr.territory_code
                 , l_mti_csr.grade_code
                 , l_mti_csr.origination_date
                 , l_mti_csr.date_code
                 , l_mti_csr.status_id
                 , l_mti_csr.change_date
                 , l_mti_csr.age
                 , l_mti_csr.retest_date
                 , l_mti_csr.maturity_date
                 , l_mti_csr.lot_attribute_category
                 , l_mti_csr.item_size
                 , l_mti_csr.color
                 , l_mti_csr.volume
                 , l_mti_csr.volume_uom
                 , l_mti_csr.place_of_origin
                 , l_mti_csr.best_by_date
                 , l_mti_csr.LENGTH
                 , l_mti_csr.length_uom
                 , l_mti_csr.recycled_content
                 , l_mti_csr.thickness
                 , l_mti_csr.thickness_uom
                 , l_mti_csr.width
                 , l_mti_csr.width_uom
                 , l_mti_csr.curl_wrinkle_fold
                 , l_mti_csr.c_attribute1
                 , l_mti_csr.c_attribute2
                 , l_mti_csr.c_attribute3
                 , l_mti_csr.c_attribute4
                 , l_mti_csr.c_attribute5
                 , l_mti_csr.c_attribute6
                 , l_mti_csr.c_attribute7
                 , l_mti_csr.c_attribute8
                 , l_mti_csr.c_attribute9
                 , l_mti_csr.c_attribute10
                 , l_mti_csr.c_attribute11
                 , l_mti_csr.c_attribute12
                 , l_mti_csr.c_attribute13
                 , l_mti_csr.c_attribute14
                 , l_mti_csr.c_attribute15
                 , l_mti_csr.c_attribute16
                 , l_mti_csr.c_attribute17
                 , l_mti_csr.c_attribute18
                 , l_mti_csr.c_attribute19
                 , l_mti_csr.c_attribute20
                 , l_mti_csr.d_attribute1
                 , l_mti_csr.d_attribute2
                 , l_mti_csr.d_attribute3
                 , l_mti_csr.d_attribute4
                 , l_mti_csr.d_attribute5
                 , l_mti_csr.d_attribute6
                 , l_mti_csr.d_attribute7
                 , l_mti_csr.d_attribute8
                 , l_mti_csr.d_attribute9
                 , l_mti_csr.d_attribute10
                 , l_mti_csr.n_attribute1
                 , l_mti_csr.n_attribute2
                 , l_mti_csr.n_attribute3
                 , l_mti_csr.n_attribute4
                 , l_mti_csr.n_attribute5
                 , l_mti_csr.n_attribute6
                 , l_mti_csr.n_attribute7
                 , l_mti_csr.n_attribute8
                 , l_mti_csr.n_attribute9
                 , l_mti_csr.n_attribute10
                 , l_mti_csr.attribute1
                 , l_mti_csr.attribute2
                 , l_mti_csr.attribute3
                 , l_mti_csr.attribute4
                 , l_mti_csr.attribute5
                 , l_mti_csr.attribute6
                 , l_mti_csr.attribute7
                 , l_mti_csr.attribute8
                 , l_mti_csr.attribute9
                 , l_mti_csr.attribute10
                 , l_mti_csr.attribute11
                 , l_mti_csr.attribute12
                 , l_mti_csr.attribute13
                 , l_mti_csr.attribute14
                 , l_mti_csr.attribute15
                 , l_mti_csr.attribute_category
                 , l_mti_csr.parent_object_type       --R12 Genealogy enhancements
                 , l_mti_csr.parent_object_id         --R12 Genealogy enhancements
                 , l_mti_csr.parent_object_number     --R12 Genealogy enhancements
                 , l_mti_csr.parent_item_id           --R12 Genealogy enhancements
                 , l_mti_csr.parent_object_type2      --R12 Genealogy enhancements
                 , l_mti_csr.parent_object_id2        --R12 Genealogy enhancements
                 , l_mti_csr.parent_object_number2    --R12 Genealogy enhancements
                 );

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('l_breadcrumb 50', 'INV_TXN_MANAGER_PUB', '9');
      END IF;

      /*loop through the serials that have been left out ....
        try copying everything from the parent MSNIs*/
      BEGIN
        SELECT serial_number_control_code
          INTO l_serial_code
          FROM mtl_system_items
         WHERE inventory_item_id = l_mti_csr.inventory_item_id
           AND organization_id = l_mti_csr.organization_id;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE ('Serial control code => ' || l_serial_code
                            , 'INV_TXN_MANAGER_PUB'
                            , '9'
                             );
          inv_log_util.TRACE ('l_breadcrumb 60', 'INV_TXN_MANAGER_PUB', '9');
        END IF;

        IF (l_serial_code IN (2, 5))
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('l_breadcrumb 70', 'INV_TXN_MANAGER_PUB'
                              , '9');
          END IF;

          FOR l_msni_rs_serials_csr IN msni_rs_serials_csr (p_parent_id)
          LOOP
            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('l_breadcrumb 80'
                                , 'INV_TXN_MANAGER_PUB'
                                , '9'
                                 );
            END IF;

            l_serial_diff :=
              inv_serial_number_pub.get_serial_diff
                                      (l_msni_rs_serials_csr.fm_serial_number
                                     , l_msni_rs_serials_csr.to_serial_number
                                      );

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('Serial diff => ' || l_serial_diff
                                , 'INV_TXN_MANAGER_PUB'
                                , '9'
                                 );
            END IF;

            IF (l_serial_diff = -1)
            THEN
              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('Error in get_serial_diff '
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
              END IF;

              fnd_message.set_name ('INV', 'INV_INVALID_SERIAL_RANGE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_next_serial := l_msni_rs_serials_csr.fm_serial_number;

            FOR i IN 1 .. l_serial_diff
            LOOP
              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('l_breadcrumb 90'
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
              END IF;

              l_rs_serial_tbl (l_next_serial) := l_next_serial;
              l_old_serial := l_next_serial;
              l_next_serial :=
                inv_serial_number_pub.increment_ser_num (l_old_serial
                                                             , 1);

              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('l_next_serial =>  ' || l_next_serial
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
              END IF;

              IF (l_old_serial = l_next_serial)
              THEN
                IF (l_debug = 1)
                THEN
                  inv_log_util.TRACE ('Error in increment_serial_number'
                                    , 'INV_TXN_MANAGER_PUB'
                                    , '9'
                                     );
                END IF;

                fnd_message.set_name ('INV', 'INVALID_SERIAL_NUMBER');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END LOOP;
          END LOOP;

          /*Get the serials in the source lot and see if they are present in l_rs_serial_tbl
           *If not then add them to l_rem_serial_tbl
           */
          FOR l_msni_st_serials_csr IN msni_st_serials_csr (p_parent_id)
          LOOP
            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('l_breadcrumb 100'
                                , 'INV_TXN_MANAGER_PUB'
                                , '9'
                                 );
            END IF;

            l_serial_diff :=
              inv_serial_number_pub.get_serial_diff
                                      (l_msni_st_serials_csr.fm_serial_number
                                     , l_msni_st_serials_csr.to_serial_number
                                      );

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('Serial diff => ' || l_serial_diff
                                , 'INV_TXN_MANAGER_PUB'
                                , '9'
                                 );
            END IF;

            IF (l_serial_diff = -1)
            THEN
              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('Error in get_serial_diff '
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
              END IF;

              fnd_message.set_name ('INV', 'INV_INVALID_SERIAL_RANGE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            l_next_serial := l_msni_st_serials_csr.fm_serial_number;

            FOR i IN 1 .. l_serial_diff
            LOOP
              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('l_breadcrumb 110'
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
                inv_log_util.TRACE ('l_next_serial => '|| l_next_serial
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
              END IF;

              BEGIN
              IF (l_rs_serial_tbl (l_next_serial) IS NULL)
              THEN
                l_rem_serial_tbl (l_next_serial) := l_next_serial;
              END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_rem_serial_tbl (l_next_serial) := l_next_serial;
                  IF (l_debug = 1)
                  THEN
                  inv_log_util.TRACE (   'Serial => '
                                      || l_next_serial
                                      || ' is not present'
                                    , 'INV_TXN_MANAGER_PUB'
                                    , '9'
                                     );
                  END IF;
              END;
              l_old_serial := l_next_serial;
              l_next_serial :=
                inv_serial_number_pub.increment_ser_num (l_old_serial
                                                             , 1);

              IF (l_old_serial = l_next_serial)
              THEN
                IF (l_debug = 1)
                THEN
                  inv_log_util.TRACE ('Error in increment_serial_number '
                                    , 'INV_TXN_MANAGER_PUB'
                                    , '9'
                                     );
                END IF;

                fnd_message.set_name ('INV', 'INVALID_SERIAL_NUMBER');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_unexpected_error;
              END IF;
            END LOOP;
          END LOOP;

          l_rem_var_index := l_rem_serial_tbl.FIRST;

          SELECT mtl_material_transactions_s.NEXTVAL
            INTO l_sequence
            FROM DUAL;

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('l_breadcrumb 120'
                              , 'INV_TXN_MANAGER_PUB'
                              , '9'
                               );
          END IF;

          FOR i IN 1 .. l_rem_serial_tbl.COUNT
          LOOP
            OPEN msni_csr (l_rem_serial_tbl (l_rem_var_index), p_parent_id);

            FETCH msni_csr
             INTO l_msni_csr;

            IF (msni_csr%ROWCOUNT = 0)
            THEN
              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('No data found in msni_csr '
                                  , 'INV_TXN_MANAGER_PUB'
                                  , '9'
                                   );
              END IF;

              RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('Inseritng into MSNI '
                                , 'INV_TXN_MANAGER_PUB'
                                , '9'
                                 );
            END IF;

            INSERT INTO mtl_serial_numbers_interface
                        (transaction_interface_id
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
                       , parent_serial_number
                       , serial_attribute_category
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
                       , attribute_category
                       , attribute1
                       , attribute2
                       , attribute3
                       , attribute4
                       , attribute5
                       , attribute6
                       , attribute7
                       , attribute8
                       , attribute9
                       , attribute10
                       , attribute11
                       , attribute12
                       , attribute13
                       , attribute14
                       , attribute15
                       , status_id
                       , territory_code
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
                       , parent_object_type       --R12 Genealogy enhancements
                       , parent_object_id         --R12 Genealogy enhancements
                       , parent_object_number     --R12 Genealogy enhancements
                       , parent_item_id           --R12 Genealogy enhancements
                       , parent_object_type2      --R12 Genealogy enhancements
                       , parent_object_id2        --R12 Genealogy enhancements
                       , parent_object_number2    --R12 Genealogy enhancements
                        )
                 VALUES (l_sequence
                       , l_sysdate
                       , l_msni_csr.last_updated_by
                       , l_sysdate
                       , l_msni_csr.created_by
                       , l_msni_csr.last_update_login
                       , l_msni_csr.request_id
                       , l_msni_csr.program_application_id
                       , l_msni_csr.program_id
                       , l_msni_csr.program_update_date
                       , l_msni_csr.vendor_serial_number
                       , l_msni_csr.vendor_lot_number
                       --Serial remaining
            ,            l_rem_serial_tbl (l_rem_var_index)
                       , l_rem_serial_tbl (l_rem_var_index)
                       , l_msni_csr.parent_serial_number
                       , l_msni_csr.serial_attribute_category
                       , l_msni_csr.c_attribute1
                       , l_msni_csr.c_attribute2
                       , l_msni_csr.c_attribute3
                       , l_msni_csr.c_attribute4
                       , l_msni_csr.c_attribute5
                       , l_msni_csr.c_attribute6
                       , l_msni_csr.c_attribute7
                       , l_msni_csr.c_attribute8
                       , l_msni_csr.c_attribute9
                       , l_msni_csr.c_attribute10
                       , l_msni_csr.c_attribute11
                       , l_msni_csr.c_attribute12
                       , l_msni_csr.c_attribute13
                       , l_msni_csr.c_attribute14
                       , l_msni_csr.c_attribute15
                       , l_msni_csr.c_attribute16
                       , l_msni_csr.c_attribute17
                       , l_msni_csr.c_attribute18
                       , l_msni_csr.c_attribute19
                       , l_msni_csr.c_attribute20
                       , l_msni_csr.d_attribute1
                       , l_msni_csr.d_attribute2
                       , l_msni_csr.d_attribute3
                       , l_msni_csr.d_attribute4
                       , l_msni_csr.d_attribute5
                       , l_msni_csr.d_attribute6
                       , l_msni_csr.d_attribute7
                       , l_msni_csr.d_attribute8
                       , l_msni_csr.d_attribute9
                       , l_msni_csr.d_attribute10
                       , l_msni_csr.n_attribute1
                       , l_msni_csr.n_attribute2
                       , l_msni_csr.n_attribute3
                       , l_msni_csr.n_attribute4
                       , l_msni_csr.n_attribute5
                       , l_msni_csr.n_attribute6
                       , l_msni_csr.n_attribute7
                       , l_msni_csr.n_attribute8
                       , l_msni_csr.n_attribute9
                       , l_msni_csr.n_attribute10
                       , l_msni_csr.attribute_category
                       , l_msni_csr.attribute1
                       , l_msni_csr.attribute2
                       , l_msni_csr.attribute3
                       , l_msni_csr.attribute4
                       , l_msni_csr.attribute5
                       , l_msni_csr.attribute6
                       , l_msni_csr.attribute7
                       , l_msni_csr.attribute8
                       , l_msni_csr.attribute9
                       , l_msni_csr.attribute10
                       , l_msni_csr.attribute11
                       , l_msni_csr.attribute12
                       , l_msni_csr.attribute13
                       , l_msni_csr.attribute14
                       , l_msni_csr.attribute15
                       , l_msni_csr.status_id
                       , l_msni_csr.territory_code
                       , l_msni_csr.time_since_new
                       , l_msni_csr.cycles_since_new
                       , l_msni_csr.time_since_overhaul
                       , l_msni_csr.cycles_since_overhaul
                       , l_msni_csr.time_since_repair
                       , l_msni_csr.cycles_since_repair
                       , l_msni_csr.time_since_visit
                       , l_msni_csr.cycles_since_visit
                       , l_msni_csr.time_since_mark
                       , l_msni_csr.cycles_since_mark
                       , l_msni_csr.number_of_repairs
                       , l_msni_csr.parent_object_type       --R12 Genealogy enhancements
                       , l_msni_csr.parent_object_id         --R12 Genealogy enhancements
                       , l_msni_csr.parent_object_number     --R12 Genealogy enhancements
                       , l_msni_csr.parent_item_id           --R12 Genealogy enhancements
                       , l_msni_csr.parent_object_type2      --R12 Genealogy enhancements
                       , l_msni_csr.parent_object_id2        --R12 Genealogy enhancements
                       , l_msni_csr.parent_object_number2    --R12 Genealogy enhancements
                        );

            IF(msni_csr%ISOPEN) THEN
              CLOSE msni_csr;
            END IF;

            l_rem_var_index := l_rem_serial_tbl.NEXT (l_rem_var_index);
          END LOOP;

          /*Need to update the MTLI with serial_txn_temP_id to connect with the MSNIs*/
          UPDATE mtl_transaction_lots_interface
             SET serial_transaction_temp_id = l_sequence
           WHERE transaction_interface_id = l_transaction_interface_id;
        END IF;                                  --end of is_serial_controlled
      EXCEPTION
        WHEN OTHERS
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE
                      ('Error while inserting in MSNI check_partial_split  '
                     , 'INV_TXN_MANAGER_PUB'
                     , '9'
                      );
          END IF;

          RETURN FALSE;
      END;
    END LOOP;                                                   --End MTI loop
  END IF;

  RETURN TRUE;
EXCEPTION
  WHEN fnd_api.g_exc_error
  THEN
    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                        , 'INV_TXN_MANAGER_PUB'
                        , '9'
                         );
      inv_log_util.TRACE ('Error in check_partial_split : ' || l_error_exp
                        , 'INV_TXN_MANAGER_PUB'
                        , '9'
                         );
    END IF;

    RETURN FALSE;
  WHEN OTHERS
  THEN
    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                        , 'INV_TXN_MANAGER_PUB'
                        , '9'
                         );
      inv_log_util.TRACE ('Error in check_partial_split : ' || l_error_exp
                        , 'INV_TXN_MANAGER_PUB'
                        , '9'
                         );
    END IF;

    RETURN FALSE;
END check_partial_split;

  /* getacctid()
  * moved to group API INV_TXN_MANAGER_GRP()
  ******************************************************************/

  /******************************************************************
-- Procedure moved to group api INV_TXN_MANAGER_GRP
--   getitemid
-- Description
--   find the item_id using the flex field segments
-- Output Parameters
--   x_item_id   locator or null if error occurred
 ******************************************************************/

  /******************************************************************
  -- Procedure moved to group api INV_TXN_MANAGER_GRP
  --   getsrcid
  -- Description
  --   find the Source ID using the flex field segments
  -- Output Parameters
  --   x_trxsrc   transaction source id or null if error occurred
  ******************************************************************/

  /******************************************************************
 *
 * errupdate()
 *
 ******************************************************************/
  PROCEDURE errupdate (p_rowid IN VARCHAR2)
  IS
    l_userid    NUMBER := -1;                           -- = prg_info.userid;
    l_reqstid   NUMBER := -1;                          -- = prg_info.reqstid;
    l_applid    NUMBER := -1;                            -- = prg_info.appid;
    l_progid    NUMBER := -1;                           -- = prg_info.progid;
    l_loginid   NUMBER := -1;                           --= prg_info.loginid;
  BEGIN
    -- WHENEVER NOT FOUND CONTINUE;
    UPDATE mtl_transactions_interface
       SET ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
         , error_explanation = SUBSTRB (l_error_exp, 1, 240)
         , last_update_date = SYSDATE
         , last_updated_by = l_userid
         , last_update_login = l_loginid
         , program_update_date = SYSDATE
         , process_flag = 3
         , lock_flag = 2
     WHERE ROWID = p_rowid;

    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN;
  END errupdate;

/******************************************************************
-- Procedure (moved to group api INV_TXN_MANAGER_GRP)
--   derive_segment_ids
-- Description
--   derive segment-ids  based on segment values
-- Output Parameters
--
 ******************************************************************/

  /******************************************************************
 *
 * validate_group
 * Validate a group of MTI records in a batch together

 * J-dev (WIP related validations)
   * Actual implemetation is mved to INV_TXN_MANAGER_GRP(INVTXGGB.pls)
   * The public spec here, does not accept p_validation_level.
   * if p_validation_level is to be used, the group api has to be invoked.
 ******************************************************************/
  PROCEDURE validate_group (
    p_header_id                    NUMBER
  , x_return_status   OUT NOCOPY   VARCHAR2
  , x_msg_count       OUT NOCOPY   NUMBER
  , x_msg_data        OUT NOCOPY   VARCHAR2
  , p_userid                       NUMBER
  , p_loginid                      NUMBER
  )
  IS
    srctypeid                NUMBER;
    tvu_flow_schedule        VARCHAR2 (50);
    tev_scheduled_flag       NUMBER;
    flow_schedule_children   VARCHAR2 (50);
    l_count                  NUMBER;
    l_profile                VARCHAR2 (100);
    exp_to_ast_allowed       NUMBER;
    exp_type_required        NUMBER;
    numhold                  NUMBER          := 0;
    l_return_status          VARCHAR2 (10)   := fnd_api.g_ret_sts_success;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2 (2000);
  BEGIN
    IF (l_debug IS NULL)
    THEN
      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    END IF;

    inv_txn_manager_grp.validate_group
                             (p_header_id            => p_header_id
                            , x_return_status        => l_return_status
                            , x_msg_count            => l_msg_count
                            , x_msg_data             => l_msg_data
                            , p_userid               => p_userid
                            , p_loginid              => p_loginid
                            , p_validation_level     => fnd_api.g_valid_level_full
                             );
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;

    IF (l_return_status = fnd_api.g_ret_sts_success)
    THEN
      x_return_status := fnd_api.g_ret_sts_success;
    --Bug: 3559328: Performance bug fix. The fnd API to clear is
    --already called in the private API. Since this is just a wrapper,
    --we do not need to call it here as it would alreday have been cleared
    --FND_MESSAGE.clear;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Error in validate_group : ' || l_error_exp
                          , 'INV_TXN_MANAGER_PUB'
                          , '1'
                           );
        inv_log_util.TRACE ('Error:' || SUBSTR (SQLERRM, 1, 250)
                          , 'INV_TXN_MANAGER_PUB'
                          , 1
                           );
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.CLEAR;
  END validate_group;

/******* LINE VALIDATION OBJECTS  ***************/

  /******************************************************************
 *
 * lotcheck moved to group API INV_TXN_MANAGER_GRP
 *
 ******************************************************************/

  /******************************************************************
 *
 * setorgclientinfo() moved to group API INV_TXN_MANAGER_GRP
 *
 ******************************************************************/

  /******************************************************************
-- Function moved to INV_TXN_MANAGER_GRP
--   getloc
-- Description
--   Private function to get Locator id using Flex API's
--   Uses FND_FLEX_KEY_API (AFFFKAIS/B.pls) and
--        FND_FLEX_EXT (AFFFEXTS/B.pls)
--
--   Assumes that only Id's are populated in the MTI segments
--
-- Returns
--   Returns false if any error occurs
-- Output Parameters
--   x_locid   locator or null if error occurred
 ******************************************************************/

  /******************************************************************
-- Function moved to INV_TXN_MANAGER_GRP
--   getlocid
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/

  /******************************************************************
-- Function moved to INV_TXN_MANAGER_GRP
--   getxlocid
-- Description
--   find the locator using the flex field segments
--   Calls private function getLoc to do the work
-- Output Parameters
--   x_locator   locator or null if error occurred
 ******************************************************************/

  /******************************************************************
 *
   * validate_loc_for_project()
   * moved to INV_TXN_MANAGER_GRP
 *
 ******************************************************************/

  /******************************************************************
 *
   * validate_unit_number()
   * moved to INV_TXN_MANAGER_GRP
 *
 ******************************************************************/

  /******************************************************************
 *
 * validate_lines() : Outer
 *
 ******************************************************************/
  PROCEDURE validate_lines (
    p_header_id                       NUMBER
  , p_commit                          VARCHAR2 := fnd_api.g_false
  , p_validation_level                NUMBER := fnd_api.g_valid_level_full
  , x_return_status      OUT NOCOPY   VARCHAR2
  , x_msg_count          OUT NOCOPY   NUMBER
  , x_msg_data           OUT NOCOPY   VARCHAR2
  , p_userid                          NUMBER
  , p_loginid                         NUMBER
  , p_applid                          NUMBER
  , p_progid                          NUMBER
  )
  AS
    CURSOR aa1
    IS
      SELECT   transaction_interface_id
             , transaction_header_id
             , request_id
             , inventory_item_id
             , organization_id
             , subinventory_code
             , transfer_organization
             , transfer_subinventory
             , transaction_uom
             , transaction_date
             , transaction_quantity
             , locator_id
             , transfer_locator
             , transaction_source_id
             , transaction_source_type_id
             , transaction_action_id
             , transaction_type_id
             , distribution_account_id
             , NVL (shippable_flag, 'Y')
             , ROWID
             , new_average_cost
             , value_change
             , percentage_change
             , material_account
             , material_overhead_account
             , resource_account
             , outside_processing_account
             , overhead_account
             , requisition_line_id
             , overcompletion_transaction_qty
             ,                               /* Overcompletion Transactions */
               end_item_unit_number
             , scheduled_payback_date
             ,                                            /* Borrow Payback */
               revision
             ,                                            /* Borrow Payback */
               org_cost_group_id
             ,                                                      /* PCST */
               cost_type_id
             ,                                                      /* PCST */
               primary_quantity
             , source_line_id
             , process_flag
             , transaction_source_name
             , trx_source_delivery_id
             , trx_source_line_id
             , parent_id
             , transaction_batch_id
             , transaction_batch_seq
             ,
             -- INVCONV start fabdi
               secondary_transaction_quantity
             , secondary_uom_code
             -- INVCONV end fabdi
             , SHIP_TO_LOCATION_ID --eIB Build; Bug# 4348541
             , transfer_price      -- OPM INVCONV umoogala Process-Discrete Transfers
             , WIP_ENTITY_TYPE -- Pawan 11th july
             /* Bug:5392366. Added the following two columns.*/
             , completion_transaction_id
             , move_transaction_id
      FROM     mtl_transactions_interface
         WHERE transaction_header_id = p_header_id AND process_flag = 1
      ORDER BY organization_id
             , inventory_item_id
             , revision
             , subinventory_code
             , locator_id;

    line_vldn_error_flag   VARCHAR (1);
    l_line_rec_type        line_rec_type;
    l_count                NUMBER;
  BEGIN
    IF (l_debug IS NULL)
    THEN
      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    END IF;

    fnd_flex_key_api.set_session_mode ('seed_data');

    FOR l_line_rec_type IN aa1
    LOOP
      BEGIN
        SAVEPOINT line_validation_svpt;
        validate_lines (p_line_rec_type        => l_line_rec_type
                      , p_commit               => p_commit
                      , p_validation_level     => p_validation_level
                      , p_error_flag           => line_vldn_error_flag
                      , p_userid               => p_userid
                      , p_loginid              => p_loginid
                      , p_applid               => p_applid
                      , p_progid               => p_progid
                       );

        IF (line_vldn_error_flag = 'Y')
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Error in Line Validatin'
                              , 'INV_TXN_MANAGER_PUB'
                              , 9
                               );
          END IF;
        END IF;
      END;
    END LOOP;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE (   'Error in outer validate_lines'
                            || SUBSTR (SQLERRM, 1, 240)
                          , 'INV_TXN_MANAGER_PUB'
                          , 1
                           );
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
  END validate_lines;

/******************************************************************
 *
 * validate_lines()
 *  Validate one transaction record in MTL_TRANSACTIONS_INTERFACE
 *
 ******************************************************************/
  PROCEDURE validate_lines (
    p_line_rec_type                   line_rec_type
  , p_commit                          VARCHAR2 := fnd_api.g_false
  , p_validation_level                NUMBER := fnd_api.g_valid_level_full
  , p_error_flag         OUT NOCOPY   VARCHAR2
  , p_userid                          NUMBER
  , p_loginid                         NUMBER
  , p_applid                          NUMBER
  , p_progid                          NUMBER
  )
  AS
    l_error_flag   VARCHAR2 (2);
  BEGIN
    IF (l_debug IS NULL)
    THEN
      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    END IF;

    inv_txn_manager_grp.validate_lines
                                    (p_line_rec_type        => p_line_rec_type
                                   , p_error_flag           => l_error_flag
                                   , p_validation_level     => p_validation_level
                                   , p_userid               => p_userid
                                   , p_loginid              => p_loginid
                                   , p_applid               => p_applid
                                   , p_progid               => p_progid
                                    );

    IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Returned from inv_txn_manager_grp.validate_lines'
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;
    p_error_flag := l_error_flag;

    IF (l_error_flag = 'Y')
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Error in Line Validatin'
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      p_error_flag := 'Y';

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Error in validate_line : ' || l_error_exp
                          , 'INV_TXN_MANAGER_PUB'
                          , '1'
                           );
        inv_log_util.TRACE ('Error:' || SUBSTR (SQLERRM, 1, 250)
                          , 'INV_TXN_MANAGER_PUB'
                          , 1
                           );
      END IF;
  END validate_lines;

/******************************************************************
 *
 * get_open_period()
 *
 ******************************************************************/
  FUNCTION get_open_period (
    p_org_id       NUMBER
  , p_trans_date   DATE
  , p_chk_date     NUMBER
  )
    RETURN NUMBER
  IS
    chk_date         NUMBER;
                  /* 0 ignore date,1-return 0 if date doesn't fall in current
                     period, -1 if Oracle error, otherwise period id*/
    trans_date       DATE;                             /* transaction_date */
    acct_period_id   NUMBER;          /* period_close_id of current period */
  BEGIN
    IF (l_debug IS NULL)
    THEN
      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    END IF;

    acct_period_id := 0;                                   /* default value */

    IF (chk_date = 1)
    THEN
      SELECT   acct_period_id
          INTO acct_period_id
          FROM org_acct_periods
         WHERE period_close_date IS NULL
           AND organization_id = p_org_id
           AND NVL (p_trans_date, SYSDATE) BETWEEN period_start_date
                                               AND schedule_close_date
      ORDER BY period_start_date DESC, schedule_close_date ASC;
    ELSE
      SELECT acct_period_id
        INTO acct_period_id
        FROM org_acct_periods
       WHERE period_close_date IS NULL
         AND organization_id = p_org_id
         AND TRUNC (schedule_close_date) >=
                                           TRUNC (NVL (p_trans_date, SYSDATE))
         AND TRUNC (period_start_date) <= TRUNC (NVL (p_trans_date, SYSDATE));
    END IF;

    RETURN (acct_period_id);
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      acct_period_id := 0;
      RETURN (acct_period_id);
    WHEN OTHERS
    THEN
      acct_period_id := -1;
      RETURN (acct_period_id);
  END get_open_period;

/******************************************************************
 *
 * tmpinsert() moved to INV_TXN_MANAGER_GRP
 *
 ******************************************************************/
  FUNCTION tmpinsert (p_header_id IN NUMBER)
    RETURN BOOLEAN
  IS
    l_lt_flow_schedule   NUMBER;
    l_return             BOOLEAN := TRUE;
  BEGIN
    IF (l_debug IS NULL)
    THEN
      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    END IF;

    l_return := inv_txn_manager_grp.tmpinsert (p_header_id => p_header_id);

    IF (l_return)
    THEN

      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE (   'Error in tmpinsert: sqlerrm : '
                            || SUBSTR (SQLERRM, 1, 200)
                          , 'INV_TXN_MANAGER_PUB'
                          , '9'
                           );
      END IF;

      RETURN FALSE;
  END tmpinsert;

/******************************************************************
 *
 * bflushchk()
 *
 ******************************************************************/
  FUNCTION bflushchk (p_txn_hdr_id IN OUT NOCOPY NUMBER)
    RETURN BOOLEAN
  IS
    l_new_hdr_id   NUMBER;                 /* New Assy Backflush Header ID */
    l_old_hdr_id   NUMBER;
  BEGIN
    l_old_hdr_id := p_txn_hdr_id;

    SELECT mtl_material_transactions_s.NEXTVAL
      INTO l_new_hdr_id
      FROM DUAL;

    p_txn_hdr_id := l_new_hdr_id;

    UPDATE mtl_material_transactions_temp
       SET transaction_header_id = l_new_hdr_id
         , lock_flag = 'Y'
     WHERE process_flag = 'Y'
       AND NVL (lock_flag, 'N') = 'N'
       AND transaction_header_id IN (
             SELECT mmtt.transaction_header_id
               FROM mtl_material_transactions mmt
                  , mtl_material_transactions_temp mmtt
              WHERE mmt.transaction_set_id = l_old_hdr_id
                AND mmt.completion_transaction_id =
                                                mmtt.completion_transaction_id);

    IF SQL%NOTFOUND
    THEN
      p_txn_hdr_id := -1;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('*** SQL error ' || SUBSTR (SQLERRM, 1, 200)
                          , 'INV_TXN_MANAGER_GRP'
                          , 9
                           );
      END IF;

      RETURN FALSE;
  END bflushchk;

/******************************************************************
 *
 * poget()
 *
 ******************************************************************/
  PROCEDURE poget (p_prof IN VARCHAR2, x_ret OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    SELECT fnd_profile.VALUE (p_prof)
      INTO x_ret
      FROM DUAL;
  END poget;

/******************************************************************
*
  * process_Transactions()
  *
  ******************************************************************/
  FUNCTION process_transactions (
    p_api_version        IN              NUMBER
  , p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  , p_commit             IN              VARCHAR2 := fnd_api.g_false
  , p_validation_level   IN              NUMBER := fnd_api.g_valid_level_full
  , x_return_status      OUT NOCOPY      VARCHAR2
  , x_msg_count          OUT NOCOPY      NUMBER
  , x_msg_data           OUT NOCOPY      VARCHAR2
  , x_trans_count        OUT NOCOPY      NUMBER
  , p_table              IN              NUMBER := 1
  , p_header_id          IN              NUMBER
  )
    RETURN NUMBER
  IS
    l_header_id                NUMBER;
    l_source_header_id         NUMBER;
    l_totrows                  NUMBER;
    l_initotrows               NUMBER;
    l_midtotrows               NUMBER;
    l_userid                   NUMBER;
    l_loginid                  NUMBER;
    l_progid                   NUMBER;
    l_applid                   NUMBER;
    l_reqstid                  NUMBER;
    l_valreq                   NUMBER;
    l_errd_int_id              NUMBER;
    l_trx_type                 NUMBER;
    l_item_id                  NUMBER;
    l_org_id                   NUMBER;
    l_srctypeid                NUMBER;
    l_tempid                   NUMBER;
    l_actid                    NUMBER;
    l_srcid                    NUMBER;
    l_locid                    NUMBER;
    l_xlocid                   NUMBER;
    l_rctrl                    NUMBER;
    l_lctrl                    NUMBER;
    l_trx_qty                  NUMBER;
    l_qty                      NUMBER          := 0;
    l_aqty                     NUMBER          := 0;
    l_oqty                     NUMBER          := 0;
    l_src_code                 VARCHAR2 (30);
    l_rowid                    VARCHAR2 (21);
    l_sub_code                 VARCHAR2 (11);
    l_xfrsub                   VARCHAR2 (11);
    l_lotnum                   VARCHAR2 (80);
                                         -- changed lot_number to 80,  inconv
    l_rev                      VARCHAR2 (4);
    l_disp                     VARCHAR2 (3000);
    l_message                  VARCHAR2 (100);
    l_source_code              VARCHAR2 (30);
    l_profval                  VARCHAR2 (256);
    l_expbuf                   VARCHAR2 (241);
    l_prfvalue                 VARCHAR2 (10);
    done                       BOOLEAN;
    FIRST                      BOOLEAN;
    tree_exists                BOOLEAN;
    l_result                   NUMBER;
    l_msg_data                 VARCHAR2 (2000);
    line_vldn_error_flag       VARCHAR (1);
    l_line_rec_type            line_rec_type;
    rollback_line_validation   EXCEPTION;
    l_trx_batch_id             NUMBER;
    l_last_trx_batch_id        NUMBER;
    batch_error                BOOLEAN;
    l_process                  NUMBER;
    l_return_status            VARCHAR2 (30);
    l_ret_sts_pre              VARCHAR2 (30);
                             --J-dev for return status if preInvWipProcessing
    l_ret_sts_post             VARCHAR2 (30);
                              --J-dev for return status ifpreInvWipProcessing
    l_source_type_id           NUMBER;  --J-dev used to check if WIP returned
    --successful rows.
    l_batch_count              NUMBER;
    l_dist_acct_id             NUMBER;
    l_batch_size               NUMBER;
                              /*Patchset J:Interface Trip Stop Enhancements*/
    l_wip_entity_type  NUMBER ; /* Pawan Added for gme- convergence*/

    /*Bug 5209598.Added the following fields to perform ATT/ATR checks. */
    l_tree_id NUMBER;
    l_msg_count  NUMBER;
    l_temp_rowid VARCHAR2(21);
    l_srclineid VARCHAR2(40);
    l_trxdate DATE;
    l_neg_inv_rcpt number;
    l_revision_control BOOLEAN;
    l_lot_control BOOLEAN;
    l_dem_hdr_id NUMBER ;
    l_dem_line_id NUMBER;
    l_translate BOOLEAN := TRUE;

    l_qoh NUMBER;
    l_rqoh NUMBER;
    l_pqoh NUMBER;
    l_qr NUMBER;
    l_qs NUMBER;
    l_att NUMBER;
    l_atr NUMBER;

    l_override_neg_for_backflush NUMBER := 0;
    l_override_rsv_for_backflush NUMBER := 2;
    l_item_qoh NUMBER;
    l_item_rqoh NUMBER;
    l_item_pqoh NUMBER;
    l_item_qr NUMBER;
    l_item_qs NUMBER;
    l_item_att NUMBER;
    l_item_atr NUMBER;

    l_current_batch_failed BOOLEAN := FALSE;
    l_current_err_batch_id NUMBER;
    l_count_success NUMBER:=0;

    /*Bug:5276191. Added the following two variables. */
    l_from_project_id NUMBER := null;
    l_serial_control  NUMBER := 1;

    /*Bug 5209598.End of variable declaration. */

    CURSOR aa1
    IS
      SELECT   transaction_interface_id
             , transaction_header_id
             , request_id
             , inventory_item_id
             , organization_id
             , subinventory_code
             , transfer_organization
             , transfer_subinventory
             , transaction_uom
             , transaction_date
             , transaction_quantity
             , locator_id
             , transfer_locator
             , transaction_source_id
             , transaction_source_type_id
             , transaction_action_id
             , transaction_type_id
             , distribution_account_id
             , NVL (shippable_flag, 'Y')
             , ROWID
             , new_average_cost
             , value_change
             , percentage_change
             , material_account
             , material_overhead_account
             , resource_account
             , outside_processing_account
             , overhead_account
             , requisition_line_id
             , overcompletion_transaction_qty
             ,                               /* Overcompletion Transactions */
               end_item_unit_number
             , scheduled_payback_date
             ,                                            /* Borrow Payback */
               revision
             ,                                            /* Borrow Payback */
               org_cost_group_id
             ,                                                      /* PCST */
               cost_type_id
             ,                                                      /* PCST */
               primary_quantity
             , source_line_id
             , process_flag
             , transaction_source_name
             , trx_source_delivery_id
             , trx_source_line_id
             , parent_id
             , transaction_batch_id
             , transaction_batch_seq
             ,
               -- INVCONV start fabdi
               secondary_transaction_quantity
             , secondary_uom_code
          -- INVCONV end fabdi
             , ship_to_location_id --eIB Build; Bug# 4348541
             , transfer_price      -- OPM INVCONV umoogala Process-Discrete Transfers
             , WIP_ENTITY_TYPE -- Pawan  11th july added
             /* Bug:5392366. Added the following two columns.*/
             , completion_transaction_id
             , move_transaction_id
      FROM     mtl_transactions_interface
         WHERE transaction_header_id = p_header_id AND process_flag = 1
      ORDER BY transaction_batch_id
             , transaction_batch_seq
             , organization_id
             , inventory_item_id
             , revision
             , subinventory_code
             , locator_id;

    /*Bug 5209598. Added the following cursor. */
    CURSOR Z1 (p_flow_sch NUMBER,p_line_rec_type inv_txn_manager_pub.line_rec_type) IS
       SELECT
         p_line_rec_type.ROWID,
         p_line_rec_type.INVENTORY_ITEM_ID,
         p_line_rec_type.REVISION,
         p_line_rec_type.ORGANIZATION_ID,
         p_line_rec_type.SUBINVENTORY_CODE,
         p_line_rec_type.LOCATOR_ID,
         ABS(p_line_rec_type.PRIMARY_QUANTITY) PRIMARY_QUANTITY,
         NULL LOT_NUMBER,
         p_line_rec_type.TRANSACTION_SOURCE_TYPE_ID,
         p_line_rec_type.TRANSACTION_ACTION_ID,
         p_line_rec_type.TRANSACTION_SOURCE_ID,
         p_line_rec_type.TRANSACTION_SOURCE_NAME,
         --Jalaj Srivastava 5010595
         --for GME (wip_enity_type=10) select trx_source_line_id as source_line_id
         decode(p_line_rec_type.transaction_source_type_id,5,decode(p_line_rec_type.wip_entity_type,10,p_line_rec_type.TRX_SOURCE_LINE_ID,p_line_rec_type.SOURCE_LINE_ID),p_line_rec_type.SOURCE_LINE_ID) SOURCE_LINE_ID,
         MSI.REVISION_QTY_CONTROL_CODE,
         decode(p_line_rec_type.transaction_source_type_id,5,1,MSI.lot_control_code) lot_control_code,--j-dev
         decode(p_line_rec_type.TRANSACTION_ACTION_ID,2,p_line_rec_type.TRANSFER_SUBINVENTORY,28,p_line_rec_type.TRANSFER_SUBINVENTORY,null) TRANSFER_SUBINVENTORY,
         p_line_rec_type.TRANSFER_LOCATOR,
         p_line_rec_type.transaction_date,
         MP.NEGATIVE_INV_RECEIPT_CODE
    FROM MTL_PARAMETERS MP,
         MTL_SYSTEM_ITEMS MSI
   WHERE MP.ORGANIZATION_ID = p_line_rec_type.ORGANIZATION_ID
    -- AND MP.NEGATIVE_INV_RECEIPT_CODE = 2 'bug 3679189'
     AND p_line_rec_type.PROCESS_FLAG = 1
     AND ((MSI.LOT_CONTROL_CODE = 1) OR (p_line_rec_type.transaction_source_type_id=5 and p_line_rec_type.wip_entity_type <> 10))--J-dev--verify this
     AND (    (     (p_line_rec_type.wip_entity_type <> 10)
                AND (       (p_flow_sch <> 1
                         AND p_line_rec_type.TRANSACTION_ACTION_ID IN (1,2,3,21,32,34,5) )
	              OR    (p_flow_sch = 1
		         AND p_line_rec_type.TRANSACTION_ACTION_ID IN (1, 32) )
	            )
	      )
	   --Jalaj Srivastava 5232394
	   --select all transactions for GME
	   OR (p_line_rec_type.wip_entity_type = 10)
	 )
     AND MSI.ORGANIZATION_ID = MP.ORGANIZATION_ID
     AND MSI.ORGANIZATION_ID = p_line_rec_type.ORGANIZATION_ID
     AND MSI.INVENTORY_ITEM_ID = p_line_rec_type.INVENTORY_ITEM_ID
UNION
     SELECT
       p_line_rec_type.ROWID,
       p_line_rec_type.INVENTORY_ITEM_ID,
       p_line_rec_type.REVISION,
       p_line_rec_type.ORGANIZATION_ID,
       p_line_rec_type.SUBINVENTORY_CODE,
       p_line_rec_type.LOCATOR_ID,
       ABS(MTLI.PRIMARY_QUANTITY) PRIMARY_QUANTITY,
       MTLI.lot_number LOT_NUMBER,
       p_line_rec_type.TRANSACTION_SOURCE_TYPE_ID,
       p_line_rec_type.TRANSACTION_ACTION_ID,
       p_line_rec_type.TRANSACTION_SOURCE_ID,
       p_line_rec_type.TRANSACTION_SOURCE_NAME,
       --Jalaj Srivastava 5010595
       --for GME (wip_enity_type=10) select trx_source_line_id as source_line_id
       decode(p_line_rec_type.wip_entity_type,10,p_line_rec_type.TRX_SOURCE_LINE_ID,p_line_rec_type.SOURCE_LINE_ID) SOURCE_LINE_ID,
       MSI.REVISION_QTY_CONTROL_CODE,
       MSI.lot_control_code lot_control_code,
       decode(p_line_rec_type.TRANSACTION_ACTION_ID,2,p_line_rec_type.TRANSFER_SUBINVENTORY,28,p_line_rec_type.TRANSFER_SUBINVENTORY,5,p_line_rec_type.transfer_subinventory,null) TRANSFER_SUBINVENTORY,
       p_line_rec_type.TRANSFER_LOCATOR,
	 p_line_rec_type.transaction_date,
	 MP.NEGATIVE_INV_RECEIPT_CODE
  FROM MTL_TRANSACTION_LOTS_INTERFACE MTLI,
       MTL_PARAMETERS MP,
       MTL_SYSTEM_ITEMS MSI
 WHERE MP.ORGANIZATION_ID = p_line_rec_type.ORGANIZATION_ID
   --AND MP.NEGATIVE_INV_RECEIPT_CODE = 2 'bug 3679189'
   AND MTLI.TRANSACTION_INTERFACE_ID = p_line_rec_type.TRANSACTION_INTERFACE_ID
   AND p_line_rec_type.PROCESS_FLAG = 1
   AND MSI.LOT_CONTROL_CODE = 2
   AND (    (       (p_line_rec_type.wip_entity_type <> 10)
                AND (       (p_flow_sch <> 1
                         AND p_line_rec_type.TRANSACTION_ACTION_ID IN (1,2,3,21,32,34,5) )
	              OR    (p_flow_sch = 1
		         AND p_line_rec_type.TRANSACTION_ACTION_ID = 32 )
	            )
	    )
	   --Jalaj Srivastava 5232394
	   --select all transactions for GME
	 OR (p_line_rec_type.wip_entity_type = 10)
       )
   AND MSI.ORGANIZATION_ID = MP.ORGANIZATION_ID
   AND MSI.ORGANIZATION_ID = p_line_rec_type.ORGANIZATION_ID
   AND MSI.INVENTORY_ITEM_ID = p_line_rec_type.INVENTORY_ITEM_ID
    -- Pawan  11th july added this for validation of lot for GME only
   AND ((p_line_rec_type.transaction_source_type_id <> 5) OR
        (p_line_rec_type.transaction_source_type_id = 5 AND
         p_line_rec_type.wip_entity_type = 10 ));--J-dev verify

     /*Bug:5276191. Added the following cursor. */
     CURSOR c_mmtt IS
      SELECT   *
          FROM mtl_material_transactions_temp
         WHERE transaction_header_id = p_header_id
           AND NVL(transaction_status, 1) <> 2   -- don't consider suggestions
           AND process_flag = 'Y'
      ORDER BY transaction_batch_id;

    l_index                    NUMBER          := 0;
    l_previous_parent_id       NUMBER          := 0;
    l_validation_status        VARCHAR2 (1)    := 'Y';

    l_rsv_wip_entity_type          NUMBER := NULL; -- Bug 6454464
    l_rsv_wip_job_type             VARCHAR2(15);   -- Bug 6454464

  BEGIN
    l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    l_header_id := p_header_id;

    --dbms_output.put_line(' came to process_trx');
    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE
                       (   '-----Inside process_Transactions-------.trxhdr='
                        || p_header_id
                      , 'INV_TXN_MANAGER_PUB'
                      , 9
                       );

    END IF;

    /* FND_MESSAGE.SET_NAME('INV', 'BAD_INPUT_ARGUMENTS');
    FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR; */

    /*----------------------------------------------------------+
    |  retrieving information
    +----------------------------------------------------------*/
    poget ('LOGIN_ID', l_loginid);
    poget ('USER_ID', l_userid);
    poget ('CONC_PROGRAM_ID', l_progid);
    poget ('CONC_REQUEST_ID', l_reqstid);
    poget ('PROG_APPL_ID', l_applid);

    IF l_loginid IS NULL
    THEN
      l_loginid := -1;
    END IF;

    IF l_userid IS NULL
    THEN
      l_userid := -1;
    END IF;

    /*l_loginid := 1068;
    l_userid := 1068;
      l_progid := 32321;
      l_reqstid := null;
      l_applid := 401;*/
    x_return_status := fnd_api.g_ret_sts_error;
    x_msg_count := 0;
    x_msg_data := '';
    x_trans_count := 0;

    -- Bug 3339212. We were rolling back everything if
    --there is an error in process transactions. This leads o erasing all
    -- the save point set, which would result in cannot establishing save points
    -- which could have been set by other teams calling our API. So, we
    -- would rollback to this point if anything fails in process
    --transactions.
    -- Bug 3686000: The savepoint to be established only when the caller calls
    -- this API with p_commit as false. Otherwise, during an exception, we
    -- will not find the save point as we would have committed if p_commit
    -- has been set to true in downstream processing.
    IF NOT fnd_api.to_boolean (p_commit)
    THEN
      SAVEPOINT process_transactions_svpt;
    END IF;

    --fnd_global.apps_initialize(1003593, 53466, 385);
    IF (p_table = 2)
    THEN
      /** Process Rows in MTL_MATERIAL_TRANSACTION_TEMP **/
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Process Rows in MTL_MATERIAL_TRANSACTION_TEMP'
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;

      UPDATE mtl_material_transactions_temp
         SET last_update_date = SYSDATE
           , transaction_temp_id =
                NVL (transaction_temp_id, mtl_material_transactions_s.NEXTVAL)
           , last_updated_by = l_userid
           , last_update_login = l_loginid
           , program_application_id = l_applid
           , program_id = l_progid
           , request_id = l_reqstid
           , program_update_date = SYSDATE
           , ERROR_CODE = NULL
           , error_explanation = NULL
       WHERE process_flag = 'Y'
         AND NVL (transaction_status, ts_default) <> ts_save_only  /* 2STEP */
         AND transaction_header_id = l_header_id;

      --Bug 4586255, support 6 decimals for wip
      UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
        SET PRIMARY_QUANTITY = ROUND(PRIMARY_QUANTITY,5),
            TRANSACTION_QUANTITY = ROUND(TRANSACTION_QUANTITY,5)
        WHERE  PROCESS_FLAG = 'Y'
           AND NVL(TRANSACTION_STATUS,TS_DEFAULT) <> TS_SAVE_ONLY  /* 2STEP */
           AND TRANSACTION_HEADER_ID = l_header_id
           AND transaction_source_type_id <> 5;

      UPDATE mtl_transaction_lots_temp
        SET  PRIMARY_QUANTITY = ROUND(PRIMARY_QUANTITY,5),
          TRANSACTION_QUANTITY = ROUND(TRANSACTION_QUANTITY,5)
          WHERE transaction_temp_id
                IN ( SELECT transaction_temp_id
                       FROM mtl_material_transactions_temp
                       WHERE  PROCESS_FLAG = 'Y'
                          AND NVL(TRANSACTION_STATUS,TS_DEFAULT) <> TS_SAVE_ONLY  /* 2STEP */
                          AND TRANSACTION_HEADER_ID = l_header_id
                  	      AND transaction_source_type_id <> 5);


      UPDATE MTL_MATERIAL_TRANSACTIONS_TEMP
        SET    PRIMARY_QUANTITY = ROUND(PRIMARY_QUANTITY,6),
               TRANSACTION_QUANTITY = ROUND(TRANSACTION_QUANTITY,6)
        WHERE  PROCESS_FLAG = 'Y'
          AND  NVL(TRANSACTION_STATUS,TS_DEFAULT) <> TS_SAVE_ONLY  /* 2STEP */
          AND  TRANSACTION_HEADER_ID = l_header_id
          AND  transaction_source_type_id = 5;

	    UPDATE mtl_transaction_lots_temp
	      SET  PRIMARY_QUANTITY = ROUND(PRIMARY_QUANTITY,6),
	           TRANSACTION_QUANTITY = ROUND(TRANSACTION_QUANTITY,6)
    	  WHERE transaction_temp_id
	            IN( SELECT transaction_temp_id
            	      FROM mtl_material_transactions_temp
            	      WHERE  PROCESS_FLAG = 'Y'
            	      AND    NVL(TRANSACTION_STATUS,TS_DEFAULT) <> TS_SAVE_ONLY  /* 2STEP */
                    AND    TRANSACTION_HEADER_ID = l_header_id
                    AND    transaction_source_type_id = 5);

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Rows in MMTT ready to process '
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;

      SELECT COUNT (1)
        INTO l_process
        FROM mtl_material_transactions_temp
       WHERE transaction_header_id = l_header_id
         AND process_flag = 'Y'
         AND transaction_status = 3 /* not able to use the TS_PROCESS macro */
         AND ROWNUM < 2;

      --the assumption is that default txns are
      --never mixed up with the 2level txns. so
      -- we can avoid temp validation call if there
      --are no rows with transaction_status = TS_PROCESS
      IF l_process = 1
      THEN
        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE ('Calling INV_PROCESS_TEMP.processTransaction'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        l_result :=
          inv_process_temp.processtransaction (l_header_id
                                             , inv_process_temp.FULL
                                             , inv_process_temp.ignore_all
                                              );
      END IF;

      SELECT COUNT (*)
        INTO l_totrows
        FROM mtl_material_transactions_temp
       WHERE transaction_header_id = l_header_id
         AND process_flag = 'Y'
         AND NVL (transaction_status, ts_default) <> ts_save_only; /* 2STEP */

      l_midtotrows := l_totrows;
      l_initotrows := l_totrows;
      x_trans_count := l_totrows;

      IF (l_totrows = 0)
      THEN
        IF fnd_api.to_boolean (p_commit)
        THEN
          COMMIT WORK;
        END IF;

        fnd_message.set_name ('INV', 'INV_PROC_WARN');
        l_disp := fnd_message.get;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
        END IF;

        RETURN -1;
      END IF;

      /*+-----------------------------------------------------------------+
        | Check if we are processing WIP transactions to determine which  |
        | to invoke to process transactions                               |
        +-----------------------------------------------------------------+*/
        -- Pawan added wip_entity_type for gme_inventory convergence
      SELECT transaction_source_type_id, wip_entity_type
	INTO l_srctypeid, l_wip_entity_type
        FROM mtl_material_transactions_temp
       WHERE transaction_header_id = l_header_id AND ROWNUM < 2;

      done := FALSE;
      FIRST := TRUE;

      WHILE (NOT done)
      LOOP
        IF (FIRST)
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Calling Process_lpn_trx'
                              , 'INV_TXN_MANAGER_PUB'
                              , 9
                               );
          END IF;

          fnd_message.set_name ('INV', 'INV_CALL_PROC');
          fnd_message.set_token ('token1', l_header_id);
          fnd_message.set_token ('token2', l_totrows);
          l_disp := fnd_message.get;

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
          END IF;
        END IF;

              -- If transactions are of type WIP, then call the WIP API. This
              -- API does the WIP pre-processing before calling
        --process_lpn_trx
        /** WIP J dev condition. Add another condtion in the if
        /* statement below. if WIP.J is not installed call
        /* wip_mtlTempProc_grp()...else call process_lpn_trx()*/
        IF (    l_srctypeid = 5
            AND wip_constants.dmf_patchset_level <
                                            wip_constants.dmf_patchset_j_value
           )
        THEN
          wip_mtltempproc_grp.processtemp
               (p_initmsglist      => fnd_api.g_false
              , p_processinv       => fnd_api.g_true
              ,                                 -- call INV TM after WIP logic
                p_txnhdrid         => l_header_id
              , x_returnstatus     => l_return_status
              , x_errormsg         => l_msg_data
               );

          IF (l_return_status <> fnd_api.g_ret_sts_success)
          THEN
            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('Failure from MMTT:WIP processTemp!!'
                                , 'INV_TXN_MANAGER_PUB'
                                , 1
                                 );
            END IF;

            l_result := -1;
          END IF;
        ELSE
          l_result :=
            inv_lpn_trx_pub.process_lpn_trx (p_trx_hdr_id      => l_header_id
                                           , p_commit          => p_commit
                                           , x_proc_msg        => l_msg_data
                                           , p_proc_mode       => 1
                                           , p_process_trx     => fnd_api.g_true
                                           , p_atomic          => fnd_api.g_false
                                            );
        END IF;

        IF (l_result <> 0)
        THEN
          fnd_message.set_name ('INV', 'INV_INT_PROCCODE');

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Error from PROCESS_LPN_TRX.. ' || l_msg_data
                              , 'INV_TXN_MANAGER_PUB'
                              , 9
                               );
          END IF;

          l_error_exp := l_msg_data;
          x_msg_data := l_msg_data;
          x_return_status := l_return_status;

          /*      No need to update MMTT after returning from process_lpn_trx as this has already
          been done within the Java code. - Bug 2284667 */
          IF fnd_api.to_boolean (p_commit)
          THEN
            COMMIT WORK;
          END IF;

          RETURN -1;
        END IF;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE ('After process_lpn_trx without errors'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        IF (FIRST)
        THEN
          fnd_message.set_name ('INV', 'INV_RETURN_PROC');
          l_disp := fnd_message.get;

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
          END IF;
        END IF;

        IF fnd_api.to_boolean (p_commit)
        THEN
          COMMIT WORK;
        END IF;

        IF (FIRST)
        THEN
          IF (NOT bflushchk (l_header_id))
          THEN
            l_error_exp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('Error in call to bflushchk'
                                , 'INV_TXN_MANAGER_PUB'
                                , 9
                                 );
            END IF;

            --ROLLBACK WORK;
            RETURN -1;
          END IF;

          IF (l_header_id <> -1)
          THEN
            fnd_message.set_name ('INV', 'INV_BFLUSH_PROC');
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
            END IF;

            SELECT COUNT (*)
              INTO l_totrows
              FROM mtl_material_transactions_temp
             WHERE transaction_header_id = l_header_id AND process_flag = 'Y';

            IF (l_totrows > 200)
            THEN
              UPDATE mtl_material_transactions_temp
                 SET transaction_header_id = (-1) * l_header_id
               WHERE transaction_header_id = l_header_id
                     AND process_flag = 'Y';

              UPDATE mtl_material_transactions_temp
                 SET transaction_header_id = ABS (l_header_id)
               WHERE transaction_header_id = (-1) * (l_header_id)
                 AND process_flag = 'Y'
                 AND ROWNUM < 201;
            END IF;

            fnd_message.set_name ('INV', 'INV_CALL_PROC');
            fnd_message.set_token ('token1', l_header_id);
            fnd_message.set_token ('token2', l_totrows);
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
            END IF;
          ELSE
            done := TRUE;
          END IF;

          FIRST := FALSE;
        ELSE
          UPDATE mtl_material_transactions_temp
             SET transaction_header_id = ABS (l_header_id)
           WHERE transaction_header_id = (-1) * (l_header_id)
             AND process_flag = 'Y'
             AND ROWNUM < 201;

          IF SQL%NOTFOUND
          THEN
            fnd_message.set_name ('INV', 'INV_RETURN_PROC');
            done := TRUE;
          END IF;
        END IF;
      END LOOP;
    ELSE

      /** Table = 1 - MTL_TRANSACTIONS_INTERFACE **/
      /** Table = 1 - MTL_TRANSACTIONS_INTERFACE **/
      /*Patchset J:Trip Stop Interface Enhancements:setting the
      /*transaction batch id for Shipping transactions depending
      /*on the profile INV:Batch Size*/
            /*Bug 3947667, enabling it irrespective of patchset */

      -- IF (INV_CONTROL.G_CURRENT_RELEASE_LEVEL >= INV_RELEASE.G_J_RELEASE_LEVEL) THEN
      BEGIN
        l_batch_size := NVL (fnd_profile.VALUE ('INV_BATCH_SIZE'), 0);
      EXCEPTION
        WHEN VALUE_ERROR
        THEN
          l_batch_size := 0;
          inv_log_util.TRACE
                         ('Inv Batch size set to null for non numeric value'
                        , 'INV_TXN_MANAGER_PUB'
                        , 9
                         );
      END;

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Inv Batch size:' || l_batch_size
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;

      UPDATE mtl_transactions_interface
         SET last_update_date = SYSDATE
           , transaction_interface_id =
               NVL (transaction_interface_id
                  , mtl_material_transactions_s.NEXTVAL
                   )
           , transaction_batch_id =
               NVL (transaction_batch_id
                  , DECODE (transaction_source_type_id
                          , 2, DECODE (l_batch_size
                                     , 0, transaction_batch_id
                                     , CEIL (ROWNUM / l_batch_size)
                                      )
                          , 8, DECODE (l_batch_size
                                     , 0, transaction_batch_id
                                     , CEIL (ROWNUM / l_batch_size)
                                      )
                          , 16, DECODE (l_batch_size
                                      , 0, transaction_batch_id
                                      , CEIL (ROWNUM / l_batch_size)
                                       )
                          , transaction_batch_id
                           )
                   )
           , last_updated_by = l_userid
           , last_update_login = l_loginid
           , program_application_id = l_applid
           , program_id = l_progid
           , request_id = l_reqstid
           , program_update_date = SYSDATE
           , lock_flag = 1
       WHERE process_flag = 1 AND transaction_header_id = l_header_id;

      /* ELSE

         UPDATE MTL_TRANSACTIONS_INTERFACE
           SET LAST_UPDATE_DATE = SYSDATE,
           TRANSACTION_INTERFACE_ID = NVL(TRANSACTION_INTERFACE_ID,
                  mtl_material_transactions_s.nextval),
           LAST_UPDATED_BY = l_userid,
           LAST_UPDATE_LOGIN = l_loginid,
           PROGRAM_APPLICATION_ID = l_applid,
           PROGRAM_ID = l_progid,
           REQUEST_ID = l_reqstid,
           PROGRAM_UPDATE_DATE = SYSDATE,
           LOCK_FLAG = 1
           WHERE PROCESS_FLAG = 1
           AND TRANSACTION_HEADER_ID = l_header_id;
      END IF; */
      l_initotrows := SQL%ROWCOUNT;

      IF fnd_api.to_boolean (p_commit)
      THEN
        COMMIT WORK;
      END IF;

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('MTI Rows cnt before Validation=' || l_initotrows
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;

      IF (l_totrows = 0)
      THEN
        fnd_message.set_name ('INV', 'INV_PROC_WARN');
        l_disp := fnd_message.get;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE (l_disp || ' totrows = 0'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        RETURN -1;
      END IF;

      /*+-----------------------------------------------------------------+
        | Check if we are processing WIP transactions to determine whether|
        | to do the derivation for flow_schedule.                         |
        +-----------------------------------------------------------------+*/
         -- Pawan Added the wip_entity_type
      SELECT NVL (validation_required, 1)
           , mtt.transaction_source_type_id, mti.wip_entity_type
        INTO l_valreq
           , l_srctypeid, l_wip_entity_type
        FROM mtl_transactions_interface mti, mtl_transaction_types mtt
       WHERE transaction_header_id = l_header_id
         AND mtt.transaction_type_id = mti.transaction_type_id
         AND ROWNUM < 2;

      /*+--------------------------------------------------------------+
      | The global INV_TXN_MANAGER_GRP.gi_flow_schedule will be '1' (or true) for        |
        | WIP flow schedules ONLY.                                     |
        +--------------------------------------------------------------+ */
      IF (l_srctypeid = 5)
      THEN
        BEGIN
          SELECT DECODE (UPPER (flow_schedule), 'Y', 1, 0)
            INTO inv_txn_manager_grp.gi_flow_schedule
            FROM mtl_transactions_interface
           WHERE transaction_header_id = l_header_id
             AND transaction_source_type_id = 5
             AND transaction_action_id IN
                                         (30, 31, 32) --CFM Scrap Transactions
             AND process_flag = 1
             AND ROWNUM < 2;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            inv_txn_manager_grp.gi_flow_schedule := 0;
        END;
      ELSE
        inv_txn_manager_grp.gi_flow_schedule := 0;
      END IF;

      /** WIP J dev condition. If WIP J is not installed do as now,
      /*else call a new new API wip_mti_pub.preInvWIPProcessing()
      /* This has to be called before validate_group()
      /* we should retain create_flow sch for WIP I and below.*/
      IF (    l_srctypeid = 5
          AND wip_constants.dmf_patchset_level >=
                                            wip_constants.dmf_patchset_j_value
         )
      THEN
      	 -- Pawan Added following changes for gme- convergence
	     IF l_wip_entity_type = 10 THEN
	     	IF (l_debug = 1) THEN
                   inv_log_util.trace('in for gme pre_process','INV_TXN_MANAGER_PUB', 9);
                END IF;
	     	gme_api_grp.gme_pre_process_txns
	        	( p_header_id	=> l_header_id,
	  		x_return_status    => l_ret_sts_pre) ;
		IF (l_ret_sts_pre  = fnd_api.g_ret_sts_success) THEN
		   IF (l_debug = 1) THEN
		      inv_log_util.trace('Success from:!!gme_api_grp.gme_pre_process_txns', 'INV_TXN_MANAGER_PUB',1);
		   END IF;

		   IF FND_API.To_Boolean( p_commit ) then
		      COMMIT WORK; /* Commit after preInvWIP all MTI records */
		   END IF;

		   --check if all records have been failed by the wip API.
		   BEGIN
		       SELECT transaction_source_type_id INTO l_source_type_id
		         FROM MTL_TRANSACTIONS_INTERFACE
		        WHERE TRANSACTION_HEADER_ID = l_header_id
			  AND PROCESS_FLAG = 1
			  AND ROWNUM < 2;
		    EXCEPTION
			   WHEN NO_DATA_FOUND THEN
			        x_return_status := FND_API.G_RET_STS_ERROR;
			        x_msg_data := 'All records failed by gme_api_grp.gme_pre_process_txns';
			        RETURN -1;
		   END;
	    	ELSE
		   IF (l_debug = 1) THEN
		      inv_log_util.trace('Failure from:!!gme_api_grp.gme_pre_process_txns', 'INV_TXN_MANAGER_PUB',1);
		   END IF;
		   RAISE fnd_api.g_exc_unexpected_error;
	    	END IF;--check for success
       ELSE/*l_wip_entity_type = 10 */

        wip_mti_pub.preinvwipprocessing (p_txnheaderid      => l_header_id
                                       , x_returnstatus     => l_ret_sts_pre
                                        );

        IF (l_ret_sts_pre = fnd_api.g_ret_sts_success)
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Success from:!!preInvWIPProcessing'
                              , 'INV_TXN_MANAGER_PUB'
                              , 1
                               );
          END IF;

          IF fnd_api.to_boolean (p_commit)
          THEN
            COMMIT WORK;         /* Commit after preInvWIP all MTI records */
          END IF;

          --check if all records have been failed by the wip API.
          BEGIN
            SELECT transaction_source_type_id
              INTO l_source_type_id
              FROM mtl_transactions_interface
             WHERE transaction_header_id = l_header_id
               AND process_flag = 1
               AND ROWNUM < 2;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              x_return_status := fnd_api.g_ret_sts_error;
              x_msg_data := 'All records failed by preInvWipProcessing';
              RETURN -1;
          END;
        ELSE
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Failure from:!!preInvWIPProcessing'
                              , 'INV_TXN_MANAGER_PUB'
                              , 1
                               );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;                                            --check for success
       END IF;--for l_wip_entity_type Pawan added for gme-convergence changes.
      ELSE
        IF (inv_txn_manager_grp.gi_flow_schedule <> 0)
        THEN
          wip_flow_utilities.create_flow_schedules (l_header_id);
        END IF;
      END IF;                                                          --J-dev

      /***** Group Validation *******************************/
      validate_group (l_header_id
                    , x_return_status
                    , x_msg_count
                    , x_msg_data
                    , l_userid
                    , l_loginid
                     );

      IF x_return_status = fnd_api.g_ret_sts_error
      THEN
        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE (   'Unexpected Error in Validate Group : '
                              || x_msg_data
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      /** Moved to after Validate_lines loop J-dev*/
      /******* Group Validation for WIP records *******************/
      /* This WIP API could potentially error some records in MTI. If any records
      /* have been errored, they would be stamped with error-code/explanation */
      /*IF (l_srctypeid = 5 ) THEN
            wip_mti_pub.postInvWIPValidation(
        p_txnHeaderID  => l_header_id,
        x_returnStatus => x_return_status
        );
        END IF;*/
      IF fnd_api.to_boolean (p_commit)
      THEN
        COMMIT WORK;      /* Commit after group validating all MTI records */
      END IF;

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Group validation complete '
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;

      batch_error := FALSE;

      FOR l_line_rec_type IN aa1
      LOOP
        BEGIN
          l_trx_batch_id := l_line_rec_type.transaction_batch_id;

          IF batch_error AND l_trx_batch_id = l_last_trx_batch_id
          THEN
            /** This group of transactions has failed move on to next **/
            /** UPDATE MTI row with Group Failure Message **/
            NULL;
          ELSE
            batch_error := FALSE;
            l_last_trx_batch_id := l_trx_batch_id;

            /** Change for Lot Transactions **/
            IF (l_line_rec_type.transaction_source_type_id = 13)
            THEN
              IF (l_line_rec_type.transaction_action_id IN (40, 41, 42))
              THEN
                IF (l_debug = 1)
                THEN
                  inv_log_util.TRACE (   'Previous parent: '
                                      || l_previous_parent_id
                                    , 'INV_TXN_MANAGER_PUB'
                                    , 9
                                     );
                  inv_log_util.TRACE (   'Current parent: '
                                      || l_line_rec_type.parent_id
                                    , 'INV_TXN_MANAGER_PUB'
                                    , 9
                                     );
                END IF;

                IF (NVL (l_previous_parent_id, 0) <> l_line_rec_type.parent_id
                   )
                THEN
                  /***** Its a new Batch. Before we do any validations, we have to
                  -- check for the transaction bacth id. For all lot
                  --  transctions, the batch id should be filled in for
                  --  the TM to perform a complete rollback in case any
                  --  of the records fail within a group/batch.
                  --  Bug 2804402
                  *******/
                  l_batch_count := 0;

                  SELECT COUNT (1)
                    INTO l_batch_count
                    FROM mtl_transactions_interface
                   WHERE parent_id = l_line_rec_type.parent_id
                     AND transaction_batch_id IS NULL;

                  IF (l_batch_count > 0)
                  THEN
                    loaderrmsg ('INV_INVALID_BATCH'
                              , 'INV_INVALID_BATCH_NUMBER'
                               );

                    UPDATE mtl_transactions_interface
                       SET last_update_date = SYSDATE
                         , last_updated_by = l_userid
                         , last_update_login = l_loginid
                         , program_update_date = SYSDATE
                         , process_flag = 3
                         , lock_flag = 2
                         , ERROR_CODE = SUBSTR (l_error_code, 1, 240)
                         , error_explanation = SUBSTRB (l_error_exp, 1, 240)
                     WHERE parent_id = l_line_rec_type.parent_id
                       AND process_flag = 1;

                    RAISE rollback_line_validation;
                  END IF;

                  l_index := 0;
                  l_previous_parent_id := l_line_rec_type.parent_id;
                  l_validation_status := 'Y';
                END IF;

                l_index := l_index + 1;
                /*l_index identifies the distinct parent_id's and processes them
                 *in one go
                 */
                IF (l_index = 1)
                THEN
                  IF (l_line_rec_type.transaction_action_id = 40)
                  THEN
                    fnd_message.set_name ('INV', 'INV_LOT_SPLIT_VALIDATIONS');
                    l_error_code := fnd_message.get;
                    inv_lot_trx_validation_pvt.validate_lot_split_trx
                                 (x_return_status         => x_return_status
                                , x_msg_count             => x_msg_count
                                , x_msg_data              => x_msg_data
                                , x_validation_status     => l_validation_status
                                , p_parent_id             => l_line_rec_type.parent_id
                                 );

                    IF (x_return_status <> fnd_api.g_ret_sts_success)
                    THEN
                      -- Fetch all the error messages from the stack and log them.
                      -- Update the MTI with last error message only, since the error messages can be redundant.
                      FOR i IN 1 .. x_msg_count
                      LOOP
                        x_msg_data := fnd_msg_pub.get (i, 'F');

                        IF (l_debug = 1)
                        THEN
                          inv_log_util.TRACE
                                     (   'Error in Validate_lot_Split_Trx: '
                                      || x_msg_data
                                    , 'INV_TXN_MANAGER_PUB'
                                    , 9
                                     );
                        END IF;
                      END LOOP;

                      UPDATE mtl_transactions_interface
                         SET last_update_date = SYSDATE
                           , last_updated_by = l_userid
                           , last_update_login = l_loginid
                           , program_update_date = SYSDATE
                           , process_flag = 3
                           , lock_flag = 2
                           , ERROR_CODE = SUBSTR (l_error_code, 1, 240)
                           , error_explanation = SUBSTRB (x_msg_data, 1, 240)
                       WHERE ROWID = l_line_rec_type.ROWID
                             AND process_flag = 1;

                      RAISE rollback_line_validation;
                    END IF;
                  ELSIF (l_line_rec_type.transaction_action_id = 41)
                  THEN
                    fnd_message.set_name ('INV', 'INV_LOT_MERGE_VALIDATIONS');
                    l_error_code := fnd_message.get;
                    inv_lot_trx_validation_pvt.validate_lot_merge_trx
                                 (x_return_status         => x_return_status
                                , x_msg_count             => x_msg_count
                                , x_msg_data              => x_msg_data
                                , x_validation_status     => l_validation_status
                                , p_parent_id             => l_line_rec_type.parent_id
                                 );

                    IF (x_return_status <> fnd_api.g_ret_sts_success)
                    THEN
                      -- Fetch all the error messages from the stack and log them.
                      -- Update the MTI with last error message only, since the error messages can be redundant.
                      FOR i IN 1 .. x_msg_count
                      LOOP
                        x_msg_data := fnd_msg_pub.get (i, 'F');

                        IF (l_debug = 1)
                        THEN
                          inv_log_util.TRACE
                                     (   'Error in Validate_lot_Merge_Trx: '
                                      || x_msg_data
                                    , 'INV_TXN_MANAGER_PUB'
                                    , 9
                                     );
                        END IF;
                      END LOOP;

                      UPDATE mtl_transactions_interface
                         SET last_update_date = SYSDATE
                           , last_updated_by = l_userid
                           , last_update_login = l_loginid
                           , program_update_date = SYSDATE
                           , process_flag = 3
                           , lock_flag = 2
                           , ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
                           , error_explanation = SUBSTRB (x_msg_data, 1, 240)
                       WHERE ROWID = l_line_rec_type.ROWID
                             AND process_flag = 1;

                      RAISE rollback_line_validation;
                    END IF;
                  ELSIF (l_line_rec_type.transaction_action_id = 42)
                  THEN
                    fnd_message.set_name ('INV'
                                        , 'INV_LOT_TRANSLATE_VALIDATIONS'
                                         );
                    l_error_code := fnd_message.get;
                    inv_lot_trx_validation_pvt.validate_lot_translate_trx
                                  (x_return_status         => x_return_status
                                 , x_msg_count             => x_msg_count
                                 , x_msg_data              => x_msg_data
                                 , x_validation_status     => l_validation_status
                                 , p_parent_id             => l_line_rec_type.parent_id
                                  );

                    IF (x_return_status <> fnd_api.g_ret_sts_success)
                    THEN
                      -- Fetch all the error messages from the stack and log them.
                      -- Update the MTI with last error message only, since the error messages can be redundant.
                      FOR i IN 1 .. x_msg_count
                      LOOP
                        x_msg_data := fnd_msg_pub.get (i, 'F');

                        IF (l_debug = 1)
                        THEN
                          inv_log_util.TRACE
                                 (   'Error in Validate_lot_Translate_Trx: '
                                  || x_msg_data
                                , 'INV_TXN_MANAGER_PUB'
                                , 9
                                 );
                        END IF;
                      END LOOP;

                      UPDATE mtl_transactions_interface
                         SET last_update_date = SYSDATE
                           , last_updated_by = l_userid
                           , last_update_login = l_loginid
                           , program_update_date = SYSDATE
                           , process_flag = 3
                           , lock_flag = 2
                           , ERROR_CODE = SUBSTR (l_error_code, 1, 240)
                           , error_explanation = SUBSTRB (x_msg_data, 1, 240)
                       WHERE ROWID = l_line_rec_type.ROWID
                             AND process_flag = 1;

                      RAISE rollback_line_validation;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END IF;

            /** End of Change for Lot Transactions ***/
            IF (    l_line_rec_type.transaction_source_type_id = 13
                AND l_line_rec_type.transaction_action_id IN (40, 41, 42)
                AND l_index > 1
                AND l_validation_status <> 'Y'
               )
            THEN
              IF (l_line_rec_type.transaction_action_id = 40)
              THEN
                fnd_message.set_name ('INV', 'INV_LOT_SPLIT_VALIDATIONS');
                l_error_code := fnd_message.get;
              ELSIF (l_line_rec_type.transaction_action_id = 41)
              THEN
                fnd_message.set_name ('INV', 'INV_LOT_MERGE_VALIDATIONS');
                l_error_code := fnd_message.get;
              ELSIF (l_line_rec_type.transaction_action_id = 42)
              THEN
                fnd_message.set_name ('INV', 'INV_LOT_TRANSLATE_VALIDATIONS');
                l_error_code := fnd_message.get;
              END IF;

              UPDATE mtl_transactions_interface
                 SET last_update_date = SYSDATE
                   , last_updated_by = l_userid
                   , last_update_login = l_loginid
                   , program_update_date = SYSDATE
                   , process_flag = 3
                   , lock_flag = 2
                   , ERROR_CODE = SUBSTR (l_error_code, 1, 240)
                   , error_explanation = SUBSTRB (x_msg_data, 1, 240)
               WHERE ROWID = l_line_rec_type.ROWID AND process_flag = 1;

              RAISE rollback_line_validation;
            END IF;

            /* bug 2807083, populate the distribution account id of lot translate txn */
            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE
                           (   'l_line_rec_type.distribution_account_id is '
                            || l_line_rec_type.distribution_account_id
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
            END IF;

            IF (l_line_rec_type.distribution_account_id IS NULL)
            THEN
              SELECT distribution_account_id
                INTO l_dist_acct_id
                FROM mtl_transactions_interface
               WHERE ROWID = l_line_rec_type.ROWID;

              l_line_rec_type.distribution_account_id := l_dist_acct_id;
            END IF;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('l_dist_acct_id is ' || l_dist_acct_id
                                , 'INV_TXN_MANAGER_PUB'
                                , 9
                                 );
            END IF;

            validate_lines (p_line_rec_type     => l_line_rec_type
                          , p_error_flag        => line_vldn_error_flag
                          , p_userid            => l_userid
                          , p_loginid           => l_loginid
                          , p_applid            => l_applid
                          , p_progid            => l_progid
                           );


            IF (line_vldn_error_flag = 'Y')
            THEN
              IF (l_debug = 1)
              THEN
                inv_log_util.TRACE ('Error in Line Validatin'
                                  , 'INV_TXN_MANAGER_PUB'
                                  , 9
                                   );
              END IF;

              RAISE rollback_line_validation;
            END IF;

            /*Bug:5209598. Start of code.Following Code has been added to perform ATT/ATR high/low level
              checks for WIP transactions. In VALIDATE_TRANSACTIONS() of pkg INV_TXN_MANAGER_GRP, high/low level
              reservation checks are performed for WIP transactions.But for those WIP transactions that do not
              go through the validate_transactions() procedure, the following code does the reservation checks
              before inserting record into MMTT.
            */
            IF ( l_srctypeid = 5 ) THEN
              IF ( l_current_err_batch_id IS NULL
		   OR l_Line_rec_Type.transaction_batch_id IS NULL
		   OR l_current_err_batch_id <>  l_Line_rec_Type.transaction_batch_id )THEN --050
                l_current_batch_failed := FALSE;
  		FOR z1_rec IN
		  Z1(inv_txn_manager_grp.gi_flow_schedule,l_Line_rec_type) LOOP

		  tree_exists := FALSE;

		  IF (l_debug = 1) THEN
		    inv_log_util.trace('Getting values from Z1 cursor', 'INV_TXN_MANAGER_PUB', 9);
		  END IF;

		  l_temp_rowid :=z1_rec.ROWID;
		  l_item_id:=z1_rec.inventory_item_id;
		  l_rev:=z1_rec.revision;
          	  l_org_id:=z1_rec.organization_id;
		  l_sub_code:=z1_rec.subinventory_code;
                  l_locid :=z1_rec.locator_id;
	          l_trx_qty:=z1_rec.primary_quantity;
	          l_lotnum:=z1_rec.lot_number;
	          l_srctypeid:=z1_rec.transaction_source_type_id;
	          l_actid:=z1_rec.transaction_action_id;
	          l_srcid:=z1_rec.transaction_source_id;
	          l_src_code:=z1_rec.transaction_source_name;
	          l_srclineid:=z1_rec.source_line_id;
	          l_rctrl:=z1_rec.revision_qty_control_code;
	          l_lctrl:=z1_rec.lot_control_code;
	          l_xfrsub:=z1_rec.transfer_subinventory;
	          l_xlocid:=z1_rec.transfer_locator;
	          l_trxdate:=z1_rec.TRANSACTION_DATE;
                  l_neg_inv_rcpt:=z1_rec.negative_inv_receipt_code;

               --Bug 6454464, we should not call available qty validation for CMRO job type
	       inv_reservation_pvt.get_wip_entity_type
	   	(  p_api_version_number           => 1.0
	      	, p_init_msg_lst                 => fnd_api.g_false
	      	, x_return_status                => l_return_status
	      	, x_msg_count                    => l_msg_count
	      	, x_msg_data                     => l_msg_data
	      	, p_organization_id              => null
	      	, p_item_id                      => null
	      	, p_source_type_id               => null
	      	, p_source_header_id             => l_srcid
	      	, p_source_line_id               => null
	      	, p_source_line_detail           => null
	      	, x_wip_entity_type              => l_rsv_wip_entity_type
	      	, x_wip_job_type                 => l_rsv_wip_job_type
	      	);

	  	IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	     		inv_log_util.TRACE ('Return status from get wip entity. '||l_return_status, 'INV_TXN_MANAGER_PUB', 9);
	  	ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	       		inv_log_util.TRACE ('Return status from get wip entity. '||l_return_status, 'INV_TXN_MANAGER_PUB', 9);
	  	END IF;

                IF (l_debug = 1) THEN
	  		inv_log_util.TRACE ('Wip entity type ' || l_rsv_wip_entity_type, 'INV_TXN_MANAGER_PUB', 9);
       		END IF;

                --Bug 6454464, we should not call available qty validation for CMRO job type
       		IF (l_rsv_wip_entity_type <> inv_reservation_global.g_wip_source_type_cmro) THEN

                  IF l_rctrl = 1 THEN
         	    l_revision_control := FALSE;
	          ELSE
         	    l_revision_control := TRUE;
                  END IF;

                  IF l_lctrl = 1 THEN
	            l_lot_control := FALSE;
		  ELSE
		    l_lot_control := TRUE;
  	          END IF;

	         IF (l_debug = 1) THEN
	           inv_log_util.trace('Calling Create tree', 'INV_TXN_MANAGER_PUB', 9);
	         END IF;

                 -- Bug 4194323 WIP Assembly Return transactions need to look for Available Quantity
                 --against the Sales Order if it's linked to job

                 IF ( NOT l_current_batch_failed) THEN --350
                   BEGIN
       	             SELECT demand_source_header_id , demand_source_line
       		     INTO l_dem_hdr_id,l_dem_line_id
       		     FROM mtl_transactions_interface
       		     WHERE
       		     ROWID = l_temp_rowid ;
                   EXCEPTION
                     WHEN OTHERS THEN
                       IF (l_debug = 1) THEN
                         inv_log_util.trace('Error in getting Demand Info : '
			                             || x_msg_data,'INV_TXN_MANAGER_PUB', 9);
		       END IF;
                       l_error_code := 'Error in getting Demand Info';
                       l_error_exp := 'Error in getting Demand Info';

                       UPDATE MTL_TRANSACTIONS_INTERFACE
                            SET LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATED_BY = l_userid,
                            LAST_UPDATE_LOGIN = l_loginid,
                            PROGRAM_UPDATE_DATE = SYSDATE,
                            PROCESS_FLAG = 3,
                            LOCK_FLAG = 2,
                            ERROR_CODE = substrb(l_error_code,1,240),
                            ERROR_EXPLANATION = substrb(l_error_exp,1,240)
                            WHERE ROWID  = l_temp_rowid
                            AND PROCESS_FLAG = 1;
                                      --check for batch error
                       loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

 	               UPDATE MTL_TRANSACTIONS_INTERFACE MTI
 	                   SET LAST_UPDATE_DATE = SYSDATE,
 	                   LAST_UPDATED_BY = l_userid,
 	                   LAST_UPDATE_LOGIN = l_loginid,
 	                   PROGRAM_UPDATE_DATE = SYSDATE,
 	                   PROCESS_FLAG = 3,
 	                   LOCK_FLAG = 2,
 	                   ERROR_CODE = substrb(l_error_code,1,240)
 	                 WHERE TRANSACTION_HEADER_ID = l_header_id
 	                   AND PROCESS_FLAG = 1
 	                   AND TRANSACTION_BATCH_ID =l_Line_rec_Type.transaction_batch_id;

                       l_current_batch_failed := TRUE;--Bug#5075521
		       l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		     END ;

                     IF ( NOT l_current_batch_failed) THEN --400
		       IF ( l_srctypeid = INv_GLOBALS.G_SOURCETYPE_WIP AND
		            l_actid = INV_GLOBALS.G_ACTION_ASSYRETURN AND l_dem_hdr_id IS NOT NULL ) then


                         INV_QUANTITY_TREE_PVT.create_tree
			   (   p_api_version_number       => 1.0
			       ,  p_init_msg_lst             => fnd_api.g_false
			       ,  x_return_status            => l_return_status
			       ,  x_msg_count                => l_msg_count
			       ,  x_msg_data                 => l_msg_data
			       ,  p_organization_id          => l_org_id
			       ,  p_inventory_item_id        => l_item_id
			       ,  p_tree_mode                => 2
			       ,  p_is_revision_control      => l_revision_control
			       ,  p_is_lot_control           => l_lot_control
			       ,  p_is_serial_control        => FALSE
			       ,  p_include_suggestion       => FALSE
			       ,  p_demand_source_type_id    => 2
			       ,  p_demand_source_header_id  => nvl(l_dem_hdr_id,-9999)
			       ,  p_demand_source_line_id    => nvl(l_dem_line_id,-9999)
			       ,  p_demand_source_name       => l_src_code
			       ,  p_demand_source_delivery   => NULL
			       ,  p_lot_expiration_date      => NULL
			       ,  x_tree_id                  => l_tree_id
			       ,  p_onhand_source            => 3 --g_all_subs
			       ,  p_exclusive                => 0 --g_non_exclusive
			       ,  p_pick_release             => 0 --g_pick_release_no
			    ) ;


    	               ELSE

		         INV_QUANTITY_TREE_PVT.create_tree
			    (   p_api_version_number       => 1.0
				,  p_init_msg_lst             => fnd_api.g_false
				,  x_return_status            => l_return_status
				,  x_msg_count                => l_msg_count
				,  x_msg_data                 => l_msg_data
				,  p_organization_id          => l_org_id
				,  p_inventory_item_id        => l_item_id
				,  p_tree_mode                => 2
				,  p_is_revision_control      => l_revision_control
				,  p_is_lot_control           => l_lot_control
				,  p_is_serial_control        => FALSE
				,  p_include_suggestion       => FALSE
				,  p_demand_source_type_id    => nvl(l_srctypeid,-9999)
				,  p_demand_source_header_id  => nvl(l_srcid,-9999)
				,  p_demand_source_line_id    => nvl(l_srclineid,-9999)
				,  p_demand_source_name       => l_src_code
				,  p_demand_source_delivery   => NULL
				,  p_lot_expiration_date      => NULL
				,  x_tree_id                  => l_tree_id
				,  p_onhand_source            => 3 --g_all_subs
				,  p_exclusive                => 0 --g_non_exclusive
  			        ,  p_pick_release             => 0 --g_pick_release_no
			    ) ;
		       END IF;
                       -- Bug 4194323 Ends

		       IF (l_debug = 1) THEN
		         inv_log_util.trace('After create tree tree : ' || l_msg_data,'INV_TXN_MANAGER_PUB', 9);
		       END IF;

		       IF l_return_status IN (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) THEN
		         IF (l_debug = 1) THEN
		           inv_log_util.trace('Error while creating tree : x_msg_data = ' || l_msg_data,'INV_TXN_MANAGER_PUB', 9);
		         END IF;
		         FND_MESSAGE.set_name('INV','INV_ERR_CREATETREE');
		         FND_MESSAGE.set_token('ROUTINE','UE:AVAIL_TO_TRX');
		         l_error_code := FND_MESSAGE.get;
		         l_error_exp := l_msg_data;
		         x_msg_data := l_msg_data;
		         UPDATE MTL_TRANSACTIONS_INTERFACE
		           SET LAST_UPDATE_DATE = SYSDATE,
		           LAST_UPDATED_BY = l_userid,
		           LAST_UPDATE_LOGIN = l_loginid,
		           PROGRAM_UPDATE_DATE = SYSDATE,
		           PROCESS_FLAG = 3,
		           LOCK_FLAG = 2,
		           ERROR_CODE = substrb(l_error_code,1,240),
		           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
		           WHERE ROWID  = l_temp_rowid
		           AND PROCESS_FLAG = 1;

		         --check for batch error
		         loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

                         UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                           SET LAST_UPDATE_DATE = SYSDATE,
                           LAST_UPDATED_BY = l_userid,
                           LAST_UPDATE_LOGIN = l_loginid,
                           PROGRAM_UPDATE_DATE = SYSDATE,
                           PROCESS_FLAG = 3,
                           LOCK_FLAG = 2,
                           ERROR_CODE = substrb(l_error_code,1,240)
                           WHERE TRANSACTION_HEADER_ID = l_header_id
                           AND PROCESS_FLAG = 1
                           AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;  --Bug#5075521
                           -- group error changes.

			 l_current_batch_failed := TRUE;--Bug#5075521
			 l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		       END IF ;
		     END IF; --400
		   END IF;--350

		   IF ( NOT l_current_batch_failed) THEN --100
		     INV_QUANTITY_TREE_PVT.query_tree
	               (   p_api_version_number   => 1.0
		        ,  p_init_msg_lst         => fnd_api.g_false
		        ,  x_return_status        => l_return_status
		        ,  x_msg_count            => l_msg_count
		        ,  x_msg_data             => l_msg_data
		        ,  p_tree_id              => l_tree_id
		        ,  p_revision             => l_rev
		        ,  p_lot_number           => l_lotnum
		        ,  p_subinventory_code    => l_sub_code
		        ,  p_transfer_subinventory_code    => l_xfrsub
		        ,  p_locator_id           => l_locid
		        ,  x_qoh                  => l_qoh
		        ,  x_rqoh                 => l_rqoh
		        ,  x_pqoh                 => l_pqoh
		        ,  x_qr                   => l_qr
		        ,  x_qs                   => l_qs
		        ,  x_att                  => l_att
		        ,  x_atr                  => l_atr
		       );

		     IF l_return_status = fnd_api.g_ret_sts_error THEN
		       IF (l_debug = 1) THEN
		         inv_log_util.trace('Expected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_PUB', 9);
		       END IF;

		     FND_MESSAGE.set_name('INV','INV_INTERNAL_ERROR');
	             FND_MESSAGE.set_token('token1','XACT_QTY1');
             	     l_error_code := FND_MESSAGE.get;
		     l_error_exp := l_msg_data;
		     x_msg_data := l_msg_data;
		     UPDATE MTL_TRANSACTIONS_INTERFACE
	               SET LAST_UPDATE_DATE = SYSDATE,
	               LAST_UPDATED_BY = l_userid,
		       LAST_UPDATE_LOGIN = l_loginid,
		       PROGRAM_UPDATE_DATE = SYSDATE,
		       PROCESS_FLAG = 3,
		       LOCK_FLAG = 2,
		       ERROR_CODE = substrb(l_error_code,1,240),
		       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
	      	       WHERE TRANSACTION_interface_id = l_temp_rowid
		       AND PROCESS_FLAG = 1;
		      --check for batch error
		     loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                       SET LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = l_userid,
                       LAST_UPDATE_LOGIN = l_loginid,
                       PROGRAM_UPDATE_DATE = SYSDATE,
                       PROCESS_FLAG = 3,
                       LOCK_FLAG = 2,
                       ERROR_CODE = substrb(l_error_code,1,240)
                       WHERE TRANSACTION_HEADER_ID = l_header_id
                       AND PROCESS_FLAG = 1
	               AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id; --Bug#5075521
                       -- group error changes.
                     l_current_batch_failed := TRUE;--Bug#5075521
		     l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521

     	           END IF ;

		   IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		     IF (l_debug = 1) THEN
		       inv_log_util.trace('UnExpected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_PUB', 9);
		     END IF;

		     FND_MESSAGE.set_name('INV','INV_INTERNAL_ERROR');
		     FND_MESSAGE.set_token('token1','XACT_QTY1');
		     l_error_code := FND_MESSAGE.get;
		     l_error_exp := l_msg_data;
		     x_msg_data := l_msg_data;
	             UPDATE MTL_TRANSACTIONS_INTERFACE
		       SET LAST_UPDATE_DATE = SYSDATE,
	               LAST_UPDATED_BY = l_userid,
		       LAST_UPDATE_LOGIN = l_loginid,
		       PROGRAM_UPDATE_DATE = SYSDATE,
		       PROCESS_FLAG = 3,
		       LOCK_FLAG = 2,
		       ERROR_CODE = substrb(l_error_code,1,240),
		       ERROR_EXPLANATION = substrb(l_error_exp,1,240)
		       WHERE ROWID = l_temp_rowid
		       AND PROCESS_FLAG = 1;
		       --check for batch error
		     loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

                     UPDATE MTL_TRANSACTIONS_INTERFACE MTI
                       SET LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = l_userid,
                       LAST_UPDATE_LOGIN = l_loginid,
                       PROGRAM_UPDATE_DATE = SYSDATE,
                       PROCESS_FLAG = 3,
                       LOCK_FLAG = 2,
                       ERROR_CODE = substrb(l_error_code,1,240)
                       WHERE TRANSACTION_HEADER_ID = l_header_id
                       AND PROCESS_FLAG = 1
	               AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		       --group error changes.
		     l_current_batch_failed := TRUE;--Bug#5075521
		     l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		   END IF;

	           IF (l_debug = 1) THEN
	             inv_log_util.trace('L_QOH : ' || l_qoh,'INV_TXN_MANAGER_PUB', 9);
	             inv_log_util.trace('L_RQOH : ' || l_rqoh,'INV_TXN_MANAGER_PUB', 9);
	             inv_log_util.trace('L_PQOH : ' || l_pqoh,'INV_TXN_MANAGER_PUB', 9);
	             inv_log_util.trace('L_QR : ' || l_qr,'INV_TXN_MANAGER_PUB', 9);
	             inv_log_util.trace('L_QS : ' || l_qs,'INV_TXN_MANAGER_PUB', 9);
	             inv_log_util.trace('L_ATT : ' || l_att,'INV_TXN_MANAGER_PUB', 9);
	             inv_log_util.trace('L_ATR : ' || l_atr,'INV_TXN_MANAGER_PUB', 9);
	           END IF;
	         END IF;--100

		 -- Bug 3427817: For WIP backflush transactions, we should not
	         -- check for negative availability. If it is
  	         -- a backflush transaction, then get the
	         -- profile value and do not check for
	         -- availability if the profile is set to
	         -- YES.
	         IF ( NOT l_current_batch_failed ) THEN--150
                   /*Bug:5392366. Modified the following condition to also check
                     completion_transaction_id and move_transaction_id to make sure it
                     is a backflush transaction. If both these values are null then
                     it is is not a backflush transaction.
                   */
	           IF ((l_line_rec_Type.transaction_source_type_id = inv_globals.G_SOURCETYPE_WIP) AND
	    	       (l_line_rec_Type.transaction_action_id
	  	        IN (inv_globals.G_ACTION_ISSUE, inv_globals.G_ACTION_NEGCOMPRETURN)AND (l_line_rec_type.completion_transaction_id is not null OR l_line_rec_type.move_transaction_id is not null))) THEN
	  	     -- It is a backflush transaction. Get the
	  	     -- override flag.
	  	     l_override_neg_for_backflush :=
	  	       fnd_profile.value('INV_OVERRIDE_NEG_FOR_BACKFLUSH');
	  	     /*Bug 4764343 Base Bug:4645686. Introducing a new profile 'INV_OVERRIDE_RSV_FOR_BACKFLUSH'
                       for a specific customer.If set to 'Yes', backflush transaction can drive inventory negative,
                       even if any reservations exist for the item*/
		     l_override_rsv_for_backflush := NVL(fnd_profile.value('INV_OVERRIDE_RSV_FOR_BACKFLUSH'), 2);
                   ELSE
                     l_override_neg_for_backflush := 0;
                     l_override_rsv_for_backflush := 2;
		   END IF;
		   IF (l_debug = 1) THEN
		     inv_log_util.trace('l_override_neg_for_backflush ' || l_override_neg_for_backflush,'INV_TXN_MANAGER_PUB', 9);
		     inv_log_util.trace('l_override_rsv_for_backflush ' || l_override_rsv_for_backflush,'INV_TXN_MANAGER_PUB', 9);
		   END IF;

		   --Bug 3487453: Added and set the variable l_translate
		   -- to true for the token to be translated.
	           /* Bug 5444209 No check for gme txns adding back to inventory */
	           IF ((l_Line_rec_Type.wip_entity_type <> 10) OR
                      (l_Line_rec_Type.wip_entity_type = 10 AND l_line_rec_Type.transaction_type_id NOT IN (43, 44, 1002))) THEN
		   IF  (l_att < l_trx_qty) THEN
		     IF (l_neg_inv_rcpt = 1 OR l_override_neg_for_backflush = 1) THEN

		       IF (l_qr >l_trx_qty  OR l_qs >0) THEN
		         /*Bug 4764343 base Bug::4645686. This condition is added for a specific customer by introducing
			   a new profile 'INV_OVERRIDE_RSV_FOR_BACKFLUSH' . If this profile is not set to 'Yes'
			   then the backflush transaction can not consume existing reservations.Else it can consume
			    existing reservation and can drive inventory go negative.
                         */
			 IF (l_override_rsv_for_backflush <> 1 ) THEN
			   inv_log_util.trace('Transaction quantity must be less than or equal to available quantity','INV_TXN_MANAGER_PUB', 9);
			   FND_MESSAGE.set_name('INV','INV_INT_PROCCODE');
			   l_error_code := FND_MESSAGE.get;
		       	   FND_MESSAGE.set_name('INV','INV_QTY_LESS_OR_EQUAL');
			   l_error_exp := FND_MESSAGE.get;
			   x_msg_data := l_error_exp;
			   UPDATE MTL_TRANSACTIONS_INTERFACE
			     SET LAST_UPDATE_DATE = SYSDATE,
			     LAST_UPDATED_BY = l_userid,
			     LAST_UPDATE_LOGIN = l_loginid,
			     PROGRAM_UPDATE_DATE = SYSDATE,
			     PROCESS_FLAG = 3,
			     LOCK_FLAG = 2,
			     ERROR_CODE = substrb(l_error_code,1,240),
			     ERROR_EXPLANATION = substrb(l_error_exp,1,240)
			     WHERE ROWID = l_temp_rowid
			     AND PROCESS_FLAG = 1;
			     --check for batch error
			   loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

		   	   UPDATE MTL_TRANSACTIONS_INTERFACE MTI
  		   	     SET LAST_UPDATE_DATE = SYSDATE,
		   	     LAST_UPDATED_BY = l_userid,
		   	     LAST_UPDATE_LOGIN = l_loginid,
		      	     PROGRAM_UPDATE_DATE = SYSDATE,
		   	     PROCESS_FLAG = 3,
		   	     LOCK_FLAG = 2,
		   	     ERROR_CODE = substrb(l_error_code,1,240)
		   	     WHERE TRANSACTION_HEADER_ID = l_header_id
		   	     AND PROCESS_FLAG = 1
		   	     AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
		   	     -- group error changes.
		   	   l_current_batch_failed := TRUE;--Bug#5075521
		           l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
			 END IF; --override_rsv_for_backflush
		       END IF;

		       IF (NOT l_current_batch_failed ) THEN --200
		         INV_QUANTITY_TREE_PVT.query_tree
	                   (   p_api_version_number   => 1.0
			    ,  p_init_msg_lst         => fnd_api.g_false
			    ,  x_return_status        => l_return_status
			    ,  x_msg_count            => l_msg_count
			    ,  x_msg_data             => l_msg_data
			    ,  p_tree_id              => l_tree_id
			    ,  p_revision             => NULL
			    ,  p_lot_number           => NULL
			    ,  p_subinventory_code    => NULL
			    ,  p_locator_id           => NULL
			    ,  x_qoh                  => l_item_qoh
			    ,  x_rqoh                 => l_item_rqoh
			    ,  x_pqoh                 => l_item_pqoh
			    ,  x_qr                   => l_item_qr
			    ,  x_qs                   => l_item_qs
			    ,  x_att                  => l_item_att
			    ,  x_atr                  => l_item_atr
			    );

			 IF l_return_status = fnd_api.g_ret_sts_error THEN
			   IF (l_debug = 1) THEN
			     inv_log_util.trace('Expected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_PUB', 9);
			   END IF;

			   FND_MESSAGE.set_name('INV','INV_INTERNAL_ERROR');
		    	   FND_MESSAGE.set_token('token1','XACT_QTY1');
			   l_error_code := FND_MESSAGE.get;
			   l_error_exp := l_msg_data;
			   x_msg_data := l_msg_data;
			   UPDATE MTL_TRANSACTIONS_INTERFACE
			     SET LAST_UPDATE_DATE = SYSDATE,
			     LAST_UPDATED_BY = l_userid,
			     LAST_UPDATE_LOGIN = l_loginid,
			     PROGRAM_UPDATE_DATE = SYSDATE,
			     PROCESS_FLAG = 3,
			     LOCK_FLAG = 2,
			     ERROR_CODE = substrb(l_error_code,1,240),
			     ERROR_EXPLANATION = substrb(l_error_exp,1,240)
			     WHERE TRANSACTION_interface_id = l_temp_rowid
			     AND PROCESS_FLAG = 1;
			     --check for batch error
			   loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

			   UPDATE MTL_TRANSACTIONS_INTERFACE MTI
			     SET LAST_UPDATE_DATE = SYSDATE,
			     LAST_UPDATED_BY = l_userid,
		     	     LAST_UPDATE_LOGIN = l_loginid,
			     PROGRAM_UPDATE_DATE = SYSDATE,
			     PROCESS_FLAG = 3,
			     LOCK_FLAG = 2,
			     ERROR_CODE = substrb(l_error_code,1,240)
			     WHERE TRANSACTION_HEADER_ID = l_header_id
			     AND PROCESS_FLAG = 1
			     AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
			     -- group error changes.
			   l_current_batch_failed := TRUE;--Bug#5075521
			   l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
			 END IF ;

			 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
			   IF (l_debug = 1) THEN
			     inv_log_util.trace('UnExpected Error while querying tree : ' || l_msg_data,'INV_TXN_MANAGER_PUB', 9);
			   END IF;

		           FND_MESSAGE.set_name('INV','INV_INTERNAL_ERROR');
   			   FND_MESSAGE.set_token('token1','XACT_QTY1');
			   l_error_code := FND_MESSAGE.get;
			   l_error_exp := l_msg_data;
			   x_msg_data := l_msg_data;
			   UPDATE MTL_TRANSACTIONS_INTERFACE
			     SET LAST_UPDATE_DATE = SYSDATE,
			     LAST_UPDATED_BY = l_userid,
			     LAST_UPDATE_LOGIN = l_loginid,
			     PROGRAM_UPDATE_DATE = SYSDATE,
			     PROCESS_FLAG = 3,
			     LOCK_FLAG = 2,
			     ERROR_CODE = substrb(l_error_code,1,240),
			     ERROR_EXPLANATION = substrb(l_error_exp,1,240)
			     WHERE ROWID = l_temp_rowid
			     AND PROCESS_FLAG = 1;
			     --check for batch error
			   loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

			   UPDATE MTL_TRANSACTIONS_INTERFACE MTI
			     SET LAST_UPDATE_DATE = SYSDATE,
			     LAST_UPDATED_BY = l_userid,
			     LAST_UPDATE_LOGIN = l_loginid,
			     PROGRAM_UPDATE_DATE = SYSDATE,
			     PROCESS_FLAG = 3,
			     LOCK_FLAG = 2,
			     ERROR_CODE = substrb(l_error_code,1,240)
			     WHERE TRANSACTION_HEADER_ID = l_header_id
			     AND PROCESS_FLAG = 1
			     AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
			     --group error changes.
			   l_current_batch_failed := TRUE;--Bug#5075521
			   l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
			 END IF;
		       END IF; --200
		       inv_log_util.trace('L_ITEM_QOH : ' || l_item_qoh,'INV_TXN_MANAGER_PUB', 9);
		       inv_log_util.trace('L_ITEM_RQOH : ' || l_item_rqoh,'INV_TXN_MANAGER_PUB', 9);
		       inv_log_util.trace('L_ITEM_PQOH : ' || l_item_pqoh,'INV_TXN_MANAGER_PUB', 9);
	               inv_log_util.trace('L_ITEM_QR : ' || l_item_qr,'INV_TXN_MANAGER_PUB', 9);
  		       inv_log_util.trace('L_ITEM_QS : ' || l_item_qs,'INV_TXN_MANAGER_PUB', 9);
		       inv_log_util.trace('L_ITEM_ATT : ' || l_item_att,'INV_TXN_MANAGER_PUB', 9);
		       inv_log_util.trace('L_ITEM_ATR : ' || l_item_atr,'INV_TXN_MANAGER_PUB', 9);
		       inv_log_util.trace('L_TRX_QTY : ' || l_trx_qty,'INV_TXN_MANAGER_PUB', 9);

		       IF ( NOT l_current_batch_failed) THEN --250
		         IF (l_item_qoh <> l_item_att) THEN -- Higher Level Reservations
		   	   IF (l_item_att < l_trx_qty AND l_item_qr > 0) THEN
			     /*Bug 4764343 Base Bug::4645686. This condition is added for a specific
                               customer by introducing a new profile 'INV_OVERRIDE_RSV_FOR_BACKFLUSH' .
                               If this profile is not set to 'Yes'then the backflush transaction can not
                               consume existing reservations.Else it can consume existing reservation and can
                               drive inventory  negative. */
			     IF (l_override_rsv_for_backflush <> 1 ) THEN
			       inv_log_util.trace('Total Org quantity cannot become negative when there are reservations present','INV_TXN_MANAGER_PUB', 9);
			     FND_MESSAGE.set_name('INV','INV_INT_PROCCODE');
			     l_error_code := FND_MESSAGE.get;
			     FND_MESSAGE.set_name('INV','INV_ORG_QUANTITY');
			     l_error_exp := FND_MESSAGE.get;
			     FND_MESSAGE.set_name('INV','INV_INTERNAL_ERROR');
			     x_msg_data := l_error_exp;
			    UPDATE MTL_TRANSACTIONS_INTERFACE
			      SET LAST_UPDATE_DATE = SYSDATE,
			      LAST_UPDATED_BY = l_userid,
			      LAST_UPDATE_LOGIN = l_loginid,
			      PROGRAM_UPDATE_DATE = SYSDATE,
			      PROCESS_FLAG = 3,
			      LOCK_FLAG = 2,
			      ERROR_CODE = substrb(l_error_code,1,240),
			      ERROR_EXPLANATION = substrb(l_error_exp,1,240)
			      WHERE ROWID = l_temp_rowid
			      AND PROCESS_FLAG = 1;
			    --check for batch error
			    loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

			    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
			      SET LAST_UPDATE_DATE = SYSDATE,
			      LAST_UPDATED_BY = l_userid,
			      LAST_UPDATE_LOGIN = l_loginid,
			      PROGRAM_UPDATE_DATE = SYSDATE,
			      PROCESS_FLAG = 3,
			      LOCK_FLAG = 2,
			      ERROR_CODE = substrb(l_error_code,1,240)
			      WHERE TRANSACTION_HEADER_ID = l_header_id
			      AND PROCESS_FLAG = 1
			      AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
			      --group error changes.
			    l_current_batch_failed := TRUE;--Bug#5075521
			    l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521

                          END IF;-- override_rsv_for_backflush
			END IF;--total org quantity
		      END IF;--high level
		    END IF; --250

	          ELSE --(neg_inv_rcpt = 1)
	            IF (l_debug = 1) THEN
	  	      inv_log_util.trace('Not Enough Qty: l_att,l_trx_qty:' || l_att||','||l_trx_qty,'INV_TXN_MANAGER_PUB', 9);
		    END IF;
		    FND_MESSAGE.set_name('INV','INV_NO_NEG_BALANCES');
		    l_error_code := FND_MESSAGE.get;
		    FND_MESSAGE.set_name('INV','INV_LESS_OR_EQUAL');
	            FND_MESSAGE.set_token('ENTITY1','INV_QUANTITY',l_translate);
	            FND_MESSAGE.set_token('ENTITY2','AVAIL_TO_TRANSACT',l_translate);
	            l_error_exp := FND_MESSAGE.get;
	            x_msg_data := l_error_exp;
	            UPDATE MTL_TRANSACTIONS_INTERFACE
	     	      SET LAST_UPDATE_DATE = SYSDATE,
	     	      LAST_UPDATED_BY = l_userid,
	     	      LAST_UPDATE_LOGIN = l_loginid,
	     	      PROGRAM_UPDATE_DATE = SYSDATE,
	     	      PROCESS_FLAG = 3,
	     	      LOCK_FLAG = 2,
	     	      ERROR_CODE = substrb(l_error_code,1,240),
	              ERROR_EXPLANATION = substrb(l_error_exp,1,240)
		      WHERE ROWID = l_temp_rowid
		      AND PROCESS_FLAG = 1;
		      --check for batch error
		    loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

		    UPDATE MTL_TRANSACTIONS_INTERFACE MTI
		      SET LAST_UPDATE_DATE = SYSDATE,
		      LAST_UPDATED_BY = l_userid,
		      LAST_UPDATE_LOGIN = l_loginid,
		      PROGRAM_UPDATE_DATE = SYSDATE,
		      PROCESS_FLAG = 3,
		      LOCK_FLAG = 2,
		      ERROR_CODE = substrb(l_error_code,1,240)
		      WHERE TRANSACTION_HEADER_ID = l_header_id
		      AND PROCESS_FLAG = 1
		      AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
		       --                               group error changes.
		    l_current_batch_failed := TRUE;--Bug#5075521
		    l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		  END IF;
		END IF;--check for att and trx qty
		END IF;--IF ((l_Line_rec_Type.wip_entity_type <> 10) OR
	        -- update the qty
	        -- Pawan  11th july Added -  GME does not have transfer subinventory
	        IF ( NOT l_current_batch_failed ) THEN --300
	          IF (l_actid in (2,28)) then
	            inv_quantity_tree_pub.update_quantities
	     	      (p_api_version_number        => 1.0,
	 	       p_init_msg_lst              => fnd_api.g_false,
	 	       x_return_status             => l_return_status,
	      	       x_msg_count                 => l_msg_count,
	 	       x_msg_data                  => l_msg_data,
	 	       p_organization_id           => l_org_id,
	 	       p_inventory_item_id         => l_item_id,
	 	       p_tree_mode                 => 2,
	 	       p_is_revision_control       => l_revision_control,
	 	       p_is_lot_control            => l_lot_control,
     	      	       p_is_serial_control         => FALSE,
	 	       p_demand_source_type_id     => nvl(l_srctypeid,-9999),
	 	       p_demand_source_header_id => nvl(l_srcid,-9999),
	 	       p_demand_source_line_id => nvl(l_srclineid,-9999),
	 	       p_revision                  => l_rev,
	      	       p_lot_number                => l_lotnum,
	 	       p_subinventory_code         => l_xfrsub,
	 	       p_locator_id                => l_xlocid,
	 	       p_primary_quantity          => l_trx_qty,
	 	       p_quantity_type             => inv_quantity_tree_pvt.g_qoh,
	 	       p_onhand_source             => inv_quantity_tree_pvt.g_all_subs,
	 	       x_qoh                       => l_qoh,
	      	       x_rqoh                      => l_rqoh,
	 	       x_qr                        => l_qr,
	 	       x_qs                        => l_qs,
	 	       x_att                       => l_att,
	 	       x_atr                       => l_atr);


	            IF l_return_status <> fnd_api.g_ret_sts_success THEN
	              FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
		      FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.UPDATE_QUANTITIES');
		      l_error_code:= fnd_message.get;
		      l_error_exp :=l_msg_data;
		      x_msg_data := l_msg_data;
		      UPDATE MTL_TRANSACTIONS_INTERFACE
		        SET LAST_UPDATE_DATE = SYSDATE,
		        LAST_UPDATED_BY = l_userid,
		        LAST_UPDATE_LOGIN = l_loginid,
		        PROGRAM_UPDATE_DATE = SYSDATE,
		        PROCESS_FLAG = 3,
		        LOCK_FLAG = 2,
		        ERROR_CODE = substrb(l_error_code,1,240),
		        ERROR_EXPLANATION = substrb(l_error_exp,1,240)
		        WHERE ROWID = l_temp_rowid
		        AND PROCESS_FLAG = 1;
		       --check for batch error
		      loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

		      UPDATE MTL_TRANSACTIONS_INTERFACE MTI
		        SET LAST_UPDATE_DATE = SYSDATE,
		        LAST_UPDATED_BY = l_userid,
		        LAST_UPDATE_LOGIN = l_loginid,
		        PROGRAM_UPDATE_DATE = SYSDATE,
		        PROCESS_FLAG = 3,
		        LOCK_FLAG = 2,
		        ERROR_CODE = substrb(l_error_code,1,240)
		        WHERE TRANSACTION_HEADER_ID = l_header_id
		        AND PROCESS_FLAG = 1
		        AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
		        --                               group error changes.
		      l_current_batch_failed := TRUE;--Bug#5075521
		      l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		    END IF;
		  ELSE
	            /* Jalaj Srivastava Bug 5232394
	               update tree with correct sign.
	               sign is derived from transaction_quantity */

		       inv_quantity_tree_pub.update_quantities
			 (p_api_version_number        => 1.0,
			  p_init_msg_lst              => fnd_api.g_false,
			  x_return_status             => l_return_status,
			  x_msg_count                 => l_msg_count,
			  x_msg_data                  => l_msg_data,
			  p_organization_id           => l_org_id,
			  p_inventory_item_id         => l_item_id,
			  p_tree_mode                 => 2,
			  p_is_revision_control       => l_revision_control,
			  p_is_lot_control            => l_lot_control,
			  p_is_serial_control         => FALSE,
			  p_demand_source_type_id     => nvl(l_srctypeid,-9999),
			  p_demand_source_header_id => nvl(l_srcid,-9999),
			  p_demand_source_line_id => nvl(l_srclineid,-9999),
			  p_revision                  => l_rev,
			  p_lot_number                => l_lotnum,
			  p_subinventory_code         => l_sub_code,
			  p_locator_id                => l_locid,
			  p_primary_quantity          => (sign(l_line_rec_type.transaction_quantity)*(l_trx_qty)),
			  p_quantity_type             => inv_quantity_tree_pvt.g_qoh,
			  p_onhand_source             => inv_quantity_tree_pvt.g_all_subs,
 			  x_qoh                       => l_qoh,
			  x_rqoh                      => l_rqoh,
			  x_qr                        => l_qr,
			  x_qs                        => l_qs,
			  x_att                       => l_att,
			  x_atr                       => l_atr);

		       IF l_return_status <> fnd_api.g_ret_sts_success THEN
			 FND_MESSAGE.set_name('INV', 'INV_ERR_CREATETREE');
    		         FND_MESSAGE.set_token('ROUTINE','INV_QUANTITY_TREE_PUB.UPDATE_QUANTITIES');
			 l_error_code:= fnd_message.get;
			 l_error_exp :=l_msg_data;
		         x_msg_data := l_msg_data;
		         UPDATE MTL_TRANSACTIONS_INTERFACE
		           SET LAST_UPDATE_DATE = SYSDATE,
		           LAST_UPDATED_BY = l_userid,
		           LAST_UPDATE_LOGIN = l_loginid,
		           PROGRAM_UPDATE_DATE = SYSDATE,
		           PROCESS_FLAG = 3,
		           LOCK_FLAG = 2,
		           ERROR_CODE = substrb(l_error_code,1,240),
		           ERROR_EXPLANATION = substrb(l_error_exp,1,240)
		           WHERE ROWID = l_temp_rowid
		           AND PROCESS_FLAG = 1;
		         --check for batch error
		         loaderrmsg('INV_GROUP_ERROR','INV_GROUP_ERROR');

		         UPDATE MTL_TRANSACTIONS_INTERFACE MTI
		           SET LAST_UPDATE_DATE = SYSDATE,
		           LAST_UPDATED_BY = l_userid,
		           LAST_UPDATE_LOGIN = l_loginid,
		           PROGRAM_UPDATE_DATE = SYSDATE,
		           PROCESS_FLAG = 3,
		           LOCK_FLAG = 2,
		           ERROR_CODE = substrb(l_error_code,1,240)
		           WHERE TRANSACTION_HEADER_ID = l_header_id
		           AND PROCESS_FLAG = 1
		           AND TRANSACTION_BATCH_ID = l_Line_rec_Type.transaction_batch_id;
		            --                               group error changes.
		         l_current_batch_failed := TRUE;--Bug#5075521
		         l_current_err_batch_id := l_Line_rec_Type.transaction_batch_id;--Bug#5075521
		       ELSE
		         --qty tree update was successful
		         IF (l_debug = 1) THEN
		           inv_log_util.trace('after update of quantity tree qoh='||l_qoh||' l_att='||l_att||' l_atr='||l_atr,'INV_TXN_MANAGER_PUB', 9);
                         END IF;
		       END IF;
		     END IF;-- Pawan Added for IF (l_actid in (2,28))
		   END IF; --300
		 END IF; --150
                END IF; --If l_rsv_wip_entity_type <> inv_reservation_global.g_wip_source_type_cmro
	       END LOOP;-- Loop Z1
	     END IF;--l_current_err_batch_id is NULL..
           END IF;  --l_srctyped =5

           /*Bug:5209598. End of code*/



            --Start of new code added as per the eIB TDD; Bug# 4348541
            DECLARE
              l_location_required_flag mtl_transaction_types.location_required_flag%TYPE;
            BEGIN
              l_location_required_flag := 'N';
              -- Call the inv_validate.check_location_required_setup procedure
              -- and pass l_line_rec_type.transaction_type_id as parameter to
              -- check if the Location has to be made mandatory. If this procedure
              -- returns 'Y' then check if the Location Code is specified or not.
              -- If it is not specified then error out the interface record.
              inv_validate.check_location_required_setup(
                p_transaction_type_id => l_line_rec_type.transaction_type_id,
                p_required_flag       => l_location_required_flag);

              IF l_location_required_flag = 'Y' AND
                l_line_rec_type.ship_to_location_id IS NULL THEN

                FND_MESSAGE.SET_NAME('INV','INV_LOCATION_MANDATORY');
                l_error_code := FND_MESSAGE.GET;

                UPDATE MTL_TRANSACTIONS_INTERFACE
                 SET LAST_UPDATE_DATE    = SYSDATE,
                     LAST_UPDATED_BY     = l_userid,
                     LAST_UPDATE_LOGIN   = l_loginid,
                     PROGRAM_UPDATE_DATE = SYSDATE,
                     PROCESS_FLAG        = 3,
                     LOCK_FLAG           = 2,
                     ERROR_CODE          = SUBSTR (l_error_code, 1, 240),
                     ERROR_EXPLANATION   = SUBSTR (l_error_code, 1, 240)
                 WHERE ROWID = l_line_rec_type.rowid
                  AND  PROCESS_FLAG = 1;

                RAISE rollback_line_validation;
              END IF;
            END;
            --End of new code added as per the eIB TDD; Bug# 4348541

            SAVEPOINT line_validation_svpt;
            fnd_message.set_name ('INV', 'INV_MOVE_TO_TEMP');
            fnd_message.set_token ('token', l_header_id);
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
            END IF;

            /* Insert into MMTT */
            /** Change for lOt Transactions **/

            IF     l_line_rec_type.transaction_source_type_id = 13
               AND l_line_rec_type.transaction_action_id IN (40, 41, 42)
            THEN
              IF (l_line_rec_type.transaction_action_id = 40)
              THEN
                IF (l_debug = 1)
                THEN
                   inv_log_util.TRACE ('Checking for lot partial split'
                                     , 'INV_TXN_MANAGER_PUB'
                                     , 9
                                      );
                END IF;
                IF (NOT check_partial_split (l_line_rec_type.parent_id
                                           , l_index
                                            )
                   )
                THEN
                  l_error_exp := fnd_message.get;

                  IF (l_debug = 1)
                  THEN
                    inv_log_util.TRACE (   'Error in Check_Partial_Split= '
                                        || l_error_exp
                                      , 'INV_TXN_MANAGER_PUB'
                                      , 9
                                       );
                  END IF;

                  fnd_message.set_name ('INV', 'INV_INT_TMPXFRCODE');
                  l_error_code := fnd_message.get;
                  ROLLBACK TO line_validation_svpt;

                  UPDATE mtl_transactions_interface
                     SET last_update_date = SYSDATE
                       , last_updated_by = l_userid
                       , last_update_login = l_loginid
                       , program_update_date = SYSDATE
                       , process_flag = 3
                       , lock_flag = 2
                       , ERROR_CODE = SUBSTR (l_error_code, 1, 240)
                       , error_explanation = SUBSTR (l_error_exp, 1, 240)
                   WHERE ROWID = l_line_rec_type.ROWID AND process_flag = 1;

                  RAISE rollback_line_validation;
                END IF;
              END IF;
            END IF;                                                    --J-dev


                      /** end of changes for lot transactions **/
          --J dev, done as a bulk insert now. outside the
          --level loop.
          END IF;
        EXCEPTION
          WHEN rollback_line_validation
          THEN
            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE
                                (   'Failed Interface ID : '
                                 || l_line_rec_type.transaction_interface_id
                                 || ' Item: '
                                 || l_line_rec_type.inventory_item_id
                                 || 'Org : '
                                 || l_line_rec_type.organization_id
                               , 'INV_TXN_MANAGER_PUB'
                               , 9
                                );
            END IF;

            batch_error := TRUE;
          WHEN OTHERS
          THEN
            batch_error := TRUE;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE
                (   'Error in INV_TXN_MANAGER_PUB LOOP - rollback last transaction Interface ID '
                 || l_line_rec_type.transaction_interface_id
               , 'INV_TXN_MANAGER_PUB'
               , 9
                );
            END IF;

            ROLLBACK TO line_validation_svpt;
        END;
      END LOOP;                                       -- endloop for AA1 (MTI)

      /*Bug:5209598. Freeing the Tree created for reservation checks.*/
      IF    (l_tree_id IS NOT NULL) THEN
        INV_QUANTITY_TREE_PVT.free_tree
          (  p_api_version_number  => 1.0
	   , p_init_msg_lst        => fnd_api.g_false
	   , x_return_status       => l_return_status
	   , x_msg_count           => l_msg_count
	   , x_msg_data            => l_msg_data
	   , p_tree_id		    => l_tree_id );
      END IF;

      --J-dev check that all records for line validation are failed here.

      --check for batch error at line validation
      loaderrmsg ('INV_GROUP_ERROR', 'INV_GROUP_ERROR');

      UPDATE mtl_transactions_interface mti
         SET last_update_date = SYSDATE
           , last_updated_by = l_userid
           , last_update_login = l_loginid
           , program_update_date = SYSDATE
           , process_flag = 3
           , lock_flag = 2
           , ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
       WHERE transaction_header_id = l_header_id
        AND process_flag = 1
        AND EXISTS
           (SELECT 'Y'
              FROM mtl_transactions_interface mti2
             WHERE mti2.transaction_header_id = l_header_id
               AND mti2.process_flag = 3
               AND mti2.error_code IS NOT NULL
               AND mti2.transaction_batch_id = mti.transaction_batch_id);

/* Commented following and added EXISTS clause above for bug 8444982
         AND transaction_batch_id IN (
               SELECT DISTINCT mti2.transaction_batch_id
                          FROM mtl_transactions_interface mti2
                         WHERE mti2.transaction_header_id = l_header_id
                           AND mti2.process_flag = 3
                           AND mti2.ERROR_CODE IS NOT NULL);
*/
      --                               group error changes.
      IF fnd_api.to_boolean (p_commit)
      THEN
        COMMIT WORK;        /* Commit after LineValidation all MTI records */
      END IF;

      --check if all records have been failed by the Line Validation
      BEGIN
        SELECT transaction_source_type_id
          INTO l_source_type_id
          FROM mtl_transactions_interface
         WHERE transaction_header_id = l_header_id
           AND process_flag = 1
           AND ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          x_return_status := fnd_api.g_ret_sts_error;
          x_msg_data := 'All records failed after line validation';

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('All records failed after line validation'
                              , 'INV_TXN_MANAGER_PUB'
                              , 1
                               );
          END IF;

          RETURN -1;
      END;

      --J-dev
      /******* Group Validation for WIP records *******************/
      /* This WIP API could potentially error some records in MTI. If any records
      /* have been errored, they would be stamped with error-code/explanation */
      -- Bug 6996032. Added NVL condition to l_wip_entity_type
      IF (l_srctypeid = 5)  and (NVL(l_wip_entity_type,-1) <> 10 )-- Pawan added for l_wip_entity_type
      THEN
        wip_mti_pub.postinvwipvalidation (p_txnheaderid      => l_header_id
                                        , x_returnstatus     => x_return_status
                                         );

        IF (x_return_status = fnd_api.g_ret_sts_success)
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Success from:!!postInvWIPValid'
                              , 'INV_TXN_MANAGER_PUB'
                              , 1
                               );
          END IF;

          --J-dev check that all records for line validation are failed here.
          --bug 3727791
          --check for batch error at line validation
          loaderrmsg ('INV_GROUP_ERROR', 'INV_GROUP_ERROR');

          UPDATE mtl_transactions_interface mti
             SET last_update_date = SYSDATE
               , last_updated_by = l_userid
               , last_update_login = l_loginid
               , program_update_date = SYSDATE
               , process_flag = 3
               , lock_flag = 2
               , ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
           WHERE transaction_header_id = l_header_id
             AND process_flag = 1
             AND EXISTS
                 (SELECT 'Y'
                    FROM mtl_transactions_interface mti2
                   WHERE mti2.transaction_header_id = l_header_id
                     AND mti2.process_flag = 3
                     AND mti2.error_code IS NOT NULL
                     AND mti2.transaction_batch_id = mti.transaction_batch_id);

/* Commented following and added EXISTS clause above for bug 8444982
             AND transaction_batch_id IN (
                   SELECT DISTINCT mti2.transaction_batch_id
                              FROM mtl_transactions_interface mti2
                             WHERE mti2.transaction_header_id = l_header_id
                               AND mti2.process_flag = 3
                               AND mti2.ERROR_CODE IS NOT NULL);
*/
          --group error changes.
          IF fnd_api.to_boolean (p_commit)
          THEN
            COMMIT WORK;        /* Commit after PostInvWip all MTI records */
          END IF;

          --check if all records have been failed by the wip API.
          BEGIN
            SELECT transaction_source_type_id
              INTO l_source_type_id
              FROM mtl_transactions_interface
             WHERE transaction_header_id = l_header_id
               AND process_flag = 1
               AND ROWNUM < 2;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              x_return_status := fnd_api.g_ret_sts_error;

	      /*  Bug 3656824
	          Replaced the hard coded message with the last message in the error stack from WIP validation*/
	      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
              RETURN -1;
          END;
        ELSE
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Failure from:!!postInvWIPProcessing'
                              , 'INV_TXN_MANAGER_PUB'
                              , 1
                               );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;                                            --check for success
      END IF;                                                --l_srctypeid = 5

      -- ADD tmp Insert here. In case of an error raise an exception.
      --J-dev

      /*Change for supporting the lot transactions for a lot serial item
       *tmpinsert will insert the data into the temp tables for transactions
       *other than split/merge/translate. Only if it is a success we move on to
       *tmpinsert2 whihc handles the three transactions
       */
      IF (l_debug = 1)
     THEN
   inv_log_util.TRACE ('Calling tmpinsert'
                     , 'INV_TXN_MANAGER_PUB'
                     , 9
                      );
    END IF;

      IF (NOT tmpinsert (l_header_id))
      THEN
        l_error_exp := fnd_message.get;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE ('Error in tmpinsert=' || l_error_exp
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        fnd_message.set_name ('INV', 'INV_INT_TMPXFRCODE');
        l_error_code := fnd_message.get;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSE
        BEGIN
         IF(l_debug = 1) THEN
         inv_log_util.TRACE (  'Calling tmpinsert2'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
         END IF;
         inv_txn_manager_grp.tmpinsert2(
                              x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , x_validation_status => l_validation_status
                            , p_header_id     => l_header_id);
         IF(l_debug = 1) THEN
          inv_log_util.TRACE (  'After tmpinsert2'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
         END IF;
        EXCEPTION
         WHEN OTHERS THEN
         inv_log_util.TRACE (  'tmpinsert2 raised exception '
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
         fnd_message.set_name ('INV', 'INV_INT_TMPXFRCODE');
         l_error_code := fnd_message.get;
         RAISE fnd_api.g_exc_unexpected_error;
        END;

      IF(x_return_status <> fnd_api.g_ret_sts_success OR
           l_validation_status <> 'Y') THEN
          inv_log_util.TRACE (  'tmpinsert2 failed..returned with error '
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
          RAISE fnd_api.g_exc_error;
       END IF;
     END IF;

     /*Bug:5276191.Start of code changes. */

     FOR p_mmtt IN c_mmtt LOOP

       IF (p_mmtt.transaction_action_id in (40,42) )then

         BEGIN
           SELECT serial_number_control_code
           INTO   l_serial_control
           FROM   MTL_SYSTEM_ITEMS
           WHERE  inventory_item_id= p_mmtt.inventory_item_id
           AND    organization_id  = p_mmtt.organization_id;
         EXCEPTION
           WHEN OTHERS THEN
           inv_log_util.TRACE ('Exception in getting serial control code'||Sqlerrm,'INV_TXN_MANAGER_PUB        ', 9);
           RAISE fnd_api.g_exc_unexpected_error;
         END;

         IF (l_serial_control IN (2,5)) THEN

           IF(p_mmtt.locator_id IS NOT NULL) then
             BEGIN
               SELECT project_id INTO l_from_project_id
               FROM mtl_item_locations
               WHERE inventory_location_id = p_mmtt.locator_id
               AND organization_id = p_mmtt.organization_id;
             EXCEPTION
               WHEN OTHERS THEN
	         IF (l_debug = 1) THEN
                   inv_log_util.TRACE ('exception in getting from project: ' || Sqlerrm, 'INV_TXN_MANAGER_PUB', 9);
	         END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
	     END;
           END IF;

           inv_cost_group_update.cost_group_update
		    (p_transaction_rec         => p_mmtt,
		     p_fob_point               => null,
		     p_transfer_wms_org        => FALSE,
		     p_tfr_primary_cost_method => null,
		     p_tfr_org_cost_group_id   => null,
		     p_from_project_id         => l_from_project_id,
		     p_to_project_id           => null,
		     x_return_status           => x_return_status,
		     x_msg_count               => x_msg_count,
		     x_msg_data                => x_msg_data);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
              l_error_exp := x_msg_data;
              RAISE fnd_api.g_exc_error;
            END IF;

          END IF; --l_serial_control_code <>1
        END IF;--action_id in (40,42)

      END LOOP; --c_mmtt loop
    /*Bug:5276191.End of code changes. */



      --- End J dev
      IF fnd_api.to_boolean (p_commit)
      THEN
        COMMIT WORK;            /* Commit after validating all MTI records */
      END IF;

      /* Delete the errored out flow schedules */
      IF (inv_txn_manager_grp.gi_flow_schedule <> 0)
      THEN
        wip_flow_utilities.delete_flow_schedules (l_header_id);
      END IF;

      SELECT COUNT (*)
        INTO l_midtotrows
        FROM mtl_material_transactions_temp
       WHERE transaction_header_id = l_header_id AND process_flag = 'Y';

      DELETE FROM mtl_material_transactions_temp
            WHERE transaction_header_id = l_header_id
              AND shippable_flag = 'N'
              AND process_flag = 'Y';

      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE (   'Goint for rows in MMTT. rcnt = '
                            || l_midtotrows
                            || ',hdrid='
                            || l_header_id
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;

      done := FALSE;
      FIRST := TRUE;

      WHILE (NOT done)
      LOOP
        SAVEPOINT process_trx_save;

        IF (FIRST)
        THEN
          fnd_message.set_name ('INV', 'INV_CALL_PROC');
          fnd_message.set_token ('token1', l_header_id);
          fnd_message.set_token ('token2', l_totrows);
          l_disp := fnd_message.get;

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
          END IF;

          --FND_MESSAGE.set_name('INV','INV_RETURN_PROC');
          --l_disp := FND_MESSAGE.get;
          --inv_log_util.trace(l_disp, 'INV_TXN_MANAGER_PUB',9);
          SELECT COUNT (*)
            INTO l_totrows
            FROM mtl_material_transactions_temp
           WHERE transaction_header_id = l_header_id AND process_flag = 'Y';

          x_trans_count := l_totrows;

          IF (l_totrows = 0)
          THEN
            fnd_message.set_name ('INV', 'INV_PROC_WARN');
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp || ' totrows = 0'
                                , 'INV_TXN_MANAGER_PUB'
                                , 9
                                 );
            END IF;

            RETURN -1;
          END IF;

          IF fnd_api.to_boolean (p_commit)
          THEN
            COMMIT WORK;
          ELSE
            SAVEPOINT process_trx_save;
          END IF;
        END IF;

        /*WIP J-dev Add another condtion in the if
        /* statement below. if WIP.J is not installed call
        /* wip_mtlTempProc_grp()...else call process_lpn_trx()*/
        -- If transactions are of type WIP, then call the WIP API. This
        -- API does the WIP pre-processing before calling process_lpn_trx
        IF (    l_srctypeid = 5
            AND wip_constants.dmf_patchset_level <
                                            wip_constants.dmf_patchset_j_value
           )
        THEN
          wip_mtltempproc_grp.processtemp
               (p_initmsglist      => fnd_api.g_false
              , p_processinv       => fnd_api.g_true
              ,                                 -- call INV TM after WIP logic
                p_txnhdrid         => l_header_id
              , x_returnstatus     => l_return_status
              , x_errormsg         => l_msg_data
               );

          IF (l_return_status <> fnd_api.g_ret_sts_success)
          THEN
            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('Failure from WIP processTemp!!'
                                , 'INV_TXN_MANAGER_PUB'
                                , 1
                                 );
            END IF;

            l_result := -1;
          END IF;
        ELSE
          --Bug #4338316
          --Pass the p_commit value to the TM
          l_result :=
            inv_lpn_trx_pub.process_lpn_trx (p_trx_hdr_id      => l_header_id
                                           , p_commit          => p_commit
                                           , x_proc_msg        => l_msg_data
                                           , p_proc_mode       => 1
                                           , p_process_trx     => fnd_api.g_true
                                           , p_atomic          => fnd_api.g_false
                                            );


        END IF;

        IF (l_result <> 0)
        THEN
          l_error_exp := l_msg_data;
          x_msg_data := l_msg_data;
          x_return_status := l_return_status;
          fnd_message.set_name ('INV', 'INV_INT_PROCCODE');
          l_error_code := fnd_message.get;

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE (   'PROCESS_LPN_TRX failed for header_id '
                                || l_header_id
                              , 'INV_TXN_MANAGER_PUB'
                              , 1
                               );
            inv_log_util.TRACE ('Error.... ' || l_error_exp
                              , 'INV_TXN_MANAGER_PUB'
                              , 9
                               );
          END IF;

          -- Bug 5748351: Deleting MSNT/MTLT/MMTT for the headerId, in case they are still present and did not
          --              get deleted in TM.
          delete from mtl_serial_numbers_temp
          where transaction_temp_id in (
          select mmtt.transaction_temp_id
          from mtl_material_transactions_temp mmtt
          where mmtt.transaction_header_id = l_header_id );

          delete from mtl_serial_numbers_temp
          where transaction_temp_id in (
          select mtlt.serial_transaction_temp_id
          from mtl_transaction_lots_temp mtlt
          where mtlt.transaction_temp_id in (
          select mmtt.transaction_temp_id
          from mtl_material_transactions_temp mmtt
          where mmtt.transaction_header_id = l_header_id));

          DELETE from mtl_transaction_lots_temp
          where transaction_temp_id in
          (select mmtt.transaction_temp_id
          from MTL_MATERIAL_TRANSACTIONS_TEMP mmtt
          WHERE mmtt.TRANSACTION_HEADER_ID = l_header_id );

          DELETE FROM MTL_MATERIAL_TRANSACTIONS_TEMP
          WHERE TRANSACTION_HEADER_ID = l_header_id;

          IF (l_debug = 1) THEN
	     inv_log_util.trace('Deleted MSNT/MTLT/MMTT for header_id ' || l_header_id, 'INV_TXN_MANAGER_PUB',1);
	  END IF;

          -- End of change for bug 5748351

          IF fnd_api.to_boolean (p_commit)
          THEN
            COMMIT WORK;
          END IF;

          RETURN -1;
        END IF;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE ('After process_lpn_trx without errors'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        IF fnd_api.to_boolean (p_commit)
        THEN
          COMMIT WORK;
        END IF;

        IF (FIRST)
        THEN
          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE ('Calling bflushchk', 'INV_TXN_MANAGER_PUB'
                              , 9);
          END IF;

          IF (NOT bflushchk (l_header_id))
          THEN
            l_error_code := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (   'Error in bflushchk header_id:'
                                  || l_header_id
                                  || ' - '
                                  || l_error_code
                                , 'INV_TXN_MANAGER_PUB'
                                , 9
                                 );
            END IF;

            --ROLLBACK TO process_trx_save;
            RETURN -1;
          END IF;

          IF (l_header_id <> -1)
          THEN
            fnd_message.set_name ('INV', 'INV_BFLUSH_PROC');
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
            END IF;

            SELECT COUNT (*)
              INTO l_totrows
              FROM mtl_material_transactions_temp
             WHERE transaction_header_id = l_header_id AND process_flag = 'Y';

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE ('totrows is ' || l_totrows
                                , 'INV_TXN_MANAGER_PUB'
                                , 9
                                 );
            END IF;

            IF (l_totrows > 200)
            THEN
              UPDATE mtl_material_transactions_temp
                 SET transaction_header_id = (-1) * l_header_id
               WHERE transaction_header_id = l_header_id
                     AND process_flag = 'Y';

              UPDATE mtl_material_transactions_temp
                 SET transaction_header_id = ABS (l_header_id)
               WHERE transaction_header_id = (-1) * (l_header_id)
                 AND process_flag = 'Y'
                 AND ROWNUM < 201;
            END IF;

            fnd_message.set_name ('INV', 'INV_CALL_PROC');
            fnd_message.set_token ('token1', l_header_id);
            fnd_message.set_token ('token2', l_totrows);
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
            END IF;
          ELSE
            done := TRUE;
            FIRST := FALSE;
          END IF;
        ELSE
          UPDATE mtl_material_transactions_temp
             SET transaction_header_id = ABS (l_header_id)
           WHERE transaction_header_id = (-1) * (l_header_id)
             AND process_flag = 'Y'
             AND ROWNUM < 201;

          IF SQL%NOTFOUND
          THEN
            fnd_message.set_name ('INV', 'INV_RETURN_PROC');
            l_disp := fnd_message.get;

            IF (l_debug = 1)
            THEN
              inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
            END IF;

            done := TRUE;
          END IF;
        END IF;
      END LOOP;

      IF (l_initotrows > l_midtotrows)
      THEN
        fnd_message.set_name ('INV', 'INV_MGR_WARN');
        l_disp := fnd_message.get;

        IF (l_debug = 1)
        THEN
          inv_log_util.TRACE (l_disp, 'INV_TXN_MANAGER_PUB', 9);
          inv_log_util.TRACE (   l_initotrows
                              -  l_midtotrows
                              || ' Transactions did not pass validation'
                            , 'INV_TXN_MANAGER_PUB'
                            , 9
                             );
        END IF;

        RETURN -1;
      ELSE
        RETURN 0;
      END IF;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('*** SQL error ' || SUBSTR (SQLERRM, 1, 200)
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
      END IF;


      fnd_message.set_name ('INV', 'INV_INT_SQLCODE');
      l_error_code := fnd_message.get;

      IF NOT fnd_api.to_boolean (p_commit)
      THEN
        ROLLBACK TO process_transactions_svpt;
      ELSE
        ROLLBACK WORK;
      END IF;

      UPDATE mtl_transactions_interface
         SET last_update_date = SYSDATE
           , last_updated_by = l_userid
           , last_update_login = l_loginid
           , program_update_date = SYSDATE
           , process_flag = 3
           , lock_flag = 2
           , ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
           , error_explanation = SUBSTRB (l_error_exp, 1, 240)
       WHERE transaction_header_id = l_header_id AND process_flag = 1;

      IF fnd_api.to_boolean (p_commit)
      THEN
        COMMIT WORK;
      END IF;

      RETURN -1;
  END process_transactions;

/******************************************************************
 *
 * Name: insert_relief
 * Description:
 *  Creates a row in MRP_RELIEF_INTERFACE with the values it's passed.
 * This process was taken from mrlpr1.ppc to facilitate PLtion of PL/SQL TM API
 *
 ******************************************************************/
  FUNCTION insert_relief (
    p_new_order_qty    NUMBER
  , p_new_order_date   DATE
  , p_old_order_qty    NUMBER
  , p_old_order_date   DATE
  , p_item_id          NUMBER
  , p_org_id           NUMBER
  , p_disposition_id   NUMBER
  , p_user_id          NUMBER
  , p_line_num         VARCHAR2
  , p_relief_type      NUMBER
  , p_disposition      VARCHAR2
  , p_demand_class     VARCHAR2
  )
    RETURN BOOLEAN
  IS
  BEGIN
    IF (p_relief_type = mds_relief)
    THEN
      IF (p_disposition <> r_sales_order)
      THEN
        fnd_message.set_name ('MRP', 'GEN-invalid entity');
        fnd_message.set_token ('ENTITY', 'disposition');
        fnd_message.set_token ('VALUE', p_disposition);
        RETURN (FALSE);
      END IF;
    ELSE
      IF (p_relief_type = mps_relief)
      THEN
        IF     (p_disposition <> r_work_order)
           AND (p_disposition <> r_purch_order)
        THEN
          fnd_message.set_name ('MRP', 'GEN-invalid entity');
          fnd_message.set_token ('ENTITY', 'disposition');
          fnd_message.set_token ('VALUE', p_disposition);
          RETURN (FALSE);
        END IF;
      ELSE
        fnd_message.set_name ('MRP', 'GEN-invalid entity');
        fnd_message.set_token ('ENTITY', 'relief_type');
        fnd_message.set_token ('VALUE', p_relief_type);
        RETURN (FALSE);
      END IF;
    END IF;

    INSERT INTO mrp_relief_interface
                (transaction_id
               , inventory_item_id
               , organization_id
               , relief_type
               , disposition_type
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , new_order_quantity
               , new_order_date
               , old_order_quantity
               , old_order_date
               , disposition_id
               , demand_class
               , process_status
               , line_num
                )
         VALUES (mrp_relief_interface_s.NEXTVAL
               , p_item_id
               , p_org_id
               , p_relief_type
               , p_disposition
               , SYSDATE
               , p_user_id
               , SYSDATE
               , p_user_id
               , -1
               , p_new_order_qty
               , p_new_order_date
               , p_old_order_qty
               , p_old_order_date
               , p_disposition_id
               , p_demand_class
               , to_be_processed
               , p_line_num
                );

    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Error in insert_relief'
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
        inv_log_util.TRACE ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                          , 'INV_TXN_MANAGER_PUB'
                          , '9'
                           );
      END IF;

      RETURN (FALSE);
  END insert_relief;

/******************************************************************
 | Name: mrp_ship_order
 | Description:
 |       Creates a row in MRP_RELIEF_INTERFACE with the values it's passed.
 ******************************************************************/
  FUNCTION mrp_ship_order (
    p_disposition_id    NUMBER
  , p_inv_item_id       NUMBER
  , p_quantity          NUMBER
  , p_last_updated_by   NUMBER
  , p_org_id            NUMBER
  , p_line_num          VARCHAR2
  , p_shipment_date     DATE
  , p_demand_class      VARCHAR2
  )
    RETURN BOOLEAN
  AS
  BEGIN
    IF (NOT insert_relief (p_quantity
                         , p_shipment_date
                         , 0
                         , NULL
                         , p_inv_item_id
                         , p_org_id
                         , p_disposition_id
                         , p_last_updated_by
                         , p_line_num
                         , mds_relief
                         , r_sales_order
                         , p_demand_class
                          )
       )
    THEN
      RETURN (FALSE);
    ELSE
      RETURN (TRUE);
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF (l_debug = 1)
      THEN
        inv_log_util.TRACE ('Error in mrp_ship_order'
                          , 'INV_TXN_MANAGER_PUB'
                          , 9
                           );
        inv_log_util.TRACE ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                          , 'INV_TXN_MANAGER_PUB'
                          , '9'
                           );
      END IF;

      RETURN (FALSE);
  END mrp_ship_order;

/******************************************************************
 *
 * post_temp_validation()
 *
 ******************************************************************/
  FUNCTION post_temp_validation (
    p_line_rec_type   line_rec_type
  , p_val_req         NUMBER
  , p_userid          NUMBER
  , p_flow_schedule   NUMBER
  , p_lot_number VARCHAR2 -- Added for 4377625
  )
    RETURN BOOLEAN
  IS
    CURSOR z1 (p_flow_sch NUMBER)
    IS
      SELECT p_line_rec_type.ROWID
           , p_line_rec_type.inventory_item_id
           , p_line_rec_type.revision
           , p_line_rec_type.organization_id
           , p_line_rec_type.subinventory_code
           , p_line_rec_type.locator_id
           , ABS (p_line_rec_type.primary_quantity)
           , NULL
           , p_line_rec_type.transaction_source_type_id
           , p_line_rec_type.transaction_action_id
           ,p_line_rec_type.TRANSACTION_TYPE_ID            /*Bug:4866991*/
           , p_line_rec_type.transaction_source_id
           , p_line_rec_type.transaction_source_name
           , TO_CHAR (p_line_rec_type.source_line_id)
           , msi.revision_qty_control_code
           , msi.lot_control_code
           , DECODE (p_line_rec_type.transaction_action_id
                   , 2, p_line_rec_type.transfer_subinventory
                   , 28, p_line_rec_type.transfer_subinventory
                   , NULL
                    )
           , p_line_rec_type.transfer_locator
           , p_line_rec_type.transaction_date
           , mp.negative_inv_receipt_code
        FROM mtl_parameters mp, mtl_system_items msi
       WHERE mp.organization_id = p_line_rec_type.organization_id
         -- AND MP.NEGATIVE_INV_RECEIPT_CODE = 2
         AND p_line_rec_type.process_flag = 1
         -- AND p_line_rec_type.SHIPPABLE_FLAG='Y'
         AND msi.lot_control_code = 1
         AND (   (    p_flow_sch <> 1
                  AND p_line_rec_type.transaction_action_id IN
                                                     (1, 2, 3, 21, 32, 34, 5)
                 )
              OR (p_flow_sch = 1
                  AND p_line_rec_type.transaction_action_id = 32
                 )
             )
         AND msi.organization_id = mp.organization_id
         AND msi.organization_id = p_line_rec_type.organization_id
         AND msi.inventory_item_id = p_line_rec_type.inventory_item_id
      UNION
      SELECT p_line_rec_type.ROWID
           , p_line_rec_type.inventory_item_id
           , p_line_rec_type.revision
           , p_line_rec_type.organization_id
           , p_line_rec_type.subinventory_code
           , p_line_rec_type.locator_id
           , ABS (mtli.primary_quantity)
           , mtli.lot_number
           , p_line_rec_type.transaction_source_type_id
           , p_line_rec_type.transaction_action_id
           ,p_line_rec_type.TRANSACTION_TYPE_ID   /*Bug:4866991*/
           , p_line_rec_type.transaction_source_id
           , p_line_rec_type.transaction_source_name
           , TO_CHAR (p_line_rec_type.source_line_id)
           , msi.revision_qty_control_code
           , msi.lot_control_code
           , DECODE (p_line_rec_type.transaction_action_id
                   , 2, p_line_rec_type.transfer_subinventory
                   , 28, p_line_rec_type.transfer_subinventory
                   , 5, p_line_rec_type.transfer_subinventory
                   , NULL
                    )
           , p_line_rec_type.transfer_locator
           , p_line_rec_type.transaction_date
           , mp.negative_inv_receipt_code
        FROM mtl_transaction_lots_interface mtli
           , mtl_parameters mp
           , mtl_system_items msi
       WHERE mp.organization_id = p_line_rec_type.organization_id
         -- AND MP.NEGATIVE_INV_RECEIPT_CODE = 2
         -- AND p_line_rec_type.SHIPPABLE_FLAG='Y'
         AND mtli.transaction_interface_id =
                                      p_line_rec_type.transaction_interface_id
         AND p_line_rec_type.process_flag = 1
         AND ts_default <> ts_save_only
         AND msi.lot_control_code = 2
         AND (   (    p_flow_sch <> 1
                  AND p_line_rec_type.transaction_action_id IN
                                                     (1, 2, 3, 21, 32, 34, 5)
                 )
              OR (p_flow_sch = 1
                  AND p_line_rec_type.transaction_action_id = 32
                 )
             )
         AND msi.organization_id = mp.organization_id
         AND msi.organization_id = p_line_rec_type.organization_id
         AND msi.inventory_item_id = p_line_rec_type.inventory_item_id
	 AND MTLI.LOT_NUMBER = NVL(p_lot_number, MTLI.LOT_NUMBER); -- Added for 4377625

    CURSOR c1
    IS
      SELECT   a.organization_id
             , a.inventory_item_id
             , NVL (a.transaction_source_id, 0)
             , a.transaction_source_type_id
             , a.trx_source_delivery_id
             , a.trx_source_line_id
             , a.revision
             , DECODE (c.lot_control_code, 2, b.lot_number, a.lot_number)
             , a.subinventory_code
             , a.locator_id
             , DECODE (c.lot_control_code
                     , 2, ABS (NVL (b.primary_quantity, 0))
                     , a.primary_quantity * (-1)
                      )
             , a.transaction_source_name
             , a.transaction_date
             , a.content_lpn_id
          FROM mtl_system_items c
             , mtl_transaction_lots_temp b
             , mtl_material_transactions_temp a
         WHERE a.transaction_header_id = p_line_rec_type.transaction_header_id
           AND a.transaction_temp_id =
                                      p_line_rec_type.transaction_interface_id
           AND a.organization_id = c.organization_id
           AND a.inventory_item_id = c.inventory_item_id
           AND b.transaction_temp_id(+) = a.transaction_temp_id
           AND a.primary_quantity < 0
      ORDER BY a.transaction_source_type_id
             , a.transaction_source_id
             , a.transaction_source_name
             , a.trx_source_line_id
             , a.trx_source_delivery_id
             , a.inventory_item_id
             , a.organization_id;

    l_tempid             NUMBER;
    l_item_id            NUMBER;
    l_org_id             NUMBER;
    l_locid              NUMBER;
    l_srctypeid          NUMBER;
    l_actid              NUMBER;
    l_trxtypeid          NUMBER;   --Bug:4866991
    l_srcid              NUMBER;
    l_xlocid             NUMBER;
    l_temp_rowid         VARCHAR2 (21);
    l_sub_code           VARCHAR2 (11);
    l_lotnum             VARCHAR2 (80);   -- changed lot_number to 80,  inconv
    --Bug #5086940
    --Changed the length to correspond to transaction_source_name
    l_src_code           mtl_transactions_interface.transaction_source_name%TYPE;
    l_xfrsub             VARCHAR2 (11);
    l_rev                VARCHAR2 (4);
    l_srclineid          VARCHAR2 (40);
    l_trxdate            DATE;
    l_qoh                NUMBER;
    l_rqoh               NUMBER;
    l_pqoh               NUMBER;
    l_qr                 NUMBER;
    l_qs                 NUMBER;
    l_att                NUMBER;
    l_atr                NUMBER;
    l_rctrl              NUMBER;
    l_lctrl              NUMBER;
    l_flow_schedule      NUMBER;
    l_trx_qty            NUMBER;
    l_qty                NUMBER          := 0;
    tree_exists          BOOLEAN;
    l_revision_control   BOOLEAN;
    l_lot_control        BOOLEAN;
    l_disp               VARCHAR2 (3000);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2 (2000);
    l_return_status      VARCHAR2 (1);
    l_tree_id            NUMBER;
    /* Added the following variables for Bug 3462946 */
    l_neg_inv_rcpt       NUMBER;
    l_cnt_res            NUMBER;
    l_item_qoh           NUMBER;
    l_item_rqoh          NUMBER;
    l_item_pqoh          NUMBER;
    l_item_qr            NUMBER;
    l_item_qs            NUMBER;
    l_item_att           NUMBER;
    l_item_atr           NUMBER;
    /* Additional Variables needed to handle TrxRsvRelief code */
    l_ship_qty           NUMBER;
    l_userline           VARCHAR2 (40);
    l_demand_class       VARCHAR2 (30);
    l_mps_flag           NUMBER;
    l_deliveryid         NUMBER;
    l_lpnid              NUMBER;
    targetnode           NUMBER;
    x_errd_int_id        NUMBER;

    l_procedure_name     VARCHAR2(60) := g_pkg_name || '.' ||'POST_TEMP_VALIDATION';
    l_progress_indicator VARCHAR2(30) := '0';
    --Bug 8571657
    l_override_rsv NUMBER := 2;

  BEGIN
    IF (l_debug IS NULL) THEN
      l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    END IF;

    IF (l_debug = 1) THEN
       inv_log_util.TRACE ('$Header: INVTXMGB.pls 120.28.12010000.5 2010/02/05 07:19:32 ksaripal ship $' , l_procedure_name , 9);
    END IF;

    l_progress_indicator := '10';

      /**********************************************/
      /* the reservation was successfully releived. */
      /* now if we did ship a +ve qty for a intord  */
      /* or a sales order, then we need to notify   */
      /* mrp about this shipment                    */
      /**********************************************/
    IF (p_val_req = 1) THEN

       l_progress_indicator := '20';
       OPEN z1 (p_flow_schedule);
       tree_exists := FALSE;

       WHILE (TRUE) LOOP

          l_progress_indicator := '30';
          FETCH z1 INTO l_temp_rowid
            , l_item_id
            , l_rev
            , l_org_id
            , l_sub_code
            , l_locid
            , l_trx_qty
            , l_lotnum
            , l_srctypeid
            , l_actid
            , l_trxtypeid   /*Bug:4866991*/
            , l_srcid
            , l_src_code
            , l_srclineid
            , l_rctrl
            , l_lctrl
            , l_xfrsub
            , l_xlocid
            , l_trxdate
            , l_neg_inv_rcpt;

          IF z1%NOTFOUND THEN
             l_progress_indicator := '40';
             IF (l_debug = 1) THEN
                inv_log_util.TRACE ('No more rows to validate quantity'
                              , l_procedure_name
                              , 9
                               );
             END IF;
             EXIT;
          END IF;

          l_progress_indicator := '50';
          IF l_rctrl = 1 THEN
             l_revision_control := FALSE;
          ELSE
             l_revision_control := TRUE;
          END IF;

          IF l_lctrl = 1 THEN
            l_lot_control := FALSE;
          ELSE
            l_lot_control := TRUE;
          END IF;

          tree_exists := TRUE;
-- Bug 2399354  The tree to be cleared prior to creating a tree to avoid
         --        using existing trees

        /*** free cache ***/
          IF p_line_rec_type.transaction_interface_id IS NULL THEN

             IF (l_debug = 1) THEN
                inv_log_util.TRACE ('Interface Id is NULL'
                              , l_procedure_name
                              , 9
                               );
             END IF;
             l_progress_indicator := '60';
             inv_quantity_tree_pvt.clear_quantity_cache;

             --Bug #5086940
             --demand_source_name cannot be greater than 30 characters
             IF (LENGTH(l_src_code) > 30) THEN
               l_src_code := NULL;
             END IF;

             l_progress_indicator := '70';
             inv_quantity_tree_pvt.create_tree (
                                 p_api_version_number          => 1.0
                               , p_init_msg_lst                => fnd_api.g_false
                               , x_return_status               => l_return_status
                               , x_msg_count                   => l_msg_count
                               , x_msg_data                    => l_msg_data
                               , p_organization_id             => l_org_id
                               , p_inventory_item_id           => l_item_id
                               , p_tree_mode                   => 2
                               , p_is_revision_control         => l_revision_control
                               , p_is_lot_control              => l_lot_control
                               , p_is_serial_control           => FALSE
                               , p_include_suggestion          => FALSE
                               , p_demand_source_type_id       => NVL
                                                                    (l_srctypeid
                                                                   , -9999
                                                                    )
                               , p_demand_source_header_id     => NVL
                                                                     (l_srcid
                                                                    , -9999
                                                                     )
                               , p_demand_source_line_id       => NVL
                                                                    (l_srclineid
                                                                   , -9999
                                                                    )
                               , p_demand_source_name          => l_src_code
                               , p_demand_source_delivery      => NULL
                               , p_lot_expiration_date         => NULL
                               , x_tree_id                     => l_tree_id
                               , p_onhand_source               => 3
                                                                  --g_all_subs
                               , p_exclusive                   => 0
                                                             --g_non_exclusive
                               , p_pick_release                => 0
                                                           --g_pick_release_no
                                );

             IF l_return_status = fnd_api.g_ret_sts_error THEN
                inv_log_util.TRACE
                             (   'Error while creating tree : x_msg_data = '
                              || l_msg_data
                            , l_procedure_name
                            , 9
                             );
                fnd_message.set_name ('INV', 'INV_ERR_CREATETREE');
                fnd_message.set_token ('ROUTINE', 'UE:AVAIL_TO_TRX');
                l_error_code := fnd_message.get;
                l_error_exp := l_msg_data;
                RAISE fnd_api.g_exc_error;
             END IF;

             IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                inv_log_util.TRACE (   'Unexpected Error while creating tree : '
                                || l_msg_data
                              , l_procedure_name
                              , 9
                               );
                l_error_exp := l_msg_data;
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;

             l_progress_indicator := '80';
             g_tree_id := l_tree_id;
             tree_exists := true;

          ELSE

             l_progress_indicator := '90';
             l_tree_id := g_tree_id;
             tree_exists := false;

          END IF;

          IF (l_debug = 1) THEN
             inv_log_util.TRACE ('tree id : '||l_tree_id , l_procedure_name , 9);
             inv_log_util.TRACE ('Revision is : '||l_rev , l_procedure_name , 9);
             inv_log_util.TRACE ('Lot is : '||l_lotnum , l_procedure_name , 9);
             inv_log_util.TRACE ('Sub is : '||l_sub_code , l_procedure_name , 9);
             inv_log_util.TRACE ('Xfr Sub is : '||l_xfrsub , l_procedure_name , 9);
             inv_log_util.TRACE ('Locator is : '||l_locid , l_procedure_name , 9);
          END IF;

          l_progress_indicator := '100';
          inv_quantity_tree_pvt.query_tree
                                    (p_api_version_number             => 1.0
                                   , p_init_msg_lst                   => fnd_api.g_false
                                   , x_return_status                  => l_return_status
                                   , x_msg_count                      => l_msg_count
                                   , x_msg_data                       => l_msg_data
                                   , p_tree_id                        => l_tree_id
                                   , p_revision                       => l_rev
                                   , p_lot_number                     => l_lotnum
                                   , p_subinventory_code              => l_sub_code
                                   , p_transfer_subinventory_code     => l_xfrsub
                                   , p_locator_id                     => l_locid
                                   , x_qoh                            => l_qoh
                                   , x_rqoh                           => l_rqoh
                                   , x_pqoh                           => l_pqoh
                                   , x_qr                             => l_qr
                                   , x_qs                             => l_qs
                                   , x_att                            => l_att
                                   , x_atr                            => l_atr
                                    );

          IF l_return_status = fnd_api.g_ret_sts_error THEN
             inv_log_util.TRACE (   'Expected Error while querying tree : '
                                || l_msg_data
                              , l_procedure_name
                              , 9
                               );
             l_error_code := fnd_message.get;
             l_error_exp := l_msg_data;
             fnd_message.set_name ('INV', 'INV_INTERNAL_ERROR');
             fnd_message.set_token ('token1', 'XACT_QTY1');
             RAISE fnd_api.g_exc_error;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             inv_log_util.TRACE (   'UnExpected Error while querying tree : '
                                || l_msg_data
                              , l_procedure_name
                              , 9
                               );
             l_error_code := fnd_message.get;
             l_error_exp := l_msg_data;
             fnd_message.set_name ('INV', 'INV_INTERNAL_ERROR');
             fnd_message.set_token ('token1', 'XACT_QTY1');
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          l_progress_indicator := '110';
          IF (l_debug = 1) THEN
             inv_log_util.TRACE ('L_QOH : ' || l_qoh, l_procedure_name, 9);
             inv_log_util.TRACE ('L_RQOH : ' || l_rqoh, l_procedure_name, 9);
             inv_log_util.TRACE ('L_PQOH : ' || l_pqoh, l_procedure_name, 9);
             inv_log_util.TRACE ('L_QR : ' || l_qr, l_procedure_name, 9);
             inv_log_util.TRACE ('L_QS : ' || l_qs, l_procedure_name, 9);
             inv_log_util.TRACE ('L_ATT : ' || l_att, l_procedure_name, 9);
             inv_log_util.TRACE ('L_ATR : ' || l_atr, l_procedure_name, 9);
          END IF;

/* Bug: 3462946 : Added the code below to check for Negative Balances for a Negative Balances Allowed Org */
          --Bug 8571657
          l_override_rsv := NVL(fnd_profile.value('INV_OVERRIDE_RSV_FOR_BACKFLUSH'), 2);
          IF l_att < 0 THEN
             l_progress_indicator := '120';
             inv_log_util.TRACE ('l_att is than zero', l_procedure_name, 9);

             IF (l_neg_inv_rcpt = 1) THEN
                l_progress_indicator := '130';
                inv_log_util.TRACE ('Negative Balance Allowed Org '
                              , l_procedure_name
                              , 9
                               );

                IF (l_qr > 0 OR l_qs > 0) THEN
                	 IF (l_override_rsv = 1) THEN
                        IF (l_debug = 1) THEN
                        inv_log_util.trace('Do not check low level reservations',l_procedure_name, 9);
                        END IF;
 	                ELSE
                        inv_log_util.TRACE (
                         'Transaction quantity must be less than or equal to available quantity'
                        , l_procedure_name
                        , 9
                        );
                        fnd_message.set_name ('INV', 'INV_INT_PROCCODE');
                        l_error_code := fnd_message.get;
                        fnd_message.set_name ('INV', 'INV_QTY_LESS_OR_EQUAL');
                        l_error_exp := fnd_message.get;
                        RAISE fnd_api.g_exc_error;
                   END IF;
                END IF;

                l_progress_indicator := '140';
                inv_quantity_tree_pvt.query_tree
                                          (p_api_version_number     => 1.0
                                         , p_init_msg_lst           => fnd_api.g_false
                                         , x_return_status          => l_return_status
                                         , x_msg_count              => l_msg_count
                                         , x_msg_data               => l_msg_data
                                         , p_tree_id                => l_tree_id
                                         , p_revision               => NULL
                                         , p_lot_number             => NULL
                                         , p_subinventory_code      => NULL
                                         , p_locator_id             => NULL
                                         , x_qoh                    => l_item_qoh
                                         , x_rqoh                   => l_item_rqoh
                                         , x_pqoh                   => l_item_pqoh
                                         , x_qr                     => l_item_qr
                                         , x_qs                     => l_item_qs
                                         , x_att                    => l_item_att
                                         , x_atr                    => l_item_atr
                                          );

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   inv_log_util.TRACE
                                 (   'Expected Error while querying tree : '
                                  || l_msg_data
                                , l_procedure_name
                                , 9
                                 );
                   l_error_code := fnd_message.get;
                   l_error_exp := l_msg_data;
                   fnd_message.set_name ('INV', 'INV_INTERNAL_ERROR');
                   fnd_message.set_token ('token1', 'XACT_QTY1');
                   RAISE fnd_api.g_exc_error;
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   inv_log_util.TRACE
                               (   'UnExpected Error while querying tree : '
                                || l_msg_data
                              , l_procedure_name
                              , 9
                               );

                   l_error_code := fnd_message.get;
                   l_error_exp := l_msg_data;
                   fnd_message.set_name ('INV', 'INV_INTERNAL_ERROR');
                   fnd_message.set_token ('token1', 'XACT_QTY1');
                   RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                l_progress_indicator := '150';
                IF (l_debug = 1) THEN
                   inv_log_util.TRACE ('L_ITEM_QOH : ' || l_item_qoh
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_ITEM_RQOH : ' || l_item_rqoh
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_ITEM_PQOH : ' || l_item_pqoh
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_ITEM_QR : ' || l_item_qr
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_ITEM_QS : ' || l_item_qs
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_ITEM_ATT : ' || l_item_att
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_ITEM_ATR : ' || l_item_atr
                              , l_procedure_name
                              , 9
                               );
                   inv_log_util.TRACE ('L_TRX_QTY : ' || l_trx_qty
                              , l_procedure_name
                              , 9
                               );
                END IF;

                IF (l_item_qoh <> l_item_att) THEN  -- Higher Level Reservations
                   l_progress_indicator := '160';

                   IF (l_item_att < 0 AND l_item_qr > 0) THEN
                   	                       /*
 	                     *  ------------------------------------------------------------
 	                     *  Enhancement made for the customer:  (BUG: 8571657)
 	                     *  ------------------------------------------------------------
 	                     *  Description:
 	                     * ------------
 	                     *  This fix will allow the TM to process the transactions posted in MTI by bypassing
 	                     *  the reservation validation. This feature is achieved by using the profile option.
 	                     *  Profile Used: INV_OVERRIDE_RSV_FOR_BACKFLUSH
 	                     *
 	                     *  For the existing customers, the DEFAULT behavior is that the transactions
 	                     *  will go through the reservation validation. The transaction error out if any
 	                     *  reservations exist for that item thererby not allowing the inventory to be
 	                     *  driven negative.
 	                     *
 	                     *  The above default behavior can be overridden by setting the profile to 'YES'
 	                     *  thereby immitating the functionality that existed in 11.5.8
 	                     *  Note:
 	                     *  -----
 	                     *  Kindly refer the BUG for an eloborate problem description.
 	                     */

 	                        IF (l_override_rsv = 1) THEN
 	                         IF (l_debug = 1) THEN
 	                                 inv_log_util.trace('Do not check high level reservations',l_procedure_name, 9);
 	                         END IF;
 	                        ELSE
 	                          l_progress_indicator := '180';
 	                          IF (l_debug = 1) THEN
 	                                 inv_log_util.trace('Total Org quantity cannot become negative when there are reservations present',l_procedure_name, 9);
 	                          END IF;
 	                          FND_MESSAGE.set_name('INV','INV_INT_PROCCODE');
 	                          l_error_code := FND_MESSAGE.get;
 	                          FND_MESSAGE.set_name('INV','INV_ORG_QUANTITY');
 	                          FND_MSG_PUB.add;
 	                          l_error_exp := FND_MESSAGE.get;
 	                          RAISE fnd_api.g_exc_error;
 	                        END IF;

 	                       /*
 	                        * The following immediate code is commented inorder to immitate the
 	                        * 11.5.8 functionality (The re-engineered code can be viewed above).
 	                        * Now, the 1158 and R120 functionality co-exist and the expected behavior
 	                        * can be chosen by setting the profile mentioned in the description above.
 	                        *
                           *
                           * Bug:4866991. For subinventory and backflush transfers high level
                           * reservations should not be checked
                           */
                      l_progress_indicator := '170';
                      /*IF ( l_srctypeid = 13 AND l_actid = 2 AND l_trxtypeid not in (66,67,68) ) THEN
                         inv_log_util.trace(
                             'Do not check high level reservations for subinventory and backflush transfers'
                            ,l_procedure_name
                            ,9
                            );
                      ELSE
                         inv_log_util.TRACE (
                            'Total Org quantity cannot become negative when there are reservations present'
                           ,l_procedure_name
                           ,9
                           );
                          fnd_message.set_name ('INV', 'INV_INT_PROCCODE');
                          l_error_code := fnd_message.get;
                          fnd_message.set_name ('INV', 'INV_ORG_QUANTITY');
                          l_error_exp := fnd_message.get;
                          RAISE fnd_api.g_exc_error;
                      END IF;*/
                   END IF;
                END IF;
             ELSE --if (neg_inv_rcpt = 1)
                l_progress_indicator := '180';
                fnd_message.set_name ('INV', 'INV_NO_NEG_BALANCES');
                l_error_code := fnd_message.get;
                fnd_message.set_name ('INV', 'INV_LESS_OR_EQUAL');
                fnd_message.set_token ('ENTITY1', 'INV_QUANTITY');
                fnd_message.set_token ('ENTITY2', 'AVAIL_TO_TRANSACT');
                l_error_exp := fnd_message.get;
                RAISE fnd_api.g_exc_error;
              --exit;
             END IF; -- neg_inv_rcpt
          END IF; -- l_att
/* End of changes for Bug 3462946 */
       END LOOP;

      /* This should be for any error other than not found */
       l_progress_indicator := '190';
       CLOSE z1;

      IF (tree_exists) THEN
         l_progress_indicator := '200';
         inv_quantity_tree_pvt.free_all (p_api_version_number     => 1.0
                                      , p_init_msg_lst           => fnd_api.g_false
                                      , x_return_status          => l_return_status
                                      , x_msg_count              => l_msg_count
                                      , x_msg_data               => l_msg_data
                                       );
      END IF;

   END IF; -- p_val_req

   x_errd_int_id := -9876;
   RETURN TRUE;

 EXCEPTION
    WHEN OTHERS THEN
        inv_log_util.TRACE ('At indicator : ' || l_progress_indicator, l_procedure_name, 9);
        inv_log_util.TRACE ('Error in post_temp_validation : ' || l_error_code
                          , l_procedure_name
                          , '1'
                           );
        inv_log_util.TRACE ('SQL : ' || SUBSTR (SQLERRM, 1, 200)
                          , l_procedure_name
                          , '1'
                           );
      x_errd_int_id := -9876;
      RETURN FALSE;
  END post_temp_validation;

  -- Bug 4764790: passing the transaction id for relieving
  -- reservations along with the serial numbers
  PROCEDURE rel_reservations_mrp_update
    (p_header_id              IN    NUMBER
     , p_transaction_temp_id  IN    NUMBER
     , p_transaction_id       IN    NUMBER DEFAULT NULL
     , p_res_sts                OUT NOCOPY      VARCHAR2
     , p_res_msg                OUT NOCOPY      VARCHAR2
     , p_res_count              OUT NOCOPY      NUMBER
     , p_mrp_status             OUT NOCOPY      VARCHAR2
     )
    IS
       CURSOR c1
    IS
      SELECT   a.organization_id
             , a.inventory_item_id
             , NVL (a.transaction_source_id, 0)
             , a.transaction_source_type_id
             , a.trx_source_delivery_id
             , a.trx_source_line_id
             , a.revision
             , DECODE (c.lot_control_code, 2, b.lot_number, a.lot_number)
             , a.subinventory_code
             , a.locator_id
             , DECODE (c.lot_control_code
                     , 2, ABS (NVL (b.primary_quantity, 0))
                     , a.primary_quantity * (-1)
                      )
             , a.transaction_source_name
             , a.transaction_date
             , NVL(a.content_lpn_id,a.lpn_id) --bug#8650417.Added NVL
             , a.primary_quantity
             ,                                                               --
               a.transaction_action_id
             , A.transaction_type_id     /*Bug:4866991*/
             , a.transfer_subinventory
             , a.transfer_to_location
             , DECODE (a.process_flag, 'Y', 1, 'N', 2, 'E', 3, 3)
             , a.shippable_flag
             , b.transaction_temp_id           --lot record identifier in MTLT
             , a.relieve_high_level_rsv_flag   /*** {{ R12 Enhanced reservations code changes ***/
          FROM mtl_system_items c
             , mtl_transaction_lots_temp b
             , mtl_material_transactions_temp a
         WHERE a.transaction_header_id = p_header_id
           AND a.transaction_temp_id = p_transaction_temp_id
           AND a.organization_id = c.organization_id
           AND a.inventory_item_id = c.inventory_item_id
           AND b.transaction_temp_id(+) = a.transaction_temp_id
--    AND      A.PRIMARY_QUANTITY < 0  /* Bug: 3462946: This clause is commented as BaseTransaction.java already does this validation */
      ORDER BY a.transaction_source_type_id
             , a.transaction_source_id
             , a.transaction_source_name
             , a.trx_source_line_id
             , a.trx_source_delivery_id
             , a.inventory_item_id
             , a.organization_id;

    l_return_status        VARCHAR2 (1);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2 (2000);
    l_ship_qty             NUMBER;
    l_userline             VARCHAR2 (40);
    l_demand_class         VARCHAR2 (30);
    l_mps_flag             NUMBER;
    l_org_id               NUMBER;
    l_item_id              NUMBER;
    l_sub_code             VARCHAR2 (11);
    l_locid                NUMBER;
    l_lotnum               VARCHAR2 (80); -- changed lot_number to 80,  inconv
    l_rev                  VARCHAR2 (4);
    l_srctypeid            NUMBER;
    l_srcid                NUMBER;
    --Bug #5086940
    --Changed the length to correspond to transaction_source_name
    l_src_code             mtl_transactions_interface.transaction_source_name%TYPE;
    l_srclineid            VARCHAR2 (40);
    l_deliveryid           NUMBER;
    l_trx_qty              NUMBER;
    l_trxdate              DATE;
    l_userid               NUMBER;
    l_lpnid                NUMBER;
    l_line_rec_type        line_rec_type;
    l_loginid              NUMBER;
    -- INVCONV fabdi  start
    l_secondary_ship_qty   NUMBER;
    l_qty_at_suom          NUMBER;
  -- INVCONV fabdi  end

    /*** {{ R12 Enhanced reservations code changes ***/
    l_relieve_high_level_rsv_flag VARCHAR2(1);
    l_total_prim_qty_to_relieve   NUMBER := 0;
    l_rel_lpn_id   NUMBER       := null;
    l_rel_loc_id   NUMBER       := null;
    l_rel_sub_code VARCHAR2(11) := null;
    l_rel_lot_num  VARCHAR2(80) := null;
    l_rel_revision VARCHAR2(4)  := null;
    -- Bug 4764790: passing the transaction id for relieving
    -- reservations along with the serial numbers
    l_transaction_id NUMBER := NULL;
    l_wip_entity_type   NUMBER := NULL; -- Bug 4764790
    l_wip_job_type      VARCHAR2(15); -- Bug 4764790
    l_loop_exit  NUMBER := 0;
    /*** End R12 }} ***/

    tree_exists BOOLEAN := false;
    l_tree_id   NUMBER;
    l_lctrl     NUMBER;
    l_rctrl     NUMBER;
    l_revision_control BOOLEAN := FALSE;
    l_lot_control  BOOLEAN := FALSE;

    l_procedure_name VARCHAR2(60) := g_pkg_name || '.' || 'REL_RESERVATIONS_MRP_UPDATE';
    l_progress_indicator VARCHAR2(20) := '0';
  BEGIN

    IF (l_debug IS NULL) THEN
       l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    IF (l_debug = 1) THEN
       inv_log_util.TRACE ('$Header: INVTXMGB.pls 120.28.12010000.5 2010/02/05 07:19:32 ksaripal ship $', l_procedure_name,9);
    END IF;


    IF (g_userid IS NULL) THEN
       g_userid :=  NVL (fnd_profile.VALUE ('USER_ID'), -1);
    END IF;

    l_userid := g_userid;
    l_loginid := NVL(fnd_global.login_id, -1);

    IF (l_debug = 1) THEN
      inv_log_util.TRACE ('USERID :' || l_userid
                        , l_procedure_name
                        , 9
                         );
      inv_log_util.TRACE ('LoginId :' || l_loginid
                        , l_procedure_name
                        , 9
                         );
    END IF;

    p_mrp_status := 'S';
    p_res_sts := 'S';
    p_res_msg := '';
    p_res_count := 0;

    l_progress_indicator := '10';
    OPEN c1;
    LOOP
       l_progress_indicator := '20';
       FETCH c1 INTO l_org_id
          , l_item_id
          , l_srcid
          , l_srctypeid
          , l_deliveryid
          , l_srclineid
          , l_rev
          , l_lotnum
          , l_sub_code
          , l_locid
          , l_trx_qty
          , l_src_code
          , l_trxdate
          , l_lpnid
          , l_line_rec_type.primary_quantity
          , l_line_rec_type.transaction_action_id
          , l_line_rec_type.TRANSACTION_TYPE_ID    /*Bug:4866991*/
          , l_line_rec_type.transfer_subinventory
          , l_line_rec_type.transfer_locator
          , l_line_rec_type.process_flag
          , l_line_rec_type.shippable_flag
          , l_line_rec_type.transaction_interface_id
          , l_relieve_high_level_rsv_flag;

       IF c1%NOTFOUND THEN
          l_progress_indicator := '30';
          IF (l_debug = 1) THEN
             inv_log_util.TRACE ('No more rows to relieve'
                            , l_procedure_name
                            , 9
                             );
          END IF;
          p_res_sts := 'S';
          p_res_msg := '';
          p_res_count := 0;
          EXIT;
       END IF;

       l_progress_indicator := '40';
      -- Bug 4764790: passing the transaction id for relieving
      -- reservations along with the serial numbers
       l_transaction_id := p_transaction_id;

       IF (l_srctypeid = job_schedule) THEN
          l_progress_indicator := '50';
	 -- call get_wip_entity API
	  inv_reservation_pvt.get_wip_entity_type
	   (  p_api_version_number           => 1.0
	      , p_init_msg_lst                 => fnd_api.g_false
	      , x_return_status                => l_return_status
	      , x_msg_count                    => l_msg_count
	      , x_msg_data                     => l_msg_data
	      , p_organization_id              => null
	      , p_item_id                      => null
	      , p_source_type_id               => null
	      , p_source_header_id             => l_srcid
	      , p_source_line_id               => null
	      , p_source_line_detail           => null
	      , x_wip_entity_type              => l_wip_entity_type
	      , x_wip_job_type                 => l_wip_job_type
	      );

	  IF (l_return_status = fnd_api.g_ret_sts_error) THEN
	     inv_log_util.TRACE ('Return status from get wip entity. ' ||l_return_status, l_procedure_name, 9);
	  ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
	       inv_log_util.TRACE ('Return status from get wip entity. ' ||l_return_status, l_procedure_name, 9);
	  END IF;

       END IF; -- job_schedule

       l_progress_indicator := '60';
       IF (l_debug = 1) THEN
	  inv_log_util.TRACE ('Wip entity type ' || l_wip_entity_type, l_procedure_name, 9);
	  inv_log_util.TRACE ('l_srctypeid ' || l_srctypeid, l_procedure_name, 9);
       END IF;

       IF ((l_srctypeid = job_schedule) AND (l_wip_entity_type =
	       inv_reservation_global.g_wip_source_type_cmro)) THEN
	        l_src_code := fnd_api.g_miss_char;
       END IF;

       --Bug #5086940
       --demand_source_name cannot be greater than 30 characters
       IF (LENGTH(l_src_code) > 30) THEN
         l_src_code := fnd_api.g_miss_char;
       END IF;

       IF (l_debug = 1) THEN
        inv_log_util.trace('l_src_code is: ' || l_src_code, l_procedure_name, 9);
       END IF;

       l_progress_indicator := '70';

      -- SRSRIRAN Bug 4437767
      -- Removed inline code branching related to INCONV/ K release
      IF ( NOT ((l_srctypeid = job_schedule) AND (l_wip_entity_type <> inv_reservation_global.g_wip_source_type_cmro))) THEN
          l_progress_indicator := '80';
	  IF (l_debug = 1) THEN
	     inv_log_util.TRACE ('Inside rsv_relief', l_procedure_name, 9);
	  END IF;
	  -- End changes for Bug 4764790
	  inv_trx_relief_c_pvt.rsv_relief
	   (x_return_status          => l_return_status
	    , x_msg_count              => l_msg_count
	    , x_msg_data               => l_msg_data
	    , x_ship_qty               => l_ship_qty --it will be the quantity relieved FROM this api
	    , x_secondary_ship_qty     => l_secondary_ship_qty  --INVCONV fabdi
	    , x_userline               => l_userline
	    , x_demand_class           => l_demand_class
	    , x_mps_flag               => l_mps_flag
	    , p_organization_id        => l_org_id
	    , p_inventory_item_id      => l_item_id
	    , p_subinv                 => l_sub_code
	    , p_locator                => l_locid
	    , p_lotnumber              => l_lotnum
	    , p_revision               => l_rev
	    , p_dsrc_type              => l_srctypeid
	    , p_header_id              => l_srcid
	    , p_dsrc_name              => l_src_code
	    , p_dsrc_line              => l_srclineid
	    , p_dsrc_delivery          => NULL  --l_deliveryid bug2745896
	    , p_qty_at_puom            => ABS (l_trx_qty)
	   , p_qty_at_suom            => l_qty_at_suom -- INVCONV fabdi
	   , p_lpn_id                 => l_lpnid
	   , p_transaction_id         => l_transaction_id --Bug 4764790
          );

          l_progress_indicator := '90';
          /*** {{ R12 Enhanced reservations code changes ***/
          l_total_prim_qty_to_relieve := l_trx_qty - l_ship_qty;

	  --Set the default as 'Y'
	  l_relieve_high_level_rsv_flag := Nvl(l_relieve_high_level_rsv_flag,'Y');
          IF (l_relieve_high_level_rsv_flag = 'Y' and l_total_prim_qty_to_relieve > 0) THEN
             -- start to relieve reservation with higher level
             l_progress_indicator := '100';
             l_rel_lpn_id   := l_lpnid;
             l_rel_loc_id   := l_locid;
             l_rel_sub_code := l_sub_code;
             l_rel_lot_num  := l_lotnum;
             l_rel_revision := l_rev;

             WHILE (l_total_prim_qty_to_relieve > 0) AND (l_loop_exit = 0)
	     LOOP
                l_progress_indicator := '110';
		IF (l_debug = 1) THEN
		   inv_log_util.trace('l_rel_lpn_id : ' || l_rel_lpn_id, l_procedure_name, 9);
		   inv_log_util.trace('l_rel_loc_id : ' || l_rel_loc_id, l_procedure_name, 9);
		   inv_log_util.trace('l_rel_sub_code : ' || l_rel_sub_code, l_procedure_name, 9);
		   inv_log_util.trace('l_rel_lot_num : ' || l_rel_lot_num, l_procedure_name, 9);
		   inv_log_util.trace('l_rel_revision : ' || l_rel_revision, l_procedure_name, 9);
		   inv_log_util.trace('l_loop_exit. before call : ' || l_loop_exit, l_procedure_name, 9);
		END IF;

		IF (l_rel_lpn_id is not null) THEN
		   l_rel_lpn_id := null;
		 ELSIF (l_rel_loc_id is not null) THEN
		   l_rel_loc_id := null;
		 ELSIF (l_rel_sub_code is not null) THEN
		   l_rel_sub_code := null;
		 ELSIF (l_rel_lot_num is not null) THEN
		   l_rel_lot_num := null;
		 ELSIF (l_rel_revision is not null) THEN
		   l_rel_revision := null;
		   l_loop_exit := 1;
		   inv_log_util.trace('Setting revision to null : ' || l_loop_exit, l_procedure_name, 9);
		END IF;

                l_progress_indicator := '120';
		inv_trx_relief_c_pvt.rsv_relief
		  (x_return_status          => l_return_status
		   , x_msg_count              => l_msg_count
		   , x_msg_data               => l_msg_data
		   , x_ship_qty               => l_ship_qty --it will be the quantity relieved FROM this api
		   , x_secondary_ship_qty     => l_secondary_ship_qty --INVCONV fabdi
		   , x_userline               => l_userline
		   , x_demand_class           => l_demand_class
		   , x_mps_flag               => l_mps_flag
		   , p_organization_id        => l_org_id
		   , p_inventory_item_id      => l_item_id
		   , p_subinv                 => l_rel_sub_code
		   , p_locator                => l_rel_loc_id
		   , p_lotnumber              => l_rel_lot_num
		   , p_revision               => l_rel_revision
		   , p_dsrc_type              => l_srctypeid
		   , p_header_id              => l_srcid
		   , p_dsrc_name              => l_src_code
		   , p_dsrc_line              => l_srclineid
		   , p_dsrc_delivery          => NULL --l_deliveryid bug2745896
		   , p_qty_at_puom            => ABS (l_total_prim_qty_to_relieve)
		  , p_qty_at_suom            => l_qty_at_suom  -- INVCONV fabdi
		  , p_lpn_id                 => l_rel_lpn_id
		  , p_transaction_id         => l_transaction_id --Bug 4764790
		  );

		l_total_prim_qty_to_relieve := l_total_prim_qty_to_relieve - l_ship_qty;
		IF (l_rel_lpn_id IS NULL AND l_rel_loc_id IS NULL AND
		    l_rel_sub_code IS NULL AND l_rel_lot_num IS NULL AND
		    l_rel_revision IS NULL) THEN
		   l_loop_exit := 1;
		END IF;

		inv_log_util.trace('l_loop_exit. After call ' || l_loop_exit, l_procedure_name, 9);
	     END LOOP;
	     l_ship_qty := l_trx_qty - l_total_prim_qty_to_relieve;
          END IF; -- relieve_reservations flag..
        /*** End R12 }} ***/
	END IF;

       IF (l_debug = 1) THEN
          inv_log_util.TRACE ('l_return_status : ' || l_return_status
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_ship_qty : ' || l_ship_qty
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_userline : ' || l_userline
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_demand_class : ' || l_demand_class
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_mps_flag  : ' || l_mps_flag
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_org_id : ' || l_org_id
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_item_id : ' || l_item_id
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_sub_code: ' || l_sub_code
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_locid : ' || l_locid, l_procedure_name, 9);
          inv_log_util.TRACE ('l_lotnum : ' || l_lotnum
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_rev : ' || l_rev, l_procedure_name, 9);
          inv_log_util.TRACE ('l_srctypeid : ' || l_srctypeid
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_header_id ' || l_srcid
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_dsrc_name : ' || l_src_code
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_dsrc_line : ' || l_srclineid
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_dsrc_delivery :' || l_deliveryid
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_dsrc_delivery :' || l_deliveryid
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_trx_qty : ' || l_trx_qty
                          , l_procedure_name
                          , 9
                           );
          inv_log_util.TRACE ('l_lpnid : ' || l_lpnid, l_procedure_name, 9);
       END IF;

       p_res_sts := l_return_status;
       p_res_msg := l_msg_data;
       p_res_count := l_msg_count;

       IF l_return_status <> fnd_api.g_ret_sts_success THEN
          IF (l_debug = 1) THEN
             inv_log_util.TRACE ('x_msg_data = ' || l_msg_data
                            , l_procedure_name
                            , 9
                             );
             inv_log_util.TRACE ('Before error return in TrxRsvRelief'
                            , l_procedure_name
                            , 9
                             );
          END IF;
          RETURN;
       ELSE -- return success
          IF (l_debug = 1) THEN
             inv_log_util.TRACE ('Reservation was successfully relieved'
                            , l_procedure_name
                            , 9
                             );
          END IF;

          IF (ABS (l_trx_qty) <> 0) AND (l_srctypeid = salorder OR l_srctypeid = intorder)
              AND (l_mps_flag <> 0) THEN
              IF (l_debug = 1) THEN
                 inv_log_util.TRACE ('Calling mrp_ship_order'
                              , l_procedure_name
                              , 9
                               );
              END IF;
              IF (NOT mrp_ship_order (l_srclineid
                                , l_item_id
                                , ABS (l_trx_qty)
                                , l_userid
                                , l_org_id
                                , l_userline
                                , l_trxdate
                                , l_demand_class
                                 )
                 ) THEN
                 IF (l_debug = 1) THEN
                     inv_log_util.TRACE ('mrp_ship_order failure'
                                , l_procedure_name
                                , 9
                                 );
                 END IF;
                 p_mrp_status := 'E';
                 RETURN;
              END IF; -- return success

              IF (l_debug = 1) THEN
                 inv_log_util.TRACE ('After mrp__order', l_procedure_name, 9);
              END IF;
          END IF; --  ABS(l_trx..)

       END IF; -- return success

       IF l_ship_qty <> ABS (l_trx_qty) THEN --in this case there

          IF (l_debug = 1) THEN
             inv_log_util.TRACE (   'l_PRIMARY_QUANTITY: '
                              || l_line_rec_type.primary_quantity
                            , l_procedure_name
                            , 9
                             );
             inv_log_util.TRACE (   'l_transaction_action_id: '
                              || l_line_rec_type.transaction_action_id
                            , l_procedure_name
                            , 9
                             );
             inv_log_util.TRACE (   'l_process_flag :'
                              || l_line_rec_type.process_flag
                            , l_procedure_name
                            , 9
                             );
             inv_log_util.TRACE (   'l_shippable_flag : '
                              || l_line_rec_type.shippable_flag
                            , l_procedure_name
                            , 9
                             );
          END IF;

          l_line_rec_type.inventory_item_id := l_item_id;
          l_line_rec_type.revision := l_rev;
          l_line_rec_type.organization_id := l_org_id;
          l_line_rec_type.subinventory_code := l_sub_code;
          l_line_rec_type.locator_id := l_locid;
          l_line_rec_type.transaction_source_type_id := l_srctypeid;
          l_line_rec_type.transaction_source_id := l_srcid;
          l_line_rec_type.transaction_source_name := l_src_code;
          l_line_rec_type.source_line_id := l_srclineid;
          l_line_rec_type.transaction_date := l_trxdate;

          BEGIN
             SELECT lot_control_code,
                    revision_qty_control_code
             INTO   l_lctrl,
                    l_rctrl
             FROM   mtl_system_items_b
             WHERE  organization_id = l_org_id
             AND    inventory_item_id = l_item_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_lctrl := 0;
                l_rctrl := 0;
          END;

          l_progress_indicator := '1305';
          IF l_rctrl = 1 THEN
             l_revision_control := FALSE;
          ELSE
             l_revision_control := TRUE;
          END IF;

          IF l_lctrl = 1 THEN
             l_lot_control := FALSE;
          ELSE
             l_lot_control := TRUE;
          END IF;

          IF (l_line_rec_type.transaction_interface_id IS NOT NULL  ) AND ( g_interface_id IS NULL OR g_interface_id <> l_line_rec_type.transaction_interface_id ) THEN

              l_progress_indicator := '135';
              INV_QUANTITY_TREE_PVT.clear_quantity_cache;

              l_progress_indicator := '1351';
              INV_QUANTITY_TREE_PVT.create_tree
                      (   p_api_version_number       => 1.0
                       ,  p_init_msg_lst             => fnd_api.g_false
                       ,  x_return_status            => l_return_status
                       ,  x_msg_count                => l_msg_count
                       ,  x_msg_data                 => l_msg_data
                       ,  p_organization_id          => l_org_id
                       ,  p_inventory_item_id        => l_item_id
                       ,  p_tree_mode                => 2
                       ,  p_is_revision_control      => l_revision_control
                       ,  p_is_lot_control           => l_lot_control
                       ,  p_is_serial_control        => FALSE
                       ,  p_include_suggestion       => FALSE
                       ,  p_demand_source_type_id    => nvl(l_srctypeid,-9999)
                       ,  p_demand_source_header_id  => nvl(l_srcid,-9999)
                       ,  p_demand_source_line_id    => nvl(l_srclineid,-9999)
                       ,  p_demand_source_name       => l_src_code
                       ,  p_demand_source_delivery   => NULL
                       ,  p_lot_expiration_date      => NULL
                       ,  x_tree_id                  => l_tree_id
                       ,  p_onhand_source            => 3 --g_all_subs
                       ,  p_exclusive                => 0 --g_non_exclusive
                       ,  p_pick_release             => 0 --g_pick_release_no
                    ) ;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('Error while creating tree : x_msg_data = ' || l_msg_data,l_procedure_name, 9);
                 END IF;
                 FND_MESSAGE.set_name('INV','INV_ERR_CREATETREE');
                 FND_MESSAGE.set_token('ROUTINE','UE:AVAIL_TO_TRX');

                 l_error_code := FND_MESSAGE.get;
                 l_error_exp := l_msg_data;
                 RAISE fnd_api.g_exc_error;
              END IF ;

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 IF (l_debug = 1) THEN
                    inv_log_util.trace('Unexpected Error while creating tree : ' || l_msg_data,l_procedure_name, 9);
                 END IF;
                 l_error_exp := l_msg_data;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              g_interface_id := l_line_rec_type.transaction_interface_id;
              tree_exists := TRUE;
              g_tree_id := l_tree_id;
              IF (l_debug = 1) THEN
                 inv_log_util.trace('Tree id is '||g_tree_id, l_procedure_name, 9);
              END IF;

           END IF; /* interface id has changed */
           --qty-tree validation
           IF ((NOT post_temp_validation (l_line_rec_type
                                     , 1                  --always validate it
                                     , l_userid
                                     , inv_txn_manager_grp.gi_flow_schedule
				     , l_lotnum -- Added for 4377625
                                      )
             )
            )
          THEN

          l_error_code := fnd_message.get;

          UPDATE mtl_transactions_interface
             SET last_update_date = SYSDATE
               , last_updated_by = l_userid
               , last_update_login = l_loginid
               , program_update_date = SYSDATE
               , process_flag = 3
               , lock_flag = 2
               , ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
               , error_explanation = SUBSTRB (l_error_exp, 1, 240)
           --WHERE ROWID = l_Line_rec_type.rowid
          WHERE  transaction_interface_id = p_transaction_temp_id
             AND process_flag = 1
             AND organization_id = l_org_id
             AND inventory_item_id = l_item_id
             AND NVL (subinventory_code, '@@@@') = NVL (l_sub_code, '@@@@');

          UPDATE mtl_transactions_interface
             SET last_update_date = SYSDATE
               , last_updated_by = l_userid
               , last_update_login = l_loginid
               , program_update_date = SYSDATE
               , process_flag = 3
               , lock_flag = 2
               , ERROR_CODE = SUBSTRB (l_error_code, 1, 240)
           --WHERE TRANSACTION_HEADER_ID = l_header_id
          WHERE  transaction_interface_id = p_transaction_temp_id
             AND process_flag = 1;

          IF (l_debug = 1)
          THEN
            inv_log_util.TRACE
                          ('After Error in post_temp_validation continue...'
                         , l_procedure_name
                         , 9
                          );
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END LOOP;

    CLOSE c1;
   l_progress_indicator := '180';
   IF (tree_exists) THEN
      l_progress_indicator := '190';
      INV_QUANTITY_TREE_PVT.free_All
                          (   p_api_version_number   => 1.0
                           ,  p_init_msg_lst         => fnd_api.g_false
                           ,  x_return_status        => l_return_status
                           ,  x_msg_count            => l_msg_count
                           ,  x_msg_data             => l_msg_data);
   END IF;
  EXCEPTION
    WHEN OTHERS THEN
       inv_log_util.TRACE (   '***Undef Error Ex..rel_res : '
                            || SUBSTR (SQLERRM, 1, 200)
                          , l_procedure_name
                          , '9'
                           );
       inv_log_util.TRACE (   'When others Ex..rel_reservations_mrp_update '
                            || l_error_code
                          , l_procedure_name
                          , '1'
                           );
       p_res_sts := 'E';
       p_mrp_status := 'E';
  END rel_reservations_mrp_update;
END inv_txn_manager_pub;

/
